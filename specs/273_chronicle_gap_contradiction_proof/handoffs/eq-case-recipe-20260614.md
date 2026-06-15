# Eq Case Proof Recipe (L974)

## Validated Proof Path

The following exact tactic sequence was tested and works through to the zone-bridge dispatch point:

### Backward direction (mpr: exist -> formula)
```lean
-- Inside: fun M h_UZ h_SZ t h_atoms => by
constructor
· sorry  -- forward (mp) direction
· -- Backward (mpr): ∃ x, nf_eval → formula truth
  intro ⟨x, h_eval⟩
  have h_x_eq := witness_eq_t_of_no_order M sub_nf t x h_gt h_lt h_eval
  subst h_x_eq
  -- After subst: t eliminated, x survives. Goal: temporal_truth M atomMap x (enriched_bypass_eq ...)
  let nf_x := nf_characteristic M 1 1 (fun _ => x)
  have h_nf_x := nf_characteristic_satisfies M 1 1 (fun _ => x)
  have h_compat := nf_x_compat_of_nf_eval M sub_nf x x h_eval nf_x h_nf_x
  show temporal_truth M atomMap x (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms)
  simp only [enriched_bypass_eq]
  rw [formula_disjList_iff]
  -- Goal is now: ∃ φ ∈ List.filterMap ..., temporal_truth M atomMap x φ
  let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  refine ⟨Formula.and (char_1 nf_x) (formula_conjList _), ?_, ?_⟩
  · -- Membership: show the disjunct is in the list
    rw [List.mem_filterMap]
    exact ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x), by simp [h_compat]⟩
  · -- Truth: show the disjunct holds
    rw [temporal_truth_and]
    constructor
    · exact (char_1_correct nf_x M h_UZ h_SZ x).mpr h_nf_x
    · rw [formula_conjList_iff]
      intro φ h_mem
      rw [List.mem_filterMap] at h_mem
      obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
      obtain ⟨h_eval_atoms, h_eval_quant⟩ := h_eval
      split_ifs at h_some with h_compat' h_yx_bool h_pos_below h_xy_bool h_pos_above h_pos_eq
      -- 6 zone cases follow. Each case:
      -- 1. Option.some_injective + subst h_eq
      -- 2. eq_case_orders to get h_xt, h_tx, h_yx_eq_yt, h_xy_eq_ty
      -- 3. Prove h_t_pred_1, h_t_pred_2 using ssn_xt_compatible extraction
      -- 4. Apply eq_case_zone_*.mpr composed with h_eval_quant
      -- For negative cases: simp [Formula.neg, temporal_truth], intro, absurd
```

### Forward direction (mp: formula -> exist)
```lean
· -- Forward (mp): formula truth → ∃ x, nf_eval
  intro h_formula
  -- CRITICAL: must unfold enriched_bypass_eq before rw
  have h_formula' := h_formula
  simp only [enriched_bypass_eq] at h_formula'
  rw [formula_disjList_iff] at h_formula'
  obtain ⟨φ, h_mem, h_truth⟩ := h_formula'
  rw [List.mem_filterMap] at h_mem
  obtain ⟨nf_x, _, h_some⟩ := h_mem
  split_ifs at h_some with h_compat_nfx
  · have h_eq_φ := Option.some_injective _ h_some; subst h_eq_φ
    rw [temporal_truth_and] at h_truth
    obtain ⟨h_char1, h_conj⟩ := h_truth
    have h_nf_x := (char_1_correct nf_x M h_UZ h_SZ t).mp h_char1
    -- Witness is t. Need nf_eval_nf M 1 2 [t,t] sub_nf
    refine ⟨t, ?_⟩
    constructor  -- splits into atom_part ∧ quant_part
    · -- Atom part: ∀ a, atom_eval M [t,t] a ↔ sub_nf.1 a
      -- Use h_nf_x (nf_eval at t for nf_x), h_compat_nfx (pred compat),
      -- h_pred_compat, h_t_compat, h_atoms
      sorry
    · -- Quant part: ∀ ssn, (∃ y, nf_eval 0 3 [y,t,t] ssn) ↔ sub_nf.2 ssn
      -- Same zone-by-zone structure as backward direction
      sorry
```

## Key Technical Facts

1. `ssn_xt_compat_x_preds` and `ssn_xt_compat_t_preds` are PRIVATE in ZoneBridge.lean
   - Extract manually: `simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat'`
   - Then `h_compat'.1.1.1` gives pred-var-1 match, need to also extract pred-var-2

2. h_t_pred_2 proof pattern:
   - Need `ssn (.pred p 2) = parent_atoms (.pred p 0)` from ssn_xt_compatible
   - The ssn_xt_compatible check structure for `false false` (eq direction) includes t-pred matching
   - But the exact extraction path depends on ssn_xt_compatible's definition internals

3. After subst, `h_atoms` becomes `∀ a, atom_eval M (fun x_1 ↦ x) a ↔ parent_atoms a = true`
   - This is equivalent to `atom_eval M (fun _ => x) a ↔ parent_atoms a`
   - Use `h_atoms (.pred p ⟨0, by omega⟩)` then `simp only [atom_eval]` to get `M.interp p x ↔ parent_atoms (.pred p 0)`
