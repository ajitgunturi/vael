import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/digests/sha256.dart';

/// Returns an opaque database filename (SHA-256 hash + `.db`).
///
/// The filename deliberately reveals nothing about the app's domain
/// (no "finance", "budget", etc.) — per the project's privacy rule that
/// storage paths must not leak financial semantics.
String databaseFileName() {
  final bytes = Uint8List.fromList(utf8.encode('vael_family_finance'));
  final digest = SHA256Digest().process(bytes);
  final hex = digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '$hex.db';
}

/// Returns the full [File] path for the production database.
///
/// Uses `getApplicationSupportDirectory()` which persists across app restarts
/// and is not user-visible on iOS/Android.
Future<File> databaseFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/${databaseFileName()}');
}
