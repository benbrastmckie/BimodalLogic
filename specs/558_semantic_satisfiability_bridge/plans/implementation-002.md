# Implementation Plan: Task #558 (Revised)

- **Task**: 558 - Semantic Satisfiability Bridge
- **Version**: 002
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: Task 557 (completed)
- **Research Inputs**: specs/558_semantic_satisfiability_bridge/reports/research-003.md
- **Previous Plan**: plans/implementation-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Session**: sess_1768690334_f9be2b

## Revision Summary

**User Guidance**: The results in Bimodal/Metalogic/ can serve as *inspiration only*. They should NOT be imported or distract from the Metalogic_v2 reorganization. The goal is to make the **representation theorem** the foundation from which completeness and other results are derived. The Metalogic/ directory will be deleted once Metalogic_v2/ is complete.

**Key Changes from v001**:
1. Added explicit Non-Goals about Metalogic/ imports
2. Added Architectural Constraints section
3. Emphasized representation-first approach
4. Clarified the axiom `representation_theorem_backward_empty` as a future completeness target
5. Added verification step to ensure no Metalogic/ imports

## Overview

This task implements two critical theorems in `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`:
- `subformulaList_finite`: Bound on subformula list length
- `consistent_implies_satisfiable`: Consistency implies satisfiability

These theorems are part of the **representation-first architecture** where the representation theorem serves as the foundation from which completeness and the FMP are derived.

### Metalogic_v2 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Metalogic_v2 Layer Hierarchy             │
├─────────────────────────────────────────────────────────────┤
│  Applications/                                              │
│    Compactness.lean         (uses FMP)                     │
├─────────────────────────────────────────────────────────────┤
│  Completeness/                                              │
│    WeakCompleteness.lean    (uses representation)          │
│    StrongCompleteness.lean  (uses representation)          │
├─────────────────────────────────────────────────────────────┤
│  Representation/  ◄── THIS TASK                            │
│    FiniteModelProperty.lean (subformulaList_finite,        │
│                             consistent_implies_satisfiable)│
│    RepresentationTheorem.lean (FOUNDATION)                 │
│    ContextProvability.lean  (valid_implies_derivable)      │
│    TruthLemma.lean                                         │
│    CanonicalModel.lean      (Task 557 complete)            │
├─────────────────────────────────────────────────────────────┤
│  Core/                                                      │
│    Basic.lean, Provability.lean, etc.                      │
├─────────────────────────────────────────────────────────────┤
│  Soundness/                                                 │
│    Soundness.lean           (proven)                       │
└─────────────────────────────────────────────────────────────┘
```

### Research Integration

Research-003.md confirms proof strategies:
- `subformulaList_finite`: Structural induction + omega tactic (30-45 min)
- `consistent_implies_satisfiable`: Contrapositive via `valid_implies_derivable` (30-60 min)
- Task 557 completed: mcs_contains_or_neg, mcs_modus_ponens, extract_neg_derivation

## Goals & Non-Goals

**Goals**:
- Prove `complexity_pos` helper lemma (formula complexity >= 1)
- Prove `subformulaList_finite` (bounded list length)
- Prove `consistent_implies_satisfiable` (consistency → satisfiability)
- Maintain Metalogic_v2 self-containment
- Support the representation-first architecture

**Non-Goals**:
- **DO NOT** import from `Bimodal.Metalogic` (the old directory)
- **DO NOT** reference or adapt code from `Metalogic/Completeness.lean`
- **DO NOT** reference `Metalogic/FiniteCanonicalModel.lean` directly (use Metalogic_v2 equivalents)
- Proving `representation_theorem_backward_empty` (Task 560 scope, currently accepted axiom)
- Constructing explicit TaskModel from CanonicalWorldState (alternative approach)

## Architectural Constraints

### Import Policy

**ALLOWED imports** (all within Metalogic_v2 or shared):
```lean
import Bimodal.Metalogic_v2.Representation.RepresentationTheorem
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Metalogic_v2.Core.*
import Bimodal.Semantics.Validity
import Bimodal.ProofSystem
import Bimodal.Syntax
```

**FORBIDDEN imports**:
```lean
-- DO NOT ADD:
-- import Bimodal.Metalogic.Completeness
-- import Bimodal.Metalogic.FiniteCanonicalModel
-- import Bimodal.Metalogic.*  (any import from old directory)
```

### Axiom Dependency

The proof of `consistent_implies_satisfiable` uses:
```lean
valid_implies_derivable  -- from ContextProvability.lean
  └── representation_theorem_backward_empty  -- AXIOM (to be proven in Task 560)
