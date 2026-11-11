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

Beyond the bridge, the two assemblies and their cell-level consumers. UPWARD: the regime-A
assembly `exists_ladderPath_through_shifted_of_pend_past` (a corollary of the register-held
iterated duplication of a given block, `exists_ladderPath_through_iterSpliced_nxt_of_pend_past`)
and the upward cell inclusion `cellAt_subset_of_shift_of_pend_past`. DOWNWARD, under the
forward-slack regime: the deletion with the register exposed and the collapse of its anchor
clause to the first region start; the regime `HasForwardSlack` with its entry lemma (a finite
witness, `hasForwardSlack_of_next_region_cnt_le`), monotonicity, transport across a deletion and
vacuity (`section Slack`); the two-state witness `ClimbWitness`, showing the regime NECESSARY (the
climbing-register path refutes the unconditional claim) and INHABITED at every amount (the
plateau); the room bound `budget_mul_succ_le_Tc` and the spaced pigeonhole
`exists_typeBlock_of_spacing`; the iterated splice index map `iterSpliceIdx` with the iterated
duplication and the register-held wrapper read through it
(`exists_iterSpliced_ladderPath_idx_of_pend_past`,
`exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past`: the walk and the realized types
exposed at EVERY position, in particular at every copy boundary) and the slack transport across
a raise (`hasForwardSlack_raise`); the one-step deletion and the overshoot loop with the sampling
window as their room hypothesis; the UP-FIRST EXACT-SHIFT theorem
`exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` (raise by `budget` copies of the
original block first, overshoot above the run, delete the exact remainder inside it: the
countdown lowered by exactly `m · (P + 1)`, the register and the realized type held, under the
gap and the regime at EXACTLY `m · (P + 1)`); and its consumer, the downward cell inclusion ON
THE WITNESSING PATH, `mem_cellAt_of_shift_of_hasForwardSlack_exact`, under exactly `n + 2 ≤ c`,
`Tc ≤ c` and the regime at `m · (P + 1)`. The same statements with a `budget²` slack term in
both anchor directions, `exists_ladderPath_through_deleted_exact_of_pend_past` and
`mem_cellAt_of_shift_of_hasForwardSlack`, are corollaries.

## What this module does NOT hold

No cell-level agreement: the reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing,
because the obligation quantifies over every path through the state and concludes cell EQUALITY,
and no STATE-level downward inclusion can be stated under a path-level regime (the climbing path
passes through a state satisfying every state-level hypothesis the consumer carries). The
downward inclusion held here is the path-level one above.
-/

set_option linter.style.longFile 2700

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

/-- **`(K2)` dominates `budget · (budget + 1)`**: the room a `(budget + 1)`-sample window at
spacing at most `budget` needs inside a region of countdown at least `Tc`. From `cascadeBound`
alone, by `b · (b + 1) ≤ 2 ^ b · 3 ≤ 2 ^ b · (tIdle pend + 2)`. -/
theorem budget_mul_succ_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) ≤ Tc := by
  classical
  refine le_trans ?_ hp.2.1.1
  rw [cascadeBound, ← card_prodState Q φ]
  have h3 : 3 ≤ tIdle pend + 2 := by unfold tIdle; omega
  have key : ∀ b : ℕ, b * (b + 1) ≤ 2 ^ b * 3 := by
    intro b
    induction b with
    | zero => simp
    | succ k ih =>
        have hk : k < 2 ^ k := Nat.lt_two_pow_self
        rw [pow_succ]
        nlinarith
  calc Fintype.card (ProdState Q φ) * (Fintype.card (ProdState Q φ) + 1)
      ≤ 2 ^ Fintype.card (ProdState Q φ) * 3 := key _
    _ ≤ 2 ^ Fintype.card (ProdState Q φ) * (tIdle pend + 2) := Nat.mul_le_mul_left _ h3

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

/-! ## The spaced type pigeonhole

`exists_typeBlock_of_budget_le_cnt_within` (`LadderPump.lean`) samples consecutive positions and
returns a block of length at most the budget. The overshoot loop needs its samples at a prescribed
spacing `s` so that every block it deletes has length a multiple of `s`: among `budget + 1`
samples at spacing `s` from `w₀` inside `z`'s region, two share `(objAt, tpOf)`, giving a
type-respecting block of length `d · s` with `1 ≤ d ≤ budget` lying in the sampling window
`[w₀, w₀ + budget · s]`. The room bound `budget_mul_succ_le_Tc` is what makes that window fit
inside a region of countdown at least `Tc` when `s ≤ budget`. -/

