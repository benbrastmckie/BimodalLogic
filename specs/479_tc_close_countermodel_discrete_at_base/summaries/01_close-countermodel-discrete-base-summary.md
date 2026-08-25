# Implementation Summary: Close `WeakCanonical.countermodel_discrete` at Base

- **Task**: 479 - tc_close_countermodel_discrete_at_base
- **Type**: lean4
- **Plan**: `specs/479_tc_close_countermodel_discrete_at_base/plans/01_close-countermodel-discrete-base.md`
- **Report**: `specs/479_tc_close_countermodel_discrete_at_base/reports/01_countermodel-discrete-base-port.md`
- **Phases**: 5 of 5 completed
- **Status**: implemented
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD

## Outcome

`FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` is **proved**. It was the tree's
sole live structural `sorry` and the only `sorryAx` source reaching
`BXCanonical.completeness`. Both are now free of `sorryAx`, and the repository's
structural-sorry inventory is **zero**.

The theorem could not be closed in place: closing it needs `companionChronicle`, and the import
chain `Transfer.lean ← IntegerModel/ReynoldsBridge.lean ← GroupModel/GroupableCompanion.lean`
makes `Transfer.lean` strictly upstream of that lemma. It was therefore relocated to a new
module under the same namespace, which preserves the fully-qualified name — so its sole
consumer, `BXCanonical/Completeness.lean:229`, needed **no edit at all** (verified: zero diff
on that file across the whole task).

## Phase Record

| Phase | Name | Status | Commit |
|-------|------|--------|--------|
| 1 | Module scaffold, aggregator wiring, carrier arithmetic lemmas | [COMPLETED] | `bac61376c` |
| 2 | Port the v2 proof body at `ℚ ×ₗ ℤ` under a temporary name | [COMPLETED] | `7411bd425` |
| 3 | Cutover — rename + delete the `Transfer.lean` original | [COMPLETED] | `5ae98e958` |
| 4 | Retarget CI invariant checks; correct stale docstrings | [COMPLETED] | `5e6ea044e`, `18c7a119e` |
| 5 | Final verification and acceptance | [COMPLETED] | (this commit) |

## What was built

`FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` (NEW, ~470 lines) hosts
the proof. The body is the port of `countermodel_discrete_reynolds_v2`
(`IntegerModel/ReynoldsBridge.lean:936-1352`) with three substitutions:

- `limitdom_is_good N hN_mcs (le_refl _) hN_box φ k` → `companionChronicle N hN_mcs hN_box φ k`.
  The `h_fc : FrameClass.Discrete ≤ fc` slot disappears — that is the whole point of the
  companion lemma — and the result is `goodGroupable` rather than `good`.
- `multiFamTaskFrame` / `multiFamHistory` / `multiFamHistory_total` / `multiFam_total_eq` →
  `multiFamTaskFrameGen (ℚ ×ₗ ℤ)` / `multiFamHistoryGen` / `multiFamHistoryGen_total` /
  `multiFamGen_total_eq` (`Algebraic/FlowFrame.lean`).
- `FrameClass.Discrete` → `FrameClass.Base` throughout. Every other step was already
  `{fc : FrameClass}`-generic; `Axiom.modal_t` is a `.Base` axiom, so its `trivial` membership
  proof survived unchanged.

Two body-level consequences of the carrier change, both as the research report predicted:

- **~40 lines deleted, not ported.** `QZStructure.toOrdered_carrier` is `rfl`, so the companion
  carrier *is* `ℚ ×ₗ ℤ` — there is no `lo`/`hi`-carved interval subtype. `h_bounds`, `h_lo`,
  `h_hi`, the `z_interval_carrier_contains_all` call, the `2 ≤ k` side condition, and all 16
  `toCarrier (h_lo f) (h_hi f) e` applications with their `Subtype.ext`/`.val` bookkeeping have
  no analogue and were dropped.
- **Every `omega` replaced.** `omega` does not run at `ℚ ×ₗ ℤ`. The 16 sites in the
  `untl`/`snce` cases became citations of named private ordered-group lemmas.

The statement is byte-identical to the original: ten binders, four fewer than the v2 Discrete
version (`SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean` are all dropped —
`FrameClass.Base` imposes no Archimedean condition, which is exactly what makes the
non-Archimedean carrier admissible). **No weakening of any kind.**

## Plan Deviations

Two, both anticipated and admitted by the plan's per-phase Scope Hypothesis clauses; recorded
inline on the plan's checklist items.

