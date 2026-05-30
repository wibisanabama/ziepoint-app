import 'package:flutter/material.dart';
import '../models/siswa.dart';

class RiwayatCatatanPage extends StatefulWidget {
  final Siswa siswa;
  const RiwayatCatatanPage({super.key, required this.siswa});

  @override
  State<RiwayatCatatanPage> createState() => _RiwayatCatatanPageState();
}

class _RiwayatCatatanPageState extends State<RiwayatCatatanPage> {
  // Full list of activities for student history
  final List<Map<String, dynamic>> _allActivities = [
    {
      'title': 'Mengikuti Lomba Kebersihan Kelas',
      'category': 'Prestasi',
      'points': '+15 Poin',
      'date': '27 Mei 2026',
      'isPositive': true,
    },
    {
      'title': 'Terlambat Masuk Sekolah (10 Menit)',
      'category': 'Pelanggaran',
      'points': '-10 Poin',
      'date': '25 Mei 2026',
      'isPositive': false,
    },
    {
      'title': 'Juara 1 Lomba Pidato Bahasa Inggris',
      'category': 'Prestasi',
      'points': '+50 Poin',
      'date': '18 Mei 2026',
      'isPositive': true,
    },
    {
      'title': 'Atribut Seragam Tidak Lengkap',
      'category': 'Pelanggaran',
      'points': '-15 Poin',
      'date': '12 Mei 2026',
      'isPositive': false,
    },
    {
      'title': 'Menjadi Petugas Upacara Bendera',
      'category': 'Prestasi',
      'points': '+20 Poin',
      'date': '10 Mei 2026',
      'isPositive': true,
    },
    {
      'title': 'Membuang Sampah Sembarangan',
      'category': 'Pelanggaran',
      'points': '-10 Poin',
      'date': '05 Mei 2026',
      'isPositive': false,
    },
    {
      'title': 'Membantu Rapihkan Buku Perpustakaan',
      'category': 'Prestasi',
      'points': '+10 Poin',
      'date': '02 Mei 2026',
      'isPositive': true,
    },
  ];


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        title: Text(
          'Riwayat Catatan',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info Card (Filled, no shadow)
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.siswa.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelas: ${widget.siswa.kelas} • NIS: ${widget.siswa.nis}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Seluruh Riwayat Aktivitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Segmented (filled) list container for all activities
            // Stack of segmented (filled) items with custom border radius per item
            Column(
              children: [
                for (int i = 0; i < _allActivities.length; i++)
                  _buildActivityTile(_allActivities[i], i, _allActivities.length),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity, int index, int total) {
    final bool isPositive = activity['isPositive'];
    final colorScheme = Theme.of(context).colorScheme;

    // Determine border radius based on position in the list
    BorderRadius borderRadius;
    if (total == 1) {
      borderRadius = BorderRadius.circular(16);
    } else if (index == 0) {
      borderRadius = const BorderRadius.vertical(top: Radius.circular(16));
    } else if (index == total - 1) {
      borderRadius = const BorderRadius.vertical(bottom: Radius.circular(16));
    } else {
      borderRadius = BorderRadius.zero;
    }

    return Container(
      margin: EdgeInsets.only(bottom: index == total - 1 ? 0 : 2.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: (isPositive ? const Color(0xFF43A047) : const Color(0xFFB71C1C)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                color: isPositive ? const Color(0xFF43A047) : const Color(0xFFB71C1C),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activity['category']} • ${activity['date']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              activity['points'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isPositive ? const Color(0xFF43A047) : const Color(0xFFB71C1C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
