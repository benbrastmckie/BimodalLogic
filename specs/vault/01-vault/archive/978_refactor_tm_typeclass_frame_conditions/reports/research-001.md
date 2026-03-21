# Research Report: Task #978 - TM Typeclass Frame Condition Architecture

**Task**: 978 - refactor_tm_typeclass_frame_conditions
**Started**: 2026-03-16T12:00:00Z
**Completed**: 2026-03-16T13:30:00Z
**Effort**: ~6-8 hours implementation
**Dependencies**: Task 977 (COMPLETED), Task 979 (BLOCKED on covering lemma)
**Sources/Inputs**:
- Codebase: `Theories/Bimodal/`, `specs/state.json`, `specs/ROAD_MAP.md`
- Context files: logic/README.md, kripke-semantics-overview.md
- Mathlib: `DenselyOrdered`, `SuccOrder`, `PredOrder`, `IsOrderedAddMonoid`
**Artifacts**:
- This report: `specs/978_refactor_tm_typeclass_frame_conditions/reports/research-001.md`
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

- **Current architecture**: TM proof system has 21 axioms organized into Base (18), Dense (1), Discrete (3) via `FrameClass` enum in `Axioms.lean`. Task 977 established this organization.
- **Task 979 blocker**: The covering lemma (`mcs_has_immediate_successor`) is blocked because DF membership (syntactic) does not directly constrain MCS order structure (structural property).
- **Recommended refactor**: Define frame condition typeclasses (`DenseFrame`, `DiscreteFrame`, `SerialFrame`) that wrap Mathlib's `DenselyOrdered`, `SuccOrder`, `NoMaxOrder`, etc. Parameterize derivation, soundness, and completeness by these typeclasses.
- **Clean-break approach**: Create new `Theories/Bimodal/FrameConditions/` module hierarchy with typeclass-based proof systems, allowing the existing infrastructure to remain stable while the new architecture is developed.
- **Estimated effort**: 6-8 hours for Phase 1 (typeclass definitions + soundness), additional 4-6 hours for completeness wiring.

---

## Context & Scope

### Task 979 Blocking Issue

Task 979 attempted to remove `discrete_Icc_finite_axiom` by proving a covering lemma. The implementation was blocked at Phase 3:

**The Gap**: The covering lemma requires showing that if K is strictly between M and W (with `CanonicalR M K` and `CanonicalR K W`, `K != M`, `K != W`), we get a contradiction.

- **What we have**: DF membership (certain formulas in M), `g_content` subset relations
- **What we cannot bridge**: DF membership is SYNTACTIC; covering is STRUCTURAL
- **Root issue**: `CanonicalR M M'` means `g_content M <= M'`, which is a set inclusion, not an order-theoretic immediate successor property

The stage-bounding approach (research-001.md teammate analysis) was also shown to be likely FALSE: MCS witnesses can be created at arbitrarily high stages yet still fall between two lower-stage endpoints.

### Task 977 Completion

Task 977 established the current organization:
- `FrameClass` enum with `Base`, `Dense`, `Discrete` constructors
- `Axiom.frameClass`, `Axiom.isBase`, `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible` predicates
- `LogicVariants.lean` as summary module
- `BaseCompleteness.lean`, `DenseCompleteness.lean`, `DiscreteCompleteness.lean` documenting gaps

---

## Findings

### Codebase Patterns

#### Current Axiom Organization (Axioms.lean)

```lean
inductive FrameClass where
  | Base      -- 18 axioms valid on all linear orders
  | Dense     -- 1 axiom: density (DN)
  | Discrete  -- 3 axioms: discreteness_forward, seriality_future, seriality_past
```

The classification is done via:
- `Axiom.frameClass : Axiom phi -> FrameClass` (returns minimal frame class)
- `Axiom.isBase`, `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible` (boolean predicates)

#### Current Validity Definitions (Validity.lean)

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi

def valid_dense (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D] ...

