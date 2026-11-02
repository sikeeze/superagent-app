import 'dart:convert';

/// Model manifest.json sebuah skill (blueprint 9.1).
///
/// Skill adalah unit deklaratif: folder berisi SKILL.md (instruksi untuk
/// agent), manifest.json (izin, versi, hash), dan scripts/ opsional
/// (JavaScript untuk sandbox QuickJS).
class SkillManifest {
  const SkillManifest({
    required this.name,
    required this.version,
    required this.description,
    required this.permissions,
    required this.risk,
    this.sha256,
  });

  /// Parse dari JSON mentah. Melempar [SkillManifestException] jika
  /// struktur tidak lengkap — skill gagal impor, bukan dijalankan
  /// dengan izin tak terparse (fail-closed, S-30).
  factory SkillManifest.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final version = json['version'] as String?;
    final description = json['description'] as String?;
    final permsRaw = json['permissions'];
    final risk = json['risk'] as String?;

    if (name == null || name.isEmpty) {
      throw const SkillManifestException('manifest: "name" wajib diisi.');
    }
    if (version == null || version.isEmpty) {
      throw const SkillManifestException('manifest: "version" wajib diisi.');
    }
    if (description == null) {
      throw const SkillManifestException('manifest: "description" wajib diisi.');
    }
    if (permsRaw is! Map<String, dynamic>) {
      throw const SkillManifestException(
          'manifest: "permissions" harus objek.');
    }
    final riskParsed = _tryParseRisk(risk);
    if (riskParsed == null) {
      throw SkillManifestException(
          'manifest: "risk" tidak valid: "$risk". Pilihan: low, medium, high.');
    }

    return SkillManifest(
      name: name,
      version: version,
      description: description,
      permissions: SkillPermissions.fromJson(permsRaw),
      risk: riskParsed,
      sha256: json['sha256'] as String?,
    );
  }

  final String name;
  final String version;
  final String description;
  final SkillPermissions permissions;
  final SkillRisk risk;

  /// SHA-256 seluruh isi skill (S-32: perubahan isi setelah disetujui
  /// memicu persetujuan ulang).
  final String? sha256;

  Map<String, dynamic> toJson() => {
        'name': name,
        'version': version,
        'description': description,
        'permissions': permissions.toJson(),
        'risk': risk.name,
        if (sha256 != null) 'sha256': sha256,
      };

  @override
  String toString() => 'SkillManifest($name v$version, risk=${risk.name})';
}

/// Izin yang diminta sebuah skill (S-12: allowlist domain per skill).
class SkillPermissions {
  const SkillPermissions({
    this.network = const [],
    this.notify = false,
    this.files = SkillFileAccess.none,
  });

  factory SkillPermissions.fromJson(Map<String, dynamic> json) {
    final networkRaw = json['network'];
    final network = <String>[];
    if (networkRaw is List) {
      network.addAll(networkRaw.whereType<String>());
    }
    final files = _tryParseFiles(json['files'] as String?);
    return SkillPermissions(
      network: List<String>.unmodifiable(network),
      notify: json['notify'] == true,
      files: files,
    );
  }

  /// Domain yang boleh diakses skill (allowlist; default kosong = tolak
  /// semua sampai pengguna menyetujui — S-12).
  final List<String> network;

  /// Boleh kirim notifikasi.
  final bool notify;

  /// Akses file: hanya folder sandbox (S-25).
  final SkillFileAccess files;

  Map<String, dynamic> toJson() => {
        'network': network,
        'notify': notify,
        'files': files.name,
      };
}

enum SkillFileAccess { none, sandbox }

enum SkillRisk { low, medium, high }

SkillRisk? _tryParseRisk(String? s) {
  switch (s) {
    case 'low':
      return SkillRisk.low;
    case 'medium':
      return SkillRisk.medium;
    case 'high':
      return SkillRisk.high;
    default:
      return null;
  }
}

SkillFileAccess _tryParseFiles(String? s) {
  switch (s) {
    case 'sandbox':
      return SkillFileAccess.sandbox;
    default:
      return SkillFileAccess.none;
  }
}

class SkillManifestException implements Exception {
  const SkillManifestException(this.message);
  final String message;
  @override
  String toString() => 'SkillManifestException: $message';
}

/// Helper parse aman dari string JSON.
SkillManifest parseSkillManifest(String raw) {
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return SkillManifest.fromJson(json);
}
