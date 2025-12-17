## Kelompok Byte Three
### Anggota Tim
| No | Nama | NIM | Lab| Kom
|:--:|------|-----|-----|-----|
| 1 | Chyntia Claudia | 231401006 | Lab PM 5 | C
| 2 | Dini Sahfitri | 231401033 | Lab PM 5 | C
| 3 | Felice Yovita | 231401045 | Lab PM 5 | C
---

# EduPin 
EduPin adalah aplikasi mobile berbasis Android yang digunakan untuk menyimpan, mencari, mengatur, dan berbagi materi pembelajaran visual dalam satu aplikasi. Materi pembelajaran tersebut dapat berupa mind map, infografis, dan rangkuman digital yang diunggah oleh para pengguna.

---

### 📱 Deskripsi Produk

EduPin dikembangkan untuk menjawab permasalahan umum pelajar dalam mengelola sumber belajar yang tersebar dan sulit diakses. Melalui Edupin, pengguna dapat mengunggah, mencari, menyimpan, dan mengorganisasi konten pembelajaran visual sesuai kebutuhan mereka.

---

### Tujuan Aplikasi

- Membantu pelajar menyimpan dan mengatur catatan belajar dengan lebih rapi
- Mempermudah pencarian materi pembelajaran visual
- Menyediakan tempat untuk berbagi dan menemukan catatan belajar
- Mendukung proses belajar mandiri dan kerja sama antar pelajar  

---

### ✨ Fungsi Utama Aplikasi

#### 🔐 Registrasi dan Login Pengguna
- Registrasi akun menggunakan email dan verifikasi  
- Login untuk mengakses seluruh fitur aplikasi  
- Pemulihan kata sandi (forgot password)  

### 📝 Manajemen Konten (Catatan)
- Mengunggah materi pembelajaran visual (JPG, PNG)  
- Menambahkan detail materi: judul, deskripsi, dan tag/kategori  
- Mengedit dan menghapus catatan yang diunggah  

#### 🔎 Penemuan dan Pencarian Konten
- Menelusuri catatan terbaru dari pengguna lain  
- Pencarian berdasarkan judul, deskripsi, kategori, atau tag  

#### 📌 Kurasi Konten Personal (Papan)
- Menyimpan atau mem-pin catatan yang relevan di papan koleksi 

#### 👤 Manajemen Profil dan Interaksi
- Melihat profil pribadi dan galeri catatan  
- Memperbarui nama tampilan dan foto profil  
- Melihat profil publik pengguna lain  
- Logout dari aplikasi  

#### 🔔 Sistem Notifikasi
- Melihat riwayat notifikasi terkait akun atau konten

#### 🚨 Moderasi Konten (Pelaporan)
- Melaporkan catatan atau profil pengguna yang melanggar pedoman komunitas  


---

## 📂 Struktur Proyek

EduPin menerapkan arsitektur yang terstruktur memisahkan *Logic*, *UI*, dan *Services* untuk kemudahan pemeliharaan (*maintainability*).

```text
lib/
├── app/
│   └── router.dart
│
├── models/
│   └── note_details.dart
│
├── provider/
│   ├── auth_provider.dart
│   └── catatan_provider.dart
│
├── screens/
│   ├── detail_catatan.dart
│   ├── edit_catatan_screen.dart
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── notifikasi_screen.dart
│   ├── papan_detail_screen.dart
│   ├── papan_screen.dart
│   ├── pin_baru.dart
│   ├── profile_screen.dart
│   ├── profile_tabs.dart
│   ├── profile_user.dart
│   ├── report_note_screen.dart
│   ├── sign_up_screen.dart
│   ├── splash_screen.dart
│   └── upload_catatan.dart
│   
├── services/
│   └──  auth/
│       ├── catatan_service.dart
│       ├── notification_service.dart
│       └── supabase_storage_service
│
├── utils/
│   ├── custom_notification.dart
│   ├── time_formatter.dart
│   └── validators.dart
│   
├── widgets/
│   ├── action_icon_button.dart
│   ├── app_header.dart
│   ├── app_navbar.dart
│   ├── bottom_sheet.dart
│   ├── image_carousel.dart
│   ├── list_kategori.dart
│   ├── logoApp_bgBlue.dart
│   ├── notification_item.dart
│   ├── pill_tag.dart
│   ├── pin_card.dart
│   ├── profile_widgets.dart
│   ├── publisher_card.dart
│   ├── save_to_pin_sheet.dart
│   ├── section_card.dart
│   └── text_field.dart
│
├── firebase_options.dart
├── main.dart

```
---

## 🛠️ Teknologi & Dependencies

Aplikasi ini dibangun menggunakan ekosistem **Flutter** dengan integrasi layanan *backend* modern.

### Tech Stack Utama
| Komponen | Teknologi |
|--------|-----------|
| **Framework** | Flutter (Dart) |
| **Platform** | Android |
| **Authentication** | Firebase Authentication & Google Sign-In |
| **Database** | Firebase Firestore |
| **Storage** | Supabase Storage |
| **State Management** | Provider |
| **Routing** | GoRouter |
| **CI/CD** | GitHub Actions |
| **Version Control** | Git & GitHub |

