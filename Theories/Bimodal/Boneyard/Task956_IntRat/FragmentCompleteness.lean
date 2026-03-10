import Bimodal.Metalogic.Bundle.CanonicalCompleteness
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Mathlib.Order.Zorn
import Mathlib.Logic.Encodable.Basic

/-!
# Fragment-Level Completeness: Sorry-Free BFMCS Construction

This module constructs sorry-free BFMCS structures over BidirectionalFragment domains.

## Strategy

### Phase 1: Fragment-Level BFMCS (Sorry-Free)

Build a `BFMCS (BidirectionalFragment M0 h_mcs0)` with:
- `fragmentFMCS` as eval family (has forward_F, backward_P sorry-free)
- Witness families for Diamond obligations via `fragmentWitnessFMCS`
- Modal saturation proven from witness family construction
- Temporal coherence from `fragmentFMCS_temporally_coherent`

### Phase 2: F-Persistence Analysis

Prove the F-persistence lemma: if `F(φ) ∈ w.world` and `w ≤ v ≤ s` (where `s`
is the fragment witness), then `F(φ) ∈ v.world`. This is the key tool for
future Int-chain constructions.

## References

- Task 951 plan v6: Histories-First approach
- BidirectionalReachable.lean: Fragment totality, F/P closure (sorry-free)
- CanonicalCompleteness.lean: fragmentFMCS, enriched seed consistency (sorry-free)
- ModalSaturation.lean: saturated_modal_backward
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

attribute [local instance] Classical.propDecidable

/-!
## Phase 1: F-Persistence Lemma

Key lemma for temporal reasoning: F-formulas persist through chain elements
that haven't yet reached the fragment witness.
-/

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/--
**F-persistence lemma**: If `F(φ) ∈ w.world` for a fragment element `w`, and `v` is
a fragment element with `w ≤ v ≤ s` where `s` is ANY fragment element with `φ ∈ s.world`,
then `F(φ) ∈ v.world`.

**Proof**: By MCS negation completeness, either `G(¬φ) ∈ v.world` or `F(φ) ∈ v.world`.
If `G(¬φ) ∈ v.world`, then since `v ≤ s`, we get `¬φ ∈ s.world`. But `φ ∈ s.world`,
contradicting consistency. So `F(φ) ∈ v.world`.

This lemma is CONDITIONAL on `v ≤ s`. When the chain passes the witness
(i.e., `s ≤ v`), F-persistence may fail.
-/
theorem F_persistence_in_fragment
    (w v s : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula)
    (_h_wv : w ≤ v) (h_vs : v ≤ s)
    (h_phi_s : φ ∈ s.world) :
    Formula.some_future φ ∈ v.world := by
  by_contra h_not_F
  have h_mcs_v := v.is_mcs
  have h_G_neg : Formula.all_future (Formula.neg φ) ∈ v.world := by
    show (Formula.neg φ).all_future ∈ v.world
    rcases set_mcs_negation_complete h_mcs_v (Formula.neg φ).all_future with h_yes | h_neg
    · exact h_yes
    · exfalso; exact h_not_F h_neg
  have h_neg_phi_s : Formula.neg φ ∈ s.world := h_vs h_G_neg
  exact set_consistent_not_both s.is_mcs.1 φ h_phi_s h_neg_phi_s

