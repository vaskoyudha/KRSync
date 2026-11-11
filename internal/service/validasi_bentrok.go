package service

import "github.com/vaskoyudha/krsync/internal/model"

func overlap(a, b model.KelasParalel) bool {
	return a.JamMulai < b.JamSelesai && a.JamSelesai > b.JamMulai
}

// BentrokJadwal mengembalikan kelas yang beririsan waktunya pada hari yang sama.
func BentrokJadwal(kandidat model.KelasParalel, diambil []model.KelasParalel) []model.KelasParalel {
	var hasil []model.KelasParalel
	for _, k := range diambil {
		if k.ID == kandidat.ID {
			continue
		}
		if k.Hari == kandidat.Hari && overlap(kandidat, k) {
			hasil = append(hasil, k)
		}
	}
	return hasil
}

// BentrokRuangan memeriksa pemakaian ruangan yang sama pada waktu beririsan.
func BentrokRuangan(kandidat model.KelasParalel, sekelas []model.KelasParalel) []model.KelasParalel {
	var hasil []model.KelasParalel
	for _, k := range sekelas {
		if k.ID == kandidat.ID {
			continue
		}
		if k.Ruangan == kandidat.Ruangan && k.Hari == kandidat.Hari && overlap(kandidat, k) {
			hasil = append(hasil, k)
		}
	}
	return hasil
}
