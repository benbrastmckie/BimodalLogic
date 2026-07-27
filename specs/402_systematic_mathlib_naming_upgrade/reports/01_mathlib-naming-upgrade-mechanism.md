# Research Report: Task 402 — Systematic Mathlib Naming Upgrade

**Task**: 402 — systematic_mathlib_naming_upgrade
**Type**: lean4 (hard mode: H2 anti-analysis, H3 reference grounding, H4 adversarial verification)
**Date**: 2026-07-26
**Session**: sess_1785113970_d0639d
**Reference grounding tier**: **code** (measured declaration inventory + resolved reference graph)
**H5 divergence audit**: not activated (focus_prompt empty)

---

## Summary

Every quantitative claim below was re-derived against the current post-restructure tree. The
headline result is that the mechanism question is **settled empirically, not by survey**: an
`.ilean`-driven, *guarded, suffix-anchored* rewriter was built and executed end-to-end on a real
declaration (`Bimodal.Semantics.truth_at`, 515 usages). It rewrote 504 sites across 19 files with
**zero guard rejections**, the build then failed loudly at exactly **8** sites the `.ilean` graph
does not record, those 8 were patched, and `lake build` returned green. The experiment was
reverted; the tree is clean.

That single experiment answers the two questions the task called load-bearing:

1. **Is an `.ilean`-driven rewriter viable?** Yes — and it is the only mechanism that is
   structurally immune to the identifier-prefix hazard. Round-trip validation over **129,611**
   recorded ranges shows **99.77%** extract exactly the expected identifier text.
2. **How do we prove a 24,000-site rewrite is complete?** Position-anchored rewriting converts the
   dangerous failure mode (silent prefix corruption) into the safe one (loud `Unknown identifier`
   build errors). The residual `.ilean` gap is real but *build-visible* — measured at ~1.6% on the
   experiment. Build-green is therefore *nearly* sufficient for code, and the genuine verification
   gap is confined to non-elaborated text (comments, strings, docs), which is enumerable.

Lean's own workspace-wide LSP rename **exists** (`Watchdog.lean:1207`) but is **disqualified by
measurement**: it writes the new name verbatim into every reference range, and **16.01%** of the
target ranges carry a written namespace qualifier (`Atom.mk_base`) that it would destroy.

The task description's own numbers largely held up, with **two corrections** worth acting on:
- The `-> Prop` predicate category (121, re-measured) is **not convertible to `theorem`**. Research
  question 5 rests on a false premise. Only **1** proof-valued `def` remains.
- Mathlib's convention makes those 121 **UpperCamelCase**, not lowerCamelCase. The target-name
  derivation rule needs three casing branches, not two.

---

## Measured Baseline (current tree)

All figures from commands run this session; the `.ilean` corpus was refreshed by a green
`lake build` (1884 jobs) before measurement.

### `defsWithUnderscore` — the actual linter, not `lake build`

`lake exe runLinter Bimodal` (batteries `runLinter`; the package declares no `lintDriver`, so
`lake exe runLinter` alone fails with "missing executable target"). Batteries reads
`scripts/nolints.json` relative to cwd (`.lake/packages/batteries/scripts/runLinter.lean:133`).

| Run | Total linter rows | `defsWithUnderscore` |
|---|---|---|
| With `scripts/nolints.json` (current state) | 247 | **1** |
| With `nolints.json` moved aside | 1107 | **861** |

Both runs reported `6443 declarations (plus 13017 automatically generated ones)` across 14 linters.
`nolints.json` holds exactly **860** entries, all `defsWithUnderscore`. The file was restored and
byte-verified identical after the unmasked run.

**Drift since the suppression list was frozen: exactly one new finding** —
`Bimodal.ProofSystem.temp_linearity_derivation`
(`Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean:74`). The suppression list is already
one entry stale, which is direct evidence for the "checkpoint, not asset" framing.

Other categories, unmasked: `unusedArguments` 124, `simpNF` 78, `docBlame` 39, `tacticDocs` 4,
`structureInType` 1.

### Declaration inventory — the 861, classified from the environment

