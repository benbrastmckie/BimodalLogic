# Teammate B Findings: Nested Bridging + FUC Replacement

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Angle**: Alternative approaches for nested bridging invalidity and FUC BX9 replacement
**Date**: 2026-04-28

## Area 1: Nested Bridging Lemma Analysis

### Key Findings

**The nested bridging lemma is genuinely unprovable under open guard.**

The two invalid lemmas are:
- `burgessR3_gamma_not_in_B_nested` (RRelation.lean:1169)
- `burgessR3_gamma_not_in_B_since_nested` (RRelation.lean:1183)

#### Why the Proof Fails

The **non-nested** version (RRelation.lean:834) works because it has `δ ∈ C`:
- Given: `burgessR3(A, B, C)`, `neg(untl(γ,δ)) ∈ A`, `δ ∈ C`
- If `γ ∈ B`: by burgessRSet, `untl(γ, δ) ∈ A` (since γ ∈ B and δ ∈ C)
- Contradiction with `neg(untl(γ,δ)) ∈ A` in MCS A. ✓

The **nested** version has `untl(γ,δ) ∈ C` instead of `δ ∈ C`:
- Given: `burgessR3(A, B, C)`, `neg(untl(γ,δ)) ∈ A`, `untl(γ,δ) ∈ C`
- If `γ ∈ B`: by burgessRSet, `untl(γ, untl(γ,δ)) ∈ A` (since γ ∈ B, untl(γ,δ) ∈ C)
- Need: `untl(γ, untl(γ,δ)) → untl(γ,δ)` to get contradiction
- This requires BX6 (absorption): `untl(γ, γ ∧ untl(γ,δ)) → untl(γ,δ)`, which works
- BUT going from `untl(γ, untl(γ,δ))` to `untl(γ, γ ∧ untl(γ,δ))` requires BX3 (right monotonicity) with `G(untl(γ,δ) → (γ ∧ untl(γ,δ)))`, which requires `⊢ untl(γ,δ) → γ`, which is exactly **BX9 (removed)**

**Confidence**: HIGH that this is genuinely unprovable under open guard.

#### Where the Nested Case Occurs

The nested case appears in CounterexampleElimination.lean in the C4/C4' hard case (Sub-case 1a: γ ∈ f(x) AND γ ∈ f(y)):

**C4 (line 422)**: After finding the rightmost `w` in `[x, y)` with `neg(untl(γ,δ)) ∈ f(w)`, the successor `w_next` splits:
- `w_next = y` → non-nested (line 415): `δ ∈ f(y)` from the counterexample. Works.
- `w_next < y` → nested (line 422): `untl(γ,δ) ∈ f(w_next)` (since w is rightmost). Broken.

**C4' (line 537)**: Mirror for Since direction. Same structure.

### Alternative Approaches for Nested Bridging

#### Option A: Restructure Search to Find δ Directly

Instead of finding the rightmost `w` with `neg(untl(γ,δ)) ∈ f(w)` and looking at its successor, **search for the leftmost v with δ ∈ f(v)** among points > x.

- `y` is always a candidate (δ ∈ f(y) given).
- Take leftmost `v_min` with `δ ∈ f(v_min)` and its predecessor `w`.
- If `neg(untl(γ,δ)) ∈ f(w)`: non-nested bridging works (δ ∈ f(v_min) as the C element). ✓
- If `untl(γ,δ) ∈ f(w)`: we still have the nested problem — w has the Until formula, not δ.

**Problem**: The nested case is inherent — any walk backwards from the event point will encounter points with `untl(γ,δ)` but not `δ`, creating the nested situation. Only clean exits are when δ appears directly.

#### Option B: Strengthen c2' to BurgessR3Maximal (MODERATE EFFORT)

If c2' maintains `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))` instead of just `burgessR3`, the maximality property may resolve the nested case:
- If γ ∈ B (B is maximal DCS with burgessR3), then certain extensions of B would also satisfy burgessR3, contradicting maximality.
- Specifically, if `untl(γ, untl(γ,δ)) ∈ A` and we can show that adding `untl(γ,δ)` to B would preserve burgessR3, then B should already contain it (or B ∪ {untl(γ,δ)} is DCS → B already has untl(γ,δ) by closure → contradiction with maximality if untl(γ,δ) ∉ B).

