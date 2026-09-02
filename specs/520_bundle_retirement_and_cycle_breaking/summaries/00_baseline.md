# Task 520 -- Phase 1 Baseline

Recorded at commit `2bd4dfba2` (post-task-519), before any Phase 2 edit.

## Gate state: ALL CHECKS PASSED

Command: `bash scripts/check-module-invariants.sh` (full, with build). Exit 0.

### C2 -- the four flagship axiom lines (verbatim)

```
'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Other load-bearing gate figures

| Check | Baseline |
|---|---|
| B0 | 1 Boneyard dir; 156 archived `.lean` excluded (590 total -> 434 live) |
| C4 | 1499 FormalSystem/BimodalTest import lines resolve |
| C5 | 1323 markdown files, 4 allowlisted |
| C6 | 17 unreachable live modules, all manifested; 15 compile-checked; 2 known-broken |
| C7 | 489 live `.lean` (434 FormalSystem / 54 Tests); 472 reachable, 17 unreachable; Metalogic 321 |
| C11 | 497 archived import lines in 156 archived files resolve, 7 waived |

## Confirmed counts

### 1. Extraction block -- 29 declarations across 3 ranges (CONFIRMED)

`FormalSystem/Metalogic/Bundle/CanonicalTaskRelation.lean`

- `:59-196` (13): `iterF`, `iter_F_zero`, `iter_F_succ`, `some_future_complexity`,
  `iter_F_complexity`, `iter_F_complexity_strictly_increasing`, `iter_F_injective`,
  `iter_F_one_eq_some_future`, `iter_F_f_nesting_depth`, `closureFBound`,
  `iter_F_exceeds_max_depth`, `iter_F_not_mem_closureWithNeg`, `iter_F_leaves_closure`
- `:557-561` (1): `iter_F_succ_eq`
- `:699-844` (15): `iterP`, `iter_P_zero`, `iter_P_succ`, `iter_P_some_past`, `iter_P_succ_eq`,
  `some_past_complexity`, `iter_P_complexity`, `iter_P_complexity_strictly_increasing`,
  `iter_P_injective`, `iter_P_one_eq_some_past`, `iter_P_p_nesting_depth`, `closurePBound`,
  `iter_P_exceeds_max_depth`, `iter_P_not_mem_closureWithNeg`, `iter_P_leaves_closure`

Total 29. Names match the plan exactly.

### 2. Purity of the block (CONFIRMED)

`grep -nE "SetMaximalConsistent|MaximalConsistent|Succ|GContent|FContent|HContent|PContent|FrameClass|Derivable|Consistent|Provable"` over each of the three ranges: **zero hits in all three**.

### 3. Saturation layer is fully dead (CONFIRMED)

Tree-wide grep over live `FormalSystem/` + `Tests/`, excluding `Bundle/ModalSaturation.lean`, for
`SaturatedBFMCS|IsModallySaturated|needs_modal_witness|saturated_modal_backward|diamond_eq|diamond_excludes_box_neg|diamond_and_not_psi_implies_neg|diamond_implies_psi_consistent|dniTheorem`:
**zero hits**. The 6th retirement stands.

### 4. Fully-qualified reference enumeration (AUTHORITATIVE -- 10 references, 6 modules)

The plan deliberately did not assert a count. Measured, over live `FormalSystem/` + `Tests/`:

| file:line | reference |
|---|---|
| `BXCanonical/Chronicle/ChronicleTypes.lean:224` | `...Bundle.axiom5NegativeIntrospection` |
| `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:587` | `...Bundle.SetMaximalConsistent.contrapositive` |
| `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:588` | `...Bundle.boxDneTheorem` |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean:1159` | `...Bundle.SetMaximalConsistent.contrapositive` |
| `BXCanonical/Chronicle/ChronicleToCountermodel.lean:1160` | `...Bundle.boxDneTheorem` |
| `BXCanonical/CompletenessDedekind.lean:478` | `...Bundle.boxDneTheorem` |
| `WeakCanonical/GroupModel/CountermodelBase.lean:298` | `...Bundle.SetMaximalConsistent.contrapositive` |
| `WeakCanonical/GroupModel/CountermodelBase.lean:299` | `...Bundle.boxDneTheorem` |
| `WeakCanonical/IntegerModel/ReynoldsBridge.lean:1118` | `...Bundle.SetMaximalConsistent.contrapositive` |
| `WeakCanonical/IntegerModel/ReynoldsBridge.lean:1119` | `...Bundle.boxDneTheorem` |

