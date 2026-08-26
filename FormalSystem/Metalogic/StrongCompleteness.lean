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
* **`FrameClass.Dedekind`**: strong completeness is **unavailable on the primary source's own
  terms**, which is a weaker and more accurate claim than the one Discrete supports. Reynolds
  1992 (Theorem 7, §9, printed p.189) is *weak* completeness for the real-line axiomatisation,
  and the restriction there is genuine rather than an artefact of presentation. What this tree
  does **not** contain is a refutation: there is no `CompactDedekind` definition and no theorem
  refuting compactness for this class, so "the Dedekind consequence relation is not compact"
  is at present a claim resting on the source's own scope, not a machine-checked fact. The
  headline result for this class is therefore weak completeness, `completeness_dedekind`, with
  the finite-context form `consequence_completeness_dedekind` as its deduction-theorem
  companion — not a "strong" theorem, and nothing in this module purports otherwise.

**Three distinct statuses, which must not be collapsed.** Base and Dense are **open** (neither
proved nor refuted; `CompactBase`/`CompactDense` name the obligations). Discrete is
**machine-refuted** (`discrete_consequence_not_compact`, `strongCompletenessDiscrete_refuted`).
Dedekind is **unavailable on Reynolds's terms** — unproved, with no refutation in the tree.
`SetConsequence.lean` already models this discipline for Dense versus Discrete; the Dedekind
case is the third status, and reading it as sharing Discrete's would overstate the evidence.

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
  `SemanticConsequenceDedekindDense` are its class-restricted siblings.
