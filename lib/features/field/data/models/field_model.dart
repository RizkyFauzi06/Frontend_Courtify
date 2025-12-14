class FieldModel {
  final int id;
  final int ownerId;
  final String nama;
  final String tipe;
  final String alamat;
  final String deskripsi;
  final double hargaPerJam;
  final String jamBuka;
  final String jamTutup;
  final List<String> foto;
  final String nomorRekening;

  FieldModel({
    required this.id,
    required this.ownerId,
    required this.nama, // semua hal yang dibutuhkan untuk membuat lapangan,
    required this.tipe,
    required this.alamat,
    required this.deskripsi,
    required this.hargaPerJam,
    required this.jamBuka,
    required this.jamTutup,
    required this.foto,
    required this.nomorRekening,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    // menerima JSON backend dan mengubahnya ke Objek
    List<String> parsedFoto = [];
    if (json['semua_foto'] != null &&
        json['semua_foto'].toString().isNotEmpty) {
      parsedFoto = json['semua_foto'].toString().split(
        ',',
      ); // menerima foto dengan kasus file backend ada koma
    } else if (json['foto_lapangan'] != null && json['foto_lapangan'] is List) {
      parsedFoto = (json['foto_lapangan'] as List)
          .map((e) => e['Url_foto'].toString())
          .toList(); // file nya JSON
    }

    return FieldModel(
      id:
          int.tryParse(json['Id_lapangan']?.toString() ?? '0') ??
          0, // ngambil nilai dari DB
      nomorRekening: json['Nomor_rekening']?.toString() ?? '-',

      // AMBIL ID PEMILIK DARI JSON
      ownerId: int.tryParse(json['Id_pemilik']?.toString() ?? '0') ?? 0,

      nama: json['Nama_lapangan']?.toString() ?? 'Tanpa Nama',
      tipe: json['Tipe_lapangan']?.toString() ?? '-',
      alamat: json['Alamat']?.toString() ?? '-',
      deskripsi: json['Deskripsi']?.toString() ?? '',
      hargaPerJam:
          double.tryParse(json['Harga_per_jam']?.toString() ?? '0') ?? 0.0,
      jamBuka: json['Jam_buka_operasional']?.toString() ?? '08:00',
      jamTutup: json['Jam_tutup_operasional']?.toString() ?? '22:00',
      foto: parsedFoto,
    );
  }

  String get coverFoto => foto.isNotEmpty
      ? foto.first
      : ''; // foto pertama foto lapangan, foto kosong kosong
}
