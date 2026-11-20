class Admin {
  final String? id;
  final String nama;
  final String namaPengguna;
  final String kataSandi;

  const Admin({
    this.id,
    required this.nama,
    required this.namaPengguna,
    required this.kataSandi,
  });

  factory Admin.dariJson(Map<String, dynamic> json) => Admin(
        id: json['id']?.toString(),
        nama: (json['nama'] ?? '').toString(),
        namaPengguna: (json['namaPengguna'] ?? '').toString(),
        kataSandi: (json['kataSandi'] ?? '').toString(),
      );
}
