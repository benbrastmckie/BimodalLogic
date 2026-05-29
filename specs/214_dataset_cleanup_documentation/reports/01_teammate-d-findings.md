# Teammate D (Horizons): Strategic Alignment Analysis

**Task**: 214 — Dataset cleanup, standardization, and documentation
**Date**: 2026-05-29
**Focus**: Long-term alignment, publication readiness, clean-break refactor target

## Key Findings

### 1. Task Scope Is Correct but Should Include a Distribution Strategy

The task as scoped (cleanup intermediates, standardize metadata, write README, fix .gitignore) is well-aligned with the project's near-publication state (95/100 readiness score). However, the task description focuses on *internal housekeeping* when the datasets represent a genuinely novel contribution: **the first formally verified training data for decidable non-classical logics**. The cleanup should be designed with external consumption in mind from day one — not as an afterthought.

### 2. The Datasets Are a Publishable Research Artifact

The project roadmap's Phases 5-9 converge on publication. The paper "The Construction of Possible Worlds" (Brast-McKie, 2025) is already published. The datasets could be a standalone companion artifact:

- **BMLogic-Bench** (727 formulas): First stratified evaluation benchmark for bimodal logic — analogous to GLUE/SuperGLUE for NLP. Tier distribution (easy 6.9%, medium 41.3%, hard 36.0%, very hard 15.8%) with ground-truth labels verified by a formally proven decision procedure.
- **BMLogic-Deep** (53,979 records): Large-scale training set with AST representations, countermodels, and difficulty metrics. Unique because labels are provably correct (not human-annotated).
- **BMLogic-Medium** (5,136 records): Exhaustive enumeration at lower complexity — useful for curriculum learning.
- **proof_steps** (2,424 records): Proof decomposition dataset with subgoal structure — enables step-level reasoning research.

No comparable datasets exist in the formal logic ML space. LogiQA and ProofWriter operate over propositional/FOL fragments; no benchmark covers temporal + modal + Until/Since.

### 3. The .gitignore Is Actively Working Against the Task

The `data/.gitignore` currently excludes ALL `.jsonl` and `*_metadata.json` files. This means the final datasets are *not tracked by git* — they're regenerated locally. For publication artifacts, this is backwards. The cleanup should:

- Track final datasets in git (remove blanket `*.jsonl` exclusion)
- Add specific exclusions for intermediates and test files
- Consider Git LFS for the 49MB `bmlogic-deep.jsonl` (exceeds GitHub's 50MB soft limit)

### 4. Metadata Schema Gap Is Wider Than the Task Acknowledges

The benchmark metadata (`bmlogic-bench_metadata.json`) has 14 top-level fields including `description`, `version`, `schema_version`, `quality`, `tier_distribution`, `category_distribution`, `source_distribution`, and `anchor_coverage`. The training metadata files have only 9 fields (`total_records`, `valid_count`, `invalid_count`, `timeout_count`, `avg_complexity`, `include_duals`, `max_complexity`, `sampling_mode`, `frame_class`). The proof_steps dataset has *no metadata file at all*. Standardizing means adding:

- `description`, `version`, `schema_version` to all
- `quality` block (duplicate checks, label verification status)
- Generation provenance (which script, with what parameters, when)
- Schema documentation (field types and descriptions per record)

### 5. The Record Schemas Are Inconsistent Across Datasets

| Field | bench | deep | medium | proof_steps |
|-------|-------|------|--------|-------------|
| `id` | ✓ (bmlogic-bench-NNNNN) | ✓ (bmlogic-NNNNN) | ✓ | ✗ |
| `split` | ✓ (benchmark) | ✓ (train) | ✓ | ✗ |
| `formula_str` | ✓ | ✓ | ✓ | ✗ |
| `formula_ast` | ✓ | ✓ | ✓ | ✗ (goal has AST) |
| `label` | ✓ | ✓ | ✓ | ✗ |
| `proof_trace` | ✓ | ✓ | ✓ | ✗ |
| `countermodel` | ✓ | ✓ | ✓ | ✗ |
| `pattern_key` | ✓ | ✓ | ✓ | ✗ |
| `metrics` | ✓ | ✓ | ✓ | ✗ |
| `benchmark_category` | ✓ | ✗ | ✗ | ✗ |
| `source` | ✓ | ✗ | ✗ | ✗ |
| `difficulty_tier` | ✓ | ✗ | ✗ | ✗ |
| `augmentation` | ✗ | ✓ | ✓ | ✗ |
| `theorem_name` | ✗ | ✗ | ✗ | ✓ |
| `step_index` | ✗ | ✗ | ✗ | ✓ |
| `context` | ✗ | ✗ | ✗ | ✓ |
| `goal` | ✗ | ✗ | ✗ | ✓ |
| `rule` | ✗ | ✗ | ✗ | ✓ |
| `subgoals` | ✗ | ✗ | ✗ | ✓ |
| `frame_class` | ✓ | ✓ | ✓ | ✓ |

The training datasets (deep/medium) share a schema with bench minus the benchmark-specific fields. proof_steps is an entirely different entity (step-level vs formula-level). Attempting to force a single schema across all four would be misguided — they're fundamentally different data types.

### 6. Adjacent Roadmap Opportunity: Task 213 Synergy

Task 213 (production-scale dataset generation validation) is currently IMPLEMENTING and will regenerate datasets at higher complexity (5-7). The cleanup in task 214 should be designed so that task 213's outputs slot in cleanly — same naming conventions, same metadata schema, same directory structure. If 214 runs first and establishes the standard, 213's implementation can conform to it. If 213 runs first, 214 needs to accommodate whatever 213 produces.

**Recommendation**: Define the target schema in 214's plan as a specification that 213 must also follow. This avoids rework.

## Recommended Approach

### Clean-Break Refactor Target (6-Month Vision)

The ideal `data/` directory in 6 months:

```
data/
├── README.md                          # Comprehensive documentation
├── DATASHEET.md                       # Datasheets for Datasets (Gebru et al. 2021)
├── bmlogic-bench/                     # Benchmark suite (separate dir)
│   ├── bmlogic-bench.jsonl            # 727 benchmark formulas
│   ├── metadata.json                  # Rich metadata
│   └── schema.json                    # JSON Schema for records
├── bmlogic-train/                     # Training data
│   ├── deep.jsonl                     # 53K+ records
│   ├── medium.jsonl                   # 5K+ records
│   ├── metadata.json                  # Shared training metadata
│   └── schema.json                    # JSON Schema for records
├── bmlogic-proofs/                    # Proof step data
│   ├── proof_steps.jsonl              # 2.4K step records
│   ├── metadata.json                  # Proof step metadata
│   └── schema.json                    # JSON Schema for records
├── .gitignore                         # Exclude intermediates only
└── scripts/                           # Generation scripts (or symlinks to scripts/)
    ├── generate.sh
    └── curate_benchmark.py
```

This structure:
- Separates datasets by *purpose* (benchmark vs training vs proof reasoning)
- Makes each sub-directory self-contained and publishable
- Supports future frame classes (Dense, Discrete, Integer) as parallel directories
- Enables HuggingFace dataset card generation per sub-directory

### For This Task (Pragmatic Scope)

Don't implement the full vision — that's over-scoped for 4-6 hours. Instead:

1. **Delete intermediates and test files** (straightforward)
2. **Standardize metadata** to the benchmark format where applicable
3. **Add `proof_steps_metadata.json`** (currently missing entirely)
4. **Write `data/README.md`** with dataset cards, schemas, and generation instructions
5. **Fix `.gitignore`** to track finals, exclude intermediates
6. **Add a `data/SCHEMA.md`** documenting the JSON record format per dataset type
7. **Consider Git LFS** for bmlogic-deep.jsonl (49MB — will cause GitHub warnings)

### External Distribution (Future)

When the project reaches publication (Phase 9), the datasets should be:
1. **HuggingFace Hub**: Upload as `logos-labs/bmlogic-bench` and `logos-labs/bmlogic-train` with dataset cards, preview, and streaming support
2. **Zenodo**: Archive a versioned DOI-bearing snapshot alongside the paper
3. **JSONL format is correct** for HuggingFace (native streaming support)

This is out of scope for task 214 but the directory structure and metadata format chosen now should be forward-compatible with HuggingFace's dataset card format.

## Evidence/Examples

### Best Practices for ML Dataset Documentation (2026)

1. **Datasheets for Datasets** (Gebru et al. 2021, now standard): Structured questionnaire covering motivation, composition, collection process, preprocessing, uses, distribution, and maintenance. Major venues (NeurIPS, ICML, ACL) expect this for dataset submissions.

2. **JSON Schema validation**: Including a `schema.json` per dataset type enables automated validation and tooling integration. HuggingFace's `datasets` library can infer types from schema files.

3. **Croissant metadata** (MLCommons, 2024-2026): Machine-readable dataset metadata format gaining adoption. Forward-looking but optional for now.

4. **Versioning**: Dataset versions should be semantic (v1.0, v1.1) and tied to the Lean project version. The metadata `version` field in bmlogic-bench_metadata.json already has `"version": "1.0"` — extend this pattern.

### Cross-Project Value

These datasets could serve:
- **Formal logic ML research**: No comparable non-classical logic benchmark exists
- **Lean prover research**: proof_steps dataset provides supervised step-level data for tactic prediction
- **Curriculum learning research**: The medium→deep→bench hierarchy provides natural difficulty progression
- **Logic education**: The benchmark with its stratified difficulty could serve as teaching material

## Confidence Level

**High** for the cleanup scope assessment and metadata gap analysis (verified by direct file inspection).

**Medium** for the clean-break refactor target and distribution strategy (depends on publication timeline and user priorities).

**Medium** for the cross-project value assessment (no direct evidence of external demand, but the uniqueness of the dataset is clear from the absence of comparable alternatives).
