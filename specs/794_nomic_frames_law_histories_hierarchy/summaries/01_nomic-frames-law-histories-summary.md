# Implementation Summary: Task #794

- **Task**: 794 - Formalize the paper's nomic frames, law-histories, and the nomic hierarchy
- **Status**: [COMPLETED]
- **Started**: 2026-10-14T22:45:00-07:00
- **Completed**: 2026-10-15T00:05:00-07:00
- **Effort**: ~1.3 hours wall clock (two full `lake build` runs dominate it)
- **Dependencies**: None (task 795, the nomic operator and its logic, depends on this one)
- **Artifacts**: plans/01_nomic-frames-law-histories.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The frame-level half of the paper's nomic appendix now exists as a four-module cluster,
`FormalSystem/Semantics/Nomic/`. A nomic frame keeps one carrier and replaces the single task
relation by a relativized family `⇒ʷ`, one per world state; each member `F^w` is an ordinary task
frame, its possible worlds are the law-histories `H_F^w`, and `H_F` is their union. All seven
phases closed `[COMPLETED]`, including the conditional Phase 6, with zero `sorry`, zero new
axioms, and `scripts/check-module-invariants.sh` reporting `ALL CHECKS PASSED`.

## What Changed

- `FormalSystem/Semantics/Nomic/Frame.lean` — new. `def:nomic-frame` as `structure NomicFrame`
  with the derived family `NomicFrame.at` (declared dotted outside the namespace, since `at` is a
  reserved token, and left a plain `def` so synthesis can key on it), the regularity class
  `IsRegular` with the `instAtIsRegular` instance that feeds it back to `FrameOver.IsRegular`, the
  relativized `TaskRel`/`taskRel_eq`, `lawHist`/`HF` over bare functions with the `WorldHistory`
  bridge `mem_lawHist_iff`, `def:nomic-properties`' `Lawful`/`Static`/`Uniform`,
  `static_of_uniform`/`lawful_of_uniform`, and `lem:nomic-occurrence` as `occurrence`
- `FormalSystem/Semantics/Nomic/Recovery.lean` — new.
  `PartialHistory.exists_worldHistory_two_point` (the two-point partial history `{⟨0,p⟩,⟨d,q⟩}` as
  a general lemma over `TaskFrame`), `lem:nomic-recovery` as `lawHist_eq_iff_taskRel_eq` over the
  one-directional helper `taskRel_imp_of_lawHist_eq`, and `static_iff_taskRel_eq` — clause (1) of
  the cut `thm:nomic-primitive`
- `FormalSystem/Semantics/Nomic/ZTime.lean` — new. `def:nomic-witnesses` as `ofStepFamily`, with
  `ofStepFamily_at` holding by `rfl`, `ofStepFamily_isRegular`, the two `lawHist`-over-ℤ bridges
  `mem_lawHist_iff_isStepPath` and `mem_lawHist_ofStepFamily_iff`, `lawHist_mono_of_le`, and the
  two step-path invariants `stepPath_invariant` and `stepPath_forward_invariant`
- `FormalSystem/Semantics/Nomic/Witnesses.lean` — new. `prop:nomic-hierarchy`'s three finite
  ℤ-time witnesses in `namespace NomicHierarchy` — `F1` (*Static* not *Lawful*) on `{a,b,c}`, `F2`
  (*Lawful* not *Static*) on `{a,b,e}`, `F3` (*Static* and *Lawful* not *Uniform*) on `{a,b,c}` —
  each with its one-step family, its bi-seriality obligations and its named independence theorems,
  plus `FormalSystem.Semantics.nomic_hierarchy` bundling their joint content
- `FormalSystem/Semantics/Nomic.lean` — new: the sibling aggregator (C8)
- `FormalSystem/Semantics/Nomic/README.md` — new: modules, ported anchors, the siting decision
  with its recorded cost, the measured axiom table, and the two known gaps
- `FormalSystem/Semantics.lean` — one import line and one `## Submodules` bullet
- `FormalSystem/Semantics/README.md` — one `Nomic.lean` row and one `Nomic/` row
- `docs/reference/paper-definitions-of-record.md` — five new `KNOWN-ANCHORS` `LIVE-UNPINNED` rows
  (`def:nomic-frame`, `def:nomic-properties`, `def:nomic-witnesses`, `lem:nomic-recovery`,
  `prop:nomic-hierarchy`), one `DANGLING` row for the cut `thm:nomic-primitive`, and the existing
  `lem:nomic-occurrence` row's NOT FORMALIZED note updated in place
