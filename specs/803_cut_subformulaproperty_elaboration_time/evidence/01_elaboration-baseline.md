# Elaboration Evidence: SubformulaProperty.lean

Before/after evidence record for task 803. Module under measurement:
`FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean`.

## 0. Result

| Measure | Before | After | Method |
|---|---|---|---|
| Heartbeats, 36 per-rule theorems summed | 34,095,081 | 79,799 | `#count_heartbeats` per declaration, `set_option Elab.async false`, in-module-context probes (section 1) |
| Heartbeats, per theorem | 858,832 - 2,085,983 | 167 - 6,639 | same |
| Module time as Lake reports it in a full build | 478s, 438s (two builds) | 2.7s, 3.2s (two builds) | `Built …SubformulaProperty (Ns)` line of the guarded full build log, same machine, same day |
| Cumulative `simp` time, single-module profile | 14,987.6s (research report) | 4.03s | `lake env lean -Dprofiler=true -Dprofiler.threshold=200 --stats` through the guard |
| Wall-clock of that single-module profile run | 499s (research report) | 5s | guard `start_epoch`/`end_epoch` |
| `set_option maxHeartbeats` lines in the module | 36 | 0 | `grep -c maxHeartbeats` |

The summed heartbeat reduction is measured, not projected: 34,095,081 -> 79,799, a factor of 427
(99.77 percent). Per theorem the factor runs from 134 (`untlNeg`) to 12,491 (`serialityRule`). All
36 conversions landed; there is no fallback set.

Heartbeats are the evidence of record. The Lake and wall-clock rows are context: the "before"
Lake figures were taken with every per-rule theorem elaborating in parallel on 24 cores while the
rest of the build competed for them, and the two profile rows compare a research-phase run with a
run taken here.

## 1. Machine context and method

- Machine: 24 cores (`nproc`), 30 GiB RAM, Linux; Lean v4.33.0-rc1 (`lean-toolchain`).
- Base commit for every "before" figure: `013dd7368` (HEAD at capture, 2026-11-13).
- Other `lean` workers live at baseline capture: none (`pgrep -c lean` = 0 before launch); the
  only concurrent load was this capture's own six probe processes.
- Heartbeat method: one probe file per per-rule theorem. Each probe is the module's own text with
  the other 35 per-rule theorems and the `Combined` section deleted, `import
  Mathlib.Util.CountHeartbeats` and `set_option Elab.async false` added after the imports, and
  `#count_heartbeats in` prefixed to the target declaration. The probe therefore elaborates the
  target in the module's own context (same `open`s, same section variables), which avoids the
  `Formula.subformulas` ambiguity the research report's `lean_run_code` probes hit.
- Invocation: the Lake environment was captured once through the guard
  (`bash .claude/scripts/lake-build-guard.sh build --timeout 60 -- env printenv`), and each probe
  was then elaborated by the toolchain's `lean` binary directly under that environment
  (`LEAN_PATH`, `LD_LIBRARY_PATH`, `LEAN_SYSROOT`), six processes in parallel. No `lake`
  process ran during the probes, so the build guard's lock was not held and not bypassed.
- Every figure below was taken under `set_option Elab.async false`. No figure is near 30.
- Wall-clock seconds are reported as context only; heartbeats are the evidence of record.

## 2. Scope-hypothesis confirmation (carried vs measured)

| Quantity | Carried from report | Measured at capture | Agree |
|---|---|---|---|
| per-rule theorems (`^theorem applyRule_.*_closed`, excluding the assembly) | 36 | 36 | yes |
| assembly theorem `applyRule_subformula_closed` | 1 | 1 | yes |
| `applyRule.eq_N` constants | 38 | 38 (`eq_39`, `eq_40` probed: MISSING) | yes |
| `set_option maxHeartbeats 1200000` lines | 34 | 34 | yes |
| `set_option maxHeartbeats 3000000` lines | 2 | 2 | yes |

Premise re-validation of the task description's figures: the 1103s Lake-log figure and the
414-of-2848 job counts are historical build-log readings that this capture did not re-measure and
does not rely on. What this capture did measure: a single per-rule theorem costs 43-67s
single-threaded and about 0.87-0.89M heartbeats (2.09M for the two late arms), which agrees with
the module's own inline estimates and with the research report's three probes.

## 3. Axiom profiles before (all 37 declarations)

`#print axioms` for each of the 36 per-rule theorems and `applyRule_subformula_closed`, probe
importing the built module. Every one of the 37 reports exactly
`[propext, Classical.choice, Quot.sound]`. Verbatim output:

```
'FormalSystem.Metalogic.Decidability.applyRule_andPos_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_andNeg_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_orPos_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_orNeg_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_impPos_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_impNeg_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_negPos_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_negNeg_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_boxTemporal_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_denseIndicatorClosure_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_serialityRule_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_timeLinearity_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_boxPos_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_diamondNeg_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_allFuturePos_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_allPastPos_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_someFutureNeg_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_somePastNeg_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_boxNeg_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_diamondPos_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_allFutureNeg_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_allPastNeg_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_someFuturePos_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_somePastPos_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_untlPos_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_sncePos_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_untlNeg_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_snceNeg_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_priorUZ_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_priorSZ_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_z1Rule_closed' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_priorUGap_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_priorSGap_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_sepRule_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_densityRule_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_orderTrichotomy_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
'FormalSystem.Metalogic.Decidability.applyRule_subformula_closed' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
```

## 4. Sorry count before

`bash .claude/scripts/lean-sorry-census.sh` over the two files in scope: `sorry_count: 0`
(`Tableau.lean`: 0, `SubformulaProperty.lean`: 0). By content: `grep -c '\bsorry\b'` returns 0
for both files.

## 5. Heartbeat table

Columns: `before` = base commit; `after R1` = body converted to wrapper-routed equation-lemma
rewrite; `R3 trial, not landed` = the same body with the propagation block's `simp_all [...]` and
`by simp` replaced by `simp only [...]` and `contradiction`, measured on a scratch copy of the
module; the working tree never carried it (see section 6).
`secs` is single-process wall-clock for the whole probe file (import + preamble + target),
context only.

