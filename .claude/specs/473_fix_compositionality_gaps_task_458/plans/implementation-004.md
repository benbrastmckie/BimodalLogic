# Implementation Plan: Task #473

- **Task**: 473 - Fix compositionality gaps from Task 458
- **Status**: [NOT STARTED]
- **Effort**: 10-12 hours
- **Priority**: Medium
- **Dependencies**: Task 472 (Lindenbaum extension - COMPLETED)
- **Research Inputs**: reports/research-003.md (Path A: Semantic History-Based World States)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements **Path A: Semantic History-Based World States** from research-003.md to achieve zero-sorry completeness for TM bimodal logic. The core insight is that defining world states as equivalence classes of `(history, time)` pairs makes compositionality trivial by construction, since paths compose naturally within histories.

### Research Integration

**Integrated from research-003.md**:
- Root cause: Current `IsLocallyConsistent` captures soundness only, not negation-completeness
- Key insight: Unbounded `SemanticTaskRel.compositionality` is mathematically false in finite setting (counterexample: k=1, x=2, y=2)
- Solution: Semantic approach where world states ARE history-time pairs, making compositionality trivial
- Proof: `time_shift_preserves_truth` in Truth.lean already provides the semantic foundation

## Goals & Non-Goals

**Goals**:
- Define `SemanticWorldState` as quotient of `(FiniteHistory, FiniteTime)` pairs
- Define `semantic_task_rel` via history existence (compositionality becomes trivial)
- Prove truth lemma using history-based semantics
- Connect semantic infrastructure to completeness theorem
- Eliminate all 24+ sorries in FiniteCanonicalModel.lean

**Non-Goals**:
- Removing the existing pointwise approach (keep for reference and potential alternative proofs)
- Optimizing computational efficiency (focus on correctness first)
- Full constructive proofs (Classical.choice is acceptable)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Quotient not finite | High | Low | Prove bound: histories * times finite |
| History existence proof hard | Medium | Medium | Use existing forward/backward existence theorems |
| Truth well-definedness fails | High | Low | Equivalence preserves truth by time_shift_preserves_truth |
| Breaks existing structure | Medium | Medium | Add new definitions, keep old ones |

## Implementation Phases

### Phase 1: Define SemanticWorldState Infrastructure [NOT STARTED]

**Goal**: Create the foundation for semantic world states as quotient of history-time pairs

**Tasks**:
- [ ] Define `HistoryTimePair phi := FiniteHistory phi × FiniteTime (temporalBound phi)`
- [ ] Define equivalence relation `htEquiv`: `(h1, t1) ~ (h2, t2)` iff `h1.states t1 = h2.states t2`
- [ ] Prove `htEquiv` is reflexive, symmetric, transitive
- [ ] Define `htSetoid : Setoid (HistoryTimePair phi)` using `htEquiv`
- [ ] Define `SemanticWorldState phi := Quotient (htSetoid phi)`
- [ ] Prove `SemanticWorldState phi` is finite (bounded by histories * times)
- [ ] Define `underlying_assignment : SemanticWorldState phi → FiniteTruthAssignment phi`

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Add new section for semantic world states

**Verification**:
- `lean_diagnostic_messages` shows no errors for new definitions
- `SemanticWorldState` compiles without sorry

---

### Phase 2: Define Semantic Task Relation [NOT STARTED]

**Goal**: Define task relation via history existence, making compositionality trivial by construction

**Tasks**:
- [ ] Define `semantic_task_rel phi w d u : Prop` as existence of history and valid times
- [ ] Prove `semantic_task_rel_refl`: `semantic_task_rel phi w 0 w`
- [ ] Prove `semantic_task_rel_compositionality`: `semantic_task_rel phi w x u → semantic_task_rel phi u y v → semantic_task_rel phi w (x+y) v`
- [ ] The key insight: compositionality proof uses the SAME history for both steps
- [ ] Prove bounds are automatically satisfied within a single history

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- `semantic_task_rel_compositionality` compiles without sorry
- Contrast with current `SemanticTaskRel.compositionality` which has sorry

---

### Phase 3: Prove Truth Well-Definedness [NOT STARTED]

**Goal**: Show truth at semantic world states is well-defined (independent of representative)

**Tasks**:
- [ ] Define `semantic_truth_at phi (w : SemanticWorldState phi) psi : Prop`
- [ ] Use `Quotient.lift` to lift truth from representatives
- [ ] Prove the key lemma: if `h1.states t1 = h2.states t2`, then `finite_truth_at phi h1 t1 psi ↔ finite_truth_at phi h2 t2 psi`
- [ ] This follows from `time_shift_preserves_truth` in Truth.lean pattern
- [ ] Prove truth respects equivalence for all formula cases

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- `semantic_truth_at` compiles without sorry
- Truth well-definedness lemma proven completely

---

### Phase 4: Prove Semantic Truth Lemma [NOT STARTED]

**Goal**: Prove the truth lemma for semantic world states

