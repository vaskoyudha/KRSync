package service

import (
	"reflect"
	"testing"

	"github.com/vaskoyudha/krsync/internal/model"
)

func grupAnd(items ...model.PrasyaratItem) model.PrasyaratGrup {
	return model.PrasyaratGrup{ID: 1, Kondisi: "AND", Items: items}
}

func TestCekPrasyarat(t *testing.T) {
	// Basis Data DAN (Pemrograman Web ATAU Pemrograman Mobile)
	grup := []model.PrasyaratGrup{
		grupAnd(model.PrasyaratItem{MkID: 10, MkNama: "Basis Data", NilaiMin: 2.00}),
		{ID: 2, Kondisi: "OR", Items: []model.PrasyaratItem{
			{MkID: 20, MkNama: "Pemrograman Web", NilaiMin: 2.00},
			{MkID: 21, MkNama: "Pemrograman Mobile", NilaiMin: 2.00},
		}},
	}

	t.Run("lolos ketika semua grup terpenuhi", func(t *testing.T) {
		got := CekPrasyarat(grup, map[int64]float64{10: 3.00, 20: 2.75})
		if !got.Lolos || len(got.Kurang) != 0 {
			t.Fatalf("want lolos, got %+v", got)
		}
	})

	t.Run("lolos lewat cabang OR kedua", func(t *testing.T) {
		got := CekPrasyarat(grup, map[int64]float64{10: 2.00, 21: 2.50})
		if !got.Lolos {
			t.Fatalf("want lolos, got %+v", got)
		}
	})

	t.Run("gagal menyebut MK yang kurang", func(t *testing.T) {
		got := CekPrasyarat(grup, map[int64]float64{20: 3.00})
		if got.Lolos {
			t.Fatal("want gagal, got lolos")
		}
		want := []string{"Basis Data"}
		if !reflect.DeepEqual(got.Kurang, want) {
			t.Fatalf("Kurang = %v, want %v", got.Kurang, want)
		}
	})

	t.Run("nilai di bawah batas dianggap tidak lulus", func(t *testing.T) {
		got := CekPrasyarat(grup, map[int64]float64{10: 1.99, 20: 3.00})
		if got.Lolos {
			t.Fatal("want gagal, got lolos")
		}
	})
}
