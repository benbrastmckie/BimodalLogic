# Implementation Plan: Systematic Mathlib Naming Upgrade

- **Task**: 402 - systematic_mathlib_naming_upgrade
- **Status**: [IMPLEMENTING]
- **Effort**: 25 hours (8 phases, 12 dispatch units)
- **Dependencies**: None
- **Research Inputs**:
  - specs/402_systematic_mathlib_naming_upgrade/reports/01_mathlib-naming-upgrade-mechanism.md
  - specs/175_naming_convention_and_bridge_cleanup/reports/01_team-research.md
  - specs/175_naming_convention_and_bridge_cleanup/reports/01_teammate-a-findings.md
- **Artifacts**: plans/01_mathlib-naming-upgrade-migration.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
  - .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4

## Overview

Rewrite the repository's identifier graph to Mathlib naming conventions in one coordinated
migration: Part A moves `Theories/Bimodal/` to `FormalSystem/` and renames the root namespace;
Part B migrates 861 snake_case `def` names to Mathlib casing; Part C folds semantic
abbreviation-expansion into the same target names so each declaration's final name is derived
once from all three dimensions and written once. The mechanism is settled by experiment: a
guarded, suffix-anchored `.ilean`-driven rewriter, proven end-to-end on `Bimodal.Semantics.truth_at`
(504 edits / 19 files / 0 guard rejections / 8 loud build errors / patched / green / reverted).

**Definition of done**: `lake build` green with no new errors; `BimodalTest` green; the sole live
`sorry` (inside `theorem countermodel_discrete` in `Metalogic/WeakCanonical/Transfer.lean`, located
by content) unchanged; `scripts/nolints.json` deleted; `lake exe batteries/runLinter FormalSystem`
reports `defsWithUnderscore = 0`.

### Research Integration

| Report | Integrated |
|---|---|
| `reports/01_mathlib-naming-upgrade-mechanism.md` | Mechanism, baseline, derivation rule, verification layers, scope decisions |
| `175/reports/01_team-research.md` | Part C rename inventory, Bridge.lean correction, deferral of `bx_` |
| `175/reports/01_teammate-a-findings.md` | Concrete per-declaration Part C rename tables (Categories 1, 2, 5, 6) |

### Preserved Assets

No prior plan exists for this task. The following completed work must not regress:

| Asset | Location | Status | Verified |
|---|---|---|---|
| Green build (1884 jobs) | whole tree | baseline | 2026-07-26 (research session) |
| Sole live `sorry`, count = 1 | `Metalogic/WeakCanonical/Transfer.lean`, `theorem countermodel_discrete` | baseline | 2026-07-26 |
| `BimodalTest` suite green | `Tests/BimodalTest/` | baseline | 2026-07-26 |
| Reverted rename experiment | `specs/402_.../working-progress-1785114897.patch`, `git stash@{0}`, tag `git-snapshot-1785114897` | recoverable seed for the rewriter | 2026-07-26 |
| Archived linter harnesses | `specs/archive/400_.../tools/`, `specs/archive/399_.../tools/` | reference (not executed against current tree) | assessed only |
| `scripts/nolints.json`, 860 entries | `scripts/nolints.json` | interim checkpoint, deleted in Phase 8 | byte-verified 2026-07-26 |

### Source-to-Implementation Mapping (H3, grounding tier: code)

Every load-bearing decision below traces to a measurement in the research report.

| Measured finding | Value | Acts on it | Citation |
|---|---|---|---|
| Unmasked `defsWithUnderscore` | 861 (masked 1; `nolints.json` = 860 entries) | Phase 1 baseline, Phase 8 proof | report "Measured Baseline" |
| Category split | 554 data / 185 DerivationTree / 121 `-> Prop` / 1 proof-valued | Phase 5.1 classifier | report "Declaration inventory" |
| `-> Prop` predicates are NOT theorem-convertible; want UpperCamelCase | 121 | Phase 5.2 three-branch casing rule | report "Two categories needing bespoke handling" |
| Resolved usages of the 861 targets | 24,482 across 295 modules | Phase 6.1 single-pass edit set | report "Reference graph" |
| Written-form split | 83.46% bare / 16.01% qualified / 0.53% dot | Phase 1 suffix-anchoring guard | report "Mechanism: recommendation" |
| Round-trip exactness | 99.77% over 129,611 ranges | Phase 1 self-test acceptance bar | report "round-trip validation at scale" |
| Guard-reject classes (wildcard `_`, keyword, `«»`) | 94 + 92 + 4 | Phase 1 guard, Phase 6.1 rejection report | report "Full mismatch taxonomy" |
| Prefix collision among target finals | 400 / 848 = 47.2% | Phase 5.2 collision audit; forbids substring replace | report "Prefix collision" |
| LSP rename writes `newName` verbatim | `Watchdog.lean:1207` | mechanism disqualified; not used anywhere | report "Rejected - LSP rename" |
| `.ilean` coverage gap | 8/512 = 1.6% on the experiment; ~390 projected (Low confidence) | Phase 6.2 build-fix loop | report "The decisive experiment" |
| `import`/`namespace`/`open`/`end` carry ZERO `.ilean` coverage | 1,581 + 903 + 1,324 lines | Phase 2 and Phase 3 use a syntactic pass, not the rewriter | report "Critical structural finding" |
| Part A qualified term refs | 554 + 25 `_root_.` | Phase 3 | report "Part A surface, measured" |
| Single-snapshot constraint (untested) | all edits from one `.ilean` snapshot, one pass, right-to-left | Phase 6.1 | report "Critical design constraint" |
| Silent-staleness inventory | 7,047 comments / 682 strings / 812 backtick-in-doc / 6 code backticks / docs 695 / typst 94 / latex 3 | Phase 7 | report "Silent-staleness inventory" |
| Stale `.ilean` survive file moves | 5 present now | Phase 1 (`lake clean`), Phase 4.2 (Bridge rename) | report "Two operational traps" |
| Linter pretty-prints `@Name` | loses 425/861 if unstripped | Phase 1 `runlinter.py` repair | report "Two operational traps" |
| Boneyard inert | 0 `.ilean`, 0 imports; 8,718 stale refs is the accepted cost | Non-Goals; Phase 8 README note | report "Scope decisions, argued" |
| 19 `tactic*` syntax declarations have no `.ilean` definition entry | 19 | Phase 8 decision | report "Two categories needing bespoke handling" |
| Part C active scope | ~13 propositional abbrevs (328 tokens), 22 `temp_`, `dd_` 7, `bfmcs` 2 | Phase 4 (deletions) + Phase 5.2 (word map) | 175 team-research + teammate-a Categories 1/2/5/6 |
| Deprecation shims backfire | an alias is itself a snake_case `def` | Postmortem constraint 3 | report recommendation 9 |

## Postmortem Constraints

Binding rules for every implementation dispatch on this task. Read before touching any file.

**Do NOT**:

1. **Do NOT use global substring replacement on any identifier.** 400 of 848 target final
   components (47.2%) are a proper prefix of another project identifier (`A_diag` in
   `A_diag_correct`, `F_mono` in `F_mono_mcs`). Position-anchored, resolved-reference rewriting is
   the only sanctioned mechanism for declaration names.
2. **Do NOT replace the bare token `Bimodal` textually without a boundary guard.** Six real
   identifiers begin with `Bimodal`: `BimodalTest`, `BimodalHarness`, `BimodalLogic`,
   `BimodalProofs`, `BimodalReference`, `BimodalIntegrationTest`. Part A's pattern must be
   `Bimodal` followed by `.` or a non-identifier character, and must exclude these six by name.
   This was measured against the current tree, not assumed.
3. **Do NOT add `@[deprecated]` aliases, forwarding shims, or `abbrev` bridges for renamed
   declarations.** An alias is itself a snake_case `def`, so `defsWithUnderscore` counts it and the
   number goes UP. This is the mechanism behind the task's warning, confirmed.
4. **Do NOT compute Part B edits from more than one `.ilean` snapshot, and do NOT apply them in
   more than one pass.** Rewriting one declaration at a time shifts UTF-16 columns for every other
   target on the same line. Within a file, apply edits per line, right-to-left.
