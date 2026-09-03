/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity
import FormalSystem.Metalogic.Core.DeductionTheorem
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.BXCanonical.CompletenessDedekind
import FormalSystem.Metalogic.SetConsequence

/-!
# Consequence Completeness, and the Strong Completeness Programme

This module hosts the finite-context *consequence completeness* statements of the bimodal
system — completeness for `Γ : Context` semantic consequence — together with the
class-specific semantic consequence relations they are stated against. All four frame classes
now carry the layer: `FrameClass.Dedekind` is the instance developed first, and the Base, Dense
and Discrete instances have the same four-layer shape (semantic deduction theorem, consequence
terminus, soundness guard, weak corollary) in the sections below. It is also the intended home
of the genuine *strong* completeness statements (arbitrary `Set Formula` premise sets) for the
classes that can support them; see the programme below.

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
  `Formula.next φ = Formula.untl Formula.bot φ` is a genuine next-step operator on discrete
  orders, so the premise set `{F p} ∪ {(¬Xⁿ p) : n ∈ ℕ}` is finitely satisfiable over `ℤ`
  (place `p` far enough out) yet unsatisfiable over every Archimedean discrete carrier: the
  `F p` witness would lie at some finite successor distance. Only weak completeness, and its
  finite-context consequence corollary, is available for this class.

  This argument is **no longer informal**. It is machine-checked in
  `FormalSystem/Metalogic/DiscreteNonCompactness.lean`: the witness set is `archWitness`, its
  two halves are `archWitness_finitely_satisfiable` and `archWitness_not_satisfiable`, and the
  conclusions are `discrete_consequence_not_compact` (refuting `CompactDiscrete`) and
  `strongCompletenessDiscrete_refuted` (refuting `StrongCompletenessDiscrete`). All are
  sorry-free at exactly `[propext, Classical.choice, Quot.sound]`.
* **`FrameClass.Dedekind`**: strong completeness is **refuted**, on the same footing as
  Discrete. Reynolds 1992 (Theorem 7, §9, printed p.189) is *weak* completeness for the
  real-line axiomatisation, and the restriction there is genuine rather than an artefact of
  presentation — this class now says *why*. The `FrameClass.Dedekind` set-based consequence
  relation is not compact: the premise set `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤ : n ∈ ℕ}`, where
  `Xq φ = untl ¬q (q ∧ φ)`, is finitely satisfiable over `ℝ` (put `q` at the integers `1, …, N`)
  yet unsatisfiable over every Dedekind-complete carrier: the `q`-points climb without bound
  below a supremum that the "isolated from below" clause forbids.

  This argument is machine-checked in `FormalSystem/Metalogic/DedekindNonCompactness.lean`: the
  witness set is `dedWitness`, its two halves are `dedWitness_finitely_satisfiable` and
  `dedWitness_not_satisfiable`, and the conclusions are `dedekind_consequence_not_compact`
  (refuting `CompactDedekind`) and `strongCompletenessDedekind_refuted` (refuting
  `StrongCompletenessDedekind`). All are sorry-free at exactly
  `[propext, Classical.choice, Quot.sound]`.

  Note that `archWitness` does **not** port to this class: `Formula.next` is vacuously false on
  a densely ordered carrier, and a densely ordered type with no maximum admits no `SuccOrder`, so
  the Discrete route is not merely inconvenient here but unavailable. The headline *positive*
  result for this class therefore remains weak completeness, `completeness_dedekind`, with the
  finite-context form `consequence_completeness_dedekind` as its deduction-theorem companion —
  not a "strong" theorem, and nothing in this module purports otherwise. The refutation does not
  contradict Reynolds's theorem; it accounts for its scope.

**Two distinct statuses, which must not be collapsed.** Base and Dense are **proved**
(`compactBase`/`compactDense` and `strongCompletenessBase`/`strongCompletenessDense`, in
`Metalogic/Compactness.lean`). Discrete and Dedekind are both **machine-refuted** —
`discrete_consequence_not_compact` / `strongCompletenessDiscrete_refuted` in
`Metalogic/DiscreteNonCompactness.lean`, and `dedekind_consequence_not_compact` /
`strongCompletenessDedekind_refuted` in `Metalogic/DedekindNonCompactness.lean` — by two
*different* witnesses, for the reason given above. `SetConsequence.lean` models this discipline
across all four rows of the `FrameClass` family; reading a proved class as sharing the refuted
classes' status, or the reverse, would misstate the evidence.

The third status this section used to record — "unavailable on the primary source's own terms",
unproved but unrefuted — no longer applies to any class in the table. It was the honest reading
while the Dedekind witness was missing; it is superseded, not softened, by
`dedekind_consequence_not_compact`.

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

## A note on the `completeness_dense` / `completeness_discrete` short names

Re-exposing the weak forms as `FormalSystem.Metalogic.completeness_dense` and
`FormalSystem.Metalogic.completeness_discrete` shadows
`FormalSystem.Metalogic.BXCanonical.completeness_dense` / `…completeness_discrete` at sites that
`open FormalSystem.Metalogic.BXCanonical`: the enclosing-namespace declaration wins. This is
harmless — the shadowing and shadowed forms have identical types, so re-pointing any call site
from one to the other would be semantically inert — and every out-of-file occurrence of either
short name in this tree is docstring prose rather than a call site.

## Contents

* `SemanticConsequence` (`Semantics/Validity.lean`) — reused unchanged as the base-class
  consequence relation; `SemanticConsequenceDense`, `SemanticConsequenceDiscrete` and
  `SemanticConsequenceDedekind` are its class-restricted siblings. All four are now
  instances of one definition, `SemanticConsequenceIn fc` over `FrameClass.Sat`
  (`Semantics/Validity.lean`), rather than four hand-written binder lists; each keeps its own
  name, its own type, and a `.of_forall`/`.apply` pair recovering its pre-abbreviation shape.
* `semantic_deduction_base` / `_dense` / `_discrete` / `_dedekind_dense`,
  `consequence_completeness_base` / `_dense` / `_discrete` / `_dedekind`,
  `soundness_base_consequence` / `soundness_dense_consequence` /
  `soundness_discrete_consequence` / `soundness_dedekind_consequence`, and the weak corollaries
  `completeness_base` / `_dense` / `_discrete` / `_dedekind` — the per-class layer.
* `SemanticConsequenceDedekind` — semantic consequence over dense Dedekind-complete
  frames; the hypothesis-and-conclusion shape of `soundness_dedekind` packaged as a definition.
* `truthAt_foldr_imp` — the pointwise currying lemma relating a context to its `imp`-fold.
* `strongCompleteness_of_compact` — strong completeness from compactness plus a single-formula
  engine, and `compact_of_modelExistence` — compactness from model existence, contraposed through
  the `Formula.neg` clause of `TruthAt` and `truthAt_foldr_imp`. Both are **generic in the
  `FrameClass`**, and each replaced a pair of per-class duplicates. Both are reductions: their
  `Compact fc` and `ModelExistence fc` hypotheses are stated in `SetConsequence.lean` and
  discharged, at `.Base` and `.Dense`, in `Metalogic/Compactness.lean`, which instantiates each
  reduction twice.
* `semantic_deduction_dedekind` — the semantic deduction theorem for that relation.
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

