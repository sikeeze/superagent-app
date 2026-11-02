/// Central network policy enforcement (blueprint rules S-10, S-12, S-13).
///
/// Both [PolicyEngine] (before a call runs) and the `http_request` tool
/// (at execution time) pipe through here, so the rules cannot be bypassed
/// by either side. Host parsing is shared to keep the two checks in sync.
class NetworkGuard {
  const NetworkGuard._();

  /// Shamelessly plain HTTP is only allowed for loopback / LAN (rule S-10).
  static bool isCleartextAllowed(Uri uri) {
    if (uri.scheme == 'https') return true;
    if (uri.scheme != 'http') return false;
    final host = _stripBrackets(uri.host);
    return isLoopbackHost(host) || isPrivateHost(host);
  }

  /// True for loopback in any spelling we are likely to see.
  static bool isLoopbackHost(String host) {
    final h = _stripBrackets(host).toLowerCase();
    if (h == 'localhost' || h == '0.0.0.0' || h == '::' || h == '::1') {
      return true;
    }
    if (h.startsWith('127.')) return true;
    // IPv4-mapped IPv6 loopback (::ffff:127.0.0.1).
    final mapped = _ipv4Mapped(h);
    if (mapped != null) return mapped.startsWith('127.');
    return false;
  }

  /// RFC1918 + link-local + carrier-grade NAT (rule S-13). IPv6 private
  /// ranges are blocked too: unique-local fc00::/7 and link-local fe80::/10.
  static bool isPrivateHost(String host) {
    final h = _stripBrackets(host).toLowerCase();
    // Strip a trailing port only when it is not part of an IPv6 address.
    final bare = _maybeStripPort(h);

    if (bare.startsWith('10.') ||
        bare.startsWith('192.168.') ||
        bare.startsWith('169.254.') ||
        bare.startsWith('100.64.')) {
      return true;
    }
    if (bare.startsWith('172.')) {
      final parts = bare.split('.');
      if (parts.length > 1) {
        final second = int.tryParse(parts[1]);
        if (second != null && second >= 16 && second <= 31) return true;
      }
    }
    if (bare.startsWith('fd') || bare.startsWith('fc')) return true;
    if (bare.startsWith('fe80:') || bare.startsWith('fe8') || bare.startsWith('fe9')) {
      return true;
    }
    final mapped = _ipv4Mapped(bare);
    if (mapped != null) return isPrivateHost(mapped);
    return false;
  }

  /// S-12: a network call is only allowed to a host the user granted for
  /// the active skill. Default is an empty list = deny everything until
  /// the user approves (`allowedHosts` is populated at skill review).
  static bool hostAllowed(String host, Set<String> allowedHosts) {
    if (allowedHosts.isEmpty) return false;
    final h = _stripBrackets(host).toLowerCase();
    for (final granted in allowedHosts) {
      final g = granted.toLowerCase();
      if (g == h || h.endsWith('.$g')) return true;
    }
    return false;
  }

  /// Extracts the host from either a full URL or a bare host argument,
  /// tolerating schemes, ports and IPv6 brackets.
  static String? hostOf(Map<String, dynamic> args) {
    final raw = args['url'] as String? ?? args['host'] as String?;
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains('://')) {
      try {
        return Uri.parse(trimmed).host;
      } catch (_) {
        return null;
      }
    }
    // Bare host[:port]; keep the bracket form for IPv6.
    final host = _maybeStripPort(trimmed);
    return host.isEmpty ? null : host;
  }

  static String _stripBrackets(String host) =>
      host.startsWith('[') && host.endsWith(']')
          ? host.substring(1, host.length - 1)
          : host;

  static String _maybeStripPort(String host) {
    // IPv6 in brackets: [::1]:443 → ::1.
    if (host.startsWith('[')) {
      final end = host.indexOf(']');
      return end > 0 ? host.substring(1, end) : host;
    }
    final colon = host.lastIndexOf(':');
    if (colon > 0 && int.tryParse(host.substring(colon + 1)) != null) {
      return host.substring(0, colon);
    }
    return host;
  }

  /// Returns the IPv4 dotted quad for an IPv4-mapped IPv6 address, else null.
  static String? _ipv4Mapped(String host) {
    if (!host.startsWith('::ffff:') && !host.startsWith('::FFFF:')) return null;
    final tail = host.substring(7);
    return tail.contains('.') && _looksLikeQuad(tail) ? tail : null;
  }

  static bool _looksLikeQuad(String s) {
    final parts = s.split('.');
    if (parts.length != 4) return false;
    return parts.every((p) => int.tryParse(p) != null);
  }
}
