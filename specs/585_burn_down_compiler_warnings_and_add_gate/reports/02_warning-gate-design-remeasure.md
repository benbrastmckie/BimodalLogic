# Research Report: Warning Gate Design and Re-measurement

- **Task**: 585 - Burn down the live compiler warnings and add a warning gate
- **Started**: 2026-09-17T16:11:00Z
- **Completed**: 2026-09-17T16:55:00Z
- **Effort**: Large by volume, highly phasable; the gate half is small (one script + one CI step)
- **Dependencies**: Task 583 (CI wiring pattern) — COMPLETE and archived; Task 584 — complete.
  Downstream: Task 597 (Mathlib standard linter set) baselines its new warnings under whichever
  gate this task chooses.
- **Sources/Inputs**:
  - Measurement (this session, 2026-09-17): four guarded `lake build` runs, logs under the
    session scratchpad; per-linter and per-file tabulations derived from them
  - `.lake/build/lib/lean/**/*.trace` (Lake trace schemaVersion `2025-09-10`) — cached log store
  - `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/src/lean/Lean/Linter/**` — linter sources
  - `.lake/packages/mathlib/Mathlib/Tactic/Push.lean`,
    `.lake/packages/mathlib/Mathlib/Tactic/TacticAnalysis/Declarations.lean`
  - `.github/workflows/ci.yml`, `docs/development/CI_CD_PROCESS.md`, `lakefile.toml`,
    `scripts/check-module-invariants.sh` (C2, C14, C16)
  - Precedent repository `~/Projects/cslib`: `lakefile.toml`, `.github/workflows/lean_action_ci.yml`,
    `.github/workflows/lint-hygiene.yml`, `scripts/check-lint-suppressions.sh`,
    `scripts/lint-suppression-baseline.txt`
  - `specs/585_burn_down_compiler_warnings_and_add_gate/reports/01_compiler-warning-inventory.md`
  - Peer census of the 99 `Verified/Termination/` warnings produced by a parallel agent this
    session (verified against measurement here where cheap; see "Peer census" below)
- **Artifacts**: - `specs/585_burn_down_compiler_warnings_and_add_gate/reports/02_warning-gate-design-remeasure.md`
- **Standards**: report-format.md, artifact-management.md, status-markers.md, tasks.md

## Executive Summary

- **The real warning surface is 348 across 56 files, not 316 across 47.** Report 01 measured only
  `lake build` with its default target (`FormalSystem`). CI additionally builds the test library
  and all thirteen `lean_exe` roots; those add 35 warnings (34 in `Tests/BimodalTest/`, 1 in
  `FormalSystem/Automation/DatasetGeneratorMain.lean`) and one whole warning class
  (`linter.defProp`, 10) that report 01 never saw. Any gate scoped to `lake build` alone would
  leave that tail permanently ungated.
- **Warnings are replayed from Lake's build cache, and `--wfail` fires on replayed warnings.**
  Measured: a fully warm all-target build re-emits all 348 warnings in **6 seconds**;
  `lake build --wfail` on a warm cache exits **1**. A gate therefore costs ~6s of CI time and is
  not defeated by caching. This also refutes, for this toolchain, the assumption recorded at
  `scripts/check-module-invariants.sh:685` ("an incremental build may not re-emit them").
- **`--iofail` is categorically unusable here.** `FormalSystem/MainResults.lean` deliberately
  emits 54 `info:` messages (25 `#check` + 29 `#print axioms`) as a documented invariant surface
  tied to C2/C14/C21. `--iofail` is `--fail-level=info`, so it would fail the build on the
  project's own design. cslib's `--wfail --iofail` precedent cannot be copied; and cslib's own CI
  comment records that the combination is **permanently RED on their tree by design**, forcing
  `if: always()` plumbing on every later step — a gate that never passes is not a gate.
- **`push_neg` → `push Not` is provably behaviour-preserving, not merely "probably".**
  Mathlib implements the deprecated `push_neg` as `push (cfg) (.const ``Not) loc` plus a warning
  (`Mathlib/Tactic/Push.lean:281-292`); the two elaborate through the identical code path. All 71
  live occurrences are the `push_neg at h` / bare `push_neg` forms, 1:1 with the warnings.
- **The section-variable fix is per-declaration, not scope-changing.** Lean prints the exact
  remedy (`omit [Nontrivial D] in`) in each of the 85 messages, and three instance sets cover 73
  of them. Report 01's caution that the fix "changes what is in scope for every theorem in the
  section" applies only to the `variable`-rewriting variant, which is optional.