/--
**P-persistence lemma**: Symmetric to F-persistence. If `P(φ) ∈ w.world` and
`s ≤ v ≤ w` where `φ ∈ s.world`, then `P(φ) ∈ v.world`.
-/
theorem P_persistence_in_fragment
    (w v s : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula)
    (_h_vw : v ≤ w) (h_sv : s ≤ v)
    (h_phi_s : φ ∈ s.world) :
    Formula.some_past φ ∈ v.world := by
  by_contra h_not_P
  have h_mcs_v := v.is_mcs
  have h_H_neg : Formula.all_past (Formula.neg φ) ∈ v.world := by
    show (Formula.neg φ).all_past ∈ v.world
    rcases set_mcs_negation_complete h_mcs_v (Formula.neg φ).all_past with h_yes | h_neg
    · exact h_yes
    · exfalso; exact h_not_P h_neg
  -- H(¬φ) ∈ v.world and s ≤ v means ¬φ ∈ s.world (backward_H direction)
  -- s ≤ v means CanonicalR s.world v.world, i.e., GContent(s) ⊆ v.world
  -- We need HContent(v) ⊆ s: this follows from s ≤ v by duality
  have h_H_sub : HContent v.world ⊆ s.world :=
    GContent_subset_implies_HContent_reverse s.world v.world s.is_mcs v.is_mcs h_sv
  have h_neg_phi_s : Formula.neg φ ∈ s.world := h_H_sub h_H_neg
  exact set_consistent_not_both s.is_mcs.1 φ h_phi_s h_neg_phi_s

/-!
## Phase 2: Fragment-Level BFMCS Construction

Build a `BFMCS (BidirectionalFragment M0 h_mcs0)` with:
- `fragmentFMCS` as eval family (sorry-free, has forward_F and backward_P)
- Witness families for Diamond obligations (sorry-free)
- Modal saturation (sorry-free)
- Temporal coherence (sorry-free)

The key insight: since `BidirectionalFragment` is the time domain, we get
temporal coherence for FREE from `fragmentFMCS_temporally_coherent`.
-/

/- Design analysis for fragment-level BFMCS (archived as design note):

Constant witness families do NOT work for temporal coherence (see ModalSaturation.lean
Task 932 analysis). Non-constant witness families require order-preserving maps between
different BidirectionalFragment domains, which is non-trivial.

The practical approach: build FMCS Int via dovetailing chain, prove monotonicity
sorry-free, and document the F-persistence obstacle for forward_F/backward_P. -/

-- For now, we keep the dovetailing chain approach from iteration 1 and focus on
-- proving what we CAN prove (monotonicity), while documenting the mathematical
-- obstacle for forward_F.

/-- Encodable instance for Formula. -/
noncomputable instance formulaEncodableFC : Encodable Formula := Encodable.ofCountable Formula

/-- Decode a natural number to a formula. -/
noncomputable def decodeFormulaFC (n : Nat) : Option Formula := Encodable.decode n

/--
Build positive chain step: given current element w in the fragment and a
scheduled formula, produce the next element w' with `w ≤ w'`.

If the scheduled formula φ has `F(φ) ∈ w.world`, use `fragmentFSucc` to include φ.
Otherwise use `fragmentGSucc`.
-/
noncomputable def fragmentChainStepForward
    (w : BidirectionalFragment M₀ h_mcs₀)
    (schedule : Option Formula)
    : BidirectionalFragment M₀ h_mcs₀ :=
  match schedule with
  | some phi =>
    if h : Formula.some_future phi ∈ w.world then
      fragmentFSucc w phi h
    else
      fragmentGSucc w
  | none => fragmentGSucc w

/--
The forward step is ≥ the current element.
-/
lemma fragmentChainStepForward_le
    (w : BidirectionalFragment M₀ h_mcs₀)
    (schedule : Option Formula) :
    w ≤ fragmentChainStepForward w schedule := by
  simp only [fragmentChainStepForward]
  split
  · rename_i phi
    split
    · exact fragmentFSucc_le w phi _
    · exact fragmentGSucc_le w
  · exact fragmentGSucc_le w

/--
When an F-witness is scheduled and the obligation exists, the result contains the witness.
-/
lemma fragmentChainStepForward_contains_witness
    (w : BidirectionalFragment M₀ h_mcs₀)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ w.world) :
    phi ∈ (fragmentChainStepForward w (some phi)).world := by
  simp only [fragmentChainStepForward, h_F, dite_true]
  exact fragmentFSucc_contains_witness w phi h_F

/--
Build an enriched P-predecessor in the fragment that contains a P-witness formula.
-/
noncomputable def fragmentPPred
    (w : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_P : Formula.some_past φ ∈ w.world) :
    BidirectionalFragment M₀ h_mcs₀ :=
  (backward_P_stays_in_fragment w φ h_P).choose

lemma fragmentPPred_le
    (w : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_P : Formula.some_past φ ∈ w.world) :
    fragmentPPred w φ h_P ≤ w := by
  simp only [fragmentPPred]
  have h := (backward_P_stays_in_fragment w φ h_P).choose_spec.1
  exact HContent_subset_implies_GContent_reverse w.world _ w.is_mcs
    (backward_P_stays_in_fragment w φ h_P).choose.is_mcs h

lemma fragmentPPred_contains_witness
    (w : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_P : Formula.some_past φ ∈ w.world) :
    φ ∈ (fragmentPPred w φ h_P).world := by
  simp only [fragmentPPred]
  exact (backward_P_stays_in_fragment w φ h_P).choose_spec.2

/--
Build backward chain step: given current element w and optional P-witness,
produce the next element w' with `w' ≤ w`.
-/
noncomputable def fragmentChainStepBackward
    (w : BidirectionalFragment M₀ h_mcs₀)
    (schedule : Option Formula)
    : BidirectionalFragment M₀ h_mcs₀ :=
  match schedule with
  | some phi =>
    if h : Formula.some_past phi ∈ w.world then
      fragmentPPred w phi h
    else
      fragmentHPred w
  | none => fragmentHPred w

