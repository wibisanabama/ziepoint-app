class JenisCatatan {
  final int? idJenis;
  final String nama;
  final String deskripsi;
  final String tipe;
  final int poin;

  JenisCatatan({
    this.idJenis,
    required this.nama,
    required this.deskripsi,
    required this.tipe,
    required this.poin,
  });

  factory JenisCatatan.fromJson(Map<String, dynamic> json) {
    return JenisCatatan(
      idJenis: json['id_jenis'],
      nama: json['nama'],
      deskripsi: json['deskripsi'],
      tipe: json['tipe'],
      poin: json['poin'] is String ? int.parse(json['poin']) : json['poin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_jenis': idJenis,
      'nama': nama,
      'deskripsi': deskripsi,
      'tipe': tipe,
      'poin': poin,
    };
  }
}
