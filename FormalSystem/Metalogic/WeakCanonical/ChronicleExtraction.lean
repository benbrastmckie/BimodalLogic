/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.ReflexiveCanonical
import FormalSystem.Metalogic.WeakCanonical.FrameProperties
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
import Mathlib.Data.Rat.Defs

/-!
# Chronicle Extraction as Prior Structure for Reynolds Theorem 15

Extracts the existing Burgess chronicle as a "prior structure" satisfying
Reynolds Corollary 3 conditions: countable, discrete without endpoints,
Prior-UZ/SZ valid everywhere. This serves as the input M_0 for the
Reynolds Theorem 15 compression (good/very good, gap elimination, Z-model).

## Design

The chronicle's `LimitDomSubtype` (subtype of Rat over `limit_dom A h_mcs`)
provides:
- Countability: `limitDomSubtype_countable`
- NoMinOrder / NoMaxOrder: `limitDomSubtype_noMinOrder` / `noMaxOrder`
- Discreteness (from `□(next_top) ∈ A`): `limitDomSubtype_succOrder`

The `ChronicleAsPriorModel` structure wraps these with Corollary 3 conditions
as fields. The extraction function `extract_chronicle_as_prior` takes
MCS A with `neg(phi)` and `□(next_top)` and produces the prior model.

## References
- Reynolds 1994, Corollary 3 (= Burgess-Xu)
- Burgess 1982: "Axioms for tense logic II: Time periods"
-/
namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.BXCanonical.Chronicle

/-! ## Discrete Hypothesis -/

/--
The hypothesis that `next_top` (= U(⊤, ⊥)) is in every MCS of the limit domain.
This follows from `□(next_top) ∈ A` via `box_discrete_gives_discreteness`.
-/
def DiscreteHypothesis (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) : Prop :=
  ∀ x ∈ LimitDom fc A h_mcs, nextTop ∈ LimitF fc A h_mcs x

/-! ## Prior-UZ/SZ Validity -/

