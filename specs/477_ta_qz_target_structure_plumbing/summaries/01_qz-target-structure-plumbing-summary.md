# Implementation Summary: Task #477

- **Task**: 477 - T-A: Target-structure plumbing for the groupable-companion route
- **Plan**: `specs/477_ta_qz_target_structure_plumbing/plans/01_qz-target-structure-plumbing.md`
- **Status**: [COMPLETED]
- **Type**: lean4
- **Session**: sess_1787636012_6457eb

## What Landed

`FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean` (194 lines: ~105-line
`/-! … -/` header + 89-line body), containing:

- Four `example … := inferInstance` carrier-gate lines pinning `ℚ ×ₗ ℤ` against the exact four
  binders of `FormalSystem.Semantics.valid` (`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`,
  `Nontrivial`).
- `QZStructure`, `QZStructure.toMonadic`, `QZStructure.toOrdered`, `QZStructure.toOrdered_carrier`.
- `goodGroupable`, `goodGroupable_of_kEquiv`, `goodGroupable_of_orderIso`.
- `NoMaxOrder (ℚ ×ₗ ℤ)` / `NoMinOrder (ℚ ×ₗ ℤ)` instances and the two `*_of_goodGroupable`
  corollaries (the guardrail against a `veryGoodGroupable`).

`FormalSystem/Metalogic/WeakCanonical.lean` gained one `-- CI edge only` import block after the
`DenseModelSurgery/` chain, on that module's stated precedent, so the new leaf stays inside the
`lake build` closure.

## Phase Results

| Phase | Status | Outcome |
|---|---|---|
| 1 — module body + build edge | [COMPLETED] | File created (89-line body transcribed from the research probe), CI edge added, `lake build` exit 0 at 2488 jobs |
| 2 — repo-standard module header | [COMPLETED] | Header prepended; scoped module build exit 0; no task-number citations |
| 3 — acceptance gate | [COMPLETED] | All gates below pass |

## Acceptance Gate Results

| Check | Baseline | After | Verdict |
|---|---|---|---|
| `lake build` | exit 0, 2487 jobs | exit 0, 2488 jobs | PASS (+1 for the new module) |
| Bare `sorry` outside `Boneyard/` | 1 (`Transfer.lean:1102`, `countermodel_discrete`) | 1, same location | PASS (unchanged) |
| `sorry` under `GroupModel/` | — | 0 | PASS |
| Real `axiom` declarations | 0 | 0 | PASS (the 5 `^axiom ` grep hits are prose inside doc comments in `Semantics/`) |
| `check-module-invariants.sh` C1–C11 | — | ALL CHECKS PASSED | PASS |
| `#print axioms` × 5 | — | `[propext, Classical.choice, Quot.sound]` on all five | PASS |
| `veryGoodGroupable` declaration | — | none (only named in the header's prohibition) | PASS |
| `GroupModel.lean` aggregator | — | not created | PASS |
| Vacuous-definition scan under `GroupModel/` | — | 0 | PASS |

C6 specifically confirms the CI edge works: the new module does not appear in the unreachable
set (22 unreachable, all manifested, unchanged), so it is inside the build closure without any
`scripts/module-invariants-manifest.txt` entry.

The five `#print axioms` checks were run from
`specs/477_ta_qz_target_structure_plumbing/verification/qz_axiom_gate.lean` via
`lake env lean`, outside `FormalSystem/`; no `#print axioms` line was left in the landed module.

## Design Rulings Recorded in the Module Header

1. **Full carrier, not an `Option`-bounds interval.** `ZIntervalStructure`'s `lo hi : Option ℤ`
   representation is not mirrored. The header records the machine-checked reason:
   `S = {x : ℚ ×ₗ ℤ | (ofLex x).1 < 0}` is `Set.OrdConnected`, has no greatest element, and `Sᶜ`
   has no least element, so no `Option`-endpoint pair denotes it — ord-connected subsets of this
   carrier are not endpoint-determined. Second, independent reason: an interval of the carrier is
   not a group, and the frame-side construction downstream needs the group binders.
2. **No `veryGoodGroupable`.** At `k ≥ 2` the carrier's `NoMaxOrder`/`NoMinOrder` propagate
   backwards across `≡_k` via `noMaxOrder_of_kEquiv`/`noMinOrder_of_kEquiv`, so every closed
   subinterval fails `goodGroupable` and any such definition would be identically false. The two
   `*_of_goodGroupable` corollaries are named in the header as the checked guardrail.

Both siblings (`IntegerModel/GoodStructures.lean`, `RealModel/GoodDense.lean`) are read, not
edited; what is mirrored from them is API shape only. The header cites Reynolds 1992 §8
*"Doets' Theorem"*, printed p.185, and defers the verbatim source block and page measurement to
`RealModel/GoodDense.lean`'s `## The source, verbatim` section rather than repeating it.

## Plan Deviations

- None (implementation followed plan).

## Not Done (by design, per plan Non-Goals)

- The companion lemma consuming `goodGroupable` — successor task.
- `countermodel_discrete` and its `sorry` — untouched.
- No `veryGoodGroupable`, no `GroupModel.lean` aggregator, no `QZSegmentStructure`.
- `specs/ROADMAP.md` not edited: the Base frame-class row stays open until the successor chain
  discharges `countermodel_discrete`.

## Files Modified

- `FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean` (new)
- `FormalSystem/Metalogic/WeakCanonical.lean` (one `-- CI edge only` import block)
- `specs/477_ta_qz_target_structure_plumbing/verification/qz_axiom_gate.lean` (new; scratch
  axiom-gate driver, outside `FormalSystem/`)