- **The gate belongs in `check-module-invariants.sh` as C26, but it must be build-free.** CI runs
  that harness in `--no-build` mode, so a C26 that shells out to `lake build` would be skipped in
  CI exactly like C2/C6/C24 already are — a gate that does not run. Reading the cached
  `.lake/build/**/*.trace` logs instead satisfies `--no-build`, costs 0.05s, covers all targets,
  and yields the per-linter split for free.
- **The open question the peer census flagged as the highest-value unknown is now settled
  empirically, in favour of the gate being feasible**: Lake *does* replay per-module warning logs
  on a warm cache. A naive stdout count is therefore sound, not unsound — with one guard added
  below against the failure mode the peer was right to fear.

## Context & Scope

Scope of this round: (1) re-measure the warning surface with the correct target set and attribute
every warning to its emitting linter; (2) establish which mechanical fixes are provably safe;
(3) choose the gate mechanism against the local evidence and the cslib precedent, including its
interaction with task 597's per-linter baseline requirement.

Constraints observed: the lean-lsp MCP server failed to connect this session
(`CONNECT_TIMEOUT`), so all Lean evidence here is from guarded `lake build` runs, Lake trace
files, and direct reads of the Lean/Mathlib sources in the toolchain and `.lake/packages`. No
lemma names or type signatures are asserted from memory. Every count below is reproducible from
the commands in the Appendix.

Out of scope by construction: `FormalSystem/Boneyard/` (169 files) is excluded from the build
closure and from every invariant traversal, so its ~130 additional `push_neg` occurrences neither
warn today nor break at a future Mathlib bump.

## Findings

### Measurement: the full surface is 348 warnings across 56 files

`lake build` (default target `FormalSystem`) emits 313 warnings over 44 files. Building the CI
target set — `FormalSystem`, `BimodalTest`, and the thirteen `lean_exe` roots from
`python3 scripts/lake_targets.py exe-roots` — emits 348 over 56 files, exit 0.

| Kind | Linter option | Count | Nature |
|---|---|---|---|
| This simp argument is unused | `linter.unusedSimpArgs` | 87 | style / stale-lemma smell |
| automatically included section variable(s) unused | `linter.unusedSectionVars` | 85 | style, per-declaration fix |
| `push_neg` has been deprecated | (deprecation) | 71 | **forward-compat debt** |
| Variable name `x` is not explicitly referenced | `linter.unusedVariables` | 36 | style |
| 'X' tactic does nothing | `linter.unusedTactic` (Mathlib) | 25 | **correctness smell** |
| Try this: intro … | `linter.tacticAnalysis.introMerge` (Mathlib) | 14 | mechanical |
| Definition `X` is a proposition; use `theorem` | `linter.defProp` | 10 | **not seen by report 01** |
| this tactic is never executed | `linter.unreachableTactic` | 9 | **correctness smell** |
| `IsTrichotomous`/`IsIrrefl` deprecated → `Std.*` | (deprecation) | 4 | **forward-compat debt** |
| `FormalSystem.Theorems.Propositional.negImp` deprecated | (deprecation) | 4 | project-internal |
| `String.takeRight` deprecated | (deprecation) | 2 | **forward-compat debt** |
| `String.trimLeft` deprecated | (deprecation) | 1 | **forward-compat debt** |
| **Total** | | **348** | |

Forward-compatibility debt is therefore **78 external deprecations** (71 + 4 + 2 + 1), not 75,
plus 4 project-internal ones that are this repo's own choice to schedule.

252 of the 348 carry a machine-readable attribution line in the build output —
`Note: This linter can be disabled with \`set_option linter.X false\`` — which is what makes a
per-linter baseline cheap to build. The remaining 96 are the 82 deprecations and the 14
`introMerge` suggestions, which carry no such note and must be classified by message pattern.

Distribution changes from report 01 worth carrying into the plan:
- `Tests/BimodalTest/` (11 files, 34 warnings) and `FormalSystem/Automation/DatasetGeneratorMain.lean`
  (1) are new scope.
- Five files in report 01's inventory no longer exist (`Metalogic/Z1Countermodel.lean`,
  `Metalogic/SoundnessLemmas/DenseValidity.lean`, `Metalogic/Conservativity/Star/Atomization.lean`,
  `Automation/DatasetExport.lean`, plus a rename); their traces are stale leftovers. Any
  trace-reading tool must filter entries whose source file no longer exists — 8 such entries exist
  right now.