| # | Theorem | before (hb) | before secs | after R1 (hb) | R3 trial, not landed (hb) |
|---|---|---|---|---|---|
| 1 | `applyRule_andPos_closed` | 882869 | 43 | 1376 | n/a |
| 2 | `applyRule_andNeg_closed` | 890965 | 49 | 1447 | n/a |
| 3 | `applyRule_orPos_closed` | 882968 | 58 | 1400 | n/a |
| 4 | `applyRule_orNeg_closed` | 890289 | 59 | 1421 | n/a |
| 5 | `applyRule_impPos_closed` | 858832 | 56 | 1515 | n/a |
| 6 | `applyRule_impNeg_closed` | 872986 | 48 | 1492 | n/a |
| 7 | `applyRule_negPos_closed` | 881963 | 45 | 1356 | n/a |
| 8 | `applyRule_negNeg_closed` | 889599 | 46 | 1402 | n/a |
| 9 | `applyRule_boxTemporal_closed` | 869716 | 44 | 1543 | n/a |
| 10 | `applyRule_denseIndicatorClosure_closed` | 879937 | 55 | 1226 | n/a |
| 11 | `applyRule_serialityRule_closed` | 2085983 | 111 | 167 | n/a |
| 12 | `applyRule_timeLinearity_closed` | 2085413 | 109 | 176 | n/a |
| 13 | `applyRule_boxPos_closed` | 868669 | 51 | 1788 | n/a |
| 14 | `applyRule_diamondNeg_closed` | 890346 | 63 | 1794 | n/a |
| 15 | `applyRule_allFuturePos_closed` | 868179 | 63 | 1799 | n/a |
| 16 | `applyRule_allPastPos_closed` | 867305 | 54 | 1799 | n/a |
| 17 | `applyRule_someFutureNeg_closed` | 889622 | 57 | 1803 | n/a |
| 18 | `applyRule_somePastNeg_closed` | 888845 | 52 | 1803 | n/a |
| 19 | `applyRule_boxNeg_closed` | 883992 | 52 | 2258 | 2204 |
| 20 | `applyRule_diamondPos_closed` | 884441 | 67 | 2185 | 2132 |
| 21 | `applyRule_allFutureNeg_closed` | 886520 | 66 | 3111 | 3032 |
| 22 | `applyRule_allPastNeg_closed` | 887427 | 66 | 3111 | 3031 |
| 23 | `applyRule_someFuturePos_closed` | 884420 | 50 | 3114 | 3035 |
| 24 | `applyRule_somePastPos_closed` | 883648 | 50 | 3114 | 3035 |
| 25 | `applyRule_untlPos_closed` | 884453 | 50 | 5053 | 4870 |
| 26 | `applyRule_sncePos_closed` | 883444 | 52 | 5053 | 4870 |
| 27 | `applyRule_untlNeg_closed` | 893772 | 59 | 6639 | 6829 |
| 28 | `applyRule_snceNeg_closed` | 892568 | 61 | 6639 | 6830 |
| 29 | `applyRule_priorUZ_closed` | 876360 | 57 | 1420 | n/a |
| 30 | `applyRule_priorSZ_closed` | 875591 | 64 | 1420 | n/a |
| 31 | `applyRule_z1Rule_closed` | 864804 | 57 | 2048 | n/a |
| 32 | `applyRule_priorUGap_closed` | 875487 | 50 | 1631 | n/a |
| 33 | `applyRule_priorSGap_closed` | 874545 | 49 | 1631 | n/a |
| 34 | `applyRule_sepRule_closed` | 873857 | 55 | 1642 | n/a |
| 35 | `applyRule_densityRule_closed` | 866915 | 49 | 2293 | 2343 |
| 36 | `applyRule_orderTrichotomy_closed` | 878351 | 50 | 2130 | n/a |

Cross-checks against the research report's three probes (not substitutes for the fresh figures):
`andPos` 882,869 vs 882,487 (+0.04%); `serialityRule` 2,085,983 vs 2,084,589 (+0.07%); `boxNeg`
883,992 vs 885,047 (-0.12%). All within a fraction of a percent.

Baseline total over the 36 per-rule theorems: 34095081 heartbeats; summed single-process probe
wall-clock 2067 s (each probe also pays import and preamble, a few seconds).

## 6. The propagation-block tightening (R3): measured, not landed

After all 36 conversions the eleven theorems that route through `mem_filterMap_sub` (the ten
fresh-witness rules and `densityRule`) cost 2,185 to 6,639 heartbeats each. The research report's
R3 premise was that the block's full-simp-set closer dominates that residue, resting on a
27,178-heartbeat post-conversion figure for `boxNeg`. In module context `boxNeg` measures 2,258
after conversion, so that figure was itself part of the report probe's ambiguity artifact.

The tightened block was written and measured on a scratch copy (11 call sites rewritten, every
probe compiled clean):

| Theorem | after R1 (landed) | R3 trial | delta |
|---|---|---|---|
| `boxNeg` | 2258 | 2204 | -54 |
| `diamondPos` | 2185 | 2132 | -53 |
| `allFutureNeg` | 3111 | 3032 | -79 |
| `allPastNeg` | 3111 | 3031 | -80 |
| `someFuturePos` | 3114 | 3035 | -79 |
| `somePastPos` | 3114 | 3035 | -79 |
| `untlPos` | 5053 | 4870 | -183 |
| `sncePos` | 5053 | 4870 | -183 |
| `untlNeg` | 6639 | 6829 | +190 |
| `snceNeg` | 6639 | 6830 | +191 |
| `densityRule` | 2293 | 2343 | +50 |
| **sum** | **42570** | **42211** | **-359 (-0.8%)** |

The tightening moves each theorem by at most 3.6 percent, with mixed sign, and the eleven together
by 0.8 percent: 359 heartbeats against a module baseline of 34,095,081. The block is not the
dominant residual cost, so the phase's premise does not hold and the block was left as it is.

## 7. Heartbeat ceilings removed

The module carried 34 `set_option maxHeartbeats 1200000 in` and two `set_option maxHeartbeats
3000000 in` lines. All 36 are deleted, together with the two `set_option linter.unusedTactic false
in` lines on `untlNeg`/`snceNeg`. `grep -c 'maxHeartbeats' <module>` returns 0, and the module
builds green at the 200,000 default in the guarded full build (exit 0, 0 errors, no warning on the
module). That is evidence of the reduction independent of every table in this file: a declaration
needing more than 200,000 heartbeats would fail that build.

One option was added: `set_option linter.style.longFile 1700` after the module docstring. The
explicit proofs are longer than the cascade scripts (1,467 -> 1,617 lines), and the repository's
default limit is 1,500.

## 8. Cumulative profiling blocks

Before — from `reports/01_cut-subformulaproperty-elaboration-time.md` (2026-11-05, same machine,
`lake env lean -Dprofiler=true -Dprofiler.threshold=200 --stats` through the guard, wall 499s, other
`lean` workers live). This task's Phase 1 did not re-run the baseline profile; the per-declaration
heartbeat baselines in section 5 are this task's own "before".

```
cumulative profiling times:
  simp                  1.52e+04 s     <-- 14,987.6 s summed over 1348 calls >200ms
  blocked (unaccounted)     73.4 s
  tactic execution         108   s
  type checking             20.9 s
  congr simp thm            15.6 s
  instantiate metavars       2.49s
  import                     1.55s
  elaboration                1.72s
```

