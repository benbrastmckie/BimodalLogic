# Implementation Plan: Language-extension directories and probe tests

- **Task**: 634 - Language-extension directories and probe tests
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: 626 (completed), 632 (completed), 633 (completed)
- **Research Inputs**: specs/634_language_extension_directories_and_probe_tests/reports/01_language-extension-directories-probes.md
- **Artifacts**: plans/01_language-extension-directory-merge.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land `PUBLICATION_REFACTOR.md` Phase 5: merge `Syntax/{Plus,Minus,Star}Language/` and
`Semantics/{Plus,Minus,Star}Language/` into `FormalSystem/{Plus,Minus,Star}Language/`, relocate
`Metalogic/Conservativity/MinusLanguageSoundness.lean` to `MinusLanguage/Soundness.lean`, settle
three foreign-namespace Chronicle files, and move 9 files out of the `Tests/BimodalTest/` root
into `Tests/BimodalTest/Metalogic/Decidability/`. The task description's premise that
"namespaces already match" is false for the 16 `Semantics/{X}Language/*` files, so this plan
carries a **measured, file-granular namespace rename** as declared scope — see
`### Scope Decision` below. Definition of done:
`python3 scripts/measure-refactor-partitions.py namespace-audit` shows an `unrelated` bucket of 5
(plus 0-2 Chronicle files), every entry recorded; the five currently-green gate scripts stay
green; the two pre-existing reds do not worsen; `lake build` succeeds.

The phase chain is **fully linear**. Phases 2 (test-root move) and 5 (Chronicle settlement) are
*logically* independent of the language merge, but every phase mutates the same working tree and
several run `move-modules.py` or the gate harness over it, so the linear ordering reflects
shared-worktree serialization rather than a logical dependency. An implementer with a reason to
reorder 2 and 5 relative to 3-4 may do so; 1 must be first and 6 must be last.

### Scope Decision: the namespace rename is in scope

This is a deliberate scope change relative to the task description, decided here with evidence
rather than escalated, because the codebase's own convention resolves it (research Decision 1).

**Evidence.** A paths-only merge moves the `namespace-audit` `unrelated` bucket from 24 to 23 —
not to the recorded-exception set. 15 files leave the bucket, but **14 enter it**, regressing from
the *acceptable* `ancestor` bucket: the 16 `Semantics/{X}Language/*.lean` files declare
`namespace FormalSystem.Semantics`, which is an ancestor of `FormalSystem/Semantics/…` but
unrelated to `FormalSystem/{X}Language/…`. Only `PlusStateLocal.lean` and `StarStateLocal.lean`
escape, because they already open with `namespace FormalSystem.{X}Language`.

**Cost, measured at HEAD `a46f164e2`, not estimated**: 241 declarations move; **0** declaration
collisions against the syntax half; **0** short names made ambiguous; **0** fully-qualified
`FormalSystem.Semantics.<decl>` citations outside the moved set; 25 direct importers; 2 pinned
`#print axioms` declarations (4 line edits — see Phase 4). The programme already set this
precedent in the same namespace-map table: its `MinusLanguageSoundness.lean` row targets
`FormalSystem.MinusLanguage` and accepts the FQN churn as "small".

**Target shape**: flat `FormalSystem.{X}Language`, matching the syntax half and the two files that
already comply. Nested `FormalSystem.{X}Language.Semantics` was considered and rejected (a
namespace level no sibling module uses, splitting the family API for no measured benefit).

**The programme record is corrected, not the acceptance weakened** — Phase 1 amends
`PUBLICATION_REFACTOR.md`'s "namespaces unchanged" claim, its Phase 5 heading, and the "15 files"
count (the real set is 29 `.lean` files + 6 aggregators + `MinusLanguageSoundness.lean`).

### Research Integration

Every phase below derives from `reports/01_language-extension-directories-probes.md`, whose
counts were re-measured against HEAD `a46f164e2`. Findings carried into phases:

- Finding 1/2/3 → the scope decision above and Phase 4.
- Finding 4 (six aggregators map onto three; the falsified Module Invariant prose) → Phase 3.
- Finding 5 (`check-metalogic-cycles.sh` fails on *shortfall*) → Phase 3's `atomic-batch` mode.
- Finding 6 (`move-modules.py` hazards) → Phases 2 and 3 tool discipline.
- Finding 7 (README merge, `Last verified` stamps) → Phase 3.
- Finding 8 (correction: the 21 broken README links are **not** in scope) → Non-Goals.
- Finding 9 (Chronicle files) → Phase 5.
- Finding 10 (test-root move; task 429 is `not_started` with a clean `Tests/` tree and a
  `file_scope` that already names the destination) → Phase 2, all 9 files move now.
- Finding 11 (`file_scope` gaps) → Phase 1.

Two research claims are **corrected/sharpened here** against the live tree:

1. Each pinned axiom declaration appears **twice** in `scripts/check-module-invariants.sh` — once
   in the expected-output block (`:1738` `truthAt_tr`, `:1764` `plusValidIn_ofFormula_iff`) and
   once in the `#print axioms` driver block (`:1858`, `:1884`). That is **4 line edits across 2
   declarations**, not 2. Editing only the driver half leaves the check comparing against a stale
   expectation.
2. Confirmed the two declarations do live in moved files: `truthAt_tr` at
   `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean:119` (becomes
   `FormalSystem.MinusLanguage.truthAt_tr`) and `plusValidIn_ofFormula_iff` at
   `FormalSystem/Semantics/PlusLanguage/PlusValidity.lean:187` (becomes
   `FormalSystem.PlusLanguage.plusValidIn_ofFormula_iff`).

### Prior Plan Reference

No prior plan. This is round 01 for this task.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch; ROADMAP.md was not consulted. The governing
programme document is `docs/development/PUBLICATION_REFACTOR.md` §4 and Phase 5, which this task
both executes and corrects.

## Goals & Non-Goals

**Goals**:
- `FormalSystem/{Plus,Minus,Star}Language/` exist at the library root, each holding the merged
  syntax + semantics modules, one merged aggregator `.lean`, and one merged `README.md`.
- `MinusLanguage/Soundness.lean` replaces `Metalogic/Conservativity/MinusLanguageSoundness.lean`.
- The 16 semantics modules and `Soundness.lean` declare `FormalSystem.{X}Language`, not
  `FormalSystem.Semantics`.
- All 9 loose test files sit under `Tests/BimodalTest/Metalogic/Decidability/`.
- The three Chronicle files are settled (one reordered if safe, the others recorded).
- `measure-refactor-partitions.py namespace-audit` `unrelated` = 5, plus 0-2 Chronicle files, with
  every entry on the recorded-exception list.
- `lake build` green; the five green gate scripts stay green.
- No new declarations, no new theorems, no `sorry`. This task has zero proof obligations.

**Non-Goals**:
- The 21 broken `../Boneyard/` README links (`readme-lint.sh` red). **Measured: none sit in a
  language-extension README** — all 21 are in `Automation/`, `Metalogic/**` and
  `FormalSystem/README.md`. They belong to the Boneyard-relocation follow-up.
- `typst-sync-check.sh`'s `sorry-total committed=4 live=0` mismatch — the archived
  `WeakCanonical/` row, untouched here.
- The other 42 stale README date stamps tracked by task 614. Only the 3 merged READMEs are
  restamped here.
- Renaming test namespaces from `BimodalTest.{FileName}` to
  `BimodalTest.Metalogic.Decidability.{FileName}`. `measure_namespaces` filters to
  `FormalSystem.`-prefixed modules, so the test library is outside the audit entirely. Optional
  tidiness, not acceptance work; skip it.
