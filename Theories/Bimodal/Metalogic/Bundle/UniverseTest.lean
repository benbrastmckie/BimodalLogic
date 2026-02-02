import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BMCSTruth
import Bimodal.Metalogic.Bundle.IndexedMCSFamily

/-!
# Universe Polymorphism Test

This file tests the universe instantiation issue in bmcs_valid_implies_valid_Int.
-/

namespace Bimodal.Metalogic.Bundle.UniverseTest

open Bimodal.Syntax
open Bimodal.Metalogic.Bundle

-- Recall the definitions from BMCSTruth.lean:
-- def bmcs_valid (φ : Formula) : Prop :=
--   ∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
--   ∀ (B : BMCS D), ∀ fam ∈ B.families, ∀ t : D, bmcs_truth_at B fam t φ

-- Define Int-specific validity locally for testing
def bmcs_valid_Int' (φ : Formula) : Prop :=
  ∀ (B : BMCS Int), ∀ fam ∈ B.families, ∀ t : Int, bmcs_truth_at B fam t φ

-- Test 1: Direct instantiation - this fails due to universe polymorphism
-- lemma test_instantiation (φ : Formula) (h : bmcs_valid φ) : bmcs_valid_Int' φ := by
--   intro B fam hfam t
--   exact h Int B fam hfam t  -- Error: Type vs Type u_1

-- Solution 1: Define a universe-monomorphic version of bmcs_valid
def bmcs_valid_Type (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  ∀ (B : BMCS D), ∀ fam ∈ B.families, ∀ t : D, bmcs_truth_at B fam t φ

-- This works because Int : Type (which is Type 0)
lemma bmcs_valid_Type_implies_valid_Int (φ : Formula) (h : bmcs_valid_Type φ) : bmcs_valid_Int' φ := by
  intro B fam hfam t
  exact h Int B fam hfam t

-- Solution 2: Use explicit universe with ULift to convert between universes
-- This is more complex but preserves polymorphism

-- Solution 3: Check if we can get from polymorphic to monomorphic
-- This requires bmcs_valid to have a weaker form

-- Actually, the key insight is: bmcs_valid quantifies over Type u for ALL u
-- bmcs_valid_Int is just the special case D = Int
-- The issue is how Type* is elaborated

-- Let's check what happens with explicit universe annotation
universe u

def bmcs_valid_u (φ : Formula) : Prop :=
  ∀ (D : Type u) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  ∀ (B : BMCS D), ∀ fam ∈ B.families, ∀ t : D, bmcs_truth_at B fam t φ

-- Solution 4: The cleanest - redefine bmcs_valid to be universe-monomorphic
-- Since the completeness proof only needs to construct countermodels,
-- and Int suffices for that, we don't actually need the full polymorphism.

-- The proof can work by REPLACING bmcs_valid with a version that
-- quantifies over Type (not Type*), which includes Int.

-- Alternatively, add: bmcs_valid → bmcs_valid_Type as an axiom
-- (mathematically obvious since Type ⊆ Type* in the sense of universes)

-- Solution 5: Actually prove it using the fact that every universe includes Type 0
-- This is the mathematically correct approach but Lean makes it annoying

-- Let's test with explicit lowering
-- axiom valid_lower_universe (φ : Formula) (h : bmcs_valid φ) : bmcs_valid_Type φ

end Bimodal.Metalogic.Bundle.UniverseTest
