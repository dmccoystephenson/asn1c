#!/usr/bin/env sh

set -e

top_srcdir=${top_srcdir:-../..}

die() {
    echo "ERROR: $*" >&2
    exit 1
}

# tests/tests-integer-native/ is not a SUBDIRS entry, so tests/Makefile.am
# lists its files in EXTRA_DIST one by one to get run.sh and its inputs into
# the release tarball.  `make distcheck` cannot notice when that list falls
# behind: nothing in the tarball runs run.sh.  Upstream syncs add inputs to the
# directory without touching the fork's list -- issue-590/591 arrived that way
# and were left out of `make dist` (fork issue #53).  This guard compares the
# directory with the list in both directions.
#
# Inside a distcheck tarball the directory holds exactly the listed files, so
# the comparison there is trivially equal; the meaningful run is `make check`
# in a git checkout.  run.sh does its work under mktemp -d, so a hand run
# leaves no build leftovers in the directory to trip this check.
dir="${top_srcdir}/tests/tests-integer-native"
mk="${top_srcdir}/tests/Makefile.am"

[ -d "${dir}" ] || die "${dir} not found"
[ -f "${mk}" ] || die "${mk} not found"

listed=$(grep -oE 'tests-integer-native/[^[:space:]\\]+' "${mk}" \
    | sed 's|^tests-integer-native/||' | sort -u)
[ -n "${listed}" ] \
    || die "no tests-integer-native/ entries found in ${mk} (EXTRA_DIST block moved or reformatted?)"

present=""
for f in "${dir}"/*; do
    [ -f "${f}" ] || continue
    present="${present}
$(basename "${f}")"
done
present=$(echo "${present}" | sed '/^$/d' | sort -u)
[ -n "${present}" ] || die "no files found in ${dir}"

missing=""
for name in ${present}; do
    echo "${listed}" | grep -qxF "${name}" || missing="${missing}
    ${name}"
done
[ -z "${missing}" ] \
    || die "files in tests/tests-integer-native/ are missing from EXTRA_DIST in tests/Makefile.am:${missing}"

stale=""
for name in ${listed}; do
    [ -f "${dir}/${name}" ] || stale="${stale}
    ${name}"
done
[ -z "${stale}" ] \
    || die "tests/Makefile.am EXTRA_DIST lists tests-integer-native/ files that do not exist:${stale}"

exit 0
