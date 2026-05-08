# Phase 9 Continuation Handoff: untl/snce Convention Swap

## Session
- **Session ID**: sess_1778221275_3b41e2
- **Status**: Partial — 12 errors remain in one file

## What Was Done

### Script-Based Swap (Major Progress)
A Python script (`scripts/swap_untl_snce.py`) was created to mechanically swap all `Formula.untl X Y` → `Formula.untl Y X` and `Formula.snce X Y` → `Formula.snce Y X` patterns.

The script was applied to:
1. ChronicleTypes.lean — type definitions (rRelation, burgessR, C4, C5, etc.)
2. RRelation.lean — all 81 Formula.untl/snce occurrences + 11 dot-notation manually fixed
3. PointInsertion.lean — 521 occurrences (with injEq fixes)
4. CounterexampleElimination.lean — 116 occurrences
5. ChronicleConstruction.lean — 38 occurrences + 6 multi-line `show` manually fixed
6. CanonicalChain.lean — 20 occurrences
7. DefectChain.lean — 13 occurrences
8. Realization.lean — 26 occurrences (+ 1 Or.inl/Or.inr manual fix)
9. LocusControl.lean — 2 occurrences

### Manual Fixes Applied
- TruthLemma.lean: Changed conclusion from ψ to φ (event extraction)
- UntilSinceCoherence.lean: Swapped `untl φ ψ` → `untl ψ φ` in backward_from_step signatures
- Construction.lean: Swapped axiom args for self_accum, until_F, since_P
- RestrictedParametricTruthLemma.lean: Swapped IH names (ih_phi ↔ ih_psi)
- PointInsertion.lean: Fixed 7 injEq `.1`↔`.2` swaps (d0_guard_*, l27_guard_*, event_list_*)
- ChronicleConstruction.lean: Fixed 6 multi-line `show` expressions (counterexample_enum .ξ/.η)
- Realization.lean: Fixed Or.inl/Or.inr in subformulas_untl_unwrap
- ChronicleToCountermodel.lean: Swapped h_ψ→h_φ destructuring in backward coherence proof

## Remaining Work: ChronicleToCountermodel.lean (12 errors)

All remaining errors are in `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`.

### Root Cause
The file has both:
1. Dot-notation patterns (`φ.untl ψ`) that were swapped by `sed`
2. Manual fixes (h_ψ → h_φ name changes) that conflict with the sed

The sed was applied AFTER the manual fixes, undoing some of them. The file needs a careful pass to:
1. Revert to git state
2. Apply ONLY the manual backward-coherence fixes (lines 501-580)
3. Apply ONLY the manual forward-coherence fixes (lines 595-660)
4. The `sed` swap of `φ.untl ψ` → `ψ.untl φ` is correct for the C4/C5 calls but WRONG for the goal/conclusion expressions

### Fix Pattern for Each Error

Lines 507, 548: `h_not` type mismatch — `by_contra h_not` produces `¬(untl φ ψ ∈ ...)` from the goal `untl φ ψ ∈ ...`. The `negation_complete` call uses `ψ.untl φ` but should use `φ.untl ψ` (matching the goal). FIX: Use `φ.untl ψ` in h_neg (DON'T swap these — they match the goal).

Lines 521, 562: `h_neg'` has `(φ.untl ψ).neg` but C4 expects `(ψ.untl φ).neg`. The C4 function now uses the swapped convention. FIX: h_neg should use `(ψ.untl φ)` for the negation formula. Since the goal uses `untl φ ψ` and C4 uses `untl δ γ` with δ=event, the formula `(ψ.untl φ).neg` means "not(event ψ until guard φ)". This is the correct negation of the Until in C4.

Lines 598, 633: `h_until'`/`h_since'` — the forward coherence functions return event at witness, guard at intermediates. The `show` statements and destructuring need to match.

Lines 612, 617, 647, 652: Guard application — `hy_guard` now returns `ψ` (guard) not `φ`, so the `show` and `apply` need swapping.

### Recommended Approach
1. `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
2. Re-apply ONLY the coherence IH name swaps (h_ψ→h_φ, show φ/ψ swaps)
3. ALSO swap the `φ.untl ψ` → `ψ.untl φ` in the C4/C5 CALLS but NOT in the negation_complete calls
4. Test incrementally with `lake build`

## Files Modified (Complete List)

All files from the prior handoff + these new ones:
- ChronicleTypes.lean, RRelation.lean, PointInsertion.lean
- CounterexampleElimination.lean, ChronicleConstruction.lean
- CanonicalChain.lean, DefectChain.lean, Realization.lean, LocusControl.lean
- ChronicleToCountermodel.lean (PARTIALLY FIXED — still has 12 errors)
- TruthLemma.lean, UntilSinceCoherence.lean, Construction.lean
- RestrictedParametricTruthLemma.lean

## Script Location
`scripts/swap_untl_snce.py` — handles `Formula.untl`/`Formula.snce` patterns recursively.
Does NOT handle dot-notation (`β.untl γ`) or multi-line arguments.
