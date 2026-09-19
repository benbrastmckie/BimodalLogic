/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.Correspondence.FwdRecPeriodicity
import Mathlib.Data.Set.Card

/-!
# The limit-closure frame `EF`: a budgeted digraph with a hub, over integer time

The frame underneath the countermodel to the limit-closure formula
(`Semantics/PlusLanguage/PlusLimitClosure.lean`). World states are `Option (Bool × ℕ)`:

* `none` is a **hub**. It reaches every state, and only the hub reaches it.
* `some (c, k)` carries a Boolean *class* `c` and a natural-number *budget* `k`. A step
  `some (c, k) → some (c', k')` requires `k' ≤ k`, and `k' < k` whenever `c' = true`.

So along any walk that has left the hub, the budget never increases and strictly decreases on
every entry into the `true` class: a walk at `some (c, k)` can visit the `true` class at most `k`
more times. That is why the budget bounds future `p`-visits in the model built on this frame.
Before leaving the hub nothing is bounded, and the hub can hand out any budget, so every *finite*
number of `true`-visits is realised from the hub while infinitely many is not. The frame is
necessarily nondeterministic — the hub reaches every state in one step — as it must be, since the
limit-closure formula is a theorem once `⊡` collapses to the identity. The one-line reading of
the countermodel this frame supports: its set of class-sequences is a dense, non-closed bundle.

## Construction

The one-step relation `eR` is transitive (`eR_trans`) and dense (`eR_dense`), so the `n`-step
relation is `eR` for every `n ≥ 1`, and the task relation over `ℤ` can be given in closed form:
`eRel w d u` is `w = u` at `d = 0`, `eR w u` at `d > 0`, and `eR u w` at `d < 0`. The construction
follows `Metalogic/Independence/ForwardDeterministicFrame.lean`: a reflective two-sided relation,
whose `FrameOver` fields come from the `TaskFrame.*_reflect_of_reflective` lemmas.

*Saturation* is the only field that needs an idea. Forward fibres of non-hub states are finite
(`eR_fwd_finite`: the budget bounds them), so every fibre and every segment either contains the
hub or is finite (`eRel_fib_hub_or_finite`, `eRel_seg_hub_or_finite`). A `⊇`-directed family of
such sets therefore either has a finite member — and then
`sInter_nonempty_of_directed_of_finite_mem` applies — or has the hub in every member.

## Main Definitions

- `EW`, `eR`, `eπ` — the carrier, the one-step relation, the class projection
- `eRel` — the two-sided task relation over `ℤ`
- `eFrameOver`, `EF` — the frame, with every `FrameOver` field discharged
- `histOfWalk` — the world history of a bi-infinite `eR`-walk

## Main Results

- `eR_trans`, `eR_dense`, `eR_succ`
- `eRel_comp`, `eRel_serial`, `eRel_limit`, `eRel_saturation`
- `ef_taskRel_iff` — `EF.TaskRel` is `eRel`
- `isWalk_state`, `walk_lt` — world histories of `EF` are exactly the bi-infinite `eR`-walks

## References

Paper: — (formalization-native)
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Semantics
open FormalSystem.Semantics.Walk

/-- The world states of the limit-closure frame: a hub `none`, and class/budget pairs. -/
abbrev EW := Option (Bool × ℕ)

/-- The one-step relation. The hub reaches everything and is reached only from itself; between
non-hub states the budget is non-increasing, and strictly decreases on entering the `true`
class. -/
def eR : EW → EW → Prop
  | none, _ => True
  | some _, none => False
  | some (_, k), some (c', k') => k' ≤ k ∧ (c' = true → k' < k)

/-- The class projection: the Boolean component, with the hub in the `false` class. -/
def eπ : EW → Bool
  | none => false
  | some (c, _) => c

/-- `eR` is transitive. -/
theorem eR_trans {x y z : EW} (h1 : eR x y) (h2 : eR y z) : eR x z := by
  rcases x with _ | ⟨c, k⟩
  · trivial
  · rcases y with _ | ⟨c1, k1⟩
    · exact h1.elim
    · rcases z with _ | ⟨c2, k2⟩
      · exact h2.elim
      · exact ⟨le_trans h2.1 h1.1, fun hc => lt_of_lt_of_le (h2.2 hc) h1.1⟩

/-- `eR` is dense: every step factors through the hub, or through the `false` state at the
source's own budget. -/
theorem eR_dense {x z : EW} (h : eR x z) : ∃ y, eR x y ∧ eR y z := by
  rcases x with _ | ⟨c, k⟩
  · exact ⟨none, trivial, trivial⟩
  · rcases z with _ | ⟨c2, k2⟩
    · exact h.elim
    · exact ⟨some (false, k), ⟨le_rfl, by simp⟩, h⟩

