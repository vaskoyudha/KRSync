# Matriks Hak Akses (CRUD Matrix)

Tabel ini menjadi acuan route dan middleware. `C` = create, `R` = read,
`U` = update, `D` = delete (soft delete untuk data master). Tanda `—` berarti
aktor tidak memiliki akses.

| Modul | Admin Prodi | Mahasiswa | Dosen Wali |
|---|---|---|---|
| Kurikulum | C R U D | R | R |
| Mata Kuliah | C R U D | R | R |
| Prasyarat / Ekuivalensi | C R U D | R | R |
| Kelas Paralel | C R U D | R | R |
| Riwayat Nilai | C R U D | R (sendiri) | R (bimbingan) |
| Pengisian KRS | R | C R U (DRAFT/REVISI) | R + setujui/revisi |
| Daftar Tunggu | R | R (sendiri) | R (bimbingan) |
| Rekap Kelas | R | — | R (bimbingan) |
| Semester / Periode | C R U | R | R |
| Pengguna / Akun | C R U (nonaktifkan) | — | — |

## Catatan penegasan

a. Data master (kurikulum, mata kuliah, prasyarat, ekuivalensi, kelas paralel,
   semester) memakai soft delete: setiap `SELECT` menyertakan
   `deleted_at IS NULL`.
b. Data transaksi (`krs`, `krs_detail`, `daftar_tunggu`) tidak pernah dihapus,
   hanya diubah statusnya.
c. Mahasiswa hanya dapat membaca baris miliknya sendiri; dosen hanya membaca
   mahasiswa bimbingannya. Pembatasan ini ditegakkan di service, bukan hanya di
   handler.
d. Admin Prodi tidak membuat atau menyetujui KRS; ia hanya membaca dan
   mengelola data master serta rekap.
