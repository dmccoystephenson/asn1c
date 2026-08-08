
ACLOCAL_AMFLAGS = -I m4

@CODE_COVERAGE_RULES@
CODE_COVERAGE_IGNORE_PATTERN="tests/*" "lex.yy.c" "y.tab.c" "asn1p_l.l" "asn1p_y.y"

SUBDIRS =                       \
    libasn1common libasn1parser \
    libasn1fix libasn1print     \
    libasn1compiler             \
    asn1-tools asn1c skeletons  \
    tests examples doc

docsdir = $(datadir)/doc/asn1c

docs_DATA = README.md INSTALL.md REQUIREMENTS.md FAQ ChangeLog BUGS .github/copilot-instructions.md

EXTRA_DIST = README.md INSTALL.md REQUIREMENTS.md FAQ LICENSE BUGS .github/copilot-instructions.md

# The design notes are distributed so that
# tests/tests-asn1c-smoke/check-design-note-paths.sh, which asserts that every
# source path they cite still resolves, keeps working under `make distcheck`
# instead of failing on an absent input.  Compare doc/man/*.man.md, which is
# distributed for check-language-option-docs.sh for the same reason.
EXTRA_DIST +=                           \
    CANONICAL_UPER_README.md            \
    ENCODING_CONTROL_STATUS.md          \
    ENCODING_CONTROL_SUMMARY.md         \
    EXTENSIBLE_INTEGER_FIX_DEMO.md      \
    ILP32_CROSS_BUILD_PLAN.md           \
    IMPLEMENTATION_SUMMARY.md           \
    JER_OPENTYPE_FIX_SUMMARY.md         \
    NO_AUTO_DECODE_CONTAINING_in_XER.md \
    PARTIAL_DECODING.md                 \
    PARTIAL_DECODING_FIX.md             \
    SECURITY_FIX_SUMMARY.md             \
    XER-OCTET-STRING-base64-plan.md
