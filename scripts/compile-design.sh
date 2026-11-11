#!/bin/sh
set -eu

mode=${1:-final}
case "$mode" in
    final|draft) ;;
    *) echo "Usage: sh scripts/compile-design.sh [final|draft]" >&2; exit 2 ;;
esac

files="use-case crud-matrix sitemap state-diagram erd kamus-data"
missing=""
for name in $files; do
    if [ ! -s "docs/design/$name.md" ]; then
        missing="$missing $name.md"
    fi
done
if [ "$mode" = final ] && [ -n "$missing" ]; then
    echo "Kompilasi final tertunda. Draft belum tersedia:$missing" >&2
    exit 1
fi

output=docs/design/kompilasi.md
tmp=$(mktemp "$output.XXXXXX")
trap 'rm -f "$tmp"' EXIT HUP INT TERM
{
    printf '# Kompilasi Desain KRSync — Tahap 1\n\n'
    printf 'Disusun oleh Shofwan dari dokumen sumber tim.\n'
    printf 'Dibuat ulang dengan `make design` (lengkap) atau `make design-draft`.\n\n'
    if [ -n "$missing" ]; then
        printf '> **DRAFT — design freeze belum selesai.** Menunggu:%s.\n\n' "$missing"
    else
        printf 'Keenam dokumen sumber tersedia; persetujuan desain tetap melalui review tim.\n\n'
    fi
    for name in $files; do
        printf '\n---\n\n## Dokumen: %s\n\n' "$name"
        printf 'Sumber: [%s.md](%s.md).\n\n' "$name" "$name"
        if [ -s "docs/design/$name.md" ]; then
            cat "docs/design/$name.md"
        else
            printf '**Menunggu draft pemilik dokumen.**\n'
        fi
    done
} > "$tmp"
mv "$tmp" "$output"