The binder list is that of `ValidDedekind` (`Semantics/Validity.lean`) verbatim, with the
context hypothesis `∀ ψ ∈ Γ, TruthAt M τ t ψ` inserted before the conclusion. It is
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
here would make the matching soundness direction refutable. See the `ValidDedekind`
docstring for the primary-source placement of `Dedekind` above `Dense`.

**Where the binder guard now lives.** This definition used to reproduce `ValidDedekind`'s
binder list by hand, and `soundness_dedekind_consequence` below was its guard: that theorem held
only because the two lists were kept character-for-character in step, and would break if they
drifted. The guard has not been dropped — it has moved somewhere it cannot drift. The class
condition is `FrameClass.Sat .Dedekind` (`Semantics/FrameClassValidity.lean`), the *same*
expression `ValidDedekind` and `soundness_in` are indexed by, so there is now one source of
truth rather than two hand-copied lists. `soundness_dedekind_consequence` remains as the
non-vacuity witness it also always was. The pre-abbreviation binder shape is recovered by the
generic `SemanticConsequenceIn.of_forall_total` / `.apply_total` (`Semantics/Validity.lean`), followed by `sat_intro` where the
proof consumes the frame condition.
-/
def SemanticConsequenceDedekind (Γ : Context) (φ : Formula) : Prop :=
  SemanticConsequenceIn FrameClass.Dedekind Γ φ

/-! ## The semantic deduction theorem -/

/--
Currying a context into an iterated implication, pointwise at a single configuration.

