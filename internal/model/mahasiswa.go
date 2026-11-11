package model

type RiwayatNilai struct {
	ID          int64
	MahasiswaID int64
	MkID        int64
	MkNama      string
	NilaiIndeks float64
	NilaiHuruf  string
	IsFinal     bool
}
