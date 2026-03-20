import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/models/money.dart';

void main() {
  group('Money — construction', () {
    test('should_store_paise_directly', () {
      final money = Money(1000);
      expect(money.paise, 1000); // 10.00 rupees
    });

    test('should_create_from_major_units_with_minor', () {
      final money = Money.fromMajor(10, 50);
      expect(money.paise, 1050);
    });

    test('should_create_from_major_units_without_minor', () {
      final money = Money.fromMajor(1);
      expect(money.paise, 100);
    });

    test('should_create_zero', () {
      expect(Money.zero.paise, 0);
    });

    test('zero_should_be_const', () {
      expect(identical(Money.zero, const Money(0)), isTrue);
    });
  });

  group('Money — arithmetic', () {
    test('should_add_two_money_values', () {
      final a = Money(500);
      final b = Money(300);
      expect((a + b).paise, 800);
    });

    test('should_subtract_two_money_values', () {
      final a = Money(500);
      final b = Money(300);
      expect((a - b).paise, 200);
    });

    test('should_negate', () {
      final m = Money(500);
      expect((-m).paise, -500);
    });

    test('addition_should_return_new_instance', () {
      final a = Money(500);
      final b = Money(300);
      final c = a + b;
      expect(a.paise, 500); // unchanged
      expect(b.paise, 300); // unchanged
      expect(c.paise, 800);
    });

    test('subtraction_should_return_new_instance', () {
      final a = Money(500);
      final b = Money(300);
      final c = a - b;
      expect(a.paise, 500);
      expect(c.paise, 200);
    });
  });

  group('Money — Indian lakh formatting', () {
    test('should_format_simple_amount', () {
      expect(Money(1000).formatted, '₹10.00');
    });

    test('should_format_zero_paise', () {
      expect(Money(0).formatted, '₹0.00');
    });

    test('should_format_paise_only', () {
      expect(Money(50).formatted, '₹0.50');
    });

    test('should_format_one_lakh', () {
      // 1,00,000 rupees = 10000000 paise
      expect(Money(10000000).formatted, '₹1,00,000.00');
    });

    test('should_format_hundred_crore', () {
      // 100 crore = 1,00,00,00,000 rupees = 1000000000 rupees = 100000000000 paise
      expect(Money(100000000000).formatted, '₹1,00,00,00,000.00');
    });

    test('should_format_with_paise', () {
      expect(Money(150075).formatted, '₹1,500.75');
    });

    test('should_format_negative_amount', () {
      expect(Money(-150075).formatted, '-₹1,500.75');
    });

    test('should_format_one_rupee', () {
      expect(Money(100).formatted, '₹1.00');
    });

    test('should_format_thousands', () {
      expect(Money(999900).formatted, '₹9,999.00');
    });

    test('should_format_ten_thousand', () {
      expect(Money(1000000).formatted, '₹10,000.00');
    });
  });

  group('Money — comparisons', () {
    test('should_compare_greater_than', () {
      expect(Money(500) > Money(300), isTrue);
      expect(Money(300) > Money(500), isFalse);
    });

    test('should_compare_less_than', () {
      expect(Money(300) < Money(500), isTrue);
      expect(Money(500) < Money(300), isFalse);
    });

    test('should_compare_equal', () {
      expect(Money(500) == Money(500), isTrue);
      expect(Money(500) == Money(300), isFalse);
    });

    test('should_compare_greater_than_or_equal', () {
      expect(Money(500) >= Money(500), isTrue);
      expect(Money(500) >= Money(300), isTrue);
      expect(Money(300) >= Money(500), isFalse);
    });

    test('should_compare_less_than_or_equal', () {
      expect(Money(500) <= Money(500), isTrue);
      expect(Money(300) <= Money(500), isTrue);
      expect(Money(500) <= Money(300), isFalse);
    });
  });

  group('Money — predicates', () {
    test('isZero_should_return_true_for_zero', () {
      expect(Money.zero.isZero, isTrue);
      expect(Money(0).isZero, isTrue);
      expect(Money(1).isZero, isFalse);
    });

    test('isPositive_should_return_true_for_positive', () {
      expect(Money(500).isPositive, isTrue);
      expect(Money(0).isPositive, isFalse);
      expect(Money(-500).isPositive, isFalse);
    });

    test('isNegative_should_return_true_for_negative', () {
      expect(Money(-500).isNegative, isTrue);
      expect(Money(0).isNegative, isFalse);
      expect(Money(500).isNegative, isFalse);
    });
  });

  group('Money — equality and hashCode', () {
    test('should_be_equal_for_same_paise', () {
      expect(Money(500), equals(Money(500)));
    });

    test('should_have_same_hashCode_for_equal_values', () {
      expect(Money(500).hashCode, Money(500).hashCode);
    });

    test('should_not_equal_different_paise', () {
      expect(Money(500), isNot(equals(Money(300))));
    });
  });

  group('Money — toString', () {
    test('should_return_debug_string', () {
      expect(Money(1050).toString(), 'Money(1050)');
    });
  });
}
