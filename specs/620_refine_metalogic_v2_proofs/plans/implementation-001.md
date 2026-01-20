# Implementation Plan: Task #620

- **Task**: 620 - refine_metalogic_v2_proofs
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/620_refine_metalogic_v2_proofs/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan systematically refines the Metalogic_v2 proofs across 5 phases, progressing from low-risk cleanup to structural improvements. The approach prioritizes maintaining a passing build after each phase. The target is a 20% reduction in total proof lines (~6000 to ~5000) while improving documentation quality for publication readiness.

### Research Integration

The research report (research-001.md) identified:
- 3 remaining sorry statements (non-blocking, skip per ROAD_MAP.md)
- Duplicate definitions (contextToSet, contextToSetLocal)
- ~20 #check statement clutter
- Verbose proof patterns in SoundnessLemmas.lean and Closure.lean
- Inconsistent naming conventions (mcs_* vs MCS_*)

## Goals & Non-Goals

**Goals**:
- Remove all #check statement clutter from module files
- Consolidate duplicate definitions (contextToSet variants)
- Improve module documentation headers with cross-references
- Clean up stray comments and elevate KNOWN ISSUE comments
- Optimize verbose proof patterns where straightforward
- Achieve publication-quality code presentation

**Non-Goals**:
- Resolving the 3 remaining sorry statements (non-blocking per ROAD_MAP.md)
- Creating new Util/ extraction layer (lower priority per research)
- Major architectural refactoring (Phase 4+ work per ROAD_MAP.md)
- Adding set-based compactness theorems

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build breakage from removing definitions | High | Medium | Run `lake build` after each file change |
| Removing actually-used code | High | Low | Use lean_local_search to verify usage before removal |
| Documentation changes introducing errors | Medium | Low | Verify syntax with lake build |
| Underestimating interdependencies | Medium | Medium | Work file-by-file, verify build after each |

## Implementation Phases

### Phase 1: Remove #check Statement Clutter [NOT STARTED]

**Goal**: Eliminate all #check statements used for documentation/re-exports that add line noise

**Tasks**:
- [ ] Audit FMP.lean for #check statements and remove
- [ ] Audit all hub/umbrella modules (Decidability.lean) for #check usage
- [ ] Verify no #check statements remain in production code
- [ ] Update module doc comments if #check served as documentation

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/FMP.lean` - Remove #check re-exports
- `Theories/Bimodal/Metalogic_v2/Decidability.lean` - Check for #check statements

**Verification**:
- `lake build` succeeds
- No #check statements in module files (test files may keep them)
- Grep confirms: `grep -r "#check" Theories/Bimodal/Metalogic_v2/` returns empty

---

### Phase 2: Consolidate Duplicate Definitions [NOT STARTED]

**Goal**: Merge duplicate contextToSet definitions and audit for other duplicates

**Tasks**:
- [ ] Verify contextToSetLocal in RepresentationTheorem.lean duplicates contextToSet in MaximalConsistent.lean
- [ ] Determine which definition is more widely used
- [ ] Update imports to use single canonical definition
- [ ] Remove the duplicate definition
- [ ] Audit Basic.lean for unused definitions (MaximalConsistent for lists, FinitelyConsistent)
- [ ] Audit Provability.lean for SetDerivable marked "being eliminated per Task 502"
- [ ] Remove confirmed unused definitions

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - contextToSet canonical location
- `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` - Remove contextToSetLocal
- `Theories/Bimodal/Metalogic_v2/Core/Basic.lean` - Remove unused definitions
- `Theories/Bimodal/Metalogic_v2/Core/Provability.lean` - Remove deprecated SetDerivable if unused

**Verification**:
- `lake build` succeeds
- lean_local_search confirms removed definitions not referenced elsewhere
- No duplicate definitions remain

---

### Phase 3: Clean Up Comments and Documentation [NOT STARTED]

**Goal**: Improve documentation quality by cleaning stray comments, elevating KNOWN ISSUE comments, and adding cross-references

**Tasks**:
- [ ] Search for KNOWN ISSUE comments and convert to proper doc comments
- [ ] Remove obsolete or misleading inline comments
- [ ] Update module header comments with accurate "Main Results" sections
- [ ] Add cross-references between related modules (e.g., TruthLemma <-> CanonicalModel)
- [ ] Ensure each file header accurately describes its contents
- [ ] Remove any TODO comments that are no longer relevant

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Core/*.lean` - Update headers and clean comments
- `Theories/Bimodal/Metalogic_v2/Soundness/*.lean` - Update headers
- `Theories/Bimodal/Metalogic_v2/Representation/*.lean` - Update headers, add cross-refs
- `Theories/Bimodal/Metalogic_v2/Completeness/*.lean` - Update headers
- `Theories/Bimodal/Metalogic_v2/Applications/Compactness.lean` - Document triviality

**Verification**:
- `lake build` succeeds
- Each module header accurately lists main theorems
- No stray KNOWN ISSUE comments outside doc blocks
- Cross-references present where modules are interdependent

---

### Phase 4: Optimize SoundnessLemmas.lean [NOT STARTED]

**Goal**: Reduce duplication in axiom validity proofs through pattern extraction

**Tasks**:
- [ ] Analyze axiom_*_valid and swap_axiom_*_valid proof patterns
- [ ] Identify common proof structure across 15+ axiom proofs
- [ ] Create local helper lemmas or tactics to factor out repetition
- [ ] Refactor proofs to use shared helpers
- [ ] Verify all axiom validity lemmas still typecheck
- [ ] Measure line count reduction (target: 15-20% reduction in SoundnessLemmas.lean)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Soundness/SoundnessLemmas.lean` - Main refactoring target

**Verification**:
- `lake build` succeeds
- All axiom_*_valid lemmas still exist with same type signatures
- Line count reduced from ~582 to ~480 or better
- Test files still pass

---

### Phase 5: Improve Closure.lean Structure [NOT STARTED]

**Goal**: Add section organization and reduce verbose proof patterns in the largest file

**Tasks**:
- [ ] Add section headers to group related theorems (closureWithNeg properties, membership lemmas, etc.)
- [ ] Identify closure_imp_left, closure_imp_right, etc. patterns
- [ ] Factor out common pattern into helper if feasible
- [ ] Clean up any remaining verbose patterns
- [ ] Ensure double-negation escape issue is well-documented
- [ ] Verify file organization improves readability

**Timing**: 1.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean` - Add sections, optimize proofs

**Verification**:
- `lake build` succeeds
- File has clear section structure with headers
- Line count reduced from ~796 to ~700 or better
- Double-negation issue documented in header

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] All existing test files pass: `lake test`
- [ ] Grep verification: no #check in Theories/Bimodal/Metalogic_v2/
- [ ] Total line count reduced by ~20% (from ~6000 to ~5000)
- [ ] No new sorry statements introduced
- [ ] Module documentation accurately reflects contents

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (upon completion)
- Refined Lean files in `Theories/Bimodal/Metalogic_v2/`

## Rollback/Contingency

If any phase causes persistent build failures:
1. `git stash` current changes
2. Investigate which change caused failure
3. Use `git diff` to isolate problematic edit
4. Revert specific problematic changes
5. Document the issue if it reveals deeper interdependency
6. Proceed with remaining phases, marking blocked phase as [BLOCKED]