**Problem**: The DCS closure of B ∪ {untl(γ,δ)} may not preserve burgessR3. This needs careful analysis.

#### Option C: Use Induction on Domain Size (SIGNIFICANT RESTRUCTURE)

Burgess's original proof uses induction on the number of domain points. The C4 elimination adds one point per step. An induction-based approach might avoid the nested case by working with the full interval structure rather than just adjacent pairs.

This would be a major restructuring of CounterexampleElimination.lean.

#### Option D: Accept the Sorry and Work Around at Limit Level (PRAGMATIC)

At the limit level, the domain is dense (no adjacent pairs). The C4 elimination at finite stages may not need the nested case if we can show that the limit C4 property holds independently via the density argument.

The limit C4 property (`limit_satisfies_c4`, already proved) uses the finite-stage C4 properties. If the finite stages have the nested sorry, the limit C4 may still hold if the nested case never actually arises at the limit (because density means no adjacent pairs → c2' is vacuous → the nested bridging is never called).

**Key question**: Does `limit_satisfies_c4` depend on the finite-stage nested bridging? Need to trace the dependency.

### Recommendation for Nested Bridging

**Primary**: Investigate Option B (strengthen c2' to BurgessR3Maximal). The infrastructure for `burgessR3Maximal_exists_from_seed` already exists (sorry-free). The point insertion construction may already produce BurgessR3Maximal interpolants.

**Fallback**: Option D — verify that the limit-level C4 doesn't depend on finite-stage nested bridging, and delete the sorry stubs entirely if they're only called at finite stages that become vacuous at the limit.

**Confidence**: MEDIUM — the nested bridging is a genuine obstacle, but the limit-level density argument may render it moot.

---

## Area 2: FUC (Forward Until Closure) BX9 Replacement

### Key Findings

**The FUC proof is harder than report 37 suggests.** The claim that `rRelation_guard_continues'` is a drop-in replacement is incorrect.

#### Current State

`cantor_bfmcs_restricted_fuc` (ChronicleToCountermodel.lean:604) needs to prove:
```
∀ t φ ψ, untl(φ,ψ) ∈ mcs(t) → ∃ s > t, ψ ∈ mcs(s) ∧ ∀ r, t < r → r < s → φ ∈ mcs(r)
```

Available:
- `limit_satisfies_c5_weak` (ChronicleConstruction.lean:577): gives endpoint `s > t` with `ψ ∈ limit_f(s)` ✓
- **Missing**: guard `φ ∈ limit_f(r)` for intermediate r

#### Why rRelation_guard_continues' Doesn't Directly Apply

`rRelation_guard_continues'` (RRelation.lean:130) has type:
```
rRelation A B → untl(γ,δ) ∈ A → δ ∉ B → γ ∈ B ∧ untl(γ,δ) ∈ B
```

This requires `rRelation(limit_f(t), limit_f(r))`. But:
1. `rRelation` is NOT established between arbitrary limit_f pairs
2. c2' gives `burgessR3`, not `rRelation` — these are fundamentally different:
   - `burgessR3(A, B, C)`: for β ∈ B, γ ∈ C, `untl(β,γ) ∈ A` (from B to A)
   - `rRelation(A, B)`: for γ,δ with `untl(γ,δ) ∈ A`, resolve in B (from A to B)

#### The BUC Success Story

The BUC proof (lines 495-584) works by **contradiction**: assume the witness pattern holds but `neg(untl(φ,ψ)) ∈ f(t)`. Then `limit_satisfies_c4` gives z between t and s_wit with `φ.neg ∈ f(z)`. But guard says `φ ∈ f(z)`, contradiction.

This works because BUC is the BACKWARD direction (from witnesses to the Until formula), while FUC is FORWARD (from Until formula to witnesses).

#### Proof Strategy for FUC

**The correct approach**: Strengthen the C5 elimination to track guards.

Currently, `omega_chain_c5_witness` gives: `untl(ξ,η) ∈ f_n(x)` → ∃ y > x with `η ∈ f_{n+1}(y)`.

Needed: Additionally track that for all domain points r between x and y (in dom_{n+1}), `ξ ∈ f_{n+1}(r)`.

**How this works in Burgess's construction**:
1. When processing C5 counterexample `untl(ξ,η) ∈ f(x)` at stage n:
   - Insert a new point y > x with `η ∈ f(y)`
   - The g-function for (x, y) is constructed to include ξ (via the rRelation property of the construction)
   - For any existing domain point r between x and y: by C3, g(x,y) ⊆ f(r), so ξ ∈ f(r)
2. At subsequent stages n' > n:
   - New points r' may be inserted between x and y
   - These new r' inherit the guard via C4 elimination: the C4 property ensures that if neg-until is at some point, the guard negation appears between that point and the event
   - Combined with the chronicle invariants, ξ propagates

**This requires**:
1. A new field `c5_forward_guard` in `EliminationResult` (CounterexampleElimination.lean:735)
2. Proof that the point insertion for C5 maintains the guard at existing intermediate domain points
3. An induction argument showing the guard propagates through subsequent stages
4. Assembly into `limit_satisfies_c5_full` (replacing `limit_satisfies_c5_weak`)

#### Alternative FUC Strategy: Contrapositive + C4

Consider the contrapositive: if `untl(φ,ψ) ∈ limit_f(t)` and `φ.neg ∈ limit_f(r)` for some `t < r`, then... what? We have:
- `neg(untl(φ,ψ))` is NOT in limit_f(r) (we don't know this).
- Even if `untl(φ,ψ) ∈ limit_f(r)`, under open guard `untl(φ,ψ)` doesn't imply `φ` at r.

**This approach doesn't work cleanly.**

#### Minimal FUC Fix: Narrow the Witness

Instead of proving the guard for ALL intermediate r, find a **closer** witness s where no domain point lies between t and s.

At the limit, the domain is dense, so there's always a point between t and any s > t. BUT: at each finite stage, the C5 elimination produces a witness that IS the next domain point. The issue is that subsequent stages insert points between t and s.

**If we pick s to be the c5_weak witness**: we need the guard at ALL intermediate points, which is the full problem.

**If we pick s more carefully** (the closest possible witness): this doesn't help because the limit domain is dense.

### Recommended Approach for FUC

**Primary path**: Strengthen `EliminationResult` to include guard information. Add a field that witnesses `ξ ∈ f_{n+1}(r)` for all `r ∈ dom_{n+1}` between `x` and `y`. Then build `limit_satisfies_c5_full` from this stronger finite-stage result.

**Key realization**: The guard propagation at the limit follows from the **monotonicity of the omega chain** combined with the strengthened C5 witness. Once `ξ ∈ f_n(r)` for domain points at stage n, it remains at all subsequent stages (since f-values on existing points don't change).

**Effort estimate**: 12-18 hours. This is more complex than the 2-4 hours suggested in report 37.

**Confidence**: MEDIUM — the mathematical argument is sound but the Lean engineering is substantial.

---

## Summary

| Area | Status | Key Finding | Recommended Approach | Effort |
|------|--------|-------------|---------------------|--------|
| Nested bridging | Genuinely invalid | BX9 dependency is fundamental | Strengthen c2' to BurgessR3Maximal or prove limit-level workaround | 8-15h |
| FUC replacement | Harder than expected | rRelation_guard_continues' doesn't directly apply at limit level | Strengthen EliminationResult with guard tracking | 12-18h |

**Key correction to report 37**: 
1. The FUC fix is NOT a simple "replace BX9 with rRelation_guard_continues'" — it requires strengthening the C5 elimination infrastructure.
2. The nested bridging problem may be avoidable at the limit level due to density (no adjacent pairs).

**Confidence Level**: MEDIUM overall.