Classified by loading `import Bimodal` and inspecting `ConstantInfo` + the telescoped result type
(scratchpad `Classify.lean`). All 861 are `defnInfo` — the linter's `test` requires
`.isDefinition && !isAutoDecl` (`Mathlib/Tactic/Linter/Style.lean:557`), so theorems are out of
scope by construction.

| Category | Count | % | Task description said |
|---|---|---|---|
| Ordinary data `def` | 554 | 64.3% | 554 ✅ |
| `DerivationTree`-valued | 185 | 21.5% | 184 ✅ |
| `-> Prop` predicate | 121 | 14.1% | 121 ✅ |
| Proof-valued `def` (a theorem in all but keyword) | **1** | 0.1% | **29 ❌** |

The 184/554/121 split survived both file-moving refactors intact. The "29 proofs" figure did not:
only **one** flagged `def` has a `Prop`-typed statement. The prior conversion pass evidently
consumed that category.

By directory: `Metalogic` 599, `Theorems` 135, `Automation` 73, `Syntax` 31, `Semantics` 17,
`FrameConditions` 5, `ProofSystem` 1. Within `Theorems/`, 135 of 135 are `DerivationTree`-valued —
the architectural-root-cause story in `docs/development/NAMING_CONVENTION_DEVIATION.md` remains
precise for that layer and remains inapplicable elsewhere.

### Reference graph

From 327 project `.ilean` files (v5 schema: `references` keyed by `{"c":{"m":module,"n":name}}`,
positions **0-indexed lines, UTF-16 code-unit columns**):

| Metric | Value |
|---|---|
| Project declarations with a definition site | 6,876 |
| Total resolved usages of project declarations | 123,257 |
| Modules containing ≥1 such usage | 295 of 327 |
| **Resolved usages of the 861 rename targets** | **24,482** |
| Median usages per flagged declaration | 6 |
| Max (`Formula.all_future`) | 1,665 |
| Flagged declarations with **zero** usages | 125 |

Churn concentration confirms the description's warning: `Bimodal.Syntax.Formula` contributes
**5,015 usages from 12 flagged declarations** — sizing this task from the `Theorems/` layer would
understate it by roughly 5x.

### Prefix collision — the central hazard, confirmed

**400 of 848** distinct flagged final components (**47.2%**) are a proper prefix of another project
identifier's final component. The description's 45.6% was right; the hazard is the norm, not an
edge case.

Examples: `A_diag` ⊂ `A_diag_correct`, `F_mono` ⊂ `F_mono_mcs`, `ExistsTask_past` ⊂
`ExistsTask_past_def`. Global substring replacement is disqualified, as the description asserted.

---

## Mechanism: recommendation with evidence

### Recommended — guarded, suffix-anchored, `.ilean`-driven rewriter

For every recorded range of a target declaration, replace **only the trailing final-component
sub-span**, after a guard verifies the extracted text ends with the old final component. Reject and
report anything else.

This single rule handles all three written forms uniformly. Measured shape of the **25,289** ranges
belonging to the 861 targets:

| Written form | Count | % |
|---|---|---|
| bare final component (`mk_base`) | 21,107 | 83.46% |
| **qualified** (`Atom.mk_base`) | 4,049 | **16.01%** |
| dot-notation (`.mk_base`) | 133 | 0.53% |

Suffix-anchoring preserves the qualifier and the leading dot automatically.

### Why the mechanism is trustworthy — round-trip validation at scale

Over **129,611** recorded ranges for project declarations, extracting the source text at each range
and comparing against the declaration name:

| Outcome | Count | % |
|---|---|---|
| Exact suffix match | 129,311 | **99.77%** |
| Mismatch | 253 | 0.20% |
| Partial (abbrev/field) | 47 | 0.04% |

Full mismatch taxonomy (all 253, spanning 194 declarations):

| Bucket | Count | Rewriter behavior |
|---|---|---|
| wildcard `_` (elaborated hole) | 94 | guard rejects — must not be rewritten |
| keyword (`instance`, anonymous/auto decl) | 92 | guard rejects — must not be rewritten |
| `_root_.`-qualified reference | 25 | suffix rule handles correctly |
| `«»`-escaped identifier (`«axiom»`) | 4 | needs explicit handling |
| parenthesized span (`(Axiom.serial_future)`, `(.boxPos)`) | ~11 | suffix rule handles correctly |

