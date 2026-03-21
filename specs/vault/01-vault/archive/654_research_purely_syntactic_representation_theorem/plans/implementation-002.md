# Implementation Plan: Task #654

- **Task**: 654 - Research Purely Syntactic Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 34 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/654_research_purely_syntactic_representation_theorem/reports/research-003.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement a Universal Parametric Canonical Model that constructs a TaskFrame parametric over ANY totally ordered additive commutative group D. This approach supersedes implementation-001.md by avoiding commitment to a concrete time type (like Int) and instead using D's algebraic operations abstractly. The key insight is that parametric completeness does not require extracting D from syntax - we keep D as a type parameter and define task_rel using D's group operations so that nullity and compositionality hold by construction.

### Research Integration

Integrated research-003.md findings:
- Approach 4 (Algebraic/Lindenbaum-Tarski) rejected: Too much infrastructure cost for TM's bimodal setting
- Approach 5 (Syntactic Duration Type) rejected: Language extension bakes in unwanted assumptions
- **Recommended**: Universal Parametric Approach with MCS + abstract time point structure
- CanonicalWorld defined as MCS paired with time point from abstract D
- task_rel defined via D's operations (if-then-else on d=0, d>0, d<0)
- Compositionality becomes simple time arithmetic proof

## Goals & Non-Goals

**Goals**:
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
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Truth Lemma backward directions complex | H | M | Leverage existing MCS closure properties in MaximalConsistent.lean; negation-completeness already proven |
| WorldHistory construction needs Choice | M | L | Use noncomputable; acceptable for completeness proofs |
| Box + temporal operator interaction | M | M | Decouple: temporal handles time arithmetic, modal handles formula propagation; use MCS closure |
| Compatibility with existing Truth.lean | M | L | Truth.lean already parametric over D; verify WorldHistory construction aligns |
| Lengthy implementation time (34 hours) | M | M | Phase-level commits; mark phases [PARTIAL] on timeout; resume from checkpoint |

## Implementation Phases

### Phase 1: Define Canonical World Structure [NOT STARTED]

**Goal**: Create the CanonicalWorld structure pairing MCS with abstract time points

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic_v2/Representation/UniversalCanonicalModel.lean`
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

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic_v2/Representation/UniversalCanonicalModel.lean`
- Import: `Metalogic_v2/Core/MaximalConsistent.lean`, `Bimodal/Semantics/TaskFrame.lean`

**Verification**:
- `CanonicalWorld D` compiles for arbitrary D with typeclasses
- `lean_diagnostic_messages` shows no errors
- MCS properties accessible via projection

---

### Phase 2: Define Canonical Task Relation [NOT STARTED]

**Goal**: Define task_rel using D's algebraic operations so frame conditions hold by construction

**Tasks**:
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
- Extend: `Theories/Bimodal/Metalogic_v2/Representation/UniversalCanonicalModel.lean`

**Verification**:
- `canonical_task_rel_nullity : ∀ w, canonical_task_rel w 0 w` proven
- `canonical_task_rel_comp : ∀ w u v d1 d2, canonical_task_rel w d1 u → canonical_task_rel u d2 v → canonical_task_rel w (d1+d2) v` proven
- All cases closed without sorry

---

### Phase 3: Construct Canonical WorldHistory [NOT STARTED]

**Goal**: For each MCS, construct a WorldHistory that respects the task relation

**Tasks**:
- [ ] Define `canonical_history (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) : WorldHistory (UniversalCanonicalFrame D)`
- [ ] Prove history domain is full (all times in D)
- [ ] Prove domain convexity (trivial for full domain)
- [ ] Prove history respects_task condition
- [ ] Connect history states to CanonicalWorld structure
- [ ] Handle noncomputability appropriately (use Choice where needed)

**Timing**: 6 hours

**Files to modify**:
- Extend: `Theories/Bimodal/Metalogic_v2/Representation/UniversalCanonicalModel.lean`

**Verification**:
- `canonical_history` compiles as `WorldHistory (UniversalCanonicalFrame D)`
- `respects_task` proof closed
- Convexity proof closed

---

