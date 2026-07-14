# Task 350 Phase 9 Handoff (20260713)

## Immediate Next Action

Dispatch Phase 10 (C / P2c): `BracketFormula.negFix` — gated Cases 1-3 + ℤ counterexample,
appended to `Kamp/EANegationFix.lean`. FIRST PROBE (R2 gate) is the ℤ counterexample `example`.
Phase 10 depends on Phases 7 and 9 — both now complete. Phase 12 (D / P3-pt,
AggregatePointMergeK1.lean) remains file-disjoint and parallelizable (wave 1).

## Current State

- Phases 1-9 of 17 COMPLETED. Build green (full `lake build`), zero sorries in Phase-9 scope,
  axiom-clean (`lean_verify` on both `_iff` theorems: exactly propext/Classical.choice/Quot.sound).
- `Kamp/EANegationFix.lean` now contains the full Phase 8+9 negation stack:
  `negChainOn(_iff)` (Lemma 5.3), `negBoundedRightFix(_iff)` (Cor 5.4(1)),
  `negBoundedLeftFix(_iff)` (Cor 5.4(2)).
- New import added: `EANegationFix` now also imports `Kamp.EANegationClosure` (for
  `BracketFormula.tail`, `TemporalPred.eval_at_neg'`, `HasAttainedINF.first_occ_tp`).
  Cycle-free (EANegationClosure imports only EANegation/VecEAClosure/Mathlib). The
  cycle-freeness comment at NfMultiAnchorBridge.lean:75 ("imports only Kamp.VecEAConjFull")
  is now slightly stale — cosmetic only.

## Key Decisions (binding for Phase 10/11 consumers)

1. **Statement shapes** (H3-binding, delivered):
   - `negBoundedRightFix_iff M atomMap h_INF bf z0 z1 h_lt :
      (negBoundedRightFix bf).holds M atomMap z0 z1 ↔ ¬∃ z, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z`
   - `negBoundedLeftFix_iff M atomMap h_INF h_SUP bf z0 z1 h_lt :
      (negBoundedLeftFix bf).holds M atomMap z0 z1 ↔ ¬∃ z, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1`
   - Right mirror needs only `h_INF` (plan sketch listed h_SUP too — annotated deviation).
2. **Endpoint-free form**: the moving endpoint carries no point type. Phase 10 Case 2 must hand
   the peeled bracket over endpoint-free; a needed point type at the moving endpoint folds into
   the adjacent fold pair.
3. **Reusable kit** for Phase 10: `bracketOf`/`bracketSnocOf` list brackets with holds-iffs,
   the `chainAllTrue` cons/snoc/mono kit, `untilFold`/`sinceFold`, the two bridges
   (`holds_iff_bracketOf`, `holds_iff_bracketSnocOf`), and the pin brackets with their iffs —
   all in EANegationFix.lean.

## Sorry Inventory

Empty. (Pre-existing sorries elsewhere — EANegation.lean:1090/1249 (task 305 impossibility
documentation), KampPrior.lean:361/364 (task 358 territory), BXCanonical/Algebraic/Boneyard —
are outside task-350 scope and unchanged.)

## References

- Plan: `plans/02_offdiag-k1-aggregate-discharge.md` (Phase 9 marked COMPLETED with inline
  deviation annotations; Phase 10 spec at lines ~473-503)
- Summary: `summaries/02_phase9-cor54-mirrors-summary.md`
- Phase 8 handoff (delivered negChainOn API): `handoffs/phase-8-handoff-20260713.md`