The 94 wildcards and 92 keywords are exactly the sites a naive rewriter would corrupt into
syntactically valid nonsense. The text guard catches 100% of them.

### The decisive experiment (run, not hypothesized)

`Bimodal.Semantics.truth_at` → `truthAt`, applied to the working tree:

```
recorded ranges:    516
edits applied:      504 sites across 19 files      (504 changed lines, git-verified)
REJECTED by guard:  0
stale .ilean:       5
```

`lake build` then failed with **exactly 8 errors**, all `Unknown identifier truth_at`, all in
`Theories/Bimodal/Metalogic/SoundnessLemmas/DenseValidity.lean` at lines 562/565/586/589/875/879/
907/911 — every one inside a `have ⟨pat⟩ : … := by` type ascription, a context the `.ilean`
reference collector does not record. Patching those 8 sites returned `lake build` to
**"Build completed successfully (1884 jobs)"**.

**`.ilean` gap rate on this declaration: 8 / 512 = 1.6%.** Extrapolated across 24,482 target usages
that is on the order of ~390 build-caught sites for the whole migration — a bounded, loud,
mechanically-resolvable residue, not a correctness risk.

The experiment was fully reverted via `git-snapshot.sh 402` (patch + stash retained); working tree
verified clean, `nolints.json` verified 860 entries, `lake build` verified green.

### Rejected — Lean's built-in LSP rename

Lean **does** implement workspace-wide rename, in the *watchdog* (not the file worker):
`textDocument/prepareRename` and `textDocument/rename` dispatch at
`Lean/Server/Watchdog.lean:1393-1396` to `handleRename` at line 1207, backed by the same `.ilean`
reference index.

It is disqualified by its edit construction, not its data:

```lean
arr := arr.push { range := ⟨start, stop⟩, newText := p.newName }
```

`newName` is written **verbatim into every reference range**. Applied to `Atom.mk_base` (a range
covering the qualifier), it produces `mkBase` where `Atom.mkBase` was required. That corrupts the
**4,049 qualified sites (16.01%)** and the **133 dot-notation sites**. The `lean-lsp` MCP server
exposes no rename tool at all (`lean_references`, `lean_code_actions`, and
`lean_declaration_file` are the closest), so driving it would additionally require a hand-rolled
JSON-RPC client.

**Conclusion**: reuse Lean's reference *data*; do not reuse its rename *edit rule*.

### Critical design constraint (not exercised by the experiment)

Rewriting one declaration at a time invalidates column positions for every other target on the
same line. **All 861 renames must be computed from a single `.ilean` snapshot and applied in one
pass**, per file, per line, right-to-left. Rebuilding between declarations would also work but
costs ~861 builds. This is a genuine correctness requirement the single-declaration experiment did
not test.

---

## The verification story (matters more than the edit story)

Build-green is necessary but not sufficient. Here is what closes the gap, with each class measured.

Textual whole-word occurrences of the 861 target final components across the 331 built
`Theories/` + `Tests/` files (33,165 hits):

| Class | Count | % | Caught by `lake build`? |
|---|---|---|---|
| Covered by `.ilean` | 25,288 | 76.25% | rewritten directly |
| Comment / docstring | 7,047 | 21.25% | **NO — silent staleness** |
| "Uncovered code position" | 707 | 2.13% | YES (see below) |
| String literal | 123 | 0.37% | **NO — silent staleness** |

After stripping comments and strings rigorously, 671 "uncovered code" hits remain across 41 files —
but these are **dominated by local hypothesis names that merely collide with global names**: the
top identifiers are `h_impl` (62), `h_untl` (41), `h_snce` (26). Those are `have`/`obtain` binders,
not references, and must *not* be rewritten. This is precisely the collision class that makes
textual rewriting unsafe and that position-anchoring sidesteps. The genuine `.ilean` gap within
this bucket is the `have ⟨pat⟩ :` class the experiment exposed — and the build catches it.

### The four verification layers

1. **Guard rejection report** — every range whose text does not end with the old final component is
   rejected and listed. Expected volume ~0.2%; each must be eyeballed. This is the layer that makes
   prefix corruption *structurally impossible*, and it is what the sibling `List.take_succ` /
   `List.take_succ_cons` failure lacked.
