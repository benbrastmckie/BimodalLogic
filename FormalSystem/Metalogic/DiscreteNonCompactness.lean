/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.StrongCompleteness

/-!
# Non-compactness of the `FrameClass.Discrete` consequence relation

This module discharges the informal argument recorded in `Metalogic/StrongCompleteness.lean`'s
module docstring: the set-based semantic consequence relation for `FrameClass.Discrete` is **not
compact**, so genuine strong completeness is unavailable for that class.

## The witness

Fix an atom `p`. The premise set is

  `archWitness p = {F p} ∪ {¬Xⁿ p : n ∈ ℕ}`

where `X φ = Formula.next φ = Formula.untl Formula.bot φ` is the next-step operator (the `untl`
constructor is **guard-first**: `next φ` is `untl (guard := ⊥) (event := φ)`).

* **Every finite subset is satisfiable.** A finite list `L` of members mentions only finitely
  many `Xⁿ`, so a threshold `N` bounds them all; over `ℤ` place `p` strictly beyond `N` and
  evaluate at `0`. Then `F p` holds (the witness sits at `N + 1`) and every `¬Xⁿ p` in `L` holds
  because `n ≤ N`.
* **The whole set is unsatisfiable.** Over any Archimedean discrete carrier, an `F p` witness
  `s > t` is reachable from `t` in finitely many successor steps — this is exactly where
  `IsSuccArchimedean` does its work — so `Xⁿ⁺¹ p` holds at `t` for that `n`, contradicting the
  corresponding `¬Xⁿ⁺¹ p`.

Together these refute `CompactDiscrete` (`Metalogic/SetConsequence.lean`), and hence
`StrongCompletenessDiscrete`.

## Note on `truthAt_next_iff` / `truthAt_next_iterate`

These two lemmas are pure semantics with no completeness content, and are the first semantic
characterisation of `Formula.next` anywhere in this development. Their natural eventual home is
the `Truth` namespace of `FormalSystem/Semantics/Truth.lean`, beside `some_future_iff`,
`future_iff` and `past_iff`; the needed `SuccOrder`/`NoMaxOrder` are already in scope there. They
are kept here for now because `Truth.lean` sits near the root of the import graph and this module
is their only consumer — promotion is the right move once a second consumer appears.

They are deliberately **not** `@[simp]`: were they promoted upstream, a simp-normal `next`
rewrite would fire inside the proof-theoretic reasoning in `Theorems/DiscreteUnfolding.lean`.
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-! ## The next-step truth lemmas -/

/-- **Semantic characterisation of `Formula.next`.** On a discrete order with no maximum,
    `X φ` holds at `t` exactly when `φ` holds at `Order.succ t`.

    Unfolding the `untl` clause of `TruthAt`, `TruthAt t (next φ)` reads
    `∃ s > t, φ(s) ∧ ∀ r ∈ (t, s), ⊥` — the empty-gap condition forces `s = Order.succ t`. -/
theorem truthAt_next_iff [SuccOrder D] [NoMaxOrder D]
    {F : TaskFrame D} (M : TaskModel F) (τ : WorldHistory F) (t : D) (φ : Formula) :
    TruthAt M τ t (Formula.next φ) ↔ TruthAt M τ (Order.succ t) φ := by
  constructor
  · rintro ⟨s, hts, hs, hgap⟩
    have h1 : Order.succ t ≤ s := Order.succ_le_of_lt hts
    rcases lt_or_eq_of_le h1 with h | h
    · exact absurd (hgap (Order.succ t) (Order.lt_succ t) h) not_false
    · exact h ▸ hs
  · intro h
    exact ⟨Order.succ t, Order.lt_succ t, h, fun r hr hrs =>
      absurd hr (not_lt.mpr (Order.le_of_lt_succ hrs))⟩

/-- Iterated form of `truthAt_next_iff`: `Xⁿ φ` at `t` is `φ` at the `n`-th successor of `t`. -/
theorem truthAt_next_iterate [SuccOrder D] [NoMaxOrder D]
    {F : TaskFrame D} (M : TaskModel F) (τ : WorldHistory F) :
    ∀ (n : ℕ) (t : D) (φ : Formula),
      TruthAt M τ t (Formula.next^[n] φ) ↔ TruthAt M τ (Order.succ^[n] t) φ := by
  intro n
  induction n with
  | zero => intro t φ; simp
  | succ k ih =>
    intro t φ
    -- The two rewrites are asymmetric on purpose: unprimed peels the *outermost* `next` off the
    -- formula side, primed peels the *innermost* `succ` off the time side. Using the same
    -- orientation on both sides leaves a type mismatch at the `exact`.
    rw [Function.iterate_succ_apply, ih, Function.iterate_succ_apply']
    exact truthAt_next_iff M τ _ φ

end FormalSystem.Metalogic
