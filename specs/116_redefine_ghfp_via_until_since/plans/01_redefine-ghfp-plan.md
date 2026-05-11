# Implementation Plan: Task #116

- **Task**: 116 - Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Status**: [NOT STARTED]
- **Effort**: 20 hours
- **Dependencies**: Task 107 (completed)
- **Research Inputs**: specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md
- **Artifacts**: plans/01_redefine-ghfp-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan removes `all_future` (G) and `all_past` (H) as primitive constructors from the `Formula` inductive type, replacing them with definitional abbreviations following Burgess 1982 section 1.1. The new definitions are: F(phi) = U(phi, top), P(phi) = S(phi, top), G(phi) = neg(F(neg(phi))), H(phi) = neg(P(neg(phi))). This reduces the `Formula` type from 8 to 6 constructors while preserving all semantic and proof-theoretic properties. The refactor touches approximately 70 non-Boneyard files with ~1416 references, organized into 10 phases proceeding from the core syntax layer outward.

### Research Integration

Key findings from the research report (reports/01_redefine-ghfp-research.md):
- Semantic equivalence confirmed for all four operators under irreflexive temporal semantics
- 122 pattern-match arms on `all_future`/`all_past` must be eliminated across all recursive functions and inductive proofs
- ~700 constructor applications require mechanical update to use the new definitions
- `temp_k_dist` and `temp_4` axiom constructors become derivable and should be removed from the Axiom inductive
- `temporal_necessitation` currently produces `G(phi)` directly; must be reformulated for the new definition
- SubformulaClosure (1744 lines, 115 references) is the highest-risk file due to closure size expansion
- Strategy A (transparent abbreviations) is recommended: let G/H expand fully, add simp lemmas as needed

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation performed for this plan.

## Goals & Non-Goals

**Goals**:
- Remove `all_future` and `all_past` from `Formula` inductive type
- Define `all_future`, `all_past`, `some_future`, `some_past` as `def` abbreviations using `untl`/`snce` and `top`
- Remove `temp_k_dist` and `temp_4` from `Axiom` inductive (now derivable)
- Reformulate `temporal_necessitation` to produce `G(phi)` via the new definition
- Provide `@[simp]` lemmas bridging old and new representations
- Ensure `lake build` passes after each phase
- Update all pattern matches, inductions, and constructor applications across the codebase

**Non-Goals**:
- Changing the semantic treatment of `untl`/`snce` (these remain primitive constructors)
- Modifying `box` or any modal operators
- Optimizing SubformulaClosure for smaller closure size (Strategy B deferred; use Strategy A)
- Updating Boneyard files beyond minimal compilation fixes
- Changing the argument ordering convention for `untl`/`snce` (Burgess convention preserved)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| SubformulaClosure size explosion (G/H expand to 5+ constructors) | H | M | Use Strategy A (transparent); add custom simp lemmas if decidability proofs break |
| Cascade of broken proofs across 70 files | H | H | Phased approach with `lake build` validation; address files layer by layer |
| temporal_necessitation reformulation difficulty | M | M | Derive G(phi) via: necessitation gives `phi`, build `neg(U(neg(phi), top))` using propositional + Until axioms |
| FMP/Decidability pipeline breakage from pattern match removal | H | M | Defer decidability fixes to Phase 8; use sorry temporarily if needed |
| Performance regression from larger term expansion | L | M | Monitor `lake build` times; G(phi) expands to 5 constructors vs 1 |
| Proof search/automation degradation | M | M | Update ProofSearch heuristics in Phase 9; simp lemmas help automation |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5, 6 | 3, 4 |
| 5 | 7 | 5 |
| 6 | 8 | 5, 6 |
| 7 | 9 | 7, 8 |
| 8 | 10 | 9 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Core Formula Type Redefinition [NOT STARTED]

**Goal**: Remove `all_future` and `all_past` constructors from `Formula`, add definitional abbreviations, and establish foundational simp lemmas.

