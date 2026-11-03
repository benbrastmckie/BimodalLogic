/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderPump

/-!
# The pin layer: what the pins of a ladder path force

## Contract

This module is CERTIFICATE-FREE under the same grep as `LadderPump.lean`: it mentions no
certificate object at all — not the certificate conditions, not the maximum certified subset,
not the closure-component type of the certificate layer, not the consistency bundle, not the
idle-extended coherence relation, and not the periodicity fixpoint's threshold or period — and
it imports `LadderPump` alone. It holds ONE argument: what the PINS of a ladder path — an idle
position immediately followed by a pending one — force about the path, and about the closure
types realized along it.

The layer has two halves. The DICHOTOMY: below a position carrying no pin at all, the pending
positions are downward closed, so the past is either uniformly idle or uniformly pending
(`pend_past_or_idle_of_no_pin_below`), and hence every pending position of a ladder path either
has a uniformly pending past or has its countdown bounded by its register plus one
(`pendPast_or_cntAt_le_nxtAt_succ`). The PIGEONHOLE: enough pins in a window force two of them
at least two apart to carry the same object state and the same realized type at their successor
positions, which produces a type-respecting block SPANNING a pin
(`exists_pinTypeBlock_of_budget_lt_pins`).

## Where this sits between the two windows of the register

The next-deadline register is read by the cell in BOTH directions, and this module sits between
the two landed windows. Backward, `cntAt_le_nxtAt_succ_of_idle_past` (`LadderAgree.lean`): a
pending position with ANY idle position in its past has countdown at most its register plus one.
Forward, `nxtAt_le_cntAt_add_of_next_region` (`LadderPump.lean`): the register at a position is
at most the countdown there plus the next idle run plus the next region's start countdown. The
dichotomy here names the complementary side of the backward window exactly — the pin-free side,
on which the past is uniformly pending and the landed regime-A assembly applies — and
`pend_past_of_nxtAt_lt` (`LadderAgree.lean`) is the landed converse, cited rather than re-proved.

## What this module does NOT hold

No cell-level agreement, no `ParamsOk`-level assembly (that is `LadderChain.lean`'s, which is
NOT certificate-free by design, and the `(K2)`-level arithmetic of the pin density lives there
for exactly that reason), no claim that pins are dense on a general path — a path may carry one
long region and no pin at all, and the dichotomy's point is that such a path IS the pin-free
side — and no `⊡`-letter transport: the pigeonhole below reads `tpOf` only through the powerset
of the closure, as `LadderPump.lean`'s own pigeonhole does.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## The pin-free dichotomy

A PIN of a ladder path is an idle position `s` whose successor `s + 1` is pending: the start of a
pending region, read at the idle position before it. The two statements below say what the ABSENCE
of a pin below a position forces, and the dichotomy that follows for a general pending position. -/

section Dichotomy

variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}

/-- **PENDING IS DOWNWARD CLOSED BELOW A PIN-FREE POSITION**, read as the forward propagation of
idleness: with no pin at or below `p`, an idle position `w` forces every position between `w` and
`p` to be idle. One step of the induction IS the absence of a pin: an idle `w + n` whose successor
were pending would be a pin at `w + n`. -/
theorem idle_of_idle_of_no_pin_below (g : ℤ → LadderState Q pend) (p : ℤ)
    (hnp : ∀ s : ℤ, s + 1 ≤ p → pend (objAt g s) = false →
      pend (objAt g (s + 1)) = true → False)
    (w : ℤ) (hw : pend (objAt g w) = false) :
    ∀ k : ℕ, w + (k : ℤ) ≤ p → pend (objAt g (w + (k : ℤ))) = false := by
  intro k
  induction k with
  | zero => intro _; simpa using hw
  | succ n ih =>
      intro hle
      have hcast : w + ((n + 1 : ℕ) : ℤ) = w + (n : ℤ) + 1 := by push_cast; ring
      rw [hcast] at hle ⊢
      have hn : w + (n : ℤ) ≤ p := by omega
      have hidle := ih hn
      by_contra hcon
      rw [Bool.not_eq_false] at hcon
      exact hnp (w + (n : ℤ)) hle hidle hcon

