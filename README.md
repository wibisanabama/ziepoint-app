# ZiePoint

Aplikasi Android dan iOS untuk mencatat pelanggaran dan prestasi siswa, dengan backend REST API berbasis Node.js dan MySQL.

## Fitur

- Login siswa menggunakan NIS dan login guru menggunakan NIP.
- Pengelolaan data siswa oleh guru.
- Pengelolaan kriteria pelanggaran dan prestasi beserta poinnya.
- Pencatatan pelanggaran dan prestasi siswa.
- Tampilan aktivitas terbaru dan riwayat catatan siswa.

## Struktur Project

```text
api-siswa-node/  Backend Express dan koneksi MySQL
ziepoint-app/    Aplikasi Flutter untuk Android dan iOS
README.md       Dokumentasi project
```

## Prasyarat

- Flutter SDK dengan Dart yang kompatibel dengan dependency project.
- Node.js 18 atau lebih baru dan npm.
- MySQL.
- Android SDK untuk Android.
- macOS dan Xcode untuk pengembangan iOS.

## Instalasi

```bash
git clone https://github.com/wibisanabama/ziepoint-app.git
cd ziepoint-app
```

Direktori hasil clone adalah root repository. Aplikasi Flutter berada di subdirektori `ziepoint-app/`.

### 1. Database

Siapkan database `db_sekolah` dengan tabel yang digunakan backend:

- `siswa`: data dan akun siswa.
- `guru`: data dan akun guru.
- `jenis_catatan`: kriteria, tipe, dan poin.
- `catatan_siswa`: catatan yang menghubungkan siswa, guru, dan kriteria.

Repository belum menyertakan skema SQL, migrasi, atau seed akun. Struktur tabel harus disediakan sesuai query dalam `api-siswa-node/app.js`. Akun guru harus tersedia di database sebelum login.

### 2. Backend

Dari root repository:

```bash
cd api-siswa-node
npm install
node app.js
```

Backend menggunakan konfigurasi environment berikut:

| Variabel | Nilai default | Keterangan |
| --- | --- | --- |
| `DB_HOST` | `localhost` | Host MySQL |
| `DB_USER` | `root` | Pengguna MySQL |
| `DB_PASSWORD` | Kosong | Password MySQL |
| `DB_NAME` | `db_sekolah` | Nama database |
| `PORT` | `3000` | Port HTTP backend |
| `ALLOWED_ORIGINS` | `http://localhost` | Origin CORS tambahan, dipisahkan koma |

Tetapkan environment variable pada terminal sebelum menjalankan backend jika konfigurasi berbeda. Aplikasi tidak memuat file `.env` secara otomatis.

### 3. Aplikasi Mobile

Atur `baseUrl` pada `ziepoint-app/lib/services/api_service.dart`:

- Android Emulator: `http://10.0.2.2:3000` (konfigurasi saat ini).
- Perangkat fisik: gunakan alamat IP jaringan komputer yang menjalankan backend.
- iOS Simulator: gunakan alamat backend yang dapat dijangkau simulator.

Sesuaikan port jika `PORT` backend diubah. Biarkan backend berjalan, lalu buka terminal baru dari root repository:

```bash
cd ziepoint-app
flutter pub get
flutter run
```

Pilih emulator atau perangkat Android/iOS yang terhubung.

## Pemeriksaan Kode

Dari root repository:

```bash
node --check api-siswa-node/app.js
cd ziepoint-app
flutter analyze
```

Pemeriksaan ini tidak menguji koneksi database atau alur aplikasi secara menyeluruh.
