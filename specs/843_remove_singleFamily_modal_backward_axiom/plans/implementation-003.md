# Implementation Plan: Remove ALL Axioms and Sorries from Active Codebase

- **Task**: 843 - remove_singleFamily_modal_backward_axiom
- **Version**: 003
- **Status**: [NOT STARTED]
- **Effort**: 28-42 hours
- **Dependencies**: Task 856 (COMPLETED), Task 857 (COMPLETED)
- **Research Inputs**: research-008.md (post-857 assessment), research-007.md (EvalBMCS revision)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan eliminates ALL axioms and sorries from the active (non-Boneyard, non-Examples) codebase to produce a publishable repository. The expanded scope targets 4 axioms and approximately 17 sorries across Bimodal and Logos modules. The approach is organized into three tiers: (1) easy clean-up of dead code and documentation sorries, (2) moderate-effort temporal Lindenbaum construction, and (3) hard multi-family saturated BMCS construction for the original modal backward axiom.

### Research Integration

- **research-008.md**: Confirmed 2 axioms in completeness chain (`singleFamily_modal_backward_axiom`, `temporally_saturated_mcs_exists`) and 2 dead-code axioms. Identified EvalBMCS truth lemma as structurally limited (box case requires iff at ALL families). Recommended temporal Lindenbaum as lower-hanging fruit before multi-family consistency.
- **research-007.md**: Established the modified Lindenbaum approach for temporal saturation. The `temporal_witness_seed_consistent` theorem is already proven.
- **Task 857 plan v003**: Designed but did not implement `temporalLindenbaumMCS`. Task 857 used an axiom shortcut instead.

## Goals & Non-Goals

**Goals**:
- Zero axioms in active Theories/ code (non-Boneyard, non-Examples)
- Zero sorries in active Theories/ code (non-Boneyard, non-Examples)
- Completeness theorem chain with no transitive axiom or sorry dependencies
- Clean `lake build` with no warnings from active code
- Publication-ready repository

**Non-Goals**:
- Fixing sorries in Boneyard/ or Examples/ directories
- Optimizing proof performance or compilation speed
- Restructuring the module hierarchy (beyond moving dead code)
- Unifying EvalBMCS and BMCS approaches (EvalBMCS becomes dead code after this)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multi-family `{psi} U UnionBoxContent(B)` consistency proof fails | High | Medium | Incremental approach: complete phases 1-4 first (reduces to 1 axiom); research alternative consistency arguments |
| Formula enumeration infrastructure is complex | Medium | Low | Standard countable inductive type; well-known technique |
| Omega-step limit in Lindenbaum construction requires care | Medium | Medium | Follow standard textbook Henkin construction; use existing `lindenbaumMCS` as template |
| Boneyard move breaks imports in other active files | Medium | Low | Check all imports before moving; update lakefile if needed |
| Logos/Dynamics sorry requires domain knowledge | Medium | Medium | The sorry is for causal counterfactual semantics; may require separate task if not tractable |
| Build times increase with new constructions | Low | Medium | Mark constructions as `noncomputable`; accept compilation cost |

## Axiom Characterization

### Pre-existing Axioms

| # | Axiom | File | Line | Category |
|---|-------|------|------|----------|
| 1 | `singleFamily_modal_backward_axiom` | Construction.lean | 228 | Completeness chain |
| 2 | `temporally_saturated_mcs_exists` | TemporalCoherentConstruction.lean | 575 | Completeness chain |
| 3 | `saturated_extension_exists` | CoherentConstruction.lean | 871 | Dead code |
| 4 | `weak_saturated_extension_exists` | WeakCoherentBundle.lean | 826 | Dead code |

### Expected Resolution

- Phase 1 eliminates axioms 3 and 4 by moving their files to Boneyard (dead code removal)
- Phase 3 eliminates axiom 2 via `temporalLindenbaumMCS` construction (structural proof)
- Phase 5 eliminates axiom 1 via multi-family saturated BMCS construction (structural proof)

### New Axioms

None. Every elimination uses structural proofs. No new axioms will be introduced.

### Remaining Debt

After this implementation:
- 0 axioms in active Theories/ code
- Completeness theorem becomes fully axiom-free (publication-ready without disclosure)

## Sorry Characterization

### Pre-existing Sorries

