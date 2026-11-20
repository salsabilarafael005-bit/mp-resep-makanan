import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/resep.dart';
import '../layanan/layanan_api.dart';

/// Sumber data untuk seluruh UI. Sekarang datanya diambil dari MockAPI
/// lewat LayananApi; UI tetap cukup memanggil tambah / ubah / hapus.
class RepositoriResep extends ChangeNotifier {
  RepositoriResep._();
  static final RepositoriResep instance = RepositoriResep._();

  final LayananApi _api = LayananApi();

  List<Resep> _daftar = [];
  bool _sedangMemuat = false;
  String? _pesanError;

  List<Resep> get daftar => List.unmodifiable(_daftar);
  bool get sedangMemuat => _sedangMemuat;
  String? get pesanError => _pesanError;

  Resep? cariBerdasarkanId(String id) {
    for (final r in _daftar) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// Teks error yang ramah untuk ditampilkan ke admin
  static String pesanDari(Object e) {
    if (e is PengecualianApi) return e.pesan;
    if (e is TimeoutException) return 'Koneksi timeout, coba lagi.';
    return 'Gagal terhubung ke server. Cek koneksi internet.';
  }

  /// READ
  Future<void> ambilData() async {
    _sedangMemuat = true;
    _pesanError = null;
    notifyListeners();

    try {
      final data = await _api.ambilDaftarResep();
      _daftar = data.reversed.toList(); // terbaru di atas
    } catch (e) {
      _pesanError = pesanDari(e);
    }

    _sedangMemuat = false;
    notifyListeners();
  }

  /// CREATE (melempar exception kalau gagal)
  Future<void> tambah(Resep resep) async {
    final dibuat = await _api.buatResep(resep);
    _daftar.insert(0, dibuat);
    notifyListeners();
  }

  /// UPDATE (melempar exception kalau gagal)
  Future<void> ubah(Resep resep) async {
    final diperbarui = await _api.ubahResep(resep);
    final index = _daftar.indexWhere((r) => r.id == diperbarui.id);
    if (index != -1) _daftar[index] = diperbarui;
    notifyListeners();
  }

  /// DELETE (melempar exception kalau gagal)
  Future<void> hapus(String id) async {
    await _api.hapusResep(id);
    _daftar.removeWhere((r) => r.id == id);
    notifyListeners();
  }
}
