# Implementation Plan v2: Task #983 — Publication-Ready FMP and Decidability

- **Task**: 983 - Review decidability results and FMP for publication
- **Version**: 2 (revised from v1)
- **Status**: [IMPLEMENTING]
- **Effort**: 35-45 hours
- **Dependencies**: Task 981 (discrete axiom, parallel), Task 982 (dense wiring, parallel)
- **Research Inputs**: research-001.md (team), research-002.md (Boneyard salvageability)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: zero-debt gate, no bridging lemmas, unified naming
- **Lean Intent**: true

---

## Revision Rationale

**v1 issues**:
1. Planned to cherry-pick Boneyard code with non-standard `semantic_truth_at_v2` validity
2. Would require bridge lemmas to connect to standard `valid` (architecturally blocked)
3. Created parallel infrastructure rather than extending existing decidability module

**v2 approach**:
1. **Rebuild from scratch** using active codebase infrastructure exclusively
2. **Single validity definition**: Use standard `valid` from `Semantics/Validity.lean` throughout
3. **Unified naming**: All new code in `Theories/Metalogic/Decidability/FMP/` with consistent naming
4. **Dense/discrete alignment**: Base FMP + frame-class specializations sharing core infrastructure
5. **No wrappers**: Direct proofs, no adapters, aliases, or bridge theorems

---

## Design Principles

### 1. Single Source of Truth

| Concept | Definition Source | Notes |
|---------|-------------------|-------|
| Validity | `Semantics/Validity.lean` | Use `valid` directly, never a variant |
| Formula closure | `Syntax/SubformulaClosure.lean` | Extend, don't duplicate |
| MCS | `Core/MaximalConsistent.lean` | Use `SetMaximalConsistent` |
| Truth | `Semantics/Satisfaction.lean` | Use `truth_at` |
| Decidability | `Metalogic/Decidability/` | Extend existing module |

### 2. No Bridging Lemmas

The Boneyard analysis revealed that bridge lemmas connecting different validity notions are architecturally blocked (6 sorries in modal/temporal cases). The solution is not to attempt bridges, but to **use the same definitions throughout**.

**Forbidden patterns**:
- `fmp_valid_iff_valid` - bridge theorem (blocked)
- `semantic_truth_at_v2` - parallel validity (creates bridge need)
- `FiniteWorldState.models` as separate truth notion

**Required pattern**:
- All FMP theorems stated directly using `valid` and `truth_at`

### 3. Unified Module Structure

```
Theories/Metalogic/Decidability/
├── ... (existing files)
└── FMP/
    ├── ClosureMCS.lean        -- MCS restricted to closure
    ├── Filtration.lean        -- Filtration equivalence and quotient
    ├── FiniteModel.lean       -- Finite model construction
    ├── TruthPreservation.lean -- Filtration lemma
    ├── FMP.lean               -- Main theorem (base logic)
    ├── DenseFMP.lean          -- Dense frame specialization
    └── DiscreteFMP.lean       -- Discrete frame specialization
```

All files use the same namespace prefix: `ProofChecker.Metalogic.Decidability.FMP`

### 4. Dense/Discrete Alignment

**Base FMP**: Proves FMP for the base TM logic (Kt + S5-like modal)

**Dense extension**: Specializes to `DenselyOrdered D` frames
- Same core proof structure
- Additional: density preservation under filtration

**Discrete extension**: Specializes to `DiscreteOrder D` frames
- Same core proof structure
- Additional: discreteness preservation under filtration
- Depends on Task 981 (axiom removal) for clean integration

---

## Goals & Non-Goals

**Goals**:
- Prove FMP using standard `valid` definition exclusively
- Prove `decide_complete` connecting FMP to tableau
- Clean integration with existing `decide_sound`
- Publication-ready proofs for base + dense + discrete cases
- Zero sorries, zero custom axioms

**Non-Goals**:
- Cherry-picking Boneyard code (uses non-standard definitions)
- Bridge lemmas between validity notions
- Complexity analysis (PSPACE-completeness)
- Soundness edge-case fixes (2 sorries in Soundness.lean, orthogonal)

---

## Implementation Phases

### Phase 1: Closure MCS Infrastructure [COMPLETED]

