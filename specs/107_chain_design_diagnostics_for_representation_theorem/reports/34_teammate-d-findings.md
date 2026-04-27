# Teammate D Findings: Strategic Architecture Review

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Role**: Horizons (strategic architecture, minimal-change path)
**Date**: 2026-04-27

## Key Findings

### 1. The Elimination Functions Don't Construct g-Values — This Is the Root Bug

Every elimination function (`eliminate_C5_counterexample`, `eliminate_C4_counterexample`, etc.) returns a new chronicle with `χ.g` unchanged:

```lean
-- eliminate_C5_counterexample (line 177):
refine ⟨⟨fun q => if q = y then C else χ.f q, χ.g, insert y χ.dom⟩, ...⟩

-- eliminate_C4_counterexample (line 324):
refine ⟨⟨fun q => if q = z then D else χ.f q, χ.g, insert z χ.dom⟩, ...⟩
```

The g function is passed through verbatim. When a new point z is inserted between x and y, the new adjacent pairs (x,z) and (z,y) inherit `χ.g x z` and `χ.g z y` — which are **arbitrary garbage** (z was never in the domain, so g was never defined for pairs involving z).

In Burgess's construction, Lemma 2.6 explicitly produces B', D, B'' where g'(x,z) = B' and g'(z,y) = B'', and Lemma 2.4 produces B, C where g'(x,y) = B. The "let C3 determine the other values" means non-adjacent pairs are set by the C3 identity. **The current code skips all of this.**

### 2. Two Separate Maximality Concepts Create Confusion

The codebase defines:
- `R3Maximal(A, B, C)` — maximal wrt `r3Relation` (obligation-propagation based)
- `BurgessR3Maximal(A, B, C)` — maximal wrt `burgessR3` (content-based)

These are **different relations**. The c2' invariant uses `burgessR3` (not even maximality — just DCS + burgessR3). The `lemma_2_6_full` uses `R3Maximal`. But Burgess's R uses content-based r(A, β, C) which maps to `burgessR`, not `rRelation`.

**Impact**: `lemma_2_6_full` (which uses R3Maximal) doesn't directly help with closing c2' (which uses burgessR3). Either:
- We need a `burgessR3`-based version of Lemma 2.6, or
- We need to show the two maximality concepts coincide, or
- We need to change c2' to use R3Maximal

### 3. g_prop and density Eliminations Are NOT in Burgess — Evaluating Necessity

Burgess only eliminates C4a, C4b, C5a, C5b counterexamples. The codebase adds:
- `g_prop_forward/backward` — G(α) ∈ f(x), α ∉ f(y), x < y adjacent
- `density` — insert midpoint between adjacent x < y

**Why these were added**: With empty g-values, the limit can't propagate G-formulas to adjacent points. So explicit g-propagation elimination was added as a workaround. Similarly, density ensures the limit domain is dense (needed for the Cantor isomorphism to ℚ).

**G-propagation vs C4**: G(α) = ¬(⊤ U ¬α). If G(α) ∈ f(x) and α ∉ f(y) with x < y, then ¬α ∈ f(y), so (⊤ U ¬α).neg ∈ f(x) and ¬α ∈ f(y) — a C4 counterexample. **So g_prop is subsumed by C4 elimination** and can be removed.

**Density**: Genuinely needed — it breaks adjacency even when no C4/C5 counterexample exists at those points. But the current implementation is wrong (f(z) = f(x), self-pair problem). If density uses Lemma 2.6 properly (picking δ ∉ g(x,y)), the self-pair problem vanishes because f(z) = D ≠ f(x).

### 4. The `lemma_2_6_full` Is Trivially True (D = B) and Useless for Splitting

Reading PointInsertion.lean lines 838-869, the current `lemma_2_6_full` works by showing R3Maximal forces B to be MCS (since r3Relation is monotone in B), so δ ∉ B → δ.neg ∈ B, then sets D = B, B' = B, B'' = B. This is mathematically correct for R3Maximal but **does nothing useful**: it doesn't create a genuinely new intermediate point.

This is because `R3Maximal` (obligation-propagation based) is so strong it forces B to be MCS. Burgess's R (content-based) does NOT force B to be MCS — the interval set g(x,y) is typically a proper DCS, not an MCS. The codebase's obligation-propagation r-relation is monotone in B, so maximality forces MCS. Burgess's content-based r is anti-monotone in B at the set level, so maximality gives a genuine DCS.

