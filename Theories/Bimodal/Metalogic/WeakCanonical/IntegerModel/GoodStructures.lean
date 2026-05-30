import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.WeakCanonical.Table
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Mathlib.Data.Fintype.Sort
import Mathlib.Order.SuccPred.LinearLocallyFinite

/-!
# Good Z-Interval Structures: Foundations, Succ-Iteration, and the One-Class Theorem

Z-interval structures, good structures, succ-iteration, transitivity helpers
(Reynolds Lemma 17), contemporaneous equivalence, no gaps in discrete orders,
and the one-class theorem.
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

**Reynolds Theorem 5** (US expressive completeness over Prior structures) is
now formalized in `PriorExpressiveness.lean`: U'(A,B) ≡ ⊥ and S'(A,B) ≡ ⊥
in any Prior structure (via Prior-UZ/SZ), composed with GHR94 Theorem 9.3.1.
**REMAINING**: Lemmas 6-13 (gap formula R, model surgery) and Theorem 14
are needed to close this sorry.

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
  -- Reynolds Theorem 5 (US expressive completeness) is COMPLETED in
  -- PriorExpressiveness.lean (stavi_U_false_on_prior_UZ, stavi_S_false_on_prior_SZ,
  -- US_expressively_complete_over_prior).
  -- REMAINING: Reynolds Lemmas 6-13 (gap formula R, R-interval properties, model
  -- surgery) and Theorem 14. See plans/09_reynolds-hybrid-plan.md Phases 2-4.
  -- Once Lemmas 6-13 + Theorem 14 are formalized in ReynoldsNoGaps.lean,
  -- this sorry is replaced by a call to theorem_14.
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


end Bimodal.Metalogic.WeakCanonical
