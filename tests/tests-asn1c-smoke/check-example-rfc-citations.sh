#!/usr/bin/env sh

set -e

top_srcdir=${top_srcdir:-../..}

EXAMPLES="${top_srcdir}/examples"
EXAMPLES_README="${EXAMPLES}/README"
EXAMPLES_MAKEFILE="${EXAMPLES}/Makefile.am"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

for f in "${EXAMPLES_README}" "${EXAMPLES_MAKEFILE}"; do
    [ -f "$f" ] || die "$f not found (moved, renamed, or missing from EXTRA_DIST?)"
done

# examples/README and the per-example READMEs name the RFC text each decoder
# is extracted from, and examples/Makefile.am names the same texts as the
# ASN1_SOURCE_<n> inputs crfc2asn1.pl actually runs on.  Nothing kept the two
# in agreement: examples/README cited rfc4211.txt (CRMF) for the LDAPv3
# decoder, twice, from the day 8c85f2a1 (2006-09-09) added examples/rfc4511.txt
# until a hand sweep found it (see issue #35).  check-design-note-paths.sh
# cannot see this class -- it scans the design notes, not examples/, and it
# deliberately ignores bare file names because a planning note may name a file
# that does not exist yet.  RFC texts are a closed, mechanically recognizable
# class, so they are checked here on their own, against the files on disk and
# against the Makefile.am, with no false-positive exclusion needed.
#
# Cross-checking the citations only against each other would not have caught
# the instance above: both named rfc4211.txt and both were wrong.

# The texts the build extracts from.  A pipeline ending in sort -u never fails,
# so an empty result is checked explicitly rather than left to set -e.
SOURCES=$(grep -E '^ASN1_SOURCE_[0-9]+[[:space:]]*=' "${EXAMPLES_MAKEFILE}" \
    | grep -oE 'rfc[0-9]+\.txt' | sort -u)
[ -n "${SOURCES}" ] \
    || die "no ASN1_SOURCE_<n> = rfc<nnnn>.txt assignment found in ${EXAMPLES_MAKEFILE} (restructured extraction? this check needs updating)"

# Every rfc<nnnn>.txt token in the Makefile.am, whether an ASN1_SOURCE_<n>
# input or an EXTRA_DIST entry, has to be a file that ships.
missing=""
for text in $(grep -oE 'rfc[0-9]+\.txt' "${EXAMPLES_MAKEFILE}" | sort -u); do
    [ -f "${EXAMPLES}/${text}" ] || missing="${missing}
    examples/Makefile.am names ${text}"
done

# The READMEs: the top-level one, which enumerates every example, and the one
# inside each sample.source.* directory.  Each token has to be a file that
# ships, and has to be a text the Makefile.am extracts from -- a README that
# names an RFC the build never reads is the same drift from the other side.
READMES="${EXAMPLES_README}"
for dir in "${EXAMPLES}"/sample.source.*; do
    if [ -f "${dir}/README" ]; then
        READMES="${READMES} ${dir}/README"
    fi
done

unextracted=""
for readme in ${READMES}; do
    for text in $(grep -oE 'rfc[0-9]+\.txt' "${readme}" | sort -u); do
        [ -f "${EXAMPLES}/${text}" ] || missing="${missing}
    ${readme#${top_srcdir}/} cites ${text}"
        printf '%s\n' "${SOURCES}" | grep -q "^${text}\$" \
            || unextracted="${unextracted}
    ${readme#${top_srcdir}/} cites ${text}"
    done
done

[ -z "${missing}" ] \
    || die "RFC texts are cited that do not exist in examples/:${missing}"
[ -z "${unextracted}" ] \
    || die "RFC texts are cited that no ASN1_SOURCE_<n> in examples/Makefile.am extracts from:${unextracted}"

# The reverse direction: the closing crfc2asn1.pl paragraph of examples/README
# lists the texts the modules are extracted from, so every ASN1_SOURCE_<n> has
# to be named there.  This is also what keeps the check from passing vacuously
# on a README that no longer mentions any RFC text at all.
uncited=""
for text in ${SOURCES}; do
    grep -q "${text}" "${EXAMPLES_README}" \
        || uncited="${uncited} ${text}"
done
[ -z "${uncited}" ] \
    || die "examples/Makefile.am extracts from RFC text(s) that examples/README does not mention:${uncited}"

exit 0
