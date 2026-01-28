# Implementation Plan: Task #628

- **Task**: 628 - Prove semantic_truth_implies_truth_at (upward bridge)
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Priority**: Low
- **Dependencies**: None (related to Tasks 610, 627, but independent)
- **Research Inputs**: specs/628_prove_semantic_truth_implies_truth_at_upward_bridge/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the upward bridge theorem `semantic_truth_implies_truth_at` which proves that if a formula is true in the finite model (via `w.models phi`), it is also true in the general semantics (via `truth_at (SemanticCanonicalModel phi) tau 0 phi`). The theorem completes `finite_model_property_constructive` in `FiniteModelProperty.lean` (line 481). The implementation requires infrastructure lemmas for bidirectional induction, bounded relevance for temporal operators, and canonical MCS propagation for modal operators.

### Research Integration

The research report (research-001.md) identified:
- **Easy cases**: Atom and Bot are straightforward
- **Medium cases**: Imp requires bidirectional induction (both directions simultaneously)
- **Hard cases**: Box requires canonical MCS propagation; temporal cases require bounded relevance lemma
- **Recommended order**: Bounded relevance first (most tractable), then bidirectional schema, then cases

## Goals & Non-Goals

**Goals**:
- Prove `semantic_truth_implies_truth_at` eliminating the sorry at line 481
- Implement the bounded relevance lemma for temporal operators
- Implement canonical MCS propagation for modal operators (if tractable)
- Establish bidirectional induction schema for Imp case

**Non-Goals**:
- Refactoring the existing completeness proof architecture
- Optimizing performance of the proof
- Proving related soundness/decidability theorems (already handled elsewhere)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Canonical MCS propagation may not be provable with current definitions | High | Medium | Fall back to S5 triviality argument or document as known limitation |
| Bounded relevance edge cases at domain boundaries | Medium | Medium | Careful case analysis with explicit domain membership proofs |
| Bidirectional induction increases proof complexity | Medium | Low | Use well-founded induction on formula size |
| Effort exceeds estimate (12-16h research estimate) | Medium | Medium | Implement easy cases first, reassess after Phase 3 |

## Implementation Phases

### Phase 1: Bounded Relevance Lemma [NOT STARTED]

**Goal**: Prove that truth at time 0 for a formula depends only on times within the temporal depth bound.

**Tasks**:
- [ ] Define `temporal_depth : Formula -> Nat` if not already present
- [ ] State the bounded relevance lemma: `truth_at M tau 0 psi` depends only on `tau` restricted to `[-k, k]` where `k = temporalDepth psi`
- [ ] Prove by structural induction on formula
- [ ] Handle base cases (atom, bot) - truth depends only on time 0
- [ ] Handle imp case - combine bounds from subformulas
- [ ] Handle box case - no temporal shift
- [ ] Handle temporal cases - show strict operators don't extend beyond depth

**Timing**: 3 hours

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModelProperty.lean` - Add bounded relevance lemma

**Verification**:
- Lemma compiles without sorry
- Can be applied in proof of temporal cases

---

### Phase 2: Bidirectional Induction Schema [NOT STARTED]

**Goal**: Establish the induction schema that proves both directions (models -> truth_at and truth_at -> models) simultaneously.

**Tasks**:
- [ ] Define mutual induction statement combining both directions
- [ ] Structure as `formula.recOn` with hypothesis carrying both implications
- [ ] Verify the induction hypothesis provides what each case needs
- [ ] Test with atom case to validate schema structure

**Timing**: 2 hours

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModelProperty.lean` - Add bidirectional induction lemma

**Verification**:
- Schema compiles and type-checks
- Can be instantiated for atom case

---

### Phase 3: Easy Cases (Atom, Bot, Imp) [NOT STARTED]

**Goal**: Prove the forward direction for atom, bot, and imp cases using the bidirectional schema.

**Tasks**:
- [ ] **Atom case**: Unfold definitions, use `semantic_valuation` definition to connect models to truth_at
- [ ] **Bot case**: Show premise is false via IsLocallyConsistent (bot = false)
- [ ] **Imp case**: Use bidirectional IH - assume truth_at psi, get models psi via reverse IH, combine with models (psi.imp chi), get models chi via imp_correct, apply forward IH

