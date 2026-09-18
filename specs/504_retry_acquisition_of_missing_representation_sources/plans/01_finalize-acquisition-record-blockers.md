# Implementation Plan: Finalize Representation-Source Acquisition and Record Blockers

- **Task**: 504 - retry_acquisition_of_missing_representation_sources
- **Status**: [COMPLETED]
- **Effort**: 3.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/504_retry_acquisition_of_missing_representation_sources/reports/01_retry-acquisition-representation-sources.md`
- **Artifacts**: plans/01_finalize-acquisition-record-blockers.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/context/standards/artifact-management.md`
  - `.claude/context/standards/git-staging-scope.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/git-workflow.md`
- **Type**: general
- **Lean Intent**: false

## Overview

The research dispatch already performed the acquisition itself: it recovered Gehrke & Jónsson
2004 (the `mscand.dk` -> `journals.msp.org` OJS migration made the "404" a stale-URL artifact,
not an availability problem), ingested it as `gehrke_jonsson_2004` (62 chunks), registered it in
`specs/literature-index.json`, and confirmed with source-specific evidence that the other seven
checklist items are genuinely unacquirable through this pipeline. What remains is *not* more
searching — it is finishing the job honestly and durably: verify the registration, reconcile an
over-strong fidelity label the research itself flagged, write the seven confirmed blockers into
the corpus's established durable record (`~/Projects/Literature/SOURCES.md`), record the Zotero
write-bridge dependency defect where `/errors` can act on it, and commit the one BimodalLogic
file this task changed.

The plan deliberately does **not** re-run discovery for the seven unacquired sources. Tier 3 was
verified healthy across ~10 queries this session with zero `TIER3_STATUS: FAILED`, so the
rate-limit hypothesis that justified *this* retry task has been discharged; repeating the sweep a
third time would add cost and no information.

### Research Integration

Findings that directly shape phases below:

- **`gehrke_jonsson_2004` is registered but uncommitted.** `specs/literature-index.json` carries
  the new entry (68 -> 69 entries, +8 lines) with all six fields (`doc_id`, `reason`, `added`,
  `source`, `citation_rule`, `fidelity`) matching the `gehrke_vosmaer_2011_view-of-canonical-extension`
  template. The research commit (`c2a3a378b`) staged only the report, so the index change is still
  a dirty working-tree file (Phase 1, Phase 4).
- **The `verified_conversion` fidelity label is over-strong, by the research's own admission**
  (its Risk 3): it was assigned because the conversion produced no quality-gate rejection and
  needed no control-character repairs — a weaker bar than the page-image cross-check the label
  implies elsewhere in the corpus. The report's mitigation asserts the PDF is "retained at
  `~/Projects/Literature/sources/gehrke_jonsson_2004/`"; it is not — that directory holds only
  `chunk_0001..0062.md`, `chunks.json`, and `metadata.json`. The only copy is in this session's
  ephemeral scratchpad. The download URL is known, HTTP-200, and unauthenticated, so the check is
  cheap to make real (Phase 2).
- **The seven confirmed blockers currently live only in this task's report**, which `/todo` will
  archive. The prior round's report was archived the same way, which is precisely why this retry
  had to re-derive the checklist from `specs/archive/503_.../reports/01_...md`. The corpus already
  has the right durable home for this: `~/Projects/Literature/SOURCES.md`, whose W-series and
  A-series sections use exactly this shape (`**Reason not obtained**`, `**Substitute ingested**`,
  `**Access route**`, bibtex) (Phase 3).
- **The `zotero-cli-cc` write bridge is broken in this environment** (`TypeError: 'httpx.Timeout'
  object cannot be interpreted as an integer or float` in the `pyzotero`/`httpx2` chain), which
  is why `gehrke_jonsson_2004` has `zotero_key: null`. The research flagged it as Risk 1 and
  recommended a future `meta` task; `specs/errors.json` is the ledger `/errors` reads to produce
  exactly such fix plans (Phase 5).

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context, so no roadmap consultation was
performed as a plan input. For reference only: `specs/ROADMAP.md` line 83 lists this task among
the "Jónsson-Tarski algebraic representation" grouping (125, 497-502, 504) as groundwork for that
capstone. Nothing in this plan writes to `ROADMAP.md`.

## Goals & Non-Goals

**Goals**:
- Verify end-to-end that `gehrke_jonsson_2004` is correctly and completely registered in both the
  sub-index and the global corpus index, and that it is retrievable via FTS search.
