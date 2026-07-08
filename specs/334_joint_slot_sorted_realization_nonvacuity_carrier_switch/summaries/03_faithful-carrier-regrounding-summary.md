# Task 334 — Phase 4 Implementation Summary (LEFT)

- **Phase**: 4 — Closed-zone compat leaf + three-way segment-meet cut (LEFT) — [COMPLETED]
- **Plan**: plans/03_faithful-carrier-regrounding.md
- **Session**: sess_1783539835_7b6867
- **File modified**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (macro-side, F7)

## Lemmas / defs produced (all axiom-clean, no sorry)

1. **`kvE2_sepCompat_zAtX1L_eq`** — the 5th, closed-zone compat leaf. Concludes
   `kvE2_sepSpikeDisjValid σ χ .coincident = true` for a FOREIGN owner's base type `χ` realized AT
   σ's fresh anchor `x1`. The disjunct read is definitionally the CLOSED `zAtX1L` bit (F5); it is
   discharged TRUE by the preserved axiom-clean `kvE2_sepCoincidentAnchor_discharge`. This re-hosts
   the Phase-2 `kvE2_sepClosedLeafStub` (which read σ's own fresh type `nf0_projFresh σ.1` as a
   structural placeholder) over foreign owner types — the §5 meet-typed shared point (md:168-173).

2. **`kvE2_sepSegLForSub'`** (def) — the three-way LEFT segment cut, keyed on σ's placement tag
   (`KvE2SepSpikeOrderType`) branching under `nf0_zoneSpec σ.1`:
   - left-interior (`zXW3`): `strictBefore` → `kvE_sub2_zXU` (before β); `coincident` → the MEET
     `Formula.and (segForm σ zXU) (segForm σ zUW)`; `strictAfter` → `kvE_sub2_zUW` (after β);
   - right-interior (`zWT3`): uniform `kvE_sub2_zXU`;
   - else: `Formula.top`.
   Additive — the binary `kvE2_sepSegLForSub` (`:561`) is retained; Phase 6 rewires the assembly.

3. **`kvE2_sepSegLForSub'_at_sound`** — the "at"-case soundness (Risk R2 core content). For a
   left-interior σ, the coincidence case IS the §5 meet `A_i = A_i^- ∧ A_i^+` (md:168): the
   `Formula.and` of the `(x,x1)` and `(x1,w)` exclusions — universal β over the whole shared
   interval `(x,w) ∖ {x1}`. Non-vacuous (never `Formula.top`), QF (F1). Proved by definitional
   reduction (`simp only [kvE2_sepSegLForSub', hzone, if_pos]`).

## Preserved-asset audit

- `kvE2_sepCompat_lX1_eq` (:409) and `kvE2_sepCompat_lX1_after_eq` (:422) — **unchanged**; survive as
  the strict-disjunct validators (open `zXU`/`zUW` reads). Module builds green with them intact.
- `kvE2_sepCoincidentAnchor_discharge` (:1161) — unchanged; consumed by the new leaf.
- `kvE2_sepFreshAnchor_ne_baseChiPoint`, `k1v_sorted_realizationK`, all Phase 1/2 constructs —
  unchanged. Binary `kvE2_sepSegLForSub` left in place per abandon-list timing.

## Faithfulness invariants

F1 (QF meet type), F2 (meet, not vacuity — the at-case discriminates), F5 (closed key for tie vs
open keys for strict), F6 (per-bracket chain unaffected), F7 (macro-side confinement) all preserved.
No invariant violated.

## Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` — green (1013 jobs).
- `lean_verify` on `kvE2_sepCompat_zAtX1L_eq` and `kvE2_sepSegLForSub'_at_sound`:
  `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- No new sorries, no vacuous definitions, no new axioms. Pre-existing sorries at :894/:901/:2069/:2212
  (abandon-list FALSE scaffolds + singleton retreat) are untouched — scheduled for removal in Phases 6/8.

## Scope discipline

Single-phase focus honored: only Phase 4 (LEFT) implemented. Phase 5 (RIGHT) not started.