def valid_discrete (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [PredOrder D] [Nontrivial D] ...
```

This is good but hardcodes the frame conditions in three separate definitions. A typeclass approach would unify these.

#### TaskFrame Structure (TaskFrame.lean)

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

The TaskFrame is parameterized by D but doesn't encode frame conditions as typeclass constraints. The refactor should make frame conditions first-class.

### Mathlib Typeclass Patterns

#### Relevant Mathlib Typeclasses

| Typeclass | Module | Purpose |
|-----------|--------|---------|
| `DenselyOrdered D` | `Mathlib.Order.Basic` | `forall a1 a2, a1 < a2 -> exists a, a1 < a /\ a < a2` |
| `SuccOrder D` | `Mathlib.Order.SuccPred.Basic` | Immediate successor function |
| `PredOrder D` | `Mathlib.Order.SuccPred.Basic` | Immediate predecessor function |
| `NoMaxOrder D` | `Mathlib.Order.Basic` | `forall a, exists b, a < b` |
| `NoMinOrder D` | `Mathlib.Order.Basic` | `forall a, exists b, b < a` |
| `IsSuccArchimedean D` | `Mathlib.Order.SuccPred.Basic` | Finite step reachability |
| `IsOrderedAddMonoid D` | `Mathlib.Algebra.Order.Monoid.Defs` | Order compatible with addition |

#### Typeclass Composition Pattern

Mathlib uses unbundled typeclasses that compose. For example:
```lean
-- Discrete orders
[LinearOrder D] [SuccOrder D] [PredOrder D] [NoMaxOrder D] [NoMinOrder D] [IsSuccArchimedean D]

-- Dense orders
[LinearOrder D] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]
```

We should follow this pattern for frame conditions.

### Existing Soundness Architecture (Soundness.lean)

```lean
theorem axiom_base_valid {phi : Formula} (h : Axiom phi) (hb : h.isBase) : valid phi
theorem axiom_valid_dense {phi : Formula} (h : Axiom phi) (hdc : h.isDenseCompatible) : valid_dense phi
theorem axiom_valid_discrete {phi : Formula} (h : Axiom phi) (hdc : h.isDiscreteCompatible) : valid_discrete phi
```

These are well-structured but use boolean predicates. A typeclass approach would use typeclass constraints:
```lean
theorem axiom_valid [FrameConditions D] {phi : Formula} (h : Axiom phi) (h_compat : AxiomCompatible h D) : valid_over D phi
```

### Completeness Infrastructure Status

| Component | File | Status |
|-----------|------|--------|
| Truth Lemma (Int) | `CanonicalConstruction.lean` | Sorry-free |
| Shifted Truth Lemma | `CanonicalConstruction.lean` | Sorry-free |
| Cantor Isomorphism | `CantorApplication.lean` | 3 sorries (quotient strictness) |
| TimelineQuot ≃o Q | `DenseCompleteness.lean` | Proven (component) |
| DiscreteTimelineQuot ≃o Z | `DiscreteCompleteness.lean` | Blocked by task 979 |
| FMCS Construction | `CanonicalFMCS.lean` | Sorry-free |

**Domain Mismatch**: Truth lemma proven for `D = Int`, but `valid_dense` quantifies over all `D` with `DenselyOrdered D`. Similar issue for discrete.

---

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | Low | We're not importing D; typeclass approach is orthogonal |
| Stage-bounding may be FALSE | HIGH | Task 979's approach doesn't work; need covering lemma via different method |
| Single-Family BFMCS modal_backward | Medium | Multi-family bundles essential; typeclass should parameterize family construction |
| Non-Standard Validity | Low | Standard validity (from Validity.lean) is correct; typeclass should preserve this |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | Typeclass should support D = TimelineQuot or D = DiscreteTimelineQuot |
| Indexed MCS Family Approach | ACTIVE | FMCS construction should be parameterized by frame class |
| Representation-First Architecture | CONCLUDED | Completeness derives from representation; typeclass parameterizes the representation |

**Key Insight from Dead Ends**: The covering lemma gap in task 979 suggests that DF membership alone doesn't give SuccOrder. We may need to:
1. Accept the covering lemma as axiomatic debt (similar to `discrete_Icc_finite_axiom`)
2. Or find a fundamentally different proof structure

---

## Recommendations

### Architecture Overview

Define a typeclass-based hierarchy for frame conditions that:
1. Wraps Mathlib's order typeclasses (DenselyOrdered, SuccOrder, etc.)
2. Parameterizes derivation by frame class
3. Parameterizes soundness/completeness by frame class
4. Provides a clean, modular API for proving theorems in specific frame classes

### Proposed Typeclass Hierarchy

```lean
-- Frame condition typeclasses (in FrameConditions/FrameClass.lean)

