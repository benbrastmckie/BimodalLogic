/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.BXCanonical.CompletenessDedekind

/-!
# Consequence Completeness, and the Strong Completeness Programme

This module hosts the finite-context *consequence completeness* statements of the bimodal
system — completeness for `Γ : Context` semantic consequence — together with the
class-specific semantic consequence relations they are stated against. The
`FrameClass.Dedekind` instance is the one developed here; the Base, Dense and Discrete
instances have the same shape and drop into the marked sections below without restructuring.
It is also the intended home of the genuine *strong* completeness statements (arbitrary
`Set Formula` premise sets) for the classes that can support them; see the programme below.

## Terminology: "strong completeness" is reserved for infinite premise sets

In the standard sense, strong completeness is completeness for consequence from an arbitrary —
possibly infinite — set of premises. `Context` is `List Formula` (`Syntax/Context.lean`), so
every context in this development is finite, and finite-context consequence completeness is
inter-derivable with *weak* (single-formula) completeness through the deduction theorem:
`Γ ⊨ φ` iff `⊨ Γ.foldr (· ⇒ ·) φ`, and a single-formula completeness engine plus iterated
`deductionConverse` yields the arbitrary-`Γ` statement. The finite-context results in this
file are therefore deliberately **not** named "strong": calling a statement that is
inter-derivable with weak completeness "strong completeness" would misrepresent it. The
reserved name applies to:

* **Strong completeness** (reserved, not yet stated in this file): `Γ ⊨_X φ → Γ ⊢_X φ` with
  `Γ : Set Formula` and a finitary set-derivability relation
  (`∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ`). For a finitary proof system
  this entails compactness of the class consequence relation, so it is available exactly for
  the frame classes whose consequence relation is compact.

The engine contract is unaffected by this naming discipline and is stated once, here, because
it is easy to get backwards: the engine never sees a context. It is fed the single formula
`Γ.foldr Formula.imp φ` and returns a derivation from `[]`. No `Γ`-relative Lindenbaum step, no
`Γ`-relative consistency notion, and no widened subformula root are needed anywhere downstream.

## The per-class programme

* **`FrameClass.Base` and `FrameClass.Dense`**: genuine strong completeness is the intended
  eventual terminus. Neither class's binder list imposes Archimedean-ness, so the standard
  non-compactness counterexamples do not apply; whether the full task-frame consequence
  relation (S5 box over shift-closed history sets, ordered-abelian-group time) is in fact
  compact is an open research question for this development. The set-based MCS layer
  (`SetConsistent` — correctly finitary, `SetMaximalConsistent`, `set_lindenbaum` in
  `Metalogic/Core/MaximalConsistent.lean`) is already in place; the missing substantive piece
  is a model-existence theorem — every `SetConsistent` set is satisfiable in a frame of the
  class — which does *not* follow from the single-formula countermodel engines.
* **`FrameClass.Discrete`**: strong completeness is provably FALSE — the consequence relation
  is not compact. `ValidDiscrete` requires `IsSuccArchimedean`/`IsPredArchimedean`, and
  `Formula.next φ = Formula.untl φ Formula.bot` is a genuine next-step operator on discrete
  orders, so the premise set `{F p} ∪ {(¬Xⁿ p) : n ∈ ℕ}` is finitely satisfiable over `ℤ`
  (place `p` far enough out) yet unsatisfiable over every Archimedean discrete carrier: the
  `F p` witness would lie at some finite successor distance. Only weak completeness, and its
  finite-context consequence corollary, is available for this class.
* **`FrameClass.Dedekind`**: strong completeness is likewise out of reach. Reynolds 1992
  (Theorem 7, §9, printed p.189) is *weak* completeness for the real-line axiomatisation, and
  the restriction is genuine: the consequence relation over Dedekind-complete flows is not
  compact (an infinite premise set can have no model while every finite subset has one, and a
  derivation can only use finitely many premises). The headline result for this class is
  therefore weak completeness, `completeness_dedekind`, with the finite-context form
  `consequence_completeness_dedekind` as its deduction-theorem companion — not a "strong"
  theorem, and nothing in this module purports otherwise.

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
* `consequence_completeness_dedekind_of_engine` — finite-context consequence completeness,
  stated against a single-formula completeness engine supplied as a hypothesis.
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
context hypothesis `∀ ψ ∈ Γ, TruthAt M Set.univ τ t ψ` inserted before the conclusion. It is
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
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M Set.univ τ t ψ) → TruthAt M Set.univ τ t φ

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
  · intro h D _ _ _ _ _ h_lub F M τ hτ t
    exact (truthAt_foldr_imp M Set.univ τ t Γ φ).mpr (h D h_lub F M τ hτ t)
  · intro h D _ _ _ _ _ h_lub F M τ hτ t
    exact (truthAt_foldr_imp M Set.univ τ t Γ φ).mp (h D h_lub F M τ hτ t)

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

