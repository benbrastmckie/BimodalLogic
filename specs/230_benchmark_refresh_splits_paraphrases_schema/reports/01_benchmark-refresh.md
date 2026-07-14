# Research Report: Task #230

**Task**: 230 - benchmark_refresh_splits_paraphrases_schema
**Started**: 2026-07-14
**Completed**: 2026-07-14
**Effort**: 1 session
**Dependencies**: 229 (completed 2026-06-02)
**Sources/Inputs**: Codebase (data/, scripts/, Theories/Bimodal/Automation/), task 229 summary
**Artifacts**: specs/230_benchmark_refresh_splits_paraphrases_schema/reports/01_benchmark-refresh.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Sub-item 1 (splits) is already ~done but subtly wrong**: task 229 regenerated
  `data/bmlogic-bench-splits.json` with `total_records: 777` and a verified exact partition
  (777 IDs, no overlap, no gaps). However, the 15 null-`pattern_key` records were all
  misclassified into `propositional-only` — including modal formulas (`□p`, `□q`, `□⊥`,
  `(□p → q)`, `(□(p→⊥) → ⊥)`) and temporal formulas (`U(p, ⊤)`, `S(p, ⊤)`) — because
  `generate_splits.py` falls back to `metrics.modalDepth/temporalDepth`, which are zeroed for
  these records. **Splits must be regenerated AFTER sub-item 5 (pattern_key fill)**.
- **Sub-item 2 (paraphrases)**: confirmed 0/777 records have `nl_paraphrase`. The generator is
  fully **rule-based (no LLM/API needed)** — `data/scripts/generate_paraphrases.py` walks
  `formula_ast`. Runnable as-is; validate with `data/scripts/validate_paraphrases.py`
  (exit 0/1) and unit tests in `data/scripts/test_paraphrases.py`.
- **Sub-item 3 (schema alignment)**: benchmark records (15 fields) lack `formula_sexpr`,
  `formula_tokens`, `pattern_features` that all training sets have (27 fields). All three are
  mechanically derivable from `formula_ast`/`pattern_key`; exact formats and the
  `topOperator -> int` mapping are documented below from the Lean source
  (`Theories/Bimodal/Automation/DataExport.lean:229-246`). Fidelity can be proven by
  round-tripping the derivation against the 6,029 training records.
- **Sub-item 4 (redundant depth fields)**: verified `max_modal_depth == metrics.modalDepth`
  and `max_temporal_depth == metrics.temporalDepth` for all 6,029 `bmlogic.jsonl` records
  (0 mismatches). **Recommendation: KEEP + document** — removal breaks the documented
  16-field schema contract (`data/README.md:217`, task 217), two validators, and published
  HF data; keeping costs two ints/record.
- **Sub-item 5 (null pattern_key)**: all 15 are `source: anchor_invalid` records. Their
  `metrics` structural sub-fields are also stale (modalDepth/temporalDepth/impCount all 0,
  even for `□p`); only `metrics.complexity` is correct. pattern_key must be recomputed from
  `formula_ast`, not copied from metrics.

## Context & Scope

Task 229 resolved train/bench contamination by adding `contamination_flag` (553 true / 224
false) to all 777 records of `data/bmlogic-bench.jsonl` and regenerating downstream metadata.
Task 230 finishes the benchmark refresh: splits correctness, NL paraphrase restoration, schema
alignment with training data, a redundancy decision, and pattern_key completion.

### Key file inventory (verified on disk)

| Artifact | Path | State |
|---|---|---|
| Benchmark | `data/bmlogic-bench.jsonl` | 777 records, 15 fields, `contamination_flag` present, `nl_paraphrase` absent, 15 null `pattern_key` |
| Splits | `data/bmlogic-bench-splits.json` | `total_records: 777`; slices 80/144/376/177; exact partition verified this session |
| Benchmark metadata | `data/bmlogic-bench_metadata.json` | has `fields` list + `contamination_analysis` (task 229) |
| Training (primary) | `data/bmlogic.jsonl` | 6,029 records, 27 fields incl. `formula_sexpr`, `formula_tokens`, `pattern_features`, `max_modal_depth`, `max_temporal_depth` |
| Training (published configs) | `data/bmlogic-c5.jsonl` (6,028), `data/bmlogic-c6.jsonl`, `data/bmlogic-c7.jsonl` (13,749) | same 27-field schema |
| Croissant | `data/croissant.json` | Benchmark Record Schema v1.2 (15 fields); `nl_paraphrase` intentionally removed by 229 pending this task |
| Dataset card | `data/dataset-card.md` | schema tables at :130-131 list `max_*` fields |
| HF mirror | `data/hf-dataset/` | symlinked data; `validate.py` REQUIRED_FIELDS + EXPECTED_COUNTS (bench=777) |

