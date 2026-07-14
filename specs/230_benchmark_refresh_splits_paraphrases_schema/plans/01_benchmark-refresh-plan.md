# Implementation Plan: Task #230

- **Task**: 230 - benchmark_refresh_splits_paraphrases_schema
- **Status**: [COMPLETED]
- **Effort**: 7 hours
- **Dependencies**: 229 (completed 2026-06-02)
- **Research Inputs**: specs/230_benchmark_refresh_splits_paraphrases_schema/reports/01_benchmark-refresh.md
- **Artifacts**: plans/01_benchmark-refresh-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Regenerate all benchmark-derived artifacts after task 229's contamination resolution, by
enriching `data/bmlogic-bench.jsonl` **in place** (following `data/scripts/add_contamination_flag.py`'s
atomic-rewrite pattern) and then regenerating downstream artifacts. The dependency-driven order
is: sub-item 5 (fill 15 null `pattern_key` + repair stale `metrics`) -> sub-item 3 (add
`formula_sexpr`/`formula_tokens`/`pattern_features` behind a 6,029-record round-trip fidelity
gate) -> sub-item 2 (restore `nl_paraphrase` via the rule-based generator + validator) ->
sub-item 1 (regenerate splits, which classify by `pattern_key`) -> metadata sync (croissant
v1.2 -> v1.3, dataset card, HF README, `hf-dataset/validate.py`). Definition of done: 777
records with 20 non-null-schema fields, 0 null `pattern_key`, correct 4-slice partition, and
`python data/hf-dataset/validate.py --config bmlogic-bench` exiting 0.

### CRITICAL INVARIANT (applies to every phase)

**NEVER rerun `scripts/finalize_benchmark.py`.** It re-samples from the gitignored
`data/bmlogic-bench-validated.jsonl` pool with fixed seed 42205 and would destroy record
identity and task 229's `contamination_flag` values (553 true / 224 false). All benchmark
changes in this plan are in-place enrichments of the existing 777 records. Any implementer
tempted to "just regenerate the benchmark" must stop and re-read this paragraph.

### Research Integration

Key findings integrated from `reports/01_benchmark-refresh.md`:
- All 15 null-`pattern_key` records are `source: anchor_invalid`; their `metrics`
  modalDepth/temporalDepth/impCount are also stale (zeroed), while `metrics.complexity` is
  correct (plain AST node count verified on all 15).
- The 762 non-null records satisfy `pattern_key == metrics` structural fields exactly — usable
  as calibration ground truth for the Python re-derivation.
- Exact formats for `formula_sexpr` (prefix s-expr, atoms quoted), `formula_tokens` (pre-order,
  atom emits `["ATOM","p"]`), and `pattern_features`
  (`[modalDepth, temporalDepth, impCount, complexity, topOperator.toNat]` with
  Atom=0, Bottom=1, Implication=2, Box=3, AllPast=4, AllFuture=5, Until=6, Since=7) are
  documented from Lean ground truth (`Theories/Bimodal/Automation/DataExport.lean:229-246`,
  `DatasetExport.lean:299-304`, `SuccessPatterns.lean:76-83`). Only the 6 primitive top-tag
  cases occur in practice.
- `generate_paraphrases.py` is fully rule-based (no LLM/API); `validate_paraphrases.py` is an
  exit-code gate; `test_paraphrases.py` provides unit tests.
- Splits bug root cause: `generate_splits.py:33-43` falls back to zeroed `metrics` when
  `pattern_key` is null, misclassifying modal/temporal formulas as propositional-only. Also fix
  the hardcoded `generation_date` at `generate_splits.py:137`.
- Sub-item 4 decision (adopted): **KEEP** `max_modal_depth`/`max_temporal_depth` and document
  them as intentional denormalization. Verified redundant (0 mismatches over 6,029 records) but
  removal breaks the 16-field schema contract, two validators, and published HF data.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context provided for this task.

## Goals & Non-Goals

**Goals**:
- Fill all 15 null `pattern_key` values and repair the same records' stale `metrics`
  structural sub-fields (modalDepth, temporalDepth, impCount), recomputed from `formula_ast`.
- Add `formula_sexpr`, `formula_tokens`, `pattern_features` to all 777 benchmark records,
  proven byte-identical to the Lean exporter via a 6,029-record training round-trip gate.
