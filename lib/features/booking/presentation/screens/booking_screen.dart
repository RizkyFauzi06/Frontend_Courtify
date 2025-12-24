import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../controllers/booking_form_controller.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String fieldId;
  final String fieldName;
  final int pricePerHour;

  const BookingScreen({
    super.key,
    required this.fieldId,
    required this.fieldName,
    required this.pricePerHour,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  int _selectedDuration = 1;
  int? _selectedStartHour;

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(bookingFormProvider);
    final controller = ref.read(bookingFormProvider.notifier);
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final primaryColor = Theme.of(context).colorScheme.primary;

    int totalEstimasi = 0;
    if (_selectedStartHour != null) {
      totalEstimasi = widget.pricePerHour * _selectedDuration;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Pemesanan"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFO LAPANGAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Booking Lapangan:",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.fieldName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${currency.format(widget.pricePerHour)} / Jam",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // PILIH TANGGAL
            const Text(
              "Pilih Tanggal Main",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  controller.setDate(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      formData.selectedDate == null
                          ? "Ketuk untuk pilih tanggal..."
                          : DateFormat(
                              'EEEE, d MMMM yyyy',
                              'id_ID',
                            ).format(formData.selectedDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // PILIH JAM MULAI
            const Text(
              "Pilih Jam Mulai",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(15, (index) {
                int hour = 8 + index; // Jam 08.00 - 22.00
                bool isSelected = _selectedStartHour == hour;

                return ChoiceChip(
                  label: Text("$hour:00"),
                  selected: isSelected,
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedStartHour = selected ? hour : null;

                      if (_selectedStartHour != null) {
                        //Cek apakah durasi sekarang nabrak jam tutup?
                        // Anggap jam tutup lapangannya jam 23:00
                        const int closingHour = 23;
                        int maxDuration = closingHour - _selectedStartHour!;

                        // Kalau durasi yg dipilih sebelumnya melebihi sisa waktu buka
                        // Kita paksa turunkan durasi ke sisa waktu maksimal
                        if (_selectedDuration > maxDuration) {
                          _selectedDuration = maxDuration;
                        }
                        // Minimal durasi tetap 1 jam
                        if (_selectedDuration < 1) _selectedDuration = 1;

                        controller.setStartTime(
                          TimeOfDay(hour: _selectedStartHour!, minute: 0),
                        );
                        controller.setEndTime(
                          TimeOfDay(
                            hour: _selectedStartHour! + _selectedDuration,
                            minute: 0,
                          ),
                        );
                      }
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 24),

            // BAGIAN DURASI MAIN
            const Text(
              "Durasi Main",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // TOMBOL KURANG (-)
                IconButton.filledTonal(
                  onPressed: () {
                    if (_selectedDuration > 1) {
                      setState(() {
                        _selectedDuration--;
                        if (_selectedStartHour != null) {
                          controller.setEndTime(
                            TimeOfDay(
                              hour: _selectedStartHour! + _selectedDuration,
                              minute: 0,
                            ),
                          );
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),

                // TEXT DURASI
                Text(
                  "$_selectedDuration Jam",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 16),

                // TOMBOL TAMBAH (+)
                IconButton.filledTonal(
                  onPressed: () {
                    const int closingHour = 23;
                    // Kalau jam belum dipilih, kasih bebas aja (misal max 12 jam)
                    // Kalau jam sudah dipilih, max = 23 - jam mulai
                    int maxDuration = _selectedStartHour == null
                        ? 12
                        : closingHour - _selectedStartHour!;

                    if (_selectedDuration < maxDuration) {
                      setState(() {
                        _selectedDuration++;
                        if (_selectedStartHour != null) {
                          controller.setEndTime(
                            TimeOfDay(
                              hour: _selectedStartHour! + _selectedDuration,
                              minute: 0,
                            ),
                          );
                        }
                      });
                    } else {
                      // Kasih peringatan kalau sudah mentok
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Sudah mentok jam tutup lapangan!"),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                ),

                const Spacer(),
                if (_selectedStartHour != null)
                  Text(
                    "Selesai: ${_selectedStartHour! + _selectedDuration}:00",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(),

            // TOTAL HARGA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Estimasi Total:", style: TextStyle(fontSize: 16)),
                Text(
                  currency.format(totalEstimasi),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // TOMBOL BOOKING
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    (formData.selectedDate != null &&
                        _selectedStartHour != null)
                    ? () => _submitBooking(context, controller)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "BOOKING SEKARANG",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _submitBooking(
    BuildContext context,
    BookingFormController controller,
  ) async {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final result = await controller.submitBooking(int.parse(widget.fieldId));

      if (mounted) Navigator.pop(context); // Close loading

      final bookingId = result['id_pemesanan_baru'];
      final totalTagihan = result['total_harga'];
      final dpWajib = result['jumlah_dp_wajib'];
      final noRek = result['nomor_rekening'] ?? '-';

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text("Booking Berhasil!"),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Jadwal telah dikunci."),
                const Divider(),
                Text(
                  "DP WAJIB: ${currency.format(num.tryParse(dpWajib.toString()) ?? 0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Total: ${currency.format(num.tryParse(totalTagihan.toString()) ?? 0)}",
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: const Text("Bayar Nanti"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push(
                    '/upload-payment/$bookingId',
                    extra: {'rekening': noRek},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Bayar Sekarang"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
    }
  }
}