```

This is **acceptable** because:
1. The axiom represents a valid mathematical statement (completeness backward direction)
2. Task 560 will prove this axiom, eliminating the dependency
3. The axiom is scoped to Metalogic_v2, not imported from Metalogic/

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidental Metalogic/ import | High | Low | Verify imports at end of each phase |
| Arithmetic complexity in imp case | Medium | Medium | Pre-prove helper lemma if omega struggles |
| DerivationTree.weakening signature mismatch | Low | Low | Use lean_hover_info to verify signatures |
| Axiom creates circular reasoning | Low | Very Low | Axiom is standard; Task 560 will prove it |

## Implementation Phases

### Phase 1: Prove complexity_pos helper lemma [NOT STARTED]

**Goal**: Establish all formulas have complexity >= 1.

**Tasks**:
- [ ] Add `complexity_pos` lemma after `complexity` definition (around line 70-80)
- [ ] Proof: `cases phi <;> simp [Formula.complexity] <;> omega`
- [ ] Verify compilation with `lean_diagnostic_messages`

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`

**Verification**:
- [ ] Lean compiles without errors
- [ ] `complexity_pos` accessible to Phase 2

---

### Phase 2: Prove subformulaList_finite [NOT STARTED]

**Goal**: Prove `(subformulaList φ).length < 2 ^ Formula.complexity φ + 1`

**Tasks**:
- [ ] Replace sorry at line 81 with induction: `induction phi with`
- [ ] Base cases (atom, bot): `simp [subformulaList, complexity] <;> omega`
- [ ] Imp case: Apply IH to ψ and χ, use `complexity_pos`, omega for bound
- [ ] Modal cases (box, all_past, all_future): Apply IH and omega
- [ ] If omega struggles, add intermediate arithmetic lemma

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` (line 81)

**Verification**:
- [ ] All cases covered (6 constructors)
- [ ] No sorry remains
- [ ] No Metalogic/ imports added

---

### Phase 3: Prove consistent_implies_satisfiable [NOT STARTED]

**Goal**: Bridge consistency to semantic satisfiability via contrapositive.

**Strategy** (from research-003):
1. Assume `Consistent [φ]`
2. Assume `¬formula_satisfiable φ` (for contradiction)
3. Then `neg φ` is valid (true everywhere, since φ nowhere true)
4. By `valid_implies_derivable`, get `ContextDerivable [] (neg φ)`
5. By weakening, `[φ] ⊢ neg φ`
6. Since `[φ] ⊢ φ` (assumption), and `[φ] ⊢ neg φ`
7. Apply `derives_bot_from_phi_neg_phi` to derive bot
8. Contradiction with `Consistent [φ]`

**Tasks**:
- [ ] Replace sorry at line 162 with `by_contra h_not_sat`
- [ ] Show `neg φ` is valid from unsatisfiability
- [ ] Apply `valid_implies_derivable` from ContextProvability.lean
- [ ] Use `DerivationTree.weakening` for `[φ] ⊢ neg φ`
- [ ] Build `[φ] ⊢ φ` using `DerivationTree.assumption`
- [ ] Apply `derives_bot_from_phi_neg_phi` for contradiction
- [ ] Complete proof with contradiction

**Timing**: 30-60 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` (line 162)

**Verification**:
- [ ] Proof compiles without errors
- [ ] Uses only Metalogic_v2 infrastructure
- [ ] No new axioms beyond accepted `representation_theorem_backward_empty`

---

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic_v2.Representation.FiniteModelProperty` succeeds
- [ ] No new sorries introduced
- [ ] Downstream files compile (RepresentationTheorem.lean, StrongCompleteness.lean)
- [ ] **CRITICAL**: Verify no imports from `Bimodal.Metalogic.*`
  ```bash
  grep -n "import Bimodal.Metalogic\." Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean
  # Should return empty
  ```

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`
- Summary: `specs/558_semantic_satisfiability_bridge/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails:
1. `git checkout Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean`
2. Document specific blocker
3. Update task status to [BLOCKED]
4. Create follow-up task if needed

**Note**: Do NOT fall back to importing Metalogic/ infrastructure. If proofs require results from Metalogic/, those results should be re-proven within Metalogic_v2/ (potentially as new tasks).