After — this task, 2026-11-13, HEAD `915bb200d`, same invocation through the guard
(`--no-share`), exit 0, wall 5s by the guard's own `start_epoch`/`end_epoch`
(1794597418 -> 1794597423). The only entry above the 200ms
threshold in the whole log is `import took 729ms`; there is no `simp` entry above it at all
(1348 before).

```
cumulative profiling times:
	attribute application 2.11ms
	blocked (unaccounted) 448ms
	compilation (IR) 4.62ms
	compilation (LCNF base) 18.5ms
	compilation (LCNF impure) 21.5ms
	compilation (LCNF mono) 35.4ms
	congr simp thm 43.3ms
	dsimp 56.3ms
	elaboration 449ms
	fix level params 5.68ms
	import 729ms
	initialization 27ms
	instantiate metavars 53.6ms
	interpretation 1.09s
	let-to-have transformation 1.65ms
	linting 243ms
	module linting 0.00265ms
	overlappingInstancesLinter 42.1ms
	parsing 74.4ms
	process pre-definitions 93.7ms
	share common exprs 50.9ms
	simp 4.03s
	tactic execution 9.88s
	tacticAnalysis 255ms
	type checking 303ms
	typeclass inference 396ms
```

## 9. Axiom profiles after, and the diff

`#print axioms` re-run for the same 37 declarations against the final build. `diff` of the Phase 1
output (section 3) against the new output is empty: all 37 still report exactly
`[propext, Classical.choice, Quot.sound]`.

The 38 wrappers added to `Tableau.lean` are new declarations and have no "before". Each reports
`[propext]`, which is exactly what the generated lemma it restates reports
(`applyRule.eq_1`, `applyRule.eq_38` and `applyRule` itself: `[propext]`), so the wrappers add no
axiom dependency of their own. Verbatim:

```
'FormalSystem.Metalogic.Decidability.applyRule_andPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_andNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_orPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_orNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_impPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_impNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_negPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_negNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_boxPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_boxNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_diamondPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_diamondNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_boxTemporal_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_allFuturePos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_allFutureNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_allPastPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_allPastNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_someFuturePos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_someFutureNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_somePastPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_somePastNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_untlPos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_sncePos_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_untlNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_snceNeg_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_orderTrichotomy_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_denseIndicatorClosure_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_densityRule_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_priorUZ_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_priorSZ_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_z1Rule_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_z1Rule_offPattern_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_priorUGap_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_priorSGap_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_sepRule_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_serialityRule_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_timeLinearity_arm_eq' depends on axioms: [propext]
'FormalSystem.Metalogic.Decidability.applyRule_offArm_eq' depends on axioms: [propext]
```

## 10. Statement fidelity and remaining gates

- Statements: the 36 per-rule statements (text from `theorem` through `:= by`) are identical
  between base commit `013dd7368` and the final tree, and everything from
  `theorem applyRule_subformula_closed` to the end of the file is byte-identical. The list of
  declaration header lines in the module is unchanged (73 before, 73 after).
- `sorry`: `lean-sorry-census.sh` over both edited files reports `sorry_count: 0`;
  `grep -c '\bsorry\b'` is 0 for both.
- `bash scripts/check-module-invariants.sh`: `ALL CHECKS PASSED`, exit 0 (full mode, with build).
- `bash .claude/scripts/check-task-references.sh <file>`: exit 0 for each of the two edited files.
- Guarded full build: `Build completed successfully (2975 jobs)`, exit 0, 0 `error:` lines, no
  warning; `.olean` newer than source for `Tableau` and `SubformulaProperty`.
- Whole-build wall-clock, context only: the first build after the Phase 2 edit took 1134s; the
  final build, which rebuilt the same set (`Tableau.lean` and everything downstream), took 668s.

## Appendix A. The 38 equation-lemma types (verbatim, `open`ed namespaces for brevity)

Enumerated by `realizeGlobalConstNoOverloadCore` on
`FormalSystem.Metalogic.Decidability.applyRule.eq_N` for `N` in 1..40 after
`import FormalSystem.Metalogic.Decidability.Tableau`, printed with `Meta.ppExpr`.

