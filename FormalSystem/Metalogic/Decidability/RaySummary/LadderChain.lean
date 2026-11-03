/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderPump
import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient

/-!
# The realized-chain bridge: a type-respecting block is a cycle of the certificate graph

## Contract

This module is NOT certificate-free, by design, and says exactly which objects it reads: the
LOCAL, one-directional half of the certificate layer — the Hintikka condition `locCoh`, the two
one-step link conditions `untlLink` and `snceLink`, their idle-extended conjunction `cohIdle`,
the saturation predicate `SatCl`, and the cycle-length set `prodCycleLens` that `(K1)`
quantifies. It names NO certificate-SET object — none of the certificate conditions, the
maximum certified subset, the consistency bundle, the periodicity bridge or the periodicity
fixpoint's threshold and period — and that is what keeps it clear of the recorded circularity,
which runs through the `⊡`-collapse and bi-infinity conditions of the certificate SET and not
through the local relation.

## What it holds

The bridge: a block of a pending region whose two ends carry the same object state and the same
realized stab-free type is, read as a periodic walk on `(objAt, tpOf)` pairs, a `cohIdle`-cycle
of the certificate graph through saturated classes, so its length is a member of
`prodCycleLens` and divides `P + 1` under `(K1)`. The realized types satisfy the local
conditions by the fixpoint equations of `AnchorLayer.lean` (`atom`, `bot`, `imp`) and the strict
one-step unfoldings of the two temporal equations of `LadderAgree.lean`. The type-pigeonhole
budget of `LadderPump.lean` equals the cardinality of the certificate layer's product carrier
(`card_prodState`), and `(K2)`'s cascade bound dominates it (`budget_le_cascadeBound`,
`budget_le_Tc`).

## What this module does NOT hold

No cell-level agreement, no assembly beyond the bridge; the regime-A assembly consumes the
bridge and is stated separately below the bridge's section.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The budget and the product carrier -/

section Budget

/-- The type-pigeonhole budget IS the cardinality of the certificate layer's product carrier. -/
theorem card_prodState (Q : Type) [Fintype Q] (φ : PlusFormula) :
    Fintype.card (ProdState Q φ) = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by
  classical
  change Fintype.card (Q × ClType φ) = _
  rw [Fintype.card_prod]
  congr 1
  rw [show Fintype.card (ClType φ) = ((plusSubformulaClosure φ).powerset).card from
    Fintype.card_coe _, Finset.card_powerset]

/-- **`(K2)`'s cascade bound dominates the type-pigeonhole budget**, with the budget as its own
exponent. -/
theorem budget_le_cascadeBound {Q : Type} [Fintype Q] (pend : Q → Bool) (φ : PlusFormula) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1 ≤ cascadeBound pend φ := by
  classical
  rw [cascadeBound, ← card_prodState Q φ]
  have h1 : Fintype.card (ProdState Q φ) < 2 ^ Fintype.card (ProdState Q φ) :=
    Nat.lt_two_pow_self
  have h2 : 1 ≤ tIdle pend + 2 := by omega
  calc Fintype.card (ProdState Q φ) + 1
      ≤ 2 ^ Fintype.card (ProdState Q φ) := by omega
    _ ≤ 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2) :=
        Nat.le_mul_of_pos_right _ (by omega)

/-- **The budget is available at every `Tc` the parameter conditions admit**, through `(K2)` and
`cascadeBound` alone. -/
theorem budget_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1 ≤ Tc :=
  le_trans (budget_le_cascadeBound pend φ) hp.2.1.1

end Budget

/-! ## The strict one-step unfoldings of the two temporal equations -/

section Unfold

variable {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)

/-- `γ U ε` at `z` iff `ε` at `z + 1`, or `γ` and `γ U ε` at `z + 1`. -/
theorem untl_mem_tpOf_succ_iff (φ : PlusFormula) (σ : WorldHistory F.toTaskFrame) (z : ℤ)
    {γ ε : PlusFormula} (h : PlusFormula.untl γ ε ∈ plusSubformulaClosure φ) :
    PlusFormula.untl γ ε ∈ tpOf M φ σ z ↔
      (ε ∈ tpOf M φ σ (z + 1) ∨
        (γ ∈ tpOf M φ σ (z + 1) ∧ PlusFormula.untl γ ε ∈ tpOf M φ σ (z + 1))) := by
  rw [untl_mem_tpOf_iff M φ σ z h]
  constructor
  · rintro ⟨s, hs, hε, hgd⟩
    rcases lt_or_eq_of_le (show z + 1 ≤ s by omega) with hlt | heq
    · refine Or.inr ⟨hgd (z + 1) (by omega) hlt, ?_⟩
      rw [untl_mem_tpOf_iff M φ σ (z + 1) h]
      exact ⟨s, hlt, hε, fun r h1 h2 => hgd r (by omega) h2⟩
    · rw [← heq] at hε
      exact Or.inl hε
  · rintro (hε | ⟨hγ, hU⟩)
    · exact ⟨z + 1, by omega, hε, fun r h1 h2 => absurd h2 (by omega)⟩
    · rw [untl_mem_tpOf_iff M φ σ (z + 1) h] at hU
      obtain ⟨s, hs, hε, hgd⟩ := hU
      refine ⟨s, by omega, hε, fun r h1 h2 => ?_⟩
      rcases lt_or_eq_of_le (show z + 1 ≤ r by omega) with hlt | heq
      · exact hgd r hlt h2
      · rw [← heq]; exact hγ

