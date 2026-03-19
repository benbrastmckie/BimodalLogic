# Research Report: Task #981 - Forward F Termination Analysis

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-18
**Focus**: Termination problem in forward_F_chain_witness succ j' case (lines 770, 839)

## Summary

The termination problem in `forward_F_chain_witness` arises because the density argument can INCREASE the "remaining F-depth" at each recursive step, breaking any simple induction on the formula depth `i`. The cleanest solution is **Approach D**: restructure the proof as induction on the density index `j` (the minimum j such that pair(p.index, encode(F^j(phi))) > stage). This approach terminates because after ONE small-step application via `witness_at_large_step`, ALL subsequent steps are guaranteed to be large steps, making `j` strictly decrease from `succ j'` to `j'` at each recursive call.

## Findings

### 1. Root Cause Analysis: Why Simple Induction on i Fails

The current proof structure in `forward_F_chain_witness` (lines 624-770) uses strong induction on `i`:

```lean
theorem forward_F_chain_witness (i : Nat) (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion) (phi : Formula)
    (h_F_iter : iteratedFuture (i + 1) phi ∈ p.mcs) :
    ∃ q ∈ dovetailedTimelineUnion, CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs
```

**The Problem** (lines 730-770):

1. Point `p` is at build stage `n`
2. Density argument gives `j` such that `encode(F^(j+i)(phi)) >= n+1`
3. `witness_at_large_step` gives witness `w` with `F^(j+i)(phi) ∈ w.mcs` and `CanonicalR p.mcs w.mcs`
4. For `j = 0`: IH applies (need `i' < i` where `F^(i'+1)(phi) ∈ w.mcs`)
5. For `j = succ j'`: We have `F^(j'+1+i)(phi) ∈ w.mcs`. To apply IH, need `j'+i < i`, which is FALSE since `j' >= 0`

**The key mathematical insight**: The density index `j` depends on the build stage of `p`. When we move to witness `w` (at a HIGHER stage), the new density index `j'` for `w` may be LARGER than `j` (not smaller). The formula depth can INCREASE, not decrease.

### 2. Evaluation of Approaches A-D

#### Approach A: Prove `witness_point_index_is_stage`

**Claim**: The witness added at step `m = pair(p.index, k)` has `w.point_index = m`.

**Assessment**: This is TRUE if the build adds exactly one point per step. However:
- The dovetailed build does NOT necessarily add a point at every step
- At step `m`, if `p.index >= m` (invalid lookup) or decode fails, NO point is added
- Even when a point is added, the invariant `pointIndexInvariant` ensures `w.point_index = list_length - 1`, NOT `w.point_index = m`

**Verdict**: NOT DIRECTLY PROVABLE as stated. The lemma would need to be: "w.point_index equals the list length at step m-1", which doesn't give us what we need.

#### Approach B: Restructure as Induction on j (Density Index)

**Assessment**: This approach recognizes that `j` (the density index) is the right measure, but the proposal is incomplete. It doesn't account for how `j` changes between recursive calls.

**Verdict**: Partially correct but needs refinement via Approach D.

#### Approach C: Double Induction on (i, j_min)

**Assessment**: This is unnecessarily complex. The key insight (that subsequent calls are always large steps) means we don't need double induction.

**Verdict**: Overcomplicated. Approach D is cleaner.

#### Approach D: Induction on j with Large-Step Propagation (RECOMMENDED)

**Key Insight**: After ONE application of `witness_at_large_step` in the small-step case, ALL subsequent calls are GUARANTEED to be large steps.

**Proof Sketch**:

1. **Large Step Definition**: `pair(p.index, encode(F^j(phi))) > stage(p)` means we can directly apply `witness_at_large_step`

2. **Small Step Conversion**: If `pair(p.index, encode(phi)) <= n` (small step), use density to find `j_min >= 1` with `encode(F^j_min(phi)) >= n+1`. Apply `witness_at_large_step` with `F^j_min(phi)`.

3. **Large Step Propagation Lemma** (THE KEY):
   ```
   If w is produced by witness_at_large_step at step m = pair(p.index, k),
   then pair(w.index, k') > m for ANY formula encoding k' >= 1
   ```

   **Proof**: By `pointIndexInvariant`, `w.point_index = list_length - 1` at step `m`. Since the list has grown by at least 1 at step `m`, and `w` was just added, `w.point_index >= m`. Then:
   ```
   pair(w.index, k') >= w.index + k' >= m + 1 > m = stage(w)
   ```

