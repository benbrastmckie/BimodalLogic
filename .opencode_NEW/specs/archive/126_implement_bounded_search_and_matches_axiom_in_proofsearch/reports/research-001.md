# Research Report: Implement bounded_search and matches_axiom in ProofSearch

**Project**: #126 — implement_bounded_search_and_matches_axiom_in_proofsearch  
**Date**: 2025-12-22  
**Research Type**: code research (Lean / proof search)

## Research Question
How should `bounded_search` and `matches_axiom` be implemented in `Logos/Core/Automation/ProofSearch.lean` to provide a terminating, minimally complete bounded proof search for TM logic, with correct axiom detection, depth/visit limits, and integration with existing helpers (`ProofCache`, context transforms, Aesop rules)?

## Current State (as of 2025-12-22)
- `matches_axiom`: 
  - Over-permissive patterns (any `box` implication counts as modal T; any implication counts as propositional K/S, etc.).
  - Covers only a subset of axioms; **missing**: `ex_falso`, `peirce`, `modal_k_dist`, `temp_k_dist`, `modal_5_collapse`, distribution variants, and precise diamond/always definitions.
  - Risk: high false positives (e.g., any `p.imp q` matches S; any `box` implication matches T), which inflates heuristic scores and search success incorrectly.
- `bounded_search`:
  - Depth-limited DFS only; **no visit/step limit**, **no cycle/duplicate guard**, and **no cache integration** despite available `ProofCache`.
  - No short-circuit on repeated goals or context growth; can loop on cyclic implications or modal/temporal self-reference.
- `search_with_cache` simply wraps `bounded_search` without visit accounting; `heuristic_score` relies on current (permissive) `matches_axiom`.
- Related modules: `Axioms.lean` defines 14 schemas (`prop_k`, `prop_s`, `ex_falso`, `peirce`, `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`, `temp_k_dist`, `temp_4`, `temp_a`, `temp_l`, `modal_future`, `temp_future`). `AesopRules.lean` provides proven forward/apply rules for a subset (excludes TL, MF, TF).

## Key Findings
1. **Axiom matching must align structurally with `Axioms.lean`** to avoid unsound search; current implementation both over-matches and omits schemas, distorting heuristics and success checks.
2. **Termination needs dual limits**: depth alone is insufficient; add a global visit/step counter and optionally a visited goal set to prevent cycles (`(Γ, φ)` repeats) especially with modal/temporal K recursions.
3. **Cache should be threaded through search**: a per-call `ProofCache` (or a visited set) will cut redundant sub-search and can store failures as well as successes.
4. **Branch ordering**: keep cheap strategies first (axiom, assumption, cached result), then modus ponens over context implications, then modal/temporal K; optionally sort MP antecedents by complexity for better pruning (ties to `heuristic_score`).
5. **Testing needs targeted cases**: positive/negative axiom patterns, depth/visit cutoffs, MP chains, and modal/temporal contexts to ensure correctness and termination.

## Recommendations
### matches_axiom (structural, no false positives)
Implement pattern checks in a **most-specific-first** order, covering all 14 schemas exactly:
- Propositional: 
  - `prop_k`: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
  - `prop_s`: `φ → (ψ → φ)`
  - `ex_falso`: `⊥ → φ` (antecedent exactly `Formula.bot`)
  - `peirce`: `((φ → ψ) → φ) → φ`
- Modal:
  - `modal_t`: `□φ → φ`
  - `modal_4`: `□φ → □□φ`
  - `modal_b`: `φ → □◇φ` (use `Formula.diamond` definition, i.e., `φ.imp (Formula.box φ.diamond)`)
  - `modal_5_collapse`: `◇□φ → □φ` (structure `φ.box.diamond.imp φ.box`)
  - `modal_k_dist`: `□(φ → ψ) → (□φ → □ψ)` (`(φ.imp ψ).box.imp (φ.box.imp ψ.box)`)
- Temporal:
  - `temp_k_dist`: `F(φ → ψ) → (Fφ → Fψ)`
  - `temp_4`: `Fφ → FFφ`
  - `temp_a`: `φ → F(Pφ)` where `Pφ` is `sometime_past φ` (`φ.imp (Formula.all_future φ.sometime_past)`) 
  - `temp_l`: `always φ → F(Pφ)` (`φ.always.imp (Formula.all_future (Formula.all_past φ))`)
