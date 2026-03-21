# Research Report: Task #970 — Remaining Phases 5-9 and Task 971 Coordination

**Task**: 970 - Review Metalogic for Publication Readiness (follow-up)
**Date**: 2026-03-15
**Mode**: Team Research (2 teammates)
**Session**: sess_1773639168_11193
**Focus**: Analysis of deferred phases 5-9 and coordination with task 971

---

## Summary

Both teammates independently produced high-confidence findings with no conflicts. The remaining phases 5-9 are well-scoped and feasible, with phases 6/7/8 being low-risk and phases 5/9 requiring more care. Task 971 (eliminate bmcs_truth_at layer) can proceed **immediately in parallel** with no blocking dependencies from phases 5-9.

**Key surprise from Phase 7 analysis**: `diamondFormula` was planned for removal in Phase 3 but still exists in `ModalSaturation.lean`. Phase 7 must clean this up.

---

## Key Findings by Phase

### Phase 5: Consolidate Duplicate Theorems

**Scope**: 3 duplicate theorem bodies to remove, 11 unique theorems to migrate.

| Theorem | Completeness.lean | MCSProperties.lean | Action |
|---------|-------------------|--------------------|--------|
| `set_mcs_all_future_all_future` | Lines 377-394 | Lines 243-260 | Remove from Completeness.lean |
| `set_mcs_all_past_all_past` | Lines 437-454 | Lines 303-320 | Remove from Completeness.lean |
| `temp_4_past` | Lines 401-423 | Lines 267-289 | Remove from Completeness.lean |

**Import graph**: `MCSProperties.lean` is imported by 15+ files; `Completeness.lean` by only 2 (`StagedExecution.lean`, `ConstructiveFragment.lean`). Canonical location is `MCSProperties.lean`.

**11 unique theorems to migrate** from `Completeness.lean` → `MCSProperties.lean`:
- `set_mcs_disjunction_intro/elim/iff` (3)
- `set_mcs_conjunction_intro/elim/iff` (3)
- `set_mcs_box_closure`, `set_mcs_box_box` (2)
- `set_mcs_neg_box_implies_diamond_neg`, `set_mcs_diamond_neg_implies_neg_box`, `set_mcs_diamond_box_duality` (3)

After migration, `Completeness.lean` can be deprecated or converted to a pure re-export file.

**Difficulty**: MEDIUM | **Risk**: LOW (all downstream files already import MCSProperties)

### Phase 6: Unify asDiamond Definitions

**Scope**: Simple removal — `asDiamond` in `ModalSaturation.lean` is completely unused.

| Definition | File | Usage |
|------------|------|-------|
| `asDiamond` | `ModalSaturation.lean:70` | **0 external references — remove** |
| `asDiamond?` | `Decidability/Tableau.lean:157` | 4 active references — keep |

Both are semantically identical (both match `neg(Box(neg A))` = `Diamond A`). Only the unused one needs removing.

**Difficulty**: LOW | **Risk**: VERY LOW

### Phase 7: Clean Internal Scaffolding

**Scope**: Two items require cleanup.

1. **`needs_modal_witness`** (`ModalSaturation.lean:82-83`): Used exactly once within `is_modally_saturated_iff_no_needs_witness` (same file). Action: make `private` or move to `where` clause.

2. **`diamondFormula`** (`ModalSaturation.lean:63`): Thin alias for `phi.diamond`. **This was supposed to be removed in Phase 3 but was missed.** Still active — must be removed and callers updated to use `phi.diamond` directly.

**Difficulty**: LOW | **Risk**: LOW

### Phase 8: Remove Weak/Finite Completeness Variants

**Scope**: Minimal — no active weak/finite completeness variants exist in the main codebase.

| Item | Status | Action |
|------|--------|--------|
| `semantic_weak_completeness` (`FMP/SemanticCanonicalModel.lean`) | **PRIMARY theorem** | Keep (this is the main completeness result) |
| `standard_weak_completeness` | Already in Boneyard | None needed |
| `dense_weak_completeness` | Doc comment only, not implemented | None needed |

**Finding**: The word "weak" in `semantic_weak_completeness` is a slight misnomer — it handles validity (`⊨ φ → ⊢ φ`), which is the standard completeness direction. Consider renaming to `semantic_completeness` for clarity (optional, low priority).

**Difficulty**: LOW | **Risk**: VERY LOW — primarily documentation clarification only

### Phase 9: Improve Naming Conventions

**Scope**: Inconsistencies exist but bulk rename is risky.

