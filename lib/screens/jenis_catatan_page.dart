import 'package:flutter/material.dart';
import '../models/jenis_catatan.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class JenisCatatanPage extends StatefulWidget {
  final String tipe; // 'pelanggaran' or 'prestasi'
  final String role;
  final Siswa? siswa;
  const JenisCatatanPage({super.key, required this.tipe, required this.role, this.siswa});

  @override
  State<JenisCatatanPage> createState() => _JenisCatatanPageState();
}

class _JenisCatatanPageState extends State<JenisCatatanPage> {
  final ApiService _apiService = ApiService();
  List<JenisCatatan> _catatanList = [];
  bool _isLoading = true;

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
  void initState() {
    super.initState();
    _fetchCatatan();
  }

  Future<void> _fetchCatatan() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<JenisCatatan> catatan = await _apiService.fetchJenisCatatan(widget.tipe);
      if (mounted) {
        setState(() {
          _catatanList = catatan;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getBadgeColor(int poin) {
    if (widget.tipe == 'prestasi') {
      if (poin >= 50) return const Color(0xFFFBC02D); // Gold
      if (poin >= 20) return const Color(0xFF43A047); // Green
      return const Color(0xFF1E88E5); // Blue
    } else {
      if (poin >= 75) return const Color(0xFFB71C1C); // Red for severe
      if (poin >= 40) return const Color(0xFFE64A19); // Orange for moderate
      return const Color(0xFF1A237E); // Dark blue for minor
    }
  }

  String _getBadgeText(int poin) {
    return widget.tipe == 'prestasi' ? '+$poin Poin' : '-$poin Poin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Very light blue-grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF37474F)), // Dark grey/blue icon
        title: Text(
          widget.tipe == 'prestasi' ? 'Jenis Prestasi' : 'Jenis Pelanggaran',
          style: const TextStyle(
            color: Color(0xFF151C3B), // Dark Navy Blue
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
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF37474F),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchCatatan,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Header Card (Filled, no shadow, no border)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24.0),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECEB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tipe == 'prestasi' 
                              ? 'Daftar Kriteria\nPrestasi'
                              : 'Daftar Kriteria\nPelanggaran',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF151C3B), // Dark Navy Blue
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.tipe == 'prestasi'
                              ? 'Panduan poin penghargaan resmi untuk\nprestasi siswa ZiePoint.'
                              : 'Panduan poin penalti resmi untuk\nkedisiplinan siswa ZiePoint.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // List of items (Segmented filled container with no shadow and no outer border)
                  if (_catatanList.isEmpty)
                    Center(child: Text('Tidak ada data jenis ${widget.tipe}'))
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2ECEB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < _catatanList.length; i++) ...[
                            _buildCatatanTile(_catatanList[i]),
                            if (i < _catatanList.length - 1)
                              const Divider(
                                color: Colors.white30,
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCatatanTile(JenisCatatan catatan) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  catatan.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF151C3B), // Dark Navy Blue
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getBadgeColor(catatan.poin),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getBadgeText(catatan.poin),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            catatan.deskripsi,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
