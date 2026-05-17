# Phase 6 Handoff: Junction-Depth Induction (BLOCKED)

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Phase**: 6 - Prove all_separable via Junction-Depth Induction
**Status**: BLOCKED
**Session**: sess_1779003456_c5b522
**Date**: 2026-05-17

## Current State

- Phases 1-5 COMPLETED, `lake build` passes
- 0 axioms in Eliminations.lean
- 8 axioms remain in SeparationThm.lean (4 weak temporal closure + 4 proper temporal closure)
- 1 sorry in ExpressiveCompleteness.lean (Phase 7 target, depends on Phase 6)

## Blocker Analysis

### The Circular Dependency

The 8 axioms assert that temporal operators preserve separability:
```
snce_separable : is_separable φ → is_separable ψ → is_separable (.snce φ ψ)
untl_separable : is_separable φ → is_separable ψ → is_separable (.untl φ ψ)
all_past_separable : is_separable φ → is_separable (.all_past φ)
all_future_separable : is_separable φ → is_separable (.all_future φ)
```

The natural approach to prove `snce_separable`:
1. Get separated φ', ψ' (from hypotheses)
2. Form `.snce φ' ψ'` (equivalent to `.snce φ ψ`)
3. Observe `.snce φ' ψ'` satisfies `no_S_nested_in_U` (since separated formulas have S-free untl-args)
4. Prove `no_S_nested_in_U → separable`

Step 4 requires induction on `count_U_subformulas`:
- Base (count=0): U-free formula. BUT U-free formulas like `all_future (snce p q)` = G(S(p,q)) are NOT separated.
- G(S(p,q))'s separated equivalent REQUIRES U operators (semantically proven: it references both past and future of the evaluation point).
- So the base case requires `all_future_separable` for formulas containing S -- which is another axiom!

Similarly, `untl_separable` requires eliminating S-under-U (the dual problem), whose base case (S-free formulas with U, like `all_past (untl A B)`) requires U in the separated equivalent.

### Why Junction-Depth Induction is Hard to Formalize

GHR94's resolution (Lemma 10.2.8) uses junction-depth induction, which simultaneously handles both directions (U-under-S AND S-under-U). The formalization challenges:

1. **Non-monotone size**: After getting separated equivalents and recomposing, the result can be LARGER than the original. Standard `sizeOf`-based WF induction fails.

2. **Mutual recursion**: U-elimination needs S-elimination for its base case, and vice versa. This requires a COMBINED well-founded measure like `(junction_depth, count_U + count_S, sizeOf)` with proofs that it strictly decreases.

3. **Integer-specific equivalences needed**: The base cases require integer-specific temporal identities:
   - `G(S(p,q))` must be expressed as a boolean combination of U-terms and S-terms
   - `H(U(A,B))` must be expressed similarly
   - These are non-trivial semantic theorems (~50-100 LOC each)

4. **Measure decrease proofs**: After abstraction/substitution/hierarchy application, must prove the combined measure strictly decreases (~200+ LOC of supporting lemmas).

### Estimated Work

- `abstract_snce` + preservation lemmas: ~200 LOC
- `no_U_nested_in_S` predicate + helpers: ~100 LOC
- Integer temporal equivalences for base cases: ~300+ LOC
- Combined mutual WF recursion: ~400+ LOC
- Measure decrease proofs: ~200+ LOC
- Total: 1200-1500 LOC across 3-4 new/modified files

## Immediate Next Action

To unblock Phase 6, the successor should:

1. **Start with the base cases**: Prove integer-specific temporal equivalences:
   - `all_future (snce C D)` (G(S(C,D))) is separable when C, D are U-free
   - `all_past (untl A B)` (H(U(A,B))) is separable when A, B are S-free
   These are concrete, bounded proof tasks that don't involve the full mutual recursion.

2. **Build `abstract_snce`** (dual of existing `abstract_untl`): Replace all occurrences of a specific `snce C D` with a fresh atom. Prove roundtrip, correctness, and preservation lemmas (mirroring the existing `abstract_untl_*` theorems in Hierarchy.lean).

3. **Define `no_U_nested_in_S`** predicate and prove:
   - `separated_implies_no_U_nested_in_S` for the relevant sub-cases
   - Preservation under `abstract_snce`

4. **Implement the mutual theorem** once base cases are available:
   ```lean
   theorem separable_of_no_bad_nesting (φ : Formula) 
       (h : no_S_nested_in_U φ ∨ no_U_nested_in_S φ) : is_separable φ
   ```
   Using well-founded induction on `(junction_depth φ, count_U_subformulas φ + count_S_subformulas φ)`.

## Key Decisions

- The existing infrastructure (abstract_untl, preservation lemmas, Lemma 10.2.4, Cases 1-4) provides ~60% of the machinery needed.
- The missing ~40% is the dual infrastructure (abstract_snce, S-elimination) and the base case temporal equivalences.
- The plan's original 4-hour estimate for Phase 6 was significantly underestimated. Realistic estimate: 20-30 hours.

## Files Modified This Session

None (analysis only; phase marked BLOCKED in plan file).
