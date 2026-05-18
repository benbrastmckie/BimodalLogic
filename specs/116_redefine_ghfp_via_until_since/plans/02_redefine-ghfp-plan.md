# Implementation Plan: Task #116

- **Task**: 116 - Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Status**: [NOT STARTED]
- **Effort**: 35 hours
- **Dependencies**: Task 107 (completed)
- **Research Inputs**: specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md, specs/116_redefine_ghfp_via_until_since/reports/02_team-research.md
- **Artifacts**: plans/02_redefine-ghfp-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Remove `all_future` (G) and `all_past` (H) as primitive constructors from the `Formula` inductive type, reducing it from 8 to 6 constructors. Define F, P, G, H as definitional abbreviations using `untl`/`snce` with `top`, matching Burgess 1982 section 1.1: F(phi)=U(phi,top), P(phi)=S(phi,top), G(phi)=neg(F(neg(phi))), H(phi)=neg(P(neg(phi))). Scope is 103 files with 2398 references and approximately 400 pattern-match arms, but approximately 54 Tier 3 files need no code changes since they use constructor-application syntax that works transparently with `def`. ConservativeExtension module is scoped out (already broken dead code). The task unblocks task 157 (expressive completeness of {S,U}).

### Research Integration

Key findings from two research reports:

**Round 1** (reports/01_redefine-ghfp-research.md): Confirmed semantic equivalence under irreflexive temporal semantics. Identified Strategy A (transparent expansion) as the recommended approach. Documented the `truth_at` multi-step unfolding path and SubformulaClosure risk.

**Round 2** (reports/02_team-research.md, 4 teammates): Corrected scope from 70/1416 to 103 files/2398 references. Recounted pattern-match arms from 122 to approximately 400. Discovered the missed WeakCanonical/Separation subtree (15 files, 492 refs, 260 arms). Established three-tier difficulty classification showing 54 files need no code changes. Identified `@[match_pattern]` as potential 50% effort reduction (needs prototyping). Found 4 inconsistent `top` definitions requiring consolidation. Confirmed `def` (not `abbrev`) for all abbreviations. Identified `temp_k_dist`/`temp_4` derivation as a prerequisite before removal.

### Prior Plan Reference

The prior plan (plans/01_redefine-ghfp-plan.md) had 10 phases at 20 hours. It underestimated by roughly 2x due to: missing the entire WeakCanonical subtree (15 files, 492 refs), omitting the test suite (20 files, 507 refs), undercounting pattern-match arms (122 vs 400), no time for `@[match_pattern]` prototyping, and no time for deriving `temp_k_dist`/`temp_4` before removal. The phase structure was reasonable (core-outward layering) but the scope was incomplete. This revised plan addresses all gaps.

### Roadmap Alignment

Roadmap Phase 2 lists task 116 as part of "Frame hierarchy + axiom cleanup": "redefine G/H/F/P via U/S (task 116). Reduces primitives to {S, U, box, imp, bot}." This task directly advances that roadmap item. Tasks 115 and 124 (predecessors in the Phase 2 sequence) are already completed/archived. Task 126 is abandoned. Task 157 (expressive completeness, Phase 3 prerequisite) is explicitly blocked by task 116.

## Goals & Non-Goals

**Goals**:
- Remove `all_future` and `all_past` from `Formula` inductive type (8 to 6 constructors)
- Define `all_future`, `all_past`, `some_future`, `some_past` as `def` abbreviations using `untl`/`snce` and `top`
- Consolidate 4 inconsistent `top` definitions into canonical `def Formula.top`
- Remove `temp_k_dist` and `temp_4` from `Axiom` inductive (derive as theorems first)
- Prototype `@[match_pattern]` to determine if existing pattern matches survive
- Provide `@[simp]` lemmas for unfolding and re-folding
- Ensure `lake build` passes after each phase
- Update all pattern matches, inductions, and constructor applications across 103 files
- Scope out ConservativeExtension as a separate follow-up task