- Restore `nl_paraphrase` + `nl_paraphrase_method` on all 777 records, validator-gated.
- Regenerate `data/bmlogic-bench-splits.json` with correct slice classification for the
  formerly-null records.
- Record the KEEP decision for `max_modal_depth`/`max_temporal_depth` and document it in
  `data/dataset-card.md` and `data/README.md`.
- Sync all metadata: `bmlogic-bench_metadata.json` fields list, `croissant.json` Benchmark
  Record Schema v1.2 -> v1.3 (+5 fields), `dataset-card.md`, `hf-dataset/README.md`,
  `hf-dataset/validate.py` — final gate green.

**Non-Goals**:
- Rerunning `scripts/finalize_benchmark.py` or otherwise re-sampling the benchmark (forbidden).
- Removing `max_modal_depth`/`max_temporal_depth` from training data (decision: keep).
- Adding training-only fields beyond the three named (folded variants, augmentation, etc.).
- "Fixing" `hf-dataset/validate.py` EXPECTED_COUNTS for c5/c6/c7 — those describe published HF
  configs, not local files; out of scope (research report explicitly warns against this
  drive-by).
- Re-uploading to HuggingFace (local artifacts only; HF data dir is symlinked).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Accidental rerun of finalize_benchmark.py destroys contamination flags | H | L | Invariant stated in plan header + every phase; verification steps assert `contamination_flag` counts (553/224) unchanged after each benchmark rewrite |
| Python/Lean derivation drift (sexpr/tokens/features) | H | M | Phase 2 fidelity gate: byte-equality round-trip over all 6,029 `bmlogic.jsonl` records BEFORE touching benchmark; abort on any mismatch |
| Complexity semantics drift (task 285 derived-op special cases) | M | L | Assert `computed_complexity == metrics.complexity` per record as tripwire; fail loudly on mismatch (research verified 0 mismatches on all 15 target formulas) |
| In-place JSONL corruption | H | L | Write-to-temp + atomic rename (pattern from `add_contamination_flag.py`); keep a `.bak` copy before each phase's rewrite (files are not git-tracked — verified) |
| Paraphrase validator failures on anchor_invalid shapes | M | M | Exit-code gate + `--sample` spot-check; fix generator branches, never whitelist records |
| Splits regeneration before pattern_key fill (wrong order) | M | L | Phase 4 hard-depends on Phase 1; Phase 4 verification explicitly checks formerly-null records landed in correct slices |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are fully sequential. Note: Phase 4 logically requires only Phase 1 (splits read
`pattern_key`), but it reads `data/bmlogic-bench.jsonl`, which Phases 2-3 rewrite in place —
serialization avoids read/rewrite races and keeps the recorded split metadata consistent with
the final record schema. Do not parallelize.

### Phase 1: pattern_key fill + metrics repair (sub-item 5) [COMPLETED]

**Goal**: All 777 benchmark records have non-null `pattern_key`, and the 15 anchor_invalid
records' `metrics` structural sub-fields are repaired, with the derivation calibrated against
the 762 trustworthy records first.

**Tasks**:
- [x] Create `data/scripts/enrich_benchmark.py` mirroring `add_contamination_flag.py`'s
      in-place atomic-rewrite pattern (temp file + rename), with a `--fill-pattern-key` mode
      (structure the script so Phase 2 adds a second mode) *(completed)*
