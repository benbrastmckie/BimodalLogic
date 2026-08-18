# Implementation Plan: Deduplicate 8 stale placeholder entries in the global literature index

- **Task**: 459 - Deduplicate 8 stale placeholder entries in the global literature index
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: 458 (satisfied; its mutations do not touch the 8-pair cluster)
- **Research Inputs**: `specs/459_deduplicate_8_stale_literature_entries/reports/01_dedup-stale-literature-entries.md`
- **Artifacts**: plans/01_dedup-stale-literature-entries.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

`~/Projects/Literature/index.json` currently holds 369 entries under its top-level `entries` key
but only 361 distinct `id` values: 8 ids each appear exactly twice, as a stale migration
placeholder paired with a fully-populated curated record. This plan deletes the 8 stale records
and nothing else, using a guarded, assertion-first script that keys on the `provenance` marker
rather than on array position or `token_count`. Definition of done: `entries` length is 361, the
distinct-`id` count is unchanged at 361, the file still parses, each of the 8 ids resolves to
exactly one surviving entry, and every surviving entry is field-for-field identical to its
pre-deletion populated counterpart.

### Research Integration

The research report is a live re-derivation and drives four load-bearing decisions in this plan:

1. **`token_count = 0` is dead as a discriminator.** A prior task backfilled `token_count` on the
   stale side, so both sides of every pair now carry identical non-zero values. The sole reliable
   discriminator is `provenance == "migrated from ingest schema (doc_id/source_path/chunks_dir)"`,
   present as a key only on the stale side and absent (not null) on the populated side.
2. **Array position is not a key.** The stale entry currently precedes its populated twin in all 8
   pairs (indices 344-361), but this is incidental regularity, not an invariant. Deletion must
   never be done by index or by "keep the second one".
3. **The FTS row-count check is not a meaningful gate for this task.** `literature-build-index.sh
   --global` never opens `index.json`; it globs the filesystem for `chunks.json` manifests. Each
   of the 8 ids has exactly one on-disk directory and one manifest, so no chunk duplication exists
   and the row count cannot move. It is retained only as a side-effect sanity check that no
   filesystem-level damage occurred. The real outcome gates are entry count 369 -> 361, distinct-id
   count still 361, JSON parses, and per-id survivor identity.
4. **Out-of-scope neighbours are named explicitly.** The 3 `doc_id`-only entries (Jónsson-Tarski
   I/II, Goldblatt, positions 366-368) and the 2 unpaired populated entries
   (`pym_ohearn_yang_2004_...`, `ishtiaq_ohearn_2001_...`) sit adjacent to the cluster and must not
   be touched. The deletion loop is scoped to the 8 named ids only, never generalized to "any entry
   with an ingest-schema shape".

Per the report's own instruction, every baseline number above is re-derived live in Phase 1 rather
than consumed from the report — index drift has been observed repeatedly in this corpus.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation was requested for this task.

## Goals & Non-Goals

**Goals**:
- Remove exactly the 8 stale placeholder records from `~/Projects/Literature/index.json`, keeping
  the fully-populated record in each pair.
- Make the deletion refuse to proceed (non-zero exit, zero writes) if any pair fails its
  discriminator assertions, rather than deleting on a weaker signal.
- Prove, field-by-field, that the 8 surviving entries are unchanged by the operation.
- Leave a recoverable backup of the pre-deletion index.

**Non-Goals**:
- Any change to the 3 `doc_id`-only ingest-schema entries or to the 2 unpaired populated entries.
- Any change to `specs/literature-index.json` in this repo (none of the 8 ids appear there; the
  file carries a pre-existing uncommitted modification from unrelated work).
- Any chunk-file, manifest, or `.literature.db` content change. The FTS rebuild is a read-side
  sanity check only.
- Committing or resolving the pre-existing dirty state of `~/Projects/Literature`'s working tree
  from today's unrelated ingests.
