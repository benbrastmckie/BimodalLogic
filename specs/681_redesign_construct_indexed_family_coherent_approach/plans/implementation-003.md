# Implementation Plan: Task #681 (Revised v3)

- **Task**: 681 - Redesign construct_indexed_family with coherent approach
- **Version**: 003 (Final Option B2 with mathematical justification)
- **Status**: [PLANNED]
- **Effort**: 12-14 hours
- **Priority**: Medium
- **Dependencies**: None (unblocks Task 658)
- **Research Inputs**:
  - specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-001.md
  - specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-002.md (mathematical elegance analysis)
  - specs/658_prove_indexed_family_coherence_conditions/reports/research-004.md (B1 vs B2 comparison)
- **Artifacts**: plans/implementation-003.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Executive Summary

This plan implements **Option B2 (Relational Coherent Construction)**, confirmed by research-002.md as the only mathematically sound and elegant approach. Option A (propagation lemmas) is **mathematically impossible** because independent Lindenbaum extensions cannot satisfy coherence. Option B1 (recursive seeds) is valid but limited to discrete time.

### Key Insight: Coherence Must Be Definitional

Research-002.md proves that coherence cannot be "proven after construction" - it must be **built into the construction**. Option B2 achieves this by:
1. Defining `coherent_at` as a relation that directly encodes the four coherence conditions
2. Proving extension lemmas that construct MCS satisfying this relation
3. Extracting IndexedMCSFamily conditions trivially from the relation

### Mathematical Justification

**Why Option A Fails**: Lindenbaum's lemma uses Choice to extend consistent sets arbitrarily. Two independent extensions `mcs(t1)` and `mcs(t2)` can add conflicting formulas. If `Gφ ∈ mcs(t1)` but `Gφ ∉ Gamma`, there's no guarantee `φ ∈ mcs(t2)`.

**Why Option B2 Works**: The `forward_seed` construction ensures:
- `forward_seed(S) = {φ | Gφ ∈ S}`
- Any MCS T extending `forward_seed(S)` satisfies `Gφ ∈ S → φ ∈ T` by construction
- This is exactly the `forward_G` coherence condition

## Goals & Non-Goals

**Goals**:
- Define `coherent_at` relation encoding all four coherence conditions
- Define `CoherentIndexedFamily` structure with pairwise coherence
- Prove `forward_extension` and `backward_extension` existence lemmas
- Prove `coherent_at_trans` for transitivity
- Construct `CoherentIndexedFamily` from root MCS
- Bridge to `IndexedMCSFamily` to unblock Task 658

**Non-Goals**:
- Full proof of `seed_consistent` lemmas (accept Boneyard-matching sorries)
- Dense time support in v1 (focus on D = ℤ; general D is future work)
- Proving Option A works (confirmed impossible by research-002.md)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency requires boxed contexts | High | High | Accept sorries matching Boneyard (line 2507) |
| Transitivity complex for mixed-sign cases | Medium | Medium | Explicit 4-case breakdown in Phase 4 |
| General D requires Dependent Choice | Medium | Low | Restrict v1 to D = ℤ |
| Boneyard compositionality has sorries | Medium | Medium | Our simpler `coherent_at` avoids modal transfer |

## Implementation Phases

### Phase 1: Define Coherent Relation Structure [NOT STARTED]

**Goal**: Define `coherent_at` relation and `CoherentIndexedFamily` structure.

**Mathematical Foundation**: The relation directly encodes the four IndexedMCSFamily conditions, making coherence *definitional* rather than something to prove.

**File**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (new)

**Tasks**:
- [ ] Create new file with imports:
  ```lean
  import Bimodal.Metalogic.Core.MaximalConsistent
  import Bimodal.Metalogic.Representation.IndexedMCSFamily
  import Bimodal.Boneyard.Metalogic.Completeness  -- For set_mcs_all_future_all_future
  ```