**Tasks**:
- [ ] Remove `all_future` and `all_past` constructors from the `Formula` inductive type (8 -> 6 constructors)
- [ ] Add `def top : Formula := Formula.bot.imp Formula.bot` if not already present
- [ ] Redefine `some_future` as `def some_future (phi : Formula) : Formula := Formula.untl phi top`
- [ ] Redefine `some_past` as `def some_past (phi : Formula) : Formula := Formula.snce phi top`
- [ ] Redefine `all_future` as `def all_future (phi : Formula) : Formula := (some_future phi.neg).neg`
- [ ] Redefine `all_past` as `def all_past (phi : Formula) : Formula := (some_past phi.neg).neg`
- [ ] Remove `beq_all_past_eq`, `beq_all_future_eq` helper theorems (no longer constructors)
- [ ] Update `beq_refl` proof: remove `all_past`/`all_future` induction cases
- [ ] Update `eq_of_beq` proof: remove `all_past`/`all_future` match arms
- [ ] Update `complexity`, `modalDepth`, `temporalDepth`, `countImplications` functions: remove `all_past`/`all_future` pattern-match arms (these now compute via the expanded definition)
- [ ] Add `@[simp]` lemmas: `all_future_def`, `all_past_def`, `some_future_def`, `some_past_def` for unfolding
- [ ] Update `atoms` function: remove `all_past`/`all_future` arms
- [ ] Update `swap_temporal`: remove `all_past`/`all_future` arms (G/H swap follows automatically from `untl <-> snce` swap)
- [ ] Add simp lemma: `swap_temporal_all_future` showing `swap_temporal (all_future phi) = all_past (swap_temporal phi)`
- [ ] Add simp lemma: `swap_temporal_all_past` showing `swap_temporal (all_past phi) = all_future (swap_temporal phi)`
- [ ] Update `swap_temporal_involution` proof
- [ ] Update `needsPositiveHypotheses` and its simp lemmas: remove `all_future`/`all_past` cases (these are now `imp` at the top level, so they return false)
- [ ] Update `atoms_swap_temporal` proof
- [ ] Update `always`, `sometimes`, `weak_future`, `weak_past` definitions (these use `all_future`/`all_past` which are now `def` -- should still work but verify)
- [ ] Verify: `lake build Bimodal.Syntax.Formula` compiles

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` - Core formula type changes

**Verification**:
- `lake build Bimodal.Syntax.Formula` succeeds
- All 6 constructors remain: `atom`, `bot`, `imp`, `box`, `untl`, `snce`
- `all_future`, `all_past`, `some_future`, `some_past` are `def` not constructors

---

### Phase 2: Syntax Layer - Subformulas and Context [NOT STARTED]

**Goal**: Update `Subformulas.lean`, `Context.lean`, and the `Syntax.lean` barrel file to work with the new definitions.

**Tasks**:
- [ ] Update `Subformulas.lean`: remove `all_past`/`all_future` pattern-match arms from `subformulas` function
- [ ] Remove or rewrite `all_past_inner_mem_subformulas` and `all_future_inner_mem_subformulas` theorems (no longer constructors)
- [ ] Add replacement lemmas for subformula membership of the new abbreviation forms
- [ ] Update `mem_subformulas_of_all_past` and `mem_subformulas_of_all_future` theorems
- [ ] Update all induction proofs in Subformulas.lean that case-split on `all_past`/`all_future`
- [ ] Update `Context.lean` if it pattern-matches on `all_past`/`all_future`
- [ ] Update `Syntax.lean` barrel file if needed
- [ ] Verify: `lake build Bimodal.Syntax` (excluding SubformulaClosure) compiles

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Syntax/Subformulas.lean` - Subformula computation
- `Theories/Bimodal/Syntax/Context.lean` - Context operations
- `Theories/Bimodal/Syntax.lean` - Barrel file

**Verification**:
- `lake build Bimodal.Syntax.Subformulas` succeeds
- Subformula computation handles G/H formulas correctly via expansion

---

### Phase 3: Syntax Layer - SubformulaClosure [NOT STARTED]

**Goal**: Update the 1744-line SubformulaClosure.lean to work without `all_future`/`all_past` constructor arms, using Strategy A (transparent expansion).

**Tasks**:
- [ ] Remove all `all_past`/`all_future` pattern-match arms from closure computation functions
- [ ] Remove all `all_past`/`all_future` induction cases from closure proofs
- [ ] Add simp lemmas for how G/H formulas are handled in the closure (via their expanded untl/snce/imp/bot form)
- [ ] Verify closure still includes the expected subformulas for G(phi) and H(phi) formulas
- [ ] Update any explicit Finset membership proofs that reference `all_future`/`all_past` constructors
- [ ] Fix any termination proofs that relied on the structural recursion through `all_future`/`all_past`
- [ ] Use `sorry` for any proofs that require deep reworking (mark with FIX: comment for future attention)
- [ ] Verify: `lake build Bimodal.Syntax.SubformulaClosure` compiles

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Subformula closure (115 references, 1744 lines)