**Non-Goals**:
- Changing the semantic treatment of `untl`/`snce` (these remain primitive constructors)
- Modifying `box` or any modal operators
- Optimizing SubformulaClosure for smaller closure size (Strategy B deferred; use Strategy A)
- Repairing ConservativeExtension/ExtFormula (dead code; separate task)
- Changing the argument ordering convention for `untl`/`snce`
- Updating Boneyard files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `@[match_pattern]` fails with complex expansion pattern | H | M | Prototype in Phase 1 on a branch; if it fails, proceed with full mechanical refactor (400 arms) |
| SubformulaClosure `Formula.noConfusion` proofs break (G/H both expand to `imp` at top level) | H | H | Redesign distinction proofs using deeper structural analysis instead of `noConfusion` |
| `swap_temporal_involution` proof requires complete rewrite (no G/H induction cases) | M | H | Rewrite using 6-constructor induction with G/H cases as separate lemmas |
| `temp_k_dist`/`temp_4` removal cascade across 100+ references in 36+ files | H | H | Derive as theorems BEFORE removing axiom constructors; update all invocation sites to use derived versions |
| Separation module syntactic predicates semantically change (is_U_free, is_S_free) | M | H | Changes are mathematically correct; update proofs to reflect new correct semantics |
| WeakCanonical/Separation Hierarchy.lean (82 pattern arms) exceeds 2-hour phase | M | M | Dedicate full phase to Separation module; use sorry for deep proof reworks with FIX: comments |
| Derived property changes (`complexity`, `countImplications`) break heuristic automation | M | L | Update ProofSearch heuristics; add re-folding simp lemmas so automation sees G/H forms |
| Multi-step `truth_at` unfolding breaks downstream proofs that relied on direct evaluation | M | H | Establish bridge lemmas (`truth_at_all_future_iff`, etc.) and require all downstream proofs to use them |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4, 5 | 3 |
| 4 | 6, 7, 8 | 4, 5 |
| 5 | 9 | 6, 7, 8 |
| 6 | 10 | 9 |
| 7 | 11 | 10 |
| 8 | 12 | 11 |

Phases within the same wave can execute in parallel.

---

### Phase 1: `@[match_pattern]` Prototype and `top` Consolidation [NOT STARTED]

**Goal**: Determine whether `@[match_pattern]` allows existing pattern matches to survive the constructor-to-def transition. Consolidate the 4 inconsistent `top` definitions into a canonical `def Formula.top`. This phase is informational and shapes the effort in all subsequent phases.

**Tasks**:
- [ ] Create a prototype branch for `@[match_pattern]` testing
- [ ] Add `@[match_pattern] def all_future (phi : Formula) := (some_future phi.neg).neg` (and `all_past`) in a scratch file importing Formula
- [ ] Test whether `| .all_future psi =>` pattern syntax compiles with the `@[match_pattern]` attribute on these definitions
- [ ] Test discrimination: can Lean distinguish `.all_future psi` from a general `.imp` in the same match expression?
- [ ] Document the result: if `@[match_pattern]` works, approximately 200 pattern-match arms survive unchanged; if not, full mechanical refactor is needed
- [ ] Add canonical `def Formula.top : Formula := Formula.bot.imp Formula.bot` to Formula.lean
- [ ] Replace `LindenbaumQuotient.lean:330` local `top_quot` usage to reference `Formula.top`
- [ ] Replace `ChronicleToCountermodel.lean:171` local `top_formula` usage to reference `Formula.top`
- [ ] Replace `TemporalClosure.lean:588` local `Formula.top` abbrev with import of the canonical one
- [ ] Replace `TemporalDerived.lean:61` private `top` abbrev with import of the canonical one
- [ ] Verify: `lake build` for affected files compiles

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` - Add canonical `def Formula.top`
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - Replace local `top_quot`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Replace local `top_formula`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` - Replace local `Formula.top`
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Replace private `top`

**Verification**:
- `@[match_pattern]` viability is documented (pass/fail with examples)
- `Formula.top` exists as a canonical definition
- All 4 local `top` definitions are replaced
- `lake build` for modified files succeeds

---

### Phase 2: Derive `temp_k_dist` and `temp_4` as Theorems [NOT STARTED]

**Goal**: Before removing `temp_k_dist` and `temp_4` from the Axiom inductive, derive them as standalone theorems from the BX Until/Since axioms. This ensures all downstream sites can be migrated to the derived versions before the axiom constructors are removed.

**Tasks**:
- [ ] Create derivation of `temp_k_dist_derived : Derivable (all_future (phi.imp psi)).imp ((all_future phi).imp (all_future psi))` from BX axioms (BX2G/left_mono_until_G + propositional logic)
- [ ] Create derivation of `temp_4_derived : Derivable (all_future phi).imp (all_future (all_future phi))` from BX5 (self_accum_until) + BX6 (absorb_until)
- [ ] Verify both derivations compile with the CURRENT Formula type (G/H still constructors)
- [ ] Replace all ~45 axiom invocations of `temp_k_dist` across the codebase with `temp_k_dist_derived`
- [ ] Replace all ~45 axiom invocations of `temp_4` across the codebase with `temp_4_derived`
- [ ] Replace `temp_4_tactic` in Automation/Tactics.lean with a version using the derived theorem
- [ ] Verify: `lake build` succeeds with all invocations replaced but axiom constructors still present

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Add derived theorems
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - Replace axiom invocations
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - Replace invocations
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Replace invocations
- `Theories/Bimodal/Metalogic/Soundness.lean` - Replace soundness arms
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Replace soundness arms
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - Replace arms
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Replace substitution arms
- `Theories/Bimodal/Automation/Tactics.lean` - Rewrite `temp_4_tactic`
- `Theories/Bimodal/Automation/AesopRules.lean` - Replace axiom references
- Various other files with `temp_k_dist`/`temp_4` invocations (~36 files total)

