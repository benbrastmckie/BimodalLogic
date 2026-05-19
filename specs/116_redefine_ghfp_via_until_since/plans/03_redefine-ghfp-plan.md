# Implementation Plan: Task #116 (Revised v3)

- **Task**: 116 - Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Status**: [NOT STARTED]
- **Effort**: 30 hours
- **Dependencies**: Task 107 (completed)
- **Research Inputs**: specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md, specs/116_redefine_ghfp_via_until_since/reports/02_team-research.md
- **Artifacts**: plans/03_redefine-ghfp-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is a post-audit revision of plan v2. The first implementation attempt executed Phases 1-5 but with significant issues: Phase 2 was falsely marked complete (temp_k_dist/temp_4 still axiom constructors), Substitution.lean has compilation errors from @[match_pattern] conflicts, SubformulaClosure has 12 sorry markers (not 8), and SoundnessLemmas.lean has ~100 errors. The build currently has 114 errors across 6 files. This revised plan preserves genuinely completed work (Phase 1 and parts of Phases 3-5), corrects the falsely completed Phase 2, fixes broken files, and restructures remaining work around the discovered @[match_pattern] limitations. Definition of done: `lake build` succeeds with zero errors and all sorry markers documented.

### Research Integration

Key findings from two research reports (integrated in plan v2, carried forward):

**Round 1** (reports/01_redefine-ghfp-research.md): Confirmed semantic equivalence under irreflexive temporal semantics. Identified Strategy A (transparent expansion) as the recommended approach. Documented the `truth_at` multi-step unfolding path and SubformulaClosure risk.

**Round 2** (reports/02_team-research.md, 4 teammates): Corrected scope from 70/1416 to 103 files/2398 references. Established three-tier difficulty classification. Identified `@[match_pattern]` as potential effort reduction. Found 4 inconsistent `top` definitions requiring consolidation. Confirmed `def` (not `abbrev`) for all abbreviations. Identified `temp_k_dist`/`temp_4` derivation as a prerequisite before removal.

### Post-Audit Findings (v3 revision basis)

The post-implementation audit revealed these issues that this plan addresses:

1. **Phase 2 was never executed**: temp_k_dist and temp_4 remain as axiom constructors in Axioms.lean (lines 111, 116). No derived theorems were created, no invocations replaced. The prior plan falsely marked this [COMPLETED].

2. **Substitution.lean broken** (3+ errors): @[match_pattern] arms for all_past/all_future cause "redundant alternative" errors when placed after .imp arms. subst_some_past has an unsolved goal. swap_temporal_subst uses all_past/all_future as induction arms (invalid -- they are not constructors).

3. **SubformulaClosure.lean has 12 sorry markers** (not 8 as previously claimed): 4-6 are fixable because some_future/some_past expand to untl/snce (distinct constructors, so injection/noConfusion works). Only all_future/all_past variants (which expand to imp) hit the noConfusion problem.

4. **SoundnessLemmas.lean has ~100 errors**: truth_at unfolding mismatches throughout the file.

5. **5 additional files failing**: TemporalContent.lean (4 errors), TemporalCoherence.lean (2 errors), Bridge.lean (3 errors), Table.lean (2 errors).

6. **@[match_pattern] limitation discovered**: The attribute works for match/def expressions but NOT for induction tactic arms. In functions that explicitly handle .imp first, adding .all_future/.all_past arms causes "redundant alternative" errors because they structurally ARE .imp terms. Pattern-match arms for all_future/all_past MUST precede .imp (and work there), but induction proofs must use the 6 real constructors only.

### Prior Plan Reference

Plan v2 (plans/02_redefine-ghfp-plan.md) had 12 phases at 35 hours. Phases 1-5 were attempted but only Phase 1 was genuinely completed in full. This v3 plan restructures around the actual state of the codebase: preserving completed work, correcting the Phase 2 omission, fixing broken files, and proceeding through the remaining untouched modules.

### Roadmap Alignment

Roadmap Phase 2 lists task 116 as part of "Frame hierarchy + axiom cleanup": "redefine G/H/F/P via U/S (task 116). Reduces primitives to {S, U, box, imp, bot}." Task 157 (expressive completeness, Phase 3 prerequisite) is explicitly blocked by task 116.

## Goals & Non-Goals

