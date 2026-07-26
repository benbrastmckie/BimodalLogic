# Research Report: Task #396

**Task**: 396 - correct_stale_sorry_claims_in_user_docs
**Started**: 2026-07-25
**Completed**: 2026-07-25
**Effort**: ~2 hours (research only)
**Dependencies**: None (sibling task fixed `.lean` sources, excluded `docs/`)
**Sources/Inputs**: `lake build`, `mcp__lean-lsp__lean_verify` (axiom checks), codebase grep, direct file reads
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Ground truth **independently re-confirmed**: `lake build` succeeds (1877 jobs, 0 errors) with
  **exactly 12** `declaration uses 'sorry'` warnings, all in `Metalogic/` (7 in
  `Bundle/SuccRelation.lean`, 3 in `Bundle/SuccExistence.lean`, 1 in
  `BXCanonical/Chronicle/ChronicleToCountermodel.lean`, 1 in `WeakCanonical/Transfer.lean`).
- `perpetuity_1` through `perpetuity_6` are **all six** confirmed sorry-free via `lean_verify`
  (`#print axioms`-equivalent): P1–P4 use only `propext`; P5–P6 use `propext`, `Classical.choice`,
  `Quot.sound` — no `sorryAx` in any of the six.
- **Correction to the task description's own count**: `architecture.md` lines 221–236 present
  **SIX** perpetuity theorems as `sorry` stubs (P1 through P6), not "four" as stated in the task
  description. An even earlier pass apparently reported three. The actual extent in that one code
  block is six.
- `architecture.md` is a self-declared **schematic roadmap** ("provides a comprehensive roadmap
  for developing…"), not a 1:1 transcript of the real codebase — its `Formula` type (6
  constructors: atom/bot/imp/box/all_past/all_future, `String` atoms, `DecidableEq := by sorry`)
  does not match the real `Formula` type (`atom : Atom → Formula`, `untl`/`snce` not
  `all_past`/`all_future`, `deriving DecidableEq` automatically). This confirms the perpetuity
  block is **SCHEMATIC** (illustrative, not a status claim) — but because it reuses the exact real
  theorem names of six now-complete theorems, it needs an explicit prose disclaimer per the task's
  instructions, not deletion.