**Verification**:
- Both derived theorems compile and are sorry-free
- No remaining references to `Axiom.temp_k_dist` or `Axiom.temp_4` as axiom constructors in proofs
- `lake build` succeeds fully

---

### Phase 3: Core Formula Type Redefinition [NOT STARTED]

**Goal**: Remove `all_future` and `all_past` constructors from `Formula`, add definitional abbreviations with `@[simp]` lemmas, and update all functions in Formula.lean. If `@[match_pattern]` worked in Phase 1, apply it to the definitions.

**Tasks**:
- [ ] Remove `all_future` and `all_past` constructors from the `Formula` inductive type (8 to 6 constructors)
- [ ] Redefine `some_future` as `def some_future (phi : Formula) : Formula := Formula.untl phi Formula.top`
- [ ] Redefine `some_past` as `def some_past (phi : Formula) : Formula := Formula.snce phi Formula.top`
- [ ] Redefine `all_future` as `def all_future (phi : Formula) : Formula := (some_future phi.neg).neg`
- [ ] Redefine `all_past` as `def all_past (phi : Formula) : Formula := (some_past phi.neg).neg`
- [ ] If `@[match_pattern]` works (Phase 1 result), add attribute to all four definitions
- [ ] Remove `beq_all_past_eq`, `beq_all_future_eq` helper theorems
- [ ] Update `beq_refl` proof: remove `all_past`/`all_future` induction cases
- [ ] Update `eq_of_beq` proof: remove `all_past`/`all_future` match arms
- [ ] Update `complexity`, `modalDepth`, `temporalDepth`, `countImplications`: remove arms (add simp lemmas for G/H values if needed)
- [ ] Update `atoms` function: remove `all_past`/`all_future` arms
- [ ] Update `swap_temporal`: remove `all_past`/`all_future` arms
- [ ] Add simp lemmas: `swap_temporal_all_future`, `swap_temporal_all_past`
- [ ] Rewrite `swap_temporal_involution` proof using 6-constructor induction
- [ ] Update `needsPositiveHypotheses` and its simp lemmas
- [ ] Update `atoms_swap_temporal` proof
- [ ] Add `@[simp]` lemmas: `all_future_def`, `all_past_def`, `some_future_def`, `some_past_def`, `top_def`
- [ ] Add re-folding `@[simp]` lemmas so `simp` can recognize expanded forms as G/H
- [ ] Remove `temp_k_dist` and `temp_4` constructors from `Axiom` inductive type (now safe since Phase 2 replaced all invocations)
- [ ] Verify: `lake build Bimodal.Syntax.Formula` and `lake build Bimodal.ProofSystem.Axioms` compile

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` - Core formula type changes, simp lemmas
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Remove temp_k_dist, temp_4 constructors

**Verification**:
- `Formula` has exactly 6 constructors: `atom`, `bot`, `imp`, `box`, `untl`, `snce`
- `all_future`, `all_past`, `some_future`, `some_past` are `def` not constructors
- All Formula.lean functions compile
- Axiom inductive has 2 fewer constructors

---

### Phase 4: Syntax Layer - Subformulas, Context, Substitution [NOT STARTED]

**Goal**: Update the remaining syntax files and the proof system layer that depends on formula structure. Remove pattern-match arms, update induction proofs, add replacement lemmas.

**Tasks**:
- [ ] Update `Subformulas.lean`: remove `all_past`/`all_future` pattern-match arms from `subformulas` function
- [ ] Rewrite `all_past_inner_mem_subformulas` and `all_future_inner_mem_subformulas` as theorems about the `def` forms
- [ ] Update all induction proofs in Subformulas.lean
- [ ] Update `Context.lean` if it pattern-matches on `all_past`/`all_future`
- [ ] Update `Substitution.lean`: remove `all_past`/`all_future` pattern-match arms from `subst` function
- [ ] Remove/rewrite `subst_all_past` and `subst_all_future` simp lemmas
- [ ] Add replacement substitution lemmas for the abbreviation forms
- [ ] Update all induction proofs in Substitution.lean
- [ ] Update `Derivation.lean`: temporal_necessitation, height computation, isDenseCompatible, isDiscreteCompatible
- [ ] Update axiom formula expressions in Axioms.lean if any require manual adjustment
- [ ] Verify: `lake build Bimodal.Syntax` and `lake build Bimodal.ProofSystem` compile

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Syntax/Subformulas.lean` - Subformula computation
- `Theories/Bimodal/Syntax/Context.lean` - Context operations
- `Theories/Bimodal/Syntax.lean` - Barrel file
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Substitution operations
- `Theories/Bimodal/ProofSystem/Derivation.lean` - Inference rules, temporal_necessitation

