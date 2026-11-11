package db_test

import (
	"database/sql"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/go-sql-driver/mysql"
)

// TestTransaksi runs the real DDL and seed against an isolated MySQL database.
// Missing FKs, permissive statuses, duplicate KRS, or incorrect seat totals
// must fail here rather than appear later in the approval/reporting flows.
func TestTransaksi(t *testing.T) {
	dsn := os.Getenv("TEST_DB_DSN")
	if dsn == "" {
		t.Skip("set TEST_DB_DSN to run MySQL integration tests")
	}
	cfg, err := mysql.ParseDSN(dsn)
	if err != nil {
		t.Fatal(err)
	}
	cfg.DBName = ""
	cfg.MultiStatements = true
	admin, err := sql.Open("mysql", cfg.FormatDSN())
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { admin.Close() })
	name := fmt.Sprintf("krsync_test_%d", time.Now().UnixNano())
	if _, err := admin.Exec("CREATE DATABASE `" + name + "` CHARACTER SET utf8mb4"); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		if _, err := admin.Exec("DROP DATABASE `" + name + "`"); err != nil {
			t.Error(err)
		}
	})
	cfg.DBName = name
	db, err := sql.Open("mysql", cfg.FormatDSN())
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	for _, path := range []string{"testdata/master.sql", "schema.sql", "seed.sql"} {
		data, err := os.ReadFile(path)
		if err != nil {
			t.Fatal(err)
		}
		if _, err := db.Exec(string(data)); err != nil {
			t.Fatalf("apply %s: %v", path, err)
		}
	}

	t.Run("seed kelas penuh dan antre FIFO", func(t *testing.T) {
		var filled, quota, total int
		if err := db.QueryRow(`SELECT COUNT(*), MAX(k.kuota_maksimal)
			FROM krs_detail d JOIN kelas_paralel k ON k.id = d.kelas_paralel_id
			WHERE d.kelas_paralel_id = 1 AND d.status_baris = 'AKTIF'`).Scan(&filled, &quota); err != nil {
			t.Fatal(err)
		}
		if filled != 1 || quota != filled {
			t.Fatalf("filled=%d, quota=%d; want 1/1", filled, quota)
		}
		if err := db.QueryRow("SELECT COUNT(*) FROM krs").Scan(&total); err != nil || total != 4 {
			t.Fatalf("KRS count=%d, err=%v; want 4", total, err)
		}
		if err := db.QueryRow(`SELECT COUNT(*) FROM krs k WHERE k.total_sks <>
			(SELECT COALESCE(SUM(m.sks),0) FROM krs_detail d
			 JOIN kelas_paralel c ON c.id=d.kelas_paralel_id JOIN mata_kuliah m ON m.id=c.mk_id
			 WHERE d.krs_id=k.id AND d.status_baris='AKTIF')`).Scan(&total); err != nil || total != 0 {
			t.Fatalf("inconsistent SKS rows=%d, err=%v", total, err)
		}
		var order string
		if err := db.QueryRow(`SELECT GROUP_CONCAT(mahasiswa_id ORDER BY id)
			FROM daftar_tunggu WHERE kelas_paralel_id=1 AND status_antre='MENUNGGU'`).Scan(&order); err != nil || order != "2,3" {
			t.Fatalf("queue=%q, err=%v; want 2,3", order, err)
		}
	})

	t.Run("constraint menolak data invalid", func(t *testing.T) {
		cases := []struct {
			name  string
			query string
			code  uint16
		}{
			{"duplicate KRS", "INSERT INTO krs (mahasiswa_id,semester_id) VALUES (1,1)", 1062},
			{"duplicate detail", "INSERT INTO krs_detail (krs_id,kelas_paralel_id) VALUES (1,1)", 1062},
			{"missing student", "INSERT INTO krs (mahasiswa_id,semester_id) VALUES (999,1)", 1452},
			{"missing semester", "INSERT INTO krs (mahasiswa_id,semester_id) VALUES (1,999)", 1452},
			{"missing KRS", "INSERT INTO krs_detail (krs_id,kelas_paralel_id) VALUES (999,1)", 1452},
			{"missing class", "INSERT INTO krs_detail (krs_id,kelas_paralel_id) VALUES (1,999)", 1452},
			{"missing waitlist student", "INSERT INTO daftar_tunggu (mahasiswa_id,kelas_paralel_id) VALUES (999,1)", 1452},
			{"missing waitlist class", "INSERT INTO daftar_tunggu (mahasiswa_id,kelas_paralel_id) VALUES (1,999)", 1452},
			{"invalid KRS status", "UPDATE krs SET status_krs='SALAH' WHERE id=1", 3819},
			{"invalid detail status", "UPDATE krs_detail SET status_baris='SALAH' WHERE id=1", 3819},
			{"invalid waitlist status", "UPDATE daftar_tunggu SET status_antre='SALAH' WHERE id=1", 3819},
			{"protect detail history", "DELETE FROM krs WHERE id=1", 1451},
		}
		for _, c := range cases {
			t.Run(c.name, func(t *testing.T) {
				tx, err := db.Begin()
				if err != nil {
					t.Fatal(err)
				}
				defer tx.Rollback()
				_, err = tx.Exec(c.query)
				me, ok := err.(*mysql.MySQLError)
				if !ok || me.Number != c.code {
					t.Fatalf("got %v, want MySQL error %d", err, c.code)
				}
			})
		}
	})

	t.Run("semua status kontrak diterima", func(t *testing.T) {
		for _, c := range []struct{ table, column, values string }{
			{"krs", "status_krs", "DRAFT DIAJUKAN REVISI DISETUJUI_TERKUNCI MASA_PERUBAHAN TERKUNCI_FINAL"},
			{"krs_detail", "status_baris", "AKTIF DIBATALKAN"},
			{"daftar_tunggu", "status_antre", "MENUNGGU DIPROMOSIKAN GAGAL BATAL"},
		} {
			for _, status := range strings.Fields(c.values) {
				if _, err := db.Exec("UPDATE "+c.table+" SET "+c.column+"=? WHERE id=1", status); err != nil {
					t.Errorf("%s %s: %v", c.table, status, err)
				}
			}
		}
	})
}
