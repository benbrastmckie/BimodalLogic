# Implementation Plan: Task #726

- **Task**: 726 - Make the decidability-programme inventory re-runnable from the tree
- **Status**: [IMPLEMENTING]
- **Effort**: 7.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/726_rerunnable_decidability_programme_inventory/reports/01_rerunnable-inventory-mechanism.md`
- **Artifacts**: plans/01_rerunnable-inventory-mechanism.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Build `scripts/generate-decidability-inventory.sh`: a standing, dependency-free script that
regenerates the PROVED / NOT ESTABLISHED / WITHDRAWN / REFUTED inventory of the decidability
programme from three machine sources in the tree, cross-checks every `pinned:` cell in
`docs/theorem-index.md`'s Decidability section against the C2/C14 axiom baselines inside
`scripts/check-module-invariants.sh`, and diffs the result against a committed machine-readable
baseline extracted from the archived decidability-programme review. The script reports what the
tree says and never adjudicates: where a source is silent it emits `UNKNOWN`, and it fails loudly
rather than silently emitting an empty inventory when an expected anchor has been renamed. Done
means the script runs green from a clean checkout, catches a synthetic phantom `pinned:` claim,
surfaces the one already-known REFUTED-set drift as a diff line, is documented in
`scripts/README.md`, and is named in `specs/ROADMAP.md`'s Maintenance section as the owner of the
periodic re-run in place of this task.

### Research Integration

The research report settled every open design question this plan would otherwise have to guess at,
and all of its findings are carried into specific phases below:

- **Implementation shape is a standing script, not a `/review` step** (report §6). Decisive
  reasons: the `core` extension's deployed `.claude/` tree is currently stale relative to its
  source store, so a `/review`-step edit would not take effect in this repo without a redeploy
  and could be silently discarded; and a script in `scripts/` runs from a fresh clone with zero
  agent-system dependency, next to the two scripts it reads. A `/review` integration remains
  possible later as a thin step that shells out to this script. Recorded as a Decision below.
- **Source 1 semantics** (report §1): membership in `docs/theorem-index.md`'s Decidability table
  (45 data rows between `### Decidability` at line 145 and the next `### ` heading) is itself the
  mechanical proxy for PROVED, under that file's own stated charter. The script's job on source 1
  is to *verify each row's pin claim*, not to decide PROVED-ness.
- **The apostrophe-regex pitfall** (report §2): baseline-name extraction MUST use the greedy
  `re.findall(r"^'(.+)' depends on axioms", block, re.M)`. A `[^']+` character class silently
  fails on the tree's trailing-prime identifiers (`not_plusValidZTime_neg_θ'`,
  `no_finite_carrier_sat'`) and produced two false-positive mismatches in the research dispatch's
  own live test. `check-module-invariants.sh`'s C36 check already hit and documented this exact
  bug; its comment is the precedent to cite, not rediscover.
- **The cross-check design is already validated live** (report §1): run against the current tree
  it found 44 tagged rows plus the one documented `no axioms (proved by \`decide\`...)` exception,
  and **zero mismatches**. The motivating hand-found defect is currently clean, so the script's
  value is forward-looking regression protection — which is why Phase 2 verifies it by *injecting*
  a synthetic bad row rather than expecting a real finding.
- **WITHDRAWN cannot be regenerated from the three named sources** (report §4). Two of the four
  baseline WITHDRAWN entries are still live and still `pinned:C2` in `docs/theorem-index.md`
  today (a source-1-only read would call them PROVED); one (`exists_tailStable_repr`) names a
  declaration that exists nowhere in the tree, so no live scan can rediscover it; and the fifth
  entry's retirement is recorded in `PlusWitnessFamily/Incompleteness.lean`'s header, a fourth
  file outside all three sources. WITHDRAWN is therefore carried forward from the baseline and
  *verified*, never derived — Phase 4.
- **REFUTED has already drifted** (report §3): `WIRED` now holds 12 entries where the baseline's
  prose says eleven, the extra being
  `seam-gluing-ray-product/backward-dual-asymmetric-fixture`. This is a real, present,
  observable diff line and is Phase 6's acceptance witness.
- **Do not parse the free-text comment table above `WIRED=(`** (report §3, Decisions): it is
  continuation-indented prose with no fixed grammar. Emit probe paths and point at the table.
- **Several `WIRED` probes are PROVED, not REFUTED, in the baseline** (report §3): five
  `seam-gluing-ray-product/*` probes establish positive results and are read as probes only
  because they sit outside the Lake build graph. The script must report "wired probe, outside
  build graph" as its own dimension and surface the disagreement for a human, never pick a side.

