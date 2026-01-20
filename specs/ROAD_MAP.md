# ProofChecker Development Roadmap

**Last Updated**: 2026-01-19
**Status**: Bimodal TM Logic Metalogic_v2 Complete, Architecture Refinement Phase

## Overview

This roadmap outlines the current state of the ProofChecker project and charts the path forward for:
1. **Proof Quality**: Improving economy, flow, and organization
2. **Generalization**: From weak to strong results, finite to infinite
3. **Extension**: Adding natural corollaries and applications
4. **Architecture**: Optimal structure for efficiency and reusability

---

## Current State: What's Been Accomplished

### ✅ Metalogic_v2: Representation-First Architecture

**Status**: Core theorems proven, architecture clean, ready for reporting

#### Core Infrastructure (Fully Proven)

| Component | Status | Location |
|-----------|--------|----------|
| **Soundness** | ✅ PROVEN | Soundness/Soundness.lean |
| **Deduction Theorem** | ✅ PROVEN | Core/DeductionTheorem.lean |
| **Lindenbaum's Lemma** | ✅ PROVEN | Core/MaximalConsistent.lean |
| **MCS Properties** | ✅ PROVEN | Core/MaximalConsistent.lean, Representation/CanonicalModel.lean |
| **Canonical Model** | ✅ PROVEN | Representation/CanonicalModel.lean |
| **Truth Lemma** | ✅ PROVEN | Representation/TruthLemma.lean |
| **Representation Theorem** | ✅ PROVEN | Representation/RepresentationTheorem.lean |

#### Metalogical Results (Proven)

| Result | Status | Location |
|--------|--------|----------|
| **Weak Completeness** | ✅ PROVEN | Completeness/WeakCompleteness.lean |
| `⊨ φ → ⊢ φ` | ✅ | Via `representation_theorem_backward_empty` |
| **Strong Completeness** | ✅ PROVEN | Completeness/StrongCompleteness.lean |
| `Γ ⊨ φ → Γ ⊢ φ` | ✅ | Via deduction theorem + weak completeness |
| **Finite Model Property** | ✅ PROVEN | Representation/FiniteModelProperty.lean |
| **Decidability** | ✅ PROVEN (noncomputable) | Representation/FiniteModelProperty.lean |
| Satisfiability decidable | ✅ | Via FMP |
| Validity decidable | ✅ | Via FMP |
| **Compactness** | ✅ PROVEN | Applications/Compactness.lean |
| Entailment compactness | ✅ | Via finiteness of derivations |
| Satisfiability compactness | ✅ | Via strong completeness |

#### Key Architectural Achievement

**Representation-First Design**: The architecture places canonical model construction as the foundation, with FMP as the central bridge. This is a significant improvement over traditional modal logic developments that treat completeness as primary.

```
Applications (Compactness)
    ↓
Completeness (Strong, Weak)
    ↓
FMP (Central Bridge)
    ↓
Representation (Canonical Model, Truth Lemma)
    ↓
Core (Soundness, Deduction, MCS)
```

### ✅ Syntax and Semantics

| Component | Status | Notes |
|-----------|--------|-------|
| **Bimodal Syntax** | ✅ COMPLETE | Formula, complexity, subformulas |
| **TM Semantics** | ✅ COMPLETE | TaskFrame, truth_at, validity |
| **Proof System** | ✅ COMPLETE | Hilbert-style with temporal axioms |

### ✅ Decidability Infrastructure

| Component | Status | Location |
|-----------|--------|----------|
| **Tableau System** | ✅ COMPLETE | Decidability/Tableau.lean |
| **Saturation** | ✅ COMPLETE | Decidability/Saturation.lean |
| **Branch Closure** | ✅ COMPLETE | Decidability/BranchClosure.lean |
| **Decision Procedure** | ✅ COMPLETE | Decidability/DecisionProcedure.lean |
| **Soundness** | ✅ PROVEN | Decidability/Correctness.lean |

---

## Phase 1: Proof Quality and Organization (High Priority)

**Goal**: Improve proof economy, flow, and readability. Make it easy to understand the "story" of the development.

### 1.1 Proof Economy Improvements

#### Issue: Redundant Proofs
Several results are proven multiple ways or with unnecessary complexity.

