/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.SoundnessLemmas.Core
import FormalSystem.Semantics.Validity

/-!
# Semantic Validity of the Paper's CO Principle

The JPL paper's `def:TMplus-c` singles out one extra axiom, **CO**, for the complete-order
extension of the base tense logic:

  `CO(φ) := △(Hφ → F(Hφ)) → (Hφ → Gφ)`

with `△` the *temporal* triangle `△ψ = Hψ ∧ ψ ∧ Gψ` (`Formula.always`). This module proves
that every CO instance is valid on dense Dedekind-complete flows, i.e.
`co_valid : ValidDedekindDense (Formula.co φ)`.

## Why this file exists

This repository's official Dedekind-class axiom basis is the Reynolds triple
`Axiom.prior_U_gap` / `Axiom.prior_S_gap` / `Axiom.sep`; CO is **not** an `Axiom`
constructor here. `co_valid` is therefore not a soundness case — nothing in the soundness
induction consumes it. It is an *independent semantic check* on the formalization: the
proof-theoretic companion `FormalSystem.Theorems.DedekindDerived.co_derived` derives CO from
the Reynolds basis, and soundness applied to that derivation must land on exactly the statement
proved here. Agreement of the two routes is the intended consistency check; a mismatch would
mean `Formula.co` transcribes the paper formula incorrectly.

## Proof shape

A direct least-upper-bound argument, mirroring `prior_U_gap_valid`
(`FormalSystem/Metalogic/Soundness.lean`). Given `△(Hφ → F Hφ)` and `Hφ` at `t`, and a
putative `v > t` with `¬φ`, the set

  `A := {u | t ≤ u ∧ Hφ holds at u}`

contains `t`, is bounded above by `v`, and its supremum `s` again satisfies `Hφ` (any `r < s`
is undercut by a member of `A` above it). The `△`-antecedent applied at `s` — its middle
conjunct when `s = t`, its `G` conjunct when `t < s` — then yields `s' > s` with `Hφ` at `s'`,
so `s' ∈ A` sits above its own supremum. Contradiction.

## Main results

- `always_elim`: the three conjuncts of `△ψ` at a point, as a usable triple.
- `co_valid`: `ValidDedekindDense (Formula.co φ)`.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-- Two-conjunct extraction through the doubly-negated encoding of `Formula.and`
(`φ ∧ ψ = ¬(φ → ¬ψ)`). Classical; the same helper appears in `Metalogic/Soundness.lean`. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  Classical.byContradiction fun hn =>
    h fun hp hq => hn ⟨hp, hq⟩

/--
**`△`-elimination, semantic side.** `△ψ = Hψ ∧ ψ ∧ Gψ` (`Formula.always`), so its truth at `t`
delivers `ψ` at every strictly-past point, `ψ` at `t` itself, and `ψ` at every strictly-future
point.

Stated for an arbitrary `ψ` so that the CO proof below never has to unfold the particular
`Hφ → F(Hφ)` sitting under the triangle.
-/
theorem always_elim {F : TaskFrame D} {M : TaskModel F}
    {τ : WorldHistory F} {t : D} {ψ : Formula}
    (h : TruthAt M τ t (Formula.always ψ)) :
    (∀ u : D, u < t → TruthAt M τ u ψ) ∧ TruthAt M τ t ψ ∧
      (∀ v : D, t < v → TruthAt M τ v ψ) := by
  simp only [Formula.always, Formula.and, Formula.neg, TruthAt, Truth.past_iff,
    Truth.future_iff] at h
  obtain ⟨h_past, h_rest⟩ := and_of_not_imp_not h
  obtain ⟨h_now, h_fut⟩ := and_of_not_imp_not h_rest
  exact ⟨h_past, h_now, h_fut⟩

/--
**Validity of the paper's CO principle** on dense Dedekind-complete flows:

  `⊨_dc  △(Hφ → F(Hφ)) → (Hφ → Gφ)`.

**Hypotheses actually consumed.** Only the least-upper-bound hypothesis `h_lub` and the linear
order. The proof uses no `DenselyOrdered`, no `Nontrivial`, no `AddCommGroup` /
`IsOrderedAddMonoid` structure, and no shift-closure assumption — exactly as with the two Prior
gap lemmas (see the note preceding `prior_U_gap_valid` in `Metalogic/Soundness.lean`). CO is
thus valid on *every* Dedekind-complete linear order, `ℤ` included. The `DenselyOrdered` binder
is carried here only for chain consistency with the rest of the `ValidDedekindDense` chain, not
because the mathematics needs it.

**Status of CO in this repository.** CO is a derived object, not a primitive: the official
Dedekind-class basis remains `Axiom.prior_U_gap` / `Axiom.prior_S_gap` / `Axiom.sep`, and the
Hilbert-side companion is `FormalSystem.Theorems.DedekindDerived.co_derived`. See
`Formula.co` for the source citation and the operator-resolution warning.
-/
theorem co_valid (φ : Formula) : ValidDedekindDense (Formula.co φ) := by
  intro D _ _ _ _ _ h_lub F M _ _h_sc τ _h_mem t
  simp only [Formula.co]
  intro h_tri h_H
  obtain ⟨-, h_mid, h_fut⟩ := always_elim h_tri
  have hH : ∀ r : D, r < t → TruthAt M τ r φ := (Truth.past_iff φ).mp h_H
  rw [Truth.future_iff]
  intro v htv
  by_contra hnv
  -- `A` collects the points at or after `t` at which `Hφ` still holds.
  set A : Set D := {u : D | t ≤ u ∧ ∀ r : D, r < u → TruthAt M τ r φ} with hA
  have htA : t ∈ A := ⟨le_refl t, hH⟩
  have hAbdd : BddAbove A := by
    refine ⟨v, ?_⟩
    intro u hu
    by_contra hvu
    exact hnv (hu.2 v (lt_of_not_ge hvu))
  obtain ⟨s, hs⟩ := h_lub A ⟨t, htA⟩ hAbdd
  have hts : t ≤ s := hs.1 htA
  -- `Hφ` survives at the supremum: any `r < s` is undercut by a member of `A` above it.
  have hsA : s ∈ A := by
    refine ⟨hts, ?_⟩
    intro r hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2 r hru
  -- The `△`-antecedent applies at `s`: middle conjunct if `s = t`, `G` conjunct if `t < s`.
  have hχs : TruthAt M τ s ((Formula.allPast φ).imp (Formula.someFuture (Formula.allPast φ))) := by
    rcases eq_or_lt_of_le hts with h_eq | h_lt
    · exact h_eq ▸ h_mid
    · exact h_fut s h_lt
  obtain ⟨s', hss', hHs'⟩ :=
    (Truth.some_future_iff (Formula.allPast φ)).mp (hχs ((Truth.past_iff φ).mpr hsA.2))
  have hs'A : s' ∈ A :=
    ⟨le_trans hts (le_of_lt hss'), (Truth.past_iff φ).mp hHs'⟩
  exact absurd (hs.1 hs'A) (not_le_of_gt hss')

end FormalSystem.Metalogic.SoundnessLemmas
