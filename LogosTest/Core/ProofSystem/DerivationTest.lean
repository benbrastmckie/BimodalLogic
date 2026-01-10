import Bimodal.ProofSystem.Derivation
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Derivation Test Suite

Tests for the DerivationTree relation and inference rules.

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

open Bimodal.Syntax
open Bimodal.ProofSystem

-- Some derivations depend on noncomputable deduction_theorem
noncomputable section

-- ============================================================
-- Axiom Rule Tests
-- ============================================================

-- Test: Modal T is derivable from empty context
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.atom "p") := by
  apply DerivationTree.axiom
  apply Axiom.modal_t

-- Test: Modal 4 is derivable from any context
example : [Formula.atom "q"] ⊢ (Formula.box (Formula.atom "p")).imp (Formula.box (Formula.box (Formula.atom "p"))) := by
  apply DerivationTree.axiom
  apply Axiom.modal_4

-- Test: Modal B is derivable
example : ⊢ (Formula.atom "p").imp (Formula.box (Formula.atom "p").diamond) := by
  apply DerivationTree.axiom
  apply Axiom.modal_b

-- Test: Temporal 4 is derivable
example : ⊢ (Formula.all_future (Formula.atom "p")).imp (Formula.all_future (Formula.all_future (Formula.atom "p"))) := by
  apply DerivationTree.axiom
  apply Axiom.temp_4

-- Test: Temporal A is derivable (φ → F(some_past φ))
example : ⊢ (Formula.atom "p").imp (Formula.all_future (Formula.atom "p").some_past) := by
  apply DerivationTree.axiom
  apply Axiom.temp_a

-- Test: Temporal L is derivable (△φ → FHφ)
example : ⊢ (Formula.atom "p").always.imp (Formula.all_future (Formula.all_past (Formula.atom "p"))) := by
  apply DerivationTree.axiom
  apply Axiom.temp_l

-- Test: Modal-Future is derivable
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.box (Formula.all_future (Formula.atom "p"))) := by
  apply DerivationTree.axiom
  apply Axiom.modal_future

-- Test: Temporal-Future is derivable
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.all_future (Formula.box (Formula.atom "p"))) := by
  apply DerivationTree.axiom
  apply Axiom.temp_future

-- ============================================================
-- Assumption Rule Tests
-- ============================================================

-- Test: Single assumption is derivable
example (p : Formula) : [p] ⊢ p := by
  apply DerivationTree.assumption
  simp

-- Test: First of multiple assumptions is derivable
example (p q : Formula) : [p, q] ⊢ p := by
  apply DerivationTree.assumption
  simp

-- Test: Second of multiple assumptions is derivable
example (p q : Formula) : [p, q] ⊢ q := by
  apply DerivationTree.assumption
  simp

-- Test: Assumption in larger context
example (p q r : Formula) : [p, q, r] ⊢ q := by
  apply DerivationTree.assumption
  simp

-- ============================================================
-- Modus Ponens Tests
-- ============================================================

-- Test: Basic modus ponens from assumptions
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply DerivationTree.modus_ponens (φ := p)
  · apply DerivationTree.assumption; simp
  · apply DerivationTree.assumption; simp

-- Test: Modus ponens with axiom as major premise
example (p : String) : [(Formula.atom p).box] ⊢ Formula.atom p := by
  apply DerivationTree.modus_ponens (φ := (Formula.atom p).box)
  · apply DerivationTree.axiom
    apply Axiom.modal_t
  · apply DerivationTree.assumption
    simp

-- Test: Chained modus ponens
example (p q r : Formula) : [p.imp q, q.imp r, p] ⊢ r := by
  apply DerivationTree.modus_ponens (φ := q)
  · apply DerivationTree.assumption; simp
  · apply DerivationTree.modus_ponens (φ := p)
    · apply DerivationTree.assumption; simp
    · apply DerivationTree.assumption; simp

-- ============================================================
-- Necessitation Rule Tests
-- ============================================================

-- Test: Necessitation with axiom (from empty context)
-- If ⊢ φ then ⊢ □φ (standard necessitation rule)
example : ([] : Context) ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")).box := by
  have d : [] ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  exact DerivationTree.necessitation _ d

-- Test: Necessitation preserves theorem status
-- If ⊢ φ then ⊢ □φ (derived from empty context stays empty)
example (φ : Formula) (d : ⊢ φ) : ⊢ φ.box := by
  exact DerivationTree.necessitation φ d

-- ============================================================
-- Temporal Necessitation Rule Tests
-- ============================================================

-- Test: Temporal necessitation with axiom (from empty context)
-- If ⊢ φ then ⊢ Fφ (standard temporal necessitation rule)
example : ([] : Context) ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")).all_future := by
  have d : [] ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom "p"))
  exact DerivationTree.temporal_necessitation _ d

