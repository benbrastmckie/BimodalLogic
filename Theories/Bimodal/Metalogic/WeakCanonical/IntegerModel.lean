import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.WeakCanonical.Table
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Mathlib.Data.Fintype.Sort
import Mathlib.Order.SuccPred.LinearLocallyFinite

/-!
# Integer Model Construction (Reynolds Theorem 15)

Defines "good" and "very good" discrete structures, contemporaneous
equivalence (~M), the gap-elimination chain for discrete orders, the
one-class theorem, and the main `chronicle_is_good` result.

## Key Definitions
- `ZIntervalStructure sig`: a monadic structure whose carrier is a Z-interval
- `good sig k M`: M is k-equivalent to some Z-interval structure
- `very_good sig k M`: all subintervals of M are good
- `contemp_equiv sig k M a b`: a ~M b if the subinterval between them is very good

## Status
Phase 2: `contemp_equiv_is_equiv` proved WITHOUT `IsSuccArchimedean`
using Reynolds Lemma 17 (ordered sum decomposition at b + doets_lemma_1_4).
Phase 4: `very_good_implies_good` uses PredOrder (required for half-open partition
correctness). Reynolds Lemma 16 via cofinal decomposition into disjoint half-open
pieces + doets_lemma_1_4 + shift-and-glue. `cofinal_decomposition_k_equiv` proved
via order isomorphism from M to orderedSum of half-open pieces [a(i), a(i+1)).
The original closed-interval formulation was incorrect (boundary point duplication
makes orderedSum non-k-equivalent to M in general).
ordered_sum_of_good_bounded_is_good closed via shift-and-glue OrderIso construction.
Phases 3, 5-6 still use `IsSuccArchimedean` (to be removed in subsequent phases).

## References
- Reynolds 1994, Theorem 15: `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Doets 1989, Section 1: `literature/Doets_1989_Monadic_Pi11_Theories.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core

/-! ## Z-Interval Structures -/

/--
A Z-interval structure: a monadic structure whose carrier is an interval of ℤ.
The carrier of `toOrdered` is the ACTUAL interval (subtype of ℤ), matching
Reynolds 1994's definition where "good" means k-equiv to a structure whose
flow of time IS an interval of the integers.
-/
structure ZIntervalStructure (sig : MonadicSignature) where
  /-- Optional lower bound (none = unbounded below) -/
  lo : Option ℤ
  /-- Optional upper bound (none = unbounded above) -/
  hi : Option ℤ
  /-- Predicate interpretations on the interval -/
  interp (p : sig.preds) : ℤ → Prop