- Make the `fidelity` label on that entry honest — either earn `verified_conversion` with a real
  page-image spot-check, or downgrade it with a specific, recorded reason.
- Give the seven confirmed-unacquirable sources a durable, discoverable record outside this
  task's soon-to-be-archived report, in the corpus's established format.
- Record the `zotero-cli-cc` dependency defect in `specs/errors.json` so it can become a real
  fix task rather than institutional memory.
- Leave the BimodalLogic working tree clean with respect to this task, with a correctly scoped
  commit.

**Non-Goals**:
- Re-running discovery for the seven unacquired sources. Tier 3 health was already confirmed and
  each blocker is now source-specific, not environmental.
- Fixing the `zotero-cli-cc`/`httpx2` dependency defect. Recording it is in scope; repairing the
  Zotero write bridge is a separate `meta` task.
- Revising the Typst representation section to cite the newly-acquired primary source in place of
  the `gehrke_vosmaer_2011` proxy. That is downstream editorial work, not acquisition.
- Committing anything in the `~/Projects/Literature/` repository. See Risks #1 — its working tree
  currently carries four other tasks' concurrent ingests and a 215-line `SOURCES.md` section from
  another task's dossier, and no non-interactive staging can separate them.
- Acquiring Sambin & Vaccaro 1988 via browser automation. See Risks #2 and the `user_decision`
  raised alongside this plan.

## Risks & Mitigations

| # | Risk | Impact | Likelihood | Mitigation |
|---|------|--------|------------|------------|
| 1 | **The `~/Projects/Literature/` working tree cannot be committed with task-scoped staging.** `index.json` carries 7,205 insertions spanning five `doc_id`s, only one of which (`gehrke_jonsson_2004`) belongs to this task — the others are concurrent `lamport_2009_pluscal-manual`, `lamport_2015_tla-plus-2-guide`, `wijesekera_-_1990_...`, `xu_-_1988_...` ingests. `SOURCES.md` additionally carries 215 uncommitted lines from another task's acquisition dossier. `git add -- index.json` would over-stage four other tasks' work; hunk-level staging (`git add -p`) is interactive and unavailable in this environment. | M | H (already true) | Do not commit in that repo. Phases 3 and 4 write to its working tree and leave the changes on disk, and the phase-4 verification requires the summary to state explicitly which Literature-repo paths this task touched and that they are deliberately uncommitted, so the user can stage them alongside the concurrent work. |
| 2 | **Sambin & Vaccaro 1988 sits in a policy gray zone the plan cannot resolve.** Unpaywall reports `is_oa: true`, `oa_status: "bronze"` (free to read at the publisher) but `url_for_pdf: null`, and ScienceDirect returns HTTP 403 to a non-browser fetch — a bot/TDM control, not a paywall. `SOURCES.md`'s stated policy says "No paywall circumvention" but also, for W11/W13/W16, that items "blocked only by anti-bot walls that a real browser passes straight through" are "the cheapest acquisitions on this list." Those two sentences point opposite ways for this item, and Playwright *is* available in this session. | M | M | Not resolved in-plan. Raised as a non-blocking `user_decision` on `.return-meta.json`; the plan proceeds on "record as not acquired" (Phase 3, entry R1), which is fully reversible — a later authorized fetch would simply convert R1 from a blocker entry into an ingest. |
| 3 | **The fidelity spot-check in Phase 2 could fail**, revealing conversion defects in a document already registered and indexed. | M | L | Phase 2's branch structure treats this as an expected outcome, not an error: on failure it downgrades the label in both indices with the specific defect recorded, rather than quarantining or re-ingesting. The document stays usable and searchable either way; the label is what changes. |
| 4 | **The re-downloaded PDF could differ from the one actually converted** (publisher re-typeset, different DOI-to-file mapping), making the spot-check vacuous. | L | L | Phase 2 compares the re-download against the scratchpad copy at `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/36806a6d-d7d5-4f49-931d-ee0ede39e2f1/scratchpad/gehrke_jonsson_2004.pdf` (223,069 bytes) by size and checksum before trusting it; a mismatch is recorded and the spot-check is run against the scratchpad copy instead, which is the file that was actually converted. |
| 5 | **`specs/errors.json`'s existing entries are both `delegation_interrupted` runtime failures**, so a tooling/dependency defect is a new `type` value for that ledger. | L | M | Phase 5 matches the existing entry key set exactly (`id`, `timestamp`, `type`, `severity`, `message`, `context`, `recovery`, `fix_status`) and only introduces a new `type` string value, which the schema treats as free-form. Phase 5 validates the file parses as JSON and that no existing entry was mutated. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 5 | -- |
| 2 | 2 | 1 |
| 3 | 4 | 2, 3, 5 |

