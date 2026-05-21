# Task 184: Dead Code Tombstone Sweep -- Research Report

## Task 155 Overlap Analysis (Exclusion List)

Files actively modified by task 155 (MUST NOT touch):
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (in git status as modified)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (recent task 155 commits)

All other WeakCanonical files were touched by task 155 historically but are not currently in-flight. However, to be conservative, all `WeakCanonical/` files should be excluded from this sweep since task 155 is actively working in that area.

---

## 1. Tombstone Comment Catalog

### Classification Key
- **(a) Single-line note**: Brief 1-line comment explaining why something was removed. Low noise, OK to keep if informative.
- **(b) Multi-line explanation block**: 3+ lines explaining removal rationale. Should be in git history, not code.
- **(c) List of removed items**: Enumerates multiple deleted declarations. Pure noise, should delete.

---

### File: Completeness.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 22 | `2. **Archived**: Duration-based canonical model infrastructure (~2300 lines)` | (a) | KEEP -- part of module docstring explaining file structure |
| 364-367 | `-- Duplicate theorems removed (canonical versions in MCSProperties.lean):` + 3 items listed | (c) | REMOVE -- list of removed items, git history suffices |
| 522 | `requiring canonical frame and history constructions have been archived.` | (a) | KEEP -- part of section docstring |
| 525-526 | `-- SetMaximalConsistent.modal_saturation_forward removed ...` / `-- CanonicalWorldState was removed ...` | (c) | REMOVE -- two-line removal listing at end of file |

### File: Soundness.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 259-260 | `-- Note: temp_future_valid (TF axiom) removed -- TF is now derived from MF + T + Modal 4.` | (a) | REMOVE -- the theorem below it already establishes what's there; this note is noise |
| 686-693 | 8 lines: BX7a/BX8/BX9/until_guard REMOVED + archived location | (c) | REMOVE -- block of removed items with archive pointer |
| 808-820 | `/-! ## Legacy Discrete Axiom Validity Theorems (Removed)` doc section (13 lines) | (b) | REMOVE -- entire multi-line explanation block listing removed theorems |
| 855 | `-- NOTE: temp_k_dist and temp_4 removed as axiom constructors (Task 116)` | (a) | KEEP -- single explanatory note inside match block, aids readability |
| 872-873 | Two `-- NOTE:` lines about linear_until_a7a / until_elim removal | (a) | REMOVE -- inside match block but the cases no longer exist, these are vestigial |
| 921 | `-- NOTE: until_elim / since_elim / until_guard / since_guard removed (task 113)` | (a) | REMOVE -- repeated in 4 match blocks (also 970, 1073, 1246) |
| 970 | Same as 921 | (a) | REMOVE |
| 1073 | Same as 921 | (a) | REMOVE |
| 1246 | Same as 921 | (a) | REMOVE |

### File: SoundnessLemmas.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 159-188 | `/-! ## NOTE: Unprovable Theorem Removed` (30 lines) | (b) | REMOVE -- verbose explanation block. The lesson is valuable but belongs in research report or git history, not library code |
| 366 | `-- Note: swap_axiom_tf_valid removed -- TF is now derived from MF + T + Modal 4.` | (a) | REMOVE -- same note as Soundness.lean:259, redundant |

### File: BXCanonical/Chronicle/ChronicleTypes.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 44-46 | 3 lines in module docstring: BX9 REMOVED, until_guard REMOVED, rRelation removed | (a) | KEEP -- part of module docstring documenting semantic constraints |
| 172 | `Note: BX9 (until_elim: phi U psi -> phi ∨ psi) has been REMOVED (task 113).` | (a) | KEEP -- contextual note in section docstring |
| 601-602 | `-- rRelation_of_superset_mcs: REMOVED ...` / `-- rRelationSince_of_superset_mcs: REMOVED ...` | (c) | REMOVE |