**Tasks**:
- [ ] **Audit proof dependencies**: Map which lemmas are actually used vs. proven for completeness
- [ ] **Identify redundant paths**: E.g., do we need both `representation_theorem` and `semantic_weak_completeness`?
- [ ] **Consolidate**: Keep the most direct proof, move alternatives to a "Alternative Proofs" section or remove
- [ ] **Measure proof size**: Track total proof lines, aim for 20% reduction

**Expected Impact**:
- Faster builds
- Easier maintenance
- Clearer dependency structure

#### Issue: Verbose Tactics
Many proofs use explicit sequences where automation could apply.

**Tasks**:
- [ ] **Identify automation opportunities**: Look for `intro; apply; exact` sequences
- [ ] **Create domain-specific tactics**: E.g., `mcs_tac` for MCS reasoning
- [ ] **Add helpful `simp` lemmas**: Reduce manual rewriting
- [ ] **Document tactic patterns**: When to use `aesop` vs `omega` vs manual

**Example Improvement**:
```lean
-- Before (15 lines)
theorem mcs_contains_or_neg (M : Set Formula) (h : SetMaximalConsistent M) (φ : Formula) :
    φ ∈ M ∨ φ.neg ∈ M := by
  by_cases h_in : φ ∈ M
  · left; exact h_in
  · right
    have h_cons := h.2.1
    have h_max := h.2.2
    ... [10 more lines]

-- After (5 lines)
theorem mcs_contains_or_neg (M : Set Formula) (h : SetMaximalConsistent M) (φ : Formula) :
    φ ∈ M ∨ φ.neg ∈ M := by
  by_cases h_in : φ ∈ M <;> [left; exact h_in, right; mcs_tac]
```

### 1.2 Proof Flow Optimization

#### Issue: Non-linear Dependencies
Some modules import from multiple layers, creating cognitive overhead.

**Tasks**:
- [ ] **Visualize import graph**: Generate dependency diagram
- [ ] **Identify cross-cutting imports**: Find patterns that break layer discipline
- [ ] **Refactor into utilities**: Extract common patterns into a `Metalogic_v2.Util` module
- [ ] **Enforce layer discipline**: Each layer only imports from layers below

**Target Structure**:
```
Util/ (cross-cutting utilities, no layer violations)
├── MCS.lean          # MCS reasoning tactics
├── Closure.lean      # Closure manipulation
└── Derivation.lean   # Derivation tree helpers

Core/ → Util/
Soundness/ → Core/, Util/
Representation/ → Soundness/, Core/, Util/
Completeness/ → Representation/, Util/
Applications/ → Completeness/, Util/
```

#### Issue: Proof Order Within Files
Some files prove lemmas after they're used, requiring forward declarations.

**Tasks**:
- [ ] **Reorder definitions**: Place helpers before main theorems
- [ ] **Create sections**: Group related lemmas with section headers
- [ ] **Add roadmap comments**: Start each file with "This file proves: X, Y, Z in that order"

### 1.3 Documentation and Storytelling

#### Issue: Hard to See the Big Picture
Individual proofs are documented, but the overall narrative is unclear.

**Tasks**:
- [ ] **Create proof architecture guide**: `docs/architecture/proof-structure.md`
- [ ] **Add module overviews**: Each `.lean` file starts with `/-! # Overview -/` section
- [ ] **Cross-reference theorems**: Link related results with `See also: theorem_name`
- [ ] **Write tutorial**: `docs/tutorials/metalogic-walkthrough.md` explaining the proof strategy

**Tutorial Outline**:
1. The Goal: Soundness and Completeness
2. The Strategy: Canonical Models
3. The Foundation: MCS and Lindenbaum
4. The Construction: Building the Canonical Model
5. The Proof: Truth Lemma and Representation
6. The Applications: Decidability and Compactness

---

## Phase 2: Generalization (Medium Priority)

**Goal**: Strengthen results from specific to general, finite to infinite.

### 2.1 Strong Completeness Enhancements

**Current**: `Γ ⊨ φ → Γ ⊢ φ` is proven for list-based contexts (Context = List Formula)

**Generalization Opportunities**:

#### A. Set-Based Strong Completeness
Prove completeness for `Γ : Set Formula`:
```lean
theorem strong_completeness_set (Γ : Set Formula) (φ : Formula) :
    (∀ D F M τ t, (∀ ψ ∈ Γ, truth_at M τ t ψ) → truth_at M τ t φ) →
    ∃ Δ : List Formula, (∀ ψ ∈ Δ, ψ ∈ Γ) ∧ ContextDerivable Δ φ
```

