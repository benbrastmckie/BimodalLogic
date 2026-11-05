/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.PlusPasting
import FormalSystem.PlusLanguage.PlusIntTransfer

/-!
# The ω-limit of splices, and the ω-chain it drives

A **marker sequence** is a strictly increasing `ℕ`-indexed sequence `c : ℕ → F.Duration`. An
`ℕ`-indexed family of world histories that agrees with its predecessor *up to* its marker is an
**ω-chain of splices**, and the content of this module is that such a family has a **limit**: one
world history agreeing with stage `k` everywhere at or below `c k`.

The principle is **class-generic** — it holds at an arbitrary regular task frame — but only under
an explicit hypothesis:

```
hcof : ∀ x : F.Duration, ∃ k, x ≤ c k
```

the markers are **cofinal** in the duration order. That binder is the single place at which the
`ℤ`-dependence of every downstream consumer is isolated and auditable, and it is not a
convenience. A `TemporalOrder` is an arbitrary nontrivial totally ordered abelian group, so over
a *dense* order a strictly increasing sequence may converge and leave an unreached tail: the
limit's states past that tail would be determined by no stage. `intOrder_omega_cofinal` is the
only discharge of the hypothesis available today, and it is available over `ℤ` alone. Every
consumer of `omega_chain` is thereby `.ZTime`-scoped, which is why
`PlusLCSchema.lean`'s `lcN_plusValidZTime` stops where it does.

## The argument

1. **Monotonicity** (`marker_mono`). A strictly increasing `ℕ`-indexed sequence is monotone.
2. **Transitive agreement** (`marker_agree_add`). Stage `k + d` agrees with stage `k` at every
   time at or below `c k`, by induction on `d` through monotonicity.
3. **The limit** (`omega_limit`). Cofinality picks, for each time `x`, *some* stage whose marker
   is at or above `x`; step 2 makes the choice irrelevant, so `fun x => (τ (idx x)).state x` is
   well defined up to agreement. It respects the task relation because any two times are below
   one common marker, where the stage's own `respects_task` applies — `WorldHistory.ofTotal`
   asks for exactly that and nothing about adjacency.
4. **The chain** (`omega_chain`). Iterating a one-step splice (`stg_step`, which pastes a
   continuation onto the current stage at its marker) produces such a family, and its limit
   carries every stage's recurrence at once.

## Main Definitions

- `Stg` — a stage of the chain: a world history through a fixed state at a fixed time, with a
  marker at or after that time carrying the `i`-th member of the recurrence family

## Main Results

- `marker_mono` — a strictly increasing `ℕ`-indexed sequence in a preorder is monotone
- `marker_agree_add` — agreement up to `c k` propagates to every later stage
- `omega_limit` — the ω-limit-of-splices principle, class-generic under cofinality
- `int_marker_add_le` — a strictly increasing `ℕ`-indexed sequence in `ℤ` dominates its index
- `intOrder_omega_cofinal` — the `ℤ` discharge of the cofinality hypothesis
- `stg_step` — one splice: a stage at `i` yields a stage at `i + 1` with a strictly larger
  marker, agreeing with its predecessor up to the old marker
- `omega_chain` — iterate the splice and take the ω-limit: one world history realising the whole
  recurrence family

## Relation to `PlusLimitClosure.lean`

`PlusLimitClosure.lean`'s `blc` is the limit-closure formula at a *single* recurring state
predicate, valid at `.Base` by Zorn plus the Extension Theorem. This module's `omega_chain` runs
a *sequence* of recurrence predicates by iterated pasting, and buys that extra index arity at the
cost of the cofinality hypothesis. Neither route subsumes the other: the Zorn route is
class-generic and single-index, this one is multi-index and `ℤ`-scoped.

## Axioms

`omega_limit` chooses an index per time and `omega_chain` iterates by `Nat.rec` over
`Exists.choose`, so both carry `Classical.choice` — the tree's standard `pcq` profile.

## References