This is pure list induction against the `Formula.imp` clause of `TruthAt`
(`Semantics/Truth.lean`); no frame condition, no shift-closure, and no Dedekind hypothesis
enters, which is why the lemma is stated at the bare `TaskModel` binder set and is reusable by
the Base, Dense and Discrete instances below.
-/
theorem truthAt_foldr_imp {F : TaskFrame} (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (Γ : Context) (φ : Formula) :
    TruthAt M τ t (Γ.foldr Formula.imp φ) ↔
      ((∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) := by
  induction Γ with
  | nil => simp
  | cons ψ Γ' ih =>
    simp only [List.foldr_cons, TruthAt, ih, List.mem_cons, forall_eq_or_imp]
    tauto

/--
**The semantic deduction theorem, at any frame class.** Consequence from a finite context is
validity of the corresponding iterated implication.

Both directions are `truthAt_foldr_imp` transported across the shared binder list; no
frame-condition reasoning is involved, which is why one statement serves every tag. This is the
lemma that lets a completeness engine be single-formula: it converts the arbitrary-`Γ` target
into a `ValidIn fc` input.

Before this collapse there were four copies of this theorem in this file — one per class, at
`SemanticConsequence`/`Valid`, `SemanticConsequenceDense`/`ValidDense`,
`SemanticConsequenceDiscrete`/`ValidDiscrete` and `SemanticConsequenceDedekind`/`ValidDedekind` —
differing only in the tag. The four per-class names below are retained as one-line
instantiations, recovered with no transport: each per-class consequence relation is
`SemanticConsequenceIn` at a literal tag and each per-class validity predicate is `ValidIn` at
the same one, both definitionally (`Semantics/Validity.lean`). -/
theorem semantic_deduction_in {fc : FrameClass} (Γ : Context) (φ : Formula) :
    SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ) := by
  constructor
  · intro h
    exact ValidIn.of_forall_total fun F hF M τ hτ t =>
      (truthAt_foldr_imp M τ t Γ φ).mpr (SemanticConsequenceIn.apply_total h F hF M τ hτ t)
  · intro h
    exact SemanticConsequenceIn.of_forall_total fun F hF M τ hτ t =>
      (truthAt_foldr_imp M τ t Γ φ).mp (ValidIn.apply_total h F hF M τ hτ t)

/--
**Semantic deduction theorem for the Dedekind class.** `semantic_deduction_in` at
`fc := .Dedekind`; `SemanticConsequenceDedekind` and `ValidDedekind` are that tag's
instantiations of the two relations, so the recovery is on the nose.
-/
theorem semantic_deduction_dedekind (Γ : Context) (φ : Formula) :
    SemanticConsequenceDedekind Γ φ ↔ ValidDedekind (Γ.foldr Formula.imp φ) :=
  semantic_deduction_in Γ φ

/-! ## Soundness at the consequence layer

The two halves of the soundness direction for consequence, stated adjacently: the finite-context
form over `Γ : Context` and the `Set Formula` form over `Γ : Set Formula`. Both are generic in
the frame class, and the second is the first carried up through
`setDerivable_iff_exists_finite`.

Both live in this module rather than in the modules supplying their vocabulary for an import
reason: `Semantics/Validity.lean` does not import `Metalogic/Soundness.lean`, and
`Metalogic/SetConsequence.lean` imports neither `Soundness.lean` nor this file. This file
imports all of them. -/

/--
**Soundness at the finite-context consequence layer**, at any frame class. `soundness_in` read
through `SemanticConsequenceIn`: the definition (`Semantics/Validity.lean`) and `soundness_in`
are indexed by the same `FrameClass.Sat fc`, so the two sides meet definitionally and the proof
is the eta-expansion below.

This is the generic form of the four per-class soundness guards further down
(`soundness_base_consequence`, `soundness_dense_consequence`, `soundness_discrete_consequence`,
`soundness_dedekind_consequence`), which are now its one-line instantiations. Each of those
retains its role as the guard keeping its class's completeness target honest — if a later edit
retargets a consequence relation to a class whose `Sat` drops a needed conjunct, the
instantiation stops typechecking and the build fails before a mis-stated terminus can be proved
against it. What the collapse changes is that there is one proof rather than four; what it does
not change is that there are still four guards, one per class, each naming its own relation.
-/
theorem soundness_consequence {fc : FrameClass} (Γ : Context) (φ : Formula)
    (h : Derivable fc Γ φ) : SemanticConsequenceIn fc Γ φ :=
  fun F hF M τ hτ t h_ctx => h.elim fun d => soundness_in Γ φ d F hF M τ hτ t h_ctx

/-- **Soundness at the set-consequence layer**, at an arbitrary `FrameClass`. A set-derivation
cites finitely many premises (`setDerivable_iff_exists_finite`); `soundness_in` discharges that
finite context, and `setConsequenceOnFrames_mono` carries the conclusion from the cited premises
back up to the whole of `Γ`.

The `Set Formula` half of the pair whose finite-context half is `soundness_consequence` directly
above. `Metalogic/SetConsequence.lean` carries the `Γ : Set Formula` vocabulary the
strong-completeness statements are phrased in, but no soundness theorem was ever stated against
it — the direction was only ever available by unfolding a set-derivation to its finite witness by
hand at each site. -/
theorem soundness_setConsequence {fc : FrameClass} (Γ : Set Formula) (φ : Formula)
    (h : SetDerivable fc Γ φ) : SetSemanticConsequenceOn fc Γ φ := by
  obtain ⟨L, hL, hd⟩ := (setDerivable_iff_exists_finite Γ φ).mp h
  refine setConsequenceOnFrames_mono (Γ := {ψ | ψ ∈ L}) (fun ψ hψ => hL ψ hψ) ?_
  intro F hF M τ hτ t h_all
  exact hd.elim fun d => soundness_in L φ d F hF M τ hτ t (fun ψ hψ => h_all ψ hψ)

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

/-! ## Finite-context consequence completeness, modulo the engine

The generic form of the four per-class consequence-completeness theorems further down. Given a
weak-completeness engine at `fc`, consequence from an arbitrary *finite* context is derivable at
`fc`: `semantic_deduction_in` converts the arbitrary-`Γ` target into the single-formula input the
engine consumes, and `derivable_foldr_imp_iff` converts the engine's empty-context derivation
back. Both of those are already generic in `fc`, so nothing here is class-specific. -/

/--
**Finite-context consequence completeness at any frame class, modulo the engine.**

The whole of the reduction from consequence completeness to weak completeness, in one
declaration: the deduction theorem in both directions, with `WeakCompleteness fc` in between.

**This is not strong completeness, at any class.** `Context := List Formula`, so every `Γ` here
is finite, and this statement is inter-derivable with weak completeness through exactly the
deduction theorem it is built from — which is why the hypothesis is `WeakCompleteness fc` and
not something stronger. The infinitary statement over `Γ : Set Formula` is
`StrongCompleteness fc` (`Metalogic/SetConsequence.lean`), and the gap between the two is
`Compact fc`, not an engine; see `strongCompleteness_of_compact` below.
-/
theorem consequence_completeness_of_engine {fc : FrameClass} (engine : WeakCompleteness fc)
    (Γ : Context) (φ : Formula) (h : SemanticConsequenceIn fc Γ φ) : Derivable fc Γ φ :=
  (derivable_foldr_imp_iff Γ φ).mpr (engine _ ((semantic_deduction_in Γ φ).mp h))

/-! ## Strong completeness for `FrameClass.Base` and `FrameClass.Dense`, modulo compactness -/

/--
**Strong completeness = compactness + weak completeness**, at any frame class. No new
proof-theoretic machinery, no `Γ`-relative Lindenbaum, no widened subformula root: the
countermodel engine is used unchanged, as a single-formula engine, exactly as the engine contract
above specifies. Compactness supplies a finite premise list; `derivable_foldr_imp_iff` — already
proved, and already generic in `fc` — turns the engine's empty-context derivation of the
`foldr`-implication back into a derivation from that list.

Before the `FrameClass`-indexing collapse this was two byte-identical proofs, one at `.Base` and
one at `.Dense`. Both are recovered by instantiation with no transport: `Compact .Base` *is*
`CompactBase` and `StrongCompleteness .Base` *is* `StrongCompletenessBase`, definitionally
(`Metalogic/SetConsequence.lean`), and likewise at `.Dense` and `.Discrete`.

This theorem lives here rather than in `FormalSystem/Metalogic/SetConsequence.lean`, which
supplies the `Compact` and `StrongCompleteness` vocabulary it is stated against, because
`derivable_foldr_imp_iff` is owned by this module and this module imports that one. Stating it
there would be an import cycle.

**The `engine` hypothesis is live, deliberately.** `BXCanonical.completeness`
(`BXCanonical/Completeness.lean`) has exactly the `.Base` shape,
`Valid φ → Derivable FrameClass.Base [] φ`, and `BXCanonical.completeness_dense` the `.Dense`
one; both are sorry-free, so the hypothesis is dischargeable at either class. It is nevertheless
not discharged *here*: keeping the statement engine-generic records in the type that compactness
is the whole of the gap between weak and strong completeness. The engines are supplied at the
call sites, in `Metalogic/Compactness.lean`, where `strongCompletenessBase` and
`strongCompletenessDense` instantiate this reduction with `compactBase`/`completeness_base` and
`compactDense`/`completeness_dense`. The unconditional finite-context results are
`consequence_completeness_base` and `consequence_completeness_dense` below.

**Status of the antecedent, per class, and why the route is what it is.** `CompactBase` and
`CompactDense` are **proved**, by `compactBase` and `compactDense` in
`Metalogic/Compactness.lean`, through an ultraproduct construction: an ultraproduct carrier, a
Łoś lemma for `TruthAt`, and the model-existence statements, from which `compact_of_modelExistence`
below derives compactness. `Compact .Discrete` is instead **refuted**
(`Metalogic/DiscreteNonCompactness.lean`), so at that class this reduction is a live implication
with a dead antecedent. The three statuses must not be collapsed into one.

That the route runs through an ultraproduct rather than through this file's own machinery is
forced, not incidental. The `BXCanonical` chronicle machinery **structurally cannot** be
extended to reach `CompactBase`, because every countermodel there routes through
`bundleFlow_completeness_from_neg_membership` (`Metalogic/Algebraic/FlowFrame.lean:791`), whose
three coherence hypotheses — `BFMCS.RestrictedTemporallyCoherent`,
`…RestrictedBackwardUntilSinceCoherent`, `…RestrictedForwardUntilSinceCoherent` — are all
relative to a single `root : Formula` and quantify over `deferralClosure root`, while the engine
additionally demands `φ ∈ subformulaClosure root`. Both closures are `Finset Formula`-valued. An
infinite `Γ` needs coherence over `⋃_{ψ ∈ Γ} subformulaClosure ψ`, which is not a `Finset` and
has no single `root` to be relative to. That is why the ultraproduct route abandons the
chronicle rather than extending it.
-/
theorem strongCompleteness_of_compact {fc : FrameClass} (hc : Compact fc)
    (engine : WeakCompleteness fc) :
    StrongCompleteness fc := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩

/-! ### The compactness triangle and the shared refutation skeleton

Three generic facts that the two named iffs and the four per-class refutations all run on. They
sit together because the dependency edges interleave: `compact_of_strongCompleteness` is one half
of `strongCompleteness_iff_compact` *and* the routing step of
`not_strongCompleteness_of_witness`, so the compactness half of the triangle and the refutation
skeleton cannot be separated into independent layers. -/

/-- **An unsatisfiable premise set entails everything.** The `ex falso` step of every
non-compactness argument in the tree, named once.

`SetSemanticConsequenceOn fc Γ φ` quantifies over configurations at which every member of `Γ`
holds; if there are none, the quantification is vacuous and any `φ` follows. Each of the four
refutations used to open with a four-line `have hcons : … := by refine …of_forall_total …` block
that was exactly this proof, with `φ := ⊥` and its own witness set substituted in. -/
theorem setConsequence_of_not_satisfiable {fc : FrameClass} {Γ : Set Formula} {φ : Formula}
    (h : ¬ SatisfiableSet fc Γ) : SetSemanticConsequenceOn fc Γ φ := by
  refine SetSemanticConsequenceOn.of_forall_total ?_
  intro F hF M τ hτ t hall
  exact absurd (SatisfiableSet.of_forall F hF M τ hτ t hall) h

/-- **Strong completeness implies compactness**, at any frame class — the converse of
`strongCompleteness_of_compact` above, and the direction that needs no engine.

A set-consequence is turned into a set-derivation by the hypothesis; a set-derivation cites a
*finite* premise list `L`; and `derivable_foldr_imp_iff` re-reads that finite derivation as an
empty-context derivation of `L.foldr imp φ`, which `soundness_validIn`
(`Metalogic/Soundness.lean`) makes `fc`-valid. That is the shape `Compact fc` asks for.

`soundness_validIn` is the right tool here rather than `soundness_in` at the empty context: it is
already the empty-context form, already uniform in `fc`, and using it avoids both a
`ValidIn.of_forall_total` wrapper and a vacuous `(by simp)` discharge of the empty premise
binder. -/
theorem compact_of_strongCompleteness {fc : FrameClass} (h : StrongCompleteness fc) :
    Compact fc := by
  intro Γ φ hcons
  obtain ⟨L, hL, hd⟩ := h Γ φ hcons
  exact ⟨L, hL, ((derivable_foldr_imp_iff L φ).mp hd).elim soundness_validIn⟩

/-- **Strong completeness and compactness are equivalent, given a weak-completeness engine.**

The first of the two named iffs this layer was missing. The `mpr` direction is
`strongCompleteness_of_compact` and needs the engine; the `mp` direction is
`compact_of_strongCompleteness` and does not. Stated at an arbitrary `fc`, so it applies at all
four tags — positively at `.Base` and `.Dense`, where both sides hold, and contrapositively at
`.Discrete` and `.Dedekind`, where the refutation of either side refutes the other.

The engine is a hypothesis rather than a side condition discharged here because it is genuinely
independent: `WeakCompleteness fc` is inhabited at all four tags (`completeness_base`,
`completeness_dense`, `completeness_discrete`, `completeness_dedekind` below), while compactness
is not. -/
theorem strongCompleteness_iff_compact {fc : FrameClass} (engine : WeakCompleteness fc) :
    StrongCompleteness fc ↔ Compact fc :=
  ⟨compact_of_strongCompleteness, fun hc => strongCompleteness_of_compact hc engine⟩

/-- **The shared non-compactness skeleton.** A finitely satisfiable but unsatisfiable set refutes
compactness, at any frame class.

Compactness applied to `W ⊨ ⊥` — which holds vacuously by `setConsequence_of_not_satisfiable` —
returns a finite `L ⊆ W` with `L.foldr imp ⊥` valid; `hfin` supplies a configuration satisfying
that same `L`; and `truthAt_foldr_imp` turns the two into `False`.

Both `notCompactDiscrete` (`Metalogic/DiscreteNonCompactness.lean`) and `notCompactDedekind`
(`Metalogic/DedekindNonCompactness.lean`) are one-line applications of this, at `archWitness` and
`dedWitness` respectively. The two arguments were previously written out in full in both modules,
differing only in the witness set and the class tag. -/
theorem not_compact_of_witness {fc : FrameClass} {W : Set Formula}
    (hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ W) → SatisfiableSet fc {ψ | ψ ∈ L})
    (hunsat : ¬ SatisfiableSet fc W) : ¬ Compact fc := by
  intro hc
  obtain ⟨L, hL, hvalid⟩ := hc W Formula.bot (setConsequence_of_not_satisfiable hunsat)
  obtain ⟨F, hF, M, τ, hτ, t, hsat⟩ := hfin L hL
  exact (truthAt_foldr_imp M τ t L Formula.bot).mp
    (ValidIn.apply_total hvalid F hF M τ hτ t) (fun ψ hψ => hsat ψ hψ)

