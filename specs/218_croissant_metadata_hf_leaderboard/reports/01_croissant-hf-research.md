# Research Report: Task #218

**Task**: 218 - Croissant Metadata Finalization + HuggingFace Leaderboard
**Started**: 2026-05-29T00:00:00Z
**Completed**: 2026-05-29T01:00:00Z
**Effort**: ~3 hours (validation, schema fixes, HF README update, optional Gradio Space)
**Dependencies**: None
**Sources/Inputs**:
- `data/croissant.json` (existing skeleton)
- `data/hf-dataset/README.md` (dataset card)
- `data/hf-dataset/validate.py`, `upload.py`, `PUBLISHING.md`
- `data/bmlogic-bench.jsonl`, `bmlogic-c5.jsonl`, `bmlogic-c7.jsonl`, `proof_steps.jsonl` (actual JSONL schemas)
- `data/bmlogic-bench_metadata.json` (benchmark metadata)
- `data/README.md` (data directory overview)
- MLCommons Croissant 1.0 specification (docs.mlcommons.org)
- mlcroissant PyPI package documentation
- HuggingFace dataset card specification (hub-docs)
- HuggingFace leaderboard/benchmark guide (blog)
**Artifacts**:
- `specs/218_croissant_metadata_hf_leaderboard/reports/01_croissant-hf-research.md` (this file)
**Standards**: report-format.md, artifact-formats.md

---

## Executive Summary

- `data/croissant.json` has one critical schema bug (`cr:conformsTo` should be `dct:conformsTo`), two schema gaps (missing `nl_paraphrase` and `nl_paraphrase_method` fields in the benchmark RecordSet), one URL mismatch (contentUrls reference `benbrastmckie/BimodalLogic` while the intended HF repo is `logos-labs/bmlogic-bench`), and null `sha256` values (optional per spec but strongly recommended).
- The `@context` in croissant.json is missing the term-to-namespace mappings for `source`, `fileObject`, `extract`, `jsonPath`, `column`, `field`, `recordSet`, `dataType`, and `conformsTo` that the official Croissant examples include; without these mappings, these terms expand to `schema.org/` rather than `mlcommons.org/croissant/`, which will likely cause mlcroissant validation warnings or errors.
- The HF dataset card (`data/hf-dataset/README.md`) currently uses `task_categories: [text-classification]`; the task requires updating to `['text-generation', 'other']`, and `task_ids: ['formal-provability-classification']` is a custom identifier (HF does not maintain a registry of task_ids for `other`).
- All four JSONL distributions have correct record counts (727, 1513, 49904, 2424) and their field schemas match the croissant.json RecordSet definitions except for the benchmark schema gap above.
- The mlcroissant Python package (v1.1.0, requires Python >= 3.10) is not currently installed; it must be installed via `pip install mlcroissant` to run validation.
- A Gradio Space leaderboard follows a four-component architecture (public leaderboard Space, private evaluator Space, private submissions dataset, public results dataset); a template exists at `huggingface.co/spaces/gradio-templates/leaderboard`.

---

## Context & Scope

This research covers three acceptance criteria for task 218:

1. **Croissant validation**: Validate `data/croissant.json` against mlcroissant 1.0 Python tooling, identify and fix schema issues, ensure all four JSONL distributions are correctly listed with accurate field descriptions.
2. **HF README update**: Change `task_categories` in `data/hf-dataset/README.md` to `['text-generation', 'other']` and add `task_ids: ['formal-provability-classification']`.
3. **Gradio Space** (optional): Research patterns for an interactive formula classification demo and leaderboard submission endpoint.

The project is a Lean 4 formalization of bimodal logic TM with four dataset distributions: `bmlogic-c5.jsonl` (training, 1513 records), `bmlogic-c7.jsonl` (training, 49904 records), `bmlogic-bench.jsonl` (evaluation benchmark, 727 records), and `proof_steps.jsonl` (proof step supervision, 2424 records).

