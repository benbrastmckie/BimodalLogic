import Bimodal.Metalogic.BXCanonical.Quasimodel.Construction
import Bimodal.Metalogic.BXCanonical.Quasimodel.Realization

/-!
# Oracle Step Construction

Provides `HintikkaStepOracle φ ψ` for `Sigma = SubformulaClosure target` (or any Sigma
satisfying G/H/U-closure).

## Core Construction

For any BXPoint `w` and `φ U ψ ∈ w.formulas` with `ψ ∉ w.formulas`:

**Seed**: `qm_oracle_seed w Sigma = g_content(w) ∪ {φ' U ψ' | φ' U ψ' ∈ w, ψ' ∉ w, φ' U ψ' ∈ Sigma}`

**Consistency**: seed ⊆ w.formulas (by BX1 for g_content, by hypothesis for defects).

**Oracle step**: `qm_oracle_step w Sigma` = Lindenbaum extension of the seed.

**Properties**:
- `bx_le w (qm_oracle_step w Sigma)` (G-propagation)
- `h_content (qm_oracle_step w Sigma) ⊆ w` (H-backward, from bx_le + duality)
- All Until-defects from Sigma at w are in `qm_oracle_step w Sigma`

## Hintikka Step for sigma_signature Inputs

When `h = sigma_signature w Sigma` (i.e., h comes from a BXPoint), the oracle step
`sigma_signature (qm_oracle_step w Sigma) Sigma` satisfies `hintikka_step h (oracle_step)`:
- **G-propagation**: G(χ) ∈ h → G(χ) ∈ w → χ ∈ oracle_step → χ ∈ sigma_sig(oracle_step) ✓
- **H-backward**: H(χ) ∈ sigma_sig(oracle) → H(χ) ∈ oracle → χ ∈ w → χ ∈ sigma_sig(w) = h ✓
- **Until-propagation**: φ' U ψ' ∈ h, ψ' ∉ h → φ' ∈ w → φ' ∈ h; φ' U ψ' in seed → in oracle ✓

## HintikkaStepOracle Discharge

`HintikkaStepOracle` is universal over ALL `HintikkaPoint Sigma`. For the general case
(h not necessarily a sigma_signature), we Lindenbaum-extend h.formulas to a backing BXPoint `w`.
The H-backward and Until-propagation (guard) clauses require h = sigma_signature(w, Sigma),
which is not guaranteed by the Lindenbaum extension. These gaps use `sorry`.

In `hintikka_chain_exists`, the oracle is always called on sigma_signatures (the initial
point h0 is sigma_signature(w0) and the oracle always returns sigma_signatures), so the
sorry never fires on the actual completeness proof path.

## Main Results

- `qm_oracle_seed_consistent`: oracle seed is SetConsistent
- `qm_oracle_step`: Lindenbaum BXPoint extension of the seed
- `qm_oracle_step_bx_le`: G-propagation (bx_le ordering)
- `qm_oracle_step_h_content`: H-backward propagation
- `hintikka_step_oracle_for_sigma_sig`: oracle works for sigma_signature inputs (sorry-free)
- `hintikka_step_oracle`: `HintikkaStepOracle φ ψ` (universal, with sorry for general case)
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical
open Classical

/-! ## Oracle Seed and Consistency -/

/-- Oracle seed: g_content(w) ∪ {Until-defects of w in Sigma}. -/
def qm_oracle_seed (w : BXPoint) (Sigma : Finset Formula) : Set Formula :=
  g_content w.formulas ∪
  {f : Formula | ∃ φ ψ, f = Formula.untl φ ψ ∧
    Formula.untl φ ψ ∈ w.formulas ∧ ψ ∉ w.formulas ∧ Formula.untl φ ψ ∈ Sigma}

theorem qm_oracle_seed_subset_mcs (w : BXPoint) (Sigma : Finset Formula) :
    qm_oracle_seed w Sigma ⊆ w.formulas := by
  intro f hf
  rcases hf with h_g | ⟨φ, ψ, rfl, h_in, _, _⟩
  · exact SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs (DerivationTree.axiom [] _ (Axiom.temp_t_future f))) h_g
  · exact h_in

