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

type KelasParalel struct {
	ID            int64
	MkID          int64
	MkNama        string
	SemesterID    int64
	KodeKelas     string
	DosenID       int64
	Hari          string
	JamMulai      string // "HH:MM"
	JamSelesai    string // "HH:MM"
	Ruangan       string
	KuotaMaksimal int
	JumlahTerisi  int
}
