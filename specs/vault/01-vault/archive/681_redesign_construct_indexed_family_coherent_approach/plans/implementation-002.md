# Implementation Plan: Task #681 (Revised v2)

- **Task**: 681 - Redesign construct_indexed_family with coherent approach
- **Version**: 002 (Option B2 refinement)
- **Status**: [PLANNED]
- **Effort**: 12-14 hours
- **Priority**: Medium
- **Dependencies**: None (unblocks Task 658)
- **Research Inputs**:
  - specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-001.md
  - specs/658_prove_indexed_family_coherence_conditions/reports/research-004.md (B1 vs B2 comparison)
- **Artifacts**: plans/implementation-002.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan implements **Option B2 (Relational/Coherent Construction)** as recommended by research-004.md. The approach adapts the Boneyard's `canonical_task_rel` pattern to define coherence relationally between MCS pairs, then constructs a family satisfying pairwise coherence.

### Why Option B2 Over B1

| Factor | Option B1 (Recursive Seeds) | Option B2 (Relational) | Winner |
|--------|---------------------------|------------------------|--------|
| Time type support | Discrete only (ℤ) | Any ordered additive group | **B2** |
| Proven pattern | No reference | Boneyard `canonical_task_rel` | **B2** |
| Coherence proof style | Induction on distance | Transitivity composition | B2 (more general) |
| Seed consistency gap | Same | Same | Tie |
| Effort estimate | 8-10h | 12-14h | B1 (but B2 more robust) |

**Key insight from research-004.md**: Option B2's relational approach makes coherence *definitional* - once `coherent_at` is established between pairs, the four IndexedMCSFamily conditions follow trivially.

### Research Integration

From research-004.md and research-001.md:
- **Root cause**: Independent `extendToMCS` calls make uncoordinated formula choices
- **Solution**: Define coherence as a *relation*, then prove extension lemmas that construct related MCS
- **Reference**: Boneyard's `canonical_task_rel` (Completeness.lean:2055-2171)
- **Known gap**: `seed_consistent` proofs require "boxed contexts" infrastructure (Boneyard has sorries)

## Goals & Non-Goals

**Goals**:
- Define `coherent_at` relation encoding all four coherence conditions
- Define `CoherentIndexedFamily` structure with pairwise coherence
- Prove `forward_extension` and `backward_extension` existence lemmas
- Prove `coherent_at_trans` for compositional reasoning
- Construct `CoherentIndexedFamily` from root MCS
- Bridge to `IndexedMCSFamily` to unblock Task 658

**Non-Goals**:
- Full proof of `seed_consistent` lemmas (accept Boneyard-matching sorries)
- Dense time support in v1 (focus on D = ℤ; general D is future work)
- Optimizing proof performance
- Refactoring IndexedMCSFamily interface (preserve compatibility)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency requires boxed contexts | High | High | Accept sorries matching Boneyard gap |
| Transitivity proof complex for mixed signs | Medium | Medium | Handle cases separately; use temporal axioms G-4, H-4 |
| General D requires Dependent Choice | Medium | Low | Restrict v1 to discrete time; document limitation |
| Boneyard `canonical_compositionality` has sorries | Medium | Medium | Our coherent_at definition may be simpler (no modal transfer needed) |

## Implementation Phases

### Phase 1: Define Coherent Relation Structure [NOT STARTED]

**Goal**: Define `coherent_at` relation and `CoherentIndexedFamily` structure.

**File**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (new)

**Tasks**:
- [ ] Create new file with imports:
  ```lean
  import Bimodal.Metalogic.Core.MaximalConsistent
  import Bimodal.Metalogic.Representation.IndexedMCSFamily
  import Bimodal.Boneyard.Metalogic.Completeness  -- For set_mcs_all_future_all_future
  ```
