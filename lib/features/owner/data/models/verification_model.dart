class VerificationModel {
  final int id;
  final String customerName;
  final String fieldName;
  final double total;
  final String proofUrl;

  VerificationModel({
    required this.id,
    required this.customerName,
    required this.fieldName,
    required this.total,
    required this.proofUrl,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) {
    // Helper function biar parsing aman (String/Int/Double friendly)
    int toInt(dynamic val) => int.tryParse(val.toString()) ?? 0;
    double toDouble(dynamic val) => double.tryParse(val.toString()) ?? 0.0;

    return VerificationModel(
      // Sesuai Key dari Query SQL Backend kamu
      id: toInt(json['Id_pemesanan']),

      customerName: json['Nama_customer']?.toString() ?? 'Customer',

      fieldName: json['Nama_lapangan']?.toString() ?? 'Lapangan',

      total: toDouble(json['Total_harga']),

      proofUrl: json['Url_bukti_bayar']?.toString() ?? '',
    );
  }
}
