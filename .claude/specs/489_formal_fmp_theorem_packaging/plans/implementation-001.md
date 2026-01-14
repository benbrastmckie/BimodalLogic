# Implementation Plan: Formal FMP Theorem Packaging

- **Task**: 489 - formal_fmp_theorem_packaging
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: Task 488 (fill remaining bridge lemmas) - recommended but not blocking
- **Research Inputs**: [research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Package the existing `semantic_weak_completeness` proof into the standard Finite Model Property format: `satisfiable phi -> exists (M : FiniteModel), M models phi`. The core completeness infrastructure is already proven in FiniteCanonicalModel.lean. This task creates explicit `FiniteTaskFrame`/`FiniteTaskModel` structures bundling the finiteness constraint, defines single-formula satisfiability, states the formal FMP theorem, proves model bounds, and adds comprehensive documentation.

### Research Integration

Research report (research-001.md) identified:
- Existing `semantic_weak_completeness` proves the core result
- `SemanticWorldState phi` has `Finite` instance already
- Current `finite_model_property` theorem at line 3834 is trivial (identity)
- Standard FMP format requires bundled `FiniteTaskFrame` structure
- Model bounds: `2^|closure phi|` world states, `temporalDepth phi` time range

## Goals & Non-Goals

**Goals**:
- Define `FiniteTaskFrame` and `FiniteTaskModel` structures bundling finiteness
- Define `formula_satisfiable` for single formulas (current `satisfiable` is for contexts)
- State formal FMP theorem in standard format
- Prove model bound theorems (state count, temporal domain)
- Add docstrings explaining FMP significance, bounds computation, and connection to decidability

**Non-Goals**:
- Proving new completeness results (already done)
- Optimizing model construction efficiency (Task 470)
- Implementing decision procedures (Task 469/490)
- Removing or changing existing sorries (Task 488)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FiniteTaskFrame structure incompatible with existing code | Low | Low | Use `extends TaskFrame` for seamless coercion |
| Bridge lemmas (Task 488) incomplete causes issues | Medium | Medium | FMP statement is independent; internal sorries localized |
| Int time type complicates bound proofs | Low | Medium | Document that finite subrange suffices; use FiniteTime |
| Satisfiability definition mismatch | Medium | Low | Define formula_satisfiable to match existing semantics |

## Implementation Phases

### Phase 1: Define FiniteTaskFrame and FiniteTaskModel [NOT STARTED]

**Goal**: Create explicit structures bundling the `Finite` constraint on world states.

**Tasks**:
- [ ] Define `FiniteTaskFrame D` structure extending `TaskFrame D` with `finite_world : Finite WorldState` field
- [ ] Define `FiniteTaskModel` as abbreviation or structure over `FiniteTaskFrame`
- [ ] Add coercion from `FiniteTaskFrame` to `TaskFrame`
- [ ] Add docstrings explaining the purpose and usage
- [ ] Verify `SemanticCanonicalFrame phi` can instantiate `FiniteTaskFrame`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Semantics/TaskFrame.lean` - Add FiniteTaskFrame definition
- `Theories/Bimodal/Semantics/TaskModel.lean` - Add FiniteTaskModel definition (or same file)

**Verification**:
- `lake build` succeeds
- `#check FiniteTaskFrame` works
- Coercion to TaskFrame is automatic

---

### Phase 2: Define Formula Satisfiability [NOT STARTED]

**Goal**: Add single-formula satisfiability definition to complement context-based `satisfiable`.

**Tasks**:
- [ ] Define `formula_satisfiable (phi : Formula) : Prop` in Validity.lean
- [ ] Prove equivalence: `formula_satisfiable phi <-> satisfiable Int [phi]`
- [ ] Add docstring explaining relationship to context satisfiability

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Semantics/Validity.lean` - Add formula_satisfiable definition

**Verification**:
- Definition compiles without errors
- Equivalence lemma proves or is stated as `sorry` for later

---

### Phase 3: State Formal FMP Theorem [NOT STARTED]

**Goal**: Replace trivial `finite_model_property` with proper FMP statement.

**Tasks**:
- [ ] Deprecate or remove trivial `finite_model_property` at line 3834
- [ ] State `finite_model_property_v2` in standard format:
  ```lean
  theorem finite_model_property_v2 (phi : Formula) :
      formula_satisfiable phi ->
      exists (F : FiniteTaskFrame Int) (M : TaskModel F.toTaskFrame)
        (tau : WorldHistory F.toTaskFrame) (t : Int),
        truth_at M tau t phi
  ```
- [ ] Prove using contrapositive connection to `semantic_weak_completeness`
- [ ] Add comprehensive docstring explaining FMP significance

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Main FMP theorem

**Verification**:
- Theorem compiles (may have sorry for proof body)
- Type signature matches standard FMP format

---

### Phase 4: Prove Model Bounds [NOT STARTED]

**Goal**: Document and prove explicit bounds on the finite model size.

**Tasks**:
- [ ] State `finite_model_state_bound`:
  ```lean
  theorem finite_model_state_bound (phi : Formula) :
      Nat.card (SemanticWorldState phi) <= 2 ^ (closure phi).card
  ```
- [ ] State `finite_model_time_bound`:
  ```lean
  theorem finite_model_time_bound (phi : Formula) :
      -- Model requires only times in [-temporalDepth phi, temporalDepth phi]
  ```
- [ ] Prove bounds or leave as sorry with clear proof sketch in docstring
- [ ] Add complexity analysis in docstrings

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Bound theorems

**Verification**:
- Theorem statements compile
- Bounds are correctly stated per research findings

---

### Phase 5: Add Documentation and Cleanup [NOT STARTED]

**Goal**: Comprehensive documentation for FMP infrastructure.

**Tasks**:
- [ ] Add module-level docstring section explaining FMP for TM logic
- [ ] Document connection to decidability (FMP + finite time = decidable)
- [ ] Document relationship between SemanticCanonicalModel and standard FMP format
- [ ] Add cross-references to related definitions (FiniteTaskFrame, formula_satisfiable)
- [ ] Verify no new warnings from documentation

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Documentation

**Verification**:
- `lake build` succeeds with no new warnings
- Documentation renders correctly in hover info

---

## Testing & Validation

- [ ] `lake build` succeeds for all modified files
- [ ] `#check FiniteTaskFrame` returns expected type
- [ ] `#check FiniteTaskModel` returns expected type
- [ ] `#check formula_satisfiable` returns expected type
- [ ] `#check finite_model_property_v2` shows correct theorem signature
- [ ] `#check finite_model_state_bound` shows correct theorem signature
- [ ] Hover info displays documentation correctly

## Artifacts & Outputs

- `Theories/Bimodal/Semantics/TaskFrame.lean` - FiniteTaskFrame definition
- `Theories/Bimodal/Semantics/Validity.lean` - formula_satisfiable definition
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - FMP theorem and bounds
- `.claude/specs/489_formal_fmp_theorem_packaging/plans/implementation-001.md` (this file)
- `.claude/specs/489_formal_fmp_theorem_packaging/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If implementation causes build failures:
1. Revert changes to individual files via git
2. Keep FiniteTaskFrame in separate file if incompatibility arises
3. Use type alias instead of structure if coercion issues occur
4. Document limitations and defer to Task 490 (decidability procedure) for full integration
