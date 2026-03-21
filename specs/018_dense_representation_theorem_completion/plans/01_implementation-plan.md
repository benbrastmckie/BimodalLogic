# Implementation Plan: Dense Representation Theorem Completion

- **Task**: 18 - dense_representation_theorem_completion
- **Status**: [NOT STARTED]
- **Effort**: 9 hours (midpoint of 7-11 hour estimate)
- **Dependencies**: Task 16 (DenseTask), Task 17 (TimelineQuotBFMCS)
- **Research Inputs**: reports/01_dense-representation-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame into the unconditional dense representation theorem: `valid_dense phi -> provable_dense phi`. The key gap is the truth lemma over TimelineQuot - currently proven for `D=Int` but needed for `D=TimelineQuot`. Resolution requires building temporal coherence (forward_F/backward_P) for timelineQuotFMCS, then porting the truth lemma structure, and finally wiring `timelineQuot_instantiate_dense` to complete the countermodel construction.

### Research Integration

From `reports/01_dense-representation-research.md`:

- **DenseTask infrastructure**: Complete and sorry-free (Task 16)
- **TimelineQuotBFMCS**: Modal coherence complete, temporal coherence via CanonicalMCS (Task 17)
- **Key Gap**: Truth lemma proven for `D=Int`, needed for `D=TimelineQuot`
- **Resolution Path**: Build BFMCS indexed by TimelineQuot using linking infrastructure
- **Risk Mitigation**: Use forward-only truth lemma for countermodel construction

## Goals & Non-Goals

**Goals**:
- Prove `timelineQuotFMCS_forward_F` and `timelineQuotFMCS_backward_P` temporal coherence
- Build TimelineQuot canonical model (`timelineQuotCanonicalTaskModel`, `timelineQuotCanonicalOmega`)
- Prove `timelineQuot_truth_lemma` via structural induction
- Complete `timelineQuot_not_valid_of_neg_consistent` (remove blocking sorry)
- Wire `dense_completeness_theorem` using `timelineQuot_instantiate_dense`

**Non-Goals**:
- Modifying existing Int-based truth lemma infrastructure
- Proving full bidirectional truth lemma (forward direction suffices for countermodels)
- Changing DenseTask or TimelineQuotBFMCS implementations

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lindenbaum witness placement at TimelineQuot positions | M | M | Use linking lemma `timelineQuot_lt_implies_canonicalR` to bridge CanonicalR witnesses to TimelineQuot positions |
| Singleton BFMCS modal_backward issue | H | L | Use forward-only truth lemma; only modal_forward (T-axiom) needed for countermodel direction |
| Box case in truth lemma for singleton BFMCS | M | M | Singleton provides correct Box semantics via T-axiom forward direction |
| Complex proof dependencies across files | M | L | Follow existing `canonical_truth_lemma` structure closely |

## Implementation Phases

### Phase 1: Temporal Coherence [NOT STARTED]

**Goal**: Prove forward_F and backward_P for timelineQuotFMCS, establishing temporal witness existence.

**Tasks**:
- [ ] Prove `timelineQuotFMCS_forward_F`: F(phi) at t implies exists s > t with phi at s
  - Use `canonical_forward_F` from CanonicalFMCS.lean
  - Apply linking lemma to place witness at TimelineQuot position
- [ ] Prove `timelineQuotFMCS_backward_P`: P(phi) at t implies exists s < t with phi at s
  - Use `canonical_backward_P` from CanonicalFMCS.lean
  - Apply linking lemma for reverse direction
- [ ] Define `TimelineQuotTemporalCoherentFMCS` structure bundling temporal coherence

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - Add temporal coherence theorems

**Verification**:
- Both `timelineQuotFMCS_forward_F` and `timelineQuotFMCS_backward_P` compile without sorry
- `lake build` succeeds

---

### Phase 2: Model Construction [NOT STARTED]

**Goal**: Build TimelineQuot canonical task model and omega set for truth evaluation.