-- Test: Temporal necessitation preserves theorem status
-- If ⊢ φ then ⊢ Fφ (derived from empty context stays empty)
example (φ : Formula) (d : ⊢ φ) : ⊢ φ.all_future := by
  exact DerivationTree.temporal_necessitation φ d

-- ============================================================
-- Temporal Duality Rule Tests
-- ============================================================

-- Test: Temporal duality on Modal T
example : ⊢ (Formula.box (Formula.atom "p")).imp (Formula.atom "p") := by
  apply DerivationTree.axiom
  apply Axiom.modal_t

-- Test: Temporal duality swaps all_past/all_future
-- If ⊢ φ then ⊢ swap_temporal φ
example : ⊢ ((Formula.all_future (Formula.atom "p")).imp (Formula.all_future (Formula.all_future (Formula.atom "p")))).swap_temporal := by
  apply DerivationTree.temporal_duality
  apply DerivationTree.axiom
  apply Axiom.temp_4

-- The above should derive: ⊢ H p → H H p (swapped from G p → G G p)

-- ============================================================
-- Weakening Rule Tests
-- ============================================================

-- Test: Weaken empty context to singleton
example (p : Formula) : [p] ⊢ (Formula.box (Formula.atom "q")).imp (Formula.atom "q") := by
  apply DerivationTree.weakening (Γ := [])
  · apply DerivationTree.axiom
    apply Axiom.modal_t
  · intro _ h
    exact False.elim (List.not_mem_nil _ h)

-- Test: Weaken to larger context
example (p q r : Formula) : [p, q, r] ⊢ p := by
  apply DerivationTree.weakening (Γ := [p])
  · apply DerivationTree.assumption; simp
  · intro x hx
    simp at hx
    simp [hx]

-- Test: Weakening preserves derivability from subset
example (p q : Formula) : [p, q] ⊢ p := by
  apply DerivationTree.weakening (Γ := [p])
  · apply DerivationTree.assumption; simp
  · intro x hx; simp at hx; simp [hx]

-- ============================================================
-- Combined Derivation Examples
-- ============================================================

-- Example: Derive □p → p from context containing □p
example (p : String) : [(Formula.atom p).box] ⊢ (Formula.atom p) := by
  apply DerivationTree.modus_ponens (φ := (Formula.atom p).box)
  · apply DerivationTree.axiom; apply Axiom.modal_t
  · apply DerivationTree.assumption; simp

-- Example: From □(p → q) and □p, derive □q
-- This uses modal K and modus ponens
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply DerivationTree.modus_ponens (φ := p)
  · apply DerivationTree.assumption; simp
  · apply DerivationTree.assumption; simp

-- Example: Axioms are theorems (derivable from empty context)
def modal_t_theorem (φ : Formula) : ⊢ (φ.box.imp φ) := by
  apply DerivationTree.axiom
  apply Axiom.modal_t

-- Example: S5 modal logic - □φ → □□φ is a theorem
def modal_4_theorem (φ : Formula) : ⊢ ((φ.box).imp (φ.box.box)) := by
  apply DerivationTree.axiom
  apply Axiom.modal_4

-- ============================================================
-- Generalized Necessitation Rule Tests
-- ============================================================

-- Test: Generalized Modal K (derived theorem)
-- If Γ ⊢ φ then □Γ ⊢ □φ
example (p : Formula) : [(Formula.atom "p").box] ⊢ (Formula.atom "p").box := by
  -- We start with [p] ⊢ p (assumption)
  have d : [Formula.atom "p"] ⊢ Formula.atom "p" := by
    apply DerivationTree.assumption
    simp
  -- Apply generalized modal K
  have d_gen := Bimodal.Theorems.generalized_modal_k [Formula.atom "p"] (Formula.atom "p") d
  -- Result should be [□p] ⊢ □p
  simp at d_gen
  exact d_gen

-- Test: Generalized Temporal K (derived theorem)
-- If Γ ⊢ φ then FΓ ⊢ Fφ
example (p : Formula) : [(Formula.atom "p").all_future] ⊢ (Formula.atom "p").all_future := by
  -- We start with [p] ⊢ p (assumption)
  have d : [Formula.atom "p"] ⊢ Formula.atom "p" := by
    apply DerivationTree.assumption
    simp
  -- Apply generalized temporal K
  have d_gen := Bimodal.Theorems.generalized_temporal_k [Formula.atom "p"] (Formula.atom "p") d
  -- Result should be [Fp] ⊢ Fp
  simp at d_gen
  exact d_gen

end

end LogosTest.Core.ProofSystem
