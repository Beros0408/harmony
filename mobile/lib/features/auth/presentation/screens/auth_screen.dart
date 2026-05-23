import 'package:flutter/material.dart';
import '../../../../core/constants/app_typography.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentification')),
      body: Center(
        child: Text(
          'À implémenter au Sprint 1',
          style: AppTypography.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