### 📦 Packages & Library
Berikut adalah daftar paket utama yang digunakan dalam pengembangan EduPin:

| Package | Versi | Fungsi / Kegunaan |
|---------|-------|-------------------|
| **Core & UI** | | |
| `flutter` | SDK | Framework utama pengembangan aplikasi. |
| **Navigasi & State** | | |
| `go_router` | ^17.0.0 | Manajemen navigasi antar halaman (*routing*). |
| `provider` | ^6.1.2 | Manajemen *state* aplikasi yang efisien. |
| **Backend & Services** | | |
| `firebase_core` | ^4.2.1 | Inisialisasi koneksi ke Firebase. |
| `firebase_auth` | ^6.1.2 | Layanan autentikasi pengguna. |
| `cloud_firestore` | ^6.1.0 | Database NoSQL real-time. |
| `supabase_flutter` | ^2.10.3 | Layanan penyimpanan file (*Storage*) alternatif. |
| `firebase_storage` | ^13.0.4 | Layanan penyimpanan file Firebase. |
| **Media & Utilitas** | | |
| `image_picker` | ^1.2.1 | Mengambil gambar dari galeri/kamera. |
| `gal` | ^2.3.0 | Menyimpan gambar ke galeri perangkat. |
| `http` | ^1.2.0 | Melakukan request jaringan (download/upload). |
| `shared_preferences` | ^2.5.4 | Penyimpanan data lokal sederhana (*key-value*). |
| `permission_handler` | ^11.3.0 | Mengelola izin akses sistem (storage, camera). |
| `path_provider` | ^2.1.2 | Mencari *path* direktori di sistem file. |
| `intl` | ^0.20.2 | Format tanggal dan angka. |

---

### 🛠️ Teknologi yang Digunakan

| Komponen | Teknologi |
|--------|-----------|
| Framework | Flutter |
| Platform | Android |
| Authentication | Firebase Authentication |
| Database | Firebase Firestore |
| Storage | Supabase Storage |
| CI/CD | GitHub Actions |
| Version Control | Git & GitHub |

---

## 📸 Preview Aplikasi EduPin

---

### Tampilan Aplikasi – Autentikasi

| Login | Sign Up | Reset Password |
|---|---|---|
| <img src="preview_app/login_Preview.jpg" width="150"/> | <img src="preview_app/signup_Preview.jpg" width="150"/> | <img src="preview_app/reset_Password_Preview.jpg" width="150"/> |

---

### Tampilan Aplikasi – Beranda dan Fitur Utama

| Beranda | Pilih Kategori | Detail Catatan | Author Catatan |
|---|---|---|---|
| <img src="preview_app/beranda_Preview.jpg" width="150"/> | <img src="preview_app/select_Kategori_Preview.jpg" width="150"/> | <img src="preview_app/detail_Catatan_Preview.jpg" width="150"/> | <img src="preview_app/Author_Catatan_Preview.jpg" width="150"/> |

---

### Tampilan Aplikasi – Papan & Unggah Catatan

| Papan | Buat papan | Tambah Catatan | Field Tambah Catatan |
|---|---|---|---|
| <img src="preview_app/papan_Preview.jpg" width="150"/> |<img src="preview_app/buat_Papan_Preview.jpg" width="150"/> | <img src="preview_app/tambah_Catatan_Preview.jpg" width="150"/> | <img src="preview_app/tambah_Catatan2_Preview.jpg" width="150"/> |

---

###  Tampilan Aplikasi – Notifikasi & Manajemen Profil

| Notifikasi | Profil Akun | Edit Profil | Manajemen Catatan | Pengaturan Akun | Hapus Akun | 
|---|---|---|---|---|---|
| <img src="preview_app/notifikasi_Preview.jpg" width="130"/> | <img src="preview_app/profil_Account_Preview.jpg" width="130"/> | <img src="preview_app/edit_Profile_Preview.jpg" width="130"/> | <img src="preview_app/manage_Catatan_Preview.jpg" width="130"/> | <img src="preview_app/pengaturan_Account_Preview.jpg" width="130"/> |<img src="preview_app/hapus_Account_Preview.jpg" width="130"/> |

---
### File dokumentasi 
- 📄 **[Dokumen EduPin (Google Drive)](https://drive.google.com/drive/folders/1-uGmA9mm7lJtzxpKosbdR5XKMsEJrZW8?usp=drive_link)**
- 🎨 **[Desain UI/UX (Figma)](https://www.figma.com/design/eS4MH0FyTXSa8tyJpRlUyN/EduPin-%7C-ByteThree?node-id=97-400&t=K0VXxtVn7A3O267e-1)**
---

## 🎨 Credit ke Sumber Aset

-   **Font Kustom: Albert Sans**
    -   **Sumber:** [Google Fonts](https://fonts.google.com/specimen/Albert+Sans)

-   **Ikon**
    -   **Sumber:** [Icons8](https://icons8.com/icons) (via plugin Figma)
---

### Cara Menggunakan Aplikasi

1. Buka halaman **Releases** pada repository GitHub EduPin
2. Unduh file **APK** versi terbaru
3. Pindahkan APK ke perangkat Android
4. Aktifkan izin **Install from Unknown Sources**
5. Install dan jalankan aplikasi EduPin
