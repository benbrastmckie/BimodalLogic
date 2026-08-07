# Implementation Plan: Task #435

- **Task**: 435 - curate_termination_literature_subindex
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/434_discharge_mintpaysfortime_residual/reports/02_spawn-analysis.md
- **Artifacts**: plans/01_curate-termination-subindex.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Register the termination-measure-relevant documents that already exist in the global corpus
(`~/Projects/Literature/index.json`) into the per-repo sub-index
(`specs/literature-index.json`), with relevance annotations, so that a subsequent `--lit`
measure-design dispatch surfaces them. Then run one confirmatory online discovery pass for a
closer-fit paper, and verify the result against acceptance criteria that actually discriminate.

The work is pure curation, not acquisition: planning-time verification confirmed every named
document is already present and resolvable in the global corpus. The substance of this task is
therefore in three judgment calls the task description leaves open — registration *granularity*
(parent vs. section), *which* `baier_katoen_2008` parts to register, and which *field name*
carries the annotation — plus replacing an acceptance criterion that, as written, passes
before any work is done.

### Research Integration

The spawn analysis (`reports/02_spawn-analysis.md`) established the gap is curation rather than
acquisition, and enumerated the candidate documents. Its dependency reasoning is load-bearing
here: it argues Task 2 (the measure design) depends on *which* papers are curated and *how they
are annotated*, because the relevance notes shape which termination-ordering pattern the
implementer attempts first. That makes the annotation text a deliverable in its own right, not
incidental metadata — Phase 4 treats it accordingly.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and `roadmap_flag` is absent, so no
roadmap review/update phases are included. `specs/ROADMAP.md` exists but was not passed to this
planning dispatch and is not consulted or modified.

## Planning-Time Verification Findings

These were confirmed empirically during planning, not assumed. Several contradict the task
description; the phases below are built on the verified version.

**F1 — All named documents exist and resolve.** Every doc_id named in the task description is
present in the global index and resolves through `literature-briefing.sh`. An initial
`jq '.entries[] | select(.doc_id==$d)'` probe returned 0 matches for 9 of 10 and was *wrong*:
the global index is key-heterogeneous — 302 entries carry `id`, 41 carry `doc_id`, and 32 carry
both (343 total). The briefing script resolves sub-index `doc_id` values against the global
`.id` field. `massacci_2000_single_step_tableaux_for_modal_logics` carries both keys, so it
resolves. Nine global entries carry `doc_id` *without* `id` and would not resolve if targeted —
none of the candidates here are among them, but Phase 5's ingest could land in that namespace.

**F2 — The briefing renders `relevance`, not `reason`.** `literature-briefing.sh` reads
`.entries[] | select(.doc_id == $id) | .relevance` from the sub-index. All 33 existing sub-index
entries carry `reason` and *zero* carry `relevance`. Confirmed against live output: the baseline
briefing emits no `Relevance:` line for any of the 33 documents, while a scratch harness using
`relevance` rendered them. Writing new entries with `reason` alone would make every annotation
invisible to the agent that needs it — which, per the research report's dependency argument, is
the entire point of the task.

**F3 — The stated acceptance criterion is vacuous.** The task description asks to run the
briefing "with a query on 'termination measure time minting rules preserved under
identification'" and confirm `sparse=false`. Per-repo mode accepts no query at all, and its
`coverage_count` is the number of *resolved sub-index documents*, not query-relevant segments.
The live baseline already emits
`<!-- lit-coverage mode=repo seg_count=33 sparse=false threshold=3 -->` — so the criterion
passes before any work is done and cannot detect failure. Phase 6 replaces it.

**F4 — The real failure mode is silent per-document drop.** An unresolvable doc_id produces
`Warning: doc_id 'X' not found in global index — skipping` on **stderr** and is dropped from the
briefing while `sparse` stays `false`. Baseline stderr is clean, which makes a clean post-change
stderr a meaningful gate — and the only one that catches this failure.

**F5 — Section entries are stamped UNVERIFIED; parents are not.** Section-level entries
(`caleiro_2013_secNN`, `blackburn_2002_ch06_secNN`) carry no `provenance_fidelity` in
index.json, and absent fidelity is rendered as
`[UNVERIFIED - provenance_fidelity: unverified_summary]`. The parent `caleiro_2013` carries
`verified_conversion` and resolves to 7 chunks (~20,846 tokens). Registering the parent is
strictly better than registering its 7 sections. Blackburn has no verified chapter-level parent
— only `blackburn_2002_book` (35 chunks, whole book) — so its Ch.6 sections face a real
precision-vs-provenance tradeoff.