/-- **The shared strong-completeness refutation.** The same witness data refutes strong
completeness, by routing through `compact_of_strongCompleteness`.

**This routing changes what the per-class refutations depend on.** They no longer mention
`soundness_discrete` or `soundness_dedekind` at all: the soundness step now happens once, inside
`compact_of_strongCompleteness`, in its class-generic `soundness_validIn` form. The per-class
soundness corollaries remain in the tree as the guards described further down, but they are no
longer on the refutation path — and with them go the `haveI : DenselyOrdered F.Duration := hd`
lines that existed only to feed `soundness_dedekind`'s instance binder. -/
theorem not_strongCompleteness_of_witness {fc : FrameClass} {W : Set Formula}
    (hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ W) → SatisfiableSet fc {ψ | ψ ∈ L})
    (hunsat : ¬ SatisfiableSet fc W) : ¬ StrongCompleteness fc :=
  fun h => not_compact_of_witness hfin hunsat (compact_of_strongCompleteness h)

/-! ### Model existence implies compactness -/

/--
**Model existence implies compactness**, at any frame class.

The contraposition. Suppose `SetSemanticConsequenceOn fc Γ φ` but no finite `L ⊆ Γ` has
`ValidIn fc (L.foldr Formula.imp φ)`. Then every finite sublist of `insert φ.neg Γ` is
satisfiable over `fc`: filtering such a sublist down to its `Γ`-part feeds the contradiction
hypothesis, and `truthAt_foldr_imp` above turns the resulting failure of validity into the
conjunction of "every filtered premise is true here" and "`φ` is false here" — which together
satisfy the whole sublist, since a member outside `Γ` can only be `φ.neg`. Model existence then
supplies one configuration satisfying all of `Γ` *and* `φ.neg`, while the consequence hypothesis
forces `φ` true there. Contradiction.

Three mechanics worth recording. `Formula.neg φ` is `φ.imp ⊥` (`Syntax/Formula.lean`) and
`TruthAt M τ t ⊥` is `False` (`Semantics/Truth.lean`), so `TruthAt M τ t φ.neg` is
*definitionally* `TruthAt M τ t φ → False`; no `truthAt_neg` lemma is needed or exists. And
`Γ : Set Formula` carries no decidability, so `classical` is what makes the `List.filter` step
available. Finally, the frame condition `hF : fc.Sat F` travels as an ordinary term: it is
carried out of the failed validity by `ValidIn.of_not` (`Semantics/Validity.lean`), threaded back
into the `SatisfiableSet` witness, and applied to `hcons` **directly, with no `.apply`
adapter** — because `SetSemanticConsequenceOn fc` exposes `fc.Sat F` as an explicit argument.
Each of the two hand-written bridges this replaces needed its own class-specific adapter at that
step.

Before the collapse this was two proofs identical apart from the class tag. Both are recovered by
instantiation, since `ModelExistenceBase` *is* `ModelExistence .Base` and `CompactBase` *is*
`Compact .Base` by definition, and likewise at `.Dense`.

Like the strong-completeness reduction above, this theorem lives here rather than in
`FormalSystem/Metalogic/SetConsequence.lean`, which supplies the `ModelExistence` and `Compact`
vocabulary it is stated against, because `truthAt_foldr_imp` is owned by this module and this
module imports that one. Stating it there would be an import cycle.

**A reduction, not a terminus.** `ModelExistence fc` is a hypothesis here, discharged elsewhere:
`modelExistenceBase` and `modelExistenceDense` (`Metalogic/Compactness.lean`) prove it at `.Base`
and `.Dense` by an ultraproduct construction, and `compactBase` / `compactDense` in that same
module are this theorem applied to them. What this theorem establishes on its own is that
compactness is no *harder* than model existence — which is what concentrated the Base and Dense
strong-completeness routes into a single construction.
-/
theorem compact_of_modelExistence {fc : FrameClass} (h : ModelExistence fc) : Compact fc := by
  classical
  intro Γ φ hcons
  by_contra hno
  push Not at hno
  have hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ insert φ.neg Γ) →
      SatisfiableSet fc {ψ | ψ ∈ L} := by
    intro L hL
    have hsub : ∀ ψ ∈ L.filter (fun ψ => decide (ψ ∈ Γ)), ψ ∈ Γ := by
      intro ψ hψ
      exact of_decide_eq_true (List.mem_filter.mp hψ).2
    have hnv := ValidIn.of_not (hno _ hsub)
    push Not at hnv
    obtain ⟨F, hF, M, τ, hτ, t, hfalse⟩ := hnv
    rw [truthAt_foldr_imp] at hfalse
    push Not at hfalse
    obtain ⟨hall, hnφ⟩ := hfalse
    refine ⟨F, hF, M, τ, hτ, t, ?_⟩
    intro ψ hψ
    by_cases hg : ψ ∈ Γ
    · exact hall ψ (List.mem_filter.mpr ⟨hψ, decide_eq_true hg⟩)
    · rcases hL ψ hψ with rfl | hmem
      · exact fun hp => hnφ hp
      · exact absurd hmem hg
  obtain ⟨F, hF, M, τ, hτ, t, hsat⟩ := h _ hfin
  exact hsat φ.neg (Set.mem_insert _ _)
    (hcons F hF M τ hτ t (fun ψ hψ => hsat ψ (Set.mem_insert_of_mem _ hψ)))

