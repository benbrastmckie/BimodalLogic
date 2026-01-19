# Implementation Plan: Task #597 (Version 2)

- **Task**: 597 - Re-prove main_provable_iff_valid in Metalogic_v2
- **Status**: [NOT STARTED]
- **Effort**: 20-30 hours (zero technical debt solution)
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**:
  - specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-001.md
  - specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-002.md
  - specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-003.md (primary)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: plans/implementation-001.md (blocked at Phase 2)

## Overview

Implement a **zero technical debt** solution for `main_provable_iff_valid` in Metalogic_v2 by building a new `SemanticCanonicalModel_v2` that bridges canonical truth (MCS membership) to semantic truth (TaskModel evaluation). This enables complete independence from the old Metalogic/ directory.

### Key Insight from Research

The entire old Metalogic dependency stems from a **single import on line 9 of ContextProvability.lean**. The missing component is a bridge between:

1. **Canonical Truth** (`canonicalTruthAt w phi`): Defined as `phi ∈ w.carrier` (MCS membership)
2. **Semantic Truth** (`truth_at M tau t phi`): Defined recursively over formula structure in TaskModel

Building `SemanticCanonicalModel_v2` with a proper truth correspondence lemma eliminates this dependency.

## Goals & Non-Goals

**Goals**:
- Build complete `SemanticCanonicalModel_v2` infrastructure in Metalogic_v2
- Prove `main_provable_iff_valid` using only Metalogic_v2 infrastructure
- Remove old Metalogic import from ContextProvability.lean (line 9)
- Achieve full independence from Theories/Bimodal/Metalogic/ directory
- Zero sorries in all new proofs
- Zero technical debt (no copied code, clean architecture)