* `semantic_deduction_base` / `_dense` / `_discrete` / `_dedekind_dense`,
  `consequence_completeness_base` / `_dense` / `_discrete` / `_dedekind`,
  `soundness_base_consequence` / `soundness_dense_consequence` /
  `soundness_discrete_consequence` / `soundness_dedekind_consequence`, and the weak corollaries
  `completeness_base` / `_dense` / `_discrete` / `_dedekind` — the per-class layer.
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
here would make the matching soundness direction refutable. See the `ValidDedekindDense`
docstring for the primary-source placement of `Dedekind` above `Dense`.
-/
def SemanticConsequenceDedekindDense (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/-! ## The semantic deduction theorem -/

/--
Currying a context into an iterated implication, pointwise at a single configuration.

This is pure list induction against the `Formula.imp` clause of `TruthAt`
(`Semantics/Truth.lean`); no frame condition, no shift-closure, and no Dedekind hypothesis
enters, which is why the lemma is stated at the bare `TaskModel` binder set and is reusable by
the Base, Dense and Discrete instances below.
-/
theorem truthAt_foldr_imp {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} (M : TaskModel F)
    (τ : WorldHistory F) (t : D) (Γ : Context) (φ : Formula) :
    TruthAt M τ t (Γ.foldr Formula.imp φ) ↔
      ((∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ) := by
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
    exact (truthAt_foldr_imp M τ t Γ φ).mpr (h D h_lub F M τ hτ t)
  · intro h D _ _ _ _ _ h_lub F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mp (h D h_lub F M τ hτ t)

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

/-! ## Strong completeness for `FrameClass.Base` and `FrameClass.Dense`, modulo compactness -/

/--
**Strong completeness = compactness + weak completeness, at the base class.** The Base mirror of
`strongCompletenessDense_of_compact` below, with `CompactBase` / `StrongCompletenessBase` /
`valid` in place of their Dense counterparts and the `[DenselyOrdered D]` binder dropped. No new
proof-theoretic machinery: compactness supplies a finite premise list and
`derivable_foldr_imp_iff` turns the engine's empty-context derivation of the
`foldr`-implication back into a derivation from that list.

Like its Dense sibling this theorem lives here rather than in
`FormalSystem/Metalogic/SetConsequence.lean`, which supplies the vocabulary it is stated
against, because `derivable_foldr_imp_iff` is owned by this module and this module imports that
one. Stating it there would be an import cycle.

**The `engine` hypothesis is live, deliberately.** `BXCanonical.completeness`
(`BXCanonical/Completeness.lean:196`) has exactly this shape,
`valid φ → Derivable FrameClass.Base [] φ`, and is sorry-free — so unlike at the time the Dense
version was written, this hypothesis is *now* dischargeable. It is nevertheless not discharged:
keeping the statement engine-generic isolates `CompactBase` as **the entire** remaining
obligation for Base strong completeness, which is the fact worth recording in the type. The
unconditional finite-context result is `consequence_completeness_base` below; nothing is lost by
leaving `engine` open here.

**Status of `CompactBase`.** Open — neither proved nor refuted. The gate on the bespoke
ultraproduct route that would settle it is passed, but the route itself is a separate,
multi-phase piece of work that is deliberately not attempted in this file: it needs an
ultraproduct carrier, a Łoś lemma for `TruthAt`, `ModelExistenceBase` and hence `CompactBase`.
The existing `BXCanonical` chronicle machinery **structurally cannot** be extended to reach it,
because every countermodel there routes through `bundleFlow_completeness_from_neg_membership`
(`Metalogic/Algebraic/FlowFrame.lean:791`), whose three coherence hypotheses —
`BFMCS.RestrictedTemporallyCoherent`, `…RestrictedBackwardUntilSinceCoherent`,
`…RestrictedForwardUntilSinceCoherent` — are all relative to a single `root : Formula` and
quantify over `deferralClosure root`, while the engine additionally demands
`φ ∈ subformulaClosure root`. Both closures are `Finset Formula`-valued. An infinite `Γ` would
need coherence over `⋃_{ψ ∈ Γ} subformulaClosure ψ`, which is not a `Finset` and has no single
`root` to be relative to. That is why the route abandons the chronicle rather than extending
it.
-/
theorem strongCompletenessBase_of_compact (hc : CompactBase)
    (engine : ∀ ψ : Formula, valid ψ → Derivable FrameClass.Base [] ψ) :
    StrongCompletenessBase := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩

/--
**Strong completeness = compactness + weak completeness.** No new proof-theoretic machinery, no
`Γ`-relative Lindenbaum, no widened subformula root: the countermodel engine is used unchanged,
as a single-formula engine, exactly as the engine contract above specifies. Compactness supplies
a finite premise list; `derivable_foldr_imp_iff` — already proved, and already generic in `fc` —
turns the engine's empty-context derivation of the `foldr`-implication back into a derivation
from that list.

This theorem lives here rather than in `FormalSystem/Metalogic/SetConsequence.lean`, which
supplies the `CompactDense` and `StrongCompletenessDense` vocabulary it is stated against,
because `derivable_foldr_imp_iff` is owned by this module and this module imports that one.
Stating it there would be an import cycle.

**The `engine` hypothesis is live.** `BXCanonical.completeness_dense`
(`BXCanonical/Completeness.lean:256`) has exactly this shape,
`ValidDense φ → Derivable FrameClass.Dense [] φ`. It is deliberately *not* consumed here: this
statement is kept engine-generic, so `CompactDense` is the whole of the remaining obligation for
Dense strong completeness.
-/
theorem strongCompletenessDense_of_compact (hc : CompactDense)
    (engine : ∀ ψ : Formula, ValidDense ψ → Derivable FrameClass.Dense [] ψ) :
    StrongCompletenessDense := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩

/-! ### Model existence implies compactness -/

/--
**Model existence implies compactness, at the base class.**

The contraposition. Suppose `SetSemanticConsequenceBase Γ φ` but no finite `L ⊆ Γ` has
`valid (L.foldr Formula.imp φ)`. Then every finite sublist of `insert φ.neg Γ` is satisfiable:
filtering such a sublist down to its `Γ`-part feeds the contradiction hypothesis, and
`truthAt_foldr_imp` above turns the resulting failure of validity into the conjunction of
"every filtered premise is true here" and "`φ` is false here" — which together satisfy the whole
sublist, since a member outside `Γ` can only be `φ.neg`. Model existence then supplies one
configuration satisfying all of `Γ` *and* `φ.neg`, while the consequence hypothesis forces `φ`
true there. Contradiction.

Two mechanics worth recording. `Formula.neg φ` is `φ.imp ⊥` (`Syntax/Formula.lean`) and
`TruthAt M τ t ⊥` is `False` (`Semantics/Truth.lean`), so `TruthAt M τ t φ.neg` is
*definitionally* `TruthAt M τ t φ → False`; no `truthAt_neg` lemma is needed or exists. And
`Γ : Set Formula` carries no decidability, so `classical` is what makes the `List.filter` step
available.

Like the two strong-completeness reductions above, this theorem lives here rather than in
`FormalSystem/Metalogic/SetConsequence.lean`, which supplies the `ModelExistenceBase` and
`CompactBase` vocabulary it is stated against, because `truthAt_foldr_imp` is owned by this
module and this module imports that one. Stating it there would be an import cycle.

**A reduction, not a terminus.** `ModelExistenceBase` is itself an **open obligation** — the
ultraproduct construction that would discharge it is not attempted anywhere in this tree — so
`CompactBase` stays open. What this theorem establishes is that `CompactBase` is no *harder*
than model existence, and that the remaining work on the Base strong-completeness route is
concentrated in a single place.
-/
theorem compactBase_of_modelExistence (h : ModelExistenceBase) : CompactBase := by
  classical
  intro Γ φ hcons
  by_contra hno
  push Not at hno
  have hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ insert φ.neg Γ) →
      SatisfiableBaseSet {ψ | ψ ∈ L} := by
    intro L hL
    have hsub : ∀ ψ ∈ L.filter (fun ψ => decide (ψ ∈ Γ)), ψ ∈ Γ := by
      intro ψ hψ
      exact of_decide_eq_true (List.mem_filter.mp hψ).2
    have hnv := hno _ hsub
    unfold valid at hnv
    push Not at hnv
    obtain ⟨D, _, _, _, _, F, M, τ, hτ, t, hfalse⟩ := hnv
    rw [truthAt_foldr_imp] at hfalse
    push Not at hfalse
    obtain ⟨hall, hnφ⟩ := hfalse
    refine ⟨D, inferInstance, inferInstance, inferInstance, inferInstance, F, M, τ, hτ, t, ?_⟩
    intro ψ hψ
    by_cases hg : ψ ∈ Γ
    · exact hall ψ (List.mem_filter.mpr ⟨hψ, decide_eq_true hg⟩)
    · rcases hL ψ hψ with rfl | hmem
      · exact fun hp => hnφ hp
      · exact absurd hmem hg
  obtain ⟨D, _, _, _, _, F, M, τ, hτ, t, hsat⟩ := h _ hfin
  exact hsat φ.neg (Set.mem_insert _ _)
    (hcons D F M τ hτ t (fun ψ hψ => hsat ψ (Set.mem_insert_of_mem _ hψ)))

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
   * At `FrameClass.Dedekind` it is **unavailable on the primary source's own terms** and
     nothing stronger. Reynolds 1992 Theorem 7 is weak-only, and this tree contains no
     `CompactDedekind` definition and no refuting theorem for the class. Saying that the
     Dedekind consequence relation "is not compact" would assert more than has been checked
     here; the honest statement is that no route to it is known and none is attempted.
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
the genuine strong (infinite-premise) form is unavailable on the primary source's own terms and
no route to it is known — but note that, unlike at `FrameClass.Discrete`, it is *unproved*
rather than refuted (see the module docstring). Recorded here so that the weak form has exactly
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
held apart there. In particular this is **not** strong completeness: the infinitary statement is
unavailable for this class on the primary source's own terms — *unproved*, with no refutation
in this tree, in contrast to `FrameClass.Discrete` where it is machine-refuted — and
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

/-! ## Consequence completeness for `FrameClass.Base`

The finite-context consequence layer for the base class, in the same four-layer shape as the
Dedekind section above: a semantic deduction theorem, the consequence terminus, the matching
soundness guard, and weak completeness as the `Γ = []` corollary.

**Base reuses `SemanticConsequence`; there is no `SemanticConsequenceBase` synonym.**
`SemanticConsequence` (`Semantics/Validity.lean`) is `valid`'s binder list verbatim with the
context hypothesis `∀ ψ ∈ Γ, TruthAt M τ t ψ` inserted before the conclusion — precisely the
surgery the other three classes perform on their own validity predicates. It quantifies over
*all* carriers `D` with no order-theoretic side conditions, and for `FrameClass.Base` "all
carriers" **is** the class, so the general relation expresses base-class consequence exactly.
The `SemanticConsequenceDedekindDense` docstring's warning against the general relation is
correct for Dedekind, Dense and Discrete — each of which restricts the carrier — and
inapplicable here. Introducing a `SemanticConsequenceBase` synonym would be a gratuitous defeq
duplicate of a definition that already owns the `Γ ⊨ φ` notation.

Genuine strong completeness over `Set Formula` premise sets remains open for this class; the
vocabulary for it is `StrongCompletenessBase` / `CompactBase` in
`FormalSystem/Metalogic/SetConsequence.lean`, and the one theorem about it is
`strongCompletenessBase_of_compact` above. Nothing in this section is strong completeness:
`Context` is `List Formula`. -/

/--
**Semantic deduction theorem for the base class.** Consequence from a finite context is
validity of the corresponding iterated implication.

Both directions are `truthAt_foldr_imp` transported across the shared binder list of `valid`
and `SemanticConsequence`; no frame-condition reasoning is involved. This is the lemma that
lets `BXCanonical.completeness` be consumed as a single-formula engine.
-/
theorem semantic_deduction_base (Γ : Context) (φ : Formula) :
    SemanticConsequence Γ φ ↔ valid (Γ.foldr Formula.imp φ) := by
  constructor
  · intro h D _ _ _ _ F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mpr (h D F M τ hτ t)
  · intro h D _ _ _ _ F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mp (h D F M τ hτ t)

/--
**Finite-context consequence completeness for `FrameClass.Base`, unconditional.**

`BXCanonical.completeness` (`BXCanonical/Completeness.lean:196`) already exists as the
single-formula engine for `valid`, so there is no `_of_engine` layer here: the engine is
consumed directly.

**This is not strong completeness.** `Context := List Formula`, so every `Γ` here is finite and
this statement is inter-derivable with weak completeness through the deduction theorem. The
infinitary statement over `Γ : Set Formula` is `StrongCompletenessBase`
(`SetConsequence.lean`), which is **open** for this class — neither proved nor refuted — and is
not reached by anything in this file.
-/
theorem consequence_completeness_base (Γ : Context) (φ : Formula)
    (h : SemanticConsequence Γ φ) : Derivable FrameClass.Base Γ φ :=
  (derivable_foldr_imp_iff Γ φ).mpr
    (BXCanonical.completeness _ ((semantic_deduction_base Γ φ).mp h))

/--
**Soundness, restated against `SemanticConsequence`.**

This is `soundness` (`Metalogic/Soundness.lean:1080`) with its hypothesis-and-conclusion block
folded into the definition. It is the guard that keeps the completeness target honest: it holds
*only* because `SemanticConsequence` reproduces `valid`'s binder list verbatim. If a later edit
weakens the consequence relation, this theorem breaks and the build fails before a mis-stated
completeness terminus can be proved against it. In particular it establishes that
`consequence_completeness_base` is not vacuous: its hypothesis is inhabited for every derivable
pair `(Γ, φ)`.
-/
theorem soundness_base_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Base Γ φ) : SemanticConsequence Γ φ := by
  intro D _ _ _ _ F M τ hτ t h_ctx
  exact h.elim fun d => soundness Γ φ d D F M τ hτ t h_ctx