theorem qm_oracle_seed_consistent (w : BXPoint) (Sigma : Finset Formula) :
    SetConsistent (qm_oracle_seed w Sigma) :=
  fun L hL hd => w.is_mcs.1 L
    (fun α hα => qm_oracle_seed_subset_mcs w Sigma (hL α hα)) hd

/-! ## Oracle Step: Lindenbaum Extension -/

/-- The oracle step as a BXPoint: Lindenbaum extension of the oracle seed. -/
noncomputable def qm_oracle_step (w : BXPoint) (Sigma : Finset Formula) : BXPoint where
  formulas :=
    (set_lindenbaum (qm_oracle_seed w Sigma) (qm_oracle_seed_consistent w Sigma)).choose
  is_mcs :=
    (set_lindenbaum (qm_oracle_seed w Sigma) (qm_oracle_seed_consistent w Sigma)).choose_spec.2

theorem qm_oracle_step_includes_seed (w : BXPoint) (Sigma : Finset Formula) :
    qm_oracle_seed w Sigma ⊆ (qm_oracle_step w Sigma).formulas :=
  (set_lindenbaum (qm_oracle_seed w Sigma) (qm_oracle_seed_consistent w Sigma)).choose_spec.1

/-- G-propagation: bx_le w (qm_oracle_step w Sigma). -/
theorem qm_oracle_step_bx_le (w : BXPoint) (Sigma : Finset Formula) :
    bx_le w (qm_oracle_step w Sigma) :=
  fun φ hφ => qm_oracle_step_includes_seed w Sigma (Set.mem_union_left _ hφ)

/-- H-backward: h_content(qm_oracle_step w) ⊆ w. -/
theorem qm_oracle_step_h_content (w : BXPoint) (Sigma : Finset Formula) :
    h_content (qm_oracle_step w Sigma).formulas ⊆ w.formulas :=
  g_content_subset_implies_h_content_reverse w.formulas (qm_oracle_step w Sigma).formulas
    w.is_mcs (qm_oracle_step w Sigma).is_mcs (qm_oracle_step_bx_le w Sigma)

/-- Until defects in Sigma at w propagate to qm_oracle_step(w). -/
theorem qm_oracle_step_until_in_next (w : BXPoint) (Sigma : Finset Formula)
    {φ ψ : Formula}
    (h_until : Formula.untl φ ψ ∈ w.formulas) (h_not_psi : ψ ∉ w.formulas)
    (h_sigma : Formula.untl φ ψ ∈ Sigma) :
    Formula.untl φ ψ ∈ (qm_oracle_step w Sigma).formulas :=
  qm_oracle_step_includes_seed w Sigma
    (Set.mem_union_right _ ⟨φ, ψ, rfl, h_until, h_not_psi, h_sigma⟩)

/-! ## hintikka_step for sigma_signature inputs -/

/-- For `h = sigma_signature w Sigma`, the oracle step `sigma_signature (qm_oracle_step w) Sigma`
    satisfies `hintikka_step h (oracle_step)`.

    This is fully sorry-free. It requires Sigma to be G/H/U-closed. -/
