# Implementation Plan: Task #981 - Density Index Induction

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [PLANNED]
- **Effort**: 5-8 hours
- **Version**: 12
- **Dependencies**: Research report 26 (Approach D analysis)
- **Research Inputs**: reports/26_forward-f-termination-analysis.md
- **Artifacts**: plans/12_density-index-induction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the failing induction on formula depth `i` with induction on the **density index** `j` (the minimum j such that `pair(p.index, encode(F^j(phi))) > stage`). The key insight: after ONE `witness_at_large_step` application in the small-step case, ALL subsequent calls are guaranteed large steps.

## Current State

### Sorries to Fill
| File | Line | Theorem | Issue |
|------|------|---------|-------|
| DovetailedTimelineQuot.lean | 770 | `forward_F_chain_witness` succ j' case | IH requires `j'+i < i` (FALSE) |
| DovetailedTimelineQuot.lean | 839 | `backward_P_chain_witness` succ j' case | Symmetric issue |

### Why Current Approach Fails
The density index `j` depends on the build stage of `p`. When moving to witness `w` (at HIGHER stage), the new density index may be LARGER than before. Formula depth can INCREASE, not decrease, breaking simple induction on `i`.

### Why Approach D Works
After ONE application of `witness_at_large_step`, the witness `w` has:
- `w.point_index >= stage_of_w` (by `pointIndexInvariant`)
- `pair(w.index, k') >= w.index + k' > stage_of_w` for any encoding `k' >= 1`

This guarantees ALL subsequent calls are large steps, making `j` strictly decrease.

---

## Phase 1: Large Step Propagation Lemma [PARTIAL]

**Estimated effort**: 2 hours

**Objectives**:
1. Prove that witnesses obtained from `witness_at_large_step` have the large-step property for subsequent formulas
2. This is the key enabler for the density index induction

**File to modify**: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverage.lean`

**Lemma to add** (after `witness_at_large_step`, around line 269):

```lean
/--
Large step propagation: A witness obtained at stage m = pair(p.index, k)
satisfies the large-step condition for ANY subsequent formula encoding.
This enables termination of the density index induction.
-/
theorem witness_large_step_propagates
    (p : DovetailedPoint) (n : Nat)
    (hp : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs)
    (k : Nat) (h_dec : decodeFormulaStaged k = some phi)
    (h_large : Nat.pair p.point_index k > n)
    (w : DovetailedPoint)
    (hw_mem : w ∈ (dovetailedBuildState root_mcs root_mcs_proof (Nat.pair p.point_index k)).points)
    (hw_R : CanonicalR p.mcs w.mcs)
    (hw_phi : phi ∈ w.mcs) :
    ∀ psi k', decodeFormulaStaged k' = some psi → k' ≥ 1 →
      Nat.pair w.point_index k' > Nat.pair p.point_index k := by
  intro psi k' h_dec' h_k'_pos
  let m := Nat.pair p.point_index k
  -- By pointIndexInvariant, w.point_index = list.length - 1 at step m
  -- The list has grown by at least 1 at step m, so w.point_index >= m
  have h_w_idx : w.point_index ≥ m := sorry -- needs dovetailed build invariant
  have h_pair_ge := pair_ge_add w.point_index k'
  omega
```

**Proof Strategy**:
1. Need to prove `w.point_index >= m` where `m = Nat.pair p.point_index k`
2. This follows from `pointIndexInvariant` in DovetailedBuild.lean
3. May need an intermediate lemma: `dovetailed_build_list_length_le_step`

**Verification**:
- `lean_goal` at the sorry to check proof state
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedCoverage`

---

## Phase 2: Forward F by Density Index [NOT STARTED]

**Estimated effort**: 2.5 hours

**Objectives**:
1. Replace `forward_F_chain_witness` with `forward_F_by_density_index`
2. Use induction on `j` (density index) instead of `i` (formula depth)
3. Fill the sorry at line 770

**File to modify**: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

**Changes**:

### Step 2.1: Add the new core theorem (before line 624)

```lean
/--
Core witness theorem using induction on density index j.
If F^(j+1)(phi) ∈ p.mcs and the large-step condition holds for F^j(phi),
then we can find a witness with phi in its MCS.
-/
theorem forward_F_by_density_index (j : Nat) (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof)
    (phi : Formula)
    (h_F_succ : iteratedFuture (j + 1) phi ∈ p.mcs)
    (h_large : ∃ n, p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points ∧
               Nat.pair p.point_index (@Encodable.encode Formula formulaEncodableStaged
                 (iteratedFuture j phi)) > n) :
    ∃ q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof,
      CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs := by
  induction j using Nat.rec generalizing p with
  | zero =>
    -- j = 0: Large step for phi directly
    obtain ⟨n, hn, h_pair_large⟩ := h_large
    simp only [iteratedFuture] at h_F_succ h_pair_large
    obtain ⟨k, h_dec⟩ := formula_has_encoding phi
    obtain ⟨w, hw_mem, hw_R, hw_phi⟩ :=
      witness_at_large_step root_mcs root_mcs_proof p n
        (by simp [dovetailedBuild, List.mem_toFinset]; exact hn)
        phi h_F_succ k h_dec h_pair_large
    exact ⟨w, ⟨Nat.pair p.point_index k, by simp [dovetailedBuild, List.mem_toFinset]; exact hw_mem⟩, hw_R, hw_phi⟩
  | succ j' ih =>
    -- j = j'+1: Apply witness_at_large_step for F^j'(phi), then use IH
    obtain ⟨n, hn, h_pair_large⟩ := h_large
    simp only [dovetailedBuild, List.mem_toFinset] at hn
    -- F^(j'+1+1)(phi) = F(F^(j'+1)(phi)) ∈ p.mcs
    have h_F_j'_succ : Formula.some_future (iteratedFuture j' phi) ∈ p.mcs := by
      simp only [iteratedFuture] at h_F_succ ⊢
      -- iteratedFuture (j'+1+1) phi = F(F^(j'+1)(phi)) = F(iteratedFuture (j'+1) phi)
      sorry -- type manipulation
    -- Get encoding of F^j'(phi)
    obtain ⟨k, h_dec⟩ := formula_has_encoding (iteratedFuture j' phi)
    -- Apply witness_at_large_step
    obtain ⟨w, hw_mem, hw_R, hw_phi⟩ :=
      witness_at_large_step root_mcs root_mcs_proof p n hn
        (iteratedFuture j' phi) h_F_j'_succ k h_dec h_pair_large
    -- w has F^(j'+1)(phi) ∈ w.mcs
    have h_w_in_union : w ∈ dovetailedTimelineUnion root_mcs root_mcs_proof :=
      ⟨Nat.pair p.point_index k, by simp [dovetailedBuild, List.mem_toFinset]; exact hw_mem⟩
    -- By witness_large_step_propagates: next call has large step
    let m := Nat.pair p.point_index k
    obtain ⟨k', h_dec'⟩ := formula_has_encoding (iteratedFuture j' phi)
    have h_k'_pos : k' ≥ 1 := sorry -- encoding is positive
    have h_large_w : Nat.pair w.point_index k' > m :=
      witness_large_step_propagates root_mcs root_mcs_proof p n hn
        (iteratedFuture j' phi) h_F_j'_succ k h_dec h_pair_large
        w hw_mem hw_R hw_phi (iteratedFuture j' phi) k' h_dec' h_k'_pos
    -- Apply IH with j'
    have h_F_w : iteratedFuture (j' + 1) phi ∈ w.mcs := by
      -- hw_phi : iteratedFuture j' phi ∈ w.mcs
      -- Need: F(iteratedFuture j' phi) ∈ w.mcs
      -- But hw_phi IS iteratedFuture j' phi, not F(iteratedFuture j' phi)
      -- Correction: need to trace what witness_at_large_step gives us
      sorry
    obtain ⟨q, hq_mem, hq_R, hq_phi⟩ := ih w h_w_in_union phi h_F_w ⟨m, hw_mem, h_large_w⟩
    exact ⟨q, hq_mem, canonicalR_transitive p.mcs w.mcs q.mcs p.is_mcs hw_R hq_R, hq_phi⟩
```

### Step 2.2: Update forward_F_witness_in_timeline (line 848)

Replace the current implementation to use the new theorem:

```lean
theorem forward_F_witness_in_timeline (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs) :
    ∃ q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof,
      CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs := by
  obtain ⟨n, hn⟩ := hp
  simp only [dovetailedBuild, List.mem_toFinset] at hn
  obtain ⟨k, h_dec⟩ := formula_has_encoding phi
  by_cases h_large : Nat.pair p.point_index k > n
  · -- Large step: use forward_F_by_density_index with j = 0
    exact forward_F_by_density_index root_mcs root_mcs_proof 0 p hp phi h_F ⟨n, hn, h_large⟩
  · -- Small step: find j_min via density
    push_neg at h_large
    obtain ⟨j_min, h_enc_large⟩ := iterated_future_encoding_unbounded_general phi (n + 1)
    -- Use density: F^(j_min+1)(phi) ∈ p.mcs
    have h_density := density_iterate_in_mcs p.mcs p.is_mcs phi h_F j_min
    -- Large step for F^j_min(phi)
    have h_large' : Nat.pair p.point_index (@Encodable.encode Formula formulaEncodableStaged
        (iteratedFuture j_min phi)) > n := by
      have := pair_ge_add p.point_index (@Encodable.encode Formula formulaEncodableStaged
        (iteratedFuture j_min phi))
      omega
    exact forward_F_by_density_index root_mcs root_mcs_proof j_min p hp phi h_density ⟨n, hn, h_large'⟩
```

### Step 2.3: Delete or mark as superseded the old forward_F_chain_witness

**Verification**:
- `lean_goal` at each sorry to check proof state
- `lean_multi_attempt` to test tactic alternatives
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot`

---

## Phase 3: Backward P by Density Index [NOT STARTED]

**Estimated effort**: 1.5 hours

**Objectives**:
1. Apply the symmetric approach to `backward_P_chain_witness`
2. Fill the sorry at line 839

**File to modify**: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

**Changes**:

### Step 3.1: Add backward_witness_large_step_propagates to DovetailedCoverage.lean

Symmetric to `witness_large_step_propagates`.

### Step 3.2: Add backward_P_by_density_index

Mirror the structure of `forward_F_by_density_index` using `backward_witness_at_large_step`.

### Step 3.3: Update backward_P_witness_in_timeline

Same pattern as Step 2.2.

**Verification**:
- Same as Phase 2

---

## Phase 4: Cleanup and Final Verification [NOT STARTED]

**Estimated effort**: 1 hour

**Objectives**:
1. Remove deprecated code (old `forward_F_chain_witness`, `backward_P_chain_witness`)
2. Verify all sorries at lines 770, 839 are filled
3. Run full build to check for regressions

**Steps**:
1. Delete or comment out the old chain_witness theorems if not used elsewhere
2. Run `lake build` for full project
3. Check `#print axioms dovetailed_dense_completeness` (if exists)
4. Verify `discrete_Icc_finite_axiom` is NOT in axiom trace

**Verification**:
- `lake build` (full project)
- `grep -r "sorry" Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
- Only line 295 (DenselyOrdered case) should remain

---

## Dependencies

- Research report 26: Approach D analysis (completed)
- DovetailedBuild.lean: `pointIndexInvariant` (exists)
- DovetailedCoverage.lean: `witness_at_large_step` (exists)
- Dovetailing.lean: `pair_ge_add` (exists)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `w.point_index >= m` not provable from existing invariants | High | May need to strengthen `pointIndexInvariant` or add new build invariant |
| Type manipulation in density proofs complex | Medium | Use `lean_goal` extensively, break into helper lemmas |
| Encoding positivity (`k' >= 1`) not easily proved | Low | Add `formula_encoding_positive` lemma if needed |

## Success Criteria

- [ ] Line 770 sorry filled (forward_F_chain_witness succ j' case)
- [ ] Line 839 sorry filled (backward_P_chain_witness succ j' case)
- [ ] `lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot` succeeds
- [ ] No new sorries introduced
- [ ] Total sorries in DovetailedTimelineQuot.lean <= 1 (line 295 only)

## Rollback Plan

If Phase 1 (`witness_large_step_propagates`) cannot be proven:
1. Document the precise mathematical gap
2. Accept a well-identified sorry at that lemma
3. Proceed with Phases 2-4 using the sorry
4. Create a new task for proving the build invariant

---

## Testing & Validation Commands

```bash
# Phase 1
lake build Bimodal.Metalogic.StagedConstruction.DovetailedCoverage

# Phase 2-3
lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot

# Phase 4
lake build
grep -c "sorry" Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean
```

Expected final sorry count: 1 (line 295, DenselyOrdered intermediate case)