2. **`lake build` green** — catches the `.ilean` coverage gap (~1.6%) as `Unknown identifier`.
   Necessary, and now demonstrated to actually fire.
3. **`lake exe runLinter Bimodal` with `nolints.json` deleted** — the only evidence that counts for
   this category. `defsWithUnderscore` emits nothing during `lake build`, and CI runs `lean-action`
   with `lint: false`. Target: **0**, with the file gone rather than filtered.
4. **Residual-text sweep** — an explicit, enumerable list of the non-elaborated occurrences the
   build can never catch (below). This is the layer that would otherwise be forgotten.

### Silent-staleness inventory (build cannot catch these)

| Class | Count | Notes |
|---|---|---|
| Comments / docstrings in built sources | 7,047 | cosmetic but user-facing |
| Single-backtick `` `Name `` in doc text | 812 | markdown inline code |
| String literals in built sources | 682 | across 41 files; concentrated in `Tests/…/TacticsTest.lean` (133), `AxiomsTest.lean` (97), and `Automation/ProofStepExport.lean` (40) — the last writes declaration names into ML training JSONL, so staleness is load-bearing |
| `docs/` | 695 hits / 56 files | |
| `typst/` | 94 hits / 21 files | |
| `latex/` | 3 hits | |
| `scripts/` | 856 hits | 851 of them are `nolints.json`, which gets deleted |
| **`Theories/Bimodal/Boneyard/`** | **8,718 hits** | see scope decision |

### Metaprogramming name references — Part C's "highest risk", re-measured and largely defused

The prior research flagged backtick name references as silently breakable. Measured against the
current tree, the risk is much smaller than feared:

| Form | Count | Recorded in `.ilean`? |
|---|---|---|
| Double-backtick ` ``Name ` (name-resolved at elaboration) | 118 | **114 (97%) — YES, rewritten automatically** |
| …unresolved remainder | 4 | all in `Automation/Tactics/Helpers.lean:305-314` |
| Single-backtick `` `Name `` **in code** (raw `Name` literal) | **2** | NO — silent breakage |
| Single-backtick in comments/docstrings | 812 | NO — cosmetic |

The 2 genuine raw-name literals are in `Theories/Bimodal/Automation/Tactics/Helpers.lean` and
`Tests/BimodalTest/Automation/LemmaDBTest.lean`. Together with the 4 unresolved double-backticks,
that is **6 hand-verifiable sites**, not a systemic hazard. Part C's concern was directionally
right and quantitatively overstated — and note its cited file `Tactics.lean` no longer exists;
it split into `Automation/Tactics/{Commands,Helpers,Deduction,PropDecide}.lean`.

### Two operational traps

- **Stale `.ilean` files survive file moves.** Five exist right now
  (`Bimodal.Metalogic.Metalogic`, `Bimodal.Metalogic.Completeness`,
  `Bimodal.Metalogic.BXCanonical.BXCanonical`, `Bimodal.Metalogic.WeakCanonical.WeakCanonical`,
  `Bimodal.Automation.EFGameTactics`) — leftovers from the module reorganization, with no
  corresponding source file. The rewriter must skip any `.ilean` whose module has no source, and
  the migration should start from `lake clean && lake build`.
- **The linter pretty-prints `@Name` for declarations with implicit arguments.** Parsing its output
  without stripping the leading `@` silently loses 425 of 861 names — this cost a full
  classification pass this session.

---

## Target-name derivation rule

Mathlib's convention is *syntactic*, keyed on the declaration's category, not its mathematical
intent. Resolving semantics + casing + `def`/`theorem` status together, per declaration:

```
IF the declaration is a `theorem` (or a `def` whose TYPE is a Prop)
     -> snake_case.  Not in the linter's scope at all.
        [Only 1 flagged declaration qualifies: convert it to `theorem` and stop.]

ELSE IF the declaration's result type (after telescoping binders) IS `Prop`
        i.e. it DEFINES a proposition or predicate
     -> UpperCamelCase.   (Mathlib: `Function.Injective`, `IsCompact`)

ELSE IF the result type is a `Sort`/`Type`
     -> UpperCamelCase.

ELSE (result type is data, including `DerivationTree`-valued)
     -> lowerCamelCase.

SEPARATELY: apply the Part C semantic substitution to the name's WORDS before casing,
            never after.
```

