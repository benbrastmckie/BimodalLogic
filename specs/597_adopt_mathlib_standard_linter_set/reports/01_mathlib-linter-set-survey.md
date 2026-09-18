# Research Report: Task #597

**Task**: 597 - Adopt Mathlib's standard linter set, following cslib's precedent
**Started**: 2026-09-18T17:59:47Z
**Completed**: 2026-09-18T19:10:00Z
**Effort**: large (estimate: 8-12 phases, dominated by the `longLine`, `emptyLine`, `show` and instance-hypothesis classes)
**Dependencies**: Task 585 (compiler-warning burn-down + C28 gate), completed
**Sources/Inputs**: - Codebase (`lakefile.toml`, `scripts/check-module-invariants.sh`, `scripts/warning-budget.{py,txt}`, `.github/workflows/ci.yml`, `docs/development/{CI_CD_PROCESS,MODULE_INVARIANTS,LEAN_STYLE_GUIDE}.md`); Mathlib `v4.33.0-rc1` linter sources (`Mathlib/Init.lean`, `Mathlib/Tactic/Linter/*.lean`); cslib checkout (`~/Projects/cslib`: `lakefile.toml`, `docs/lint-suppression-policy.md`, `scripts/check-lint-suppressions.sh`); an empirical per-file sweep of the live tree under `-Dweak.linter.mathlibStandardSet=true`
**Artifacts**: - specs/597_adopt_mathlib_standard_linter_set/reports/01_mathlib-linter-set-survey.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Measured warning surface: 2,451 warnings in 283 files, 14 linter classes**, across the 555 of 590
  live `.lean` files that could be elaborated during the sweep. The other 35 files could not be
  measured because another session was rebuilding their imports (see Risks). Counting those files
  from source text adds about 230 more `longLine` warnings and about 13 more `maxHeartbeats`
  warnings. **The projected total is about 2,700.**
- **The task description's premises are out of date:** (a) the file is `lakefile.toml`, not
  `lakefile.lean`. (b) Only **1** blanket suppression is left, not 4
  (`Semantics/Ultraproduct/Carrier.lean:81`). Task 619 deleted the other three and the one in the
  test. (c) There are 50 scoped `maxHeartbeats` settings, not 48. The 7 unscoped ones are confirmed.
  (d) `longFile` **does not fire** under the linter set alone. Its option is a `Nat` whose default
  is 0, so it is off in downstream projects. It fires only if the lakefile sets
  `weak.linter.style.longFile = 1500`.
- **The CI setup conflicts with "baseline the rest under C28".** CI builds with `--wfail`, which
  task 585 wired as the hard stop. With `--wfail`, any baselined warning turns CI red. So every
  linter class that is switched on must either be fixed down to zero or be switched off in the
  lakefile with a written reason. A non-zero C28 baseline is not an option unless `--wfail` is
  removed, and that is not recommended.
- **Enabling the linters breaks 5 test files outright.** `longLine` warnings get inserted into the
  output that `#guard_msgs` checks, which turns them into **errors**. The files are
  `TableauConformance`, `BoxSpreadProbe`, `RegionGateProbe`, `TemporalWitnessProbe` and
  `RayRegionProbe`.
- **Recommended approach: turn the classes on one at a time.** Enable the whole set in
  `[leanOptions]`, with a temporary `weak.linter.X = false` for each class that is not yet at zero.
  Each phase takes one class to zero and deletes its temporary opt-out. That keeps `lake build
  --wfail` green after every phase. Only documented, permanent opt-outs remain at the end, such as
  `hashCommand` for the test library and possibly the instance-hypothesis pair.
- **The ratchet should extend C29** (the existing comment-aware `set_option linter.* false`
  scanner) and start from a **zero** baseline. It should also forbid unscoped `maxHeartbeats`, and
  it must explicitly allow Mathlib's in-source `set_option linter.style.longFile N` baseline form.

## Context & Scope