```
### eq_1
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.andPos sf branch timeOrd =
      match asAnd? sf.formula with
      | some (ψ, χ) => (RuleResult.linear [SignedFormula.pos ψ sf.label, SignedFormula.pos χ sf.label], timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_2
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.neg →
    applyRule TableauRule.andNeg sf branch timeOrd =
      match asAnd? sf.formula with
      | some (ψ, χ) => (RuleResult.branching [[SignedFormula.neg ψ sf.label], [SignedFormula.neg χ sf.label]], timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_3
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.orPos sf branch timeOrd =
      match asOr? sf.formula with
      | some (ψ, χ) => (RuleResult.branching [[SignedFormula.pos ψ sf.label], [SignedFormula.pos χ sf.label]], timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_4
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.neg →
    applyRule TableauRule.orNeg sf branch timeOrd =
      match asOr? sf.formula with
      | some (ψ, χ) => (RuleResult.linear [SignedFormula.neg ψ sf.label, SignedFormula.neg χ sf.label], timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_5
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ χ : Formula),
  sf.sign = Sign.pos →
    sf.formula = ψ.imp χ →
      applyRule TableauRule.impPos sf branch timeOrd =
        (RuleResult.branching [[SignedFormula.neg ψ sf.label], [SignedFormula.pos χ sf.label]], timeOrd)
### eq_6
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ χ : Formula),
  sf.sign = Sign.neg →
    sf.formula = ψ.imp χ →
      applyRule TableauRule.impNeg sf branch timeOrd =
        (RuleResult.linear [SignedFormula.pos ψ sf.label, SignedFormula.neg χ sf.label], timeOrd)
### eq_7
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.negPos sf branch timeOrd =
      match asNeg? sf.formula with
      | some ψ => (RuleResult.linear [SignedFormula.neg ψ sf.label], timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_8
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.neg →
    applyRule TableauRule.negNeg sf branch timeOrd =
      match asNeg? sf.formula with
      | some ψ => (RuleResult.linear [SignedFormula.pos ψ sf.label], timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_9
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ : Formula),
  sf.sign = Sign.pos →
    sf.formula = ψ.box →
      applyRule TableauRule.boxPos sf branch timeOrd =
        if
            (List.filterMap
                  (fun w =>
                    have newSf := SignedFormula.pos ψ { world := w, time := sf.label.time };
                    if branch.contains newSf = true then none else some newSf)
                  branch.knownWorlds).isEmpty =
              true then
          (RuleResult.notApplicable, timeOrd)
        else
          (RuleResult.persistent
              (List.filterMap
                (fun w =>
                  have newSf := SignedFormula.pos ψ { world := w, time := sf.label.time };
                  if branch.contains newSf = true then none else some newSf)
                branch.knownWorlds),
            timeOrd)
### eq_10
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ : Formula),
  sf.sign = Sign.neg →
    sf.formula = ψ.box →
      applyRule TableauRule.boxNeg sf branch timeOrd =
        (RuleResult.linear
            (SignedFormula.neg ψ { world := branch.nextWorld, time := sf.label.time } ::
                List.filterMap
                  (fun bsf =>
                    match bsf.formula with
                    | inner.box =>
                      have prop := SignedFormula.pos inner { world := branch.nextWorld, time := bsf.label.time };
                      if branch.contains prop = true then none else some prop
                    | x => none)
                  branch.boxPosFormulas ++
              List.filterMap
                (fun dsf =>
                  match dsf.formula with
                  | (inner.imp Formula.bot).box.imp Formula.bot =>
                    have prop := SignedFormula.neg inner { world := branch.nextWorld, time := dsf.label.time };
                    if branch.contains prop = true then none else some prop
                  | x => none)
                branch.diamondNegFormulas),
          timeOrd)
### eq_11
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.diamondPos sf branch timeOrd =
      match asDiamond? sf.formula with
      | some ψ =>
        have freshWorld := branch.nextWorld;
        have freshLabel := { world := freshWorld, time := sf.label.time };
        have witness := SignedFormula.pos ψ freshLabel;
        have boxProps :=
          List.filterMap
            (fun bsf =>
              match bsf.formula with
              | inner.box =>
                have prop := SignedFormula.pos inner { world := freshWorld, time := bsf.label.time };
                if branch.contains prop = true then none else some prop
              | x => none)
            branch.boxPosFormulas;
        have diaProps :=
          List.filterMap
            (fun dsf =>
              match dsf.formula with
              | (inner.imp Formula.bot).box.imp Formula.bot =>
                have prop := SignedFormula.neg inner { world := freshWorld, time := dsf.label.time };
                if branch.contains prop = true then none else some prop
              | x => none)
            branch.diamondNegFormulas;
        (RuleResult.linear (witness :: boxProps ++ diaProps), timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_12
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.neg →
    applyRule TableauRule.diamondNeg sf branch timeOrd =
      match asDiamond? sf.formula with
      | some ψ =>
        have worlds := branch.knownWorlds;
        have newFormulas :=
          List.filterMap
            (fun w =>
              have newSf := SignedFormula.neg ψ { world := w, time := sf.label.time };
              if branch.contains newSf = true then none else some newSf)
            worlds;
        if newFormulas.isEmpty = true then (RuleResult.notApplicable, timeOrd)
        else (RuleResult.persistent newFormulas, timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_13
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ : Formula),
  sf.sign = Sign.pos →
    sf.formula = ψ.box →
      applyRule TableauRule.boxTemporal sf branch timeOrd =
        if
            (List.filter (fun sf => !branch.contains sf)
                  [SignedFormula.pos ψ.allFuture sf.label, SignedFormula.pos ψ.allPast sf.label]).isEmpty =
              true then
          (RuleResult.notApplicable, timeOrd)
        else
          (RuleResult.persistent
              (List.filter (fun sf => !branch.contains sf)
                [SignedFormula.pos ψ.allFuture sf.label, SignedFormula.pos ψ.allPast sf.label]),
            timeOrd)
### eq_14
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ : Formula),
  sf.sign = Sign.pos →
    sf.formula = ((Formula.bot.imp Formula.bot).untl (ψ.imp Formula.bot)).imp Formula.bot →
      applyRule TableauRule.allFuturePos sf branch timeOrd =
        if
            (List.filterMap
                  (fun t' =>
                    have newSf := SignedFormula.pos ψ { world := sf.label.world, time := t' };
                    if branch.contains newSf = true then none else some newSf)
                  (timeOrd.futureOf sf.label.time)).isEmpty =
              true then
          (RuleResult.notApplicable, timeOrd)
        else
          (RuleResult.persistent
              (List.filterMap
                (fun t' =>
                  have newSf := SignedFormula.pos ψ { world := sf.label.world, time := t' };
                  if branch.contains newSf = true then none else some newSf)
                (timeOrd.futureOf sf.label.time)),
            timeOrd)
### eq_15
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ : Formula),
  sf.sign = Sign.neg →
    sf.formula = ((Formula.bot.imp Formula.bot).untl (ψ.imp Formula.bot)).imp Formula.bot →
      applyRule TableauRule.allFutureNeg sf branch timeOrd =
        (RuleResult.linear
            (SignedFormula.neg ψ { world := sf.label.world, time := branch.nextTime } ::
                  List.filterMap
                    (fun gsf =>
                      match gsf.formula with
                      | ((Formula.bot.imp Formula.bot).untl (inner.imp Formula.bot)).imp Formula.bot =>
                        if (gsf.label.time == sf.label.time) = true then
                          have prop := SignedFormula.pos inner { world := gsf.label.world, time := branch.nextTime };
                          if branch.contains prop = true then none else some prop
                        else none
                      | x => none)
                    branch.allFuturePosFormulas ++
                List.filterMap
                  (fun fsf =>
                    match fsf.formula with
                    | (Formula.bot.imp Formula.bot).untl inner =>
                      if (fsf.label.time == sf.label.time) = true then
                        have prop := SignedFormula.neg inner { world := fsf.label.world, time := branch.nextTime };
                        if branch.contains prop = true then none else some prop
                      else none
                    | x => none)
                  branch.someFutureNegFormulas ++
              FormalSystem.Metalogic.Decidability.boxDiamondPersistence✝ branch sf.label.world sf.label.time
                branch.nextTime),
          timeOrd.addFuture sf.label.time branch.nextTime)
### eq_16
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ : Formula),
  sf.sign = Sign.pos →
    sf.formula = ((Formula.bot.imp Formula.bot).snce (ψ.imp Formula.bot)).imp Formula.bot →
      applyRule TableauRule.allPastPos sf branch timeOrd =
        if
            (List.filterMap
                  (fun t' =>
                    have newSf := SignedFormula.pos ψ { world := sf.label.world, time := t' };
                    if branch.contains newSf = true then none else some newSf)
                  (timeOrd.pastOf sf.label.time)).isEmpty =
              true then
          (RuleResult.notApplicable, timeOrd)
        else
          (RuleResult.persistent
              (List.filterMap
                (fun t' =>
                  have newSf := SignedFormula.pos ψ { world := sf.label.world, time := t' };
                  if branch.contains newSf = true then none else some newSf)
                (timeOrd.pastOf sf.label.time)),
            timeOrd)
### eq_17
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ : Formula),
  sf.sign = Sign.neg →
    sf.formula = ((Formula.bot.imp Formula.bot).snce (ψ.imp Formula.bot)).imp Formula.bot →
      applyRule TableauRule.allPastNeg sf branch timeOrd =
        (RuleResult.linear
            (SignedFormula.neg ψ { world := sf.label.world, time := branch.nextTime } ::
                  List.filterMap
                    (fun hsf =>
                      match hsf.formula with
                      | ((Formula.bot.imp Formula.bot).snce (inner.imp Formula.bot)).imp Formula.bot =>
                        if (hsf.label.time == sf.label.time) = true then
                          have prop := SignedFormula.pos inner { world := hsf.label.world, time := branch.nextTime };
                          if branch.contains prop = true then none else some prop
                        else none
                      | x => none)
                    branch.allPastPosFormulas ++
                List.filterMap
                  (fun psf =>
                    match psf.formula with
                    | (Formula.bot.imp Formula.bot).snce inner =>
                      if (psf.label.time == sf.label.time) = true then
                        have prop := SignedFormula.neg inner { world := psf.label.world, time := branch.nextTime };
                        if branch.contains prop = true then none else some prop
                      else none
                    | x => none)
                  branch.somePastNegFormulas ++
              FormalSystem.Metalogic.Decidability.boxDiamondPersistence✝ branch sf.label.world sf.label.time
                branch.nextTime),
          timeOrd.addPast sf.label.time branch.nextTime)
### eq_18
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.someFuturePos sf branch timeOrd =
      match asSomeFuture? sf.formula with
      | some ψ =>
        have freshTime := branch.nextTime;
        have freshLabel := { world := sf.label.world, time := freshTime };
        have newOrd := timeOrd.addFuture sf.label.time freshTime;
        have witness := SignedFormula.pos ψ freshLabel;
        have gProps :=
          List.filterMap
            (fun gsf =>
              match gsf.formula with
              | ((Formula.bot.imp Formula.bot).untl (inner.imp Formula.bot)).imp Formula.bot =>
                if (gsf.label.time == sf.label.time) = true then
                  have prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime };
                  if branch.contains prop = true then none else some prop
                else none
              | x => none)
            branch.allFuturePosFormulas;
        have fNegProps :=
          List.filterMap
            (fun fsf =>
              match fsf.formula with
              | (Formula.bot.imp Formula.bot).untl inner =>
                if (fsf.label.time == sf.label.time) = true then
                  have prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime };
                  if branch.contains prop = true then none else some prop
                else none
              | x => none)
            branch.someFutureNegFormulas;
        have modalProps :=
          FormalSystem.Metalogic.Decidability.boxDiamondPersistence✝ branch sf.label.world sf.label.time freshTime;
        (RuleResult.linear (witness :: gProps ++ fNegProps ++ modalProps), newOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_19
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.neg →
    applyRule TableauRule.someFutureNeg sf branch timeOrd =
      match asSomeFuture? sf.formula with
      | some ψ =>
        have futureTimes := timeOrd.futureOf sf.label.time;
        have newFormulas :=
          List.filterMap
            (fun t' =>
              have newSf := SignedFormula.neg ψ { world := sf.label.world, time := t' };
              if branch.contains newSf = true then none else some newSf)
            futureTimes;
        if newFormulas.isEmpty = true then (RuleResult.notApplicable, timeOrd)
        else (RuleResult.persistent newFormulas, timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_20
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.somePastPos sf branch timeOrd =
      match asSomePast? sf.formula with
      | some ψ =>
        have freshTime := branch.nextTime;
        have freshLabel := { world := sf.label.world, time := freshTime };
        have newOrd := timeOrd.addPast sf.label.time freshTime;
        have witness := SignedFormula.pos ψ freshLabel;
        have hProps :=
          List.filterMap
            (fun hsf =>
              match hsf.formula with
              | ((Formula.bot.imp Formula.bot).snce (inner.imp Formula.bot)).imp Formula.bot =>
                if (hsf.label.time == sf.label.time) = true then
                  have prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime };
                  if branch.contains prop = true then none else some prop
                else none
              | x => none)
            branch.allPastPosFormulas;
        have pNegProps :=
          List.filterMap
            (fun psf =>
              match psf.formula with
              | (Formula.bot.imp Formula.bot).snce inner =>
                if (psf.label.time == sf.label.time) = true then
                  have prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime };
                  if branch.contains prop = true then none else some prop
                else none
              | x => none)
            branch.somePastNegFormulas;
        have modalProps :=
          FormalSystem.Metalogic.Decidability.boxDiamondPersistence✝ branch sf.label.world sf.label.time freshTime;
        (RuleResult.linear (witness :: hProps ++ pNegProps ++ modalProps), newOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_21
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.neg →
    applyRule TableauRule.somePastNeg sf branch timeOrd =
      match asSomePast? sf.formula with
      | some ψ =>
        have pastTimes := timeOrd.pastOf sf.label.time;
        have newFormulas :=
          List.filterMap
            (fun t' =>
              have newSf := SignedFormula.neg ψ { world := sf.label.world, time := t' };
              if branch.contains newSf = true then none else some newSf)
            pastTimes;
        if newFormulas.isEmpty = true then (RuleResult.notApplicable, timeOrd)
        else (RuleResult.persistent newFormulas, timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_22
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.untlPos sf branch timeOrd =
      match asUntil? sf.formula with
      | some (event, guard) =>
        have freshTime := branch.nextTime;
        have freshLabel := { world := sf.label.world, time := freshTime };
        have newOrd := timeOrd.addFuture sf.label.time freshTime;
        have branch1 := [SignedFormula.pos event freshLabel];
        have branch2 := [SignedFormula.pos guard freshLabel, SignedFormula.pos (guard.untl event) freshLabel];
        have gProps :=
          List.filterMap
            (fun gsf =>
              match gsf.formula with
              | ((Formula.bot.imp Formula.bot).untl (inner.imp Formula.bot)).imp Formula.bot =>
                if (gsf.label.time == sf.label.time) = true then
                  have prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime };
                  if branch.contains prop = true then none else some prop
                else none
              | x => none)
            branch.allFuturePosFormulas;
        have fNegProps :=
          List.filterMap
            (fun fsf =>
              match fsf.formula with
              | (Formula.bot.imp Formula.bot).untl inner =>
                if (fsf.label.time == sf.label.time) = true then
                  have prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime };
                  if branch.contains prop = true then none else some prop
                else none
              | x => none)
            branch.someFutureNegFormulas;
        have modalProps :=
          FormalSystem.Metalogic.Decidability.boxDiamondPersistence✝ branch sf.label.world sf.label.time freshTime;
        have autoProp := gProps ++ fNegProps ++ modalProps;
        (RuleResult.branching [branch1 ++ autoProp, branch2 ++ autoProp], newOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_23
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.sncePos sf branch timeOrd =
      match asSince? sf.formula with
      | some (event, guard) =>
        have freshTime := branch.nextTime;
        have freshLabel := { world := sf.label.world, time := freshTime };
        have newOrd := timeOrd.addPast sf.label.time freshTime;
        have branch1 := [SignedFormula.pos event freshLabel];
        have branch2 := [SignedFormula.pos guard freshLabel, SignedFormula.pos (guard.snce event) freshLabel];
        have hProps :=
          List.filterMap
            (fun hsf =>
              match hsf.formula with
              | ((Formula.bot.imp Formula.bot).snce (inner.imp Formula.bot)).imp Formula.bot =>
                if (hsf.label.time == sf.label.time) = true then
                  have prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime };
                  if branch.contains prop = true then none else some prop
                else none
              | x => none)
            branch.allPastPosFormulas;
        have pNegProps :=
          List.filterMap
            (fun psf =>
              match psf.formula with
              | (Formula.bot.imp Formula.bot).snce inner =>
                if (psf.label.time == sf.label.time) = true then
                  have prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime };
                  if branch.contains prop = true then none else some prop
                else none
              | x => none)
            branch.somePastNegFormulas;
        have modalProps :=
          FormalSystem.Metalogic.Decidability.boxDiamondPersistence✝ branch sf.label.world sf.label.time freshTime;
        have autoProp := hProps ++ pNegProps ++ modalProps;
        (RuleResult.branching [branch1 ++ autoProp, branch2 ++ autoProp], newOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_24
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.neg →
    applyRule TableauRule.untlNeg sf branch timeOrd =
      match asUntil? sf.formula with
      | some (event, guard) =>
        have futureTimes := timeOrd.futureOf sf.label.time;
        if (futureTimes.isEmpty && decide (timeOrd.timeCount > 0) && decide (timeOrd.timeCount < 4)) = true then
          have freshTime := branch.nextTime;
          have freshLabel := { world := sf.label.world, time := freshTime };
          have newOrd := timeOrd.addFuture sf.label.time freshTime;
          have gProps :=
            List.filterMap
              (fun gsf =>
                match gsf.formula with
                | ((Formula.bot.imp Formula.bot).untl (inner.imp Formula.bot)).imp Formula.bot =>
                  if (gsf.label.time == sf.label.time) = true then
                    have prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime };
                    if branch.contains prop = true then none else some prop
                  else none
                | x => none)
              branch.allFuturePosFormulas;
          have fNegProps :=
            List.filterMap
              (fun fsf =>
                match fsf.formula with
                | (Formula.bot.imp Formula.bot).untl inner =>
                  if (fsf.label.time == sf.label.time) = true then
                    have prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime };
                    if branch.contains prop = true then none else some prop
                  else none
                | x => none)
              branch.someFutureNegFormulas;
          have modalProps :=
            FormalSystem.Metalogic.Decidability.boxDiamondPersistence✝ branch sf.label.world sf.label.time freshTime;
          have autoProp := gProps ++ fNegProps ++ modalProps;
          have branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp;
          have branch2 := [SignedFormula.neg guard freshLabel, sf] ++ autoProp;
          (RuleResult.branching [branch1, branch2], newOrd)
        else (RuleResult.notApplicable, timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_25
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.neg →
    applyRule TableauRule.snceNeg sf branch timeOrd =
      match asSince? sf.formula with
      | some (event, guard) =>
        have pastTimes := timeOrd.pastOf sf.label.time;
        if (pastTimes.isEmpty && decide (timeOrd.timeCount > 0) && decide (timeOrd.timeCount < 4)) = true then
          have freshTime := branch.nextTime;
          have freshLabel := { world := sf.label.world, time := freshTime };
          have newOrd := timeOrd.addPast sf.label.time freshTime;
          have hProps :=
            List.filterMap
              (fun hsf =>
                match hsf.formula with
                | ((Formula.bot.imp Formula.bot).snce (inner.imp Formula.bot)).imp Formula.bot =>
                  if (hsf.label.time == sf.label.time) = true then
                    have prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime };
                    if branch.contains prop = true then none else some prop
                  else none
                | x => none)
              branch.allPastPosFormulas;
          have pNegProps :=
            List.filterMap
              (fun psf =>
                match psf.formula with
                | (Formula.bot.imp Formula.bot).snce inner =>
                  if (psf.label.time == sf.label.time) = true then
                    have prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime };
                    if branch.contains prop = true then none else some prop
                  else none
                | x => none)
              branch.somePastNegFormulas;
          have modalProps :=
            FormalSystem.Metalogic.Decidability.boxDiamondPersistence✝ branch sf.label.world sf.label.time freshTime;
          have autoProp := hProps ++ pNegProps ++ modalProps;
          have branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp;
          have branch2 := [SignedFormula.neg guard freshLabel, sf] ++ autoProp;
          (RuleResult.branching [branch1, branch2], newOrd)
        else (RuleResult.notApplicable, timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_26
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.orderTrichotomy sf branch timeOrd =
      if (asAnd? sf.formula).isSome = true then (RuleResult.notApplicable, timeOrd)
      else
        have disjuncts := fun x y =>
          [(x.and y).someFuture, (x.and y.someFuture).someFuture, (x.someFuture.and y).someFuture];
        have carriedAt := fun t =>
          List.filterMap
            (fun sf' =>
              match sf'.sign with
              | Sign.pos =>
                if (sf'.label.world == sf.label.world && sf'.label.time == t && (asAnd? sf'.formula).isNone) = true then
                  some sf'.formula
                else none
              | x => none)
            branch;
        have futs := timeOrd.futureOf sf.label.time;
        have pasts := timeOrd.pastOf sf.label.time;
        have candidates :=
          List.flatMap
            (fun t0 =>
              have siblings :=
                List.filter (fun t2 => t2 != sf.label.time && !futs.contains t2 && !pasts.contains t2)
                  (timeOrd.futureOf t0);
              List.flatMap (fun t2 => List.map (fun ψ => (t0, ψ)) (carriedAt t2)) siblings)
            pasts;
        have firedAlready := fun d =>
          List.any branch fun sf' => sf'.sign == Sign.pos && sf'.label.world == sf.label.world && sf'.formula == d;
        have witnessesOf := fun t0 χ =>
          List.filter (fun t => branch.contains (SignedFormula.pos χ { world := sf.label.world, time := t }))
            (timeOrd.futureOf t0);
        have settled := fun t0 ψ =>
          (witnessesOf t0 sf.formula).any fun a =>
            (witnessesOf t0 ψ).any fun b => a == b || (timeOrd.futureOf a).contains b || (timeOrd.pastOf a).contains b;
        have fires := fun x =>
          match x with
          | (t0, ψ) =>
            have l0 := { world := sf.label.world, time := t0 };
            have ds := disjuncts sf.formula ψ;
            !ds.any firedAlready && !settled t0 ψ && decide ((witnessesOf t0 sf.formula).length ≤ 1) &&
                decide ((witnessesOf t0 ψ).length ≤ 1) &&
              ds.any fun d => branch.contains (SignedFormula.neg d l0);
        match List.find? fires candidates with
        | none => (RuleResult.notApplicable, timeOrd)
        | some (t0, ψ) =>
          have l0 := { world := sf.label.world, time := t0 };
          (RuleResult.branching (List.map (fun d => [SignedFormula.pos d l0, sf]) (disjuncts sf.formula ψ)), timeOrd)
### eq_27
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    sf.formula = Formula.bot.untl (Formula.bot.imp Formula.bot) →
      applyRule TableauRule.denseIndicatorClosure sf branch timeOrd = (RuleResult.linear [], timeOrd)
### eq_28
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (ψ : Formula),
  sf.sign = Sign.pos →
    sf.formula = ((Formula.bot.imp Formula.bot).untl (ψ.imp Formula.bot)).imp Formula.bot →
      applyRule TableauRule.densityRule sf branch timeOrd =
        match
          List.filter
            (fun t' =>
              (timeOrd.futureOf t').isEmpty &&
                !(timeOrd.futureOf sf.label.time).any fun t'' => (timeOrd.futureOf t'').contains t')
            (timeOrd.futureOf sf.label.time) with
        | [] => (RuleResult.notApplicable, timeOrd)
        | t' :: tail =>
          have freshTime := branch.nextTime;
          have freshLabel := { world := sf.label.world, time := freshTime };
          have newOrd := (timeOrd.addFuture sf.label.time freshTime).addFuture freshTime t';
          have witness := SignedFormula.pos ψ freshLabel;
          have gProps :=
            List.filterMap
              (fun gsf =>
                match gsf.formula with
                | ((Formula.bot.imp Formula.bot).untl (inner.imp Formula.bot)).imp Formula.bot =>
                  if (gsf.label.time == sf.label.time && gsf.formula != ψ.allFuture) = true then
                    have prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime };
                    if branch.contains prop = true then none else some prop
                  else none
                | x => none)
              branch.allFuturePosFormulas;
          (RuleResult.persistent (witness :: gProps), newOrd)
### eq_29
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.priorUZ sf branch timeOrd =
      match asSomeFuture? sf.formula with
      | some ψ =>
        have untilFormula := ψ.neg.untl ψ;
        have newSf := SignedFormula.pos untilFormula sf.label;
        if branch.contains newSf = true then (RuleResult.notApplicable, timeOrd)
        else (RuleResult.persistent [newSf], timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_30
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.priorSZ sf branch timeOrd =
      match asSomePast? sf.formula with
      | some ψ =>
        have sinceFormula := ψ.neg.snce ψ;
        have newSf := SignedFormula.pos sinceFormula sf.label;
        if branch.contains newSf = true then (RuleResult.notApplicable, timeOrd)
        else (RuleResult.persistent [newSf], timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_31
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (inner rhs : Formula),
  sf.sign = Sign.pos →
    sf.formula =
        ((Formula.bot.imp Formula.bot).untl
              (((((Formula.bot.imp Formula.bot).untl (inner.imp Formula.bot)).imp Formula.bot).imp rhs).imp
                Formula.bot)).imp
          Formula.bot →
      applyRule TableauRule.z1Rule sf branch timeOrd =
        if (inner == rhs) = true then
          have gInner := inner.allFuture;
          have fgFormula := gInner.someFuture;
          have fgSf := SignedFormula.pos fgFormula sf.label;
          if branch.contains fgSf = true then
            have newSf := SignedFormula.pos gInner sf.label;
            if branch.contains newSf = true then (RuleResult.notApplicable, timeOrd)
            else (RuleResult.persistent [newSf], timeOrd)
          else (RuleResult.notApplicable, timeOrd)
        else (RuleResult.notApplicable, timeOrd)
### eq_32
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    ∀ (φ_inner : Formula),
      sf.formula = ((Formula.bot.imp Formula.bot).untl (φ_inner.imp Formula.bot)).imp Formula.bot →
        (∀ (inner rhs : Formula),
            φ_inner = (((Formula.bot.imp Formula.bot).untl (inner.imp Formula.bot)).imp Formula.bot).imp rhs → False) →
          applyRule TableauRule.z1Rule sf branch timeOrd = (RuleResult.notApplicable, timeOrd)
### eq_33
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.priorUGap sf branch timeOrd =
      match asAnd? sf.formula with
      | some (a, b) =>
        match a with
        | g.untl e =>
          if (e == Formula.top && b == g.neg.someFuture) = true then
            have concl := g.untl (g.neg.or g.neg.kPlus);
            have newSf := SignedFormula.pos concl sf.label;
            if branch.contains newSf = true then (RuleResult.notApplicable, timeOrd)
            else (RuleResult.persistent [newSf], timeOrd)
          else (RuleResult.notApplicable, timeOrd)
        | x => (RuleResult.notApplicable, timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_34
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.priorSGap sf branch timeOrd =
      match asAnd? sf.formula with
      | some (a, b) =>
        match a with
        | g.snce e =>
          if (e == Formula.top && b == g.neg.somePast) = true then
            have concl := g.snce (g.neg.or g.neg.kMinus);
            have newSf := SignedFormula.pos concl sf.label;
            if branch.contains newSf = true then (RuleResult.notApplicable, timeOrd)
            else (RuleResult.persistent [newSf], timeOrd)
          else (RuleResult.notApplicable, timeOrd)
        | x => (RuleResult.notApplicable, timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_35
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  sf.sign = Sign.pos →
    applyRule TableauRule.sepRule sf branch timeOrd =
      match asAnd? sf.formula with
      | some (a, b) =>
        match a with
        | ((ψ.imp Formula.bot).untl e).imp Formula.bot =>
          if (e == Formula.top && b == (ψ.and (ψ.neg.untl ψ)).kPlus.neg) = true then
            have concl := (ψ.kPlus.and ψ.kMinus).kPlus;
            have newSf := SignedFormula.pos concl sf.label;
            if branch.contains newSf = true then (RuleResult.notApplicable, timeOrd)
            else (RuleResult.persistent [newSf], timeOrd)
          else (RuleResult.notApplicable, timeOrd)
        | x => (RuleResult.notApplicable, timeOrd)
      | none => (RuleResult.notApplicable, timeOrd)
### eq_36
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  applyRule TableauRule.serialityRule sf branch timeOrd =
    if
        (List.filter (fun f => !branch.contains f)
              [SignedFormula.pos Formula.top.someFuture sf.label,
                SignedFormula.pos Formula.top.somePast sf.label]).isEmpty =
          true then
      (RuleResult.notApplicable, timeOrd)
    else
      (RuleResult.persistent
          (List.filter (fun f => !branch.contains f)
            [SignedFormula.pos Formula.top.someFuture sf.label, SignedFormula.pos Formula.top.somePast sf.label]),
        timeOrd)
### eq_37
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering),
  applyRule TableauRule.timeLinearity sf branch timeOrd =
    match firstIncomparablePair branch timeOrd with
    | none => (RuleResult.notApplicable, timeOrd)
    | some (t₁, t₂) =>
      (RuleResult.branchingOrdered
          [(branch, timeOrd.addFuture t₁ t₂), (branch, timeOrd.addFuture t₂ t₁),
            (branch.identifyTime (min t₁ t₂) (max t₁ t₂), timeOrd.identifyTime (min t₁ t₂) (max t₁ t₂))],
        timeOrd)
### eq_38
∀ (sf : SignedFormula) (branch : Branch) (timeOrd : TimeOrdering) (rule : TableauRule),
  (rule = TableauRule.serialityRule → False) →
    (rule = TableauRule.timeLinearity → False) →
      (rule = TableauRule.andPos → sf.sign = Sign.pos → False) →
        (rule = TableauRule.andNeg → sf.sign = Sign.neg → False) →
          (rule = TableauRule.orPos → sf.sign = Sign.pos → False) →
            (rule = TableauRule.orNeg → sf.sign = Sign.neg → False) →
              (rule = TableauRule.negPos → sf.sign = Sign.pos → False) →
                (rule = TableauRule.negNeg → sf.sign = Sign.neg → False) →
                  (rule = TableauRule.diamondPos → sf.sign = Sign.pos → False) →
                    (rule = TableauRule.diamondNeg → sf.sign = Sign.neg → False) →
                      (rule = TableauRule.someFuturePos → sf.sign = Sign.pos → False) →
                        (rule = TableauRule.someFutureNeg → sf.sign = Sign.neg → False) →
                          (rule = TableauRule.somePastPos → sf.sign = Sign.pos → False) →
                            (rule = TableauRule.somePastNeg → sf.sign = Sign.neg → False) →
                              (rule = TableauRule.untlPos → sf.sign = Sign.pos → False) →
                                (rule = TableauRule.sncePos → sf.sign = Sign.pos → False) →
                                  (rule = TableauRule.untlNeg → sf.sign = Sign.neg → False) →
                                    (rule = TableauRule.snceNeg → sf.sign = Sign.neg → False) →
                                      (rule = TableauRule.orderTrichotomy → sf.sign = Sign.pos → False) →
                                        (rule = TableauRule.priorUZ → sf.sign = Sign.pos → False) →
                                          (rule = TableauRule.priorSZ → sf.sign = Sign.pos → False) →
                                            (rule = TableauRule.priorUGap → sf.sign = Sign.pos → False) →
                                              (rule = TableauRule.priorSGap → sf.sign = Sign.pos → False) →
                                                (rule = TableauRule.sepRule → sf.sign = Sign.pos → False) →
                                                  (∀ (ψ χ : Formula),
                                                      rule = TableauRule.impPos →
                                                        sf.sign = Sign.pos → sf.formula = ψ.imp χ → False) →
                                                    (∀ (ψ χ : Formula),
                                                        rule = TableauRule.impNeg →
                                                          sf.sign = Sign.neg → sf.formula = ψ.imp χ → False) →
                                                      (∀ (ψ : Formula),
                                                          rule = TableauRule.boxPos →
                                                            sf.sign = Sign.pos → sf.formula = ψ.box → False) →
                                                        (∀ (ψ : Formula),
                                                            rule = TableauRule.boxNeg →
                                                              sf.sign = Sign.neg → sf.formula = ψ.box → False) →
                                                          (∀ (ψ : Formula),
                                                              rule = TableauRule.boxTemporal →
                                                                sf.sign = Sign.pos → sf.formula = ψ.box → False) →
                                                            (∀ (ψ : Formula),
                                                                rule = TableauRule.allFuturePos →
                                                                  sf.sign = Sign.pos →
                                                                    sf.formula =
                                                                        ((Formula.bot.imp Formula.bot).untl
                                                                              (ψ.imp Formula.bot)).imp
                                                                          Formula.bot →
                                                                      False) →
                                                              (∀ (ψ : Formula),
                                                                  rule = TableauRule.allFutureNeg →
                                                                    sf.sign = Sign.neg →
                                                                      sf.formula =
                                                                          ((Formula.bot.imp Formula.bot).untl
                                                                                (ψ.imp Formula.bot)).imp
                                                                            Formula.bot →
                                                                        False) →
                                                                (∀ (ψ : Formula),
                                                                    rule = TableauRule.allPastPos →
                                                                      sf.sign = Sign.pos →
                                                                        sf.formula =
                                                                            ((Formula.bot.imp Formula.bot).snce
                                                                                  (ψ.imp Formula.bot)).imp
                                                                              Formula.bot →
                                                                          False) →
                                                                  (∀ (ψ : Formula),
                                                                      rule = TableauRule.allPastNeg →
                                                                        sf.sign = Sign.neg →
                                                                          sf.formula =
                                                                              ((Formula.bot.imp Formula.bot).snce
                                                                                    (ψ.imp Formula.bot)).imp
                                                                                Formula.bot →
                                                                            False) →
                                                                    (rule = TableauRule.denseIndicatorClosure →
                                                                        sf.sign = Sign.pos →
                                                                          sf.formula =
                                                                              Formula.bot.untl
                                                                                (Formula.bot.imp Formula.bot) →
                                                                            False) →
                                                                      (∀ (ψ : Formula),
                                                                          rule = TableauRule.densityRule →
                                                                            sf.sign = Sign.pos →
                                                                              sf.formula =
                                                                                  ((Formula.bot.imp Formula.bot).untl
                                                                                        (ψ.imp Formula.bot)).imp
                                                                                    Formula.bot →
                                                                                False) →
                                                                        (∀ (φ_inner : Formula),
                                                                            rule = TableauRule.z1Rule →
                                                                              sf.sign = Sign.pos →
                                                                                sf.formula =
                                                                                    ((Formula.bot.imp Formula.bot).untl
                                                                                          (φ_inner.imp Formula.bot)).imp
                                                                                      Formula.bot →
                                                                                  False) →
                                                                          applyRule rule sf branch timeOrd =
                                                                            (RuleResult.notApplicable, timeOrd)
### eq_39: MISSING
### eq_40: MISSING
```