One research statement is **stale as of this plan** and the plan corrects it: report §5 records
task 728's phantom-citation checker as not yet landed. It has since landed —
`scripts/check-phantom-citations.sh` exists in the tree at commit `3bfb970e4`. The dispatch's
"REUSE it rather than writing a second one" instruction is honoured by *not building a
phantom-citation check at all here*: this task's `pinned:`-cell cross-check targets index rows
against invariants baselines, a different check with different inputs, and the two stay separate
exactly as the dispatch requires. That landed script is also adopted as this plan's CLI and
header-documentation precedent (Phase 1), since it is the newest script in `scripts/` written to
this repo's current conventions.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch, so no roadmap context was loaded as a planning
input and no roadmap-review/roadmap-update wrapper phases are added. `specs/ROADMAP.md` is
nonetheless a deliberate *edit target* of this plan on the task description's own instruction:
its Maintenance section (lines 342-352) currently reads "Nobody owns the periodic re-run of the
decidability inventory until task 726 lands", and Phase 5 performs the hand-off by naming the
script as owner. The baseline path that section already cites
(`specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`)
is correct and current and is not changed.

## Goals & Non-Goals

**Goals**:
- A standing `scripts/generate-decidability-inventory.sh` that regenerates the four-status
  inventory from the three named machine sources, on demand, with no agent-system dependency.
- A mechanical `pinned:`-cell cross-check: every Decidability row claiming `pinned:C2` or
  `pinned:C14` is verified against the C2/C14 heredoc baselines inside
  `scripts/check-module-invariants.sh`, so a row claiming a pin with no baseline behind it is
  caught by the script rather than by a human reading carefully.
- A committed, machine-readable baseline (`scripts/decidability-inventory-baseline.txt`) derived
  reproducibly from section 1 of the archived review, plus a `--diff` mode that reports
  added/removed inventory entries against it.
- WITHDRAWN carried forward from that baseline and verified for drift (reappearance, lost pin,
  confirmed-still-absent), never re-derived.
- Loud failure on a missing anchor; `UNKNOWN` wherever a source is silent.
- `specs/ROADMAP.md`'s Maintenance section names the script as the periodic-re-run owner, and
  `scripts/README.md` documents the script and its data file.

**Non-Goals**:
- **No phantom-declaration-citation checker.** Owned by `scripts/check-phantom-citations.sh`
  (already landed). This plan builds nothing that overlaps it.
- **No adjudication.** The script never upgrades, downgrades, or reclassifies a status the three
  sources plus the carried-forward baseline do not state. It never resolves the
  PROVED-vs-REFUTED disagreement among the `seam-gluing-ray-product/*` wired probes; it reports
  both readings.
- **No complexity claim** of any kind in the generated output (explicit hard constraint).
- **No CI wiring.** `.github/workflows/ci.yml` is not touched. This is an on-demand review
  instrument, not a build gate; its only hard-failure condition (a pin mismatch) is already
  covered from the other side by C2/C14 themselves. The script ships a `--strict` mode so a
  future task can wire it without rework.
- **No edit under `.claude/**`.** Per `source-store-deploy-boundary.md` and the dispatch's
  deploy-freshness warning, nothing in the deployed tree is hand-authored. The one optional
  agent-system pointer (Phase 5) is written to the source store resolved from
  `.claude-extensions.json`'s `source_dir`, or skipped.
- **No new Lean code and no edit to `docs/theorem-index.md`, `check-module-invariants.sh`, or
  `check-evidence-probes.sh`.** All three are read-only sources here. The one exception is a
  deliberately reverted temporary edit inside Phase 2's negative test.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Naive `[^']+` baseline-name regex silently drops trailing-prime identifiers, producing false mismatches | H | H (it already happened twice in the research dispatch) | Use the greedy `re.findall(r"^'(.+)' depends on axioms", block, re.M)` verbatim and cite C36's own comment in the script header; Phase 2's test asserts the two known trailing-prime names resolve cleanly |
| An anchor is renamed later (`### Decidability`, `<<'BASELINE'`, `<<'C14BASE'`, the "Retired as vacuous" heading) and the script silently reports an empty inventory | H | M | Anti-silence guards: every anchor lookup fails loudly with a named non-zero exit, following C36's precedent. Phase 1 and Phase 3 each carry a negative test that renames an anchor in a scratch copy and asserts the loud failure |
| Parsing the free-text `WIRED` comment table for rationale produces a brittle second parser | M | M (tempting) | Explicit non-goal; emit probe paths and point at the table (research Decisions) |
| Treating every `WIRED` probe as REFUTED contradicts the baseline's own PROVED classification of five `seam-gluing-ray-product/*` probes | M | H if ignored | Report "wired probe, outside build graph" as a separate dimension and print the baseline's classification beside it; disagreement is surfaced, not resolved |
| Diffing the prose baseline report on every run is fragile (heterogeneous tables, prose-heavy cells) | M | H if attempted | One-time reproducible extraction into a committed data file via `--extract-baseline`; normal runs diff against the committed file, so the fragile parse runs only when a human re-derives it |
| Concurrent sibling tasks 722 and 728 are dispatched this same cycle with no declared `file_scope` and may touch `scripts/README.md` or `specs/ROADMAP.md` | M | M | Re-read each shared file immediately before editing; stage only this task's own hunks with an explicit file list (never a directory or glob `git add`); never run `git-snapshot.sh` in reverting mode; treat a foreign commit or modification as a stop-and-report condition after checking `git log` |
| Unicode mismatch (`θ`, `Φ`, precomposed vs. combining) across files edited at different times | M | L | Read every source as UTF-8 and compare raw Python strings with no normalization — the configuration the research dispatch's live test ran under, which produced zero false positives once the regex was fixed |
| A future reader mistakes the script's informational diff output for a gate verdict | L | M | Exit-status discipline is documented in the script header and enforced: non-zero only on a pin mismatch or a missing anchor; all diff output is informational and exits 0 |

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