**F6 — `baier_katoen_2008` metadata cannot identify the right parts.** All 12 parts share an
identical title ("Principles of Model Checking"), an identical and evidently wrong
`token_count` (39848 for every part), and null page ranges. The FTS5 database indexes this
document under the bare doc_id `baier_katoen_2008`, which does *not* exist in index.json, so
search hits cannot be mapped back to a registrable id. Part selection must come from reading
the part files directly.

**F7 — `literature-search.sh` AND-s query terms.** The long query
"LTL to Buchi automaton tableau closure construction" returns zero results with
`degraded: true, fallback_tier: "none"`, while "mosaic" returns well-ranked hits. Verification
queries must be short.

## Goals & Non-Goals

**Goals**:
- Register the termination-relevant global-corpus documents into `specs/literature-index.json`
  with annotations that actually render.
- Make the registration granularity a deliberate, recorded decision rather than a transcription
  of the task description's phrasing.
- Run one confirmatory online discovery pass and register any closer-fit paper found.
- Verify with criteria that can fail.

**Non-Goals**:
- Backfilling `relevance` onto the 33 pre-existing entries. This is a real, confirmed defect
  (F2) — their annotations are invisible today — but it is a corpus-wide repair affecting an
  unrelated research line, and folding it in would make this task's diff unreviewable. Record
  it as a follow-up; do not fix it here.
- Normalizing the global index's `id`/`doc_id` heterogeneity (F1) or repairing
  `baier_katoen_2008`'s duplicated `token_count` metadata (F6). Both are global-corpus defects
  outside this task's `file_scope`.
- Designing the fourth termination-measure component. That is the dependent task.
- Modifying any script under `.claude/scripts/`. Note that `.claude/**` is a disposable deploy
  artifact here; any script change would belong in `agent-system/extensions/**` and is out of
  scope regardless.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| False green: acceptance criterion passes without the work landing (F3) | H | H (certain if taken as written) | Phase 6 replaces the criterion with per-document resolution + annotation-render + stderr checks |
| Annotations written to `reason` only, rendering nothing (F2) | H | M | Phase 4 writes both `reason` and `relevance`; Phase 6 greps rendered output for each annotation |
| A registered doc_id silently drops from the briefing (F1, F4) | H | M | Phase 6 asserts stderr contains zero `not found in global index` warnings and counts resolved documents |
| Editing a 33-entry JSON by hand corrupts existing entries | H | M | jq-based append only; Phase 4 diffs the 33 pre-existing entries byte-for-byte and validates JSON |
| Online pass ingests a low-fidelity PDF into the *shared* global corpus | M | M | `--dry-run` first; inspect the directive token and resulting `provenance_fidelity` before accepting |
| Online pass finds nothing | L | M | A null result is a valid, recordable outcome — Phase 5 records it explicitly rather than treating it as failure |
| Over-registering (all 7 caleiro sections + 12 baier parts) dilutes the briefing with UNVERIFIED noise | M | M | Phase 3 fixes a granularity policy before any writing; Phase 2 narrows baier to the parts that earn their place |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Baseline Capture and Candidate Resolution Audit [COMPLETED]

**Goal**: Establish a falsifiable before-state and confirm every candidate doc_id resolves,
so that Phase 6's comparison means something.

**Tasks**:
- [x] Capture baseline `literature-briefing.sh` stdout and stderr to separate scratch files;
      record the `<!-- lit-coverage -->` marker line verbatim. *(completed: `<!-- lit-coverage mode=repo seg_count=33 sparse=false threshold=3 -->`, stderr empty)*
- [x] Record the baseline sub-index entry count and a hash of the `entries` array. *(completed: 33 entries, sha256 bedb30e9...134b4a)*
- [x] For each candidate doc_id, confirm it resolves against the global index `.id` field, and
      record its `provenance_fidelity` (or its absence) and child `chunk_count`. *(completed: all 8 candidate parents resolve, all verified_conversion; caleiro/blackburn secNN children confirmed provenance_fidelity:null (F5); baier_katoen_2008 parts confirmed identical title/token_count (F6))*