### Pipeline scripts (verified locations)

| Script | Path | Notes |
|---|---|---|
| Split generator | `data/scripts/generate_splits.py` | defaults `--bench data/bmlogic-bench.jsonl --out data/bmlogic-bench-splits.json`; **bug**: `generation_date` hardcoded to `"2026-05-29"` at `data/scripts/generate_splits.py:137`; null-pattern_key fallback to metrics at :35-43 |
| Paraphrase generator | `data/scripts/generate_paraphrases.py` | rule-based recursive AST walker; adds `nl_paraphrase` + `nl_paraphrase_method` (`rule_based` for depth<=2, `rule_based_complex` for >=3); docstring says "727 records" (stale, harmless) |
| Paraphrase validator | `data/scripts/validate_paraphrases.py` | 8 checks (non-null, no formal symbols, capitalization, punctuation, length, placeholders, grammar, spot-check); exit 0 pass / 1 fail |
| Paraphrase unit tests | `data/scripts/test_paraphrases.py` | exists alongside generator |
| Benchmark finalizer | `scripts/finalize_benchmark.py` | reads `data/bmlogic-bench-validated.jsonl` (gitignored intermediate), stratified sampling, seed 42205; **rerunning it would resample and destroy 229's contamination work — do NOT rerun; enrich in place instead** |
| Contamination flagger | `data/scripts/add_contamination_flag.py` | task 229's script, pattern to imitate for in-place enrichment |
| Schema migration v2 | `scripts/migrate_schema_v2.py` | origin of `max_*` fields (copied from `pattern_key`, task 217) |
| Validators | `scripts/validate_datasets.py:29-32`, `scripts/validate_c5_dataset.py:34-35` | both list `max_modal_depth`/`max_temporal_depth` (and sexpr/tokens/features) as REQUIRED for training data |
| HF validator | `data/hf-dataset/validate.py:38-75` | bench REQUIRED_FIELDS has `contamination_flag`; `nl_paraphrase` removed by 229 ("task 230 will add them") |

## Findings

### 1. Splits (sub-item 1): partially resolved by 229; must be redone after pattern_key fill

Verified this session against `data/bmlogic-bench-splits.json`:
- Slice sizes: propositional-only 80, modal-only 144, temporal-only 376, bimodal 177 = 777.
- Every benchmark ID appears in exactly one slice (0 missing, 0 extra, 0 multi-assigned).
- **But**: all 15 null-`pattern_key` IDs (list below) sit in `propositional-only`, though 5+
  are modal and 2 temporal. Root cause: `classify_record` at
  `data/scripts/generate_splits.py:33-43` falls back to `metrics.modalDepth/temporalDepth`,
  which are erroneously 0 for these records.
- Additional fix: replace hardcoded `"generation_date": "2026-05-29"`
  (`generate_splits.py:137`) with `date.today().isoformat()`.

So the "regenerate splits" step is cheap (idempotent script) but only meaningful after
sub-item 5 fixes pattern_key. Post-fill expected movement: propositional-only shrinks by ~13
(records 00168 `p`, 00179 `q`, 00049 `(q → p)`, 00423 `(p → q)`, 00268 `⊥`, 00368, 00660,
00688 stay propositional; the box/untl/snce records move to modal-only / temporal-only).

### 2. NL paraphrases (sub-item 2): fields fully absent; restoration is deterministic

- 0 of 777 records have `nl_paraphrase` (verified by scan).
- Task 229 explicitly removed `nl_paraphrase`/`nl_paraphrase_method` from `croissant.json`
  and `hf-dataset/validate.py` because the data lacked them, deferring re-add to task 230
  (see `specs/archive/229_resolve_train_bench_contamination/summaries/01_contamination-resolution-summary.md`).
- `generate_paraphrases.py` is entirely rule-based (recursive AST walker with derived-operator
  detection: neg/top/and/or/iff/diamond/F/G/P/H/X/Y). No network or LLM dependency.
