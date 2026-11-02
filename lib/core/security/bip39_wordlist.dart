import 'package:flutter/services.dart' show rootBundle;

/// BIP-39 English wordlist (blueprint rule S-03: seed phrase redaction).
///
/// The list ships as a compressed engine asset rather than a source-code
/// constant: 2048 words as literals would burn ~14 KB into the Dart heap at
/// compile time and make review noisy. [load] is called once at bootstrap
/// (see main.dart) so the first [findSeedPhrase] call is warm.
class Bip39Wordlist {
  Bip39Wordlist._();

  static const _assetPath = 'assets/bip39_english.txt';

  static final Set<String> _words = <String>{};
  static bool _loaded = false;

  /// Word tokens; seed phrases are space-delimited so punctuation or a
  /// newline between words breaks a run.
  static final RegExp _wordPattern = RegExp(r'[A-Za-z]+');

  /// Loads the wordlist. Safe to call repeatedly; concurrent callers share
  /// one load (the returned future completes for all of them).
  static Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(_assetPath);
    // Word-per-line, trimmed; the canonical file ends with a newline.
    _words.addAll(
      raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty),
    );
    _loaded = true;
  }

  static bool get isLoaded => _loaded;

  /// True when [word] is on the BIP-39 English wordlist.
  static bool isWord(String word) =>
      _loaded && _words.contains(word.toLowerCase());

  /// Finds the span of a BIP-39 seed phrase in [text], if any.
  ///
  /// A seed phrase is 12+ consecutive BIP-39 words separated by single
  /// spaces. Returns the inclusive [start, end] character range, or null
  /// when no qualifying run is found. False positives (prose that happens
  /// to be all wordlist words) are acceptable: redaction errs toward
  /// masking.
  static List<int>? findSeedPhrase(String text) {
    if (!_loaded) return null;

    final tokens = <_Token>[];
    for (final m in _wordPattern.allMatches(text)) {
      tokens.add(_Token(m.start, m.end, m.group(0)!));
    }
    if (tokens.length < 12) return null;

    var runStart = -1; // index of the first word in the current run
    for (var i = 0; i < tokens.length; i++) {
      final t = tokens[i];
      final inList = _words.contains(t.word.toLowerCase());
      // A run continues when the word is on the list AND (it starts the
      // run OR follows the previous word with exactly one space).
      final continues = inList &&
          (runStart < 0 ||
              _isContiguous(tokens[i - 1], t));
      if (continues) {
        if (runStart < 0) runStart = i;
        continue;
      }

      // Run broken at i: check the run ending at i-1.
      if (runStart >= 0) {
        final runLen = i - runStart;
        if (runLen >= 12) {
          return <int>[tokens[runStart].start, tokens[i - 1].end];
        }
      }
      runStart = inList ? i : -1;
    }

    // Tail check: the text may end on a complete run.
    if (runStart >= 0 && tokens.length - runStart >= 12) {
      return <int>[tokens[runStart].start, tokens[tokens.length - 1].end];
    }
    return null;
  }

  /// A run only counts when consecutive words are separated by exactly one
  /// space (BIP-39 phrases are space-delimited; prose usually has longer
  /// gaps, commas, or newlines between words).
  static bool _isContiguous(_Token a, _Token b) =>
      b.start - a.end == 1;
}

class _Token {
  const _Token(this.start, this.end, this.word);

  final int start;
  final int end;
  final String word;
}