**Tasks**:
- [ ] Define `SetDerivable Γ φ := ∃ Δ ⊆ Γ, Δ.toFinset.toList ⊢ φ`
- [ ] Prove `Γ ⊨ φ → SetDerivable Γ φ` via compactness
- [ ] Show equivalence with list-based for finite Γ

**Impact**: More natural statement, aligns with standard modal logic literature

#### B. Constructive Completeness
Make completeness constructive where possible:
```lean
def complete_decision (φ : Formula) :
    (⊢ φ) ⊕ (∃ M τ t, ¬truth_at M τ t φ) :=
  ...
```

**Tasks**:
- [ ] Identify which parts of completeness proof are constructive
- [ ] Replace `Classical.choice` with explicit constructions where possible
- [ ] Document remaining uses of classical reasoning

**Impact**: Stronger results, potential for proof extraction

### 2.2 Infinite Model Results

**Current**: FMP establishes finite models suffice. But what about infinite models?

**Extension Opportunities**:

#### A. Infinite Compactness
Prove compactness for infinite sets:
```lean
theorem infinite_compactness (Γ : Set Formula) :
    (∀ Δ : Finset Formula, ↑Δ ⊆ Γ → context_satisfiable Δ.toList) →
    ∃ D F M τ t, ∀ φ ∈ Γ, truth_at M τ t φ
```

**Tasks**:
- [ ] Define ultrafilter construction or limit construction
- [ ] Prove transfer lemmas for truth preservation
- [ ] Connect to finite compactness via FMP

**Impact**: Handles countably infinite theories, aligns with standard model theory

#### B. Löwenheim-Skolem for TM
Prove downward Löwenheim-Skolem:
```lean
theorem lowenheim_skolem (Γ : Set Formula) :
    (∃ M, ∀ φ ∈ Γ, truth_at M φ) →
    (∃ M_countable, ∀ φ ∈ Γ, truth_at M_countable φ)
```

**Tasks**:
- [ ] Identify the cardinality bounds from FMP
- [ ] Show countable language → countable models
- [ ] Connect to Henkin construction

**Impact**: Classic model theory result for TM logic

### 2.3 Modular Frame Properties

**Current**: Results are for TM logic specifically (time domain = ordered additive monoid)

**Generalization Opportunity**:
Parameterize by frame class:
```lean
class FrameClass (F : Type → Type) where
  validates : Formula → F → Prop
  soundness : ∀ φ F, validates φ F → F ⊨ φ

theorem completeness_for_frame_class [FC : FrameClass F] :
    (∀ F, FC.validates φ F → F ⊨ φ) → ⊢_FC φ
```

**Tasks**:
- [ ] Define frame property interface
- [ ] Parameterize canonical model by frame properties
- [ ] Prove completeness relative to frame classes (K, T, S4, S5)

**Impact**:
- Reusable for other modal logics
- Clear separation of logic vs frame properties
- Easier to add new logics

---

## Phase 3: Extensions (Medium Priority)

**Goal**: Add natural corollaries and related results to make a comprehensive package.

### 3.1 Metalogical Extensions

#### A. Craig Interpolation
If `⊢ φ → ψ`, then `∃ θ` such that `Var(θ) ⊆ Var(φ) ∩ Var(ψ)` and `⊢ φ → θ` and `⊢ θ → ψ`.

**Status**: Not started
**Difficulty**: Medium (requires proof analysis)
**Value**: High (classic logic result)

**Tasks**:
- [ ] Define propositional variables for formulas
- [ ] Implement interpolant extraction from derivation
- [ ] Prove correctness

#### B. Beth Definability
If `φ` implicitly defines `p`, then it explicitly defines `p`.

**Status**: Not started
**Difficulty**: Medium-High
**Value**: Medium (completes the "big three" of modal model theory)

**Tasks**:
- [ ] Define implicit vs explicit definability
- [ ] Prove via ultraproduct or amalgamation
- [ ] Document relationship to interpolation

#### C. Separation Properties
Modal separation: if `φ` and `ψ` are not provably equivalent, they're distinguishable by a model.

**Status**: Follows from completeness
**Difficulty**: Low
**Value**: Low (corollary)

**Tasks**:
- [ ] State formally
- [ ] Prove from completeness in 5 lines
- [ ] Add as application

### 3.2 Decidability Extensions