This report re-measures what the task description recorded on 2026-09-16, as its "re-measure
before planning" note asks. It sets out what `weak.linter.mathlibStandardSet` contains at the
pinned Mathlib, measures the new warnings per class, and recommends a phase breakdown with
sorry-free, suppression-free fixes. No Lean proofs are involved: this task is lint hygiene only, so
the zero-debt policy is met trivially (no `sorry`, no axioms).

### Linter set membership at Mathlib `v4.33.0-rc1`

Source: `Mathlib/Init.lean:81`, `register_linter_set linter.mathlibStandardSet`:

`auxLemma`, `flexible`, `hashCommand`, `oldObtain`, `privateModule`, `style.cases`,
`style.induction`, `style.refine`, `style.cdot`, `style.docString`, `style.dollarSyntax`,
`style.emptyLine`, `style.header`, `style.lambdaSyntax`, `style.longLine`, `style.longFile`,
`style.multiGoal`, `style.nativeDecide`, `style.openClassical`, `style.maxHeartbeats`,
`style.missingEnd`, `style.setOption`, `style.show`, `style.whitespace`,
`unusedDecidableInType`, `unusedFintypeInType`.

`allScriptsDocumented`, `checkInitImports` and `docPrime` are deliberately *not* in the set at
this Mathlib. cslib opts out of `pythonStyle`, `checkInitImports`, `allScriptsDocumented` and
`unicodeLinter`, but none of those does anything here:
- the first three are not in the set;
- `pythonStyle` and `unicodeLinter` are text-based linters that run only under
  `lake exe lint-style`, never during `lake build`.

This repo does not need to copy cslib's opt-out block.

## Findings

### Codebase Patterns

**Lake configuration.** `lakefile.toml` sets `leanOptions = {pp.unicode.fun, autoImplicit}` on
each of the two `lean_lib` targets. It has no package-level `[leanOptions]` table.

The 13 `lean_exe` roots live under `FormalSystem/Automation/` and are built only as exe targets.
Library-level `leanOptions` therefore do **not** reach them. The option has to go in the
**package-level** `[leanOptions]` table, as cslib does, or those roots escape the linters. This
matters: `ProofExtractorMain.lean` alone carries 158 `emptyLine` warnings.

Changing any `leanOptions` value changes every module's trace hash, which means one full rebuild
of the tree.

**Existing gates the change has to fit into:**

| Gate | What it does | Implication for this task |
|---|---|---|
| CI `build-args: "--wfail"` (`ci.yml:40`) | any compiler warning fails the build | the target is **zero warnings** for every enabled class |
| C28 `scripts/warning-budget.py` + `warning-budget.txt` | per-`<count> <path> <linter>` ceiling; **exit 2 on any observed linter class with no disposition row** | every newly enabled class needs a `# disposition` row, even at zero warnings, or the harness goes red. That is a useful forcing function. |
| C29 (`check-module-invariants.sh:3924`) | every `set_option linter.* false` carries a reason comment naming the linter; comment-masked scan via `scripts/lib/lean_debug_artifacts.py` | the blanket-suppression ratchet should be built on the same walk and masker |
| C16 (`runLinter`, `nolints.json`) | environment linters | disjoint from this task; untouched |

**Existing documentation.** `docs/development/LEAN_STYLE_GUIDE.md:110` already states a
100-character limit, and `:771-830` documents suppression practice. `longLine` therefore enforces
a convention the repo already has; it does not introduce a new one. `MODULE_INVARIANTS.md` needs a
new row for the ratchet check.

### Measured warning surface (empirical sweep)

**Method.** For each of the 590 live files (`FormalSystem/` and `Tests/`, excluding `Boneyard/`),
the sweep ran:

```
lake env lean -Dweak.linter.mathlibStandardSet=true <file>
```

This uses the existing `.lake` oleans and writes no build outputs. 555 files elaborated cleanly.
Of the 35 that failed:
- 30 failed because their imports' `.olean` files did not exist at that moment. Another session was
  rebuilding `Termination/Fuel`, `MintBound/OrderingTimes` and `MintBound/TimeCensus` at the time.
  These are measurement gaps, not defects.