| # | File | Lines | Count | Category |
|---|------|-------|-------|----------|
| 1 | TruthLemma.lean | 604, 611, 625, 639 | 4 | Legacy `eval_bmcs_truth_lemma` (dead code after phase 6) |
| 2 | SaturatedConstruction.lean | 817, 985, 1005 | 3 | Dead code (not used by completeness) |
| 3 | PreCoherentBundle.lean | 338, 377 | 2 | Dead code (structural impossibility) |
| 4 | WeakCoherentBundle.lean | 501, 750, 944 | 3 | Dead code (not used by completeness) |
| 5 | Logos/SubTheories/Dynamics/Truth.lean | 176 | 1 | Causal counterfactual semantics (deferred feature) |
| 6 | Logos/Automation.lean | 26 | 1 | Documentation example sorry |
| 7 | Bimodal/Automation/ProofSearch.lean | 1348, 1353, 1358 | 3 | Documentation example sorries |

### Expected Resolution

- Phase 1 eliminates #2, #3, #4 (8 sorries) by moving files to Boneyard
- Phase 2 eliminates #5, #6, #7 (5 sorries) by removing documentation sorries or replacing with proven alternatives
- Phase 6 eliminates #1 (4 sorries) by moving legacy `eval_bmcs_truth_lemma` to Boneyard after completeness is rewired

### New Sorries

None. If intermediate complexity requires temporary sorry, it will be documented with specific remediation within the same plan.

### Remaining Debt

After this implementation:
- 0 sorries in active Theories/ code
- All sorries confined to Boneyard/ and Examples/ directories

## Implementation Phases

### Phase 1: Dead Code Removal -- Move Unused Files to Boneyard [NOT STARTED]

**Goal**: Eliminate 2 dead-code axioms and 8 sorries by moving files that are not used by the completeness chain to Boneyard.

**Tasks**:
- [ ] Verify that `SaturatedConstruction.lean` is not imported by any active file outside Boneyard
- [ ] Verify that `PreCoherentBundle.lean` is not imported by any active file outside Boneyard
- [ ] Verify that `WeakCoherentBundle.lean` is not imported by any active file outside Boneyard
- [ ] Move `SaturatedConstruction.lean` to `Theories/Bimodal/Boneyard/Metalogic_v5/SaturatedConstruction.lean`
- [ ] Move `PreCoherentBundle.lean` to `Theories/Bimodal/Boneyard/Metalogic_v5/PreCoherentBundle.lean`
- [ ] Move `WeakCoherentBundle.lean` to `Theories/Bimodal/Boneyard/Metalogic_v5/WeakCoherentBundle.lean`
- [ ] Update any Boneyard imports if needed
- [ ] Run `lake build` to verify no active code is broken

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` -- move to Boneyard
- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` -- move to Boneyard
- `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean` -- move to Boneyard

**Verification**:
- `lake build` passes with no errors
- `grep -r "SaturatedConstruction" Theories/Bimodal/Metalogic/` returns no active imports
- `grep -r "PreCoherentBundle" Theories/Bimodal/Metalogic/` returns no active imports
- `grep -r "WeakCoherentBundle" Theories/Bimodal/Metalogic/` returns no active imports
- Axiom count reduced by 2 (`saturated_extension_exists`, `weak_saturated_extension_exists`)
- Sorry count reduced by 8

---

### Phase 2: Remove Documentation and Deferred-Feature Sorries [NOT STARTED]

**Goal**: Eliminate the 5 sorries in Logos and Automation files that are documentation examples or deferred features, not mathematical gaps.

**Tasks**:
- [ ] Read `Theories/Logos/Automation.lean` -- the sorry at line 26 is in a documentation example; either provide a real proof or remove the example
- [ ] Read `Theories/Bimodal/Automation/ProofSearch.lean` -- the 3 sorries at lines 1348, 1353, 1358 are in documentation examples; either provide real proofs or remove the examples
- [ ] Read `Theories/Logos/SubTheories/Dynamics/Truth.lean` -- the sorry at line 176 is for causal counterfactual semantics (`Formula.causal`); assess whether it can be proven or if the causal operator should be removed/stubbed differently
- [ ] For Automation sorries: if the examples demonstrate future automation, replace `sorry` with `Exists.intro _ trivial` or restructure examples to not require sorry
- [ ] For Logos/Dynamics sorry: if causal semantics is not yet defined, consider replacing with `False.elim` on an unreachable case, or marking the causal operator as not yet supported with a `panic!` or `absurd` rather than `sorry`
- [ ] Run `lake build` to verify

**Timing**: 2 hours

