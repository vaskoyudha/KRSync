package model

type PrasyaratGrup struct {
	ID      int64
	MkID    int64
	Kondisi string // "AND" | "OR"
	Items   []PrasyaratItem
}

type PrasyaratItem struct {
	MkID     int64
	MkNama   string
	NilaiMin float64
}
