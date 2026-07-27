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

contains_all() {
    text=$1
    shift
    for token in "$@"; do
        case "$text" in
            *"$token"*) ;;
            *) return 1 ;;
        esac
    done
    return 0
}

for f in "${SRC_MAIN}" "${DOC_MAN_MD}" "${DOC_USAGE_TEX}"; do
    [ -f "$f" ] || die "$f not found (moved, renamed, or missing from EXTRA_DIST?)"
done

main_lexer_line=$(grep 'Wdebug-lexer' "${SRC_MAIN}" | head -n 1 || true)
main_parser_line=$(grep 'Wdebug-parser' "${SRC_MAIN}" | head -n 1 || true)

contains_all "${main_lexer_line}" "lexer" || die "asn1c.c -Wdebug-lexer text drifted"
contains_all "${main_parser_line}" "parser" || die "asn1c.c -Wdebug-parser text drifted"

man_lexer_desc=$(awk '$0=="-Wdebug-lexer" { getline; print; exit }' "${DOC_MAN_MD}")
man_parser_desc=$(awk '$0=="-Wdebug-parser" { getline; print; exit }' "${DOC_MAN_MD}")

contains_all "${man_lexer_desc}" "lexer" "lexing stage" || die "asn1c.man.md -Wdebug-lexer is inaccurate"
contains_all "${man_parser_desc}" "parser" "parsing stage" || die "asn1c.man.md -Wdebug-parser is inaccurate"

tex_lexer_desc=$(awk 'index($0, "{\\ttfamily -Wdebug-lexer}") { print; exit }' "${DOC_USAGE_TEX}")
tex_parser_desc=$(awk 'index($0, "{\\ttfamily -Wdebug-parser}") { print; exit }' "${DOC_USAGE_TEX}")

contains_all "${tex_lexer_desc}" "lexer" "lexing stage" || die "asn1c-usage.tex -Wdebug-lexer is inaccurate"
contains_all "${tex_parser_desc}" "parser" "parsing stage" || die "asn1c-usage.tex -Wdebug-parser is inaccurate"

exit 0
