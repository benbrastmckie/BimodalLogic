# Implementation Plan: Prove Seed Consistency Axioms

- **Task**: 34 - prove_succ_seed_consistency_axioms
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (building on existing infrastructure in WitnessSeed.lean, DiscreteSuccSeed.lean)
- **Research Inputs**: specs/034_prove_succ_seed_consistency_axioms/reports/01_seed-consistency-research.md
- **Artifacts**: plans/01_seed-axiom-elimination.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Prove or eliminate three axioms in `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` that were deferred from Task 29 Phase 7. Under reflexive semantics with T-axioms available, all three axioms can be proven using the established proof pattern from `forward_temporal_witness_seed_consistent` in WitnessSeed.lean. The deferral seed axioms (1-2) are structurally simpler than existing axioms because they lack blocking formulas, making them straightforward to adapt from existing proofs. The F-step axiom (3) requires more careful analysis of Lindenbaum extension behavior.

### Research Integration

The research report identified:
- **Key Proof Pattern**: `forward_temporal_witness_seed_consistent` in WitnessSeed.lean (line 79) provides the template
- **T-Axiom Availability**: `Gφ → φ` and `Hφ → φ` are in the proof system under reflexive semantics
- **Structural Simplicity**: Deferral seeds omit blocking formulas, reducing proof complexity
- **g_content_consistent**: Already proven in DiscreteSuccSeed.lean (line 225), reusable as foundation

## Goals & Non-Goals

**Goals**:
- Prove `successor_deferral_seed_consistent_axiom` (line 266)
- Prove `predecessor_deferral_seed_consistent_axiom` (line 311)
- Prove `predecessor_f_step_axiom` (line 516)
- Remove all three `axiom` declarations, replacing with `theorem` + proof
- Verify no axiom regression using `lean_verify` tool

**Non-Goals**:
- Addressing the deprecated `canonicalR_irreflexive_axiom` (Layer 2 concern, isolated)
- Modifying the Succ/Pred relation definitions
- Optimizing existing proof infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-step axiom proof more complex than anticipated | H | M | Phase 4 includes fallback: document semantic argument more rigorously if direct proof fails |
| Deduction theorem adaptation requires additional lemmas | M | L | Use existing `deduction_theorem` from ProofSystem; research identified it as already available |
| Build time increases significantly | L | L | Use incremental `lake build SuccExistence` rather than full rebuild |
| MCP tools timeout during proof exploration | M | L | Use `lean_multi_attempt` for tactic exploration; fall back to manual iteration |

## Implementation Phases

### Phase 1: Prove Successor Seed Consistency [COMPLETED]

**Goal**: Replace `successor_deferral_seed_consistent_axiom` with a proven theorem

**Tasks**:
- [ ] Read and understand `forward_temporal_witness_seed_consistent` proof structure in WitnessSeed.lean
- [ ] Identify required helper lemmas (deduction theorem, generalized temporal K, MCS closure)
- [ ] Create proof outline: assume inconsistency, case split on whether deferral disjunction is in inconsistent subset
- [ ] Implement Case 1: If no deferral disjunctions in L, reduce to `g_content_consistent`
- [ ] Implement Case 2: If deferral disjunction `φ ∨ F(φ)` in L, use deduction theorem + generalized temporal K
- [ ] Replace `axiom` declaration with `theorem` and proof
- [ ] Run `lake build` to verify compilation

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Replace axiom at line 266 with theorem

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccExistence` succeeds
- `lean_verify successor_deferral_seed_consistent_axiom` shows no axioms (will need new name after replacement)

---

### Phase 2: Prove Predecessor Seed Consistency [COMPLETED]

**Goal**: Replace `predecessor_deferral_seed_consistent_axiom` with a proven theorem

**Tasks**:
- [ ] Adapt Phase 1 proof for temporal duality (h_content instead of g_content, P instead of F)
- [ ] Use `generalized_past_k` instead of `generalized_temporal_k`
- [ ] Verify symmetric structure maintains correctness
- [ ] Replace `axiom` declaration with `theorem` and proof
- [ ] Run `lake build` to verify compilation

**Timing**: 0.75 hours (leveraging Phase 1 structure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Replace axiom at line 311 with theorem

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccExistence` succeeds
- `lean_verify predecessor_deferral_seed_consistent_axiom` shows no axioms

---

### Phase 3: Analyze F-step Property [COMPLETED]

**Goal**: Develop proof strategy for `predecessor_f_step_axiom`

**Tasks**:
- [ ] Analyze `predecessor_from_deferral_seed` construction to understand how F-formulas enter the MCS
- [ ] Check existing `h_content_subset_implies_g_content_reverse` theorem for applicability
- [ ] Explore temporal duality approach: h_content(u) ⊆ v → g_content(v) ⊆ u
- [ ] Trace Lindenbaum extension behavior for F-formula introduction
- [ ] Determine if new helper lemmas are needed
- [ ] Document proof strategy or identify blockers

**Timing**: 0.75 hours

**Files to examine**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - predecessor construction
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - f/g/h/p content relationships
- `Theories/Bimodal/Metalogic/Core/Lindenbaum.lean` - Lindenbaum extension properties

**Verification**:
- Documented proof strategy or blocker analysis

---

### Phase 4: Prove F-step Axiom [BLOCKED]

**Goal**: Replace `predecessor_f_step_axiom` with a proven theorem

**Tasks**:
- [ ] Implement proof based on Phase 3 strategy
- [ ] If proof too complex, create helper lemmas:
  - Lemma: F-formulas in Lindenbaum extension derive from seed or negation completeness
  - Lemma: Seed structure constrains F-content relationship
- [ ] If direct proof fails after 1.5 hours: document semantic argument more rigorously as comment, mark as TODO for future work
- [ ] Replace `axiom` declaration with `theorem` and proof (or sorry with detailed comment)
- [ ] Run `lake build` to verify compilation

**Timing**: 1 hour (with contingency for fallback)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Replace axiom at line 516 with theorem

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccExistence` succeeds
- Either axiom eliminated or clearly documented as future work

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] Run `lean_verify Bimodal.Metalogic.Bundle.SuccExistence.successor_from_deferral_seed` to check axiom usage
- [ ] Run `lean_verify Bimodal.Metalogic.Bundle.SuccExistence.predecessor_from_deferral_seed` to check axiom usage
- [ ] Grep for `axiom` in SuccExistence.lean to confirm all three are eliminated or documented
- [ ] Verify dependent theorems (`successor_succ`, `predecessor_succ`, `predecessor_pred`) still compile

## Artifacts & Outputs

- `plans/01_seed-axiom-elimination.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` with proofs
- `summaries/01_seed-axiom-summary.md` upon completion

## Rollback/Contingency

If proofs introduce regressions or unacceptable complexity:
1. `git checkout Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` to restore original
2. Document blockers in research report update
3. Consider task decomposition: create subtasks for additional lemmas about deferral disjunction derivability or F/P duality specific to seed extensions
