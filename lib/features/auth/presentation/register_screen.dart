import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/utils/validation_messages.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_provider.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/password_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final bool ok = await ref.read(authControllerProvider.notifier).register(
          _email.text.trim(),
          _password.text,
          _name.text.trim(),
        );
    if (ok && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool busy = ref.watch(authControllerProvider).isLoading;

    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) _showError(next.error!);
    });

    return AuthScaffold(
      title: l10n.register,
      subtitle: l10n.tagline,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.displayName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  localizeValidation(l10n, Validators.displayName(v)),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.mail_outline),
              ),
              validator: (v) => localizeValidation(l10n, Validators.email(v)),
            ),
            const SizedBox(height: AppSpacing.lg),
            PasswordField(
              controller: _password,
              label: l10n.password,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  localizeValidation(l10n, Validators.password(v)),
            ),
            const SizedBox(height: AppSpacing.lg),
            PasswordField(
              controller: _confirm,
              label: l10n.confirmPassword,
              onSubmitted: busy ? null : _submit,
              validator: (v) => localizeValidation(
                  l10n, Validators.confirmPassword(v, _password.text)),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: busy ? null : _submit,
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.register),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: busy ? null : () => Navigator.of(context).maybePop(),
              child: Text(l10n.haveAccountPrompt),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(Object error) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppException e = ErrorMapper.fromException(error);
    final String msg = switch (e.debugDetail) {
      'email-already-in-use' => l10n.emailInUse,
      'weak-password' => l10n.passwordWeak,
      _ => ErrorMapper.message(l10n, e),
    };
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}
