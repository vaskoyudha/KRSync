package service

import (
	"testing"

	"github.com/vaskoyudha/krsync/internal/model"
)

func TestNilaiTerbaik(t *testing.T) {
	riwayat := []model.RiwayatNilai{
		{MkID: 10, NilaiIndeks: 2.00, IsFinal: true},  // MK baru
		{MkID: 90, NilaiIndeks: 3.50, IsFinal: true},  // MK lama, ekuivalen
		{MkID: 91, NilaiIndeks: 4.00, IsFinal: false}, // belum final, harus diabaikan
	}

	t.Run("ambil nilai tertinggi termasuk ekuivalensi", func(t *testing.T) {
		n, ok := NilaiTerbaik(riwayat, 10, []int64{90})
		if !ok || n != 3.50 {
			t.Fatalf("want 3.50 ok, got %.2f %v", n, ok)
		}
	})

	t.Run("abaikan nilai non-final", func(t *testing.T) {
		n, _ := NilaiTerbaik(riwayat, 10, []int64{91})
		if n == 4.00 {
			t.Fatal("nilai non-final tidak boleh dipakai")
		}
	})

	t.Run("tanpa riwayat", func(t *testing.T) {
		if _, ok := NilaiTerbaik(riwayat, 77, nil); ok {
			t.Fatal("want not ok")
		}
	})
}

func TestPetaNilai(t *testing.T) {
	p := PetaNilai([]model.RiwayatNilai{
		{MkID: 10, NilaiIndeks: 2.75, IsFinal: true},
		{MkID: 10, NilaiIndeks: 3.25, IsFinal: true},
		{MkID: 10, NilaiIndeks: 4.00, IsFinal: false},
	})
	if p[10] != 3.25 {
		t.Fatalf("want best 3.25, got %.2f", p[10])
	}
}