- **Dependencies:** None
- **Goal:** Define MCS restricted to subformula closure with projection theorem

**Approach**:
- Extend `Syntax/SubformulaClosure.lean` if needed
- Use existing `SetMaximalConsistent` from `Core/MaximalConsistent.lean`
- Define `ClosureMCS phi := { Γ : Finset Formula // Γ ⊆ closure phi ∧ IsClosureMCS phi Γ }`
- Prove: `mcs_to_closure_mcs : SetMaximalConsistent Γ → IsClosureMCS phi (Γ ∩ closure phi)`

**Key definitions**:
```lean
-- Closure-restricted consistency
def IsClosureConsistent (phi : Formula) (Γ : Finset Formula) : Prop :=
  Γ ⊆ closure phi ∧ Consistent Γ

-- Closure-restricted MCS
def IsClosureMCS (phi : Formula) (Γ : Finset Formula) : Prop :=
  IsClosureConsistent phi Γ ∧ ∀ ψ ∈ closure phi, ψ ∉ Γ → ¬Consistent (Γ ∪ {ψ})

-- Key projection theorem
theorem mcs_to_closure_mcs (h : SetMaximalConsistent Γ) :
    IsClosureMCS phi (Γ ∩ closure phi)
```

**Timing:** 5 hours

**Files to create**:
- `Theories/Metalogic/Decidability/FMP/ClosureMCS.lean`

**Verification:**
- `lake build` passes
- File is sorry-free
- No custom axioms

---

### Phase 2: Filtration Construction [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Define filtration equivalence and quotient model

**Approach**:
- Define equivalence: `w ≡_φ v ↔ ∀ ψ ∈ closure φ, truth_at M Ω τ w ψ ↔ truth_at M Ω τ v ψ`
- Prove it's an equivalence relation
- Construct quotient model with lifted accessibility
- Prove quotient is a valid TaskFrame

**Key definitions**:
```lean
-- Filtration equivalence (using standard truth_at)
def FiltrationEquiv (M : TaskModel D) (Ω : Omega D) (τ : History D) (phi : Formula) :
    D → D → Prop :=
  fun w v => ∀ ψ ∈ closure phi, truth_at M Ω τ w ψ ↔ truth_at M Ω τ v ψ

-- Quotient type
def FilteredWorld (M : TaskModel D) (Ω : Omega D) (τ : History D) (phi : Formula) :=
  Quotient (FiltrationEquivSetoid M Ω τ phi)

-- Lifted accessibility (smallest filtration)
def filtered_R (M : TaskModel D) (...) : FilteredWorld → FilteredWorld → Prop := ...

-- Filtered TaskFrame
def FilteredTaskFrame (M : TaskModel D) (...) : TaskFrame (FilteredWorld M Ω τ phi) := ...
```

**Timing:** 8 hours

**Files to create**:
- `Theories/Metalogic/Decidability/FMP/Filtration.lean`

**Verification:**
- `lake build` passes
- `FiltrationEquiv` is an `Equivalence`
- `FilteredTaskFrame` is a valid `TaskFrame`
- File is sorry-free

---

### Phase 3: Finiteness Theorem [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Prove filtered model has bounded size

**Approach**:
- Equivalence classes are determined by truth values on `closure phi`
- At most `2^|closure phi|` equivalence classes
- Prove `Fintype (FilteredWorld M Ω τ phi)` with cardinality bound

**Key theorems**:
```lean
-- Finiteness of filtered world
noncomputable instance filtered_world_fintype (M : TaskModel D) (...) :
    Fintype (FilteredWorld M Ω τ phi)

-- Cardinality bound
theorem filtered_world_card_bound (M : TaskModel D) (...) :
    Fintype.card (FilteredWorld M Ω τ phi) ≤ 2 ^ Finset.card (closure phi)
```

**Timing:** 4 hours

**Files to create**:
- `Theories/Metalogic/Decidability/FMP/FiniteModel.lean`

**Verification:**
- `lake build` passes
- Cardinality bound proven
- File is sorry-free

---

### Phase 4: Truth Preservation (Filtration Lemma) [PARTIAL]

- **Dependencies:** Phase 3
- **Goal:** Prove truth is preserved for closure formulas

