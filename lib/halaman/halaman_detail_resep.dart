
import 'package:flutter/material.dart';

import '../data/repositori_resep.dart';
import '../widget/konfirmasi_hapus.dart';
import '../widget/gambar_resep.dart';
import 'halaman_form_resep.dart';

class HalamanDetailResep extends StatelessWidget {
  final String idResep;

  const HalamanDetailResep({
    super.key,
    required this.idResep,
  });

  static const cokelat = Color(0xFF65452F);
  static const cokelatTua = Color(0xFF3D2A20);
  static const krem = Color(0xFFFAF5EF);
  static const kremGelap = Color(0xFFF0E3D5);
  static const oranye = Color(0xFFD99A56);
  static const hijau = Color(0xFF66805A);

  @override
  Widget build(BuildContext context) {
    final repositori = RepositoriResep.instance;

    return ListenableBuilder(
      listenable: repositori,
      builder: (context, _) {
        final resep = repositori.cariBerdasarkanId(idResep);

        if (resep == null) {
          return const Scaffold(
            backgroundColor: krem,
            body: Center(
              child: CircularProgressIndicator(color: cokelat),
            ),
          );
        }

        return Scaffold(
          backgroundColor: krem,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 310,
                backgroundColor: cokelatTua,
                foregroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton(
                    tooltip: 'Kembali',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Colors.black.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Edit resep',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Colors.black.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HalamanFormResep(resep: resep),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Hapus resep',
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Colors.black.withValues(alpha: 0.5),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () async {
                      final terhapus =
                          await konfirmasiDanHapusResep(context, resep);

                      if (terhapus && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      GambarResep(
                        url: resep.gambar,
                        width: double.infinity,
                        height: 310,
                        radius: 0,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              cokelatTua.withValues(alpha: 0.35),
                            ],
                            stops: const [0, 0.45, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 38,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cokelatTua.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.restaurant_menu_rounded,
                                color: oranye,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'DETAIL RESEP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: krem,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resep.nama,
                          style: const TextStyle(
                            color: cokelatTua,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kremGelap,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category_rounded,
                                color: cokelat,
                                size: 17,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                resep.kategori,
                                style: const TextStyle(
                                  color: cokelat,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Ringkasan resep
                        Row(
                          children: [
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.timer_outlined,
                                label: 'Waktu',
                                value: '${resep.waktuMasak} mnt',
                                iconColor: oranye,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.shopping_basket_outlined,
                                label: 'Bahan',
                                value: '${resep.daftarBahan.length}',
                                iconColor: hijau,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InfoTile(
                                icon: Icons.format_list_numbered_rounded,
                                label: 'Langkah',
                                value: '${resep.daftarLangkah.length}',
                                iconColor: cokelat,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _KartuKonten(
                          judul: 'Tentang Resep',
                          ikon: Icons.notes_rounded,
                          child: Text(
                            resep.deskripsi,
                            style: const TextStyle(
                              color: cokelatTua,
                              height: 1.7,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        _KartuKonten(
                          judul: 'Bahan-bahan',
                          ikon: Icons.shopping_basket_rounded,
                          keterangan:
                              '${resep.daftarBahan.length} bahan',
                          child: Column(
                            children: resep.daftarBahan.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 20,
                                      color: hijau,
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          color: cokelatTua,
                                          height: 1.5,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 18),

                        _KartuKonten(
                          judul: 'Langkah Memasak',
                          ikon: Icons.soup_kitchen_rounded,
                          keterangan:
                              '${resep.daftarLangkah.length} langkah',
                          child: Column(
                            children: resep.daftarLangkah
                                .asMap()
                                .entries
                                .map((e) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: e.key.isEven
                                            ? cokelat
                                            : oranye,
                                        borderRadius:
                                            BorderRadius.circular(11),
                                      ),
                                      child: Text(
                                        '${e.key + 1}',
                                        style: TextStyle(
                                          color: e.key.isEven
                                              ? Colors.white
                                              : cokelatTua,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 6),
                                        child: Text(
                                          e.value,
                                          style: const TextStyle(
                                            color: cokelatTua,
                                            height: 1.6,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HalamanFormResep(resep: resep),
                              ),
                            ),
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Edit Resep Ini'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cokelat,
                              side: const BorderSide(color: cokelat),
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  static const Color cokelat = Color(0xFF65452F);
  static const Color cokelatTua = Color(0xFF3D2A20);
  static const Color krem = Color(0xFFFAF5EF);
  static const Color kremGelap = Color(0xFFF0E3D5);

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: kremGelap),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: krem,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: cokelatTua,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: cokelat.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _KartuKonten extends StatelessWidget {
  static const Color cokelat = Color(0xFF65452F);
  static const Color cokelatTua = Color(0xFF3D2A20);
  static const Color krem = Color(0xFFFAF5EF);
  static const Color kremGelap = Color(0xFFF0E3D5);

  final String judul;
  final IconData ikon;
  final String? keterangan;
  final Widget child;

  const _KartuKonten({
    required this.judul,
    required this.ikon,
    required this.child,
    this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kremGelap),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kremGelap,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(ikon, color: cokelat, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  judul,
                  style: const TextStyle(
                    color: cokelatTua,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (keterangan != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: krem,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    keterangan!,
                    style: const TextStyle(
                      color: cokelat,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