Not in the migrating set, and therefore untouched: `TruthLemma.lean:251,272` and
`RRelation.lean:659,694` name `...Bundle.neg_some_future_to_all_future_neg` /
`neg_some_past_to_all_past_neg`, both declared in the **surviving** `Bundle/WitnessSeed.lean`.

### 5. Unqualified consumer sites of the migrating names

| file:line | name |
|---|---|
| `Bundle/TemporalCoherence.lean:68,84,108,126,138` | `dneTheorem` |
| `BXCanonical/CanonicalModel.lean:839` | `SetMaximalConsistent.contrapositive` |
| `BXCanonical/CanonicalModel.lean:840` | `boxDneTheorem` |
| `BXCanonical/CompletenessDedekind.lean:477` | `SetMaximalConsistent.contrapositive` |
| `BXCanonical/Chronicle/MCSMixedCase.lean:58` | `SetMaximalConsistent.neg_box_implies_box_neg_box` |

9 consumer modules total (the 6 above plus `ChronicleTypes`, `ChronicleToCountermodel`,
`ChronicleToCountermodelBasic`, `CountermodelBase`, `ReynoldsBridge` -- counting distinct files:
`TemporalCoherence`, `CanonicalModel`, `CompletenessDedekind`, `ChronicleToCountermodel`,
`ChronicleToCountermodelBasic`, `CountermodelBase`, `ReynoldsBridge`, `ChronicleTypes`,
`MCSMixedCase` = **9**). CONFIRMED.

`negBoxToBoxNegBox`: every live cross-file call site (`CanonicalModel.lean:372,751`,
`ChronicleToCountermodelBasic.lean:335`, `Frame.lean:627`) resolves to the independent
`BXCanonical/Frame.lean:578` copy. The `Bundle` copy has **zero** live cross-file consumers,
only the internal use at `ModalSaturation.lean:517`. CONFIRMED.

### 6. Import inventory (CONFIRMED at 28)

**23 external archived** lines naming the 6 dead modules, across 14 archived files -- exactly the
list the plan enumerates (`CanonicalFrame` 6, `Construction` 2, `UntilSinceCoherence` 4,
`CanonicalTaskRelation` 4, `SuccRelation` 6, `ModalSaturation` 1).

**5 intra-set** live lines: `Construction.lean:8` (ModalSaturation), `UntilSinceCoherence.lean:8`
(SuccRelation), `CanonicalTaskRelation.lean:7,8` (SuccRelation, CanonicalFrame),
`SuccRelation.lean:8` (CanonicalFrame). The other intra-`Bundle/` imports in the retiring files
(`CanonicalFrame:7,8`, `SuccRelation:7,9`, `UntilSinceCoherence:7`, `ModalSaturation:7`,
`Construction:7`) name **surviving** modules and stay as they are.

**Live imports naming the 6**, to be removed:
`Bundle.lean:8,9,10,15,18,21` (6, plus the duplicate `FMCSDef` at `:11`/`:12`);
`BXCanonical/Frame.lean:11`; `Core/RestrictedMCS/Basic.lean:12`;
`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:9`;
plus two the plan's Phase 4 list does not name because Phase 3 removes them as consumer
re-points: `BXCanonical/Chronicle/ChronicleTypes.lean:12` and `Bundle/TemporalCoherence.lean:8`
(both `Bundle.ModalSaturation`).

### 7. Survivors each have a live importer outside `Bundle.lean` (CONFIRMED, 9/9)

