import 'dart:convert';

import 'package:dio/dio.dart';

/// Klien JSON-RPC EVM minimal (blueprint Fase 7, read-only).
///
/// Hanya memanggil method baca (`eth_getBalance`, `eth_call`, `eth_blockNumber`,
/// `eth_gasPrice`). Tidak ada kunci privat yang terlibat di modul ini —
/// dompet yang dipantau bersifat **watch-only** (alamat publik saja).
///
/// Endpoint diisi pengguna (aturan K-08: RPC tepercaya pilihan pengguna),
/// tidak ada endpoint yang di-hardcode di app.
class RpcClient {
  RpcClient({required this.url, Dio? dio}) : _dio = dio ?? Dio();

  /// URL RPC pengguna, mis. `https://bsc-dataseed.bnbchain.org`.
  final String url;
  final Dio _dio;

  int _id = 0;

  /// Request JSON-RPC 2.0 generik.
  Future<dynamic> call(String method, [List<dynamic>? params]) async {
    final id = ++_id;
    try {
      final res = await _dio.post<dynamic>(
        url,
        data: jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'method': method,
          // ignore: use_null_aware_elements
          if (params != null) 'params': params,
        }),
        options: Options(
          headers: const {'Content-Type': 'application/json'},
          // Waktu tunggu singkat: RPC publik kadang lambat.
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final body = res.data is String
          ? jsonDecode(res.data as String) as Map<String, dynamic>
          : res.data as Map<String, dynamic>;
      if (body.containsKey('error')) {
        throw RpcException(_errMsg(body['error']));
      }
      return body['result'];
    } on DioException catch (e) {
      throw RpcException('jaringan: ${e.message}');
    }
  }

  String _errMsg(Object? e) {
    if (e is Map) {
      return (e['message'] ?? e.toString()).toString();
    }
    return e.toString();
  }

  /// Saldo native (wei) dari [address].
  Future<BigInt> getBalance(String address) async {
    final hex = await call('eth_getBalance', [address, 'latest']);
    return _hexToBigInt(hex as String);
  }

  /// Nomor blok terbaru.
  Future<int> blockNumber() async {
    final hex = await call('eth_blockNumber');
    return _hexToBigInt(hex as String).toInt();
  }

  /// Harga gas saat ini (wei).
  Future<BigInt> gasPrice() async {
    final hex = await call('eth_gasPrice');
    return _hexToBigInt(hex as String);
  }

  /// Saldo token ERC-20 (raw uint256) untuk pemilik [owner].
  Future<BigInt> tokenBalance({
    required String token,
    required String owner,
  }) async {
    // balanceOf(address) selector = 0x70a08231
    final data =
        '0x70a08231000000000000000000000000${owner.substring(2).toLowerCase()}';
    final hex = await call('eth_call', [
      {'to': token, 'data': data},
      'latest',
    ]);
    return _hexToBigInt(hex as String);
  }

  /// Cek apakah RPC merespons (digunakan saat tes koneksi).
  Future<bool> ping() async {
    try {
      await blockNumber();
      return true;
    } catch (_) {
      return false;
    }
  }

  static BigInt _hexToBigInt(String hex) {
    var h = hex;
    if (h.startsWith('0x') || h.startsWith('0X')) h = h.substring(2);
    if (h.isEmpty) return BigInt.zero;
    return BigInt.parse(h, radix: 16);
  }
}

class RpcException implements Exception {
  RpcException(this.message);
  final String message;

  @override
  String toString() => 'RpcException: $message';
}
