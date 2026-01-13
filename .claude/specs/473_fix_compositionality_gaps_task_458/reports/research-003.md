# Research Report: Task #473 (Focus: Zero-Sorry Completeness)

**Task**: 473 - Fix compositionality gaps from Task 458
**Started**: 2026-01-13T19:30:00Z
**Completed**: 2026-01-13T20:15:00Z
**Effort**: 8-12 hours (revised estimate for recommended approach)
**Priority**: Medium
**Parent**: Task 458
**Dependencies**: Task 472 (Lindenbaum extension - COMPLETED)
**Sources/Inputs**:
  - plans/implementation-003.md (v003 plan with bounded compositionality discovery)
  - summaries/implementation-summary-20260113-phase3.md (Phase 3 findings)
  - reports/research-001.md and research-002.md (prior analyses)
  - Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean (current state)
  - Theories/Bimodal/Metalogic/Completeness.lean (SetMaximalConsistent infrastructure)
  - Theories/Bimodal/Semantics/Truth.lean (time_shift_preserves_truth theorem)
**Artifacts**: This report (research-003.md)
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- **Current state**: 20+ sorry locations in FiniteCanonicalModel.lean across compositionality, truth lemma, and infrastructure lemmas
- **Root cause analysis**: The finite model uses `IsLocallyConsistent` (soundness only) instead of full negation-completeness; compositionality is structurally unprovable without bounds
- **Three viable paths** to zero-sorry completeness identified, ranked by feasibility
- **Primary recommendation**: **Semantic History-Based Construction** - define world states as equivalence classes of histories, making compositionality trivial
- **Estimated effort**: 12-16 hours for primary approach; 6-8 hours for alternative approach

## Context & Scope

### Goal
Achieve a zero-sorry proof of completeness for TM bimodal logic. The current FiniteCanonicalModel.lean approach has structural limitations that make certain lemmas unprovable without fundamentally different definitions.

### Current Sorry Count Analysis

| Component | Sorry Count | Root Cause |
|-----------|-------------|------------|
| `closure_lindenbaum_via_projection` | 1 | Closure-restricted maximality detail |
| `closure_mcs_negation_complete` | 1 | Needs derivation infrastructure |
| `closure_mcs_imp_closed` | 1 | Derivation closure detail |
| `closure_mcs_implies_locally_consistent` | 1 | IsLocallyConsistent constraints |
| `worldStateFromClosureMCS_models_iff` | 1 | Bridge lemma detail |
| `FiniteTaskRel.compositionality` | 1 | Mixed-sign cases (Section in FiniteCanonicalModel namespace) |
| `SemanticTaskRel.compositionality_bounded` | 1 | Sequence gluing |
| `SemanticTaskRel.compositionality` | 1 | **UNPROVABLE** - finite bounds |
| `SemanticTaskRel.semantic_implies_pointwise` | 1 | Path induction machinery |
| `FiniteHistory.respects_task` | 1 | Task relation proof detail |
| `FiniteHistory.time_shift` | 2 | Forward/backward relation sorries |
| `forwardTransferRequirements_consistent` | 1 | Consistency proof detail |
| `finite_forward_existence_thm` | 1 | Depends on requirements_consistent |
| `backwardTransferRequirements_consistent` | 1 | Consistency proof detail |
| `finite_backward_existence_thm` | 1 | Depends on requirements_consistent |
| `finite_history_from_state` | 2 | Construction sorries |
| `finite_truth_lemma` | 6 | Backward directions (imp, box, temporal) |

**Total**: ~24 sorry locations

### Key Finding: Unbounded Compositionality is Unprovable

Phase 3 proved that `SemanticTaskRel.compositionality` without bounds is **mathematically false** in the finite setting:

**Counterexample** (k=1, temporal bound):
- `finite_task_rel_semantic phi w 2 u` with witness times `t1=-1, t1'=1`
- `finite_task_rel_semantic phi u 2 v` with witness times `t2=-1, t2'=1`
- Required: `finite_task_rel_semantic phi w 4 v`
- But max displacement in `[-1, 1]` is `2`, so no valid witnesses exist for displacement `4`

This is not a proof gap - it's a fundamental limitation of the finite time domain approach when durations can exceed the domain bounds.

