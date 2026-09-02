# Implementation Plan: Spherical → Saturation axiom rename

- **Task**: 517 - Rename the fourth task-frame axiom from `Spherical` to `Saturation`
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: 518 (landed — baseline commit `92b154ab2` includes it)
- **Research Inputs**: `specs/517_rename_spherical_axiom_to_saturation/reports/01_spherical-to-saturation-occurrence-inventory.md`
- **Artifacts**: plans/01_spherical-to-saturation-rename.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The paper (`possible_worlds.tex`) renamed the fourth task-frame axiom from *Spherical* to
*Saturation*; the repository still uses the old name at 444 sites across 40 non-`specs/` files.
The research report established that the semantic partition the task brief asked about — "does
this occurrence name the axiom or the weaker standard ball-space condition?" — collapses to a
single checkable rule: the KEEP set is **exactly** the three occurrences inside the literal
phrase "spherically complete". That turns 444 judgment calls into one sentinel-guarded global
substitution plus a short list of hand edits, with a mechanical post-condition
(`git grep -io "spherical" | grep -v "^specs/" | wc -l == 3`) standing in for a manual audit.

The plan's shape is dictated by a build fact, not by a preference: `TaskFrame.lean` is
transitively imported by essentially the whole tree, and Lean invalidates on whole-file hash, so
*every* verification build here is a full rebuild of ~646 modules. The plan therefore runs **one
atomic edit followed by one detached, guarded build** rather than N phases each ending in a
build.

Definition of done: the tree names the axiom `Saturation` everywhere it names the axiom, the
three "spherically complete" occurrences survive verbatim, `lake build` exits 0,
`check-module-invariants.sh` exits 0, and no gate acquires a violation it did not already have.

### Research Integration

Findings carried into this plan, each re-verified against the live tree at `92b154ab2` while
writing it (this plan is not taking the report on trust — see the Scope Hypothesis lines):

- **Census** — `git grep -io spherical` outside `specs/` returns **444** across **40 files**;
  `spherically` returns **3**. Both re-measured; both match the report.
- **KEEP set** — `FormalSystem/Semantics/TaskFrame.lean:393`, `:394`, `README.md:80`. Line 394 is
  the only line carrying both partitions (`"Spherical"` renames, `"spherically complete"` stays);
  the sentinel pass handles it with no hand edit.
