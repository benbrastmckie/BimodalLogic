# Implementation Plan: Succ Relation Definition

- **Task**: 10 - define_succ_relation
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 9 (completed - f_content/p_content in TemporalContent.lean)
- **Research Inputs**: specs/010_define_succ_relation/reports/01_succ-relation-research.md
- **Artifacts**: plans/01_succ-relation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Define the Succ (immediate successor) relation for discrete temporal frames and prove its three core theorems. Succ(u,v) captures when v is the "next" state after u by requiring both G-persistence (same as CanonicalR) and F-step (F-obligations resolve or defer). This is foundational infrastructure for the discrete track (tasks 10-15).

### Research Integration

From report 01_succ-relation-research.md:
- All prerequisites exist: g_content, f_content, CanonicalR, g_content_subset_implies_h_content_reverse
- Single-step forcing proof strategy: FFphi absence implies GG(neg phi), enabling contradiction
- Estimated 50-60 lines of code, low-moderate difficulty

## Goals & Non-Goals

**Goals**:
- Define Succ relation with g_content and f_content conditions
- Prove Succ_implies_CanonicalR (trivial projection)
- Prove Succ_implies_h_content_reverse (g/h duality)
- Prove single_step_forcing (key forcing theorem)
- Add comprehensive docstrings for all definitions/theorems

**Non-Goals**:
- Succ chain iteration (task 11)
- CanonicalTask frame construction (task 12)
- Bounded witness theorems (task 13)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula expansion lemma complexity | M | L | Research shows neg_FF_eq_GG_neg is definitional (rfl) |
| MCS consistency in single_step_forcing | M | L | Use existing set_consistent_not_both pattern from WitnessSeed.lean |
| Missing import | L | L | Imports clearly documented in research report |

## Implementation Phases

### Phase 1: File Setup and Succ Definition [NOT STARTED]

**Goal**: Create SuccRelation.lean with imports and core Succ definition

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
- [ ] Add imports: TemporalContent, CanonicalFrame, WitnessSeed, MCSProperties
- [ ] Define namespace Bimodal.Metalogic.Bundle
- [ ] Define `Succ (u v : Set Formula) : Prop := g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v`
- [ ] Add accessor theorems: `Succ.g_persistence`, `Succ.f_step`
- [ ] Add docstrings explaining the two conditions

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - create new file

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccRelation` succeeds
- Definition and accessors have no sorries

---

### Phase 2: Succ_implies_CanonicalR [NOT STARTED]

**Goal**: Prove that Succ implies the canonical relation

**Tasks**:
- [ ] Add theorem `Succ_implies_CanonicalR : Succ u v → CanonicalR u v`
- [ ] Prove via projection h.1 (trivial, one line)
- [ ] Add docstring explaining this is just the first component

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`

**Verification**:
- `lake build` succeeds
- No sorries in theorem

---

### Phase 3: g/h Duality for Succ [NOT STARTED]

**Goal**: Prove that Succ implies h_content reverse direction

**Tasks**:
- [ ] Add theorem `Succ_implies_h_content_reverse`
- [ ] Statement: `Succ u v → h_content v ⊆ u` (for MCS u, v)
- [ ] Prove by applying existing `g_content_subset_implies_h_content_reverse` to h.1
- [ ] Add docstring explaining duality via temp_a axiom

**Timing**: 10 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`

**Verification**:
- `lake build` succeeds
- No sorries in theorem

---

### Phase 4: Auxiliary Lemmas for Single-Step Forcing [NOT STARTED]

**Goal**: Prove helper lemmas for the main forcing theorem

**Tasks**:
- [ ] Add lemma `neg_FF_eq_GG_neg`: `(F(F(phi))).neg = G(G(phi.neg))`
  - Should be provable by rfl or simple simp
- [ ] Add lemma `G_neg_implies_not_F`: `G(phi.neg) in M → F(phi) not in M`
  - Use set_consistent_not_both pattern from WitnessSeed.lean
- [ ] Add docstrings explaining each lemma's role

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`

**Verification**:
- `lake build` succeeds
- Both lemmas have no sorries
- Use `lean_goal` to verify proof states

---

### Phase 5: Single-Step Forcing Theorem [NOT STARTED]

**Goal**: Prove the key theorem connecting F-nesting depth to witness distance

**Tasks**:
- [ ] Add theorem `single_step_forcing` with statement:
  ```lean
  theorem single_step_forcing
      (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
      (phi : Formula)
      (h_F : Formula.some_future phi ∈ u)
      (h_FF_not : Formula.some_future (Formula.some_future phi) ∉ u)
      (h_succ : Succ u v) :
      phi ∈ v
  ```
- [ ] Implement proof following 8-step strategy from research:
  1. FFphi not in u → neg(FFphi) in u by negation completeness
  2. neg(FFphi) = GG(neg phi) by formula expansion
  3. GG(neg phi) in u → G(neg phi) in g_content u
  4. G(neg phi) in v by G-persistence
  5. G(neg phi) = neg(Fphi), so Fphi not in v
  6. By F-step: Fphi in u implies phi in v or Fphi in v
  7. Since Fphi not in v, conclude phi in v
- [ ] Add comprehensive docstring explaining the proof strategy

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`

**Verification**:
- `lake build` succeeds
- No sorries in theorem
- Use `lean_goal` during proof development

---

### Phase 6: Final Verification and Documentation [NOT STARTED]

**Goal**: Verify complete file and add module documentation

**Tasks**:
- [ ] Add module docstring explaining SuccRelation.lean purpose
- [ ] Document relationship to tasks 11-15 (future dependencies)
- [ ] Run full `lake build` to verify all theorems
- [ ] Check no sorries with grep
- [ ] Verify all three main theorems are proven:
  - Succ_implies_CanonicalR
  - Succ_implies_h_content_reverse
  - single_step_forcing

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccRelation` succeeds with no warnings
- `grep -r "sorry" SuccRelation.lean` returns no results
- All theorems documented

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Bundle.SuccRelation` succeeds
- [ ] No sorries in the file (`grep sorry SuccRelation.lean`)
- [ ] All three main theorems proven:
  - [ ] `Succ_implies_CanonicalR`
  - [ ] `Succ_implies_h_content_reverse`
  - [ ] `single_step_forcing`
- [ ] Documentation comments for each definition/theorem
- [ ] Module compiles cleanly with no warnings

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - New Lean 4 module
- `specs/010_define_succ_relation/plans/01_succ-relation-plan.md` - This plan
- `specs/010_define_succ_relation/summaries/01_succ-relation-summary.md` - Summary (post-implementation)

## Rollback/Contingency

- If single_step_forcing proof becomes complex, break into sub-lemmas
- If formula expansion lemma fails rfl, use explicit simp with Formula definitions
- Full rollback: `git checkout -- Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
