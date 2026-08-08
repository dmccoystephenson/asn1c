#!/usr/bin/env sh

set -e

top_srcdir=${top_srcdir:-../..}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

# The design notes at the top of the tree describe subsystems by citing the
# sources they live in.  Those citations rot silently: SECURITY_FIX_SUMMARY.md
# listed skeletons/constr_SEQUENCE_OF_oer.c in its "Remaining Work" checklist
# even though no such file has ever existed (both OER SEQUENCE OF codecs are
# #define aliases onto SET_OF_*_oer -- skeletons/constr_SEQUENCE_OF.h), and it
# survived until a hand sweep found it (see issue #21).  Every other doc-drift
# class fixed in this repo has since acquired a guard -- this one covers the
# design notes.
DESIGN_NOTES="
    CANONICAL_UPER_README.md
    ENCODING_CONTROL_STATUS.md
    ENCODING_CONTROL_SUMMARY.md
    EXTENSIBLE_INTEGER_FIX_DEMO.md
    ILP32_CROSS_BUILD_PLAN.md
    IMPLEMENTATION_SUMMARY.md
    JER_OPENTYPE_FIX_SUMMARY.md
    NO_AUTO_DECODE_CONTAINING_in_XER.md
    PARTIAL_DECODING.md
    PARTIAL_DECODING_FIX.md
    SECURITY_FIX_SUMMARY.md
    XER-OCTET-STRING-base64-plan.md
"

for note in ${DESIGN_NOTES}; do
    [ -f "${top_srcdir}/${note}" ] \
        || die "${top_srcdir}/${note} not found (moved, renamed, or missing from EXTRA_DIST in the top-level Makefile.am?)"
done

# Only directory-qualified citations are checked, and only their existence.
#
#  * A bare file name such as `constr_SET.c` does not say which directory it
#    lives in, and the planning notes deliberately cite names for files that
#    do not exist yet (`NNN-base64-prefix-OK.asn1` in
#    XER-OCTET-STRING-base64-plan.md), so bare names would be false positives.
#  * The function names cited beside each path are the other half of this
#    drift class, but #define aliasing in skeletons/ makes them impractical to
#    resolve mechanically.  Path existence is the high-value, low-noise
#    subset.
#
# A trailing line reference (`path.c:123` or `path.c:123-456`) is stripped
# before the path is resolved; its accuracy is out of scope here.  A backticked
# URL would otherwise look exactly like a directory-qualified path, so anything
# carrying a scheme is dropped.
missing=""
for note in ${DESIGN_NOTES}; do
    cited=$(grep -oE '`[^`]*/[^`]*\.(c|h|y|l|am|ac|sh|md|asn1)(:[0-9]+(-[0-9]+)?)?`' \
        "${top_srcdir}/${note}" | tr -d '`' | grep -v '://' | cut -d: -f1 | sort -u)
    for path in ${cited}; do
        [ -e "${top_srcdir}/${path}" ] || missing="${missing}
    ${note} cites ${path}"
    done
done

[ -z "${missing}" ] \
    || die "design notes cite source paths that do not exist in the tree:${missing}"

exit 0
