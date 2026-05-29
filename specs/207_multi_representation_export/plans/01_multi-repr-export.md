# Implementation Plan: Multi-Representation Formula Export

- **Task**: 207 - Multi-representation formula export
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: Task 203 (completed)
- **Research Inputs**: specs/207_multi_representation_export/reports/01_multi-repr-export.md
- **Artifacts**: plans/01_multi-repr-export.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Extend the JSONL dataset export pipeline to include three new formula representations alongside the existing `formula_str` and `formula_ast` fields: an S-expression string (`formula_sexpr`), a prefix-notation token list (`formula_tokens`), and a numeric feature vector (`pattern_features`). All new serialization functions are pure, recursive, and follow existing string-concatenation patterns in DataExport.lean. The DatasetRecord structure and its JSON serializer in DatasetExport.lean are updated to include the new fields. An optional GNN adjacency-list format is deferred since the existing nested `formula_ast` already serves GNN needs with minimal Python-side preprocessing.

### Research Integration

The research report confirmed that `pattern_key` (the JSON object) is already exported. The task description's mention of "PatternKey numeric features" refers to a flat numeric vector suitable for direct neural-network input, distinct from the existing JSON object. The S-expression printer and tokenizer are straightforward recursive functions on the 6-constructor `Formula` type. The research identified a 15-token symbolic vocabulary for the tokenizer (no BPE/subword needed for structured symbolic expressions). GNN adjacency-list export was assessed as lower priority and deferred.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No specific ROADMAP.md items are advanced by this task. This is a dataset tooling enhancement for ML model consumption.

## Goals & Non-Goals

**Goals**:
- Add `Formula.toSExpr` for canonical S-expression output
- Add `Formula.tokenize` for prefix-notation token lists consumable by transformers
- Add `GoalCategory.toNat` and `PatternKey.toFeatureVector` for numeric feature export
- Integrate all three new representations into `DatasetRecord` and JSONL output
- Update dataset metadata to document available representations

**Non-Goals**:
- GNN adjacency-list format (deferred; existing `formula_ast` suffices)
- Token vocabulary file generation (can be done downstream in Python)
- Modifying the `DatasetExporter.lean` secondary pipeline (only the primary JSONL pipeline is targeted)
- Adding new BPE/subword tokenization (unnecessary for fixed symbolic vocabulary)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| String concatenation performance at scale | L | Low | Existing pattern works; all functions are O(n) in formula size |
| Token vocabulary collision with atom names | L | Low | Atoms are always preceded by the `ATOM` marker token |
| Breaking existing JSONL consumers | H | Low | New fields are strictly additive; no existing fields change |
| Build time increase from new definitions | L | Very Low | Approximately 100 lines of pure functions added |
| GoalCategory.toNat mapping incomplete | M | Low | All 8 variants covered even though `goalCategory` only produces 6 in practice |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |
| 3 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: S-Expression Printer [COMPLETED]

**Goal**: Add `Formula.toSExpr` to DataExport.lean for canonical S-expression serialization of formulas.

**Tasks**:
- [x] Add `Formula.toSExpr : Formula -> String` as a recursive function on the 6 constructors
- [x] Handle `fresh_index` in atom serialization (append index when present)
- [x] Use `escapeJsonString` for atom base names (consistent with existing serialization)
- [x] Verify the function compiles with `lake build Bimodal.Automation.DataExport`

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DataExport.lean` - Add `Formula.toSExpr` after `Formula.prettyPrint` (around line 135)

**Verification**:
- `lake build Bimodal.Automation.DataExport` succeeds without errors
- Function follows the pattern: `(imp (atom "p") (atom "q"))` for `p -> q`

---

### Phase 2: Tokenizer [COMPLETED]

**Goal**: Add `Formula.tokenize` to DataExport.lean for prefix-notation token list generation.

**Tasks**:
- [x] Add `Formula.tokenize : Formula -> List String` as a recursive function on the 6 constructors
- [x] Add `tokenListToJson : List String -> String` helper that wraps tokens as a JSON array of quoted strings
- [x] Token vocabulary: `ATOM`, `BOT`, `IMP`, `BOX`, `UNTL`, `SNCE` as operator tokens; atom base names as value tokens
- [x] Verify the function compiles with `lake build Bimodal.Automation.DataExport`

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DataExport.lean` - Add `Formula.tokenize` and `tokenListToJson` after `Formula.toSExpr`

**Verification**:
- `lake build Bimodal.Automation.DataExport` succeeds without errors
- Token sequence for `p -> q` is `["IMP", "ATOM", "p", "ATOM", "q"]`

---

### Phase 3: Pattern Feature Vector [COMPLETED]

**Goal**: Add `GoalCategory.toNat` and `PatternKey.toFeatureVector` to DataExport.lean for numeric feature export.

