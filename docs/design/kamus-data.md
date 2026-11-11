# Kamus Data (Bagian Master)

Diturunkan dari `db/schema.sql`; bila keduanya berbeda, perbaiki dokumen ini pada PR yang sama.
Tabel transaksi (`krs`, `krs_detail`, `daftar_tunggu`) dicatat oleh Shofwan.

**Konvensi:** PK selalu `id`; FK bernama `<nama_tabel>_id` (pengecualian terkunci di PLAN: `mk_id`, `mk_baru_id`, `mk_lama_id`, `mk_prasyarat_id`, `dosen_id`). Data master di-soft-delete lewat `deleted_at`.

## 1. `users`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `nama` | VARCHAR | 100 | - | TIDAK | Nama lengkap pemilik akun |
| 3 | `email` | VARCHAR | 255 | UNIQUE | TIDAK | Username login; unik |
| 4 | `password_hash` | VARCHAR | 255 | - | TIDAK | Hash bcrypt (bukan teks asli) |
| 5 | `role` | VARCHAR | 20 | - | TIDAK | ADMIN_PRODI / MAHASISWA / DOSEN_WALI |
| 6 | `is_active` | TINYINT | 1 | - | TIDAK | 1 = akun aktif, 0 = dinonaktifkan; default 1 |
| 7 | `created_at` | TIMESTAMP | - | - | TIDAK | Waktu akun dibuat |

**Constraint:** CHECK role IN ('ADMIN_PRODI','MAHASISWA','DOSEN_WALI').

## 2. `sessions`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `token` | VARCHAR | 64 | PK | TIDAK | Token acak 128 bit yang dibawa cookie `session` |
| 2 | `user_id` | BIGINT | - | FK → users.id | TIDAK | Pemilik session; ON DELETE CASCADE |
| 3 | `expires_at` | DATETIME | - | - | TIDAK | Batas berlaku session (7 hari sejak login) |

## 3. `semester`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `tahun_ajaran` | VARCHAR | 9 | - | TIDAK | Format 2025/2026 |
| 3 | `periode` | VARCHAR | 10 | - | TIDAK | GANJIL / GENAP |
| 4 | `status_periode` | VARCHAR | 30 | - | TIDAK | Fase KRS: PENGISIAN_KRS / PERKULIAHAN / MASA_PERUBAHAN_KRS / SELESAI; default 'PENGISIAN_KRS' |
| 5 | `tanggal_mulai` | DATE | - | - | TIDAK | Awal semester |
| 6 | `tanggal_selesai` | DATE | - | - | TIDAK | Akhir semester |
| 7 | `created_at` | TIMESTAMP | - | - | TIDAK | Waktu baris dibuat |

**Constraint:** UNIQUE (tahun_ajaran, periode); CHECK periode IN ('GANJIL','GENAP'); CHECK status_periode IN ('PENGISIAN_KRS','PERKULIAHAN','MASA_PERUBAHAN_KRS','SELESAI').

## 4. `kurikulum`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `kode` | VARCHAR | 20 | UNIQUE | TIDAK | Kode kurikulum, mis. K2024; unik |
| 3 | `nama` | VARCHAR | 100 | - | TIDAK | Nama kurikulum |
| 4 | `tahun_mulai` | YEAR | - | - | TIDAK | Tahun pemberlakuan |
| 5 | `is_active` | TINYINT | 1 | - | TIDAK | 1 = kurikulum masih berlaku; default 1 |
| 6 | `created_at` | TIMESTAMP | - | - | TIDAK | Waktu baris dibuat |
| 7 | `updated_at` | TIMESTAMP | - | - | YA | Waktu perubahan terakhir |
| 8 | `deleted_at` | TIMESTAMP | - | - | YA | Soft delete; NULL = belum dihapus |

## 5. `mata_kuliah`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `kurikulum_id` | BIGINT | - | FK → kurikulum.id | TIDAK | Kurikulum pemilik MK |
| 3 | `kode` | VARCHAR | 20 | - | TIDAK | Kode MK; unik per kurikulum |
| 4 | `nama` | VARCHAR | 120 | - | TIDAK | Nama mata kuliah |
| 5 | `sks` | TINYINT | - | - | TIDAK | Bobot SKS (1-6) |
| 6 | `semester_ke` | TINYINT | - | - | TIDAK | Semester penawaran dalam kurikulum |
| 7 | `created_at` | TIMESTAMP | - | - | TIDAK | Waktu baris dibuat |
| 8 | `updated_at` | TIMESTAMP | - | - | YA | Waktu perubahan terakhir |
| 9 | `deleted_at` | TIMESTAMP | - | - | YA | Soft delete; NULL = belum dihapus |

**Constraint:** UNIQUE (kurikulum_id, kode); CHECK sks BETWEEN 1 AND 6.

## 6. `ekuivalensi_mk`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `mk_baru_id` | BIGINT | - | FK → mata_kuliah.id | TIDAK | MK kurikulum baru |
| 3 | `mk_lama_id` | BIGINT | - | FK → mata_kuliah.id | TIDAK | MK kurikulum lama yang setara; pasangan (baru, lama) unik |
| 4 | `created_at` | TIMESTAMP | - | - | TIDAK | Waktu baris dibuat |

