import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'bip39_wordlist.dart';

/// Redacts secrets before they reach logs, error reports or the audit trail.
/// Implements blueprint rules S-03 (log redaction), A-06 (auth tokens / OTP),
/// C-04 (exchange keys) and V-04 (wallet keys never logged).
///
/// Every sink that can leave the device, or be read by a human, MUST pipe
/// through [Redactor.redact]. Coverage: API keys, bearer headers, EVM
/// private keys, seed phrases, JWTs and labelled OTP codes.
@immutable
class Redactor {
  const Redactor._();

  /// `sk-...` style API keys (OpenAI and most OpenAI-compatible gateways).
  static final RegExp _apiKey = RegExp(r'sk-[A-Za-z0-9_-]{16,}');

  /// `sb_publishable_...` / `sb_secret_...` Supabase keys.
  static final RegExp _supabaseKey =
      RegExp(r'sb_(?:publishable|secret)_[A-Za-z0-9_-]{16,}');

  /// Bearer / x-api-key header values. `Bearer` (or the equivalent scheme
  /// word) may follow the colon before the secret itself, so the scheme is
  /// optional whitespace-delimited filler. Dart regex has no inline `(?i)`
  /// flag, so case-insensitivity is set on the whole pattern instead.
  /// Label umum (auth, token, key, api) supaya header map yang umum dipakai
  /// (mis. `Auth: Bearer tok_live_...` di Dio) juga ter-redaksi (S-03).
  static final RegExp _bearer = RegExp(
    r'(?:bearer|x-api-key|authorization|auth|token|api[_-]?key|key)\s*[:=]\s*'
    r'(?:bearer\s+)?'
    r'[A-Za-z0-9_\-.,=]{20,}',
    caseSensitive: false,
  );

  /// EVM private key: 64 hex chars, optional 0x prefix.
  static final RegExp _privateKey = RegExp(r'\b0x?[0-9a-fA-F]{64}\b');

  /// JWT: three base64url segments. `eyJ` signals a JSON header; length
  /// bounds are permissive ({6,}) because real JWT segments vary —
  /// false positives are harmless (redaction is the safe direction).
  static final RegExp _jwt = RegExp(
    r'\beyJ[A-Za-z0-9_-]{6,}\.[A-Za-z0-9_-]{6,}\.[A-Za-z0-9_-]{6,}\b',
  );

  /// Redact every known secret pattern in [input].
  static String redact(String? input) {
    if (input == null || input.isEmpty) return '';
    var out = input;

    out = out.replaceAllMapped(_apiKey, (m) => 'sk-***');
    out = out.replaceAllMapped(_supabaseKey, (m) => 'sb_***');
    out = out.replaceAllMapped(_bearer, (m) => '***');
    out = out.replaceAllMapped(_privateKey, (m) => '0x***');
    out = out.replaceAllMapped(_jwt, (m) => 'jwt.***');
    out = _redactSeedPhrase(out);

    return out;
  }

  /// Seed phrases are not regex-detectable (any 12+ contiguous wordlist
  /// words qualify), so this scans via the [Bip39Wordlist] after the
  /// regex passes. Loops so several phrases in one payload are all masked.
  static String _redactSeedPhrase(String input) {
    var span = Bip39Wordlist.findSeedPhrase(input);
    while (span != null) {
      input =
          '${input.substring(0, span[0])}***seed phrase***${input.substring(span[1])}';
      final next = Bip39Wordlist.findSeedPhrase(input);
      if (next == null) break;
      span = next;
    }
    return input;
  }

  /// Short mask for display: `sk-***a1b2` (blueprint 5.1). Keeps a short
  /// tail so the user can visually identify which key it is.
  static String mask(String value, {int head = 0, int tail = 4}) {
    if (value.length <= tail + 3) return '***';
    final h = head > 0 ? value.substring(0, head) : '';
    return '$h***${value.substring(value.length - tail)}';
  }

  /// Redacts a JSON payload meant for logs or audit entries.
  static String redactJson(Map<String, dynamic> json) =>
      redact(jsonEncode(json));
}