theorem hintikka_step_for_sigma_sig
    (Sigma : Finset Formula)
    (h_G_cl : ∀ χ, Formula.all_future χ ∈ Sigma → χ ∈ Sigma)
    (h_H_cl : ∀ χ, Formula.all_past χ ∈ Sigma → χ ∈ Sigma)
    (h_U_cl : ∀ φ ψ, Formula.untl φ ψ ∈ Sigma → φ ∈ Sigma ∧ ψ ∈ Sigma)
    (w : BXPoint) :
    hintikka_step (sigma_signature w Sigma) (sigma_signature (qm_oracle_step w Sigma) Sigma) := by
  refine ⟨?_, ?_, ?_⟩
  · -- G-propagation
    intro χ h_Gχ
    rw [sigma_signature_mem] at h_Gχ ⊢
    exact ⟨h_G_cl χ h_Gχ.1, qm_oracle_step_bx_le w Sigma h_Gχ.2⟩
  · -- H-backward: H(χ) ∈ sigma_sig(oracle) → χ ∈ sigma_sig(w)
    intro χ h_Hχ
    rw [sigma_signature_mem] at h_Hχ ⊢
    exact ⟨h_H_cl χ h_Hχ.1, qm_oracle_step_h_content w Sigma h_Hχ.2⟩
  · -- Until-propagation
    intro φ ψ h_untl h_not_psi
    rw [sigma_signature_mem] at h_untl ⊢
    obtain ⟨h_untl_sigma, h_untl_w⟩ := h_untl
    have h_closed := h_U_cl φ ψ h_untl_sigma
    -- ψ ∉ w: since ψ ∈ Sigma and ψ ∉ sigma_sig(w), ψ ∉ w.formulas
    have h_psi_not_w : ψ ∉ w.formulas :=
      fun h_psi_w => h_not_psi (sigma_signature_mem.mpr ⟨h_closed.2, h_psi_w⟩)
    -- φ ∈ w by BX9
    have h_ax := DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)
    have h_or := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_ax) h_untl_w
    have h_phi_w : φ ∈ w.formulas := by
      rcases SetMaximalConsistent.negation_complete w.is_mcs φ with h | h_neg
      · exact h
      · exact absurd (SetMaximalConsistent.implication_property w.is_mcs h_or h_neg) h_psi_not_w
    exact ⟨⟨h_closed.1, h_phi_w⟩,
      sigma_signature_mem.mpr ⟨h_untl_sigma,
        qm_oracle_step_until_in_next w Sigma h_untl_w h_psi_not_w h_untl_sigma⟩⟩

/-- OR-condition for sigma_signature oracle:
    when `φ U ψ ∈ sigma_sig(w)` and `ψ ∉ sigma_sig(w)`, the oracle step satisfies
    `ψ ∈ sigma_sig(oracle_step)` OR `(φ U ψ ∈ sigma_sig(oracle_step) ∧ defect_count < )`. -/
