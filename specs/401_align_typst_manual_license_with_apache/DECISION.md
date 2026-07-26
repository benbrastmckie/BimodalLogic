# User Decision: Task 401 License Carve-Out

**Date**: 2026-07-26
**Authorized by**: repository copyright holder (Benjamin Brast-McKie), via direct instruction
in the orchestration session.

## Decision

**Option (a): bring the typst reference manual under Apache-2.0.**

The all-rights-reserved carve-out on `Theories/Bimodal/typst/BimodalReference.typ` is retired.
The manual is relicensed to Apache-2.0, matching the rest of the repository, for a single
uniform license story.

## Authorization Scope

This authorization satisfies the charter's gate ("Do NOT change the licensing of the manual
without explicit authorization -- surface the recommendation and wait"). Options (b) keep-and-
strengthen-carve-out and (c) CC-BY-4.0 are declined.

## Required Consequences

1. `Theories/Bimodal/typst/BimodalReference.typ` (notices at :10 and :111): replace the bare
   `All rights reserved.` assertion with the Apache-2.0 notice, naming the LICENSE file.
2. README.md License section: remove or rewrite the sentence documenting the carve-out, since
   the carve-out no longer exists. The repo license story becomes uniform Apache-2.0.
3. Any generated output (PDF or otherwise) carrying the old all-rights-reserved notice must be
   regenerated, or flagged if regeneration is out of scope.
4. Verify no remaining license assertion in the repo contradicts any other. Established
   non-issues to leave alone: `docs/research/` and `specs/literature/`, which describe
   THIRD-PARTY project licenses, not this repo's.