/-! ### The compactness / model-existence equivalence -/

/-- **Compactness implies model existence**, at any frame class — the converse of
`compact_of_modelExistence` above, and literally the contrapositive of `not_compact_of_witness`.

A finitely satisfiable `Γ` that were *not* satisfiable would be exactly the witness data
`not_compact_of_witness` consumes, and would therefore refute the compactness hypothesis in
hand. So `by_contra` closes the goal in one step; no second construction is needed. -/
theorem modelExistence_of_compact {fc : FrameClass} (hc : Compact fc) : ModelExistence fc := by
  intro Γ hfin
  by_contra hns
  exact not_compact_of_witness hfin hns hc

/-- **Compactness and model existence are equivalent**, at any frame class.

The second of the two named iffs this layer was missing, and unlike
`strongCompleteness_iff_compact` it is unconditional — no engine, no side hypothesis. Both
directions were already available as separate theorems; naming the equivalence is what lets a
refutation of either side be read off from a refutation of the other, which is how
`modelExistenceDedekind_refuted` (`Metalogic/DedekindNonCompactness.lean`) is drawn. -/
theorem compact_iff_modelExistence {fc : FrameClass} : Compact fc ↔ ModelExistence fc :=
  ⟨modelExistence_of_compact, compact_of_modelExistence⟩

/-! ## Consequence completeness for `FrameClass.Dedekind` -/

/--
**Finite-context consequence completeness over dense Dedekind-complete frames, modulo the
engine.**

Given a single-formula completeness engine for `ValidDedekind`, semantic consequence from
an arbitrary finite context is derivable at `FrameClass.Dedekind`.

**This is *not* strong completeness, and the gap is not one of degree.** Infinitary strong
completeness — `Γ ⊨ φ → Γ ⊢ φ` for an arbitrary, possibly infinite `Γ : Set Formula` — is a
*strictly different statement*, and three separate facts should be held apart:

1. *This theorem is inter-derivable with weak completeness.* `Context` is `List Formula`, so
   every `Γ` here is finite, and the deduction theorem turns the finite-context form into the
   single-formula form and back. Nothing is gained over `completeness_dedekind` beyond the
   convenience of the arbitrary-`Γ` shape, which is exactly the shape of `soundness_dedekind`.
2. *The infinitary statement is not reachable from this theorem, and is not established for
   this class.* A derivation is a finite object and can cite only finitely many premises, so
   strong completeness for a finitary derivability relation entails compactness of the class
   consequence relation — and no strengthening of the countermodel construction, and no
   reformulation of this theorem, supplies that compactness. Beyond that structural point the
   evidence for the two classes differs sharply, and the difference matters:

   * At `FrameClass.Discrete` the infinitary statement is **machine-refuted**:
     `discrete_consequence_not_compact` refutes `CompactDiscrete` and
     `strongCompletenessDiscrete_refuted` refutes `StrongCompletenessDiscrete`, both in
     `Metalogic/DiscreteNonCompactness.lean`, both sorry-free.
   * At `FrameClass.Dedekind` the infinitary statement is **machine-refuted** as well:
     `dedekind_consequence_not_compact` refutes `CompactDedekind` and
     `strongCompletenessDedekind_refuted` refutes `StrongCompletenessDedekind`, both in
     `Metalogic/DedekindNonCompactness.lean`, both sorry-free. The two refutations use
     *different* witnesses — `archWitness` is built from `Formula.next`, which is vacuously
     false on a densely ordered carrier — so the parallel is one of status, not of proof.
3. *The infinitary statement is not even expressible in this tree.* `Context := List Formula`
   (`Syntax/Context.lean`) is the premise type of `Derivable`, `DerivationTree`, and
   `SemanticConsequenceDedekind` alike, so there is no `Γ : Set Formula` to quantify over
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
    (engine : WeakCompleteness FrameClass.Dedekind)
    (Γ : Context) (φ : Formula) (h : SemanticConsequenceDedekind Γ φ) :
    Derivable FrameClass.Dedekind Γ φ :=
  consequence_completeness_of_engine engine Γ φ h

/--
**Soundness, restated against `SemanticConsequenceDedekind`.**

`soundness_consequence` at `fc := .Dedekind`. It remains the guard that keeps the completeness
target honest — if a later edit weakens the consequence relation, say by retargeting it to a
class whose `Sat` drops the density conjunct, this instantiation stops typechecking and the
build fails before a mis-stated completeness terminus can be proved against it. What the
collapse changed is only that the proof now lives once, generically, instead of four times; the
guard still names this class's own relation, which is the whole of what makes it a guard. In
particular it still establishes that the terminus is not vacuous: its hypothesis is inhabited
for every derivable pair `(Γ, φ)`.
-/
theorem soundness_dedekind_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Dedekind Γ φ) : SemanticConsequenceDedekind Γ φ :=
  soundness_consequence Γ φ h

/--
**Weak completeness — the headline result for the Dedekind class — as the `Γ = []` instance
of the consequence form.**

Weak completeness is the strongest completeness statement available for `FrameClass.Dedekind`:
the genuine strong (infinite-premise) form is **refuted**, by
`strongCompletenessDedekind_refuted` in `Metalogic/DedekindNonCompactness.lean` — the same
status as at `FrameClass.Discrete`, reached by a different witness (see the module docstring).
Recorded here so that the weak form has exactly
one proof in the tree, and that proof is a corollary rather than a parallel construction —
proving it independently would duplicate the countermodel engine; this declaration makes that
redundancy visible in the type.
-/
theorem completeness_dedekind_of_engine
    (engine : WeakCompleteness FrameClass.Dedekind)
    (φ : Formula) (h : ValidDedekind φ) : Derivable FrameClass.Dedekind [] φ :=
  consequence_completeness_dedekind_of_engine engine [] φ
    ((semantic_deduction_dedekind [] φ).mpr (by simpa using h))

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
held apart there. In particular this is **not** strong completeness: the infinitary statement is
*machine-refuted* for this class, by `strongCompletenessDedekind_refuted`
(`Metalogic/DedekindNonCompactness.lean`) — the same status `FrameClass.Discrete` has, though
reached by a different witness — and `Context := List Formula` cannot express it in any case.
-/
theorem consequence_completeness_dedekind (Γ : Context) (φ : Formula)
    (h : SemanticConsequenceDedekind Γ φ) : Derivable FrameClass.Dedekind Γ φ :=
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
**Stated as a `WeakCompleteness .Dedekind` witness**, which is what it is: `ValidDedekind` is
`ValidIn .Dedekind` definitionally (`Semantics/Validity.lean`), so this declaration inhabits
`WeakCompleteness FrameClass.Dedekind` (`Metalogic/SetConsequence.lean`) on the nose — no
transport, no `rfl` lemma, and no change at any application site, since `WeakCompleteness fc`
unfolds to exactly the `(φ) (h) : Derivable fc [] φ` shape this theorem used to spell out. It is
in that form that `consequence_completeness_dedekind` above and `tmComplete_iff_forward`
(`Metalogic/Conservativity/TMCompletenessReduction.lean`) consume it.
-/
theorem completeness_dedekind : WeakCompleteness FrameClass.Dedekind :=
  fun φ h => consequence_completeness_dedekind [] φ
    ((semantic_deduction_in [] φ).mpr (by simpa using h))

