package config

import (
	"errors"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	Addr         string
	DBDSN        string
	CookieSecure bool
}

func Load() (Config, error) {
	_ = godotenv.Load()

	cfg := Config{
		Addr:         getEnv("ADDR", ":8080"),
		DBDSN:        os.Getenv("DB_DSN"),
		CookieSecure: os.Getenv("COOKIE_SECURE") == "true",
	}
	if cfg.DBDSN == "" {
		return cfg, errors.New("DB_DSN belum di-set (cek file .env)")
	}
	return cfg, nil
}

func getEnv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
