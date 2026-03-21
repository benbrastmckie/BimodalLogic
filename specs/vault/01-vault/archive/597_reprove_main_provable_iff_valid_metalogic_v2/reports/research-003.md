# Research Report: Task #597 - Zero Technical Debt Architecture for Metalogic_v2

**Task**: 597 - Re-prove main_provable_iff_valid in Metalogic_v2
**Started**: 2026-01-18T21:45:00Z
**Completed**: 2026-01-18T22:30:00Z
**Effort**: High (20-40 hours for full zero-debt solution)
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
  - Previous research: research-001.md, research-002.md
  - Complete Metalogic_v2 codebase analysis
  - Old Metalogic/Completeness/FiniteCanonicalModel.lean (4878 lines)
  - lean_file_outline, Read tool, lake build verification
**Artifacts**:
  - This report: specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-003.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

1. **Current Build Status**: Metalogic_v2 BUILDS SUCCESSFULLY (946 jobs completed)
2. **Single Dependency**: The entire old Metalogic dependency comes from ONE import on line 9 of `ContextProvability.lean`
3. **Zero Debt Solution Exists**: A new contrapositive completeness proof is feasible using Metalogic_v2's existing infrastructure
4. **Key Missing Component**: A `SemanticCanonicalModel_v2` that bridges `CanonicalWorldState` (MCS) to `TaskModel` (semantic truth)
5. **Estimated Effort**: 20-25 hours to implement a clean, self-contained solution

---

## Context & Scope

### Research Mandate

The user explicitly stated: **"I do not want to accept ANY technical debt, building a NEW contrapositive proof if that is what would provide the most elegant long term solution."**

This research focuses on designing a complete, self-contained Metalogic_v2 architecture that requires zero imports from the old Metalogic directory.

### Current State Summary

| Component | Status | Notes |
|-----------|--------|-------|
| `Metalogic_v2/Core/` | COMPLETE | MCS theory, deduction theorem, Lindenbaum |
| `Metalogic_v2/Soundness/` | COMPLETE | Full soundness proof |
| `Metalogic_v2/Representation/` | PARTIAL | Has CanonicalModel, missing semantic bridge |
| `Metalogic_v2/Completeness/` | DEPENDS | Uses old Metalogic's `main_provable_iff_valid` |
| `Metalogic_v2/FMP.lean` | PARTIAL | Constructive FMP has sorries |

### The Dependency Chain

```
WeakCompleteness.lean (line 1)
  └── imports FMP.lean
       └── imports ContextProvability.lean (line 2)
            └── imports Metalogic/Completeness/FiniteCanonicalModel.lean (LINE 9)
                 └── defines main_provable_iff_valid (line 4542)
```

**The entire old Metalogic dependency is isolated to LINE 9 of ContextProvability.lean.**

---

## Complete Inventory: Metalogic_v2 File Structure

### Core Layer (6 files, ~1200 lines)

| File | Lines | Status | Key Theorems |
|------|-------|--------|--------------|
| `Core/Basic.lean` | ~50 | COMPLETE | Basic definitions |
| `Core/Provability.lean` | ~150 | COMPLETE | ContextDerivable, theorem_in_mcs |
| `Core/DeductionTheorem.lean` | ~450 | COMPLETE | deduction_theorem |
| `Core/MaximalConsistent.lean` | ~523 | COMPLETE | SetMaximalConsistent, set_lindenbaum |

### Soundness Layer (2 files, ~400 lines)

| File | Lines | Status | Key Theorems |
|------|-------|--------|--------------|
| `Soundness/SoundnessLemmas.lean` | ~200 | COMPLETE | Helper lemmas |
| `Soundness/Soundness.lean` | ~200 | COMPLETE | soundness theorem |

### Representation Layer (5 files, ~1100 lines)

| File | Lines | Status | Key Theorems |
|------|-------|--------|--------------|
| `Representation/CanonicalModel.lean` | ~358 | COMPLETE | CanonicalWorldState, mcs_contains_or_neg, mcs_modus_ponens |
| `Representation/TruthLemma.lean` | ~184 | COMPLETE | canonicalTruthAt, truthLemma_detailed |
| `Representation/RepresentationTheorem.lean` | ~189 | COMPLETE | representation_theorem |
| `Representation/ContextProvability.lean` | ~200 | **DEPENDS** | representation_theorem_backward_empty uses OLD Metalogic |
| `Representation/FiniteModelProperty.lean` | ~435 | PARTIAL | finite_model_property_constructive has sorries |

