import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/jenis_catatan.dart';
import '../models/siswa.dart';
import '../services/api_service.dart';

class JenisCatatanPage extends StatefulWidget {
  final String tipe;
  final String role;
  final Siswa? siswa;
  const JenisCatatanPage(
      {super.key, required this.tipe, required this.role, this.siswa});

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
      final List<JenisCatatan> catatan =
          await _apiService.fetchJenisCatatan(widget.tipe);
      if (mounted) {
        setState(() {
          _catatanList = catatan;
        });
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $errorMsg')),
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
      return const Color(0xFF43A047);
    } else {
      return const Color(0xFFB71C1C);
    }
  }

  String _getBadgeText(int poin) {
    return widget.tipe == 'prestasi' ? '+$poin Poin' : '-$poin Poin';
  }

  Future<bool?> _confirmDeleteDialog(int id) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content:
              const Text("Apakah Anda yakin ingin menghapus kriteria ini?"),
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

  Future<void> _deleteCatatanSilently(int id) async {
    try {
      await _apiService.deleteJenisCatatan(id);
      _fetchCatatan();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kriteria berhasil dihapus')),
      );
    } catch (e) {
      _fetchCatatan();
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus kriteria: $errorMsg')),
      );
    }
  }

  void _showDetailBottomSheet(JenisCatatan catatan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        final isPrestasi = catatan.tipe == 'prestasi';
        final themeColor =
            isPrestasi ? const Color(0xFF43A047) : const Color(0xFFB71C1C);

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isPrestasi ? 'Detail Prestasi' : 'Detail Pelanggaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeColor,
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
                catatan.nama,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'DESKRIPSI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                catatan.deskripsi,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              if (widget.role == 'guru') ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showFormDialog(jenis: catatan);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('EDIT KRITERIA'),
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

  void _showFormDialog({JenisCatatan? jenis}) {
    final isEditing = jenis != null;
    final namaController =
        TextEditingController(text: isEditing ? jenis.nama : '');
    final deskripsiController =
        TextEditingController(text: isEditing ? jenis.deskripsi : '');
    final poinController =
        TextEditingController(text: isEditing ? jenis.poin.toString() : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        final colorScheme = Theme.of(sheetContext).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Edit Kriteria' : 'Tambah Kriteria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildFormTextField(
                  controller: namaController,
                  label: 'Nama Kriteria',
                ),
                const SizedBox(height: 12),
                _buildFormTextField(
                  controller: deskripsiController,
                  label: 'Deskripsi',
                ),
                const SizedBox(height: 12),
                _buildFormTextField(
                  controller: poinController,
                  label: 'Jumlah Poin',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (namaController.text.isEmpty ||
                        textEmpty(deskripsiController.text) ||
                        poinController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Semua kolom harus diisi')),
                      );
                      return;
                    }

                    final int? poin = int.tryParse(poinController.text);
                    if (poin == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Poin harus berupa angka valid')),
                      );
                      return;
                    }

                    final newJenis = JenisCatatan(
                      idJenis: isEditing ? jenis.idJenis : null,
                      nama: namaController.text,
                      deskripsi: deskripsiController.text,
                      tipe: widget.tipe,
                      poin: poin,
                    );

                    try {
                      if (isEditing) {
                        await _apiService.updateJenisCatatan(newJenis);
                      } else {
                        await _apiService.createJenisCatatan(newJenis);
                      }
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEditing
                              ? 'Kriteria berhasil diperbarui'
                              : 'Kriteria berhasil ditambahkan'),
                        ),
                      );

                      if (!sheetContext.mounted) return;
                      Navigator.of(sheetContext).pop();
                      _fetchCatatan();
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
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
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

  bool textEmpty(String text) => text.trim().isEmpty;

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide:
              BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
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
                  if (_catatanList.isEmpty)
                    Center(child: Text('Tidak ada data jenis ${widget.tipe}'))
                  else
                    Column(
                      children: [
                        for (int i = 0; i < _catatanList.length; i++)
                          _buildCatatanTile(
                              _catatanList[i], i, _catatanList.length),
                      ],
                    ),
                ],
              ),
            ),
      floatingActionButton: widget.role == 'guru'
          ? FloatingActionButton(
              onPressed: () => _showFormDialog(),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              highlightElevation: 0,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildCatatanTile(JenisCatatan catatan, int index, int total) {
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
      onTap: () => _showDetailBottomSheet(catatan),
      child: Container(
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      ),
    );

    if (widget.role == 'guru') {
      return Dismissible(
        key: ValueKey(catatan.idJenis ?? catatan.nama),
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
          if (catatan.idJenis != null) {
            return await _confirmDeleteDialog(catatan.idJenis!);
          }
          return false;
        },
        onDismissed: (direction) {
          if (catatan.idJenis != null) {
            _deleteCatatanSilently(catatan.idJenis!);
          }
        },
        child: tileContent,
      );
    } else {
      return tileContent;
    }
  }
}
