import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: Center(
        child: Text(
          'À implémenter au Sprint 4',
          style: AppTypography.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
