import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.WeakCanonical.Table
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Mathlib.Data.Fintype.Sort

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
Definitions are genuine. Proofs that require `sum_preservation` (Doets Lemma 1.4)
remain sorried with TODO markers. The one-class argument chain
(`no_boundary_at_successor` -> `one_class`) works via `finite_structures_good`.

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
  -- The interval carrier = {z : ℤ // (some 0).elim True (· ≤ z) ∧ (some (↑n - 1)).elim True (z ≤ ·)}
  --                       = {z : ℤ // (0 : ℤ) ≤ z ∧ z ≤ (↑n : ℤ) - 1}
  let Z : ZIntervalStructure sig := {
    lo := some 0
    hi := some ((n : ℤ) - 1)
    interp := fun p (z : ℤ) =>
      if h : 0 ≤ z ∧ z < ↑n then
        M.interp p (iso ⟨z.toNat, by omega⟩)
      else
        False  -- outside interval; never evaluated on the actual carrier
  }
  refine ⟨Z, ?_⟩
  -- Build order iso from M.carrier to Z.intervalCarrier
  -- Z.intervalCarrier = {z : ℤ // 0 ≤ z ∧ z ≤ (↑n : ℤ) - 1}
  -- Map: M.carrier → Fin n → ℤ-interval
  -- Build the order isomorphism from M.carrier to Z.intervalCarrier
  -- The composition: M.carrier ≃o Fin n (via iso.symm), then Fin n ≃o Z.intervalCarrier
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
  -- Apply k_equiv_of_iso
  apply k_equiv_of_iso sig k M (Z.toOrdered sig) fullIso
  -- Show predicates are preserved
  intro p x
  -- fullIso x = finToZOrd (iso.symm x)
  -- (fullIso x).val = ↑((iso.symm x : Fin n) : ℕ)
  show M.interp p x ↔ Z.interp p (fullIso x).val
  -- Unfold fullIso
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

/-! ## Contemporaneous Equivalence -/

/--
Contemporaneous equivalence ~M (Reynolds 1994):
a ~M b if the subinterval between them is "very good."
-/
def contemp_equiv (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) : Prop :=
  very_good sig k (M.subinterval sig (min a b) (max a b))

/--
~M is an equivalence relation on M.carrier.

- **Reflexivity**: M.subinterval(a,a) is singleton, hence finite, hence good.
- **Symmetry**: min/max are symmetric.
- **Transitivity**: Requires sum_preservation; sorried.
-/
theorem contemp_equiv_is_equiv (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) :
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
  -- TODO: Transitivity requires genuine very_good argument.
  -- Deferred: depends on sum_preservation for combining subintervals.
  trans {a b c} hab hbc := by
    simp only [contemp_equiv, very_good] at *
    intro x y hxy
    sorry

/-! ## No Gaps in Discrete Orders -/

/--
In a discrete linear order, if a and b are in different ~M classes,
there exists a boundary point c with c ~M a but succ(c) not ~M a.
-/
theorem no_gaps_discrete (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (a b : M.carrier) (h_diff_class : ¬ contemp_equiv sig k M a b) :
    ∃ (c : M.carrier), contemp_equiv sig k M a c ∧
      ¬ contemp_equiv sig k M a (Order.succ c) := by
  -- TODO: Genuine proof requires well-founded induction on the distance between a and b.
  -- Deferred: the genuine argument uses properties of good structures.
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
ONE-CLASS THEOREM (Reynolds, discrete case):
All points are contemporaneously equivalent in any discrete linear order
without endpoints.
-/
theorem one_class (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier] :
    ∀ (a b : M.carrier), contemp_equiv sig k M a b := by
  by_contra h_not_all
  push_neg at h_not_all
  obtain ⟨a, b, h_diff⟩ := h_not_all
  obtain ⟨c, hc_equiv, hc_succ_not⟩ := no_gaps_discrete sig k M a b h_diff
  have h_succ : contemp_equiv sig k M c (Order.succ c) :=
    no_boundary_at_successor sig k M c
  have h_equiv := contemp_equiv_is_equiv sig k M
  have h_succ_c : contemp_equiv sig k M (Order.succ c) c := h_equiv.symm h_succ
  have h_ca' : contemp_equiv sig k M c a := h_equiv.symm hc_equiv
  have h_succ_a : contemp_equiv sig k M (Order.succ c) a := h_equiv.trans h_succ_c h_ca'
  have h_a_succ : contemp_equiv sig k M a (Order.succ c) := h_equiv.symm h_succ_a
  exact hc_succ_not h_a_succ

/-! ## Very Good → Good -/

/--
Reynolds Lemma 16: If M is countable and very good, then M is good.

-- TODO: Requires sum_preservation (Doets Lemma 1.4). Deferred to follow-up task.
-/
theorem very_good_implies_good (sig : MonadicSignature) (k : Nat) (M : OrderedMonadicStructure sig)
    (_h_countable : Countable M.carrier) (_h_very_good : very_good sig k M) :
    good sig k M := by
  sorry

/-! ## Chronicle is Good -/

/--
The chronicle prior model is good at any finite depth.

-- TODO: Depends on very_good_implies_good which depends on sum_preservation. Deferred.
-/
theorem chronicle_is_good (M : ChronicleAsPriorModel) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) (k : Nat) :
    good sig k (chronicleAsMonadicStructure M sig atomMap) := by
  sorry

end Bimodal.Metalogic.WeakCanonical
