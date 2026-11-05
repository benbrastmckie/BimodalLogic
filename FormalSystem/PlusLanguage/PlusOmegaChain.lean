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

end FormalSystem.PlusLanguage