5. **Do NOT treat a green `lake build` as evidence about `defsWithUnderscore`.** The linter emits
   nothing during `lake build`, and CI runs `lean-action` with `lint: false`. Every count in every
   report must come from an explicit `lake exe batteries/runLinter <root>` run. Plain
   `lake exe runLinter` fails - the package declares no `lintDriver`.
6. **Do NOT locate the live `sorry` by line number.** Anchor on `theorem countermodel_discrete` in
   `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (post-Part-A: `FormalSystem/...`).
   It is at line 1242 today and will move.
7. **Do NOT rewrite `Theories/Bimodal/Boneyard/` (post-move `FormalSystem/Boneyard/`).** It has 0
   `.ilean` artifacts and 0 imports from active code, so the resolved-reference mechanism
   structurally cannot cover it, and a textual pass there faces the full 47.2% prefix hazard with
   no build to catch errors. Its 8,718 stale references are an accepted, recorded cost.
8. **Do NOT rewrite guard-rejected ranges by hand without classifying them first.** The 94 wildcard
   `_` holes and 92 keyword/anonymous-decl sites are exactly the ranges a naive rewriter corrupts
   into syntactically valid nonsense. A rejection is a correct outcome, not a bug to work around.
9. **Do NOT reopen the naming policy.** Full Mathlib conformance is decided. Do not propose partial
   conformance, per-directory exemptions, or a new `nolints.json`.
10. **Do NOT begin any Phase 6 edit before the Phase 5.2 target-name table has been reviewed.**
    The table is the "derive once" artifact; deriving names during the rewrite defeats its purpose.

**MUST**:

11. **MUST run `lake clean && lake build` before generating any `.ilean`-derived edit set.** Five
    stale `.ilean` files exist right now with no corresponding source. The rewriter must
    additionally skip any `.ilean` whose module has no source file.
12. **MUST strip the linter's leading `@`** when parsing its output. It pretty-prints `@Name` for
    declarations with implicit arguments; not stripping it silently loses 425 of 861 names.
13. **MUST rewrite the fully-qualified namespace prefix inside `scripts/nolints.json` during
    Phase 3.** Its 860 entries are fully-qualified (`["defsWithUnderscore",
    "Bimodal.Automation.apply_modal_k"]`). The namespace rename makes every one of them match
    nothing, silently unmasking all 861 findings mid-migration and destroying the drift metric.
14. **MUST commit at every green milestone**, scoped per `.claude/context/standards/git-staging-scope.md`.
    Never `git add -A`, never `git commit -am`.
15. **MUST run `bash .claude/scripts/git-snapshot.sh 402` before any destructive git operation** on
    a dirty tree.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- **Mechanism**: guarded, suffix-anchored, `.ilean`-driven rewriter. Lean's own workspace LSP
  rename is rejected - `handleRename` (`Watchdog.lean:1207`) writes `newText := p.newName` verbatim,
  destroying the 16.01% of ranges carrying a namespace qualifier and the 0.53% dot-notation ranges.
- **Ordering**: Part A strictly before Part B. Running the namespace rename after the casing rewrite
  churns all 24,482 sites a second time and invalidates the verification baseline.
- **The 121 `-> Prop` predicates get UpperCamelCase and are NOT convertible to `theorem`.**
  `α → Prop` has type `Type`, not `Prop`; the conversion is a type error, not a judgment call.
  Exactly 1 proof-valued `def` exists; convert that one to `theorem` and it leaves the linter's
  scope entirely.
- **`Bridge.lean` is NOT a forwarding wrapper.** It holds 25 substantive definitions
  (`box_mono` 29 refs, `diamond_mono` 12, `perpetuity_6` 6, `bridge1`/`bridge2` feeding P6). Do not
  delete it wholesale. Only `dne`, `lce_imp`, `rce_imp`, and the three `local_*` re-implementations
  are inlineable.
- **`bx_completeness` does not exist in source.** The real theorem is `completeness_discrete`
  (`Metalogic/BXCanonical/Completeness.lean:302`). Documentation references only.
- **The `bx_` prefix is OUT of scope** (~25 defs / ~134 refs), deferred by the Part C team research
  on blast-radius-vs-value grounds. `drm`, `tc_`, `fuc_`, `buc_`, `sdc` need no active code changes.
- **`Tests/` is IN**, not a judgment call: it is a `lean_lib` built by `lake build`, and its
  `.ilean` files are already inside the 24,482-usage count. Omitting it means a red build.

## Goals & Non-Goals

**Goals**:
- Move `Theories/Bimodal/` to `FormalSystem/`; rename root namespace `Bimodal` to `FormalSystem`;
  update `lakefile.lean` (`srcDir`, `roots`, and all 13 `lean_exe` roots), every import, every
  qualified reference, `README.md`, `Tests/`, and all non-Lean path references.
- Derive a single target name per flagged declaration from all three dimensions (Part C semantics,
  Mathlib casing, def/theorem status) and rewrite once.
- Reach `defsWithUnderscore = 0` by genuine conformance with `scripts/nolints.json` deleted.
- Eliminate the enumerated silent-staleness classes the build cannot catch.
- Preserve: green build, green `BimodalTest`, sorry count = 1.

**Non-Goals**:
- `Theories/Bimodal/Boneyard/` identifiers (8,718 stale references accepted and recorded).
- The `bx_` prefix removal in `Metalogic/BXCanonical/` (~134 refs) - deferred.
- `drm`, `tc_`, `fuc_`, `buc_`, `sdc` - zero or Boneyard-only active occurrences.
- Renaming `BFMCS`, `FMCS`, `MCS`, `imp_trans`, `b_combinator`, `mp` - established abbreviations
  with formal definitions, deliberately kept.
- File splitting, module reorganization, or any refactor that is not a rename.
- Re-opening the naming policy or introducing a replacement suppression file.

## Risks & Mitigations

- **Risk**: The single-pass rewrite leaves the tree red longer than one dispatch can sustain
  (Phase 6.1 ends red by construction). **Mitigation**: 6.1 and 6.2 are declared a paired unit;
  6.1 must end with `git-snapshot.sh 402` plus a written `guard-rejections.md` and
  `build-errors-initial.txt` so 6.2 can resume from an artifact, not from memory. Contingency
  below if 6.2 does not converge.
- **Risk**: The ~390 build-caught `.ilean` gap sites figure is Low confidence, extrapolated from a
  single declaration. **Mitigation**: Phase 6.2 drives the fix loop from a script that parses
  `Unknown identifier X` out of build output and applies the same name map, so cost scales with a
  cheap loop rather than with hand edits. Phase 6.2 records the true count.
- **Risk**: A target name collides with an existing identifier after casing/semantic substitution.
  **Mitigation**: Phase 5.2 runs a collision audit against the full project identifier set and
  Lean/Mathlib core names before the human review gate; the known `and_left`/`and_right` case
  (`PointInsertion.lean:1193`, `Hierarchy.lean:2463`, `DedekindZ.lean:691`, plus core `And.left`)
  is checked explicitly.
- **Risk**: `nolints.json` silently unmasks after Part A, making every interim linter number
  meaningless. **Mitigation**: Postmortem constraint 13 - rewrite its prefix in Phase 3.
- **Risk**: `Automation/ProofStepExport.lean` writes declaration names into ML training JSONL; stale
  strings there are load-bearing, not cosmetic, and the build cannot catch them.
  **Mitigation**: Phase 7.1 names this file as a mandatory, individually-verified item.
- **Risk**: Renaming the 19 `tactic*` declarations is a user-facing API change disguised as a naming
  cleanup. **Mitigation**: Phase 8 applies a written decision rule and records the outcome; these 19
  do not gate the other 842.
- **Risk**: Two research claims are `[UNVERIFIED]` (whether the 20 active `cud` tokens are
  comments-only; whether the archived harnesses still execute). **Mitigation**: both are resolved in
  Phase 1 before any edit depends on them.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7.1, 7.2 | 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. **This plan is deliberately near-sequential**:
every phase from 2 through 6 mutates the same resolved-reference graph or the snapshot derived from
it, so territory overlap is total and parallelism would be unsound rather than merely inefficient.
Wave 7 is the one genuine parallel opportunity - 7.1 and 7.2 own disjoint file trees.

**Territory contracts (H7)**:

| Phase | Owns (exclusive write access) | Must not touch |
|---|---|---|
| 1 | `specs/402_.../tools/`, `specs/402_.../baseline/` | any source file |
| 2 | `lakefile.lean`, all `.lean` file paths, `import` lines | `namespace`/`open`/`end` lines, declaration bodies |
| 3 | `namespace`/`end`/`open` lines, `Bimodal.`-qualified term refs, `scripts/nolints.json`, `README.md`, `docs/`, `typst/`, `latex/` path strings | declaration final components |
| 4 | `Theorems/Propositional.lean`, `Theorems/Combinators.lean`, `Theorems/Perpetuity/Bridge.lean`, `ProofSystem/Axioms.lean`, `Metalogic/BXCanonical/Completeness.lean`, `Metalogic/Algebraic/AlgebraicCompleteness.lean`, `Bundle/FMCS.lean`, `Bundle/CanonicalFrame.lean`, `Metalogic/.../TemporalDerived.lean`, `Metalogic/.../TemporalClosure.lean` | anything outside the enumerated deletion/inline set |
| 5 | `specs/402_.../tools/`, `specs/402_.../target-names/` | any source file (read-only phase) |
| 6 | every built `.lean` file under `FormalSystem/` (excluding `Boneyard/`) and `Tests/` | `docs/`, `typst/`, `latex/`, `Boneyard/` |
| 7.1 | string literals / comments / docstrings / backtick sites inside `FormalSystem/` and `Tests/` | `docs/`, `typst/`, `latex/`, any elaborated code |
| 7.2 | `docs/`, `typst/`, `latex/`, `README.md` | any `.lean` file |
| 8 | `scripts/nolints.json` (delete), `docs/development/NAMING_CONVENTION_DEVIATION.md`, the 19 tactic declaration sites, `FormalSystem/Boneyard/README.md` | anything else |

---

### Phase 1: Baseline capture and rewriter harness [COMPLETED]

- **Goal:** Produce the two tools the whole migration depends on, prove the rewriter's guard against
  the full reference corpus, freeze the numeric baseline, and resolve the two `[UNVERIFIED]` research
  claims - all before any source file is touched.
- **Tasks:**
  - [x] `lake clean && lake build`; confirm green and record the job count. This eliminates the 5
        stale `.ilean` files (`Bimodal.Metalogic.Metalogic`, `Bimodal.Metalogic.Completeness`,
        `Bimodal.Metalogic.BXCanonical.BXCanonical`,
        `Bimodal.Metalogic.WeakCanonical.WeakCanonical`, `Bimodal.Automation.EFGameTactics`). *(deviation: altered — build was already green at 1884 jobs and fully cached; the five stale `.ilean` files were deleted directly and `ilean.py` skips any `.ilean` whose module has no source, achieving constraint 11 without discarding a valid build. A full clean rebuild is forced by Phase 2 regardless.)*
  - [x] Recover `runlinter.py` from `specs/archive/400_clear_lean_v433_deprecation_warnings/tools/`
        into `specs/402_.../tools/`. Repair its `ROW` regex to strip the pretty-printer's leading
        `@`. Preserve its documented trap handling: the header regex opens `/-` not `/--`;
        `LINTER FAILED` has two row shapes and appears mid-message; raw `lean` emits
        `PATH:L:C: severity: msg` while lake emits `severity: PATH:L:C: msg`.
  - [x] Capture baseline into `specs/402_.../baseline/`: masked linter run (expect
        `defsWithUnderscore = 1`, 247 rows); `nolints.json` moved aside, unmasked run (expect 861,
        1107 rows); restore `nolints.json` and byte-verify it identical (860 entries). Record the
        other categories (`unusedArguments` 124, `simpNF` 78, `docBlame` 39, `tacticDocs` 4,
        `structureInType` 1) so Phase 8 can prove no regression outside the target category.
  - [x] Record the sole live `sorry` by content: `theorem countermodel_discrete` in
        `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`. Write a `check-sorry.sh` that
        locates it by theorem name and asserts the repository-wide live count is 1.
  - [x] Write `tools/ilean.py`: load all project `.ilean` files (v5 schema, `references` keyed by
        `{"c":{"m":module,"n":name}}`, 0-indexed lines, UTF-16 code-unit columns); skip any `.ilean`
        whose module has no source file.
  - [x] Write `tools/rename.py` (seed: the reverted experiment in
        `specs/402_.../working-progress-1785114897.patch` / `git stash@{0}` / tag
        `git-snapshot-1785114897`): for each recorded range, extract the source text; **guard** that
        it ends with the old final component; replace only the trailing final-component sub-span;
        reject and report everything else. Apply per file, per line, right-to-left. Must handle
        `_root_.`-qualified refs and parenthesized spans via the suffix rule, and `«»`-escaped
        identifiers explicitly.
  - [x] Run the round-trip self-test over all recorded ranges for project declarations.
        **Acceptance bar**: >= 99.7% exact suffix match (research measured 99.77% of 129,611), and
        the mismatch taxonomy must reproduce the four known buckets (wildcard `_`, keyword/anon,
        `_root_.`, `«»`). Any new bucket blocks the phase.
  - [x] Resolve `[UNVERIFIED]` claim 1: inspect all 20 active `cud` tokens; classify each as
        comment or code. Record the verdict.
  - [x] Resolve `[UNVERIFIED]` claim 2: execute the archived harnesses from
        `specs/archive/399_.../tools/` and `specs/archive/400_.../tools/` against the current tree.
        Record which run and which are reference-only.
- **Estimated output:** ~300 lines (Python tooling + baseline JSON + a short findings note)
- **Done when:** `tools/rename.py --self-test` passes the >= 99.7% bar with no unknown mismatch
  bucket; `tools/runlinter.py` reproduces 861 on an unmasked run; `baseline/` holds both linter
  runs; `nolints.json` byte-identical to its pre-run state; both `[UNVERIFIED]` claims resolved in
  writing.
- **Tree at phase end:** GREEN (no source file modified).
- **Timing:** 2-3 hours
- **Depends on:** none

---

### Phase 2: Part A-1 - module path rename [COMPLETED]

- **Goal:** Move the library to `FormalSystem/` and make every module path resolve, leaving the
  `Bimodal` *namespace* untouched. Module name and namespace are independent in Lean, so this is a
  separately-green-able change.
- **Tasks:**
  - [x] `git mv Theories/Bimodal FormalSystem`; `git mv FormalSystem/Bimodal.lean
        FormalSystem/FormalSystem.lean`. `Theories/` is left empty and removed. *(deviation: altered — the root module `Theories/Bimodal.lean` became `FormalSystem.lean` at the repository root, matching the Mathlib layout the new `srcDir := "."` implies; `Theories/README.md` was deleted rather than moved, since all 33 of its lines describe the removed `Theories/` layout and its "Adding a New Theory" instructions are now wrong. `FormalSystem/README.md` (315 lines) is the surviving library doc.)*
  - [x] `lakefile.lean`: `lean_lib Bimodal` -> `lean_lib FormalSystem`, `srcDir := "Theories"` ->
        `srcDir := "."` (or the layout that matches the new root), `roots := #[\`Bimodal]` ->
        `#[\`FormalSystem]`. Update **all 13 `lean_exe` roots** (`dataset_generator`,
        `dataset_validator`, `proof_extractor`, `enum_benchmark`, `benchmark_anchors`, and the
        remainder) - each carries its own `root := \`Bimodal.…` and `srcDir := "Theories"`.
  - [x] Rewrite all 1,581 `import Bimodal…` lines to `import FormalSystem…`, line-anchored on
        `^import Bimodal(\.|$)`. Includes `Tests/BimodalTest/**`.
  - [x] Apply postmortem constraint 2: the pattern must not match `BimodalTest`, `BimodalHarness`,
        `BimodalLogic`, `BimodalProofs`, `BimodalReference`, `BimodalIntegrationTest`. Grep for all
        six after the pass and confirm each is unchanged.
  - [x] `lake build`; fix any residual module-resolution error. *(deviation: altered — one residual class the import pass structurally could not see: `open private … from <Module>` clauses carry a module path that is not an `import` line. Three such clauses in `NfMultiAnchorBridge/{InteriorGateGeneralK,ExteriorGateAssembleK}.lean` were rewritten via a `from`-anchored pattern. This was the ONLY build failure.)*
