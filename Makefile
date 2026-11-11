MYSQL ?= mysql
MYSQL_ARGS ?= -u app -p
DB_NAME ?= krsync
WGO_VERSION ?= v0.6.3

.PHONY: dev build test test-db schema seed fmt check-fmt lint tools design design-draft

dev:
	wgo run -file .html -file .css ./cmd/web

build:
	go build -o krsync ./cmd/web

test:
	go test ./...

test-db:
	@test -n "$$TEST_DB_DSN" || { echo 'Set TEST_DB_DSN ke MySQL pengujian (lihat docs/SHOFWAN-MINGGU-1.md).'; exit 1; }
	go test -count=1 -v ./db

schema:
	$(MYSQL) $(MYSQL_ARGS) $(DB_NAME) < db/schema.sql

seed:
	$(MYSQL) $(MYSQL_ARGS) $(DB_NAME) < db/seed.sql

fmt:
	gofmt -w .

lint:
	go vet ./...

check-fmt:
	@files="$$(gofmt -l .)" || exit $$?; test -z "$$files" || { printf 'Jalankan make fmt:\n%s\n' "$$files"; exit 1; }

tools:
	go install github.com/bokwoon95/wgo@$(WGO_VERSION)

design:
	sh scripts/compile-design.sh final

design-draft:
	sh scripts/compile-design.sh draft
