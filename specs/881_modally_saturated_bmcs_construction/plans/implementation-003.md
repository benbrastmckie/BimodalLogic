# Implementation Plan: Task #881 (Version 3)

- **Task**: 881 - Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
- **Status**: [IMPLEMENTING]
- **Effort**: 10-14 hours
- **Dependencies**: None (builds on completed Phase 1 and research findings)
- **Research Inputs**: research-007.md (constant families analysis), research-008.md (semantic alignment)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements the zero-compromise dovetailing path identified in research-007.md. The key insight is that constant witness families (used by modal saturation) are a DESIGN CHOICE, not mathematical necessity. The conflict between temporal coherence and modal saturation exists because constant families require temporally-saturated MCS, which is impossible for arbitrary consistent sets (counterexample: `{F(p), not p}`).

**Resolution Strategy**: Build witness families via dovetailing chain construction (non-constant) instead of constant Lindenbaum extension. This requires fixing the 4 DovetailingChain sorries first, then modifying the modal saturation construction to use dovetailing per-witness.

### Research Integration

Reports integrated:
- research-007.md: Proved constant families are simplification choice, identified zero-compromise path
- research-008.md: Confirmed semantic alignment (history-based semantics throughout)

Key findings:
- 4 DovetailingChain sorries are the critical blockers (lines 606, 617, 633, 640)
- Modal saturation (`exists_fullySaturated_extension`) is sorry-free but uses constant families
- Constant families need `F psi -> psi` in MCS, which is impossible for general consistent sets
- Solution: Build witness families via dovetailing (non-constant, temporally coherent by construction)

## Goals & Non-Goals

**Goals**:
- Fix the 4 DovetailingChain.lean sorries (forward_G cross-sign, backward_H cross-sign, forward_F witness, backward_P witness)
- Create infrastructure for building temporally coherent witness families via dovetailing
- Modify modal saturation to use temporally coherent witness construction
- Eliminate the `fully_saturated_bmcs_exists_int` sorry (line 842 of TemporalCoherentConstruction.lean)
- Achieve zero new axioms and zero new sorries on the critical path

**Non-Goals**:
- Fixing TemporalLindenbaum.lean sorries (dead end per task 882 analysis)
- Generic D support (Int is sufficient for completeness)
- Supporting dense time types (Rat, Real)
- Restructuring TruthLemma.lean (maintains current structure)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-sign propagation more complex than expected | High | Medium | Fall back to GContent tracking from ALL assigned times via auxiliary lemmas |
| Witness enumeration for F/P formulas difficult | High | Medium | Use Nat.unpair-based dovetailing with explicit encoding |
| Non-constant witness families complicate box_coherence | Medium | Low | S5 axiom 5 already proven; use box_coherent_constant_boxcontent_complete pattern |
| GContent/HContent from non-constant families harder | Medium | Medium | Track BoxContent dynamically using time-indexed sets |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean:842) - main target
- 4 sorries in DovetailingChain.lean:
  - Line 606: `forward_G` cross-sign (t < 0)
  - Line 617: `backward_H` cross-sign (t >= 0)
  - Line 633: `forward_F` witness enumeration
  - Line 640: `backward_P` witness enumeration
- 1 sorry in `temporal_coherent_family_exists` generic D (line 636) - not on critical path (only Int used)

### Expected Resolution
- Phase 1: Resolves cross-sign sorries (lines 606, 617) via GContent/HContent tracking
- Phase 2: Resolves witness sorries (lines 633, 640) via dovetailing enumeration
- Phase 3: Creates dovetailing witness construction infrastructure
- Phase 4: Eliminates `fully_saturated_bmcs_exists_int` sorry by wiring components

### New Sorries
- None expected. All temporal witnesses placed in seed before Lindenbaum extension.

