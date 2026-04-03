import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Temporal Derived Theorems: G(a) → X(a) and H(a) → Y(a)

Under strict temporal semantics (G quantifies over s > t, not s ≥ t),
the T-axiom `G(a) → a` is NOT valid. However, the weaker `G(a) → X(a)` IS
derivable from the axiom system, where X(a) = ⊥ U a (next).

## Main Results

- `G_implies_X`: `⊢ G(a) → X(a)` -- if `a` holds at all strictly future times,
  then `a` holds at the next time.
- `H_implies_Y`: `⊢ H(a) → Y(a)` -- dual: if `a` holds at all strictly past times,
  then `a` holds at the previous time.

## Proof Strategy

The derivation uses:
1. `prop_s` to derive `G(a) → G((⊤ ∧ X(a)) → a)` (weakening under G)
2. `until_induction` with φ=⊤, ψ=a, χ=a to get
   `G(a→a) ∧ G((⊤∧X(a))→a) → ((⊤ U a) → X(a))`
3. `seriality_future` + `F_until_equiv` to get `G(a) → ⊤ U a`
4. Chaining to get `G(a) → X(a)`

## References

- Task 83 research report 12: Root cause analysis of g_content blocker
- Goldblatt 1992, *Logics of Time and Computation*
-/

namespace Bimodal.Theorems.TemporalDerived

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators

-- Abbreviations for readability
private abbrev top : Formula := Formula.neg Formula.bot  -- ⊤ = ¬⊥
private abbrev X (a : Formula) : Formula := Formula.untl Formula.bot a  -- X(a) = ⊥ U a
private abbrev Y (a : Formula) : Formula := Formula.snce Formula.bot a  -- Y(a) = ⊥ S a

/-!
## G(a) → X(a) Derivation

### Step 1: G(a) → ⊤ U a  (seriality + F_until_equiv)
### Step 2: G(a) → G(a→a) ∧ G((⊤∧X(a))→a)  (prop_s under G)
### Step 3: until_induction gives (⊤ U a) → X(a) from the conjunction
### Step 4: Chain steps 1, 2, 3 to get G(a) → X(a)
-/

/--
`⊢ G(a) → ⊤ U a` by chaining seriality_future with F_until_equiv.
-/
def G_implies_topUntil (a : Formula) :
    ⊢ a.all_future.imp (Formula.untl top a) :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.seriality_future a))
    (DerivationTree.axiom [] _ (Axiom.F_until_equiv a))

/--
`⊢ G(a) → G(a → a)`: G(a→a) is a theorem, so G(a) → G(a→a) by prop_s.
-/
def G_implies_G_id (a : Formula) :
    ⊢ a.all_future.imp (a.imp a).all_future :=
  mp (DerivationTree.temporal_necessitation _ (identity a))
     (DerivationTree.axiom [] _ (Axiom.prop_s (a.imp a).all_future a.all_future))

/--
`⊢ G(a) → G((⊤ ∧ X(a)) → a)`: From the prop_s instance
`⊢ a → ((⊤ ∧ X(a)) → a)`, apply temporal necessitation and temp_k_dist.
-/
def G_implies_G_step (a : Formula) :
    ⊢ a.all_future.imp
      ((Formula.and top (X a)).imp a).all_future :=
  mp (DerivationTree.temporal_necessitation _
       (DerivationTree.axiom [] _ (Axiom.prop_s a (Formula.and top (X a)))))
     (DerivationTree.axiom [] _
       (Axiom.temp_k_dist a ((Formula.and top (X a)).imp a)))

/--
The until_induction axiom instance for φ = ⊤, ψ = a, χ = a:
`⊢ G(a→a) ∧ G((⊤∧X(a))→a) → ((⊤ U a) → X(a))`
-/
def until_ind_inst (a : Formula) :
    ⊢ (Formula.and
        (a.imp a).all_future
        ((Formula.and top (X a)).imp a).all_future
      ).imp ((Formula.untl top a).imp (X a)) :=
  DerivationTree.axiom [] _ (Axiom.until_induction top a a)

/--
The main theorem: `⊢ G(a) → X(a)` where X(a) = ⊥ U a.

Under strict temporal semantics, G(a) states that `a` holds at all strictly
future times (s > t). X(a) states that `a` holds at the next time (t+1).
Since t+1 > t, this is semantically valid.