- Derived-operator semantics used by the generator (documented in its docstring):
  `untl{event=bot}` = Next, `untl{event=top}` = Eventually, `snce{event=bot}` = Yesterday,
  `snce{event=top}` = Past.
- Validation chain: `python data/scripts/generate_paraphrases.py` (in-place default), then
  `python data/scripts/validate_paraphrases.py` (exit code gate), plus
  `test_paraphrases.py` unit tests.
- The 15 anchor_invalid records include shapes like `S(p, (⊥ → ⊥))` and `U(p, (⊥ → ⊥))`
  (event=atom, guard=top) — these hit the "Past/Eventually of guard while event holds"
  standard branch; the validator will catch any placeholder output.

### 3. Schema alignment (sub-item 3): three fields, all mechanically derivable

Benchmark fields (15): `axiom_name, benchmark_category, contamination_flag, countermodel,
difficulty_tier, formula_ast, formula_str, frame_class, id, label, metrics, pattern_key,
proof_trace, source, split`. Missing vs training: `formula_sexpr`, `formula_tokens`,
`pattern_features` (task asks for exactly these three; training also has folded variants,
augmentation, etc. — out of scope).

Exact formats (verified against `data/bmlogic.jsonl` and Lean source
`Theories/Bimodal/Automation/DatasetExport.lean:299-304`):

- **formula_sexpr**: prefix s-expression over primitive tags; atoms quoted:
  `□U(p, (⊥ → ⊥))` -> `(box (untl (atom "p") (imp bot bot)))`.
- **formula_tokens**: pre-order token list; vocabulary observed across all 6,029 training
  records: `ATOM, BOT, BOX, IMP, SNCE, UNTL` + atom names `p, q, r`. Atom emits two tokens
  `["ATOM", "p"]`. Example above -> `["BOX","UNTL","ATOM","p","IMP","BOT","BOT"]`.
- **pattern_features**: `[modalDepth, temporalDepth, impCount, complexity, topOperator.toNat]`
  (`Theories/Bimodal/Automation/DataExport.lean:243-246`), with `GoalCategory.toNat`
  (`DataExport.lean:229-237`):
  Atom=0, Bottom=1, Implication=2, Box=3, AllPast=4, AllFuture=5, Until=6, Since=7.
  Hypothesis verified over 3,000 training records with observed categories
  (Implication->2, Box->3, Until->6, Since->7; 0 violations).
- `topOperator` classification is primitive-constructor-only
  (`goalCategory`, `Theories/Bimodal/Automation/SuccessPatterns.lean:76-83`): atom/bot/imp/box/
  untl/snce map directly; AllPast/AllFuture never occur as raw top tags, so a Python
  re-derivation needs only the 6 primitive cases.