- Physically relocating `ChronicleInstance.lean` or `ChronicleRealFlow.lean` (see Phase 5).
- Any use of `move-modules.py --namespace-map` (see Risks).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `--namespace-map` is a **repo-wide string rewrite**: a row `FormalSystem.Semantics -> FormalSystem.PlusLanguage` rewrites every occurrence across ~90 files | H | M | **Prohibited by this plan.** The rename in Phase 4 is a hand edit of 17 `namespace`/`end` pairs. Never point `--namespace-map` at `FormalSystem.Semantics`. |
| `resolve_move` prefers a directory over a same-named `.lean` sibling, silently orphaning `Syntax/{X}Language.lean` **with its citations already rewritten** — green-looking and silent | H | H | File-granular map rows only (one row per `.lean`). After every run assert `ls FormalSystem/Syntax/*Language*` and `ls FormalSystem/Semantics/*Language*` are both empty. |
| `check-metalogic-cycles.sh` asserts the upward-import set **EQUALS** a 7-line allowlist, all 7 keyed on `FormalSystem.Syntax.MinusLanguage.AxiomDischarge`. Moving that file makes all 7 a **shortfall**, and Assertion B fails on shortfall as loudly as on surplus | H | H | Phase 3 is `Commit Mode: atomic-batch`. `ALLOWLIST` is emptied to `frozenset()` and its header comment rewritten **in the same commit as the `git mv`**. The tree is expected red between the two edits; that red must not be committed separately. |
| `move-modules.py` cannot distinguish a current-location citation from a historical statement and has collapsed "from X to Y" prose into "from Y to Y" three times this run | M | H | Every tool run is `--dry-run` first. After each real run, hand-review **every non-`.lean` diff hunk** (`git diff -- '*.md' '*.sh' '*.py' '*.typ'`) before staging. All narrative prose *about this move* is written in Phases 1 and 6, after the tool has run. |
| `lake build` green is **not sufficient**: exe roots sit outside every build closure and only the build-inclusive `check-module-invariants.sh` (C25) catches a broken one | H | M | Every phase's closing gate runs `bash scripts/check-module-invariants.sh` **without** `--no-build`. `--no-build` is for fast mid-phase probing only. |
| C20 `file:line` citations shift when import lines are added or removed | M | M | Research measured **zero** non-`specs/` `file:line` citations targeting any moved file, so direct exposure is nil — but Phase 4 adds `open` lines to up to 25 importers, which shifts line numbers *within* those files. Re-run `check-module-invariants.sh` at the end of Phase 4 and fix any C20 drift it names. |
| `git-snapshot.sh` refuses when tracked modifications fall outside the task's declared `file_scope`, and 634's `file_scope` omits the 6 aggregators, the scripts, the docs and 7 of the 9 probes | M | H | Phase 1 widens `file_scope` in `specs/state.json` **before any tree change**. Do not reach for `--allow-out-of-scope` instead. |
| Hidden `open`-scope breakage across the 25 importers | M | M | `lake build` is the oracle. Measured short-name ambiguity is **0**, so failures will be missing-`open` errors with an exact fix, not silent elaboration changes. |
| `ChronicleRealExtension.lean` block reorder breaks a dependency | L | M | Bounded to one file. Attempt it; on failure fall back to recording it as an exception with a docstring sentence. Decided in-phase, no escalation. |
| Relocating a Chronicle file would change the measured cycle set and could break Assertion A's "exactly 1 cycle" | M | L | Decision: do not relocate. Record both as exceptions. |
| Waiting on a background job or monitor: agents in this run were repeatedly never woken and stalled 15-30 minutes | M | H | Run `lake build` and every gate script **in the foreground with a blocking call**. Do not background them; do not end a turn to wait on one. |
| A task-number reference leaks into a deliverable file | L | M | `PUBLICATION_REFACTOR.md`, `ORGANISATION.md`, the READMEs and the scripts are all outside `specs/**`. Cite durable anchors (filenames, section headings), never "task 634". |

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

Phases within the same wave can execute in parallel. This plan is fully sequential (see Overview
for why: shared working tree, not logical coupling).

---

### Phase 1: Widen file_scope and correct the programme record [NOT STARTED]

**Goal**: Make the declared scope match the real work and fix the programme statements this task
falsifies, before any file moves.

**Tasks**:
- [ ] Widen `file_scope` for project 634 in `specs/state.json` to add: the 6 aggregators
      (`FormalSystem/{Syntax,Semantics}/{Plus,Minus,Star}Language.lean`);
      `FormalSystem/{Syntax,Semantics,FormalSystem}.lean`; `FormalSystem/README.md`,
      `FormalSystem/Syntax/README.md`, `FormalSystem/Semantics/README.md`; `Tests/BimodalTest.lean`
      and the 7 unlisted probe files; `Tests/BimodalTest/Metalogic/Decidability/`;
      `scripts/check-metalogic-cycles.sh`, `scripts/check-module-invariants.sh`,
      `scripts/measure-refactor-partitions.py`, `scripts/module-invariants-allowlist.txt`;
      `docs/development/PUBLICATION_REFACTOR.md`, `ORGANISATION.md`.
- [ ] Append to `file_scope`; do not reassign the array wholesale.
- [ ] In `docs/development/PUBLICATION_REFACTOR.md`: correct `:92` ("namespaces unchanged") and
      the Phase 5 heading ("paths only; FQNs unchanged for the 15 files") to state that the
      language-family merge carries a namespace rename.
- [ ] Correct namespace-map row 1 (`:164`): the moved set is **29 `.lean` files** (13 syntax + 16
      semantics) plus 6 aggregators plus `MinusLanguageSoundness.lean`, not 15; target namespace
      `FormalSystem.{X}Language`. Note that "15" was the size of the *unrelated bucket*, not the
      file set.
- [ ] Extend the Phase 5 recorded-exception list with `FormalSystem/Semantics/FrameClassValidity.lean`
      (namespace `FormalSystem.ProofSystem`) and
      `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` (namespace
      `…Decidability.Periodic`). Both are outside this task's edit scope but **will** appear in the
      audit's `unrelated` bucket, so they must be recorded or acceptance cannot pass.
- [ ] Amend the Phase 5 acceptance sentence to exempt **both** aggregator-shaped test-root files:
      `Property.lean` (already exempt) and `WalkthroughAxioms.lean` (not a Decidability probe, no
      natural home in the destination directory).
- [ ] Verify no task-number reference is introduced into any file outside `specs/**`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the `file_scope` gap list of Finding 11 and the counts
"29 `.lean` files", "13 syntax", "16 semantics". Confirm before editing:
`ls FormalSystem/Syntax/{Plus,Minus,Star}Language/*.lean | wc -l` (expect 13) and
`ls FormalSystem/Semantics/{Plus,Minus,Star}Language/*.lean | wc -l` (expect 16). If either
differs, correct the number written into `PUBLICATION_REFACTOR.md` to the measured value and note
the discrepancy in the phase record.