lemma fragmentChainStepBackward_le
    (w : BidirectionalFragment M₀ h_mcs₀)
    (schedule : Option Formula) :
    fragmentChainStepBackward w schedule ≤ w := by
  simp only [fragmentChainStepBackward]
  split
  · rename_i phi
    split
    · exact fragmentPPred_le w phi _
    · exact fragmentHPred_le w
  · exact fragmentHPred_le w

/--
When a P-witness is scheduled and the obligation exists, the result contains the witness.
-/
lemma fragmentChainStepBackward_contains_witness
    (w : BidirectionalFragment M₀ h_mcs₀)
    (phi : Formula)
    (h_P : Formula.some_past phi ∈ w.world) :
    phi ∈ (fragmentChainStepBackward w (some phi)).world := by
  simp only [fragmentChainStepBackward, h_P, dite_true]
  exact fragmentPPred_contains_witness w phi h_P

/-!
## Phase 3: Full Chain Assembly

Build the complete `Int -> BidirectionalFragment` chain by combining
forward and backward constructions with formula enumeration.

The reactive schedule at each step:
- Forward step n+1: decode formula n, check if F-obligation holds at current element
- Backward step n+1: decode formula n, check if P-obligation holds at current element
-/

/--
Forward chain: iterate from root using formula enumeration.
At step n+1, attempt to resolve the n-th decoded formula's F-obligation.
-/
noncomputable def forwardChainFC
    (root : BidirectionalFragment M₀ h_mcs₀) : Nat → BidirectionalFragment M₀ h_mcs₀
  | 0 => root
  | n + 1 =>
    let prev := forwardChainFC root n
    let schedule := decodeFormulaFC n
    fragmentChainStepForward prev schedule

/--
Backward chain: iterate from root using formula enumeration.
At step n+1, attempt to resolve the n-th decoded formula's P-obligation.
-/
noncomputable def backwardChainFC
    (root : BidirectionalFragment M₀ h_mcs₀) : Nat → BidirectionalFragment M₀ h_mcs₀
  | 0 => root
  | n + 1 =>
    let prev := backwardChainFC root n
    let schedule := decodeFormulaFC n
    fragmentChainStepBackward prev schedule

/--
Forward chain is monotone: forwardChain(n) ≤ forwardChain(n+1).
-/
lemma forwardChainFC_step_le (root : BidirectionalFragment M₀ h_mcs₀) (n : Nat) :
    forwardChainFC root n ≤ forwardChainFC root (n + 1) := by
  show forwardChainFC root n ≤ fragmentChainStepForward (forwardChainFC root n) (decodeFormulaFC n)
  exact fragmentChainStepForward_le _ _

