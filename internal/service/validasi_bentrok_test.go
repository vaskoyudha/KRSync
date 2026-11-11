package service

import (
	"testing"

	"github.com/vaskoyudha/krsync/internal/model"
)

func kp(id int64, hari, mulai, selesai, ruang string) model.KelasParalel {
	return model.KelasParalel{ID: id, Hari: hari, JamMulai: mulai, JamSelesai: selesai, Ruangan: ruang}
}

func TestBentrokJadwal(t *testing.T) {
	kandidat := kp(9, "SENIN", "08:00", "09:40", "A101")

	t.Run("tidak bentrok beda hari", func(t *testing.T) {
		if got := BentrokJadwal(kandidat, []model.KelasParalel{kp(1, "SELASA", "08:00", "09:40", "B201")}); len(got) != 0 {
			t.Fatalf("want no conflict, got %v", got)
		}
	})

	t.Run("bentrok overlap parsial", func(t *testing.T) {
		if got := BentrokJadwal(kandidat, []model.KelasParalel{kp(2, "SENIN", "09:00", "10:40", "C301")}); len(got) != 1 {
			t.Fatalf("want 1 conflict, got %v", got)
		}
	})

	t.Run("bersambung tepat tidak bentrok", func(t *testing.T) {
		if got := BentrokJadwal(kandidat, []model.KelasParalel{kp(3, "SENIN", "09:40", "11:20", "C301")}); len(got) != 0 {
			t.Fatalf("want no conflict, got %v", got)
		}
	})

	t.Run("bentrok identik", func(t *testing.T) {
		if got := BentrokJadwal(kandidat, []model.KelasParalel{kp(4, "SENIN", "08:00", "09:40", "D401")}); len(got) != 1 {
			t.Fatalf("want 1 conflict, got %v", got)
		}
	})
}

func TestBentrokRuangan(t *testing.T) {
	kandidat := kp(9, "SENIN", "08:00", "09:40", "A101")
	bentrok := BentrokRuangan(kandidat, []model.KelasParalel{kp(5, "SENIN", "08:30", "10:00", "A101")})
	if len(bentrok) != 1 {
		t.Fatalf("want 1 room conflict, got %v", bentrok)
	}
}