**Goals**:
- Fix the 114 build errors across 6 currently-failing files
- Complete the skipped Phase 2: derive temp_k_dist/temp_4 as theorems and remove axiom constructors
- Fix Substitution.lean @[match_pattern] conflicts and induction errors
- Resolve the fixable SubformulaClosure sorry markers (some_future/some_past cases where injection works)
- Complete Phases 6-12 from the original plan (Soundness, Decidability, Algebraic, Completeness, WeakCanonical, Theorems/Automation, Tests, Validation)
- Rename "bridge lemma" to "semantic characterization theorem" in Truth.lean docstrings
- Ensure `lake build` passes with zero errors
- Audit and document all sorry markers with FIX: comments

**Non-Goals**:
- Adding bridge lemmas or compatibility wrappers (the semantic characterization theorems in Truth.lean are legitimate and stay, but no new shims)
- Changing the semantic treatment of untl/snce (remain primitive constructors)
- Modifying box or any modal operators
- Optimizing SubformulaClosure for smaller closure size (Strategy B deferred)
- Repairing ConservativeExtension/ExtFormula (dead code; separate task)
- Papering over issues with sorry -- fix properly where possible

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| temp_k_dist/temp_4 derivation proves difficult (requires deep proof from BX axioms) | H | M | Phase 2 safety: if derivation is intractable, keep as axiom constructors and defer removal to follow-up task |
| @[match_pattern] arm ordering issues propagate to more files than expected | M | M | Document the ordering rule clearly (all_future/all_past arms BEFORE .imp); apply mechanically per file |
| SoundnessLemmas.lean ~100 errors require understanding truth_at unfolding chains | H | H | Use the semantic characterization theorems (truth_at_all_future_iff, etc.) as rewrite targets; work error-by-error |
| SubformulaClosure all_future/all_past sorry markers genuinely intractable (noConfusion on imp) | M | H | These are known-hard; leave sorry with FIX: comments and document the structural reason |
| WeakCanonical/Separation Hierarchy.lean (82 arms) exceeds phase budget | M | M | Use sorry for deep proof reworks; split into sub-phase if needed |
| Cascade of truth_at expansion mismatches in metalogic files | H | H | Systematic approach: simp with semantic characterization theorems, then manual rewrites |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4, 5 | 3 |
| 4 | 6, 7 | 4, 5 |
| 5 | 8 | 6, 7 |
| 6 | 9 | 8 |
| 7 | 10 | 9 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix Substitution.lean and Rename Docstrings [COMPLETED]

**Goal**: Fix the 3+ compilation errors in Substitution.lean caused by @[match_pattern] conflicts and invalid induction arms. Rename "bridge lemma" to "semantic characterization theorem" in Truth.lean docstrings.

**Tasks**:
- [ ] Fix @[match_pattern] arm ordering in Substitution.lean: remove redundant all_past/all_future arms that conflict with .imp arms (lines 37-38), or reorder so they precede .imp
- [ ] Fix subst_some_past unsolved goal (line 109): the proof likely needs updating since some_past now expands to snce
- [ ] Fix swap_temporal_subst (lines 399-400): replace invalid all_past/all_future induction arms with proofs using the 6 real constructors plus simp lemmas for the abbreviation cases
- [ ] Rename all "bridge lemma" references to "semantic characterization theorem" in Truth.lean docstrings
- [ ] Verify: `lake build Bimodal.ProofSystem.Substitution` compiles with zero errors
- [ ] Verify: `lake build Bimodal.Semantics.Truth` compiles

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Fix @[match_pattern] arm ordering, induction, and unsolved goals
- `Theories/Bimodal/Semantics/Truth.lean` - Rename docstrings

**Verification**:
- Substitution.lean compiles with zero errors
- swap_temporal_subst proof uses 6-constructor induction only
- No "redundant alternative" warnings from @[match_pattern] arms
- Truth.lean docstrings say "semantic characterization theorem" not "bridge lemma"

---

### Phase 2: Derive temp_k_dist and temp_4 as Theorems [NOT STARTED]

**Goal**: Derive temp_k_dist and temp_4 as standalone theorems from BX axioms, replace all ~45 axiom invocations across the codebase, then remove the axiom constructors from the Axiom inductive type. This phase was falsely marked complete in the prior attempt and must be done from scratch.

