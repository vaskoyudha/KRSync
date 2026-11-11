package service

import "github.com/vaskoyudha/krsync/internal/model"

// NilaiTerbaik mencari nilai_indeks final tertinggi untuk sebuah MK,
// termasuk nilai dari MK lama yang ekuivalen (kurikulum lama).
func NilaiTerbaik(riwayat []model.RiwayatNilai, mkID int64, ekuivalen []int64) (float64, bool) {
	relevan := map[int64]bool{mkID: true}
	for _, e := range ekuivalen {
		relevan[e] = true
	}

	best, ada := 0.0, false
	for _, r := range riwayat {
		if !r.IsFinal || !relevan[r.MkID] {
			continue
		}
		if !ada || r.NilaiIndeks > best {
			best, ada = r.NilaiIndeks, true
		}
	}
	return best, ada
}

// PetaNilai memetakan mk_id → nilai final tertinggi, dipakai CekPrasyarat.
func PetaNilai(riwayat []model.RiwayatNilai) map[int64]float64 {
	peta := make(map[int64]float64)
	for _, r := range riwayat {
		if !r.IsFinal {
			continue
		}
		if v, ok := peta[r.MkID]; !ok || r.NilaiIndeks > v {
			peta[r.MkID] = r.NilaiIndeks
		}
	}
	return peta
}
