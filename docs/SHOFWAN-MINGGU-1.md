# Shofwan — Minggu 1

Acuan: `PLAN.md`, antrean Shofwan dan jadwal Week 1 (Task 0, bagian Task 1,
dan bagian transaksi Task 2).

## Task 0 — Kompilasi desain

`docs/design/kompilasi.md` merupakan keluaran Markdown gabungan. Jalankan
`make design-draft` untuk menggabungkan draft yang tersedia, atau `make design`
untuk kompilasi lengkap. Perintah lengkap gagal jika salah satu sumber belum
tersedia, dan mempertahankan keluaran sebelumnya.

| Dokumen | Pemilik | Status saat pengerjaan |
|---|---|---|
| use-case.md | Vasco | Tersedia |
| crud-matrix.md | Vasco | Tersedia |
| sitemap.md | Vasco | Tersedia; celah route sudah tercatat di sumber |
| state-diagram.md | Saghita | Menunggu draft |
| erd.md | Fariz | Menunggu draft |
| kamus-data.md | Fariz | Menunggu draft |

**Task 0 belum mencapai design freeze.** Kompilasi tidak menggantikan review
tim atau menyatakan tiga dokumen yang belum ada sebagai selesai.

## Task 1 — Tooling dan CI

- `make dev`: hot reload Go/HTML/CSS dengan `wgo`.
- `make tools`: memasang versi `wgo` yang dipatok; tambahkan `$(go env GOPATH)/bin`
  ke `PATH` bila belum tersedia.
- `make build`, `make test`, `make lint`, `make fmt`, `make check-fmt`.
- `make test-db`: pengujian schema/seed transaksi pada MySQL nyata. Wajib
  `TEST_DB_DSN`; akun penguji memerlukan izin CREATE/DROP database pengujian.
- GitHub Actions menjalankan pemeriksaan format, build, vet, unit test,
  dan integrasi MySQL 8.0. Versi Go mengikuti `go.mod` milik Vasco.

Contoh pengujian (gunakan akun MySQL khusus pengembangan):

```sh
export TEST_DB_DSN='root:password@tcp(127.0.0.1:3306)/?parseTime=true&charset=utf8mb4'
make test-db
```

Test membuat database `krsync_test_<timestamp>` sendiri lalu menghapusnya.
Tanpa `TEST_DB_DSN`, `make test` melewati pengujian database, sedangkan
`make test-db` gagal dengan petunjuk konfigurasi.

## Task 2 — Kontrak integrasi dengan Fariz

`db/schema.sql` saat ini berisi **bagian transaksi saja**: `krs`, `krs_detail`,
`daftar_tunggu`. Gabungkan DDL master Fariz **sebelum** bagian ini, termasuk
`mahasiswa`, `semester`, dan `kelas_paralel` dengan PK bertipe `BIGINT` signed.
`kelas_paralel` adalah master milik Fariz.

`db/seed.sql` adalah bagian transaksi untuk database demo kosong. Seed master
harus lebih dulu menyediakan kontrak berikut:

| Data master | ID / nilai yang diperlukan |
|---|---|
| Semester pengisian KRS | `id = 1` |
| Empat mahasiswa | `id = 1..4`, IPS berurutan `3.25 / 2.75 / 2.10 / 1.80` |
| Kelas demo penuh | `id = 1`, `semester_id = 1`, `kuota_maksimal = 1` |
| Mata kuliah kelas demo | `kelas_paralel.mk_id` merujuk MK 3 SKS |

Jika ID master berbeda, selaraskan seed transaksi dalam PR integrasi.
Seed ini membuat empat KRS DRAFT; mahasiswa 1 mengisi satu kursi aktif,
mahasiswa 2 dan 3 mengantre (FIFO menurut ID), mahasiswa 4 masih kosong.
Total SKS masing-masing `3 / 0 / 0 / 0`.

Master produksi tetap harus memenuhi semua kasus Task 2: empat MK bernama,
satu MK lama ekuivalen, prasyarat `Basis Data DAN (Web ATAU Mobile)`, akun
dengan bcrypt nyata, dan empat kelompok IPS. `db/testdata/master.sql` hanya
fixture minimal pengujian; jangan dipakai sebagai seed master produksi.

Status dan indeks mengikuti locked decisions. FK detail ke KRS menggunakan
RESTRICT (default MySQL), menggantikan contoh `ON DELETE CASCADE` di plan agar
penghapusan induk tidak menghilangkan riwayat detail. Perubahan status tetap
merupakan cara pembatalan transaksi; larangan delete lain ditegakkan oleh
repository/service pada task berikutnya.

Setelah master digabung dan database `krsync` disiapkan:

```sh
make schema
make seed
# Koneksi alternatif tanpa mengubah Makefile:
make schema MYSQL_ARGS='--host=127.0.0.1 --port=3306 --user=app --password'
```

`MYSQL`, `MYSQL_ARGS`, dan `DB_NAME` dapat dioverride. Seed ditujukan untuk
database kosong, bukan migrasi atau perintah yang diulang pada data aktif.
DDL transaksi tidak mengganti database yang dipilih oleh pemanggil.

## Batas verifikasi

Pengujian integrasi memverifikasi FK, uniqueness KRS/detail, seluruh status,
penolakan status invalid, perlindungan riwayat detail, total SKS, kursi penuh,
dan urutan antre. Integrasi terhadap master produksi menunggu berkas Fariz.
Angka "12 tabel" pada contoh verifikasi PLAN.md tidak konsisten: seluruh DDL
di plan mendefinisikan 16 tabel, termasuk tiga tabel transaksi ini.
PDF spesifikasi dan hasil ekstraksi slide yang dirujuk plan tidak tersedia
di mesin ini; acuan pengerjaan adalah PLAN.md dan draft desain yang tersedia.

### Hasil pemeriksaan lokal

- `go build ./...`, `make build`, `make test`, `make lint`, `make check-fmt`:
  berhasil. Paket aplikasi yang sudah ada belum memiliki unit test.
- `make test-db` dengan MySQL **8.0.44**: berhasil, termasuk 12 kasus
  penolakan constraint dan tiga kelompok uji utama.
- `make schema` kemudian `make seed`: berhasil pada database pengujian
  dengan fixture master; menghasilkan empat KRS DRAFT dan dua antrean.
- `make tools` dan `make dev`: berhasil; log `database terhubung`, halaman
  `GET /` mengembalikan HTTP 200 dengan `<h1>KRSync</h1>`.
- Kompilasi diuji dengan sumber parsial dan enam sumber dalam direktori
  temporer: draft berhasil, final menolak sumber hilang tanpa menimpa output,
  final lengkap berhasil dan hasilnya deterministik.
- GitHub Actions sudah dikonfigurasi; eksekusi di GitHub menunggu push/PR.