**Approach**:
- Induction on formula structure
- Cases: atom, bot, imp, box, diamond, future, past, etc.
- Use `truth_at` throughout (no separate finite model truth)

**Key theorem**:
```lean
-- The Filtration Lemma (using standard truth_at)
theorem filtration_lemma (M : TaskModel D) (Ω : Omega D) (τ : History D) (phi : Formula)
    (w : D) (ψ : Formula) (h : ψ ∈ closure phi) :
    truth_at M Ω τ w ψ ↔ truth_at (FilteredTaskModel M Ω τ phi) Ω' τ' ⟦w⟧ ψ
```

**Timing:** 10 hours (largest phase - requires careful modal/temporal handling)

**Files to create**:
- `Theories/Metalogic/Decidability/FMP/TruthPreservation.lean`

**Verification:**
- `lake build` passes
- All formula cases covered
- File is sorry-free

---

### Phase 5: FMP Main Theorem (Base Logic) [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** State and prove FMP using standard `valid`

**Approach**:
- FMP: If φ is satisfiable, it's satisfiable in a finite model
- Use contrapositive: If valid in all finite models, valid in all models
- Connect to canonical model via filtration

**Key theorem**:
```lean
-- FMP using standard valid definition
theorem finite_model_property (phi : Formula) :
    ¬(valid phi) → ∃ (M : FiniteTaskModel) (Ω : Omega M.D) (τ : History M.D) (t : M.D),
      ¬(truth_at M.model Ω τ t phi) ∧ Fintype.card M.D ≤ 2 ^ closureSize phi

-- Or equivalently (the completeness direction):
theorem fmp_completeness (phi : Formula) :
    (∀ (M : FiniteTaskModel) (Ω : Omega M.D) (τ : History M.D) (t : M.D),
      truth_at M.model Ω τ t phi) → valid phi
```

**Timing:** 5 hours

**Files to create**:
- `Theories/Metalogic/Decidability/FMP/FMP.lean`

**Verification:**
- `lake build` passes
- FMP theorem uses standard `valid` from `Semantics/Validity.lean`
- File is sorry-free

---

### Phase 6: Dense/Discrete FMP Specializations [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Prove FMP preserves dense/discrete frame properties

**Approach**:
- Dense: Prove filtration preserves `DenselyOrdered` on temporal accessibility
- Discrete: Prove filtration preserves `DiscreteOrder` (after Task 981 completes)
- Both inherit base FMP proof structure

**Key theorems**:
```lean
-- Dense FMP
theorem dense_fmp (phi : Formula) (h_valid_dense : valid_dense phi) :
    ∀ (M : FiniteTaskModel) (hM : DenseFrame M), truth_at_all M phi

-- Discrete FMP (depends on Task 981 for axiom-free discrete infrastructure)
theorem discrete_fmp (phi : Formula) (h_valid_discrete : valid_discrete phi) :
    ∀ (M : FiniteTaskModel) (hM : DiscreteFrame M), truth_at_all M phi
```

**Timing:** 6 hours (3 hrs each for dense/discrete)

**Files to create**:
- `Theories/Metalogic/Decidability/FMP/DenseFMP.lean`
- `Theories/Metalogic/Decidability/FMP/DiscreteFMP.lean`

**Verification:**
- `lake build` passes
- Dense FMP is sorry-free
- Discrete FMP depends on Task 981 status
- Frame preservation theorems proven

---

### Phase 7: Decidability Completeness [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Prove `decide_complete` using FMP

**Approach**:
- Connect FMP to tableau: open saturated branch → finite countermodel exists
- Use existing countermodel extraction machinery
- Prove: `valid phi → ∃ d, decide phi = ProofFound d`

**Key theorem**:
```lean
-- Decidability completeness (dual to existing decide_sound)
theorem decide_complete (phi : Formula) :
    valid phi → ∃ d : DerivationTree, decide phi = DecisionResult.ProofFound d

-- Or the contrapositive form:
theorem decide_complete' (phi : Formula) :
    (∀ d, decide phi ≠ DecisionResult.ProofFound d) → ¬(valid phi)
```

