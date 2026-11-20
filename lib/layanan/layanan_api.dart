import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/admin.dart';
import '../model/resep.dart';

class PengecualianApi implements Exception {
  final String pesan;

  const PengecualianApi(this.pesan);

  @override
  String toString() => pesan;
}

class LayananApi {
  static const String urlDasar =
      'https://6ad3689159dd78397bbbaced.mockapi.io';

  static const String _sumber = 'resep';
  static const Duration _batasWaktu = Duration(seconds: 15);

  static const Map<String, String> _header = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

    Uri _alamat([String? id]) {
    final path = id == null
        ? _sumber
        : '$_sumber/$id';

    return Uri.parse('$urlDasar/$path');
  }

  /// READ - GET /resep
  Future<List<Resep>> ambilDaftarResep() async {
    final respons = await http
        .get(_alamat(), headers: _header)
        .timeout(_batasWaktu);

    _periksa(respons, [200]);

    final dynamic hasil = jsonDecode(respons.body);

    if (hasil is! List) {
      throw const PengecualianApi(
        'Format data resep dari server tidak sesuai.',
      );
    }

    return hasil.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const PengecualianApi(
          'Format salah satu data resep tidak sesuai.',
        );
      }

      return Resep.dariJson(item);
    }).toList();
  }

  /// CREATE - POST /resep
  Future<Resep> buatResep(Resep resep) async {
    final respons = await http
        .post(
          _alamat(),
          headers: _header,
          body: jsonEncode(resep.keJson()),
        )
        .timeout(_batasWaktu);

    _periksa(respons, [200, 201]);

    final dynamic hasil = jsonDecode(respons.body);

    if (hasil is! Map<String, dynamic>) {
      throw const PengecualianApi(
        'Respons penyimpanan resep tidak sesuai.',
      );
    }

    return Resep.dariJson(hasil);
  }

  /// UPDATE - PUT /resep/:id
  Future<Resep> ubahResep(Resep resep) async {
    final id = resep.id;

    if (id == null || id.isEmpty) {
      throw const PengecualianApi(
        'ID resep tidak ditemukan. Data tidak dapat diperbarui.',
      );
    }

    final respons = await http
        .put(
          _alamat(id),
          headers: _header,
          body: jsonEncode(resep.keJson()),
        )
        .timeout(_batasWaktu);

    _periksa(respons, [200]);

    final dynamic hasil = jsonDecode(respons.body);

    if (hasil is! Map<String, dynamic>) {
      throw const PengecualianApi(
        'Respons perubahan resep tidak sesuai.',
      );
    }

    return Resep.dariJson(hasil);
  }

  /// DELETE - DELETE /resep/:id
  Future<void> hapusResep(String id) async {
    final respons = await http
        .delete(_alamat(id), headers: _header)
        .timeout(_batasWaktu);

    _periksa(respons, [200, 204]);
  }

  /// LOGIN - GET /admin?namaPengguna=...
  Future<Admin?> cariAdmin(
    String namaPengguna,
    String kataSandi,
  ) async {
    final alamat = Uri.parse('$urlDasar/admin').replace(
      queryParameters: {
        'namaPengguna': namaPengguna,
      },
    );

    final respons = await http
        .get(alamat, headers: _header)
        .timeout(_batasWaktu);

    _periksa(respons, [200]);

    final dynamic hasil = jsonDecode(respons.body);

    if (hasil is! List) {
      throw const PengecualianApi(
        'Format data admin dari server tidak sesuai.',
      );
    }

    for (final item in hasil) {
      if (item is! Map<String, dynamic>) continue;

      final admin = Admin.dariJson(item);

      if (admin.namaPengguna == namaPengguna &&
          admin.kataSandi == kataSandi) {
        return admin;
      }
    }

    return null;
  }

  void _periksa(
    http.Response respons,
    List<int> diharapkan,
  ) {
    if (!diharapkan.contains(respons.statusCode)) {
      final detail = respons.body.trim();

      throw PengecualianApi(
        'Server error (${respons.statusCode})'
        '${detail.isNotEmpty ? ': $detail' : ''}',
      );
    }
  }
}