- [x] Confirm the baseline stderr is free of `not found in global index` warnings, establishing
      the clean-stderr gate as valid. *(completed: confirmed clean)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Planning-time probing indicates all candidate ids resolve, baseline is
`seg_count=33 sparse=false`, and baseline stderr is clean. Confirm each by direct execution —
do not carry these forward on this plan's authority.

**Files to modify**:
- None (read-only; scratch outputs only)

**Verification**:
- Baseline stdout, stderr, and marker line are captured to disk and can be diffed later.
- Every candidate doc_id has a recorded resolution status and fidelity value.

---

### Phase 2: Identify the `baier_katoen_2008` Parts Worth Registering [COMPLETED]

**Goal**: Replace "the parts covering LTL-to-automaton tableau construction" with a specific,
evidence-backed list.

**Tasks**:
- [x] Grep each of the 12 part files under
      `~/Projects/Literature/sources/baier_katoen_2008/` for the LTL-to-automaton vocabulary
      (`elementary set`, `closure of`, `Büchi`/`Buchi`, `NBA`). *(completed: note the corpus
      encodes Büchi with a decomposed combining diaeresis (U+0308) after 'u', not precomposed
      ü — a naive grep for precomposed ü silently returns 0 everywhere; using a combining-mark-
      aware pattern surfaces the true counts. part04: elementary_set=23, closure_of=3;
      part02: closure_of=6; part03: NBA=167; all other parts negligible (0-2))*
- [x] Read enough of the top-scoring part(s) to confirm the closure-set construction and its
      termination argument are genuinely present, not merely name-dropped in a forward
      reference or index. *(completed: part04 confirmed genuine — Definition 5.35 "Elementary
      Sets of Formulae", Theorem 5.37 GNBA construction with state-space bound O(2^|subf(ϕ)|).
      part02's "closure of" hits are a DIFFERENT concept — the topological closure of a
      linear-time property (Ch.3 safety/liveness), not the syntactic closure(ϕ) used in the
      tableau. part03's NBA hits are the general Ch.4 NBA definition and nested-DFS emptiness
      check — real automata background but not the specific elementary-set termination bound.
      part07/10/11's "closure of" hits are all bisimulation/relational closure, unrelated.
      part12's 2 "elementary set" hits are back-matter index entries pointing to page 276
      (inside part04), not content.)*
- [x] Fix the final part list, and record the evidence (hit counts plus a confirming quotation
      or section heading) that justifies including each part and excluding the rest. *(completed:
      final list is `baier_katoen_2008_part04` only — see Phase 2 evidence note below)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: A planning-time keyword sweep put the content in `part04` (26 hits), with
secondary coverage in `part02` (6 hits) and negligible counts elsewhere (0-2). This is a
keyword-frequency signal only — confirm by reading before registering, and be prepared for the
answer to be one part or three rather than two.

**Files to modify**:
- None (read-only investigation)

**Verification**:
- A written list of `baier_katoen_2008_partNN` ids to register, each with cited evidence.
- An explicit statement of which parts were excluded and why.

**Result — final part list**: `baier_katoen_2008_part04` only.

**Evidence for inclusion (part04)**: Definition 5.35 "Elementary Sets of Formulae" —
`B ⊆ closure(ϕ)` consistent, maximal, locally consistent w.r.t. until; Theorem 5.37 proof
constructing the GNBA `Gϕ = (Q, 2^AP, δ, Q0, F)` with `Q` = the set of all elementary sets of
`closure(ϕ)`, and the accompanying state-space bound `|Q| ≤ 2^|subf(ϕ)|` — this is the
closure-set potential/termination argument the research report names, cited by definition and
theorem number rather than a keyword hit alone.

**Evidence for exclusion**:
- `part02` (closure_of=6): a different "closure" — the *topological* closure of a linear-time
  property (Ch.3 safety/liveness decomposition, `closure(P) = {σ | pref(σ) ⊆ pref(P)}`), not the
  syntactic `closure(ϕ)` of an LTL formula used in the tableau construction.
- `part03` (NBA=167): Ch.4's general nondeterministic Büchi automaton definition and the nested
  depth-first-search emptiness check — genuine automata background but not the specific
  elementary-set termination bound.