### Phase 4: Prove Truth Lemma [NOT STARTED]

**Goal**: Connect MCS membership to semantic truth in canonical model

**Tasks**:
- [ ] Define `truth_lemma` statement:
  ```lean
  theorem truth_lemma (w : CanonicalWorld D) (phi : Formula) (tau : canonical_history w.mcs w.is_mcs) :
    phi ∈ w.mcs ↔ truth_at (UniversalCanonicalModel D) tau w.time phi
  ```
- [ ] Prove atom case (by valuation construction)
- [ ] Prove bot case (trivial)
- [ ] Prove imp case (using MCS closure)
- [ ] Prove box case (quantify over all histories = all MCS)
- [ ] Prove all_past forward direction (G phi ∈ MCS → all future times satisfy phi)
- [ ] Prove all_past backward direction (semantic truth → MCS membership)
- [ ] Prove all_future forward direction
- [ ] Prove all_future backward direction
- [ ] Handle temporal backward directions using MCS negation-completeness

**Timing**: 12 hours

**Files to modify**:
- Create: `Theories/Bimodal/Metalogic_v2/Representation/UniversalTruthLemma.lean`
- Import: `UniversalCanonicalModel.lean`, `Semantics/Truth.lean`

**Verification**:
- All formula cases closed without sorry
- Induction on formula structure completes
- Backward directions use MCS properties correctly

---

### Phase 5: Instantiate TaskFrame and TaskModel [NOT STARTED]

**Goal**: Package construction into TaskFrame and TaskModel instances

**Tasks**:
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
- [ ] Prove representation theorem:
  ```lean
  theorem representation_theorem (phi : Formula) (h_cons : Consistent {phi}) :
    ∃ (M : TaskModel (UniversalCanonicalFrame D)) (tau : WorldHistory (UniversalCanonicalFrame D)) (t : D),
      truth_at M tau t phi
  ```
- [ ] Update module documentation
- [ ] Ensure exports are clean

**Timing**: 4 hours

**Files to modify**:
- Extend: `Theories/Bimodal/Metalogic_v2/Representation/UniversalCanonicalModel.lean`
- Modify: `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` (update to use universal construction)
- Modify: `Theories/Bimodal/Metalogic_v2/Representation.lean` (update imports)

**Verification**:
- `UniversalCanonicalFrame D` type-checks as `TaskFrame D`
- `UniversalCanonicalModel D` type-checks as `TaskModel (UniversalCanonicalFrame D)`
- Representation theorem compiles without sorry
- `lake build` succeeds

---

## Testing & Validation

- [ ] All new files compile without errors
- [ ] `lake build` succeeds for entire project
- [ ] No sorry remaining in UniversalCanonicalModel or UniversalTruthLemma
- [ ] `UniversalCanonicalFrame D` is valid `TaskFrame D` for any D with typeclasses
- [ ] Truth lemma covers all formula cases (atom, bot, imp, box, all_past, all_future)
- [ ] Representation theorem uses TaskModel not ad-hoc structure
- [ ] Parametric construction works for D = Int, D = Rat (verify with examples)
- [ ] Existing semantics (Truth.lean, WorldHistory.lean) remain unchanged

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Representation/UniversalCanonicalModel.lean` (main construction)
- `Theories/Bimodal/Metalogic_v2/Representation/UniversalTruthLemma.lean` (truth lemma proof)
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` (updated theorem)
- `specs/654_research_purely_syntactic_representation_theorem/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails or produces intractable proof obligations:

1. **Preserve progress**: Commit each completed phase to git
2. **Document issues**: Create error report in errors.json with:
   - Which phase failed
   - Specific proof obligations that couldn't be closed
   - Error messages from lean_diagnostic_messages
3. **Alternative approaches** (in priority order):
   - Fall back to Int-specific construction from implementation-001.md
   - Weaken compositionality to cover most cases with sorry for edge cases
   - Define specialized canonical_task_rel for different sign cases
4. **Keep existing code**: Current CanonicalModel.lean and SemanticCanonicalModel.lean remain in place as reference
5. **Mark task status**: If blocked, update to [BLOCKED] with technical description in TODO.md
