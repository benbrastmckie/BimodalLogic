# Task 334 — Phase 5 Handoff (RIGHT three-way segment-meet cut)

## Immediate Next Action
Phase 6 (Wave 4): `kvE2_sepArr'_sound` + rewire `kvE2_sepBody`/`kvE2_sepBody_nonvacuous` onto
`kvE2_sepArr'` (off the flat-union `List.Perm.refl`); DELETE the FALSE scaffolds
`kvE2_sepSlotsL_valid`/`_valid` (:894/:901) + the additive `kvE2_sepValid`/`kvE2_sepArrL`/`R` +
flatMap slot union. First step: prove `kvE2_sepArr'_sound` — a valid disjunct's realization implies
the joint conjunction — consuming the Phase-4/5 three-way cuts (`kvE2_sepSegLForSub'`,
`kvE2_sepSegRForSub'`) and the Phase-3 k-anchor region lift (`k1v_sorted_realizationK`).

## Current State
- Phases 1-5 COMPLETE, module green, axiom-clean on the new leaf.
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` → success (1013 jobs).
- Sorry count in SharedWitness.lean: 4 — ALL pre-existing (894/901 FALSE scaffolds → Phase 6;
  2069/2212 singleton retreat → Phase 8). Phase 5 introduced ZERO sorries.

## Key Decisions (Phase 5)
- `kvE2_sepSegRForSub'` mirrors `kvE2_sepSegLForSub'` with roles swapped: RIGHT-interior owner
  (`zWT3`) carries the tie/three-way cut; LEFT-interior owner (`zXW3`) contributes uniform `zWT`.
- Meet on RIGHT = `Formula.and (segForm zWX1) (segForm zWT)` — the two open sub-intervals `(w,x1)`
  and `(x1,t)` around the closed anchor (§5 right sub-interval `A_i^+(z,z_1)`, md:170).
- Signature dropped the `lR`/`j` structural-read params (as LEFT did); keys on the placement TAG.
- "at"-case soundness discharged the first `if` (`= zXW3`) as negative via the pre-existing private
  `kvE2_sep_zWT3_ne_zXW3` (:1414), then `if_pos hzone` for the `zWT3` branch.
- Closed-zone leaf `kvE2_sepCompat_zAtX1L_eq` (Phase 4) serves BOTH sides — no new right-side leaf.

## Sorry Inventory (unchanged from Phase 4; Phase 5 added none)
- SharedWitness.lean:894 `kvE2_sepSlotsL_valid` — FALSE scaffold, remove Phase 6.
- SharedWitness.lean:901 `kvE2_sepSlotsR_valid` — FALSE scaffold, remove Phase 6.
- SharedWitness.lean:2069 `kvE2_sepBody_singleton*` — singleton retreat, remove Phase 8.
- SharedWitness.lean:2212 `kvE2_sepBody_singleton*` — singleton retreat, remove Phase 8.
