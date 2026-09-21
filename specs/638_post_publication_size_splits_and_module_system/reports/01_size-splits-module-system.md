# Research Report: Task #638

**Task**: 638 - Post-publication size splits and the Lean module system
**Started**: 2026-09-21T19:15:40Z
**Completed**: 2026-09-21T19:40:00Z
**Effort**: Splits: small (one implementation run, ~6 new/edited Lean files, no proof edits). Module system: large, separate programme (all 504 library files, bottom-up, plus five harness scripts).
**Dependencies**: Task 637 (completed)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Expressiveness/{EFGames,GameTransfer}/`, `ORGANISATION.md`, `docs/development/PUBLICATION_REFACTOR.md`, `docs/development/MODULE_INVARIANTS.md`, `scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`), standalone `lean` elaboration experiments on scratch copies (no tracked file touched), Mathlib source at the pinned tag (`.lake/packages/mathlib`), empirical `module` probes against the v4.33.0-rc1 toolchain. No literature source is referenced by the task.
**Artifacts**: - specs/638_post_publication_size_splits_and_module_system/reports/01_size-splits-module-system.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **`GapDetection.lean` has three genuine dependency seams, all verified by elaboration.** Its 17
  declarations fall into four import-acyclic families: formula definitions + rank bounds (~345
  lines), mu-relativized truth (~415 lines), left Lemma 9 (~2,110 lines), right Lemma 9 (~2,220
  lines). The left and right families share nothing but the namespace and the mu-truth lemmas.
  Only two declarations of the whole file (`extendPoint_lt_iff`, `stavi_truth_mu_at_point`) have
  any live consumer outside it; the other 15 have none.
- **`SplitPoint.lean` has exactly one seam, and it does not reduce the file's size.** The file is
  one structure (`SplitPointProps`, ~110 lines) plus ONE 4,774-line theorem
  (`obtain_split_point_props`). `CaseAnalysis.lean` consumes only the structure;
  `WeakCanonical/Transfer.lean` is the only consumer of the theorem. Extracting the structure is a
  real seam by `ORGANISATION.md`'s own test, but the residual file stays ~4,800 lines because it is
  one argument. There is no declaration family inside a single proof to split along.
- **Every proposed split was compiled in scratch form and is green**: the extracted blocks, the
  residual blocks, and unmodified copies of the two consumers (`CustomGame.lean`,
  `CaseAnalysis.lean`) re-pointed at the narrow module all elaborate with zero errors. No
  declaration is renamed, no namespace changes, no proof text changes.
- **The build-time payoff is modest, the importability payoff is real.** `GapDetection.lean`
  elaborates in 11 s, so taking it off the critical path saves little; `SplitPoint.lean` takes
  ~125 s, and after the extraction it runs in parallel with `CaseAnalysis.lean` (18 s) instead of
  ahead of it. The justification is the dependency-seam rule, not the clock.
- **Module system: do not adopt under this task; record it as its own programme with an ADR.**
  Two facts were confirmed empirically on this toolchain: a `module` cannot import a non-`module`
  (adoption is forced bottom-up from `FormalSystem/Init.lean`, never leaf-first), and a public
  theorem proved by unfolding a non-exposed definition fails (so `@[expose] public section` is the
  practical default, as in 4,942 Mathlib files). Mathlib and every dependency are already
  converted at the pinned tag, so nothing upstream blocks it; the cost is local (504 files, 14
  meta-code files, five harness scripts that parse `import` lines, and C33's generator).
- **Recommended approach**: a flat four-module layout for GapDetection that keeps
  `GapDetection.lean` in place as the definitions module; a one-module extraction for
  `SplitPointProps`; three one-line import edits in consumers; `file_scope` must be widened first.

## Context & Scope

The task asks for two things: (1) split the two files over 4,500 lines "only along import-acyclic
declaration families, keeping namespaces", with acceptance "no fully-qualified name changes;
harness green", and (2) "evaluate adopting the Lean module system as its own programme".

The governing project rule is `ORGANISATION.md` section "Module size": *split a module along a
dependency seam, never to satisfy a line count*; a file is worth dividing "when a consumer needs
the definitions but not the thousand lines of lemmas behind one theorem, or when two halves share
nothing but a namespace"; and the two named files are "a candidate for a split if a dependency
seam is found in it, and for nothing otherwise". The research question is therefore not "where can
the files be cut" but "do seams exist, and where".

Both files exist at their post-move paths (task 637 is completed):

| File | Lines | `longFile` baseline |
|---|---|---|
| `FormalSystem/Metalogic/Expressiveness/EFGames/GapDetection.lean` | 5,094 | 5200 |
| `FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPoint.lean` | 4,906 | 5100 |

Constraints honoured during research: no tracked file was modified; all experiments ran on copies
under the session scratchpad using `lean --root=<scratch>` with `LEAN_PATH` extended (no
`lake build`, no Lake lock). The experiments pass `-DautoImplicit=false` but NOT the package's
linter set, so they establish elaboration, not warning-freeness; the implementation must confirm
warnings with a real guarded `lake build`.

## Findings

### Codebase Patterns

**Both files are structurally trivial to cut.** Each is one `namespace
FormalSystem.Metalogic.Expressiveness` block with one `open FormalSystem.Syntax`. Neither has a
`section`, `variable`, `universe`, `instance`, `attribute`, `notation`, `macro`, `syntax`, or
`@[simp]`. So a declaration moved to another module carries no hidden context, and a consumer
that stops importing a block loses nothing but the names in it.

**The local import chain is linear** (each arrow is the sole intra-directory import):

```
Defs -> TypeFormulas -> GapDetection -> CustomGame -> {Composition, Decomposition}
     -> StaviCompleteness -> ContinuationSets -> DConsistencyTransport -> SplitPoint
     -> CaseAnalysis -> WeakCanonical/Transfer
