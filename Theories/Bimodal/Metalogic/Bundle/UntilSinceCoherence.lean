import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Theorems.TemporalDerived

/-!
# Until/Since Coherence: Backward Direction

This module provides backward Until and backward Since lemmas for FMCS families
over Int. These are needed for the truth lemma's Until/Since cases: given a
witness pattern (ψ at some s ≥ t, φ on guard [t, s)), derive (φ U ψ) ∈ fam.mcs t.

## Approach

Under BX reflexive Until semantics, `or_until_in_mcs` gives:
  (ψ ∨ (φ ∧ (φ U ψ))) ∈ M → (φ U ψ) ∈ M

This enables the reflexive base case (t = s) directly via BX8: `ψ → (φ U ψ)`.

For the inductive case (t < s), we need a "step transfer" property to pull
the Until formula backward one position at a time.

### Step Transfer Property

The backward induction from s to t requires, at each intermediate step r:
  (φ U ψ) ∈ fam.mcs (r + 1) ∧ φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r

This step is NOT derivable from the bare FMCS structure (forward_G, backward_H).
It requires additional chain properties:

1. **Deterministic chain** (archived to Boneyard/DiscreteXY): Used bot-Until
   linking `φ ∈ chain(n+1) ↔ (⊥ U φ) ∈ chain(n)`, giving the step via `until_intro`.
   Under BX reflexive semantics, (⊥ U α) ↔ α in any MCS, so the deterministic
   chain is constant and backward Until is trivially satisfied.

2. **Dovetailed/SuccChain**: Has g_content linking `G(φ) ∈ chain(n) → φ ∈ chain(n+1)`,
   which goes forward but not backward. The h_content duality gives
   `H(φ) ∈ chain(n+1) → φ ∈ chain(n)` but Until is not an H-formula.
   The step transfer is not available for these constructions without modification.

### Parameterized Approach

We provide `backward_until_from_step` and `backward_since_from_step` parameterized
by a step transfer hypothesis. Any chain construction that can prove the step
property (e.g., via enriched seeds or modified successor construction) can use
these to derive full backward Until/Since coherence.

## Main Results

- `backward_until_reflexive`: (φ U ψ) ∈ M when ψ ∈ M (t = s case, any MCS)
- `backward_since_reflexive`: (φ S ψ) ∈ M when ψ ∈ M (t = s case, any MCS)
- `backward_until_from_step`: Full backward Until for FMCS Int, given step transfer
- `backward_since_from_step`: Full backward Since for FMCS Int, given step transfer
- `backward_until_coherent`: Second conjunct of until_since_coherent for BFMCS Int
- `backward_since_coherent`: Fourth conjunct of until_since_coherent for BFMCS Int

## References

- TemporalCoherence.lean: `BFMCS.until_since_coherent` definition
- SuccRelation.lean: `or_until_in_mcs`, `or_since_in_mcs`
- Theorems/TemporalDerived.lean: `psi_imp_until`, `psi_imp_since`
-/

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
theorem backward_until_reflexive {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_psi : ψ ∈ M) : Formula.untl ψ φ ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.psi_imp_until φ ψ)) h_psi

/--
Reflexive backward Since: ψ ∈ M → (φ S ψ) ∈ M.

From BX8': `ψ → (φ S ψ)`.
-/
theorem backward_since_reflexive {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_psi : ψ ∈ M) : Formula.snce ψ φ ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.psi_imp_since φ ψ)) h_psi

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