### File: BXCanonical/Chronicle/PointInsertion.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 29-30 | 2 lines in module docstring: BX9 REMOVED, until_guard REMOVED | (a) | KEEP -- module docstring |
| 33-34 | `Several lemmas in this file are INVALID under open guard and retained as sorry stubs...` | (a) | KEEP -- module docstring |
| 179 | `-- until_elim_mcs: REMOVED (task 113 Phase 3). INVALID under open guard.` | (a) | REMOVE |
| 346 | `None of these axioms depend on BX9 (removed) or the T-axiom.` | (a) | KEEP -- part of docstring |
| 353-354 | `-- lemma_2_7_guard: REMOVED ... Depended on removed until_elim_mcs.` | (c) | REMOVE |
| 559-566 | 8 lines: rRelation_self_mcs, rRelationSince_self_mcs, lemma_2_6_full REMOVED | (c) | REMOVE |
| 1497-1502 | 6 lines: `-- REMOVED (Task 115): burgess_zeta_consistent, d0_guard...` + list | (c) | REMOVE |

### File: BXCanonical/Chronicle/RRelation.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 30-32 | Module docstring lines: BX9 REMOVED, until_guard REMOVED, INVALID stubs | (a) | KEEP -- module docstring |
| 64-67 | `WAS provable (via BX9). Under open guard (t,s), even this weaker statement is INVALID...` | (b) | KEEP -- part of section-level explanation that aids current code understanding |
| 72-78 | 4 separate `-- X: REMOVED ... INVALID under open guard.` lines | (c) | REMOVE |
| 107-108 | `-- since_disjunction_in_mcs: REMOVED ...` | (c) | REMOVE |
| 138-139 | `-- rRelation_of_subset_mcs: REMOVED ...` | (c) | REMOVE |
| 436-437 | `-- r3Relation_of_superset_mcs: REMOVED ...` | (c) | REMOVE |
| 1187 | `alone (until_guard axiom removed, task 113). Callers must provide η ∈ A` | (a) | KEEP -- part of theorem docstring |
| 1219-1228 | 10 lines: untl_absorb_nested/snce_absorb_nested/burgessR3_gamma... REMOVED/DELETED | (c) | REMOVE |

### File: BXCanonical/TruthLemma.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 33-35 | `The backward direction ... was removed: these had unsound signatures ...` | (a) | KEEP -- module docstring explaining current design |

### File: BXCanonical/CanonicalChain.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 14 | `- (Removed: left_mono_until_mcs/left_mono_since_mcs — unused dead code, task 135)` | (a) | REMOVE -- in module docstring bullet list, but it's about what's NOT here |
| 23 | `(BX9/BX9' removed as unsound). The delegation bridges are updated to match.` | (a) | KEEP -- describes current state |
| 40-41 | `-- NOTE: psi_imp_until_mcs / psi_imp_since_mcs REMOVED (task 113).` + explanation | (c) | REMOVE |

### File: BXCanonical/Frame.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 655-656 | `Note: BX9 (Until elimination for phi in w) was removed -- unsound under open guard (task 113). The return type no longer claims phi in w.` | (a) | KEEP -- part of section docstring explaining current API |
| 675 | `The return type no longer claims phi in w (BX9 was removed as unsound).` | (a) | KEEP -- theorem docstring |
| 695 | `Under open guard semantics, the return type does not claim phi in w (BX9' removed).` | (a) | KEEP -- theorem docstring |

### File: BXCanonical/Quasimodel/Realization.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 48-49 | `-- F_of_mem, P_of_mem: archived to Boneyard/BX1DependentCode/ (task 130).` | (c) | REMOVE |
| 149-150 | `-- g_content/h_content subset branches required BX1/BX1', removed under irreflexive semantics (task 113).` | (a) | REMOVE -- not useful context, the thing it explains is gone |
| 286 | `-- Under open guard (task 113), return types no longer claim phi in w (BX9 removed).` | (a) | KEEP -- contextual design note above delegation call |
| 296 | Same pattern as 286 | (a) | KEEP |

### File: BXCanonical/Quasimodel/Construction.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 112-115 | 4 lines: `-- NOTE: until_elim_mcs (BX9 at MCS level) removed ...` + explanation | (b) | REMOVE -- the theorem below (`self_accum_mcs`) speaks for itself |
| 146-147 | `-- NOTE: since_elim_mcs (BX9' at MCS level) removed ...` + explanation | (a) | REMOVE -- mirror of above |

