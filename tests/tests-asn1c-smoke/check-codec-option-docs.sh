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
    "no-gen-autotools" \
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
check_roff_flag "no-gen-autotools" '\-no\-gen\-autotools'

# Each -no-gen-<RULE> switch above has an inverse -gen-<RULE>, and asn1c accepts
# all of them (asn1c/asn1c.c, case 'g'), but only -gen-autotools was documented:
# the rest appeared in none of the four surfaces, even though the man page
# SYNOPSIS advertises a -gen-<option> family and asn1c's own "-fno-constraints
# is incompatible with -gen-OER, -gen-UPER, or -gen-APER" diagnostic names three
# members of it (see issue #27).
#
# The substring searches used above cannot be reused here, because "-gen-BER" is
# a substring of "-no-gen-BER": every positive switch would pass on the strength
# of its negative twin. Each occurrence is therefore extracted together with its
# optional "no-" prefix -- leftmost-longest matching claims the whole
# "-no-gen-BER" when one is present -- and an exact match is then required.
#
# asn1c/asn1c.c is narrowed to the usage() help table, whose every entry starts
# a source line with `"  -`, rather than searched whole: the -fno-constraints
# diagnostic spells out -gen-OER, -gen-UPER and -gen-APER in its message text,
# so a whole-file search would report those three as documented even after
# usage() lost them.
#
# doc/man/asn1c.1 has its backslashes stripped before the same extraction runs,
# which turns pandoc's "\-gen\-random\-fill" back into "-gen-random-fill". That
# is what lets one spelling of each switch serve all four files, rather than the
# per-flag roff spellings check_roff_flag needs above.
USAGE_TEXT=$(grep '^"  -' "${SRC_MAIN}") \
    || die "asn1c/asn1c.c has no usage() help table (entries starting with '  -')"
ROFF_TEXT=$(tr -d '\\' < "${DOC_MAN_ROFF}")

check_gen_flag() {
    rule=$1
    printf '%s\n' "${USAGE_TEXT}" \
        | grep -oE -- "-(no-)?gen-${rule}" | grep -qx -- "-gen-${rule}" \
        || die "asn1c/asn1c.c usage() is missing -gen-${rule}"
    for doc in "${DOC_MAN_MD}" "${DOC_USAGE_TEX}"; do
        grep -oE -- "-(no-)?gen-${rule}" "${doc}" | grep -qx -- "-gen-${rule}" \
            || die "${doc} is missing -gen-${rule}"
    done
    printf '%s\n' "${ROFF_TEXT}" \
        | grep -oE -- "-(no-)?gen-${rule}" | grep -qx -- "-gen-${rule}" \
        || die "doc/man/asn1c.1 is missing -gen-${rule} (stale generated man page; regenerate with 'make -C doc/man asn1c.1')"
}

check_gen_flag "BER"
check_gen_flag "XER"
check_gen_flag "JER"
check_gen_flag "CBOR"
check_gen_flag "OER"
check_gen_flag "UPER"
check_gen_flag "APER"
check_gen_flag "print"
check_gen_flag "random-fill"
check_gen_flag "example"
check_gen_flag "autotools"

exit 0
