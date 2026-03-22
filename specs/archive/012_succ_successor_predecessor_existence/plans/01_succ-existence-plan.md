# Implementation Plan: Succ Successor/Predecessor Existence

- **Task**: 12 - succ_successor_predecessor_existence
- **Status**: [COMPLETED]
- **Effort**: 6-7 hours
- **Dependencies**: Task 10 (Succ relation - completed)
- **Research Inputs**: specs/012_succ_successor_predecessor_existence/reports/01_succ-existence-research.md
- **Artifacts**: plans/01_succ-existence-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task proves successor and predecessor existence for the Succ relation under discrete axioms (base + DF + seriality). The key construction is the **deferral seed**: `g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}`, which captures both G-persistence and the "resolve or defer" semantics of F-obligations. Proving consistency of this seed is the crux; it requires adapting techniques from `forward_temporal_witness_seed_consistent` to handle multiple disjunctive deferrals simultaneously.

### Research Integration

From the research report (01_succ-existence-research.md):
- Succ relation from task 10: `g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v`
- Deferral seed ensures both Succ conditions are satisfied by construction
- DF axiom `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` is key to consistency argument
- Existing `g_content_consistent` and `forward_temporal_witness_seed_consistent` provide proof patterns
- DP (backward discreteness) is already derivable from DF via `discreteness_past`

## Goals & Non-Goals

**Goals**:
- Define `successor_deferral_seed` and `predecessor_deferral_seed`
- Prove consistency of deferral seeds (or axiomatize with justification)
- Prove `successor_exists`: for MCS u with F(top) in u, exists MCS v with Succ(u,v)
- Prove `predecessor_exists`: for MCS u with P(top) in u, exists MCS v with Succ(v,u)
- Integrate with existing SuccRelation.lean infrastructure

**Non-Goals**:
- Proving Succ forms a linear order (separate task)
- Proving confluence/determinacy of Succ (separate task)
- Modifying the existing Succ definition
- Removing existing axioms from DiscreteSuccSeed.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deferral seed consistency proof intractable | H | M | Fallback: axiomatize with documented semantic justification (like `discreteImmediateSuccSeed_consistent_axiom`) |
| Disjunctive deferrals interact in unexpected ways | M | M | Case-split carefully; leverage `g_content_consistent` for base case |
| Proof gets stuck on formula manipulation | M | L | Use existing patterns from WitnessSeed.lean; break into helper lemmas |
| DF axiom usage is subtle | M | M | Follow existing patterns from research; test incrementally |

## Implementation Phases

### Phase 1: Seed Definitions and Membership Lemmas [COMPLETED]

**Goal**: Define the successor and predecessor deferral seeds with basic lemmas.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- [ ] Import SuccRelation.lean, WitnessSeed.lean, Construction.lean
- [ ] Define `successor_deferral_seed (u : Set Formula) : Set Formula`
  - `g_content u ∪ {Formula.or φ (Formula.some_future φ) | Formula.some_future φ ∈ u}`
- [ ] Define `predecessor_deferral_seed (u : Set Formula) : Set Formula`
  - `h_content u ∪ {Formula.or φ (Formula.some_past φ) | Formula.some_past φ ∈ u}`
- [ ] Add membership lemmas:
  - `g_content_subset_successor_deferral_seed`
  - `deferral_disjunction_mem_of_F_mem`
  - (symmetric for predecessor)
- [ ] Add documentation header explaining seed purpose

**Timing**: 1 hour

**Files to modify**:
- Create `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccExistence` succeeds
- Definitions and membership lemmas compile

---

### Phase 2: Successor Seed Consistency (Core Challenge) [COMPLETED]

**Goal**: Prove or axiomatize `successor_deferral_seed_consistent`.

**Tasks**:
- [ ] Define theorem statement:
  ```lean
  theorem successor_deferral_seed_consistent
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
      SetConsistent (successor_deferral_seed u)
  ```
- [ ] **Attempt direct proof** (1.5 hours):
  - Suppose L ⊆ seed with L derives bot
  - Partition L into L_g (from g_content) and L_d (disjunctive deferrals)
  - Case 1 (L_d = empty): Use `g_content_consistent`
  - Case 2 (L_d nonempty): Adapt `forward_temporal_witness_seed_consistent` pattern
    - Key insight: each disjunction `φ ∨ F(φ)` is derivable from `F(φ) ∈ u` via DF
    - Use generalized temporal K on the conjunction
- [ ] **If direct proof fails** (30 min):
  - Add axiom with documented justification:
  ```lean
  axiom successor_deferral_seed_consistent_axiom
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
      SetConsistent (successor_deferral_seed u)
  ```
  - Document semantic justification: seriality + DF guarantee realizability
- [ ] Add helper lemmas as needed:
  - `deferral_disjunction_derivable_from_F` (derive φ ∨ F(φ) from F(φ) using DF)
  - Interaction between g_content and deferrals

**Timing**: 2-2.5 hours (1.5h attempt + 0.5h fallback + 0.5h helpers)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- Theorem compiles (either proven or axiomatized)
- Any axiom has clear documentation of semantic justification

---

### Phase 3: Successor Existence Theorem [COMPLETED]

**Goal**: Prove that successors exist for MCSes with F(top).

