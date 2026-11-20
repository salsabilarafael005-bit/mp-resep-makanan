import 'package:flutter/material.dart';

import '../data/repositori_resep.dart';
import '../data/sesi_admin.dart';
import 'halaman_dashboard.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  static const cokelat = Color(0xFF65452F);
  static const cokelatTua = Color(0xFF3D2A20);
  static const krem = Color(0xFFFAF5EF);
  static const kremGelap = Color(0xFFF0E3D5);
  static const oranye = Color(0xFFD99A56);

  final _kunciForm = GlobalKey<FormState>();
  final _namaPengguna = TextEditingController();
  final _kataSandi = TextEditingController();

  bool _sembunyikanSandi = true;
  bool _sedangMasuk = false;

  @override
  void dispose() {
    _namaPengguna.dispose();
    _kataSandi.dispose();
    super.dispose();
  }

  Future<void> _masuk() async {
    if (!_kunciForm.currentState!.validate()) return;

    setState(() => _sedangMasuk = true);

    try {
      final berhasil = await SesiAdmin.instance.masuk(
        _namaPengguna.text.trim(),
        _kataSandi.text,
      );

      if (!mounted) return;

      if (berhasil) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HalamanDashboard(),
          ),
        );
      } else {
        setState(() => _sedangMasuk = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Nama pengguna atau kata sandi salah'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _sedangMasuk = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(RepositoriResep.pesanDari(e)),
        ),
      );
    }
  }

  InputDecoration _dekorasi(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: cokelat, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: krem,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      labelStyle: const TextStyle(color: cokelat),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cokelatTua, cokelat],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: oranye.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 40,
                          color: oranye,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    const Text(
                      'Admin Resep Tradisional',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masuk untuk mengelola resep',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kremGelap),
                      ),
                      child: Form(
                        key: _kunciForm,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _namaPengguna,
                              autocorrect: false,
                              textInputAction: TextInputAction.next,
                              decoration: _dekorasi(
                                'Nama Pengguna',
                                Icons.person_outline_rounded,
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Nama pengguna wajib diisi'
                                      : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _kataSandi,
                              obscureText: _sembunyikanSandi,
                              decoration: _dekorasi(
                                'Kata Sandi',
                                Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  tooltip: _sembunyikanSandi
                                      ? 'Tampilkan kata sandi'
                                      : 'Sembunyikan kata sandi',
                                  color: cokelat,
                                  icon: Icon(
                                    _sembunyikanSandi
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _sembunyikanSandi = !_sembunyikanSandi;
                                    });
                                  },
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Kata sandi wajib diisi'
                                  : null,
                              onFieldSubmitted: (_) => _masuk(),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: _sedangMasuk ? null : _masuk,
                                style: FilledButton.styleFrom(
                                  backgroundColor: cokelat,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: kremGelap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                icon: _sedangMasuk
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: cokelat,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded, size: 20),
                                label: Text(
                                  _sedangMasuk ? 'Memproses...' : 'Masuk',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'Aplikasi Pengelolaan Resep Tradisional',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: oranye.withValues(alpha: 0.95),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}