- Interaction:
  - `modal_future`: `□φ → □Fφ`
  - `temp_future`: `□φ → F□φ`

Use helper predicates to destruct implications cleanly and prefer definitional forms for derived operators (`diamond`, `always`, `sometime_past`). Avoid catch-all implication cases; ensure ordering prevents broader patterns from pre-empting specific ones.

### bounded_search (depth + visits + cache)
Implement a DFS with explicit limits and optional visited set:
- Signature (suggested): `bounded_search (Γ : Context) (φ : Formula) (depth : Nat) (visits : Nat := 0) (visitLimit : Nat := 500) (cache : ProofCache := .empty) : Bool × ProofCache × Nat` (or thread `(Bool × ProofCache)` while passing `visits` by value).
- Guards:
  - `if depth = 0 ∨ visits ≥ visitLimit then (false, cache, visits)`
  - On each call, increment visits once (entry) to ensure deterministic cutoffs.
  - Check cache (hit → return cached result without increasing visits further if desired), else proceed and insert result (success or failure) before return.
- Strategy order:
  1. **Axiom**: `matches_axiom φ` → success.
  2. **Assumption**: `Γ.contains φ` → success.
  3. **Modus Ponens**: for each `ψ` in `find_implications_to Γ φ`, recurse on `ψ` with `depth - 1`; short-circuit on first success; thread updated cache/visits.
  4. **Modal K**: if `φ = □ψ`, recurse on `ψ` with `box_context Γ`.
  5. **Temporal K**: if `φ = F ψ`, recurse on `ψ` with `future_context Γ`.
  6. Otherwise fail.
- Optional: maintain a visited set `List (Context × Formula)` to prevent re-entering identical goals; on entry, if `(Γ, φ)` already visited, return false (and cache failure) to avoid loops in cyclic contexts.
- Determinism: ensure every recursive call decrements depth and increments visits; use tail recursion where possible to keep stack reasonable.

### Integration and API shaping
- Keep `search_with_cache` delegating to `bounded_search` by threading the cache; expose an entrypoint that takes optional `visitLimit` to prevent runaway recursion in user-facing search.
- Update `heuristic_score` to rely on corrected `matches_axiom` (post-fix false positives) and optionally incorporate cache hits (score 0/1 on cached success, large penalty on cached failure).
- Remove axiom placeholders once `matches_axiom` covers all schemas.

## Test Suggestions
- **Unit tests for matches_axiom** (new file under `LogosTest/Core/Automation/ProofSearchTest.lean`): one positive case per schema, plus negatives (random atoms, mixed implications, box nesting that should not match modal T/B/4, etc.).
- **Search termination tests**:
  - Depth cutoff: goal only reachable beyond depth → returns false.
  - Visit cutoff: cyclic context like `[p.imp p]` with low `visitLimit` halts without timeout.
  - Cache reuse: repeated subgoals hit cache and reduce visit count growth.
- **Strategy coverage tests**: 
  - MP chain: context `[p.imp q, r.imp p]` proves `q` within depth 2.
  - Modal K: goal `□p` with context `[p]` succeeds via `box_context`.
  - Temporal K: goal `F p` with context `[p]` succeeds via `future_context`.

## Impact on Acceptance Criteria
- **bounded_search with depth/visit limits**: add visit guard + cache; ensure each branch decrements depth.
- **matches_axiom correct matching logic**: align to all 14 axiom schemata, no over-match.
- **Axiom stubs removed**: replace stub logic with full structural matching.
- **Basic search runs without timeouts**: visit cutoff + cache + stricter matching reduce runaway recursion.

## Relevant Sources
- `Logos/Core/Automation/ProofSearch.lean` (current stubs and search order)
- `Logos/Core/ProofSystem/Axioms.lean` (authoritative axiom schemata)
- `Logos/Core/Automation/AesopRules.lean` (available proven axioms and inference rules)
- `Logos/Core/Automation/Tactics.lean` (context transforms and modal/temporal helpers)
