// Transcriptions are MOCKED — real STT integration in Sprint 5

enum VoicemailUrgency { low, normal, urgent }

class HarmonyVoicemail {
  const HarmonyVoicemail({
    required this.id,
    required this.callerName,
    required this.callerPhone,
    required this.receivedAt,
    required this.duration,
    required this.transcription,
    required this.shortPreview,
    required this.isRead,
    required this.urgency,
  });

  final String id;
  final String callerName;
  final String callerPhone;
  final DateTime receivedAt;
  final Duration duration;
  final String transcription;
  final String shortPreview;
  final bool isRead;
  final VoicemailUrgency urgency;

  HarmonyVoicemail copyWith({bool? isRead}) => HarmonyVoicemail(
        id: id,
        callerName: callerName,
        callerPhone: callerPhone,
        receivedAt: receivedAt,
        duration: duration,
        transcription: transcription,
        shortPreview: shortPreview,
        isRead: isRead ?? this.isRead,
        urgency: urgency,
      );
}

List<HarmonyVoicemail> kVoicemails() => [
      HarmonyVoicemail(
        id: 'vm_001',
        callerName: 'Alice Dupont',
        callerPhone: '+33 6 12 34 56 78',
        receivedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        duration: const Duration(seconds: 47),
        transcription:
            'Bonjour, c\'est Alice. Je voulais te rappeler que notre réunion est demain à 14h. '
            'N\'oublie pas d\'apporter le rapport trimestriel. À bientôt !',
        shortPreview: 'Réunion demain à 14h...',
        isRead: false,
        urgency: VoicemailUrgency.urgent,
      ),
      HarmonyVoicemail(
        id: 'vm_002',
        callerName: 'Bob Martin',
        callerPhone: '+33 6 98 76 54 32',
        receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
        duration: const Duration(seconds: 23),
        transcription:
            'Salut, c\'est Bob. Je voulais juste savoir si tu avais eu le temps de regarder '
            'le document que je t\'ai envoyé hier. Rappelle-moi quand tu peux.',
        shortPreview: 'As-tu regardé le document ?',
        isRead: false,
        urgency: VoicemailUrgency.normal,
      ),
      HarmonyVoicemail(
        id: 'vm_003',
        callerName: 'Cabinet Médical',
        callerPhone: '+33 1 42 00 11 22',
        receivedAt: DateTime.now().subtract(const Duration(hours: 5)),
        duration: const Duration(seconds: 34),
        transcription:
            'Bonjour, ici le cabinet du Dr. Bernard. Nous vous appelons pour confirmer votre '
            'rendez-vous de demain à 10h30. En cas d\'empêchement, merci de nous prévenir.',
        shortPreview: 'Confirmation RDV Dr. Bernard...',
        isRead: true,
        urgency: VoicemailUrgency.normal,
      ),
      HarmonyVoicemail(
        id: 'vm_004',
        callerName: 'Numéro inconnu',
        callerPhone: '+33 9 87 65 43 21',
        receivedAt: DateTime.now().subtract(const Duration(days: 1)),
        duration: const Duration(seconds: 12),
        transcription:
            'Félicitations ! Vous avez été sélectionné pour gagner un voyage. '
            'Rappellez-nous au plus vite.',
        shortPreview: 'Vous avez été sélectionné...',
        isRead: true,
        urgency: VoicemailUrgency.low,
      ),
    ];
