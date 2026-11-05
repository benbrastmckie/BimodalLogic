/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage

/-!
# Open-future elimination: `▷` and `◁` against separated L⁺ formulas

## What is proved here

Call an L⁺ formula **past-determined** at a frame when its truth at `(τ, t)` depends only on
`τ|(-∞, t]`, and **future-determined** when it depends only on `τ|[t, ∞)`. On every regular task
frame, the open-future modal distributes over a disjunction of such a pair, and the open-past
modal does so in mirror image:

* the **elimination** `ofutP_or_iff`, `opastP_or_iff`: for `α` past-determined and `β`
  future-determined, `▷(α ∨ β) ↔ α ∨ ⊡β` and `◁(α ∨ β) ↔ ⊡α ∨ β`;
* its **conjunctive normal form** `ofutP_sepForm_iff`, `opastP_sepForm_iff`: the restricted modal
  of a conjunction of such clauses is the conjunction of the eliminated clauses,
  `⋀ᵢ (αᵢ ∨ ⊡βᵢ)` resp. `⋀ᵢ (⊡αᵢ ∨ βᵢ)`;
* the **translation** `tr`, `openTruthAt_iff_tr`, `openValidOnFrames_iff_tr`,
  `openValidIn_ztime_iff_tr`, `openValidIn_rtime_iff_tr`: *conditional on* the named hypothesis
  `SeparationOver P` — every L⁺ formula is equivalent, on every regular frame satisfying `P`, to
  a separated conjunctive normal form — there is a translation `OpenFormula → PlusFormula`
  preserving truth at every model, world history and time over every regular `P`-frame, hence
  transporting validity in either direction.

Regularity enters through `paste` and nowhere else; it is taken exactly on the declarations whose
proofs glue a past onto a future.

## The verdict this module serves

The open-future modal `▷` and the open-past modal `◁` are **L⁺-definable at `.ZTime` and at
`.RTime`**. The route is Gabbay's Separation Theorem — over the integer flow,
[GHR][gabbay1994] vol. 1, Theorem 10.2.9; over the Dedekind-complete flows, ibid.,
Theorem 10.3.20 — applied to the `U`/`S` formula obtained by reading each maximal `□ψ` and each
maximal `⊡ψ` subformula, and each atom, as a propositional leaf. That abstraction is legitimate
because each such leaf is a function of the time alone (`□`) or of the present world state alone
(`⊡`), hence both past- and future-determined; the separated form it returns is a conjunction of
(past-determined ∨ future-determined) clauses, which is precisely what the eliminations above
consume.

## What is NOT proved here

The separation hypothesis itself. `SeparationOver` is an explicit named hypothesis standing for
the cited theorems above, which are **not formalized in this tree**; every result below it is
therefore conditional, and nothing here discharges it. The paper-level bookkeeping — the leaf
abstraction, the conjunctive-normal-form rearrangement of a separated formula, and the
order-isomorphism invariance of `U`/`S` truth — is likewise unverified in Lean. Formalizing
[GHR][gabbay1994] Lemmas 10.2.1-10.2.8 is the route that would remove the hypothesis.

Nothing here claims a completeness or a decidability result for the open-future language or for
L⁺.

## Where it does not apply

The hypothesis is **false** for `U`/`S` over `ℚ`: separation fails on a non-Dedekind-complete
flow. So it is unavailable at the `.Dense` and `.Base` frame classes, and no statement below
transfers to either.

## Why the determinedness predicates are semantic

`PastDet` and `FutDet` are stated semantically, as invariance of truth under `AgreeUpTo` resp.
`AgreeFrom`, rather than syntactically via `PlusFormula.IsPurePast` / `IsPureFuture`. This is
load-bearing and not stylistic: the separated forms supplied by the Dedekind-complete form of
separation are future-determined without being syntactically pure, so a syntactic version of
either predicate would not serve the `.RTime` instantiation at all. The two bridge lemmas
`pastDet_of_isPurePast` and `futDet_of_isPureFuture` are the only place the syntactic predicates
appear.