### Completeness Layer (2 files, ~300 lines)

| File | Lines | Status | Key Theorems |
|------|-------|--------|--------------|
| `Completeness/WeakCompleteness.lean` | ~94 | DEPENDS | weak_completeness, provable_iff_valid |
| `Completeness/StrongCompleteness.lean` | ~213 | DEPENDS | strong_completeness |

### Applications Layer (1 file)

| File | Lines | Status | Key Theorems |
|------|-------|--------|--------------|
| `Applications/Compactness.lean` | ~100 | PARTIAL | Compactness theorem (depends on FMP) |

### Hub Module

| File | Lines | Status | Notes |
|------|-------|--------|-------|
| `FMP.lean` | ~147 | DEPENDS | Re-exports, depends on ContextProvability |

---

## Dependency Graph

```
                          ┌──────────────────────────┐
                          │  OLD METALOGIC IMPORT    │
                          │  (line 9 of              │
                          │   ContextProvability)    │
                          └─────────────┬────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ContextProvability.lean                       │
│  representation_theorem_backward_empty uses main_provable_iff_valid
└─────────────────────────────────────────────────────────────────┘
                                        │
                    ┌───────────────────┴───────────────────┐
                    ▼                                       ▼
         ┌─────────────────┐                     ┌─────────────────┐
         │ FMP.lean (hub)  │                     │ RepresentationThm│
         └────────┬────────┘                     └─────────────────┘
                  │
      ┌───────────┴───────────┐
      ▼                       ▼
┌─────────────┐       ┌─────────────────┐
│WeakComplete.│       │StrongComplete.  │
└─────────────┘       └─────────────────┘
```

---

## Gap Analysis: What's Missing for Independence

### The Core Gap

Metalogic_v2 has two different "truth" notions that are NOT connected:

1. **Canonical Truth** (`canonicalTruthAt w phi`): Defined as `phi ∈ w.carrier` (MCS membership)
2. **Semantic Truth** (`truth_at M tau t phi`): Defined recursively over formula structure in TaskModel

The old Metalogic bridges this gap via `SemanticCanonicalModel`, which:
- Constructs a `TaskModel` from the canonical frame
- Proves `truth_at (SemanticCanonicalModel phi) tau t psi ↔ psi ∈ (closure MCS)`

**Metalogic_v2 lacks this bridge.**

### What Metalogic_v2 Currently Has

```lean
-- Already proven in Metalogic_v2:
theorem representation_theorem :
    Consistent Γ → ∃ (w : CanonicalWorldState), ∀ φ ∈ Γ, canonicalTruthAt w φ

-- This gives: consistent contexts have canonical witnesses
-- But it does NOT connect to semantic truth (truth_at in TaskModel)
```

### What Metalogic_v2 Needs (The Bridge)

```lean
-- NEEDED: Bridge from CanonicalWorldState to TaskModel
theorem canonical_to_semantic_bridge (phi : Formula) :
    ∃ (F : TaskFrame Int) (M : TaskModel F) (tau : WorldHistory F) (t : Int),
      ∀ psi ∈ closure phi,
        canonicalTruthAt (some_canonical_world) psi ↔ truth_at M tau t psi
```

---

## Zero Technical Debt Architecture Design

### Target Module Structure

```
Metalogic_v2/
├── Core/
│   ├── Basic.lean           # Unchanged
│   ├── Provability.lean     # Unchanged
│   ├── DeductionTheorem.lean # Unchanged
│   └── MaximalConsistent.lean # Unchanged
├── Soundness/
│   ├── SoundnessLemmas.lean # Unchanged
│   └── Soundness.lean       # Unchanged
├── Representation/
│   ├── CanonicalModel.lean  # Unchanged
│   ├── TruthLemma.lean      # Unchanged
│   ├── RepresentationTheorem.lean # Unchanged
│   ├── SemanticCanonicalModel.lean # NEW - The Bridge
│   ├── ContextProvability.lean # MODIFIED - Remove old import
│   └── FiniteModelProperty.lean # MODIFIED - Fill sorries
├── Completeness/
│   ├── WeakCompleteness.lean # MODIFIED - Use new bridge
│   └── StrongCompleteness.lean # Unchanged (depends on Weak)
├── Applications/
│   └── Compactness.lean     # Unchanged
└── FMP.lean                 # Unchanged (hub re-exports)
```