Phases within the same wave can execute in parallel. This plan is fully sequential by design:
phases 1-4 and 6 all edit the single file `scripts/generate-decidability-inventory.sh`, so
serializing them avoids same-file collisions, and Phase 5's documentation edits depend on the
script's final CLI surface being fixed.

---

### Phase 1: Script skeleton, source-1 parser, anti-silence guards [COMPLETED]

**Goal**: `bash scripts/generate-decidability-inventory.sh` runs and prints the PROVED section —
every Decidability row in `docs/theorem-index.md` with its Lean name and `pinned:` tag — and fails
loudly if the section anchor is missing.

**Tasks**:
- [x] Create `scripts/generate-decidability-inventory.sh` as a `bash` driver with an inline
      `python3` payload invoked via a here-string, following `check-module-invariants.sh`'s C36
      pattern (report §6) and `check-phantom-citations.sh`'s overall file shape. *(completed)*
- [x] Write the header comment block in this repo's established style: WHY THIS EXISTS (static
      review artifacts drift; the next review should be a diff), WHAT IT READS (the three sources
      by path), WHAT IT DOES NOT DO (no adjudication, no complexity claim, no phantom-citation
      check — that is `check-phantom-citations.sh`'s, by this task's own record), LIMITATIONS,
      Usage, and Exit status. *(completed)*
- [x] Implement the CLI with the same conventions as `check-phantom-citations.sh`: `--verbose`,
      `--strict`, `--help` (via the `sed -n '2,Np' "$0" | sed 's/^# \{0,1\}//'` self-documenting
      idiom), unknown-argument `exit 2`, and a `ROOT` resolved from `BASH_SOURCE` so the script
      runs from any working directory. *(completed)*
- [x] Parse source 1: locate the literal `### Decidability` heading in `docs/theorem-index.md`,
      take rows up to the next `^### ` heading, skip the header and separator rows, and extract
      the Lean name (column 3, backticks stripped) and the Axioms cell (column 6). *(completed)*
- [x] Extract a `pinned:(C\d+)` tag per row; pass the single documented
      `no axioms (proved by \`decide\`; absent from the C2 baseline by construction, ...)` cell
      through unchanged as a named, non-defect exception — not as `UNKNOWN` and not as a finding. *(completed)*
- [x] Emit `UNKNOWN` for any row whose Axioms cell carries neither a `pinned:` tag nor that
      documented exception. *(completed)*
- [x] Anti-silence guard: if `### Decidability` is not found verbatim, or the section yields zero
      data rows, print a named failure and exit non-zero (never print an empty inventory). *(completed)*
- [x] Make the script executable (`chmod +x`), matching the other `scripts/*.sh`. *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research dispatch measured 45 data rows in the Decidability section, 44
carrying a `pinned:C2`/`pinned:C14` tag plus one documented `no axioms` exception, at
`docs/theorem-index.md:145`-194. Confirm at implementation time by running the script and
comparing its own row count against a direct
`sed -n '145,194p' docs/theorem-index.md | grep -c '^|'`; if the counts have drifted, report the
new numbers rather than assuming 45/44/1, and do not hardcode any of them in the script.

**Files to modify**:
- `scripts/generate-decidability-inventory.sh` - new file: driver, header, CLI, source-1 parser,
  anti-silence guard

**Verification**:
- `bash scripts/generate-decidability-inventory.sh` exits 0 and prints a PROVED section whose row
  count matches the independent `grep -c` above.
- `bash scripts/generate-decidability-inventory.sh --help` prints the header block and exits 0.
- `bash scripts/generate-decidability-inventory.sh --bogus-flag` exits 2.
- Negative test: in a scratch copy of `docs/theorem-index.md` under the session scratchpad,
  rename `### Decidability`; point the script at it (or temporarily at the copy) and confirm a
  named non-zero failure rather than an empty inventory. The real file is not modified.
- `bash -n scripts/generate-decidability-inventory.sh` parses clean.

---

### Phase 2: `pinned:`-cell cross-check against the C2/C14 baselines [COMPLETED]

**Goal**: Every tagged Decidability row's Lean name is verified to be a member of the baseline its
tag names, and a row claiming `pinned:C14` with nothing behind it in the C14 baseline is a loud,
non-zero failure. This is the task's motivating defect class and the script's only hard-failure
condition on its own content.

