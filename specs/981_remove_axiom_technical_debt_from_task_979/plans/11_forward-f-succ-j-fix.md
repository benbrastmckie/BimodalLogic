# Implementation Plan: Task #981 - Fix forward_F succ-j' Sorry

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [IN PROGRESS]
- **Effort**: 4-6 hours
- **Dependencies**: Plan v10 partial work (677 lines added to DovetailedTimelineQuot.lean)
- **Research Inputs**: Deep analysis of forward_F_chain_witness termination problem (this document)
- **Artifacts**: plans/11_forward-f-succ-j-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Current State (After Plan v10 Partial Implementation)

### What Was Accomplished in Plan v10

- **Phase 1 DONE**: `iterated_future_encoding_unbounded_general` added to DovetailedCoverage.lean (line 133)
- **677 lines added** to DovetailedTimelineQuot.lean including:
  - `dovetailedTimelineQuot_lt_implies_canonicalR` (DONE, sorry-free)
  - `dovetailedTimelineQuot_forward_G`, `backward_H` (DONE, sorry-free)
  - `forward_F_chain_witness` (line 624) - **HAS SORRY at line 770 (succ j' case)**
  - `backward_P_chain_witness` (line 775) - **HAS SORRY at line 839 (succ j' case)**
  - `forward_F_witness_in_timeline` (line 848) - wraps forward_F_chain_witness
  - `backward_P_witness_in_timeline` (line 861) - wraps backward_P_chain_witness
  - `dovetailedTimelineQuotFMCS_forward_F` (line 882) - DONE if helper is sorry-free
  - `dovetailedTimelineQuotFMCS_backward_P` (line 1038) - DONE if helper is sorry-free

### Remaining Sorries in DovetailedTimelineQuot.lean (3 total)
- Line 295: DenselyOrdered intermediate case (pre-existing from original file)
- Line 770: `forward_F_chain_witness` succ j' case ← **PRIMARY BLOCKER**
- Line 839: `backward_P_chain_witness` succ j' case ← **PRIMARY BLOCKER**

## The Mathematical Problem

### What `forward_F_chain_witness` Proves

```
theorem forward_F_chain_witness (i : Nat) (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion) (phi : Formula)
    (h_F_iter : iteratedFuture (i + 1) phi ∈ p.mcs) :
    ∃ q ∈ dovetailedTimelineUnion, CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs
```

Proved by strong induction on `i`. The density argument gives `j` such that:
- `encode(iteratedFuture j (iteratedFuture i phi)) >= n+1`
- `witness_at_large_step` gives `w` with `iteratedFuture (j+i) phi ∈ w.mcs`

The SORRY at `| succ j' =>` occurs when `j = j'+1 ≥ 1`:
- We have `w` with `iteratedFuture (j'+1+i) phi ∈ w.mcs` and `CanonicalR p.mcs w.mcs`
- We need `q` with `CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs`
- A recursive call `forward_F_chain_witness (j'+i) w hw phi h'` would give this BUT
  requires `j'+i < i` (for valid IH call), which is FALSE when `j' ≥ 0`

### Why Simple Induction on `i` Fails

The density argument computes `j` based on the BUILD STAGE `n` of `p`. When recursing to `w`
(at stage `pair(p.index, k') >> n`), the new density argument might give `j'' >> j`, so the
"remaining F-depth" can INCREASE at each recursive step. This breaks any simple measure.

### Key Mathematical Insight: Large Step Guarantee After First Step

After the first application of `witness_at_large_step`, the witness `w` has:
- `w` added at stage `n_w = pair(p.index, encode(F^j(phi)))` where `j ≥ 1`
- `w.index` = position of `w` in the build list at step `n_w`

The CRITICAL CLAIM: `pair(w.index, encode(F^(j-1)(phi))) > n_w`

**Proof**: `pair(w.index, encode(F^(j-1)(phi))) ≥ w.index + encode(F^(j-1)(phi))`
(from `pair_ge_add`). If `w.index ≥ n_w` then this exceeds `n_w` since
`encode(F^(j-1)(phi)) ≥ 1`.

The COMPLICATION: we need `w.index ≥ n_w`, but we can only guarantee `w.index ≤ n_w`
(since the list has at most `n_w + 1` elements by step `n_w`).

**NEEDED LEMMA**: `witness_at_large_step_index_is_stage`: If `w` is added by
`witness_at_large_step` at step `n_w`, then `w.point_index = n_w` (or at least `≥ n_w`).

This holds IF the dovetailed build adds a new point at **every** step from `0` to `n_w - 1`
(so the list at step `n_w` has exactly `n_w + 1` elements, and `w.index = n_w`).

## Proposed Fix

### Approach A: Prove `witness_point_index_is_stage` (Recommended)

Prove that the dovetailed build adds a forward or backward witness at EVERY step.

In the dense logic, every MCS contains `F(neg bot)` (seriality axiom) and by density,
`F(F(neg bot)), F(F(F(neg bot))), ...` The dovetailed build processes these at each step.
Since there's always a formula to witness, every step adds a witness.

**New Lemma** to add to DovetailedBuild.lean or DovetailedCoverage.lean:
```lean
theorem dovetailed_build_adds_point_every_step (m : Nat) :
    (dovetailedBuildState root_mcs root_mcs_proof (m + 1)).points.length =
    (dovetailedBuildState root_mcs root_mcs_proof m).points.length + 1 := by
  -- At step m = pair(i, k), the point at index i (if exists) has some F(phi) in MCS
  -- (by density: F(neg bot) ∈ every MCS, and the enumeration covers all formulas)
  -- The forward witness is ALWAYS addable.
  sorry
```

If this holds, then `w.index = n_w` (the witness added at step `n_w` is at position `n_w`)
and the LARGE STEP condition for subsequent calls is guaranteed:
```
pair(w.index, encode(F^(j-1)(phi))) = pair(n_w, encode(F^(j-1)(phi)))
    ≥ n_w + encode(F^(j-1)(phi)) ≥ n_w + 1 > n_w = stage_of_w
```

**Then the succ j' sorry is filled by**:
```lean
| succ j' =>
  -- Get encoding of F^(j'+i)(phi)
  obtain ⟨k_next, h_dec_next⟩ := formula_has_encoding (iteratedFuture (j' + i) phi)
  -- F^(j'+1+i)(phi) = F(F^(j'+i)(phi)) ∈ w.mcs (from hw_phi)
  have h_F_next : Formula.some_future (iteratedFuture (j' + i) phi) ∈ w.mcs := by
    simp only [iteratedFuture] at hw_phi; exact hw_phi
  -- w is at stage n_w = pair(p.index, k')
  obtain ⟨n_w, hw_in_stage⟩ := h_w_in_union
  simp only [dovetailedBuild, List.mem_toFinset] at hw_in_stage
  -- By witness_point_index_is_stage: pair(w.index, encode(F^(j'+i)(phi))) > n_w
  have h_large_w : Nat.pair w.point_index k_next > n_w := by
    have h_w_idx : w.point_index = n_w := witness_point_index_is_stage ...
    rw [h_w_idx]
    have h_enc_pos : k_next ≥ 1 := ... -- encode is ≥ 1 for non-trivial formulas
    omega
  -- Apply witness_at_large_step to w
  obtain ⟨v, hv_mem, hv_R, hv_phi⟩ :=
    witness_at_large_step root_mcs root_mcs_proof w n_w hw_in_stage
      (iteratedFuture (j' + i) phi) h_F_next k_next h_dec_next h_large_w
  -- Chain: CanonicalR p.mcs w.mcs ∧ CanonicalR w.mcs v.mcs → CanonicalR p.mcs v.mcs
  have hv_in_union : v ∈ dovetailedTimelineUnion root_mcs root_mcs_proof :=
    ⟨Nat.pair w.point_index k_next, by simp [dovetailedBuild, List.mem_toFinset]; exact hv_mem⟩
  have h_chain := canonicalR_transitive p.mcs w.mcs v.mcs p.is_mcs hw_R hv_R
  -- Now recurse: F^(j'+i)(phi) ∈ v.mcs
  -- Since v.index = pair(w.index, k_next) = pair(n_w, k_next) >> n_w, next step is large
  -- Apply ih with m = j'+i < ... STILL ISSUE with ih constraint
  ...
```

**THE REMAINING ISSUE**: Even with `witness_point_index_is_stage`, the recursive call to get
from `F^(j'+i)(phi) ∈ v.mcs` to `phi ∈ q.mcs` still requires `j'+i` more applications, each
needing the IH. Strong induction on `i` doesn't help here since `j'+i ≥ i`.

### Approach B: Restructure as Induction on j (The Density Index)

**RECOMMENDED FIX**: Replace strong induction on `i` with induction on the DENSITY INDEX `j`.

**New theorem** `forward_F_unwind`:
```lean
-- Reduce F^(j+1)(phi) membership to phi membership via j-step chain
theorem forward_F_unwind (j : Nat) (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion) (phi : Formula)
    (h_iter : iteratedFuture (j + 1) phi ∈ p.mcs) :
    ∃ q ∈ dovetailedTimelineUnion, CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs
```

Proved by induction on `j` using `witness_point_index_is_stage`:
- `j = 0`: F(phi) ∈ p.mcs. Get encoding k of phi. Case split:
  - Large step (pair(p.index, k) > n): `witness_at_large_step`. Get w with phi ∈ w.mcs. Done!
  - Small step: Use density to find j₁ with encode(F^j₁(phi)) > n+1. Since j₁ ≥ 1 (small step):
    Apply `witness_at_large_step` with F^(j₁)(phi) as phi_arg: get w with F^j₁(phi) ∈ w.mcs.
    Now w.index = n_w (by `witness_point_index_is_stage`).
    The NEXT application is LARGE STEP for (w, F^(j₁-1)(phi)):
    `pair(w.index, encode(F^(j₁-1)(phi))) = pair(n_w, encode(F^(j₁-1)(phi))) > n_w`.
    Apply `witness_at_large_step` again: get v with F^(j₁-1)(phi) ∈ v.mcs.
    Repeat j₁ times... each is large step after the first.
    TERMINATES in j₁ steps by induction on j₁.
  - **STILL CIRCULAR**: the small step case for j=0 still needs j₁ recursive calls
    with VARYING j₁. This is why we need induction on j₁ (the density index), not on j.

### Approach C: Double Induction on (i, j_min) [RECOMMENDED]

Use a DOUBLE INDUCTION or a single induction on `i + j_min` where `j_min` is the
MINIMUM density index (the minimum j such that encode(F^j(phi)) > n).

Key: in the small step case, `j_min ≥ 1`. After applying `witness_at_large_step` with
F^(j_min)(phi), we get w at stage n_w with F^(j_min)(phi) ∈ w.mcs. The NEXT CALL's
j_min' satisfies:

**Claim**: j_min' = 0 (large step) for the call `(w, F^(j_min-1)(phi))`.

**Proof**: pair(w.index, encode(F^(j_min-1)(phi))) > n_w = pair(p.index, encode(F^(j_min)(phi)))
⟺ pair(w.index, encode(F^(j_min-1)(phi))) > pair(p.index, encode(F^(j_min)(phi)))

Using `witness_point_index_is_stage`: w.index = n_w = pair(p.index, encode(F^(j_min)(phi))).
Then pair(w.index, encode(F^(j_min-1)(phi))) ≥ w.index + encode(F^(j_min-1)(phi))
= pair(p.index, encode(F^(j_min)(phi))) + encode(F^(j_min-1)(phi)) > stage_of_w. ✓

So after ONE small-step application, the NEXT is always a LARGE STEP!

This means the recursion is: small step (j_min-1 large steps to unwind F^(j_min) to phi).
TOTAL: 1 + j_min calls. Terminates in j_min + 1 steps. **j_min DECREASES** is the measure.

Actually, the correct INDUCTION MEASURE is j_min itself:
- j_min = 0: large step, direct.
- j_min = succ j': after getting w with F^(succ j')(phi) ∈ w.mcs, the NEXT call has j_min' = 0.
  Apply witness_at_large_step to w for F^j'(phi): get v with F^j'(phi) ∈ v.mcs.
  Then recurse: the call for (v, phi) has j_min'' = 0 (large step). Direct!

  Wait, this still requires j_min to go from succ j' to 0, not to j'. So j_min strictly decreases
  only if every subsequent call is a large step (j_min' = 0), meaning the recursion is exactly 2 steps.

### Approach D: Induction on j_min with `witness_point_index_is_stage` [CLEANEST]

**Theorem `forward_F_by_jmin`** (the core theorem):
```lean
-- Prove: if F^(j+1)(phi) ∈ p.mcs and pair(p.index, encode(F^j(phi))) > n,
--         then ∃ q with CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs
-- This covers BOTH large step (j = 0) and chain-from-large-step (j ≥ 1)
-- Induction on j
```

Induction on j:
- j = 0: pair(p.index, encode(phi)) > n. Apply witness_at_large_step with phi directly. DONE!
- j = succ j':
  - F^(succ j'+1)(phi) = F(F^(succ j')(phi)) ∈ p.mcs
  - pair(p.index, encode(F^(succ j')(phi))) > n (hypothesis)
  - Apply witness_at_large_step for F^(succ j')(phi): get w with F^(succ j')(phi) ∈ w.mcs.
  - By `witness_point_index_is_stage`: w.index = stage_of_w = pair(p.index, encode(F^(succ j')(phi))).
  - Now: pair(w.index, encode(F^j'(phi))) = pair(stage_of_w, encode(F^j'(phi))) > stage_of_w.
    (Since encode(F^j'(phi)) ≥ 1 and pair(a, b) ≥ a + b.)
  - So pair(w.index, encode(F^j'(phi))) > stage_of_w = stage condition for w.
  - Apply IH with j = j' to (w, phi):
    - IH says: F^(j'+1)(phi) ∈ w.mcs ∧ pair(w.index, encode(F^j'(phi))) > stage_of_w
      → ∃ q with CanonicalR w.mcs q.mcs ∧ phi ∈ q.mcs
    - F^(j'+1)(phi) = F^(succ j')(phi) ∈ w.mcs ✓ (from witness_at_large_step)
    - pair(w.index, encode(F^j'(phi))) > stage_of_w ✓ (shown above)
    - Get q with CanonicalR w.mcs q.mcs ∧ phi ∈ q.mcs.
  - Chain: CanonicalR p.mcs w.mcs ∧ CanonicalR w.mcs q.mcs → CanonicalR p.mcs q.mcs. DONE!

**This is a valid induction on j!** j strictly decreases from succ j' to j'.

## Implementation Phases

### Phase 0: Verify `witness_point_index_is_stage` [NOT STARTED]

Check if the dovetailed build adds a point at every step. If TRUE, prove:
```lean
theorem witness_point_index_is_stage
    (p : DovetailedPoint) (n : Nat)
    (hn : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs)
    (k : Nat) (h_dec : decodeFormulaStaged k = some phi)
    (h_large : Nat.pair p.point_index k > n) :
    let m := Nat.pair p.point_index k
    ∃ w, w ∈ (dovetailedBuildState root_mcs root_mcs_proof m).points ∧
         CanonicalR p.mcs w.mcs ∧ phi ∈ w.mcs ∧
         w.point_index = (dovetailedBuildState root_mcs root_mcs_proof m).points.length - 1
```

This says the witness added at step m gets index = length-1 of the build list at step m.

**File**: `DovetailedBuild.lean` (or a new `DovetailedBuildInvariants.lean`)

**Alternative**: If this lemma is hard to prove, check if `Nat.pair p.point_index k ≥ ...`
type inequalities suffice without the exact equality.

**Timing**: 1 hour

---

### Phase 1: Prove `forward_F_by_jmin` [NOT STARTED]

Add a new theorem BEFORE `forward_F_chain_witness` that uses induction on j:

```lean
-- In DovetailedTimelineQuot.lean, before forward_F_chain_witness
theorem forward_F_by_jmin (j : Nat) (p : DovetailedPoint)
    (hp_stage : ∃ n, p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points)
    (phi : Formula)
    (h_F_succ : iteratedFuture (j + 1) phi ∈ p.mcs)
    (h_large : ∃ n, p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points ∧
               Nat.pair p.point_index (@Encodable.encode Formula formulaEncodableStaged
                 (iteratedFuture j phi)) > n) :
    ∃ q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof,
      CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs := by
  induction j using Nat.strong_induction_on generalizing p with
  | _ j ih =>
    obtain ⟨n, hn, h_pair_large⟩ := h_large
    simp only [dovetailedBuild, List.mem_toFinset] at hn
    obtain ⟨k, h_dec⟩ := formula_has_encoding (iteratedFuture j phi)
    cases j with
    | zero =>
      -- j = 0: pair(p.index, encode(phi)) > n (large step)
      simp only [iteratedFuture] at h_F_succ h_pair_large h_dec
      obtain ⟨w, hw_mem, hw_R, hw_phi⟩ :=
        witness_at_large_step root_mcs root_mcs_proof p n hn phi h_F_succ k h_dec h_pair_large
      exact ⟨w, ⟨k, by simp [dovetailedBuild, List.mem_toFinset]; exact hw_mem⟩, hw_R, hw_phi⟩
    | succ j' =>
      -- j = j'+1: get w with iteratedFuture (j'+1) phi ∈ w.mcs
      -- Apply witness_at_large_step for iteratedFuture (j'+1) phi
      have h_F_j_succ : Formula.some_future (iteratedFuture j' phi) ∈ p.mcs := by
        simp only [iteratedFuture] at h_F_succ ⊢; exact h_F_succ
      obtain ⟨w, hw_mem, hw_R, hw_phi⟩ :=
        witness_at_large_step root_mcs root_mcs_proof p n hn
          (iteratedFuture j' phi) h_F_j_succ k h_dec h_pair_large
      -- w has iteratedFuture (j'+1) phi ∈ w.mcs (= F(F^j'(phi)) ∈ w.mcs)
      -- By witness_point_index_is_stage: w.point_index = n_w = pair(p.index, encode(F^j'(phi)))
      let n_w := Nat.pair p.point_index k
      have hw_in_union : w ∈ dovetailedTimelineUnion root_mcs root_mcs_proof :=
        ⟨n_w, by simp [dovetailedBuild, List.mem_toFinset]; exact hw_mem⟩
      have hw_index : w.point_index = n_w := witness_point_index_is_stage ...
      -- Compute encoding of iteratedFuture j' phi
      obtain ⟨k', h_dec'⟩ := formula_has_encoding (iteratedFuture j' phi)
      -- pair(w.index, encode(F^(j')(phi))) > n_w
      have h_large_w : Nat.pair w.point_index k' > n_w := by
        rw [hw_index]
        have h_enc_pos : k' ≥ 1 := ... -- encoding of any formula ≥ 1 (or ≥ 0 + pair > pair)
        have := pair_ge_add n_w k'
        omega
      -- Apply IH with j = j' < j'+1 = j
      obtain ⟨q, hq_mem, hq_R, hq_phi⟩ :=
        ih j' (Nat.lt_succ_self j') w ⟨n_w, hw_mem⟩ phi hw_phi
          ⟨n_w, hw_mem, h_large_w⟩
      exact ⟨q, hq_mem, canonicalR_transitive p.mcs w.mcs q.mcs p.is_mcs hw_R hq_R, hq_phi⟩
```

**File**: `DovetailedTimelineQuot.lean` (replace forward_F_chain_witness)

**Timing**: 2 hours

---

### Phase 2: Replace `forward_F_chain_witness` sorries [NOT STARTED]

Once `forward_F_by_jmin` is proved:

1. Fix `forward_F_chain_witness` succ j' case (line 770):
   - Use `forward_F_by_jmin` with j = j'+1+i, applied to w with large step condition
   - Then chain with ih using the index argument

2. Alternatively: Delete `forward_F_chain_witness` and replace `forward_F_witness_in_timeline`
   to use `forward_F_by_jmin` directly:
   ```lean
   theorem forward_F_witness_in_timeline (p) (hp) (phi) (h_F) :=
     -- Choose jmin = minimum j with encode(F^j(phi)) > n
     let jmin := Nat.find (iterated_future_encoding_unbounded_general phi (n + 1))
     forward_F_by_jmin jmin p hp phi h_F_succ h_large
   ```

**Timing**: 1 hour

---

### Phase 3: Symmetric backward_P fix [NOT STARTED]

Mirror Phase 1-2 for:
- `backward_P_chain_witness` succ j' sorry (line 839)
- `backward_P_witness_in_timeline`
- Symmetric `backward_F_by_jmin` or reuse the forward structure

**Timing**: 1 hour

---

### Phase 4: Verify and complete Phases 4-5 of plan v10 [NOT STARTED]

Once sorries at 770 and 839 are filled:

1. **TemporalCoherentFamily and BFMCS** (plan v10 Phase 4):
   - Build singleton BFMCS over DovetailedTimelineQuot
   - Prove modal_backward for singleton BFMCS

2. **Fill completeness sorry** (plan v10 Phase 5):
   - Fill `timelineQuot_not_valid_of_neg_consistent` or fill `dovetailed_dense_completeness`
   - Use parametric truth lemma with the new BFMCS

**Timing**: 2 hours

---

## Key Files and Current State

| File | Current State | Plan Action |
|------|---------------|-------------|
| `DovetailedCoverage.lean` | Has `iterated_future_encoding_unbounded_general` | Add new `density_future_iterate` alias if needed |
| `DovetailedBuild.lean` | Existing | Add `witness_point_index_is_stage` (Phase 0) |
| `DovetailedTimelineQuot.lean` | 1157 lines, 2 key sorries (770, 839) | Replace with `forward_F_by_jmin` approach |
| `DovetailedFMCS.lean` | Sorry-free | Extend with TemporalCoherentFamily in Phase 4 |
| `TimelineQuotCompleteness.lean` | Has sorry at line 127 | Fill in Phase 4 or use DovetailedCompleteness |

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot` (no sorries at 770/839)
- [ ] `lake build Bimodal.Metalogic.StagedConstruction.DovetailedCompleteness` (sorry-free)
- [ ] `#print axioms dovetailed_dense_completeness` shows only standard axioms
- [ ] `discrete_Icc_finite_axiom` NOT in axiom trace

## Critical Risk: `witness_point_index_is_stage`

The entire approach depends on being able to prove that the witness added by
`witness_at_large_step` at step `m = pair(p.index, k)` gets `point_index = m`
(or at least `point_index ≥ m`).

This requires that the dovetailed build has added exactly `m` new points before step `m`.
For the DENSE case (with DN axiom), every MCS has F-formulas, so every step SHOULD add a
forward witness. But proving this in Lean may require examining the build state invariants
more carefully.

**If this lemma is too hard to prove**: Consider accepting a sorry at this lemma and marking
it as a well-identified mathematical gap (not an axiom).

## Rollback/Contingency

If Phase 0 (`witness_point_index_is_stage`) is unprovable:
1. Accept the sorries in `forward_F_chain_witness` and `backward_P_chain_witness`
2. Document them as open mathematical questions
3. Focus on Phase 4-5 with those sorries in place (completeness under sorry)
4. Create a new task specifically for proving `witness_point_index_is_stage`
