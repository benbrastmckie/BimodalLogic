# Phase 1 Handoff - Create Boneyard Archive

**Completed**: 2026-05-20
**Next Action**: Phase 2 - Update downstream call sites

## What Was Done
- Created `Theories/Bimodal/Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean`
- Contains all 5 ARCHIVE definitions with full proof bodies in code fences
- Contains all 22 DELETE definitions as type signatures in code fences
- Documents downstream impact table
- No import statements (documentation-only, following ClosedGuardLegacy precedent)

## Key Decisions
- Followed ClosedGuardLegacy format exactly (code in markdown fences within /-! ... -/ block)
- Included proof bodies for `until_F_expansion` and `since_P_expansion` (25/23 lines)
- Noted `or_until_imp`/`or_since_imp` proofs as "see git history" since they use sorry-bearing defs

## Next Steps
- Phase 2: Update 8 downstream call sites in UltrafilterFrame, UntilSinceCoherence, SuccRelation