### File: BXCanonical/Filtration/DefectChain.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 24-25 | `Note: defect_step_phi (BX9) and since_defect_step_phi (BX9') removed ...` | (a) | KEEP -- module docstring |
| 64-66 | `-- NOTE: defect_step_phi (BX9 at BXPoint level) removed ...` (3 lines) | (b) | REMOVE -- replaced by the theorem immediately below it |
| 100-101 | `-- NOTE: since_defect_step_phi (BX9' at BXPoint level) removed ...` (2 lines) | (a) | REMOVE -- same pattern |

### File: Core/RestrictedMCS.lean

| Line(s) | Content | Class | Verdict |
|----------|---------|-------|---------|
| 1364-1368 | 5 lines: `-- NOTE: neg_FF_implies_GG_neg_in_drm was removed (Task 167) because:` + 3 reasons | (b) | REMOVE -- rationale belongs in commit message/git history |

---

## 2. #check Statement Catalog

### Classification Key
- **(a) Pedagogical/example in docstring**: Inside ```` ```lean ```` block. KEEP.
- **(b) Debugging leftover**: Standalone check with no docstring context. REMOVE.
- **(c) API showcase in library code**: Tests typeclass/API in library file. Move to Examples or REMOVE.

| File | Line(s) | Content | Class | Verdict |
|------|----------|---------|-------|---------|
| Decidability.lean | 39-41 | `#check decide` / `isValid` / `isSatisfiable` | (a) | KEEP -- inside module docstring code block |
| Semantics.lean | 67, 70, 76 | `#check (⊨ ...)` / `#check truth_at ...` | (a) | KEEP -- inside module docstring code block |
| Bimodal.lean | 52 | `#check perpetuity_1` | (a) | KEEP -- inside module docstring code block |
| Theorems.lean | 49-50, 55-56, 61-62 | `#check imp_trans` / `ecq` / `t_box_to_diamond` etc. | (a) | KEEP -- inside module docstring code block |
| Automation/Tactics.lean | 1378-1380 | `#check (SearchConfig.default : SearchConfig)` etc. | (c) | REMOVE -- test-area checks, not pedagogical |
| FrameConditions/FrameClass.lean | 201-203 | `#check (inferInstance : LinearTemporalFrame Int)` etc. | (c) | REMOVE -- typeclass inference verification, move to test or remove |

**Summary**: 6 #check statements to remove (Tactics.lean:1378-1380, FrameClass.lean:201-203). The remaining 13 are inside doc comment code blocks and should stay.

---

## 3. Stale TODO Analysis

### Tactics.lean line 498
```lean
-- TODO: BX refactor - temp_4 axiom removed, must derive from BX1
throwError "temp_4_tactic: temp_4 axiom removed in BX refactor, derive from BX1"
```

**Assessment**: This tactic (`temp_4_tactic`) is a dead tactic that always throws an error. The axiom `temp_4` was removed in the BX refactor and the tactic was left as a stub. The TODO suggests deriving it from BX1, but BX1 itself was also removed (irreflexive semantics, task 113). This entire tactic definition (lines ~474-515) is dead code.

**Recommendation**: Remove the entire `temp_4_tactic` elab definition. If it has callers, they will fail at build time and can be addressed. Alternatively, track as a separate cleanup task.

### Tactics.lean line 543
```lean
-- TODO: BX refactor - temp_a axiom removed, must derive from BX4
throwError "temp_a_tactic: temp_a axiom removed in BX refactor, derive from BX4"
```

**Assessment**: Same pattern as above. The `temp_a_tactic` (lines ~517-555) always throws an error. The TODO is stale since the derivation from BX4 is already handled elsewhere (the temp_a axiom is now derived, see `temp_a_dual_valid` in Soundness.lean).

**Recommendation**: Remove the entire `temp_a_tactic` elab definition. Both are error-only stubs that cannot be used.

---

## 4. Completeness.lean Removal Blocks

