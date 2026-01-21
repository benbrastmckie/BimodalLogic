# Implementation Plan: Task #654

- **Task**: 654 - Research Purely Syntactic Representation Theorem
- **Version**: 003
- **Status**: [IMPLEMENTING]
- **Effort**: 38 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/654_research_purely_syntactic_representation_theorem/reports/research-003.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan supersedes implementation-002.md with a revised directory strategy per user request:

1. **Archive First**: Move `Bimodal/Metalogic_v2/` to `Bimodal/Boneyard/Metalogic_v2/`
2. **Fresh Start**: Develop the Universal Parametric Canonical Model in `Bimodal/Metalogic/`
3. **Port Lazily**: Only port elements from the archived code when they become relevant during implementation

The mathematical approach remains the same as implementation-002.md: construct a TaskFrame parametric over ANY totally ordered additive commutative group D, with canonical worlds pairing MCS with abstract time points, and task_rel defined using D's group operations so frame conditions hold by construction.

### Key Changes from implementation-002.md

| Aspect | implementation-002.md | implementation-003.md |
|--------|----------------------|----------------------|
| Target directory | `Bimodal/Metalogic_v2/` | `Bimodal/Metalogic/` |
| Existing code | Extend in-place | Archive to Boneyard first |
| Porting strategy | N/A | Lazy - only when relevant |
| Phase 0 | N/A | Archive + directory setup |

### Research Integration

Same as implementation-002.md (research-003.md findings):
- Approach 4 (Algebraic/Lindenbaum-Tarski) rejected: Too much infrastructure cost
- Approach 5 (Syntactic Duration Type) rejected: Language extension bakes in unwanted assumptions
- **Recommended**: Universal Parametric Approach with MCS + abstract time point structure
- CanonicalWorld defined as MCS paired with time point from abstract D
- task_rel defined via D's operations (if-then-else on d=0, d>0, d<0)
- Compositionality becomes simple time arithmetic proof

## Goals & Non-Goals

**Goals**:
- Archive `Metalogic_v2/` to `Boneyard/Metalogic_v2/` preserving directory structure
- Create fresh `Bimodal/Metalogic/` with clean module hierarchy
- Define `CanonicalWorld D` structure as MCS + time point from D
- Define `canonical_task_rel` using D's algebraic operations abstractly
- Prove nullity (trivial: same MCS, same time at d=0)
- Prove compositionality (time arithmetic + formula propagation transitivity)
- Construct canonical WorldHistory through MCS worlds
- Prove Truth Lemma connecting MCS membership to semantic truth
- Define `UniversalCanonicalFrame D : TaskFrame D` for any D with typeclasses
- Define `UniversalCanonicalModel D : TaskModel (UniversalCanonicalFrame D)`
- Prove representation theorem: consistent formulas satisfiable in UniversalCanonicalModel

**Non-Goals**:
- Finite model property (separate concern using filtration)
- Strong completeness (only weak completeness)
- Algebraic/BAO infrastructure (rejected approach)
- Language extensions with explicit duration terms (rejected approach)
- Pre-emptive porting of unused Metalogic_v2 code
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Archive loses useful code | L | L | Boneyard preserves full history; git tracks moves |
| Missing MCS dependencies | M | M | Port Core/MaximalConsistent.lean early; verify imports |
| Truth Lemma backward directions complex | H | M | Leverage MCS closure properties; negation-completeness |
| WorldHistory construction needs Choice | M | L | Use noncomputable; acceptable for completeness proofs |
| Box + temporal operator interaction | M | M | Decouple: temporal handles time, modal handles formulas |
| Compatibility with existing Truth.lean | M | L | Truth.lean already parametric over D; verify alignment |
| Lengthy implementation time (38 hours) | M | M | Phase-level commits; mark phases [PARTIAL] on timeout |

## Implementation Phases

### Phase 0: Archive and Setup [COMPLETED]

**Goal**: Archive Metalogic_v2 and establish fresh Metalogic directory structure

**Tasks**:
- [ ] Create target directory: `Theories/Bimodal/Boneyard/Metalogic_v2/`
- [ ] Move entire `Theories/Bimodal/Metalogic_v2/` to `Theories/Bimodal/Boneyard/Metalogic_v2/`
- [ ] Update imports in Boneyard files to reflect new paths (if any cross-references exist)
- [ ] Create fresh `Theories/Bimodal/Metalogic/` directory structure:
  ```
  Metalogic/
  ├── Core/           # Basic definitions, provability, MCS theory
  ├── Representation/ # Canonical model, truth lemma
  └── Metalogic.lean  # Root module with exports
  ```
- [ ] Verify `lake build` succeeds (Boneyard not imported anywhere active)
- [ ] Create stub `Theories/Bimodal/Metalogic.lean` root module

**Timing**: 2 hours

**Files to modify**:
- Move: `Theories/Bimodal/Metalogic_v2/**` -> `Theories/Bimodal/Boneyard/Metalogic_v2/**`
- Create: `Theories/Bimodal/Metalogic/` directory structure
- Create: `Theories/Bimodal/Metalogic.lean` root module