1. **Phase 2 — two arithmetic helpers beyond the planned three.** The plan's Scope Hypothesis
   asserted three `ℚ ×ₗ ℤ` facts sufficed to replace all 16 `omega` calls. Two more were needed:
   - `qz_sub_add_cancel` (`z - t + t = z`) — a fourth arithmetic shape, in the **box** forward
     case (`h_univ`), where the `ℤ` blueprint used `omega`. The plan's hypothesis was scoped to
     `untl`/`snce`, so the box case was genuinely unanticipated.
   - `qz_exists_shift` (`∃ x, w + x = r`) — the offset-surjectivity packaging of
     `qz_add_sub_cancel`. Needed for a Lean-mechanical reason rather than a mathematical one:
     `rc`/`sc` in the `untl`/`snce` cases have type `((getQ f).toOrdered sig).carrier`, only
     `rfl`-equal to `ℚ ×ₗ ℤ`, and Lean's `-` elaborator compares operand types syntactically, so
     a subtraction cannot be written against those points directly (`HSub carrier (Lex (ℚ × ℤ))
     ?m` fails to synthesize). Passing the point through a function argument instead makes the
     defeq check happen at unification, where it succeeds. The same gap forced the
     existential-packaging zero-shift step to use an explicit congruence (`h_point`) rather than
     `rw [qz_zero_add]`.

   Neither is a mathematical addition; both are bookkeeping around the carrier's defeq
   presentation. Both are stated, proved, and documented in the module.

2. **Phase 4 — six docstring sites beyond the report's nine-file inventory.** A fresh repo-wide
   grep found stale "sole/only structural sorry" claims the report missed:
   `FormalSystem/README.md:30`, `FormalSystem/Metalogic/README.md:284`,
   `FormalSystem/Metalogic/WeakCanonical/README.md:26` (plus a stale line count and a missing
   `GroupModel/` row), `FormalSystem/Metalogic/Decidability/FMP/README.md:26`,
   `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean:98`, and the C3 header comment
   in `scripts/check-module-invariants.sh:11`. Per the phase's Scope Hypothesis these were
   treated as additions to the list, all fixed. The repository has a documented history of
   stale sorry claims; this task retires the last of them.

## Verification Evidence (Phase 5)

All from a green tree.

```
lake build                       →  Build completed successfully (2493 jobs)
lake build BimodalTest           →  Build completed successfully (2543 jobs)
bash scripts/check-module-invariants.sh  →  ALL CHECKS PASSED
```

`#print axioms` against fresh oleans
(`specs/479_tc_close_countermodel_discrete_at_base/verification/axioms_final.lean`):

```
'FormalSystem.Metalogic.WeakCanonical.countermodel_discrete'  → [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness'             → [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_dense'       → [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_discrete'    → [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' → [propext, Classical.choice, Quot.sound]
```

No `sorryAx` anywhere. The three C2 regression baselines (`completeness_dense`,
`completeness_discrete`, `countermodel_dense`) are unchanged.

Other gates:

- Structural-sorry grep over `FormalSystem/` excluding `Boneyard/`: **0 hits**. C3 now asserts
  this inventory at zero rather than at one.
- New `axiom` declarations: **none**. The five `^axiom ` grep hits in `FormalSystem/` are all
  prose lines inside docstrings (`Semantics/FrameAxioms.lean`, `Semantics/TaskFrame.lean`,
  `Semantics/Extension/Extension.lean`), in files this task did not touch.
- Vacuous definitions: **none introduced**. The one grep hit,
  `Examples/TemporalStructures.lean:538` `int_domain_universal … := trivial`, is a genuine proof
  — `intTimeHistory.domain t` is definitionally `True` — and predates this task.
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean`: **zero diff** across the whole task,
  as the plan required.

## Files Changed

**New**
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` — hosts the proved
  `countermodel_discrete`, its four private `ℚ ×ₗ ℤ` arithmetic lemmas, the offset-shift helper,
  and the carrier gate.

**Modified — source**
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` — 50 lines shorter; the theorem and its
  `/-! ## countermodel_discrete — the one live sorry -/` section header removed; module header
  rewritten to point at the new home.
- `FormalSystem/Metalogic/WeakCanonical.lean` — new import; the `GroupableCompanion` "CI edge
  only … leaf" comment demoted (it has a real consumer now); Main Export and Status sections
  rewritten.
- `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/BXCanonical/Completeness.lean`
  (docstrings only), `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean`,
  `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`,
  `FormalSystem/Metalogic/Decidability.lean`,
  `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`,
  `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean`,
  `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` — stale-sorry docstrings.

**Modified — infrastructure and docs**
- `scripts/check-module-invariants.sh` — C2 baseline drops `sorryAx` from `completeness`; C3
  retargeted from "exactly 1 structural sorry in `Transfer.lean`/`countermodel_discrete`" to
  "**zero** structural sorries", with the now-dead `EXPECTED_FILE`/`EXPECTED_THM`/`ENCLOSING`
  scan machinery deleted.
- `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/WeakCanonical/README.md`,
  `FormalSystem/Metalogic/Decidability/FMP/README.md`.

## Non-Goals Honoured

The O1 isomorphism and `succ_cofinal` were not re-examined. `companionChronicle` was consumed by
signature and not re-derived. No construction-level work was done in `ChronicleConstruction.lean`
or `PointInsertion.lean`. `truth_transfer` was not moved out of `Transfer.lean`. No `sorry` was
introduced and no statement was weakened.