/-- **THE PIN-FREE DICHOTOMY.** With no pin at or below `p`, the past at or below `p` is either
uniformly idle or uniformly pending from some position down: pending is downward closed there, so
there is no third shape. This is the complementary side of the backward window
`cntAt_le_nxtAt_succ_of_idle_past`, which consumes an idle position in the past; here there is
none to consume below a pending position, and the past is pending forever. -/
theorem pend_past_or_idle_of_no_pin_below (g : ℤ → LadderState Q pend) (p : ℤ)
    (hnp : ∀ s : ℤ, s + 1 ≤ p → pend (objAt g s) = false →
      pend (objAt g (s + 1)) = true → False) :
    (∀ v : ℤ, v ≤ p → pend (objAt g v) = false)
      ∨ (∃ v : ℤ, v ≤ p ∧ ∀ w : ℤ, w ≤ v → pend (objAt g w) = true) := by
  classical
  by_cases hall : ∀ v : ℤ, v ≤ p → pend (objAt g v) = false
  · exact Or.inl hall
  · push Not at hall
    obtain ⟨v, hvp, hv⟩ := hall
    rw [ne_eq, Bool.not_eq_false] at hv
    refine Or.inr ⟨v, hvp, ?_⟩
    intro w hwv
    by_contra hcon
    rw [Bool.not_eq_true] at hcon
    have hidle := idle_of_idle_of_no_pin_below g p hnp w hcon (v - w).toNat (by omega)
    rw [show w + (((v - w).toNat : ℕ) : ℤ) = v by omega] at hidle
    exact Bool.false_ne_true (hidle.symm.trans hv)

/-- **THE COUNTER-LEVEL DICHOTOMY AT A PENDING POSITION.** Every pending position of a ladder
path is on exactly one of the two sides the cell's replacement argument must treat separately:
either its past is uniformly pending — the pin-free side, which is the hypothesis the landed
upward cell inclusion `cellAt_subset_of_shift_of_pend_past` already consumes — or its countdown
is at most its register plus one, which is the backward window. The split is over the PINS: a pin
at or below `z` supplies the idle position the window needs, and its absence routes through
`pend_past_or_idle_of_no_pin_below`, whose uniformly-idle side is refuted at `z` itself. -/
theorem pendPast_or_cntAt_le_nxtAt_succ (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (hz : pend (objAt g z) = true) :
    (∀ w : ℤ, w ≤ z → pend (objAt g w) = true) ∨ cntAt g z ≤ nxtAt g z + 1 := by
  classical
  by_cases hpin : ∃ s : ℤ, s + 1 ≤ z ∧ pend (objAt g s) = false ∧
      pend (objAt g (s + 1)) = true
  · obtain ⟨s, hsz, hsi, -⟩ := hpin
    exact Or.inr (cntAt_le_nxtAt_succ_of_idle_past g hg z s hz (by omega) hsi)
  · have hnp : ∀ s : ℤ, s + 1 ≤ z → pend (objAt g s) = false →
        pend (objAt g (s + 1)) = true → False := fun s h1 h2 h3 => hpin ⟨s, h1, h2, h3⟩
    rcases pend_past_or_idle_of_no_pin_below g z hnp with hall | _hex
    · exact absurd ((hall z le_rfl).symm.trans hz) Bool.false_ne_true
    · refine Or.inl ?_
      intro w hwz
      by_contra hcon
      rw [Bool.not_eq_true] at hcon
      have hidle := idle_of_idle_of_no_pin_below g z hnp w hcon (z - w).toNat (by omega)
      rw [show w + (((z - w).toNat : ℕ) : ℤ) = z by omega] at hidle
      exact Bool.false_ne_true (hidle.symm.trans hz)

end Dichotomy

/-! ## The pigeonhole over region starts

`LadderPump.lean`'s pigeonhole runs over the positions INSIDE one pending region, so the block it
produces never crosses a pin — its hypothesis `l ≤ cntAt g u` puts it inside the region. The
pigeonhole below runs over the PINS themselves, so the block it produces SPANS one: given more
than the type-pigeonhole budget of pins in a window, two of them at least two apart carry the same
object state and the same realized type at their successor positions, and the block between those
two successor positions contains the pin in between.

The arithmetic is the same `Fintype.exists_ne_map_eq_of_card_lt` over
`Q × (plusSubformulaClosure φ).powerset` that `LadderPump.lean`'s own pigeonhole uses, never
through the certificate layer's product carrier, which this module's contract forbids. The
pigeonhole is restricted to the EVEN-indexed pins, at the cost of a factor two in the hypothesis:
the two colliding pins must be at least two apart for a third pin to lie strictly inside the block
they bound, and the even indices buy that separation directly.

This produces a spanning block AT A GIVEN OBJECT where the pins are dense. It is NOT the refuted
spanning-block device, which asserted a spanning block unconditionally under `ParamsOk`; the
hypothesis here is the pin count, and nothing below claims that count is derivable. -/

section PinPigeonhole

variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}