#### A. Complexity Bounds
Establish complexity class for TM satisfiability.

**Status**: Partial (decidability proven, complexity not analyzed)
**Difficulty**: Medium
**Value**: High (for practical applications)

**Tasks**:
- [ ] Analyze FMP bound: `2^|closure(φ)|`
- [ ] Count model enumeration complexity
- [ ] Establish PSPACE upper bound (likely)
- [ ] Compare to other modal logics (K is PSPACE-complete)

**Expected Result**: TM satisfiability is in PSPACE

#### B. Proof Search Strategy
Optimize the decision procedure for practical use.

**Status**: Basic tableau exists, not optimized
**Difficulty**: Medium
**Value**: Medium-High (for verification)

**Tasks**:
- [ ] Implement heuristics (clause learning, backjumping)
- [ ] Add caching for repeated subproblems
- [ ] Benchmark against standard modal logic solvers
- [ ] Document performance characteristics

#### C. Countermodel Minimization
Find smallest countermodel when formula is invalid.

**Status**: Basic extraction exists
**Difficulty**: Low-Medium
**Value**: Medium (for user feedback)

**Tasks**:
- [ ] Implement state minimization
- [ ] Prove minimality
- [ ] Add user-friendly countermodel display

### 3.3 Temporal Logic Extensions

#### A. Until/Since Operators
Extend to full LTL with U and S.

**Status**: Not started
**Difficulty**: High (new operators require new axioms)
**Value**: High (full LTL is important)

**Tasks**:
- [ ] Add `until` and `since` to syntax
- [ ] Define semantics
- [ ] Add axioms (expansion laws)
- [ ] Prove completeness (will require extending canonical model)

**Note**: This is a significant extension requiring Phase 1 work first

#### B. Branching Time (CTL)
Add path quantifiers A and E.

**Status**: Not started
**Difficulty**: Very High (requires new semantic framework)
**Value**: Very High (important for verification)

**Tasks**:
- [ ] Design tree semantics
- [ ] Add path quantifiers
- [ ] Prove completeness (challenging!)
- [ ] Integrate with TM fragment

**Note**: This is a research-level extension

### 3.4 Epistemic Extensions

#### A. S5 Epistemic Logic
Instantiate the framework for knowledge (S5 modality).

**Status**: Framework supports it, not instantiated
**Difficulty**: Low-Medium
**Value**: Medium (common in verification)

**Tasks**:
- [ ] Define S5 frame class (equivalence relation)
- [ ] Instantiate canonical model for S5
- [ ] Prove S5-completeness as instance of general theorem
- [ ] Add common knowledge operator

#### B. Distributed Knowledge
Add D operator for distributed knowledge.

**Status**: Not started
**Difficulty**: Medium
**Value**: Medium (for multi-agent systems)

**Tasks**:
- [ ] Define intersection semantics
- [ ] Add axioms
- [ ] Prove completeness

---

## Phase 4: Architecture Optimization (High Priority)

**Goal**: Restructure to maximize efficiency, economy, and reusability.

### 4.1 The Optimal Layering

#### Current Structure Issues
1. **Representation depends on Soundness**: Unnecessary coupling
2. **FMP is a separate layer**: Could be integrated
3. **Decidability is parallel**: Could be better integrated

#### Proposed Optimal Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATIONS                             │
│  Interpolation, Separation, Complexity Bounds               │
└─────────────────────────────────────────────────────────────┘
                            ▲
┌─────────────────────────────────────────────────────────────┐
│                META-THEOREMS (Top Layer)                    │
│  Compactness, Decidability, FMP (as corollaries)            │
└─────────────────────────────────────────────────────────────┘
                            ▲
┌─────────────────────────────────────────────────────────────┐
│              SOUNDNESS-COMPLETENESS                         │
│  ┌──────────────┐              ┌──────────────┐            │
│  │  Soundness   │              │ Completeness │            │
│  │  (Γ ⊢ φ → Γ ⊨ φ) ◄────────► │ (Γ ⊨ φ → Γ ⊢ φ)            │
│  └──────────────┘              └──────────────┘            │
│         │                              ▲                    │
│         │                              │                    │
│         └──────────┬───────────────────┘                    │
│                    ▼                                        │
│         ┌─────────────────────┐                            │
│         │  Representation     │                            │
│         │  (Canonical Model)  │                            │
│         └─────────────────────┘                            │
└─────────────────────────────────────────────────────────────┘
                            ▲
