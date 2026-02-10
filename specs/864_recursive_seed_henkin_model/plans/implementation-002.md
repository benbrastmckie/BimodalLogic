# Implementation Plan: Recursive Seed Henkin Model Construction (v2)

- **Task**: 864 - Recursive seed construction for Henkin model completeness
- **Status**: [PARTIAL]
- **Effort**: 36 hours (revised from 34)
- **Version**: 002 (revised from 001)
- **Dependencies**: None (supersedes task 843's approach)
- **Research Inputs**:
  - specs/864_recursive_seed_henkin_model/reports/research-001.md
  - specs/864_recursive_seed_henkin_model/reports/research-002.md (new)
  - specs/865_canonical_task_frame_bimodal_completeness/reports/research-005.md (cross-reference)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary (v001 -> v002)

Based on research-002.md analysis of how seed construction bypasses task 843's Phase 1 blockage:

| Phase | v001 | v002 Changes |
|-------|------|--------------|
| Phase 1 | Basic seed data structures | **Added**: `SeedEntryType` tracking (temporal_witness vs. universal_target) |
| Phase 2 | Recursive seed builder | **Added**: Formula merging logic for existing time indices; proof task |
| Phase 3 | Seed consistency proof | **Added**: Explicit diamond-box interaction consistency lemma; strengthened invariants |
| Phase 4 | Seed completion to MCS | **Added**: Cross-sign handling clarification (seed pre-placed, Lindenbaum uses 4-axiom through time 0) |
| Phase 5 | BMCS assembly | **Added**: Explicit documentation of task 843 blockage resolution |
| Risk | Various | **Revised**: Seed consistency risk reduced from HIGH to MEDIUM-HIGH |

**Key insight from research-002**: The seed construction AVOIDS the cross-sign propagation problem rather than SOLVING it. Witnesses are pre-placed before Lindenbaum extension, eliminating the need for cross-chain propagation.

## Overview

This plan implements a recursive, formula-driven seed construction for Henkin model completeness in TM bimodal logic. Instead of building temporal and modal structure independently and combining them (which failed in task 843 due to cross-sign temporal propagation), the seed construction builds the entire model structure -- both temporal families and modal families -- directly from the recursive structure of a consistent formula.

The construction proceeds in six phases: (1) formula classification and seed data structures with entry type tracking, (2) recursive seed builder with formula merging, (3) seed consistency proof with diamond-box interaction lemma, (4) seed completion to MCS families with cross-sign handling, (5) BMCS assembly with coherence proofs and task 843 resolution, and (6) integration with completeness theorems.

### Research Integration

Integrated from research-001.md:
- Operator-specific seed rules (Section 2.3): Box/G/H are universal (add to existing entries), negated Box creates new families, negated G/H create new time indices
- The distinction between modal witnesses (new families) and temporal witnesses (new time indices within same family) mirrors BMCS semantics
- Existing infrastructure reuse: `set_lindenbaum`, `diamond_boxcontent_consistent_constant`, `constructCoherentWitness`, `GContent`/`HContent`/`TemporalContent`, `eval_saturated_bundle_exists`

Integrated from research-002.md (NEW):
- **Task 843 blockage analysis**: The two-chain architecture fundamentally cannot support cross-sign G propagation; interleaving does not help (Section 2)
- **Why seed construction works**: Witnesses pre-placed BEFORE Lindenbaum extension, avoiding cross-chain propagation entirely (Section 3)
- **Diamond-box interaction lemma**: When Box phi and neg(Box psi) are jointly consistent, {phi, neg psi} is consistent (Section 5)
- **4-axiom propagation**: Cross-sign for Lindenbaum-added formulas uses 4-axiom (`G phi -> G(G phi)`) through time 0 (Section 4)
- **Revised risk assessment**: Seed consistency reduced from HIGH to MEDIUM-HIGH due to clear path (Section 6)

## Goals & Non-Goals

**Goals**:
- Implement `ModelSeed` data structure with `SeedEntryType` tracking
- Implement `FormulaClass` classification
- Implement recursive `buildSeed` function with termination proof and formula merging
- Prove seed consistency via diamond-box interaction lemma
- Extend seed to full `IndexedMCSFamily` instances with cross-sign handling via 4-axiom
- Assemble families into `BMCS` with proven modal and temporal coherence
- **Resolve task 843's Phase 1 blockage** by superseding the two-chain architecture
- Eliminate `singleFamily_modal_backward_axiom` (Construction.lean:210) -- mathematically FALSE
- Eliminate `temporal_coherent_family_exists` axiom (TemporalCoherentConstruction.lean:578) -- mathematically TRUE but unproven
- Integrate with Completeness.lean so completeness theorems use new construction

**Non-Goals**:
- Modifying the TruthLemma (it is already sorry-free and works with any temporally coherent BMCS)
- Changing the Formula type or proof system axioms
- Proving completeness for logics beyond TM bimodal logic
- Optimizing the construction for efficiency (correctness is the priority)
- Removing sorries in TemporalChain.lean (those are in a separate module for a different approach)

## Risks & Mitigations (Revised)

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency proof requires diamond-box interaction lemma | High | **Medium** (was Medium-High) | Document the lemma explicitly: when Box phi and neg(Box psi) are jointly consistent in parent, {phi, neg psi} is consistent in witness family |
| Lindenbaum extension at non-seed times may add problematic formulas | Medium | Low | Seed pre-places BoxContent; 4-axiom handles cross-sign for Lindenbaum-added formulas through time 0 |
| Termination of recursive seed builder is complex to prove in Lean | Medium | Low | Use `Formula.complexity` as decreasing measure; each recursive call processes a strict subformula |
| Chain filling for non-seed times reintroduces cross-sign problem | **Low** (was Medium) | Low | Only same-sign filling needed; cross-sign handled by 4-axiom through time 0 |
| Integration with existing BMCS infrastructure requires significant refactoring | Low | Low | New construction provides the same `BMCS D` type; only `construct_temporal_bmcs` and its callers need updating |

## Sorry Characterization

### Pre-existing Sorries
- 4 sorries in `DovetailingChain.lean` (forward_G cross-sign, backward_H cross-sign, forward_F, backward_P)
- These are NOT directly resolved by this task but the new construction **bypasses them entirely**

### Expected Resolution
- The recursive seed construction eliminates the NEED for `DovetailingChain.lean` in the completeness chain
- Seed-based families are built with temporal coherence from the start
- **Task 843's Phase 1 blockage is resolved**: cross-sign propagation is avoided, not solved
- The two false/unproven axioms are the primary targets

### New Sorries
- Phases 3-4 may introduce temporary sorries during the consistency proof development, to be resolved within those phases
- If the full modal coherence proof at non-seed time indices stalls, a CORRECT axiom (mathematically true, clearly justified) may be introduced as technical debt requiring remediation

### Remaining Debt
After this implementation:
- Zero axioms on the critical completeness path (target)
- Fallback: at most 1 correct axiom for modal coherence at non-seed times (replacing 2 current axioms, one of which is FALSE)
- DovetailingChain.lean sorries remain but are **off the critical path**

## Axiom Characterization

### Pre-existing Axioms
- `singleFamily_modal_backward_axiom` (Construction.lean:210) -- mathematically FALSE, claims phi in MCS implies Box phi in MCS
- `temporal_coherent_family_exists` (TemporalCoherentConstruction.lean:578) -- mathematically TRUE but unproven, claims existence of temporally coherent family

### Expected Resolution
- Phase 5 eliminates `singleFamily_modal_backward_axiom` via multi-family BMCS construction with proven modal_backward from saturation
- Phase 5 eliminates `temporal_coherent_family_exists` via seed-based family construction with built-in temporal witnesses
- **Structural proof approach**: the recursive seed pre-places all witnesses, then Lindenbaum extension preserves them

### New Axioms
- None expected. If modal coherence at non-seed times requires a gap axiom, it will be a CORRECT axiom clearly labeled as technical debt

### Remaining Debt
After this implementation:
- Zero-axiom target for completeness chain
- Fallback: 1 correct axiom (down from 2, one of which was false)

## Implementation Phases

### Phase 1: Formula Classification and Seed Data Structures [COMPLETED]

- **Goal:** Define the `FormulaClass` inductive type for classifying formulas by their main operator, the `ModelSeed` data structure with entry type tracking, and helper functions for seed manipulation.

- **Tasks:**
  - [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`
  - [ ] Define `FormulaClass` inductive type with constructors: `atomic`, `bottom`, `implication`, `negation`, `boxPositive`, `boxNegative`, `futurePositive`, `futureNegative`, `pastPositive`, `pastNegative`
  - [ ] Implement `classifyFormula : Formula -> FormulaClass` function that pattern-matches on formula structure
  - [ ] **NEW (v002)**: Define `SeedEntryType` inductive with constructors: `temporal_witness` (singleton formula from F/P witness), `universal_target` (formulas from Box/G/H propagation)
  - [ ] Define `SeedEntry` structure: `familyIdx : Nat`, `timeIdx : Int`, `formulas : Finset Formula`, **`entryType : SeedEntryType`**
  - [ ] Define `ModelSeed` structure with fields: `entries : List SeedEntry`, `nextFamilyIdx : Nat`, and helper accessors
  - [ ] Implement `ModelSeed.addFormula : ModelSeed -> Nat -> Int -> Formula -> ModelSeed` -- **merges with existing entry if present**
  - [ ] Implement `ModelSeed.addToAllFamilies : ModelSeed -> Int -> Formula -> ModelSeed`
  - [ ] Implement `ModelSeed.addToAllFutureTimes : ModelSeed -> Nat -> Int -> Formula -> ModelSeed`
  - [ ] Implement `ModelSeed.addToAllPastTimes : ModelSeed -> Nat -> Int -> Formula -> ModelSeed`
  - [ ] Implement `ModelSeed.createNewFamily : ModelSeed -> Int -> Formula -> ModelSeed` (for diamond witnesses, **entryType = temporal_witness**)
  - [ ] Implement `ModelSeed.createNewTime : ModelSeed -> Nat -> Int -> Formula -> ModelSeed` (for temporal witnesses, **entryType = temporal_witness**)
  - [ ] Implement `ModelSeed.getFormulas : ModelSeed -> Nat -> Int -> Finset Formula` (lookup formulas at (family, time))
  - [ ] **NEW (v002)**: Implement `ModelSeed.getEntryType : ModelSeed -> Nat -> Int -> Option SeedEntryType`
  - [ ] Implement `ModelSeed.familyIndices : ModelSeed -> Finset Nat` and `ModelSeed.timeIndices : ModelSeed -> Nat -> Finset Int`
  - [ ] Verify file compiles with `lake build`

- **Timing:** 2 hours

- **Files to create/modify:**
  - `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (new file)

- **Verification:**
  - File compiles without errors
  - `classifyFormula` correctly classifies example formulas
  - All seed manipulation functions type-check
  - **NEW**: `SeedEntryType` correctly distinguishes witness vs. universal entries

---

### Phase 2: Recursive Seed Builder [COMPLETED]

- **Goal:** Implement the `buildSeed` function that recursively unpacks a formula to build a `ModelSeed`, with a termination proof and formula merging for existing entries.

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
  - [ ] **NEW (v002)**: When G/H phi adds phi to existing time indices, merge formulas into existing entry
  - [ ] **NEW (v002)**: Prove `buildSeedAux_adds_to_existing : ∀ (f, t) in seed, phi is added to existing entry, not duplicated`
  - [ ] Prove termination using `Formula.complexity` as decreasing measure
  - [ ] Define `buildSeed : Formula -> ModelSeed` -- entry point creating initial seed `{(0, 0, {phi})}` and calling `buildSeedAux`
  - [ ] Add `#eval`/`#check` tests for example formulas from research report
  - [ ] Verify file compiles with `lake build`

- **Timing:** 4.5 hours (was 4)

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (extend)

- **Verification:**
  - `buildSeed` terminates on all well-formed formulas
  - Example: `buildSeed (neg (box (all_future (atom "p"))))` produces correct entries
  - **NEW**: Formula merging works correctly for multiple additions to same (family, time)
  - File compiles without errors or sorries

---

### Phase 3: Seed Consistency Proof [IN PROGRESS]

**Progress Update (2026-02-10, Session 5):**
- `addFormula_preserves_consistent_of_theorem`: COMPLETED
- `diamond_box_interaction`: COMPLETED (KEY LEMMA)
- `initialSeedConsistent`: COMPLETED
- `singleton_consistent_iff`: COMPLETED
- `addFormula_preserves_consistent`: COMPLETED (new helper)
- `hasPosition_iff_findEntry_isSome`: COMPLETED (new helper)
- `findEntry_some_of_hasPosition`: COMPLETED (new helper)
- `initial_has_family_zero`: COMPLETED
- `buildSeed_has_family_zero`: COMPLETED (fixed in Session 5)
- `buildSeedAux_preserves_familyIndices`: COMPLETED (fixed in Session 5 - complex imp case handling)
- `buildSeedAux_preserves_seedConsistent`: 1 sorry (new helper, complex induction)
- `seedConsistent`: COMPLETED (proof structure, but depends on above sorry)

**Progress Update (2026-02-10, Session 6):**
- `List.mem_modify_iff`: COMPLETED (new helper for List.modify membership characterization)
- `findIdx_go_ge`: COMPLETED (new helper for findIdx?.go bounds)
- `findIdx_go_pred`: COMPLETED (new helper for findIdx?.go predicate)
- `addFormula_seed_preserves_consistent`: COMPLETED (key lemma for adding formulas to seed)
- RecursiveSeed.lean sorries reduced from 4 to 1 (only `buildSeedAux_preserves_seedConsistent`)

**Progress Update (2026-02-10, Session 7):**
- `createNewTime_preserves_seedConsistent`: COMPLETED (new helper)
- `createNewFamily_preserves_seedConsistent`: COMPLETED (new helper)
- Simplified proof structure in `buildSeedAux_preserves_seedConsistent`
- Cleaned up code: removed 10+ intermediate sorries, leaving 1 core sorry
- Build succeeds with only 1 sorry in RecursiveSeed.lean

**Blocking Issues:**
- `buildSeedAux_preserves_seedConsistent` requires tracking consistency through each case of the buildSeedAux recursion. This is the primary blocking sorry for Phase 3.
- The proof requires showing that for each case of `buildSeedAux`, the `h_compat` condition of `addFormula_seed_preserves_consistent` holds - i.e., that inserting the formula into existing entries at that position preserves consistency.
- **Key insight from analysis**: The current hypothesis `h_pos_cons` (formulas at position are individually consistent) is too weak. The proof needs a stronger invariant that tracks:
  1. The seed is consistent (SeedConsistent)
  2. The formula being processed (phi) is IN the current position's formula set
  3. All formulas at current position are mutually compatible (not just individually consistent)

- **Goal:** Prove that if the starting formula is consistent, then every (family, time) entry in the seed is consistent. This is the mathematically hardest phase.

- **Key Insight (v002):** The diamond-box interaction lemma is the KEY LEMMA. When Box phi and neg(Box psi) are jointly consistent in the parent family, {phi, neg psi} is consistent in the witness family.

- **Tasks:**
  - [ ] Define `SeedConsistent : ModelSeed -> Prop` -- every entry's formula set is SetConsistent
  - [ ] Define `SeedWellFormed : ModelSeed -> Prop` -- structural invariants (unique entries per (family, time), valid indices)
  - [ ] Prove `initialSeedConsistent : FormulaConsistent phi -> SeedConsistent (initialSeed phi)` -- the singleton seed is consistent
  - [ ] Prove `addFormula_preserves_consistent` -- adding a formula derivable from existing formulas preserves consistency
  - [ ] Prove universal operator consistency: when Box phi is in a CS and we add phi to another CS, the result is consistent (T-axiom)
  - [ ] Prove existential operator consistency: creating a new entry with a single formula neg phi is always consistent (singleton sets)
  - [ ] **NEW (v002)**: Document and prove the **diamond-box interaction consistency lemma**:
    ```
    Lemma diamond_box_interaction:
      If {Box phi, neg(Box psi)} ⊆ S and SetConsistent S,
      then SetConsistent {phi, neg psi}
    Proof: By contraposition. If {phi, neg psi} is inconsistent, then phi ⊢ psi.
           By necessitation and K axiom: Box phi ⊢ Box psi.
           Then {Box phi, neg(Box psi)} derives Box psi and neg(Box psi), contradicting S consistent.
    ```
  - [ ] **NEW (v002)**: Document invariant explicitly:
    ```
    Invariant: At each recursive step, for each (family, time) entry:
      1. If temporal_witness: contains singleton {witness_formula}
      2. If universal_target: contains formulas derivable from parent + universal additions
      3. Cross-family Box additions: {phi, neg psi} consistent by diamond-box interaction lemma
    ```
  - [ ] Prove `buildSeedAux_preserves_consistent` by induction on formula complexity, using the above lemmas
  - [ ] Prove main theorem: `seedConsistent : FormulaConsistent phi -> SeedConsistent (buildSeed phi)`
  - [ ] Verify all proofs compile without sorry

- **Timing:** 8 hours

- **Files to modify:**
  - `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (extend)

- **Verification:**
  - `seedConsistent` compiles without sorry
  - **NEW**: Diamond-box interaction lemma explicitly proven
  - All intermediate lemmas compile without sorry
  - `lake build` succeeds

---

### Phase 4: Seed Completion to MCS Families [PARTIAL]

**Progress Update (2026-02-10, Session 3):**
- `seedFamilyMCS_is_mcs`: COMPLETED
- `seedFamilyMCS_contains_seed`: COMPLETED
- `modal_witness_includes_boxcontent`: 1 sorry
- `buildFamilyFromSeed`: 1 sorry (requires full construction)
- `buildFamilyFromSeed_cross_sign_seed`: 1 sorry
- `buildFamilyFromSeed_contains_seed`: 1 sorry

- **Goal:** Extend each seed entry's consistent set to a full MCS via Lindenbaum, then build `IndexedMCSFamily` instances for each family index, filling non-seed time indices using temporal chain construction.

- **Key Insight (v002):** Cross-sign handling has two cases:
  1. **Seed formulas**: Pre-placed by construction, no propagation needed
  2. **Lindenbaum-added formulas**: Use 4-axiom (`G phi -> G(G phi)`) to propagate through time 0

- **Tasks:**
  - [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean`
  - [ ] Define `extendSeedEntry : SeedEntry -> (h_cons : SetConsistent entry.formulas) -> Set Formula` -- extend via `set_lindenbaum`
  - [ ] Prove `extendSeedEntry_is_mcs` -- the extended set is a maximal consistent set
  - [ ] Prove `extendSeedEntry_contains_seed` -- the extended MCS contains all seed formulas
  - [ ] Define `seedFamilyMCS : ModelSeed -> Nat -> Int -> Set Formula` -- MCS at each (family, time) position in the seed
  - [ ] For diamond witness families: include `BoxContent(eval_family)` in the seed before Lindenbaum extension
  - [ ] For non-seed time indices within a family: use `TemporalContent` from TemporalChain.lean to fill in intermediate times
  - [ ] Define `buildFamilyFromSeed : ModelSeed -> Nat -> IndexedMCSFamily Int` -- construct full family from seed data
  - [ ] Prove `buildFamilyFromSeed_is_mcs` -- each time index has a valid MCS
  - [ ] Prove `buildFamilyFromSeed_forward_G` -- G formulas propagate forward
  - [ ] Prove `buildFamilyFromSeed_backward_H` -- H formulas propagate backward
  - [ ] **NEW (v002)**: Document cross-sign handling explicitly:
    ```
    Cross-sign handling for seed formulas:
      - G phi at seed time t < 0 needs phi at times t' >= 0
      - By seed construction, phi is ALREADY at all future seed times (including positive ones)
      - No propagation needed; verified by seed_contains proof

    Cross-sign handling for Lindenbaum-added formulas:
      - G phi added at time t < 0 by Lindenbaum
      - By 4-axiom: G phi -> G(G phi), so G phi is also in MCS at time t
      - G(G phi) propagates forward to time 0 (same-sign)
      - From time 0, G phi propagates to positive times (same-sign)
      - The base MCS at time 0 connects both chains via 4-axiom
    ```
  - [ ] **NEW (v002)**: Prove `buildFamilyFromSeed_cross_sign_G_via_four_axiom` -- cross-sign G via 4-axiom through time 0
  - [ ] Prove `buildFamilyFromSeed_contains_seed` -- seed formulas are in the constructed MCS
  - [ ] Verify file compiles with `lake build`

- **Timing:** 6.5 hours (was 6)

- **Files to create/modify:**
  - `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` (new file)

- **Verification:**
  - All family construction functions type-check
  - Forward_G and backward_H proofs compile without sorries
  - **NEW**: Cross-sign via 4-axiom proof compiles
  - Seed formula inclusion is proven
  - `lake build` succeeds

---

### Phase 5: BMCS Assembly and Coherence Proofs [PARTIAL]

**Progress Update (2026-02-10, Session 3):**
- `buildSeedBMCS.nonempty`: COMPLETED (using buildSeed_has_family_zero)
- `buildSeedBMCS.eval_family_mem`: COMPLETED (using buildSeed_has_family_zero)
- `buildSeedBMCS.modal_forward`: 1 sorry
- `buildSeedBMCS.modal_backward`: 1 sorry
- `construct_seed_bmcs`: 1 sorry
- `construct_seed_bmcs_contains_context`: 1 sorry
- `construct_seed_bmcs_temporally_coherent`: 1 sorry

- **Goal:** Assemble the seed-built families into a `BMCS` with proven modal_forward, modal_backward, and temporal coherence. This phase eliminates both axioms and **resolves task 843's Phase 1 blockage**.

- **Key Documentation (v002):** This phase supersedes task 843's two-chain architecture by using seed-based placement instead of chain-based propagation.

- **Tasks:**
  - [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean`
  - [ ] **NEW (v002)**: Add module documentation explaining task 843 blockage resolution:
    ```
    /-!
    # Seed-Based BMCS Construction

    This module constructs a BMCS from recursive seed construction, resolving
    task 843's Phase 1 blockage.

    ## Task 843 Blockage (DovetailingChain.lean)

    The two-chain architecture cannot support cross-sign temporal propagation:
    - Forward chain: 0, 1, 2, ... using GContent seeds
    - Backward chain: 0, -1, -2, ... using HContent seeds
    - G formulas at negative times cannot reach positive times
    - Interleaving construction order does not help (problem is seed content, not order)

    ## Resolution via Seed Construction

    This construction avoids the blockage by:
    1. Placing ALL temporal witnesses in seed BEFORE Lindenbaum extension
    2. Cross-sign propagation is not needed (witnesses pre-placed)
    3. For Lindenbaum-added formulas, 4-axiom propagates through time 0

    The 4 sorries in DovetailingChain.lean are no longer on the critical path.
    -/
    ```
  - [ ] Define `buildSeedBMCS : Formula -> (h_cons : FormulaConsistent phi) -> BMCS Int` -- main construction entry point
  - [ ] Collect all families from `buildFamilyFromSeed` for each family index in the seed
  - [ ] Prove `seedBMCS_nonempty` -- at least family 0 exists
  - [ ] Prove `seedBMCS_modal_forward` -- Box phi in any family at time t implies phi in all families at time t
  - [ ] Prove `seedBMCS_modal_backward` -- phi in all families at time t implies Box phi in each family at time t
  - [ ] Prove `seedBMCS_temporally_coherent` -- forward_F and backward_P hold for all families
  - [ ] Define `construct_seed_bmcs : List Formula -> ContextConsistent Gamma -> BMCS Int` -- wrapper for Completeness.lean
  - [ ] Prove `construct_seed_bmcs_contains_context` -- Gamma is in eval_family.mcs 0
  - [ ] Prove `construct_seed_bmcs_temporally_coherent` -- the BMCS is temporally coherent
  - [ ] Update `Completeness.lean` to use `construct_seed_bmcs` instead of `construct_temporal_bmcs`
  - [ ] **NEW (v002)**: Verify `temporal_coherent_family_exists_theorem` from DovetailingChain.lean is superseded
  - [ ] **NEW (v002)**: Verify the 4 sorries in DovetailingChain.lean are no longer on the critical path
  - [ ] Verify `bmcs_representation` still compiles
  - [ ] Verify `bmcs_weak_completeness` and `bmcs_strong_completeness` still compile
  - [ ] Comment out or remove `singleFamily_modal_backward_axiom` from Construction.lean
  - [ ] Comment out or remove `temporal_coherent_family_exists` from TemporalCoherentConstruction.lean
  - [ ] Run full `lake build` to verify no axiom dependencies remain

- **Timing:** 9 hours (was 8)

- **Files to create/modify:**
  - `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean` (new file)
  - `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (update construction calls)
  - `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (remove/comment axiom)
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (remove/comment axiom)

- **Verification:**
  - Full `lake build` succeeds with zero axioms on completeness critical path
  - `bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness` compile without sorry
  - `#print axioms bmcs_representation` shows no custom axioms
  - Both removed axioms are no longer referenced
  - **NEW**: DovetailingChain.lean sorries confirmed off critical path

---

### Phase 6: Verification, Documentation, and Cleanup [PARTIAL]

- **Goal:** Final verification that the construction is correct, clean up temporary constructs, add documentation, and verify the full build.

- **Tasks:**
  - [ ] Run `lake build` and verify zero build errors
  - [ ] Run `#print axioms bmcs_weak_completeness` and `#print axioms bmcs_strong_completeness` to verify axiom-free status
  - [ ] Count remaining sorries in new files (target: zero)
  - [ ] Add module-level documentation to `RecursiveSeed.lean` explaining the construction
  - [ ] Add module-level documentation to `SeedCompletion.lean` explaining the completion strategy
  - [ ] Add module-level documentation to `SeedBMCS.lean` explaining the BMCS assembly and task 843 resolution
  - [ ] Update imports in `Metalogic.lean` root file to include new modules
  - [ ] Verify DovetailingChain.lean still compiles (it should, as it is not modified)
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
- [ ] New files have zero sorries (target)
- [ ] Example formulas from research report produce correct seed structures
- [ ] The Truth Lemma continues to compile without modification
- [ ] **NEW (v002)**: DovetailingChain.lean sorries confirmed off critical path via `#print axioms`

## Artifacts & Outputs

- `specs/864_recursive_seed_henkin_model/plans/implementation-002.md` (this file)
- `specs/864_recursive_seed_henkin_model/plans/implementation-001.md` (previous version, preserved)
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/SeedBMCS.lean` (new)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (modified)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (modified)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (modified)
- `specs/864_recursive_seed_henkin_model/summaries/implementation-summary-YYYYMMDD.md` (completion summary)

## Rollback/Contingency

If the full axiom-free construction proves infeasible:

**Fallback A (Partial Success):** Replace 2 axioms (one FALSE) with 1 CORRECT axiom for modal coherence at non-seed time indices.

**Fallback B (Temporal Only):** Use seed construction only for temporal coherence while keeping the modal axiom.

**Rollback Procedure:**
1. Revert `Completeness.lean` to use `construct_temporal_bmcs`
2. Restore axiom declarations
3. New files can be retained as infrastructure for future attempts
4. `lake build` to verify rollback succeeds

## Relationship to Task 843

This implementation **supersedes task 843's Phase 1** (interleaved chain construction):

| Aspect | Task 843 (BLOCKED) | Task 864 (This Plan) |
|--------|-------------------|---------------------|
| Architecture | Two-chain (forward/backward) | Single seed with multiple families |
| Witness placement | During chain building | In seed BEFORE Lindenbaum |
| Cross-sign temporal | Cannot work (fundamental limitation) | Avoided (witnesses pre-placed) |
| Cross-sign for Lindenbaum | Not addressed | 4-axiom through time 0 |
| Status | Phase 1 BLOCKED | Ready to implement |

After this implementation:
- Task 843's Phase 1 should be marked SUPERSEDED
- Task 843's Phase 4 (FALSE axiom replacement) remains valuable and is preserved
- Task 865's canonical task frame can build on seed-constructed BMCS
