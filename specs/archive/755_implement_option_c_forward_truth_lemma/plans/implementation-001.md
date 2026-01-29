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

### Phase 1: Strengthen Implication Truth Correspondence [BLOCKED]

**Goal**: Prove complete truth correspondence for implications, establishing the pattern for other constructors.

**Status**: BLOCKED - Fundamental architectural issue discovered.

**Analysis Findings**:
The truth correspondence for implications requires BOTH directions:
1. Forward: truth_at (psi.imp chi) → assignment (psi.imp chi) = true
2. Backward: assignment (psi.imp chi) = true → truth_at (psi.imp chi)

For MCS-derived world states, `closure_mcs_imp_iff` provides material implication equivalence:
- (psi.imp chi) ∈ S ↔ (psi ∈ S → chi ∈ S)

However, `truth_at_implies_semantic_truth` is called with ARBITRARY SemanticWorldStates,
not just MCS-derived ones. The assignment of a general FiniteWorldState is only required
to satisfy `IsLocallyConsistent`, which is weaker than MCS properties.

**Key Insight**: Local consistency enforces:
- v(psi.imp chi) = true AND v(psi) = true IMPLIES v(chi) = true

But it does NOT enforce:
- (v(psi) = true → v(chi) = true) IMPLIES v(psi.imp chi) = true

This is the forward direction we need but don't have for general world states.

**Tasks**:
- [x] Analyze existing `closure_mcs_imp_iff` and `IsLocallyConsistent` infrastructure
- [ ] ~~Implement `truth_at_imp_iff_semantic` theorem~~ BLOCKED: Cannot prove for arbitrary world states
- [ ] ~~Handle both directions~~ BLOCKED: Forward direction fails for non-MCS states

**Files modified**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Added documentation and helper lemmas

---

### Phase 2: Prove Box Collapse in Finite Model [BLOCKED]

**Goal**: Prove that box semantics collapse in the finite bounded-time model - the key insight that makes FMP completeness work.

**Status**: BLOCKED - Box semantics are fundamentally incompatible with the current model structure.

**Analysis Findings**:
The box operator has semantics: `truth_at M tau t (box psi) = forall sigma, truth_at M sigma t psi`

This quantifies over ALL WorldHistory, which corresponds to ALL SemanticWorldStates at time t.
For `truth_at (box psi) → assignment (box psi) = true` to hold, we need:
- If psi is true at ALL world states, then the assignment says box psi is true

But for an arbitrary FiniteWorldState, the assignment of box psi is just a boolean that
satisfies IsLocallyConsistent. The T-axiom in IsLocallyConsistent says:
- v(box psi) = true IMPLIES v(psi) = true

This is the REVERSE direction. We need:
- If psi is true at ALL worlds, then v(box psi) = true

For MCS-derived world states, this works because:
- If box psi ∈ MCS, then by T-axiom, psi ∈ MCS
- In S5, if psi holds at all worlds, box psi is true

But for arbitrary locally consistent assignments, v(box psi) could be false even when
psi is true at all worlds - local consistency only constrains the converse.

**Tasks**:
- [x] Understand the `htEquiv` quotient structure and how histories relate
- [ ] ~~Implement `box_truth_in_finite_model` theorem~~ BLOCKED: Requires MCS properties not available for general states

**Key Obstacle**: The SemanticCanonicalModel allows world states that are merely locally consistent,
not necessarily MCS-derived. Box semantics require global consistency across ALL world states.

---

### Phase 3: Prove Temporal Operator Correspondence [BLOCKED]

**Goal**: Prove truth correspondence for `all_past` and `all_future` operators.

**Status**: BLOCKED - Similar structural issues to box case.

**Analysis Findings**:
Temporal operators have semantics:
- `truth_at M tau t (all_past psi) = forall s, s <= t -> truth_at M tau s psi`
- `truth_at M tau t (all_future psi) = forall s, t <= s -> truth_at M tau s psi`

Unlike box, temporal operators quantify over times (not histories) on the SAME history.
This is actually more tractable for constant histories (finite_history_from_state).

However, the issue is that temporal semantics quantify over ALL times s in the duration
type (Int), not just times in the bounded domain [-k, k]. For times outside the domain:
- Atoms are false (no domain proof)
- Compound formulas still recurse

This means `all_past psi` might be false because psi is false at some time s < -k,
even though within the bounded domain everything is consistent.

Additionally, for non-MCS-derived world states, the same forward direction issue applies:
we need to show that if all_past psi is true recursively, then the assignment says so.
Local consistency doesn't enforce this direction for temporal operators.

**Tasks**:
- [x] Analyze temporal semantics (reflexive: uses <= not <)
- [x] Understand `BoundedTime` domain structure [-k, k]
- [ ] ~~Implement correspondence theorems~~ BLOCKED: Same structural issues as box

---

### Phase 4: Assemble Full Inductive Proof [BLOCKED]

**Goal**: Combine all constructor cases into the main `truth_at_implies_semantic_truth` theorem, removing the sorry.

**Status**: BLOCKED - Depends on Phases 1-3 which are all blocked.

**Analysis Findings**:
The structural induction proof cannot proceed because:
1. Atom case: Would work (semantic_valuation defined via assignment)
2. Bot case: Would work (both are always false)
3. Implication case: BLOCKED (forward direction fails for non-MCS states)
4. Box case: BLOCKED (requires global MCS properties)
5. Temporal cases: BLOCKED (same structural issues)

**Fundamental Architectural Issue**:
The theorem `truth_at_implies_semantic_truth` is called with arbitrary SemanticWorldStates.
The `valid_implies_semantic_truth` function gets a world state `w` and builds a history
through it, then tries to show truth_at implies the assignment.

But `w` might not be MCS-derived - any locally consistent assignment yields a valid
FiniteWorldState. Local consistency is WEAKER than MCS properties.

**Potential Architectural Solutions** (not implemented):
1. Modify SemanticCanonicalModel to only contain MCS-derived world states
2. Prove a different version of completeness that doesn't require this lemma
3. Show that for VALID formulas, the structure forces correspondence
4. Use a completely different model construction (e.g., coherent MCS family)

**Tasks**:
- [x] Review existing atom and bot cases (already proven in the codebase)
- [ ] ~~Integrate implication/box/temporal cases~~ BLOCKED: Phases 1-3 are blocked
- [ ] ~~Replace the sorry~~ BLOCKED: Cannot prove without resolving architectural issue

---

### Phase 5: Verification and Cleanup [PARTIAL]

**Goal**: Final verification, cleanup, and documentation of the sorry-free completeness theorem.

**Status**: PARTIAL - Added documentation but sorry remains.

**Tasks**:
- [x] Run `lake build` and verify module compiles
- [x] Add documentation comments explaining the proof challenge
- [ ] ~~Remove sorry from truth_at_implies_semantic_truth~~ BLOCKED: Architectural issue
- [x] Document the architectural gap between truth_at and semantic_truth_at_v2

**Files modified**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`:
  - Added detailed documentation explaining the truth lemma gap
  - Added `valid_implies_neg_unsatisfiable` helper lemma (proven)
  - Added `set_mcs_neg_excludes_helper` helper (delegates to existing lemma)
  - Enhanced documentation for `sorry_free_weak_completeness`
  - Documented potential solutions and architectural considerations

**Current sorry count in FMP path**:
- `SemanticCanonicalModel.lean:219` - compositionality (documented as mathematically false)
- `SemanticCanonicalModel.lean:629` - truth_at_implies_semantic_truth (architectural gap)

**Verification**:
- `lake build` passes with no errors
- Documentation accurately describes the current status and challenges

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
