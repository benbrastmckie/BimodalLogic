# Implementation Summary: Task #262 -- Interestingness Metrics

## What Was Done

Implemented a three-tier deterministic interestingness scoring system for theorems and derivations in bimodal logic TM. The system produces a composite score (0-1000 scale) with 7-tier classification, serving as a reward signal for neural networks discovering interesting results.

### New Files
- `Theories/Bimodal/Automation/InterestingnessMetrics.lean` -- Core metrics module (570 lines)
- `Tests/BimodalTest/Automation/InterestingnessTest.lean` -- Test suite (41 tests)

### Modified Files
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- Added interestingness fields to LabeledFormula, compute scores in labelFormula pipeline, JSON export
- `Theories/Bimodal/Automation.lean` -- Registered InterestingnessMetrics module

## Architecture

### Tier 1: Syntactic Metrics (formula-only, no proof data needed)
- `OperatorProfile` + `extractOperatorProfile` -- Recursive AST traversal detecting 8 operator types (box, diamond, until, since, all_future, all_past, some_future, some_past) including derived operator pattern matching
- `operatorDiversity` -- Distinct operators + cross-modal bonus (+2) + bidirectional bonus (+1)
- `semanticNonTriviality` (SNT gate) -- 0 for trivial (ex_falso, identity, weakening, top-imp), 1 propositional, 2 unimodal, 3 bimodal
- `statementSimplicity` -- atomCount * 100 / complexity
- `modalTemporalInteraction` -- Boolean: both modal and temporal operators present

### Tier 2: Proof-Structural Metrics
- `proofDepthRatio` -- height * 100 / complexity
- `proofRuleDiversity` -- distinct inference rules used
- `classifyAxiomLayer` -- Maps 42 axiom names to 4 layers (propositional, modal, temporal, interaction)
- `axiomLayerDiversity` -- distinct axiom layers in proof (max 4)
- `proofRichness` -- non-axiom rules * 100 / complexity
- `interactionAxiomDependency` -- Whether proof uses modal_future (the sole bridge axiom)

### Tier 3: Composite Score
- `InterestingnessWeights` -- Configurable weights with research-recommended defaults
- `InterestingnessTier` -- 7 tiers: trivial, routine, basic, moderate, notable, interesting, remarkable
- `computeInterestingness` -- Multiplicative SNT gate (0 zeroes score, 1 halves, 2+ full credit) applied to weighted sum of normalized dimensions
- `InterestingnessResult.toJson` -- JSON serialization for pipeline export

### Pipeline Integration
- `LabeledFormula` gains `interestingnessScore : Option Nat` and `interestingnessTier : Option String`
- `labelFormula` computes scores for all three branches (valid with full proof data, invalid/timeout with syntactic-only)
- `LabeledFormula.toJson` emits `interestingness_score` and `interestingness_tier` fields
- `ProofData` bridge structure avoids circular import between InterestingnessMetrics and DatasetGenerator

## Key Design Decisions

1. **All-Nat arithmetic**: Used Nat scaled by 100 or 1000 instead of Float for determinism and simplicity
2. **Multiplicative SNT gate**: Trivial formulas (ex_falso, identity, weakening) get exactly 0 score regardless of other metrics
3. **ProofData bridge**: Lightweight mirror of ProofTrace to break import cycle between InterestingnessMetrics.lean and DatasetGenerator.lean
4. **Default field values**: `interestingnessScore` and `interestingnessTier` default to `none`, preserving backward compatibility

## Verification

- 0 sorries, 0 vacuous definitions, 0 new axioms
- Full `lake build` succeeds (1682 jobs)
- 41 test cases all pass covering SNT gate, operator profiles, diversity scoring, axiom classification, tier boundaries, composite computation, JSON serialization, and interaction detection

## Plan Deviations

- statementSimplicity returns Nat (scaled by 100) instead of Float per plan
- proofDepthRatio and proofRichness return Nat (scaled by 100) instead of Float per plan
- InterestingnessWeights uses Nat weights instead of Float; includes w_PR for proof richness
- InterestingnessTier.fromScore uses Nat on 0-1000 scale instead of Float 0.0-1.0
- Test file placed in `Tests/BimodalTest/Automation/` subdirectory, not `Tests/BimodalTest/`
- DatasetMetadata version note skipped (low priority)