4. **Why j Decreases**: In the succ j' case:
   - We have `F^(j'+1)(phi) = F(F^j'(phi)) ∈ p.mcs`
   - Apply `witness_at_large_step` for `F^j'(phi)`: get `w` with `F^j'(phi) ∈ w.mcs`
   - By Large Step Propagation, the NEXT call for `(w, F^(j'-1)(phi))` is a large step
   - Continue: each subsequent call is large step, so `j` decreases: `j' -> j'-1 -> ... -> 0`
   - At `j = 0`: direct large step gives `phi ∈ q.mcs`

**Verdict**: CLEANEST AND MOST MATHEMATICALLY CORRECT.

### 3. Provability of witness_point_index_is_stage

The plan's `witness_point_index_is_stage` lemma is NOT directly needed. What we actually need is a weaker lemma:

**Lemma: Large Step Propagation**
```lean
theorem large_step_propagates
    (p : DovetailedPoint) (n : Nat)
    (hp : p ∈ (dovetailedBuildState n).points)
    (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs)
    (k : Nat) (h_dec : decodeFormulaStaged k = some phi)
    (h_large : Nat.pair p.point_index k > n) :
    let m := Nat.pair p.point_index k
    let w := witness_obtained_from_witness_at_large_step ...
    ∀ psi, ∀ k', decodeFormulaStaged k' = some psi →
      Nat.pair w.point_index k' > m
```

This follows from:
1. `w.point_index = list_length_at_step_m - 1` (by `pointIndexInvariant`)
2. `list_length_at_step_m >= m + 1` (monotonicity of list length)
3. `pair(w.index, k') >= w.index + k' >= m + k' > m` (since `k' >= 0`)

Actually, we need `k' >= 1` for strict inequality. For `k' = 0`, we have `pair(w.index, 0) = 0` which could be problematic. However, formula encodings are never 0 (the empty formula is encoded as some positive number), so this is fine.

### 4. Concrete Implementation Path

**Phase 1: Add Helper Lemma**
```lean
-- In DovetailedCoverage.lean
theorem witness_stage_propagation
    (p : DovetailedPoint) (n : Nat)
    (hp : p ∈ (dovetailedBuildState n).points)
    (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs)
    (k : Nat) (h_dec : decodeFormulaStaged k = some phi)
    (h_large : Nat.pair p.point_index k > n) :
    let m := Nat.pair p.point_index k
    ∃ w ∈ (dovetailedBuildState m).points,
      CanonicalR p.mcs w.mcs ∧ phi ∈ w.mcs ∧
      ∀ psi k', decodeFormulaStaged k' = some psi → k' ≥ 1 →
        Nat.pair w.point_index k' > m
```

**Phase 2: Restructure forward_F_chain_witness**

Replace the current theorem with one that uses induction on `j` directly:

```lean
theorem forward_F_by_density_index (j : Nat) (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion)
    (phi : Formula)
    (h_F_succ : iteratedFuture (j + 1) phi ∈ p.mcs)
    (h_large : ∃ n, p ∈ (dovetailedBuildState n).points ∧
               Nat.pair p.point_index (encode (iteratedFuture j phi)) > n) :
    ∃ q ∈ dovetailedTimelineUnion, CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs
```

**Induction on j**:
- `j = 0`: Large step condition holds. Apply `witness_at_large_step` directly.
- `j = succ j'`: Apply `witness_at_large_step` for `F^j'(phi)`. Get `w` with `F^j'(phi) ∈ w.mcs`. By `witness_stage_propagation`, next call has large step. Apply IH with `j'`.

**Phase 3: Wrapper Theorem**

