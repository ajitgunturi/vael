import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/sha256.dart';

/// Supported bank statement formats.
enum BankFormat { hdfc, sbi, icici, generic }

/// A parsed transaction from a bank statement.
class ParsedTransaction {
  final DateTime date;
  final String description;
  final int amount; // paise (always positive)
  final bool isDebit;
  final String? reference;
  final String? inferredCategory;

  const ParsedTransaction({
    required this.date,
    required this.description,
    required this.amount,
    required this.isDebit,
    this.reference,
    this.inferredCategory,
  });
}

/// Result of parsing a bank statement.
class ParseResult {
  final BankFormat format;
  final List<ParsedTransaction> transactions;
  final int skippedRows;

  const ParseResult({
    required this.format,
    required this.transactions,
    required this.skippedRows,
  });
}

/// Bank statement CSV parser with auto-detection.
///
/// Supports HDFC, SBI, ICICI, and generic CSV formats.
/// All amounts are converted to paise (integer minor units).
/// The parser never commits — it returns parsed data for user review.
class StatementParser {
  StatementParser._();

  /// Computes a deduplication hash for an imported transaction.
  ///
  /// Returns `SHA256(familyId + accountId + date + amount + description)`
  /// as a hex string. Used to detect duplicates across repeated imports.
  static String computeDedupHash(
    String familyId,
    String accountId,
    ParsedTransaction txn,
  ) {
    final input =
        '$familyId$accountId${txn.date.toIso8601String()}${txn.amount}${txn.description}';
    final digest = SHA256Digest();
    final bytes = digest.process(Uint8List.fromList(utf8.encode(input)));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Detects bank format from CSV header row.
  static BankFormat detectFormat(String csv) {
    final firstLine = csv.split('\n').first.trim();
    final lower = firstLine.toLowerCase();

    if (lower.contains('narration') && lower.contains('value dat')) {
      return BankFormat.hdfc;
    }
    if (lower.contains('txn date') && lower.contains('ref no')) {
      return BankFormat.sbi;
    }
    if (lower.contains('transaction date') &&
        lower.contains('transaction remarks')) {
      return BankFormat.icici;
    }
    return BankFormat.generic;
  }

  /// Parses a CSV string into transactions. Auto-detects format.
  static ParseResult parse(String csv) {
    final trimmed = csv.trim();
    if (trimmed.isEmpty) {
      return const ParseResult(
        format: BankFormat.generic,
        transactions: [],
        skippedRows: 0,
      );
    }

    final format = detectFormat(trimmed);
    final lines = trimmed.split('\n');
    if (lines.length < 2) {
      return ParseResult(format: format, transactions: [], skippedRows: 0);
    }

    // Skip header
    final dataLines = lines.sublist(1);

    switch (format) {
      case BankFormat.hdfc:
        return _parseHdfc(dataLines, format);
      case BankFormat.sbi:
        return _parseSbi(dataLines, format);
      case BankFormat.icici:
        return _parseIcici(dataLines, format);
      case BankFormat.generic:
        return _parseGeneric(dataLines, format);
    }
  }

  static ParseResult _parseHdfc(List<String> lines, BankFormat format) {
    final txns = <ParsedTransaction>[];
    int skipped = 0;

    for (final line in lines) {
      try {
        final cols = _splitCsv(line);
        if (cols.length < 7) {
          skipped++;
          continue;
        }

        final date = _parseDateDMY(cols[0].trim(), '/');
        final narration = cols[1].trim();
        final debitStr = cols[3].trim();
        final creditStr = cols[4].trim();
        final ref = cols[5].trim();

        final isDebit = debitStr.isNotEmpty;
        final amountStr = isDebit ? debitStr : creditStr;
        final amount = _parseAmount(amountStr);

        txns.add(
          ParsedTransaction(
            date: date,
            description: narration,
            amount: amount,
            isDebit: isDebit,
            reference: ref.isNotEmpty ? ref : null,
            inferredCategory: inferCategory(narration),
          ),
        );
      } catch (_) {
        skipped++;
      }
    }

    return ParseResult(
      format: format,
      transactions: txns,
      skippedRows: skipped,
    );
  }

  static ParseResult _parseSbi(List<String> lines, BankFormat format) {
    final txns = <ParsedTransaction>[];
    int skipped = 0;

    for (final line in lines) {
      try {
        final cols = _splitCsv(line);
        if (cols.length < 7) {
          skipped++;
          continue;
        }

        final date = _parseDateDMY(cols[0].trim(), '/');
        final description = cols[2].trim();
        final ref = cols[3].trim();
        final debitStr = cols[4].trim();
        final creditStr = cols[5].trim();

        final isDebit = debitStr.isNotEmpty;
        final amountStr = isDebit ? debitStr : creditStr;
        final amount = _parseAmount(amountStr);

        txns.add(
          ParsedTransaction(
            date: date,
            description: description,
            amount: amount,
            isDebit: isDebit,
            reference: ref.isNotEmpty ? ref : null,
            inferredCategory: inferCategory(description),
          ),
        );
      } catch (_) {
        skipped++;
      }
    }

    return ParseResult(
      format: format,
      transactions: txns,
      skippedRows: skipped,
    );
  }

  static ParseResult _parseIcici(List<String> lines, BankFormat format) {
    final txns = <ParsedTransaction>[];
    int skipped = 0;

    for (final line in lines) {
      try {
        final cols = _splitCsv(line);
        if (cols.length < 7) {
          skipped++;
          continue;
        }

        final date = _parseDateDMY(cols[0].trim(), '-');
        final remarks = cols[2].trim();
        final ref = cols[3].trim();
        final debitStr = cols[4].trim();
        final creditStr = cols[5].trim();

        final isDebit = debitStr.isNotEmpty;
        final amountStr = isDebit ? debitStr : creditStr;
        final amount = _parseAmount(amountStr);

        txns.add(
          ParsedTransaction(
            date: date,
            description: remarks,
            amount: amount,
            isDebit: isDebit,
            reference: ref.isNotEmpty ? ref : null,
            inferredCategory: inferCategory(remarks),
          ),
        );
      } catch (_) {
        skipped++;
      }
    }

    return ParseResult(
      format: format,
      transactions: txns,
      skippedRows: skipped,
    );
  }

  static ParseResult _parseGeneric(List<String> lines, BankFormat format) {
    final txns = <ParsedTransaction>[];
    int skipped = 0;

    for (final line in lines) {
      try {
        final cols = _splitCsv(line);
        if (cols.length < 3) {
          skipped++;
          continue;
        }

        final date = DateTime.parse(cols[0].trim());
        final description = cols[1].trim();
        final amountRaw = double.parse(cols[2].trim());
        final isDebit = amountRaw < 0;
        final amount = (amountRaw.abs() * 100).round();

        txns.add(
          ParsedTransaction(
            date: date,
            description: description,
            amount: amount,
            isDebit: isDebit,
            inferredCategory: inferCategory(description),
          ),
        );
      } catch (_) {
        skipped++;
      }
    }

    return ParseResult(
      format: format,
      transactions: txns,
      skippedRows: skipped,
    );
  }

  // --- Helpers ---

  /// Parses DD/MM/YYYY or DD-MM-YYYY dates.
  static DateTime _parseDateDMY(String s, String separator) {
    final parts = s.split(separator);
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  /// Parses an amount string like "1,50,000.50" to paise (int).
  static int _parseAmount(String s) {
    final cleaned = s.replaceAll(',', '').trim();
    return (double.parse(cleaned) * 100).round();
  }

  /// Splits a CSV line handling basic quoting.
  static List<String> _splitCsv(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(ch);
      }
    }
    result.add(current.toString());
    return result;
  }

