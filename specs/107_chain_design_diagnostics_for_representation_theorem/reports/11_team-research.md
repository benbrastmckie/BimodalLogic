# Research Report: Task #107 — Density, Semantics, and Domain Construction

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Focus**: Does constructing over Q force density? What do Burgess/Venema/Verbrugge actually do?

## Summary

The team research resolves the density question definitively: **Approach A (dense domain) is WRONG for general BX completeness**, and the previous team's recommendation must be reversed. Burgess 1982 constructs over a **sparse subset** X ⊂ Q, not over Q itself. The truth lemma quantifies only over domain points in X, which need not be dense. The project's `FMCS Rat` / `BFMCS Rat` requiring `forward_G` over ALL rationals is architecturally incompatible with Burgess's approach and must be refactored.

## Key Findings

### 1. Burgess Uses Strict G Semantics with Sparse Domain (Teammate A)

**Burgess 1982 uses strict semantics** (x < y, not x ≤ y), matching this project exactly. His base system J₀ does NOT include a density axiom. Density (`F'T`: "between any two times there is another") is listed as a **separate extension**, explicitly excluded from the base system.

**The model domain is X = ∪ dom(fₙ)** — the union of finitely many rational points added at each construction step. X is countable, embedded in Q, but **NOT necessarily dense**. Q serves only as a coordinate pool for midpoint insertion, not as the model domain.

**The truth lemma (Claim 2.11) says**: `α ∈ f(x) ↔ x ⊨ α` for **x ∈ X only**, not for all rationals.

### 2. GGp → Gp Is the Density Axiom, Valid on Q but Not Derivable in BX (Teammates B, C, D)

All teammates confirm:
- **GGp → Gp IS valid on dense strict linear orders** (including Q). The density chaining argument is correct: for any t' > t, pick intermediate t₁ with t < t₁ < t', then Gp at t₁ gives p at t'.
- **GGp → Gp FAILS on Z** (discrete). Counterexample: p true at n ≥ 2, false at n < 2. Then GGp at 0 (Gp at all n > 0, which holds since Gp at n means p at all m > n) but Gp at 0 requires p at 1, which fails.
- **GGp → Gp is NOT derivable in BX**. The BX axiom `temp_4` gives only Gφ → GGφ (forward direction). The converse is not derivable.
- **Venema 1993** explicitly identifies GGp → Gp as the density axiom, separate from the base system.
- **Verbrugge 2004** includes it only when targeting dense frames.

### 3. The Dense Domain Approach (Previous Report's Recommendation) Is WRONG (Teammate D)

Making limit_dom = Q (or even dense in Q) would make GGp → Gp valid in the constructed model. This means:
- The completeness theorem would only hold for logics where GGp → Gp is derivable
- Formulas like GGp ∧ ¬Gp (BX-consistent, satisfiable on Z) could not be falsified
- **The previous team research (report 10) incorrectly recommended Approach A**

The correct approach is to work over the sparse domain X that the construction naturally produces, following Burgess.

### 4. The Project's FMCS/TaskFrame Architecture Is Incompatible with Burgess (All Teammates)

The root cause of the `forward_G` / `extended_limit_f` problem is that:

- `FMCS D` requires `forward_G : ∀ t t' : D, t < t' → G(φ) ∈ mcs(t) → φ ∈ mcs(t')`
- This quantifies over ALL elements of D, not just domain points
- When D = Rat, this requires forward_G at non-domain rationals
- Burgess's construction does NOT provide this — his truth lemma only holds at domain points

**The `extended_limit_f` design (assigning root MCS A to non-domain rationals) was an attempt to extend the truth lemma to all of Rat, but this is mathematically impossible** under strict semantics without either:
(a) Making the domain dense (wrong — validates density axiom)
(b) Using a subtype domain (blocked by AddCommGroup requirement)

### 5. The AddCommGroup Constraint Is the Real Architectural Bottleneck

The parametric infrastructure chain requires:
- `FMCS D` needs `[Preorder D]` (sufficient)
- `BFMCS D` needs `[Preorder D]` (sufficient)
- `TaskFrame D` needs `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` (**too strong**)
- `ParametricCanonicalTaskFrame D` needs all of the above
- `RestrictedParametricTruthLemma` needs all of the above

