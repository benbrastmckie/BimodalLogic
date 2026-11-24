# Implementation Summary: Task #975

- **Task**: 975 - Theorem library: fragment conservativity (milestone M22, lane metatheory)
- **Status**: [COMPLETED]
- **Started**: 2026-11-24T00:40:00Z
- **Completed**: 2026-11-24T02:05:00Z
- **Effort**: 1.5 hours
- **Dependencies**: 971 (completed)
- **Artifacts**: plans/01_fragment-conservativity-edges.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Every conservativity edge of the fragment lattice is now proved, refuted or a registered
conjecture with a named obstruction, and the table of edges is rendered from kernel-checked
terms. The edges out of `Boolean` and out of the cell with `□` are proved at every frame class by
one parametric translation theorem; the edge out of `TemporalBoolean` at `Base` is refuted; the
temporal edges at `Dense`, `ZTime`, `RTime` and a repaired `Base` edge are open. All nine plan
phases are complete and all six Challenge statements are proved with their pinned signatures.

## What Changed

FormalSystem (new directory `FormalSystem/Metalogic/Conservativity/Fragments/`):

- `Fragments/Calculus.lean` — `Sublanguage`, the `Prop`-valued calculus `CellDerivable L fc Γ φ`,
  `mem`, `mono`, `toDerivationTree`, and `CellDerivable.deduction` by plain induction over a
  subset-generalized statement.
- `Fragments/PropComplete.lean` — `evalProp`, `Tautology`, `kalmar`, `eliminate`,
  `tautology_derivable`: propositional completeness inside any sublanguage.
- `Fragments/Translation.lean` — `conservative_of_translation`, the parametric theorem.
- `Fragments/Collapse.lean` — `BooleanFormula`, `ModalFormula`, `collapse`, `denseReading`, and
  the lemmas that make the collapse an instance.
- `Fragments/Edges.lean` — `boolean_conservative`, `modal_conservative`, each for arbitrary `fc`.
- `Fragments.lean` (umbrella), `Fragments/README.md`, import in `Conservativity.lean`; regenerated
  `FormalSystem.lean`, `typst/generated/status.typ`, inventory blocks.

BimodalLib:

- `Conservativity/TemporalBase.lean` — `not_conservativeEdge_temporal_base`: soundness of the
  temporal cell over every linear order without endpoints, and NF failing on `ℤ ⊕ₗ ℚ`.
- `Fragment.lean` — `Profile` order lemmas, profile of each constructor, `Profile.cellName`.
- `Conservativity.lean` — `proofProfile`, `within_iff_proofProfile_le`, `Decidable (within c d)`.
- `Conservativity/Proved.lean` — `derivableIn_iff_cellDerivable` and the five positive Challenge
  theorems: `conservativeEdge_boolean`, `derivableIn_boolean_of_box`,
  `derivableIn_boolean_of_temporal`, `conservativeEdge_box`, `derivableIn_box_of_derivableInP`.
- `Conservativity/Table.lean` — `EdgeVerdict`, `ConservativityEdge`, eleven rows.
- `Conjectures/Conservativity.lean` — four conjectures set to `derived`, one to `refuted`, the
  three temporal notes rewritten, new conjecture `temporalBooleanUniformIntoTMBase`.
- `ProofFragment.lean` — `record_proof_fragment`, `assert_proof_fragments_recorded`,
  `renderProofFragments`; the check runs in `Theorems/Complete.lean`; three reasons recorded in
  `Theorems/TemporalBoolean/Base.lean`.
- `Index.lean`, `INDEX.md` — sections "Conservativity edges" and "Proofs outside the statement
  cell".

Tests: `Tests/BimodalLibTest/EdgeTableTest.lean`, `ProofFragmentTest.lean`,
`Fixtures/UnrecordedProofFragment.lean`.