**Non-Goals**:
- Copy/paste from old Metalogic (creates technical debt)
- Accept the current implementation as "good enough"
- Delete old Metalogic directory (separate deprecation task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth correspondence lemma complexity | High | High | Start with Phase 3 PoC; use structural induction pattern from old Metalogic as reference |
| Temporal operator handling | Medium | Medium | Borrow FiniteTime/FiniteHistory infrastructure design (not code) from old Metalogic |
| Bounded time domain edge cases | Medium | Low | Accept some sorries in edge cases if necessary (documented) |
| Build issues during migration | Low | Medium | Incremental changes with `lake build` after each file |
| Effort underestimation | Medium | Medium | Buffer time in Phase 5; each phase has 2-hour buffer |

## Implementation Phases

### Phase 1: Closure Infrastructure [NOT STARTED]

**Goal**: Build finite subformula infrastructure needed for semantic bridge.

**Estimated Effort**: 4-6 hours

**Files to create**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` (NEW, ~200 lines)

**Key Definitions**:
```lean
-- Subformula closure with negations (for negation completeness)
def closureWithNeg (phi : Formula) : Set Formula :=
  closure phi ∪ (Formula.neg '' closure phi)

-- Closure-restricted maximal consistency
def ClosureMaximalConsistent (phi : Formula) (S : Set Formula) : Prop :=
  S ⊆ closureWithNeg phi ∧
  (∀ L : List Formula, (∀ psi ∈ L, psi ∈ S) → Consistent L) ∧
  (∀ psi ∈ closureWithNeg phi, psi ∉ S → ¬SetConsistent (insert psi S))

-- Project full MCS to closure
def mcs_projection (phi : Formula) (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Set Formula := M ∩ closureWithNeg phi

-- Key theorem: projection preserves closure-MCS property
theorem mcs_projection_is_closure_mcs (phi : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    ClosureMaximalConsistent phi (mcs_projection phi M h_mcs)
```

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.Closure` succeeds
- All definitions have no sorries

---

### Phase 2: Finite World State [NOT STARTED]

**Goal**: Define world states as truth assignments on closure.

**Estimated Effort**: 4-6 hours

**Files to create**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean` (NEW, ~150 lines)

**Key Definitions**:
```lean
-- Finite time bounded by temporal depth of formula
def temporalBound (phi : Formula) : Nat := -- maximal temporal nesting depth

-- Finite time type
def FiniteTime (bound : Nat) : Type := Fin (bound + 1)

-- Finite world state: truth assignment on closure
structure FiniteWorldState (phi : Formula) where
  assignment : closureWithNeg phi → Bool
  consistent : -- no formula and its negation both true
  negation_complete : -- for each psi in closure, has psi or neg psi

-- Build from closure MCS
def worldStateFromClosureMCS (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) : FiniteWorldState phi

-- Truth at finite world state
def finite_models (w : FiniteWorldState phi) (psi : Formula)
    (h_mem : psi ∈ closure phi) : Prop := w.assignment ⟨psi, ...⟩ = true
```

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.FiniteWorldState` succeeds
- All definitions have no sorries

---

### Phase 3: Semantic Canonical Model (CRITICAL PATH) [NOT STARTED]

**Goal**: Build TaskModel from canonical construction with truth correspondence.

**Estimated Effort**: 6-8 hours

**Files to create**:
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` (NEW, ~400 lines)

**Key Definitions**:
```lean
-- Finite history: sequence of finite world states
structure FiniteHistory (phi : Formula) where
  states : FiniteTime (temporalBound phi) → FiniteWorldState phi

-- Equivalence on history-time pairs: same underlying world state
def htEquiv (phi : Formula) :
    (FiniteHistory phi × FiniteTime (temporalBound phi)) →
    (FiniteHistory phi × FiniteTime (temporalBound phi)) → Prop :=
  fun ⟨h1, t1⟩ ⟨h2, t2⟩ => h1.states t1 = h2.states t2

-- Semantic world state (quotient of history-time pairs)
def SemanticWorldState_v2 (phi : Formula) : Type :=
  Quotient (htEquiv_setoid phi)

-- Semantic canonical frame
def SemanticCanonicalFrame_v2 (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState_v2 phi
  task_rel := semantic_task_rel_v2 phi
  nullity := SemanticTaskRelV2.nullity
  compositionality := SemanticTaskRelV2.compositionality

-- Semantic canonical model
def SemanticCanonicalModel_v2 (phi : Formula) : TaskModel (SemanticCanonicalFrame_v2 phi) where
  valuation := fun w p =>
    let ws := SemanticWorldState.toFiniteWorldState w
    ws.models (Formula.atom p) (atom_mem_closure p phi)

-- CRITICAL: Truth correspondence lemma
theorem semantic_truth_lemma_v2 (phi : Formula) (w : SemanticWorldState_v2 phi)
    (t : FiniteTime (temporalBound phi)) (psi : Formula) (h_mem : psi ∈ closure phi) :
    truth_at (SemanticCanonicalModel_v2 phi) (some_history w t) (toInt t) psi ↔
    (toFiniteWorldState w).models psi h_mem
```

**Verification**:
- `lake build Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel` succeeds
- `semantic_truth_lemma_v2` proven without sorries
- Truth correspondence holds for all formula constructors (atom, neg, imp, box, temporal)

---

### Phase 4: Main Completeness Theorem [NOT STARTED]

**Goal**: Prove `main_provable_iff_valid` using new infrastructure.

**Estimated Effort**: 4-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` (MODIFY)
- `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` (MODIFY)

**Key Changes**:

1. **ContextProvability.lean**: Replace old import with new SemanticCanonicalModel
   ```lean
   -- REMOVE line 9: import Bimodal.Metalogic.Completeness.FiniteCanonicalModel
   -- ADD:
   import Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel

   -- REMOVE lines 59-60 (open statement for old Metalogic)
   ```

2. **WeakCompleteness.lean**: New proof using Metalogic_v2 infrastructure
   ```lean
   theorem main_provable_iff_valid_v2 (phi : Formula) : Nonempty (⊢ phi) ↔ valid phi := by
     constructor
     · -- Soundness (already proven)
       intro ⟨h_deriv⟩
       exact soundness_to_validity h_deriv
     · -- Completeness via contrapositive
       intro h_valid
       by_contra h_not_prov
       -- Step 1: {phi.neg} is consistent since phi not provable
       have h_neg_cons := neg_consistent_of_not_provable phi h_not_prov
       -- Step 2: Extend to full MCS by Lindenbaum
       obtain ⟨M, h_sub_M, h_M_mcs⟩ := set_lindenbaum {phi.neg} h_neg_cons
       -- Step 3: Project to closure MCS
       let S := mcs_projection phi M h_M_mcs
       -- Step 4: Build FiniteWorldState from S
       let w := worldStateFromClosureMCS phi S (mcs_projection_is_closure_mcs ...)
       -- Step 5: Build SemanticCanonicalModel_v2 witnessing history
       let F := SemanticCanonicalFrame_v2 phi
       let M := SemanticCanonicalModel_v2 phi
       let tau := constructWitnessHistory w
       -- Step 6: Apply h_valid to get truth_at phi
       have h_phi_true := h_valid Int F M tau 0
       -- Step 7: By truth correspondence, phi ∈ S, but phi.neg ∈ S (contradiction)
       have h_contradiction := semantic_truth_lemma_v2 phi w 0 phi ...
       exact contradiction_from_mcs_contains_both ...
   ```

**Verification**:
- `main_provable_iff_valid_v2` proven without sorries
- `lake build Bimodal.Metalogic_v2.Completeness.WeakCompleteness` succeeds

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Ensure full build, verify independence, clean up.

**Estimated Effort**: 2-4 hours

**Tasks**:
1. Remove line 9 from ContextProvability.lean completely
2. Remove lines 59-60 (open statement for old Metalogic)
3. Run `lake build` to verify full compilation
4. Grep for any remaining old Metalogic imports:
   ```bash
   grep -r "import Bimodal.Metalogic\." Theories/Bimodal/Metalogic_v2/
   # Should return NOTHING
   ```
5. Update FMP.lean re-exports if needed
6. Fix any downstream breakage
7. Add module documentation

**Verification**:
```bash
lake build Bimodal.Metalogic_v2
grep -r "import Bimodal.Metalogic\." Theories/Bimodal/Metalogic_v2/
# Must return empty
grep -r "sorry" Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean
# Must return empty (or document any acceptable edge cases)
```

---

## Testing & Validation

### Build Verification
- [ ] `lake build Bimodal.Metalogic_v2.Representation.Closure` succeeds
- [ ] `lake build Bimodal.Metalogic_v2.Representation.FiniteWorldState` succeeds
- [ ] `lake build Bimodal.Metalogic_v2.Representation.SemanticCanonicalModel` succeeds
- [ ] `lake build Bimodal.Metalogic_v2.Completeness.WeakCompleteness` succeeds
- [ ] `lake build Bimodal.Metalogic_v2` (full module) succeeds
- [ ] `lake build` (full project) succeeds

### Independence Verification
- [ ] `grep -r "import Bimodal.Metalogic\." Theories/Bimodal/Metalogic_v2/` returns empty
- [ ] `grep -r "Metalogic.Completeness" Theories/Bimodal/Metalogic_v2/` returns empty
- [ ] No `open` statements reference old Metalogic

### Quality Verification
- [ ] No sorries in new files (or documented acceptable edge cases)
- [ ] All new theorems have proper docstrings
- [ ] Module structure follows Metalogic_v2 conventions

---

## Artifacts & Outputs

**New Files**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` (~200 lines)
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean` (~150 lines)
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean` (~400 lines)

**Modified Files**:
- `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` - Remove old import
- `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` - New proof

**Documentation**:
- `specs/597_reprove_main_provable_iff_valid_metalogic_v2/summaries/implementation-summary-YYYYMMDD.md`

---

## Total Effort Summary

| Phase | Description | Hours | Cumulative |
|-------|-------------|-------|------------|
| 1 | Closure Infrastructure | 4-6 | 4-6 |
| 2 | Finite World State | 4-6 | 8-12 |
| 3 | Semantic Canonical Model (CRITICAL) | 6-8 | 14-20 |
| 4 | Main Completeness Theorem | 4-6 | 18-26 |
| 5 | Verification and Cleanup | 2-4 | 20-30 |

---

## Rollback/Contingency

If implementation fails at any phase:

1. **Phase 1-2 failure**: Low risk, isolated new files, just delete
2. **Phase 3 failure**: Critical path - evaluate if a simpler bridge is possible, or consider minimal migration from old Metalogic as fallback
3. **Phase 4 failure**: If proof doesn't work, re-examine truth correspondence lemma
4. **Phase 5 failure**: Build issues are usually fixable with incremental debugging

**Emergency Fallback**: If zero-debt approach is blocked, fall back to minimal migration extracting ~850-1000 lines from old Metalogic (10-15 hours). This creates technical debt but achieves independence.

---

## Notes

- **Phase 3 is the critical path** - Start here for proof-of-concept if time is limited
- Reference old Metalogic for design patterns, but do not copy code
- Each phase should be independently testable via `lake build`
- Commit after each successful phase