- Beyond the confirmed instance and the named candidate (`tactic-registry.md:68`), the sweep found
  a **cluster of genuinely STALE claims in `Theories/Bimodal/docs/project-info/`** (not just
  `architecture.md`): `implementation-status.md`, `known-limitations.md`, `README.md`, and
  `test-coverage.md` all assert sorry counts, file names, and completeness/build status that are
  demonstrably false against the current code (e.g., "~30 known sorries" vs. actual 12; example
  files `ModalProofs.lean`/`TemporalProofs.lean` that do not exist; a `ProofSearch.lean` "build
  failure" that no longer reproduces since the full build is green).
- `tutorial.md` (lines 365–402) and `tactic-development.md` (lines 359–383) contain **additional
  SCHEMATIC instances** of the same perpetuity-name-reuse pattern found in `architecture.md`, plus
  a soundness/completeness stub reusing the real `soundness`/completeness names.
- **Out-of-scope but load-bearing finding**: several `project-info/` and `user-guide/examples.md`
  references use a `Logos/Core/Automation/...` path and `Logos.*` import namespace that **do not
  exist anywhere in the repository** (only a LaTeX build artifact happens to be named
  `LogosReference`). This is a separate, larger staleness problem (namespace/path, not sorry
  status) that should probably be its own follow-up task rather than folded into this one.

## Context & Scope

Sweep target: `Theories/Bimodal/docs/` for `sorry`, `In Progress`, `NOT STARTED`, `PARTIAL`,
`pending`, `infrastructure gap`, cross-checked against the actual `.lean` sources via `lake build`
and `lean_verify`. Scope is documentation-only; no `.lean` file was touched and no proof was
written.

## Findings

### Independently confirmed ground truth

| Claim | Verification method | Result |
|---|---|---|
| `lake build` succeeds, 1877 jobs, 0 errors | Ran `lake build` directly | Confirmed |
| Exactly 12 `sorry` warnings, all in `Metalogic/` | `lake build 2>&1 \| grep "declaration uses"` | Confirmed — 7× `Bundle/SuccRelation.lean` (:559,568,591,615,629,642,652), 3× `Bundle/SuccExistence.lean` (:442,748,822), 1× `BXCanonical/Chronicle/ChronicleToCountermodel.lean:200`, 1× `WeakCanonical/Transfer.lean:1283` |
| `perpetuity_1`–`perpetuity_6` all proven, no `sorryAx` | `mcp__lean-lsp__lean_verify` on each, fully-qualified names in `Principles.lean`/`Bridge.lean` | Confirmed — P1–P4: `{propext}`; P5–P6: `{propext, Classical.choice, Quot.sound}` |

### Per-Hit Table

| File:Line | Current Claim | Verdict | Evidence | Replacement Text |
|---|---|---|---|---|
| `user-guide/architecture.md:219-237` | Code block presents `perpetuity_1` through `perpetuity_6` as `theorem ... := by sorry` (six theorems, not four) | **SCHEMATIC** (needs prose clarification, not deletion) | File is a self-declared "roadmap" whose `Formula` type diverges from the real one (`Syntax/Formula.lean:76-91`); real `perpetuity_1..6` are sorry-free (see ground truth table) | Insert a callout immediately after the code block (before "#### Derivation Trees: Type vs Prop"): *"**Status note**: This section sketches the target proof system from scratch for pedagogical purposes; the `sorry` placeholders above are illustrative, not a live status report. In the actual implementation, all six perpetuity principles are complete and sorry-free — see `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` (P1–P5) and `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` (P6)."* |
| `user-guide/architecture.md:1296` | "Partial metalogic: Soundness (5/8 axioms proven), completeness infrastructure defined" | **STALE** | Soundness.lean has zero `sorry` (not among the 12 confirmed warnings); `known-limitations.md`'s own "What Works Well" list already says "✅ Full soundness proof"; axiom count is also stale (8 vs. the current 21: 17 base + 1 dense + 3 discrete per `implementation-status.md:36`) | "Complete metalogic: full soundness proof (all 21 axiom schemas); completeness proven for the dense and discrete frame classes, with one residual proof debt in the general Base-frame case (see `known-limitations.md`)." |
| `project-info/tactic-registry.md:68` | "`perpetuity_1` through `perpetuity_6` - Perpetuity principles (🚧 In Progress)" listed under "Safe Rules (always apply)" | **STALE** (nuanced — do not flip to bare "Complete") | The six theorems are proven, but grep of `Automation/AesopRules.lean` finds **zero** `@[aesop safe]` annotations on any `perpetuity_*` name — they are not actually wired into the Aesop rule set at all, unlike `modal_t_valid`/`modal_4_derivable`/etc. which are *also* absent from that file (the whole "Registered Rules" section appears aspirational vs. the real file's names: `axiom_modal_t`, `modal_t_forward`, etc.) | "`perpetuity_1` through `perpetuity_6` - Perpetuity principles: theorems fully proven (sorry-free), not yet registered as Aesop safe rules (📋 Planned integration)" |
| `project-info/implementation-status.md:62` | "`Completeness.lean` \| ⏸️ \| Infrastructure only" | **STALE** | `Metalogic/BXCanonical/Completeness.lean` docstring: `completeness_dense`/`completeness_discrete` are sorryAx-free; only the general Base-frame `completeness` retains one sorryAx source (dead `WeakCanonical.countermodel_discrete` pipeline) | "`Completeness.lean` \| 🔶 \| Dense/discrete frame classes proven sorry-free; general Base-frame case has one residual sorryAx (dead pipeline dependency)" |
| `project-info/implementation-status.md:76-85` | Perpetuity table: P1–P5 ✅, "P6 \| 🔶 \| Axiomatized"; section header "Perpetuity (🔶 ~85%)" | **STALE** | P6 (`Bridge.lean:837`) confirmed sorry-free via `lean_verify` | Change P6 row to "✅ \| Complete (`Bridge.lean`)"; change section header to "Perpetuity (✅ 100%)". Note: the formula strings shown for P1–P3 in this table (e.g. "`□φ ↔ □◇□φ`") don't match the real theorem statements either — flagging as a secondary defect outside this task's sorry-status scope. |
| `project-info/implementation-status.md:91` | "`ModalS4.lean` \| 🔶 \| Core theorems proven" | **STALE** | `Theorems/ModalS4.lean:34` docstring states verbatim: "All 4 theorems above are fully proven; this module is sorry-free." Zero `sorry` in file. | "`ModalS4.lean` \| ✅ \| All 4 theorems proven, sorry-free" |
| `project-info/implementation-status.md:116-125` | Examples table: `ModalProofs.lean` (~5), `TemporalProofs.lean` (~8), `BimodalProofs.lean` (~6), `*Strategies.lean` (~5) sorries; "Examples (🔶 Partial)" | **STALE** | `Theories/Bimodal/Examples/` contains only two files: `BimodalProofs.lean` and `TemporalStructures.lean`, **both with zero `sorry`**. `ModalProofs.lean`, `TemporalProofs.lean`, and any `*Strategies.lean` do not exist in the directory. `Examples.lean`'s own docstring calls both existing files "sorry-free." | Replace section entirely: "## Examples (✅ Complete)\n\n\| Module \| Status \| Sorries \|\n\|---\|---\|---\|\n\| `BimodalProofs.lean` \| ✅ \| 0 \|\n\| `TemporalStructures.lean` \| ✅ \| 0 \|\n\n**Note**: both example files are sorry-free (per `Examples.lean` module docstring)." |
| `project-info/implementation-status.md:134` | "Known sorries \| ~30" | **STALE** | Ground truth: exactly 12, all in `Metalogic/` | "Known sorries \| 12 (all in `Metalogic/`: `Bundle/SuccRelation.lean` ×7, `Bundle/SuccExistence.lean` ×3, `BXCanonical/Chronicle/ChronicleToCountermodel.lean` ×1, `WeakCanonical/Transfer.lean` ×1)" |
| `project-info/known-limitations.md:14` | "The `provable_iff_valid` theorem uses `sorry`" | **STALE** — theorem doesn't exist under this name | `grep -rn "provable_iff_valid"` returns zero hits anywhere in `Theories/Bimodal/`. Actual completeness theorems: `completeness`, `completeness'`, `completeness_dense`, `completeness_discrete` in `BXCanonical/Completeness.lean` | "The general Base-frame `completeness` theorem (`BXCanonical/Completeness.lean:187`) retains one `sorryAx` dependency on a deprecated dead-code pipeline (`WeakCanonical.countermodel_discrete`); `completeness_dense` and `completeness_discrete` are fully proven and sorryAx-free." |
| `project-info/known-limitations.md:66` | "Files in `Bimodal/Examples/` contain `sorry` placeholders (~24 total)" | **STALE** | Confirmed 0 sorries across both files in `Examples/` (see above) | "Files in `Bimodal/Examples/` are sorry-free (0 total) as of the current build." Consider removing Limitation 3 entirely or marking it resolved. |
| `project-info/known-limitations.md:87-89` | "`CompletenessTest.lean` (3)... `PropositionalTest.lean` (1)... `PerpetuityTest.lean` (1)" | **STALE** | `Metalogic/CompletenessTest.lean` does not exist anywhere in the repo (`find` returns nothing). `Tests/BimodalTest/Theorems/PerpetuityTest.lean` and `.../PropositionalTest.lean` both have **zero** actual `sorry` tactic uses (only comments noting "no sorry") | Remove or replace Limitation 4 entirely: "Test suite: no outstanding `sorry` placeholders found in `PerpetuityTest.lean` or `PropositionalTest.lean`; `CompletenessTest.lean` no longer exists in the tree." |
| `project-info/known-limitations.md:103-107` | "Limitation 5: Modal S4 Theorems Partial ... `s4_diamond_box_conj`... have `sorry`" | **STALE** | `Theorems/ModalS4.lean` is sorry-free per its own docstring and confirmed grep (only "sorry-free" self-description present, no live `sorry`) | Remove Limitation 5 or replace with: "Resolved: all Modal S4 theorems, including `s4_diamond_box_conj`, are fully proven and sorry-free." |
| `project-info/known-limitations.md:160` | "What Works Well" list: "✅ Perpetuity principles P1-P5" (omits P6) | **STALE** (incomplete, not false) | P6 confirmed proven (see ground truth table) | "✅ Perpetuity principles P1-P6" |
| `project-info/README.md:28` | "Completeness: Infrastructure only (on hold)" | **STALE** | Same as `implementation-status.md:62` finding above | "Completeness: dense/discrete frame classes proven sorry-free; general Base-frame case has one residual proof debt" |
| `project-info/README.md:29` | "Known Sorries: ~30 (mostly in examples and tests)" | **STALE** | Ground truth: 12, all in `Metalogic/`, none in examples or tests | "Known Sorries: 12 (all in `Metalogic/`; none in `Examples/` or `Tests/`)" |
| `project-info/test-coverage.md:14,109-126` | Sorry Audit table: 5 placeholders across `CompletenessTest.lean` (3), `PerpetuityTest.lean` (1), `PropositionalTest.lean` (1) | **STALE** | Same evidence as `known-limitations.md:87-89` above — `CompletenessTest.lean` doesn't exist; the other two files have zero actual sorries now | This is a dated, script-generated baseline report ("Generated: 2026-01-12... Baseline (initial measurement)"). Recommend either (a) re-running `scripts/coverage-analysis.sh` to regenerate, or (b) adding a header note "Superseded — sorry counts below are stale; see `known-limitations.md` for current status" if regeneration is out of scope for this task. |
| `user-guide/troubleshooting.md:375` | "ProofSearch is blocked **pending** architecture changes" (build-failure claim) | **STALE** | Confirmed: `Automation/ProofSearch.lean` no longer exists as a single file; it is now `ProofSearch/Core.lean` + `ProofSearch/Strategies.lean`, both imported by `Automation.lean`, and the **full** `lake build` succeeds with 0 errors — the module builds cleanly as part of the main build | "**Cause**: Historical — `ProofSearch` previously had build issues; it has since been reorganized into `Automation/ProofSearch/Core.lean` and `Automation/ProofSearch/Strategies.lean` and builds cleanly (confirmed via `lake build`, 0 errors)." Consider removing this troubleshooting entry or marking it resolved. |
| `project-info/known-limitations.md:34-39` | "Limitation 2: ProofSearch Has Build Issues... `aesop` internal errors that prevent compilation" | **STALE** | Same evidence as `troubleshooting.md:375` | Remove Limitation 2 or mark resolved with the same note. |
| `user-guide/examples.md:949` | "The current implementation in `Completeness.lean` has the scaffolding with placeholder `sorry`s" | **STALE** (same underlying claim as `known-limitations.md:14`, different file) | Same evidence — dense/discrete variants are proven; only Base-frame retains a residual sorryAx | "The general Base-frame `completeness` theorem retains one residual proof debt (a deprecated dependency); the dense and discrete frame-class variants (`completeness_dense`, `completeness_discrete`) are fully proven." |
| `user-guide/examples.md:959-960` | "`Bimodal/Examples/ModalProofs.lean`", "`Bimodal/Examples/TemporalProofs.lean`" listed as source files | **STALE** (adjacent finding — file reference, not a sorry-status claim, but in the same section as the line above and worth fixing in the same pass) | Files don't exist; real files are `BimodalProofs.lean` and `TemporalStructures.lean` | Replace the two bullet lines with the two real filenames. |
| `user-guide/tutorial.md:365-402` | `example`/`theorem` blocks with `sorry` for modal-K/temporal-K rule application (365,208,213 — generic, unnamed `example`s), then explicitly named `theorem soundness ... sorry -- See Metalogic/Soundness.lean` (367-370), `theorem weak_completeness`/`theorem strong_completeness ... sorry -- See Metalogic/Completeness.lean` (377-384), and `theorem perpetuity_1`/`perpetuity_2 ... sorry` (392-398) | **Mixed**: the anonymous `example` blocks (208,213) are **SCHEMATIC** exercises with no real-theorem collision — leave as-is. The **named** `soundness`/`weak_completeness`/`strong_completeness`/`perpetuity_1`/`perpetuity_2` blocks are **SCHEMATIC but need the same disclaimer** as `architecture.md`, since they reuse real theorem names that are proven or nearly-proven in the actual codebase | Real `soundness` is fully proven (not in the 12-sorry list); real `completeness_dense`/`completeness_discrete` are proven, only Base retains residual debt; real `perpetuity_1`/`perpetuity_2` are proven. Add a note after line 401 (before "### Extension Layers"): *"**Status note**: The `sorry` placeholders in this section are pedagogical stand-ins for a from-scratch walkthrough. In the actual library, `soundness` is fully proven, `completeness_dense`/`completeness_discrete` are fully proven (only the general Base-frame case has a residual debt), and `perpetuity_1`–`perpetuity_6` are all fully proven — see `Metalogic/Soundness.lean`, `Metalogic/BXCanonical/Completeness.lean`, and `Theorems/Perpetuity/{Principles,Bridge}.lean`."* |
| `user-guide/tactic-development.md:359-383` | `theorem perpetuity_1`/`perpetuity_2 ... sorry -- P1/P2 implementation` inside a "Custom Rule Sets" example using `declare_aesop_rule_sets [TMLogic]` | **SCHEMATIC**, same disclaimer family, plus the example itself describes tooling (`declare_aesop_rule_sets [TMLogic]`) that the real `AesopRules.lean` explicitly says does **not** exist ("there is no separate `TMLogic` rule set declared... Do not write `aesop (rule_sets [TMLogic])`") | Confirmed via direct read of `Automation/AesopRules.lean:51-53` comment | Add a note before this example: *"**Status note**: this hypothetical `TMLogic` rule set is illustrative; the real `AesopRules.lean` registers its rules directly into Aesop's default rule set (no separate `TMLogic` rule set exists), and does not currently include the perpetuity theorems, which are proven but not Aesop-registered — see `tactic-registry.md`."* |
| `research/leansearch-proof-caching-memoization.md:140` | "Pending Queries" (queries not executed) | **ACCURATE** | This describes a research note's own methodology, not a codebase proof-status claim | No change. |
| `reference/comment-convention.md:33` | `-- TODO: Replace sorry with full proof when Task 131 completes.` | **ACCURATE (style-guide example)** | This is illustrating the TODO-comment *convention*, not asserting a live status; also Task 131 (`refactor_module_organization`) is confirmed still `not_started` in `specs/state.json` | No change. |
| `reference/readme-standard.md:8-10` | "established before task 131 (module reorganization, NOT STARTED)" | **ACCURATE** | `specs/state.json` confirms project #131 status is `"not_started"` | No change (also note: this file cites a task number in a deliverable outside `specs/**`, which is a separate concern under `.claude/rules/no-task-references-in-deliverables.md`, not in scope here). |
| `reference/docstring-standard.md`, `reference/tactic-reference.md:11-13` | Docstring template mentioning "Sorry Status" field; tactic table marking `modal_search`/`temporal_search` "Partial", `tm_auto` "In Development" | **Out of scope / lower confidence** | These are about *tactic* completion, not theorem/proof sorry-status, and conflict with `tactic-registry.md`'s own "✅ Complete (Task 315)" claim for `modal_search`/`temporal_search` — an internal inconsistency between two project docs, not a sorry-vs-code mismatch. Also, `AesopRules.lean`'s own deprecation notice ("As of 2026-01-17, `tm_auto` no longer uses Aesop... delegates to `modal_search`") isn't reflected in either doc. | Flagged for awareness; recommend a follow-up pass reconciling `tactic-reference.md` vs. `tactic-registry.md` vs. the `AesopRules.lean` deprecation notice, but this is a tactic-status inconsistency, not the sorry/proof-status pattern this task targets. |
| `Theories/Bimodal/docs/user-guide/examples.md` (whole file) and `project-info/tactic-registry.md` (`Logos/Core/Automation/...` paths) | Multiple references to `Logos/Core/Automation/ProofSearch.lean`, `Logos/Core/Automation/Tactics.lean`, `import Logos.Examples...` | **Out of scope — flag only** | `find . -iname "Logos" -type d` returns nothing; no `Logos/` directory exists anywhere in the repo (only an unrelated LaTeX build artifact named `LogosReference`). This is a namespace/path staleness issue, much larger in scope than "sorry" claims, and affects many more lines than listed here. | Not corrected in this report — recommend a dedicated follow-up task to reconcile `Logos.*` references with the real `Bimodal.*` namespace throughout `docs/user-guide/examples.md` and `docs/project-info/tactic-registry.md`. |

## Decisions

- Treat `architecture.md`'s perpetuity block, `tutorial.md`'s soundness/completeness/perpetuity
  blocks, and `tactic-development.md`'s Aesop rule-set example as **SCHEMATIC**: add a prose
  disclaimer pointing to the real, currently-proven theorems, rather than deleting or rewriting
  the illustrative code (per the task's explicit instruction).
- Treat all `project-info/*.md` sorry-count, file-name, and build-status claims found in the
  sweep as **STALE** and in-scope for correction, since these present themselves as live status
  reports (tables, "Known Sorries: N", "Status: Partial") rather than pedagogical walkthroughs.
- Leave the `Logos/` namespace mismatch and the `tactic-reference.md` vs. `tactic-registry.md`
  internal inconsistency **unfixed** and flagged only — both are real problems but outside this
  task's "sorry misrepresents proof status" scope, and each is large enough to warrant its own
  task.
- Corrected the task description's own count: the architecture.md block shows **six** perpetuity
  stubs (P1–P6), not four.

## Risks & Mitigations

- **Risk**: `test-coverage.md` is a dated, script-generated snapshot (`Generated: 2026-01-12`).
  Manually hand-editing its numbers could drift from what `scripts/coverage-analysis.sh` would
  produce if re-run. **Mitigation**: recommend either regenerating via the script or adding an
  explicit "stale as of {date}" header rather than silently editing the counts, so the next
  regeneration doesn't fight a hand-edited version.
- **Risk**: The implementation pass could be tempted to "fix" the `Logos/` namespace references
  while touching these same files, expanding scope well beyond sorry-claims. **Mitigation**:
  explicitly flagged as out-of-scope above; recommend a separate task.
- **Risk**: Several formula-statement transcriptions in `implementation-status.md`'s perpetuity
  table (e.g., "P1 `□φ ↔ □◇□φ`") don't match the real theorem statements at all, independent of
  sorry status. **Mitigation**: flagged as a secondary defect in the per-hit table row; not
  treated as required for this task since it's not a sorry/proof-status claim.

## Context Extension Recommendations

- **Topic**: Stale-documentation detection for formal-proof codebases.
- **Gap**: No existing context file documents the pattern of pedagogical `sorry` code blocks in
  Lean documentation reusing real theorem names, or the general principle that dated/generated
  status reports (like `test-coverage.md`) need a "stale as of" marker rather than silent
  hand-edits.
- **Recommendation**: Consider a `.claude/extensions/lean/context/` note on this pattern if it
  recurs across future doc-staleness tasks in this repo.

## Appendix

- `lake build` (full project) — confirmed 1877 jobs, 0 errors, 12 sorry warnings.
- `mcp__lean-lsp__lean_verify` on `Bimodal.Theorems.Perpetuity.perpetuity_{1..6}`.
- `grep -rniE "sorry|In Progress|NOT STARTED|PARTIAL|pending|infrastructure gap" Theories/Bimodal/docs/`
- `find Theories/Bimodal/Examples -iname "*.lean"`, `find . -iname "CompletenessTest.lean" -o -iname "PerpetuityTest.lean" -o -iname "PropositionalTest.lean"`
- `grep -rn "perpetuity" Theories/Bimodal/Automation/AesopRules.lean` (zero hits)
- `grep -n "provable_iff_valid" Theories/Bimodal/` (zero hits)
- `find . -iname "Logos" -type d` (zero hits — confirms namespace does not exist)
- `jq` lookup of `specs/state.json` project #131 status (`not_started`, confirms `readme-standard.md` claim is accurate)