- `FormalSystem/Semantics/Correspondence/FwdRecBridge.lean` is newly warning (1, `introMerge`).

### The cluster is real, and it is the `Decidability/` subtree

All 34 dead-tactic warnings (25 does-nothing + 9 never-executed) sit in exactly four files, all
under `Metalogic/Decidability/Verified/Termination/`: `SubformulaProperty.lean` 24,
`MintPotential.lean` 7, `Fuel.lean` 2, `TimeCensus.lean` 1. The unused-simp-arg cluster is
slightly broader than report 01 supposed: 80 of 87 are under `Metalogic/Decidability/`
(`SubformulaProperty.lean` 54, `Tableau.lean` 9, `MintPotential.lean` 8,
`CountermodelExtraction.lean` 4, others 5). The recurring argument names are concentrated —
`or_false` 11, `List.not_mem_nil` 7, `List.flatten_nil` 7, `List.flatten_cons` 7,
`List.append_nil` 7, `SignedFormula.neg` 6, `if_false` 5, `SignedFormula.pos` 4 — which is the
signature of one normal form changing under the tree, not 87 independent authoring slips.

Not one of the 87 unused-simp-arg warnings carries Lean's `←` caveat (the linter adds a note when
the argument is a `←` rewrite, because dropping it also restores the other direction to the simp
set and so is *not* a no-op). Every one of the 87 is therefore safe to delete as the linter
suggests, modulo the read-the-proof judgement the dead-tactic warnings in the same files demand.

### Peer census of the 99 `Verified/Termination/` warnings, and what it changes

A parallel agent analysed the 99 warnings under
`FormalSystem/Metalogic/Decidability/Verified/Termination/` and did not analyse the rest. Its
scope figure is confirmed exactly by measurement here: 99 warnings in that directory (78
`SubformulaProperty.lean`, 15 `MintPotential.lean`, 3 `TimeCensus.lean`, 2 `Fuel.lean`, 1
`OrientedGate.lean`), leaving 249 elsewhere on the 348-warning full surface (the census's "214"
is the same complement measured against the 313-warning default-target surface).

Its substantive findings, which this report adopts rather than re-deriving:

- The cause is mostly **authored dead, not orphaned**. The proof template entered in commits
  `ed28604ac`/`5b82a7ef9` (2026-07-28), *after* the v4.33.0-rc1 toolchain pin `29b9cea6f`
  (2026-07-25) — so `unusedSimpArgs`/`unusedTactic` were already live when the code was written.
  Commit `6b2be0db8` ("prune inert simp names") is a partial cleanup pass by the same author.
  Report 01's "one refactor orphaned these" hypothesis holds for only 4 of the 99: the
  `mem_boxDiamondPersistence` alternative is flagged dead at exactly the two theorems
  (`SubformulaProperty.lean:864,893`) that `6b2be0db8` edited when it removed six temporal
  propagation blocks as unsound.
- Classification: **77 safe-delete, 0 repair, 22 case-by-case** — the 22 being every warning
  attached to an alternative inside a `first` chain.
- **Per-site editing is mandatory.** `all_goals (try subst hg)` is dead at 9 of 15 sites,
  `(simp_all only []; done)` at 5 of 6 (line 1014 is still live), the `mem_boxDiamondPersistence`
  alternative at 2 of 10. A pattern-wide `sed` on any of the three breaks the build.

**Verified independently here**: the census's load-bearing claim about a `linter.unusedTactic`
false positive is correct and is already documented in-tree.
`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Invariants.lean:789-797`
carries a comment recording the experiment — the `exact RuleResult.noConfusion h` inside a `first`
alternative is the alternative's *failure* mechanism, and "deleting the `exact` was tried and
leaves 12 goals unsolved", naming all twelve rule cases — followed by
`set_option linter.unusedTactic false in`. The same declaration-scoped suppression appears at
`MintBound/UntlSnceFree.lean:352`. So `linter.unusedTactic` demonstrably reports tactics that are
load-bearing, and the current 25-count is already net of those two suppressed sites.

### Deprecation fixes are provably safe substitutions

`Mathlib/Tactic/Push.lean:281-292` defines the deprecated tactic as

```
elab (name := push_neg) "push_neg" cfg:optConfig loc:(location)? : tactic => do
  logWarning "`push_neg` has been deprecated. Prefer using `push Not` instead. …"
  let loc := (loc.map expandLocation).getD (.targets #[] true)
  push (← elabPushConfig cfg) none (.const ``Not) loc
```

