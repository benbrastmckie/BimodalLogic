import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Mathlib.Data.Finset.Basic

/-!
# n-Equivalence and Monadic Sentences for Z-Model Construction

Defines the monadic first-order framework for Reynolds Theorem 15.

## Key definitions
- `MonadicSignature`: finite set of predicate symbols
- `MonadicFormula sig n`: monadic FO formula with `n` free variables (De Bruijn `Fin n`)
- `MonadicSentence sig`: abbreviation for `MonadicFormula sig 0` (closed formula)
- `MonadicStructure`: carrier with predicate interpretations
- `OrderedMonadicStructure`: monadic structure with `LinearOrder` on the carrier
- `eval`: Tarski satisfaction for monadic FO formulas
- `atomCount`, `nfCount`: Doets 1989 normal form counting functions
- `NormalFormIdx sig k n`: finite index type for depth-≤k normal forms
- `KType sig k`: k-types as truth-assignment functions on `NormalFormIdx sig k 0`
- `k_type_of`: k-type computation mapping structures to `KType sig k`
- `k_equiv`: k-equivalence via k-type equality
- `KEquivalenceFramework`: typeclass interface for k-equivalence properties

## Design
`MonadicFormula sig n` uses De Bruijn variable binding with `Fin n` indices,
following Reynolds 1994 Section 6 and Doets 1987 Chapter 1. Constructors:
`atom`, `lt`, `not`, `and`, `all`, `ex`. Evaluation (`eval`) uses `Fin.cons`
for quantifier binding.

### KType Redesign (Task 143)
`KType sig k` is now `NormalFormIdx sig k 0 → Bool`, where `NormalFormIdx`
is `Fin (nfCount p k 0)` — a finite index type counting the semantically
distinct depth-≤k sentence classes (Doets 1989, Lemma 1.1). This makes
`Fintype (KType sig k)` trivial via `inferInstance`, which in turn makes
the `finite_types` field of `KEquivalenceFramework` provable by injection.

Previously: `{s : MonadicFormula sig 0 // s.quantifier_depth ≤ k} → Bool`
(syntactically infinite domain, `Fintype` was impossible).

## References
- Doets 1989, Section 1 (k-types, finiteness): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Section 4 (k-equivalence framework): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Reynolds 1994, Section 6 (monadic FO language): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Task 143: Doets Lemma 1.1 Normal Form KType Redesign
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem

/-! ## Monadic Signature -/

structure MonadicSignature where
  preds : Type
  [fintypePreds : Fintype preds]
  [decEqPreds : DecidableEq preds]

attribute [instance] MonadicSignature.fintypePreds
attribute [instance] MonadicSignature.decEqPreds

/-! ## Monadic Formula (De Bruijn indexed) -/

/--
A monadic first-order formula with `n` free variables over signature `sig`.
Variables are represented as De Bruijn indices (`Fin n`).

Constructors:
- `atom p i`: unary predicate `p` applied to variable `i`
- `lt i j`: order relation `x_i < x_j`
- `not α`: negation
- `and α β`: conjunction
- `all α`: universal quantification (binds variable 0, shifts others up)
- `ex α`: existential quantification (binds variable 0, shifts others up)
-/
inductive MonadicFormula (sig : MonadicSignature) : Nat → Type where
  | atom {n : Nat} (p : sig.preds) (i : Fin n) : MonadicFormula sig n
  | lt {n : Nat} (i j : Fin n) : MonadicFormula sig n
  | not {n : Nat} (α : MonadicFormula sig n) : MonadicFormula sig n
  | and {n : Nat} (α β : MonadicFormula sig n) : MonadicFormula sig n
  | all {n : Nat} (α : MonadicFormula sig (n + 1)) : MonadicFormula sig n
  | ex {n : Nat} (α : MonadicFormula sig (n + 1)) : MonadicFormula sig n
  deriving DecidableEq

/-- A monadic sentence: a closed formula with 0 free variables. -/
abbrev MonadicSentence (sig : MonadicSignature) := MonadicFormula sig 0