-- `linter.unusedVariables`, scoped to this declaration: the signature is pinned by the plan's
-- Lean Challenge Statements block, and the even-indexed pins' own idle/pending data is not read —
-- only the pin strictly inside the block is, so `hpin` is consumed at one odd index.
set_option linter.unusedVariables false in
/-- **THE PIGEONHOLE OVER REGION STARTS.** With `s` enumerating `N` pins strictly monotonically
and `N` exceeding twice the type-pigeonhole budget by two, there is a type-respecting block
`[u, u + l)` inside the window `(s 0, s (N - 1) + 1]` that contains a pin `t` strictly inside it:
`u ≤ t` and `t + 1 < u + l`, with equal object state and equal realized type at the block's two
ends. The block therefore SPANS a region start, which is the data the refuted device would have
had to produce unconditionally. -/
theorem exists_pinTypeBlock_of_budget_lt_pins
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (s : ℕ → ℤ) (hmono : StrictMono s) (N : ℕ)
    (hN : 2 * (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) + 2 ≤ N)
    (hpin : ∀ i : ℕ, i < N →
      pend (objAt g (s i)) = false ∧ pend (objAt g (s i + 1)) = true) :
    ∃ (u : ℤ) (l : ℕ) (t : ℤ), 0 < l ∧ u ≤ t ∧ t + 1 < u + (l : ℤ) ∧
      s 0 < u ∧ u + (l : ℤ) ≤ s (N - 1) + 1 ∧
      pend (objAt g t) = false ∧ pend (objAt g (t + 1)) = true ∧
      objAt g u = objAt g (u + (l : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ)) := by
  classical
  set b := Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card with hb
  -- the collision, read off the even-indexed pins' successor positions
  have key : ∀ i j : ℕ, i < j → j ≤ b →
      objAt g (s (2 * i) + 1) = objAt g (s (2 * j) + 1) →
      tpOf (ladderModel step pend fwd bwd lab) φ σ (s (2 * i) + 1)
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (s (2 * j) + 1) →
      ∃ (u : ℤ) (l : ℕ) (t : ℤ), 0 < l ∧ u ≤ t ∧ t + 1 < u + (l : ℤ) ∧
        s 0 < u ∧ u + (l : ℤ) ≤ s (N - 1) + 1 ∧
        pend (objAt g t) = false ∧ pend (objAt g (t + 1)) = true ∧
        objAt g u = objAt g (u + (l : ℤ)) ∧
        tpOf (ladderModel step pend fwd bwd lab) φ σ u
          = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ)) := by
    intro i j hij hjb hobj hty
    -- the three strict inequalities the enumeration supplies, and the window's two bounds
    have h1 : s (2 * i) < s (2 * i + 1) := hmono (by omega)
    have h2 : s (2 * i + 1) < s (2 * j) := hmono (by omega)
    have h0 : s 0 ≤ s (2 * i) := hmono.monotone (by omega)
    have hNm : s (2 * j) ≤ s (N - 1) := hmono.monotone (by omega)
    have hL : (((s (2 * j) - s (2 * i)).toNat : ℕ) : ℤ) = s (2 * j) - s (2 * i) := by omega
    have hmid := hpin (2 * i + 1) (by omega)
    have hend : s (2 * i) + 1 + (((s (2 * j) - s (2 * i)).toNat : ℕ) : ℤ) = s (2 * j) + 1 := by
      omega
    refine ⟨s (2 * i) + 1, (s (2 * j) - s (2 * i)).toNat, s (2 * i + 1), by omega, by omega,
      by omega, by omega, by omega, hmid.1, hmid.2, ?_, ?_⟩
    · rw [hend]; exact hobj
    · rw [hend]; exact hty
  -- the pigeonhole itself, over the `b + 1` even-indexed pins
  let f : Fin (b + 1) → Q × {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset} :=
    fun i => (objAt g (s (2 * (i : ℕ)) + 1),
      ⟨tpOf (ladderModel step pend fwd bwd lab) φ σ (s (2 * (i : ℕ)) + 1),
        Finset.mem_powerset.mpr (tpOf_subset _ φ σ _)⟩)
  obtain ⟨a, c, hac, hf⟩ := Fintype.exists_ne_map_eq_of_card_lt f (by
    rw [Fintype.card_prod, Fintype.card_coe, Finset.card_powerset, Fintype.card_fin]
    omega)
  have hf' : f a = f c := hf
  simp only [f, Prod.mk.injEq, Subtype.mk.injEq] at hf'
  obtain ⟨hobj, hty⟩ := hf'
  rcases lt_or_gt_of_ne (fun h : (a : ℕ) = (c : ℕ) => hac (Fin.ext h)) with hlt | hlt
  · exact key (a : ℕ) (c : ℕ) hlt (by omega) hobj hty
  · exact key (c : ℕ) (a : ℕ) hlt (by omega) hobj.symm hty.symm