**Verification**:
- `lake build Bimodal.Syntax.SubformulaClosure` succeeds
- Closure computation handles G/H formulas via their untl/snce expansion

---

### Phase 4: Proof System Layer - Axioms, Derivation, Substitution [NOT STARTED]

**Goal**: Update the proof system: remove `temp_k_dist`/`temp_4` from Axiom inductive, reformulate `temporal_necessitation`, and update Substitution.lean pattern matches.

**Tasks**:
- [ ] Remove `temp_k_dist` and `temp_4` constructors from `Axiom` inductive type (45 -> 43 constructors)
- [ ] Verify all axiom formula expressions that use `all_future`/`all_past` still compile (they reference the `def` versions)
- [ ] Update `temporal_necessitation` in `Derivation.lean`: change from producing `Formula.all_future phi` (constructor) to producing the abbreviation `all_future phi` (which expands to `(untl phi.neg top).neg`)
- [ ] Alternatively, keep `temporal_necessitation` producing `all_future phi` since it is now a `def` that expands -- verify this approach works
- [ ] Update `Derivation.lean` height computation: remove or update any arm that referenced the old constructor form
- [ ] Update `isDenseCompatible` and `isDiscreteCompatible` in Derivation.lean
- [ ] Update `Substitution.lean`: remove `all_past`/`all_future` pattern-match arms from `subst` function
- [ ] Remove `subst_all_past` and `subst_all_future` simp lemmas (no longer constructors)
- [ ] Add replacement substitution lemmas for the abbreviation forms
- [ ] Update `subst_some_past` and `subst_some_future` lemmas for new definitions
- [ ] Update all induction proofs in Substitution.lean that case-split on `all_past`/`all_future`
- [ ] Update axiom substitution proofs (e.g., for `left_mono_until`, `connect_future`, etc.)
- [ ] Add derived theorems `temp_k_dist_derived` and `temp_4_derived` from BX axioms
- [ ] Verify: `lake build Bimodal.ProofSystem` compiles

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Axiom schema (remove temp_k_dist, temp_4)
- `Theories/Bimodal/ProofSystem/Derivation.lean` - Inference rules (temporal_necessitation)
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Substitution operations

**Verification**:
- `lake build Bimodal.ProofSystem` succeeds
- Axiom count reduced from 45 to 43
- `temporal_necessitation` produces G(phi) using the new definition

---

### Phase 5: Semantics Layer - Truth and Validity [NOT STARTED]

**Goal**: Remove `all_future`/`all_past` cases from `truth_at`, add semantic equivalence lemmas bridging old and new definitions.

**Tasks**:
- [ ] Remove `all_past` and `all_future` cases from `truth_at` function (8 -> 6 cases)
- [ ] Add `truth_at_all_future_iff` lemma: `truth_at M Omega tau t (all_future phi) <-> forall s, t < s -> truth_at M Omega tau s phi`
- [ ] Add `truth_at_all_past_iff` lemma: `truth_at M Omega tau t (all_past phi) <-> forall s, s < t -> truth_at M Omega tau s phi`
- [ ] Add `truth_at_some_future_iff` lemma: `truth_at M Omega tau t (some_future phi) <-> exists s, t < s /\ truth_at M Omega tau s phi`
- [ ] Add `truth_at_some_past_iff` lemma: `truth_at M Omega tau t (some_past phi) <-> exists s, s < t /\ truth_at M Omega tau s phi`
- [ ] The `truth_at_all_future_iff` proof must show: `truth_at(neg(untl(neg(phi), top)), t)` iff `forall s > t, phi(s)`. This requires showing the guard `top` is always true and the negation of the existential gives the universal
- [ ] Add `truth_at_top` lemma: `truth_at M Omega tau t top <-> True`
- [ ] Update any existing truth lemmas in Truth.lean that reference `all_future`/`all_past` constructors
- [ ] Update `Validity.lean` if it pattern-matches on `all_future`/`all_past`
- [ ] Verify: `lake build Bimodal.Semantics` compiles