/-- `γ S ε` at `z + 1` iff `ε` at `z`, or `γ` and `γ S ε` at `z`. -/
theorem snce_mem_tpOf_succ_iff (φ : PlusFormula) (σ : WorldHistory F.toTaskFrame) (z : ℤ)
    {γ ε : PlusFormula} (h : PlusFormula.snce γ ε ∈ plusSubformulaClosure φ) :
    PlusFormula.snce γ ε ∈ tpOf M φ σ (z + 1) ↔
      (ε ∈ tpOf M φ σ z ∨ (γ ∈ tpOf M φ σ z ∧ PlusFormula.snce γ ε ∈ tpOf M φ σ z)) := by
  rw [snce_mem_tpOf_iff M φ σ (z + 1) h]
  constructor
  · rintro ⟨s, hs, hε, hgd⟩
    rcases lt_or_eq_of_le (show s ≤ z by omega) with hlt | heq
    · refine Or.inr ⟨hgd z hlt (by omega), ?_⟩
      rw [snce_mem_tpOf_iff M φ σ z h]
      exact ⟨s, hlt, hε, fun r h1 h2 => hgd r h1 (by omega)⟩
    · rw [heq] at hε
      exact Or.inl hε
  · rintro (hε | ⟨hγ, hS⟩)
    · exact ⟨z, by omega, hε, fun r h1 h2 => absurd h1 (by omega)⟩
    · rw [snce_mem_tpOf_iff M φ σ z h] at hS
      obtain ⟨s, hs, hε, hgd⟩ := hS
      refine ⟨s, by omega, hε, fun r h1 h2 => ?_⟩
      rcases lt_or_eq_of_le (show r ≤ z by omega) with hlt | heq
      · exact hgd r h1 hlt
      · rw [heq]; exact hγ

end Unfold

/-! ## The realized types satisfy the local conditions -/

section Realized

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- A realized type as a closure component. -/
noncomputable def realizedCl (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) : ClType φ :=
  ⟨tpOf (ladderModel step pend fwd bwd lab) φ τ z,
    Finset.mem_powerset.mpr (tpOf_subset _ φ τ z)⟩

