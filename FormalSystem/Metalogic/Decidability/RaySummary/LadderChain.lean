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
`budget_le_Tc`). `(K2)` bounds `Tc` below by an EXPONENTIAL in the
product carrier's cardinality and not by the cardinality itself
(`two_pow_card_prodState_le_Tc`), which is the quantity a pigeonhole over the REGION STARTS of a
doubling chain consumes: a chain whose last region has countdown at least `Tc` carries on the
order of `log₂ Tc` region starts below it, and that bound makes `log₂ Tc` dominate the carrier's
cardinality.

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

/-- **`(K2)` IS AN EXPONENTIAL LOWER BOUND ON `Tc`**, not a linear one: `cascadeBound` carries
`2 ^ Fintype.card (ProdState Q φ)` as a factor, so every `Tc` the parameter conditions admit
dominates that power. This is the quantity a pigeonhole over the REGION STARTS of a doubling
chain consumes — a chain whose last region has countdown at least `Tc` carries on the order of
`log₂ Tc` region starts below it, and this bound is what makes `log₂ Tc` dominate the product
carrier's cardinality. The budget bound `budget_le_Tc` beside it is the weaker, linear-in-the-
carrier reading of the same conjunct. -/
theorem two_pow_card_prodState_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool)
    (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    2 ^ Fintype.card (ProdState Q φ) ≤ Tc := by
  refine le_trans ?_ hp.2.1.1
  rw [cascadeBound]
  exact Nat.le_mul_of_pos_right _ (by omega)

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

/-! ## The regime-A assembly: the countdown raised by a multiple of `P + 1`, the register held

Through a pending-forever path's state at countdown at least `Tc`, a ladder path with the
countdown raised by exactly `m · (P + 1)`, the register and the object state held, and the same
realized stab-free type. The pieces: `budget_le_Tc` makes the type pigeonhole available at `z`;
the pigeonhole yields a type-respecting block `[u, u + l)` of `z`'s region; the bridge puts `l`
among the divisors of `P + 1`; the iterated duplication, `d := m · ((P + 1) / l)` times, raises
`z`'s countdown by `d · l = m · (P + 1)` and preserves the realized type at `z`; and the register
is rebuilt by the landed lift with `z` translated to the origin and `n₀ := nxtAt g z` — the base
pin is admissible because the first pin above `z` is the original's first pin displaced by
`m · (P + 1)`, so the `1`-Lipschitz register of the original already bridges the shorter
distance. This is the upward shift with the register held. The downward direction's register
obstruction was an anchor-position mismatch, not a cascade: the landed lift is anchored at
position `0` while the deletion window sits at `z` and reads `l` positions to the right, so
composing them charges the `l`-shift against a distance from `0`. The z-anchored lift
`exists_ladderPath_of_walk_nxt_at` removes the mismatch, and the single-block downward assembly
`exists_ladderPath_through_deleted_of_pend_past` (below) lowers the countdown by one
type-respecting block with the register held — under the named hypothesis `HasForwardSlack`, one
inequality at the first region start above `z`'s region that the path's own facts do not
discharge. The cell-level downward inclusion still needs the exact-shift iteration of the
deletion. -/

section Assembly

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- The landed lift of a walk, with the register's base value exposed: `nxtAt g' 0 = n₀`. -/
theorem exists_ladderPath_of_walk_nxt (w : ℤ → Q) (c : ℤ → ℕ) (n₀ : ℕ)
    (hw : ∀ v, step (w v) (w (v + 1)) = true)
    (hidle : ∀ v, pend (w v) = false → c v = 0)
    (hpp : ∀ v, pend (w v) = true → pend (w (v + 1)) = true → c (v + 1) + 1 = c v)
    (hpi : ∀ v, pend (w v) = true → pend (w (v + 1)) = false → c v = 0)
    (hpins : ∀ s v, pend (w s) = false → pend (w (s + 1)) = true →
      pend (w v) = false → pend (w (v + 1)) = true →
      ((c (s + 1) : ℤ) - c (v + 1)).natAbs ≤ (s - v).natAbs)
    (hn₀ : ∀ v, pend (w v) = false → pend (w (v + 1)) = true →
      ((c (v + 1) : ℤ) - n₀).natAbs ≤ v.natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = w v) ∧ (∀ v, cntAt g' v = c v) ∧ nxtAt g' 0 = n₀ := by
  obtain ⟨n, hn0, hR⟩ :=
    exists_rlad_hist_of_walk step pend 0 w c n₀ hw hidle hpp hpi hpins hn₀
  refine ⟨fun v => ⟨(w v, c v, n v), fun h => hidle v h⟩, fun v => hR v, fun _ => rfl,
    fun _ => rfl, hn0⟩

/-- A ladder path translated by `z` is a ladder path. -/
theorem isLadderPath_shift {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g)
    (z : ℤ) : IsLadderPath step pend (fun v => g (v + z)) := fun v => by
  have := hg (v + z)
  rwa [show v + z + 1 = v + 1 + z by ring] at this

/-- **The landed lift with the anchor position freed.** `exists_ladderPath_of_walk_nxt` pins the
register's base value at the hardwired position `0`, measuring each pin's distance from `0`;
here the anchor is a parameter `z`, each pin's distance is measured from `z`, and the register
is exposed at `z`. The proof conjugates the landed lift with the translation: lift the walk read
from `z` (`fun v => w (v + z)`) with its countdown, then translate the result back by
`fun v => g₃ (v - z)`. With `z := 0` this recovers `exists_ladderPath_of_walk_nxt` verbatim. -/
theorem exists_ladderPath_of_walk_nxt_at (w : ℤ → Q) (c : ℤ → ℕ) (z : ℤ) (n₀ : ℕ)
    (hw : ∀ v, step (w v) (w (v + 1)) = true)
    (hidle : ∀ v, pend (w v) = false → c v = 0)
    (hpp : ∀ v, pend (w v) = true → pend (w (v + 1)) = true → c (v + 1) + 1 = c v)
    (hpi : ∀ v, pend (w v) = true → pend (w (v + 1)) = false → c v = 0)
    (hpins : ∀ s v, pend (w s) = false → pend (w (s + 1)) = true →
      pend (w v) = false → pend (w (v + 1)) = true →
      ((c (s + 1) : ℤ) - c (v + 1)).natAbs ≤ (s - v).natAbs)
    (hn₀ : ∀ v, pend (w v) = false → pend (w (v + 1)) = true →
      ((c (v + 1) : ℤ) - n₀).natAbs ≤ (v - z).natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = w v) ∧ (∀ v, cntAt g' v = c v) ∧ nxtAt g' z = n₀ := by
  -- the walk read from `z`, lifted with the anchor at the origin
  obtain ⟨g₃, hg₃, hobj₃, hcnt₃, hnxt₃⟩ :=
    exists_ladderPath_of_walk_nxt (fun v => w (v + z)) (fun v => c (v + z)) n₀
      (fun v => by
        rw [show v + 1 + z = v + z + 1 by ring]
        exact hw (v + z))
      (fun v h => hidle (v + z) h)
      (fun v h0 h1 => by
        rw [show v + 1 + z = v + z + 1 by ring]
        exact hpp (v + z) h0 (by rwa [show v + z + 1 = v + 1 + z by ring]))
      (fun v h0 h1 =>
        hpi (v + z) h0 (by rwa [show v + z + 1 = v + 1 + z by ring]))
      (fun s v hs0 hs1 hv0 hv1 => by
        have := hpins (s + z) (v + z) hs0 (by rwa [show s + z + 1 = s + 1 + z by ring])
          hv0 (by rwa [show v + z + 1 = v + 1 + z by ring])
        rwa [show s + z + 1 = s + 1 + z by ring, show v + z + 1 = v + 1 + z by ring,
          show s + z - (v + z) = s - v by ring] at this)
      (fun v h0 h1 => by
        have := hn₀ (v + z) h0 (by rwa [show v + z + 1 = v + 1 + z by ring])
        rwa [show v + z + 1 = v + 1 + z by ring, show v + z - z = v by ring] at this)
  -- translate back
  refine ⟨fun v => g₃ (v - z), ?_, ?_, ?_, ?_⟩
  · intro v
    have := hg₃ (v - z)
    rwa [show v - z + 1 = v + 1 - z by ring] at this
  · intro v
    change objAt g₃ (v - z) = _
    rw [hobj₃]
    rw [sub_add_cancel]
  · intro v
    change cntAt g₃ (v - z) = _
    rw [hcnt₃]
    rw [sub_add_cancel]
  · change nxtAt g₃ (z - z) = _
    rw [sub_self, hnxt₃]

end Assembly

section AssemblyFin

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE REGIME-A ASSEMBLY.** -/
theorem exists_ladderPath_through_shifted_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hTc : Tc ≤ cntAt g z) (m : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  have hz : pend (objAt g z) = true := hpast z le_rfl
  have hbud := budget_le_Tc step pend lab φ Tc Tn P B hp
  set b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card with hb
  -- a history of the original, and the type-respecting block of `z`'s region
  obtain ⟨σ₀, hσ₀⟩ := exists_hist_of_isLadderPath fwd bwd g hg
  have hσ₀' : ∀ t : ℤ, σ₀.state t = (t + 0, g t) := fun t => by rw [add_zero]; exact hσ₀ t
  obtain ⟨u, l, hl, hlb, hzu, hcl, hul, hrep, hty⟩ :=
    exists_typeBlock_of_budget_le_cnt_within step pend fwd bwd lab φ σ₀ hg z hz (by omega)
  -- every position up to `u` is pending: below `z` by hypothesis, from `z` to `u` by the region
  have hpast_u : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true := fun p hp' => by
    rcases le_or_gt p z with hpz | hpz
    · exact hpast p hpz
    · have := (cntAt_sub_of_pend g hg z hz (p - z).toNat (by omega)).1
      rwa [show z + (((p - z).toNat : ℕ) : ℤ) = p by omega] at this
  have hpu : pend (objAt g u) = true := hpast_u u le_rfl
  -- the block's length divides `P + 1`
  obtain ⟨q, hq⟩ := typeBlock_length_dvd_of_paramsOk step pend fwd bwd lab φ hp σ₀ hσ₀' hg hno
    u l hl hlb hpu hcl hrep hty
  set d := m * q with hd
  have hdl : d * l = m * (P + 1) := by rw [hd, hq]; ring
  -- the iterated duplication
  obtain ⟨g₁, hg₁, hobj₁, hend₁, hcnt₁, hpend₁, habove₁, hty₁⟩ :=
    exists_iterSpliced_ladderPath_of_pend_past step pend fwd bwd lab φ hno hg hl hcl hpast_u hrep
      σ₀ hσ₀ hty d
  have hcz : cntAt g₁ z = cntAt g z + m * (P + 1) := by
    rw [hcnt₁ z hzu (by omega), hdl]
  have hoz : objAt g₁ z = objAt g z := hobj₁ z (by omega)
  -- every position of `g₁` below `u + (d + 1) l` is pending
  have hpend_all : ∀ v : ℤ, v < u + ((d + 1) * l : ℕ) → pend (objAt g₁ v) = true := fun v hv => by
    rcases lt_or_ge v u with hvu | hvu
    · rw [hobj₁ v (by omega)]; exact hpast_u v (le_of_lt hvu)
    · exact hpend₁ v hvu hv
  -- the register, rebuilt with `z` at the origin
  let w : ℤ → Q := fun v => objAt g₁ (v + z)
  let c : ℤ → ℕ := fun v => cntAt g₁ (v + z)
  have hg₂ : IsLadderPath step pend (fun v => g₁ (v + z)) := isLadderPath_shift hg₁ z
  have hw : ∀ v, step (w v) (w (v + 1)) = true := fun v => by
    have := objAt_step _ hg₂ v
    exact this
  have hidle : ∀ v, pend (w v) = false → c v = 0 := fun v h =>
    cntAt_eq_zero_of_idle _ hg₂ v h
  have hpp : ∀ v, pend (w v) = true → pend (w (v + 1)) = true → c (v + 1) + 1 = c v :=
    fun v h0 h1 => cntAt_succ_of_pend_pend _ hg₂ v h0 h1
  have hpi : ∀ v, pend (w v) = true → pend (w (v + 1)) = false → c v = 0 :=
    fun v h0 h1 => (cntAt_eq_zero_of_pend_idle _ hg₂ v h0 h1).1
  have hpins : ∀ s v, pend (w s) = false → pend (w (s + 1)) = true →
      pend (w v) = false → pend (w (v + 1)) = true →
      ((c (s + 1) : ℤ) - c (v + 1)).natAbs ≤ (s - v).natAbs :=
    fun s v hs0 hs1 hv0 hv1 => pinCompat_of_ladderPath _ hg₂ s v hs0 hs1 hv0 hv1
  have hn₀ : ∀ v, pend (w v) = false → pend (w (v + 1)) = true →
      ((c (v + 1) : ℤ) - nxtAt g z).natAbs ≤ v.natAbs := fun v h0 h1 => by
    -- the pin sits above every copy, where `g₁` is the original displaced by `d · l`
    have hge : u + ((d + 1) * l : ℕ) ≤ v + z := by
      by_contra hlt
      rw [not_le] at hlt
      exact Bool.false_ne_true (h0.symm.trans (hpend_all (v + z) hlt))
    obtain ⟨ho0, -⟩ := habove₁ (v + z) hge
    obtain ⟨ho1, hc1⟩ := habove₁ (v + z + 1) (by omega)
    have h0' : pend (objAt g (v + z - (d * l : ℕ))) = false := by
      have : pend (objAt g₁ (v + z)) = false := h0
      rwa [ho0] at this
    have h1' : pend (objAt g (v + z - (d * l : ℕ) + 1)) = true := by
      have : pend (objAt g₁ (v + 1 + z)) = true := h1
      rwa [show v + 1 + z = v + z + 1 by ring, ho1,
        show v + z + 1 - (d * l : ℕ) = v + z - (d * l : ℕ) + 1 by ring] at this
    have hpin := cntAt_eq_nxtAt_of_idle_pend g hg _ h0' h1'
    have hc : (c (v + 1) : ℤ) = nxtAt g (v + z - (d * l : ℕ)) := by
      change (cntAt g₁ (v + 1 + z) : ℤ) = _
      rw [show v + 1 + z = v + z + 1 by ring, hc1,
        show v + z + 1 - (d * l : ℕ) = v + z - (d * l : ℕ) + 1 by ring, hpin]
    rw [hc]
    have hlip := nxtAt_lipschitz_two_sided g hg (v + z - (d * l : ℕ)) z
    have hge' : u + ((d * l : ℕ) : ℤ) + (l : ℤ) ≤ v + z := by
      have e : (((d + 1) * l : ℕ) : ℤ) = ((d * l : ℕ) : ℤ) + (l : ℤ) := by push_cast; ring
      rw [e] at hge
      omega
    have hnn : (0 : ℤ) ≤ ((d * l : ℕ) : ℤ) := Int.natCast_nonneg _
    omega
  obtain ⟨g₃, hg₃, hobj₃, hcnt₃, hnxt₃⟩ :=
    exists_ladderPath_of_walk_nxt w c (nxtAt g z) hw hidle hpp hpi hpins hn₀
  -- translate back
  refine ⟨fun v => g₃ (v - z), ?_, ?_, ?_, ?_, fun σ σ' hσ hσ' => ?_⟩
  · intro v
    have := hg₃ (v - z)
    rwa [show v - z + 1 = v + 1 - z by ring] at this
  · change objAt g₃ (z - z) = _
    rw [sub_self, hobj₃]
    change objAt g₁ (0 + z) = _
    rw [zero_add, hoz]
  · change cntAt g₃ (z - z) = _
    rw [sub_self, hcnt₃]
    change cntAt g₁ (0 + z) = _
    rw [zero_add, hcz]
  · change nxtAt g₃ (z - z) = _
    rw [sub_self, hnxt₃]
  · -- the realized type at `z`: `g'` has `g₁`'s object walk, whose type at `z` is `g`'s
    have hobj' : ∀ v : ℤ, objAt (fun v => g₃ (v - z)) v = objAt g₁ v := fun v => by
      change objAt g₃ (v - z) = _
      rw [hobj₃]
      change objAt g₁ (v - z + z) = _
      rw [sub_add_cancel]
    obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
    have e1 : tpOf (ladderModel step pend fwd bwd lab) φ σ' z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ z :=
      tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ₁
        (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ₁ t)
        hobj' hno z
    have e2 := (hty₁ σ₁ hσ₁).1 z (by omega)
    have e3 : tpOf (ladderModel step pend fwd bwd lab) φ σ₀ z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z :=
      tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ
        hσ₀' (fun t => by rw [add_zero]; exact hσ t) (fun _ => rfl) hno z
    rw [e1, e2, e3]

end AssemblyFin

/-! ## The deletion with the register exposed

The landed deletion theorem `exists_deleted_ladderPath_of_pend_past` (`LadderPump.lean`) exposes
only the object walk and the countdown of the deleted path, because it calls
`exists_ladderPath_of_walk` rather than the register-exposing lift; the consumer
`cellAt_subset_of_shift_of_pend_past` reads `nxtAt g z = n` and needs `nxtAt g' z = n` on the
replacement path. This section re-runs the same construction through the z-anchored lift
`exists_ladderPath_of_walk_nxt_at`, reusing the five landed counter and pin clauses verbatim,
and makes the register's anchor clause an explicit hypothesis on the pins above the block. -/

section DelNxt

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE DELETION WITH THE REGISTER EXPOSED AT `z`.** The landed deletion theorem's five
clauses (`delObj_step`, `delCnt_idle`, `delCnt_pend_pend`, `delCnt_pend_idle`, and the pin
compatibility through `pinCompat_of_ladderPath`) are reused untouched; the one new hypothesis
is the anchor clause `hanch`: every pin of the deleted walk — a region start `v + l` of the
original with `a < v`, read at the deleted position `v` — carries a register value within
`|v − z|` of `n`. The landed theorem discharges this clause internally with `z := 0` and
`n := nxtAt g l`, by `nxtAt_lipschitz_two_sided g hg (v + l) l` and the rewrite `v + l − l = v`;
exposing it here lets the anchor be chosen at the consumer's position `z` with the consumer's
value `n`, and the clause is reduced to a single pin by the collapse lemma that follows. -/
theorem exists_deleted_ladderPath_of_pend_past_nxt
    {g : ℤ → LadderState Q pend} {a : ℤ} {l : ℕ}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hpast : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (z : ℤ) (n : ℕ)
    (hanch : ∀ v : ℤ, a < v → pend (objAt g (v + (l : ℤ))) = false →
      pend (objAt g (v + (l : ℤ) + 1)) = true →
      ((nxtAt g (v + (l : ℤ)) : ℤ) - n).natAbs ≤ (v - z).natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = delObj g a l v) ∧ (∀ v, cntAt g' v = delCnt g a l v) ∧
      nxtAt g' z = n := by
  -- every region start of the deleted walk sits above `a`
  have hstart : ∀ s : ℤ, pend (delObj g a l s) = false → a < s := by
    intro s hs
    by_contra hle
    exact Bool.false_ne_true
      (hs.symm.trans (delObj_pend_of_le_of_pend_past hrep hpast s (by omega)))
  -- and is the original's own region start, displaced by `-l`
  have hpull : ∀ s : ℤ, pend (delObj g a l s) = false →
      pend (delObj g a l (s + 1)) = true →
      pend (objAt g (s + (l : ℤ))) = false ∧ pend (objAt g (s + (l : ℤ) + 1)) = true ∧
        delCnt g a l (s + 1) = cntAt g (s + (l : ℤ) + 1) := by
    intro s h0 h1
    have hgt := hstart s h0
    rw [delObj_of_ge s (by omega)] at h0
    rw [delObj_of_ge (s + 1) (by omega), show s + 1 + (l : ℤ) = s + (l : ℤ) + 1 by ring] at h1
    refine ⟨h0, h1, ?_⟩
    rw [delCnt_of_ge (s + 1) (by omega), show s + 1 + (l : ℤ) = s + (l : ℤ) + 1 by ring]
  refine exists_ladderPath_of_walk_nxt_at (delObj g a l) (delCnt g a l) z n
    (delObj_step hg hrep) (delCnt_idle hg) (delCnt_pend_pend hg hl hcl)
    (delCnt_pend_idle hg hl hcl) (fun s v hs0 hs1 hv0 hv1 => ?_) (fun v hv0 hv1 => ?_)
  · obtain ⟨hs0', hs1', hsc⟩ := hpull s hs0 hs1
    obtain ⟨hv0', hv1', hvc⟩ := hpull v hv0 hv1
    rw [hsc, hvc]
    have := pinCompat_of_ladderPath g hg (s + (l : ℤ)) (v + (l : ℤ)) hs0' hs1' hv0' hv1'
    rw [show s + (l : ℤ) - (v + (l : ℤ)) = s - v by ring] at this
    exact this
  · obtain ⟨hv0', hv1', hvc⟩ := hpull v hv0 hv1
    rw [hvc, cntAt_eq_nxtAt_of_idle_pend g hg (v + (l : ℤ)) hv0' hv1']
    exact hanch v (hstart v hv0) hv0' hv1'

/-- **THE COLLAPSE OF THE ANCHOR CLAUSE TO THE FIRST REGION START.** Every pin of the deleted
walk is a region start `v + l` of the original lying above `a`, hence above the end `z + cntAt g z`
of `z`'s region, hence at or after the idle position `z + cntAt g z + I` just before the FIRST
region start above that end (found by `Nat.find` on the offset past `z + cntAt g z + 1`, the
mirror of `cntAt_le_nxtAt_succ_of_idle_past`'s backward search). The register's value at the pin
is within `v + l − (z + cntAt g z + I)` of its value at that idle position
(`nxtAt_lipschitz_two_sided`), and `hfirst` bounds the latter within `cntAt g z + I − l` of `n`;
the two summands add to `v − z` exactly, so the anchor clause at every pin follows from the
single inequality at the nearest one. The hypothesis is stated on the ORIGINAL path only, so the
collapse and the deletion do not entangle. -/
theorem anchor_clause_of_first_region_start (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (hz : pend (objAt g z) = true) (l n : ℕ)
    (hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) : ℤ) - n).natAbs
        ≤ ((cntAt g z : ℤ) + I - l).natAbs)
    (a : ℤ) (hza : z ≤ a) (hal : a + (l : ℤ) ≤ z + (cntAt g z : ℤ)) :
    ∀ v : ℤ, a < v → pend (objAt g (v + (l : ℤ))) = false →
      pend (objAt g (v + (l : ℤ) + 1)) = true →
      ((nxtAt g (v + (l : ℤ)) : ℤ) - n).natAbs ≤ (v - z).natAbs := by
  classical
  intro v hav hv0 hv1
  -- the pin lies strictly above the region's end, which is pending throughout
  have hvC : z + (cntAt g z : ℤ) < v + (l : ℤ) := by
    by_contra hle
    rw [not_lt] at hle
    have := (cntAt_sub_of_pend g hg z hz (v + (l : ℤ) - z).toNat (by omega)).1
    rw [show z + (((v + (l : ℤ) - z).toNat : ℕ) : ℤ) = v + (l : ℤ) by omega] at this
    exact Bool.false_ne_true (hv0.symm.trans this)
  -- the first pending position after the region's end, found by its offset
  have hex : ∃ k : ℕ, pend (objAt g (z + (cntAt g z : ℤ) + 1 + (k : ℤ))) = true :=
    ⟨(v + (l : ℤ) - (z + (cntAt g z : ℤ))).toNat, by
      rw [show z + (cntAt g z : ℤ) + 1 + (((v + (l : ℤ) - (z + (cntAt g z : ℤ))).toNat : ℕ) : ℤ)
          = v + (l : ℤ) + 1 by omega]
      exact hv1⟩
  set I := Nat.find hex with hI
  have hnext : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true := Nat.find_spec hex
  have hidle : ∀ i : ℕ, i < I →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false := by
    intro i hi
    have := Nat.find_min hex (m := i) (by omega)
    rw [Bool.not_eq_true] at this
    exact this
  -- the idle run is non-empty: the region's end forces an idle successor
  have hIpos : 0 < I := by
    rcases Nat.eq_zero_or_pos I with h | h
    · exfalso
      have h0 := not_pend_of_count g hg z hz
      rw [h, show z + (cntAt g z : ℤ) + 1 + ((0 : ℕ) : ℤ) = z + (cntAt g z : ℤ) + 1 by
        push_cast; ring] at hnext
      exact Bool.false_ne_true (h0.symm.trans hnext)
    · exact h
  -- the pin sits at or after the idle position before the first region start
  have hvs : z + (cntAt g z : ℤ) + (I : ℤ) ≤ v + (l : ℤ) := by
    by_contra hlt
    rw [not_le] at hlt
    have := hidle (v + (l : ℤ) - (z + (cntAt g z : ℤ))).toNat (by omega)
    rw [show z + (cntAt g z : ℤ) + 1 + (((v + (l : ℤ) - (z + (cntAt g z : ℤ))).toNat : ℕ) : ℤ)
        = v + (l : ℤ) + 1 by omega] at this
    exact Bool.false_ne_true (this.symm.trans hv1)
  -- the triangle through the first region start
  have hbound := hfirst I hIpos hidle hnext
  have hlip := nxtAt_lipschitz_two_sided g hg (v + (l : ℤ)) (z + (cntAt g z : ℤ) + (I : ℤ))
  omega

/-- **THE FORWARD-SLACK HYPOTHESIS: a regime restriction on ONE region start, with a finite
witness.** The collapse above reduces the anchor clause to the two-sided bound
`|nxtAt g s₀ − n| ≤ cntAt g z + I − l` at the idle position `s₀ = z + cntAt g z + I` before the
first region start above `z`'s region. Its lower direction follows from the consumer's gap
hypothesis `n + l ≤ cntAt g z` alone. Its upper direction, stated here over `ℤ` to avoid
truncated subtraction, is NOT implied by anything the path carries: `nxtAt_lipschitz_two_sided`
gives only `nxtAt g s₀ ≤ nxtAt g z + cntAt g z + I`, and the forward window
`nxtAt_le_cntAt_add_of_next_region` bounds the register at `z` from above by the next region's
countdown, which is the free direction. The gate's `omega` run on the three facts closes the
lower direction and leaves the upper one open with the arithmetic witness
`n = 0, cntAt g z = 3, I = 1, l = 1, nxtAt g s₀ = 4`, which satisfies the gap, the Lipschitz
bound, and the window and violates this inequality by exactly `l`. The path-level reading of
that witness: the register relation `Drift` (`RunLayer.lean`) admits the rung `n' = n + 1` at
every step, so a ladder path whose register climbs by one per step from `z` to `s₀` — realized
on any object with one pending and one idle state — satisfies every hypothesis of the deletion
and has no room to shorten the chain by `l`. The hypothesis is therefore a property of a PATH,
quantified over the single idle position it constrains; no hypothesis on the counter STATE
`(q, c, n)` at `z` can replace it, because the cell's universal quantification over paths
through the state ranges over the climbing path too. -/
def HasForwardSlack (g : ℤ → LadderState Q pend) (z : ℤ) (l n : ℕ) : Prop :=
  ∀ I : ℕ, 0 < I →
    (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
    pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
    (nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) : ℤ) ≤ (n : ℤ) + cntAt g z + I - l

end DelNxt

/-! ## The single-block downward assembly: the countdown lowered by the block's length, the
register held

The mirror of the regime-A assembly for ONE block. Through a pending-forever path's state at `z`
with countdown at least `Tc`, a ladder path with the countdown LOWERED by the type-respecting
block's length `l` (a divisor of `P + 1`), the object state and the register at `z` held, and the
same realized stab-free type at `z`. The register is rebuilt by the z-anchored deletion with
`n := nxtAt g z`, and its anchor clause is reduced to the first region start by the collapse; the
single inequality left there is NOT discharged from the path's own facts (the gate's verdict),
so it is carried as the named hypothesis `HasForwardSlack g z (P + 1) (nxtAt g z)`. -/

