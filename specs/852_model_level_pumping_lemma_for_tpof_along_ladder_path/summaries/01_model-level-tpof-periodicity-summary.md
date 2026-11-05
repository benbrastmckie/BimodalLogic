# Implementation Summary: Task #852

- **Task**: 852 - Author a model-level pumping lemma for tpOf along a ladder path
- **Status**: [COMPLETED]
- **Started**: 2026-11-05T08:05:00Z
- **Completed**: 2026-11-05T08:45:00Z
- **Effort**: ~40 minutes
- **Dependencies**: 855
- **Artifacts**: plans/01_model-level-tpof-periodicity.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The model-side periodicity statement the layer lacked is authored, in the one form that is true:
the realized stab-free type of a ladder path is `l`-periodic whenever that path's object walk is
globally `l`-periodic. The unconditional (eventual, threshold-and-period) form — the shape
`satThreshold`/`satPeriod` carry on the certificate side — is compiled as FALSE by a new wired
probe, so the conditional form's hypothesis is shown to be load-bearing rather than decorative.
The honest gap is recorded in the layer's own record: the condition is unavailable exactly where
the third circularity runs, so these declarations do not discharge it.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — two new theorems after
  `tpOf_stabFree_eq_of_objAt_eq` (section `Hist`), plus a new module-docstring section:
  - `tpOf_periodic_of_objAt_periodic` — `hper : ∀ v : ℤ, objAt g (v + l) = objAt g v` gives
    `tpOf M φ σ (z + l) = tpOf M φ σ z` at every `z`. Proof: `tpOf_timeShift` composed with half
    (i) (`tpOf_stabFree_eq_of_objAt_eq`) at `σ' := σ.timeShift l`, the shifted presentation
    supplied from `WorldHistory.timeShift_state` plus a `ring`-level rearrangement of `t + l + k`.
  - `objAt_tpOf_eq_of_objAt_periodic` — the same fact as the `(objAt, tpOf)` endpoint pair at
    distance `l`, in the tuple shape `exists_typeBlock_of_spacing` and
    `tpOf_eq_spliceIdx_of_tpOf_eq` consume.
  Both landed with the pinned `## Lean Challenge Statements` signatures: hypothesis lists and
  conclusions are byte-identical to the plan's, with only the section-level
  `{Q : Type} [Finite Q] [Nonempty Q] {step} {pend}` binders supplied by the host `variable`
  block, which the plan's Binder note explicitly permits.
- `specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean` — new wired
  probe. All-idle two-state object (`pendA _ = false`, `stepA` total), so `Adm` pins the countdown
  to `0`, `Count` is discharged by its idle clause everywhere, and the object walk is completely
  unconstrained. Seriality discharged (`fwdA`, `bwdA`), walk `true` exactly at the powers of two
  via a computable bounded test (`isP2`, `List.any` over `List.range (m+1)` — no `noncomputable`,
  no classical `decide` in the walk), tail-aperiodicity arithmetic compiled (`wA_pow`,
  `wA_pow_add`, `exists_pow_ge`), path and history from the landed `exists_ladderPath_of_walk` and
  `exists_hist_of_isLadderPath`. Headlines:
  `tpOf_periodicity_refuted_unconditional : ¬ TpOfEventualPeriodicity`,
  `exists_separating_positions`, `wA_not_periodic`.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — a trailing bold-headed record
  paragraph naming the two declarations, their quantifier, the refuted unconditional form, and the
  verdict sentence about the gap.
- `FormalSystem/Metalogic/README.md`, `README.md`, `typst/generated/status.typ` — generated
  count/inventory blocks refreshed; drift is exactly this task's own line delta.

## Decisions

- The separating formula is the negated letter `chiA := ¬ p`, not a nested eventuality. The
  refutation needs only that the atomic clause reads `objAt`, and a closure of `{¬ p, p, ⊥}` keeps
  BOTH compared types nonempty (the letter in one, its negation in the other), which an atom alone
  would not.
