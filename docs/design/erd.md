# ERD (Bagian Master)

Diagram dibuat dari `db/schema.sql`. Tabel transaksi (`krs`, `krs_detail`, `daftar_tunggu`) ditambahkan oleh Shofwan pada ERD gabungan; relasi yang menuju ke sana diberi catatan di bawah diagram.

```mermaid
erDiagram
  users {
    BIGINT id PK
    VARCHAR nama
    VARCHAR email
    VARCHAR password_hash
    VARCHAR role
    TINYINT is_active
    TIMESTAMP created_at
  }
  sessions {
    VARCHAR token PK
    BIGINT user_id FK
    DATETIME expires_at
  }
  semester {
    BIGINT id PK
    VARCHAR tahun_ajaran
    VARCHAR periode
    VARCHAR status_periode
    DATE tanggal_mulai
    DATE tanggal_selesai
    TIMESTAMP created_at
  }
  kurikulum {
    BIGINT id PK
    VARCHAR kode
    VARCHAR nama
    YEAR tahun_mulai
    TINYINT is_active
    TIMESTAMP created_at
    TIMESTAMP updated_at
    TIMESTAMP deleted_at
  }
  mata_kuliah {
    BIGINT id PK
    BIGINT kurikulum_id FK
    VARCHAR kode
    VARCHAR nama
    TINYINT sks
    TINYINT semester_ke
    TIMESTAMP created_at
    TIMESTAMP updated_at
    TIMESTAMP deleted_at
  }
  ekuivalensi_mk {
    BIGINT id PK
    BIGINT mk_baru_id FK
    BIGINT mk_lama_id FK
    TIMESTAMP created_at
  }
  prasyarat_grup {
    BIGINT id PK
    BIGINT mk_id FK
    VARCHAR grup_kondisi
    TIMESTAMP created_at
  }
  prasyarat_item {
    BIGINT id PK
    BIGINT grup_id FK
    BIGINT mk_prasyarat_id FK
    DECIMAL nilai_min
  }
  dosen_wali {
    BIGINT id PK
    BIGINT user_id FK
    VARCHAR nidn
    VARCHAR nama
  }
  mahasiswa {
    BIGINT id PK
    BIGINT user_id FK
    VARCHAR nim
    VARCHAR nama
    YEAR angkatan
    BIGINT kurikulum_id FK
    BIGINT dosen_wali_id FK
    DECIMAL ips_terakhir
  }
  riwayat_nilai {
    BIGINT id PK
    BIGINT mahasiswa_id FK
    BIGINT mk_id FK
    BIGINT semester_id FK
    DECIMAL nilai_indeks
    VARCHAR nilai_huruf
    TINYINT is_final
  }
  kelas_paralel {
    BIGINT id PK
    BIGINT mk_id FK
    BIGINT semester_id FK
    VARCHAR kode_kelas
    BIGINT dosen_id FK
    VARCHAR hari
    TIME jam_mulai
    TIME jam_selesai
    VARCHAR ruangan
    SMALLINT kuota_maksimal
    TIMESTAMP created_at
    TIMESTAMP updated_at
    TIMESTAMP deleted_at
  }
  users ||--o| sessions : "user_id"
  kurikulum ||--o{ mata_kuliah : "kurikulum_id"
  mata_kuliah ||--o{ ekuivalensi_mk : "mk_baru_id"
  mata_kuliah ||--o{ ekuivalensi_mk : "mk_lama_id"
  mata_kuliah ||--o{ prasyarat_grup : "mk_id"
  prasyarat_grup ||--o{ prasyarat_item : "grup_id"
  mata_kuliah ||--o{ prasyarat_item : "mk_prasyarat_id"
  users ||--o| dosen_wali : "user_id"
  users ||--o| mahasiswa : "user_id"
  kurikulum ||--o{ mahasiswa : "kurikulum_id"
  dosen_wali |o--o{ mahasiswa : "dosen_wali_id"
  mahasiswa ||--o{ riwayat_nilai : "mahasiswa_id"
  mata_kuliah ||--o{ riwayat_nilai : "mk_id"
  semester ||--o{ riwayat_nilai : "semester_id"
  mata_kuliah ||--o{ kelas_paralel : "mk_id"
  semester ||--o{ kelas_paralel : "semester_id"
  dosen_wali |o--o{ kelas_paralel : "dosen_id"
```

## Catatan relasi

- `users` 1—1 `mahasiswa` dan `users` 1—1 `dosen_wali` lewat `user_id`; Admin Prodi hanya punya baris di `users`.
- `ekuivalensi_mk` menghubungkan dua baris `mata_kuliah` (`mk_baru_id` dan `mk_lama_id`).
- `prasyarat_grup` → `prasyarat_item`: tepat dua tingkat (grup AND/OR di atas butir MK), tanpa nesting.
- `kelas_paralel.dosen_id` menunjuk `dosen_wali.id`.
- Tabel transaksi menunjuk ke tabel ini: `krs.mahasiswa_id`/`semester_id`, `krs_detail.kelas_paralel_id`, `daftar_tunggu.mahasiswa_id`/`kelas_paralel_id`.