and the `conv` form likewise (`:348-354`). `push_neg` and `push Not` reach the same `push` call
with the same configuration and location; the substitution is identity plus the removed warning.
Live usage is 71 occurrences in 14 files, all of the forms `push_neg` (5) and `push_neg at <h>`
(66) — a per-file `sed` with a per-file rebuild is sufficient, and the per-file warning counts
give an exact expected delta for each file.

Mathlib's own warning text offers a second option: re-declare `push_neg` as a local macro in the
project. That silences all 71 without touching call sites, but it perpetuates a deprecated
spelling, risks parser ambiguity against the still-present upstream `elab`, and leaves the repo
re-doing the work when upstream deletes the tactic. Recommend the substitution.

The other deprecations are one-line each: `IsTrichotomous` → `Std.Trichotomous`, `IsIrrefl` →
`Std.Irrefl` (4, in `DoetsTheorem.lean` 2 and `BlockDecomposition.lean` 2), `String.takeRight` →
`String.takeEnd` (2), `String.trimLeft` → its named replacement (1), and the project's own
`Theorems.Propositional.negImp` (4 call sites in the test library, which is a decision this repo
owns: retire the deprecated name or move the callers).

### Section variables: 85 warnings, 9 instance sets, per-declaration remedy

Every message names the exact remedy. Example, verbatim from the build log:

```
FormalSystem/Semantics/TaskFrame.lean:376:0: automatically included section variable(s) unused in
theorem `FormalSystem.Semantics.TaskFrame.mem_Fib`:
  [Nontrivial D]
consider restructuring your `variable` declarations so that the variables are not in scope or
explicitly omit them:
  omit [Nontrivial D] in theorem ...
```

Clustering: `[Nontrivial D]` 30, `[IsDualClosed C]` 22, `[Fintype sig.preds]` 21,
`[AddCommGroup D]` 4, `[IsOrderedAddMonoid D]` 3, `[AddCommGroup α]` 2, and three singletons.
`omit … in` is attached to one declaration and cannot affect its neighbours, so the safe default
is the `omit` form; rewriting a `variable` line is the optional tidier fix and is the only variant
that needs the whole-file rebuild report 01 called for.

### There are already seven in-tree suppressions, three of them blanket

`FormalSystem/Semantics/Ultraproduct/{Carrier,Los,ShiftSetProduct}.lean` each carry a file-scoped
`set_option linter.unusedSectionVars false` (no `in`); `RegionFrame.lean` (×2),
`UntlSnceFree.lean`, and `Invariants.lean` carry declaration-scoped ones. The three blanket
suppressions hide an unknown number of section-variable warnings from every count in this report,
and task 597 is chartered to convert exactly those to `in`-scoped form — which will *reveal* those
warnings after this task has burned the visible ones down. **The plan should measure the hidden
count during the section-variable phase** (comment the three lines out, build those files, record
the number) so that 597 inherits a known quantity rather than a surprise, and so the gate baseline
is set with that number visible.

### Gate: what the evidence supports

Measured facts that decide the design:

1. **Replay works.** `.lake/build/lib/lean/**/*.trace` stores each module's messages as a JSON
   `log` array with a `level` field; Lake replays them on a cache hit (67 `Replayed` markers, 0
   `Built`, in the warm all-target run) and `--wfail` honours replayed warnings (exit 1). A gate
   does not need a cold build.
2. **It is cheap.** Warm all-target replay: **6 seconds** wall. A pure trace scan (no `lake` at
   all): **0.05 seconds**, and it reproduces the same 348/56 totals plus the per-linter split.
   Both fit comfortably inside the ~56s CI check budget recorded in CI_CD_PROCESS.md.
3. **No dependency noise.** Zero warnings in the log originate from Mathlib, Batteries, or any
   other package; `--wfail` can only ever fire on this repo's own code.
4. **`--iofail` is out.** 54 deliberate `info:` messages from `MainResults.lean`.
5. **The docs already claim `--wfail` is on, and it is not.** `docs/development/CI_CD_PROCESS.md`
   asserts `build-args: "--wfail"` at lines 41-49, 69, 319 and 343; `.github/workflows/ci.yml`
   sets no `build-args` at all. This documentation drift is itself part of the finding H4 hole and
   must be corrected by this task in the same change as the gate.

Options weighed:

| Option | Fails on | Cost | Verdict |
|---|---|---|---|
| A. `build-args: "--wfail"` on lean-action | any warning in the CI build | 0s | Right *end state*; cannot be adopted before the count is 0, and one Mathlib deprecation re-reds the build with no ratchet to absorb it |
| B. `--wfail --iofail` (cslib's spelling) | any warning **or info** | 0s | **Reject.** Breaks on `MainResults.lean` by design; cslib's own tree runs it permanently red |
| C. `warningAsError := true` in `lakefile.toml` `leanOptions` | any warning, everywhere | 0s | **Reject**, and note it is strictly worse than A: a `leanOptions` entry breaks every contributor's *local* build too, while `--wfail` is a CI-only CLI flag |
| D. Ratchet baseline read from `lake build` stdout | a file/class exceeding its allowance | ~6s + a new CI step | Sound (replay confirmed), but the new step is avoidable — see below |
| E. **Ratchet baseline read from `.lake/build/**/*.trace`, wired as C26** | same | ~0.05s, no new CI step | **Recommend** |

**Evaluating the peer census's C26 proposal on the merits.** Its three arguments are all correct:
the harness exists and is numbered through C25; `scripts/` already holds companion
allowlist/waiver files (`module-invariants-allowlist.txt`, `nolint-attribute-allowlist.txt`,
`boneyard-import-waivers.txt`, `markdown-link-allowlist.txt`) so a baseline file fits house
convention; and `warningAsError` is the wrong instrument. Adopt the proposal — with one
correction it could not have made without building:

> **CI invokes `bash scripts/check-module-invariants.sh --no-build`** (`.github/workflows/ci.yml`,
> the "Check module invariants" step). CI_CD_PROCESS.md's "Known Not-in-CI Gaps" records that C2,
> C6 and C24 are consequently **not run in CI at all**. A C26 that shells out to `lake build`
> would silently join that list — the gate would exist, pass locally, and never run on a PR.

C26 must therefore be **build-free**, which the trace store makes easy and cheap: the scan needs
no `lake` invocation at all, so it runs identically in `--no-build` and full mode, and
`.lake/build` is already populated at that point in the CI job by the lean-action step and the
`Compile lean_exe roots` step above it. This also disposes of the cache-warm-placement question:
the existing invariants step is already correctly placed, so **no new CI step and no
runtime-budget row are needed** — the measured cost is 0.05s inside a step that already costs
~23s.

Recommended shape (C26 in `scripts/check-module-invariants.sh`, plus one companion file):

- **Acquisition**: walk `.lake/build/lib/lean/**/*.trace`, take `log[]` entries with
  `level == "warning"`, and drop any whose source path no longer exists (8 such stale entries
  today, left by files deleted or renamed since their last build). Prototyped this session: 0.049s,
  reproducing 348 warnings over 56 files and the exact per-linter split.
- **Baseline key**: `<count> <path> <linter>` in `scripts/warning-budget.txt`, not the peer's
  per-class scalar and not a bare per-file count. This answers the census's own "secondary caveat"
  (a scalar cannot catch one warning fixed and a different one introduced), matches the
  coordinator's point that `nolints.json` grandfathers *findings* rather than totals, and is the
  shape task 597 needs — it baselines new linter classes per file without the file being
  redesigned. Line numbers are deliberately excluded so ordinary edits do not churn the baseline.
- **Linter attribution**: the `Note: This linter can be disabled with `set_option linter.X false``
  line accompanies 252 of the 348 messages and is carried inside the trace log text; the remaining
  96 (82 deprecations, 14 `introMerge`) are classified by message pattern.
- **Modes**: verify (default, exit 1 on regression), `--update` (rewrite the file), `--list`
  (current counts, highest first), exit 2 for usage/environment error — copying
  `~/Projects/cslib/scripts/check-lint-suppressions.sh`, which is the same ratchet in a sibling
  repo. Header must carry the "counts are a CEILING and may only decrease" rule and the
  never-regenerate-to-hide-a-regression warning C16 already states for `nolints.json`
  (`check-module-invariants.sh:2083-2086`).
- **Anti-silence guard** (the census's fear, retained even though replay is confirmed): C26 must
  exit 2, never pass, when it finds no trace files, when every trace lacks a `log` key, or when the
  recorded baseline total is non-zero while the observed total is 0. A gate that silently measures
  zero is the one failure mode worse than no gate, and a future Lake schema change is the realistic
  way it would happen.
- **Cross-check path**: keep a `--from-build` mode that re-derives the same numbers from
  `lake build FormalSystem BimodalTest $(python3 scripts/lake_targets.py exe-roots)` stdout
  (6s warm, schema-independent) for re-baselining and after any toolchain bump.
  `scripts/lake_targets.py` is already the single reader of `lakefile.toml` for target lists, so
  the target set stays correct when a target moves.
- **Final ratchet**: once the baseline is 0 everywhere, add `build-args: "--wfail"` to the
  lean-action step *in addition to* C26. Both, deliberately: `--wfail` is an immediate hard stop
  that also covers anything C26's trace walk might miss, while C26 supplies per-file/per-linter
  diagnostics and a reviewed escape hatch for the day an upstream deprecation lands mid-cycle.

**Blocking vs. advisory for `unusedTactic`/`unreachableTactic`.** The census recommends
advisory-only, on the strength of the `Invariants.lean:789-797` false positive — which is real and
verified above. This report recommends a narrower rule instead: **keep the class counted and
blocking after burn-down, with "fix or document" as the sanctioned resolution.** The repo has
already answered this exact situation twice, by deleting nothing and instead writing a
declaration-scoped `set_option linter.unusedTactic false in` above a comment recording the failed
deletion experiment. That escape hatch is cheap, is self-documenting, decays with the declaration,
and is explicitly *permitted* by task 597's blanket-suppression ratchet (which gates only the
`in`-less form). Advisory-only, by contrast, lets a 34-warning class regrow unobserved, and the
pressure the census rightly worries about — contributors deleting load-bearing tactics — is
relieved by naming suppression-with-evidence as an accepted outcome rather than by not counting.
Both dispositions should be recorded in the plan; if the implementer disagrees, advisory-only is a
defensible fallback, but it should be a decision, not a default.

### C16 disjointness is confirmed

`lake lint` / C16 runs Batteries' `env_linter` suite (`simpNF`, `docBlame`, `defsWithUnderscore`,
`structureInType`, `tacticDocs`, `unusedArguments`) against *declarations* in the built
environment, filtered through `scripts/nolints.json`'s 217 grandfathered findings. None of the ten
linters producing the 348 warnings above is in that suite; the sets are disjoint, as the task
description states. The hole is real.

