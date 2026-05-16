import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.FrameProperties
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
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
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.BXCanonical.Chronicle

/-! ## Discrete Hypothesis -/

/--
The hypothesis that `next_top` (= U(⊤, ⊥)) is in every MCS of the limit domain.
This follows from `□(next_top) ∈ A` via `box_discrete_gives_discreteness`.
-/
def DiscreteHypothesis (A : Set Formula) (h_mcs : SetMaximalConsistent A) : Prop :=
  ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x

/-! ## Prior-UZ/SZ Validity -/

/--
Prior-UZ holds at every point in the limit domain: for any MCS in the domain,
the Prior-UZ axiom instance (for any formula ψ) is in that MCS.
-/
theorem prior_UZ_in_limit_domain (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ψ : Formula) :
    Formula.imp (Formula.some_future ψ) (Formula.untl ψ ψ.neg) ∈ limit_f A h_mcs x :=
  theorem_in_mcs (limit_c0 A h_mcs x hx)
    (DerivationTree.axiom [] _ (Axiom.prior_UZ ψ))

/--
Prior-SZ holds at every point in the limit domain.
-/
theorem prior_SZ_in_limit_domain (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x ∈ limit_dom A h_mcs) (ψ : Formula) :
    Formula.imp (Formula.some_past ψ) (Formula.snce ψ ψ.neg) ∈ limit_f A h_mcs x :=
  theorem_in_mcs (limit_c0 A h_mcs x hx)
    (DerivationTree.axiom [] _ (Axiom.prior_SZ ψ))

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
structure ChronicleAsPriorModel where
  /-- The root MCS A -/
  root : Set Formula
  /-- Proof that A is MCS -/
  root_mcs : SetMaximalConsistent root
  /-- Domain: countable subtype of Rat, discrete without endpoints -/
  domain : Type
  /-- Domain inherits LinearOrder from Rat -/
  domain_lo : LinearOrder domain := by infer_instance
  /-- Domain is countable -/
  domain_countable : Countable domain := by infer_instance
  /-- Domain has no maximum -/
  domain_no_max : NoMaxOrder domain := by infer_instance
  /-- Domain has no minimum -/
  domain_no_min : NoMinOrder domain := by infer_instance
  /-- Domain is discrete (has immediate successors) -/
  domain_succ : SuccOrder domain := by infer_instance
  /-- Domain is discrete (has immediate predecessors) -/
  domain_pred : PredOrder domain := by infer_instance
  /-- Domain is succ-Archimedean: succ-iteration reaches any larger element -/
  domain_succ_archimedean : IsSuccArchimedean domain := by infer_instance
  /-- Domain is nonempty (contains 0) -/
  domain_nonempty : Nonempty domain := by infer_instance
  /-- The point representing the root MCS -/
  root_point : domain
  /-- MCS assignment at each domain point -/
  fmcs : domain → Set Formula
  /-- Each domain point maps to an MCS -/
  fmcs_is_mcs : ∀ t : domain, SetMaximalConsistent (fmcs t)
  /-- The root point's MCS equals A -/
  root_point_mcs : fmcs root_point = root
  /-- Discreteness: next_top ∈ MCS at every point -/
  next_top_everywhere : ∀ t : domain, next_top ∈ fmcs t
  /-- Prior-UZ valid: for all ψ, Prior-UZ(ψ) ∈ MCS at every point -/
  prior_UZ_valid : ∀ t : domain, ∀ ψ : Formula,
    Formula.imp (Formula.some_future ψ) (Formula.untl ψ ψ.neg) ∈ fmcs t
  /-- Prior-SZ valid: for all ψ, Prior-SZ(ψ) ∈ MCS at every point -/
  prior_SZ_valid : ∀ t : domain, ∀ ψ : Formula,
    Formula.imp (Formula.some_past ψ) (Formula.snce ψ ψ.neg) ∈ fmcs t

attribute [instance] ChronicleAsPriorModel.domain_lo
attribute [instance] ChronicleAsPriorModel.domain_countable
attribute [instance] ChronicleAsPriorModel.domain_no_max
attribute [instance] ChronicleAsPriorModel.domain_no_min
attribute [instance] ChronicleAsPriorModel.domain_succ
attribute [instance] ChronicleAsPriorModel.domain_pred
attribute [instance] ChronicleAsPriorModel.domain_succ_archimedean
attribute [instance] ChronicleAsPriorModel.domain_nonempty

/-! ## Extraction from the Chronicle -/

/--
Extract a `ChronicleAsPriorModel` from the Burgess chronicle.

Given MCS A with `□(next_top) ∈ A` (box discreteness), the chronicle's
`LimitDomSubtype` provides a countable discrete domain without endpoints.
The `box_discrete_gives_discreteness` lemma ensures discreteness propagates
to every domain point.

The root point is `⟨0, zero_mem_limit_dom A h_mcs⟩` where `limit_f = A`.
-/
noncomputable def extract_chronicle_as_prior (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_box_discrete : Formula.box next_top ∈ A) : ChronicleAsPriorModel :=
  let h_discrete := box_discrete_gives_discreteness A h_mcs h_box_discrete
  {
    root := A
    root_mcs := h_mcs
    domain := LimitDomSubtype A h_mcs
    domain_succ := limitDomSubtype_succOrder A h_mcs h_discrete
    domain_pred := limitDomSubtype_predOrder A h_mcs h_discrete
    domain_succ_archimedean := limitDomSubtype_isSuccArchimedean A h_mcs h_discrete
    root_point := ⟨0, zero_mem_limit_dom A h_mcs⟩
    fmcs := fun t => limit_f A h_mcs t.val
    fmcs_is_mcs := fun t => limit_c0 A h_mcs t.val t.property
    root_point_mcs := limit_f_zero A h_mcs
    next_top_everywhere := fun t => h_discrete t.val t.property
    prior_UZ_valid := fun t ψ =>
      prior_UZ_in_limit_domain A h_mcs t.val t.property ψ
    prior_SZ_valid := fun t ψ =>
      prior_SZ_in_limit_domain A h_mcs t.val t.property ψ
  }

/-! ## Derived Properties -/

/--
The domain of the chronicle prior model is linearly ordered.
This follows because `LimitDomSubtype` inherits `LinearOrder` from `Rat`.

We reuse the structure's `domain_lo` field marked as `[instance]`.
-/
instance chronicle_prior_domain_linear_order (M : ChronicleAsPriorModel) : LinearOrder M.domain :=
  M.domain_lo

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
def chronicle_discrete_succ (M : ChronicleAsPriorModel)
    (t : M.domain) : M.domain :=
  Order.succ t

/--
The chronicle prior model has an immediate predecessor for every point.
-/
def chronicle_discrete_pred (M : ChronicleAsPriorModel)
    (t : M.domain) : M.domain :=
  Order.pred t

end Bimodal.Metalogic.WeakCanonical
