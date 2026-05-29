# Teammate B Findings: Alternative Approaches and Best Practices

**Task**: 214 — Dataset cleanup, standardization, and documentation
**Angle**: Alternative patterns, standards, and best practices (2026 state of the art)
**Date**: 2026-05-29

---

## Key Findings

### 1. Metadata Standards Landscape (2026)

Three major standards compete for ML dataset metadata:

| Standard | Format | Adoption | Fit for BMLogic |
|----------|--------|----------|-----------------|
| **HuggingFace Dataset Card** | YAML frontmatter + Markdown | Dominant for HF-hosted datasets | High — simple, human-readable |
| **Croissant 1.1** (MLCommons, Feb 2026) | JSON-LD (schema.org extension) | Growing — supported by HF, TensorFlow, Google Dataset Search | Medium — powerful but heavy for 4 files |
| **Datasheets for Datasets** (Gebru) | Free-form documentation | Academic standard | Low priority — overkill for auto-generated data |

**Croissant 1.1** is the newest standard (released February 2026) and adds machine-actionable provenance for data lineage, vocabulary interoperability, structured usage policies, and enhanced multi-dimensional data modeling. It builds on schema.org and is natively supported by HuggingFace, Google Dataset Search, and TensorFlow Datasets.

**HuggingFace Dataset Cards** remain the most practical standard. Their YAML frontmatter specifies `license`, `language`, `task_categories`, `pretty_name`, `tags`, `dataset_info` (with features, splits, sizes), and `configs`. The README body follows a structured template: Dataset Description → Dataset Structure → Dataset Creation → Considerations → Additional Information.

**Recommendation**: Adopt HuggingFace dataset card format for `data/README.md` (compatible with future HF hosting) with lightweight Croissant metadata as a stretch goal.

### 2. Comparable Formal Logic Datasets

Several formal logic/theorem proving datasets provide reference models:

- **Lean Workbook** (57K problems, HuggingFace-hosted): Uses Parquet format, HF dataset card with YAML metadata, per-entry fields for natural language statement, formal statement, formal proof.
- **FIMO** (formal IMO problems): JSONL with problem statements and Lean proofs.
- **HolStep** (higher-order logic): CSV-based with separate train/test splits and dedicated documentation.
- **Spark-Prover-X1**: Diverse training data with explicit provenance tracking.

**Common patterns across formal logic datasets**:
- Explicit train/test/benchmark split designators (in filename or field)
- Provenance fields linking generated data back to the proof system version
- Difficulty/complexity stratification metadata
- Machine-readable field schemas

BMLogic's benchmark dataset already follows these patterns well (difficulty tiers, source tracking, proof traces). The training datasets lag behind.

### 3. Data Storage: Git vs Git LFS vs DVC

Current state: All `.jsonl` and `_metadata.json` files are git-ignored via `data/.gitignore`. Total final dataset size is ~70MB.

| Approach | Pros | Cons | Verdict |
|----------|------|------|---------|
| **Direct Git tracking** | Simple, no extra tooling | 50MB deep file bloats repo history | Only for files <10MB |
| **Git LFS** | Transparent, integrates with git | No subset downloads, degrades with many large files | Good for 50MB file |
| **DVC** | Subset downloads, ML-native, remote storage | Extra dependency, config complexity | Overkill for 4 files |
| **Hybrid: Git + LFS** | Small files in git, large in LFS | Slight complexity | **Best fit** |

**Recommendation**: Track the 4 final datasets and their metadata in the repo. Use Git LFS for `bmlogic-deep.jsonl` (50MB) and `proof_steps.jsonl` (15MB). Track `bmlogic-bench.jsonl` (672KB), `bmlogic-medium.jsonl` (4.2MB), and all `_metadata.json` files directly in git. DVC is overkill for this scale.

### 4. Metadata Schema Inconsistency

Current metadata schemas are inconsistent:

**bmlogic-bench_metadata.json** (rich — 12 fields):
```
benchmark_name, version, description, generation_date, schema_version,
frame_class, total_count, valid_count, invalid_count, valid_ratio,
tier_distribution, category_distribution, source_distribution,
anchor_coverage, near_miss, quality
```

**bmlogic-deep/medium_metadata.json** (minimal — 9 fields):
```
total_records, valid_count, invalid_count, timeout_count,
avg_complexity, include_duals, max_complexity, sampling_mode, frame_class
```

**proof_steps** (no metadata file at all)

**Target unified schema** should include:
- **Identity**: `dataset_name`, `version`, `description`, `schema_version`
- **Generation**: `generation_date`, `generator_version`, `lean_version`, `mathlib_version`, `frame_class`
- **Statistics**: `total_records`, `valid_count`, `invalid_count`, `timeout_count` (where applicable)
- **Parameters**: `sampling_mode`, `max_complexity`, `include_duals` (where applicable)
- **Quality**: `zero_label_mismatches`, `zero_duplicates`, `verification_status`
- **Schema**: `fields` array with name, type, description for each field

### 5. JSONL Field Schema Differences

The four datasets have three distinct field schemas:

**Benchmark** (13 fields): adds `benchmark_category`, `difficulty_tier`, `source` — benchmark-specific stratification fields.

**Training (deep/medium)** (11 fields): adds `augmentation` — training-specific field. Missing benchmark stratification.

**Proof steps** (8 fields): completely different schema — `theorem_name`, `step_index`, `context`, `goal`, `rule`, `axiom_name`, `subgoals`, `frame_class`. This is a fundamentally different data type (proof step traces vs. formula classification).

**Key insight**: Don't force a single schema. The benchmark and training datasets share a common core (formula-classification records) with role-specific extensions. Proof steps are a separate data type entirely. Document each schema independently with a shared glossary for common fields.

### 6. Ideal Target Directory Structure

