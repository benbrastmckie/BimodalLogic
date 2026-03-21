# Implementation Plan: Task #981 - Coverage-Based Approach

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [PLANNED]
- **Effort**: 4-6 hours
- **Version**: 13
- **Dependencies**: Research report 27 (well-founded recursion analysis)
- **Research Inputs**: reports/27_well-founded-recursion-analysis.md
- **Artifacts**: plans/13_coverage-based-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

**ABANDON** the failing induction-on-formula-depth approach. Instead, prove that all CanonicalR-reachable MCSs from root are in the dovetailed timeline, then use this coverage theorem to derive forward_F/backward_P witnesses directly.

### Why Previous Approaches Failed

| Plan | Approach | Failure Mode |
|------|----------|--------------|
| v11-12 | Induction on i (formula depth) | j'+i can be > i (depth INCREASES) |
| v12 | Large step propagation | w.point_index >= m not provable (list grows sparsely) |

### Why Coverage-Based Works

The dovetailed construction processes ALL (point_index, formula_encoding) pairs via Cantor pairing enumeration. If M is in the timeline and F(phi) ∈ M, then at step `pair(M.index, encode(phi))`, the witness W is added. By induction on CanonicalR chain length (NOT formula depth), all reachable MCSs are covered.

---

## Phase 1: Define CanonicalR_chain [PARTIAL]

**Estimated effort**: 30 minutes

**Objectives**:
1. Define a predicate for CanonicalR chains from root
2. Provide induction principle on chain length

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverageReach.lean` (NEW)

**Content**:

```lean
import ProofChecker.Theories.Bimodal.Metalogic.StagedConstruction.DovetailedCoverage

namespace Bimodal.Metalogic.StagedConstruction

variable {root_mcs : Set Formula} {root_mcs_proof : SetMaximalConsistent root_mcs}

/-- A chain of CanonicalR steps from root_mcs to target. -/
inductive CanonicalR_chain (root : Set Formula) : Set Formula → Nat → Prop where
  | base : CanonicalR_chain root root 0
  | step {M W : Set Formula} {n : Nat} :
      CanonicalR_chain root M n →
      CanonicalR M W →
      CanonicalR_chain root W (n + 1)

/-- Alternative: exists chain predicate -/
def CanonicalR_reachable (root W : Set Formula) : Prop :=
  ∃ n, CanonicalR_chain root W n

end Bimodal.Metalogic.StagedConstruction
```

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedCoverageReach`

---

## Phase 2: Prove Coverage Theorem [NOT STARTED]

**Estimated effort**: 2-3 hours

**Objectives**:
1. Prove that all CanonicalR-reachable MCSs from root are in dovetailedTimelineUnion
2. This is the key theorem that enables sorry-free forward_F

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverageReach.lean`

**Theorem**:

```lean
/-- All CanonicalR-reachable MCSs from root are in the dovetailed timeline. -/
theorem dovetailed_covers_reachable (W : Set Formula) (h_mcs : SetMaximalConsistent W)
    (n : Nat) (h_reach : CanonicalR_chain root_mcs W n) :
    ∃ p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof, p.mcs = W := by
  induction n generalizing W with
  | zero =>
    -- Base case: W = root_mcs, which is at position 0
    cases h_reach
    use ⟨root_mcs, root_mcs_proof, 0⟩
    constructor
    · exact dovetailedTimeline_root_mem
    · rfl
  | succ n' ih =>
    -- Inductive case: M is in timeline, CanonicalR M W, show W is in timeline
    cases h_reach with
    | step h_chain h_R =>
      -- Get M from the chain
      obtain ⟨p, hp_mem, hp_mcs_eq⟩ := ih _ (canonical_chain_predecessor_mcs h_chain) h_chain
      -- Find the formula phi such that F(phi) ∈ M and W witnesses phi
      obtain ⟨phi, h_F_in_M, h_phi_in_W⟩ := canonicalR_witness_formula h_R
      -- At step pair(p.point_index, encode(phi)), W is added
      obtain ⟨k, h_dec⟩ := formula_has_encoding phi
      let m := Nat.pair p.point_index k
      -- Use witness_at_large_step machinery OR direct build analysis
      -- Key: at step m, W is added (or W = existing point)
      sorry -- Main technical work
```

**Proof Strategy**:

1. **Base case** (n=0): W = root_mcs, which is the first point in timeline (index 0)

2. **Inductive case** (n=n'+1):
   - By IH, predecessor M is in timeline at some point `p`
   - CanonicalR M W means: ∃ phi, F(phi) ∈ M ∧ phi ∈ W
   - At step `m = pair(p.point_index, encode(phi))`:
     - If m > stage(p): `witness_at_large_step` adds W (or W already exists)
     - If m <= stage(p): W was already added at an earlier step

3. **Key lemma needed**: Either W is already in timeline, or `witness_at_large_step` adds it

**Helper lemma**:

```lean
/-- The CanonicalR witness at (p, phi) is eventually in the timeline. -/
theorem canonicalR_witness_in_timeline (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof)
    (phi : Formula) (h_F : Formula.some_future phi ∈ p.mcs)
    (W : Set Formula) (h_mcs : SetMaximalConsistent W)
    (h_R : CanonicalR p.mcs W) (h_phi : phi ∈ W) :
    ∃ q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof, q.mcs = W
