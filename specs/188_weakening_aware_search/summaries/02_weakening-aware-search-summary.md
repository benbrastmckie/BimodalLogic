# Implementation Summary: Weakening-Aware Search (Task 188)

- **Task**: 188 - Weakening aware search
- **Plan**: plans/02_weakening-aware-search-plan.md
- **Status**: [COMPLETED] — all 4 phases complete (Phases 1-2 subsumed by task 187; Phases 3-4 implemented here)
- **Session**: sess_1784042334_6ccc8d
- **Date**: 2026-07-14

## Outcome

The plan was written before tasks 187/189/194 landed and was partly stale. After
reconciliation against the committed tree:

- **Phases 1-2 (tactic layer): done-by-187.** Task 187 replaced `tryDerivedMatch`
  with `tryLemmaMatchCore` (`Theories/Bimodal/Automation/Tactics/Helpers.lean:696-773`),
  which matches the `@[tm_lemma]` database and, for non-empty contexts, applies a
  weakening fallback via `DerivationTree.weakening` + `List.nil_subset`
  (`Helpers.lean:753-772`). No `tryWeakenedDerivedMatch` or `derivedTheoremTable`
  was added — 187's design supersedes both. The Phase-2 subset combinator is
  obsolete because 187's fallback always produces a literal `[] ⊆ Γ` side goal.
- **Phase 3 (computable layer): implemented.** In
  `Theories/Bimodal/Automation/ProofSearch/Core.lean`:
  - `matchDerived` extended from one arm (TF: `□φ → G□φ`) to five, via a
    `<|>` chain of structural shape matches: TF, `box_to_future` (`□φ → Gφ`),
    `box_to_past` (`□φ → Hφ`), `identity` (`φ → φ`), `dni` (`φ → ¬¬φ`). Each
    reuses the corresponding computable constant from
    `Bimodal.Theorems.Combinators` / `Bimodal.Theorems.Perpetuity` (new import
    `Bimodal.Theorems.Perpetuity.Helpers`; no cycle — its automation dependency
    is the leaf module `LemmaDB`). The existing `weakening [] Γ` wrapper lifts
    matches into non-empty contexts unchanged.
  - **Completeness fix**: the `matchAxiom` branch of `bounded_search_with_proof`
    is restructured as an `Option`-valued `axiomAttempt`; a frame-class mismatch
    (e.g. Dense/Discrete-only axioms under Base) or formula mismatch now falls
    through to derived/assumption/MP instead of returning `none` outright. The
    success proof term (`heq ▸ DerivationTree.axiom Γ ψ witness hfc`) is
    preserved verbatim; termination is untouched (still structural on `depth`).
- **Phase 4 (tests): implemented** in a NEW file
  `Tests/BimodalTest/Automation/WeakeningSearchTest.lean` (registered in
  `Tests/BimodalTest.lean`), because `TacticsTest.lean` and `ProofSearchTest.lean`
  are baseline-broken (pre-existing String/Atom and `search`-identifier errors;
  431 errors across 17 untouched test files in the `BimodalTest` root target).
  Cases:
  - Tactic layer: headline `[p, q] ⊢ (p.imp p)` by `modal_search`; recursion
    case `[(p.imp p).imp q] ⊢ q` by `modal_search 3`; Tier-2
    `[q] ⊢ (□p → Gp)` via `box_to_future`.
  - Computable layer (`#guard`): headline mirror `[p, q]` identity;
    `box_to_future`, `box_to_past`, `dni` arms in non-empty contexts; TF-arm
    regression guard (empty context).
  - Fall-through witness: density-shaped `GGp → Gp` (Dense-only axiom match)
    now closes from the context by assumption — previously dead-ended.
  - Negative fast-fail guard: `bounded_search_with_proof [] z 5` returns `none`.

## Verification

| Check | Result |
|-------|--------|
| `lake build Bimodal.Automation.ProofSearch.Core` (scoped) | green |
| `lake build BimodalTest.Automation.WeakeningSearchTest` (scoped) | green |
| Full `lake build` (default target) | green (1755 jobs) |
| Sorries in touched files | 0 |
| Vacuous definitions in diff | 0 |
| New axioms | 0 (`#print axioms matchDerived` → `[propext]`; `bounded_search_with_proof` → `[propext, Quot.sound]`) |
| Headline + all `#guard` cases | pass |

Note: `lake build BimodalTest` (full test root) fails at baseline in 17
pre-existing files unrelated to this task (e.g. `DerivationTest.lean`,
`EdgeCaseTest.lean`); the new test module builds green in isolation and via the
root import chain up to those pre-existing failures.

## Plan Deviations

- Phases 1-2 skipped entirely: subsumed by task 187's `tryLemmaMatchCore`
  weakening fallback + `@[tm_lemma]` database (committed before this run).
- Phase 3 `matchDerived` arms altered: `lce_imp`/`rce_imp` (noncomputable
  section) and `temp_4_derived`/`H_transitivity` (noncomputable defs) excluded —
  `matchDerived` must stay computable because `bounded_search_with_proof`
  constructs its proof terms at runtime. Added instead: identity, dni,
  box_to_future, box_to_past.
- Phase 4 test placement altered: new `WeakeningSearchTest.lean` instead of the
  baseline-broken `TacticsTest.lean`/`ProofSearchTest.lean`.
- Phase 4 gate altered: scoped test-module build + full default-target
  `lake build` substituted for the unattainable `lake build BimodalTest` root
  (pre-existing breakage outside task scope).
- No commits made by this agent (orchestrator commits, per dispatch instructions).

## Files

- Modified: `Theories/Bimodal/Automation/ProofSearch/Core.lean` (+1 import,
  matchDerived extension, matchAxiom fall-through restructure)
- Modified: `Tests/BimodalTest.lean` (+1 import line)
- Added: `Tests/BimodalTest/Automation/WeakeningSearchTest.lean`
- Updated: `specs/188_weakening_aware_search/plans/02_weakening-aware-search-plan.md`
  (phase markers, reconciliation notes, deviation annotations)

## Follow-up Candidates (not blocking)

- Make `lce_imp`/`rce_imp`/`temp_4_derived`/`H_transitivity` computable (or add
  computable re-derivations) to extend `matchDerived` to the remaining
  unambiguous shapes from the plan.
- Repair the baseline-broken test files (`DerivationTest.lean`,
  `EdgeCaseTest.lean`, `TacticsTest.lean`, `ProofSearchTest.lean`, etc.) so the
  `BimodalTest` root target builds again.