**Verification**:
- Metalogic_v2 directory is empty or removed
- Boneyard/Metalogic_v2 contains all former content
- `lake build` succeeds
- Fresh Metalogic/ exists with planned subdirectories

---

### Phase 1: Port Core MCS Infrastructure [IN PROGRESS]

**Goal**: Port minimal MCS theory needed for canonical world definition

**Tasks**:
- [ ] Assess `Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` for required MCS definitions
- [ ] Create `Metalogic/Core/MaximalConsistent.lean` with essential MCS infrastructure:
  - `SetMaximalConsistent` definition
  - Negation completeness (`neg_complete`)
  - Deductive closure (`deductively_closed`)
  - Consistency preservation lemmas
- [ ] Port only definitions/lemmas used by later phases (verify with lean_hover_info)
- [ ] Create `Metalogic/Core/Basic.lean` for shared definitions if needed
- [ ] Create `Metalogic/Core.lean` root module for Core exports

**Timing**: 4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`
- `Theories/Bimodal/Metalogic/Core/Basic.lean` (if needed)
- `Theories/Bimodal/Metalogic/Core.lean`

**Verification**:
- `SetMaximalConsistent` compiles
- `neg_complete` and `deductively_closed` available
- `lean_diagnostic_messages` shows no errors
- `lake build` succeeds

---

### Phase 2: Define Canonical World Structure [NOT STARTED]

**Goal**: Create the CanonicalWorld structure pairing MCS with abstract time points

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean`
- [ ] Define `CanonicalWorld D` structure:
  ```lean
  structure CanonicalWorld (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
    mcs : Set Formula
    time : D
    is_mcs : SetMaximalConsistent mcs
  ```
- [ ] Define basic accessors and projections
- [ ] Prove basic MCS inheritance properties (consistent, maximal, negation-complete)
- [ ] Add helper lemmas for MCS membership reasoning

**Timing**: 4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean`

**Verification**:
- `CanonicalWorld D` compiles for arbitrary D with typeclasses
- `lean_diagnostic_messages` shows no errors
- MCS properties accessible via projection

---

### Phase 3: Define Canonical Task Relation [NOT STARTED]

**Goal**: Define task_rel using D's algebraic operations so frame conditions hold by construction

**Tasks**:
- [ ] Extend `CanonicalWorld.lean` or create new file for task relation
- [ ] Define `canonical_task_rel : CanonicalWorld D -> D -> CanonicalWorld D -> Prop`:
  ```lean
  def canonical_task_rel (w : CanonicalWorld D) (d : D) (v : CanonicalWorld D) : Prop :=
    if d = 0 then w.mcs = v.mcs ∧ w.time = v.time
    else if 0 < d then
      (∀ phi, Formula.all_future phi ∈ w.mcs → phi ∈ v.mcs) ∧
      (∀ phi, Formula.all_past phi ∈ v.mcs → phi ∈ w.mcs) ∧
      v.time = w.time + d
    else
      (∀ phi, Formula.all_past phi ∈ w.mcs → phi ∈ v.mcs) ∧
      (∀ phi, Formula.all_future phi ∈ v.mcs → phi ∈ w.mcs) ∧
      v.time = w.time + d
  ```
- [ ] Prove nullity: `canonical_task_rel w 0 w` trivially
- [ ] Prove compositionality base case (d1=0 or d2=0)
- [ ] Prove compositionality positive case (d1>0, d2>0)
- [ ] Prove compositionality negative case (d1<0, d2<0)
- [ ] Prove compositionality mixed case (sign(d1) != sign(d2))
- [ ] Handle edge cases for compositionality when d1+d2 crosses zero

**Timing**: 8 hours

**Files to modify**:
- Extend: `Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean`
- Or create: `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`

**Verification**:
- `canonical_task_rel_nullity : ∀ w, canonical_task_rel w 0 w` proven
- `canonical_task_rel_comp : ∀ w u v d1 d2, canonical_task_rel w d1 u → canonical_task_rel u d2 v → canonical_task_rel w (d1+d2) v` proven
- All cases closed without sorry

---

### Phase 4: Construct Canonical WorldHistory [NOT STARTED]

**Goal**: For each MCS, construct a WorldHistory that respects the task relation

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean`
- [ ] Define `canonical_history (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) : WorldHistory (UniversalCanonicalFrame D)`
- [ ] Prove history domain is full (all times in D)
- [ ] Prove domain convexity (trivial for full domain)
- [ ] Prove history respects_task condition
- [ ] Connect history states to CanonicalWorld structure
- [ ] Handle noncomputability appropriately (use Choice where needed)