**Tasks**:
- [x] Add `GoalCategory.toNat : GoalCategory -> Nat` mapping all 8 variants to numeric IDs (0-7)
- [x] Add `PatternKey.toFeatureVector : PatternKey -> List Nat` extracting the 5 numeric fields plus the `toNat`-encoded top operator
- [x] Add `PatternKey.featureVectorToJson : PatternKey -> String` serializing the vector as a JSON array of integers
- [x] Verify the function compiles with `lake build Bimodal.Automation.DataExport`

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DataExport.lean` - Add `GoalCategory.toNat`, `PatternKey.toFeatureVector`, and `PatternKey.featureVectorToJson` after `PatternKey.toJson` (around line 171)

**Verification**:
- `lake build Bimodal.Automation.DataExport` succeeds without errors
- Feature vector for a PatternKey with modalDepth=1, temporalDepth=0, impCount=1, complexity=3, topOperator=Implication is `[1, 0, 1, 3, 2]`

---

### Phase 4: DatasetRecord Integration [COMPLETED]

**Goal**: Add the three new fields to `DatasetRecord` and wire them into the JSONL serialization and record construction.

**Tasks**:
- [x] Add `formula_sexpr : String` field to `DatasetRecord` structure
- [x] Add `formula_tokens : String` field to `DatasetRecord` structure (pre-serialized JSON array)
- [x] Add `pattern_features : String` field to `DatasetRecord` structure (pre-serialized JSON array)
- [x] Update `Inhabited DatasetRecord` instance with default values for new fields
- [x] Update `datasetRecordToJson` to include the three new fields in the JSON output
- [x] Update `labeledToRecord` to compute new fields: call `toSExpr`, `tokenize` + `tokenListToJson`, and `featureVectorToJson`
- [x] Verify the function compiles with `lake build Bimodal.Automation.DatasetExport`

**Timing**: 1 hour

**Depends on**: 1, 2, 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - Modify `DatasetRecord` (line 157), `Inhabited DatasetRecord` (line 182), `datasetRecordToJson` (line 198), and `labeledToRecord` (line 224)

**Verification**:
- `lake build Bimodal.Automation.DatasetExport` succeeds without errors
- All three new fields appear in `datasetRecordToJson` output
- `labeledToRecord` correctly computes all new field values

---

### Phase 5: Build Verification and Metadata Update [COMPLETED]

**Goal**: Verify the complete project builds and update dataset metadata to document available representations.

**Tasks**:
- [x] Run full `lake build` to verify no regressions
- [x] Update `datasetMetadataToJson` in DatasetExport.lean to include a `representations` field listing all available formats
- [x] Run `lake build` again to confirm metadata changes compile
- [ ] Optionally run `lake exe dataset_generator -- --max-complexity 3 --max-formulas 10 --output /tmp/test_multi_repr.jsonl` to verify new fields appear in output *(deviation: skipped -- optional functional test not part of compilation verification)*

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - Update `datasetMetadataToJson` (line 332) to include representations list

**Verification**:
- `lake build` succeeds without errors across the entire project
- New JSONL records contain `formula_sexpr`, `formula_tokens`, and `pattern_features` fields
- Metadata file includes `representations` field listing all available formats

## Testing & Validation

- [ ] `lake build Bimodal.Automation.DataExport` succeeds (phases 1-3)
- [ ] `lake build Bimodal.Automation.DatasetExport` succeeds (phase 4)
- [ ] Full `lake build` succeeds with no regressions (phase 5)
- [ ] S-expression output uses constructor names as heads and matches primitive form (no derived operators)
- [ ] Token sequences are valid prefix notation (unambiguous without parentheses)
- [ ] Feature vectors are consistently 5 elements long
- [ ] New JSONL fields are additive (existing fields unchanged)
- [ ] Dataset metadata includes representations list

## Artifacts & Outputs

- `Theories/Bimodal/Automation/DataExport.lean` - New serialization functions (toSExpr, tokenize, toFeatureVector)
- `Theories/Bimodal/Automation/DatasetExport.lean` - Updated DatasetRecord with new fields and serialization
- `specs/207_multi_representation_export/plans/01_multi-repr-export.md` - This plan
- `specs/207_multi_representation_export/summaries/01_multi-repr-export-summary.md` - Implementation summary (created at completion)

## Rollback/Contingency

All changes are additive (new functions and new struct fields). If any phase fails:
- Phases 1-3 are independent and can be reverted individually via `git checkout` on DataExport.lean
- Phase 4 changes to DatasetExport.lean can be reverted independently
- If the full build fails in Phase 5, revert DatasetExport.lean changes and investigate the specific build error
- No existing functionality is modified, so rollback risk is minimal