### Remaining Debt
After this implementation:
- 0 sorries on critical path (`fully_saturated_bmcs_exists_int` becomes sorry-free theorem)
- `temporal_coherent_family_exists` generic D sorry remains (not on critical path)
- TemporalLindenbaum.lean sorries remain (dead end, not on critical path)

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in TemporalCoherentConstruction.lean: `fully_saturated_bmcs_exists` (line 778, deprecated)
- 0 axioms in DovetailingChain.lean (replaced axiom with sorry-backed theorem)
- 1 axiom in Construction.lean: `singleFamily_modal_backward_axiom` (not directly addressed)

### Expected Resolution
- Phase 4 eliminates `fully_saturated_bmcs_exists_int` sorry, making it a true theorem
- The deprecated `fully_saturated_bmcs_exists` axiom can then be removed
- No new axioms introduced

### New Axioms
- None. NEVER introduce new axioms. All gaps resolved through structural proofs.

### Remaining Debt
After this implementation:
- 0 axioms for fully saturated BMCS construction (Int case)
- `singleFamily_modal_backward_axiom` remains (separate issue, used by single-family path)

## Implementation Phases

### Phase 1: Fix DovetailingChain Cross-Sign Propagation [BLOCKED]

- **Dependencies:** None
- **Goal:** Fix sorries at lines 606 and 617 for cross-sign G/H propagation