- [ ] Define `coherent_at` relation:
  ```lean
  /-- Two MCS are coherent at times t, t' if temporal formulas propagate correctly. -/
  def coherent_at (D : Type*) [LinearOrder D]
      (mcs_t mcs_t' : Set Formula) (t t' : D) : Prop :=
    (t < t' → ∀ φ, Formula.all_future φ ∈ mcs_t → φ ∈ mcs_t') ∧  -- forward_G
    (t' < t → ∀ φ, Formula.all_past φ ∈ mcs_t → φ ∈ mcs_t') ∧    -- backward_H
    (t < t' → ∀ φ, Formula.all_past φ ∈ mcs_t' → φ ∈ mcs_t) ∧   -- forward_H
    (t' < t → ∀ φ, Formula.all_future φ ∈ mcs_t' → φ ∈ mcs_t)    -- backward_G
  ```
- [ ] Define `CoherentIndexedFamily` structure:
  ```lean
  structure CoherentIndexedFamily (D : Type*) [AddCommGroup D] [LinearOrder D] where
    mcs : D → Set Formula
    is_mcs : ∀ t, SetMaximalConsistent (mcs t)
    pairwise_coherent : ∀ t t', coherent_at D (mcs t) (mcs t') t t'
  ```
- [ ] Prove `coherent_at_refl`: reflexivity when t = t'
- [ ] Prove `coherent_at_symm`: coherent_at S T t t' ↔ coherent_at T S t' t

**Key insight**: Unlike Boneyard's `canonical_task_rel`, we don't need `modal_transfer` since we're building a temporal family, not a task relation. This simplifies the definition.

**Timing**: 2 hours

**Verification**:
- File compiles without errors
- `coherent_at` captures all four IndexedMCSFamily conditions
- Reflexivity and symmetry proven

---

### Phase 2: Forward Seed and Extension [NOT STARTED]

**Goal**: Define forward seed and prove extension existence.

**Reference**: Boneyard Completeness.lean:2521-2581 (`forward_extension`)

**Tasks**:
- [ ] Define `forward_seed`:
  ```lean
  /-- Seed for constructing MCS at future time: formulas that must hold. -/
  def forward_seed (S : Set Formula) : Set Formula :=
    {φ | Formula.all_future φ ∈ S}
  ```
  Note: We omit `{φ | □φ ∈ S}` since we're building temporal, not modal, coherence.

- [ ] State `forward_seed_consistent`:
  ```lean
  lemma forward_seed_consistent (S : Set Formula) (h_mcs : SetMaximalConsistent S) :
      SetConsistent (forward_seed S) := by
    sorry  -- Requires boxed context infrastructure; matches Boneyard gap
  ```
  Document why: Must show if `forward_seed S` is inconsistent, then `S` is inconsistent (contradiction).

- [ ] Prove `forward_extension`:
  ```lean
  theorem forward_extension (S : Set Formula) (h_mcs : SetMaximalConsistent S)
      (D : Type*) [AddCommGroup D] [LinearOrder D] (t t' : D) (h_lt : t < t') :
      ∃ T : Set Formula, SetMaximalConsistent T ∧ coherent_at D S T t t' := by
    -- 1. forward_seed S is consistent (sorry)
    -- 2. Extend via set_lindenbaum
    -- 3. Verify coherent_at conditions
  ```

- [ ] Prove G-persistence: `Gφ ∈ S → Gφ ∈ T` using `set_mcs_all_future_all_future` (G-4 axiom)

**Timing**: 2.5 hours

**Verification**:
- `forward_extension` compiles (with documented sorry)
- G-persistence uses G-4 axiom correctly
- Coherent_at forward conditions satisfied

---

### Phase 3: Backward Seed and Extension [NOT STARTED]

**Goal**: Define backward seed and prove extension existence (symmetric to Phase 2).

**Tasks**:
- [ ] Define `backward_seed`:
  ```lean
  def backward_seed (S : Set Formula) : Set Formula :=
    {φ | Formula.all_past φ ∈ S}
  ```

