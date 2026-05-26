# Guide : Activer l'accès aux notifications pour Harmony (Android)

## Pourquoi ce paramètre est nécessaire

Le module Messages de Harmony utilise le `NotificationListenerService` d'Android pour capturer
les notifications de WhatsApp, Signal et Telegram. Ce service est conçu pour des applications
d'accessibilité et nécessite une activation manuelle par l'utilisateur — Android ne permet pas
aux applications de s'accorder automatiquement cet accès.

> **Note iOS** : WhatsApp et Signal ne peuvent pas être interceptés sur iOS en raison du
> sandboxing d'Apple. Seuls les SMS sont filtrables via SMS Filter Extension. Pour limiter
> WhatsApp sur iOS, utilisez **Réglages → Temps d'écran**.

---

## Étapes (Android)

### 1. Ouvrir les paramètres depuis l'app

Depuis l'écran **Messages & SMS** de Harmony, appuyez sur le bouton **"Activer l'accès"**.
Harmony ouvrira automatiquement l'écran système approprié.

### 2. Navigation manuelle (si le bouton ne fonctionne pas)

1. Ouvrez **Paramètres** (⚙️)
2. Appuyez sur **Applications** (ou *Gestion des applications*)
3. Appuyez sur **Accès spécial des applications**
4. Appuyez sur **Accès aux notifications**
5. Trouvez **Harmony** dans la liste
6. Activez le toggle → confirmez en appuyant sur **Autoriser**

### 3. Vérification

Revenez dans Harmony → écran **Messages & SMS** → appuyez sur **Rafraîchir**.
Le statut doit afficher **"Accès aux notifications actif"** avec un indicateur vert.

---

## Données captées

| Source | Données capturées |
|---|---|
| **SMS** | Expéditeur, contenu, horodatage |
| **WhatsApp** | Expéditeur (titre notif), extrait du message |
| **Signal** | Expéditeur, extrait du message |
| **Telegram** | Expéditeur, extrait du message |

> Les messages **privés (chiffrés)** de Signal et WhatsApp affichent parfois uniquement
> "Nouveau message" dans la notification — le contenu réel n'est pas accessible par le listener.

---

## Confidentialité

- Les messages sont stockés **uniquement en mémoire RAM** au Sprint 6 (aucune persistance disque).
- Après redémarrage de l'app, l'historique est effacé.
- La persistance chiffrée (SQLCipher) sera ajoutée au Sprint 7.

---

## Dépannage

| Symptôme | Solution |
|---|---|
| Le statut reste "désactivé" après activation | Forcer l'arrêt de l'app et la rouvrir |
| Les notifications WhatsApp ne s'affichent pas | Vérifier que WhatsApp n'est pas en mode "Économie de batterie" |
| Aucun SMS visible | Vérifier la permission `READ_SMS` dans Paramètres → Applications → Harmony → Permissions |