## Decisions

- **Scope the gate to the full CI target set** (`FormalSystem` + `BimodalTest` + `lean_exe`
  roots), not to `lake build`'s default target. Otherwise 35 warnings and the whole
  `linter.defProp` class stay ungated.
- **Reject `--iofail`** on the record, with the reason: `MainResults.lean`'s 54 deliberate `info:`
  messages. cslib's precedent does not transfer.
- **Adopt option E as the gate**: a build-free C26 in `scripts/check-module-invariants.sh`, backed
  by `scripts/warning-budget.txt` keyed on `<count> <path> <linter>`. Treat
  `build-args: "--wfail"` as the closing ratchet after the count reaches zero, not as the
  mechanism, and reject `warningAsError` in `lakefile.toml` outright (it breaks local builds).
- **C26 must not invoke `lake`**, because CI runs the harness with `--no-build`; a build-dependent
  C26 would join C2/C6/C24 in the documented not-in-CI gap list.
- **Count `unusedTactic`/`unreachableTactic` and gate them**, resolving false positives by
  documented declaration-scoped `set_option … in` suppression rather than by excluding the class
  from the gate.
- **Note the stale spelling**: both the task description and report 01 refer to `lakefile.lean`.
  The package migrated to `lakefile.toml` (commit `089f35fe0`); there is no `lakefile.lean`.
- **Use `omit [...] in` for section variables** as the default fix; `variable`-line restructuring
  only where it is independently tidier.
- **Perform the `push_neg` substitution** rather than re-declaring a local `push_neg` macro.
- **Leave `FormalSystem/Boneyard/` out of scope** and say so explicitly in the summary: it is not
  compiled, so its ~130 `push_neg` occurrences cannot warn or break.
- **Correct `docs/development/CI_CD_PROCESS.md`'s four false `--wfail` claims** as part of the
  gate phase, not as a separate cleanup.

## Recommendations