| Module | Live importer(s) outside `Bundle.lean` and the dead set |
|---|---|
| `BFMCS` | `BXCanonical/CanonicalModel.lean`, `Bundle/TemporalCoherence.lean` |
| `FMCSDef` | `BXCanonical/CanonicalModel.lean`, `Bundle/BFMCS.lean`, `Bundle/LimitMCS.lean` |
| `LimitMCS` | `Bundle/LimitMCSCoherence.lean` |
| `LimitMCSCoherence` | `Bundle/RealExtension.lean` |
| `RealExtension` | `Bundle/RealExtensionBundle.lean` |
| `RealExtensionBundle` | 4 `BXCanonical/Chronicle/` modules |
| `TemporalCoherence` | `Algebraic/FlowFrame.lean`, `Chronicle/ChronicleMonadicBridge.lean`, `Bundle/RealExtensionBundle.lean` |
| `TemporalContent` | `Chronicle/ChronicleTypes.lean`, `BXCanonical/Frame.lean`, `WeakCanonical/ReflexiveCanonical.lean`, `Bundle/WitnessSeed.lean` |
| `WitnessSeed` | `WeakCanonical/TruthLemma.lean`, `BXCanonical/Frame.lean`, `Chronicle/RRelation.lean` |

### 8. Dead-set line counts (CONFIRMED at 2,735)

| File | Lines |
|---|---:|
| `CanonicalFrame.lean` | 312 |
| `Construction.lean` | 253 |
| `UntilSinceCoherence.lean` | 46 |
| `CanonicalTaskRelation.lean` | 1,050 |
| `SuccRelation.lean` | 553 |
| `ModalSaturation.lean` | 521 |
| **Total** | **2,735** |

### 9. `untl`/`snce` occurrences in the retiring files -- DIVERGENCE

| File | Plan asserts | Measured |
|---|---:|---:|
| `SuccRelation.lean` | 10 | **12** |
| `CanonicalFrame.lean` | 2 | 2 |
| `CanonicalTaskRelation.lean` | 2 | 2 |
| **Total** | **14** | **16** |

Command: `grep -o "untl\|snce" <file> | wc -l`. `Construction.lean`, `UntilSinceCoherence.lean`
and `ModalSaturation.lean` have zero.

**Refinement (measured after Phase 2, and this is what the Phase 5 carve-out must state).** The
gap above is a counting-unit difference plus a Phase-2 effect, not a disagreement:

- The plan's per-file figures are **lines**; mine were **occurrences**. `SuccRelation.lean` has
  **10 matching lines carrying 12 occurrences** (`:198` and `:360` each carry two).
- `CanonicalTaskRelation.lean`'s 2 occurrences (`:96`, `:744` at HEAD) are docstring mentions
  *inside the relocated block*. Phase 2 moved them to the live
  `Syntax/SubformulaClosure/IteratedTemporal.lean` (`:81`, `:234`), so they never reach the
  archive.

**What actually travels into `Boneyard/BundleDeadHalf/`: 14 occurrences across 12 lines in 2
files** -- `SuccRelation.lean` 12 occurrences / 10 lines, `CanonicalFrame.lean` 2 / 2. The
plan's total of 14 is therefore correct for the archived set; only its per-file split needed
adjusting.

## Divergences from the plan, reported before Phase 2 starts

1. **`untl`/`snce` per-file split needed adjusting; the archived total of 14 stands.**
   `SuccRelation.lean` has 12 occurrences across 10 lines, and `CanonicalTaskRelation.lean`'s 2
   travel to the live `IteratedTemporal.lean` in Phase 2 rather than to the archive. The Phase 5
   carve-out names `SuccRelation.lean` 12 and `CanonicalFrame.lean` 2 = 14, in 2 files.
2. **The fully-qualified reference enumeration is 10 references across 6 modules** -- neither the
   report's prose figure (7) nor its matrix figure (9). The plan anticipated this and made the
   enumeration authoritative; the table in section 4 above is that enumeration.
3. **Two live `Bundle.ModalSaturation` imports are not in the plan's Phase 4 removal list**
   (`ChronicleTypes.lean:12`, `TemporalCoherence.lean:8`). Both are consumer re-points and belong
   to Phase 3, consistent with the plan's own Phase 3 note that only `Bundle.lean` and
   `Construction.lean` should still import `ModalSaturation` after Phase 3.

Every other asserted count came back exactly as the plan states.
