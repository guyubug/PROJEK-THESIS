# SPPG Priangan Jaya 🍽️

Aplikasi mobile berbasis **Flutter** untuk memonitor stok bahan makanan pada program **SPPG (Satuan Pelayanan Pemenuhan Gizi)** — mendukung operasional dapur program makan bergizi di sekolah. Dikembangkan sebagai proyek tugas akhir (skripsi).

<!-- 
TODO: Tambahkan screenshot/GIF aplikasi di sini, contoh:
<p align="center">
  <img src="screenshots/home.png" width="200" />
  <img src="screenshots/barang.png" width="200" />
  <img src="screenshots/transaksi.png" width="200" />
</p>
-->

## ✨ Fitur Utama

- **Autentikasi Pengguna** — Login & pendaftaran akun dengan role-based access (`pengada` / `pemakai`)
- **Manajemen Barang** — Pantau daftar bahan makanan dan status stok (dengan indikator badge berwarna)
- **Pencatatan Transaksi Stok** — Tambah dan edit transaksi keluar/masuk barang dalam satu form terpadu
- **Manajemen Supplier** — Kelola data pemasok bahan makanan (tambah, edit, hapus)
- **Dashboard Beranda** — Ringkasan kondisi stok secara real-time
- **Riwayat & Catatan Aktivitas** — Log aktivitas otomatis untuk setiap perubahan data
- **Auto-refresh antar Tab** — Data selalu ter-update saat berpindah tab navigasi

## 🛠️ Tech Stack

| Kategori | Teknologi |
|---|---|
| Framework | [Flutter](https://flutter.dev) |
| Backend & Database | [Supabase](https://supabase.com) (PostgreSQL) |
| Autentikasi | Supabase Auth dengan Row Level Security (RLS) |
| Package utama | `supabase_flutter`, `url_launcher`, `intl` |
| Desain | Figma (custom teal gradient theme) |

## 🗄️ Struktur Database

Aplikasi ini menggunakan 6 tabel utama di Supabase:

- `profiles` — Data pengguna & role
- `bahan` — Data bahan makanan & stok
- `supplier` — Data pemasok
- `transaksi_stok` — Riwayat transaksi keluar/masuk barang
- `request_bahan` — Permintaan bahan
- `log_aktivitas` — Log aktivitas sistem

Dilengkapi **PostgreSQL trigger** untuk update stok otomatis dan pencatatan log aktivitas, serta **RLS policy** untuk kontrol akses berbasis role.

## 🚀 Cara Menjalankan

1. Clone repository ini
   ```bash
   git clone https://github.com/guyubug/PROJEK-THESIS.git
   cd PROJEK-THESIS
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi (emulator/device harus sudah aktif)
   ```bash
   flutter run
   ```

> Catatan: Aplikasi menggunakan Supabase publishable key yang memang didesain aman untuk sisi client. Keamanan data ditangani melalui Row Level Security (RLS) di sisi database.

## 📱 Demo

<!-- TODO: Tambahkan link video demo di sini, contoh: -->
<!-- [Tonton demo aplikasi di YouTube](https://youtube.com/...) -->

## 📖 Latar Belakang

Aplikasi ini dikembangkan untuk membantu unit SPPG mengelola stok bahan makanan secara lebih efisien dan transparan, menggantikan pencatatan manual dengan sistem digital yang terintegrasi dengan database real-time. Beberapa tantangan teknis yang dihadapi selama pengembangan meliputi perancangan RLS policy berbasis role, sinkronisasi data antar tab navigasi, dan implementasi trigger database untuk pembaruan stok otomatis.

---

Dikembangkan oleh **Rangga** sebagai proyek tugas akhir.
