package com.kimiacare.app.contacts

import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.provider.ContactsContract
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Plugin natif pour lire TOUS les contacts du device, y compris ceux avec account_type=NULL.
 * flutter_contacts 1.1.9 ignore les contacts sans compte — ce plugin contourne ce comportement
 * en queryant directement ContactsContract.
 */
class ContactsReaderPlugin(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL_NAME = "com.kimiacare.app/contacts_reader"
        private const val TAG = "HARMONY-CONTACTS"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "readAllContacts" -> {
                try {
                    val contacts = readAllContacts()
                    Log.d(TAG, "readAllContacts() returning ${contacts.size} contacts to Flutter")
                    result.success(contacts)
                } catch (e: SecurityException) {
                    Log.e(TAG, "readAllContacts() SecurityException (permission manquante?): ${e.message}")
                    result.error("PERMISSION_DENIED", e.message, null)
                } catch (e: Exception) {
                    Log.e(TAG, "readAllContacts() exception: ${e.message}", e)
                    result.error("READ_CONTACTS_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun readAllContacts(): List<Map<String, Any>> {
        val cr: ContentResolver = context.contentResolver

        // Étape 1 : lire TOUS les raw_contacts (sans filtre account_type)
        // Le résultat est groupé par CONTACT_ID pour merger les raw_contacts
        // d'un même contact logique.
        val contactMap = mutableMapOf<Long, ContactBuilder>()

        val rawProjection = arrayOf(
            ContactsContract.RawContacts._ID,
            ContactsContract.RawContacts.CONTACT_ID,
            ContactsContract.RawContacts.DISPLAY_NAME_PRIMARY,
            ContactsContract.RawContacts.ACCOUNT_TYPE,
        )

        val rawCursor: Cursor? = cr.query(
            ContactsContract.RawContacts.CONTENT_URI,
            rawProjection,
            null, null,
            ContactsContract.RawContacts.DISPLAY_NAME_PRIMARY,
        )

        Log.d(TAG, "raw_contacts cursor count: ${rawCursor?.count ?: -1}")

        rawCursor?.use { cursor ->
            while (cursor.moveToNext()) {
                val rawId = cursor.safeGetLong(ContactsContract.RawContacts._ID) ?: continue
                val contactId = cursor.safeGetLong(ContactsContract.RawContacts.CONTACT_ID) ?: rawId
                val displayName = cursor.safeGetString(ContactsContract.RawContacts.DISPLAY_NAME_PRIMARY) ?: ""
                val accountType = cursor.safeGetString(ContactsContract.RawContacts.ACCOUNT_TYPE)

                Log.d(TAG, "  raw id=$rawId contactId=$contactId name='$displayName' account_type=$accountType")

                val existing = contactMap[contactId]
                if (existing == null) {
                    contactMap[contactId] = ContactBuilder(
                        id = contactId.toString(),
                        displayName = displayName,
                    )
                } else if (existing.displayName.isEmpty() && displayName.isNotEmpty()) {
                    existing.displayName = displayName
                }
            }
        }

        if (contactMap.isEmpty()) {
            Log.d(TAG, "Aucun raw_contact trouvé — liste vide retournée")
            return emptyList()
        }

        // Étape 2 : lire les données (téléphones + noms structurés) pour chaque contact
        val contactIds = contactMap.keys.joinToString(",")

        val dataProjection = arrayOf(
            ContactsContract.Data.CONTACT_ID,
            ContactsContract.Data.MIMETYPE,
            ContactsContract.CommonDataKinds.Phone.NUMBER,
            ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME,
        )
        val dataSelection = (
            "${ContactsContract.Data.CONTACT_ID} IN ($contactIds)" +
            " AND ${ContactsContract.Data.MIMETYPE} IN (?, ?)"
        )
        val dataArgs = arrayOf(
            ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE,
            ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE,
        )

        val dataCursor: Cursor? = cr.query(
            ContactsContract.Data.CONTENT_URI,
            dataProjection,
            dataSelection,
            dataArgs,
            null,
        )

        Log.d(TAG, "data cursor count: ${dataCursor?.count ?: -1}")

        dataCursor?.use { cursor ->
            while (cursor.moveToNext()) {
                val contactId = cursor.safeGetLong(ContactsContract.Data.CONTACT_ID) ?: continue
                val mimeType = cursor.safeGetString(ContactsContract.Data.MIMETYPE) ?: continue
                val builder = contactMap[contactId] ?: continue

                when (mimeType) {
                    ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE -> {
                        val number = cursor.safeGetString(ContactsContract.CommonDataKinds.Phone.NUMBER)
                        if (!number.isNullOrBlank()) {
                            builder.phones.add(number)
                        }
                    }
                    ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE -> {
                        val name = cursor.safeGetString(
                            ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME,
                        )
                        if (!name.isNullOrBlank() && builder.displayName.isEmpty()) {
                            builder.displayName = name
                        }
                    }
                }
            }
        }

        // Étape 3 : convertir en List<Map> triée par nom, filtrer les contacts totalement vides
        val result = contactMap.values
            .filter { it.displayName.isNotEmpty() || it.phones.isNotEmpty() }
            .sortedBy { it.displayName.lowercase() }
            .map { b ->
                mapOf<String, Any>(
                    "id" to b.id,
                    "displayName" to b.displayName,
                    "phones" to b.phones.toList(),
                )
            }

        Log.d(TAG, "Found ${contactMap.size} raw contacts → ${result.size} après filtre")
        return result
    }

    // Évite les index négatifs et les valeurs null des curseurs Android
    private fun Cursor.safeGetString(columnName: String): String? {
        val idx = getColumnIndex(columnName)
        return if (idx >= 0 && !isNull(idx)) getString(idx) else null
    }

    private fun Cursor.safeGetLong(columnName: String): Long? {
        val idx = getColumnIndex(columnName)
        return if (idx >= 0 && !isNull(idx)) getLong(idx) else null
    }

    /** Holder mutable utilisé pendant la construction des contacts. */
    private data class ContactBuilder(
        val id: String,
        var displayName: String,
        val phones: MutableList<String> = mutableListOf(),
    )
}
