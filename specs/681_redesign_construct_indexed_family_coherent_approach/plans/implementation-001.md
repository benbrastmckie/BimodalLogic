# Implementation Plan: Task #681

- **Task**: 681 - Redesign construct_indexed_family with coherent approach
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Priority**: Medium
- **Dependencies**: None (unblocks Task 658)
- **Research Inputs**: specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Redesign the `construct_indexed_family` function in IndexedMCSFamily.lean to use a coherent relational construction approach adapted from the Boneyard's `canonical_task_rel` pattern. The current implementation uses independent Lindenbaum extensions at each time point, which cannot guarantee temporal coherence because each extension makes independent choices. The new approach defines coherence relationally between neighboring MCS pairs, ensuring coherence is built into the construction rather than proven after the fact.

### Research Integration

Research report (research-001.md) identified:
- **Root cause**: Independent `extendToMCS` calls at each time point make uncoordinated formula choices
- **Recommended pattern**: Boneyard's `canonical_task_rel` with forward/backward extension lemmas
- **Key files**: Boneyard/Metalogic/Completeness.lean:2055-2581 for relational pattern reference

## Goals & Non-Goals

**Goals**:
- Define a `coherent_at` relation between MCS pairs that guarantees temporal coherence
- Define `CoherentIndexedFamily` structure using pairwise coherence
- Prove forward_extension and backward_extension existence lemmas
- Prove that `CoherentIndexedFamily` satisfies all four `IndexedMCSFamily` coherence conditions
- Construct a `CoherentIndexedFamily` from a root MCS, unblocking Task 658

**Non-Goals**:
- Full proof of `seed_consistent` lemmas (Boneyard has sorries here; accept same gap)
- Supporting arbitrary dense time structures (focus on discrete time first)
- Optimizing for proof performance
- Refactoring existing IndexedMCSFamily interface (preserve compatibility)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Extension lemmas have sorries (seed_consistent) | High | High | Accept same gap as Boneyard; document clearly. These are provable but require additional infrastructure for "boxed contexts". |
| Transitivity proof is complex | Medium | Medium | Use temporal axiom patterns (G-4, H-4) from Boneyard |
| Approach still doesn't work for dense time | Medium | Low | Focus on discrete time (Z) first; use induction instead of Dependent Choice |
| Compositionality requires cross-time coordination | Medium | Medium | Build transitivity into relation definition following Boneyard pattern |

## Implementation Phases

### Phase 1: Define Coherent Relation Structure [NOT STARTED]

**Goal**: Define the foundational `coherent_at` relation and `CoherentIndexedFamily` structure that encode temporal coherence constraints.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- [ ] Import IndexedMCSFamily.lean, Lindenbaum lemma, and MCS properties
- [ ] Define `coherent_at (mcs_t : Set Formula) (mcs_t' : Set Formula) (t t' : D) : Prop`:
  - `t < t' -> forall phi, G phi in mcs_t -> phi in mcs_t'` (forward G transfer)
  - `t' < t -> forall phi, H phi in mcs_t -> phi in mcs_t'` (backward H transfer)
  - `t < t' -> forall phi, H phi in mcs_t' -> phi in mcs_t` (forward H: looking back)
  - `t' < t -> forall phi, G phi in mcs_t' -> phi in mcs_t` (backward G: looking forward)
- [ ] Define `CoherentIndexedFamily` structure with fields:
  - `mcs : D -> Set Formula`
  - `is_mcs : forall t, SetMaximalConsistent (mcs t)`
  - `pairwise_coherent : forall t t', coherent_at (mcs t) (mcs t') t t'`