### Lines 364-367
```lean
-- Duplicate theorems removed (canonical versions in MCSProperties.lean):
-- - SetMaximalConsistent.all_future_all_future: canonical version in MCSProperties.lean
-- - temp_4_past: canonical version in MCSProperties.lean
-- - SetMaximalConsistent.all_past_all_past: canonical version in MCSProperties.lean
```

**Assessment**: Pure noise. These list what was moved. The canonical versions already exist in `MCSProperties.lean` and git history records the move.

**Verdict**: REMOVE (4 lines).

### Lines 525-526
```lean
-- SetMaximalConsistent.modal_saturation_forward removed (thin alias for SetMaximalConsistent.box_closure)
-- CanonicalWorldState was removed (duplicate of CanonicalMCS in CanonicalFMCS.lean)
```

**Assessment**: These are at the very end of the file (line 528 is `end Bimodal.Metalogic`). They document what was cleaned up but provide no value to current readers.

**Verdict**: REMOVE (2 lines).

---

## 5. Safe Removal Batches

### Batch 1: #check Statements (Low risk, 6 lines)
- `Theories/Bimodal/Automation/Tactics.lean` lines 1378-1380
- `Theories/Bimodal/FrameConditions/FrameClass.lean` lines 201-203 (and the `/-! ## Typeclass Inference Verification for Int -/` header on line 198)

**Verification**: `lake build`

### Batch 2: Single-line Tombstones (Medium volume, isolated)
- `Soundness.lean`: lines 259-260, 686-693, 872-873, 921, 970, 1073, 1246
- `SoundnessLemmas.lean`: line 366
- `CanonicalChain.lean`: lines 14, 40-41
- `Realization.lean`: lines 48-49, 149-150
- `Construction.lean`: lines 112-115, 146-147
- `PointInsertion.lean`: line 179

**Verification**: `lake build`

### Batch 3: Multi-line Blocks (Higher risk -- may affect doc formatting)
- `Soundness.lean`: lines 808-820 (Legacy section header)
- `SoundnessLemmas.lean`: lines 159-188 (Unprovable theorem explanation)
- `RestrictedMCS.lean`: lines 1364-1368

**Verification**: `lake build`

### Batch 4: Completeness.lean Cleanup
- Lines 364-367
- Lines 525-526

**Verification**: `lake build`

### Batch 5: RRelation.lean and PointInsertion.lean Tombstone Lists
- `RRelation.lean`: lines 72-78, 107-108, 138-139, 436-437, 1219-1228
- `PointInsertion.lean`: lines 353-354, 559-566, 1497-1502
- `ChronicleTypes.lean`: lines 601-602
- `DefectChain.lean`: lines 64-66, 100-101

**Verification**: `lake build`

### Batch 6: Dead Tactic Removal (Largest change, most risky)
- `Tactics.lean`: Remove `temp_4_tactic` definition (lines ~474-515)
- `Tactics.lean`: Remove `temp_a_tactic` definition (lines ~517-555)

**Verification**: `lake build` -- check for downstream callers first with `grep -rn "temp_4_tactic\|temp_a_tactic" Theories/`

---

## 6. Summary Statistics

| Category | Total Found | To Remove | To Keep |
|----------|-------------|-----------|---------|
| Tombstone comments (class c: lists) | ~25 blocks | 25 | 0 |
| Tombstone comments (class b: multi-line) | ~6 blocks | 6 | 0 |
| Tombstone comments (class a: single-line) | ~25 | 12 | 13 |
| #check statements | 19 | 6 | 13 |
| Stale TODOs | 2 | 2 | 0 |
| Dead tactic definitions | 2 | 2 | 0 |

**Total lines to remove**: approximately 120-140 lines across 12 files.

**Files excluded (task 155)**: All files under `WeakCanonical/` directory.

---

## 7. Recommended Execution Order

1. Batch 1 (trivial, instant verification)
2. Batch 4 (small, self-contained file)
3. Batch 2 (many files but single lines, low format risk)
4. Batch 5 (chronicle/filtration area, moderate volume)
5. Batch 3 (multi-line blocks require careful line-range deletions)
6. Batch 6 (dead tactics -- grep for callers first)

Each batch should be committed separately with message `task 184: batch N -- {description}`.