* [M. Reynolds, *An Axiomatization of PCTL\**][reynolds2003] — the infinite limit-closure schema
  whose transposition `PlusLCSchema.lean` consumes this module to validate
* `PlusLanguage/PlusPasting.lean` — `paste`, `paste_agreeFrom`, `paste_agreeUpTo`
* `PlusLanguage/PlusLimitClosure.lean` — the single-index limit-closure route at `.Base`

## Tags

plus-language · stability-modal · limit-closure · omega-chain · ztime
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics
open PartialHistory
open PlusTruth

variable {F : TaskFrame}

/-! ## Marker sequences -/

/--
**A strictly increasing `ℕ`-indexed sequence is monotone.**

Stated over an arbitrary preorder rather than at `F.Duration`: the only content is
`strictMono_nat_of_lt_succ`, and the chain argument reads it at both `F.Duration` and `ℕ`.
-/
theorem marker_mono {α : Type*} [Preorder α] {c : ℕ → α} (hc : ∀ k, c k < c (k + 1)) :
    Monotone c :=
  (strictMono_nat_of_lt_succ hc).monotone

/--
**Agreement up to a marker propagates along the whole tail of the chain.**

Each stage agrees with its predecessor at or below its predecessor's marker; monotonicity of the
markers lets that single step be iterated, so stage `k + d` agrees with stage `k` at every time
at or below `c k`.
-/
theorem marker_agree_add {τ : ℕ → WorldHistory F} {c : ℕ → F.Duration}
    (hc : ∀ k, c k < c (k + 1))
    (hag : ∀ k x, x ≤ c k → (τ (k + 1)).state x = (τ k).state x) (k d : ℕ) (x : F.Duration)
    (hx : x ≤ c k) : (τ (k + d)).state x = (τ k).state x := by
  induction d with
  | zero => rfl
  | succ d ih =>
    rw [← ih, ← add_assoc]
    exact hag (k + d) x (le_trans hx (marker_mono hc (Nat.le_add_right k d)))

/-! ## The ω-limit -/

/--
**ω-limit of splices.** A sequence of world histories, each agreeing with its predecessor up to a
strictly increasing marker whose markers are cofinal in the duration order, has a limit world
history agreeing with stage `k` up to marker `k`.

The cofinality hypothesis `hcof` is load-bearing and is the one binder that fixes the frame class
of every downstream consumer; see the module docstring. The construction itself is short because
`WorldHistory.ofTotal` asks only for `∀ s t, F.TaskRel (f s) (t - s) (f t)`, which a single
common marker discharges from that stage's own `respects_task`.
-/
theorem omega_limit [F.IsRegular] {τ : ℕ → WorldHistory F} {c : ℕ → F.Duration}
    (hc : ∀ k, c k < c (k + 1)) (hcof : ∀ x : F.Duration, ∃ k, x ≤ c k)
    (hag : ∀ k x, x ≤ c k → (τ (k + 1)).state x = (τ k).state x) :
    ∃ lim : WorldHistory F, ∀ k x, x ≤ c k → lim.state x = (τ k).state x := by
  classical
  obtain ⟨idx, hidx⟩ : ∃ idx : F.Duration → ℕ, ∀ x, x ≤ c (idx x) :=
    ⟨fun x => (hcof x).choose, fun x => (hcof x).choose_spec⟩
  have key : ∀ k x, x ≤ c k → (τ (idx x)).state x = (τ k).state x := by
    intro k x hx
    rcases le_total (idx x) k with h | h
    · obtain ⟨d, rfl⟩ := Nat.exists_eq_add_of_le h
      exact (marker_agree_add hc hag (idx x) d x (hidx x)).symm
    · obtain ⟨d, hd⟩ := Nat.exists_eq_add_of_le h
      rw [hd]
      exact marker_agree_add hc hag k d x hx
  have hrel : ∀ s t : F.Duration,
      F.TaskRel ((τ (idx s)).state s) (t - s) ((τ (idx t)).state t) := by
    intro s t
    have hs : s ≤ c (max (idx s) (idx t)) :=
      le_trans (hidx s) (marker_mono hc (le_max_left _ _))
    have ht : t ≤ c (max (idx s) (idx t)) :=
      le_trans (hidx t) (marker_mono hc (le_max_right _ _))
    rw [key _ s hs, key _ t ht]
    exact (τ (max (idx s) (idx t))).respects_task s t
  exact ⟨WorldHistory.ofTotal F (fun x => (τ (idx x)).state x) hrel, fun k x hx => key k x hx⟩

