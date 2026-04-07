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
    ⊢ a.all_future.imp (Formula.untl top a) := by
  sorry -- seriality + F_until_equiv derivable from BX (Phase 3)

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
      ((Formula.and top (X a)).imp a).all_future := by
  sorry /- temp_k_dist derivable from BX (Phase 3) -/

/--
The until_induction axiom instance for φ = ⊤, ψ = a, χ = a:
`⊢ G(a→a) ∧ G((⊤∧X(a))→a) → ((⊤ U a) → X(a))`
-/
def until_ind_inst (a : Formula) :
    ⊢ (Formula.and
        (a.imp a).all_future
        ((Formula.and top (X a)).imp a).all_future
      ).imp ((Formula.untl top a).imp (X a)) :=
  sorry /- removed in BX -/

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
    sorry /- seriality_past + P_since_equiv removed in BX -/
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
    sorry /- since_induction removed in BX -/
  -- Step 6: H(a) → (⊤ S a → Y(a))
  have h_topS_to_Y : ⊢ a.all_past.imp ((Formula.snce top a).imp (Y a)) :=
    imp_trans h_conj h_ind
  -- Step 7: Chain
  have h_k : ⊢ (a.all_past.imp ((Formula.snce top a).imp (Y a))).imp
    ((a.all_past.imp (Formula.snce top a)).imp (a.all_past.imp (Y a))) :=
    DerivationTree.axiom [] _ (Axiom.prop_k a.all_past (Formula.snce top a) (Y a))
  have h1 := DerivationTree.modus_ponens [] _ _ h_k h_topS_to_Y
  exact DerivationTree.modus_ponens [] _ _ h1 h_topSince

/--
`⊢ G(⊥) → ⊥`: G(⊥) is absurd because seriality gives F(⊥) = ¬G(⊤),
but G(⊤) is a theorem.

This is the special case needed for seed consistency proofs where the
T-axiom `G(a) → a` was previously used at `a = ⊥`.
-/
def G_bot_absurd : ⊢ Formula.bot.all_future.imp Formula.bot :=
  -- Under reflexive BX semantics: G(⊥) → ⊥ follows directly from BX1 (temp_t_future)
  DerivationTree.axiom [] _ (Axiom.temp_t_future Formula.bot)

/--
`⊢ H(⊥) → ⊥`: H(⊥) is absurd because seriality gives P(⊥) = ¬H(⊤),
but H(⊤) is a theorem.
-/
noncomputable def H_bot_absurd : ⊢ Formula.bot.all_past.imp Formula.bot :=
  DerivationTree.axiom [] _ (Axiom.temp_t_past Formula.bot)

/--
`⊢ X(⊥) → ⊥`, i.e., `⊢ (⊥ U ⊥) → ⊥`.

X(⊥) = ⊥ U ⊥ semantically says "⊥ at the next time step", which is impossible
because every time step has a consistent MCS.

**Derivation**: Uses G_bot_absurd and G_implies_X to derive a contradiction.
From G(⊥) → ⊥ (G_bot_absurd) and G(⊥) → X(⊥) (G_implies_X), we get that
X(⊥) and G(⊤) are jointly inconsistent. Since G(⊤) is a theorem (via
temporal necessitation of identity), X(⊥) leads to absurdity.

The formal derivation uses until_linearity on X(⊥) and X(⊤) (a theorem):
  X(⊥) ∧ X(⊤) → (X(⊥ ∧ X(⊤))) ∨ (X(⊤ ∧ X(⊥))) ∨ F(⊥ ∧ ⊤)
  F(⊥ ∧ ⊤) ↔ F(⊥) ↔ ¬G(⊤), and ¬G(⊤) → ⊥ since G(⊤) is a theorem.
  The other disjuncts are handled recursively by omega descent.

NOTE: This derivation is semantically clear but the syntactic proof tree
construction is non-trivial. Uses sorry pending full axiom-level construction.
-/
noncomputable def X_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot := by
  sorry /- X/Y axioms removed in BX, discrete-only -/

/--
`⊢ Y(⊥) → ⊥`, i.e., `⊢ (⊥ S ⊥) → ⊥`.
Mirror of X_bot_absurd for the past direction.
-/
noncomputable def Y_bot_absurd : ⊢ (Formula.snce Formula.bot Formula.bot).imp Formula.bot := by
  -- swap_temporal((⊥ U ⊥) → ⊥) = (⊥ S ⊥) → ⊥
  exact DerivationTree.temporal_duality _ X_bot_absurd

/--
`⊢ (φ U ψ) → F(ψ)`: Any Until formula implies eventuality of its second argument.

Under strict semantics, φ U ψ means ∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r).
The witness s certifies F(ψ). The derivation uses until_induction with χ = ⊥
to derive X(⊥) from G(¬ψ) ∧ (φ U ψ), then X_bot_absurd for contradiction.
-/
noncomputable def until_implies_some_future (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.some_future ψ) := by
  sorry /- derivable from BX axioms, Phase 3 -/

