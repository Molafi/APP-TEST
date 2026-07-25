import '../../l10n/app_localizations.dart';

/// Maps stable validation keys (from [Validators]) to localized messages so
/// validation logic stays pure and UI-agnostic.
String? localizeValidation(AppLocalizations l10n, String? key) {
  if (key == null) return null;
  switch (key) {
    case 'emailRequired':
      return l10n.emailRequired;
    case 'emailInvalid':
      return l10n.emailInvalid;
    case 'emailTooLong':
      return l10n.emailTooLong;
    case 'passwordRequired':
      return l10n.passwordRequired;
    case 'passwordTooShort':
      return l10n.passwordTooShort;
    case 'passwordTooLong':
      return l10n.passwordTooLong;
    case 'passwordWeak':
      return l10n.passwordWeak;
    case 'passwordMismatch':
      return l10n.passwordMismatch;
    case 'nameRequired':
      return l10n.nameRequired;
    case 'nameTooLong':
      return l10n.nameTooLong;
    case 'messageEmpty':
    case 'messageTooLong':
      return l10n.errorInvalidInput;
    default:
      return l10n.errorInvalidInput;
  }
}
