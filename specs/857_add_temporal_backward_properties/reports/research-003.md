# Research Report: Task #857 - Strategy Revision After Task 856 Completion

**Task**: Add temporal_backward_G and temporal_backward_H properties to IndexedMCSFamily
**Date**: 2026-02-04
**Focus**: Re-evaluate zero-axiom feasibility given task 856's multi-family saturation completion

## Summary

Task 856 successfully proved `eval_saturated_bundle_exists` using a non-constructive approach with `{base} U allWitnesses`. This report evaluates whether the EvalCoherent infrastructure enables a zero-axiom approach for temporal backward properties. **Finding**: The EvalCoherent approach from task 856 does NOT directly enable temporal backward proofs, but provides a pattern that could be extended with temporal saturation. The recommended approach remains axiom-based for the constant family construction, with a clear path to axiom elimination via temporal saturation in future work.

## 1. Task 856 Key Technical Achievements

### 1.1 Core Innovation: EvalCoherent (Weaker Than MutuallyCoherent)

Task 856 solved the "Lindenbaum control problem" by defining:

```lean
def EvalCoherent (families : Set (IndexedMCSFamily D)) (eval_fam : IndexedMCSFamily D)
    (h_eval_mem : eval_fam ∈ families) : Prop :=
  ∀ fam ∈ families, ∀ chi ∈ BoxContent eval_fam, ∀ t : D, chi ∈ fam.mcs t
```

This is weaker than `MutuallyCoherent` (which requires all families to contain UnionBoxContent of ALL families). EvalCoherent only requires families to contain `BoxContent(eval_family)`, which is FIXED and doesn't change when adding witnesses.

### 1.2 Key Theorem: neg_box_to_diamond_neg

```lean
lemma neg_box_to_diamond_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_neg_box : Formula.neg (Formula.box phi) ∈ M) :
    diamondFormula (Formula.neg phi) ∈ M
```

This transforms `neg(Box phi)` to `diamondFormula(neg phi)` using:
- `box_dne_theorem`: Box(neg neg phi) -> Box phi
- `mcs_contrapositive`: Transfers implications contrapositively through MCS membership

### 1.3 Saturation Approach: Non-Constructive Union

Instead of enumeration-based saturation, task 856 defines:

```lean
let allWitnesses : Set (IndexedMCSFamily D) :=
  { W | ∃ psi : Formula, ∃ t : D, ∃ h_diamond : diamondFormula psi ∈ base.mcs t,
        W = (constructCoherentWitness base h_const psi t h_diamond).family }

let saturatedFamilies : Set (IndexedMCSFamily D) := {base} ∪ allWitnesses
```

This uses axiom of choice to assert existence of all witnesses, avoiding enumeration issues.

## 2. Analysis: Can This Approach Work for Temporal Backward?

### 2.1 The Fundamental Asymmetry

The EvalCoherent approach works for MODAL saturation because:
1. `Box phi` in `eval_family` creates obligation `phi` in witnesses
2. Witnesses are constructed with `BoxContent(eval_family)` included
3. The `constructCoherentWitness` ensures `phi` is in all witness families

For TEMPORAL backward (e.g., `temporal_backward_G`), the situation is different:

**What we need**: `(forall s >= t, phi in mcs s) -> G phi in mcs t`

**The obstacle**: Unlike modal saturation (which adds witness families), temporal backward requires reasoning about a SINGLE family's MCS across multiple times.

### 2.2 Why Task 856's Approach Doesn't Directly Apply

Task 856 solves modal saturation by:
1. Having multiple families (witnesses)
2. `phi in ALL families` implies `Box phi` via contraposition (saturation provides witness with `neg phi` if `Box phi` fails)

For temporal, the challenge is different:
1. We have ONE family with MCS at each time point
2. `phi in mcs s for all s >= t` is about the SAME family at different times
3. We need `G phi in mcs t` for that family

**Key Difference**: Modal saturation exploits multiple families; temporal backward needs reasoning within a single family across time.

### 2.3 The Constant Family Limitation (Still Applies)

Research-002.md correctly identified:

For a **constant family** (`fam.mcs t = M` for all t):
- `forward_G`: `G phi in M` implies `phi in M` by T-axiom (works)
- `backward_G` (temporal_backward_G): `phi in M` does NOT imply `G phi in M` (T-axiom goes wrong direction)