**Timing**: 2 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - Truth evaluation (remove 2 cases, add bridge lemmas)
- `Theories/Bimodal/Semantics/Validity.lean` - Validity definitions

**Verification**:
- `lake build Bimodal.Semantics` succeeds
- Bridge lemmas established for downstream use
- `truth_at` has exactly 6 cases: atom, bot, imp, box, untl, snce

---

### Phase 6: Soundness and Core Metalogic [NOT STARTED]

**Goal**: Update Soundness, SoundnessLemmas, and Core metalogic files (DeductionTheorem, MCSProperties, RestrictedMCS).

**Tasks**:
- [ ] Update `Soundness.lean`: remove `temp_k_dist`/`temp_4` soundness cases (these axioms no longer exist)
- [ ] Update `SoundnessLemmas.lean`: remove pattern matches on `all_future`/`all_past` constructors; use bridge lemmas from Phase 5
- [ ] Update `DiscreteSoundness.lean`: remove `all_future`/`all_past` match arms
- [ ] Update `Metalogic/Core/DeductionTheorem.lean`: remove `all_future`/`all_past` induction cases
- [ ] Update `Metalogic/Core/MCSProperties.lean`: replace `all_future`/`all_past` constructor usage with abbreviation usage
- [ ] Update `Metalogic/Core/RestrictedMCS.lean`: remove pattern matches on removed constructors
- [ ] Verify: `lake build Bimodal.Metalogic.Soundness`, `lake build Bimodal.Metalogic.SoundnessLemmas`, core files compile

**Timing**: 2 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Soundness theorem
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Soundness infrastructure
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - Discrete soundness
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - Deduction theorem
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS properties
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Restricted MCS

**Verification**:
- Core metalogic modules compile successfully
- Soundness proof updated to handle 43 axioms instead of 45

---

### Phase 7: Completeness Pipeline - Bundle and BXCanonical [NOT STARTED]

**Goal**: Update the completeness pipeline: Bundle modules (WitnessSeed, TemporalCoherence, SuccRelation, etc.) and BXCanonical modules (CanonicalChain, Chronicle, Quasimodel, TruthLemma, etc.).

**Tasks**:
- [ ] Update `Bundle/WitnessSeed.lean` (88 refs): remove `all_future`/`all_past` pattern matches; use abbreviation definitions
- [ ] Update `Bundle/TemporalCoherence.lean` (51 refs): remove constructor-based pattern matches
- [ ] Update `Bundle/SuccRelation.lean` (49 refs): replace constructor usage
- [ ] Update `Bundle/CanonicalFrame.lean`, `CanonicalIrreflexivity.lean`, `CanonicalTaskRelation.lean`: remove `all_future`/`all_past` arms
- [ ] Update `Bundle/FMCSDef.lean`, `SuccExistence.lean`, `TemporalContent.lean`: remove constructor references
- [ ] Update `BXCanonical/CanonicalChain.lean`, `CanonicalModel.lean`, `Frame.lean`: remove `all_future`/`all_past` arms
- [ ] Update `BXCanonical/Chronicle/*.lean` (PointInsertion 68 refs, ChronicleConstruction 30 refs, others): remove constructor matches
- [ ] Update `BXCanonical/Quasimodel/*.lean` (Construction, EnrichedClosure, Realization, SubformulaClosure): remove constructor references
- [ ] Update `BXCanonical/TruthLemma.lean`, `OrderedSeedConsistency.lean`, `RootScopedChain.lean`: remove constructor arms
- [ ] Update `BXCanonical/Filtration/DefectChain.lean`, `SigmaOrdering.lean`: remove constructor matches
- [ ] Update `Completeness.lean`: remove any direct constructor references
- [ ] Use `sorry` for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Metalogic.Bundle`, `lake build Bimodal.Metalogic.BXCanonical` compile

**Timing**: 2 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - Witness seed construction (88 refs)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - Temporal coherence (51 refs)
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - Successor relation (49 refs)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - Canonical frame
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Canonical irreflexivity
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - Task relation
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - FMCS definition
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Successor existence
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - Temporal content
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` - Canonical chain
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Canonical model
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` - BX frame
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - Point insertion (68 refs)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` - Chronicle construction
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Countermodel
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` - Counterexample elimination
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` - R relation
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` - Quasimodel construction
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` - Enriched closure
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` - Realization
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` - Quasimodel closure
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` - Truth lemma
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` - Seed consistency
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Root scoped chain
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` - Defect chain
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/SigmaOrdering.lean` - Sigma ordering
- `Theories/Bimodal/Metalogic/Completeness.lean` - Completeness theorem

