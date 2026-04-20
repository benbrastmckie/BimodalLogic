# Research Report: Task #104

**Task**: 104 - clean_superseded_tasks
**Started**: 2026-04-20T18:10:00Z
**Completed**: 2026-04-20T18:25:00Z
**Effort**: 1 hour
**Dependencies**: None
**Sources/Inputs**:
- specs/state.json (current machine state)
- specs/TODO.md (current user-facing task list)
- Codebase sorry scan across Theories/Bimodal/
- specs/archive/059_prove_frame_specific_soundness_axioms/ (archived task 59)
- specs/109_close_chain_construction_sorries/reports/01_chain-construction-sorries.md
**Artifacts**: specs/104_clean_superseded_tasks/reports/01_stale-state-cleanup.md
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- Task 60 depends on nonexistent task 59, which is archived. The `discrete_Icc_finite_axiom` no longer exists as an actual Lean axiom declaration -- it was already eliminated. Task 60 needs its dependency removed and description reassessed.
- The TODO.md frontmatter claims `sorry_count: 140` but the actual non-Boneyard count is 129. The `publication_path_sorries: 1` is severely wrong -- there are 11 sorry sites on the active completeness path (CanonicalModel + RootScopedChain).
- The `axiom_count: 0` claim is correct -- zero custom Lean axiom declarations exist outside Boneyard.
- state.json `repository_health.sorry_counts.non_boneyard: 140` also needs correction to 129.
- The abandoned tasks (89, 87, 74, 75, 76, 82) are already properly marked in both state.json and TODO.md with abandonment reasons.

## Context & Scope

Task 104 is a meta cleanup task to fix stale state after the post-task-93 review that abandoned 6 tasks superseded by the irreflexive semantics switch. The scope covers three areas: (1) task 60 dependency/description fixes, (2) sorry count metrics in TODO.md frontmatter, (3) sorry count metrics in state.json.

## Findings

### 1. Task 60 Status

**Current state in state.json** (project_number 60):
- Status: `not_started`
- Dependencies: `[59]`
- Description: references `discrete_Icc_finite_axiom` at `FrameConditions/Completeness.lean line 187`

**Task 59** is archived at `specs/archive/059_prove_frame_specific_soundness_axioms/`. It does not exist in state.json `active_projects`. The dependency is stale.

**`discrete_Icc_finite_axiom` status**: No Lean `axiom` declaration exists anywhere in the active codebase (confirmed via `grep -rn "^axiom " Theories/`). The identifier appears only in:
- `FrameConditions/FrameClass.lean:143` -- docstring comment referencing it as "documented technical debt"
- `Bundle/SuccExistence.lean:996` -- comment referencing it

The axiom was already eliminated. However, the docstring in FrameClass.lean still references it as if it exists. The `axiom_count_note` in TODO.md frontmatter correctly says "discrete_Icc_finite_axiom eliminated".

**Recommendation for task 60**: Either (a) abandon the task since the axiom is already gone, or (b) reassign the task to clean up the stale docstring references. The dependency on task 59 must be removed regardless.

### 2. Sorry Count Metrics

#### Actual Non-Boneyard Sorry Count: 129

Breakdown by area:

| Area | File | Count |
|------|------|-------|
| BXCanonical/CanonicalModel.lean | Chain construction | 6 |
| BXCanonical/RootScopedChain.lean | Chain coherence | 5 |
| BXCanonical/Quasimodel/OracleStep.lean | Oracle (to archive in task 107) | 4 |
| BXCanonical/Quasimodel/Realization.lean | Quasimodel realization | 4 |
| BXCanonical/Quasimodel/Construction.lean | Quasimodel construction | 2 |
| BXCanonical/TruthLemma.lean | Truth lemma gaps | 2 |
| BXCanonical/Frame.lean | Frame property | 1 |
| BXCanonical/Filtration/SigmaOrdering.lean | Sigma ordering | 3 |
| SoundnessLemmas.lean | Soundness lemmas | 24 |
| Bundle/ (3 files) | Bundle path | 7 |
| Algebraic/ (3 files) | Algebraic path | 5 |
| Examples/ (5 files) | Example exercises | 55 |
| Theorems/TemporalDerived.lean | Derived theorems | 9 |
| **Total non-Boneyard** | | **129** |

Note: After task 107 archives OracleStep (4 sorries) + Boneyard/OracleCoherence (not counted here, already in Boneyard subdir) + Boneyard/RoundRobinChain (already in Boneyard subdir), the non-Boneyard count would drop to ~125.

#### Publication Path Sorries

The TODO.md frontmatter says `publication_path_sorries: 1`. This is wrong.

The 11 sorry sites blocking sorry-free `bx_completeness` are in:
- `CanonicalModel.lean`: lines 56, 101, 117, 167, 207, 213 (6 sorries)
- `RootScopedChain.lean`: lines 1065, 1092, 1099, 1107, 1114 (5 sorries)

The `1` was from an earlier assessment when only the TaskModel embedding sorry (Completeness.lean:154) was considered the blocker. Task 93 closed that sorry but the broader chain construction sorries were already present and are now the primary blocker.

**Correct value**: `publication_path_sorries: 11`

The sorry_count_note should be updated to reflect: "129 non-Boneyard (11 on active completeness path in CanonicalModel+RootScopedChain; 4 of 11 genuinely false/unprovable as stated). Soundness is sorry-free. Decidability is sorry-free."