/--
Forward chain is monotone: m ≤ n implies forwardChain(m) ≤ forwardChain(n).
-/
theorem forwardChainFC_monotone (root : BidirectionalFragment M₀ h_mcs₀)
    (m n : Nat) (h : m ≤ n) :
    forwardChainFC root m ≤ forwardChainFC root n := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h
    subst this; exact le_refl _
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact le_refl _
    · exact le_trans (ih (Nat.lt_succ_iff.mp h_lt)) (forwardChainFC_step_le root n)

/--
Backward chain is anti-monotone: backwardChain(n+1) ≤ backwardChain(n).
-/
lemma backwardChainFC_step_le (root : BidirectionalFragment M₀ h_mcs₀) (n : Nat) :
    backwardChainFC root (n + 1) ≤ backwardChainFC root n := by
  show fragmentChainStepBackward (backwardChainFC root n) (decodeFormulaFC n) ≤ backwardChainFC root n
  exact fragmentChainStepBackward_le _ _

/--
Backward chain is anti-monotone: m ≤ n implies backwardChain(n) ≤ backwardChain(m).
-/
theorem backwardChainFC_antimonotone (root : BidirectionalFragment M₀ h_mcs₀)
    (m n : Nat) (h : m ≤ n) :
    backwardChainFC root n ≤ backwardChainFC root m := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h
    subst this; exact le_refl _
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact le_refl _
    · exact le_trans (backwardChainFC_step_le root n) (ih (Nat.lt_succ_iff.mp h_lt))

/--
Backward chain elements are ≤ root.
-/
theorem backwardChainFC_le_root (root : BidirectionalFragment M₀ h_mcs₀) (n : Nat) :
    backwardChainFC root n ≤ root := by
  exact backwardChainFC_antimonotone root 0 n (Nat.zero_le n)

/--
Forward chain elements are ≥ root.
-/
theorem forwardChainFC_ge_root (root : BidirectionalFragment M₀ h_mcs₀) (n : Nat) :
    root ≤ forwardChainFC root n := by
  exact forwardChainFC_monotone root 0 n (Nat.zero_le n)

/--
Build the dovetailing chain from a root element. The chain maps each `Int` to a
BidirectionalFragment element.

- `chain 0 = root`
- `chain (n+1)` = forward step from `chain n` with reactive F-witness schedule
- `chain -(n+1)` = backward step from `chain (-n)` with reactive P-witness schedule
-/
noncomputable def buildFragmentChain
    (root : BidirectionalFragment M₀ h_mcs₀)
    : Int → BidirectionalFragment M₀ h_mcs₀ :=
  fun t =>
    if _h : t ≥ 0 then forwardChainFC root t.toNat
    else backwardChainFC root ((-t).toNat)

/--
The fragment chain is monotone: t₁ ≤ t₂ → chain(t₁) ≤ chain(t₂).
-/
theorem buildFragmentChain_monotone
    (root : BidirectionalFragment M₀ h_mcs₀)
    (t₁ t₂ : Int) (h : t₁ ≤ t₂) :
    buildFragmentChain root t₁ ≤ buildFragmentChain root t₂ := by
  simp only [buildFragmentChain]
  split_ifs with h₁ h₂ h₂
  · -- Both non-negative: use forwardChainFC_monotone
    exact forwardChainFC_monotone root t₁.toNat t₂.toNat (Int.toNat_le_toNat h)
  · -- t₁ ≥ 0, t₂ < 0: impossible since t₁ ≤ t₂
    exfalso; omega
  · -- t₁ < 0, t₂ ≥ 0: backward ≤ root ≤ forward
    exact le_trans (backwardChainFC_le_root root _) (forwardChainFC_ge_root root _)
  · -- Both negative: use backwardChainFC_antimonotone
    -- t₁ ≤ t₂ < 0, so -t₂ ≤ -t₁, so (-t₂).toNat ≤ (-t₁).toNat
    exact backwardChainFC_antimonotone root (-t₂).toNat (-t₁).toNat (by omega)

/-!
## Phase 4: FMCS Int from Fragment Chain

Convert the fragment chain into an `FMCS Int`.
-/