/-! ## Consequence completeness for `FrameClass.Dedekind` -/

/--
**Finite-context consequence completeness over dense Dedekind-complete frames, modulo the
engine.**

Given a single-formula completeness engine for `ValidDedekindDense`, semantic consequence from
an arbitrary finite context is derivable at `FrameClass.Dedekind`.

**This is *not* strong completeness, and the gap is not one of degree.** Infinitary strong
completeness — `Γ ⊨ φ → Γ ⊢ φ` for an arbitrary, possibly infinite `Γ : Set Formula` — is a
*strictly different statement*, and three separate facts should be held apart:

1. *This theorem is inter-derivable with weak completeness.* `Context` is `List Formula`, so
   every `Γ` here is finite, and the deduction theorem turns the finite-context form into the
   single-formula form and back. Nothing is gained over `completeness_dedekind` beyond the
   convenience of the arbitrary-`Γ` shape, which is exactly the shape of `soundness_dedekind`.
2. *The infinitary statement is provably out of reach for any finitary proof system, by
   non-compactness.* A derivation is a finite object and can cite only finitely many premises,
   so strong completeness for a finitary derivability relation entails compactness of the
   class consequence relation. The consequence relation over dense Dedekind-complete flows is
   not compact — an infinite premise set can be unsatisfiable while every finite subset has a
   model — so no strengthening of the countermodel construction, and no reformulation of this
   theorem, can reach it. It is refuted, not merely unproved. (The same obstruction rules the
   statement out at `FrameClass.Discrete`; see the module docstring for both counterexamples.)
3. *The infinitary statement is not even expressible in this tree.* `Context := List Formula`
   (`Syntax/Context.lean`) is the premise type of `Derivable`, `DerivationTree`, and
   `SemanticConsequenceDedekindDense` alike, so there is no `Γ : Set Formula` to quantify over
   without first introducing a set-based derivability relation
   (`∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ`) that no declaration in this
   development defines. Reading this theorem as "strong completeness" therefore mistakes a
   statement about finite lists for one about arbitrary sets, of a kind the type signature
   cannot express.

The finite-context form is still the right statement to carry, for the reason in (1): it
matches the arbitrary-`Γ` shape of `soundness_dedekind` exactly.

The engine hypothesis is deliberate. It fixes the target of the Dedekind route *before* the
countermodel construction exists, and it records the exact interface the construction must
meet: one formula in, one derivation from the empty context out. Discharging `engine` turns
this into the unconditional `consequence_completeness_dedekind`, of which weak completeness —
the headline result for this class — is the `Γ := []` instance (via
`derivable_foldr_imp_iff`); the weak form is never proved separately.
-/
theorem consequence_completeness_dedekind_of_engine
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
  intro D _ _ _ _ _ h_lub F M τ hτ t h_ctx
  exact h.elim fun d => soundness_dedekind Γ φ d D h_lub F M τ hτ t h_ctx

/--
**Weak completeness — the headline result for the Dedekind class — as the `Γ = []` instance
of the consequence form.**

Weak completeness is the strongest completeness statement available for `FrameClass.Dedekind`:
the class consequence relation is not compact, so the genuine strong (infinite-premise) form
is out of reach (see the module docstring). Recorded here so that the weak form has exactly
one proof in the tree, and that proof is a corollary rather than a parallel construction —
proving it independently would duplicate the countermodel engine; this declaration makes that
redundancy visible in the type.
-/
theorem completeness_dedekind_of_engine
    (engine : ∀ ψ : Formula, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ)
    (φ : Formula) (h : ValidDedekindDense φ) : Derivable FrameClass.Dedekind [] φ :=
  consequence_completeness_dedekind_of_engine engine [] φ
    ((semantic_deduction_dedekind_dense [] φ).mpr (by simpa using h))

/-! ## The unconditional terminus