- The aperiodic walk is defined by a computable bounded power-of-two search rather than by a
  classical `decide` over `∃ n, 2 ^ n = v`, so the probe introduces no `noncomputable` definition
  and no classical choice in the fixture itself.
- The RaySummary README's declaration table is a GENERATED per-file inventory block, so the two
  declarations are recorded in the bold-headed trailing-paragraph style the file's later entries
  use, and the generated block was refreshed with
  `scripts/check-module-invariants.sh --emit-inventory` rather than hand-edited.
- The probe is registered without an ordinal. Ordinals in that README run to "fifteenth" in
  `## Evidence` with one later "forty-seventh", and every entry after the fifteenth is registered
  without one; no ordinal was invented.

## Plan Deviations

- **Phase 3, `file_scope` addition** altered: no scope-addition call was needed.
  `specs/state.json`'s `file_scope` for this task already listed
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  the repo-root `README.md` and `typst/generated/status.typ` — all four of which this phase
  touched. Annotated inline on the plan's checklist.
- **Phase 3, README declaration rows** altered: recorded as a trailing bold-headed paragraph
  rather than table rows, because the only declaration table in that file is a generated inventory
  block (one row per FILE, carrying `<!-- TODO: add description -->` for `LadderAgree.lean`) that
  must not be hand-edited. Annotated inline.
- **Phase 2, probe-internal lemma** altered: the plan's prose said the witness violates
  `tpOf_periodic_of_objAt_periodic`'s hypothesis "at every `l`". That is false at `l = 0`, where
  global `0`-periodicity holds of every walk and the conditional lemma's conclusion is the
  identity. The probe lemma is therefore `wA_not_periodic (l : ℤ) (hl : l ≠ 0)`, and the probe's
  docstring states the `l = 0` case explicitly. No Challenge-pinned hypothesis or conclusion was
  changed; this corrects an overstatement in plan prose, not a decomposition or a statement.

## Verification

- Build: **Success**. `lake-build-guard.sh build --timeout 1800 -- build` (full project) exits 0,
  2900 jobs, 0 `error:` lines, and `LadderAgree.olean` is newer than its source. A full build was
  run at the end of every phase, not only at the final gate.
- Probe: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean`
  exits 0 with no `sorry` warning.
- Sorry count: **0** (`lean-sorry-census.sh` over all resolved source roots).
- Vacuous count: **0 in this task's diff**. The repo-wide grep returns one pre-existing hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`
  (`theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`), outside this
  task's diff and not introduced here.
- Axiom count: **unchanged at 14** repo-wide; this task's diff introduces no `axiom` declaration.
  `lean_verify` on both new declarations: `[propext, Classical.choice, Quot.sound]`, trust
  standard, no non-standard axiom, no warning. `#print axioms` on all eleven printed probe
  theorems: the same profile, with `[propext]` alone on `fwdA`/`bwdA`. No `sorryAx`, no custom
  axiom, no `native_decide`, no `noncomputable` `Decidable`-valued declaration.
- `hper` is load-bearing: a scratch copy of the statement with `hper` deleted fails to elaborate
  (`Unknown identifier 'hper'`), and the probe is the substantive demonstration — the form
  obtained by dropping the hypothesis altogether is compiled FALSE.
- The probe refutes the EVENTUAL form: `TpOfEventualPeriodicity`'s conclusion is
  `∃ N : ℤ, ∃ p : ℤ, 0 < p ∧ ∀ z : ℤ, N ≤ z → …`, carrying both a threshold and a period.
- Record gates: `check-module-invariants.sh --emit-inventory --check` PASS;
  `typst-sync-check.sh` PASS (status.typ, module map and machine appendix in sync);
  `readme-lint.sh` PASS; `check-task-references.sh` 0 unexempted occurrences; no record-version
  language in either deliverable edit.
