# Research Report: Closing the k=1 Sorry in `good_of_split_at_succ`

## Location

`Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` line 480

## Goal at Sorry

```
⊢ good sig (0 + 1) (orderedSum sig Bool witnesses)
```

i.e., `good sig 1 (orderedSum sig Bool witnesses)`.

## Analysis of NormalForm sig 1 0

**Type expansion**:
- `NormalForm sig 1 0 = (AtomKind sig 0 -> Bool) x (NormalForm sig 0 1 -> Bool)`
- `AtomKind sig 0` is empty (no variables means no predicate atoms, no order atoms)
- `NormalForm sig 0 1 = AtomKind sig 1 -> Bool`
- `AtomKind sig 1` has only predicate atoms `.pred p 0` (no order atoms since Fin 1 has no distinct pair)

**Concrete meaning**: `NormalForm sig 0 1` is effectively `sig.preds -> Bool` -- a "predicate profile" assigning true/false to each unary predicate for a single point.

## What 1-Equivalence Means

Two structures M and N are 1-equivalent iff they realize the same set of predicate profiles. Specifically, `k_type_of sig 1 M = k_type_of sig 1 N` records for each `f : NormalForm sig 0 1`:
- Does there exist an element x in M whose predicate membership matches f?

The atom component of `NormalForm sig 1 0` is trivial (domain is empty). Only the quantifier component matters.

**Key insight**: At depth 1, ORDER plays no role. The `AtomKind sig 1` type has no `.order` constructors (only `.pred p 0`). Therefore 1-equivalence is purely about which predicate profiles are realized, completely ignoring the linear order on the carrier.

## Finite Model Property at Depth 1

**Theorem**: For ANY ordered monadic structure M, `good sig 1 M`.

**Proof strategy**: Build a Z-interval with one integer per realized predicate profile.

1. Let `realized = {f : NormalForm sig 0 1 | exists x in M with profile f}` (a finite set, since `NormalForm sig 0 1` is `Fintype`)
2. Let `n = |realized|`
3. Build Z-interval `[0, n-1]` where integer `i` gets the predicate assignment of the `i`-th realized profile
4. Prove 1-equivalence using `nf_characteristic_satisfies` and `nf_agreement_from_shared_nf`

This works for ANY M including empty M (when n=0, the Z-interval [0,-1] is also empty).

## Why the k>=2 Technique Cannot Work Here

The k>=2 proof shows "has max" (depth-2 sentence `exists x. forall y. not(x < y)`) is expressible, then transfers boundedness from the original subintervals to Z1 and Z2 via `doets_lemma_1_1`. At k=1, this sentence has depth 2 > 1, so it cannot be transferred. The Z-intervals Z1, Z2 may be unbounded at depth 1.

## Verified Code Sketch

The following proof compiles sorry-free (verified via `lean_run_code`):