**Tasks**:
- [x] Read `scripts/check-module-invariants.sh` as text and extract the two baseline heredocs with
      `re.search(r"<<'TAG'\n(.*?)\nTAG\n", text, re.S)`: `BASELINE` (C2, at lines 1114-1165) and
      `C14BASE` (C14, at lines 2057-2260). *(completed)*
- [x] Extract declaration names from each block with the greedy
      `re.findall(r"^'(.+)' depends on axioms", block, re.M)` — **never** a `[^']+` class. Cite
      C36's own comment in an inline comment at this exact site, so the next reader does not
      "simplify" it back to the broken form. *(completed)*
- [x] Anti-silence guard on both heredocs: a missing `<<'BASELINE'`/`<<'C14BASE'` anchor, or a
      block yielding zero names, is a named non-zero failure. *(completed)*
- [x] For every tagged row, assert membership in the baseline set its tag names; collect
      mismatches as `(lean_name, claimed_tag)` pairs. *(completed)*
- [x] Report each mismatch with the row's line number in `docs/theorem-index.md`, the claimed tag,
      and the fact that the name is absent from that baseline. Exit non-zero on any mismatch. *(completed)*
- [x] Read all files as UTF-8 and compare raw strings with no Unicode normalization step. *(completed)*
- [x] Document in the header that this is the one hard-failure condition arising from the
      script's own analysis, and why everything else is informational. *(completed)*

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research dispatch measured 50 names in the C2 baseline (matching that
script's own "all fifty pinned axiom sets match baseline" message) and 202 in the C14 baseline,
with 0 mismatches against the 44 tagged rows. Confirm by printing the script's own extracted
counts under `--verbose` and comparing against `check-module-invariants.sh`'s own reported fifty;
report drift rather than assuming 50/202/0, and hardcode neither count.

**Files to modify**:
- `scripts/generate-decidability-inventory.sh` - baseline-heredoc extraction, greedy-regex name
  parse with the C36 citation, cross-check, mismatch reporting, exit-status discipline

**Verification**:
- `bash scripts/generate-decidability-inventory.sh` exits 0 on the current tree and reports 0 pin
  mismatches (the state the research dispatch measured live).
- Trailing-prime regression test: `--verbose` output confirms `not_plusValidZTime_neg_θ'` and
  `no_finite_carrier_sat'` are present in the extracted C2 baseline name set — the two names a
  `[^']+` class silently drops.
- **Positive (negative-case) test, the core acceptance evidence for this phase**: add one
  synthetic Decidability row to `docs/theorem-index.md` claiming `pinned:C14` for a
  non-existent declaration name, confirm the script exits non-zero and names that row, then
  **revert the edit immediately** (`git diff -- docs/theorem-index.md` empty) and re-confirm a
  clean exit-0 run. Commit only after the revert is confirmed.
- Negative test: scratch copy with `<<'C14BASE'` renamed produces a named non-zero failure, not a
  silent zero-name baseline.

---

### Phase 3: Sources 2 and 3 — REFUTED probes and the NOT ESTABLISHED anchor [COMPLETED]

**Goal**: The script emits a REFUTED section listing every `WIRED`/`WIRED_REPO` probe from
`scripts/check-evidence-probes.sh`, and a NOT ESTABLISHED section anchored on
`Correctness.lean`'s "Retired as vacuous" section — with `UNKNOWN` and loud failure where those
sources are silent.

**Tasks**:
- [x] Extract the `WIRED=( ... )` array (lines 173-186) and the `WIRED_REPO=( ... )` array (lines
      224-228) from `scripts/check-evidence-probes.sh` by locating the `WIRED=(`/`WIRED_REPO=(`
      opener and the matching `^)` terminator; emit each entry's path verbatim. *(completed)*
- [x] Mark `WIRED` entries as collection-relative (under `specs/evidence/`) and `WIRED_REPO`
      entries as full repo-relative, mirroring that script's own distinction, and note that
      `WIRED_REPO` entries each carry a named blocker in the preceding comment. *(completed)*
- [x] Emit, for every probe, the dimension "wired probe, outside the Lake build graph" **separate
      from** the REFUTED/PROVED classification, and print the baseline's own classification beside
      it once Phase 4 lands the baseline (leave a clearly marked hook here, fill it in Phase 4). *(completed)*
- [x] Do **not** parse the free-text comment table above `WIRED=(`. Print a pointer to it
      (`scripts/check-evidence-probes.sh`, the comment table directly above `WIRED=(`) as the
      rationale source instead. *(completed)*
- [x] Optionally shell out to `bash scripts/check-evidence-probes.sh` behind an explicit
      `--compile-probes` flag (off by default, because it compiles Lean and is slow) and report
      each probe's PASS/FAIL; without the flag, report compile status as `UNKNOWN (not run)`. *(completed)*
- [x] Parse source 3: locate the literal heading
      `` ## `validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous `` in
      `FormalSystem/Metalogic/Decidability/Correctness.lean` (line 192) and capture the paragraph
      following `**What is still owed, and is deliberately not stated here.**` up to the closing
      `-/`. *(completed)*
- [x] Anti-silence guards: a missing `WIRED=(`/`WIRED_REPO=(` array, an empty array, or a
      not-found-verbatim source-3 heading each produce a named non-zero failure. A heading found
      but an absent "What is still owed" sub-heading emits `UNKNOWN` for the NOT ESTABLISHED body
      rather than guessing at a substitute anchor. *(completed)*
- [x] State in the header that the four statuses come from different sources with different
      authority, and that the script reports the source for each. *(completed)*

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The research dispatch measured 12 `WIRED` entries and 3 `WIRED_REPO`
entries (15 total) against the baseline report's recorded "eleven `WIRED` plus three
`WIRED_REPO`" (14). Confirm by comparing the script's own emitted count against
`sed -n '173,186p;224,228p' scripts/check-evidence-probes.sh`; the 12-vs-11 delta is an expected
*finding* to be surfaced in Phase 4's diff, not a parser bug to be tuned away — but re-measure
rather than assuming the 12/3 split still holds.

**Files to modify**:
- `scripts/generate-decidability-inventory.sh` - `WIRED`/`WIRED_REPO` array extraction, probe
  reporting with the separate build-graph dimension, source-3 anchor parse, anti-silence guards

**Verification**:
- `bash scripts/generate-decidability-inventory.sh` exits 0 and prints a REFUTED section whose
  entry count matches the independent `sed` extraction above.
- The NOT ESTABLISHED section reproduces the `⊨ φ → isValid φ fc = true` obligation text from
  `Correctness.lean`, with its file-and-section provenance printed.
- No output line anywhere reproduces prose from the `WIRED` comment table (confirm by grepping the
  script source for a distinctive phrase from that table and finding nothing).
- Negative test: scratch copy of `Correctness.lean` with the "Retired as vacuous" heading renamed
  produces a named non-zero failure; a copy retaining the heading but missing the "What is still
  owed" sub-heading produces `UNKNOWN` and exit 0.

---

### Phase 4: Baseline data file, reproducible extraction, diff mode, WITHDRAWN carry-forward [COMPLETED]

**Goal**: A committed machine-readable baseline exists, derived reproducibly from section 1 of the
archived review; `--diff` reports added/removed inventory entries against it; and WITHDRAWN is
carried forward from it and verified for drift rather than re-derived.

**Tasks**:
- [x] Add `--extract-baseline [PATH]` mode: parse sections 1.1-1.4 of
      `specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md`
      (default path; overridable) and emit a flat, line-oriented data file — one record per entry,
      `STATUS<TAB>IDENTIFIER_OR_PATH<TAB>PROVENANCE`. This mode is the *only* place the prose
      report is parsed, so the fragile parse runs when a human deliberately re-derives the
      baseline, never on an ordinary run. *(completed)*
- [x] Write the extracted result to `scripts/decidability-inventory-baseline.txt`, following the
      existing convention for hand-maintained companion data files next to scripts
      (`scripts/c20-declaration-baseline.txt`, `scripts/certificate-witness-inventory.txt`,
      `scripts/module-invariants-manifest.txt`). *(completed)*
- [x] Head the data file with a provenance comment block: the archived report path and its
      section numbers, the extraction command that produced it, the date, and an explicit note
      that it is the *recorded* baseline — a historical record to diff against, never a statement
      about the current tree. *(completed)*
- [x] Review the extracted file by hand against the report's four tables before committing;
      correct any cell the parser mangled (the report's tables are prose-heavy and the extraction
      is a convenience, not an authority). Record in the commit message that it was hand-verified. *(completed)*
- [x] Add `--diff [--baseline PATH]` mode (default `scripts/decidability-inventory-baseline.txt`):
      report added and removed PROVED declarations, added and removed REFUTED probe paths, and
      any NOT ESTABLISHED anchor change, as `+`/`-` lines with their status. *(completed)*
- [x] WITHDRAWN carry-forward: read the four §1.3 entries from the baseline data file (never
      hardcoded in the script) and, for each, mechanically check current-tree state — presence in
      `docs/theorem-index.md`, presence of a definition site under `FormalSystem/`, and `pinned:`
      status where applicable. Report three drift classes: *reappeared* (now a live
      `docs/theorem-index.md` row), *newly unpinned*, and *confirmed still absent* (the expected
      state for `exists_tailStable_repr`). *(completed)*
- [x] State explicitly in the output that two baseline WITHDRAWN entries
      (`not_exists_plusCertifies_pumpTarget`, `not_exists_hopFree_plusCertifies_hopTarget`) are
      *expected* to appear as live `pinned:C2` rows in source 1 — a source-1-only read calls them
      PROVED, and the baseline's WITHDRAWN classification is what distinguishes them. This is
      reported, not resolved. *(completed)*
- [x] Fill in Phase 3's marked hook: print each wired probe's baseline classification (PROVED per
      §1.1 vs. REFUTED per §1.4) beside its "outside build graph" dimension, and emit an explicit
      DISAGREEMENT line where a probe the baseline calls PROVED sits in a `WIRED` array whose own
      script header frames every entry as a refutation. *(completed)*
- [x] Document in the header why WITHDRAWN is carried forward and cannot be regenerated, naming
      `exists_tailStable_repr` as the concrete reason (no declaration of that name exists anywhere
      in the tree; only prose references survive). *(completed)*

**Timing**: 1.75 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The baseline's section 1 holds four tables (§1.1 PROVED, §1.2 NOT
ESTABLISHED, §1.3 WITHDRAWN with 4 entries, §1.4 REFUTED with 4 rows) at report lines 40-103.
Confirm the extracted record count against a hand count of those tables before committing the
data file; the §1.1 PROVED table in particular packs multiple sibling declarations into single
cells, so the extracted PROVED count will legitimately exceed the row count — report the actual
numbers rather than assuming them.

