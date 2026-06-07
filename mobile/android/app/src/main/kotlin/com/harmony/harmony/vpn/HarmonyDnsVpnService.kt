package com.harmony.harmony.vpn

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.FileInputStream
import java.io.FileOutputStream
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress

/**
 * VpnService minimaliste qui impose un DNS filtrant familial à l'appareil.
 *
 * Approche "DNS-only VPN" :
 *   - Crée une interface TUN locale (198.18.0.1/32).
 *   - Annonce 198.18.0.2 comme serveur DNS système (via addDnsServer).
 *   - Route uniquement 198.18.0.2/32 dans le tunnel TUN — tout le reste
 *     continue à passer par la connexion réseau normale.
 *   - Thread de relais : intercepte les requêtes DNS UDP (port 53) arrivant
 *     sur le TUN, les transmet à CleanBrowsing Family (185.228.168.168), et
 *     retourne la réponse filtrée à l'application appelante.
 *
 * Aucun contenu HTTPS n'est inspecté ou redirigé. Le filtrage est délégué
 * entièrement au résolveur familial CleanBrowsing.
 */
class HarmonyDnsVpnService : VpnService() {

    companion object {
        const val ACTION_START = "com.harmony.harmony.START_DNS_VPN"
        const val ACTION_STOP  = "com.harmony.harmony.STOP_DNS_VPN"

        // Résolveurs familiaux CleanBrowsing (bloquent adultes + malware)
        private const val REAL_DNS_PRIMARY   = "185.228.168.168"
        private const val REAL_DNS_SECONDARY = "185.228.169.168"

        // Adresse TUN locale et faux DNS annoncé au système
        private const val TUN_ADDR      = "198.18.0.1"
        private const val FAKE_DNS_ADDR = "198.18.0.2"
        private const val DNS_PORT      = 53

        private const val CHANNEL_ID = "harmony_dns_vpn"
        private const val NOTIF_ID   = 7002
        private const val TAG        = "HarmonyDnsVpn"

        /** Indique si le tunnel DNS est actif — lu par [ContentFilterPlugin]. */
        @Volatile
        var isRunning = false
            private set
    }