`completeness_dedekind_engine` (`BXCanonical/CompletenessDedekind.lean`) discharges the engine
hypothesis of the two `_of_engine` forms above. Nothing in this section restates or re-binds
those signatures: the two theorems below are their instances and nothing else, which is why
neither carries a proof of its own beyond naming the engine. -/

/--
**Finite-context consequence completeness over dense Dedekind-complete frames, unconditional.**

`consequence_completeness_dedekind_of_engine` at
`engine := BXCanonical.completeness_dedekind_engine` — Reynolds 1992, §9 Theorem 7, printed
p.189. The engine hypothesis is discharged; everything the docstring of the `_of_engine` form
says about what this statement is and is not carries over verbatim, including the three facts
held apart there. In particular this is **not** strong completeness: the class consequence
relation is not compact, the infinitary statement is refuted rather than merely unproved, and
`Context := List Formula` cannot express it in any case.
-/
theorem consequence_completeness_dedekind (Γ : Context) (φ : Formula)
    (h : SemanticConsequenceDedekindDense Γ φ) : Derivable FrameClass.Dedekind Γ φ :=
  consequence_completeness_dedekind_of_engine
    FormalSystem.Metalogic.BXCanonical.completeness_dedekind_engine Γ φ h

/--
**Weak completeness for `FrameClass.Dedekind` — the headline result — unconditional.**

Reynolds 1992, §2, printed p.169, is where the notion being discharged is fixed: validity over
the class implies derivability in the system for the class. The finite-context form falls out
of it because `Context` is finite and the deduction theorem is available in both directions;
that is exactly why this declaration is `consequence_completeness_dedekind` at `Γ := []` with
`simp` discharging the vacuous `∀ ψ ∈ [], _` premise binder, and **not** an independent
countermodel construction. Proving it separately would duplicate
`countermodel_dedekind_dense`; deriving it makes the redundancy visible in the type.

This agrees definitionally with `completeness_dedekind_of_engine` at the same engine; the
`_of_engine` form is retained unmodified as the pinned interface.
-/
theorem completeness_dedekind (φ : Formula) (h : ValidDedekindDense φ) :
    Derivable FrameClass.Dedekind [] φ :=
  consequence_completeness_dedekind [] φ
    ((semantic_deduction_dedekind_dense [] φ).mpr (by simpa using h))

/-! ### Axiom audit for the terminus

Reynolds' §9 Theorem 7 is discharged with no `sorryAx` and no new axiom: exactly `propext`,
`Classical.choice` and `Quot.sound`, the same set carried by `completeness_dense` and
`completeness_discrete`. -/

#print axioms consequence_completeness_dedekind
#print axioms completeness_dedekind

/-! ## Consequence and strong completeness for `FrameClass.Base`

Reserved. Two layers are expected here, and both are intentionally absent rather than stubbed:

1. The finite-context consequence instance, with the same three-declaration shape as the
   Dedekind section above (`SemanticConsequenceBase`, its semantic deduction lemma, and a
   `_of_engine` form), reusing `truthAt_foldr_imp` and `derivable_foldr_imp_iff` unchanged;
   only the binder list of the consequence relation differs.
2. Genuine strong completeness over `Set Formula` premise sets, pending the compactness /
   model-existence research described in the module docstring. The Base binder list imposes no
   Archimedean-ness, so no known non-compactness obstruction applies. -/

/-! ## Consequence and strong completeness for `FrameClass.Dense`

Reserved, same two-layer shape as the Base section above, against the `ValidDense` binder
list. Like Base, the Dense class has no known non-compactness obstruction, so genuine strong
completeness is the intended terminus. -/

/-! ## Consequence completeness for `FrameClass.Discrete`

Reserved — the finite-context consequence layer only, against the `ValidDiscrete` binder list.
Genuine strong completeness is provably unavailable for this class: `ValidDiscrete` requires
`IsSuccArchimedean`/`IsPredArchimedean`, and the premise set `{F p} ∪ {(¬Xⁿ p) : n ∈ ℕ}` —
expressible because `Formula.next φ = Formula.untl φ Formula.bot` is a genuine next-step
operator on discrete orders — is finitely satisfiable over `ℤ` yet unsatisfiable over every
Archimedean discrete carrier, so the class consequence relation is not compact. Weak
completeness (`completeness_discrete`) is the strongest form for this class. -/

end FormalSystem.Metalogic