- 5 are the `#guard_msgs` breakages described below.

| Class | Warnings | Files | Nature of fix | Top files |
|---|---:|---:|---|---|
| `style.longLine` | 844 (+~230 unmeasured) | 178 | mechanical reflow | `MintBound/Register.lean` 65, `Metalogic/Conservativity.lean` 29, `SoundnessLemmas/FrameClassVariants.lean` 20 |
| `style.emptyLine` | 534 | 31 | mechanical (blank lines inside a command) | `ProofExtractorMain.lean` 158, `ProofSearch/Core.lean` 48, `Tactics/Search.lean` 36 |
| `unusedFintypeInType` | 274 | 55 | structural, see below | `Bridge/Interpolate.lean` 16, `AggregateOffDiagK1.lean` 14, `BadIntervals.lean` 14 |
| `unusedDecidableInType` | 249 | 53 | structural, see below | `AggregateOffDiagK1.lean` 14, `BadIntervals.lean` 14, `GoodDense.lean` 13 |
| `hashCommand` | 241 | 10 (all `Tests/`) | opt-out for the test lib | `DatasetGeneratorTest.lean` 108, `SaturationTest.lean` 48, `NormalizationTest.lean` 42 |
| `style.show` | 193 | 59 | `show` → `change` where the goal changes | `RamseyFactorization.lean` 17 |
| `flexible` | 81 | 9 | `simp` → `simp only [...]` / `simpa` before a rigid tactic | `Termination/Fuel.lean` 33, `Tableau.lean` 17, `EFGameTactics.lean` 8 |
| `style.maxHeartbeats` | 18 (+~13 unmeasured) | 7 | add a `--` comment **after** the `in` | `OrderingTimes`, `Invariants`, `BoxSaturation`, `TemporalOrder` |
| `style.setOption` | 7 | 3 | the 7 unscoped `maxHeartbeats` | `SubformulaProperty.lean` 5, `TemporalSaturation.lean` 1, `Tableau.lean` 1 |
| `style.docString` | 4 | 4 | trivial | |
| `style.multiGoal` | 2 | 1 | trivial (focus with `·`) | `Bridge/IntTruth.lean` |
| `style.openClassical` | 2 | 2 | scope to `open Classical in` | `DeterministicBridge.lean:87`, `PlusTruth.lean:69` |
| `style.missingEnd` | 1 | 1 | trivial | `Bundle/LimitMCS.lean` |
| `style.cdot` | 1 | 1 | trivial | `RamseyFactorization.lean` |
| **Total** | **2,451** | **283** | | |

These classes were measured at **zero** in the elaborated files: `header`, `whitespace`,
`dollarSyntax`, `lambdaSyntax`, `cases`, `induction`, `refine`, `nativeDecide`, `oldObtain`,
`auxLemma` and `privateModule`. The last is inert because no file uses the `module` keyword. None
of these needs a phase, but each still needs a C28 disposition row.

**The `#guard_msgs` hazard.** In 5 test files, a `#guard_msgs` block evaluates a command whose
guarded output is longer than 100 characters. The `longLine` warning is then *added* to the
message set, the docstring no longer matches, and the command fails with an **error**. The files
are `TableauConformance.lean` (lines ~910-936), `BoxSpreadProbe.lean`, `RegionGateProbe.lean`,
`TemporalWitnessProbe.lean` and `RayRegionProbe.lean`, all in `Tests/BimodalTest/`.

The implementation must handle these in the same phase that enables `longLine`, or the build
breaks. Possible fixes:
- reflow the source line that the warning points at;
- use per-command `set_option linter.style.longLine false in` with a reason (C29);
- use `#guard_msgs (drop warning) in`. This is weaker because it would also hide other warnings.

