import FormalSystem.Metalogic.Bundle.TemporalCoherence
import FormalSystem.Metalogic.Bundle.SuccRelation
import FormalSystem.Theorems.TemporalDerived

/-!
# ARCHIVED (Boneyard) — never compiled.

Whole declaration body of `Metalogic/Bundle/UntilSinceCoherence.lean`: 6 declarations
forming two 3-link dead chains with sorry-free upper links and zero external code
consumers at every level (verified by fresh word-boundary grep at excision time):

- `backward_until_reflexive` (1 sorry) → `backward_until_from_step` → `backward_until_coherent`
- `backward_since_reflexive` (1 sorry) → `backward_since_from_step` → `backward_since_coherent`

The two reflexive base cases were tombstoned when reflexive Until/Since introduction
became invalid under open guard (t,s) semantics (their previous proofs via
`TemporalDerived.psi_imp_until` / `psi_imp_since` were archived to
`Boneyard/OpenGuardInvalid/`), leaving the whole parameterized backward-coherence
apparatus unprovable as stated and unconsumed. The truth-lemma pipeline this module
was built for reaches backward Until/Since coherence via the restricted BFMCS route
(`ChronicleToCountermodelBasic.lean`'s `restricted_backward_until_since_coherent`
structure field — a distinct identifier, not a consumer of these declarations).

The live `Metalogic/Bundle/UntilSinceCoherence.lean` retains only its module
docstring, noting this archival.

Do not import from live code.
-/

#exit

/- ======================================================================
   Source: Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean
   Original context: `namespace Bimodal.Metalogic.Bundle`.
   ====================================================================== -/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Reflexive Base Case

When the witness time equals the target time (s = t), backward Until/Since
is immediate from BX8/BX8' (reflexive introduction).
-/

/--
Reflexive backward Until: ψ ∈ M → (φ U ψ) ∈ M.

From BX8: `ψ → (φ U ψ)`.
-/
theorem backward_until_reflexive {M : Set Formula} (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_psi : ψ ∈ M) : Formula.untl ψ φ ∈ M := by
  -- TOMBSTONE: was TemporalDerived.psi_imp_until; archived to Boneyard/OpenGuardInvalid/
  -- Reason: reflexive Until intro invalid under open guard (t,s) semantics
  sorry

/--
Reflexive backward Since: ψ ∈ M → (φ S ψ) ∈ M.

