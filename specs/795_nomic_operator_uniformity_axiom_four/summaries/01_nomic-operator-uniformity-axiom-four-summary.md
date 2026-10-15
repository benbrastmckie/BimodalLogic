# Implementation Summary: Task #795

- **Task**: 795 - Formalize the nomic operator and its three results, on the nomic frames of task 794
- **Status**: [COMPLETED]
- **Started**: 2026-10-15T15:00:00Z
- **Completed**: 2026-10-15T17:30:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: Task 794 (completed) — `FormalSystem/Semantics/Nomic/` supplies the frames, law-histories, occurrence, recovery, the ℤ-time presentation and the three hierarchy witnesses
- **Artifacts**: plans/01_nomic-operator-uniformity-axiom-four.md, reports/01_nomic-operator-uniformity-axiom-four.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The language half of the paper's nomic appendix is formalized, in the two-directory split the
plan specifies: `FormalSystem/Semantics/Nomic/Uniformity.lean` for `thm:nomic-uniform`'s six
language-free frame conditions, and a new semantic-only top-level component
`FormalSystem/NomicLanguage/` for the operator itself — the formula type, the truth recursion with
`def:nomic-frame`'s Nomic clause, `prop:nomic-tense-free`'s state-set bridge with its five **S5**
schemata, validity with seriality, and `app:nomic-four` over ℤ-time. All seven phases landed; the
39 declarations pinned under the plan's `## Lean Challenge Statements` exist at their pinned
signatures, with zero `sorry` and zero new axioms.

## What Changed