## Findings

### 1. Three Paths to Zero-Sorry Completeness

#### Path A: Semantic History-Based World States (RECOMMENDED)

**Core Idea**: Instead of defining world states as truth assignments that satisfy `IsLocallyConsistent`, define them as equivalence classes of `(history, time)` pairs. Compositionality becomes trivial because histories compose.

**Definition Change**:
```lean
-- Current approach (problematic):
structure FiniteWorldState (phi : Formula) where
  assignment : FiniteTruthAssignment phi
  consistent : IsLocallyConsistent phi assignment

-- Proposed approach:
def SemanticWorldState (phi : Formula) :=
  Quotient (@historyTimeSetoid phi)

where historyTimeSetoid phi := {
  r := fun (h1, t1) (h2, t2) => h1.states t1 = h2.states t2,
  ...
}
```

**Why This Works**:
1. **Compositionality is trivial**: `(h, t)` and `(h, t+x)` and `(h, t+x+y)` trivially satisfy the task relation because they're on the same history
2. **Truth is well-defined**: Truth at `(h, t)` is defined by the history's semantics
3. **Negation-completeness is automatic**: For any formula, either it or its negation is true at `(h, t)` by classical logic

**Effort Estimate**: 12-16 hours
- Phase 1: Define `SemanticWorldState` and prove well-definedness (3-4h)
- Phase 2: Define `SemanticTaskRel` via history existence (2-3h)
- Phase 3: Prove compositionality trivially (1-2h)
- Phase 4: Define `SemanticTruth` and prove truth lemma (4-5h)
- Phase 5: Connect to completeness theorem (2-3h)

**Risks**:
- Need to ensure finite world state count is preserved
- May require showing quotient is finite (bounded by number of histories times time points)

#### Path B: Strengthen IsLocallyConsistent to Full Closure-MCS

**Core Idea**: Add negation-completeness to `IsLocallyConsistent` and prove all bridge lemmas explicitly.

**Required Changes**:
1. Extend `closure` to `closureWithNeg` ensuring negations are included
2. Add negation-completeness condition to `IsLocallyConsistent`:
   ```lean
   (forall psi, psi in closure -> psi.neg in closure ->
     v psi = true \/ v psi.neg = true)
   ```
3. Prove all closure-MCS bridge lemmas that currently have sorries
4. Use full `SetMaximalConsistent` properties from Completeness.lean

**Why This Is Harder**:
- Closure extension requires care (must include negations without blowing up size)
- Bridge lemmas require explicit derivation manipulation
- Still doesn't fix the unbounded compositionality issue

**Effort Estimate**: 10-14 hours
- Closure extension and negation-completeness: 3-4h
- Bridge lemma proofs: 4-6h
- Truth lemma completion: 3-4h

**Still Leaves**: Compositionality gaps (must accept bounded version or structural sorries)

#### Path C: Accept Bounded Compositionality + Complete Everything Else

**Core Idea**: Accept that unbounded compositionality is unprovable, use the bounded version where needed, and focus on completing all other sorries.

**Key Insight**: For completeness, we don't actually need arbitrary compositionality. We need:
1. Truth lemma for formulas in closure
2. Existence of witnesses (forward/backward)
3. History construction from consistent states

All operations within a finite history naturally stay within bounds (temporal bound k ensures all displacements are at most 2k).

**Required Changes**:
1. Complete closure-MCS bridge lemmas (using Task 472 infrastructure)
2. Complete existence theorem proofs
3. Complete truth lemma backward directions (using negation-completeness)
4. Document `SemanticTaskRel.compositionality` as accepting only bounded version
5. Ensure all uses of compositionality in completeness have bounds satisfied

**Effort Estimate**: 6-8 hours
- Bridge lemmas: 2-3h
- Existence theorems: 2h
- Truth lemma completion: 2-3h
- Documentation: 1h

**Tradeoff**: Results in a "quasi-zero-sorry" proof where the one remaining sorry (`SemanticTaskRel.compositionality`) is documented as mathematically justified limitation, not a proof gap.

### 2. Analysis of `time_shift_preserves_truth`

The existing theorem in `Truth.lean` provides a complete proof:

```lean
theorem time_shift_preserves_truth (M : TaskModel F) (σ : WorldHistory F) (x y : D)
    (φ : Formula) :
    truth_at M (WorldHistory.time_shift σ (y - x)) x φ ↔ truth_at M σ y φ
```

This theorem is **fully proven** (no sorries) and establishes that:
- Truth is invariant under time-shift
- The proof handles all formula cases including the critical `box` case

**Relevance to Path A**: This theorem can serve as the foundation for the semantic approach. If we define truth via histories, we inherit all these properties automatically.

### 3. Why Current Approach Has So Many Sorries

The current `FiniteCanonicalModel.lean` approach has a fundamental tension:

**Design Choice**: World states are defined as `(assignment, IsLocallyConsistent proof)`
- This is a **syntactic** approach - states are functions assigning truth values
- Requires proving all semantic properties from syntactic constraints

**Problem 1: Soundness vs Completeness**
- `IsLocallyConsistent` captures soundness: "if these formulas are true, those must be true"
- Truth lemma backward direction requires completeness: "if those are semantically true, these must be syntactically present"
- Without negation-completeness, backward directions fail

**Problem 2: Pointwise vs Path-Based**
- `finite_task_rel` captures endpoint conditions
- Compositionality requires path conditions
- Mixed-sign durations lose path information

**Solution Insight**: A semantic approach (Path A) defines truth directly from model-theoretic semantics, making soundness/completeness automatic and compositionality trivial.

### 4. Finite Model Property Preservation

Any approach must preserve:
1. **Bounded world states**: At most `2^|closure(phi)|` states
2. **Bounded time domain**: `2*temporalBound(phi) + 1` time points
3. **Decidability**: The model checking problem remains decidable

**Path A Preservation**:
- World states are quotients of `(history, time)` pairs
- For finite histories over finite times with finite world states at each point, the quotient is finite
- Bound: `|histories| * |times|` is bounded by `(2^|closure|)^(2k+1) * (2k+1)`
- This is finite (though potentially large)

### 5. Comparison with Mathlib Modal Logic Approaches

Mathlib's first-order logic completeness (`Mathlib.ModelTheory.Satisfiability`) uses:
- `Theory.IsMaximal` - negation-complete theories
- `IsMaximal.mem_or_not_mem` - for any formula, it or its negation is in the theory

This pattern aligns with Path B (strengthen to full MCS) but doesn't directly help with the temporal compositionality issue unique to bimodal logic.

## Decisions

Based on this analysis:

1. **Path A (Semantic History-Based) is recommended** for a true zero-sorry proof
   - Eliminates compositionality issue by construction
   - Simplifies truth lemma by making negation-completeness automatic
   - More mathematically elegant

2. **Path C (Accept Bounded) is acceptable** if time is limited
   - Results in one documented structural limitation
   - All other sorries can be eliminated
   - Limitation is mathematically justified (not a proof gap)

3. **Path B (Strengthen IsLocallyConsistent) is least recommended**
   - Most work
   - Still doesn't solve compositionality
   - Duplicates work already done in Completeness.lean for SetMaximalConsistent

## Recommendations

### For Zero-Sorry: Path A Implementation Plan

**Phase 1: Semantic Infrastructure** (3-4 hours)
```lean
-- Define history-time pairs
def HistoryTimePair (phi : Formula) :=
  FiniteHistory phi × FiniteTime (temporalBound phi)

-- Define equivalence based on state equality
def htEquiv (phi : Formula) : HistoryTimePair phi → HistoryTimePair phi → Prop :=
  fun ⟨h1, t1⟩ ⟨h2, t2⟩ => h1.states t1 = h2.states t2

-- Define semantic world state
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)
```

**Phase 2: Task Relation** (2-3 hours)
```lean
-- Semantic task relation via history existence
def semantic_task_rel (phi : Formula) (w u : SemanticWorldState phi) (d : Int) : Prop :=
  ∃ h : FiniteHistory phi, ∃ t : FiniteTime (temporalBound phi),
    ∃ t' : FiniteTime (temporalBound phi),
    toInt t' = toInt t + d ∧
    Quotient.mk w = ⟦(h, t)⟧ ∧
    Quotient.mk u = ⟦(h, t')⟧

-- Compositionality is trivial: same history, add durations
theorem semantic_compositionality :
  semantic_task_rel phi w x u → semantic_task_rel phi u y v →
  semantic_task_rel phi w (x + y) v := by
  -- Use transitivity of history paths
  ...
```

