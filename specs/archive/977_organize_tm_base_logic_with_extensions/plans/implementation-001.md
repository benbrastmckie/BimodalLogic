# Implementation Plan: Task #977 — Organize TM Base Logic with Extensions

- **Task**: 977 - Organize TM base logic with extensions
- **Status**: [NOT STARTED]
- **Effort**: 14-18 hours
- **Dependencies**: Tasks 973 (partial), 974 (researched) — blocking prerequisites
- **Research Inputs**: specs/977_organize_tm_base_logic_with_extensions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: true

## Overview

This plan addresses all identified gaps in the TM proof system organization, completeness, and documentation — BEFORE any structural refactoring. The research identified six gaps; this plan fills all gaps that are feasible within the current codebase structure, explicitly deferring the typeclass-based refactor to a follow-up task.

The key principle is **additive enhancement**: layer improvements on the existing sound foundation rather than disruptive refactoring.

### Research Integration

Integrated findings from research-001.md (4-teammate synthesis):
- 21 axiom constructors with correct `isBase`/`isDenseCompatible`/`isDiscreteCompatible` predicates
- Soundness is complete for all three variants (base, dense, discrete)
- Dense completeness: components proven but final theorem wiring missing (critical gap)
- Discrete completeness: framework largely absent
- Base completeness: implicit in BFMCS, needs explicit statement
- Documentation: outdated axiom counts (cites 14, actual is 21)

## Goals & Non-Goals

**Goals**:
- Fill all completeness gaps (base, dense, discrete statements)
- Wire the dense completeness theorem (components exist, assembly missing)
- Verify full derivation soundness (not just axiom validity)
- Update all documentation with correct axiom counts
- Add FrameClass enumeration for explicit classification
- Document theoretical justification for base/extension split

**Non-Goals (Explicitly Deferred to Follow-up Task)**:
- Typeclass-based parameterization for frame conditions
- Separate inductive types for each logic variant (type-level separation)
- Derivation validation predicates (DerivationTree_Base vs DerivationTree_Dense)
- Major directory restructuring

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Tasks 973/974 remain incomplete | High | Medium | Plan phases to be executable in parallel where possible; defer completeness wiring until prerequisites resolve |
| Dense completeness domain mismatch harder than expected | Medium | Medium | Allocate extra time in Phase 4; mark [BLOCKED] with review_reason if transfer map infeasible |
| Discrete completeness requires more infrastructure than available | Medium | High | Phase 6 explicitly scopes to "statement and framework skeleton" only |
| Full derivation soundness already exists but scattered | Low | Medium | Phase 2 searches comprehensively; if found, document location rather than duplicate |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `Canonical/ConstructiveFragment.lean` (NoMaxOrder/NoMinOrder) — task 973
- 4 sorries in `Domain/DiscreteTimeline.lean` (SuccOrder/PredOrder coverness) — task 974
- ~5 additional sorries in StagedConstruction files — various completeness gaps

### Expected Resolution
- This task does NOT directly resolve the 973/974 sorries — those are blocking prerequisites
- This task resolves completeness wiring sorries through Phase 4-6 work
- Phase 2 verifies derivation soundness is present (no new sorry introduction expected)

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- Tasks 973/974 sorries remain until those tasks complete
- Dense/discrete completeness theorems will be stated; full proof depends on 973/974 resolution
- Zero new sorries from this task

---

## Implementation Phases

### Phase 1: Documentation Audit and Update [NOT STARTED]

- **Dependencies:** None
- **Goal:** Update all documentation to reflect correct axiom counts and structure

**Tasks:**
- [ ] Audit `ProofSystem/Axioms.lean` header comments for axiom count — update if states "14"
- [ ] Audit `Theories/Bimodal/README.md` for axiom counts — update to 21
- [ ] Audit any other README.md files in Metalogic/ subdirectories
- [ ] Add inline documentation block in Axioms.lean explaining the three predicates (isBase, isDenseCompatible, isDiscreteCompatible) and their theoretical justification
- [ ] Verify all 21 constructors are documented with their frame correspondence

**Timing:** 1-2 hours

**Files to modify:**
- `Theories/Bimodal/ProofSystem/Axioms.lean` - header comments
- `Theories/Bimodal/README.md` - axiom count sections
- Any other READMEs with outdated counts

**Verification:**
- `grep -rn "14 axiom" Theories/Bimodal/` returns empty
- Each axiom constructor has frame correspondence documented

---

### Phase 2: Derivation Soundness Verification [NOT STARTED]

- **Dependencies:** None
- **Goal:** Verify full derivation soundness exists (or create if missing)

**Tasks:**
- [ ] Search for existing derivation soundness theorem covering modus ponens and necessitation
- [ ] If found: document location in Soundness.lean header
- [ ] If missing: state and prove `theorem derivation_sound : (⊢ φ) → valid φ` for base logic
- [ ] Verify dense and discrete derivation soundness follow from axiom validity + rules

