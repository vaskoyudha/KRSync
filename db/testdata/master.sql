-- Fixture terisolasi, BUKAN schema/seed master produksi milik Fariz.
-- Hanya kolom parent yang dibutuhkan pengujian transaksi; tipe FK mengikuti PLAN.md.
CREATE TABLE mahasiswa (
    id BIGINT PRIMARY KEY,
    ips_terakhir DECIMAL(3,2) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE semester (id BIGINT PRIMARY KEY) ENGINE=InnoDB;
CREATE TABLE mata_kuliah (
    id BIGINT PRIMARY KEY,
    sks TINYINT NOT NULL
) ENGINE=InnoDB;
CREATE TABLE kelas_paralel (
    id BIGINT PRIMARY KEY,
    mk_id BIGINT NOT NULL,
    semester_id BIGINT NOT NULL,
    kuota_maksimal SMALLINT NOT NULL,
    FOREIGN KEY (mk_id) REFERENCES mata_kuliah(id),
    FOREIGN KEY (semester_id) REFERENCES semester(id)
) ENGINE=InnoDB;
INSERT INTO mahasiswa VALUES (1,3.25),(2,2.75),(3,2.10),(4,1.80);
INSERT INTO semester VALUES (1);
INSERT INTO mata_kuliah VALUES (1,3);
INSERT INTO kelas_paralel VALUES (1,1,1,1);