- `part07`, `part10`, `part11` (closure_of=1-2 each): all reflexive/transitive/bisimulation
  relational closure, unrelated to LTL formula closure.
- `part12` (elementary_set=2): back-matter index entries ("elementary sets, 276") pointing back
  into part04, not content of their own.
- `part01`, `part05`, `part06`, `part08`, `part09`: 0-1 incidental hits, no relevant content.

**Methodology note**: the source `.md` encodes "Büchi" with a *decomposed* combining diaeresis
(U+0308 following `u`) rather than the precomposed `ü` (U+00FC) — a naive `grep -o 'ü'`
search silently returns 0 matches across all 12 parts. A combining-mark-aware pattern
(`[Bb]ü?chi`) was required to get true counts; this is the same corpus-wide combining-mark
defect documented in `specs/literature-index.json`'s `rabinovich_2014` entry hazard note.

---

### Phase 3: Fix the Registration Granularity Policy [NOT STARTED]

**Goal**: Decide parent-vs-section registration for `caleiro_2013` and the Blackburn Ch.6
sections, on the record, before any file is written.

**Tasks**:
- [ ] Confirm F5 directly: check `provenance_fidelity` presence for `caleiro_2013` versus its
      `secNN` children, and for `blackburn_2002_ch06_secNN` versus `blackburn_2002_book`.
- [ ] Decide caleiro granularity. The task description asks for "all 7 chunked sections"; the
      verified tradeoff favors the parent (verified provenance, all 7 chunks reachable, one
      entry instead of seven UNVERIFIED ones). Record the decision and its rationale.
- [ ] Decide Blackburn granularity, weighing Ch.6 section precision against the UNVERIFIED
      stamp that section-level entries carry, given the only verified alternative is the entire
      35-chunk book.
- [ ] Produce the final registrable id list: caleiro, Blackburn, massacci, venema, gerth, the
      two vardi entries, and Phase 2's baier parts.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The final list is expected to be roughly 8-12 entries. The count is an
output of the two granularity decisions, not an input constraint — do not pad or trim the list
to hit a number.

**Files to modify**:
- None (decision-recording only)

**Verification**:
- A final id list exists, with a recorded rationale for each parent-vs-section choice.
- Every id on the list was confirmed resolvable in Phase 1.

---

### Phase 4: Register Entries into the Sub-Index [NOT STARTED]

**Goal**: Write the entries with annotations that render and that carry the design signal the
dependent measure-design task needs.

**Tasks**:
- [ ] For each id, write both `relevance` (rendered by the briefing — F2) and `reason`
      (matching the file's existing convention and recording provenance).
- [ ] Make each `relevance` note state the *bearing on the measure-design question*, not just
      the document's topic — which termination-ordering pattern it supplies (mosaic bound,
      closure-set potential, prefix-length rule bound, interval/density guard) and how it
      relates to paying for `untlNeg`/`snceNeg`/`densityRule` or to preservation across
      `identifyTime`.
- [ ] Where a section-level entry was chosen despite the UNVERIFIED stamp, say so in the note
      so a downstream reader is not misled about provenance.
- [ ] Append via jq rather than hand-editing; update the `updated` timestamp.
- [ ] Validate the file parses and that the 33 pre-existing entries are byte-for-byte unchanged.

**Timing**: 0.75 hours

**Depends on**: 2, 3

**Verification Tier**: interface

**Scope Hypothesis**: Entry count follows from Phase 3's list. Confirm the post-write count
equals the Phase 1 baseline count plus the Phase 3 list length exactly — a mismatch means an
id was dropped or duplicated.

**Files to modify**:
- `specs/literature-index.json` — append the new entries; bump `updated`

**Verification**:
- `jq empty specs/literature-index.json` succeeds.
- The first 33 entries are identical to the Phase 1 baseline.
- Every new entry carries both a non-empty `relevance` and `reason`.

---

### Phase 5: Confirmatory Online Discovery Pass [NOT STARTED]

**Goal**: Check whether a closer-fit paper — well-founded / Dershowitz-Manna-style termination
orderings for loop-checking modal-temporal tableaux — is missing from the corpus entirely.

**Tasks**:
- [ ] Run `literature-discover.sh` with a query targeting well-founded/Dershowitz-Manna
      termination orderings for loop-checking modal and temporal tableaux. Run more than one
      phrasing if the first returns only Tier-1 hits already registered.
