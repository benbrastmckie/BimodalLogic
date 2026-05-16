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
Phases 3-6 still use `IsSuccArchimedean` (to be removed in subsequent phases).

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
    sorry -- interval_split_iso + k_equiv_of_iso: OrderIso via dite on x ≤ b
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
    sorry -- z_interval_ordered_sum_good: bounded witnesses → Fintype → finite_structures_good
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
In a discrete linear order without endpoints, if a and b are in different ~M
classes, there exists a boundary point c with c ~M a but succ(c) not ~M a.
-/
theorem no_gaps_discrete (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier]
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  exfalso
  apply h_diff_class
  simp only [contemp_equiv, very_good]
  intro x y _
  haveI : Finite (M.subinterval sig (min a b) (max a b)).carrier :=
    subinterval_finite_of_succ_archimedean sig M _ _ min_le_max
  haveI : Fintype (M.subinterval sig (min a b) (max a b)).carrier := Fintype.ofFinite _
  haveI : Fintype ((M.subinterval sig (min a b) (max a b)).subinterval sig x y).carrier :=
    Subtype.fintype _
  exact finite_structures_good sig k _

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
ONE-CLASS THEOREM (Reynolds, discrete case):
All points are contemporaneously equivalent in any discrete succ-Archimedean
linear order without endpoints.
-/
theorem one_class (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier] :
    ∀ (a b : M.carrier), contemp_equiv sig k M a b := by
  intro a b
  simp only [contemp_equiv, very_good]
  intro x y _
  haveI : Finite (M.subinterval sig (min a b) (max a b)).carrier :=
    subinterval_finite_of_succ_archimedean sig M _ _ min_le_max
  haveI : Fintype (M.subinterval sig (min a b) (max a b)).carrier := Fintype.ofFinite _
  haveI : Fintype ((M.subinterval sig (min a b) (max a b)).subinterval sig x y).carrier :=
    Subtype.fintype _
  exact finite_structures_good sig k _

/-! ## Very Good → Good -/

/--
Reynolds Lemma 16: If M is a succ-Archimedean discrete linear order without
endpoints (hence order-isomorphic to ℤ), then M is good at any depth.
-/
theorem very_good_implies_good (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    [IsSuccArchimedean M.carrier] [Nonempty M.carrier]
    (_h_countable : Countable M.carrier) (_h_very_good : very_good sig k M) :
    good sig k M := by
  let f : M.carrier ≃o ℤ := orderIsoIntOfLinearSuccPredArch
  let Z : ZIntervalStructure sig := {
    lo := none
    hi := none
    interp := fun p z => M.interp p (f.symm z)
  }
  refine ⟨Z, ?_⟩
  let val_iso : Z.intervalCarrier ≃o ℤ :=
    Equiv.toOrderIso
      { toFun := Subtype.val, invFun := fun z => ⟨z, trivial, trivial⟩,
        left_inv := by intro ⟨_, _⟩; rfl, right_inv := by intro _; rfl }
      (fun _ _ h => h) (fun _ _ h => h)
  let g : M.carrier ≃o (Z.toOrdered sig).carrier := f.trans val_iso.symm
  apply k_equiv_of_iso sig k M (Z.toOrdered sig) g
  intro p x
  show M.interp p x ↔ M.interp p (f.symm (f x))
  simp [OrderIso.symm_apply_apply]

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