- `scripts/nolints.json` — one `unusedArguments` entry for `ofStepFamily`'s deliberately-kept
  `[Finite W]` binder
- `FormalSystem.lean`, `FormalSystem/README.md`, `README.md`, `typst/generated/status.typ` —
  regenerated

## Decisions

- **Siting**: `Semantics/Nomic/`, not `OpenLanguage/Nomic/`. A nomic frame mentions no object
  language, and `OpenLanguage/` imports `Semantics/` and never the reverse, so the operator can
  import these frames. The recorded cost — operator and frames not co-located, one extra import
  for the operator — is stated in the cluster README and in `Semantics.lean`'s bullet.
- **The two-point history is a general lemma over `TaskFrame`**, stated with `p q : F.WorldState`,
  because an inline construction at `F.at w` elaborates its `if`-terms at a different (if
  definitionally equal) carrier and all four `respects_task` branches then fail on `rw`. It is
  declared in `namespace PartialHistory` so promoting it into `Semantics/Extension/Extension.lean`
  later is a pure file move.
- **`rw` is avoided wherever a rewrite would cross the derived frame's carrier boundary.** The
  membership binder is `↑intOrder → F.World` while the witness paths are bare `ℤ → W3` functions;
  the two are defeq but not type-correct for a rewrite motive at `implicit` transparency. Routed
  through `refine Iff.trans … ?_`, `Set.ext_iff` and `congrArg` instead. This bit once (in
  `F3.not_uniform`) and was then applied pre-emptively in Phases 5 and 6.
- **Witness relations are written as `match`es with a shared catch-all branch**, so the paper's
  two law-history coincidences (`H_F^a = H_F^b` for witness 1, `H_F^b = H_F^c` for witness 3) hold
  by `rfl` rather than by proof, and `F1.lawHist_a_eq_b`/`F3.lawHist_b_eq_c` pin that shape.
- **Witness names are dotted** (`F1.static`, `R2.a_le_e`), inside `namespace NomicHierarchy`
  following `FrameConstraintIndependence.lean`'s house style. The underscore spellings the plan
  used (`F1_static`) are `Uppercase_x` names that gate C23 rejects.
- `ofStepFamily` keeps its pinned `[Finite W]` binder even though its body does not use it: the
  binder is what `ofStepFamily_isRegular` needs, and carrying it on the construction keeps every
  statement about a generated family at one binder set. Recorded in the docstring and in
  `scripts/nolints.json` rather than silenced in place.

## Plan Deviations

- **Phase 3, altered**: `Int.le_induction` (which the plan named for `stepPath_forward_invariant`)
  is deprecated on this Lean pin in favour of `Int.leInduction`; the proof uses the latter, with
  the same `base`/`succ` case names. The plan's other induction notes held: `Int.induction_on`
  does take `zero`/`succ`/`pred` here, and `omega` rather than `ring` closes the index identities.
- **Phase 4, altered**: witness 3's `R_b`/`R_c` is written as "either both ends are `a` or neither
  is" — the same five-pair relation as `{(a,a)} ∪ ({b,c} × {b,c})`, in the form that makes the
  two-sided invariance of `u = a` immediate. The witnesses also live in a dedicated namespace with
  dotted member names rather than at the bare `Semantics` level.
- **Phase 1, scope hypothesis corrected**: five record rows were added, not six —
  `lem:nomic-occurrence` already carried a `LIVE-UNPINNED` row from an earlier task's nomic
  forward pointer, so its note was updated in place rather than duplicated. A sixth row, for the
  cut `thm:nomic-primitive`, was added in Phase 7 when C15 reported the README citations
  resolving to nothing.
- Everything else followed the plan's sequence. No phase was skipped, deferred or blocked; no
  `sorry` was placed at any point.

## Verification

- Build: **Success**. `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build`
  (full project, unscoped, detached and guarded) — guard exit status 0, `Build completed
  successfully (2854 jobs)`, zero `error:` and zero `warning:` lines across both captured streams,
  and all five new modules' `.olean` files newer than their sources