**Timing**: 6 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean`

**Verification**:
- `canonical_history` compiles as `WorldHistory (UniversalCanonicalFrame D)`
- `respects_task` proof closed
- Convexity proof closed

---

### Phase 5: Prove Truth Lemma [NOT STARTED]

**Goal**: Connect MCS membership to semantic truth in canonical model

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
- [ ] Define `truth_lemma` statement:
  ```lean
  theorem truth_lemma (w : CanonicalWorld D) (phi : Formula) (tau : canonical_history w.mcs w.is_mcs) :
    phi ∈ w.mcs ↔ truth_at (UniversalCanonicalModel D) tau w.time phi
  ```
- [ ] Prove atom case (by valuation construction)
- [ ] Prove bot case (trivial)
- [ ] Prove imp case (using MCS closure)
- [ ] Prove box case (quantify over all histories = all MCS)
- [ ] Prove all_past forward direction (H phi ∈ MCS → all past times satisfy phi)
- [ ] Prove all_past backward direction (semantic truth → MCS membership)
- [ ] Prove all_future forward direction
- [ ] Prove all_future backward direction
- [ ] Handle temporal backward directions using MCS negation-completeness

**Timing**: 12 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`

**Verification**:
- All formula cases closed without sorry
- Induction on formula structure completes
- Backward directions use MCS properties correctly

---

### Phase 6: Instantiate TaskFrame and TaskModel [NOT STARTED]

**Goal**: Package construction into TaskFrame and TaskModel instances

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean`
- [ ] Define `UniversalCanonicalFrame D : TaskFrame D`:
  ```lean
  def UniversalCanonicalFrame (D : Type*) [...] : TaskFrame D where
    WorldState := CanonicalWorld D
    task_rel := canonical_task_rel
    nullity := canonical_task_rel_nullity
    compositionality := canonical_task_rel_comp
  ```
- [ ] Define valuation function: `canonical_valuation : (UniversalCanonicalFrame D).WorldState → String → Prop`
- [ ] Define `UniversalCanonicalModel D : TaskModel (UniversalCanonicalFrame D)`
- [ ] Create `Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean`
- [ ] Prove representation theorem:
  ```lean
  theorem representation_theorem (phi : Formula) (h_cons : Consistent {phi}) :
    ∃ (M : TaskModel (UniversalCanonicalFrame D)) (tau : WorldHistory (UniversalCanonicalFrame D)) (t : D),
      truth_at M tau t phi
  ```
- [ ] Create `Theories/Bimodal/Metalogic/Representation.lean` root module
- [ ] Update `Theories/Bimodal/Metalogic.lean` with full exports
- [ ] Verify integration with existing `Theories/Bimodal/Semantics/` types

**Timing**: 4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean`
- `Theories/Bimodal/Metalogic/Representation.lean`

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean`

**Verification**:
- `UniversalCanonicalFrame D` type-checks as `TaskFrame D`
- `UniversalCanonicalModel D` type-checks as `TaskModel (UniversalCanonicalFrame D)`
- Representation theorem compiles without sorry
- `lake build` succeeds

---

## Testing & Validation

- [ ] All new files compile without errors
- [ ] `lake build` succeeds for entire project
- [ ] No sorry remaining in Metalogic/ files
- [ ] `UniversalCanonicalFrame D` is valid `TaskFrame D` for any D with typeclasses
- [ ] Truth lemma covers all formula cases (atom, bot, imp, box, all_past, all_future)
- [ ] Representation theorem uses TaskModel not ad-hoc structure
- [ ] Parametric construction works for D = Int, D = Rat (verify with examples)
- [ ] Existing semantics (Truth.lean, WorldHistory.lean) remain unchanged
- [ ] Boneyard/Metalogic_v2 contains archived code for reference

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Metalogic_v2/` (archived previous attempt)
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` (MCS theory)
- `Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean` (world structure)
- `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean` (history construction)
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` (truth lemma proof)
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` (frame/model defs)
- `Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean` (main theorem)
- `specs/654_research_purely_syntactic_representation_theorem/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails or produces intractable proof obligations:

1. **Preserve progress**: Commit each completed phase to git
2. **Document issues**: Create error report in errors.json with:
   - Which phase failed
   - Specific proof obligations that couldn't be closed
   - Error messages from lean_diagnostic_messages
3. **Alternative approaches** (in priority order):
   - Port working elements from Boneyard/Metalogic_v2 as-is
   - Weaken compositionality to cover most cases with sorry for edge cases
   - Define specialized canonical_task_rel for different sign cases
4. **Restore from archive**: If fresh approach fails completely, restore Metalogic_v2 from Boneyard
5. **Mark task status**: If blocked, update to [BLOCKED] with technical description in TODO.md

## Porting Guidelines

When porting from `Boneyard/Metalogic_v2/`:

1. **Identify need first**: Don't port speculatively; port when implementation requires it
2. **Check compatibility**: Verify ported code aligns with new parametric approach
3. **Adapt imports**: Update module paths to new Metalogic/ structure
4. **Test incrementally**: Verify `lake build` after each port
5. **Document provenance**: Add comments noting ported code origin if substantial

**Likely ports** (based on Phase 1 analysis):
- MCS theory from `Core/MaximalConsistent.lean`
- Formula definition from `Core/Basic.lean` (or use existing Syntax)
- Provability definitions from `Core/Provability.lean`

**Unlikely ports** (superseded by new approach):
- `Representation/CanonicalModel.lean` (different world structure)
- `Representation/SemanticCanonicalModel.lean` (Int-specific)
- `Representation/FiniteWorldState.lean` (finite bounds approach)