**`maxHeartbeats` comment placement.** A probe confirmed Mathlib's rule: the explanatory comment
must be a `--` comment **after** the `in`, between it and the declaration. A docstring does not
count, and neither does a comment above the `set_option`. Most of the 50 scoped sites already
follow the Mathlib form. About 31 do not: they sit directly above a docstring. Most are in
`Termination/MintBound/*`, `Bridge/{Prop,Box}Saturation`, `CountermodelExtraction` (lines 507
and 593) and `TemporalOrder` (lines 197 and 200).

**The 7 unscoped `maxHeartbeats`.**
- 5 are in `Termination/SubformulaProperty.lean` (lines 470, 595, 690, 801 and 1165). Each is
  already bounded by a named `section`. Together they cover about 37 theorems.
- 1 is in `Verified/Bridge/TemporalSaturation.lean:42` and is **file-scoped** (6 declarations).
- 1 is in `Decidability/Tableau.lean:2387`, inside `section ProgressLemmas`.

To convert them, run a per-declaration trial: remove the budget, build, and add
`set_option maxHeartbeats N in` plus a trailing `--` reason only where the build needs it. Use
`count_heartbeats in` to choose N. A blind copy onto every declaration would inflate the count of
scoped settings for no benefit.

**The instance-hypothesis pair: the one non-mechanical class.** Of the 523 warnings in the two
classes, 489 are the same pair, `[Fintype sig.preds]` (244) and `[DecidableEq sig.preds]` (245).
They are repeated on theorem signatures throughout the `MonadicSignature` layer
(`WeakCanonical/Kamp/**`, `DenseModelSurgery/**`, `RealModel/**`, `Bridge/Interpolate.lean`).
The other 34 are 28 `[Fintype ι]` and six singletons.

The fix Mathlib recommends is to remove the hypothesis from each theorem that does not need it in
its *type*, and use `classical` or `Fintype.ofFinite` inside the proof. It is sound and sorry-free,
but it has two risks:
- **Instance mismatch downstream.** A caller that relied on the specific instance may now see a
  `Classical.decEq` instance. `Fintype` is a subsingleton, so it is safe. `DecidableEq`
  mismatches do occur in practice.
- **A call-graph cascade** like the one task 585 recorded for `omit`. Removing the instance from
  `X` can make it unused in a caller `Y`.

The alternative is a single structural change: bundle the pair into the signature, as fields or a
`[MonadicSignature.Finite sig]` class. That is a refactor of about 55 files.

Recommendation: plan this class last, as its own phase or phases, and iterate to a fixpoint as
585 did. Decide at plan time between fixing it and a permanent, documented lakefile opt-out.

### External Resources

- cslib `lakefile.toml`: `[leanOptions] weak.linter.mathlibStandardSet = true`,
  `weak.linter.flexible = true` (redundant at this Mathlib), plus four opt-outs that are inert
  here. The test library uses per-library
  `leanOptions = {weak.linter.style.header = false, weak.linter.privateModule = false}`. That is
  the model for a `BimodalTest`-only `weak.linter.hashCommand = false`.
- cslib `docs/lint-suppression-policy.md`: blanket form is gated and may only decrease;
  declaration-scoped `... false in` is always allowed. It records two traps:
  - `omit [X] in` is **not** interchangeable with `set_option linter.X false in`;
  - `set_option ... in` must come **before** a doc comment.

  It also warns that `set_option linter.X false in open Classical` scopes the `open`. That is
  directly relevant to the 2 `openClassical` fixes here.
- cslib `scripts/check-lint-suppressions.sh`: a per-file baseline ratchet matched by the regex
  `^\s*set_option\s+linter\.[A-Za-z0-9_.]+\s+false\s*(--.*)?$`. It is not comment-aware.
- Mathlib `Style.lean:347-420`: the `longFile` semantics. A value of 0 means off. When the file is
  longer than the default (1500), the only accepted per-file values are `candidate` and
  `candidate + 100`, where `candidate = (lines/100)*100 + 200`. The linter itself therefore
  polices how tight each per-file baseline is.

