# Implementation Plan: Task #262

- **Task**: 262 - Interestingness Metrics for Theorems
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (all infrastructure exists in codebase)
- **Research Inputs**: reports/01_interestingness-metrics.md, reports/02_deep-interestingness-survey.md
- **Artifacts**: plans/02_interestingness-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Implement deterministic interestingness metrics for theorems and derivations in bimodal logic TM, organized as a three-tier scoring architecture: fast syntactic gate (Tier 1), proof-structural score (Tier 2), and domain-specific bonuses (Tier 3). The metrics build on existing infrastructure -- `Formula.complexity`, `Formula.modalDepth`, `Formula.temporalDepth`, `ProofTrace`, `RuleProfile`, and `PatternKey` -- adding a new `InterestingnessMetrics.lean` module plus integration into the `LabeledFormula` and JSONL export pipeline. The composite score serves as a reward signal for neural networks discovering interesting results, with a multiplicative SNT gate ensuring trivial formulas (ex_falso, identity, weakening) receive zero reward.

### Research Integration

Two research reports were synthesized into this plan:

- **Report 01** (initial survey): Established the 8-dimension taxonomy (SNT, OD, PDR, PRD, SN, IC, LU, CC), analyzed the critical gap that all 1,959 valid training formulas are trivial height-0 axiom instances, catalogued existing Lean infrastructure, and proposed the multiplicative SNT gating approach.
- **Report 02** (deep literature survey, 36+ sources): Refined the taxonomy into a three-tier architecture (fast syntactic gate, proof-structural score, domain-specific bonuses), added new metrics (Axiom Layer Diversity, Interaction Axiom Dependency, Statement Simplicity, Frame Correspondence Bonus, Proof Incompressibility), provided theoretical grounding via Schmidhuber's compression progress and SPEED-RL's difficulty-based curriculum, and proposed MAP-Elites quality-diversity for theorem generation.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Implement all Tier 1 syntactic metrics (SNT gate, Operator Diversity, Statement Simplicity) as pure `Formula -> Nat/Float` functions
- Implement Tier 2 proof-structural metrics (PDR, PRD, Axiom Layer Diversity) using existing `ProofTrace` and `RuleProfile` structures
- Implement Tier 3 domain-specific bonuses (Interaction Axiom Dependency) from proof trace data
- Create composite `InterestingnessScore` structure with tier classification
- Integrate metrics into `LabeledFormula` and the JSONL export pipeline
- Ensure all metrics are deterministic and computable without external dependencies

**Non-Goals**:
- Implementing learned interestingness measures (FERMAT-style evolutionary approach) -- this is a long-term research direction
- Building the MAP-Elites quality-diversity archive -- this depends on a future theorem generation pipeline
- Implementing Lemma Utility or Structural Novelty cross-reference metrics requiring a proof-step index -- deferred to a follow-on task
- Implementing Frame Correspondence Bonus -- requires deeper integration with FrameConditions module
- Countermodel Complexity scoring for invalid formulas -- the `SemanticCountermodelSummary` already captures the needed data; scoring can be added later

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Derived operator detection (F, G, P, H, diamond) is fragile due to encoding as compound AST patterns | M | M | Implement canonical pattern matching using existing `some_future`, `some_past`, `all_future`, `all_past`, `neg` definitions; add unit tests for each derived operator |
| Propositional tautology check in SNT may be expensive for large formulas | L | L | Limit check to formulas with 0 modal/temporal depth; for mixed formulas, classify as non-trivial without full check |
| All current training data scores near 0 (trivial), making weight calibration impossible from training data alone | M | H | Use the 310 named theorems from proof_steps.jsonl as calibration anchors; defer weight tuning to a separate task |
| Build breakage from new module imports or type changes to LabeledFormula | M | L | Add new fields as `Option` types to avoid breaking existing code; run `lake build` after each phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Tier 1 -- Syntactic Metrics Module [COMPLETED]

**Goal**: Create `InterestingnessMetrics.lean` with all pure-formula metrics that require no proof trace.