- [ ] Prove `coherent_at_refl`: `coherent_at S S t t` (reflexivity)
- [ ] Prove basic coherent_at properties (symmetry of conditions when t = t')

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (new file)

**Verification**:
- File compiles without errors
- `coherent_at` definition captures all four IndexedMCSFamily conditions
- `CoherentIndexedFamily` structure is well-formed

---

### Phase 2: Forward Extension Lemma [NOT STARTED]

**Goal**: Prove that given any MCS S, we can construct an MCS T that is coherent with S for a future time step.

**Tasks**:
- [ ] Define `forward_seed (S : Set Formula) : Set Formula`:
  - `{phi | G phi in S} union {phi | box phi in S}`
- [ ] State `forward_seed_subset_coherent`: forward_seed S is contained in any MCS T where coherent_at S T 0 eps (eps > 0)
- [ ] Prove `forward_seed_consistent (S : Set Formula) (h_mcs : SetMaximalConsistent S) : SetConsistent (forward_seed S)`:
  - Proof approach: Assume inconsistent, derive contradiction using MCS properties
  - Accept sorry if proof requires "boxed contexts" infrastructure (matching Boneyard gap)
- [ ] Prove `forward_extension`:
  ```lean
  theorem forward_extension (S : Set Formula) (h_mcs : SetMaximalConsistent S) (eps : D) (h_pos : eps > 0) :
      exists T : Set Formula, SetMaximalConsistent T and coherent_at S T 0 eps
  ```
  - Use set_lindenbaum to extend forward_seed to MCS
  - Verify coherent_at conditions hold by construction

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Verification**:
- `forward_extension` compiles (possibly with sorry in `forward_seed_consistent`)
- Coherent_at conditions are satisfied by the constructed T
- Uses MCS properties (set_mcs_all_future_all_future for G-4 axiom)

---

### Phase 3: Backward Extension Lemma [NOT STARTED]

**Goal**: Prove that given any MCS S, we can construct an MCS T that is coherent with S for a past time step.

**Tasks**:
- [ ] Define `backward_seed (S : Set Formula) : Set Formula`:
  - `{phi | H phi in S} union {phi | box phi in S}`
- [ ] Prove `backward_seed_consistent (S : Set Formula) (h_mcs : SetMaximalConsistent S) : SetConsistent (backward_seed S)`:
  - Symmetric to forward_seed_consistent
  - Accept sorry if needed (matching Boneyard gap)
- [ ] Prove `backward_extension`:
  ```lean
  theorem backward_extension (S : Set Formula) (h_mcs : SetMaximalConsistent S) (eps : D) (h_pos : eps > 0) :
      exists T : Set Formula, SetMaximalConsistent T and coherent_at T S (-eps) 0
  ```
  - Extend backward_seed to MCS
  - Verify coherent_at conditions (reversed direction)
- [ ] Prove consistency between forward and backward: if T is forward extension of S, then S satisfies backward conditions relative to T

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Verification**:
- `backward_extension` compiles (possibly with sorry)
- Forward/backward symmetry is established
- Uses set_mcs_all_past_all_past for H-4 axiom

---

### Phase 4: Coherence Transitivity [NOT STARTED]

**Goal**: Prove that pairwise coherence is transitive, enabling construction of families by chaining extension steps.

**Tasks**:
- [ ] Prove `coherent_at_trans`:
  ```lean
  theorem coherent_at_trans (S T U : Set Formula) (t1 t2 t3 : D)
      (h_ST : coherent_at S T t1 t2) (h_TU : coherent_at T U t2 t3)
      (h_mcs_S : SetMaximalConsistent S) (h_mcs_T : SetMaximalConsistent T) (h_mcs_U : SetMaximalConsistent U) :
      coherent_at S U t1 t3
  ```
- [ ] Case analysis on signs of (t2 - t1) and (t3 - t2):
  - Case 1: both positive (S < T < U) - chain forward transfers via G-4 axiom
  - Case 2: both negative (S > T > U) - chain backward transfers via H-4 axiom
  - Case 3: mixed signs - use cross-direction coherence conditions
- [ ] Use temporal axioms:
  - G phi -> GG phi (via set_mcs_all_future_all_future)
  - H phi -> HH phi (via set_mcs_all_past_all_past)

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Verification**:
- All cases compile without sorry (or documented necessary sorries)
- Can chain n extension steps via repeated transitivity

---

### Phase 5: Construct Coherent Family [NOT STARTED]

**Goal**: Build a complete CoherentIndexedFamily from a root MCS using extension lemmas.

**Tasks**:
- [ ] Define family construction strategy for discrete time (D = Z):
  ```lean
  noncomputable def construct_coherent_family_discrete
      (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
      CoherentIndexedFamily Int
  ```
- [ ] Build mcs(0) = Gamma (the root)
- [ ] Build mcs(n+1) from mcs(n) using forward_extension
- [ ] Build mcs(n-1) from mcs(n) using backward_extension
- [ ] Prove pairwise_coherent by induction on distance |t - t'|:
  - Base case: |t - t'| = 0, reflexivity
  - Inductive case: use transitivity through intermediate MCS
- [ ] Alternative: If supporting general D (not just Z), use Axiom of Dependent Choice:
  ```lean
  axiom dependent_choice {alpha : Type*} (R : alpha -> alpha -> Prop) (a0 : alpha)
      (h : forall a, exists b, R a b) : exists f : Nat -> alpha, f 0 = a0 and forall n, R (f n) (f (n+1))
  ```

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Verification**:
- `construct_coherent_family_discrete` compiles
- All fields of CoherentIndexedFamily are satisfied
- Construction works for arbitrary root MCS

---

### Phase 6: Bridge to IndexedMCSFamily [NOT STARTED]

**Goal**: Prove that CoherentIndexedFamily satisfies all IndexedMCSFamily coherence conditions, providing the final bridge to unblock Task 658.

**Tasks**:
- [ ] Prove `CoherentIndexedFamily.to_IndexedMCSFamily`:
  ```lean
  def CoherentIndexedFamily.to_IndexedMCSFamily (F : CoherentIndexedFamily D) :
      IndexedMCSFamily D
  ```
- [ ] Prove forward_G from pairwise_coherent:
  - `forall t t' phi, t < t' -> G phi in F.mcs t -> phi in F.mcs t'`
  - Follows directly from coherent_at definition
- [ ] Prove backward_H from pairwise_coherent:
  - `forall t t' phi, t' < t -> H phi in F.mcs t -> phi in F.mcs t'`
  - Follows directly from coherent_at definition
- [ ] Prove forward_H from pairwise_coherent:
  - `forall t t' phi, t < t' -> H phi in F.mcs t' -> phi in F.mcs t`
  - Follows directly from coherent_at definition
- [ ] Prove backward_G from pairwise_coherent:
  - `forall t t' phi, t' < t -> G phi in F.mcs t' -> phi in F.mcs t`
  - Follows directly from coherent_at definition
- [ ] Update construct_indexed_family in IndexedMCSFamily.lean to use new coherent construction:
  ```lean
  noncomputable def construct_indexed_family
      (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
      IndexedMCSFamily D :=
    (construct_coherent_family_discrete Gamma h_mcs).to_IndexedMCSFamily
  ```

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (update construct_indexed_family)

**Verification**:
- All four coherence conditions satisfied without sorry
- construct_indexed_family compiles with new implementation
- Original IndexedMCSFamily interface preserved
- Task 658's sorries can be resolved using the new construction

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Representation.CoherentConstruction` compiles
- [ ] `lake build Theories.Bimodal.Metalogic.Representation.IndexedMCSFamily` compiles
- [ ] No new sorries introduced except documented seed_consistent gap (same as Boneyard)
- [ ] Run `lean_diagnostic_messages` on both files to verify no errors
- [ ] Verify forward_G, backward_H, forward_H, backward_G all proved (not sorry)
- [ ] Task 658 can use the new construction to complete its proofs

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (new file)
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (updated)
- `specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

- If seed_consistent proofs prove harder than expected: Accept sorries matching Boneyard, document as future work
- If transitivity fails for mixed-sign cases: Restrict to discrete time with simple induction (no cross-origin cases)
- If general D proves too complex: Specialize to D = Int (discrete integers) and document limitation
- Original IndexedMCSFamily.lean preserved in git history for rollback
- If approach fundamentally fails: Consider Option B (incremental family construction) from research report
