# Research Report: Task #825

**Task**: FDSM Multi-History Modal Saturation - Blockers Analysis
**Date**: 2026-02-03
**Focus**: Analyzing what prevents fully completing PARTIAL phases in implementation-001.md
**Session**: sess_1770089589_19268f

## Summary

The PARTIAL phases (4-6) are blocked by a fundamental architectural gap: the abstract `saturation_step` operates on `Finset (FDSMHistory phi)` but cannot construct witnesses because `FDSMHistory` values don't carry the MCS information needed for Lindenbaum extension. The `MCSTrackedHistory` structure was added to bridge this gap but lacks the type class instances (`DecidableEq`) needed for `Finset` operations.

## Detailed Analysis of Each Blocker

### Phase 4: Modal Saturation Property - 3 Sorries

#### Blocker 1: `fixed_point_is_saturated` (line 803)

**Location**: ModalSaturation.lean:755-803

**Problem Statement**: The theorem claims that if `saturation_step phi hists t = hists` (fixed point), then `is_modally_saturated phi hists t`. The proof strategy is contrapositive: if some Diamond psi lacks a witness, then `saturation_step` would add one, contradicting the fixed point.

**Why It's Blocked**:
1. The `saturation_step` definition filters from `Finset.univ` for histories satisfying `IsWitnessFor`
2. `IsWitnessFor` requires that a history h' models psi at time t
3. To prove a witness EXISTS, we need to CONSTRUCT one via `buildWitnessHistory`
4. `buildWitnessHistory` requires an MCS M and proof that `Diamond psi ∈ M`
5. But `FDSMHistory` values don't carry MCS information - they're just functions from time to world states

**The Fundamental Gap**:
```lean
-- We have: h : FDSMHistory phi, h ∈ hists, Diamond psi ∈ (h.states t).toSet
-- We need: Some MCS M such that Diamond psi ∈ M
-- Problem: There's no function from FDSMHistory to its originating MCS
```

**What Would Resolve It**:
- Option A: Prove witness existence abstractly via a choice principle on the finite type
- Option B: Use `MCSTrackedHistory` to track MCS origins and prove saturation over this richer type
- Option C: Prove that world states themselves ARE closure MCS (they are, but the proof requires infrastructure)

#### Blocker 2: `saturated_histories_saturated` (line 815)

**Location**: ModalSaturation.lean:808-815

**Dependency**: Directly depends on `fixed_point_is_saturated`. Once that is proven, this follows by showing that `saturated_histories_from` produces a fixed point.

**Why It's Blocked**:
- Requires proving that `saturate_with_fuel` eventually reaches a fixed point
- Also requires `saturation_terminates` which has its own sorry

#### Blocker 3: `saturation_terminates` (line 728)

**Location**: ModalSaturation.lean:711-728

**Problem Statement**: Prove that saturation reaches a fixed point within `maxHistories phi` steps.

**Why It's Blocked**:
The proof requires showing that at each non-fixed-point step, cardinality strictly increases. The `saturation_step_card_increase` theorem proves the cardinality claim, but connecting this to "reaches fixed point" requires well-founded induction on `maxHistories - current_card`, which is a standard but tedious argument.

**Difficulty**: Medium - this is a bookkeeping proof, not conceptually hard.

---

### Phase 5: modal_backward_from_saturation - 2 Sorries

#### Blocker 4: `neg_box_iff_diamond_neg` (line 309)

**Location**: ModalSaturation.lean:286-309

**Problem Statement**: Show that `(Box psi).neg ∈ S` implies `Diamond (psi.neg) ∈ S` for an MCS S, under closure membership conditions.

**Why It's Blocked**:
- This is NOT syntactic equality: `(Box psi).neg = Box psi → ⊥`
- `Diamond chi = (Box chi.neg).neg`
- So we need: `(Box psi).neg ∈ S ⟹ (Box psi.neg.neg).neg ∈ S`
- By classical logic, `psi ↔ psi.neg.neg`, so `Box psi ↔ Box psi.neg.neg`
- The proof requires showing MCS closure under classical equivalence

**Difficulty**: Medium - requires careful handling of double negation in MCS.

#### Blocker 5: `modal_backward_from_saturation` (line 345)

**Location**: ModalSaturation.lean:329-345

**Problem Statement**: If psi holds at ALL histories at time t, then Box psi is in the world state.

**Why It's Blocked**:
The proof uses:
1. Contrapositive: assume Box psi ∉ h.states t
2. By MCS negation completeness: (Box psi).neg ∈ h.states t
3. By `neg_box_iff_diamond_neg`: Diamond(psi.neg) ∈ h.states t
4. By modal saturation: exists h' where psi.neg holds
5. But h_all says psi holds at ALL histories - contradiction

**Dependencies**:
- Requires `neg_box_iff_diamond_neg`
- Requires the model to have `modal_saturated` property
- Requires that world states are MCS-derived (for negation completeness)

**The Real Blocker**: The theorem is stated for abstract FDSMHistory values, but the proof requires knowing that world states come from MCS constructions.

---

### Phase 6: Update Completeness.lean - 2 Sorries

#### Blocker 6: `modal_saturated` in `fdsm_from_closure_mcs` (Completeness.lean:74-88)

**Location**: Completeness.lean:68-92

**Problem Statement**: The single-history FDSM needs to prove that if Diamond psi holds, there exists a witness history where psi holds.

**Current State**: The code has a sorry at line 88. The comment notes that with a single history, Diamond psi = neg(neg psi) = psi, so the single history is its own witness.

**Why It's Blocked**:
- The simplification "Diamond psi = psi in single-history semantics" needs formal proof
- Requires showing: if `(Box (neg psi)).neg ∈ world_state`, then `psi ∈ world_state`
- This needs the MCS property that `(Box chi).neg ∈ S` implies something about `chi`

