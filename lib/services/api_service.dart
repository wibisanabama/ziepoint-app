import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/siswa.dart';
import '../models/guru.dart';
import '../models/jenis_catatan.dart';

class ApiService {
  // Ganti dengan alamat IP backend Anda jika dijalankan di perangkat fisik
  // Jika menggunakan emulator Android, gunakan 10.0.2.2
  // Jika menggunakan emulator iOS atau web, localhost sudah cukup
  static const String baseUrl = 'http://localhost:3000';

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

  Future<Siswa> createSiswa(Siswa siswa) async {
    final response = await http.post(
      Uri.parse('$baseUrl/siswa'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(siswa.toJson()),
    );
    if (response.statusCode == 200) {
      // API mengembalikan message dan id
      return Siswa(
        id: jsonDecode(response.body)['id'],
        nama: siswa.nama,
        kelas: siswa.kelas,
        nis: siswa.nis,
      );
    } else {
      throw Exception('Gagal menambahkan siswa');
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
      throw Exception('Gagal mengupdate siswa. Status: ${response.statusCode}, Error: ${response.body}');
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
      throw Exception('Gagal menghapus siswa');
    }
  }
}
