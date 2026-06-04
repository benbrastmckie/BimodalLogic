# Phase 2 Multi-Family Z-Interval Handoff

## Status
Phase 2 IN PROGRESS. Multi-family Z-interval approach proven viable mathematically. Implementation in progress — core infrastructure (TaskFrame, History, Omega, TaskModel) compiles successfully. Truth correspondence and countermodel assembly need carrier-type mismatch resolution.

## Verified: Multi-Family Infrastructure Compiles

The following definitions were tested and compile successfully in ReynoldsBridge.lean:

```lean
-- TaskFrame with WorldState = FamIdx × ℤ
noncomputable def multiFamTaskFrame (FamIdx : Type) : TaskFrame ℤ where
  WorldState := FamIdx × ℤ
  task_rel := fun p d q => p.1 = q.1 ∧ q.2 = p.2 + d
  nullity_identity := fun p q => by
    constructor
    · rintro ⟨h1, h2⟩; ext <;> [exact h1; omega]
    · rintro h; subst h; exact ⟨rfl, by omega⟩
  forward_comp := fun _ _ _ _ _ _ _ ⟨h1, h2⟩ ⟨h3, h4⟩ => ⟨h1.trans h3, by omega⟩
  converse := fun _ _ _ => by constructor <;> (rintro ⟨h1, h2⟩; exact ⟨h1.symm, by omega⟩)

-- History, Omega, TaskModel all compile
```

## Mathematical Proof (Complete)

### Box Universality — Forward
(Z_f.interp(atomMap(.box ψ)) z = True) → (∀ f' z', temporal_truth ψ z' on Z_{f'})

