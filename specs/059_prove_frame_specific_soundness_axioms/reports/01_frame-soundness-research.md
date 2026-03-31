# Research Report: Frame-Specific Soundness Axioms

**Task**: 59 - prove_frame_specific_soundness_axioms
**Session**: sess_1774993419_e0fde9
**Date**: 2026-03-31

## Executive Summary

This report analyzes 5 sorries in `Soundness.lean` related to frame-specific axioms. Key finding: **4 of 5 sorries can be filled trivially** using reflexive semantics (`le_rfl`), while 1 sorry (`temporal_duality` at line 602) genuinely requires type class constraints that are absent from the general `soundness` theorem signature.

## Sorry Analysis

### Location Summary

| Line | Axiom | Status | Constraint Needed |
|------|-------|--------|-------------------|
| 572 | `density` | **Fillable** | None (reflexive semantics) |
| 576 | `discreteness_forward` | **Fillable** | None (reflexive semantics) |
| 579 | `seriality_future` | **Fillable** | None (reflexive semantics) |
| 582 | `seriality_past` | **Fillable** | None (reflexive semantics) |
| 602 | `temporal_duality` | **Blocked** | `[DenselyOrdered D] [Nontrivial D]` |

### Detailed Analysis

#### 1. Density Axiom (Line 572)

**Formula**: `GGphi -> Gphi` (all_future.all_future.imp all_future)

**Original Comment**: "Requires DenselyOrdered D"

**Finding**: Under reflexive semantics (using `<=` instead of `<`), this is **trivially valid** without `DenselyOrdered`. The proof:

```lean
simp only [truth_at]
intro h_GG s hts
-- h_GG : forall r >= t, forall q >= r, phi(q)
-- Goal: phi(s)
-- Take r = s: h_GG s hts gives forall q >= s, phi(q)
-- Take q = s with le_rfl: phi(s)
exact h_GG s hts s le_rfl
```

**Verification**: Tested via `lean_multi_attempt` - compiles successfully.

#### 2. Discreteness Forward Axiom (Line 576)

**Formula**: `(F_top /\ phi /\ H phi) -> F(H phi)`

**Original Comment**: "Requires SuccOrder D"

**Finding**: Under reflexive semantics, this is **trivially valid**. The witness for `F(H phi)` is `t` itself (since `t >= t` by `le_rfl`).

```lean
simp only [Formula.and, Formula.some_future, Formula.neg, truth_at]
intro h_conj h_G_not_H
have h1 := and_of_not_imp_not h_conj
have <_h_F_top, h_phi_and_H> := h1
have h2 := and_of_not_imp_not h_phi_and_H
have <_h_phi, h_H> := h2
apply h_G_not_H t le_rfl
exact h_H
```

**Verification**: Tested via `lean_multi_attempt` - compiles successfully.

#### 3. Seriality Future Axiom (Line 579)

**Formula**: `G phi -> F phi` (all_future.imp some_future)

**Original Comment**: "Requires NoMaxOrder D"

**Finding**: Under reflexive semantics, this is **trivially valid via T-axiom**. If `G phi` holds (forall s >= t, phi(s)), then `phi(t)` holds (taking s = t), which witnesses `F phi`.

```lean
simp only [Formula.some_future, Formula.neg, truth_at]
intro h_G h_neg_F
exact h_neg_F t le_rfl (h_G t le_rfl)
```

**Verification**: Tested via `lean_multi_attempt` - compiles successfully.

#### 4. Seriality Past Axiom (Line 582)

**Formula**: `H phi -> P phi` (all_past.imp some_past)

**Original Comment**: "Requires NoMinOrder D"

**Finding**: Symmetric to seriality_future. Under reflexive semantics, `phi(t)` witnesses `P phi`.

```lean
simp only [Formula.some_past, Formula.neg, truth_at]
intro h_H h_neg_P
exact h_neg_P t le_rfl (h_H t le_rfl)
```

**Verification**: Tested via `lean_multi_attempt` - compiles successfully.

#### 5. Temporal Duality (Line 602)

**Context**: The `temporal_duality` inference rule transforms `|- phi` to `|- phi.swap_temporal`.

**Finding**: This case **genuinely requires** `[DenselyOrdered D] [Nontrivial D]` because it calls:

```lean
SoundnessLemmas.derivable_implies_swap_valid d' h_dc F M Omega h_sc tau h_mem t
```

And `derivable_implies_swap_valid` has signature:
```lean
theorem derivable_implies_swap_valid [DenselyOrdered D] [Nontrivial D]
    {phi : Formula} (d : DerivationTree [] phi) (h_dc : d.isDenseCompatible) :
    is_valid D phi.swap_temporal
```

**Why the constraint is needed**: The swap-validity proof for axioms like `modal_future` and `temp_future` uses `time_shift_preserves_truth` which relies on the density property.

## Architectural Options

### Option A: Fill 4 Sorries, Leave 1 (Recommended)

Fill the 4 trivially-fillable sorries (density, discreteness_forward, seriality_future, seriality_past) with their reflexive semantics proofs.

