import 'package:flutter_test/flutter_test.dart';
import 'package:train_wake/features/auth/domain/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    // -----------------------------------------------------------------------
    // Invalid passwords
    // -----------------------------------------------------------------------
    test('empty password fails', () {
      expect(PasswordValidator.validate(''), isNotNull);
      expect(PasswordValidator.isValid(''), isFalse);
    });

    test('null password fails', () {
      expect(PasswordValidator.validate(null), isNotNull);
      expect(PasswordValidator.isValid(''), isFalse);
    });

    test('fewer than 8 characters fails', () {
      expect(PasswordValidator.validate('Ab1!'), isNotNull);
      expect(PasswordValidator.isValid('Ab1!'), isFalse);
    });

    test('no uppercase letter fails', () {
      expect(PasswordValidator.validate('abcd1234!'), isNotNull);
      expect(PasswordValidator.isValid('abcd1234!'), isFalse);
    });

    test('no lowercase letter fails', () {
      expect(PasswordValidator.validate('ABCD1234!'), isNotNull);
      expect(PasswordValidator.isValid('ABCD1234!'), isFalse);
    });

    test('no number fails', () {
      expect(PasswordValidator.validate('Abcdefgh!'), isNotNull);
      expect(PasswordValidator.isValid('Abcdefgh!'), isFalse);
    });

    test('no special character fails', () {
      expect(PasswordValidator.validate('Password1'), isNotNull);
      expect(PasswordValidator.isValid('Password1'), isFalse);
    });

    test('plain password fails (no uppercase, no number, no special)', () {
      expect(PasswordValidator.validate('password'), isNotNull);
    });

    test('Password without number and special fails', () {
      expect(PasswordValidator.validate('Password'), isNotNull);
    });

    // -----------------------------------------------------------------------
    // Valid passwords
    // -----------------------------------------------------------------------
    test('TrainWake123! is valid', () {
      expect(PasswordValidator.validate('TrainWake123!'), isNull);
      expect(PasswordValidator.isValid('TrainWake123!'), isTrue);
    });

    test('Secure@Pass1 is valid', () {
      expect(PasswordValidator.validate('Secure@Pass1'), isNull);
      expect(PasswordValidator.isValid('Secure@Pass1'), isTrue);
    });

    test('Abcdef1! is valid (exactly 8 chars)', () {
      expect(PasswordValidator.validate('Abcdef1!'), isNull);
      expect(PasswordValidator.isValid('Abcdef1!'), isTrue);
    });

    // -----------------------------------------------------------------------
    // Requirements breakdown
    // -----------------------------------------------------------------------
    test('requirements: empty password has all unmet', () {
      final reqs = PasswordValidator.requirements('');
      expect(reqs.every((r) => !r.met), isTrue);
    });

    test('requirements: TrainWake123! has all met', () {
      final reqs = PasswordValidator.requirements('TrainWake123!');
      expect(reqs.every((r) => r.met), isTrue);
    });

    test('requirements: returns exactly 5 items', () {
      expect(PasswordValidator.requirements('anything').length, equals(5));
    });

    test('requirements: length requirement met only when >= 8 chars', () {
      final short = PasswordValidator.requirements('Ab1!');
      final long = PasswordValidator.requirements('Ab1!xxxx');
      expect(short.first.met, isFalse);
      expect(long.first.met, isTrue);
    });

    // -----------------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------------
    test('all special chars variant is valid', () {
      expect(PasswordValidator.isValid('Pass1!@#\$'), isTrue);
    });

    test('7-char near-valid password fails length check', () {
      expect(PasswordValidator.isValid('Abc1!zz'), isFalse);
    });
  });
}