- **One irregular token** — `sphericality` at `TaskFrame.lean:513` ("seriality, limit and
  sphericality") must become `saturation`, not `saturationity`. Handled by a dedicated pass
  *before* the global substitution.
- **Paper-anchor axis** — the paper renamed both anchors. Verified directly against the live
  paper source: `\item[\it Saturation:]` at paper lines 976/2837, `\label{cor:saturation-finite}`
  at paper line 3144. Both replacement checksums were re-derived independently via
  `check-paper-definitions.sh --resolve` and match the report exactly (see Phase 2, Step 2.6).
- **C15 gating** — `def:frame#Spherical` → `def:frame#Saturation` is C15-neutral (C15's regex
  stops before `#`). `cor:spherical-finite` → `cor:saturation-finite` **is** C15-gated: the
  citations and the MANIFEST row must land in the same commit. This is what forces
  `Commit Mode: atomic-batch` on Phase 2.
- **Two brief corrections** — the rename is **26 identifiers, not "roughly 30"**; and two
  in-scope files the brief did not list carry occurrences: `FormalSystem/Semantics/FrameAxioms.lean`
  (17 — the largest undeclared site) and `scripts/check-module-invariants.sh` (1, a code comment).
- **Homonym** — `FormalSystem/Metalogic/Decidability/Saturation.lean` exists (tableau saturation)
  but declares no `Saturation` namespace, so there is no identifier conflict. One disambiguating
  line goes into the renamed docstring; nothing more.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so no roadmap consultation was
performed and no roadmap phases are included. (`specs/ROADMAP.md` exists in the repository but
was not passed to this planning dispatch.)

## Goals & Non-Goals

**Goals**:

- Rename the axiom to `Saturation`/`saturation` at all 441 RENAME-class occurrences across the
  40 non-`specs/` files, including the 26 Lean identifiers and the test file's own name.
- Preserve all 3 KEEP-class occurrences ("spherically complete") verbatim.
- Move both paper anchors to the identifiers the paper now uses, with
  `specs/paper-definitions-of-record.md`'s two MANIFEST rows updated in the same commit.
- Remove the interim note at `README.md:80` saying the Lean sources still use the old name.
- Leave `lake build` and `check-module-invariants.sh` green, and every other gate no worse than
  its measured pre-edit baseline.

**Non-Goals**:

- **Absorbing the unrelated paper drift.** `check-paper-definitions.sh` is red at HEAD with 10
  drifted anchors (`def:task-relation`, `def:directed`, `def:frame`, `def:frame#Compositionality`,
  `def:frame#Seriality`, `def:frame#Limit`, `def:world-history`, `thm:extension`,
  `def:BLplus-defined`, `def:time-shift-histories`). Most are `\bf` → `\it` cosmetics, but at
  least two are substantive (`def:time-shift-histories` dropped its explicit translation function;
  `def:BLplus-defined` changed item emphasis). This task will take the anchor count from 2
  unresolvable to 0 and will not touch the 10. Flag for a follow-up task.
- **Fixing `typst-sync-check.sh`.** Its 2 Check-1 violations are aesop attributes introduced by
  task 518 and are unrelated to this rename.
- **Fixing `check-evidence-probes.sh` / `readme-lint.sh`.** Both red for unrelated reasons.
- **Rewriting `specs/**` history.** The 227 occurrences in historical task artifacts stay. The
  only `specs/` writes here are the two MANIFEST rows plus a dated record entry.
- **The `sInter_nonempty_of_*` helper family.** These names carry no axiom name and are not
  renamed. Downstream work (the Wave 2 core-utilities task) collapses them; that is its business,
  not this task's.
- **Collapsing the seven duplicated "deterministic frame ⇒ Spherical" proofs.** That is the Wave 2
  task, which is explicitly sequenced *after* this one.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Global substitution clobbers a "spherically complete" occurrence | H | M | Sentinel pass protects the token before the global pass and restores it after; post-condition grep asserts exactly 3 survivors and that all 3 sit inside "spherically complete" |
| `sphericality` → `saturationity` | M | H (if unguarded) | Dedicated pass on `TaskFrame.lean` runs *first*; post-condition greps for `saturationity` and asserts 0 |
| C15 fails because citations moved but the MANIFEST row did not | H | M | `Commit Mode: atomic-batch` — one commit carries both; Phase 2 runs `check-module-invariants.sh` before committing |
| `#guard_msgs` expected-output strings go stale — these are compile-checked, so a miss is a **build error**, not a warning | H | M | The 5 pinned strings all contain the stem and are covered by the global pass; Phase 2 Step 2.8 greps the test file for any surviving `spherical` before the build |
| Build timeout too short — the research report's `--timeout 1800` was calibrated on a *fully cached* 13 s build, not on the full ~646-module rebuild this edit forces | M | M | Use `--timeout 7200`; run detached via `run_in_background: true`; treat the wall time as a hypothesis to be measured, not asserted |
| `lake-build-guard.sh` refuses an empty wrapped-command vector at **exit 77** without running any build, silently looking like a fast pass | M | H (if the report's command form is copied verbatim) | The lake subcommand goes **after** `--`: `... --timeout 7200 -- build`. The report's `build --timeout 1800 --` form is wrong and must not be used |
| Stale `.olean` for the removed `BimodalTest.Semantics.SphericalFiniteAxiomTest` module | L | L | Lake ignores orphaned oleans; if the build complains, `rm -rf .lake/build/lib/BimodalTest/Semantics/SphericalFiniteAxiomTest.*` and rebuild |
| Substitution touches a file outside the intended set | M | L | The file list is computed once by `git grep -il` and frozen to a variable; `git status --short` reviewed against it before committing |
| Sentinel token already present in a target file | L | L | Phase 1 asserts the sentinel is absent from every target file before any edit |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential by
construction: Phase 2's post-condition is defined relative to Phase 1's measured baseline, and
Phase 3's edits reference paths that only exist after Phase 2's `git mv`.

---

### Phase 1: Capture the pre-edit baseline [COMPLETED]

**Goal**: Establish, at the actual pre-edit HEAD, the numbers that Phase 2's and Phase 3's
acceptance criteria are stated *relative to*. Acceptance for this task is "no NEW violations",
not "all green" — three gates are already red for reasons this task did not create, so the
baseline has to be a measurement, not an assumption.

**Tasks**:

- [x] Record the working HEAD (`git rev-parse HEAD`) and confirm the tree is clean apart from
      any in-flight `specs/` bookkeeping.
- [x] Re-measure the census and record all four numbers: *(deviation: altered — the `saturationity` census command needs the `grep -v "^specs/"` exclusion the plan applies to the other three; unexcluded it returns 8, all of them the plan/report prose that names the token. Outside `specs/` it is 0 as expected.)*
      ```bash
      git grep -io "spherical"   -- . | grep -v "^specs/" | wc -l   # expect 444
      git grep -io "spherically" -- . | grep -v "^specs/" | wc -l   # expect 3
      git grep -il "spherical"   -- . | grep -v "^specs/" | wc -l   # expect 40
      git grep -io "saturationity" -- . | wc -l                     # expect 0
      ```
- [x] Freeze the target file list to a file so Phase 2 and the post-commit review use the same
      set: `git grep -il "spherical" -- . | grep -v "^specs/" > /tmp/517-files.txt`.
- [x] Assert the sentinel token is absent from every target file:
      `grep -l 'SPHLYSENTINEL' $(cat /tmp/517-files.txt)` must return nothing (exit 1).
- [x] Capture gate baselines, saving full output for later diffing:
      - `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — expect exit 0
        (cached; fast at this point because nothing has been touched yet)
      - `bash scripts/check-module-invariants.sh` — expect exit 0, `ALL CHECKS PASSED`
      - `bash scripts/typst-sync-check.sh` — expect exit 1, `TOTAL_VIOLATIONS=2`, both
        `@[aesop norm unfold]` / `@[aesop safe forward]` in `typst/chapters/p4-proof-automation.typ`
      - `bash scripts/check-paper-definitions.sh` — expect exit 1, `10 recorded definition(s)
        drifted`, `2 recorded anchor(s) could not be resolved` (`def:frame#Spherical`,
        `cor:spherical-finite`)
- [x] Take a snapshot before the batch edit: `bash .claude/scripts/git-snapshot.sh 517`. *(deviation: altered — `git-snapshot.sh 517` reverted the uncommitted `specs/` bookkeeping to HEAD; restored via `git stash apply stash@{0}`. The snapshot itself is intact as `git-snapshot-1788327852`.)*

**Timing**: 0.5 hours (dominated by `check-paper-definitions.sh`, which re-resolves 47 anchors
against a 438 KB paper source)

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts the census figures 444 / 3 / 40 / 0 and the four gate
baselines (build 0; invariants 0; typst 1 with exactly 2 violations; paper-definitions 1 with 10
drifted + 2 unresolvable). All eight were measured at `92b154ab2` while this plan was written and
matched. Confirm by re-running the commands above and comparing; if any figure differs, the tree
moved and Phase 2's post-condition must be re-derived before editing.

**Files to modify**: none (measurement only; `/tmp/517-files.txt` is scratch, not a deliverable)

**Verification**:
- All four census numbers match the expectations above, or a discrepancy is recorded and
  reconciled before Phase 2 starts.
- Sentinel-absence check returns nothing.
- Baseline outputs are saved and referenceable from Phase 2 and Phase 3.

---

### Phase 2: Apply the complete rename and verify with one full build [COMPLETED]

**Goal**: Land the entire rename — substitution, irregular token, file rename, hand edits,
MANIFEST rows — as one atomic change, assert the mechanical post-condition, then run exactly one
detached guarded build plus the full gate set, and commit once.

**Tasks**:

- [x] **2.1 Irregular token first.** `sed -i 's/[Ss]phericality/saturation/g'
      FormalSystem/Semantics/TaskFrame.lean` — turns "seriality, limit and sphericality" (line
      513) into "seriality, limit and saturation". This MUST precede the global pass, which would
      otherwise produce `saturationity`.
- [x] **2.2 Protect the KEEP set.** `sed -i 's/spherically/SPHLYSENTINEL/g' $(cat /tmp/517-files.txt)`
      — 3 sites (`TaskFrame.lean:393`, `:394`, `README.md:80`).
- [x] **2.3 Global substitution.**
      `sed -i -e 's/Spherical/Saturation/g' -e 's/spherical/saturation/g' $(cat /tmp/517-files.txt)`.
      This one pass covers the 26 identifiers, all 21 `spherical := …` field-assignment sites, the
      5 compile-checked `#guard_msgs` expected-output strings, the typst macro `leanSpherical` and
      its `raw("spherical")` body, the `SphericalFiniteAxiomTest` module name at all 5 citation
      sites (including the build-breaking `Tests/BimodalTest.lean:15` import and the C12-gated
      `BiLasso/README.md:56` path), the whitelist entries, and both paper anchors.
- [x] **2.4 Restore the KEEP set.** `sed -i 's/SPHLYSENTINEL/spherically/g' $(cat /tmp/517-files.txt)`.
      After this, `TaskFrame.lean:394` reads
      `"Saturation" is not a synonym for "spherically complete"; reading it as one understates the axiom.`
      — the one line carrying both partitions, resolved without a hand edit.
- [x] **2.5 Rename the test file.**
      `git mv Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`.
      Do this *after* the substitution, since the file list was captured under the old path.
      `lakefile.lean` uses ``roots := #[`BimodalTest]``, so no lakefile edit is needed.
- [x] **2.6 Update the two MANIFEST rows** in `specs/paper-definitions-of-record.md` (between the
      `<!-- MANIFEST:BEGIN -->` / `<!-- MANIFEST:END -->` sentinels; this file is outside the
      substitution set because `specs/` is excluded). Both checksums below were re-derived
      independently via `check-paper-definitions.sh --resolve` against the live paper while this
      plan was written:
      ```
      # line ~1319, was: def:frame#Spherical|item|def:frame|Spherical|92b407bc45ab62ce5bac22982c67e2555efb4a990ddf8e61fd7f1b45840bcf60
      def:frame#Saturation|item|def:frame|Saturation|c293e9f830a2e1f0154d1ee7be2c7a121a7aa0ec4476266637e4fffaff345c60

      # line ~1354, was: cor:spherical-finite|env|-|-|26ed8ff4c8b01f1dde980e075bc2e0bd45571951be82160bb184d59227b9f7b3
      cor:saturation-finite|env|-|-|6456eb11cb2adf8b06c929c3f6b5d19dc581f9ba7a33af8a28e61ec675567d74
      ```
      Change **only** these two MANIFEST rows here. The prose elsewhere in that file (the drift
      tables at ~line 452, the quoted footnote at ~line 495, the resolved-text block at
      ~1078–1081) is a **historical record of what the paper said at the time** — rewriting it
      would falsify the record. The `KNOWN-ANCHORS` block was checked and contains neither anchor.
- [x] **2.7 Hand-edit `README.md:80`.** Delete the interim sentence outright — after substitution
      it reads *"The Lean sources still carry this axiom under its former name *Saturation*
      (`TaskFrame.Saturation`, the `saturation` field of `FrameOver`); renaming them to match is
      pending."* Deleting it drops README from 4 occurrences to 1 (the KEEP occurrence).
- [x] **2.8 Add the homonym disambiguation.** One line in the renamed `TaskFrame.Saturation`
      docstring (around `TaskFrame.lean:412`) noting that this is unrelated to the tableau
      saturation of `FormalSystem/Metalogic/Decidability/Saturation.lean`. That module declares no
      `Saturation` namespace, so this is a reader aid, not a conflict fix.
- [x] **2.9 Assert the post-condition** — this is the substitute for a 444-site manual audit and *(deviation: altered — assertions C (`SPHLYSENTINEL`) and D (`saturationity`) need the `grep -v "^specs/"` exclusion assertion A already carries; unexcluded they return 2 and 8, every hit being this plan's and the Phase 1 handoff's own prose naming the tokens. With the exclusion applied all six assertions hold.)*
      is a hard gate on proceeding:
      ```bash
      git grep -io "spherical" -- . | grep -v "^specs/" | wc -l    # MUST be exactly 3
      git grep -in "spherical" -- . | grep -v "^specs/"            # all 3 inside "spherically complete"
      git grep -l  "SPHLYSENTINEL" -- .                            # MUST be empty
      git grep -io "saturationity" -- . | wc -l                    # MUST be 0
      git grep -in "spherical" -- Tests/                           # MUST be empty (#guard_msgs safety)
      git grep -o  "cor:spherical-finite\|def:frame#Spherical" -- . | grep -v "^specs/" | wc -l  # MUST be 0
      ```
- [x] **2.10 One detached, guarded build.** Run under `Bash(run_in_background: true)`: *(deviation: altered — the `--timeout 7200` lock-wait budget was used as written, but the rebuild measured **345 s** (2521 jobs), not the multi-thousand-second full re-elaboration the figure anticipated. The 7200 hypothesis is disconfirmed on the low side; 1800 would have been ample. Detachment was still required — 345 s exceeds the 120 s default foreground cap.)*
      ```bash
      bash .claude/scripts/lake-build-guard.sh build --timeout 7200 -- build
      ```
      **The lake subcommand goes after `--`.** The form `build --timeout 1800 --` passes an empty
      wrapped-command vector and the guard refuses it at **exit 77 without running any build** —
      a silent false pass. The timeout is raised from the report's 1800 because that figure was
      calibrated on a fully-cached 13 s build; this edit invalidates `TaskFrame.lean` and forces a
      full re-elaboration of ~646 modules.
- [x] **2.11 Run the gate set** once the build exits 0:
      - `bash scripts/check-module-invariants.sh` — MUST exit 0. C15 must still report every
        anchor resolving; this is where a missed MANIFEST row surfaces.
      - `bash scripts/typst-sync-check.sh` — MUST show `TOTAL_VIOLATIONS=2`, the same two aesop
        entries as the Phase 1 baseline and no others.
      - `bash scripts/check-paper-definitions.sh` — still exit 1, but the unresolvable count MUST
        drop from 2 to 0 and the drifted count MUST remain 10 (no new drift introduced).
- [x] **2.12 Review and commit once.** `git status --short` against `/tmp/517-files.txt` plus the
      two expected extras (`specs/paper-definitions-of-record.md`, the `git mv` rename pair);
      `git diff --staged` reviewed; then a single commit. Stage the specific paths — never
      `git add -A`.

**Timing**: 2 hours (roughly 45 min of edit and assertion work; the remainder is the full
rebuild, which runs detached)

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

This is a genuine pre-declared atomic batch, not a convenience. The `cor:spherical-finite` →
`cor:saturation-finite` citation rename and the MANIFEST row that makes it resolvable are
C15-coupled: split across two commits, the first commit is red at C15. Every intermediate
per-file state between Step 2.1 and Step 2.9 is expected red (the tree does not elaborate
mid-substitution) and MUST NOT be committed. The declared file set is exactly
`/tmp/517-files.txt` (40 files) plus `specs/paper-definitions-of-record.md` plus the `git mv`
rename pair. Widening this batch after the fact is not permitted; if new files turn out to need
edits, stop and re-derive the file list.

*Contingency if a single commit is judged too coarse*: the coupling can be broken by
**adding** the `cor:saturation-finite` MANIFEST row while leaving the old row in place (C15 stays
green — both anchors known), renaming the citations in a second commit, then removing the stale
row in a third. This costs a transient duplicate row and two extra full-gate runs, and is not the
default.

**Scope Hypothesis**: This phase asserts a 40-file substitution set, 26 renamed Lean identifiers,
21 field-assignment sites, 5 compile-checked `#guard_msgs` strings, 5 test-file citation sites,
and exactly 2 MANIFEST rows to change. The 40-file figure and the 3-survivor post-condition were
re-measured at `92b154ab2`; the 26/21/5/5 figures come from the research report and are **not**
independently re-counted here. Confirm at implementation time by the Step 2.9 assertions, which
are outcome-based and therefore catch a miscount in any of them regardless of whether the
underlying number was right — the post-condition, not the inventory, is the gate.

**Files to modify**:
- The 40 files in `/tmp/517-files.txt` — mechanical `Spherical`→`Saturation` /
  `spherical`→`saturation` substitution, with `spherically` preserved
- `FormalSystem/Semantics/TaskFrame.lean` — additionally: `sphericality` → `saturation` (Step
  2.1), homonym disambiguation line in the `Saturation` docstring (Step 2.8)
- `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` → `SaturationFiniteAxiomTest.lean`
  via `git mv`
- `README.md` — delete the interim note (Step 2.7)
- `specs/paper-definitions-of-record.md` — two MANIFEST rows only (Step 2.6)

**Verification**:
- Step 2.9's six assertions all hold.
- `lake build` (guarded, detached, `-- build` after the separator) exits 0.
- `check-module-invariants.sh` exits 0 with `ALL CHECKS PASSED`.
- `typst-sync-check.sh` reports `TOTAL_VIOLATIONS=2`, identical to the Phase 1 baseline.
- `check-paper-definitions.sh` reports 10 drifted and **0** unresolvable.
- Exactly one commit; `git status --short` shows no file outside the declared batch.

---

### Phase 3: Documentation coherence and record absorption [NOT STARTED]

**Goal**: Close the prose-level loose ends the substitution cannot reach. Every edit here is in
markdown or LaTeX with zero Lean elaboration surface, so this phase does not trigger a second
rebuild and commits separately.

**Tasks**:

- [ ] Add a dated entry to `specs/paper-definitions-of-record.md` recording the anchor absorption:
      `def:frame#Spherical` → `def:frame#Saturation` and `cor:spherical-finite` →
      `cor:saturation-finite`, with the two new checksums, noting that this is a rename
      absorption rather than a drift correction and that the 10 remaining drifted anchors are
      untouched. Do **not** rewrite the historical drift tables or quoted paper text.
- [ ] Fix the pre-existing fidelity gap in `latex/subfiles/02-Semantics.tex` (lines ~77–78 and
      ~85): the transcription says "for any **directed** family" where the paper says "for any
      **⊇-directed** family". The Lean docstrings already carry the qualifier correctly
      (`TaskFrame.lean:386`). This is a one-line-per-site change that improves fidelity; call it
      out explicitly in the commit so it is not mistaken for a rename artifact. No gate depends
      on it.
- [ ] Add the missing row for `SaturationFiniteAxiomTest.lean` to
      `Tests/BimodalTest/Semantics/README.md`, whose file table lists only 4 of the 6 `.lean`
      files in the directory. (`DependentUltraproductProbe.lean` is also missing; add it in the
      same pass or leave it — record which.)
- [ ] Re-run `bash scripts/check-module-invariants.sh` — C12 checks that slash-shaped source
      paths in markdown resolve, and this phase adds new ones. MUST stay exit 0.
- [ ] Record the two out-of-scope follow-ups in the implementation summary so they are not lost:
      (a) the 10 drifted paper anchors, two of them substantive; (b) the 2 aesop violations in
      `typst-sync-check.sh` owned by task 518's territory.
- [ ] Commit.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: prose

Every edit in this phase lies in markdown or LaTeX prose with no compile or elaboration surface.
The tier's declared blind spot — a doc comment that is actually load-bearing — is covered here by
re-running `check-module-invariants.sh`, since C12's markdown-path resolution *is* a live check
over exactly the kind of text this phase adds.

**Scope Hypothesis**: This phase asserts that `latex/subfiles/02-Semantics.tex` has the missing
`⊇` qualifier at 2 sites and that `Tests/BimodalTest/Semantics/README.md` lists 4 of 6 `.lean`
files. Both come from the research report and were not independently re-counted here. Confirm by
`grep -n "directed family" latex/subfiles/02-Semantics.tex` and by comparing
`ls Tests/BimodalTest/Semantics/*.lean` against the README's table before editing; adjust the
edit to whatever is actually there.

**Files to modify**:
- `specs/paper-definitions-of-record.md` — append a dated absorption entry
- `latex/subfiles/02-Semantics.tex` — add the `⊇` qualifier at the directed-family sites
- `Tests/BimodalTest/Semantics/README.md` — add the missing file-table row(s)

**Verification**:
- `check-module-invariants.sh` exits 0 (C12 in particular).
- `git grep -io "spherical" -- . | grep -v "^specs/" | wc -l` still returns 3.
- No Lean file touched, so no rebuild required; confirm with `git status --short`.

---

## Testing & Validation

- [ ] `git grep -io "spherical" -- . | grep -v "^specs/" | wc -l` returns exactly **3**, and all
      three are inside the phrase "spherically complete".
- [ ] `git grep -io "saturationity" -- . | wc -l` returns **0**.
- [ ] `git grep -l "SPHLYSENTINEL" -- .` returns nothing.
- [ ] `git grep -in "spherical" -- Tests/` returns nothing (the `#guard_msgs` strings are
      compile-checked; a stale one is a build error).
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 7200 -- build` exits **0**.
- [ ] `bash scripts/check-module-invariants.sh` exits **0** with `ALL CHECKS PASSED`.
- [ ] `bash scripts/typst-sync-check.sh` reports `TOTAL_VIOLATIONS=2` — the same two pre-existing
      aesop entries, no new ones. **Exit 1 here is the expected, accepted outcome.**
- [ ] `bash scripts/check-paper-definitions.sh` reports 10 drifted and **0** unresolvable (down
      from 2). **Exit 1 here is the expected, accepted outcome.**
- [ ] `Tests/BimodalTest.lean` imports `BimodalTest.Semantics.SaturationFiniteAxiomTest` and the
      test module elaborates.

**Acceptance is stated as "no NEW violations", deliberately.** `lake build` and
`check-module-invariants.sh` are the task's two stated gates and must be green. Three other
scripts are already red at HEAD for causes this task did not create — `typst-sync-check.sh`
(task 518's aesop attributes), `check-paper-definitions.sh` (10 drifted anchors),
`check-evidence-probes.sh` and `readme-lint.sh` (missing probe files, missing README/dates).
Stating acceptance as "all green" would fail this task for other tasks' debts.

## Artifacts & Outputs

- `specs/517_rename_spherical_axiom_to_saturation/plans/01_spherical-to-saturation-rename.md`
  (this plan)
- `specs/517_rename_spherical_axiom_to_saturation/summaries/01_{short-slug}-summary.md`
  (implementation summary, written at completion — must record the measured full-rebuild wall
  time, the final census, and the two out-of-scope follow-ups)
- Modified: 40 non-`specs/` files, one file rename (`SphericalFiniteAxiomTest.lean` →
  `SaturationFiniteAxiomTest.lean`), `specs/paper-definitions-of-record.md`
- Two commits: Phase 2's atomic batch, Phase 3's documentation pass
- Follow-up task recommendation: absorb the 10 drifted paper anchors in
  `specs/paper-definitions-of-record.md`, two of which are substantive

## Rollback/Contingency

Phase 1 takes a snapshot via `bash .claude/scripts/git-snapshot.sh 517` before any edit, so the
whole batch is recoverable in one step. Because Phase 2 is a single atomic commit, rollback is
`git revert` of that one commit — there is no half-renamed intermediate state to reason about.

Per-failure contingencies:

- **Post-condition returns more than 3** — some occurrence is outside the frozen file list, or a
  file gained an occurrence between Phase 1 and Phase 2. Re-run `git grep -il`, diff against
  `/tmp/517-files.txt`, and re-run the substitution on the delta. Do not hand-patch the
  survivors one by one.
- **Post-condition returns fewer than 3** — the sentinel restore failed or a KEEP occurrence was
  clobbered. `git diff` the three known KEEP sites and restore by hand; do not proceed to the
  build.
- **Build fails on a stale `#guard_msgs` string** — the expected-output docstring is out of date;
  fix it in place and rebuild. This is a one-line fix, not a rollback trigger.
- **Build fails on a stale olean for the removed module** —
  `rm -rf .lake/build/lib/BimodalTest/Semantics/SphericalFiniteAxiomTest.*` and rebuild.
- **Guard exits 77** — the wrapped-command vector was empty or malformed. No build ran; nothing
  is broken. Re-issue with `-- build` after the separator.
- **C15 fails after the batch** — a MANIFEST row was missed or mistyped. Fix the row and amend
  the commit before it is pushed anywhere; the citations and the row must remain in the same
  commit.
- **The full rebuild exceeds the 7200 s timeout** — this would be new information about the
  tree's build cost, not a defect in the rename. Re-run with a longer timeout and record the
  measured time in the summary.
