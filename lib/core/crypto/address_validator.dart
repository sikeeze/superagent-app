/// Validasi alamat EVM (Fase 7).
///
/// Fase 7 memakai checksum dasar (prefix 0x + 40 hex) untuk memfilter input
/// jelas invalid sebelum menyentuh DB/RPC. Verifikasi checksum EIP-55 dan
 /// deteksi drainer/permit dipasang di Fase 8 bersama PolicyEngine on-chain
/// penuh.
class AddressValidator {
  AddressValidator._();

  static final _re = RegExp(r'^0x[0-9a-fA-F]{40}$');

  /// True bila format dasar alamat EVM valid.
  static bool isValid(String address) {
    return _re.hasMatch(address.trim());
  }

  /// True bila alamat adalah kontrak berbahaya dikenal? Fase 7: tidak pernah
  /// dipanggil; gunakan [PolicyEngine] on-chain di Fase 8.
  static bool isUnlimitedApprovalSig(String data) {
    if (data.length < 10) return false;
    final sig = data.substring(0, 10).toLowerCase();
    // N-03: approve tak terbatas & setApprovalForAll diblokir otomatis.
    // Layout calldata: selector(10 hex) + address(64 hex) + uint256(64 hex).
    if (sig == '0x095ea7b3') {
      if (data.length < 138) return false;
      final amount = data.substring(74, 138);
      return amount.toLowerCase() ==
          'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
    }
    return sig == '0xa22cb465'; // setApprovalForAll(address,bool)
  }
}