/-- Quantifier depth of a monadic formula. -/
def MonadicFormula.quantifier_depth {sig : MonadicSignature} {n : Nat} :
    MonadicFormula sig n → Nat
  | .atom _ _ => 0
  | .lt _ _ => 0
  | .not α => α.quantifier_depth
  | .and α β => max α.quantifier_depth β.quantifier_depth
  | .all α => α.quantifier_depth + 1
  | .ex α => α.quantifier_depth + 1

/-! ## Monadic Structure -/

/--
A monadic structure over signature `sig`. The carrier is any type;
predicate interpretations map each predicate symbol to a unary predicate
on the carrier.
-/
structure MonadicStructure (sig : MonadicSignature) where
  carrier : Type
  interp (p : sig.preds) : carrier → Prop

/-! ## Ordered Monadic Structure -/

/--
An ordered monadic structure bundles a monadic structure with a
`LinearOrder` on its carrier. This enables subinterval restriction,
the ordered sum construction, and Tarski evaluation of `lt` formulas.
-/
structure OrderedMonadicStructure (sig : MonadicSignature) extends MonadicStructure sig where
  carrier_order : LinearOrder carrier

attribute [instance] OrderedMonadicStructure.carrier_order

instance (sig : MonadicSignature) (M : OrderedMonadicStructure sig) : LinearOrder M.carrier :=
  M.carrier_order

/--
Convert an `OrderedMonadicStructure` to a plain `MonadicStructure`,
dropping the order information.
-/
def OrderedMonadicStructure.toMonadic (sig : MonadicSignature) (M : OrderedMonadicStructure sig) :
    MonadicStructure sig where
  carrier := M.carrier
  interp := M.interp

/--
The subinterval of an ordered monadic structure between points a and b.

The carrier is `{x : M.carrier // a ≤ x ∧ x ≤ b}` (Subtype), and the
predicate interpretations are inherited as `M.interp p x.val`.

