# Implementation Plan: Burgess-Xu Clean-Break Refactor

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 20-30 hours
- **Dependencies**: None
- **Research Inputs**: reports/33_team-research.md (4-teammate synthesis on BX axiom system, unsoundness audit, canonical model design)
- **Artifacts**: plans/33_bx-refactor.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace the current mixed-semantics axiom system (G/H reflexive, U/S strict) and successor-chain completeness architecture with the Burgess-Xu (BX) axiom system under all-reflexive semantics. The forward_F circularity that blocked 31 rounds of research is structural -- an artifact of the successor-chain construction -- and cannot be fixed within the current architecture. The BX system dissolves this circularity entirely: BX5 (self-accumulation) and BX6 (absorption) resolve Until-eventualities axiomatically, and the canonical model truth lemma for G uses MCS negation completeness directly without forward_F. The refactor replaces ~35 axiom constructors with ~25 BX constructors, proves all sorry-free soundness, builds a new BX canonical model completeness proof, and archives the chain infrastructure to Boneyard/.

### Research Integration

Key findings from reports/33_team-research.md (4 teammates, all HIGH confidence on core design):

1. **Root cause confirmed**: Mixed U/S strict semantics + deterministic chain + Next-based Until axioms create an irresolvable circularity (all 4 teammates agree)
2. **Semantic change**: 2-line edit in Truth.lean switching Until/Since witness from strict (`<`/`>`) to reflexive (`<=`/`>=`), guards remain open `(t, s)`
3. **Unsound axioms identified**: F_until_equiv and P_since_equiv are unsound under current strict semantics (sorry at Soundness.lean:770,786)
4. **BX axiom system**: 14 new temporal axioms (7 schemas x 2 mirrors) replacing 16 discrete axioms + density + several base temporals
5. **Completeness architecture**: BX canonical model using Zorn's lemma for maximal chains, eventuality resolution via BX5/BX6

## Goals & Non-Goals

**Goals**:
- Switch U/S semantics from strict to reflexive (2-line change, re-prove affected lemmas)
- Replace axiom system with BX + S5 (~25 constructors, all sorry-free soundness)
- Build BX canonical model completeness proof (Frame, Ordering, EventualityResolution, TruthLemma, Completeness)
- Prove key derived temporal principles from BX axioms (G-distribution, G-transitivity, phi -> G(P(phi)))
- Archive chain infrastructure to Boneyard/ after new modules compile
- Eliminate the 2 main sorries (succ_chain_restricted_forward_F/backward_P) and the 2 auxiliary sorries in Soundness.lean (F_until_equiv_valid, P_since_equiv_valid)

**Non-Goals**:
- FMP TruthPreservation (task 82)
- dense_completeness_fc (task 68)
- Discrete completeness (future work -- BX provides base/dense only)
- Changing the Formula inductive type (keep untl/snce constructors as-is)
- Fixing forward_F within the chain architecture (31 failed rounds is sufficient evidence)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BX completeness harder than expected (never formalized in any proof assistant) | H | 70% | Validate BX soundness proofs first (Phase 2); if soundness succeeds, completeness confidence rises; if it fails, stop early |
| BX4 (connectedness) or BX7 (linearity) soundness proof harder than expected | M | 50% | Prove these first as validation gate in Phase 2; they have the most complex semantic arguments |
| Pattern match cascade from Axiom type change | L | 40% | Single phase handles all Axiom-dependent files; lake build catches exhaustiveness |
| Reflexive U/S creates unexpected semantic interactions | M | 30% | Guards remain open (t,s) -- no half-open intervals; prove F(phi) <-> top U phi early as validation |
| Chain infrastructure loss before new proof works | H | 40% | Archive to Boneyard/ in separate phase AFTER new modules compile; git preserves full history |
| Zorn's lemma wiring for maximal chain construction | M | 40% | Mathlib provides zorn_subset_nonempty; verify Lean API early in Phase 4 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Semantic Foundation -- Reflexive Until/Since [COMPLETED]

**Goal**: Switch Until/Since witness from strict to reflexive and re-prove all affected Truth.lean lemmas. This is the foundational 2-line change that everything else builds on.

