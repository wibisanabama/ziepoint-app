class Guru {
  final int? id;
  final String nama;
  final String nip;
  final String? password;

  Guru({
    this.id,
    required this.nama,
    required this.nip,
    this.password,
  });

  factory Guru.fromJson(Map<String, dynamic> json) {
    return Guru(
      id: json['id_guru'] ?? json['id'],
      nama: json['nama'],
      nip: json['nip']?.toString() ?? '',
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'nip': nip,
      if (password != null) 'password': password,
    };
  }
}
