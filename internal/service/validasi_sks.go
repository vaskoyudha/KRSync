package service

// BatasSKS mengikuti Aturan Bisnis KRSync: IPS >= 3.00 → 24 SKS,
// 2.50–2.99 → 21, 2.00–2.49 → 18, < 2.00 → 15.
func BatasSKS(ips float64) int {
	switch {
	case ips >= 3.00:
		return 24
	case ips >= 2.50:
		return 21
	case ips >= 2.00:
		return 18
	default:
		return 15
	}
}

func SKSMelebihi(totalSKS, tambahan, batas int) bool {
	return totalSKS+tambahan > batas
}