**Implementation approach**: new `data/scripts/enrich_benchmark.py` (mirroring
`add_contamination_flag.py`'s in-place atomic-rewrite pattern) that derives all three fields
from `formula_ast` + `pattern_key`. **Do not rerun `scripts/finalize_benchmark.py`** — it
re-samples from the gitignored validated pool with a fixed seed and would clobber
contamination flags and record identity.

**Fidelity gate (strong)**: before touching the benchmark, run the same derivation over
`data/bmlogic.jsonl`'s `formula_ast` and assert byte-equality with its stored
`formula_sexpr`/`formula_tokens`/`pattern_features` for all 6,029 records. This proves the
Python re-implementation matches the Lean exporter exactly.

### 4. Redundant depth fields (sub-item 4): recommend KEEP + document

Verified: `max_modal_depth == metrics.modalDepth` and `max_temporal_depth ==
metrics.temporalDepth` for **all 6,029** `bmlogic.jsonl` records (0 mismatches; note metrics
keys are camelCase). The fields were added by `scripts/migrate_schema_v2.py` (task 217)
copying from `pattern_key`, so they are indeed a third copy
(pattern_key.modalDepth / metrics.modalDepth / max_modal_depth).

Removal cost inventory:
- `scripts/validate_datasets.py:32` and `scripts/validate_c5_dataset.py:35` list them as
  REQUIRED — both must change.
- `data/README.md:217` documents the "16-field schema including max_modal_depth" contract.
- `data/dataset-card.md:130-131` schema table rows.
- All four local training files (`bmlogic.jsonl`, c5, c6, c7 — ~40k records, ~220 MB) must be
  rewritten, and the published HF dataset would diverge from local until re-upload.
- `scripts/migrate_schema_v2.py` becomes dead code (delete or mark historical).

Keep cost: two ints per record; croissant Training Record Schema (v2.0) does not even list
them, so no schema debt there.

**Recommendation**: keep, and add one sentence to `data/dataset-card.md` and `data/README.md`
documenting them as intentional denormalization for flat filtering (e.g.
`df[df.max_modal_depth > 0]` without unpacking nested dicts). If the project prefers
minimality, the full removal checklist above is the complete blast radius — nothing else
consumes them (grep-verified across `data/`, `scripts/`, `Documentation/`).

### 5. Null pattern_key (sub-item 5): 15 anchor_invalid records; metrics also stale

All 15 are `source: anchor_invalid`, `benchmark_category: anchor-invalid`:
00049 `(q → p)`, 00134 `□p`, 00168 `p`, 00179 `q`, 00196 `(□p → q)`, 00268 `⊥`,
00286 `S(p, (⊥ → ⊥))`, 00339 `(□(p → ⊥) → ⊥)`, 00368 `((p → q) → p)`, 00423 `(p → q)`,
00593 `□⊥`, 00660 `((p → ((p → ⊥) → ⊥)) → ⊥)`, 00688 `(r → (p → q))`,
00737 `U(p, (⊥ → ⊥))`, 00774 `□q`.

Two data problems, not one:
1. `pattern_key` is null.
2. `metrics.modalDepth/temporalDepth/impCount` are all 0 for these 15 (wrong for at least 7
   of them: `□p` has modalDepth 1, `(q → p)` has impCount 1, etc.). Only
   `metrics.complexity` is correct (verified: plain AST node count matches for all 15, e.g.
   `S(p, ⊤)` -> 5, `((p→((p→⊥)→⊥))→⊥)` -> 9).

Fill strategy: recompute from `formula_ast` in Python — modalDepth/temporalDepth (nesting
depth of box / untl+snce), impCount (imp node count), complexity (total node count),
topOperator (root tag via the 6-case primitive mapping). Calibrate the recomputation against
the 762 non-null records first (this session verified pattern_key == metrics structural
fields on all 762, so pattern_key values there are trustworthy ground truth).

Caveat on complexity: Lean's `Formula.complexity` (`Theories/Bimodal/Syntax/Formula.lean:170`)
has derived-operator special cases (task 285: always/sometimes/weak_future/... count as
1 + child). None of the 15 formulas match those macro patterns, and plain node count
reproduces `metrics.complexity` exactly for all 15, so plain node count is safe here — but
the enrichment script should assert `computed_complexity == metrics.complexity` per record
and fail loudly on any future mismatch.

**Decision needed at plan time**: also repair the stale `metrics` structural sub-fields for
these 15 records (recommended — leaving them contradicts the freshly filled pattern_key and
keeps `generate_splits.py`'s metrics fallback broken), or fill pattern_key only (minimal
scope, splits still fixed since pattern_key takes precedence).

## Recommended Phased Implementation

Ordering is driven by the dependency: splits classification reads pattern_key, and croissant/
card/validator updates must reflect the final field set.

- **Phase 1 — pattern_key fill (+ metrics repair) [sub-item 5]**
  New `data/scripts/enrich_benchmark.py` (or `fill_pattern_key.py`): AST-walk derivation,
  calibrated against the 762 non-null records (assert exact match before writing), then fill
  the 15 nulls; optionally repair the 15 records' `metrics` structural fields.
  Verify: 0 null pattern_key; calibration assertion passes.

- **Phase 2 — schema enrichment [sub-item 3]**
  Same script (second mode/flag): derive `formula_sexpr`, `formula_tokens`,
  `pattern_features`. Fidelity gate: round-trip all 6,029 `bmlogic.jsonl` records to
  byte-equality before applying to the benchmark.
  Verify: all 777 records gain 3 non-null fields; spot-check `(atom "p")` quoting.

- **Phase 3 — paraphrase restoration [sub-item 2]**
  `python data/scripts/generate_paraphrases.py` (in-place), then
  `python data/scripts/validate_paraphrases.py` (must exit 0) and `test_paraphrases.py`.
  Verify: 777/777 non-null `nl_paraphrase` + `nl_paraphrase_method`.

- **Phase 4 — splits regeneration [sub-item 1]**
  Fix `generation_date` hardcode (`generate_splits.py:137`), rerun; validate exact-partition
  (script self-asserts at :112) plus an explicit check that the 15 formerly-null records now
  land in their correct slices (e.g. 00134/00593/00774 in modal-only; 00286/00737 in
  temporal-only).

- **Phase 5 — decision + metadata sync [sub-item 4 + downstream]**
  (a) Record keep/remove decision for `max_*` fields (recommendation: keep + document).
  (b) Update `data/bmlogic-bench_metadata.json` `fields` list;
  (c) `data/croissant.json` Benchmark Record Schema v1.2 -> v1.3 adding `nl_paraphrase`,
  `nl_paraphrase_method`, `formula_sexpr`, `formula_tokens`, `pattern_features` (229's
  summary explicitly assigns this to 230);
  (d) `data/dataset-card.md` benchmark schema table (15 -> 20 fields);
  (e) `data/hf-dataset/README.md` field table;
  (f) `data/hf-dataset/validate.py` REQUIRED_FIELDS/OPTIONAL_FIELDS for bmlogic-bench, then
  run `python data/hf-dataset/validate.py --config bmlogic-bench` as the final gate
  (HF data dir is symlinked, so no copy step).

## Decisions

- Do NOT rerun `scripts/finalize_benchmark.py`: it re-samples (seed 42205) from a gitignored
  intermediate and would destroy record identity and task 229's contamination flags. Enrich
  `data/bmlogic-bench.jsonl` in place, following `add_contamination_flag.py`'s pattern.
- Sub-item ordering must be 5 -> 3 -> 2 -> 1 -> metadata (splits depend on pattern_key).
- Sub-item 4 recommendation: keep `max_*` fields, document as denormalization (full removal
  checklist provided above if overridden).
- Paraphrase generation is rule-based; no external API dependency or cost.

## Risks & Mitigations

- **Python/Lean derivation drift** (sexpr/tokens/features): mitigated by the 6,029-record
  byte-equality round-trip gate before touching the benchmark.
- **Complexity semantics drift** (task 285 derived-op cases): none of the 15 formulas match
  macro patterns; assert `computed == metrics.complexity` per record as a tripwire.
- **In-place JSONL corruption**: use write-to-temp + atomic rename (pattern already used by
  `migrate_schema_v2.py` and `add_contamination_flag.py`); data files are gitignored-adjacent
  (`bmlogic-bench.jsonl` itself is NOT tracked by git — verified `git ls-files data/` is
  empty), so keep a `.bak` copy during each phase.
- **Concurrent HF publication drift**: `hf-dataset/validate.py` EXPECTED_COUNTS for c5/c6/c7
  (2283/13064/77272) do not match local line counts (6028/.../13749) — these describe the
  published HF configs, not local files; benchmark count 777 does match. Out of scope, but
  implementers should not "fix" those counts as a drive-by.
- **Paraphrase validator failures on anchor_invalid shapes**: validator exit-code gate plus
  its `--sample` spot-check will surface any `[unknown operator]` placeholders; fix generator
  branches rather than whitelisting.

## Context Extension Recommendations

- **Topic**: BMLogic dataset pipeline map (file inventory, script inventory, in-place
  enrichment pattern, "never rerun finalize_benchmark" invariant)
- **Gap**: no context file documents the data/ pipeline; tasks 227-230 each rediscovered it
- **Recommendation**: add `.context/` note or `.memory/` entry summarizing the pipeline
  inventory table from this report

## Appendix

- Verification commands run this session: record/field scans over `bmlogic-bench.jsonl` and
  `bmlogic.jsonl` (Python one-liners), splits partition check, pattern_features hypothesis
  check (3,000 records), max_* redundancy check (6,029 records, 0 mismatches),
  pattern_key==metrics calibration (762 records, 0 mismatches).
- Lean ground truth: `Theories/Bimodal/Automation/DataExport.lean:229-246` (toNat +
  featureVector), `Theories/Bimodal/Automation/DatasetExport.lean:299-304` (export fields),
  `Theories/Bimodal/Automation/SuccessPatterns.lean:59-120` (GoalCategory, PatternKey),
  `Theories/Bimodal/Syntax/Formula.lean:170` (complexity).
- Task 229 handover notes:
  `specs/archive/229_resolve_train_bench_contamination/summaries/01_contamination-resolution-summary.md`.