    private var vpnInterface: ParcelFileDescriptor? = null
    private var relayThread: Thread? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startVpn()
            ACTION_STOP  -> stopVpn()
        }
        return START_STICKY
    }

    // ── Démarrage ────────────────────────────────────────────────────────────

    private fun startVpn() {
        if (vpnInterface != null) return  // idempotent
        try {
            val pfd = Builder()
                .addAddress(TUN_ADDR, 32)
                .addDnsServer(FAKE_DNS_ADDR)
                .addRoute(FAKE_DNS_ADDR, 32)  // seul le trafic vers le faux DNS passe par le tunnel
                .setSession("KimiaCare DNS Filter")
                .setBlocking(true)
                .establish()

            if (pfd == null) {
                Log.w(TAG, "establish() null — permission VPN non accordée")
                return
            }
            vpnInterface = pfd
            isRunning    = true
            startForeground(NOTIF_ID, buildNotification())
            relayThread = Thread(::runDnsRelay, "HarmonyDnsRelay").also { it.start() }
            Log.i(TAG, "VPN DNS démarré — DNS système → $REAL_DNS_PRIMARY")
        } catch (e: Exception) {
            Log.e(TAG, "startVpn failed: ${e.message}", e)
            stopVpn()
        }
    }

    // ── Arrêt ────────────────────────────────────────────────────────────────

    private fun stopVpn() {
        isRunning = false
        relayThread?.interrupt()
        relayThread = null
        try { vpnInterface?.close() } catch (_: Exception) {}
        vpnInterface = null
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        Log.i(TAG, "VPN DNS arrêté")
    }

    // ── Thread de relais DNS ─────────────────────────────────────────────────

    private fun runDnsRelay() {
        val fd     = vpnInterface?.fileDescriptor ?: return
        val input  = FileInputStream(fd)
        val output = FileOutputStream(fd)
        val buf    = ByteArray(32768)

        while (isRunning && !Thread.interrupted()) {
            try {
                val n = input.read(buf)
                if (n < 28) continue  // paquet trop court (IP 20 + UDP 8)

                // Vérifier IPv4
                if ((buf[0].toInt() and 0xF0) != 0x40) continue
                val protocol = buf[9].toInt() and 0xFF
                if (protocol != 17) continue  // UDP uniquement

                val ihl     = (buf[0].toInt() and 0x0F) * 4
                val dstPort = ((buf[ihl + 2].toInt() and 0xFF) shl 8) or (buf[ihl + 3].toInt() and 0xFF)
                if (dstPort != DNS_PORT) continue

                val srcPort = ((buf[ihl].toInt() and 0xFF) shl 8) or (buf[ihl + 1].toInt() and 0xFF)
                val srcIp   = buf.copyOfRange(12, 16)
                val query   = buf.copyOfRange(ihl + 8, n)

                val response = forwardDns(query) ?: continue

                // Réponse : source = FAKE_DNS_ADDR, destination = IP source de la requête
                val fakeIp = byteArrayOf(198.toByte(), 18, 0, 2)
                output.write(buildUdpPacket(fakeIp, srcIp, DNS_PORT, srcPort, response))

            } catch (_: InterruptedException) {
                break
            } catch (e: Exception) {
                if (!isRunning) break
                Log.w(TAG, "relay error: ${e.message}")
            }
        }
    }

    /** Transmet la requête DNS à CleanBrowsing et retourne la réponse. */
    private fun forwardDns(query: ByteArray): ByteArray? {
        return try {
            val sock = DatagramSocket()
            protect(sock)  // exempte ce socket du tunnel VPN pour atteindre Internet
            sock.soTimeout = 3000
            val addr = InetAddress.getByName(REAL_DNS_PRIMARY)
            sock.send(DatagramPacket(query, query.size, addr, DNS_PORT))
            val resp = ByteArray(512)
            val pkt  = DatagramPacket(resp, resp.size)
            sock.receive(pkt)
            sock.close()
            resp.copyOf(pkt.length)
        } catch (e: Exception) {
            Log.w(TAG, "DNS forward failed: ${e.message}")
            null
        }
    }

    // ── Construction de paquet IP/UDP ────────────────────────────────────────

    private fun buildUdpPacket(
        srcIp: ByteArray, dstIp: ByteArray,
        srcPort: Int, dstPort: Int,
        payload: ByteArray,
    ): ByteArray {
        val udpLen = 8 + payload.size
        val ipLen  = 20 + udpLen
        val pkt    = ByteArray(ipLen)

        // En-tête IPv4 (20 octets, sans options)
        pkt[0]  = 0x45.toByte()                    // version=4, IHL=5
        pkt[2]  = (ipLen ushr 8).toByte()
        pkt[3]  = (ipLen and 0xFF).toByte()
        pkt[6]  = 0x40.toByte()                    // flag DF
        pkt[8]  = 0x40.toByte()                    // TTL=64
        pkt[9]  = 0x11.toByte()                    // protocole UDP
        srcIp.copyInto(pkt, 12)
        dstIp.copyInto(pkt, 16)
        val csum = ipChecksum(pkt, 0, 20)
        pkt[10] = (csum ushr 8).toByte()
        pkt[11] = (csum and 0xFF).toByte()

        // En-tête UDP (8 octets)
        pkt[20] = (srcPort ushr 8).toByte()
        pkt[21] = (srcPort and 0xFF).toByte()
        pkt[22] = (dstPort ushr 8).toByte()
        pkt[23] = (dstPort and 0xFF).toByte()
        pkt[24] = (udpLen ushr 8).toByte()
        pkt[25] = (udpLen and 0xFF).toByte()
        // Checksum UDP = 0 (facultatif en IPv4)

        payload.copyInto(pkt, 28)
        return pkt
    }

    private fun ipChecksum(buf: ByteArray, offset: Int, len: Int): Int {
        var sum = 0
        var i   = offset
        while (i < offset + len) {
            val hi = buf[i].toInt() and 0xFF
            val lo = if (i + 1 < offset + len) buf[i + 1].toInt() and 0xFF else 0
            sum += (hi shl 8) or lo
            i   += 2
        }
        while (sum ushr 16 != 0) sum = (sum and 0xFFFF) + (sum ushr 16)
        return sum.inv() and 0xFFFF
    }

    // ── Notification foreground ──────────────────────────────────────────────

    private fun createNotificationChannel() {
        val nm = getSystemService(NotificationManager::class.java)
        val ch = NotificationChannel(
            CHANNEL_ID,
            "Filtrage de contenu",
            NotificationManager.IMPORTANCE_LOW,
        ).apply { description = "Harmony filtre les sites adultes via DNS familial." }
        nm.createNotificationChannel(ch)
    }

    private fun buildNotification(): Notification =
        Notification.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_manage)
            .setContentTitle("Filtrage DNS actif")
            .setContentText("Harmony protège la navigation de cet appareil.")
            .setOngoing(true)
            .build()

    override fun onDestroy() {
        stopVpn()
        super.onDestroy()
    }
}
