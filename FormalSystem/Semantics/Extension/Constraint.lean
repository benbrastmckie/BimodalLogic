/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.FrameAxioms
import Mathlib.Tactic.Abel

/-!
# `lem:constraint`: the constraint family is directed and nonempty

This module proves the Constraint Lemma in its **restructured** form: the constraints a partial
history imposes on a new duration form a *directed* family of *nonempty* sets. That is the whole
of the lemma. The admissibility characterization that the lemma's earlier merged statement
carried has been split out by the paper into `lem:admissible`, warranted by `lem:fibers` (a
RETIRED paper anchor — `\label{lem:fibers}` was later removed and the citation now resolves
against the record's DANGLING entry), and is
deliberately **not** folded back in here.

## Paper Specification Reference

Anchors are `\label` keys into `specs/paper-definitions-of-record.md`, which — not the paper
source — is the citation source of record.

- `lem:constraint` (verbatim): "For any partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the constraints imposed on
  $z$ form a directed family of nonempty sets."
- `def:constraints` (verbatim): "For a partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the \textit{constraints
  imposed on $z$} are the segments $[\tau(t), \tau(s)]_{z-t}^{s-z}$ for times $t,s \in X$ where
  $t < z < s$, and the fibers $\Fib(\tau(t), z - t)$ for $t \in X$ otherwise."
- `def:directed` (verbatim): "A nonempty family of sets $\mathcal{S}$ is \textit{directed} just in
  case $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in
  \mathcal{S}$."
- *Seriality* (`def:frame#Seriality`, verbatim): "$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for
  some $u, v \in W$."
- *Compositionality* (`def:frame#Compositionality`, verbatim): "$w \Rightarrow_{x + y} v$ if and
  only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$."

## Which axioms this consumes

`PartialHistory.constraint`'s proof consumes exactly three things, and the reader can check the
§7-style threading for each:

1. **`Serial`** (`hSer`) — nonemptiness of every *fiber* member. At a domain time `t ≤ z` this is
   the successor half of *Seriality* at `z - t ≥ 0`; at `t ≥ z` it is the predecessor half at
   `t - z ≥ 0`, converted by the converse convention.
2. **`Interpolates`** (`hInt`) — nonemptiness of every *segment* member. This is the
   left-to-right half of biconditional *Compositionality*: the history's own task-respect gives
   `τ(t) ⇒_{s-t} τ(s)`, and interpolating at `z` splits `s - t = (z - t) + (s - z)` into a point
   of `[τ(t), τ(s)]_{z-t}^{s-z}`.
3. **`TaskFrame.forward_comp`** — *directedness*, via the two fiber-monotonicity lemmas below.
   This is the right-to-left (composition) half of the same biconditional axiom, so
   *Compositionality* is consumed in **both** directions by this one lemma.