**Timing:** 1-2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Soundness.lean` - add/document derivation theorem

**Verification:**
- Theorem `derivation_sound` (or equivalent) exists and is sorry-free
- `lake build` passes

---

### Phase 3: FrameClass Enumeration [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Add explicit FrameClass enumeration for type-safe classification

**Tasks:**
- [ ] Define `inductive FrameClass | Base | Dense | Discrete` in Axioms.lean
- [ ] Add `def Axiom.frameClass : Axiom → FrameClass` mapping each axiom to its class
- [ ] Add `def Axiom.minimalFrameClass` for the most general frame class where axiom is valid
- [ ] Verify consistency: `isBase a ↔ a.frameClass = .Base` etc.
- [ ] Add docstrings explaining the classification criteria

**Timing:** 1.5-2 hours

**Files to modify:**
- `Theories/Bimodal/ProofSystem/Axioms.lean` - add FrameClass type and functions

**Verification:**
- `lake build` passes
- Consistency lemmas proven or made definitionally true
- `grep -n "\bsorry\b" Axioms.lean` returns empty

---

### Phase 4: Dense Completeness Wiring [NOT STARTED]

- **Dependencies:** Phase 2 (soundness verified), Task 973 (blocking)
- **Goal:** Wire the existing dense completeness components into final theorem

**Tasks:**
- [ ] Identify the domain mismatch between Int-indexed BFMCS and TimelineQuot
- [ ] Construct transfer map or embedding between canonical construction domains
- [ ] State `theorem completeness_dense : valid_dense φ → ⊢_dense φ`
- [ ] Wire Truth Lemma, Shifted Truth Lemma, Cantor isomorphism into final proof
- [ ] If blocked by unsolvable domain mismatch: mark [BLOCKED] with detailed review_reason

**Timing:** 3-4 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` - wire final theorem
- Possibly new file `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - top-level export

**Verification:**
- `lake build` passes
- `theorem completeness_dense` exists and is sorry-free (or [BLOCKED] with reason)
- `grep -n "\bsorry\b" Completeness.lean` returns empty for new code

---

### Phase 5: Base Completeness Statement [NOT STARTED]

- **Dependencies:** Phase 4 (dense completeness provides template)
- **Goal:** State explicit base completeness theorem

**Tasks:**
- [ ] Identify where base completeness is implicit in BFMCS construction
- [ ] State `theorem completeness_base : valid φ → ⊢ φ` (for base axioms only)
- [ ] Wire from existing BFMCS construction if possible
- [ ] Document relationship between base and dense completeness (base is subsumed)

**Timing:** 2-3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/` or new `BaseCompleteness.lean`

**Verification:**
- `theorem completeness_base` exists
- `lake build` passes
- Documentation explains the completeness hierarchy

---

### Phase 6: Discrete Completeness Framework [NOT STARTED]

- **Dependencies:** Phase 5 (base completeness template), Task 974 (blocking for full proof)
- **Goal:** Establish discrete completeness skeleton and statement

**Tasks:**
- [ ] State `theorem completeness_discrete : valid_discrete φ → ⊢_discrete φ`
- [ ] Identify required infrastructure from DiscreteTimeline (task 974)
- [ ] Create skeleton proof structure with clearly marked sorry points awaiting 974
- [ ] Document what DiscreteTimeline components are needed for full proof
- [ ] If 974 blockers prevent even skeleton: mark [BLOCKED] with dependencies listed

**Timing:** 2-3 hours

**Files to modify:**
- New file `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean`

**Verification:**
- `theorem completeness_discrete` statement exists
- Required infrastructure documented
- Remaining sorries are ONLY those blocked by task 974

---

### Phase 7: Logic Variants Summary and Verification [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Create summary documentation and verify all completeness theorems

**Tasks:**
- [ ] Create `Theories/Bimodal/LogicVariants.lean` that exports all three completeness theorems
- [ ] Add summary docstrings explaining TM Base, TM Dense, TM Discrete
- [ ] Verify all three soundness/completeness pairs are stated:
  - Base: `axiom_base_valid` + `completeness_base`
  - Dense: `axiom_valid_dense` + `completeness_dense`
  - Discrete: `axiom_valid_discrete` + `completeness_discrete`
- [ ] Update main Bimodal README with logic variants summary section
- [ ] Run final `lake build` verification

**Timing:** 1.5-2 hours

**Files to modify:**
- New file `Theories/Bimodal/LogicVariants.lean`
- `Theories/Bimodal/README.md` - logic variants section

**Verification:**
- `lake build` passes
- All three logic variant pairs documented
- `grep -n "\bsorry\b" LogicVariants.lean` returns empty
- README contains accurate logic variants summary

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (for new code)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All new proofs verified with `lean_goal` showing "no goals"

### Specific Validations
- [ ] Documentation shows 21 axiom constructors consistently
- [ ] FrameClass enumeration covers all axioms
- [ ] Each completeness theorem is stated (even if proof blocked)
- [ ] Blocking dependencies on 973/974 are clearly documented in code comments

## Artifacts & Outputs

- `specs/977_organize_tm_base_logic_with_extensions/plans/implementation-001.md` (this file)
- `specs/977_organize_tm_base_logic_with_extensions/summaries/implementation-summary-YYYYMMDD.md`
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean`
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean`
- Modified: `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`
- New: `Theories/Bimodal/Metalogic/DenseCompleteness.lean` (optional top-level)
- New: `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean`
- New: `Theories/Bimodal/LogicVariants.lean`
- Modified: `Theories/Bimodal/README.md`

## Rollback/Contingency

- All phases add new content rather than modifying existing proofs
- Rollback: `git revert` per-phase commits
- If Phase 4 (dense completeness wiring) proves infeasible:
  - Document the domain mismatch precisely
  - Leave components in place with explicit TODO
  - Create follow-up task for alternative approach
- If Phase 6 (discrete completeness) blocked by 974:
  - Document skeleton with explicit `sorry` blocked by task 974
  - Follow-up when 974 completes

## Follow-up Task (Out of Scope)

The following enhancements are explicitly saved for a follow-up task after this plan completes:

**Typeclass-based frame condition modularity:**
- Separate derivation types per logic variant (DerivationTree_Base, etc.)
- Type-level safety for axiom usage
- Derivation validation predicates
- Typeclass parameterization for frame conditions

This refactor should only proceed AFTER all gaps identified in research-001.md are filled and the metalogic is complete.