/-! ### Axiom audit for the terminus

Reynolds' §9 Theorem 7 is discharged with no `sorryAx` and no new axiom: exactly `propext`,
`Classical.choice` and `Quot.sound`, the same set carried by `completeness_dense` and
`completeness_discrete`. -/

#print axioms consequence_completeness_dedekind
#print axioms completeness_dedekind

/-! ## Consequence completeness for `FrameClass.Base`

The finite-context consequence layer for the base class, in the same four-layer shape as the
Dedekind section above: a semantic deduction theorem, the consequence terminus, the matching
soundness guard, and weak completeness as the `Γ = []` corollary.

**Base reuses `SemanticConsequence`; there is no `SemanticConsequenceBase` synonym.**
`SemanticConsequence` (`Semantics/Validity.lean`) is `Valid`'s binder list verbatim with the
context hypothesis `∀ ψ ∈ Γ, TruthAt M τ t ψ` inserted before the conclusion — precisely the
surgery the other three classes perform on their own validity predicates. It quantifies over
*all* carriers `D` with no order-theoretic side conditions, and for `FrameClass.Base` "all
carriers" **is** the class, so the general relation expresses base-class consequence exactly.
The `SemanticConsequenceDedekind` docstring's warning against the general relation is
correct for Dedekind, Dense and Discrete — each of which restricts the carrier — and
inapplicable here. Introducing a `SemanticConsequenceBase` synonym would be a gratuitous defeq
duplicate of a definition that already owns the `Γ ⊨ φ` notation.

Genuine strong completeness over `Set Formula` premise sets remains open for this class; the
vocabulary for it is `StrongCompletenessBase` / `CompactBase` in
`FormalSystem/Metalogic/SetConsequence.lean`, and the one theorem about it is
`strongCompleteness_of_compact` above, at `fc := .Base`. Nothing in this section is strong completeness:
`Context` is `List Formula`. -/

/--
**Semantic deduction theorem for the base class.** `semantic_deduction_in` at `fc := .Base`.

This is the row whose collapse looks different from its three siblings, and the difference is
worth recording rather than smoothing over. The other three were already stated against
`SemanticConsequenceIn`/`ValidIn` at a literal tag; this one was stated against the
frame-condition-free `SemanticConsequence`/`Valid` names and routed through their bespoke
adapters `Valid.of_forall_total` / `SemanticConsequence.of_forall` / `.apply`, which discharge
the `True` frame-condition argument so no call site writes `trivial`. Those adapters are not
needed here: `SemanticConsequence` *is* `SemanticConsequenceIn .Base` and `Valid` *is*
`ValidIn .Base`, both definitionally (`Semantics/Validity.lean`), so the generic theorem lands
on this statement with no transport at all — the `Sat .Base = True` slot is filled by the
generic proof itself. This is the lemma that lets `BXCanonical.completeness` be consumed as a
single-formula engine.
-/
theorem semantic_deduction_base (Γ : Context) (φ : Formula) :
    SemanticConsequence Γ φ ↔ Valid (Γ.foldr Formula.imp φ) :=
  semantic_deduction_in Γ φ

/--
**Finite-context consequence completeness for `FrameClass.Base`, unconditional.**

`BXCanonical.completeness` (`BXCanonical/Completeness.lean:196`) already exists as the
single-formula engine for `Valid`, so there is no `_of_engine` layer here: the engine is
consumed directly.

**This is not strong completeness.** `Context := List Formula`, so every `Γ` here is finite and
this statement is inter-derivable with weak completeness through the deduction theorem. The
infinitary statement over `Γ : Set Formula` is `StrongCompletenessBase`
(`SetConsequence.lean`), which is **proved** for this class, as `strongCompletenessBase` in
`Metalogic/Compactness.lean` — but it is not reached by anything in this file, which
supplies only the reduction it is built from.
-/
theorem consequence_completeness_base (Γ : Context) (φ : Formula)
    (h : SemanticConsequence Γ φ) : Derivable FrameClass.Base Γ φ :=
  (derivable_foldr_imp_iff Γ φ).mpr
    (BXCanonical.completeness _ ((semantic_deduction_base Γ φ).mp h))

/--
**Soundness, restated against `SemanticConsequence`.**

`soundness_consequence` at `fc := .Base`; `SemanticConsequence` is `SemanticConsequenceIn .Base`
definitionally, so the recovery is on the nose. It remains the guard that keeps the completeness
target honest — if a later edit weakens the consequence relation, this instantiation stops
typechecking and the build fails before a mis-stated completeness terminus can be proved against
it. In particular it still establishes that `consequence_completeness_base` is not vacuous: its
hypothesis is inhabited for every derivable pair `(Γ, φ)`.
-/
theorem soundness_base_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Base Γ φ) : SemanticConsequence Γ φ :=
  soundness_consequence Γ φ h

/--
**Weak completeness for `FrameClass.Base`, as the `Γ = []` instance of the consequence form.**

Definitionally `BXCanonical.completeness` routed through the deduction theorem in both
directions; recorded here so that the base class carries the same four-layer shape as the other
three, and so that the weak form is visibly a corollary rather than a parallel construction.
The vacuous `∀ ψ ∈ [], _` premise binder is discharged by `simpa`.

**Stated as a `WeakCompleteness .Base` witness.** `Valid` is `ValidIn .Base` definitionally
(`Semantics/Validity.lean`), so this declaration inhabits `WeakCompleteness FrameClass.Base`
(`Metalogic/SetConsequence.lean`) on the nose — no transport and no `rfl` lemma — and it is in
that form that `strongCompletenessBase` (`Metalogic/Compactness.lean`) and
`tmCompleteBase_iff_forwardBase`
(`Metalogic/Conservativity/TMCompletenessReduction.lean`) consume it. Application sites are
unaffected: `WeakCompleteness fc` unfolds to exactly the `(φ) (h) : Derivable fc [] φ` shape
this theorem used to spell out.
-/
theorem completeness_base : WeakCompleteness FrameClass.Base :=
  fun φ h => consequence_completeness_base [] φ
    ((semantic_deduction_in [] φ).mpr (by simpa using h))

/-! ## Consequence completeness for `FrameClass.Dense`

The finite-context consequence layer for the dense class, in the same four-layer shape as the
Base section above, against the `ValidDense` binder list. Unlike Base, this class restricts the
carrier (`[DenselyOrdered D]`), so the general `SemanticConsequence` relation would express a
different — and for a completeness statement, false — claim; a class-specific relation is
required, and `SemanticConsequenceDense` supplies it.