**Tasks**:
- [ ] Edit `Truth.lean:127`: change `t < s` to `t ≤ s` in Until witness
- [ ] Edit `Truth.lean:129`: change `s < t` to `s ≤ t` in Since witness
- [ ] Update the docstring and module header to reflect reflexive U/S semantics
- [ ] Re-prove all Truth.lean lemmas broken by the witness change (identify via `lake build`)
- [ ] Prove new semantic theorem: `F(phi) <-> top U phi` under reflexive semantics (witness s = t gives empty guard, so phi U psi at t holds iff psi holds at t; top U phi at t holds iff phi at some s >= t)
- [ ] Prove new semantic theorem: `P(phi) <-> top S phi` (mirror)
- [ ] Verify that G/H semantics (lines 125-126) are UNCHANGED (already reflexive <=/>= )
- [ ] Verify interaction axiom soundness is unaffected (modal_future, temp_future use G/H only)
- [ ] Run `lake build` -- expect failures in Soundness.lean and downstream files that reference strict Until/Since; catalog all failures

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- 2-line semantic change + re-prove lemmas + new theorems (~80 LOC)

**Verification**:
- Truth.lean compiles with zero sorry
- F(phi) <-> top U phi proved as semantic theorem
- Lake build catalog shows expected failures only in Soundness/Axioms/downstream

---

### Phase 2: Axiom System Replacement + Soundness [COMPLETED]

**Goal**: Replace the Axiom inductive with BX constructors and prove sorry-free soundness for all axioms. This is the validation gate -- if BX soundness proofs succeed, the refactor is viable.

