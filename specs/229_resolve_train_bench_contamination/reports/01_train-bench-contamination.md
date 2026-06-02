# Research Report: Task #229

**Task**: 229 - Resolve train/benchmark formula contamination
**Started**: 2026-06-02T00:00:00Z
**Completed**: 2026-06-02T01:00:00Z
**Effort**: 2 hours
**Dependencies**: None
**Sources/Inputs**:
- `data/bmlogic-c7.jsonl` — 49,904-record training set
- `data/bmlogic-bench.jsonl` — 777-record benchmark
- `data/bmlogic-bench_metadata.json` — Benchmark metadata
- `data/bmlogic-bench-splits.json` — Cross-logic splits
- `data/axiom-instances.jsonl` — 110-record axiom instances
- `data/croissant.json` — Croissant ML dataset card
- `data/dataset-card.md` — HuggingFace dataset card
- `data/scripts/generate_paraphrases.py` — NL paraphrase generator
- `specs/261_dataset_quality_and_stall_diagnosis/reports/01_dataset-quality-stall.md` — Prior dataset quality research
- Direct Python analysis of dataset overlap
**Artifacts**:
- `specs/229_resolve_train_bench_contamination/reports/01_train-bench-contamination.md`
**Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

---

## Executive Summary

- The 71.2% contamination claim is **exactly confirmed**: 553 of 777 benchmark formulas appear verbatim in `bmlogic-c7.jsonl`, leaving 224 (28.8%) as genuinely held-out.
- Contamination is **structural, not accidental**: c7 is an exhaustive enumeration of all bimodal formulas up to complexity 7, so any benchmark formula sampled from that range is necessarily in training.
- The 224 non-overlapping records are skewed: dominated by `very_hard` tier (126/224 = 56%) and `sampled-invalid` category (123/224 = 55%), making them a poor standalone benchmark.
- **Option B (contamination_flag)** is recommended as the lowest-risk immediate fix, preserving all existing IDs, splits, and downstream artifacts while transparently flagging contaminated records.
- A complementary **Option D (regenerate with complexity >= 8 exclusion)** is viable medium-term and would produce a genuinely held-out benchmark of sufficient size.
- Task 230 (artifact regeneration) depends on this task and will need to update splits, paraphrases, and schema fields regardless of which option is chosen.

---

## Context & Scope

### Problem Statement

The `bmlogic-bench.jsonl` benchmark was designed as a held-out evaluation set for models trained on `bmlogic-c7.jsonl`. However, because c7 is an **exhaustive enumeration** of all bimodal formulas up to complexity 7, any benchmark formula sampled from that complexity range is by construction in the training set.

### Data Summary

| Dataset | Records | Complexity Range | Notes |
|---------|---------|-----------------|-------|
| `bmlogic-c7.jsonl` | 49,904 | 3–7 | Exhaustive enumeration, the training set |
| `bmlogic-bench.jsonl` | 777 | 1–65 | Benchmark — 71.2% contaminated |
| `axiom-instances.jsonl` | 110 | 3–63 | Axiom schema instances, 99/110 not in training |
| `bmlogic-c5.jsonl` | 1,513 | 3–5 | Small training set, subset of c7 |

---

## Findings

### 1. Contamination Verification

Python analysis confirms the reported numbers precisely:

```
Training set (c7): 49,904 unique formula strings
Benchmark total:      777 records (all unique)
Overlapping:          553 (71.2%)
Non-overlapping:      224 (28.8%)
```

Contamination rate is **uniform across all cross-logic splits**:

| Split | Total | Contaminated | Held-Out |
|-------|-------|--------------|---------|
| propositional-only | 97 | 72 (74.2%) | 25 (25.8%) |
| modal-only | 144 | 101 (70.1%) | 43 (29.9%) |
| temporal-only | 247 | 176 (71.3%) | 71 (28.7%) |
| bimodal | 239 | 162 (67.8%) | 77 (32.2%) |

### 2. Root Cause

The contamination is **not a curation error**. It is an architectural consequence of the training data design:

- `bmlogic-c7.jsonl` is described as "exhaustive bimodal logic training dataset at complexity 7" — it enumerates **every** formula in the language up to complexity 7 (using a canonical atom ordering starting at complexity 3).
- The benchmark pipeline sampled from this same complexity range (complexity 3–7 for 553 records), making overlap inevitable.
- The benchmark also sampled from complexity >= 8 (axiom instances, some high-complexity productions) — these 224 records are genuinely held-out.

**Complexity distribution of contaminated vs. held-out records:**

| Complexity | Contaminated | Held-Out |
|-----------|-------------|---------|
| 1–2 | 0 | 6 |
| 3 | 40 | 5 |
| 4 | 15 | 0 |
| 5 | 70 | 17 |
| 6 | 218 | 0 |
| 7 | 210 | 18 |
| 8+ | 0 | 178 |

