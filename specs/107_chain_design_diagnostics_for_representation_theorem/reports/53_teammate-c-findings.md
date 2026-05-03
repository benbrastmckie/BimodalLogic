# Phase 4 Research: c2' Threading Through Omega-Chain and G-Value Construction

**Task 107 - Chain Design Diagnostics for Representation Theorem**  
**Session**: sess_1777762781_b2f826  
**Research Teammate C**  
**Date**: 2026-05-02

---

## Executive Summary

This report analyzes the 10 c2' sorry sites in `CounterexampleElimination.lean` and provides a detailed implementation plan for closing the C4/C4' hard cases. The c2' field (Burgess C2') is **critical** for the limit construction as it ensures `BurgessR3Maximal` holds for adjacent pairs at every finite stage of the omega-chain.

**Key Findings:**
- All 10 c2' sorry sites follow a pattern: 5 "elimination occurred" cases + 5 "no elimination" cases
- C4/C4' hard cases (lines 412, 510) require Lemma 2.6 splitting and BurgessR3 bridging
- G-value construction differs by elimination type:
  - **C5/C5'**: Capture B from Lemma 2.4 output, use `burgessR3Maximal_exists_from_seed`
  - **C4/C4'**: Use Lemma 2.6/2.7 outputs (B', D, B'') with D as f(z)
  - **Density**: Split existing g(x,y) using C3, no new c2' obligation

**Estimated Effort**: ~6 hours (requires Phase 2 and 3 completion)

---

## 1. Architecture Analysis of c2' Threading

### 1.1 Definition of c2' (Burgess C2')

From `ChronicleTypes.lean` (lines 372-374):

```lean
def Chronicle.c2' (χ : Chronicle) : Prop :=
  ∀ x y : Rat, Adjacent χ.dom x y →
    BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y)
```

**Interpretation**: For every adjacent pair (x,y) in the chronicle domain, the interval set g(x,y) must be a **maximal** DCS satisfying the Burgess r-relation with endpoints f(x) and f(y).

### 1.2 BurgessR3Maximal Definition

From `ChronicleTypes.lean` (lines 320-324):

```lean
def BurgessR3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B ∧
  burgessR3 A B C ∧
  ∀ D, SetDeductivelyClosed D → B ⊂ D → ¬burgessR3 A D C
```

Where `burgessR3 A B C` combines:
- `burgessRSet A B C`: ∀ β ∈ B, ∀ γ ∈ C, `untl β γ ∈ A`
- `burgessRSetSince C B A`: ∀ β ∈ B, ∀ α ∈ A, `snce β α ∈ C`

**Why c2' matters**: At the limit, the domain is dense (no adjacent pairs), so c2' becomes vacuously true. But at finite stages, c2' ensures:
1. Interval sets are as large as possible (maximality)
2. The C4 hard case can find γ.neg in an MCS extending g(w, w_next)
3. Lemma 2.5 absorption works for non-adjacent pairs

### 1.3 The 10 c2' Sorry Sites

From `CounterexampleElimination.lean`:

| Line | Elimination Type | Case | Strategy |
|------|-----------------|------|----------|
| 756 | C5_forward | Elimination occurred | Use Lemma 2.4 B, seed construction |
| 768 | C5_forward | No elimination | c2' preserved (trivial) |
| 794 | C5_backward | Elimination occurred | Use Lemma 2.4 mirror, seed construction |
| 806 | C5_backward | No elimination | c2' preserved (trivial) |
| 834 | C4_forward | Elimination occurred | **Hard case**: Lemma 2.6 splitting |
| 845 | C4_forward | No elimination | c2' preserved (trivial) |
| 872 | C4_backward | Elimination occurred | **Hard case**: Lemma 2.6 mirror |
| 883 | C4_backward | No elimination | c2' preserved (trivial) |
| 918 | Density | Elimination occurred | Split g(x,y) via C3 |
| 931 | Density | No elimination | c2' preserved (trivial) |

**Pattern**: 5 "elimination" cases (hard) + 5 "no elimination" cases (easy)

### 1.4 EliminationResult Structure

From `CounterexampleElimination.lean` (lines 693-722):