**Files to modify**:
- `scripts/generate-decidability-inventory.sh` - `--extract-baseline`, `--diff`, `--baseline`,
  WITHDRAWN carry-forward and drift check, probe-classification disagreement reporting
- `scripts/decidability-inventory-baseline.txt` - new file: extracted, hand-verified, provenance-
  headed machine baseline

**Verification**:
- `bash scripts/generate-decidability-inventory.sh --extract-baseline` writes a data file whose
  record count matches the hand count of the report's four tables.
- `bash scripts/generate-decidability-inventory.sh --diff` exits 0 and reports
  `seam-gluing-ray-product/backward-dual-asymmetric-fixture` as an added REFUTED-category probe —
  the one real, already-known drift instance (research §3). A `--diff` run that reports *no*
  drift at all is a signal the diff is not wired up, not a clean bill of health.
- `--diff` reports `exists_tailStable_repr` as WITHDRAWN, confirmed still absent.
- `--diff` reports the two still-live `pinned:C2` WITHDRAWN entries with the explicit
  source-1-says-PROVED note, and prints at least one DISAGREEMENT line for the
  `seam-gluing-ray-product/*` probes the baseline classifies PROVED.
- Re-running `--extract-baseline` is idempotent: output byte-identical to the committed file apart
  from the provenance date line.
