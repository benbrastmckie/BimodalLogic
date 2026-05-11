# Implementation Plan: Redefine G, H, F, P via Until and Since

- **Task**: 116 - Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: Task 107 (completed)
- **Research Inputs**: reports/01_redefine-ghfp-research.md
- **Artifacts**: plans/01_redefine-ghfp-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove `all_future` (G) and `all_past` (H) as primitive constructors from the `Formula` inductive type, reducing it from 8 to 6 constructors. Redefine F(phi) = U(phi, top), P(phi) = S(phi, top), G(phi) = neg(F(neg(phi))), H(phi) = neg(P(neg(phi))) as definitional abbreviations matching Burgess 1982 section 1.1. Remove `temp_k_dist` and `temp_4` from the `Axiom` inductive type (they become derivable). Update ~70 non-Boneyard files with ~138 pattern-match arms and ~1400 total references. Done when `lake build` succeeds with no new sorries beyond those already present.

### Research Integration

The research report (reports/01_redefine-ghfp-research.md) identified:
- Semantic equivalence is verified: truth_at(neg(U(neg(phi),top)), t) = forall s > t, phi(s)
- 70 non-Boneyard files affected with ~1416 references
- SubformulaClosure (115 refs) is the highest-risk file -- G(phi) subformulas grow from 2 to 6+
- Two axioms (temp_k_dist, temp_4) become derivable from BX axioms
- temporal_necessitation produces `all_future phi` and needs reformulation
- Strategy A (transparent abbreviations) recommended first for SubformulaClosure

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the Burgess axiom alignment effort. The ROADMAP.md notes the proof system has 45 BX axioms; this task reduces the axiom count to 43 by deriving temp_k_dist and temp_4. It also simplifies the Formula type from 8 to 6 constructors, improving alignment with the mathematical literature.

## Goals & Non-Goals

**Goals**:
- Remove `all_past` and `all_future` constructors from the `Formula` inductive type
- Define `top`, `some_future`, `some_past`, `all_future`, `all_past` as `def` abbreviations
- Remove `temp_k_dist` and `temp_4` from `Axiom` inductive; derive them as theorems
- Reformulate `temporal_necessitation` for the new definitions
- Update all pattern matches, constructor applications, and simp references across the codebase
- Pass `lake build` with no new sorries

**Non-Goals**:
- Removing `box` as a primitive (box remains the S5 modal operator)
- Implementing Strategy B (smart abbreviations) for SubformulaClosure unless Strategy A fails
- Updating Boneyard files beyond minimal compilation fixes
- Proving existing sorries that predate this task
- Changing the semantics of any operator (all changes are definitional)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| SubformulaClosure size explosion (G(phi) grows from 2 to 6+ subformulas) | H | M | Start with Strategy A (transparent). If decidability proofs break, add custom closure lemmas that treat G/H patterns as atomic |
| Cascade of proof breakage across 70 files | H | H | Strict layered approach: fix each layer completely before moving to the next; `lake build` after each phase |
| temporal_necessitation reformulation complexity | M | M | The rule currently produces `all_future phi`; after change it must produce the expanded form. Add a bridge lemma first |
| Performance regression from larger term representations | L | L | G(phi) expands from 1 constructor to 5. Monitor `lake build` times; if problematic, add definitional unfolding control |
| Decidability/FMP pipeline breakage (tableau rules pattern-match on G/H) | M | M | Phase 5 addresses this specifically; may require adding G/H-pattern recognition to tableau |
| Proof terms referencing temp_k_dist/temp_4 across metalogic | M | H | Derive these as theorems early (Phase 2) so all downstream code can reference the derived versions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases are strictly sequential because each layer depends on the previous layer compiling.

---

### Phase 1: Core Syntax Layer [NOT STARTED]

**Goal**: Remove `all_past`/`all_future` constructors from `Formula`, add definitional abbreviations, and fix all Syntax files to compile.

