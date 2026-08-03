#!/usr/bin/env sh

set -e

top_srcdir=${top_srcdir:-../..}

SRC_MAIN="${top_srcdir}/asn1c/asn1c.c"
DOC_MAN_MD="${top_srcdir}/doc/man/asn1c.man.md"
DOC_MAN_ROFF="${top_srcdir}/doc/man/asn1c.1"
DOC_USAGE_TEX="${top_srcdir}/doc/docsrc/asn1c-usage.tex"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

for f in "${SRC_MAIN}" "${DOC_MAN_MD}" "${DOC_MAN_ROFF}" "${DOC_USAGE_TEX}"; do
    [ -f "$f" ] || die "$f not found (moved, renamed, or missing from EXTRA_DIST?)"
done

# Every -f<flag> parsed by the 'f' case in asn1c.c must have a row/entry in
# the CLI's own usage() help text, doc/man/asn1c.man.md, and
# doc/docsrc/asn1c-usage.tex, so the three cannot silently drift out of sync
# with each other again (see issue #9; usage() itself was missing
# -fall-defs-global and -flink-skeletons despite both docs having them).
for flag in \
    "fall-defs-global" \
    "fbless-SIZE" \
    "fcomplex-threshold" \
    "fcompound-names" \
    "findirect-choice" \
    "fincludes-quoted" \
    "fknown-extern-type" \
    "fline-refs" \
    "fno-constraints" \
    "fno-include-deps" \
    "flink-skeletons" \
    "flist-deps" \
    "fgen-only-pdu-deps" \
    "fprefer-import-source" \
    "fprefix" \
    "funnamed-unions" \
    "fwide-types" \
    "flong-size" \
    "finteger-native-type" \
    ; do
    grep -q -- "-${flag}" "${SRC_MAIN}" \
        || die "asn1c/asn1c.c usage() is missing -${flag}"
    grep -q -- "-${flag}" "${DOC_MAN_MD}" \
        || die "doc/man/asn1c.man.md is missing -${flag}"
    grep -q -- "-${flag}" "${DOC_USAGE_TEX}" \
        || die "doc/docsrc/asn1c-usage.tex is missing -${flag}"
done

# doc/man/asn1c.1 is pandoc-generated from doc/man/asn1c.man.md and is what
# actually ships to users (dist_man1_MANS in doc/man/Makefile.am); it has
# fallen out of sync with its source before because regeneration requires
# pandoc and is easy to forget (see issue #13). Pandoc escapes every literal
# hyphen as "\-", so each flag's roff form is checked explicitly here rather
# than derived, since POSIX sh has no portable global string substitution.
check_roff_flag() {
    plain=$1
    roff=$2
    grep -qF -- "${roff}" "${DOC_MAN_ROFF}" \
        || die "doc/man/asn1c.1 is missing -${plain} (stale generated man page; regenerate with 'make -C doc/man asn1c.1')"
}

check_roff_flag "fall-defs-global" '\-fall\-defs\-global'
check_roff_flag "fbless-SIZE" '\-fbless\-SIZE'
check_roff_flag "fcomplex-threshold" '\-fcomplex\-threshold'
check_roff_flag "fcompound-names" '\-fcompound\-names'
check_roff_flag "findirect-choice" '\-findirect\-choice'
check_roff_flag "fincludes-quoted" '\-fincludes\-quoted'
check_roff_flag "fknown-extern-type" '\-fknown\-extern\-type'
check_roff_flag "fline-refs" '\-fline\-refs'
check_roff_flag "fno-constraints" '\-fno\-constraints'
check_roff_flag "fno-include-deps" '\-fno\-include\-deps'
check_roff_flag "flink-skeletons" '\-flink\-skeletons'
check_roff_flag "flist-deps" '\-flist\-deps'
check_roff_flag "fgen-only-pdu-deps" '\-fgen\-only\-pdu\-deps'
check_roff_flag "fprefer-import-source" '\-fprefer\-import\-source'
check_roff_flag "fprefix" '\-fprefix='
check_roff_flag "funnamed-unions" '\-funnamed\-unions'
check_roff_flag "fwide-types" '\-fwide\-types'
check_roff_flag "flong-size" '\-flong\-size'
check_roff_flag "finteger-native-type" '\-finteger\-native\-type'

exit 0