**Timing**: 2 hours

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModelProperty.lean` - Implement cases in main theorem

**Verification**:
- All three cases compile without sorry
- Type-checks with correct goal state progression

---

### Phase 4: Temporal Cases [NOT STARTED]

**Goal**: Prove the forward direction for all_past and all_future cases using bounded relevance.

**Tasks**:
- [ ] **all_future case**: For s > k (temporal depth), show atoms outside domain are handled by bounded relevance
- [ ] **all_past case**: Similar structure, for s < -k
- [ ] Handle domain boundary conditions (tau.domain s may be false for large s)
- [ ] Apply bounded relevance lemma to show truth only depends on bounded region
- [ ] Connect finite model evaluation to general truth_at via IH

**Timing**: 3 hours

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModelProperty.lean` - Implement temporal cases

**Verification**:
- Temporal cases compile without sorry
- Boundary conditions correctly handled

---

### Phase 5: Canonical MCS Propagation (Box Case) [NOT STARTED]

**Goal**: Prove the forward direction for the box case by showing box formulas propagate across all MCS-derived states.

**Tasks**:
- [ ] Investigate SemanticCanonicalFrame structure - verify all WorldHistories are MCS-derived
- [ ] State lemma: If box(psi) in any MCS S in the closure, then psi in all MCSes T in closure
- [ ] Attempt proof via S5 semantics (reflexive, symmetric, transitive accessibility)
- [ ] Alternative: Show modal equivalence relation is trivial (all states related)
- [ ] Apply propagation lemma in box case to show forall sigma, truth_at sigma 0 psi

**Timing**: 4 hours

**Files to modify**:
- `Logos/Metalogic_v2/SemanticCanonicalModel.lean` - Add MCS propagation lemma if needed
- `Logos/Metalogic_v2/FiniteModelProperty.lean` - Complete box case

**Verification**:
- Box case compiles without sorry
- All cases of semantic_truth_implies_truth_at proven

---

### Phase 6: Integration and Final Verification [NOT STARTED]

**Goal**: Combine all cases, verify the main theorem compiles, and ensure no regressions.

**Tasks**:
- [ ] Combine all cases into the main `semantic_truth_implies_truth_at` theorem
- [ ] Remove sorry from `finite_model_property_constructive` (line 481)
- [ ] Run `lake build` to verify no compilation errors
- [ ] Check no new sorries introduced
- [ ] Verify `main_provable_iff_valid_v2` still compiles

**Timing**: 1 hour

**Files to modify**:
- `Logos/Metalogic_v2/FiniteModelProperty.lean` - Final integration

**Verification**:
- `lake build` succeeds
- `grep sorry Logos/Metalogic_v2/*.lean` shows no new sorries
- Existing tests pass

## Testing & Validation

- [ ] `lake build` completes successfully for Metalogic_v2
- [ ] No new `sorry` statements introduced
- [ ] `finite_model_property_constructive` compiles without sorry at line 481
- [ ] Related theorems (`semantic_weak_completeness`, `main_provable_iff_valid_v2`) unaffected
- [ ] Manual review of proof structure for correctness

## Artifacts & Outputs

- `Logos/Metalogic_v2/FiniteModelProperty.lean` - Updated with upward bridge proof
- `Logos/Metalogic_v2/SemanticCanonicalModel.lean` - Updated with MCS propagation lemma (if needed)
- `specs/628_prove_semantic_truth_implies_truth_at_upward_bridge/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the canonical MCS propagation (Phase 5) proves intractable:
1. Document the specific difficulty in the summary
2. Leave box case as sorry with detailed comment explaining the blocker
3. Mark task as [PARTIAL] with clear resume instructions
4. Alternative: Accept the sorry as a known limitation with documented justification (research recommends this as acceptable since the bridge is not on the critical path)

If overall effort exceeds estimates:
1. Complete through Phase 4 (temporal cases) as minimum viable progress
2. The easy cases alone reduce the sorry scope significantly
3. Reassess Phase 5 approach before investing additional time
