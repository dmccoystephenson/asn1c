
# Tests are ordered in the rough order of the time it takes to go through them.
SUBDIRS = \
    tests-asn1c-compiler    \
    tests-skeletons         \
    tests-asn1c-smoke       \
    tests-c-compiler        \
    tests-randomized        \
    ioc-v2x                 \
    ieee1609-ioc            \
    f1ap-regression  

EXTRA_DIST = README

# tests-integer-native/ is not a SUBDIRS entry -- its run.sh is driven by hand
# (and is cited as such by ILP32_CROSS_BUILD_PLAN.md), so nothing else pulls it
# into the tarball.  It is listed explicitly rather than as a bare directory so
# that a dirty working tree cannot smuggle build leftovers into `make dist`.
EXTRA_DIST +=                                       \
    tests-integer-native/README.md                  \
    tests-integer-native/oversized-integers.asn1    \
    tests-integer-native/run.sh                     \
    tests-integer-native/test_bigint.c              \
    tests-integer-native/test_constraints.c         \
    tests-integer-native/test_cval.c                \
    tests-integer-native/test_int32.c

