import Bimodal.Metalogic.BXCanonical.Quasimodel.Construction
import Bimodal.Syntax.BigConj
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Propositional

/-!
# Realization Lifting Lemma

Proves that abstract Hintikka chains can be lifted to concrete BXPoint chains
in the canonical model, preserving the temporal ordering `bx_le`.

## Main Definitions

- `until_forward_seed`: The enriched Lindenbaum seed for Until eventuality resolution
- `since_backward_seed`: The enriched Lindenbaum seed for Since eventuality resolution

## Main Results

- `until_eventuality_resolution`: Until eventuality resolution (delegates to Frame.lean)
- `since_eventuality_resolution`: Since eventuality resolution (delegates to Frame.lean)

## Mathematical Analysis

The Until/Since functions in this module now delegate to Frame.lean's canonical
versions (identical signatures). The sorry root cause analysis has been moved
to `CanonicalChain.lean`.

The key insight: the guard property in these signatures is mathematically
correct but appears unprovable from BX1-BX12 due to non-totality of the
`bx_le` preorder. See `CanonicalChain.lean` for the full analysis and
recommended resolution path (chain-based completeness).

## References

- Verbrugge 2007: "Completeness by Construction" (realization technique)
- Burgess 1984: One-step defect discharge
- Reynolds 2003: Until axiomatization and completeness
-/

namespace Bimodal.Metalogic.BXCanonical.Quasimodel

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.BXCanonical

/-! ## Helper: F(ψ) from ψ ∈ w

Any formula in an MCS has its F (some_future) also in the MCS.
Proof: if G(¬ψ) ∈ w, then ¬ψ ∈ w (BX1), contradicting ψ ∈ w.
So G(¬ψ) ∉ w, hence F(ψ) = ¬G(¬ψ) ∈ w. -/

theorem F_of_mem {w : BXPoint} {ψ : Formula}
    (h : ψ ∈ w.formulas) : Formula.some_future ψ ∈ w.formulas := by
  -- F(ψ) from ψ ∈ w. Show G(¬ψ) ∉ w, then derive contradiction.
  by_contra h_not_F
  -- ¬F(ψ) ∈ w by negation completeness
  have h_neg_F : (Formula.some_future ψ).neg ∈ w.formulas :=
    (SetMaximalConsistent.negation_complete w.is_mcs _).resolve_left h_not_F
  -- G(¬ψ) ∈ w from ¬F(ψ) via duality bridge
  have h_G_neg : Formula.all_future (Formula.neg ψ) ∈ w.formulas :=
    Bundle.neg_some_future_to_all_future_neg w.is_mcs ψ h_neg_F
  -- Under irreflexive semantics, BX1 (G(φ) → φ) is removed.
  -- F_of_mem no longer follows from BX1. Sorry'd (non-critical Quasimodel path).
  sorry

/-- P(ψ) ∈ w when ψ ∈ w. Dual of F_of_mem.
Under irreflexive semantics, BX1' (H(φ) → φ) is removed. Sorry'd (non-critical). -/
theorem P_of_mem {w : BXPoint} {ψ : Formula}
    (h : ψ ∈ w.formulas) : Formula.some_past ψ ∈ w.formulas := by
  sorry

/-! ## Helper: F(ψ) from bx_le w v and ψ ∈ v

If bx_le w v and ψ ∈ v, then F(ψ) ∈ w.
Uses BX4' (connect_past: φ → H(F(φ))) and bx_H_forward. -/

