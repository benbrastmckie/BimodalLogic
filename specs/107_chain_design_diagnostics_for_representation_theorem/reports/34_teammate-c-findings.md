# Teammate C (Critic) Findings: Task 107

**Date**: 2026-04-27
**Role**: Critic — identify gaps, errors, and blind spots

## Key Findings

### 1. CRITICAL: The Density Elimination is Fundamentally Wrong

**Status**: The density case (CounterexampleElimination.lean lines 989–1153) sets `f(z) = f(x)` — copying the left endpoint's MCS to the midpoint. This is NOT what Burgess does.

**What Burgess actually does**: Burgess's Lemma 2.9 (Case n=0) applies Lemma 2.6 to `R(f(x), g(x,y), f(y))` to obtain `B', D, B''` with `R(f(x), B', D)`, `R(D, B'', f(y))`, and `B = B' ∩ D ∩ B''`. Then `f'(z) = D` (a FRESH MCS constructed via Lindenbaum from a consistency argument), `g'(x,z) = B'`, `g'(z,y) = B''`.

**What the code does**: It sets `f(z) = χ.f pc.x` (i.e., `D = f(x)`), and `g'(x,z) = g'(z,y) = χ.g pc.x pc.y`. This creates the "self-pair" blocker at line 1086 where `burgessR3(f(x), g(x,y), f(x))` is needed but unprovable — because g(x,y) was constructed for the pair (f(x), f(y)), not (f(x), f(x)).

**This is not a corner case to be patched** — the entire density elimination is architecturally wrong. It needs to use Lemma 2.6 (which constructs D via A4a-equivalent reasoning) to produce f(z), g(x,z), and g(z,y) simultaneously. The self-pair blocker is a symptom of using the wrong MCS.

**However**: Burgess's density elimination is just a special case of C4 elimination (Lemma 2.9). In Burgess, there is NO separate "density" step — density emerges from the limit being over the rationals. The current code has a separate `.density` case because it breaks adjacency by inserting midpoints. But this is unnecessary if C4/C5 eliminations already use Lemma 2.6 to insert points. The density of the limit domain follows from the density of the rationals (every pair can have a midpoint inserted).

**Recommendation**: Either (a) rewrite the density case to use Lemma 2.6 with a proper D, or (b) eliminate the density case entirely and rely on C4/C5 eliminations + the density of the rationals to produce a dense limit domain.

### 2. CRITICAL: None of the Elimination Functions Construct g-Values

Every individual elimination function (`eliminate_C5_counterexample`, `eliminate_C4_counterexample`, `eliminate_g_prop_counterexample`, `eliminate_h_prop_counterexample`) returns `g = χ.g` unchanged. The return types all include `∀ a b, χ'.g a b = χ.g a b` (proved by `fun _ _ => rfl`).

This means the g-function is NEVER extended by ANY elimination. New pairs (x, z) and (z, y) created by inserting z get `g(x,z) = g(x,y)` and `g(z,y) = g(x,y)` — but ONLY in the density case within `eliminate_potential_counterexample`. For C5 and C4 eliminations, the new point's g-values are just `χ.g` applied to coordinates where it was never defined (garbage values).

**In Burgess's construction**: Lemma 2.4 (C5 case) explicitly constructs `B` (with `R(A, B, C)`) and sets `g'(x, y) = B`. Lemma 2.6 and 2.7 (C4/C5 n>0 cases) construct `B', D, B''` and set `g'(x, z) = B'`, `g'(z, y) = B''`, with C3 determining other values.

**The return type of the individual elimination functions must be changed** to include the new g-values. Currently they return `∃ χ' : Chronicle, ... ∧ (∀ a b, χ'.g a b = χ.g a b)`. This last clause (`g unchanged`) is what makes it impossible to construct proper g-values.

### 3. The "burgessR3_absorption" Lemma is Real but Misnamed

The existing `burgessR3_absorption` in RRelation.lean (line 641) is correctly proved. It says: if `burgessR3(A, B₁, D)` and `burgessR3(D, B₂, C)` and `B₁₂ ⊆ B₁ ∩ D ∩ B₂`, then `burgessR3(A, B₁₂, C)`.

This corresponds to Burgess's Lemma 2.5 direction: given the three-way decomposition, the intersection satisfies the r-relation. It does NOT "split" an existing BurgessR3Maximal — it goes in the OPPOSITE direction (from parts to whole).

**For C4 elimination (Lemma 2.9)**: We need to go from `R(f(x), g(x,y), f(y))` to `R(f(x), B', D)` and `R(D, B'', f(y))`. This is Lemma 2.6, which CONSTRUCTS B', D, B'' via a Lindenbaum argument. The "absorption" lemma only tells us that `g(x,y) = B' ∩ D ∩ B''` — it doesn't produce B', D, B''.

**What's needed**: A Lean formalization of Lemma 2.6 for the `burgessR3` relation (or more precisely, for `BurgessR3Maximal`). The current `lemma_2_6` in PointInsertion.lean does NOT exist — only `lemma_2_4` and `lemma_2_5b` are implemented.

### 4. The Intersection-Based limit_g IS Correct for the Limit, but NOT for FUC

The current `limit_g(x,z) = {φ | ∀ y ∈ limit_dom, x < y → y < z → φ ∈ limit_f(y)}` is mathematically the RIGHT definition for the limit g-function. In a dense domain, C3 forces `g(x,z) = ⋂{f(y) : x < y < z}`, which is exactly this set.

**Report 33 is WRONG to call this "tautological"**. The definition is correct. The problem is that the FUC proof needs to show `φ ∈ limit_g(x,y)`, which by this definition means showing `φ ∈ limit_f(z)` for ALL z between x and y. This is NOT tautological — it's a substantive claim that must be proved using the finite-stage g-values.

**The correct argument for Claim 2.11 (Until case)**:
1. `U(β, γ) ∈ f(x)` (by hypothesis)
2. By C5, ∃ y with `γ ∈ f(y)` and `β ∈ g_n(x, y)` at some finite stage n
3. By C3 at stage n: `g_n(x, y) ⊆ f_n(z)` for any z between x and y in dom_n
4. At the limit: need `β ∈ f(z)` for ALL z between x and y (not just those in dom_n)
5. For any z in the limit domain, z enters at some stage m. By stage max(m, n), both x, y, z are in the domain. Need: `β ∈ g_max(n,m)(x, y)` and `g_max(n,m)(x, y) ⊆ f_max(n,m)(z)`.
6. This requires g-immutability: `g_max(n,m)(x, y) ⊇ g_n(x, y)` (or rather `= g_n(x, y)`)
7. Given g-immutability + C3 at the finite stage, step 5 follows.

So the intersection limit_g is correct, but the FUC proof requires **g-immutability** and **non-trivial finite-stage g-values** (specifically, `β ∈ g_n(x, y)` from C5). The problem isn't the limit_g definition — the problem is that finite-stage g-values are empty/undefined.

**However**, there's a subtlety: the intersection-based limit_g only gives `β ∈ limit_g(x, y)` if β is at EVERY intermediate point. But C5 gives `β ∈ g_n(x, y)`, and we need C3 at stage n to propagate to intermediate points that exist at stage n. For NEW intermediate points added after stage n, we need g-immutability to ensure the stage-n g-value persists.

### 5. C2' at Finite Stages IS Needed — But Only for C4 Elimination

The question "is C2' needed at finite stages?" has a definitive answer: **YES, but only because C4 elimination uses it**.

Looking at the code:
- `eliminate_C4_counterexample` takes `h_c2' : χ.c2'` as input and uses it at line 409: `obtain ⟨h_dcs_wn, h_r3_wn⟩ := h_c2' w w_next h_adj`
- `eliminate_C4'_counterexample` similarly takes and uses `h_c2'`
- `eliminate_C5_counterexample` does NOT use `h_c2'`
- `eliminate_g_prop_counterexample` does NOT use `h_c2'`
- `eliminate_h_prop_counterexample` does NOT use `h_c2'`

So C2' is load-bearing specifically for the C4 hard case: when `γ ∈ f(x)` and `γ ∈ f(y)` and `¬U(γ,δ) ∈ f(x)`, we need `burgessR3(f(w), g(w, w_next), f(w_next))` for the adjacent pair (w, w_next) to show `γ ∉ g(w, w_next)`.

If we could prove C4 at the limit WITHOUT using C2' at finite stages (e.g., by a different argument), then C2' could be dropped from the finite-stage invariant. But the current C4 proof fundamentally depends on it.

### 6. g_prop and h_prop Eliminations Are NOT Burgess Lemma 2.6

The `eliminate_g_prop_counterexample` (line 564) handles `G(α) ∈ f(x)` and `α ∉ f(y)` for adjacent x, y. It uses `g_propagation_witness` to find a D with `α ∈ D` and `g_content(f(x)) ⊆ D`, then sets `f(z) = D`.

This is NOT a C4 elimination and NOT Lemma 2.6. It's more like a specialized version of ensuring G-propagation across the domain. In Burgess's framework, G-propagation follows automatically from C3 + the definition of g: `G(α) ∈ f(x)` means `α ∈ g_content(f(x))`, and with a proper g(x,y), C3 gives `g(x,y) ⊆ f(z)` for intermediate z.

**The g_prop/h_prop cases exist because g-values are trivial**. If g(x,y) were properly constructed (as in Burgess), then `G(α) ∈ f(x)` would put `α` in g(x,y) which by C3 propagates to intermediate points. The g_prop elimination is a WORKAROUND for empty g-values, not a genuine feature of the completeness proof.

### 7. Missing Lemma 2.6 and 2.7 Are the Root Cause

The PointInsertion.lean file header (line 49) explicitly states:
```
### Withdrawn (Phase 3, Task 107)
- `lemma_2_6_strong`: FALSE under strict semantics
- `lemma_2_7`: FALSE under strict semantics
- `lemma_2_8`: Depends on lemma_2_7
```

But Burgess's Lemma 2.6 is **essential** for C4 elimination (constructing D with ¬δ between adjacent points) and for density (constructing D between any two points). The claim that it's "FALSE under strict semantics" needs careful examination.

Burgess's Lemma 2.6 uses A4a: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`. Under strict semantics, A4a may not hold directly. But the formalization uses BX axioms (BX5 = self_accum_until, BX6 = absorb_until) that serve analogous roles. The question is whether BX5 + BX6 + BX7 (linear_until) provide enough power to prove the consistency argument in Lemma 2.6.

**This is the deepest mathematical question**: Can the D₀ consistency argument from Lemma 2.6 be adapted to strict semantics using BX axioms? If yes, then Lemma 2.6 can be formalized and all the downstream problems (c2' sorries, density self-pair, g-construction) have a clear path to resolution. If no, then a fundamentally different approach is needed.

## Assessment of Current Plan (v20)

### What's Correct
- Deleting `rebuild_g` and `burgessR3Maximal_exists_general` (Phase 3 cleanup)
- The general direction of constructing g-values within elimination functions
- The need for g-immutability at the limit
- Phase 5's approach of using C5 seed + C3 interval containment for FUC

### What's Wrong or Incomplete

1. **Plan assumes absorption can "split" g-values** — it can't. Lemma 2.5/absorption goes from parts to whole, not whole to parts. C4/density splitting requires Lemma 2.6, which constructs NEW g-values from scratch.

2. **Plan doesn't address that individual elimination functions need new return types** — they all currently return `g = χ.g`. The plan's Phase 3 says "modify all 7 elimination functions" but doesn't acknowledge the return type must change from `∀ a b, χ'.g a b = χ.g a b` to something that carries new g-values.

3. **Plan doesn't address that Lemma 2.6 is missing** — the single most important missing piece. Without it, there's no way to construct B', D, B'' for C4 elimination or density point insertion.

4. **Plan incorrectly says limit_g must be "stage-based"** — the intersection-based definition is mathematically correct for a dense limit domain. The real requirement is non-trivial finite-stage g-values + g-immutability, not a different limit definition.

5. **Plan's estimate of 700-800 lines is likely 2-3x too low** — formalizing Lemma 2.6 alone could be 300-500 lines given the complexity of the consistency argument under strict semantics.

## Questions That Need Answers

1. **Can Lemma 2.6 be proved under strict semantics?** Specifically: can the consistency of `D₀ = {S(α,β) : α ∈ A, β ∈ B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ ∈ C, β ∈ B}` be established using BX axioms instead of A4a? This uses A4a in the step: from `U(γ,β) ∈ A` and `¬U(γ, β∧δ) ∈ A`, derive `U(β ∧ U(γ,β) ∧ ¬δ, β) ∈ A`. Under strict semantics, do BX5 (self_accum) + BX7 (linear) provide equivalent power?

2. **Should g_prop/h_prop elimination be eliminated?** If g-values are properly constructed, G-propagation should follow from C3 automatically. The g_prop/h_prop cases may be unnecessary overhead.

3. **Is the density case really needed as a separate elimination type?** In Burgess, density is not a separate step — the limit domain is dense because it's a subset of the rationals. Could the density case be subsumed by ensuring the counterexample enumeration eventually inserts midpoints?

4. **What's the relationship between `burgessR3` and Burgess's `R(A, B, C)`?** The code defines `BurgessR3Maximal(A, B, C)` as maximal DCS B with `burgessR3(A, B, C)`. But Burgess's `R(A, B, C)` means B is maximal with `r(A, B, C)` where `r(A, β, C) ≡ ∀γ∈C, U(β,γ)∈A`. Are these equivalent? The code's `burgessR3` additionally requires the Since direction. Is this needed?

## Confidence Level

**High confidence**: Findings 1, 2, 3, and 6 are based on direct code reading and are factual.

**High confidence**: Finding 7 (missing Lemma 2.6) is the root cause of the stalled progress.

**Medium confidence**: Finding 4 (intersection limit_g correctness). The mathematical argument is sound but the Lean formalization may have subtleties around g-immutability.

**Low confidence**: Whether Lemma 2.6 can be adapted to strict semantics (Question 1). This requires deep analysis of the axiom interaction that I haven't fully verified.
