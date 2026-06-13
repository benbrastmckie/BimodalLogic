# Phase 3 Handoff: Composition Lemma Blocker

## Immediate Next Action

Fill the sorry at `NegationClosure.lean:1712` (`nf_exist_formula_nested_backward`).

## Current State

- **Phase 1-2**: COMPLETED (Lemma 5.3 and Prop 4.2 are already sorry-free in existing code)
- **Phase 3**: BLOCKED on composition lemma
- **Sorry count**: 8 sorry sites on Kamp chain, all cascading from NegationClosure.lean:1712
- **Build**: Clean (no errors)

## Key Finding

The negation closure infrastructure (Prop 4.2) is **already sorry-free**:
- `neg_interval_formula` (Lemma 5.1): NegationClosure5.lean -- sorry-free
- `neg_2var_vec_ea` (Prop 4.2): NegationClosureProp42.lean -- sorry-free
- `VVecEA2.translateLeft_correct` (translation): VecEATranslation.lean -- sorry-free
- `VVecEA2.conj_holds_vvecEA2` (conjunction): VecEAClosure.lean -- sorry-free

The blocker is NOT Prop 4.2 itself but the **wiring** from Prop 4.2 to NF existentials.

## The Sole Blocker

`nf_exist_formula_nested_backward` (NegationClosure.lean:1712)

**Goal**: Given formula truth → ∃ x, nf_eval_nf M (k+1) 2 (x,t) sub_nf

**What the formula provides**:
- x from Until/Since with char_kp1(nf_x) at x
- nf_eval_nf M (k+1) 1 (fun _ => x) nf_x
- Interval zone y witnesses with char_kp1(nf_y) at y
- Atom compatibility with sub_nf
- nf_full_compat_right filter passed

**What's missing**: Proof that sub_nf.2 ssn matches the actual 3-var existentials at (y,x,t) for non-interval zones.

## Three Approaches

### Approach A: Strengthen the formula filter
Add quantifier compatibility checks to nf_full_compat_right. Then prove the forward direction passes the stronger filter. Difficulty: forward direction proof at depth k > 0 requires the same composition argument.

### Approach B: Prove composition lemma directly
State and prove: for y in zone z relative to x,t with fixed order, `(∃ y, nf_eval_nf M k 3 (y,x,t) ssn) ↔ f(nf_x, parent_atoms, ssn, z)`. Induction on k. Base case (k=0) is straightforward. Step case needs IH at depth k-1. Difficulty: ~300-500 lines estimated.

### Approach C: VecEA2-based formula construction (RECOMMENDED)
Build a NEW formula from scratch using VecEA2 types instead of nf_exist_formula_nested. For each quantifier condition, construct a VecEA2 encoding. Use conjunction closure and existential closure (both sorry-free) to assemble. Correctness is BY CONSTRUCTION. Difficulty: ~400-600 lines, but no backward analysis needed.

## Sorry Inventory

| File | Line | Statement | Cascade? |
|------|------|-----------|----------|
| NegationClosure.lean | 1712 | nf_exist_formula_nested_backward | **ROOT** |
| NegationClosure.lean | 1327 | nf_full_compat_right_v2_of_eval | Independent (not on path) |
| RabinovichNegation.lean | 291 | nf_2var_exist_formula_prior_neg k+1 | Cascade |
| RabinovichGeneralized.lean | 474 | existPart_succ n>=2 | Cascade |
| NfCharFormula.lean | 572 | nf_2var_exist_formula_prior | Cascade |
| RabinovichWiring.lean | 359 | backward k+1 | Cascade |

## Key Decisions

- Created RabinovichProp42.lean with wiring and documentation
- Phases 1-2 marked COMPLETED (existing code sufficient)
- Phase 3 marked BLOCKED with clear blocker description