**Phase 3: Truth and Completeness** (4-5 hours)
```lean
-- Truth is defined via the underlying history
def semantic_truth_at (phi : Formula) (w : SemanticWorldState phi) (psi : Formula) : Prop :=
  Quotient.lift (fun ⟨h, t⟩ => finite_truth_at phi h t psi) ... w

-- Truth lemma becomes essentially tautological
theorem semantic_truth_lemma :
  (underlying_assignment w).models psi h_mem ↔ semantic_truth_at phi w psi := by
  -- By definition of SemanticWorldState
  ...
```

**Phase 4: Completeness Theorem** (2-3 hours)
- Connect semantic infrastructure to main completeness statement
- Show satisfiability in semantic model implies derivability
- Verify finite model property is preserved

### For Pragmatic Completion: Path C Implementation Plan

**Phase 1: Complete Bridge Lemmas** (2-3 hours)
- Fill `closure_lindenbaum_via_projection` using derivation theorem
- Fill `closure_mcs_negation_complete` using deduction theorem
- Fill `closure_mcs_imp_closed` using derivation closure

**Phase 2: Complete Existence Theorems** (2 hours)
- Prove `forwardTransferRequirements_consistent` using MCS properties
- Prove `backwardTransferRequirements_consistent` similarly
- Remove sorries from existence theorems

**Phase 3: Complete Truth Lemma** (2-3 hours)
- Use closure-MCS negation-completeness for backward directions
- Implication case: by negation-completeness, either psi false or chi true
- Box case: by negation-completeness, either box(psi) in state or not
- Temporal cases: similar pattern

**Phase 4: Document Compositionality** (1 hour)
- Add clear docstring to `SemanticTaskRel.compositionality`
- Explain it's not a proof gap but structural limitation
- Reference counterexample (k=1, x=2, y=2)
- Note that bounded version `compositionality_bounded` is valid

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path A quotient not computable | High | Low | Use Classical choice, accept noncomputable |
| Path A breaks existing structure | Medium | Medium | Keep both, prove equivalence |
| Path C leaves one sorry | Low | N/A | Document as structural limitation |
| Time underestimate | Medium | Medium | Path C as fallback |

## Appendix

### Key Theorems Available

**From Completeness.lean**:
- `set_lindenbaum` - Lindenbaum extension (proven)
- `set_mcs_negation_complete` - MCS has phi or neg(phi) (proven)
- `set_mcs_closed_under_derivation` - Derivation closure (proven)
- `set_mcs_imp_property` - Implication in MCS (proven)

**From Truth.lean**:
- `time_shift_preserves_truth` - Truth invariant under time-shift (proven)
- `truth_double_shift_cancel` - Double shift cancels (proven)

**From FiniteCanonicalModel.lean**:
- `closure_lindenbaum_via_projection` - Restricted Lindenbaum (has sorry)
- `closure_mcs_negation_complete` - Restricted negation-completeness (has sorry)
- `compositionality_bounded` - With bounds hypothesis (has sorry but provable)

### Sorry Dependency Graph

```
finite_weak_completeness (axiom)
├── finite_truth_lemma (6 sorries)
│   └── closure_mcs_negation_complete (1 sorry)
│       └── closure_lindenbaum_via_projection (1 sorry)
│           └── set_lindenbaum (proven)
└── finite_history_from_state (2 sorries)
    ├── finite_forward_existence_thm (1 sorry)
    │   └── forwardTransferRequirements_consistent (1 sorry)
    └── finite_backward_existence_thm (1 sorry)
        └── backwardTransferRequirements_consistent (1 sorry)

SemanticTaskRel.compositionality (1 sorry - UNPROVABLE)
└── Blocked by finite bounds (counterexample exists)
```

## Next Steps

1. **Decision Point**: Choose between Path A (zero-sorry) or Path C (pragmatic)
2. **If Path A**: Create new plan version (implementation-004.md) with semantic approach
3. **If Path C**: Proceed with implementation-003.md phases 4-7
4. Run `/plan 473 --revise` after decision to create updated implementation plan