Phases within the same wave can execute in parallel. Territory is disjoint across wave 1: Phase 1
is read-only, Phase 3 writes only `~/Projects/Literature/SOURCES.md`, Phase 5 writes only
`specs/errors.json`.

---

### Phase 1: Audit the `gehrke_jonsson_2004` Registration [COMPLETED]

**Goal**: Confirm, by direct inspection rather than by trusting the research report, that the
acquired source is completely and correctly registered in both indices and is retrievable — and
produce the exact list of anything that is not, for Phase 2 to act on.

**Tasks**:
- [x] Read the `gehrke_jonsson_2004` entry in `specs/literature-index.json` and confirm it carries
      all six fields present on the `gehrke_vosmaer_2011_view-of-canonical-extension` entry
      (`doc_id`, `reason`, `added`, `source`, `citation_rule`, `fidelity`), with no empty values.
      *(completed: all 6 fields present and non-empty)*
- [x] Confirm `specs/literature-index.json` parses as JSON and that `.entries | length` is 69.
      *(completed: 69 confirmed)*
- [x] Confirm the global `~/Projects/Literature/index.json` parent entry carries real metadata
      (`title`, `authors`, `year`, `venue`, `doi`, `provenance_fidelity`) and note that
      `zotero_key` is `null` — this is expected, and its cause is the defect Phase 5 records.
      *(completed: all fields present; zotero_key/zotero_path both null as expected)*
- [x] Confirm the chunk entries exist in the global index for this `doc_id` and that the on-disk
      chunk count in `~/Projects/Literature/sources/gehrke_jonsson_2004/` matches.
      *(completed: 62 chunk entries in global index + 1 parent = 63; 62 chunk_*.md files on disk — match)*
- [x] Run `bash .claude/scripts/literature-search.sh "bounded distributive lattice"` and confirm
      `gehrke_jonsson_2004` is among the results.
      *(completed: returned as top-ranked result)*
