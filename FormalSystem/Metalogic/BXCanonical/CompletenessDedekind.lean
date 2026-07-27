/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Completeness
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# Dedekind Completeness: carrier probe and the box-dense branch

This module hosts the `FrameClass.Dedekind` completeness branch. It is the Dedekind analogue
of the `completeness_dense` material in the sibling module `Completeness.lean`, built on the
real line rather than on `Rat`.

## Scope of the Dedekind axioms

Reynolds 1992 (printed p.169) is explicit that the Prior axioms enforce only a *definably*
Dedekind complete model: "there may be gaps in the order but ... you wouldn't know that just
looking at the behaviour of temporal formulas." Nothing in this file — and nothing downstream
of it — may claim order-theoretic gap-freeness of the canonical carrier. The gap-freeness that
is available is definable gap-freeness, a consequence of Prior-U, and it is used only where a
temporal formula is at stake.

The Dedekind-completeness side condition that the *semantic* target needs is supplied instead
by the carrier: `ValidDedekindDense` (see `FormalSystem/Semantics/Validity.lean`) carries the
least-upper-bound property as an explicit `Prop` hypothesis, and `real_lub_of_bddAbove` below
discharges it for `ℝ` from Mathlib's conditionally complete linear order instance. There is
therefore no order-theoretic bridge to build.

## Contents

* `real_lub_of_bddAbove` — `ℝ` discharges the lub hypothesis of `ValidDedekindDense`.
* `dedekind_box_dense_mem` — every `FrameClass.Dedekind`-MCS contains `□(¬U(⊤,⊥))`.

The `example`s in the "Carrier probe" section are compile-time checks, not exports: they record
that the `D`-generic parametric canonical machinery accepts `D := ℝ` unchanged, which is the
hypothesis the whole Dedekind route rests on.

## References

- Reynolds 1992, §1, printed p.169 (definably-Dedekind-complete scoping).
- Reynolds 1992, printed p.168 (US/R's density axioms, this tree's `Axiom.dense_indicator`).
-/

namespace FormalSystem.Metalogic.BXCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Semantics

/-! ## Carrier probe: the `D`-generic machinery at `D := ℝ`

These `example`s exist to fail loudly if the parametric canonical construction ever acquires a
binder that `ℝ` cannot discharge (a `Countable`, an `Encodable`, a `SuccOrder`, ...). They are
the compile-time form of the claim "only the layer beneath the chronicle moves to `ℝ`". -/

section CarrierProbe

open FormalSystem.Metalogic.Algebraic.ParametricCanonical
open FormalSystem.Metalogic.Algebraic.ParametricHistory
open FormalSystem.Metalogic.Algebraic.ParametricTruthLemma
open FormalSystem.Metalogic.Algebraic.RestrictedParametricTruthLemma

variable {fc : FrameClass}

/-- The parametric canonical task frame elaborates at `D := ℝ`. -/
noncomputable example : TaskFrame ℝ := ParametricCanonicalTaskFrame (fc := fc) ℝ

/-- The parametric canonical task model elaborates at `D := ℝ`. -/
noncomputable example : TaskModel (ParametricCanonicalTaskFrame (fc := fc) ℝ) :=
  ParametricCanonicalTaskModel (fc := fc) ℝ

/-- The shift-closed canonical history space elaborates at `D := ℝ`. -/
noncomputable example (B : BFMCS (fc := fc) ℝ) :
    Set (WorldHistory (ParametricCanonicalTaskFrame (fc := fc) ℝ)) :=
  ShiftClosedParametricCanonicalOmega B

