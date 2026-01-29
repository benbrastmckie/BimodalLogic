# Implementation Plan: Task #755

- **Task**: 755 - Implement Option C: Forward Truth Lemma via FMP Path
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Priority**: High
- **Dependencies**: Task 750 research (research-005.md)
- **Research Inputs**: specs/755_implement_option_c_forward_truth_lemma/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements Option C from task 750 research: achieving sorry-free completeness (`valid phi -> derivable [] phi`) via the FMP (Finite Model Property) path. The key challenge is proving `truth_at_implies_semantic_truth` - bridging recursive truth evaluation (`truth_at`) to assignment-based truth checking (`semantic_truth_at_v2`). The approach uses structural induction over the subformula closure, leveraging the existing sorry-free `semantic_weak_completeness` theorem.

### Research Integration

Research report research-001.md identifies:
- The exact sorry location in `truth_at_implies_semantic_truth` at SemanticCanonicalModel.lean:699
- The gap between recursive `truth_at` (quantifies over ALL histories/times) and flat `semantic_truth_at_v2` (checks assignment)
- Existing infrastructure: `IsLocallyConsistent`, `closure_mcs_imp_iff`, `closure_mcs_neg_complete`, `worldStateFromClosureMCS_models_iff`
- Recommended approach: structural induction with lemmas for each formula constructor

## Goals & Non-Goals

**Goals**:
- Remove the sorry from `truth_at_implies_semantic_truth`
- Achieve fully sorry-free `sorry_free_weak_completeness`
- Prove truth correspondence lemmas for all formula constructors (atom, bot, imp, box, all_past, all_future)
- Verify with `lake build` that all sorries are eliminated in the FMP completeness path