Applied to the 861:

| Target casing | Count |
|---|---|
| lowerCamelCase (data-valued) | **720** — of which 185 are `DerivationTree`-valued, 535 other data |
| **UpperCamelCase (Prop-valued definition)** | **121** |
| syntax/tactic declaration (special case, below) | 19 |
| convert to `theorem`, keep snake_case | 1 |

### Worked examples

| Current | Category (measured) | Semantic step (Part C) | Target |
|---|---|---|---|
| `Bimodal.Semantics.truth_at` | data def (`-> Prop`? no; `Bool`/data) | none needed | `truthAt` |
| `Bimodal.Syntax.Formula.all_future` | data def, `Formula`-valued | none needed | `allFuture` |
| `Propositional.ecq` | `DerivationTree`-valued **def** | `ecq` → `bot_of_and_neg` | **`botOfAndNeg`** (not `bot_of_and_neg`) |
| `Propositional.lce` | `DerivationTree`-valued def | `lce` → `and_left` | `andLeft` |
| `ProofSystem.temp_linearity_derivation` | `DerivationTree`-valued def | `temp_` → `temporal_` | `temporalLinearityDerivation` |
| a `-> Prop` predicate e.g. `..._holds_at` | Prop-valued **definition** | as applicable | `HoldsAt` (**Upper**CamelCase) |

The `ecq` row is exactly the trap the task description called out, and the measurement confirms
its resolution: `ecq` is a `def`, so the Part C target `bot_of_and_neg` must be re-cased.

### Two categories needing bespoke handling

