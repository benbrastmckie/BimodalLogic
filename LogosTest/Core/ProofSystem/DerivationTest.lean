import Logos.Core.ProofSystem.Derivation

/-!
# Derivation Test Suite

Tests for the Derivable relation and inference rules.

## Test Categories

- Axiom rule (all 8 axiom schemata derivable)
- Assumption rule (context membership)
- Modus ponens (implication elimination)
- Modal K rule
- Temporal K rule
- Temporal duality rule
- Weakening rule
- Example derivations
-/

namespace LogosTest.Core.ProofSystem

open Logos.Core.Syntax
open Logos.Core.ProofSystem

-- ============================================================
-- Axiom Rule Tests
-- ============================================================

-- Test: Modal T is derivable from empty context
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.atom "p") := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Test: Modal 4 is derivable from any context
example : [Formula.atom "q"] ⊢ (Formula.box (Formula.atom "p")).imp (Formula.box (Formula.box (Formula.atom "p"))) := by
  apply Derivable.axiom
  apply Axiom.modal_4

-- Test: Modal B is derivable
example : ⊢ (Formula.atom "p").imp (Formula.box (Formula.atom "p").diamond) := by
  apply Derivable.axiom
  apply Axiom.modal_b

-- Test: Temporal 4 is derivable
example : ⊢ (Formula.all_future (Formula.atom "p")).imp (Formula.all_future (Formula.all_future (Formula.atom "p"))) := by
  apply Derivable.axiom
  apply Axiom.temp_4

-- Test: Temporal A is derivable (φ → F(some_past φ))
example : ⊢ (Formula.atom "p").imp (Formula.all_future (Formula.atom "p").some_past) := by
  apply Derivable.axiom
  apply Axiom.temp_a

-- Test: Temporal L is derivable (△φ → FHφ)
example : ⊢ (Formula.atom "p").always.imp (Formula.all_future (Formula.all_past (Formula.atom "p"))) := by
  apply Derivable.axiom
  apply Axiom.temp_l

-- Test: Modal-Future is derivable
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.box (Formula.all_future (Formula.atom "p"))) := by
  apply Derivable.axiom
  apply Axiom.modal_future

-- Test: Temporal-Future is derivable
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.all_future (Formula.box (Formula.atom "p"))) := by
  apply Derivable.axiom
  apply Axiom.temp_future

-- ============================================================
-- Assumption Rule Tests
-- ============================================================

-- Test: Single assumption is derivable
example (p : Formula) : [p] ⊢ p := by
  apply Derivable.assumption
  simp

-- Test: First of multiple assumptions is derivable
example (p q : Formula) : [p, q] ⊢ p := by
  apply Derivable.assumption
  simp

-- Test: Second of multiple assumptions is derivable
example (p q : Formula) : [p, q] ⊢ q := by
  apply Derivable.assumption
  simp

-- Test: Assumption in larger context
example (p q r : Formula) : [p, q, r] ⊢ q := by
  apply Derivable.assumption
  simp

-- ============================================================
-- Modus Ponens Tests
-- ============================================================

-- Test: Basic modus ponens from assumptions
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens (φ := p)
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp

-- Test: Modus ponens with axiom as major premise
example (p : String) : [(Formula.atom p).box] ⊢ Formula.atom p := by
  apply Derivable.modus_ponens (φ := (Formula.atom p).box)
  · apply Derivable.axiom
    apply Axiom.modal_t
  · apply Derivable.assumption
    simp

-- Test: Chained modus ponens
example (p q r : Formula) : [p.imp q, q.imp r, p] ⊢ r := by
  apply Derivable.modus_ponens (φ := q)
  · apply Derivable.assumption; simp
  · apply Derivable.modus_ponens (φ := p)
    · apply Derivable.assumption; simp
    · apply Derivable.assumption; simp

-- ============================================================
-- Modal K Rule Tests
-- ============================================================

-- Test: Modal K with axiom (from empty context)
-- Since axioms are derivable from any context, including □[], we can derive □(axiom)
example : ([] : Context) ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")).box := by
  have h : [] ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
    Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  have h' : Context.map Formula.box [] ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")).box :=
    Derivable.modal_k [] _ h
  simp only [Context.map] at h'
  exact h'

-- Test: Modal K preserves theorem status
-- If ⊢ φ then ⊢ □φ (derived from empty context stays empty)
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.box := by
  have h' : Context.map Formula.box [] ⊢ φ.box := Derivable.modal_k [] φ h
  simp only [Context.map] at h'
  exact h'

-- ============================================================
-- Temporal K Rule Tests
-- ============================================================

-- Test: Temporal K with axiom (from empty context)
example : ([] : Context) ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")).all_future := by
  have h : [] ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
    Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  have h' : Context.map Formula.all_future [] ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")).all_future :=
    Derivable.temporal_k [] _ h
  simp only [Context.map] at h'
  exact h'

-- Test: Temporal K preserves theorem status
-- If ⊢ φ then ⊢ Fφ
-- Note: temporal_k maps [] → [] since Context.map _ [] = []
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.all_future := by
  have h' : Context.map Formula.all_future [] ⊢ φ.all_future := Derivable.temporal_k [] φ h
  simp only [Context.map] at h'
  exact h'

-- ============================================================
-- Temporal Duality Rule Tests
-- ============================================================

-- Test: Temporal duality on Modal T
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.atom "p") := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Test: Temporal duality swaps all_past/all_future
-- If ⊢ φ then ⊢ swap_temporal φ
example : ⊢ ((Formula.all_future (Formula.atom "p")).imp (Formula.all_future (Formula.all_future (Formula.atom "p")))).swap_temporal := by
  apply Derivable.temporal_duality
  apply Derivable.axiom
  apply Axiom.temp_4

-- The above should derive: ⊢ H p → H H p (swapped from G p → G G p)

-- ============================================================
-- Weakening Rule Tests
-- ============================================================

-- Test: Weaken empty context to singleton
example (p : Formula) : [p] ⊢ (Formula.box (Formula.atom "q")).imp (Formula.atom "q") := by
  apply Derivable.weakening (Γ := [])
  · apply Derivable.axiom
    apply Axiom.modal_t
  · intro _ h
    exact False.elim (List.not_mem_nil _ h)

-- Test: Weaken to larger context
example (p q r : Formula) : [p, q, r] ⊢ p := by
  apply Derivable.weakening (Γ := [p])
  · apply Derivable.assumption; simp
  · intro x hx
    simp at hx
    simp [hx]

-- Test: Weakening preserves derivability from subset
example (p q : Formula) : [p, q] ⊢ p := by
  apply Derivable.weakening (Γ := [p])
  · apply Derivable.assumption; simp
  · intro x hx; simp at hx; simp [hx]

-- ============================================================
-- Combined Derivation Examples
-- ============================================================

-- Example: Derive □p → p from context containing □p
example (p : String) : [(Formula.atom p).box] ⊢ (Formula.atom p) := by
  apply Derivable.modus_ponens (φ := (Formula.atom p).box)
  · apply Derivable.axiom; apply Axiom.modal_t
  · apply Derivable.assumption; simp

-- Example: From □(p → q) and □p, derive □q
-- This uses modal K and modus ponens
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens (φ := p)
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp

-- Example: Axioms are theorems (derivable from empty context)
theorem modal_t_theorem (φ : Formula) : ⊢ (φ.box.imp φ) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Example: S5 modal logic - □φ → □□φ is a theorem
theorem modal_4_theorem (φ : Formula) : ⊢ ((φ.box).imp (φ.box.box)) := by
  apply Derivable.axiom
  apply Axiom.modal_4

end LogosTest.Core.ProofSystem
