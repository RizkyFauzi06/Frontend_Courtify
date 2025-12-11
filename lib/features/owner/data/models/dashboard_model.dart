class DashboardStats {
  final double totalPendapatan;
  final int totalPemesanan;
  final double totalJam;

  DashboardStats({
    required this.totalPendapatan,
    required this.totalPemesanan,
    required this.totalJam,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalPendapatan:
          double.tryParse(json['total_pendapatan']?.toString() ?? '0') ?? 0.0,
      totalPemesanan:
          int.tryParse(json['total_pemesanan_sukses']?.toString() ?? '0') ?? 0,
      totalJam:
          double.tryParse(json['total_jam_terpesan']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class JamRamai {
  final int jam;
  final int jumlahBooking;

  JamRamai({required this.jam, required this.jumlahBooking});

  factory JamRamai.fromJson(Map<String, dynamic> json) {
    return JamRamai(
      jam: int.tryParse(json['jam']?.toString() ?? '0') ?? 0,
      jumlahBooking:
          int.tryParse(json['jumlah_booking']?.toString() ?? '0') ?? 0,
    );
  }
}

class LapanganTerlaris {
  final String nama;
  final int jumlahBooking;
  final double totalPendapatan;

  LapanganTerlaris({
    required this.nama,
    required this.jumlahBooking,
    required this.totalPendapatan,
  });

  factory LapanganTerlaris.fromJson(Map<String, dynamic> json) {
    return LapanganTerlaris(
      nama: json['nama_lapangan']?.toString() ?? '-',
      jumlahBooking:
          int.tryParse(json['jumlah_booking']?.toString() ?? '0') ?? 0,
      totalPendapatan:
          double.tryParse(
            json['total_pendapatan_lapangan']?.toString() ?? '0',
          ) ??
          0.0,
    );
  }
}