- **The 121 `-> Prop` predicates.** Research question 5 asked how many are "genuinely convertible
  to `theorem`". **The answer is zero, and the question rests on a false premise.** A `def Foo :
  α → Prop` *defines* a predicate — its type is `α → Prop`, which is a `Type`, not a `Prop`.
  `theorem` requires a `Prop`-typed statement, so the conversion is a type error, not a judgment
  call. These 121 must be renamed, to **UpperCamelCase**. The one declaration that genuinely is a
  proof-valued `def` should be converted; that removes it from the linter's scope entirely and is
  strictly better than renaming, exactly as the description reasoned — it just applies to 1
  declaration, not 121.
- **The 19 `tactic*` syntax declarations.** These have **no `.ilean` definition entry** and are
  auto-generated from `syntax`/`macro` commands, with names derived from the tactic token
  (`Bimodal.Automation.tacticModal_norm` ← the `modal_norm` tactic). Renaming them means renaming
  the *user-facing tactic syntax*, which is an API change, not a naming cleanup. The linter's
  exclusion list (`Mathlib/Tactic/Linter/Style.lean:535-548`) already skips `term`-prefixed and
  `«»`-containing names but **not** `tactic`-prefixed ones. Recommend deciding these deliberately:
  either rename the tactics (API break) or `@[nolint defsWithUnderscore]` them with a written
  rationale. They are 19 of 861 and should not gate the other 842.

---

## Staging: Part A before Part B, both in one tooling pass

**Recommendation: stage them, Part A first, with a green build between.** Not one atomic pass.

The description's ordering argument is correct and the measurements sharpen it: Part A is far
cheaper than assumed, because `Bimodal` is a *root* namespace that is almost never written out.

**Part A surface, measured:**

| Site class | Count | In `.ilean`? |
|---|---|---|
| `import Bimodal…` lines | 1,581 | **NO** |
| `namespace` / `end Bimodal…` lines | 903 | **NO** |
| `open Bimodal…` occurrences | 1,324 | **NO** |
| Term references written as `Bimodal.…` | **554** | YES (0.44% of all ranges) |
| Written as `_root_.Bimodal…` | 25 | YES |
| `lakefile.lean` (`srcDir`, `roots`, 13 `lean_exe` roots) | 1 file | — |
| Non-Lean (`docs/` 56, `typst/` 21, `latex/` 21, `scripts/` 12, `README.md`) | ~111 files | — |

**Critical structural finding: `import`, `namespace`, `end`, and `open` lines carry ZERO `.ilean`
references.** I probed this directly (a module's `open`/`namespace`/`end` lines had 0 of its
recorded ranges landing on them). So Part A cannot be done by the reference-graph rewriter at all —
it needs a separate, line-anchored syntactic pass. That pass is trivial and unambiguous (`^import
Bimodal` → `^import FormalSystem`, etc.), which is precisely why Part A should go **first and
separately**: ~4,400 mechanical Lean-side sites plus a directory move, verifiable by a single build.

Running Part A after Part B would churn the entire 24,482-site rewrite a second time and invalidate
its verification baseline, exactly as the description argues.

**Green-build checkpoints are achievable at:** (1) directory move + `lakefile.lean` + imports;
(2) namespace/open rename; (3) each batch of Part B renames grouped by defining module. Part B can
be sub-staged by module without ever leaving dangling references, because each declaration's full
usage set is rewritten together — a partial rename of a *declaration* is what must never be
committed, not a partial rename of the *project*.

---

## Scope decisions, argued

### `Tests/` — **IN**, mandatory

Not a judgment call: `Tests/` is a `lean_lib` in `lakefile.lean` and is built by `lake build`
(1884 jobs include `BimodalTest`). Leaving it out means a red build. Its `.ilean` files exist and
are already part of the 327-file corpus and the 24,482-usage count. Its **682 string literals**
naming target declarations are the real work item — they are test labels the build will not check.

### `Theories/Bimodal/Boneyard/` — **OUT for the rewriter, but say so explicitly**

Verified inert:
- **0** `.ilean` artifacts under any `Boneyard` path
- **0** imports of any Boneyard module from active code
- The single `Boneyard` mention in `Theories/Bimodal/Bimodal.lean:33` is a prose comment

So the resolved-reference mechanism **structurally cannot** cover it — there is no reference data to
drive from, and a textual pass there would face the same 47.2% prefix hazard with no build to catch
mistakes. Renaming it buys nothing (nothing consumes it) and risks corrupting an archive.

It holds **8,718** stale references after the migration, and 93 files. That is the cost of the
decision and it should be recorded, not discovered later. Recommend: leave Boneyard untouched and
add a one-line note at its README that its identifiers predate the Mathlib naming migration.

---

## Part C — re-verified against the current tree

I read all five reports in `specs/175_naming_convention_and_bridge_cleanup/reports/`. Their
corrections **hold**; I did not re-derive them, I spot-verified them, and note where paths drifted.

| Part C claim | Status now | Evidence |
|---|---|---|
| `Bridge.lean` is substantive, do NOT delete | **HOLDS** | file present at `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` |
| `bx_completeness` does not exist in source | **HOLDS** | `theorem completeness_discrete` at `Metalogic/BXCanonical/Completeness.lean:302`; 1 doc-only mention of `bx_completeness` |
| `drm` Boneyard-only | **HOLDS** | active 0 / Boneyard 50 |
| `tc_` Boneyard-only | **HOLDS** | active 0 / Boneyard 9 |
| `fuc_`, `buc_` zero everywhere | **HOLDS** | 0 / 0 |
| `sdc` negligible | **HOLDS** | 0 active |
| `cud` comments only | **partially drifted** | 20 active tokens — needs a per-site check |
| Only `bfmcs`, `dd_`, `temp_` need active changes | **HOLDS** | `temp_` 248 active, `dd_` 7 active, lowercase `bfmcs` 2 active |
| ~13 propositional abbreviations, 257+ refs | **HOLDS** | `lce` 109, `rce` 86, `dni` 47, `efq` 25, `raa` 16, `ecq` 15, `ldi` 10, `rdi` 9, `rcp` 7, `lem` 4 — 328 active tokens |
| Metaprogramming backtick names are highest risk | **OVERSTATED** | 97% of ` ``Name ` refs are `.ilean`-resolved; only 6 sites need hand-checking |
| `Tactics.lean:540-553` hardcodes axiom names | **PATH DRIFTED** | file split; now `Automation/Tactics/Helpers.lean:567+` |

The one item to fold into the derivation rule: Part C's proposed targets (`ecq → bot_of_and_neg`,
`lce → and_left`, `rce → and_right`, `dni → not_not_intro`, …) are all snake_case, and every one of
those declarations is a `def`. **Re-case every Part C target through the derivation rule before
using it.** This is exactly the "derive each target name once, from all three dimensions" mandate.

---

## Tooling assessment

The archived harnesses are at the corrected paths and are **usable as reference, not as-is**:

- `specs/archive/400_clear_lean_v433_deprecation_warnings/tools/` — `lintlib.py` (207), `fixers.py`
  (606), `gate.py` (152), `runlinter.py` (94), `sites.py`, `sweep.py`, plus baseline JSON
- `specs/archive/399_mathlib_linter_compliance_tier3_metalogic/tools/` — `runlinter.py` (94),
  `lintlib.py` (164), `fixers.py` (557), `flexible.py`, `fullsweep.py`, `one.py`, `sites.py`,
  `sweep.py`

`runlinter.py`'s parser is the reusable asset — its header documents the solved traps (the header
regex opens `/-` not `/--`; `LINTER FAILED` has two row shapes and appears mid-message; raw `lean`
emits `PATH:L:C: severity:` while lake emits `severity: PATH:L:C:`). All still apply. **Its `ROW`
regex does not strip the pretty-printer's leading `@`**, which this task needs — that is a
one-line repair, and the trap that cost the most time this session.

None of the archived tools do resolved-reference rewriting; that harness is new work. The working
prototype from this session (`rename.py`, ~60 lines: `.ilean` load → guard → UTF-16 suffix-anchored
splice, right-to-left) is the seed and has been exercised end-to-end.

**Note**: `-DautoImplicit=false` is required when invoking `lake env lean` directly, or elaboration
is more permissive than `lake build` (the package sets it via `theoryLeanOptions`).

---

## Verification bar for this task

- `lake build` green, no new errors — baseline confirmed green this session (1884 jobs)
- `BimodalTest` green — built as part of the default target
- **Sole live `sorry` unchanged**, located **by content**: the bare `sorry` inside
  `theorem countermodel_discrete` in `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
  (currently line 1242; the file's own docstring at line 1208 confirms it is the repository's sole
  live `sorry` and sole `sorryAx` source). Anchor on the theorem name, never the line number.
