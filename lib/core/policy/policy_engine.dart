import 'network_guard.dart';
import 'permissions.dart';

/// Decides whether a proposed agent action may run (blueprint 6.6, 10A.1).
///
/// The model only ever PROPOSES an action; this engine decides. Every
/// decision is written to the audit trail with a human-readable reason so
/// the user can verify why something ran or was blocked (rules K-06, S-41).
class PolicyEngine {
  PolicyEngine({
    RiskLevel confirmationThreshold = RiskLevel.high,
    this.defaultAllowedHosts = const <String>{},
  }) : _confirmationThreshold = confirmationThreshold;

  /// Actions at or above this level need explicit human confirmation
  /// (Manual execution mode, the install default per C-11).
  final RiskLevel _confirmationThreshold;

  /// S-12: hosts a skill may call without asking. Empty by default = deny
  /// every network call until the user approves a host at skill review.
  final Set<String> defaultAllowedHosts;

  /// Evaluates a proposed tool call against the active permission grants.
  ///
  /// Returns a [PolicyDecision]; never throws on policy violations —
  /// refusals are normal outcomes and are logged, not raised.
  PolicyDecision evaluate({
    required ToolSpec tool,
    required Map<String, dynamic> args,
    required Set<Permission> granted,
    Set<String>? allowedHosts,
  }) {
    // Forbidden actions can never be approved, by anyone, in any mode.
    if (tool.risk == RiskLevel.forbidden) {
      return PolicyDecision(
        allowed: false,
        reason: 'Aksi "${tool.name}" dilarang. Tidak bisa diizinkan dalam '
            'mode apa pun.',
      );
    }

    // Check declared permissions against what the user actually granted.
    final missing = tool.permissions.where((p) => !granted.contains(p));
    if (missing.isNotEmpty) {
      final names = missing.map(_permissionName).join(', ');
      return PolicyDecision(
        allowed: false,
        reason: 'Skill belum diberi izin: $names.',
      );
    }

    // Domain allowlist + anti-SSRF for network tools (rules S-12, S-13).
    // Also enforces S-10 (HTTPS or loopback/LAN) at decision time.
    if (tool.permissions.contains(Permission.network)) {
      final host = NetworkGuard.hostOf(args);
      if (host == null || host.isEmpty) {
        return PolicyDecision(
          allowed: false,
          reason: 'Permintaan jaringan tanpa host yang valid.',
        );
      }
      if (NetworkGuard.isPrivateHost(host)) {
        return PolicyDecision(
          allowed: false,
          reason: 'Host $host adalah alamat internal; diblokir anti-SSRF '
              '(aturan S-13).',
        );
      }
      final url = args['url'] as String?;
      if (url != null && url.contains('://')) {
        final uri = Uri.parse(url);
        if (!NetworkGuard.isCleartextAllowed(uri)) {
          return PolicyDecision(
            allowed: false,
            reason: 'HTTP hanya diizinkan untuk localhost/LAN (aturan S-10).',
          );
        }
      }
      if (!NetworkGuard.hostAllowed(host, allowedHosts ?? defaultAllowedHosts)) {
        return PolicyDecision(
          allowed: false,
          reason: 'Host $host belum diizinkan untuk skill ini. Setujui '
              'host di pengaturan skill (aturan S-12).',
        );
      }
    }

    final needConfirm = tool.risk.index >= _confirmationThreshold.index;
    // A high-risk action is never auto-approved: `allowed` stays false and
    // the agent loop must either ask the human (when a confirm callback
    // exists) or hit its `!decision.allowed` refusal branch — it cannot
    // silently run. Low-risk actions are allowed straight away.
    return PolicyDecision(
      allowed: !needConfirm,
      needsConfirmation: needConfirm,
      reason: needConfirm
          ? 'Aksi berisiko ${_riskName(tool.risk)}: perlu persetujuan Anda.'
          : 'Diizinkan secara otomatis (risiko ${_riskName(tool.risk)}).',
    );
  }

  String _riskName(RiskLevel l) => switch (l) {
        RiskLevel.low => 'rendah',
        RiskLevel.medium => 'sedang',
        RiskLevel.high => 'tinggi',
        RiskLevel.forbidden => 'dilarang',
      };

  String _permissionName(Permission p) => switch (p) {
        Permission.network => 'network',
        Permission.files => 'files',
        Permission.notify => 'notify',
        Permission.clipboard => 'clipboard',
        Permission.terminal => 'terminal',
        Permission.sign => 'sign',
      };
}