- [x] Implement AST-walk derivation from `formula_ast`: modalDepth (box nesting),
      temporalDepth (untl/snce nesting), impCount (imp node count), complexity (total node
      count), topOperator (root tag via the 6-case primitive mapping from
      `SuccessPatterns.lean:76-83`) *(completed: note — an initial Lean-faithful complexity port
      with task 274/285 derived-op cases failed calibration 216/762; plain node count is the
      benchmark's actual generation-time convention and passes 762/762 + 777/777)*
- [x] Calibration gate: run derivation over the 762 non-null records and assert exact match
      with stored `pattern_key` (and `metrics` structural fields) before writing anything;
      abort on any mismatch *(completed: 762/762 exact)*
- [x] Tripwire: for every record, assert `computed_complexity == metrics.complexity`
      *(completed: 777/777)*
- [x] Back up `data/bmlogic-bench.jsonl` to `.bak`, then fill `pattern_key` for the 15 null
      records AND repair their `metrics.modalDepth/temporalDepth/impCount` (research
      recommendation adopted: repair, do not leave stale) *(completed: backup at
      bmlogic-bench.jsonl.phase1.bak; 15 records filled + repaired)*
- [x] Post-write assertions: 0 null `pattern_key`; record count still 777;
      `contamination_flag` counts still 553 true / 224 false; ids unchanged *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `data/scripts/enrich_benchmark.py` - new script (mode 1: pattern_key fill + metrics repair)
- `data/bmlogic-bench.jsonl` - in-place enrichment (15 records)

**Verification**:
- Calibration assertion passes on all 762 non-null records (0 mismatches)
- `python -c` scan: 0 records with null `pattern_key`; 777 lines; contamination counts 553/224
- Spot-check: record 00134 (`□p`) now has `pattern_key.modalDepth == 1` and
  `metrics.modalDepth == 1`; 00049 (`(q → p)`) has `impCount == 1`

---

### Phase 2: schema enrichment — sexpr/tokens/features (sub-item 3) [COMPLETED]

**Goal**: All 777 records gain `formula_sexpr`, `formula_tokens`, `pattern_features`, with the
Python derivation proven byte-identical to the Lean exporter on all 6,029 training records
before the benchmark is touched.

**Tasks**:
- [x] Add `--add-schema-fields` mode to `data/scripts/enrich_benchmark.py` deriving all three
      fields from `formula_ast` + `pattern_key`: *(completed)*
      - `formula_sexpr`: prefix s-expression over primitive tags, atoms quoted —
        e.g. `(box (untl (atom "p") (imp bot bot)))`
      - `formula_tokens`: pre-order token list, vocabulary `ATOM, BOT, BOX, IMP, SNCE, UNTL`
        + atom names; atom emits two tokens `["ATOM", "p"]`
      - `pattern_features`: `[modalDepth, temporalDepth, impCount, complexity,
        topOperator.toNat]` with the 8-value toNat mapping (Atom=0 ... Since=7) from
        `DataExport.lean:229-246`
- [x] **Fidelity gate (blocking)**: run the derivation over all 6,029 `data/bmlogic.jsonl`
      records' `formula_ast` and assert byte-equality with their stored
      `formula_sexpr`/`formula_tokens`/`pattern_features`; do NOT write to the benchmark until
      this passes with 0 mismatches *(completed: 6,029/6,029 byte-equal)*
- [x] Back up to `.bak`, apply to all 777 benchmark records via atomic rewrite *(completed:
      bmlogic-bench.jsonl.phase2.bak)*
- [x] Post-write assertions: all 777 records have the 3 new non-null fields; count/ids/
      contamination counts unchanged *(completed: 777/777, 553/224)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `data/scripts/enrich_benchmark.py` - add schema-enrichment mode
- `data/bmlogic-bench.jsonl` - in-place enrichment (777 records, +3 fields)

**Verification**:
- Fidelity gate: 6,029/6,029 byte-equal round-trips (hard abort otherwise)
- Scan: 777/777 records have non-null `formula_sexpr`, `formula_tokens`, `pattern_features`
- Spot-check atom quoting: a record with formula `p` yields sexpr `(atom "p")` and tokens
  `["ATOM","p"]`

---

### Phase 3: paraphrase restoration (sub-item 2) [COMPLETED]

**Goal**: All 777 records have non-null `nl_paraphrase` and `nl_paraphrase_method`, passing the
validator and unit tests.

**Tasks**:
- [x] Back up `data/bmlogic-bench.jsonl` to `.bak` *(completed: bmlogic-bench.jsonl.phase3.bak)*
- [x] Run `python data/scripts/generate_paraphrases.py` (in-place default; rule-based AST
      walker, no LLM/API dependency) *(completed: 702 rule_based / 75 rule_based_complex)*
- [x] Run `python data/scripts/validate_paraphrases.py` — must exit 0 (8 checks: non-null, no
      formal symbols, capitalization, punctuation, length, placeholders, grammar, spot-check)
      *(completed: exit 0, 777/777 passed, grammar 100%)*
- [x] Run `python data/scripts/test_paraphrases.py` unit tests — must pass *(completed: 46/46
      OK after updating two stale integration expectations — record count 727 -> 777 and method
      distribution 635/92 -> 702/75, both artifacts of the pre-finalize benchmark; generator
      untouched)*
- [ ] If validation fails on anchor_invalid shapes (e.g. `S(p, (⊥ → ⊥))`, `U(p, (⊥ → ⊥))`):
      fix the generator's operator branches, never whitelist records or hand-edit output
      *(deviation: skipped — validation did not fail; anchor_invalid shapes produced clean
      rule_based paraphrases, no generator fix needed)*
- [x] Post-write assertions: 777/777 non-null `nl_paraphrase` + `nl_paraphrase_method`
      (values `rule_based` or `rule_based_complex`); count/ids/contamination counts unchanged
      *(completed: 777/777, 553/224)*

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `data/bmlogic-bench.jsonl` - in-place enrichment (777 records, +2 fields)
- `data/scripts/generate_paraphrases.py` - only if validator surfaces a generator-branch bug

**Verification**:
- `validate_paraphrases.py` exits 0; `test_paraphrases.py` passes
- Scan confirms 777/777 non-null paraphrase fields and unchanged invariants

---

### Phase 4: splits regeneration (sub-item 1) [COMPLETED]

**Goal**: `data/bmlogic-bench-splits.json` regenerated with correct classification for the 15
formerly-null records and a verified exact partition of all 777 IDs.

**Tasks**:
- [x] Fix hardcoded `"generation_date": "2026-05-29"` at `data/scripts/generate_splits.py:137`
      to use `date.today().isoformat()` *(completed)*
- [x] Run `python data/scripts/generate_splits.py` (defaults: `--bench data/bmlogic-bench.jsonl
      --out data/bmlogic-bench-splits.json`); script self-asserts exact partition at :112
      *(completed: 73/149/378/177 = 777)*
- [x] Explicit slice checks for formerly-null records: 00134/00593/00774 (`□p`, `□⊥`, `□q`) in
      modal-only; 00286/00737 (`S(p,⊤)`, `U(p,⊤)`-shaped) in temporal-only; 00196/00339 (mixed
      `□`+`→`) NOT in propositional-only; 00168/00179/00049/00423/00268/00368/00660/00688
      remain propositional-only *(completed: all placements verified)*
- [x] Verify slice sizes sum to 777 and every ID appears in exactly one slice *(completed:
      0 missing / 0 extra / 0 multi-assigned)*

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `data/scripts/generate_splits.py` - generation_date fix
- `data/bmlogic-bench-splits.json` - regenerated

**Verification**:
- Script's built-in partition assertion passes; independent scan confirms 0 missing / 0 extra /
  0 multi-assigned across 777 IDs
- The 7 modal/temporal formerly-null records are out of propositional-only; propositional-only
  shrinks accordingly (~80 -> ~73)

---

### Phase 5: max_* decision + metadata sync (sub-item 4 + downstream) [COMPLETED]

**Goal**: The KEEP decision for `max_modal_depth`/`max_temporal_depth` is documented, and every
downstream metadata artifact reflects the final 20-field benchmark schema, with the HF
validator as the final green gate.

**Tasks**:
- [x] Record decision (adopted from research + orchestrator directive): KEEP
      `max_modal_depth`/`max_temporal_depth` in training data; add one documenting sentence to
      `data/dataset-card.md` and `data/README.md` describing them as intentional
      denormalization for flat filtering (e.g. `df[df.max_modal_depth > 0]`); no training-file
      rewrites, no validator changes for training configs *(completed)*
- [x] Update `data/bmlogic-bench_metadata.json` `fields` list with the 5 new fields
      (`nl_paraphrase`, `nl_paraphrase_method`, `formula_sexpr`, `formula_tokens`,
      `pattern_features`) *(deviation: altered — already present on disk from prior interrupted
      agent's uncommitted work; verified 20-field list, not re-done)*
- [x] Update `data/croissant.json`: Benchmark Record Schema v1.2 -> v1.3, adding the same 5
      fields (task 229's summary explicitly assigned this re-add to task 230) *(deviation:
      altered — already present on disk; verified v1.3 heading + 20 cr:Field entries)*
- [x] Update `data/dataset-card.md` benchmark schema table (15 -> 20 fields) *(deviation:
      altered — already present on disk; verified all 5 v1.3 rows)*
- [x] Update `data/hf-dataset/README.md` benchmark field table *(completed: heading 15/v1.2 ->
      20/v1.3, +5 rows, example record replaced with real record 00001 incl. new fields; also
      fixed stale training pattern_features description and lead sentence)*
- [x] Update `data/hf-dataset/validate.py` REQUIRED_FIELDS/OPTIONAL_FIELDS for bmlogic-bench
      (re-adding `nl_paraphrase`/`nl_paraphrase_method` per the "task 230 will add them" note
      and adding the 3 schema fields); do NOT touch c5/c6/c7 EXPECTED_COUNTS *(completed: 5
      fields added to REQUIRED_FIELDS["bmlogic-bench"]; EXPECTED_COUNTS untouched)*
- [x] Final gate: `python data/hf-dataset/validate.py --config bmlogic-bench` exits 0 (HF data
      dir is symlinked — no copy step) *(completed: exit 0 — 777 records, 16 required fields
      non-null, labels valid; HF Hub upload intentionally deferred awaiting user approval)*
- [x] Clean up `.bak` files from Phases 1-3 after the final gate passes *(completed)*

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `data/bmlogic-bench_metadata.json` - fields list
- `data/croissant.json` - Benchmark Record Schema v1.3
- `data/dataset-card.md` - schema table + max_* documentation sentence
- `data/README.md` - max_* documentation sentence
- `data/hf-dataset/README.md` - field table
- `data/hf-dataset/validate.py` - benchmark REQUIRED_FIELDS/OPTIONAL_FIELDS

**Verification**:
- `python data/hf-dataset/validate.py --config bmlogic-bench` exits 0
- grep confirms all 5 new fields present in croissant.json benchmark schema and metadata fields
  list; croissant version string reads v1.3
- c5/c6/c7 EXPECTED_COUNTS untouched (git diff review)

## Testing & Validation

- [x] Phase 1 calibration: derivation matches all 762 non-null `pattern_key` records exactly
- [x] Phase 2 fidelity gate: 6,029/6,029 byte-equal round-trips on training data
- [x] Phase 3: `validate_paraphrases.py` exit 0; `test_paraphrases.py` pass
- [x] Phase 4: exact-partition assertion + formerly-null slice placement checks
- [x] Phase 5: `python data/hf-dataset/validate.py --config bmlogic-bench` exit 0
- [x] Invariant after every benchmark rewrite: 777 records, unchanged ids, unchanged
      `contamination_flag` distribution (553 true / 224 false) *(re-verified at phase 5 resume:
      777 records, ids identical to phase1.bak, 553/224, 0 null pattern_key, 20 fields)*
- [x] `scripts/finalize_benchmark.py` never executed (check shell history / summary honesty)

## Artifacts & Outputs

- `data/scripts/enrich_benchmark.py` (new, two modes)
- `data/bmlogic-bench.jsonl` (enriched in place: 15 -> 20 non-null-schema fields, 0 null
  pattern_key)
- `data/bmlogic-bench-splits.json` (regenerated)
- `data/scripts/generate_splits.py` (generation_date fix)
- `data/bmlogic-bench_metadata.json`, `data/croissant.json` (v1.3), `data/dataset-card.md`,
  `data/README.md`, `data/hf-dataset/README.md`, `data/hf-dataset/validate.py` (metadata sync)
- `specs/230_benchmark_refresh_splits_paraphrases_schema/summaries/01_benchmark-refresh-summary.md`
  (implementation summary, written at completion)

## Rollback/Contingency

- Data files under `data/` are not git-tracked (verified in research): each phase that rewrites
  `data/bmlogic-bench.jsonl` first copies it to `.bak`; restore by `mv` on failure. Do not
  delete `.bak` files until the Phase 5 final gate passes.
- Script and metadata files ARE git-tracked: revert via git checkout of the specific paths.
- If the Phase 2 fidelity gate cannot reach 6,029/6,029, STOP — do not write approximate
  derivations to the benchmark; record the mismatch classes in the summary and mark the phase
  [BLOCKED] for follow-up against the Lean exporter source.
- Under no rollback scenario is rerunning `scripts/finalize_benchmark.py` an acceptable
  recovery path.
