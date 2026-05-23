import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness')),
      body: Center(
        child: Text(
          'À implémenter au Sprint 5',
          style: AppTypography.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
