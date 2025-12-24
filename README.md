# Courtify Mobile App

[![Download APK](https://img.shields.io/badge/Download-APK_v1.0-success?style=for-the-badge&logo=android)](https://github.com/RizkyFauzi06/Frontend_Courtify/releases/tag/v1.0.0)


PANDUAN INSTALASI APLIKASI RESERVASI LAPANGAN
File zip ini berisi source code Frontend (Flutter) dan Backend (Dart Frog).
Ikuti langkah-langkah di bawah ini secara berurutan agar aplikasi berjalan lancar.

BAGIAN 1: SETUP DATABASE (MySQL)
Sebelum menjalankan aplikasi, database harus disiapkan terlebih dahulu agar tidak terjadi error relasi antar tabel.

1.Buka Aplikasi Database Manager (DBeaver, HeidiSQL, atau phpMyAdmin via XAMPP).
2.Buat Database Baru, misalnya beri nama: lapangan_db.
3.Persiapkan File SQL nya(PENTING):
	1.Buka file .sql yang ada di folder ini menggunakan Text Editor (VS Code / Notepad).
	2.Tambahkan kode ini di baris paling ATAS (Baris pertama): "SET FOREIGN_KEY_CHECKS = 0;"
	3.Tambahkan kode ini di baris paling BAWAH (Baris terakhir): "SET FOREIGN_KEY_CHECKS = 1;"
	4.Coba import
	5.Jika ada error saat di import seperti tabel ngak bisa di import berarti ada masalah di definer
	6.cara mengatasinya adalah dengan cari command yang seperti ini 
		"/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;"
	7. lalu hapus semua tapi hanya di bagian paling atas dan paling bawah jangan yang di bagian isi tabel
	8.Done
5.Kembali ke DBeaver/phpMyAdmin.
6.Klik kanan pada database lapangan_db -> Tools -> Restore / Import Script.
7.Pilih file SQL yang sudah diedit tadi.
8.Jalankan (Execute). Pastikan tidak ada error merah.

BAGIAN 2: MENJALANKAN SERVER BACKEND (Dart Frog):
Backend bertugas melayani data ke aplikasi HP.

1.Hubungkan hp dan laptop pada satu jaringan yang sama entah wifi atau hospot
2.Buka Terminal (CMD / PowerShell / Terminal VS Code).
3.Masuk ke folder backend project: "cd path/to/backend_lapangan_server" atau jika di vscode klik kanan file backend nya dan pilih open integrated terminal.
4.Pastikan dependensi sudah terinstall biar aman bisa ke terminal dan ketik: "dart pub get" dan tunggu hingga selesai
5.Nyalakan Server dengan mengetik: "dart_frog dev"
6.Tunggu sampai muncul pesan: Running on http://localhost:8080 (Pastikan port-nya 8080).
NOTE: JANGAN TUTUP TERMINAL INI SELAMA APLIKASI DIGUNAKAN!!.

BAGIAN 3: KONFIGURASI IP ADDRESS (Agar HP Bisa Konek)
Karena aplikasi berjalan di HP/Emulator, aplikasi tidak bisa memanggil localhost. Kita harus menggunakan IP Address Laptop.

A. Cara Mengetahui IP Laptop
	1.Pastikan Laptop dan HP (jika pakai HP asli) terhubung ke jaringan yang SAMA.
	2.Buka Command Prompt (CMD) atau Terminal.
	3.Ketik perintah:
		Windows: ipconfig 
		Mac/Linux: ifconfig atau ip a
	4.Cari bagian Wireless LAN adapter Wi-Fi (atau Ethernet jika pakai kabel).
	5.Catat angka di sebelah IPv4 Address Contoh: 192.168.1.15 (Angka ini bisa berubah-ubah, jadi selalu cek).

B.Cara menghubungkan nya dengan HP
	1.Setelah mengetahui ipv4 Address diatas
	2.buka aplikasi Courtify 
	3.di bagian login screen cari icon "Gerigi" 
	4.klik icon gerigi dan ganti bagian "192.16.145.15" jangan yang "htpp//" atau ":8080" dengan ipv4 yang kalian dapat
	5.Selesai silahkan daftar dan login dengan akun mu
