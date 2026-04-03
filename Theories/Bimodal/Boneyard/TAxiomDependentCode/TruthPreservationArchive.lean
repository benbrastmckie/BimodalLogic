/-
  ARCHIVED: T-Axiom Dependent Code from TruthPreservation.lean (FMP)
  Date: 2026-04-03
  Reason: These theorems assume G(psi) -> psi / H(psi) -> psi (T-axiom),
          which is NOT valid under strict temporal semantics.
          FMP proof strategy needs redesign for strict semantics.
  Source: Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean
  Task: 83 Phase 1

  This file does NOT compile. It is preserved for historical reference only.
-/

-- ORIGINAL: lines 247-263
/--
All-future reflexivity for closure MCS: Gψ ∈ S implies ψ ∈ S.

**DEPRECATED**: Under strict temporal semantics, the T-axiom (Gφ → φ) is
NOT valid, so this theorem does not hold. The FMP proof strategy needs redesign
to avoid relying on reflexive semantics.

**Status**: Uses sorry pending FMP redesign.
-/
theorem mcs_all_future_closure {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_future : ψ.all_future ∈ S.carrier)
    (h_psi_clos : ψ ∈ closureWithNeg phi) :
    ψ ∈ S.carrier := by
  -- Under strict semantics, Gψ only says ψ at times > t, not at t itself.
  -- This theorem is NOT derivable and needs FMP redesign.
  sorry

-- ORIGINAL: lines 265-281
/--
All-past reflexivity for closure MCS: Hψ ∈ S implies ψ ∈ S.

**DEPRECATED**: Under strict temporal semantics, the T-axiom for past
(Hφ → φ) is NOT valid, so this theorem does not hold. The FMP proof strategy needs
redesign to avoid relying on reflexive semantics.

**Status**: Uses sorry pending FMP redesign.
-/
theorem mcs_all_past_closure {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_past : ψ.all_past ∈ S.carrier)
    (h_psi_clos : ψ ∈ closureWithNeg phi) :
    ψ ∈ S.carrier := by
  -- Under strict semantics, Hψ only says ψ at times < t, not at t itself.
  -- This theorem is NOT derivable and needs FMP redesign.
  sorry

-- ORIGINAL: lines 327-339
/--
Filtration lemma for all_future (forward direction).
If Gψ ∈ closure(φ) and Gψ ∈ S, then ψ ∈ S.
-/
theorem filtration_all_future_forward {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_future_clos : ψ.all_future ∈ subformulaClosure phi)
    (h_future : ψ.all_future ∈ S.carrier) :
    ψ ∈ S.carrier := by
  have h_psi_clos : ψ ∈ subformulaClosure phi := closure_all_future phi ψ h_future_clos
  have h_psi_clneg : ψ ∈ closureWithNeg phi :=
    subformulaClosure_subset_closureWithNeg phi h_psi_clos
  exact mcs_all_future_closure h_future h_psi_clneg

-- ORIGINAL: lines 341-353
/--
Filtration lemma for all_past (forward direction).
If Hψ ∈ closure(φ) and Hψ ∈ S, then ψ ∈ S.
-/
theorem filtration_all_past_forward {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_past_clos : ψ.all_past ∈ subformulaClosure phi)
    (h_past : ψ.all_past ∈ S.carrier) :
    ψ ∈ S.carrier := by
  have h_psi_clos : ψ ∈ subformulaClosure phi := closure_all_past phi ψ h_past_clos
  have h_psi_clneg : ψ ∈ closureWithNeg phi :=
    subformulaClosure_subset_closureWithNeg phi h_psi_clos
  exact mcs_all_past_closure h_past h_psi_clneg
