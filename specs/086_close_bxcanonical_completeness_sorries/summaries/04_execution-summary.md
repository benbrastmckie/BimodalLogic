# Execution Summary: Close usf_completeness imp Case B

**Task**: 86 -- Close BXCanonical completeness sorries
**Session**: sess_1775715334_7579f6
**Date**: 2026-04-09
**Status**: PARTIAL (Phase 1 completed, Phases 2-5 blocked)

## Results

### Phase 1: Box Preservation and Modal Equivalence Along bx_le [COMPLETED]

Added 3 sorry-free lemmas to `Frame.lean` and 1 to `CanonicalEmbedding.lean`:

1. **`neg_box_to_box_neg_box`** (Frame.lean): Derivation tree for S5 negative introspection `|- neg(box phi) -> box(neg(box phi))`. Uses `modal_5_collapse` + `Propositional.contraposition` + `Propositional.double_negation` + `Combinators.imp_trans`.

2. **`box_preserved_along_bx_le`** (Frame.lean): For `bx_le w v`: `box phi in w <-> box phi in v`. Forward uses `temp_future` + `bx_G_forward`. Backward uses S5 negative introspection contrapositive.

3. **`bx_modal_equiv_of_bx_le`** (Frame.lean): `bx_le w v -> bx_modal_equiv w v`. Immediate corollary wrapping `box_preserved_along_bx_le`.

4. **`modal_omega_eq_of_bx_le`** (CanonicalEmbedding.lean): `bx_le w v -> modal_omega w = modal_omega v`. Uses `bx_modal_equiv_of_bx_le` + existing `modal_omega_eq_of_equiv`.

### Phases 2-5: Dovetailed Chain [BLOCKED]

Extensive analysis (~6 hours) revealed a fundamental gap in the plan's architecture.

**The Gap**: The dovetail chain's G-completeness property ("if G(alpha) not-in chain(s), then exists r > s with alpha not-in chain(r)") is NOT provable for enumeration-based chains. Resolving one F-obligation by taking a G-backward witness can introduce new G-formulas that kill other pending F-obligations. This is because:

- G-formulas propagate FORWARD along bx_le (by all_future_all_future + bx_G_forward)
- G-formulas do NOT propagate BACKWARD along bx_le
- The G-backward witness (via Lindenbaum / Classical.choice) may introduce arbitrary new G-formulas

The plan's claim that "G-contrapositive on the chain" follows from G-completeness is also incorrect: having alpha at all CHAIN POINTS does not imply G(alpha), because G_iff_mcs requires alpha at ALL BXPoints (uncountably many) above the chain point, not just the countably many chain points.

## Handoff

Detailed analysis and 4 viable alternative paths documented in:
`specs/086_close_bxcanonical_completeness_sorries/handoffs/01_forward-f-blocker.md`

Recommended path: **Combined F-Seed Extension** -- at each chain step, extend using a combined seed `{psi_1, ..., psi_k} union g_content(M)` that resolves ALL pending F-obligations simultaneously. Requires proving the combined seed is consistent (standard technique from Goldblatt 1992).

## Build Status

- `lake build` passes with zero errors
- No new sorries introduced
- The 1 sorry in CanonicalEmbedding.lean (imp Case B) and 4 sorries in Frame.lean (Until/Since) remain unchanged

## Files Modified

| File | Change | Status |
|------|--------|--------|
| `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` | Added neg_box_to_box_neg_box, box_preserved_along_bx_le, bx_modal_equiv_of_bx_le | Sorry-free |
| `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` | Added modal_omega_eq_of_bx_le | Sorry-free |