section Spacing

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE SPACED TYPE PIGEONHOLE.** Among `budget + 1` samples at spacing `s` from `w₀` inside
`z`'s region, two share `(objAt, tpOf)`: a type-respecting block of length `d · s` with
`1 ≤ d ≤ budget`, lying in the sampling window. -/
theorem exists_typeBlock_of_spacing {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hg : IsLadderPath step pend g) (z : ℤ) (hz : pend (objAt g z) = true)
    (w₀ : ℤ) (s : ℕ) (hzw : z ≤ w₀)
    (hroom : w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * s : ℕ) : ℤ)
      ≤ z + (cntAt g z : ℤ)) :
    ∃ (u : ℤ) (d : ℕ), 0 < d ∧
      d ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      w₀ ≤ u ∧
      u + ((d * s : ℕ) : ℤ)
        ≤ w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * s : ℕ) : ℤ) ∧
      d * s ≤ cntAt g u ∧
      objAt g u = objAt g (u + ((d * s : ℕ) : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + ((d * s : ℕ) : ℤ)) := by
  classical
  set b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card with hb
  let f : Fin (b + 1) → Q × {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset} :=
    fun i => (objAt g (w₀ + (((i : ℕ) * s : ℕ) : ℤ)),
      ⟨tpOf (ladderModel step pend fwd bwd lab) φ σ (w₀ + (((i : ℕ) * s : ℕ) : ℤ)),
        Finset.mem_powerset.mpr (tpOf_subset _ φ σ _)⟩)
  obtain ⟨a, c, hac, hf⟩ := Fintype.exists_ne_map_eq_of_card_lt f (by
    rw [Fintype.card_prod, Fintype.card_coe, Finset.card_powerset, Fintype.card_fin]
    omega)
  have hf' : f a = f c := hf
  simp only [f, Prod.mk.injEq, Subtype.mk.injEq] at hf'
  obtain ⟨hobj, hty⟩ := hf'
  have ha : (a : ℕ) ≤ b := by omega
  have hc : (c : ℕ) ≤ b := by omega
  have hcnt : ∀ i : ℕ, i ≤ b → ∀ d : ℕ,
      w₀ + ((i * s : ℕ) : ℤ) + ((d * s : ℕ) : ℤ) ≤ z + (cntAt g z : ℤ) →
      d * s ≤ cntAt g (w₀ + ((i * s : ℕ) : ℤ)) := by
    intro i hi d hd
    have hle : (w₀ + ((i * s : ℕ) : ℤ) - z).toNat ≤ cntAt g z := by
      have : ((d * s : ℕ) : ℤ) ≥ 0 := Int.natCast_nonneg _
      omega
    have := (cntAt_sub_of_pend g hg z hz _ hle).2
    rw [show z + (((w₀ + ((i * s : ℕ) : ℤ) - z).toNat : ℕ) : ℤ) = w₀ + ((i * s : ℕ) : ℤ) by
      omega] at this
    omega
  rcases lt_or_gt_of_ne (fun h : (a : ℕ) = (c : ℕ) => hac (Fin.ext h)) with hlt | hlt
  · have hcast : w₀ + (((a : ℕ) * s : ℕ) : ℤ) + ((((c : ℕ) - (a : ℕ)) * s : ℕ) : ℤ)
        = w₀ + (((c : ℕ) * s : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    have hwin : w₀ + (((c : ℕ) * s : ℕ) : ℤ) ≤ w₀ + ((b * s : ℕ) : ℤ) := by
      have : (c : ℕ) * s ≤ b * s := Nat.mul_le_mul_right _ hc
      omega
    refine ⟨w₀ + (((a : ℕ) * s : ℕ) : ℤ), (c : ℕ) - (a : ℕ), by omega, by omega,
      by omega, by rw [hcast]; exact hwin, ?_, ?_, ?_⟩
    · exact hcnt (a : ℕ) ha _ (by rw [hcast]; omega)
    · rw [hcast]; exact hobj
    · rw [hcast]; exact hty
  · have hcast : w₀ + (((c : ℕ) * s : ℕ) : ℤ) + ((((a : ℕ) - (c : ℕ)) * s : ℕ) : ℤ)
        = w₀ + (((a : ℕ) * s : ℕ) : ℤ) := by
      push_cast [Nat.cast_sub (le_of_lt hlt)]; ring
    have hwin : w₀ + (((a : ℕ) * s : ℕ) : ℤ) ≤ w₀ + ((b * s : ℕ) : ℤ) := by
      have : (a : ℕ) * s ≤ b * s := Nat.mul_le_mul_right _ ha
      omega
    refine ⟨w₀ + (((c : ℕ) * s : ℕ) : ℤ), (a : ℕ) - (c : ℕ), by omega, by omega,
      by omega, by rw [hcast]; exact hwin, ?_, ?_, ?_⟩
    · exact hcnt (c : ℕ) hc _ (by rw [hcast]; omega)
    · rw [hcast]; exact hobj.symm
    · rw [hcast]; exact hty.symm

end Spacing

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
distance. The duplication-and-register-rebuild step is factored as the given-block lemma
`exists_ladderPath_through_iterSpliced_nxt_of_pend_past`, which takes the block and the number of
copies as inputs, and the assembly is its corollary. This is the upward shift with the register
held. The downward direction's register
obstruction was an anchor-position mismatch, not a cascade: the landed lift is anchored at
position `0` while the deletion window sits at `z` and reads `l` positions to the right, so
composing them charges the `l`-shift against a distance from `0`. The z-anchored lift
`exists_ladderPath_of_walk_nxt_at` removes the mismatch, and the single-block downward assembly
`exists_ladderPath_through_deleted_of_pend_past` (below) lowers the countdown by one
type-respecting block with the register held — under the named hypothesis `HasForwardSlack`, one
inequality at the first region start above `z`'s region that the path's own facts do not
discharge. The exact-shift iteration of that deletion is `section DelNxtIter` below:
`exists_ladderPath_through_deleted_exact_of_pend_past`, and its consumer
`mem_cellAt_of_shift_of_hasForwardSlack`, the downward cell inclusion on the witnessing path. -/

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

/-! ## The iterated splice index map

The retraction of `d` splices of a block `[u, u + l)` on positions: the identity below `u + l`,
the original's position `u + ((v - u) mod l)` inside the run of `d + 1` copies, and `v - d · l`
above the run. It is defined by iterating `spliceIdx`, one splice per step, so that the
`d + 1`-fold duplication's walk and realized types are read through it by one application of the
single-splice type lemma per step; its characterization lemmas below are what every consumer of
the iterated duplication reads instead of a list of boundary clauses. -/

section IterIdx

/-- **The retraction of `d` splices of `[u, u + l)` on positions**: the identity below `u + l`,
the original's position `u + ((v - u) mod l)` inside the run of `d + 1` copies, and `v - d · l`
above the run. Defined by iterating `spliceIdx` so that the `d + 1`-fold duplication's types
are read through it by one application of the duplication type lemma per step. -/
def iterSpliceIdx (u : ℤ) (l : ℕ) : ℕ → ℤ → ℤ
  | 0, v => v
  | d + 1, v => iterSpliceIdx u l d (spliceIdx u l v)

@[simp] theorem iterSpliceIdx_zero (u : ℤ) (l : ℕ) (v : ℤ) : iterSpliceIdx u l 0 v = v := rfl

theorem iterSpliceIdx_succ (u : ℤ) (l : ℕ) (d : ℕ) (v : ℤ) :
    iterSpliceIdx u l (d + 1) v = iterSpliceIdx u l d (spliceIdx u l v) := rfl

/-- Below `u + l` the retraction is the identity. -/
theorem iterSpliceIdx_of_lt (u : ℤ) (l : ℕ) (d : ℕ) (v : ℤ) (h : v < u + (l : ℤ)) :
    iterSpliceIdx u l d v = v := by
  induction d with
  | zero => rfl
  | succ d ih => rw [iterSpliceIdx_succ, spliceIdx_of_lt u l v h, ih]

/-- Above the run the retraction is the displacement by `d · l`. -/
theorem iterSpliceIdx_of_ge (u : ℤ) (l : ℕ) (d : ℕ) (v : ℤ)
    (h : u + ((d + 1) * l : ℕ) ≤ v) : iterSpliceIdx u l d v = v - (d * l : ℕ) := by
  induction d generalizing v with
  | zero => simp
  | succ d ih =>
    have e : (((d + 1 + 1) * l : ℕ) : ℤ) = ((d + 1) * l : ℕ) + (l : ℤ) := by push_cast; ring
    rw [e] at h
    have hge : u + (l : ℤ) ≤ v := by
      have : (0 : ℤ) ≤ (((d + 1) * l : ℕ) : ℤ) := Int.natCast_nonneg _
      omega
    rw [iterSpliceIdx_succ, spliceIdx_of_ge u l v hge, ih (v - l) (by omega)]
    push_cast; ring

/-- Inside the run, position `j` of the `i`-th copy is position `j` of the original block. -/
theorem iterSpliceIdx_add_mul (u : ℤ) (l : ℕ) (d : ℕ) (i j : ℕ) (hi : i ≤ d) (hj : j < l) :
    iterSpliceIdx u l d (u + (i * l : ℕ) + (j : ℤ)) = u + (j : ℤ) := by
  induction d generalizing i with
  | zero =>
    have : i = 0 := by omega
    subst this; simp
  | succ d ih =>
    rcases Nat.eq_zero_or_pos i with h0 | hpos
    · subst h0
      rw [iterSpliceIdx_of_lt u l _ _ (by push_cast; omega)]
      simp
    · obtain ⟨i', rfl⟩ : ∃ i', i = i' + 1 := ⟨i - 1, by omega⟩
      have e : u + ((i' + 1) * l : ℕ) + (j : ℤ) = (u + (i' * l : ℕ) + (j : ℤ)) + (l : ℤ) := by
        push_cast; ring
      have hge : u + (l : ℤ) ≤ (u + (i' * l : ℕ) + (j : ℤ)) + (l : ℤ) := by
        have : (0 : ℤ) ≤ ((i' * l : ℕ) : ℤ) := Int.natCast_nonneg _
        omega
      rw [iterSpliceIdx_succ, e, spliceIdx_of_ge u l _ hge, add_sub_cancel_right]
      exact ih i' (by omega)

/-- **Every copy boundary inside the run retracts to `u`.** -/
theorem iterSpliceIdx_boundary (u : ℤ) (l : ℕ) (hl : 0 < l) (d i : ℕ) (hi : i ≤ d) :
    iterSpliceIdx u l d (u + (i * l : ℕ)) = u := by
  have := iterSpliceIdx_add_mul u l d i 0 hi hl
  simpa using this

/-- **The run's top boundary retracts to `u + l`.** -/
theorem iterSpliceIdx_top (u : ℤ) (l : ℕ) (d : ℕ) :
    iterSpliceIdx u l d (u + ((d + 1) * l : ℕ)) = u + (l : ℤ) := by
  rw [iterSpliceIdx_of_ge u l d _ le_rfl]; push_cast; ring

/-- Inside the run the retraction lands in the original block `[u, u + l)`. -/
theorem iterSpliceIdx_mem (u : ℤ) (l : ℕ) (d : ℕ) (v : ℤ) (hv : u ≤ v)
    (hv' : v < u + ((d + 1) * l : ℕ)) :
    u ≤ iterSpliceIdx u l d v ∧ iterSpliceIdx u l d v < u + (l : ℤ) := by
  induction d generalizing v with
  | zero =>
    refine ⟨hv, ?_⟩
    simpa using hv'
  | succ d ih =>
    rcases lt_or_ge v (u + (l : ℤ)) with h | h
    · rw [iterSpliceIdx_of_lt u l _ v h]; omega
    · rw [iterSpliceIdx_succ, spliceIdx_of_ge u l v h]
      apply ih (v - l) (by omega)
      have e : (((d + 1 + 1) * l : ℕ) : ℤ) = ((d + 1) * l : ℕ) + (l : ℤ) := by push_cast; ring
      rw [e] at hv'; omega

end IterIdx

/-! ## The iterated duplication with the realized types exposed everywhere -/

section Iterate

variable {Q : Type} [Finite Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE ITERATED DUPLICATION, READ THROUGH THE INDEX MAP.** `d` duplications of a
type-respecting block `[u, u + l)` of a pending-forever region: the walk is the original read
through `iterSpliceIdx u l d` at EVERY position, every countdown before the block whose region
reaches it is raised by `d · l`, above the run the countdown is the original's `d · l` earlier,
and the realized stab-free type at every position is the original's at the retracted position —
in particular the original's type at `u` at every copy boundary `u + i · l` (`i ≤ d`) and its
type at `u + l` at the run's top `u + (d + 1) · l`. The landed
`exists_iterSpliced_ladderPath_of_pend_past` exposes types only below `u + l` and at `u + l`;
every one of its clauses is a reading of this one through the characterization lemmas of
`iterSpliceIdx`. -/
theorem exists_iterSpliced_ladderPath_idx_of_pend_past {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u)
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      (∀ v : ℤ, v ≤ u → u ≤ v + (cntAt g v : ℤ) → cntAt g' v = cntAt g v + d * l) ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := by
  classical
  haveI : Fintype Q := Fintype.ofFinite Q
  induction d with
  | zero =>
      refine ⟨g, hg, fun _ => rfl, fun v _ _ => by simp, fun v _ => by simp, fun σ' hσ' w => ?_⟩
      exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ
        (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
        (fun _ => rfl) hno w
  | succ d ih =>
      obtain ⟨g₁, hg₁, hobj₁, hcnt₁, habove₁, hty₁⟩ := ih
      -- the original's object and type at the retraction of `u + l` are those at `u`
      have hidx_ul : objAt g (iterSpliceIdx u l d (u + (l : ℤ))) = objAt g u := by
        rcases d with _ | d
        · rw [iterSpliceIdx_zero]; exact hrep.symm
        · rw [show u + (l : ℤ) = u + ((1 * l : ℕ) : ℤ) by push_cast; ring,
            iterSpliceIdx_boundary u l hl (d + 1) 1 (by omega)]
      have hty_ul : tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d (u + (l : ℤ)))
          = tpOf (ladderModel step pend fwd bwd lab) φ σ u := by
        rcases d with _ | d
        · rw [iterSpliceIdx_zero]; exact hty.symm
        · rw [show u + (l : ℤ) = u + ((1 * l : ℕ) : ℤ) by push_cast; ring,
            iterSpliceIdx_boundary u l hl (d + 1) 1 (by omega)]
      have hpast₁ : ∀ p : ℤ, p ≤ u → pend (objAt g₁ p) = true := fun p hp => by
        rw [hobj₁ p, iterSpliceIdx_of_lt u l d p (by omega)]; exact hpast p hp
      have hrep₁ : objAt g₁ u = objAt g₁ (u + (l : ℤ)) := by
        rw [hobj₁ u, hobj₁ (u + (l : ℤ)), iterSpliceIdx_of_lt u l d u (by omega), hidx_ul]
      have hcu₁ : cntAt g₁ u = cntAt g u + d * l := hcnt₁ u le_rfl (by omega)
      have hcl₁ : l ≤ cntAt g₁ u := by rw [hcu₁]; omega
      obtain ⟨g₂, hg₂, hobj₂, hcnt₂⟩ :=
        exists_spliced_ladderPath_of_pend_past hg₁ hl hcl₁ hpast₁ hrep₁
      have hobj₂' : ∀ w : ℤ, objAt g₂ w = objAt g₁ (spliceIdx u l w) := fun w => by
        rw [hobj₂ w, spliceObj_eq_objAt_spliceIdx]
      refine ⟨g₂, hg₂, fun v => ?_, fun v hv hreg => ?_, fun v hv => ?_, fun σ₂ hσ₂ w => ?_⟩
      · rw [hobj₂' v, hobj₁, iterSpliceIdx_succ]
      · have hreg₁ : u ≤ v + (cntAt g₁ v : ℤ) := by rw [hcnt₁ v hv hreg]; push_cast; omega
        rw [hcnt₂ v, spliceCnt_add_of_mem_region hl v hv hreg₁, hcnt₁ v hv hreg]
        ring
      · have e : (((d + 1 + 1) * l : ℕ) : ℤ) = ((d + 1) * l : ℕ) + (l : ℤ) := by push_cast; ring
        rw [e] at hv
        have hge : u + (l : ℤ) ≤ v := by
          have : (0 : ℤ) ≤ (((d + 1) * l : ℕ) : ℤ) := Int.natCast_nonneg _
          omega
        rw [hcnt₂ v, spliceCnt_of_ge v hge, habove₁ (v - (l : ℤ)) (by omega)]
        congr 1; push_cast; ring
      · obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
        have hty₁' : tpOf (ladderModel step pend fwd bwd lab) φ σ₁ u
            = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ (u + (l : ℤ)) := by
          rw [hty₁ σ₁ hσ₁ u, hty₁ σ₁ hσ₁ (u + (l : ℤ)), iterSpliceIdx_of_lt u l d u (by omega),
            hty_ul]
        have htr := tpOf_eq_spliceIdx_of_tpOf_eq step pend fwd bwd lab φ u l hl (k := 0) (k' := 0)
          σ₁ σ₂ (fun t => by rw [add_zero]; exact hσ₁ t) (fun t => by rw [add_zero]; exact hσ₂ t)
          hobj₂' hno hty₁' w
        rw [htr, hty₁ σ₁ hσ₁, iterSpliceIdx_succ]

end Iterate

section AssemblyFin

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE REGISTER-HELD ITERATED DUPLICATION OF A GIVEN BLOCK, READ THROUGH THE INDEX MAP.**
The landed `exists_ladderPath_through_iterSpliced_nxt_of_pend_past` with the walk and the types
exposed at every position through `iterSpliceIdx u l d`, and the countdown above the run. The
proof is the landed one: the duplication supplies the walk and the countdown; the register is
rebuilt by the landed lift with `z` at the origin and `n₀ := nxtAt g z`, every pin of the
duplicated path sitting above the run where it is the original's pin displaced by `d · l`. -/
theorem exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past
    {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u) (hzu : z ≤ u)
    (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, objAt g' v = objAt g (iterSpliceIdx u l d v)) ∧
      cntAt g' z = cntAt g z + d * l ∧
      nxtAt g' z = nxtAt g z ∧
      (∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → cntAt g' v = cntAt g (v - (d * l : ℕ))) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ w : ℤ, tpOf (ladderModel step pend fwd bwd lab) φ σ' w
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (iterSpliceIdx u l d w) := by
  classical
  haveI : Fintype Q := Fintype.ofFinite Q
  have hpu : pend (objAt g u) = true := hpast u le_rfl
  obtain ⟨g₁, hg₁, hobj₁, hcnt₁, habove₁, hty₁⟩ :=
    exists_iterSpliced_ladderPath_idx_of_pend_past step pend fwd bwd lab φ hno hg hl hcl hpast hrep
      σ hσ hty d
  have hcz : cntAt g₁ z = cntAt g z + d * l := hcnt₁ z hzu (by omega)
  -- every position of `g₁` below `u + (d + 1) l` is pending
  have hpend_all : ∀ v : ℤ, v < u + ((d + 1) * l : ℕ) → pend (objAt g₁ v) = true := fun v hv => by
    rw [hobj₁ v]
    rcases lt_or_ge v u with hvu | hvu
    · rw [iterSpliceIdx_of_lt u l d v (by omega)]; exact hpast v (le_of_lt hvu)
    · obtain ⟨h1, h2⟩ := iterSpliceIdx_mem u l d v hvu hv
      have := (cntAt_sub_of_pend g hg u hpu (iterSpliceIdx u l d v - u).toNat (by omega)).1
      rwa [show u + (((iterSpliceIdx u l d v - u).toNat : ℕ) : ℤ) = iterSpliceIdx u l d v by omega]
        at this
  -- the walk above the run is the original displaced by `d · l`
  have hobj_above : ∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v → objAt g₁ v = objAt g (v - (d * l : ℕ)) :=
    fun v hv => by rw [hobj₁ v, iterSpliceIdx_of_ge u l d v hv]
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
    have hge : u + ((d + 1) * l : ℕ) ≤ v + z := by
      by_contra hlt
      rw [not_le] at hlt
      exact Bool.false_ne_true (h0.symm.trans (hpend_all (v + z) hlt))
    have ho0 := hobj_above (v + z) hge
    have ho1 := hobj_above (v + z + 1) (by omega)
    have hc1 := habove₁ (v + z + 1) (by omega)
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
  have hobj' : ∀ v : ℤ, objAt (fun v => g₃ (v - z)) v = objAt g₁ v := fun v => by
    change objAt g₃ (v - z) = _
    rw [hobj₃]
    change objAt g₁ (v - z + z) = _
    rw [sub_add_cancel]
  have hcnt' : ∀ v : ℤ, cntAt (fun v => g₃ (v - z)) v = cntAt g₁ v := fun v => by
    change cntAt g₃ (v - z) = _
    rw [hcnt₃]
    change cntAt g₁ (v - z + z) = _
    rw [sub_add_cancel]
  refine ⟨fun v => g₃ (v - z), ?_, fun v => ?_, ?_, ?_, fun v hv => ?_, fun σ' hσ' w => ?_⟩
  · intro v
    have := hg₃ (v - z)
    rwa [show v - z + 1 = v + 1 - z by ring] at this
  · rw [hobj' v, hobj₁ v]
  · rw [hcnt' z, hcz]
  · change nxtAt g₃ (z - z) = _
    rw [sub_self, hnxt₃]
  · rw [hcnt' v, habove₁ v hv]
  · obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
    have e1 : tpOf (ladderModel step pend fwd bwd lab) φ σ' w
        = tpOf (ladderModel step pend fwd bwd lab) φ σ₁ w :=
      tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ₁
        (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ₁ t)
        hobj' hno w
    rw [e1, hty₁ σ₁ hσ₁ w]

/-- **THE REGISTER-HELD ITERATED DUPLICATION OF A GIVEN BLOCK.** The regime-A assembly's
construction with the block as an input: given a type-respecting block `[u, u + l)` of `z`'s
region of a path pending up to `u`, and a number `d` of copies, a ladder path that agrees with
the original below `u + l`, has `z`'s countdown raised by exactly `d · l`, the register at `z`
held, and the realized stab-free type at `z` held. A corollary of
`exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past`, which carries the same
construction with the walk and the types exposed at EVERY position through `iterSpliceIdx u l d`:
this reading keeps the walk below `u + l` and the type at `z`, both of which the index map fixes
(`iterSpliceIdx_of_lt`). Taking the block as an input (rather than finding it by the pigeonhole
inside) is what lets the exact-shift construction raise the ORIGINAL pigeonhole block of a path
first, before the overshoot loop runs above the run of copies. -/
theorem exists_ladderPath_through_iterSpliced_nxt_of_pend_past {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ) {u : ℤ} {l : ℕ}
    (hl : 0 < l) (hcl : l ≤ cntAt g u) (hzu : z ≤ u)
    (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true)
    (hrep : objAt g u = objAt g (u + (l : ℤ)))
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (hty : tpOf (ladderModel step pend fwd bwd lab) φ σ u
         = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ))) (d : ℕ) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v : ℤ, v < u + (l : ℤ) → objAt g' v = objAt g v) ∧
      cntAt g' z = cntAt g z + d * l ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  obtain ⟨g', hg', hobj, hcz, hnxt, -, hty⟩ :=
    exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past step pend fwd bwd lab φ hno hg z
      hl hcl hzu hul hpast hrep σ hσ hty d
  refine ⟨g', hg', fun v hv => ?_, hcz, hnxt, fun σ' hσ' => ?_⟩
  · rw [hobj v, iterSpliceIdx_of_lt u l d v hv]
  · rw [hty σ' hσ' z, iterSpliceIdx_of_lt u l d z (by omega)]

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
  obtain ⟨q, hq⟩ := typeBlock_length_dvd_of_paramsOk step pend fwd bwd lab φ hp σ₀ hσ₀' hg hno
    u l hl hlb hpu hcl hrep hty
  have hdl : (m * q) * l = m * (P + 1) := by rw [hq]; ring
  -- the given-block raise, `m · q` copies
  obtain ⟨g', hg', hobj', hcnt', hnxt', hty'⟩ :=
    exists_ladderPath_through_iterSpliced_nxt_of_pend_past step pend fwd bwd lab φ hno hg z hl hcl
      hzu hul' hpast_u hrep σ₀ hσ₀ hty (m * q)
  refine ⟨g', hg', hobj' z (by omega), by rw [hcnt', hdl], hnxt', fun σ σ' hσ hσ' => ?_⟩
  have e3 : tpOf (ladderModel step pend fwd bwd lab) φ σ₀ z
      = tpOf (ladderModel step pend fwd bwd lab) φ σ z :=
    tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ
      hσ₀' (fun t => by rw [add_zero]; exact hσ t) (fun _ => rfl) hno z
  rw [hty' σ' hσ', e3]

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

/-! ## The forward-slack regime: entry, monotonicity, transport, vacuity

`HasForwardSlack g z l n` is a property of the PATH `g` at the single idle position before the
first region start above `z`'s region. This section equips it with what a consumer needs: an
entry lemma with a finite witness (the countdown of that first region start, read at the idle
position before it through `cntAt_eq_nxtAt_of_idle_pend`), monotonicity in the deleted amount,
transport across a deletion inside `z`'s region (decreased by exactly the deleted length), and
the vacuous case (no region follows, so the regime asks nothing). -/

section Slack

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **Monotone in the deleted amount**: slack for a larger amount is slack for a smaller one. -/
theorem hasForwardSlack_mono {Q : Type} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (z : ℤ) {l l' n : ℕ}
    (h : HasForwardSlack g z l n) (hle : l' ≤ l) : HasForwardSlack g z l' n := by
  intro I hI hidle hnext
  have := h I hI hidle hnext
  omega

/-- **The baseline is free.** At amount `0`, with the register read at `z` itself, the regime
asks only that the register at the idle position `z + cntAt g z + I` before the first region
start above `z`'s region exceed `nxtAt g z` by at most the distance `cntAt g z + I` travelled to
reach it — which is exactly the two-sided Lipschitz bound on the register
(`nxtAt_lipschitz_two_sided`). So nothing beyond `IsLadderPath` is needed, and the regime becomes
a constraint only once the amount is positive: `ClimbWitness.hasForwardSlack_refuted_unconditional`
refutes it already at amount `1`. -/
theorem hasForwardSlack_zero {Q : Type} {pend : Q → Bool} {step : Q → Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ) :
    HasForwardSlack g z 0 (nxtAt g z) := by
  intro I _ _ _
  have hlip := nxtAt_lipschitz_two_sided g hg (z + (cntAt g z : ℤ) + (I : ℤ)) z
  omega

/-- **The regime from its finite witness.** The first region start above `z`'s region sits at
`z + cntAt g z + 1 + I` for the unique `I > 0` whose predecessors are idle; its countdown is the
register's value at the idle position before it (`cntAt_eq_nxtAt_of_idle_pend`), so a bound
`cntAt ≤ n + cntAt g z + I - l` on that one countdown is exactly the regime at amount `l`. -/
theorem hasForwardSlack_of_next_region_cnt_le {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n : ℕ)
    (hnext : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      (cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) : ℤ) ≤ (n : ℤ) + cntAt g z + I - l) :
    HasForwardSlack g z l n := by
  intro I hI hidle hnx
  have h0 := hidle (I - 1) (by omega)
  have hcast : z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ) = z + (cntAt g z : ℤ) + (I : ℤ) := by
    push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
  rw [hcast] at h0
  have h1 : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnx
  have hpin := cntAt_eq_nxtAt_of_idle_pend g hg _ h0 h1
  have := hnext I hI hidle hnx
  rw [show z + (cntAt g z : ℤ) + 1 + (I : ℤ) = z + (cntAt g z : ℤ) + (I : ℤ) + 1 by ring, hpin]
    at this
  exact this

/-- **Forward slack transports across a deletion inside `z`'s region**, decreased by exactly the
deleted length `l`: the deleted path's region at `z` is shorter by `l`, the first region start
above it is the original's displaced by `-l` with the same countdown, so the regime at amount
`L` on the original is the regime at amount `L - l` on the deleted path. -/
theorem hasForwardSlack_del {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {a : ℤ} {l : ℕ} (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hza : z ≤ a) (hal : a + (l : ℤ) ≤ z + (cntAt g z : ℤ)) {L n : ℕ}
    (hslack : HasForwardSlack g z L n) (hlL : l ≤ L)
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hobj : ∀ v, objAt g' v = delObj g a l v) (hcnt : ∀ v, cntAt g' v = delCnt g a l v) :
    HasForwardSlack g' z (L - l) n := by
  intro I hI hidle hnext
  have hcz : cntAt g' z = cntAt g z - l := by
    rw [hcnt z]; exact delCnt_sub_of_mem_region hg hl hcl z hza (by omega)
  have hczZ : (cntAt g' z : ℤ) = (cntAt g z : ℤ) - l := by rw [hcz]; omega
  have hpull : ∀ v : ℤ, a ≤ v → objAt g' v = objAt g (v + (l : ℤ)) := fun v hv => by
    rw [hobj v, delObj_of_ge v hv]
  have hidle' : ∀ i : ℕ, i < I →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false := by
    intro i hi
    have := hidle i hi
    rw [hczZ, hpull _ (by omega)] at this
    rwa [show z + ((cntAt g z : ℤ) - l) + 1 + (i : ℤ) + (l : ℤ)
        = z + (cntAt g z : ℤ) + 1 + (i : ℤ) by ring] at this
  have hnext' : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true := by
    have := hnext
    rw [hczZ, hpull _ (by omega)] at this
    rwa [show z + ((cntAt g z : ℤ) - l) + 1 + (I : ℤ) + (l : ℤ)
        = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring] at this
  have hb := hslack I hI hidle' hnext'
  have h0' := hidle' (I - 1) (by omega)
  have h0 := hidle (I - 1) (by omega)
  have hcast : ∀ C : ℤ, C + 1 + ((I - 1 : ℕ) : ℤ) = C + (I : ℤ) := by
    intro C; push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
  rw [hcast] at h0' h0
  have h1' : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnext'
  have h1 : pend (objAt g' (z + (cntAt g' z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g' z : ℤ) + (I : ℤ) + 1 = z + (cntAt g' z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnext
  have hpin' := cntAt_eq_nxtAt_of_idle_pend g hg _ h0' h1'
  have hpin := cntAt_eq_nxtAt_of_idle_pend g' hg' _ h0 h1
  have hreg : nxtAt g' (z + (cntAt g' z : ℤ) + (I : ℤ))
      = nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) := by
    rw [← hpin, ← hpin', hcnt, delCnt_of_ge _ (by omega), hczZ]
    congr 1; ring
  rw [hreg, hczZ]
  have hlLZ : ((L - l : ℕ) : ℤ) = (L : ℤ) - l := by omega
  rw [hlLZ]
  omega

/-- **Forward slack transports across a raise of `z`'s region by `d · l`**, increased by exactly
`d · l`: the raised path's region at `z` is longer by `d · l`, every position above it sits above
the run of copies, where the raised path is the original displaced by `d · l`, so the first
region start above `z`'s region is the original's displaced by `d · l` with the same countdown
(hence the same register at the idle position before it). The mirror of `hasForwardSlack_del`.
Only two exposure clauses of the raise are consumed: the countdown at `z` and the walk above the
run. -/
theorem hasForwardSlack_raise {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {u : ℤ} {l d : ℕ} (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    {L n : ℕ} (hslack : HasForwardSlack g z L n)
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hcz : cntAt g' z = cntAt g z + d * l)
    (habove : ∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v →
      objAt g' v = objAt g (v - (d * l : ℕ)) ∧ cntAt g' v = cntAt g (v - (d * l : ℕ))) :
    HasForwardSlack g' z (L + d * l) n := by
  intro I hI hidle hnext
  have hczZ : (cntAt g' z : ℤ) = (cntAt g z : ℤ) + ((d * l : ℕ) : ℤ) := by rw [hcz]; push_cast; ring
  have e : (((d + 1) * l : ℕ) : ℤ) = ((d * l : ℕ) : ℤ) + (l : ℤ) := by push_cast; ring
  -- every position above `z`'s raised region sits above the run of copies
  have hab : ∀ i : ℕ, u + ((d + 1) * l : ℕ) ≤ z + (cntAt g' z : ℤ) + 1 + (i : ℤ) := fun i => by
    rw [hczZ, e]; omega
  have hpull : ∀ i : ℕ, objAt g' (z + (cntAt g' z : ℤ) + 1 + (i : ℤ))
      = objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ)) := fun i => by
    rw [(habove _ (hab i)).1, hczZ]; congr 1; ring
  have hidle' : ∀ i : ℕ, i < I →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false := fun i hi => by
    rw [← hpull i]; exact hidle i hi
  have hnext' : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true := by
    rw [← hpull I]; exact hnext
  have hb := hslack I hI hidle' hnext'
  -- the register at the idle position before the first region start, on both paths
  have h0' := hidle' (I - 1) (by omega)
  have h0 := hidle (I - 1) (by omega)
  have hcast : ∀ C : ℤ, C + 1 + ((I - 1 : ℕ) : ℤ) = C + (I : ℤ) := by
    intro C; push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
  rw [hcast] at h0' h0
  have h1' : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnext'
  have h1 : pend (objAt g' (z + (cntAt g' z : ℤ) + (I : ℤ) + 1)) = true := by
    rw [show z + (cntAt g' z : ℤ) + (I : ℤ) + 1 = z + (cntAt g' z : ℤ) + 1 + (I : ℤ) by ring]
    exact hnext
  have hpin' := cntAt_eq_nxtAt_of_idle_pend g hg _ h0' h1'
  have hpin := cntAt_eq_nxtAt_of_idle_pend g' hg' _ h0 h1
  have hreg : nxtAt g' (z + (cntAt g' z : ℤ) + (I : ℤ))
      = nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) := by
    rw [← hpin, ← hpin']
    have hab' : u + ((d + 1) * l : ℕ) ≤ z + (cntAt g' z : ℤ) + (I : ℤ) + 1 := by
      rw [hczZ, e]; omega
    rw [(habove _ hab').2, hczZ]; congr 1; ring
  rw [hreg, hczZ]
  have hLZ : ((L + d * l : ℕ) : ℤ) = (L : ℤ) + ((d * l : ℕ) : ℤ) := by push_cast; ring
  rw [hLZ]
  omega

/-- **A raise buys slack equal to exactly the raise, from no slack hypothesis at all**: the
composite of `hasForwardSlack_zero` with `hasForwardSlack_raise`, at the raised path's exposure
clauses (the countdown at `z` and the walk above the run) that
`exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` supplies, the latter through
`iterSpliceIdx_of_ge`.

**The slack accounting, in full.** The baseline is free at amount `0` (`hasForwardSlack_zero`);
a raise of `z`'s region by `d` copies of a length-`l` block increases the amount by exactly
`d · l` (`hasForwardSlack_raise`); a deletion of `l` from inside `z`'s region decreases it by
exactly `l` (`hasForwardSlack_del`). Both transports are exact, in both directions, so no
composition of them yields slack exceeding the total amount raised, and a raise-then-delete round
trip at `z` is net zero: it returns the amount the path entered the composition with. The regime
is therefore not a source of slack — every positive amount in a composition is paid for by a
raise, and what remains open is only whether some OTHER device supplies a positive amount at a
position where no raise is available. -/
theorem hasForwardSlack_raise_of_zero {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {u : ℤ} {l d : ℕ} (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ))
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hcz : cntAt g' z = cntAt g z + d * l)
    (habove : ∀ v : ℤ, u + ((d + 1) * l : ℕ) ≤ v →
      objAt g' v = objAt g (v - (d * l : ℕ)) ∧ cntAt g' v = cntAt g (v - (d * l : ℕ))) :
    HasForwardSlack g' z (d * l) (nxtAt g z) := by
  have h0 : HasForwardSlack g z 0 (nxtAt g z) := hasForwardSlack_zero g hg z
  simpa using hasForwardSlack_raise g hg z hul h0 g' hg' hcz habove

/-- **The vacuous case**: when every position above `z`'s region is idle, no region start exists
for the regime to constrain, and `HasForwardSlack` holds at every amount and every register. -/
theorem hasForwardSlack_of_idle_above (g : ℤ → LadderState Q pend) (z : ℤ) (l n : ℕ)
    (hidle_all : ∀ i : ℕ, pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) :
    HasForwardSlack g z l n := by
  intro I _ _ hnext
  exact absurd ((hidle_all I).symm.trans hnext) Bool.false_ne_true

/-- **THE REGIME-A ASSEMBLY WITH THE RAISE-BOUGHT FORWARD SLACK EXPOSED.** The landed
`exists_ladderPath_through_shifted_of_pend_past` with ONE clause added: the raised path carries
the regime at `L + m · (P + 1)` whenever the original carries it at `L`. Its four landed clauses
are returned unchanged, so this is a strict strengthening and a pure sibling — the landed
assembly's signature and body are untouched.

**The one clause the landed assembly discards, and where.** The raise's inner call is
`exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past`, which returns the countdown ABOVE
the run of copies (`habove`); the non-`_idx_` wrapper
`exists_ladderPath_through_iterSpliced_nxt_of_pend_past` drops it with a `-` pattern, and the
landed assembly calls that wrapper. The discarded clause is exactly the second half of
`hasForwardSlack_raise`'s `habove` input, so the raise-bought slack is not reachable from the
landed signature at all, by any reading of its conclusion. This theorem calls the `_idx_` variant
directly and assembles the slack from it; nothing else in the spine changes.

**The accounting.** A raise by `d` copies of an `l`-block increases the regime's amount by exactly
`d · l` — see `hasForwardSlack_raise_of_zero`'s own docstring for why, and `hasForwardSlack_raise`
for the statement. Here `d := m · q` with `q · l = P + 1`, so the amount gained is `m · (P + 1)`.
At `L = 0` the hypothesis costs nothing: `hasForwardSlack_zero` supplies
`HasForwardSlack g z 0 (nxtAt g z)` for every ladder path, which is why
`hasForwardSlack_raise_of_zero` needs no regime hypothesis either.

**Placement.** This belongs with `exists_ladderPath_through_shifted_of_pend_past` in
`section AssemblyFin` and cannot sit there: `HasForwardSlack` and `hasForwardSlack_raise` are
both introduced below that section, so a declaration mentioning either must follow them. It is
therefore stated here, at the end of the forward-slack section whose vocabulary its added clause
uses. -/
theorem exists_ladderPath_through_shifted_slack_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hTc : Tc ≤ cntAt g z) (m : ℕ) (L : ℕ)
    (hslack : HasForwardSlack g z L (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z + m * (P + 1) ∧
      nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z (L + m * (P + 1)) (nxtAt g z) ∧
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
  have hul' : u + (l : ℤ) ≤ z + (cntAt g z : ℤ) := by omega
  have hpast_u : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true := fun p hp' => by
    rcases le_or_gt p z with hpz | hpz
    · exact hpast p hpz
    · have := (cntAt_sub_of_pend g hg z hz (p - z).toNat (by omega)).1
      rwa [show z + (((p - z).toNat : ℕ) : ℤ) = p by omega] at this
  have hpu : pend (objAt g u) = true := hpast_u u le_rfl
  obtain ⟨q, hq⟩ := typeBlock_length_dvd_of_paramsOk step pend fwd bwd lab φ hp σ₀ hσ₀' hg hno
    u l hl hlb hpu hcl hrep hty
  have hdl : (m * q) * l = m * (P + 1) := by rw [hq]; ring
  -- the given-block raise through the INDEX variant, which returns the countdown above the run
  obtain ⟨g', hg', hobj', hcz', hnxt', habove', hty'⟩ :=
    exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past step pend fwd bwd lab φ hno hg z
      hl hcl hzu hul' hpast_u hrep σ₀ hσ₀ hty (m * q)
  -- the walk AND the countdown above the run: the pair `hasForwardSlack_raise` consumes
  have hobj_above : ∀ v : ℤ, u + ((m * q + 1) * l : ℕ) ≤ v →
      objAt g' v = objAt g (v - (m * q * l : ℕ)) ∧
      cntAt g' v = cntAt g (v - (m * q * l : ℕ)) :=
    fun v hv => ⟨by rw [hobj' v, iterSpliceIdx_of_ge u l _ v hv], habove' v hv⟩
  refine ⟨g', hg', ?_, by rw [hcz', hdl], hnxt', ?_, fun σ σ' hσ hσ' => ?_⟩
  · rw [hobj' z, iterSpliceIdx_of_lt u l _ z (by omega)]
  · rw [← hdl]
    exact hasForwardSlack_raise g hg z hul' hslack g' hg' hcz' hobj_above
  · have e3 : tpOf (ladderModel step pend fwd bwd lab) φ σ₀ z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z :=
      tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ
        hσ₀' (fun t => by rw [add_zero]; exact hσ t) (fun _ => rfl) hno z
    rw [hty' σ' hσ' z, iterSpliceIdx_of_lt u l _ z (by omega), e3]

end Slack

/-! ## The two-state witness: the forward-slack regime is necessary and inhabited

The object is `Bool` with `true` pending, `false` idle, and every step allowed (`stepT`,
`pendT`). Two concrete ladder paths on it bracket the regime. The CLIMBING path realizes the
gate's arithmetic witness `n = 0, cntAt g z = 3, I = 1, l = 1, nxtAt g s₀ = 4` exactly: pending
forever into the past at `z = 0` with countdown `3`, its register climbs by one per step from `0`
at `z` to `4` at the single idle position `s₀ = 4`, so the next region (countdown `4`) is longer
than the deleted amount leaves room for and `HasForwardSlack` fails at amount `1`. Nothing in the
ladder relation prevents this: `Drift` admits the rung `n' = n + 1` at every step, and a pending
self-loop on `true` realizes any next-region length, so no `Drift`-level invariant bounds the
climb — which is why the regime is a hypothesis and not a theorem. The PLATEAU path (register
constant `0`, countdown `C` at `z = 0`, then alternating idle and length-`1` pending regions)
satisfies the regime at every amount `l ≤ C + 1` with a genuine next region (`I = 1`), so the
hypothesis is inhabited at every amount and is not a disguised `sorry`. The two headline
statements are exact mirrors of each other with the negation removed. -/

namespace ClimbWitness

/-- Two-state object: `true` pending, `false` idle, every step allowed. -/
def stepT : Bool → Bool → Bool := fun _ _ => true

/-- The pending predicate of the two-state object is the identity. -/
def pendT : Bool → Bool := fun b => b

/-- The climbing-register path: pending forever up to `3` with countdown `3 - v`, register `0`
for `v ≤ 0` climbing by one per step to `4` at the idle position `4`, then periodic with period
`6` (five pending positions with countdown `4, 3, 2, 1, 0`, one idle), register `4`. -/
def climbRaw (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ 3 then (true, (3 - v).toNat, (max 0 v).toNat)
  else if v = 4 then (false, 0, 4)
  else if (v - 5) % 6 = 5 then (false, 0, 4)
  else (true, (4 - (v - 5) % 6).toNat, 4)

theorem climbRaw_adm (v : ℤ) : (climbRaw v).2.1 ∈ Adm pendT (climbRaw v).1 := by
  intro h
  unfold climbRaw at *
  split_ifs at * <;> simp_all [pendT]

/-- The climbing path as a ladder state function. -/
def climb (v : ℤ) : LadderState Bool pendT := ⟨climbRaw v, climbRaw_adm v⟩

theorem climb_isLadderPath : IsLadderPath stepT pendT climb := by
  intro u
  change Rlad stepT pendT u (climbRaw u) (climbRaw (u + 1))
  unfold Rlad Drift Count climbRaw stepT pendT
  split_ifs <;> simp_all <;> omega

theorem climb_pend_past : ∀ p : ℤ, p ≤ 0 → pendT (objAt climb p) = true := by
  intro p hp
  simp [objAt, climb, climbRaw, pendT, show p ≤ 3 by omega]

theorem climb_gap : nxtAt climb 0 + (0 + 1) ≤ cntAt climb 0 := by
  simp [nxtAt, cntAt, climb, climbRaw]

theorem climb_not_hasForwardSlack : ¬ HasForwardSlack climb 0 (0 + 1) (nxtAt climb 0) := by
  intro h
  have := h 1 (by omega) (fun i hi => by
      have : i = 0 := by omega
      subst this
      simp [objAt, climb, climbRaw, pendT, cntAt])
    (by simp [objAt, climb, climbRaw, pendT, cntAt])
  simp [nxtAt, cntAt, climb, climbRaw] at this

/-- **The unconditional forward-slack claim is refuted by a ladder path**: pending forever into
the past at `0`, gap `nxtAt + (P + 1) ≤ cntAt` with `P = 0`, and no forward slack. -/
theorem hasForwardSlack_refuted_unconditional :
    ∃ g : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g ∧
      (∀ p : ℤ, p ≤ 0 → pendT (objAt g p) = true) ∧
      nxtAt g 0 + (0 + 1) ≤ cntAt g 0 ∧ ¬ HasForwardSlack g 0 (0 + 1) (nxtAt g 0) :=
  ⟨climb, climb_isLadderPath, climb_pend_past, climb_gap, climb_not_hasForwardSlack⟩

/-- The plateau path at height `C`: pending with countdown `C - v` up to `C` (register `0`), then
alternating idle (`v - C` odd) and length-`1` pending regions (`v - C` even), register `0`
throughout. -/
def plateauRaw (C : ℕ) (v : ℤ) : Bool × ℕ × ℕ :=
  if v ≤ (C : ℤ) then (true, ((C : ℤ) - v).toNat, 0)
  else if (v - (C : ℤ)) % 2 = 1 then (false, 0, 0)
  else (true, 0, 0)

theorem plateauRaw_adm (C : ℕ) (v : ℤ) :
    (plateauRaw C v).2.1 ∈ Adm pendT (plateauRaw C v).1 := by
  intro h
  unfold plateauRaw at *
  split_ifs at * <;> simp_all [pendT]

/-- The plateau path as a ladder state function. -/
def plateau (C : ℕ) (v : ℤ) : LadderState Bool pendT := ⟨plateauRaw C v, plateauRaw_adm C v⟩

theorem plateau_isLadderPath (C : ℕ) : IsLadderPath stepT pendT (plateau C) := by
  intro u
  change Rlad stepT pendT u (plateauRaw C u) (plateauRaw C (u + 1))
  unfold Rlad Drift Count plateauRaw stepT pendT
  split_ifs <;> simp_all <;> omega

theorem plateau_pend_past (C : ℕ) : ∀ p : ℤ, p ≤ 0 → pendT (objAt (plateau C) p) = true := by
  intro p hp
  simp [objAt, plateau, plateauRaw, pendT, show p ≤ (C : ℤ) by omega]

/-- The plateau's register is `0` everywhere. -/
theorem plateau_nxt (C : ℕ) (v : ℤ) : nxtAt (plateau C) v = 0 := by
  change (plateauRaw C v).2.2 = 0
  unfold plateauRaw
  split_ifs <;> rfl

/-- The plateau's countdown at `0` is `C`. -/
theorem plateau_cnt_zero (C : ℕ) : cntAt (plateau C) 0 = C := by
  change (plateauRaw C 0).2.1 = C
  unfold plateauRaw
  rw [if_pos (by omega)]
  change ((C : ℤ) - 0).toNat = C
  omega

theorem plateau_gap (C l : ℕ) (hl : l ≤ C) :
    nxtAt (plateau C) 0 + l ≤ cntAt (plateau C) 0 := by
  rw [plateau_nxt, plateau_cnt_zero]; omega

/-- **The plateau satisfies the regime at every amount `l ≤ C + 1`**, with a genuine next region:
the first region start above `0`'s region is at `C + 2` (`I = 1`), its countdown is `0`, and the
inequality `0 ≤ 0 + C + 1 - l` is the regime. -/
theorem hasForwardSlack_plateau (C l : ℕ) (hl : l ≤ C + 1) :
    HasForwardSlack (plateau C) 0 l 0 := by
  intro I hI hidle hnext
  rw [plateau_cnt_zero] at hidle hnext ⊢
  have hI1 : I = 1 := by
    by_contra hne
    have h1 := hidle 1 (by omega)
    have hpos : ((0 : ℤ) + (C : ℤ) + 1 + ((1 : ℕ) : ℤ)) = (C : ℤ) + 2 := by push_cast; ring
    rw [hpos] at h1
    change (plateauRaw C ((C : ℤ) + 2)).1 = false at h1
    unfold plateauRaw at h1
    rw [if_neg (by omega), if_neg (by omega)] at h1
    exact Bool.false_ne_true h1.symm
  subst hI1
  rw [plateau_nxt]
  push_cast
  omega

/-- **The regime is inhabited at every amount**: the exact mirror of
`hasForwardSlack_refuted_unconditional` with the negation removed. The witness is the plateau at
height `L`, whose next region starts at `L + 2` — a path with a next region, not an idle-forever
one. -/
theorem exists_hasForwardSlack_inhabitant (L : ℕ) :
    ∃ g : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g ∧
      (∀ p : ℤ, p ≤ 0 → pendT (objAt g p) = true) ∧
      nxtAt g 0 + L ≤ cntAt g 0 ∧ HasForwardSlack g 0 L (nxtAt g 0) := by
  refine ⟨plateau L, plateau_isLadderPath L, plateau_pend_past L, plateau_gap L L le_rfl, ?_⟩
  rw [plateau_nxt]
  exact hasForwardSlack_plateau L L (by omega)

end ClimbWitness

/-! ## The single-block downward assembly: the countdown lowered by the block's length, the
register held

The mirror of the regime-A assembly for ONE block. Through a pending-forever path's state at `z`
with countdown at least `Tc`, a ladder path with the countdown LOWERED by the type-respecting
block's length `l` (a divisor of `P + 1`), the object state and the register at `z` held, and the
same realized stab-free type at `z`. The register is rebuilt by the z-anchored deletion with
`n := nxtAt g z`, and its anchor clause is reduced to the first region start by the collapse; the
single inequality left there is NOT discharged from the path's own facts (the gate's verdict),
so it is carried as the named hypothesis `HasForwardSlack g z (P + 1) (nxtAt g z)`;
`section Slack` above equips the regime, and `section DelNxtIter` below iterates this assembly to
the exact shift. -/

section DelNxtFin

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **THE SINGLE-BLOCK DOWNWARD ASSEMBLY, under the forward-slack hypothesis.** The gate on the
residual inequality FAILED in its upper direction (see `HasForwardSlack`), so this is the
regime-restricted branch: beyond the upward mirror's hypotheses and the gap
`nxtAt g z + (P + 1) ≤ cntAt g z`, the consumer must supply
`HasForwardSlack g z (P + 1) (nxtAt g z)`, one inequality at one region start, and the
`l`-instance the block needs follows from it by monotonicity (`l ≤ P + 1`). Nothing is weakened
under an existing name, and the reserved name
`cellLE_zero_const_of_kappa_eq` remains claimed by nothing. Two pieces separate this single-block
assembly from the cell-level downward inclusion, and `section DelNxtIter` supplies both on the
witnessing path: the exact-shift ITERATION of the deletion is
`exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` (every deletion lemma is
length-agnostic, so `d` deletions of an `l`-block are one deletion of a `d · l`-block and the
obstacle is EXACTNESS, met by raising first by `budget` copies of the original block with the
register held, overshooting with sampled blocks at spacing `l` above the run, and deleting the
exact remainder as one block of the run), and the PATH-versus-STATE quantification (the forward
slack is a property of a path, and the cell quantifies over every path through the state, the
climbing-register path included) is answered by stating the inclusion on the witnessing path,
`mem_cellAt_of_shift_of_hasForwardSlack_exact`, the only sound form under a
path-level regime. -/
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

/-! ## The exact-shift iteration: raise first, overshoot above the run, delete the exact
remainder inside it

Every landed deletion lemma is length-agnostic, so `d` deletions of an `l`-block are one deletion
of a `d · l`-block; what the cell-level downward inclusion needs is EXACTNESS — the countdown
lowered by exactly `m · (P + 1)` — and a pigeonhole never returns a prescribed length. The
device, with `l` the length of the original pigeonhole block `[u, u + l)` (a divisor of `P + 1`)
and `R := m · ((P + 1) / l)` the target in `l`-units: RAISE first by `budget` copies of that
block with the register held (`exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past`),
which adds exactly `budget · l` of forward slack (`hasForwardSlack_raise`); then run the
overshoot loop ABOVE the run of copies, sampling at spacing `l` from `u + (budget + 1) · l` and
deleting the type-respecting block the spaced pigeonhole returns (length `d · l`,
`1 ≤ d ≤ budget`) until at least `R · l` positions are gone, the overshoot `t − R` fewer than
`budget` blocks; finally delete the remainder `r := R + budget − t ∈ [1, budget]` EXACTLY, as the
single block `[u, u + r · l)` of the run, whose ends carry the original's `(objAt, tpOf)` at `u`.
What makes the raise-first order possible is the index-map exposure of the iterated duplication:
`iterSpliceIdx` reads the walk and the realized types at every copy boundary, so the remainder
block is type-respecting after the loop has run above it. The hypotheses are exactly the gap and
the regime at `m · (P + 1)`: the raise pays for the overshoot before it happens, and no `budget²`
slack term enters either anchor direction. The step and the loop take their sampling window as
their one room hypothesis, which is what lets the loop start above the run. -/

section DelNxtIter

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

/-- **ONE STEP OF THE OVERSHOOT LOOP.** With the sampling window `[w₀, w₀ + budget · l]` inside
`z`'s region as the one room hypothesis (`hwin`, so the loop can sample from a start pushed out
by a run of copies), sample at spacing `l` from `w₀`, delete the type-respecting block the spaced
pigeonhole returns, and hand back a ladder path that
agrees with the input at every position up to and including `w₀` (object walk and realized
type), has `z`'s countdown lowered by `d · l` with `1 ≤ d ≤ budget`, keeps the register at `z`,
and carries the regime at the amount decreased by exactly `d · l`. The spine mirrors
`exists_ladderPath_through_deleted_of_pend_past` with the spaced pigeonhole in place of the
consecutive one: `hasForwardSlack_mono` brings the regime down to the block's length, the
collapse `anchor_clause_of_first_region_start` supplies the deletion's anchor clause, the deletion
with the register exposed does the surgery, and the agreement, countdown, regime and type clauses
are read off `delObj_eq_of_le`, `delCnt_sub_of_mem_region`, `hasForwardSlack_del` and
`tpOf_eq_delIdx_of_tpOf_eq` respectively. -/
theorem exists_deleted_ladderPath_step_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (w₀ : ℤ) (hzw : z ≤ w₀) (l : ℕ) (hl : 0 < l)
    (hwin : w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
      ≤ z + (cntAt g z : ℤ))
    {L : ℕ} (hLb : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l ≤ L)
    (hgap : nxtAt g z + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l ≤ cntAt g z)
    (hslack : HasForwardSlack g z L (nxtAt g z)) :
    ∃ (g' : ℤ → LadderState Q pend) (d : ℕ), IsLadderPath step pend g' ∧
      0 < d ∧ d ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      (∀ v : ℤ, v ≤ w₀ → objAt g' v = objAt g v) ∧
      cntAt g' z + d * l = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z (L - d * l) (nxtAt g z) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ v : ℤ, v ≤ w₀ →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' v
            = tpOf (ladderModel step pend fwd bwd lab) φ σ v := by
  classical
  have hz : pend (objAt g z) = true := hpast z le_rfl
  -- the spaced pigeonhole
  obtain ⟨a, d, hd, hdb, hwa, haw, hcl, hrep, hty⟩ :=
    exists_typeBlock_of_spacing step pend fwd bwd lab φ σ hg z hz w₀ l hzw hwin
  have hdl : 0 < d * l := Nat.mul_pos hd hl
  have hdlb : d * l ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l :=
    Nat.mul_le_mul_right l hdb
  have hdlL : d * l ≤ L := le_trans hdlb hLb
  have hza : z ≤ a := le_trans hzw hwa
  have hal : a + ((d * l : ℕ) : ℤ) ≤ z + (cntAt g z : ℤ) := le_trans haw hwin
  -- every position up to `a` is pending: below `z` by hypothesis, from `z` to `a` by the region
  have hpast_a : ∀ p : ℤ, p ≤ a → pend (objAt g p) = true := fun p hp' => by
    rcases le_or_gt p z with hpz | hpz
    · exact hpast p hpz
    · have := (cntAt_sub_of_pend g hg z hz (p - z).toNat (by omega)).1
      rwa [show z + (((p - z).toNat : ℕ) : ℤ) = p by omega] at this
  -- the single-pin bound at the block's length, from the gap and the regime; then the collapse
  have hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) : ℤ) - nxtAt g z).natAbs
        ≤ ((cntAt g z : ℤ) + I - (d * l : ℕ)).natAbs := fun I hI hidle hnext => by
    have := hasForwardSlack_mono g z hslack hdlL I hI hidle hnext
    omega
  have hanch := anchor_clause_of_first_region_start g hg z hz (d * l) (nxtAt g z) hfirst a hza hal
  -- the deleted path, with the register held at `z`
  obtain ⟨g', hg', hobj', hcnt', hnxt'⟩ :=
    exists_deleted_ladderPath_of_pend_past_nxt hg hdl hcl hpast_a hrep z (nxtAt g z) hanch
  refine ⟨g', d, hg', hd, hdb, ?_, ?_, hnxt', ?_, ?_⟩
  · -- the object walk up to `w₀ ≤ a` is untouched
    intro v hv
    rw [hobj' v, delObj_eq_of_le hrep v (by omega)]
  · -- the countdown at `z` drops by exactly the block's length
    rw [hcnt' z, delCnt_sub_of_mem_region hg hdl hcl z hza (by omega)]
    omega
  · -- the regime transports, decreased by exactly the block's length
    exact hasForwardSlack_del g hg z hdl hcl hza hal hslack hdlL g' hg' hobj' hcnt'
  · -- the realized types up to `w₀`, read through `delIdx a (d · l)`
    intro σ' hσ' v hv
    have hσ0 : ∀ t : ℤ, σ.state t = (t + 0, g t) := fun t => by rw [add_zero]; exact hσ t
    have hσ'0 : ∀ t : ℤ, σ'.state t = (t + 0, g' t) := fun t => by rw [add_zero]; exact hσ' t
    have hdel := tpOf_eq_delIdx_of_tpOf_eq step pend fwd bwd lab φ a (d * l) hdl (k := 0)
      (k' := 0) σ σ' hσ0 hσ'0 (fun w => (hobj' w).trans rfl) hno hty v
    rw [hdel]
    rcases lt_or_eq_of_le (show v ≤ a by omega) with hlt | heq
    · rw [delIdx_of_lt a (d * l) v hlt]
    · rw [heq, delIdx_of_ge a (d * l) a le_rfl, ← hty]

/-- **THE OVERSHOOT LOOP.** Iterating the step by strong induction on the target number `R` of
`l`-units deletes at least `R · l` positions and fewer than `(R + budget) · l` — the overshoot is
fewer than `budget` blocks of length `l` — preserving the object walk and the realized types up to
`w₀` (inclusive), the register at `z`, and the regime at the decreased amount. The one room
hypothesis is the sampling window: `R + budget` blocks of length `l` from `w₀` inside `z`'s region.
The only new structure is the induction generalizing the path and its history, so that each step's
output is the next step's input; every path fact comes from the step lemma. -/
theorem exists_deleted_ladderPath_overshoot_of_pend_past
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    {g : ℤ → LadderState Q pend} (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hσ : ∀ t : ℤ, σ.state t = (t, g t))
    (w₀ : ℤ) (hzw : z ≤ w₀) (l : ℕ) (hl : 0 < l)
    (hlb : l ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) (R : ℕ)
    (hwin : w₀ + ((R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
      ≤ z + (cntAt g z : ℤ))
    (hgap : nxtAt g z + R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l
      ≤ cntAt g z)
    (hslack : HasForwardSlack g z
      (R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l) (nxtAt g z)) :
    ∃ (g' : ℤ → LadderState Q pend) (t : ℕ), IsLadderPath step pend g' ∧
      R ≤ t ∧ t < R + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      (∀ v : ℤ, v ≤ w₀ → objAt g' v = objAt g v) ∧
      cntAt g' z + t * l = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z
        (R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l - t * l) (nxtAt g z) ∧
      ∀ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        ∀ v : ℤ, v ≤ w₀ →
          tpOf (ladderModel step pend fwd bwd lab) φ σ' v
            = tpOf (ladderModel step pend fwd bwd lab) φ σ v := by
  classical
  induction R using Nat.strong_induction_on generalizing g σ with
  | _ R ih =>
  rcases Nat.eq_zero_or_pos R with hR0 | hRpos
  · -- base: nothing to delete; two histories of the same path realize the same stab-free type
    subst hR0
    refine ⟨g, 0, hg, le_rfl, by omega, fun _ _ => rfl, by simp, rfl, by simpa using hslack,
      fun σ' hσ' v _ => ?_⟩
    exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ' σ
      (fun t => by rw [add_zero]; exact hσ' t) (fun t => by rw [add_zero]; exact hσ t)
      (fun _ => rfl) hno v
  · -- step: one deletion of `d · l` positions, then recurse on `R - d` if any units remain
    have hwin₀ : w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
        ≤ z + (cntAt g z : ℤ) := by
      have hc : ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
          ≤ ((R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ) := by
        exact_mod_cast Nat.le_add_left _ _
      omega
    obtain ⟨g₁, d, hg₁, hd, hdb, hagree₁, hcnt₁, hnxt₁, hslack₁, hty₁⟩ :=
      exists_deleted_ladderPath_step_of_pend_past step pend fwd bwd lab φ hno hg z hpast σ hσ
        w₀ hzw l hl hwin₀ (Nat.le_add_left _ _) (by omega) hslack
    rcases le_or_gt R d with hRd | hdR
    · -- a single block already covers the target
      exact ⟨g₁, d, hg₁, hRd, by omega, hagree₁, hcnt₁, hnxt₁, hslack₁, hty₁⟩
    · -- `d < R`: recurse on the shortened path with `R - d` units left
      have e : (R - d) * l + d * l = R * l := by
        rw [← Nat.add_mul, Nat.sub_add_cancel (le_of_lt hdR)]
      obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
      have hpast₁ : ∀ p : ℤ, p ≤ z → pend (objAt g₁ p) = true := fun p hp => by
        rw [hagree₁ p (by omega)]; exact hpast p hp
      have hwin₁ : w₀ + (((R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l
          : ℕ) : ℤ) ≤ z + (cntAt g₁ z : ℤ) := by
        have hc : ((R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
            = (((R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
              + ((d * l : ℕ) : ℤ) := by
          rw [← e]; push_cast; ring
        have hc1 : (cntAt g₁ z : ℤ) + ((d * l : ℕ) : ℤ) = (cntAt g z : ℤ) := by
          exact_mod_cast hcnt₁
        omega
      have hgap₁ : nxtAt g₁ z + (R - d) * l +
          Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l ≤ cntAt g₁ z := by
        rw [hnxt₁]; omega
      have hslack₁' : HasForwardSlack g₁ z
          ((R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l)
          (nxtAt g₁ z) := by
        rw [hnxt₁]
        have hamt : R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l - d * l
            = (R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l := by omega
        rw [hamt] at hslack₁
        exact hslack₁
      obtain ⟨g₂, t', hg₂, hRt', ht'R, hagree₂, hcnt₂, hnxt₂, hslack₂, hty₂⟩ :=
        ih (R - d) (by omega) hg₁ hpast₁ σ₁ hσ₁ hwin₁ hgap₁ hslack₁'
      refine ⟨g₂, d + t', hg₂, by omega, by omega,
        fun v hv => (hagree₂ v hv).trans (hagree₁ v hv), ?_, hnxt₂.trans hnxt₁, ?_,
        fun σ' hσ' v hv => (hty₂ σ' hσ' v hv).trans (hty₁ σ₁ hσ₁ v hv)⟩
      · rw [Nat.add_mul]; omega
      · rw [hnxt₁] at hslack₂
        have hamt : R * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l
            - (d + t') * l
            = (R - d) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l - t' * l := by
          rw [Nat.add_mul]; omega
        rw [hamt]
        exact hslack₂

/-- **THE EXACT-SHIFT THEOREM, UP-FIRST.** Under the gap `nxtAt g z + m · (P + 1) ≤ cntAt g z`
and the regime at EXACTLY the amount `m · (P + 1)`: the countdown lowered by exactly
`m · (P + 1)`, the object state, the register and the realized stab-free type at `z` held. The
ordering: (i) the original pigeonhole block `[u, u + l)`, `l ∣ P + 1`, target `R := m · q` blocks;
(ii) RAISE by `b := budget` copies of it with the register held, which adds exactly `b · l` of
slack (`hasForwardSlack_raise`) and exposes `(objAt, tpOf)` at every copy boundary `u + i · l`,
`i ≤ b`; (iii) the overshoot loop ABOVE the run, sampling from `u + (b + 1) · l`, deletes `t · l`
with `R ≤ t < R + b` and leaves the run untouched; (iv) the remainder `r := R + b − t ∈ [1, b]`
is deleted EXACTLY as the single block `[u, u + r · l)` of the run, whose ends carry the
original's `(objAt, tpOf)` at `u`. No `budget²` term: the raise pays for the overshoot before it
happens. -/
theorem exists_ladderPath_through_deleted_exact_upfirst_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) ≤ cntAt g z)
    (hslack : HasForwardSlack g z (m * (P + 1)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  have hz : pend (objAt g z) = true := hpast z le_rfl
  have hbud := budget_le_Tc step pend lab φ Tc Tn P B hp
  have hb2 := budget_mul_succ_le_Tc step pend lab φ Tc Tn P B hp
  -- a history of the original, and the type-respecting block of `z`'s region
  obtain ⟨σ₀, hσ₀⟩ := exists_hist_of_isLadderPath fwd bwd g hg
  have hσ₀' : ∀ t : ℤ, σ₀.state t = (t + 0, g t) := fun t => by rw [add_zero]; exact hσ₀ t
  obtain ⟨u, l, hl, hlb, hzu, hcl, hul, hrep, hty⟩ :=
    exists_typeBlock_of_budget_le_cnt_within step pend fwd bwd lab φ σ₀ hg z hz (by omega)
  have hpast_u : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true := fun p hp' => by
    rcases le_or_gt p z with hpz | hpz
    · exact hpast p hpz
    · have := (cntAt_sub_of_pend g hg z hz (p - z).toNat (by omega)).1
      rwa [show z + (((p - z).toNat : ℕ) : ℤ) = p by omega] at this
  have hpu : pend (objAt g u) = true := hpast_u u le_rfl
  obtain ⟨q, hq⟩ := typeBlock_length_dvd_of_paramsOk step pend fwd bwd lab φ hp σ₀ hσ₀' hg hno
    u l hl hlb hpu hcl hrep hty
  have hRl : (m * q) * l = m * (P + 1) := by rw [hq]; ring
  have hul' : u + (l : ℤ) ≤ z + (cntAt g z : ℤ) := by omega
  -- the budget products
  have hbl : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l
      ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) :=
    Nat.mul_le_mul_left _ hlb
  have hbb : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1)
      = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) +
        Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := Nat.mul_succ _ _
  have hb1l : (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l
      = Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l + l := Nat.succ_mul _ _
  -- (ii) the raise by `b` copies, the register held
  obtain ⟨g₁, hg₁, hobj₁, hcz₁, hnxt₁, habove₁, hty₁⟩ :=
    exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past step pend fwd bwd lab φ hno hg z
      hl hcl hzu hul' hpast_u hrep σ₀ hσ₀ hty (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)
  have hobj_above₁ : ∀ v : ℤ,
      u + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l : ℕ) ≤ v →
      objAt g₁ v = objAt g (v - (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ)) ∧
      cntAt g₁ v = cntAt g (v - (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ)) :=
    fun v hv => ⟨by rw [hobj₁ v, iterSpliceIdx_of_ge u l _ v hv], habove₁ v hv⟩
  have hslack₁ : HasForwardSlack g₁ z
      ((m * q) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l) (nxtAt g z) := by
    rw [hRl]
    exact hasForwardSlack_raise g hg z hul' hslack g₁ hg₁ hcz₁ hobj_above₁
  -- (iii) the overshoot loop above the run
  obtain ⟨σ₁, hσ₁⟩ := exists_hist_of_isLadderPath fwd bwd g₁ hg₁
  have hpast₁ : ∀ p : ℤ, p ≤ z → pend (objAt g₁ p) = true := fun p hp => by
    rw [hobj₁ p, iterSpliceIdx_of_lt u l _ p (by omega)]; exact hpast p hp
  have hwin : u + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l : ℕ)
      + (((m * q) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l : ℕ) : ℤ)
      ≤ z + (cntAt g₁ z : ℤ) := by
    rw [hcz₁, hb1l]
    generalize hbq : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card = b
      at hul hbl hbb hb2 hbud ⊢
    omega
  obtain ⟨g₂, t, hg₂, hRt, htR, hagree₂, hcnt₂, hnxt₂, hslack₂, hty₂⟩ :=
    exists_deleted_ladderPath_overshoot_of_pend_past step pend fwd bwd lab φ hno hg₁ z hpast₁
      σ₁ hσ₁ (u + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l : ℕ))
      (by omega) l hl hlb (m * q) hwin (by rw [hnxt₁, hcz₁]; omega)
      (by rw [hnxt₁]; exact hslack₁)
  -- (iv) the exact remainder `r`, deleted as one block of the run
  obtain ⟨r, hr⟩ : ∃ r : ℕ, r + t = m * q + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card :=
    ⟨m * q + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card - t, by omega⟩
  have hr1 : 1 ≤ r := by omega
  have hrb : r ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by omega
  have hrl : 0 < r * l := Nat.mul_pos hr1 hl
  have ert : r * l + t * l
      = (m * q) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l := by
    rw [← Nat.add_mul, hr, Nat.add_mul]
  have hcz₂ : cntAt g₂ z + (m * q) * l = cntAt g z + r * l := by omega
  have hrw₀ : u + ((r * l : ℕ) : ℤ)
      ≤ u + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l : ℕ) := by
    have : r * l ≤ (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) * l :=
      Nat.mul_le_mul_right l (by omega)
    omega
  have hrep₂ : objAt g₂ u = objAt g₂ (u + ((r * l : ℕ) : ℤ)) := by
    rw [hagree₂ u (by omega), hagree₂ _ hrw₀, hobj₁, hobj₁, iterSpliceIdx_of_lt u l _ u (by omega),
      iterSpliceIdx_boundary u l hl _ r hrb]
  have hpast₂ : ∀ p : ℤ, p ≤ u → pend (objAt g₂ p) = true := fun p hp' => by
    rw [hagree₂ p (by omega), hobj₁ p, iterSpliceIdx_of_lt u l _ p (by omega)]
    exact hpast_u p hp'
  have hz₂ : pend (objAt g₂ z) = true := hpast₂ z hzu
  -- the run block lies inside `z`'s (still long enough) region
  have huzb : u - z ≤ ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card : ℕ) : ℤ) := by
    omega
  have hc₂big : Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + r * l ≤ cntAt g₂ z := by
    omega
  have hcl₂ : r * l ≤ cntAt g₂ u := by
    have h2 : (u - z).toNat ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card := by omega
    have h1 := (cntAt_sub_of_pend g₂ hg₂ z hz₂ (u - z).toNat (by omega)).2
    rw [show z + (((u - z).toNat : ℕ) : ℤ) = u by omega] at h1
    omega
  have hal₂ : u + ((r * l : ℕ) : ℤ) ≤ z + (cntAt g₂ z : ℤ) := by omega
  -- the regime at exactly the remainder, and the anchor clause
  have hamt : (m * q) * l + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * l - t * l
      = r * l := by omega
  rw [hamt, hnxt₁] at hslack₂
  have hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g₂ (z + (cntAt g₂ z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g₂ (z + (cntAt g₂ z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g₂ (z + (cntAt g₂ z : ℤ) + (I : ℤ)) : ℤ) - nxtAt g z).natAbs
        ≤ ((cntAt g₂ z : ℤ) + I - (r * l : ℕ)).natAbs := fun I hI hidle hnext => by
    have := hslack₂ I hI hidle hnext
    omega
  have hanch := anchor_clause_of_first_region_start g₂ hg₂ z hz₂ (r * l) (nxtAt g z) hfirst u hzu
    hal₂
  obtain ⟨g₃, hg₃, hobj₃, hcnt₃, hnxt₃⟩ :=
    exists_deleted_ladderPath_of_pend_past_nxt hg₂ hrl hcl₂ hpast₂ hrep₂ z (nxtAt g z) hanch
  refine ⟨g₃, hg₃, ?_, ?_, hnxt₃, fun σ σ' hσ hσ' => ?_⟩
  · rw [hobj₃ z, delObj_eq_of_le hrep₂ z hzu, hagree₂ z (by omega), hobj₁ z,
      iterSpliceIdx_of_lt u l _ z (by omega)]
  · rw [hcnt₃ z, delCnt_sub_of_mem_region hg₂ hrl hcl₂ z hzu (by omega)]
    omega
  · -- the type at `z`: through `σ₂` (the deletion), `σ₁` (the loop), `σ₀` (the raise), `σ`
    obtain ⟨σ₂, hσ₂⟩ := exists_hist_of_isLadderPath fwd bwd g₂ hg₂
    have hσ₂0 : ∀ t : ℤ, σ₂.state t = (t + 0, g₂ t) := fun t => by rw [add_zero]; exact hσ₂ t
    have hσ'0 : ∀ t : ℤ, σ'.state t = (t + 0, g₃ t) := fun t => by rw [add_zero]; exact hσ' t
    have hty₂' : tpOf (ladderModel step pend fwd bwd lab) φ σ₂ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ₂ (u + ((r * l : ℕ) : ℤ)) := by
      rw [hty₂ σ₂ hσ₂ u (by omega), hty₂ σ₂ hσ₂ _ hrw₀, hty₁ σ₁ hσ₁, hty₁ σ₁ hσ₁,
        iterSpliceIdx_of_lt u l _ u (by omega), iterSpliceIdx_boundary u l hl _ r hrb]
    have hdel := tpOf_eq_delIdx_of_tpOf_eq step pend fwd bwd lab φ u (r * l) hrl (k := 0)
      (k' := 0) σ₂ σ' hσ₂0 hσ'0 (fun w => (hobj₃ w).trans rfl) hno hty₂' z
    have hz₂' : tpOf (ladderModel step pend fwd bwd lab) φ σ' z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ₂ z := by
      rw [hdel]
      rcases lt_or_eq_of_le hzu with hlt | heq
      · rw [delIdx_of_lt u (r * l) z hlt]
      · rw [heq, delIdx_of_ge u (r * l) u le_rfl, ← hty₂']
    have e3 : tpOf (ladderModel step pend fwd bwd lab) φ σ₀ z
        = tpOf (ladderModel step pend fwd bwd lab) φ σ z :=
      tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ
        hσ₀' (fun t => by rw [add_zero]; exact hσ t) (fun _ => rfl) hno z
    rw [hz₂', hty₂ σ₂ hσ₂ z (by omega), hty₁ σ₁ hσ₁, iterSpliceIdx_of_lt u l _ z (by omega), e3]


/-- **THE REGISTER-LOWERING EXACT-SHIFT THEOREM, UP-FIRST.** The exact-shift theorem above with
the TARGET REGISTER freed: the countdown at `z` is still lowered by exactly `m · (P + 1)` and the
object state and the realized stab-free type at `z` are still held, but the register is delivered
at a PRESCRIBED value `n₀ ≤ nxtAt g z`, under forward slack at `m · (P + 1) + k` where
`n₀ + k = nxtAt g z`. Lowering the anchor from `nxtAt g z` to `n₀` costs exactly `k` of
additional slack in the UPPER direction of the single anchor inequality, and nothing in the lower
one (the lower direction only gets easier as the anchor falls); `k = 0` is the held-register
theorem above, hypothesis for hypothesis.

**The construction.** The lowering is performed BEFORE the surgery, not inside it. The countdown
of a ladder path is read off its object walk (`cntAt_sub_of_pend`, `cntAt_eq_zero_of_idle`), but
the REGISTER is not: `exists_ladderPath_of_walk_nxt_at` re-lifts a walk together with its own
countdown at any anchor value whose single pin clause `hn₀` holds, and that clause is exactly the
collapse `anchor_clause_of_first_region_start` at deleted length `0` — one inequality at the first
region start above `z`'s region, which `HasForwardSlack g z (m · (P + 1) + k) (nxtAt g z)`
supplies at `n₀` because the two statements differ by exactly the `k` of the lowering. The
re-lifted path `g₀` has the ORIGINAL walk and countdown and register `n₀` at `z`, so every
hypothesis of the held-register theorem transfers to it verbatim (the regime included: a region
start's countdown is the register's value at the idle position before it, so `HasForwardSlack`
depends on the walk and countdown alone), and its conclusion is this one — the realized type
coming back to `g` through `tpOf_stabFree_eq_of_objAt_eq` on the shared walk. -/
theorem exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ) (n₀ k : ℕ)
    (hk : n₀ + k = nxtAt g z)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) + k ≤ cntAt g z)
    (hslack : HasForwardSlack g z (m * (P + 1) + k) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  have hz : pend (objAt g z) = true := hpast z le_rfl
  -- the regime at the LOWERED register: the `k` of the lowering is exactly the extra slack
  have hslack₀ : HasForwardSlack g z (m * (P + 1)) n₀ := by
    intro I hI hidle hnext
    have := hslack I hI hidle hnext
    omega
  -- (A) the anchor clause at `n₀`, at deleted length `0`, on the ORIGINAL path
  have hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) : ℤ) - n₀).natAbs
        ≤ ((cntAt g z : ℤ) + I - ((0 : ℕ) : ℤ)).natAbs := fun I hI hidle hnext => by
    have := hslack₀ I hI hidle hnext
    have hcast : ((0 : ℕ) : ℤ) = 0 := by norm_num
    rw [hcast]
    omega
  have hanch := anchor_clause_of_first_region_start g hg z hz 0 n₀ hfirst z le_rfl (by
    have hcast : ((0 : ℕ) : ℤ) = 0 := by norm_num
    rw [hcast]; omega)
  have hn₀ : ∀ v : ℤ, pend (objAt g v) = false → pend (objAt g (v + 1)) = true →
      ((cntAt g (v + 1) : ℤ) - n₀).natAbs ≤ (v - z).natAbs := by
    intro v hv0 hv1
    have hzv : z < v := by
      by_contra hle
      exact Bool.false_ne_true (hv0.symm.trans (hpast v (by omega)))
    have h0 : pend (objAt g (v + ((0 : ℕ) : ℤ))) = false := by simpa using hv0
    have h1 : pend (objAt g (v + ((0 : ℕ) : ℤ) + 1)) = true := by simpa using hv1
    have hres := hanch v hzv h0 h1
    rw [cntAt_eq_nxtAt_of_idle_pend g hg v hv0 hv1]
    simpa using hres
  -- (B) the re-lift: the original walk and countdown, the register at `n₀`
  obtain ⟨g₀, hg₀, hobj₀, hcnt₀, hnxt₀⟩ :=
    exists_ladderPath_of_walk_nxt_at (objAt g) (cntAt g) z n₀ (objAt_step g hg)
      (fun v h => cntAt_eq_zero_of_idle g hg v h)
      (fun v h0 h1 => cntAt_succ_of_pend_pend g hg v h0 h1)
      (fun v h0 h1 => (cntAt_eq_zero_of_pend_idle g hg v h0 h1).1)
      (fun s v hs0 hs1 hv0 hv1 => pinCompat_of_ladderPath g hg s v hs0 hs1 hv0 hv1) hn₀
  have hpast₀ : ∀ p : ℤ, p ≤ z → pend (objAt g₀ p) = true := fun p hp => by
    rw [hobj₀ p]; exact hpast p hp
  -- the regime depends on the walk and the countdown alone, so it transfers to the re-lift
  have htrans : ∀ L n : ℕ, HasForwardSlack g z L n → HasForwardSlack g₀ z L n := by
    intro L n hs I hI hidle hnx
    simp only [hobj₀, hcnt₀] at hidle hnx ⊢
    have h0 := hidle (I - 1) (by omega)
    have hcast : z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ)
        = z + (cntAt g z : ℤ) + (I : ℤ) := by
      push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
    rw [hcast] at h0
    have h1 : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
      rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
      exact hnx
    have e1 : nxtAt g₀ (z + (cntAt g z : ℤ) + (I : ℤ))
        = nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) := by
      rw [← cntAt_eq_nxtAt_of_idle_pend g₀ hg₀ _ (by rw [hobj₀]; exact h0)
            (by rw [hobj₀]; exact h1), hcnt₀,
        cntAt_eq_nxtAt_of_idle_pend g hg _ h0 h1]
    rw [e1]
    exact hs I hI hidle hnx
  -- (C) the held-register exact-shift theorem, applied to the re-lift
  obtain ⟨g', hg', hobj', hcnt', hnxt', hty'⟩ :=
    exists_ladderPath_through_deleted_exact_upfirst_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g₀ hg₀ z hpast₀ m (by rw [hcnt₀ z]; exact hTc)
      (by rw [hnxt₀, hcnt₀ z]; omega) (by rw [hnxt₀]; exact htrans _ _ hslack₀)
  refine ⟨g', hg', ?_, ?_, ?_, fun σ σ' hσ hσ' => ?_⟩
  · rw [hobj']; exact hobj₀ z
  · rw [hcnt']; exact hcnt₀ z
  · rw [hnxt', hnxt₀]
  · obtain ⟨σ₀, hσ₀⟩ := exists_hist_of_isLadderPath fwd bwd g₀ hg₀
    rw [hty' σ₀ σ' hσ₀ hσ']
    exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ
      (fun t => by rw [add_zero]; exact hσ₀ t) (fun t => by rw [add_zero]; exact hσ t)
      (fun v => hobj₀ v) hno z

/-- **THE REGISTER-RAISING EXACT-SHIFT THEOREM, UP-FIRST.** The mirror of
`exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`: the countdown at `z` is
lowered by exactly `m · (P + 1)` and the object state and the realized stab-free type at `z` are
held, but the register is delivered at a prescribed value `n₀ ≥ nxtAt g z` — and the regime amount
stays at `m · (P + 1)`, UNCHANGED.

**Why a raise is free where a lowering costs.** The single anchor inequality
`anchor_clause_of_first_region_start` collapses to at deleted length `0` is two-sided, and the two
directions charge for opposite movements of the anchor. LOWERING the anchor from `nxtAt g z` to
`n₀ ≤ nxtAt g z` is paid for in the UPPER direction, which is why the lowered sibling carries
`HasForwardSlack g z (m · (P + 1) + k) (nxtAt g z)` with `n₀ + k = nxtAt g z` and spends exactly
the `k` of the lowering. RAISING it costs nothing in that direction: the regime at
`nxtAt g z` already bounds the first region start's register from above by
`nxtAt g z + cntAt g z + I - m · (P + 1)`, and raising the anchor only weakens that bound. So the
regime hypothesis here is the HELD-register one, at the held-register amount, with `hraise` the
one extra fact consumed.

**What the raise does need.** `hroom : n₀ + 2 + m · (P + 1) ≤ cntAt g z`, carried as a NAMED
hypothesis rather than derived: none of the module's gap conditions implies another, and the two
inputs the held-register theorem asks of the re-lifted path — `n₀ + m · (P + 1) ≤ cntAt g z` for
its own `hgap` and `Tc + m · (P + 1) ≤ cntAt g z` for its threshold — both follow from `hroom`
and `hTc` by `omega`. At `n₀ = nxtAt g z` this is
`exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` hypothesis for hypothesis, up to
`hroom`'s two units of headroom over that theorem's own `hgap`.

**The construction** is the lowered sibling's, with the one trade changed. The raise is performed
BEFORE the surgery: `exists_ladderPath_of_walk_nxt_at` re-lifts the ORIGINAL walk and countdown
at the anchor value `n₀`, whose single pin clause is the collapse of
`anchor_clause_of_first_region_start` at deleted length `0`; the regime depends on the walk and
the countdown alone, so it transfers to the re-lift verbatim, and the held-register theorem then
applies to it with its conclusion read back through the shared walk. -/
theorem exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ) (n₀ : ℕ)
    (hraise : nxtAt g z ≤ n₀)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hroom : n₀ + 2 + m * (P + 1) ≤ cntAt g z)
    (hslack : HasForwardSlack g z (m * (P + 1)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := by
  classical
  have hz : pend (objAt g z) = true := hpast z le_rfl
  -- the regime at the RAISED register: a raise only weakens the bound, so the amount is unchanged
  have hslack₀ : HasForwardSlack g z (m * (P + 1)) n₀ := by
    intro I hI hidle hnext
    have := hslack I hI hidle hnext
    omega
  -- (A) the anchor clause at `n₀`, at deleted length `0`, on the ORIGINAL path
  have hfirst : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      ((nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) : ℤ) - n₀).natAbs
        ≤ ((cntAt g z : ℤ) + I - ((0 : ℕ) : ℤ)).natAbs := fun I hI hidle hnext => by
    have := hslack₀ I hI hidle hnext
    have hcast : ((0 : ℕ) : ℤ) = 0 := by norm_num
    rw [hcast]
    omega
  have hanch := anchor_clause_of_first_region_start g hg z hz 0 n₀ hfirst z le_rfl (by
    have hcast : ((0 : ℕ) : ℤ) = 0 := by norm_num
    rw [hcast]; omega)
  have hn₀ : ∀ v : ℤ, pend (objAt g v) = false → pend (objAt g (v + 1)) = true →
      ((cntAt g (v + 1) : ℤ) - n₀).natAbs ≤ (v - z).natAbs := by
    intro v hv0 hv1
    have hzv : z < v := by
      by_contra hle
      exact Bool.false_ne_true (hv0.symm.trans (hpast v (by omega)))
    have h0 : pend (objAt g (v + ((0 : ℕ) : ℤ))) = false := by simpa using hv0
    have h1 : pend (objAt g (v + ((0 : ℕ) : ℤ) + 1)) = true := by simpa using hv1
    have hres := hanch v hzv h0 h1
    rw [cntAt_eq_nxtAt_of_idle_pend g hg v hv0 hv1]
    simpa using hres
  -- (B) the re-lift: the original walk and countdown, the register at `n₀`
  obtain ⟨g₀, hg₀, hobj₀, hcnt₀, hnxt₀⟩ :=
    exists_ladderPath_of_walk_nxt_at (objAt g) (cntAt g) z n₀ (objAt_step g hg)
      (fun v h => cntAt_eq_zero_of_idle g hg v h)
      (fun v h0 h1 => cntAt_succ_of_pend_pend g hg v h0 h1)
      (fun v h0 h1 => (cntAt_eq_zero_of_pend_idle g hg v h0 h1).1)
      (fun s v hs0 hs1 hv0 hv1 => pinCompat_of_ladderPath g hg s v hs0 hs1 hv0 hv1) hn₀
  have hpast₀ : ∀ p : ℤ, p ≤ z → pend (objAt g₀ p) = true := fun p hp => by
    rw [hobj₀ p]; exact hpast p hp
  -- the regime depends on the walk and the countdown alone, so it transfers to the re-lift
  have htrans : ∀ L n : ℕ, HasForwardSlack g z L n → HasForwardSlack g₀ z L n := by
    intro L n hs I hI hidle hnx
    simp only [hobj₀, hcnt₀] at hidle hnx ⊢
    have h0 := hidle (I - 1) (by omega)
    have hcast : z + (cntAt g z : ℤ) + 1 + ((I - 1 : ℕ) : ℤ)
        = z + (cntAt g z : ℤ) + (I : ℤ) := by
      push_cast [Nat.cast_sub (by omega : 1 ≤ I)]; ring
    rw [hcast] at h0
    have h1 : pend (objAt g (z + (cntAt g z : ℤ) + (I : ℤ) + 1)) = true := by
      rw [show z + (cntAt g z : ℤ) + (I : ℤ) + 1 = z + (cntAt g z : ℤ) + 1 + (I : ℤ) by ring]
      exact hnx
    have e1 : nxtAt g₀ (z + (cntAt g z : ℤ) + (I : ℤ))
        = nxtAt g (z + (cntAt g z : ℤ) + (I : ℤ)) := by
      rw [← cntAt_eq_nxtAt_of_idle_pend g₀ hg₀ _ (by rw [hobj₀]; exact h0)
            (by rw [hobj₀]; exact h1), hcnt₀,
        cntAt_eq_nxtAt_of_idle_pend g hg _ h0 h1]
    rw [e1]
    exact hs I hI hidle hnx
  -- (C) the held-register exact-shift theorem, applied to the re-lift
  obtain ⟨g', hg', hobj', hcnt', hnxt', hty'⟩ :=
    exists_ladderPath_through_deleted_exact_upfirst_of_pend_past step pend fwd bwd lab φ
      Tc Tn P B hp hno g₀ hg₀ z hpast₀ m (by rw [hcnt₀ z]; exact hTc)
      (by rw [hnxt₀, hcnt₀ z]; omega) (by rw [hnxt₀]; exact htrans _ _ hslack₀)
  refine ⟨g', hg', ?_, ?_, ?_, fun σ σ' hσ hσ' => ?_⟩
  · rw [hobj']; exact hobj₀ z
  · rw [hcnt']; exact hcnt₀ z
  · rw [hnxt', hnxt₀]
  · obtain ⟨σ₀, hσ₀⟩ := exists_hist_of_isLadderPath fwd bwd g₀ hg₀
    rw [hty' σ₀ σ' hσ₀ hσ']
    exact tpOf_stabFree_eq_of_objAt_eq fwd bwd lab φ (k := 0) (k' := 0) σ₀ σ
      (fun t => by rw [add_zero]; exact hσ₀ t) (fun t => by rw [add_zero]; exact hσ t)
      (fun v => hobj₀ v) hno z

/-- **THE DOWNWARD CELL INCLUSION ON THE WITNESSING PATH, under the regime at exactly
`m · (P + 1)`.** In the pending-forever regime (`n + 2 ≤ c`) at countdown at least `Tc`: every
type realized at `(q, c + m · (P + 1), n)` BY A PATH `g` satisfying
`HasForwardSlack g z (m · (P + 1)) n` is realized at `(q, c, n)`, by the up-first exact-shift
theorem. The hypotheses are exactly `n + 2 ≤ c`, `Tc ≤ c` and the regime at `m · (P + 1)`: no
`budget²` term in the gap or in the regime amount. The hypothesis is on the WITNESSING PATH, not
on the state: `cellAt` is existential over histories, so this is the only sound downward statement
under a path-level regime — the climbing-register path `ClimbWitness.climb` passes through a state
satisfying every state-level hypothesis the consumer carries and violates the regime, so no
state-level variant can be stated (`ClimbWitness.hasForwardSlack_refuted_unconditional`). The
reserved name `cellLE_zero_const_of_kappa_eq` remains claimed by nothing: the obligation
quantifies over every path through the state and concludes cell EQUALITY, and what separates this
inclusion from it is the tight (doubling) chain, no finite deletion-derivative of which lifts —
argued in the task record, not compiled. -/
theorem mem_cellAt_of_shift_of_hasForwardSlack_exact
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n), h'⟩)
    (hslack : HasForwardSlack g z (m * (P + 1)) n)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := by
  classical
  have hoz : objAt g z = q := by simp [objAt, hgz]
  have hcz : cntAt g z = c + m * (P + 1) := by simp [cntAt, hgz]
  have hnz : nxtAt g z = n := by simp [nxtAt, hgz]
  have hz : pend (objAt g z) = true := by
    by_contra hne
    rw [Bool.not_eq_true, hoz] at hne
    have := h hne
    omega
  have hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; omega)
  obtain ⟨g', hg', ho, hc, hn, hty⟩ :=
    exists_ladderPath_through_deleted_exact_upfirst_of_pend_past step pend fwd bwd lab φ Tc Tn P B
      hp hno g hg z hpast m (by rw [hcz]; omega) (by rw [hcz, hnz]; omega)
      (by rw [hnz]; exact hslack)
  have hc' : cntAt g' z = c := by omega
  obtain ⟨τ', hτ'⟩ := exists_hist_of_isLadderPath fwd bwd g' hg'
  rw [mem_cellAt_ladder_iff]
  refine ⟨g', τ', hg', ?_, hτ', ?_⟩
  · apply Subtype.ext
    change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c, n)
    rw [ho, hc', hn, hoz, hnz]
  · exact hty τ τ' hτ hτ'

/-- **THE EXACT-SHIFT THEOREM under the regime at `m · (P + 1) + budget²`** (statement kept
verbatim): through a pending-forever path's state at `z` with room `Tc + m · (P + 1) ≤ cntAt g z`,
under the gap and the forward-slack regime at amount `m · (P + 1) + budget²`, a ladder path with
`z`'s countdown lowered by exactly `m · (P + 1)`, the object state and the register at `z` held,
and the realized stab-free type at `z` held. A corollary of the up-first
`exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`: monotonicity of the regime
(`hasForwardSlack_mono`) brings the amount down to `m · (P + 1)`, and arithmetic on the gap drops
its `budget²` summand. The `budget²` term in both hypotheses is slack this statement carries and
the up-first ordering does not need. -/
theorem exists_ladderPath_through_deleted_exact_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) +
      Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) ≤ cntAt g z)
    (hslack : HasForwardSlack g z
      (m * (P + 1) + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z :=
  exists_ladderPath_through_deleted_exact_upfirst_of_pend_past step pend fwd bwd lab φ Tc Tn P B
    hp hno g hg z hpast m hTc (by omega) (hasForwardSlack_mono g z hslack (Nat.le_add_right _ _))

-- TWO linters see `hslk`, and each needs a DIFFERENT remedy. The binder is the gap
-- `n + budget² ≤ c`: slack the `_exact` form does not need once the regime amount is
-- `m · (P + 1)`, so this proof does not read it. The statement is nonetheless kept verbatim
-- because it is a pinned Challenge statement -- dropping the binder would be
-- same-name-different-signature drift against that pin.
--   (1) The FRONTEND linter `linter.unusedVariables` is silenced by the `set_option ... in`
--       line below, which must stay: `hslk` is still an unused binder at the frontend.
--   (2) Batteries' `@[env_linter] unusedArguments` -- the linter `lake exe runLinter` and
--       `scripts/check-module-invariants.sh`'s C16 actually run -- reads the COMPILED
--       environment, so no `set_option linter.*` reaches it. It is exempted instead by the
--       matching row in `scripts/nolints.json`.
-- Do NOT regenerate that ledger with `lake exe runLinter --update`: it rewrites the whole file
-- from current findings in a different serialization, grandfathering any genuine regression
-- along with this row. Add or remove rows there by hand.
set_option linter.unusedVariables false in
/-- **THE DOWNWARD CELL INCLUSION ON THE WITNESSING PATH, under the regime at
`m · (P + 1) + budget²`** (statement kept verbatim): a corollary of
`mem_cellAt_of_shift_of_hasForwardSlack_exact`, which carries the witnessing-path discussion and
the reserved-name boundary. Monotonicity of the regime (`hasForwardSlack_mono`) brings the amount
down to `m · (P + 1)`; the gap `hslk` is slack this statement carries and the `_exact` form does
not need. -/
theorem mem_cellAt_of_shift_of_hasForwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c)
    (hslk : n + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) ≤ c)
    (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n), h'⟩)
    (hslack : HasForwardSlack g z
      (m * (P + 1) + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)) n)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z :=
  mem_cellAt_of_shift_of_hasForwardSlack_exact step pend fwd bwd lab φ Tc Tn P B hp hno q c n h m
    h' hgap hTc z g hg hgz (hasForwardSlack_mono g z hslack (Nat.le_add_right _ _)) τ hτ

end DelNxtIter

/-- **THE UPWARD CELL INCLUSION along the common-shift chain.** In the pending-forever regime
(`n + 2 ≤ c`, so by `pend_past_of_nxtAt_lt` every path through the state is pending forever into
the past) at countdown at least `Tc`, the cell at `(q, c, n)` is contained in the cell at
`(q, c + m · (P + 1), n)`: every type realized at the former is realized at the latter by the
regime-A assembly. The downward inclusion is `mem_cellAt_of_shift_of_hasForwardSlack_exact`,
stated on the witnessing path under exactly `n + 2 ≤ c`, `Tc ≤ c` and
`HasForwardSlack g z (m · (P + 1)) n`, through the up-first exact-shift theorem
`exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`; no state-level downward
inclusion is claimed. Under `kappa_eq_components` this covers the sub-regime `n = n'`;
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