**Proof outline**:
1. `G(a) → G(a→a)` and `G(a) → G((⊤∧X(a))→a)` (prop_s under G)
2. Combine: `G(a) → G(a→a) ∧ G((⊤∧X(a))→a)` (conjunction)
3. until_induction: `G(a→a) ∧ G((⊤∧X(a))→a) → ((⊤ U a) → X(a))`
4. So `G(a) → (⊤ U a) → X(a)`
5. `G(a) → ⊤ U a` (seriality + F_until_equiv)
6. Chain: `G(a) → X(a)`
-/
def G_implies_X (a : Formula) : ⊢ a.all_future.imp (X a) := by
  -- Step 1: G(a) → G(a→a) ∧ G((⊤∧X(a))→a)
  have h_conj : ⊢ a.all_future.imp
      (Formula.and (a.imp a).all_future
        ((Formula.and top (X a)).imp a).all_future) :=
    combine_imp_conj (G_implies_G_id a) (G_implies_G_step a)
  -- Step 2: G(a→a) ∧ G((⊤∧X(a))→a) → ((⊤ U a) → X(a))
  have h_ind := until_ind_inst a
  -- Step 3: G(a) → ((⊤ U a) → X(a))
  have h_topU_to_X : ⊢ a.all_future.imp ((Formula.untl top a).imp (X a)) :=
    imp_trans h_conj h_ind
  -- Step 4: G(a) → ⊤ U a
  have h_topU := G_implies_topUntil a
  -- Step 5: Chain to get G(a) → X(a)
  -- From G(a) → (⊤ U a → X(a)) and G(a) → ⊤ U a, get G(a) → X(a)
  -- This is the S-combinator pattern:
  -- prop_k: (P → Q → R) → (P → Q) → P → R
  have h_k : ⊢ (a.all_future.imp ((Formula.untl top a).imp (X a))).imp
    ((a.all_future.imp (Formula.untl top a)).imp (a.all_future.imp (X a))) :=
    DerivationTree.axiom [] _ (Axiom.prop_k a.all_future (Formula.untl top a) (X a))
  have h1 := DerivationTree.modus_ponens [] _ _ h_k h_topU_to_X
  exact DerivationTree.modus_ponens [] _ _ h1 h_topU

/--
The dual theorem: `⊢ H(a) → Y(a)` where Y(a) = ⊥ S a.

Under strict temporal semantics, H(a) states that `a` holds at all strictly
past times (s < t). Y(a) states that `a` holds at the previous time (t-1).
Since t-1 < t, this is semantically valid.

Derived symmetrically to G_implies_X using since_induction, seriality_past,
and P_since_equiv.
-/
noncomputable def H_implies_Y (a : Formula) : ⊢ a.all_past.imp (Y a) := by
  -- Step 1: H(a) → ⊤ S a  (seriality_past + P_since_equiv)
  have h_topSince : ⊢ a.all_past.imp (Formula.snce top a) :=
    imp_trans
      (DerivationTree.axiom [] _ (Axiom.seriality_past a))
      (DerivationTree.axiom [] _ (Axiom.P_since_equiv a))
  -- Step 2: H(a) → H(a→a) (theorem under H)
  have h_H_id : ⊢ a.all_past.imp (a.imp a).all_past :=
    mp (Bimodal.Theorems.past_necessitation _ (identity a))
       (DerivationTree.axiom [] _ (Axiom.prop_s (a.imp a).all_past a.all_past))
  -- Step 3: H(a) → H((⊤ ∧ Y(a)) → a)
  have h_H_step : ⊢ a.all_past.imp
      ((Formula.and top (Y a)).imp a).all_past :=
    mp (Bimodal.Theorems.past_necessitation _
         (DerivationTree.axiom [] _ (Axiom.prop_s a (Formula.and top (Y a)))))
       (Bimodal.Theorems.past_k_dist a ((Formula.and top (Y a)).imp a))
  -- Step 4: Combine conjunction
  have h_conj : ⊢ a.all_past.imp
      (Formula.and (a.imp a).all_past
        ((Formula.and top (Y a)).imp a).all_past) :=
    combine_imp_conj h_H_id h_H_step
  -- Step 5: since_induction instance
  have h_ind : ⊢ (Formula.and
      (a.imp a).all_past
      ((Formula.and top (Y a)).imp a).all_past
    ).imp ((Formula.snce top a).imp (Y a)) :=
    DerivationTree.axiom [] _ (Axiom.since_induction top a a)
  -- Step 6: H(a) → (⊤ S a → Y(a))
  have h_topS_to_Y : ⊢ a.all_past.imp ((Formula.snce top a).imp (Y a)) :=
    imp_trans h_conj h_ind
  -- Step 7: Chain
  have h_k : ⊢ (a.all_past.imp ((Formula.snce top a).imp (Y a))).imp
    ((a.all_past.imp (Formula.snce top a)).imp (a.all_past.imp (Y a))) :=
    DerivationTree.axiom [] _ (Axiom.prop_k a.all_past (Formula.snce top a) (Y a))
  have h1 := DerivationTree.modus_ponens [] _ _ h_k h_topS_to_Y
  exact DerivationTree.modus_ponens [] _ _ h1 h_topSince

end Bimodal.Theorems.TemporalDerived