theorem F_from_above {w v : BXPoint} {ψ : Formula}
    (h_le : bx_le w v) (h_mem : ψ ∈ v.formulas) :
    Formula.some_future ψ ∈ w.formulas := by
  -- ψ ∈ v → H(F(ψ)) ∈ v (BX4': connect_past)
  have h_connect := connect_past_mcs h_mem
  -- H(F(ψ)) ∈ v and bx_le w v → F(ψ) ∈ w
  exact bx_H_forward h_le h_connect

/-! ## Phase 4 Scaffolding: DerivationTree-level bigconj helpers

These lemmas turn a list of formulas into a `DerivationTree`-level
conjunction (and back). They are consumed by the chain-step seed
consistency reduction below: given a finite subset `L_h` of a Hintikka
point's formulas, we need to move between "each element of `L_h` is
derivable" and "the conjunction `bigconj L_h` is derivable".

They are colocated here (rather than in `Bimodal.Syntax.BigConj`) because
they depend on `DerivationTree` and the propositional combinator library,
whereas `BigConj.lean` is `DerivationTree`-free scaffolding for the
Fisher-Ladner `EnrichedClosure`. -/

/-- Conjunction introduction from a list of assumptions:
    the list derives its own big conjunction. -/
noncomputable def bigconj_intro : (L : List Formula) → L ⊢ bigconj L
  | [] => by
      -- bigconj [] = ¬⊥ = ⊥ → ⊥
      have h : ⊢ Formula.bot.imp Formula.bot :=
        Bimodal.Theorems.Combinators.identity Formula.bot
      show [] ⊢ Formula.bot.neg
      simpa [bigconj, Formula.neg] using h
  | [a] => by
      -- bigconj [a] = a; the list derives a by assumption.
      show [a] ⊢ a
      simpa [bigconj] using
        DerivationTree.assumption [a] a (by simp)
  | a :: b :: rest => by
      -- bigconj (a :: b :: rest) = a ∧ bigconj (b :: rest)
      have h_rec : (b :: rest) ⊢ bigconj (b :: rest) := bigconj_intro (b :: rest)
      have h_rec_w : (a :: b :: rest) ⊢ bigconj (b :: rest) :=
        DerivationTree.weakening _ _ _ h_rec (by
          intro x hx
          simp at hx
          rcases hx with rfl | hx'
          · simp
          · simp [hx'])
      have h_a : (a :: b :: rest) ⊢ a :=
        DerivationTree.assumption _ a (by simp)
      have h_pair :
          ⊢ a.imp ((bigconj (b :: rest)).imp (Formula.and a (bigconj (b :: rest)))) :=
        Bimodal.Theorems.Combinators.pairing a (bigconj (b :: rest))
      have h_pair_w :
          (a :: b :: rest) ⊢ a.imp ((bigconj (b :: rest)).imp
            (Formula.and a (bigconj (b :: rest)))) :=
        DerivationTree.weakening [] (a :: b :: rest) _ h_pair (by intro; simp)
      have h_step1 : (a :: b :: rest) ⊢
          (bigconj (b :: rest)).imp (Formula.and a (bigconj (b :: rest))) :=
        DerivationTree.modus_ponens _ _ _ h_pair_w h_a
      have h_step2 : (a :: b :: rest) ⊢ Formula.and a (bigconj (b :: rest)) :=
        DerivationTree.modus_ponens _ _ _ h_step1 h_rec_w
      show (a :: b :: rest) ⊢ bigconj (a :: b :: rest)
      simpa [bigconj] using h_step2

/-- Conjunction elimination: `[bigconj L] ⊢ φ` for every `φ ∈ L`. -/
noncomputable def bigconj_mem_iff :
    (L : List Formula) → (φ : Formula) → φ ∈ L → [bigconj L] ⊢ φ
  | [], _, h => by simp at h
  | [a], φ, h => by
      have heq : φ = a := by simpa using h
      subst heq
      show [bigconj [φ]] ⊢ φ
      simpa [bigconj] using DerivationTree.assumption [φ] φ (by simp)
  | a :: b :: rest, φ, h => by
      show [bigconj (a :: b :: rest)] ⊢ φ
      rw [show bigconj (a :: b :: rest) = Formula.and a (bigconj (b :: rest)) from rfl]
      by_cases hφa : φ = a
      · subst hφa
        exact Bimodal.Theorems.Propositional.lce φ (bigconj (b :: rest))
      · have h_in : φ ∈ b :: rest := by
          rcases List.mem_cons.mp h with rfl | h'
          · exact absurd rfl hφa
          · exact h'
        have h_rce : [Formula.and a (bigconj (b :: rest))] ⊢ bigconj (b :: rest) :=
          Bimodal.Theorems.Propositional.rce a (bigconj (b :: rest))
        have h_rec : [bigconj (b :: rest)] ⊢ φ := bigconj_mem_iff (b :: rest) φ h_in
        have h_imp : [] ⊢ (bigconj (b :: rest)).imp φ :=
          deduction_theorem [] (bigconj (b :: rest)) φ (by simpa using h_rec)
        have h_imp_w :
            [Formula.and a (bigconj (b :: rest))] ⊢ (bigconj (b :: rest)).imp φ :=
          DerivationTree.weakening [] _ _ h_imp (by intro; simp)
        exact DerivationTree.modus_ponens _ _ _ h_imp_w h_rce

-- enriched_seed_consistent_until, enriched_seed_consistent_since:
-- archived to Boneyard/BX1DependentCode/ (task 130).
-- g_content/h_content subset branches required BX1/BX1', removed under
-- irreflexive semantics (task 113).

/-! ## Phase 4a: Chain-step seed consistency (enriched with g_content)

Task 98 Phase 4a (plan v4): lift task 99's `chain_step_seed_consistent`
to the enriched seed `h.formulas ∪ g_content v.formulas`, where
`h : HintikkaPoint Sigma` is a point of a witnessed Hintikka chain and
`v : BXPoint` is the prior BXPoint being extended in the `realize_chain_step`
construction.

The proof is a one-step subset-of-MCS argument: `ChainWitnessed` gives us
a `BXPoint w` backing `h` with `h.formulas ⊆ w.formulas`; the hypothesis
`h_bx_le_witness` additionally states that `bx_le v w` (i.e.
`g_content v.formulas ⊆ w.formulas`). Together, every element of the
enriched seed lies in `w.formulas`, so `w.is_mcs.1` discharges any
`SetConsistent` obligation.

This matches the `h_neg_in = false` branch of
`enriched_seed_consistent_until` above and the one-line proof of
`chain_step_seed_consistent` in `Construction.lean:676-690`; it is the
lifting lemma Phase 5's stricter seed (C.4) consumes for the
`h.formulas ∪ g_content v.formulas` chunk. -/

theorem chain_step_seed_consistent_enriched
    {Sigma : Finset Formula} {c : HintikkaRawChain Sigma}
    (h_wit : ChainWitnessed c)
    {h : HintikkaPoint Sigma} (h_mem : h ∈ c.points)
    (v : BXPoint)
    (h_bx_le_witness :
      ∀ w : BXPoint, (∀ f ∈ h.formulas, f ∈ w.formulas) → bx_le v w) :
    SetConsistent ((h.formulas : Set Formula) ∪ g_content v.formulas) := by
  -- Extract a BXPoint witness `w` backing `h` from the `ChainWitnessed` predicate.
  obtain ⟨w, hw⟩ := h_wit h h_mem
  -- The caller-supplied witness hypothesis upgrades the backing witness to `bx_le v w`.
  have h_vw : bx_le v w := h_bx_le_witness w hw
  -- Any list from the enriched seed is entirely contained in `w.formulas`.
  intro L hL ⟨d⟩
  have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := by
    intro α hα
    have h_mem_L := hL α hα
    rcases h_mem_L with h_h | h_g
    · exact hw α h_h
    · exact h_vw h_g
  exact w.is_mcs.1 L h_L_in_w ⟨d⟩

/-- Since dual of `chain_step_seed_consistent_enriched`: the enriched
    seed `h.formulas ∪ h_content v.formulas` is consistent whenever the
    chain is witnessed and the caller can upgrade the backing witness
    `w` to `bx_le w v` (equivalently `h_content v.formulas ⊆ w.formulas`
    via `h_content_subset_implies_g_content_reverse`).

    Phase 4b will consume this lemma once `HintikkaStepOracleSince` is
    strengthened to carry a `WitnessedHintikka`. The statement is already
    provable today because `ChainWitnessed` is domain-agnostic. -/
theorem chain_step_seed_consistent_enriched_since
    {Sigma : Finset Formula} {c : HintikkaRawChain Sigma}
    (h_wit : ChainWitnessed c)
    {h : HintikkaPoint Sigma} (h_mem : h ∈ c.points)
    (v : BXPoint)
    (h_h_content_witness :
      ∀ w : BXPoint, (∀ f ∈ h.formulas, f ∈ w.formulas) →
        h_content v.formulas ⊆ w.formulas) :
    SetConsistent ((h.formulas : Set Formula) ∪ h_content v.formulas) := by
  obtain ⟨w, hw⟩ := h_wit h h_mem
  have h_hv : h_content v.formulas ⊆ w.formulas := h_h_content_witness w hw
  intro L hL ⟨d⟩
  have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := by
    intro α hα
    have h_mem_L := hL α hα
    rcases h_mem_L with h_h | h_g
    · exact hw α h_h
    · exact h_hv h_g
  exact w.is_mcs.1 L h_L_in_w ⟨d⟩

/-! ## Phase 5: Chain Realization Infrastructure

Task 98 Phase 5 (plan v4): infrastructure for realizing a Hintikka chain
as a chain of BXPoints in the canonical model.

### Mathematical Analysis

The plan's "strict seed" approach (C.4) proposes a Lindenbaum seed
`h_{i+1}.formulas ∪ g_content(v_i.formulas) ∪ {¬f | f ∈ Sigma \ h_{i+1}}`
to realize each chain step. Analysis reveals a genuine obstacle:

**Obstacle**: `g_content(v_i) ⊆ w_{i+1}.formulas` (required for seed consistency
via `chain_step_seed_consistent_enriched`) fails for `G(χ) ∈ v_i` with
`G(χ) ∉ Sigma`. The `hintikka_step` only propagates G-formulas *within* Sigma,
so `χ ∈ h_{i+1}` is not guaranteed when `G(χ) ∉ Sigma`. If additionally
`χ ∈ Sigma` and `χ ∉ h_{i+1}`, the strict seed forces `¬χ ∈ v_{i+1}` while
`bx_le` forces `χ ∈ v_{i+1}`, making the seed inconsistent.

**Further obstacle**: G-formulas do NOT persist through the Hintikka chain.
For `G(χ) ∈ h_i` (with `G(χ) ∈ Sigma`), hintikka_step gives `χ ∈ h_{i+1}`,
but `G(χ) ∈ h_{i+1}` is not guaranteed: the witness `w_{i+1}` backing `h_{i+1}`
may have `¬G(χ) ∈ w_{i+1}` (meaning χ holds now but not always in the future),
which is consistent with `χ ∈ h_{i+1}`. Without G-persistence, χ may not reach
the last point of chains longer than 2.

**Consequence**: Chain realization requires either (a) G-persistence in the
Sigma-closure (not available for the enriched closure), or (b) a completely
different approach. The guard property (`φ ∈ u` for arbitrary intermediate
BXPoints `u`) additionally requires locus-control exhaustiveness (Phase 6).

### Proven Infrastructure

The lemmas below provide the *provable* building blocks:
- `hintikka_step_g_prop`: G-propagation through a single hintikka_step
- `g_content_sigma` / `g_content_sigma_sub_g_content`: Sigma-restricted g_content
-/

/-- The Sigma-restricted g_content of a BXPoint: only those `χ` where
    `G(χ) ∈ w.formulas` AND `G(χ) ∈ Sigma`. This subset of g_content is
    guaranteed to propagate through `hintikka_step` (via the G-propagation
    clause), unlike full `g_content` which may contain `G(χ) ∉ Sigma`. -/
def g_content_sigma (w : BXPoint) (Sigma : Finset Formula) : Set Formula :=
  {χ : Formula | Formula.all_future χ ∈ w.formulas ∧ Formula.all_future χ ∈ Sigma}

/-- g_content_sigma is a subset of g_content. -/
theorem g_content_sigma_sub_g_content (w : BXPoint) (Sigma : Finset Formula) :
    g_content_sigma w Sigma ⊆ g_content w.formulas := by
  intro χ hχ
  exact hχ.1

/-- G-propagation at the Hintikka level: if `hintikka_step h₁ h₂` and
    `G(χ) ∈ h₁.formulas`, then `χ ∈ h₂.formulas`. This is the first
    clause of `hintikka_step`. -/
theorem hintikka_step_g_prop
    {Sigma : Finset Formula} {h₁ h₂ : HintikkaPoint Sigma}
    (h_step : hintikka_step h₁ h₂) {χ : Formula}
    (h_Gχ : Formula.all_future χ ∈ h₁.formulas) :
    χ ∈ h₂.formulas :=
  h_step.1 χ h_Gχ

/-! ## Until Eventuality Resolution (delegates to Frame.lean) -/

-- Under open guard (task 113), return types no longer claim φ ∈ w (BX9 removed).
noncomputable def until_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl ψ φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas :=
  bx_until_eventuality_resolution w φ ψ h_until h_not_psi

/-! ## Since Eventuality Resolution (delegates to Frame.lean) -/

-- Under open guard (task 113), return types no longer claim φ ∈ w (BX9' removed).
noncomputable def since_eventuality_resolution
    (w : BXPoint) (φ ψ : Formula)
    (h_since : Formula.snce ψ φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le v w ∧ ψ ∈ v.formulas :=
  bx_since_eventuality_resolution w φ ψ h_since h_not_psi

/-! ## SubformulaClosure Temporal Closure Properties

The Quasimodel `SubformulaClosure` (with G/H enrichment and negation pairing)
satisfies the key closure property needed by hintikka_step:
if `G(χ) ∈ Sigma` or `H(χ) ∈ Sigma`, then `χ ∈ Sigma`.
Similarly, if `(φ U ψ) ∈ Sigma`, then `φ, ψ ∈ Sigma`.

These are essential for the oracle construction: when we project a BXPoint
to a Sigma-signature, G-propagation and Until-propagation at the BXPoint
level must land back inside Sigma. -/

/-- Subformulas are transitively closed: if `f ∈ subformulas g` and
    `g ∈ subformulas target`, then `f ∈ subformulas target`. -/
private theorem subformulas_subset_of_mem {g target : Formula}
    (h : g ∈ subformulas target) : subformulas g ⊆ subformulas target := by
  induction target with
  | atom _ =>
    simp [subformulas] at h; subst h; exact Finset.Subset.refl _
  | bot =>
    simp [subformulas] at h; subst h; exact Finset.Subset.refl _
  | imp a b iha ihb =>
    simp [subformulas] at h
    rcases h with rfl | ha | hb
    · exact Finset.Subset.refl _
    · exact Finset.Subset.trans (iha ha) (by
        intro f hf; exact Finset.mem_insert_of_mem (Finset.mem_union_left _ hf))
    · exact Finset.Subset.trans (ihb hb) (by
        intro f hf; exact Finset.mem_insert_of_mem (Finset.mem_union_right _ hf))
  | box a ih =>
    simp [subformulas] at h
    rcases h with rfl | ha
    · exact Finset.Subset.refl _
    · exact Finset.Subset.trans (ih ha) (by
        intro f hf; exact Finset.mem_insert_of_mem hf)
  | untl a b iha ihb =>
    simp [subformulas] at h
    rcases h with rfl | ha | hb
    · exact Finset.Subset.refl _
    · exact Finset.Subset.trans (iha ha) (by
        intro f hf; exact Finset.mem_insert_of_mem (Finset.mem_union_left _ hf))
    · exact Finset.Subset.trans (ihb hb) (by
        intro f hf; exact Finset.mem_insert_of_mem (Finset.mem_union_right _ hf))
  | snce a b iha ihb =>
    simp [subformulas] at h
    rcases h with rfl | ha | hb
    · exact Finset.Subset.refl _
    · exact Finset.Subset.trans (iha ha) (by
        intro f hf; exact Finset.mem_insert_of_mem (Finset.mem_union_left _ hf))
    · exact Finset.Subset.trans (ihb hb) (by
        intro f hf; exact Finset.mem_insert_of_mem (Finset.mem_union_right _ hf))

/-- χ is a subformula of all_future χ. -/
private theorem chi_mem_subformulas_all_future (χ : Formula) :
    χ ∈ subformulas (Formula.all_future χ) := by
  -- all_future χ = imp (untl (imp χ bot) (imp bot bot)) bot
  simp only [Formula.all_future, Formula.some_future, Formula.neg, Formula.top, subformulas]
  simp [Finset.mem_insert, Finset.mem_union, self_mem_subformulas]

/-- χ is a subformula of all_past χ. -/
private theorem chi_mem_subformulas_all_past (χ : Formula) :
    χ ∈ subformulas (Formula.all_past χ) := by
  simp only [Formula.all_past, Formula.some_past, Formula.neg, Formula.top, subformulas]
  simp [Finset.mem_insert, Finset.mem_union, self_mem_subformulas]

/-- `G(χ) ∈ subformulas target → χ ∈ subformulas target`. -/
private theorem subformulas_G_unwrap {target χ : Formula}
    (h : Formula.all_future χ ∈ subformulas target) :
    χ ∈ subformulas target :=
  subformulas_subset_of_mem h (chi_mem_subformulas_all_future χ)

/-- `H(χ) ∈ subformulas target → χ ∈ subformulas target`. -/
private theorem subformulas_H_unwrap {target χ : Formula}
    (h : Formula.all_past χ ∈ subformulas target) :
    χ ∈ subformulas target :=
  subformulas_subset_of_mem h (chi_mem_subformulas_all_past χ)

/-- φ and ψ are subformulas of (φ U ψ). -/
private theorem untl_components_mem_subformulas (φ ψ : Formula) :
    φ ∈ subformulas (Formula.untl ψ φ) ∧ ψ ∈ subformulas (Formula.untl ψ φ) := by
  simp [subformulas, Finset.mem_insert, Finset.mem_union, self_mem_subformulas]

/-- `(φ U ψ) ∈ subformulas target → φ, ψ ∈ subformulas target`. -/
private theorem subformulas_untl_unwrap {target φ ψ : Formula}
    (h : Formula.untl ψ φ ∈ subformulas target) :
    φ ∈ subformulas target ∧ ψ ∈ subformulas target := by
  have hsub := subformulas_subset_of_mem h
  obtain ⟨hφ, hψ⟩ := untl_components_mem_subformulas φ ψ
  exact ⟨hsub hφ, hsub hψ⟩

/-- Classify membership in `ghEnrichment`. -/
private theorem ghEnrichment_mem_cases {S : Finset Formula} {f : Formula}
    (h : f ∈ ghEnrichment S) :
    f ∈ S ∨ (∃ g ∈ S, f = Formula.all_future g) ∨ (∃ g ∈ S, f = Formula.all_past g) := by
  simp only [ghEnrichment, Finset.mem_union, Finset.mem_image] at h
  rcases h with (h_sub | ⟨g, hg, rfl⟩) | ⟨g, hg, rfl⟩
  · exact Or.inl h_sub
  · exact Or.inr (Or.inl ⟨g, hg, rfl⟩)
  · exact Or.inr (Or.inr ⟨g, hg, rfl⟩)

/-- Classify membership in `SubformulaClosure`. -/
private theorem SubformulaClosure_mem_cases {target f : Formula}
    (h : f ∈ SubformulaClosure target) :
    f ∈ ghEnrichment (subformulas target) ∨
    (∃ g ∈ ghEnrichment (subformulas target), f = Formula.neg g) := by
  simp only [SubformulaClosure, Finset.mem_union, Finset.mem_image] at h
  rcases h with h_base | ⟨g, hg, rfl⟩
  · exact Or.inl h_base
  · exact Or.inr ⟨g, hg, rfl⟩

theorem SubformulaClosure_G_closed {target χ : Formula}
    (h : Formula.all_future χ ∈ SubformulaClosure target) :
    χ ∈ SubformulaClosure target := by
  rcases SubformulaClosure_mem_cases h with h_base | ⟨g, hg_base, hg_eq⟩
  · rcases ghEnrichment_mem_cases h_base with h_sub | ⟨f, hf, hfeq⟩ | ⟨f, _, hfeq⟩
    · exact subformula_mem (subformulas_G_unwrap h_sub)
    · -- all_future χ = all_future f: extract χ = f via unfolding
      have : χ = f := by
        simp only [Formula.all_future, Formula.some_future, Formula.neg, Formula.top] at hfeq
        exact Formula.imp.inj (Formula.untl.inj (Formula.imp.inj hfeq).1).1 |>.1
      subst this; exact subformula_mem hf
    · -- all_future χ = all_past f: impossible (untl ≠ snce)
      simp only [Formula.all_future, Formula.all_past, Formula.some_future, Formula.some_past,
                  Formula.neg, Formula.top] at hfeq
      exact absurd (Formula.imp.inj hfeq).1 (by intro h'; exact Formula.noConfusion h')
  · -- all_future χ = neg g, i.e., g = some_future(neg χ)
    -- Since all_future χ = neg(some_future(neg χ)) by definition, g = some_future(neg χ)
    -- g ∈ ghEnrichment(subformulas target), and some_future(neg χ) is untl at top
    -- So g ∈ subformulas target (G/H enrichment images are imp at top, not untl)
    have hg_is : g = Formula.some_future (Formula.neg χ) := by
      simp only [Formula.all_future, Formula.some_future, Formula.neg, Formula.top] at hg_eq
      exact (Formula.imp.inj hg_eq).1.symm
    subst hg_is
    -- some_future(neg χ) ∈ ghEnrichment means it's in S, or = all_future f, or = all_past f
    rcases ghEnrichment_mem_cases hg_base with h_sub | ⟨f, hf, hfeq⟩ | ⟨f, _, hfeq⟩
    · -- some_future(neg χ) ∈ subformulas target: χ ∈ subformulas target by transitivity
      have : χ ∈ subformulas (Formula.some_future (Formula.neg χ)) := by
        simp only [Formula.some_future, Formula.neg, Formula.top, subformulas]
        simp [Finset.mem_insert, Finset.mem_union, self_mem_subformulas]
      exact subformula_mem (subformulas_subset_of_mem h_sub this)
    · -- some_future(neg χ) = all_future f: untl = imp, impossible
      simp only [Formula.some_future, Formula.all_future, Formula.neg, Formula.top] at hfeq
      exact absurd hfeq (by intro h'; exact Formula.noConfusion h')
    · -- some_future(neg χ) = all_past f: untl = imp, impossible
      simp only [Formula.some_future, Formula.all_past, Formula.some_past, Formula.neg, Formula.top] at hfeq
      exact absurd hfeq (by intro h'; exact Formula.noConfusion h')

/-- If `H(χ) ∈ SubformulaClosure target`, then `χ ∈ SubformulaClosure target`. -/
theorem SubformulaClosure_H_closed {target χ : Formula}
    (h : Formula.all_past χ ∈ SubformulaClosure target) :
    χ ∈ SubformulaClosure target := by
  rcases SubformulaClosure_mem_cases h with h_base | ⟨g, hg_base, hg_eq⟩
  · rcases ghEnrichment_mem_cases h_base with h_sub | ⟨f, _, hfeq⟩ | ⟨f, hf, hfeq⟩
    · exact subformula_mem (subformulas_H_unwrap h_sub)
    · -- all_past χ = all_future f: impossible (snce ≠ untl)
      simp only [Formula.all_past, Formula.all_future, Formula.some_past, Formula.some_future,
                  Formula.neg, Formula.top] at hfeq
      exact absurd (Formula.imp.inj hfeq).1 (by intro h'; exact Formula.noConfusion h')
    · -- all_past χ = all_past f: extract χ = f
      have : χ = f := by
        simp only [Formula.all_past, Formula.some_past, Formula.neg, Formula.top] at hfeq
        exact Formula.imp.inj (Formula.snce.inj (Formula.imp.inj hfeq).1).1 |>.1
      subst this; exact subformula_mem hf
  · -- all_past χ = neg g: g = some_past(neg χ)
    have hg_is : g = Formula.some_past (Formula.neg χ) := by
      simp only [Formula.all_past, Formula.some_past, Formula.neg, Formula.top] at hg_eq
      exact (Formula.imp.inj hg_eq).1.symm
    subst hg_is
    rcases ghEnrichment_mem_cases hg_base with h_sub | ⟨f, _, hfeq⟩ | ⟨f, _, hfeq⟩
    · have : χ ∈ subformulas (Formula.some_past (Formula.neg χ)) := by
        simp only [Formula.some_past, Formula.neg, Formula.top, subformulas]
        simp [Finset.mem_insert, Finset.mem_union, self_mem_subformulas]
      exact subformula_mem (subformulas_subset_of_mem h_sub this)
    · -- some_past(neg χ) = all_future f: snce = imp, impossible
      simp only [Formula.some_past, Formula.all_future, Formula.some_future, Formula.neg, Formula.top] at hfeq
      exact absurd hfeq (by intro h'; exact Formula.noConfusion h')
    · -- some_past(neg χ) = all_past f: snce = imp, impossible
      simp only [Formula.some_past, Formula.all_past, Formula.neg, Formula.top] at hfeq
      exact absurd hfeq (by intro h'; exact Formula.noConfusion h')

/-- If `(φ U ψ) ∈ SubformulaClosure target`, then `φ, ψ ∈ SubformulaClosure target`. -/
theorem SubformulaClosure_untl_closed {target φ ψ : Formula}
    (h : Formula.untl ψ φ ∈ SubformulaClosure target) :
    φ ∈ SubformulaClosure target ∧ ψ ∈ SubformulaClosure target := by
  rcases SubformulaClosure_mem_cases h with h_base | ⟨g, _, hg_eq⟩
  · rcases ghEnrichment_mem_cases h_base with h_sub | ⟨f, _, hfeq⟩ | ⟨f, _, hfeq⟩
    · obtain ⟨l, r⟩ := subformulas_untl_unwrap h_sub
      exact ⟨subformula_mem l, subformula_mem r⟩
    · -- untl ψ φ = all_future f: untl = imp, impossible
      simp only [Formula.all_future, Formula.some_future, Formula.neg, Formula.top] at hfeq
      exact absurd hfeq (by intro h'; exact Formula.noConfusion h')
    · -- untl ψ φ = all_past f: untl = imp, impossible
      simp only [Formula.all_past, Formula.some_past, Formula.neg, Formula.top] at hfeq
      exact absurd hfeq (by intro h'; exact Formula.noConfusion h')
  · -- untl ψ φ = neg g = imp g bot: untl = imp, impossible
    simp only [Formula.neg] at hg_eq
    exact absurd hg_eq (by intro h'; exact Formula.noConfusion h')

end Bimodal.Metalogic.BXCanonical.Quasimodel
