# Teammate C Findings: Critic Analysis

**Task**: 214 - Dataset cleanup, standardization, and documentation
**Angle**: Gaps, risks, and blind spots
**Date**: 2026-05-29

## Key Findings

### 1. CRITICAL: axiom-instances.jsonl Is Not Purely Intermediate

The task description marks `axiom-instances.jsonl` as an intermediate to delete, but it is a **pipeline input** to the benchmark curation process. The benchmark pipeline (task 205) flows:

```
benchmark_anchors -> axiom-instances.jsonl (724 records)
                          |
curate_benchmark.py ------+--> bmlogic-bench-candidates.jsonl (1771)
  (loads axiom-instances   |
   + production data)      v
                    benchmark_oracle -> bmlogic-bench-validated.jsonl (1771)
                                              |
                    finalize_benchmark.py -> bmlogic-bench.jsonl (727)
```

While `axiom-instances.jsonl` can be regenerated via `lake exe benchmark_anchors`, deleting it breaks the ability to quickly re-run just the Python curation step without rebuilding from Lean. The candidates and validated files are truly intermediate (they're fully subsumed by the final benchmark), but axiom-instances has independent value as a reference artifact showing all 724 concrete axiom schema instantiations.

**Risk**: Low — regenerable — but the task should explicitly decide whether axiom-instances should be kept as a reference or documented as regenerable-intermediate.

### 2. HIGH RISK: 51MB Dataset in Git Will Cause Repo Bloat

`bmlogic-deep.jsonl` is 51.5MB. The task says to "update .gitignore to track final datasets" — meaning this file would be committed to git. Problems:

- **Every regeneration** (e.g., task 213 plans to re-run at complexity 5-7) creates a new 50MB+ commit. After 3-4 regenerations, data/ alone adds 150-200MB to git history.
- **Clone penalty**: New contributors clone the entire history. `git clone --depth 1` helps but is a workaround.
- **proof_steps.jsonl** is 15MB — same concern at smaller scale.
- **Git is not designed for large binary/data files.** The threshold for "should this be in Git LFS or external storage?" is typically 10MB.

**Alternatives to evaluate**:
1. Keep the current `.gitignore` approach (exclude all generated data) and document regeneration commands
2. Use Git LFS for large files
3. Track only small files in git (bench at 672K, medium at 4.2MB) and gitignore the large ones
4. Use a separate `data/` release mechanism (GitHub Releases, DVC, or the HuggingFace task 208)

### 3. Schema Standardization Is Wrong-Headed for proof_steps.jsonl

The task says to "standardize metadata JSON schemas across all kept datasets to match the richer bmlogic-bench_metadata.json format." But:

- **proof_steps.jsonl has a completely different record schema**: `{theorem_name, step_index, context, goal, rule, axiom_name, subgoals, frame_class}` vs the formula datasets' `{id, split, formula_str, formula_ast, frame_class, label, ...}`.
- **proof_steps has no metadata file at all** — the `proof_extractor` executable doesn't generate one (confirmed: no "metadata" references in ProofStepExport.lean).
- The bench metadata has 20+ fields (tier_distribution, category_distribution, quality checks, etc.) that make no sense for training data or proof steps.

**Recommendation**: Don't force a single metadata schema. Instead:
- Define a **common header** (name, version, description, generation_date, schema_version, total_count, frame_class) shared by all metadata files
- Allow **dataset-specific sections** (tier_distribution for bench, sampling_mode for training, theorem_coverage for proof_steps)
- Create a proof_steps_metadata.json with proof-step-appropriate fields

### 4. Dependency Tasks (204, 205) Are Complete — But Task 213 Is Active

Tasks 204 and 205 are both `completed`, so the dependency is satisfied. However:

- **Task 213** ("Production-scale dataset generation validation") is `[IMPLEMENTING]` and plans to **re-run the dataset generator at complexity 5-7**. This will overwrite `bmlogic-deep.jsonl` and `bmlogic-medium.jsonl` with new data.
- If task 214 tracks these files in git and documents their current schemas/counts, those docs immediately become stale when task 213 regenerates them.

**Risk**: Medium. Task 214 should either:
1. Wait for task 213 to complete, OR
2. Design documentation to be regeneration-aware (document the schema and generation commands, not frozen record counts)

### 5. No Checksums or Integrity Verification

The task mentions no mechanism for verifying dataset integrity after generation. Considerations:

- **SHA-256 checksums** in metadata files would allow quick verification that files haven't been corrupted or accidentally modified
- The `dataset_validator` executable exists but only validates conformance, not file integrity
- Without checksums, there's no way to confirm the files on disk match what was generated

### 6. data/.gitignore Currently Excludes Everything — Design Tension

The current `data/.gitignore` excludes `*.jsonl` and `*_metadata.json`. The task says to change this to track finals while excluding intermediates. But:

- The `.gitignore` in `data/` is the **only** gitignore for data files. The root `.gitignore` has no data-related rules.
- Switching from "ignore all" to "ignore selectively" requires careful negation patterns:
  ```
  # Ignore all generated files
  *.jsonl
  *_metadata.json
  # But track finals
  !bmlogic-bench.jsonl
  !bmlogic-bench_metadata.json
  ...
  ```
- This is fragile — new intermediate files added by future pipeline runs will be tracked unless the pattern is maintained.

### 7. Schema Evolution Not Addressed

The record schemas have already evolved (bench records have `benchmark_category`, `source`, `difficulty_tier` fields not present in training records). As the pipeline matures:
- What happens when new fields are added to the generator?
- Should metadata include a `schema_version` field for downstream consumers?
- The bench metadata already has `schema_version: "1.0"` but training metadata doesn't.

## Recommended Approach

1. **Don't track large files in git.** Keep `bmlogic-deep.jsonl` (51MB) and `proof_steps.jsonl` (15MB) gitignored. Only track `bmlogic-bench.jsonl` (672K) and `bmlogic-medium.jsonl` (4.2MB) if desired, or track none and document regeneration commands.
2. **Don't force bench metadata format on all datasets.** Define a common metadata header + dataset-specific extensions.
3. **Create proof_steps_metadata.json** with appropriate fields (theorem_count, step_count, rule_distribution, etc.).
4. **Keep axiom-instances.jsonl or explicitly document it as regenerable.** Don't silently delete a pipeline input.
5. **Add SHA-256 checksums** to metadata files for integrity verification.
6. **Coordinate with task 213** — either wait for it or design docs to be regeneration-aware.
7. **Consider task 208 (HuggingFace packaging)** as the distribution mechanism for large files instead of git.

## Evidence/Examples

- Pipeline flow: `BenchmarkAnchors.lean:34` references task 205 plan; `BenchmarkOracle.lean` hardcodes default paths `data/bmlogic-bench-candidates.jsonl` and `data/bmlogic-bench-validated.jsonl`
- proof_steps schema is completely disjoint from formula schemas (0 shared field names except `frame_class`)
- Task 205 summary explicitly lists `axiom-instances.jsonl` as a produced artifact
- Task 213 is `[IMPLEMENTING]` and will regenerate training datasets
- `DatasetMetadata` structure in `DatasetExport.lean:304-321` has 9 fields; bench metadata JSON has 20+ fields — the generator code would need modification to produce the richer format

## Confidence Level

**High** on risks #1-4 and #6 (verified against source code and task state).
**Medium** on risks #5 and #7 (best practices, not verified blockers).
