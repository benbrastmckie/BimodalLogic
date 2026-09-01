# Implementation Summary: Eliminate the 21 overlapping `[Nontrivial D]` instance warnings

- **Task**: 515
- **Plan**: `specs/515_eliminate_overlapping_nontrivial_instance_warnings/plans/01_eliminate-overlapping-instance-binders.md`
- **Status**: COMPLETED — all 4 phases green
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Type**: lean4

## What Changed

All 21 `linter.overlappingInstances` warnings were one defect with one shape: an enclosing
`variable` block and a nearer binder both supplying `[Nontrivial D]` for the same `D`. Every site
was fixed by *deleting the redundant binder*. No linter was disabled anywhere.

| File | Sites | Edit |
|---|---|---|
| `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` | 13 (Class A) | ` [Nontrivial D]` deleted from 13 declaration lines under the `:449` section binder |
| `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` | 5 (Class A) | ` [Nontrivial D]` deleted at `:2144`, `:2149`, `:2162`, `:2172`, and continuation line `:2762` |
| `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` | 3 (Class B) | `variable [Nontrivial D]` at `:351` deleted; the `:348-350` comment retargeted to the surviving `:346` binder |

`Decidable.lean:2762` was the one delicate site: it carried `[DenselyOrdered D] [Nontrivial D]` on
a continuation line of the `:2761 truthAt_sep` declaration. Only the `[Nontrivial D]` token was
removed; the line now reads exactly `    [DenselyOrdered D]` and was not deleted.

## Class B ownership decision (recorded)

For all three `TruthLemma.lean` sites (`RegionValued`, `atomRegionInvariant_regionHistory`,
`interpInvariantAt_regionHistory`), the `section Countermodel` header binder at `:345-346` owns
`[Nontrivial D]` and the `variable [Nontrivial D]` at `:351` was deleted. The plan's no-shadowing
finding was re-confirmed against the live pre-edit source before editing: `end Invariance` at
`:335` closes the section holding the `:74` binder, and `section Countermodel` opens at `:343`, so
the outer `D` is out of scope and `:345`'s `{D : Type}` is the section's only introduction of `D`.
The compiler corroborated this — the pre-edit diagnostic named exactly **2** `[Nontrivial D]`
instances, not 3, and reported no `AddCommGroup`/`LinearOrder` overlap.

Three grounds for keeping `:346` rather than `:351`:
1. The `:348-350` comment states a requirement about *scope*, not position — that `[Nontrivial D]`
   be declared in its own right rather than recovered from `[NoMaxOrder D]`, so the `omit` clause
   below cannot strip nontriviality along with the density instances. `:346` satisfies it
   identically: it is equally absent from that `omit` list. The comment's claims survive intact;
   only its anchor moved.
2. `:346` is the codebase-wide duration-group bundle shape, matching `TruthLemma.lean:74`,
   `Decidable.lean:136`, `FlowFrame.lean:449`, and 33 other files.
3. It is the binder-order-preserving choice: `interpInvariantAt_regionHistory`'s surviving
   `[Nontrivial D]` keeps the baseline's slot in the elaborated signature.

The `omit` clause (now `:367`) still lists exactly
`[Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]` and still does not mention
`Nontrivial D`.

## Verification

Baseline was measured first, from a real full build of the unmodified tree, so every "before"
figure below is the compiler's own and not an assumption.

| Gate | Baseline | After | Result |
|---|---|---|---|
| Forced full `lake build --no-share` | exit 0, `Build completed successfully (2506 jobs).` | exit 0, `Build completed successfully (2506 jobs).` | PASS (job count confirmed in log) |
| `lake test` | — | exit 0, 0 errors | PASS |
| `Overlapping instance parameters`, tree-wide | 21 | **0** | PASS |
| — `FlowFrame.lean` | 13 | 0 | PASS |
| — `Decidable.lean` | 5 | 0 | PASS |
| — `TruthLemma.lean` | 3 | 0 | PASS |
| `automatically included section variable` | 97 | 83 | as predicted (-14: FlowFrame -10, Decidable -2, TruthLemma -2) |
| total `warning:` occurrences | 381 | 346 | -35 = 21 overlapping + 14 unusedSectionVars |
| `error:` | 0 | 0 | PASS |
| `declaration uses 'sorry'` | 0 | 0 | PASS |
| `comm -13 baseline new` over sorted warning text | — | **empty** | PASS — no new warning of any class |
| `grep -rn overlappingInstances FormalSystem/` | — | no match (exit 1) | PASS |
| `sorry`/`admit`/`native_decide` token count in `FormalSystem/` | 1170 | 1170 | unchanged |
| `^axiom ` occurrences in `FormalSystem/` | 7 (all prose in comments) | 7, identical set | unchanged |

The no-new-warning check was set-theoretic, not a count comparison, and was run twice — once with
`file:line:col` retained and once with location stripped. Both `comm -13` results were empty, and
the baseline-only side contained exactly 21 `Overlapping instance parameters` plus 14
`automatically included section variable` entries and nothing else. No warning was substituted for
another.

Per-file gates were additionally run with `lake env lean` on each of the three files (all exit 0),
and the one-hop dependent `Bridge/Valuation.lean` built clean with no source edit (guarded build,
exit 0, 1409 jobs); its three residual warnings are byte-identical to baseline.

## Residual warnings (deliberately out of scope, per the plan's Non-Goals)

- `FlowFrame.lean:635 fmcs_box_persistent` — one `unusedSectionVars`, unrelated to this fix
- `Decidable.lean:1000/:1019/:1153/:1164` — four `unusedSectionVars`, pre-existing
- `Decidable.lean:892/:929/:1237/:1246` and `TruthLemma.lean:193/:223/:254/:266` — `push_neg`
  deprecations, pre-existing

## Plan Deviations

- None (implementation followed plan).

## Commits

- `2b9217336` task 515 phase 1: FlowFrame.lean — 13 Class A binder deletions
- `fc6a173e7` task 515 phase 2: Decidable.lean — 5 Class A binder deletions
- `9b776a655` task 515 phase 3: TruthLemma.lean — Class B ownership fix
- Phase 4 (verification only, no source change) — this summary