```

**Verification**:
- `lean_goal` at each sorry
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedCoverageReach`

---

## Phase 3: Derive forward_F and backward_P [NOT STARTED]

**Estimated effort**: 1-2 hours

**Objectives**:
1. Use coverage theorem to prove `forward_F_witness_in_timeline`
2. Symmetric proof for `backward_P_witness_in_timeline`
3. Delete or replace the old `forward_F_chain_witness` and `backward_P_chain_witness`

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

**Changes**:

### Step 3.1: New forward_F proof using coverage

```lean
theorem forward_F_witness_in_timeline_v2 (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion root_mcs root_mcs_proof)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ p.mcs) :
    ∃ q ∈ dovetailedTimelineUnion root_mcs root_mcs_proof,
      CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs := by
  -- Get canonical witness from MCS properties
  obtain ⟨W, h_W_mcs, h_R, h_phi⟩ := canonical_mcs_forward_witness p.mcs p.is_mcs phi h_F
  -- W is CanonicalR-reachable from root (p is reachable, W is one step further)
  obtain ⟨n, h_chain_p⟩ := dovetailed_point_reachable p hp
  have h_chain_W : CanonicalR_chain root_mcs W (n + 1) :=
    CanonicalR_chain.step (by rw [← (dovetailed_point_mcs_eq p hp)]; exact h_chain_p) h_R
  -- By coverage, W is in timeline
  obtain ⟨q, hq_mem, hq_mcs_eq⟩ := dovetailed_covers_reachable W h_W_mcs (n + 1) h_chain_W
  exact ⟨q, hq_mem, hq_mcs_eq.symm ▸ h_R, hq_mcs_eq.symm ▸ h_phi⟩
```

### Step 3.2: Update existing theorems

Replace `forward_F_witness_in_timeline` body to use the coverage-based proof.
Same for `backward_P_witness_in_timeline`.

### Step 3.3: Remove deprecated code

Delete or comment out:
- `forward_F_chain_witness` (lines 638-770)
- `forward_F_core` (if added in v12 attempt)
- `backward_P_chain_witness` (lines 775-839)

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot`
- `grep -c "sorry" Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`

---

## Phase 4: Final Verification [NOT STARTED]

**Estimated effort**: 30 minutes

**Objectives**:
1. Verify all sorries filled (except line 295 DenselyOrdered case)
2. Run full build
3. Check axiom trace

**Steps**:

```bash
# Full build
lake build

# Check sorries in DovetailedTimelineQuot.lean
grep -n "sorry" Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean

# Expected: only line 295 (DenselyOrdered intermediate case)

# Check axiom trace (if completeness theorem exists)
# #print axioms dovetailed_dense_completeness
```

**Verification**:
- Sorry count in DovetailedTimelineQuot.lean = 1 (line 295 only)
- Build passes
- No `discrete_Icc_finite_axiom` in trace

---

## Dependencies

- Research report 27: Coverage-based approach analysis (completed)
- DovetailedCoverage.lean: `witness_at_large_step`, `formula_has_encoding`
- MCS infrastructure: `canonical_mcs_forward_witness` or equivalent

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `canonical_mcs_forward_witness` doesn't exist | Medium | Construct from Lindenbaum lemma + CanonicalR definition |
| Coverage proof requires complex case analysis | Medium | Break into helper lemmas, use `lean_goal` extensively |
| Deleted code causes downstream failures | Low | Check all imports/usages before deletion |

## Success Criteria

- [ ] `CanonicalR_chain` defined and working
- [ ] `dovetailed_covers_reachable` proved
- [ ] `forward_F_witness_in_timeline` uses coverage (no induction on formula depth)
- [ ] `backward_P_witness_in_timeline` uses coverage (symmetric)
- [ ] Sorries in DovetailedTimelineQuot.lean <= 1 (line 295 only)
- [ ] `lake build` succeeds
- [ ] Old `forward_F_chain_witness` and `backward_P_chain_witness` removed

## Rollback Plan

If Phase 2 (coverage proof) fails:
1. Document the precise mathematical gap
2. Accept a well-documented sorry at `dovetailed_covers_reachable`
3. This is preferable to the current sorry inside a broken induction
4. Create a new task specifically for proving the coverage theorem

---

## Testing & Validation Commands

```bash
# Phase 1
lake build Bimodal.Metalogic.StagedConstruction.DovetailedCoverageReach

# Phase 2-3
lake build Bimodal.Metalogic.StagedConstruction.DovetailedTimelineQuot

# Phase 4
lake build
grep -c "sorry" Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean
```

Expected final sorry count: 1 (line 295, DenselyOrdered intermediate case)
