import 'package:flutter/material.dart';

import '../model/resep.dart';
import 'gambar_resep.dart';

class KartuResep extends StatelessWidget {
  final Resep resep;
  final VoidCallback saatDitekan;
  final VoidCallback? saatEdit;
  final VoidCallback? saatHapus;

  const KartuResep({
    super.key,
    required this.resep,
    required this.saatDitekan,
    this.saatEdit,
    this.saatHapus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: saatDitekan,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GambarResep(url: resep.gambar, width: 80, height: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resep.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            resep.kategori,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.timer_outlined, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${resep.waktuMasak} mnt',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      resep.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (saatEdit != null || saatHapus != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') saatEdit?.call();
                    if (value == 'delete') saatHapus?.call();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