- Generalizing the dedup into a reusable "find all duplicate ids" maintenance tool.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting the populated entry instead of the stale one | H | L | Per-pair assertion that exactly one of the two rows carries the `provenance` marker and the other lacks the key entirely; refuse to write on any failure (Phase 2/3) |
| Deletion keyed on array index or `token_count` | H | M | Both explicitly forbidden; script selects by `(id in the 8) AND provenance == marker` only (Phase 2) |
| Over-broad deletion sweeping in the 3 `doc_id`-only or 2 unpaired neighbours | H | L | Deletion loop iterates the hardcoded 8-id list; Phase 4 re-derives total and distinct-id counts and asserts the neighbours still present |
| Whole-file reformat on rewrite, burying the real change in diff noise | M | M | Phase 1 proves byte-exact round-trip fidelity of `json.dumps(indent=2, ensure_ascii=False) + "\n"` before any mutation; Phase 5 confirms the diff contains only deletions |
| Silent field mutation of a survivor during rewrite | M | L | Phase 1 captures a pre-image of the 8 populated entries; Phase 4 asserts byte-identical canonical JSON per survivor |
| Index drift since the research report | M | M | All baselines re-derived live in Phase 1; script asserts against re-derived values, not report literals |
| Partial/corrupt write leaving an unparseable index | H | L | Atomic write (tmp file + `os.replace`) plus Phase 1 backup; rollback is a file copy |
| Misreading the trivially-passing FTS check as validation of the dedup | L | M | Phase 5 states the check's role explicitly: only a *decrease* is a signal, and it signals filesystem damage, not dedup failure |
| `~/Projects/Literature` working tree already dirty from unrelated ingests | L | H | Phase 5 reviews `git diff -- index.json` scoped to the file and isolates the 8 deletions; no commit or stash of unrelated changes |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
consumes an artifact the previous phase produced.

---

### Phase 1: Re-derive live baselines, capture pre-image, back up [COMPLETED]

**Goal**: Establish every number this plan gates on from the live file, prove the rewrite is
formatting-neutral, and make the operation reversible — all before any mutation.

