# Implementation Plan: Archive Dead Sorry Stubs from TemporalDerived.lean

- **Task**: 173 - Archive 19 dead sorry stubs from TemporalDerived.lean
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_sorry-stub-audit.md
- **Artifacts**: plans/01_sorry-stub-archive.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove 27 sorry-tainted definitions (19 direct sorry stubs + 8 transitive dependents) from TemporalDerived.lean and archive 5 definitions with educational value to a new Boneyard directory. The remaining 22 definitions are pure 1-line sorry stubs with no proof content (many already have closed-guard originals archived in ClosedGuardLegacy). Six downstream call sites in active modules (UltrafilterFrame, UntilSinceCoherence, SuccRelation) must be updated with tombstone comments and direct sorry replacements. Net active sorry count reduction: 19.

### Research Integration

The research report (01_sorry-stub-audit.md) provides a complete inventory of all 41 definitions in TemporalDerived.lean, categorized as: 14 sorry-free (KEEP), 14 open-guard-invalid sorry stubs (DELETE), 5 pre-existing sorry stubs (3 DELETE, 2 ARCHIVE), and 8 transitive sorry dependents (DELETE). It also identifies the exact 6 downstream call sites requiring tombstone updates and confirms the existing Boneyard precedent in ClosedGuardLegacy/ClosedGuardTemporalDerived.lean.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

The ROADMAP.md notes ~17 sorries in the BXCanonical/Bundle/Quasimodel/Filtration pipeline as "mathematically false under irreflexive semantics" and states they "should be archived." This task directly addresses the TemporalDerived.lean component of that dead-code sorry population. The Bundle/ downstream call sites (UntilSinceCoherence, SuccRelation) are part of this dead pipeline -- the tombstone replacements preserve compilation while marking the sorry provenance.

## Goals & Non-Goals

**Goals**:
- Remove all 27 sorry-tainted definitions from TemporalDerived.lean
- Archive 5 definitions with proof content or downstream users to Boneyard
- Update 6 downstream call sites with tombstone comments and direct sorry
- Reduce active sorry count by 19
- Maintain `lake build` success throughout

**Non-Goals**:
- Proving any of the sorry obligations (these are known to be invalid or blocked)
- Refactoring the downstream modules (UntilSinceCoherence, SuccRelation, UltrafilterFrame)
- Archiving the downstream sorry-bearing code paths (separate task scope)
- Modifying the 24 sorry-free definitions that remain in TemporalDerived.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Undiscovered downstream references not found by grep | H | L | Run full `grep -rn` for each deleted definition name before removal; `lake build` as gate |
| Build failure from import changes | M | L | Phase 2 updates downstream before Phase 3 removes definitions; incremental build checks |
| Boneyard file import contamination | M | L | Boneyard files use no `import` statements; they are documentation-only code fences (following ClosedGuardLegacy precedent) |
| Missing definition in research inventory | M | L | Research report was systematic (line-by-line); Phase 3 will re-verify against current file |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are fully sequential because downstream updates (Phase 2) must precede definition removal (Phase 3), and build verification (Phase 4) must follow all code changes.

---

### Phase 1: Create Boneyard Archive [COMPLETED]

**Goal**: Create the Boneyard archive file containing the 5 ARCHIVE definitions with their proof bodies and documentation header for all 27 removed definitions.

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Boneyard/OpenGuardInvalid/`
- [ ] Create `OpenGuardTemporalDerived.lean` with module docstring documenting:
  - Why definitions were archived (BX8/BX9 removal, reflexive order invalidity, seriality requirement)
  - Cross-reference to ClosedGuardLegacy for original proofs
  - Cross-reference to task 173
  - Date of archival (2026-05-20)
- [ ] Include the 5 ARCHIVE definitions with their full proof bodies in code-fence comments:
  - `G_bot_absurd` (sorry stub, but has active downstream users; note seriality requirement)
  - `H_bot_absurd` (sorry stub, mirror of above)
  - `until_F_expansion` (25-line proof body, demonstrates until-unfolding + F-wrapping technique)
  - `since_P_expansion` (23-line proof body, mirror of above)
  - `past_density_derivable` (1-line sorry, archived for consistency with density_derivable)
- [ ] Include documentation-only listing of all 22 DELETE definitions (type signatures in code fences, no bodies needed since they are pure sorry stubs)
- [ ] Verify file is well-formed (no `import` statements, code in fenced blocks only)

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean` - NEW: archive file

**Verification**:
- File exists at expected path
- Contains all 5 ARCHIVE definitions with proof bodies
- Contains documentation listing of all 22 DELETE definitions
- Has no `import` statements

---

### Phase 2: Update Downstream Call Sites [COMPLETED]

**Goal**: Replace 6 downstream references to sorry-tainted definitions with direct `sorry` and tombstone comments, preserving compilation.

**Tasks**:
- [x] Update `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` *(deviation: skipped -- file already archived to Boneyard/UltrafilterFrame/ before task 173; references only in Boneyard)*
- [x] Update `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean`:
  - Line 84: Replace `psi_imp_until` reference with tombstone comment + `sorry`
  - Line 94: Replace `psi_imp_since` reference with tombstone comment + `sorry`
- [x] Update `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`:
  - Line 553: Replace `until_unfold_wrapped` reference with tombstone comment + `sorry`
  - Line 561: Replace `since_unfold_wrapped` reference with tombstone comment + `sorry`
  - Line 618: Replace `psi_imp_until` reference with tombstone comment + `sorry`
  - Line 639: Replace `psi_imp_since` reference with tombstone comment + `sorry`
- [x] Use consistent tombstone format: `-- TOMBSTONE (task 173): was TemporalDerived.{name}; archived to Boneyard/OpenGuardInvalid/`
- [x] Run `lake build` to verify downstream files still compile (sorry count at call sites unchanged since they were already in sorry-bearing code paths)

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` - tombstone 2 call sites
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` - tombstone 2 call sites
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - tombstone 4 call sites

