import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../models/jenis_catatan.dart';
import '../models/guru.dart';
import '../services/api_service.dart';

class InputCatatanPage extends StatefulWidget {
  final Guru? guru;
  const InputCatatanPage({super.key, this.guru});

  @override
  State<InputCatatanPage> createState() => _InputCatatanPageState();
}

class _InputCatatanPageState extends State<InputCatatanPage> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  List<Siswa> _siswaList = [];
  List<JenisCatatan> _pelanggaranList = [];
  List<JenisCatatan> _prestasiList = [];

  Siswa? _selectedSiswa;
  String _selectedCategory = 'pelanggaran';
  JenisCatatan? _selectedKriteria;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final siswa = await _apiService.fetchSiswa();
      final pelanggaran = await _apiService.fetchJenisCatatan('pelanggaran');
      final prestasi = await _apiService.fetchJenisCatatan('prestasi');

      setState(() {
        _siswaList = siswa;
        _pelanggaranList = pelanggaran;
        _prestasiList = prestasi;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  List<JenisCatatan> get _activeCriteriaList {
    return _selectedCategory == 'pelanggaran'
        ? _pelanggaranList
        : _prestasiList;
  }

  void _showSiswaSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final colorScheme = Theme.of(context).colorScheme;
            final filteredSiswa = _siswaList.where((s) {
              return s.nama
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  s.nis.contains(_searchQuery) ||
                  s.kelas.toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.65,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pilih Siswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (val) {
                        setSheetState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama, kelas, atau NIS...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredSiswa.isEmpty
                          ? const Center(
                              child: Text('Tidak ada data siswa ditemukan'))
                          : ListView.builder(
                              itemCount: filteredSiswa.length,
                              itemBuilder: (context, index) {
                                final s = filteredSiswa[index];
                                final isSelected = _selectedSiswa?.id == s.id;

                                BorderRadius borderRadius;
                                if (filteredSiswa.length == 1) {
                                  borderRadius = BorderRadius.circular(16);
                                } else if (index == 0) {
                                  borderRadius = const BorderRadius.vertical(
                                      top: Radius.circular(16));
                                } else if (index == filteredSiswa.length - 1) {
                                  borderRadius = const BorderRadius.vertical(
                                      bottom: Radius.circular(16));
                                } else {
                                  borderRadius = BorderRadius.zero;
                                }

                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: index == filteredSiswa.length - 1
                                          ? 0
                                          : 2.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primary
                                            .withValues(alpha: 0.15)
                                        : colorScheme.surfaceContainer,
                                    borderRadius: borderRadius,
                                    border: isSelected
                                        ? Border.all(
                                            color: colorScheme.primary,
                                            width: 1.5)
                                        : null,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.primary
                                              .withValues(alpha: 0.15),
                                      child: Icon(
                                        Icons.person,
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.primary,
                                      ),
                                    ),
                                    title: Text(
                                      s.nama,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${s.kelas} • NIS: ${s.nis}',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _selectedSiswa = s;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _searchQuery = '';
    });
  }

  void _showKriteriaSelectionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        final list = _activeCriteriaList;

        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _selectedCategory == 'pelanggaran'
                    ? 'Pilih Kriteria Pelanggaran'
                    : 'Pilih Kriteria Prestasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('Tidak ada kriteria tersedia'))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final k = list[index];
                          final isSelected =
                              _selectedKriteria?.idJenis == k.idJenis;
                          final badgeColor = _selectedCategory == 'pelanggaran'
                              ? const Color(0xFFB71C1C)
                              : const Color(0xFF43A047);

                          BorderRadius borderRadius;
                          if (list.length == 1) {
                            borderRadius = BorderRadius.circular(16);
                          } else if (index == 0) {
                            borderRadius = const BorderRadius.vertical(
                                top: Radius.circular(16));
                          } else if (index == list.length - 1) {
                            borderRadius = const BorderRadius.vertical(
                                bottom: Radius.circular(16));
                          } else {
                            borderRadius = BorderRadius.zero;
                          }

                          return Container(
                            margin: EdgeInsets.only(
                                bottom: index == list.length - 1 ? 0 : 2.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.15)
                                  : colorScheme.surfaceContainer,
                              borderRadius: borderRadius,
                              border: isSelected
                                  ? Border.all(
                                      color: colorScheme.primary, width: 1.5)
                                  : null,
                            ),
                            child: ListTile(
                              title: Text(
                                k.nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  k.deskripsi,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _selectedCategory == 'pelanggaran'
                                      ? '-${k.poin} Poin'
                                      : '+${k.poin} Poin',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedKriteria = k;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(Siswa siswa, JenisCatatan kriteria) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Success',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final colorScheme = Theme.of(context).colorScheme;
        final isPrestasi = _selectedCategory == 'prestasi';
        final themeColor =
            isPrestasi ? const Color(0xFF43A047) : const Color(0xFFB71C1C);

        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isPrestasi
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: themeColor,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Catatan Berhasil Disimpan!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            colorScheme.primary.withValues(alpha: 0.15),
                        radius: 18,
                        child: Icon(Icons.person,
                            color: colorScheme.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              siswa.nama,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kelas ${siswa.kelas} • NIS ${siswa.nis}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              kriteria.nama,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isPrestasi
                                  ? '+${kriteria.poin} Poin'
                                  : '-${kriteria.poin} Poin',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        kriteria.deskripsi,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'OKE',
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  Future<void> _submitCatatan() async {
    if (_selectedSiswa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih siswa terlebih dahulu')),
      );
      return;
    }
    if (_selectedKriteria == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kriteria terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.createCatatan(
        idGuru: widget.guru?.id,
        idSiswa: _selectedSiswa!.id!,
        idJenis: _selectedKriteria!.idJenis!,
        keterangan: _selectedKriteria!.nama,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      _showSuccessDialog(_selectedSiswa!, _selectedKriteria!);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan catatan: $errorMsg')),
      );
    }
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
          'Input Catatan Siswa',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catat Poin Siswa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gunakan menu ini untuk menambahkan poin prestasi atau mencatat poin pelanggaran untuk siswa sekolah.',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pilih Siswa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showSiswaSelectionSheet,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _selectedSiswa == null
                          ? Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Icon(Icons.person_add_alt_1_outlined,
                                      color: colorScheme.primary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Pilih data siswa...',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: colorScheme.onSurfaceVariant),
                              ],
                            )
                          : Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorScheme.primary
                                      .withValues(alpha: 0.15),
                                  child: Icon(Icons.person,
                                      color: colorScheme.primary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedSiswa!.nama,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Kelas ${_selectedSiswa!.kelas} • NIS ${_selectedSiswa!.nis}',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.edit_outlined,
                                    color: colorScheme.primary, size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Kategori Catatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'pelanggaran';
                              _selectedKriteria = null;
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedCategory == 'pelanggaran'
                                  ? const Color(0xFFB71C1C)
                                  : colorScheme.surfaceContainer,
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(24)),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: _selectedCategory == 'pelanggaran'
                                        ? Colors.white
                                        : colorScheme.onSurfaceVariant,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pelanggaran',
                                    style: TextStyle(
                                      color: _selectedCategory == 'pelanggaran'
                                          ? Colors.white
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = 'prestasi';
                              _selectedKriteria = null;
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: _selectedCategory == 'prestasi'
                                  ? const Color(0xFF43A047)
                                  : colorScheme.surfaceContainer,
                              borderRadius: const BorderRadius.horizontal(
                                  right: Radius.circular(24)),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    color: _selectedCategory == 'prestasi'
                                        ? Colors.white
                                        : colorScheme.onSurfaceVariant,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Prestasi',
                                    style: TextStyle(
                                      color: _selectedCategory == 'prestasi'
                                          ? Colors.white
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pilih Kriteria',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showKriteriaSelectionSheet,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _selectedKriteria == null
                          ? Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  child: Icon(Icons.assignment_outlined,
                                      color: colorScheme.primary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Pilih jenis kriteria...',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Icon(Icons.chevron_right,
                                    color: colorScheme.onSurfaceVariant),
                              ],
                            )
                          : Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      (_selectedCategory == 'pelanggaran'
                                              ? const Color(0xFFB71C1C)
                                              : const Color(0xFF43A047))
                                          .withValues(alpha: 0.15),
                                  child: Icon(
                                    _selectedCategory == 'pelanggaran'
                                        ? Icons.warning_amber_rounded
                                        : Icons.emoji_events_outlined,
                                    color: _selectedCategory == 'pelanggaran'
                                        ? const Color(0xFFB71C1C)
                                        : const Color(0xFF43A047),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedKriteria!.nama,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedKriteria!.deskripsi,
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _selectedCategory == 'pelanggaran'
                                        ? const Color(0xFFB71C1C)
                                        : const Color(0xFF43A047),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _selectedCategory == 'pelanggaran'
                                        ? '-${_selectedKriteria!.poin} Poin'
                                        : '+${_selectedKriteria!.poin} Poin',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submitCatatan,
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
                      'SIMPAN CATATAN',
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
  }
}
