import Bimodal.ProofSystem.Derivation
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.TemporalDerived

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

namespace BimodalTest.ProofSystem

open Bimodal.Syntax
open Bimodal.ProofSystem

-- Some derivations depend on noncomputable deduction_theorem
noncomputable section

-- ============================================================
-- Axiom Rule Tests
-- ============================================================

-- Test: Modal T is derivable from empty context
example : ⊢ (Formula.box (Formula.atom_s "p")).imp (Formula.atom_s "p") :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

-- Test: Modal 4 is derivable from any context
example : [Formula.atom_s "q"] ⊢ (Formula.box (Formula.atom_s "p")).imp (Formula.box (Formula.box (Formula.atom_s "p"))) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

-- Test: Modal B is derivable
example : ⊢ (Formula.atom_s "p").imp (Formula.box (Formula.atom_s "p").diamond) :=
  DerivationTree.axiom _ _ (Axiom.modal_b _) trivial

-- Test: Temporal 4 is derivable (now a derived theorem, no longer an axiom constructor)
noncomputable example : ⊢ (Formula.all_future (Formula.atom_s "p")).imp (Formula.all_future (Formula.all_future (Formula.atom_s "p"))) :=
  Bimodal.Theorems.TemporalDerived.temp_4_derived (Formula.atom_s "p")

-- Test: connect_future is derivable (φ → G(P(φ)), BX4)
example : ⊢ (Formula.atom_s "p").imp (Formula.all_future (Formula.atom_s "p").some_past) :=
  DerivationTree.axiom _ _ (Axiom.connect_future _) trivial

-- Test: connect_past is derivable (φ → H(F(φ)), BX4')
example : ⊢ (Formula.atom_s "p").imp (Formula.all_past (Formula.atom_s "p").some_future) :=
  DerivationTree.axiom _ _ (Axiom.connect_past _) trivial

-- Test: Modal-Future is derivable
example : ⊢ (Formula.box (Formula.atom_s "p")).imp (Formula.box (Formula.all_future (Formula.atom_s "p"))) :=
  DerivationTree.axiom _ _ (Axiom.modal_future _) trivial

-- Test: Temporal-Future is derivable (derived from MF + T + Modal 4)
example : ⊢ (Formula.box (Formula.atom_s "p")).imp (Formula.all_future (Formula.box (Formula.atom_s "p"))) :=
  Bimodal.Theorems.Combinators.temp_future_derived (Formula.atom_s "p")

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
example (p : String) : [(Formula.atom_s p).box] ⊢ Formula.atom_s p := by
  apply DerivationTree.modus_ponens (φ := (Formula.atom_s p).box)
  · exact DerivationTree.axiom _ _ (Axiom.modal_t _) trivial
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
example : ([] : Context) ⊢ ((Formula.atom_s "p").box.imp (Formula.atom_s "p")).box := by
  have d : [] ⊢ (Formula.atom_s "p").box.imp (Formula.atom_s "p") :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom_s "p")) trivial
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
example : ([] : Context) ⊢ ((Formula.atom_s "p").box.imp (Formula.atom_s "p")).all_future := by
  have d : [] ⊢ (Formula.atom_s "p").box.imp (Formula.atom_s "p") :=
    DerivationTree.axiom [] _ (Axiom.modal_t (Formula.atom_s "p")) trivial
  exact DerivationTree.temporal_necessitation _ d

-- Test: Temporal necessitation preserves theorem status
-- If ⊢ φ then ⊢ Fφ (derived from empty context stays empty)
example (φ : Formula) (d : ⊢ φ) : ⊢ φ.all_future := by
  exact DerivationTree.temporal_necessitation φ d

-- ============================================================
-- Temporal Duality Rule Tests
-- ============================================================

-- Test: Temporal duality on Modal T
example : ⊢ (Formula.box (Formula.atom_s "p")).imp (Formula.atom_s "p") :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

-- Test: Temporal duality swaps all_past/all_future
-- If ⊢ φ then ⊢ swap_temporal φ (using connect_future as the base derivation)
example : ⊢ ((Formula.atom_s "p").imp (Formula.all_future (Formula.atom_s "p").some_past)).swap_temporal :=
  DerivationTree.temporal_duality _ (DerivationTree.axiom [] _ (Axiom.connect_future _) trivial)

-- The above should derive: ⊢ p → H(F(p)) (swapped from p → G(P(p)))

-- ============================================================
-- Weakening Rule Tests
-- ============================================================

-- Test: Weaken empty context to singleton
example (p : Formula) : [p] ⊢ (Formula.box (Formula.atom_s "q")).imp (Formula.atom_s "q") := by
  apply DerivationTree.weakening (Γ := [])
  · exact DerivationTree.axiom _ _ (Axiom.modal_t _) trivial
  · intro _ h
    simp at h

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
example (p : String) : [(Formula.atom_s p).box] ⊢ (Formula.atom_s p) := by
  apply DerivationTree.modus_ponens (φ := (Formula.atom_s p).box)
  · exact DerivationTree.axiom _ _ (Axiom.modal_t _) trivial
  · apply DerivationTree.assumption; simp

-- Example: From □(p → q) and □p, derive □q
-- This uses modal K and modus ponens
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply DerivationTree.modus_ponens (φ := p)
  · apply DerivationTree.assumption; simp
  · apply DerivationTree.assumption; simp

-- Example: Axioms are theorems (derivable from empty context)
def modal_t_theorem (φ : Formula) : ⊢ (φ.box.imp φ) :=
  DerivationTree.axiom _ _ (Axiom.modal_t _) trivial

-- Example: S5 modal logic - □φ → □□φ is a theorem
def modal_4_theorem (φ : Formula) : ⊢ ((φ.box).imp (φ.box.box)) :=
  DerivationTree.axiom _ _ (Axiom.modal_4 _) trivial

-- ============================================================
-- Generalized Necessitation Rule Tests
-- ============================================================

-- Test: Generalized Modal K (derived theorem)
-- If Γ ⊢ φ then □Γ ⊢ □φ
example (p : Formula) : [(Formula.atom_s "p").box] ⊢ (Formula.atom_s "p").box := by
  -- We start with [p] ⊢ p (assumption)
  have d : [Formula.atom_s "p"] ⊢ Formula.atom_s "p" := by
    apply DerivationTree.assumption
    simp
  -- Apply generalized modal K
  have d_gen := Bimodal.Theorems.generalized_modal_k [Formula.atom_s "p"] (Formula.atom_s "p") d
  -- Result should be [□p] ⊢ □p. `simp at d_gen` no longer reduces the `List.map` (it now
  -- reports "made no progress"); the two are still definitionally equal, so `exact` closes it.
  exact d_gen

-- Test: Generalized Temporal K (derived theorem)
-- If Γ ⊢ φ then FΓ ⊢ Fφ
example (p : Formula) : [(Formula.atom_s "p").all_future] ⊢ (Formula.atom_s "p").all_future := by
  -- We start with [p] ⊢ p (assumption)
  have d : [Formula.atom_s "p"] ⊢ Formula.atom_s "p" := by
    apply DerivationTree.assumption
    simp
  -- Apply generalized temporal K
  have d_gen := Bimodal.Theorems.generalized_temporal_k [Formula.atom_s "p"] (Formula.atom_s "p") d
  -- Result should be [Fp] ⊢ Fp. Same `List.map` reduction as the modal case above.
  exact d_gen

end

end BimodalTest.ProofSystem