section DelNxtFin

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE SINGLE-BLOCK DOWNWARD ASSEMBLY, under the forward-slack hypothesis.** The gate on the
residual inequality FAILED in its upper direction (see `HasForwardSlack`), so this is the
regime-restricted branch: beyond the upward mirror's hypotheses and the gap
`nxtAt g z + (P + 1) ≤ cntAt g z`, the consumer must supply
`HasForwardSlack g z (P + 1) (nxtAt g z)`, one inequality at one region start, and the
`l`-instance the block needs follows from it by monotonicity (`l ≤ P + 1`). Nothing is weakened
under an existing name, and the reserved name
`cellLE_zero_const_of_kappa_eq` remains claimed by nothing. Two pieces still separate this from
the cell-level downward inclusion `cellAt … (q, c + m · (P + 1), n) ⊆ cellAt … (q, c, n)`: the
exact-shift ITERATION of the deletion (deleting `(P + 1) / l` blocks needs that many consecutive
type-equal copies in the ORIGINAL, which the pigeonhole does not supply, whereas the upward
iteration manufactures its copies by splicing), and the PATH-versus-STATE quantification (the
forward slack is a property of a path, and the cell quantifies over every path through the
state, the climbing-register path included). -/
theorem exists_ladderPath_through_deleted_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hTc : Tc ≤ cntAt g z)
    (hgap : nxtAt g z + (P + 1) ≤ cntAt g z)
    (hslack : HasForwardSlack g z (P + 1) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧
      (∃ l : ℕ, 0 < l ∧ l ∣ P + 1 ∧ cntAt g' z + l = cntAt g z) ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  have hz : pend (objAt g z) = true := hpast z le_rfl
  have hbud := budget_le_Tc step pend lab φ Tc Tn P B hp
  -- a history of the original, and the type-respecting block of `z`'s region
  obtain ⟨σ₀, hσ₀⟩ := exists_hist_of_isLadderPath fwd bwd g hg
  have hσ₀' : ∀ t : ℤ, σ₀.state t = (t + 0, g t) := fun t => by rw [add_zero]; exact hσ₀ t
  obtain ⟨u, l, hl, hlb, hzu, hcl, hul, hrep, hty⟩ :=
    exists_typeBlock_of_budget_le_cnt_within step pend fwd bwd lab φ σ₀ hg z hz (by omega)
  -- the block lies inside `z`'s region
  have hul' : u + (l : ℤ) ≤ z + (cntAt g z : ℤ) := by omega
  -- every position up to `u` is pending: below `z` by hypothesis, from `z` to `u` by the region
  have hpast_u : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true := fun p hp' => by
    rcases le_or_gt p z with hpz | hpz
    · exact hpast p hpz
    · have := (cntAt_sub_of_pend g hg z hz (p - z).toNat (by omega)).1
      rwa [show z + (((p - z).toNat : ℕ) : ℤ) = p by omega] at this
  have hpu : pend (objAt g u) = true := hpast_u u le_rfl
  -- the block's length divides `P + 1`
  have hdvd : l ∣ P + 1 := typeBlock_length_dvd_of_paramsOk step pend fwd bwd lab φ hp σ₀ hσ₀'
    hg hno u l hl hlb hpu hcl hrep hty
  have hlP : l ≤ P + 1 := Nat.le_of_dvd (Nat.succ_pos P) hdvd
  -- the single-pin bound, from the gap and the forward slack; then the collapse
  have hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) : ℤ) - nxtAt g z).natAbs
        ≤ ((cntAt g z : ℤ) + I - l).natAbs := fun I hI hidle hnext => by
    have := hslack I hI hidle hnext
    omega
  have hanch := anchor_clause_of_first_region_start g hg z hz l (nxtAt g z) hfirst u hzu hul'
  -- the deleted path, with the register held at `z`
  obtain ⟨g', hg', hobj', hcnt', hnxt'⟩ :=
    exists_deleted_ladderPath_of_pend_past_nxt hg hl hcl hpast_u hrep z (nxtAt g z) hanch
  refine ⟨g', hg', ?_, ⟨l, hl, hdvd, ?_⟩, hnxt', fun σ σ' hσ hσ' => ?_⟩
  · rw [hobj' z, delObj_eq_of_le hrep z hzu]
  · rw [hcnt' z, delCnt_sub_of_mem_region hg hl hcl z hzu (by omega)]
    omega
  · -- the realized type at `z`, read through `delIdx u l`
    have hσ0 : ∀ t : ℤ, σ.state t = (t + 0, g t) := fun t => by rw [add_zero]; exact hσ t
    have hσ'0 : ∀ t : ℤ, σ'.state t = (t + 0, g' t) := fun t => by rw [add_zero]; exact hσ' t
    have hty_σ : tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ)) := by
      have e1 := tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ hσ₀' hσ0
        (fun _ => rfl) hno u
      have e2 := tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ hσ₀' hσ0
        (fun _ => rfl) hno (u + (l : ℤ))
      rw [← e1, ← e2]
      exact hty
    have hdel := tpOf_eq_delIdx_of_tpOf_eq step pend fwd bwd lab φ u l hl (k := 0) (k' := 0)
      σ σ' hσ0 hσ'0 (fun w => (hobj' w).trans rfl) hno hty_σ z
    rw [hdel]
    rcases lt_or_eq_of_le hzu with hlt | heq
    · rw [delIdx_of_lt u l z hlt]
    · rw [heq, delIdx_of_ge u l u le_rfl, ← hty_σ]

end DelNxtFin

/-- **THE UPWARD CELL INCLUSION along the common-shift chain.** In the pending-forever regime
(`n + 2 ≤ c`, so by `pend_past_of_nxtAt_lt` every path through the state is pending forever into
the past) at countdown at least `Tc`, the cell at `(q, c, n)` is contained in the cell at
`(q, c + m · (P + 1), n)`: every type realized at the former is realized at the latter by the
regime-A assembly. The downward inclusion is not claimed at the cell level: its single-block,
path-level form is `exists_ladderPath_through_deleted_of_pend_past`, under the forward-slack
hypothesis `HasForwardSlack` on the path, and the exact-shift iteration of the deletion is the
piece still missing. Under `kappa_eq_components` this covers the sub-regime `n = n'`;
the common shift `n' = n + m · (P + 1)` is the same construction with `n₀ := n'` inside the
widened window and is not stated here. -/
theorem cellAt_subset_of_shift_of_pend_past {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (z : ℤ) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  intro T hT
  rw [mem_cellAt_ladder_iff] at hT ⊢
  obtain ⟨g, τ, hg, hgz, hτ, hT⟩ := hT
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n := by simp [nxtAt, hgz]
  have hz : pend (objAt g z) = true := by
    by_contra hne
    rw [Bool.not_eq_true, hoz] at hne
    have := h hne
    omega
  have hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; exact hgap)
  obtain ⟨g', hg', ho, hc, hn, hty⟩ :=
    exists_ladderPath_through_shifted_of_pend_past step pend fwd bwd lab φ Tc Tn P B hp hno g hg
      z hpast (by rw [hcz]; exact hTc) m
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c + m * (P + 1), n)
    rw [ho, hc, hn, hoz, hcz, hnz]
  · rw [hty τ τ' hτ hτ', hT]

end FormalSystem.Metalogic.Decidability.RaySummary