/--
The restricted-completeness engine typechecks at `D := ℝ` against a hypothesised real-carrier
bundle. This is the load-bearing probe: it is the single declaration the Dedekind countermodel
will be assembled from, and its binder list is `{fc} {D} [AddCommGroup D] [LinearOrder D]
[IsOrderedAddMonoid D]` — no `DenselyOrdered`, no `Countable`, no `Rat`.
-/
noncomputable example (B : BFMCS (fc := fc) ℝ) (root : Formula)
    (h_rtc : B.RestrictedTemporallyCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root)
    (fam : FMCS (fc := fc) ℝ) (hfam : fam ∈ B.families)
    (t : ℝ) (h_neg_in : φ.neg ∈ fam.mcs t) :
    ¬TruthAt (ParametricCanonicalTaskModel ℝ) (ShiftClosedParametricCanonicalOmega B)
      (parametricToHistory fam) t φ :=
  fully_restricted_parametric_completeness_from_neg_membership B root h_rtc h_buc h_fuc φ h_sub
    fam hfam t h_neg_in

end CarrierProbe

/-! ## `ℝ` discharges the `ValidDedekindDense` binders

`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `DenselyOrdered` and `Nontrivial` are all
found by instance search. The remaining binder of `ValidDedekindDense`
(`FormalSystem/Semantics/Validity.lean`) is an explicit `Prop`, so it needs a named lemma. -/

/-- Instance-search check for the five class binders of `ValidDedekindDense` at `D := ℝ`. -/
noncomputable example : AddCommGroup ℝ := inferInstance

noncomputable example : LinearOrder ℝ := inferInstance

noncomputable example : IsOrderedAddMonoid ℝ := inferInstance

noncomputable example : DenselyOrdered ℝ := inferInstance

noncomputable example : Nontrivial ℝ := inferInstance

/--
The least-upper-bound hypothesis of `ValidDedekindDense` holds on `ℝ`.

This is the explicit `Prop` binder at the head of `ValidDedekindDense`; every application of a
`ValidDedekindDense` hypothesis at the real carrier discharges it with this lemma. The content
is Mathlib's `ConditionallyCompleteLinearOrder ℝ` instance: `sSup s` is a least upper bound of
any nonempty bounded-above `s`.
-/
theorem real_lub_of_bddAbove :
    ∀ s : Set ℝ, s.Nonempty → BddAbove s → ∃ x, IsLUB s x :=
  fun _ hne hbd => ⟨_, isLUB_csSup hne hbd⟩

/-! ## The box-dense branch at `FrameClass.Dedekind` -/

/--
Every `FrameClass.Dedekind`-MCS contains `□(¬U(⊤,⊥))`.

This is the Dedekind analogue of the non-dense branch of `completeness_dense`
(sibling module `Completeness.lean`): `Axiom.dense_indicator` states `¬U(⊤,⊥)`, whose
`minFrameClass` is `.Dense`, and `FrameClass.Dense ≤ FrameClass.Dedekind`, so the axiom is
admissible in a `.Dedekind` derivation. Necessitation then puts the box in every Dedekind-MCS
via `theorem_in_mcs`.

Consequence: the case split that `completeness_dense` performs on `□(¬U(⊤,⊥)) ∈ M` collapses at
`.Dedekind` — there is no non-dense branch to discharge, and the countermodel construction may
assume the box-dense hypothesis unconditionally.

The placement of `Dedekind` above `Dense` is primary-source: Reynolds 1992 (printed p.168)
includes density axioms in US/R, and `K⁺⊤` normalises to this tree's `Axiom.dense_indicator`.
-/
theorem dedekind_box_dense_mem {A : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Dedekind) A) :
    Formula.box Chronicle.nextTop.neg ∈ A := by
  have h_ax : DerivationTree FrameClass.Dedekind [] Chronicle.nextTop.neg :=
    DerivationTree.axiom [] _ Axiom.dense_indicator (by trivial)
  have h_box : DerivationTree FrameClass.Dedekind [] Chronicle.nextTop.neg.box :=
    DerivationTree.necessitation _ h_ax
  exact theorem_in_mcs h_mcs h_box

/-! ## Axiom Audit

Mirrors the audit section of the sibling module `Completeness.lean`. Both declarations must
report exactly `[propext, Classical.choice, Quot.sound]` — no `sorryAx`. -/

#print axioms real_lub_of_bddAbove
#print axioms dedekind_box_dense_mem

end FormalSystem.Metalogic.BXCanonical