```lean
structure EliminationResult (χ : Chronicle) (pc : PotentialCounterexample) where
  val : Chronicle
  dom_sub : χ.dom ⊆ val.dom
  c0 : val.c0
  f_agrees : ∀ x ∈ χ.dom, val.f x = χ.f x
  g_agrees : ∀ a b, a ∈ χ.dom → b ∈ χ.dom → val.g a b = χ.g a b
  c2' : val.c2'  -- NEW FIELD requiring proof
  c5_forward_witness : ...
  c5_backward_witness : ...
  c4_forward_witness : ...
  c4_backward_witness : ...
  density_witness : ...
```

---

## 2. Burgess 1982 Reference (Sections 2.9, 2.10)

### 2.1 Chronicle Conditions C0-C5 (Burgess p. 372)

Burgess defines a chronicle as (f, g) satisfying:

- **C0**: f maps domain points to MCS
- **C0'**: Domain is finite
- **C1**: g maps pairs x < y to DCS
- **C2**: For x < y, r(f(x), g(x,y), f(y)) holds (three-argument r-relation)
- **C2'**: For adjacent x,y, R(f(x), g(x,y), f(y)) holds (R-maximality)
- **C3**: For x < y < z, g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) (three-way decomposition)
- **C4a**: If ¬U(γ,δ) ∈ f(x) and δ ∈ f(y) with x < y, ∃z with x < z < y and ¬γ ∈ f(z)
- **C5a**: If U(ξ,η) ∈ f(x), ∃y with x < y, ξ ∈ f(y), η ∈ g(x,y)

### 2.2 Section 2.9: C4 Counterexample Lemma (Burgess p. 374)

**Lemma 2.9** (C4 elimination): Given a counterexample to C4a, extend the chronicle to eliminate it.

**Proof Structure** (by induction on n = elements between x and y):