**Files to modify**:
- `specs/state.json` - append the missing paths to project 634's `file_scope`
- `docs/development/PUBLICATION_REFACTOR.md` - `:92`, Phase 5 heading, namespace-map row 1,
  Phase 5 acceptance list and acceptance sentence

**Verification**:
- `jq '.active_projects[] | select(.project_number==634) | .file_scope' specs/state.json` lists
  every path Phases 2-6 will touch.
- `git diff -- docs/development/PUBLICATION_REFACTOR.md` — every hunk lies in prose; no
  "from Y to Y" collapse present (the tool has not run yet in this phase).
- No Lean file changed; the harness is unchanged. Spot-check with
  `bash scripts/check-metalogic-cycles.sh` (still exit 0).

---

### Phase 2: Move the 9 test-root files [NOT STARTED]

**Goal**: Relocate the 8 `*Probe.lean` files and `TableauConformance.lean` into
`Tests/BimodalTest/Metalogic/Decidability/`, leaving `Property.lean`, `WalkthroughAxioms.lean` and
`README.md` at the root. Cheap, independent green milestone.

**Tasks**:
- [ ] Re-confirm task 429 is not in flight: `jq '.active_projects[] | select(.project_number==429)
      | .status' specs/state.json` and `git status --porcelain -- Tests/`. Research measured
      `not_started` + clean tree, and 429's own `file_scope` already names the post-move path. If
      429 now shows uncommitted work under `Tests/`, exclude `TemporalWitnessProbe.lean` from this
      pass and record the exclusion; otherwise move all 9.
- [ ] Write a file-granular module map (9 rows) to the scratchpad, e.g.
      `BimodalTest.TemporalWitnessProbe -> BimodalTest.Metalogic.Decidability.TemporalWitnessProbe`.
- [ ] `python3 scripts/move-modules.py --module-map <map> --dry-run` and read the full report.
- [ ] Run for real. Verify `Tests/BimodalTest/Metalogic/Decidability/` holds the 9 files and the
      test root holds only `Property.lean`, `WalkthroughAxioms.lean`, `README.md` and the
      `Metalogic/` subtree.
- [ ] Confirm `Tests/BimodalTest.lean:31-39` imports were rewritten to the new module paths.
- [ ] Hand-review every non-`.lean` diff hunk, and the module-docstring cross-citations the probes
      make to each other (`TemporalWitnessProbe.lean:12,596`, `RayRegionProbe.lean:12`,
      `BoxNegPreservationProbe.lean:20,76`, `BoxNegReachabilityProbe.lean:12`,
      `CrossWorldPropagationProbe.lean:22,24`, `UntlSnceCopyProbe.lean:14`) for "from Y to Y"
      collapse.
- [ ] Do not rename the `BimodalTest.{FileName}` namespaces (Non-Goal).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts exactly 9 files move and exactly 3 entries remain at the
test root. Confirm with `ls Tests/BimodalTest/*.lean Tests/BimodalTest/*.md` before and after; the
"after" listing must be exactly `Property.lean`, `WalkthroughAxioms.lean`, `README.md`.

**Files to modify**:
- `Tests/BimodalTest/{BoxNegPreservation,BoxNegReachability,BoxSpread,CrossWorldPropagation,RayRegion,RegionGate,TemporalWitness,UntlSnceCopy}Probe.lean` - moved
- `Tests/BimodalTest/TableauConformance.lean` - moved
- `Tests/BimodalTest.lean` - import paths rewritten

**Verification**:
- `lake build` green, run in the **foreground**.
- `bash scripts/check-evidence-probes.sh` exit 0 (the 4 wired probes still compile).
- `bash scripts/check-module-invariants.sh` (build-inclusive, **no** `--no-build`) — ALL CHECKS
  PASSED.
- `readme-lint.sh` scopes to `FormalSystem/` only, so no README is needed for the new test
  directory.
- Commit at green: `task 634 phase 2: move test-root probes to Metalogic/Decidability`.

---

### Phase 3: Scripted path merge of Plus, Minus and Star [NOT STARTED]

**Goal**: Land the six-directory-into-three merge, the `MinusLanguageSoundness.lean` relocation,
the three aggregator merges and the three README merges — with the
`check-metalogic-cycles.sh` allowlist edit in the **same commit**.

**Tasks**:
- [ ] Write a file-granular module map: one row per `.lean` under the six source directories (29
      rows), one for `FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness ->
      FormalSystem.MinusLanguage.Soundness`, and three rows for the **syntax** aggregators
      (`FormalSystem.Syntax.PlusLanguage -> FormalSystem.PlusLanguage`, likewise Minus and Star).
      The syntax-aggregator rows work only because the file rows have already consumed the
      directory, so `resolve_move` falls through to the `.lean` branch.