Leave `temporal_duality` (line 602) as a sorry with an updated comment explaining it requires type class constraints not present in the general theorem.

**Pros**:
- Minimal code change
- Accurate documentation
- General soundness theorem remains usable for derivations without temporal_duality

**Cons**:
- 1 sorry remains

### Option B: Restrict General Soundness Theorem

Add `[DenselyOrdered D] [Nontrivial D]` constraints to the general `soundness` theorem signature.

**Pros**:
- Zero sorries
- Complete theorem

**Cons**:
- Changes API surface
- Users needing soundness for non-dense types would need alternative theorem

### Option C: Create isDenseCompatible Guard

Require `d.isDenseCompatible` as a hypothesis in general soundness, then the temporal_duality case can use `derivable_implies_swap_valid`.

**Issue**: This still requires the type class constraints in the theorem signature because `derivable_implies_swap_valid` is polymorphic over D with those constraints.

### Option D: Separate Theorems (Current Architecture)

The codebase already has `soundness_dense` (line 701) which:
- Has the necessary constraints
- Handles all cases including temporal_duality
- Is used by completeness proofs

The general `soundness` theorem could be:
1. Deprecated in favor of `soundness_dense`
2. Restricted to derivations without temporal_duality
3. Marked as a partial result

## Dependencies

### Files Involved

- `/Theories/Bimodal/Metalogic/Soundness.lean` - Main file with sorries
- `/Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Bridge theorems for temporal_duality
- `/Theories/Bimodal/Semantics/Validity.lean` - Validity definitions (valid, valid_dense)

### Mathlib Dependencies

No additional Mathlib imports needed for the 4 fillable sorries.

For `temporal_duality` resolution (if Option B chosen):
- `DenselyOrdered` from `Mathlib.Order.Basic`
- `Nontrivial` from `Mathlib.Logic.Nontrivial.Basic`

### Internal Dependencies

- `and_of_not_imp_not` helper (line 93) - Used by discreteness_forward proof
- `density_valid` theorem (line 321) - Shows the same proof pattern
- `soundness_dense` theorem (line 701) - Reference implementation with all cases handled

## Proof Strategies

### For Lines 572, 576, 579, 582

All use the same core insight: **reflexive semantics allows self-witness via `le_rfl`**.

The key pattern:
```lean
-- Given: forall s (rel) t, property(s)
-- Goal: exists s (rel) t, property(s)
-- Witness: s = t, relation holds by le_rfl
```

### For Line 602 (if constraints added)

```lean
| temporal_duality phi' d' ih =>
    exact SoundnessLemmas.derivable_implies_swap_valid d' h_dc F M Omega h_sc tau h_mem t
```

Requires `h_dc : d'.isDenseCompatible` to be derivable from context.

## Recommendations

### Primary Recommendation: Option A

1. **Fill 4 sorries** at lines 572, 576, 579, 582 with verified proofs
2. **Update comment** at line 602 to accurately document the constraint requirement
3. **Keep soundness_dense** as the primary soundness theorem for dense frames

### Implementation Plan

**Phase 1**: Fill density sorry (line 572)
```lean
| density psi =>
    simp only [truth_at]
    intro h_GG s hts
    exact h_GG s hts s le_rfl
```

**Phase 2**: Fill discreteness_forward sorry (line 576)
```lean
| discreteness_forward psi =>
    simp only [Formula.and, Formula.some_future, Formula.neg, truth_at]
    intro h_conj h_G_not_H
    have h1 := and_of_not_imp_not h_conj
    have <_h_F_top, h_phi_and_H> := h1
    have h2 := and_of_not_imp_not h_phi_and_H
    have <_h_phi, h_H> := h2
    apply h_G_not_H t le_rfl
    exact h_H
```

**Phase 3**: Fill seriality_future sorry (line 579)
```lean
| seriality_future psi =>
    simp only [Formula.some_future, Formula.neg, truth_at]
    intro h_G h_neg_F
    exact h_neg_F t le_rfl (h_G t le_rfl)
```

**Phase 4**: Fill seriality_past sorry (line 582)
```lean
| seriality_past psi =>
    simp only [Formula.some_past, Formula.neg, truth_at]
    intro h_H h_neg_P
    exact h_neg_P t le_rfl (h_H t le_rfl)
```

**Phase 5**: Update temporal_duality comment (line 602)
```lean
| temporal_duality phi' d' ih =>
    -- Temporal duality soundness requires [DenselyOrdered D] [Nontrivial D]
    -- because derivable_implies_swap_valid has those constraints.
    -- For the full soundness theorem, use soundness_dense instead.
    sorry
```

## Verification Commands

After implementation, verify with:
```bash
lake build Bimodal.Metalogic.Soundness
```

Expected: 1 warning about remaining sorry at line 602, reduced from 5.

## References

- `Soundness.lean` lines 538-604: General soundness theorem
- `Soundness.lean` lines 701-775: `soundness_dense` with all cases handled
- `SoundnessLemmas.lean` lines 993-996: `derivable_implies_swap_valid` signature
- `Validity.lean` lines 159-165: `valid_dense` definition