```

Both big files sit on the critical path of everything downstream, which is why a seam that lets a
consumer skip them is worth having even when the time saved is small.

#### GapDetection.lean: declaration inventory and dependency graph

Line spans include each declaration's docstring. "Uses" is the intra-file dependency set
(comment-masked identifier scan, then confirmed by elaboration). "External" is every live
consumer under `FormalSystem/`, `Tests/`, `BimodalTools/`.

| # | Lines | Decl | Uses | External consumers |
|---|---|---|---|---|
| 0 | 49-87 | `def leftFormulaBase` | - | none |
| 1 | 88-137 | `def leftFormula` | 0 | none |
| 2 | 138-166 | `def rightFormulaBase` | - | none |
| 3 | 167-210 | `def rightFormula` | 2 | none |
| 4 | 213-240 | `private theorem operator_depth_flatten_stavi_le` | - | none (also unused in-file) |
| 5 | 241-271 | `private theorem stavi_depth_left_formula_base` | 0 | - |
| 6 | 272-313 | `theorem stavi_depth_left_formula` | 1, 5 | none |
| 7 | 314-360 | `theorem stavi_depth_right_formula` | 2, 3 | none |
| 8 | 368-377 | `theorem extendPoint_lt_iff` | - | `CustomGame.lean`, `ContinuationSets.lean` |
| 9 | 378-423 | `theorem temporal_truth_mu_at_point` | 8 | none |
| 10 | 424-772 | `theorem stavi_truth_mu_at_point` | 8, 9 | `CustomGame.lean`, `ContinuationSets.lean` |
| 11 | 781-840 | `theorem gap_detection_unique` | - | none |
| 12 | 841-1123 | `theorem stavi_untl_gap_detection` | 10 | none |
| 13 | 1124-2878 | `theorem left_formula_gap_detection` (1,762 lines) | 0, 1, 8-12 | none |
| 14 | 2886-3147 | `theorem stavi_snce_gap_detection` | 10 | none |
| 15 | 3148-3178 | `theorem gap_detection_unique_right` | - | none |
| 16 | 3179-5093 | `theorem right_formula_gap_detection` (1,917 lines) | 2, 3, 8-10, 14, 15 | none |

There are no forward references, so the file order is already a topological order. The families:

- **F-defs** = {0-7}: Definition 8.5 formulas and their rank bounds. Uses nothing else in the file.
- **F-mu** = {8, 9, 10}: mu-relativized truth at actual points. Uses nothing else in the file.
  This is the ONLY part of the file any other module consumes.
- **F-left** = {11, 12, 13}: left Lemma 9. Uses F-defs (0, 1) and F-mu.
- **F-right** = {14, 15, 16}: right Lemma 9. Uses F-defs (2, 3) and F-mu.

F-left and F-right are mutually independent ("two halves share nothing but a namespace"), and
F-mu is the "definitions a consumer needs without the thousand lines behind one theorem" case -
both of `ORGANISATION.md`'s criteria are met.

`extendPoint_lt_iff'` in `TypeFormulas.lean` is a distinct `private` declaration (primed name);
it is not a consumer and is unaffected.