- `git diff -- specs/archive/` is empty (the archived report is read-only).

---

### Phase 5: Documentation, roadmap ownership hand-off, registration [COMPLETED]

**Goal**: The script is discoverable and owned: documented in `scripts/README.md`, and named in
`specs/ROADMAP.md`'s Maintenance section as the owner of the periodic re-run in place of this
task.

**Tasks**:
- [x] Re-read `scripts/README.md` immediately before editing (siblings 722/728 are live on this
      tree with no declared `file_scope`, and `check-phantom-citations.sh` is itself currently
      missing from this README — a sibling may be about to add it). *(completed)*
- [x] Add a row for `generate-decidability-inventory.sh` to `scripts/README.md`. Place it under a
      non-gate heading, not under "Gates and ratchets": it is an on-demand review instrument, not
      a build gate. Add a row for `decidability-inventory-baseline.txt` too — that file's own
      opening claim is that "every script and non-script data file that lives directly under
      `scripts/` ... is named below; nothing in this directory is undocumented". *(completed)*
- [x] Re-read `specs/ROADMAP.md` immediately before editing. *(completed)*
- [x] Edit the Maintenance section (lines 342-352): replace "Nobody owns the periodic re-run of
      the decidability inventory until task 726 lands" with a sentence naming
      `scripts/generate-decidability-inventory.sh` as the owner, keeping the existing baseline
      citation intact and adding the committed data file
      (`scripts/decidability-inventory-baseline.txt`) as the diff target. Per
      `no-task-references-in-deliverables.md`, `specs/ROADMAP.md` sits under `specs/**` so a task
      number is permitted there, but the whole point of this edit is to replace the task-number
      ownership with a durable path — write the path, not a task number. *(completed)*
- [x] Optional, and skipped if the source store is not reachable: add a one-line pointer to the
      new script from `domain/decidability-provenance.md` in the **source store** resolved from
      `.claude-extensions.json`'s `source_dir` (research's Context Extension Recommendation).
      Never hand-author the deployed `.claude/` copy — the dispatch flags the `lean` extension as
      currently stale, so a deployed edit would be silently discarded. *(completed)*
- [x] Do not touch `.github/workflows/ci.yml` (explicit non-goal; record the `--strict` hook in
      the README row so a future task can wire it). *(completed)*

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `specs/ROADMAP.md`'s Maintenance section is at lines 342-352 and
`scripts/README.md` currently documents 54 script/data entries across its tables, with
`check-phantom-citations.sh` absent from it. Both files may have moved under a sibling's edit
between planning and implementation — re-locate the Maintenance heading by
`grep -n '^## Maintenance' specs/ROADMAP.md` rather than by line number, and re-count the README
rows before asserting coverage.