**Non-Goals**:
- Fixing sorries in Representation/ path (that's a different approach)
- Removing the compositionality sorry (documented as mathematically false)
- Changing the soundness axiomatization (that's acceptable as an axiom)
- Refactoring the overall architecture

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box collapse proof too complex | High | Medium | Use quotient structure; histories at same time yield same SemanticWorldState |
| Temporal operators need additional infrastructure | Medium | Medium | Leverage existing reflexive semantics; T-axiom already handled |
| Implication backward direction fails | High | Low | closure_mcs_imp_iff provides both directions; use contrapositive |
| Time estimates exceed plan | Medium | Medium | Phases designed to be independently completable; can adjust |

## Implementation Phases

### Phase 1: Strengthen Implication Truth Correspondence [NOT STARTED]

**Goal**: Prove complete truth correspondence for implications, establishing the pattern for other constructors.

**Tasks**:
- [ ] Analyze existing `closure_mcs_imp_iff` and `IsLocallyConsistent` infrastructure
- [ ] Implement `truth_at_imp_iff_semantic` theorem
- [ ] Handle both forward (recursive -> assignment) and backward (assignment -> recursive) directions
- [ ] Verify with lean_goal at each proof step

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Add implication correspondence theorem

**Verification**:
- New theorem compiles without sorry
- `lean_goal` shows no unsolved goals
- `lake build` passes with no new errors

---

### Phase 2: Prove Box Collapse in Finite Model [NOT STARTED]

**Goal**: Prove that box semantics collapse in the finite bounded-time model - the key insight that makes FMP completeness work.

**Tasks**:
- [ ] Understand the `htEquiv` quotient structure and how histories relate
- [ ] Prove helper lemma: histories at same bounded time with same SemanticWorldState are equivalent for truth
- [ ] Implement `box_truth_in_finite_model` theorem
- [ ] Handle the universal quantification over all WorldHistory

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Add box collapse lemmas

**Verification**:
- Box collapse theorem compiles without sorry
- Proof connects `forall sigma, truth_at ... sigma 0 psi` to `semantic_truth_at_v2 ... psi.box`

---

### Phase 3: Prove Temporal Operator Correspondence [NOT STARTED]

**Goal**: Prove truth correspondence for `all_past` and `all_future` operators.

**Tasks**:
- [ ] Analyze temporal semantics (reflexive: uses <= not <)
- [ ] Understand `BoundedTime` domain structure [-k, k]
- [ ] Implement `all_past_truth_correspondence` theorem
- [ ] Implement `all_future_truth_correspondence` theorem
- [ ] Handle the quantification over bounded time domain

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Add temporal correspondence theorems

**Verification**:
- Both temporal correspondence theorems compile without sorry
- Proofs correctly handle the reflexive semantics (T-axiom)

---

### Phase 4: Assemble Full Inductive Proof [NOT STARTED]

**Goal**: Combine all constructor cases into the main `truth_at_implies_semantic_truth` theorem, removing the sorry.

**Tasks**:
- [ ] Review existing atom and bot cases (already proven)
- [ ] Integrate implication case from Phase 1
- [ ] Integrate box case from Phase 2
- [ ] Integrate temporal cases from Phase 3
- [ ] Replace the sorry with the complete structural induction
- [ ] Verify the proof handles all formula constructors

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Complete `truth_at_implies_semantic_truth`

**Verification**:
- `truth_at_implies_semantic_truth` has no sorry
- `sorry_free_weak_completeness` compiles without sorry
- `lake build` shows no sorries in FMP path

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Final verification, cleanup, and documentation of the sorry-free completeness theorem.

**Tasks**:
- [ ] Run `lake build` and verify no sorries in FMP/ directory
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/` to confirm
- [ ] Add documentation comments explaining the proof strategy
- [ ] Update module docstring to reflect sorry-free status
- [ ] Clean up any temporary helper lemmas or scaffolding

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Documentation updates
- Potentially `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` if verification extends there

**Verification**:
- `lake build` passes with no new errors
- `grep sorry` returns only the documented compositionality sorry
- Module docstrings accurately describe theorem status

## Testing & Validation

- [ ] `lake build` completes successfully
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` shows only compositionality sorry
- [ ] `lean_goal` at `sorry_free_weak_completeness` shows "no goals" (proof complete)
- [ ] Manual review confirms structural induction covers all formula cases

## Artifacts & Outputs

- `specs/755_implement_option_c_forward_truth_lemma/plans/implementation-001.md` (this file)
- `specs/755_implement_option_c_forward_truth_lemma/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

## Rollback/Contingency

If the full inductive proof proves too complex:

1. **MCS-Restricted Approach**: Restrict `truth_at_implies_semantic_truth` to MCS-derived world states only. The `worldStateFromClosureMCS_models_iff` lemma provides direct membership-assignment correspondence. This is simpler because countermodels in `semantic_weak_completeness` ARE MCS-derived.

2. **Partial Progress**: Each phase produces independently valuable lemmas. If Phase 2 (box) or Phase 3 (temporal) proves intractable, the implication correspondence from Phase 1 still advances understanding.

3. **Git Rollback**: All changes are in a single file. Revert to pre-implementation commit if needed: `git checkout HEAD~N -- Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

## Technical Notes

### Key Existing Infrastructure

```lean
-- Local consistency enforces propositional logic on assignments
def IsLocallyConsistent (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  (forall h : Formula.bot in closure phi, v ... = false) /\
  (forall psi chi, ... v (psi.imp chi) = true -> v psi = true -> v chi = true) /\
  (forall psi, ... v (psi.box) = true -> v psi = true)  -- T axiom

-- MCS membership equals assignment truth
theorem worldStateFromClosureMCS_models_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_mem : psi in closure phi) :
    psi in S <-> (worldStateFromClosureMCS phi S h_mcs).models psi h_mem

-- Negation completeness in closure MCS
theorem closure_mcs_neg_complete (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_clos : psi in closure phi) :
    psi in S \/ psi.neg in S

-- Implication iff material conditional in MCS
theorem closure_mcs_imp_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi chi : Formula)
    (h_imp_clos : Formula.imp psi chi in closure phi) :
    Formula.imp psi chi in S <-> (psi in S -> chi in S)
```

### Critical Insight: Quotient Structure

The `SemanticWorldState` is a quotient over `HistoryTimePair` by `htEquiv`:
```lean
def htEquiv (phi : Formula) : HistoryTimePair phi -> HistoryTimePair phi -> Prop :=
  fun p1 p2 => p1.1.states p1.2 = p2.1.states p2.2
```

This means: **different histories at the same bounded time that yield the same FiniteWorldState are equivalent**. For box semantics, this is crucial - the universal quantification over histories collapses because all that matters is the underlying world state.