- [x] Record any discrepancy found as a concrete item for Phase 2; if none, record that explicitly.
      *(completed: no discrepancies found; all observed values match research report's figures exactly)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the sub-index holds 69 entries, that the corpus directory
holds 62 chunks, and that the global index holds 1 parent + 62 chunk entries for this `doc_id`.
These are the research report's figures, not independently confirmed facts. Confirm each by
running the count at implementation time (`jq '.entries|length'` on each index; `ls
sources/gehrke_jonsson_2004/chunk_*.md | wc -l`) and record the observed numbers; a mismatch is a
finding for Phase 2, not a reason to stop.

**Files to modify**:
- None — this phase is read-only. Its output is the discrepancy list consumed by Phase 2.

**Verification**:
- Both index files parse as JSON (`jq . >/dev/null` on each).
- Every assertion above has an observed value recorded next to it, not just a pass/fail.
- `literature-search.sh` returns the document.

---

### Phase 2: Spot-Check Conversion Fidelity and Reconcile the Label [COMPLETED]

**Goal**: Make the `fidelity` / `provenance_fidelity` label on `gehrke_jonsson_2004` reflect a
check that was actually performed, and retain the source PDF on disk so any future citation from
this document can be re-checked.

**Tasks**:
- [x] Re-download the PDF from the known-good endpoint
      `https://journals.msp.org/mscand/article/download/791/790` and verify HTTP 200,
      `content-type: application/pdf`, and PDF magic bytes.
      *(completed: HTTP 200, content-type application/pdf, magic bytes %PDF-1.3 confirmed)*
- [x] Compare the re-download to the scratchpad copy
      (`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/36806a6d-d7d5-4f49-931d-ee0ede39e2f1/scratchpad/gehrke_jonsson_2004.pdf`,
      223,069 bytes) by byte size and `sha256sum`. If they differ, record both checksums and run
      the spot-check against the scratchpad copy — that is the file that was actually converted.
      *(completed: byte-identical, both 223,069 bytes, sha256 6dd101dc53a5368ae73046a72c328bec119d1f4b67fd307ac77493f2bd7315ff — no divergence)*
- [x] Place the PDF in `~/Projects/Literature/sources/gehrke_jonsson_2004/` alongside the chunks,
      matching the sibling `gehrke_vosmaer_2011_view-of-canonical-extension/` directory layout.
      (Note: `*.pdf` is gitignored in that repo, so this is on-disk retention only, by design.)
      *(completed)*
- [x] Cross-check at least three numbered items — a theorem statement, a definition, and a
      section heading with its page number — between the converted chunks and the PDF page
      images, choosing items a future citation would plausibly use (the canonical extension
      `A^sigma` definition and its density/compactness conditions are the obvious candidates).
      *(completed: section heading 2.2 "Six topologies" (p.18), Definition 2.7 (p.18), Theorem 2.8 statement+proof (p.18-19) — all match verbatim modulo font ligatures)*
- [x] If all three match: keep `verified_conversion` and rewrite the `fidelity` string in
      `specs/literature-index.json` to name the evidence actually obtained (which items were
      checked, against which page numbers), replacing the current quality-gate-only justification.
      *(completed: all 3 matched, label kept and string rewritten with the sha256 check and the 3 specific items/pages)*
- [ ] If any mismatch is found: downgrade `fidelity` to `unverified_conversion` in
      `specs/literature-index.json` and `provenance_fidelity` to match in
      `~/Projects/Literature/index.json`, naming the specific defect observed.
      *(deviation: skipped — condition not triggered, no mismatch was found)*
- [x] Apply any other discrepancy Phase 1 surfaced.
      *(completed: none — Phase 1 found no discrepancies)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase assumes the download endpoint is still live and unauthenticated
(it was HTTP 200 on 2026-09-18) and that the scratchpad copy still exists (scratchpad contents are
session-scoped and may be gone). Confirm both at implementation time before planning the check; if
the endpoint has regressed AND the scratchpad copy is gone, the spot-check cannot be performed —
in that case downgrade the label to `unverified_conversion` with "spot-check not performable, PDF
no longer retrievable" as the recorded reason rather than leaving an unearned label in place.

**Files to modify**:
- `specs/literature-index.json` — rewrite the `fidelity` string on the `gehrke_jonsson_2004`
  entry; no other entry touched.
- `~/Projects/Literature/index.json` — `provenance_fidelity` on the parent entry, only if the
  label is downgraded.
- `~/Projects/Literature/sources/gehrke_jonsson_2004/` — add the retained PDF.

**Verification**:
- Both index files still parse as JSON, and their entry counts are unchanged from Phase 1's
  observed values (this phase edits values, never adds or removes entries).
- The `fidelity` string names a check that was actually run, with the specific items and page
  numbers checked — it must not be possible to read the string and be unable to tell what was
  verified.
- The PDF is present in the source directory and its magic bytes verify.

---

### Phase 3: Record the Seven Unacquired Sources in `SOURCES.md` [COMPLETED]

**Goal**: Give the confirmed blockers a durable home in the corpus's own acquisition record, so a
future retry starts from the known DOI and the known, source-specific blocker instead of
re-deriving both from an archived task report for a third time.

**Tasks**:
- [x] Read the existing `~/Projects/Literature/SOURCES.md` W-series (lines ~185-480) and A-series
      (lines ~498-709) sections to fix the exact conventions in hand: the dated `# {title}
      (YYYY-MM-DD)` section header, the `## {PREFIX}{n}. Author (Year) — Title` entry heading, the
      `**Authors**` / `**Venue**` / `**Reason not obtained**` / `**Substitute ingested**` /
      `**Access route**` fields, the fenced bibtex block, and the closing `## ... acquisition
      notes` subsection.
      *(completed)*
- [x] Append a new dated top-level section (separated by the `---` the file uses between sections)
      for the modal-representation/duality acquisition front, using a fresh entry prefix not
      already in use (`W` and `A` are taken; `R` is free).
      *(completed: "Modal-Representation and Duality Acquisition Front (2026-09-18)" appended at EOF, verified as a pure append — pre-existing 709 lines byte-identical)*
- [x] Write one entry per unacquired source, each stating the blocker as *confirmed evidence*, not
      as a guess — the report's Findings table has the specifics for all seven:
      - R1 Sambin & Vaccaro 1988 — Unpaywall `is_oa: true` / `oa_status: bronze`,
        `best_oa_location.url_for_pdf: null`, DOI `10.1016/0168-0072(88)90021-8`, ScienceDirect
        derived PDF endpoint returns HTTP 403 to a non-browser fetch (checked 2026-09-18). Note
        explicitly that this is an anti-bot/TDM control on a free-to-read item, not a paywall, and
        cross-reference the existing W11/W13/W16 note on that distinction.
      - R2 S. K. Thomason 1972, "Semantic analysis of tense logics" — Cambridge Core PDF URL
        redirects (302 -> 301) to the paywalled product page.
      - R3 S. K. Thomason 1975, "Categories of frames for modal logic" — same Cambridge Core
        paywall pattern, no OA host found.
      - R4 Goldblatt 1976, "Metamathematics of modal logic" I-II — confirmed absent from
        Goldblatt's own Online Papers list (`homepages.ecs.vuw.ac.nz/~rob/papers.html`), which
        covers 1999 onward only.
      - R5 Fine 1975, "Some connections between elementary and modal logic" — paywalled Elsevier
        book-series chapter (*Studies in Logic* vol. 82), no OA copy located.
      - R6 Gabbay & Shehtman, "Products of modal logics I" — academia.edu listing requires an
        authenticated session (HTTP 403 direct); Oxford Academic paywalled.
      - R7 Marx & Venema 1997, "Multi-dimensional modal logic" — Kluwer/Springer monograph;
        Venema's own `staff.science.uva.nl/y.venema/books.html` lists it with a purchase link
        only, no PDF.
      *(completed: all 7 entries written with the confirmed evidence above, plus DOI/venue/publisher fields following the W-series template)*
- [x] For each entry, record the corpus substitute where one exists, using the report's mapping:
      `venema_2007_algebras_and_coalgebras` Theorem 5.28 covers Goldblatt 1976 and Esakia duality
      (R4); the same document's Theorem 6.17 covers Fine 1975 (R5). State plainly, for R1, R2 and
      R3, that **no substitute exists** for the historical narrative around the origins of the
      discrete-frame/BAO duality — that gap is the one real informational loss and must not be
      papered over.
      *(completed)*
- [x] Add a short closing notes subsection recording (a) that Gehrke & Jónsson 2004 came off this
      same checklist and is now in the corpus as `gehrke_jonsson_2004`, superseding the
      `gehrke_vosmaer_2011` proxy for the canonical-extension framework; (b) that Tier 3 discovery
      was confirmed healthy on 2026-09-18 across ~10 queries, so these seven are not blocked by
      tooling and re-running discovery will not change the outcome; and (c) a priority ordering
      for anyone with institutional access.
      *(completed: "Modal-representation acquisition notes" subsection covers all three points)*
- [x] Cite the evidence source by durable path (`BimodalLogic/specs/.../reports/01_retry-acquisition-representation-sources.md`)
      following the A-series precedent, rather than by a bare task number.
      *(completed: cited by durable path in the section intro; no "task 504" string appears anywhere in the appended text, confirmed by grep)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts exactly seven entries (R1-R7), derived from the eight-item
dispatch checklist minus the one acquired item. Confirm against the report's Findings table at
implementation time that the acquired/unacquired split is still 1/7 and that no item was
double-counted (Goldblatt 1976 I and II are one entry covering two parts, matching how the
checklist and the report both treat them).

**Files to modify**:
- `~/Projects/Literature/SOURCES.md` — append one new dated section; no existing line edited.

**Verification**:
- The new section is appended at end-of-file and the pre-existing 215 uncommitted lines from the
  other task's section are byte-identical afterwards (`git diff` in that repo shows the new
  section as pure addition below them).
