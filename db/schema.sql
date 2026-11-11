-- ============================================================
-- KRSync - db/schema.sql  (BAGIAN MASTER - Fariz)
-- Sumber: PLAN.md Task 2 (Langkah 1-4). MySQL 8.0.16+ (CHECK ditegakkan).
-- Isi : users, sessions, semester, kurikulum, mata_kuliah, ekuivalensi_mk,
--       prasyarat_grup, prasyarat_item, dosen_wali, mahasiswa,
--       riwayat_nilai, kelas_paralel
-- Bagian transaksi (krs, krs_detail, daftar_tunggu) = Shofwan; tempelkan
-- di bagian paling bawah file ini (lihat penanda).
-- Konvensi: PK = id; FK = <nama_tabel>_id (kecuali mk_id, mk_baru_id,
-- mk_lama_id, mk_prasyarat_id, dosen_id yang sudah dikunci di PLAN).
-- Data master di-soft-delete lewat deleted_at.
-- ============================================================

CREATE DATABASE IF NOT EXISTS krsync CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE krsync;

-- ------------------------------------------------------------
-- Auth
-- ------------------------------------------------------------
CREATE TABLE users (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    nama          VARCHAR(100) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role          VARCHAR(20)  NOT NULL,
    is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_users_role CHECK (role IN ('ADMIN_PRODI','MAHASISWA','DOSEN_WALI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sessions (
    token      VARCHAR(64) PRIMARY KEY,
    user_id    BIGINT NOT NULL,
    expires_at DATETIME NOT NULL,
    CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Periode akademik
-- ------------------------------------------------------------
CREATE TABLE semester (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    tahun_ajaran    VARCHAR(9)  NOT NULL,
    periode         VARCHAR(10) NOT NULL,
    status_periode  VARCHAR(30) NOT NULL DEFAULT 'PENGISIAN_KRS',
    tanggal_mulai   DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_semester (tahun_ajaran, periode),
    CONSTRAINT chk_semester_periode CHECK (periode IN ('GANJIL','GENAP')),
    CONSTRAINT chk_semester_status CHECK (status_periode IN ('PENGISIAN_KRS','PERKULIAHAN','MASA_PERUBAHAN_KRS','SELESAI'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Kurikulum dan mata kuliah
-- ------------------------------------------------------------
CREATE TABLE kurikulum (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    kode        VARCHAR(20)  NOT NULL UNIQUE,
    nama        VARCHAR(100) NOT NULL,
    tahun_mulai YEAR NOT NULL,
    is_active   TINYINT(1) NOT NULL DEFAULT 1,
    created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NULL,
    deleted_at  TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE mata_kuliah (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    kurikulum_id BIGINT NOT NULL,
    kode         VARCHAR(20)  NOT NULL,
    nama         VARCHAR(120) NOT NULL,
    sks          TINYINT NOT NULL,
    semester_ke  TINYINT NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NULL,
    deleted_at   TIMESTAMP NULL,
    UNIQUE KEY uq_mk (kurikulum_id, kode),
    CONSTRAINT fk_mk_kurikulum FOREIGN KEY (kurikulum_id) REFERENCES kurikulum(id),
    CONSTRAINT chk_mk_sks CHECK (sks BETWEEN 1 AND 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ekuivalensi_mk (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    mk_baru_id BIGINT NOT NULL,
    mk_lama_id BIGINT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_ekuivalensi (mk_baru_id, mk_lama_id),
    CONSTRAINT fk_eku_baru FOREIGN KEY (mk_baru_id) REFERENCES mata_kuliah(id),
    CONSTRAINT fk_eku_lama FOREIGN KEY (mk_lama_id) REFERENCES mata_kuliah(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE prasyarat_grup (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    mk_id        BIGINT NOT NULL,
    grup_kondisi VARCHAR(3) NOT NULL,
    created_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_grup_kondisi CHECK (grup_kondisi IN ('AND','OR')),
    CONSTRAINT fk_grup_mk FOREIGN KEY (mk_id) REFERENCES mata_kuliah(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE prasyarat_item (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    grup_id         BIGINT NOT NULL,
    mk_prasyarat_id BIGINT NOT NULL,
    nilai_min       DECIMAL(3,2) NOT NULL DEFAULT 2.00,
    CONSTRAINT fk_item_grup FOREIGN KEY (grup_id) REFERENCES prasyarat_grup(id) ON DELETE CASCADE,
    CONSTRAINT fk_item_mk   FOREIGN KEY (mk_prasyarat_id) REFERENCES mata_kuliah(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Dosen, mahasiswa, riwayat nilai
-- ------------------------------------------------------------
CREATE TABLE dosen_wali (
    id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    nidn    VARCHAR(20)  NOT NULL UNIQUE,
    nama    VARCHAR(100) NOT NULL,
    CONSTRAINT fk_dosen_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE mahasiswa (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id       BIGINT NOT NULL UNIQUE,
    nim           VARCHAR(20)  NOT NULL UNIQUE,
    nama          VARCHAR(100) NOT NULL,
    angkatan      YEAR NOT NULL,
    kurikulum_id  BIGINT NOT NULL,
    dosen_wali_id BIGINT NULL,
    ips_terakhir  DECIMAL(3,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_mhs_user      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_mhs_kurikulum FOREIGN KEY (kurikulum_id) REFERENCES kurikulum(id),
    CONSTRAINT fk_mhs_dosen     FOREIGN KEY (dosen_wali_id) REFERENCES dosen_wali(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE riwayat_nilai (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    mahasiswa_id BIGINT NOT NULL,
    mk_id        BIGINT NOT NULL,
    semester_id  BIGINT NOT NULL,
    nilai_indeks DECIMAL(3,2) NOT NULL,
    nilai_huruf  VARCHAR(2) NOT NULL,
    is_final     TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY uq_nilai (mahasiswa_id, mk_id, semester_id),
    KEY idx_nilai_mhs_mk (mahasiswa_id, mk_id),
    CONSTRAINT fk_nilai_mhs FOREIGN KEY (mahasiswa_id) REFERENCES mahasiswa(id),
    CONSTRAINT fk_nilai_mk  FOREIGN KEY (mk_id) REFERENCES mata_kuliah(id),
    CONSTRAINT fk_nilai_sem FOREIGN KEY (semester_id) REFERENCES semester(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Kelas paralel (data master jadwal; diacu krs_detail dan daftar_tunggu)
-- ------------------------------------------------------------
CREATE TABLE kelas_paralel (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    mk_id          BIGINT NOT NULL,
    semester_id    BIGINT NOT NULL,
    kode_kelas     VARCHAR(10) NOT NULL,
    dosen_id       BIGINT NULL,
    hari           VARCHAR(7) NOT NULL,
    jam_mulai      TIME NOT NULL,
    jam_selesai    TIME NOT NULL,
    ruangan        VARCHAR(20) NOT NULL,
    kuota_maksimal SMALLINT NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP NULL,
    deleted_at     TIMESTAMP NULL,
    UNIQUE KEY uq_kelas (mk_id, semester_id, kode_kelas),
    KEY idx_kelas_sem (semester_id, mk_id),
    CONSTRAINT chk_kelas_hari  CHECK (hari IN ('SENIN','SELASA','RABU','KAMIS','JUMAT','SABTU')),
    CONSTRAINT chk_kelas_jam   CHECK (jam_mulai < jam_selesai),
    CONSTRAINT chk_kelas_kuota CHECK (kuota_maksimal > 0),
    CONSTRAINT fk_kelas_mk    FOREIGN KEY (mk_id) REFERENCES mata_kuliah(id),
    CONSTRAINT fk_kelas_sem   FOREIGN KEY (semester_id) REFERENCES semester(id),
    CONSTRAINT fk_kelas_dosen FOREIGN KEY (dosen_id) REFERENCES dosen_wali(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- >>> BAGIAN TRANSAKSI (Shofwan) DITEMPEL DI BAWAH INI <<<
-- krs, krs_detail, daftar_tunggu  (PLAN.md Task 2 Langkah 4)
-- ============================================================
