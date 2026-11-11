package service

import (
	"fmt"

	"github.com/vaskoyudha/krsync/internal/model"
)

type HasilPrasyarat struct {
	Lolos  bool
	Kurang []string
}

// CekPrasyarat mengevaluasi dua tingkat: grup_kondisi (AND/OR) di tingkat
// grup, dan setiap item di dalam grup harus >= NilaiMin.
// nilai adalah peta mk_id → nilai_indeks terbaik mahasiswa.
func CekPrasyarat(grup []model.PrasyaratGrup, nilai map[int64]float64) HasilPrasyarat {
	var kurang []string

	for _, g := range grup {
		var gagalGrup []string
		for _, it := range g.Items {
			n, ada := nilai[it.MkID]
			if !ada || n < it.NilaiMin {
				gagalGrup = append(gagalGrup, it.MkNama)
			}
		}

		switch g.Kondisi {
		case "OR":
			// grup OR gagal hanya kalau SEMUA item gagal
			if len(gagalGrup) == len(g.Items) {
				kurang = append(kurang, gagalGrup...)
			}
		default: // AND
			kurang = append(kurang, gagalGrup...)
		}
	}

	return HasilPrasyarat{Lolos: len(kurang) == 0, Kurang: kurang}
}

func (h HasilPrasyarat) Pesan() string {
	if h.Lolos {
		return ""
	}
	return fmt.Sprintf("Prasyarat belum terpenuhi: %v", h.Kurang)
}
