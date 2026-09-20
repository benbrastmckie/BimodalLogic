# Implementation Plan: Task #631

- **Task**: 631 - Deliverable hygiene excluding specs
- **Status**: [IMPLEMENTING]
- **Effort**: 8.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/631_deliverable_hygiene_excluding_specs/reports/01_deliverable-hygiene-research.md
- **Artifacts**: plans/01_deliverable-hygiene.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Bring the tracked tree down to a publishable deliverable: untrack four agent-system
configuration files, delete four one-off scripts and document the remainder, retire the frozen
`latex/` edition together with every link into it, move `CONTRIBUTING.md` to the repository root,
untrack `docs/research/` and `docs/training/`, strip personal absolute paths from `docs/` and
`typst/`, and normalise stale `Logos`/`ProofChecker`/`lakefile.lean` naming in the surviving
docs. Nothing under `specs/` is touched. Definition of done: `scripts/check-module-invariants.sh`
and `scripts/readme-lint.sh` both green (they are green at baseline, so this is a
preserve-not-repair bar) and `grep -rn 'home/benjamin' docs typst` returns nothing.

### Research Integration

The research report establishes five facts this plan is built on:

1. `docs/development/PUBLICATION_REFACTOR.md` Section 7 ("Phase 1: Deliverable hygiene"),
   Section 4 ("Target layout") and Section 5 are the authoritative elaboration of the one-paragraph
   task description. The plan follows that document, not a re-derivation of the dispatch text.
2. Both acceptance gates are **green at baseline** (`ALL CHECKS PASSED`, `RESULT: PASS`), so every
   phase's job is to not break them.
3. The dispatch's shorthand "the C10/C12 references to it" does not match those checks' actual
   regexes. C10 matches only `FormalSystem/(docs|latex|typst)`; C12 matches only paths prefixed
   `FormalSystem|Tests|Logos|Bimodal`. The checks that actually fire on the `latex/` retirement
   are **C13** (relative markdown links in `docs/` + root `README.md`) and **`readme-lint.sh`
   Check 3** (broken relative file references under `FormalSystem/`). Phase 3 targets those two.
4. The `Logos`/`ProofChecker` rewrite scope roughly halves once `docs/research/` is untracked, so
   the naming phase is sequenced *after* the removal phases.
5. `CITATION.cff` contains **zero** `Logos`/`ProofChecker` occurrences and needs no rewrite; its
   only `logos` string is an author email domain.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch; `specs/ROADMAP.md` was not consulted. The
governing programme document is `docs/development/PUBLICATION_REFACTOR.md` (this task is its
Phase 1 / Follow-up B).

## Goals & Non-Goals