/-- `eR` is serial. -/
theorem eR_succ (x : EW) : ∃ y, eR x y := by
  rcases x with _ | ⟨c, k⟩
  · exact ⟨none, trivial⟩
  · exact ⟨some (false, k), le_rfl, by simp⟩

/-- The two-sided task relation over `ℤ`: identity at `0`, `eR` forwards, its converse
backwards. Since `eR` is transitive and dense, this is the `n`-step relation in closed form. -/
def eRel (w : EW) (d : ℤ) (u : EW) : Prop :=
  (d = 0 ∧ w = u) ∨ (0 < d ∧ eR w u) ∨ (d < 0 ∧ eR u w)

/-- At duration `0` the task relation is the identity. -/
theorem eRel_zero {w u : EW} : eRel w 0 u ↔ w = u := by
  unfold eRel
  constructor
  · rintro (⟨_, h⟩ | ⟨h, _⟩ | ⟨h, _⟩)
    · exact h
    · omega
    · omega
  · exact fun h => Or.inl ⟨rfl, h⟩

/-- At a positive duration the task relation is `eR`. -/
theorem eRel_pos {w u : EW} {d : ℤ} (hd : 0 < d) : eRel w d u ↔ eR w u := by
  unfold eRel
  constructor
  · rintro (⟨h, _⟩ | ⟨_, h⟩ | ⟨h, _⟩)
    · omega
    · exact h
    · omega
  · exact fun h => Or.inr (Or.inl ⟨hd, h⟩)

/-- At a negative duration the task relation is the converse of `eR`. -/
theorem eRel_neg {w u : EW} {d : ℤ} (hd : d < 0) : eRel w d u ↔ eR u w := by
  unfold eRel
  constructor
  · rintro (⟨h, _⟩ | ⟨h, _⟩ | ⟨_, h⟩)
    · omega
    · omega
    · exact h
  · exact fun h => Or.inr (Or.inr ⟨hd, h⟩)

/-- *Reflection*: `eRel` is reflective by construction. -/
theorem eRel_reflection (w : EW) (d : ℤ) (u : EW) : eRel w d u ↔ eRel u (-d) w := by
  unfold eRel
  constructor
  · rintro (⟨h, e⟩ | ⟨h, e⟩ | ⟨h, e⟩)
    · exact Or.inl ⟨by omega, e.symm⟩
    · exact Or.inr (Or.inr ⟨by omega, e⟩)
    · exact Or.inr (Or.inl ⟨by omega, e⟩)
  · rintro (⟨h, e⟩ | ⟨h, e⟩ | ⟨h, e⟩)
    · exact Or.inl ⟨by omega, e.symm⟩
    · exact Or.inr (Or.inr ⟨by omega, e⟩)
    · exact Or.inr (Or.inl ⟨by omega, e⟩)

/-- *Seriality*: forwards from `eR_succ`, backwards through the hub. -/
theorem eRel_serial : TaskFrame.Serial (D := TemporalOrder.of ℤ) eRel := by
  intro w x hx
  have hx' : (0 : ℤ) ≤ x := hx
  rcases hx'.eq_or_lt with h | h
  · subst h
    exact ⟨⟨w, eRel_zero.mpr rfl⟩, ⟨w, eRel_zero.mpr rfl⟩⟩
  · obtain ⟨y, hy⟩ := eR_succ w
    exact ⟨⟨y, (eRel_pos h).mpr hy⟩, ⟨none, (eRel_pos h).mpr trivial⟩⟩