- [ ] Triage results: ignore `available`/`in_zotero` records (already local); consider only
      `open_access`, `paywall`, `in_zotero_no_pdf`.
- [ ] For any genuinely closer-fit candidate, run `literature-ingest-online.sh --record` with
      `--dry-run` first; inspect the directive token before committing to a live ingest.
- [ ] On successful ingest, register the new doc_id in the sub-index with a `relevance` note,
      and confirm the resulting `provenance_fidelity` is acceptable.
- [ ] If nothing closer-fit is found, record that explicitly — including the queries tried — as
      the pass's result.

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: The research report predicts no online ingestion will be necessary. Treat
that as a prediction to test, not a reason to skip the pass — but equally, do not manufacture an
ingest to make the phase feel productive. A well-documented null result satisfies this phase.

**Files to modify**:
- `specs/literature-index.json` — only if an ingest succeeds

**Verification**:
- The queries run and their results are recorded.
- Either a new entry is registered with acceptable fidelity, or a null result is recorded with
  the queries that produced it.
- If an ingest occurred, the sub-index still parses and prior entries are unchanged.

---

### Phase 6: Verify Against Discriminating Criteria [NOT STARTED]

**Goal**: Confirm the curation actually reaches an agent, using checks that can fail. The
criterion in the task description cannot (F3) and is deliberately not used as the gate.

**Tasks**:
- [ ] Re-run `literature-briefing.sh`, capturing stdout and stderr separately.
- [ ] Assert stderr contains zero `not found in global index` warnings (F4) — this is the
      primary gate.
- [ ] Assert every newly registered document appears by title in stdout, each followed by its
      `Relevance:` line (F2). Absence of the `Relevance:` line is a failure even if the title
      renders.
- [ ] Assert the `<!-- lit-coverage -->` `seg_count` equals baseline plus the number of new
      entries — confirming none were silently dropped. Record that `sparse=false` holds, while
      noting it held at baseline too and therefore proves nothing on its own.
- [ ] Run short, AND-safe `literature-search.sh` queries (F7) — e.g. `mosaic`, `closure`,
      `elementary sets` — and confirm hits land in the newly registered documents, establishing
      the corpus is actually reachable for this subject matter.
- [ ] Record the follow-up defect from F2: the 33 pre-existing entries carry no `relevance` and
      their annotations do not render.

**Timing**: 0.5 hours

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- None (verification only)

**Verification**:
- Clean stderr; per-document title and `Relevance:` line present for every new entry.
- `seg_count` arithmetic matches exactly.
- Search hits demonstrate reachability of the termination/mosaic material.

---

## Testing & Validation

- [ ] `specs/literature-index.json` is valid JSON and the 33 pre-existing entries are unchanged.
- [ ] Briefing stderr contains zero `not found in global index` warnings.
- [ ] Every newly registered document renders both a title line and a `Relevance:` line.
- [ ] `seg_count` equals the baseline count plus the number of newly registered entries.
- [ ] Short-form corpus searches return hits inside the newly registered documents.
- [ ] The online discovery pass produced either a registered ingest or a recorded null result
      with its queries.

## Artifacts & Outputs

- `specs/literature-index.json` — extended with termination-relevant entries carrying rendering
  annotations
- A recorded granularity decision (parent vs. section) with rationale
- A recorded `baier_katoen_2008` part selection with supporting evidence
- The online discovery pass result (ingest or documented null)
- A follow-up note on the 33 pre-existing entries whose annotations do not render

## Rollback/Contingency

`specs/literature-index.json` is version-controlled and this task touches only that file, so
`git checkout -- specs/literature-index.json` fully reverts the curation. Capture the baseline
copy in Phase 1 regardless, so a partial write can be restored without relying on the working
tree being clean.

The one action that escapes this rollback is a Phase 5 live ingest, which writes into the
*shared* global corpus (`~/Projects/Literature/`) and possibly Zotero — outside this repo and
outside `git checkout`'s reach. That asymmetry is why Phase 5 requires `--dry-run` before any
live ingest. If a bad ingest lands, it must be reverted in the global corpus directly; note
that removing it there affects every project sharing that corpus, so prefer leaving a correctly
ingested but unregistered document over an aggressive cleanup.
