class BookingHistoryModel {
  final int id;
  final int fieldId; // ID Lapangan (Penting buat Ulasan)
  final String namaLapangan;
  final String tipeLapangan;
  final DateTime waktuMulai;
  final DateTime waktuSelesai;
  final double totalHarga;
  final String status;
  final String? urlBuktiBayar;
  final String noRek;

  BookingHistoryModel({
    required this.id,
    required this.fieldId,
    required this.namaLapangan,
    required this.tipeLapangan,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.totalHarga,
    required this.status,
    this.urlBuktiBayar,
    required this.noRek,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    var rawFieldId = json['Id_lapangan'];
    int finalFieldId = 0;
    if (rawFieldId != null) {
      // Hapus semua karakter yang bukan angka, lalu parse
      finalFieldId =
          int.tryParse(
            rawFieldId.toString().replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;
    }

    // Buat ID Pemesanan
    var rawBookingId = json['Id_pemesanan'];
    int finalBookingId = 0;
    if (rawBookingId != null) {
      finalBookingId =
          int.tryParse(
            rawBookingId.toString().replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;
    }

    // LOGIKA HARGA
    var rawHarga = json['Total_harga'];
    double finalHarga = 0.0;
    if (rawHarga != null) {
      finalHarga = double.tryParse(rawHarga.toString()) ?? 0.0;
    }

    return BookingHistoryModel(
      id: finalBookingId, // Hasil parsing aman
      fieldId: finalFieldId, // Hasil parsing aman (Punya kamu)

      namaLapangan: json['Nama_lapangan']?.toString() ?? 'Lapangan',
      tipeLapangan: json['Tipe_lapangan']?.toString() ?? '-',

      waktuMulai:
          DateTime.tryParse(json['Waktu_mulai']?.toString() ?? '') ??
          DateTime.now(),
      waktuSelesai:
          DateTime.tryParse(json['Waktu_selesai']?.toString() ?? '') ??
          DateTime.now(),

      totalHarga: finalHarga,

      status: json['Status']?.toString() ?? 'unknown',
      urlBuktiBayar: json['Url_bukti_bayar']?.toString(),
      noRek: json['Nomor_rekening']?.toString() ?? 'Tanya Owner',
    );
  }
}