  /// Infers a category from transaction description keywords.
  ///
  /// Returns null if no match found. This is a best-effort hint —
  /// the user always has final say during review.
  static String? inferCategory(String description) {
    final upper = description.toUpperCase();

    // Category keywords ordered by specificity
    if (upper.contains('SALARY') || upper.contains('PAYROLL')) return 'Salary';
    if (upper.contains('EMI')) return 'EMI';
    if (upper.contains('GROCERY') ||
        upper.contains('BIGBASKET') ||
        upper.contains('DMART') ||
        upper.contains('MORE ')) {
      return 'Groceries';
    }
    if (upper.contains('SWIGGY') ||
        upper.contains('ZOMATO') ||
        upper.contains('FOOD') ||
        upper.contains('RESTAURANT')) {
      return 'Food & Dining';
    }
    if (upper.contains('UBER') ||
        upper.contains('OLA') ||
        upper.contains('METRO') ||
        upper.contains('FUEL') ||
        upper.contains('PETROL')) {
      return 'Transport';
    }
    if (upper.contains('RENT')) return 'Rent';
    if (upper.contains('ELECTRICITY') ||
        upper.contains('WATER') ||
        upper.contains('GAS BILL') ||
        upper.contains('BROADBAND')) {
      return 'Utilities';
    }
    if (upper.contains('AMAZON') ||
        upper.contains('FLIPKART') ||
        upper.contains('MYNTRA')) {
      return 'Shopping';
    }
    if (upper.contains('INSURANCE') ||
        upper.contains('LIC') ||
        upper.contains('PREMIUM')) {
      return 'Insurance';
    }
    if (upper.contains('SIP') ||
        upper.contains('MUTUAL FUND') ||
        upper.contains('MF ')) {
      return 'Investments';
    }
    if (upper.contains('NETFLIX') ||
        upper.contains('HOTSTAR') ||
        upper.contains('SPOTIFY') ||
        upper.contains('PRIME')) {
      return 'Entertainment';
    }
    if (upper.contains('HOSPITAL') ||
        upper.contains('PHARMACY') ||
        upper.contains('DOCTOR') ||
        upper.contains('MEDICAL')) {
      return 'Healthcare';
    }
    if (upper.contains('SCHOOL') ||
        upper.contains('COLLEGE') ||
        upper.contains('TUITION') ||
        upper.contains('COURSE')) {
      return 'Education';
    }

    return null;
  }
}
