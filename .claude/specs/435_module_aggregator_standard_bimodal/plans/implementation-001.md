# Implementation Plan: Task #435

- **Task**: 435 - Module Aggregator Standard for Bimodal/
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/435_module_aggregator_standard_bimodal/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Systematically improve all module aggregator files in the Bimodal/ theory to follow a consistent standard. The primary focus is fixing the critical gap in `Theorems.lean` which only exports 2 of 6 available theorem modules. Secondary focus is standardizing documentation across all 9 aggregator files using the pattern established in `Metalogic/Decidability.lean` as the gold standard.

### Research Integration

From research-001.md:
- **Critical Issue**: `Theorems.lean` missing 4 theorem module exports (Combinators, Propositional, ModalS5, ModalS4)
- **Best Practice Pattern**: `Metalogic/Decidability.lean` demonstrates ideal aggregator format with submodule descriptions, status section, and usage examples
- **Documentation Gaps**: `Syntax.lean`, `ProofSystem.lean`, `Semantics.lean` have minimal documentation compared to gold standard
- **Build Status**: Project builds successfully, no errors related to module structure

## Goals & Non-Goals

**Goals**:
- Fix critical functional gap in `Theorems.lean` by adding missing exports
- Standardize documentation format across all aggregator files
- Apply consistent structure: header, overview, submodules, status (if applicable), usage, references
- Ensure all aggregators follow the pattern from `Metalogic/Decidability.lean`

**Non-Goals**:
- Adding namespace blocks to aggregators (optional enhancement, not required)
- Adding `#check` examples beyond usage section
- Cross-pollinating with Logos/ aggregators (future task)
- Modifying non-aggregator files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build breakage from import changes | High | Low | Run `lake build` after each phase |
| Inconsistent documentation style | Medium | Medium | Use Decidability.lean as template |
| Missing submodule descriptions | Low | Low | Read each submodule header for accurate descriptions |

## Implementation Phases

### Phase 1: Fix Theorems.lean Critical Gap [NOT STARTED]

**Goal**: Add all 4 missing theorem module exports and update documentation

**Tasks**:
- [ ] Add import for `Bimodal.Theorems.Combinators`
- [ ] Add import for `Bimodal.Theorems.Propositional`
- [ ] Add import for `Bimodal.Theorems.ModalS5`
- [ ] Add import for `Bimodal.Theorems.ModalS4`
- [ ] Update documentation to describe all 6 submodules
- [ ] Verify build with `lake build Bimodal.Theorems`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Theorems.lean` - Add 4 imports, expand documentation

**Verification**:
- `lake build Bimodal.Theorems` succeeds
- All 6 theorem modules accessible via single import

---

### Phase 2: Standardize Syntax.lean and ProofSystem.lean [NOT STARTED]

**Goal**: Expand documentation in these two aggregators to match gold standard

**Tasks**:
- [ ] Read `Syntax/Formula.lean` and `Syntax/Context.lean` headers for accurate descriptions
- [ ] Update `Syntax.lean` with expanded submodule descriptions and status if applicable
- [ ] Read `ProofSystem/Axioms.lean` and `ProofSystem/Derivation.lean` headers
- [ ] Update `ProofSystem.lean` with expanded submodule descriptions and status
- [ ] Ensure both have consistent usage examples

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Syntax.lean` - Expand documentation
- `Theories/Bimodal/ProofSystem.lean` - Expand documentation

**Verification**:
- Documentation follows Decidability.lean pattern
- Build succeeds after changes

---

### Phase 3: Standardize Semantics.lean [NOT STARTED]

**Goal**: Expand Semantics.lean documentation to match gold standard

**Tasks**:
- [ ] Read headers of all 5 semantics submodules (TaskFrame, WorldHistory, TaskModel, Truth, Validity)
- [ ] Update `Semantics.lean` with detailed submodule descriptions
- [ ] Add Status section if there are implementation notes
- [ ] Ensure usage example is comprehensive

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Semantics.lean` - Expand documentation

**Verification**:
- Documentation follows Decidability.lean pattern
- Build succeeds after changes

---

### Phase 4: Review and Polish Metalogic.lean, Automation.lean, Examples.lean [NOT STARTED]

**Goal**: Ensure these already-good aggregators have fully consistent formatting

**Tasks**:
- [ ] Review `Metalogic.lean` - add any missing elements from gold standard
- [ ] Review `Automation.lean` - verify tactic selection guide is complete
- [ ] Review `Examples.lean` - verify learning path is complete
- [ ] Ensure consistent header format across all three

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - Minor polish if needed
- `Theories/Bimodal/Automation.lean` - Minor polish if needed
- `Theories/Bimodal/Examples.lean` - Minor polish if needed

**Verification**:
- All three files have consistent documentation style
- Build succeeds

---

### Phase 5: Update Root Bimodal.lean and Final Verification [NOT STARTED]

**Goal**: Update root aggregator's Theorems description and verify all changes

**Tasks**:
- [ ] Update `Bimodal.lean` Theorems description to reflect all 6 theorem modules
- [ ] Run full `lake build` to verify no regressions
- [ ] Verify `import Bimodal` provides access to all submodules
- [ ] Check for any linter warnings introduced

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Bimodal.lean` - Update Theorems description

**Verification**:
- `lake build` succeeds with no new errors
- All aggregator documentation follows consistent standard
- Theorems.lean exports all 6 modules

---

## Testing & Validation

- [ ] `lake build Bimodal` completes successfully
- [ ] `import Bimodal.Theorems` provides access to Combinators, Propositional, ModalS5, ModalS4, Perpetuity, GeneralizedNecessitation
- [ ] All aggregator files follow consistent documentation pattern
- [ ] No new linter warnings introduced

## Artifacts & Outputs

- Updated `Theories/Bimodal/Theorems.lean` with 6 module exports
- Updated `Theories/Bimodal/Syntax.lean` with expanded documentation
- Updated `Theories/Bimodal/ProofSystem.lean` with expanded documentation
- Updated `Theories/Bimodal/Semantics.lean` with expanded documentation
- Polished `Theories/Bimodal/Metalogic.lean`, `Automation.lean`, `Examples.lean`
- Updated `Theories/Bimodal/Bimodal.lean` root aggregator

## Rollback/Contingency

All changes are documentation and import additions. Rollback via:
```bash
git checkout HEAD -- Theories/Bimodal/
```

No breaking changes expected since we are only adding imports and expanding documentation.
