# Research Report: temporal_swap_strategy_for_truth_lean_supports_tasks_129_130 (Re-evaluation)

**Project**: #154  
**Date**: 2025-12-23  
**Research Type**: comprehensive

## Research Question

Re-evaluate whether the global time-reversal lemma `is_valid φ ↔ is_valid φ.swap_past_future` is derivable without strengthening frame/domain assumptions. If not, identify the precise blocking assumptions and the minimal additional axioms needed. Provide next steps for Tasks 129 & 130 under both branches (derivable vs. not derivable).

## Sources Consulted

- Prior report: `specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/reports/research-001.md`
- Internal code: `Logos/Core/Semantics/Truth.lean` (definitions of `truth_at`, `is_valid`, time-shift lemmas)
- Frame/domain structure: `WorldHistory` (domain restrictions), `TimeShift.time_shift_preserves_truth`

## Key Findings

1) **Current assumptions do NOT suffice (global swap not derivable)**
- The model class is **not closed under time reversal**: domains of histories are arbitrary subsets of `T`; no guarantee that `t` implies `-t` (or `t ± Δ`) is also in domain. Past/Future quantifiers range only over existing domain points, so swapping directions can lose or gain witnesses asymmetrically.
- **Imp/past/future cases break structural validity induction**: `truth_at` for `Past φ` quantifies over `s < t` with `τ.domain s`; after swap this becomes `Future φ`, needing `t < s`. Without bi-infinite domains, one direction can be vacuous while the other is not, so `is_valid (Past φ)` need not imply `is_valid (Future φ)` or vice versa.
- The logic’s frame class is **not proved closed under time-reversal transforms** (τ ↦ time-reverse τ, M ↦ time-reverse M), so we cannot transport validity across reversed models.

2) **Minimal additional axioms to make the global lemma provable (sketch)**
- **Bi-infinite domain closure**: for every history τ and time t in domain, all shifts `t + Δ` are in domain (in particular, both directions). A weaker variant suffices: closure under negation and translation, i.e., `τ.domain t ↔ τ.domain (t + Δ)` for all Δ.
- **History reversal availability**: ability to form `reverse τ` with domain `{t | τ.domain (-t)}` and states `reverse τ .states t := τ.states (-t)`; similarly `reverse M` reuses the same valuation on reversed histories. This requires the above domain closure to ensure `reverse τ` is a well-formed history.
- **Time-reversal adequacy lemma** (proof obligation): for all φ, `truth_at (reverse M) (reverse τ) t ht (φ.swap_past_future)` ↔ `truth_at M τ (-t) h(-t) φ`. This can be proved by structural induction once domain closure gives the needed witnesses in the past/future cases.
- With these, obtain `is_valid φ → is_valid φ.swap_past_future` (and the converse) by instantiating at reversed models/histories.

3) **If we stay with current assumptions (recommended)**
- Global swap remains unprovable; the blocking assumptions are precisely lack of domain symmetry/closure and absence of a time-reversal model construction. The safer path is still to refactor the derivation-indexed proof (`derivable_implies_swap_valid`) to avoid `valid_swap_of_valid`.

## Recommendations / Next Steps

**Branch A (accept stronger axioms to prove the global lemma)**
- Add frame/domain axioms: bi-infinite, translation-closed domains for all histories; define `reverse` history/model constructors.
- Prove the time-reversal adequacy lemma (above), then the global validity equivalence.
- Re-run `TruthTest`/`SoundnessTest`; document the semantics change (narrower model class). Evaluate impact on Tasks 129/130: they can then rely on the global lemma, but this is a semantics-level shift.

**Branch B (no new axioms; current model class) — Recommended**
- Proceed with refactoring `derivable_implies_swap_valid` to use the induction hypothesis directly in the `temporal_duality` case (or a mutual IH producing both `is_valid φ` and `is_valid φ.swap`). Remove the dependency on `valid_swap_of_valid`/`truth_swap_of_valid_at_triple` sorries.
- If any transport lemmas are needed, keep them local and domain-witnessed, reusing `TimeShift.time_shift_preserves_truth` (no global reversal claims).

## Task-Specific Guidance

- **Task 129 (temporal swap lemmas)**
  - *Branch A*: After adding reversal axioms, implement the time-reversal adequacy lemma and derive `is_valid φ ↔ is_valid φ.swap_past_future`; wire it to close `derivable_implies_swap_valid` via the global lemma.
  - *Branch B*: Refactor the derivation induction to eliminate the global lemma; optionally introduce mutual IH to yield both swapped and unswapped validity.

- **Task 130 (domain extension lemmas)**
  - *Branch A*: Encode the bi-infinite/translation-closed domain axiom as a reusable lemma; ensure histories expose the needed witnesses for reversed times.
  - *Branch B*: Keep domain lemmas local (e.g., “if `τ.domain t` and `s < t`, we can transport truth along existing witnesses”); do not assume global extension.

## Summary

- Under current frame/domain assumptions, `is_valid φ ↔ is_valid φ.swap_past_future` remains **not derivable**. The precise blockers are lack of domain symmetry/translation closure and the absence of a time-reversal model construction.
- Minimal additional axioms to make it go through: bi-infinite/translation-closed domains, definable reverse histories/models, and a structural time-reversal adequacy lemma.
- Recommended path is still to avoid the global lemma: refactor the derivation-indexed proof and use local transport lemmas as needed. If stronger axioms are accepted, the proof route is clear but constitutes a semantics change that must be documented and regression-tested.