**Tasks**:
- [x] Create `Theories/Bimodal/Automation/InterestingnessMetrics.lean` with module header and imports
- [x] Implement `OperatorProfile` structure with fields for each operator type (hasBox, hasDiamond, hasUntil, hasSince, hasAllFuture, hasAllPast, hasSomeFuture, hasSomePast)
- [x] Implement `extractOperatorProfile : Formula -> OperatorProfile` with recursive AST traversal detecting both primitive operators and derived operator patterns (e.g., `untl phi top` as `some_future`, `imp (untl (neg phi) top) bot` as `all_future`)
- [x] Implement `operatorDiversity : Formula -> Nat` counting distinct operator types with cross-modal bonus (+2 if both modal and temporal present) and bidirectional bonus (+1 if both future and past temporal present)
- [x] Implement `semanticNonTriviality : Formula -> Nat` returning 0 for trivially valid patterns (ex_falso `bot.imp _`, identity `phi.imp phi`, weakening `phi.imp (_.imp phi)`, top-implication `_.imp (bot.imp bot)`), 1 for purely propositional formulas (modalDepth=0 and temporalDepth=0), 2 for modal-only or temporal-only, 3 for genuinely bimodal
- [x] Implement `statementSimplicity : Formula -> Nat` as `atomCount * 100 / complexity` ratio *(deviation: altered -- returns Nat scaled by 100 instead of Float for determinism and simplicity)*
- [x] Implement `modalTemporalInteraction : Formula -> Bool` detecting whether a formula uses both modal (box/diamond) and temporal (untl/snce or derived) operators
- [x] Run `lake build Bimodal.Automation.InterestingnessMetrics` to verify compilation

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/InterestingnessMetrics.lean` (NEW) -- all Tier 1 metric functions

**Verification**:
- Module compiles without errors
- `#eval operatorDiversity (Formula.box (Formula.atom_s "p"))` produces expected value
- `#eval semanticNonTriviality (Formula.bot.imp (Formula.atom_s "p"))` returns 0
- `#eval semanticNonTriviality (Formula.box (Formula.atom_s "p").imp (Formula.some_future (Formula.atom_s "p")))` returns 3

---

### Phase 2: Tier 2 -- Proof-Structural Metrics [COMPLETED]

**Goal**: Add proof-trace-aware metrics that operate on existing `ProofTrace` and `RuleProfile` structures.

**Tasks**:
- [x] Add `proofDepthRatio : ProofTrace -> Formula -> Nat` computing `height * 100 / complexity` *(deviation: altered -- returns Nat scaled by 100 instead of Float)*
- [x] Add `proofRuleDiversity : ProofTrace -> Nat` counting distinct entries in `rules_applied`
- [x] Implement axiom layer classification: `classifyAxiomLayer : String -> String` mapping axiom names to one of 4 layers ("propositional", "modal", "temporal", "interaction") using the layer scheme from `extractAxiomName` in DatasetGenerator.lean
- [x] Add `axiomLayerDiversity : ProofTrace -> Nat` counting distinct axiom layers used (max 4)
- [x] Add `proofRichness : RuleProfile -> Formula -> Nat` computing total non-axiom rule applications * 100 / complexity *(deviation: altered -- returns Nat scaled by 100 instead of Float)*
- [x] Add `interactionAxiomDependency : ProofTrace -> Bool` returning true if `axioms_used` contains "modal_future"
- [x] Run `lake build Bimodal.Automation.InterestingnessMetrics` to verify

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/InterestingnessMetrics.lean` -- add Tier 2 functions

**Verification**:
- All functions compile and produce expected values for test inputs
- `axiomLayerDiversity` correctly classifies all axiom names from the `extractAxiomName` match cases
- `interactionAxiomDependency` returns true for traces containing "modal_future"

---

### Phase 3: Composite Score and Tier Classification [COMPLETED]

**Goal**: Implement the composite interestingness score combining all metrics with configurable weights, and the tier classification system.

**Tasks**:
- [x] Define `InterestingnessWeights` structure with Nat fields for each dimension (w_OD, w_PDR, w_PRD, w_ALD, w_IAD, w_SS, w_PR) and a `default` instance *(deviation: altered -- uses Nat weights instead of Float; added w_PR for proof richness; SNT gate is multiplicative, not a weight)*
- [x] Define `InterestingnessTier` inductive with variants: trivial, routine, basic, moderate, notable, interesting, remarkable
- [x] Implement `InterestingnessTier.fromScore : Nat -> InterestingnessTier` using the 7-tier score ranges on 0-1000 scale *(deviation: altered -- uses Nat on 0-1000 scale instead of Float 0.0-1.0)*
- [x] Implement `InterestingnessTier.toString : InterestingnessTier -> String`
- [x] Define `InterestingnessResult` structure holding the composite score (Nat), tier, individual dimension scores, and SNT gate value
- [x] Implement `computeInterestingness : Formula -> Option ProofTrace -> Option RuleProfile -> InterestingnessWeights -> InterestingnessResult` with multiplicative SNT gating
- [x] Implement `InterestingnessResult.toJson : InterestingnessResult -> String` for JSON serialization
- [x] Run `lake build Bimodal.Automation.InterestingnessMetrics` to verify

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/InterestingnessMetrics.lean` -- add composite score structures and computation

**Verification**:
- `computeInterestingness` on `bot.imp phi` with any trace returns score=0.0, tier=trivial
- `computeInterestingness` on a formula with high OD and non-zero SNT produces score > 0.3
- JSON serialization produces valid JSON with all expected fields

---

### Phase 4: LabeledFormula Integration and JSONL Export [COMPLETED]

**Goal**: Add interestingness fields to `LabeledFormula` and wire them into the dataset generation and JSONL export pipeline.

