# Implementation Plan: Contrastive Pair Generation

- **Task**: 206 - contrastive_pair_generation
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (existing infrastructure sufficient)
- **Research Inputs**: reports/01_contrastive-pairs.md
- **Artifacts**: plans/01_contrastive-pairs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement a `FormulaMutator.lean` module in `Theories/Bimodal/Automation/` that generates contrastive pairs from valid formulas. The module applies systematic mutations (atom substitution with bot, operator weakening box->diamond/G->F/H->P, subformula deletion, depth reduction, temporal duality) and re-runs the decision procedure to produce `(valid_formula, invalid_mutation, countermodel)` triples. This creates the dual-verification training signal identified as novel in task 201 research. The module will include JSON serialization and a standalone executable entry point.

### Research Integration

Key findings from the research report (reports/01_contrastive-pairs.md):

- **Formula AST**: 6 primitive constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce`); all other operators (neg, and, or, diamond, G, H, F, P, next, prev) are derived. Mutations must operate at the primitive level.
- **Existing infrastructure**: `swap_temporal` (temporal duality, preserves validity for Base frame class) and `subst_formula` (atom substitution) already exist. No dedicated mutator module exists.
- **Decision procedure**: `decideAuto`/`decideOptimized` with `DecisionResult` type returning valid proofs, countermodels, or timeout. `labelFormula` in DatasetGenerator shows the invocation pattern.
- **Countermodels**: `SimpleCountermodel` (atom-level) and `EnrichedCountermodel` (full branch info with modal/temporal formulas) both available with JSON serialization.
- **Derived operator recognition**: G/H are encoded as nested imp/untl/snce/bot patterns. Pattern matching helpers (`matchAllFuture`, `matchAllPast`) needed for G->F / H->P weakening.
- **Performance**: ~1ms per decision at complexity <= 5. Batch of 18K mutations feasible in ~18 seconds.
- **Dependency recommendation**: Reimplement a local `substAtom` rather than importing the heavy `Separation.FormulaOps` chain.
- **Output recommendation**: Standalone JSONL format (Option B) rather than extending existing `DatasetRecord`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define `MutationType` inductive and `ContrastivePair` structure for representing mutation metadata and contrastive outputs
- Implement all 7 mutation strategies: atom-to-bot, box-to-diamond, G-to-F, H-to-P, subformula deletion, modal/temporal depth reduction, temporal duality
- Implement derived-operator recognition helpers for G and H pattern matching
- Build a pipeline that takes labeled formulas, generates mutations, re-runs decision procedure, and filters for truly contrastive pairs
- Serialize contrastive pairs to JSONL format with enriched countermodels
- Add a standalone executable entry point for batch contrastive pair generation
- Zero sorry in the module (pure functional mutations + IO pipeline)

**Non-Goals**:
- Modifying the existing `DatasetRecord` schema or `DatasetExport` pipeline
- Proving correctness theorems about mutations (this is data generation code, not proof code)
- Optimizing the decision procedure itself
- Supporting frame classes other than Base
- Building a training harness or ML integration

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| G/H pattern matching fragility (encoding depends on exact `top`/`neg` definitions) | M | M | Use existing `top` definition (`imp bot bot`), add unit tests for pattern recognition |
| Low contrastive yield (many mutations preserve validity) | L | M | Research estimates 30-50% yield; acceptable for training data. Quality filtering ensures only genuinely contrastive pairs exported |
| Heavy import chain from DatasetGenerator/EnrichedCountermodel | L | L | Already compiled for existing pipeline; incremental build cost minimal |
| Mutation-induced timeouts (some mutated formulas harder for decision procedure) | L | M | Use `decideAuto` with built-in fuel limits; exclude timeout results from contrastive pairs |
| `subst_formula` import pulls heavy Separation dependency | M | H | Reimplement local `substAtom` (~10 lines) as recommended by research |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Core Types and Mutation Functions [NOT STARTED]

**Goal**: Define the foundational types (`MutationType`, `ContrastivePair`) and implement all 7 mutation functions plus derived-operator recognition helpers.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/FormulaMutator.lean` with module header, imports (`Bimodal.Syntax`, `Bimodal.Automation.DatasetGenerator`, `Bimodal.Automation.EnrichedCountermodel`)
- [ ] Define `MutationType` inductive with 8 variants: `atomSubBot`, `boxToDiamond`, `allFutureToSomeFuture`, `allPastToSomePast`, `subformulaDeletion`, `modalDepthReduction`, `temporalDepthReduction`, `temporalDuality`
- [ ] Define `ContrastivePair` structure with fields: `original`, `originalLabel`, `mutated`, `mutatedLabel`, `mutationType`, `countermodel`, `enrichedCountermodel`, `originalProofTrace`
- [ ] Implement local `substAtom : Formula -> Atom -> Formula -> Formula` (avoids Separation import)
- [ ] Implement `matchAllFuture : Formula -> Option Formula` and `matchAllPast : Formula -> Option Formula` for derived-operator recognition
- [ ] Implement `mutateAtomToBot : Formula -> Atom -> Formula` using local `substAtom`
- [ ] Implement `weakenBoxToDiamond : Formula -> Formula` (recursive box->diamond replacement)
- [ ] Implement `weakenAllToSome : Formula -> Formula` (G->F and H->P using pattern matching helpers)
- [ ] Implement `deleteSubformula : Formula -> Formula -> Formula -> Formula` (target subformula replacement)
- [ ] Implement `reduceModalDepth : Formula -> Formula` (strip outermost box)
- [ ] Implement `reduceTemporalDepth : Formula -> Formula` (strip outermost untl/snce)
- [ ] Implement `generateMutations : Formula -> List (Formula x MutationType)` that produces all applicable mutations for a given formula
- [ ] Run `lake build Bimodal.Automation.FormulaMutator` to verify compilation

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` - New file: types and mutation functions

**Verification**:
- Module compiles without errors or sorry
- `generateMutations` produces mutations for a test formula with atoms, boxes, and temporal operators

---

### Phase 2: Contrastive Pair Generation Pipeline [NOT STARTED]

**Goal**: Build the IO pipeline that takes labeled formulas, applies mutations, re-runs the decision procedure, and filters for truly contrastive pairs (including temporal duality from invalid formulas).

**Tasks**:
- [ ] Implement `classifyMutation : Formula -> MutationType -> IO ContrastivePair` that runs `decideAuto` on the mutated formula and constructs the pair record
- [ ] Implement `generateContrastivePairs : LabeledFormula -> IO (List ContrastivePair)` that generates all mutations for a labeled formula, classifies each, and returns results
- [ ] Implement `filterContrastive : List ContrastivePair -> List ContrastivePair` to keep only pairs where `originalLabel != mutatedLabel` and `mutated.complexity >= 3` and neither is timeout
- [ ] Implement temporal duality contrastive pairs: for invalid formulas, apply `swap_temporal`, re-run decision procedure, keep pairs where dual has different validity
- [ ] Implement `generateBatchContrastive : List LabeledFormula -> IO (List ContrastivePair)` with progress reporting (following existing `labelBatch` pattern)
- [ ] Add enriched countermodel extraction via `findEnrichedCountermodel` for invalid mutations
- [ ] Run `lake build Bimodal.Automation.FormulaMutator` to verify compilation

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` - Add pipeline functions

