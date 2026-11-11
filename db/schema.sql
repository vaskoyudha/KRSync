-- Task 2 — bagian transaksi (Shofwan).
-- Terapkan DDL master Fariz lebih dahulu pada database yang sama:
-- mahasiswa, semester, kelas_paralel (lihat docs/SHOFWAN-MINGGU-1.md).

CREATE TABLE krs (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    mahasiswa_id  BIGINT NOT NULL,
    semester_id   BIGINT NOT NULL,
    status_krs    VARCHAR(25) NOT NULL DEFAULT 'DRAFT',
    total_sks     SMALLINT NOT NULL DEFAULT 0,
    catatan_dosen TEXT NULL,
    submitted_at  DATETIME NULL,
    approved_at   DATETIME NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NULL,
    UNIQUE KEY uq_krs (mahasiswa_id, semester_id),
    CONSTRAINT chk_krs_status CHECK (status_krs IN ('DRAFT','DIAJUKAN','REVISI','DISETUJUI_TERKUNCI','MASA_PERUBAHAN','TERKUNCI_FINAL')),
    CONSTRAINT fk_krs_mhs FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(id),
    CONSTRAINT fk_krs_sem FOREIGN KEY (semester_id) REFERENCES semester(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE krs_detail (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    krs_id           BIGINT NOT NULL,
    kelas_paralel_id  BIGINT NOT NULL,
    status_baris     VARCHAR(15) NOT NULL DEFAULT 'AKTIF',
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_detail (krs_id, kelas_paralel_id),
    CONSTRAINT chk_detail_status CHECK (status_baris IN ('AKTIF','DIBATALKAN')),
    -- Riwayat transaksi dipertahankan; pembatalan melalui status_baris.
    CONSTRAINT fk_detail_krs FOREIGN KEY (krs_id) REFERENCES krs(id),
    CONSTRAINT fk_detail_kelas FOREIGN KEY (kelas_paralel_id) REFERENCES kelas_paralel(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE daftar_tunggu (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    mahasiswa_id     BIGINT NOT NULL,
    kelas_paralel_id  BIGINT NOT NULL,
    status_antre     VARCHAR(15) NOT NULL DEFAULT 'MENUNGGU',
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_antre_kelas (kelas_paralel_id, status_antre, id),
    KEY idx_antre_mhs (mahasiswa_id),
    CONSTRAINT chk_antre_status CHECK (status_antre IN ('MENUNGGU','DIPROMOSIKAN','GAGAL','BATAL')),
    CONSTRAINT fk_antre_mhs FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(id),
    CONSTRAINT fk_antre_kelas FOREIGN KEY (kelas_paralel_id) REFERENCES kelas_paralel(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
