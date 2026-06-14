# Bracket Sorry (L1358) Resolution

## Status: Structural proof complete, sorted-witness sub-lemma needs work

## Approach

The bracket sorry at L1358 requires `BracketFormula.holds M atomMap vea.snd.bracket t x`
where `vea = enriched_vecEA2_until ...`.

### Helper 1: `seg_guard_holds`
Proves segment guards hold for any y in (t, x). For each negative between_tx ssn,
h_eval_quant says `sub_nf.2 ssn = false`, so the existential fails. If char_y held
at some y, we could reconstruct the existential via between_tx_temporal_iff, contradicting
the false bit.

**Status**: Complete, compiles.

### Helper 2: `bracket_holds_of_eval_quant`  
Constructs BracketFormula.holds from h_eval_quant. Two cases:
- n = 0 (no positive between_tx ssns): Just segment guards, proven via seg_guard_holds.
- n + 1 (positive ssns exist): Need sorted witnesses. Each positive ssn provides a
  witness via h_eval_quant + between_tx_temporal_iff. The sorted-witness construction
  requires showing distinct ssns produce distinct witness points (different y-projections)
  and then sorting them.

**Status**: n=0 case complete. n+1 case has sorry for sorted-witness construction.

### Wiring
The bracket sorry is replaced with:
```lean
exact bracket_holds_of_eval_quant atomMap h_surj nf_x_1var parent_atoms sub_nf M x t h_t_lt_x
  (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x; have := h_atom (.pred p ⟨0, by omega⟩)
               simp only [atom_eval] at this; exact this)
  (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
               simp only [atom_eval] at this; exact this)
  h_eval_quant
```

## Code to Insert

Insert after `between_tx_temporal_iff` (after the line containing `/-! ## Until Case`):

```lean
/-! ## Bracket construction helper -/

private theorem seg_guard_holds
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier) (h_tx : t < x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true)
    (h_eval_quant : ∀ ssn : NormalForm sig 0 3,
      (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
      sub_nf.2 ssn = true)
    (y : M.carrier) (h_ty : t < y) (h_yx : y < x) :
    TemporalPred.eval_at M atomMap
      ⟨formula_conjList
        (List.map (fun ssn => (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)
          ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter (fun ssn =>
            ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
            (ssn_zone_until ssn == .between_tx) &&
            !sub_nf.2 ssn)))⟩ y := by
  simp only [TemporalPred.eval_at]
  rw [formula_conjList_iff]
  intro φ h_mem
  rw [List.mem_map] at h_mem
  obtain ⟨ssn, h_ssn_mem, h_eq⟩ := h_mem
  subst h_eq
  rw [List.mem_filter] at h_ssn_mem
  obtain ⟨h_ssn_elem, h_cond⟩ := h_ssn_mem
  simp only [Bool.and_eq_true, beq_iff_eq, Bool.not_eq_true'] at h_cond
  obtain ⟨⟨h_compat, h_zone⟩, h_neg⟩ := h_cond
  simp only [Formula.neg, temporal_truth]
  intro h_char
  have h_y_preds := (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mp h_char
  have h_exist : ∃ y', nf_eval_nf M 0 3 (Fin.cons y' (Fin.cons x (fun _ => t))) ssn :=
    (between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
      h_compat h_zone h_x_pred h_t_pred).mpr ⟨y, h_ty, h_yx, h_y_preds⟩
  have h_pos := (h_eval_quant ssn).mp h_exist
  rw [h_neg] at h_pos
  exact absurd h_pos (by decide)

set_option maxHeartbeats 1600000 in
private theorem bracket_holds_of_eval_quant
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier) (h_tx : t < x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true)
    (h_eval_quant : ∀ ssn : NormalForm sig 0 3,
      (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
      sub_nf.2 ssn = true) :
    let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
      ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
      (ssn_zone_until ssn == .between_tx) &&
      sub_nf.2 ssn
    let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
      ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
      (ssn_zone_until ssn == .between_tx) &&
      !sub_nf.2 ssn
    let seg_guard : TemporalPred :=
      ⟨formula_conjList (neg_between.map fun ssn =>
        (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
    let n := pos_between.length
    let bracket : BracketFormula n :=
      { pointTypes := fun i =>
          nfPred atomMap h_surj (nf_y_proj (pos_between[i.val]'(by omega)))
        segmentTypes := fun _ => seg_guard }
    bracket.holds M atomMap t x := by
  simp only
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, IntervalPattern.holds]
  set pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) &&
    sub_nf.2 ssn with h_pos_def
  have h_seg : ∀ y : M.carrier, t < y → y < x →
      TemporalPred.eval_at M atomMap
        ⟨formula_conjList
          (List.map (fun ssn => (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)
            ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter (fun ssn =>
              ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
              (ssn_zone_until ssn == .between_tx) && !sub_nf.2 ssn)))⟩ y :=
    fun y h_ty h_yx => seg_guard_holds atomMap h_surj nf_x_1var parent_atoms sub_nf M x t h_tx
      h_x_pred h_t_pred h_eval_quant y h_ty h_yx
  split
  next h_len _ =>
    intro y h_ty h_yx; exact h_seg y h_ty h_yx
  next n h_len _ =>
    sorry -- Sorted-witness construction for n+1 positive between_tx ssns
```

## Remaining Work

The n+1 case requires constructing a sorted witness function. This needs:
1. For each i : Fin (n+1), a witness y_i with t < y_i < x and matching nfPred
2. The witnesses must be strictly increasing
3. Segment guards hold on all segments

The mathematical argument: distinct ssns in pos_between have distinct y-projections 
(different predicate profiles), so their witnesses are at distinct points in the linear 
order. n+1 distinct points in a linear order can be sorted into a strictly increasing 
sequence. The segment guards hold for any y in (t,x) by seg_guard_holds.

This requires either:
- A `Finset.sort`-based approach to sort the witness values
- Or an explicit construction using `List.mergeSort` on the witness list
