import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Bimodal.Metalogic.WeakCanonical.MonadicFO
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Mathlib.Data.Sigma.Order

/-!
# k-Equivalence Framework and Chronicle Integration

Defines the k-equivalence framework for ordered monadic structures, connecting
the monadic FO definitions (from MonadicFO.lean) and normal form theory
(from NormalForm.lean) with the chronicle extraction infrastructure.

## Key definitions
- `KType sig k`: k-types as truth-assignment functions on `NormalForm sig k 0`
- `k_type_of`: k-type computation using `nf_eval_nf` from NormalForm.lean
- `k_equiv`: k-equivalence via k-type equality
- `KEquivalenceFramework`: typeclass interface for k-equivalence properties
- `chronicleAsMonadicStructure`: converts chronicles to ordered monadic structures

## Design
`KType sig k` is `NormalForm sig k 0 → Bool`, where `NormalForm` is the
concrete recursive normal form type from NormalForm.lean. This makes
`Fintype (KType sig k)` trivial via `inferInstance`, and enables
`k_equiv_monotone` to be proved via `nf_agreement_monotone`.

## References
- Doets 1989, Section 1 (k-types, finiteness): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Section 4 (k-equivalence framework): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Task 143: Doets Lemma 1.1 Normal Form KType Redesign
- Task 145: Split NEquivalence, redesign KType to NormalForm, close k_equiv_monotone
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem

/-! ## k-Types and k-Equivalence -/

/--
A k-type is a truth-assignment function on depth-≤k normal forms.
Each k-type maps each `NormalForm sig k 0` to `true` or `false`,
recording which concrete normal form classes of sentences are realized.

The domain `NormalForm sig k 0` is finite (via `normalForm_fintype`),
so `KType sig k` is a `Fintype` via `inferInstance` on `NormalForm sig k 0 → Bool`.