**Tasks**:
- [ ] Remove `all_past` and `all_future` constructors from the `Formula` inductive type in `Formula.lean`
- [ ] Add `def top : Formula := Formula.bot.imp Formula.bot`
- [ ] Add `def some_future (phi : Formula) : Formula := Formula.untl phi top`
- [ ] Add `def some_past (phi : Formula) : Formula := Formula.snce phi top`
- [ ] Add `def all_future (phi : Formula) : Formula := (some_future phi.neg).neg`
- [ ] Add `def all_past (phi : Formula) : Formula := (some_past phi.neg).neg`
- [ ] Remove the old `some_future` and `some_past` definitions (currently `phi.neg.all_future.neg` and `phi.neg.all_past.neg`) and replace with the new Burgess definitions
- [ ] Add `@[simp]` lemmas: `all_future_def`, `all_past_def`, `some_future_def`, `some_past_def`, `top_def`
- [ ] Remove `beq_all_past_eq`, `beq_all_future_eq` helper theorems; remove corresponding arms from `beq_refl` and `eq_of_beq`
- [ ] Remove `all_past`/`all_future` arms from `complexity`, `modalDepth`, `temporalDepth`, `countImplications`
- [ ] Add simp lemmas for complexity/depth/count through the new definitions (e.g., `complexity_all_future`)
- [ ] Update `swap_temporal` to remove `all_past`/`all_future` arms (swap now only needs `untl <-> snce`; G/H swap follows automatically from their definitions)
- [ ] Fix `swap_temporal_involution` proof
- [ ] Remove `needsPositiveHypotheses_all_future` and `needsPositiveHypotheses_all_past` simp lemmas; update `needsPositiveHypotheses` if it pattern-matches on G/H
- [ ] Update `Subformulas.lean`: remove `all_past`/`all_future` arms from `subformulas`, remove `all_past_inner_mem_subformulas`/`all_future_inner_mem_subformulas` theorems, add equivalent lemmas for the new definitions
- [ ] Update `SubformulaClosure.lean`: remove direct pattern-match arms for `all_past`/`all_future`, update `closure_all_past`/`closure_all_future` to work with the new definitions, update `f_nesting_depth` and related functions
- [ ] Update `Atom.lean` or `Context.lean` if they reference `all_future`/`all_past` (verify)
- [ ] Run `lake build Bimodal.Syntax` to verify syntax layer compiles

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` - Remove 2 constructors, add 5 definitions, update all functions and proofs
- `Theories/Bimodal/Syntax/Subformulas.lean` - Remove 2 pattern-match arms, update membership lemmas
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Major rewrite of closure computation and properties (115 refs)
- `Theories/Bimodal/Syntax/BigConj.lean` - Update if it references G/H constructors

**Verification**:
- `lake build Bimodal.Syntax` compiles without errors
- All `@[simp]` lemmas are present and usable
- `swap_temporal_involution` still holds

---

### Phase 2: Proof System Layer [NOT STARTED]

**Goal**: Remove `temp_k_dist` and `temp_4` from `Axiom`, reformulate `temporal_necessitation`, derive the removed axioms as theorems, and fix all ProofSystem files.

**Tasks**:
- [ ] Remove `temp_k_dist` and `temp_4` constructors from the `Axiom` inductive type in `Axioms.lean`
- [ ] Update all remaining axiom expressions that reference `.all_future` or `.all_past` to use the new `def all_future`/`all_past` (verify they still construct the same formulas)
- [ ] Update `temporal_necessitation` in `Derivation.lean`: currently produces `Formula.all_future phi`; update to produce the expanded `(some_future phi.neg).neg` or add a bridge that connects the new `def all_future` to the derivation output
- [ ] Add derived theorem `temp_k_dist_derived`: prove `G(phi -> psi) -> (G(phi) -> G(psi))` from BX axioms
- [ ] Add derived theorem `temp_4_derived`: prove `G(phi) -> G(G(phi))` from BX axioms
- [ ] Update `Substitution.lean`: remove `all_past`/`all_future` arms from `subst` function, add `subst_all_future`/`subst_all_past` lemmas for the new definitions, update `axiom_subst_invariant`
- [ ] Update `LinearityDerivedFacts.lean` if it references G/H constructors
- [ ] Run `lake build Bimodal.ProofSystem` to verify

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Remove 2 axiom constructors, verify remaining axiom expressions
- `Theories/Bimodal/ProofSystem/Derivation.lean` - Update `temporal_necessitation` output type
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Remove pattern-match arms, update simp lemmas
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` - Update references

**Verification**:
- `lake build Bimodal.ProofSystem` compiles without errors
- `temp_k_dist_derived` and `temp_4_derived` are proven (or marked sorry with clear justification)
- All axiom expression formulas unchanged semantically

---

### Phase 3: Semantics Layer [NOT STARTED]

**Goal**: Remove `all_past`/`all_future` cases from `truth_at`, prove semantic equivalence lemmas, and fix all Semantics files.