**Goals**:
- Untrack `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, the empty `.gitattributes`
  (files stay on local disk; add matching `.gitignore` entries).
- Delete `scripts/migrate_schema_v2.py`, `scripts/swap_untl_snce.py`,
  `scripts/standardize_metadata.py`, `scripts/add-copyright-headers.sh`; add `scripts/README.md`
  naming every remaining script.
- Retire the tracked `latex/` tree (18 tracked files including `BimodalReference.pdf`) and repair
  every reference that would otherwise dangle.
- Move `docs/development/CONTRIBUTING.md` to the repository root and repoint all citers.
- Untrack `docs/research/` (15 files) and `docs/training/` (4 files) and repair inbound links.
- Remove every `home/benjamin` occurrence from `docs/` and `typst/`.
- Normalise stale `Logos`-as-package-name and literal-name `ProofChecker` misuse in `README.md`
  and `docs/`, including the absorbed task-610 `lakefile.lean` mentions.
- Keep `check-module-invariants.sh` and `readme-lint.sh` green throughout.

**Non-Goals**:
- Untracking anything under `specs/` (explicitly excluded; the maintainer's standing decision is
  that `specs/` stays tracked).
- Editing `CITATION.cff` for naming (already clean — verified, zero occurrences).
- Rewriting `README.md`'s or `docs/README.md`'s intentional `ProofChecker`-as-role-name framing,
  or any legitimate "Logos Laboratories" / `logos-labs.ai` external-project reference. Both are
  documented conventions, not defects.
- Editing `docs/development/PUBLICATION_REFACTOR.md`'s self-referential `Logos`/`ProofChecker`
  mentions (it is the plan describing the rewrite, not an instance of it). Its `home/benjamin`
  occurrences are handled separately in Phase 6 because the acceptance grep is literal.
- Restructuring `README.md`'s architecture paragraph into a "Related projects" section
  (Section 5 floats this as later-phase polish, not a Phase-1 commitment).
- Editing ADR-009, ADR-010, `docs/development/MODULE_INVARIANTS.md`,
  `scripts/check-module-invariants.sh` comments, or `FormalSystem/Boneyard/README.md` for the
  `latex/` retirement — none is gate-relevant and ADR-010 already narrates this retirement as
  expected.
- Any Lean source change; no `lake build` is required by this task.

## Decisions Adopted

- **`docs/research/` and `docs/training/` disposition**: untrack (`git rm --cached -r`), keep the
  files on local disk, add both paths to `.gitignore` — the same treatment the four dotfiles get.
  Rationale: Section 4 says "removed from the tracked deliverable", and its alternative
  destinations (the external dataset project; `BimodalTools/`, not created until task 632) do not
  exist yet. Untracking is the reading that is both literal and reversible; outright deletion is
  not reversible without git history archaeology and was not instructed.
- **`home/benjamin` self-reference**: `docs/development/PUBLICATION_REFACTOR.md` quotes the
  acceptance grep verbatim in four places, so the acceptance command can never return empty while
  those quotes stand. Resolution: reword those four lines to describe the check in prose ("no
  absolute path under the maintainer's home directory remains in `docs/` or `typst/`") rather than
  quoting the literal invocation. Meaning is preserved; the literal substring is not.
- **Duplication with task 637**: Section 8 and task 637 repeat the same dotfile untrack "at the
  gate". This task performs it now, as instructed. No change is made to task 637 here; the
  duplication is recorded in the research report so a later `git rm --cached` on an
  already-untracked path is not a surprise.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting `latex/` before fixing its link-bearing citers red-lights both named acceptance gates at once (C13 on `README.md`, readme-lint Check 3 on `FormalSystem/README.md`) | H | H | Phase 3 fixes `README.md:17,357` and `FormalSystem/README.md:7` in the **same** step as the deletion, then re-runs both gates before committing |
| Blanket `Logos` -> `FormalSystem` substitution corrupts legitimate "Logos Laboratories" / `logos-labs.ai` references and contradicts the documented naming convention | H | M | Phase 7 is explicitly per-occurrence with a three-bucket classification; no single-regex substitution is permitted |
| Untracking `docs/research/`/`docs/training/` silently orphans inbound links from `README.md:366,373`, `docs/README.md:125`, `docs/user-guide/examples.md:479`, `docs/reference/paper-definitions-of-record.md:164`, `scripts/export-training-data.sh:27,327` | M | H | Phase 4 repairs all six sites in the same step, then re-runs C13 plus an explicit `grep -rn 'docs/research\|docs/training'` over the remaining tracked tree (C13's scan root would miss `ORGANISATION.md`/`FormalSystem/README.md`) |
| Deleting `swap_untl_snce.py` while `docs/reference/paper-definitions-of-record.md:195` asserts it is "kept for output and history stability" leaves a documented promise the tree does not keep | M | H | Phase 2 edits that line in the same step as the deletion |
| `scripts/README.md` introduces a task-number citation and trips C9 (which scans `scripts/`) | M | L | Phase 2 verification greps the new file for task-number patterns before committing; see `.claude/rules/no-task-references-in-deliverables.md` |
| `CONTRIBUTING.md` relocation leaves stale relative links (`../development/CONTRIBUTING.md`, `CONTRIBUTING.md` sibling links inside `docs/development/`) | M | H | Phase 5 enumerates all 14 citers from the research report and re-runs C13, which covers every one of them inside `docs/` |
| Phase 7's ~30-file naming scope overruns a single implementation dispatch | M | M | Phase 7 is scoped as its own phase with a per-file checklist and may be split at a file boundary into 7.1/7.2 if it overruns; each file's edit is independently committable |
| `.gitignore` entries written as bare names also ignore same-named files deeper in the tree | L | M | Use root-anchored forms (`/CLAUDE.md`, `/.syncprotect`, `/.claude-extensions.json`, `/.gitattributes`, `/docs/research/`, `/docs/training/`) |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 3 |
| 3 | 5, 6 | 4 (phase 5); 2, 4 (phase 6) |
| 4 | 7 | 5, 6 |
| 5 | 8 | 1, 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel. The wave-1 phases are independent because
their file sets are disjoint (`.gitignore` + git index; `scripts/` + one docs line; `latex/` +
its citers). Phases 4-7 are serialised because they all edit `README.md` and/or `docs/README.md`.
The ordering also follows the research recommendation to do the removals first so the later
grep-driven phases scan a smaller tree.

### Phase 1: Untrack agent-system configuration files [IN PROGRESS]

**Goal**: `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect` and the empty `.gitattributes`
are no longer tracked, remain on local disk, and are ignored going forward.

**Tasks**:
- [ ] Confirm all four are currently tracked: `git ls-files | grep -E '^(CLAUDE\.md|\.claude-extensions\.json|\.syncprotect|\.gitattributes)$'` (expect exactly 4 lines).
- [ ] Confirm `.gitattributes` is empty (`wc -c .gitattributes` -> 0); it is deleted outright rather than ignored, since an empty file carries nothing to preserve.
- [ ] `git rm --cached CLAUDE.md .claude-extensions.json .syncprotect` (keeps working-tree copies).
- [ ] `git rm .gitattributes` (empty file: remove from tree as well).
- [ ] Add root-anchored `.gitignore` entries: `/CLAUDE.md`, `/.claude-extensions.json`, `/.syncprotect`, with a one-line comment saying these are agent-system configuration, not deliverable.
- [ ] Confirm nothing in the deliverable references these paths: the only hits are `docs/user-guide/MCP_INTEGRATION.md:34` and `docs/project-info/MAINTENANCE.md:670`, both of which name `.claude/CLAUDE.md` (the generated deploy copy, already gitignored) and need no edit — re-verify rather than assume.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly four files are tracked and `.gitattributes` is empty (0 bytes),
verified at research time. Confirm both with the two commands in the first two checklist items
before removing anything; if `.gitattributes` is non-empty, untrack it (as with the other three)
instead of deleting it.

**Files to modify**:
- `.gitignore` - add root-anchored ignore entries for the three retained-but-untracked files
- `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect` - index removal only, file contents untouched
- `.gitattributes` - deleted (empty)

**Verification**:
- `git ls-files | grep -E '^(CLAUDE\.md|\.claude-extensions\.json|\.syncprotect|\.gitattributes)$'` returns nothing.
- `ls CLAUDE.md .claude-extensions.json .syncprotect` still succeeds (files survive on disk).
- `git status --porcelain` shows no untracked-but-unignored entry for the three retained files.
- `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh` still green.

---

### Phase 2: Delete one-off scripts and document the remainder [NOT STARTED]

**Goal**: The four one-off scripts are gone, `scripts/README.md` names every surviving script,
and no doc still promises a deleted script is retained.

**Tasks**:
- [ ] `git rm scripts/migrate_schema_v2.py scripts/swap_untl_snce.py scripts/standardize_metadata.py scripts/add-copyright-headers.sh`.
- [ ] Re-grep for any surviving reference to the four names outside `specs/` (research found exactly one: `docs/reference/paper-definitions-of-record.md:195`); fix each hit found.
- [ ] Edit `docs/reference/paper-definitions-of-record.md:195` so it no longer asserts `scripts/swap_untl_snce.py` is "kept for output and history stability" — restate the migration-pattern fact without promising the script's retention.
- [ ] Check whether `scripts/check-copyright-headers.sh` documents `add-copyright-headers.sh` as its companion writer; if so, reword so the checker stands alone.
- [ ] Author `scripts/README.md`: one line per surviving top-level script (name, one-sentence purpose, whether it is a gate/ratchet or a utility), plus a short section covering the `scripts/lib/` helper modules and the non-script data files (`*.txt` allowlists, `nolints.json`) so the directory listing is fully accounted for.
- [ ] Verify `scripts/README.md` contains **no** task-number citation (C9 enforces zero task-number citations under `scripts/`).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: after deletion, `scripts/` holds 29 surviving top-level scripts plus 4
`scripts/lib/*.py` helpers and a set of allowlist/data files (`ls scripts/` at research time
showed 41 top-level entries including `lib`, `__pycache__` and 8 non-script data files). Confirm
the live inventory with `ls scripts/` and `ls scripts/lib/` **at implementation time** and write
the README from that listing, not from this count. Every entry that appears in the listing must
appear in the README.

**Files to modify**:
- `scripts/migrate_schema_v2.py`, `scripts/swap_untl_snce.py`, `scripts/standardize_metadata.py`, `scripts/add-copyright-headers.sh` - deleted
- `scripts/README.md` - new file
- `docs/reference/paper-definitions-of-record.md` - remove the retention promise for the deleted script
- `scripts/check-copyright-headers.sh` - only if it names the deleted writer script

**Verification**:
- `ls scripts/ | grep -E 'migrate_schema_v2|swap_untl_snce|standardize_metadata|add-copyright-headers'` returns nothing.
- Every entry from `ls scripts/` and `ls scripts/lib/` (excluding `__pycache__`) appears by name in `scripts/README.md`.
- `grep -rn 'migrate_schema_v2\|swap_untl_snce\|standardize_metadata\|add-copyright-headers' --include='*.md' --include='*.sh' . | grep -v '^\./specs/'` returns nothing.
- `bash scripts/check-module-invariants.sh` green (C9 covers `scripts/`).

---

### Phase 3: Retire the frozen `latex/` edition and repair its citers [NOT STARTED]

**Goal**: `latex/` and its tracked PDF are out of the tree, no surviving markdown link dangles,
and both acceptance gates stay green.

**Tasks**:
- [ ] Record the pre-state: `git ls-files latex/` (18 tracked files at research time; `latex/build/` is untracked and irrelevant).
- [ ] `git rm -r latex/`.
- [ ] `git rm docs/development/LATEX_STANDARDS.md` — its entire subject is the retired directory.
- [ ] Fix `README.md:17` (prose + `[latex/BimodalReference.pdf](latex/BimodalReference.pdf)`) and `README.md:357` (`[Specification Document](latex/BimodalReference.pdf)`): point at the published paper URL or drop the entry; do not leave a relative link (C13 will fail).
- [ ] Fix `FormalSystem/README.md:7` (`[tex](../latex/...)` / `[pdf](../latex/...)`) — readme-lint Check 3 scans this file.
- [ ] Drop the now-dangling `LATEX_STANDARDS.md` entries at `docs/development/README.md:32` and `docs/README.md:153`.
- [ ] Update `typst/README.md:188,191` and `typst/SYNC-MAP.md:125,127` ("D3. latex/ mirror: declared divergence") to past-tense / removed-tree framing.
- [ ] Update `ORGANISATION.md:45`'s table row (`| typst/, latex/ | The paper sources |`) to name `typst/` alone.
- [ ] Update `docs/development/CONTRIBUTING.md:143`'s project-structure bullet to drop `latex/` (the file itself moves in Phase 5; this is a content edit, not the move).
- [ ] Leave untouched, per Non-Goals: ADR-009, ADR-010, `docs/development/MODULE_INVARIANTS.md:29`, `scripts/check-module-invariants.sh` comments, `FormalSystem/Boneyard/README.md:680`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 13 files outside `latex/` reference `latex/` paths, of which exactly three
sites are gate-relevant (`README.md:17`, `README.md:357`, `FormalSystem/README.md:7`) and 18
files are tracked under `latex/`. Confirm at implementation time with `git ls-files latex/ | wc -l`
and `grep -rn 'latex/' --include='*.md' . | grep -v '^\./specs/' | grep -v '^\./latex/'`; the
authoritative closing check is the two gate scripts, not this enumeration. Line numbers cited
here are research-time anchors — locate by content, not by line number.

**Files to modify**:
- `latex/**` (18 tracked files) - deleted
- `docs/development/LATEX_STANDARDS.md` - deleted
- `README.md` - two link sites repointed or removed
- `FormalSystem/README.md` - tex/pdf links repointed or removed
- `docs/development/README.md`, `docs/README.md` - drop `LATEX_STANDARDS.md` index entries
- `typst/README.md`, `typst/SYNC-MAP.md` - past-tense reframing
- `ORGANISATION.md` - table row
- `docs/development/CONTRIBUTING.md` - project-structure bullet

**Verification**:
- `git ls-files latex/` returns nothing; `ls latex` shows no tracked sources.
- `grep -rn 'latex/' --include='*.md' . | grep -v '^\./specs/'` returns only the deliberately-retained prose sites listed under Non-Goals.
- `bash scripts/check-module-invariants.sh` green — specifically `PASS C13`.
- `bash scripts/readme-lint.sh` green — specifically Check 3, `Broken file references: 0`.

---

### Phase 4: Untrack `docs/research/` and `docs/training/` [NOT STARTED]

**Goal**: Both directories leave the tracked deliverable, survive on local disk, and no surviving
file links into them.

**Tasks**:
- [ ] `git rm --cached -r docs/research docs/training` (files stay on disk).
- [ ] Add `/docs/research/` and `/docs/training/` to `.gitignore` beside the Phase-1 entries.
- [ ] Repair the six inbound reference sites found by research: `README.md:366` (link to `docs/research/BIMODAL_LOGIC.md`), `README.md:373` (link to `docs/training/PIPELINE.md`), `docs/README.md:125` (link to `docs/research/`), `docs/user-guide/examples.md:479` (prose path), `docs/reference/paper-definitions-of-record.md:164` (prose reference to `docs/training/SYNC_PROTOCOL.md`), `scripts/export-training-data.sh:27,327` (comment + runtime echo).
- [ ] Re-grep the whole remaining tracked tree (not just C13's scan root) for `docs/research\|docs/training` and repair anything else that surfaces outside `specs/` and outside the two directories themselves.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 15 tracked files under `docs/research/` and 4 under `docs/training/`, with
six inbound reference sites outside them. Confirm with `git ls-files docs/research docs/training | wc -l`
and the tree-wide grep in the last checklist item before closing the phase; C13's scan root
(`docs/` + root `README.md`) does **not** cover `ORGANISATION.md` or `FormalSystem/README.md`, so
the grep is load-bearing and not redundant with the gate.

**Files to modify**:
- `docs/research/**` (15 files), `docs/training/**` (4 files) - index removal only
- `.gitignore` - two root-anchored entries
- `README.md`, `docs/README.md`, `docs/user-guide/examples.md`, `docs/reference/paper-definitions-of-record.md`, `scripts/export-training-data.sh` - inbound references repaired

**Verification**:
- `git ls-files docs/research docs/training` returns nothing; both directories still exist on disk.
- `grep -rn 'docs/research\|docs/training' . 2>/dev/null | grep -v '^\./specs/' | grep -v '^\./docs/research/' | grep -v '^\./docs/training/' | grep -v '^\./\.claude/'` returns only `docs/development/PUBLICATION_REFACTOR.md` (the programme document describing this removal, deliberately retained).
- `bash scripts/check-module-invariants.sh` green (C13 catches any surviving link from `docs/` or `README.md`).
- `bash scripts/readme-lint.sh` green.

---

### Phase 5: Move `CONTRIBUTING.md` to the repository root [NOT STARTED]

**Goal**: `CONTRIBUTING.md` sits at the root beside `README.md`, `ORGANISATION.md`, `NOTATION.md`
and `references.bib`, and every citer points at the new location.

**Tasks**:
- [ ] `git mv docs/development/CONTRIBUTING.md CONTRIBUTING.md`.
- [ ] Fix relative links **inside** the moved file itself (its own links were written relative to `docs/development/` and all now resolve from the root).
- [ ] Repoint the citers found by research: `README.md:362`, `docs/README.md:150,236,283`, `docs/development/README.md:54,69`, `docs/development/VERSIONING.md:316`, `docs/development/QUALITY_METRICS.md:287`, `docs/development/DIRECTORY_README_STANDARD.md:256`, `docs/installation/BASIC_INSTALLATION.md:193`, `docs/user-guide/MCP_INTEGRATION.md:60`, `docs/user-guide/architecture.md:1517`, `docs/user-guide/tutorial.md:436`, `docs/project-info/MAINTENANCE.md:672`.
- [ ] Leave `docs/development/PUBLICATION_REFACTOR.md`'s mentions alone (programme text, not links to repair) and leave `specs/**` mentions alone (historical record, out of scope).
- [ ] Re-grep for `CONTRIBUTING` outside `specs/` and confirm every remaining reference resolves.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 14 citer sites outside `specs/`, enumerated above from a research-time grep.
Confirm at implementation time with `grep -rn 'CONTRIBUTING' --include='*.md' . | grep -v '^\./specs/' | grep -v '^\./\.claude/'`
and treat C13 (`PASS C13`) as the closing authority on link resolution, not the count.

**Files to modify**:
- `docs/development/CONTRIBUTING.md` -> `CONTRIBUTING.md` (moved; internal relative links rewritten)
- `README.md`, `docs/README.md`, `docs/development/README.md`, `docs/development/VERSIONING.md`, `docs/development/QUALITY_METRICS.md`, `docs/development/DIRECTORY_README_STANDARD.md`, `docs/installation/BASIC_INSTALLATION.md`, `docs/user-guide/MCP_INTEGRATION.md`, `docs/user-guide/architecture.md`, `docs/user-guide/tutorial.md`, `docs/project-info/MAINTENANCE.md` - links repointed

**Verification**:
- `ls CONTRIBUTING.md` succeeds; `ls docs/development/CONTRIBUTING.md` fails.
- `grep -rn 'development/CONTRIBUTING.md' . | grep -v '^\./specs/'` returns only `docs/development/PUBLICATION_REFACTOR.md`.
- `bash scripts/check-module-invariants.sh` green (`PASS C13`).
- `bash scripts/readme-lint.sh` green.

---

### Phase 6: Remove personal absolute paths from `docs/` and `typst/` [NOT STARTED]

**Goal**: `grep -rn 'home/benjamin' docs typst` returns nothing, with provenance meaning
preserved where the path carried information.

**Tasks**:
- [ ] Re-run `grep -rn 'home/benjamin' docs typst` to get the live hit list (research found `typst/` already clean, and three files in `docs/`).
- [ ] `docs/development/DOC_QUALITY_CHECKLIST.md` (3 hits): the literal `cd /home/benjamin/Projects/BimodalLogic` lines in example shell blocks — drop the `cd` line or replace with "from the repository root".
- [ ] `docs/reference/paper-definitions-of-record.md` (5 hits): these name an unvendored external checkout (`/home/benjamin/Philosophy/Papers/PossibleWorlds/...`) as provenance. Genericise to `~/Philosophy/Papers/PossibleWorlds/...` or describe it as "the maintainer's local, unvendored checkout", **preserving** the repo name, commit hash and checksum that make the provenance verifiable.
- [ ] `docs/development/PUBLICATION_REFACTOR.md` (4 hits): all four quote this task's own acceptance grep. Reword each to describe the check in prose per the Decisions Adopted section, so the acceptance command can genuinely return empty without losing the criterion's meaning.
- [ ] Confirm `typst/` is still clean (a recent commit appears to have fixed it incidentally; do not assume).

**Timing**: 0.75 hours

**Depends on**: 2, 4

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 12 occurrences across 3 files in `docs/`, 0 in `typst/`, as of research
time. The live `grep -rn 'home/benjamin' docs typst` at implementation time is authoritative;
work from its output, not from this list, and repeat it after each file until empty.

**Files to modify**:
- `docs/development/DOC_QUALITY_CHECKLIST.md` - genericise example shell blocks
- `docs/reference/paper-definitions-of-record.md` - genericise provenance paths, keep commit/checksum
- `docs/development/PUBLICATION_REFACTOR.md` - reword the four quoted acceptance lines into prose

**Verification**:
- `grep -rn 'home/benjamin' docs typst` returns nothing (exit status 1).
- `bash scripts/check-module-invariants.sh` green (C9D scans `docs/`).
- `bash scripts/readme-lint.sh` green.

---

### Phase 7: Normalise `Logos`/`ProofChecker`/`lakefile.lean` naming [NOT STARTED]

**Goal**: Stale package-name usages in the surviving docs name the real artifacts
(`FormalSystem`, `BimodalLogic`, `lakefile.toml`), while every legitimate external-project and
role-name usage is preserved.

**Tasks**:
- [ ] Re-run the naming greps against the **post-removal** tree: `grep -rn 'Logos' README.md docs/` and `grep -rn 'ProofChecker' README.md docs/` (scope roughly halves once `docs/research/` is untracked).
- [ ] Classify every hit into one of three buckets before editing anything:
      (a) **stale Lean-package usage** — `import Logos`, `Logos.ProofSystem`, `Logos.Core.Automation.ProofSearch`, `open Logos.Syntax` in `docs/user-guide/tutorial.md`, `tactic-development.md`, `examples.md` -> rewrite to `FormalSystem`;
      (b) **legitimate external-project reference** — "Logos Laboratories", "the broader Logos project", `https://logos-labs.ai/` -> **leave untouched**;
      (c) **loose literal-name misuse** — e.g. `docs/user-guide/troubleshooting.md:53` "Ensure you're in the ProofChecker root directory", `docs/user-guide/quickstart.md:8` "ProofChecker project cloned and built" -> normalise to the repository name (`BimodalLogic`) or generic phrasing ("the repository root").
- [ ] Leave `README.md`'s and `docs/README.md`'s deliberate `ProofChecker`-as-role-name framing intact (it matches the documented naming convention and `docs/README.md` already carries the disambiguation blockquote).
- [ ] Leave `docs/development/PUBLICATION_REFACTOR.md`'s 5 self-referential mentions intact.
- [ ] Absorbed task-610 scope: fix the stale `lakefile.lean` mentions at `docs/user-guide/architecture.md:1131`, `docs/development/LEAN_STYLE_GUIDE.md:790`, `docs/user-guide/troubleshooting.md:55`, `docs/development/NAMING_CONVENTION_DEVIATION.md:333`, then re-grep the whole tree for any other `lakefile.lean` or stale `Logos` package-name mention outside `specs/`.
- [ ] Confirm `CITATION.cff` needs no edit (`grep -c 'Logos\|ProofChecker' CITATION.cff` -> 0; its `logos-labs.ai` email is bucket (b)).
- [ ] Commit per file or per small file group; do **not** run a single tree-wide regex substitution.

**Timing**: 2 hours

**Depends on**: 5, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: after the Phase-4 removal, roughly 30 files outside `docs/research/` carry
`Logos`/`ProofChecker` hits (~65 and ~75 occurrences respectively), concentrated in
`docs/user-guide/architecture.md` (18), `docs/development/LEAN_STYLE_GUIDE.md` (~19) and
`docs/architecture/ADR-001-Classical-Logic-Noncomputable.md` (9). Re-derive the live list with the
two greps in the first checklist item; if the classified bucket-(a)+(c) set materially exceeds
this estimate, split this phase at a file boundary into 7.1 and 7.2 rather than overrunning a
single dispatch.

**Files to modify**:
- `docs/user-guide/tutorial.md`, `docs/user-guide/tactic-development.md`, `docs/user-guide/examples.md` - stale `import Logos`-style code examples
- `docs/user-guide/troubleshooting.md`, `docs/user-guide/quickstart.md`, `docs/user-guide/architecture.md`, `docs/development/LEAN_STYLE_GUIDE.md`, `docs/development/NAMING_CONVENTION_DEVIATION.md`, `docs/architecture/ADR-001-Classical-Logic-Noncomputable.md` and the remaining classified files - literal-name normalisation and `lakefile.lean` -> `lakefile.toml`
- `CITATION.cff` - **no change expected**; verify only

**Verification**:
- `grep -rn 'import Logos\|Logos\.\(ProofSystem\|Core\|Syntax\)' README.md docs/` returns nothing.
- `grep -rn 'lakefile\.lean' . | grep -v '^\./specs/' | grep -v '^\./\.claude/'` returns nothing.
- Every surviving `Logos`/`ProofChecker` hit in `README.md` + `docs/` is individually justifiable as bucket (b) or as the documented role-name framing; spot-check the full list once more before closing.
- `bash scripts/check-module-invariants.sh` green.
- `bash scripts/readme-lint.sh` green.

---

### Phase 8: Final acceptance gate and summary [NOT STARTED]

**Goal**: The task's three stated acceptance criteria pass on the final tree, and the outcome is
recorded.

**Tasks**:
- [ ] `bash scripts/check-module-invariants.sh` -> `ALL CHECKS PASSED`.
- [ ] `bash scripts/readme-lint.sh` -> `Missing READMEs: 0   Broken file references: 0   RESULT: PASS`.
- [ ] `grep -rn 'home/benjamin' docs typst` -> empty.
- [ ] `git status --short` review: confirm nothing under `specs/` was untracked or deleted, and that the working tree holds no unintended residue.
- [ ] `git ls-files | wc -l` before/after comparison recorded in the summary (expect a drop of roughly 18 `latex/` + 15 `docs/research/` + 4 `docs/training/` + 4 dotfiles + 4 scripts + 1 `LATEX_STANDARDS.md`, offset by +1 for `scripts/README.md`; `CONTRIBUTING.md` is a move, not a net change).
- [ ] Write `specs/631_deliverable_hygiene_excluding_specs/summaries/01_deliverable-hygiene-summary.md`.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4, 5, 6, 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the expected tracked-file delta above is an estimate derived from the
per-phase counts. Record the actual before/after `git ls-files | wc -l` figures in the summary;
a material divergence from the estimate means a phase removed more or less than it declared and
must be investigated before the task closes.

**Files to modify**:
- `specs/631_deliverable_hygiene_excluding_specs/summaries/01_deliverable-hygiene-summary.md` - new

**Verification**:
- All three acceptance commands pass as stated above.
- No `specs/` path appears in the task's cumulative diff other than this task's own artifacts.

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` exits 0 with `ALL CHECKS PASSED` (baseline is green; this must not regress). No `lake build` is needed — this task makes no Lean change.
- [ ] `bash scripts/readme-lint.sh` exits 0 with `RESULT: PASS`, `Broken file references: 0`.
- [ ] `grep -rn 'home/benjamin' docs typst` produces no output.
- [ ] `git ls-files | grep -E '^(CLAUDE\.md|\.claude-extensions\.json|\.syncprotect|\.gitattributes)$'` produces no output.
- [ ] `git ls-files latex/ docs/research docs/training` produces no output.
- [ ] `git ls-files specs/ | wc -l` is unchanged from the pre-task value (the `specs/` exclusion is honoured).
- [ ] `ls CONTRIBUTING.md scripts/README.md` both succeed.

## Artifacts & Outputs

- `specs/631_deliverable_hygiene_excluding_specs/plans/01_deliverable-hygiene.md` (this plan)
- `specs/631_deliverable_hygiene_excluding_specs/summaries/01_deliverable-hygiene-summary.md` (Phase 8)
- `scripts/README.md` (new deliverable file)
- `CONTRIBUTING.md` at the repository root (relocated)
- Updated `.gitignore`
- Deleted from the tracked tree: `latex/**`, `docs/development/LATEX_STANDARDS.md`, the four one-off scripts, `.gitattributes`
- Untracked but retained on disk: `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, `docs/research/**`, `docs/training/**`

## Rollback/Contingency

Every phase is committed separately (`atomic-batch` only where declared), so the ordinary
contingency is `git revert` of the offending phase commit — no working-tree discard is involved
and no snapshot is required.

If a phase must be abandoned mid-way with uncommitted edits in the tree, take a durable
non-reverting checkpoint first with `bash .claude/scripts/git-snapshot.sh 631 --no-revert`, which
preserves the work without touching the working tree. A genuine whole-tree rollback (discarding
uncommitted work) is the only case that uses the default reverting mode of that script; see
`.claude/context/contracts/recovery.md`'s rollback rung for the exact invocation, including its
out-of-scope override flag.

Untracking is fully reversible without history archaeology: `git add -f <path>` restores tracking
for any of `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, `docs/research/`,
`docs/training/`, since their contents remain on disk throughout. The deletions
(`latex/**`, `docs/development/LATEX_STANDARDS.md`, the four scripts, `.gitattributes`) are
recoverable from git history via `git checkout <pre-task-sha> -- <path>`.