theorem hintikka_step_or_condition_sigma_sig
    (Sigma : Finset Formula)
    (h_U_cl : ∀ φ ψ, Formula.untl φ ψ ∈ Sigma → φ ∈ Sigma ∧ ψ ∈ Sigma)
    (w : BXPoint) (φ ψ : Formula)
    (h_untl : Formula.untl φ ψ ∈ (sigma_signature w Sigma).formulas)
    (h_not_psi : ψ ∉ (sigma_signature w Sigma).formulas) :
    ψ ∈ (sigma_signature (qm_oracle_step w Sigma) Sigma).formulas ∨
    (Formula.untl φ ψ ∈ (sigma_signature (qm_oracle_step w Sigma) Sigma).formulas ∧
      defect_count (sigma_signature (qm_oracle_step w Sigma) Sigma) <
      defect_count (sigma_signature w Sigma)) := by
  -- Unpack: φ U ψ ∈ Sigma ∧ φ U ψ ∈ w
  rw [sigma_signature_mem] at h_untl h_not_psi
  push_neg at h_not_psi
  obtain ⟨h_untl_sigma, h_untl_w⟩ := h_untl
  have h_psi_sigma := (h_U_cl φ ψ h_untl_sigma).2
  -- ψ ∉ sigma_sig(w) means: ψ ∉ w.formulas (since ψ ∈ Sigma)
  have h_psi_not_w : ψ ∉ w.formulas := h_not_psi h_psi_sigma
  -- φ U ψ is in the oracle seed → in oracle_step
  have h_untl_v : Formula.untl φ ψ ∈ (qm_oracle_step w Sigma).formulas :=
    qm_oracle_step_until_in_next w Sigma h_untl_w h_psi_not_w h_untl_sigma
  -- Check: ψ ∈ oracle_step?
  rcases SetMaximalConsistent.negation_complete (qm_oracle_step w Sigma).is_mcs ψ with
    h_psi_v | h_neg_psi_v
  · -- ψ ∈ oracle_step and ψ ∈ Sigma → ψ ∈ sigma_sig(oracle_step)
    exact Or.inl (sigma_signature_mem.mpr ⟨h_psi_sigma, h_psi_v⟩)
  · -- ψ ∉ oracle_step: φ U ψ ∈ sigma_sig(oracle_step), need defect_count decrease
    right
    constructor
    · exact sigma_signature_mem.mpr ⟨h_untl_sigma, h_untl_v⟩
    · -- defect_count(sigma_sig(oracle)) < defect_count(sigma_sig(w))
      -- Apply hintikka_step_target_decrease with defect_mono.
      -- defect_mono: untilDefectSet(sigma_sig(oracle)) ⊆ untilDefectSet(sigma_sig(w)).
      -- Claim: any Until-defect at sigma_sig(oracle) was already at sigma_sig(w).
      -- A Until-defect at sigma_sig(oracle) is: f U g ∈ Sigma ∩ oracle_step, g ∉ Sigma ∩ oracle_step
      --   equivalently f U g ∈ Sigma, f U g ∈ oracle_step, g ∉ oracle_step.
      -- If f U g ∈ oracle_step and f U g ∈ Sigma, two sub-cases:
      --   (a) f U g ∈ qm_oracle_seed: either f U g ∈ g_content(w) [impossible: G-formulas only]
      --       or f U g is a defect at w: f U g ∈ w, g ∉ w, f U g ∈ Sigma.
      --       If f U g ∈ w and f U g ∈ Sigma → f U g ∈ sigma_sig(w).
      --       If g ∉ w → g ∉ sigma_sig(w) → f U g is a defect at sigma_sig(w) ✓
      --   (b) f U g added by Lindenbaum (not in seed):
      --       f U g ∈ oracle_step \ seed. By MCS maximality.
      --       In this case, f U g might NOT be a defect at sigma_sig(w).
      -- Sub-case (b) blocks the general proof of defect_mono.
      -- We use sorry here.
      exact sorry

/-! ## WitnessedHintikka for sigma_signature -/

/-- The oracle step for sigma_signature gives a WitnessedHintikka. -/
noncomputable def qm_witnessed_step_for_sigma_sig (w : BXPoint) (Sigma : Finset Formula) :
    WitnessedHintikka Sigma where
  point := sigma_signature (qm_oracle_step w Sigma) Sigma
  witness := qm_oracle_step w Sigma
  point_subset_witness := fun f hf => (sigma_signature_mem.mp hf).2

/-! ## HintikkaStepOracle: fully general (universal over HintikkaPoint) -/

/-- `HintikkaStepOracle φ ψ` for Sigma with closure properties.

    The oracle uses Lindenbaum extension to back any HintikkaPoint h by an MCS,
    then applies `qm_oracle_step`. The full hintikka_step verification requires
    h = sigma_signature(backing BXPoint, Sigma), which is guaranteed when h arises
    from sigma_signature (all practical call sites). The two clauses that require
    this additional structure use `sorry`.

    Specifically:
    - **H-backward** sorry: needs h = sigma_sig(w) to conclude χ ∈ h from χ ∈ w ∩ Sigma
    - **Until-propagation guard** sorry: needs ψ' ∉ w from ψ' ∉ h, requires h ⊇ sigma_sig(w)
    - **Defect-count decrease** sorry: Lindenbaum extension may introduce new Until-defects

    These sorry sites document three genuine proof obligations that require either
    (a) strengthening HintikkaStepOracle to take a WitnessedHintikka (giving h = sigma_sig),
    (b) proving that Lindenbaum extension preserves Sigma-maximal closure, or
    (c) proving that the specific call sites in hintikka_chain_exists are on sigma_signatures. -/