/-! ## The `ℤ` discharge of the cofinality hypothesis -/

/--
**A strictly increasing `ℕ`-indexed sequence in `ℤ` dominates its own index.**

The arithmetic step behind cofinality over `ℤ`: each successor advances the sequence by at least
one, so after `k` steps it has advanced by at least `k`. This is exactly what has no counterpart
over a dense order, where the increments may be summable.
-/
theorem int_marker_add_le {c : ℕ → ℤ} (hc : ∀ k, c k < c (k + 1)) (k : ℕ) : c 0 + k ≤ c k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have := hc k
    push_cast
    omega

/--
**A strictly increasing `ℕ`-indexed sequence in `ℤ` is cofinal.**

This is the only discharge of `omega_limit`/`omega_chain`'s cofinality hypothesis available
today, and it is **false over a dense temporal order**: a strictly increasing sequence in a dense
totally ordered abelian group may converge, leaving every term below some bound. Every consumer
of `omega_chain` that reaches validity through this lemma is therefore `.ZTime`-scoped and cannot
be lifted to `.Base` by any reshuffling of the ω-chain argument.
-/
theorem intOrder_omega_cofinal (c : ℕ → ℤ) (hc : ∀ k, c k < c (k + 1)) (x : ℤ) :
    ∃ k, x ≤ c k := by
  refine ⟨(x - c 0).toNat, ?_⟩
  have := int_marker_add_le hc (x - c 0).toNat
  omega

/-! ## The splice stage -/

/--
**A stage of the chain**: a world history through the state `w` at the time `t`, together with a
marker at or after `t` at whose state the `i`-th member of the recurrence family holds.