**Integration**:
```lean
-- Full decidability correctness
theorem decide_correct (phi : Formula) :
    (decide phi = ProofFound d → valid phi) ∧  -- soundness (existing)
    (valid phi → ∃ d, decide phi = ProofFound d)  -- completeness (new)
```

**Timing:** 6 hours

**Files to modify**:
- `Theories/Metalogic/Decidability/Correctness.lean` - add `decide_complete`

**Verification:**
- `lake build` passes
- `decide_complete` proven
- Both `decide_sound` and `decide_complete` exported

---

### Phase 8: Integration and Documentation [NOT STARTED]

- **Dependencies:** Phase 7, Task 981 (optional), Task 982 (optional)
- **Goal:** Finalize publication-ready results and documentation

**Tasks**:
- [ ] Run full sorry/axiom audit
- [ ] Document all exported theorems
- [ ] Create module index `Theories/Metalogic/Decidability/FMP.lean`
- [ ] Update CHANGE_LOG.md and ROAD_MAP.md
- [ ] Create implementation summary

**Timing:** 4 hours

**Verification:**
- `grep -rn "\bsorry\b" Theories/Metalogic/Decidability/FMP/` returns empty
- `grep -n "^axiom " Theories/Metalogic/Decidability/FMP/` returns empty
- All exports compile

---

## Effort Summary

| Phase | Description | Effort | Dependencies |
|-------|-------------|--------|--------------|
| 1 | Closure MCS Infrastructure | 5 hrs | None |
| 2 | Filtration Construction | 8 hrs | Phase 1 |
| 3 | Finiteness Theorem | 4 hrs | Phase 2 |
| 4 | Truth Preservation | 10 hrs | Phase 3 |
| 5 | FMP Main Theorem | 5 hrs | Phase 4 |
| 6 | Dense/Discrete FMP | 6 hrs | Phase 5 |
| 7 | Decidability Completeness | 6 hrs | Phase 5 |
| 8 | Integration & Documentation | 4 hrs | Phase 7 |
| **Total** | | **48 hrs** | |

---

## What This Plan Does NOT Do

1. **Does NOT cherry-pick Boneyard code** - Builds fresh with active infrastructure
2. **Does NOT introduce bridges** - Single validity definition throughout
3. **Does NOT create parallel modules** - Extends existing `Decidability/`
4. **Does NOT add wrappers/aliases** - Direct definitions and proofs
5. **Does NOT depend on Task 981/982** - Can proceed independently (Phase 6 discrete case is optional until 981 completes)

---

## Success Criteria

1. **FMP theorem** stated using standard `valid` definition
2. **Zero sorries** in all new FMP modules
3. **Zero custom axioms** in FMP modules
4. **`decide_complete`** proven and exported alongside `decide_sound`
5. **Clean naming**: `FiltrationEquiv`, `FilteredWorld`, `filtration_lemma`, etc.
6. **No bridges**: All proofs use same truth/validity definitions

---

## Risk Mitigations

| Risk | Mitigation |
|------|------------|
| Filtration lemma modal case complexity | Use existing MCS modal properties; literature-standard proof |
| Filtration lemma temporal case complexity | Bound time domain to `2*closureSize + 1` for finite iteration |
| Quotient type inference issues | Explicit universe annotations; use `Quotient.lift` patterns |
| Dense/discrete preservation subtle | Prove independently; can defer to future task if blocked |

---

## Artifacts

**New files** (8):
- `Theories/Metalogic/Decidability/FMP/ClosureMCS.lean`
- `Theories/Metalogic/Decidability/FMP/Filtration.lean`
- `Theories/Metalogic/Decidability/FMP/FiniteModel.lean`
- `Theories/Metalogic/Decidability/FMP/TruthPreservation.lean`
- `Theories/Metalogic/Decidability/FMP/FMP.lean`
- `Theories/Metalogic/Decidability/FMP/DenseFMP.lean`
- `Theories/Metalogic/Decidability/FMP/DiscreteFMP.lean`
- `Theories/Metalogic/Decidability/FMP.lean` (index)

**Modified files** (1):
- `Theories/Metalogic/Decidability/Correctness.lean` (add `decide_complete`)

**Documentation**:
- `specs/983_review_decidability_fmp_completeness/summaries/implementation-summary-YYYYMMDD.md`
