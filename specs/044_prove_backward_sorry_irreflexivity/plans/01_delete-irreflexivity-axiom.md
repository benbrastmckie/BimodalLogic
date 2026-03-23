# Implementation Plan: Task #44

- **Task**: 44 - Prove backward sorry and make irreflexivity derivable
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 43 (archiving StagedConstruction to Boneyard)
- **Research Inputs**: specs/044_prove_backward_sorry_irreflexivity/reports/01_team-research.md
- **Artifacts**: plans/01_delete-irreflexivity-axiom.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The original task scope (prove backward sorry, derive irreflexivity) is mathematically impossible under reflexive semantics. Team research conclusively determined:

1. **Backward sorry is unprovable**: `ExistsTask M N -> exists n >= 1, CanonicalTask M n N` requires constructing a Succ-chain reaching N specifically, but the witness construction only produces SOME successor, not N
2. **Phase 7 is impossible**: Under reflexive semantics (Task 29), `ExistsTask M M` is provably TRUE via T-axiom. The `existsTask_irreflexive_axiom` directly contradicts this proven theorem
3. **Layer 2 dependents are already in Boneyard**: CantorApplication.lean, DovetailedTimelineQuot.lean, DiscreteTimeline.lean are already archived

The revised plan deletes the inconsistent axiom and its deprecated dependents from the active codebase, completing the semantic cleanup from Task 29.

### Research Integration

Key findings from `01_team-research.md`:
- Both teammates independently concluded original scope is impossible (high confidence)
- The axiom introduces inconsistency with `existsTask_reflexive`
- Per-construction strictness pattern (`strict_of_formula_in_g_content_not_in_source`) remains for local proofs
- Deletion reduces axiom count by 1 (aligns with Task 42 goal)

## Goals & Non-Goals

**Goals**:
- Delete `existsTask_irreflexive_axiom` from CanonicalIrreflexivity.lean
- Delete all `@[deprecated]` theorems that depend on the axiom
- Verify codebase builds without the axiom
- Document the resolution in task summary

**Non-Goals**:
- Prove the backward sorry (mathematically impossible)
- Derive universal irreflexivity (contradicts reflexive semantics)
- Modify Layer 2 dependents in Boneyard (already archived, out of scope)
- Remove `strict_of_formula_in_g_content_not_in_source` (still useful for per-construction proofs)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Active code depends on axiom | High | Low | Grep search before deletion; research shows no active dependents |
| Build breaks after deletion | Medium | Low | Incremental deletion with build verification |
| Loss of useful infrastructure | Low | Very Low | Preserve per-construction strictness pattern |

## Implementation Phases

### Phase 1: Dependency Audit [NOT STARTED]

**Goal**: Confirm no active code depends on the axiom or deprecated theorems

**Tasks**:
- [ ] Grep for `existsTask_irreflexive_axiom` usage outside CanonicalIrreflexivity.lean
- [ ] Grep for `existsTask_irreflexive` usage (the deprecated theorem)
- [ ] Grep for `canonicalTask_irreflexive` (pos/neg/general variants)
- [ ] Verify all usages are in Boneyard or deprecated sections
- [ ] Document any unexpected dependencies

**Timing**: 15 minutes

**Files to inspect**:
- `Theories/Bimodal/Metalogic/**/*.lean` - active metalogic code
- `Theories/Bimodal/**/*.lean` - broader theory code

**Verification**:
- Grep results show no imports/usages in active (non-Boneyard) code
- Any found dependencies are documented for handling

---

### Phase 2: Delete Axiom and Deprecated Theorems [NOT STARTED]

**Goal**: Remove the inconsistent axiom and all theorems derived from it

**Tasks**:
- [ ] Delete `existsTask_irreflexive_axiom` (lines ~281-282)
- [ ] Delete `canonicalR_irreflexive_axiom` alias (line ~285)
- [ ] Delete `existsTask_irreflexive` deprecated theorem (lines ~287-290)
- [ ] Delete `canonicalR_irreflexive` alias (lines ~292-293)
- [ ] Delete `#check` statements for deprecated items (lines ~295-296)
- [ ] Delete `canonicalTask_irreflexive_pos` (lines ~452-467)
- [ ] Delete `canonicalTask_irreflexive_neg` (lines ~476-486)
- [ ] Delete `canonicalTask_irreflexive` general (lines ~496-503)
- [ ] Update module docstring to remove Layer 2 references

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - delete ~80 lines

**Verification**:
- No axiom keyword remains in file
- No deprecated annotations related to irreflexivity remain
- Module docstring reflects reflexive-only semantics

---

### Phase 3: Build Verification [NOT STARTED]

**Goal**: Verify the codebase builds cleanly without the axiom

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Fix any compilation errors (if any)
- [ ] Verify no warnings about missing axiom
- [ ] Check that Boneyard files still compile (they import CanonicalIrreflexivity)

**Timing**: 30 minutes

**Files to verify**:
- Full project build
- `Boneyard/Metalogic/StagedConstruction/*.lean` - should still compile (may have errors but that's expected in Boneyard)

**Verification**:
- `lake build` succeeds without errors in active code
- Axiom count reduced (verify with `grep -r "^axiom" Theories/`)

---

### Phase 4: Documentation Update [NOT STARTED]

**Goal**: Update module documentation to reflect the semantic resolution

**Tasks**:
- [ ] Update CanonicalIrreflexivity.lean header docstring
- [ ] Remove Two-Layer Architecture section (now only reflexive layer)
- [ ] Update title to reflect current purpose (reflexive semantics infrastructure)
- [ ] Ensure per-construction strictness documentation remains

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - update docstring

**Verification**:
- Module docstring accurately describes reflexive-only semantics
- No references to "Layer 2" or deprecated axiom approach

---

### Phase 5: Summary and Closure [NOT STARTED]

**Goal**: Create implementation summary and verify task completion

**Tasks**:
- [ ] Create summary document with deletion details
- [ ] Document why original scope was impossible
- [ ] Note axiom count reduction
- [ ] Final build verification

**Timing**: 30 minutes

**Artifacts**:
- `specs/044_prove_backward_sorry_irreflexivity/summaries/01_implementation-summary.md`

**Verification**:
- Summary explains mathematical impossibility
- Axiom deletion documented
- Build passes

## Testing & Validation

- [ ] `lake build` succeeds on full project
- [ ] No active code references deleted axiom
- [ ] Per-construction strictness infrastructure preserved
- [ ] Module docstring reflects current semantic framework

## Artifacts & Outputs

- `plans/01_delete-irreflexivity-axiom.md` (this file)
- `summaries/01_implementation-summary.md` (after implementation)
- Modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

## Rollback/Contingency

If deletion breaks unexpected code:
1. Git revert to pre-deletion state
2. Add discovered dependencies to audit
3. Update plan to handle dependencies
4. Re-execute with dependency handling

If Boneyard code breaks:
- This is expected and acceptable
- Boneyard code is not on publication path
- Task 43 is archiving StagedConstruction anyway