The `z ∉ dom τ` proviso of `def:constraints` (the paper's `z ∈ D \ X`) is **not** needed for this
lemma and is therefore not assumed: when `z` does lie in the domain, the fiber `Fib(τ(z), 0)` is
itself a constraint and is contained in every other constraint, so directedness holds a fortiori.
That is the `fib_zero_subset_of_mem_Constraints` branch below.

## Main Results

- `PartialHistory.constraint` — `lem:constraint`: the constraint family is directed, and each of
  its members is nonempty

## Supporting Results

- `PartialHistory.seg_eq_inter_fib` — a constraint segment is the intersection of its two fiber
  conditions, with `def:task-relation`'s `-y` offset normalized to `z - s`
- `PartialHistory.fib_subset_fib_of_le_of_le` / `fib_subset_fib_of_le_of_le'` — fiber
  monotonicity below and above `z`: the constraint imposed by a domain time *nearer* `z` is the
  tighter one
- `PartialHistory.fib_zero_subset` / `fib_zero_subset_of_mem_Constraints` — when `z` is itself a
  domain time, its own fiber is the tightest constraint of all
- `PartialHistory.seg_subset_seg` — segment monotonicity in both endpoints
- `PartialHistory.nonempty_fib_of_serial` / `nonempty_seg_of_interpolates` — the two
  member-nonemptiness cases
- `PartialHistory.nonempty_Constraints` — the family itself is nonempty (part of `def:directed`)
- `PartialHistory.exists_mem_subset_inter` — the directedness step proper

## Implementation Notes

- **No new definition is introduced.** Everything is stated with `TaskFrame.Fib`, `TaskFrame.Seg`,
  `TaskFrame.DirectedFamily`, and `PartialHistory.Constraints` exactly as already transcribed.
- **Fibers and segments stay two separate classes.** The case analysis below is driven by
  `Constraints`' own two clauses, never by a merged class.
- **The `def:constraints` "otherwise" reading is consumed, not re-decided.** A fiber member's
  `¬ IsPaired τ z t` hypothesis is what rules out the mixed fiber/segment configurations: if a
  segment `[τ(t₁), τ(s₁)]` exists then every domain time other than `z` itself is paired, so the
  only fiber that can coexist with a segment is `Fib(τ(z), 0)`.
-/

namespace FormalSystem.Semantics

namespace PartialHistory

open TaskFrame

variable {F : TaskFrame}

/-!
### Rewriting a constraint segment as a pair of fiber conditions
-/

/--
A constraint segment is the intersection of the two fiber conditions at its endpoints.

`def:task-relation`'s *Segment* clause is `[w, v]_x^y = Fib(w, x) ∩ Fib(v, -y)`; for the
constraint segment `[τ(t), τ(s)]_{z-t}^{s-z}` the second offset `-(s - z)` normalizes to `z - s`,
which is the same shape as the fiber constraint `Fib(τ(s), z - s)` that the time `s` imposes.
This normalization is what lets the monotonicity lemmas below apply uniformly to fibers and to
segment endpoints.
-/
theorem seg_eq_inter_fib (τ : PartialHistory F) {z t s : F.Duration}
    (ht : τ.domain t) (hs : τ.domain s) :
    Seg F.TaskRel (τ.states t ht) (τ.states s hs) (z - t) (s - z)
      = Fib F.TaskRel (τ.states t ht) (z - t) ∩ Fib F.TaskRel (τ.states s hs) (z - s) := by
  simp only [TaskFrame.Seg, neg_sub]

/-!
### Fiber monotonicity: constraints tighten as the domain time approaches `z`
-/

/--
Below `z`, a later domain time imposes a tighter constraint: for `a ≤ b ≤ z` in the domain,
`Fib(τ(b), z - b) ⊆ Fib(τ(a), z - a)`.

This is *Compositionality*'s composition half (`TaskFrame.forward_comp`) applied to the history's
own task-respect step `τ(a) ⇒_{b-a} τ(b)`, with both durations `b - a` and `z - b` nonnegative so
that the axiom's positive-cone proviso is met.
-/
theorem fib_subset_fib_of_le_of_le {τ : PartialHistory F} {z a b : F.Duration}
    (ha : τ.domain a) (hb : τ.domain b) (hab : a ≤ b) (hbz : b ≤ z) :
    Fib F.TaskRel (τ.states b hb) (z - b) ⊆ Fib F.TaskRel (τ.states a ha) (z - a) := by
  intro u hu
  have hcomp := F.forward_comp (τ.states a ha) (τ.states b hb) u (b - a) (z - b)
    (sub_nonneg.mpr hab) (sub_nonneg.mpr hbz) (τ.respects_task a b ha hb)
    (TaskFrame.mem_Fib.mp hu)
  have heq : b - a + (z - b) = z - a := by abel
  rw [heq] at hcomp
  exact TaskFrame.mem_Fib.mpr hcomp

/--
Above `z`, an earlier domain time imposes a tighter constraint: for `z ≤ b ≤ a` in the domain,
`Fib(τ(b), z - b) ⊆ Fib(τ(a), z - a)`.

The mirror image of `fib_subset_fib_of_le_of_le`. Both fiber durations are now nonpositive, so
the composition is performed on the reflected pair — `u ⇒_{b-z} τ(b)` and `τ(b) ⇒_{a-b} τ(a)` —
and the converse convention (`FrameOver.converse`) carries the result back.
-/
theorem fib_subset_fib_of_le_of_le' {τ : PartialHistory F} {z a b : F.Duration}
    (ha : τ.domain a) (hb : τ.domain b) (hba : b ≤ a) (hzb : z ≤ b) :
    Fib F.TaskRel (τ.states b hb) (z - b) ⊆ Fib F.TaskRel (τ.states a ha) (z - a) := by
  intro u hu
  have hu' : F.TaskRel u (b - z) (τ.states b hb) := by
    have h := (F.converse (τ.states b hb) (z - b) u).mp (TaskFrame.mem_Fib.mp hu)
    rwa [neg_sub] at h
  have hcomp := F.forward_comp u (τ.states b hb) (τ.states a ha) (b - z) (a - b)
    (sub_nonneg.mpr hzb) (sub_nonneg.mpr hba) hu' (τ.respects_task b a hb ha)
  have heq : b - z + (a - b) = a - z := by abel
  rw [heq] at hcomp
  have h := (F.converse u (a - z) (τ.states a ha)).mp hcomp
  rw [neg_sub] at h
  exact TaskFrame.mem_Fib.mpr h

/--
When `z` is itself a domain time, its own zero-duration fiber is contained in the constraint
imposed by every other domain time. Immediate from the two monotonicity lemmas, splitting on
whether `t` lies below or above `z`.
-/
theorem fib_zero_subset {τ : PartialHistory F} {z t : F.Duration}
    (hz : τ.domain z) (ht : τ.domain t) :
    Fib F.TaskRel (τ.states z hz) (z - z) ⊆ Fib F.TaskRel (τ.states t ht) (z - t) := by
  rcases le_total t z with h | h
  · exact fib_subset_fib_of_le_of_le ht hz h le_rfl
  · exact fib_subset_fib_of_le_of_le' ht hz h le_rfl

/--
Segment monotonicity: shrinking a constraint segment's endpoints towards `z` (from `t` up to `t'`
below `z`, and from `s` down to `s'` above `z`) tightens the constraint.
-/
theorem seg_subset_seg {τ : PartialHistory F} {z t s t' s' : F.Duration}
    (ht : τ.domain t) (hs : τ.domain s) (ht' : τ.domain t') (hs' : τ.domain s')
    (htt' : t ≤ t') (ht'z : t' ≤ z) (hzs' : z ≤ s') (hs's : s' ≤ s) :
    Seg F.TaskRel (τ.states t' ht') (τ.states s' hs') (z - t') (s' - z)
      ⊆ Seg F.TaskRel (τ.states t ht) (τ.states s hs) (z - t) (s - z) := by
  rw [seg_eq_inter_fib, seg_eq_inter_fib]
  exact Set.inter_subset_inter (fib_subset_fib_of_le_of_le ht ht' htt' ht'z)
    (fib_subset_fib_of_le_of_le' hs hs' hs's hzs')

/--
When `z` is a domain time, its zero-duration fiber is contained in *every* constraint on `z` —
fibers by `fib_zero_subset`, segments because a segment is the intersection of its two endpoint
fiber conditions (`seg_eq_inter_fib`).
-/
theorem fib_zero_subset_of_mem_Constraints {τ : PartialHistory F} {z : F.Duration} (hz : τ.domain z)
    {c : Set F.WorldState} (hc : c ∈ Constraints τ z) :
    Fib F.TaskRel (τ.states z hz) (z - z) ⊆ c := by
  rcases hc with ⟨t, s, ht, hs, _, _, rfl⟩ | ⟨t, ht, _, rfl⟩
  · rw [seg_eq_inter_fib]
    exact Set.subset_inter (fib_zero_subset hz ht) (fib_zero_subset hz hs)
  · exact fib_zero_subset hz ht

/-!
### Nonemptiness of the members
-/

/--
Every fiber constraint is nonempty, by *Seriality*.

For a domain time `t ≤ z` this is the successor half of *Seriality* at the nonnegative duration
`z - t`; for `t ≥ z` it is the predecessor half at `t - z`, turned around by the converse
convention. No other axiom is used.
-/
theorem nonempty_fib_of_serial {τ : PartialHistory F} {z t : F.Duration}
    (ht : τ.domain t) : (Fib F.TaskRel (τ.states t ht) (z - t)).Nonempty := by
  rcases le_total t z with h | h
  · obtain ⟨u, hu⟩ := (F.serial (τ.states t ht) (z - t) (sub_nonneg.mpr h)).1
    exact ⟨u, TaskFrame.mem_Fib.mpr hu⟩
  · obtain ⟨v, hv⟩ := (F.serial (τ.states t ht) (t - z) (sub_nonneg.mpr h)).2
    refine ⟨v, TaskFrame.mem_Fib.mpr ?_⟩
    have h' := (F.converse v (t - z) (τ.states t ht)).mp hv
    rwa [neg_sub] at h'

/--
Every segment constraint is nonempty, by the interpolation half of *Compositionality*.

The history's own task-respect gives `τ(t) ⇒_{s-t} τ(s)`, and `s - t = (z - t) + (s - z)` with
both summands positive because `t < z < s`. Interpolating at that split produces a state `u` with
`τ(t) ⇒_{z-t} u` and `u ⇒_{s-z} τ(s)`; the converse convention rewrites the second conjunct as
`τ(s) ⇒_{-(s-z)} u`, which is exactly membership in `[τ(t), τ(s)]_{z-t}^{s-z}`.
-/
theorem nonempty_seg_of_interpolates {τ : PartialHistory F} {z t s : F.Duration} (ht : τ.domain t) (hs : τ.domain s) (htz : t < z) (hzs : z < s) :
    (Seg F.TaskRel (τ.states t ht) (τ.states s hs) (z - t) (s - z)).Nonempty := by
  have hrel : F.TaskRel (τ.states t ht) ((z - t) + (s - z)) (τ.states s hs) := by
    have h := τ.respects_task t s ht hs
    have heq : z - t + (s - z) = s - t := by abel
    rw [heq]
    exact h
  obtain ⟨u, hu1, hu2⟩ := F.interpolates (τ.states t ht) (τ.states s hs) (z - t) (s - z)
    (le_of_lt (sub_pos.mpr htz)) (le_of_lt (sub_pos.mpr hzs)) hrel
  exact ⟨u, hu1, (F.converse u (s - z) (τ.states s hs)).mp hu2⟩

/-- Every constraint on `z` is nonempty: the two cases of `def:constraints`, discharged by
*Seriality* and by the interpolation half of *Compositionality* respectively. -/
theorem nonempty_of_mem_Constraints {τ : PartialHistory F} {z : F.Duration} {c : Set F.WorldState}
    (hc : c ∈ Constraints τ z) : c.Nonempty := by
  rcases hc with ⟨t, s, ht, hs, htz, hzs, rfl⟩ | ⟨t, ht, _, rfl⟩
  · exact nonempty_seg_of_interpolates ht hs htz hzs
  · exact nonempty_fib_of_serial ht

/-!
### Directedness
-/

/--
The constraint family is itself nonempty — the first conjunct of `def:directed`.

The partial history's domain is nonempty by its `nonempty_domain` field. Any domain time `t`
contributes: if `t` is not paired about `z` it contributes its own fiber, and if it is paired the
witnessing pair straddles `z` and contributes a segment.
-/
theorem nonempty_Constraints (τ : PartialHistory F) (z : F.Duration) : (Constraints τ z).Nonempty := by
  obtain ⟨t, ht⟩ := τ.nonempty_domain
  by_cases hp : IsPaired τ z t
  · rcases hp with ⟨htz, s, hs, hzs⟩ | ⟨hzt, s, hs, hsz⟩
    · exact ⟨_, mem_Constraints.mpr (Or.inl ⟨t, s, ht, hs, htz, hzs, rfl⟩)⟩
    · exact ⟨_, mem_Constraints.mpr (Or.inl ⟨s, t, hs, ht, hsz, hzt, rfl⟩)⟩
  · exact ⟨_, mem_Constraints.mpr (Or.inr ⟨t, ht, hp, rfl⟩)⟩

/--
The directedness step of `def:directed`: any two constraints on `z` are jointly refined by a third
constraint on `z`.

The proof is a four-way case analysis on `def:constraints`' two clauses, and the `¬ IsPaired`
side condition on fiber members is what makes two of the four cases collapse:

- **segment, segment**: the refining member is the segment cut at `max t₁ t₂` and `min s₁ s₂`,
  which still straddles `z`; `seg_subset_seg` gives both containments.
- **segment, fiber** (and its mirror): the segment's own endpoints witness that any domain time
  strictly below or strictly above `z` is paired, so the fiber's time can only be `z` itself —
  and then the fiber `Fib(τ(z), 0)` already refines the segment.
- **fiber, fiber**: if either time is `z` that fiber refines the other; otherwise both lie
  strictly on the same side of `z` (a strict straddle would pair them), and the refining member is
  the fiber at the time nearer `z` — `max` below, `min` above.
-/
theorem exists_mem_subset_inter {τ : PartialHistory F} {z : F.Duration} {c₁ c₂ : Set F.WorldState}
    (hc₁ : c₁ ∈ Constraints τ z) (hc₂ : c₂ ∈ Constraints τ z) :
    ∃ c ∈ Constraints τ z, c ⊆ c₁ ∩ c₂ := by
  rcases hc₁ with ⟨t₁, s₁, ht₁, hs₁, ht₁z, hzs₁, rfl⟩ | ⟨t₁, ht₁, hnp₁, rfl⟩
  · rcases hc₂ with ⟨t₂, s₂, ht₂, hs₂, ht₂z, hzs₂, rfl⟩ | ⟨t₂, ht₂, hnp₂, rfl⟩
    · -- segment, segment: cut at `max t₁ t₂` and `min s₁ s₂`
      have hmt : τ.domain (max t₁ t₂) := by
        rcases max_choice t₁ t₂ with h | h <;> rw [h] <;> assumption
      have hms : τ.domain (min s₁ s₂) := by
        rcases min_choice s₁ s₂ with h | h <;> rw [h] <;> assumption
      have hmtz : max t₁ t₂ < z := max_lt ht₁z ht₂z
      have hzms : z < min s₁ s₂ := lt_min hzs₁ hzs₂
      refine ⟨_, mem_Constraints.mpr
        (Or.inl ⟨max t₁ t₂, min s₁ s₂, hmt, hms, hmtz, hzms, rfl⟩), ?_⟩
      exact Set.subset_inter
        (seg_subset_seg ht₁ hs₁ hmt hms (le_max_left _ _) (le_of_lt hmtz) (le_of_lt hzms)
          (min_le_left _ _))
        (seg_subset_seg ht₂ hs₂ hmt hms (le_max_right _ _) (le_of_lt hmtz) (le_of_lt hzms)
          (min_le_right _ _))
    · -- segment, fiber: the segment's endpoints force the fiber's time to be `z` itself
      rcases lt_trichotomy t₂ z with h | rfl | h
      · exact absurd (Or.inl ⟨h, s₁, hs₁, hzs₁⟩) hnp₂
      · refine ⟨_, mem_Constraints.mpr (Or.inr ⟨t₂, ht₂, hnp₂, rfl⟩), ?_⟩
        refine Set.subset_inter ?_ (subset_refl _)
        exact fib_zero_subset_of_mem_Constraints ht₂
          (mem_Constraints.mpr (Or.inl ⟨t₁, s₁, ht₁, hs₁, ht₁z, hzs₁, rfl⟩))
      · exact absurd (Or.inr ⟨h, t₁, ht₁, ht₁z⟩) hnp₂
  · rcases hc₂ with ⟨t₂, s₂, ht₂, hs₂, ht₂z, hzs₂, rfl⟩ | ⟨t₂, ht₂, hnp₂, rfl⟩
    · -- fiber, segment: mirror of the previous case
      rcases lt_trichotomy t₁ z with h | rfl | h
      · exact absurd (Or.inl ⟨h, s₂, hs₂, hzs₂⟩) hnp₁
      · refine ⟨_, mem_Constraints.mpr (Or.inr ⟨t₁, ht₁, hnp₁, rfl⟩), ?_⟩
        refine Set.subset_inter (subset_refl _) ?_
        exact fib_zero_subset_of_mem_Constraints ht₁
          (mem_Constraints.mpr (Or.inl ⟨t₂, s₂, ht₂, hs₂, ht₂z, hzs₂, rfl⟩))
      · exact absurd (Or.inr ⟨h, t₂, ht₂, ht₂z⟩) hnp₁
    · -- fiber, fiber
      by_cases hz₁ : t₁ = z
      · subst hz₁
        refine ⟨_, mem_Constraints.mpr (Or.inr ⟨t₁, ht₁, hnp₁, rfl⟩), ?_⟩
        refine Set.subset_inter (subset_refl _) ?_
        exact fib_zero_subset_of_mem_Constraints ht₁
          (mem_Constraints.mpr (Or.inr ⟨t₂, ht₂, hnp₂, rfl⟩))
      · by_cases hz₂ : t₂ = z
        · subst hz₂
          refine ⟨_, mem_Constraints.mpr (Or.inr ⟨t₂, ht₂, hnp₂, rfl⟩), ?_⟩
          refine Set.subset_inter ?_ (subset_refl _)
          exact fib_zero_subset_of_mem_Constraints ht₂
            (mem_Constraints.mpr (Or.inr ⟨t₁, ht₁, hnp₁, rfl⟩))
        · rcases lt_or_gt_of_ne hz₁ with h₁ | h₁ <;> rcases lt_or_gt_of_ne hz₂ with h₂ | h₂
          · -- both strictly below `z`: refine at `max t₁ t₂`
            have hmt : τ.domain (max t₁ t₂) := by
              rcases max_choice t₁ t₂ with h | h <;> rw [h] <;> assumption
            have hnp : ¬ IsPaired τ z (max t₁ t₂) := by
              rcases max_choice t₁ t₂ with h | h <;> rw [h] <;> assumption
            have hmtz : max t₁ t₂ ≤ z := le_of_lt (max_lt h₁ h₂)
            refine ⟨_, mem_Constraints.mpr (Or.inr ⟨max t₁ t₂, hmt, hnp, rfl⟩), ?_⟩
            exact Set.subset_inter
              (fib_subset_fib_of_le_of_le ht₁ hmt (le_max_left _ _) hmtz)
              (fib_subset_fib_of_le_of_le ht₂ hmt (le_max_right _ _) hmtz)
          · -- `t₁ < z < t₂`: the two times straddle `z`, so `t₁` is paired
            exact absurd (Or.inl ⟨h₁, t₂, ht₂, h₂⟩) hnp₁
          · -- `t₂ < z < t₁`: the two times straddle `z`, so `t₁` is paired
            exact absurd (Or.inr ⟨h₁, t₂, ht₂, h₂⟩) hnp₁
          · -- both strictly above `z`: refine at `min t₁ t₂`
            have hmt : τ.domain (min t₁ t₂) := by
              rcases min_choice t₁ t₂ with h | h <;> rw [h] <;> assumption
            have hnp : ¬ IsPaired τ z (min t₁ t₂) := by
              rcases min_choice t₁ t₂ with h | h <;> rw [h] <;> assumption
            have hzmt : z ≤ min t₁ t₂ := le_of_lt (lt_min h₁ h₂)
            refine ⟨_, mem_Constraints.mpr (Or.inr ⟨min t₁ t₂, hmt, hnp, rfl⟩), ?_⟩
            exact Set.subset_inter
              (fib_subset_fib_of_le_of_le' ht₁ hmt (min_le_left _ _) hzmt)
              (fib_subset_fib_of_le_of_le' ht₂ hmt (min_le_right _ _) hzmt)

/--
`lem:constraint`: the constraints imposed on a new duration form a directed family of nonempty
sets.

Recorded source (`lem:constraint`, verbatim): "For any partial history $\tau : X \to W$ over a
frame $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the constraints
imposed on $z$ form a directed family of nonempty sets."

**This is the restructured statement.** The admissibility characterization that the lemma's
earlier merged form carried has been split out into `lem:admissible` (warranted by `lem:fibers`,
a RETIRED paper anchor resolving against the record's DANGLING entry)
and must not be folded back in here; directedness and member-nonemptiness are the whole content.

**Axioms consumed, for the §7-style threading check.** Exactly three, and the reader can verify
each by deleting the corresponding hypothesis and observing the failure:

- `hSer` (*Seriality*) — nonemptiness of the fiber members, via `nonempty_fib_of_serial`;
- `hInt` (the interpolation half of *Compositionality*) — nonemptiness of the segment members,
  via `nonempty_seg_of_interpolates`;
- `TaskFrame.forward_comp` (the composition half of *Compositionality*) — directedness, via the
  fiber-monotonicity lemmas `fib_subset_fib_of_le_of_le` and `fib_subset_fib_of_le_of_le'`.

*Compositionality* is therefore consumed in **both** of its directions here. *Saturation* is
**not** consumed: it is applied only at `lem:step`, the sole application site the paper names, and
this lemma is precisely what supplies that application its directed-family-of-nonempty-sets
hypothesis. *Limit* is not consumed either.

The paper's `z ∈ D \ X` proviso is not assumed: see this module's docstring for why the lemma
holds a fortiori when `z` is itself a domain time.
-/
theorem constraint (τ : PartialHistory F) (z : F.Duration) :
    DirectedFamily (Constraints τ z) ∧ ∀ c ∈ Constraints τ z, c.Nonempty :=
  ⟨⟨nonempty_Constraints τ z, fun _ h₁ _ h₂ => exists_mem_subset_inter h₁ h₂⟩,
    fun _ hc => nonempty_of_mem_Constraints hc⟩

end PartialHistory

end FormalSystem.Semantics