**Verification**:
- `lake build Bimodal.Syntax` succeeds
- `lake build Bimodal.ProofSystem` succeeds
- Substitution distributes correctly through the expanded G/H forms

---

### Phase 5: Semantics Layer and SubformulaClosure [NOT STARTED]

**Goal**: Remove `all_future`/`all_past` cases from `truth_at`, add semantic bridge lemmas, and update SubformulaClosure for Strategy A (transparent expansion). SubformulaClosure is the highest-risk file.

**Tasks**:
- [ ] Remove `all_past` and `all_future` cases from `truth_at` (8 to 6 cases)
- [ ] Add `truth_at_top` lemma: `truth_at M Omega tau t Formula.top <-> True`
- [ ] Add `truth_at_all_future_iff`: `truth_at(all_future phi, t) <-> forall s > t, truth_at(phi, s)`
- [ ] Add `truth_at_all_past_iff`: `truth_at(all_past phi, t) <-> forall s < t, truth_at(phi, s)`
- [ ] Add `truth_at_some_future_iff`: `truth_at(some_future phi, t) <-> exists s > t, truth_at(phi, s)`
- [ ] Add `truth_at_some_past_iff`: `truth_at(some_past phi, t) <-> exists s < t, truth_at(phi, s)`
- [ ] Update `Validity.lean` if it pattern-matches on `all_future`/`all_past`
- [ ] Update SubformulaClosure.lean: remove all `all_past`/`all_future` pattern-match arms from closure computation functions
- [ ] Update SubformulaClosure.lean: remove all `all_past`/`all_future` induction cases from closure proofs
- [ ] Address `Formula.noConfusion` proof breakage: G/H both expand to `imp` at top level; redesign distinction proofs
- [ ] Fix `f_nesting_depth` and `extractFInner` pattern detection: F formulas are now `untl phi Formula.top` (not `imp (all_future ...) bot`)
- [ ] Update deferral closure constants (`G_neg_neg_bot`, `H_neg_neg_bot`) if present
- [ ] Add simp lemmas for how G/H formulas are handled in the closure
- [ ] Use `sorry` for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Semantics` and `lake build Bimodal.Syntax.SubformulaClosure` compile

**Timing**: 4 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - Truth evaluation (remove 2 cases, add bridge lemmas)
- `Theories/Bimodal/Semantics/Validity.lean` - Validity definitions
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Subformula closure (115 references, 1744 lines)

**Verification**:
- `truth_at` has exactly 6 cases: atom, bot, imp, box, untl, snce
- All bridge lemmas compile
- SubformulaClosure compiles (possibly with sorry markers for deep proofs)

---

### Phase 6: Soundness and Core Metalogic [NOT STARTED]

**Goal**: Update Soundness, SoundnessLemmas, DiscreteSoundness, and Core metalogic files (DeductionTheorem, MCSProperties, RestrictedMCS). Remove temp_k_dist/temp_4 soundness proof arms (axioms no longer exist).

**Tasks**:
- [ ] Update `Soundness.lean`: remove `temp_k_dist`/`temp_4` soundness cases
- [ ] Update `SoundnessLemmas.lean`: remove pattern matches on `all_future`/`all_past` constructors; use bridge lemmas from Phase 5
- [ ] Update `DiscreteSoundness.lean`: remove `all_future`/`all_past` match arms
- [ ] Update `DeductionTheorem.lean`: remove `all_future`/`all_past` induction cases
- [ ] Update `MCSProperties.lean`: replace constructor usage with abbreviation usage
- [ ] Update `RestrictedMCS.lean`: remove pattern matches on removed constructors
- [ ] Verify: `lake build Bimodal.Metalogic.Soundness`, core metalogic modules compile

**Timing**: 2 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Soundness theorem
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Soundness infrastructure
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - Discrete soundness
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - Deduction theorem
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS properties
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Restricted MCS

**Verification**:
- Core metalogic modules compile
- Soundness proof handles the reduced axiom set

---

### Phase 7: Decidability and Algebraic Metalogic [NOT STARTED]

**Goal**: Update the Decidability (Tableau, SignedFormula, FMP) and Algebraic modules. These have moderate pattern-match counts and depend on the semantic bridge lemmas.

**Tasks**:
- [ ] Update `Decidability/SignedFormula.lean`: remove `all_future`/`all_past` pattern matches
- [ ] Update `Decidability/Tableau.lean`: remove G/H tableau rules; add rules for expanded forms or use simp lemmas
- [ ] Update `Decidability/FMP/TruthPreservation.lean`: remove `all_future`/`all_past` match arms
- [ ] Update `Algebraic/TenseS5Algebra.lean` (38 refs): remove constructor-based pattern matches
- [ ] Update `Algebraic/InteriorOperators.lean`: remove constructor references
- [ ] Update `Algebraic/LindenbaumQuotient.lean`: remove constructor references (top already consolidated in Phase 1)
- [ ] Update `Algebraic/ParametricTruthLemma.lean`, `RestrictedParametricTruthLemma.lean`: remove constructor references
- [ ] Update `Algebraic/UltrafilterFrame.lean` (82 refs, untracked new file): remove constructor references
- [ ] Update remaining Algebraic files: `ParametricCanonical.lean`, `ParametricCompleteness.lean`, `ParametricHistory.lean`, `UltrafilterMCS.lean`, `BooleanStructure.lean`, `AlgebraicCompleteness.lean`
- [ ] Use `sorry` for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Metalogic.Decidability` and `lake build Bimodal.Metalogic.Algebraic` compile

