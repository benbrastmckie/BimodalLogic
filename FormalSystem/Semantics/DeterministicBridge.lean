/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Semantics.PlusLanguage.PlusDeterminism

/-!
# `lem:deterministic-singleton` as a biconditional — the (⇐) half via `thm:extension`

`FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` carries the (⇒) half of
`lem:deterministic-singleton`: on a deterministic frame, two possible worlds agreeing on their
world state at one time agree at every time (`states_eq_of_deterministic`). This module adds the
converse, and packages the two as one biconditional.

## Main Definitions

- `TaskFrame.SingletonClasses` — `⟨τ⟩_x = {τ}` for every possible world and every time, in the
  tree's **pointwise-on-states** form

## Main Results

- `singletonClasses_of_deterministic` — the (⇒) half, a one-line application of
  `states_eq_of_deterministic`; choice-free
- `deterministic_of_singletonClasses` — the (⇐) half, via `thm:extension`; a theorem of **ZFC**
- `deterministic_iff_singletonClasses` — the biconditional `lem:deterministic-singleton` now is

## Why the pointwise-on-states form on both sides

`lem:deterministic-singleton` reads `⟨τ⟩_x = {τ}`, an equation between *sets of histories*.
The tree states both halves pointwise on states instead — "every possible world sharing `τ`'s
state at `x` shares it at every time" — for two reasons, and the choice is deliberate rather
than a weakening:

1. `states_eq_of_deterministic` already concludes pointwise state agreement, and gets it for
   free from `respects_task` plus determinism at the (possibly negative) duration `s - t`.
   History *equality* would additionally route through `WorldHistory.ext_state`, which spends
   `propext` and function extensionality and which no consumer needs.
2. Pointwise agreement is *weaker as a conclusion* and therefore **stronger as a hypothesis**.
   Taking it on both sides makes the biconditional below strictly stronger than the
   history-equality form would be: the (⇐) direction assumes less, and the (⇒) direction
   concludes what every downstream consumer actually uses (`truth_congr_ext`, and its L⋆
   successor, convert pointwise state agreement into agreement on every formula).

## Choice dependence, recorded honestly

The two halves have **opposite** choice profiles, and this module is careful not to blur them.

- `singletonClasses_of_deterministic` is choice-free: it is `states_eq_of_deterministic`, whose
  `[propext]`-only pin is recorded in `PlusDeterminism.lean` and is **untouched by this module's
  existence**. Nothing here is added to that file; it gains no import of
  `Semantics/Extension/Extension.lean` and therefore no path to Zorn.
- `deterministic_of_singletonClasses` is a **theorem of ZFC**. It manufactures two separating
  possible worlds out of a two-point partial history by `thm:extension`, whose own footnote
  records that its proof appeals to Zorn's lemma. `#print axioms` on it reports
  `Classical.choice`, and the statement must never be advertised as choice-free.

That asymmetry is the general pattern for this appendix: "frame condition ⟹ validity" is the
safe direction, and "validity ⟹ frame condition" manufactures witnesses through
`thm:extension`.

## A step of the paper's proof that Lean does not need

The paper's argument for the (⇐) direction opens by deriving that `⇒_0` is the identity, from
*Limit* together with `lem:nullity`. In this tree that is the theorem
`FrameOver.nullity_identity` — `∀ w u, TaskRel w 0 u ↔ w = u`, derived once from the `serial` and
`limit` fields and available on every frame — so the paper's Step 1 is not transcribed here. The `x = 0` branch of
`deterministic_of_singletonClasses` closes by `F.nullity_identity` outright.

## References

* JPL paper `lem:deterministic-singleton` (the biconditional), `thm:extension` (and its Zorn
  footnote), `def:deterministic`, `lem:nullity`