**Verification**:
- All Bundle and BXCanonical modules compile
- Completeness theorem compiles (possibly with sorry markers)

---

### Phase 8: Decidability, Algebraic, and ConservativeExtension Metalogic [NOT STARTED]

**Goal**: Update the remaining metalogic modules: Decidability (Tableau, SignedFormula, FMP), Algebraic, and ConservativeExtension.

**Tasks**:
- [ ] Update `Decidability/SignedFormula.lean`: remove `all_future`/`all_past` pattern matches from signed formula handling
- [ ] Update `Decidability/Tableau.lean`: remove G/H tableau rules that pattern-match on constructors; add rules for the expanded forms or use simp lemmas
- [ ] Update `Decidability/FMP/TruthPreservation.lean`: remove `all_future`/`all_past` match arms
- [ ] Update `Algebraic/TenseS5Algebra.lean` (38 refs): remove constructor-based pattern matches
- [ ] Update `Algebraic/InteriorOperators.lean`, `LindenbaumQuotient.lean`, `ParametricTruthLemma.lean`, `RestrictedParametricTruthLemma.lean`: remove constructor references
- [ ] Update `ConservativeExtension/ExtFormula.lean` (39 refs): remove `all_future`/`all_past` from extended formula constructors
- [ ] Update `ConservativeExtension/ExtDerivation.lean`, `Lifting.lean` (29 refs), `Substitution.lean`: remove constructor references
- [ ] Use `sorry` for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Metalogic.Decidability`, `lake build Bimodal.Metalogic.Algebraic`, `lake build Bimodal.Metalogic.ConservativeExtension` compile

**Timing**: 2 hours

**Depends on**: 5, 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Signed formulas
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Tableau rules
- `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean` - FMP truth preservation
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` - Tense S5 algebra (38 refs)
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` - Interior operators
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - Lindenbaum quotient
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Parametric truth
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` - Restricted truth
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean` - Extended formula (39 refs)
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` - Extended derivation
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` - Lifting (29 refs)
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` - Extended substitution

**Verification**:
- All Decidability, Algebraic, and ConservativeExtension modules compile
- Tableau rules handle G/H formulas correctly via expansion

---

### Phase 9: Theorems, Automation, and Examples [NOT STARTED]

**Goal**: Update derived theorem files, automation/proof search, and example files.

**Tasks**:
- [ ] Update `Theorems/TemporalDerived.lean`: rewrite derived theorem proofs using new definitions; proofs that used `temp_k_dist`/`temp_4` axioms need reformulation via BX Until/Since axioms
- [ ] Update `Theorems/GeneralizedNecessitation.lean` (30 refs): adapt to new `temporal_necessitation` signature
- [ ] Update `Theorems/Perpetuity/Bridge.lean` (57 refs): remove constructor-based match arms
- [ ] Update `Theorems/Perpetuity/Helpers.lean`: update helper lemmas
- [ ] Update `Theorems/Perpetuity/Principles.lean` (47 refs): update principle proofs
- [ ] Update `Automation/ProofSearch.lean` (35 refs): update heuristic scoring and pattern recognition for G/H formulas
- [ ] Update `Automation/AesopRules.lean`, `Tactics.lean`, `SuccessPatterns.lean`: update tactic support
- [ ] Update `Automation.lean` barrel file if needed
- [ ] Update `Examples/BimodalProofs.lean`, `BimodalProofStrategies.lean` (57 refs): update example proofs
- [ ] Update `Examples/TemporalProofs.lean` (41 refs), `TemporalProofStrategies.lean` (29 refs): update temporal examples
- [ ] Verify: `lake build Bimodal.Theorems`, `lake build Bimodal.Automation`, `lake build Bimodal.Examples` compile

**Timing**: 2 hours