- **Estimated output:** ~200 lines (a line-anchored rewrite script + lakefile diff + build fixes)
- **Done when:** `lake build` green; `BimodalTest` green; `grep -rn "import Bimodal" --include=*.lean`
  returns nothing; all six `Bimodal*` identifiers verified intact; sorry count still 1.
- **Tree at phase end:** GREEN.
- **Timing:** 1.5-2 hours
- **Depends on:** 1

---

### Phase 3: Part A-2 - root namespace rename and path references [COMPLETED]

- **Goal:** Rename the root namespace `Bimodal` to `FormalSystem` everywhere it is written, repair
  `scripts/nolints.json`, and update every non-Lean reference to the old directory path.
- **Tasks:**
  - [x] Rewrite the 903 `namespace Bimodal…` / `end Bimodal…` lines and the 1,324 `open Bimodal…`
        occurrences with a line-anchored syntactic pass. These carry **zero** `.ilean` coverage and
        cannot be done by `rename.py`. *(deviation: altered — implemented as a lexer-guarded pass (`tools/leanmask.py`) rather than a line-anchored one. `Bimodal` is also the LOGIC's name, so a line-anchored pass cannot tell `namespace Bimodal.Syntax` from the prose "the Bimodal library". The mask separates code from comments/strings by depth-counting nested `/- -/` and string literals: 3,669 code identifiers rewritten, 221 qualified `Bimodal.X` references inside docstrings rewritten as stale references, and 343 bare prose mentions of the logic deliberately left intact.)*
  - [x] Rewrite the 554 term references written as `Bimodal.…` and the 25 written as
        `_root_.Bimodal…`. These *are* `.ilean`-covered; either mechanism is sound here, but the
        boundary guard from postmortem constraint 2 is mandatory either way.
  - [x] **Rewrite the namespace prefix inside `scripts/nolints.json`**: all 860 entries are
        fully-qualified (`["defsWithUnderscore", "Bimodal.Automation.apply_modal_k"]`) and match
        nothing after the rename. Without this, the interim `defsWithUnderscore` reading jumps from
        1 to 861 for reasons unrelated to progress. Verify with a masked linter run reporting 1
        (or 2, allowing the one known drift entry `temp_linearity_derivation`).
  - [x] Update non-Lean path references *(deviation: altered — scope grew beyond docs/typst/latex/scripts once `scripts/check-module-invariants.sh` was run: its own module-path resolver, import regex, reachability roots, and embedded axiom baseline all encoded the old layout. Repairing them surfaced pre-existing under-matching — C4 went from checking 50 import lines to 1,078, and C5 from a broken resolver to 1,612 markdown files — and the suite now reports ALL CHECKS PASSED.)* (~111 files): `README.md`, `docs/` (56 files), `typst/`
        (21), `latex/` (21), `scripts/` (12). These are path/namespace references only; declaration
        names are Phase 7's territory.
  - [x] `lake build`; run the linter masked and confirm the count is back to its baseline value.
- **Estimated output:** ~250 lines (rewrite script + nolints prefix repair + non-Lean sweep)
- **Done when:** `lake build` green; `BimodalTest` green; sorry count 1;
  `grep -rn "\bBimodal\b" --include=*.lean FormalSystem/ Tests/` returns only Boneyard and prose
  comments; masked linter reports the baseline `defsWithUnderscore` value; the six `Bimodal*`
  identifiers intact.
- **Tree at phase end:** GREEN. **Commit - this is the Part A completion checkpoint.**
- **Timing:** 2-3 hours
- **Depends on:** 2

---

### Phase 4: Part C structural cleanup [COMPLETED]

- **Goal:** Delete, inline, and unify everything Part C calls for that is *not* a rename, so the
  Phase 5 target-name table is derived over the final declaration set rather than over declarations
  that are about to disappear.

#### Phase 4.1: Dead-code deletion, alias removal, trivial-wrapper inlining [COMPLETED]

- **Goal:** Remove declarations with zero callers and inline the confirmed trivial wrappers.
- **Tasks:**
  - [x] Verify-then-delete the four zero-caller propositional declarations: `ni`
        (`Propositional.lean:1507`), `ne` (`:1531`), `de` (`:1614`), `bi_imp` (`:1562`). Re-verify
        zero callers against the current tree before each deletion - line numbers are from the Part
        C audit and will have drifted. *(deviation: altered — the re-verification the plan mandates
        overturned three of the four. Measured with `tools/refcount.py` against the resolved
        `.ilean` graph, not grep: `ni` has a LIVE caller
        (`Metalogic/Decidability/Propositional/Kalmar.lean:67`); `de` is used by
        `or_elim_neg_neg` in its own file; `bi_imp` carries `@[tm_lemma]`, so it is reachable
        through `modal_search`'s proof-search database and produces NO `.ilean` usage at all —
        a reference count of 0 is not evidence of deadness for an attribute-registered
        declaration. Only `ne` (0 usages, no attribute) was deleted. The other three are
        KEPT, each for a recorded reason.)*
  - [x] Delete the unused aliases: `completeness'` (`BXCanonical/Completeness.lean:176`),
        `algebraic_completeness_theorem'` (`Algebraic/AlgebraicCompleteness.lean:187`),
        `minimalFrameClass` (`ProofSystem/Axioms.lean:412`).
  - [x] Inline `canonicalR_transitive` -> `existsTask_transitive` (`Bundle/CanonicalFrame.lean:268`,
        1 call site). *(deviation: altered — 1 call site
        (`Metalogic/Algebraic/ParametricCanonical.lean:141`), not 3, and the alias was at
        `CanonicalFrame.lean:285`. The alias was written `abbrev … := @existsTask_transitive`,
        so the inline had to drop the `@` — `existsTask_transitive` takes `{fc : FrameClass}`
        implicitly, and keeping the `@` shifted `M.val` into the `fc` position.)*
  - [x] In `Theorems/Perpetuity/Bridge.lean`: inline `dne` -> `Propositional.double_negation`
        (7 refs); remove the duplicate `lce_imp` and `rce_imp` (0 qualified callers); attempt removal
        of `local_efq` / `local_lce` / `local_rce` by redirecting to the `Propositional` versions.
        **If the circular import between `Propositional` and `Perpetuity` cannot be broken, keep the
        three `local_*` definitions and record why** - the Part C research explicitly left this
        unresolved. Do not restructure the import graph to force it. *(deviation: altered — the feared
        circular import DOES NOT EXIST: no module under `Theorems/Propositional/` imports
        `Perpetuity`, and `Bridge.lean` already imports `Propositional.Connectives` (which
        re-exports `Propositional.Core`). All three `local_*` re-implementations were therefore
        removed, not kept: `local_efq`/`local_lce`/`local_rce` have signatures IDENTICAL to
        `Propositional.efq`/`lce`/`rce` and were redirected to them. `dne` was a one-line alias
        for `Propositional.double_negation` (3 uses, not 7). The duplicate `lce_imp`/`rce_imp`
        were repointed at the FrameClass-generic `Propositional` versions. 276 lines removed
        from Bridge.lean with no import-graph restructuring.)*
  - [x] **Do not touch** the 25 substantive Bridge definitions (`box_mono` 29 refs,
        `diamond_mono` 12, `past_mono` 5, `perpetuity_6` 6, `bridge1`, `bridge2`,
        `double_contrapose`, the duality and always-decomposition lemmas).
- **Estimated output:** ~150 lines of diff
- **Done when:** `lake build` green; `BimodalTest` green; sorry count 1; each deleted name returns
  zero hits outside Boneyard.
- **Tree at phase end:** GREEN.
- **Timing:** 2 hours
- **Depends on:** 3

#### Phase 4.2: File rename, definition unification, re-export removal [COMPLETED]

- **Goal:** Structural tidy-ups that change module paths, done before the snapshot Phase 5/6 depends
  on.
- **Tasks:**
  - [x] Rename `Theorems/Perpetuity/Bridge.lean` -> `Theorems/Perpetuity/MonotonicityDuality.lean`
        (its content is duality and monotonicity proofs for P6, not a bridge). Update the importing
        modules and any `namespace` block naming.
  - [x] Unify `Formula.top`: `private abbrev top = Formula.neg Formula.bot` (`TemporalDerived.lean:62`)
        vs `abbrev Formula.top = .imp .bot .bot` (`TemporalClosure.lean:515`). Pick one canonical
        form, delete the other, repoint callers. *(deviation: altered — `TemporalClosure.lean`
        no longer exists. The canonical `Formula.top` is `Syntax/Formula.lean:118`
        (`Formula.bot.imp Formula.bot`, 440 resolved usages). The `private abbrev top` at
        `TemporalDerived.lean:98` had ZERO usages and a semantically different body
        (`Formula.neg Formula.bot`) — a dead private shadow, deleted outright. No caller
        repointing was needed.)*
  - [x] Remove the `Bundle/FMCS.lean` re-export file (17 lines, pure re-export of `FMCSDef.lean`) by
        repointing its importers. *(deviation: altered — 2 importers, `Metalogic/Bundle.lean`
        and `Bundle/BFMCS.lean`, both repointed to `Bundle.FMCSDef`.)*
  - [x] `lake clean && lake build` - the file rename creates a stale `.ilean` exactly like the five
        found in research; a plain incremental build will leave it behind.
- **Estimated output:** ~120 lines of diff
- **Done when:** `lake build` green from a clean state; `BimodalTest` green; sorry count 1; no
  `.ilean` file exists whose module has no source.
- **Tree at phase end:** GREEN. **Commit - declaration set is now final.**
- **Timing:** 1.5-2 hours
- **Depends on:** 4.1

---

### Phase 5: Target-name derivation table [COMPLETED]

- **Goal:** Produce, in one artifact, the single target name for every remaining flagged
  declaration - derived from Part C semantics, then Mathlib casing, then def/theorem status - and
  gate it on human review. **No source file is edited in this phase.**

#### Phase 5.1: Environment classifier and category export [COMPLETED]

- **Goal:** Recover the per-declaration result-type category from the Lean environment, since the
  casing branch is a function of the category and cannot be inferred from the name.
- **Tasks:**
  - [x] Write `tools/Classify.lean`: `import FormalSystem`, walk `ConstantInfo`, telescope the result
        type with `forallTelescopeReducing`, and classify each linter-flagged declaration as
        `data` / `prop_valued_definition` / `sort_or_type` / `proof_valued_def`.
  - [x] Run the unmasked linter to get the current flagged set (baseline 861, minus the Phase 4
        deletions). Cross-check the split against the research baseline: 554 data / 185
        DerivationTree-valued / 121 `-> Prop` / 1 proof-valued. **A material divergence from these
        numbers, beyond the Phase 4 deletions, means the classifier is wrong - stop and diagnose.**
        *(completed — reconciles EXACTLY. 121 `-> Prop` matches the baseline to the unit; data
        is 739 - 5 deleted `DerivationTree`-valued = 734; and the single proof-valued `def`
        research found was `canonicalR_transitive`, an `abbrev` for the theorem
        `existsTask_transitive`, deleted in Phase 4.1 — so 0 remain and the plan's
        "convert that one to `theorem`" branch is now moot. See
        `target-names/RECONCILIATION.md`.)*
  - [x] Emit `specs/402_.../target-names/categories.tsv` with one row per flagged declaration:
        fully-qualified name, module, category, usage count.
  - [x] Separate out the 19 `tactic*` syntax declarations (no `.ilean` definition entry,
        auto-generated from `syntax`/`macro`) into their own list for the Phase 8 decision. They do
        not enter the rewrite set. *(deviation: altered — the measured set is **18**, not 19.
        Exhaustively confirmed: no other flagged name has a final component beginning `tactic`,
        and the only other flagged name containing the substring is the ordinary predicate
        `Separation.is_syntactically_separated`. `refcount.py` reports NO SUCH DECLARATION for
        all 18, confirming they carry no `.ilean` entry whatsoever.)*
- **Estimated output:** ~180 lines (Lean introspection + TSV export)
- **Done when:** `categories.tsv` covers every flagged declaration; counts reconcile with the
  baseline minus Phase 4 deletions; the 19 tactic declarations are listed separately.
- **Tree at phase end:** GREEN (read-only).
- **Timing:** 2 hours
- **Depends on:** 4

#### Phase 5.2: Derivation, collision audit, and review gate [COMPLETED]

- **Goal:** Apply the derivation rule to every row and prove the result is collision-free before any
  edit is authorised.
- **Tasks:**
  - [x] Implement the derivation rule in `tools/derive_names.py`, in this order:
    1. **Semantic substitution first, casing second** (never the reverse). Word map from Part C:
       `ecq`->`bot_of_and_neg`, `raa`->`imp_neg_imp`, `efq`->`neg_imp`, `efq_neg`->`imp_of_neg`,
       `lce`->`and_left`, `rce`->`and_right`, `ldi`->`or_inl`, `rdi`->`or_inr`,
       `rcp`->`imp_of_neg_imp_neg`, `lem`->`em`, `dni`->`not_not_intro`; `temp_`->`temporal_`
       (22 declarations incl. `Axiom.temp_linearity`, `Axiom.temp_linearity_past`, the 7
       `temp_*_valid` in `Soundness.lean`, and the 6 private `axiom_temp_*` in `SoundnessLemmas.lean`);
       `dd_countermodel_chronicle_discrete`->`countermodel_chronicle_discrete`,
       `dd_countermodel_chronicle_mixed_sorry`->`countermodel_chronicle_mixed`; lowercase `bfmcs`
       (2 active sites). *(deviation: altered — MEASURED SCOPE IS FAR SMALLER THAN THE PLAN
       ASSUMES. `ecq`/`raa`/`efq`/`lce`/`rce`/`ldi`/`rdi`/`rcp`/`lem`/`dni` contain NO
       underscore, so `defsWithUnderscore` never flags them; they are absent from all 855 and
       had to be added to the rename set explicitly. Only `efq_neg` is in both sets. Part C
       semantic renaming and the linter goal are therefore largely DISJOINT work, not two views
       of one set. `temp_` matches 10 flagged declarations, not 22 — the rest are theorems or
       constructors, outside the linter's scope. `dd_*` matches ZERO; those declarations no
       longer exist. `bfmcs` needs no change: it already appears lowercase inside names
       (`henkin_bfmcs`), and `Bundle.BFMCS` is a structure name, for which UpperCamelCase is
       already correct.)*
    2. **Then the three-branch casing rule**, keyed on the Phase 5.1 category:
       - `theorem`, or a `def` whose *type* is a `Prop` -> snake_case, out of the linter's scope.
         Exactly 1 declaration qualifies: convert it to `theorem` and stop. *(deviation: skipped
         — MOOT. That declaration was `canonicalR_transitive`, an `abbrev` for the theorem
         `existsTask_transitive`, deleted in Phase 4.1. The classifier finds ZERO proof-valued
         `def`s remaining, so this branch is never taken.)*
       - result type (after telescoping) is `Prop`, i.e. it *defines* a predicate -> **UpperCamelCase**
         (Mathlib: `Function.Injective`, `IsCompact`). 121 declarations.
       - result type is a `Sort`/`Type` -> UpperCamelCase.
       - otherwise (data, including all 185 `DerivationTree`-valued) -> lowerCamelCase. ~720.
    - [x] Verify the worked examples reproduce: `truth_at`->`truthAt`; `Formula.all_future`->`allFuture`;
          `Propositional.ecq` (a `def`) -> **`botOfAndNeg`**, not `bot_of_and_neg`;
          `Propositional.lce`->`andLeft`; `temp_linearity_derivation`->`temporalLinearityDerivation`.
          The `ecq` row is the trap the task description names - every Part C target is snake_case and
          every one of those declarations is a `def`, so **every Part C target must be re-cased**.
          *(deviation: altered — four of the five worked examples reproduce exactly. The fifth
          does NOT: `truth_at` classifies as `prop_valued_definition` (its result type after
          telescoping IS `Prop`), so the plan's own three-branch rule mandates UpperCamelCase,
          giving **`TruthAt`**, not `truthAt`. The plan's worked example predates that rule — it
          comes from the research mechanism experiment, where `truth_at` was renamed only to
          prove the rewriter worked. The rule wins. Surfaced at the review gate rather than
          silently resolved, because it is the most-referenced declaration in the migration.)*
  - [x] **Collision audit**: no two rows may share a target; no target may collide with an existing
        project identifier or a Lean/Mathlib core name. Check the known cases explicitly -
        `and_left`/`and_right` against `and_left_impl` (`PointInsertion.lean:1193`),
        `and_left_congr_hier` (`Hierarchy.lean:2463`), `and_left_congr` (`DedekindZ.lean:691`), and
        core `And.left`/`And.right`. Re-run the 47.2% prefix-collision measurement over the *target*
        finals and record the new figure. *(completed — audit CLEAN: 0 duplicate targets, 0
        clashes with surviving project declarations, 0 clashes with external names, 0 no-op
        rows, 0 underscores surviving into a target. TWO irreducible collisions were surfaced
        and resolved IN THE TABLE, never mid-rewrite: `apply_modus_ponens` ->
        `applyModusPonensRule` (the naive `applyModusPonens` is already taken in the same
        namespace by `ForwardProofGenerator.lean:234`) and `r_definable_gap` ->
        `IsRDefinableGap` (the naive `RDefinableGap` is taken seven lines below by the subtype
        that bundles it; Mathlib gives the predicate the `Is` prefix). The predicted
        `and_left`/`and_right` collision did NOT materialise. Prefix collision re-measured:
        47.5% over current finals, reproducing research's 47.2%, falling to **10.8%** over
        target finals.)*
  - [x] Emit `specs/402_.../target-names/target-names.tsv` (machine-readable, consumed by Phase 6)
        and `specs/402_.../target-names/README.md` (human-readable table: current name, category,
        semantic step, target, usage count, defining module).
  - [x] Automated pre-review checklist, all of which must pass before a human is asked to look:
        every flagged declaration has exactly one target; zero collisions; category counts reconcile;
        30 randomly sampled rows (seed 402) are tabulated in `target-names/README.md` for hand
        re-derivation.
  - [x] **REVIEW GATE — REACHED.** Stop. Surface the table for human review. Phase 6 must not begin until the
        table is reviewed and accepted. In autonomous orchestration this phase is the terminus of the
        run - report the table and halt rather than proceeding.
- **Estimated output:** ~220 lines of tooling plus the generated table (~870 rows, generated not
  hand-written)
- **Done when:** `target-names.tsv` is complete and collision-free; the pre-review checklist passes;
  the review gate is recorded as reached.
- **Tree at phase end:** GREEN (read-only). **Commit the table artifacts.**
- **Timing:** 2-3 hours
- **Depends on:** 5.1

---

### Phase 6: Part B - single-pass declaration rewrite [COMPLETED]

- **Goal:** Apply all target names in one computed pass and return the tree to green.
  6.1 and 6.2 are a **paired unit**: 6.1 ends with a red build by construction and must be followed
  immediately by 6.2. Do not commit 6.1's output to `main` as a standalone state.

#### Phase 6.1: Apply the rewrite from a single snapshot [COMPLETED]

- **Goal:** One edit set, one pass, one snapshot.
- **Tasks:**
  - [x] `bash .claude/scripts/git-snapshot.sh 402` before starting.
  - [x] `lake clean && lake build` to produce a fresh, complete `.ilean` corpus. Confirm no `.ilean`
        exists whose module lacks a source file. *(deviation: altered — three corrections. (1)
        `lake clean` with no argument deletes the build directory of EVERY package in the
        workspace, Mathlib included; the scoped `lake clean Logos` was used instead. (2) `lake
        build` alone builds only `@[default_target] lean_lib FormalSystem`, whose glob is its
        root module's import closure — measured, that leaves **22 source files with no `.ilean`
        at all**, including `Automation/ProofStepExport.lean`, which Phase 7.1 names as
        load-bearing. Those files are invisible to BOTH the rewriter and the build meant to
        catch what the rewriter missed, so a rename would have broken them silently. `lake build
        BimodalTest` plus all 12 `lean_exe` roots closes the gap; captured as
        `tools/build-all.sh`, now the standard build command for the rest of the migration.
        (3) Two files remain uncovered — `Tests/BimodalTest/Semantics/SemanticBenchmark.lean`
        and `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` — because they DO NOT
        COMPILE on the unmodified tree (verified at HEAD before any edit: type mismatches,
        missing cases, `List.get!` removed upstream). Pre-existing breakage in orphan modules,
        recorded, not caused here.)* Final corpus: **329 live `.ilean`, 0 stale, 212,900
        recorded ranges** — versus 269 files had the plan's literal command been used.
  - [x] Run `rename.py` over **all** rows of `target-names.tsv` against **that one snapshot**,
        emitting the full edit set before applying anything. Apply per file, per line,
        right-to-left. **845 targets, 284 files, 25,640 spans, 0 overlap conflicts.**
  - [x] Write `specs/402_.../guard-rejections.md`: every range whose extracted text did not end with
        the expected old final component. Expected volume ~0.2%, dominated by wildcard `_` holes and
        keyword/anonymous declarations - both of which **must stay rejected**. Classify each
        rejection; an unclassifiable rejection blocks 6.2. *(deviation: altered — **0 rejections**,
        not ~0.2%. The 234 mismatching ranges the self-test finds all belong to declarations
        OUTSIDE the rename map, so no rejection was reachable. `guard-rejections.md` records
        the zero. The self-test remains the evidence that the guard works: 128,083 / 128,317 =
        **99.8176%** exact suffix over the full corpus, five known buckets, no unknown bucket.)*
  - [x] `lake build`, capture the full error list to `build-errors-initial.txt`. These are the
        `.ilean` coverage gap - expect `Unknown identifier` at `have ⟨pat⟩ : … := by` type
        ascriptions, the class the experiment exposed at
        `Metalogic/SoundnessLemmas/DenseValidity.lean`. *(completed — the predicted class
        appeared at exactly the predicted file: eight `have ⟨s1, hs1t, h_φs1⟩ : ∃ s, … ∧ truth_at
        …` sites in `DenseValidity.lean`.)*
  - [x] Record the actual gap rate against the projected ~1.6% / ~390 sites (the projection is Low
        confidence, extrapolated from one declaration). *(completed — the projection was
        **~13x too pessimistic**. Measured: **30 gap sites**, 0.117% of the 25,640 rewritten
        spans, against a projected ~390 / 1.6%. Five structural classes, none anticipated in
        full: (1) intra-`structure` field references — a later field's type mentioning an
        earlier field carries no `.ilean` range, 6 sites in `Semantics/TaskFrame.lean`;
        (2) `have ⟨pat⟩ : T := by` type ascriptions, 8 sites, the predicted class;
        (3) dot-notation projections `φ.swap_temporal` reported as `Invalid field`, 4 sites;
        (4) identifiers inside a `macro` syntax quotation, reported at the USE site with a
        hygiene dagger `deduction_theorem✝` while the defect is at the macro definition, 1 site
        (`Automation/Tactics/Deduction.lean`); (5) ordinary unrecorded term references, 11
        sites. Classes 3 and 4 required extending `fixloop.py` mid-loop; class 4 was fixed by
        hand because the reported position is not the position that needs editing.)*
- **Estimated output:** ~100 lines of orchestration plus a very large generated diff and two report
  artifacts
- **Done when:** the edit set is applied, `guard-rejections.md` is written and every rejection
  classified, `build-errors-initial.txt` captured.
- **Tree at phase end:** **RED, by construction.** Paired with and immediately followed by 6.2.
- **Timing:** 1.5-2 hours
- **Depends on:** 5

#### Phase 6.2: Build-fix loop to green, commits sub-staged by defining module [COMPLETED]

- **Goal:** Close the `.ilean` coverage gap and return to green, committing in module-sized slices.
- **Tasks:**
  - [x] Write a small fix-loop driver: parse `Unknown identifier X` (and related resolution errors)
        out of `lake build` output, look `X` up in `target-names.tsv`, apply the mapped name at the
        reported position, rebuild. Loop until green. Hand-editing ~390 sites is not the plan.
        *(deviation: altered — `tools/fixloop.py` needed three extensions the plan did not
        foresee, each added only after the build produced an error shape the tool could not
        parse. (a) Lean 4.33 writes ``Unknown identifier `x` `` with BACKTICKS, not the
        `unknown identifier 'x'` single quotes the plan's wording implies. (b) Dot-notation
        failures arrive as ``Invalid field `swap_temporal`: the environment does not contain
        `FormalSystem.Syntax.Formula.swap_temporal` `` — a different message with the
        fully-qualified old name in it, and the edit must anchor on the DOT, not on an
        identifier boundary. (c) Hygiene daggers (`deduction_theorem✝`) must be stripped
        before map lookup. The driver applies a fix only when the name resolves to exactly ONE
        target; ambiguity is reported, never guessed.)*
  - [x] Any error that is *not* a name-resolution failure is a genuine defect - stop and diagnose
        rather than patching it into silence. *(completed — the loop halted twice on
        unclassifiable errors rather than guessing. Both halts were correct and neither was a
        defect: the first was the unparsed `Invalid field` shape, the second the macro-quotation
        site whose reported position is in a different file from the edit it needs. **Zero
        genuine defects were introduced**; every error traced to a name the rewriter could not
        see.)*
  - [x] Once green: `lake build` full, `BimodalTest` green, sorry count = 1 located by content
        (`theorem countermodel_discrete` - it will have moved from line 1242). *(completed —
        2,725 jobs green via `build-all.sh`; `check-sorry.sh` reports 1 live sorry, located by
        content in `Metalogic/WeakCanonical/Transfer.lean`; `scripts/check-module-invariants.sh`
        ALL CHECKS PASSED; all six `Bimodal*` identifiers intact; 0 new axioms; 0 new
        `@[deprecated]` aliases — the sole one in the tree predates this task, dated
        2025-12-14 at `Theorems/Propositional/Core.lean`.)*
  - [x] **Sub-stage the commits by defining module**, largest first, matching the research's
        directory distribution: `Metalogic` (599), `Theorems` (135), `Automation` (73), `Syntax`
        (31), `Semantics` (17), `FrameConditions` (5), `ProofSystem` (1). The *edit set* is not
        sub-staged - only the commits are. *(deviation: altered — five commits, not seven.
        `Syntax`/`Semantics`/`FrameConditions`/`ProofSystem`/`Examples` were staged together;
        splitting five directories touching 21 files into five commits adds no history value,
        and every commit before the last is red regardless, since a rename is not divisible.)*
  - [x] Run the linter masked and unmasked; record both. The unmasked count will still be nonzero
        because `nolints.json` entries now name declarations that no longer exist - that is expected
        and is resolved in Phase 8. *(completed — **unmasked `defsWithUnderscore`: 861 -> 20**.
        Every other category is EXACTLY at the Phase 1 unmasked baseline: `unusedArguments` 124,
        `LINTER FAILED` 115, `docBlame` 39, `tacticDocs` 4, `structureInType` 1. No regression.
        The 20 are the 18 `tactic*` syntax declarations plus two the Phase 5.1 exclusion list
        got wrong, both now Phase 8's problem: `Automation.LemmaDB.Parser.Attr.tm_lemma` (an
        attribute declaration, no `.ilean` entry) and
        `Separation.sNestingAboveU.S_nesting_above_U_inner` — the Phase 5.2 table excluded this
        as a "parent-derived auxiliary" on the theory that Lean regenerates its name from the
        parent's; **that theory is false**. Renaming the parent moved only the NAMESPACE
        component (`S_nesting_above_U.` -> `sNestingAboveU.`); the final component is spelled
        literally in source and survived untouched.)*