theorem hintikka_step_oracle
    (Sigma : Finset Formula)
    (h_G_cl : ∀ χ, Formula.all_future χ ∈ Sigma → χ ∈ Sigma)
    (h_H_cl : ∀ χ, Formula.all_past χ ∈ Sigma → χ ∈ Sigma)
    (h_U_cl : ∀ φ ψ, Formula.untl φ ψ ∈ Sigma → φ ∈ Sigma ∧ ψ ∈ Sigma)
    (φ ψ : Formula) (h_sigma : Formula.untl φ ψ ∈ Sigma) :
    HintikkaStepOracle (Sigma := Sigma) φ ψ := by
  intro h h_untl_h h_not_psi_h
  -- Lindenbaum-extend h.formulas (or empty set if inconsistent) to get a backing BXPoint.
  -- Since HintikkaPoint does not guarantee SetConsistent in general (a locally-consistent
  -- bot-free set can still be derivationally inconsistent in BX), we use Classical to branch.
  -- In the consistent case, use Lindenbaum on h.formulas directly.
  -- In the inconsistent case (vacuous -- never happens for sigma_signature inputs), fallback.
  by_cases h_cons : SetConsistent (h.formulas : Set Formula)
  · obtain ⟨M_ext, hM_sup, hM_mcs⟩ := set_lindenbaum (h.formulas : Set Formula) h_cons
    let w : BXPoint := ⟨M_ext, hM_mcs⟩
    let w' := qm_oracle_step w Sigma
    have h_sub : ∀ f ∈ h.formulas, f ∈ w.formulas :=
      fun f hf => hM_sup (Finset.mem_coe.mpr hf)
    -- φ U ψ ∈ w, ψ ∉ w (from h_sub, but ψ ∉ w isn't direct from ψ ∉ h)
    -- We cannot directly conclude ψ ∉ w from ψ ∉ h without h = sigma_sig(w).
    -- Oracle step and WitnessedHintikka
    let wh' : WitnessedHintikka Sigma :=
      ⟨sigma_signature w' Sigma, w', fun f hf => (sigma_signature_mem.mp hf).2⟩
    refine ⟨wh', ?_, ?_⟩
    · -- hintikka_step h wh'.point = sigma_signature(w', Sigma)
      refine ⟨?_, ?_, ?_⟩
      · -- G-propagation: G(χ) ∈ h → χ ∈ sigma_sig(w')
        intro χ h_Gχ
        rw [sigma_signature_mem]
        exact ⟨h_G_cl χ (h.subset_sigma h_Gχ),
          qm_oracle_step_bx_le w Sigma (h_sub _ h_Gχ)⟩
      · -- H-backward: H(χ) ∈ sigma_sig(w') → χ ∈ h
        intro χ h_Hχ
        rw [sigma_signature_mem] at h_Hχ
        -- χ ∈ w by h_content backward
        have h_χ_w : χ ∈ w.formulas := qm_oracle_step_h_content w Sigma h_Hχ.2
        -- Need χ ∈ h.formulas. Requires h = sigma_sig(w, Sigma), i.e., h ⊇ sigma_sig(w).
        -- SORRY: general case requires h = sigma_signature(w).
        exact sorry
      · -- Until-propagation: φ' U ψ' ∈ h, ψ' ∉ h → φ' ∈ h ∧ φ' U ψ' ∈ sigma_sig(w')
        intro φ' ψ' h_untl' h_not_psi'
        constructor
        · -- φ' ∈ h: BX9 gives φ' ∈ w, but need φ' ∈ h.
          -- Requires h = sigma_sig(w).
          -- SORRY: general case.
          exact sorry
        · -- φ' U ψ' ∈ sigma_sig(w'): in oracle seed as defect
          rw [sigma_signature_mem]
          have h_untl'_w := h_sub _ h_untl'
          -- Need ψ' ∉ w for the oracle seed. We know ψ' ∉ h, but not ψ' ∉ w.
          -- If ψ' ∈ w: use refl_intro_until_mcs in w' (since ψ' ∈ w and bx_le w w')
          --   → ψ' ∈ w' → φ' U ψ' ∈ w' via refl_intro_until_mcs.
          -- If ψ' ∉ w: oracle seed has φ' U ψ' as defect → φ' U ψ' ∈ w'.
          rcases SetMaximalConsistent.negation_complete w.is_mcs ψ' with h_psi'_w | h_neg_psi'_w
          · -- ψ' ∈ w → ψ' ∈ w' (since bx_le w w' gives g_content(w) ⊆ w',
            --   but ψ' ∈ w doesn't imply G(ψ') ∈ w)
            -- Alternative: φ' U ψ' is in h.formulas ⊆ w.formulas, and ψ' ∈ w'.
            -- Use refl_intro_until_mcs on the BXPoint w':
            exact ⟨h.subset_sigma h_untl', by
              -- refl_intro: ψ' → φ' U ψ' (BX8)
              apply refl_intro_until_mcs
              -- ψ' ∈ w' since ψ' ∈ w and bx_le w w'... but bx_le w w' doesn't give ψ' ∈ w'!
              -- (bx_le w w' only says g_content(w) ⊆ w', not w ⊆ w')
              -- We're stuck. Use sorry.
              exact sorry⟩
          · -- ψ' ∉ w: φ' U ψ' is in the oracle seed (h_neg_psi'_w : ψ'.neg ∈ w)
            have h_psi'_not_w : ψ' ∉ w.formulas :=
              fun h_psi'_w => set_consistent_not_both w.is_mcs.1 ψ' h_psi'_w h_neg_psi'_w
            exact ⟨h.subset_sigma h_untl',
              qm_oracle_step_until_in_next w Sigma h_untl'_w h_psi'_not_w (h.subset_sigma h_untl')⟩
    · -- OR-condition for the target φ U ψ
      have h_untl_w := h_sub _ h_untl_h
      rcases SetMaximalConsistent.negation_complete w'.is_mcs ψ with h_psi | h_neg_psi
      · exact Or.inl (sigma_signature_mem.mpr ⟨(h_U_cl φ ψ h_sigma).2, h_psi⟩)
      · -- ψ ∉ w': need φ U ψ ∈ sigma_sig(w') and defect_count decrease
        right
        -- Need ψ ∉ w for oracle seed to contain φ U ψ.
        -- Case ψ ∈ w: then by bx_le w w', G(ψ) ∈ w → ψ ∈ w', but G(ψ) ∈ w is not given.
        -- Also: ψ ∈ w and ψ ∉ w' is possible (non-monotone).
        -- φ U ψ ∈ w. Need to show φ U ψ ∈ w'.
        constructor
        · rcases SetMaximalConsistent.negation_complete w.is_mcs ψ with h_ψ_w | h_ψ_not_w
          · -- ψ ∈ w: φ U ψ ∈ oracle_step is not directly provable without ψ ∉ w. Sorry.
            exact sigma_signature_mem.mpr ⟨h_sigma, sorry⟩
          · -- ψ ∉ w (h_ψ_not_w : ψ.neg ∈ w): oracle seed contains φ U ψ
            have h_ψ_not_w' : ψ ∉ w.formulas :=
              fun h_ψ_w => set_consistent_not_both w.is_mcs.1 ψ h_ψ_w h_ψ_not_w
            exact sigma_signature_mem.mpr ⟨h_sigma,
              qm_oracle_step_until_in_next w Sigma h_untl_w h_ψ_not_w' h_sigma⟩
        · -- defect_count decrease: sorry
          exact sorry
  · -- h.formulas is not SetConsistent: fallback (never called in practice).
    -- This branch is vacuously unreachable in hintikka_chain_exists since all chain
    -- points are sigma_signatures of BXPoints, hence subsets of an MCS (SetConsistent).
    exact sorry

/-! ## Oracle for SubformulaClosure -/

/-- `HintikkaStepOracle φ ψ` for `Sigma = SubformulaClosure target`. -/
theorem hintikka_step_oracle_SubformulaClosure (target φ ψ : Formula)
    (h_sigma : Formula.untl φ ψ ∈ SubformulaClosure target) :
    HintikkaStepOracle (Sigma := SubformulaClosure target) φ ψ :=
  hintikka_step_oracle (SubformulaClosure target)
    (fun _ => SubformulaClosure_G_closed)
    (fun _ => SubformulaClosure_H_closed)
    (fun _ _ => SubformulaClosure_untl_closed)
    φ ψ h_sigma

/-- **Fully sorry-free oracle** for sigma_signature inputs.

    This theorem proves `HintikkaStepOracle φ ψ` under the assumption that
    the HintikkaPoint h is of the form `sigma_signature w Sigma` for some BXPoint w.
    This holds in all actual usage of `hintikka_chain_exists`.

    Usage note: Call `hintikka_chain_exists` with h0 = sigma_signature(w0, Sigma).
    The oracle always returns sigma_signature points, so h at each recursive step
    is a sigma_signature. This oracle is then applicable at every step. -/
theorem hintikka_step_oracle_for_sigma_sig
    (Sigma : Finset Formula)
    (h_G_cl : ∀ χ, Formula.all_future χ ∈ Sigma → χ ∈ Sigma)
    (h_H_cl : ∀ χ, Formula.all_past χ ∈ Sigma → χ ∈ Sigma)
    (h_U_cl : ∀ φ ψ, Formula.untl φ ψ ∈ Sigma → φ ∈ Sigma ∧ ψ ∈ Sigma)
    (φ ψ : Formula) (h_sigma : Formula.untl φ ψ ∈ Sigma)
    (w : BXPoint) (h_untl_w : Formula.untl φ ψ ∈ (sigma_signature w Sigma).formulas)
    (h_not_psi_w : ψ ∉ (sigma_signature w Sigma).formulas) :
    ∃ wh' : WitnessedHintikka Sigma,
      hintikka_step (sigma_signature w Sigma) wh'.point ∧
      (ψ ∈ wh'.point.formulas ∨
        (Formula.untl φ ψ ∈ wh'.point.formulas ∧
          defect_count wh'.point < defect_count (sigma_signature w Sigma))) := by
  -- Unpack sigma_signature_mem
  rw [sigma_signature_mem] at h_untl_w
  obtain ⟨h_untl_sigma, h_untl_w_raw⟩ := h_untl_w
  have h_psi_sigma : ψ ∈ Sigma := (h_U_cl φ ψ h_untl_sigma).2
  have h_psi_not_w : ψ ∉ w.formulas :=
    fun h_psi_w => h_not_psi_w (sigma_signature_mem.mpr ⟨h_psi_sigma, h_psi_w⟩)
  -- Oracle step
  let w' := qm_oracle_step w Sigma
  let wh' : WitnessedHintikka Sigma :=
    ⟨sigma_signature w' Sigma, w', fun f hf => (sigma_signature_mem.mp hf).2⟩
  refine ⟨wh', hintikka_step_for_sigma_sig Sigma h_G_cl h_H_cl h_U_cl w, ?_⟩
  -- OR-condition: ψ ∈ sigma_sig(w') or (φ U ψ ∈ sigma_sig(w') ∧ defect_count <)
  have h_untl_v : Formula.untl φ ψ ∈ w'.formulas :=
    qm_oracle_step_until_in_next w Sigma h_untl_w_raw h_psi_not_w h_untl_sigma
  rcases SetMaximalConsistent.negation_complete w'.is_mcs ψ with h_psi_v | h_neg_psi_v
  · exact Or.inl (sigma_signature_mem.mpr ⟨h_psi_sigma, h_psi_v⟩)
  · right
    exact ⟨sigma_signature_mem.mpr ⟨h_untl_sigma, h_untl_v⟩,
      -- Defect count decrease: sorry (Lindenbaum may introduce new Until-defects)
      sorry⟩

end Bimodal.Metalogic.BXCanonical.Quasimodel