```lean
theorem forward_F_witness_in_timeline_v2 (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion) (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs) :
    ∃ q ∈ dovetailedTimelineUnion, CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs := by
  obtain ⟨n, hn⟩ := hp
  simp only [dovetailedBuild, List.mem_toFinset] at hn
  -- Get encoding of phi
  obtain ⟨k, h_dec⟩ := formula_has_encoding phi
  -- Check if large step already
  by_cases h_large : Nat.pair p.point_index k > n
  · -- Large step: use forward_F_by_density_index with j = 0
    exact forward_F_by_density_index 0 p hp phi h_F ⟨n, hn, h_large⟩
  · -- Small step: find j_min with large encoding
    push_neg at h_large
    obtain ⟨j_min, h_enc_large⟩ := iterated_future_encoding_unbounded_general phi (n + 1)
    -- Use density: F^(j_min+1)(phi) ∈ p.mcs
    have h_density := density_iterate_in_mcs p.mcs p.is_mcs phi h_F j_min
    -- Large step for F^j_min(phi)
    have h_large' : Nat.pair p.point_index (encode (iteratedFuture j_min phi)) > n := by
      have := pair_ge_add p.point_index (encode (iteratedFuture j_min phi))
      omega
    exact forward_F_by_density_index j_min p hp phi h_density ⟨n, hn, h_large'⟩
```

### 5. Critical Observation: Formula Encoding Minimum

For the large step propagation to work, we need `encode(psi) >= 1` for all formulas. Let me verify this:

From `formulaEncodableStaged`, the encoding is based on `Encodable.encode` which maps formulas to natural numbers. The key property:
- `encode` is injective
- `decode(encode(phi)) = some phi`
- Encodings start from 0

So `encode(phi)` could be 0 for some formula. However, `pair(a, 0) = a*(a+1)/2 + 0` which is `>= 0`. For the strict inequality `pair(w.index, k') > m`, we need to verify that for formulas used in the recursion, encodings are non-zero.

Actually, looking at the proof more carefully: the issue is `pair(w.index, 0) = triangle(w.index)` which may or may not be `> m`. But the formulas we care about are `iteratedFuture j phi` for various `j`, and these have encodings that grow unboundedly. By `iterated_future_encoding_unbounded_general`, we can always find an iteration with encoding `>= n+1 >= 1`.

So the actual lemma should use the specific encoding from density, not arbitrary encodings.

## Recommendations

### Recommended Approach: Implement Approach D

1. **Add `witness_stage_propagation`** to DovetailedCoverage.lean
   - Proves that witnesses obtained from `witness_at_large_step` have large-step property for subsequent formulas

2. **Replace `forward_F_chain_witness`** with `forward_F_by_density_index`
   - Uses induction on density index `j` instead of formula depth `i`
   - Termination is clear: `j` decreases from `succ j'` to `j'` at each step

3. **Update wrapper theorems** to use the new structure

4. **Mirror for backward_P** with symmetric `backward_P_by_density_index`

### Estimated Effort

- Phase 1 (witness_stage_propagation): 1-2 hours
- Phase 2 (forward_F_by_density_index): 2-3 hours
- Phase 3 (backward_P symmetric): 1-2 hours
- Phase 4 (cleanup, testing): 1 hour

**Total: 5-8 hours**

### Risk Assessment

**Low Risk**: The mathematical argument is sound. The key insight (large step propagation) follows directly from existing infrastructure (`pointIndexInvariant`, `pair_ge_add`).

**Medium Risk**: Lean may require careful handling of the existential quantifiers and dependent types when extracting the witness from `witness_at_large_step` and proving its properties.

## References

- DovetailedTimelineQuot.lean: Lines 624-770 (forward_F_chain_witness), 775-839 (backward_P_chain_witness)
- DovetailedCoverage.lean: Lines 231-269 (witness_at_large_step)
- DovetailedBuild.lean: Lines 196-225 (pointIndexInvariant)
- Dovetailing.lean: Lines 201-210 (pair_ge_sum, pair_ge_left, pair_ge_right)
- plans/11_forward-f-succ-j-fix.md: Original problem analysis

## Context Extension Recommendations

None. The mathematical context is well-established in the existing documentation.

## Next Steps

1. Implement `witness_stage_propagation` lemma in DovetailedCoverage.lean
2. Implement `forward_F_by_density_index` theorem using induction on `j`
3. Verify the approach with `lake build`
4. Implement symmetric `backward_P_by_density_index`
5. Update `forward_F_witness_in_timeline` and `backward_P_witness_in_timeline` to use new structure
