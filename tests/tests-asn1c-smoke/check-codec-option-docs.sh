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

# Every encoding rule that asn1c generates support code for by default has a
# -no-gen-<RULE> switch to turn it off, so each one must be discoverable from
# the CLI's own usage() help text, doc/man/asn1c.man.md and
# doc/docsrc/asn1c-usage.tex. -no-gen-JER was parsed by asn1c.c and enabled by
# default, yet missing from all three, so there was no documented way to find
# it. check-language-option-docs.sh covers the -f<flag> family the same way.
for flag in \
    "no-gen-BER" \
    "no-gen-XER" \
    "no-gen-JER" \
    "no-gen-CBOR" \
    "no-gen-OER" \
    "no-gen-UPER" \
    "no-gen-APER" \
    "gen-autotools" \
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

check_roff_flag "no-gen-BER" '\-no\-gen\-BER'
check_roff_flag "no-gen-XER" '\-no\-gen\-XER'
check_roff_flag "no-gen-JER" '\-no\-gen\-JER'
check_roff_flag "no-gen-CBOR" '\-no\-gen\-CBOR'
check_roff_flag "no-gen-OER" '\-no\-gen\-OER'
check_roff_flag "no-gen-UPER" '\-no\-gen\-UPER'
check_roff_flag "no-gen-APER" '\-no\-gen\-APER'
check_roff_flag "gen-autotools" '\-gen\-autotools'

exit 0
