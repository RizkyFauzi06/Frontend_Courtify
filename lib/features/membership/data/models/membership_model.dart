class MembershipModel {
  final int id;
  final String nama;
  final double harga;
  final double diskon;

  MembershipModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.diskon,
  });

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    // Helper parse biar gak crash
    double toDouble(dynamic val) => double.tryParse(val.toString()) ?? 0.0;
    int toInt(dynamic val) => int.tryParse(val.toString()) ?? 0;

    return MembershipModel(
      // Backend: Id_tingkatan
      id: toInt(json['Id_tingkatan']),
      
      // Backend: Nama_tingkatan
      nama: json['Nama_tingkatan']?.toString() ?? 'Paket',
      
      // Backend: Harga_bulanan
      harga: toDouble(json['Harga_bulanan']),
      
      // Backend: Persen_diskon
      diskon: toDouble(json['Persen_diskon']),
    );
  }
}