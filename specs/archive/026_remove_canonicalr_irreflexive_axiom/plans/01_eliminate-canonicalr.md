# Implementation Plan: Eliminate CanonicalR as Primary Concept

- **Task**: 26 - remove_canonicalr_irreflexive_axiom
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (immediate phases have no blockers)
- **Research Inputs**: specs/026_remove_canonicalr_irreflexive_axiom/reports/18_team-research.md
- **Artifacts**: plans/01_eliminate-canonicalr.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Refactor the canonical construction to establish `CanonicalTask M n N` as the central relation, relegating `CanonicalR` to a derived concept. The research confirms that CanonicalTask fully supports negative durations via the proven converse theorem, directly instantiates `TaskFrame Int`, and is the native TaskFrame concept. CanonicalR originates from Kripke semantics and causes architectural distraction by losing duration magnitude.

The implementation follows a staged approach: immediate items (no blockers), medium-term items (simple refactoring), and long-term items (requires proving the backward sorry).

### Research Integration

Key findings from wave 6 research:
- CanonicalTask converse theorem is fully proven (no sorry)
- CanonicalTask directly instantiates TaskFrame Int with all three axioms proven
- CanonicalR is `exists n > 0, CanonicalTask M n N` - an existential projection
- The irreflexivity axiom reformulates cleanly without the backward sorry
- The backward sorry in CanonicalRecovery.lean is the critical blocker for full equivalence

## Goals & Non-Goals

**Goals**:
- Establish CanonicalTask as the primary canonical relation in documentation and code
- Derive canonicalTask_irreflexive from existing canonicalR_irreflexive_axiom
- Rename CanonicalR to ExistsTask to clarify its derived nature
- Eliminate CanonicalR_past as a named concept
- Reformulate parametric_canonical_task_rel for D=Int to use CanonicalTask directly
- Prove the backward sorry (CanonicalR implies CanonicalTask) if feasible

**Non-Goals**:
- Remove the irreflexivity axiom entirely (confirmed needed by research)
- Change the mathematical content of the canonical construction
- Modify CanonicalTask definition or proven theorems

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Backward sorry proof is hard | H | H | Phase 6 is optional; main refactoring works without it |
| CanonicalR rename causes import cascades | M | M | Use Lean deprecation mechanism, phase incrementally |
| parametric_canonical_task_rel change breaks truth lemma | M | L | Verify all 85 files before merge |
| StagedPoint.le migration breaks preorder proofs | M | M | Add adapter lemmas before changing definition |

## Implementation Phases

### Phase 1: Add Derived Irreflexivity Theorem [NOT STARTED]

**Goal**: Derive canonicalTask_irreflexive from existing axiom using forward recovery direction.

**Tasks**:
- [ ] Add theorem in CanonicalIrreflexivity.lean:
  ```lean
  theorem canonicalTask_irreflexive (M : Set Formula) (n : Int)
      (h_mcs : SetMaximalConsistent M) (h_pos : 0 < n) :
      ¬CanonicalTask M n M := fun h_task =>
    canonicalR_irreflexive M h_mcs (canonicalTask_pos_implies_canonicalR h_task)
  ```
- [ ] Add symmetric version for negative n using converse theorem
- [ ] Verify with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Add theorem

**Verification**:
- Build succeeds with no new sorries
- Theorem type-checks against existing canonicalR_irreflexive_axiom

---

### Phase 2: Document CanonicalR as Derived Concept [NOT STARTED]

**Goal**: Add docstrings clarifying CanonicalR is the existential projection ExistsTask.

**Tasks**:
- [ ] Add docstring to CanonicalR definition in CanonicalFrame.lean:63
  ```lean
  /-- CanonicalR is the existential projection of CanonicalTask over positive durations:
      CanonicalR M N ↔ ∃ n > 0, CanonicalTask M n N

      This is the standard Kripke accessibility relation for tense modal logic.
      For TaskFrame semantics, use CanonicalTask directly.

      Alias: ExistsTask (preferred for new code) -/
  ```
- [ ] Add docstring to CanonicalR_past in CanonicalFrame.lean:71
  ```lean
  /-- CanonicalR_past is subsumed by negative durations in CanonicalTask:
      CanonicalR_past M N ↔ ∃ n > 0, CanonicalTask N n M
                         ↔ ∃ n < 0, CanonicalTask M n N

      Prefer: CanonicalTask with negative duration -/
  ```
- [ ] Add docstring to canonicalR_irreflexive_axiom explaining dual formulation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - Add docstrings

**Verification**:
- Documentation renders correctly in IDE hover

---

### Phase 3: Create ExistsTask Alias and Deprecation [NOT STARTED]

**Goal**: Add ExistsTask as preferred name, deprecate CanonicalR.

**Tasks**:
- [ ] Add ExistsTask definition in CanonicalFrame.lean:
  ```lean
  /-- ExistsTask M N means there exists a positive duration n such that CanonicalTask M n N.
      This is the preferred name for what was historically called CanonicalR. -/
  abbrev ExistsTask := CanonicalR
  ```
- [ ] Add deprecation attribute to CanonicalR:
  ```lean
  @[deprecated ExistsTask (since := "2026-03-21")]
  def CanonicalR ...
  ```
- [ ] Add ExistsTask_def theorem:
  ```lean
  theorem ExistsTask_def (M N : Set Formula) :
      ExistsTask M N ↔ ∃ n > 0, CanonicalTask M n N := by
    -- Uses forward direction of recovery (proven)
    constructor
    · sorry -- backward direction blocked by recovery sorry
    · intro ⟨n, hn_pos, h_task⟩
      exact canonicalTask_pos_implies_canonicalR h_task
  ```
