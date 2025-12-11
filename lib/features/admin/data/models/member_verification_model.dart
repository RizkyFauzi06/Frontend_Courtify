class MemberVerificationModel {
  final int id; // Id_langganan
  final String namaUser;
  final String namaPaket;
  final double harga;
  final String? buktiUrl;

  MemberVerificationModel({
    required this.id,
    required this.namaUser,
    required this.namaPaket,
    required this.harga,
    this.buktiUrl,
  });

  factory MemberVerificationModel.fromJson(Map<String, dynamic> json) {
    return MemberVerificationModel(
      id: int.tryParse(json['Id_langganan']?.toString() ?? '0') ?? 0,
      
      // Backend: U.Nama_lengkap
      namaUser: json['Nama_lengkap']?.toString() ?? 'User',
      
      // Backend: T.Nama_tingkatan
      namaPaket: json['Nama_tingkatan']?.toString() ?? 'Paket',
      
      // Backend: T.Harga_bulanan
      harga: double.tryParse(json['Harga_bulanan']?.toString() ?? '0') ?? 0.0,
      
      // Backend: L.Url_bukti_bayar
      buktiUrl: json['Url_bukti_bayar']?.toString(),
    );
  }
}