### 3. state.json `repository_health` Section

Current values:
```json
"sorry_counts": {
  "non_boneyard": 140,
  "boneyard": 171,
  "total": 311
}
```

Should be:
```json
"sorry_counts": {
  "non_boneyard": 129,
  "boneyard": 171,
  "total": 300
}
```

The Boneyard count (171) was not re-audited and may also be stale but is lower priority.

### 4. TODO.md Frontmatter Metrics

Current:
```yaml
task_counts:
  active: 24
  completed: 760
  in_progress: 0
  not_started: 13
  abandoned: 69
  total: 853
technical_debt:
  sorry_count: 140
  sorry_count_note: "Audited 2026-04-12: 140 non-Boneyard (1 active-path at BXCanonical/Completeness.lean:154)..."
  publication_path_sorries: 1
```

Issues:
1. `sorry_count` should be 129, not 140
2. `sorry_count_note` references "1 active-path at BXCanonical/Completeness.lean:154" which was closed by task 93. The 11 chain construction sorries are now the active-path blockers.
3. `publication_path_sorries` should be 11, not 1
4. `task_counts` may need reconciliation (new tasks 104-109 created, tasks abandoned)

### 5. Abandoned Tasks Context

All 6 abandoned tasks are properly recorded:

| Task | Name | Abandonment Reason |
|------|------|--------------------|
| 89 | close_frame_lean_eventuality_sorries | Superseded by tasks 90+92+98+102 |
| 87 | full_representation_theorem_until_since | Bundle/ approach superseded by BXCanonical (task 109) |
| 74 | research_strict_vs_reflexive_semantics | Answered by task 93 irreflexive switch |
| 75 | research_strict_temporal_extension_design | Moot after task 93 irreflexive switch |
| 76 | research_density_discreteness_completeness | Framed around resolved strict-vs-reflexive question |
| 82 | close_fmp_truth_preservation_sorries | Assumes reflexive semantics removed by task 93 |

All have `status: "abandoned"` in state.json and `[ABANDONED]` markers in TODO.md with documented reasons. No further action needed for these.

### 6. Task 59 Context

Task 59 (`prove_frame_specific_soundness_axioms`) is archived at `specs/archive/059_prove_frame_specific_soundness_axioms/`. It has plans, reports, and summaries but is not in state.json `active_projects`. It was likely completed or archived before the vault transition.

## Decisions

1. The "11 active-path sorries" claim from the task description is **verified correct** (6 CanonicalModel + 5 RootScopedChain).
2. The `discrete_Icc_finite_axiom` has been eliminated -- task 60 should have its dependency on 59 removed and should be reassessed (possibly abandoned since the axiom no longer exists).
3. Sorry count metrics need updating in both TODO.md and state.json.

## Recommendations

### Implementation Actions (ordered by priority)

1. **Update task 60 in state.json**: Remove dependency on task 59. Either abandon task 60 (axiom already eliminated) or update description to reference only the stale docstring cleanup.

2. **Update TODO.md frontmatter**:
   - `sorry_count: 129`
   - `publication_path_sorries: 11`
   - `sorry_count_note`: Update to reference 11 active-path sorries in CanonicalModel+RootScopedChain, noting task 93 closed the Completeness.lean:154 sorry

3. **Update state.json `repository_health.sorry_counts`**:
   - `non_boneyard: 129`
   - `total: 300`
   - Update note text

4. **Update TODO.md task 60 entry**: Remove `Dependencies: Task 59`, update description

5. **Reconcile `task_counts`**: Verify active/not_started/abandoned counts match actual state

## Risks & Mitigations

- **Risk**: Sorry count may shift if other tasks (105, 107, 108) make changes before 104 is implemented. **Mitigation**: Use the counts as of this audit date (2026-04-20) and note the audit timestamp.
- **Risk**: Task 60 abandonment may lose track of the stale FrameClass.lean docstring. **Mitigation**: Include docstring cleanup in task 60's revised description rather than abandoning entirely.

## Appendix

### Sorry Count Verification Command
```bash
grep -rn "^  sorry\|^    sorry\|^      sorry\|^sorry" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard | grep -v StrictSemanticsLegacy | wc -l
# Result: 129 (as of 2026-04-20)
```

### Active Completeness Path Sorries (11 total)
```
CanonicalModel.lean:56   enriched_seed_consistent
CanonicalModel.lean:101  fwd_succ_f_carry (genuinely unprovable)
CanonicalModel.lean:117  enriched_past_seed_consistent
CanonicalModel.lean:167  bwd_pred_p_carry (genuinely unprovable)
CanonicalModel.lean:207  g_content_subset_self (genuinely false)
CanonicalModel.lean:213  h_content_subset_self (genuinely false)
RootScopedChain.lean:1065  fwd_chain_forward_F
RootScopedChain.lean:1092  dd_bfmcs_restricted_tc (fwd)
RootScopedChain.lean:1099  dd_bfmcs_restricted_tc (bwd)
RootScopedChain.lean:1107  dd_bfmcs_restricted_buc
RootScopedChain.lean:1114  dd_bfmcs_restricted_fuc
```

### Custom Axiom Declarations
Zero custom Lean `axiom` declarations found outside Boneyard/StrictSemanticsLegacy. The `discrete_Icc_finite_axiom` has been eliminated.