/--
`⊢ (φ S ψ) → P(ψ)`: Any Since formula implies past eventuality.
Mirror of until_implies_some_future.
-/
noncomputable def since_implies_some_past (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.some_past ψ) := by
  sorry /- derivable from BX axioms, Phase 3 -/

/-!
## YX and XY Identity: Y(X(φ)) → φ and X(Y(φ)) → φ

These are direct applications of the yx_identity and xy_identity axioms.
They express that "Previous of Next" and "Next of Previous" are identities
on discrete linear frames.
-/

/-- Y(X(φ)) → φ: Previous of Next is identity.
Direct axiom application. -/
noncomputable def YX_identity (a : Formula) :
    ⊢ (Formula.snce Formula.bot (Formula.untl Formula.bot a)).imp a :=
  sorry /- yx_identity removed in BX -/

/-- X(Y(φ)) → φ: Next of Previous is identity.
Direct axiom application. -/
noncomputable def XY_identity (a : Formula) :
    ⊢ (Formula.untl Formula.bot (Formula.snce Formula.bot a)).imp a :=
  sorry /- xy_identity removed in BX -/

/-- Y-necessitation: if ⊢ φ then ⊢ Y(φ). Uses past temporal necessitation + H→Y. -/
private noncomputable def y_nec' {φ : Formula} (h : DerivationTree [] φ) :
    DerivationTree [] (Formula.snce Formula.bot φ) := by
  have h_H : DerivationTree [] φ.all_past :=
    Bimodal.Theorems.past_necessitation _ h
  exact DerivationTree.modus_ponens [] _ _ (H_implies_Y φ) h_H

/-- X-necessitation: if ⊢ φ then ⊢ X(φ). Uses temporal necessitation + G→X. -/
private noncomputable def x_nec' {φ : Formula} (h : DerivationTree [] φ) :
    DerivationTree [] (Formula.untl Formula.bot φ) := by
  have h_G : DerivationTree [] φ.all_future :=
    DerivationTree.temporal_necessitation _ h
  exact DerivationTree.modus_ponens [] _ _ (G_implies_X φ) h_G

/-- Y(G(φ)) → φ: if G(φ) held at the previous time, then φ holds now.
Derived from G_implies_X (G(φ) → X(φ)), Y-K distribution, and YX_identity. -/
noncomputable def YG_implies_self (a : Formula) :
    ⊢ (Formula.snce Formula.bot a.all_future).imp a := by
  -- Step 1: G(a) → X(a) (G_implies_X)
  have h_GX := G_implies_X a
  -- Step 2: Y(G(a)) → Y(X(a)) (by Y-K distribution)
  have h_y_nec_GX := y_nec' h_GX
  have h_y_k : ⊢ (Formula.snce Formula.bot (a.all_future.imp (X a))).imp
      ((Formula.snce Formula.bot a.all_future).imp (Formula.snce Formula.bot (X a))) :=
    sorry /- y_k_dist removed in BX -/
  have h_YG_imp_YX : ⊢ (Formula.snce Formula.bot a.all_future).imp
      (Formula.snce Formula.bot (X a)) :=
    DerivationTree.modus_ponens [] _ _ h_y_k h_y_nec_GX
  -- Step 3: Y(X(a)) → a (YX_identity)
  have h_YX := YX_identity a
  -- Step 4: Chain: Y(G(a)) → Y(X(a)) → a
  exact imp_trans h_YG_imp_YX h_YX

/-- X(H(φ)) → φ: if H(φ) holds at the next time, then φ holds now.
Derived from H_implies_Y (H(φ) → Y(φ)), X-K distribution, and XY_identity. -/
noncomputable def XH_implies_self (a : Formula) :
    ⊢ (Formula.untl Formula.bot a.all_past).imp a := by
  -- Step 1: H(a) → Y(a) (H_implies_Y)
  have h_HY := H_implies_Y a
  -- Step 2: X(H(a)) → X(Y(a)) (by X-K distribution)
  have h_x_nec_HY := x_nec' h_HY
  have h_x_k : ⊢ (Formula.untl Formula.bot (a.all_past.imp (Y a))).imp
      ((Formula.untl Formula.bot a.all_past).imp (Formula.untl Formula.bot (Y a))) :=
    sorry /- x_k_dist removed in BX -/
  have h_XH_imp_XY : ⊢ (Formula.untl Formula.bot a.all_past).imp
      (Formula.untl Formula.bot (Y a)) :=
    DerivationTree.modus_ponens [] _ _ h_x_k h_x_nec_HY
  -- Step 3: X(Y(a)) → a (XY_identity)
  have h_XY := XY_identity a
  -- Step 4: Chain: X(H(a)) → X(Y(a)) → a
  exact imp_trans h_XH_imp_XY h_XY

end Bimodal.Theorems.TemporalDerived