**Tasks**:
- [ ] **Axioms.lean**: Replace the `Axiom` inductive type:
  - KEEP: prop_k, prop_s, ex_falso, peirce (4 propositional)
  - KEEP: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist (5 S5 modal)
  - KEEP: temp_t_future, temp_t_past (BX1/BX1' -- already exist)
  - ADD: left_mono_until, left_mono_since (BX2/BX2' -- left monotonicity)
  - ADD: right_mono_until, right_mono_since (BX3/BX3' -- right monotonicity)
  - ADD: connect_until_since, connect_since_until (BX4/BX4' -- connectedness)
  - ADD: self_accum_until, self_accum_since (BX5/BX5' -- self-accumulation)
  - ADD: absorb_until, absorb_since (BX6/BX6' -- absorption)
  - ADD: linear_until, linear_since (BX7/BX7' -- linearity)
  - KEEP: modal_future, temp_future (2 interaction axioms)
  - REMOVE: temp_k_dist, temp_4, temp_a, temp_a_dual, temp_l, temp_linearity (derivable from BX)
  - REMOVE: density (derivable from BX1 under reflexive G)
  - REMOVE: ALL 16 discrete axioms (discreteness_forward, seriality_*, disc_next/prev, until_unfold/intro/induction, since_unfold/intro/induction, until/since_linearity, until/since_connectedness, F_until_equiv, P_since_equiv)
- [ ] **Axioms.lean**: Update `isBase`, `isDenseCompatible`, `isDiscreteCompatible` classification predicates
  - isBase = all BX axioms (BX1-BX7, S5, interaction, propositional)
  - isDenseCompatible = isBase (no separate dense axiom needed)
  - isDiscreteCompatible = future extension point (stubs only)
- [ ] **Axioms.lean**: Update `frameClass` assignment for new constructors
- [ ] **Substitution.lean**: Update substitution lemma match cases for new axiom constructors (~50 LOC)
- [ ] **Derivation.lean**: Verify inference rules still apply (MP, NEC_Box, NEC_G, NEC_H, temporal_duality, weakening). No changes expected -- BX uses same rules
- [ ] **Soundness.lean**: Remove F_until_equiv_valid and P_since_equiv_valid (currently sorry)
- [ ] **Soundness.lean**: Prove soundness for BX2-BX7 (12 new axioms, ~400 LOC):
  - BX2/BX2' (left_mono): Straightforward from monotonicity of quantifiers
  - BX3/BX3' (right_mono): Straightforward from monotonicity of quantifiers
  - BX4/BX4' (connect): Most complex -- requires careful interval reasoning with reflexive witness
  - BX5/BX5' (self_accum): phi U psi -> (phi /\ phi U psi) U psi -- enrich guard with eventuality
  - BX6/BX6' (absorb): phi U (phi /\ phi U psi) -> phi U psi -- collapse intermediate
  - BX7/BX7' (linear): Linearity of temporal order -- case split on witness ordering
- [ ] **Soundness.lean**: Update `axiom_valid` master theorem to handle new constructors, remove old cases
- [ ] **SoundnessLemmas.lean**: Update bridge theorems for new axiom set (~200 LOC)
- [ ] **FrameConditions/Compatibility.lean**: Update compatibility instances for BX constructors (~50 LOC)
- [ ] **FrameConditions/Soundness.lean**: Update frame-class soundness if needed
- [ ] Run `lake build` on all modified files -- target: zero sorry in Soundness.lean

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Replace axiom inductive (~200 LOC)
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- Update match cases (~50 LOC)
- `Theories/Bimodal/ProofSystem/Derivation.lean` -- Verify, minimal changes
- `Theories/Bimodal/Metalogic/Soundness.lean` -- New BX soundness proofs (~400 LOC)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- Update bridge theorems (~200 LOC)
- `Theories/Bimodal/FrameConditions/Compatibility.lean` -- Update instances (~50 LOC)
- `Theories/Bimodal/FrameConditions/Soundness.lean` -- Update if needed

**Verification**:
- All BX axiom soundness proofs compile with zero sorry
- `lake build Bimodal.Metalogic.Soundness` succeeds
- `lake build Bimodal.ProofSystem` succeeds
- Axiom count: ~25 constructors (down from 35)

---

### Phase 3: Derived Theorems + Match Exhaustiveness [NOT STARTED]

**Goal**: Recover key derived temporal theorems from BX axioms and fix all pattern match exhaustiveness failures across the codebase caused by the Axiom type change.

**Tasks**:
- [ ] **TemporalDerived.lean**: Prove G-distribution from BX axioms:
  - G(phi -> psi) -> (G(phi) -> G(psi)) derivable from BX1 (temp_t_future) + NEC_G + prop_k
- [ ] **TemporalDerived.lean**: Prove G-transitivity:
  - G(phi) -> G(G(phi)) derivable from BX1 + NEC_G (instantiate BX1 with G(phi))
- [ ] **TemporalDerived.lean**: Prove phi -> G(P(phi)) from BX4 (connectedness)
- [ ] **TemporalDerived.lean**: Prove phi -> H(F(phi)) from BX4' (connectedness mirror)
- [ ] **TemporalDerived.lean**: Prove density derivable: G(G(phi)) -> G(phi) from BX1 (trivial -- BX1 gives G(phi) -> phi, instantiate with G(phi))
- [ ] **TemporalDerived.lean**: Remove or simplify G_implies_topUntil (no longer needed -- was F_until_equiv dependent)
- [ ] **TemporalDerived.lean**: Remove or simplify G_implies_X, H_implies_Y (X/Y are discrete-only under BX)
- [ ] **TemporalDerived.lean**: Remove or simplify X_bot_absurd, Y_bot_absurd, x_nec', y_nec' (X/Y discrete-only)
- [ ] **TemporalDerived.lean**: Assess XY_identity, YX_identity, YG_implies_self, XH_implies_self -- mark as discrete-extension or remove
- [ ] Fix all pattern match exhaustiveness errors across the codebase:
  - `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` -- Update axiom-dependent matches
  - `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` -- Update if needed
  - `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- Update if needed
  - `Theories/Bimodal/Theorems/Discreteness.lean` -- Will break (depends on discrete axioms); comment out or guard
  - `Theories/Bimodal/Theorems/Perpetuity/` -- Verify; should be unaffected (uses G/H only)
  - `Theories/Bimodal/Theorems/ModalS5.lean` -- Verify; should be unaffected
  - `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` -- Update match cases
  - `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- Update or remove (temp_linearity removed)
  - Any other files found via `lake build` errors
- [ ] Run `lake build` iteratively -- fix all compilation errors from axiom type change
- [ ] Add BX-specific MCS properties to MCSProperties.lean if needed (~100 LOC):
  - Until left/right monotonicity in MCS
  - Until self-accumulation in MCS
  - Until absorption in MCS

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- Major rewrite (~200 LOC net)
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` -- Add BX MCS properties (~100 LOC)
- `Theories/Bimodal/Theorems/Discreteness.lean` -- Comment out or guard discrete-dependent code
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- Update or remove
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` -- Update match cases
- ~5-10 other files with exhaustiveness errors (identified by lake build)

**Verification**:
- `lake build` succeeds with zero new sorry (existing sorries in chain code expected)
- G-distribution, G-transitivity, phi -> G(P(phi)) proved from BX axioms
- All pattern match exhaustiveness resolved
- No regressions in Propositional, ModalS5, ModalS4, Perpetuity theorems

---

### Phase 4: BX Canonical Model Completeness [NOT STARTED]

**Goal**: Build the new BX canonical model completeness proof in a new `Metalogic/BXCanonical/` module directory. This is the highest-risk phase but also where the main sorries get eliminated.

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Metalogic/BXCanonical/`
- [ ] **BXCanonical/Frame.lean** (~200 LOC): Define BX canonical frame
  - `BXCanonicalPoint`: Structure wrapping MCS (reuse existing `SetMaximalConsistent`)
  - `canonical_temporal_le`: w <= v iff for all phi, G(phi) in w.formulas implies phi in v.formulas
  - `canonical_temporal_ge`: w >= v iff for all phi, H(phi) in w.formulas implies phi in v.formulas
  - `canonical_modal_equiv`: w ~ v iff for all phi, box(phi) in w.formulas iff box(phi) in v.formulas
  - Prove canonical_temporal_le is a preorder (reflexive from BX1, transitive from BX1 + NEC_G)
  - Prove canonical_temporal_le is a linear order (from BX7, linearity axiom)
  - Prove canonical_modal_equiv is an equivalence relation (from S5 axioms)
- [ ] **BXCanonical/Ordering.lean** (~300 LOC): Prove canonical ordering properties
  - Linearity: for any w, v, either w <= v or v <= w (from BX7)
  - Antisymmetry: w <= v and v <= w implies w = v for MCS (from G(phi) -> phi both directions)
  - Connection to modal: w ~ v implies same modal content (from interaction axioms)
  - Prove the ordering is compatible with Until: if phi U psi in w and w <= v, derive consequences
- [ ] **BXCanonical/EventualityResolution.lean** (~500 LOC): The key new component
  - Define `UntilEventuality`: a formula phi U psi that needs witness resolution
  - Prove BX5 in MCS context: if phi U psi in w, then (phi /\ (phi U psi)) U psi in w
  - Prove BX6 in MCS context: absorption prevents infinite deferral
  - Define `resolves_eventuality`: an MCS v resolves phi U psi if psi in v and phi holds at all intermediate points
  - Prove eventuality resolution theorem: for any MCS w with phi U psi in w, there exists v >= w where psi in v and phi holds on (w, v)
  - Use Zorn's lemma (Mathlib `zorn_subset_nonempty` or `zorn_partialOrder`) for maximal chain construction
  - Handle the Since mirror cases
- [ ] **BXCanonical/TruthLemma.lean** (~400 LOC): BX truth lemma by formula induction
  - atom case: standard MCS valuation (reuse existing infrastructure)
  - bot case: trivial
  - imp case: MCS maximality (reuse existing)
  - box case: canonical modal equivalence (reuse existing modal saturation)
  - all_future (G) forward case: BX1 + canonical ordering definition
  - all_future (G) backward case: MCS negation completeness -- if G(phi) not in w then F(neg phi) in w, so exists v >= w with neg(phi) in v, contradicting hypothesis
  - all_past (H) cases: mirror of G cases
  - untl (phi U psi) forward case: eventuality resolution from BXCanonical/EventualityResolution.lean (hardest case)
  - untl (phi U psi) backward case: BX4 connectedness + MCS properties
  - snce (phi S psi) cases: mirror of Until cases
- [ ] **BXCanonical/Completeness.lean** (~200 LOC): Wire everything together
  - Construct BX canonical TaskModel from the canonical frame
  - State and prove the BX completeness theorem: if valid phi then Derivable [] phi
  - Contrapositive: if not Derivable [] phi, extend {neg phi} to MCS w, build canonical model, truth lemma gives model where neg phi holds, contradicting validity
- [ ] **BXCanonical/BXCanonical.lean** (~20 LOC): Module file importing all BXCanonical submodules
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` to import BXCanonical
- [ ] Wire BXCanonical completeness to BaseCompleteness.lean
- [ ] Wire to DenseCompleteness.lean (= base completeness, no additional axioms needed under BX)
- [ ] Run `lake build` on BXCanonical modules

**Timing**: 2 hours (initial structure and Frame/Ordering), then iterative refinement over multiple sessions

**Depends on**: 3

**Files to create**:
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (~200 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/Ordering.lean` (~300 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/EventualityResolution.lean` (~500 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` (~400 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (~200 LOC)
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` (~20 LOC)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` -- Import BXCanonical
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` -- Wire to BX completeness
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` -- Wire to base (= BX)

**Verification**:
- All BXCanonical modules compile
- Completeness theorem stated and proved (may have targeted sorry in EventualityResolution initially)
- BaseCompleteness wired through BXCanonical
- DenseCompleteness = BaseCompleteness (trivial)

---

### Phase 5: Archive Chain Infrastructure to Boneyard [NOT STARTED]

**Goal**: Move the old successor-chain completeness code to Boneyard/ and remove it from the build path. Only do this AFTER Phase 4 modules compile.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/ChainCompleteness/` directory
- [ ] Move chain files to Boneyard (preserving for reference, not compiled):
  - `Metalogic/Algebraic/DeterministicChain.lean`
  - `Metalogic/Algebraic/DeterministicFMCS.lean`
  - `Metalogic/Algebraic/DovetailedChain.lean`
  - `Metalogic/Algebraic/FiniteDeferral.lean`
  - `Metalogic/Algebraic/UltrafilterChain.lean`
  - `Metalogic/Algebraic/RestrictedTruthLemma.lean`
  - `Metalogic/Bundle/SuccChainFMCS.lean`
  - `Metalogic/Bundle/SuccChainTaskFrame.lean`
  - `Metalogic/Bundle/SuccChainTruth.lean`
  - `Metalogic/Bundle/SuccChainWorldHistory.lean`
  - `Metalogic/Bundle/SuccExistence.lean`
  - `Metalogic/Bundle/SuccRelation.lean`
  - `Metalogic/Bundle/TargetedChain.lean`
  - `Metalogic/Bundle/TemporalCoherence.lean`
  - `Metalogic/Bundle/TemporalContent.lean`
  - `Metalogic/Bundle/WitnessSeed.lean`
  - `Metalogic/Bundle/MCSWitnessChain.lean`
  - `Metalogic/Bundle/MCSWitnessSuccessor.lean`
  - `Metalogic/Bundle/SimplifiedChain.lean`
  - `Metalogic/Bundle/ResolvingChain.lean`
  - `Metalogic/Completeness/SuccChainCompleteness.lean`
- [ ] Update `Metalogic/Algebraic/Algebraic.lean` to remove chain imports
- [ ] Update `Metalogic/Bundle/FMCS.lean` or related import files to remove chain imports
- [ ] Update `Metalogic/Metalogic.lean` to remove chain imports
- [ ] Update `Metalogic/Completeness/Completeness.lean` to remove SuccChainCompleteness import
- [ ] Update `FrameConditions/Completeness.lean` to remove chain references
- [ ] Run `lake build` -- verify clean build without chain code

**Timing**: 1 hour

**Depends on**: 4

**Files to move** (to Boneyard/ChainCompleteness/):
- 21 files listed above (~15,000+ LOC archived)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` -- Remove imports
- `Theories/Bimodal/Metalogic/Bundle/FMCS.lean` -- Remove imports
- `Theories/Bimodal/Metalogic/Metalogic.lean` -- Remove imports
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` -- Remove imports
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- Update references

**Verification**:
- `lake build` succeeds with zero chain-related imports
- All Boneyard files are NOT compiled (no import path reaches them)
- No regressions in any compiled module

---

### Phase 6: Integration Testing + Sorry Audit + Extension Hooks [NOT STARTED]

**Goal**: Final validation that the refactor is complete: zero sorry in core path, extension hooks for discrete completeness, and full lake build clean.

**Tasks**:
- [ ] Run full `lake build` and verify success
- [ ] Run sorry audit: `grep -rn "sorry" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard | grep -v "sorry-free\|-- sorry\|/-"` -- catalog all remaining sorry
- [ ] Verify the 4 target sorries are eliminated:
  - succ_chain_restricted_forward_F (was UltrafilterChain.lean:3939) -- archived
  - succ_chain_restricted_backward_P (was UltrafilterChain.lean:3949) -- archived
  - F_until_equiv_valid (was Soundness.lean:770) -- removed
  - P_since_equiv_valid (was Soundness.lean:786) -- removed
- [ ] Verify the 2 auxiliary sorries are eliminated:
  - restricted_chain_G_step (was RestrictedTruthLemma.lean) -- archived
  - restricted_chain_H_step (was RestrictedTruthLemma.lean) -- archived
- [ ] Add discrete extension stubs:
  - Define `DiscreteExtensionAxiom` inductive in a new file or stub section (DF, seriality, SuccOrder constraints)
  - Document that X(phi) = bot U phi and Y(phi) = bot S phi are discrete-only derived operators
  - Leave DiscreteCompleteness.lean as stub pointing to future work
- [ ] Add extension hook for eventuality resolution:
  - Define typeclass or structure `EventualityResolver` abstracting BX5/BX6 resolution pattern
  - Base instance: BX canonical model resolution
  - Discrete instance: stub (successor chain resolution, future work)
- [ ] Update module docstrings across all modified files to reflect BX architecture
- [ ] Update `Theories/Bimodal/README.md` if it references the old architecture
- [ ] Run tests: `lake build BimodalTest` (if test suite exists)

**Timing**: 1 hour

**Depends on**: 4

**Files to create**:
- Extension hook file (small, ~50-80 LOC)

**Files to modify**:
- `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean` -- Update stub
- Various docstrings across modified files
- `Theories/Bimodal/README.md` -- Update architecture description

**Verification**:
- Full `lake build` clean
- Sorry count in non-Boneyard code reduced (target: eliminate all 4 main + 2 auxiliary sorries)
- Discrete extension stubs compile
- All docstrings accurate

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase (incremental validation)
- [ ] Phase 1 gate: Truth.lean compiles, F(phi) <-> top U phi proved semantically
- [ ] Phase 2 gate: All BX axiom soundness proofs sorry-free (CRITICAL validation gate)
- [ ] Phase 3 gate: Full `lake build` succeeds with all pattern matches resolved
- [ ] Phase 4 gate: BXCanonical modules compile, completeness theorem stated
- [ ] Phase 5 gate: Chain code archived, `lake build` clean without chain imports
- [ ] Phase 6 gate: Zero target sorry, sorry audit clean, extension hooks in place
- [ ] Regression check: Propositional, ModalS5, ModalS4, Perpetuity theorems unaffected
- [ ] Regression check: Algebraic infrastructure (BooleanStructure, LindenbaumQuotient, TenseS5Algebra, InteriorOperators, UltrafilterMCS) unaffected

## Artifacts & Outputs

- `plans/33_bx-refactor.md` (this file)
- `Theories/Bimodal/Semantics/Truth.lean` -- Reflexive U/S semantics
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- BX axiom system
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Sorry-free BX soundness
- `Theories/Bimodal/Metalogic/BXCanonical/` -- New completeness architecture (5 files)
- `Theories/Bimodal/Boneyard/ChainCompleteness/` -- Archived chain code (~21 files)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- BX-derived temporal principles

## Rollback/Contingency

The refactor is structured for safe rollback at each phase boundary:

- **After Phase 1**: Revert Truth.lean semantic change (2 lines). All downstream still works with old semantics.
- **After Phase 2**: If BX soundness proofs fail (especially BX4/BX7), revert Axioms.lean and Soundness.lean to old constructors. This is the primary decision gate.
- **After Phase 3**: If derived theorem recovery is problematic, revert TemporalDerived.lean.
- **After Phase 4**: If BX completeness is incomplete, keep sorry in EventualityResolution.lean. The BX architecture is still superior to the chain architecture even with internal sorry, because it eliminates the structural circularity.
- **After Phase 5**: If build breaks after archival, restore chain imports from Boneyard/ (files are preserved, not deleted).

Git preserves the entire chain architecture in version control. The Boneyard/ archive provides easy reference without cluttering the build path.

**Critical invariant**: Never delete chain code until Phase 4 BXCanonical modules compile. Phase 5 is strictly gated on Phase 4 success.