**Files to modify**:
- `scripts/README.md` - new rows for the script and its baseline data file
- `specs/ROADMAP.md` - Maintenance section: ownership hand-off from this task to the script
- `<source_dir>/.../domain/decidability-provenance.md` - optional one-line pointer, source store
  only, resolved from `.claude-extensions.json`; skipped if unreachable

**Verification**:
- `grep -n 'generate-decidability-inventory' scripts/README.md specs/ROADMAP.md` finds both edits.
- `grep -n 'until task 726 lands' specs/ROADMAP.md` finds nothing.
- `grep -rn '726' specs/ROADMAP.md` shows no remaining ownership claim on this task number.
- `git diff --stat` touches no path under `.claude/`.
- `bash scripts/check-phantom-citations.sh` is no worse than its pre-edit baseline (it scans
  `specs/ROADMAP.md`; capture its finding count before and after and compare).
- `git status --short` shows only this task's files; any foreign modification is reported, not
  absorbed.

---

### Phase 6: End-to-end acceptance run and final gate [NOT STARTED]

**Goal**: The acceptance criteria are demonstrated end to end on the real tree, and the repo's
full gate set is green.

**Tasks**:
- [ ] Run `bash scripts/generate-decidability-inventory.sh` from a directory other than the repo
      root and confirm the `BASH_SOURCE`-derived `ROOT` resolution works.
- [ ] Confirm all four statuses appear in one run's output (PROVED, NOT ESTABLISHED, WITHDRAWN,
      REFUTED), each labelled with the source that supports it.
- [ ] Confirm no output line asserts a complexity claim and no status is asserted beyond what the
      three sources plus the carried-forward baseline state; confirm `UNKNOWN` appears wherever a
      source is silent (at minimum, probe compile status without `--compile-probes`).
- [ ] Run `bash scripts/generate-decidability-inventory.sh --diff` and record its output verbatim
      in the implementation summary as the acceptance evidence — including the
      `backward-dual-asymmetric-fixture` added-probe line.
- [ ] Run `bash scripts/generate-decidability-inventory.sh --strict` and confirm its exit status
      matches the documented discipline.
- [ ] `shellcheck scripts/generate-decidability-inventory.sh` if available (several scripts here
      use `set -uo pipefail` rather than `-e` deliberately; match the sibling convention and
      silence nothing without a comment).
- [ ] Run the repository's full gate set and confirm green: `lake build`,
      `bash scripts/check-module-invariants.sh`, `bash scripts/check-evidence-probes.sh`,
      `bash scripts/readme-lint.sh`, `bash scripts/check-copyright-headers.sh`,
      `bash scripts/check-metalogic-cycles.sh`, `bash scripts/check-paper-definitions.sh`,
      `bash scripts/check-phantom-citations.sh`. Treat a failure in a file outside this task's own
      scope as possibly a concurrent sibling's in-flight edit — check `git log` and report rather
      than silently "fixing" it.
- [ ] Record in the summary that the pin cross-check currently finds 0 mismatches, that this is
      the expected clean state, and that Phase 2's synthetic-row test is the evidence the check
      actually fires.

**Timing**: 0.75 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: The gate set enumerated above is drawn from `scripts/README.md`'s "Gates and
ratchets" table plus `.github/workflows/ci.yml`. Confirm the live set by re-reading that table and
the CI workflow's step list at implementation time rather than trusting this enumeration; if a
gate has been added, run it too.

**Files to modify**:
- `scripts/generate-decidability-inventory.sh` - only if a gate, shellcheck, or acceptance run
  surfaces a defect

**Verification**:
- Every gate in the enumerated full set exits 0 (paste each exit status into the summary).
- All four statuses present in one run; `--diff` output captured verbatim.
- `git status --short` clean of anything outside this task's declared files.

---

## Testing & Validation

- [ ] `bash -n` and (where available) `shellcheck` clean on the new script.
- [ ] `--help`, unknown-flag `exit 2`, and run-from-anywhere `ROOT` resolution all behave.
- [ ] Four-status output in a single run, each status labelled with its source.
- [ ] Pin cross-check reports 0 mismatches on the clean tree **and** exits non-zero on an injected
      synthetic `pinned:C14` row (then the injection is reverted and the clean run re-confirmed).
- [ ] Trailing-prime names (`not_plusValidZTime_neg_θ'`, `no_finite_carrier_sat'`) resolve in the
      extracted C2 baseline — the `[^']+` regression guard.
- [ ] Anti-silence guards fire loudly for each of the four anchors (`### Decidability`,
      `<<'BASELINE'`, `<<'C14BASE'`, the "Retired as vacuous" heading), tested on scratch copies
      with the real files left untouched.
