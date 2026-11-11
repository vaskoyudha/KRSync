# Sitemap Halaman Web — KRSync Tahap 1

Setiap halaman dipetakan ke tepat satu route. Route mengikuti `PLAN.md`
(Task 13, 17, 18, 19, 20) dan didaftarkan di `cmd/web/main.go` (Task 1, 6, 13,
17, 18).

## Halaman bersama (sebelum login)

| Halaman | Route | Handler |
|---|---|---|
| Beranda | `GET /` | `halaman.Home` |
| Login | `GET /login`, `POST /login` | `authH.FormLogin`, `authH.Login` |
| Logout | `POST /logout` | `authH.Logout` |
| Aset statis | `GET /static/` | `http.FileServer("public")` |

## Menu Admin Prodi

| Halaman | Route |
|---|---|
| Dashboard Rekap Kelas dan Waitlist | `GET /admin/rekap` |
| Semester / Periode | `GET /admin/semester`, `POST /admin/semester` |
| Master Kurikulum | `GET /admin/kurikulum`, `POST /admin/kurikulum`, `GET /admin/kurikulum/{id}/edit`, `POST /admin/kurikulum/{id}/edit` |
| Master Mata Kuliah | `GET /admin/mk`, `POST /admin/mk`, `GET /admin/mk/{id}/edit`, `POST /admin/mk/{id}/edit` |
| Set Prasyarat dan Ekuivalensi | `GET /admin/prasyarat`, `POST /admin/prasyarat` |
| Jadwal dan Kuota Kelas Paralel | `GET /admin/kelas`, `POST /admin/kelas` |
| Input Nilai Mahasiswa | `GET /admin/nilai`, `POST /admin/nilai` |

## Menu Mahasiswa

| Halaman | Route |
|---|---|
| Dashboard Akademik (IPS dan jatah SKS) | `GET /krs` |
| Isi KRS dan Pilih Kelas | `GET /krs/isi`, `POST /krs/kelas`, `POST /krs/kelas/{id}/hapus` |
| Ajukan KRS | `POST /krs/ajukan` |
| Daftar Tunggu Saya | `GET /krs/tunggu` |
| Lembar KRS dan Riwayat Nilai | `GET /krs/lembar` |

## Menu Dosen Wali

| Halaman | Route |
|---|---|
| Daftar Mahasiswa Bimbingan | `GET /bimbingan` |
| Detail Review dan Persetujuan KRS | `GET /bimbingan/{id}` |
| Setujui KRS | `POST /bimbingan/{id}/setujui` |
| Minta Revisi KRS | `POST /bimbingan/{id}/revisi` |

## Celah yang ditemukan

a. **Pengguna / Akun (Admin Prodi)** ada di CRUD matrix tetapi tidak memiliki
   route maupun task handler di `PLAN.md`. Saat ini akun hanya dibuat lewat
   seed SQL (Task 21). Ini adalah task yang hilang bila halaman pengguna harus
   ada di Tahap 1.
b. **Riwayat Nilai mahasiswa** tidak punya route terpisah; kontrak Task 17
   menggabungkannya ke halaman Lembar KRS (`GET /krs/lembar`). Bila dosen atau
   mahasiswa butuh riwayat sebagai halaman sendiri, task tambahan diperlukan.
c. **Rekap Kelas untuk Dosen Wali** ada di CRUD matrix (`R bimbingan`) tetapi
   route `/admin/rekap` hanya untuk Admin Prodi. Task 19 tidak menyediakan
   route rekap per bimbingan.