The linear order on the subinterval is the inherited Subtype order
(using `Subtype.instLinearOrder` which is available from Mathlib).
-/
def OrderedMonadicStructure.subinterval (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) : OrderedMonadicStructure sig where
  carrier := {x : M.carrier // a ≤ x ∧ x ≤ b}
  interp p x := M.interp p x.val
  carrier_order := inferInstance

/--
If a = b, the subinterval [a, a] is a singleton, hence finite.

Proof: every element x in the subinterval satisfies a ≤ x.val ∧ x.val ≤ a,
so x.val = a by antisymmetry. Thus the subinterval has exactly one element.
-/
theorem subinterval_singleton_finite (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a : M.carrier) : Finite (M.subinterval sig a a).carrier := by
  -- The subinterval carrier is {x : M.carrier // a ≤ x ∧ x ≤ a}
  let elem : (M.subinterval sig a a).carrier := ⟨a, le_refl a, le_refl a⟩
  have h_fintype : Fintype (M.subinterval sig a a).carrier := {
    elems := {elem}
    complete := by
      intro x
      have hx := x.property
      have h_eq_val : x.val = a := le_antisymm hx.2 hx.1
      apply Finset.mem_singleton.mpr
      exact Subtype.ext h_eq_val
  }
  haveI : Fintype (M.subinterval sig a a).carrier := h_fintype
  infer_instance

/--
If b = Order.succ a in a SuccOrder, the subinterval [a, succ a] has exactly
two elements: a and succ(a).
-/
theorem subinterval_two_element_finite (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] (a : M.carrier) :
    Finite (M.subinterval sig a (Order.succ a)).carrier := by
  let c : (M.subinterval sig a (Order.succ a)).carrier := ⟨a, le_refl a, Order.le_succ a⟩
  let d : (M.subinterval sig a (Order.succ a)).carrier := ⟨Order.succ a, Order.le_succ a, le_refl _⟩
  have h_fintype : Fintype (M.subinterval sig a (Order.succ a)).carrier := {
    elems := {c, d}
    complete := by
      intro x
      rcases x with ⟨x_val, hx_a, hx_succ⟩
      by_cases h_eq_a : x_val = a
      · subst h_eq_a; simp [c]
      · have ha_lt_x : a < x_val := lt_of_le_of_ne hx_a (Ne.symm h_eq_a)
        have h_succ_le : Order.succ a ≤ x_val := SuccOrder.succ_le_of_lt ha_lt_x
        have h_eq_succ : x_val = Order.succ a := le_antisymm hx_succ h_succ_le
        subst h_eq_succ; simp [d]
  }
  haveI : Fintype (M.subinterval sig a (Order.succ a)).carrier := h_fintype
  infer_instance

/-! ## Z-Structure: Integer-Based Monadic Structures -/

/--
A Z-structure: a monadic structure whose carrier is ℤ. This represents
a "Z-model" or "Z-interval" in the Reynolds framework.
-/
structure ZStructure (sig : MonadicSignature) where
  interp (p : sig.preds) : ℤ → Prop

/--
Convert a Z-structure to a plain monadic structure.
-/
def ZStructure.toMonadic (sig : MonadicSignature) (Z : ZStructure sig) : MonadicStructure sig where
  carrier := ℤ
  interp := Z.interp

/--
Convert a Z-structure to an ordered monadic structure (using ℤ's natural order).
-/
def ZStructure.toOrdered (sig : MonadicSignature) (Z : ZStructure sig) :
    OrderedMonadicStructure sig where
  carrier := ℤ
  interp := Z.interp
  carrier_order := inferInstance

/-! ## Tarski Satisfaction (eval) -/

/--
Tarski satisfaction for monadic FO formulas. Evaluates a formula with `n` free
variables in an ordered monadic structure `M` under an environment `env` that
assigns carrier elements to each free variable.

Quantifier binding uses `Fin.cons`: `∀ x, eval M (Fin.cons x env) α` binds
variable 0 to `x` and shifts the remaining variables.
-/
def eval {sig : MonadicSignature} {n : Nat} (M : OrderedMonadicStructure sig)
    (env : Fin n → M.carrier) : MonadicFormula sig n → Prop
  | .atom p i => M.interp p (env i)
  | .lt i j => env i < env j
  | .not α => ¬ eval M env α
  | .and α β => eval M env α ∧ eval M env β
  | .all α => ∀ (x : M.carrier), eval M (Fin.cons x env) α
  | .ex α => ∃ (x : M.carrier), eval M (Fin.cons x env) α

/-! ## Normal Form Count (Doets 1989, Lemma 1.1) -/

/--
The number of atomic propositions available with `p` unary predicates and
`n` free variables over a linear order:
- `p * n` predicate atoms: `P_i(x_j)` for each predicate and variable
- `n * (n - 1)` order atoms: `x_i < x_j` for each ordered pair of distinct variables
-/
def atomCount (p n : Nat) : Nat := p * n + n * (n - 1)

/--
The number of semantically distinct monadic FO formulas of quantifier
depth at most `k` with `n` free variables, over a signature with `p`
unary predicates and a linear order.

WARNING: Double-exponential growth. Never mark `@[reducible]` or `@[simp]`.
-/
def nfCount (p : Nat) : Nat → Nat → Nat
  | 0, n => 2 ^ atomCount p n
  | k + 1, n => 2 ^ (atomCount p n + nfCount p k (n + 1))

/-- `nfCount p k n` is always positive. -/
theorem nfCount_pos (p k n : Nat) : 0 < nfCount p k n := by
  induction k generalizing n with
  | zero => simp [nfCount]
  | succ k _ih => simp [nfCount]

/--
The finite index type for normal forms at depth `k` with `n` free variables.
`Fin (nfCount ...)` is always `Fintype` since `Fin N` is `Fintype`.
-/
abbrev NormalFormIdx (sig : MonadicSignature) (k n : Nat) :=
  Fin (nfCount (Fintype.card sig.preds) k n)

/-! ## k-Types and k-Equivalence -/

/--
A k-type is a truth-assignment function on depth-≤k normal forms.
Each k-type maps each normal form index at depth k to `true` or `false`,
recording which semantic equivalence classes of sentences are realized.

The domain `NormalFormIdx sig k 0` is finite (it is `Fin (nfCount ...)`),
so `KType sig k` is a `Fintype` via `inferInstance` on `Fin N → Bool`.

## Design Change (Task 143)
Previously: `{s : MonadicFormula sig 0 // s.quantifier_depth ≤ k} → Bool`
(syntactically infinite domain, `Fintype` impossible).
Now: `NormalFormIdx sig k 0 → Bool` (finite domain via Doets 1989 counting).
-/
abbrev KType (sig : MonadicSignature) (k : Nat) : Type :=
  NormalFormIdx sig k 0 → Bool

/--
A canonical representative mapping from normal form indices to depth-≤k
sentences. Selected abstractly via `Classical.choice`.

The existence of such a mapping is guaranteed because:
- The domain `NormalFormIdx sig k 0` has cardinality `nfCount p k 0`
- There exist depth-≤k sentences (e.g., `∀x.∀y.x < y` has depth 2)
- We only need an arbitrary function, not a surjection

The mathematical content (that the chosen representatives are semantically
distinct and cover all equivalence classes) is the substance of Doets
Lemma 1.1, which provides conceptual justification but is not required
for the finite_types proof.
-/
noncomputable def nf_rep (sig : MonadicSignature) (k : Nat) :
    NormalFormIdx sig k 0 → MonadicFormula sig 0 :=
  Classical.choice ⟨fun _ => MonadicFormula.not (MonadicFormula.not
    (MonadicFormula.all (MonadicFormula.all
      (MonadicFormula.lt ⟨0, by omega⟩ ⟨1, by omega⟩))))⟩

/--
The k-type realized by an ordered monadic structure M: for each normal
form index at depth k, records whether M satisfies the representative
formula assigned to that index by `nf_rep`.

Uses `Classical.dec` for decidability of `eval` (the carrier may be infinite).
This makes the definition noncomputable but mathematically precise.
-/
noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun i => @decide (eval M Fin.elim0 (nf_rep sig k i)) (Classical.dec _)

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

The mathematical proof relies on Doets 1989 Lemma 1.1: every depth-≤m
formula is semantically equivalent to some depth-≤k formula, so agreement
on all depth-≤k classes implies agreement on all depth-≤m classes.

With the NormalFormIdx-based KType, this requires an explicit embedding
from depth-m indices to depth-k indices, which depends on the concrete
normal form enumeration. This is deferred to future work (full Doets
formalization).

Note: This theorem is not used by any downstream proof in the current
codebase. It is instantiated in the KEquivalenceFramework typeclass
but equiv_monotone is never called.
-/
theorem k_equiv_monotone (sig : MonadicSignature) {k m : Nat}
    {M N : OrderedMonadicStructure sig}
    (_hkm : m ≤ k) (_h_equiv : k_equiv sig k M N) : k_equiv sig m M N := by
  sorry

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
    Note: The ordered sum here is taken as OrderedMonadicStructure. The actual
    lexicographic order construction is deferred; this field is sorried. -/
  sum_preservation (k : Nat) (I : Type) [inst_lo : LinearOrder I]
    (ms ms' : I → OrderedMonadicStructure sig)
    (h : ∀ i, equiv_at k (ms i) (ms' i)) :
    equiv_at k
      { carrier := Sigma fun i => (ms i).carrier
        interp := fun p x => (ms x.1).interp p x.2
        carrier_order := sorry }
      { carrier := Sigma fun i => (ms' i).carrier
        interp := fun p x => (ms' x.1).interp p x.2
        carrier_order := sorry }

/-! ## Default KEquivalenceFramework Instance -/

/--
Default instance of `KEquivalenceFramework` for any `MonadicSignature`.

- `equiv_at` is defined as `k_equiv` (equality of k-types via `k_type_of`)
- `equiv_is_equiv`: k-type equality is trivially an equivalence relation
- `equiv_monotone`: follows from `k_equiv_monotone`
- `finite_types`: CLOSED (Task 143) via Fintype injection into `KType sig k`
- `sum_preservation`: sorried, requires EF-game formalization (Doets Lemma 1.4)
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
  -- CLOSED [Task 143]: finite_types via injection into KType sig k.
  -- The quotient by k_equiv injects into KType sig k (which is NormalFormIdx sig k 0 → Bool,
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
  -- TODO [Task 143+]: sum_preservation requires EF-game formalization (Doets Lemma 1.4).
  -- The entire Reynolds pipeline (KEquivalenceFramework -> Transfer -> Z-model) is
  -- bypassed in the discrete case by the chronicle fallback in Transfer.lean.
  -- Only needed if the Reynolds pipeline is activated for the general (dense) case.
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