- `lake exe batteries/runLinter Bimodal` with `scripts/nolints.json` **deleted** →
  `defsWithUnderscore` = **0**. Note the invocation: plain `lake exe runLinter` fails.

---

## Adversarial Self-Verification

I attempted to refute each central recommendation before writing it. Results:

### Claim Verification Table

| Claim | Source / Counterexample sought | Verification method | Confidence |
|---|---|---|---|
| Unmasked `defsWithUnderscore` = 861 | — | two `lake exe batteries/runLinter Bimodal` runs, masked and unmasked; `nolints.json` restored and diff-verified | **High** |
| Category split 554/185/121/1 | Sought the description's "29 proofs" | environment classification via `import Bimodal` + `ConstantInfo` + `forallTelescopeReducing`; **corrected 29 → 1** | **High** |
| `.ilean` drives a sound rewriter | Sought positions that don't round-trip | 129,611 ranges, 99.77% exact; full mismatch taxonomy enumerated | **High** |
| Guarded rewrite + build converges | Sought a silent-corruption path | **executed** on `truth_at`: 504 edits, 0 rejects, 8 loud build errors, patched, build green, reverted | **High** |
| `.ilean` has a real coverage gap | Tried to prove it was my scanner's bug | proved genuine: `DenseValidity.lean:562` has no recorded range; the build error confirmed it independently | **High** |
| LSP rename is disqualified | Sought client-side compensation | read `handleRename` (`Watchdog.lean:1207`): `newText := p.newName` verbatim; 16.01% of target ranges are qualified | **High** |
| 121 `-> Prop` predicates cannot be theorems | Tried to find any convertible | type-theoretic: `α → Prop : Type`, not `Prop`; measurement found exactly 1 proof-valued def | **High** |
| Prefix collision 47.2% | — | computed over the current identifier set (848 distinct target finals) | **High** |
| Boneyard is inert and out of reach | Sought any live dependency | 0 `.ilean`, 0 imports, sole mention is prose | **High** |
| Backtick hazard is 6 sites | Started from Part C's "highest risk" framing | 97% of ` ``Name ` refs are `.ilean`-resolved; **revised Part C's severity down** | **Medium-High** |
| ~390 build-caught sites across the full migration | — | extrapolated from a **single** declaration's 1.6% gap rate | **Low — flagged** |
| `cud` is comments-only (Part C) | — | 20 active tokens found; **not verified** whether they are comments | **[UNVERIFIED]** |
| Archived harnesses "still run" | — | read and assessed; **not executed** against the current tree | **[UNVERIFIED]** |