**Tasks**:
- [ ] Create derivation of `temp_k_dist_derived : Derivable (all_future (phi.imp psi)).imp ((all_future phi).imp (all_future psi))` from BX axioms (BX2G/left_mono_until_G + propositional logic)
- [ ] Create derivation of `temp_4_derived : Derivable (all_future phi).imp (all_future (all_future phi))` from BX5 (self_accum_until) + BX6 (absorb_until)
- [ ] Verify both derivations compile and are sorry-free with the CURRENT Formula type (G/H are now defs)
- [ ] Replace all ~45 axiom invocations of `Axiom.temp_k_dist` across the codebase with the derived theorem
- [ ] Replace all ~45 axiom invocations of `Axiom.temp_4` across the codebase with the derived theorem
- [ ] Replace `temp_4_tactic` in Automation/Tactics.lean with a version using the derived theorem
- [ ] Remove `temp_k_dist` and `temp_4` constructors from `Axiom` inductive type in Axioms.lean
- [ ] Update any Soundness/DiscreteSoundness arms that match on the removed axiom constructors
- [ ] Verify: `lake build Bimodal.ProofSystem.Axioms` compiles
- [ ] Verify: `lake build` for all files that previously referenced temp_k_dist/temp_4 succeeds

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` - Add derived theorems
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Remove temp_k_dist, temp_4 constructors
- `Theories/Bimodal/Metalogic/Soundness.lean` - Remove soundness arms for removed axioms
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Remove soundness arms
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - Remove arms
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - Replace axiom invocations
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` - Replace invocations
- `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - Replace invocations
- `Theories/Bimodal/ProofSystem/Substitution.lean` - Replace substitution arms
- `Theories/Bimodal/Automation/Tactics.lean` - Rewrite temp_4_tactic
- `Theories/Bimodal/Automation/AesopRules.lean` - Replace axiom references
- Various other files with temp_k_dist/temp_4 invocations (~36 files total)

**Verification**:
- Both derived theorems compile and are sorry-free
- No remaining references to `Axiom.temp_k_dist` or `Axiom.temp_4` as axiom constructors in proofs
- Axiom inductive has 2 fewer constructors
- `lake build Bimodal.ProofSystem` succeeds

---

### Phase 3: Fix Currently-Failing Files [NOT STARTED]

**Goal**: Fix the 5 currently-failing files (excluding Substitution.lean, fixed in Phase 1): SoundnessLemmas.lean (~100 errors), TemporalContent.lean (4 errors), TemporalCoherence.lean (2 errors), Bridge.lean (3 errors), Table.lean (2 errors). All failures stem from truth_at expansion mismatches and type mismatches from all_past/all_future no longer being constructors.

**Tasks**:
- [ ] Fix SoundnessLemmas.lean (~100 errors): systematically rewrite proofs using semantic characterization theorems (truth_at_all_future_iff, truth_at_all_past_iff, truth_at_some_future_iff, truth_at_some_past_iff, truth_at_top) instead of direct truth_at unfolding for G/H/F/P formulas
- [ ] Fix TemporalContent.lean (4 errors): update type mismatches where code treats all_past/all_future as constructors
- [ ] Fix TemporalCoherence.lean (2 errors): update type mismatches
- [ ] Fix Bridge.lean (3 errors): fix swap_temporal simp issues (likely @[match_pattern] arm ordering)
- [ ] Fix Table.lean (2 errors): fix simp failures (likely need to add semantic characterization theorems to simp set)
- [ ] Verify: `lake build` for all 5 files compiles with zero errors

**Timing**: 4 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Rewrite truth_at proofs (~100 errors)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - Fix type mismatches (4 errors)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - Fix type mismatches (2 errors)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Bridge.lean` - Fix swap_temporal simp (3 errors, if this file exists; may be Theorems/Perpetuity/Bridge.lean)
- `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` - Fix simp failures (2 errors)

**Verification**:
- All 5 files compile with zero errors
- No new sorry markers introduced (fix properly or document why sorry is necessary)
- `lake build` error count drops from 114 to 0 for these files

---

### Phase 4: Fix SubformulaClosure Sorry Markers [NOT STARTED]

**Goal**: Resolve the fixable sorry markers in SubformulaClosure.lean. Of the 12 sorry markers, 4-6 involve some_future/some_past which expand to untl/snce (distinct constructors), so injection/noConfusion works. The remaining all_future/all_past cases expand to imp and genuinely hit the noConfusion problem -- these get documented FIX: comments but may remain as sorry.