**Verification**:
- Pipeline compiles and handles valid->invalid, invalid->valid (temporal duality), and unchanged (filtered out) cases
- Progress reporting works for batch processing

---

### Phase 3: JSON Serialization and Export [NOT STARTED]

**Goal**: Add JSON serialization for `MutationType` and `ContrastivePair`, implement JSONL file export, and add a standalone executable entry point.

**Tasks**:
- [ ] Implement `MutationType.toString : MutationType -> String` for human-readable mutation names
- [ ] Implement `MutationType.toJson : MutationType -> String` for JSON mutation type field
- [ ] Implement `ContrastivePair.toJson : ContrastivePair -> String` producing the full JSON record (original formula/AST/label, mutated formula/AST/label, countermodel, enriched countermodel, mutation type and detail)
- [ ] Implement `writeContrastiveJSONL : List ContrastivePair -> System.FilePath -> IO Unit` to write JSONL output file
- [ ] Implement `ContrastiveBatchStats` structure and `computeContrastiveStats` for summary statistics (total mutations, contrastive count, yield rate, per-mutation-type breakdown)
- [ ] Implement `main : IO Unit` entry point that enumerates formulas (reusing `FormulaEnumerator`), labels them, generates contrastive pairs, exports JSONL, and prints summary stats
- [ ] Add `lean_exe contrastive_generator` to `lakefile.lean` pointing to this module
- [ ] Run `lake build contrastive_generator` to verify the executable builds

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` - Add serialization and main function
- `lakefile.lean` - Add `lean_exe contrastive_generator` entry

**Verification**:
- `lake build contrastive_generator` succeeds
- Running `lake exe contrastive_generator` (even briefly) produces valid JSONL output without crash

---

### Phase 4: Integration Validation and Build Verification [NOT STARTED]

**Goal**: Verify the complete module integrates correctly with the existing pipeline, passes full project build, and produces meaningful contrastive pairs.

**Tasks**:
- [ ] Run `lake build` to verify full project builds with the new module
- [ ] Validate that existing executables (`dataset_generator`, `dataset_validator`, `proof_extractor`) still build correctly
- [ ] Verify JSONL output schema matches the research-specified format (id, original block, mutation block, mutation_type, mutation_detail)
- [ ] Verify enriched countermodels are populated for invalid mutations
- [ ] Verify temporal duality pairs are generated from invalid formulas with differing swap_temporal validity
- [ ] Confirm zero sorry in the module via `lean_verify` or grep
- [ ] Review and clean up any unused imports or dead code

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` - Final cleanup if needed

