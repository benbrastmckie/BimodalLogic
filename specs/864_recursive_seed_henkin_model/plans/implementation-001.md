# Implementation Plan: Recursive Seed Henkin Model Construction

- **Task**: 864 - Recursive seed construction for Henkin model completeness
- **Status**: [NOT STARTED]
- **Effort**: 34 hours
- **Dependencies**: None (supersedes task 843's approach)
- **Research Inputs**: specs/864_recursive_seed_henkin_model/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements a recursive, formula-driven seed construction for Henkin model completeness in TM bimodal logic. Instead of building temporal and modal structure independently and combining them (which failed in task 843), the seed construction builds the entire model structure -- both temporal families and modal families -- directly from the recursive structure of a consistent formula. The formula's syntax dictates what constraints the model must satisfy, and the seed captures the minimal structure needed.

The construction proceeds in six phases: (1) formula classification and seed data structures, (2) recursive seed builder, (3) seed consistency proof, (4) seed completion to MCS families via Lindenbaum, (5) model assembly into BMCS with coherence proofs, and (6) integration with completeness theorems to eliminate both false axioms.

### Research Integration

Integrated from research-001.md:
- Operator-specific seed rules (Section 2.3): Box/G/H are universal (add to existing entries), negated Box creates new families, negated G/H create new time indices
- The distinction between modal witnesses (new families) and temporal witnesses (new time indices within same family) mirrors BMCS semantics
- Existing infrastructure reuse: `set_lindenbaum`, `diamond_boxcontent_consistent_constant`, `constructCoherentWitness`, `GContent`/`HContent`/`TemporalContent`, `eval_saturated_bundle_exists`
- Consistency argument strategy: induction on formula structure, mirroring the seed construction
- Risk assessment: seed consistency proof and modal coherence at non-seed time indices are highest risk

## Goals & Non-Goals

**Goals**:
- Implement `ModelSeed` data structure and `FormulaClass` classification
- Implement recursive `buildSeed` function with termination proof
- Prove seed consistency (each (family, time) CS is consistent if starting formula is consistent)
- Extend seed to full `IndexedMCSFamily` instances via Lindenbaum + temporal chain construction
- Assemble families into `BMCS` with proven modal and temporal coherence
- Eliminate `singleFamily_modal_backward_axiom` (Construction.lean:210) -- mathematically FALSE
- Eliminate `temporal_coherent_family_exists` axiom (TemporalCoherentConstruction.lean:578) -- mathematically TRUE but unproven
- Integrate with Completeness.lean so completeness theorems use new construction

**Non-Goals**:
- Modifying the TruthLemma (it is already sorry-free and works with any temporally coherent BMCS)
- Changing the Formula type or proof system axioms
- Proving completeness for logics beyond TM bimodal logic
- Optimizing the construction for efficiency (correctness is the priority)
- Removing sorries in TemporalChain.lean (those are in a separate module for a different approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency proof is harder than expected (cross-family Box additions may conflict with existing diamond witnesses) | High | Medium | Use induction on formula complexity; separate universal and existential steps; fall back to axiom for consistency if proof stalls |
| Modal coherence at non-seed time indices fails (Lindenbaum extension at intermediate times may add Box formulas breaking cross-family agreement) | High | Medium | Use BoxContent inclusion in all family seeds; leverage constant-family modal coherence for the base layer; accept correct axiom as fallback |
| Termination of recursive seed builder is complex to prove in Lean | Medium | Low | Use `Formula.complexity` as decreasing measure; each recursive call processes a strict subformula |
| Temporal chain filling between seed time indices introduces uncontrolled formulas | Medium | Medium | Use TemporalContent seeds (proven consistent) for chain filling; verify chain properties are preserved across seed time boundaries |
| Integration with existing BMCS infrastructure requires significant refactoring | Low | Low | New construction provides the same `BMCS D` type; only `construct_temporal_bmcs` and its callers need updating |

## Sorry Characterization

### Pre-existing Sorries
- 4 sorries in `TemporalChain.lean` (forward_G cross-sign, backward_H cross-sign, forward_F, backward_P)
- These are NOT directly resolved by this task but the new construction bypasses them

### Expected Resolution
- The recursive seed construction eliminates the NEED for `TemporalChain.lean` in the completeness chain
- Seed-based families are built with temporal coherence from the start
- The two false/unproven axioms (`singleFamily_modal_backward_axiom`, `temporal_coherent_family_exists`) are the primary targets

### New Sorries
- Phases 3-4 may introduce temporary sorries during the consistency proof development, to be resolved within those phases
- If the full modal coherence proof at non-seed time indices stalls, a CORRECT axiom (mathematically true, clearly justified) may be introduced as technical debt requiring remediation

### Remaining Debt
After this implementation:
- Zero axioms on the critical completeness path (target)
- Fallback: at most 1 correct axiom for modal coherence at non-seed times (replacing 2 current axioms, one of which is FALSE)
- TemporalChain.lean sorries remain but are off the critical path

## Axiom Characterization

### Pre-existing Axioms
- `singleFamily_modal_backward_axiom` (Construction.lean:210) -- mathematically FALSE, claims phi in MCS implies Box phi in MCS
- `temporal_coherent_family_exists` (TemporalCoherentConstruction.lean:578) -- mathematically TRUE but unproven, claims existence of temporally coherent family

### Expected Resolution
- Phase 5 eliminates `singleFamily_modal_backward_axiom` via multi-family BMCS construction with proven modal_backward from saturation
- Phase 5 eliminates `temporal_coherent_family_exists` via seed-based family construction with built-in temporal witnesses
- Structural proof approach: the recursive seed pre-places all witnesses, then Lindenbaum extension preserves them

### New Axioms
- None expected. If modal coherence at non-seed times requires a gap axiom, it will be a CORRECT axiom (mathematically sound) clearly labeled as technical debt requiring structural proof elimination

### Remaining Debt
After this implementation:
- Zero-axiom target for completeness chain
- Fallback: 1 correct axiom (down from 2, one of which was false)
- Publication requires axiom disclosure or elimination for any remaining axioms

## Implementation Phases

### Phase 1: Formula Classification and Seed Data Structures [NOT STARTED]

- **Goal:** Define the `FormulaClass` inductive type for classifying formulas by their main operator, the `ModelSeed` data structure for representing seeds, and helper functions for seed manipulation.

- **Tasks:**
  - [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
  - [ ] Define `FormulaClass` inductive type with constructors: `atomic`, `bottom`, `implication`, `negation`, `boxPositive`, `boxNegative`, `futurePositive`, `futureNegative`, `pastPositive`, `pastNegative`
  - [ ] Implement `classifyFormula : Formula -> FormulaClass` function that pattern-matches on formula structure (handle `imp (.box phi) .bot` as boxNegative, `imp (.all_future phi) .bot` as futureNegative, etc.)
  - [ ] Define `SeedEntry` structure: `familyIdx : Nat`, `timeIdx : Int`, `formulas : Finset Formula`
  - [ ] Define `ModelSeed` structure with fields: `entries : List SeedEntry`, `nextFamilyIdx : Nat`, and helper accessors
  - [ ] Implement `ModelSeed.addFormula : ModelSeed -> Nat -> Int -> Formula -> ModelSeed`
  - [ ] Implement `ModelSeed.addToAllFamilies : ModelSeed -> Int -> Formula -> ModelSeed`
  - [ ] Implement `ModelSeed.addToAllFutureTimes : ModelSeed -> Nat -> Int -> Formula -> ModelSeed`
  - [ ] Implement `ModelSeed.addToAllPastTimes : ModelSeed -> Nat -> Int -> Formula -> ModelSeed`
  - [ ] Implement `ModelSeed.createNewFamily : ModelSeed -> Int -> Formula -> ModelSeed` (for diamond witnesses)
  - [ ] Implement `ModelSeed.createNewTime : ModelSeed -> Nat -> Int -> Formula -> ModelSeed` (for temporal witnesses)
  - [ ] Implement `ModelSeed.getFormulas : ModelSeed -> Nat -> Int -> Finset Formula` (lookup formulas at (family, time))
  - [ ] Implement `ModelSeed.familyIndices : ModelSeed -> Finset Nat` and `ModelSeed.timeIndices : ModelSeed -> Nat -> Finset Int`
  - [ ] Verify file compiles with `lake build`

- **Timing:** 2 hours

- **Files to create/modify:**
  - `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (new file)

- **Verification:**
  - File compiles without errors
  - `classifyFormula` correctly classifies example formulas (can verify via `#eval` or `#check`)
  - All seed manipulation functions type-check

---

### Phase 2: Recursive Seed Builder [NOT STARTED]

- **Goal:** Implement the `buildSeed` function that recursively unpacks a formula to build a `ModelSeed`, with a termination proof based on formula complexity.

- **Tasks:**
  - [ ] Define `buildSeedAux : Formula -> Nat -> Int -> ModelSeed -> ModelSeed` -- the core recursive function
  - [ ] Handle atomic case: add atom to current (family, time) CS
  - [ ] Handle bottom case: no-op (should not arise for consistent formulas)
  - [ ] Handle implication case: add implication to current CS (Lindenbaum will decide branches)
  - [ ] Handle Box phi: add Box phi to current CS, add phi to ALL families at current time, recurse on phi at all families
  - [ ] Handle negated Box (imp (box phi) bot): add neg(box phi) to current CS, create NEW family with neg phi at current time, recurse on neg phi at new family
  - [ ] Handle G phi (all_future): add G phi and phi to current CS, add phi to all future times in current family
  - [ ] Handle negated G (imp (all_future phi) bot): add neg(G phi) to current CS, create new time t+1 in current family with neg phi, recurse on neg phi at new time
  - [ ] Handle H phi (all_past): add H phi and phi to current CS, add phi to all past times in current family
  - [ ] Handle negated H (imp (all_past phi) bot): add neg(H phi) to current CS, create new time t-1 in current family with neg phi, recurse on neg phi at new time
  - [ ] Handle generic negation (imp phi bot): add neg phi to current CS, recurse on inner classification
  - [ ] Prove termination using `Formula.complexity` as decreasing measure
  - [ ] Define `buildSeed : Formula -> ModelSeed` -- entry point creating initial seed `{(0, 0, {phi})}` and calling `buildSeedAux`
  - [ ] Add `#eval`/`#check` tests for example formulas from research report (Section 2.5-2.6)
  - [ ] Verify file compiles with `lake build`

- **Timing:** 4 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (extend)

- **Verification:**
  - `buildSeed` terminates on all well-formed formulas
  - Example from research: `buildSeed (neg (box (all_future (atom "p"))))` produces 3 entries (fam_0 at time 0, fam_1 at time 0, fam_1 at time 1)
  - File compiles without errors or sorries

---

### Phase 3: Seed Consistency Proof [NOT STARTED]

- **Goal:** Prove that if the starting formula is consistent, then every (family, time) entry in the seed is consistent. This is the mathematically hardest phase.

- **Tasks:**
  - [ ] Define `SeedConsistent : ModelSeed -> Prop` -- every entry's formula set is SetConsistent
  - [ ] Define `SeedWellFormed : ModelSeed -> Prop` -- structural invariants (unique entries per (family, time), valid indices)
  - [ ] Prove `initialSeedConsistent : FormulaConsistent phi -> SeedConsistent (initialSeed phi)` -- the singleton seed is consistent
  - [ ] Prove `addFormula_preserves_consistent` -- adding a formula that is provable from existing formulas preserves consistency
  - [ ] Prove universal operator consistency: when Box phi is in a CS and we add phi to another CS that already has consistent relationship with the first, the result is consistent. Key lemma: if phi is derivable from Box phi (T-axiom) and Box phi is in a consistent set, then adding phi preserves consistency
  - [ ] Prove existential operator consistency: creating a new entry with a single formula neg phi is always consistent (singleton sets of non-bottom formulas are consistent)
  - [ ] Prove cross-family consistency: when Box phi adds phi to a diamond witness family containing neg psi, show {phi, neg psi} is consistent when the parent formula is consistent. Key insight: this follows from the parent formula's consistency -- if Box phi and neg(Box psi) are both in a consistent set, then phi and neg psi must be jointly consistent
  - [ ] Prove `buildSeedAux_preserves_consistent` by induction on formula complexity, using the above lemmas
  - [ ] Prove main theorem: `seedConsistent : FormulaConsistent phi -> SeedConsistent (buildSeed phi)`
  - [ ] Verify all proofs compile without sorry

- **Timing:** 8 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (extend)

- **Verification:**
  - `seedConsistent` compiles without sorry
  - All intermediate lemmas compile without sorry
  - `lake build` succeeds

---

### Phase 4: Seed Completion to MCS Families [NOT STARTED]

- **Goal:** Extend each seed entry's consistent set to a full MCS via Lindenbaum, then build `IndexedMCSFamily` instances for each family index, filling non-seed time indices using temporal chain construction.

- **Tasks:**
  - [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
  - [ ] Define `extendSeedEntry : SeedEntry -> (h_cons : SetConsistent entry.formulas) -> Set Formula` -- extend via `set_lindenbaum`
  - [ ] Prove `extendSeedEntry_is_mcs` -- the extended set is a maximal consistent set
  - [ ] Prove `extendSeedEntry_contains_seed` -- the extended MCS contains all seed formulas
  - [ ] Define `seedFamilyMCS : ModelSeed -> Nat -> Int -> Set Formula` -- MCS at each (family, time) position in the seed
  - [ ] For diamond witness families: include `BoxContent(eval_family)` in the seed before Lindenbaum extension, using `diamond_boxcontent_consistent_constant` from CoherentConstruction.lean
  - [ ] For non-seed time indices within a family: use `TemporalContent` from TemporalChain.lean to fill in intermediate times
  - [ ] Define `buildFamilyFromSeed : ModelSeed -> Nat -> IndexedMCSFamily Int` -- construct full family from seed data
  - [ ] Prove `buildFamilyFromSeed_is_mcs` -- each time index has a valid MCS
  - [ ] Prove `buildFamilyFromSeed_forward_G` -- G formulas propagate forward (from seed structure + TemporalContent seeds)
  - [ ] Prove `buildFamilyFromSeed_backward_H` -- H formulas propagate backward (from seed structure + TemporalContent seeds)
  - [ ] Prove `buildFamilyFromSeed_contains_seed` -- seed formulas are in the constructed MCS
  - [ ] Verify file compiles with `lake build`

- **Timing:** 6 hours

- **Files to create/modify:**
  - `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` (new file)

- **Verification:**
  - All family construction functions type-check
  - Forward_G and backward_H proofs compile (may have sorries for cross-sign cases initially)
  - Seed formula inclusion is proven
  - `lake build` succeeds

---

### Phase 5: BMCS Assembly and Coherence Proofs [NOT STARTED]

- **Goal:** Assemble the seed-built families into a `BMCS` with proven modal_forward, modal_backward, and temporal coherence. This phase eliminates both axioms.

- **Tasks:**
  - [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`
  - [ ] Define `buildSeedBMCS : Formula -> (h_cons : FormulaConsistent phi) -> BMCS Int` -- main construction entry point
  - [ ] Collect all families from `buildFamilyFromSeed` for each family index in the seed
  - [ ] Prove `seedBMCS_nonempty` -- at least family 0 exists
  - [ ] Prove `seedBMCS_modal_forward` -- Box phi in any family at time t implies phi in all families at time t. Strategy: by seed construction, Box phi at (f, t) means phi was added to ALL families at time t; by seed_contains, phi is in the Lindenbaum extension of each family's MCS at t
  - [ ] Prove `seedBMCS_modal_backward` -- phi in all families at time t implies Box phi in each family at time t. Strategy: use contraposition via saturation -- if Box phi not in fam, then neg(Box phi) = Diamond(neg phi) in fam, so by seed construction some witness family has neg phi, contradicting phi in all families. Leverage `saturated_modal_backward` from ModalSaturation.lean
  - [ ] Prove `seedBMCS_temporally_coherent` -- forward_F and backward_P hold for all families. Strategy: by seed construction, F phi at seed time t means a witness time exists with phi; for non-seed F-formulas arising from Lindenbaum, use temporal chain filling with TemporalContent
  - [ ] Define `construct_seed_bmcs : List Formula -> ContextConsistent Gamma -> BMCS Int` -- wrapper matching the signature expected by Completeness.lean
  - [ ] Prove `construct_seed_bmcs_contains_context` -- Gamma is in eval_family.mcs 0
  - [ ] Prove `construct_seed_bmcs_temporally_coherent` -- the BMCS is temporally coherent
  - [ ] Update `Completeness.lean` to use `construct_seed_bmcs` instead of `construct_temporal_bmcs`
  - [ ] Verify `bmcs_representation` still compiles
  - [ ] Verify `bmcs_weak_completeness` and `bmcs_strong_completeness` still compile
  - [ ] Comment out or remove `singleFamily_modal_backward_axiom` from Construction.lean
  - [ ] Comment out or remove `temporal_coherent_family_exists` from TemporalCoherentConstruction.lean
  - [ ] Run full `lake build` to verify no axiom dependencies remain

- **Timing:** 8 hours

- **Files to create/modify:**
  - `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean` (new file)
  - `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (update construction calls)
  - `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (remove/comment axiom)
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (remove/comment axiom)

- **Verification:**
  - Full `lake build` succeeds with zero axioms on completeness critical path
  - `bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness` compile without sorry
  - `#print axioms bmcs_representation` shows no custom axioms (only Lean builtins like propext, Quot.sound, Classical.choice)
  - Both removed axioms are no longer referenced

---

### Phase 6: Verification, Documentation, and Cleanup [NOT STARTED]

- **Goal:** Final verification that the construction is correct, clean up temporary constructs, add documentation, and verify the full build.

- **Tasks:**
  - [ ] Run `lake build` and verify zero build errors
  - [ ] Run `#print axioms bmcs_weak_completeness` and `#print axioms bmcs_strong_completeness` to verify axiom-free status
  - [ ] Count remaining sorries in new files (target: zero, but document any with remediation timeline)
  - [ ] Add module-level documentation to `RecursiveSeed.lean` explaining the construction
  - [ ] Add module-level documentation to `SeedCompletion.lean` explaining the completion strategy
  - [ ] Add module-level documentation to `SeedBMCS.lean` explaining the BMCS assembly
  - [ ] Update imports in `Metalogic.lean` root file to include new modules
  - [ ] Verify TemporalChain.lean still compiles (it should, as it is not modified)
  - [ ] Create implementation summary

- **Timing:** 2 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (documentation)
  - `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` (documentation)
  - `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean` (documentation)
  - `Theories/Bimodal/Metalogic.lean` (import updates)

- **Verification:**
  - `lake build` succeeds with zero errors
  - `#print axioms` confirms axiom-free completeness
  - All new files have proper module documentation
  - Implementation summary created

## Testing & Validation

- [ ] `lake build` succeeds with zero build errors across entire project
- [ ] `#print axioms bmcs_representation` shows no custom axioms
- [ ] `#print axioms bmcs_weak_completeness` shows no custom axioms
- [ ] `#print axioms bmcs_strong_completeness` shows no custom axioms
- [ ] `singleFamily_modal_backward_axiom` is no longer used anywhere in the codebase
- [ ] `temporal_coherent_family_exists` axiom is no longer used anywhere in the codebase
- [ ] New files (`RecursiveSeed.lean`, `SeedCompletion.lean`, `SeedBMCS.lean`) have zero sorries (target)
- [ ] Example formulas from research report produce correct seed structures
- [ ] The Truth Lemma (`TruthLemma.lean`) continues to compile without modification

## Artifacts & Outputs

- `specs/864_recursive_seed_henkin_model/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (new -- seed data structures and builder)
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` (new -- seed to MCS family completion)
- `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean` (new -- BMCS assembly and coherence)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (modified -- use new construction)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (modified -- remove false axiom)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (modified -- remove unproven axiom)
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md` (completion summary)

## Rollback/Contingency

If the full axiom-free construction proves infeasible:

**Fallback A (Partial Success):** Replace 2 axioms (one FALSE) with 1 CORRECT axiom for modal coherence at non-seed time indices. This is strictly better than the current state and can be clearly justified mathematically.

**Fallback B (Temporal Only):** Use seed construction only for temporal coherence (eliminating `temporal_coherent_family_exists`) while keeping the modal axiom. The seed naturally provides temporal witnesses, making this the easiest partial victory.

**Rollback Procedure:**
1. Revert `Completeness.lean` to use `construct_temporal_bmcs`
2. Restore axiom declarations in `Construction.lean` and `TemporalCoherentConstruction.lean`
3. New files (`RecursiveSeed.lean`, `SeedCompletion.lean`, `SeedBMCS.lean`) can be retained as infrastructure for future attempts
4. `lake build` to verify rollback succeeds
