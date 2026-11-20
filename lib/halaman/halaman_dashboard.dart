import 'package:flutter/material.dart';

import '../data/repositori_resep.dart';
import '../data/sesi_admin.dart';
import '../model/resep.dart';
import '../widget/gambar_resep.dart';
import '../widget/tampilan_error.dart';
import 'halaman_daftar_resep.dart';
import 'halaman_detail_resep.dart';
import 'halaman_form_resep.dart';
import 'halaman_login.dart';

class HalamanDashboard extends StatefulWidget {
  const HalamanDashboard({super.key});

  @override
  State<HalamanDashboard> createState() => _HalamanDashboardState();
}

class _HalamanDashboardState extends State<HalamanDashboard> {
  static const cokelat = Color(0xFF65452F);
  static const cokelatTua = Color(0xFF3D2A20);
  static const krem = Color(0xFFFAF5EF);
  static const kremGelap = Color(0xFFF0E3D5);
  static const oranye = Color(0xFFD99A56);
  static const hijau = Color(0xFF66805A);

  @override
  void initState() {
    super.initState();
    RepositoriResep.instance.ambilData();
  }

  void _keluar() {
    SesiAdmin.instance.keluar();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HalamanLogin()),
      (route) => false,
    );
  }

  void _bukaHalaman(Widget halaman) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => halaman),
    );
  }

  String _sapaan() {
    final jam = DateTime.now().hour;

    if (jam < 11) return 'Selamat pagi';
    if (jam < 15) return 'Selamat siang';
    if (jam < 18) return 'Selamat sore';

    return 'Selamat malam';
  }

  // BANNER SELAMAT DATANG
  Widget bannerDapurResep() {
    return Container(
      width: double.infinity,
      height: 230,
      margin: const EdgeInsets.only(bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/banner_dapur_resep.png',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color(0x66704A32),
                BlendMode.darken,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xCC40291E),
                  Color(0x6640291E),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_menu_rounded,
                  color: Color(0xFFFFD49B),
                  size: 28,
                ),
                SizedBox(height: 8),
                Text(
                  'Kelola Resep dengan Mudah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Tambah, ubah, dan hapus resep agar koleksi menu '
                  'selalu lengkap dan terbaru.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepositoriResep.instance;
    final namaAdmin = SesiAdmin.instance.admin?.nama ?? 'Admin';

    return Scaffold(
      backgroundColor: krem,

      // APP BAR
      appBar: AppBar(
        backgroundColor: cokelatTua,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 27,
              color: oranye,
            ),
            SizedBox(width: 10),
            Text(
              'Dapur Resep Admin',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _keluar,
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // TOMBOL TAMBAH RESEP
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaHalaman(const HalamanFormResep()),
        backgroundColor: cokelat,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah resep',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // KONTEN DASHBOARD
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          if (repo.sedangMemuat && repo.daftar.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: cokelat),
            );
          }

          if (repo.pesanError != null && repo.daftar.isEmpty) {
            return TampilanError(
              pesan: repo.pesanError!,
              saatCobaLagi: repo.ambilData,
            );
          }

          final daftar = repo.daftar;
          final total = daftar.length;

          final totalKategori = daftar.map((r) => r.kategori).toSet().length;

          final jumlahPerKategori = <String, int>{};
          for (final r in daftar) {
            jumlahPerKategori[r.kategori] =
                (jumlahPerKategori[r.kategori] ?? 0) + 1;
          }

          final kategoriTeratas = jumlahPerKategori.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          final terbaru = daftar.take(4).toList();

          return RefreshIndicator(
            color: cokelat,
            onRefresh: repo.ambilData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
              children: [
                // BANNER SELAMAT DATANG
                bannerDapurResep(),

                // SAPAAN ADMIN
                Container(
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [cokelatTua, cokelat],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _sapaan(),
                              style: const TextStyle(
                                color: Color(0xFFE9D5C1),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              namaAdmin,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Siap mengelola resep hari ini?',
                              style: TextStyle(
                                color: Color(0xFFF0E3D5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 30,
                          color: oranye,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // MENU
                const _JudulBagian(
                  judul: 'Menu',
                  keterangan: 'Akses cepat pengelolaan resep',
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _MenuItem(
                        ikon: Icons.add_circle_outline_rounded,
                        judul: 'Tambah resep',
                        warna: cokelat,
                        latar: kremGelap,
                        onTap: () => _bukaHalaman(
                          const HalamanFormResep(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MenuItem(
                        ikon: Icons.restaurant_menu_rounded,
                        judul: 'Daftar resep',
                        warna: hijau,
                        latar: const Color(0xFFE5EADD),
                        onTap: () => _bukaHalaman(
                          const HalamanDaftarResep(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // RINGKASAN
                const _JudulBagian(
                  judul: 'Ringkasan',
                  keterangan: 'Gambaran singkat koleksi resep',
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _KartuStatistik(
                        judul: 'Total resep',
                        nilai: '$total',
                        ikon: Icons.menu_book_rounded,
                        gradient: const [cokelatTua, cokelat],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KartuStatistik(
                        judul: 'Kategori',
                        nilai: '$totalKategori',
                        ikon: Icons.category_rounded,
                        gradient: const [Color(0xFF4F6745), hijau],
                      ),
                    ),
                  ],
                ),

                if (daftar.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SebaranKategori(
                    data: kategoriTeratas.take(4).toList(),
                    total: total,
                  ),
                ],

                const SizedBox(height: 28),

                // RESEP TERBARU
                Row(
                  children: [
                    const Expanded(
                      child: _JudulBagian(
                        judul: 'Resep terbaru',
                        keterangan: 'Resep yang baru ditambahkan',
                      ),
                    ),
                    TextButton(
                      onPressed: () => _bukaHalaman(
                        const HalamanDaftarResep(),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: cokelat,
                      ),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (daftar.isEmpty)
                  _TampilanKosong(
                    onTambah: () => _bukaHalaman(
                      const HalamanFormResep(),
                    ),
                  )
                else
                  ...terbaru.map(
                    (resep) => _KartuResep(
                      resep: resep,
                      onTap: () => _bukaHalaman(
                        HalamanDetailResep(idResep: resep.id!),
                      ),
                    ),
                  ),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    'Dapur Resep · Panel Admin',
                    style: TextStyle(
                      color: Color(0xFFAA9B8E),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// JUDUL BAGIAN
class _JudulBagian extends StatelessWidget {
  final String judul;
  final String keterangan;

  const _JudulBagian({
    required this.judul,
    required this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          judul,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _HalamanDashboardState.cokelatTua,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          keterangan,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF85776D),
          ),
        ),
      ],
    );
  }
}

// KARTU STATISTIK
class _KartuStatistik extends StatelessWidget {
  final String judul;
  final String nilai;
  final IconData ikon;
  final List<Color> gradient;

  const _KartuStatistik({
    required this.judul,
    required this.nilai,
    required this.ikon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned(
              right: -12,
              bottom: -14,
              child: Icon(
                ikon,
                size: 88,
                color: Colors.white.withValues(alpha: 0.13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    judul,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    nilai,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SEBARAN KATEGORI
class _SebaranKategori extends StatelessWidget {
  final List<MapEntry<String, int>> data;
  final int total;

  const _SebaranKategori({
    required this.data,
    required this.total,
  });

  static const _warna = [
    _HalamanDashboardState.cokelat,
    _HalamanDashboardState.oranye,
    _HalamanDashboardState.hijau,
    Color(0xFFB98B5E),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE3D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sebaran kategori',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _HalamanDashboardState.cokelatTua,
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < data.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    data[i].key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF85776D),
                    ),
                  ),
                ),
                Text(
                  '${data[i].value}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _HalamanDashboardState.cokelatTua,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: data[i].value / total,
                minHeight: 8,
                backgroundColor: _HalamanDashboardState.kremGelap,
                color: _warna[i % _warna.length],
              ),
            ),
            if (i != data.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

// MENU PINTASAN
class _MenuItem extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final Color warna;
  final Color latar;
  final VoidCallback onTap;

  const _MenuItem({
    required this.ikon,
    required this.judul,
    required this.warna,
    required this.latar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 17,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEDE3D8)),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: latar,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(ikon, color: warna, size: 20),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  judul,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _HalamanDashboardState.cokelatTua,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// KARTU RESEP TERBARU
class _KartuResep extends StatelessWidget {
  final Resep resep;
  final VoidCallback onTap;

  const _KartuResep({
    required this.resep,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDE3D8)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            children: [
              GambarResep(
                url: resep.gambar,
                width: 88,
                height: 88,
                radius: 13,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resep.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _HalamanDashboardState.cokelatTua,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _HalamanDashboardState.kremGelap,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        resep.kategori,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _HalamanDashboardState.cokelat,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: _HalamanDashboardState.oranye,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${resep.waktuMasak} menit',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF85776D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFAA9B8E),
                size: 23,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TAMPILAN KETIKA BELUM ADA RESEP
class _TampilanKosong extends StatelessWidget {
  final VoidCallback onTambah;

  const _TampilanKosong({
    required this.onTambah,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEDE3D8)),
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              color: _HalamanDashboardState.kremGelap,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 32,
              color: _HalamanDashboardState.cokelat,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Belum ada resep',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _HalamanDashboardState.cokelatTua,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tambahkan resep pertama untuk memulai.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF85776D),
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: onTambah,
            style: OutlinedButton.styleFrom(
              foregroundColor: _HalamanDashboardState.cokelat,
              side: const BorderSide(
                color: _HalamanDashboardState.cokelat,
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah resep'),
          ),
        ],
      ),
    );
  }
}