**Tasks**:
- [ ] Define successor construction using Lindenbaum:
  ```lean
  noncomputable def successor_from_deferral_seed
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
      Set Formula :=
    lindenbaumMCS_set (successor_deferral_seed u)
      (successor_deferral_seed_consistent u h_mcs h_F_top)
  ```
- [ ] Prove successor is MCS:
  ```lean
  theorem successor_from_deferral_seed_mcs : SetMaximalConsistent (successor_from_deferral_seed ...)
  ```
- [ ] Prove Succ condition 1 (G-persistence):
  ```lean
  theorem successor_satisfies_g_persistence :
      g_content u ⊆ successor_from_deferral_seed u h_mcs h_F_top
  ```
- [ ] Prove Succ condition 2 (F-step):
  ```lean
  theorem successor_satisfies_f_step :
      f_content u ⊆ (successor_from_deferral_seed u h_mcs h_F_top) ∪
                     f_content (successor_from_deferral_seed u h_mcs h_F_top)
  ```
  - Key: for F(φ) in u, the disjunction φ ∨ F(φ) is in the seed, hence in successor
  - By MCS disjunction property, either φ in successor (resolved) or F(φ) in successor (deferred)
- [ ] Combine into Succ:
  ```lean
  theorem successor_succ : Succ u (successor_from_deferral_seed u h_mcs h_F_top)
  ```
- [ ] Wrap as existence:
  ```lean
  theorem successor_exists (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
      ∃ v, SetMaximalConsistent v ∧ Succ u v
  ```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `successor_exists` compiles and type-checks
- `#check @successor_exists` shows correct signature

---

### Phase 4: Predecessor Existence (Symmetric) [COMPLETED]

**Goal**: Prove predecessor existence via symmetric construction using DP.

**Tasks**:
- [ ] Define `Pred` relation (convenience alias):
  ```lean
  def Pred (u v : Set Formula) : Prop := Succ v u
  ```
- [ ] Prove `predecessor_deferral_seed_consistent`:
  - Mirror Phase 2 structure
  - Use h_content instead of g_content
  - Use p_content instead of f_content
  - Use DP (`discreteness_past`) instead of DF
  - Use `contains_seriality_past` instead of `contains_seriality_future`
- [ ] Define predecessor construction using Lindenbaum:
  ```lean
  noncomputable def predecessor_from_deferral_seed
      (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
      Set Formula
  ```
- [ ] Prove Pred conditions (symmetric to Phase 3):
  - H-persistence: h_content u ⊆ predecessor
  - P-step: p_content u ⊆ predecessor ∪ p_content predecessor
- [ ] Prove predecessor existence:
  ```lean
  theorem predecessor_exists (u : Set Formula) (h_mcs : SetMaximalConsistent u)
      (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
      ∃ v, SetMaximalConsistent v ∧ Pred u v
  ```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

**Verification**:
- `predecessor_exists` compiles
- `#check @predecessor_exists` shows correct signature
- `#check @Pred` is available

---

### Phase 5: Integration and Testing [COMPLETED]

**Goal**: Verify integration with existing infrastructure and add documentation.

**Tasks**:
- [ ] Add SuccExistence.lean to Bimodal.lean imports
- [ ] Run `lake build` on full project
- [ ] Verify no new axioms beyond justified ones
- [ ] Add module documentation:
  - Overview explaining the deferral seed approach
  - Key theorems listed
  - References to task 10 and research reports
- [ ] Optional: Add Succ/Pred duality lemmas if useful:
  ```lean
  lemma Pred_iff_Succ_reverse : Pred u v ↔ Succ v u
  ```
- [ ] Create implementation summary

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (docs)
- `Theories/Bimodal.lean` (import)

**Verification**:
- Full `lake build` succeeds
- No unexpected warnings
- Module documentation is comprehensive

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.SuccExistence` succeeds
- [ ] `lake build` (full project) succeeds
- [ ] `#check @successor_exists` returns expected type
- [ ] `#check @predecessor_exists` returns expected type
- [ ] `#check @Succ` and `#check @Pred` work
- [ ] No new unjustified axioms introduced (any axioms documented)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Main implementation file
- `specs/012_succ_successor_predecessor_existence/plans/01_succ-existence-plan.md` - This plan
- `specs/012_succ_successor_predecessor_existence/summaries/01_succ-existence-summary.md` - Execution summary (post-implementation)

## Rollback/Contingency

If the implementation fails or introduces problems:

1. **If seed consistency proof fails**: Use axiomatization fallback (documented in Phase 2)
2. **If axiom count is unacceptable**: Consider whether `discreteImmediateSuccSeed` provides an alternative path (though it uses blocking formulas, not deferral disjunctions)
3. **If integration breaks existing code**: Revert SuccExistence.lean, investigate imports
4. **Full rollback**: Delete `SuccExistence.lean`, remove from imports

## Notes

- The deferral seed is structurally simpler than the blocking formula seed in DiscreteSuccSeed.lean
- The disjunctive deferral `φ ∨ F(φ)` directly captures "resolve or defer" semantics
- DP (backward discreteness) is already derivable from DF, so predecessor case should mirror successor
- Existing `lindenbaumMCS_set` provides all needed Lindenbaum machinery