**Tasks**:
- [x] Add `interestingnessScore : Option Nat` and `interestingnessTier : Option String` fields to `LabeledFormula` structure in `DatasetGenerator.lean` *(deviation: altered -- uses Nat instead of Float)*
- [x] Update `LabeledFormula`'s `Inhabited` instance to include the new `Option` fields with `none` defaults *(deviation: altered -- used default field values instead of explicit Inhabited entries)*
- [x] In `DatasetGenerator.lean`, import `InterestingnessMetrics` and call `computeInterestingness` during the `labelFormula` pipeline, storing the result in the new fields
- [x] In `DatasetGenerator.lean`, update `LabeledFormula.toJson` to include `"interestingness_score"` and `"interestingness_tier"` fields *(deviation: altered -- toJson is in DatasetGenerator not DatasetExporter)*
- [ ] Update `DatasetMetadata` in `DatasetExporter.lean` to include a note about interestingness metrics version *(deviation: skipped -- low priority metadata annotation)*
- [x] Register the new module in the project's import chain (`Theories/Bimodal/Automation.lean`)
- [x] Run `lake build` (full project build) to verify no breakage

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- add fields to `LabeledFormula`, compute score in `labelFormula`
- `Theories/Bimodal/Automation/DatasetExporter.lean` -- add interestingness fields to JSON output
- `Theories/Bimodal/Automation/DatasetExport.lean` -- add `InterestingnessResult.toJson` if needed for export helpers
- Root import file (if one exists) -- register `InterestingnessMetrics` module

**Verification**:
- Full `lake build` succeeds with no errors
- `LabeledFormula` records include interestingness data
- JSONL output includes `interestingness_score` and `interestingness_tier` fields

---

### Phase 5: Validation and Calibration [COMPLETED]

**Goal**: Validate metrics against known theorems and verify score distribution across the triviality spectrum.

**Tasks**:
- [x] Create `Tests/BimodalTest/Automation/InterestingnessTest.lean` with test cases for each metric function *(deviation: altered -- placed in Automation/ subdirectory following existing test organization)*
- [x] Add test cases for trivial formulas: `bot.imp (atom "p")` (SNT=0, score=0), `(atom "p").imp (atom "p")` (SNT=0, score=0)
- [x] Add test cases for modal formula: `box (atom "p") |>.imp (atom "p")` (SNT=2)
- [x] Add test cases for bimodal formulas: formula with both box and until operators (SNT=3, high OD)
- [x] Add test cases for operator profile extraction: verify each derived operator pattern is correctly detected (8 operator types)
- [x] Add test cases for axiom layer classification: verify prop_k, modal_t, modal_future, serial_future, connect_future, density
- [x] Verify that `InterestingnessTier.fromScore` correctly maps all 7 tier boundaries (9 boundary tests)
- [x] Run `lake build` to verify all tests compile -- 41 tests pass, full build succeeds

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Tests/BimodalTest/InterestingnessTest.lean` (NEW) -- comprehensive test suite
- Lakefile or test runner configuration -- register new test file

**Verification**:
- All test cases compile and pass
- Score distribution spans the expected range across test cases
- SNT gate correctly zeros out trivial formula scores
- Full `lake build` succeeds

## Testing & Validation

- [ ] `lake build Bimodal.Automation.InterestingnessMetrics` succeeds after Phase 1-3
- [ ] Full `lake build` succeeds after Phase 4 (no breakage to existing modules)
- [ ] `semanticNonTriviality` returns 0 for all known trivial patterns (ex_falso, identity, weakening, top-implication)
- [ ] `operatorDiversity` correctly detects derived operators (F, G, P, H, diamond) encoded as compound AST patterns
- [ ] `axiomLayerDiversity` classifies all 42 axiom constructors into the correct layer
- [ ] Composite score produces 0.0 for trivial formulas (SNT gate) and >0.0 for non-trivial ones
- [ ] JSONL export includes `interestingness_score` and `interestingness_tier` fields
- [ ] Score tier boundaries match the 7-tier classification from Report 02

## Artifacts & Outputs

- `Theories/Bimodal/Automation/InterestingnessMetrics.lean` -- new module with all metric functions, composite score, and JSON serialization
- `Tests/BimodalTest/InterestingnessTest.lean` -- test suite
- Updated `Theories/Bimodal/Automation/DatasetGenerator.lean` -- `LabeledFormula` with interestingness fields
- Updated `Theories/Bimodal/Automation/DatasetExporter.lean` -- JSONL export with interestingness fields

## Rollback/Contingency

All new code is isolated in a new file (`InterestingnessMetrics.lean`). The `LabeledFormula` changes use `Option` types, so reverting requires only removing the new fields and the import. If any phase fails to compile, the new module can be excluded from the build without affecting existing functionality. Git revert of the implementation commits restores the pre-implementation state completely.
