-- ============================================================
-- KRSync - db/seed.sql  (BAGIAN MASTER - Fariz)
-- Dijalankan setelah db/schema.sql. Password login (bcrypt, cost 10):
--   admin@krsync.test / admin123
--   dosen@krsync.test / dosen123
--   budi|citra|dian|eko@krsync.test / mhs123
-- Bagian transaksi (krs, krs_detail, daftar_tunggu, kelas penuh) = Shofwan
-- dan Task 21 (seed matrix).
-- ============================================================
USE krsync;

-- Hash bcrypt: admin123, dosen123, mhs123 (PHP password_hash, prefiks $2a$)
SET @h_admin = '$2a$10$zv4/T8xmQj.yEDVQ16bUruVt/.g63FJcmDpgirEU5HsaToJoq13R2';
SET @h_dosen = '$2a$10$ZKRNpIwnWqwN81XNcpVDbOgDD3NdMGyInWXKWb.VOKiANm80855W2';
SET @h_mhs   = '$2a$10$0Ub.NHnu.BgQSGV1.Z1IL.lpoJS5FUwXYfele7fEI3hQrIXEzx1TS';

INSERT INTO users (id, nama, email, password_hash, role) VALUES
(1, 'Admin Prodi',                  'admin@krsync.test', @h_admin, 'ADMIN_PRODI'),
(2, 'Dr. Bambang Sutrisno, M.Kom',  'dosen@krsync.test', @h_dosen, 'DOSEN_WALI'),
(3, 'Budi Santoso',                 'budi@krsync.test',  @h_mhs,   'MAHASISWA'),
(4, 'Citra Lestari',                'citra@krsync.test', @h_mhs,   'MAHASISWA'),
(5, 'Dian Pratama',                 'dian@krsync.test',  @h_mhs,   'MAHASISWA'),
(6, 'Eko Wijaya',                   'eko@krsync.test',   @h_mhs,   'MAHASISWA');

INSERT INTO kurikulum (id, kode, nama, tahun_mulai, is_active) VALUES
(1, 'K2018', 'Kurikulum 2018 (Lama)', 2018, 1),
(2, 'K2024', 'Kurikulum 2024 (Baru)', 2024, 1);

-- Empat MK bernama dari tugas + satu MK kurikulum lama untuk ekuivalensi
INSERT INTO mata_kuliah (id, kurikulum_id, kode, nama, sks, semester_ke) VALUES
(1, 2, 'IF101', 'Basis Data',          3, 3),
(2, 2, 'IF201', 'Pemrograman Web',     3, 4),
(3, 2, 'IF202', 'Pemrograman Mobile',  3, 4),
(4, 2, 'IF301', 'Basis Data Lanjut',   3, 5),
(5, 1, 'TI210', 'Pemrograman Web (K2018)', 3, 4);

-- Pemrograman Web (K2024) setara dengan Pemrograman Web (K2018)
INSERT INTO ekuivalensi_mk (id, mk_baru_id, mk_lama_id) VALUES
(1, 2, 5);

-- Basis Data Lanjut: Basis Data DAN (Pemrograman Web ATAU Pemrograman Mobile)
INSERT INTO prasyarat_grup (id, mk_id, grup_kondisi) VALUES
(1, 4, 'AND'),
(2, 4, 'OR');
INSERT INTO prasyarat_item (id, grup_id, mk_prasyarat_id, nilai_min) VALUES
(1, 1, 1, 2.00),
(2, 2, 2, 2.00),
(3, 2, 3, 2.00);

INSERT INTO semester (id, tahun_ajaran, periode, status_periode, tanggal_mulai, tanggal_selesai) VALUES
(1, '2024/2025', 'GANJIL', 'SELESAI',        '2024-09-01', '2025-01-31'),
(2, '2024/2025', 'GENAP',  'SELESAI',        '2025-02-17', '2025-07-31'),
(3, '2025/2026', 'GANJIL', 'PENGISIAN_KRS',  '2025-08-25', '2026-01-31');

INSERT INTO dosen_wali (id, user_id, nidn, nama) VALUES
(1, 2, '0011223301', 'Dr. Bambang Sutrisno, M.Kom');

-- IPS terakhir 3.25 / 2.75 / 2.10 / 1.80 (batas SKS 24 / 21 / 18 / 15)
INSERT INTO mahasiswa (id, user_id, nim, nama, angkatan, kurikulum_id, dosen_wali_id, ips_terakhir) VALUES
(1, 3, '2304130001', 'Budi Santoso',  2023, 2, 1, 3.25),
(2, 4, '2304130002', 'Citra Lestari', 2023, 2, 1, 2.75),
(3, 5, '2304130003', 'Dian Pratama',  2023, 2, 1, 2.10),
(4, 6, '2304130004', 'Eko Wijaya',    2023, 2, 1, 1.80);

-- Budi: lulus Basis Data (A) + Pemrograman Web K2018 (B, lewat ekuivalensi)
-- Citra: lulus Basis Data (B) + Pemrograman Mobile (C)
-- Dian: Basis Data C saja (grup OR belum terpenuhi)
-- Eko: belum punya nilai
INSERT INTO riwayat_nilai (mahasiswa_id, mk_id, semester_id, nilai_indeks, nilai_huruf, is_final) VALUES
(1, 1, 1, 4.00, 'A', 1),
(1, 5, 1, 3.00, 'B', 1),
(2, 1, 1, 3.00, 'B', 1),
(2, 3, 2, 2.00, 'C', 1),
(3, 1, 1, 2.00, 'C', 1);

-- Kelas semester berjalan; Basis Data Lanjut A berkuota 1 untuk demo kelas penuh
INSERT INTO kelas_paralel (id, mk_id, semester_id, kode_kelas, dosen_id, hari, jam_mulai, jam_selesai, ruangan, kuota_maksimal) VALUES
(1, 1, 3, 'A', 1, 'SENIN',  '08:00:00', '09:40:00', 'R101', 40),
(2, 2, 3, 'A', 1, 'SELASA', '10:00:00', '11:40:00', 'R102', 40),
(3, 3, 3, 'A', 1, 'RABU',   '08:00:00', '09:40:00', 'R103', 40),
(4, 4, 3, 'A', 1, 'KAMIS',  '08:00:00', '09:40:00', 'R104', 1);