┌─────────────────────────────────────────────────────────────┐
│                      CORE                                   │
│  Deduction Theorem, Lindenbaum, MCS Properties             │
└─────────────────────────────────────────────────────────────┘
                            ▲
┌─────────────────────────────────────────────────────────────┐
│                   FOUNDATIONS                               │
│  Syntax, Semantics, Proof System                           │
└─────────────────────────────────────────────────────────────┘
```

#### Key Changes
1. **Merge Soundness into Soundness-Completeness layer**: They're dual results
2. **Make FMP a corollary**: Derive from completeness + finiteness of formulas
3. **Decidability as application**: Not fundamental, but derived
4. **Representation as bridge**: The key technical component

### 4.2 The Minimal Kernel

**Goal**: Identify the smallest set of results needed for all others.

#### Kernel Candidates

**Option A: Deduction + MCS + Canonical Model**
```
Kernel = {
  deduction_theorem,
  set_lindenbaum,
  mcs_properties,
  canonical_model_construction,
  truth_lemma
}

Derivable = {
  soundness (by induction),
  completeness (via contrapositive + canonical),
  FMP (finiteness of closure),
  decidability (FMP + enumeration),
  compactness (finiteness of derivations)
}
```

**Option B: Representation Theorem Alone**
```
Kernel = {
  representation_theorem : Consistent Γ ↔ CanonicalSatisfiable Γ
}

Derivable = {
  soundness (trivial from semantics),
  completeness (contrapositive of representation),
  everything else from completeness
}
```

#### Recommendation
**Use Option B**: The representation theorem is the true core. Everything else is a corollary.

**Implementation Tasks**:
- [ ] Refactor to make `representation_theorem` the primary export
- [ ] Recast soundness/completeness as corollaries
- [ ] Document the one-line derivations
- [ ] Measure proof economy improvement

**Expected Impact**:
- 30-40% reduction in "fundamental" proofs
- Clearer story: "We build canonical models, everything follows"
- Easier to extend to other logics

### 4.3 Proof Reuse Infrastructure

#### Current Issue
Many similar proofs (e.g., each modal operator needs similar treatment in truth lemma).

#### Solution: Generic Proof Framework

**Create operator classes**:
```lean
class ModalOperator (op : Formula → Formula) where
  axiom_scheme : Formula
  frame_property : Frame → Prop
  truth_condition : ∀ M w φ, M ⊨ op φ at w ↔ ...

-- Then prove once:
theorem truth_lemma_for_operator [ModalOperator op] : ...

