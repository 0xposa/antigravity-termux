# 🚀 Google Antigravity CLI — Termux Native Installer

<p align="center">
  <img src="https://img.shields.io/badge/Google%20Antigravity-Official%20Android%20Bionic-blue?style=for-the-badge&logo=google" alt="Google Antigravity Official" />
  <img src="https://img.shields.io/badge/PRoot%20Distro-NOT%20NEEDED-brightgreen?style=for-the-badge" alt="Zero PRoot" />
  <img src="https://img.shields.io/badge/Architecture-ARM64%20(aarch64)-orange?style=for-the-badge" alt="ARM64" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="MIT License" />
</p>

Repositori ini menyediakan skrip instalasi **1-Klik (One-Liner)** untuk memasang **Google Antigravity CLI (`agy`) resmi (official)** secara **native** di aplikasi Termux Android tanpa memerlukan PRoot-Distro (tanpa Ubuntu/Debian container).

Didesain khusus untuk **pemula yang benar-benar awam dengan terminal** maupun pengguna yang **baru saja mengunduh aplikasi Termux** (fresh install).

---

## ⚡ Cara Pasang Cepat (One-Liner)

Buka aplikasi Termux Anda, lalu **salin (copy) dan tempel (paste)** perintah di bawah ini, kemudian tekan **Enter**:

```bash
pkg update -y && pkg install -y curl && curl -fsSL https://raw.githubusercontent.com/0xposa/antigravity-termux/main/install.sh | bash
```

> [!TIP]
> Perintah di atas sudah otomatis:
> 1. Menginstal paket `curl` dan prasyarat lainnya tanpa memunculkan dialog konfigurasi yang membingungkan.
> 2. Mengunduh biner **official Google** versi terbaru.
> 3. Memverifikasi keamanan biner dengan checksum SHA-512.
> 4. Memasang perintah `agy` ke `$PREFIX/bin` sehingga **langsung bisa digunakan seketika**!

---

## 📖 Panduan Lengkap untuk Pemula (Langkah demi Langkah)

Jika Anda baru pertama kali menggunakan Termux, ikuti 4 langkah mudah ini:

### 1. Pastikan Menggunakan Termux yang Benar
> [!CAUTION]
> **JANGAN unduh Termux dari Google Play Store!** Versi Play Store sudah usang (deprecated) dan server paketnya tidak lagi diperbarui.
> 
> Unduh Termux resmi versi terbaru dari salah satu link ini:
> - **F-Droid**: [Download Termux di F-Droid](https://f-droid.org/en/packages/com.termux/)
> - **GitHub Release**: [Download APK Termux GitHub](https://github.com/termux/termux-app/releases) *(Pilih yang berakhiran `arm64-v8a.apk`)*.

### 2. Jalankan Perintah Instalasi
1. Buka aplikasi **Termux**.
2. Salin baris perintah di atas:
   ```bash
   pkg update -y && pkg install -y curl && curl -fsSL https://raw.githubusercontent.com/0xposa/antigravity-termux/main/install.sh | bash
   ```
3. Tekan lama di layar Termux, pilih **Paste**, lalu tekan **Enter**.
4. Biarkan proses berjalan hingga muncul tulisan hijau **"🎉 SELAMAT! ANTIGRAVITY CLI SIAP DIGUNAKAN!"**.

### 3. Jalankan Antigravity
Ketik perintah:
```bash
agy
```
Lalu tekan **Enter**.

### 4. Login Akun Google
Saat pertama kali dijalankan, `agy` akan memberikan tautan (URL) login Google.
- Tekan link tersebut atau salin ke browser Google Chrome di HP Anda.
- Masuk (*Sign In*) menggunakan akun Google Anda.
- Selesai! Antigravity CLI siap menjadi asisten pemrograman AI Anda langsung dari HP.

---

## 🌟 Keunggulan Installer Ini

| Fitur | Installer Ini (Native) | Metode PRoot Distro Lama |
|---|---|---|
| **Biner** | **100% Official Google Android Bionic** | Linux glibc yang di-patch |
| **Kebutuhan Storage** | **~200 MB saja** | 2.5 GB – 4 GB (berat!) |
| **Kecepatan** | **Maksimal (Native)** | Lambat (ada overhead PRoot) |
| **Kemudahan Pemula** | **Tinggal ketik `agy`** | Harus login ke Debian/Ubuntu dulu |
| **Keamanan** | **Verifikasi Checksum SHA-512 Otomatis** | Tidak terverifikasi |

---

## 🛠️ Tips & Solusi Masalah (Troubleshooting)

### 1. Error: `Repository is under maintenance or down`
Jika Termux baru Anda menampilkan error saat mendownload paket, server mirror bawaan Termux mungkin sedang lambat atau offline.
Solusinya, jalankan:
```bash
termux-change-repo
```
Pilih **Main Repository**, lalu pilih mirror lain (misalnya **Grimler**, **A125**, atau **Tsinghua**), kemudian jalankan kembali perintah instalasi.

### 2. Mengizinkan Termux Mengakses Memori HP (`/sdcard`)
Agar Antigravity dapat membaca file codingan yang Anda simpan di memori internal HP:
```bash
termux-setup-storage
```
Tekan **Allow / Izinkan** pada pop-up izin yang muncul di layar HP Anda. File internal Anda akan dapat diakses di folder `~/storage/shared`.

### 3. Mencegah Termux Tertutup Sendiri (Android 12+)
Pada Android 12 ke atas, fitur *Phantom Process Killer* sering mematikan aplikasi latar belakang:
1. Jalankan perintah ini di Termux agar HP tetap terjaga saat proses berat:
   ```bash
   termux-wake-lock
   ```
2. Buka **Pengaturan HP ➔ Aplikasi ➔ Termux ➔ Baterai** ➔ Ubah menjadi **Tidak Dibatasi (Unrestricted)**.

### 4. Cara Keluar dari Antigravity CLI
Jika Anda ingin keluar dari sesi obrolan Antigravity dan kembali ke terminal Termux:
- Tekan tombol **Ctrl + D** dua kali, atau
- Ketik perintah: `/exit` atau `/quit`.

---

## 🗑️ Cara Menghapus (Uninstall)

Jika Anda ingin menghapus instalasi secara bersih dari Termux:

```bash
curl -fsSL https://raw.githubusercontent.com/0xposa/antigravity-termux/main/uninstall.sh | bash
```
Atau jika Anda mengklon repositori ini:
```bash
bash uninstall.sh
```

---

## 📜 Lisensi & Penafian

- Kode skrip installer ini dilisensikan di bawah lisensi [MIT](LICENSE).
- **Google Antigravity CLI** adalah merek dagang dan hak cipta milik **Google LLC**. Installer ini hanya mengunduh biner resmi yang didistribusikan langsung oleh Google.