Docs and records: three rows in `docs/theorem-index.md` with the matching C14 pair in
`scripts/check-module-invariants.sh`; `docs/reference/bimodal-lib.md`; `BimodalLib/README.md`;
`BimodalLib/Conjectures/README.md`; `FormalSystem/Metalogic/Conservativity/README.md` and the
docstring of `Conservativity.lean`; `Tests/README.md`; `records/theorem-library.md` (implemented
table and three-step method cut, the open edges kept, the "theorem at every edge" claim
corrected); `records/proof-mode.md` (M22 reworded).

## Decisions

- **Translation, not soundness, bridge and completeness.** As planned. No completeness theorem
  for a fragment is used anywhere.
- **Kalmár with membership as the assignment.** The assignment for a context is membership in
  the context, so the Kalmár lemma needs no consistency hypothesis. The Phase 3 decision gate was
  not taken.
- **`denseReading fc` picks the reading.** The collapse uses `g ∧ e` for Until and Since at every
  class but `.ZTime`, where it uses `e`. The case split on the class is inside the axiom lemmas.
- **Proof profiles by evaluation.** `proofProfile` is evaluated on each registered derivation
  with `evalExpr`. Reduction by `whnf` was tried and hit the recursion limit on some rows.
- **Reasons state only what is checked.** The recorded reason for NP, its mirror and NA says the
  edge is refuted by NF and that lowering these three is not settled; only NF is machine-checked
  as underivable in the temporal cell.

## Plan Deviations

- **Phase 4, Translation.lean** altered: the theorem asks commutation with `imp` only;
  commutation with `bot` is unused.
- **Phase 4, Collapse.lean** altered: the sublanguages are the recursive predicates
  `BooleanFormula` and `ModalFormula`; `denseReading` selects the reading.
- **Phase 5, instantiation** altered: one instantiation per edge, no assembly by cases on `fc`.
- **Phase 7, rows** altered: eleven rows, with `Boolean` into the full base system as its own row.
- **Phase 7, repaired conjecture** altered: the hypothesis has a past conjunct, `Y⊤ → always Y⊤`.
- **Phase 8, reasons** altered: three rows are listed, all at `TemporalBoolean` over `Base`; no
  reason is needed at the other classes. The check also rejects a reason recorded for a proof
  that stays inside its cell, and `ConservativityEdge` has a `cell` field.
- **Phase 8, contingency** skipped: evaluation succeeded on all 190 rows.
- **Phase 9, files** altered: `BimodalLib/Conservativity/README.md` is added, which the README
  lint requires for a new directory with Lean files, and `Tests/BimodalLibTest/README.md` gains
  rows for the two new tests. Neither path is in the task's declared `file_scope`; see
  Follow-ups.

## Verification

- Build: Success. `lake build --wfail` (3017 jobs) and `lake build BimodalLib BimodalLibTest
  --wfail`, each through the build guard, at every phase end and at the close.
- Sorry count: 0
- Vacuous count: 0 introduced. The single-line pattern has 2 hits, both in files this task did
  not touch and neither a placeholder (`int_domain_universal := trivial` in
  `FormalSystem/Examples/TemporalStructures.lean`, a proof; `AnyPoint ... := True` in
  `FormalSystem/Semantics/PointTransport.lean`, a relation that is meant to be total)
- Axiom count: 14 lines match `^axiom ` across the source roots, the same 14 as at the pre-task
  commit; no `axiom` declaration and no `native_decide` added
- Plan compliance: passed (all six Goals identifiers declared)
- Axioms of the results: `conservative_of_translation` depends on `propext`; the two edge
  theorems and all six Challenge theorems on `propext, Classical.choice, Quot.sound`
- Tests: Passed (`BimodalLibTest`, including the two new test modules)
- Files verified: Yes
- Scoped gates, observed in this dispatch: `scripts/check-module-invariants.sh` passes C3, C5,
  C14, C15, C26, C33, B3 and INV; it fails C12 and C20, each naming only files this task did not
  touch (`docs/development/stability-operator-family.md`; files under
  `Metalogic/Expressiveness/Kamp/` and `Metalogic/WeakCanonical/`), so both are pre-existing.
  `scripts/library-index.sh --check`, `scripts/typst-sync-check.sh --counts-only`,
  `scripts/check-metalogic-cycles.sh`, `scripts/check-copyright-headers.sh --strict`,
  `.claude/scripts/check-task-references.sh`: pass.
