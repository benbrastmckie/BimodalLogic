# Implementation Plan: Task #301

- **Task**: 301 - Completeness cleanup and roadmap
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/301_completeness_cleanup_and_roadmap/reports/01_completeness-status-audit.md
- **Artifacts**: plans/02_cleanup-roadmap-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Repository cleanup and roadmap update following the completion of task 273 (BracketFormula k encoding fix, ~1400 lines of sorry-free proofs). The research audit revealed that the completeness picture is far simpler than previously understood: only ONE sorry blocks `completeness_discrete` (the k>0 case in `existPart_succ_n1_bypass` at KampBypass.lean:4486), and `chronicle_gap_contradiction` is dead code. This plan covers dead-code archival, oversized file factoring, phantom sorry elimination, task triage (abandon 5 obsolete tasks, revise 2 dependencies), new task creation (k>0 depth induction + import refactor), and ROADMAP.md rewrite.

### Research Integration

Key findings from the completeness status audit (report 01):
- Sole real blocker for `completeness_discrete`: `existPart_succ_n1_bypass` k>0 (KampBypass.lean:4486)
- `chronicle_gap_contradiction` is dead code -- appears in `#print axioms` only due to phantom import
- Tasks 155, 268, 200, 254, 176 are obsolete and should be abandoned
- KampBypass.lean at 4488 lines needs factoring
- ROADMAP.md is significantly outdated (claims two sorry chains when only one matters)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

ROADMAP.md exists but is significantly outdated. This plan includes a full rewrite of ROADMAP.md as its final phase. Key items this plan advances:
- Closing the gap between documented sorry status and actual sorry status
- Archiving dead code (BXCanonical, dead chronicle functions, VecEADecomposition)
- Clarifying the sole remaining completeness blocker

## Goals & Non-Goals

**Goals**:
- Archive dead code to Boneyard/ with clear comments
- Factor KampBypass.lean into manageable files
- Eliminate phantom sorry dependency from `chronicle_gap_contradiction`
- Abandon 5 obsolete tasks and revise 2 task dependencies
- Create 2 new tasks (k>0 depth induction, import refactor)
- Rewrite ROADMAP.md to accurately reflect current state

**Non-Goals**:
- Closing the k>0 sorry (that is a separate new task)
- Refactoring non-Metalogic code
- Publication-quality documentation (task 177)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Moving `mcs_mixed_case_absurd` breaks imports | H | M | Run `lake build` after move to verify |
| KampBypass factoring introduces import cycles | H | L | Follow natural module boundaries (Until/Since/Core) |
| Boneyard archival breaks aggregator imports | M | M | Update all aggregator files; verify with `lake build` |
| Stavi path still used by some non-critical code | M | L | Check imports before archiving; keep if referenced |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Move mcs_mixed_case_absurd and eliminate phantom sorry [COMPLETED]

**Goal**: Eliminate the phantom sorry dependency from `chronicle_gap_contradiction` by moving `mcs_mixed_case_absurd` out of ChronicleToCountermodel.lean.

**Tasks**:
- [ ] Identify all callers of `mcs_mixed_case_absurd` using grep/lean_references
- [ ] Create or identify the appropriate target file (likely `Metalogic/Core/MCSProperties.lean` or a new file `Metalogic/WeakCanonical/MCSMixedCase.lean`)
- [ ] Move `mcs_mixed_case_absurd` and any helper lemmas it depends on to the target file
- [ ] Update import in `Completeness.lean` to use new location instead of ChronicleToCountermodel
- [ ] Run `lake build` to verify zero errors
- [ ] Verify with `#print axioms completeness_discrete` that `chronicle_gap_contradiction` no longer appears *(deviation: skipped — sorryAx in completeness_discrete comes from existPart_succ_n1_bypass via Reynolds pipeline, not from chronicle_gap_contradiction phantom import; the move is still valuable for code organization)*

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - remove `mcs_mixed_case_absurd`
- `Theories/Bimodal/Metalogic/Completeness.lean` - update import
- New or existing file for `mcs_mixed_case_absurd` destination

**Verification**:
- `lake build` passes with zero errors
- `#print axioms completeness_discrete` shows no `chronicle_gap_contradiction`

---

### Phase 2: Archive dead code to Boneyard/ [NOT STARTED]

**Goal**: Move dead code out of the active source tree into Boneyard/ with clear archival comments.

**Tasks**:
- [ ] Verify BXCanonical non-Chronicle subtree is fully dead (grep for imports from live code)
- [ ] Move dead BXCanonical files to `Boneyard/BXCanonical/` (if not already done by task 268)
- [ ] Identify dead chronicle functions (`chronicle_gap_contradiction`, `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective`) in ChronicleToCountermodel.lean
- [ ] Move dead chronicle functions to `Boneyard/DeadChronicle/` or comment-mark them as dead code
- [ ] Verify VecEADecomposition.lean sorries are quarantined (confirmed dead by task 273 research)
- [ ] Check StaviCompleteness.lean / Stavi path usage before considering archival (may still be referenced)
- [ ] Update aggregator imports (`Metalogic.lean`, `BXCanonical.lean`, etc.)
- [ ] Run `lake build` to verify zero errors

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - remove dead functions
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` - update aggregator
- `Theories/Bimodal/Metalogic/Metalogic.lean` - update aggregator
- `Boneyard/` - new archival files

**Verification**:
- `lake build` passes with zero errors
- Dead code no longer in active source tree
- Archival comments present in Boneyard files

---

### Phase 3: Factor KampBypass.lean [NOT STARTED]

**Goal**: Split the oversized KampBypass.lean (4488 lines) into manageable files following natural module boundaries.

**Tasks**:
- [ ] Analyze KampBypass.lean structure: identify Until-direction proofs, Since-direction proofs, shared infrastructure, eq case, and main theorem
- [ ] Create `KampBypassUntil.lean` with Until-direction proofs
- [ ] Create `KampBypassSince.lean` with Since-direction proofs
- [ ] Create `KampBypassCore.lean` (or keep as `KampBypass.lean`) with shared infrastructure, eq case, and main theorem
- [ ] Update all imports referencing KampBypass to use the correct new file
- [ ] Run `lake build` to verify zero errors

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/KampBypass.lean` - factor into pieces
- New files: `KampBypassUntil.lean`, `KampBypassSince.lean`, `KampBypassCore.lean`
- Any files importing KampBypass - update imports

