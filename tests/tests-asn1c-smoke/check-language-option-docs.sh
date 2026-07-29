#!/usr/bin/env sh

set -e

top_srcdir=${top_srcdir:-../..}

SRC_MAIN="${top_srcdir}/asn1c/asn1c.c"
DOC_MAN_MD="${top_srcdir}/doc/man/asn1c.man.md"
DOC_USAGE_TEX="${top_srcdir}/doc/docsrc/asn1c-usage.tex"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

for f in "${SRC_MAIN}" "${DOC_MAN_MD}" "${DOC_USAGE_TEX}"; do
    [ -f "$f" ] || die "$f not found (moved, renamed, or missing from EXTRA_DIST?)"
done

# Every -f<flag> parsed by the 'f' case in asn1c.c must have a row/entry in
# both doc/man/asn1c.man.md and doc/docsrc/asn1c-usage.tex, so the two
# reference docs cannot silently drift out of sync with the CLI again
# (see issue #9).
for flag in \
    "fall-defs-global" \
    "fcomplex-threshold" \
    "flink-skeletons" \
    "flist-deps" \
    "fprefer-import-source" \
    ; do
    grep -q -- "-${flag}" "${DOC_MAN_MD}" \
        || die "doc/man/asn1c.man.md is missing -${flag}"
    grep -q -- "-${flag}" "${DOC_USAGE_TEX}" \
        || die "doc/docsrc/asn1c-usage.tex is missing -${flag}"
done

exit 0
