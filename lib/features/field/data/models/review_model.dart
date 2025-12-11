class ReviewModel {
  final String namaPengguna;
  final double rating;
  final String komentar;
  final DateTime tanggalUlasan;
  final String? fotoPengguna; // Tambahan: Foto User

  ReviewModel({
    required this.namaPengguna,
    required this.rating,
    required this.komentar,
    required this.tanggalUlasan,
    this.fotoPengguna,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      // Backend: p.Nama_lengkap
      namaPengguna: json['Nama_lengkap']?.toString() ?? 'Pengguna',

      // Backend: u.Rating
      rating: double.tryParse(json['Rating']?.toString() ?? '0') ?? 0.0,

      // Backend: u.Komentar
      komentar: json['Komentar']?.toString() ?? '',

      // Backend: u.Dibuat_pada
      tanggalUlasan:
          DateTime.tryParse(json['Dibuat_pada']?.toString() ?? '') ??
          DateTime.now(),

      // Backend: Foto_pengguna (Alias dari query SQL kamu)
      fotoPengguna: json['Foto_pengguna']?.toString(),
    );
  }
}
