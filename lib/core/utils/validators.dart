import '../config/app_config.dart';

/// Pure validation helpers returning a stable error *key* (not a localized
/// string) so the presentation layer can localize. Returns null when valid.
class Validators {
  const Validators._();

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? email(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'emailRequired';
    if (v.length > AppConfig.maxEmailChars) return 'emailTooLong';
    if (!_emailRegex.hasMatch(v)) return 'emailInvalid';
    return null;
  }

  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'passwordRequired';
    if (v.length < AppConfig.minPasswordChars) return 'passwordTooShort';
    if (v.length > AppConfig.maxPasswordChars) return 'passwordTooLong';
    final bool hasLetter = v.contains(RegExp(r'[A-Za-z]'));
    final bool hasDigit = v.contains(RegExp(r'\d'));
    if (!hasLetter || !hasDigit) return 'passwordWeak';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '') != original) return 'passwordMismatch';
    return null;
  }

  static String? displayName(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'nameRequired';
    if (v.length > AppConfig.maxDisplayNameChars) return 'nameTooLong';
    return null;
  }

  static String? message(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'messageEmpty';
    if (v.length > AppConfig.maxInputChars) return 'messageTooLong';
    return null;
  }
}
