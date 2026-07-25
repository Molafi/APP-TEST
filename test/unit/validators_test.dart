import 'package:flutter_test/flutter_test.dart';
import 'package:plantsense_ai/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty', () => expect(Validators.email(''), 'emailRequired'));
    test('rejects malformed',
        () => expect(Validators.email('not-an-email'), 'emailInvalid'));
    test('accepts valid',
        () => expect(Validators.email('a@b.co'), isNull));
  });

  group('Validators.password', () {
    test('rejects empty',
        () => expect(Validators.password(''), 'passwordRequired'));
    test('rejects short',
        () => expect(Validators.password('a1'), 'passwordTooShort'));
    test('rejects letters-only',
        () => expect(Validators.password('abcdefgh'), 'passwordWeak'));
    test('accepts strong',
        () => expect(Validators.password('abcd1234'), isNull));
  });

  group('Validators.confirmPassword', () {
    test('mismatch',
        () => expect(Validators.confirmPassword('a', 'b'), 'passwordMismatch'));
    test('match', () => expect(Validators.confirmPassword('a', 'a'), isNull));
  });

  group('Validators.displayName', () {
    test('required',
        () => expect(Validators.displayName('  '), 'nameRequired'));
    test('accepts', () => expect(Validators.displayName('Sam'), isNull));
  });

  group('Validators.message', () {
    test('empty', () => expect(Validators.message('   '), 'messageEmpty'));
    test('accepts', () => expect(Validators.message('hello'), isNull));
  });
}
