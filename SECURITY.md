# Security Policy

This is a fork of [mouse07410/asn1c](https://github.com/mouse07410/asn1c). See
[ChangeLog](ChangeLog) for the current release (the README's "Latest release"
section always names it) and how this fork tracks upstream.

## Supported Versions

Only the `vlm_master` branch receives security fixes; tagged/released versions
do not get patch releases. Build from `vlm_master` for the latest fixes.

## Security Surfaces

### Compiler (`asn1c` binary)

The compiler is a developer tool: it runs in trusted build environments on
schemas you control. Compiler bugs are not treated as security vulnerabilities —
report them via a public GitHub issue.

### Generated code and runtime skeletons

The C code asn1c emits (`skeletons/` and type-specific generated files) runs in
production systems that parse untrusted network data (X.509 certificates, mobile
network messages, ITS vehicle communication, etc.). This is the active security
surface. Examples of in-scope vulnerabilities:

- Buffer overflow or integer overflow in a BER/DER/PER/OER/XER decoder
- Unchecked length or constraint allowing heap corruption in generated decoders
- Memory leak or use-after-free in generated encode/decode paths
- Incorrect constraint validation accepting out-of-range values
- Denial-of-service via crafted encoded messages

## Reporting a Vulnerability

**Do not open a public GitHub issue for generated-code or skeleton vulnerabilities.**

Report it privately via GitHub's [Security Advisories for this
repository](https://github.com/dmccoystephenson/asn1c/security/advisories/new)
(or the repository's **Security** tab, **Report a vulnerability**). Since this
fork's runtime code is shared with upstream, also consider reporting to
[mouse07410/asn1c](https://github.com/mouse07410/asn1c/security/advisories/new)
so the fix can land there too.

Include:

1. asn1c version or commit hash
2. Description of the vulnerability and its potential impact
3. Steps to reproduce — a minimal encoded input that triggers the issue
4. Proof-of-concept or crash output if available (stack trace, ASAN report, etc.)

## Notes for Downstream Maintainers

Fixes to the runtime skeletons are compiled into consuming applications, not
linked dynamically. A skeleton fix therefore requires downstream projects to
regenerate (or re-copy the skeletons) and rebuild — simply updating the
`asn1c` compiler binary is not sufficient. If you redistribute generated code
or vendored skeletons, track `vlm_master` and rebuild after security fixes land.