- Sorry count: **0** (`.claude/scripts/lean-sorry-census.sh` over the resolved source roots)
- Vacuous count: **0 in this task's files**. The census reports one hit repository-wide,
  `FormalSystem/Examples/TemporalStructures.lean:495`, which is pre-existing and a genuine
  theorem (a total-domain history's `domain` predicate *is* `True`), not a placeholder
- Axiom count: **unchanged**. No `axiom` declaration anywhere under
  `FormalSystem/Semantics/Nomic/`; the 14 repository-wide `^axiom ` grep hits are all prose lines
  inside docstrings, as they were before this task
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED** (55 PASS, 0 FAIL), including
  C3, C8, C15, C16, C19, C23, C24, C33, C34a and C34b
- `bash scripts/readme-lint.sh FormalSystem` — exit 0, `RESULT: PASS`
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` — exit 0
- `bash scripts/typst-sync-check.sh` — exit 0 (no `--fix` needed on the final run)
- `bash .claude/scripts/verify-deploy.sh` — exit 0, `PASS -- 15 check(s), 0 failure(s)`
- `bash scripts/check-paper-definitions.sh` — advisory, as the plan specifies. Exit 1 on **ten
  inherited drifted anchors** (`CO`, `def:BX`, `def:BX-z`, `def:BX-d`, `def:TMplus`,
  `app:discrete`, `def:id`, `def:strongest`, `thm:exist`, `lem:uniq`), every one of them already
  red before this task began and none of them touched here. The six nomic anchors were checked
  individually with `--resolve`: all six resolve, and each `sha256` matches the value recorded
  during research exactly
- Measured axiom sets (`#print axioms`, not inferred): `nomic_hierarchy`, `occurrence`,
  `lawHist_eq_iff_taskRel_eq`, `static_iff_taskRel_eq` and every witness theorem at
  `[propext, Classical.choice, Quot.sound]`; `stepPath_invariant` at `[propext, Quot.sound]`;
  `mem_lawHist_iff`, `static_of_uniform` and `lawful_of_uniform` at `[propext]`
- Files verified: Yes

## Impacts

- Task 795 (the nomic operator `◈`, its truth clause and its logic) is unblocked: it can site the
  operator under `OpenLanguage/` and import `FormalSystem.Semantics.Nomic`. Its
  `prop:nomic-tense-free` port has the frame-level machinery its forward pointer in
  `Independence/StateSetTruth.lean` was written against.
- `PartialHistory.exists_worldHistory_two_point` is now available to any consumer needing a
  possible world through two prescribed points. `Semantics/DeterministicBridge.lean:146-165`
  carries the same construction inline and can be reduced to one call to it.
- `prop:nomic-hierarchy` is machine-checked at the generality the paper states it, so "the three
  nomic properties are strictly ordered" is a theorem of this tree rather than a claim in prose.

## Follow-ups

- Promote `PartialHistory.exists_worldHistory_two_point` into
  `Semantics/Extension/Extension.lean`, beside `PartialHistory.point`/`occurrence`, and rewrite
  `Semantics/DeterministicBridge.lean:146-165` as one call to it. Both were deliberately left out
  of this task's scope; the lemma is already declared in the right namespace, so the move is a
  pure file move.
- Clause (2) of the cut `thm:nomic-primitive` (the primitive-level form of *Lawful*) is not
  ported: its three-point partial history needs a well-definedness argument — coinciding times
  forcing coinciding states through `lem:nullity`, over a nested-`if` state function — with no
  precedent in this tree. Clauses (3) and (4) are recorded as consumerless in the cut note itself.
- For the paper's author, in a different repository and so out of scope here: the `% PORT:`
  markers under `lem:nomic-occurrence` and `lem:nomic-recovery` in `possible_worlds.tex` can now
  be cleared and their proofs closed with `\leanproof{\texttt{NomicFrame.occurrence}}` and
  `\leanproof{\texttt{NomicFrame.lawHist_eq_iff_taskRel_eq}}`; the declarations were named so that
  no rename is needed.
- `docs/theorem-index.md` rows for the new declarations were out of scope (the file was inside a
  concurrent task's declared `file_scope`) and remain to be added.

## References

- `specs/794_nomic_frames_law_histories_hierarchy/plans/01_nomic-frames-law-histories.md`
- `specs/794_nomic_frames_law_histories_hierarchy/reports/01_nomic-frames-law-histories-hierarchy.md`
- `specs/794_nomic_frames_law_histories_hierarchy/handoffs/` — one per phase, with the measured
  evidence for each
- `FormalSystem/Semantics/Nomic/README.md` — the cluster's own record of siting, anchors and
  choice dependence