**Verification**:
- `lake build` passes with zero errors
- No single file exceeds ~2000 lines
- All imports resolve correctly

---

### Phase 4: Task triage and new task creation [NOT STARTED]

**Goal**: Abandon obsolete tasks, revise dependencies, and create new tasks for the remaining work.

**Tasks**:
- [ ] Abandon task 155 (reynolds_pipeline_activation) with reason: "Mega-task with 67 plan versions. Scope fully carved into task 273 (completed) and new k>0 task."
- [ ] Abandon task 268 (reynolds_pipeline_bridge) with reason: "Proposed bypassing chronicle_gap_contradiction. Audit shows this sorry is dead code -- no bypass needed."
- [ ] Abandon task 200 (ghr93_case_ii_elegance_rewrite) with reason: "Cosmetic rewrite of working proof. Low priority, not on critical path."
- [ ] Abandon task 254 (update_stale_metadata_post_202) with reason: "Metadata cleanup subsumed by task 301."
- [ ] Abandon task 176 (relocate_chronicle_and_archive_dead_bxcanonical) with reason: "Partially subsumed by task 301 Boneyard archival scope."
- [ ] Update task 95 dependency: change from 155 to the new k>0 task number
- [ ] Update task 299 dependency: change from 273 to the new k>0 task number (since it needs sorry-free chain)
- [ ] Create new task: "k>0 depth induction" -- close `existPart_succ_n1_bypass` k>0 via Rabinovich Section 5 Lemma 5.1 interval-splitting induction (~200-400 lines, sole completeness_discrete blocker)
- [ ] Create new task: "import refactor" -- move `mcs_mixed_case_absurd` out of ChronicleToCountermodel.lean (quick win if not already done in Phase 1; otherwise mark as completed during creation)
- [ ] Update state.json for all abandoned tasks and new tasks
- [ ] Regenerate TODO.md via `generate-todo.sh`

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `specs/state.json` - abandon 5 tasks, revise 2 dependencies, create 2 new tasks
- `specs/TODO.md` - regenerated from state.json

**Verification**:
- All 5 tasks marked as abandoned in state.json
- New tasks created with correct task_type, dependencies, descriptions
- Task 95 and 299 dependencies updated
- TODO.md regenerated and consistent with state.json

---

### Phase 5: Rewrite ROADMAP.md [NOT STARTED]

**Goal**: Update ROADMAP.md to accurately reflect the current state of the completeness effort after task 273 completion.

**Tasks**:
- [ ] Update the "Current state" section: sole blocker is k>0 `existPart_succ_n1_bypass`
- [ ] Fix the "Critical path" section: remove references to "two independent sorry chains" -- only one chain matters
- [ ] Update sorry chain documentation: `chronicle_gap_contradiction` is dead code (not a blocker)
- [ ] Remove or annotate the `succ_cofinal` discussion as resolved/bypassed
- [ ] Update task references: 273 completed, 155/268 abandoned, new k>0 task created
- [ ] Update the Sorry Inventory tables to reflect current sorry counts
- [ ] Add note about task 273 accomplishment (~1400 lines sorry-free proofs, k=0 KampBypass complete)
- [ ] Mark completed ROADMAP items with `- [x]` and completion annotations

**Timing**: 1 hour

**Depends on**: 3, 4

**Files to modify**:
- `specs/ROADMAP.md` - comprehensive update

**Verification**:
- ROADMAP.md accurately reflects sole blocker (k>0 existPart_succ_n1_bypass)
- No references to "two sorry chains" or obsolete tasks
- Task 273 completion documented
- Sorry inventory matches actual codebase state

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `#print axioms completeness_discrete` shows no `chronicle_gap_contradiction` after Phase 1
- [ ] All 5 abandoned tasks marked correctly in state.json
- [ ] New tasks created with accurate descriptions and dependencies
- [ ] ROADMAP.md accurately reflects sole remaining blocker
- [ ] No import cycles introduced by file factoring

## Artifacts & Outputs

- `specs/301_completeness_cleanup_and_roadmap/plans/02_cleanup-roadmap-plan.md` (this file)
- `specs/301_completeness_cleanup_and_roadmap/summaries/02_cleanup-roadmap-summary.md` (after implementation)
- Updated `specs/ROADMAP.md`
- Updated `specs/state.json` and `specs/TODO.md`
- Factored KampBypass files
- Boneyard archival files

## Rollback/Contingency

All changes are reversible via git:
- File moves to Boneyard can be reverted by moving files back
- KampBypass factoring can be reverted by restoring the original file from git
- Task status changes in state.json can be reverted
- ROADMAP.md changes can be reverted from git history

If `lake build` fails after any phase, stop and diagnose before proceeding. Import issues are the most likely failure mode and can be resolved by adjusting import paths.