**Verification**:
- `lake build` succeeds (full project)
- No sorry in FormulaMutator.lean
- JSONL output contains valid JSON records with expected fields
- Existing executables unaffected

## Testing & Validation

- [ ] `lake build Bimodal.Automation.FormulaMutator` compiles without errors
- [ ] `lake build contrastive_generator` builds the executable
- [ ] `lake build` full project passes (no regressions)
- [ ] Zero sorry in FormulaMutator.lean (grep check)
- [ ] `generateMutations` produces expected mutation count for formulas with known structure
- [ ] `filterContrastive` correctly excludes non-contrastive pairs and timeout results
- [ ] `matchAllFuture` and `matchAllPast` correctly recognize G/H encoding patterns
- [ ] JSONL output is valid JSON (parseable by standard tools)
- [ ] Temporal duality pairs generated from invalid formulas with differing swap_temporal validity
- [ ] Enriched countermodels populated for invalid mutations

## Artifacts & Outputs

- `Theories/Bimodal/Automation/FormulaMutator.lean` - New module with all mutation, pipeline, and export code
- `lakefile.lean` - Updated with `contrastive_generator` executable entry
- `specs/206_contrastive_pair_generation/plans/01_contrastive-pairs.md` - This plan file

## Rollback/Contingency

- The implementation creates a single new file (`FormulaMutator.lean`) and adds one entry to `lakefile.lean`. Rollback is straightforward: delete the new file and revert the lakefile change.
- If G/H pattern matching proves too fragile, fall back to simpler mutations (atom-to-bot, box-to-diamond, depth reduction) which do not require derived-operator recognition.
- If enriched countermodel extraction is too slow for batch processing, fall back to `SimpleCountermodel` only and add enriched extraction as a future enhancement.
- If the Separation import chain causes build issues, the local `substAtom` reimplementation avoids it entirely (this is the planned approach).
