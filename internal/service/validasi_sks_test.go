package service

import "testing"

func TestBatasSKS(t *testing.T) {
	cases := []struct {
		ips  float64
		want int
	}{
		{3.51, 24}, {3.00, 24}, {2.99, 21}, {2.50, 21},
		{2.49, 18}, {2.00, 18}, {1.99, 15}, {0.00, 15},
	}
	for _, c := range cases {
		if got := BatasSKS(c.ips); got != c.want {
			t.Errorf("BatasSKS(%.2f) = %d, want %d", c.ips, got, c.want)
		}
	}
}
