# Research Report: Task #567 (findings carried over from the stability-completeness research)

- **Task**: 567 - Determinism clause and separatedness asymmetry
- **Started**: 2026-09-19T00:30:00Z
- **Completed**: 2026-09-19T01:00:00Z
- **Effort**: 0.5 hours (transfer of existing findings; no new proofs)
- **Dependencies**: None (task 563 remains this task's implementation dependency)
- **Sources/Inputs**:
  - `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/04_semantics-first-task-frames.md` §3.3
  - `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/04_semantics-native-general-duration.lean` Part S (`reparB`, `repar_invariance`)
  - `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean`, `StarDiscrimination.lean`, `DriftFrame.lean`
  - `FormalSystem/Semantics/StarLanguage/StarDeterminism.lean` (`deterministic_starDefinable`)
  - `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean`
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

This is an advisory note written from the main session, not a full research round. It does not
change this task's status. Every claim is tied to a file; anything not machine-checked is labelled.

## Executive Summary

- **The open question this task is told to pose appears to be already settled in the library.**
  The task description asks to record, as open, whether any `BL-star` formula characterizes
  separatedness of `Beh(F)`. `deterministic_starDefinable`
  (`Semantics/StarLanguage/StarDeterminism.lean`) proves that `F.Deterministic` holds iff the
  `StarFormula` schema `detPM` is valid on `F` at atoms, iff it is valid at every formula. If this
  task's Determinism clause identifies separatedness with `F.Deterministic`, the answer is **yes
  for L⋆**, and `deterministic_not_plusDefinable` (`DeterminismUndefinable.lean`) gives **no for
  L⁺**. The docstring should state the pair, not pose the question. CHECK FIRST that
  "separatedness" in the intended sense is the injectivity of restriction maps and not a weaker
  cover-relative condition.
- **The description's hint is stale.** It says `PlusDeterminism.lean`'s choice-dependence note
  "suggests it does not". That note is about which *direction* needs choice, not about
  definability, and the L⋆ definability theorem has landed since.
- **A general mechanism behind the drift-frame asymmetry is now compiled** (in a probe, not the
  library): `repar_invariance` says truth of every formula with `⊡` is unchanged when each history
  is re-timed by an order automorphism of `D`. L⁺ sees a history's order of states, never its
  durations.
- **Why that explains the theorem pair.** `F°` and `F¹` differ in determinism but their histories
  differ only by re-timing (see Findings 2, my observation, UNVERIFIED in Lean). Separatedness is a
  fact about durations-and-states; validity of *Determined* is a fact L⁺ can see. The gap between
  them is exactly what re-timing erases.
- **The mechanism does not extend to L⋆**, which is why `sent:det` discriminates `F°` from `F¹`
  (`StarDiscrimination.lean`): stored times make synchrony across histories expressible.

## Context & Scope

Four research rounds on a complete proof system for `⊡` produced side results about what the object
languages can express. Two of them bear on this task's theorem pair and on its posed question. This
note transfers them; it proves nothing new and proposes no change to the task's deliverables other
than the docstring wording.

## Findings

### 1. What `repar_invariance` says (compiled, probe only)

- `reparB R := {η | ∃ τ, Hist R τ ∧ ∃ f : D ≃o D, η = τ ∘ f}`: all order-automorphic re-timings of
  histories of `R`.
- `repar_invariance`: for every formula `φ` of the language with `⊡`, every `τ`, `f : D ≃o D`, `t`:
  truth of `φ` at `(τ ∘ f, t)` in the *bundle* model on `reparB R` equals truth of `φ` at
  `(τ, f t)` in the all-histories model of `R`.
- Setting: a mirror of `PlusTruthAt` over an arbitrary ordered abelian group, no frame axiom
  assumed. It is NOT stated against the live `PlusTruthAt`, and the left-hand model is a bundle,
  not the all-histories model of a task frame.

### 2. Relation to the drift frame (observation, UNVERIFIED in Lean)

- `F°` has `u - w ∈ [d, 2d]` for `d ≥ 0` (`fzeroRel`, `DriftFrame.lean`); `F¹` has `u = w + d`.
- A history of `F°` is strictly increasing with increments bounded below by the elapsed duration, so
  it is continuous, unbounded both ways, and hence an order automorphism `f` of `ℝ`. It is therefore
  the `F¹` history `t ↦ t` re-timed by `f`. So `H_{F°} ⊆ reparB(F¹)`, properly (slopes are bounded).
- Report 04 §3.3 says the drift frame's histories "are not all re-timings of translations" and
  labels the implication from `repar_invariance` to `cor:no-characterization` UNVERIFIED. The first
  half of that sentence looks wrong by the argument above; the label is still right, for a
  different reason: `repar_invariance` compares the full model with the bundle of ALL re-timings,
  and `H_{F°}` is a proper sub-bundle. An invariance statement for sub-bundles of re-timings that
  contain every history's translates would be needed.
- The landed proof of `fzero_plusValidOn_iff_f1` goes through the state-set bridge
  (`Independence/StateSetTruth.lean`) and does not need any of this. The observation is an
  explanation, not a missing lemma.

### 3. What this means for the theorem pair

- Direction proved in this task: deterministic ⇒ separated / injective restrictions, connected to
  `states_eq_of_deterministic`. Unaffected.
- Converse refuted by `F°`: unaffected, and the refutation is the library's own
  (`fzero_determined`, `fzero_not_deterministic`).
- Suggested docstring sentence, in durable terms: *validity of Determined is invariant under
  re-timing histories, separatedness is not; the drift frame is the translation flow re-timed.*
  Cite `DeterminismUndefinable.lean`; do not cite the probe from library code.

### 4. The posed question

- L⁺: no set of `PlusFormula`s defines the deterministic frames (`deterministic_not_plusDefinable`).
- L⋆: `detPM` at atoms defines them (`deterministic_starDefinable`, a theorem of ZFC through its
  (⇒) direction, per its docstring).
- So, conditional on separatedness ≡ `F.Deterministic`: characterized in L⋆, not in L⁺.

## Decisions

- None taken on the task's behalf. The planner should decide whether the "open question" paragraph
  of the description is replaced by the settled pair.

## Recommendations

1. Before planning, confirm in `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md`
   §5.2.1 which sense of separatedness is meant. If it is injectivity of restriction maps, replace
   the posed question by the two landed theorems.
2. Keep the theorem-pair deliverable exactly as described.
3. Do not port `repar_invariance` inside this task; whether it belongs in the library is a question
   for the task on what the object languages can see of a task frame (624).

## Risks & Mitigations

- **Risk**: Findings 2 is an unchecked real-analysis argument. **Mitigation**: it is labelled, and
  nothing in this task depends on it.
- **Risk**: "separatedness" is cover-relative in the source study, in which case Findings 4 does not
  answer the question. **Mitigation**: Recommendation 1.

## Appendix

- Probe theorem locations: `04_semantics-native-general-duration.lean`, section `Repar` (Part S).
- Library theorem names quoted above were read from the files on 2026-09-18; re-grep before citing.