**Tasks**:
- [ ] Remove `all_past` and `all_future` match arms from `truth_at` in `Truth.lean` (reduce from 8 to 6 cases)
- [ ] Prove `truth_at_all_future_iff`: `truth_at M Omega tau t (all_future phi) <-> forall s, t < s -> truth_at M Omega tau s phi`
- [ ] Prove `truth_at_all_past_iff`: `truth_at M Omega tau t (all_past phi) <-> forall s, s < t -> truth_at M Omega tau s phi`
- [ ] Prove `truth_at_some_future_iff`: `truth_at M Omega tau t (some_future phi) <-> exists s, t < s /\ truth_at M Omega tau s phi`
- [ ] Prove `truth_at_some_past_iff`: `truth_at M Omega tau t (some_past phi) <-> exists s, s < t /\ truth_at M Omega tau s phi`
- [ ] Prove `truth_at_top_iff`: `truth_at M Omega tau t top <-> True`
- [ ] Update existing `truth_at_all_past_unfold` and `truth_at_all_future_unfold` lemmas
- [ ] Update `truth_at_swap_temporal` proof (currently has `all_past`/`all_future` induction arms)
- [ ] Update `truth_at_monotone` or similar proofs in `Truth.lean`
- [ ] Update `Validity.lean` if it pattern-matches on G/H
- [ ] Update `TaskModel.lean`, `TaskFrame.lean`, `WorldHistory.lean` if they reference G/H constructors
- [ ] Run `lake build Bimodal.Semantics` to verify

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - Remove 2 cases from truth_at, add 5+ equivalence lemmas
- `Theories/Bimodal/Semantics/Validity.lean` - Update if needed
- `Theories/Bimodal/Semantics/TaskModel.lean` - Verify no direct constructor references
- `Theories/Bimodal/Semantics/TaskFrame.lean` - Verify no direct constructor references
- `Theories/Bimodal/Semantics/WorldHistory.lean` - Verify no direct constructor references

**Verification**:
- `lake build Bimodal.Semantics` compiles without errors
- All `_iff` lemmas proven
- Semantic equivalence between old and new definitions established

---

### Phase 4: Metalogic Layer [NOT STARTED]

**Goal**: Update Soundness, Completeness, and all supporting metalogic files (45 affected files across 9 subdirectories).

**Tasks**:
- [ ] Update `SoundnessLemmas.lean`: remove `temp_k_dist`/`temp_4` soundness proof match arms, update `axiom_temp_k_dist_valid`/`axiom_temp_4_valid` references (these become derived theorem validity proofs), remove `all_future`/`all_past` induction arms from all soundness lemmas
- [ ] Update `Soundness.lean`, `DenseSoundness.lean`, `DiscreteSoundness.lean` references
- [ ] Update `Metalogic/Core/` files (3 files): `MCSProperties.lean` (update `temp_4_past`, `all_future_all_future` etc.), `MaximalConsistent.lean`, `RestrictedMCS.lean`
- [ ] Update `Metalogic/Bundle/` files (9 files): `WitnessSeed.lean` (88 refs -- most complex), `TemporalCoherence.lean` (51 refs), `SuccRelation.lean` (49 refs), and 6 others
- [ ] Update `Metalogic/BXCanonical/` files (17 files across Chronicle, Quasimodel, Filtration subdirs): update pattern matches and constructor references
- [ ] Update `Metalogic/ConservativeExtension/` files (4 files): `ExtFormula.lean` (39 refs), `Lifting.lean` (29 refs), and others
- [ ] Update `Metalogic/Algebraic/` files (5 files): `TenseS5Algebra.lean` (38 refs), `LindenbaumQuotient.lean` (update temp_k_dist sorry references), `InteriorOperators.lean`
- [ ] Update `Metalogic/Decidability/` files (3 files): tableau rules that pattern-match on G/H, FMP truth preservation
- [ ] Update `Metalogic/Relational/` if affected
- [ ] Update `Completeness.lean` and `Metalogic.lean` roll-up files
- [ ] Run `lake build Bimodal.Metalogic` to verify

**Timing**: 5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Remove match arms for removed axioms and constructors
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - Update temp_4 references
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - 88 references to update
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - 51 references
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - 49 references
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - 68 references
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtFormula.lean` - 39 references
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` - 38 references
- Plus ~35 additional metalogic files with fewer references each

**Verification**:
- `lake build Bimodal.Metalogic` compiles without errors
- No new sorries introduced (existing sorries preserved as-is)
- Soundness proofs still complete (sorry-free)

---

### Phase 5: Theorems, Examples, and Automation [NOT STARTED]

**Goal**: Update all theorem files, example files, and automation/tactic files.

