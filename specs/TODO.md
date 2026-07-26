---
next_project_number: 403
---

# TODO

## Task Order

*Updated 2026-07-26. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 95,125,127,128,165,179,180,192,196,199,231,257,298,318,341,361,377,389,402 | -- | completeness, frame-extensions, algebraic-representation, ... |
| 2 | 131,169,170,186,193,219,282,296,378,390 | 192,196,199,231,298,341,361,389 | completeness, formula-refactor, automation, ... |
| 3 | 175,177,178,362,391 | 131,169,170,193,390,402 | completeness, formula-refactor, strong_completeness |

**Grouped by Topic** (indented = depends on parent):

### Completeness

95 [NOT STARTED] — Verification pass on sorry status for completeness_discrete and b
165 [NOT STARTED] — Establish the semantic finite model property for TM bimodal logic
390 [NOT STARTED] — Research task: determine how a Dedekind-complete carrier can be p
  └─ 391 [NOT STARTED] — Design and land the frame-class scaffolding for a Dedekind-comple

### Formula Refactor

131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs and d
  └─ 175 [RESEARCHED] — Normalize naming conventions to follow Mathlib-style descriptive 
  └─ 177 [NOT STARTED] — Update all documentation to match final codebase state after refa
  └─ 178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Publication Quality

180 [NOT STARTED] — copyright_headers_universe_polymorphism_line_limits
402 [NOT STARTED] — Systematically upgrade the repository to Mathlib naming conventio

### Automation

179 [RESEARCHED] — research_lean4_tactics_infrastructure
192 [NOT STARTED] — master_tactic_dispatch
  └─ 193 [NOT STARTED] — codebase_tactic_refactor
196 [RESEARCHED] — Systematic survey of the entire Theories/Bimodal/ codebase to ide
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)
199 [PARTIAL] — Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Autom
  └─ 186 [NOT STARTED] — unify_search_systems

### Dataset Enhancement

231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
  └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
257 [BLOCKED] — large_data_storage_huggingface
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor
  └─ 282 [PARTIAL] — exhaustive_enumeration_by_default
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Literature

389 [PLANNED] — Repair the literature corpus for the Dedekind-complete completene

### Reference Book

318 [NOT STARTED] — GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymo

### Kamp Theorem Formalization

341 [PLANNED] — Structural refactor of the NfMultiAnchorBridge kvE2_sep carrier l

### Kamp Completeness