**Difficulty**: Medium - the single-history case is actually simpler because the witness IS the same history.

#### Blocker 7: `fdsm_mcs_implies_truth` (Completeness.lean:144-153)

**Location**: Completeness.lean:144-153

**Problem Statement**: If psi ∈ S (closure MCS), then psi is true at the evaluation history.

**Why It's Blocked**: Requires the full truth lemma infrastructure from TruthLemma.lean.

#### Blocker 8: `fdsm_mcs_neg_implies_false` (Completeness.lean:162-172)

**Location**: Completeness.lean:162-172

**Problem Statement**: If psi ∉ S and psi.neg ∈ S, then psi is false at the evaluation history.

**Why It's Blocked**: Also requires TruthLemma.lean infrastructure.

---

### TruthLemma.lean - 13+ Sorries

**Critical Observation**: TruthLemma.lean has many sorries (lines 76, 119, 126-127, 133, 160-163, 184, 187, 195, 200, 207, 214, etc.) that are characterized as "closure membership bookkeeping."

**Why These Are Important**:
- The completeness proof (`fdsm_completeness_contrapositive`) calls `fdsm_mcs_neg_implies_false`
- That calls into TruthLemma machinery
- The TruthLemma sorries block the completeness proof indirectly

---

## Dependency Graph

```
Phase 4:
  saturation_terminates ← (well-founded argument)
  fixed_point_is_saturated ← MCS tracking gap
  saturated_histories_saturated ← fixed_point_is_saturated

Phase 5:
  neg_box_iff_diamond_neg ← classical equivalence in MCS
  modal_backward_from_saturation ← neg_box_iff_diamond_neg + modal_saturated

Phase 6:
  modal_saturated in fdsm_from_closure_mcs ← single-history modal semantics
  fdsm_mcs_implies_truth ← TruthLemma.lean
  fdsm_mcs_neg_implies_false ← TruthLemma.lean
```

## Root Causes

### Root Cause 1: MCS Tracking Gap

The fundamental issue is that the abstract saturation construction operates on `FDSMHistory` values that don't carry their originating MCS information. The `MCSTrackedHistory` structure was added to address this but requires:

1. `DecidableEq (MCSTrackedHistory phi)` - For `Finset` operations
2. A complete rewrite of `saturation_step` to work on `Finset (MCSTrackedHistory phi)`
3. Proofs that MCS-tracked saturation produces a proper `Finset (FDSMHistory phi)`

### Root Cause 2: TruthLemma Closure Bookkeeping

Many sorries involve proving closure membership propagates through formula constructors. For example, proving `psi ∈ closure phi ⟹ psi.neg ∈ closure phi` or similar.

### Root Cause 3: Classical Equivalences in MCS

Several proofs need that MCS are closed under classical equivalence, particularly double negation elimination.

## Recommendations

### Priority 1: Fix Single-History Modal Saturation (Quick Win)

The sorry in `fdsm_from_closure_mcs.modal_saturated` is the easiest to resolve:
- For single history, Diamond psi = psi (semantically)
- Just prove: if `(Box (neg psi)).neg ∈ S`, then `psi ∈ S` (for closure MCS S)
- This uses: `(Box (neg psi)).neg ∈ S` ⟹ `Box (neg psi) ∉ S` ⟹ (by closure MCS property, neg psi may not hold everywhere) ⟹ actually this is the HARD direction

Actually, the single-history case is NOT trivial because Diamond psi = neg(Box(neg psi)) doesn't directly give us psi. The implication `Diamond psi ⟹ psi` is NOT valid in general modal logic.

**Revised Assessment**: The single-history construction is semantically BROKEN as the implementation summary notes. It makes Box psi = psi, which is WRONG.

### Priority 2: Complete MCSTrackedHistory Integration

The cleaner path forward:
1. Add classical `DecidableEq` for `MCSTrackedHistory`
2. Define `saturation_step_tracked` over `Finset (MCSTrackedHistory phi)`
3. Prove saturation produces modal saturation over the tracked type
4. Project to `Finset (FDSMHistory phi)` for the final model

### Priority 3: Fix Closure Membership Infrastructure

Many sorries would resolve if we had lemmas like:
- `closure_neg`: `psi ∈ closure phi → psi.neg ∈ closureWithNeg phi`
- `closure_imp`: `psi → chi ∈ closure phi → psi ∈ closure phi ∧ chi ∈ closure phi`
- etc.

These should be straightforward inductions on closure definition.

### Priority 4: Classical MCS Equivalence Lemma

Add: `mcs_classical_equiv`: If `⊢ psi ↔ chi` and `psi ∈ S`, then `chi ∈ S` for MCS S.

This would unlock `neg_box_iff_diamond_neg` directly.

## Conclusion

The PARTIAL phases are blocked primarily by the **MCS tracking gap** - the abstract saturation operates on histories that don't carry their MCS origin, making it impossible to construct witnesses. The `MCSTrackedHistory` infrastructure is present but incomplete. Secondary blockers include closure membership bookkeeping and classical equivalence lemmas.

The recommended path forward is:
1. Complete `DecidableEq` for `MCSTrackedHistory` (using classical decidability)
2. Reimplement saturation over tracked histories
3. Complete the closure membership infrastructure in parallel
4. The single-history model should be treated as deprecated (semantically broken)

## References

- Implementation summary: specs/825_fdsm_multi_history_modal_saturation/summaries/implementation-summary-20260203.md
- Implementation plan: specs/825_fdsm_multi_history_modal_saturation/plans/implementation-001.md
- ModalSaturation.lean (current state)
- Completeness.lean (current state)
- TruthLemma.lean (dependency)