**Tasks**:
- [ ] Prove `semantic_truth_lemma`: `underlying_assignment w |= psi ↔ semantic_truth_at phi w psi`
- [ ] Atom case: By definition of underlying_assignment
- [ ] Bot case: By consistency of histories
- [ ] Imp case: By structural induction
- [ ] Box case: Requires showing all histories agree at same state (this is where quotient helps)
- [ ] All_past case: Use semantic task relation for past times
- [ ] All_future case: Use semantic task relation for future times
- [ ] The key: negation-completeness is automatic since we're working with actual histories

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- `semantic_truth_lemma` compiles without sorry
- All formula cases proven

---

### Phase 5: Connect to Completeness Theorem [NOT STARTED]

**Goal**: Connect semantic infrastructure to main completeness statement

**Tasks**:
- [ ] Prove `semantic_weak_completeness`: valid implies provable using semantic model
- [ ] Show satisfiability in semantic model from consistent set
- [ ] Use Lindenbaum extension (from Task 472) to get maximal consistent set
- [ ] Construct history from maximal consistent set
- [ ] Verify finite model property preserved (model is still finite)
- [ ] Update `finite_weak_completeness` to use semantic infrastructure
- [ ] Prove or remove old sorries that are now obsolete

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- `semantic_weak_completeness` compiles without sorry
- Old sorries either proven or documented as obsolete

---

### Phase 6: Clean Up and Verify Zero-Sorry [NOT STARTED]

**Goal**: Ensure all sorries are eliminated and proofs are complete

**Tasks**:
- [ ] Run `lean_diagnostic_messages` on full file
- [ ] List any remaining sorries
- [ ] Either complete remaining sorries or document why they are acceptable
- [ ] Verify the main completeness theorem is fully proven
- [ ] Add documentation explaining the semantic approach
- [ ] Consider whether to keep or remove old pointwise infrastructure

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`

**Verification**:
- `lean_diagnostic_messages` shows 0 sorries (or documented acceptable ones)
- File compiles without errors
- Main completeness theorem is fully proven

## Testing & Validation

- [ ] `lean_diagnostic_messages` on FiniteCanonicalModel.lean shows no errors
- [ ] `lean_goal` at key theorem locations shows "no goals" (proofs complete)
- [ ] `lake build` succeeds for full project
- [ ] `SemanticTaskRel.compositionality` equivalent proven without sorry (key metric)
- [ ] `finite_truth_lemma` equivalent proven without sorry
- [ ] `finite_weak_completeness` proven without sorry

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Updated with semantic approach
- `.claude/specs/473_fix_compositionality_gaps_task_458/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If semantic approach fails:
1. All new code is additive (old definitions preserved)
2. Can revert to old approach by removing new `Semantic*` definitions
3. Fall back to Path C (Accept Bounded Compositionality) if necessary
4. Path C effort estimate: 6-8 hours, results in one documented structural limitation

## Technical Details

### Why This Approach Works

The key insight from research-003.md is that compositionality fails in the current approach because:

1. **Pointwise relation** loses path information - mixed-sign cases can't compose
2. **Unbounded semantic relation** is mathematically false in finite setting

The semantic world state approach fixes both:

1. **World states ARE paths** (equivalence classes of history-time pairs)
2. **Compositionality is trivial**: same history, add durations
3. **Bounds are automatic**: within a single history, all operations stay in bounds
4. **Truth is well-defined**: equivalent history-time pairs have same state, thus same truth

### Core Definitions

```lean
-- Phase 1: Infrastructure
def HistoryTimePair (phi : Formula) := FiniteHistory phi × FiniteTime (temporalBound phi)

def htEquiv (phi : Formula) (p1 p2 : HistoryTimePair phi) : Prop :=
  p1.1.states p1.2 = p2.1.states p2.2

def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)

-- Phase 2: Task Relation
def semantic_task_rel (phi : Formula) (w u : SemanticWorldState phi) (d : Int) : Prop :=
  Quotient.liftOn₂ w u (fun p1 p2 =>
    ∃ h : FiniteHistory phi, ∃ t t' : FiniteTime (temporalBound phi),
      toInt t' = toInt t + d ∧
      h.states t = p1.1.states p1.2 ∧
      h.states t' = p2.1.states p2.2) ...

-- Compositionality is now trivial:
theorem semantic_compositionality : semantic_task_rel phi w x u →
    semantic_task_rel phi u y v → semantic_task_rel phi w (x + y) v :=
  -- Use the SAME history for both, just extend the path
```

### Expected Sorry Elimination

| Component | Current State | After Plan |
|-----------|---------------|------------|
| Compositionality (unbounded) | Sorry (unprovable) | Trivial (by construction) |
| Truth lemma backward | 6 sorries | 0 (negation-completeness automatic) |
| History construction | 2 sorries | 0 (histories define states) |
| Bridge lemmas | 3+ sorries | 0 (not needed in semantic approach) |
| Existence theorems | 2 sorries | 0 (history existence = state existence) |