## Main Results

* `PastDet`, `FutDet` — the two determinedness predicates
* `pastDet_of_isPurePast`, `futDet_of_isPureFuture` — the syntactic bridges
* `OfutP`, `OpastP` — the `▷` and `◁` readings of an L⁺ argument
* `ofutP_or_iff`, `opastP_or_iff` — the elimination of a separated disjunction
* `sepForm`, `ofutElim`, `opastElim`, `SepClauses` — separated conjunctive normal forms and their
  eliminated shapes
* `ofutP_sepForm_iff`, `opastP_sepForm_iff` — the elimination in conjunctive normal form
* `SeparationOver` — the named separation hypothesis
* `tr`, `openTruthAt_iff_tr`, `openValidOnFrames_iff_tr` — the translation and its truth lemma
* `openValidIn_ztime_iff_tr`, `openValidIn_rtime_iff_tr` — validity transfer at `.ZTime` and
  `.RTime`, conditional on separation over that class
* `ofutP_of_pastDet`, `ofutP_of_futDet` — the two split-free ends of the elimination

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], Chapter 10 — the separation property, Theorem 10.2.9 over
  the integer flow and Theorem 10.3.20 over the Dedekind-complete flows
* [A. Rabinovich, *A Proof of Kamp's Theorem*][rabinovich2014], the separation-based modern
  treatment
-/

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage

variable {F : TaskFrame}

/-! ## Past- and future-determined L⁺ formulas -/

/-- `φ` is **past-determined** at `F`: its truth at `(τ, t)` depends only on `τ|(-∞, t]`. -/
def PastDet (F : TaskFrame) (φ : PlusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration), AgreeUpTo τ σ t →
    (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)

/-- `φ` is **future-determined** at `F`: its truth at `(τ, t)` depends only on `τ|[t, ∞)`. -/
def FutDet (F : TaskFrame) (φ : PlusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration), AgreeFrom τ σ t →
    (PlusTruthAt M τ t φ ↔ PlusTruthAt M σ t φ)

/-- Syntactically pure-past formulas are past-determined (`truth_congr_agreeUpTo`). The converse
fails: the separated forms the Dedekind-complete separation theorem returns are determined
without being pure, which is why `PastDet` is the semantic predicate. -/
theorem pastDet_of_isPurePast {φ : PlusFormula} (h : PlusFormula.IsPurePast φ) : PastDet F φ :=
  fun M τ σ t hag => truth_congr_agreeUpTo M h τ σ t hag

/-- Syntactically pure-future formulas are future-determined (`truth_congr_agreeFrom`). The
converse fails, for the same reason recorded at `pastDet_of_isPurePast`. -/
theorem futDet_of_isPureFuture {φ : PlusFormula} (h : PlusFormula.IsPureFuture φ) : FutDet F φ :=
  fun M τ σ t hag => truth_congr_agreeFrom M h τ σ t hag

/-! ## `▷` and `◁` read at the L⁺ level -/

/-- `▷φ` for an L⁺ argument: `φ` holds at every world history in `|τ⟩_t`, i.e. at every history
agreeing with `τ` up to and including `t`. -/
def OfutP (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) : Prop :=
  ∀ σ : WorldHistory F, AgreeUpTo τ σ t → PlusTruthAt M σ t φ

/-- `◁φ` for an L⁺ argument: `φ` holds at every world history in `⟨τ|_t`, i.e. at every history
agreeing with `τ` from `t` onwards. -/
def OpastP (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) : Prop :=
  ∀ σ : WorldHistory F, AgreeFrom τ σ t → PlusTruthAt M σ t φ

/-- `OfutP` is the open-future modal applied to an embedded L⁺ formula: the bridge between the
semantic reading above and `OpenTruthAt` on `OpenFormula.ofut (ofPlus φ)`. -/
theorem ofutP_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    OpenTruthAt M τ t (.ofut (ofPlus φ)) ↔ OfutP M τ t φ :=
  forall_congr' fun σ => imp_congr_right fun _ => openTruthAt_ofPlus M σ t φ

/-- `OpastP` is the open-past modal applied to an embedded L⁺ formula, the mirror of
`ofutP_iff`. -/
theorem opastP_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    OpenTruthAt M τ t (.opast (ofPlus φ)) ↔ OpastP M τ t φ :=
  forall_congr' fun σ => imp_congr_right fun _ => openTruthAt_ofPlus M σ t φ

/-- `▷` distributes over conjunction: a universal quantifier commutes with `∧`. No determinedness
and no regularity hypothesis is needed. -/
theorem ofutP_and (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ ψ : PlusFormula) :
    OfutP M τ t (φ.and ψ) ↔ OfutP M τ t φ ∧ OfutP M τ t ψ := by
  constructor
  · intro h
    exact ⟨fun σ hs => ((PlusTruth.and_iff M σ t φ ψ).mp (h σ hs)).1,
      fun σ hs => ((PlusTruth.and_iff M σ t φ ψ).mp (h σ hs)).2⟩
  · rintro ⟨h1, h2⟩ σ hs
    exact (PlusTruth.and_iff M σ t φ ψ).mpr ⟨h1 σ hs, h2 σ hs⟩

/-- `◁` distributes over conjunction, the mirror of `ofutP_and`. -/
theorem opastP_and (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ ψ : PlusFormula) :
    OpastP M τ t (φ.and ψ) ↔ OpastP M τ t φ ∧ OpastP M τ t ψ := by
  constructor
  · intro h
    exact ⟨fun σ hs => ((PlusTruth.and_iff M σ t φ ψ).mp (h σ hs)).1,
      fun σ hs => ((PlusTruth.and_iff M σ t φ ψ).mp (h σ hs)).2⟩
  · rintro ⟨h1, h2⟩ σ hs
    exact (PlusTruth.and_iff M σ t φ ψ).mpr ⟨h1 σ hs, h2 σ hs⟩

/-- `▷⊤` holds: the base case of the conjunctive-normal-form recursion. -/
theorem ofutP_top (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    OfutP M τ t PlusFormula.top :=
  fun σ _ => PlusTruth.top_true M σ t

/-- `◁⊤` holds, the mirror of `ofutP_top`. -/
theorem opastP_top (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    OpastP M τ t PlusFormula.top :=
  fun σ _ => PlusTruth.top_true M σ t

/-! ## The elimination: `▷(α ∨ β) ↔ α ∨ ⊡β` and `◁(α ∨ β) ↔ ⊡α ∨ β` -/

/-- **`▷(α ∨ β) ↔ α ∨ ⊡β`** for `α` past-determined and `β` future-determined, on every regular
task frame. The `→` half pastes `τ`'s past onto each `σ ∈ ⟨τ⟩_t`, obtaining a history in `|τ⟩_t`
on which `α` reads as on `τ` and `β` as on `σ`; the `←` half is the inclusion `|τ⟩_t ⊆ ⟨τ⟩_t`
together with past-determinedness. `[F.IsRegular]` enters through `paste` and nowhere else.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
elimination for them) -/
theorem ofutP_or_iff [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {α β : PlusFormula} (hα : PastDet F α) (hβ : FutDet F β) :
    OfutP M τ t (α.or β) ↔ PlusTruthAt M τ t (α.or (.stab β)) := by
  rw [PlusTruth.or_iff, PlusTruth.stab_iff]
  constructor
  · intro h
    by_cases hA : PlusTruthAt M τ t α
    · exact Or.inl hA
    · refine Or.inr fun σ hsame => ?_
      have hρτ : AgreeUpTo τ (paste τ σ t hsame) t :=
        (agreeUpTo_equivalence t).symm (paste_agreeUpTo τ σ t hsame)
      rcases (PlusTruth.or_iff M _ t α β).mp (h _ hρτ) with hA' | hB'
      · exact absurd ((hα M τ _ t hρτ).mpr hA') hA
      · exact (hβ M _ σ t (paste_agreeFrom τ σ t hsame)).mp hB'
  · rintro (hA | hB) σ hag
    · exact (PlusTruth.or_iff M σ t α β).mpr (Or.inl ((hα M τ σ t hag).mp hA))
    · exact (PlusTruth.or_iff M σ t α β).mpr (Or.inr (hB σ (hag t le_rfl)))

/-- **`◁(α ∨ β) ↔ ⊡α ∨ β`**, the time-reflected elimination: paste `σ`'s past onto `τ`'s future.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
elimination for them) -/
theorem opastP_or_iff [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {α β : PlusFormula} (hα : PastDet F α) (hβ : FutDet F β) :
    OpastP M τ t (α.or β) ↔ PlusTruthAt M τ t ((PlusFormula.stab α).or β) := by
  rw [PlusTruth.or_iff, PlusTruth.stab_iff]
  constructor
  · intro h
    by_cases hB : PlusTruthAt M τ t β
    · exact Or.inr hB
    · refine Or.inl fun σ hsame => ?_
      have hρτ : AgreeFrom τ (paste σ τ t hsame.symm) t :=
        (agreeFrom_equivalence t).symm (paste_agreeFrom σ τ t hsame.symm)
      rcases (PlusTruth.or_iff M _ t α β).mp (h _ hρτ) with hA' | hB'
      · exact (hα M _ σ t (paste_agreeUpTo σ τ t hsame.symm)).mp hA'
      · exact absurd ((hβ M τ _ t hρτ).mpr hB') hB
  · rintro (hA | hB) σ hag
    · exact (PlusTruth.or_iff M σ t α β).mpr (Or.inl (hA σ (hag t le_rfl)))
    · exact (PlusTruth.or_iff M σ t α β).mpr (Or.inr ((hβ M τ σ t hag).mp hB))

/-! ## Separated conjunctive normal forms and their eliminated shapes -/

/-- A separated conjunctive normal form `⋀ᵢ (αᵢ ∨ βᵢ)`, as a list of clauses. -/
def sepForm : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => (c.1.or c.2).and (sepForm L)

/-- `⋀ᵢ (αᵢ ∨ ⊡βᵢ)`: the `▷`-eliminated form of `sepForm L`. -/
def ofutElim : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => (c.1.or (.stab c.2)).and (ofutElim L)

/-- `⋀ᵢ (⊡αᵢ ∨ βᵢ)`: the `◁`-eliminated form of `sepForm L`. -/
def opastElim : List (PlusFormula × PlusFormula) → PlusFormula
  | [] => PlusFormula.top
  | c :: L => ((PlusFormula.stab c.1).or c.2).and (opastElim L)

/-- Every clause of `L` is a (past-determined, future-determined) pair at `F`. -/
def SepClauses (F : TaskFrame) (L : List (PlusFormula × PlusFormula)) : Prop :=
  ∀ c ∈ L, PastDet F c.1 ∧ FutDet F c.2

/-- **The elimination in conjunctive normal form**: `▷` of a conjunction of separated clauses is
the conjunction of their `▷`-eliminated forms. Structural recursion on `L`, with `ofutP_or_iff`
at each clause.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
elimination for them) -/
theorem ofutP_sepForm_iff [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) : ∀ L : List (PlusFormula × PlusFormula), SepClauses F L →
      (OfutP M τ t (sepForm L) ↔ PlusTruthAt M τ t (ofutElim L))
  | [], _ => ⟨fun _ => PlusTruth.top_true M τ t, fun _ => ofutP_top M τ t⟩
  | c :: L, hL => by
    have hc : PastDet F c.1 ∧ FutDet F c.2 := hL c (List.mem_cons.mpr (Or.inl rfl))
    have hL' : SepClauses F L := fun d hd => hL d (List.mem_cons.mpr (Or.inr hd))
    change OfutP M τ t ((c.1.or c.2).and (sepForm L)) ↔
      PlusTruthAt M τ t ((c.1.or (.stab c.2)).and (ofutElim L))
    rw [ofutP_and, PlusTruth.and_iff, ofutP_or_iff M τ t hc.1 hc.2,
      ofutP_sepForm_iff M τ t L hL']

/-- **The open-past elimination in conjunctive normal form**, the mirror of
`ofutP_sepForm_iff`.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
elimination for them) -/
theorem opastP_sepForm_iff [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) : ∀ L : List (PlusFormula × PlusFormula), SepClauses F L →
      (OpastP M τ t (sepForm L) ↔ PlusTruthAt M τ t (opastElim L))
  | [], _ => ⟨fun _ => PlusTruth.top_true M τ t, fun _ => opastP_top M τ t⟩
  | c :: L, hL => by
    have hc : PastDet F c.1 ∧ FutDet F c.2 := hL c (List.mem_cons.mpr (Or.inl rfl))
    have hL' : SepClauses F L := fun d hd => hL d (List.mem_cons.mpr (Or.inr hd))
    change OpastP M τ t ((c.1.or c.2).and (sepForm L)) ↔
      PlusTruthAt M τ t (((PlusFormula.stab c.1).or c.2).and (opastElim L))
    rw [opastP_and, PlusTruth.and_iff, opastP_or_iff M τ t hc.1 hc.2,
      opastP_sepForm_iff M τ t L hL']

/-! ## The translation, conditional on separation -/

/-- **The separation hypothesis over a frame predicate `P`**: every L⁺ formula has a separated
conjunctive normal form equivalent to it on every regular frame satisfying `P`.

This is an explicit named hypothesis standing for cited literature that is **not formalized in
this tree**. For `P := TaskFrame.IsZTime` it is Gabbay's Separation Theorem over the integer flow
([GHR][gabbay1994] vol. 1, Theorem 10.2.9), with `□ψ` and `⊡ψ` subformulas and atoms read as
propositional leaves; for `P := TaskFrame.IsRTime` its Dedekind-complete form (ibid.,
Theorem 10.3.20). It is **false** at `P := fun _ => True` (the unconstrained class) and over
dense flows generally, because `U`/`S` is not separable over `ℚ`. -/
def SeparationOver (P : TaskFrame → Prop) : Prop :=
  ∀ φ : PlusFormula, ∃ L : List (PlusFormula × PlusFormula),
    ∀ (F : TaskFrame), F.IsRegular → P F → SepClauses F L ∧
      ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
        PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t (sepForm L)

/-- The translation of the open-future language into L⁺: homomorphic on the seven shared
constructors, and at `▷φ` (resp. `◁φ`) the `▷`- (resp. `◁`-) eliminated form of a separated
conjunctive normal form of the translation of `φ`. Choosing that form is what makes the
definition noncomputable. -/
noncomputable def tr {P : TaskFrame → Prop} (hsep : SeparationOver P) :
    OpenFormula → PlusFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (tr hsep φ) (tr hsep ψ)
  | .box φ => .box (tr hsep φ)
  | .untl ψ φ => .untl (tr hsep ψ) (tr hsep φ)
  | .snce ψ φ => .snce (tr hsep ψ) (tr hsep φ)
  | .stab φ => .stab (tr hsep φ)
  | .ofut φ => ofutElim (Classical.choose (hsep (tr hsep φ)))
  | .opast φ => opastElim (Classical.choose (hsep (tr hsep φ)))

/-- **The translation is truth-preserving** on every regular `P`-frame, at every model, world
history and time, given separation over `P`. Induction on `φ` generalizing the world history and
the time; the two new cases are the conjunctive-normal-form eliminations. -/
theorem openTruthAt_iff_tr {P : TaskFrame → Prop} (hsep : SeparationOver P)
    {F : TaskFrame} [hF : F.IsRegular] (hP : P F) (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : OpenFormula) :
    OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr hsep φ) := by
  induction φ generalizing τ t with
  | atom p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih => exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab φ ih => exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t
  | ofut φ ih =>
    obtain ⟨hcl, heq⟩ := Classical.choose_spec (hsep (tr hsep φ)) F hF hP
    exact (forall_congr' fun σ => imp_congr_right fun _ => (ih σ t).trans (heq M σ t)).trans
      (ofutP_sepForm_iff M τ t _ hcl)
  | opast φ ih =>
    obtain ⟨hcl, heq⟩ := Classical.choose_spec (hsep (tr hsep φ)) F hF hP
    exact (forall_congr' fun σ => imp_congr_right fun _ => (ih σ t).trans (heq M σ t)).trans
      (opastP_sepForm_iff M τ t _ hcl)

/-- Validity transfers along `tr`, in both directions, over the regular `P`-frames. -/
theorem openValidOnFrames_iff_tr {P : TaskFrame → Prop} (hsep : SeparationOver P)
    (φ : OpenFormula) :
    OpenValidOnFrames (fun F => F.IsRegular ∧ P F) φ ↔
      PlusValidOnFrames (fun F => F.IsRegular ∧ P F) (tr hsep φ) := by
  constructor
  · intro h F hF M τ t
    haveI := hF.1
    exact (openTruthAt_iff_tr hsep hF.2 M τ t φ).mp (h F hF M τ t)
  · intro h F hF M τ t
    haveI := hF.1
    exact (openTruthAt_iff_tr hsep hF.2 M τ t φ).mpr (h F hF M τ t)

/-- **At `.ZTime`**, conditional on separation over ℤ-time frames: open-future-language validity
is L⁺-validity of the translation. `FrameClass.Sat .ZTime F` is `F.IsRegular ∧ F.IsZTime` by
definition. The hypothesis is Gabbay's Separation Theorem over the integer flow and is not
formalized here, so this is a conditional result.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
theorem openValidIn_ztime_iff_tr (hsep : SeparationOver TaskFrame.IsZTime) (φ : OpenFormula) :
    OpenValidIn FormalSystem.ProofSystem.FrameClass.ZTime φ ↔
      PlusValidIn FormalSystem.ProofSystem.FrameClass.ZTime (tr hsep φ) :=
  openValidOnFrames_iff_tr hsep φ

/-- **At `.RTime`**, conditional on separation over the dense Dedekind-complete frames: the same
transfer as `openValidIn_ztime_iff_tr`. The hypothesis is the Dedekind-complete form of the
separation theorem and is not formalized here.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
theorem openValidIn_rtime_iff_tr (hsep : SeparationOver TaskFrame.IsRTime) (φ : OpenFormula) :
    OpenValidIn FormalSystem.ProofSystem.FrameClass.RTime φ ↔
      PlusValidIn FormalSystem.ProofSystem.FrameClass.RTime (tr hsep φ) :=
  openValidOnFrames_iff_tr hsep φ

/-! ## The two split-free ends of the elimination

`▷` of a past-determined formula is the formula, and `▷` of a future-determined formula is `⊡` of
it. Neither needs separation, and the first needs no frame axiom either. -/

/-- `▷α ↔ α` for `α` past-determined: the `α`-end of the elimination. Takes no regularity
instance — reflexivity of `AgreeUpTo` and past-determinedness suffice, with no pasting. -/
theorem ofutP_of_pastDet (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {α : PlusFormula} (hα : PastDet F α) : OfutP M τ t α ↔ PlusTruthAt M τ t α :=
  ⟨fun h => h τ ((agreeUpTo_equivalence t).refl τ), fun h σ hag => (hα M τ σ t hag).mp h⟩

/-- `▷β ↔ ⊡β` for `β` future-determined: the `β`-end of the elimination, on every regular task
frame. The forward direction pastes, which is where regularity enters. -/
theorem ofutP_of_futDet [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {β : PlusFormula} (hβ : FutDet F β) : OfutP M τ t β ↔ PlusTruthAt M τ t (.stab β) := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h σ hsame
    have hρτ : AgreeUpTo τ (paste τ σ t hsame) t :=
      (agreeUpTo_equivalence t).symm (paste_agreeUpTo τ σ t hsame)
    exact (hβ M _ σ t (paste_agreeFrom τ σ t hsame)).mp (h _ hρτ)
  · intro h σ hag
    exact h σ (hag t le_rfl)

/-! ## Transfer corollaries: decidability and completeness reductions

Every declaration in this section is a **reduction**, not a result about the open-future
language: each one takes the corresponding L⁺ fact as an explicit hypothesis and no such
hypothesis is discharged anywhere in this tree. See `## What is NOT proved here` above for the
full list of undischarged antecedents. -/

/-- **Given** a translation `T` with `OpenValidIn fc φ ↔ PlusValidIn fc (T φ)` and a decision
procedure for L⁺ validity at `fc`, open-language validity at `fc` is decidable. This is the
generic form of the reduction: nothing here supplies either hypothesis, and in particular no
`Decidable (PlusValidIn fc ψ)` is established at any frame class in this tree.

The hypothesis does real work: because `T` is an explicit argument rather than the noncomputable
`tr`, this compiles as a plain `def` and its `Decidable` instance genuinely runs `hdec` on
`T φ`.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
def decidableOpenValidIn_of_translation (fc : FormalSystem.ProofSystem.FrameClass)
    (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (hdec : ∀ ψ : PlusFormula, Decidable (PlusValidIn fc ψ)) (φ : OpenFormula) :
    Decidable (OpenValidIn fc φ) :=
  letI := hdec (T φ)
  decidable_of_iff (PlusValidIn fc (T φ)) (hT φ).symm

/-- **Given** a translation `T` and a `Bool`-valued decider `d` for L⁺ formulas, the composite
`d ∘ T` is the induced `Bool`-valued decider for the open-future language. A definition, not a
result: it is correct exactly to the extent `d` is, which `openDecider_correct` states. No `d`
with the required property is exhibited anywhere in this tree.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
def openDecider (T : OpenFormula → PlusFormula) (d : PlusFormula → Bool) :
    OpenFormula → Bool := fun φ => d (T φ)

/-- **Given** a translation `T` transferring validity and a decider `d` correct for L⁺ validity at
`fc`, `openDecider T d` is correct for open-language validity at `fc`. Both hypotheses are
undischarged: no correct `d` is constructed here, at `fc := .ZTime` or anywhere else.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
theorem openDecider_correct (fc : FormalSystem.ProofSystem.FrameClass)
    (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (d : PlusFormula → Bool) (hd : ∀ ψ : PlusFormula, d ψ = true ↔ PlusValidIn fc ψ)
    (φ : OpenFormula) : openDecider T d φ = true ↔ OpenValidIn fc φ :=
  (hd (T φ)).trans (hT φ).symm

/-- **Given** separation over ℤ-time frames, the translation slot of the reductions above is
inhabited at `.ZTime`, by `tr hsep`. Existence only: this says the generic reductions apply at
`.ZTime` once separation is granted, and nothing about whether their other hypotheses hold.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
theorem exists_translation_ztime (hsep : SeparationOver TaskFrame.IsZTime) :
    ∃ T : OpenFormula → PlusFormula,
      ∀ φ : OpenFormula, OpenValidIn FormalSystem.ProofSystem.FrameClass.ZTime φ ↔
        PlusValidIn FormalSystem.ProofSystem.FrameClass.ZTime (T φ) :=
  ⟨tr hsep, openValidIn_ztime_iff_tr hsep⟩

/-- **Given** separation over the dense Dedekind-complete frames, the mirror of
`exists_translation_ztime` at `.RTime`.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
theorem exists_translation_rtime (hsep : SeparationOver TaskFrame.IsRTime) :
    ∃ T : OpenFormula → PlusFormula,
      ∀ φ : OpenFormula, OpenValidIn FormalSystem.ProofSystem.FrameClass.RTime φ ↔
        PlusValidIn FormalSystem.ProofSystem.FrameClass.RTime (T φ) :=
  ⟨tr hsep, openValidIn_rtime_iff_tr hsep⟩

/-- **Given** separation over ℤ-time frames and decidability of L⁺ validity at `.ZTime` **for the
one formula** `tr hsep φ`, open-language validity of `φ` at `.ZTime` is decidable. The hypothesis
is per-formula deliberately: the uniform form is forced `noncomputable` and is then inhabited
with no hypothesis at all (see `## What is NOT proved here`). `Decidable (PlusValidIn
FrameClass.ZTime _)` is stated nowhere in this tree, so this reduction is never applied here.

`decidable_of_iff`'s first explicit argument is supplied by hand: `PlusValidIn` does not unfold
under instance search.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
def decidableOpenValidZTimeOfTr
    (hsep : SeparationOver TaskFrame.IsZTime) (φ : OpenFormula)
    (hdec : Decidable
      (PlusValidIn FormalSystem.ProofSystem.FrameClass.ZTime (tr hsep φ))) :
    Decidable (OpenValidIn FormalSystem.ProofSystem.FrameClass.ZTime φ) :=
  letI := hdec
  decidable_of_iff (PlusValidIn FormalSystem.ProofSystem.FrameClass.ZTime (tr hsep φ))
    (openValidIn_ztime_iff_tr hsep φ).symm

/-- **Given** separation over the dense Dedekind-complete frames and decidability of L⁺ validity
at `.RTime` for the one formula `tr hsep φ`, the mirror of `decidableOpenValidZTimeOfTr`.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
def decidableOpenValidRTimeOfTr
    (hsep : SeparationOver TaskFrame.IsRTime) (φ : OpenFormula)
    (hdec : Decidable
      (PlusValidIn FormalSystem.ProofSystem.FrameClass.RTime (tr hsep φ))) :
    Decidable (OpenValidIn FormalSystem.ProofSystem.FrameClass.RTime φ) :=
  letI := hdec
  decidable_of_iff (PlusValidIn FormalSystem.ProofSystem.FrameClass.RTime (tr hsep φ))
    (openValidIn_rtime_iff_tr hsep φ).symm

/-- **Given** a translation `T` transferring validity at `fc` and a relation `Der` on L⁺ formulas
that is complete for L⁺ validity at `fc`, every `fc`-valid open-language formula has its
translation `Der`-derivable. `Der` is an abstract `PlusFormula → Prop`, which keeps this module's
import surface unchanged; instantiating it at `PlusDerivable fc []` is a one-liner at the point of
use. Completeness of any L⁺ proof system is open at every frame class, so `hcomp` is undischarged
and no completeness result for the open-future language follows from this.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
theorem openComplete_of_plusComplete_in {fc : FormalSystem.ProofSystem.FrameClass}
    (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (Der : PlusFormula → Prop)
    (hcomp : ∀ ψ : PlusFormula, PlusValidIn fc ψ → Der ψ)
    (φ : OpenFormula) (hv : OpenValidIn fc φ) : Der (T φ) :=
  hcomp _ ((hT φ).mp hv)

/-- **Given** a translation `T` transferring validity at `fc` and a relation `Der` sound for L⁺
validity at `fc`, `Der`-derivability of a translation yields open-language validity of the
original. The soundness mirror of `openComplete_of_plusComplete_in`, free from the same `iff`;
`hsound` is likewise undischarged here.

Paper: — (formalization-native; the manuscript sets the restricted modals aside and states no
translation for them) -/
theorem openValid_of_plusSound {fc : FormalSystem.ProofSystem.FrameClass}
    (T : OpenFormula → PlusFormula)
    (hT : ∀ φ : OpenFormula, OpenValidIn fc φ ↔ PlusValidIn fc (T φ))
    (Der : PlusFormula → Prop)
    (hsound : ∀ ψ : PlusFormula, Der ψ → PlusValidIn fc ψ)
    (φ : OpenFormula) (hd : Der (T φ)) : OpenValidIn fc φ :=
  (hT φ).mpr (hsound _ hd)

end FormalSystem.Metalogic.Expressiveness
