import 'package:flutter/material.dart';
import '../models/siswa.dart';
import 'login_page.dart';

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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Keluar", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF37474F)),
        title: const Text(
          'Riwayat Catatan',
          style: TextStyle(
            color: Color(0xFF151C3B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _showLogoutDialog,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFD3AFAE).withValues(alpha: 0.3),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF8A6E6A),
                ),
              ),
            ),
          ),
        ],
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
                color: const Color(0xFF8A6E6A),
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

            const Text(
              'Seluruh Riwayat Aktivitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF151C3B),
              ),
            ),
            const SizedBox(height: 16),

            // Segmented (filled) list container for all activities
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2ECEB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < _allActivities.length; i++) ...[
                    _buildActivityTile(_allActivities[i]),
                    if (i < _allActivities.length - 1)
                      const Divider(
                        color: Colors.white30,
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    final bool isPositive = activity['isPositive'];
    return Padding(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF151C3B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity['category']} • ${activity['date']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
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
    );
  }
}
