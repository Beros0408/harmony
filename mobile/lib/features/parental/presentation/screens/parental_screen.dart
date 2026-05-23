import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';

class ParentalScreen extends StatelessWidget {
  const ParentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contrôle parental')),
      body: Center(
        child: Text(
          'À implémenter au Sprint 3',
          style: AppTypography.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
