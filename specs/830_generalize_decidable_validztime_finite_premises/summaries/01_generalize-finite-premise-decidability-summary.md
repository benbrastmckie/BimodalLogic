# Implementation Summary: Task #830

- **Task**: 830 - Generalize `Compression.decidableValidZTime` from the empty-premise case to arbitrary finite premises
- **Status**: [COMPLETED]
- **Started**: 2026-11-12T12:39:00Z
- **Completed**: 2026-11-12T13:20:00Z
- **Effort**: ~0.7 hours
- **Dependencies**: None
- **Artifacts**: plans/01_generalize-finite-premise-decidability.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The witness-family decision procedure now decides `SemanticConsequenceIn FrameClass.ZTime Γ σ` at
arbitrary finite `Γ`, where it previously covered `Γ = []` only. All three enumerated residue
items were landed sorry-free, by both the direct and the reduction route, with every pinned
`φ`-indexed declaration kept at its current name and statement. The README caveat that the
general form "is not known to compile" is discharged, and the recorded claim that the tree lacks
a context-conjunction deduction theorem is corrected at every live site.

## What Changed

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Enumerate.lean` — residue item 3.
  Added `closureList`/`mem_closureList` (the computable enumeration universe, which is what
  removes the need for a noncomputable `Finset.toList`) and thirteen context-indexed declarations
  `closureSubsetsOfCtx`, `closureSubsetsOfCtx_sub`, `mem_closureSubsetsOfCtx`,
  `rawLabelledLassosCtx`, `mem_rawLabelledLassosCtx`, `length_of_mem_rawLabelledLassosCtx`,
  `IsLabelledLassoCtx`, `instDecIsLabelledLassoCtx`, `boundedLassosCtx`, `mem_boundedLassosCtx`,
  `boundedLassosCtx_sound`, `candsCtx`, `mem_candsCtx_of_bounded`. The thirteen `φ`-indexed names
  are re-expressed as thin wrappers, signatures verified byte-identical.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` — residue items 1
  and 2. Added `ConsequenceInt`, `consequenceZTime_iff_consequenceInt` and
  `exists_witnessFamily_of_not_consequence`; `exists_witnessFamily_of_not_validZTime` is now
  derived from the general form at `Γ = []` through `semanticConsequenceIn_nil_iff`, its statement
  unchanged.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` — added
  `consequence_iff_noCertifiedCandidate` (the criterion) and `decidableSemanticConsequenceZTime`
  (the procedure, direct route); `decidableSemanticConsequenceNil` re-expressed as its `Γ = []`
  specialization; the "Scope: no premises" header section rewritten.
- `FormalSystem/Metalogic/ZTimeProvability.lean` — added the `StrongCompleteness` import and
  `decidableSemanticConsequenceZTimeReduction`, the same result by the reduction route.
- `FormalSystem/.../Compression/README.md`, `FormalSystem/.../WitnessFamily/README.md`,
  `docs/theorem-index.md`, `README.md`, `FormalSystem/Metalogic/README.md` — documentation
  reconciliation, five new theorem-index rows, regenerated inventory blocks.
- `typst/generated/status.typ`, `scripts/lean-citation-manifest.json` — regenerated.

## Decisions

- **The direct route is the primary deliverable; the reduction route lands beside it.** Only the
  direct route yields candidates in the exported `WitnessFamily Γ [σ]` shape with `Γ` and `Δ`
  named separately. The reduction route's candidates are
  `WitnessFamily [] [Γ.foldr Formula.imp σ]`, which fold the premises into the conclusion formula
  and carry no separate record of which formulas were premises. They are companions, not
  substitutes.
- **The recorded deduction-theorem claim was false as a conclusion and is corrected, not worked
  around.** It is true that the tree has no `Context.conj` or `bigConj`. It does not follow that
  the tree lacks a context-conjunction deduction theorem: `StrongCompleteness.lean:262`'s
  `semantic_deduction_in` supplies the iterated-implication form. Both live sites
  (`Compression/README.md`, `Assembly.lean`) now say so.
- **The probe's `C` suffix was renamed to `Ctx` on arrival**, because `Compression/Cycle.lean`
  already uses a `C` suffix with an unrelated meaning (`cycleBoundC`).
- **`decidableSemanticConsequenceZTimeReduction`, not `..._reduction`.** The research report's
  name carries a non-trailing underscore in a `def`, which fails `check-module-invariants.sh` C26.
  C26 passes under the chosen name.
- **The `φ`-indexed names survive as wrappers rather than being deleted**, so the C14-pinned name
  set does not churn and no C14 row needed editing.

## Plan Deviations

- **Phase 5, `check-metalogic-cycles.sh` task** altered: the script was run (exit 0) but not
  edited. The task was conditional — extend the Assertion B allowlist *if* the new
  `StrongCompleteness` import produces a surplus upward edge. It did not; the recorded 10-line
  upward set is still exact. The conditional branch correctly did not fire.

Otherwise the implementation followed the plan.

## Verification

- Build: Success. Full `lake build` green at every phase end and at final verification — guard
  exit 0, "Build completed successfully (2975 jobs)", 0 `error:` occurrences and 0 warnings
  across both captured streams. Warnings are treated as failures because CI runs `--wfail`; two
  over-length-line warnings introduced by Phase 6 docstring edits were fixed and the build re-run
  to green.
- Sorry count: 0 (`grep -rn sorry` over `Compression/` and `ZTimeProvability.lean`: no match).
- Vacuous count: 0.
- Axiom count: unchanged, no new axioms. All five new headline declarations measure at exactly
  `[propext, Classical.choice, Quot.sound]`:
  `consequenceZTime_iff_consequenceInt`, `exists_witnessFamily_of_not_consequence`,
  `consequence_iff_noCertifiedCandidate`, `decidableSemanticConsequenceZTime`,
  `decidableSemanticConsequenceZTimeReduction`. The pinned
  `exists_witnessFamily_of_not_validZTime`, `validZTime_iff_noCertifiedCandidate`,
  `Compression.decidableValidZTime`, `decidableSemanticConsequenceNil` and
  `decidableDerivableZTime` measure the same after being re-expressed.
- `scripts/check-module-invariants.sh`: exit 0, ALL CHECKS PASSED — **no delta** against the
  pre-task baseline captured in Phase 1, which was itself ALL CHECKS PASSED. C26 passes.
- `scripts/check-module-invariants.sh --emit-inventory --check`: exit 0.
- `scripts/typst-sync-check.sh`: exit 0 on the full bare invocation (all 4 checks green).
- `scripts/check-metalogic-cycles.sh`: exit 0.
- `scripts/check-task-references.sh`: exit 0, 0 unexempted occurrences.
- No `noncomputable` modifier on any `Enumerate.lean` declaration or on
  `decidableSemanticConsequenceZTime`; the only `noncomputable` tokens in those files are
  docstring prose.
- Tests: N/A — no test suite covers these modules; the acceptance criteria are build, axioms and
  the invariant gates above.
- Files verified: Yes.

### Scoped gate discharge (batch deferral)

This dispatch ran under the batch-gate deferral: the final phase's `full` tier was discharged
against a scoped gate set, with the complete set deferred to the batch stage. The plan's Phase 6
named `verify-deploy.sh`, which compares the deployed `.claude/` tree against the source store
(`agent-system/extensions/`). This task touched neither — every modified file is under
`FormalSystem/`, `docs/`, `scripts/`, `typst/generated/`, `README.md` or `specs/` — so no
`--only-gate` selection reaches this phase's touched files and the criterion is unmappable in the
dispatch's sense. Per the unmappable-criterion clause it was not waived: the checks that do reach
these files were run directly instead, and are the `check-module-invariants.sh`,
`check-metalogic-cycles.sh`, `typst-sync-check.sh` and `check-task-references.sh` results above.

`scripts/check-record-versioning.sh` reports 6 BLOCKING occurrences repo-wide. All six are in
`Boneyard/` and `FormalSystem/Metalogic/Expressiveness/Kamp/`; none names a file this task
touched. Standing tree baseline, not a regression from this task.

## Impacts

- `Decidable (SemanticConsequenceIn FrameClass.ZTime Γ σ)` is now available at arbitrary finite
  `Γ`, by two independent routes, where only the `Γ = []` case was decidable before.
- `candsCtx Γ Del` and `exists_witnessFamily_of_not_consequence`'s inputs are stated at arbitrary
  `Γ Del`, so a future multi-conclusion result needs no further generalization of the enumeration.
- The out-of-scope list in `Compression/README.md` now contains only two genuine items (a usable
  executable, and the stability modal), where it previously carried the finite-premise residue as
  a third.

## Follow-ups

- No usable executable, and none is filed: `candsCtx Γ [σ]` is astronomically large and
  [GKWZ] §6.5's EXPSPACE-hardness lower bound for `PTL × S5` makes the cost the literature's own.
- This strengthens the **base-language** result and does **not** advance the L⁺ aim
  (`Decidable (PlusValidZTime φ)`, ROADMAP Stage 1). `ValidZTime` is stated for
  `FormalSystem.Syntax.Formula`, which carries no stability operator.
- A multi-conclusion (`Del` with more than one formula) headline result was deliberately not
  added; `SemanticConsequenceIn` is single-conclusion.

## References

- `specs/830_generalize_decidable_validztime_finite_premises/plans/01_generalize-finite-premise-decidability.md`
- `specs/830_generalize_decidable_validztime_finite_premises/reports/01_generalize-finite-premise-decidability.md`
- `specs/830_generalize_decidable_validztime_finite_premises/reports/01_verified-general-form.lean`
- `specs/830_generalize_decidable_validztime_finite_premises/handoffs/` (per-phase handoffs 1-6)