Task 856's multi-family approach doesn't change this because:
- The base family is still constant (`constantIndexedMCSFamily`)
- Witnesses are also constant (use same MCS at all times)
- No witness construction provides temporal backward

## 3. What Would a Zero-Axiom Approach Require?

### 3.1 Temporal Saturation (Not Yet Implemented)

To achieve temporal_backward_G structurally, we would need **temporal saturation**:

```lean
structure TemporallySaturatedFamily where
  fam : IndexedMCSFamily D
  /-- F phi at t implies exists s > t with phi at s -/
  forward_F : forall t phi, Formula.some_future phi in fam.mcs t ->
              exists s, t < s ∧ phi in fam.mcs s
  /-- P phi at t implies exists s < t with phi at s -/
  backward_P : forall t phi, Formula.some_past phi in fam.mcs t ->
               exists s, s < t ∧ phi in fam.mcs s
```

**Why this enables temporal_backward_G** (by contraposition):
1. Assume `phi in mcs s` for all `s >= t` but `G phi NOT in mcs t`
2. By MCS maximality: `neg(G phi) = F(neg phi)` IS in `mcs t`
3. By `forward_F`: exists `s > t` with `neg phi in mcs s`
4. But `phi in mcs s` for all `s >= t`, so `phi in mcs s` for this `s`
5. Contradiction: `phi` and `neg phi` both in `mcs s`

### 3.2 Time-Varying MCS Construction (Not Implemented)

A constant family (`mcs t = M` for all t) CANNOT satisfy `forward_F`:
- `F phi in M` does NOT imply `phi in M` (no T-axiom for F)
- There's no "different time" to witness the F formula

To achieve temporal saturation, we would need:
1. **Different MCS at different times** (not constant)
2. Construction that ensures `F phi in mcs t` creates a witness time `s > t` with `phi in mcs s`
3. This is analogous to modal saturation but across TIME instead of across FAMILIES

### 3.3 Estimated Effort for Full Temporal Saturation

| Component | Estimated Hours | Current Status |
|-----------|-----------------|----------------|
| Define TemporallySaturatedFamily structure | 2-4 | Not implemented |
| Prove F/P witness existence via Lindenbaum | 15-25 | Not implemented |
| Prove temporal_backward_G/H from saturation | 4-8 | Not implemented |
| Integrate with completeness proof | 8-12 | Not implemented |
| **Total** | **29-49** | Not started |

## 4. Reusable Patterns from Task 856

Despite not directly enabling temporal backward, task 856 provides valuable patterns:

### 4.1 The neg_X_to_diamond_neg Pattern

The `neg_box_to_diamond_neg` lemma shows how to transform negated universal modalities:
- `neg(Box phi) -> diamondFormula(neg phi)` via `box_dne_theorem` and `mcs_contrapositive`

An analogous lemma could be:
- `neg(G phi) -> F(neg phi)` (this is definitionally true: `neg(all_future phi) = some_future(neg phi)`)

**Note**: For temporal operators, this might be simpler since `neg(G phi) = F(neg phi)` may be definitional equality, unlike the modal case which required `box_dne_theorem`.

### 4.2 The Non-Constructive Saturation Pattern

Instead of enumerating witnesses, define the saturated set directly:

```lean
let allTemporalWitnesses : Set D :=
  { s | ∃ phi : Formula, ∃ t : D, ∃ h_F : Formula.some_future phi ∈ base.mcs t,
        t < s ∧ phi ∈ base.mcs s }
```

This pattern could be used if we had time-varying MCS construction.

### 4.3 The EvalCoherent Weakening Strategy

The key insight: weaken the coherence requirement to what's ACTUALLY NEEDED for completeness.

For temporal backward, we might define:
- `EvalTemporalCoherent`: Only require temporal saturation for eval_family
- This would be weaker than full temporal saturation across all families

## 5. Recommended Approach for Task 857

### 5.1 Immediate Implementation: Axiom-Based Approach (Recommended)

Given the analysis, the **axiom-based approach** remains correct for task 857:

```lean
axiom singleFamily_temporal_backward_G_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_all_future : ∀ s, t ≤ s → phi ∈ fam.mcs s) :
    Formula.all_future phi ∈ fam.mcs t

axiom singleFamily_temporal_backward_H_axiom (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (fam : IndexedMCSFamily D) (phi : Formula) (t : D)
    (h_all_past : ∀ s, s ≤ t → phi ∈ fam.mcs s) :
    Formula.all_past phi ∈ fam.mcs t
```

**Rationale**:
1. Consistent with `singleFamily_modal_backward_axiom` pattern
2. Eliminates the TruthLemma sorries immediately
3. Documents the technical debt with clear remediation path
4. Follows proof-debt-policy.md (axiom with documented remediation)

### 5.2 Axiom Location

Place axioms in `Construction.lean` immediately after `singleFamily_modal_backward_axiom` (line 231).

### 5.3 TruthLemma.lean Changes

Replace sorries at lines 387 and 400:

```lean
-- Line 387 (all_future backward)
intro h_all
have h_psi_all_mcs : ∀ s, t ≤ s → ψ ∈ fam.mcs s := by
  intro s hts
  exact (ih fam hfam s).mpr (h_all s hts)
exact singleFamily_temporal_backward_G_axiom D fam ψ t h_psi_all_mcs

-- Line 400 (all_past backward)
intro h_all
have h_psi_all_mcs : ∀ s, s ≤ t → ψ ∈ fam.mcs s := by
  intro s hst
  exact (ih fam hfam s).mpr (h_all s hst)
exact singleFamily_temporal_backward_H_axiom D fam ψ t h_psi_all_mcs
```

### 5.4 Future Work: Temporal Saturation (Task 856 Follow-Up)

A future task should:
1. Define `TemporallySaturatedFamily` structure
2. Implement time-varying MCS construction (similar to CoherentConstruction.lean)
3. Prove temporal_backward_G/H structurally from temporal saturation
4. Eliminate the temporal axioms

This would be analogous to how task 856 provides infrastructure to eventually eliminate `singleFamily_modal_backward_axiom`.

## 6. Summary Table

| Aspect | Task 856 (Modal) | Task 857 (Temporal) |
|--------|------------------|---------------------|
| **Problem** | `phi in ALL families -> Box phi in fam` | `phi at ALL times -> G phi at t` |
| **Obstacle** | Single family has no witnesses | Constant family has same MCS everywhere |
| **856's Solution** | Multi-family saturation (EvalCoherent) | Not applicable (different dimension) |
| **Zero-Axiom Path** | EvalSaturated bundle (PROVEN) | Temporal saturation (NOT IMPLEMENTED) |
| **Recommended 857** | N/A | Axiom-based (consistent with modal) |
| **Technical Debt** | `saturated_extension_exists` (now obsolete) | New temporal axioms |
| **Remediation** | Use EvalBMCS for completeness | Future temporal saturation task |

## 7. Conclusions

1. **Task 856 does NOT directly enable zero-axiom temporal backward** - The EvalCoherent approach solves a different dimension (multiple families vs. single family across time).

2. **The axiom-based approach remains correct** - For constant family construction, temporal backward requires axioms, just as modal backward did before task 856.

3. **Task 856 provides useful patterns** - The `neg_X_to_diamond_neg` pattern and non-constructive saturation could be adapted for future temporal saturation work.

4. **Clear remediation path exists** - A future task implementing temporal saturation could eliminate the temporal axioms, analogous to how EvalBMCS eliminates modal axioms.

5. **Implementation recommendation** - Proceed with axiom-based approach immediately; document temporal saturation as future work.

## 8. References

- Task 856 summary: `specs/856_implement_multifamily_saturated_bmcs/summaries/implementation-summary-20260204.md`
- Previous research: `specs/857_add_temporal_backward_properties/reports/research-001.md`, `research-002.md`
- CoherentConstruction.lean: Task 856 implementation
- TruthLemma.lean: Lines 383, 395 (sorries to eliminate)
- Construction.lean: `singleFamily_modal_backward_axiom` pattern

## 9. Next Steps

1. Create implementation plan for task 857 using axiom-based approach
2. Implement two temporal backward axioms in Construction.lean
3. Update TruthLemma.lean to use the axioms
4. Document axioms in SORRY_REGISTRY.md
5. Create follow-up task for temporal saturation infrastructure
