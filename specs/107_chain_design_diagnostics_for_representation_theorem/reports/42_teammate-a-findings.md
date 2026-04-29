# Teammate A Findings: g-Value Construction in Burgess 1982

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Focus**: g-value construction mechanism and sorry-site resolution
**Date**: 2026-04-28

## Key Findings

### 1. Burgess does NOT construct g-values at finite stages beyond the initial seed

This is the critical insight. Reading Burgess 1982 Section 2 carefully:

**Initial chronicle**: `dom f_0 = {0}`, `f_0(0) = A_0`, `g_0 = empty function` (line 238 of the paper). The g function starts completely empty because a singleton domain has no pairs.

**At each finite stage**, the elimination lemmas (2.9 and 2.10) produce g-values for NEW adjacent pairs via the splitting lemmas (2.4, 2.6, 2.7, 2.8). The mechanism is:

- **Lemma 2.4** (C5 elimination, n=0 case): Apply to `A = f(x)` with `U(xi, eta) in A`. Get `B, C` such that `R(A, B, C)`, `xi in C`, `eta in B`. Set `f'(y) = C`, `g'(x, y) = B`.
- **Lemma 2.6** (C4 elimination, n=0 case): Apply to `A = f(x)`, `B = g(x,y)`, `C = f(y)` with `R(A, B, C)`. Get `B', D, B''`. Set `f'(z) = D`, `g'(x,z) = B'`, `g'(z,y) = B''`.
- **Lemma 2.7/2.8** (C5 elimination, n=m+1 nested case): Similar splitting, producing `B', D, B''` from `R(A, B, C)`.

**For non-adjacent pairs**, g-values are determined by C3: `g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z)`.

So: g-values ARE constructed at every finite stage, but ONLY for new adjacent pairs created by point insertion. The paper's "let C3 determine the other values" (lines 222, 234) is doing the heavy lifting for non-adjacent g-values.

### 2. The exact mechanism for populating g when inserting a new point

There are three distinct insertion patterns in Burgess:

**Pattern A (C5, n=0, appending beyond domain)**: Lemma 2.10 says "apply 2.4 to A = f(x) obtaining B, C. Set y = x+1, f'(y) = C, g'(x,y) = B." Here B comes directly from Lemma 2.4, which produces an R-maximal DCS. In the codebase, `eliminate_C5_counterexample` uses `lemma_2_4` to get `C` (the MCS) but **does not capture B** (the g-value). It discards B entirely (`obtain ⟨C, h_C_mcs, h_η_C, _, _⟩`) and sets `g' = χ.g` unchanged. This is the root cause of the sorry sites.

**Pattern B (C4/C5, n=0, splitting an adjacent pair)**: Lemma 2.9/2.6 says "apply 2.6 to A = f(x), B = g(x,y), C = f(y) to obtain B', D, B''. Set f'(z) = D, g'(x,z) = B', g'(z,y) = B''." Here g-values come from the splitting lemma which preserves `B = B' ∩ D ∩ B''` (Lemma 2.5).

**Pattern C (non-adjacent)**: "let C3 determine" = `g'(w,z) = g(w,x) ∩ f(x) ∩ g'(x,z)` for existing w < x < z_new.

### 3. The codebase's fundamental design gap

The current `eliminate_C5_counterexample` (line 167) returns:
```
g' a b = χ.g a b  -- for ALL pairs, including new ones!
```

This means g is NEVER updated for the new adjacent pair `(x_max, y_new)`. The function signature promises `∀ a b, χ'.g a b = χ.g a b`, which is correct for OLD pairs but produces an empty/undefined g for the new pair.

The 7 sorry sites in `eliminate_potential_counterexample` all require `c2'` (BurgessR3Maximal for new adjacent pairs), but since g was never populated, there's nothing to be maximal about.

### 4. The relationship between Burgess R-maximality and the codebase's BurgessR3Maximal

Burgess's `R(A, B, C)` means: B is a maximal DCS such that `r(A, B, C)` holds (using Burgess's content-based r-relation). The codebase's `BurgessR3Maximal(A, B, C)` is exactly this, using the correct content-based `burgessR3` (not the obligation-propagation `r3Relation`).