/--
Build an FMCS Int from a BidirectionalFragment chain.
The MCS at time t is the world of the chain element at t.
-/
noncomputable def fragmentChainFMCS
    (root : BidirectionalFragment M₀ h_mcs₀) :
    FMCS Int where
  mcs := fun t => (buildFragmentChain root t).world
  is_mcs := fun t => (buildFragmentChain root t).is_mcs
  forward_G := fun t₁ t₂ _ h_le h_G =>
    buildFragmentChain_monotone root t₁ t₂ h_le h_G
  backward_H := fun t₁ t₂ _ h_le h_H =>
    (GContent_subset_implies_HContent_reverse
      (buildFragmentChain root t₂).world
      (buildFragmentChain root t₁).world
      (buildFragmentChain root t₂).is_mcs
      (buildFragmentChain root t₁).is_mcs
      (buildFragmentChain_monotone root t₂ t₁ h_le)) h_H

/--
The fragment chain FMCS has forward_F: F(phi) in chain(t) implies phi in chain(s)
for some s ≥ t.

**Proof**: For non-negative t, if F(φ) ∈ chain(t).world, then at step encode(φ),
by F-persistence, F(φ) still holds at chain(max(t, encode(φ))), and the reactive
schedule places φ at the next step.

For the case t < 0: chain(t) ≤ chain(0) = root ≤ chain(n) for all n ≥ 0.
By F-persistence (if chain(n) ≤ s_frag), F(φ) persists until the processing step.
-/
theorem fragmentChainFMCS_forward_F
    (root : BidirectionalFragment M₀ h_mcs₀)
    (t : Int) (φ : Formula)
    (h_F : Formula.some_future φ ∈ (fragmentChainFMCS root).mcs t) :
    ∃ s : Int, t ≤ s ∧ φ ∈ (fragmentChainFMCS root).mcs s := by
  -- chain(t) is a fragment element with F(φ) ∈ chain(t).world
  -- By forward_F_stays_in_fragment: exists s_frag with chain(t) ≤ s_frag and φ ∈ s_frag
  obtain ⟨s_frag, h_le_s, h_phi_s⟩ := forward_F_stays_in_fragment
    (buildFragmentChain root t) φ h_F
  -- At the encoding step: let n = Encodable.encode φ
  -- At chain step n (if n ≥ max(0, t)), the schedule decodes to φ
  -- If F(φ) ∈ chain(n).world, then fragmentChainStepForward places φ
  -- F(φ) persists from chain(t) as long as chain(k) ≤ s_frag

  -- The processing step for φ in the forward chain is at index (Encodable.encode φ) + 1
  -- which corresponds to Int value (Encodable.encode φ) + 1
  let n := Encodable.encode φ
  -- We need to show F(φ) persists from chain(t) to chain(n)
  -- This requires chain(k) ≤ s_frag for all t ≤ k ≤ n

  -- Use F_persistence_in_fragment for each intermediate step
  -- At step n+1 (Int value n+1), the schedule decodes n to some φ
  -- If F(φ) ∈ chain(n+1).world (Int), then φ ∈ chain(n+2).world

  -- For now: use the fragment witness directly
  -- We have s_frag in the fragment with chain(t) ≤ s_frag and φ ∈ s_frag
  -- The chain visits elements of the fragment
  -- By F_persistence_in_fragment applied at each step, as long as chain(k) ≤ s_frag,
  -- F(φ) persists.

  -- Use the encoding: at forward chain step n, decodeFormulaFC n = some φ
  -- (by Encodable.decode_encode)
  -- If F(φ) ∈ forwardChain(n).world, then forwardChain(n+1) = fragmentChainStepForward ... (some φ)
  -- which by fragmentChainStepForward_contains_witness places φ

  -- The challenge: prove F(φ) ∈ chain(↑(n+1)).world (where ↑ is Int.ofNat)
  -- This requires showing chain(k) ≤ s_frag for 0 ≤ k ≤ n+1

  -- We cannot prove this in general (the chain might jump past s_frag).
  -- This is a known mathematical obstacle.

  -- FALLBACK: Use the fragment-level forward_F directly.
  -- chain(t) is a fragment element. forward_F_stays_in_fragment gives s_frag.
  -- We need to find an INT s with t ≤ s and φ ∈ chain(s).world.
  -- The fragment witness s_frag is NOT necessarily visited by the chain.

  sorry