- `FormalSystem/Semantics/Nomic/Uniformity.lean` — **new** (377 lines). `accRel`
  (`def:nomic-frame`'s accessibility relation); the three small facts the 794 cluster lacked
  (`lawHist_subset_HF`, `exists_mem_HF_eq`, `lawHist_nonempty`); conditions (1)-(4) as
  `TransAt`/`SymmAt`/`EuclAt`/`PointUniform`; the cycle `uniform_of_transAt`/`_symmAt`/`_euclAt`,
  `pointUniform_of_uniform`, and the three choice-free `_of_pointUniform` directions; the (5)⇔(6)
  step `uniform_iff_taskRel_indep` through `lem:nomic-recovery`; the `H_F × H_F` identification
  `accRel_eq_of_uniform` with `accRel_equivalence_of_uniform`; the bundled `nomic_uniform`; and the
  cut `rmk:nomic-uniform`'s per-state transitivity `TransAtState` with `transAtState_iff` and
  `uniform_iff_forall_transAtState`
- `FormalSystem/NomicLanguage/Formula.lean` — **new**. `NomicFormula` (BL's six constructors plus
  `nomic`), twelve derived operators with `Formula`'s right-hand sides, and `ofFormula` with
  `ofFormula_injective` and eleven `rfl` commutation pins
- `FormalSystem/NomicLanguage/NomicTruth.lean` — **new**. `NomicModel`, the seven-clause
  `NomicTruthAt` carrying `def:nomic-frame`'s Nomic clause, seven primitive and nine derived clause
  lemmas (including the collapsed `always_iff` and `next_iff_succ`/`next_iff_add_one`), and the
  uniformity collapse `nomic_iff_box_of_uniform`
- `FormalSystem/NomicLanguage/NomicTenseFree.lean` — **new**. `TenseFree`, the total state-set
  recursion `nomicSatSet`, the bridge `tenseFree_satSet_iff`, the collapse
  `nomic_iff_box_tenseFree`, and `nomic_k_tenseFree`, `nomic_t_tenseFree`, `nomic_four_tenseFree`,
  `nomic_five_tenseFree`, `nomic_b_tenseFree`
- `FormalSystem/NomicLanguage/NomicValidity.lean` — **new**. `NomicFrame.NomicValidOn`,
  `nomic_serial`, and `nomicValidOn_nomic_iff_box_of_uniform`
- `FormalSystem/NomicLanguage/NomicFour.lean` — **new**. The shared countermodel
  `exists_refutation_of_not_uniform`, `four_validOn_iff_uniform`,
  `nomic_iff_box_validOn_iff_uniform` on the same witness sentence, and `not_four_nomicValid` at
  `NomicHierarchy.F3`
- `FormalSystem/NomicLanguage.lean`, `FormalSystem/NomicLanguage/README.md` — **new** sibling
  aggregator (C8) and component README with the five exclusions recorded with their reasons
- `scripts/measure-refactor-partitions.py` — the `"NomicLanguage"` `LANGUAGE_FILE_LAYERS` entry
  (`Formula` 0, the four semantic modules 1)
- `docs/reference/paper-definitions-of-record.md` — `thm:nomic-uniform` and `app:nomic-four` added
  as `LIVE-UNPINNED`, `rmk:nomic-uniform` added as `DANGLING`, and the `def:nomic-frame`,
  `prop:nomic-tense-free` and `sub:RestrictedModalities` notes repointed
- Four prose repoints, so the tree no longer asserts the operator is unformalized:
  `FormalSystem/OpenLanguage/README.md`, `FormalSystem/StarLanguage/README.md`,
  `FormalSystem/Metalogic/Independence/StateSetTruth.lean`'s `## References` forward pointer, and
  the record file's `sub:RestrictedModalities` note; plus a `NomicLanguage/` row in
  `FormalSystem/README.md`
- `FormalSystem.lean`, `FormalSystem/Semantics/Nomic.lean`, `FormalSystem/Semantics/Nomic/README.md`
  — regenerated root, aggregator import, module row

## Decisions

- **The frame conditions are stated at a single time, with all three worlds restricted to `H_F`** —
  the existential reading of the paper's `x`-quantifier, which is the stronger hypothesis to
  discharge. The universal reading comes back from `transAt_of_pointUniform` and its two siblings,
  which is exactly what licenses the paper's "either way" remark
- **Condition (4) quantifies only over occupied states**, so (5)⇒(4) is immediate and
  (4)⇒(1)(2)(3) never needs `occurrence` — the measured reason those three directions are
  choice-free at `[propext]`
- **The truth recursion ranges over bare state functions**, inheriting 794's presentation of
  `lawHist`, so nothing threads a membership proof and nothing transports. Validity, not truth, is
  where `τ ∈ H_F` enters
- **The derived-operator clause layer is duplicated rather than instantiated**, because every class
  in `Semantics/TruthClauses.lean` binds `TaskFrame`/`TaskModel F`/`WorldHistory F` and `H_F` is
  the world-history set of no task frame on a non-uniform frame. Recorded with its cause in
  `NomicTruth.lean`'s docstring
- **`nomicSatSet` is total with `∅` at the two temporal clauses**, since a `Prop`-valued
  `TenseFree` has no large elimination; the bridge carries `TenseFree φ` and discharges those cases
  by `cases h`. Both the box and nomic clauses use `lem:state-set`'s ignoring-set form, which is
  what makes the two state sets equal by `rfl`
- **The bridge is stated for an arbitrary bare `τ`**, strictly stronger than the paper's `τ ∈ H_F`
  statement and free in the proof; recorded in the docstring rather than silently taken
- **The five S5 schemata are proved by reading the bridge at the relevant compound** rather than
  through `nomic_iff_box_tenseFree` plus a box lemma: the box clause alone cannot deliver **T** at
  a bare `τ`, since `τ ∈ H_F` is not available at the truth level. T on the fragment therefore
  holds over *every* nomic frame, including the non-*Lawful* ones — recorded as the module's one
  genuine surprise, and a consistency check against `prop:nomic-hierarchy`'s first witness

## Plan Deviations

- None (implementation followed plan). Phase 7's verification list names
  `bash .claude/scripts/verify-deploy.sh`; this dispatch's own Batch Gate Deferral directive
  supersedes that one line for this run, deferring the complete gate set to the batch stage. That
  is the dispatch's instruction rather than a departure from the plan, and it is recorded under
  `## Verification` above.

## Verification

- Build: Success — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (full project, unscoped, detached, exit status captured un-piped) exits 0
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots)
- Vacuous count: 0 in this task's files (one repository-wide hit,
  `FormalSystem/Examples/TemporalStructures.lean:495`, is pre-existing at HEAD and untouched here)
- Axiom count: 14, unchanged from HEAD; every hit is prose inside a docstring, not an `axiom`
  declaration
- Tests: N/A (no test-suite changes; the new component is covered by the library build)
- Files verified: Yes
- Measured axiom sets: `transAt_of_pointUniform` and `nomic_iff_box_of_uniform` at `[propext]` —
  the two genuinely choice-free results, as their docstrings claim; `uniform_of_transAt`,
  `tenseFree_satSet_iff`, `nomic_serial` and `not_four_nomicValid` at
  `[propext, Classical.choice, Quot.sound]`, as their `rmk:choice` notes claim
- Gates run, all green: `check-module-invariants.sh --no-build` ends `ALL CHECKS PASSED` (the
  C1 build is verified separately above, so skipping its replay loses no evidence) — C8, C12, C13,
  C14, C15, C16 `docBlame` and the `env_linter` batch, C19, C23, C24, C26, C28 zero warning budget,
  C33 byte-current generated root, C34/C34a/C34b, C35, INV; `readme-lint.sh FormalSystem` exit 0;
  `check-copyright-headers.sh --strict FormalSystem` exit 0 (700 conforming, 0 nonconforming);
  `python3 scripts/measure-refactor-partitions.py` exit 0, no `UnlayeredModuleError`, and neither
  new semantic module joins the namespace-audit bucket; `typst-sync-check.sh` PASS after `--fix`
  re-stamped `status.typ` (693 -> 700 files)
