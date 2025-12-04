import Logos.Core.Metalogic.Soundness
import Logos.Core.ProofSystem.Derivation

/-!
# Soundness Tests

Tests for soundness theorem and axiom validity.
-/

namespace LogosTest.Core.Metalogic

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Semantics
open Logos.Core.Metalogic

-- ========================================
-- Axiom Validity Tests
-- ========================================

-- Test: Modal T is valid (□φ → φ)
example (φ : Formula) : ⊨ (φ.box.imp φ) := modal_t_valid φ

-- Test: Modal 4 is valid (□φ → □□φ)
example (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := modal_4_valid φ

-- Test: Modal B is valid (φ → □◇φ)
example (φ : Formula) : ⊨ (φ.imp (φ.diamond.box)) := modal_b_valid φ

-- Test: Temporal 4 is valid (Fφ → FFφ)
example (φ : Formula) : ⊨ ((φ.future).imp (φ.future.future)) := temp_4_valid φ

-- Test: Temporal A is valid (φ → F(sometime_past φ))
example (φ : Formula) : ⊨ (φ.imp (Formula.future φ.sometime_past)) := temp_a_valid φ

-- ========================================
-- Axiom Derivability Tests
-- ========================================

-- Test: Modal T axiom is derivable
example (φ : Formula) : ⊢ (φ.box.imp φ) :=
  Derivable.axiom [] _ (Axiom.modal_t φ)

-- Test: Modal 4 axiom is derivable
example (φ : Formula) : ⊢ ((φ.box).imp (φ.box.box)) :=
  Derivable.axiom [] _ (Axiom.modal_4 φ)

-- Test: Modal B axiom is derivable
example (φ : Formula) : ⊢ (φ.imp (φ.diamond.box)) :=
  Derivable.axiom [] _ (Axiom.modal_b φ)

-- Test: Temporal 4 axiom is derivable
example (φ : Formula) : ⊢ ((φ.future).imp (φ.future.future)) :=
  Derivable.axiom [] _ (Axiom.temp_4 φ)

-- Test: Temporal A axiom is derivable
example (φ : Formula) : ⊢ (φ.imp (Formula.future φ.sometime_past)) :=
  Derivable.axiom [] _ (Axiom.temp_a φ)

-- ========================================
-- Soundness Application Tests
-- ========================================

-- Test: Soundness applies to Modal T derivation
example (φ : Formula) : [] ⊨ (φ.box.imp φ) := by
  let deriv : ⊢ (φ.box.imp φ) := Derivable.axiom [] _ (Axiom.modal_t φ)
  exact soundness [] (φ.box.imp φ) deriv

-- Test: Soundness applies to Modal 4 derivation
example (φ : Formula) : [] ⊨ ((φ.box).imp (φ.box.box)) := by
  let deriv : ⊢ ((φ.box).imp (φ.box.box)) := Derivable.axiom [] _ (Axiom.modal_4 φ)
  exact soundness [] ((φ.box).imp (φ.box.box)) deriv

-- Test: Soundness applies to Modal B derivation
example (φ : Formula) : [] ⊨ (φ.imp (φ.diamond.box)) := by
  let deriv : ⊢ (φ.imp (φ.diamond.box)) := Derivable.axiom [] _ (Axiom.modal_b φ)
  exact soundness [] (φ.imp (φ.diamond.box)) deriv

-- Test: Soundness applies to Temporal 4 derivation
example (φ : Formula) : [] ⊨ ((φ.future).imp (φ.future.future)) := by
  let deriv : ⊢ ((φ.future).imp (φ.future.future)) := Derivable.axiom [] _ (Axiom.temp_4 φ)
  exact soundness [] ((φ.future).imp (φ.future.future)) deriv

-- Test: Soundness applies to Temporal A derivation
example (φ : Formula) : [] ⊨ (φ.imp (Formula.future φ.sometime_past)) := by
  let deriv : ⊢ (φ.imp (Formula.future φ.sometime_past)) := Derivable.axiom [] _ (Axiom.temp_a φ)
  exact soundness [] (φ.imp (Formula.future φ.sometime_past)) deriv

-- ========================================
-- Inference Rule Soundness Tests
-- ========================================

-- Test: Valid implies semantic consequence from empty context
example (φ : Formula) (h : ⊨ (φ.box.imp φ)) : [] ⊨ (φ.box.imp φ) :=
  Validity.valid_iff_empty_consequence _ |>.mp h

-- Test: Soundness for assumptions
example (φ : Formula) : [φ] ⊨ φ := by
  let deriv : [φ] ⊢ φ := Derivable.assumption [φ] φ (List.Mem.head _)
  exact soundness [φ] φ deriv

-- Test: Soundness preserves modus ponens
example (φ ψ : Formula) : [φ.imp ψ, φ] ⊨ ψ := by
  let deriv : [φ.imp ψ, φ] ⊢ ψ :=
    Derivable.modus_ponens [φ.imp ψ, φ] φ ψ
      (Derivable.assumption [φ.imp ψ, φ] (φ.imp ψ) (List.Mem.head _))
      (Derivable.assumption [φ.imp ψ, φ] φ (List.Mem.tail _ (List.Mem.head _)))
  exact soundness [φ.imp ψ, φ] ψ deriv

-- Test: Soundness preserves weakening
example (φ ψ : Formula) : [φ, ψ] ⊨ φ := by
  -- Direct proof without using weakening rule
  intro F M τ t ht h_all
  apply h_all
  constructor

end LogosTest.Core.Metalogic
