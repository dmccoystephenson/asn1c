/*
 * Regression test for mouse07410/asn1c#561, reported by @Schramp.
 *
 * Purpose: verify that the generated CHOICE to_canonical_order and
 *          from_canonical_order maps put every alternative at the wire
 *          index X.691 #23.6 assigns it, for a reordering that is not its
 *          own inverse.
 * Original source: tests/tests-asn1c-compiler/157-per-canonical-order-OK.asn1.
 * Version: 2026-10-03.
 * Inputs: generated asn_DEF_T for
 *           T ::= CHOICE { one [4] NULL, two [3] NULL,
 *                          three [1] NULL, four [2] NULL }
 *         The canonical (ascending tag) order is three, four, two, one, so
 *         the 2-bit CHOICE index is one=3, two=2, three=0, four=1.  NULL
 *         contributes no bits, so each encoding is the index alone, in the
 *         top two bits of a single octet.  The range is below 256, so APER
 *         uses the same unaligned bit-field and produces identical bytes.
 * Returns: process status zero on success; assert failure otherwise.
 * Exceptions: none are thrown; decoded objects are always released.
 * Responsible party: asn1c maintainers; discovery credited to @Schramp.
 * History: added with the CHOICE canonical map label fix.  Before the fix
 *          the maps were emitted under swapped names; since encode and
 *          decode used the two swapped maps consistently, asn1c-to-asn1c
 *          round trips still succeeded and only the wire bytes were wrong
 *          (one encoded as 0x80, two as 0xc0, three as 0x40, four as 0x00).
 * Example: this file is run by check-assembly.sh with -gen-UPER -gen-APER.
 */
#undef NDEBUG

#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include <aper_decoder.h>
#include <aper_encoder.h>
#include <uper_decoder.h>
#include <uper_encoder.h>

#include "T.h"

typedef asn_enc_rval_t (*encode_to_buffer_f)(
    const asn_TYPE_descriptor_t *type_descriptor,
    const asn_per_constraints_t *constraints, const void *struct_ptr,
    void *buffer, size_t buffer_size);

typedef asn_dec_rval_t (*decode_complete_f)(
    const asn_codec_ctx_t *opt_codec_ctx,
    const asn_TYPE_descriptor_t *type_descriptor, void **struct_ptr,
    const void *buffer, size_t size);

/*
 * Purpose: encode one alternative, compare against the X.691 byte, then
 *          decode that byte back and require the same alternative.
 * Inputs: codec_name labels the output; encode/decode are the UPER or APER
 *         entry points; present selects the alternative; expected_byte is
 *         the hand-derived encoding.
 * Returns: no value.
 * Exceptions: assert aborts on a wrong wire byte or a wrong decoded
 *             alternative.
 * Example: check_alternative("UPER", uper_encode_to_buffer,
 *                            uper_decode_complete, T_PR_one, 0xc0);
 */
static void
check_alternative(const char *codec_name, encode_to_buffer_f encode,
                  decode_complete_f decode, T_PR present,
                  uint8_t expected_byte) {
    T_t value;
    T_t *decoded = NULL;
    uint8_t buf[8];
    asn_enc_rval_t er;
    asn_dec_rval_t rv;

    memset(&value, 0, sizeof(value));
    value.present = present;

    memset(buf, 0xaa, sizeof(buf));
    er = encode(&asn_DEF_T, NULL, &value, buf, sizeof(buf));
    assert(er.encoded >= 1);
    assert(er.encoded <= 8);
    printf("%s T present=%d => %02x (expected %02x)\n", codec_name,
           (int)present, buf[0], expected_byte);
    assert(buf[0] == expected_byte);

    rv = decode(NULL, &asn_DEF_T, (void **)&decoded, &expected_byte, 1);
    assert(rv.code == RC_OK);
    assert(decoded != NULL);
    printf("%s T %02x => present=%d (expected %d)\n", codec_name,
           expected_byte, (int)decoded->present, (int)present);
    assert(decoded->present == present);
    ASN_STRUCT_FREE(asn_DEF_T, decoded);
}

/*
 * Purpose: check every alternative of T under one PER variant.
 * Inputs: codec_name labels the output; encode/decode are the entry points.
 * Returns: no value.
 * Exceptions: assert aborts on any mismatch.
 * Example: check_codec("APER", aper_encode_to_buffer, aper_decode_complete);
 */
static void
check_codec(const char *codec_name, encode_to_buffer_f encode,
            decode_complete_f decode) {
    check_alternative(codec_name, encode, decode, T_PR_one, 0xc0);   /* 3 */
    check_alternative(codec_name, encode, decode, T_PR_two, 0x80);   /* 2 */
    check_alternative(codec_name, encode, decode, T_PR_three, 0x00); /* 0 */
    check_alternative(codec_name, encode, decode, T_PR_four, 0x40);  /* 1 */
}

int
main(void) {
    check_codec("UPER", uper_encode_to_buffer, uper_decode_complete);
    check_codec("APER", aper_encode_to_buffer, aper_decode_complete);
    return 0;
}