The existence theorem `burgessR3Maximal_exists_from_seed` already handles the mathematical core: given a seed element eta with `burgessR(A, eta, C)` and `burgessRSince(C, eta, A)` and `eta in A`, it produces `BurgessR3Maximal(A, B, C)`.

### 5. Does Burgess maintain c2' at finite stages?

**Yes, implicitly**. Burgess's condition C2' states: "Whenever x, y in dom f and x immediately precedes y in dom f, then R(f(x), g(x,y), f(y)) holds." Every finite-stage chronicle in F satisfies C2' because:
- The initial chronicle satisfies C2' vacuously (singleton domain, no adjacent pairs)
- Each elimination step produces g-values for new adjacent pairs that are R-maximal by construction (Lemmas 2.4, 2.6, 2.7, 2.8 all produce R-maximal B)
- Old adjacent pairs that remain adjacent are unchanged
- Old adjacent pairs that get split have their g-values inherited via B = B' ∩ D ∩ B'' (Lemma 2.5)

### 6. Connection between g_content(A) and burgessR

There IS a seed connection but it's indirect:

- `g_content(A) = {phi | G(phi) in A}` captures the "universal future" content
- `burgessR(A, eta, C)` = for all gamma in C, `untl(eta, gamma) in A`
- These are connected via the axiom `G(phi) -> untl(phi, gamma)` (which follows from BX2: left monotonicity of Until, with the tautology `phi -> (top -> phi)` and BX12: `F(gamma) <-> top U gamma`)

Specifically: if `G(eta) in A`, then for any gamma in C, `untl(eta, gamma) in A` follows from `G(eta) -> (top U gamma -> eta U gamma)` (by BX2 + weakening) and `F(gamma)` (which must hold if C is reachable). But this requires F(gamma) in A, which is NOT guaranteed without additional structure.

The actual seed in Burgess comes from Lemma 2.4 directly, NOT from g_content. Lemma 2.4 constructs B as a maximal DCS with `eta in B` and `r(A, B, C)`, starting from the seed `{eta} ∪ {S(alpha, eta) : alpha in A}`.

### 7. Axioms needed for `untl(eta, gamma) in A` from `G(eta) in A` and `gamma in C`

This derivation requires:
1. `G(eta) in A` (hypothesis)
2. `gamma in C` (hypothesis)
3. Need: some connection between A and C (reachability)
4. `G(eta) -> (top -> eta)` (propositional)
5. `G(top -> eta) -> (top U gamma -> eta U gamma)` (BX2, left monotonicity of Until)
6. But we need `top U gamma in A`, i.e., `F(gamma) in A`

Without knowing F(gamma) in A, this derivation CANNOT be completed. The g_content approach alone is insufficient. This confirms that the seed must come from a structured construction (Lemma 2.4/2.6/2.7/2.8), not from g_content membership alone.

## Recommended Approach

### Fix Strategy: Restructure elimination functions to produce g-values

The fix requires modifying the elimination functions to actually construct and return g-values for new adjacent pairs:

**For C5 elimination** (`eliminate_C5_counterexample`):
1. Change `lemma_2_4` to return B (the DCS) alongside C (the MCS)
2. Set `g'(x_max, y_new) = B` where B is the R-maximal DCS from Lemma 2.4
3. For non-adjacent pairs involving y_new, use C3: `g'(w, y_new) = g(w, x_max) ∩ f(x_max) ∩ g'(x_max, y_new)` for w < x_max
4. The returned chronicle should have `BurgessR3Maximal(f(x_max), g'(x_max, y_new), f(y_new))` by construction

**For C5' elimination** (`eliminate_C5'_counterexample`):
- Mirror of above: capture B from the Since-direction Lemma 2.4, set `g'(y_new, x_min) = B`

**For C4 elimination** (`eliminate_C4_counterexample`):
1. Already has access to `g(x, y)` (the old adjacent pair being split)
2. Lemma 2.6 produces `B', D, B''` with `B = B' ∩ D ∩ B''`
3. Set `g'(x, z) = B'`, `g'(z, y) = B''`
4. BurgessR3Maximal follows from the construction

