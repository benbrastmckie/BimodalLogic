# Implementation Plan: Task #540

- **Task**: 540 - Finish Metalogic Directory Refactor and Cleanup
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: Medium
- **Dependencies**: Task 523 (completed)
- **Research Inputs**: [research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The Metalogic directory has two parallel structures: a working completeness proof in `Completeness.lean` (3719 lines, proven), and a broken Representation/ module hierarchy (21+ compilation errors) intended to provide a cleaner architecture. The user wants to **fix the broken modules** to deliver on the ideal structure with the representation theorem as foundation and FMP as bridge.

The key insight from the research: `Completeness.lean` uses a Duration-based canonical model that **works**, while `Representation/CanonicalModel.lean` uses an older API that fails. The solution is to extract the working patterns from `Completeness.lean` into the Representation/ module hierarchy.

### Research Integration

Key findings integrated into this plan:
- `Representation/CanonicalModel.lean` has 21 errors from outdated Mathlib APIs (`.toList` on Set, wrong Zorn patterns)
- `Completeness.lean` has a working `CanonicalWorldState` and `SetMaximalConsistent` that can be reused
- The semantic approach in `FiniteCanonicalModel.lean` proves completeness without the FMP gap
- FMP exists for finite formulas via `SemanticCanonicalModel`

## Goals & Non-Goals

**Goals**:
- Fix `Representation/CanonicalModel.lean` to compile using patterns from working `Completeness.lean`
- Establish `RepresentationTheorem.lean` → `FiniteModelProperty.lean` → `CompletenessTheorem.lean` architecture
- Connect FMP to existing decidability machinery
- Update `Applications/Compactness.lean` to use working completeness
- Update README.md to accurately reflect the architecture

**Non-Goals**:
- Completely rewrite the completeness proof (it's already proven)
- Implement compactness from scratch (use existing completeness)
- Add new metalogical results beyond fixing the architecture

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| API incompatibilities run deeper than anticipated | H | M | Extract minimal interface from Completeness.lean |
| Zorn lemma patterns hard to fix | M | L | Copy working pattern from Completeness.lean line 354-409 |
| Import cycles between modules | M | L | Design imports carefully bottom-up |
| Time exceeds estimate | M | M | Phase 1-2 give 80% value; phases 3-4 are polish |

## Implementation Phases

### Phase 1: Fix CanonicalModel.lean Foundation [NOT STARTED]

**Goal**: Get `Representation/CanonicalModel.lean` to compile by adapting patterns from `Completeness.lean`

**Tasks**:
- [ ] Copy `SetMaximalConsistent`, `SetConsistent`, `ConsistentExtensions` definitions from `Completeness.lean` (lines 123-143)
- [ ] Replace `.toList` usage with proper Set-based consistency (use `Consistent : Context → Prop` adapter)
- [ ] Fix Lindenbaum's lemma using working `set_lindenbaum` pattern (Completeness.lean lines 354-409)
- [ ] Replace `.subformula_closure` with proper subformula function from Core/Basic or inline definition
- [ ] Fix `CanonicalFrame` and `CanonicalModel` structures to use `CanonicalWorldState` pattern
- [ ] Remove or fix the `past`/`future` constructor references (use `all_past`/`all_future`)
- [ ] Fix type mismatches with Formula vs Prop in membership tests

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - Major rewrite using working patterns

**Verification**:
- `lake build Bimodal.Metalogic.Representation.CanonicalModel` succeeds
- `lean_diagnostic_messages` shows no errors

---

### Phase 2: Establish TruthLemma and RepresentationTheorem [NOT STARTED]

**Goal**: Build out the representation theorem chain connecting maximal consistent sets to model truth

**Tasks**:
- [ ] Fix `TruthLemma.lean` imports to use fixed CanonicalModel
- [ ] Adapt truth lemma statement from `Completeness.lean` line 3539-3570 (`truth_lemma`)
- [ ] Implement or adapt the truth lemma proof (may need to reference `semantic_truth_lemma_v2` from FiniteCanonicalModel)
- [ ] Fix `RepresentationTheorem.lean` to export the key equivalence: membership in MCS ↔ truth in canonical model
- [ ] Ensure proper namespace and export structure for downstream use

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Representation/RepresentationTheorem.lean`

**Verification**:
- Both files compile without errors
- `RepresentationTheorem` exports usable theorem for completeness

---

### Phase 3: Connect FMP Bridge [NOT STARTED]

**Goal**: Establish FiniteModelProperty as the bridge from representation to decidability/compactness

**Tasks**:
- [ ] Fix `FiniteModelProperty.lean` imports
- [ ] Define FMP statement: for finite φ, non-provability implies finite countermodel
- [ ] Connect to existing `SemanticCanonicalModel` machinery from `FiniteCanonicalModel.lean`
- [ ] Link FMP to decidability (Decidability/ modules)
- [ ] Verify FMP → Decidability chain works

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/FiniteModelProperty.lean`

**Verification**:
- FMP statement compiles and connects to existing proofs
- Decidability imports work correctly

---

### Phase 4: Complete Applications Module [NOT STARTED]

**Goal**: Fix CompletenessTheorem.lean and Compactness.lean to use the new architecture

**Tasks**:
- [ ] Fix `Completeness/CompletenessTheorem.lean` imports to use Representation/
- [ ] Ensure it exports `weak_completeness` and `strong_completeness` theorems
- [ ] Fix `Applications/Compactness.lean` to use working completeness
- [ ] Implement or stub compactness theorem (if derivation uses only finitely many premises)
- [ ] Update parent module `Metalogic.lean` to export correct hierarchy

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/CompletenessTheorem.lean`
- `Theories/Bimodal/Metalogic/Applications/Compactness.lean`
- `Theories/Bimodal/Metalogic.lean`

**Verification**:
- All files compile
- `lake build Bimodal.Metalogic` succeeds

---

### Phase 5: Documentation Update [NOT STARTED]

**Goal**: Update README and documentation to accurately reflect the cleaned-up architecture

**Tasks**:
- [ ] Create or update `Metalogic/README.md` with accurate architecture diagram
- [ ] Document the representation theorem approach
- [ ] Remove references to non-existent `Metalogic/Boneyard/` (point to `Bimodal/Boneyard/`)
- [ ] Update module status table showing which modules are complete vs partial
- [ ] Add comments to key modules explaining the architecture

**Timing**: 0.5 hours (can run in parallel with verification)

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` (create if needed)
- Module-level docstrings

**Verification**:
- Documentation matches reality
- All paths mentioned exist

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic` completes without errors
- [ ] `lean_diagnostic_messages` shows no errors in any Metalogic file
- [ ] Import hierarchy is clean (no cycles)
- [ ] Key theorems exported: `provable_iff_valid`, `weak_completeness`, `strong_completeness`
- [ ] FMP connects to decidability machinery
- [ ] README accurately describes the architecture

## Artifacts & Outputs

- `specs/540_finish_metalogic_refactor_cleanup/plans/implementation-001.md` (this file)
- `specs/540_finish_metalogic_refactor_cleanup/summaries/implementation-summary-YYYYMMDD.md`
- Fixed Lean files in `Theories/Bimodal/Metalogic/Representation/`
- Fixed Lean files in `Theories/Bimodal/Metalogic/Completeness/`
- Fixed Lean files in `Theories/Bimodal/Metalogic/Applications/`
- Updated `Theories/Bimodal/Metalogic/README.md`

## Rollback/Contingency

If the representation module approach proves too difficult to fix:

1. **Fallback Option A**: Delete broken Representation/ modules and rely solely on `Completeness.lean` + `FiniteCanonicalModel.lean` (the current working system)
2. **Fallback Option B**: Move broken modules to `Bimodal/Boneyard/` with deprecation notes and document why they didn't work
3. **Partial Success**: If Phase 1-2 succeed but 3-4 fail, declare partial victory - the canonical model foundation is established

Git revert: All changes will be in a single task branch, can revert to pre-task state if needed.

## Architecture Diagram (Target State)

```
Bimodal.ProofSystem + Bimodal.Semantics
         │
         ▼
  Core/Basic.lean (Consistent, Context utilities)
         │
         ▼
  Representation/CanonicalModel.lean
  (SetMaximalConsistent, CanonicalWorldState, Lindenbaum)
         │
         ├────────────────────┐
         ▼                    ▼
  Representation/         Representation/
  TruthLemma.lean        FiniteModelProperty.lean
         │                    │
         ▼                    ▼
  Representation/         Decidability/
  RepresentationTheorem      (Tableau, Decision)
         │                    │
         ├────────────────────┘
         ▼
  Completeness/CompletenessTheorem.lean
  (weak_completeness, strong_completeness, provable_iff_valid)
         │
         ▼
  Applications/Compactness.lean
```

The existing `Completeness.lean` (3719 lines) contains the proven completeness and can be gradually refactored to use this structure, or kept as the "monolithic proven version" with the Representation/ hierarchy as the "clean architecture version."