- [ ] **Do not** add a `--namespace-map`. **Do not** add rows for the three *semantics*
      aggregators — they collide with the syntax aggregators' destination and are hand-merged
      below.
- [ ] `--dry-run` first; read the full report.
- [ ] Run for real with `--no-verify` (the harness is expected red mid-phase).
- [ ] Assert no orphans: `ls FormalSystem/Syntax/*Language*` and
      `ls FormalSystem/Semantics/*Language*` — both must be empty of the merged names.
- [ ] Hand-merge each `FormalSystem/Semantics/{X}Language.lean` into the moved
      `FormalSystem/{X}Language.lean`, then `git rm` the three semantics aggregators.
- [ ] Rewrite the **Module Invariant** prose the merge falsifies by construction
      (`Syntax/PlusLanguage.lean:47-54` and its Minus/Star twins: *"Nothing under
      `FormalSystem/PlusLanguage/` imports anything from `FormalSystem/Semantics/`"*). It is
      prose-only — no mechanical check enforces it — but it must be rewritten, not left to rot.
- [ ] Rewrite `Semantics/PlusLanguage.lean:20-21`'s *"The declarations stay in the
      `FormalSystem.Semantics` namespace; only the module paths are grouped here"* — Phase 4
      overturns it.
- [ ] Merge the 6 READMEs into 3 (`Syntax/{X}Language/README.md` + `Semantics/{X}Language/README.md`
      → `FormalSystem/{X}Language/README.md`) and `git rm` the superseded pair. Preserve the
      `## Paper-label correspondence` section at `Syntax/StarLanguage/README.md:103`.
- [ ] Set each merged README's `Last verified: YYYY-MM-DD` stamp to the merge commit's date
      (`readme-lint.sh` Check 4 compares it against `git log -1 --format=%cs` for the directory).
- [ ] Update `FormalSystem/Syntax/README.md` and `FormalSystem/Semantics/README.md` to drop the
      merged subdirectory entries; update `FormalSystem/README.md` to gain the three new top-level
      directories.
- [ ] Update the subdirectory-layout prose at `FormalSystem/Syntax.lean:28-29,48,89` and
      `FormalSystem/Semantics.lean:42-46,121-170`; check `FormalSystem/FormalSystem.lean`'s
      aggregator imports.
- [ ] Empty `ALLOWLIST` in `scripts/check-metalogic-cycles.sh` to `frozenset()` and rewrite the
      header comment at `:156-159` plus the script's docstring block — the allowlist's 7 lines all
      key on `FormalSystem.Syntax.MinusLanguage.AxiomDischarge`, whose new top-level directory sits
      outside `LAYERS`, so `layer_of` returns `None` and all 7 become a shortfall.
- [ ] Hand-review every non-`.lean` diff hunk for "from Y to Y" collapse before staging.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts 29 `.lean` rows + 1 Soundness row + 3 syntax-aggregator
rows = 33 map rows, and 6 READMEs collapsing to 3. Confirm the 29 by listing the six source
directories immediately before writing the map; confirm the README count with
`ls FormalSystem/{Syntax,Semantics}/{Plus,Minus,Star}Language/README.md | wc -l` (expect 6). A
mismatch means a dependency task landed a new file — widen the map, do not proceed with a stale
one.

**Files to modify**:
- The 29 `.lean` files under the six source directories - moved to `FormalSystem/{X}Language/`
- `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` - moved to
  `FormalSystem/MinusLanguage/Soundness.lean`
- `FormalSystem/Syntax/{Plus,Minus,Star}Language.lean` - moved, then hand-merged
- `FormalSystem/Semantics/{Plus,Minus,Star}Language.lean` - merged in, then `git rm`
- 6 READMEs → 3 merged, with refreshed date stamps
- `FormalSystem/{Syntax,Semantics,FormalSystem}.lean`, `FormalSystem/README.md`,
  `FormalSystem/{Syntax,Semantics}/README.md` - layout prose
- `scripts/check-metalogic-cycles.sh` - `ALLOWLIST` emptied, header and docstring rewritten

**Verification**:
- `lake build` green, foreground.
- `bash scripts/check-metalogic-cycles.sh` exit 0 — Assertion A still finds exactly 1 cycle,
  Assertion B's set now equals the empty allowlist.
- `bash scripts/check-module-invariants.sh` (build-inclusive) — ALL CHECKS PASSED.
- `bash scripts/readme-lint.sh` — still 21 broken references (unchanged), and **no new** STALE
  DATE finding for the three merged READMEs.
- `bash scripts/check-copyright-headers.sh --strict` and `bash scripts/check-paper-definitions.sh`
  exit 0.
- **One commit** for the whole batch: `task 634 phase 3: merge language-extension directories`.
  Intermediate per-file states are expected red and must not be committed.

---

### Phase 4: Rename the semantics namespaces to FormalSystem.{X}Language [NOT STARTED]

**Goal**: Move the 241 declarations in the 16 moved semantics modules plus `Soundness.lean` out of
`FormalSystem.Semantics` and into flat `FormalSystem.{X}Language`, so the audit classifies them as
equal-or-descendant.

**Tasks**:
- [ ] Hand-edit the `namespace`/`end` pair in each of the 17 files:
      `FormalSystem.Semantics` → `FormalSystem.{X}Language` for the matching X. **Never** use
      `--namespace-map`.
- [ ] Include the *second* `namespace FormalSystem.Semantics` block inside
      `PlusStateLocal.lean` (≈lines 210-410) and the matching block in `StarStateLocal.lean` —
      otherwise those two files stay split across two namespaces for no reason.
- [ ] Build; for each missing-identifier error, add `open FormalSystem.{X}Language` to the
      importer. Measured short-name ambiguity is 0, so every failure has an exact fix. Work through
      the direct-importer set (25 files, incl. `FormalSystem/FormalSystem.lean`,
      `Metalogic/Conservativity{,/Plus,/Star}/*.lean`, `Metalogic/Independence/*.lean`,
      `Metalogic/Deterministic/Validity.lean`,
      `Semantics/{DeterministicBridge,StateLocalTransfer}.lean`,
      `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`).
- [ ] Update the two pinned axiom declarations in `scripts/check-module-invariants.sh` at **all
      four** sites: `FormalSystem.Semantics.truthAt_tr` → `FormalSystem.MinusLanguage.truthAt_tr`
      in the expected-output block (≈`:1738`) **and** the `#print axioms` driver (≈`:1858`);
      `FormalSystem.Semantics.plusValidIn_ofFormula_iff` →
      `FormalSystem.PlusLanguage.plusValidIn_ofFormula_iff` at ≈`:1764` **and** ≈`:1884`. Editing
      only the driver half leaves the check comparing against a stale expectation. Do **not** touch
      the other `FormalSystem.Semantics.*` baselines (`galoisClosed_*`, `validOn_nextTop_iff`) —
      those declarations are not in the moved set.
- [ ] Re-run `check-module-invariants.sh` and fix any C20 `file:line` citation drift caused by the
      added `open` lines.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts 17 files renamed, 241 declarations moved, 25 direct
importers, 0 ambiguities, 0 external FQN citations, and 2 pinned declarations at 4 sites. Confirm
before editing: `grep -rl 'namespace FormalSystem.Semantics' FormalSystem/{Plus,Minus,Star}Language/
FormalSystem/MinusLanguage/Soundness.lean` (expect 17 paths, with two files matching twice), and
`grep -rn 'FormalSystem\.Semantics\.' --include='*.lean' --include='*.sh' . | grep -v specs/`
to re-confirm the external-FQN-citation count is 0 for moved declarations. If a non-zero count
appears, rewrite those citations in this phase rather than deferring.

**Files to modify**:
- The 16 `FormalSystem/{Plus,Minus,Star}Language/*` semantics modules - `namespace`/`end` pairs
- `FormalSystem/MinusLanguage/Soundness.lean` - `namespace`/`end` pair
- Up to 25 direct importers - added `open FormalSystem.{X}Language`
- `scripts/check-module-invariants.sh` - 4 lines across 2 pinned declarations

**Verification**:
- `lake build` green, foreground.
- `bash scripts/check-module-invariants.sh` (build-inclusive) — ALL CHECKS PASSED, both axiom
  baselines matching under their new names.
- `python3 scripts/measure-refactor-partitions.py namespace-audit` — the 14 previously-regressing
  semantics files and `Soundness.lean` are now `equal-or-descendant`; `unrelated` is down to the
  recorded set plus the Chronicle files Phase 5 settles.
- Commit each green sub-step (per language family is a natural grain).

---

### Phase 5: Settle the three Chronicle files [NOT STARTED]

**Goal**: Remove the Chronicle files from the `unrelated` bucket, by reorder where free and by
recorded exception where relocation would be harmful.

**Tasks**:
- [ ] `Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (1164 lines, 21 declarations,
      interleaved `FormalSystem.Metalogic.Bundle` 299-818 → `BXCanonical.Chronicle` 820-946 →
      `Bundle` 948-1164): check whether the Bundle material at 299-818 is a prerequisite of
      820-946. If it is not, hoist the 820-946 block above it so the file's **first** namespace
      matches its directory — this classifies the file as equal-or-descendant with **zero FQN
      churn**, the cheapest genuine fix in this task.
- [ ] If the hoist breaks a dependency, revert it and record the file as an exception with a
      docstring sentence naming the interleaving as the reason. Decide in-phase; do not escalate.
- [ ] Record `Metalogic/WeakCanonical/DenseModelSurgery/ChronicleInstance.lean` and
      `Metalogic/WeakCanonical/RealModel/ChronicleRealFlow.lean` as exceptions with a docstring
      sentence each. **Do not relocate them**: both are edge sources in the single sanctioned
      `WeakCanonical → BXCanonical` directory cycle that `check-metalogic-cycles.sh` Assertion A
      asserts as "exactly 1 cycle", and moving either would change the measured cycle set for no
      acceptance gain. Neither is in `EXPRESSIVENESS_SET`, so Phase 6 of the programme does not
      pre-empt this.
- [ ] Add matching docstring sentences to `FormalSystem/Semantics/FrameClassValidity.lean`
      (namespace `FormalSystem.ProofSystem`, a duplication its docstring explains but whose
      *namespace* it does not) and `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean`
      (namespace `…Decidability.Periodic`, a split pair, same gap). Phase 1 added them to the
      recorded-exception list; this is the docstring half.
- [ ] Add each settled file to `PUBLICATION_REFACTOR.md`'s Phase 5 recorded-exception list if
      Phase 1's edit did not already cover it.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the `ChronicleRealExtension.lean` block boundaries
(299-818 / 820-946 / 948-1164) and the declaration counts 21/15/7. Line numbers may have drifted
since research. Re-derive the block boundaries with `grep -n '^namespace\|^end ' ` on the file
before attempting the hoist; do not hoist against stale line numbers.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` - block reorder or
  docstring exception
- `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/ChronicleInstance.lean` - docstring
- `FormalSystem/Metalogic/WeakCanonical/RealModel/ChronicleRealFlow.lean` - docstring
- `FormalSystem/Semantics/FrameClassValidity.lean` - docstring
- `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` - docstring
- `docs/development/PUBLICATION_REFACTOR.md` - recorded-exception list, if not fully covered by
  Phase 1

**Verification**:
- `lake build` green, foreground.
- `bash scripts/check-metalogic-cycles.sh` exit 0 — Assertion A still reports **exactly 1** cycle.
- `bash scripts/check-module-invariants.sh` (build-inclusive) — ALL CHECKS PASSED.
- Every remaining `unrelated` entry has a docstring sentence explaining its namespace.

---

### Phase 6: Refresh counts and docs; run acceptance [NOT STARTED]

**Goal**: Bring the measurement scripts and layer documentation in line with the new tree, then
run the full acceptance gate.

**Tasks**:
- [ ] Refresh `scripts/measure-refactor-partitions.py`'s docstring counts at `:61-64` — the
      "24 unrelated / 15 language files" figures this task invalidates.
- [ ] Prune the three now-resolving `FormalSystem.{Plus,Minus,Star}Language` entries from
      `scripts/module-invariants-allowlist.txt` (lines ≈28-49), including their explanatory
      comments. C5 reports stale entries as INFO, not FAIL, so this is tidiness — but leaving them
      misrepresents the tree.
- [ ] Add an explicit note to `ORGANISATION.md`'s layer table that the extension-language
      directories sit **outside** the core stack and are therefore absent from `LAYERS`. Without
      it their omission reads as an oversight. Flag the measurement consequence: once the three
      directories sit at the library root, `layer_of` returns `None` for them and every import into
      and out of them becomes invisible to the upward-edge measurement —
      `Metalogic → MinusLanguage` and `Semantics/StateLocalTransfer.lean →
      PlusLanguage.PlusStateLocal` both stop being measured. No harness check catches this; the
      documentation is the only record.
- [ ] Review all narrative prose written about this move across `PUBLICATION_REFACTOR.md`,
      `ORGANISATION.md` and the merged READMEs for "from Y to Y" collapse introduced by the tool
      runs in Phases 2 and 3.
- [ ] Confirm no task-number reference leaked into any file outside `specs/**`.
- [ ] Run the full acceptance gate (below) in the foreground.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the acceptance figure `unrelated` = 5
(`ForMathlib/Order/PFilter.lean`, `Theorems/DeductionTheorem.lean`, `Tactic/Meta.lean`,
`Semantics/FrameClassValidity.lean`, `Decidability/BiLasso/Periodic.lean`) plus 0-2 Chronicle
files depending on Phase 5's outcome. Confirm by running the audit and listing the bucket by name,
not by count alone. If an unexpected name appears, it must be either fixed or recorded before the
phase closes — a count that happens to match with different members is not acceptance.

**Files to modify**:
- `scripts/measure-refactor-partitions.py` - docstring counts at `:61-64`
- `scripts/module-invariants-allowlist.txt` - prune 3 resolved entries
- `ORGANISATION.md` - layer-table note
- `docs/development/PUBLICATION_REFACTOR.md` - final prose review
- The 3 merged READMEs - final prose review

**Verification**:
- `python3 scripts/measure-refactor-partitions.py namespace-audit` — `unrelated` bucket lists only
  recorded exceptions, **by name**.
- `lake build` green, foreground.
- `bash scripts/check-module-invariants.sh` (build-inclusive) — ALL CHECKS PASSED.
- `bash scripts/check-evidence-probes.sh`, `check-copyright-headers.sh --strict`,
  `check-metalogic-cycles.sh`, `check-paper-definitions.sh` — all exit 0.
- `bash scripts/readme-lint.sh` and `bash scripts/typst-sync-check.sh` — still exit 1, with the
  **same** pre-existing findings (21 broken references; `sorry-total committed=4 live=0` plus 2
  mismatches). Not worse.
- Commit: `task 634: complete implementation`.

---

## Lean Challenge Statements

Not applicable. This task relocates modules and renames namespaces; it introduces no new
declaration, no theorem and no `sorry`, so the `- **Goals**:` bullets name **zero** identifiers and
the Challenge identifier set is correspondingly empty. No ```lean block is emitted, and no
Challenge module should be snapshotted for this plan. Verification is `lake build` plus the seven
gate scripts, not a proof obligation.

## Testing & Validation

- [ ] `lake build` green at the end of every phase, run in the foreground.
- [ ] `bash scripts/check-module-invariants.sh` (build-inclusive, **not** `--no-build`) — ALL
      CHECKS PASSED. This is the only check that catches a broken exe root.
- [ ] `bash scripts/check-metalogic-cycles.sh` exit 0 — Assertion A exactly 1 cycle, Assertion B
      set equals the (now empty) allowlist.
- [ ] `bash scripts/check-evidence-probes.sh` exit 0 (4 wired probes compile).
- [ ] `bash scripts/check-copyright-headers.sh --strict` exit 0.
- [ ] `bash scripts/check-paper-definitions.sh` exit 0 (43 definitions unchanged).
- [ ] `bash scripts/readme-lint.sh` — exit 1 with exactly the pre-existing 21 broken references
      and no new STALE DATE finding.
- [ ] `bash scripts/typst-sync-check.sh` — exit 1 with exactly the pre-existing mismatches.
- [ ] `python3 scripts/measure-refactor-partitions.py namespace-audit` — `unrelated` = 5 (+0-2
      Chronicle), every member recorded, verified by name.
- [ ] `ls FormalSystem/Syntax/*Language*` and `ls FormalSystem/Semantics/*Language*` — no orphans.
- [ ] `git diff` hand-review of every non-`.lean` hunk after each `move-modules.py` run.

## Artifacts & Outputs

- `specs/634_language_extension_directories_and_probe_tests/plans/01_language-extension-directory-merge.md` (this file)
- `specs/634_language_extension_directories_and_probe_tests/summaries/01_*-summary.md` (written at
  implementation completion)
- `FormalSystem/{Plus,Minus,Star}Language/` — three merged directories, each with modules, one
  aggregator `.lean` and one `README.md`
- `Tests/BimodalTest/Metalogic/Decidability/` — 9 relocated test files
- Updated: `docs/development/PUBLICATION_REFACTOR.md`, `ORGANISATION.md`,
  `scripts/check-metalogic-cycles.sh`, `scripts/check-module-invariants.sh`,
  `scripts/measure-refactor-partitions.py`, `scripts/module-invariants-allowlist.txt`

## Rollback/Contingency

Each phase ends at a committed green state (Phase 3 as one atomic batch), so the ordinary recovery
is `git revert` of the offending phase commit — no working-tree destruction needed.

If a phase must be abandoned mid-flight with uncommitted changes, this is a genuine rollback
scenario, not a routine checkpoint: follow `context/contracts/recovery.md`'s rollback rung for the
exact `git-snapshot.sh` invocation shape, including its out-of-scope override flag for the
deliberate whole-tree case. Phase 1 widens `file_scope` precisely so the default-mode snapshot is
not refused; reach for `--allow-out-of-scope` only for an intentional whole-tree rollback.

Phase-specific contingencies:
- **Phase 3 red persists after the allowlist edit**: the batch is not committable. Diagnose with
  `python3 scripts/measure-refactor-partitions.py upward-edges` to derive the true upward set —
  the allowlist must *equal* it, so a non-empty result means some other file now contributes an
  upward edge and the allowlist should hold that instead of being emptied.
- **Phase 4 build failures multiply beyond the measured 25 importers**: stop, re-run the
  external-FQN-citation measurement, and treat a non-zero result as the real scope. Do not paper
  over it with a repo-wide rewrite.
- **Phase 5 hoist breaks a dependency**: revert the hoist, record the file as an exception. This
  costs one entry in the `unrelated` bucket and is an accepted outcome, not a failure.
