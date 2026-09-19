# Research Report: Task #623 (findings carried over from the stability-completeness research)

- **Task**: 623 - Decidable `ValidZTime` via the quasimodel / ShiftSet witness-family route
- **Started**: 2026-09-19T00:30:00Z
- **Completed**: 2026-09-19T01:00:00Z
- **Effort**: 0.5 hours (transfer of existing findings; no new proofs)
- **Dependencies**: None
- **Sources/Inputs**:
  - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` §1.1-1.3
  - `specs/559_.../reports/04_semantics-first-task-frames.md` §4.2
  - `FormalSystem/Semantics/ShiftSet.lean` (module docstring: `ShiftSet.frame`, the functional task relation, Saturation discharged for free)
  - `FormalSystem/Semantics/Validity.lean` (`ValidZTime`)
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

This is an advisory note written from the main session, not a full research round. It does not
change this task's status. Its relevance to this task is LIMITED, and the summary says where.

## Executive Summary

- **One finding I expected to help does not.** Report 03 §1.2 argues (paper) that Saturation makes
  no difference to ZTime validity. For this task that is moot: `ShiftSet.frame` has a *functional*
  task relation, so every fibre and segment is a singleton or empty and `saturation` is discharged
  without any frame-theoretic work (`ShiftSet.lean` docstring). No obligation is removed.
- **Independent paper-level confirmation that the target is true.** Report 03 §1.3 argues that over
  integer time the validities of the *larger* language with the stability modal `⊡` are decidable,
  by translation into monadic second-order logic over the ω-branching tree. `ValidZTime` concerns
  the `⊡`-free fragment, so its decidability follows a fortiori IF the ZTime class is the integer
  time the report's mirror uses. The argument rests on Rabin's theorem, which is recalled and not in
  the held literature, and it yields no usable procedure. It is a sanity check, not a route.
- **It agrees with `fmp_false`.** Report 03 §1.3 records that the finite model property is NOT
  obtained by its method ("a regular tree does not obviously fold to a finite digraph"). That is
  consistent with the refuted small-model hypothesis this task replaces.
- **A scoping fact worth one docstring sentence.** The witness models of this route are
  deterministic (functional task relation), and `⊡` collapses to the identity on deterministic
  frames. So the procedure decides L-validity only, and cannot be extended to the language with
  `⊡` by adding a clause: that language needs nondeterministic witnesses.

## Context & Scope

Research on a complete proof system for `⊡` produced results about integer-time validity. This note
records the ones that touch this task and says plainly which do not.

## Findings

### 1. Saturation at ZTime: moot here

- Claim (report 03 §1.2, paper): every doubly serial digraph refuting a formula has a cover that is
  an oriented forest, which satisfies the literal Saturation, and truth is invariant along the
  covering map (`tw_invariance`, compiled in a probe).
- This task never builds a nondeterministic frame. `ShiftSet.frame` sets `TaskRel w d u := u = sh w d`.
  Nothing to use.

### 2. Decidability via MSO (paper; rests on a recalled theorem)

- Steps in report 03 §1.3: countable model property by closing under one witness walk per state
  and diamond-subformula; pass to the forest cover; root each tree; express "walk with a marked
  time" and the truth clauses in MSO; appeal to Rabin.
- What it does not give: a finite certificate, a complexity bound, or anything a Lean `Decidable`
  instance could be built from.
- Assumption to check before citing it anywhere: that `FrameClass.ZTime` is exactly `D = ℤ` as in
  the report's mirror (all bi-infinite walks of a digraph), not a wider class of discrete orders.

### 3. Why the route is confined to L

- Deterministic collapse is landed: on a deterministic frame the histories through a state at a
  time form a singleton, so `⊡φ ↔ φ` (`Semantics/PlusLanguage/PlusDeterminism.lean`,
  `states_eq_of_deterministic`).
- Report 04 §4.2 makes the same point about the four completeness engines: their states are
  ⟨index, time⟩ pairs, which forces *Determined*. The bi-lasso witness family of this task is the
  same device.
- A future decision procedure for L⁺ at ZTime would need witness families that branch at a shared
  state, and a truth lemma over all walks of the resulting digraph, which is the open problem of the
  completeness research.

## Decisions

- None taken on the task's behalf.

## Recommendations

1. No change to the task's plan or deliverables.
2. When correcting the `Assembly.lean` docstring and the BiLasso `README.md` (already in scope), add
   one sentence of scope in durable terms: the procedure decides validity for the language without
   the stability modal; its witness models are deterministic, on which that modal is trivial.
3. Do not cite the MSO argument in library documentation unless Rabin's theorem is first tied to a
   held source.

## Risks & Mitigations

- **Risk**: Findings 2 is read as a proof. **Mitigation**: it is labelled paper-level and rests on a
  recalled theorem; this task should not depend on it.

## Appendix

- Probe: `specs/559_.../probes/03_morphisms-clock-rule-lc-schema.lean` (`tw_invariance`,
  `lift_walk`).