**Tasks**:
- [x] Back up the index: `cp -p ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-$(date +%Y%m%d-%H%M%S)-pre-dedup`; record the exact backup path in the phase notes. *(completed: backup at ~/Projects/Literature/index.json.bak-20260818-142007-pre-dedup, parses OK)*
- [x] Re-derive and record live: total `entries` length; count of entries carrying an `id` key; distinct-`id` count; the list of ids appearing more than once, with their multiplicities. *(completed: total=369, id-carrying=366, distinct-id=358 (report's '361' is an arithmetic slip -- 358 is used as the gate), 8 duplicated ids each x2)*
- [x] Assert the duplicated-id set is exactly the 8 named ids. If it differs in any direction (an id added or dropped), STOP and report — do not proceed on a changed set. *(completed: live set matches report's 8 named ids exactly, both directions -- not a stop condition)*
- [x] Prove round-trip fidelity: read the raw file text, `json.loads` it, re-serialize with `json.dumps(obj, indent=2, ensure_ascii=False) + "\n"`, and assert the result is byte-identical to the raw text. If it is not, STOP — the write strategy in Phase 3 must be revised before proceeding, since any diff would then be uninterpretable. *(completed: byte-identical, confirmed True)*
- [x] Capture the pre-image: write, to a scratch file, the canonical JSON of each of the 8 *populated* entries (the ones lacking the `provenance` key), keyed by id. This is Phase 4's comparison basis. *(completed: 8 canonical json.dumps(sort_keys=True) strings written to scratch preimage_canonical.json)*
- [x] Record whether each of the 8 ids' two entries share a byte-identical `path` string (expected yes, per the report) and that neither carries a `chunks_dir` key. *(completed: all 8 pairs share identical path, neither row carries chunks_dir)*
- [x] Record the pre-existing `git -C ~/Projects/Literature status --porcelain index.json` state. *(completed: ' M index.json', pre-existing dirty state from unrelated ingest work)*

**Timing**: 30 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The report asserts 369 total entries, 361 distinct ids, exactly 8 duplicated
ids matching a named list, and a single contiguous cluster at indices 344-361. Every one of these
is a hypothesis to be confirmed by this phase's own live re-derivation against
`~/Projects/Literature/index.json`; the plan's later phases consume the re-derived values, not the
report's. A mismatch on the duplicated-id *set* is a stop condition; a mismatch on total count or
cluster indices alone is recorded and the re-derived value used.

**Files to modify**:
- None. Read-only, except for creating the backup file and a scratch pre-image file outside the repo.

**Verification**:
- Backup file exists, is non-empty, and `python3 -c "import json;json.load(open(...))"` parses it.
- The duplicated-id set printed matches the 8 named ids exactly (set equality, both directions).
- Round-trip byte-identity assertion passed.
- Pre-image scratch file contains exactly 8 keyed entries.

---

### Phase 2: Author the guarded deletion script and dry-run it [NOT STARTED]

**Goal**: Produce a script that can only ever delete the correct 8 rows, and demonstrate on a
dry run that it selects exactly those rows — without writing to the index.

**Tasks**:
- [ ] Write the script to a scratch path (not into this repo's tree; it is a one-off, not a maintained tool).
- [ ] Hardcode the 8 target ids and the exact discriminator string `migrated from ingest schema (doc_id/source_path/chunks_dir)`.
- [ ] For each of the 8 ids, assert all of the following before any deletion is staged: exactly 2 entries carry that id; exactly 1 of them has `provenance` equal to the marker string; the other has no `provenance` key at all (key absence, not a null value); both carry a byte-identical `path`. Accumulate failures across all 8 ids rather than stopping at the first, so one run reports the full picture.
- [ ] If any assertion fails for any pair: print every failure, exit non-zero, and write nothing — no partial deletion, no output file.
- [ ] Selection rule is `(entry id in the 8-id list) AND (entry provenance == marker)` and nothing else. Do not select by array index, by `token_count`, by position within the pair, or by any ingest-schema shape heuristic.
- [ ] Assert the staged deletion set has size exactly 8 and that the resulting entries length equals the input length minus 8.
- [ ] Write via tmp file + `os.replace` for atomicity, serializing with `json.dumps(obj, indent=2, ensure_ascii=False) + "\n"` (the formatting proven byte-exact in Phase 1). Preserve entry order otherwise.
- [ ] Support a `--dry-run` mode that performs all assertions and prints the selection but writes nothing.
- [ ] Execute `--dry-run` and confirm it reports exactly 8 selected rows, one per id, each carrying the marker.

**Timing**: 30 minutes

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The phase asserts the deletion set is exactly 8 rows, one per named id. The
dry run confirms this at implementation time by printing the selected `(id, array index,
provenance present)` triples; the count is not accepted from this plan.

**Files to modify**:
- Scratch deletion script (new file, outside the repo tree).

**Verification**:
- `--dry-run` exits 0, prints exactly 8 selected rows covering exactly the 8 ids with no repeats.
- `~/Projects/Literature/index.json` byte size and mtime are unchanged after the dry run.
- Negative check: temporarily point the script at a copy of the index with one pair's marker
  stripped, confirm it exits non-zero and writes nothing, then discard the copy. This proves the
  refusal path is live, not merely coded.

---

### Phase 3: Execute the deletion [NOT STARTED]

**Goal**: Apply the verified selection to the live index, atomically.

**Tasks**:
- [ ] Confirm the Phase 1 backup still exists and parses.
- [ ] Run the script without `--dry-run`.
- [ ] Confirm exit status 0 and that the script reports 8 rows removed.
- [ ] Confirm the file still parses immediately after the write.

**Timing**: 10 minutes

**Depends on**: 2

**Verification Tier**: local

**Files to modify**:
- `~/Projects/Literature/index.json` - remove the 8 stale placeholder entries from the `entries` array; no other change.

**Verification**:
- Script exit code 0.
- `python3 -c "import json;json.load(open('~/Projects/Literature/index.json'))"` (expanded path) succeeds.
- `len(entries)` is 361 (or, if Phase 1 re-derived a different total, that total minus 8).

---

### Phase 4: Field-level correctness verification [NOT STARTED]

**Goal**: Prove the operation removed rows and changed nothing else.

**Tasks**:
- [ ] Re-derive total `entries` length and assert it equals the Phase 1 total minus 8.
- [ ] Re-derive the **distinct-`id`** count independently and assert it is unchanged from Phase 1 (361). A drop here would mean an id was eliminated entirely, not deduplicated.
- [ ] Assert no id in the file now appears more than once among the 8 targets — each resolves to exactly one entry.
- [ ] Assert each of the 8 survivors is the populated one: no `provenance` key, non-empty `summary`, full (non-surname-only) `authors`.
- [ ] Byte-identity check: for each of the 8 ids, canonicalize the surviving entry
      (`json.dumps(entry, sort_keys=True, ensure_ascii=False)`) and assert it is byte-identical to
      the Phase 1 pre-image for that id. Any mismatch is a failure requiring rollback, regardless
      of how cosmetic it looks.
- [ ] Assert the out-of-scope neighbours are untouched and still present: the 3 `doc_id`-only entries (Jónsson-Tarski I/II, Goldblatt) and the 2 unpaired populated entries (`pym_ohearn_yang_2004_possible-worlds-resources-bi`, `ishtiaq_ohearn_2001_bi-assertion-language`).
- [ ] Assert no entry anywhere in the file still carries the migration `provenance` marker *and* one of the 8 target ids.

**Timing**: 25 minutes

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the post-state counts 361 total and 361 distinct. Both are
derived live from the mutated file and cross-checked against Phase 1's re-derived pre-state
(pre-total minus 8, pre-distinct unchanged), never against this plan's literals.

**Files to modify**:
- None. Read-only verification.

**Verification**:
- All eight assertions above pass, each with its result printed rather than merely asserted silently.
- The byte-identity check reports 8/8 survivors identical to pre-image.

---

### Phase 5: Side-effect sanity, diff isolation, and closeout [NOT STARTED]

**Goal**: Confirm nothing outside `index.json` moved, and that the change set is exactly 8 deletions.

**Tasks**:
- [ ] Run `bash ~/Projects/Literature/.claude/scripts/literature-build-index.sh --global`; confirm exit 0.
- [ ] Query `sqlite3 ~/Projects/Literature/.literature.db "SELECT count(*) FROM chunks_fts;"` and confirm the count has not *decreased* from the 17,736 baseline (re-derive the baseline value from the report's figure and treat equality as the expected result). Record the value. Interpretation: an unchanged count is the expected pass; a decrease indicates accidental filesystem-level damage to chunk files or manifests, not a dedup problem. This check does not validate the dedup itself.
- [ ] Review `git -C ~/Projects/Literature diff -- index.json` and confirm the change relative to the pre-existing dirty state consists solely of 8 removed entry blocks — no additions, no reindentation, no reordering, no whitespace-only hunks elsewhere.
- [ ] Confirm `specs/literature-index.json` in this repo is byte-identical to its pre-task state: compare its `git diff` against the Phase 1 record and confirm no new hunk. It must retain its pre-existing uncommitted modification untouched.
- [ ] Do not commit or stash `~/Projects/Literature`'s unrelated dirty files. Leave the index change uncommitted there unless the user directs otherwise; note the backup path and the deletion script path in the implementation summary.
- [ ] Record final numbers (pre/post totals, distinct ids, FTS row count, backup path) in the summary.

**Timing**: 25 minutes

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- None in this repo. `~/Projects/Literature/.literature.db` is rebuilt as an ephemeral artifact by the index build script (documented atomic tmp-then-rename), not a source-of-truth mutation.

**Verification**:
- Index build exits 0.
- `chunks_fts` row count >= 17,736 and recorded.
- `git diff -- index.json` shows deletions only, 8 blocks.
- `specs/literature-index.json` shows no new diff hunk relative to Phase 1's recorded state.

---

## Testing & Validation

- [ ] Pre-deletion backup of `~/Projects/Literature/index.json` exists, is non-empty, and parses.
- [ ] Round-trip serialization fidelity proven byte-exact before any mutation.
- [ ] Duplicated-id set live-re-derived and confirmed equal to the 8 named ids (set equality, both directions).
- [ ] Deletion script refuses (non-zero exit, no write) when a pair's discriminator assertion fails — demonstrated, not assumed.
- [ ] Deletion selected exactly 8 rows, one per target id, each carrying the migration `provenance` marker.
- [ ] Post-deletion `entries` length is 361 (pre-total minus 8).
- [ ] Post-deletion distinct-`id` count is 361 — re-derived independently, not inferred from the total.
- [ ] `json.load` on the mutated index succeeds.
- [ ] Each of the 8 ids resolves to exactly one surviving entry, and that entry lacks `provenance`, has a non-empty `summary`, and has full author names.
- [ ] All 8 survivors are byte-identical (canonical JSON) to their Phase 1 pre-images.
- [ ] The 3 `doc_id`-only entries and the 2 unpaired populated entries are still present and unmodified.
- [ ] `literature-build-index.sh --global` exits 0.
- [ ] `chunks_fts` row count has not decreased from 17,736.
- [ ] `git diff -- index.json` in `~/Projects/Literature` shows only the 8 deletions.
- [ ] `specs/literature-index.json` in this repo is byte-identical to its pre-task state.

## Artifacts & Outputs

- `~/Projects/Literature/index.json` — 361 entries, 8 stale placeholders removed.
- `~/Projects/Literature/index.json.bak-{TIMESTAMP}-pre-dedup` — pre-deletion backup.
- Scratch deletion script and pre-image file (outside this repo; paths recorded in the summary).
- `specs/459_deduplicate_8_stale_literature_entries/summaries/01_dedup-stale-literature-entries-summary.md` — implementation summary with final recorded numbers.

## Rollback/Contingency

Rollback is a single file restore: `cp -p {backup_path} ~/Projects/Literature/index.json`, then
re-verify `json.load` succeeds and `len(entries)` is back to the Phase 1 pre-total. No other
artifact needs reverting — `.literature.db` is rebuildable from disk at any time via
`literature-build-index.sh --global`, and no chunk file, manifest, or repo file is modified by this
plan.

Trigger rollback if: the post-deletion file fails to parse; the distinct-`id` count drops below the
Phase 1 value; any survivor fails the byte-identity check; or the `git diff` shows anything other
than the 8 deletion blocks. In every case, restore first, then diagnose against the backup rather
than against the mutated file.