Based on best practices from comparable projects:

```
data/
├── README.md                          # HuggingFace-style dataset card
├── croissant.json                     # Optional: Croissant 1.1 metadata
├── benchmark/
│   ├── bmlogic-bench.jsonl           # 727 records
│   └── bmlogic-bench_metadata.json
├── training/
│   ├── bmlogic-deep.jsonl            # 53,979 records (Git LFS)
│   ├── bmlogic-deep_metadata.json
│   ├── bmlogic-medium.jsonl          # 5,136 records
│   └── bmlogic-medium_metadata.json
├── proof-steps/
│   ├── proof_steps.jsonl             # 2,424 records (Git LFS)
│   └── proof_steps_metadata.json     # NEW
└── schemas/
    ├── formula-record.schema.json    # JSON Schema for bench/training records
    └── proof-step.schema.json        # JSON Schema for proof step records
```

**vs. flat structure** (simpler alternative):
```
data/
├── README.md
├── bmlogic-bench.jsonl
├── bmlogic-bench_metadata.json
├── bmlogic-deep.jsonl
├── bmlogic-deep_metadata.json
├── bmlogic-medium.jsonl
├── bmlogic-medium_metadata.json
├── proof_steps.jsonl
├── proof_steps_metadata.json          # NEW
└── .gitignore                         # Updated: only ignore intermediates
```

**Recommendation**: Use the **flat structure**. With only 4 datasets, subdirectories add navigational overhead without meaningful organization benefit. The README provides the conceptual grouping. This also avoids breaking any existing scripts or paths that reference `data/bmlogic-bench.jsonl`.

### 7. Data Versioning Strategy

For a formal logic project where datasets are regenerated from the decision procedure:

- **Semantic versioning** in metadata: `version: "1.0"` (already in benchmark metadata). Bump minor version on regeneration with same parameters, major on schema changes.
- **Generation provenance**: Record `lean_version`, `mathlib_version`, `generator_commit` in metadata so datasets can be reproduced.
- **Immutable IDs**: Records already have IDs (`bmlogic-bench-00001`, `bmlogic-00001`). These should be stable across regenerations of the same formula.

---

## Recommended Approach

**Pragmatic middle path** — adopt widely-used standards without over-engineering:

1. **README.md**: HuggingFace dataset card format (YAML frontmatter + structured Markdown). Ready for future HF publishing.
2. **Metadata**: Standardize all `_metadata.json` files to a superset schema. Create `proof_steps_metadata.json`.
3. **Storage**: Remove git-ignore on final datasets. Use Git LFS for files >10MB (`bmlogic-deep.jsonl`, `proof_steps.jsonl`).
4. **Structure**: Keep flat layout. Remove intermediate and test files.
5. **Schema docs**: Document field schemas in README (not separate JSON Schema files — those are a future enhancement).
6. **Versioning**: Add `version`, `description`, `generation_date`, `schema_version` to all metadata files.

---

## Evidence/Examples

### HuggingFace YAML Frontmatter Example (adapted for BMLogic)

```yaml
---
license: mit
task_categories:
  - text-classification
tags:
  - modal-logic
  - bimodal
  - theorem-proving
  - formal-verification
pretty_name: BMLogic Datasets
dataset_info:
  - config_name: benchmark
    features:
      - name: id
        dtype: string
      - name: formula_str
        dtype: string
      - name: label
        dtype: string
      - name: difficulty_tier
        dtype: string
    splits:
      - name: benchmark
        num_examples: 727
  - config_name: training-deep
    features:
      - name: id
        dtype: string
      - name: formula_str
        dtype: string
      - name: label
        dtype: string
    splits:
      - name: train
        num_examples: 53979
---
```

### Unified Metadata Schema Example

```json
{
  "dataset_name": "bmlogic-deep",
  "version": "1.0",
  "description": "Large-scale training dataset for bimodal logic TM formula classification",
  "schema_version": "1.0",
  "generation_date": "2026-05-29T12:12:00Z",
  "generator": "lake exe dataset_generator",
  "lean_version": "4.27.0-rc1",
  "frame_class": "Base",
  "total_records": 53979,
  "valid_count": 888,
  "invalid_count": 51730,
  "timeout_count": 1361,
  "parameters": {
    "sampling_mode": "random",
    "max_complexity": 7,
    "include_duals": true
  },
  "quality": {
    "zero_label_mismatches": true,
    "zero_duplicates": true
  },
  "fields": [
    {"name": "id", "type": "string", "description": "Unique record identifier"},
    {"name": "split", "type": "string", "description": "Dataset split (train)"},
    {"name": "formula_str", "type": "string", "description": "Unicode formula string"},
    {"name": "formula_ast", "type": "object", "description": "Tagged AST representation"},
    {"name": "frame_class", "type": "string", "description": "Frame class (Base)"},
    {"name": "label", "type": "string", "description": "Validity label (valid/invalid)"},
    {"name": "proof_trace", "type": "object|null", "description": "Proof tree for valid formulas"},
    {"name": "countermodel", "type": "object|null", "description": "Countermodel for invalid formulas"},
    {"name": "pattern_key", "type": "object", "description": "Structural complexity metrics"},
    {"name": "metrics", "type": "object", "description": "Performance and difficulty metrics"},
    {"name": "augmentation", "type": "object|null", "description": "Augmentation info if applicable"}
  ]
}
```

---

## Confidence Level

**High** — These recommendations are grounded in widely-adopted standards (HuggingFace, Croissant, Gebru Datasheets) and directly applicable patterns from comparable formal logic datasets. The storage recommendations are straightforward given the modest dataset sizes. The main uncertainty is whether the project plans to publish on HuggingFace (which would make the dataset card format even more valuable) vs. keeping datasets purely local.