#### SplitPoint.lean: declaration inventory

| Lines | Decl | External consumers |
|---|---|---|
| 21-128 | section docstring + `structure SplitPointProps` | `CaseAnalysis.lean` (4 binder sites) |
| 130-4905 | `set_option maxHeartbeats 800000 in` + reason comment + `theorem obtain_split_point_props` (4,774 lines) | `WeakCanonical/Transfer.lean:691` only (`CustomGame.lean` mentions it in prose only) |

`CaseAnalysis.lean` imports `SplitPoint` but uses only the structure. `Transfer.lean` reaches the
theorem transitively through `CaseAnalysis`.

The theorem's proof has 133 top-level tactic steps. Three are ~1,000-line `have` blocks
(`h_r2_resp_le_d` at L1295, 1,027 lines; `h_interior_left` at L2754, 1,122 lines;
`h_interior_right` at L3877, 1,024 lines), and four more are 240-325 lines. Turning any of them
into a standalone lemma means restating a local context that, by that point, holds dozens of
hypotheses (`d`, `c_inf`, `S_C`, `S_C_M`, `r2_resp`, and their property bundles), under a raised
heartbeat budget. That is a proof refactor, not a split along declaration families; it would add
new public or private names; and `ORGANISATION.md` rules it out in terms ("a file that is long
because one argument is long is not improved by being cut"). It is out of scope for this task.

### Elaboration experiments (all green)

Scratch modules were assembled from exact line ranges of the live files, with the same import the
source file has today, so each consumer's environment is the old environment minus the names it
provably does not use.

| Scratch module | Content | Result | Wall time |
|---|---|---|---|
| `MuTruth` | GapDetection L361-772, imports `TypeFormulas` | rc=0, 0 errors | 2 s |
| `GapDefs` | GapDetection L21-360, imports `TypeFormulas` | rc=0 | <2 s |
| `GapLeftF` | GapDetection L773-2878, imports `GapDefs` + `MuTruth` | rc=0, 0 errors | 5 s |
| `GapRightF` | GapDetection L2879-5093, imports `GapDefs` + `MuTruth` | rc=0, 0 errors | 5 s |
| `GapLeft` / `GapRight` (variant: each half carries only ITS OWN defs) | proves left needs no right def and vice versa | rc=0 both | 6 s / 5 s |
| `CustomGameCopy` | unmodified `CustomGame.lean`, import re-pointed at `MuTruth` only | rc=0, 0 errors | 6 s |
| `SplitPointProps` | SplitPoint L21-129, imports `DConsistencyTransport` | rc=0 | 1 s |
| `SplitPointThm` | SplitPoint L130-4905, imports `SplitPointProps` | rc=0, 0 errors | 125 s |
| `CaseAnalysisCopy` | unmodified `CaseAnalysis.lean`, import re-pointed at `SplitPointProps` only | rc=0, 0 errors | 14 s |
| baselines | `GapDetection` 11 s, `CustomGame` 7 s, `CaseAnalysis` 18 s, `SplitPoint` ~125 s | - | - |

Timings are single runs on a 24-core idle machine with several jobs in parallel; treat them as
order-of-magnitude.

### Harness impact (what a split touches, check by check)

| Check | Effect | Action |
|---|---|---|
| C33 (root is byte-for-byte `mk_all` output) | New modules must appear in `FormalSystem.lean` | Regenerate with `lake exe mk_all --lib FormalSystem`; never hand-edit |
| C4 (imports resolve) | New import lines | Covered by the edits below |
| C8 (aggregators) | Walks only `FormalSystem/`, `Metalogic/`, `Syntax/`, `Semantics/`, `BimodalTools/` children; `EFGames/` and `GameTransfer/` are grandchildren | None, PROVIDED no new subdirectory is created |
| `readme-lint.sh` Check 1 (gated) | Every Lean-bearing directory needs a `README.md` | None with the flat layout; a `GapDetection/` subdirectory would need its own README - a reason to stay flat |
| C11 (Boneyard imports resolve) | `Boneyard/StaviDiscretePath/NFGameBridge.lean` imports `EFGames.GapDetection`; `Boneyard/SorriedDeclExcisions/Ghr93ForwardToBackwardChain.lean` imports `GameTransfer.SplitPoint` | None if both module names survive (they do in the recommended layout) |
| C20 (`file.lean:NNN` citations) | No live citation targets either file (the only hits are under `specs/reviews/`, out of scope) | None |
| C28 (warning budget, keyed by path) | Neither file has a budget row | None; confirm new files emit zero warnings |
| C30 / longFile baseline | `GapDetectionLeft` (~2,130) and `GapDetectionRight` (~2,240) and residual `SplitPoint` (~4,810) exceed 1,500 | Each carries `set_option linter.style.longFile N` directly after its module docstring. Observed convention: N = (floor(lines/100) + 2) * 100 (5,094 -> 5200; 4,906 -> 5100). Let the linter's own message give the tight value. The residual `GapDetection.lean` (~370) and the two small new modules drop the option entirely |
| C30 (scoped heartbeats) | `set_option maxHeartbeats 800000 in` must travel WITH `obtain_split_point_props`, together with the `--` reason comment above the docstring (C29-style) | Keep L130-133 contiguous with the theorem |
| C24 (every module reaches `FormalSystem.Init`) | New modules import an existing module that already does | None |
| C2 / C14 (`#print axioms` baselines) | Declarations keep their names and proofs; axiom sets cannot change | None; re-run as the acceptance evidence |
| C5 / C12 / C13 | New module names and paths written into READMEs and `ORGANISATION.md` must resolve | Write real paths only |
| Copyright header / `linter.style.header` | Each new file needs the 5-line header, then imports, then a `/-! # Title` module docstring | Copy from the source file |
| Layer table (`check-metalogic-cycles.sh`, `LAYERS`) | Rows are per language directory; `Expressiveness/` files are not rows | None |

**Private-name caveat.** A `private` declaration's internal name embeds its module name. Decls 4
and 5 are private. In the recommended layout they stay in `GapDetection.lean`, so even their
mangled names are unchanged. (Decl 4, `operator_depth_flatten_stavi_le`, is unused everywhere; it
is left alone - deleting it is not this task.)

### External Resources

Module-system facts, established on the project's own toolchain (Lean v4.33.0-rc1) rather than
recalled:

- **Upstream is already converted.** At the pinned tag, 8,199 of 8,268 Mathlib files start with
  `module`; Batteries 185/254, Aesop 135/250, ProofWidgets 42/46, importGraph 26/37. 4,942 Mathlib
  files open with `@[expose] public section`, 2,701 with a plain `public section`; 536 lines use
  `meta import` / `public meta import` / `import all`. No experimental flag was needed to compile
  a `module` file.
- **Probe 1 - direction of adoption.** A scratch `module` file with `public import
  FormalSystem.Init` fails at line 1: `cannot import non-`module` FormalSystem.Init from `module``.
  The converse works: a plain file importing a `module` elaborates normally. Consequence:
  conversion must proceed bottom-up along the import DAG (`FormalSystem/Init.lean` and
  `ForMathlib/` first, `Tests/` and `BimodalTools/` last or never). A leaf-first or
  one-directory-at-a-time pilot in the middle of the DAG is impossible.
- **Probe 2 - exposure.** In a `module`, `public def f n := n + 1` followed by `public theorem
  f_eq : f n = n + 1 := rfl` fails: "Not a definitional equality ... all definitions that need to
  be unfolded to prove this theorem must be exposed". Under `@[expose] public section` it
  compiles. The library has ~1,500 lines using `:= rfl`, `by rfl`, `by decide` or `native_decide`,
  so blanket `@[expose] public section` is the only mechanical route; selective exposure is a
  per-file judgement and a later refinement.
- **Probe 3 - artifacts.** A compiled module emits `.olean`, `.olean.private`, `.olean.server`,
  `.ir`, `.ir.sig`. `private` declarations stay invisible to importers, as today.
- **`mk_all` supports it**: `scripts/mk_all.lean` has a `--module` flag and otherwise infers the
  style from the existing aggregator; a module-style root begins `module  -- shake: keep-all
  --deprecated_module: ignore` and uses `public import`. C33's python re-implementation of the
  generator would have to learn that shape.

Local cost inventory for adoption: 504 files under `FormalSystem/`, 65 under `Tests/`, 27 under
`BimodalTools/`; 768 `private` declarations (unchanged in meaning, but anything a test reaches
into would need `import all`); 14 files with `elab`/`macro`/`syntax`/`initialize`/
`register_simp_attr` (these need `meta import` / `public meta import` discipline for anything used
at compile time); and five scripts that parse `import` lines textually
(`check-module-invariants.sh`, `check-metalogic-cycles.sh`, `typst-status-counts.sh`,
`test-move-modules.py`, `lib/import_graph.py`) plus `move-modules.py`, every one of which must
accept `public import`, `meta import`, `public meta import` and `import all`.

### Recommendations

**R1 - GapDetection: flat four-module layout (sorry-free path exists; no proof text changes).**

| Module (under `EFGames/`) | Content | Source lines | Imports |
|---|---|---|---|
| `GapDetection.lean` (retained) | F-defs: Definition 8.5 formulas + rank bounds, incl. both private helpers | 21-360 | `EFGames.TypeFormulas` |
| `MuRelativizedTruth.lean` (new) | F-mu: `extendPoint_lt_iff`, `temporal_truth_mu_at_point`, `stavi_truth_mu_at_point` | 361-772 | `EFGames.TypeFormulas` |
| `GapDetectionLeft.lean` (new) | F-left: `gap_detection_unique`, `stavi_untl_gap_detection`, `left_formula_gap_detection` | 773-2878 | `EFGames.GapDetection`, `EFGames.MuRelativizedTruth` |
| `GapDetectionRight.lean` (new) | F-right: `stavi_snce_gap_detection`, `gap_detection_unique_right`, `right_formula_gap_detection` | 2879-5093 | `EFGames.GapDetection`, `EFGames.MuRelativizedTruth` |

Why this shape: it is exactly the four families; it creates no subdirectory (no new README, no
aggregator question); `EFGames.GapDetection` survives as a module name (Boneyard import and prose
references stay valid); the private helpers do not move. File names are a recommendation - the
planner may rename, but must keep `GapDetection.lean` in existence.

Consumer edit: `EFGames/CustomGame.lean` line 7 changes from `import ...EFGames.GapDetection` to
`import ...EFGames.MuRelativizedTruth`. Verified sufficient. `ContinuationSets.lean` needs no edit
(it reaches F-mu transitively through `StaviCompleteness -> ... -> CustomGame`).

**R2 - SplitPoint: extract the structure, leave the proof whole.**

| Module (under `GameTransfer/`) | Content | Source lines | Imports |
|---|---|---|---|
| `SplitPointProps.lean` (new) | "Inductive Step Infrastructure" section docstring + `structure SplitPointProps` | 21-128 | `GameTransfer.DConsistencyTransport` |
| `SplitPoint.lean` (retained) | `obtain_split_point_props` with its `set_option ... in` and reason comment | 130-4905 | `GameTransfer.SplitPointProps` |

Consumer edits: `GameTransfer/CaseAnalysis.lean` line 7 re-points at `SplitPointProps`;
`WeakCanonical/Transfer.lean` gains `import ...GameTransfer.SplitPoint` (it uses the theorem at
L691 and currently gets it only through `CaseAnalysis`). Without the second edit the build breaks.

R2 is recommended but is the weaker of the two: it satisfies the seam rule and unblocks
`CaseAnalysis` from a 2-minute proof, yet leaves a ~4,810-line file. If the planner prefers to
leave `SplitPoint.lean` untouched, that is defensible under `ORGANISATION.md`; what is NOT
defensible is cutting the proof itself.

**R3 - Aggregator closure.** `FormalSystem/Metalogic/Expressiveness.lean` imports
`EFGames.StaviCompleteness` and `GameTransfer.CaseAnalysis`. After R1/R2, `GapDetectionLeft`,
`GapDetectionRight` and (via the aggregator) `SplitPoint` fall out of its closure - they remain in
the build through the generated root and, for `SplitPoint`, through `Transfer`. To keep
`import FormalSystem.Metalogic.Expressiveness` meaning "the whole development", add three import
lines there. This is a choice, not a build requirement; recommend adding them.

**R4 - Documentation in the same change.** `EFGames/README.md` (new rows; its table is already
stale - it lists the archived `NFGameBridge.lean`, and `StaviCompleteness.lean` at 3,252 lines
against an actual 1,665), `GameTransfer/README.md` (new row, new line counts, "Key Results"
attribution), `ORGANISATION.md` "Module size" (GapDetection leaves the over-4,500 list; SplitPoint
stays, with the reason: one proof, its one seam taken), and the `Last verified` dates. Also fix
the stale sentence in `left_formula_gap_detection`'s docstring ("This is sorry'd pending the full
game-theoretic proof in Phase 4C") - the file contains no `sorry`. C14 compares documented sorry
COUNTS and does not catch this prose form, which is why it has survived a green gate.

**R5 - Widen `file_scope` before implementing.** The recorded scope lacks
`EFGames/CustomGame.lean`, `GameTransfer/CaseAnalysis.lean`, `WeakCanonical/Transfer.lean`,
`FormalSystem/Metalogic/Expressiveness.lean`, and the four new files. `git-snapshot.sh` refuses on
out-of-scope tracked modifications, and this task is first in a serialized batch keyed on scope.

**R6 - Module system: evaluate = "not now, own programme, ADR first".** Reasons to defer: adoption
cannot be piloted locally (Probe 1), so it is all-or-nothing across 504 files; it changes no
citable name (already recorded as row 3a of `PUBLICATION_REFACTOR.md`), so publication gains
nothing; and the harness's textual import parsers must change first or every gate reads an empty
graph and passes on a zero denominator (the failure mode C11's history already records). Reasons
it is eventually worth doing: upstream has fully converted, so plain-import consumers of a module
ecosystem are the legacy path; non-exposed bodies would cut rebuild fan-out for a library whose
critical path includes a 125 s proof. Suggested programme order, for whoever picks it up: (1) ADR;
(2) teach `scripts/lib/import_graph.py` and the four other parsers the new import forms, with
fixtures, while the tree is still plain; (3) convert bottom-up with blanket `@[expose] public
section`, meta-code files first among equals; (4) regenerate the root with `mk_all --module` and
update C33; (5) only then consider narrowing exposure. This task should deliver the evaluation as
prose (this section, plus at most a pointer in `PUBLICATION_REFACTOR.md`), not code.

**Verification sequence for the implementation**: guarded, detached `lake build` (C1); `lake exe
mk_all --lib FormalSystem --check`; `bash scripts/check-module-invariants.sh` (full, so C2, C6,
C24 run); `bash scripts/readme-lint.sh`; and a before/after diff of the declaration names in the
`FormalSystem.Metalogic.Expressiveness` namespace for the 19 affected declarations as the direct
evidence for "no fully-qualified name changes".

## Decisions

- Treated `ORGANISATION.md`'s dependency-seam rule as binding: a seam was looked for and found, not
  assumed; line count alone justified nothing.
- Chose the flat layout over a `GapDetection/` subdirectory because the subdirectory triggers
  `readme-lint` Check 1 and adds an aggregator for no gain.
- Kept F-defs in `GapDetection.lean` so the module name, the Boneyard import, and the two private
  mangled names all survive unchanged.
- Declared decomposition of `obtain_split_point_props` (and of the two Lemma 9 proofs) out of
  scope: it is proof refactoring, not a declaration-family split.
- No `user_decision` raised: the task text already frames the module system as an evaluation, and
  R2's optionality is a planner-level call the artifacts can settle.
- No new axioms, no `sorry`, no proof edits are involved anywhere in the recommended path.

## Risks & Mitigations

- **Docstring/section headers cut mid-block.** The line ranges above start and end on block
  boundaries in the current file (L361, L773, L2879 are `/-!` openers; L211 is a one-line header
  that belongs with F-defs). Any edit to the files before implementation shifts them - re-derive
  ranges from the declaration names, not the numbers.
- **Lint warnings not measured.** The scratch runs did not carry `weak.linter.mathlibStandardSet`.
  New files may trip `linter.style.header` or the longFile tightness check. Mitigation: build
  under the real package options and fix before committing; C28 is a ceiling and these paths have
  no budget rows.
- **Forgetting `Transfer.lean`.** It is outside the two directories and outside the recorded
  scope; omitting its new import is the one way R2 breaks the build.
- **Hand-editing `FormalSystem.lean`.** C33 compares bytes; always regenerate.
- **Long rebuild.** Touching `GapDetection.lean` invalidates everything downstream of `CustomGame`
  including the 125 s `SplitPoint` proof and `Transfer`'s dependents. Use the detached, guarded
  build per `long-builds.md`; do both splits in one change to pay the rebuild once.
- **Module-system scope creep.** Any `module` keyword landing in this task would immediately fail
  (Probe 1) unless the whole chain below it were converted. Keep the evaluation to prose.

## Tactic Survey Results

- Not applicable (no tactic survey performed). The task moves declarations verbatim; no proof goal
  is opened or changed.

## Context Extension Recommendations

- **Topic**: Lean module system adoption constraints on this toolchain.
- **Gap**: No context file records that `module` files cannot import non-`module` files, that
  public `rfl`-style theorems require `@[expose]`, or which harness scripts parse imports
  textually.
- **Recommendation**: If the programme is opened, seed its ADR and a
  `context/project/lean4/` note from the "External Resources" section above.

- **Topic**: Standalone elaboration of a candidate split without touching the tree.
- **Gap**: The technique (`lean --root=<scratch> -o X.olean`, `LEAN_PATH` extended with the
  scratch root, consumer copied with one import line rewritten) is not documented.
- **Recommendation**: A short pattern note beside `long-builds.md`; it avoids the Lake lock and a
  full rebuild when the question is only "does this seam hold".

## Appendix

- **Declaration scan**: comment-masking python scanner (declaration keyword regex, docstring-aware
  spans, identifier-set intersection for intra-file edges); external consumers via `grep -rlw` per
  name over `FormalSystem/`, `Tests/`, `BimodalTools/`, then line-level confirmation.
- **Side-effect scan**: `grep -n '^@\[|^instance|^attribute|^notation|^local|^scoped|^macro|^syntax|set_option'`
  on both files - only the two longFile baselines and the one scoped heartbeat option.
- **Experiment command shape**: `LEAN_PATH="$(lake env printenv LEAN_PATH):$SCRATCH" lean
  -DautoImplicit=false --root=$SCRATCH [-o M.olean] M.lean`.
- **Module probes**: three scratch files (`module` + `public import FormalSystem.Init`; `module`
  with and without `@[expose] public section`; a plain importer).
- **Mathlib adoption counts**: `grep -rlx 'module'` over `.lake/packages/*`.
- **Documents read**: `ORGANISATION.md` (Module size), `docs/development/PUBLICATION_REFACTOR.md`
  (row 3a, Phase 9, brief I), `docs/development/MODULE_INVARIANTS.md` (check table),
  `scripts/check-module-invariants.sh` (C8), `scripts/readme-lint.sh` (gated checks),
  `.lake/packages/mathlib/scripts/mk_all.lean` (`--module`), both directory READMEs,
  `specs/reviews/review-2026-07-24-metalogic-cleanup.md` (longest-proof table).
- **MCP search tools**: not used - the task involves no Mathlib lemma discovery.
