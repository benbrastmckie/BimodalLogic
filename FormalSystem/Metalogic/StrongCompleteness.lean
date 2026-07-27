/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Metalogic.Soundness

/-!
# Strong Completeness

This module hosts the *strong* (arbitrary-context) completeness statements of the bimodal
system, together with the class-specific semantic consequence relations they are stated
against. The `FrameClass.Dedekind` instance is the one developed here; the Base, Dense and
Discrete instances have the same shape and drop into the marked sections below without
restructuring.

## The terminus is strong; weak completeness is the `Γ = []` instance

`Context` is `List Formula` (`Syntax/Context.lean`), i.e. every context is finite. Finiteness
is what makes strong and weak completeness inter-derivable, and the bridge is the deduction
theorem: `Γ ⊨ φ` iff `⊨ Γ.foldr (· ⇒ ·) φ`, so a single-formula completeness engine plus
iterated `deductionConverse` already yields the arbitrary-`Γ` statement. Consequently the
target of this file is the strong form, and the weak form is recovered by instantiating
`Γ := []` — *not* the other way around. `soundness_dedekind` (`Metalogic/Soundness.lean`) is
already stated in strong arbitrary-`Γ` form, so the strong terminus is its exact converse.

The practical consequence for the completeness engine is stated once, here, because it is easy
to get backwards: the engine never sees a context. It is fed the single formula
`Γ.foldr Formula.imp φ` and returns a derivation from `[]`. No `Γ`-relative Lindenbaum step, no
`Γ`-relative consistency notion, and no widened subformula root are needed anywhere downstream.

## Why Reynolds' "weakly complete" does not bite here

Reynolds 1992 (§9, printed p.189) states his Theorem 7 as *weak* completeness for the real-line
axiomatisation. The restriction is a genuine one in his setting, where a context may be
infinite and the proof's parameter `k` is fixed one greater than the quantifier depth of a
*single* input formula. At `Context = List Formula` there is no infinite context to express, so
the gap the word "weakly" marks is not expressible in this development's types, and the strong
form follows from the weak one by the deduction theorem above. Extending to `Set Formula`
contexts would require compactness of the Dedekind-class consequence relation, which is a
separate question and is deliberately out of scope for this module.

Stated plainly, so that the scope of the word "strong" in this file is not mistaken:
*infinitary* strong completeness — a turnstile whose left-hand side ranges over arbitrary,
possibly infinite sets of formulas — is a strictly different statement, it is provably out of
reach for any finitary proof system because the consequence relation over Dedekind-complete
flows is not compact (an infinite premise set can have no model while every finite subset has
one, and a derivation can only use finitely many premises), and it is in any case
*inexpressible* in this development: `Context` is defined as `List Formula`
(`Syntax/Context.lean`), so both the derivability turnstile and the semantic-consequence
relation are finitary by type. Nothing in this module either proves or purports to prove the
infinitary statement.

## Axiomatisability of the real-line temporal logic

Goldblatt (arXiv:2310.20069v1, Introduction, p.1) records that propositional temporal logic
over `(ℝ, <)` is recursively — indeed finitely — axiomatisable, a result due to Bull, and that
Scott's non-axiomatisability theorem concerns *first-order* temporal logic rather than the
propositional fragment; Scott's argument is noted there to apply to any infinite Dedekind
complete linear order, the integers included. The "admissible models" restriction appearing in
that paper is likewise a first-order device, introduced to recover a completeness theorem for
the first-order system. So no known obstruction stands against a propositional completeness
terminus over the reals.
`[UNVERIFIED - unverified_conversion]` — the local copy of this source is a machine conversion
whose provenance has not been independently checked, so the marker stands; the Introduction was
however read directly and does corroborate the attribution as paraphrased above. What appears
here is paraphrase, not quotation. Nothing in this file depends on it: the claim is orientation
for the reader, and no declaration below cites it.

## Contents

* `SemanticConsequenceDedekindDense` — semantic consequence over dense Dedekind-complete
  frames; the hypothesis-and-conclusion shape of `soundness_dedekind` packaged as a definition.
* `truthAt_foldr_imp` — the pointwise currying lemma relating a context to its `imp`-fold.
* `semantic_deduction_dedekind_dense` — the semantic deduction theorem for that relation.
* `derivable_foldr_imp_iff` — its proof-theoretic counterpart, generic in the frame class.
* `strong_completeness_dedekind_of_engine` — the terminus, stated against a single-formula
  completeness engine supplied as a hypothesis.
* `soundness_dedekind_consequence` — the matching soundness direction, which pins the
  consequence relation to `soundness_dedekind` and rules out a vacuous target.
* `completeness_dedekind_of_engine` — weak completeness, exhibited as the `Γ = []` instance.
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/-! ## Semantic consequence over dense Dedekind-complete frames -/