**Verification**:
- All 8 call sites updated with tombstone comments
- `lake build` succeeds (no new errors from downstream changes)

---

### Phase 3: Remove Sorry Stubs from TemporalDerived.lean [NOT STARTED]

**Goal**: Delete all 27 sorry-tainted definitions from TemporalDerived.lean, update the file header, and add a tombstone summary block.

**Tasks**:
- [ ] Run `grep -rn` for every definition name being removed to confirm no undiscovered downstream references beyond those already tombstoned in Phase 2
- [ ] Delete the 14 open-guard-invalid sorry stubs (lines ~333-586):
  - `bot_until_bot_absurd`, `bot_since_bot_absurd`, `bot_until_elim`, `bot_since_elim`
  - `psi_imp_until`, `psi_imp_since`, `until_imp_or`, `since_imp_or`
  - `bot_until_id`, `bot_since_id`, `until_unfold_thm`, `since_unfold_thm`
  - `refl_F`, `refl_P`
- [ ] Delete the 5 pre-existing sorry stubs (lines ~223-324):
  - `G_bot_absurd`, `H_bot_absurd`, `G_implies_topUntil`, `density_derivable`, `past_density_derivable`
- [ ] Delete the 8 transitive sorry dependents (lines ~493-654):
  - `or_until_imp`, `or_since_imp`, `until_unfold_wrapped`, `since_unfold_wrapped`
  - `until_intro`, `since_intro`, `until_F_expansion`, `since_P_expansion`
- [ ] Update the file header (lines ~19-37) to replace the "NOT VALID" section with a "Removed (Task 173)" note pointing to the Boneyard archive
- [ ] Add a tombstone summary block listing all removed definitions by category
- [ ] Verify the 24 sorry-free definitions remain intact and unmodified
- [ ] Verify no broken section separators or orphaned comments

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - remove 27 definitions, update header

**Verification**:
- File contains only the 24 sorry-free definitions plus header/structure
- `grep -c sorry TemporalDerived.lean` returns 0 (all sorry stubs removed)
- No references to removed definitions remain in file

---

### Phase 4: Build Verification and Boneyard README Update [NOT STARTED]

**Goal**: Verify the full project builds successfully and update the Boneyard README inventory.

**Tasks**:
- [ ] Run `lake build` and verify success (same or fewer errors than before)
- [ ] Compare sorry counts before and after (expect -19 net reduction in active code)
- [ ] Add inventory entry to `Theories/Bimodal/Boneyard/README.md`:
  - Directory: OpenGuardInvalid
  - Files: 1
  - Lines: estimated ~200
  - Archived From: TemporalDerived.lean
  - Why Archived: BX8/BX9 dependent + reflexivity-dependent theorems invalid under open guard (t,s); seriality-dependent sorry stubs
  - Task: 173
- [ ] Add `OpenGuardInvalid` entry to the Archival Reason Taxonomy section under "Unsound Axioms / Semantics"
- [ ] Add task 173 to the Task Cross-References table

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Boneyard/README.md` - add inventory entry, taxonomy entry, cross-reference

**Verification**:
- `lake build` succeeds
- Boneyard README has correct entry for OpenGuardInvalid
- Task cross-reference table includes task 173

---

### Phase 5: Final Audit and Cleanup [NOT STARTED]

**Goal**: Comprehensive verification that no references to removed definitions remain anywhere in the active codebase.

**Tasks**:
- [ ] Run comprehensive grep for all 27 removed definition names across entire `Theories/` directory (excluding Boneyard)
- [ ] Verify that the only remaining references are:
  - Tombstone comments in downstream files (Phase 2)
  - The Boneyard archive file (Phase 1)
  - The ClosedGuardLegacy archive (pre-existing)
  - The Boneyard StrictSemanticsLegacy archive (pre-existing, lines 996 and 1305 in UltrafilterChain.lean)
- [ ] Verify TemporalDerived.lean line count decreased substantially (expect ~672 -> ~350-400 lines)
- [ ] Run final `lake build` as gate check

**Timing**: 30 minutes

**Depends on**: 4

**Files to modify**:
- None (audit-only phase; minor fixups if issues found)

**Verification**:
- Zero active-code references to removed definitions (excluding Boneyard and tombstone comments)
- `lake build` succeeds
- Sorry count in active code reduced by 19

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental verification)
- [ ] `grep -c sorry Theories/Bimodal/Theorems/TemporalDerived.lean` returns 0
- [ ] All 24 sorry-free definitions in TemporalDerived.lean remain intact and functional
- [ ] No active module imports or references the Boneyard archive
- [ ] Downstream tombstone comments are syntactically correct
- [ ] Boneyard README inventory totals are updated correctly

## Artifacts & Outputs

- `specs/173_archive_dead_temporal_derived_sorry_stubs/plans/01_sorry-stub-archive.md` (this plan)
- `Theories/Bimodal/Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean` (new archive file)
- Modified `Theories/Bimodal/Theorems/TemporalDerived.lean` (27 definitions removed)
- Modified `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` (2 tombstones)
- Modified `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (2 tombstones)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` (4 tombstones)
- Modified `Theories/Bimodal/Boneyard/README.md` (inventory update)

## Rollback/Contingency

All removed code is preserved in two locations:
1. **Boneyard archive**: `Theories/Bimodal/Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean` contains all type signatures and the 5 definitions with proof bodies.
2. **Git history**: `git log --follow Theories/Bimodal/Theorems/TemporalDerived.lean` provides full history of all removed definitions.

To rollback: `git revert` the implementation commits. No external dependencies or configuration changes are involved.