**Depends on**: 7, 8

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Derived temporal theorems
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - Generalized necessitation (30 refs)
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` - Bridge theorems (57 refs)
- `Theories/Bimodal/Theorems/Perpetuity/Helpers.lean` - Perpetuity helpers
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - Perpetuity principles (47 refs)
- `Theories/Bimodal/Automation/ProofSearch.lean` - Proof search (35 refs)
- `Theories/Bimodal/Automation/AesopRules.lean` - Aesop rules
- `Theories/Bimodal/Automation/Tactics.lean` - Tactics
- `Theories/Bimodal/Automation/SuccessPatterns.lean` - Success patterns
- `Theories/Bimodal/Automation.lean` - Automation barrel file
- `Theories/Bimodal/Examples/BimodalProofs.lean` - Bimodal proof examples
- `Theories/Bimodal/Examples/BimodalProofStrategies.lean` - Strategy examples (57 refs)
- `Theories/Bimodal/Examples/TemporalProofs.lean` - Temporal proof examples (41 refs)
- `Theories/Bimodal/Examples/TemporalProofStrategies.lean` - Strategy examples (29 refs)

**Verification**:
- All theorem, automation, and example modules compile
- Derived theorems are provable from the new axiom set

---

### Phase 10: Full Build Validation and Documentation [NOT STARTED]

**Goal**: Run full `lake build`, fix any remaining compilation errors, update documentation, and clean up sorry markers.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Fix any remaining compilation errors across all files
- [ ] Update `Bimodal.lean` barrel file if needed
- [ ] Audit and resolve any `sorry` markers introduced during the refactor (or document them as known limitations with FIX: comments)
- [ ] Update module-level documentation (docstrings at top of Formula.lean, Axioms.lean, Truth.lean, Derivation.lean) to reflect the new 6-constructor design
- [ ] Update the Formula.lean header comment listing 6 constructors instead of 8
- [ ] Verify no regressions in existing test suite: `lake build Tests`
- [ ] Run final `lake build` to confirm clean compilation

**Timing**: 1 hour

**Depends on**: 9

**Files to modify**:
- `Theories/Bimodal/Bimodal.lean` - Top-level barrel file
- Various files with remaining sorry markers
- Module-level documentation in key files

**Verification**:
- `lake build` succeeds with no errors
- `lake build Tests` succeeds
- All sorry markers are either resolved or documented
- Documentation reflects 6-constructor Formula type

## Testing & Validation

- [ ] `lake build` succeeds for the full project after each phase
- [ ] Formula inductive type has exactly 6 constructors: atom, bot, imp, box, untl, snce
- [ ] `all_future`, `all_past`, `some_future`, `some_past` are `def` abbreviations, not constructors
- [ ] Axiom inductive type reduced from 45 to 43 constructors (temp_k_dist and temp_4 removed)
- [ ] Semantic equivalence: `truth_at(all_future phi, t) <-> forall s > t, truth_at(phi, s)` proved as lemma
- [ ] Semantic equivalence: `truth_at(some_future phi, t) <-> exists s > t, truth_at(phi, s)` proved as lemma
- [ ] `temporal_necessitation` correctly produces `G(phi)` formulas
- [ ] `swap_temporal` correctly swaps G/H (via U/S swap) and preserves involution property
- [ ] Soundness, completeness, and decidability modules compile (possibly with sorry markers)
- [ ] Test suite passes: `lake build Tests`
- [ ] Audit of sorry markers: all are documented with FIX: comments

## Artifacts & Outputs

- `specs/116_redefine_ghfp_via_until_since/plans/01_redefine-ghfp-plan.md` (this file)
- Modified `Theories/Bimodal/Syntax/Formula.lean` (core change)
- Modified `Theories/Bimodal/ProofSystem/Axioms.lean` (axiom removal)
- Modified `Theories/Bimodal/Semantics/Truth.lean` (truth evaluation simplification)
- Modified `Theories/Bimodal/ProofSystem/Derivation.lean` (temporal_necessitation update)
- ~70 additional Lean files with pattern-match and constructor reference updates

## Rollback/Contingency

- **Git-based rollback**: Each phase is committed separately; revert to pre-phase commit if a phase introduces unfixable issues
- **Strategy B fallback**: If SubformulaClosure size explosion causes decidability proof failures (Phase 3/8), switch to Strategy B with custom closure handling that treats G/H as atomic for closure purposes
- **Sorry bridge**: If any metalogic proof becomes intractable, use `sorry` with FIX: comment and file a follow-up task for the specific proof repair
- **Axiom preservation**: If removing `temp_k_dist`/`temp_4` causes too many downstream breakages in Phase 4, keep them as axioms initially and derive them as theorems in a separate follow-up task
