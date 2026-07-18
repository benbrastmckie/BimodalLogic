# Task 379 — Phase 8 Execution Summary (Widen-Last Field Flip)

**Plan:** `plans/09_partial-interval-rearchitecture.md` — Phase 8 only.
**Status:** [COMPLETED]. Full `lake build` EXIT 0 at 1770 jobs; `completeness_discrete` axiom set unchanged.

## What Phase 8 achieved

`ExistsForallFormula.intervalType` was widened from the complete type `Fin (n+2) → UnaryType` to the
genuine **partial** type `Fin (n+2) → IntervalType` (`= Finset UnaryType`). Point types stay
`UnaryType`. The interval field is now genuinely partial; `efSat`'s three interval clauses read the
partial satisfaction relation `intervalHolds`.

## Execution (four green commits)

The flip is atomic across the dependency graph, so the consumer migration was landed first as green,
committable checkpoints while the field was still complete-typed, and the field flip landed last:

- **8.1 — relocation.** Moved `efIntervalSetTP` / `eval_at_foldr_disj` / `efIntervalSetTP_eval` from
  `Prop42NegationGeneral.lean` (downstream) UP into `Prop35Assembly.lean`, next to `efIntervalTP`
  (added `import ...VecEAClosure` for `eval_at_disj`). This makes the set-level renderer available to
  the upstream consumers `Prop35Assembly` and `Prop42ExistsForall`.
- **8.2 — Prop35Assembly.** Routed `translateProp35` and `translateProp35_correct`'s interval clauses
  through `efIntervalSetTP ∘ ψ.intervalSet` and `efIntervalSetTP_eval`/`intervalHolds`, dropping the
  `intervalSet_holds_iff` bridge (efSat already yields `intervalHolds` via `efSat_interval_iff`).
- **8.3 — Prop42ExistsForall.** Same set-renderer routing for `translateProp42` and its
  forward/backward correctness proofs; `EndpointPinnedCapTrivial.capTrivialLeft/Right` restated on
  `intervalHolds N (ψ.intervalSet ·)`.
- **8.4 — the flip.** Field widened to `IntervalType`; `efSat` interval clauses use `intervalHolds`;
  `intervalSet` collapsed to the identity on the field; the stale `intervalSet_holds_iff` family
  deleted; `efSat_interval_iff` becomes reflexivity. `IntervalType` and `intervalHolds` were moved UP
  from `IntervalType.lean` into `ExistsForallFormula.lean` (the field and `efSat` reference them, and
  `IntervalType.lean` imports `ExistsForallFormula` — a reverse reference would be an import cycle).

## Plan deviations

- **`ofComplete` constructor updates — skipped (not needed).** No from-scratch `UnaryType` interval
  producers exist on the migrated path: every interval-field value flows from a field copy
  (`pairProject`/`dropPin`/`existenceSentence`) or from `ConjInterleave.chainIntervalType` (which
  reads the field). All producers auto-adapted to the widened field type.
- **`ConjInterleave.lean` mechanical update — skipped (not needed).** `chainIntervalType` reads
  `ψ.intervalType`, so its inferred return type widened automatically; the module typechecks
  unchanged with its tracked `conjInterleave_forward` strategic sorry intact.

## Verification

- Full `lake build` EXIT 0 at 1770 jobs.
- `#print axioms completeness_discrete` = `[propext, sorryAx, Classical.choice, Lean.ofReduceBool,
  Lean.trustCompiler, Quot.sound]` — identical to baseline (spine still carried by the pre-existing
  `KampPrior.lean:562` sorry, to be retired in Phase 13).
- No new `sorry`, no vacuous definition, no new axiom.
- Amended sorry gate holds: only the permitted live sorries remain (`nf_nvar_exist_all_depths|_k+2`,
  the two `EANegation` sorries, and the tracked `conjInterleave_forward` continuation sorry).
- Interval field is genuinely partial (`IntervalType := Finset UnaryType`).

## Next

Phase 9 (α restated) is now unblocked: redefine the `conjInterleave` merge to the genuine
intersection `chainIntervalType ψ₁ ∩ chainIntervalType ψ₂` on the partial field, prove the full
`conjInterleave_iff` biconditional (discharging `conjInterleave_forward`), and build
`veeConj`/`veeConj_iff`.