**Constraint:** UNIQUE (mk_baru_id, mk_lama_id).

## 7. `prasyarat_grup`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `mk_id` | BIGINT | - | FK → mata_kuliah.id | TIDAK | MK target yang memiliki prasyarat; ON DELETE CASCADE |
| 3 | `grup_kondisi` | VARCHAR | 3 | - | TIDAK | AND = semua item lulus; OR = minimal satu item lulus (semua grup MK wajib lolos) |
| 4 | `created_at` | TIMESTAMP | - | - | TIDAK | Waktu baris dibuat |

**Constraint:** CHECK grup_kondisi IN ('AND','OR').

## 8. `prasyarat_item`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `grup_id` | BIGINT | - | FK → prasyarat_grup.id | TIDAK | Grup induk; ON DELETE CASCADE |
| 3 | `mk_prasyarat_id` | BIGINT | - | FK → mata_kuliah.id | TIDAK | MK yang menjadi syarat |
| 4 | `nilai_min` | DECIMAL | 3,2 | - | TIDAK | Nilai indeks minimal; default 2.00 (C); default 2.00 |

## 9. `dosen_wali`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `user_id` | BIGINT | - | FK → users.id | TIDAK | Akun login dosen; unik |
| 3 | `nidn` | VARCHAR | 20 | UNIQUE | TIDAK | Nomor Induk Dosen Nasional; unik |
| 4 | `nama` | VARCHAR | 100 | - | TIDAK | Nama beserta gelar |

## 10. `mahasiswa`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `user_id` | BIGINT | - | FK → users.id | TIDAK | Akun login mahasiswa; unik |
| 3 | `nim` | VARCHAR | 20 | UNIQUE | TIDAK | Nomor Induk Mahasiswa; unik |
| 4 | `nama` | VARCHAR | 100 | - | TIDAK | Nama lengkap |
| 5 | `angkatan` | YEAR | - | - | TIDAK | Tahun masuk |
| 6 | `kurikulum_id` | BIGINT | - | FK → kurikulum.id | TIDAK | Kurikulum yang diikuti |
| 7 | `dosen_wali_id` | BIGINT | - | FK → dosen_wali.id | YA | Pembimbing akademik; boleh NULL |
| 8 | `ips_terakhir` | DECIMAL | 3,2 | - | TIDAK | IPS semester lalu; dasar batas SKS; default 0.00 |

## 11. `riwayat_nilai`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `mahasiswa_id` | BIGINT | - | FK → mahasiswa.id | TIDAK | Pemilik nilai |
| 3 | `mk_id` | BIGINT | - | FK → mata_kuliah.id | TIDAK | MK yang dinilai |
| 4 | `semester_id` | BIGINT | - | FK → semester.id | TIDAK | Semester pengambilan; (mahasiswa, MK, semester) unik |
| 5 | `nilai_indeks` | DECIMAL | 3,2 | - | TIDAK | Bobot numerik 0.00-4.00; lulus bila >= 2.00 dan is_final = 1 |
| 6 | `nilai_huruf` | VARCHAR | 2 | - | TIDAK | A, A-, B+, B, ... E |
| 7 | `is_final` | TINYINT | 1 | - | TIDAK | 1 = nilai sudah final; default 1 |

**Constraint:** UNIQUE (mahasiswa_id, mk_id, semester_id).

## 12. `kelas_paralel`

| No | Kolom | Tipe | Panjang | PK/FK | Nullable | Keterangan |
|---|---|---|---|---|---|---|
| 1 | `id` | BIGINT | - | PK | TIDAK | Primary key auto-increment |
| 2 | `mk_id` | BIGINT | - | FK → mata_kuliah.id | TIDAK | MK yang dibuka |
| 3 | `semester_id` | BIGINT | - | FK → semester.id | TIDAK | Semester penyelenggaraan |
| 4 | `kode_kelas` | VARCHAR | 10 | - | TIDAK | Kode kelas, mis. A; unik per (MK, semester) |
| 5 | `dosen_id` | BIGINT | - | FK → dosen_wali.id | YA | Dosen pengampu (dosen_wali.id); boleh NULL |
| 6 | `hari` | VARCHAR | 7 | - | TIDAK | SENIN sampai SABTU |
| 7 | `jam_mulai` | TIME | - | - | TIDAK | Jam mulai; harus sebelum jam_selesai |
| 8 | `jam_selesai` | TIME | - | - | TIDAK | Jam selesai |
| 9 | `ruangan` | VARCHAR | 20 | - | TIDAK | Ruangan kuliah (FR-06) |
| 10 | `kuota_maksimal` | SMALLINT | - | - | TIDAK | Kuota kursi; harus > 0 |
| 11 | `created_at` | TIMESTAMP | - | - | TIDAK | Waktu baris dibuat |
| 12 | `updated_at` | TIMESTAMP | - | - | YA | Waktu perubahan terakhir |
| 13 | `deleted_at` | TIMESTAMP | - | - | YA | Soft delete; NULL = belum dihapus |

**Constraint:** UNIQUE (mk_id, semester_id, kode_kelas); CHECK hari IN ('SENIN','SELASA','RABU','KAMIS','JUMAT','SABTU'); CHECK jam_mulai < jam_selesai; CHECK kuota_maksimal > 0.