- Every entry names a concrete, dated blocker — a URL plus an HTTP status, an API field value, or
  a named page checked — and no entry says only "paywalled" or "not found".
- The three sources with no substitute are identified as such in the text, not silently omitted.
- Entry headings, field names and bibtex fencing match the W-series/A-series shape when diffed
  by eye against an existing entry.

---

### Phase 4: Commit the Sub-Index Change and Clean Up Backups [COMPLETED]

**Goal**: Leave the BimodalLogic working tree clean with respect to this task, with a correctly
scoped commit, and report the Literature-repo state honestly rather than committing it.

**Tasks**:
- [x] Run `git status --short` and `git diff -- specs/literature-index.json` and confirm the diff
      is confined to the single `gehrke_jonsson_2004` entry (plus whatever Phase 2 changed on that
      same entry's `fidelity` string).
      *(completed: confirmed 8-line diff confined to one entry before committing in Phase 2)*
- [x] Stage `specs/literature-index.json` and `specs/errors.json` explicitly by path — never
      `git add -A`, `git add .`, or a directory/glob pathspec — plus this task's `plans/` and
      `reports/` artifacts and its `.return-meta.json`.
      *(deviation: altered — staged and committed per-phase as each phase went green (Phase 1 commit `67f583d56`, Phase 2 commit `8b5e60ccb` staged literature-index.json, Phase 3 commit `5910608f0`, Phase 5 commit `330f27068` staged errors.json), per the Commit-Per-Green-Substep Mandate in `.claude/rules/git-workflow.md`, rather than batching all files into one final Phase 4 commit as originally envisioned. Same explicit-path staging discipline, no `git add -A`/`-A`/glob, applied at every commit.)*
- [x] Review `git diff --staged` before committing; confirm no unrelated file from the concurrent
      task-606 / task-619 work is staged.
      *(completed: reviewed via git-commit-scoped.sh's path-scoped staging at each phase commit; git show --stat HEAD confirmed only this task's files at each step)*
- [ ] Commit with the conventional message `task 504: complete implementation`, including the
      session ID in the body.
      *(deviation: altered — no single final "complete implementation" commit; the substantive changes were already committed per-phase per the Commit-Per-Green-Substep Mandate. This phase's own remaining plan-checkbox/progress-file updates and the execution summary are committed as this phase's own green sub-step below.)*
- [x] Delete the pre-edit backup `specs/literature-index.json.bak-504` (the change is in git
      history once committed, and the repo does not track these backups).
      *(completed)*
- [x] Delete `~/Projects/Literature/index.json.bak-task504` — that repo gitignores `index.json.bak*`
      precisely because they accumulate (26 had built up, 9.3 MB, before a prior cleanup).
      *(completed)*
- [x] Record in the execution summary the exact list of `~/Projects/Literature/` paths this task
      touched (`index.json`, `SOURCES.md`, `sources/gehrke_jonsson_2004/`) and state that they are
      deliberately left uncommitted, with Risk #1's reason.
      *(completed: see summary's "Literature-repo state" section)*

**Timing**: 0.5 hours

**Depends on**: 2, 3, 5

**Verification Tier**: local

**Scope Hypothesis**: This phase assumes the `specs/literature-index.json` diff is 8 insertions
confined to one entry. Confirm with `git diff --stat` at implementation time; if the count has
grown, inspect before staging — a larger diff means another session also edited the sub-index and
the staging scope must be reconsidered rather than committed blind.

**Files to modify**:
- Git index / HEAD in the BimodalLogic repository only.
- Deletions: `specs/literature-index.json.bak-504`,
  `~/Projects/Literature/index.json.bak-task504`.

**Verification**:
- `git status --short -- specs/literature-index.json specs/errors.json` is empty after the commit.
- `git show --stat HEAD` lists only this task's files.
- `git status --short` in `~/Projects/Literature/` still shows the concurrent work untouched and
  unstaged.
- The summary names the uncommitted Literature-repo paths explicitly.

---

### Phase 5: Record the Zotero Write-Bridge Defect in `specs/errors.json` [COMPLETED]

**Goal**: Turn the research's Risk 1 from a note inside a soon-to-be-archived report into an entry
`/errors` can read and turn into a fix task.

**Tasks**:
- [x] Read the two existing entries in `specs/errors.json` and match their key set exactly:
      `id`, `timestamp`, `type`, `severity`, `message`, `context`, `recovery`, `fix_status`.
      *(completed)*
- [x] Append one entry describing the defect: `literature-ingest-online.sh`'s Zotero `create-item`
      step fails with `ONLINE_INGEST_ZOTERO_CREATE_FAILED`, caused by `TypeError: 'httpx.Timeout'
      object cannot be interpreted as an integer or float` inside the
      `zotero-cli-cc` -> `pyzotero` -> `httpx2`/`httpcore2` dependency chain. Note that this is
      version-drift in the dependency, independent of any source's availability.
      *(completed)*
- [x] Record the observed consequence concretely: every new open-access ingest must bypass the
      Zotero write step, and documents ingested that way carry `zotero_key: null` /
      `zotero_path: null` — `gehrke_jonsson_2004` is the current example.
      *(completed)*
- [x] Record the known workaround in `recovery`: download and magic-byte-verify the PDF, feed it
      directly to the unmodified `literature-ingest.sh`, then patch the index metadata by hand
      against an existing entry's schema. Mark `auto_recoverable` honestly — the workaround is
      manual, so this is not auto-recoverable.
      *(completed: recovery.auto_recoverable: false, recovery.workaround describes the manual bypass)*
- [x] Set `fix_status` to match the convention the existing entries use for unfixed items.
      *(completed: fix_status: "unfixed", matching both existing entries)*
- [x] Suggest a `meta`-type fix (pin or patch the `zotero-cli-cc` dependency versions) in the
      `recovery.suggested_action` field.
      *(completed)*

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts `specs/errors.json` currently holds 2 entries under an
`errors` key, both of `type: delegation_interrupted`. Confirm with `jq '.errors|length'` before
appending; the append must be additive (`.errors += [...]`), never a whole-array assignment.

**Files to modify**:
- `specs/errors.json` — append exactly one entry.

**Verification**:
- `jq . specs/errors.json >/dev/null` succeeds.
- `jq '.errors|length'` returns the pre-edit count plus exactly 1.
- The two pre-existing entries are byte-identical (diff the `jq -S '.errors[0:2]'` output against
  a pre-edit capture).
- The new entry's key set is identical to the existing entries' key set.

---

## Testing & Validation

- [ ] `specs/literature-index.json`, `specs/errors.json`, and `~/Projects/Literature/index.json`
      all parse as valid JSON after every phase that touches them.
- [ ] `specs/literature-index.json` entry count is 69 and the `gehrke_jonsson_2004` entry carries
      all six fields, none empty.
- [ ] `bash .claude/scripts/literature-search.sh "bounded distributive lattice"` returns
      `gehrke_jonsson_2004`.
- [ ] The `fidelity` label on that entry names the specific check performed, and matches
      `provenance_fidelity` in the global index.
- [ ] `~/Projects/Literature/SOURCES.md` contains seven new blocker entries, each with a dated,
      concrete, evidence-bearing `Reason not obtained`.
- [ ] `specs/errors.json` holds exactly one new entry, with the pre-existing entries unchanged.
- [ ] `git status --short` in BimodalLogic shows no remaining task-504 file uncommitted, and
      `git show --stat HEAD` lists only task-504 files.
- [ ] No task-number reference was written into any file outside `specs/**` (this includes the
      `SOURCES.md` entries, which cite the report by durable path).

## Artifacts & Outputs

- `specs/504_retry_acquisition_of_missing_representation_sources/summaries/01_*-summary.md` — the
  execution summary, which must state the Literature-repo uncommitted paths explicitly.
- `specs/literature-index.json` — `gehrke_jonsson_2004` entry, fidelity label reconciled, committed.
- `specs/errors.json` — one new entry for the Zotero write-bridge dependency defect.
- `~/Projects/Literature/SOURCES.md` — new dated section, seven R-series blocker entries
  (working-tree change, deliberately uncommitted).
- `~/Projects/Literature/sources/gehrke_jonsson_2004/` — retained source PDF added.
- Deleted: `specs/literature-index.json.bak-504`, `~/Projects/Literature/index.json.bak-task504`.

## Rollback/Contingency

- **Phases 1, 2, 5 (BimodalLogic)**: all changes are value edits or a single append to two JSON
  files that are tracked in git and, at the point of edit, clean or carrying only this task's
  8-line diff. Reverting is `git checkout HEAD -- <path>` on a clean-or-task-scoped file; no
  snapshot is required and none should be taken (a default-mode `git-snapshot.sh` call here would
  be a precautionary checkpoint, which is exactly the anti-pattern the git-workflow rules close).
- **Phase 3 (`SOURCES.md`)**: the edit is a pure end-of-file append. Rolling it back means
  deleting the appended section; because the surrounding file carries another task's uncommitted
  work, roll back by truncating the appended lines, never by `git checkout` on that file, which
  would destroy 215 lines of unrelated uncommitted work.
- **Phase 2 (PDF placement)**: additive only; remove the file to undo.
- **Phase 4 (commit)**: if the staged set is wrong, `git restore --staged <path>` (safe — unstages
  only) and re-stage. If a wrong commit lands, `git revert` it rather than resetting, since the
  working tree carries other sessions' concurrent work.
- **Backup deletions**: perform them only after the Phase 4 commit has landed, so the pre-edit
  state is recoverable from git history before the on-disk copy is removed.
