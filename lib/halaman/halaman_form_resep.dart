import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/repositori_resep.dart';
import '../model/resep.dart';
import '../widget/gambar_resep.dart';

class HalamanFormResep extends StatefulWidget {
  final Resep? resep;

  const HalamanFormResep({super.key, this.resep});

  @override
  State<HalamanFormResep> createState() => _HalamanFormResepState();
}

class _HalamanFormResepState extends State<HalamanFormResep> {
  static const cokelat = Color(0xFF65452F);
  static const cokelatTua = Color(0xFF3D2A20);
  static const krem = Color(0xFFFAF5EF);
  static const kremGelap = Color(0xFFF0E3D5);
  static const oranye = Color(0xFFD99A56);

  static const double _lebarMaks = 640;
  static const double _jarakKartu = 16;
  static const double _jarakField = 14;
  static const double _tinggiFoto = 190;

  final _kunciForm = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _deskripsi;
  late final TextEditingController _bahan;
  late final TextEditingController _langkah;
  late final TextEditingController _waktu;

  late String _kategori;

  bool _menyimpan = false;
  String _gambarData = '';

  bool get _modeEdit => widget.resep != null;

  @override
  void initState() {
    super.initState();

    final r = widget.resep;

    _nama = TextEditingController(text: r?.nama ?? '');
    _deskripsi = TextEditingController(text: r?.deskripsi ?? '');
    _bahan = TextEditingController(text: r?.bahan ?? '');
    _langkah = TextEditingController(text: r?.langkah ?? '');
    _waktu = TextEditingController(
      text: r != null ? '${r.waktuMasak}' : '',
    );

    _gambarData = r?.gambar ?? '';

    _kategori = r != null && KategoriResep.semua.contains(r.kategori)
        ? r.kategori
        : KategoriResep.semua.first;
  }

  @override
  void dispose() {
    _nama.dispose();
    _deskripsi.dispose();
    _bahan.dispose();
    _langkah.dispose();
    _waktu.dispose();
    super.dispose();
  }