/--
**Weak completeness for `FrameClass.Base`, as the `Γ = []` instance of the consequence form.**

Definitionally `BXCanonical.completeness` routed through the deduction theorem in both
directions; recorded here so that the base class carries the same four-layer shape as the other
three, and so that the weak form is visibly a corollary rather than a parallel construction.
The vacuous `∀ ψ ∈ [], _` premise binder is discharged by `simpa`.
-/
theorem completeness_base (φ : Formula) (h : valid φ) : Derivable FrameClass.Base [] φ :=
  consequence_completeness_base [] φ
    ((semantic_deduction_base [] φ).mpr (by simpa using h))

/-! ## Consequence completeness for `FrameClass.Dense`

The finite-context consequence layer for the dense class, in the same four-layer shape as the
Base section above, against the `ValidDense` binder list. Unlike Base, this class restricts the
carrier (`[DenselyOrdered D]`), so the general `SemanticConsequence` relation would express a
different — and for a completeness statement, false — claim; a class-specific relation is
required, and `SemanticConsequenceDense` supplies it.

Genuine strong completeness over `Set Formula` premise sets remains **open** for this class:
`StrongCompletenessDense` and `CompactDense` (`FormalSystem/Metalogic/SetConsequence.lean`) name
open obligations, and `strongCompletenessDense_of_compact` above isolates `CompactDense` as the
whole of what remains. Nothing in this section is strong completeness: `Context` is
`List Formula`. -/

