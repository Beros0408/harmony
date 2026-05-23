import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';

class CallFilterScreen extends StatelessWidget {
  const CallFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filtrage d\'appels')),
      body: Center(
        child: Text(
          'À implémenter au Sprint 2',
          style: AppTypography.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
