import 'package:flutter/material.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

// Données mockées des sessions — remplacées par l'API audio au Sprint 9
const _kSessions = [
  _Session('Sérénité matinale',  '5 min',  Icons.wb_sunny_outlined),
  _Session('Détente profonde',   '10 min', Icons.spa_outlined),
  _Session('Souffle conscient',  '7 min',  Icons.air_outlined),
  _Session('Sommeil paisible',   '15 min', Icons.bedtime_outlined),
  _Session('Pleine présence',    '12 min', Icons.self_improvement),
];

class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _MeditationHeroAppBar(title: l10n.moduleMeditationTitle),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _SessionTile(session: _kSessions[index]),
                childCount: _kSessions.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hero header plein-largeur avec l'image océan
class _MeditationHeroAppBar extends StatelessWidget {
  const _MeditationHeroAppBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.bgBase,
      leading: const BackButton(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/océan calme, lever du soleil.png',
              fit: BoxFit.cover,
            ),
            // gradient pour lisibilité du titre
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0xCC000000),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final _Session session;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accentRose.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(session.icon, color: AppColors.accentRose, size: 22),
        ),
        title: Text(
          session.title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          session.duration,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.accentRose.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow_rounded, color: AppColors.accentRose, size: 20),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${session.title} — Bientôt disponible'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }
}

class _Session {
  const _Session(this.title, this.duration, this.icon);
  final String title;
  final String duration;
  final IconData icon;
}