- [ ] Define `coherent_at` relation (mirrors Boneyard `canonical_task_rel` line 2055):
  ```lean
  /-- Two MCS are coherent at times t, t' if temporal formulas propagate correctly.

  This directly encodes the four IndexedMCSFamily coherence conditions:
  - forward_G: Gφ ∈ mcs(t) → φ ∈ mcs(t') for t < t'
  - backward_H: Hφ ∈ mcs(t) → φ ∈ mcs(t') for t' < t
  - forward_H: Hφ ∈ mcs(t') → φ ∈ mcs(t) for t < t'
  - backward_G: Gφ ∈ mcs(t') → φ ∈ mcs(t) for t' < t
  -/
  def coherent_at (D : Type*) [LinearOrder D]
      (mcs_t mcs_t' : Set Formula) (t t' : D) : Prop :=
    (t < t' → ∀ φ, Formula.all_future φ ∈ mcs_t → φ ∈ mcs_t') ∧  -- forward_G
    (t' < t → ∀ φ, Formula.all_past φ ∈ mcs_t → φ ∈ mcs_t') ∧    -- backward_H
    (t < t' → ∀ φ, Formula.all_past φ ∈ mcs_t' → φ ∈ mcs_t) ∧   -- forward_H
    (t' < t → ∀ φ, Formula.all_future φ ∈ mcs_t' → φ ∈ mcs_t)    -- backward_G
  ```

- [ ] Define `CoherentIndexedFamily` structure:
  ```lean
  /-- A family of MCS indexed by time with pairwise coherence.

  The pairwise_coherent field directly implies all four IndexedMCSFamily conditions
  by extracting the appropriate conjunct from coherent_at.
  -/
  structure CoherentIndexedFamily (D : Type*) [AddCommGroup D] [LinearOrder D] where
    mcs : D → Set Formula
    is_mcs : ∀ t, SetMaximalConsistent (mcs t)
    pairwise_coherent : ∀ t t', coherent_at D (mcs t) (mcs t') t t'
  ```

- [ ] Prove `coherent_at_refl`: When t = t', all conditions are vacuously true
- [ ] Prove `coherent_at_symm`: `coherent_at S T t t' ↔ coherent_at T S t' t`

**Key Insight**: Unlike Boneyard's `canonical_task_rel`, we omit `modal_transfer` since we're building temporal coherence, not task-frame accessibility.

**Timing**: 2 hours

**Verification**:
- File compiles without errors
- `coherent_at` captures all four IndexedMCSFamily conditions
- Reflexivity and symmetry proven

---

### Phase 2: Forward Seed and Extension [NOT STARTED]

**Goal**: Define forward seed and prove extension existence.

**Mathematical Foundation**: The forward seed `{φ | Gφ ∈ S}` contains exactly the formulas that *must* be in any coherent future MCS. By extending this seed to an MCS, we guarantee forward_G by construction.

**Reference**: Boneyard Completeness.lean:2521-2581 (`forward_extension`)

**Tasks**:
- [ ] Define `forward_seed`:
  ```lean
  /-- Seed for constructing MCS at future time.

  If T is any MCS containing forward_seed(S), then:
  - Gφ ∈ S implies φ ∈ forward_seed(S) by definition
  - φ ∈ forward_seed(S) implies φ ∈ T by subset
  - Therefore Gφ ∈ S → φ ∈ T, which is forward_G
  -/
  def forward_seed (S : Set Formula) : Set Formula :=
    {φ | Formula.all_future φ ∈ S}
  ```

- [ ] State `forward_seed_consistent` (accept sorry matching Boneyard line 2507):
  ```lean
  /-- The forward seed of an MCS is consistent.

  Proof idea: If {φ₁, ..., φₙ} ⊆ forward_seed(S) derives ⊥, then
  by generalized necessitation, {Gφ₁, ..., Gφₙ} derives G⊥.
  But Gφᵢ ∈ S for all i, so S derives G⊥.
  Since S is MCS, G⊥ ∈ S, but G⊥ → ⊥ is derivable (T axiom applied to G⊥).
  So ⊥ ∈ S, contradicting consistency of S.

  Full proof requires generalized necessitation infrastructure.
  -/
  lemma forward_seed_consistent (S : Set Formula) (h_mcs : SetMaximalConsistent S) :
      SetConsistent (forward_seed S) := by
    sorry  -- Matches Boneyard gap at line 2507
  ```

- [ ] Prove `forward_extension`:
  ```lean
  /-- For any MCS S, there exists an MCS T that is forward-coherent with S.

  Construction:
  1. forward_seed(S) is consistent (forward_seed_consistent)
  2. Extend via set_lindenbaum to MCS T
  3. coherent_at holds because forward_seed ⊆ T
  -/
  theorem forward_extension (S : Set Formula) (h_mcs : SetMaximalConsistent S)
      (D : Type*) [AddCommGroup D] [LinearOrder D] (t t' : D) (h_lt : t < t') :
      ∃ T : Set Formula, SetMaximalConsistent T ∧ coherent_at D S T t t' := by
    -- 1. Get consistent seed
    have h_cons := forward_seed_consistent S h_mcs
    -- 2. Extend to MCS
    obtain ⟨T, h_sub, h_mcs_T⟩ := set_lindenbaum (forward_seed S) h_cons
    use T, h_mcs_T
    -- 3. Verify coherent_at (forward conditions hold by construction)
    ...
  ```