**Tasks**:
- [ ] Define `timelineQuotCanonicalTaskModel : TaskModel timelineQuotTaskFrame`
  - Model structure over DenseTaskFrame
  - Valuation from MCS membership
- [ ] Define `timelineQuotCanonicalOmega : Set (WorldHistory timelineQuotTaskFrame)`
  - Shift-closure property for temporal reasoning
  - History construction from timelineQuotFMCS
- [ ] Define `timelineQuotSingletonBFMCS : BFMCS (TimelineQuot root_mcs root_mcs_proof)`
  - Singleton wrapper using temporally coherent FMCS
  - Modal forward via T-axiom

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Add model definitions

**Verification**:
- All definitions compile without sorry
- `lake build` succeeds

---

### Phase 3: Truth Lemma [NOT STARTED]

**Goal**: Port truth lemma to TimelineQuot domain via structural induction on formulas.

**Tasks**:
- [ ] Prove base cases: atom, bot
  - Atom: MCS membership iff valuation
  - Bot: contradiction property
- [ ] Prove propositional cases: imp, neg (derived)
  - Follow canonical_truth_lemma structure
- [ ] Prove modal case: box
  - Use singleton BFMCS modal_forward
  - Forward direction only needed for countermodel
- [ ] Prove temporal cases: G (future), H (past)
  - Use `forward_G` from timelineQuotFMCS (already proven)
  - Use `backward_H` from timelineQuotFMCS (already proven)
- [ ] Prove temporal cases: F (some future), P (some past)
  - Use `forward_F` and `backward_P` from Phase 1
- [ ] Bundle into `timelineQuot_truth_lemma` theorem

**Timing**: 3.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Add truth lemma

**Verification**:
- `timelineQuot_truth_lemma` compiles without sorry
- All formula cases handled
- `lake build` succeeds

---

### Phase 4: Final Wiring [NOT STARTED]

**Goal**: Complete the dense completeness theorem by wiring all components.

**Tasks**:
- [ ] Complete `timelineQuot_not_valid_of_neg_consistent` (remove blocking sorry)
  - Construct countermodel at TimelineQuot using truth lemma
  - Use root MCS with phi.neg to show validity failure
- [ ] Wire `timelineQuot_instantiate_dense` with truth lemma
  - Instantiate valid_dense at D=TimelineQuot
  - Connect to countermodel construction
- [ ] Complete `dense_completeness_theorem`
  - Contrapositive: unprovable implies not valid_dense
  - Use neg consistent for countermodel
- [ ] Verify all sorries eliminated in TimelineQuotCompleteness.lean

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Complete main theorems

**Verification**:
- `dense_completeness_theorem` compiles without sorry
- `timelineQuot_not_valid_of_neg_consistent` compiles without sorry
- Full `lake build` succeeds with no sorries in TimelineQuotCompleteness.lean
- Run `grep -n "sorry" TimelineQuotCompleteness.lean` returns empty

---

## Testing & Validation

- [ ] All theorems in TimelineQuotCompleteness.lean compile without sorry
- [ ] `lake build` succeeds on full project
- [ ] `timelineQuot_truth_lemma` handles all formula constructors
- [ ] `dense_completeness_theorem` provides completeness for dense temporal frames
- [ ] No regression in existing proofs (Task 16, Task 17 remain sorry-free)

## Artifacts & Outputs

- `plans/01_implementation-plan.md` (this file)
- `summaries/01_implementation-summary.md` (after completion)
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

## Rollback/Contingency

If truth lemma approach encounters insurmountable issues:

1. **Alternative: Transfer Theorem**
   - Prove equivalence between Int-based truth and TimelineQuot-based truth
   - More complex but mathematically viable
   - Requires bijection between Int and TimelineQuot positions

2. **Partial Delivery**
   - If only temporal coherence achieved, document as [PARTIAL]
   - Remaining phases become follow-up tasks

3. **Git Rollback**
   - All changes are atomic per phase
   - `git revert` can undo individual phase commits