### Claims revised after verification

1. **Part C's "highest-risk silent breakage"** — downgraded. 97% of double-backtick name references
   are `.ilean`-resolved and rewrite automatically; only 6 sites need hand-checking. Part C's
   concern was directionally correct but quantitatively overstated, and its cited file no longer
   exists.
2. **"671 uncovered code positions" (my own first pass)** — largely retracted. Dominated by local
   hypothesis binders (`h_impl`, `h_untl`, `h_snce`) that merely collide with global names. My
   initial framing would have overstated the `.ilean` gap by roughly an order of magnitude.
3. **The description's "29 proofs"** — corrected to 1, with method stated.
4. **Research question 5** — reframed. It asked "how many `-> Prop` predicates are convertible to
   `theorem`"; the answer is zero on type-theoretic grounds, and the intended category (proof-valued
   defs) has exactly 1 member left.
5. **Added a constraint the experiment did not test** — the single-`.ilean`-snapshot / one-pass
   requirement. Renaming declarations sequentially against a stale snapshot shifts columns within
   shared lines. Flagged explicitly rather than glossed.

### Contradiction log

**Resolved**: My scanner initially reported `Bimodal.Metalogic.WeakCanonical.NormalForm.atomKind_fintype`
as having zero `.ilean` ranges, suggesting a systemic gap. Resolution by precedence (direct file
inspection over derived tooling): the declaration's namespace is
`Bimodal.Metalogic.WeakCanonical`, not the module path — its definition **is** recorded at
`[99,9,99,25]`. My lookup was wrong, the `.ilean` was right.

**No unresolved contradictions.**

### Repository state after research

Working tree clean apart from the new task directory. `lake build` green. `scripts/nolints.json`
verified at 860 entries. The rename experiment is reverted and recoverable via
`specs/402_systematic_mathlib_naming_upgrade/working-progress-1785114897.patch` and `git stash`.

---

## Recommendations for planning

1. **Start from `lake clean && lake build`** to eliminate the 5 stale `.ilean` files.
2. **Part A first**, as a syntactic line-anchored pass (imports / namespace / end / open /
   lakefile / directory move) plus 579 `.ilean`-driven qualified term references. Green build,
   commit.
3. **Derive all 861 target names in one table** before editing anything: apply Part C's semantic
   substitutions to the words, then the three-branch casing rule. Review the table as a unit — this
   is the "derive once" mandate, and it is a *planning* artifact, not an implementation step.
4. **Part B as one computed pass**: all edits from a single `.ilean` snapshot, applied per file per
   line right-to-left, with a guard-rejection report. Sub-stage the *commits* by defining module,
   never the per-declaration edit sets.
5. **Iterate build-fix** on the ~1.6% `.ilean` gap. Expect `have ⟨pat⟩ :` type ascriptions.
6. **Sweep the silent-staleness inventory explicitly** — 682 string literals (especially
   `ProofStepExport.lean`, which feeds ML training data), 6 backtick sites, 7,047 comments,
   `docs/` + `typst/` + `latex/`.
7. **Delete `scripts/nolints.json`** and prove `defsWithUnderscore = 0` via
   `lake exe batteries/runLinter Bimodal`. Also remove or supersede
   `docs/development/NAMING_CONVENTION_DEVIATION.md`, which names this migration as its successor.
8. **Decide the 19 tactic-syntax declarations separately** — API change or documented nolint.
9. **Do not add `@[deprecated]` aliases.** Confirmed mechanism for the description's warning: an
   alias is itself a snake_case `def`, so it is caught by the same linter and raises the count.
