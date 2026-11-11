-- Task 2 — bagian transaksi (Shofwan), untuk database demo kosong.
-- Jalankan SETELAH seed master Fariz. Kontrak ID/kuota/SKS:
-- docs/SHOFWAN-MINGGU-1.md. Jangan gunakan fixture testdata untuk produksi.

START TRANSACTION;

INSERT INTO krs (id, mahasiswa_id, semester_id, status_krs, total_sks) VALUES
(1, 1, 1, 'DRAFT', 3),
(2, 2, 1, 'DRAFT', 0),
(3, 3, 1, 'DRAFT', 0),
(4, 4, 1, 'DRAFT', 0);

-- Satu kursi terisi pada kelas dengan kuota_maksimal = 1.
INSERT INTO krs_detail (id, krs_id, kelas_paralel_id, status_baris) VALUES
(1, 1, 1, 'AKTIF');

-- FIFO menggunakan id, bukan created_at (timestamp dapat sama).
INSERT INTO daftar_tunggu (id, mahasiswa_id, kelas_paralel_id, status_antre) VALUES
(1, 2, 1, 'MENUNGGU'),
(2, 3, 1, 'MENUNGGU');

COMMIT;