- **Estimated output:** ~150 lines of fix-loop tooling plus the residual diff
- **Done when:** `lake build` green; `BimodalTest` green; sorry count 1; all commits landed;
  the true `.ilean` gap rate recorded.
- **Tree at phase end:** GREEN. **This is the largest single checkpoint in the migration.**
- **Timing:** 2.5-4 hours
- **Depends on:** 6.1

---

### Phase 7: Silent-staleness sweep [NOT STARTED]

- **Goal:** Eliminate the occurrences `lake build` structurally cannot catch. 7.1 and 7.2 own
  disjoint file trees and may run in parallel.

#### Phase 7.1: Lean sources - strings, backticks, comments, tombstones [NOT STARTED]

- **Goal:** Fix non-elaborated occurrences inside built Lean sources.
- **Territory:** `FormalSystem/` (excluding `Boneyard/`) and `Tests/`. Must not touch `docs/`,
  `typst/`, `latex/`.
- **Tasks:**
  - [ ] **682 string literals** across 41 files. Concentrated in `Tests/…/TacticsTest.lean` (133),
        `AxiomsTest.lean` (97), and `Automation/ProofStepExport.lean` (40). **`ProofStepExport.lean`
        is mandatory and individually verified** - it writes declaration names into ML training
        JSONL, so staleness there is load-bearing, not cosmetic. Regenerate or diff a sample of its
        output to confirm the names are current.
  - [ ] **6 hand-verifiable backtick sites**: the 2 genuine single-backtick raw `Name` literals in
        `Automation/Tactics/Helpers.lean` and `Tests/BimodalTest/Automation/LemmaDBTest.lean`, plus
        the 4 unresolved double-backticks at `Automation/Tactics/Helpers.lean:305-314`. The other
        114 of 118 double-backtick references are `.ilean`-resolved and were rewritten in Phase 6 -
        verify a sample rather than re-editing them.
  - [ ] Check the hardcoded axiom-name list at `Automation/Tactics/Helpers.lean:567+` (the Part C
        research cited `Tactics.lean:540-553`; that file split into
        `Automation/Tactics/{Commands,Helpers,Deduction,PropDecide}.lean`). Also check
        `AesopRules.lean` `@[aesop safe apply]` rules and `SuccessPatterns.lean` string labels.
  - [ ] **7,047 comments and docstrings** naming old identifiers. Drive from the rename map, not
        from free-text search.
  - [ ] **Tombstone-comment purge**: the Part C audit found 96 "removed/archived/superseded"
        comments across 39 files (top: `SoundnessLemmas.lean` 14, `Bundle/Construction.lean` 9,
        `ProofSystem/Axioms.lean` 8, `Bundle/SuccRelation.lean` 7, `Algebraic/Algebraic.lean` 7).
        **Verify each before deleting** - the narrower audits found 4 and 52 respectively, and some
        "removed" mentions are legitimate historical documentation of complex constructions.
  - [ ] Apply the Phase 1 verdict on the 20 active `cud` tokens.