  Future<void> _pilihGambar() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 60,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!mounted) return;

      setState(() => _gambarData = base64Encode(bytes));
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto gagal dipilih. Silakan coba lagi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _simpan() async {
    if (!_kunciForm.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _menyimpan = true);

    final resep = Resep(
      id: widget.resep?.id,
      nama: _nama.text.trim(),
      kategori: _kategori,
      deskripsi: _deskripsi.text.trim(),
      bahan: _bahan.text.trim(),
      langkah: _langkah.text.trim(),
      waktuMasak: int.parse(_waktu.text.trim()),
      gambar: _gambarData,
    );

    try {
      final repositori = RepositoriResep.instance;

      if (_modeEdit) {
        await repositori.ubah(resep);
      } else {
        await repositori.tambah(resep);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cokelatTua,
          content: Text(
            _modeEdit
                ? 'Resep berhasil diperbarui'
                : 'Resep berhasil ditambahkan',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => _menyimpan = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(RepositoriResep.pesanDari(e)),
        ),
      );
    }
  }

  String? _wajibDiisi(String? v, String label) {
    return v == null || v.trim().isEmpty ? '$label wajib diisi' : null;
  }

  InputDecoration _dekorasi(
    String label, {
    String? helper,
    bool alignHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      alignLabelWithHint: alignHint,
      filled: true,
      fillColor: krem,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      labelStyle: const TextStyle(color: cokelat),
      helperStyle: TextStyle(color: cokelat.withValues(alpha: 0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kremGelap),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cokelat, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  // Dua field sebelahan kalau lebar cukup, menumpuk kalau sempit.
  Widget _duaKolom(Widget kiri, Widget kanan) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 440) {
          return Column(
            children: [
              kiri,
              const SizedBox(height: _jarakField),
              kanan,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: kiri),
            const SizedBox(width: 12),
            Expanded(child: kanan),
          ],
        );
      },
    );
  }

  Widget _bagianFoto() {
    if (_gambarData.isEmpty) {
      return InkWell(
        onTap: _pilihGambar,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: _tinggiFoto,
          width: double.infinity,
          decoration: BoxDecoration(
            color: krem,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: oranye, width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                size: 32,
                color: cokelat,
              ),
              const SizedBox(height: 10),
              const Text(
                'Tambahkan Foto Makanan',
                style: TextStyle(
                  color: cokelatTua,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Pilih dari galeri',
                style: TextStyle(
                  color: cokelat.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: _tinggiFoto,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GambarResep(
              url: _gambarData,
              width: double.infinity,
              height: _tinggiFoto,
              radius: 14,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                tooltip: 'Hapus foto',
                onPressed: () => setState(() => _gambarData = ''),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: FilledButton(
                onPressed: _pilihGambar,
                style: FilledButton.styleFrom(
                  backgroundColor: cokelatTua,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ganti Foto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuBagian({
    required String judul,
    required List<Widget> isi,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kremGelap),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _JudulBagian(judul),
          const SizedBox(height: 16),
          ...isi,
        ],
      ),
    );
  }

  Widget _tombolSimpan() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kremGelap)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _lebarMaks),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _menyimpan ? null : _simpan,
                  style: FilledButton.styleFrom(
                    backgroundColor: cokelat,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: kremGelap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _menyimpan
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cokelat,
                          ),
                        )
                      : Text(
                          _modeEdit ? 'Simpan Perubahan' : 'Simpan Resep',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
        title: Text(
          _modeEdit ? 'Edit Resep' : 'Tambah Resep',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _lebarMaks),
                child: Form(
                  key: _kunciForm,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _kartuBagian(
                        judul: 'Foto Makanan',
                        isi: [_bagianFoto()],
                      ),
                      const SizedBox(height: _jarakKartu),

                      _kartuBagian(
                        judul: 'Informasi Dasar',
                        isi: [
                          TextFormField(
                            controller: _nama,
                            textCapitalization: TextCapitalization.words,
                            decoration: _dekorasi('Nama Makanan'),
                            validator: (v) => _wajibDiisi(v, 'Nama makanan'),
                          ),
                          const SizedBox(height: _jarakField),
                          _duaKolom(
                            DropdownButtonFormField<String>(
                              initialValue: _kategori,
                              isExpanded: true,
                              decoration: _dekorasi('Kategori'),
                              items: KategoriResep.semua
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                setState(() => _kategori = v ?? _kategori);
                              },
                            ),
                            TextFormField(
                              controller: _waktu,
                              keyboardType: TextInputType.number,
                              decoration: _dekorasi('Waktu (menit)'),
                              validator: (v) {
                                final n = int.tryParse(v?.trim() ?? '');
                                if (n == null || n <= 0) {
                                  return 'Isi angka lebih dari 0';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: _jarakField),
                          TextFormField(
                            controller: _deskripsi,
                            maxLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: _dekorasi(
                              'Deskripsi',
                              alignHint: true,
                            ),
                            validator: (v) => _wajibDiisi(v, 'Deskripsi'),
                          ),
                        ],
                      ),
                      const SizedBox(height: _jarakKartu),

                      _kartuBagian(
                        judul: 'Detail Resep',
                        isi: [
                          TextFormField(
                            controller: _bahan,
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: _dekorasi(
                              'Bahan-bahan',
                              helper: 'Tulis satu bahan pada setiap baris.',
                              alignHint: true,
                            ),
                            validator: (v) => _wajibDiisi(v, 'Bahan-bahan'),
                          ),
                          const SizedBox(height: _jarakField),
                          TextFormField(
                            controller: _langkah,
                            maxLines: 8,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: _dekorasi(
                              'Langkah-langkah',
                              helper: 'Tulis satu langkah pada setiap baris.',
                              alignHint: true,
                            ),
                            validator: (v) =>
                                _wajibDiisi(v, 'Langkah-langkah'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _tombolSimpan(),
        ],
      ),
    );
  }
}

class _JudulBagian extends StatelessWidget {
  static const Color cokelatTua = Color(0xFF3D2A20);

  final String text;

  const _JudulBagian(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: cokelatTua,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}