### Recommendations

1. **Enable at package level.** Add a top-level `[leanOptions]` table to `lakefile.toml` with
   `weak.linter.mathlibStandardSet = true`, so the `lean_exe` roots are covered too. Keep the
   per-library `pp.unicode.fun` and `autoImplicit` entries as they are. Also add
   `weak.linter.style.longFile = 1500`, because otherwise `longFile` never runs.
2. **Enable the classes one at a time behind temporary opt-outs.** Phase 1 turns on the set and
   adds `weak.linter.<X> = false` for every class that is not yet at zero, with a
   `# TEMPORARY -- removed by phase N` comment on each. Each later phase takes one class to zero,
   deletes its line and adds a `blocking` disposition row to `warning-budget.txt`. `--wfail`
   stays green throughout, and C28 stays at a zero baseline.
3. **Baseline `longFile` in the source, not in C28.** Add Mathlib's own
   `set_option linter.style.longFile N` (N = candidate) to each of the **38** files over 1,500
   lines. The largest is `EFGames/GapDetection.lean` at 5,090. This produces no warnings, the
   linter checks that N is tight, and it is not a suppression. The ratchet must allow this form.
4. **Suggested phase order**, cheapest and most isolated first:
   - (P1) lakefile, temporary opt-outs and C28 disposition rows;
   - (P2) trivial classes: `docString`, `multiGoal`, `openClassical`, `missingEnd`, `cdot`;
   - (P3) the `maxHeartbeats` group: the 7 unscoped settings (`setOption`) and the ~31
     comment-placement fixes (`style.maxHeartbeats`);
   - (P4) `longFile` in-source baselines;
   - (P5) `hashCommand`: a permanent documented opt-out on `BimodalTest` only, because its
     `#eval` tests are the point of those files;
   - (P6) `emptyLine`;
   - (P7) `show`;
   - (P8) `flexible`;
   - (P9-P11) `longLine`, split by directory: `Metalogic/Decidability`, `Metalogic/WeakCanonical`,
     then the rest plus `Tests`. The 5 `#guard_msgs` files go in the phase that covers `Tests`;
   - (P12+) `unusedDecidableInType` / `unusedFintypeInType`: fix or document a permanent opt-out;
   - (last) the ratchet check and the policy doc.
5. **Carrier.lean's blanket suppression.** Carry out the restructuring its own comment prescribes:
   split the `variable` block so that `[∀ i, LinearOrder (D i)]` and
   `[∀ i, IsOrderedAddMonoid (D i)]` are in scope only for the order-dependent declarations. Then
   delete the suppression. Per-declaration `... false in` is the fallback, and each one needs a
   C29 reason.
6. **The ratchet check (a new check C30, or a second half of C29).** Reuse C29's
   `live_files` walk and `lean_debug_artifacts.mask`, and start from a **zero** baseline with no
   allow-list. Fail on:
   - (a) any masked `set_option linter.<X> <value>` with no trailing `in`, **except**
     `linter.style.longFile <N>`;
   - (b) any `set_option <...maxHeartbeats...> N` with no trailing `in`.

   Keep C29's anti-silence guards: exit 2 on an empty walk, and on zero matched scoped
   suppressions. Document it in `MODULE_INVARIANTS.md`, and add a lint-suppression policy section
   to `docs/development/LEAN_STYLE_GUIDE.md` that cites cslib's policy doc as the model. That
   section should list every permanent lakefile opt-out with its reason.
7. **Final verification.** Do one guarded all-target build (`FormalSystem`, `BimodalTest` and
   every exe root) with the final lakefile. Then run `warning-budget.py --from-build` against it,
   because the sweep above missed 35 files, and run `check-module-invariants.sh`.

## Decisions

- The warnings are measured with per-file `lake env lean -D...`, not a full rebuild. This avoided
  invalidating `.lake/build` while another session was building. The implementation's all-target
  build is the authoritative count.