- [ ] Verify build with deprecation warnings

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - Add ExistsTask

**Verification**:
- Build succeeds
- Deprecation warnings appear for CanonicalR usages (expected)

---

### Phase 4: Migrate Key Files to ExistsTask [NOT STARTED]

**Goal**: Update high-impact files to use ExistsTask, validating the refactoring approach.

**Tasks**:
- [ ] Identify pilot files from research usage map:
  - CanonicalIrreflexivity.lean (irreflexivity proofs)
  - CanonicalDomain.lean (NoMaxOrder/NoMinOrder)
  - CanonicalFrame.lean (internal uses)
- [ ] Replace CanonicalR with ExistsTask in pilot files
- [ ] Update local theorem names as appropriate
- [ ] Verify build after each file

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- `Theories/Bimodal/Metalogic/Domain/CanonicalDomain.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

**Verification**:
- Build succeeds with no regressions
- Pilot files use ExistsTask consistently

---

### Phase 5: Eliminate CanonicalR_past [NOT STARTED]

**Goal**: Remove CanonicalR_past as a named concept, using negative CanonicalTask durations.

**Tasks**:
- [ ] Add adapter theorem:
  ```lean
  theorem CanonicalR_past_eq_neg_CanonicalTask (M N : Set Formula) :
      CanonicalR_past M N ↔ ∃ n < 0, CanonicalTask M n N := by
    simp only [CanonicalR_past, CanonicalTask_converse]
    -- ... proof using converse theorem
  ```
- [ ] Grep for CanonicalR_past usages across codebase
- [ ] Replace each usage with negative CanonicalTask or explicit existential
- [ ] Deprecate CanonicalR_past definition
- [ ] Verify build

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - Deprecate
- Multiple files using CanonicalR_past (grep to identify)

**Verification**:
- Build succeeds
- No active usages of CanonicalR_past remain

---

### Phase 6: Reformulate parametric_canonical_task_rel [NOT STARTED]

**Goal**: Update the algebraic construction to use CanonicalTask directly for D=Int.

**Tasks**:
- [ ] Read current parametric_canonical_task_rel in ParametricCanonical.lean:85
- [ ] Design duration-preserving version:
  ```lean
  def parametric_canonical_task_rel_v2 (M N : SetOfFormulas) (d : Int) : Prop :=
    CanonicalTask M.val d N.val
  ```
- [ ] Verify this satisfies TaskFrame axioms
- [ ] Update dependent truth lemma proofs
- [ ] Add backward compatibility shim if needed

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean`
- Dependent files (truth lemma proofs)

**Verification**:
- Build succeeds
- Truth lemmas still hold
- Duration magnitude preserved in algebraic construction

---

### Phase 7: Prove Backward Sorry (Optional, High Effort) [NOT STARTED]

**Goal**: Prove `CanonicalR M N → ∃ n >= 1, CanonicalTask M n N` in CanonicalRecovery.lean.

**Tasks**:
- [ ] Analyze current sorry location and requirements
- [ ] Study Lindenbaum witness construction (canonical_forward_F)
- [ ] Verify witnesses satisfy G-persistence (CanonicalR condition)
- [ ] Prove witnesses satisfy F-step condition (CanonicalTask_forward requirement)
- [ ] Complete the backward direction proof
- [ ] Update ExistsTask_def to remove sorry

**Timing**: 4+ hours (exploratory)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - Remove sorry from ExistsTask_def

**Verification**:
- No sorries in recovery theorems
- Full equivalence between CanonicalR and ExistsTask proven

---

### Phase 8: Make Irreflexivity Axiom Derivable (Blocked by Phase 7) [NOT STARTED]

**Goal**: Once backward sorry is filled, make canonicalR_irreflexive derivable from canonicalTask_irreflexive.

**Tasks**:
- [ ] Add theorem deriving CanonicalR irreflexivity from CanonicalTask irreflexivity:
  ```lean
  theorem canonicalR_irreflexive_derived (M : Set Formula) (h : SetMaximalConsistent M) :
      ¬CanonicalR M M := fun h_R =>
    let ⟨n, hn_pos, h_task⟩ := canonicalR_implies_canonicalTask h_R
    canonicalTask_irreflexive M n h hn_pos h_task
  ```
- [ ] Document both formulations as equivalent
- [ ] Consider deprecating one axiom form in favor of the other

**Timing**: 1 hour (after Phase 7)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- Dual derivation complete
- Both axiom forms interderivable

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No new sorries introduced (except Phase 3 temporary sorry, removed in Phase 7)
- [ ] Deprecation warnings appear for legacy names
- [ ] IDE hover shows updated documentation
- [ ] Truth lemmas unaffected by parametric_canonical_task_rel changes
- [ ] All 69 files identified in research still build

## Artifacts & Outputs

- `plans/01_eliminate-canonicalr.md` (this file)
- Updated Lean files:
  - `CanonicalIrreflexivity.lean` - New derived theorem
  - `CanonicalFrame.lean` - ExistsTask alias, docstrings, deprecations
  - `CanonicalDomain.lean` - ExistsTask migration
  - `ParametricCanonical.lean` - Duration-preserving task relation
  - `CanonicalRecovery.lean` - Backward sorry proof (if Phase 7 completed)

## Rollback/Contingency

- Phases 1-5 are low-risk: simple additions and renames
- Phase 6 (parametric_canonical_task_rel) can be reverted by keeping original definition
- Phase 7 (backward sorry) is optional: if too hard, document as future work
- Phase 8 depends entirely on Phase 7: skip if Phase 7 incomplete

Each phase is independently committable, allowing partial completion if blockers emerge.
