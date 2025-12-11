class UserModel {
  final String id;
  final String namaLengkap;
  final String email;
  final String role;
  final String? fotoUrl;

  UserModel({
    required this.id,
    required this.namaLengkap,
    required this.email,
    required this.role,
    this.fotoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // BACA SEGALA KEMUNGKINAN KEY ID
      id: json['id']?.toString() ?? json['Id_pengguna']?.toString() ?? '0',

      // BACA SEGALA KEMUNGKINAN KEY NAMA
      namaLengkap:
          json['nama_lengkap']?.toString() ??
          json['Nama_lengkap']?.toString() ??
          'User Tanpa Nama',

      // BACA SEGALA KEMUNGKINAN KEY EMAIL
      email:
          json['email']?.toString() ??
          json['Email']?.toString() ??
          'Email Tidak Ditemukan',

      // BACA SEGALA KEMUNGKINAN KEY ROLE
      role: json['role']?.toString() ?? json['Role']?.toString() ?? 'Customer',

      // BACA FOTO
      fotoUrl: json['foto_url']?.toString() ?? json['Url_foto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'email': email,
      'role': role,
      'foto_url': fotoUrl,
    };
  }
}