`A` is a predicate on a **time and a world state**, not a formula. That is the probe's own
binder bundle and it is what makes the splice sound: `stg_step` pastes a continuation onto the
current stage at its marker, which replaces the history strictly *before* the new marker, so only
a condition reading the time and the state there survives the paste. A formula-valued family
would need a state-locality side condition to say the same thing, and the instantiation this
module exists to serve (`PlusLCSchema.lean`'s `A k s v := ⟐α_k` at `v`, `s`) is state-local by
construction because `⟐` is.
-/
structure Stg (F : TaskFrame) (w : F.WorldState) (t : F.Duration)
    (A : ℕ → F.Duration → F.WorldState → Prop) (i : ℕ) where
  /-- The stage's world history. -/
  hist : WorldHistory F
  /-- The stage's marker. -/
  mark : F.Duration
  /-- The history passes through `w` at `t`. -/
  thru : hist.state t = w
  /-- The marker is at or after the time of evaluation. -/
  le : t ≤ mark
  /-- The `i`-th recurrence holds at the marker's state. -/
  hA : A i mark (hist.state mark)

/--
**One splice.** A stage at index `i` yields a stage at `i + 1` with a strictly larger marker,
agreeing with its predecessor everywhere at or below the old marker.

The construction is `PlusPasting.paste` and nothing else: the continuation `η` shares the
stage's state at the old marker, `paste_agreeUpTo` keeps the passage through `w` at `t`, and
`paste_agreeFrom` carries the new recurrence from `η` to the pasted history at the new marker.
-/
theorem stg_step [F.IsRegular] {w : F.WorldState} {t : F.Duration}
    {A : ℕ → F.Duration → F.WorldState → Prop}
    (H : ∀ (ρ : WorldHistory F), ρ.state t = w → ∀ k s, t ≤ s → A k s (ρ.state s) →
      ∃ (η : WorldHistory F) (s' : F.Duration), η.state s = ρ.state s ∧ s < s' ∧
        A (k + 1) s' (η.state s'))
    {i : ℕ} (x : Stg F w t A i) :
    ∃ y : Stg F w t A (i + 1), x.mark < y.mark ∧
      ∀ z, z ≤ x.mark → y.hist.state z = x.hist.state z := by
  obtain ⟨η, s', he, hlt, hA'⟩ := H x.hist x.thru i x.mark x.le x.hA
  have hsame : x.hist.state x.mark = η.state x.mark := he.symm
  have hup := paste_agreeUpTo x.hist η x.mark hsame
  have hfrom := paste_agreeFrom x.hist η x.mark hsame
  refine ⟨⟨paste x.hist η x.mark hsame, s', ?_, le_trans x.le hlt.le, ?_⟩, hlt, hup⟩
  · rw [hup t x.le]; exact x.thru
  · rw [hfrom s' hlt.le]; exact hA'

/-! ## The ω-chain -/

/--
**ω-chain principle.** If every `A k`-point on a world history through `σ`'s state at `t` can be
continued, by a splice, to a later `A (k + 1)`-point, then **one** world history through that
same state realises the whole sequence at a strictly increasing sequence of markers.

The cofinality hypothesis `hcof` is the single binder at which the `ℤ`-dependence of every
consumer is isolated; `intOrder_omega_cofinal` is its only available discharge today, so every
validity reached through this lemma lands at `.ZTime` and not at `.Base`.

`Nat.rec` over `Exists.choose` builds the chain, so this carries `Classical.choice` — the tree's
standard `pcq` profile.
-/
theorem omega_chain [F.IsRegular] (σ : WorldHistory F) (t : F.Duration)
    (A : ℕ → F.Duration → F.WorldState → Prop)
    (hcof : ∀ c : ℕ → F.Duration, (∀ k, c k < c (k + 1)) → ∀ x : F.Duration, ∃ k, x ≤ c k)
    (hstart : ∃ (ρ : WorldHistory F) (s : F.Duration),
      ρ.state t = σ.state t ∧ t ≤ s ∧ A 0 s (ρ.state s))
    (hstep : ∀ (ρ : WorldHistory F), ρ.state t = σ.state t → ∀ k s, t ≤ s → A k s (ρ.state s) →
      ∃ (η : WorldHistory F) (s' : F.Duration), η.state s = ρ.state s ∧ s < s' ∧
        A (k + 1) s' (η.state s')) :
    ∃ (ρ : WorldHistory F) (c : ℕ → F.Duration), ρ.state t = σ.state t ∧
      (∀ k, c k < c (k + 1)) ∧ (∀ k, t ≤ c k ∧ A k (c k) (ρ.state (c k))) := by
  classical
  obtain ⟨ρ₀, s₀, h0w, h0s, h0A⟩ := hstart
  let chain : (k : ℕ) → Stg F (σ.state t) t A k := fun k =>
    Nat.rec (motive := fun k => Stg F (σ.state t) t A k) ⟨ρ₀, s₀, h0w, h0s, h0A⟩
      (fun _ x => (stg_step hstep x).choose) k
  have hstg : ∀ k, (chain k).mark < (chain (k + 1)).mark ∧
      ∀ z, z ≤ (chain k).mark → (chain (k + 1)).hist.state z = (chain k).hist.state z :=
    fun k => (stg_step hstep (chain k)).choose_spec
  obtain ⟨lim, hlag⟩ := omega_limit (τ := fun k => (chain k).hist) (c := fun k => (chain k).mark)
    (fun k => (hstg k).1) (hcof _ fun k => (hstg k).1) (fun k x hx => (hstg k).2 x hx)
  refine ⟨lim, fun k => (chain k).mark, ?_, fun k => (hstg k).1, fun k => ⟨(chain k).le, ?_⟩⟩
  · rw [hlag 0 t (chain 0).le]; exact (chain 0).thru
  · rw [hlag k _ le_rfl]; exact (chain k).hA

end FormalSystem.PlusLanguage