---

## Findings

### Codebase Patterns

#### Existing File Inventory (data/)

| File | Records | Purpose |
|------|---------|---------|
| `bmlogic-c5.jsonl` | 1,513 | Training, complexity ≤ 5, 14 fields (schema v2.0) |
| `bmlogic-c7.jsonl` | 49,904 | Training, complexity ≤ 7, 14 fields (schema v2.0) |
| `bmlogic-bench.jsonl` | 727 | Evaluation benchmark, 15 fields (schema v1.1, with nl_paraphrase) |
| `proof_steps.jsonl` | 2,424 | Proof step supervision, 8 fields |
| `croissant.json` | — | MLCommons metadata skeleton |
| `hf-dataset/README.md` | — | HF dataset card (YAML frontmatter + markdown body) |

#### Actual Field Schemas (verified against JSONL files)

**bmlogic-c5.jsonl and bmlogic-c7.jsonl** (14 fields, schema v2.0):
`id`, `split`, `formula_str`, `formula_ast`, `frame_class`, `label`, `proof_trace`, `countermodel`, `pattern_key`, `metrics`, `augmentation`, `formula_sexpr`, `formula_tokens`, `pattern_features`

**bmlogic-bench.jsonl** (15 fields, schema v1.1):
`id`, `split`, `formula_str`, `formula_ast`, `frame_class`, `label`, `proof_trace`, `countermodel`, `pattern_key`, `metrics`, `benchmark_category`, `source`, `difficulty_tier`, `nl_paraphrase`, `nl_paraphrase_method`

**proof_steps.jsonl** (8 fields):
`theorem_name`, `step_index`, `context`, `goal`, `rule`, `axiom_name`, `subgoals`, `frame_class`

#### Croissant.json Current State

The skeleton at `data/croissant.json` (424 lines) contains:
- Top-level dataset metadata: name, description, url, version, datePublished, license, creator, keywords, citation, `cr:conformsTo` (BUG — see Issues)
- `cr:distribution`: 5 FileObject entries (4 JSONL + 1 JSON for splits file)
- `cr:recordSet`: 3 RecordSet entries (training-schema-v2, benchmark-schema-v1, proof-steps-schema)
- `cr:task`: 2 Task entries (provability-classification, proof-step-prediction)

The benchmark RecordSet (`benchmark-schema-v1`) defines 13 fields but the actual file has 15 fields (missing `nl_paraphrase` and `nl_paraphrase_method` added in v1.1 on 2026-05-29).

### Issues Identified in croissant.json

#### Issue 1 — CRITICAL: Wrong namespace for conformsTo

The Croissant 1.0 specification requires the Dublin Core Terms property `dct:conformsTo`. The current skeleton uses `cr:conformsTo` (Croissant namespace), which is incorrect.

```json
// Current (WRONG):
"cr:conformsTo": "http://mlcommons.org/croissant/1.0"

// Required (CORRECT):
"dct:conformsTo": "http://mlcommons.org/croissant/1.0"
```

The official Titanic reference dataset at `github.com/mlcommons/croissant/datasets/1.0/titanic/metadata.json` uses the unprefixed `"conformsTo"` which the @context expands to `dct:conformsTo`. Our croissant.json does not include `conformsTo` in the @context, making `dct:conformsTo` the safe explicit form.

#### Issue 2 — CRITICAL: @context missing term mappings

The current `@context` defines only namespace prefixes:
```json
{
  "@language": "en",
  "@vocab": "https://schema.org/",
  "cr": "http://mlcommons.org/croissant/",
  "dct": "http://purl.org/dc/terms/",
  "sc": "https://schema.org/"
}
```

