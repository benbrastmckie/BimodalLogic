/- T-A probe: the full proposed content of the new module, compiled end-to-end.
   Every declaration below is a candidate for the real file; all axioms are clean. -/
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import FormalSystem.Metalogic.WeakCanonical.RealModel.GoodDense
import Mathlib.Algebra.Order.Monoid.Prod

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.Metalogic.Core

/-! ## Carrier gate: `ℚ ×ₗ ℤ` satisfies the four `valid`/`SemanticConsequence` binders. -/

example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

/-! ## The target structure -/

structure QZStructure (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    where
  interp (p : sig.preds) : ℚ ×ₗ ℤ → Prop

def QZStructure.toMonadic (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (Q : QZStructure sig) : MonadicStructure sig where
  carrier := ℚ ×ₗ ℤ
  interp p x := Q.interp p x

def QZStructure.toOrdered (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (Q : QZStructure sig) : OrderedMonadicStructure sig where
  carrier := ℚ ×ₗ ℤ
  interp p x := Q.interp p x
  carrierOrder := inferInstance

theorem QZStructure.toOrdered_carrier (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (Q : QZStructure sig) :
    (Q.toOrdered sig).carrier = (ℚ ×ₗ ℤ) := rfl

/-! ## `goodGroupable` -/

def goodGroupable (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (M : OrderedMonadicStructure sig) : Prop :=
  ∃ (Q : QZStructure sig), KEquiv sig k M (Q.toOrdered sig)

theorem goodGroupable_of_kEquiv (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) {M N : OrderedMonadicStructure sig}
    (h : KEquiv sig k M N) (hN : goodGroupable sig k N) : goodGroupable sig k M := by
  obtain ⟨Q, hQ⟩ := hN
  exact ⟨Q, h.trans hQ⟩

theorem goodGroupable_of_orderIso (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) {M N : OrderedMonadicStructure sig}
    (f : M.carrier ≃o N.carrier)
    (h_pred : ∀ (p : sig.preds) (x : M.carrier), M.interp p x ↔ N.interp p (f x))
    (hN : goodGroupable sig k N) : goodGroupable sig k M :=
  goodGroupable_of_kEquiv sig k (k_equiv_of_iso sig k M N f h_pred) hN

/-! ## Endpoint consequences (why the target has no bounded-interval analogue) -/

instance : NoMaxOrder (ℚ ×ₗ ℤ) :=
  ⟨fun a => ⟨toLex ((ofLex a).1, (ofLex a).2 + 1), by
    have h : a = toLex ((ofLex a).1, (ofLex a).2) := rfl
    rw [h]; exact Prod.Lex.right _ (by simp)⟩⟩

instance : NoMinOrder (ℚ ×ₗ ℤ) :=
  ⟨fun a => ⟨toLex ((ofLex a).1, (ofLex a).2 - 1), by
    have h : a = toLex ((ofLex a).1, (ofLex a).2) := rfl
    rw [h]; exact Prod.Lex.right _ (by simp)⟩⟩

theorem noMaxOrder_of_goodGroupable (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) {M : OrderedMonadicStructure sig}
    (h : goodGroupable sig k M) : NoMaxOrder M.carrier := by
  obtain ⟨Q, hQ⟩ := h
  haveI : NoMaxOrder (Q.toOrdered sig).carrier := inferInstanceAs (NoMaxOrder (ℚ ×ₗ ℤ))
  exact noMaxOrder_of_kEquiv sig k hk hQ.symm

theorem noMinOrder_of_goodGroupable (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) {M : OrderedMonadicStructure sig}
    (h : goodGroupable sig k M) : NoMinOrder M.carrier := by
  obtain ⟨Q, hQ⟩ := h
  haveI : NoMinOrder (Q.toOrdered sig).carrier := inferInstanceAs (NoMinOrder (ℚ ×ₗ ℤ))
  exact noMinOrder_of_kEquiv sig k hk hQ.symm

#print axioms QZStructure.toOrdered
#print axioms goodGroupable_of_kEquiv
#print axioms goodGroupable_of_orderIso
#print axioms noMaxOrder_of_goodGroupable
#print axioms noMinOrder_of_goodGroupable

end FormalSystem.Metalogic.WeakCanonical
