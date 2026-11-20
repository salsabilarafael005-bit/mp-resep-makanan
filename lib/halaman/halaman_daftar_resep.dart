
import 'package:flutter/material.dart';

import '../data/repositori_resep.dart';
import '../model/resep.dart';
import '../widget/konfirmasi_hapus.dart';
import '../widget/tampilan_error.dart';
import '../widget/kartu_resep.dart';
import 'halaman_detail_resep.dart';
import 'halaman_form_resep.dart';

class HalamanDaftarResep extends StatefulWidget {
  const HalamanDaftarResep({super.key});

  @override
  State<HalamanDaftarResep> createState() =>
      _HalamanDaftarResepState();
}

class _HalamanDaftarResepState extends State<HalamanDaftarResep> {
  static const _labelSemua = 'Semua';

  static const cokelat = Color(0xFF65452F);
  static const cokelatTua = Color(0xFF3D2A20);
  static const krem = Color(0xFFFAF5EF);
  static const kremGelap = Color(0xFFF0E3D5);
  static const oranye = Color(0xFFD99A56);

  final _repositori = RepositoriResep.instance;
  final _kontrolCari = TextEditingController();

  String _kataKunci = '';
  String _kategori = _labelSemua;

  @override
  void dispose() {
    _kontrolCari.dispose();
    super.dispose();
  }

  void _bukaForm([Resep? resep]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalamanFormResep(resep: resep),
      ),
    );
  }

  void _bukaDetail(Resep resep) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalamanDetailResep(idResep: resep.id!),
      ),
    );
  }

  void _resetFilter() {
    _kontrolCari.clear();
    setState(() {
      _kataKunci = '';
      _kategori = _labelSemua;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: krem,
      appBar: AppBar(
        backgroundColor: cokelatTua,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Daftar Resep',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        backgroundColor: cokelat,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Resep',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListenableBuilder(
        listenable: _repositori,
        builder: (context, _) {
          if (_repositori.sedangMemuat &&
              _repositori.daftar.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: cokelat),
            );
          }

          if (_repositori.pesanError != null &&
              _repositori.daftar.isEmpty) {
            return TampilanError(
              pesan: _repositori.pesanError!,
              saatCobaLagi: _repositori.ambilData,
            );
          }

          final terfilter = _repositori.daftar.where((r) {
            final cocokKategori =
                _kategori == _labelSemua ||
                r.kategori == _kategori;

            final cocokKata = r.nama
                .toLowerCase()
                .contains(_kataKunci.toLowerCase().trim());

            return cocokKategori && cocokKata;
          }).toList();

          final adaFilter =
              _kataKunci.trim().isNotEmpty ||
              _kategori != _labelSemua;

          return Column(
            children: [
              // Header halaman
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cokelatTua, cokelat],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koleksi Resep',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kolom pencarian
                    TextField(
                      controller: _kontrolCari,
                      onChanged: (v) {
                        setState(() => _kataKunci = v);
                      },
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Cari nama resep...',
                        hintStyle: TextStyle(
                          color: cokelat.withValues(alpha: 0.55),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: cokelat,
                        ),
                        suffixIcon: _kataKunci.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus pencarian',
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: cokelat,
                                ),
                                onPressed: () {
                                  _kontrolCari.clear();
                                  setState(() => _kataKunci = '');
                                },
                              ),
                        filled: true,
                        fillColor: krem,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: oranye,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter kategori
              SizedBox(
                height: 66,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  children: [
                    _labelSemua,
                    ...KategoriResep.semua,
                  ].map((kategori) {
                    final dipilih = _kategori == kategori;

                    return Padding(
                      padding: const EdgeInsets.only(right: 9),
                      child: ChoiceChip(
                        label: Text(kategori),
                        selected: dipilih,
                        showCheckmark: false,
                        selectedColor: cokelat,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: dipilih ? Colors.white : cokelat,
                          fontWeight: dipilih
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: dipilih
                                ? cokelat
                                : kremGelap,
                          ),
                        ),
                        onSelected: (_) {
                          setState(() => _kategori = kategori);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Informasi jumlah resep
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: kremGelap,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 20,
                        color: cokelat,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adaFilter
                                ? 'Hasil pencarian'
                                : 'Semua koleksi',
                            style: const TextStyle(
                              color: cokelatTua,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${terfilter.length} resep tersedia',
                            style: TextStyle(
                              color: cokelat.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (adaFilter)
                      TextButton.icon(
                        onPressed: _resetFilter,
                        style: TextButton.styleFrom(
                          foregroundColor: cokelat,
                        ),
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 17,
                        ),
                        label: const Text('Reset'),
                      ),
                  ],
                ),
              ),

              // Daftar resep
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _repositori.ambilData,
                  color: cokelat,
                  backgroundColor: Colors.white,
                  child: terfilter.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            24,
                            20,
                            100,
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 32,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: kremGelap),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      color: kremGelap,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      adaFilter
                                          ? Icons.search_off_rounded
                                          : Icons.menu_book_rounded,
                                      size: 48,
                                      color: cokelat,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    adaFilter
                                        ? 'Resep tidak ditemukan'
                                        : 'Belum ada resep',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: cokelatTua,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    adaFilter
                                        ? 'Coba kata kunci atau kategori lain.'
                                        : 'Tambahkan resep pertamamu agar koleksimu makin lengkap.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: cokelat.withValues(
                                        alpha: 0.7,
                                      ),
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  if (adaFilter)
                                    OutlinedButton.icon(
                                      onPressed: _resetFilter,
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                      ),
                                      label: const Text('Reset filter'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: cokelat,
                                        side: const BorderSide(
                                          color: cokelat,
                                        ),
                                      ),
                                    )
                                  else
                                    ElevatedButton.icon(
                                      onPressed: () => _bukaForm(),
                                      icon: const Icon(
                                        Icons.add_rounded,
                                      ),
                                      label: const Text('Tambah Resep'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: cokelat,
                                        foregroundColor: Colors.white,
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            2,
                            16,
                            100,
                          ),
                          itemCount: terfilter.length,
                          itemBuilder: (context, i) {
                            final resep = terfilter[i];

                            return KartuResep(
                              resep: resep,
                              saatDitekan: () => _bukaDetail(resep),
                              saatEdit: () => _bukaForm(resep),
                              saatHapus: () =>
                                  konfirmasiDanHapusResep(
                                context,
                                resep,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
