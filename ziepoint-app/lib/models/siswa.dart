class Siswa {
  final int? id;
  final String nama;
  final String kelas;
  final String nis;
  final String? password;

  Siswa({
    this.id,
    required this.nama,
    required this.kelas,
    required this.nis,
    this.password,
  });

  factory Siswa.fromJson(Map<String, dynamic> json) {
    return Siswa(
      id: json['id_siswa'] ?? json['id'],
      nama: json['nama'],
      kelas: json['kelas'],
      nis: json['nis']?.toString() ?? '',
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kelas': kelas,
      'nis': nis,
      if (password != null) 'password': password,
    };
  }
}