**For density/g_prop elimination**:
- Density case already handles g correctly (line 1045 in CounterexampleElimination.lean sets g' based on old g(pc.x, pc.y)) but has a sorry at line 1130 for the case `(a, z)` with `a = pc.x` where `f(z) = f(pc.x)` -- this is the self-pair case where burgessR3 is needed between pc.x and itself (via the copy at z)
- g_prop cases need similar treatment

### Specific sorry-site resolution

| Line | Case | Resolution |
|------|------|------------|
| 830 | c5_forward, c2' | Restructure `eliminate_C5_counterexample` to return g-value from Lemma 2.4's B |
| 868 | c5_backward, c2' | Mirror: restructure `eliminate_C5'_counterexample` |
| 908 | c4_forward, c2' | Restructure `eliminate_C4_counterexample` to return B', B'' from Lemma 2.6 |
| 946 | c4_backward, c2' | Mirror of c4_forward |
| 982 | g_prop_forward, c2' | Need g-value for new pair from G-propagation insertion |
| 1014 | g_prop_backward, c2' | Mirror of g_prop_forward |
| 1130 | density, c2' | Self-pair case: burgessR3(f(x), g(x,y), f(x)) -- needs special argument |

### Critical architectural insight

The current architecture separates "point insertion" (PointInsertion.lean) from "g-value assignment" (implied but not implemented). Burgess does both simultaneously. The fix should either:

**(Option A)** Merge: have elimination functions return the full extended chronicle with g-values already set and c2' already proved. This is the cleanest approach matching Burgess.

**(Option B)** Two-phase: have elimination functions return the new MCS + seed element, then have a separate g-construction step that calls `burgessR3Maximal_exists_from_seed`. This uses the existing infrastructure but requires identifying the seed.

Option A is recommended as it matches the paper more closely and avoids the seed-identification problem.

## Evidence/Examples

### Burgess 2.10 (C5, n=0) — exact quote:

> "We can apply 2.4 to A = f(x) obtaining B, C. Set y = x + 1, f'(y) = C, g'(x, y) = B, and let C3 determine the other values of g'(w, y)."

Note: B is the DCS from Lemma 2.4, set directly as g'(x,y). The codebase discards this B.

### Burgess 2.9 (C4, n=0) — exact quote:

> "By C2' we have R(f(x), g(x,y), f(y)) and so we can apply 2.6 to A = f(x), B = g(x,y), C = f(y) to obtain B', D, B''. Let z = (x+y)/2. Set f'(z) = D. Set g'(x,z) = B', g'(z,y) = B'', and let C3 determine the other values."

### Xu 1988 (Section 2) — simpler approach:

Xu's construction is simpler because:
1. His C4 condition (called C4 in his paper) is `g(t,t') ⊆ f(t'')` for intermediate t'', NOT Burgess's three-way C3 intersection
2. His Lemma 2.6 (C5a elimination) directly applies Lemma 2.4 to get B', D, B'' and sets g-values
3. His Lemma 2.7 (C6a elimination) directly applies Lemma 2.2 to get B, C and sets g-values
4. Key difference: Xu does NOT require R-maximality (C2') at finite stages; he only uses `r(A, B, C)`. His C3 is just `r(f(t), g(t,t'), f(t'))` without maximality.

However, our codebase uses Burgess's C2' (with maximality) which is stronger. The fix should maintain this.

### Lemma 2.4 output in the codebase (PointInsertion.lean:150-168):

```lean
noncomputable def lemma_2_4 ... :
    ∃ C : Set Formula, SetMaximalConsistent C ∧
      β ∈ C ∧ g_content A ⊆ C ∧
      Formula.some_past (Formula.untl γ β) ∈ C
```

This returns C (the MCS endpoint) but NOT B (the DCS interval set). Burgess's Lemma 2.4 produces BOTH B and C with `R(A, B, C)`. The codebase's version needs to be extended to also return B, or a new function needs to produce B from the seed.

## Confidence Level

**High** for findings 1-5 (g-value construction mechanism, design gap diagnosis, c2' maintenance).

**High** for the recommended approach (restructure elimination functions to produce g-values).

**Medium** for the self-pair case at line 1130 (density insertion where f(z) = f(x)). This case is unusual -- Burgess never copies f-values; each new point gets a genuinely new MCS. The density case is a codebase-specific addition not present in Burgess 1982. It likely needs `burgessR3(f(x), g(x,y), f(x))` which requires a specialized argument since the standard Lemma 2.4/2.6 construction assumes distinct endpoints.
