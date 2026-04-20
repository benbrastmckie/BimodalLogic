# Implementation Plan: Rewrite ROADMAP for Irreflexive Semantics

- **Task**: 106 - Rewrite ROADMAP for irreflexive semantics
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None (documentation task; task 93 already completed)
- **Research Inputs**: specs/106_rewrite_roadmap_irreflexive/reports/01_roadmap-rewrite-audit.md
- **Artifacts**: plans/01_roadmap-rewrite.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

ROADMAP.md contains pervasive references to "reflexive" semantics that must be corrected to "irreflexive" following the completion of task 93. Beyond terminology, the sorry inventory is severely undercounted (ROADMAP claims 5, actual non-Boneyard count is 32), the axiom count is wrong (claims 35-37, actual is 33), BX8/BX8' are still listed in the axiom table despite removal, the X/Y operator section is entirely stale, and module line counts and sorry-free claims are outdated across multiple files. This plan covers all 15 research findings in 5 phases.

### Research Integration

The research report (01_roadmap-rewrite-audit.md) audited every ROADMAP section against the current Lean source. Key findings integrated into this plan:
- 25 occurrences of "reflexive" language need correction (some are historically correct in dead-ends context)
- Axiom count must change from 35/37 to 33 (BX8/BX8' removed)
- Sorry inventory must be restructured: 5 RootScopedChain sorries (critical path) + 9 additional in CanonicalModel/TruthLemma/Frame (irreflexive-consequence) + 9 in Quasimodel infrastructure + 9 in OracleStep (deprecated)
- X/Y operator section needs complete rewrite for irreflexive semantics
- Module import graph has stale line counts and incorrect sorry-free claims for 5 files

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task directly updates ROADMAP.md itself. No external roadmap items to align against.

## Goals & Non-Goals

**Goals**:
- Correct all "reflexive" terminology to "irreflexive" where semantically appropriate
- Fix axiom count to 33 and remove BX8/BX8' from the axiom table
- Restructure sorry inventory to distinguish critical-path vs irreflexive-consequence vs infrastructure sorries
- Rewrite X/Y operator section for irreflexive semantics
- Update all module line counts and sorry-free claims to match actual source
- Update task cross-reference table with tasks 93, 106, 109

**Non-Goals**:
- Fixing sorries in the Lean source code (that is task 109's scope)
- Updating Axioms.lean header comment (separate concern, minor)
- Changing the ROADMAP's overall structure or adding new sections
- Verifying sorry counts by running grep (research report already did this)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line numbers in ROADMAP drift from source after future edits | M | H | Use definition names alongside line numbers; accept approximate line refs |
| Sorry counts change between research and implementation | L | M | Verify counts with quick grep before writing; note "as of date" |
| Over-correcting "reflexive" in dead-ends context | M | L | Research report identified which dead-end references are historically correct; preserve those |
| BX2 description inconsistency missed | M | L | Cross-check axiom table entry against Lean source during Phase 2 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1 |
| 4 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Overview and Semantics Language Corrections [COMPLETED]

**Goal**: Fix all "reflexive" -> "irreflexive" terminology in the overview, irreflexive semantics section, legacy code section, and Burgess-Xu section. Correct the axiom count in the overview.

**Tasks**:
- [ ] Line 5: Change "reflexive linear temporal logic" to "irreflexive linear temporal logic"
- [ ] Line 8: Change "37 BX axioms" to "33 BX axioms"
- [ ] Line 11: Rewrite "fully reflexive: G/H quantify over t <= s / s <= t" to "irreflexive: G/H quantify over t < s / s < t, and Until/Since require strict witnesses"
- [ ] Line 37: Change "reflexive semantics, canonical" to "irreflexive semantics, canonical"
- [ ] Line 116: Fix incorrect claim that BX8 was replaced with step axiom -- BX8 was removed entirely
- [ ] Lines 514-550 (Legacy Code): Fix "reverted to the all-reflexive BX system" to clarify legacy files were from a different architecture
- [ ] Line 533: Update task 94 reference (no longer future -- completed)
- [ ] Lines 554-621 (Burgess-Xu): Clarify that BX system departs from Burgess/Xu by using irreflexive semantics
- [ ] Lines 598-599: Update BX9 role description for irreflexive semantics (guard covers t, so phi(t) from guard, not from s=t)
- [ ] Lines 624-984 (Dead Ends): Review "reflexive" references in dead ends 28 and 36(b); preserve historically correct ones, fix any that describe current system incorrectly

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `specs/ROADMAP.md` -- Overview (lines 1-38), Irreflexive Semantics (lines 107-124), Legacy Code (lines 514-550), Burgess-Xu (lines 554-621), Dead Ends (lines 624-984)

**Verification**:
- No occurrence of "fully reflexive" describing current system semantics
- "33 BX axioms" in overview
- BX8 described as removed, not replaced

---

### Phase 2: Axiom System Table Corrections [COMPLETED]

**Goal**: Fix axiom count, remove BX8/BX8' from the table, update all Axioms.lean line number references, and verify BX2 description consistency.

**Tasks**:
- [ ] Line 40: Change "35 axiom constructors" to "33 axiom constructors"
- [ ] Lines 89-90: Remove BX8 (until_step) and BX8' (since_step) rows from axiom table
- [ ] Update all `Axioms.lean:NNN` line number references in the axiom table to match current source
- [ ] Verify BX2/BX2' table entry matches current Lean code: `(phi->chi) AND G(phi->chi) -> ((phi U psi) -> (chi U psi))`
- [ ] Fix line 109 BX2 description text if it still shows old form (without current-time conjunct)

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROADMAP.md` -- Axiom System section (lines 40-124)

**Verification**:
- Axiom table has exactly 33 entries (no BX8/BX8')
- All Axioms.lean line references are within 5 lines of actual
- BX2 description and table entry are consistent

---

### Phase 3: X/Y Operator Section Rewrite [COMPLETED]

**Goal**: Completely rewrite the X/Y Operator Status section (lines 163-192) for irreflexive semantics.

**Tasks**:
- [ ] Remove stale reflexive unfolding calculation (lines 180-184 using t <= s)
- [ ] Write new analysis: Under irreflexive semantics, `bot U phi` at `t` requires `exists s > t, phi(s) AND forall r, t < r < s -> bot`
- [ ] Document discrete order case: empty interval condition gives genuine next-step operator
- [ ] Document dense order case: note that immediate successor may not exist
- [ ] Reassess conclusion that "X/Y are definitional dead code" -- under irreflexive semantics they may have genuine content
- [ ] Update any cross-references to this section from elsewhere in ROADMAP

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROADMAP.md` -- X/Y Operator Status section (lines 163-192)

**Verification**:
- No references to `t <= s` in X/Y section
- Discrete and dense order cases both addressed
- Section correctly uses strict inequality `t < s`

---

### Phase 4: Sorry Inventory and Module Import Graph [COMPLETED]

**Goal**: Restructure the sorry inventory to reflect actual sorry counts (32 non-Boneyard) with categorization, fix module line counts, and correct sorry-free claims.

**Tasks**:
- [ ] Lines 452-511: Restructure sorry inventory into three categories:
  - Critical path (5 in RootScopedChain.lean blocking bx_completeness)
  - Irreflexive-consequence (Frame 1, TruthLemma 2, CanonicalModel 6 = 9 sorries)
  - Infrastructure (Quasimodel Construction 2, Realization 4, SigmaOrdering 3, OracleStep 9 = 18 sorries)
- [ ] Fix RootScopedChain.lean sorry line numbers: 1065, 1092, 1099, 1107, 1114 (not 1093, 1120, 1127, 1135, 1142)
- [ ] Fix sorry definition names: row 1 is `fwd_chain_forward_F` not `dd_bfmcs_restricted_fuc`; remove duplicate row 5
- [ ] Lines 203-276 (Module Import Graph): Update line counts per research findings table (section 6)
- [ ] Fix sorry-free claims: TruthLemma.lean (2 sorries), CanonicalModel.lean (6 sorries), Construction.lean (2 sorries), Realization.lean (4 sorries), SigmaOrdering.lean (3 sorries)
- [ ] Line 275: Fix "5,791 lines across 16 files, 5 sorries" to correct totals
- [ ] Lines 16-33 (Overview Sorry Summary): Update sorry count, fix line number references, document broader sorry landscape
- [ ] Lines 337-357: Fix Completeness.lean sorry description (now sorry-free; sorry moved to RootScopedChain.lean)

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `specs/ROADMAP.md` -- Sorry Inventory (lines 452-511), Module Import Graph (lines 203-276), Overview Sorry Summary (lines 16-33), Canonical Model bx_completeness section (lines 337-357)

**Verification**:
- Sorry inventory lists all 32 non-Boneyard sorries with correct categorization
- RootScopedChain.lean sorry table has 5 entries with correct line numbers and definition names
- No file incorrectly claimed sorry-free
- Total line count and sorry count updated

---

### Phase 5: Canonical Model, Quasimodel, Cross-Reference, and Final Pass [COMPLETED]

**Goal**: Update remaining sections (canonical model construction, quasimodel/filtration, task cross-reference), update the "Last Updated" line, and do a final consistency pass.

**Tasks**:
- [ ] Lines 283-357 (Canonical Model Construction): Fix Frame.lean line references for g_content_set_consistent; clarify it uses seriality, not BX1
- [ ] Lines 362-441 (Quasimodel/Filtration): Update line counts; remove "all sorry-free" claim (Construction 2 sorries, Realization 4, SigmaOrdering 3)
- [ ] Lines 1086-1103 (Task Cross-Reference): Update task 93 status to [COMPLETED]; add task 106 and task 109 entries
- [ ] Update "Last Updated" line with current date and description of changes
- [ ] Final pass: Search for remaining "reflexive" references to ensure none describe current system incorrectly
- [ ] Verify internal consistency: axiom count (33) appears consistently, sorry counts match between overview and inventory sections

**Timing**: 30 minutes

**Depends on**: 2, 3, 4

**Files to modify**:
- `specs/ROADMAP.md` -- Canonical Model (lines 283-357), Quasimodel/Filtration (lines 362-441), Task Cross-Reference (lines 1086-1103), Last Updated line

**Verification**:
- g_content_set_consistent references seriality (not BX1)
- Quasimodel section acknowledges 9 sorries in infrastructure
- Task cross-reference includes tasks 93, 106, 109
- "33" axiom count appears consistently throughout
- grep for "fully reflexive" returns 0 matches in non-dead-end, non-historical context

## Testing & Validation

- [ ] Search ROADMAP.md for "fully reflexive" -- should only appear in dead-end historical context
- [ ] Search for "37 BX" or "35 axiom" -- should return 0 matches
- [ ] Search for BX8 entries in axiom table -- should be absent (may remain in prose describing removal)
- [ ] Verify sorry inventory total equals sum of categories (5 + 9 + 18 = 32)
- [ ] Verify axiom count "33" is consistent across overview, axiom system section header, and any summary lines
- [ ] Cross-check RootScopedChain.lean sorry line numbers against actual file

## Artifacts & Outputs

- `specs/106_rewrite_roadmap_irreflexive/plans/01_roadmap-rewrite.md` (this plan)
- `specs/ROADMAP.md` (updated)
- `specs/106_rewrite_roadmap_irreflexive/summaries/01_roadmap-rewrite-summary.md` (post-implementation)

## Rollback/Contingency

ROADMAP.md is under git version control. If any changes introduce errors, revert with `git checkout HEAD -- specs/ROADMAP.md`. Each phase modifies distinct sections, so partial rollback is straightforward by reverting specific line ranges from git history.
