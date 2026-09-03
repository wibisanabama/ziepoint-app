import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/siswa.dart';
import '../models/guru.dart';
import '../models/jenis_catatan.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000';

  Future<List<Siswa>> fetchSiswa() async {
    final response = await http.get(Uri.parse('$baseUrl/siswa'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Siswa.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data siswa');
    }
  }

  Future<List<JenisCatatan>> fetchJenisCatatan(String tipe) async {
    final response = await http.get(Uri.parse('$baseUrl/jenis_catatan/$tipe'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => JenisCatatan.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat jenis catatan');
    }
  }

  Future<Siswa> loginSiswa(String nis, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'nis': nis, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Siswa.fromJson(data['user']);
    } else {
      throw Exception('NIS atau Password salah!');
    }
  }

  Future<Guru> loginGuru(String nip, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login_guru'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'nip': nip, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Guru.fromJson(data['user']);
    } else {
      throw Exception('NIP atau Password salah!');
    }
  }

  String _parseError(http.Response response, String defaultMsg) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('error')) {
        return body['error'].toString();
      }
    } catch (_) {}
    return defaultMsg;
  }

  Future<Siswa> createSiswa(Siswa siswa) async {
    final response = await http.post(
      Uri.parse('$baseUrl/siswa'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(siswa.toJson()),
    );
    if (response.statusCode == 200) {
      return Siswa(
        id: jsonDecode(response.body)['id'],
        nama: siswa.nama,
        kelas: siswa.kelas,
        nis: siswa.nis,
      );
    } else {
      throw Exception(_parseError(response, 'Gagal menambahkan siswa'));
    }
  }

  Future<void> updateSiswa(Siswa siswa) async {
    final response = await http.put(
      Uri.parse('$baseUrl/siswa/${siswa.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(siswa.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response, 'Gagal mengupdate siswa'));
    }
  }

  Future<void> deleteSiswa(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/siswa/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response, 'Gagal menghapus siswa'));
    }
  }

  Future<JenisCatatan> createJenisCatatan(JenisCatatan jenis) async {
    final response = await http.post(
      Uri.parse('$baseUrl/jenis_catatan'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(jenis.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return JenisCatatan(
        idJenis: data['id'],
        nama: jenis.nama,
        deskripsi: jenis.deskripsi,
        tipe: jenis.tipe,
        poin: jenis.poin,
      );
    } else {
      throw Exception(_parseError(response, 'Gagal menambahkan kriteria'));
    }
  }

  Future<void> updateJenisCatatan(JenisCatatan jenis) async {
    final response = await http.put(
      Uri.parse('$baseUrl/jenis_catatan/${jenis.idJenis}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(jenis.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response, 'Gagal mengupdate kriteria'));
    }
  }

  Future<void> deleteJenisCatatan(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/jenis_catatan/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response, 'Gagal menghapus kriteria'));
    }
  }

  Future<void> createCatatan({
    int? idGuru,
    required int idSiswa,
    required int idJenis,
    String? tanggal,
    String? keterangan,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/catatan'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'id_guru': idGuru,
        'id_siswa': idSiswa,
        'id_jenis': idJenis,
        'tanggal': tanggal,
        'keterangan': keterangan,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception(_parseError(response, 'Gagal menyimpan catatan'));
    }
  }

  Future<List<Map<String, dynamic>>> fetchCatatanSiswa(int idSiswa) async {
    final response =
        await http.get(Uri.parse('$baseUrl/catatan/siswa/$idSiswa'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) {
        final Map<String, dynamic> row = item as Map<String, dynamic>;
        final String tipe = row['kriteria_tipe']?.toString() ?? 'pelanggaran';
        final int poin = row['kriteria_poin'] ?? 0;
        final bool isPositive = tipe.toLowerCase() == 'prestasi';

        String displayDate = row['tanggal']?.toString() ?? '';
        try {
          final parsedDate = DateTime.parse(displayDate).toLocal();
          final months = [
            'Januari',
            'Februari',
            'Maret',
            'April',
            'Mei',
            'Juni',
            'Juli',
            'Agustus',
            'September',
            'Oktober',
            'November',
            'Desember'
          ];
          displayDate =
              '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
        } catch (_) {}

        return {
          'title': row['kriteria_nama']?.toString() ?? '',
          'category': isPositive ? 'Prestasi' : 'Pelanggaran',
          'points': isPositive ? '+$poin Poin' : '-$poin Poin',
          'date': displayDate,
          'isPositive': isPositive,
          'keterangan': row['keterangan']?.toString() ?? '',
        };
      }).toList();
    } else {
      throw Exception(_parseError(response, 'Gagal memuat riwayat catatan'));
    }
  }
}