**Key observation**: All complexity 6 bench records are contaminated (c7 is exhaustive at complexity 6, and bench draws from that range). Complexity 8+ records are never in c7.

### 3. Contamination by Benchmark Source

| Source | Contaminated | Not Contaminated |
|--------|-------------|-----------------|
| `production` | 548 (78.1%) | 154 (21.9%) |
| `axiom_instance` | 1 (1.7%) | 59 (98.3%) |
| `anchor_invalid` | 4 (26.7%) | 11 (73.3%) |

Axiom instances are almost entirely held-out (59/60 = 98.3%). They are the most reliable source for a clean benchmark.

### 4. Quality of the 224 Non-Overlapping Records

The 224 genuinely held-out records are **not a well-balanced benchmark** on their own:

**Difficulty tier distribution (224 held-out):**

| Tier | Count | % |
|------|-------|---|
| easy | 11 | 4.9% |
| medium | 17 | 7.6% |
| hard | 70 | 31.2% |
| very_hard | 126 | 56.3% |

The original full benchmark was designed for: easy (6.6%), medium (41.2%), hard (36.0%), very_hard (16.2%). The held-out subset is heavily skewed toward very_hard, lacking medium-difficulty coverage.

**Label balance:** 90 valid / 134 invalid (0.40 valid ratio vs. designed 0.47).

**Per-split held-out record counts are too small for reliable evaluation:**
- propositional-only: 25 records
- modal-only: 43 records
- temporal-only: 71 records
- bimodal: 77 records

### 5. Downstream Artifact Inventory

All of the following need updating regardless of which option is chosen (some are already stale):

| Artifact | Current State | Required Update |
|----------|---------------|-----------------|
| `data/bmlogic-bench.jsonl` | 777 records, no NL paraphrases | Add field(s) per chosen option |
| `data/bmlogic-bench_metadata.json` | Accurate | Update after field changes |
| `data/bmlogic-bench-splits.json` | Stale: `total_records=727`, bench has 777 | Regenerate with `generate_splits.py` |
| `data/croissant.json` | No contamination field documented | Update field schema |
| `data/dataset-card.md` | No contamination section | Add contamination analysis section |
| `data/hf-dataset/data/bmlogic-bench.jsonl` | HF copy, stale | Sync after bench update |
| `data/hf-dataset/README.md` | No contamination docs | Update |
| NL paraphrases | Not yet generated | Run `generate_paraphrases.py` (tracked in task 230) |

**Notable pre-existing issue**: `bmlogic-bench-splits.json` already has `total_records=727` but the benchmark has 777 records — this stale count exists independently of the contamination issue.

### 6. Quantitative Impact of Each Option

**Option A — Trim benchmark to 224 non-overlapping records:**
- Benchmark shrinks from 777 to 224 records (71% reduction)
- Remaining records are heavily skewed: 56% very_hard, only 5% easy
- Per-split sizes drop to 25–77 records — insufficient for robust evaluation
- Valid ratio drops from 0.47 to 0.40
- Pro: Zero overlap guarantee, no new data generation required
- Con: Destroys benchmark utility; would need to re-run `generate_splits.py`, `generate_paraphrases.py`, and update all metadata/croissant

**Option B — Add `contamination_flag` field:**
- No records deleted; all existing IDs, splits, and downstream artifact structure preserved
- All 777 records remain; users can filter to 224 truly held-out records
- Low implementation risk: single-pass script to add boolean field
- Metadata, croissant.json field list, and dataset card need documentation updates
- Con: The benchmark's primary use remains compromised unless users filter; headline numbers are misleading without filtering
- Effort: ~1 hour Python + documentation

**Option C — Remove 553 overlapping formulas from c7 training:**
- c7 shrinks from 49,904 to 49,351 records (only 1.1% reduction)
- **Breaks c7's exhaustive property**: c7 is described as "all bimodal formulas up to complexity 7" — removing 553 formulas violates this contract
- Would create unannounced holes in the training set
- Would invalidate the c7 metadata description
- Benefit is minimal (1.1% of training removed)
- Not recommended without also documenting the modified exhaustive set clearly

**Option D — Regenerate benchmark from complexity >= 8 sources (not in original task):**
- Would produce a properly held-out benchmark
- Available held-out sources: 99 axiom instances not in c7, plus production formulas at complexity 8–65 (154 available, all held-out)
- Total available held-out: ~253 records — close to the 224 already available, but with better tier balance possible
- Requires re-running the benchmark generation pipeline with a c7 exclusion filter
- Pro: Scientifically clean; produces a larger benchmark than Option A with better distribution
- Con: Requires pipeline work; would regenerate from scratch losing historical record IDs