From BX8': `ψ → (φ S ψ)`.
-/
theorem backward_since_reflexive {M : Set Formula} (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (φ ψ : Formula) (h_psi : ψ ∈ M) : Formula.snce ψ φ ∈ M := by
  -- TOMBSTONE: was TemporalDerived.psi_imp_since; archived to Boneyard/OpenGuardInvalid/
  -- Reason: reflexive Since intro invalid under open guard (t,s) semantics
  sorry

/-!
## Parameterized Backward Until/Since

These theorems abstract over the chain-step transfer property, allowing
any chain construction to derive backward Until/Since by providing a
suitable step hypothesis.
-/

/--
Backward Until for an FMCS over Int, parameterized by step transfer.

The step hypothesis says: if `(φ U ψ) ∈ fam.mcs (r+1)` and `φ ∈ fam.mcs r`,
then `(φ U ψ) ∈ fam.mcs r`. This abstracts over the chain-link mechanism
(bot-Until content, enriched seed, etc.) that enables pulling Until backward.
-/
theorem backward_until_from_step (fam : FMCS Int)
    (φ ψ : Formula)
    (h_step : ∀ r : Int, Formula.untl ψ φ ∈ fam.mcs (r + 1) →
      φ ∈ fam.mcs r → Formula.untl ψ φ ∈ fam.mcs r)
    (t s : Int) (h_le : t ≤ s)
    (h_psi : ψ ∈ fam.mcs s)
    (h_guard : ∀ r : Int, t ≤ r → r < s → φ ∈ fam.mcs r) :
    Formula.untl ψ φ ∈ fam.mcs t := by
  suffices h : ∀ (d : Nat) (t' s' : Int), s' - t' = ↑d →
      ψ ∈ fam.mcs s' →
      (∀ r : Int, t' ≤ r → r < s' → φ ∈ fam.mcs r) →
      Formula.untl ψ φ ∈ fam.mcs t' by
    exact h (s - t).toNat t s (by omega) h_psi h_guard
  intro d
  induction d with
  | zero =>
    intro t' s' h_diff h_psi_s _
    have h_eq : s' = t' := by omega
    rw [h_eq] at h_psi_s
    exact backward_until_reflexive (fam.is_mcs t') φ ψ h_psi_s
  | succ d' ih =>
    intro t' s' h_diff h_psi_s h_phi_guard
    have h_U_next : Formula.untl ψ φ ∈ fam.mcs (t' + 1) := by
      apply ih (t' + 1) s' (by omega) h_psi_s
      intro r h_le_r h_r_lt
      exact h_phi_guard r (by omega) h_r_lt
    have h_phi_t : φ ∈ fam.mcs t' := h_phi_guard t' (le_refl t') (by omega)
    exact h_step t' h_U_next h_phi_t

/--
Backward Since for an FMCS over Int, parameterized by step transfer.

Symmetric to `backward_until_from_step` for the past direction.
-/
theorem backward_since_from_step (fam : FMCS Int)
    (φ ψ : Formula)
    (h_step : ∀ r : Int, Formula.snce ψ φ ∈ fam.mcs (r - 1) →
      φ ∈ fam.mcs r → Formula.snce ψ φ ∈ fam.mcs r)
    (t s : Int) (h_le : s ≤ t)
    (h_psi : ψ ∈ fam.mcs s)
    (h_guard : ∀ r : Int, s < r → r ≤ t → φ ∈ fam.mcs r) :
    Formula.snce ψ φ ∈ fam.mcs t := by
  suffices h : ∀ (d : Nat) (t' s' : Int), t' - s' = ↑d →
      ψ ∈ fam.mcs s' →
      (∀ r : Int, s' < r → r ≤ t' → φ ∈ fam.mcs r) →
      Formula.snce ψ φ ∈ fam.mcs t' by
    exact h (t - s).toNat t s (by omega) h_psi h_guard
  intro d
  induction d with
  | zero =>
    intro t' s' h_diff h_psi_s _
    have h_eq : t' = s' := by omega
    rw [h_eq]
    exact backward_since_reflexive (fam.is_mcs s') φ ψ h_psi_s
  | succ d' ih =>
    intro t' s' h_diff h_psi_s h_phi_guard
    have h_S_prev : Formula.snce ψ φ ∈ fam.mcs (t' - 1) := by
      apply ih (t' - 1) s' (by omega) h_psi_s
      intro r h_lt_r h_r_le
      exact h_phi_guard r h_lt_r (by omega)
    have h_phi_t : φ ∈ fam.mcs t' := h_phi_guard t' (by omega) (le_refl t')
    exact h_step t' h_S_prev h_phi_t

/-!
## BFMCS Assembly

Derive the backward conjuncts (2nd and 4th) of `until_since_coherent`
for a BFMCS over Int, given step transfer properties for each family.
-/

/--
Backward Until coherence (2nd conjunct of `until_since_coherent`) for a
BFMCS over Int, given step transfer for each family.
-/
theorem backward_until_coherent (B : BFMCS Int)
    (h_step : ∀ fam ∈ B.families, ∀ (φ ψ : Formula) (r : Int),
      Formula.untl ψ φ ∈ fam.mcs (r + 1) → φ ∈ fam.mcs r →
      Formula.untl ψ φ ∈ fam.mcs r) :
    ∀ fam ∈ B.families, ∀ t : Int, ∀ φ ψ : Formula,
      (∃ s : Int, t ≤ s ∧ ψ ∈ fam.mcs s ∧ ∀ r : Int, t ≤ r → r < s → φ ∈ fam.mcs r) →
      Formula.untl ψ φ ∈ fam.mcs t := by
  intro fam hfam t φ ψ ⟨s, h_le, h_psi, h_guard⟩
  exact backward_until_from_step fam φ ψ (h_step fam hfam φ ψ) t s h_le h_psi h_guard

/--
Backward Since coherence (4th conjunct of `until_since_coherent`) for a
BFMCS over Int, given step transfer for each family.
-/
theorem backward_since_coherent (B : BFMCS Int)
    (h_step : ∀ fam ∈ B.families, ∀ (φ ψ : Formula) (r : Int),
      Formula.snce ψ φ ∈ fam.mcs (r - 1) → φ ∈ fam.mcs r →
      Formula.snce ψ φ ∈ fam.mcs r) :
    ∀ fam ∈ B.families, ∀ t : Int, ∀ φ ψ : Formula,
      (∃ s : Int, s ≤ t ∧ ψ ∈ fam.mcs s ∧ ∀ r : Int, s < r → r ≤ t → φ ∈ fam.mcs r) →
      Formula.snce ψ φ ∈ fam.mcs t := by
  intro fam hfam t φ ψ ⟨s, h_le, h_psi, h_guard⟩
  exact backward_since_from_step fam φ ψ (h_step fam hfam φ ψ) t s h_le h_psi h_guard

end Bimodal.Metalogic.Bundle