**This means Lemma 2.6 needs to be re-proved using BurgessR3Maximal** (or for c2' which uses non-maximal burgessR3), not R3Maximal.

### 5. The Intersection-Based limit_g Should Be Kept

Both limit_g approaches work once finite-stage g-values are non-empty. The intersection approach:
- Gives C3 for free (definitional, no proof needed)
- Avoids needing g-immutability proofs
- Makes `limit_g(x,z) ⊆ limit_f(y)` immediate
- Is conceptually cleaner

The FUC argument then goes: C5 at stage n gives η ∈ g_n(x,y). By finite-stage C3 (which we'd need to maintain as an invariant), η ∈ f_n(z) for all z between x and y at stage n. By f-immutability (already proved), η ∈ limit_f(z). So η ∈ limit_g(x,y) by the intersection definition.

### 6. c2' as Currently Defined (DCS + burgessR3, No Maximality) May Suffice

The current c2' invariant:
```lean
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    SetDeductivelyClosed (χ.g x y) ∧ burgessR3 (χ.f x) (χ.g x y) (χ.f y)
```

This is weaker than Burgess's R (maximality). The question is: do we need maximality? Looking at where c2' is used:
- **C4 hard case** (already sorry-free): Uses `burgessR3_gamma_not_in_B`, which needs DCS + burgessR3 — no maximality needed.
- **FUC closure**: Needs η ∈ g(x,y) from C5 elimination — this comes from the construction, not from maximality.

**Maximality is only used in Lemma 2.6** to construct the splitting point D. If we can prove the splitting without maximality, c2' as-is suffices. But Burgess's proof of Lemma 2.6 critically uses maximality (the "there exist β₀ ∈ B, γ₀ ∈ C with ¬U(γ₀, β₀ ∧ δ) ∈ A" step depends on maximality to get the witness β₀).

**Verdict**: We likely need full BurgessR3Maximal for c2' (or at least for the adjacent-pair g-values used in Lemma 2.6). The current weakened c2' was a compromise that may need upgrading.

## Strategic Recommendations

### A. Formalize Burgess Lemma 2.6 for the Content-Based Relation

The existing `lemma_2_6_full` is useless (D = B). We need a version that:
1. Takes `BurgessR3Maximal(A, B, C)` (or equivalent) with `δ ∉ B`
2. Produces genuinely new D, B', B'' where D ≠ B
3. Gives `BurgessR3Maximal(A, B', D)` and `BurgessR3Maximal(D, B'', C)` with `B = B' ∩ D ∩ B''`

**Critical question**: Does Burgess's consistency argument adapt to strict semantics? Burgess uses A3a and A4a, which are NOT valid under strict semantics. The adaptation needs BX axioms (BX5, BX6, BX7, etc.). This is the hard mathematical work.

### B. Modify Elimination Functions to Construct g-Values

**C5 elimination**: Use Lemma 2.4 output B for g'(x,y). Set g' for non-adjacent new pairs via C3.

**C4 elimination**: Use new Lemma 2.6 to get B', D, B''. Set g'(x,z) = B', g'(z,y) = B''. Set g' for non-adjacent new pairs via C3.

**Density elimination**: Fix to use Lemma 2.6 (pick δ ∉ g(x,y)), not f(z) = f(x).

### C. Remove g_prop from PotentialCounterexample

G-propagation failures are C4 counterexamples. Once C4 elimination constructs proper g-values, g_prop is redundant. This simplifies the codebase.

### D. Keep Intersection-Based limit_g

No change needed to the current limit_g definition. The FUC argument works through finite-stage C3 + f-immutability + intersection definition.

## Minimal-Change Path

| Step | What | Hours | Risk |
|------|------|-------|------|
| 1 | Formalize Burgess Lemma 2.6 for burgessR3/BurgessR3Maximal | 40-60 | HIGH: A3a/A4a adaptation |
| 2 | Upgrade c2' to BurgessR3Maximal (if needed for Lemma 2.6) | 4-8 | LOW |
| 3 | Modify C5/C5' to construct g from Lemma 2.4 | 8 | MEDIUM |
| 4 | Modify C4/C4' to construct g from new Lemma 2.6 | 8 | MEDIUM |
| 5 | Fix density to use Lemma 2.6 | 4 | LOW |
| 6 | Close 7 c2' sorry sites (immediate from construction) | 4 | LOW |
| 7 | Close 2 FUC sorry sites | 8 | MEDIUM |
| 8 | Remove g_prop, clean up | 2 | LOW |
| **Total** | | **78-102** | |

Step 1 dominates. If the BX-axiom adaptation of Burgess's consistency argument works, everything else follows. If it doesn't, the entire approach may need rethinking.

## Confidence Level

**High** on diagnosis: elimination functions not constructing g-values is definitively the root cause.

**Medium** on the path: Lemma 2.6 for strict semantics is genuinely hard and the main risk.

**High** on keeping intersection limit_g: once finite-stage g is non-empty, FUC works cleanly.