*Case n = 0* (x, y adjacent):
- By C2', have R(f(x), g(x,y), f(y))
- Apply **Lemma 2.6** to A = f(x), B = g(x,y), C = f(y) with δ ∉ B
- Obtain B', D, B'' with:
  - R(A, B', D), R(D, B'', C)
  - B = B' ∩ D ∩ B''
  - ¬δ ∈ D
- Set z = (x+y)/2, f'(z) = D, g'(x,z) = B', g'(z,y) = B''
- C3 determines other g' values

*Case n = m+1*:
- Let x' immediately succeed x
- If ¬U(γ,δ) ∈ f(x'), reduce to case n = m by replacing x with x'
- If U(γ,δ) ∈ f(x'), note δ ∈ f(x') (else not a counterexample)
- Let γ' = δ ∧ U(γ,δ) ∈ f(x')
- Using A3a: ¬U(γ',δ) ∈ f(x), reduce to case n = 0

**Key Insight**: The hard case uses **Lemma 2.6 splitting** of g(x,y) into B', D, B''.

### 2.3 Section 2.10: C5 Counterexample Lemma (Burgess p. 374-375)

**Lemma 2.10** (C5 elimination): Given a counterexample to C5a, extend the chronicle.

**Proof Structure**:

*Case n = 0* (no elements after x):
- Apply **Lemma 2.4** to A = f(x) with U(ξ,η) ∈ A
- Obtain B, C with R(A, B, C), η ∈ B, ξ ∈ C
- Set y = x+1, f'(y) = C, g'(x,y) = B

*Case n = m+1*:
- Let x' immediately succeed x
- Check if η ∧ U(ξ,η) ∈ f(x') and η ∈ g(x,x')
  - If yes: reduce to case n = m by replacing x with x'
- Check if ξ ∈ f(x') and η ∈ g(x,x')
  - If yes: x,ξ,η would not be a counterexample
- Otherwise: hypotheses of **Lemma 2.7** or **2.8** hold
- Apply Lemma 2.7/2.8 to get B', D, B''
- Set z = (x+x')/2, f'(z) = D, g'(x,z) = B', g'(z,x') = B''

**Key Insight**: Lemma 2.4 gives (B, C), Lemma 2.7/2.8 give splitting (B', D, B'').

---

## 3. G-Value Construction Plan

### 3.1 C5/C5' Elimination: Capture B from Lemma 2.4

**Lemma 2.4 Output** (`PointInsertion.lean`, line 150+):

Given MCS A with U(γ, β) ∈ A:
- Returns B (DCS), C (MCS) with:
  - R(A, B, C) (B is R-maximal)
  - β ∈ B
  - γ ∈ C

**G-Value Construction**:

```lean
-- After C5 elimination with new point y:
-- val.g x y = B from Lemma 2.4
-- val.f y = C from Lemma 2.4
-- c2' proof: Need to show BurgessR3Maximal (χ.f x) B C
```

**c2' Proof Strategy**:
1. From Lemma 2.4, we have R-maximality: `rMaximal (χ.f x) B`
2. Need to upgrade to `BurgessR3Maximal (χ.f x) B C`
3. Use `burgessR3Maximal_exists_from_seed` with:
   - η = β (the guard from Until)
   - h_burgessR: from rRelation + β ∈ B
   - h_burgessRSince: need to prove separately
   - h_η_A: β ∈ A (from Lemma 2.4 property)

**Issue**: Lemma 2.4 currently produces `RMaximal` not `BurgessR3Maximal`. Need to check if the construction already gives BurgessR3 or needs upgrade.

### 3.2 C4/C4' Hard Case: Use Lemma 2.6 Splitting

**Lemma 2.6 Output** (`PointInsertion.lean`, line ~2000+):

Given BurgessR3Maximal(A, B, C) and δ ∉ B:
- Returns B', D, B'' with:
  - BurgessR3Maximal(A, B', D)
  - BurgessR3Maximal(D, B'', C)
  - B = B' ∩ D ∩ B''
  - ¬δ ∈ D

**C4 Hard Case** (`CounterexampleElimination.lean`, line 412):

```lean
-- Context: w < w_next are adjacent in original domain
-- h_adj gives us c2' for (w, w_next): BurgessR3Maximal (χ.f w) (χ.g w w_next) (χ.f w_next)
-- Need to insert z between w and w_next with neg(γ) ∈ f(z)
-- Use Lemma 2.6 with:
--   A = χ.f w
--   B = χ.g w w_next
--   C = χ.f w_next
--   δ = γ (the guard we want to negate)
```

**G-Value Construction**:

```lean
-- After finding w, w_next with adjacent property:
have h_c2'_orig : BurgessR3Maximal (χ.f w) (χ.g w w_next) (χ.f w_next) := 
  χ.c2' w w_next h_adj

-- Apply Lemma 2.6
obtain ⟨B', D, B'', h_r3m_1, h_r3m_2, h_inter, h_neg_δ⟩ := 
  lemma_2_6_splitting h_c2'_orig h_γ_not_in_B

-- Construct new chronicle with:
--   f(z) = D
--   g(w, z) = B'
--   g(z, w_next) = B''
--   Other g values via C3
```

**c2' Proof for New Adjacent Pairs**:

After inserting z, we have new adjacent pairs:
- (w, z): `BurgessR3Maximal (χ.f w) B' D` ✓ (from h_r3m_1)
- (z, w_next): `BurgessR3Maximal D B'' (χ.f w_next)` ✓ (from h_r3m_2)

For original adjacent pairs that don't involve z:
- Use `g_agrees` property to show g-values unchanged
- Use original χ.c2' for those pairs

### 3.3 Density Elimination: Split via C3

**Density Case** (`CounterexampleElimination.lean`, line 918):

When x, y are adjacent and we insert z = (x+y)/2:

```lean
-- Before: g(x,y) with BurgessR3Maximal (χ.f x) (χ.g x y) (χ.f y)
-- After: need g(x,z) and g(z,y)
-- By C3: g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y)
-- Solution: set g(x,z) = g(x,y) and g(z,y) = g(x,y)
-- Then C3 requires: g(x,y) = g(x,y) ∩ f(z) ∩ g(x,y) = g(x,y) ∩ f(z)
-- This means g(x,y) ⊆ f(z) -- which may not hold!
```

**Correct Approach**:

For density insertion (breaking adjacency only, not solving a counterexample):

```lean
-- The new point z is not solving a specific counterexample
-- f(z) can be any MCS (we use χ.f x for simplicity)
-- For c2': there are NO new adjacent pairs!
--   (w, z) is not adjacent if ∃ point between them
--   (z, w_next) is not adjacent if ∃ point between them
-- Wait, that's wrong. After insertion:
--   - w < z < w_next
--   - (w, z) and (z, w_next) ARE adjacent in the new domain
--   - (w, w_next) is NOT adjacent anymore
```

**Revised Density Strategy**:

```lean
-- For density: x < y adjacent, insert z with x < z < y
-- New adjacent pairs: (x, z) and (z, y)
-- Old pair (x, y) is no longer adjacent
-- Need to construct g(x,z) and g(z,y) such that:
--   1. C3: g(x,y) = g(x,z) ∩ f(z) ∩ g(z,y)
--   2. c2': BurgessR3Maximal (f x) (g x z) (f z)
--           BurgessR3Maximal (f z) (g z y) (f y)

-- Strategy: Use the existing g(x,y) and apply Lemma 2.6 splitting
-- with δ chosen such that we can set g(x,z) = B', f(z) = D, g(z,y) = B''
```

Actually, for density, we don't have a δ constraint. The simplest approach:

```lean
-- Use any δ ∈ g(x,y) (or arbitrary δ)
-- Apply Lemma 2.6 to split g(x,y)
-- This gives us B', D, B'' with:
--   g(x,y) = B' ∩ D ∩ B''
--   BurgessR3Maximal (f x) B' D
--   BurgessR3Maximal D B'' (f y)
-- Set:
--   f(z) = D
--   g(x,z) = B'
--   g(z,y) = B''
-- C3 is satisfied by construction
```

---

## 4. Detailed Proof Obligations for Each c2' Site

### 4.1 C5_forward Elimination (Line 756)

**Context**:
- C5 counterexample eliminated using `eliminate_C5_counterexample`
- Returns χ' with new point y such that η ∈ f(y) and ξ ∈ g(x,y)

**Proof Obligation**:
```lean
c2' := by
  -- Need to prove: ∀ a b, Adjacent χ'.dom a b → BurgessR3Maximal (χ'.f a) (χ'.g a b) (χ'.f b)
  intro a b h_adj
  -- Case 1: neither a nor b is the new point y
  -- Then use original χ.c2' and g_agrees
  -- Case 2: (a, b) = (x, y) - the new adjacent pair
  -- Use properties from eliminate_C5_counterexample
  -- Need: BurgessR3Maximal (χ.f x) (χ'.g x y) (χ'.f y)
  sorry
```

**Missing Component**: The `eliminate_C5_counterexample` result needs to include BurgessR3Maximal for the new interval.

### 4.2 C5_forward No Elimination (Line 768)

**Proof**:
```lean
c2' := by
  -- χ' = χ (no change)
  -- So val.c2' = χ.c2' (given by h_c0, but actually need χ.c2')
  -- Wait, the structure doesn't have χ.c2', only χ.c0
  sorry
```

**Issue**: The chronicle structure doesn't currently carry c2' as a field. It's only in `ChronicleInvariant` and `ValidChronicle`. The `EliminationResult` has `c2'` as a field, but the input `χ` doesn't.

### 4.3 C4_forward Elimination (Line 834)

**Context**:
- C4 counterexample eliminated using `eliminate_C4_counterexample`
- Hard case requires Lemma 2.6 splitting

**Proof Obligation**:
```lean
c2' := by
  intro a b h_adj
  -- Check if the new adjacent pair involves the inserted point z
  -- For new pairs: use Lemma 2.6 output (BurgessR3Maximal for B', D, B'')
  -- For existing pairs: use χ.c2' and g_agrees
  sorry
```

### 4.4 Density Elimination (Line 918)

**Proof Obligation**:
```lean
c2' := by
  intro a b h_adj
  -- After inserting z between x and y:
  -- New adjacent pairs: (x, z) and (z, y)
  -- Need: BurgessR3Maximal (f x) (g x z) (f z)
  --       BurgessR3Maximal (f z) (g z y) (f y)
  -- Use Lemma 2.6 with arbitrary δ to split g(x,y)
  sorry
```

---

## 5. Helper Lemmas Needed

### 5.1 Core Lemmas from RRelation.lean

Already available:
- `burgessR3Maximal_exists_from_seed` (line 1164): Creates BurgessR3Maximal from seed element
- `burgessR3Maximal_extension_exists` (line ~900): Zorn's lemma extension

### 5.2 Lemma 2.6 Splitting (PointInsertion.lean)

**Required Lemma**:

```lean
theorem lemma_2_6_splitting {A B C : Set Formula}
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (δ : Formula)
    (h_δ_notin_B : δ ∉ B) :
    ∃ (B' D B'' : Set Formula),
      BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      B = B' ∩ D ∩ B'' ∧
      δ.neg ∈ D
```

**Status**: The `burgess_D0_seed_consistent` theorem (line 1971) and supporting infrastructure exists. The main proof is in progress but has sorry stubs.

### 5.3 Lemma 2.7 for C5/C5' (PointInsertion.lean)

**Required Lemma**:

```lean
theorem lemma_2_7 {A B C : Set Formula} (ξ η : Formula)
    (h_mcs_A : SetMaximalConsistent A)
    (h_mcs_C : SetMaximalConsistent C)
    (h_r3m : BurgessR3Maximal A B C)
    (h_until : Formula.untl ξ η ∈ A)
    (h_η_notin_B : η ∉ B) :
    ∃ (B' D B'' : Set Formula),
      BurgessR3Maximal A B' D ∧
      BurgessR3Maximal D B'' C ∧
      B = B' ∩ D ∩ B'' ∧
      η ∈ B' ∧ ξ ∈ D
```

**Status**: Documented in PointInsertion.lean as "Re-assessed as VALID (Phase 5, plan v27)". Proof not yet implemented.

### 5.4 C3 Propagation for New g-Values

**Required Lemma**:

```lean
theorem c3_new_g_values {χ : Chronicle} (h_c3 : χ.c3)
    {x y z : Rat} (hx : x ∈ χ.dom) (hy : y ∈ χ.dom)
    (hxy : x < y) (hz_notin : z ∉ χ.dom)
    (B' D B'' : Set Formula)
    (h_inter : χ.g x y = B' ∩ D ∩ B'') :
    let χ' := ⟨fun q => if q = z then D else χ.f q,
               fun a b => ... -- g with new values,
               insert z χ.dom⟩
    χ'.c3
```

**Status**: Need to define g for all pairs involving z and verify C3.

---

## 6. Complete Implementation Architecture

### 6.1 Phase 4 Implementation Order

```
Phase 4a: Helper Lemmas (2 hours)
  1. Complete Lemma 2.6 proof (currently has sorry at line 1858-1859)
  2. Prove Lemma 2.7 for C5/C5'
  3. Prove C3 propagation lemmas

Phase 4b: G-Value Construction (2 hours)
  1. Update eliminate_C5_counterexample to return BurgessR3Maximal
  2. Update eliminate_C4_counterexample hard case to use Lemma 2.6
  3. Update eliminate_C4'_counterexample hard case to use Lemma 2.6 mirror
  4. Update density case to use Lemma 2.6 with arbitrary δ

Phase 4c: c2' Proofs for All Sites (2 hours)
  1. C5_forward elimination (line 756)
  2. C5_forward no-elimination (line 768)
  3. C5_backward elimination (line 794)
  4. C5_backward no-elimination (line 806)
  5. C4_forward elimination (line 834)
  6. C4_forward no-elimination (line 845)
  7. C4_backward elimination (line 872)
  8. C4_backward no-elimination (line 883)
  9. Density elimination (line 918)
  10. Density no-elimination (line 931)
```

### 6.2 Dependencies

**Blocked on**:
- Phase 2: Lemma 2.6 completion (`burgess_D0_seed_consistent`)
- Phase 3: Lemma 2.7 completion

**Blocks**:
- Phase 5: Omega-chain construction (needs EliminationResult.c2')
- Phase 6: Limit construction (needs finite-stage c2')

### 6.3 G-Value Assignment Strategy

For each elimination type, the g-value construction is:

| Elimination | New Point | f(new) | g(left, new) | g(new, right) | c2' Source |
|-------------|-----------|--------|--------------|---------------|------------|
| C5_forward | y | C (from 2.4) | B (from 2.4) | extend via C3 | Lemma 2.4 output |
| C5_backward | y | C' (from 2.4') | B' (from 2.4') | extend via C3 | Lemma 2.4' output |
| C4_forward (hard) | z | D (from 2.6) | B' (from 2.6) | B'' (from 2.6) | Lemma 2.6 output |
| C4_backward (hard) | z | D' (from 2.6') | B' (from 2.6') | B'' (from 2.6') | Lemma 2.6' output |
| Density | z | D (from 2.6, arbitrary δ) | B' (from 2.6) | B'' (from 2.6) | Lemma 2.6 output |

---

## 7. Technical Challenges and Solutions

### 7.1 Challenge: Chronicle Type Doesn't Include c2'

**Problem**: The `Chronicle` structure only has f, g, dom. The c2' property is in `ChronicleInvariant`.

**Solution**: 
- The `EliminationResult` already includes `c2'` as a field
- Input chronicles should come with `ChronicleInvariant` which includes `hc2'`
- The elimination functions need to accept and return invariants

### 7.2 Challenge: Lemma 2.6 Has Sorry Stubs

**Problem**: `burgess_D0_seed_consistent` (line 1971) has sorry at lines 1858-1859:
```lean
have h_ev_b : DerivationTree [] (event.imp b) := sorry
have h_ev_untl : DerivationTree [] (event.imp (Formula.untl b γ_hat)) := sorry
```

**Solution**: 
- These require showing event → q where q = b ∧ untl(b, γ_hat)
- Use properties of the iterated enrichment construction
- May need additional BX axiom lemmas

### 7.3 Challenge: C3 Determination for New Pairs

**Problem**: When inserting point z, need to define g for ALL pairs involving z, not just immediate neighbors.

**Solution**:
- For w < z where w < x (left of left neighbor): 
  - C3 requires: g(w,z) = g(w,x) ∩ f(x) ∩ g(x,z)
  - Use original g(w,x) and new g(x,z)
- For z < w where y < w (right of right neighbor):
  - C3 requires: g(z,w) = g(z,y) ∩ f(y) ∩ g(y,w)
  - Use new g(z,y) and original g(y,w)

### 7.4 Challenge: No-Elimination c2' Preservation

**Problem**: Lines 768, 806, 845, 883, 931 need to show c2' is preserved when no elimination occurs.

**Solution**:
```lean
-- When no elimination: val = χ
-- So val.c2' = χ.c2'
-- But χ.c2' is not directly available (only in invariant)
-- Solution: Pass invariant as implicit argument
```

---

## 8. Verification Checklist

After Phase 4 implementation, verify:

- [ ] All 10 c2' sorry sites are closed
- [ ] Lemma 2.6 proof is complete (no sorry)
- [ ] Lemma 2.7 proof is complete (no sorry)
- [ ] C4 hard case at line 412 uses Lemma 2.6 correctly
- [ ] C4' hard case at line 510 uses Lemma 2.6 mirror correctly
- [ ] C3 is satisfied after all eliminations
- [ ] EliminationResult.c2' field is populated for all cases
- [ ] `lake build` succeeds without errors

---

## 9. References

1. **Burgess 1982**: "Axioms for Tense Logic II: Time Periods", Notre Dame Journal of Formal Logic
2. **Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean**: Chronicle structure and conditions
3. **Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean**: Elimination lemmas and sorry sites
4. **Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean**: Lemmas 2.4, 2.6, 2.7
5. **Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean**: BurgessR3Maximal and existence theorems

---

## 10. Summary

Phase 4 (c2' threading) is the **critical bridge** between:
- **Input**: Lemma 2.6/2.7 existence (Phases 2-3)
- **Output**: Omega-chain construction (Phase 5)

The 10 c2' sorry sites follow a clear pattern:
- 5 easy "no elimination" cases (c2' preservation)
- 5 hard "elimination" cases requiring g-value construction

**Key Insight**: Burgess's C2' (R-maximality for adjacent pairs) is exactly what's needed to:
1. Make the C4 hard case work (splitting g-values)
2. Ensure the omega-chain limit satisfies C2 (r-relation for all pairs)
3. Support the truth lemma via C3 (three-way decomposition)

**Estimated Timeline**: 6 hours after Phases 2-3 complete

**Risk Assessment**: Medium. The main risk is incomplete Lemma 2.6/2.7 proofs. If those lemmas can't be completed, the C4/C5 hard cases will need restructuring (potentially using different proof strategies or alternative lemmas).
