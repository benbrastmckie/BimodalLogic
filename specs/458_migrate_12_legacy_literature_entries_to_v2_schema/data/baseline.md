# Phase 1 Baseline — Live Re-Derivation (Task 458)

Derived live at implementation time (2026-08-18), per the plan's Phase 1 mandate that every later
phase consumes only these numbers, never the research report's or the plan's recorded numbers.

## Prerequisites

| Tool / Script | Present | Executable |
|---|---|---|
| `python3` (3.13.13) | yes | yes |
| `jq` | yes | yes |
| `sqlite3` | yes | yes |
| `.claude/scripts/literature-build-index.sh` | yes | yes (`-rwxr-xr-x`) |
| `.claude/scripts/literature-search.sh` | yes | yes (`-rwxr-xr-x`) |

## Index-Level Baseline

| Metric | Research report | Plan-time (recorded in plan) | **Live (this phase)** | Verdict |
|---|---|---|---|---|
| Total index entries | 370 | 369 | **369** | DRIFTED (research -> plan/live) |
| Distinct ids | 362 | -- | **359** | DRIFTED (research -> live) |
| FTS (`chunks_fts`) row count | 17,788 | -- | **17,736** | DRIFTED (research -> live) |
| Entries with null `doc_type` (the 12 targets) | -- | 12 | **12** | PASS |

`~/Projects/Literature/index.json` parses clean via Python's `json` module with top-level keys
`version` / `description` / `token_budget` / `max_chunks` / `entries` — confirmed directly
(not via `jq` regex over `.id`, which the research report noted had previously produced a
`null`-indexing error).

**Gate floor for Phase 6**: the live FTS row count of **17736** is the number Phase 6 compares
against — not 17,788 (research) and not any other recorded figure.

## The Twelve Targets — Presence and Missing-Field Confirmation

All twelve target ids are present exactly once each in `entries`, and each is missing exactly the
five fields `provenance_fidelity`, `path`, `token_count`, `doc_type`, `source_format` (confirmed
by direct field inspection, not by `doc_type is null` alone):

| id | missing fields | verdict |
|---|---|---|
| brics-rs-96-35 | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| cattani-winskel-2005-profunctors | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| brics-rs-94-7 | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| schultz-spivak-temporal-type-theory | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| fong-speranzon-spivak-temporal-landscapes | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| schultz-spivak-vasilakopoulou-dynamical-systems-sheaves | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| thomason-1970-indeterminist-time | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| rutten-2000-universal-coalgebra | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| jacobs-coalgebra-intro-draft | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| danos-krivine-rccs | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| reynolds-2003-ockhamist | provenance_fidelity, path, token_count, doc_type, source_format | PASS |
| rumberg-zanardo-2019-transition-structures | provenance_fidelity, path, token_count, doc_type, source_format | PASS |

## Chunk-Count Cross-Check Against Research's Table

Research asserted per-entry chunk counts: 38 / 129 / 76 / 236 / 31 / 45 / 77 / 353 / 1448 / 32 /
29 / 41 (order per its own table). Live on-disk `chunk_*.md` counts, matched against the stored
`chunk_count` field:

| id | stored `chunk_count` | live `chunk_*.md` files on disk | match | matches research figure |
|---|---|---|---|---|
| brics-rs-96-35 | 38 | 38 | PASS | PASS |
| cattani-winskel-2005-profunctors | 129 | 129 | PASS | PASS |
| brics-rs-94-7 | 76 | 76 | PASS | PASS |
| schultz-spivak-temporal-type-theory | 236 | 236 | PASS | PASS |
| fong-speranzon-spivak-temporal-landscapes | 31 | 31 | PASS | PASS |
| schultz-spivak-vasilakopoulou-dynamical-systems-sheaves | 45 | 45 | PASS | PASS |
| thomason-1970-indeterminist-time | 77 | 77 | PASS | PASS |
| rutten-2000-universal-coalgebra | 353 | 353 | PASS | PASS |
| jacobs-coalgebra-intro-draft | 1448 | 1448 | PASS | PASS |
| danos-krivine-rccs | 32 | 32 | PASS | PASS |
| reynolds-2003-ockhamist | 29 | 29 | PASS | PASS |
| rumberg-zanardo-2019-transition-structures | 41 | 41 | PASS | PASS |

No divergence beyond ±10% anywhere; no mismatch in any of the twelve's chunk counts. No stop
condition triggered.

## `chunks_dir` Location Confirmation

For each of the twelve, `chunks_dir` resolves to an existing directory directly under
`~/Projects/Literature/<id>/` (**not** under `sources/`) — confirmed by exact string equality
against `/home/benjamin/Projects/Literature/{id}` for all twelve. PASS for all twelve.

## No Canonical Whole-Document `.md`

For each of the twelve `chunks_dir` directories, a glob for `*.md` files not matching the
`chunk_*.md` pattern returned an empty list for all twelve. This confirms summing `chunk_*.md`
character counts is the correct (non-double-counting) basis for the later `token_count`
computation. PASS.

## `/tmp/task54-lit/*.pdf` Absence

`/tmp/task54-lit/` exists but contains no `*.pdf` files for any of the twelve targets — its sole
entry is a directory named `thomason-1970-test.md` (not a PDF, not one of the twelve source
files). PASS: the twelve `/tmp/task54-lit/<id>.pdf` source files the research described are
confirmed still absent.

## `literature-fidelity-audit.sh` `sources/`-Scope Confirmation

`literature-fidelity-audit.sh` classifies only `sources/<dir>/` directories (confirmed by reading
the script: `prefix = f"sources/{dirname}/"` appears at both matching sites, and its usage text
states "Classify every sources/<dir>/"). It does not accept a document-id argument at all
(`--dry-run`/`--write`/`-h` are its only flags).

Running `literature-fidelity-audit.sh --dry-run` over the full corpus and grepping its 151-line
report for each of the twelve target ids confirmed **zero matches for all twelve** — the script
produces no output for any of them. This is recorded as the reason the manual chunk-read is the
sole adjudication evidence for these twelve entries, matching the task description's premise
exactly: none of them live under `sources/`, so the automated audit structurally cannot see them.

## Master Pre-Task Backup

```
cp ~/Projects/Literature/index.json ~/Projects/Literature/index.json.bak-20260818-135342-pre-458
```

MD5 of `index.json` and the backup match exactly (`8149f3fc568c199cb814e3d3ccca65d4`), confirming
a faithful byte-for-byte snapshot before any Phase 2+ work begins.

## `specs/literature-index.json` Pre-Task State

None of the twelve target ids appear anywhere in `specs/literature-index.json` (confirmed by
substring search over the serialized JSON for all twelve). This is the Non-Goal baseline Phase 6
re-checks at the end: the sub-index must remain byte-identical throughout this task. MD5 at
baseline: `bc66820d6ac166d4cf9810a51c6b7e5e`.

## Overall Verdict

All Phase 1 checks PASS except the three explicitly-expected drift items (entry count, distinct
id count, FTS row count), each of which the plan's Scope Hypothesis anticipated and which are
within the plan's tolerance (no divergence exceeds the ±10% threshold; the twelve chunk counts
match exactly). No stop condition was triggered. Proceed to Phase 2/3.
