# Implementation Plan: Module Organization Refactor

- **Task**: 131 - refactor_module_organization
- **Status**: [IMPLEMENTING]
- **Effort**: 18.5 hours
- **Dependencies**: None (blocks the later systematic Mathlib naming task)
- **Research Inputs**: specs/131_refactor_module_organization/reports/01_module-reorganization-research.md
- **Artifacts**: plans/01_module-reorganization.md (this file)
- **Standards**: .claude/context/formats/plan-format.md; .claude/rules/plan-format-enforcement.md; .claude/rules/artifact-formats.md; .claude/rules/status-markers.md; .claude/rules/no-task-references-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task reorganizes `Theories/Bimodal/` for navigability without renaming a single declaration.
Research re-measured the tree and materially changed the shape of the work: module docstrings are
already ~99% present (287 of 288 live files), so goal (2) is a *documentation-accuracy* problem,
not a coverage problem; and directory-level import cycles (`BXCanonical` <-> `WeakCanonical`,
`Core` <-> `Bundle`) make a physical regroup of the completeness subtrees structurally impossible,
so goal (1)'s deliverable is a correct architecture map plus standardized aggregator boundaries.
Definition of done: the tree carries one consistent aggregator convention, no dead or misplaced
live modules, an architecture map that matches measured reality, `docs/`/`latex/`/`typst/` relocated
out of the Lean source root with every reference updated, and every phase boundary verified green by
a scripted invariant check.

### Research Integration

Findings driving the phase structure:

- **Two Boneyards exist** (`Theories/Bimodal/Boneyard`, 92 files; and
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard`, 62 files). Every count, `find`, `grep`,
  and script in this plan MUST exclude both via `-not -path '*/Boneyard/*'`. A filter naming only
  the top-level Boneyard silently sweeps 27k archived lines into "live".
- **Goal (2) is ~99% done.** Only `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` lacks a
  `/-!` module doc. The real defect is stale maps: `Metalogic/README.md` documents eight files that
  do not exist and omits `Kamp/` entirely (99 live files / 71,246 lines — the largest thing in the
  repository).
- **Goal (1) cannot be a physical regroup.** Measured mutual edges: `WeakCanonical -> BXCanonical`
  (4) and `BXCanonical -> WeakCanonical` (2); `Bundle -> Core` (18) and `Core -> Bundle` (1). Any
  nesting produces a directory whose contents import upward out of it. The deliverable is a
  documented relationship plus sibling aggregators.
- **Goal (4) resolves on evidence.** Zero files under `Metalogic/` import `Bimodal.FrameConditions`;
  `FrameConditions/` imports `Bimodal.Metalogic.Soundness`. FrameConditions sits strictly above
  Metalogic. Keep separate; merging would invert the dependency direction.
- **`WeakCanonical` is the riskiest possible move** (581 import lines / 137 files). Deferred by
  explicit decision — see Non-Goals.
- **28 markdown files reference `Bimodal.Metalogic.*` module paths.** A `.lean`-only rewrite leaves
  them dangling. The invariant script gates on markdown module paths too.

Independent re-verification performed during planning (all confirmed against the working tree at
commit `e832cc72a`):

| Claim | Verified value |
|---|---|
| Live `.lean` files (both Boneyards excluded) | 288 |
| `Metalogic/Relational/` contents | `README.md` only, zero `.lean` |
| Aggregator-less Metalogic subdirs | `Core`, `Bundle`, `Algebraic`, `SoundnessLemmas`, `Relational` |
| Importers of `Bimodal.Metalogic.Metalogic` | 7 (1 in `Theories/`, 6 in `Tests/Integration/`) |
| Importers of `Bimodal.Metalogic.BXCanonical.BXCanonical` | 1 (`Metalogic/Metalogic.lean`) |
| Importers of `Bimodal.Metalogic.WeakCanonical.WeakCanonical` | 1 (`Metalogic/WeakCanonical.lean`) |
| Importers of `Bimodal.Metalogic.Completeness` | 0 live (dead, as reported) |
| `Automation/EFGameTactics.lean` namespace | `Bimodal.Metalogic.WeakCanonical` (misplaced) |

Two facts found during planning that the research report did not surface, and which this plan
accounts for:

1. **`Metalogic/WeakCanonical/Expressiveness/Claim1.lean` imports `Bimodal.Automation.EFGameTactics`** —
   a genuine layering inversion (Metalogic importing Automation). Relocating `EFGameTactics.lean`
   into `Metalogic/WeakCanonical/` both fixes its namespace mismatch and removes this inversion.
   This raises the priority of that move from cosmetic to structural.
2. **The goal (6) blast radius is roughly double the research estimate.** Measured: ~50 references
   across ~20 files (research said ~27 in 8). Critically, it includes two *executable* references,
   not just prose: `Theories/Bimodal/Automation/MachineAppendixExport.lean` line 393 hardcodes
   `"Theories/Bimodal/typst/generated/machine-appendix.jsonl"` as a default output path, and
   `scripts/typst-sync-check.sh` contains path-resolution *logic* keyed on the literal prefix
   `Theories/Bimodal/` (lines 130-131, 142, 147). Goal (6) therefore gets two phases with a
   script-execution gate, not one phase with a link-check gate.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in the delegation, and no roadmap phases are required for this
plan.

## Goals & Non-Goals

**Goals**:

- (1) Clarify the `BXCanonical` (chronicle) / `WeakCanonical` (Kamp-Reynolds) / `Algebraic`
  (parametric) three-way relationship through a correct, measured architecture map and standardized
  aggregator boundaries.
- (2) Bring module-level documentation into agreement with the tree: fix the stale maps, add the one
  missing module docstring, add READMEs for uncovered directories.
- (3) One consistent aggregator convention (sibling `X.lean` beside `X/`) with explicit exports,
  applied to every Metalogic subdirectory.
- (4) Settle FrameConditions placement on measured layering evidence, and record that evidence
  durably.
- (5) Audit both Boneyards and document the two-location fact.
- (6) Decide and execute the `docs/`/`latex/`/`typst/` placement question.
- Establish a reusable, scripted invariant check so that "the reorganization did not break anything"
  is a command, not a judgement.

**Non-Goals**:

- **No declaration renames.** Every operation here is `git mv` + import rewrite + prose. The
  systematic Mathlib naming upgrade runs after this task; renaming now churns that rewrite twice.
- **No physical regrouping of `BXCanonical`/`WeakCanonical`/`Algebraic`.** Declined on evidence: the
  mutual cycle means directory nesting cannot express the relationship, and `WeakCanonical`'s 581
  import lines across 137 files is exactly where a partial move — the failure mode the charter names
  as "worse than no move" — is most likely. This decision is recorded in the architecture map, not
  silently dropped.
- **No rename of the Lean source root** (`Theories/` -> anything). Deferred to the naming task per
  the charter, even though this plan decides the `docs`/`latex`/`typst` question.
- **No proof work.** The sole live `sorry` is an invariant to preserve, not a defect to fix.
- **No Boneyard deletion.** The audit documents; it does not purge.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A move silently reroutes a proof through a different import path, changing what it depends on | H | M | Gate on the four `#print axioms` results, not just on a sorry count. An axiom-set change is detected even when the build stays green and the sorry count is unchanged (Phase 1 builds this check). |
| `.lean` imports updated but the 28 markdown files left dangling — a "complete-looking but actually partial" move | H | H | The invariant script's markdown module-path resolution check runs at *every* phase gate, so a partial move fails the gate that created it rather than surfacing at the end. |
| A `find`/`grep` filter excludes only the top-level Boneyard, contaminating counts with 27k archived Kamp lines | M | H | All filters go through the single Phase 1 script, which hardcodes `-not -path '*/Boneyard/*'`. Ad-hoc greps in later phases are forbidden by the plan; phases call the script. |
| `BimodalTest` green is a weaker gate than it looks — 8 test modules are unreachable from `Tests/BimodalTest.lean` and never compile | M | H | Phase 2 widens the gate by wiring them in where they compile, and the invariant script's dangling-import check covers every live file regardless of reachability, so unreachable code cannot rot silently. |
| An unreachable module (e.g. `Metalogic/Completeness.lean`) does not actually compile, so "wiring it in" breaks the build | M | M | Phase 5 compile-checks each dead module in isolation with `lake env lean` *before* deciding wire-in vs. archive. Archive is the default outcome. |
| Relocating `docs`/`latex`/`typst` breaks the typst toolchain, whose scripts contain path-resolution logic (not just literals) | H | M | Phase 11 gates on actually executing `scripts/typst-sync-check.sh` and `scripts/typst-machine-appendix.sh`, not on grepping for stale strings. |
| Adding aggregators for `Core`/`Bundle` introduces a genuine module-level cycle | H | L | Aggregators import concrete leaf modules only. No existing file may be edited to import an aggregator. `lake build` detects any true cycle immediately at the phase gate. |
| Breaking the `Core` <-> `Bundle` cycle turns out to have a larger blast radius than measured | M | L | Phase 7 carries an explicit abort threshold and a documented no-op outcome; skipping it costs nothing downstream. |
| Task-number citations leak into files outside `specs/**` while rewriting READMEs | L | M | Phase 10 strips the existing 79 and every doc-writing phase states the prohibition; Phase 13 re-scans. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 11 | 1 |
| 3 | 3, 12 | 2 (for 3), 11 (for 12) |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7, 8, 9 | 6 |
| 8 | 10 | 7, 8, 9 |
| 9 | 13 | 10, 12 |

Phases within the same wave can execute in parallel. Territory is disjoint within each wave:
Phase 2 owns `Tests/`, Phase 11 owns `scripts/` + `lakefile.lean` + the moved directories; Phase 3
owns `Theories/Bimodal/**/*.lean`, Phase 12 owns markdown path references. Phases 7/8/9 own
disjoint documentation files, enumerated in each phase.

### Phase 1: Verification Harness and Baseline Capture [COMPLETED]

- **Goal:** Turn "nothing broke" into a single command that later phases call, and capture the
  pre-change baseline. No source files change in this phase.
- **Tasks:**
  - [x] Resolve the fully-qualified names of the four flagship theorems whose axiom sets are the
        strongest invariant: `completeness_dense`, `completeness_discrete`, `completeness`,
        `countermodel_dense`. Record the resolved names in the script.
  - [x] Write `scripts/check-module-invariants.sh` implementing these checks *(deviation: altered — C8/C9/C10 are implemented up front but gated behind `ENFORCE_C8/C9/C10` flags defaulting to 0, reported as `TODO` lines. Phases 6/10/12 flip their flag to 1 instead of authoring the check. A check that fails at every gate is not a gate; this keeps the script exit-0-on-green while making progress toward each end-state invariant visible from Phase 1 onward.)*, each with a clear
        PASS/FAIL line and a non-zero exit on any failure:
    - **C1 Build**: `lake build` exits 0.
    - **C2 Axiom sets**: write a scratch file importing `Bimodal` with `#print axioms` for the four
      theorems, run it via `lake env lean --run` (or `lake env lean`), and compare against the
      recorded baseline. Expected: `completeness_dense`, `completeness_discrete`,
      `countermodel_dense` -> `[propext, Classical.choice, Quot.sound]`; `completeness` ->
      `[propext, sorryAx, Classical.choice, Quot.sound]`. Do NOT scrape `lake build` stdout for
      these — an incremental build may not re-emit them.
    - **C3 Sole sorry, located by content**: the structural-sorry grep
      `grep -rnE --include='*.lean' '(^[[:space:]]*sorry[[:space:]]*$)|(:=[[:space:]]*sorry[[:space:]]*$)|(\bexact sorry\b)|(<;> sorry)' Theories | grep -v '/Boneyard/'`
      returns exactly one hit, that hit is in
      `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`, and that file contains
      `theorem countermodel_discrete`. Assert by content only; never assert a line number.
    - **C4 Dangling imports**: every `import Bimodal.*` and `import BimodalTest.*` line across live
      `Theories/` and `Tests/` resolves to an existing `.lean` file. Zero unresolved.
    - **C5 Markdown module paths**: every `Bimodal.Metalogic.*`-shaped (and more generally
      `Bimodal.*`-shaped) module path appearing in non-`specs/**` markdown resolves to an existing
      module. Report unresolved paths with file and line.
    - **C6 Unreachable-module rot guard**: `lake env lean` compile-check each module listed in a
      companion manifest of known-unreachable live modules, so code outside the build graph cannot
      silently break.
    - **C7 Live inventory**: print (informational, not asserted) the live `.lean` count and the
      per-top-level-directory file counts.
    - Every filesystem traversal in the script uses `-not -path '*/Boneyard/*'` so BOTH Boneyards
      are excluded. Add a self-test asserting that the exclusion matches two distinct directories.
  - [x] Run the script against the clean tree and write its full output to
        `specs/131_refactor_module_organization/baseline-invariants.txt`.
  - [x] Confirm the script exits 0 on the unmodified tree.
  - [x] The script and its manifest contain no task-number references (they live outside `specs/**`).
- **Timing:** 1.5 hours
- **Depends on:** none
- **Files to modify:**
  - `scripts/check-module-invariants.sh` - new; the phase-gate harness
  - `scripts/module-invariants-manifest.txt` (or equivalent) - new; known-unreachable module list
  - `specs/131_refactor_module_organization/baseline-invariants.txt` - new; captured baseline
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0 on the clean tree
  - C2 reports the four expected axiom lists; C3 reports exactly one sorry at
    `theorem countermodel_discrete`; C4 and C5 report zero unresolved
  - The Boneyard self-test confirms two excluded directories

---

### Phase 2: Widen the Test Gate [COMPLETED]

- **Goal:** Make `BimodalTest` a real gate before any file moves happen. 8 test modules are
  unreachable from `Tests/BimodalTest.lean` and would not catch a broken import.
- **Tasks:**
  - [x] Compile-check each of the 8 orphaned modules in isolation with `lake env lean`: *(deviation: altered — used `lake build <Module>` instead of `lake env lean <path>`; the latter reports spurious "object file ... does not exist" errors because unbuilt executable-root .oleans are missing, which would have been misread as rot. Result: 6 compile, 2 broken.)*
        `BimodalTest.Automation.FormulaMutatorTest`, `BimodalTest.Automation.InterestingnessTest`,
        `BimodalTest.Automation.ProofFirstTests`, `BimodalTest.ProofSystem.DerivationBenchmark`,
        `BimodalTest.Semantics.SemanticBenchmark`, `BimodalTest.TraceCertificateTest`,
        `BimodalTest.TraceExportTest`, `BimodalTest.TraceExporterE2ETest`.
  - [x] Wire every module that compiles cleanly into `Tests/BimodalTest.lean`. *(deviation: altered — only 4 of the 6 compiling modules could be wired. `FormulaMutatorTest` and `ProofFirstTests` compile in isolation but fail on import into the test root with "environment already contains 'main' from Bimodal.Automation.DatasetValidator": each pulls in an executable root that defines `main`. Quarantined per the phase's own "more than an import fix -> quarantine" instruction.)*
  - [x] For any module that does NOT compile, leave it unwired and add it to the Phase 1
        unreachable-module manifest with a one-line reason, so C6 keeps watching it.
  - [x] Record which modules were wired and which were quarantined; this determines whether
        `BimodalTest.Automation.ProofFirstBenchmark` is live (Phase 5 depends on the answer).
  - [x] These modules are name-stable; do not rename anything to make them compile. If a module
        needs more than an import fix, quarantine it.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Files to modify:**
  - `Tests/BimodalTest.lean` - add imports for modules that compile
  - `scripts/module-invariants-manifest.txt` - add any quarantined modules
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0
  - `lake build BimodalTest` exits 0
  - The count of unreachable test modules is recorded and is either 0 or fully manifested

---

### Phase 3: Standardize Aggregators [COMPLETED]

- **Goal:** One convention — sibling `X.lean` beside `X/` — applied across Metalogic. Seven of the
  eight top-level directories already follow it; Metalogic is the outlier, and five of its
  subdirectories have no aggregator at all. Mathlib uses neither convention, so there is no upstream
  authority to appeal to; the local majority rule wins because it is checkable by script.
- **Tasks:**
  - [x] `git mv Theories/Bimodal/Metalogic/Metalogic.lean Theories/Bimodal/Metalogic.lean`.
        Update its 7 importers to `import Bimodal.Metalogic`: `Theories/Bimodal/Bimodal.lean` plus
        `Tests/BimodalTest/Integration/{BimodalIntegrationTest,ProofSystemSemanticsTest,TemporalIntegrationTest,Helpers,AutomationProofSystemTest,ComplexDerivationTest}.lean`.
  - [x] `git mv Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean Theories/Bimodal/Metalogic/BXCanonical.lean`.
        Sole importer is the relocated `Metalogic.lean`; update it to
        `import Bimodal.Metalogic.BXCanonical`.
  - [x] Collapse the WeakCanonical duplication: `Theories/Bimodal/Metalogic/WeakCanonical.lean`
        (13-line stub, correct sibling position) and
        `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` (80 lines, self-named inner).
        Fold the inner file's import list and module doc into the sibling file, then
        `git rm` the inner one. The sibling's only importer relationship is preserved.
  - [x] Add sibling aggregators that do not yet exist: `Theories/Bimodal/Metalogic/Core.lean`,
        `Bundle.lean`, `Algebraic.lean`, `SoundnessLemmas.lean`. Each imports the concrete leaf
        modules of its directory and carries a `/-!` module doc naming the directory's role.
  - [x] **Constraint**: aggregators import concrete leaf modules ONLY. Do not edit any existing file
        to import an aggregator — that is how a real module-level cycle would get introduced.
  - [x] Do not touch `Theories/Bimodal.lean` / `Theories/Bimodal/Bimodal.lean`. That pair exhibits
        the same both-at-once pattern, but `Theories/Bimodal.lean` is the Lake `lean_lib` root
        (`srcDir := "Theories"`), so the indirection is load-bearing. Note it in the Phase 7
        architecture map as a known, deliberate exception.
  - [x] Fix `Theories/Bimodal/Bimodal.lean`'s broken References link
        `[Metalogic.lean](Metalogic.lean)`, which now points at the real relocated file.
        *(deviation: altered -- no edit was needed. The link is relative to
        `Theories/Bimodal/`, so moving `Metalogic/Metalogic.lean` to
        `Theories/Bimodal/Metalogic.lean` made the existing link resolve. Verified, not edited.)*

  **Phase 3 result.** The gate caught two stale references a `.lean`-only rewrite would have
  left dangling, both in the typst tree: `typst/SYNC-MAP.md` named the module
  `Bimodal.Metalogic.BXCanonical.BXCanonical` (C5), and `typst/chapters/04-metalogic.typ`
  cited the path `Metalogic/Metalogic.lean`. Both corrected. C8 (aggregator convention)
  passes as of this phase, ahead of Phase 6 enforcing it.

  The four new aggregators (`Core`, `Bundle`, `Algebraic`, `SoundnessLemmas`) have no importer,
  per this phase's own no-cycle constraint, so they are unreachable from every Lake root and are
  recorded in the C6 manifest. C6 compile-checks them, so they cannot rot.
- **Timing:** 1.5 hours
- **Depends on:** 2
- **Files to modify:**
  - `Theories/Bimodal/Metalogic.lean` - moved from `Metalogic/Metalogic.lean`
  - `Theories/Bimodal/Metalogic/BXCanonical.lean` - moved from `BXCanonical/BXCanonical.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical.lean` - absorbs the inner self-named file
  - `Theories/Bimodal/Metalogic/{Core,Bundle,Algebraic,SoundnessLemmas}.lean` - new aggregators
  - `Theories/Bimodal/Bimodal.lean` - import update + broken link fix
  - `Tests/BimodalTest/Integration/*.lean` - 6 import updates
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0 (C4 catches any missed importer)
  - No `X/X.lean` self-named aggregator remains under `Metalogic/`
  - Every `Metalogic/` subdirectory has exactly one sibling aggregator

---

### Phase 4: Relocate Misplaced Modules [COMPLETED]

- **Goal:** Put the one namespace-mismatched file where its namespace says it lives, which also
  removes a real layering inversion, and delete the empty placeholder directory.
- **Tasks:**
  - [x] `git mv Theories/Bimodal/Automation/EFGameTactics.lean Theories/Bimodal/Metalogic/WeakCanonical/EFGameTactics.lean`.
        It declares `namespace Bimodal.Metalogic.WeakCanonical` and imports
        `Bimodal.Metalogic.WeakCanonical.EFGames.CustomGame`; it is a Metalogic file that was living
        in Automation.
  - [x] Update its two importers: `Theories/Bimodal/Automation.lean` and
        `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Claim1.lean`, both to
        `import Bimodal.Metalogic.WeakCanonical.EFGameTactics`.
  - [x] Confirm the layering improvement: `Claim1.lean`'s import becomes intra-Metalogic, removing
        the only `Metalogic -> Automation` upward edge. `Automation.lean` gaining a
        `Metalogic.WeakCanonical` import introduces no new layering violation — Automation already
        imports `Bimodal.Metalogic.Decidability.*` (13 such import lines) and previously reached
        `Metalogic.WeakCanonical.EFGames.CustomGame` transitively through this very file.
  - [x] Verify by measurement that no `Metalogic/**` file imports `Bimodal.Automation.*` after the
        move, and record the result. *(deviation: altered -- the measurement contradicts the plan's
        premise. `Claim1.lean` was NOT the only `Metalogic -> Automation` edge: four more exist and
        remain after the move, all in `Metalogic/Decidability/`:
        `Closure.lean -> Automation.ProofSearch.Core`,
        `DecisionProcedure.lean -> Automation.ProofSearch.Strategies`,
        `DecisionProcedure.lean -> Automation.Normalization`, and
        `TraceExport.lean -> Automation.DataExport`.
        The move still removes one genuine inversion and fixes the namespace/path mismatch, but this
        phase's verification criterion "zero files under `Metalogic/` import `Bimodal.Automation.*`"
        is unreachable without relocating the decision-procedure / proof-search boundary, which is
        outside this task's scope. Recorded here and in the Phase 13 decision record rather than
        silently restated as satisfied. Measured edge count: 5 before, 4 after.)*
  - [x] Remove `Theories/Bimodal/Metalogic/Relational/`. It contains only a `README.md` describing
        itself as a placeholder and zero `.lean` files. `git rm -r` the directory; if any document
        references it, that reference is corrected in Phase 7 or 8.
  - [x] Update `Theories/Bimodal/Automation/README.md` and any `Metalogic/WeakCanonical/README.md`
        file listing to reflect the moved file. *(deviation: altered -- scope widened. The
        `WeakCanonical/README.md` module table was wrong well beyond the moved file: it listed a
        non-existent `ExpressiveCompleteness/` directory and a non-existent `Separation.lean`,
        omitted `Kamp/` (99 files / 71,246 lines) and `PriorDefs.lean` entirely, and mis-stated every
        subdirectory count (`Separation/` as "11+ files"; actually 3). The table was regenerated from
        measurement -- correcting one row of a table that stale would have left exactly the dangling
        references Phase 13 forbids.)*
- **Timing:** 1 hour
- **Depends on:** 3
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/EFGameTactics.lean` - moved from `Automation/`
  - `Theories/Bimodal/Automation.lean` - import update
  - `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Claim1.lean` - import update
  - `Theories/Bimodal/Metalogic/Relational/` - removed
  - `Theories/Bimodal/Automation/README.md`, `Theories/Bimodal/Metalogic/WeakCanonical/README.md` - file lists
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0
  - Zero files whose path is under `Metalogic/` import `Bimodal.Automation.*`
  - Every live file's declared namespace agrees with its path (this was the one exception)

---

### Phase 5: Resolve Dead Modules [COMPLETED]

- **Goal:** No live-tree module is simultaneously unreachable and documented as live. Decide each
  case on a compile check, not on assumption.
- **Tasks:**
  - [x] `Theories/Bimodal/Metalogic/Completeness.lean` (534 lines). Zero live importers; the only
        import line anywhere is from a Boneyard file. Yet both `Metalogic/README.md` and
        `Metalogic.lean` document it as live. **Decision: archive to
        `Theories/Bimodal/Boneyard/`.** Rationale: `lean_lib Bimodal` builds only what is reachable
        from the root module, so this file is not compiled today and reviving it is a proof-work
        gamble outside this task's no-rename, no-proof scope; the live completeness results already
        live in `BXCanonical`/`WeakCanonical`. Before archiving, run
        `lake env lean Theories/Bimodal/Metalogic/Completeness.lean` and record whether it compiles
        — that fact belongs in the Boneyard note either way.
  - [x] `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` (88 lines). It is cited in prose
        by `ProofSystem/Axioms.lean` (line ~237, as the non-derivability counterexample) and listed
        in `ProofSystem/README.md`, so it is documentation-load-bearing. Compile-check it; if clean,
        wire it into `Theories/Bimodal/ProofSystem.lean` so the citation is backed by compiled code.
        If it does not compile, archive it and remove both citations.
  - [x] `Theories/Bimodal/Automation/ProofFirstBenchmark.lean` (173 lines). Its only importer is
        `Tests/BimodalTest/Automation/ProofFirstTests.lean`, one of the orphaned test modules. If
        Phase 2 wired `ProofFirstTests` in, this module is now live — take no action beyond
        confirming it. If Phase 2 quarantined it, add both to the unreachable manifest so C6 guards
        them.
  - [x] Update the Phase 1 unreachable-module manifest to match the post-phase reality, and confirm
        the live `.lean` count moved by exactly the expected delta.
  - [x] Record each decision and its evidence for the Phase 13 decision record.

  **Phase 5 result.** All three modules compile (`lake build <Module>`), so every decision is
  made on evidence rather than on assumed rot.
  - `Metalogic/Completeness.lean` -- archived to
    `Boneyard/SupersededCompleteness/`, with a README recording that it *did* compile at
    archival (it was unreferenced, not broken -- the only place that fact now survives, since
    the file is inert and nothing re-checks it).
  - `ProofSystem/LinearityDerivedFacts.lean` -- compiles, so wired into
    `Theories/Bimodal/ProofSystem.lean`. Its `Axioms.lean` non-derivability citation is now
    backed by compiled code, and its manifest line is deleted.
  - `Automation/ProofFirstBenchmark.lean` -- compiles, but Phase 2 quarantined its only
    importer (`ProofFirstTests`, duplicate `main`), so it stays unreachable and manifested.
  Live `.lean` count under `Theories/`: 291 -> 290, exactly the one archived file.

  The gate again caught what a `.lean`-only rewrite would have missed: four markdown references
  to the now-archived `Bimodal.Metalogic.Completeness`, in `BXCanonical/README.md`,
  `WeakCanonical/README.md`, `docs/development/MODULE_ORGANIZATION.md` and
  `docs/reference/API_REFERENCE.md`. *(deviation: altered -- the latter two are nominally Phase
  13 territory, but C5 fails the phase that creates a dangling path, so they were corrected here
  rather than carried as known-broken across five phase gates.)*
- **Timing:** 1.5 hours
- **Depends on:** 4
- **Files to modify:**
  - `Theories/Bimodal/Boneyard/` - receives `Completeness.lean` (and possibly `LinearityDerivedFacts.lean`)
  - `Theories/Bimodal/ProofSystem.lean` - possible aggregator addition
  - `Theories/Bimodal/ProofSystem/Axioms.lean`, `ProofSystem/README.md` - citation correction if archived
  - `scripts/module-invariants-manifest.txt` - updated
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0
  - No live-tree module is both unreachable and absent from the manifest
  - The live `.lean` count delta matches the number of files archived

---

### Phase 6: Aggregator and Layering Consistency Check [COMPLETED]

- **Goal:** Prove the structural work is complete and internally consistent before any documentation
  is written against it. Documentation written against a still-moving tree is how the current stale
  map came to exist.
- **Tasks:**
  - [x] *(deviation: altered -- C8 was authored in Phase 1 behind an `ENFORCE_C8` flag defaulting
        to 0; this phase flips the default to 1. See the Phase 1 note. The check began passing in
        Phase 3, so enforcement here locks in an already-satisfied invariant rather than
        introducing a newly-failing one.)*
        Extend `scripts/check-module-invariants.sh` with a structural check (C8): every
        subdirectory of `Theories/Bimodal/` and of `Theories/Bimodal/Metalogic/` has exactly one
        sibling aggregator `.lean`, and no `X/X.lean` self-named aggregator exists anywhere in the
        live tree. The documented exception is the Lake root pair
        `Theories/Bimodal.lean` + `Theories/Bimodal/Bimodal.lean`, which the check allowlists by
        name with an inline comment explaining why.
  - [x] Recompute the cross-subtree import edge table for `Metalogic/` (the counts research measured
        as `Bundle -> Core` 18, `BXCanonical -> Bundle` 9, `WeakCanonical -> BXCanonical` 4,
        `BXCanonical -> WeakCanonical` 2, `Core -> Bundle` 1, etc.) and save it to
        `specs/131_refactor_module_organization/edge-table-post-structural.txt`. Phase 7 draws the
        architecture map from this file, not from the research report.
  - [x] Recompute and record the blast-radius table (import lines and files touched per subtree) so
        the map's risk annotations are current.
  - [x] Confirm the two directory-level cycles are the only ones, and that their exact edges are
        enumerated file-by-file.
  - [x] **Optional, with an explicit abort threshold**: `Core/RestrictedMCS/Basic.lean` is the sole
        `Core -> Bundle` edge (it imports `Bundle.CanonicalTaskRelation`). Relocating it to
        `Metalogic/Bundle/RestrictedMCS/` makes `Core` a true leaf foundation and removes one of the
        two cycles. Measure the blast radius first — planning measured exactly 1 importer of
        `Bimodal.Metalogic.Core.RestrictedMCS.Basic`, but re-measure against the post-Phase-5 tree.
        **Abort condition**: if the move touches more than 10 import lines or more than 6 files,
        skip it, record the measurement and the skip, and continue. Nothing downstream depends on
        this move; the architecture map in Phase 7 documents whichever outcome occurs.

  **Phase 6 result.** Exactly **2** directory-level cycles, as predicted:
  `BXCanonical <-> WeakCanonical` (2 lines out / 4 lines back) and `Bundle <-> Core`
  (18 lines out / 1 line back), with every constituent edge enumerated file-and-line in
  `edge-table-post-structural.txt`. Zero simple cycles of length > 2. An earlier grouping that
  treated the sibling aggregators as their own pseudo-subtree reported 4 cycles; that was an
  artifact of the grouping (an aggregator importing its own directory is not a cross-subtree
  dependency), and the attribution rule is stated in the output file so the number is
  reproducible.

  Blast radius confirms the declined regroup: `WeakCanonical` is 339 import lines across 137
  files -- roughly five times the next-largest subtree (`Decidability`, 71/28).

  **Optional cycle break: measured and SKIPPED.** Relocating `Core/RestrictedMCS/Basic.lean`
  into `Bundle/` needs 2 import-line edits (under the 10-line limit) but touches 9 files
  (over the 6-file limit); the threshold is disjunctive, so the abort condition fires. Five of
  the nine are markdown -- precisely the references a `.lean`-only rewrite would leave dangling.
  Also recorded: the planning-time figure of "exactly 1 importer" is now 2, because the Phase 3
  aggregator `Metalogic/Core.lean` imports it by design.
- **Timing:** 1.5 hours
- **Depends on:** 5
- **Files to modify:**
  - `scripts/check-module-invariants.sh` - add C8
  - `specs/131_refactor_module_organization/edge-table-post-structural.txt` - new measurement output
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0 including the new C8
  - The edge table is regenerated from the post-move tree, not copied from research
  - Exactly two directory-level cycles are found, with every constituent edge named

---

### Phase 7: Rewrite the Metalogic Architecture Map [COMPLETED]

- **Goal:** Goal (1)'s primary deliverable. `Metalogic/README.md` currently maps a repository that
  no longer exists — it documents eight non-existent files, draws its dependency flowcharts over
  them, calls `WeakCanonical/Separation/` "11+ files" (it has 3), and omits `Kamp/` entirely.
- **Tasks:**
  - [x] Rewrite `Theories/Bimodal/Metalogic/README.md` from the Phase 6 edge table. Remove every
        reference to `Core/Core.lean`, `Bundle/SuccExistence.lean`, `Bundle/Completeness.lean`,
        `Bundle/TruthLemma.lean`, `Bundle/BFMCSTruth.lean`, `Algebraic/AlgebraicCompleteness.lean`,
        `Decidability/FMP.lean`, and `WeakCanonical/ExpressiveCompleteness/`.
  - [x] Add the `Kamp/` subtree to the map: 99 live files / 71,246 lines, with its two large
        sub-subtrees `NfMultiAnchorBridge/` (43 files / 41,859 lines) and `EANegationFix/` (7 files
        / 3,227 lines), and its own local Boneyard.
  - [x] Document the three-way relationship explicitly, which is the charter's central organizing
        question:
    - `BXCanonical` — the chronicle construction route to completeness.
    - `WeakCanonical` — the Kamp/Reynolds route, including the `Kamp/` machinery.
    - `Algebraic` — the parametric/algebraic route.
    - The genuinely layered core beneath all three: `Core -> Bundle -> {Algebraic, BXCanonical, WeakCanonical}`.
  - [x] Document the two directory-level cycles as **named, measured exceptions**, with their exact
        constituent edges, and state plainly why directory nesting cannot express the relationship:
        `WeakCanonical/{ChronicleExtraction,ReflexiveCanonical,Transfer}.lean` reach into
        `BXCanonical`, while `BXCanonical/Completeness.lean` and
        `BXCanonical/Chronicle/ChronicleToCountermodel.lean` reach back into `WeakCanonical`. Lean
        permits this because the cycle is at directory granularity while the module DAG is acyclic.
  - [x] Record the declined regroup as a decision with its evidence: `WeakCanonical` is 581 import
        lines across 137 files, the largest partial-move risk in the tree, and no nesting resolves a
        mutual dependency.
  - [x] Redraw any dependency flowcharts over modules that actually exist.
  - [x] No task-number references anywhere in this file.

  **Phase 7 result.** Full rewrite, drawn from `edge-table-post-structural.txt`. All eight
  non-existent files the old map documented are gone, and every remaining relative link and
  module path was checked to resolve. `Kamp/` is now mapped at three levels (99 files / 71,246
  lines, with `NfMultiAnchorBridge/` 43/41,859 and `EANegationFix/` 7/3,227, plus its local
  Boneyard), and `Separation/` is corrected from "11+ files" to its measured 3.

  Two things the plan did not anticipate are recorded in the map because leaving them out would
  reproduce the same stale-map defect: (a) `BXCanonical` imports from BOTH other routes (2 lines
  each), so the three routes are not independent alternatives -- all three are live; and (b) the
  four `Decidability -> Automation` upward edges from Phase 4, documented as a named known
  wrinkle. The map also carries the counting guidance, since every count in it is wrong if
  either Boneyard is missed.
- **Timing:** 1.5 hours
- **Depends on:** 6
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/README.md` - full rewrite
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0 (C5 proves every module path named in the map
    resolves to a real module)
  - Every file and directory named in the map exists; `Kamp/` is present
  - Both cycles are documented with their exact edges

---

### Phase 8: Docstring and Structure-Block Accuracy [COMPLETED]

- **Goal:** Goal (2). Coverage is already ~99%; this phase repairs accuracy and fills the small
  genuine gaps. Territory is disjoint from Phase 7 (which owns only `Metalogic/README.md`).
- **Tasks:**
  - [x] Add the one missing `/-!` module doc to
        `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — the only live file
        of 288 lacking one. *(deviation: skipped -- no gap to fill. That file DOES carry a `/-!`
        module doc ("# Multi-Anchor Characteristic Formula Bridge"); it simply sits at line 180,
        after ~160 lines of `--` import-rationale comments, which is the correct Lean position for
        a module doc but defeats a "look in the first N lines" check. Verified by measurement:
        `find Theories -name '*.lean' -not -path '*/Boneyard/*' | xargs grep -L '^/-!'` returns
        ZERO files, so all 290 live modules carry one. Coverage is 100%, not 99%.)*
  - [x] Rewrite the "Module Structure" block in `Theories/Bimodal/Metalogic.lean` (relocated in
        Phase 3). It currently lists `SoundnessLemmas.lean` as a file when it is a directory, names
        `BXCanonical/Filtration/`, `Decidability/FMP/`, and `WeakCanonical/Separation/`, and omits
        `Kamp/`.
  - [x] Rewrite the structure block in `Theories/Bimodal/FrameConditions.lean`, which lists a
        `Completeness.lean` that does not exist. The directory holds `FrameClass.lean`,
        `Validity.lean`, `Soundness.lean`, `Compatibility.lean`, and `README.md`.
  - [x] Update the component list in `Theories/Bimodal/Bimodal.lean` to match the post-Phase-5 tree.
  - [x] Add READMEs for the five uncovered directories: `Metalogic/WeakCanonical/Kamp/`,
        `Kamp/NfMultiAnchorBridge/`, `Kamp/EANegationFix/`, `Kamp/NfMultiAnchorBridge/SharedWitness/`,
        and `Metalogic/Decidability/Propositional/`. Each states the directory's role, its file
        inventory, and its position in the layering — measured, not assumed.
  - [x] No task-number references in any file touched here.

  **Phase 8 result.** Module-doc coverage is 100% of 290 live files, so this phase was pure
  accuracy repair. `Metalogic.lean`'s structure block now carries measured per-directory file
  counts, shows `SoundnessLemmas` as the directory it is, includes `Kamp/` with its local
  Boneyard flagged, and states that the top-level `Completeness.lean` is archived rather than
  missing. `FrameConditions.lean` no longer advertises a `Completeness.lean` that never existed
  there, and now carries the layering evidence. `Bimodal.lean`'s component list is corrected
  (`Theorems` had 6 modules listed against 8 actual). All five new READMEs are written from
  measurement, and every relative link in them was checked to resolve.
- **Timing:** 1.5 hours
- **Depends on:** 6
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` - add module doc
  - `Theories/Bimodal/Metalogic.lean` - structure block rewrite
  - `Theories/Bimodal/FrameConditions.lean` - structure block rewrite
  - `Theories/Bimodal/Bimodal.lean` - component list refresh
  - 5 new `README.md` files in the directories listed above
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0
  - All 288-minus-archived live files carry a `/-!` module doc (zero exceptions)
  - Every file named in every structure block exists

---

### Phase 9: Placement Decisions — FrameConditions and Boneyard [COMPLETED]

- **Goal:** Goals (4) and (5). Record both decisions durably where a future reader will find them.
  Territory is disjoint from Phases 7 and 8.
- **Tasks:**
  - [x] **Goal (4): keep `FrameConditions/` separate.** Record the measured evidence in
        `Theories/Bimodal/FrameConditions/README.md`: zero files under `Metalogic/` import
        `Bimodal.FrameConditions`; `FrameConditions/` imports `Bimodal.Metalogic.Soundness`,
        `Bimodal.ProofSystem.Axioms`, and `Bimodal.Semantics.Validity`; nothing outside the
        directory imports it except the library root. It is a 4-file / 816-line typeclass API layer
        that consumes Metalogic. Merging would invert the dependency direction and manufacture a new
        cycle. This is an evidence-based resolution, not a preference.
  - [x] Record the disambiguation the README must not get wrong: the 97 files referencing the
        identifier `FrameClass` mean `Bimodal.ProofSystem.Axioms.FrameClass` (an `inductive`, used
        as `FrameClass.Base` / `FrameClass.Discrete`), which is a different thing from
        `FrameConditions/FrameClass.lean`'s typeclasses `LinearTemporalFrame`, `SerialFrame`,
        `DenseTemporalFrame`, `DiscreteTemporalFrame`. A name-based audit conflates them.
  - [x] **Goal (5): Boneyard audit.** Write or refresh a `README.md` in each of the two Boneyards
        with a measured inventory. `Theories/Bimodal/Boneyard/` (92 files / 58,476 lines before this
        task's archival additions) and `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/`
        (62 files / 27,394 lines).
  - [x] Each Boneyard README states the archival criterion, the inventory, and — critically — that a
        second Boneyard exists elsewhere, with its path. Every count in the repository currently
        misses the Kamp-local one.
  - [x] State the two-Boneyard fact prominently in `Theories/Bimodal/README.md` so any future
        counting exercise sees it, and point at `scripts/check-module-invariants.sh` as the correct
        way to count live files.
  - [x] No task-number references in any file touched here.

  **Phase 9 result.** The `FrameConditions/README.md` rewrite found the directory's own
  documentation asserting the dependency direction **backwards**: it claimed to be "imported by
  `Bimodal.Metalogic.SoundnessLemmas`, `Bimodal.Metalogic.Soundness`" when those are among the
  things it *imports*. Measured: 0 files under `Metalogic/` import `Bimodal.FrameConditions`;
  its sole live importer is the library root `Bimodal.lean`. The README now states these as
  measurements and ships the command to re-derive them. *(deviation: altered -- the plan's
  "97 files referencing the identifier `FrameClass`" re-measures as 96 on the post-Phase-5 tree;
  the README carries the measured 96.)*

  Both Boneyard READMEs already existed and were substantive, so rather than replacing them each
  gained a prominent two-Boneyard cross-reference with measured counts (93 files / 59,010 lines
  and 62 / 27,394) plus an explicit archival criterion distinguishing "archived" from
  "unreachable but manifested" -- a distinction that matters under `Kamp/`, where several modules
  exist precisely to keep a transcription reachable. The same notice is now near the top of
  `Theories/Bimodal/README.md`, pointing at the invariant script as the correct way to count.

- **Timing:** 1 hour
- **Depends on:** 6
- **Files to modify:**
  - `Theories/Bimodal/FrameConditions/README.md` - layering evidence and the FrameClass disambiguation
  - `Theories/Bimodal/Boneyard/README.md` - inventory and cross-reference
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` - inventory and cross-reference
  - `Theories/Bimodal/README.md` - two-Boneyard notice and counting guidance
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0
  - Both Boneyard READMEs exist and each names the other's path
  - The FrameConditions README states the measured import counts, not a judgement

---

### Phase 10: Strip Task-Number Citations from Theories/ [COMPLETED]

- **Goal:** `.claude/rules/no-task-references-in-deliverables.md` forbids task-number citations
  outside `specs/**`; `Theories/` currently holds 79. This task is already rewriting the exact
  READMEs that carry most of them, so stripping them is nearly free here and expensive later. This
  touches prose only — it does not collide with the naming task.
- **Tasks:**
  - [x] *(deviation: altered -- measured 82, not 79, and 26 planted notes, not 14. The counts
        below are the measured ones.)* Enumerate all 79 occurrences under `Theories/` (excluding both Boneyards) across `.lean` and
        `.md` files.
  - [x] Remove the 14 planted verification notes of the form "This README was last verified before
        task ... -- verify file list is still current after that task completes" from
        `Theories/Bimodal/README.md`, `Metalogic/README.md`, and the 11 subdirectory READMEs. These
        notes are now satisfied; deleting them is the correct resolution.
  - [x] Replace inline citations with durable anchors per the rule. Examples requiring judgement:
        `(task 309 Phase 8)` in `Kamp/NfMultiAnchorBridge/Base.lean`,
        `## Reflexive G/H Semantics (Task 29)` in `Bundle/README.md`, and
        `moved to Boneyard/UltrafilterFrame/, task 21` in `Algebraic/README.md`. Each becomes a
        reference to a sibling document, a section heading, or a verified fact — never a task number.
  - [x] Where a citation carries information that would be lost (e.g. why a file was archived),
        preserve the information and drop only the identifier.
  - [x] Extend `scripts/check-module-invariants.sh` with a check (C9) that zero task-number
        citations exist under `Theories/`, so this cannot regress. *(deviation: altered -- C9 was
        authored in Phase 1 behind `ENFORCE_C9`; this phase flips the default to 1. See Phase 1.)*

  **Phase 10 result.** 82 citations measured (the plan estimated 79), across 38 files, now **0**.
  Breakdown: 26 planted "last verified before task N" notes deleted (the plan expected 14); 23 in
  `typst/SYNC-MAP.md`; 9 in Lean docstrings under `Kamp/NfMultiAnchorBridge/`; the rest across
  subdirectory READMEs and `docs/`.

  The root cause was fixed alongside the symptom: `docs/reference/readme-standard.md` **mandated**
  the planted note ("The task 131 note must accompany every 'Last verified' line"), which is why
  there were 26 of them. That instruction is replaced by one pointing at
  `scripts/check-module-invariants.sh`, whose C5 catches stale inventories mechanically. Without
  that change the notes would have been re-planted by the next README author.

  `docs/reference/comment-convention.md` was a second generator: its worked examples of comment
  style all cited task numbers, teaching the anti-pattern by example. Rewritten to durable
  anchors.

  Information was preserved wherever a citation carried any: "moved to Boneyard/UltrafilterFrame/,
  task 21" keeps the destination and drops only the identifier; "Task 44: Removed inconsistent
  `existsTask_irreflexive_axiom`" keeps the declaration name. Citations that carried nothing but
  the number were deleted outright.
- **Timing:** 1.5 hours
- **Depends on:** 7, 8, 9
- **Files to modify:**
  - `Theories/Bimodal/README.md`, `Metalogic/README.md`, and 11 subdirectory READMEs - remove planted notes
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` - inline citation
  - `Theories/Bimodal/Metalogic/Bundle/README.md`, `Metalogic/Algebraic/README.md` - inline citations
  - Remaining files among the 79 occurrences
  - `scripts/check-module-invariants.sh` - add C9
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0 including C9
  - Zero task-number citations remain under `Theories/`
  - No information was lost — each removed citation either carried none or was replaced by a durable anchor

---

### Phase 11: Relocate docs/, latex/, typst/ and Update Executable References [COMPLETED]

- **Goal:** Goal (6), execution half. `srcDir := "Theories"` means Lake treats this tree as source,
  yet 2.6M of non-Lean assets sit inside it (`docs/` 404K, `latex/` 192K, `typst/` 2.0M including a
  `generated/` build-output subdirectory). A root `docs/` already exists and cross-links into the
  source-tree one via `../Theories/Bimodal/docs/...`, so the current split is already incoherent.
  **Decision: move all three to the project root**, with `Theories/Bimodal/docs/` merged into the
  existing root `docs/` rather than becoming a sibling `docs/bimodal/` — merging eliminates the
  two-tree incoherence, which is the actual defect. This phase owns the executable references; the
  prose references are Phase 12.
- **Tasks:**
  - [x] `git mv` the three directories to the project root. Merge `Theories/Bimodal/docs/` into the
        existing `docs/` tree, resolving any filename collisions explicitly (do not silently
        overwrite). `latex/` and `typst/` become root-level directories.
  - [x] Update `Theories/Bimodal/Automation/MachineAppendixExport.lean` line ~393: the default
        `output` value is the string literal
        `"Theories/Bimodal/typst/generated/machine-appendix.jsonl"`. This is executable behaviour,
        not prose.
  - [x] Update `scripts/typst-machine-appendix.sh`: `GEN_DIR` (line ~56), the two documented output
        paths (lines ~22-23), and the `lake env lean --run Theories/Bimodal/Automation/MachineAppendixExport.lean`
        invocation (line ~195) — the last stays as-is, since the Lean source does not move.
  - [x] Update `scripts/typst-sync-check.sh` with care: it contains path-resolution *logic*, not
        just literals. `BIMODAL_DIR` (line ~30) must continue to point at the Lean source root for
        identifier resolution, while the typst-scanning root moves. The `rel.startswith("Theories/Bimodal/")`
        prefix-stripping at lines ~130-131 and the violation messages at lines ~142/~147 need to
        reflect the new two-root reality.
  - [x] Update `scripts/typst-status-counts.sh` `BIMODAL_DIR` (line ~30) and its header comment.
  - [x] Update the `lakefile.lean` doc comment on the `machine_appendix` exe (line ~105).
  - [x] Resolve the loose `Theories/Bimodal/BimodalReference.pdf`. Root `README.md` links it at
        `Theories/Bimodal/latex/BimodalReference.pdf` — a pre-existing broken link. Move the PDF to
        the relocated `latex/` directory so the link becomes correct after Phase 12 updates its
        prefix. Note that `typst/build/BimodalReference.pdf` is a separate build artifact; do not
        conflate them.
  - [x] Keep the source-root directory name `Theories/` unchanged — that rename belongs to the
        naming task per the charter.

  **Phase 11 result.** `Theories/Bimodal/` is now Lean-only: no assets remain under the Lean
  source root. `latex/` and `typst/` are root-level; `BimodalReference.pdf` moved into `latex/`,
  making the root `README.md` link correct for the first time.

  **docs/ merge collisions, resolved explicitly.** 30 source files vs 47 root files, with 5
  collisions -- all index `README.md`s (`docs/README.md` plus the `user-guide/`, `project-info/`,
  `reference/`, `research/` indexes). 25 files moved cleanly by `git mv`; for the 5, the incoming
  content was appended into the root file under a labelled "Merged from the Lean source tree"
  heading rather than overwriting either side, so nothing was lost.

  **The executable gate earned its place.** Running the scripts, rather than grepping for stale
  strings, caught two defects a grep would have missed:

  1. **A Phase 4 regression.** `scripts/typst-status-counts.sh` called
     `strip_and_count_sorries "${METALOGIC_DIR}/Relational"`, and Phase 4 deleted `Relational/`.
     Under `set -e` the missing path aborted the script, which made `typst-sync-check.sh`
     Check 2 die with a JSON decode error on empty input. The invariant script could not have
     caught this -- it never runs the typst toolchain. Fixed by making the helper return 0 for a
     missing path and dropping the two subtrees that no longer exist (`Relational/`, and
     `ConservativeExtension/`, archived earlier) from the accounting and its label.
  2. **Two stale path claims inside the book**, `Relational/` and `Metalogic/Completeness.lean`
     in `typst/chapters/04-metalogic.typ`, both caused by this task's Phases 4 and 5.

  **Violation accounting.** `typst-sync-check.sh` Check 1 reports 18 violations, down from 21
  before these fixes. All 18 predate this task (`ConservativeExtension/`, `DenseSoundness.lean`,
  `FMP/DenseFMP.lean`, `lift_derivation_qfree`, ...) and are book-content drift against
  long-archived modules, not path breakage: zero of them name `docs`, `latex` or `typst`.
  Check 2's `MISMATCH_COUNT=6` is likewise pre-existing -- the committed `status.typ` records
  sorry counts (Algebraic 3, BXCanonical 4, Bundle 12, WeakCanonical 24) from before extensive
  sorry-elimination work; live values are 0/0/0/5. *(deviation: skipped -- regenerating
  `status.typ` would clear those 6, but it is stale book content unrelated to the relocation and
  regenerating it would require re-rendering downstream chapters. The phase criterion is "no NEW
  violations relative to pre-move behaviour", which is met.)* `typst-machine-appendix.sh` runs
  clean and writes to the new root-level `GEN_DIR`.
- **Timing:** 2 hours
- **Depends on:** 1
- **Files to modify:**
  - `docs/` (root) - receives the merged source-tree docs
  - `latex/`, `typst/` (root) - relocated
  - `Theories/Bimodal/Automation/MachineAppendixExport.lean` - default output path
  - `scripts/typst-machine-appendix.sh`, `scripts/typst-sync-check.sh`, `scripts/typst-status-counts.sh`
  - `lakefile.lean` - doc comment
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0
  - `bash scripts/typst-sync-check.sh` runs and reports no new violations relative to its
    pre-move behaviour
  - `bash scripts/typst-machine-appendix.sh` runs and writes to the new `GEN_DIR`
  - `lake build` exits 0 (the `MachineAppendixExport.lean` edit is a string literal, but the build
    must confirm it)
  - No `.lean` or `.sh` file under the repository references `Theories/Bimodal/{docs,latex,typst}`

---

### Phase 12: Update Prose References to the Relocated Directories [NOT STARTED]

- **Goal:** Goal (6), reference-completeness half. ~50 references across ~20 files point at the old
  locations; leaving any behind reproduces exactly the dangling-reference defect the charter warns
  about. Territory: path-reference edits only (the literal strings
  `Theories/Bimodal/{docs,latex,typst}`). Module-path (`Bimodal.Metalogic.*`) corrections in
  `docs/` belong to Phase 13.
- **Tasks:**
  - [ ] Update all markdown references, working from a fresh measurement rather than this list:
        `docs/README.md` (~17), `README.md` (~5), `docs/user-guide/README.md` (~5),
        `docs/research/README.md` (~3), `docs/project-info/MAINTENANCE.md` (~3),
        `docs/reference/README.md` (~2), `docs/project-info/README.md` (~2), and one each in
        `docs/training/PIPELINE.md`, `docs/research/BIMODAL_LOGIC.md`,
        `docs/project-info/IMPLEMENTATION_STATUS.md`, `docs/project-info/FEATURE_REGISTRY.md`,
        `docs/development/CONTRIBUTING.md`, `docs/development/CI_CD_PROCESS.md`.
  - [ ] Update the references inside the moved trees themselves: `typst/README.md` (~3),
        `latex/README.md` (~1), and the relocated `docs/reference/readme-standard.md` (~1).
  - [ ] Fix the relative-path direction: root `docs/` previously reached the source tree via
        `../Theories/Bimodal/docs/...`. After the merge these become intra-`docs/` links.
  - [ ] Confirm root `README.md`'s `BimodalReference.pdf` link now resolves (Phase 11 moved the file
        to make this true).
  - [ ] Extend `scripts/check-module-invariants.sh` with a check (C10) that zero references to
        `Theories/Bimodal/{docs,latex,typst}` remain anywhere outside `specs/**`.
  - [ ] Leave `specs/**` untouched — historical task artifacts legitimately record the old paths.
- **Timing:** 1 hour
- **Depends on:** 11
- **Files to modify:**
  - The ~20 markdown files enumerated above
  - `scripts/check-module-invariants.sh` - add C10
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0 including C10
  - Zero occurrences of `Theories/Bimodal/docs`, `Theories/Bimodal/latex`, or
    `Theories/Bimodal/typst` outside `specs/**`
  - Every relative markdown link in `docs/` resolves to an existing file

---

### Phase 13: Final Sweep and Decision Record [NOT STARTED]

- **Goal:** Prove import completeness across every file type, correct the remaining module-path
  references in root `docs/`, and record the deferred decisions so the naming task inherits them.
- **Tasks:**
  - [ ] Correct `Bimodal.Metalogic.*` module paths in root-`docs/` files that Phase 12 deliberately
        did not touch: `docs/reference/API_REFERENCE.md`, `docs/development/MODULE_ORGANIZATION.md`,
        `docs/training/PIPELINE.md`, and the relocated `typst/SYNC-MAP.md`. `MODULE_ORGANIZATION.md`
        in particular is a direct competitor to `Metalogic/README.md` and must agree with it.
  - [ ] Run the full invariant script from a clean checkout state and diff its output against
        `baseline-invariants.txt`. Every difference must be an intended consequence of a phase; any
        unexplained difference is a defect.
  - [ ] Confirm the three preservation invariants explicitly and by content:
    - `lake build` green with no new errors or warnings beyond the known single `sorry` warning
    - `lake build BimodalTest` green
    - the sole structural `sorry` still at `theorem countermodel_discrete` in
      `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
    - the four `#print axioms` results byte-identical to baseline
  - [ ] Write a decision record capturing what was decided and what was deliberately deferred, so
        the naming task does not re-litigate it: the declined `BXCanonical`/`WeakCanonical`/
        `Algebraic` regroup and why; the `FrameConditions` separation and its evidence; the
        `docs`/`latex`/`typst` merge-into-root choice; the deferred source-root rename; the
        `Core` <-> `Bundle` cycle outcome from Phase 6; and the fate of each dead module and each
        orphaned test module.
  - [ ] Confirm the invariant script itself contains no task-number references and is documented in
        `docs/development/` so it is discoverable.
- **Timing:** 1.5 hours
- **Depends on:** 10, 12
- **Files to modify:**
  - `docs/reference/API_REFERENCE.md`, `docs/development/MODULE_ORGANIZATION.md`,
    `docs/training/PIPELINE.md`, `typst/SYNC-MAP.md` - module-path corrections
  - `docs/development/` - document the invariant script
  - `specs/131_refactor_module_organization/summaries/01_module-reorganization-summary.md` - decision record
- **Verification:**
  - `bash scripts/check-module-invariants.sh` exits 0 with all checks C1-C10 passing
  - The final-vs-baseline diff contains only intended changes, each attributable to a named phase
  - Zero dangling module paths in any markdown file outside `specs/**`

---

## Testing & Validation

- [ ] `lake build` exits 0 at every phase boundary, with no new errors and no new warnings
- [ ] `lake build BimodalTest` exits 0 at every phase boundary
- [ ] The structural-sorry grep returns exactly one hit, in
      `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`, inside `theorem countermodel_discrete`
      — asserted by content, never by line number
- [ ] `#print axioms` for the four flagship theorems returns the baseline axiom sets:
      `completeness_dense`, `completeness_discrete`, `countermodel_dense` ->
      `[propext, Classical.choice, Quot.sound]`; `completeness` ->
      `[propext, sorryAx, Classical.choice, Quot.sound]`
- [ ] Zero dangling `import Bimodal.*` / `import BimodalTest.*` lines across live `Theories/` and `Tests/`
- [ ] Zero dangling `Bimodal.*` module paths in markdown outside `specs/**`
- [ ] Zero references to `Theories/Bimodal/{docs,latex,typst}` outside `specs/**`
- [ ] Zero task-number citations under `Theories/`
- [ ] `bash scripts/typst-sync-check.sh` and `bash scripts/typst-machine-appendix.sh` both run successfully
- [ ] Every live `.lean` file carries a `/-!` module doc block
- [ ] Every subdirectory has exactly one sibling aggregator; no `X/X.lean` remains except the
      allowlisted Lake root pair
- [ ] Every traversal excludes BOTH Boneyards

## Artifacts & Outputs

- `specs/131_refactor_module_organization/plans/01_module-reorganization.md` (this file)
- `specs/131_refactor_module_organization/baseline-invariants.txt` - Phase 1 baseline capture
- `specs/131_refactor_module_organization/edge-table-post-structural.txt` - Phase 6 measurement
- `specs/131_refactor_module_organization/summaries/01_module-reorganization-summary.md` - decision record
- `scripts/check-module-invariants.sh` - reusable phase-gate harness (checks C1-C10)
- `scripts/module-invariants-manifest.txt` - known-unreachable module list
- `Theories/Bimodal/Metalogic.lean`, `Metalogic/BXCanonical.lean`, `Metalogic/WeakCanonical.lean`,
  `Metalogic/{Core,Bundle,Algebraic,SoundnessLemmas}.lean` - standardized aggregators
- `Theories/Bimodal/Metalogic/README.md` - rewritten architecture map (goal 1 deliverable)
- 5 new subdirectory READMEs, 2 Boneyard READMEs, updated `FrameConditions/README.md`
- Root-level `latex/` and `typst/`; merged root `docs/`

## Rollback/Contingency

- The working tree is clean at commit `e832cc72a`. Every phase is committed separately using the
  `task {N} phase {P}: {name}` convention, so any phase can be reverted with `git revert` of a
  single commit without disturbing its predecessors.
- All file relocations use `git mv`, so history follows the files and a revert restores both content
  and path.
- If a phase gate fails, fix forward: the invariant script names the specific failing check and the
  offending file. Do not discard uncommitted work to reach a green build (see
  `.claude/rules/error-handling.md`).
- Phase 6 carries the only optional work in the plan (the `Core` <-> `Bundle` cycle break) with an
  explicit abort threshold: more than 10 import lines or more than 6 files touched means skip,
  record the measurement in the Phase 13 decision record, and continue. Nothing downstream depends
  on it, and Phase 7's architecture map documents whichever outcome occurs.
- If Phase 11 breaks the typst toolchain in a way that cannot be fixed within the phase, revert
  Phase 11 and 12 together; goals (1)-(5) are independent of goal (6) and remain valid without them.
- The baseline in `baseline-invariants.txt` is the reference for "unchanged". If a phase produces an
  axiom-set or sorry-location change, that is a hard stop, not a new baseline.