Revised phasing (supersedes report 01's; same spirit, corrected counts and an added phase 0):

| Phase | Scope | Count | Character |
|---|---|---|---|
| 0 | Land C26 in `--list`/report-only form and commit the *current* baseline (348 over 56 files) before any fix | — | Makes every later phase's delta machine-verified |
| 1 | Deprecations: `push_neg` ×71, `IsTrichotomous`/`IsIrrefl` ×4, `String.takeRight`/`trimLeft` ×3, project-internal `negImp` ×4 | 82 | Mechanical, provably safe, highest forward-compat value |
| 2a | `SubformulaProperty.lean` alone (78) — per-site, per the census's edit discipline | 78 | Needs reading; no pattern-wide `sed` |
| 2b | `MintPotential.lean` 15, `TimeCensus.lean` 3, `Fuel.lean` 2, `OrientedGate.lean` 1 | 21 | Same discipline |
| 2c | Remaining unused simp args outside `Termination/`: `Tableau.lean` 9, `CountermodelExtraction.lean` 4, and 10 stragglers | 23 | Mechanical; census did not read these |
| 3 | Section variables ×85 via `omit … in`, plus measuring what the three blanket suppressions hide | 85 | Per-declaration, safe; hand 597 the hidden number |
| 4 | Unreferenced binder names ×36 (21 in `FormalSystem/`, 14 in `Tests/`, 1 in `Termination/`), `Try this: intro` ×14, `linter.defProp` ×10 (all test library) | 60 | Mechanical |
| 5 | Gate: baseline to 0, wire `build-args: "--wfail"`, and correct CI_CD_PROCESS.md | — | Coordinated with 597's per-linter need |

**Required deliverable, whichever gate is chosen**: `docs/development/CI_CD_PROCESS.md` must end up
describing what CI actually does. It currently documents a `build-args: "--wfail"` gate in four
places (lines 41-49, 69, 319, 343) that `.github/workflows/ci.yml` does not implement — there is no
`build-args`, no `--wfail`, and no `warningAsError` anywhere in `ci.yml` or `lakefile.toml`. This is
not a side cleanup: the stale documentation is part of why 348 warnings accumulated unchallenged,
and leaving it would make the new gate's documentation ambiguous on arrival.

The census's per-class blocking/advisory table is otherwise adopted as written: deprecations
blocking; `unusedSimpArgs` blocking after burn-down; unused binder names blocking; `Try this:`
suggestions advisory. Only its `unusedTactic` row is amended, per the discussion above.

Per-phase verification (all phases): `lake build` exits 0; `bash scripts/check-module-invariants.sh`
passes in full with C2 and C14 axiom baselines unmoved; no `sorry` introduced (C3); the warning
count drops by exactly the phase's expected delta and the baseline file is updated in the same
commit. Every `lake build` runs detached through
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build …`, per
`context/project/lean4/operations/long-builds.md`.

Phase-2 caution, from the census and confirmed by the file distribution: the 99
`Verified/Termination/` warnings must be edited **per site**, never by pattern —
`all_goals (try subst hg)` is dead at 9 of 15 occurrences, `(simp_all only []; done)` at 5 of 6,
the `mem_boxDiamondPersistence` alternative at 2 of 10. The 22 warnings attached to `first`-chain
alternatives are the case-by-case bucket and include the class with the verified false positive;
each is either deleted with a green build or suppressed with a recorded experiment, following
`Invariants.lean:789-797` as the model.

## Risks & Mitigations

- **Risk**: the gate depends on Lake replaying cached warnings; a future Lake could stop, and the
  ratchet would pass silently at 0. **Mitigation**: the anti-silence guard specified above (fail
  when the baseline is non-zero and the observation is 0, or when no module markers appear).
- **Risk**: deleting a "does nothing" tactic changes nothing *today* but may be load-bearing under
  a future Mathlib simp-set change. **Mitigation**: phase 2 reads each proof rather than bulk
  deleting, and C2/C14 axiom baselines plus a full green build bound the blast radius.
- **Risk**: a Mathlib bump lands mid-burn-down and adds a new deprecation class, re-reding a
  `--wfail` gate with no absorber. **Mitigation**: this is precisely why the baseline script, not
  `--wfail`, is the mechanism; `--wfail` is added only at the end and can be reverted to
  baseline-only in one line if a bump makes it untenable.
- **Risk**: task 597 un-suppresses the three blanket `linter.unusedSectionVars false` files and
  re-inflates the count after this task reports zero. **Mitigation**: measure the hidden count in
  phase 3 and record it in the summary so 597 baselines a known number.
- **Risk**: the recommended acquisition path reads Lake trace files, whose `schemaVersion` is
  `2025-09-10` and can change on a toolchain bump. **Mitigation**: the anti-silence guard turns a
  schema change into a loud exit 2 rather than a silent pass, and the `--from-build` cross-check
  mode (6s, stdout-based, schema-independent) is the re-baselining path and the post-bump
  verification.
- **Risk**: gating `unusedTactic` pressures a contributor into deleting a load-bearing tactic —
  the census's stated objection, backed by a verified in-tree false positive.
  **Mitigation**: name documented declaration-scoped suppression as an accepted resolution, with
  `Invariants.lean:789-797` as the worked example, so "fix" and "document why not" are both green
  outcomes. Advisory-only remains the fallback if that proves insufficient in practice.
- **Risk**: baseline regeneration used to launder a regression (the failure mode C16 warns about
  for `nolints.json`). **Mitigation**: copy that warning verbatim into the baseline file header and
  the script's own header; require the `--update` diff to be shown in the commit that contains it.

## Tactic Survey Results

Not applicable — no tactic survey was performed. This task removes tactics rather than searching
for them, and the goals in question are already closed. The relevant tactic-level evidence is the
dead-tactic inventory in "The cluster is real" above, which is produced by Lean's own
`linter.unusedTactic` / `linter.unreachableTactic` rather than by a search tool. The lean-lsp MCP
server was unavailable this session (`CONNECT_TIMEOUT`), so `lean_multi_attempt` /
`lean_hammer_premise` could not have been used in any case; nothing in this task's findings
depends on them.

## Context Extension Recommendations

- **Topic**: Lake log replay and cache-safe measurement.
  **Gap**: `context/project/lean4/operations/long-builds.md` explains detaching and guarding builds
  but says nothing about the fact that warnings and info messages are cached per module in
  `.lake/build/**/*.trace` and replayed on a cache hit — the property every measurement-based gate
  in this repo depends on, and one this repo's own `check-module-invariants.sh:685` currently
  assumes is false.
  **Recommendation**: add a short section to that file (or a sibling
  `operations/build-log-replay.md`) recording the measured behaviour, the `--wfail` interaction,
  the 6-second warm replay cost, and the stale-trace caveat.

## Appendix

Reproduction commands (all run from the repository root; builds detached and guarded):

```
# Full surface (348 warnings, 56 files)
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- \
  build FormalSystem BimodalTest $(python3 scripts/lake_targets.py exe-roots | tr '\n' ' ')
# count:   grep -c '^warning: '
# by file: grep '^warning: ' | sed 's/^warning: //' | awk -F: '{print $1}' | sort | uniq -c | sort -rn
# by linter: grep -o 'set_option [a-zA-Z.]*linter[a-zA-Z.]* false' | sort | uniq -c | sort -rn

# Warm-cache --wfail behaviour (exit 1, 313 warnings on the default target)
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build --wfail

# Trace-scan alternative (0.05s): read .lake/build/lib/lean/**/*.trace, take log[].level == "warning",
# drop entries whose source path no longer exists (8 stale right now).
```

Key source references:
- `.lake/packages/mathlib/Mathlib/Tactic/Push.lean:281-292`, `:348-354` — `push_neg` deprecation
- `.lake/packages/mathlib/Mathlib/Tactic/Linter/UnusedTactic.lean:208` — "tactic does nothing"
- `.lake/packages/mathlib/Mathlib/Tactic/TacticAnalysis/Declarations.lean:577-599` —
  `linter.tacticAnalysis.introMerge`, `defValue := true`
- `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/src/lean/Lean/Elab/MutualDef.lean:497,565,578`
  — `linter.unusedSectionVars`
- `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/src/lean/Lean/Linter/UnusedSimpArgs.lean:26,40`
  — `Tactic.linter.unusedSimpArgs`, and the `←`-argument caveat
- `~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/src/lean/Lean/Linter/DefProp.lean:26,50`
  — `linter.defProp`
- `~/Projects/cslib/.github/workflows/lean_action_ci.yml:20-56` — the `--wfail --iofail`
  precedent and its recorded permanently-red status
- `~/Projects/cslib/scripts/check-lint-suppressions.sh:1-45` and
  `~/Projects/cslib/scripts/lint-suppression-baseline.txt` — the ratchet template
- `scripts/check-module-invariants.sh:683-690` (C2 and its replay assumption), `:2075-2090` (C16
  scope and the never-regenerate rule)
- `docs/development/CI_CD_PROCESS.md:41-49, 69, 170-260, 319, 343`
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/Invariants.lean:789-797` and
  `MintBound/UntlSnceFree.lean:352` — the two in-tree `linter.unusedTactic` false positives, with
  the twelve unsolved goals recorded in the first
- Peer census of the 99 `Verified/Termination/` warnings (parallel agent, this session): commit
  identifiers `ed28604ac`, `5b82a7ef9`, `6b2be0db8`, `29b9cea6f`, `2deea9dd2`; its scope figure,
  per-file split and recurring-simp-argument frequencies were re-derived independently here and
  agree exactly