## Design Change (Task 145)
Previously: `NormalFormIdx sig k 0 → Bool` (abstract Fin-index domain).
Now: `NormalForm sig k 0 → Bool` (concrete normal form domain).
This enables `k_equiv_monotone` via `nf_agreement_monotone`.
-/
abbrev KType (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 0 → Bool

/--
The k-type realized by an ordered monadic structure M: for each
normal form at depth k (with 0 free variables), records whether
M satisfies it under the empty environment via `nf_eval_nf`.

Uses `Classical.dec` for decidability of `nf_eval_nf` (the carrier may be infinite).
This makes the definition noncomputable but mathematically precise.
-/
noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun nf => @decide (nf_eval_nf M k 0 Fin.elim0 nf) (Classical.dec _)

/--
k-equivalence: M and N have the same k-type, i.e., they satisfy the same
monadic sentences of quantifier depth ≤ k.
-/
def k_equiv (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) : Prop :=
  k_type_of sig k M = k_type_of sig k N

/--
k-equivalence is equivalent to having the same k-type.
-/
theorem k_equiv_iff_same_type (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) :
    k_equiv sig k M N ↔ k_type_of sig k M = k_type_of sig k N := by
  rfl

/--
Monotonicity: if M and N are k-equivalent, they are m-equivalent for any m ≤ k.

Proved via `nf_agreement_monotone` from NormalForm.lean: if M and N agree on
all depth-k normal forms (extracted from `k_equiv` hypothesis), then by
monotonicity of normal form agreement they agree on all depth-m normal forms.
-/
theorem k_equiv_monotone (sig : MonadicSignature) {k m : Nat}
    {M N : OrderedMonadicStructure sig}
    (hkm : m ≤ k) (h_equiv : k_equiv sig k M N) : k_equiv sig m M N := by
  -- Unfold k_equiv and k_type_of to get pointwise equality on NormalForm
  unfold k_equiv k_type_of at h_equiv ⊢
  funext nf_m
  -- Extract the depth-k agreement from h_equiv
  have h_agree_k : ∀ nf : NormalForm sig k 0,
      nf_eval_nf M k 0 Fin.elim0 nf ↔ nf_eval_nf N k 0 Fin.elim0 nf := by
    intro nf
    have h_pt := congr_fun h_equiv nf
    simp only [decide_eq_decide] at h_pt
    exact h_pt
  -- Apply nf_agreement_monotone to step down from depth k to depth m
  have h_agree_m := nf_agreement_monotone m k 0 hkm M Fin.elim0 N Fin.elim0 h_agree_k nf_m
  simp only [decide_eq_decide]
  exact h_agree_m

/-! ## Ordered Sum Construction -/

/--
The ordered sum of a family of ordered monadic structures, indexed by a
linearly ordered type `I`. The carrier is the dependent sigma type
`Σ i, (ms i).carrier` with lexicographic order: elements from different
components are ordered by their index; elements from the same component
are ordered by the component's linear order.

Uses Mathlib's `Sigma.Lex.linearOrder` which provides a `LinearOrder` on
`Σₗ i, α i` (= `Lex (Σ i, α i)` = `Σ i, α i` as a type) given
`[LinearOrder I]` and `[∀ i, LinearOrder (α i)]`.
-/
noncomputable def orderedSum (sig : MonadicSignature) (I : Type) [LinearOrder I]
    (ms : I → OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
  carrier := Sigma fun i => (ms i).carrier
  interp := fun p x => (ms x.1).interp p x.2
  carrier_order := by
    haveI : ∀ i, LinearOrder ((ms i).carrier) := fun i => (ms i).carrier_order
    exact Sigma.Lex.linearOrder

/-! ## K-Equivalence Framework (Typeclass) -/

/--
`KEquivalenceFramework sig` is a typeclass providing the properties of
k-equivalence needed by the Reynolds pipeline.

The `equiv_at` relation operates on `OrderedMonadicStructure sig` because
evaluation of monadic FO formulas (specifically the `lt` constructor)
requires a linear order on the carrier.

Note: The class lives at `Type 1` because `OrderedMonadicStructure sig`
contains a `carrier : Type` field.
-/
class KEquivalenceFramework (sig : MonadicSignature) : Type 1 where
  /-- The k-equivalence relation between two ordered monadic structures -/
  equiv_at (k : Nat) : OrderedMonadicStructure sig → OrderedMonadicStructure sig → Prop
  /-- k-equivalence is an equivalence relation -/
  equiv_is_equiv (k : Nat) : Equivalence (equiv_at k)
  /-- Finer equivalence implies coarser: if M ≡_k N and m ≤ k then M ≡_m N -/
  equiv_monotone {k m : Nat} (h : m ≤ k) {M N : OrderedMonadicStructure sig}
    (h_equiv : equiv_at k M N) : equiv_at m M N
  /-- There are finitely many k-types (equivalence classes) for any fixed k -/
  finite_types (k : Nat) : Fintype (Quotient (@Setoid.mk _ (equiv_at k) (equiv_is_equiv k)))
  /-- Ordered sums preserve k-equivalence:
    if ∀ i, m(i) ≡_k m'(i) then Σ_i m(i) ≡_k Σ_i m'(i).
    The ordered sum uses lexicographic order via `orderedSum`. -/
  sum_preservation (k : Nat) (I : Type) [inst_lo : LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h : ∀ i, equiv_at k (ms i) (ms' i)) :
    equiv_at k (orderedSum sig I ms) (orderedSum sig I ms')

/-! ## Default KEquivalenceFramework Instance -/

/--
Default instance of `KEquivalenceFramework` for any `MonadicSignature`.

- `equiv_at` is defined as `k_equiv` (equality of k-types via `k_type_of`)
- `equiv_is_equiv`: k-type equality is trivially an equivalence relation
- `equiv_monotone`: follows from `k_equiv_monotone` (via `nf_agreement_monotone`)
- `finite_types`: CLOSED (Task 143) via Fintype injection into `KType sig k`
- `sum_preservation`: sorried, requires normal form induction proof (Doets Lemma 1.4)
-/
noncomputable instance (sig : MonadicSignature) : KEquivalenceFramework sig where
  equiv_at k M N := k_equiv sig k M N
  equiv_is_equiv k := {
    refl := fun _ => rfl
    symm := fun h => h.symm
    trans := fun h1 h2 => h1.trans h2
  }
  equiv_monotone := by
    intro k m h M N h_equiv
    exact k_equiv_monotone sig h h_equiv
  -- CLOSED [Task 143/145]: finite_types via injection into KType sig k.
  -- The quotient by k_equiv injects into KType sig k (which is NormalForm sig k 0 → Bool,
  -- a Fintype). The injection is Quotient.lift (k_type_of sig k), which is well-defined
  -- because k_equiv is defined as equality of k_type_of, and injective for the same reason.
  finite_types k := by
    have h_inj : Function.Injective
        (Quotient.lift (k_type_of sig k)
          (fun M N (h : k_equiv sig k M N) => h) :
          Quotient (@Setoid.mk _ (k_equiv sig k)
            { refl := fun _ => rfl
              symm := fun h => h.symm
              trans := fun h1 h2 => h1.trans h2 }) → KType sig k) := by
      intro a b hab
      induction a using Quotient.inductionOn
      induction b using Quotient.inductionOn
      simp [Quotient.lift_mk] at hab
      exact Quotient.sound hab
    exact Fintype.ofInjective _ h_inj
  -- TODO [Task 154]: sum_preservation via normal form induction (Doets Lemma 1.4).
  sum_preservation k I _ ms ms' h := by
    sorry

/-! ## Chronicle As Monadic Structure Converter -/

/--
Convert a `ChronicleAsPriorModel` to an `OrderedMonadicStructure`.
The `atomMap` function maps each monadic predicate symbol to a
temporal formula; the interpretation of predicate `p` at domain
point `x` is whether `atomMap p ∈ M.fmcs x`.

All properties (countability, discreteness, no endpoints, Prior-UZ/SZ)
are inherited from `ChronicleAsPriorModel`.
-/
def chronicleAsMonadicStructure (M : ChronicleAsPriorModel) (sig : MonadicSignature)
    (atomMap : sig.preds → Formula) : OrderedMonadicStructure sig where
  carrier := M.domain
  interp p x := (atomMap p) ∈ M.fmcs x
  carrier_order := M.domain_lo

/--
The chronicle-as-monadic-structure is countable: its carrier is
`M.domain` which has `Countable` by the `ChronicleAsPriorModel` fields.
-/
instance chronicleAsMonadicStructure_countable (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    Countable (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_countable

/--
The chronicle-as-monadic-structure has no maximum element
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_no_max (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    NoMaxOrder (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_no_max

/--
The chronicle-as-monadic-structure has no minimum element
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_no_min (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    NoMinOrder (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_no_min

/--
The chronicle-as-monadic-structure is discrete (has SuccOrder)
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_succ (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    SuccOrder (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_succ

/--
The chronicle-as-monadic-structure is discrete (has PredOrder)
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_pred (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    PredOrder (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_pred

/--
The chronicle-as-monadic-structure is nonempty
(inherited from ChronicleAsPriorModel).
-/
instance chronicleAsMonadicStructure_nonempty (M : ChronicleAsPriorModel)
    (sig : MonadicSignature) (atomMap : sig.preds → Formula) :
    Nonempty (chronicleAsMonadicStructure M sig atomMap).carrier :=
  M.domain_nonempty

end Bimodal.Metalogic.WeakCanonical
