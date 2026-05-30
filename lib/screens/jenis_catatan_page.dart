import 'package:flutter/material.dart';
import '../models/jenis_catatan.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';

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
      if (poin >= 75) return const Color(0xFFB71C1C); // Dark red for severe
      if (poin >= 40) return const Color(0xFFE64A19); // Orange-red for moderate
      return const Color(0xFFEF5350); // Soft red for minor
    }
  }

  String _getBadgeText(int poin) {
    return widget.tipe == 'prestasi' ? '+$poin Poin' : '-$poin Poin';
  }

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
          widget.tipe == 'prestasi' ? 'Jenis Prestasi' : 'Jenis Pelanggaran',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tipe == 'prestasi' 
                              ? 'Daftar Kriteria\nPrestasi'
                              : 'Daftar Kriteria\nPelanggaran',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
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
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // List of items (Segmented filled containers with position-based border radii)
                  if (_catatanList.isEmpty)
                    Center(child: Text('Tidak ada data jenis ${widget.tipe}'))
                  else
                    Column(
                      children: [
                        for (int i = 0; i < _catatanList.length; i++)
                          _buildCatatanTile(_catatanList[i], i, _catatanList.length),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildCatatanTile(JenisCatatan catatan, int index, int total) {
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
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
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