**Tasks**:
- [ ] Identify which of the 12 sorry markers involve some_future/some_past (fixable) vs all_future/all_past (hard)
- [ ] Fix the some_future/some_past sorry markers: since these expand to .untl/.snce (distinct constructors), noConfusion/injection should work -- write proper proofs
- [ ] For all_future/all_past sorry markers that hit the .imp noConfusion problem: attempt structural proofs using deeper pattern analysis (e.g., proving that all_future phi = imp (untl (imp phi bot) (imp bot bot)) (imp phi bot) is injective by analyzing subterms)
- [ ] For any remaining intractable sorry markers: add detailed FIX: comments explaining the structural reason (all_future/all_past expand to .imp, so noConfusion cannot distinguish them from other .imp terms)
- [ ] Fix the deferralClosure sorry markers (lines 1303, 1307, 1311, 1315, 1320) -- assess whether these are fixable or require deeper rework
- [ ] Verify: `lake build Bimodal.Syntax.SubformulaClosure` compiles

**Timing**: 3 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Fix fixable sorry markers, document remaining ones

**Verification**:
- Sorry count reduced (target: 6 or fewer remaining, all documented with FIX: comments)
- Some_future/some_past cases fully proved (no sorry)
- All remaining sorry markers have FIX: comments explaining why they cannot be resolved without deeper structural changes
- File compiles

---

### Phase 5: Soundness and Core Metalogic [NOT STARTED]

**Goal**: Complete the update of Soundness.lean, DiscreteSoundness.lean, and core metalogic files (DeductionTheorem, MCSProperties, RestrictedMCS). Phase 3 fixes the SoundnessLemmas.lean errors; this phase handles the remaining Soundness module files and core metalogic that were not touched in the first attempt.

**Tasks**:
- [ ] Update Soundness.lean: remove temp_k_dist/temp_4 soundness cases (if not already handled in Phase 2), update any remaining all_future/all_past pattern matches
- [ ] Update DiscreteSoundness.lean: remove all_future/all_past match arms, use semantic characterization theorems
- [ ] Update DeductionTheorem.lean: remove all_future/all_past induction cases (use 6-constructor induction)
- [ ] Update MCSProperties.lean: replace constructor usage with abbreviation usage
- [ ] Update RestrictedMCS.lean: remove pattern matches on removed constructors
- [ ] Verify: `lake build Bimodal.Metalogic.Soundness` and core metalogic modules compile

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Soundness theorem
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - Discrete soundness
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - Deduction theorem
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS properties
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Restricted MCS

**Verification**:
- All core metalogic modules compile
- Soundness proof handles the reduced axiom set (no temp_k_dist/temp_4)
- No new sorry markers introduced

---

### Phase 6: Decidability and Algebraic Metalogic [NOT STARTED]

**Goal**: Update the Decidability (Tableau, SignedFormula, FMP) and Algebraic modules. These have moderate pattern-match counts and depend on the semantic characterization theorems.

