# Implementation Plan: Consolidate the Two Boneyard Archives

- **Task**: 451 - Consolidate the two Boneyard archives into a single tree
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours
- **Dependencies**: None
- **Research Inputs**: specs/451_consolidate_boneyard_archives/reports/01_consolidate-boneyard-archives.md
- **Artifacts**: plans/01_consolidate-boneyard-archives.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Consolidate `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/` (63 files) into the top-level
`FormalSystem/Boneyard/` tree using `git mv` exclusively, then add the missing infrastructure that
keeps an uncompiled archive honest: a per-import resolution checker (C11) wired into
`scripts/check-module-invariants.sh`, a waiver file for unrepairable imports, per-approach READMEs
for the Kamp region, and single-sourced archive counts. The move itself is build-neutral (nothing
live imports either tree, namespaces are not path-derived, and both tooling filters match on the
`Boneyard` name glob), so every gate that is green today must still be green at the end.

Definition of done: one archive tree, 0 unwaived dangling imports across it, C11 shipped and
enforcing, `check-module-invariants.sh` ALL CHECKS PASSED, `readme-lint.sh` PASS, `lake build` and
`lake build BimodalTest` both exit 0 with output unchanged, and `git log --follow` resolving
through every move.

### Research Integration

The research report re-measured every quantity in the charter and four findings reshape the work:

1. **The archive is already rotten.** 65 import lines inside the two archives name modules that do
   not exist on disk *today*. Deliverable (d)'s checker cannot be green on arrival. Split: 48
   Category A (repairable — target file exists at a different path) and 17 Category B (6 modules
   deleted outright in commit `6c3419a4f`, unrepairable without reviving deleted code). This plan
   repairs Category A and waives Category B with the commit SHA as the recorded reason, so C11
   ships enforced-and-green rather than behind an `ENFORCE_C11=0` flag the script's own comment
   discourages ever flipping back.
2. **The move-broken rewrite set is 55 lines, not 52** — three files in `Boneyard/RabinovichPath/`
   import into the Kamp archive.
3. **`file_scope` is too narrow.** Nine files outside it must change; two of them
   (`FormalSystem/README.md:19`, `Kamp/README.md:65`) turn `readme-lint.sh` RED via broken
   markdown links. Phase 1 extends `file_scope` before any implementation.
4. **The charter's baselines are stale and its inherited-RED list is obsolete.** Live count is 394
   `FormalSystem` `.lean` / 448 total, not 373. `lake build`, `lake build BimodalTest`,
   `check-module-invariants.sh`, and `readme-lint.sh` are all currently GREEN. There is no
   inherited red to "confirm is no worse" — **any red after this task is caused by this task.**

The three open questions the report left to the planner are resolved here as follows:

- **(b) Option A or B**: **Option B** — a physical `FormalSystem/Boneyard/Kamp/` umbrella holding
  `KampWeakCanonical/` (the incoming 63, keeping deliverable (a)'s directory name) plus the four
  existing Kamp-facing top-level directories. Verified during planning: `grep` for
  `^import FormalSystem.Boneyard.{KampBypassArchive,KampNegationClosure,RabinovichPath,VecEADecomposition,MergedBracketQuarantine}`
  across all `.lean` under `FormalSystem/` and `Tests/` returns **zero** hits, so moving those 22
  files breaks no currently-resolving import. Option B is import-neutral and is what the charter's
  "not two sibling directories that each look authoritative" actually asks for.
  `MergedBracketQuarantine/` (2 borderline Kamp edges, 1 file) stays where it is — see Non-Goals.
- **Category B**: waive-and-enforce now.
- **The 7 comment-only `Kamp/Boneyard/` mentions in 3 live `.lean` files**: leave untouched
  (honors the "do not modify any live module" non-goal), and record the decision in the
  consolidated README.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation was requested in the delegation context (`roadmap_flag` absent). No
ROADMAP.md phases are included.

## Goals & Non-Goals

**Goals**:

- One archive tree rooted at `FormalSystem/Boneyard/`, with a coherent `Kamp/` region, produced
  entirely by `git mv` so `git log --follow` resolves through every move.
- Every import line in every archived file resolves to a file on disk, or is explicitly waived
  with a recorded reason.
- A new C11 check in `scripts/check-module-invariants.sh` enforcing that invariant from day one,
  with stale-waiver reporting on the C5 model.
- B0 updated to assert 1 Boneyard directory, and its `:20-22` header comment rewritten.
- Per-approach documentation for the Kamp region matching the top-level archive's convention: one
  subdirectory per abandoned approach, each with a README recording what it was, why it died, what
  revival would require, and **every file's original path**.
- Archive counts stated in exactly one place, with every other location linking to it.

**Non-Goals**:

- Do NOT revive, repair, or compile any archived code. Archived files stay uncompiled and outside
  the import closure.
- Do NOT modify any live `.lean` module. If one turns out to need a change, stop and report. (The
  7 comment-only path mentions in `Kamp/DedekindINF.lean`, `Kamp/NfMultiAnchorBridge.lean`, and
  `Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` are deliberately left untouched under this
  non-goal.)
- Do NOT delete anything, including the six deleted-module imports — those are waived, not removed.
- Do NOT add the archive to `lakefile.lean` in any form.
- Do NOT move `MergedBracketQuarantine/` into the Kamp umbrella. Its 2 Kamp edges are borderline
  and its subject matter is bracket quarantine, not Kamp; leaving it out is recorded in writing in
  the region README.
- Do NOT write the 6 missing **non-Kamp** top-level READMEs (`StaviDiscretePath/`,
  `DeadConvergenceProof/`, `FMPVariants/`, `SoundnessVariants/`, `BXCanonicalQuasimodel/`,
  `RestrictedMCSDeferral/`). Deliverable (g) targets the Kamp archive; these are a pre-existing gap
  in the top-level archive and belong in a follow-up task. Report them at completion.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `git mv` degrades to delete+add, losing history | H | L | Move-only phase with no content edits to any moved `.lean`; gate on `git status --find-renames` showing `R100` for the full move set before committing; `git log --follow` sampled per moved subdirectory |
| Option B breaks a currently-resolving import into the 4 relocated directories | H | L | Pre-verified zero inbound resolving imports (planning-time grep, re-run in Phase 1 as a Scope Hypothesis); Phase 3's resolution scan catches any miss |
| C11 written with a naive `^import` grep produces 15 false positives from block-comment continuation lines and a fenced code block | M | H | Reuse C4's regex `^import\s+((?:FormalSystem\|BimodalTest)(?:\.[A-Za-z0-9_]+)*)\s*$` with `re.M`; do NOT widen it. Phase 5 asserts the real counts (364 top / 149 Kamp), never the naive ones (366 / 162) |
| A Category A repair points at an ambiguous module name matching two files | M | M | Resolution scan must find exactly one target file per import; ambiguity is a hard stop, recorded and waived rather than guessed. `FormalSystem.Metalogic.Completeness` is already flagged ambiguous in the research and is expected to land in the waiver file |
| `readme-lint.sh` goes RED between the move and the README phases | M | H | Phase 2 repoints the two gating links in the same atomic commit as the move; the fuller README rewrite happens later without ever leaving the gate red |
| Phase 6's regroup of the 35 flat files breaks further imports | M | M | C11 is already enforcing by Phase 6, so any new dangler fails the gate immediately rather than silently |
| Hand-recopied counts drift again | M | M | State each count once in `FormalSystem/Boneyard/README.md`, cite `check-module-invariants.sh` B0/C7 as the live source, and link from everywhere else |

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
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |
| 10 | 10 | 9 |

Phases within the same wave can execute in parallel. This migration is inherently sequential: each
phase either changes module paths that the next phase's gate resolves against, or installs the
gate that the next phase relies on.

---

### Phase 1: Baseline capture and scope extension [COMPLETED]

**Goal**: Freeze the pre-move ground truth so every later "unchanged" assertion is a real
comparison, and widen `file_scope` so the implementer does not hit a scope wall mid-task.

**Tasks**:

- [x] Create `specs/451_consolidate_boneyard_archives/baselines/` and record, verbatim:
      `lake build`, `lake build BimodalTest`, `bash scripts/check-module-invariants.sh`, and
      `bash scripts/readme-lint.sh` (stdout+stderr and exit code each).
- [x] Re-measure and record *(deviation: altered — measured 553/397/53/450, 3 higher than the plan's 550/394/53/448 because concurrent tasks added live files; archive counts 156 / 93+59,019 / 63+29,256 match exactly. See baselines/MEASURED.md D2)*: total `FormalSystem/**/*.lean` (expect 550), live `FormalSystem`
      (394), live `Tests` (53), live total (448), archived (156), `FormalSystem/Boneyard/`
      (93 files / 59,019 lines), `.../Kamp/Boneyard/` (63 / 29,256).
- [x] Re-run the dangling-import census *(deviation: altered — 65 total confirmed, but the A/B split measured 47/18 not 48/17: `FormalSystem.Metalogic.Completeness` is ambiguous across 4 files and belongs in Category B, which the plan already listed in the waiver seed. See MEASURED.md D3)* with a `FormalSystem|BimodalTest`-prefixed regex and record
      the per-archive and per-category counts (expect 65 total; 48 Category A, 17 Category B across
      6 modules).
- [x] Re-run the Option B safety grep *(0 hits, confirmed)*:
      `grep -rhoE "^import FormalSystem\.Boneyard\.(KampBypassArchive|KampNegationClosure|RabinovichPath|VecEADecomposition)(\.[A-Za-z0-9_]+)*" --include=*.lean FormalSystem/ Tests/`
      and confirm it is empty. If it is not, stop and report before moving anything.
- [x] Extend `active_projects[].file_scope` for task 451 in `specs/state.json` (append via `+=`,
      never wholesale assignment) with: `FormalSystem/README.md`,
      `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/WeakCanonical/README.md`,
      `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md`,
      `docs/development/MODULE_INVARIANTS.md`, `scripts/check-copyright-headers.sh`,
      `scripts/add-copyright-headers.sh`, `scripts/typst-sync-check.sh`, `typst/SYNC-MAP.md`,
      `scripts/boneyard-import-waivers.txt`.
- [x] Run `bash .claude/scripts/generate-todo.sh`.

**MEASURED BASELINE DIVERGENCE** (Phase 1): `readme-lint.sh` is **RED at baseline**, not green as
the plan's Research Integration item 4 asserts. It exits 1 with `RESULT: FAIL (7 missing READMEs,
5 broken references)`, none Boneyard-related. It also carried a latent `set -euo pipefail` bug that
aborted it mid-Check-3 on any link-less README, hiding its own summary; fixed in-scope
(`scripts/readme-lint.sh` is in `file_scope`) by `{ grep ... || true; }`. **Every later phase's
`readme-lint.sh PASS` criterion is therefore downgraded to "no worse than baseline": 7 missing,
<= 5 broken.** Full record: `baselines/MEASURED.md` (divergences D1-D4).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Every count above (550/394/53/448/156, 93/59,019, 63/29,256, 65 = 48 + 17
across 6 modules, 55 move-broken lines, zero inbound imports into the 4 relocated directories) is a
research-time hypothesis, not a fact. Confirm each by direct measurement in this phase and record
the measured value in the baselines directory. Any divergence larger than rounding is reported
before Phase 2 begins, and the later phases' gate numbers are adjusted to the measured values.

**Files to modify**:

- `specs/state.json` - append 10 paths to task 451's `file_scope`
- `specs/TODO.md` - regenerated, not hand-edited
- `specs/451_consolidate_boneyard_archives/baselines/*` - new, recorded gate output

**Verification**:

- All four baseline commands exit 0 and their output is on disk.
- `jq -e '.active_projects[]|select(.project_number==451)|.file_scope|length >= 14' specs/state.json`
- The Option B safety grep is empty.

---

### Phase 2: Consolidate the archive trees [COMPLETED]

**Goal**: One archive tree. All 85 files relocated by `git mv` with zero content edits to any
moved `.lean`, with B0 and the two gating README links updated in the same commit so no gate is
left red.

**Tasks**:

- [x] `mkdir -p FormalSystem/Boneyard/Kamp`
- [x] `git mv FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard FormalSystem/Boneyard/Kamp/KampWeakCanonical`
      (63 files; preserves `ZetaProbes/`, `NfMultiAnchorBridgeRetired/`, `ExpressiveCompleteness/`,
      `Separation/` with `Separation/DedekindZ/` and `Separation/Hierarchy/`, plus 35 flat root
      files and the tree README).
- [x] `git mv` each of `FormalSystem/Boneyard/{KampBypassArchive,KampNegationClosure,RabinovichPath,VecEADecomposition}`
      into `FormalSystem/Boneyard/Kamp/` (22 files).
- [x] Confirm `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/` no longer exists.
- [x] Write a short stub `FormalSystem/Boneyard/Kamp/README.md` *(deviation: altered — only `KampWeakCanonical/` and `VecEADecomposition/` are linked; the other three have no README until Phase 7, so they are named in plain text rather than shipped as broken links)* naming the region and pointing at
      the five subdirectories. Full region index is Phase 7.
- [x] In `scripts/check-module-invariants.sh`: change `2` to `1` in all three B0 places (the
      `-eq 2` test, "covers exactly 2 directories", "expected 2 Boneyard directories"). Do NOT
      touch `live_lean()`'s `-not -path '*/Boneyard/*'` glob — keeping the name glob is what makes
      B0's count assertion a regression detector if a second archive ever reappears.
- [x] Rewrite the `:20-22` header comment block: the two-Boneyard warning is obsolete, and its
      "~27k archived lines" figure was already wrong (actual 29,256).
- [x] Repoint `FormalSystem/README.md:19` and
      `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md:65` at the new archive location so
      `readme-lint.sh`'s link resolution stays green. Minimal link-target edits only; the prose
      rewrite is Phase 9.

**MEASURED** (Phase 2): 90 renames, every one `R100`, zero delete+add pairs. The plan's "85"
counts `.lean` only; 5 `README.md` files ride along in the same directories. B0 PASS at 1
directory, note reads "excluded 156 archived .lean files (553 total -> 397 live)" (553/397 rather
than the plan's 550/394 -- see MEASURED.md D2). `readme-lint.sh` output is **byte-identical** to
the Phase 1 baseline (7 missing, 5 broken; both link repoints resolve). `check-module-invariants.sh
--no-build` -> ALL CHECKS PASSED (C3, C4 at 1388 lines, C5 with 4 allowlisted, C6, C8, C9, C10).
The authoritative full `lake build` is deferred to Phase 10: several other agents held the Lake
lock throughout this phase, and this phase's diff (renames of uncompiled files, one bash script,
two markdown link targets) cannot reach the import closure.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 85 files move (63 + 22). Confirm with
`git status --porcelain --find-renames | grep -c '^R'` before committing. The moved `.lean` files
carry zero content edits, so every rename must be `R100`; a similarity below 100 on any `.lean`
means content was touched and must be reverted.

**Files to modify**:

- `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/**` -> `FormalSystem/Boneyard/Kamp/KampWeakCanonical/**` (63, moved)
- `FormalSystem/Boneyard/{KampBypassArchive,KampNegationClosure,RabinovichPath,VecEADecomposition}/**` -> `FormalSystem/Boneyard/Kamp/**` (22, moved)
- `FormalSystem/Boneyard/Kamp/README.md` - new stub
- `scripts/check-module-invariants.sh` - B0 `2`->`1` (3 places), `:20-22` header comment
- `FormalSystem/README.md` - line 19 link target only
- `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md` - line 65 link target only

**Verification**:

- `git status --porcelain --find-renames` shows 85 renames, `R100` on every `.lean`, zero
  delete+add pairs.
- `git log --follow` resolves through the move for one sampled file from each of:
  `KampWeakCanonical/ZetaProbes/`, `KampWeakCanonical/NfMultiAnchorBridgeRetired/`,
  `KampWeakCanonical/Separation/`, `KampWeakCanonical/Separation/DedekindZ/`,
  `KampWeakCanonical/Separation/Hierarchy/`, `KampWeakCanonical/ExpressiveCompleteness/`,
  `KampWeakCanonical/` root, and `KampBypassArchive/`.
- `find FormalSystem -type d -name Boneyard | wc -l` is 1.
- `lake build` exits 0 and its output matches the Phase 1 baseline.
- `lake build BimodalTest` exits 0.
- `bash scripts/check-module-invariants.sh` -> ALL CHECKS PASSED; B0 PASS at 1 directory; the B0
  note still reads "excluded 156 archived .lean files (550 total -> 394 live)"; C7 reports
  394 / 53 / 448 unchanged.
- `bash scripts/readme-lint.sh` -> RESULT: PASS, exit 0.

---

### Phase 3: Rewrite the move-broken import lines [COMPLETED]

**Goal**: Restore every import that resolved before Phase 2 and broke because its target's module
path changed. The dangling-import census must return to exactly its Phase 1 value.

**Tasks**:

- [x] Rewrite the 52 intra-Kamp import lines under
      `FormalSystem/Boneyard/Kamp/KampWeakCanonical/**` from
      `FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.*` to
      `FormalSystem.Boneyard.Kamp.KampWeakCanonical.*`.
- [x] Rewrite the 3 lines in `FormalSystem/Boneyard/Kamp/RabinovichPath/` that import
      `...Kamp.Boneyard.RabinovichTranslation`
      (`RabinovichGeneralized.lean`, `RabinovichNegation.lean`, `RabinovichWiring.lean`).
- [x] Re-run the census; confirm the count is back to the Phase 1 baseline (expected 65), i.e. all
      move-induced breakage is gone and only the pre-existing rot remains.

**MEASURED** (Phase 3): pre-rewrite census **120** = baseline 65 + 55 move-broken, exactly as
hypothesised. All 55 lines share one prefix, so a single rule
(`FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.` -> `FormalSystem.Boneyard.Kamp.KampWeakCanonical.`)
restored all of them, across 26 files. Post-rewrite census is **65** and its file/module set is
identical to the Phase 1 baseline set under the phase-2 path mapping -- no import outside the
enumerated 55 broke. `grep -rn 'Metalogic\.WeakCanonical\.Kamp\.Boneyard' --include=*.lean` is empty.
The slash-form `Kamp/Boneyard` survives in exactly **7 comment-only mentions across 3 live `.lean`
files** (`Kamp/DedekindINF.lean` x1, `Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` x1,
`Kamp/NfMultiAnchorBridge.lean` x5) -- the plan's predicted 7/3, deliberately untouched -- plus 3
comment mentions inside archived files, which Phase 8 updates.

**DEVIATION** (Phase 2 commit attribution): the 90 staged renames were swept into a concurrently
running agent's commit `94da79d88` ("task 424 phase 6-7"), which staged the whole working tree.
All 90 are recorded there as **R100**, and `git log --follow` resolves through the move for a
sampled file in every moved subdirectory (6-77 commits of prior history each). The move is intact;
only the commit that carries it is misattributed. History was not rewritten -- five agents were
committing to this branch concurrently, and rewriting shared history under them would be worse
than a wrong commit message.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: 55 lines (52 + 3), and the post-move / pre-rewrite dangling count is
65 + 55 = 120. Confirm both by census before and after the rewrite. If the pre-rewrite count is not
exactly baseline + 55, an import outside the enumerated set broke; find it before proceeding.

**Files to modify**:

- `FormalSystem/Boneyard/Kamp/KampWeakCanonical/**/*.lean` - 52 import lines
- `FormalSystem/Boneyard/Kamp/RabinovichPath/{RabinovichGeneralized,RabinovichNegation,RabinovichWiring}.lean` - 3 import lines

**Verification**:

- Census (block-comment-aware or `FormalSystem|BimodalTest`-prefix-restricted) over the whole
  archive reports exactly the Phase 1 baseline count of unresolvable imports.
- `grep -rn 'Metalogic\.WeakCanonical\.Kamp\.Boneyard' --include=*.lean FormalSystem/` is empty.
- `bash scripts/check-module-invariants.sh` ALL CHECKS PASSED; `readme-lint.sh` PASS;
  `lake build` exit 0 (archived files are uncompiled, so this must be unchanged).

---

### Phase 4: Repair Category A danglers and record Category B waivers [COMPLETED]

**Goal**: Drive unwaived dangling imports across the consolidated archive to zero — the
precondition for shipping C11 enforced.

**Tasks**:

- [x] Repair the Category A lines *(deviation: altered — **47**, not 48; `FormalSystem.Metalogic.Completeness` is ambiguous and moved to Category B, which the plan already seeded into the waiver file. See MEASURED.md D3)* by rewriting each to its target's current module path.
      Concentrations: `Kamp/KampBypassArchive/` (22), `Kamp/RabinovichPath/` (8),
      `Kamp/KampNegationClosure/` (4), `BundleSuccessorSeed` consumers (4),
      `StaviDiscretePath/` (2), scattered singles.
- [x] For each repair, confirm the resolution finds **exactly one** target file. An import name
      matching two files on disk is ambiguous: do not guess. Record it and waive it with the
      ambiguity as the reason.
- [x] Create `scripts/boneyard-import-waivers.txt` using the `scripts/module-invariants-allowlist.txt`
      comment/parse idiom (one module per line, `#` reason). Seed with the 6 Category B modules,
      each annotated with commit `6c3419a4f` ("delete superseded canonical model stack") as the
      recorded reason:
      `FormalSystem.Metalogic.Algebraic.ParametricTruthLemma`,
      `...ParametricCompleteness`, `...RestrictedParametricTruthLemma`, `...ParametricHistory`,
      `...ParametricCanonical`, and `FormalSystem.Metalogic.Completeness` (ambiguous; record why).
- [x] Add a header comment to the waiver file stating that entries are permanent records of
      deleted modules, not a backlog, and that stale entries are reported by C11.

**MEASURED** (Phase 4): 47 Category A lines repaired across **30** archived files; 18 lines across
**6** modules waived. Every repair was resolved by unique-basename lookup over the whole tree and
**every one found exactly one candidate** -- no repair was guessed. Concentrations landed close to
the plan's: `Kamp/KampBypassArchive/` 21 lines (plan said 22 -- one of them, `Kamp.KampBypass`
at 5 lines, resolves into that directory but is imported from elsewhere in the archive),
`Kamp/RabinovichPath/` 1, `Kamp/KampNegationClosure/` 5, `BundleSuccessorSeed` 5,
`StaviDiscretePath/` 2, `Kamp/KampWeakCanonical/` 11, singles elsewhere. Census after: **18**
unresolved, all waived; **0 unwaived**. The five `Algebraic.Parametric*` deletions were verified
directly against `git show 6c3419a4f` ("task 415 phase 4: delete superseded canonical model
stack"), which shows all five as `D`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: 48 repairable / 17 waived across 6 modules. Confirm by census before and
after. If a "repairable" line turns out to have no unique target, reclassify it as Category B and
waive it; the plan's 48/17 split is a hypothesis, the invariant "0 unwaived danglers" is the
requirement.

**Files to modify**:

- `FormalSystem/Boneyard/**/*.lean` - 48 import lines across ~10 subdirectories
- `scripts/boneyard-import-waivers.txt` - new

**Verification**:

- Census reports 0 unresolvable imports that are not covered by a waiver entry.
- Every waiver entry is exercised (no stale entries).
- `bash scripts/check-module-invariants.sh` ALL CHECKS PASSED; `readme-lint.sh` PASS;
  `lake build` exit 0.

---

### Phase 5: Add C11 to check-module-invariants.sh [COMPLETED]

**Goal**: Make the archive's import-resolution invariant a permanent, enforced gate rather than a
one-off cleanup, so the archive cannot silently decay again.

**Tasks**:

- [x] Add C11 to the existing `python3` heredoc block in `scripts/check-module-invariants.sh`,
      modelled on C4 (resolution) and C5 (allowlist idiom with stale-entry reporting).
- [x] Walk the consolidated archive tree. Reuse C4's regex
      `^import\s+((?:FormalSystem|BimodalTest)(?:\.[A-Za-z0-9_]+)*)\s*$` with `re.M` — **do not
      widen it to all imports**; widening reintroduces the 15 block-comment/fenced-code false
      positives. Resolve via C4's `mod_to_path`.
- [x] Parse `scripts/boneyard-import-waivers.txt`; suppress waived modules; report any waiver
      entry that no longer occurs as stale (C5 precedent) so the file cannot become a dumping
      ground.
- [x] Fail on any unwaived dangling import. Ship enforced from day one — no `ENFORCE_C11` flag;
      the script's own comment forbids ever flipping a flag back to 0.
- [x] Add a C11 line to the check list at `:5-16`.
- [x] Add the C11 row to `docs/development/MODULE_INVARIANTS.md`.
- [x] Adversarial check: temporarily inject a dangling import into one archived file, confirm C11
      fails with a message naming the file and the module, then revert the injection.

**MEASURED** (Phase 5): C11 reports **497** archived import lines across **156** archived files,
0 unwaived danglers, 6 waived, 0 stale. 497 = 349 + 148, the Phase 1 measured real counts -- **not**
the plan's 364 + 149 (MEASURED.md D4), and not the naive `^import` counts of 366 + 162, which the
shared C4 regex correctly declines to see. Adversarial check ran: injecting
`import FormalSystem.Metalogic.ThisModuleDoesNotExist` at `KampWeakCanonical/Prop43.lean:1` produced
`FAIL C11 1 unwaived dangling import(s) across 498 archived import lines`, named the file, line,
module and the missing path, printed the repair-or-waive instruction, and exited 1; after revert,
green. Stale-waiver reporting was tested the same way (a bogus entry produced
`INFO C11 1 waiver entr(y/ies) no longer occur; prune them`) and reverted. C11 was placed after C8
in the Python block so the printed order matches the numeric order in the check list.
MODULE_INVARIANTS.md gained the C11 row, a rewritten B0 row, and a third companion-file section.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: Real import-line counts are 364 in the former top-level archive and 149 in
the former Kamp archive (naive `^import` counts are 366 and 162). C11's own reported totals must
match the real counts, not the naive ones. Confirm by comparing C11's output against the Phase 1
census.

**Files to modify**:

- `scripts/check-module-invariants.sh` - C11 in the Python block, check list at `:5-16`, companion
  files list
- `docs/development/MODULE_INVARIANTS.md` - new C11 row

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` -> ALL CHECKS PASSED, C11 green, 0 unwaived
  danglers, waiver file reported with its full entry count and 0 stale.
- The injected-dangler test fails C11 and names the offending file and module; after revert, green.
- `bash scripts/check-module-invariants.sh` (with build) -> ALL CHECKS PASSED, exit 0.
- `bash scripts/readme-lint.sh` -> PASS.

---

### Phase 6: Regroup the flat Kamp files into per-approach subdirectories [COMPLETED]

**Goal**: Give the Kamp region the top-level archive's one-subdirectory-per-abandoned-approach
shape, so deliverable (g)'s READMEs have something to attach to.

**Tasks**:

- [x] `git mv` the 35 flat files at `FormalSystem/Boneyard/Kamp/KampWeakCanonical/` root into
      per-approach subdirectories following the taxonomy the existing 215-line archive README
      already names (do not invent a new one):
      - probe iterations: the `Exterior*ProbeK` family, `InteriorHrealSupplyK`, `NfZone*Probe`,
        `SeamPairRefutationProbe`, `ZoneSeamCrossContextProbe`
      - V-EA / normal-form infrastructure: `VecEA_m`, `EAVecNegationClosure`,
        `VecEAArityFirewall`, `ArityReduction`, `FOToVEA`, `NfComposition`, `NfExistTL`,
        `NegationIndep`, `EndpointNegation`, `WitnessCount`
      - Kamp/translation era: `KampComposition`, `RabinovichTranslation`, `RefutationF2`,
        `ZoneBridge`, `SeparationBridge`, `Separation`
      - individually-documented singles: `Prop43`, `Prop43DepthCharInfra`, `Arity4CharStackK`,
        `EANegationVBracketBackward`, `NavigatedEndCharSinglePoint`
- [x] Rewrite every import line broken by the regroup *(deviation: altered — **22** lines across 19 files, not the predicted 7; the prediction counted only intra-`KampWeakCanonical` edges targeting flat root files, but `KampBypassArchive/` (8 files) and `RabinovichPath/` (3 files) also import them. C11 was already enforcing, so a missed rewrite would have failed the gate)* (research predicts at most 7: only 7 of the
      52 intra-archive edges target flat root files).
- [x] Confirm every move is a rename, not a delete+add.

**MEASURED** (Phase 6): all 35 flat root files regrouped into four subdirectories named from the
archive README's own taxonomy -- `ProbeIterations/` (14), `VecEANormalForm/` (10),
`TranslationEra/` (6), `DocumentedSingles/` (5). 0 flat `.lean` files remain at the
`KampWeakCanonical/` root. All 35 are detected as renames, none as delete+add.

**DEVIATION** from "`R100` for the `.lean` files": 28 are `R100`; **7 are `R098`/`R099`** --
`Prop43`, `ExteriorPinnedProbeAnchorK`, `KampComposition`, `ArityReduction`,
`EAVecNegationClosure`, `NfExistTL`, `VecEAArityFirewall`. Those are exactly the moved files that
*also* import another moved file, so the same phase both relocates them and rewrites an import line
inside them. The plan asks for both in one phase, so a similarity below 100 on precisely this set
is the correct outcome, not content drift: a phase cannot simultaneously rewrite a file's imports
and leave it byte-identical. Git still records them as renames, so `git log --follow` resolves.

C11 green throughout at 497 lines / 0 unwaived; `readme-lint.sh` unchanged from baseline.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 35 flat files, and at most 7 additional import rewrites. Confirm both by
counting the flat root files before the regroup and by running C11 after; C11 is enforcing by this
phase, so any missed rewrite fails the gate rather than passing silently. If more than 7 rewrites
are needed, record the actual number — it does not change the work, only the estimate.

**Files to modify**:

- `FormalSystem/Boneyard/Kamp/KampWeakCanonical/*.lean` -> per-approach subdirectories (35, moved)
- import lines in whichever archived files reference the moved modules

**Verification**:

- `git status --porcelain --find-renames` shows 35 renames at `R100` for the `.lean` files.
- `git log --follow` resolves for one sampled file per new subdirectory.
- `bash scripts/check-module-invariants.sh` ALL CHECKS PASSED, C11 green at 0 unwaived danglers.
- `lake build` exit 0, `lake build BimodalTest` exit 0.
- `bash scripts/readme-lint.sh` PASS.

---

### Phase 7: Write the Kamp region documentation [COMPLETED]

**Goal**: Deliverable (g) — every Kamp subdirectory carries a README explaining what the approach
was, why it died, what revival would require, and the original path of every file in it.

**Tasks**:

- [x] Expand `FormalSystem/Boneyard/Kamp/README.md` from the Phase 2 stub into the region index:
      name all five subdirectories, state which is authoritative for what, and state in writing why
      `MergedBracketQuarantine/` was left outside the umbrella.
- [x] Write the missing per-approach READMEs on the incoming side: `KampWeakCanonical/ZetaProbes/`
      (5 files), `KampWeakCanonical/NfMultiAnchorBridgeRetired/` (5),
      `KampWeakCanonical/Separation/` top level (16), and one per subdirectory created in Phase 6.
- [x] Write the missing per-approach READMEs on the reconciled side: `Kamp/KampBypassArchive/`
      (13 files — the largest undocumented subdirectory in the archive),
      `Kamp/KampNegationClosure/` (4), `Kamp/RabinovichPath/` (4).
- [x] In every README, record each file's **original path** (pre-move, pre-regroup), so provenance
      survives for a reader who never runs `git log`.
- [x] Do not contradict provenance already recorded inside the files themselves —
      `Arity4CharStackK.lean` carries a per-block provenance table in its own header, and several
      files record their excision origin in prose. Reconcile against those, do not overwrite them.

**MEASURED** (Phase 7): **10 new READMEs** written -- `KampBypassArchive/` (13 files),
`KampNegationClosure/` (4), `RabinovichPath/` (4), `KampWeakCanonical/ZetaProbes/` (5),
`NfMultiAnchorBridgeRetired/` (5), `Separation/` (10 at top level), and one per Phase 6
subdirectory: `ProbeIterations/` (14), `VecEANormalForm/` (10), `TranslationEra/` (6),
`DocumentedSingles/` (5) -- plus the expanded region index. **Every one of the 14 directories
under `Boneyard/Kamp/` holding a `.lean` file now has a README, and all 85 `.lean` files appear
in an original-path table**, verified mechanically rather than by eye.

Two pre-existing inventory gaps were closed while auditing that: `Separation/Hierarchy/README.md`
listed 3 of its 4 files (`HierarchyCaseSep.lean` was absent), and `VecEADecomposition/README.md`
had no file table at all.

Original paths come from three sources, and the tables say which: the file's own
`-- ARCHIVED from` header where it has one (all of `KampNegationClosure/` and `RabinovichPath/`),
`git log --follow` otherwise, and an explicit "created in the archive" with the birth commit for
the 5 files that were born archived. Two git-inferred origins are flagged as unverified rather
than asserted: git's rename heuristic pairs `KampMutualInduction.lean` with
`RabinovichGeneralized.lean`, which is almost certainly a content-similarity false match.
`Arity4CharStackK.lean`'s own per-block provenance table is cited as authoritative and is not
restated, per the plan's last task.

Three broken markdown links inside the archive were repaired: `KampWeakCanonical/README.md:54`
(broken *by* the move -- its `../../../../Boneyard/README.md` no longer resolved at the new depth),
and two pre-existing ones in `Separation/Hierarchy/README.md:39` and
`ExpressiveCompleteness/README.md:29`, repointed at their live targets. `readme-lint.sh` never saw
any of the three -- its Check 3 skips `Boneyard`-named directories, confirmed by reading the
script rather than assumed -- so this was caught by an explicit archive-wide link sweep. One
broken link remains, in `Boneyard/README.md`, and Phase 8 rewrites that file.

C5 PASS at 4 allowlisted confirms the plan's expectation that archive READMEs stay exempt from
the markdown module-path check.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: prose

**Scope Hypothesis**: 10 or more new READMEs (3 pre-existing gaps on the incoming side + 3 on the
reconciled side + one per Phase 6 subdirectory + the region index). Confirm the final list against
an actual walk: every directory under `FormalSystem/Boneyard/Kamp/` containing at least one `.lean`
must have a `README.md`.

**Files to modify**:

- `FormalSystem/Boneyard/Kamp/README.md` - expanded region index
- `FormalSystem/Boneyard/Kamp/**/README.md` - new per-approach READMEs

**Verification**:

- Every directory under `FormalSystem/Boneyard/Kamp/` holding a `.lean` file has a `README.md`.
- Every `.lean` file under that tree appears exactly once in an original-path table.
- `bash scripts/readme-lint.sh` PASS; `bash scripts/check-module-invariants.sh` ALL CHECKS PASSED
  (C5 skips `Boneyard`-named directories, so archive READMEs remain exempt from the markdown
  module-path check — confirm rather than assume).

---

### Phase 8: Single-source the archive counts and retire the obsolete policies [NOT STARTED]

**Goal**: Deliverable (f) — one accurate statement of the archive's shape, in one place, with the
contradictory and now-false prose retired explicitly.

**Tasks**:

- [ ] In `FormalSystem/Boneyard/README.md`: replace the "There Are TWO Boneyards" section with one
      accurate statement of the single consolidated tree.
- [ ] State the archive counts in **exactly this one place**, citing
      `scripts/check-module-invariants.sh` B0/C7 output as the live source. Use the Phase 1
      measured values, not the stale `59,010` / `62 / 27,394` figures.
- [ ] Fold the former `Kamp/Boneyard/README.md` content into
      `Kamp/KampWeakCanonical/README.md`, and explicitly retire, in writing:
      - its closing paragraph justifying the nesting ("nested here rather than under the top-level
        Boneyard to keep the Kamp pipeline's history next to the live `Kamp/` code") — this task
        overrules it; say so.
      - its sentence "stale imports in never-built code are cosmetic and need not be repaired" —
        C11 reverses this policy; the README must not carry a rule its own gate violates.
- [ ] Record the decision to leave the 7 comment-only `Kamp/Boneyard/` mentions in the 3 live
      `.lean` files untouched, noting that the correct path is now `FormalSystem/Boneyard/`, and
      that updating them is a separate task under the no-live-module non-goal.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: prose

**Scope Hypothesis**: 7 comment-only mentions of the old path across 3 live `.lean` files. Confirm
by grep before writing the recorded decision; if the number differs, record the measured number
rather than the plan's.

**Files to modify**:

- `FormalSystem/Boneyard/README.md` - merged single-source statement and counts
- `FormalSystem/Boneyard/Kamp/KampWeakCanonical/README.md` - folded content, retired policies

**Verification**:

- `grep -rn 'TWO Boneyards' FormalSystem/` returns only the single new accurate statement (or
  nothing, if the new wording drops the phrase).
- `grep -rn 'need not be repaired' FormalSystem/` returns only the explicit retirement note.
- The count figures `59,010` and `27,394` appear nowhere under `FormalSystem/`.
- `bash scripts/readme-lint.sh` PASS; `bash scripts/check-module-invariants.sh` ALL CHECKS PASSED.

---

### Phase 9: Update the live-side documentation [NOT STARTED]

**Goal**: Remove every stale two-Boneyard claim and every restated count from the files outside the
archive, replacing restatements with links to the Phase 8 single source.

**Tasks**:

- [ ] `FormalSystem/README.md` - remove the "TWO Boneyards" section and its table; link to the
      consolidated archive README instead of restating `93 / 59,010` and `62 / 27,394`.
- [ ] `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md` - remove the
      `## This Directory Has Its Own Boneyard` section (`:8-16`), the table row (`:26`), and the
      `:56` claim; the `:65` link was already repointed in Phase 2.
- [ ] `FormalSystem/Metalogic/README.md` - `:8`, `:14-17`, `:185`, `:191`, `:249`, `:293`.
- [ ] `FormalSystem/Metalogic/WeakCanonical/README.md` - `:31`, `:36-38` ("carries its own local
      `Boneyard/`").
- [ ] `docs/development/MODULE_INVARIANTS.md` - update the `:19` B0 row from "Both Boneyards" to
      the single tree. (The C11 row was added in Phase 5.)
- [ ] `scripts/check-copyright-headers.sh:22` - comment names both trees and says "151 archived
      files"; correct to the single tree and the measured count.
- [ ] `scripts/add-copyright-headers.sh:18` - comment names the Kamp tree and "62 files".
- [ ] `scripts/typst-sync-check.sh:97` - comment example uses the old Kamp path.
- [ ] `typst/SYNC-MAP.md` - `:174`, `:177`, `:310`, `:394` counts split around the nested archive.
- [ ] Do NOT touch `scripts/typst-status-counts.sh` — verified safe: its
      `strip_and_count_sorries` helper returns 0 for a missing path by design, so
      `SORRY_WEAKCANONICAL_ALL` minus a now-zero `SORRY_KAMP_BONEYARD` stays arithmetically
      correct. Confirm its output is unchanged rather than editing it.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: prose

**Scope Hypothesis**: 9 files outside the original `file_scope` need edits. Confirm by grepping the
whole repo (excluding `specs/**` and `.git/**`) for `Kamp/Boneyard`, `TWO Boneyards`, `59,010`,
`27,394`, `151 archived`, and `62 files`; the residual hit set after this phase must be empty
except the 7 deliberate live `.lean` comments.

**Files to modify**:

- `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/WeakCanonical/README.md`,
  `FormalSystem/Metalogic/WeakCanonical/Kamp/README.md`, `docs/development/MODULE_INVARIANTS.md`,
  `scripts/check-copyright-headers.sh`, `scripts/add-copyright-headers.sh`,
  `scripts/typst-sync-check.sh`, `typst/SYNC-MAP.md`

**Verification**:

- `bash scripts/readme-lint.sh` -> RESULT: PASS, exit 0, 0 broken references.
- `bash scripts/check-module-invariants.sh` ALL CHECKS PASSED, C5 PASS with its 4 allowlisted
  entries unchanged.
- `bash scripts/typst-status-counts.sh` output is unchanged from the Phase 1 baseline.

---

### Phase 10: Final verification sweep [NOT STARTED]

**Goal**: Prove, against the Phase 1 baselines, that the consolidation changed nothing it should
not have changed and everything it should have.

**Tasks**:

- [ ] Run the full corrected verification contract and record each result against its baseline.
- [ ] Grep audit: zero remaining references to `Metalogic/WeakCanonical/Kamp/Boneyard` outside
      `specs/**` and `.git/**`, except the 7 deliberate comment-only mentions in the 3 live `.lean`
      files.
- [ ] Report at completion: the 6 missing non-Kamp top-level READMEs left out of scope, and any
      Scope Hypothesis whose measured value diverged from the plan.

**Timing**: 1 hour

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: Every number in the verification table below (85 + 35 renames, 156 archived,
550 total, 394 live, 53 Tests, 448 total, 1 sorry, 4 C5 allowlist entries, waiver entry count) is
asserted against the Phase 1 measured baselines, not against the research report. Where Phase 1
measured a different value, this table's expected value is that measured value; a divergence
between a Phase 1 measurement and a Phase 10 result is a real regression and must be investigated,
not reconciled by editing the expectation.

**Files to modify**:

- none (verification only; findings go in the implementation summary)

**Verification**:

| # | Check | Expected |
|---|---|---|
| 1 | `git status` across the move commits | 85 renames (Phase 2) + 35 renames (Phase 6), `R100` on `.lean`, zero delete+add pairs |
| 2 | `git log --follow`, one file per moved subdirectory | resolves through every move |
| 3 | `lake build` | exit 0, output unchanged from the Phase 1 baseline |
| 4 | `lake build BimodalTest` | exit 0 (was green before; must stay green) |
| 5 | B0 | PASS at 1 directory; "excluded 156 archived .lean files (550 total -> 394 live)" |
| 6 | C3 | exactly 1 sorry, `countermodel_discrete`, `WeakCanonical/Transfer.lean` |
| 7 | C4 | all live import lines resolve, count unchanged from baseline |
| 8 | C5 | PASS, 4 allowlisted, unchanged |
| 9 | C7 | 394 live `FormalSystem` / 53 `Tests` / 448 total, unchanged |
| 10 | C11 | green: 0 unwaived dangling imports; waiver file entries all exercised, 0 stale |
| 11 | `check-module-invariants.sh` overall | ALL CHECKS PASSED, exit 0 |
| 12 | `readme-lint.sh` | RESULT: PASS, exit 0, 0 broken references |
| 13 | Grep audit | zero `Metalogic/WeakCanonical/Kamp/Boneyard` outside `specs/**` and `.git/**`, except the 7 deliberate live comments |
| 14 | Kamp region README coverage | every directory under `FormalSystem/Boneyard/Kamp/` holding a `.lean` has a `README.md` with original-path records |

---

## Testing & Validation

- [ ] `lake build` exits 0 with output byte-identical to the Phase 1 baseline (the archive is
      outside the import closure, so any difference means something moved that should not have).
- [ ] `lake build BimodalTest` exits 0.
- [ ] `bash scripts/check-module-invariants.sh` -> ALL CHECKS PASSED, exit 0, including the new C11.
- [ ] `bash scripts/readme-lint.sh` -> RESULT: PASS, exit 0.
- [ ] `bash scripts/typst-status-counts.sh` output unchanged from baseline.
- [ ] `git status --find-renames` shows renames only, never delete+add, across all move commits.
- [ ] C11 fails as designed when a dangling import is deliberately injected (tested in Phase 5).
- [ ] Live sorry count remains exactly 1, verified via C3, never a naive grep.

## Artifacts & Outputs

- `FormalSystem/Boneyard/Kamp/` - the consolidated Kamp region (`KampWeakCanonical/`,
  `KampBypassArchive/`, `KampNegationClosure/`, `RabinovichPath/`, `VecEADecomposition/`) with a
  region index README and per-approach READMEs recording original paths
- `scripts/check-module-invariants.sh` - B0 asserting 1 directory, new C11 import-resolution check,
  updated header comment and check list
- `scripts/boneyard-import-waivers.txt` - new; permanent record of unrepairable imports with
  recorded reasons
- `docs/development/MODULE_INVARIANTS.md` - updated B0 row, new C11 row
- `FormalSystem/Boneyard/README.md` - single-source archive counts and shape
- 9 live-side documentation and script-comment files with stale two-Boneyard claims removed
- `specs/451_consolidate_boneyard_archives/baselines/` - recorded pre-move gate output
- `specs/451_consolidate_boneyard_archives/summaries/01_*-summary.md` - implementation summary

## Rollback/Contingency

Every phase ends at a committed, green milestone, so rollback is `git revert` of the phases from
the failure point backward, in reverse order. The move phases (2 and 6) are pure renames with no
`.lean` content change, so reverting them restores the previous tree exactly.

If a live module turns out to require a change, stop and report — that is a separate task per the
non-goal, not a rollback.

If Phase 4 cannot drive unwaived danglers to zero (for example, a repair target is genuinely
ambiguous in a way waiving cannot honestly cover), do not weaken C11 to an `ENFORCE_C11=0` flag.
Mark the task `[BLOCKED]` with the specific import lines named, and surface the question of whether
those files should be deleted instead — deletion is an explicit non-goal, so it needs a user
decision rather than an agent judgment call.