### Key New File: SemanticCanonicalModel.lean

This is the core missing component. It needs to:

1. Define `SemanticCanonicalFrame_v2 : TaskFrame Int`
2. Define `SemanticCanonicalModel_v2 : TaskModel (SemanticCanonicalFrame_v2 phi)`
3. Prove the truth correspondence lemma

---

## Implementation Roadmap

### Phase 1: Closure Infrastructure (4-6 hours)

**Objective**: Build the finite subformula infrastructure needed for semantic bridge.

**Files to create/modify**:
- `Representation/Closure.lean` (NEW, ~200 lines)

**Key definitions**:
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

theorem mcs_projection_is_closure_mcs (phi : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    ClosureMaximalConsistent phi (mcs_projection phi M h_mcs)
```

**Estimated effort**: 4-6 hours

### Phase 2: Finite World State (4-6 hours)

**Objective**: Define world states as truth assignments to closure.

**Files to create/modify**:
- `Representation/FiniteWorldState.lean` (NEW, ~150 lines)

**Key definitions**:
```lean
-- Finite world state: truth assignment on closure
structure FiniteWorldState (phi : Formula) where
  assignment : closureWithNeg phi → Bool
  consistent : -- no contradiction
  negation_complete : -- has phi or neg phi for each

-- Build from closure MCS
def worldStateFromClosureMCS (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) : FiniteWorldState phi

-- Truth at finite world state
def finite_models (w : FiniteWorldState phi) (psi : Formula)
    (h_mem : psi ∈ closure phi) : Prop := w.assignment ⟨psi, ...⟩ = true
```

**Estimated effort**: 4-6 hours

### Phase 3: Semantic Canonical Model (6-8 hours)

**Objective**: Build TaskModel from canonical construction.

**Files to create/modify**:
- `Representation/SemanticCanonicalModel.lean` (NEW, ~400 lines)

**Key definitions**:
```lean
-- Semantic world state (quotient of history-time pairs)
def SemanticWorldState_v2 (phi : Formula) : Type :=
  Quotient (htEquiv phi)

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

**Estimated effort**: 6-8 hours

### Phase 4: Main Completeness Theorem (4-6 hours)

**Objective**: Prove `main_provable_iff_valid` using new infrastructure.

**Files to modify**:
- `Representation/ContextProvability.lean` (MODIFY - remove old import)
- `Completeness/WeakCompleteness.lean` (MODIFY - use new proof)

**Key theorem**:
```lean
-- NEW proof using Metalogic_v2 infrastructure only
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
    -- Step 6: Apply h_valid to get truth_at phi
    -- Step 7: By truth correspondence, phi ∈ S, but phi.neg ∈ S (contradiction)
    sorry -- The details use Phase 3 infrastructure
```

**Estimated effort**: 4-6 hours

### Phase 5: Verification and Cleanup (2-4 hours)

**Objective**: Ensure full build, remove old imports, verify independence.

**Tasks**:
1. Remove line 9 from ContextProvability.lean
2. Run `lake build` to verify full compilation
3. Grep for any remaining old Metalogic imports
4. Update FMP.lean re-exports if needed
5. Fix any downstream breakage

**Verification**:
```bash
lake build Bimodal.Metalogic_v2
grep -r "import Bimodal.Metalogic\." Theories/Bimodal/Metalogic_v2/
# Should return NOTHING after completion
```

**Estimated effort**: 2-4 hours

---

## Total Effort Estimate

| Phase | Description | Hours |
|-------|-------------|-------|
| 1 | Closure Infrastructure | 4-6 |
| 2 | Finite World State | 4-6 |
| 3 | Semantic Canonical Model | 6-8 |
| 4 | Main Completeness Theorem | 4-6 |
| 5 | Verification and Cleanup | 2-4 |
| **Total** | | **20-30** |

---

## Alternative: Minimal Migration (NOT RECOMMENDED)

If zero technical debt is not feasible, a minimal migration could:

1. Copy ONLY these definitions from old Metalogic:
   - `SemanticWorldState` quotient construction (~100 lines)
   - `SemanticCanonicalFrame`, `SemanticCanonicalModel` (~150 lines)
   - `semantic_truth_at_v2` (~50 lines)
   - `semantic_weak_completeness` (~200 lines)
   - `main_provable_iff_valid` (~50 lines)

2. Adapt to Metalogic_v2 naming conventions

**Estimated effort**: 10-15 hours
**Trade-off**: Creates code duplication, harder to maintain

---

## Decisions

1. **Zero technical debt is the recommended approach** - The new infrastructure is cleaner and more maintainable than copying from old Metalogic
2. **SemanticCanonicalModel_v2 is the key missing component** - This bridges canonical truth (MCS membership) to semantic truth (TaskModel evaluation)
3. **The old Metalogic should NOT be imported** - A single import creates long-term maintenance burden
4. **Phase 3 is the critical path** - The semantic canonical model construction is the most complex part

---

## Recommendations

### Recommendation 1: Implement Zero Debt Solution (Priority: HIGH)

**Action**: Implement the 5-phase roadmap described above.

**Rationale**:
- Provides complete independence from old Metalogic
- Creates cleaner, more maintainable architecture
- Enables eventual deletion of old Metalogic directory
- Worth the 20-30 hour investment for long-term codebase health

### Recommendation 2: Start with Phase 3 Proof-of-Concept (Priority: HIGH)

**Action**: Begin with SemanticCanonicalModel_v2 as a proof-of-concept.

**Rationale**:
- Phase 3 is the riskiest/most complex
- Early validation reduces overall project risk
- If Phase 3 works, remaining phases are straightforward

### Recommendation 3: Update Implementation Plan (Priority: MEDIUM)

**Action**: Update the existing implementation plan to reflect the 5-phase architecture.

**Rationale**:
- Current plan assumes simpler approach
- New phases are more detailed and actionable
- Provides clear milestones for progress tracking

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Truth correspondence lemma complexity | High | High | Start with Phase 3 PoC; use structural induction pattern from old Metalogic |
| Temporal operator handling | Medium | Medium | Borrow FiniteTime/FiniteHistory infrastructure from old Metalogic |
| Bounded time domain edge cases | Medium | Low | Accept some sorries in edge cases (documented) |
| Build issues during migration | Low | Medium | Incremental changes with `lake build` after each file |
| Effort underestimation | Medium | Medium | Buffer time in Phase 5; ready to accept partial debt if needed |

---

## Appendix: Key Old Metalogic Infrastructure

### SemanticWorldState (line ~2450)

```lean
-- Equivalence on history-time pairs: same underlying world state
def htEquiv (phi : Formula) : (FiniteHistory phi × FiniteTime (temporalBound phi)) →
    (FiniteHistory phi × FiniteTime (temporalBound phi)) → Prop :=
  fun ⟨h1, t1⟩ ⟨h2, t2⟩ => h1.states t1 = h2.states t2

-- Quotient by equivalence
def SemanticWorldState (phi : Formula) : Type :=
  Quotient (htEquiv_setoid phi)
```

### SemanticCanonicalFrame (line ~2687)

```lean
def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel_v2 phi
  nullity := SemanticTaskRelV2.nullity
  compositionality := SemanticTaskRelV2.compositionality
```

### semantic_weak_completeness (line ~3050)

```lean
-- If phi is true at all SemanticWorldStates, then phi is derivable
noncomputable def semantic_weak_completeness (phi : Formula)
    (h_all_true : ∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w ... phi) :
    ⊢ phi := by
  -- Contrapositive: assume ¬⊢ phi
  -- Extend {phi.neg} to MCS
  -- Project to closure MCS
  -- Build SemanticWorldState
  -- By h_all_true, phi is true at that state
  -- But phi.neg is also in the closure MCS (contradiction)
  ...
```

### main_provable_iff_valid (line ~4542)

```lean
theorem main_provable_iff_valid (phi : Formula) : Nonempty (⊢ phi) ↔ valid phi := by
  constructor
  · -- Soundness
    intro ⟨h_deriv⟩
    exact soundness_implies_valid h_deriv
  · -- Completeness
    intro h_valid
    exact ⟨main_weak_completeness phi h_valid⟩
```

---

## References

- Previous research: specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-001.md
- Previous research: specs/597_reprove_main_provable_iff_valid_metalogic_v2/reports/research-002.md
- Old Metalogic: Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean
- Blackburn et al., Modal Logic, Chapter 4 (Canonical Models)
