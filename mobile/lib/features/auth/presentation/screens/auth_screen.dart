import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/biometric_button.dart';
import '../widgets/pin_dots.dart';
import '../widgets/pin_pad.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.dashboard);
        }
      },
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            backgroundColor: AppColors.bgBase,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthPinSetup) {
          return const _PinSetupFlow();
        }
        if (state is AuthBiometricSetup) {
          return const _BiometricSetupScreen();
        }
        if (state is AuthPinEntry) {
          return _PinEntryScreen(
            biometricAvailable: state.biometricAvailable,
            biometricEnabled: state.biometricEnabled,
          );
        }
        if (state is AuthPinError) {
          return _PinEntryScreen(
            biometricAvailable: false,
            biometricEnabled: false,
            errorAttemptsLeft: state.attemptsLeft,
          );
        }
        if (state is AuthError) {
          return Scaffold(
            backgroundColor: AppColors.bgBase,
            body: Center(
              child: Text(
                state.message,
                style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.accentRed),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Flux de création de PIN en deux étapes (saisie + confirmation)
// ---------------------------------------------------------------------------

class _PinSetupFlow extends StatefulWidget {
  const _PinSetupFlow();

  @override
  State<_PinSetupFlow> createState() => _PinSetupFlowState();
}

class _PinSetupFlowState extends State<_PinSetupFlow> {
  String _firstPin = '';
  String _currentInput = '';
  bool _confirming = false;
  bool _mismatch = false;

  void _onDigit(String digit) {
    if (_currentInput.length >= 4) return;
    setState(() {
      _mismatch = false;
      _currentInput += digit;
    });
    if (_currentInput.length == 4) _onComplete();
  }

  void _onDelete() {
    if (_currentInput.isEmpty) return;
    setState(() => _currentInput = _currentInput.substring(0, _currentInput.length - 1));
  }

  void _onComplete() {
    if (!_confirming) {
      setState(() {
        _firstPin = _currentInput;
        _currentInput = '';
        _confirming = true;
      });
    } else {
      if (_currentInput == _firstPin) {
        context.read<AuthBloc>().add(AuthPinSetupRequested(_currentInput));
      } else {
        setState(() {
          _mismatch = true;
          _currentInput = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.accentBlue, size: 48),
              const SizedBox(height: AppSpacing.xl),
              Text(
                _confirming ? l10n.authConfirmPinTitle : l10n.authCreatePinTitle,
                style: AppTypography.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _mismatch
                    ? l10n.authPinMismatch
                    : _confirming
                        ? l10n.authReenterPin
                        : l10n.authChoosePin,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: _mismatch ? AppColors.accentRed : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              PinDots(filled: _currentInput.length, hasError: _mismatch),
              const SizedBox(height: AppSpacing.xxxl),
              PinPad(onDigit: _onDigit, onDelete: _onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Écran de saisie du PIN (authentification normale)
// ---------------------------------------------------------------------------

class _PinEntryScreen extends StatefulWidget {
  const _PinEntryScreen({
    required this.biometricAvailable,
    required this.biometricEnabled,
    this.errorAttemptsLeft,
  });

  final bool biometricAvailable;
  final bool biometricEnabled;
  final int? errorAttemptsLeft;

  @override
  State<_PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends State<_PinEntryScreen> {
  String _input = '';

  void _onDigit(String digit) {
    if (_input.length >= 4) return;
    setState(() => _input += digit);
    if (_input.length == 4) {
      context.read<AuthBloc>().add(AuthPinSubmitted(_input));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _input = '');
      });
    }
  }

  void _onDelete() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showBiometric = widget.biometricAvailable && widget.biometricEnabled;
    final hasError = widget.errorAttemptsLeft != null;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: AppColors.accentBlue, size: 48),
              const SizedBox(height: AppSpacing.xl),
              Text(l10n.authWelcomeTitle, style: AppTypography.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                hasError
                    ? '${l10n.authIncorrectCode} · ${l10n.authAttemptsLeft(widget.errorAttemptsLeft!)}'
                    : l10n.authEnterPin,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: hasError ? AppColors.accentRed : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              PinDots(filled: _input.length, hasError: hasError),
              const SizedBox(height: AppSpacing.xxxl),
              PinPad(
                onDigit: _onDigit,
                onDelete: _onDelete,
                extraAction: showBiometric
                    ? BiometricButton(
                        onTap: () => context.read<AuthBloc>().add(const AuthBiometricRequested()),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Proposition d'activation de la biométrie après configuration du PIN
// ---------------------------------------------------------------------------

class _BiometricSetupScreen extends StatelessWidget {
  const _BiometricSetupScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint, color: AppColors.accentBlue, size: 72),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.authBiometricSetupTitle,
                  style: AppTypography.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.authBiometricSetupDesc,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthBiometricToggled(enabled: true)),
                    child: Text(l10n.authBiometricEnable),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context
                        .read<AuthBloc>()
                        .add(const AuthBiometricToggled(enabled: false)),
                    child: Text(l10n.authBiometricLater),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