/-- **A realized type is locally coherent** at its own object state: the `atom` arm by the
ladder valuation, the `bot` and `imp` arms by the fixpoint equations. -/
theorem locCoh_of_realized (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {k : ℤ} {g : ℤ → LadderState Q pend}
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (z : ℤ) :
    locCoh lab φ (objAt g z, realizedCl fwd bwd lab φ τ z) = true := by
  unfold locCoh
  rw [decide_eq_true_eq]
  intro ψ hψ
  cases ψ with
  | atom a =>
      simp only [locPred, realizedCl]
      rw [beq_iff_eq]
      have key := atom_mem_tpOf_ladder_iff fwd bwd lab φ τ hτ z a
      cases h : lab (objAt g z) a
      · exact decide_eq_false (fun hm => by
          have := (key.mp hm).2
          rw [h] at this
          exact Bool.false_ne_true this)
      · exact decide_eq_true (key.mpr ⟨hψ, h⟩)
  | bot =>
      simp only [locPred, realizedCl]
      exact decide_eq_true (bot_not_mem_tpOf _ φ τ z)
  | imp α β =>
      simp only [locPred, realizedCl]
      have key := imp_mem_tpOf_iff (ladderModel step pend fwd bwd lab) φ τ z hψ
      by_cases hα : α ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ z <;>
        by_cases hβ : β ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ z <;>
        simp [key, hα, hβ]
  | box _ => rfl
  | untl _ _ => rfl
  | snce _ _ => rfl
  | stab _ => rfl

/-- **Consecutive realized types satisfy the forward link condition.** -/
theorem untlLink_of_realized (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) :
    untlLink φ (realizedCl fwd bwd lab φ τ z) (realizedCl fwd bwd lab φ τ (z + 1)) = true := by
  unfold untlLink
  rw [decide_eq_true_eq]
  intro ψ hψ
  cases ψ with
  | untl γ ε =>
      simp only [linkPred, realizedCl]
      have key := untl_mem_tpOf_succ_iff (ladderModel step pend fwd bwd lab) φ τ z hψ
      by_cases h1 : ε ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ (z + 1) <;>
        by_cases h2 : γ ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ (z + 1) <;>
        by_cases h3 :
          PlusFormula.untl γ ε ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ (z + 1) <;>
        simp [key, h1, h2, h3]
  | atom _ => rfl
  | bot => rfl
  | imp _ _ => rfl
  | box _ => rfl
  | snce _ _ => rfl
  | stab _ => rfl

/-- **Consecutive realized types satisfy the backward link condition.** -/
theorem snceLink_of_realized (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : ℤ) :
    snceLink φ (realizedCl fwd bwd lab φ τ z) (realizedCl fwd bwd lab φ τ (z + 1)) = true := by
  unfold snceLink
  rw [decide_eq_true_eq]
  intro ψ hψ
  cases ψ with
  | snce γ ε =>
      simp only [linkPredB, realizedCl]
      have key := snce_mem_tpOf_succ_iff (ladderModel step pend fwd bwd lab) φ τ z hψ
      by_cases h1 : ε ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ z <;>
        by_cases h2 : γ ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ z <;>
        by_cases h3 : PlusFormula.snce γ ε ∈ tpOf (ladderModel step pend fwd bwd lab) φ τ z <;>
        simp [key, h1, h2, h3]
  | atom _ => rfl
  | bot => rfl
  | imp _ _ => rfl
  | box _ => rfl
  | untl _ _ => rfl
  | stab _ => rfl

/-- **Consecutive `(objAt, tpOf)` pairs of a ladder history are `cohIdle`-linked.** -/
theorem cohIdle_of_realized (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {k : ℤ} {g : ℤ → LadderState Q pend}
    (hg : IsLadderPath step pend g)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (z : ℤ) :
    cohIdle step lab φ (objAt g z, realizedCl fwd bwd lab φ τ z)
      (objAt g (z + 1), realizedCl fwd bwd lab φ τ (z + 1)) = true := by
  simp only [cohIdle, Bool.and_eq_true]
  exact ⟨⟨⟨⟨objAt_step g hg z, locCoh_of_realized fwd bwd lab φ τ hτ z⟩,
    locCoh_of_realized fwd bwd lab φ τ hτ (z + 1)⟩, untlLink_of_realized fwd bwd lab φ τ z⟩,
    snceLink_of_realized fwd bwd lab φ τ z⟩

end Realized

/-! ## The bridge -/

section Bridge

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- The periodic walk of a type-respecting block: position `u + (i % l)`. -/
noncomputable def blockWalk (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (g : ℤ → LadderState Q pend)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (u : ℤ) (l : ℕ)
    (i : ℕ) : ProdState Q φ :=
  (objAt g (u + ((i % l : ℕ) : ℤ)), realizedCl fwd bwd lab φ τ (u + ((i % l : ℕ) : ℤ)))

/-- **The periodic walk of a type-respecting block is `cohIdle`-linked at every step**: inside
the block by `cohIdle_of_realized`, and at the wrap-around because the block's two ends carry
the same object state and the same realized type. -/
theorem blockWalk_cohIdle (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {k : ℤ} {g : ℤ → LadderState Q pend}
    (hg : IsLadderPath step pend g)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (u : ℤ) (l : ℕ) (hl : 0 < l)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ τ u
         = tpOf (ladderModel step pend fwd bwd lab) φ τ (u + (l : ℤ))) (i : ℕ) :
    cohIdle step lab φ (blockWalk fwd bwd lab φ g τ u l i)
      (blockWalk fwd bwd lab φ g τ u l (i + 1)) = true := by
  have hlt : i % l < l := Nat.mod_lt i hl
  rcases lt_or_eq_of_le (show i % l ≤ l - 1 by omega) with hmid | hend
  · -- inside the block: the next position is `u + (i % l) + 1`
    have hmod : (i + 1) % l = i % l + 1 := by
      rw [Nat.add_mod, Nat.one_mod_eq_one.mpr (by omega), Nat.mod_eq_of_lt (by omega)]
    simp only [blockWalk]
    rw [hmod, show u + ((i % l + 1 : ℕ) : ℤ) = u + ((i % l : ℕ) : ℤ) + 1 by push_cast; ring]
    exact cohIdle_of_realized fwd bwd lab φ hg τ hτ _
  · -- the wrap-around: from `u + l - 1` to `u`, which carries the type of `u + l`
    have hmod : (i + 1) % l = 0 := by
      have hdm := Nat.div_add_mod i l
      rw [hend] at hdm
      have h1 : i + 1 = l * (i / l + 1) := by rw [Nat.mul_add, Nat.mul_one]; omega
      rw [h1, Nat.mul_mod_right]
    have hcoh := cohIdle_of_realized fwd bwd lab φ hg τ hτ (u + ((l - 1 : ℕ) : ℤ))
    have hcast : u + ((l - 1 : ℕ) : ℤ) + 1 = u + (l : ℤ) := by
      push_cast [Nat.cast_sub (by omega : 1 ≤ l)]; ring
    rw [hcast] at hcoh
    have hcl : realizedCl fwd bwd lab φ τ (u + (l : ℤ)) = realizedCl fwd bwd lab φ τ u := by
      unfold realizedCl
      exact Subtype.ext hty.symm
    rw [hcl, ← hrep] at hcoh
    simp only [blockWalk]
    rw [hmod, hend]
    simpa using hcoh

/-- Every point of the periodic walk is saturated: the walk itself is its infinite forward
`cohIdle`-walk. -/
theorem blockWalk_satCl (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {k : ℤ} {g : ℤ → LadderState Q pend}
    (hg : IsLadderPath step pend g)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t + k, g t)) (u : ℤ) (l : ℕ) (hl : 0 < l)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ τ u
         = tpOf (ladderModel step pend fwd bwd lab) φ τ (u + (l : ℤ))) (i : ℕ) :
    SatCl step lab φ (blockWalk fwd bwd lab φ g τ u l i) :=
  ⟨fun j => blockWalk fwd bwd lab φ g τ u l (i + j), by simp, fun j => by
    dsimp only
    rw [show i + (j + 1) = i + j + 1 by ring]
    exact blockWalk_cohIdle fwd bwd lab φ hg τ hτ u l hl hrep hty (i + j)⟩

-- `linter.unusedVariables`, scoped to this declaration: the signature is pinned by the plan's
-- Lean Challenge Statements block, and `hno` is not read — the equality of the block's two
-- end types is all the cycle needs, whatever letters the closure carries.
set_option linter.unusedVariables false in
/-- **THE REALIZED-CHAIN BRIDGE.** A type-respecting block of a pending region, of length at most
the budget, is a `cohIdle`-cycle of the certificate graph through saturated, pending classes, so
its length is a member of the cycle-length set `(K1)` quantifies. -/
theorem realized_typeBlock_mem_prodCycleLens
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    {k : ℤ} {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t))
    (hg : IsLadderPath step pend g)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (u : ℤ) (l : ℕ) (hl : 0 < l)
    (hbud : l ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)
    (hpu : pend (objAt g u) = true) (hcl : l ≤ cntAt g u)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) :
    l ∈ prodCycleLens step pend lab φ := by
  refine ⟨hl, by rw [card_prodState]; exact hbud, blockWalk fwd bwd lab φ g σ u l,
    blockWalk_cohIdle fwd bwd lab φ hg σ hσ u l hl hrep hty, fun i => ?_,
    blockWalk_satCl fwd bwd lab φ hg σ hσ u l hl hrep hty, ?_⟩
  · -- every position of the block is pending
    change pend (objAt g (u + ((i % l : ℕ) : ℤ))) = true
    exact (cntAt_sub_of_pend g hg u hpu (i % l) (by have := Nat.mod_lt i hl; omega)).1
  · simp only [blockWalk, Nat.mod_self, Nat.zero_mod]

/-- **A type-respecting block's length divides `P + 1`** under `(K1)`. -/
theorem typeBlock_length_dvd_of_paramsOk
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {Tc Tn P B : ℕ}
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    {k : ℤ} {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t + k, g t))
    (hg : IsLadderPath step pend g)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (u : ℤ) (l : ℕ) (hl : 0 < l)
    (hbud : l ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)
    (hpu : pend (objAt g u) = true) (hcl : l ≤ cntAt g u)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) :
    l ∣ P + 1 :=
  hp.1.1 l (realized_typeBlock_mem_prodCycleLens step pend fwd bwd lab φ σ hσ hg hno u l hl hbud
    hpu hcl hrep hty)

end Bridge

end FormalSystem.Metalogic.Decidability.RaySummary