**Timing**: 2.5 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Signed formulas
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Tableau rules
- `Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean` - FMP truth preservation
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` - Tense S5 algebra
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` - Interior operators
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` - Lindenbaum quotient
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Parametric truth
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` - Restricted truth
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterFrame.lean` - Ultrafilter frame
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` - Parametric canonical
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCompleteness.lean` - Parametric completeness
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` - Parametric history
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - Ultrafilter MCS
- `Theories/Bimodal/Metalogic/Algebraic/BooleanStructure.lean` - Boolean structure
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicCompleteness.lean` - Algebraic completeness

**Verification**:
- All Decidability and Algebraic modules compile
- Tableau rules handle G/H formulas via expansion or bridge lemmas

---

### Phase 8: Completeness Pipeline - Bundle and BXCanonical [NOT STARTED]

**Goal**: Update the completeness pipeline: Bundle modules (WitnessSeed, TemporalCoherence, SuccRelation, etc.) and BXCanonical modules (CanonicalChain, Chronicle, Quasimodel, TruthLemma, etc.). This is the largest single module group by reference count.

**Tasks**:
- [ ] Update `Bundle/WitnessSeed.lean` (88 refs): remove `all_future`/`all_past` pattern matches
- [ ] Update `Bundle/TemporalCoherence.lean` (51 refs): remove constructor-based pattern matches
- [ ] Update `Bundle/SuccRelation.lean` (49 refs): replace constructor usage
- [ ] Update `Bundle/CanonicalFrame.lean`, `CanonicalIrreflexivity.lean`, `CanonicalTaskRelation.lean`: remove arms
- [ ] Update `Bundle/FMCSDef.lean`, `SuccExistence.lean`, `TemporalContent.lean`: remove references
- [ ] Update `BXCanonical/CanonicalChain.lean`, `CanonicalModel.lean`, `Frame.lean`: remove arms
- [ ] Update `BXCanonical/Chronicle/*.lean` (PointInsertion 68 refs, ChronicleConstruction 30 refs, others): remove matches
- [ ] Update `BXCanonical/Quasimodel/*.lean` (Construction, EnrichedClosure, Realization, SubformulaClosure): remove references
- [ ] Update `BXCanonical/TruthLemma.lean`, `OrderedSeedConsistency.lean`, `RootScopedChain.lean`: remove arms
- [ ] Update `BXCanonical/Filtration/DefectChain.lean`, `SigmaOrdering.lean`: remove matches
- [ ] Update `Completeness.lean`: remove any direct constructor references
- [ ] Use `sorry` for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Metalogic.Bundle` and `lake build Bimodal.Metalogic.BXCanonical` compile

**Timing**: 4 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - Witness seed (88 refs)
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
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` - Counterexample
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

### Phase 9: WeakCanonical and Separation Module [NOT STARTED]

**Goal**: Update the entire WeakCanonical subtree, including the Separation module (15 files, 492 refs, 260 pattern-match arms). This was entirely missed in the original plan and contains the hardest files: Hierarchy.lean (82 arms), TemporalClosure.lean (58 arms), and Defs.lean (36 arms).

**Tasks**:
- [ ] Update `Separation/Defs.lean` (45 refs, 36 arms): update `is_U_free`, `is_S_free`, `is_future_only`, `is_past_only`, `is_syntactically_separated` to reflect new semantics where G/H contain U/S
- [ ] Update `Separation/Hierarchy.lean` (115 refs, 82 arms): massive structural inductions; use sorry for deep proof reworks
- [ ] Update `Separation/TemporalClosure.lean` (111 refs, 58 arms): leverage existing `expand_temporal` proof asset and semantic equivalence proofs (`all_past_equiv_neg_snce`, `all_future_equiv_neg_untl`)
- [ ] Update `Separation/Duality.lean` (24 refs, 20 arms): remove constructor pattern matches
- [ ] Update `Separation/DedekindZ.lean` (24 refs, 20 arms): remove constructor pattern matches
- [ ] Update `Separation/SeparationThm.lean` (24 refs, 4 arms): remove constructor matches
- [ ] Update `Separation/FormulaOps.lean`, `Eliminations.lean`, `DualEliminations.lean`, `Distributivity.lean`, `NegationEquiv.lean`, `NormalForm.lean`, `IntHelpers.lean`: remove all G/H constructor arms
- [ ] Update `Table.lean` (12 refs, 10 arms): remove constructor matches
- [ ] Update `TruthLemma.lean` (10 refs, 2 arms): remove constructor matches
- [ ] Update `ExpressiveCompleteness.lean` (25 refs, 20 arms): remove constructor matches
- [ ] Update remaining WeakCanonical files: `ReflexiveCanonical.lean` (84 refs, 0 arms), `FrameProperties.lean`, `IntegerModel.lean`, `MonadicFO.lean`, `NEquivalence.lean`, `NormalForm.lean`, `OrderedSum.lean`, `ChronicleExtraction.lean`, `Transfer.lean`, `WeakCanonical.lean`
- [ ] Update `Separation.lean` barrel file
- [ ] Use `sorry` for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical` compiles

**Timing**: 6 hours

**Depends on**: 6, 7, 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` - Syntactic predicates (36 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` - Hierarchy theorem (82 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/TemporalClosure.lean` - Temporal closure (58 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Duality.lean` - Duality (20 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` - DedekindZ (20 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` - Separation theorem (4 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/FormulaOps.lean` - Formula operations
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` - Eliminations
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DualEliminations.lean` - Dual eliminations
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Distributivity.lean` - Distributivity
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NegationEquiv.lean` - Negation equivalences
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` - Normal form
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/IntHelpers.lean` - Integer helpers
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` - Table (10 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean` - Truth lemma
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` - Expressive completeness (20 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Reflexive canonical (84 refs, 0 arms)
- `Theories/Bimodal/Metalogic/WeakCanonical/FrameProperties.lean` - Frame properties
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` - Integer model
- `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` - Monadic FO
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - N-equivalence
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` - Normal form
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Ordered sum
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` - Chronicle extraction
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Transfer
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation.lean` - Barrel file
- `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` - Barrel file

**Verification**:
- All WeakCanonical modules compile (possibly with sorry markers for Hierarchy/TemporalClosure deep proofs)
- Syntactic predicates reflect correct new semantics (G contains U, H contains S)

---

### Phase 10: Theorems, Automation, and Examples [NOT STARTED]

**Goal**: Update derived theorem files, automation/proof search, and example files. These are mostly Tier 2/3 files with constructor-application usage that may work transparently.

**Tasks**:
- [ ] Update `Theorems/TemporalDerived.lean`: rewrite derived theorem proofs using new definitions; adapt proofs that used old `temp_k_dist`/`temp_4` references
- [ ] Update `Theorems/GeneralizedNecessitation.lean` (30 refs): adapt to `temporal_necessitation`
- [ ] Update `Theorems/Perpetuity/Bridge.lean` (57 refs): remove constructor-based match arms
- [ ] Update `Theorems/Perpetuity/Helpers.lean`: update helper lemmas
- [ ] Update `Theorems/Perpetuity/Principles.lean` (47 refs): update principle proofs
- [ ] Update `Automation/ProofSearch.lean` (35 refs): update heuristic scoring and pattern recognition for G/H formulas (they are now `imp` at top level)
- [ ] Update `Automation/AesopRules.lean`, `Tactics.lean`, `SuccessPatterns.lean`: update tactic support
- [ ] Update `Automation.lean` barrel file
- [ ] Update `Examples/BimodalProofs.lean`, `BimodalProofStrategies.lean` (57 refs): update example proofs
- [ ] Update `Examples/TemporalProofs.lean` (41 refs), `TemporalProofStrategies.lean` (29 refs): update temporal examples
- [ ] Verify: `lake build Bimodal.Theorems`, `lake build Bimodal.Automation`, `lake build Bimodal.Examples` compile

**Timing**: 2.5 hours

**Depends on**: 9

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Derived temporal theorems
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - Generalized necessitation
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` - Bridge theorems
- `Theories/Bimodal/Theorems/Perpetuity/Helpers.lean` - Perpetuity helpers
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - Perpetuity principles
- `Theories/Bimodal/Automation/ProofSearch.lean` - Proof search
- `Theories/Bimodal/Automation/AesopRules.lean` - Aesop rules
- `Theories/Bimodal/Automation/Tactics.lean` - Tactics
- `Theories/Bimodal/Automation/SuccessPatterns.lean` - Success patterns
- `Theories/Bimodal/Automation.lean` - Automation barrel file
- `Theories/Bimodal/Examples/BimodalProofs.lean` - Bimodal proofs
- `Theories/Bimodal/Examples/BimodalProofStrategies.lean` - Strategy examples
- `Theories/Bimodal/Examples/TemporalProofs.lean` - Temporal proofs
- `Theories/Bimodal/Examples/TemporalProofStrategies.lean` - Strategy examples

**Verification**:
- All theorem, automation, and example modules compile
- Derived theorems are provable from the new definitions
- Proof search handles G/H forms correctly

---

### Phase 11: Test Suite [NOT STARTED]

**Goal**: Update the test suite (20 files, 507 references). Most test files use constructor-application syntax and may compile without changes, but formula generators and property tests need updates.

**Tasks**:
- [ ] Update `Syntax/FormulaTest.lean`: update constructor-based tests
- [ ] Update `Syntax/FormulaPropertyTest.lean`: update property tests (may reference 8 constructors)
- [ ] Update `Syntax/ContextTest.lean`: update context tests
- [ ] Update `Property/Generators.lean`: update formula generators (currently generate `all_future`/`all_past` constructors; must generate via `def` forms)
- [ ] Update `ProofSystem/AxiomsTest.lean`: remove `temp_k_dist`/`temp_4` test cases
- [ ] Update `ProofSystem/DerivationTest.lean`, `DerivationPropertyTest.lean`, `DerivationBenchmark.lean`: update derivation tests
- [ ] Update `Semantics/TruthTest.lean`, `TaskFrameTest.lean`, `SemanticPropertyTest.lean`, `SemanticBenchmark.lean`: update truth evaluation tests
- [ ] Update `Theorems/PropositionalTest.lean`, `PerpetuityTest.lean`, `ModalS4Test.lean`, `ModalS5Test.lean`: update theorem tests
- [ ] Update `Automation/*.lean` test files: update automation tests
- [ ] Update `Integration/*.lean` test files: update integration tests
- [ ] Update `BimodalTest.lean` barrel file and `Property.lean`
- [ ] Verify: `lake build Tests` succeeds

**Timing**: 2 hours

**Depends on**: 10

**Files to modify**:
- `Tests/BimodalTest/Syntax/FormulaTest.lean` - Formula tests
- `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` - Formula property tests
- `Tests/BimodalTest/Syntax/ContextTest.lean` - Context tests
- `Tests/BimodalTest/Property/Generators.lean` - Formula generators
- `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` - Axiom tests
- `Tests/BimodalTest/ProofSystem/DerivationTest.lean` - Derivation tests
- `Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean` - Derivation property tests
- `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` - Derivation benchmarks
- `Tests/BimodalTest/Semantics/TruthTest.lean` - Truth tests
- `Tests/BimodalTest/Semantics/TaskFrameTest.lean` - Task frame tests
- `Tests/BimodalTest/Semantics/SemanticPropertyTest.lean` - Semantic property tests
- `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` - Semantic benchmarks
- `Tests/BimodalTest/Theorems/PropositionalTest.lean` - Propositional tests
- `Tests/BimodalTest/Theorems/PerpetuityTest.lean` - Perpetuity tests
- `Tests/BimodalTest/Theorems/ModalS4Test.lean` - Modal S4 tests
- `Tests/BimodalTest/Theorems/ModalS5Test.lean` - Modal S5 tests
- `Tests/BimodalTest/Automation/*.lean` - Automation tests
- `Tests/BimodalTest/Integration/*.lean` - Integration tests
- `Tests/BimodalTest.lean` - Test barrel file
- `Tests/BimodalTest/Property.lean` - Property barrel file

**Verification**:
- `lake build Tests` succeeds
- Formula generators produce valid G/H formulas via the new definitions
- No test references old constructor forms

---

### Phase 12: Full Build Validation and Cleanup [NOT STARTED]

**Goal**: Run full `lake build`, fix remaining compilation errors, audit sorry markers, update documentation. Scope ConservativeExtension out to a follow-up task.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Fix any remaining compilation errors across all files
- [ ] Scope out ConservativeExtension/ExtFormula as dead code: add a comment or move to Boneyard (it has structural incompatibility -- no `untl`/`snce` constructors, uses `String` atoms vs `Atom`)
- [ ] Audit all `sorry` markers introduced during the refactor: document each with FIX: comment
- [ ] Count total sorries before vs after refactor to ensure no regression
- [ ] Update module-level documentation (docstrings at top of Formula.lean, Axioms.lean, Truth.lean, Derivation.lean) to reflect the 6-constructor design
- [ ] Update Formula.lean header comment listing 6 constructors
- [ ] Update `Bimodal.lean` barrel file if needed
- [ ] Run final `lake build` to confirm clean compilation
- [ ] Create follow-up task for ConservativeExtension repair/archival

**Timing**: 2 hours

**Depends on**: 11

**Files to modify**:
- `Theories/Bimodal/Bimodal.lean` - Top-level barrel file
- `Theories/Bimodal/Metalogic/ConservativeExtension/*.lean` - Mark as dead code or move to Boneyard
- Various files with remaining sorry markers
- Module-level documentation in key files

**Verification**:
- `lake build` succeeds with no errors
- `lake build Tests` succeeds
- All sorry markers are documented with FIX: comments
- Sorry count is tracked (before vs after)
- ConservativeExtension is scoped out with documented justification
- Documentation reflects 6-constructor Formula type

## Testing & Validation

- [ ] `lake build` succeeds for the full project after each phase
- [ ] `Formula` inductive type has exactly 6 constructors: atom, bot, imp, box, untl, snce
- [ ] `all_future`, `all_past`, `some_future`, `some_past` are `def` abbreviations, not constructors
- [ ] `Formula.top` exists as a canonical definition (not scattered local definitions)
- [ ] `temp_k_dist_derived` and `temp_4_derived` are sorry-free theorems
- [ ] Axiom inductive reduced by 2 constructors (temp_k_dist, temp_4 removed)
- [ ] Semantic equivalence: `truth_at(all_future phi, t) <-> forall s > t, truth_at(phi, s)` proved
- [ ] Semantic equivalence: `truth_at(some_future phi, t) <-> exists s > t, truth_at(phi, s)` proved
- [ ] `temporal_necessitation` correctly produces G(phi) formulas
- [ ] `swap_temporal` correctly swaps G/H (via U/S swap) and preserves involution property
- [ ] Soundness, completeness, and decidability modules compile
- [ ] WeakCanonical/Separation module compiles with correct syntactic predicate semantics
- [ ] Test suite passes: `lake build Tests`
- [ ] `@[match_pattern]` decision is documented
- [ ] Audit of sorry markers: all are documented with FIX: comments, no net sorry increase

## Artifacts & Outputs

- `specs/116_redefine_ghfp_via_until_since/plans/02_redefine-ghfp-plan.md` (this file)
- Modified `Theories/Bimodal/Syntax/Formula.lean` (core change: 8 to 6 constructors)
- Modified `Theories/Bimodal/ProofSystem/Axioms.lean` (axiom removal: temp_k_dist, temp_4)
- Modified `Theories/Bimodal/Semantics/Truth.lean` (truth evaluation: 8 to 6 cases, bridge lemmas)
- Modified `Theories/Bimodal/ProofSystem/Derivation.lean` (temporal_necessitation update)
- ~100 additional Lean files with pattern-match and constructor reference updates
- Follow-up task for ConservativeExtension repair/archival

## Rollback/Contingency

- **Git-based rollback**: Each phase is committed separately; revert to pre-phase commit if a phase introduces unfixable issues
- **Phase 1 pivot**: If `@[match_pattern]` fails, the plan proceeds with full mechanical refactor (additional 200 pattern-match arm removals absorbed into later phases)
- **Phase 2 safety**: temp_k_dist/temp_4 are derived BEFORE removal from Axiom inductive. If derivation fails, keep them as axiom constructors and defer removal
- **Strategy B fallback**: If SubformulaClosure size explosion causes decidability proof failures (Phase 5), switch to Strategy B with custom closure handling that treats G/H as atomic for closure purposes
- **Sorry bridge**: If any metalogic proof becomes intractable, use `sorry` with FIX: comment and file a follow-up task for the specific proof repair
- **ConservativeExtension exclusion**: Already scoped out. If any import chain pulls it in, stub it out or add `sorry` markers
- **Separation module risk**: If Hierarchy.lean (82 arms) proves intractable within the 6-hour phase, split into a sub-phase with sorry markers and file a follow-up task