**Tasks**:
- [ ] Update `Theorems/TemporalDerived.lean`: reprove derived temporal theorems using new definitions; update proofs that previously relied on temp_k_dist/temp_4 as axioms
- [ ] Update `Theorems/Perpetuity/Bridge.lean` (57 refs) and `Theorems/Perpetuity/Principles.lean` (47 refs)
- [ ] Update `Theorems/Perpetuity.lean` roll-up
- [ ] Update `Theorems/GeneralizedNecessitation.lean` (30 refs): update temporal generalized necessitation proofs
- [ ] Update `Theorems/Combinators.lean`, `Theorems/ModalS4.lean`, `Theorems/ModalS5.lean`, `Theorems/Propositional.lean`
- [ ] Update `Examples/BimodalProofStrategies.lean` (57 refs) and `Examples/TemporalProofs.lean` (41 refs)
- [ ] Update `Examples/TemporalProofStrategies.lean` (29 refs), `Examples/BimodalProofs.lean`, `Examples/Demo.lean`
- [ ] Update `Automation/ProofSearch.lean` (35 refs), `Automation/Tactics.lean`, `Automation/AesopRules.lean`, `Automation/SuccessPatterns.lean`
- [ ] Update `FrameConditions/` files if they reference G/H constructors
- [ ] Run `lake build Bimodal.Theorems Bimodal.Examples Bimodal.Automation` to verify

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Reprove derived theorems
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` - 57 references
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - 47 references
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - 30 references
- `Theories/Bimodal/Examples/BimodalProofStrategies.lean` - 57 references
- `Theories/Bimodal/Examples/TemporalProofs.lean` - 41 references
- `Theories/Bimodal/Automation/ProofSearch.lean` - 35 references
- Plus ~10 additional files

**Verification**:
- `lake build Bimodal.Theorems Bimodal.Examples Bimodal.Automation` compiles
- Example proofs still produce correct results
- Proof search tactics still function

---

### Phase 6: Integration, Boneyard, and Full Build [NOT STARTED]

**Goal**: Fix remaining compilation issues, update Boneyard minimally, update roll-up files, and achieve a clean full `lake build`.

**Tasks**:
- [ ] Update Boneyard files minimally for compilation (add imports for new `all_future`/`all_past` definitions where needed, or mark with sorry if too complex)
- [ ] Update `Tests/BimodalTest/` test files
- [ ] Update all roll-up `.lean` files (`Bimodal.lean`, `Syntax.lean`, `ProofSystem.lean`, `Semantics.lean`, `Metalogic.lean`, `Theorems.lean`, `Examples.lean`, `Automation.lean`)
- [ ] Update doc comments and module-level documentation in `Formula.lean` to reflect that G/H are now definitional abbreviations
- [ ] Run full `lake build` and resolve any remaining errors
- [ ] Verify no new sorries by comparing sorry count before and after
- [ ] Review that swap_temporal still has correct involution behavior through the new definitions

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Boneyard/` - Minimal compilation fixes
- `Tests/BimodalTest/` - Test updates
- `Theories/Bimodal/Bimodal.lean` - Roll-up verification
- `Theories/Bimodal/Syntax/Formula.lean` - Final doc comment updates

**Verification**:
- Full `lake build` succeeds with no errors
- Sorry count unchanged from before the task (no new sorries)
- All existing tests pass
- Module documentation reflects new definitions

## Testing & Validation

- [ ] `lake build` completes successfully (full project)
- [ ] No new `sorry` introduced (compare before/after count)
- [ ] `swap_temporal_involution` theorem still holds
- [ ] Semantic equivalence lemmas (`truth_at_all_future_iff`, `truth_at_all_past_iff`) proven
- [ ] `temp_k_dist_derived` and `temp_4_derived` proven (or justified sorry)
- [ ] Existing soundness proofs remain sorry-free
- [ ] Example proofs in `Examples/` still produce correct derivation trees

## Artifacts & Outputs

- `specs/116_redefine_ghfp_via_until_since/plans/01_redefine-ghfp-plan.md` (this file)
- Modified `Formula` inductive type (6 constructors instead of 8)
- Modified `Axiom` inductive type (43 constructors instead of 45)
- New definitional abbreviations: `top`, `some_future`, `some_past`, `all_future`, `all_past`
- New derived theorems: `temp_k_dist_derived`, `temp_4_derived`
- New semantic equivalence lemmas: `truth_at_all_future_iff`, `truth_at_all_past_iff`, etc.

## Rollback/Contingency

The task touches ~70 files with ~1400 references. Rollback strategy:

1. **Git-based rollback**: Each phase produces a commit. If a phase introduces intractable problems, `git revert` back to the last successful phase commit.
2. **SubformulaClosure escape hatch**: If Strategy A (transparent abbreviations) causes decidability proofs to break irreparably, switch to Strategy B (add custom G/H pattern recognition in SubformulaClosure) without reverting earlier phases.
3. **Axiom derivation fallback**: If `temp_k_dist_derived` or `temp_4_derived` cannot be proven immediately, mark with `sorry` and create a follow-up task. The sorry does not block compilation.
4. **Full abort**: If the scope proves larger than estimated, revert all changes and create a multi-task breakdown with smaller slices (e.g., one task per layer).