- [ ] Prove G-persistence for transitivity (uses G-4 axiom via `set_mcs_all_future_all_future`):
  ```lean
  /-- G formulas persist through forward extension.

  If Gφ ∈ S and T is a forward extension, then Gφ ∈ T.
  Proof: Gφ ∈ S → GGφ ∈ S (by G-4) → Gφ ∈ forward_seed(S) → Gφ ∈ T.
  -/
  lemma forward_G_persistence ...
  ```

**Timing**: 2.5 hours

**Verification**:
- `forward_extension` compiles (with documented sorry)
- G-persistence uses G-4 axiom correctly
- All forward coherent_at conditions satisfied

---

### Phase 3: Backward Seed and Extension [NOT STARTED]

**Goal**: Define backward seed and prove extension existence (symmetric to Phase 2).

**Mathematical Foundation**: Symmetric to forward case, using H instead of G.

**Tasks**:
- [ ] Define `backward_seed`:
  ```lean
  def backward_seed (S : Set Formula) : Set Formula :=
    {φ | Formula.all_past φ ∈ S}
  ```

- [ ] State `backward_seed_consistent` (accept sorry):
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
    ...
  ```

- [ ] Prove H-persistence using H-4 axiom (`set_mcs_all_past_all_past`)

**Timing**: 1.5 hours (leveraging Phase 2 pattern)

**Verification**:
- `backward_extension` compiles (with documented sorry)
- H-persistence uses H-4 axiom correctly
- All backward coherent_at conditions satisfied

---

### Phase 4: Coherence Transitivity [NOT STARTED]

**Goal**: Prove pairwise coherence composes transitively.

**Mathematical Foundation**: Transitivity is essential for proving coherence across arbitrary time gaps. We use G-4/H-4 axioms to show temporal formulas persist through chains.

**Reference**: Boneyard `canonical_compositionality` (lines 2190-2254)

**Tasks**:
- [ ] Prove `coherent_at_trans` with explicit case analysis:
  ```lean
  /-- Coherence is transitive when the middle MCS is maximal consistent.

  The four cases correspond to the four orderings of t1, t2, t3:
  1. t1 < t2 < t3: Use G-4 for forward persistence
  2. t1 > t2 > t3: Use H-4 for backward persistence
  3. t1 < t2 > t3: Mix forward and backward conditions
  4. t1 > t2 < t3: Symmetric to case 3
  -/
  theorem coherent_at_trans (D : Type*) [AddCommGroup D] [LinearOrder D]
      (S T U : Set Formula) (t1 t2 t3 : D)
      (h_ST : coherent_at D S T t1 t2) (h_TU : coherent_at D T U t2 t3)
      (h_mcs_T : SetMaximalConsistent T) :
      coherent_at D S U t1 t3 := by
    ...
  ```

**Case 1**: t1 < t2 < t3 (monotonic future)
- forward_G (S→U): Gφ ∈ S → Gφ ∈ T (by G-persistence) → φ ∈ U (by h_TU forward_G)
- backward_H (S→U): vacuously true (t3 not < t1)
- forward_H (U→S): Hφ ∈ U → φ ∈ T (by h_TU forward_H) → ... (need chaining)
- backward_G (U→S): vacuously true (t1 not > t3)

**Case 2**: t1 > t2 > t3 (monotonic past)
- Symmetric using H-4

**Case 3**: t1 < t2 > t3 (peak at t2)
- Need both forward and backward conditions
- Key: Use cross-direction conditions in coherent_at

**Case 4**: t1 > t2 < t3 (valley at t2)
- Symmetric to Case 3

**Timing**: 2.5 hours

**Verification**:
- All four cases handled
- Uses G-4/H-4 axioms appropriately
- No unexpected sorries

---

### Phase 5: Construct Coherent Family [NOT STARTED]

**Goal**: Build `CoherentIndexedFamily` from root MCS.

**Strategy**: For v1, specialize to D = ℤ and use induction. General D requires Dependent Choice axiom.

**Tasks**:
- [ ] Define forward chain:
  ```lean
  noncomputable def mcs_forward (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) : ℕ → Set Formula
  | 0 => Gamma
  | n+1 => Classical.choose (forward_extension (mcs_forward Gamma h_mcs h_no_G_bot n)
                             (mcs_forward_is_mcs ...) (n : ℤ) (n+1) (by omega))
  ```

- [ ] Define backward chain:
  ```lean
  noncomputable def mcs_backward (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) : ℕ → Set Formula
  | 0 => Gamma
  | n+1 => Classical.choose (backward_extension (mcs_backward Gamma h_mcs h_no_H_bot n)
                             (mcs_backward_is_mcs ...) (-(n+1) : ℤ) (-n : ℤ) (by omega))
  ```

- [ ] Combine into unified function ℤ → Set Formula

- [ ] Prove `pairwise_coherent` by induction on |t - t'|

- [ ] Assemble into `CoherentIndexedFamily`:
  ```lean
  noncomputable def construct_coherent_family
      (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
      (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
      CoherentIndexedFamily ℤ where
    mcs := mcs_unified Gamma h_mcs h_no_G_bot h_no_H_bot
    is_mcs := mcs_unified_is_mcs ...
    pairwise_coherent := mcs_unified_pairwise_coherent ...
  ```

**Timing**: 2.5 hours

**Verification**:
- Construction compiles for D = ℤ
- All CoherentIndexedFamily fields satisfied
- Works for arbitrary root MCS

---

### Phase 6: Bridge to IndexedMCSFamily [NOT STARTED]

**Goal**: Convert `CoherentIndexedFamily` to `IndexedMCSFamily`, unblocking Task 658.

**Mathematical Foundation**: This is the payoff of making coherence definitional. The four IndexedMCSFamily conditions are direct extractions from `pairwise_coherent`.

**Tasks**:
- [ ] Define trivial conversion:
  ```lean
  /-- Convert CoherentIndexedFamily to IndexedMCSFamily.

  This is trivial because coherent_at directly encodes the four conditions.
  Each field extraction is a one-liner applying the appropriate conjunct.
  -/
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
  /-- Construct an IndexedMCSFamily from a root MCS.

  This replaces the old construction which had 4 sorries.
  The new construction uses CoherentConstruction which guarantees
  coherence by design, not by proof.
  -/
  noncomputable def construct_indexed_family
      (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
      (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma) :
      IndexedMCSFamily ℤ :=
    (construct_coherent_family Gamma h_mcs h_no_G_bot h_no_H_bot).toIndexedMCSFamily
  ```

- [ ] Remove old sorry-based coherence proofs from IndexedMCSFamily.lean

- [ ] Update module documentation

**Timing**: 1.5 hours

**Verification**:
- Conversion is trivial
- `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` succeeds
- Task 658 coherence sorries eliminated

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Representation.CoherentConstruction` compiles
- [ ] `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` compiles
- [ ] Only documented sorries: forward_seed_consistent, backward_seed_consistent
- [ ] `lean_diagnostic_messages` shows no errors on both files
- [ ] All four IndexedMCSFamily conditions satisfied by trivial extraction
- [ ] Task 658 coherence sorries eliminated

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (new, ~400 lines)
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (updated construct_indexed_family)
- `specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

| Situation | Action |
|-----------|--------|
| Seed consistency harder than expected | Accept sorries matching Boneyard line 2507 |
| Transitivity fails for mixed-sign cases | Document limitation; may need case restrictions |
| General D too complex | Commit to D = ℤ; general D is future work |
| Approach fundamentally fails | Fall back to Option B1 (recursive seeds, ℤ only) |

## Changes from v002

| Aspect | v002 | v003 |
|--------|------|------|
| Research basis | research-001.md, research-004.md | + research-002.md (mathematical elegance analysis) |
| Mathematical justification | Implicit | Explicit proof sketches in each phase |
| Boneyard references | General | Specific line numbers (2055, 2507, 2521-2581) |
| Seed consistency gap | Mentioned | Fully documented with proof idea |
| Phase 4 cases | Listed | Detailed strategy per case |
| Conversion rationale | Implicit | Explicit "payoff of definitional coherence" |

## References

- Boneyard `canonical_task_rel`: Completeness.lean:2055-2061
- Boneyard `forward_seed_consistent` sorry: Completeness.lean:2507
- Boneyard `forward_extension`: Completeness.lean:2521-2581
- Boneyard `canonical_compositionality`: Completeness.lean:2190-2254
- Research-002.md: Mathematical elegance analysis proving Option A impossible
- Research-004.md: Detailed B1 vs B2 comparison
- Research-001.md: Initial relational approach analysis
