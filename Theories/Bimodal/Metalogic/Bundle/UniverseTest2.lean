import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.BMCSTruth

/-!
# Deep Universe Analysis

Exploring the exact nature of the universe polymorphism issue.
-/

namespace Bimodal.Metalogic.Bundle.UniverseTest2

open Bimodal.Syntax
open Bimodal.Metalogic.Bundle

/-!
## Understanding Type*

In Lean 4:
- `Type` = `Type 0`
- `Type*` elaborates to `Type u` where `u` is a fresh universe metavariable
- When you write `∀ (D : Type*), P D`, Lean creates `∀ (D : Type u_1), P D`
  where `u_1` is inferred from context

The issue: `bmcs_valid φ` means `∀ (D : Type u) [...]...` for some fixed `u`
But the INTENTION is "for all types in all universes".

## Key Question: Does bmcs_valid NEED universe polymorphism?

Looking at the usage:
1. Weak completeness: `bmcs_valid φ → derivable φ`
   - The contrapositive is: `¬derivable φ → ¬bmcs_valid φ`
   - To prove ¬bmcs_valid, we construct a countermodel at Int
   - So we only NEED `bmcs_valid_Int φ → derivable φ` for completeness!

2. Strong completeness: similar reasoning

So the theorem we actually care about is:
  `bmcs_valid_Int φ → derivable φ`

NOT:
  `bmcs_valid φ → derivable φ`

The polymorphic version is STRONGER but not necessary for the main result.
-/

-- Re-examine: do we even need bmcs_valid → bmcs_valid_Int?
-- The proof structure in Completeness.lean:

-- bmcs_weak_completeness : bmcs_valid φ → Nonempty (DerivationTree [] φ)
--   uses: bmcs_not_valid_of_not_derivable (contrapositive)
--     which uses: bmcs_valid_implies_valid_Int + bmcs_not_valid_Int_of_not_derivable

-- But bmcs_not_valid_Int_of_not_derivable can be stated directly:
--   ¬Nonempty (DerivationTree [] φ) → ¬bmcs_valid_Int φ

-- And we could have:
--   bmcs_weak_completeness_Int : bmcs_valid_Int φ → Nonempty (DerivationTree [] φ)
-- by contraposition of bmcs_not_valid_Int_of_not_derivable

-- The polymorphic bmcs_valid is only needed if we want the theorem stated
-- for ALL types, not just Int.

-- SOLUTION: Restructure to use bmcs_valid_Int as the primary notion

-- Or alternatively: prove that for Formula (a Type 0 object),
-- validity only depends on Type 0 domains.

-- This is actually false in general! A formula could distinguish between
-- domains of different cardinalities. But for propositional logic...
-- wait, this is propositional + modal + temporal logic. The domain D
-- is just the time domain, not the domain of quantification.

-- Since Formula doesn't have quantifiers over D, the choice of D
-- only affects what temporal points exist. But the formula itself
-- is the same regardless of D.

-- INSIGHT: For completeness, we need ONE countermodel domain.
-- Int works because:
-- 1. It's infinite (need density for some temporal constructs)
-- 2. It's ordered
-- 3. It's an ordered additive group

-- The polymorphism in bmcs_valid is OVERKILL for the completeness proof.

-- RECOMMENDED FIX:
-- Option A: Remove bmcs_valid, use only bmcs_valid_Int everywhere
-- Option B: Keep bmcs_valid for generality but don't try to prove the implication
-- Option C: Change bmcs_valid to use `Type` instead of `Type*`

-- Let's verify Option A works by checking all uses of bmcs_valid

end Bimodal.Metalogic.Bundle.UniverseTest2