---

## Decisions

**Recommended resolution: Option B + Document (immediate) + Option D (medium-term)**

1. **Immediate (Option B)**: Add `contamination_flag: bool` field to all 777 benchmark records. Update metadata, croissant.json, and dataset-card.md to document the contamination analysis. This is backward-compatible (no ID changes), takes ~1 hour to implement, and preserves all existing downstream structure.

2. **Medium-term (Option D)**: Regenerate the benchmark with complexity >= 8 as the lower bound, using the existing pipeline with a c7 formula exclusion filter. This would produce a ~250-400 record genuinely held-out benchmark with proper tier balance.

**Why not Option A**: The 224 remaining records are too skewed (56% very_hard) to be useful as a standalone benchmark, and sub-split sizes (25–77) are too small for meaningful evaluation.

**Why not Option C**: Removing formulas from an exhaustive training set violates the exhaustiveness property and provides negligible benefit (1.1% reduction).

---

## Recommendations

1. **Implement Option B immediately** (this task): Add `contamination_flag` field via a Python script, update `bmlogic-bench_metadata.json` to add a `contamination_analysis` section, update `croissant.json` to document the new field, add a "Contamination Analysis" section to `dataset-card.md`.

2. **Fix stale splits count** (this task or task 230): `bmlogic-bench-splits.json` has `total_records=727` but should be 777. This is independently broken and should be fixed by re-running `generate_splits.py`.

3. **Document clearly in dataset card**: Report the contamination analysis, give the 224 genuinely held-out count, and add a usage note that evaluation on contaminated models should filter to `contamination_flag=False` records.

4. **Plan Option D for task 230 or a new task**: Regenerating with complexity >= 8 exclusion would produce a larger, properly balanced held-out benchmark. This should be planned as a follow-up after completing the immediate flag-based fix.

5. **Do not modify c7 training data** (ruling out Option C): The exhaustive enumeration property of c7 is a design feature worth preserving. Adding a note in the metadata that the benchmark overlaps with c7 at complexity <= 7 is preferable to creating holes.

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|-----------|
| Option B still misleads without filtering | Medium | Clearly document in dataset card; add usage example showing how to filter |
| Option D requires pipeline re-run (may hit c9 stall bug) | Medium | Only run at complexity 8–10 range where stall bug was at complexity 6; limited scope |
| Stale splits file independently broken | Low | Fix concurrently in this task or task 230 |
| HF dataset copy diverges | Low | Sync `hf-dataset/data/bmlogic-bench.jsonl` as part of implementation |
| Task 230 NL paraphrase generation needs correct record count | Low | Paraphrase script targets `data/bmlogic-bench.jsonl` directly; will work after flag addition |

---

## Context Extension Recommendations

- **Topic**: Dataset contamination best practices in ML benchmarks
- **Gap**: No existing context covers contamination flag patterns or benchmark holdout strategies
- **Recommendation**: After resolution, add a brief note to `data/dataset-card.md` covering the contamination analysis methodology. This will serve as in-repo documentation for future dataset maintainers.

---

## Appendix

### Verification Script (Python)

```python
import json

train = set()
with open('data/bmlogic-c7.jsonl') as f:
    for line in f:
        train.add(json.loads(line)['formula_str'])

bench = [json.loads(line) for line in open('data/bmlogic-bench.jsonl')]
overlap = sum(1 for r in bench if r['formula_str'] in train)
print(f"{overlap}/{len(bench)} = {100*overlap/len(bench):.1f}% contaminated")
# Output: 553/777 = 71.2% contaminated
```

### Key Field in Option B Implementation

```json
{
  "id": "bmlogic-bench-00001",
  "split": "benchmark",
  "formula_str": "(q → (⊥ → q))",
  "contamination_flag": true,
  ...
}
```

### Downstream Update Checklist (for implementation)

- [ ] Add `contamination_flag` boolean to all 777 bench records
- [ ] Update `bmlogic-bench_metadata.json`: add `contamination_analysis` section
- [ ] Update `croissant.json`: add `contamination_flag` field to benchmark-schema-v1 record set
- [ ] Update `data/dataset-card.md`: add contamination analysis section
- [ ] Fix `bmlogic-bench-splits.json` stale `total_records` (727 -> 777)
- [ ] Sync `hf-dataset/data/bmlogic-bench.jsonl` with updated bench
- [ ] Update `hf-dataset/README.md` with contamination documentation

### References

- c7 metadata: `data/bmlogic-c7_metadata.json` (sampling_mode: "exhaustive", max_complexity: 7)
- Benchmark metadata: `data/bmlogic-bench_metadata.json`
- Splits file: `data/bmlogic-bench-splits.json`
- Task 230: Dependent task for full artifact regeneration (NL paraphrases, schema alignment)
