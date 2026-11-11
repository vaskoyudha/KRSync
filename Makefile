.PHONY: dev build test db schema seed fmt lint

dev:
	wgo run -file .html -file .css ./cmd/web

build:
	go build -o krsync ./cmd/web

test:
	go test ./...

schema:
	mysql -u app -p krsync < db/schema.sql

seed:
	mysql -u app -p krsync < db/seed.sql

fmt:
	gofmt -w .

lint:
	go vet ./...