- [ ] State `backward_seed_consistent`:
  ```lean
  lemma backward_seed_consistent (S : Set Formula) (h_mcs : SetMaximalConsistent S) :
      SetConsistent (backward_seed S) := by
    sorry  -- Symmetric to forward_seed_consistent
  ```

- [ ] Prove `backward_extension`:
  ```lean
  theorem backward_extension (S : Set Formula) (h_mcs : SetMaximalConsistent S)
      (D : Type*) [AddCommGroup D] [LinearOrder D] (t t' : D) (h_lt : t' < t) :
      ∃ T : Set Formula, SetMaximalConsistent T ∧ coherent_at D T S t' t := by
    -- Symmetric to forward_extension
  ```

- [ ] Prove H-persistence: `Hφ ∈ S → Hφ ∈ T` using `set_mcs_all_past_all_past` (H-4 axiom)

**Timing**: 1.5 hours (leveraging Phase 2 pattern)

**Verification**:
- `backward_extension` compiles (with documented sorry)
- H-persistence uses H-4 axiom correctly
- Coherent_at backward conditions satisfied

---

### Phase 4: Coherence Transitivity [NOT STARTED]

**Goal**: Prove pairwise coherence composes transitively.

**Key insight from research-004.md**: The Boneyard's `canonical_compositionality` proof (lines 2190-2254) has complexity in mixed-sign cases. Our simpler `coherent_at` definition should make this easier.

**Tasks**:
- [ ] Prove `coherent_at_trans`:
  ```lean
  theorem coherent_at_trans (D : Type*) [AddCommGroup D] [LinearOrder D]
      (S T U : Set Formula) (t1 t2 t3 : D)
      (h_ST : coherent_at D S T t1 t2) (h_TU : coherent_at D T U t2 t3)
      (h_mcs_T : SetMaximalConsistent T) :
      coherent_at D S U t1 t3 := by
    -- Case analysis on ordering of t1, t2, t3
  ```

- [ ] Case 1: t1 < t2 < t3 (monotonic future)
  - forward_G: Gφ ∈ S → φ ∈ T (by h_ST) → need φ ∈ U
  - Use: T is MCS, so if Gφ ∈ S then GGφ ∈ S (by G-4), so Gφ ∈ T, so φ ∈ U

- [ ] Case 2: t1 > t2 > t3 (monotonic past)
  - Symmetric using H-4

- [ ] Case 3: t1 < t2 > t3 (peak in middle)
  - Use cross-direction conditions in coherent_at

- [ ] Case 4: t1 > t2 < t3 (valley in middle)
  - Symmetric to Case 3

**Timing**: 2.5 hours

**Verification**:
- All four cases handled
- Uses G-4/H-4 axioms appropriately
- No unexpected sorries

---

### Phase 5: Construct Coherent Family [NOT STARTED]

**Goal**: Build `CoherentIndexedFamily` from root MCS.

**Strategy**: For v1, specialize to discrete time D = ℤ and use induction. General D requires Dependent Choice axiom.

**Tasks**:
- [ ] Define `construct_coherent_family`:
  ```lean
  noncomputable def construct_coherent_family
      (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
      (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
      CoherentIndexedFamily ℤ := by
    -- Use forward_extension and backward_extension iteratively
  ```

- [ ] Build forward chain: mcs(n) for n ≥ 0
  ```lean
  noncomputable def mcs_forward (Gamma : Set Formula) (h_mcs : ...) : ℕ → Set Formula
  | 0 => Gamma
  | n+1 => Classical.choose (forward_extension (mcs_forward Gamma h_mcs n) ...)
  ```

- [ ] Build backward chain: mcs(-n) for n > 0
  ```lean
  noncomputable def mcs_backward (Gamma : Set Formula) (h_mcs : ...) : ℕ → Set Formula
  | 0 => Gamma
  | n+1 => Classical.choose (backward_extension (mcs_backward Gamma h_mcs n) ...)
  ```

- [ ] Combine into unified function: ℤ → Set Formula

