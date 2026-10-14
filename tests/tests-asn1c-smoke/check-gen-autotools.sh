#!/usr/bin/env bash

set -ex
set -o pipefail

top_builddir=${top_builddir:-../..}
top_srcdir=${top_srcdir:-../..}
srcdir=$(cd "$(dirname "$0")" && pwd)

path_from_testdir() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *) printf '../../%s\n' "$1" ;;
    esac
}

# Each case below runs asn1c from its own subdirectory of $testdir, because the
# example configure.ac and Makefile.am are written to the current directory.
ASN1C="$(path_from_testdir "${top_builddir}")/asn1c/asn1c"
SKELETONS_DIR="$(path_from_testdir "${top_srcdir}")/skeletons"

testdir=test-gen-autotools
cleanup() {
    rm -rf "$testdir"
}
trap cleanup EXIT

rm -rf "$testdir"
mkdir "$testdir"
cd "$testdir"

for case in with without cancelled; do
    mkdir "$case"
    cp "${srcdir}/data/fprefix-link.asn" "$case/test.asn"
done

# -gen-autotools is the only switch that sets A1C_GEN_AUTOTOOLS_EXAMPLE (it is
# off by default), so it must be accepted and must emit the example top-level
# configure.ac and Makefile.am (see issue #41).
(cd with && "${ASN1C}" -S "${SKELETONS_DIR}" -gen-autotools test.asn)
test -f with/Cause.c
test -f with/configure.ac
test -f with/Makefile.am
grep -F "AC_CONFIG_FILES([Makefile])" with/configure.ac
grep -F "include Makefile.am.asn1convert" with/Makefile.am

# Without the switch, neither file is generated.
(cd without && "${ASN1C}" -S "${SKELETONS_DIR}" test.asn)
test -f without/Cause.c
test ! -e without/configure.ac
test ! -e without/Makefile.am

# A later -no-gen-autotools cancels an earlier -gen-autotools.
(cd cancelled \
    && "${ASN1C}" -S "${SKELETONS_DIR}" -gen-autotools -no-gen-autotools \
        test.asn)
test -f cancelled/Cause.c
test ! -e cancelled/configure.ac
test ! -e cancelled/Makefile.am