The official reference examples include explicit term-to-namespace mappings for all Croissant-specific properties: `source`, `fileObject`, `extract`, `column`, `jsonPath`, `field`, `recordSet`, `dataType`, `conformsTo`, `citeAs`, `isLiveDataset`, `references`, etc. Without these, JSON-LD processors expand `"source"` to `"https://schema.org/source"` (via `@vocab`) instead of `"http://mlcommons.org/croissant/source"`. This will likely trigger validation warnings from mlcroissant.

The fix is to add explicit term mappings in @context matching the official Croissant reference examples. Note that in practice, mlcroissant may still parse the file correctly if it performs namespace-aware processing, but explicit mappings are the safe approach.

#### Issue 3 — SCHEMA GAP: nl_paraphrase fields missing from benchmark RecordSet

The `benchmark-schema-v1` RecordSet in croissant.json documents 13 fields, but `bmlogic-bench.jsonl` (v1.1) has 15 fields: the two paraphrase augmentation fields (`nl_paraphrase`, `nl_paraphrase_method`) added on 2026-05-29 are absent from the Croissant metadata.

These fields are "optional" (backward-compatible) in the JSONL schema but are present in all 727 records. They should be added to the RecordSet with appropriate field descriptions, noting they are optional for backward compatibility.

#### Issue 4 — URL MISMATCH: contentUrls reference wrong HF repository

All distribution `contentUrl` values reference `benbrastmckie/BimodalLogic`:
```
https://huggingface.co/datasets/benbrastmckie/BimodalLogic/resolve/main/data/...
```

But the intended publication repository (per `hf-dataset/upload.py` and `hf-dataset/README.md`) is `logos-labs/bmlogic-bench`:
```
https://huggingface.co/datasets/logos-labs/bmlogic-bench/resolve/main/data/...
```

The contentUrls must be updated to match the actual HF repository where the dataset will be published. This is the most impactful correctness issue for downstream consumers.

#### Issue 5 — RECOMMENDED: sha256 values are null

All 5 distributions have `"sc:sha256": null`. The spec marks sha256 as optional but "strongly recommended for versioning." Computing and populating actual SHA-256 hashes for the JSONL files would complete the skeleton. For the LFS-tracked files (bmlogic-c7.jsonl, proof_steps.jsonl), sha256 must be computed against the actual file content.

#### Issue 6 — MINOR: Dataset name mismatch

`croissant.json` uses `"name": "BMLogic"` but the HF dataset card uses `"pretty_name": "BMLogic-Bench: Bimodal Logic Benchmark"`. The Croissant `name` should match or be harmonized with the HF dataset name (`bmlogic-bench` or `BMLogic-Bench`).

#### Issue 7 — MINOR: contentSize format

The `contentSize` values use human-readable strings (`"1.4 MB"`, `"< 1 MB"`). The spec recommends using `schema.org/contentSize` which typically accepts integer bytes. The string format is accepted by mlcroissant but is non-standard.

### HF README Analysis

**Current state** (`data/hf-dataset/README.md` YAML frontmatter):
```yaml
task_categories:
  - text-classification
```

**Issues**:
1. `text-classification` is inaccurate — the dataset supports both provability classification and proof step prediction tasks. The `text-classification` pipeline on HuggingFace typically implies NLP tasks on natural language text, not formal logic classification.
2. The task description requires changing to `['text-generation', 'other']` — however, this deserves scrutiny (see Decisions).
3. `task_ids` field is not present. The `task_ids` format follows `{task_category}-{subtask}` patterns (e.g., `open-book-qa`, `closed-domain-qa`). The identifier `formal-provability-classification` is a custom identifier; HuggingFace does not maintain a registry for custom task_ids under `other`, but the field is accepted for discovery purposes.

