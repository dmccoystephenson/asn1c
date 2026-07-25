
dist_man1_MANS = asn1c.1 unber.1 enber.1

# The .man.md files are the pandoc sources for the man pages above, and are
# read by tests/tests-asn1c-smoke/check-debug-option-docs.sh, so they have to
# travel in the distribution tarball too.
EXTRA_DIST = $(srcdir)/*.man.md

if HAVE_PANDOC

PANDOC_OPTIONS= --from markdown --to man        \
		--variable header="Version ${VERSION}"  \
		--variable adjusting:l                  \
		--variable hyphenate:""                 \
		--standalone

%.1: %.man.md
	${PANDOC} ${PANDOC_OPTIONS} -o $@ $<

endif