**Tasks**:
- [ ] Update Decidability/SignedFormula.lean: remove all_future/all_past pattern matches
- [ ] Update Decidability/Tableau.lean: remove G/H tableau rules; add rules for expanded forms or use simp lemmas
- [ ] Update Decidability/FMP/TruthPreservation.lean: remove all_future/all_past match arms
- [ ] Update Algebraic/TenseS5Algebra.lean (38 refs): remove constructor-based pattern matches
- [ ] Update Algebraic/InteriorOperators.lean: remove constructor references
- [ ] Update Algebraic/LindenbaumQuotient.lean: remove constructor references
- [ ] Update Algebraic/ParametricTruthLemma.lean, RestrictedParametricTruthLemma.lean: remove constructor references
- [ ] Update Algebraic/UltrafilterFrame.lean (82 refs): remove constructor references
- [ ] Update remaining Algebraic files: ParametricCanonical.lean, ParametricCompleteness.lean, ParametricHistory.lean, UltrafilterMCS.lean, BooleanStructure.lean, AlgebraicCompleteness.lean
- [ ] Use sorry for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Metalogic.Decidability` and `lake build Bimodal.Metalogic.Algebraic` compile

**Timing**: 2.5 hours

**Depends on**: 3

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
- Tableau rules handle G/H formulas via expansion or simp
- Sorry markers (if any) documented with FIX: comments

---

### Phase 7: Completeness Pipeline - Bundle and BXCanonical [NOT STARTED]

**Goal**: Update the completeness pipeline: Bundle modules (WitnessSeed, TemporalCoherence, SuccRelation, etc.) and BXCanonical modules (CanonicalChain, Chronicle, Quasimodel, TruthLemma, etc.). Note: TemporalContent.lean and TemporalCoherence.lean are partially fixed in Phase 3 (build errors), but may need further pattern-match updates here.

**Tasks**:
- [ ] Update Bundle/WitnessSeed.lean (88 refs): remove all_future/all_past pattern matches
- [ ] Complete Bundle/TemporalCoherence.lean: beyond the build error fixes from Phase 3, update remaining constructor-based pattern matches
- [ ] Update Bundle/SuccRelation.lean (49 refs): replace constructor usage
- [ ] Update Bundle/CanonicalFrame.lean, CanonicalIrreflexivity.lean, CanonicalTaskRelation.lean: remove arms
- [ ] Update Bundle/FMCSDef.lean, SuccExistence.lean: remove references
- [ ] Complete Bundle/TemporalContent.lean: beyond Phase 3 fixes, update remaining matches
- [ ] Update BXCanonical/CanonicalChain.lean, CanonicalModel.lean, Frame.lean: remove arms
- [ ] Update BXCanonical/Chronicle/*.lean (PointInsertion 68 refs, ChronicleConstruction 30 refs, others): remove matches
- [ ] Update BXCanonical/Quasimodel/*.lean (Construction, EnrichedClosure, Realization, SubformulaClosure): remove references
- [ ] Update BXCanonical/TruthLemma.lean, OrderedSeedConsistency.lean, RootScopedChain.lean: remove arms
- [ ] Update BXCanonical/Filtration/DefectChain.lean, SigmaOrdering.lean: remove matches
- [ ] Update Completeness.lean: remove any direct constructor references
- [ ] Use sorry for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Metalogic.Bundle` and `lake build Bimodal.Metalogic.BXCanonical` compile

**Timing**: 4 hours

**Depends on**: 4, 5

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

### Phase 8: WeakCanonical and Separation Module [NOT STARTED]

**Goal**: Update the entire WeakCanonical subtree, including the Separation module (15 files, 492 refs, 260 pattern-match arms). Note: Table.lean and Bridge.lean build errors are fixed in Phase 3; this phase handles the full pattern-match refactor for all remaining files. Hierarchy.lean (82 arms) and TemporalClosure.lean (58 arms) are the hardest files.