- **Estimated output:** ~250 lines of diff plus a sweep script
- **Done when:** `lake build` green; `BimodalTest` green; sorry count 1; a whole-word search for the
  old final components across `FormalSystem/` (excluding `Boneyard/`) and `Tests/` returns only
  deliberately-retained hits, each listed.
- **Tree at phase end:** GREEN.
- **Timing:** 2-3 hours
- **Depends on:** 6

#### Phase 7.2: Documentation trees [NOT STARTED]

- **Goal:** Update declaration-name references outside the Lean tree.
- **Territory:** `docs/`, `typst/`, `latex/`, `README.md`. Must not touch any `.lean` file.
- **Tasks:**
  - [ ] `docs/`: 695 hits across 56 files. `typst/`: 94 hits across 21 files. `latex/`: 3 hits.
  - [ ] Correct the `bx_completeness` references - the name does not exist in source; the real
        theorem is `completeness_discrete` (`Metalogic/BXCanonical/Completeness.lean:302`). This is a
        documentation fix, not a rename.
  - [ ] The ~812 single-backtick `` `Name `` occurrences in doc text are markdown inline code -
        cosmetic but user-facing; drive from the rename map.
  - [ ] These files are outside `specs/**`, so per `.claude/rules/no-task-references-in-deliverables.md`
        they must carry **no task-number citations**. Cite durable anchors instead.
- **Estimated output:** ~200 lines of diff
- **Done when:** a whole-word search for old final components across `docs/`, `typst/`, `latex/`,
  `README.md` returns only deliberately-retained hits; no task-number citations introduced.
- **Tree at phase end:** GREEN (no build impact).
- **Timing:** 1.5-2 hours
- **Depends on:** 6

---

### Phase 8: Linter proof and closeout [NOT STARTED]

- **Goal:** Prove `defsWithUnderscore = 0` by genuine conformance with the suppression file gone,
  and close the loose ends the migration was supposed to retire.
- **Tasks:**
  - [ ] **Decide the 19 `tactic*` syntax declarations** and record the decision in writing. These
        are auto-generated from `syntax`/`macro` commands, with names derived from the user-facing
        tactic token (`Bimodal.Automation.tacticModal_norm` from the `modal_norm` tactic). The
        linter's exclusion list (`Mathlib/Tactic/Linter/Style.lean:535-548`) skips `term`-prefixed
        and `«»`-containing names but not `tactic`-prefixed ones. **Decision rule**: grep `docs/`,
        `README.md`, and `Examples/` for each tactic token. If a tactic is internal-only, rename the
        token (and its declaration follows). If it is documented user-facing API, apply
        `@[nolint defsWithUnderscore]` at the declaration with a one-line rationale naming the tactic
        token it derives from. Per-declaration in-source nolints on auto-generated names are a
        documented exemption, not the bulk masking the task rules out - state that distinction where
        the attribute is applied.
  - [ ] **Delete `scripts/nolints.json`.** Not filtered, not emptied - removed from the tree.
  - [ ] Run `lake exe batteries/runLinter FormalSystem` (note: the root is renamed; plain
        `lake exe runLinter` fails - the package declares no `lintDriver`; batteries reads
        `scripts/nolints.json` relative to cwd, which is now absent). **Target: `defsWithUnderscore = 0`.**
  - [ ] Compare all other linter categories against the Phase 1 baseline (`unusedArguments` 124,
        `simpNF` 78, `docBlame` 39, `tacticDocs` 4, `structureInType` 1). Any increase is a
        regression introduced by this migration and must be fixed or explicitly recorded.
  - [ ] Remove or supersede `docs/development/NAMING_CONVENTION_DEVIATION.md`, which names this
        migration as its successor. Its architectural-root-cause account remains precise for the
        `Theorems/` layer (135 of 135 `DerivationTree`-valued) - preserve that content if it is
        moved rather than deleted.
  - [ ] Add a one-line note to `FormalSystem/Boneyard/README.md` recording that its identifiers
        predate the Mathlib naming migration and were deliberately left untouched (8,718 stale
        references, 93 files). Also update the prose Boneyard mention in
        `FormalSystem/FormalSystem.lean`.
  - [ ] Final verification bar, all four layers, recorded with output.
- **Estimated output:** ~150 lines (decision record, deletions, doc updates, verification transcript)
- **Done when:** `scripts/nolints.json` does not exist; `lake exe batteries/runLinter FormalSystem`
  reports `defsWithUnderscore = 0`; no other linter category regressed; `lake build` green;
  `BimodalTest` green; sorry count 1; the 19-tactic decision is recorded.
- **Tree at phase end:** GREEN. **Migration complete.**
- **Timing:** 2-3 hours
- **Depends on:** 7

## Testing & Validation

The four verification layers, in order of what each can and cannot prove:

- [ ] **Layer 1 - Guard rejection report.** Every `.ilean` range whose extracted text does not end
      with the expected old final component is rejected and listed. Expected ~0.2%. Every rejection
      is eyeballed and classified. This layer is what makes prefix corruption structurally
      impossible; it is precisely what a textual rewrite lacks.
- [ ] **Layer 2 - `lake build` green, no new errors.** Catches the ~1.6% `.ilean` coverage gap as
      loud `Unknown identifier` errors. Necessary, demonstrated to actually fire, and **not
      sufficient**.
- [ ] **Layer 3 - `lake exe batteries/runLinter FormalSystem` with `scripts/nolints.json` deleted ->
      `defsWithUnderscore = 0`.** The only evidence that counts for this category. The linter emits
      nothing during `lake build` and CI runs `lean-action` with `lint: false`, so no build result is
      evidence here.
- [ ] **Layer 4 - Residual-text sweep.** The enumerable non-elaborated classes the build can never
      catch: 682 string literals, 6 code backtick sites, 7,047 comments, `docs/` 695, `typst/` 94,
      `latex/` 3.

Invariants checked at every phase boundary:

- [ ] `lake build` green (excepting the declared red interval between 6.1 and 6.2).
- [ ] `BimodalTest` green - it is a `lean_lib` built by the default target.
- [ ] Live `sorry` count = 1, located **by content**: the bare `sorry` inside
      `theorem countermodel_discrete` in `Metalogic/WeakCanonical/Transfer.lean`.
- [ ] The six `Bimodal*` identifiers (`BimodalTest`, `BimodalHarness`, `BimodalLogic`,
      `BimodalProofs`, `BimodalReference`, `BimodalIntegrationTest`) intact.
- [ ] No `@[deprecated]` alias introduced anywhere.

## Artifacts & Outputs

- `specs/402_systematic_mathlib_naming_upgrade/plans/01_mathlib-naming-upgrade-migration.md` (this file)
- `specs/402_systematic_mathlib_naming_upgrade/tools/` - `ilean.py`, `rename.py`, `runlinter.py`,
  `derive_names.py`, `Classify.lean`, fix-loop driver, `check-sorry.sh`
- `specs/402_systematic_mathlib_naming_upgrade/baseline/` - masked and unmasked linter runs, category
  counts, sorry location
- `specs/402_systematic_mathlib_naming_upgrade/target-names/categories.tsv`
- `specs/402_systematic_mathlib_naming_upgrade/target-names/target-names.tsv` - the derive-once table,
  consumed by Phase 6
- `specs/402_systematic_mathlib_naming_upgrade/target-names/README.md` - human-reviewable table
- `specs/402_systematic_mathlib_naming_upgrade/guard-rejections.md`
- `specs/402_systematic_mathlib_naming_upgrade/build-errors-initial.txt`
- `specs/402_systematic_mathlib_naming_upgrade/summaries/01_mathlib-naming-upgrade-summary.md`
- Source tree: `Theories/Bimodal/` -> `FormalSystem/`; `lakefile.lean`; `scripts/nolints.json`
  (deleted); `docs/`, `typst/`, `latex/`, `README.md`

## Rollback/Contingency

- **Before any destructive git operation on a dirty tree**: `bash .claude/scripts/git-snapshot.sh 402`.
  The research experiment's own snapshot (`working-progress-1785114897.patch`, `git stash@{0}`, tag
  `git-snapshot-1785114897`) demonstrates the flow and must not be deleted.
- **Per-phase rollback**: every phase except 6.1 ends green and is committed, so rollback is
  `git revert` of that phase's commits. Phase 6.1 is explicitly not a rollback point - if 6.2
  cannot converge, roll back to the Phase 5 commit and re-run 6.1, do not attempt to repair a
  partially-rewritten tree by hand.
- **If the Phase 6.2 build-fix loop does not converge** within a reasonable budget (the ~390-site
  projection is Low confidence): roll back to the Phase 5 commit and re-run Part B in
  defining-module batches, with a **full `lake clean && lake build` between batches**. This
  preserves the single-snapshot invariant - each batch is computed from its own fresh, complete
  snapshot - at the cost of roughly 7 additional full builds. It is the sanctioned fallback, not a
  license to sub-stage edits against a stale snapshot.
- **If the `Propositional`/`Perpetuity` circular import cannot be broken** (Phase 4.1): keep
  `local_efq` / `local_lce` / `local_rce`, record the reason, and continue. This does not block any
  later phase.
- **If a target name collides irreducibly** (Phase 5.2): resolve it in the table before Phase 6, not
  during it. Amending a name mid-rewrite violates the single-snapshot constraint.
- **Partial-migration state is worse than no migration.** No phase may be left half-applied across a
  session boundary except the declared 6.1/6.2 pair, which must be completed or rolled back within
  the same working session.