**Files to modify**:
- `Theories/Logos/Automation.lean` -- remove or prove documentation sorry
- `Theories/Bimodal/Automation/ProofSearch.lean` -- remove or prove 3 documentation sorries
- `Theories/Logos/SubTheories/Dynamics/Truth.lean` -- address causal counterfactual sorry

**Verification**:
- `lake build` passes
- `grep -rn "sorry" Theories/Logos/` returns no results (excluding Boneyard/Examples)
- `grep -rn "sorry" Theories/Bimodal/Automation/` returns no results

---

### Phase 3: Implement `temporalLindenbaumMCS` [NOT STARTED]

**Goal**: Build the modified Lindenbaum construction that produces temporally saturated MCS, eliminating the `temporally_saturated_mcs_exists` axiom. This is the construction that Task 857 planned but did not implement.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` (new file)
- [ ] Implement formula enumeration: `enumFormulas : Nat -> Formula` that enumerates all formulas
- [ ] Implement temporal witness extraction: given a formula F(psi) or P(psi), extract the witness psi
- [ ] Implement `temporalLindenbaumStep`: given a set M and formula phi, add phi if consistent, then add temporal witness if applicable and consistent
- [ ] Prove `temporalLindenbaumStep_preserves_consistency`: each step preserves set consistency
- [ ] Prove `temporalLindenbaumStep_monotone`: each step extends the set
- [ ] Implement `temporalLindenbaumMCS`: omega-step construction iterating over all formulas
- [ ] Prove result is maximal consistent (every formula or its negation is in the set)
- [ ] Prove result extends the original context
- [ ] Prove `temporalLindenbaumMCS_forward_saturated`: F(psi) in M implies psi in M
- [ ] Prove `temporalLindenbaumMCS_backward_saturated`: P(psi) in M implies psi in M
- [ ] Key lemma: use `temporal_witness_seed_consistent` (already proven in TemporalCoherentConstruction.lean:477) to show witness insertion is consistent

**Timing**: 8-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` -- new file with full construction

**Verification**:
- `lake build` passes
- New file compiles without sorry
- `#check @temporalLindenbaumMCS` shows no axiom dependencies
- Saturation properties proven without sorry

---

### Phase 4: Rewire Temporal Construction to Use `temporalLindenbaumMCS` [NOT STARTED]

**Goal**: Replace the `temporally_saturated_mcs_exists` axiom in TemporalCoherentConstruction.lean with the proven `temporalLindenbaumMCS`, eliminating the second completeness-chain axiom.

**Tasks**:
- [ ] Replace the body of `temporal_eval_saturated_bundle_exists` to use `temporalLindenbaumMCS` instead of the axiom
- [ ] Verify that `construct_temporal_bmcs` still compiles (it transitively depends on `temporal_eval_saturated_bundle_exists`)
- [ ] Comment out or delete the `temporally_saturated_mcs_exists` axiom declaration
- [ ] Update documentation in TemporalCoherentConstruction.lean to reflect axiom removal
- [ ] Run `lake build` to verify completeness chain still compiles

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- replace axiom usage with proven construction

**Verification**:
- `lake build` passes
- `grep -rn "temporally_saturated_mcs_exists" Theories/` returns only comments
- `#check @construct_temporal_bmcs` shows only `singleFamily_modal_backward_axiom` (not both axioms)
- Completeness chain reduced from 2 axioms to 1

---

### Phase 5: Multi-Family Saturated BMCS Construction [NOT STARTED]

**Goal**: Build a multi-family BMCS where every Diamond formula has a witness family, eliminating `singleFamily_modal_backward_axiom`. This is the hardest phase and the original goal of task 843.

**Mathematical approach**: Construct a BMCS where:
1. Every family is a temporally saturated constant MCS (using `temporalLindenbaumMCS` from phase 3)
2. For every Diamond(psi) in any family, there exists a witness family containing psi
3. Modal backward follows by contraposition: if phi is in ALL families, then Box(phi) must be in each family (otherwise Diamond(neg phi) would be witnessed by a family not containing phi)

**Key mathematical challenge**: Proving `{psi} U UnionBoxContent(B)` is consistent when Diamond(psi) is in some family of B. The singleton case is proven (`diamond_boxcontent_consistent_constant` in CoherentConstruction.lean). The multi-family case requires showing the union of BoxContent across families is consistent with psi.