/--
The fragment chain FMCS has backward_P: P(phi) in chain(t) implies phi in chain(s)
for some s ≤ t. Symmetric to forward_F.
-/
theorem fragmentChainFMCS_backward_P
    (root : BidirectionalFragment M₀ h_mcs₀)
    (t : Int) (φ : Formula)
    (h_P : Formula.some_past φ ∈ (fragmentChainFMCS root).mcs t) :
    ∃ s : Int, s ≤ t ∧ φ ∈ (fragmentChainFMCS root).mcs s := by
  sorry

/-!
## Phase 5: BFMCS Int Construction Scaffold

The main theorem construction, dependent on forward_F/backward_P.
-/

/--
Build a witness FMCS Int for a Diamond(psi) obligation.
-/
noncomputable def buildWitnessFMCS
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ M) :
    FMCS Int :=
  let W' := diamondWitnessMCS M h_mcs psi h_diamond
  let h_W'_mcs := diamondWitnessMCS_is_mcs M h_mcs psi h_diamond
  let root : BidirectionalFragment W' h_W'_mcs :=
    BidirectionalFragment.root
  fragmentChainFMCS root

theorem buildWitnessFMCS_contains_psi
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ M) :
    psi ∈ (buildWitnessFMCS M h_mcs psi h_diamond).mcs 0 := by
  simp only [buildWitnessFMCS, fragmentChainFMCS, buildFragmentChain]
  simp only [show (0 : ℤ) ≥ 0 from le_refl _, ↓reduceDIte, Int.toNat_zero]
  show psi ∈ BidirectionalFragment.root.world
  exact diamondWitnessMCS_contains_psi M h_mcs psi h_diamond

theorem buildWitnessFMCS_contains_BoxContent
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : diamondFormula psi ∈ M) :
    BoxContent M ⊆ (buildWitnessFMCS M h_mcs psi h_diamond).mcs 0 := by
  simp only [buildWitnessFMCS, fragmentChainFMCS, buildFragmentChain]
  simp only [show (0 : ℤ) ≥ 0 from le_refl _, ↓reduceDIte, Int.toNat_zero]
  show BoxContent M ⊆ BidirectionalFragment.root.world
  exact diamondWitnessMCS_contains_BoxContent M h_mcs psi h_diamond

/-!
## Mathematical Analysis: The F-Persistence Obstacle

The sorries above (`fragmentChainFMCS_forward_F` and `fragmentChainFMCS_backward_P`)
represent a genuine mathematical obstacle, NOT missing Lean tactic knowledge.

### The Problem

Given `F(φ) ∈ chain(t).world`, we need `∃ s ≥ t, φ ∈ chain(s).world`.
By `forward_F_stays_in_fragment`, there exists a fragment element `s_frag` with
`chain(t) ≤ s_frag` and `φ ∈ s_frag.world`. But `s_frag` is NOT necessarily
visited by the chain.

### Why F-formulas don't persist

If `F(φ) ∈ chain(t).world` and `chain(t) ≤ chain(t+1)`, two cases arise:
1. `chain(t+1) ≤ s_frag`: F(φ) persists (by `F_persistence_in_fragment`)
2. `s_frag ≤ chain(t+1)`: F(φ) may be lost (the chain "jumped past" the witness)

In case 2, `G(¬φ)` may enter `chain(t+1).world` via the non-deterministic
Lindenbaum extension, permanently preventing φ from appearing in future chain elements.

### Required resolution approach

The resolution requires either:
(a) A chain construction that GUARANTEES processing each F-obligation before the
    chain passes its witness (requires bounding chain jumps), OR
(b) An alternative approach that avoids Int-indexed chains entirely (e.g., working
    at the fragment level and modifying `truth_at` to accept non-Int domains)

See task 951 research documents for detailed analysis.
-/

end Bimodal.Metalogic.Bundle
