/// Parse input terminal menjadi command + argumen (blueprint 9.2).
///
/// Command virtual: `skill list`, `skill install <p>`, `config get <k>`,
/// dst. Bukan shell sistem (S-23: perintah diimplementasikan dalam app).
class ParsedCommand {
  const ParsedCommand({required this.name, required this.args});

  /// Command utama, mis. `skill`.
  final String name;

  /// Argumen setelahnya, mis. `['install', 'path/atau/url']`.
  final List<String> args;

  /// Sub-command pertama (mis. `install` dari `skill install x`), atau
  /// null bila tidak ada.
  String? get sub => args.isNotEmpty ? args.first : null;

  /// Sisa argumen setelah sub-command.
  List<String> get rest => args.skip(1).toList();
}

/// Tokenisasi sederhana: hormati tanda kutip, pisahkan spasi.
List<String> tokenize(String raw) {
  final tokens = <String>[];
  final buf = StringBuffer();
  var quote = false;
  for (final ch in raw.runes) {
    if (ch == 0x22 || ch == 0x27) {
      // " atau '
      quote = !quote;
      continue;
    }
    if (!quote && (ch == 0x20 || ch == 0x09)) {
      if (buf.isNotEmpty) {
        tokens.add(buf.toString());
        buf.clear();
      }
      continue;
    }
    buf.writeCharCode(ch);
  }
  if (buf.isNotEmpty) tokens.add(buf.toString());
  return tokens;
}

/// Parse baris input. Mengembalikan null bila kosong.
ParsedCommand? parseCommand(String raw) {
  final tokens = tokenize(raw.trim());
  if (tokens.isEmpty) return null;
  return ParsedCommand(name: tokens.first, args: tokens.skip(1).toList());
}
