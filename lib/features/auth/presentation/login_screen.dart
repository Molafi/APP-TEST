import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/validation_messages.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_provider.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/password_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .signIn(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<void> state = ref.watch(authControllerProvider);
    final bool busy = state.isLoading;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        _showError(next.error!);
      }
    });

    return AuthScaffold(
      title: l10n.appTitle,
      subtitle: l10n.tagline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.mail_outline),
              ),
              validator: (v) =>
                  localizeValidation(l10n, Validators.email(v)),
            ),
            const SizedBox(height: AppSpacing.lg),
            PasswordField(
              controller: _password,
              label: l10n.password,
              onSubmitted: busy ? null : _submit,
              validator: (v) =>
                  localizeValidation(l10n, Validators.password(v)),
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: busy
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        )),
                child: Text(l10n.forgotPassword),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: busy ? null : _submit,
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.login),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: busy
                  ? null
                  : () =>
                      ref.read(authControllerProvider.notifier).signInWithGoogle(),
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(l10n.continueWithGoogle),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: busy
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      )),
              child: Text(l10n.noAccountPrompt),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(Object error) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppException e = ErrorMapper.fromException(error);
    // Special-case a couple of auth details for friendlier copy.
    final String msg = switch (e.debugDetail) {
      'email-already-in-use' => l10n.emailInUse,
      'user-disabled' => l10n.userDisabled,
      _ => ErrorMapper.message(l10n, e),
    };
    if (e.debugDetail == 'google sign-in cancelled') return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}