- **One gate collision found in this task's own files and fixed**: C34 failed on two docstring
  sentences reading "it carries no `Constraints consumed:` line" — written precisely to document
  the *absence* of a marker on the two choice-free declarations. C34's extractor,
  `re.compile(r"Constraints consumed:\s*([^\n]*)")`, matched the literal token inside that prose
  and parsed "line." as a constraint outside its closed vocabulary. C34a and C34b passed in the
  same run, which is what showed the substantive claims were sound. Reworded to
  "carries no constraints-consumed marker" (no colon, so outside the regex) in `NomicTruth.lean`,
  `Uniformity.lean` and the component README; C34 then passes
- **Deferred to the batch stage, not forgiven**, per this dispatch's Batch Gate Deferral directive:
  `.claude/scripts/verify-deploy.sh`, which checks the deployed `.claude/` tree against its source
  store. It has zero overlap with this task's file set — nothing under `.claude/**` or
  `agent-system/**` was touched — and this dispatch's own deploy-freshness context already reported
  the `core` extension stale before any of this work began
- **One pre-existing gate failure, reported and not repaired**: `check-metalogic-cycles.sh`
  assertion B fails on one SURPLUS upward edge,
  `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.LinearityDerived`. The import
  was added by commit `ba6c0f5dd` without extending that script's 7-line allowlist; it was masked
  until now because assertion B aborted early on the unlayered new directory. Outside this task's
  file set, so reported per the plan's Phase 7 instruction. Assertions A and C pass, including the
  syntax-before-semantics invariant for the new component

## Impacts

- The tree now has a sixth object language and a sixth semantic-only language component. Every
  mechanical obligation a new top-level component carries is discharged: sibling aggregator,
  directory README with a generated inventory, `LANGUAGE_FILE_LAYERS` rows, regenerated library
  root
- Four prose sites that recorded the nomic operator as a deliberate exclusion now point at the
  formalization, and `StateSetTruth.lean`'s forward pointer — written for exactly this port — names
  the induction that answers it
- `prop:nomic-tense-free` and `thm:nomic-uniform` are machine-checked, so the paper's three
  `% PORT:` markers under them and `app:nomic-four` can be cleared and their proofs closed with
  `\leanproof{}` citations against the declaration names fixed here
- The choice record is honest per declaration: the two `[propext]` results are pinned as
  choice-free and everything reaching `lem:nomic-occurrence` is stated as a theorem of ZFC

## Follow-ups

- **`check-metalogic-cycles.sh`'s allowlist** needs `LinearityDerived` added (one entry) by whoever
  owns the `AxiomDischarge` import. Not this task's to repair
- **The paper (a different repository, read-only here)**: clear the `% PORT:` markers under
  `prop:nomic-tense-free`, `thm:nomic-uniform` and `app:nomic-four`, and close their proofs with
  `\leanproof{\texttt{…}}` against the names fixed here
- **The dense-time case of `app:nomic-four`** is open in the paper's own commented remark and was
  not attempted; `NomicFour.lean`'s docstring records the ℤ-time hypothesis as load-bearing
- **`docs/theorem-index.md` rows** for the new declarations were a declared Non-Goal (the file is
  inside a sibling task's `file_scope`); C15's second assertion checks only existing rows, so the
  omission is gate-clean
- The two context-extension recommendations the research report makes — a note on
  `TruthClauses.lean`'s frame binding, and one on `warning-budget.txt`'s zero baseline and its
  missing-row-is-exit-2 rule — remain unwritten

## References

- `specs/795_nomic_operator_uniformity_axiom_four/plans/01_nomic-operator-uniformity-axiom-four.md`
- `specs/795_nomic_operator_uniformity_axiom_four/reports/01_nomic-operator-uniformity-axiom-four.md`
- `specs/795_nomic_operator_uniformity_axiom_four/handoffs/phase-{2..7}-handoff-20261015.md`
- `FormalSystem/NomicLanguage/README.md` — the component's contract and its five recorded exclusions
- `FormalSystem/Semantics/Nomic/README.md` — the frame-level cluster this builds on
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — `def:nomic-frame`,
  `prop:nomic-tense-free`, `thm:nomic-uniform`, `app:nomic-four`
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` — the cut
  `rmk:nomic-uniform`, "Transitivity of nomic accessibility"
