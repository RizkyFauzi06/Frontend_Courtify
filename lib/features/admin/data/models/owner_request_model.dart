class OwnerRequestModel {
  final int idPengajuan;
  final String nama;
  final String email;
  final DateTime tanggal;
  final String status;
  final String bisnis;
  final String alasan;
  final String? urlKtp;

  OwnerRequestModel({
    required this.idPengajuan,
    required this.nama,
    required this.email,
    required this.tanggal,
    required this.status,
    required this.bisnis,
    required this.alasan,
    this.urlKtp,
  });

  factory OwnerRequestModel.fromJson(Map<String, dynamic> json) {
    return OwnerRequestModel(
      idPengajuan:
          int.tryParse(json['Id_pengajuan']?.toString() ?? '0') ??
          0, //parsing ngubah int ke string
      nama: json['Nama_lengkap']?.toString() ?? 'User',
      email: json['Email']?.toString() ?? '-',
      tanggal:
          DateTime.tryParse(json['Tgl_pengajuan']?.toString() ?? '') ??
          DateTime.now(),
      status: json['Status']?.toString() ?? '-',
      bisnis: json['Nama_bisnis']?.toString() ?? '-',
      alasan: json['Alasan']?.toString() ?? '-',
      urlKtp: json['Url_ktp']?.toString(),
    );
  }
}