/-- A linear temporal frame (base TM logic). -/
class LinearTemporalFrame (D : Type*) extends
    AddCommGroup D, LinearOrder D, IsOrderedAddMonoid D

/-- A dense temporal frame (TM + DN axiom). -/
class DenseTemporalFrame (D : Type*) extends LinearTemporalFrame D where
  dense : DenselyOrdered D
  nontrivial : Nontrivial D
  no_max : NoMaxOrder D
  no_min : NoMinOrder D

/-- A discrete temporal frame (TM + DF/SF/SP axioms). -/
class DiscreteTemporalFrame (D : Type*) extends LinearTemporalFrame D where
  succ : SuccOrder D
  pred : PredOrder D
  nontrivial : Nontrivial D
  no_max : NoMaxOrder D
  no_min : NoMinOrder D
  succ_arch : IsSuccArchimedean D

/-- A serial frame (has future and past). -/
class SerialFrame (D : Type*) extends LinearTemporalFrame D where
  no_max : NoMaxOrder D
  no_min : NoMinOrder D
```

### Parameterized Validity

```lean
-- Replace three separate definitions with one parameterized definition

/-- Validity over a specific frame class. -/
def valid_over (FrameClass : Type* -> Prop) (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [h : FrameClass D] (F : TaskFrame D) ...

-- Instantiate for each frame class
def valid := valid_over LinearTemporalFrame
def valid_dense := valid_over DenseTemporalFrame
def valid_discrete := valid_over DiscreteTemporalFrame
```

### Parameterized Axiom Compatibility

```lean
/-- An axiom is compatible with a frame class if it is valid on that frame class. -/
class AxiomCompatible (phi : Formula) (h : Axiom phi) (FrameClass : Type* -> Prop) where
  valid : forall D [FrameClass D], valid_over FrameClass phi

-- Base axioms are compatible with all frame classes
instance base_axiom_compat {phi} (h : Axiom phi) (hb : h.isBase) : AxiomCompatible phi h F := ...

-- Dense axiom compatible with DenseTemporalFrame
instance density_compat {phi} (h : Axiom.density phi) : AxiomCompatible phi h DenseTemporalFrame := ...

-- Discrete axioms compatible with DiscreteTemporalFrame
instance discreteness_compat {phi} (h : Axiom.discreteness_forward phi) : AxiomCompatible phi h DiscreteTemporalFrame := ...
```

### Directory Reorganization

**Proposed Structure**:
```
Theories/Bimodal/
  FrameConditions/
    FrameClass.lean           -- Typeclass definitions
    Compatibility.lean        -- Axiom compatibility instances
    DenseFrameProperties.lean -- Dense-specific lemmas
    DiscreteFrameProperties.lean -- Discrete-specific lemmas
  Metalogic/
    Soundness/
      BaseSoundness.lean      -- Soundness for LinearTemporalFrame
      DenseSoundness.lean     -- Soundness for DenseTemporalFrame
      DiscreteSoundness.lean  -- Soundness for DiscreteTemporalFrame
      UnifiedSoundness.lean   -- Parameterized soundness
    Completeness/
      BaseCompleteness.lean   -- (existing, refactored)
      DenseCompleteness.lean  -- (existing, refactored)
      DiscreteCompleteness.lean -- (existing, refactored)
      UnifiedCompleteness.lean -- Parameterized completeness
```

### Implementation Phases

#### Phase 1: Define Frame Condition Typeclasses (2-3 hours)
1. Create `FrameConditions/FrameClass.lean` with the typeclass hierarchy
2. Define `LinearTemporalFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`, `SerialFrame`
3. Prove instance relationships (Dense extends Linear, Discrete extends Linear)
4. Ensure compatibility with existing Validity.lean definitions

#### Phase 2: Parameterized Soundness (2-3 hours)
1. Create `Soundness/UnifiedSoundness.lean`
2. Define `valid_over` parameterized by frame class
3. Prove soundness for each frame class using typeclass constraints
4. Refactor existing soundness to use new infrastructure

#### Phase 3: Axiom Compatibility (1-2 hours)
1. Create `FrameConditions/Compatibility.lean`
2. Define `AxiomCompatible` typeclass
3. Prove compatibility instances for all 21 axioms

#### Phase 4: Completeness Wiring (Future, depends on task 979)
1. Refactor completeness modules to use frame condition typeclasses
2. Resolve domain mismatch (TimelineQuot vs Int)
3. Wire truth lemmas with typeclass constraints

### Handling Task 979 Blocker

The covering lemma gap affects discrete completeness but NOT:
- Typeclass definitions (can define `DiscreteTemporalFrame` without proving covering)
- Soundness (already proven)
- Dense completeness (independent)

**Recommendation**: Proceed with phases 1-3 while task 979 remains blocked. The typeclass infrastructure can be built independently.

For discrete completeness, two options:
1. **Accept axiom**: Keep `discrete_Icc_finite_axiom` as documented debt; the typeclass design accommodates this
2. **Alternative proof**: Research alternative covering lemma proofs (e.g., Goldblatt/Burgess technique using frame correspondence directly)

---

## Decisions

1. **Use Mathlib typeclasses directly**: Wrap `DenselyOrdered`, `SuccOrder`, etc. rather than creating custom predicates
2. **Parameterize by frame class, not axiom set**: The frame class determines validity, not the specific axioms used
3. **Clean-break approach**: Create new module hierarchy rather than refactoring in place
4. **Preserve existing infrastructure**: Existing soundness/completeness remains stable; new infrastructure builds on top

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Typeclass inference issues | Medium | High | Use explicit instances; avoid complex instance search |
| Universe level mismatches | Low | Medium | Use `Type` (not `Type*`) consistently as in existing code |
| Task 979 never resolves | Medium | High | Document covering lemma as intentional debt; proceed with soundness |
| Mathlib version incompatibility | Low | Medium | Lock Mathlib version; test with current toolchain |

---

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Frame condition typeclasses | Recommendations | No | new_file |
| Domain mismatch (Int vs TimelineQuot) | Findings | Partial (in DenseCompleteness.lean) | extension |
| Covering lemma gap | Findings | Partial (in task 979) | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `typeclass-frame-conditions.md` | `domain/` | Frame condition typeclass design patterns | High | Yes |
| `completeness-domain-mismatch.md` | `domain/` | Analysis of Int vs dense/discrete domain gaps | Medium | No |

**Rationale for new files**:
- `typeclass-frame-conditions.md`: Central reference for the new architecture; will be needed by all future frame condition work

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `kripke-semantics-overview.md` | Frame Conditions | Add section on typeclass-based frame conditions | Medium | No |
| `modal-proof-strategies.md` | Completeness | Add note on domain mismatch resolution | Low | No |

### Summary

- **New files needed**: 1
- **Extensions needed**: 2
- **Tasks to create**: 1 (context file for typeclass design)
- **High priority gaps**: 1

---

## Appendix

### Search Queries Used

1. **Codebase exploration**:
   - `Glob Theories/Bimodal/**/*.lean` - Found 95+ Lean files
   - `Grep LogicVariant|FrameClass` - Found Axioms.lean, LogicVariants.lean, README.md

2. **Mathlib lookup**:
   - `lean_leansearch "typeclass hierarchy for ordered groups"` - Found IsOrderedAddMonoid, LinearOrder hierarchy
   - `lean_loogle "DenselyOrdered"` - Found Mathlib.Order.Basic, exists_between lemmas
   - `lean_loogle "SuccOrder"` - Found Mathlib.Order.SuccPred.Basic, Order.succ function

### Key Codebase Files Examined

| File | Lines | Key Content |
|------|-------|-------------|
| `Axioms.lean` | 570 | FrameClass enum, axiom classification |
| `Validity.lean` | 267 | valid, valid_dense, valid_discrete definitions |
| `TaskFrame.lean` | 303 | TaskFrame structure, nullity/compositionality |
| `LogicVariants.lean` | 195 | Logic variant summary, soundness re-exports |
| `BaseCompleteness.lean` | 179 | Base truth lemma, completeness infrastructure |
| `DenseCompleteness.lean` | 200 | Domain mismatch documentation |
| `DiscreteCompleteness.lean` | 243 | Task 979 dependency documentation |
| `DiscreteTimeline.lean` | 400+ | Covering lemma gap, axiom debt |

### References to Documentation

- ROAD_MAP.md: D Construction strategy, Dead Ends (stage-bounding, covering)
- specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/reports/research-001.md: Covering lemma analysis
- specs/979_remove_discrete_icc_finite_axiom_prove_stage_bounding/summaries/implementation-summary-20260316.md: Blocking gap details
- specs/977_organize_tm_base_logic_with_extensions/summaries/implementation-summary-20260316.md: Task 977 completion