- Full gate set: deferred to the batch stage per the dispatch's Batch Gate Deferral, not run
  independently here.

### Touched-path run: one failure, in a suite this task's files do not reach

`bash .claude/scripts/verify-touched.sh` (no arguments), the scoped tier the dispatch names for
Phase 9, exited 1: 84 suites passed, 10 were skipped, and 1 failed and is reported as NEW,
`.claude/scripts/tests/test-deploy-propagation.sh`. That suite deploys the agent system into a
scratch repository under `/tmp` with `deploy-headless.sh` and fails at its step 14, "runtime-file
tracking policy reported failures", inside the scratch tree. Run directly in this repository,
`.claude/scripts/check-runtime-file-tracking.sh` passes all three of its checks. The suite was
selected through the fallback set for unmapped touched paths; it reads no Lean, docs or records
file. The dispatch also reports the deployed `.claude/` tree stale for the `core` extension.
This result is recorded as red, not waived: Phase 9 is closed on its own declared criteria
above, and this failure is left for the batch-stage gate, which runs the complete set once.

Done-when, item by item: every edge is proved, refuted or a conjecture with a named obstruction
(section "Conservativity edges" of `BimodalLib/INDEX.md`, eleven rows); the table is generated
(`library-index.sh --check`); the proved edges are in `docs/theorem-index.md` with pinned axiom
sets (C14); no entry has a proof outside its statement cell without a reason (the build-time
check in `BimodalLib/Theorems/Complete.lean`; 3 of 190 rows listed, each with a reason).

## Impacts

- Filing at the smallest fragment is a theorem at `Boolean` and at `ModalBoolean`. At
  `TemporalBoolean` over `Base` it is refuted, and the docs and records now say so.
- `tautology_derivable` and `CellDerivable.deduction` are available for any later edge: a new
  translation needs only its axiom lemma.
- `lake build BimodalLib` now fails when a registered theorem's proof leaves its statement cell
  with no reason, so a new registration under `TemporalBoolean` derived through `□` needs a
  `record_proof_fragment` line.
- `within` is decidable, by `proofProfile`.

## Follow-ups

- **Proposed record: the always translation.** The temporal edges at `Dense`, `ZTime`, `RTime`
  and the repaired `Base` edge (`temporalBooleanUniformIntoTMBase`) are one piece of work: a
  translation reading `□` as `always`, which needs the S5 laws of `always`, `always φ → always
  Gφ` and replacement of provable equivalents derived inside the temporal cell. This task created
  no task for it.
- **Two README files outside the declared `file_scope` are edited and not committed**:
  `BimodalLib/Conservativity/README.md` (new) and `Tests/BimodalLibTest/README.md` (rows for the
  two new tests). The scoped commit drops them. Without the first, `scripts/readme-lint.sh`
  reports one missing README.
- NP and NA are not machine-checked as underivable in the temporal cell at `Base`; countermodels
  exist on paper (`ℚ ×ₗ ℕ` for NP, `ℚ ⊕ₗ ℤ` for NA) and would let their recorded reasons say so.
- `scripts/readme-lint.sh` reports four new stale dates on READMEs this task did not touch.

## References

- `specs/975_theorem_library_fragment_conservativity/plans/01_fragment-conservativity-edges.md`
- `specs/975_theorem_library_fragment_conservativity/reports/01_fragment-conservativity-edges.md`
- `specs/975_theorem_library_fragment_conservativity/scratch/axioms_fragments.lean`,
  `scratch/axioms_bimodallib.lean`, `scratch/measure_profiles.lean`
- `BimodalLib/INDEX.md`, `docs/reference/bimodal-lib.md`, `docs/theorem-index.md`
