/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

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

- `co_valid`: `ValidDedekindDense (Formula.co φ)`.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {F : TaskFrame}

/-- Two-conjunct extraction through the doubly-negated encoding of `Formula.and`
(`φ ∧ ψ = ¬(φ → ¬ψ)`). Classical; the same helper appears in `Metalogic/Soundness.lean`. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  Classical.byContradiction fun hn =>
    h fun hp hq => hn ⟨hp, hq⟩

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
  -- `ValidDedekindDense.of_forall` restores the pre-abbreviation binder shape: the frame, its
  -- density instance, the LUB hypothesis, the model, the history, its totality, and the time.
  refine ValidDedekindDense.of_forall ?_
  intro F _ h_lub M τ _h_sc t
  simp only [Formula.co]
  intro h_tri h_H
  have h_all := (Truth.always_iff _).mp h_tri
  have hH : ∀ r : F.Duration, r < t → TruthAt M τ r φ := (Truth.past_iff φ).mp h_H
  rw [Truth.future_iff]
  intro v htv
  by_contra hnv
  -- `A` collects the points at or after `t` at which `Hφ` still holds.
  set A : Set F.Duration := {u : F.Duration | t ≤ u ∧ ∀ r : F.Duration, r < u → TruthAt M τ r φ} with hA
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
  -- The `△`-antecedent applies at `s` directly: the collected form of `always_iff` holds at
  -- *every* time, so no case split on `s = t` versus `t < s` is needed.
  obtain ⟨s', hss', hHs'⟩ :=
    (Truth.some_future_iff (Formula.allPast φ)).mp (h_all s ((Truth.past_iff φ).mpr hsA.2))
  have hs'A : s' ∈ A :=
    ⟨le_trans hts (le_of_lt hss'), (Truth.past_iff φ).mp hHs'⟩
  exact absurd (hs.1 hs'A) (not_le_of_gt hss')

end FormalSystem.Metalogic.SoundnessLemmas