**Additional note**: The HF dataset card (hf-dataset/README.md) also uses:
```yaml
license: cc-by-4.0
```
But `data/croissant.json` uses `https://opensource.org/licenses/MIT`. There is a license mismatch between the two files that needs resolution (the PUBLISHING.md and README.md both say CC BY 4.0 but the Lean project's standard is MIT).

### HF Leaderboard / Gradio Space Research

#### HuggingFace Leaderboard Architecture (2025-2026)

The recommended pattern for a custom benchmark leaderboard uses four components:

1. **Public Leaderboard Space** (Gradio): Displays results table, accepts model prediction submissions. Template: `huggingface.co/spaces/gradio-templates/leaderboard`.
2. **Private Evaluator Space** (Gradio): Reads submissions dataset, scores predictions against held-out test labels, writes results. Runs on a polling loop (every ~5 minutes).
3. **Private Submissions Dataset**: Stores incoming prediction files and submission metadata.
4. **Public Results Dataset**: Stores evaluation scores by model; leaderboard reads from this.

#### Implementation Details

**Submission flow**:
- User uploads a predictions JSONL file (one prediction per `id` in bmlogic-bench) via the Gradio Space
- Submission metadata (model_name, submitted_by, timestamp, prediction_file_path) written to submissions dataset via HuggingFace Hub API
- Evaluator Space polls submissions dataset, computes accuracy/F1/per-tier scores against bmlogic-bench ground truth labels
- Results written to public results dataset; leaderboard refreshes on demand

**Key metrics for BMLogic-Bench leaderboard**:
- Overall accuracy (valid vs invalid)
- F1 score (valid class)
- Per-tier accuracy: easy, medium, hard, very_hard
- Accuracy by logic fragment (propositional-only, modal-only, temporal-only, bimodal) using bmlogic-bench-splits.json

**Security**: Ground truth labels are in bmlogic-bench.jsonl which is already public (HF dataset). A leaderboard thus cannot hide test labels. The value of the leaderboard is aggregation, visibility, and structured comparison rather than preventing label leakage.

**Open LLM Leaderboard**: The original HF Open LLM Leaderboard submission UI has been archived as of June 2025. Custom benchmark leaderboards are the recommended path for domain-specific benchmarks.

**mlcroissant library tag**: Adding `- mlcroissant` to the `tags:` section of the HF dataset card enables the mlcroissant library widget on the dataset page (per HF docs: `tags` for supported libraries).

---

## Decisions

1. **conformsTo key**: Use `"dct:conformsTo"` (explicit Dublin Core Terms namespace) in croissant.json. This is the specification-compliant form and avoids JSON-LD namespace ambiguity.

2. **@context enrichment**: The @context should be extended with the full set of Croissant term mappings from the official reference examples to ensure correct JSON-LD expansion. The current four-entry @context is insufficient for mlcroissant to resolve Croissant-specific terms.

3. **task_categories decision**: The task instruction requests `['text-generation', 'other']`. Analysis: `text-classification` is the most semantically accurate category (binary classification of formula validity), while `text-generation` is less accurate (the dataset does not train generative models). However, `other` + custom `task_ids` is the recommended approach for novel tasks not fitting existing HuggingFace pipeline categories. The instruction's intent appears to be: use `text-generation` (for LLM fine-tuning use cases) + `other` (for the formal reasoning classification task). This is a valid editorial choice — implementation should follow the task instructions as stated.

4. **URL correction**: The contentUrls should be updated to `logos-labs/bmlogic-bench` (the intended HF target) but must remain consistent with whatever repository the dataset is actually published to. If the repository has not yet been published, the URLs are placeholders that can be updated post-publish.

5. **nl_paraphrase fields**: These two fields must be added to the `benchmark-schema-v1` RecordSet in croissant.json, marked as optional (present in all current records but backward-compatible).

6. **License resolution**: The croissant.json license (`MIT`) should be reconciled with the HF dataset card license (`CC BY 4.0`). This decision belongs to the dataset author but both files should agree.

---

## Recommendations

### Priority 1 — Fix croissant.json (Required for Acceptance)

**Fix 1.1**: Change `"cr:conformsTo"` to `"dct:conformsTo"` at the top level.

**Fix 1.2**: Extend the `@context` with the Croissant standard term mappings. The minimal additions needed are:
```json
"@context": {
  "@language": "en",
  "@vocab": "https://schema.org/",
  "cr": "http://mlcommons.org/croissant/",
  "dct": "http://purl.org/dc/terms/",
  "sc": "https://schema.org/",
  "conformsTo": "dct:conformsTo",
  "citeAs": "cr:citeAs",
  "dataType": "cr:dataType",
  "field": "cr:field",
  "fileObject": "cr:fileObject",
  "fileProperty": "cr:fileProperty",
  "fileSet": "cr:fileSet",
  "extract": "cr:extract",
  "recordSet": "cr:recordSet",
  "references": "cr:references",
  "source": "cr:source",
  "column": "cr:column",
  "jsonPath": "cr:jsonPath",
  "transform": "cr:transform"
}
```

**Fix 1.3**: Add `nl_paraphrase` and `nl_paraphrase_method` fields to `benchmark-schema-v1` RecordSet:
```json
{
  "@type": "cr:Field",
  "@id": "bench/nl_paraphrase",
  "name": "nl_paraphrase",
  "description": "Natural-language English paraphrase of the formula (added v1.1, 2026-05-29). Generated by recursive AST-walker with derived-operator detection. Optional field; all 727 records contain non-null values.",
  "dataType": "sc:Text",
  "source": {"fileObject": {"@id": "bmlogic-bench-jsonl"}, "extract": {"jsonPath": "$.nl_paraphrase"}}
},
{
  "@type": "cr:Field",
  "@id": "bench/nl_paraphrase_method",
  "name": "nl_paraphrase_method",
  "description": "Paraphrase generation method: 'rule_based' (modalDepth + temporalDepth <= 2, 635 records) or 'rule_based_complex' (depth >= 3, 92 records). Optional field.",
  "dataType": "sc:Text",
  "source": {"fileObject": {"@id": "bmlogic-bench-jsonl"}, "extract": {"jsonPath": "$.nl_paraphrase_method"}}
}
```

**Fix 1.4**: Update all `contentUrl` values from `benbrastmckie/BimodalLogic` to `logos-labs/bmlogic-bench` (or whatever the actual publication repository will be).

**Fix 1.5**: Update `"name": "BMLogic"` to `"name": "BMLogic-Bench"` for consistency with the HF dataset card.

### Priority 2 — Compute sha256 (Strongly Recommended)

Install mlcroissant and compute SHA-256 for each JSONL file before running validation:
```bash
pip install mlcroissant
sha256sum data/bmlogic-c5.jsonl data/bmlogic-c7.jsonl data/bmlogic-bench.jsonl data/proof_steps.jsonl
```
Populate the `sc:sha256` fields in croissant.json (or rename to just `"sha256"` after adding `"sha256": "sc:sha256"` to the @context).

Then validate:
```bash
mlcroissant validate --jsonld data/croissant.json
```

### Priority 3 — Update HF README (Required for Acceptance)

In `data/hf-dataset/README.md`, change the YAML frontmatter:
```yaml
# Current:
task_categories:
  - text-classification

# Target:
task_categories:
  - text-generation
  - other
task_ids:
  - formal-provability-classification
```

Also add the `mlcroissant` library tag to make the mlcroissant widget appear on the HF dataset page:
```yaml
tags:
  - logic
  - theorem-proving
  - bimodal-logic
  - temporal-logic
  - modal-logic
  - lean4
  - formal-verification
  - benchmark
  - reasoning
  - mlcroissant   # ADD THIS
```

**License reconciliation**: Decide on MIT or CC BY 4.0 and update both `croissant.json` and `hf-dataset/README.md` to use the same license.

### Priority 4 — Gradio Space (Optional)

Build a three-tab Gradio Space:
- **Tab 1: Leaderboard** — sortable table of model results (overall accuracy, per-tier accuracy, F1) loaded from a public results dataset
- **Tab 2: Submit** — file upload for prediction JSONL, model name/link fields
- **Tab 3: About** — dataset description, evaluation metric definitions, how to prepare predictions

Use the `gradio-templates/leaderboard` Space as a template. Create:
- `logos-labs/bmlogic-bench-submissions` (private dataset)
- `logos-labs/bmlogic-bench-results` (public dataset)
- Private evaluator Space that scores against bmlogic-bench ground truth

Note: Since bmlogic-bench labels are public, the evaluator Space approach cannot prevent test-set leakage. The leaderboard provides visibility and structured model comparison, not a blind evaluation.

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|-----------|
| mlcroissant validation still warns after @context fix | Medium | Run `mlcroissant validate --debug` to identify remaining issues; consult issue #963 on mlcommons/croissant GitHub |
| contentUrls incorrect if repo not yet published | Medium | Use placeholder URL format and update post-publish; document in PUBLISHING.md |
| License mismatch (MIT vs CC BY 4.0) causes HF rejection | Low | Author must decide; update both files before publishing |
| `task_ids: formal-provability-classification` not recognized by HF | Low | HF accepts custom task_ids for `other` category; no registry validation |
| Gradio Space evaluation loop latency (5-min poll) causes poor UX | Low | Cache results; show "last updated" timestamp |
| bmlogic-c7.jsonl sha256 computation slow (52 MB LFS file) | Low | Must `git lfs pull` first; run sha256sum once and embed in croissant.json |

---

## Context Extension Recommendations

- **Topic**: Croissant metadata maintenance workflow
- **Gap**: No documented process for keeping `data/croissant.json` synchronized with JSONL schema updates
- **Recommendation**: Add a note to `data/README.md` under "Validate Packaging" that schema changes to any JSONL file require parallel updates to both `data/croissant.json` RecordSet field lists and `data/hf-dataset/README.md` data field tables

---

## Appendix

### Key File Paths
- `data/croissant.json` — Croissant metadata skeleton (needs fixes)
- `data/hf-dataset/README.md` — HF dataset card (needs task_categories update)
- `data/hf-dataset/validate.py` — Local packaging validator (does not validate Croissant)
- `data/hf-dataset/PUBLISHING.md` — Upload workflow (covers Croissant download step)
- `data/bmlogic-bench_metadata.json` — Benchmark statistics for field description accuracy

### mlcroissant Installation
```bash
pip install mlcroissant  # v1.1.0, requires Python >= 3.10
mlcroissant validate --jsonld data/croissant.json
mlcroissant validate --jsonld data/croissant.json --debug  # extra detail
```

### HuggingFace task_categories Valid Values (selected)
All valid values from `huggingface.js/packages/tasks/src/pipelines.ts`:
`text-classification`, `text-generation`, `token-classification`, `question-answering`, `summarization`, `multiple-choice`, `other` (and ~40 more).

`other` is a valid official category. Custom `task_ids` under `other` are accepted for discovery filtering even without a registry entry.

### References
- MLCommons Croissant 1.0 spec: https://docs.mlcommons.org/croissant/docs/croissant-spec.html
- mlcroissant PyPI: https://pypi.org/project/mlcroissant/ (v1.1.0)
- mlcommons/croissant GitHub: https://github.com/mlcommons/croissant
- HF dataset card docs: https://huggingface.co/docs/hub/en/datasets-cards
- HF task categories list: https://github.com/huggingface/huggingface.js/blob/main/packages/tasks/src/pipelines.ts
- HF benchmark guide: https://huggingface.co/blog/hugging-science/building-a-benchmark-or-challenge
- HF leaderboard template: https://huggingface.co/spaces/gradio-templates/leaderboard
- Croissant validate issue #963: https://github.com/mlcommons/croissant/issues/963
- Croissant version issue #609: https://github.com/mlcommons/croissant/issues/609