- Plan compliance spot-check: `lean-plan-compliance-check.sh` reports
  `COMPLIANCE_CHECK: failed` on ONE finding, `[MISSING] l`. That finding is a tokenizer artefact:
  the script extracted the bare metavariable `l` from the Goals block's prose `` `l``-periodic ``
  and looked for a declaration named `l`. Both pinned Challenge identifiers resolve
  (`[OK] tpOf_periodic_of_objAt_periodic`, `[OK] objAt_tpOf_eq_of_objAt_periodic`), and their
  landed signatures are byte-identical to the plan's. Per
  `.claude/rules/plan-compliance.md`, a mechanical drift finding is advisory and is not on its own
  grounds to fail the task; it is reported here rather than suppressed.
- Batch-gate deferral, recorded honestly: this dispatch's directive defers the full gate set to the
  batch stage and asks for a narrowing `run-all.sh --only` / `verify-deploy.sh --only-gate`
  invocation covering this phase's files. Neither harness covers any file in this task's diff —
  `run-all.sh` discovers shell suites under `.claude/scripts/` and `agent-system/extensions/`, and
  `verify-deploy.sh` compares the deployed `.claude/` tree against the source store; this task
  touched no shell script, no `.claude/**` file and no `agent-system/**` file. The checks that do
  cover these files (the full `lake build`, the probe compile, `lean_verify`, and the four record
  lints above) were run in FULL rather than scoped. The batch-stage gate set still runs once for
  the whole invocation.
- Tests: N/A (no test-suite file touched).
- Files verified: Yes.

## Impacts

- The layer has a model-level periodicity statement about `tpOf` for the first time, available to
  any argument that can establish a globally periodic object walk, and delivered in both the
  equation form and the `(objAt, tpOf)` endpoint-pair form the type pigeonhole and the duplication
  type lemma already consume.
- The unconditional form is closed by evidence rather than left open, so no successor round spends
  effort on it or cites `satThreshold`/`satPeriod` as if it transferred to the model side.
- The third circularity is NOT discharged, and the record now says so in the layer's own words.
  The bridge from the certificate layer's periodicity (`prodPre_periodic` on `prodPreStep` over
  `Finset (ProdState Q φ)`) to `tpOf` remains unbuilt.

## Follow-ups

- `docs/theorem-index.md` rows for the two new declarations. Deliberately not touched: a
  concurrent sibling (task 856) declares that file in its own `file_scope`, and the plan's
  Non-Goals excluded it for this round.
- A future-locality lemma would be needed before any one-sided (eventual) weakening of the
  conditional form could even be stated; the tree has none, and none was attempted.
- The tight (doubling) chain remains the gap: its walk is not globally periodic, so neither new
  declaration reaches the depth-`0` cell obligation `CellLEZeroConstOfKappaEq`, whose reserved
  name `cellLE_zero_const_of_kappa_eq` is still claimed by nothing.
- `LadderAgree.lean` is 2887 lines against its in-file `set_option linter.style.longFile 2900`
  ceiling. A successor adding to this module must raise that ceiling in place or split it, and the
  module docstring already records why a split would put one argument across an import edge.
- The RaySummary README's `*Last verified:*` stamp is left at 2026-10-13; `readme-lint.sh` flags it
  as advisory-stale. This dispatch verified the two new entries and the generated block, not the
  whole record, so the stamp was not claimed.

## References

- `specs/852_model_level_pumping_lemma_for_tpof_along_ladder_path/plans/01_model-level-tpof-periodicity.md`
- `specs/852_model_level_pumping_lemma_for_tpof_along_ladder_path/handoffs/phase-1-handoff-20261105T080700Z.md`
- `specs/852_model_level_pumping_lemma_for_tpof_along_ladder_path/handoffs/phase-2-handoff-20261105T082000Z.md`
- `specs/852_model_level_pumping_lemma_for_tpof_along_ladder_path/handoffs/phase-3-handoff-20261105T083500Z.md`
- `specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean`
- `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean` — the refutation this
  one is NOT a restatement of
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
