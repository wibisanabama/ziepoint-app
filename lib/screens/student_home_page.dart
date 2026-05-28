import 'package:flutter/material.dart';
import '../models/siswa.dart';
import 'jenis_catatan_page.dart';
import 'login_page.dart';

class StudentHomePage extends StatefulWidget {
  final Siswa siswa;
  const StudentHomePage({super.key, required this.siswa});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  // Mock point history for premium dashboard look
  final List<Map<String, dynamic>> _recentActivities = [
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
          'Beranda Siswa',
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
            // Student Welcome Card
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: const Color(0xFF8A6E6A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Datang,',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.siswa.nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          widget.siswa.kelas,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white30, height: 1),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NOMOR INDUK SISWA (NIS)',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.siswa.nis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Quick Navigation Cards Section
            const Text(
              'Menu ZiePoint',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF151C3B),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMenuCard(
                    title: 'Jenis\nPelanggaran',
                    subtitle: 'Skor Poin Penalti',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFB71C1C),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JenisCatatanPage(
                            tipe: 'pelanggaran',
                            role: 'siswa',
                            siswa: widget.siswa,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMenuCard(
                    title: 'Jenis\nPrestasi',
                    subtitle: 'Skor Poin Hadiah',
                    icon: Icons.emoji_events_outlined,
                    color: const Color(0xFF43A047),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JenisCatatanPage(
                            tipe: 'prestasi',
                            role: 'siswa',
                            siswa: widget.siswa,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Activity History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Catatan Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF151C3B),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(color: Color(0xFF8A6E6A)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // List of Recent Activities
            ..._recentActivities.map((activity) => _buildActivityTile(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF2ECEB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF151C3B),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    final bool isPositive = activity['isPositive'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
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
                    color: Colors.grey.shade500,
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