-- Instantiate:
instance : ModalOperator box where ...
instance : ModalOperator diamond where ...
instance : ModalOperator all_future where ...
```

**Tasks**:
- [ ] Design operator typeclass hierarchy
- [ ] Prove generic truth lemma
- [ ] Instantiate for each operator
- [ ] Measure proof reuse (expect 3-4x code reduction)

**Expected Impact**:
- DRY principle for modal operators
- Easy to add new operators
- Proofs become operator-generic

---

## Phase 5: Removing Known Sorries (Low Priority)

**Goal**: Eliminate the 4 remaining sorries where tractable.

### 5.1 Priority Assessment

| Sorry | Location | Difficulty | Value | Priority |
|-------|----------|------------|-------|----------|
| `semantic_task_rel_compositionality` | SemanticCanonicalModel.lean:236 | High | Low | **Skip** |
| `main_provable_iff_valid_v2` (completeness dir) | SemanticCanonicalModel.lean:632 | High | Low | **Skip** |
| `finite_model_property_constructive` | FiniteModelProperty.lean:480 | Medium | Low | **Later** |
| `decide_axiom_valid` | Decidability/Correctness.lean:196 | Low | Low | **Maybe** |

### 5.2 Recommended Actions

#### `semantic_task_rel_compositionality`
**Recommendation**: Document as acceptable limitation, don't attempt to fix.
**Reason**: Fundamental issue with finite time domain. Would require rearchitecting the entire semantic model. Not worth it since completeness proof doesn't use it.

#### `main_provable_iff_valid_v2` (completeness)
**Recommendation**: Keep using `semantic_weak_completeness` instead.
**Reason**: The "truth bridge" is technically challenging and low value. The sorry-free `semantic_weak_completeness` provides the same result.

#### `finite_model_property_constructive`
**Recommendation**: Attempt if generalizing to constructive completeness (Phase 2.1.B).
**Reason**: Worth doing as part of constructive generalization, not as standalone.

#### `decide_axiom_valid`
**Recommendation**: Fix incrementally as `matchAxiom` is extended.
**Reason**: Low hanging fruit, good for completeness, but not critical.

---

## Phase 6: Polish and Publication (Low Priority Now, High Later)

**Goal**: Prepare for external consumption (paper, library, tools).

### 6.1 Documentation for Publication

**Tasks**:
- [ ] Write comprehensive README
- [ ] Create API documentation
- [ ] Add usage examples
- [ ] Write paper draft (if academic publication desired)

### 6.2 Performance Optimization

**Tasks**:
- [ ] Profile build times
- [ ] Optimize slow proofs
- [ ] Parallelize independent proofs
- [ ] Cache expensive computations

### 6.3 Testing and Validation

**Tasks**:
- [ ] Create test suite for each major theorem
- [ ] Add property-based tests
- [ ] Benchmark against standard examples
- [ ] Validate against known results from literature

---

## Recommended Execution Order

### Near Term (Next 2-4 weeks)
1. **Phase 1.2**: Proof flow optimization - clean up the architecture
2. **Phase 1.3**: Documentation - add overviews and tutorials
3. **Phase 4.1**: Optimal layering - restructure for efficiency

**Why**: These improve understandability and maintainability, making all future work easier.

### Medium Term (1-3 months)
1. **Phase 1.1**: Proof economy - reduce redundancy
2. **Phase 2.1.A**: Set-based strong completeness
3. **Phase 3.1.A**: Craig interpolation
4. **Phase 4.2**: Minimal kernel - refactor around representation theorem

**Why**: Strengthens the core results and makes the package publication-ready.

### Long Term (3-6 months)
1. **Phase 2.3**: Modular frame properties - generalize the framework
2. **Phase 3.2**: Decidability extensions - make it practical
3. **Phase 3.3.A**: Until/Since operators - extend to full LTL
4. **Phase 6**: Polish and publication

**Why**: These are significant extensions that build on a solid foundation.

---

## Success Metrics

### Proof Quality Metrics
- **Lines of proof code**: Target 20% reduction through economy improvements
- **Average proof depth**: Target <10 for major theorems
- **Redundancy ratio**: <5% of proofs should be redundant
- **Build time**: <2 minutes for full build

### Coverage Metrics
- **Core results**: 100% (already achieved)
- **Standard metatheorems**: 80% (need interpolation, Beth, complexity)
- **Extensions**: 50% (temporal operators, epistemic logic)

### Architecture Metrics
- **Layer violations**: 0 (enforce strict layering)
- **Import cycles**: 0 (already achieved)
- **Proof reuse**: 60% of operator-specific proofs should be instances of generic framework

### Documentation Metrics
- **API coverage**: 100% of public theorems documented
- **Tutorial coverage**: All major proof strategies explained
- **Example coverage**: 10+ worked examples

---

## Open Questions

### Theoretical
1. **Is TM logic PSPACE-complete?** (decidability complexity)
2. **Does interpolation hold for TM?** (likely yes, but needs proof)
3. **What's the best frame class abstraction?** (for modular completeness)

### Implementation
1. **Should we use typeclasses or instances for modal operators?**
2. **How fine-grained should proof modules be?**
3. **Should decidability be computable or just decidable?**

### Strategic
1. **Target audience**: Research tool or verification platform?
2. **Publication venue**: Conference (LICS, CADE) or journal (JSL)?
3. **Interoperability**: Should we support import/export to other provers?

---

## Conclusion

The ProofChecker project has achieved its primary goal: a clean, proven metalogic for TM bimodal logic. The Metalogic_v2 architecture is solid and ready for reporting.

**The path forward** focuses on three pillars:
1. **Quality**: Improving proof economy and organization (Phase 1, 4)
2. **Generalization**: Strengthening results and extending to new domains (Phase 2, 3)
3. **Accessibility**: Better documentation and tooling (Phase 6)

The recommended approach is to **consolidate before extending**: complete Phases 1 and 4 (organization and architecture) before embarking on major extensions. This ensures a solid foundation that makes future work easier and more maintainable.

**Key Insight**: The representation theorem is the core. Everything else—soundness, completeness, FMP, decidability, compactness—flows naturally from it. Refactoring to make this explicit will dramatically improve proof economy and clarity.