**Analysis of the Problem**:
The current construction builds forward chain (non-negative times) and backward chain (non-positive times) separately, joined at time 0. The cross-sign case arises when:
- `forward_G` at t < 0: G phi in M_t (backward chain) must imply phi in M_{t'} for t' > 0 (forward chain)
- `backward_H` at t >= 0: H phi in M_t (forward chain) must imply phi in M_{t'} for t' < 0 (backward chain)

**Solution Approach**:
At the shared base MCS (time 0):
1. G phi at t < 0 propagates G phi to M_0 via backward HContent seeds
2. G phi at M_0 propagates phi to M_{t'} for t' > 0 via forward GContent seeds

**Tasks**:
- [ ] Add lemma `dovetailChainSet_G_propagates_to_zero`: G phi at t < 0 implies G phi at M_0
- [ ] Add lemma `dovetailChainSet_cross_sign_forward_G`: Combines propagation to 0 with forward chain
- [ ] Fix `buildDovetailingChainFamily.forward_G` at line 606 using cross_sign_forward_G
- [ ] Add symmetric lemmas for H propagation
- [ ] Fix `buildDovetailingChainFamily.backward_H` at line 617
- [ ] Verify with `lake build`

**Key Insight**:
For G phi at t < 0, we need to show phi reaches the forward chain. The path is:
```
G phi ∈ M_t (t < 0)
→ G(G phi) ∈ M_t (by 4 axiom: G phi → G(G phi))
→ G phi ∈ HContent(M_t) (by definition of HContent)
→ G phi ∈ M_{t+1} (backward chain extends HContent)
→ ... (propagate to M_0)
→ G phi ∈ M_0
→ phi ∈ GContent(M_0)
→ phi ∈ M_1 (forward chain extends GContent)
→ ... (propagate to any t' > 0)
```

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

**Verification**:
- `lake build` succeeds
- Sorries at lines 606 and 617 eliminated
- `buildDovetailingChainFamily.forward_G` and `backward_H` fully proven

---

### Phase 2: Implement F/P Witness Enumeration [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Fix sorries at lines 633 and 640 for F/P witness construction

**Analysis of the Problem**:
The current construction does not place witnesses for F/P formulas. When F psi ∈ M_t, we need to ensure some M_s (s > t) contains psi.

**Solution Approach** (Dovetailing Enumeration):
Enumerate all (time, formula) pairs using Nat.unpair. At construction step n:
1. Decode step n to (t, k) via Nat.unpair
2. Get the k-th formula psi from a formula enumeration
3. If processing time t' = dovetailIndex(n) > t and F(psi) ∈ M_t, include psi in seed for M_{t'}

**Tasks**:
- [ ] Define `FormulaEnumeration`: Type of enumerable formula assignments
- [ ] Define `witnessEnumerationStep`: Given step n, returns (source_time, formula, is_F_or_P)
- [ ] Define `FWitnessSeed`: Set of formulas to add at time t from F-witness obligations
- [ ] Prove `FWitnessSeed_consistent`: Adding F-witnesses preserves seed consistency
- [ ] Modify seed construction to include FWitnessSeed
- [ ] Prove `forward_F_witness_exists`: F psi at t implies psi at some s > t
- [ ] Symmetric construction for P witnesses (PWitnessSeed)
- [ ] Fix `buildDovetailingChainFamily_forward_F` at line 633
- [ ] Fix `buildDovetailingChainFamily_backward_P` at line 640
- [ ] Verify with `lake build`

**Key Insight**:
The dovetailing enumeration ensures every (time, formula) pair is eventually processed. For F psi at time t:
- Eventually, step n will encode (t, psi)
- At this step, we construct some M_{t'} with t' > t
- The seed for M_{t'} includes psi (via FWitnessSeed)
- Lindenbaum preserves psi in the extended MCS

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

**Verification**:
- `lake build` succeeds
- Sorries at lines 633 and 640 eliminated
- `temporal_coherent_family_exists_theorem` becomes sorry-free

---

### Phase 3: Create Dovetailing Witness Family Infrastructure [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Build infrastructure for modal saturation to use dovetailing witnesses instead of constant families

**Analysis**:
The current `exists_fullySaturated_extension` uses `constantWitnessFamily` for Diamond witnesses. These constant families need temporally-saturated MCS (F psi -> psi, P psi -> psi), which is impossible.

**Solution**:
Replace constant witness construction with dovetailing witness construction. When adding a witness for Diamond psi:
1. Create seed containing psi + BoxContent from existing families
2. Build dovetailing chain from this seed (non-constant family)
3. The resulting family is temporally coherent by construction (from Phase 2)

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/DovetailingWitness.lean`
- [ ] Define `buildDovetailingWitnessFamily`: Given seed, build temporally coherent family
- [ ] Prove `dovetailingWitnessFamily_contains_seed`: Seed is preserved at time 0
- [ ] Prove `dovetailingWitnessFamily_temporally_coherent`: forward_F and backward_P hold
- [ ] Prove `dovetailingWitnessFamily_extends_boxcontent`: BoxContent from other families is preserved
- [ ] Adapt `diamond_box_coherent_consistent` for dovetailing context
- [ ] Verify with `lake build`

**Key Design**:
```lean
/-- Build a temporally coherent witness family for a Diamond formula. -/
noncomputable def buildDovetailingWitnessFamily
    (BoxContent : Set Formula)
    (psi : Formula)
    (h_seed_cons : SetConsistent ({psi} ∪ BoxContent)) :
    IndexedMCSFamily Int :=
  -- Use buildDovetailingChainFamily with seed = {psi} ∪ BoxContent
  -- This produces a non-constant family with temporal coherence
```

**Timing**: 2-3 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingWitness.lean`

**Files to modify**:
- `Theories/Bimodal.lean` - Add import

**Verification**:
- `lake build` succeeds
- `buildDovetailingWitnessFamily` compiles with no sorries
- Temporal coherence proven for witness families

---

### Phase 4: Wire to Axiom Elimination [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Modify modal saturation to use dovetailing witnesses, eliminating the BMCS existence sorry

**Analysis**:
The `exists_fullySaturated_extension` theorem in SaturatedConstruction.lean:
1. Uses Zorn's lemma to find maximal family collection
2. Uses `constantWitnessFamily` when extending collection
3. Is sorry-free but produces constant (non-temporally-coherent) witness families

**Solution**:
Create a variant that uses dovetailing witness families:
1. Start with temporally coherent eval family (from DovetailingChain)
2. Use `buildDovetailingWitnessFamily` for Diamond witnesses
3. Each witness family is temporally coherent by construction
4. Box coherence is preserved by including BoxContent in seed

**Tasks**:
- [ ] Create `exists_fullySaturated_extension_temporal` in TemporalCoherentConstruction.lean
- [ ] Modify to use `buildDovetailingWitnessFamily` instead of `constantWitnessFamily`
- [ ] Prove box_coherence is preserved with non-constant witness families
- [ ] Prove all families in result are temporally coherent
- [ ] Replace `fully_saturated_bmcs_exists_int` sorry with constructed proof
- [ ] Deprecate or remove the polymorphic `fully_saturated_bmcs_exists` axiom
- [ ] Update `construct_saturated_bmcs_int` to use the new theorem
- [ ] Verify with `lake build`

**Key Proof Structure**:
```lean
theorem fully_saturated_bmcs_exists_int_constructed
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS Int),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0) ∧
      B.temporally_coherent ∧
      is_modally_saturated B := by
  -- 1. Build temporally coherent eval family via DovetailingChain
  obtain ⟨eval_fam, h_extends, h_fwd_F, h_bwd_P⟩ := temporal_coherent_family_exists_theorem Gamma h_cons
  -- 2. Build family collection with dovetailing witnesses via Zorn
  obtain ⟨C', h_extends', h_eval_preserved, h_sat⟩ :=
    exists_fullySaturated_extension_temporal (initialFamilyCollection phi eval_fam)
  -- 3. Convert to BMCS
  use C'.toBMCS h_sat
  -- 4. Prove properties
  ...
```

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` (add temporal variant)

**Verification**:
- `lake build` succeeds
- `fully_saturated_bmcs_exists_int` is sorry-free
- `grep -r "sorry" TemporalCoherentConstruction.lean` shows only generic D sorry
- Completeness theorems still compile

---

## Fallback Option: Scope Restriction

If the zero-compromise path proves too complex, there is a mathematically sound fallback:

**Eval-Only Temporal Coherence**:
- Restructure TruthLemma.lean to only require temporal coherence for eval_family
- This is sufficient for formulas without nested `Box(G/H ...)` patterns
- Requires documenting scope restriction in completeness theorem

**When to Consider Fallback**:
- If Phase 3 box_coherence proof fails for non-constant families
- If temporal coherence of witness families creates unforeseen consistency issues
- Time budget exceeded without clear path forward

**Fallback Tasks** (if needed):
- [ ] Define `TemporallySafeFormula` predicate (no `Box(G/H ...)` nesting)
- [ ] Modify TruthLemma to only use temporal_backward for eval_family
- [ ] Document scope restriction in Completeness.lean
- [ ] Update task completion summary with scope limitation

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] After Phase 2: `grep -r "sorry" DovetailingChain.lean` returns 0 matches
- [ ] After Phase 4: `grep -r "sorry" TemporalCoherentConstruction.lean | grep -v "temporal_coherent_family_exists "` returns 0 matches (only generic D sorry remains)
- [ ] Completeness.lean theorems remain valid and compile
- [ ] TruthLemma.lean continues to compile without changes
- [ ] `grep -r "axiom fully_saturated_bmcs_exists"` shows only deprecated annotation

## Artifacts & Outputs

- `plans/implementation-003.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- New Lean file:
  - `Theories/Bimodal/Metalogic/Bundle/DovetailingWitness.lean`
- Modified Lean files:
  - `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (Phases 1-2)
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (Phase 4)
  - `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` (Phase 4 variant)
  - `Theories/Bimodal.lean` (imports)

## Rollback/Contingency

If implementation fails:
1. Git revert to pre-implementation commit
2. Document blocking issues in error report
3. Consider fallback eval-only temporal coherence path

If dovetailing witness families break box_coherence:
1. Investigate S5 axiom 5 application to non-constant families
2. Consider tracking BoxContent per-time dynamically
3. Document mathematical gaps for future work

If time budget exceeded:
1. Mark phase [PARTIAL] with clear resume point
2. Commit partial progress
3. Document remaining work in implementation summary