/--
Prior-UZ holds at every point in the limit domain: for any MCS in the domain,
the Prior-UZ axiom instance (for any formula ψ) is in that MCS.
-/
theorem prior_UZ_in_limit_domain {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (x : Rat) (hx : x ∈ LimitDom fc A h_mcs) (ψ : Formula) :
    Formula.imp (Formula.someFuture ψ) (Formula.untl ψ ψ.neg) ∈ LimitF fc A h_mcs x :=
  theorem_in_mcs (limit_c0 fc A h_mcs x hx)
    (DerivationTree.axiom [] _ (Axiom.prior_UZ ψ) h_fc)

/--
Prior-SZ holds at every point in the limit domain.
-/
theorem prior_SZ_in_limit_domain {fc : FrameClass} (h_fc : FrameClass.Discrete ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (x : Rat) (hx : x ∈ LimitDom fc A h_mcs) (ψ : Formula) :
    Formula.imp (Formula.somePast ψ) (Formula.snce ψ ψ.neg) ∈ LimitF fc A h_mcs x :=
  theorem_in_mcs (limit_c0 fc A h_mcs x hx)
    (DerivationTree.axiom [] _ (Axiom.prior_SZ ψ) h_fc)

/-! ## ChronicleAsPriorModel -/

/--
A **ChronicleAsPriorModel** wraps the Burgess chronicle's discrete output
with the Corollary 3 conditions as explicit fields.

For a given MCS A with `□(next_top) ∈ A`, the chronicle produces:
- A countable domain `LimitDomSubtype`
- That is discrete (has SuccOrder / PredOrder)
- With no endpoints (NoMinOrder / NoMaxOrder)
- Where Prior-UZ and Prior-SZ hold at every point

The `domain` type and its typeclass instances are bundled together as
fields of the structure.
-/
structure ChronicleAsPriorModel (fc : FrameClass := FrameClass.Base) where
  /-- The root MCS A -/
  root : Set Formula
  /-- Proof that A is MCS -/
  root_mcs : SetMaximalConsistent (fc := fc) root
  /-- Domain: countable subtype of Rat, discrete without endpoints -/
  domain : Type
  /-- Domain inherits LinearOrder from Rat -/
  domainLo : LinearOrder domain := by infer_instance
  /-- Domain is countable -/
  domain_countable : Countable domain := by infer_instance
  /-- Domain has no maximum -/
  domain_no_max : NoMaxOrder domain := by infer_instance
  /-- Domain has no minimum -/
  domain_no_min : NoMinOrder domain := by infer_instance
  /-- Domain is discrete (has immediate successors) -/
  domainSucc : SuccOrder domain := by infer_instance
  /-- Domain is discrete (has immediate predecessors) -/
  domainPred : PredOrder domain := by infer_instance
  /-- Domain is succ-Archimedean: succ-iteration reaches any larger element -/
  domain_succ_archimedean : IsSuccArchimedean domain := by infer_instance
  /-- Domain is nonempty (contains 0) -/
  domain_nonempty : Nonempty domain := by infer_instance
  /-- The point representing the root MCS -/
  rootPoint : domain
  /-- MCS assignment at each domain point -/
  fmcs : domain → Set Formula
  /-- Each domain point maps to an MCS -/
  fmcs_is_mcs : ∀ t : domain, SetMaximalConsistent (fc := fc) (fmcs t)
  /-- The root point's MCS equals A -/
  root_point_mcs : fmcs rootPoint = root
  /-- Discreteness: next_top ∈ MCS at every point -/
  next_top_everywhere : ∀ t : domain, nextTop ∈ fmcs t
  /-- Prior-UZ valid: for all ψ, Prior-UZ(ψ) ∈ MCS at every point -/
  prior_UZ_valid : ∀ t : domain, ∀ ψ : Formula,
    Formula.imp (Formula.someFuture ψ) (Formula.untl ψ ψ.neg) ∈ fmcs t
  /-- Prior-SZ valid: for all ψ, Prior-SZ(ψ) ∈ MCS at every point -/
  prior_SZ_valid : ∀ t : domain, ∀ ψ : Formula,
    Formula.imp (Formula.somePast ψ) (Formula.snce ψ ψ.neg) ∈ fmcs t
  /-- C5 forward for Until: if U(φ,ψ) ∈ fmcs(t), then there exists s > t
      with φ ∈ fmcs(s) and ψ ∈ fmcs(r) for all r ∈ (t,s). -/
  until_coherent_fwd : ∀ (t : domain) (φ ψ : Formula),
    Formula.untl φ ψ ∈ fmcs t →
    ∃ (s : domain), t < s ∧ φ ∈ fmcs s ∧
      ∀ (r : domain), t < r → r < s → ψ ∈ fmcs r
  /-- C5 forward for Since: if S(φ,ψ) ∈ fmcs(t), then there exists s < t
      with φ ∈ fmcs(s) and ψ ∈ fmcs(r) for all r ∈ (s,t). -/
  since_coherent_fwd : ∀ (t : domain) (φ ψ : Formula),
    Formula.snce φ ψ ∈ fmcs t →
    ∃ (s : domain), s < t ∧ φ ∈ fmcs s ∧
      ∀ (r : domain), s < r → r < t → ψ ∈ fmcs r
  /-- C4 backward for Until: if ¬U(φ,ψ) ∈ fmcs(t) and φ ∈ fmcs(s) with t < s,
      there exists an intermediate z ∈ (t,s) with ¬ψ ∈ fmcs(z). -/
  neg_until_coherent : ∀ (t s : domain), t < s → ∀ (φ ψ : Formula),
    (Formula.untl φ ψ).neg ∈ fmcs t → φ ∈ fmcs s →
    ∃ (z : domain), t < z ∧ z < s ∧ ψ.neg ∈ fmcs z
  /-- C4 backward for Since: if ¬S(φ,ψ) ∈ fmcs(t) and φ ∈ fmcs(s) with s < t,
      there exists an intermediate z ∈ (s,t) with ¬ψ ∈ fmcs(z). -/
  neg_since_coherent : ∀ (t s : domain), s < t → ∀ (φ ψ : Formula),
    (Formula.snce φ ψ).neg ∈ fmcs t → φ ∈ fmcs s →
    ∃ (z : domain), s < z ∧ z < t ∧ ψ.neg ∈ fmcs z

attribute [instance] ChronicleAsPriorModel.domainLo
attribute [instance] ChronicleAsPriorModel.domain_countable
attribute [instance] ChronicleAsPriorModel.domain_no_max
attribute [instance] ChronicleAsPriorModel.domain_no_min
attribute [instance] ChronicleAsPriorModel.domainSucc
attribute [instance] ChronicleAsPriorModel.domainPred
attribute [instance] ChronicleAsPriorModel.domain_succ_archimedean
attribute [instance] ChronicleAsPriorModel.domain_nonempty

-- extract_chronicle_as_prior archived to
-- Boneyard/DeadChronicleGapElimination/TransferDead.lean

/-! ## Derived Properties -/

/--
The domain of the chronicle prior model is linearly ordered.
This follows because `LimitDomSubtype` inherits `LinearOrder` from `Rat`.

We reuse the structure's `domain_lo` field marked as `[instance]`.
-/
instance chroniclePriorDomainLinearOrder (M : ChronicleAsPriorModel) : LinearOrder M.domain :=
  M.domainLo

/--
The domain of the chronicle prior model is countable.
This follows from `limitDomSubtype_countable`.
-/
instance chronicle_prior_domain_countable (M : ChronicleAsPriorModel) : Countable M.domain :=
  M.domain_countable

/--
The chronicle prior model has no maximum element.
Follows from seriality + `limit_F_resolution`.
-/
theorem chronicle_no_endpoints_forward (M : ChronicleAsPriorModel)
    (t : M.domain) : ∃ (s : M.domain), t < s :=
  exists_gt t

/--
The chronicle prior model has no minimum element.
Follows from seriality + `limit_P_resolution`.
-/
theorem chronicle_no_endpoints_backward (M : ChronicleAsPriorModel)
    (t : M.domain) : ∃ (s : M.domain), s < t :=
  exists_lt t

/--
The chronicle prior model is discrete: every point has an immediate successor.
Follows from `limitDomSubtype_succOrder` (defined when `next_top` is everywhere).
-/
def chronicleDiscreteSucc (M : ChronicleAsPriorModel)
    (t : M.domain) : M.domain :=
  Order.succ t

/--
The chronicle prior model has an immediate predecessor for every point.
-/
def chronicleDiscretePred (M : ChronicleAsPriorModel)
    (t : M.domain) : M.domain :=
  Order.pred t

end FormalSystem.Metalogic.WeakCanonical