/-- *Compositionality*: `eR_trans` one way, `eR_dense` the other. -/
theorem eRel_comp : TaskFrame.Compositional (D := TemporalOrder.of ℤ) eRel := by
  intro w v x y hx hy
  have hx' : (0 : ℤ) ≤ x := hx
  have hy' : (0 : ℤ) ≤ y := hy
  change eRel w ((x : ℤ) + y) v ↔ ∃ u, eRel w (x : ℤ) u ∧ eRel u (y : ℤ) v
  rcases hx'.eq_or_lt with h | h
  · subst h
    rw [zero_add]
    exact ⟨fun h => ⟨w, eRel_zero.mpr rfl, h⟩, fun ⟨u, h1, h2⟩ => (eRel_zero.mp h1) ▸ h2⟩
  · rcases hy'.eq_or_lt with h' | h'
    · subst h'
      rw [add_zero]
      exact ⟨fun h => ⟨v, h, eRel_zero.mpr rfl⟩, fun ⟨u, h1, h2⟩ => (eRel_zero.mp h2) ▸ h1⟩
    · rw [eRel_pos (add_pos h h')]
      constructor
      · intro hr
        obtain ⟨u, h1, h2⟩ := eR_dense hr
        exact ⟨u, (eRel_pos h).mpr h1, (eRel_pos h').mpr h2⟩
      · rintro ⟨u, h1, h2⟩
        exact eR_trans ((eRel_pos h).mp h1) ((eRel_pos h').mp h2)

/-- *Limit*, from `TaskFrame.limit_of_succOrder`: `ℤ` is a `SuccOrder` with `NoMaxOrder`. -/
theorem eRel_limit :
    ∀ w u, (∀ x : ℤ, 0 < x → ∃ y, |y| < x ∧ eRel w y u) → u = w :=
  TaskFrame.limit_of_succOrder (D := ℤ) fun _ _ h => (eRel_zero.mp h).symm

/-! ### Saturation -/

/--
A `⊇`-directed family of nonempty sets with one **finite** member has nonempty intersection.
Frame-agnostic; a corollary of `TaskFrame.sInter_nonempty_of_directed_of_minimal`, applied at a
finite member of least cardinality, which is `⊆`-minimal in the family.
-/
theorem sInter_nonempty_of_directed_of_finite_mem {W : Type} {S : Set (Set W)}
    (hd : ∀ S₁ ∈ S, ∀ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂) (hne : ∀ s ∈ S, s.Nonempty)
    {s₀ : Set W} (h₀ : s₀ ∈ S) (hfin : s₀.Finite) : (⋂₀ S).Nonempty := by
  classical
  have hex : ∃ n : ℕ, ∃ s ∈ S, s.Finite ∧ Set.ncard s = n := ⟨_, s₀, h₀, hfin, rfl⟩
  obtain ⟨Sstar, hStarMem, hStarFin, hStarCard⟩ := Nat.find_spec hex
  refine TaskFrame.sInter_nonempty_of_directed_of_minimal hd hne hStarMem ?_
  intro T hT hsub
  have hTfin : T.Finite := hStarFin.subset hsub
  have hle : Set.ncard Sstar ≤ Set.ncard T := by
    rw [hStarCard]; exact Nat.find_le ⟨T, hT, hTfin, rfl⟩
  have heq : T = Sstar := Set.eq_of_subset_of_ncard_le hsub hle hStarFin
  rw [heq]

/-- Forward fibres of non-hub states are finite: the budget bounds them. -/
theorem eR_fwd_finite (c : Bool) (k : ℕ) : {u : EW | eR (some (c, k)) u}.Finite := by
  refine Set.Finite.subset
    ((Finset.univ (α := Bool) ×ˢ Finset.range (k + 1)).image some).finite_toSet ?_
  rintro (_ | ⟨c', k'⟩) hu
  · exact hu.elim
  · have : k' ≤ k := hu.1
    simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_product,
      Finset.mem_univ, true_and, Finset.mem_range]
    exact ⟨(c', k'), by omega, rfl⟩

/-- Every fibre of `eRel` contains the hub or is finite. -/
theorem eRel_fib_hub_or_finite (w : EW) (d : ℤ) :
    none ∈ TaskFrame.Fib (D := TemporalOrder.of ℤ) eRel w d ∨
      (TaskFrame.Fib (D := TemporalOrder.of ℤ) eRel w d).Finite := by
  rcases lt_trichotomy d 0 with h | h | h
  · exact Or.inl ((eRel_neg h).mpr trivial)
  · subst h
    refine Or.inr (Set.Finite.subset (Set.finite_singleton w) ?_)
    intro u hu
    exact (eRel_zero.mp hu).symm
  · rcases w with _ | ⟨c, k⟩
    · exact Or.inl ((eRel_pos h).mpr trivial)
    · refine Or.inr (Set.Finite.subset (eR_fwd_finite c k) ?_)
      intro u hu
      exact (eRel_pos h).mp hu

/-- Every segment of `eRel` contains the hub or is finite. -/
theorem eRel_seg_hub_or_finite (w v : EW) (x y : ℤ) (hy : 0 ≤ y) :
    none ∈ TaskFrame.Seg (D := TemporalOrder.of ℤ) eRel w v x y ∨
      (TaskFrame.Seg (D := TemporalOrder.of ℤ) eRel w v x y).Finite := by
  rcases eRel_fib_hub_or_finite w x with h1 | h1
  · rcases hy.eq_or_lt with h | h
    · subst h
      refine Or.inr (Set.Finite.subset (Set.finite_singleton v) ?_)
      intro u hu
      have : eRel v (-0) u := hu.2
      rw [neg_zero] at this
      exact (eRel_zero.mp this).symm
    · exact Or.inl ⟨h1, (eRel_neg (by omega)).mpr trivial⟩
  · exact Or.inr (h1.subset Set.inter_subset_left)

/-- *Saturation*: a directed family of fibres and segments either has a finite member, or has
the hub in every member. -/
theorem eRel_saturation : TaskFrame.Saturation (D := TemporalOrder.of ℤ) eRel := by
  intro S hdir hmem
  obtain ⟨_, hd⟩ := hdir
  have hne : ∀ s ∈ S, s.Nonempty := fun s hs => (hmem s hs).2
  by_cases hfin : ∃ s ∈ S, s.Finite
  · obtain ⟨s₀, h₀, hf⟩ := hfin
    exact sInter_nonempty_of_directed_of_finite_mem hd hne h₀ hf
  · refine ⟨none, fun s hs => ?_⟩
    rcases (hmem s hs).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, hy, rfl⟩
    · exact (eRel_fib_hub_or_finite w x).resolve_right fun h => hfin ⟨_, hs, h⟩
    · exact (eRel_seg_hub_or_finite w v x y hy).resolve_right fun h => hfin ⟨_, hs, h⟩

/-- The limit-closure frame over `ℤ`, with every `FrameOver` field discharged. Reducible, so
that `WorldState` reduces to `EW` and `Duration` to `ℤ`. -/
@[reducible] def eFrameOver : FrameOver (TemporalOrder.of ℤ) where
  WorldState := EW
  PosRel w x u := eRel w x u
  comp := TaskFrame.compositional_reflect_of_reflective eRel_reflection eRel_comp
  serial := TaskFrame.serial_reflect_of_reflective eRel_reflection eRel_serial
  limit := TaskFrame.limit_reflect_of_reflective eRel_reflection eRel_limit
  saturation := TaskFrame.saturation_reflect_of_reflective eRel_reflection eRel_saturation

/-- The limit-closure frame, as a `TaskFrame`. -/
@[reducible] def EF : TaskFrame := eFrameOver.toTaskFrame

/-- The task relation of `EF` is `eRel`. -/
theorem ef_taskRel_iff (w : EW) (d : ℤ) (u : EW) : EF.TaskRel w d u ↔ eRel w d u :=
  TaskFrame.reflect_restrict_iff (R := eRel) eRel_reflection

/-! ### Walks and world histories -/

/-- The state function of a world history of `EF` is a bi-infinite `eR`-walk. -/
theorem isWalk_state (τ : WorldHistory EF) : IsWalk eR τ.state := by
  intro n
  have h := (ef_taskRel_iff _ _ _).mp (τ.respects_task n (n + 1))
  have e : (n + 1 - n : ℤ) = 1 := by omega
  change eRel (τ.state n) (n + 1 - n) (τ.state (n + 1)) at h
  rw [e] at h
  exact (eRel_pos one_pos).mp h

/-- Along a walk, `eR` relates any earlier point to any later one, by transitivity. -/
theorem walk_lt {f : ℤ → EW} (hf : IsWalk eR f) {s t : ℤ} (h : s < t) : eR (f s) (f t) := by
  have key : ∀ k : ℕ, eR (f s) (f (s + 1 + k)) := by
    intro k
    induction k with
    | zero => simpa using hf s
    | succ k ih =>
      have := hf (s + 1 + k)
      rw [show s + 1 + (k : ℤ) + 1 = s + 1 + ((k + 1 : ℕ) : ℤ) by push_cast; ring] at this
      exact eR_trans ih this
  have := key (t - s - 1).toNat
  rwa [show s + 1 + ((t - s - 1).toNat : ℤ) = t by omega] at this

/-- Every bi-infinite `eR`-walk is the state function of a world history of `EF`. -/
def histOfWalk (f : ℤ → EW) (hf : IsWalk eR f) : WorldHistory EF :=
  WorldHistory.ofTotal EF f <| by
    intro s t
    refine (ef_taskRel_iff _ _ _).mpr ?_
    change eRel (f s) (t - s) (f t)
    rcases lt_trichotomy s t with h | h | h
    · exact (eRel_pos (sub_pos.mpr h)).mpr (walk_lt hf h)
    · subst h; rw [sub_self]; exact eRel_zero.mpr rfl
    · exact (eRel_neg (sub_neg.mpr h)).mpr (walk_lt hf h)

end FormalSystem.Metalogic.Independence