/--
Semantic consequence over dense, Dedekind-complete ordered carriers.

The binder list is that of `ValidDedekindDense` (`Semantics/Validity.lean`) verbatim, with the
context hypothesis `∀ ψ ∈ Γ, TruthAt M Omega τ t ψ` inserted before the conclusion. It is
therefore exactly the hypothesis-and-conclusion shape of `soundness_dedekind`
(`Metalogic/Soundness.lean`), packaged as a definition so that the completeness converse can be
stated against the same relation.

**Why not `SemanticConsequence`.** The general relation in `Semantics/Validity.lean` quantifies
over *all* carriers `D` with no order-theoretic side conditions, so it cannot express
consequence restricted to the Dedekind class; a completeness theorem stated against it would be
a different (and false) statement.

**Why the `[DenselyOrdered D]` binder stays.** `FrameClass.Dedekind` lies above
`FrameClass.Dense`, so `Axiom.density` and `Axiom.dense_indicator` are admissible in a
`.Dedekind` derivation. Both are false on `ℤ`, which is Dedekind-complete, so dropping density
here would make the matching soundness direction refutable. See the `ValidDedekindDense`
docstring for the primary-source placement of `Dedekind` above `Dense`.
-/
def SemanticConsequenceDedekindDense (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ

/-! ## The semantic deduction theorem -/

/--
Currying a context into an iterated implication, pointwise at a single configuration.

This is pure list induction against the `Formula.imp` clause of `TruthAt`
(`Semantics/Truth.lean`); no frame condition, no shift-closure, and no Dedekind hypothesis
enters, which is why the lemma is stated at the bare `TaskModel` binder set and is reusable by
the Base, Dense and Discrete instances below.
-/
theorem truthAt_foldr_imp {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) (Γ : Context) (φ : Formula) :
    TruthAt M Omega τ t (Γ.foldr Formula.imp φ) ↔
      ((∀ ψ ∈ Γ, TruthAt M Omega τ t ψ) → TruthAt M Omega τ t φ) := by
  induction Γ with
  | nil => simp
  | cons ψ Γ' ih =>
    simp only [List.foldr_cons, TruthAt, ih, List.mem_cons, forall_eq_or_imp]
    tauto

/--
**Semantic deduction theorem for the Dedekind class.** Consequence from a finite context is
validity of the corresponding iterated implication.

Both directions are `truthAt_foldr_imp` transported across the shared binder list; no
frame-condition reasoning is involved. This is the lemma that lets the completeness engine be
single-formula: it converts the arbitrary-`Γ` target into a `ValidDedekindDense` input.
-/
theorem semantic_deduction_dedekind_dense (Γ : Context) (φ : Formula) :
    SemanticConsequenceDedekindDense Γ φ ↔ ValidDedekindDense (Γ.foldr Formula.imp φ) := by
  constructor
  · intro h D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t
    exact (truthAt_foldr_imp M Omega τ t Γ φ).mpr (h D h_lub F M Omega h_sc τ h_mem t)
  · intro h D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t
    exact (truthAt_foldr_imp M Omega τ t Γ φ).mp (h D h_lub F M Omega h_sc τ h_mem t)

/-! ## The proof-theoretic deduction theorem, in fold form -/

/--
Discharging an `imp`-fold into the context, generic in the frame class.

Each step is one application of `deductionConverse` (`Metalogic/Core/DeductionTheorem.lean`),
followed by a weakening to permute the accumulated head formulas back into place: the converse
direction pushes formulas onto the *front* of the context in reverse order, and
`Derivable.weaken` is membership-based, so the permutation is free.
-/
theorem derivable_of_derivable_foldr_imp {fc : FrameClass} :
    ∀ (Γ Δ : Context) (φ : Formula),
      Derivable fc Δ (Γ.foldr Formula.imp φ) → Derivable fc (Γ ++ Δ) φ := by
  intro Γ
  induction Γ with
  | nil => intro Δ φ h; simpa using h
  | cons ψ Γ' ih =>
    intro Δ φ h
    rw [List.foldr_cons] at h
    have h1 : Derivable fc (ψ :: Δ) (Γ'.foldr Formula.imp φ) :=
      h.elim fun d => ⟨Core.deductionConverse Δ ψ _ d⟩
    have h2 := ih (ψ :: Δ) φ h1
    refine h2.weaken ?_
    intro χ hχ
    simp only [List.mem_append, List.mem_cons] at hχ ⊢
    tauto

/--
Absorbing context formulas into an `imp`-fold, generic in the frame class. The converse of
`derivable_of_derivable_foldr_imp`, built from `Derivable.deduction`.
-/
theorem derivable_foldr_imp_of_derivable {fc : FrameClass} :
    ∀ (Γ Δ : Context) (φ : Formula),
      Derivable fc (Γ ++ Δ) φ → Derivable fc Δ (Γ.foldr Formula.imp φ) := by
  intro Γ
  induction Γ with
  | nil => intro Δ φ h; simpa using h
  | cons ψ Γ' ih =>
    intro Δ φ h
    have h1 : Derivable fc (Γ' ++ ψ :: Δ) φ := by
      refine h.weaken ?_
      intro χ hχ
      simp only [List.cons_append, List.mem_cons, List.mem_append] at hχ ⊢
      tauto
    rw [List.foldr_cons]
    exact (ih (ψ :: Δ) φ h1).deduction

/-- The two directions above, packaged. Generic in the frame class. -/
theorem derivable_foldr_imp_iff {fc : FrameClass} (Γ : Context) (φ : Formula) :
    Derivable fc Γ φ ↔ Derivable fc [] (Γ.foldr Formula.imp φ) := by
  constructor
  · intro h
    exact derivable_foldr_imp_of_derivable Γ [] φ (by simpa using h)
  · intro h
    simpa using derivable_of_derivable_foldr_imp Γ [] φ h

/-! ## Strong completeness for `FrameClass.Dedekind` -/

/--
**Strong completeness over dense Dedekind-complete frames, modulo the engine.**

Given a single-formula completeness engine for `ValidDedekindDense`, semantic consequence from
an arbitrary finite context is derivable at `FrameClass.Dedekind`.

The engine hypothesis is deliberate. It fixes the terminus of the Dedekind route *before* the
countermodel construction exists, so the statement cannot silently drift toward the weak form,
and it records the exact interface the construction must meet: one formula in, one derivation
from the empty context out. Discharging `engine` turns this into the unconditional
`strong_completeness_dedekind`, of which weak completeness is the `Γ := []` instance (via
`derivable_foldr_imp_iff`) — the weak form is never proved separately.
-/
theorem strong_completeness_dedekind_of_engine
    (engine : ∀ ψ : Formula, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)
    (Γ : Context) (φ : Formula) (h : SemanticConsequenceDedekindDense Γ φ) :
    Derivable FrameClass.Dedekind Γ φ :=
  (derivable_foldr_imp_iff Γ φ).mpr
    (engine _ ((semantic_deduction_dedekind_dense Γ φ).mp h))

/--
**Soundness, restated against `SemanticConsequenceDedekindDense`.**

This is `soundness_dedekind` with its hypothesis-and-conclusion block folded into the
definition, and it is the guard that keeps the completeness target honest: it holds *only*
because the definition above reproduces that block verbatim. If a later edit weakens the
consequence relation — say by dropping the `[DenselyOrdered D]` binder, or by quantifying over
all carriers — this theorem breaks, and the build fails before a mis-stated completeness
terminus can be proved against it. In particular it establishes that the terminus is not
vacuous: its hypothesis is inhabited for every derivable pair `(Γ, φ)`.
-/
theorem soundness_dedekind_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Dedekind Γ φ) : SemanticConsequenceDedekindDense Γ φ := by
  intro D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t h_ctx
  exact h.elim fun d => soundness_dedekind Γ φ d D h_lub F M Omega h_sc τ h_mem t h_ctx

/--
**Weak completeness as the `Γ = []` instance of the strong terminus.**

Recorded here so that the weak form has exactly one proof in the tree, and that proof is a
corollary rather than a parallel construction. Proving weak completeness independently would
duplicate the countermodel engine and re-introduce the weaker terminus the strong statement
exists to eliminate; this declaration makes that redundancy visible in the type.
-/
theorem completeness_dedekind_of_engine
    (engine : ∀ ψ : Formula, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)
    (φ : Formula) (h : ValidDedekindDense φ) : Derivable FrameClass.Dedekind [] φ :=
  strong_completeness_dedekind_of_engine engine [] φ
    ((semantic_deduction_dedekind_dense [] φ).mpr (by simpa using h))

/-! ## Strong completeness for `FrameClass.Base`

Reserved. The Base instance has the same three-declaration shape as the Dedekind section above
(`SemanticConsequenceBase`, its semantic deduction lemma, and a `_of_engine` terminus), reusing
`truthAt_foldr_imp` and `derivable_foldr_imp_iff` unchanged; only the binder list of the
consequence relation differs. It is owned by the finite-context strong-completeness effort and
is intentionally absent rather than stubbed. -/

/-! ## Strong completeness for `FrameClass.Dense`

Reserved, same shape as the Base section above, against the `ValidDense` binder list. -/

/-! ## Strong completeness for `FrameClass.Discrete`

Reserved, same shape as the Base section above, against the `ValidDiscrete` binder list. -/

end FormalSystem.Metalogic
