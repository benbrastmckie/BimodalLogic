/-
T-B research probe 1: statement elaboration gate + target-side plumbing.

Part A: every statement of the proposed T-B decomposition elaborates as a `Prop`
        against the live codebase (no sorries needed: `def ... : Prop`).
Part B: the Sigma-constant-family / Prod.Lex order isomorphism, fully proved —
        the bridge from `orderedSum sig ℚ (fun _ => fiber)` to the `ℚ ×ₗ ℤ` carrier
        that `QZStructure` demands.
-/
import FormalSystem.Metalogic.WeakCanonical.GroupModel.GoodGroupable
import FormalSystem.Metalogic.WeakCanonical.MixedSum
import FormalSystem.Metalogic.WeakCanonical.OrderedSum
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge
import Mathlib.Order.CountableDenseLinearOrder

namespace FormalSystem.Metalogic.WeakCanonical.TBProbe

open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core

/-! ## Part A: statement suite -/

/-- The companion lemma, general form (report 02 §4 verbatim, at the fixed carrier). -/
def CompanionGeneral : Prop :=
  ∀ (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (M : OrderedMonadicStructure sig) [Countable M.carrier]
    [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier] [Nonempty M.carrier],
    goodGroupable sig k M

/-- The chronicle instantiation T-C consumes (Base analogue of `limitdom_is_good`). -/
def CompanionChronicle : Prop :=
  ∀ {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (_h_box : Formula.box FormalSystem.Metalogic.BXCanonical.Chronicle.nextTop ∈ A)
    (φ : Formula) (k : Nat),
    goodGroupable (mkSigFrom φ) k (limitdomMonadicStructure A h_mcs φ)

/-- Sub-phase (2): monochromatic discrete completeness at depth k, no-endpoint variant.
Two structures with matching constant interpretations, both countable discrete
unbounded, are k-equivalent for every k. -/
def MonoDiscreteNoEnds : Prop :=
  ∀ (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (M N : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [Nonempty M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [Nonempty N.carrier],
    (∀ p : sig.preds,
      ((∀ x, M.interp p x) ∧ (∀ y, N.interp p y)) ∨
      ((∀ x, ¬ M.interp p x) ∧ (∀ y, ¬ N.interp p y))) →
    KEquiv sig k M N

/-- Sub-phase (2), min-no-max variant (the `ω ≡ⁿ ω + ζ·L` family, Doets 1.0.3(ii)). -/
def MonoDiscreteMinNoMax : Prop :=
  ∀ (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (M N : OrderedMonadicStructure sig)
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [Nonempty M.carrier]
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [Nonempty N.carrier],
    (∃ m : M.carrier, ∀ x, m ≤ x) → (∃ n : N.carrier, ∀ y, n ≤ y) →
    (∀ p : sig.preds,
      ((∀ x, M.interp p x) ∧ (∀ y, N.interp p y)) ∨
      ((∀ x, ¬ M.interp p x) ∧ (∀ y, ¬ N.interp p y))) →
    KEquiv sig k M N

/-- Phase 0 (S2): block decomposition of a countable discrete unbounded structure —
an index order `I` and per-index colored-ℤ fibers whose ordered sum is
order-isomorphic (predicate-preserving) to `M`. Fibers are packaged as structures
with carrier ℤ so the target-side reassembly is literal. -/
def BlockDecomposition : Prop :=
  ∀ (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) [Countable M.carrier]
    [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
    [NoMinOrder M.carrier] [Nonempty M.carrier],
    ∃ (I : Type) (_ : LinearOrder I) (_ : Countable I) (_ : Nonempty I)
      (c : I → sig.preds → ℤ → Prop),
      ∃ f : M.carrier ≃o (orderedSum sig I (fun i =>
              { carrier := ℤ
                interp := fun p z => c i p z
                carrierOrder := inferInstance : OrderedMonadicStructure sig })).carrier,
        ∀ (p : sig.preds) (x : M.carrier), M.interp p x ↔ c (f x).1 p (f x).2

/-- Every nonempty countable linear order is a condensation of ℚ: a partition of ℚ
into nonempty convex pieces, indexed by `I`, ordered as `I`. -/
def CondensationOfQ : Prop :=
  ∀ (I : Type) [LinearOrder I] [Countable I] [Nonempty I],
    ∃ C : I → Set ℚ,
      (∀ i, (C i).Nonempty ∧ (C i).OrdConnected) ∧
      (∀ q : ℚ, ∃! i, q ∈ C i) ∧
      (∀ i j : I, i < j → ∀ x ∈ C i, ∀ y ∈ C j, x < y)

/-- The tail-absorption lemma (per-block inflation core): appending a suitably
colored `ℚ ×ₗ ℤ` to an ω-shaped colored structure is invisible at depth k. Stated
abstractly: for every colored structure `B` whose carrier is discrete with a least
element and no greatest, there is a coloring `e` of `ℚ ×ₗ ℤ` with
`B ≡ₖ B + (ℚ ×ₗ ℤ, e)` (the sum over `Bool` with `false < true`). -/
def TailAbsorption : Prop :=
  ∀ (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (B : OrderedMonadicStructure sig) [Countable B.carrier]
    [SuccOrder B.carrier] [PredOrder B.carrier] [NoMaxOrder B.carrier]
    [Nonempty B.carrier],
    (∃ m : B.carrier, ∀ x, m ≤ x) →
    ∃ e : sig.preds → ℚ ×ₗ ℤ → Prop,
      KEquiv sig k B
        (orderedSum sig Bool (fun b => if b then
          { carrier := ℚ ×ₗ ℤ
            interp := fun p x => e p x
            carrierOrder := inferInstance : OrderedMonadicStructure sig }
          else B))

/-- Infinite Ramsey for pairs (absent from Mathlib at this pin; to be proved locally). -/
def InfiniteRamseyPairs : Prop :=
  ∀ (C : Type) [Finite C] (c : ℕ → ℕ → C),
    ∃ g : ℕ → ℕ, StrictMono g ∧ ∃ τ : C, ∀ i j : ℕ, i < j → c (g i) (g j) = τ

/-! ## Part B: the Sigma-constant / Prod.Lex bridge, proved -/

/-- A monadic structure on ℤ from a coloring. -/
def zFiber (sig : MonadicSignature) (c : sig.preds → ℤ → Prop) :
    OrderedMonadicStructure sig where
  carrier := ℤ
  interp := fun p z => c p z
  carrierOrder := inferInstance

/-- The ordered sum of constant-carrier-ℤ fibers over ℚ is order-isomorphic to
`ℚ ×ₗ ℤ`. This is the bridge from `orderedSum` to the carrier `QZStructure` fixes. -/
noncomputable def sumQZOrderIso (sig : MonadicSignature)
    (c : ℚ → sig.preds → ℤ → Prop) :
    (orderedSum sig ℚ (fun q => zFiber sig (c q))).carrier ≃o (ℚ ×ₗ ℤ) := by
  refine Equiv.toOrderIso
    { toFun := fun x => toLex (x.1, x.2)
      invFun := fun y => ⟨(ofLex y).1, (ofLex y).2⟩
      left_inv := fun x => rfl
      right_inv := fun y => rfl } ?_ ?_
  · -- monotone forward
    intro x y hxy
    rcases eq_or_lt_of_le hxy with heq | hlt
    · exact le_of_eq (congrArg _ heq)
    · have h : Sigma.Lex (· < ·) (fun _ => (· < ·)) x y := hlt
      cases h with
      | left a b hij => exact le_of_lt (Prod.Lex.left _ _ hij)
      | right a b hab => exact le_of_lt (Prod.Lex.right _ hab)
  · -- monotone backward
    intro x y hxy
    rcases eq_or_lt_of_le hxy with heq | hlt
    · exact le_of_eq (congrArg _ heq)
    · rcases Prod.Lex.lt_iff.mp hlt with h1 | ⟨h1, h2⟩
      · exact le_of_lt (Sigma.Lex.left _ _ h1)
      · refine le_of_lt ?_
        have hgoal : Sigma.Lex (· < ·) (fun _ => (· < ·))
            (⟨(ofLex x).1, (ofLex x).2⟩ :
              (orderedSum sig ℚ (fun q => zFiber sig (c q))).carrier)
            (⟨(ofLex y).1, (ofLex y).2⟩ :
              (orderedSum sig ℚ (fun q => zFiber sig (c q))).carrier) := by
          rw [h1]
          exact Sigma.Lex.right _ _ h2
        exact hgoal

#print axioms sumQZOrderIso
#print axioms FormalSystem.Metalogic.WeakCanonical.kEquiv_orderedSum_of_kEquiv_colour
#print axioms FormalSystem.Metalogic.WeakCanonical.doets_lemma_1_4
#print axioms FormalSystem.Metalogic.WeakCanonical.kEquiv_colourStructure
#print axioms FormalSystem.Metalogic.WeakCanonical.kEquiv_iff_backForth
#print axioms FormalSystem.Metalogic.WeakCanonical.k_equiv_of_iso
#print axioms FormalSystem.Metalogic.WeakCanonical.noMaxOrder_of_kEquiv

end FormalSystem.Metalogic.WeakCanonical.TBProbe