**Tasks**:
- [ ] Study `CoherentConstruction.lean` infrastructure: `CoherentBundle`, `toBMCS`, `diamond_boxcontent_consistent_constant`
- [ ] Define `SaturatedCoherentBundle`: a CoherentBundle where every Diamond formula has a witness family and all families are temporally saturated
- [ ] Implement iterative saturation: starting from an initial bundle, repeatedly add witness families for unsatisfied Diamond formulas
- [ ] Prove multi-family consistency: `{psi} U UnionBoxContent(B)` is consistent. Strategy options:
  - (a) Prove directly via K-distribution argument extended to unions
  - (b) Use the fact that constant families share the same MCS content at all times, so UnionBoxContent reduces to union of BoxContent of individual families
  - (c) If (a) and (b) fail, consider restricting to countably saturated bundles via transfinite induction
- [ ] Prove the saturated bundle has `modal_backward` for ALL families (contraposition argument)
- [ ] Prove the saturated bundle has `modal_forward` for ALL families (T-axiom argument, as in current `singleFamilyBMCS`)
- [ ] Combine with temporal saturation from phase 3 to get temporally coherent multi-family BMCS
- [ ] Construct `axiomFree_construct_temporal_bmcs`: replacement for `construct_temporal_bmcs` that uses no axioms

**Timing**: 10-15 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` -- extend with multi-family saturation proof
- Or create new file `Theories/Bimodal/Metalogic/Bundle/SaturatedBMCS.lean` if cleaner

**Verification**:
- `lake build` passes
- New construction compiles without sorry or axiom
- `#check @axiomFree_construct_temporal_bmcs` shows no axiom dependencies
- Modal forward/backward proven for ALL families

---

### Phase 6: Rewire Completeness and Remove All Axioms [NOT STARTED]

**Goal**: Replace `construct_temporal_bmcs` in Completeness.lean with the axiom-free construction, then remove all remaining axioms.

**Tasks**:
- [ ] Update `bmcs_representation` in Completeness.lean to use `axiomFree_construct_temporal_bmcs`
- [ ] Update `bmcs_context_representation` similarly
- [ ] Verify `bmcs_truth_lemma` still applies (the new BMCS must satisfy `temporally_coherent`)
- [ ] Verify all downstream completeness theorems still compile
- [ ] Comment out or delete `singleFamily_modal_backward_axiom` in Construction.lean
- [ ] Comment out or delete `singleFamilyBMCS` (no longer needed)
- [ ] Move legacy `eval_bmcs_truth_lemma` (4 sorries) to Boneyard or delete, since the main truth lemma is now fully proven and EvalBMCS is obsolete
- [ ] Move `CoherentConstruction.lean` dead code sections to Boneyard if the `saturated_extension_exists` axiom infrastructure is no longer referenced
- [ ] Update module documentation to reflect zero-axiom completeness
- [ ] Run full `lake build`

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` -- rewire to axiom-free construction
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` -- remove axiom and singleFamilyBMCS
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- move legacy eval_bmcs_truth_lemma to Boneyard
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- clean up axiom references

**Verification**:
- `lake build` passes with no errors
- `grep -rn "axiom " Theories/Bimodal/Metalogic/` returns no results (excluding Boneyard)
- `grep -rn "axiom " Theories/Logos/` returns no results
- `grep -rn "sorry" Theories/Bimodal/Metalogic/` returns no results (excluding Boneyard)
- `grep -rn "sorry" Theories/Logos/` returns no results
- `#check @bmcs_strong_completeness` shows zero axiom dependencies
- `#check @bmcs_weak_completeness` shows zero axiom dependencies

---

### Phase 7: Final Verification and Documentation [NOT STARTED]

**Goal**: Comprehensive verification that the repository is publication-ready with zero axioms and zero sorries in active code.

**Tasks**:
- [ ] Run `grep -rn "axiom " Theories/` excluding Boneyard and Examples -- expect zero results
- [ ] Run `grep -rn "sorry" Theories/` excluding Boneyard and Examples -- expect zero results
- [ ] Run `lake build` -- expect clean build
- [ ] Verify `#check @bmcs_strong_completeness` has no axiom dependencies
- [ ] Verify `#check @bmcs_weak_completeness` has no axiom dependencies
- [ ] Verify `#check @bmcs_representation` has no axiom dependencies
- [ ] Update `specs/state.json` repository_health: axiom_count = 0 (active), sorry_count = 0 (active)
- [ ] Create implementation summary at `specs/843_remove_singleFamily_modal_backward_axiom/summaries/implementation-summary-YYYYMMDD.md`

