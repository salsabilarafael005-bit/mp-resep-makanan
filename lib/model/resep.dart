class KategoriResep {
  static const List<String> semua = [
    'Makanan Utama',
    'Sup',
    'Camilan',
    'Minuman',
    'Dessert',
  ];
}

class Resep {
  final String? id;
  final String nama;
  final String kategori;
  final String deskripsi;
  final String bahan; // satu bahan per baris
  final String langkah; // satu langkah per baris
  final int waktuMasak; // menit
  final String gambar;

  const Resep({
    this.id,
    required this.nama,
    required this.kategori,
    required this.deskripsi,
    required this.bahan,
    required this.langkah,
    required this.waktuMasak,
    required this.gambar,
  });

  List<String> get daftarBahan => _pecahBaris(bahan);

  // Nomor di depan baris (misal "1. ") dibuang, nanti diberi nomor otomatis.
  List<String> get daftarLangkah => _pecahBaris(langkah)
      .map((s) => s.replaceFirst(RegExp(r'^\d+[.)]\s*'), ''))
      .toList();

  static List<String> _pecahBaris(String text) => text
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Resep copyWith({String? id}) => Resep(
        id: id ?? this.id,
        nama: nama,
        kategori: kategori,
        deskripsi: deskripsi,
        bahan: bahan,
        langkah: langkah,
        waktuMasak: waktuMasak,
        gambar: gambar,
      );

  // Dipakai saat integrasi MockAPI
  factory Resep.dariJson(Map<String, dynamic> json) => Resep(
        id: json['id']?.toString(),
        nama: (json['nama'] ?? '').toString(),
        kategori: (json['kategori'] ?? '').toString(),
        deskripsi: (json['deskripsi'] ?? '').toString(),
        bahan: (json['bahan'] ?? '').toString(),
        langkah: (json['langkah'] ?? '').toString(),
        waktuMasak: int.tryParse('${json['waktuMasak']}') ?? 0,
        gambar: (json['gambar'] ?? '').toString(),
      );

  Map<String, dynamic> keJson() => {
        'nama': nama,
        'kategori': kategori,
        'deskripsi': deskripsi,
        'bahan': bahan,
        'langkah': langkah,
        'waktuMasak': waktuMasak,
        'gambar': gambar,
      };
}