The `AddCommGroup` requirement comes from the task duration mechanism (durations as group elements `d = t' - t`). The chronicle's domain X = limit_dom is NOT closed under addition, so X cannot carry AddCommGroup.

## Synthesis: Resolution Path

### What Must Change

The project needs to either:

**Option 1: Refactor TaskFrame to remove AddCommGroup** — Replace the group-based duration mechanism with a pure order-based approach. The chronicle only needs `[LinearOrder D]` on its domain. The task frame could use ordered pairs `(t, t')` with `t < t'` instead of duration elements `d = t' - t`. This is the cleanest fix but invasive.

**Option 2: Use an order-isomorphism** — Construct the chronicle over X ⊂ Q (sparse), establish an order-isomorphism between X and some AddCommGroup-carrying type (e.g., Z if X is order-isomorphic to Z, or Q if we explicitly close under addition), then transfer the truth lemma. This preserves existing infrastructure but adds complexity.

**Option 3: Accept dense-frame completeness** — If the project's intended semantics ARE specifically for dense task frames (TaskFrame over ordered groups, which are Archimedean and hence dense), then GGp → Gp IS valid for the intended semantics, and the dense domain approach works. The completeness theorem would be stated for the class of ordered-group frames, not all strict linear orders.

### Recommendation

The user has explicitly stated they want completeness for a general logic "neither dense nor discrete." This rules out Option 3.

**Option 1 (refactor TaskFrame) is the correct path.** The AddCommGroup requirement is an implementation choice, not a mathematical necessity. The completeness theorem for BX over all strict linear orders does not require group structure on the domain. The parametric truth lemma can be reformulated to use `[LinearOrder D]` only, with task durations replaced by explicit witness pairs.

However, this is a significant refactoring of the parametric infrastructure (TaskFrame, ParametricCanonicalTaskFrame, ParametricTruthLemma, RestrictedParametricTruthLemma). It should be assessed for scope before committing.

**Option 2 could serve as an intermediate step**: prove completeness for the existing TaskFrame Rat infrastructure (which implies GGp → Gp), then later generalize.

## Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Previous report recommended Approach A (dense domain) | **REVERSED**: Dense domain validates GGp → Gp, restricting to dense frames. Approach A is wrong for general completeness. |
| Subtype ruled out by AddCommGroup | **CONFIRMED**: AddCommGroup is the real bottleneck. Must be removed from TaskFrame or worked around. |
| "Density argument is misdirected" (Teammate C) | **CLARIFIED**: The argument is correct for FMCS Rat (model over all of Q). It's misdirected for Burgess's actual construction (model over sparse X ⊂ Q). The project's FMCS Rat IS the problem. |

## Impact on Implementation Plan

The plan v4 (09_implementation-plan.md) must be revised:
1. **Phase 6 must be redesigned** — neither dense domain nor current extended_limit_f works
2. **The parametric infrastructure may need refactoring** before Phase 6 can proceed
3. **Phases 7-8 depend on Phase 6** and are blocked until the architectural question is resolved
4. **Phases 4-5 (C4 completion, limit_g)** can proceed independently as they don't depend on the domain extension

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|-----------------|
| A | Burgess 1982 semantics | completed | Burgess uses strict G with sparse X ⊂ Q; density is separate extension |
| B | Venema 1993 strict time | completed | GGp → Gp confirmed as density axiom; Venema's method sidesteps density |
| C | Truth lemma analysis | completed | Density argument correct but misdirected; FMCS Rat is the real problem |
| D | Verbrugge step-by-step | completed | Dense domain WRONG for BX; corrects previous report's recommendation |

## References

- Burgess 1982: Strict semantics, sparse domain X ⊂ Q, density as separate extension
- Venema 1993: Strict semantics, GGp → Gp = density axiom, "completeness via completeness"
- Verbrugge 2004: Step-by-step construction, domain matches axiom system's frame class
- Previous report 10: **SUPERSEDED** — dense domain recommendation reversed