| Current Name | Should Be | Location | Usage Count |
|--------------|-----------|----------|-------------|
| `temporally_coherent` | `is_temporally_coherent` | BFMCS.lean | ~10 files |
| `SetMaximalConsistent` | `IsSetMaximalConsistent` | Core/MaximalConsistent.lean | 50+ files |
| `SetConsistent` | `IsSetConsistent` | Core/MaximalConsistent.lean | 50+ files |

**Assessment**: `SetMaximalConsistent` and `SetConsistent` affect 50+ files — immediate rename too risky. Recommendation: add deprecation aliases, update new code, consider bulk rename in a dedicated follow-up task.

`temporally_coherent` is lower risk (~10 files) and could be renamed directly.

**Coordination note with Task 971**: If Phase 9 renames any `bmcs_*` identifiers, coordinate with Task 971's deprecation strategy to avoid confusion.

**Difficulty**: MEDIUM-HIGH | **Risk**: MEDIUM

---

## Task 970/971 Coordination

### Overlap Assessment: MINIMAL

| Task 970 Phase | Overlaps with 971? | Details |
|----------------|-------------------|---------|
| Phase 5: Consolidate Duplicates | NO | Different files (Completeness.lean, MCSProperties.lean) |
| Phase 6: Unify asDiamond | NO | Different subsystem (ModalSaturation, Tableau) |
| Phase 7: Clean Scaffolding | MINIMAL | Could touch BFMCSTruth.lean indirectly |
| Phase 8: Remove Weak Variants | NO | Different layer |
| Phase 9: Naming Conventions | POSSIBLE | If renaming `bmcs_*` identifiers |

### Task 971 Prerequisites — All Met

Task 971 can **start immediately** because:
- Task 970 Phase 4 [COMPLETED] already removed unused `bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context` from `BFMCSTruth.lean`
- Task 970 Phase 11 [COMPLETED] added legacy path markers to `TruthLemma.lean` and `BFMCSTruth.lean`
- Task 970 Phase 11 [COMPLETED] updated `SORRY_REGISTRY.md`
- No import cycle risks identified

### Shared File Status

| File | Task 970 Phase | Task 971 Phase | Conflict Risk |
|------|----------------|----------------|---------------|
| `BFMCSTruth.lean` | Phase 4 (DONE) | Phase 2 | LOW |
| `TruthLemma.lean` | Phase 11 (DONE) | Phase 3 | LOW (aligned) |
| `Metalogic.lean` | Phase 11 (DONE) | Phase 4 | LOW (aligned) |

### Recommended Sequencing

```
Task 971 START  ────────────────────────────────> (independent)
Task 970 Phase 6 ──> Phase 7 ──> Phase 8 ──> Phase 5 ──> Phase 9
                                                          (coordinate on bmcs_* naming)
```

Tasks 970 phases 5-8 and Task 971 can run in **parallel**. Phase 9 should be coordinated with Task 971 completion if `bmcs_*` identifiers are renamed.

---

## Synthesis

### Revised Execution Order for Phases 5-9

| Order | Phase | Rationale |
|-------|-------|-----------|
| 1 | **Phase 6** (asDiamond removal) | Simplest — zero external references, 5 min fix |
| 2 | **Phase 7** (Scaffolding + missed diamondFormula) | Contains Phase 3 missed item; low risk |
| 3 | **Phase 8** (Weak completeness docs) | Documentation only; no structural changes |
| 4 | **Phase 5** (Theorem consolidation) | Main structural work; needs import graph care |
| 5 | **Phase 9** (Naming conventions) | Cross-cutting; coordinate with Task 971 |

### Conflicts Found
None between the two teammates' analyses — findings were complementary.

### Gaps Identified
1. **Phase 7 must also fix `diamondFormula`** (missed in Phase 3 — still present in ModalSaturation.lean)
2. **Phase 9 scope clarification needed**: `SetMaximalConsistent` and `SetConsistent` are too widespread for direct rename; restrict Phase 9 to `temporally_coherent` only and create follow-up task for the broader naming
3. **Plan revision needed**: Update implementation-002.md Phase 9 scope to reflect restricted rename plan

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Phase-by-phase analysis (scope, difficulty, order) | completed | high |
| B | Task 970/971 overlap and sequencing | completed | high |

---

## References

- `specs/970_review_metalogic_for_publication/reports/research-002-teammate-a-findings.md`
- `specs/970_review_metalogic_for_publication/reports/research-002-teammate-b-findings.md`
- `specs/970_review_metalogic_for_publication/plans/implementation-002.md` (current plan)
- `specs/971_refactor_eliminate_bmcs_truth_at_layer/plans/implementation-001.md`
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean`
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
