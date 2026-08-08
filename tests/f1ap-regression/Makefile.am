dist_check_SCRIPTS = run.sh

TESTS_ENVIRONMENT = \
	abs_top_srcdir=${abs_top_srcdir} \
	abs_top_builddir=${abs_top_builddir} \
	srcdir=${srcdir}

TESTS = $(dist_check_SCRIPTS)

# JER_OPENTYPE_FIX_TEST.md is cited by JER_OPENTYPE_FIX_SUMMARY.md, so it has
# to reach the tarball for check-design-note-paths.sh to resolve it there.
EXTRA_DIST = F1AP-16.7.0.asn JER_OPENTYPE_FIX_TEST.md

CLEANFILES = *.[choa] *.d converter-example converter-example.mk Makefile.am.* asn_constant.h \
  test-jer-opentype.jer

# Remove files copied from srcdir during out-of-tree builds (distcheck)
clean-local:
	if [ "$(srcdir)" != "." ]; then \
		rm -f F1AP-16.7.0.asn; \
	fi