/-- **THE SPANNING-BLOCK DATA, in the shape the refuted device's statement took.** With the pin
window closed off below a position `z`, the pigeonhole's block lies entirely below `z` and
contains a pin strictly inside it — the tuple `(u, l, t)` with the two endpoint equalities, ready
to be consumed without re-deriving it. The hypothesis is the PIN COUNT in the window, which is
exactly what the refuted device had to do without. -/
theorem exists_spanningBlock_of_pins_below
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (s : ℕ → ℤ) (hmono : StrictMono s) (N : ℕ)
    (hN : 2 * (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) + 2 ≤ N)
    (hpin : ∀ i : ℕ, i < N →
      pend (objAt g (s i)) = false ∧ pend (objAt g (s i + 1)) = true)
    (z : ℤ) (hz : s (N - 1) + 1 ≤ z) :
    ∃ (u : ℤ) (l : ℕ) (t : ℤ), 0 < l ∧ u ≤ t ∧ t + 1 < u + (l : ℤ) ∧ u + (l : ℤ) ≤ z ∧
      pend (objAt g t) = false ∧ pend (objAt g (t + 1)) = true ∧
      objAt g u = objAt g (u + (l : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + (l : ℤ)) := by
  obtain ⟨u, l, t, hl, hut, htl, -, hhi, hti, htp, hobj, hty⟩ :=
    exists_pinTypeBlock_of_budget_lt_pins step pend fwd bwd lab φ σ s hmono N hN hpin
  exact ⟨u, l, t, hl, hut, htl, le_trans hhi hz, hti, htp, hobj, hty⟩

end PinPigeonhole

end FormalSystem.Metalogic.Decidability.RaySummary
