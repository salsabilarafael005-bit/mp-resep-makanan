import 'package:flutter/foundation.dart';

import '../layanan/layanan_api.dart';
import '../model/admin.dart';

/// Menyimpan siapa admin yang sedang login (hanya selama aplikasi terbuka).
class SesiAdmin extends ChangeNotifier {
  SesiAdmin._();
  static final SesiAdmin instance = SesiAdmin._();

  final LayananApi _api = LayananApi();
  Admin? _admin;

  Admin? get admin => _admin;
  bool get sudahMasuk => _admin != null;

  /// Return true kalau nama pengguna dan kata sandi cocok.
  /// Melempar exception kalau gagal terhubung ke server.
  Future<bool> masuk(String namaPengguna, String kataSandi) async {
    final hasil = await _api.cariAdmin(namaPengguna, kataSandi);
    if (hasil == null) return false;
    _admin = hasil;
    notifyListeners();
    return true;
  }

  void keluar() {
    _admin = null;
    notifyListeners();
  }
}