Genuine strong completeness over `Set Formula` premise sets **holds** for this class:
`StrongCompletenessDense` and `CompactDense` (`FormalSystem/Metalogic/SetConsequence.lean`) are
discharged by `strongCompletenessDense` and `compactDense` in
`FormalSystem/Metalogic/Compactness.lean`, the first of them by instantiating the
`strongCompleteness_of_compact` reduction above at `fc := .Dense`. Nothing in *this* section is strong
completeness: `Context` is `List Formula`. -/

/--
Semantic consequence over densely ordered carriers.

The binder list is that of `ValidDense` (`Semantics/Validity.lean`) verbatim, with the context
hypothesis `∀ ψ ∈ Γ, TruthAt M τ t ψ` inserted before the conclusion — the same surgery
`SemanticConsequenceDedekind` performs on `ValidDedekind`. It is therefore exactly
the hypothesis-and-conclusion shape of `soundness_dense` (`Metalogic/Soundness.lean:1254`),
packaged as a definition so that the completeness converse can be stated against the same
relation.

This is `SetSemanticConsequenceDense` (`SetConsequence.lean`) with `Γ : Set Formula` changed to
`Γ : Context` and nothing else. The two are deliberately distinct types: the set form is the
vocabulary of the (open) strong completeness statement, this one is the finite-context relation
that the theorems below actually discharge.

**Why not `SemanticConsequence`.** The general relation is `SemanticConsequenceIn` at `.Base`,
whose `Sat` is `True`, so it imposes no order-theoretic side condition and cannot express
consequence restricted to the dense class; a completeness theorem stated against it would be a
different statement. (For `FrameClass.Base` the general relation *is* the right one, because
there "all carriers" is the class — see the Base section above.)

**Where the binder guard now lives.** As for `SemanticConsequenceDedekind` above: the
hand-copied binder list has been replaced by `FrameClass.Sat .Dense`, the same expression
`ValidDense` and `soundness_in` are indexed by, so the guard `soundness_dense_consequence` used
to enforce by textual coincidence is now structural. The pre-abbreviation binder shape is recovered by the
generic `SemanticConsequenceIn.of_forall_total` / `.apply_total` (`Semantics/Validity.lean`).
-/
def SemanticConsequenceDense (Γ : Context) (φ : Formula) : Prop :=
  SemanticConsequenceIn FrameClass.Dense Γ φ

/--
**Semantic deduction theorem for the dense class.** `semantic_deduction_in` at `fc := .Dense`;
`SemanticConsequenceDense` and `ValidDense` are that tag's instantiations of the two relations.
`truthAt_foldr_imp`, which the generic proof runs on, is stated at the bare `TaskModel` binder
set, so the extra `[DenselyOrdered D]` binder simply rides along.
-/
theorem semantic_deduction_dense (Γ : Context) (φ : Formula) :
    SemanticConsequenceDense Γ φ ↔ ValidDense (Γ.foldr Formula.imp φ) :=
  semantic_deduction_in Γ φ

/--
**Finite-context consequence completeness for `FrameClass.Dense`, unconditional.**

`BXCanonical.completeness_dense` (`BXCanonical/Completeness.lean:255`) already exists as the
single-formula engine for `ValidDense`, so there is no `_of_engine` layer here: the engine is
consumed directly.

**This is not strong completeness.** `Context := List Formula`, so every `Γ` here is finite and
this statement is inter-derivable with weak completeness through the deduction theorem. The
infinitary statement over `Γ : Set Formula` is `StrongCompletenessDense`, which is **proved**
for this class, as `strongCompletenessDense` in `Metalogic/Compactness.lean` — reached
only through `CompactDense`, via `strongCompleteness_of_compact` at `fc := .Dense`.
-/
theorem consequence_completeness_dense (Γ : Context) (φ : Formula)
    (h : SemanticConsequenceDense Γ φ) : Derivable FrameClass.Dense Γ φ :=
  (derivable_foldr_imp_iff Γ φ).mpr
    (BXCanonical.completeness_dense _ ((semantic_deduction_dense Γ φ).mp h))

/--
**Soundness, restated against `SemanticConsequenceDense`.**

`soundness_consequence` at `fc := .Dense`. It remains the guard that keeps the completeness
target honest — if a later edit weakens the relation, say by retargeting it to a class whose
`Sat` does not imply `DenselyOrdered`, this instantiation stops typechecking and the build fails
before a mis-stated completeness terminus can be proved against it. In particular it still
establishes that `consequence_completeness_dense` is not vacuous: its hypothesis is inhabited
for every derivable pair `(Γ, φ)`.
-/
theorem soundness_dense_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Dense Γ φ) : SemanticConsequenceDense Γ φ :=
  soundness_consequence Γ φ h

/--
**Weak completeness for `FrameClass.Dense`, as the `Γ = []` instance of the consequence form.**

Definitionally `BXCanonical.completeness_dense` routed through the deduction theorem in both
directions; recorded here so that the dense class carries the same four-layer shape as the
others, and so that the weak form is visibly a corollary rather than a parallel construction.
The vacuous `∀ ψ ∈ [], _` premise binder is discharged by `simpa`.

**Stated as a `WeakCompleteness .Dense` witness.** `ValidDense` is `ValidIn .Dense`
definitionally (`Semantics/Validity.lean`), so this declaration inhabits
`WeakCompleteness FrameClass.Dense` (`Metalogic/SetConsequence.lean`) on the nose, and it is in
that form that `strongCompletenessDense` (`Metalogic/Compactness.lean`) consumes it.

On the short name it shares with `BXCanonical.completeness_dense`, see the note in the module
docstring: the enclosing-namespace declaration wins at `open` sites, and it still has the same
applied shape, so the shadowing remains inert.
-/
theorem completeness_dense : WeakCompleteness FrameClass.Dense :=
  fun φ h => consequence_completeness_dense [] φ
    ((semantic_deduction_in [] φ).mpr (by simpa using h))

/-! ## Consequence completeness for `FrameClass.Discrete`

The finite-context consequence layer for the discrete class, in the same four-layer shape as the
Base and Dense sections above, against the `ValidDiscrete` binder list.

**Only the finite-context layer exists here, and that is a permanent fact rather than a gap.**
Everything below takes `Γ : Context = List Formula`, so it is consequence completeness, not
strong completeness. For this class the infinitary statement is not merely unproved but
**machine-refuted**: `discrete_consequence_not_compact` refutes `CompactDiscrete` and
`strongCompletenessDiscrete_refuted` refutes `StrongCompletenessDiscrete` outright, both in
`FormalSystem/Metalogic/DiscreteNonCompactness.lean` and both sorry-free at exactly
`[propext, Classical.choice, Quot.sound]`. The witness is the premise set
`{F p} ∪ {(¬Xⁿ p) : n ∈ ℕ}` — expressible because `Formula.next φ = Formula.untl Formula.bot φ`
is a genuine next-step operator on discrete orders — which is finitely satisfiable over `ℤ` yet
unsatisfiable over every Archimedean discrete carrier, since `ValidDiscrete` requires
`IsSuccArchimedean`/`IsPredArchimedean`.

Discrete is no longer the only class where "machine-refuted" is the earned phrasing: Base and
Dense are **proved** (`Metalogic/Compactness.lean`), while Dedekind is refuted too, by a
different witness, in `Metalogic/DedekindNonCompactness.lean`
(`dedekind_consequence_not_compact`, `strongCompletenessDedekind_refuted`). Reynolds 1992
Theorem 7 remains correctly cited as the *weak* completeness result for that class. The two
remaining statuses — proved, refuted — must not be collapsed into one. -/

