import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String role;
  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<Siswa> _siswaList = [];
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
    _fetchSiswa();
  }

  Future<void> _fetchSiswa() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<Siswa> siswa = await _apiService.fetchSiswa();
      setState(() {
        _siswaList = siswa;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSiswa(int id) async {
    try {
      await _apiService.deleteSiswa(id);
      _fetchSiswa();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: $e')),
      );
    }
  }

  void _showFormDialog({Siswa? siswa}) {
    final isEditing = siswa != null;
    final namaController = TextEditingController(text: isEditing ? siswa.nama : '');
    final kelasController = TextEditingController(text: isEditing ? siswa.kelas : '');
    final nisController = TextEditingController(text: isEditing ? siswa.nis : '');
    final passwordController = TextEditingController(text: isEditing ? (siswa.password ?? '') : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Update Data Siswa' : 'Tambah Data Siswa',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A6E6A),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: namaController,
                  label: 'Nama Lengkap',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: kelasController,
                  label: 'Kelas',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: nisController,
                  label: 'NIS',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: passwordController,
                  label: 'Password',
                  obscureText: false,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (namaController.text.isEmpty ||
                        kelasController.text.isEmpty ||
                        nisController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Semua kolom harus diisi')),
                      );
                      return;
                    }

                    final newSiswa = Siswa(
                      id: isEditing ? siswa.id : null,
                      nama: namaController.text,
                      kelas: kelasController.text,
                      nis: nisController.text,
                      password: passwordController.text.isNotEmpty ? passwordController.text : null,
                    );

                    try {
                      if (isEditing) {
                        await _apiService.updateSiswa(newSiswa);
                      } else {
                        await _apiService.createSiswa(newSiswa);
                      }
                      if (!context.mounted) return;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing ? 'Data berhasil diupdate' : 'Data berhasil ditambah'),
                        ),
                      );
                      
                      Navigator.of(context).pop();
                      _fetchSiswa();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal menyimpan data: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD3AFAE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SIMPAN',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Color(0xFF8A6E6A)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8A6E6A),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _showLogoutDialog,
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white24,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _siswaList.isEmpty
              ? const Center(child: Text('Tidak ada data siswa'))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2ECEB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < _siswaList.length; i++) ...[
                            _buildSiswaTile(_siswaList[i]),
                            if (i < _siswaList.length - 1)
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
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFF8A6E6A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSiswaTile(Siswa siswa) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswa.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF151C3B), // Navy blue
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${siswa.kelas} • NIS: ${siswa.nis}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF8A6E6A)),
            onPressed: () => _showFormDialog(siswa: siswa),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text("Yakin ingin menghapus data ini?"),
                    actions: [
                      TextButton(
                        child: const Text("Batal"),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (siswa.id != null) {
                            _deleteSiswa(siswa.id!);
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