- [ ] Prove `pairwise_coherent` by induction on |t - t'|:
  - Base: |t - t'| = 0 → reflexivity
  - Step: Use transitivity through intermediate times

**Timing**: 2.5 hours

**Verification**:
- Construction compiles for D = ℤ
- All CoherentIndexedFamily fields satisfied
- Works for arbitrary root MCS (with h_no_G_bot, h_no_H_bot assumptions)

---

### Phase 6: Bridge to IndexedMCSFamily [NOT STARTED]

**Goal**: Convert `CoherentIndexedFamily` to `IndexedMCSFamily`, unblocking Task 658.

**Tasks**:
- [ ] Define conversion function:
  ```lean
  def CoherentIndexedFamily.toIndexedMCSFamily (F : CoherentIndexedFamily D) :
      IndexedMCSFamily D where
    mcs := F.mcs
    is_mcs := F.is_mcs
    forward_G := fun t t' φ h_lt h_G => (F.pairwise_coherent t t').1 h_lt φ h_G
    backward_H := fun t t' φ h_lt h_H => (F.pairwise_coherent t t').2.1 h_lt φ h_H
    forward_H := fun t t' φ h_lt h_H => (F.pairwise_coherent t t').2.2.1 h_lt φ h_H
    backward_G := fun t t' φ h_lt h_G => (F.pairwise_coherent t t').2.2.2 h_lt φ h_G
  ```

- [ ] Update `construct_indexed_family` in IndexedMCSFamily.lean:
  ```lean
  noncomputable def construct_indexed_family
      (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
      (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
      IndexedMCSFamily ℤ :=
    (construct_coherent_family Gamma h_mcs h_no_G_bot h_no_H_bot).toIndexedMCSFamily
  ```

- [ ] Remove sorries from old coherence proofs (now provided by structure)

- [ ] Update module documentation explaining the coherent construction approach

**Timing**: 1.5 hours

**Verification**:
- Conversion is trivial (coherent_at directly implies IndexedMCSFamily conditions)
- `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` succeeds
- Task 658 coherence sorries eliminated

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Representation.CoherentConstruction` compiles
- [ ] `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` compiles
- [ ] Only documented sorries: forward_seed_consistent, backward_seed_consistent
- [ ] `lean_diagnostic_messages` shows no errors on both files
- [ ] All four IndexedMCSFamily conditions satisfied by construction
- [ ] Task 658 can close its sorries using new construct_indexed_family

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (new file, ~350 lines)
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (updated construct_indexed_family)
- `specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

| Situation | Action |
|-----------|--------|
| Seed consistency harder than expected | Accept sorries matching Boneyard; document as future work |
| Transitivity fails for mixed-sign cases | Restrict to monotonic chains; document limitation |
| General D too complex | Commit to D = ℤ; document as future work for dense time |
| Approach fundamentally fails | Fall back to Option B1 (recursive seeds) for discrete time |

## Changes from v001

| Aspect | v001 | v002 |
|--------|------|------|
| Research basis | research-001.md only | + research-004.md (B1 vs B2 comparison) |
| forward_seed definition | Included modal transfer (□φ) | Temporal only (no modal) |
| Transitivity approach | Generic case split | Explicit 4-case analysis with axiom mapping |
| Time type | Mixed (Z focus, general D mentioned) | Explicit: v1 = ℤ, general D is future work |
| Effort estimate | 14 hours | 12-14 hours (tighter bounds) |
| Risk table | Generic | Specific to Option B2 challenges |

## References

- Boneyard `canonical_task_rel`: Completeness.lean:2055-2061
- Boneyard `canonical_nullity`: Completeness.lean:2080-2110
- Boneyard `forward_extension`: Completeness.lean:2521-2581
- Boneyard `canonical_compositionality`: Completeness.lean:2190-2254
- Research-004.md: Option B1 vs B2 detailed comparison
- Research-001.md: Initial relational approach analysis