377 [PARTIAL] — RESCOPED after research (report 01, machine-verified). The origin
378 [NOT STARTED] — DEFERRED from task 377 plan v2 Phases 6-8 (re-scoped by binding u

### Strong Completeness

361 [NOT STARTED] — Research + scoping for finite-context strong completeness (Contex
  └─ 169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th
    └─ 362 [NOT STARTED] — Implement main_strong_completeness: finite-context strong complet
  └─ 170 [NOT STARTED] — Dense (FrameClass.Dense) WEAK completeness green: make `completen
    └─ 362 [NOT STARTED] — Implement main_strong_completeness: finite-context strong complet (see above)

## Tasks

### 402. Systematic mathlib naming upgrade
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 394

**Description**: Systematically upgrade the repository to Mathlib naming conventions. This task COMBINES two previously-separate renames because they rewrite the SAME reference graph and must share one tooling pass, one verification strategy, and one set of green-build checkpoints. Doing them separately means paying a 24,000+ site rewrite and its verification twice, with each pass invalidating the other's baseline.

  PART A (absorbed from the former standalone directory-rename task): move `Theories/Bimodal/` to `FormalSystem/`; rename the root namespace `Bimodal` to `FormalSystem`; update `lakefile.lean` (`srcDir` Theories -> FormalSystem, `roots` Bimodal -> FormalSystem); update every `import` and every fully-qualified reference; update `README.md`, `Tests/`, and any other path references.

  PART B: migrate snake_case `def` names to lowerCamelCase so `defsWithUnderscore` reaches zero by genuine conformance, and delete the interim `scripts/nolints.json` suppression as the migration lands.

The two parts touch DIFFERENT COMPONENTS of the same qualified identifier -- Part A changes the namespace prefix, Part B changes the final component -- so a single resolved-reference rewrite can apply both at once. Research must decide whether to apply them in one atomic pass or stage them, but the tooling and reference resolution MUST be shared.

PREREQUISITE STATE (established by the predecessor naming task; re-measure, since counts drift):
  - 38 `linter.defProp` declarations were already converted `def` -> `theorem`, removing 28 findings automatically.
  - The residual ~860 `defsWithUnderscore` findings are suppressed by a filtered `scripts/nolints.json`. Those rows are a CHECKPOINT, not an asset -- they are expected to be DELETED as this migration lands, not maintained.
  - `docs/development/NAMING_CONVENTION_DEVIATION.md` documents the interim state, is explicitly framed as having a known successor (this task), and carries the cost figures below.

COSTING FOR PART B, measured from resolved `.ilean` references, NOT grep:
  - 24,364 resolved usages across 258 of 300 modules (86% of the project)
  - 398 of 873 names (45.6%) are PROPER PREFIXES of another project identifier
  - a naive substring pass would touch 68,076 sites, of which 46.4% would be WRONG
  - churn is concentrated in DATA names, not the `Theorems/` layer: `Syntax/Formula.lean`'s 12 data names carry 4,929 usages, roughly 5x the entire `Theorems/` layer. Sizing this task from the `Theorems/` findings would badly understate it.

THE CENTRAL HAZARD is identifier-prefix collision. Position-anchored replacement driven by RESOLVED REFERENCES is mandatory; global substring replace is disqualified. A sibling task demonstrated the failure mode concretely: replacing `List.take_succ` silently corrupted `List.take_succ_cons`, a distinct non-deprecated lemma, surfacing as a `rewrite` failure a line away. At 45.6% prefix overlap that is the norm here, not an edge case. Part A carries the same hazard at namespace level.

DEPRECATION SHIMS MEASURABLY BACKFIRE: adding one `@[deprecated]` alias raised `defsWithUnderscore` 860 -> 861, because the alias is itself a snake_case def. Backward-compatibility aliases need their own suppression story or a different mechanism.

ROOT CAUSE CONTEXT FOR PART B: `DerivationTree` is Type-valued (`ProofSystem/Derivation.lean`), so derived theorems must be `def` rather than `theorem`, and Mathlib demands lowerCamelCase for defs while allowing snake_case for theorems. Only 184 of 888 findings (20.7%) are actually `DerivationTree`-valued -- but within tier-1 it is 135/189, all in `Theorems/`. The other 753 are 554 ordinary data defs, 121 `-> Prop` predicates, 29 proofs. A `Prop` wrapper already exists (`ProofSystem/Derivable.lean`, `Nonempty (DerivationTree ...)`) but restating against it removes only 135 findings and permanently doubles the combinator API, because `Automation/` consumes those combinators to BUILD trees and needs `DerivationTree.height` (68 references). Rejected as a substitute for renaming.

RESEARCH MUST DETERMINE (the naming POLICY is settled -- full Mathlib conformance. These are mechanism questions):
  - The rewrite MECHANISM. Assess Lean/Mathlib's own rename facilities against an `.ilean`-driven resolved-reference rewriter. The VERIFICATION story matters more than the edit story: how do we prove a 24,000+ site rewrite is complete and correct?
  - Whether Parts A and B land in one atomic pass or are staged, and whether staging can keep `lake build` green at every commit. A partial rename leaving dangling references is worse than no rename.
  - Ordering: if staged, Part A (namespace, mechanical) should precede Part B (declaration casing, expensive), never the reverse -- a namespace rename applied after the casing rewrite churns straight back through all 24,364 sites.
  - Whether `Tests/` and `Boneyard/` are in or out. `Boneyard/` is unbuilt and inert; renaming it buys nothing, but leaving it stale costs nothing either. Decide deliberately, not by accident.
  - The 121 `-> Prop` predicates: some may be convertible to `theorem` on their own merits (as the 38 already were), which removes them from the linter's scope ENTIRELY and is strictly better than renaming them. Establish how many.

INTERACTION WITH THE SEMANTIC-RENAMING TASK -- READ BEFORE CHOOSING TARGET NAMES: a separate task covers SEMANTIC renaming (`ecq` -> `bot_of_and_neg`, `lce` -> `and_left`, expanding opaque abbreviations `bfmcs`/`cud`/`sdc`/`dd_`/`tc_`/`fuc_`/`buc_`, and eliminating Bridge.lean wrappers). Its proposed target names are SNAKE_CASE, which is correct for `theorem`s but WRONG for `def`s under the very convention this task enforces. Any declaration that remains a `def` must receive a lowerCamelCase semantic name (`botOfAndNeg`, not `bot_of_and_neg`). Do not choose a target name for a declaration without knowing whether it will be a `def` or a `theorem`. Coordinate rather than rename twice.

VERIFICATION BAR: `lake build` green with no new errors, `BimodalTest` green, and the sole live `sorry` count unchanged -- locate it BY CONTENT in `Metalogic/WeakCanonical/Transfer.lean`, never by line number, it drifts. NOTE `defsWithUnderscore` emits NOTHING during `lake build`, and CI runs `lean-action` with `lint: false`, so a green build is NOT evidence for this category. Every count must come from an explicit `lake exe runLinter Bimodal`. As `nolints.json` rows are deleted the count must reach 0 by genuine conformance, not because the file still masks them.

TOOLING: reuse the gated harnesses at `specs/400_clear_lean_v433_deprecation_warnings/tools/` (`lintlib.py`, `fixers.py`, `gate.py`) and `runlinter.py` from `specs/399_mathlib_linter_compliance_tier3_metalogic/tools/`. Solved traps: raw `lean` emits `PATH:L:C: severity: msg` while lake emits `severity: PATH:L:C: msg`; `LINTER FAILED` comes in two row shapes (positioned + positionless `#check`) and appears mid-message; `run_lint` needs `-DautoImplicit=false` or it elaborates more permissively than `lake build`.

SCOPE DISCIPLINE: do not re-open the naming policy -- full Mathlib conformance is decided. Research the mechanism, the staging, and the target-name derivation rule, not whether to do it.

---

### 401. Align typst manual license with apache
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Topic**: publication-quality
- **Dependencies**: None

**Description**: Resolve the one remaining inconsistency in the repo's license story. The project was relicensed GPL-3.0 to Apache-2.0 by explicit user authorization: LICENSE now holds the complete standard Apache-2.0 text, README.md states Apache-2.0, and all 279 live .lean files under Theories/ carry the Apache header.

THE CARVE-OUT: Theories/Bimodal/typst/BimodalReference.typ:10 and :111 carry 'Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.' with NO 'Released under' line -- an all-rights-reserved assertion on the reference manual, originating from a deliberate earlier decision that no open license be applied to that document. The relicensing task intentionally left those notices unchanged rather than silently reversing that decision, and instead documented the carve-out in the README License section. So the current state is coherent and openly stated, not broken -- but it does mean an Apache-2.0 repository contains one all-rights-reserved document.

THIS TASK IS A DECISION FIRST, AN EDIT SECOND. Research and present the options, then implement the choice:
  (a) Bring the manual under Apache-2.0 too, for a single uniform license story. Simplest to explain; gives up the reserved-rights position on the document.
  (b) Keep the carve-out and strengthen it -- make the reservation explicit in the .typ source itself (naming it as a deliberate exception to the repo's Apache-2.0 license) rather than relying on a README sentence, so a reader of the file alone is not misled.
  (c) Apply a documentation-appropriate open license (e.g. CC-BY-4.0) to the manual, distinct from the code license.
The copyright holder is the sole author, so any of these is theirs to authorize. Do NOT change the licensing of the manual without explicit authorization -- surface the recommendation and wait.

ALSO CHECK: whether any generated PDF or other typst/latex output carries the same notice and would need regenerating for consistency, and whether Theories/Bimodal/latex/ has an equivalent notice (the original discovery sweep found the .typ sites; confirm latex/ is clean).

Verify afterwards that no license assertion anywhere in the repo contradicts any other. The prior sweep also established two NON-issues to leave alone: license mentions in docs/research/ and specs/literature/ describe THIRD-PARTY projects' licenses, not this repo's.

---

### 400. Clear lean v433 deprecation warnings
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 393, Task 399
- **Research**: [400_clear_lean_v433_deprecation_warnings/reports/01_deprecation-census-and-validation.md]
- **Plan**: [400_clear_lean_v433_deprecation_warnings/plans/01_clear-deprecation-warnings.md]
- **Summary**: [400_clear_lean_v433_deprecation_warnings/summaries/01_clear-deprecation-warnings-summary.md]

**Description**: Clear the 554 deprecation warnings in the build. These are Lean v4.31-to-v4.33 upgrade residue, not linter-compliance findings, which is why earlier compliance work correctly excluded them.

MEASURED: 554 warnings total, of which 506 are `push_neg` (the replacement is `push Not`). 553 are in the tier-3 Metalogic subset and 1 is in Automation/; ZERO are in the 67 tier-1/tier-2 modules already brought to mechanical compliance.

The `push_neg` bulk is highly mechanical and a good candidate for a scripted pass with per-file verification, but confirm the exact replacement semantics before bulk-applying: verify on a handful of sites that `push Not` is behaviour-preserving in this codebase's usage, since a tactic rename is not always a pure substitution. Enumerate and handle the remaining ~48 non-push_neg deprecations individually.

SEQUENCING: depends on the archivable-sorry review and the tier-3 compliance work, both of which touch the same Metalogic/ files -- and the archival review may remove some of these files from the build entirely, making a subset of these warnings disappear for free. Re-derive the count at start.

Toolchain is Lean v4.33.0-rc1. Targets are `Bimodal.*`, NOT `Theories.Bimodal.*`.

INVARIANTS: `lake build` must stay at 0 errors, and the sorry count must remain exactly 12 at unchanged locations (or lower, if archival removed some). Do not rename declarations and do not convert `def` to `theorem` -- separate task territory. Verify per file; a tactic substitution that changes a goal state can break a proof several lines later.

---

### 399. Mathlib linter compliance tier3 metalogic
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 393, Task 398
- **Research**: [399_mathlib_linter_compliance_tier3_metalogic/reports/01_tier3-linter-inventory.md]
- **Plan**: [399_mathlib_linter_compliance_tier3_metalogic/plans/01_tier3-linter-compliance.md]
- **Summary**: [399_mathlib_linter_compliance_tier3_metalogic/summaries/01_tier3-linter-compliance-summary.md]

**Description**: Extend Mathlib linter compliance to the tier-3 Metalogic subset that earlier compliance work explicitly deferred. This is the largest remaining compliance surface in the repo.

MEASURED SCOPE: 166 files, approximately 6,136 diagnostics. It was deferred for a principled reason, not arbitrarily: the originating task's own predicate was 'all sorry-free modules', and this subset is NOT sorry-free -- it holds all 12 of the repo's live sorries (Bundle/SuccRelation.lean x7, Bundle/SuccExistence.lean x3, BXCanonical/Chronicle/ChronicleToCountermodel.lean x1, WeakCanonical/Transfer.lean x1).

SEQUENCING RATIONALE: this task depends on the archivable-sorry review completing first, because that review may move some sorry-bearing code into Boneyard/ (unbuilt and inert, therefore exempt from linting). Linting files that are about to be archived is wasted effort. Re-derive the file list and diagnostic counts at start rather than trusting the 166/6,136 figures, which predate any archival.

ALSO INCLUDED: the remaining docBlame findings. 91 were reported project-wide; 8 in-scope ones are already fixed, so roughly 83 remain, concentrated here.

WORKING INVOCATIONS (verified, Lean v4.33.0-rc1): `lake exe runLinter Bimodal` (declaration linters), `lake env lean -Dlinter.mathlibStandardSet=true <file>` (style/syntax), `set_option linter.all true` (core set -- it does exist and work). Targets are `Bimodal.*`, NOT `Theories.Bimodal.*`.

HARD-WON LESSONS from the tier-1/tier-2 pass -- apply them, they will save significant time:
  1. The `emptyLine` diagnostic count is NOT a blank-line count. Splitting a long line changes which blank lines fall inside a command's syntactic span, so the emptyLine count can RISE after line-wrapping with zero blank lines added (it went 489 -> 507 in the earlier pass). Drive from re-derived positions and iterate to zero; never trust a precomputed per-file number.
  2. Mathlib's scripts/fix_unused.py is STALE against v4.33: its regex expects 'unused variable `x`' but Lean now emits 'Variable name `x` is not explicitly referenced.' Fix those by hand.
  3. Mathlib's scripts/fix_long_lines.py only cuts at commas -- applicable to about 42% of sites, and it mangles prose (it split a doc-comment bullet mid-item in testing). Expect to hand-fix a majority.
  4. Line-breaking hazards that a build gate caught previously: never leave `return`, `pure`, `throw`, or `yield` last on a line (do-notation's `return` takes an OPTIONAL argument, so it silently reparses); always split a trailing `--` comment onto further comment lines rather than wrapping it as code; a docstring placed between an attribute and its declaration is a parse error.

OUT OF SCOPE: all naming work (owned by the naming task); the 554 deprecation warnings (own task); Boneyard/. Do not alter the sorry count -- resolving those sorries is separate work.

Given the size, expect this to need multiple dispatches. Commit per phase at every green build.

---

### 398. Fix judgment requiring linter categories
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 393
- **Research**: [398_fix_judgment_requiring_linter_categories/reports/01_judgment-linter-categories-inventory.md]
- **Plan**: [398_fix_judgment_requiring_linter_categories/plans/01_judgment-linter-remediation.md]
- **Summary**: [398_fix_judgment_requiring_linter_categories/summaries/01_judgment-linter-remediation-summary.md]

**Description**: Resolve the Mathlib linter categories that a sibling mechanical-compliance task deliberately deferred because each one CHANGES PROOF SHAPE and therefore needs judgment plus re-verification, rather than a mechanical edit. That task took the mechanical categories to zero across the 67 sorry-free ported modules; these remain.

MEASURED RESIDUAL INVENTORY (post-mechanical-pass, authoritative):
  linter.flexible          78  (24 tier-1 + 54 tier-2) -- the bulk of the work
  linter.style.show        10  (1 tier-1 + 9 tier-2)
  unusedArguments          10  (in scope; each is a signature change with its own blast radius)
  linter.style.nativeDecide 4  (all tier-2)
  linter.unusedTactic       2  (all tier-2)
  linter.style.multiGoal    2  (all tier-2)
  linter.style.openClassical 1 (tier-2)
  simpNF                    1  in scope (of 42 project-wide)

`linter.flexible` concentration, for phase sizing: Saturation 21, Core/DeductionTheorem 12, ProofSystem/Axioms 9, Propositional/Connectives 6, Core/RestrictedMCS/Basic 6, then a tail of 14 files with <=4 each. Each site requires running `simp?`, transcribing its suggestion, and re-verifying the proof still closes -- this is why it was deferred.

KNOWN HAZARD on simpNF: 17 of tier-1's 18 simpNF findings report as 'LINTER FAILED', i.e. the linter itself errored rather than reporting a real issue. Do not chase those as if they were defects; diagnose whether the linter failure is itself the finding.

WORKING LINTER INVOCATIONS (verified on Lean v4.33.0-rc1): `lake exe runLinter Bimodal` for declaration linters, `lake env lean -Dlinter.mathlibStandardSet=true <file>` for style/syntax, and `set_option linter.all true` for the core Lean set (this DOES exist and work, contrary to an earlier report). Build targets are `Bimodal.*`, NOT `Theories.Bimodal.*` (srcDir := "Theories", roots := #[`Bimodal]).

OUT OF SCOPE: all naming work including defsWithUnderscore and the 3 linter.defProp def-to-theorem conversions (owned by the naming task); tier-3 Metalogic bulk compliance (its own task); the 554 deprecation warnings (its own task); Boneyard/ (unbuilt, inert).

INVARIANTS: `lake build` must stay at 0 errors with exactly 12 `declaration uses 'sorry'` warnings at their existing Metalogic/ locations. Since every change here touches proof shape, verify after EACH file, not just at the end. If a linter suggestion breaks a proof, restore the original and record it as an accepted residual with the reason -- do not force a fix.

---

### 397. Update stale toolchain version in claudemd
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Topic**: publication-quality
- **Dependencies**: None

**Description**: CLAUDE.md:25 states 'v4.27.0-rc1 with Mathlib v4.27.0-rc1'. This is STALE and wrong: the actual toolchain is Lean v4.33.0-rc1, verified two ways -- lean-toolchain reads 'leanprover/lean4:v4.33.0-rc1', and `lake env lean --version` reports 'Lean (version 4.33.0-rc1, x86_64-unknown-linux-gnu, commit 62eed1db4d67327ec8120be05f1a1b0847d74561, Release)'.

This mattered concretely and repeatedly: multiple agents had to be told to disregard CLAUDE.md's version, and one recorded a false conclusion partly downstream of version confusion (it reported `set_option linter.all true` as nonexistent when it does exist and works -- confirmed by a control test in which a bogus option name errors with 'Unknown option' while linter.all compiles clean and emits real diagnostics).

Fix CLAUDE.md:25 to state the correct Lean and Mathlib versions. Determine the Mathlib version empirically rather than assuming it matches the Lean version string -- check lake-manifest.json / .lake/packages/mathlib for the actual pinned revision.

ALSO SWEEP for other stale version assertions and fix or report them: grep the repo (excluding .lake/, .git/, and specs/) for 'v4.2', 'v4.3', '4.27', '4.31', '4.33', and 'Lean 4 version'. A related known fact worth recording where appropriate: the 554 deprecation warnings currently in the build are v4.31-to-v4.33 upgrade residue, which corroborates that the documented version is several releases behind.

Consider adding a note on how to re-derive the version (`cat lean-toolchain`) so the next reader does not have to trust a hand-maintained number. Documentation-only.

---

### 396. Correct stale sorry claims in user docs
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Topic**: publication-quality
- **Dependencies**: None

**Description**: Correct documentation that misrepresents completed proofs as unproven. A sibling task fixed this class of staleness inside .lean source but explicitly excluded docs/, which was outside its scope.

CONFIRMED INSTANCE: Theories/Bimodal/docs/user-guide/architecture.md around lines 229-240 contains illustrative code blocks presenting FOUR perpetuity principles as unproven stubs -- `theorem perpetuity_3 ... := by sorry`, and likewise perpetuity_4, perpetuity_5, perpetuity_6. All four are in fact fully proven with zero sorries. Note this is four, not the three an earlier pass reported; verify the full extent yourself rather than trusting either count.

VERIFIED GROUND TRUTH: `lake build` succeeds at 1877 jobs, 0 errors, with exactly 12 `declaration uses 'sorry'` warnings, and ALL 12 are in Metalogic/ (Bundle/SuccRelation.lean x7, Bundle/SuccExistence.lean x3, BXCanonical/Chronicle/ChronicleToCountermodel.lean x1, WeakCanonical/Transfer.lean x1). Nothing in Theorems/ has a sorry. perpetuity_1 through perpetuity_6 are all proven -- P1-P5 in Theorems/Perpetuity/Principles.lean, P6 in Theorems/Perpetuity/Bridge.lean.

SWEEP, do not just fix the one known file: grep all of Theories/Bimodal/docs/ for 'sorry', 'In Progress', 'NOT STARTED', 'PARTIAL', 'pending', and 'infrastructure gap', and check each hit against the actual code. A known additional candidate: Theories/Bimodal/docs/project-info/tactic-registry.md:68 describes perpetuity_1 through perpetuity_6 as 'In Progress'.

CRITICAL RULE: verify each claim against the code BEFORE rewriting it. Do not replace one unverified claim with the unverified inverse -- check the declaration, confirm it builds, and confirm no sorryAx via `#print axioms` before asserting it is proven. Where an illustrative code block is deliberately schematic rather than a status claim, make that explicit in the prose instead of deleting the example.

Documentation-only. Do not modify any .lean file and do not write any proof.

---

### 395. Add apache headers to test files
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: None

**Description**: Add the Apache 2.0 copyright header to the 42 .lean files under Tests/. The sibling headers task covered only Theories/ (279 files); Tests/ was outside its file_scope and currently has ZERO conforming headers, verified by count.

Three files additionally carry a vague placeholder line that must be REPLACED, not prepended to, or they end up double-headered: Tests/BimodalTest/TraceExporterE2ETest.lean:3, Tests/BimodalTest/TraceCertificateTest.lean:3, and Tests/BimodalTest/TraceExportTest.lean:3 each read 'Released under the project's standard license.' That line was not falsified by the GPL-to-Apache relicensing, but it is vague and should now name Apache-2.0 explicitly.

USE EXACTLY this verified format -- a /- -/ BLOCK comment, not '--' line comments (the '--' variant was tested against Mathlib's copyrightHeaderChecks and REJECTED), with the individual holder rather than a collective, and the per-file git creation year:
  /-
  Copyright (c) YYYY Benjamin Brast-McKie. All rights reserved.
  Released under Apache 2.0 license as described in the file LICENSE.
  Authors: Benjamin Brast-McKie
  -/
The header must precede any `import` line.

The repo LICENSE is now Apache-2.0 (relicensed from GPL-3.0 by explicit user authorization), so the license assertion is TRUE -- no relicensing work is needed here.

VERIFY with `bash scripts/check-copyright-headers.sh --strict Tests` (that script already exists). Do NOT rely on Mathlib's linter.style.header: it is a proven FALSE NEGATIVE in this repo because its isInLibraryRoot looks for ./Bimodal.lean while the lakefile's srcDir := "Theories" puts the root at Theories/Bimodal.lean, so it silently no-ops. The duplicate-detection predicate must count '^Copyright \(c\) ' across the WHOLE file, not just validate the leading block, or a double-headered file passes silently.

Confirm Tests/ still builds and passes afterwards.

---

### 394. Resolve mathlib naming convention compliance
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 292, Task 293, Task 393, Task 395, Task 396, Task 398, Task 399, Task 400, Task 401
- **Research**: [394_resolve_mathlib_naming_convention_compliance/reports/01_naming-convention-decision-evidence.md]
- **Plan**: [394_resolve_mathlib_naming_convention_compliance/plans/01_defprop-conversion-nolints-suppression.md]
- **Summary**: [394_resolve_mathlib_naming_convention_compliance/summaries/01_defprop-conversion-nolints-suppression-summary.md]

**Description**: Resolve Mathlib naming-convention compliance for the cslib porting scope. Split out as a dedicated task by explicit user decision, because it is the one linter category that is a breaking API decision rather than mechanical cleanup. The sibling linter-compliance task deliberately does NOT touch naming -- it handles only mechanical categories (line length, unused simp args, docstrings, blank lines).

VERIFIED BASELINE (empirical, toolchain is Lean v4.33.0-rc1 -- note the top-level CLAUDE.md claims v4.27.0-rc1 and is stale). Working linter mechanisms on this toolchain:
  - `lake exe runLinter Bimodal` -- Mathlib DECLARATION linters (the source of the findings below)
  - `lake env lean -Dlinter.mathlibStandardSet=true <file>` -- style/syntax linters
  - `set_option linter.all true` -- core Lean linter set; this DOES exist and work (a prior research pass wrongly recorded it as nonexistent; verified against a control test in which a bogus option name errors with 'Unknown option' while linter.all compiles clean and emits real warnings)

FINDINGS: `defsWithUnderscore` reports 239 errors in the recommended porting scope (189 in tier 1 -- Syntax, Semantics, ProofSystem, Theorems, FrameConditions; 50 in tier 2 -- Metalogic Soundness/Core/Completeness/Decidability/Separation) and 902 project-wide.

ROOT CAUSE IS ARCHITECTURAL, not sloppiness: `DerivationTree` is Type-valued (ProofSystem/Derivation.lean:85), so every derived theorem must be a `def` rather than a `theorem`, and Mathlib demands lowerCamelCase for defs. The existing names are meaningful snake_case that reads as mathematics (`box_conj_iff`, `perpetuity_5`, `s4_box_diamond_box`). Any fix must engage this root cause rather than treating the names as arbitrary.

THE DECISION THIS TASK MUST MAKE (deliberately left open -- research and recommend, then implement the chosen route):
  (a) SUPPRESS: add @[nolint defsWithUnderscore] attributes and/or scripts/nolints.json entries. Non-breaking, zero call-site churn, keeps mathematical readability. Leaves a documented deviation from Mathlib convention.
  (b) RENAME all 239 to lowerCamelCase. Fully conformant but a breaking API change rippling across 429 .lean files plus Tests/. Highest churn and regression risk.
  (c) PARTIAL: convert the 39 `linter.defProp` cases to `theorem` and suppress or accept the rest.

THE UNAMBIGUOUSLY-SAFE SUBSET, valid under any of the three routes: 39 declarations are flagged by `linter.defProp`, meaning they are `def`s whose type is actually a Prop and which should be `theorem`s. Converting those to `theorem` is semantically correct on its own merits AND removes them from defsWithUnderscore automatically (the linter only applies to defs). Do this subset first regardless of the route chosen for the remaining ~200.

DEAD ENDS -- do not spend effort here (verified): `drm` has zero occurrences outside the unbuilt Boneyard/, so the frequently-cited 'rename drm' item is dead code and needs no rename. All 209 `BFMCS` occurrences live inside the deferred tier-3 Metalogic subset, entirely outside the core porting scope. There are no universe-polymorphism findings at all -- no universe linter exists in this toolchain, Semantics already uses `(D : Type*)` consistently, and Validity.lean:71 documents its one monomorphization as deliberate. Mathlib's scripts/fix_unused.py is stale against v4.33 (its regex expects 'unused variable `x`' but Lean now emits 'Variable name `x` is not explicitly referenced') -- do not assume it runs.

VERIFICATION: `lake build` must stay green with no new errors, and Tests/ must still build and pass. If route (b) is chosen, the rename must be complete -- a partial rename that leaves dangling references is worse than no rename. Re-run `lake exe runLinter Bimodal` to confirm the defsWithUnderscore count actually drops as intended.

---

### 393. Review archivable sorries to boneyard
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: sorry-elimination
- **Dependencies**: Task 292, Task 293
- **Research**: [393_review_archivable_sorries_to_boneyard/reports/01_sorry-archivability-verdicts.md]
- **Plan**: [393_review_archivable_sorries_to_boneyard/plans/01_archive-dead-sorries-boneyard.md]
- **Summary**: [393_review_archivable_sorries_to_boneyard/summaries/01_archive-dead-sorries-boneyard-summary.md]

**Description**: Review the 12 remaining live `sorry` instances and determine which, if any, can safely be archived to Theories/Bimodal/Boneyard/ rather than proven. This is an ANALYSIS AND DECISION task: the deliverable is a per-sorry verdict backed by reachability evidence, not a proof effort and not a bulk file move.

VERIFIED BASELINE (established by a full `lake build`, 1877 jobs, currently succeeding). Note module names are `Bimodal.*`, NOT `Theories.Bimodal.*` -- the lakefile sets srcDir := "Theories" and roots := #[`Bimodal]. All 12 live sorries are in Metalogic/; the rest of the tree (Syntax, Semantics, ProofSystem, Theorems, FrameConditions) is sorry-free:
  Metalogic/Bundle/SuccRelation.lean:553 until_unfold_in_mcs
  Metalogic/Bundle/SuccRelation.lean:562 since_unfold_in_mcs
  Metalogic/Bundle/SuccRelation.lean:585 until_persists_through_succ
  Metalogic/Bundle/SuccRelation.lean:609 or_until_in_mcs
  Metalogic/Bundle/SuccRelation.lean:623 or_since_in_mcs
  Metalogic/Bundle/SuccRelation.lean:636 g_content_subset_mcs
  Metalogic/Bundle/SuccRelation.lean:646 h_content_subset_mcs
  Metalogic/Bundle/SuccExistence.lean:436 constrained_successor_seed_consistent
  Metalogic/Bundle/SuccExistence.lean:742 successor_deferral_seed_consistent_axiom
  Metalogic/Bundle/SuccExistence.lean:816 predecessor_deferral_seed_consistent_axiom
  Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean:194 chronicle_gap_contradiction (private)
  Metalogic/WeakCanonical/Transfer.lean:1277 countermodel_discrete

THE CENTRAL CONSTRAINT: `Bimodal.Metalogic.BXCanonical.completeness` (Metalogic/BXCanonical/Completeness.lean:395) depends on axioms [propext, sorryAx, Classical.choice, Quot.sound]. The `sorryAx` dependency proves that AT LEAST SOME of these 12 sorries are load-bearing for the headline completeness theorem, and those are therefore NOT archivable at all -- archiving them would silently delete a real proof obligation and break completeness. Partitioning the 12 into load-bearing vs genuinely dead is the core question this task must answer. Use `#print axioms` / lean_verify on completeness and trace the sorryAx dependency chain to identify precisely which of the 12 it flows through; do not guess from names or file locations.

ARCHIVABILITY CRITERION, per the existing convention documented in Theories/Bimodal/Boneyard/README.md: the Boneyard holds dead-end approaches, superseded implementations, and architecturally-incompatible code. No Boneyard file is imported by any active module -- the whole directory is inert with respect to `lake build`, files there are not required to compile, and its sorry counts are explicitly NOT open proof obligations. The README's own archival rationales turn on 'zero live importers' / 'no live downstream consumers'. So the operative test per sorry is: does any live, reachable declaration depend on it? Establish this with lean_references / grep for each declaration, and record the evidence.

EXPECTED DELIVERABLE -- one verdict per sorry, each with evidence:
  (a) ARCHIVE: dead, zero live consumers, safe to move to Boneyard/ as a documented unit.
  (b) KEEP AND PROVE: load-bearing for completeness or another live result; a real obligation.
  (c) KEEP AS EXPLICIT AXIOM: intended as a stated assumption rather than a gap -- note the three declarations already named '..._axiom' (SuccExistence.lean:742, :816) suggest this category may already be intended, in which case converting them from `sorry` to a declared `axiom` (or documenting them as such) is more honest than either archiving or proving.

LEAD TO INVESTIGATE: Boneyard/README.md's inventory already lists a DeadChronicleGapElimination directory archived specifically for 'the chronicle_gap_contradiction sorry chain', noting the live completeness_discrete path uses the Reynolds pipeline instead. Yet a live chronicle_gap_contradiction still exists at ChronicleToCountermodel.lean:194. Determine whether this is a leftover that the earlier archival pass missed -- if so it is a strong ARCHIVE candidate.

IF any sorry is archived, follow the established Boneyard conventions: move as a coherent unit, add or update the subdirectory README explaining what was archived and why it is dead, add the corresponding row to the inventory table in Boneyard/README.md following that table's existing format, and verify `lake build` still succeeds with a strictly reduced sorry-warning count and no new errors. Confirm no live module imports the archived path.

SCOPE DISCIPLINE: do not attempt to prove any sorry under this task -- proving is a separate, much larger effort. If the analysis concludes a sorry must be proven, record it as a recommendation with an assessment of difficulty rather than starting the proof.

---

### 392. Correct kamp dedekind task charters
- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Topic**: kamp-completeness
- **Dependencies**: None

**Description**: Two backlog corrections on the Kamp/Dedekind path, both of which currently mislead any agent that reads them.

CORRECTION 1 -- rewrite task 378's charter under the new goal.
Task 378 (rebase_section5_onto_faithful_dedekind_carrier) leads with a prominent banner declaring the work "fidelity-only, ZERO OPERATIONAL VALUE", justified as follows: the live goal chain runs on Prior structures where INF/SUP attainment holds outright via the UZ axiom (prior_hasAttainedINF, Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean:224), so no consumer can observe the difference between HasAttainedINF and HasDedekindINF. That reasoning was correct for the goal in force when it was written.
It is now obsolete. The project goal is a genuine Dedekind-complete FRAME CLASS with its own completeness theorem, with the Rabinovich Section 5 re-base as a fidelity prerequisite feeding it. Under that goal the value calculus inverts: a Dedekind-complete frame class has consumers that CAN observe the difference, and hasDefinableINF_excludes_kplus (Kamp/Lemma53.lean:282, axiom-clean) machine-proves that the currently-landed HasDefinableINF DELETES the paper's disjunct (2) -- exactly what a Dedekind-complete class cannot afford.
Action: rewrite the description so the banner reflects the new goal, state the dependency direction explicitly (378 feeds the frame-class work), and keep every binding constraint intact -- the THREE-STRIKES PROHIBITION on EANegation.lean:1090 and :1249, the AMENDED SORRY GATE (only KampPrior.lean:520, EANegation.lean:1090, EANegation.lean:1249 permitted; add zero), the EXTENDED NON-VACUITY RULE, and the PDF-page-only citation rule for Rabinovich. Do NOT re-litigate the deferral rationale itself; only the value framing changes. Preserve the pointer to specs/377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md and the note that its Phase 6 task list is now largely DONE (re-scope to Phases 7-8).

CORRECTION 2 -- spawn task 383's missing unblock sub-task.
Task 383 is BLOCKED. Its dependency 382 is satisfied (archived). The actual blocker is an arity mismatch recorded in its blockers field: the negation ENGINE is complete, green and sorry-free (Prop42NegationGeneral.lean, Phases 1-6), but the augTarget_iff seam (Metalogic/WeakCanonical/Kamp/ExistsForallLemmas.lean:696) has ZERO live consumers, and the parent's real Phase-7 gap at KampPrior.lean:562 is a deeper model-independent arity-m negation, not a 2-variable one. VVecEA2.negFix_iff is additionally gated on strict order z0 < z1, so it does not apply to unordered pairs or to 0-free-variable existence sentences.
The record names two candidate remedies and recommends /spawn: either (i) a live completeness consumer reducing Prop 4.3 negation to per-pair strictly-ordered 2-variable exists-forall negations, or (ii) a design sub-task on unordered-pair projection plus 0-free-var existence-sentence negation. NEITHER HAS EVER BEEN CREATED, which is why 383 has sat blocked.
Action: run /spawn 383, or create the chosen sub-task directly, and wire 383's dependencies to it.
IMPORTANT: 383's description leads with a GO-branch scope (steps 1-3, roughly 870-1230 lines) that task 382's verdict RETIRED -- 382 returned RECONCILE, not GO (specs/archive/382_adjudicate_rabinovich_faithfulness_of_the_phase_7_negationcase_unblock/reports/01_go-reconcile-verdict.md). The costed alternative is efSat_split D1 plus prop42_efSat_negation_general D2 plus wire D3, roughly 350-550 lines. Correct the description so the superseded GO scope cannot be used for planning.
This is the same producer-consumer arity shape that killed tasks 358 and 376 and forced task 321's v6 redesign; treat a low-arity producer meeting a higher-arity consumer as the known failure mode.

---

### 391. Frameclass dedekind scaffolding
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 390, Task 291

**Description**: Design and land the frame-class scaffolding for a Dedekind-complete extension, once the carrier-construction research resolves GO.

PROBLEM 1 -- the frame-class order does not admit a Dedekind tier. Theories/Bimodal/ProofSystem/Axioms.lean:424-427 defines "inductive FrameClass where | Base | Dense | Discrete". The LE instance at :430 gives Base <= everything, with Dense and Discrete reflexive-only and mutually incomparable; PartialOrder is at :440. A Dedekind-complete order is a fortiori DENSE, so it validates both the density axiom (Axioms.lean:387) and dense_indicator (:399). A Dedekind constructor therefore sits ABOVE Dense, which the current three-element order does not anticipate: adding it is not a fresh incomparable leaf but a genuine change to the order's shape. FrameClass is referenced 1649 times across 118 live files, and the gate ax.minFrameClass <= fc is enforced structurally in DerivationTree's axiom constructor (ProofSystem/Derivation.lean:92), upstream of every derivation and soundness proof. Expect the LE and PartialOrder proofs to need real work, not just an extra case; the existing proofs are "cases <;> simp_all" and may or may not survive.

PROBLEM 2 -- there is no axiom characterizing Dedekind completeness. Axiom.minFrameClass (Axioms.lean:458) is the single source of truth for axiom-frame-class compatibility and currently maps only density and dense_indicator to Dense, and prior_UZ / prior_SZ / z1 to Discrete. No candidate Dedekind axiom exists in the Axiom inductive. The characterizing axiom comes out of the carrier-construction research; this task lands it.

SCOPE (each item is a phase boundary, size accordingly):
1. FrameClass.Dedekind constructor plus reworked LE / DecidableRel / PartialOrder instances, preserving the minFrameClass <= fc invariant. Full build green.
2. The characterizing axiom in the Axiom inductive plus its minFrameClass row.
3. valid_dedekind in Theories/Bimodal/Semantics/Validity.lean alongside valid (:73), valid_dense (:162), valid_discrete (:180), plus the valid -> valid_dedekind bridge mirroring :193 and :200.
4. Optionally a DedekindTemporalFrame marker class in Theories/Bimodal/FrameConditions/FrameClass.lean alongside LinearTemporalFrame (:82), SerialFrame (:97), DenseTemporalFrame (:118), DiscreteTemporalFrame (:142). NOTE these marker classes are a side-car: the live completeness and soundness theorems do NOT consume them, they consume the raw instance-binder validity predicates in Semantics/Validity.lean. Do not mistake the side-car for the load-bearing layer.
5. soundness_dedekind plus per-axiom validity lemmas in Theories/Bimodal/Metalogic/Soundness.lean, alongside soundness (:1023), soundness_dense (:1193), soundness_discrete (:1338). axiom_swap_valid_general (SoundnessLemmas/FrameClassVariants.lean:34) is frame-class-free and directly reusable.
The completeness theorem itself is NOT in this task's scope -- it depends on the countermodel construction, which the research task must deliver first.

TEMPLATE TO FOLLOW. All three live completeness theorems sit in Metalogic/BXCanonical/Completeness.lean (completeness :181, completeness_dense :247, completeness_discrete :288) and share one five-move contrapositive: by_contra into neg_consistent_of_not_derivable (:66, generic in fc); set_lindenbaum to an MCS; split on box(not U(top,bot)) via negation_complete; a frame-class-specific countermodel in the matching branch; and a frame-class-specific proof-theoretic elimination of the non-matching branch. Step 5 is where a frame class "pays for itself" -- completeness_dense closes its branch from dense_indicator (:263-268), completeness_discrete derives U(top,bot) from prior_UZ plus left_mono_until_G plus Modal-T (:300-342). Note discrete_box_necessity is a BASE axiom, which is what lets mcs_mixed_case_absurd work at any frame class -- a Dedekind class inherits it free.

---

### 390. Dedekind carrier construction research
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 389

**Description**: Research task: determine how a Dedekind-complete carrier can be produced for the canonical-model construction. This is the mathematical crux of the Dedekind-complete completeness effort and MUST resolve before any implementation plan is written.

THE OBSTRUCTION. specs/ROADMAP.md:1477 describes the chronicle limit domain X as a COUNTABLE linear order (sparse X subset of Rat for Base, Rat for Dense, order-isomorphic to Int for Discrete). But a Dedekind-complete, densely ordered, unbounded linear order is order-isomorphic to the reals, hence uncountable. So the existing chronicle / canonical-model route cannot directly yield a Dedekind-complete carrier.
Corroborating anchors: specs/ROADMAP.md:317-320 warns that dense domains such as Rat are WRONG for general completeness (GGp -> Gp is valid on Rat but not derivable in BX; Burgess uses a sparse X subset of Rat). specs/ROADMAP.md:1414's "Representation Theorem Goal" enumerates D' = Rat (base), Rat (dense), Int (discrete) and has NO reals row. Theories/Bimodal/Metalogic/WeakCanonical/Kamp/DedekindINF.lean:44 states flatly that no reals OrderedMonadicStructure is constructed here or anywhere in this tree.

QUESTIONS TO ANSWER, with literature grounding (see the Dedekind literature-remediation task):
1. Does the intended semantics quantify over Dedekind-complete ORDERS, or over Dedekind-complete orders arising as duration groups? The live validity predicates take instance binders on a duration type D (Theories/Bimodal/Semantics/Validity.lean:73 valid, :162 valid_dense, :180 valid_discrete). Establish what the Dedekind analogue's binder list must be.
2. Is a Dedekind completion of the countable limit domain sound for the truth lemma -- i.e. does adding limit points preserve the coherence conditions the BFMCS bundle requires? If not, why not, and what is the obstruction precisely.
3. What does the literature actually do? Reynolds 1992 axiomatizes Until/Since over the reals; GHR94 Ch.10 section 10.3 treats separation over Dedekind-complete flows. Extract the construction each uses for the carrier and state whether it is a completion, a direct construction, or a representation argument.
4. Is the target completeness result even true for the intended axiom set, and what axiom characterizes Dedekind completeness? No candidate exists in the Axiom inductive today.

CONSTRAINTS. Standing ROADMAP anti-patterns apply: do NOT attempt a direct IsSuccArchimedean proof bypassing chronicle_gap_contradiction; do NOT attempt the "discrete bypass"; decidability-based completeness is explicitly excluded as a path to the representation theorem.
Reusable scaffolding that a solution must plug into (all live, sorry-free, generic in the duration type D and the frame class fc): ParametricCanonicalTaskFrame (Algebraic/ParametricCanonical.lean:200), ParametricCanonicalTaskModel (Algebraic/ParametricTruthLemma.lean:101), parametric_canonical_truth_lemma (:226), restricted_parametric_shifted_truth_lemma (Algebraic/RestrictedParametricTruthLemma.lean:109), and the single funnel both live countermodels go through, fully_restricted_parametric_completeness_from_neg_membership (:394). Also neg_consistent_of_not_derivable (Metalogic/BXCanonical/Completeness.lean:66, generic in fc) and mcs_mixed_case_absurd (Chronicle/MCSMixedCase.lean:34, takes fc explicitly). structure Gap (Metalogic/WeakCanonical/EFGames/Defs.lean:230) is the existing object with the right shape for phrasing "no Dedekind gaps" as a frame condition.
Related warning from the existing tree: Metalogic/BXCanonical/Completeness.lean:168-179 documents why the general completeness theorem still carries sorryAx -- a Base-MCS is not automatically Discrete-consistent, so the sorry-free Reynolds pipeline cannot be reused. A Dedekind variant will hit the structurally identical problem and must build a countermodel from an MCS of its own class.
DELIVERABLE: a research report with a GO / NO-GO recommendation and, if GO, the carrier construction to be formalized. Dispatch with --lit.

---

### 389. Repair dedekind literature corpus
- **Effort**: medium
- **Status**: [PLANNED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: None
- **Research**: [389_repair_dedekind_literature_corpus/reports/01_repair-literature-corpus.md]
- **Plan**: [389_repair_dedekind_literature_corpus/plans/01_repair-literature-corpus.md]

**Description**: Repair the literature corpus for the Dedekind-complete completeness effort. Two parts.

PART 1 -- Rabinovich conversion is silently corrupt and the index falsely certifies it (CRITICAL).
~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md contains ZERO occurrences of the character "!=" (U+2260) across the whole 16-page paper, while <= (4 occurrences) and >= (3) survived -- the PDF-to-markdown converter dropped the glyph, so every inequality reads as an equality. Measured at md:199 the Prop 4.2 case split reads "In the first case k = m, i.e., z0 = z1 and in the second k = m", and md:201 reads "If k = m, w.l.o.g. we assume that m < k". Both should be the negated form. This is Section 5 / Proposition 4.2 -- exactly the "equivalent over Dedekind complete chains" material this effort depends on. The failure mode is the dangerous one: readable, plausible, logically inverted.
Aggravating factors: (a) ~/Projects/Literature/index.json sets the entry's "path" to the corrupt .md rather than the PDF; (b) it tags the entry provenance_fidelity "verified_conversion", which is false; (c) 11 of its chunks are live in .literature.db chunks_fts, so every --lit briefing serves this text; (d) token_count is 2721 for 16 pages, indicating all displayed equations were dropped as well.
Note the repo-local specs/literature-index.json ALREADY records this hazard (including 89 known-dangling md:NN citations in Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean). The two indices contradict each other and the global one wins for --lit. Reconcile them.
Deliverables: re-convert from the PDF with equation and glyph preservation (verify by asserting the U+2260 count is greater than zero and spot-checking md:199/:201 against PDF p.6); correct the global index entry's provenance_fidelity and path; re-chunk and re-index so FTS5 serves the corrected text; confirm the sub-index hazard block matches reality afterward. If faithful re-conversion proves infeasible, the fallback is to set provenance_fidelity to a non-verified value and repoint path at the PDF -- do NOT leave a false "verified_conversion" in place.

PART 2 -- close the Dedekind-specific coverage gaps.
The single most on-point source is Gabbay-Hodkinson-Reynolds 1994 Vol.1 Ch.10 section 10.3 "Separation over Dedekind Complete Flows". Current corpus state: 10.3.1, 10.3.3 and 10.3.4 are present but carry provenance_fidelity null (unadjudicated); 10.3.2 is ABSENT entirely, a hole in the middle of the chapter -- and the ch10 PDF is already on disk, so this is a conversion gap, not an acquisition gap.
Also: Gabbay & Reynolds 2000 Vol.2 PDF is present but conversion was rejected (zero tokens) and is where much of the axiomatization-over-real-flows material lives; Reynolds 1992 "An Axiomatization for Until and Since over the Reals without the IRR Rule" is converted EXCEPT sections 5 and 9 -- check whether those bear on the countable-carrier obstruction before deciding priority; Hodkinson & Reynolds 2006 Handbook Ch.11 is 2094 tokens for 65 pages (stub); Burgess 1984 section 4 is 982 tokens for 11 pages (stub) and is one of the 12 sub-index pointers.
Register everything ingested in specs/literature-index.json. Do NOT mark anything verified_conversion without an actual spot-check against the source PDF.

---

### 383. Construct the phase 7 negationcase unblock per adjudication verdict
- **Effort**: 14-20 hours
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: Task 382
- **Research**:
  - [379_rearchitect_kampprior_k2_onto_unary_esigma_encoding/reports/02_spawn-analysis.md]
  - [383_construct_the_phase_7_negationcase_unblock_per_adjudication_verdict/reports/02_rabinovich-faithfulness-crosscheck.md]
- **Plan**:
  - [383_construct_the_phase_7_negationcase_unblock_per_adjudication_verdict/plans/01_phase7-negation-split.md]
  - [383_construct_the_phase_7_negationcase_unblock_per_adjudication_verdict/plans/02_phase7-negation-tl-level.md]
- **Summary**: [383_construct_the_phase_7_negationcase_unblock_per_adjudication_verdict/summaries/02_phase7-negation-tl-level-summary.md]

**Description**: FIRST, read the probe report produced by the adjudication task this depends on, in full. Its GO/RECONCILE verdict determines which branch below applies -- do not skip this precondition check. If the verdict is GO: build, in dependency order, sub-decomposed into separate green committed sub-steps: (1) Native Lemma 3.2(1) on ExistsForallFormula -- conjInterleave + conjInterleave_iff (conjunction of two efSat iff disjunction via order-preserving chain interleavings, ~500-650 lines per the prior report unless the adjudication task corrected this estimate); (2) Native Lemma 3.4 ∧-closure -- veeConj + veeConj_iff (distribute ∧ over the two disjunct lists, apply step 1 pointwise, ~120-180 lines); (3) Arbitrary-pin Prop 4.2 negation bridge -- efSat_negation_general then prop42_veeSat_negation_general (De Morgan over the disjunct list, single-object negation by case analysis over order patterns, reassemble via step 2, ~250-400 lines); (4) Re-attempt Phase 7's negation case using the new engine. If the verdict is RECONCILE: build the smaller, concrete construction plan the adjudication task's report specifies instead (e.g. a re-targeted augTarget that always yields endpoint pins, or a direct transcription of Rabinovich's actual Prop 4.2 general-case proof from PDF pp.7-11) -- follow that report's own signatures/line estimates rather than the original report-06 proposal. If the adjudication report indicates neither branch cleanly resolves, do not force either construction; escalate this task to [BLOCKED] citing the specific unresolved question. Every deliverable lives in new file(s) under Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ (name provisional, e.g. ConjInterleave.lean, Prop42NegationGeneral.lean), off the live import path until Phase 7 rewires onto it, mirroring how Prop43.lean/Prop42ExistsForall.lean already sit off-path. lake build must stay EXIT 0 at the existing job count throughout; no new axiom/sorry may appear on completeness_discrete's axiom trace. No sorry, no vacuous placeholder, no Prop43Structural.lean hole. Cite Rabinovich by PDF page only. Durable-anchor headers only (no task-number references in Theories/ files). Once this task lands, resume the parent task at Phase 7 via /implement. Inherit topic kamp-completeness.

---

### 378. Rebase section5 onto faithful dedekind carrier
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: Task 341

**Description**: DEFERRED from task 377 plan v2 Phases 6-8 (re-scoped by binding user directive: "If it's not on the critical path stub it out to leave behind for later when we do the dedicated complete proof system"). Re-base Rabinovich's Section 5 onto the FAITHFUL Dedekind carrier. THIS IS THE "dedicated complete proof system" WORK -- do not dispatch it as a side quest.

GOAL AND VALUE (supersedes the original deferral framing; do not re-litigate the deferral itself -- the reasoning below was correct for the goal in force when this task was written, and is now superseded by a changed project goal, not refuted). The project goal is now a genuine Dedekind-complete FRAME CLASS with its own completeness theorem, with this Rabinovich Section 5 re-base as a FIDELITY PREREQUISITE FEEDING that frame-class completeness work -- i.e. 378 is upstream of, and blocks, the frame-class theorem, not a side branch of it. Under this goal the value calculus inverts: a Dedekind-complete frame class has consumers that CAN observe the difference between HasAttainedINF and HasDedekindINF, because attained INF/SUP is NOT free on a general Dedekind-complete chain the way it is on Prior structures (prior_hasAttainedINF, PriorINF.lean:224, via the UZ axiom). hasDefinableINF_excludes_kplus (Kamp/Lemma53.lean:282, axiom-clean, machine-checked) proves the currently-landed HasDefinableINF carrier DELETES the paper's disjunct (2) -- exactly the content a Dedekind-complete class cannot afford to lose. This re-base is therefore load-bearing for the frame-class theorem, not fidelity-only.

ALREADY LANDED AND GREEN -- BUILD ON THIS, DO NOT REBUILD IT:
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/DedekindINF.lean -- LIVE and CI-protected (import edge from NfMultiAnchorBridge), sorry-free, all decls axiom-clean {propext, Classical.choice, Quot.sound}. Contains: HasDedekindINF/HasDedekindSUP (Rabinovich eq (5.2) stated faithfully as the disjunction of the paper's `Subcase r0 = z0` = K+(P1)(z0) and eq (5.2) verbatim, PDF p.8); the FOUR compatibility shims HasAttainedINF/HasDefinableINF.toHasDedekindINF + SUP duals (HasDefinableINF.toHasDedekindINF discharges the r0<=z1 vs r0<z1 reconciliation from the occurrence hypothesis rather than assuming it); prior_hasDedekindINF/prior_hasDedekindSUP; and the strictness delta hasDedekindINF_admits_kplus_shape + hasDefinableINF_incompatible_with_kplus. The shims are what a re-base needs FIRST -- they let the faithful carrier be consumed wherever the landed ones are supplied, so the re-base need NOT discard EANegationFix/.
- TemporalPred.disj (ExistsForallNF.lean) + TemporalPred.eval_at_disj (VecEAClosure.lean) -- the point-type primitive for eq (5.2)'s (P1(r0) v K+(P1)(r0)). Sorry-free, axiom-clean.
- Section5Correspondence.lean -- page-cited Section 5 correspondence table (PDF pp.7-11) + prop42_contentful_of_attained. Sorry-free, axiom-clean. READ THIS FIRST: Section 5 is ALREADY TRANSCRIBED in EANegationFix/ under names that mention neither Rabinovich nor lemma numbers. It was grep-discoverable for thirteen months and was STILL re-planned from scratch by successive agents, one of which marked six present, sorry-free rows ABSENT.
- lemma53 sorry-free at the attained carrier; hasDefinableINF_excludes_kplus (Lemma53.lean:282, axiom-clean) -- machine-proves HasDefinableINF DELETES the paper's disjunct (2); the whole reason the faithful carrier is needed.
- The EANegationFix/ tree -- live, correct at the attained carrier.

THE DEFERRED WORK (plan v2 Phases 6-8 carry full task breakdowns, verification gates, and a written GO/NO-GO kill criterion -- START THERE: specs/377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md. Phase 6's task list is now LARGELY DONE -- the carrier and shims above have landed since the plan was written; RE-SCOPE DISPATCH TO PHASES 7-8 ONLY):
1. Lemma 5.3 (PDF p.8) -- negChainOnFaithful over HasDedekindINF, restoring the PRINTED THREE-disjunct O_n+1: (1) (Ay)^{<z1}_{>z0}-P1(y); (2) K+(P1)(z0) ^ O_n(P2..Pn,z0,z1) <-- DELETED by the landed attained simplification; (3) (Er0)^{<z1}_{>z0}(INF(z0,r0,z1,P1) ^ O_n(P2..Pn,r0,z1)). The landed negChainOn (EANegationFix/OnBuilder.lean:149) truncates to TWO. Result type MUST be VVecEA2, NOT VBracketFormula: disjunct (2) conjoins the endpoint predicate K+(P1) at z0, which VBracketFormula cannot carry. THIS PHASE IS THE GO/NO-GO GATE AND THE SIZING CANARY for the rest -- if it does not close in ONE dispatch, that is a sizing signal to RE-SPLIT, not grounds for a second dispatch on the same target.
2. Lemma 5.1 (PDF pp.9-10) -- re-base BracketFormula.negFix_iff (EANegationFix/NegFix.lean:669).
3. Prop 4.2 (PDF p.6) -- re-base VVecEA2.negFix_iff (EANegationFix/VecEANegFix.lean:164), hence prop42_contentful_of_attained, off the attained pin. LARGEST AND LEAST CERTAIN: negFixList (NegFix.lean:424) is a 681-line recursion whose Case 2/Case 3 gates are built around the ATTAINED pin; admitting the K+ limit case adds a third gate to each. Phase 8 does NOT dispatch until the Lemma 5.3 gate resolves GO.

BINDING CONSTRAINTS CARRIED FORWARD FROM 377 (unchanged, do not weaken):
- THREE-STRIKES PROHIBITION (standing): the model-INDEPENDENT Prop 4.2 backward direction at the BracketFormula level is ruled UNFIXABLE (task 377 report 18 sec 4.3; Boneyard/NegationIndep.lean:346-364). EANegation.lean:1090 and :1249 ARE that target -- DO NOT TOUCH THEM. BracketFormula.negFix_iff (NegFix.lean:669) is INF-ANCHORED and CONFIRMS the ruling; never cite it as license for a fourth bare attempt.
- AMENDED SORRY GATE (user-approved, committed e74f129d1): the ONLY live sorries permitted are KampPrior.lean:520, EANegation.lean:1090, EANegation.lean:1249. Add ZERO. KampPrior:520 is task 358's P17 frozen-interface gap by its own in-code note (:507-518 says "Do NOT discharge here"). [STALENESS NOTE, preserved for the record, not a license to weaken this gate unilaterally: as of this task's last research pass (2026-07-25), none of these three sites contain a live sorry -- KampPrior.lean's k>=2 residual was retired by task 379 Phase 5 (kampArm_zeta, 2026-07-24) and EANegation.lean:1090/:1249 were retired to Boneyard/EANegationVBracketBackward.lean by task 359 phase 2 (2026-07-24). `lean-sorry-census.sh` on Kamp/ reports zero live sorries. If this task dispatches and finds the same, treat the gate as vacuously satisfied (zero live sorries is trivially "no more than the permitted three"), not as evidence the gate was violated, and flag the state.json wording for a follow-up correction rather than re-deriving the history above.]
- EXTENDED NON-VACUITY RULE: if you land a carrier, STATE WHAT IT EXCLUDES. An over-strong hypothesis passes sorry-free, axiom-clean and EXIT 0 exactly as a vacuous conclusion does -- that pattern recurred THREE times undetected on this task. The strengthening chain: Rabinovich's Dedekind completeness < HasDedekindINF < HasDefinableINF < HasAttainedINF (landed).
- USER'S PRIMARY CONSTRAINT: "It is ESSENTIAL to maintain full faithfulness with Rabinovich to avoid attempting to prove novel mathematics (which is very hard)."
- CITE RABINOVICH BY PDF PAGE ONLY: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf (Read supports PDFs via `pages`). The companion .md is CORRUPT (inverts k!=m at md:199) -- NEVER ground truth. No chunk_00NN-style citations.
- PRESERVE -- DO NOT DELETE FILES. ~29% of NfMultiAnchorBridge is load-bearing via kampArm_*_k0/_k1; frozen byte-identity surfaces sit INSIDE live files (surgical decl excision only, never file deletion). Do NOT delete hasDefinableINF_excludes_kplus, lemma53's Basis, or anything in EANegationFix/.
- LIVENESS: `lake build BoneyardArchive` passes VACUOUSLY (#exit line 5 precedes imports line 7) -- NEVER evidence of health. Kamp/Boneyard/* is covered by NO glob and compiled by NOTHING in CI. ONLY reachability from Theories/Bimodal.lean decides liveness. This is why DedekindINF.lean was landed LIVE rather than parked in Boneyard, and why the deferred targets were recorded as PROSE rather than as sorry-bodied theorems in a dead module.
- SORRY CENSUS MUST BE TACTIC-POSITION, never `grep -c`: use .claude/scripts/lean-sorry-census.sh. [Baseline note superseded: at last check (2026-07-25) the census reports 0 live sorries in Kamp/ (4 dead, all in Boneyard/). Re-run the script at dispatch time rather than trusting either this count or the plan's original "5 across Kamp/" baseline -- both are point-in-time snapshots.] NOTE: the script's --cross-check reports a structural MISMATCH when the target is a subdirectory (the stripper is scoped to the target; the compiler's `lake build` is always whole-project, and names DECLARATION start lines where the stripper names TACTIC positions). Within Kamp/ the compiler's 3 sorry-using decls (KampPrior.lean:346, EANegation.lean:834, EANegation.lean:1129) correspond exactly to the census's 3 live tactic positions. Not a defect.

BASELINE METRICS (HISTORICAL, post-377-phase-6; re-measure at dispatch): full `lake build` EXIT 0 at 1766 jobs / 239 live modules under Theories/. Every new live module adds exactly +1 to each.

DISPATCH GUIDANCE: --hard --lit. Expect to need its own plan; plan v2 Phases 6-8 are a strong starting point but were written before the carrier and shims landed, so their Phase 6 task list is now largely DONE -- re-scope to Phases 7-8 only.

---

### 377. Transcribe rabinovich faithful nf encoding
- **Effort**: large
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: kamp-completeness
- **Dependencies**: None
- **Research**:
  - [377_transcribe_rabinovich_faithful_nf_encoding/reports/01_faithful-nf-encoding-ruling.md]
  - [377_transcribe_rabinovich_faithful_nf_encoding/reports/06_kampprior-520-adjudication.md]
- **Plan**:
  - [377_transcribe_rabinovich_faithful_nf_encoding/plans/02_section5-exists-carrier-rebase.md]
  - [377_transcribe_rabinovich_faithful_nf_encoding/plans/01_contentful-prop42-section5.md]
- **Summary**:
  - [377_transcribe_rabinovich_faithful_nf_encoding/summaries/02_section5-correspondence-guard-summary.md]
  - [377_transcribe_rabinovich_faithful_nf_encoding/summaries/02_section5-exists-carrier-rebase-summary.md]

**Description**: RESCOPED after research (report 01, machine-verified). The original charter's central premise -- "the faithful path stalled at Prop 4.2" -- is FALSE and has been retired. Binding user constraint UNCHANGED and now the primary driver: "It is ESSENTIAL to maintain full faithfulness with Rabinovich to avoid attempting to prove novel mathematics (which is very hard)." Cite Rabinovich BY PDF PAGE only (~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf); the companion .md is CORRUPT (inverts k!=m at md:199).

VERIFIED FACTS (do not re-litigate):
- Prop 4.2 IS PROVED: neg_2var_vec_ea (Boneyard/KampNegationClosure/NegationClosureProp42.lean:159-169) is sorry-free, axiom-clean {propext, Classical.choice, Quot.sound}, NO sorryAx. Builds EXIT 0 after stripping ONLY the 4-line header and the #exit line. RabinovichNegation.lean (279L) also sorry-free.
- Lemma 3.2(2) PHASE 1 GATE: CLEARED. chain_split proved sorry-free AND axiom-free (not even propext) over a bare LinearOrder, no Dedekind completeness needed. Probe: reports/01_lemma32-anchor-split-probe.lean. Reusable as the Lemma 3.2(2) primitive.
- Sections 3-5 are LARGELY ALREADY TRANSCRIBED, live, sorry-free (~1,902 lines): VecEA2 + BracketFormula (VecEAFormula.lean:128,252) are Notation 5.2 (p.8) EXACTLY (pointTypes alpha + segmentTypes beta + PINNED endpoints); VecEATranslation.lean (translateLeft = Prop 3.5 Until, 566L); NfToVecEA.lean (translateRight = Prop 3.5 Since, 567L).
- Archive 302 was REACHABILITY-based ("no live importers"), never correctness-based. 93-module closure: 74 live, 21 boneyard, 0 ABSENT. Drift is PURELY module-path renames. Only 4 REAL sorries across 8 archived files (naive grep says ~40 -- nearly all docstring PROSE; DO NOT BUDGET FROM GREP COUNTS).

THE ONLY REMAINING GAP (entire scope of this task): the nf_eval_nf -> VecEA2 bridge ABOVE DEPTH 0. NfToVecEA.lean is DEPTH-0 ONLY by its own docstring, terminating at nf_2var_exist_depth0_tl (:503). Both paths stall at the same obstruction under two names: archived nf_exist_formula_nested_backward (NegationClosure.lean:1722, blocker comment names "the Feferman-Vaught composition theorem for linear orders" for non-interval zones 1,2,4,5; interval zone 3 already discharges from Since/Until) and live KampPrior.lean:519 ("goal needs arity 3, IH supplies arity 2"). Two independent derivations, one obstruction.

THE ENCODING RULING (mechanism pinned; the ORIGINAL CHARTER STATED THIS INVERTED): Lemma 3.2(2) is a THEOREM of Rabinovich's Def 3.1 (treewidth 1; proved here axiom-free) and a NON-THEOREM of the repo's nf_eval_nf (hyperedge; machine-proved UNPROVABLE in-repo at Base.lean:1779). NATURAL EXPERIMENT ALREADY RUN IN-REPO: NegationClosureProp42.lean is built on VVecEA2, has ZERO nf_eval_nf hits, PROVED Prop 4.2 axiom-clean; NegationClosure.lean is built on nf_eval_nf, has 42 hits, STALLED. The encoding boundary IS the proved/stalled boundary, zero exceptions. The FV gap is SELF-INFLICTED by a type-first architecture -- Rabinovich never needs FV because Prop 4.3 (p.6) inducts over FORMULAS with processed depth folded into the signature as a unary E[Sigma]-atom (Def 4.1 p.5), making composition STRUCTURAL, not a theorem.

PLAN MUST ENCODE (in this order):
1. SEQUENCE KampPrior.lean:522 FIRST -- mechanically retirable by RESTRUCTURING the declaration (unreachable: recursion resets arity to 1 at :407, live entry is n=1; sorryAx is tracked per-declaration not per-path, which is why DoD needs both :519 and :522). No encoding work, no Prop 4.2. Only DoD item obtainable independently; yields an early green commit and splits an all-or-nothing DoD into two milestones.
2. FORMULA-FIRST Prop 4.3 PROBE before ANY FV investment. This is the single most important item AND the research's LEAST CONFIDENT claim (Medium -- a design judgment, not a machine check). Can the FV requirement be DISSOLVED by inducting over formulas? Apply Prop 4.3 to the depth-k 1-type's Hintikka formula (itself an FO formula) and bridge to nf_eval_nf only at ARITY 1. Its Negation case consumes exactly Lemma 3.2(2) (CLEARED, probe landed) and Prop 4.2 (PROVED) -- both in hand for the first time. WARNING: Kamp/Prop43.lean AND Kamp/Boneyard/Prop43.lean BOTH exist and are BOTH UNBUILT -- Prop 4.3 was attempted twice and orphaned twice; FIND OUT WHY before a third attempt.
3. ADOPT VecEA2/BracketFormula (VecEAFormula.lean:128,252) as the Def 3.1 object -- NOT EAtomDom, NOT IntervalPattern. It is Notation 5.2 exactly INCLUDING pinned endpoints. BracketFormula.toIntervalPattern (:135) bridges if needed. Do NOT adopt NfEFold: its EAtomDom (:69) lacks Def 3.1's beta slot, its defense (:100) is REFUTED (zoneHolds constrains x only against ENV points, cannot express "no point in the open interval (x,t)"), and nf_eval_efold_k (:608) is a MIS-NAMED NON-FOLD that grows arity by its own docstring.
4. UN-ARCHIVE, DO NOT REWRITE: restore NegationClosureProp42.lean (+ NegationClosure5.lean) by stripping the 4-line header and #exit -- VERIFIED to build EXIT 0 axiom-clean with no other edit. Restoring NegationClosure.lean additionally pulls the KampBypassArchive cluster (~13,255 lines / 21 files) -- budget for it.
5. TRY chain_split (reports/01_lemma32-anchor-split-probe.lean) AGAINST NON-INTERVAL ZONES (1,2,4,5) before reaching for the FV literature theorem -- it is itself a composition/gluing theorem at a shared anchor over a bare LinearOrder, structurally the same shape as what the archived path wanted, and axiom-free.

DEFINITION OF DONE (unchanged): KampPrior.lean:519 AND :522 both retired (SAME declaration; sorryAx leaves completeness_discrete's closure only if BOTH go -- confirmed by two proof-term traces); full lake build green; no new axioms (exactly {propext, Classical.choice, Quot.sound}); every new declaration carries a page-cited source correspondence.

GOAL CHAIN: completeness_discrete (Metalogic/BXCanonical/Completeness.lean:276) <- nf_nvar_exist_all_depths <- nf_characterizable_temporal_prior <- kamp_prior_expressive_completeness <- US_expressively_complete_over_prior. LIVE chain needs only arity <=2.

PRESERVE / DO NOT DELETE: DO NOT SPAWN CLEANUP. ~29% of NfMultiAnchorBridge (11 files / 13,737 lines) is LOAD-BEARING via kampArm_*_k0/_k1 (AggregateHookDischarge.lean, AggregateOffDiagK1.lean). Frozen byte-identity surfaces (CarrierKv.lean:240-249; rfl bridges InteriorGateGeneralK.lean:339-351, CarrierKv.lean:294-351) sit INSIDE live files -- any reclamation must be surgical decl excision, never file deletion. Kamp/Boneyard/* is green-on-demand and KampNegationClosure holds a VERIFIED Prop 4.2.

LIVENESS RULE FOR THIS TREE: directory location, absence of #exit, and a green scoped build are ALL unreliable liveness signals -- only reachability from Theories/Bimodal.lean decides what CI protects. `lake build BoneyardArchive` passes VACUOUSLY (#exit at line 5 precedes imports at line 7; Lean parses an empty header and halts) -- NEVER cite it as evidence of health. Kamp/Boneyard/* is covered by NO glob and compiled by NOTHING in CI.

KNOWN TRAPS: (1) endInterval_correct (EndIntervalConsumerK.lean:268) is arity-1 charF machinery, NOT arity-4 charFib -- report 06's dead-leaf list mis-buckets it. (2) ExistsForallNF.lean's VEF.closed_conj/closed_ex/closed_disj are ADVERTISED in the docstring and NEVER DEFINED -- its zero-sorry count reflects unstated theorems, not proved ones. (3) 89 in-code citations in SharedWitness.lean dangle. (4) literature-search.sh throws fts5 syntax errors on period-containing queries.

PRIOR ART: reports/01_faithful-nf-encoding-ruling.md (this task, PRIMARY -- includes H3 21-row page-cited lemma table + H4 adversarial verification with contradiction log). specs/376_arity_general_zone_decomposed_char_engine/reports/ 04-08 (07 = source-fidelity adjudication: arity caps at Def 3.1 p.4 / Def 4.1 p.5; "Dedekind completeness is an ANCHOR FACTORY, not a model filter" p.8 eq 5.2; Rabinovich needs NO rigidity). NOTE: report 08 is SUPERSEDED on the Prop 4.2 stall claim and on the encoding-ruling direction.

---

### 362. Main strong completeness finite context all frame classes
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 375, Task 169, Task 170

**Description**: Implement main_strong_completeness: finite-context strong completeness (Γ : Context = List Formula) for all three frame classes, with weak completeness re-exposed as the Γ=[] corollary. For each X ∈ {Base, Dense, Discrete}: prove strong_completeness_X : semantic_consequence_X Γ φ → Nonempty (DerivationTree FrameClass.X Γ φ), by (a) the semantic deduction lemma reducing Γ ⊨_X φ to ⊨_X (Γ.foldr Formula.imp φ), (b) the existing empty-context weak completeness theorem for X (completeness / completeness_dense / completeness_discrete, BXCanonical/Completeness.lean:135/234/276), and (c) iterated application of the syntactic deduction_theorem (Metalogic/Core/DeductionTheorem.lean) to move the finite premises into the context. Then derive weak_completeness_X as strong_completeness_X at Γ=[]. New file Theories/Bimodal/Metalogic/StrongCompleteness.lean (additive); update the Metalogic.lean tracking table. Axioms exactly [propext, Classical.choice, Quot.sound] modulo whatever the underlying weak terminus already carries; sorry-free once the three weak termini (358/169/170) are green. This is the capstone the LaTeX names main_strong_completeness (04-Metalogic.tex:266). Depends on research 361 (architecture + per-class semantic_consequence definitions) and the three weak termini: 358 (discrete), 169 (base), 170 (dense).

---

### 361. Strong completeness architecture and weak terminus gap analysis
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: None

**Description**: Research + scoping for finite-context strong completeness (Context = List Formula) across all three frame classes (Base, Dense, Discrete). Deliverables: (1) Confirm the strong-completeness corollary architecture — per-class semantic_consequence_X (paralleling valid/valid_discrete in Semantics/Validity.lean; the current `⊨`/semantic_consequence quantifies over ALL ordered abelian groups D, so a Discrete/Dense restriction must be defined), the semantic deduction lemma (Γ ⊨ φ ↔ ⊨ Γ.foldr imp φ), and iterated use of the existing syntactic deduction_theorem (Metalogic/Core/DeductionTheorem.lean) to derive Γ ⊢ φ from []⊢(Γ→φ). (2) Authoritative gap analysis of what still gates each WEAK terminus: Discrete = task 358 (KampPrior.lean:361/364) + supply (task 350/309); Base = the open sorries in `completeness` (BXCanonical/Completeness.lean:135 — dense arm countermodel_dense, deprecated countermodel_discrete Transfer.lean:1270 "unfixable Z+Z", dd_countermodel_chronicle_mixed_sorry); Dense = the chronicle dense-path sorries inherited by `completeness_dense` (:234) (ChronicleToCountermodel.lean, MCSMixedCase). For each, determine whether the current live architecture reaches green or needs rerouting, and produce a concrete sub-task decomposition + dependency graph for tasks 169 (base weak) and 170 (dense weak), spawning refinements as needed. (3) Confirm the LaTeX-documented main_strong_completeness (04-Metalogic.tex:266) finite-context shape and that weak completeness is exactly the Γ=[] instance. Reference: 04-Metalogic.tex §Completeness-as-Corollary; report 13 (discrete-completeness roadmap). Analysis/read task — no proof obligations to close here.

---

### 341. Structural refactor sharedwitness carrier layer
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 335, Task 337, Task 340, Task 346
- **Research**:
  - [341_structural_refactor_sharedwitness_carrier_layer/reports/01_sharedwitness-declaration-survey.md]
  - [341_structural_refactor_sharedwitness_carrier_layer/reports/02_post-kamp-revision-realignment.md]
  - [341_structural_refactor_sharedwitness_carrier_layer/reports/03_refactor-strategy-evaluation.md]
  - [341_structural_refactor_sharedwitness_carrier_layer/reports/03_teammate-a-decomposition-findings.md]
  - [341_structural_refactor_sharedwitness_carrier_layer/reports/03_teammate-b-api-surface-findings.md]
  - [341_structural_refactor_sharedwitness_carrier_layer/reports/03_teammate-c-mechanics-forwardcompat-findings.md]
- **Plan**:
  - [341_structural_refactor_sharedwitness_carrier_layer/plans/02_module-split-refresh.md]
  - [341_structural_refactor_sharedwitness_carrier_layer/plans/01_module-split-design.md]

**Description**: Structural refactor of the NfMultiAnchorBridge kvE2_sep carrier layer, now that it has grown to a large, intricate state. MEASURED CURRENT SIZE (2026-07-09, wc -l): SharedWitness.lean is ~9248 lines (NOT ~3540 as previously stated — 2.6x larger); SubBracket2V.lean ~2160; CarrierK1V.lean ~2097; the enclosing directory Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ totals ~18,100 lines across 11 files (Base 1478, CarrierK1V 2097, CarrierKv 482, NavigatedSpine 451, OuterGate 203, PriorInterface 105, RefutationF2 963, SharedWitness 9248, SubBracket 266, SubBracket2 647, SubBracket2V 2160). Any module-split proposal MUST be sized against the true ~9248-line SharedWitness, not the stale 3540 figure. CURRENT CARRIER STRUCTURE (post-task-334, post-task-342 — describe the split against THIS, not the old text): task 334 [COMPLETED] switched the carrier to kvE2_sepArr' (41 occ; decls kvE2_sepArr'_mem_modelOrder at 1888, kvE2_sepArr'_sound at 6918) plus kvE2_sepDisjValidOwner (def at 1733, 12 occ), DELETING kvE2_sepArrL / kvE2_sepArrR / kvE2_sepValid and the entire kvE2_sepSingleton block — all four now have 0 declarations; their surviving mentions are prose/comment only (kvE2_sepArrL 9, kvE2_sepArrR 2, kvE2_sepValid 17, kvE2_sepSingleton 0). Task 342 [COMPLETED] added the interior-restricted owner index kvE2_sepPosI (noncomputable def at line 211; now ~229 occurrences) plus tie-admitting weak orders, and deleted the global hLR hypothesis-carrying construction: hLR now survives ONLY as a local binder inside the certificate theorem kvE2_sepHonest_hLR_absurd (SharedWitness:5710), which proves the former hLR was inconsistent with every honest evaluation — there is no global hLR declaration. Name the split against the REAL current symbols — kvE2_sepArr', kvE2_sepDisjValidOwner, kvE2_sepPosI, kvE2_sepBody (def at 2328, 52 occ), kvE2_sepBody_extract (thm at 6328), kvE2_sepHonest_hLR_absurd — and NEVER against the deleted kvE2_sepArrL/R/Valid/Singleton/hLR. LITERATURE-CITATION HAZARD (record explicitly and respect): SharedWitness.lean carries 89 dangling md:NN citations in comments (md:77 x27, md:168 x24, md:154 x9, md:72 x8, md:61 x6, md:91 x3, md:218 x3, md:170 x3, and singletons md:78/74/66/207/137/100). These point into a Rabinovich markdown that was a hand-written paraphrase, replaced 2026-07-09 by a PDF text-extract that drops every displayed equation and inverts k!=m into k=m; the md:NN line references are therefore meaningless. By a deliberate user decision these are left UNFIXED for now — but this refactor, which will move those comments between modules, MUST NOT silently propagate them as if valid. This is a natural opportunity to re-cite to Rabinovich PDF page numbers if the refactor touches those comments (the codebase already uses this style, e.g. 'Rabinovich §5, p.7' at SharedWitness:6132). RULE: cite Rabinovich by PDF page only, never md:NN. GOALS (original intent preserved): (1) SPLIT the oversized SharedWitness.lean into cohesive modules along natural seams (e.g. slot/carrier types & enumeration; per-slot global-index + kvE2_ordRank kernel and the interior owner index kvE2_sepPosI; honest-order + membership/monotonicity; coincidence-fold/discharge; body/holds_iff/extract assembly via kvE2_sepBody / kvE2_sepBody_extract), preserving the public API and all import sites. (2) IMPROVE the API: consistent naming, clearer signatures, section structure, and comprehensive docstrings/comments explaining the value-faithful per-individual-slot design and its Rabinovich Def 3.1 grounding (cite PDF pages, and reports 05-09), correcting or dropping dangling md:NN comments wherever they are encountered. (3) ARCHIVE genuinely dead/superseded code to Theories/Bimodal/Boneyard/ (residual 339 region-primary machinery; obsolete owner-block tuple remnants after the task-340 v3 per-slot refinement; comment blocks referencing the deleted kvE2_sepArrL/R/Valid/Singleton/hLR constructions), WHILE preserving anything still uncertain or potentially load-bearing in place with clear NOTE:/QUESTION: comments rather than deleting it. (4) Keep the full lake build green and axiom-clean {propext, Classical.choice, Quot.sound} throughout; no sorries introduced; preserve F1-F7 faithfulness invariants and the LITMUS (NavigatedSpine:437, UNVERIFIED exact line). This is a code-health/maintainability pass, NOT a semantic change — behavior and proved theorems must be preserved exactly. SEQUENCING (hard constraint): MUST run AFTER the active carrier chain completes — dependencies 340 (per-slot refinement), 337 (holds builder), 335 (outer gate) — AND must NOT run concurrently with the H7 territory contract that currently assigns SharedWitness.lean to task 333 and OuterGate.lean to task 335; both 333 and 335 must land before this structural refactor is safe, to avoid churning files under active edit. Strongly recommend a survey/plan phase that maps the current declaration graph against the true ~9248-line structure and proposes the module split before moving any code. This is a description correction, not a re-scoping: overall scope and goals are unchanged. SEQUENCING ADDENDUM (2026-07-11, session sess_1783723095_edd5a7): task 346 (successor carrier redefinition, spawned from 335) added as an explicit dependency — it reworks NfMultiAnchorBridge carrier internals, so the code-move GATE must verify BOTH 335 COMPLETED AND 346 COMPLETED (or 346 abandoned by user decision) before moving code. Note for the GATE re-diff: tasks 344/345 grew SharedWitness.lean from 10,037 to ~12,600 lines (TASK 344/345 banner sections — pin-anchored fragment fold + symmetric gate); the five-seam cut lines and the md:NN inventory in plan 01 are stale and must be refreshed at the GATE as the plan already provides.

SIZING CORRECTION 2026-07-24 (metalogic cleanup review): SharedWitness.lean has grown again to 12,800 lines (this charter previously said ~12,600). Re-measure before planning; the growth trend itself strengthens the case for the shared-witness carrier-layer extraction.

---

### 321. Implement corrected k2 carrier and close the correctness gate f4 resolution
- **Effort**: 10-16 hours
- **Status**: [EXPANDED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 320, Task 326, Task 330, Task 331, Task 335, Task 336
- **Research**:
  - [309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md]
  - [320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/06_faithful-separate-bracket-architecture.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/07_v7-consolidated-faithful-route.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/10_supersession-decision.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/02_spawn-analysis.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/03_divergence-audit-joint-channel.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/04_spawn-analysis.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/05_remaining-k2-gate-architecture.md]
- **Plan**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/02_corrected-k2-carrier-fi-chain-v2.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/03_corrected-k2-carrier-gate-v3.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/04_corrected-k2-carrier-gate-v4.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/05_corrected-k2-carrier-gate-v5.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/06_corrected-k2-carrier-gate-v6-redesign.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/07_v7-faithful-separate-bracket.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/01_corrected-k2-carrier-fi-chain.md]
- **Summary**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/01_corrected-k2-carrier-fi-chain-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/06_corrected-k2-carrier-gate-v6-redesign-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/07_phase11-n2-singleton-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/07_phase7-sepbody-carrier-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/08_phase8-joint-extraction-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/09_phase9-o4-verdict-summary.md]

**Description**: REDESIGN (v6, plan 06). Task 330's PDF-verified faithfulness audit (specs/330_.../reports/01_faithfulness-audit-fold-representation.md — the PRIMARY BASIS) determined the entire v1-v5 route rested on a MIS-CITATION: the "constant-arity E[Sigma]-fold (Def 4.1)" does not exist in Rabinovich 2014. Def 4.1 (p.5) is the E[Sigma] ALPHABET EXPANSION (TL-formulas-as-atoms), NOT a fold. The real fold is Prop 3.5 / Cor 5.4: NAVIGATED (nested Until/Since) over FLAT exists-forall blocks with QUANTIFIER-FREE point types (Lemma 5.1, p.7); higher FO depth is discharged by STRUCTURAL INDUCTION (Prop 4.3, p.6), never by nesting a depth-k characteristic. The static arity-1 E-atom (EAtomDom = ZoneSpec n x NormalForm sig k 1, NfEFold:69) is a CATEGORY ERROR at k>=1 — the recurring wall (G6 :1609-1641, F4 :5689-5765, k=2 NO-GO 327 :8760-8825) is ONE obstruction: an arity-1 monadic channel cannot carry an inner witness's joint coupling to multiple anchors (goal needs ZoneSpec 4, channel supplies ZoneSpec 1).\n\nv6 DROPS every phase depending on the refuted infrastructure (nfk_assemble/nfk_dropFresh/nfk_zoneSpec, nf_eval_nf1_cons_factor, efold_of_nfk, the constant-arity fold engine nf_quant_layer_fold_k2_gate). It CONSUMES the landed assets the audit identified: BracketCarrierCorrectV (NfMultiAnchorBridge:1881, the witness-growing carrier), neg_2var_vec_ea (EANegationClosure:722, the LANDED Prop 4.2 negation closure — the hardest piece), and the task-326 interior closers (kvE_subBracket2V_sound_of_outer/_complete). It ADDS the missing ingredient: the Prop 4.3 re-flatten structural-induction wiring. It FOLDS IN the redefined scope of the now-ABANDONED prerequisite tasks (NOT re-spawned): former 328 -> the navigated witness-growing fold (Prop 4.3 re-flatten induction over flat exists-forall blocks); former 329 -> the per-arrangement VVecEA2 non-interior dischargers (soundness + completeness) for the 5 non-interior zones (zPastX/zAtX/zAtW/zAtT/zFutT). v5 Phase 15 (F4 Z adversarial gate + verdict record) is preserved as the downstream consumer (now Phase 8).\n\nBINDING INVARIANT (the ONE thing v6 changes after 5 non-converging versions): reconstruction is NAVIGATED / witness-growing, NEVER a static arity-1 characteristic — inter-anchor coupling rides the EVALUATION POINT / structural position of nested Until/Since (Prop 3.5 / Cor 5.4). LITMUS: no x1 < e_i relative-position literal on any live path. CONSTRAINTS (preserved from v5): purely additive; DO-NOT-EDIT (byte-identical) task-325/326 landed lemmas, kvE2_body/bracketEndChar_kvE2 splice, kvE_subChain2V, BracketCarrierCorrectVPrior, EANegation, F1-F4 records; no provider-side pinning (Amendment F3); anchor cap 2; G5 citations at every chain step; axiom-clean [propext, Classical.choice, Quot.sound]; no sorry on any live path. RE-SCOPE fallback (audit-sanctioned) only if the navigated fold + induction wiring exceeds budget: narrow to the interior + boundary fragment via task 326 + epL/epR/ptW, deferring exterior-navigated completeness. GOAL STATE: v6 GO gate unblocks task 309 Phase 13.4 (general-k one-step correctness) + Phase 14 (hook rewire discharging KampPrior.lean:351's strategic sorry). LITERATURE GROUNDING: /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md (Def 3.1/4.1, Prop 3.5, Prop 4.2, Prop 4.3, Lemma 5.1, Lemma 5.3, Cor 5.4). SCOPE AMENDMENT (2026-07-07, plan v7 Phase 10 decision gate): O4 (carrier-side per-sigma hgate derivation) FAILED its one dedicated dispatch — forward-zone conjunct underdetermined at cross-sigma slot points (inert O4 CRUX RECORD, SharedWitness.lean). Verdict N2: task re-scoped to the single-positive-sub fragment (Appendix N2 promoted into Phases 11-12). The GO/NO-GO deliverable for task 309 Phase 13.4 + KampPrior.lean:351 is now fragment-scoped; the multi-positive case (bit-compatibility filtering of kvE2_sepArrL/R, a carrier re-definition) is deferred to a successor task.

---

### 318. Slot lk results into bimodalreference decidability
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 313, Task 319

**Description**: GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymous TACAS 2027 double-blind submission at ~/Philosophy/Papers/PossibleWorlds/Lk/) is accepted and the embargo (user decision 2 on task 313) lifts. Insert the Lk-specific content into chapters/p3-decidability-frontier.typ at the prepared // SLOT-IN: anchors, without renumbering chapters or sections: the BL-star ladder table (Lk 07-related-work.tex 32-104, tab:bl-star-ladder), the complexity map (L1 = PTL x S5 EXPSPACE-complete; L_k undecidable for k >= 2; alternation-freedom does not restore decidability, Theorem F-B; forall-AF-L_k PSPACE-complete flagship, Theorem F-A), and the hardware case study (constant-time as forall-forall, reset convergence, SVA/Logos-Hardware bridge, Lk 06-case-study.tex). Add the Lk bibliography entry with its final published citation. State openly, in plain prose, which results are established in print and which are new; note that none are Lean-formalized (Lk 08-conclusion.tex names Lean 4 formalization as future work). Include the honest trace-vs-task-semantics bridging caveats (Lk is discrete/future-only trace sets; TM is group-time/two-sided task frames). Sources: teammate A rows 15-18.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 297, Task 343
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**: [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 295, Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 294. Eliminate sorry in modals5 and perpetuity
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: sorry-elimination
- **Dependencies**: Task 291
- **Research**: [294_eliminate_sorry_in_modals5_and_perpetuity/reports/01_sorry-elimination-modals5-perpetuity.md]
- **Plan**: [294_eliminate_sorry_in_modals5_and_perpetuity/plans/01_correct-stale-sorry-documentation.md]
- **Summary**: [294_eliminate_sorry_in_modals5_and_perpetuity/summaries/01_correct-stale-sorry-documentation-summary.md]

**Description**: Correct stale sorry/incompleteness documentation in Theorems/ModalS5.lean and Theorems/Perpetuity/Principles.lean, and record the zero-sorry audit evidence. RE-SCOPED after research: the original premise ("eliminate all sorry instances") was false -- an axiom audit (#print axioms over all declarations, no sorryAx) plus a comment-stripped source scan of the 17-module transitive import closure plus a clean lake build confirmed both files and their entire dependency closure are ALREADY fully sorry-free. All 4 grep hits for "sorry" are comment prose; two of them already assert zero-sorry status. Residual work: (1) fix the stale claim at ModalS5.lean:485 ("Marked as sorry pending Phase 3") which describes a proof that is in fact complete; (2) fix the stale claim at Perpetuity/Principles.lean:103 ("left as sorry for the...") likewise; (3) verify the two accurate status lines at Principles.lean:686 and :889 need no change; (4) audit Theorems.lean roll-up status lines (31/39/40) for the same staleness, noting that file is outside the original declared file_scope. PR 4 zero-sorry criterion is already met for these files. Do NOT attempt proof work -- there are no sorries to eliminate. unusedSimpArgs linter warnings in Perpetuity/Bridge.lean are deliberately left to the linter-compliance task, not fixed here.

---

### 293. Audit and fix mathlib linter compliance
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 291, Task 294
- **Research**: [293_audit_and_fix_mathlib_linter_compliance/reports/01_mathlib-linter-compliance-baseline.md]
- **Plan**: [293_audit_and_fix_mathlib_linter_compliance/plans/01_mechanical-linter-compliance.md]
- **Summary**: [293_audit_and_fix_mathlib_linter_compliance/summaries/01_mechanical-linter-compliance-summary.md]

**Description**: Audit and fix Mathlib linter compliance across all sorry-free modules scheduled for porting to cslib (Syntax, Semantics, ProofSystem, Theorems, FrameConditions, Soundness, MCS/Deduction, Completeness, Decidability, Separation, ConservativeExtension). Run the Mathlib linter (set_option linter.all true or use #check_lint). Fix: (1) Naming convention violations -- Mathlib uses descriptive snake_case names not opaque abbreviations (e.g., bfmcs, drm). (2) Missing docstrings on public declarations. (3) Universe polymorphism issues. (4) Line length violations (100 char limit). (5) Unused variable warnings. This task produces files ready for direct porting to cslib without linter failures.

---

### 292. Add copyright headers to all source files
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 291, Task 293
- **Research**: [292_add_copyright_headers_to_all_source_files/reports/01_apache-copyright-headers-baseline.md]
- **Plan**: [292_add_copyright_headers_to_all_source_files/plans/01_relicense-apache-add-headers.md]
- **Summary**: [292_add_copyright_headers_to_all_source_files/summaries/01_relicense-apache-add-headers-summary.md]

**Description**: Add Apache 2.0 copyright headers to all source files under Theories/Bimodal/ (approximately 160 .lean files). cslib requires headers on all contributed files following the format: "-- Copyright (c) 2024 The Bimodal Logic Contributors. All rights reserved. -- Released under Apache 2.0 license as described in the file LICENSE. -- Authors: [author names]". Use a script to batch-add headers to files that lack them. Verify no duplicates are introduced. Run lake build to confirm no import errors.

---

### 291. Upgrade lean toolchain to v431 and mathlib
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: toolchain
- **Dependencies**: None
- **Research**: [291_upgrade_lean_toolchain_to_v431_and_mathlib/reports/01_lean-toolchain-upgrade-431.md]
- **Plan**: [291_upgrade_lean_toolchain_to_v431_and_mathlib/plans/01_lean-toolchain-upgrade.md]
- **Summary**: [291_upgrade_lean_toolchain_to_v431_and_mathlib/summaries/01_lean-toolchain-upgrade-summary.md]

**Description**: Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to the same pin as cslib. This is a prerequisite for all porting tasks: cslib uses Lean 4.31 and tasks 292-294 cannot proceed until BimodalLogic builds cleanly on 4.31. Steps: (1) Update lean-toolchain to v4.31.0-rc1 (or current cslib pin). (2) Run lake update to fetch compatible Mathlib. (3) Fix any API breakage caused by Lean/Mathlib version bump (expect ~50-200 lines of fixes across formula, tactic, and instance changes). (4) Run lake build to confirm zero errors. (5) Run existing tests to confirm no regressions. This task unlocks tasks 292, 293, 294 and all cslib porting tasks (2-13).

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274, Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 230

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 231
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 199. Grid order tactic
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [199_grid_order_tactic/reports/01_grid-order-tactic.md]
  - [199_grid_order_tactic/reports/02_blocker-analysis.md]
- **Plan**: [199_grid_order_tactic/plans/01_grid-order-tactic.md]
- **Summary**: [199_grid_order_tactic/summaries/01_grid-order-tactic-summary.md]

**Description**: Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Automation/) that automates the same_order_type grid dispatch in ghr93_case_II (Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean). The problem: after same_order_type_grid expands to intro i j; simp only [game_tuple]; split_ifs, it generates ~25 ordering goals per case. Each goal has shape (a_bwd ⟨k, proof_n+1⟩ < x ↔ resp_tau ⟨k, proof_n⟩ < y) ∧ (... = ... ↔ ...). The available ordering lemmas (tau_sel_y, tau_sel_sel, sel_pn_ord, pn_sel_ord, tau_d_sel, hord_cd_en_pn, pivot_chain_order, fwd_x_b, fwd_b_y) are stated with Fin n but the goals use Fin (n+1), causing exact to fail on metavar unification. The tactic must: (1) try each ordering lemma with automatic Fin bridging via convert ... using 3 <;> (congr 1; exact Fin.ext (by omega)), (2) handle the hab_eq rewrite for p_n cases (when not k < n, rewrite a_bwd to extendPoint p_n before applying sel_pn_ord/pn_sel_ord), (3) handle symmetry (y < sel goal uses tau_sel_y.symm), (4) fall back to sorry with trace if no lemma applies. After building the tactic, apply it to replace the two sorry fallbacks in ghr93_case_II: Case A sorry at line ~1631 and Case B sorry at line ~1940. These are the last fallthrough goals in the first | ... | sorry chains inside the same_order_type proof obligation. Verify zero build errors. Iterate on the tactic if the initial version does not close all goals.

---

### 196. Codebase tactic survey
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 161
- **Research**:
  - [196_codebase_tactic_survey/reports/01_team-research.md]
  - [196_codebase_tactic_survey/reports/01_teammate-a-findings.md]
  - [196_codebase_tactic_survey/reports/01_teammate-b-findings.md]
  - [196_codebase_tactic_survey/reports/01_teammate-c-findings.md]
  - [196_codebase_tactic_survey/reports/01_teammate-d-findings.md]

**Description**: Systematic survey of the entire Theories/Bimodal/ codebase to identify all tactic and automation opportunities. Produces a ranked inventory of tactic groups with effort estimates, line savings, and dependency relationships. Output: one new task per tactic group, replacing or refining existing tasks 185-195.

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 189, Task 192, Task 196
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

---

### 192. Master tactic dispatch
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 185, Task 187, Task 190, Task 191, Task 194
- **Research**: [192_master_tactic_dispatch/reports/01_master-dispatch-seed.md]

---

### 186. Unify search systems
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 185, Task 199
- **Research**: [186_unify_search_systems/reports/01_unify-search-seed.md]

---

### 180. Copyright headers universe polymorphism line limits
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 292

---

### 179. Research lean4 tactics infrastructure
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-a-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-b-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-c-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-d-findings.md]

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 175. Naming convention and bridge cleanup
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 402
- **Research**:
  - [175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-a-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-b-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-c-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-d-findings.md]

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: bot_of_and_neg instead of ecq, and_left instead of lce, and_right instead of rce, or_inl instead of ldi, or_inr instead of rdi, absurd instead of raa, False.elim instead of efq, not_not_intro instead of dni, etc. Expand opaque abbreviations (bfmcs, drm, cud, sdc, dd_, tc_, fuc_, buc_). Inline or remove Bridge.lean wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize z1_valid to axiom_z1_valid for consistency. Rename temp_ prefix to temporal_ for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report for the full mapping.

CASING CONSTRAINT (added after the systematic Mathlib naming upgrade was scoped): the target names listed above are SNAKE_CASE, which is correct for `theorem`s but WRONG for `def`s under Mathlib convention -- and this repository has ~860 declarations that are forced to be `def` because `DerivationTree` is Type-valued. Any declaration that remains a `def` must receive a lowerCamelCase semantic name (`botOfAndNeg`, not `bot_of_and_neg`), or this task will reintroduce exactly the `defsWithUnderscore` violations its predecessor eliminated. Do not choose a target name without first establishing whether the declaration is a `def` or a `theorem`; where a `-> Prop` declaration can legitimately become a `theorem`, doing so is strictly better than renaming it, because it leaves the linter's scope entirely.

---

### 170. Complete dense extension completeness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Dense (FrameClass.Dense) WEAK completeness green: make `completeness_dense` (BXCanonical/Completeness.lean:234) genuinely sorry-free by retiring the inherited chronicle dense-path sorries (BXCanonical/Chronicle/ChronicleToCountermodel.lean succ_reaches_dom_N / chronicle_gap_contradiction; MCSMixedCase.lean). Weak terminus feeding the finite-context strong-completeness capstone (task 362). Exact decomposition scoped by research task 361. (Repurposed from the former empty stub "complete_dense_extension_completeness".)

---

### 169. Complete frame extension setup and soundness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Base (FrameClass.Base / general) WEAK completeness green: make the empty-context theorem `completeness` (BXCanonical/Completeness.lean:135, `valid φ → Nonempty (DerivationTree FrameClass.Base [] φ)`) genuinely sorry-free by retiring or rerouting its open sorries — the dense-arm `countermodel_dense` (:159), the deprecated `countermodel_discrete` path (:166 → Transfer.lean:1270, the "unfixable Z+Z" succ_cofinal route; reroute through the clean countermodel_discrete_reynolds_v2 where the base case overlaps), and `dd_countermodel_chronicle_mixed_sorry` (:170). Weak terminus feeding the finite-context strong-completeness capstone (task 362). Exact decomposition scoped by research task 361. (Repurposed from the former empty stub "complete_frame_extension_setup_and_soundness".)

---

### 165. Establish semantic finite model property
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Establish the semantic finite model property for TM bimodal logic. The existing FMP in Decidability/FMP/ is purely proof-theoretic: it shows closure MCS structures are finite and that provability is decidable via MCS enumeration, but it does not construct finite semantic models (task frames with world histories). A standard semantic FMP requires: (1) Starting from a canonical model where phi fails, quotient worlds by agreement on the subformula closure. (2) Prove the filtration lemma for all formula constructors including Until/Since (known to be problematic for naive filtration). (3) Prove the quotient model is a valid task frame. (4) Bound the model size by 2^|cl(phi)|. The result should be stated as: if phi is satisfiable in a task model, then phi is satisfiable in a finite task model of bounded size.

---

### 161. Rename theories bimodal to formalsystem
- **Status**: [EXPANDED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 291

**Description**: Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theories/Bimodal/ directory to FormalSystem/, update all imports in Lean files, update lakefile.lean srcDir from Theories to FormalSystem and roots from Bimodal to FormalSystem, update any references in README.md, Tests/, and other files that point to the old path. Ensure lake build still passes after the rename.

---

### 131. Refactor module organization
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 341

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

---

### 128. Open set operator dense continuous
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add topological open set (interior) operator for dense and continuous temporal frames. On discrete ℤ the interior is trivial (discrete topology), but on dense ℚ and continuous ℝ it captures neighborhood-stable truth: Int(φ) true at t iff φ holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4, and Fernandez-Duque intuitionistic temporal logic. Phase 1: add TopologicalSpace instance to TaskFrame for dense/continuous cases. Phase 2: add interior constructor to Formula with truth clause. Phase 3: axioms (S4-like: Int(φ)→φ, Int(φ)→Int(Int(φ))). Phase 4: interaction with temporal operators and S5 □. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014) — completeness may require non-standard techniques.

---

### 127. Time addition operator
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add time addition operator (+) to the bimodal logic TM. φ + ψ is true at (τ, x) iff ∃ y,z with x = y+z, φ true at (τ,y), ψ true at (τ,z). This internalizes the AddCommGroup structure of D into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), and separation logic (BI). Phase 1: add tadd/tsub constructors to Formula, truth clause in semantics. Phase 2: basic axioms (associativity, commutativity, identity, inverse). Phase 3: soundness proofs. Phase 4: interaction with G/H/U/S/□. Completeness (ternary canonical model) and decidability are open research problems — defer to later phases.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: None

**Description**: Implement a Jonsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. Phased approach: Phase 1 — Complex algebra Cm(F): define powerset STSA for TaskFrames with box/G/H/sigma operators derived from frame relations. Prove Cm(F) satisfies all STSA axioms. Phase 2 — Ultrafilter frame Uf(A): given abstract STSA A, construct frame whose worlds are ultrafilters with canonical relations R_G, R_H, R_Box (seed infrastructure from task 163 recovery of UltrafilterChain.lean). Prove Uf(A) satisfies TaskFrame axioms. Phase 3 — Embedding theorem: prove eta(a) = {U | a in U} is an injective STSA homomorphism A into Cm(Uf(A)). Phase 4 — Since/Until extension: extend STSA typeclass with binary untl/sinc operators and prove representation for the full operator signature. Start with basic {box, G, H} fragment (Phases 1-3) before tackling S/U (Phase 4). Prerequisites: resolve 6 algebraic sorries (temp_k_dist, temp_a, temp_l in TenseS5Algebra/InteriorOperators/LindenbaumQuotient); obtain 3 missing papers (Jonsson-Tarski 1951/52, BRV 2001 Ch.5, Goldblatt 1989). Task 992 research report (01_stsa-algebraic-analysis.md) maps ~80% of needed infrastructure. Architecture: restructure Algebraic/ into Core/ (shared STSA/Boolean/ultrafilter), Completeness/ (renamed existing), Representation/ (new J-T work).

---

### 95. Completeness verification audit
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 375, Task 379, Task 380, Task 387

**Description**: Verification pass on sorry status for completeness_discrete and bx_completeness. Updated scope after task 202 completion and task 155 re-scope: (1) Verify dd_countermodel_chronicle_dense and dd_countermodel_chronicle_mixed_sorry show no sorryAx (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case sorryAx: The BX chronicle path (dd_countermodel_chronicle_discrete -> succ_embed_surjective -> limitDomSubtype_isSuccArchimedean -> succ_cofinal) is being bypassed. The correct fix is the WeakCanonical path: task 155 targets closing the no_gaps_discrete import cycle (GoodStructures.lean:855) by delegating to no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:2133), then rewiring completeness_discrete. Note: succ_cofinal remains the current root sorry on the BX chronicle path (ChronicleToCountermodel.lean), but this path is dead code -- the WeakCanonical route via no_gaps_discrete_model_surgery (already sorry-free) is the production path once the import cycle is resolved by task 155. (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report. Dependencies on tasks 93 and 109 removed (both completed).
