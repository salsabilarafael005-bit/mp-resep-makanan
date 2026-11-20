import 'package:flutter/material.dart';

import '../data/repositori_resep.dart';
import '../model/resep.dart';

/// Dialog konfirmasi -> hapus lewat API. Return true kalau berhasil dihapus.
Future<bool> konfirmasiDanHapusResep(BuildContext context, Resep resep) async {
  final messenger = ScaffoldMessenger.of(context);

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus resep?'),
      content: Text('"${resep.nama}" akan dihapus permanen.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (ok != true) return false;

  try {
    await RepositoriResep.instance.hapus(resep.id!);
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(RepositoriResep.pesanDari(e))),
    );
    return false;
  }

  messenger.showSnackBar(
    SnackBar(content: Text('Resep "${resep.nama}" dihapus')),
  );
  return true;
}