- "Baseline the rest under C28" is interpreted as "baseline in C28 only if `--wfail` would still
  pass". Since `--wfail` is live, this means zero warnings per enabled class, or a documented
  opt-out. A C28 baseline above zero is ruled out.
- `longFile` is baselined in the source using Mathlib's own mechanism. This follows the task's
  "baselined, not split" requirement without adding any warnings.
- `hashCommand` for `Tests/` is recommended as a permanent opt-out. It is a linter that does not
  fit a test library made of `#eval`/`#guard` probes. cslib does the same for `header` and
  `privateModule` in its tests.

## Risks & Mitigations

- **35 files were not measured.** Mitigation: the final all-target build with
  `warning-budget.py --from-build` produces the real count. From the source text, the gap is about
  230 `longLine` and about 13 `maxHeartbeats` warnings.
- **The `#guard_msgs` breakage is an error, not a warning.** Mitigation: fix those 5 files in the
  same phase that turns `longLine` on.
- **Instance-hypothesis removal can cascade** or cause `DecidableEq` instance mismatches.
  Mitigation: iterate to a fixpoint and do a full build after each wave. Keep the documented
  opt-out available as a fallback that requires a decision.
- **`flexible` fixes can change proof behaviour** when a `simp only [...]` set is incomplete.
  Mitigation: use the lemma list from `simp?` and build after each file.
- **Every `leanOptions` edit forces a full rebuild.** Keep the lakefile edits to the fewest
  possible commits. The temporary opt-out lines cost one rebuild each time they change, so batch
  the deletions where phases can share a build.
- **C28 exit 2 on a new class.** Add disposition rows for all 26 set members in P1, including the
  zero-count classes, so that no build ever meets an undispositioned class.

## Tactic Survey Results

- Not applicable (no tactic survey performed). This is a lint and configuration task with no
  proof goals. Standalone probes confirmed how three linters behave:

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `set_option maxHeartbeats N in` followed by a docstring | (linter probe) | warns | a comment after `in` is required |
| a 1,617-line file under the set only | (linter probe) | no `longFile` warning | needs `weak.linter.style.longFile = 1500` |
| `simp at h; rw [h]` / multi-goal `exact` / `show` | (linter probe) | `flexible`, `multiGoal`, `show` warn | standard set |

## Context Extension Recommendations

- **Topic**: Mathlib linter-set adoption in downstream projects
- **Gap**: No context file records that `longFile` is off downstream by default, that `--wfail`
  rules out a non-zero warning baseline, or the `#guard_msgs` interaction.
- **Recommendation**: add a short note to `.claude/context/project/lean4/` (through the source
  store `agent-system/extensions/lean/`) after implementation.

## Appendix

- Sweep driver: per-file `lake env lean -Dweak.linter.mathlibStandardSet=true` with `xargs -P5`.
  Per-file logs are aggregated by the `set_option linter.X false` note that follows each warning.
- Text-based counts at research time:
  - 1,100 lines over 100 characters in 205 files. The linter measures fewer, because it excludes
    `import` and `http` lines and `#guard_msgs` docstrings.
  - 38 files over 1,500 lines.
  - 1 blanket linter suppression.
  - 7 unscoped and 50 scoped `maxHeartbeats`.
  - 0 uses of `refine'` or `cases'`, 10 of `induction'`, 9 of `native_decide`, and 3 of `λ`. The
    `induction'` and `native_decide` counts are text-only and include comments or strings, because
    the linter measured 0 in both classes.
- Sources read: `Mathlib/Init.lean:60-145`; `Mathlib/Tactic/Linter/Style.lean` (setOption,
  longFile and longLine); `DeprecatedSyntaxLinter.lean` (maxHeartbeats); `HashCommandLinter.lean`;
  `Header.lean`; cslib `lakefile.toml`, `docs/lint-suppression-policy.md` and
  `scripts/check-lint-suppressions.sh`; task 585's summary.
