import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _fetchSiswa();
    _scrollController.addListener(() {
      if (_scrollController.offset > 10) {
        if (!_isScrolled) {
          setState(() {
            _isScrolled = true;
          });
        }
      } else {
        if (_isScrolled) {
          setState(() {
            _isScrolled = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $errorMsg')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool?> _confirmDeleteDialog(int id) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content:
              const Text("Apakah Anda yakin ingin menghapus data siswa ini?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSiswaSilently(int id) async {
    try {
      await _apiService.deleteSiswa(id);
      _fetchSiswa();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data siswa berhasil dihapus')),
      );
    } catch (e) {
      _fetchSiswa();
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: $errorMsg')),
      );
    }
  }

  void _showDetailBottomSheet(Siswa siswa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        colorScheme.primary.withValues(alpha: 0.15),
                    radius: 24,
                    child: Icon(Icons.person,
                        color: colorScheme.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          siswa.nama,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelas ${siswa.kelas}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOMOR INDUK SISWA (NIS)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          siswa.nis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (siswa.password != null && siswa.password!.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PASSWORD AKSES',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            siswa.password!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 36),
              if (widget.role == 'guru') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showFormDialog(siswa: siswa);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('EDIT DATA SISWA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  'TUTUP',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFormDialog({Siswa? siswa}) {
    final isEditing = siswa != null;
    final namaController =
        TextEditingController(text: isEditing ? siswa.nama : '');
    final kelasController =
        TextEditingController(text: isEditing ? siswa.kelas : '');
    final nisController =
        TextEditingController(text: isEditing ? siswa.nis : '');
    final passwordController =
        TextEditingController(text: isEditing ? (siswa.password ?? '') : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(sheetContext).colorScheme.primary,
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
                  keyboardType: TextInputType.number,
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
                        const SnackBar(
                            content: Text('Semua kolom harus diisi')),
                      );
                      return;
                    }

                    final newSiswa = Siswa(
                      id: isEditing ? siswa.id : null,
                      nama: namaController.text,
                      kelas: kelasController.text,
                      nis: nisController.text,
                      password: passwordController.text.isNotEmpty
                          ? passwordController.text
                          : null,
                    );

                    try {
                      if (isEditing) {
                        await _apiService.updateSiswa(newSiswa);
                      } else {
                        await _apiService.createSiswa(newSiswa);
                      }
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing
                              ? 'Data berhasil diupdate'
                              : 'Data berhasil ditambah'),
                        ),
                      );

                      if (!sheetContext.mounted) return;
                      Navigator.of(sheetContext).pop();
                      _fetchSiswa();
                    } catch (e) {
                      if (!mounted) return;
                      final errorMsg =
                          e.toString().replaceAll('Exception: ', '');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Gagal menyimpan data: $errorMsg')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(sheetContext).colorScheme.primary,
                    foregroundColor:
                        Theme.of(sheetContext).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'SIMPAN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
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
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Siswa',
          style: TextStyle(
            color: _isScrolled ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: _isScrolled ? colorScheme.primary : Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _siswaList.isEmpty
              ? const Center(child: Text('Tidak ada data siswa'))
              : ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    for (int i = 0; i < _siswaList.length; i++)
                      _buildSiswaTile(_siswaList[i], i, _siswaList.length),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: colorScheme.primary,
        elevation: 0,
        highlightElevation: 0,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildSiswaTile(Siswa siswa, int index, int total) {
    final colorScheme = Theme.of(context).colorScheme;

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

    Widget tileContent = GestureDetector(
      onTap: () => _showDetailBottomSheet(siswa),
      child: Container(
        margin: EdgeInsets.only(bottom: index == total - 1 ? 0 : 2.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siswa.nama,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${siswa.kelas} • NIS: ${siswa.nis}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.role == 'guru') {
      return Dismissible(
        key: ValueKey(siswa.id ?? siswa.nis),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: borderRadius,
          ),
          child:
              const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: borderRadius,
          ),
          child:
              const Icon(Icons.delete_outline, color: Colors.white, size: 28),
        ),
        confirmDismiss: (direction) async {
          if (siswa.id != null) {
            return await _confirmDeleteDialog(siswa.id!);
          }
          return false;
        },
        onDismissed: (direction) {
          if (siswa.id != null) {
            _deleteSiswaSilently(siswa.id!);
          }
        },
        child: tileContent,
      );
    } else {
      return tileContent;
    }
  }
}