1. Box pred True on Z_f → `∀x. P_{box ψ}(x)` on Z_f (constancy from eval of `.all (.atom ...)`)
2. k-equiv reverse transfer (depth 1 ≤ k) → `∀x. P_{box ψ}(x)` on limitdom_f
3. → `.box ψ ∈ limit_f_N(t)` for all t → `.box ψ ∈ N_f` (via `box_stable_in_limit_f`)
4. → `.box ψ ∈ A` (box-equiv) → `.box ψ ∈ N_{f'}` for all f' (box-equiv)
5. → `ψ ∈ limit_f_{N_{f'}}(t)` for all t (Modal T: `□ψ→ψ` + box stability)
6. → `temporal_truth(ψ, t)` on limitdom_{f'} (effective formula bridge, `eff = id`)
7. → `∀x. table(ψ)(x)` on limitdom_{f'} (table_correctness)
8. → k-equiv transfer (depth ≤ operator_depth(ψ)+1 ≤ k) → `∀x. table(ψ)(x)` on Z_{f'}
9. → `temporal_truth(ψ, z')` for all z' on Z_{f'} (table_correctness reverse)

### Box Universality — Backward
(∀ f' z', temporal_truth ψ z' on Z_{f'}) → (Z_f.interp(atomMap(.box ψ)) z = True)

1. ∀ f' z', temporal_truth ψ z' on Z_{f'} → `∀x. table(ψ)(x)` on each Z_{f'}
2. k-equiv reverse → `∀x. table(ψ)(x)` on each limitdom_{f'}
3. → `ψ ∈ limit_f_{N_{f'}}(0) = N_{f'}` for all f' (table_correctness + eff bridge + limit_f_zero)
4. → `.box ψ ∈ A` (via modal_backward: needs `bx_modal_witness_fc` contrapositive)
5. → `.box ψ ∈ N_f` (box-equiv) → box pred True on Z_f (z_interval_box_constant)

### Depth Bounds
- k = operator_depth(φ) + 2
- `∀x. P_{box ψ}(x)`: depth 1 ≤ k ✓
- `∀x. table(ψ)(x)`: depth ≤ 1 + operator_depth(ψ) ≤ operator_depth(φ) ≤ k ✓

### modal_backward Construction
The BFMCS `modal_backward` is not directly available (we're not using the parametric canonical model). Instead, prove directly:
```
∀ ψ, (∀ f : FamIdx, ψ ∈ getN f) → Formula.box ψ ∈ A
```
By contradiction: if `.box ψ ∉ A`, then `¬.box ψ ∈ A`. By S5: `□(¬.box ψ) ∈ A`. By box_dne + contrapositive: `◇(¬ψ) ∈ A`. By `bx_modal_witness_fc`: ∃ box-equiv MCS v with `¬ψ ∈ v`. But v is a family (FamIdx element), and by hypothesis `ψ ∈ v`. Contradiction.

## Implementation Issues and Solutions

### Carrier Type Mismatch
`temporal_truth` on `Z.toOrdered sig` uses `Z.intervalCarrier` (subtype of ℤ). The TaskFrame time domain is raw ℤ.

**Solution**: Define `toCarrier` helper:
```lean
def toCarrier {sig} {Z : ZIntervalStructure sig} (h_lo : Z.lo = none) (h_hi : Z.hi = none) (z : ℤ) : Z.intervalCarrier :=
  ⟨z, by rw [h_lo, h_hi]; exact ⟨trivial, trivial⟩⟩
```

For truth_corr statement:
```
truth_at TM Omega (multiFamHistory f w₀) t ψ ↔
  temporal_truth (Z_f.toOrdered sig) atomMap (toCarrier h_lo h_hi (w₀+t)) ψ
```

For Until/Since witnesses: convert `s : ℤ` to carrier via `toCarrier`, and carrier `sc` to ℤ via `sc.val`. The key lemma: `toCarrier a < toCarrier b ↔ a < b` (Iff.rfl for subtype ordering on ℤ).

For the backward Until direction, reconstruct carrier witness as `⟨r.val, _⟩` via: `∃ ri, r = toCarrier h_lo h_hi ri := ⟨r.val, by ext; rfl⟩`.

### FO Sentence Constructors
Use `.atom` not `.pred` for `MonadicFormula`. E.g., `∀x. P(x)` is `.all (.atom p 0)`.

### predFormulas Helpers Needed
```lean
predFormulas_imp_left_sub, predFormulas_imp_right_sub : (ψ₁.imp ψ₂).predFormulas ⊆ root.predFormulas → ψᵢ.predFormulas ⊆ root.predFormulas
predFormulas_box_sub : (Formula.box ψ).predFormulas ⊆ root.predFormulas → ψ.predFormulas ⊆ root.predFormulas
predFormulas_has_box_sub : (Formula.box ψ).predFormulas ⊆ root.predFormulas → Formula.box ψ ∈ root.predFormulas
predFormulas_untl_left_sub, predFormulas_untl_right_sub : analogous
predFormulas_snce_left_sub, predFormulas_snce_right_sub : analogous
```
All are `Finset.Subset.trans Finset.subset_union_{left/right} h`.

### box_in_mcs_to_all_temporal_truth Helper
Takes `.box ψ ∈ A` and returns `temporal_truth ψ z'` on any Z_{f'}. Chain: box-equiv → box stability → Modal T → eff bridge → table_correctness → k-equiv transfer.

Note: this helper's `A` parameter must be passed explicitly (it was accidentally out of scope in an earlier draft).

## Countermodel Assembly

In `countermodel_discrete_reynolds_v2`:
1. FamIdx = subtype of box-equiv MCSes (already defined as `{N // SetMaximalConsistent N ∧ box next_top ∈ N ∧ box-equiv}`)
2. For each family, get Z via `limitdom_is_good` + `Classical.choice`
3. Z unbounded via `z_interval_carrier_contains_all` → derive lo = none, hi = none
4. Build modal_backward proof (contrapositive via bx_modal_witness_fc)
5. Get temporal_truth(φ.neg) at root via `limitdom_root_neg_truth` + `truth_transfer`
6. Package: `⟨ℤ, ..., multiFamTaskFrame FamIdx, multiFamTaskModel getZ atomMap, multiFamOmega FamIdx, multiFamHistory f₀ 0, ..., s.val, ...⟩`
7. Convert: `truth_corr` at (f₀, 0, s.val) gives `truth_at φ ↔ temporal_truth φ (toCarrier s.val)`; `temporal_truth φ.neg s` contradicts `truth_at φ`.

Note: `truth_transfer` gives `s : (getZ f₀).intervalCarrier`. Use `s.val` as the time in the TaskFrame.

## Next Steps
1. Add multi-family defs + predFormulas helpers + toCarrier to ReynoldsBridge.lean (verified to compile)
2. Add z_interval_box_constant' theorem
3. Add helper theorems (all_families_temporal_truth_to_mcs_root, box_in_mcs_to_all_temporal_truth)
4. Implement multiFam_truth_corr (structural induction, ~100 lines)
5. Rewrite countermodel_discrete_reynolds_v2 proof body (~40 lines)
6. Wire into completeness_discrete (1-line swap)
7. Verify full build + #print axioms

## Session
sess_1780545588_1d9001