```lean
theorem good_one (sig : MonadicSignature) (M : OrderedMonadicStructure sig) :
    good sig 1 M := by
  classical
  let realized : Finset (NormalForm sig 0 1) :=
    Finset.univ.filter (fun f => ∃ x : M.carrier, nf_eval_nf M 0 1 (Fin.cons x Fin.elim0) f)
  let n := realized.card
  let Z : ZIntervalStructure sig := {
    lo := some 0
    hi := some ((n : ℤ) - 1)
    interp := fun p z =>
      if h : 0 ≤ z ∧ z < ↑n then
        (realized.equivFin.symm ⟨z.toNat, by omega⟩ : NormalForm sig 0 1) 
          (AtomKind.pred p (0 : Fin 1)) = true
      else False
  }
  refine ⟨Z, ?_⟩
  have hM := nf_characteristic_satisfies M 1 0 Fin.elim0
  suffices h_Z_sat : nf_eval_nf (Z.toOrdered sig) 1 0 Fin.elim0 
      (nf_characteristic M 1 0 Fin.elim0) by
    unfold k_equiv k_type_of
    funext nf; simp only [decide_eq_decide]
    exact nf_agreement_from_shared_nf M Fin.elim0 (Z.toOrdered sig) Fin.elim0
      (nf_characteristic M 1 0 Fin.elim0) hM h_Z_sat nf
  simp only [nf_eval_nf, nf_characteristic]
  have h_empty : IsEmpty (AtomKind sig 0) :=
    ⟨fun a => match a with | .pred _ i => Fin.elim0 i | .order i _ _ => Fin.elim0 i⟩
  constructor
  · intro a; exact h_empty.elim a
  · intro sub_nf
    simp only [decide_eq_true_eq]
    constructor
    · intro ⟨z, hz⟩
      have hz_mem := z.property
      simp only [Z, Option.elim] at hz_mem
      have hz_lt_n : z.val.toNat < n := by omega
      set g := (realized.equivFin.symm ⟨z.val.toNat, hz_lt_n⟩ : NormalForm sig 0 1)
      have h_Z_realizes_g : nf_eval_nf (Z.toOrdered sig) 0 (0 + 1) (Fin.cons z Fin.elim0) g := by
        intro a
        obtain ⟨p, hp⟩ : ∃ p : sig.preds, a = AtomKind.pred p 0 := by
          cases a with
          | pred p i => exact ⟨p, by congr; exact Fin.eq_zero i⟩
          | order i j h => exact absurd (Fin.eq_zero i ▸ Fin.eq_zero j ▸ rfl) h
        subst hp
        simp only [atom_eval, Fin.cons_zero, ZIntervalStructure.toOrdered]
        show Z.interp p z.val ↔ g (AtomKind.pred p 0) = true
        simp only [Z, g]
        rw [dif_pos (show 0 ≤ z.val ∧ z.val < ↑n from by omega)]
      have h_eq : sub_nf = g := 
        nf_eval_unique (Z.toOrdered sig) 0 (0 + 1) (Fin.cons z Fin.elim0) sub_nf g hz h_Z_realizes_g
      have hg_mem : (g : NormalForm sig 0 1) ∈ realized :=
        (realized.equivFin.symm ⟨z.val.toNat, hz_lt_n⟩).property
      rw [h_eq]
      exact (Finset.mem_filter.mp hg_mem).2
    · intro ⟨x, hx⟩
      have h_mem : sub_nf ∈ realized := by
        simp only [realized, Finset.mem_filter, Finset.mem_univ, true_and]
        exact ⟨x, hx⟩
      let idx := realized.equivFin ⟨sub_nf, h_mem⟩
      let z_val : ℤ := ↑(idx : ℕ)
      have hz_in : Z.lo.elim True (· ≤ z_val) ∧ Z.hi.elim True (z_val ≤ ·) := by
        simp only [Z, Option.elim, z_val]
        exact ⟨Int.natCast_nonneg _, by have := idx.isLt; omega⟩
      let z : (Z.toOrdered sig).carrier := ⟨z_val, hz_in⟩
      refine ⟨z, ?_⟩
      intro a
      obtain ⟨p, hp⟩ : ∃ p : sig.preds, a = AtomKind.pred p 0 := by
        cases a with
        | pred p i => exact ⟨p, by congr; exact Fin.eq_zero i⟩
        | order i j h => exact absurd (Fin.eq_zero i ▸ Fin.eq_zero j ▸ rfl) h
      subst hp
      simp only [atom_eval, Fin.cons_zero, ZIntervalStructure.toOrdered]
      show Z.interp p z_val ↔ sub_nf (AtomKind.pred p 0) = true
      simp only [Z]
      rw [dif_pos (show 0 ≤ z_val ∧ z_val < ↑n from by
        simp only [z_val]; exact ⟨Int.natCast_nonneg _, by have := idx.isLt; omega⟩)]
      suffices h : (realized.equivFin.symm ⟨z_val.toNat, _⟩ : NormalForm sig 0 1) = sub_nf by
        rw [h]
      have h_toNat : z_val.toNat = (idx : ℕ) := by simp [z_val]
      have h_fin_eq : (⟨z_val.toNat, _⟩ : Fin n) = idx := Fin.ext h_toNat
      rw [h_fin_eq]
      exact congrArg Subtype.val (Equiv.symm_apply_apply realized.equivFin ⟨sub_nf, h_mem⟩)
```

## How to Apply at the Sorry

Replace line 480 (`sorry`) with:

```lean
        exact good_one sig (orderedSum sig Bool witnesses)
```

Where `good_one` is defined earlier in the same file (before `good_of_split_at_succ`).

## Estimated Complexity

- **Lines of code**: ~75 lines for the `good_one` theorem
- **Replacement at sorry**: 1 line
- **Additional imports needed**: None (all tools already imported)
- **Placement**: Before `good_of_split_at_succ` (around line 328) or in the `/-! ## Good Structures -/` section

## Key Dependencies Used

- `nf_characteristic_satisfies` (NormalForm.lean) - characteristic NF is satisfied
- `nf_eval_unique` (NormalForm.lean) - uniqueness of satisfied NF
- `nf_agreement_from_shared_nf` (NormalForm.lean) - shared NF implies full agreement
- `Finset.equivFin` (Mathlib) - bijection between Finset and Fin n
- `AtomKind sig 0` emptiness (inline proof, matches existing pattern)
- `AtomKind sig 1` pred-only property (inline proof, matches `atomKind_one_pred_only`)