- [ ] `UNKNOWN` appears where a source is silent; no complexity claim anywhere in the output.
- [ ] `--diff` surfaces `seam-gluing-ray-product/backward-dual-asymmetric-fixture` as added.
- [ ] `--extract-baseline` is idempotent apart from its date line.
- [ ] WITHDRAWN drift check reports `exists_tailStable_repr` still absent and the two live
      `pinned:C2` entries with their source-1-says-PROVED note.
- [ ] At least one DISAGREEMENT line for the baseline-PROVED `seam-gluing-ray-product/*` probes.
- [ ] `scripts/README.md` and `specs/ROADMAP.md` both name the script; no `.claude/**` path in the
      diff; no remaining task-number ownership claim in the roadmap.
- [ ] Full repository gate set green.

## Artifacts & Outputs

- `scripts/generate-decidability-inventory.sh` — the mechanism (new, executable).
- `scripts/decidability-inventory-baseline.txt` — committed, hand-verified, provenance-headed
  machine baseline extracted from the archived review's section 1 (new).
- `scripts/README.md` — rows for both of the above (modified).
- `specs/ROADMAP.md` — Maintenance section: periodic-re-run ownership moved from this task to the
  script (modified).
- `<source_dir>/.../domain/decidability-provenance.md` — optional one-line pointer, source store
  only (modified, or skipped with a recorded reason).
- `specs/726_rerunnable_decidability_programme_inventory/summaries/01_*-summary.md` — the
  implementation summary, carrying the verbatim `--diff` output as acceptance evidence.

## Rollback/Contingency

Every phase's work is confined to two new files plus three small, additive documentation hunks, so
rollback is per-commit revert rather than a working-tree reset. Phases are committed individually
(`per-substep`), so `git revert <sha>` on the offending commit undoes a single phase without
disturbing the others; the two new files can simply be deleted if the whole approach is
abandoned.

Two situations need care:

1. **Phase 2's synthetic-row injection into `docs/theorem-index.md`** is the one edit to a
   read-only source in this plan. It must be reverted within the same phase and before any
   commit, and the revert confirmed by an empty `git diff -- docs/theorem-index.md`. If a crash
   leaves the injection in place, remove that one row by hand — do not reach for a tree-wide
   discard, because concurrent siblings 722 and 728 may hold uncommitted work on this same tree.
2. **A genuine rollback that would discard uncommitted work** (any `git reset --hard`,
   `git checkout -- <path>`, or `git clean -fd`) requires a snapshot first: see
   `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation
   shape and its out-of-scope override flag. For an ordinary defensive checkpoint before risky
   work — not a rollback — use `bash .claude/scripts/git-snapshot.sh --no-revert`, which is
   durable without reverting the working tree. Never emit the bare reverting form as a routine
   checkpoint, and never run it at all while siblings hold uncommitted work on this tree.

If the baseline extraction in Phase 4 proves unworkable against the report's prose tables, the
fallback is a hand-written `scripts/decidability-inventory-baseline.txt` with the same provenance
header and the `--extract-baseline` mode dropped; the `--diff` mode, which is the acceptance-
relevant half, is unaffected. Record the substitution and its reason in the summary rather than
silently shipping a hand-written file labelled as extracted.

## Decisions

- **Standing script, not a `/review` step.** Reasons, in order of weight: the `core` extension's
  deployed `.claude/` tree is currently stale relative to its source store, so a `/review`-step
  edit would not take effect in this repo without a redeploy and risks silent discard; a script
  under `scripts/` runs from a fresh clone with no agent-system dependency, beside the two scripts
  it reads; `/review` would wrap a "run a script and read its stdout" job in task-creation and
  state-management machinery it does not need; and a script is trivially something `/review` can
  shell out to later, while the reverse is not true. (Research §6, Recommendation 1.)
- **The diff target is a committed data file, not the prose report.** The dispatch names the
  archived review's section 1 as the baseline; this plan honours that by deriving the data file
  from it reproducibly via `--extract-baseline`, with the report named as provenance. Parsing
  prose-heavy heterogeneous tables on every ordinary run would be the fragile design, and the
  archived report is immutable, so a frozen extraction is faithful.
- **WITHDRAWN is carried forward and verified, never regenerated.** Forced by the sources: one
  entry names a declaration absent from the whole tree, two are still live `pinned:C2` rows that a
  source-1-only read would call PROVED, and one is recorded in a fourth file outside all three
  sources. Regenerating it would mean asserting a status the sources do not support — the hard
  constraint this task sets.
- **No CI wiring.** This is a review instrument, not a gate; its one hard-failure condition is
  already covered from the other side by C2/C14. A `--strict` mode ships so a future task can wire
  it without rework.
- **No phantom-citation checker.** `scripts/check-phantom-citations.sh` landed since the research
  dispatch and owns that check. This plan builds nothing overlapping it and adopts it as the CLI
  and header-documentation precedent instead.
