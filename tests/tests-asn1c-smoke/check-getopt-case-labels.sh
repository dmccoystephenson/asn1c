#!/usr/bin/env sh

set -e

top_srcdir=${top_srcdir:-../..}

SRC_MAIN="${top_srcdir}/asn1c/asn1c.c"

die() {
    echo "ERROR: $*" >&2
    exit 1
}

[ -f "${SRC_MAIN}" ] || die "${SRC_MAIN} not found (moved, renamed, or missing from EXTRA_DIST?)"

# The short-option string handed to getopt() and the case labels of the switch
# that consumes it are two halves of one declaration, and nothing makes them
# agree.  'L' stayed in the option string for 22 years after cbf218f7
# (2004-08-20) removed its "case 'L':" label: getopt() went on accepting -L and
# returning 'L', so opterr never printed its "invalid option" diagnostic, and
# -L fell to "default: usage()" -- a usage screen naming no offending option,
# where every other unrecognized flag says which one was rejected (see issue
# #31).  A label with no letter is the mirror-image defect: unreachable code.
#
# Only the option-parsing switch is scanned, delimited by the getopt() call and
# its own default: label, so a case label belonging to some other switch in the
# file is not mistaken for an option.
SWITCH=$(sed -n '/getopt(ac, av, "/,/^[[:space:]]*default:/p' "${SRC_MAIN}")

OPTSTRING=$(printf '%s\n' "${SWITCH}" \
    | sed -n 's/.*getopt(ac, av, "\([^"]*\)").*/\1/p')
[ -n "${OPTSTRING}" ] \
    || die "no getopt(ac, av, \"...\") call found in ${SRC_MAIN} (rewritten option parsing? this check needs updating)"

# An unterminated sed range runs to end of file, which would sweep in case
# labels from any switch below.  There is no default: label to close it only if
# the option switch has been restructured, in which case this check is stale.
printf '%s\n' "${SWITCH}" | grep -q '^[[:space:]]*default:' \
    || die "the option-parsing switch in ${SRC_MAIN} has no default: label to delimit it (restructured option parsing? this check needs updating)"

# ':' marks the preceding letter as taking an argument and is not an option
# itself.  The remaining letters are split one per line for comparison, the
# way check-design-note-paths.sh already relies on grep -o.
LETTERS=$(printf '%s' "${OPTSTRING}" | tr -d ':' | grep -o .)

LABELS=$(printf '%s\n' "${SWITCH}" | sed -n "s/^[[:space:]]*case '\(.\)':.*/\1/p" | sort -u)

undeclared=""
for letter in ${LETTERS}; do
    printf '%s\n' "${LABELS}" | grep -q "^${letter}\$" \
        || undeclared="${undeclared} -${letter}"
done
[ -z "${undeclared}" ] \
    || die "getopt() option string in ${SRC_MAIN} accepts option(s) with no case label:${undeclared} (they reach 'default: usage()' with no diagnostic naming them -- drop the letter from the option string, or add the missing label)"

unreachable=""
for letter in ${LABELS}; do
    case "${OPTSTRING}" in
        *"${letter}"*) ;;
        *) unreachable="${unreachable} -${letter}" ;;
    esac
done
[ -z "${unreachable}" ] \
    || die "switch in ${SRC_MAIN} has case label(s) absent from the getopt() option string:${unreachable} (getopt() never returns them, so the code is unreachable -- add the letter to the option string, or drop the label)"

exit 0