/--
Semantic consequence over discrete carriers.

The binder list is that of `ValidDiscrete` (`Semantics/Validity.lean`) verbatim — `SuccOrder`,
`PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean` in place of Dense's `DenselyOrdered` —
with the context hypothesis `∀ ψ ∈ Γ, TruthAt M τ t ψ` inserted before the conclusion. It is
therefore exactly the hypothesis-and-conclusion shape of `soundness_discrete`
(`Metalogic/Soundness.lean:1400`), packaged as a definition.

This is `SetSemanticConsequenceDiscrete` (`SetConsequence.lean`) with `Γ : Set Formula` changed
to `Γ : Context` and nothing else. The set form is the vocabulary the *refutation* is stated in;
this one is the finite-context relation the theorems below discharge. The finite form is
perfectly available even though the infinite one is false — that is precisely what
non-compactness means.

**Where the binder guard now lives.** As for the two classes above: the four-instance list is no
longer reproduced here by hand but read off `FrameClass.Sat .Discrete`
(`TaskFrame.IsSuccArchDiscrete`), the same expression `ValidDiscrete` and `soundness_in` are
indexed by. `soundness_discrete_consequence`'s warning about dropping `[IsSuccArchimedean D]`
still holds and is now enforced at that one definition rather than by keeping two lists in step.
The pre-abbreviation binder shape is recovered by the
generic `SemanticConsequenceIn.of_forall_total` / `.apply_total` (`Semantics/Validity.lean`), followed by `sat_intro`.
-/
def SemanticConsequenceDiscrete (Γ : Context) (φ : Formula) : Prop :=
  SemanticConsequenceIn FrameClass.Discrete Γ φ

/--
**Semantic deduction theorem for the discrete class.** `semantic_deduction_in` at
`fc := .Discrete`. Note that this lemma is *not* in tension with non-compactness: it is the
finite-context statement, and the deduction theorem it embodies is exactly what fails to extend
to infinite premise sets.
-/
theorem semantic_deduction_discrete (Γ : Context) (φ : Formula) :
    SemanticConsequenceDiscrete Γ φ ↔ ValidDiscrete (Γ.foldr Formula.imp φ) :=
  semantic_deduction_in Γ φ

/--
**Finite-context consequence completeness for `FrameClass.Discrete`, unconditional.**

`BXCanonical.completeness_discrete` (`BXCanonical/Completeness.lean:296`) already exists as the
single-formula engine for `ValidDiscrete`, so there is no `_of_engine` layer here.

**This is not strong completeness, and for this class it cannot be strengthened into one.**
`Context := List Formula`, so every `Γ` here is finite. The infinitary statement
`StrongCompletenessDiscrete` is refuted by `strongCompletenessDiscrete_refuted`; this theorem is
the strongest consequence-shaped result the class admits.
-/
theorem consequence_completeness_discrete (Γ : Context) (φ : Formula)
    (h : SemanticConsequenceDiscrete Γ φ) : Derivable FrameClass.Discrete Γ φ :=
  (derivable_foldr_imp_iff Γ φ).mpr
    (BXCanonical.completeness_discrete _ ((semantic_deduction_discrete Γ φ).mp h))

/--
**Soundness, restated against `SemanticConsequenceDiscrete`.**

`soundness_consequence` at `fc := .Discrete`. It remains the guard that keeps the completeness
target honest — if a later edit weakens the relation, say by retargeting it to a class whose
`Sat` drops `IsSuccArchimedean`, on which the non-compactness witness turns, this instantiation
stops typechecking and the build fails before a mis-stated terminus can be proved against it. In
particular it still establishes that `consequence_completeness_discrete` is not vacuous: its
hypothesis is inhabited for every derivable pair `(Γ, φ)`.
-/
theorem soundness_discrete_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Discrete Γ φ) : SemanticConsequenceDiscrete Γ φ :=
  soundness_consequence Γ φ h

/--
**Weak completeness for `FrameClass.Discrete`, as the `Γ = []` instance of the consequence
form.**

Weak completeness is the strongest completeness statement available for this class: the class
consequence relation is provably not compact (`discrete_consequence_not_compact`), so the
genuine strong form is refuted rather than open. Definitionally
`BXCanonical.completeness_discrete` routed through the deduction theorem in both directions; the
vacuous `∀ ψ ∈ [], _` premise binder is discharged by `simpa`.

**Stated as a `WeakCompleteness .Discrete` witness.** `ValidDiscrete` is `ValidIn .Discrete`
definitionally (`Semantics/Validity.lean`), so this declaration inhabits
`WeakCompleteness FrameClass.Discrete` (`Metalogic/SetConsequence.lean`) on the nose. Note what
that does *not* buy: `WeakCompleteness` is the single-formula statement, and
`strongCompleteness_of_compact` needs `Compact .Discrete` alongside it — which is refuted. The
witness is real; the class still has no strong completeness.

On the short name it shares with `BXCanonical.completeness_discrete`, see the note in the module
docstring: the shadowing is inert.
-/
theorem completeness_discrete : WeakCompleteness FrameClass.Discrete :=
  fun φ h => consequence_completeness_discrete [] φ
    ((semantic_deduction_in [] φ).mpr (by simpa using h))

/-! ### Axiom audit for the per-class consequence layer

The fourteen declarations of the Base, Dense and Discrete sections above — four for Base, which
reuses `SemanticConsequence` rather than introducing a relation of its own, and five each for
Dense and Discrete — are discharged with no `sorryAx` and no new axiom: exactly `propext`,
`Classical.choice` and `Quot.sound`, the same set carried by the Dedekind terminus audited
earlier in this file and by the three `BXCanonical` engines they consume.
`strongCompleteness_of_compact` is audited alongside them; it is a reduction rather than a
terminus, since it takes `Compact fc` as a hypothesis rather than proving it. Before the
`FrameClass`-indexing collapse there were two such reductions here, one per class; there is now
one, generic in `fc`.

`compact_of_modelExistence` is audited on the same footing and is counted separately from the
fourteen above: it is likewise a reduction rather than a terminus, taking `ModelExistence fc` as
a hypothesis. It too replaces what were two per-class bridges. The termini these two reductions
reduce to are audited where they are proved, in `Metalogic/Compactness.lean`. -/

#print axioms semantic_deduction_in
#print axioms soundness_consequence
#print axioms soundness_setConsequence

#print axioms strongCompleteness_of_compact
#print axioms setConsequence_of_not_satisfiable
#print axioms compact_of_strongCompleteness
#print axioms strongCompleteness_iff_compact
#print axioms not_compact_of_witness
#print axioms not_strongCompleteness_of_witness
#print axioms compact_of_modelExistence
#print axioms modelExistence_of_compact
#print axioms compact_iff_modelExistence
#print axioms consequence_completeness_base
#print axioms completeness_base
#print axioms soundness_base_consequence
#print axioms consequence_completeness_dense
#print axioms completeness_dense
#print axioms soundness_dense_consequence
#print axioms consequence_completeness_discrete
#print axioms completeness_discrete
#print axioms soundness_discrete_consequence

end FormalSystem.Metalogic