/--
Semantic consequence over densely ordered carriers.

The binder list is that of `ValidDense` (`Semantics/Validity.lean`) verbatim, with the context
hypothesis `∀ ψ ∈ Γ, TruthAt M τ t ψ` inserted before the conclusion — the same surgery
`SemanticConsequenceDedekindDense` performs on `ValidDedekindDense`. It is therefore exactly
the hypothesis-and-conclusion shape of `soundness_dense` (`Metalogic/Soundness.lean:1254`),
packaged as a definition so that the completeness converse can be stated against the same
relation.

This is `SetSemanticConsequenceDense` (`SetConsequence.lean`) with `Γ : Set Formula` changed to
`Γ : Context` and nothing else. The two are deliberately distinct types: the set form is the
vocabulary of the (open) strong completeness statement, this one is the finite-context relation
that the theorems below actually discharge.

**Why not `SemanticConsequence`.** The general relation quantifies over *all* carriers with no
order-theoretic side conditions, so it cannot express consequence restricted to the dense class;
a completeness theorem stated against it would be a different statement. (For `FrameClass.Base`
the general relation *is* the right one, because there "all carriers" is the class — see the
Base section above.)
-/
def SemanticConsequenceDense (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
    [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/--
**Semantic deduction theorem for the dense class.** Consequence from a finite context is
`ValidDense`ity of the corresponding iterated implication.

Both directions are `truthAt_foldr_imp` transported across the shared binder list; no
frame-condition reasoning is involved. `truthAt_foldr_imp` is stated at the bare `TaskModel`
binder set, so the extra `[DenselyOrdered D]` binder simply rides along.
-/
theorem semantic_deduction_dense (Γ : Context) (φ : Formula) :
    SemanticConsequenceDense Γ φ ↔ ValidDense (Γ.foldr Formula.imp φ) := by
  constructor
  · intro h D _ _ _ _ _ F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mpr (h D F M τ hτ t)
  · intro h D _ _ _ _ _ F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mp (h D F M τ hτ t)

/--
**Finite-context consequence completeness for `FrameClass.Dense`, unconditional.**

`BXCanonical.completeness_dense` (`BXCanonical/Completeness.lean:255`) already exists as the
single-formula engine for `ValidDense`, so there is no `_of_engine` layer here: the engine is
consumed directly.

**This is not strong completeness.** `Context := List Formula`, so every `Γ` here is finite and
this statement is inter-derivable with weak completeness through the deduction theorem. The
infinitary statement over `Γ : Set Formula` is `StrongCompletenessDense`, which is **open** for
this class — neither proved nor refuted — and is reached only through `CompactDense`, via
`strongCompletenessDense_of_compact`.
-/
theorem consequence_completeness_dense (Γ : Context) (φ : Formula)
    (h : SemanticConsequenceDense Γ φ) : Derivable FrameClass.Dense Γ φ :=
  (derivable_foldr_imp_iff Γ φ).mpr
    (BXCanonical.completeness_dense _ ((semantic_deduction_dense Γ φ).mp h))

/--
**Soundness, restated against `SemanticConsequenceDense`.**

This is `soundness_dense` (`Metalogic/Soundness.lean:1254`) with its hypothesis-and-conclusion
block folded into the definition, and it is the guard that keeps the completeness target honest:
it holds *only* because `SemanticConsequenceDense` reproduces `ValidDense`'s binder list
verbatim. If a later edit weakens the relation — say by dropping `[DenselyOrdered D]` — this
theorem breaks and the build fails before a mis-stated completeness terminus can be proved
against it. In particular it establishes that `consequence_completeness_dense` is not vacuous:
its hypothesis is inhabited for every derivable pair `(Γ, φ)`.
-/
theorem soundness_dense_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Dense Γ φ) : SemanticConsequenceDense Γ φ := by
  intro D _ _ _ _ _ F M τ hτ t h_ctx
  exact h.elim fun d => soundness_dense Γ φ d D F M τ hτ t h_ctx

/--
**Weak completeness for `FrameClass.Dense`, as the `Γ = []` instance of the consequence form.**

Definitionally `BXCanonical.completeness_dense` routed through the deduction theorem in both
directions; recorded here so that the dense class carries the same four-layer shape as the
others, and so that the weak form is visibly a corollary rather than a parallel construction.
The vacuous `∀ ψ ∈ [], _` premise binder is discharged by `simpa`.

On the short name it shares with `BXCanonical.completeness_dense`, see the note in the module
docstring: the enclosing-namespace declaration wins at `open` sites and the two have identical
types, so the shadowing is inert.
-/
theorem completeness_dense (φ : Formula) (h : ValidDense φ) : Derivable FrameClass.Dense [] φ :=
  consequence_completeness_dense [] φ
    ((semantic_deduction_dense [] φ).mpr (by simpa using h))

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

Discrete is the one class in this development where "machine-refuted" is the earned phrasing:
Base and Dense are **open**, and Dedekind is **unavailable on its primary source's own terms**
(Reynolds 1992 Theorem 7 is weak-only). Those three statuses must not be collapsed into one. -/

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
-/
def SemanticConsequenceDiscrete (Γ : Context) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]
    [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

/--
**Semantic deduction theorem for the discrete class.** Consequence from a finite context is
`ValidDiscrete`ity of the corresponding iterated implication.

Both directions are `truthAt_foldr_imp` transported across the shared binder list. Note that
this lemma is *not* in tension with non-compactness: it is the finite-context statement, and
the deduction theorem it embodies is exactly what fails to extend to infinite premise sets.
-/
theorem semantic_deduction_discrete (Γ : Context) (φ : Formula) :
    SemanticConsequenceDiscrete Γ φ ↔ ValidDiscrete (Γ.foldr Formula.imp φ) := by
  constructor
  · intro h D _ _ _ _ _ _ _ _ F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mpr (h D F M τ hτ t)
  · intro h D _ _ _ _ _ _ _ _ F M τ hτ t
    exact (truthAt_foldr_imp M τ t Γ φ).mp (h D F M τ hτ t)

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

This is `soundness_discrete` (`Metalogic/Soundness.lean:1400`) with its
hypothesis-and-conclusion block folded into the definition, and it is the guard that keeps the
completeness target honest: it holds *only* because `SemanticConsequenceDiscrete` reproduces
`ValidDiscrete`'s binder list verbatim. If a later edit weakens the relation — say by dropping
`[IsSuccArchimedean D]`, on which the non-compactness witness turns — this theorem breaks and
the build fails before a mis-stated terminus can be proved against it. In particular it
establishes that `consequence_completeness_discrete` is not vacuous: its hypothesis is inhabited
for every derivable pair `(Γ, φ)`.
-/
theorem soundness_discrete_consequence (Γ : Context) (φ : Formula)
    (h : Derivable FrameClass.Discrete Γ φ) : SemanticConsequenceDiscrete Γ φ := by
  intro D _ _ _ _ _ _ _ _ F M τ hτ t h_ctx
  exact h.elim fun d => soundness_discrete Γ φ d D F M τ hτ t h_ctx

/--
**Weak completeness for `FrameClass.Discrete`, as the `Γ = []` instance of the consequence
form.**

Weak completeness is the strongest completeness statement available for this class: the class
consequence relation is provably not compact (`discrete_consequence_not_compact`), so the
genuine strong form is refuted rather than open. Definitionally
`BXCanonical.completeness_discrete` routed through the deduction theorem in both directions; the
vacuous `∀ ψ ∈ [], _` premise binder is discharged by `simpa`.

On the short name it shares with `BXCanonical.completeness_discrete`, see the note in the module
docstring: the shadowing is inert.
-/
theorem completeness_discrete (φ : Formula) (h : ValidDiscrete φ) :
    Derivable FrameClass.Discrete [] φ :=
  consequence_completeness_discrete [] φ
    ((semantic_deduction_discrete [] φ).mpr (by simpa using h))

/-! ### Axiom audit for the per-class consequence layer

The fourteen declarations of the Base, Dense and Discrete sections above — four for Base, which
reuses `SemanticConsequence` rather than introducing a relation of its own, and five each for
Dense and Discrete — are discharged with no `sorryAx` and no new axiom: exactly `propext`,
`Classical.choice` and `Quot.sound`, the same set carried by the Dedekind terminus audited
earlier in this file and by the three `BXCanonical` engines they consume.
`strongCompletenessBase_of_compact` is audited alongside them; it is a reduction rather than a
terminus, since its `CompactBase` hypothesis is an open obligation. -/

#print axioms strongCompletenessBase_of_compact
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