**Timing**: 1-2 hours

**Files to modify**:
- `specs/state.json` -- update repository_health metrics
- `specs/TODO.md` -- update task status

**Verification**:
- All checks from above pass
- Implementation summary created
- State files synchronized

---

## Testing & Validation

- [ ] `lake build` passes after each phase with no errors
- [ ] Zero axioms in active Theories/ (non-Boneyard, non-Examples) after phase 6
- [ ] Zero sorries in active Theories/ (non-Boneyard, non-Examples) after phase 6
- [ ] `#check @bmcs_strong_completeness` shows no axiom dependencies
- [ ] `#check @bmcs_weak_completeness` shows no axiom dependencies
- [ ] `#check @bmcs_representation` shows no axiom dependencies
- [ ] No active file imports from Boneyard
- [ ] All moved files are accessible in Boneyard for historical reference

## Artifacts & Outputs

- `specs/843_remove_singleFamily_modal_backward_axiom/plans/implementation-003.md` (this file)
- `specs/843_remove_singleFamily_modal_backward_axiom/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- New file: `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
- New file (possibly): `Theories/Bimodal/Metalogic/Bundle/SaturatedBMCS.lean`
- Modified files:
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
  - `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
  - `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
  - `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
  - `Theories/Logos/Automation.lean`
  - `Theories/Logos/SubTheories/Dynamics/Truth.lean`
  - `Theories/Bimodal/Automation/ProofSearch.lean`
- Moved to Boneyard:
  - `SaturatedConstruction.lean`
  - `PreCoherentBundle.lean`
  - `WeakCoherentBundle.lean`

## Incremental Value

This plan is designed for incremental progress. Each phase delivers independent value:

| After Phase | Axioms Removed | Sorries Removed | Value |
|-------------|---------------|-----------------|-------|
| Phase 1 | 2 (dead code) | 8 (dead code) | Clean active codebase of dead weight |
| Phase 2 | 0 | 5 (docs/deferred) | Zero sorries in Logos/ and Automation/ |
| Phase 3 | 0 | 0 | New proven infrastructure (temporalLindenbaumMCS) |
| Phase 4 | 1 (temporal) | 0 | Completeness chain down to 1 axiom |
| Phase 5 | 0 | 0 | New proven infrastructure (multi-family BMCS) |
| Phase 6 | 1 (modal) + cleanup | 4 (eval legacy) | ZERO axioms, ZERO sorries in active code |
| Phase 7 | 0 | 0 | Verified publication-ready state |

If Phase 5 proves too difficult, Phases 1-4 alone reduce the completeness chain from 2 axioms to 1 axiom and remove all dead-code axioms/sorries. This is independently valuable and publishable with axiom disclosure.

## Comparison with Previous Versions

| Aspect | v001 | v002 | v003 |
|--------|------|------|------|
| Scope | Remove 1 axiom | Remove 1 axiom | Remove ALL axioms + ALL sorries |
| Phases | 4 | 2 | 7 |
| Estimated hours | 9 | 4-6 | 28-42 |
| Approach | EvalBMCS truth lemma | Eval-only forward | Multi-family saturated BMCS + temporal Lindenbaum |
| Blocking issue | EvalBMCS box case | Research-008 invalidated eval-only | None identified (multi-family consistency is hard but not blocked) |
| Research basis | research-001, 002 | research-003 | research-008 (post-857 assessment) |
| Dead code cleanup | No | No | Yes (Boneyard moves) |
| Logos/Automation | No | No | Yes (all sorries addressed) |
| Publication-ready | No (1 axiom remains) | No (1 axiom remains) | Yes (zero axioms, zero sorries) |

## Rollback/Contingency

**Phase 1-2 rollback**: Git revert moves files back from Boneyard; no mathematical content affected.

**Phase 3-4 rollback**: New file `TemporalLindenbaum.lean` can be deleted; axiom remains in TemporalCoherentConstruction.lean unchanged.

**Phase 5-6 rollback**: New multi-family construction is additive; original `construct_temporal_bmcs` remains until the replacement is verified. Axioms are only commented out after replacement is confirmed working.

**If Phase 5 fails**: Stop at Phase 4. The repository will have 1 axiom (`singleFamily_modal_backward_axiom`) and 4 legacy eval sorries. This is still a significant improvement (removed 3 axioms and 13 sorries). Document the remaining axiom as requiring further research on multi-family consistency and create a follow-up task.