* `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — the (⇒) half and its choice-free pin
* `FormalSystem/Semantics/Extension/Extension.lean` — `thm:extension`

## Tags

determinism · singleton-bridge · extension-theorem · lem:deterministic-singleton
-/

namespace FormalSystem.Semantics

open FormalSystem.PlusLanguage
open scoped Classical

variable {F : TaskFrame}

/--
`⟨τ⟩_x = {τ}` for every possible world and every time, in the tree's pointwise-on-states form:
any two possible worlds agreeing on their world state at one time agree at *every* time.

See this module's docstring for why the pointwise form is taken on both sides of
`deterministic_iff_singletonClasses` rather than the paper's history-equality form.
-/
def TaskFrame.SingletonClasses (F : TaskFrame) : Prop :=
  ∀ (τ σ : WorldHistory F) (x : F.Duration),
    τ.state x = σ.state x → ∀ y : F.Duration, τ.state y = σ.state y

/--
**(⇒) of `lem:deterministic-singleton`**, restated at the `SingletonClasses` predicate: a
deterministic frame has singleton stability classes.

One application of `states_eq_of_deterministic`; choice-free, and it adds nothing to that
result — the value of the restatement is that it puts both halves in the same shape, so that
`deterministic_iff_singletonClasses` is a bare `⟨_, _⟩`.
-/
theorem singletonClasses_of_deterministic (hD : F.Deterministic) : F.SingletonClasses :=
  fun _ _ _ h y => states_eq_of_deterministic hD h y

/--
**(⇐) of `lem:deterministic-singleton`** — the half `app:deterministic`'s formalization
deliberately skipped, now that it has a consumer.

Given `w ⇒_x u` and `w ⇒_x v`, the two-point partial histories `τ₁, τ₂` carrying `w` at time `0`
and `u` (resp. `v`) at time `x` are extended by `thm:extension` to possible worlds agreeing at
time `0`; `SingletonClasses` at time `0` then forces them to agree at time `x`, i.e. `u = v`.

Two transcription notes:

* The domain `{0, x}` is **not convex**, which is exactly why the argument is run at the
  `PartialHistory` layer and `thm:extension` — not `cor:occurrence` — is the tool.
* The paper's Step 1, deriving that `⇒_0` is the identity from *Limit* plus `lem:nullity`, has
  no counterpart here: it is the general theorem `F.nullity_identity`, which closes the `x = 0`
  branch by itself.

**This is a theorem of ZFC**, via `thm:extension`'s appeal to Zorn's lemma.
-/
theorem deterministic_of_singletonClasses (h : F.SingletonClasses) : F.Deterministic := by
  rw [TaskFrame.deterministic_iff]
  intro w u v x hu hv
  by_cases hx : x = 0
  · subst hx
    rw [F.nullity_identity] at hu hv
    exact hu ▸ hv ▸ rfl
  have hne0 : ¬ ((0 : F.Duration) = x) := fun h0 => hx h0.symm
  -- The two-point partial history through `w` at time `0` and a prescribed state at time `x`,
  -- extended to a possible world by `thm:extension`. Its domain `{0, x}` is not convex, which is
  -- why the construction happens at the `PartialHistory` layer.
  have key : ∀ z : F.WorldState, F.TaskRel w x z →
      ∃ σ : WorldHistory F, σ.state 0 = w ∧ σ.state x = z := by
    intro z hz
    have h0x : (if (0 : F.Duration) = x then z else w) = w := if_neg hne0
    have hxx : (if x = x then z else w) = z := if_pos rfl
    have hresp : ∀ (s t : F.Duration), (s = 0 ∨ s = x) → (t = 0 ∨ t = x) →
        F.TaskRel (if s = x then z else w) (t - s) (if t = x then z else w) := by
      intro s t hs ht
      rcases hs with hs | hs <;> rcases ht with ht | ht <;> rw [hs, ht]
      · rw [h0x, sub_zero]; exact (F.nullity_identity w w).mpr rfl
      · rw [h0x, hxx, sub_zero]; exact hz
      · rw [h0x, hxx, zero_sub]; exact (F.reflection w x z).mp hz
      · rw [hxx, sub_self]; exact (F.nullity_identity z z).mpr rfl
    obtain ⟨σ, hext⟩ := PartialHistory.extension F
      { domain := fun t => t = 0 ∨ t = x
        nonempty_domain := ⟨0, Or.inl rfl⟩
        states := fun t _ => if t = x then z else w
        respects_task := fun s t hs ht => hresp s t hs ht }
    exact ⟨σ, (hext.agree 0 (Or.inl rfl)).trans h0x, (hext.agree x (Or.inr rfl)).trans hxx⟩
  obtain ⟨σ₁, h₁0, h₁x⟩ := key u hu
  obtain ⟨σ₂, h₂0, h₂x⟩ := key v hv
  have hy := h σ₁ σ₂ 0 (h₁0.trans h₂0.symm) x
  rw [h₁x, h₂x] at hy
  exact hy

/--
**`lem:deterministic-singleton`, as the biconditional the manuscript now states it as.**

The (⇒) half is choice-free; the (⇐) half is a theorem of ZFC. See this module's docstring.
-/
theorem deterministic_iff_singletonClasses (F : TaskFrame) :
    F.Deterministic ↔ F.SingletonClasses :=
  ⟨singletonClasses_of_deterministic, deterministic_of_singletonClasses⟩

end FormalSystem.Semantics
