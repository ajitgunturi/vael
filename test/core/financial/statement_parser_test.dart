import 'package:flutter_test/flutter_test.dart';
import 'package:vael/core/financial/statement_parser.dart';

void main() {
  group('StatementParser', () {
    group('format detection', () {
      test('should detect HDFC format', () {
        const csv =
            '''Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance
01/01/2026,UPI-SWIGGY,01/01/2026,450.00,,123456,50000.00
02/01/2026,NEFT-SALARY,02/01/2026,,150000.00,789012,200000.00''';

        expect(StatementParser.detectFormat(csv), BankFormat.hdfc);
      });

      test('should detect SBI format', () {
        const csv =
            '''Txn Date,Value Date,Description,Ref No./Cheque No.,Debit,Credit,Balance
01/01/2026,01/01/2026,UPI/SWIGGY,123456,450.00,,50000.00
02/01/2026,02/01/2026,NEFT/SALARY,789012,,150000.00,200000.00''';

        expect(StatementParser.detectFormat(csv), BankFormat.sbi);
      });

      test('should detect ICICI format', () {
        const csv =
            '''Transaction Date,Value Date,Transaction Remarks,Cheque Number,Debit Amount,Credit Amount,Balance (INR)
01-01-2026,01-01-2026,UPI/SWIGGY,123456,450.00,,50000.00''';

        expect(StatementParser.detectFormat(csv), BankFormat.icici);
      });

      test('should fall back to generic for unknown format', () {
        const csv = '''date,description,amount,type
2026-01-01,Groceries,-450.00,debit''';

        expect(StatementParser.detectFormat(csv), BankFormat.generic);
      });
    });

    group('HDFC parser', () {
      test('should parse debit transactions', () {
        const csv =
            '''Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance
01/01/2026,UPI-SWIGGY-FOOD,01/01/2026,450.50,,REF123,49549.50''';

        final result = StatementParser.parse(csv);

        expect(result.transactions.length, 1);
        expect(result.transactions[0].date, DateTime(2026, 1, 1));
        expect(result.transactions[0].description, 'UPI-SWIGGY-FOOD');
        expect(result.transactions[0].amount, 45050); // paise
        expect(result.transactions[0].isDebit, true);
      });

      test('should parse credit transactions', () {
        const csv =
            '''Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance
02/01/2026,NEFT-SALARY-JAN,02/01/2026,,150000.00,REF456,200000.00''';

        final result = StatementParser.parse(csv);

        expect(result.transactions[0].amount, 15000000);
        expect(result.transactions[0].isDebit, false);
      });

      test('should parse multiple rows', () {
        const csv =
            '''Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance
01/01/2026,UPI-SWIGGY,01/01/2026,450.00,,REF1,49550.00
02/01/2026,NEFT-SALARY,02/01/2026,,150000.00,REF2,199550.00
03/01/2026,EMI-HOME LOAN,03/01/2026,35000.00,,REF3,164550.00''';

        final result = StatementParser.parse(csv);
        expect(result.transactions.length, 3);
      });
    });

    group('SBI parser', () {
      test('should parse SBI format', () {
        const csv =
            '''Txn Date,Value Date,Description,Ref No./Cheque No.,Debit,Credit,Balance
15/01/2026,15/01/2026,UPI/AMAZON/SHOPPING,654321,2500.00,,47500.00''';

        final result = StatementParser.parse(csv);

        expect(result.format, BankFormat.sbi);
        expect(result.transactions.length, 1);
        expect(result.transactions[0].description, 'UPI/AMAZON/SHOPPING');
        expect(result.transactions[0].amount, 250000);
        expect(result.transactions[0].isDebit, true);
      });
    });

    group('ICICI parser', () {
      test('should parse ICICI format with dash date', () {
        const csv =
            '''Transaction Date,Value Date,Transaction Remarks,Cheque Number,Debit Amount,Credit Amount,Balance (INR)
01-01-2026,01-01-2026,UPI/BIGBASKET,111222,800.00,,49200.00''';

        final result = StatementParser.parse(csv);

        expect(result.format, BankFormat.icici);
        expect(result.transactions.length, 1);
        expect(result.transactions[0].amount, 80000);
      });
    });

    group('generic CSV parser', () {
      test('should parse generic format with amount column', () {
        const csv = '''date,description,amount
2026-01-01,Groceries,-450.00
2026-01-05,Salary,150000.00''';

        final result = StatementParser.parse(csv);

        expect(result.format, BankFormat.generic);
        expect(result.transactions.length, 2);
        expect(result.transactions[0].isDebit, true);
        expect(result.transactions[0].amount, 45000);
        expect(result.transactions[1].isDebit, false);
        expect(result.transactions[1].amount, 15000000);
      });
    });

    group('error handling', () {
      test('should skip malformed rows and report errors', () {
        const csv =
            '''Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance
01/01/2026,Valid Row,01/01/2026,100.00,,REF1,49900.00
INVALID,Bad Row
03/01/2026,Another Valid,03/01/2026,200.00,,REF2,49700.00''';

        final result = StatementParser.parse(csv);

        expect(result.transactions.length, 2);
        expect(result.skippedRows, 1);
      });

      test('should handle empty CSV', () {
        const csv = '';
        final result = StatementParser.parse(csv);

        expect(result.transactions, isEmpty);
      });

      test('should handle header-only CSV', () {
        const csv =
            'Date,Narration,Value Dat,Debit Amount,Credit Amount,Chq/Ref Number,Closing Balance';
        final result = StatementParser.parse(csv);

        expect(result.transactions, isEmpty);
      });
    });

    group('category inference', () {
      test('should infer category from common keywords', () {
        expect(
          StatementParser.inferCategory('UPI-SWIGGY-FOOD-ORDER'),
          'Food & Dining',
        );
        expect(StatementParser.inferCategory('NEFT-SALARY-JAN2026'), 'Salary');
        expect(StatementParser.inferCategory('EMI-HOME LOAN-HDFC'), 'EMI');
        expect(
          StatementParser.inferCategory('UPI-BIGBASKET-GROCERY'),
          'Groceries',
        );
      });

      test('should return null for unrecognized descriptions', () {
        expect(StatementParser.inferCategory('MISC PAYMENT REF12345'), isNull);
      });
    });
  });
}
