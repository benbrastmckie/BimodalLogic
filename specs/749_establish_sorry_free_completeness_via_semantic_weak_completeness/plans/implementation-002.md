# Implementation Plan: Task #749 (Revised)

- **Task**: 749 - Establish sorry-free completeness using semantic_weak_completeness
- **Version**: 002
- **Created**: 2026-01-29
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Priority**: High
- **Dependencies**: None (builds on existing sorry-free semantic_weak_completeness)
- **Research Inputs**:
  - specs/749_establish_sorry_free_completeness_via_semantic_weak_completeness/reports/research-001.md
  - specs/749_establish_sorry_free_completeness_via_semantic_weak_completeness/summaries/implementation-summary-20260129.md
  - specs/755_implement_option_c_forward_truth_lemma/reports/research-001.md (Option C analysis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revision Rationale**: The original plan (v001) attempted to bridge truth correspondence by fixing sorries in TruthLemma.lean. The partial implementation revealed that those sorries are **architectural limitations**, not missing proofs:

1. **Box sorries (lines 366, 389)**: Universal quantification over ALL world histories requires semantic architecture changes
2. **Temporal backward sorries (lines 416, 438)**: Requires omega-rule (infinitely many premises), not expressible in TM logic

**New Approach**: Based on task 755 research, prove truth correspondence via **structural induction over the subformula closure** directly in SemanticCanonicalModel.lean. This avoids the TruthLemma.lean architecture and instead uses:
- The finite closure structure (`closure phi` is finite and contains all subformulas)
- `IsLocallyConsistent` properties ensuring assignments respect formula structure
- The existing sorry-free `semantic_weak_completeness` contrapositive construction

### Key Technical Insight

The goal is to prove:
```lean
theorem truth_at_implies_semantic_truth (phi : Formula) ... :
    truth_at (SemanticCanonicalModel phi) tau 0 phi →
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) phi
```

This requires bridging:
- **Recursive truth** (`truth_at`): Evaluates formula by structural recursion
- **Assignment truth** (`semantic_truth_at_v2`): Looks up formula in FiniteWorldState's truth assignment

The solution is to prove that for formulas in the closure, the assignment IS consistent with recursion due to `IsLocallyConsistent` properties.

## Goals & Non-Goals

**Goals**:
- Prove `truth_at_imp_iff_semantic` for implication using local consistency and IH
- Prove `truth_at_box_iff_semantic` via box collapse in finite bounded-time model
- Prove `truth_at_G_iff_semantic` and `truth_at_H_iff_semantic` for temporal operators
- Remove sorry from `truth_at_implies_semantic_truth` via structural induction
- Achieve sorry-free `sorry_free_weak_completeness: valid phi -> provable phi`

**Non-Goals**:
- Fixing TruthLemma.lean sorries (architectural limitations, not our approach)
- Proving truth correspondence for arbitrary formulas (only need closure members)
- Full biconditional (only need forward direction for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box collapse proof complexity | High | Medium | Box semantics collapse in finite model - same SemanticWorldState at same time |
| Temporal quantification bounds | Medium | Medium | BoundedTime domain is finite `[-k, k]`; use this constraint |
| IsLocallyConsistent gaps | Medium | Low | Audit and strengthen if needed before main proof |
| Type coercion complexity | Medium | Medium | Use existing helper lemmas, create new ones as needed |

## Implementation Phases

### Phase 1: Audit and Strengthen Local Consistency [NOT STARTED]

**Goal**: Ensure `IsLocallyConsistent` includes all required properties for the inductive proof

**Tasks**:
- [ ] Review `FiniteWorldState.IsLocallyConsistent` definition in `FMP/FiniteWorldState.lean`
- [ ] Verify implication property: `v (psi.imp chi) = true → v psi = true → v chi = true`
- [ ] Verify negation property: `v (psi.neg) = true ↔ v psi = false` for closure members
- [ ] Verify reflexive axiom properties (T-axiom) for box and temporal operators
- [ ] Add any missing properties with proofs

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - audit IsLocallyConsistent
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add lemmas if needed

**Verification**:
- `lake build Bimodal.Metalogic.FMP.FiniteWorldState` succeeds
- Each property has a working proof or existing lemma identified

---

### Phase 2: Truth Correspondence for Implication [NOT STARTED]

**Goal**: Prove truth_at for implication matches semantic_truth_at_v2

**Tasks**:
- [ ] Prove `truth_at_imp_iff_semantic` using `closure_imp_left`, `closure_imp_right`
- [ ] Forward direction: IH on subformulas + modus ponens from local consistency
- [ ] Backward direction: From semantic assignment, use IH to get recursive truth

**Key Lemma**:
```lean
theorem truth_at_imp_iff_semantic (phi psi chi : Formula)
    (h_imp : Formula.imp psi chi ∈ closure phi)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (ih_psi : truth_at ... psi ↔ semantic_truth_at_v2 phi ... psi)
    (ih_chi : truth_at ... chi ↔ semantic_truth_at_v2 phi ... chi) :
    truth_at (SemanticCanonicalModel phi) tau 0 (psi.imp chi) ↔
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) (psi.imp chi)
```

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add implication lemma

**Verification**:
- `lake build` succeeds
- Lemma has no sorry

---

### Phase 3: Box Collapse in Finite Model [NOT STARTED]

**Goal**: Prove box truth correspondence by showing box semantics collapse in finite bounded-time model

**Key Insight**: In the SemanticCanonicalFrame:
- Different WorldHistories at the same BoundedTime yield the same SemanticWorldState (via `htEquiv` quotient)
- Box quantifies over all histories, but all relevant histories collapse to the same state
- Thus `∀ sigma, truth_at M sigma t psi` reduces to `truth_at M tau t psi` for any tau

**Tasks**:
- [ ] Prove `box_histories_collapse`: All histories at same bounded time give same SemanticWorldState
- [ ] Prove `truth_at_box_iff_semantic` using the collapse lemma
- [ ] Handle the reflexive case (T-axiom: box psi → psi)

**Key Lemma**:
```lean
theorem box_histories_collapse (phi : Formula)
    (tau sigma : WorldHistory (SemanticCanonicalFrame phi))
    (ht : tau.domain 0) (hs : sigma.domain 0) :
    truth_at (SemanticCanonicalModel phi) tau 0 psi ↔
    truth_at (SemanticCanonicalModel phi) sigma 0 psi
```

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add box collapse lemmas

**Verification**:
- `lake build` succeeds
- All box-related lemmas have no sorry

---

### Phase 4: Temporal Operators at Bounded Time [NOT STARTED]

**Goal**: Prove truth correspondence for G (all_future) and H (all_past)

**Key Insight**: BoundedTime domain is finite: `{-k, -k+1, ..., 0, ..., k-1, k}` where `k = temporalBound phi`. The temporal quantifiers only range over this finite set.

**Tasks**:
- [ ] Prove `truth_at_G_iff_semantic`: G operator correspondence
- [ ] Prove `truth_at_H_iff_semantic`: H operator correspondence
- [ ] Use finite domain to convert "forall time" to finite conjunction
- [ ] Apply IH to each time point (all in domain)

**Key Lemma**:
```lean
theorem truth_at_G_iff_semantic (phi psi : Formula)
    (h_G : psi.all_future ∈ closure phi)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (ih : ∀ t, truth_at ... t psi ↔ semantic_truth_at_v2 phi (tau.states t _) _ psi) :
    truth_at (SemanticCanonicalModel phi) tau 0 (psi.all_future) ↔
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) (psi.all_future)
```

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - add temporal lemmas

**Verification**:
- `lake build` succeeds
- Temporal lemmas have no sorry

---

### Phase 5: Main Truth Correspondence Theorem [NOT STARTED]

**Goal**: Prove `truth_at_implies_semantic_truth` by structural induction using phases 1-4

**Tasks**:
- [ ] Replace the sorry in `truth_at_implies_semantic_truth` with actual proof
- [ ] Use structural induction on phi
- [ ] Apply case lemmas from phases 2-4 for each formula constructor
- [ ] Verify the chain: `valid phi → truth_at → semantic_truth_at_v2`

**Proof Structure**:
```lean
theorem truth_at_implies_semantic_truth (phi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi) :
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) phi := by
  -- Structural induction on phi
  induction phi with
  | atom p => exact (truth_at_atom_iff_semantic ...).mp h_truth
  | bot => exact (truth_at_bot_iff_semantic ...).mp h_truth
  | imp psi chi ih_psi ih_chi => exact (truth_at_imp_iff_semantic ...).mp h_truth
  | box psi ih => exact (truth_at_box_iff_semantic ...).mp h_truth
  | all_past psi ih => exact (truth_at_H_iff_semantic ...).mp h_truth
  | all_future psi ih => exact (truth_at_G_iff_semantic ...).mp h_truth
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - complete the proof

**Verification**:
- `lake build` succeeds
- `truth_at_implies_semantic_truth` has NO sorry
- `sorry_free_weak_completeness` is now fully sorry-free

---

### Phase 6: Final Verification and Documentation [NOT STARTED]

**Goal**: Verify completeness is sorry-free and update documentation

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - should only show unrelated sorries (compositionality)
- [ ] Update docstrings to mark `sorry_free_weak_completeness` as truly sorry-free
- [ ] Update `Theories/Bimodal/Metalogic/FMP/README.md` with new result
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - docstring updates
- `Theories/Bimodal/Metalogic/FMP/README.md` - document completeness result
- `specs/749_.../summaries/implementation-summary-20260129.md` - update or create new

**Verification**:
- Full `lake build` succeeds
- Sorry count in completeness chain is 0
- Documentation reflects the achievement

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel` succeeds
- [ ] `lake build` full project succeeds
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean | grep -v compositionality` returns no matches
- [ ] `sorry_free_weak_completeness` is usable without warnings about sorries in dependencies

## Artifacts & Outputs

- `plans/implementation-002.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- Modified: `Theories/Bimodal/Metalogic/FMP/README.md`
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the full inductive proof proves intractable:

1. **Alternative A - MCS-Restricted Proof**: Restrict to MCS-derived world states only (simpler since `worldStateFromClosureMCS_models_iff` directly connects MCS membership to assignment)

2. **Alternative B - Accept Semantic Completeness**: Document that `semantic_weak_completeness` is the primary sorry-free completeness result, working for the "semantic truth" notion

3. **Document Obstacles**: If specific cases fail, document which (likely box or temporal) and why

The existing code remains functional - all changes are additive or modify only the sorry-marked theorems.

## References

- Task 755 research: `specs/755_implement_option_c_forward_truth_lemma/reports/research-001.md`
- Closure infrastructure: `Theories/Bimodal/Metalogic/FMP/Closure.lean`
- FiniteWorldState: `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean`
- Truth semantics: `Theories/Bimodal/Semantics/Truth.lean`