**Tasks**:
- [ ] Update Separation/Defs.lean (45 refs, 36 arms): update is_U_free, is_S_free, is_future_only, is_past_only, is_syntactically_separated to reflect new semantics where G/H contain U/S
- [ ] Update Separation/Hierarchy.lean (115 refs, 82 arms): massive structural inductions; use sorry for deep proof reworks
- [ ] Update Separation/TemporalClosure.lean (111 refs, 58 arms): leverage existing expand_temporal proof asset and semantic equivalence proofs
- [ ] Update Separation/Duality.lean (24 refs, 20 arms): remove constructor pattern matches
- [ ] Update Separation/DedekindZ.lean (24 refs, 20 arms): remove constructor pattern matches
- [ ] Update Separation/SeparationThm.lean (24 refs, 4 arms): remove constructor matches
- [ ] Update Separation/FormulaOps.lean, Eliminations.lean, DualEliminations.lean, Distributivity.lean, NegationEquiv.lean, NormalForm.lean, IntHelpers.lean: remove all G/H constructor arms
- [ ] Complete Table.lean: beyond Phase 3 build fixes, update remaining pattern matches
- [ ] Update TruthLemma.lean (10 refs, 2 arms): remove constructor matches
- [ ] Update ExpressiveCompleteness.lean (25 refs, 20 arms): remove constructor matches
- [ ] Update remaining WeakCanonical files: ReflexiveCanonical.lean (84 refs, 0 arms), FrameProperties.lean, IntegerModel.lean, MonadicFO.lean, NEquivalence.lean, NormalForm.lean, OrderedSum.lean, ChronicleExtraction.lean, Transfer.lean, WeakCanonical.lean
- [ ] Update Separation.lean barrel file
- [ ] Use sorry for proofs that require deep reworking; mark with FIX: comments
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical` compiles

**Timing**: 6 hours

**Depends on**: 6, 7

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

### Phase 9: Theorems, Automation, and Examples [NOT STARTED]

**Goal**: Update derived theorem files, automation/proof search, and example files. These are mostly Tier 2/3 files with constructor-application usage that may work transparently with @[match_pattern].

**Tasks**:
- [ ] Update Theorems/TemporalDerived.lean: rewrite derived theorem proofs using new definitions; adapt proofs that used old temp_k_dist/temp_4 references (some may already be handled in Phase 2)
- [ ] Update Theorems/GeneralizedNecessitation.lean (30 refs): adapt to temporal_necessitation
- [ ] Update Theorems/Perpetuity/Bridge.lean (57 refs): remove constructor-based match arms (may overlap with Phase 3 fix if this is the "Bridge.lean" that was failing)
- [ ] Update Theorems/Perpetuity/Helpers.lean: update helper lemmas
- [ ] Update Theorems/Perpetuity/Principles.lean (47 refs): update principle proofs
- [ ] Update Automation/ProofSearch.lean (35 refs): update heuristic scoring and pattern recognition for G/H formulas (they are now imp at top level)
- [ ] Update Automation/AesopRules.lean, Tactics.lean, SuccessPatterns.lean: update tactic support
- [ ] Update Automation.lean barrel file
- [ ] Update Examples/BimodalProofs.lean, BimodalProofStrategies.lean (57 refs): update example proofs
- [ ] Update Examples/TemporalProofs.lean (41 refs), TemporalProofStrategies.lean (29 refs): update temporal examples
- [ ] Verify: `lake build Bimodal.Theorems`, `lake build Bimodal.Automation`, `lake build Bimodal.Examples` compile

**Timing**: 2.5 hours

**Depends on**: 8

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

### Phase 10: Test Suite and Full Build Validation [NOT STARTED]

**Goal**: Update the test suite (20 files, 507 references), run full `lake build`, fix remaining compilation errors, audit sorry markers, and update documentation. ConservativeExtension scoped out to follow-up task.

**Tasks**:
- [ ] Update Tests/BimodalTest/Syntax/FormulaTest.lean: update constructor-based tests
- [ ] Update Tests/BimodalTest/Syntax/FormulaPropertyTest.lean: update property tests (may reference 8 constructors)
- [ ] Update Tests/BimodalTest/Syntax/ContextTest.lean: update context tests
- [ ] Update Tests/BimodalTest/Property/Generators.lean: update formula generators (must generate via def forms, not constructors)
- [ ] Update Tests/BimodalTest/ProofSystem/AxiomsTest.lean: remove temp_k_dist/temp_4 test cases
- [ ] Update Tests/BimodalTest/ProofSystem/DerivationTest.lean, DerivationPropertyTest.lean, DerivationBenchmark.lean: update derivation tests
- [ ] Update Tests/BimodalTest/Semantics/TruthTest.lean, TaskFrameTest.lean, SemanticPropertyTest.lean, SemanticBenchmark.lean: update truth evaluation tests
- [ ] Update Tests/BimodalTest/Theorems/*.lean and Automation/*.lean and Integration/*.lean test files
- [ ] Update BimodalTest.lean barrel file and Property.lean
- [ ] Run full `lake build` for the entire project
- [ ] Fix any remaining compilation errors
- [ ] Scope out ConservativeExtension/ExtFormula as dead code: add comment or move to Boneyard
- [ ] Audit all sorry markers: document each with FIX: comment, count total sorries before vs after
- [ ] Update module-level documentation (docstrings at top of Formula.lean, Axioms.lean, Truth.lean, Derivation.lean) to reflect the 6-constructor design
- [ ] Update Bimodal.lean barrel file if needed
- [ ] Run final `lake build` to confirm clean compilation
- [ ] Create follow-up task for ConservativeExtension repair/archival if not already exists

**Timing**: 2.5 hours

**Depends on**: 9

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
- `Tests/BimodalTest/Theorems/*.lean` - Theorem tests
- `Tests/BimodalTest/Automation/*.lean` - Automation tests
- `Tests/BimodalTest/Integration/*.lean` - Integration tests
- `Tests/BimodalTest.lean` - Test barrel file
- `Tests/BimodalTest/Property.lean` - Property barrel file
- `Theories/Bimodal/Bimodal.lean` - Top-level barrel file
- Various files with remaining sorry markers

**Verification**:
- `lake build` succeeds with no errors
- `lake build Tests` succeeds
- Formula generators produce valid G/H formulas via the new definitions
- All sorry markers are documented with FIX: comments
- Sorry count is tracked (before vs after)
- ConservativeExtension is scoped out with documented justification
- Documentation reflects 6-constructor Formula type

## Testing & Validation

- [ ] `lake build` succeeds for the full project after each phase
- [ ] Formula inductive type has exactly 6 constructors: atom, bot, imp, box, untl, snce
- [ ] all_future, all_past, some_future, some_past are def abbreviations, not constructors
- [ ] Formula.top exists as a canonical definition
- [ ] temp_k_dist_derived and temp_4_derived are sorry-free theorems
- [ ] Axiom inductive reduced by 2 constructors (temp_k_dist, temp_4 removed)
- [ ] Semantic characterization: truth_at(all_future phi, t) <-> forall s > t, truth_at(phi, s) proved
- [ ] Semantic characterization: truth_at(some_future phi, t) <-> exists s > t, truth_at(phi, s) proved
- [ ] temporal_necessitation correctly produces G(phi) formulas
- [ ] swap_temporal correctly swaps G/H (via U/S swap) and preserves involution property
- [ ] Soundness, completeness, and decidability modules compile
- [ ] WeakCanonical/Separation module compiles with correct syntactic predicate semantics
- [ ] Test suite passes: `lake build Tests`
- [ ] @[match_pattern] limitations documented: works for match/def, NOT for induction arms; arms must precede .imp to avoid redundancy
- [ ] All sorry markers documented with FIX: comments, no net sorry increase
- [ ] Truth.lean docstrings say "semantic characterization theorem" not "bridge lemma"
- [ ] No bridge lemmas or compatibility wrappers added beyond existing semantic characterization theorems

## Artifacts & Outputs

- `specs/116_redefine_ghfp_via_until_since/plans/03_redefine-ghfp-plan.md` (this file)
- Modified `Theories/Bimodal/Syntax/Formula.lean` (already done: 8 to 6 constructors)
- Modified `Theories/Bimodal/ProofSystem/Axioms.lean` (Phase 2: remove temp_k_dist, temp_4)
- Modified `Theories/Bimodal/Semantics/Truth.lean` (already done: 6 cases + semantic characterization theorems; Phase 1: rename docstrings)
- Modified `Theories/Bimodal/ProofSystem/Substitution.lean` (Phase 1: fix @[match_pattern] conflicts)
- Modified `Theories/Bimodal/Syntax/SubformulaClosure.lean` (Phase 4: reduce sorry count)
- Modified `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (Phase 3: fix ~100 errors)
- ~100 additional Lean files with pattern-match and constructor reference updates
- Follow-up task for ConservativeExtension repair/archival

## Rollback/Contingency

- **Git-based rollback**: Each phase is committed separately; revert to pre-phase commit if a phase introduces unfixable issues
- **Phase 2 safety**: If temp_k_dist/temp_4 derivation from BX axioms proves intractable, keep them as axiom constructors and defer removal to a follow-up task. The rest of the refactor is not blocked by this.
- **@[match_pattern] ordering rule**: If arm ordering issues propagate unexpectedly, the fallback is removing all @[match_pattern] arms and writing explicit match arms using the 6 real constructors everywhere. This is more verbose but always correct.
- **SubformulaClosure sorry budget**: If the all_future/all_past sorry markers prove intractable, they remain with FIX: comments. The key constraint is that some_future/some_past cases MUST be fixed (they are solvable).
- **SoundnessLemmas.lean**: If the ~100 errors cannot be fixed by systematic use of semantic characterization theorems, consider adding targeted simp lemmas to Truth.lean that make truth_at unfold in the old patterns. This is not a "bridge lemma" -- it is providing simp with the knowledge it needs.
- **Sorry bridge**: If any metalogic proof becomes intractable, use sorry with FIX: comment and file a follow-up task for the specific proof repair.
- **ConservativeExtension exclusion**: Already scoped out. If any import chain pulls it in, stub it out.