/-- The interval carrier: {z : ℤ // lo ≤ z ∧ z ≤ hi} with Option bounds. -/
def ZIntervalStructure.intervalCarrier {sig : MonadicSignature}
    (Z : ZIntervalStructure sig) : Type :=
  {z : ℤ // Z.lo.elim True (· ≤ z) ∧ Z.hi.elim True (z ≤ ·)}

instance ZIntervalStructure.intervalCarrier_linearOrder {sig : MonadicSignature}
    (Z : ZIntervalStructure sig) : LinearOrder Z.intervalCarrier :=
  Subtype.instLinearOrder _

/-- Convert a Z-interval structure to a monadic structure (carrier = interval). -/
def ZIntervalStructure.toMonadic (sig : MonadicSignature) (Z : ZIntervalStructure sig) :
    MonadicStructure sig where
  carrier := Z.intervalCarrier
  interp p x := Z.interp p x.val

/-- Convert a Z-interval structure to an ordered monadic structure.
    The carrier is the actual interval {z : ℤ // lo ≤ z ∧ z ≤ hi},
    with ℤ's natural order inherited via Subtype. -/
def ZIntervalStructure.toOrdered (sig : MonadicSignature) (Z : ZIntervalStructure sig) :
    OrderedMonadicStructure sig where
  carrier := Z.intervalCarrier
  interp p x := Z.interp p x.val
  carrier_order := inferInstance

/-! ## Good Structures -/

/--
A structure is "good" (at depth k) if it is k-equivalent to some
Z-interval structure. Uses genuine `k_equiv` via `eval`.
-/
def good (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig) : Prop :=
  ∃ (Z : ZIntervalStructure sig),
    k_equiv sig k M (Z.toOrdered sig)

/--
"Very good": every subinterval of the structure is good.
-/
def very_good (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig) : Prop :=
  ∀ (a b : M.carrier), a ≤ b → good sig k (M.subinterval sig a b)

/--
Order-isomorphic structures that preserve predicates are k-equivalent.

The proof uses `nf_characteristic` uniqueness: both structures satisfy the same
characteristic normal form because the isomorphism preserves all atoms
(predicates and order) and bijects witnesses at each quantifier level.
-/
theorem k_equiv_of_iso (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) (f : M.carrier ≃o N.carrier)
    (h_pred : ∀ (p : sig.preds) (x : M.carrier), M.interp p x ↔ N.interp p (f x)) :
    k_equiv sig k M N := by
  -- Key helper: nf_eval transfers across the isomorphism
  suffices h_transfer : ∀ (kk nn : Nat) (env_M : Fin nn → M.carrier)
      (nf' : NormalForm sig kk nn),
      nf_eval_nf M kk nn env_M nf' ↔ nf_eval_nf N kk nn (fun i => f (env_M i)) nf' by
    unfold k_equiv k_type_of
    funext nf; simp only [decide_eq_decide]
    have h := h_transfer k 0 Fin.elim0 nf
    simp only [show (fun i : Fin 0 => f (Fin.elim0 i)) = Fin.elim0 from
      funext (fun i => Fin.elim0 i)] at h
    exact h
  -- Prove the transfer by induction on kk
  intro kk; induction kk with
  | zero =>
    intro nn env_M nf'
    simp only [nf_eval_nf]
    have h_atom : ∀ a : AtomKind sig nn,
        atom_eval M env_M a ↔ atom_eval N (fun i => f (env_M i)) a := by
      intro a; cases a with
      | pred p i => exact h_pred p (env_M i)
      | order i j hne =>
        show env_M i < env_M j ↔ f (env_M i) < f (env_M j)
        exact f.lt_iff_lt.symm
    constructor
    · intro h a; exact (h_atom a).symm.trans (h a)
    · intro h a; exact (h_atom a).trans (h a)
  | succ kk ih =>
    intro nn env_M ⟨aa, qa⟩
    simp only [nf_eval_nf]
    have h_atom : ∀ a : AtomKind sig nn,
        atom_eval M env_M a ↔ atom_eval N (fun i => f (env_M i)) a := by
      intro a; cases a with
      | pred p i => exact h_pred p (env_M i)
      | order i j hne =>
        show env_M i < env_M j ↔ f (env_M i) < f (env_M j)
        exact f.lt_iff_lt.symm
    have h_quant : ∀ snf : NormalForm sig kk (nn + 1),
        (∃ x : M.carrier, nf_eval_nf M kk (nn + 1) (Fin.cons x env_M) snf) ↔
        (∃ y : N.carrier, nf_eval_nf N kk (nn + 1)
          (Fin.cons y (fun i => f (env_M i))) snf) := by
      intro snf; constructor
      · rintro ⟨x, hx⟩
        refine ⟨f x, ?_⟩
        have h1 := (ih (nn + 1) (Fin.cons x env_M : Fin (nn + 1) → M.carrier) snf).mp hx
        convert h1 using 2
        rename_i i; cases i using Fin.cases with
        | zero => rfl
        | succ j => rfl
      · rintro ⟨y, hy⟩
        refine ⟨f.symm y, ?_⟩
        apply (ih (nn + 1) (Fin.cons (f.symm y) env_M : Fin (nn + 1) → M.carrier) snf).mpr
        convert hy using 2
        rename_i i; cases i using Fin.cases with
        | zero => simp [Fin.cons, OrderIso.apply_symm_apply]
        | succ j => rfl
    constructor
    · intro ⟨ha, hq⟩
      exact ⟨fun a => (h_atom a).symm.trans (ha a),
             fun snf => (h_quant snf).symm.trans (hq snf)⟩
    · intro ⟨ha, hq⟩
      exact ⟨fun a => (h_atom a).trans (ha a),
             fun snf => (h_quant snf).trans (hq snf)⟩

/-- Every finite structure is good: it is k-equivalent to a Z-interval.

    Proof (Doets 1989, Theorem 1.1 for finite case): A finite ordered
    monadic structure M with n elements is order-isomorphic to the integer
    interval [0, n-1]. We construct a ZIntervalStructure whose carrier is
    exactly this interval and whose predicates match M under the isomorphism.
    Then k-equivalence follows from the order-isomorphism preserving all
    atoms (predicates and order).
-/
theorem finite_structures_good (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [Fintype M.carrier] :
    good sig k M := by
  -- Get cardinality
  set n := Fintype.card M.carrier with hn
  -- Build order isomorphism iso : Fin n ≃o M.carrier
  let iso : Fin n ≃o M.carrier := monoEquivOfFin M.carrier rfl
  -- Construct Z-interval structure on [0, (n:ℤ)-1]
  let Z : ZIntervalStructure sig := {
    lo := some 0
    hi := some ((n : ℤ) - 1)
    interp := fun p (z : ℤ) =>
      if h : 0 ≤ z ∧ z < ↑n then
        M.interp p (iso ⟨z.toNat, by omega⟩)
      else
        False
  }
  refine ⟨Z, ?_⟩
  let finToZ : Fin n ≃ Z.intervalCarrier := {
    toFun := fun i => ⟨↑(i : ℕ), by
      simp only [Z, ZIntervalStructure.intervalCarrier, Option.elim]
      exact ⟨Int.natCast_nonneg _, by omega⟩⟩
    invFun := fun ⟨z, hz⟩ => ⟨z.toNat, by
      simp only [Z, ZIntervalStructure.intervalCarrier, Option.elim] at hz; omega⟩
    left_inv := fun ⟨i, hi⟩ => by ext; simp
    right_inv := fun ⟨z, hz⟩ => by
      apply Subtype.ext
      simp only [Z, ZIntervalStructure.intervalCarrier, Option.elim] at hz ⊢
      omega
  }
  have finToZ_mono : Monotone finToZ := by
    intro ⟨a, _⟩ ⟨b, _⟩ hab
    show (↑a : ℤ) ≤ ↑b
    exact_mod_cast hab
  have finToZ_inv_mono : Monotone finToZ.symm := by
    intro ⟨a, ha⟩ ⟨b, hb⟩ hab
    show (a : ℤ).toNat ≤ (b : ℤ).toNat
    simp only [Z, ZIntervalStructure.intervalCarrier, Option.elim] at ha hb
    have hab' : a ≤ b := hab
    omega
  let finToZOrd : Fin n ≃o Z.intervalCarrier :=
    Equiv.toOrderIso finToZ finToZ_mono finToZ_inv_mono
  let fullIso : M.carrier ≃o (Z.toOrdered sig).carrier :=
    iso.symm.trans finToZOrd
  apply k_equiv_of_iso sig k M (Z.toOrdered sig) fullIso
  intro p x
  show M.interp p x ↔ Z.interp p (fullIso x).val
  have hval : (fullIso x).val = ↑((iso.symm x : Fin n) : ℕ) := rfl
  rw [show Z.interp p (fullIso x).val =
    Z.interp p ↑((iso.symm x : Fin n) : ℕ) from by rw [hval]]
  simp only [Z]
  have h_cond : (0 : ℤ) ≤ ↑((iso.symm x : Fin n) : ℕ) ∧
      (↑((iso.symm x : Fin n) : ℕ) : ℤ) < ↑n := ⟨Int.natCast_nonneg _,
      by exact_mod_cast (iso.symm x).isLt⟩
  rw [dif_pos h_cond]
  have h_toNat : (↑((iso.symm x : Fin n) : ℕ) : ℤ).toNat = ((iso.symm x : Fin n) : ℕ) := by
    simp
  simp only [h_toNat]
  simp [OrderIso.apply_symm_apply]

/-! ## Succ-Iteration Monotonicity -/

/--
Iterated successor is monotone: if m ≤ n then succ^m(a) ≤ succ^n(a).
-/
private theorem succ_iterate_le {α : Type} [Preorder α] [SuccOrder α]
    (a : α) {m n : Nat} (h : m ≤ n) :
    Order.succ^[m] a ≤ Order.succ^[n] a := by
  induction n with
  | zero => simp [Nat.le_zero.mp h]
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact le_refl _
    · exact le_trans (ih (Nat.le_of_lt_succ h_lt))
        (by rw [Function.iterate_succ']; exact Order.le_succ _)

/--
In a succ-Archimedean linear order, every bounded interval [a, b] is finite.
-/
theorem subinterval_finite_of_succ_archimedean (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier]
    [IsSuccArchimedean M.carrier]
    (a b : M.carrier) (hab : a ≤ b) :
    Finite (M.subinterval sig a b).carrier := by
  obtain ⟨n, hn⟩ := IsSuccArchimedean.exists_succ_iterate_of_le hab
  let f : Fin (n + 1) → (M.subinterval sig a b).carrier :=
    fun i => ⟨Order.succ^[i.val] a, succ_iterate_le a (Nat.zero_le _),
      hn ▸ succ_iterate_le a (Nat.le_of_lt_succ i.isLt)⟩
  have hf_surj : Function.Surjective f := by
    intro ⟨x, hax, hxb⟩
    obtain ⟨m, hm⟩ := IsSuccArchimedean.exists_succ_iterate_of_le hax
    by_cases hle : m ≤ n
    · exact ⟨⟨m, Nat.lt_succ_of_le hle⟩, Subtype.ext hm⟩
    · push_neg at hle
      have h_n_le_m : n ≤ m := le_of_lt hle
      have h_le : Order.succ^[n] a ≤ Order.succ^[m] a := succ_iterate_le a h_n_le_m
      have h_eq : x = Order.succ^[n] a :=
        le_antisymm (hn ▸ hxb) (le_trans h_le (le_of_eq hm))
      exact ⟨⟨n, Nat.lt_succ_of_le le_rfl⟩, Subtype.ext (h_eq ▸ rfl)⟩
  exact Finite.of_surjective f hf_surj

/-! ## Transitivity Helpers (Reynolds Lemma 17) -/

/--
Subinterval of a subinterval flattens: a nested subinterval is k-equivalent
to the corresponding direct subinterval of M.
-/
theorem subinterval_of_subinterval_k_equiv (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (a b : M.carrier)
    (c d : (M.subinterval sig a b).carrier) :
    k_equiv sig k ((M.subinterval sig a b).subinterval sig c d)
      (M.subinterval sig c.val d.val) := by
  let f : ((M.subinterval sig a b).subinterval sig c d).carrier ≃o
      (M.subinterval sig c.val d.val).carrier := {
    toEquiv := {
      toFun := fun ⟨⟨x, hax, hxb⟩, hcx, hxd⟩ => ⟨x, hcx, hxd⟩
      invFun := fun ⟨x, hcx, hxd⟩ => ⟨⟨x, le_trans c.property.1 hcx,
        le_trans hxd d.property.2⟩, hcx, hxd⟩
      left_inv := by intro ⟨⟨_, _, _⟩, _, _⟩; rfl
      right_inv := by intro ⟨_, _, _⟩; rfl
    }
    map_rel_iff' := by intro ⟨⟨_, _, _⟩, _, _⟩ ⟨⟨_, _, _⟩, _, _⟩; exact Iff.rfl
  }
  apply k_equiv_of_iso sig k _ _ f
  intro p ⟨⟨_, _, _⟩, _, _⟩
  exact Iff.rfl

/--
Good of a very-good subinterval: if [a,b] is very good and c,d are within [a,b],
then M.subinterval(c,d) is good.
-/
theorem good_of_very_good_subinterval (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (a b : M.carrier) (hab : a ≤ b)
    (h_vg : very_good sig k (M.subinterval sig a b))
    (c d : M.carrier) (hac : a ≤ c) (hdb : d ≤ b) (hcd : c ≤ d) :
    good sig k (M.subinterval sig c d) := by
  let c' : (M.subinterval sig a b).carrier := ⟨c, hac, le_trans hcd hdb⟩
  let d' : (M.subinterval sig a b).carrier := ⟨d, le_trans hac hcd, hdb⟩
  have h_good := h_vg c' d' hcd
  obtain ⟨Z, hZ⟩ := h_good
  exact ⟨Z, (subinterval_of_subinterval_k_equiv sig k M a b c' d').symm.trans hZ⟩

/-- Every structure is good at depth 1 (monadic FO finite model property at depth 1).
At depth 1, k-equiv only captures which predicate profiles are realized (no order atoms).
Construct a Z-interval with one element per realized profile. -/
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

/--
If M|[t,u] decomposes at b (with t ≤ b < u in a SuccOrder with NoMaxOrder),
and both M|[t,b] and M|[succ b, u] are good, then M|[t,u] is good.

This is the core of Reynolds Lemma 17's hard case. The proof:
1. Construct order iso from M|[t,u] to orderedSum Bool [M|[t,b], M|[succ b, u]]
2. Apply doets_lemma_1_4 with the Z-interval witnesses
3. Show the ordered sum of Z-intervals is good

Reynolds 1994: "M|[t,b] and M|[b+1,u] are both good. Choose Z1 ~k M|[t,b]
and Z2 ~k M|[b+1,u]. Then M|[t,u] ~k Z1 + Z2 whose flow is isomorphic
to an interval of Z itself."
-/
theorem good_of_split_at_succ (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [NoMaxOrder M.carrier]
    (t b u : M.carrier) (htb : t ≤ b) (hbu : b < u)
    (h_left : good sig k (M.subinterval sig t b))
    (h_right : good sig k (M.subinterval sig (Order.succ b) u)) :
    good sig k (M.subinterval sig t u) := by
  -- Reynolds Lemma 17 hard case: decompose M|[t,u] at b/succ(b), apply doets_lemma_1_4.
  -- Proof structure:
  --   M|[t,u] ~k orderedSum Bool pieces    (via OrderIso, SuccOrder gives partition)
  --           ~k orderedSum Bool witnesses  (via doets_lemma_1_4, pointwise k-equiv)
  --           ~k Z3.toOrdered              (witnesses form a finite orderedSum)
  obtain ⟨Z1, hZ1⟩ := h_left
  obtain ⟨Z2, hZ2⟩ := h_right
  let pieces : Bool → OrderedMonadicStructure sig :=
    fun i => if i = false then M.subinterval sig t b else M.subinterval sig (Order.succ b) u
  let witnesses : Bool → OrderedMonadicStructure sig :=
    fun i => if i = false then Z1.toOrdered sig else Z2.toOrdered sig
  -- Step 1: M|[t,u] ~k orderedSum Bool pieces via interval decomposition
  -- The OrderIso exists because SuccOrder ensures every x in [t,u] satisfies
  -- x ≤ b ∨ Order.succ b ≤ x (no elements between b and succ b).
  -- Predicates are preserved because both sides use M.interp on the same element.
  have h_iso : k_equiv sig k (M.subinterval sig t u) (orderedSum sig Bool pieces) := by
    -- Construct OrderIso from M|[t,u] to orderedSum Bool [M|[t,b], M|[succ b, u]]
    -- Key: SuccOrder ensures every x in [t,u] satisfies x ≤ b ∨ Order.succ b ≤ x
    letI inst_ord : LinearOrder (orderedSum sig Bool pieces).carrier :=
      (orderedSum sig Bool pieces).carrier_order
    let e : (M.subinterval sig t u).carrier ≃ (orderedSum sig Bool pieces).carrier := {
      toFun := fun ⟨x, htx, hxu⟩ =>
        if hxb : x ≤ b then ⟨false, ⟨x, htx, hxb⟩⟩
        else ⟨true, ⟨x, Order.succ_le_iff.mpr (lt_of_not_le hxb), hxu⟩⟩
      invFun := fun ⟨i, elem⟩ => match i with
        | false => ⟨elem.val, elem.property.1, le_trans elem.property.2 (le_of_lt hbu)⟩
        | true => ⟨elem.val, le_trans htb (le_trans (Order.le_succ b) elem.property.1),
                   elem.property.2⟩
      left_inv := by intro ⟨x, htx, hxu⟩; simp only; split_ifs with hxb <;> rfl
      right_inv := by
        intro ⟨i, elem⟩; match i with
        | false =>
          simp only [dif_pos elem.property.2]
          exact Sigma.ext rfl (heq_of_eq (Subtype.ext rfl))
        | true =>
          simp only [dif_neg (not_le.mpr (lt_of_lt_of_le
            (Order.lt_succ_of_not_isMax (not_isMax b)) elem.property.1))]
          exact Sigma.ext rfl (heq_of_eq (Subtype.ext rfl))
    }
    have hm1 : Monotone e := by
      intro ⟨x, htx, hxu⟩ ⟨y, hty, hyu⟩ (hxy : x ≤ y)
      simp only [e, Equiv.coe_fn_mk]
      split_ifs with hxb hyb hyb
      · show @LE.le _ inst_ord.toLE ⟨false, ⟨x, htx, hxb⟩⟩ ⟨false, ⟨y, hty, hyb⟩⟩
        exact Sigma.Lex.le_def.mpr (Or.inr ⟨rfl, hxy⟩)
      · show @LE.le _ inst_ord.toLE ⟨false, ⟨x, htx, hxb⟩⟩
            ⟨true, ⟨y, Order.succ_le_iff.mpr (lt_of_not_le hyb), hyu⟩⟩
        exact Sigma.Lex.le_def.mpr (Or.inl Bool.false_lt_true)
      · exact absurd (le_trans hxy hyb) hxb
      · show @LE.le _ inst_ord.toLE
            ⟨true, ⟨x, Order.succ_le_iff.mpr (lt_of_not_le hxb), hxu⟩⟩
            ⟨true, ⟨y, Order.succ_le_iff.mpr (lt_of_not_le hyb), hyu⟩⟩
        exact Sigma.Lex.le_def.mpr (Or.inr ⟨rfl, hxy⟩)
    have hm2 : Monotone e.symm := by
      intro a c hac
      obtain ⟨ia, ea⟩ := a; obtain ⟨ic, ec⟩ := c
      have hac' := Sigma.Lex.le_def.mp hac
      show (e.symm ⟨ia, ea⟩).val ≤ (e.symm ⟨ic, ec⟩).val
      revert hac'; cases ia <;> cases ic <;> simp only [e, Equiv.coe_fn_symm_mk] <;> intro hac'
      · rcases hac' with h | ⟨_, h⟩
        · exact absurd h (lt_irrefl _)
        · exact h
      · exact le_trans ea.property.2 (le_trans (Order.le_succ b) ec.property.1)
      · rcases hac' with h | ⟨h, _⟩
        · exact absurd h (by decide)
        · exact absurd h (by decide)
      · rcases hac' with h | ⟨_, h⟩
        · exact absurd h (lt_irrefl _)
        · exact h
    have h_pred : ∀ (p : sig.preds) (x : (M.subinterval sig t u).carrier),
        (M.subinterval sig t u).interp p x ↔
          (orderedSum sig Bool pieces).interp p (e x) := by
      intro p ⟨x, htx, hxu⟩
      have he : e ⟨x, htx, hxu⟩ = if hxb : x ≤ b then ⟨false, ⟨x, htx, hxb⟩⟩
          else ⟨true, ⟨x, Order.succ_le_iff.mpr (lt_of_not_le hxb), hxu⟩⟩ := rfl
      rw [he]; split_ifs with hxb <;>
        simp [pieces, OrderedMonadicStructure.subinterval, orderedSum]
    exact k_equiv_of_iso sig k _ _ (Equiv.toOrderIso e hm1 hm2) h_pred
  -- Step 2: orderedSum Bool pieces ~k orderedSum Bool witnesses via doets_lemma_1_4
  have h_sum : k_equiv sig k (orderedSum sig Bool pieces) (orderedSum sig Bool witnesses) :=
    doets_lemma_1_4 sig k Bool pieces witnesses
      (fun i => by simp only [pieces, witnesses]; split <;> [exact hZ1; exact hZ2])
  -- Step 3: orderedSum Bool witnesses is good
  -- Both Z-intervals are bounded (M|[t,b] has max b, M|[succ b, u] has max u,
  -- and k-equiv at k ≥ 2 preserves "has a max/min"; at k < 2, good holds trivially).
  -- Bounded Z-intervals have Fintype carrier (intervals of ℤ are finite).
  -- Sigma of two Fintypes is Fintype, so finite_structures_good applies.
  have h_good : good sig k (orderedSum sig Bool witnesses) := by
    -- The ordered sum witnesses = [Z1.toOrdered, Z2.toOrdered].
    -- We construct a single Z-interval Z3 that is k-equiv to this ordered sum.
    -- Z3 uses lo=none, hi=none (all of ℤ) with predicates defined via a
    -- bijection from the Sigma carrier. The bijection maps:
    --   (false, z) ↦ 2*z     (even integers for Z1's elements)
    --   (true, z)  ↦ 2*z + 1 (odd integers for Z2's elements)
    -- This preserves the lexicographic order because:
    --   - All evens from Z1 are interleaved with odds from Z2
    --   Wait, this does NOT preserve order (2*1 > 2*0+1).
    --
    -- Correct approach: use a simple shift.
    -- Map (false, z) ↦ 2*z and (true, z) ↦ 2*z+1 does NOT work for order.
    -- The correct map for lex order: since false < true,
    --   ALL (false, _) elements must map below ALL (true, _) elements.
    -- This is impossible with a fixed bijection to ℤ unless one side is bounded.
    --
    -- Since we cannot guarantee boundedness without the expressibility lemma,
    -- we use the k-equivalence directly through the already-established chain:
    --   M|[t,u] ~k orderedSum pieces ~k orderedSum witnesses
    -- and the fact that M|[t,u] IS good implies orderedSum witnesses is good
    -- (by transitivity of k-equiv and the definition of good).
    -- But this is CIRCULAR: we're trying to prove M|[t,u] is good!
    --
    -- The correct non-circular argument: since M|[t,b] has a max element (b)
    -- and k-equiv preserves "has a max" (expressible in depth 1), Z1 must be
    -- bounded above. Similarly Z2 is bounded below. With both bounded, the
    -- shift-and-glue gives a single Z-interval.
    --
    -- For k ≥ 1: bounded arguments work.
    -- For k = 0: all nonempty structures are 0-equivalent, so good holds trivially.
    --
    -- Implementation: case split on k, then use boundedness for k ≥ 1.
    -- At k = 0, we directly construct a witness.
    cases k with
    | zero =>
      -- At depth 0, all structures have the same 0-type because AtomKind sig 0
      -- is empty (no variables). So any Z-interval witnesses goodness.
      refine ⟨⟨some 0, some 0, fun _ _ => True⟩, ?_⟩
      unfold k_equiv k_type_of; funext nf; simp only [decide_eq_decide]
      have h_empty : IsEmpty (AtomKind sig 0) :=
        ⟨fun a => match a with | .pred _ i => Fin.elim0 i | .order i _ _ => Fin.elim0 i⟩
      constructor <;> intro _ a <;> exact h_empty.elim a
    | succ k' =>
      -- At depth k'+1 ≥ 1, case split: k'=0 uses finite model property,
      -- k'≥1 uses expressibility of "has max/min" (depth 2) via doets_lemma_1_1.
      cases k' with
      | zero =>
        -- k = 1. Finite model property at depth 1 (good_one).
        exact good_one sig (orderedSum sig Bool witnesses)
      | succ k'' =>
        -- k = k''+2 ≥ 2. Use expressibility: "has max/min" has depth 2 ≤ k.
        -- Transfer via doets_lemma_1_1 to show Z1, Z2 are fully bounded → Fintype → good.
        let has_max_sent : MonadicSentence sig := .ex (.all (.not (.lt 1 0)))
        let has_min_sent : MonadicSentence sig := .ex (.all (.not (.lt 0 1)))
        have h_depth_max : has_max_sent.quantifier_depth ≤ k'' + 2 := by
          simp [has_max_sent, MonadicFormula.quantifier_depth]
        have h_depth_min : has_min_sent.quantifier_depth ≤ k'' + 2 := by
          simp [has_min_sent, MonadicFormula.quantifier_depth]
        -- Bridge k_equiv to nf_eval_nf iff (needed for doets_lemma_1_1)
        have h_same_nf_Z1 : ∀ nf : NormalForm sig (k'' + 2) 0,
            nf_eval_nf (OrderedMonadicStructure.subinterval sig M t b) (k'' + 2) 0 Fin.elim0 nf ↔
            nf_eval_nf (ZIntervalStructure.toOrdered sig Z1) (k'' + 2) 0 Fin.elim0 nf := by
          intro nf; have h := congr_fun hZ1 nf; simp [k_type_of] at h; exact_mod_cast h
        have h_same_nf_Z2 : ∀ nf : NormalForm sig (k'' + 2) 0,
            nf_eval_nf (OrderedMonadicStructure.subinterval sig M (Order.succ b) u) (k'' + 2) 0 Fin.elim0 nf ↔
            nf_eval_nf (ZIntervalStructure.toOrdered sig Z2) (k'' + 2) 0 Fin.elim0 nf := by
          intro nf; have h := congr_fun hZ2 nf; simp [k_type_of] at h; exact_mod_cast h
        -- M|[t,b] has max (b) and min (t); M|[succ b, u] has max (u) and min (succ b)
        have h_M_has_max : eval (OrderedMonadicStructure.subinterval sig M t b) Fin.elim0 has_max_sent := by
          simp only [has_max_sent, eval, Fin.cons]
          exact ⟨⟨b, htb, le_refl b⟩, fun y => not_lt.mpr y.property.2⟩
        have h_M_has_min : eval (OrderedMonadicStructure.subinterval sig M t b) Fin.elim0 has_min_sent := by
          simp only [has_min_sent, eval, Fin.cons]
          exact ⟨⟨t, le_refl t, htb⟩, fun y => not_lt.mpr y.property.1⟩
        have h_M2_has_max : eval (OrderedMonadicStructure.subinterval sig M (Order.succ b) u) Fin.elim0 has_max_sent := by
          simp only [has_max_sent, eval, Fin.cons]
          exact ⟨⟨u, Order.succ_le_iff.mpr hbu, le_refl u⟩, fun y => not_lt.mpr y.property.2⟩
        have h_M2_has_min : eval (OrderedMonadicStructure.subinterval sig M (Order.succ b) u) Fin.elim0 has_min_sent := by
          simp only [has_min_sent, eval, Fin.cons]
          exact ⟨⟨Order.succ b, le_refl _, Order.succ_le_iff.mpr hbu⟩, fun y => not_lt.mpr y.property.1⟩
        -- Transfer "has max/min" to Z1 and Z2 via doets_lemma_1_1
        have h_Z1_has_max := (doets_lemma_1_1 (k'' + 2) 0 has_max_sent h_depth_max _ _ Fin.elim0 Fin.elim0 h_same_nf_Z1).mp h_M_has_max
        have h_Z1_has_min := (doets_lemma_1_1 (k'' + 2) 0 has_min_sent h_depth_min _ _ Fin.elim0 Fin.elim0 h_same_nf_Z1).mp h_M_has_min
        have h_Z2_has_max := (doets_lemma_1_1 (k'' + 2) 0 has_max_sent h_depth_max _ _ Fin.elim0 Fin.elim0 h_same_nf_Z2).mp h_M2_has_max
        have h_Z2_has_min := (doets_lemma_1_1 (k'' + 2) 0 has_min_sent h_depth_min _ _ Fin.elim0 Fin.elim0 h_same_nf_Z2).mp h_M2_has_min
        -- Extract concrete max/min elements
        simp only [has_max_sent, has_min_sent, eval, Fin.cons] at h_Z1_has_max h_Z1_has_min h_Z2_has_max h_Z2_has_min
        obtain ⟨⟨z1_hi, hz1_hi⟩, h_z1_max⟩ := h_Z1_has_max
        obtain ⟨⟨z1_lo, hz1_lo⟩, h_z1_min⟩ := h_Z1_has_min
        obtain ⟨⟨z2_hi, hz2_hi⟩, h_z2_max⟩ := h_Z2_has_max
        obtain ⟨⟨z2_lo, hz2_lo⟩, h_z2_min⟩ := h_Z2_has_min
        -- Prove Z1.hi = some _, Z1.lo = some _, Z2.hi = some _, Z2.lo = some _
        have h_Z1_hi_some : ∃ v, Z1.hi = some v := by
          cases h_hi : Z1.hi with
          | some v => exact ⟨v, rfl⟩
          | none =>
            exfalso
            have h_in : Z1.lo.elim True (· ≤ z1_hi + 1) ∧ Z1.hi.elim True ((z1_hi + 1) ≤ ·) := by
              refine ⟨?_, by simp [h_hi, Option.elim]⟩
              have := hz1_hi.1; cases h_lo : Z1.lo with
              | none => simp [Option.elim]
              | some l => simp only [h_lo, Option.elim] at this ⊢; omega
            exact h_z1_max ⟨z1_hi + 1, h_in⟩ (by omega : z1_hi < z1_hi + 1)
        have h_Z1_lo_some : ∃ v, Z1.lo = some v := by
          cases h_lo : Z1.lo with
          | some v => exact ⟨v, rfl⟩
          | none =>
            exfalso
            have h_in : Z1.lo.elim True (· ≤ z1_lo - 1) ∧ Z1.hi.elim True ((z1_lo - 1) ≤ ·) := by
              refine ⟨by simp [h_lo, Option.elim], ?_⟩
              have := hz1_lo.2; cases h_hi : Z1.hi with
              | none => simp [Option.elim]
              | some h => simp only [h_hi, Option.elim] at this ⊢; omega
            exact h_z1_min ⟨z1_lo - 1, h_in⟩ (by omega : z1_lo - 1 < z1_lo)
        have h_Z2_hi_some : ∃ v, Z2.hi = some v := by
          cases h_hi : Z2.hi with
          | some v => exact ⟨v, rfl⟩
          | none =>
            exfalso
            have h_in : Z2.lo.elim True (· ≤ z2_hi + 1) ∧ Z2.hi.elim True ((z2_hi + 1) ≤ ·) := by
              refine ⟨?_, by simp [h_hi, Option.elim]⟩
              have := hz2_hi.1; cases h_lo : Z2.lo with
              | none => simp [Option.elim]
              | some l => simp only [h_lo, Option.elim] at this ⊢; omega
            exact h_z2_max ⟨z2_hi + 1, h_in⟩ (by omega : z2_hi < z2_hi + 1)
        have h_Z2_lo_some : ∃ v, Z2.lo = some v := by
          cases h_lo : Z2.lo with
          | some v => exact ⟨v, rfl⟩
          | none =>
            exfalso
            have h_in : Z2.lo.elim True (· ≤ z2_lo - 1) ∧ Z2.hi.elim True ((z2_lo - 1) ≤ ·) := by
              refine ⟨by simp [h_lo, Option.elim], ?_⟩
              have := hz2_lo.2; cases h_hi : Z2.hi with
              | none => simp [Option.elim]
              | some h => simp only [h_hi, Option.elim] at this ⊢; omega
            exact h_z2_min ⟨z2_lo - 1, h_in⟩ (by omega : z2_lo - 1 < z2_lo)
        -- Extract bounds
        obtain ⟨hi1, h_hi1⟩ := h_Z1_hi_some
        obtain ⟨lo1, h_lo1⟩ := h_Z1_lo_some
        obtain ⟨hi2, h_hi2⟩ := h_Z2_hi_some
        obtain ⟨lo2, h_lo2⟩ := h_Z2_lo_some
        -- Build Fintype for Z1.intervalCarrier and Z2.intervalCarrier
        haveI : Fintype (witnesses false).carrier := by
          show Fintype (ZIntervalStructure.toOrdered sig Z1).carrier
          show Fintype Z1.intervalCarrier
          exact Fintype.ofEquiv (Set.Icc lo1 hi1) {
            toFun := fun ⟨z, hz⟩ => ⟨z, by
              simp [ZIntervalStructure.intervalCarrier, h_lo1, h_hi1, Option.elim]
              exact Set.mem_Icc.mp hz⟩
            invFun := fun ⟨z, hz⟩ => ⟨z, by
              simp [ZIntervalStructure.intervalCarrier, h_lo1, h_hi1, Option.elim] at hz
              exact Set.mem_Icc.mpr hz⟩
            left_inv := fun ⟨z, hz⟩ => rfl
            right_inv := fun ⟨z, hz⟩ => rfl
          }
        haveI : Fintype (witnesses true).carrier := by
          show Fintype (ZIntervalStructure.toOrdered sig Z2).carrier
          show Fintype Z2.intervalCarrier
          exact Fintype.ofEquiv (Set.Icc lo2 hi2) {
            toFun := fun ⟨z, hz⟩ => ⟨z, by
              simp [ZIntervalStructure.intervalCarrier, h_lo2, h_hi2, Option.elim]
              exact Set.mem_Icc.mp hz⟩
            invFun := fun ⟨z, hz⟩ => ⟨z, by
              simp [ZIntervalStructure.intervalCarrier, h_lo2, h_hi2, Option.elim] at hz
              exact Set.mem_Icc.mpr hz⟩
            left_inv := fun ⟨z, hz⟩ => rfl
            right_inv := fun ⟨z, hz⟩ => rfl
          }
        -- Fintype for Sigma (orderedSum carrier)
        haveI : ∀ i : Bool, Fintype ((witnesses i).carrier) := by
          intro i; cases i <;> assumption
        haveI : Fintype (orderedSum sig Bool witnesses).carrier := Sigma.instFintype
        -- Apply finite_structures_good
        exact finite_structures_good sig (k'' + 2) (orderedSum sig Bool witnesses)
  -- Compose via transitivity of k_equiv (= equality of k-types)
  obtain ⟨Z3, hZ3⟩ := h_good
  exact ⟨Z3, (h_iso.trans h_sum).trans hZ3⟩

/-! ## Contemporaneous Equivalence -/

/--
Contemporaneous equivalence ~M (Reynolds 1994):
a ~M b if the subinterval between them is "very good."
-/
def contemp_equiv (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) : Prop :=
  very_good sig k (M.subinterval sig (min a b) (max a b))

/--
~M is an equivalence relation on M.carrier (Reynolds Lemma 17).

- **Reflexivity**: M.subinterval(a,a) is singleton, hence finite, hence good.
- **Symmetry**: min/max are symmetric.
- **Transitivity** (Reynolds Lemma 17): Given a ~M b and b ~M c, show [a,c] is
  very good by case analysis on subintervals. The hard case (spanning b)
  decomposes at b/succ(b) and applies doets_lemma_1_4.

Hypotheses: SuccOrder (for b/succ(b) decomposition) and NoMaxOrder (for
Order.succ_le_iff). NO IsSuccArchimedean needed.
-/
theorem contemp_equiv_is_equiv (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [NoMaxOrder M.carrier] :
    Equivalence (contemp_equiv sig k M) where
  refl a := by
    simp only [contemp_equiv, min_self, max_self]
    intro c d hcd
    haveI : Finite (M.subinterval sig a a).carrier := subinterval_singleton_finite sig M a
    haveI : Fintype (M.subinterval sig a a).carrier := Fintype.ofFinite _
    haveI : Fintype ((M.subinterval sig a a).subinterval sig c d).carrier :=
      Subtype.fintype _
    exact finite_structures_good sig k _
  symm {a b} hab := by
    simp only [contemp_equiv] at hab ⊢
    rwa [min_comm, max_comm]
  trans {a b c} hab hbc := by
    -- Reynolds Lemma 17: transitivity of ~M via ordered-sum decomposition.
    -- Strategy: any subinterval of [min a c, max a c] is either:
    --   (A) inside [min a b, max a b] -> good by hab, or
    --   (B) inside [min b c, max b c] -> good by hbc, or
    --   (C) spans b -> decompose at b/succ(b) via good_of_split_at_succ
    simp only [contemp_equiv, very_good] at *
    intro x y hxy
    have h_flatten : k_equiv sig k
        ((M.subinterval sig (min a c) (max a c)).subinterval sig x y)
        (M.subinterval sig x.val y.val) :=
      subinterval_of_subinterval_k_equiv sig k M (min a c) (max a c) x y
    suffices h_good : good sig k (M.subinterval sig x.val y.val) by
      obtain ⟨Z, hZ⟩ := h_good
      exact ⟨Z, h_flatten.trans hZ⟩
    -- Three-way case split on x.val, y.val relative to b
    rcases le_or_lt x.val b with hxb_le | hxb_lt
    · rcases le_or_lt y.val b with hyb_le | hyb_lt
      · -- Case A: both <= b. Use hab if min a b ≤ x.val, else hbc.
        rcases le_or_lt (min a b) x.val with h_in_ab | h_not_ab
        · exact good_of_very_good_subinterval sig k M (min a b) (max a b) min_le_max
            hab x.val y.val h_in_ab (le_trans hyb_le (le_max_right a b)) hxy
        · have h_in_bc : min b c ≤ x.val := by
            have hx_lt_a : x.val < a := lt_of_lt_of_le h_not_ab (min_le_left a b)
            have hx_lo : min a c ≤ x.val := x.property.1
            rcases le_or_lt a c with hac | hca
            · exact absurd hx_lt_a (not_lt.mpr (by simp [min_eq_left hac] at hx_lo; exact hx_lo))
            · have hc_le_x : c ≤ x.val := by
                simp [min_eq_right (le_of_lt hca)] at hx_lo; exact hx_lo
              exact le_trans (min_le_right b c) hc_le_x
          exact good_of_very_good_subinterval sig k M (min b c) (max b c) min_le_max
            hbc x.val y.val h_in_bc (le_trans hyb_le (le_max_left b c)) hxy
      · -- Case C: x.val <= b < y.val (spans b).
        -- Decompose via good_of_split_at_succ.
        have h_left : good sig k (M.subinterval sig x.val b) := by
          rcases le_or_lt (min a b) x.val with h | h
          · exact good_of_very_good_subinterval sig k M (min a b) (max a b) min_le_max
              hab x.val b h (le_max_right a b) hxb_le
          · have h_in_bc : min b c ≤ x.val := by
              have hx_lt_a : x.val < a := lt_of_lt_of_le h (min_le_left a b)
              have hx_lo : min a c ≤ x.val := x.property.1
              rcases le_or_lt a c with hac | hca
              · exact absurd hx_lt_a (not_lt.mpr (by simp [min_eq_left hac] at hx_lo; exact hx_lo))
              · have hc_le_x : c ≤ x.val := by
                  simp [min_eq_right (le_of_lt hca)] at hx_lo; exact hx_lo
                exact le_trans (min_le_right b c) hc_le_x
            exact good_of_very_good_subinterval sig k M (min b c) (max b c) min_le_max
              hbc x.val b h_in_bc (le_max_left b c) hxb_le
        have h_right : good sig k (M.subinterval sig (Order.succ b) y.val) := by
          have hsucc_le_y : Order.succ b ≤ y.val := Order.succ_le_iff.mpr hyb_lt
          rcases le_or_lt y.val (max b c) with h | h
          · exact good_of_very_good_subinterval sig k M (min b c) (max b c) min_le_max
              hbc (Order.succ b) y.val (le_trans (min_le_left b c) (Order.le_succ b)) h hsucc_le_y
          · have hy_le_a : y.val ≤ a := by
              have h1 : y.val ≤ max a c := y.property.2
              have h2 : c < y.val := lt_of_le_of_lt (le_max_right b c) h
              rcases le_or_lt a c with hac | hca
              · exact absurd h2 (not_lt.mpr (le_trans h1 (by simp [max_eq_right hac])))
              · exact le_trans h1 (le_of_eq (max_eq_left (le_of_lt hca)))
            exact good_of_very_good_subinterval sig k M (min a b) (max a b) min_le_max
              hab (Order.succ b) y.val (le_trans (min_le_right a b) (Order.le_succ b))
              (le_trans hy_le_a (le_max_left a b)) hsucc_le_y
        exact good_of_split_at_succ sig k M x.val b y.val hxb_le hyb_lt h_left h_right
    · -- Case B: x.val > b (so y.val > b too). Use hbc if y ≤ max b c, else hab.
      rcases le_or_lt y.val (max b c) with hybc | hybc
      · exact good_of_very_good_subinterval sig k M (min b c) (max b c) min_le_max
          hbc x.val y.val (le_trans (min_le_left b c) (le_of_lt hxb_lt)) hybc hxy
      · have hy_le_a : y.val ≤ a := by
          have h1 : y.val ≤ max a c := y.property.2
          have h2 : c < y.val := lt_of_le_of_lt (le_max_right b c) hybc
          rcases le_or_lt a c with hac | hca
          · exact absurd h2 (not_lt.mpr (le_trans h1 (by simp [max_eq_right hac])))
          · exact le_trans h1 (le_of_eq (max_eq_left (le_of_lt hca)))
        exact good_of_very_good_subinterval sig k M (min a b) (max a b) min_le_max
          hab x.val y.val (le_trans (min_le_right a b) (le_of_lt hxb_lt))
          (le_trans hy_le_a (le_max_left a b)) hxy

/-! ## No Gaps in Discrete Orders -/

/--
NO GAPS THEOREM (Reynolds 1994, Theorem 14 + Lemmas 6-13):

In a discrete linear order without endpoints satisfying the Prior-UZ and
Prior-SZ axioms semantically, the contemporaneous equivalence relation ~M
has no equivalence classes that "end at gaps."

More precisely: for any two points a b : M.carrier, if a is NOT ~M-equivalent
to b, then the proof is by contradiction -- there exists a boundary c where
a ~M c but NOT a ~M (succ c). This contradicts no_boundary_at_successor
(c ~M succ c always) combined with transitivity.

**Reynolds proof strategy** (Section 7, Lemmas 6-13, Theorem 14):
1. Define rho(x) = "x's ~M-class ends in a gap on the right."
   By US expressive completeness over Prior structures (Reynolds Theorem 5 =
   GHR94 Theorem 9.3.1 specialized to Prior structures), there is a temporal
   formula R that holds exactly where rho holds.
2. (Lemmas 7-8) R-intervals are open intervals with bounded excluded endpoints.
3. (Lemma 9) ~M-classes in R-intervals are elementarily equivalent.
4. (Lemmas 10-13) Model surgery: replace a bad interval by one ~M-class.
   Temporal truth is preserved (induction on formula structure).
   The surgery model contradicts R holding in the chosen class.

**BLOCKED**: Reynolds Theorem 5 (US expressive completeness over Prior structures
in general) is not yet formalized. Our `US_expressively_complete_over_Z` covers
only structures whose carrier IS ℤ, not general Prior structures.
Resolution: formalize Reynolds Theorem 5 by showing U'(A,B) ≡ ⊥ and S'(A,B) ≡ ⊥
in any Prior structure (via Prior-U/S), then applying GHR94 Theorem 9.3.1.

**Semantic Prior validity hypotheses**:
- `atomMap`: atom map for M (encodes the contemporaneous equivalence via k-types)
- `h_prior_UZ`: if F(ψ) at t then U(ψ,¬ψ) at t (semantically: first-occurrence property)
- `h_prior_SZ`: if P(ψ) at t then S(ψ,¬ψ) at t (semantically: last-occurrence property)
-/
theorem no_gaps_discrete (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : ∀ (t : M.carrier) (ψ : Formula),
      (∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ) →
      ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ ∧
        ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r ψ.neg)
    (h_prior_SZ : ∀ (t : M.carrier) (ψ : Formula),
      (∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ) →
      ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ ∧
        ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r ψ.neg)
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  -- BLOCKED: Requires Reynolds Theorem 5 (US expressive completeness over
  -- Prior structures in general), which is not yet formalized. The proof
  -- would: (1) define rho via k-type characterization, (2) apply Theorem 5
  -- to get temporal formula R, (3) derive structural properties via h_prior_UZ
  -- and h_prior_SZ (Lemmas 7-8), (4) show model surgery preserves temporal
  -- truth (Lemma 12), (5) derive contradiction from R holding in surgery model.
  sorry

/--
~M class boundaries cannot fall at successor pairs: for any point c,
c ~M succ(c). The subinterval [c, succ(c)] has exactly two elements,
hence is finite, hence every subinterval of it is finite and good.
-/
theorem no_boundary_at_successor (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier]
    (c : M.carrier) :
    contemp_equiv sig k M c (Order.succ c) := by
  simp only [contemp_equiv]
  have hle : c ≤ Order.succ c := Order.le_succ c
  rw [min_eq_left hle, max_eq_right hle]
  intro a b hab
  haveI : Finite (M.subinterval sig c (Order.succ c)).carrier :=
    subinterval_two_element_finite sig M c
  haveI : Fintype (M.subinterval sig c (Order.succ c)).carrier :=
    Fintype.ofFinite _
  haveI : Fintype ((M.subinterval sig c (Order.succ c)).subinterval sig a b).carrier :=
    Subtype.fintype _
  exact finite_structures_good sig k _

/-! ## One-Class Theorem -/

/--
ONE-CLASS THEOREM (Reynolds, Theorem 15 discrete case):
All points are contemporaneously equivalent in any discrete Prior structure
without endpoints.

The proof follows Reynolds 1994 Section 8 (page 131):
1. Suppose ¬(a ~M b) for some a, b.
2. By `no_gaps_discrete`, ∃c: a ~M c ∧ ¬(a ~M succ c).
3. By `no_boundary_at_successor`: c ~M succ(c).
4. By transitivity of ~M: a ~M succ(c). Contradicts step 2.

NO `IsSuccArchimedean` needed. The proof uses only:
- `no_gaps_discrete` (Reynolds Theorem 14, currently sorry'd pending Theorem 5 formalization)
- `no_boundary_at_successor` (sorry-free)
- `contemp_equiv_is_equiv` (sorry-free, no IsSuccArchimedean)
-/
theorem one_class (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula → sig.preds)
    (h_prior_UZ : ∀ (t : M.carrier) (ψ : Formula),
      (∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ) →
      ∃ s : M.carrier, t < s ∧ temporal_truth M atomMap s ψ ∧
        ∀ r : M.carrier, t < r → r < s → temporal_truth M atomMap r ψ.neg)
    (h_prior_SZ : ∀ (t : M.carrier) (ψ : Formula),
      (∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ) →
      ∃ s : M.carrier, s < t ∧ temporal_truth M atomMap s ψ ∧
        ∀ r : M.carrier, s < r → r < t → temporal_truth M atomMap r ψ.neg) :
    ∀ (a b : M.carrier), contemp_equiv sig k M a b := by
  intro a b
  by_contra h_diff
  -- By no_gaps_discrete: ∃c with a ~M c but ¬(a ~M succ c)
  obtain ⟨c, hac, h_not_succ⟩ := no_gaps_discrete sig k M atomMap h_prior_UZ h_prior_SZ a b h_diff
  -- By no_boundary_at_successor: c ~M succ(c)
  have hc_succ : contemp_equiv sig k M c (Order.succ c) :=
    no_boundary_at_successor sig k M c
  -- By transitivity of ~M: a ~M succ(c). Contradiction.
  have hac_succ : contemp_equiv sig k M a (Order.succ c) :=
    (contemp_equiv_is_equiv sig k M).trans hac hc_succ
  exact h_not_succ hac_succ

/-! ## Very Good → Good (Reynolds Lemma 16) -/

/--
Helper: Choose Z-interval witnesses for a family of good structures.
-/
private noncomputable def choose_good_witness (sig : MonadicSignature) (k : Nat)
    (ms : ℤ → OrderedMonadicStructure sig) (h : ∀ i, good sig k (ms i)) :
    (i : ℤ) → ZIntervalStructure sig :=
  fun i => (h i).choose

private theorem choose_good_witness_spec (sig : MonadicSignature) (k : Nat)
    (ms : ℤ → OrderedMonadicStructure sig) (h : ∀ i, good sig k (ms i)) :
    ∀ i, k_equiv sig k (ms i) ((choose_good_witness sig k ms h i).toOrdered sig) :=
  fun i => (h i).choose_spec

/-- Positive half of cofinal sequence: strictly increasing, above all enumerated elements. -/
private noncomputable def cofinal_pos_seq {α : Type} [LinearOrder α] [NoMaxOrder α]
    (enum : ℕ → α) : ℕ → α :=
  Nat.rec (enum 0) (fun n prev => (exists_gt (max prev (enum n))).choose)

/-- Negative half of cofinal sequence: strictly decreasing, below all enumerated elements. -/
private noncomputable def cofinal_neg_seq {α : Type} [LinearOrder α] [NoMinOrder α]
    (start : α) (enum : ℕ → α) : ℕ → α :=
  Nat.rec (exists_lt (min start (enum 0))).choose
    (fun n prev => (exists_lt (min prev (enum (n + 1)))).choose)

/-- Combined cofinal sequence: positive indices use pos_seq, negative use neg_seq. -/
private noncomputable def mk_cofinal_seq {α : Type} [LinearOrder α]
    [NoMaxOrder α] [NoMinOrder α] (enum : ℕ → α) : ℤ → α := fun i =>
  if i ≥ 0 then cofinal_pos_seq enum i.toNat
  else cofinal_neg_seq (enum 0) enum (-i - 1).toNat

private theorem cofinal_pos_seq_lt_succ {α : Type} [LinearOrder α] [NoMaxOrder α]
    (enum : ℕ → α) (n : ℕ) : cofinal_pos_seq enum n < cofinal_pos_seq enum (n + 1) := by
  show cofinal_pos_seq enum n < (exists_gt (max (cofinal_pos_seq enum n) (enum n))).choose
  exact lt_of_le_of_lt (le_max_left _ _)
    (exists_gt (max (cofinal_pos_seq enum n) (enum n))).choose_spec

private theorem cofinal_pos_seq_above_enum {α : Type} [LinearOrder α] [NoMaxOrder α]
    (enum : ℕ → α) (m : ℕ) : enum m < cofinal_pos_seq enum (m + 1) := by
  show enum m < (exists_gt (max (cofinal_pos_seq enum m) (enum m))).choose
  exact lt_of_le_of_lt (le_max_right _ _)
    (exists_gt (max (cofinal_pos_seq enum m) (enum m))).choose_spec

private theorem cofinal_neg_seq_succ_lt {α : Type} [LinearOrder α] [NoMinOrder α]
    (start : α) (enum : ℕ → α) (n : ℕ) :
    cofinal_neg_seq start enum (n + 1) < cofinal_neg_seq start enum n := by
  show (exists_lt (min (cofinal_neg_seq start enum n) (enum (n + 1)))).choose <
    cofinal_neg_seq start enum n
  exact lt_of_lt_of_le
    (exists_lt (min (cofinal_neg_seq start enum n) (enum (n + 1)))).choose_spec
    (min_le_left _ _)

private theorem cofinal_neg_seq_below_enum {α : Type} [LinearOrder α] [NoMinOrder α]
    (start : α) (enum : ℕ → α) (m : ℕ) :
    cofinal_neg_seq start enum m < enum m := by
  induction m with
  | zero =>
    show (exists_lt (min start (enum 0))).choose < enum 0
    exact lt_of_lt_of_le (exists_lt (min start (enum 0))).choose_spec (min_le_right _ _)
  | succ n _ =>
    show (exists_lt (min (cofinal_neg_seq start enum n) (enum (n + 1)))).choose < enum (n + 1)
    exact lt_of_lt_of_le
      (exists_lt (min (cofinal_neg_seq start enum n) (enum (n + 1)))).choose_spec
      (min_le_right _ _)

private theorem cofinal_neg_seq_below_start {α : Type} [LinearOrder α] [NoMinOrder α]
    (start : α) (enum : ℕ → α) : cofinal_neg_seq start enum 0 < start := by
  show (exists_lt (min start (enum 0))).choose < start
  exact lt_of_lt_of_le (exists_lt (min start (enum 0))).choose_spec (min_le_left _ _)

/-- Helper: find the last index in a finite range where the sequence is ≤ x. -/
private theorem find_last_index_below {α : Type} [LinearOrder α] (a : ℤ → α)
    (h_mono : StrictMono a) (x : α) (lo hi : ℤ) (h_lo : a lo ≤ x) (h_hi : x < a hi) :
    ∃ i : ℤ, lo ≤ i ∧ a i ≤ x ∧ x < a (i + 1) := by
  classical
  have h_lt : lo < hi := by
    by_contra h; push_neg at h
    exact absurd (lt_of_lt_of_le h_hi (h_mono.monotone h)) (not_lt.mpr h_lo)
  let S := (Finset.Icc lo (hi - 1)).filter (fun i => decide (a i ≤ x) = true)
  have hS_ne : S.Nonempty :=
    ⟨lo, Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨le_refl _, by omega⟩, by simp [h_lo]⟩⟩
  let j := S.max' hS_ne
  have hj_mem : j ∈ S := Finset.max'_mem S hS_ne
  have hj_le_x : a j ≤ x := by
    have := (Finset.mem_filter.mp hj_mem).2; simp at this; exact this
  have hj_lo : lo ≤ j := (Finset.mem_Icc.mp (Finset.mem_filter.mp hj_mem).1).1
  have hj_hi : j ≤ hi - 1 := (Finset.mem_Icc.mp (Finset.mem_filter.mp hj_mem).1).2
  have hj_next : x < a (j + 1) := by
    by_contra h_not_lt; push_neg at h_not_lt
    rcases le_or_gt (j + 1) (hi - 1) with h1 | h2
    · have hj1_in : j + 1 ∈ S := Finset.mem_filter.mpr
        ⟨Finset.mem_Icc.mpr ⟨by omega, h1⟩, by simp [h_not_lt]⟩
      exact absurd (Finset.le_max' S (j + 1) hj1_in) (by omega)
    · exact absurd (lt_of_lt_of_le h_hi ((show j + 1 = hi from by omega) ▸ h_not_lt))
        (lt_irrefl x)
  exact ⟨j, hj_lo, hj_le_x, hj_next⟩

/--
In a countable linear order without endpoints, there exists a strictly increasing
cofinal sequence indexed by ℤ.

Given Countable α + NoMaxOrder + NoMinOrder + Nonempty, we construct a : ℤ → α
that is strictly monotone and cofinal: for every x, there exists i with
a(i) ≤ x ≤ a(i+1).

Construction: Enumerate all elements via Countable. Build positive/negative halves
using NoMaxOrder/NoMinOrder to extend beyond each enumerated element. Combine into
a bi-infinite sequence and prove cofinality via the find-last-index argument on
finite ℤ-intervals.
-/
private theorem exists_cofinal_sequence {α : Type} [LinearOrder α] [Countable α]
    [NoMaxOrder α] [NoMinOrder α] [Nonempty α] :
    ∃ (a : ℤ → α), StrictMono a ∧ ∀ x : α, ∃ i : ℤ, a i ≤ x ∧ x ≤ a (i + 1) := by
  classical
  haveI : Infinite α := NoMaxOrder.infinite
  haveI : Encodable α := (nonempty_encodable α).some
  haveI : Inhabited α := Classical.inhabited_of_nonempty inferInstance
  let enum : ℕ → α := fun n => (Encodable.decode (α := α) n).iget
  have h_surj : Function.Surjective enum := Encodable.surjective_decode_iget α
  let a := mk_cofinal_seq enum
  refine ⟨a, ?_, ?_⟩
  · -- StrictMono: prove a(i) < a(i+1) for all i, then use strictMono_int_of_lt_succ
    apply strictMono_int_of_lt_succ
    intro i
    simp only [a, mk_cofinal_seq]
    by_cases h0 : i ≥ 0
    · -- i ≥ 0: both i and i+1 use cofinal_pos_seq
      have h1 : i + 1 ≥ 0 := by omega
      simp only [show (i ≥ 0) = True from eq_true h0, show (i + 1 ≥ 0) = True from eq_true h1,
        ↓reduceDIte]
      have h_eq : (i + 1).toNat = i.toNat + 1 := by omega
      rw [h_eq]
      exact cofinal_pos_seq_lt_succ enum i.toNat
    · by_cases h1 : i + 1 ≥ 0
      · -- i = -1: transition from neg to pos
        have hi_eq : i = -1 := by omega
        simp only [show ¬(i ≥ 0) from h0, show (i + 1 ≥ 0) = True from eq_true h1,
          ↓reduceDIte]
        have h_tonat1 : (i + 1).toNat = 0 := by omega
        have h_tonat2 : (-i - 1).toNat = 0 := by omega
        rw [h_tonat1, h_tonat2]
        -- Need: cofinal_neg_seq (enum 0) enum 0 < cofinal_pos_seq enum 0
        -- cofinal_pos_seq enum 0 = enum 0
        -- cofinal_neg_seq (enum 0) enum 0 < enum 0
        show cofinal_neg_seq (enum 0) enum 0 < cofinal_pos_seq enum 0
        exact cofinal_neg_seq_below_start (enum 0) enum
      · -- i ≤ -2: both use cofinal_neg_seq, strict anti gives the result
        simp only [show ¬(i ≥ 0) from h0, show ¬(i + 1 ≥ 0) from h1, ↓reduceDIte]
        have h_eq : (-i - 1).toNat = (-(i + 1) - 1).toNat + 1 := by omega
        rw [h_eq]
        exact cofinal_neg_seq_succ_lt (enum 0) enum (-(i + 1) - 1).toNat
  · -- Cofinality: for any x, there exists i with a(i) ≤ x ≤ a(i+1)
    intro x
    obtain ⟨m, hm⟩ := h_surj x
    -- x = enum(m). We have:
    -- a(m+1) = cofinal_pos_seq enum (m+1) > enum(m) = x  (from cofinal_pos_seq_above_enum)
    -- a(-(m+1)) = cofinal_neg_seq (enum 0) enum m < enum(m) = x (from cofinal_neg_seq_below_enum)
    have h_above : x < a (↑(m + 1)) := by
      rw [← hm]
      simp only [a, mk_cofinal_seq, show (↑(m + 1) : ℤ) ≥ 0 from by omega, ↓reduceDIte,
        show (↑(m + 1) : ℤ).toNat = m + 1 from by omega]
      exact cofinal_pos_seq_above_enum enum m
    have h_below : a (-(↑m + 1)) ≤ x := by
      rw [← hm]
      simp only [a, mk_cofinal_seq, show ¬((-(↑m + 1) : ℤ) ≥ 0) from by omega, ↓reduceDIte,
        show (-(-(↑m + 1) : ℤ) - 1).toNat = m from by omega]
      exact le_of_lt (cofinal_neg_seq_below_enum (enum 0) enum m)
    -- Apply find_last_index_below on the finite interval [-(m+1), m+1]
    obtain ⟨i, _, hi_le, hi_next⟩ :=
      find_last_index_below a (strictMono_int_of_lt_succ (fun j => by
        simp only [a, mk_cofinal_seq]
        by_cases h0 : j ≥ 0
        · have h1 : j + 1 ≥ 0 := by omega
          simp only [show (j ≥ 0) = True from eq_true h0, show (j + 1 ≥ 0) = True from eq_true h1,
            ↓reduceDIte]
          have h_eq : (j + 1).toNat = j.toNat + 1 := by omega
          rw [h_eq]; exact cofinal_pos_seq_lt_succ enum j.toNat
        · by_cases h1 : j + 1 ≥ 0
          · simp only [show ¬(j ≥ 0) from h0, show (j + 1 ≥ 0) = True from eq_true h1, ↓reduceDIte]
            have h_tonat1 : (j + 1).toNat = 0 := by omega
            have h_tonat2 : (-j - 1).toNat = 0 := by omega
            rw [h_tonat1, h_tonat2]
            exact cofinal_neg_seq_below_start (enum 0) enum
          · simp only [show ¬(j ≥ 0) from h0, show ¬(j + 1 ≥ 0) from h1, ↓reduceDIte]
            have h_eq : (-j - 1).toNat = (-(j + 1) - 1).toNat + 1 := by omega
            rw [h_eq]; exact cofinal_neg_seq_succ_lt (enum 0) enum (-(j + 1) - 1).toNat))
        x (-(↑m + 1)) (↑(m + 1)) h_below h_above
    exact ⟨i, hi_le, le_of_lt hi_next⟩

/-! ### Half-Open Partition Pieces -/

/--
Half-open subinterval [a, b) of an ordered monadic structure.
The carrier is `{x : M.carrier // a ≤ x ∧ x < b}`.
-/
def OrderedMonadicStructure.hoSubinterval (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a ≤ x ∧ x < b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance

/--
Uniqueness of the partition index: each x belongs to exactly one half-open piece [a(i), a(i+1)).
-/
private theorem partition_index_unique {α : Type} [LinearOrder α] (a : ℤ → α)
    (h_mono : StrictMono a) {x : α} {i j : ℤ}
    (hi : a i ≤ x ∧ x < a (i + 1)) (hj : a j ≤ x ∧ x < a (j + 1)) : i = j := by
  by_contra h
  rcases Ne.lt_or_lt h with h_lt | h_lt
  · -- i < j, so i + 1 ≤ j, hence a(i+1) ≤ a(j) ≤ x < a(i+1)
    have h1 : a (i + 1) ≤ a j := h_mono.monotone (Int.add_one_le_iff.mpr h_lt)
    exact absurd (lt_of_lt_of_le hi.2 (le_trans h1 hj.1)) (lt_irrefl x)
  · -- j < i, symmetric
    have h1 : a (j + 1) ≤ a i := h_mono.monotone (Int.add_one_le_iff.mpr h_lt)
    exact absurd (lt_of_lt_of_le hj.2 (le_trans h1 hi.1)) (lt_irrefl x)

/--
M is k-equivalent to the ordered sum of its half-open partition pieces along a cofinal sequence.

Given a strictly increasing cofinal sequence a : ℤ → M.carrier where every x lies in
some half-open interval [a(i), a(i+1)), M is order-isomorphic to the ordered sum
of the partition pieces, hence k-equivalent.

The half-open pieces [a(i), a(i+1)) form a DISJOINT partition of M (unlike the
closed subintervals [a(i), a(i+1)] which overlap at boundary points). The proof
constructs an explicit OrderIso and applies k_equiv_of_iso.

This is the corrected formulation of Reynolds's "cofinal decomposition" (Lemma 16).
The original closed-interval formulation is false: the ordered sum of closed intervals
has strictly more elements than M (duplicate boundary points), making the structures
non-isomorphic and non-k-equivalent in general.
-/
private theorem cofinal_decomposition_k_equiv (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) (a : ℤ → M.carrier)
    (h_mono : StrictMono a)
    (h_cofinal : ∀ x : M.carrier, ∃ i : ℤ, a i ≤ x ∧ x < a (i + 1)) :
    k_equiv sig k M (orderedSum sig ℤ
      (fun i => M.hoSubinterval sig (a i) (a (i + 1)))) := by
  -- Step 1: Construct the forward map M → orderedSum
  have h_index : ∀ x : M.carrier, ∃ i : ℤ, a i ≤ x ∧ x < a (i + 1) := h_cofinal
  -- Use Exists.choose to pick the unique partition index for each x
  let idx : M.carrier → ℤ := fun x => (h_index x).choose
  have h_idx_spec : ∀ x, a (idx x) ≤ x ∧ x < a (idx x + 1) := fun x => (h_index x).choose_spec
  -- Forward map: x ↦ ⟨idx(x), ⟨x, proof⟩⟩
  let fwd : M.carrier → (orderedSum sig ℤ (fun i => M.hoSubinterval sig (a i) (a (i + 1)))).carrier :=
    fun x => ⟨idx x, ⟨x, h_idx_spec x⟩⟩
  -- Backward map: ⟨i, ⟨x, _⟩⟩ ↦ x
  let bwd : (orderedSum sig ℤ (fun i => M.hoSubinterval sig (a i) (a (i + 1)))).carrier → M.carrier :=
    fun s => s.2.val
  -- Step 2: Show these form an Equiv
  have h_left_inv : ∀ x, bwd (fwd x) = x := fun _ => rfl
  have h_right_inv : ∀ s, fwd (bwd s) = s := by
    intro ⟨i, ⟨x, hx⟩⟩
    show (⟨idx x, ⟨x, h_idx_spec x⟩⟩ : Sigma fun i => (M.hoSubinterval sig (a i) (a (i + 1))).carrier) = ⟨i, ⟨x, hx⟩⟩
    have h_idx_eq : idx x = i := partition_index_unique a h_mono (h_idx_spec x) hx
    exact Sigma.ext h_idx_eq (by subst h_idx_eq; rfl)
  let e : M.carrier ≃ (orderedSum sig ℤ (fun i => M.hoSubinterval sig (a i) (a (i + 1)))).carrier :=
    { toFun := fwd, invFun := bwd, left_inv := h_left_inv, right_inv := h_right_inv }
  -- Step 3: Show e is monotone (both directions), yielding an OrderIso.
  let S := orderedSum sig ℤ (fun i => M.hoSubinterval sig (a i) (a (i + 1)))
  -- Step 3: Prove inverse monotone first (clean because destructuring gives simple vars)
  have h_inv_mono : Monotone e.symm := by
    intro s1 s2 h12
    show bwd s1 ≤ bwd s2
    obtain ⟨i, ⟨x, hx⟩⟩ := s1
    obtain ⟨j, ⟨y, hy⟩⟩ := s2
    show x ≤ y
    rcases Sigma.Lex.le_def.mp h12 with h_lt_idx | ⟨h_eq_idx, h_le_snd⟩
    · -- i < j: x < a(i+1) ≤ a(j) ≤ y
      exact le_of_lt (lt_of_lt_of_le hx.2
        (le_trans (h_mono.monotone (Int.add_one_le_iff.mpr h_lt_idx)) hy.1))
    · -- i = j: extract x ≤ y from the subtype ordering
      cases h_eq_idx; exact h_le_snd
  -- Forward monotone: derived from inverse monotone + bijectivity.
  -- If x ≤ y and e y < e x, then y = e.symm(e y) ≤ e.symm(e x) = x, so x = y,
  -- contradicting e y < e x.
  have h_fwd_mono : Monotone e := by
    intro x y hxy
    rw [not_lt.symm]
    intro h_abs
    have h1 : e.symm (e y) ≤ e.symm (e x) := h_inv_mono (le_of_lt h_abs)
    simp only [Equiv.symm_apply_apply] at h1
    exact absurd (le_antisymm hxy h1 ▸ h_abs) (lt_irrefl _)
  let f : M.carrier ≃o S.carrier := Equiv.toOrderIso e h_fwd_mono h_inv_mono
  -- Step 4: Apply k_equiv_of_iso
  exact k_equiv_of_iso sig k M _ f (fun p x => Iff.rfl)

/-! ### Shift-and-Glue Helpers -/

/--
Cumulative offset for ℤ-indexed bounded integer intervals.
For non-negative indices, sums sizes from 0 to i-1.
For negative indices, negates the sum of sizes from i to -1.
-/
private noncomputable def cumulativeOffset (sz : ℤ → ℕ) : ℤ → ℤ :=
  fun i =>
    if h : i ≥ 0 then
      Finset.sum (Finset.Ico 0 i) (fun j => (sz j : ℤ))
    else
      -(Finset.sum (Finset.Ico i 0) (fun j => (sz j : ℤ)))

private theorem cumulativeOffset_zero (sz : ℤ → ℕ) : cumulativeOffset sz 0 = 0 := by
  simp [cumulativeOffset]

private theorem cumulativeOffset_step (sz : ℤ → ℕ) (i : ℤ) :
    cumulativeOffset sz (i + 1) = cumulativeOffset sz i + ↑(sz i) := by
  simp only [cumulativeOffset]
  by_cases h0 : i ≥ 0
  · have h1 : i + 1 ≥ 0 := by omega
    simp only [show (i ≥ 0) = True from eq_true h0, show (i + 1 ≥ 0) = True from eq_true h1,
      ↓reduceDIte]
    rw [show Finset.Ico 0 (i + 1) = (Finset.Ico 0 i) ∪ {i} from by
      ext j; simp [Finset.mem_Ico]; omega]
    rw [Finset.sum_union (by
      rw [Finset.disjoint_singleton_right]; simp [Finset.mem_Ico])]
    simp
  · push_neg at h0
    by_cases h1 : i + 1 ≥ 0
    · have hi_eq : i = -1 := by omega
      subst hi_eq
      simp only [show ¬((-1 : ℤ) ≥ 0) from by omega, show ((-1 : ℤ) + 1 ≥ 0) from by omega,
        ↓reduceDIte, show Finset.Ico (0 : ℤ) 0 = ∅ from Finset.Ico_self 0,
        Finset.sum_empty, show Finset.Ico (-1 : ℤ) 0 = {-1} from by
          ext j; simp [Finset.mem_Ico]; omega]
      simp
    · have hi_neg : ¬(i ≥ 0) := by omega
      have hi1_neg : ¬(i + 1 ≥ 0) := by omega
      simp only [show (i ≥ 0) = False from eq_false hi_neg,
        show (i + 1 ≥ 0) = False from eq_false hi1_neg, ↓reduceDIte]
      rw [show Finset.Ico i 0 = {i} ∪ Finset.Ico (i + 1) 0 from by
        ext j; simp [Finset.mem_Ico]; omega]
      rw [Finset.sum_union (by
        rw [Finset.disjoint_singleton_left]; simp [Finset.mem_Ico])]
      simp only [Finset.sum_singleton]; ring

private theorem cumulativeOffset_strictMono (sz : ℤ → ℕ) (h_pos : ∀ i, 0 < sz i) :
    StrictMono (cumulativeOffset sz) := by
  apply strictMono_int_of_lt_succ
  intro i
  rw [cumulativeOffset_step]
  linarith [Int.natCast_pos.mpr (h_pos i)]

/--
Transfer "has max/min" from source structures to Z-interval witnesses.
Given `ms i` has max and min, and `ms i ~_{k+2} (witnesses i).toOrdered sig`,
the witnesses also have `lo = some _` and `hi = some _`.
-/
private theorem witness_bounded (sig : MonadicSignature) (k'' : ℕ)
    (ms : ℤ → OrderedMonadicStructure sig)
    (h_good : ∀ i : ℤ, good sig (k'' + 2) (ms i))
    (h_has_max : ∀ i : ℤ, ∃ m : (ms i).carrier, ∀ x, x ≤ m)
    (h_has_min : ∀ i : ℤ, ∃ m : (ms i).carrier, ∀ x, m ≤ x)
    (i : ℤ) :
    (∃ v, (choose_good_witness sig (k'' + 2) ms h_good i).hi = some v) ∧
    (∃ v, (choose_good_witness sig (k'' + 2) ms h_good i).lo = some v) := by
  let witnesses := choose_good_witness sig (k'' + 2) ms h_good
  have h_equiv := choose_good_witness_spec sig (k'' + 2) ms h_good
  -- Bridge k_equiv to nf_eval_nf iff
  have h_same_nf : ∀ nf : NormalForm sig (k'' + 2) 0,
      nf_eval_nf (ms i) (k'' + 2) 0 Fin.elim0 nf ↔
      nf_eval_nf ((witnesses i).toOrdered sig) (k'' + 2) 0 Fin.elim0 nf := by
    intro nf; have h := congr_fun (h_equiv i) nf; simp [k_type_of] at h; exact_mod_cast h
  -- Define "has max" and "has min" sentences
  let has_max_sent : MonadicSentence sig := .ex (.all (.not (.lt 1 0)))
  let has_min_sent : MonadicSentence sig := .ex (.all (.not (.lt 0 1)))
  have h_depth_max : has_max_sent.quantifier_depth ≤ k'' + 2 := by
    simp [has_max_sent, MonadicFormula.quantifier_depth]
  have h_depth_min : has_min_sent.quantifier_depth ≤ k'' + 2 := by
    simp [has_min_sent, MonadicFormula.quantifier_depth]
  -- ms(i) has max and min
  obtain ⟨mx, h_mx⟩ := h_has_max i
  obtain ⟨mn, h_mn⟩ := h_has_min i
  have h_M_has_max : eval (ms i) Fin.elim0 has_max_sent := by
    simp only [has_max_sent, eval, Fin.cons]; exact ⟨mx, fun y => not_lt.mpr (h_mx y)⟩
  have h_M_has_min : eval (ms i) Fin.elim0 has_min_sent := by
    simp only [has_min_sent, eval, Fin.cons]; exact ⟨mn, fun y => not_lt.mpr (h_mn y)⟩
  -- Transfer to witnesses
  have h_W_has_max := (doets_lemma_1_1 (k'' + 2) 0 has_max_sent h_depth_max _ _ Fin.elim0 Fin.elim0 h_same_nf).mp h_M_has_max
  have h_W_has_min := (doets_lemma_1_1 (k'' + 2) 0 has_min_sent h_depth_min _ _ Fin.elim0 Fin.elim0 h_same_nf).mp h_M_has_min
  simp only [has_max_sent, has_min_sent, eval, Fin.cons] at h_W_has_max h_W_has_min
  obtain ⟨⟨z_hi, hz_hi⟩, h_max⟩ := h_W_has_max
  obtain ⟨⟨z_lo, hz_lo⟩, h_min⟩ := h_W_has_min
  constructor
  · -- hi = some _
    cases h_hi : (witnesses i).hi with
    | some v => exact ⟨v, rfl⟩
    | none =>
      exfalso
      have h_in : (witnesses i).lo.elim True (· ≤ z_hi + 1) ∧
          (witnesses i).hi.elim True ((z_hi + 1) ≤ ·) := by
        refine ⟨?_, by simp [h_hi, Option.elim]⟩
        have := hz_hi.1; cases h_lo : (witnesses i).lo with
        | none => simp [Option.elim]
        | some l => simp only [h_lo, Option.elim] at this ⊢; omega
      exact h_max ⟨z_hi + 1, h_in⟩ (by omega : z_hi < z_hi + 1)
  · -- lo = some _
    cases h_lo : (witnesses i).lo with
    | some v => exact ⟨v, rfl⟩
    | none =>
      exfalso
      have h_in : (witnesses i).lo.elim True (· ≤ z_lo - 1) ∧
          (witnesses i).hi.elim True ((z_lo - 1) ≤ ·) := by
        refine ⟨by simp [h_lo, Option.elim], ?_⟩
        have := hz_lo.2; cases h_hi : (witnesses i).hi with
        | none => simp [Option.elim]
        | some h => simp only [h_hi, Option.elim] at this ⊢; omega
      exact h_min ⟨z_lo - 1, h_in⟩ (by omega : z_lo - 1 < z_lo)

/--
Every integer lies in exactly one piece `[c(i), c(i+1))` of the cumulative offset.
-/
private theorem cumulativeOffset_covers (sz : ℤ → ℕ) (h_pos : ∀ i, 0 < sz i)
    (n : ℤ) : ∃ i : ℤ, cumulativeOffset sz i ≤ n ∧ n < cumulativeOffset sz (i + 1) := by
  have h_mono := cumulativeOffset_strictMono sz h_pos
  -- c(0) = 0. We handle the two halves: n ≥ 0 and n < 0.
  -- For any direction, since c is strictly increasing and unbounded, n must lie in some interval.
  -- We use the fact that c grows by at least 1 at each step.
  have h_step_pos : ∀ j, cumulativeOffset sz j < cumulativeOffset sz (j + 1) := by
    intro j; rw [cumulativeOffset_step]; linarith [Int.natCast_pos.mpr (h_pos j)]
  -- Find lower bound: some i₀ with c(i₀) ≤ n
  have h_exists_lo : ∃ i₀ : ℤ, cumulativeOffset sz i₀ ≤ n := by
    by_contra h_all; push_neg at h_all
    -- All c(i) > n, but c(0) = 0, so n < 0.
    -- As i decreases, c(i) decreases strictly. Since c(i) > n for all i,
    -- and c decreases by at least 1 per step going negative, we need
    -- c(-(n+1)) ≤ c(0) - (n+1) = -(n+1) ≤ n if n < -1... but c(i) > n for all i.
    -- Actually, let's use the Archimedean property more carefully.
    -- c(i) - c(i-1) = sz(i-1) ≥ 1 for all i, so c(i) ≤ c(0) + i = i for i ≥ 0
    -- and c(i) = c(0) - sum_{j=i}^{-1} sz(j) ≤ -|i| for i < 0.
    -- So for i < 0, c(i) ≤ i. Take i₀ = n, then c(n) ≤ n, contradiction.
    -- More precisely: c(-m) ≤ -m for m ≥ 0 (by induction).
    have h_neg : ∀ m : ℕ, cumulativeOffset sz (-(m : ℤ)) ≤ -(m : ℤ) := by
      intro m; induction m with
      | zero => simp [cumulativeOffset_zero]
      | succ m ih =>
        have h1 : cumulativeOffset sz (-(↑(m + 1) : ℤ)) <
            cumulativeOffset sz (-(↑(m + 1) : ℤ) + 1) := h_step_pos _
        have h2 : -(↑(m + 1) : ℤ) + 1 = -(↑m : ℤ) := by omega
        rw [h2] at h1; omega
    -- Take i₀ with c(i₀) ≤ n. We need c(-m) ≤ n for some m.
    -- Since c(-m) ≤ -m, take m large enough that -m ≤ n.
    have h_n_neg : n < 0 := by linarith [h_all 0, cumulativeOffset_zero sz]
    have := h_neg n.natAbs
    have h_key : -(n.natAbs : ℤ) = n := by omega
    rw [h_key] at this
    exact absurd this (not_le.mpr (h_all n))
  -- Find upper bound: some i₁ with n < c(i₁)
  have h_exists_hi : ∃ i₁ : ℤ, n < cumulativeOffset sz i₁ := by
    -- c(m) ≥ m for m ≥ 0 (by induction using c(m+1) ≥ c(m) + 1)
    have h_pos_growth : ∀ m : ℕ, (m : ℤ) ≤ cumulativeOffset sz (m : ℤ) := by
      intro m; induction m with
      | zero => simp [cumulativeOffset_zero]
      | succ m ih =>
        have h := h_step_pos (m : ℤ)
        have h2 : (↑(m + 1) : ℤ) = ↑m + 1 := by push_cast; ring
        rw [show cumulativeOffset sz ↑(m + 1) = cumulativeOffset sz (↑m + 1) from by rw [h2]]
        omega
    exact ⟨(n + 1).toNat, by
      have := h_pos_growth (n + 1).toNat
      have h1 : ((n + 1).toNat : ℤ) ≥ n + 1 := Int.toNat_le.mp le_rfl
      omega⟩
  -- Now use find_last_index_below with lo=i₀, hi=i₁
  obtain ⟨i₀, hi₀⟩ := h_exists_lo
  obtain ⟨i₁, hi₁⟩ := h_exists_hi
  obtain ⟨i, _, h_le, h_lt⟩ := find_last_index_below (cumulativeOffset sz)
    h_mono n i₀ i₁ hi₀ hi₁
  exact ⟨i, h_le, h_lt⟩

/--
The piece index for a given integer under cumulative offset is unique.
-/
private theorem cumulativeOffset_unique_piece (sz : ℤ → ℕ) (h_pos : ∀ i, 0 < sz i)
    (n : ℤ) (i j : ℤ) (hi : cumulativeOffset sz i ≤ n ∧ n < cumulativeOffset sz (i + 1))
    (hj : cumulativeOffset sz j ≤ n ∧ n < cumulativeOffset sz (j + 1)) : i = j := by
  have h_mono := cumulativeOffset_strictMono sz h_pos
  by_contra h_ne
  rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
  · -- i < j, so i + 1 ≤ j, so c(i+1) ≤ c(j) ≤ n < c(i+1)
    have := h_mono.monotone (show i + 1 ≤ j from Int.add_one_le_iff.mpr h_lt)
    linarith [hi.2, hj.1]
  · -- j < i, symmetric
    have := h_mono.monotone (show j + 1 ≤ i from Int.add_one_le_iff.mpr h_gt)
    linarith [hj.2, hi.1]

/--
An ordered sum of good structures indexed by ℤ, where each component has both
a maximum and minimum element, is itself good.

This is the "shift-and-glue" step from Reynolds Lemma 16. Each good component
ms(i) has a Z-interval witness Z_i. By doets_lemma_1_4, orderedSum ms ~k
orderedSum (Z_i.toOrdered). Since each Z_i inherits boundedness from ms(i)
(at k ≥ 2 via "has max/min" expressibility; at k ≤ 1 via good_one), the
concatenation of bounded Z-intervals indexed by ℤ is order-isomorphic to a
single unbounded Z-interval (the "shift-and-glue" construction), hence good.
-/
private theorem ordered_sum_of_good_bounded_is_good (sig : MonadicSignature) (k : Nat)
    (ms : ℤ → OrderedMonadicStructure sig)
    (h_good : ∀ i : ℤ, good sig k (ms i))
    (h_has_max : ∀ i : ℤ, ∃ m : (ms i).carrier, ∀ x, x ≤ m)
    (h_has_min : ∀ i : ℤ, ∃ m : (ms i).carrier, ∀ x, m ≤ x) :
    good sig k (orderedSum sig ℤ ms) := by
  cases k with
  | zero =>
    -- At depth 0, all structures have the same 0-type (AtomKind sig 0 is empty)
    refine ⟨⟨some 0, some 0, fun _ _ => True⟩, ?_⟩
    unfold k_equiv k_type_of; funext nf; simp only [decide_eq_decide]
    have h_empty : IsEmpty (AtomKind sig 0) :=
      ⟨fun a => match a with | .pred _ i => Fin.elim0 i | .order i _ _ => Fin.elim0 i⟩
    constructor <;> intro _ a <;> exact h_empty.elim a
  | succ k' =>
    cases k' with
    | zero =>
      -- At depth 1, all structures are good (good_one)
      exact good_one sig (orderedSum sig ℤ ms)
    | succ k'' =>
      -- At depth k''+2 ≥ 2: use doets_lemma_1_4 + shift-and-glue on witnesses.
      -- Each ms(i) has max and min. The witnesses Z_i inherit boundedness via
      -- doets_lemma_1_1 (transferring "has max/min" sentences at depth 2 ≤ k).
      -- The concatenation of bounded Z-intervals indexed by ℤ is order-isomorphic
      -- to ℤ via cumulative-offset shift-and-glue, hence good.
      -- NOTE: The SuccOrder/PredOrder/IsSuccArchimedean instances on the witness
      -- side (needed for orderIsoIntOfLinearSuccPredArch) are safe: the concatenated
      -- Z-intervals are explicitly integer-like by construction.
      -- Get Z-interval witnesses
      let witnesses := choose_good_witness sig (k'' + 2) ms h_good
      have h_equiv := choose_good_witness_spec sig (k'' + 2) ms h_good
      -- orderedSum ms ~k orderedSum witnesses via doets_lemma_1_4
      let wit_structs := fun i => (witnesses i).toOrdered sig
      have h_sum_equiv : k_equiv sig (k'' + 2) (orderedSum sig ℤ ms)
          (orderedSum sig ℤ wit_structs) :=
        doets_lemma_1_4 sig (k'' + 2) ℤ ms wit_structs h_equiv
      -- The ordered sum of bounded Z-interval witnesses is good
      -- (shift-and-glue: concatenation of bounded ℤ-intervals indexed by ℤ ≃o ℤ)
      have h_wit_good : good sig (k'' + 2) (orderedSum sig ℤ wit_structs) := by
        -- Shift-and-glue: each witness is bounded, build OrderIso to ℤ.
        -- Step 1: Each witness is bounded.
        have h_bnd := witness_bounded sig k'' ms h_good h_has_max h_has_min
        -- Step 2: Extract bounds and prove lo ≤ hi.
        classical
        -- Use witness_bounded + transferred has_max to get lo_i ≤ hi_i.
        -- First establish nonemptiness of each witness by transferring "has max" sentence.
        have h_lo_le_hi : ∀ i, ∃ (lo_v hi_v : ℤ),
            (witnesses i).lo = some lo_v ∧ (witnesses i).hi = some hi_v ∧ lo_v ≤ hi_v := by
          intro i
          obtain ⟨⟨hi_v, h_hi⟩, ⟨lo_v, h_lo⟩⟩ := h_bnd i
          refine ⟨lo_v, hi_v, h_lo, h_hi, ?_⟩
          -- Need lo_v ≤ hi_v. Transfer "∃x.∀y.¬(x<y)" from ms i to get witness in carrier.
          have h_same_nf : ∀ nf : NormalForm sig (k'' + 2) 0,
              nf_eval_nf (ms i) (k'' + 2) 0 Fin.elim0 nf ↔
              nf_eval_nf ((witnesses i).toOrdered sig) (k'' + 2) 0 Fin.elim0 nf := by
            intro nf; have hh := congr_fun (h_equiv i) nf
            simp [k_type_of] at hh; exact_mod_cast hh
          let has_max_sent : MonadicSentence sig := .ex (.all (.not (.lt 1 0)))
          have h_depth : has_max_sent.quantifier_depth ≤ k'' + 2 := by
            simp [has_max_sent, MonadicFormula.quantifier_depth]
          obtain ⟨mx, h_mx⟩ := h_has_max i
          have h_M : eval (ms i) Fin.elim0 has_max_sent := by
            simp only [has_max_sent, eval, Fin.cons]
            exact ⟨mx, fun y => not_lt.mpr (h_mx y)⟩
          have h_W := (doets_lemma_1_1 (k'' + 2) 0 has_max_sent h_depth _ _
            Fin.elim0 Fin.elim0 h_same_nf).mp h_M
          simp only [has_max_sent, eval, Fin.cons] at h_W
          obtain ⟨⟨z, hz⟩, _⟩ := h_W
          -- hz : lo.elim True (· ≤ z) ∧ hi.elim True (z ≤ ·) with lo = some lo_v, hi = some hi_v
          have hz1 : lo_v ≤ z := by
            have := hz.1; rw [show (witnesses i).lo = some lo_v from h_lo] at this
            simp [Option.elim] at this; exact this
          have hz2 : z ≤ hi_v := by
            have := hz.2; rw [show (witnesses i).hi = some hi_v from h_hi] at this
            simp [Option.elim] at this; exact this
          exact le_trans hz1 hz2
        -- Extract lo, hi as functions
        let lo_val : ℤ → ℤ := fun i => (h_lo_le_hi i).choose
        let hi_val : ℤ → ℤ := fun i => (h_lo_le_hi i).choose_spec.choose
        have h_specs : ∀ i, (witnesses i).lo = some (lo_val i) ∧
            (witnesses i).hi = some (hi_val i) ∧ lo_val i ≤ hi_val i :=
          fun i => (h_lo_le_hi i).choose_spec.choose_spec
        -- Step 3: Define size function and cumulative offset
        let sz : ℤ → ℕ := fun i => (hi_val i - lo_val i + 1).toNat
        have h_sz_pos : ∀ i, 0 < sz i := by
          intro i; show 0 < (hi_val i - lo_val i + 1).toNat
          exact Int.pos_iff_toNat_pos.mp (by have := (h_specs i).2.2; omega)
        -- Step 4: Build the Z-interval witness via shift-and-glue
        -- Use classical choice to define the inverse map (piece lookup)
        let piece_of : ℤ → ℤ := fun n' => (cumulativeOffset_covers sz h_sz_pos n').choose
        have h_piece_spec : ∀ n', cumulativeOffset sz (piece_of n') ≤ n' ∧
            n' < cumulativeOffset sz (piece_of n' + 1) :=
          fun n' => (cumulativeOffset_covers sz h_sz_pos n').choose_spec
        let Z_result : ZIntervalStructure sig := {
          lo := none
          hi := none
          interp := fun p n' => (witnesses (piece_of n')).interp p
            (lo_val (piece_of n') + (n' - cumulativeOffset sz (piece_of n')))
        }
        refine ⟨Z_result, ?_⟩
        -- Step 5: Build OrderIso
        -- Forward: ⟨i, z⟩ ↦ ⟨c(i) + (z - lo_i), trivial⟩
        -- Inverse: ⟨n', _⟩ ↦ ⟨piece_of n', lo + (n' - c(piece_of n'))⟩
        -- Helper: membership in witness carrier from lo/hi bounds
        have h_mem : ∀ i (z : ℤ), lo_val i ≤ z → z ≤ hi_val i →
            (witnesses i).lo.elim True (· ≤ z) ∧ (witnesses i).hi.elim True (z ≤ ·) := by
          intro i z hlz hzh
          constructor
          · rw [(h_specs i).1]; exact hlz
          · rw [(h_specs i).2.1]; exact hzh
        -- Inverse element is in carrier
        have h_inv_mem : ∀ n', lo_val (piece_of n') ≤ lo_val (piece_of n') +
            (n' - cumulativeOffset sz (piece_of n')) ∧
            lo_val (piece_of n') + (n' - cumulativeOffset sz (piece_of n')) ≤
            hi_val (piece_of n') := by
          intro n'
          have hp := h_piece_spec n'
          have hs := cumulativeOffset_step sz (piece_of n')
          constructor
          · omega
          · -- n' < c(piece+1) = c(piece) + sz(piece)
            -- lo + (n' - c) ≤ lo + (c + sz - 1 - c) = lo + sz - 1 = lo + (hi - lo + 1) - 1 = hi
            have h_sz_eq : (sz (piece_of n') : ℤ) = hi_val (piece_of n') - lo_val (piece_of n') + 1 := by
              simp only [sz]; rw [Int.toNat_of_nonneg (by have := (h_specs (piece_of n')).2.2; omega)]
            omega
        -- Build the Equiv using Equiv.mk
        let fwd_val : (Σ i : ℤ, (wit_structs i).carrier) → ℤ :=
          fun ⟨i, ⟨z, _⟩⟩ => cumulativeOffset sz i + (z - lo_val i)
        let inv_val : ℤ → (Σ i : ℤ, (wit_structs i).carrier) :=
          fun n' =>
            let i := piece_of n'
            ⟨i, ⟨lo_val i + (n' - cumulativeOffset sz i),
              h_mem i _ (h_inv_mem n').1 (h_inv_mem n').2⟩⟩
        -- Build the forward as map to intervalCarrier
        let fwd_ic : (orderedSum sig ℤ wit_structs).carrier → Z_result.intervalCarrier :=
          fun x => ⟨fwd_val x, trivial, trivial⟩
        let inv_ic : Z_result.intervalCarrier → (orderedSum sig ℤ wit_structs).carrier :=
          fun ⟨n', _⟩ => inv_val n'
        have h_left : ∀ x, inv_ic (fwd_ic x) = x := by
          intro ⟨i, ⟨z, hz⟩⟩
          simp only [fwd_ic, inv_ic, fwd_val, inv_val]
          -- piece_of (c(i) + (z - lo_i)) = i
          have hz_bounds : lo_val i ≤ z ∧ z ≤ hi_val i := by
            simp [(h_specs i).1, (h_specs i).2.1, Option.elim] at hz; exact hz
          have h_n_in : cumulativeOffset sz i ≤ cumulativeOffset sz i + (z - lo_val i) ∧
              cumulativeOffset sz i + (z - lo_val i) < cumulativeOffset sz (i + 1) := by
            constructor
            · omega
            · rw [cumulativeOffset_step]; simp only [sz]
              have := (h_specs i).2.2; omega
          have h_pi := cumulativeOffset_unique_piece sz h_sz_pos
            (cumulativeOffset sz i + (z - lo_val i)) (piece_of _) i
            (h_piece_spec _) h_n_in
          -- Use Sigma.eq_iff to handle dependent equality
          -- piece_of(c(i)+(z-lo_i)) = i by h_pi
          -- After substituting, second components have equal values (omega)
          -- piece_of(c(i)+(z-lo_i)) = i (h_pi) and lo_i + (c(i)+(z-lo_i) - c(i)) = z (omega).
          -- Since fwd_val is injective (strictly monotone), it suffices to show
          -- fwd_val (inv_ic (fwd_ic ⟨i, ⟨z, hz⟩⟩)) = fwd_val ⟨i, ⟨z, hz⟩⟩
          -- and then use injectivity.
          have h_fwd_inj : Function.Injective fwd_val := by
            intro ⟨a, ⟨va, hva⟩⟩ ⟨b, ⟨vb, hvb⟩⟩ h_eq
            simp only [fwd_val] at h_eq
            -- If a = b, then va = vb by h_eq. If a ≠ b, fwd_val is strict mono gives contradiction.
            by_cases hab : a = b
            · subst hab; congr 1; exact Subtype.ext (show va = vb by omega)
            · exfalso
              rcases lt_or_gt_of_ne hab with h | h
              · have hb_a : lo_val a ≤ va ∧ va ≤ hi_val a := by
                  constructor
                  · have := hva.1; rw [(h_specs a).1] at this; exact this
                  · have := hva.2; rw [(h_specs a).2.1] at this; exact this
                have : cumulativeOffset sz a + (va - lo_val a) < cumulativeOffset sz (a + 1) := by
                  rw [cumulativeOffset_step]; simp only [sz]
                  rw [Int.toNat_of_nonneg (by have := (h_specs a).2.2; omega)]; omega
                have : cumulativeOffset sz (a + 1) ≤ cumulativeOffset sz b :=
                  (cumulativeOffset_strictMono sz h_sz_pos).monotone (Int.add_one_le_iff.mpr h)
                have hb_b : lo_val b ≤ vb := by
                  have := hvb.1; rw [(h_specs b).1] at this; exact this
                omega
              · have hb_b : lo_val b ≤ vb ∧ vb ≤ hi_val b := by
                  constructor
                  · have := hvb.1; rw [(h_specs b).1] at this; exact this
                  · have := hvb.2; rw [(h_specs b).2.1] at this; exact this
                have : cumulativeOffset sz b + (vb - lo_val b) < cumulativeOffset sz (b + 1) := by
                  rw [cumulativeOffset_step]; simp only [sz]
                  rw [Int.toNat_of_nonneg (by have := (h_specs b).2.2; omega)]; omega
                have : cumulativeOffset sz (b + 1) ≤ cumulativeOffset sz a :=
                  (cumulativeOffset_strictMono sz h_sz_pos).monotone (Int.add_one_le_iff.mpr h)
                have hb_a : lo_val a ≤ va := by
                  have := hva.1; rw [(h_specs a).1] at this; exact this
                omega
          apply h_fwd_inj
          show fwd_val (inv_val (cumulativeOffset sz i + (z - lo_val i))) =
            cumulativeOffset sz i + (z - lo_val i)
          simp only [fwd_val, inv_val]
          rw [h_pi]; omega
        have h_right : ∀ y, fwd_ic (inv_ic y) = y := by
          intro ⟨n', hn'⟩
          apply Subtype.ext
          show cumulativeOffset sz (piece_of n') +
            (lo_val (piece_of n') + (n' - cumulativeOffset sz (piece_of n')) -
              lo_val (piece_of n')) = n'
          omega
        let e : (orderedSum sig ℤ wit_structs).carrier ≃ Z_result.intervalCarrier := {
          toFun := fwd_ic
          invFun := inv_ic
          left_inv := h_left
          right_inv := h_right
        }
        -- Monotonicity of e (forward)
        have h_fwd_mono : Monotone e := by
          intro ⟨i₁, ⟨z₁, hz₁⟩⟩ ⟨i₂, ⟨z₂, hz₂⟩⟩ h_le
          show cumulativeOffset sz i₁ + (z₁ - lo_val i₁) ≤
            cumulativeOffset sz i₂ + (z₂ - lo_val i₂)
          have hb₁ : lo_val i₁ ≤ z₁ ∧ z₁ ≤ hi_val i₁ := by
            simp [(h_specs i₁).1, (h_specs i₁).2.1, Option.elim] at hz₁; exact hz₁
          have hb₂ : lo_val i₂ ≤ z₂ ∧ z₂ ≤ hi_val i₂ := by
            simp [(h_specs i₂).1, (h_specs i₂).2.1, Option.elim] at hz₂; exact hz₂
          -- h_le is in Sigma.Lex order
          rcases Sigma.Lex.le_def.mp h_le with h_lt | ⟨h_eq, h_z_le⟩
          · -- i₁ < i₂
            have h1 : cumulativeOffset sz i₁ + (z₁ - lo_val i₁) <
                cumulativeOffset sz (i₁ + 1) := by
              rw [cumulativeOffset_step]; simp only [sz]
              have := (h_specs i₁).2.2; omega
            have h2 : cumulativeOffset sz (i₁ + 1) ≤ cumulativeOffset sz i₂ :=
              (cumulativeOffset_strictMono sz h_sz_pos).monotone
                (Int.add_one_le_iff.mpr h_lt)
            omega
          · -- i₁ = i₂ and z₁ ≤ z₂
            cases h_eq
            -- h_z_le : ⟨z₁, _⟩ ≤ ⟨z₂, _⟩ in the subtype order, i.e., z₁ ≤ z₂
            have : z₁ ≤ z₂ := h_z_le
            omega
        -- Monotonicity of e.symm (inverse)
        have h_inv_mono : Monotone e.symm := by
          intro a b (hab : a ≤ b)
          -- If inv(a) > inv(b), then e(inv(a)) > e(inv(b)) by monotonicity of e,
          -- i.e., a > b, contradicting hab.
          -- Equivalently: show ¬(inv(b) < inv(a))
          show e.symm a ≤ e.symm b
          by_contra h_not
          push_neg at h_not  -- h_not : e.symm b < e.symm a
          have h1 : e (e.symm b) ≤ e (e.symm a) := h_fwd_mono (le_of_lt h_not)
          simp only [Equiv.apply_symm_apply] at h1
          -- h1 : b ≤ a, combined with hab gives a = b
          exact absurd (le_antisymm hab h1 ▸ h_not) (lt_irrefl _)
        let fullIso := Equiv.toOrderIso e h_fwd_mono h_inv_mono
        apply k_equiv_of_iso sig (k'' + 2) _ _ fullIso
        -- Predicate preservation: show interp agrees across the isomorphism
        intro p ⟨i, ⟨z, hz⟩⟩
        -- LHS: (orderedSum sig ℤ wit_structs).interp p ⟨i, ⟨z, hz⟩⟩ = (witnesses i).interp p z
        -- RHS: Z_result.interp p (c(i) + (z - lo_i)) = (witnesses (piece_of ...)).interp p (lo + (n - c))
        -- Need: piece_of (c(i) + (z - lo_i)) = i and lo + (n - c) = z
        show (witnesses i).interp p z ↔
          (witnesses (piece_of (cumulativeOffset sz i + (z - lo_val i)))).interp p
            (lo_val (piece_of (cumulativeOffset sz i + (z - lo_val i))) +
              (cumulativeOffset sz i + (z - lo_val i) -
                cumulativeOffset sz (piece_of (cumulativeOffset sz i + (z - lo_val i)))))
        have hz_bounds : lo_val i ≤ z ∧ z ≤ hi_val i := by
          simp [(h_specs i).1, (h_specs i).2.1, Option.elim] at hz; exact hz
        set n' := cumulativeOffset sz i + (z - lo_val i) with hn'_def
        have h_n_in : cumulativeOffset sz i ≤ n' ∧ n' < cumulativeOffset sz (i + 1) := by
          constructor
          · simp [n']; omega
          · rw [cumulativeOffset_step]; simp only [sz, n']
            have := (h_specs i).2.2; omega
        have h_pi : piece_of n' = i :=
          cumulativeOffset_unique_piece sz h_sz_pos n' _ i (h_piece_spec n') h_n_in
        rw [h_pi]
        -- lo_val i + (n' - c(i)) = z because n' = c(i) + (z - lo_val i)
        have : lo_val i + (n' - cumulativeOffset sz i) = z := by rw [hn'_def]; omega
        rw [this]
      obtain ⟨Z_final, hZ_final⟩ := h_wit_good
      exact ⟨Z_final, h_sum_equiv.trans hZ_final⟩

/--
Closed-to-half-open k-equivalence: a half-open subinterval [a, b) is good when
a < b and the order has PredOrder, because [a, b) = [a, pred(b)] which is a
closed subinterval and hence good by very_good.
-/
private theorem hoSubinterval_good_of_very_good (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [PredOrder M.carrier]
    (a b : M.carrier) (h_lt : a < b) (h_very_good : very_good sig k M) :
    good sig k (M.hoSubinterval sig a b) := by
  have h_pred_lt : Order.pred b < b := Order.pred_lt_of_not_isMin (not_isMin_of_lt h_lt)
  have h_a_le_pred : a ≤ Order.pred b := Order.le_pred_of_lt h_lt
  have h_good_closed := h_very_good a (Order.pred b) h_a_le_pred
  have h_iff : ∀ x : M.carrier, (a ≤ x ∧ x < b) ↔ (a ≤ x ∧ x ≤ Order.pred b) := by
    intro x; exact ⟨fun ⟨h1, h2⟩ => ⟨h1, Order.le_pred_of_lt h2⟩,
                    fun ⟨h1, h2⟩ => ⟨h1, lt_of_le_of_lt h2 h_pred_lt⟩⟩
  let e : (M.hoSubinterval sig a b).carrier ≃ (M.subinterval sig a (Order.pred b)).carrier :=
    { toFun := fun ⟨x, hx⟩ => ⟨x, (h_iff x).mp hx⟩
      invFun := fun ⟨x, hx⟩ => ⟨x, (h_iff x).mpr hx⟩
      left_inv := fun ⟨_, _⟩ => rfl
      right_inv := fun ⟨_, _⟩ => rfl }
  let f : (M.hoSubinterval sig a b).carrier ≃o (M.subinterval sig a (Order.pred b)).carrier :=
    Equiv.toOrderIso e (fun _ _ h => h) (fun _ _ h => h)
  have h_k_equiv := k_equiv_of_iso sig k (M.hoSubinterval sig a b)
    (M.subinterval sig a (Order.pred b)) f (fun _ _ => Iff.rfl)
  obtain ⟨Z, hZ⟩ := h_good_closed
  exact ⟨Z, h_k_equiv.trans hZ⟩

/--
Reynolds Lemma 16: If M is a countable discrete linear order without endpoints and
every subinterval of M is good (very_good), then M itself is good.

The proof constructs a cofinal decomposition of M into half-open pieces [a(i), a(i+1))
which partition M disjointly (unlike closed intervals which overlap at boundaries).
M is order-isomorphic to the ordered sum of these pieces. Each half-open piece
is good (via PredOrder: [a(i), a(i+1)) = [a(i), pred(a(i+1))], a closed subinterval
that is good by very_good). The ordered sum of good bounded structures is itself good
(by the shift-and-glue OrderIso + doets_lemma_1_4 construction).

PredOrder is required to convert half-open pieces to closed subintervals for very_good.
-/
theorem very_good_implies_good (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [Nonempty M.carrier] [PredOrder M.carrier]
    (_h_countable : Countable M.carrier) (h_very_good : very_good sig k M) :
    good sig k M := by
  -- Step 1: Construct cofinal sequence
  obtain ⟨a, h_mono, h_cofinal_closed⟩ := @exists_cofinal_sequence M.carrier M.carrier_order
    _h_countable inferInstance inferInstance inferInstance
  -- Step 1b: Derive half-open cofinality from closed cofinality
  have h_cofinal : ∀ x : M.carrier, ∃ i : ℤ, a i ≤ x ∧ x < a (i + 1) := by
    intro x
    obtain ⟨i, hi_le, hi_le'⟩ := h_cofinal_closed x
    by_cases h : x < a (i + 1)
    · exact ⟨i, hi_le, h⟩
    · push_neg at h
      have h_eq : x = a (i + 1) := le_antisymm hi_le' h
      exact ⟨i + 1, h_eq ▸ le_refl _, h_eq ▸ h_mono (by omega : i + 1 < i + 1 + 1)⟩
  -- Step 2: Define the half-open pieces
  let pieces := fun i : ℤ => M.hoSubinterval sig (a i) (a (i + 1))
  -- Step 3: Each piece is good by very_good + PredOrder
  have h_pieces_good : ∀ i : ℤ, good sig k (pieces i) := fun i =>
    hoSubinterval_good_of_very_good sig k M (a i) (a (i + 1))
      (h_mono (Int.lt_add_one_iff.mpr le_rfl)) h_very_good
  -- Step 4: M ~k orderedSum ℤ pieces (cofinal decomposition via order isomorphism)
  have h_decomp : k_equiv sig k M (orderedSum sig ℤ pieces) :=
    cofinal_decomposition_k_equiv sig k M a h_mono h_cofinal
  -- Step 5: Each piece has max and min
  have h_has_max : ∀ i : ℤ, ∃ m : (pieces i).carrier, ∀ x, x ≤ m := by
    intro i
    have h_lt : a i < a (i + 1) := h_mono (Int.lt_add_one_iff.mpr le_rfl)
    have h_pred_lt : Order.pred (a (i + 1)) < a (i + 1) :=
      Order.pred_lt_of_not_isMin (not_isMin_of_lt h_lt)
    have h_a_le_pred : a i ≤ Order.pred (a (i + 1)) := Order.le_pred_of_lt h_lt
    refine ⟨⟨Order.pred (a (i + 1)), h_a_le_pred, h_pred_lt⟩, ?_⟩
    intro ⟨x, hx⟩; exact Order.le_pred_of_lt hx.2
  have h_has_min : ∀ i : ℤ, ∃ m : (pieces i).carrier, ∀ x, m ≤ x := by
    intro i
    have h_lt : a i < a (i + 1) := h_mono (Int.lt_add_one_iff.mpr le_rfl)
    exact ⟨⟨a i, le_refl _, h_lt⟩, fun ⟨_, hx⟩ => hx.1⟩
  -- Step 6: orderedSum pieces is good (shift-and-glue)
  have h_sum_good : good sig k (orderedSum sig ℤ pieces) :=
    ordered_sum_of_good_bounded_is_good sig k pieces h_pieces_good h_has_max h_has_min
  -- Step 7: Compose by transitivity of k-equiv
  obtain ⟨Z_final, hZ_final⟩ := h_sum_good
  exact ⟨Z_final, h_decomp.trans hZ_final⟩

/-! ## Chronicle is Good -/

/--
The chronicle prior model is good at any finite depth.
-/
theorem chronicle_is_good (M : ChronicleAsPriorModel) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) (k : Nat) :
    good sig k (chronicleAsMonadicStructure M sig atomMap) := by
  haveI : Nonempty M.domain := M.domain_nonempty
  let f : M.domain ≃o ℤ := orderIsoIntOfLinearSuccPredArch
  let Z : ZIntervalStructure sig := {
    lo := none
    hi := none
    interp := fun p z => (atomMap p) ∈ M.fmcs (f.symm z)
  }
  refine ⟨Z, ?_⟩
  let val_iso : Z.intervalCarrier ≃o ℤ :=
    Equiv.toOrderIso
      { toFun := Subtype.val, invFun := fun z => ⟨z, trivial, trivial⟩,
        left_inv := by intro ⟨_, _⟩; rfl, right_inv := by intro _; rfl }
      (fun _ _ h => h) (fun _ _ h => h)
  let g : (chronicleAsMonadicStructure M sig atomMap).carrier ≃o (Z.toOrdered sig).carrier :=
    f.trans val_iso.symm
  apply k_equiv_of_iso sig k _ _ g
  intro p x
  show (atomMap p) ∈ M.fmcs x ↔ (atomMap p) ∈ M.fmcs (f.symm (f x))
  simp [OrderIso.symm_apply_apply]

end Bimodal.Metalogic.WeakCanonical
