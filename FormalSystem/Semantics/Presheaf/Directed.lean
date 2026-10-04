/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.Presheaf.Behavior
import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Semantics.Extension.Completion

/-!
# *Totality* and *Directed Gluing*: both clauses as wrappers on `thm:extension`

`app:presheaf-dictionary`'s remaining two clauses are discharged here, and the point of the module
is that **both are wrappers** on the Extension Theorem rather than new mathematics. *Totality* says
every restriction map `Beh(F)(l) → Beh(F)(m)` of the behavior presheaf is surjective. *Directed
Gluing* says compatible sections over an upward directed family of subwindows of `[0, l]` extend to
a section over `[0, l]`, uniquely when the family covers it. Each is three steps long: translate a
section onto its window (`place`), extend to a possible world (`thm:extension`), cut the world back
down to `[0, l]` (`ofWorld`). `restrict_ofWorld` is the bridge both share.

The only piece of genuinely new machinery is the **directed union** `directedSup`: `thm:extension`
consumes a single partial history, so *Directed Gluing* has to union the translates first.

Each clause is stated as a binder-free **engine** taking
`∀ τ, PartialHistory.IsRestriction τ` as an explicit hypothesis, plus instantiations that supply
that hypothesis from a different source. The split is load-bearing, not tidiness: it buys the
choice **attribution** recorded below, it buys the minimal-hypothesis variants for one line each,
and it is the delegation pattern C34a recognizes.

## Main Definitions

- `place`: the translate — a section over `m` placed at offset `p`, as a partial history with
  domain `Interval p (p + m)` and states `t ↦ σ (t - p)`.
- `ofWorld`: the cut — a possible world restricted to `[0, l]`, as a section of `Beh F l`.
- `directedSup`: the union of a directed family of partial histories. `noncomputable`, as
  `PartialHistory.chainSup` is.

## Main Results

- `place_mem`: every point of `[p, p + m]` is in the translate's domain.
- `restrict_ofWorld`: the bridge. If a possible world extends `place p hm σ`, then restricting its
  cut over `[0, l]` along the translation by `p` returns `σ` exactly.
- `totality_of_isRestriction`: *Totality*'s **engine** — surjectivity of `Beh.restrict`, with the
  extension property taken as an explicit hypothesis. `Constraints consumed: None`.
- `totality_clause`: the clause at `[F.IsRegular]`, via
  `PartialHistory.isRestriction_of_isRegular`.
- `totality_clause_site`: the same in the site's own vocabulary, along a morphism `f : Tr l' l`.
- `totality_of_isZTime`, `totality_of_completion`: the two minimal-hypothesis forms, over discrete
  ℤ-time and at bare *Completion*. Both are **Saturation-free** — which is a statement about
  `def:frame`'s fourth constraint and *not* a claim of choice-freedom: both still route through
  Zorn's lemma and both measure `Classical.choice` (see the record below).
- `directed_states_agree`: two members of a directed family agree wherever both are defined — the
  directed analogue of `PartialHistory.chain_states_agree`, with a common upper bound in place of
  `IsChain.total`.
- `le_directedSup`: every member of a directed family is below its union.
- `place_le_place`: the paper's "any two restrict a third" bridge, from its two hypotheses
  (directedness of the windows, compatibility on overlaps) to the single `Directed (· ≤ ·)` the
  proof consumes.
- `directed_gluing_of_isRestriction`: *Directed Gluing*'s existence half, in engine form.
  `Constraints consumed: None`.
- `directed_gluing_unique`: the uniqueness half under covering. It needs neither directedness nor
  any frame constraint.
- `directed_gluing_clause`: the clause itself, as the `∃!` the two halves package.

## The choice record

Recorded explicitly, rather than left implicit in the proof terms, because the split between the
clauses is the substantive finding. Every row below was measured in this round with `lean_verify`
or `#print axioms`, not inferred.

| Declaration | Measured axioms |
|---|---|
| `sheaf_clause` (binary *Sheaf*) | `[propext, Quot.sound]` |
| `ofWorld`, `directed_states_agree` | `[propext]` |
| `place`, `place_le_place`, `restrict_ofWorld` | `[propext, Quot.sound]` |
| `totality_of_isRestriction` (engine) | `[propext, Quot.sound]` |
| `PartialHistory.extension` | `[propext, Classical.choice, Quot.sound]` |
| `totality_clause`, `totality_clause_site` | `[propext, Classical.choice, Quot.sound]` |
| `totality_of_isZTime`, `totality_of_completion` | `[propext, Classical.choice, Quot.sound]` |
| `directedSup`, `le_directedSup` | `[propext, Classical.choice]` |
| `directed_gluing_unique` | `[propext, Quot.sound]` |
| `directed_gluing_of_isRestriction` (engine) | `[propext, Classical.choice, Quot.sound]` |
| `directed_gluing_clause` | `[propext, Classical.choice, Quot.sound]` |

Reading the four values: `[propext]` and `[propext, Quot.sound]` are **choice-free**;
`[propext, Classical.choice]` is the directed union's own non-constructivity; and
`[propext, Classical.choice, Quot.sound]` is everything that reaches Zorn's lemma, directly or
through the union.

**The engine rows are what make this a record rather than an observation.** *Totality*'s engine is
measured choice-free *with the extension property as a hypothesis*, so the `Classical.choice` in
`totality_clause` is **attributable** — exactly to `thm:extension` and to nothing in the geometry.
*Directed Gluing* admits no such attribution, and the sharpest evidence is the contrast between the
two engine rows: `directed_gluing_of_isRestriction` measures `Classical.choice` *even with the
extension property hypothesized away*, because `directedSup` is independently non-constructive.
Its choice is **doubly** sourced. That is a sharper statement than "*Sheaf* is choice-free,
*Directed Gluing* is not".

**The non-constructivity of the directed case is a mathematical obstruction, not a Lean artifact.**
`app:gluing`'s footnote supplies a counterexample proving *Saturation* is genuinely required there:
over `D = ℚ` with `W = {q ∈ ℚ : q > 0}` and `r ⇒ₓ r'` iff `|r' − r| ≤ x`, the restrictions of
`τ(t) = 1 − t` to `(0, b]` for `b < 1` form an increasing chain whose union admits no value at time
`1`. This is why the paper writes "in ZFC" at this clause and "choice-free" at the binary one, and
it is why the binary case's choice-freeness **must not** be imported into the directed case.

## Implementation Notes

**The translate is written against `Interval p (p + m)`, not through `PartialHistory.timeShift`.**
`timeShift`'s domain at `z` is `τ.domain (z + Δ)`, so placing a section at offset `p` would mean
`Δ = -p` and every subsequent arithmetic step would carry a negation. Written directly against the
interval, `place`'s domain equations stay `rfl` and the arithmetic stays negation-free. The one
step a reader may not expect is `respects_task`, which moves `(t - p) - (s - p)` to `t - s` by
`sub_sub_sub_cancel_right`.

**`ofWorld`'s section condition is `fun _ => Iff.rfl`, and that is not luck.** `Beh` carries a
pointwise `Iff` against the same predicate `Interval` is built from — the design
`Semantics/Presheaf/Behavior.lean`'s Implementation Notes flag as load-bearing — so the cut's
domain obligation discharges definitionally. Restating `Beh` by a domain *equality* would break it.

**`add_le_add (le_refl p) h`, never `(add_le_add_iff_left p).mpr h`.** The two prove the same goal
`p + r ≤ p + m` from `r ≤ m`, and the second **measures `Classical.choice`** (measured, not
suspected). Substituting it anywhere in this module leaves the build green while silently
destroying the attribution result above, since *Totality*'s engine row would then read
`Classical.choice` and there would be nothing left to attribute. The chosen idiom is the one
`Beh.restrict` already uses in `Behavior.lean`. The same caution applies to any `*_iff_*` round
trip on a path whose axiom measurement is load-bearing: when a measurement is the result, measure
the arithmetic helpers too.

**`directedSup` is here rather than beside `chainSup`, and that is a recorded deferral.** Its
natural home is `Semantics/PartialHistoryOrder.lean`, next to `PartialHistory.chainSup`, from which
`chainSup` could then be derived as the `IsChain` special case — a chain is directed, and
`chain_states_agree` is `directed_states_agree` at `IsChain.total`. Consolidating it there is
deliberately **not** done: the history-order module is outside this cluster's remit, exactly as
`Behavior.lean`'s `partialHistory_ext` records for `PartialHistory.lean`. Anything else needing a
directed union should move this definition down rather than write a second copy.

**`states_eq_of_eq` is imported, not restated.** `Semantics/Presheaf/Sheaf.lean` declares it at top
level in this same namespace, so a local copy under the same name is a hard duplicate-declaration
error rather than a shadowing. Importing `Presheaf.Sheaf` costs nothing — it imports only
`FormalSystem.Init` and `Presheaf.Behavior`, both of which this module needs anyway. The lemma is
what `directed_gluing_unique` needs: `rw [h i]` there fails with "motive is not type correct",
because the goal's domain witness mentions the section being rewritten.

**Paper state: the source appendix is cut.** As for the three sibling modules, the dictionary
anchors cited below live in `app:Structure`, which the paper **cut in full** under an explicit
`% SECTION CUT` record and whose surviving commented block carries a bare `% CHECK` — the author
has not finished reviewing this material. They resolve against
`docs/reference/paper-definitions-of-record.md`, where each carries a `DANGLING` row, and not
against a live `\label{}`; `scripts/check-paper-definitions.sh --resolve` structurally cannot pin a
commented-out label, so none is pinned. `thm:extension` and `cor:occurrence`, by contrast, are live
and pinned, and are cited plainly.

## References

* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  §3.2 — the behavior sheaf, of whose structure maps surjectivity is the task-frame reading
* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Totality* and *Directed
  Gluing* clauses `totality_clause` and `directed_gluing_clause` discharge. **`DANGLING`**: cut
  from the paper with `app:Structure` and recorded in
  `docs/reference/paper-definitions-of-record.md`
* JPL paper `def:behavior-presheaf` — `Beh(F)(l)` and restriction along `Tr p`. **`DANGLING`**, as
  above
* JPL paper `app:Structure` — the cut appendix containing both. **`DANGLING`**, as above
* JPL paper `thm:extension` — every partial history is extended by some possible world; the single
  result both clauses of this module consume
* JPL paper `cor:occurrence` — the occurrence corollary drawn off `thm:extension`, whose footnote
  records that the route through Zorn's lemma is what makes the derivation a theorem of ZFC
* JPL paper `app:gluing` — the gluing lemma for two convex histories agreeing on their overlap,
  whose footnote carries the ℚ counterexample showing *Saturation* is genuinely required in the
  directed case. Cited as a **pointer only**: its record row is `LIVE-UNPINNED` precisely because
  no docstring quotes its text, and this one does not either
* `FormalSystem/Semantics/Extension/Extension.lean` — `PartialHistory.extension`,
  `PartialHistory.isRestriction_of_isRegular`
* `FormalSystem/Semantics/Extension/Completion.lean` — `extension_of_completion`,
  `extension_of_isZTime`, the two minimal-hypothesis sources of the engine's hypothesis
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrict`, `Beh.restrictTr`,
  `partialHistory_ext`
* `FormalSystem/Semantics/Presheaf/Sheaf.lean` — `states_eq_of_eq`, and `sheaf_clause`, the binary
  companion clause whose choice-freeness this module's directed one does not share
* `FormalSystem/Semantics/Presheaf/Site.lean` — `Interval`, `Obj`, `Tr`
* `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory`, `WorldHistory`,
  `PartialHistory.restrict`, `states_eq_of_time_eq`
* `FormalSystem/Semantics/PartialHistoryOrder.lean` — the extension preorder, `le_def`,
  `chain_states_agree` and `chainSup`, the shape `directedSup` generalizes
-/

namespace FormalSystem.Semantics.Presheaf

variable {F : TaskFrame}

/-! ## The translate -/

/--
**The translate**: a section over `m`, placed at offset `p`.

Its domain is the window `Interval p (p + m)` and it reads `σ` at the shifted time `t - p`. This is
the partial history `thm:extension` is applied to, both in *Totality* and — after taking a directed
union of translates — in *Directed Gluing*.
-/
def place {m : F.Duration} (p : F.Duration) (hm : 0 ≤ m) (σ : Beh F m) : PartialHistory F where
  domain := Interval p (p + m)
  nonempty_domain := ⟨p, le_refl p, le_add_of_nonneg_right hm⟩
  states := fun t ht =>
    σ.val.states (t - p) (Beh.mem_dom σ (sub_nonneg.mpr ht.1) (sub_le_iff_le_add'.mpr ht.2))
  respects_task := by
    intro s t hs ht
    have h := σ.val.respects_task (s - p) (t - p)
      (Beh.mem_dom σ (sub_nonneg.mpr hs.1) (sub_le_iff_le_add'.mpr hs.2))
      (Beh.mem_dom σ (sub_nonneg.mpr ht.1) (sub_le_iff_le_add'.mpr ht.2))
    rwa [sub_sub_sub_cancel_right] at h

/-- Every point of the window `[p, p + m]` is in the translate's domain. -/
theorem place_mem {m : F.Duration} (p : F.Duration) (hm : 0 ≤ m) (σ : Beh F m)
    {t : F.Duration} (h0 : p ≤ t) (h1 : t ≤ p + m) : (place p hm σ).domain t :=
  ⟨h0, h1⟩

/-! ## The cut -/

/--
**The cut**: a possible world, restricted to `[0, l]`, as a section of `Beh F l`.

The section condition discharges by `fun _ => Iff.rfl` because `Beh` carries a pointwise `Iff`
against the very predicate `Interval 0 l` is — see the module's Implementation Notes.
-/
def ofWorld (h : WorldHistory F) (l : F.Duration) (hl : 0 ≤ l) : Beh F l :=
  ⟨PartialHistory.restrict h (Interval 0 l) ⟨0, le_refl 0, hl⟩, fun _ => Iff.rfl⟩

/--
**The bridge.** If a possible world `h` extends the translate of `σ` at offset `p`, then cutting
`h` down to `[0, l]` and restricting along the translation by `p` returns `σ` — on the nose, not
merely pointwise.

The only step worth naming moves a state across `p + r - p = r` through
`PartialHistory.states_eq_of_time_eq`, the same device `Behavior.lean`'s `restrict_id` and
`restrict_comp` use.
-/
theorem restrict_ofWorld {l m : F.Duration} (p : F.Duration) (hp : 0 ≤ p) (hm : 0 ≤ m)
    (hfit : p + m ≤ l) (hl : 0 ≤ l) (σ : Beh F m) (h : WorldHistory F)
    (hext : place p hm σ ≤ h.val) :
    Beh.restrict p m hp hm hfit (ofWorld h l hl) = σ := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ m) = σ.val.domain z
    exact propext (σ.property z).symm
  · intro r hr h'
    have hdom : (place p hm σ).domain (p + r) :=
      place_mem p hm σ (le_add_of_nonneg_right hr.1) (add_le_add (le_refl p) hr.2)
    have hag := (PartialHistory.le_def.mp hext).agree (p + r) hdom
    have hL : (Beh.restrict p m hp hm hfit (ofWorld h l hl)).val.states r hr
        = σ.val.states (p + r - p)
            (Beh.mem_dom σ (sub_nonneg.mpr hdom.1) (sub_le_iff_le_add'.mpr hdom.2)) := hag
    rw [hL]
    exact PartialHistory.states_eq_of_time_eq σ.val (p + r - p) r (add_sub_cancel_left p r) _ h'

/-! ## The *Totality* clause -/

/--
**The *Totality* clause, in engine form.** Every restriction map of the behavior presheaf is
surjective, with the extension property taken as an **explicit hypothesis** rather than read off a
frame bundle.

Given a target section `σ` over `m`, the witness is the cut of any possible world extending
`place p hm σ`, and `restrict_ofWorld` is the verification. The geometry is all there is: this
declaration measures `[propext, Quot.sound]`, with **no `Classical.choice`**, which is exactly what
makes the choice in `totality_clause` attributable to `thm:extension` rather than merely
co-present with it.

Constraints consumed: None
-/
theorem totality_of_isRestriction (F : TaskFrame)
    (hext : ∀ τ : PartialHistory F, PartialHistory.IsRestriction τ)
    {l m : F.Duration} (p : F.Duration) (hp : 0 ≤ p) (hm : 0 ≤ m) (hfit : p + m ≤ l) :
    Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m) := by
  intro σ
  obtain ⟨h, hagree⟩ := hext (place p hm σ)
  have hl : 0 ≤ l := le_trans (le_trans hp (le_add_of_nonneg_right hm)) hfit
  exact ⟨ofWorld h l hl,
    restrict_ofWorld p hp hm hfit hl σ h (PartialHistory.le_def.mpr hagree)⟩

/--
**The *Totality* clause at `[F.IsRegular]`.** The engine, with the extension property supplied by
`thm:extension` in the form `PartialHistory.isRestriction_of_isRegular`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem totality_clause (F : TaskFrame) [F.IsRegular] {l m : F.Duration} (p : F.Duration)
    (hp : 0 ≤ p) (hm : 0 ≤ m) (hfit : p + m ≤ l) :
    Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m) :=
  totality_of_isRestriction F (PartialHistory.isRestriction_of_isRegular F) p hp hm hfit

/--
**The *Totality* clause, at the site.** The same surjectivity along a morphism `f : Tr l' l` of
`Int(D)` rather than at raw offsets. The morphism supplies the offset and both order facts, so this
is `totality_clause` read through the definition of `Beh.restrictTr` — no transport, no cast.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem totality_clause_site (F : TaskFrame) [F.IsRegular] {l' l : Obj F.Duration} (f : Tr l' l) :
    Function.Surjective (Beh.restrictTr f : Beh F l.val → Beh F l'.val) :=
  totality_clause F f.shift f.shift_nonneg l'.property f.shift_add_le

/--
**The *Totality* clause over discrete ℤ-time, without *Saturation*.** `extension_of_isZTime`
supplies the engine's hypothesis from a successor/predecessor-with-Archimedean-reach duration
order, where the nearest-time argument replaces the appeal to Zorn's lemma.

Constraints consumed: Compositionality, Seriality, Limit
-/
theorem totality_of_isZTime (F : TaskFrame) (hZ : F.IsZTime)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) {l m : F.Duration} (p : F.Duration)
    (hp : 0 ≤ p) (hm : 0 ≤ m) (hfit : p + m ≤ l) :
    Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m) :=
  totality_of_isRestriction F
    (fun τ => PartialHistory.extension_of_isZTime hZ hcomp hser hlim τ) p hp hm hfit

/--
**The *Totality* clause at bare *Completion*.** The weakest hypothesis form: *Completion* is
strictly weaker than *Saturation*, and `extension_of_completion` is where the repository records
that sharpness. *Compositionality* drops out entirely.

Constraints consumed: Seriality, Limit
-/
theorem totality_of_completion (F : TaskFrame) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (hC : PartialHistory.Completion F)
    {l m : F.Duration} (p : F.Duration) (hp : 0 ≤ p) (hm : 0 ≤ m) (hfit : p + m ≤ l) :
    Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m) :=
  totality_of_isRestriction F
    (fun τ => PartialHistory.extension_of_completion hser hlim hC τ) p hp hm hfit

/-! ## The directed union

`thm:extension` consumes a **single** partial history, so *Directed Gluing* needs the union of the
translates and there is no route around it. `PartialHistoryOrder.lean`'s `chainSup` is the shape
this copies, but it is not reusable: it is stated for `IsChain`, and the family here is only
`Directed (· ≤ ·)`. Its proof uses `hc.total` solely to find a comparison, and a directed family
supplies a common upper bound instead, so the generalization is mechanical.
-/

/-- Two members of a directed family agree wherever both are defined. The directed analogue of
`PartialHistory.chain_states_agree`, with a common upper bound in place of `IsChain.total`. This is
what makes `directedSup`'s `Classical.choose` of a witnessing index well defined. -/
theorem directed_states_agree {I : Type*} {fam : I → PartialHistory F}
    (hdir : Directed (· ≤ ·) fam) (i j : I) (t : F.Duration)
    (hi : (fam i).domain t) (hj : (fam j).domain t) :
    (fam i).states t hi = (fam j).states t hj := by
  obtain ⟨k, hik, hjk⟩ := hdir i j
  have e1 := (PartialHistory.le_def.mp hik).agree t hi
  have e2 := (PartialHistory.le_def.mp hjk).agree t hj
  exact e1.symm.trans e2

/--
**The union of a directed family of partial histories.**

Its domain is the union of the members' domains and its state at a time is read off *some* member
containing that time, picked by `Classical.choose`; `directed_states_agree` is what makes that pick
irrelevant. Task-respect routes the two chosen witnesses through a common upper bound.

`[Nonempty I]` is required for exactly the reason `chainSup` requires a nonempty chain:
`PartialHistory.nonempty_domain` is a **field**, so the empty family's union has empty domain and is
not a partial history at all.

This declaration measures `[propext, Classical.choice]` **on its own**, which is what makes
*Directed Gluing*'s dependence on choice doubly sourced rather than attributable to
`thm:extension` alone — see the choice record in this module's docstring.
-/
noncomputable def directedSup {I : Type*} [Nonempty I]
    (fam : I → PartialHistory F) (hdir : Directed (· ≤ ·) fam) : PartialHistory F where
  domain t := ∃ i, (fam i).domain t
  nonempty_domain := by
    obtain ⟨t, ht⟩ := (fam (Classical.arbitrary I)).nonempty_domain
    exact ⟨t, Classical.arbitrary I, ht⟩
  states t ht := (fam (Classical.choose ht)).states t (Classical.choose_spec ht)
  respects_task := by
    intro s t hs ht
    obtain ⟨k, hsk, htk⟩ := hdir (Classical.choose hs) (Classical.choose ht)
    have hs' : (fam k).domain s :=
      (PartialHistory.le_def.mp hsk).subset s (Classical.choose_spec hs)
    have ht' : (fam k).domain t :=
      (PartialHistory.le_def.mp htk).subset t (Classical.choose_spec ht)
    have hrel := (fam k).respects_task s t hs' ht'
    rwa [(PartialHistory.le_def.mp hsk).agree s (Classical.choose_spec hs),
      (PartialHistory.le_def.mp htk).agree t (Classical.choose_spec ht)] at hrel

/-- Every member of a directed family is below its union. -/
theorem le_directedSup {I : Type*} [Nonempty I] (fam : I → PartialHistory F)
    (hdir : Directed (· ≤ ·) fam) (i : I) : fam i ≤ directedSup fam hdir :=
  ⟨fun _t ht => ⟨i, ht⟩,
   fun _t ht => directed_states_agree hdir _ i _t
     (Classical.choose_spec (⟨i, ht⟩ : ∃ j, (fam j).domain _t)) ht⟩

/-! ## The *Directed Gluing* clause -/

/--
**The paper's own directedness hypothesis, discharged.** If the `i`-th window sits inside the
`k`-th and `σ` is `σ'` restricted along that inclusion, then the `i`-th translate is below the
`k`-th in the extension order.

This is the bridge from the paper's two hypotheses — upward directedness of the subintervals, and
compatibility of the sections on overlaps — to the single `Directed (· ≤ ·)` the proof below
actually consumes. The paper's phrase is "any two of which restrict a third since the family is
upward directed"; `hres` is the restriction, and the conclusion is the `≤`.

The shift-fit `p - p' + m ≤ m'` is taken as an explicit named hypothesis rather than as an inline
`by` term, so that a caller discharging it can see what it has to prove.
-/
theorem place_le_place {m m' : F.Duration} (p p' : F.Duration)
    (hm : 0 ≤ m) (hm' : 0 ≤ m') (σ : Beh F m) (σ' : Beh F m')
    (hple : p' ≤ p) (hsub : 0 ≤ p - p') (hshift : p - p' + m ≤ m')
    (hres : σ = Beh.restrict (p - p') m hsub hm hshift σ') :
    place p hm σ ≤ place p' hm' σ' := by
  subst hres
  have hwin : p + m ≤ p' + m' := by
    have h := add_le_add (le_refl p') hshift
    have harith : p' + (p - p' + m) = p + m := by abel
    rwa [harith] at h
  refine ⟨fun t ht => ⟨le_trans hple ht.1, le_trans ht.2 hwin⟩, ?_⟩
  intro t _ht
  exact PartialHistory.states_eq_of_time_eq σ'.val (t - p') (p - p' + (t - p)) (by abel) _ _

/--
**The *Directed Gluing* clause, existence half, in engine form.** Compatible sections over an
upward directed family of subwindows of `[0, l]` extend to a section over `[0, l]`, with the
extension property taken as an explicit hypothesis.

Three steps: union the translates (`directedSup`), extend the union to a possible world (the
hypothesis), cut the world down to `[0, l]` (`ofWorld`). `restrict_ofWorld` then applies at *every*
index, because each translate is below the union (`le_directedSup`) and the union is below the
world.

Constraints consumed: None
-/
theorem directed_gluing_of_isRestriction (F : TaskFrame)
    (hext : ∀ τ : PartialHistory F, PartialHistory.IsRestriction τ)
    {I : Type*} [Nonempty I] {l : F.Duration}
    (p m : I → F.Duration) (hp : ∀ i, 0 ≤ p i) (hm : ∀ i, 0 ≤ m i)
    (hfit : ∀ i, p i + m i ≤ l) (σ : ∀ i, Beh F (m i))
    (hdir : Directed (· ≤ ·) fun i => place (p i) (hm i) (σ i)) :
    ∃ τ : Beh F l, ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ = σ i := by
  obtain ⟨h, hagree⟩ := hext (directedSup (fun i => place (p i) (hm i) (σ i)) hdir)
  have hl : 0 ≤ l :=
    le_trans (le_trans (hp (Classical.arbitrary I))
      (le_add_of_nonneg_right (hm (Classical.arbitrary I)))) (hfit (Classical.arbitrary I))
  refine ⟨ofWorld h l hl, fun i => ?_⟩
  refine restrict_ofWorld (p i) (hp i) (hm i) (hfit i) hl (σ i) h ?_
  exact le_trans (le_directedSup _ hdir i) (PartialHistory.le_def.mpr hagree)

/--
**The *Directed Gluing* clause, uniqueness half.** When the family **covers** `[0, l]`, a section
over `l` restricting to the given family is unique. No directedness and no frame constraint are
needed here: sections are functions on points, and covering is what supplies a point of every
window.

At each `t ∈ [0, l]` a covering index `i` is picked and both sections are read at `t - p i` through
`states_eq_of_eq` (imported from `Presheaf.Sheaf`), then moved back across `p i + (t - p i) = t`.
Reading them through `rw [h i]` instead fails with "motive is not type correct" — the goal's domain
witness mentions the section being rewritten — which is the whole reason `states_eq_of_eq` exists.
-/
theorem directed_gluing_unique {I : Type*} {l : F.Duration}
    (p m : I → F.Duration) (hp : ∀ i, 0 ≤ p i) (hm : ∀ i, 0 ≤ m i)
    (hfit : ∀ i, p i + m i ≤ l)
    (hcov : ∀ t, 0 ≤ t → t ≤ l → ∃ i, p i ≤ t ∧ t ≤ p i + m i)
    (σ : ∀ i, Beh F (m i)) (τ τ' : Beh F l)
    (h : ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ = σ i)
    (h' : ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ' = σ i) :
    τ = τ' := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    exact propext ((τ.property z).trans (τ'.property z).symm)
  · intro r hr hr'
    obtain ⟨i, hi1, hi2⟩ := hcov r ((τ.property r).mp hr).1 ((τ.property r).mp hr).2
    have hd : (0 : F.Duration) ≤ r - p i ∧ r - p i ≤ m i :=
      ⟨sub_nonneg.mpr hi1, sub_le_iff_le_add'.mpr hi2⟩
    have hmem := Beh.mem_dom (σ i) hd.1 hd.2
    have hpr : τ.val.domain (p i + (r - p i)) := by rw [add_sub_cancel]; exact hr
    have hpr' : τ'.val.domain (p i + (r - p i)) := by rw [add_sub_cancel]; exact hr'
    have e1 := states_eq_of_eq (h i) (r - p i) hd hmem
    have e2 := states_eq_of_eq (h' i) (r - p i) hd hmem
    rw [Beh.restrict_states (p i) (m i) (hp i) (hm i) (hfit i) τ (r - p i) hd hpr,
      PartialHistory.states_eq_of_time_eq τ.val (p i + (r - p i)) r
        (add_sub_cancel (p i) r) hpr hr] at e1
    rw [Beh.restrict_states (p i) (m i) (hp i) (hm i) (hfit i) τ' (r - p i) hd hpr',
      PartialHistory.states_eq_of_time_eq τ'.val (p i + (r - p i)) r
        (add_sub_cancel (p i) r) hpr' hr'] at e2
    exact e1.trans e2.symm

/--
**The *Directed Gluing* clause.** Compatible sections over an upward directed family of subwindows
of `[0, l]` extend to a section over `[0, l]`, **uniquely** when the family covers `[0, l]`.

Existence is `directed_gluing_of_isRestriction` with the extension property supplied by
`thm:extension`; uniqueness is `directed_gluing_unique`, which needs neither directedness nor any
frame constraint. The paper writes "in ZFC" at exactly this clause and "choice-free" at the binary
*Sheaf* clause, and that contrast is reproduced by measurement rather than asserted — see the
choice record in this module's docstring.

Constraints consumed: Compositionality, Seriality, Limit, Saturation
-/
theorem directed_gluing_clause (F : TaskFrame) [F.IsRegular] {I : Type*} [Nonempty I]
    {l : F.Duration} (p m : I → F.Duration) (hp : ∀ i, 0 ≤ p i) (hm : ∀ i, 0 ≤ m i)
    (hfit : ∀ i, p i + m i ≤ l)
    (hcov : ∀ t, 0 ≤ t → t ≤ l → ∃ i, p i ≤ t ∧ t ≤ p i + m i)
    (σ : ∀ i, Beh F (m i))
    (hdir : Directed (· ≤ ·) fun i => place (p i) (hm i) (σ i)) :
    ∃! τ : Beh F l, ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ = σ i := by
  obtain ⟨τ, hτ⟩ := directed_gluing_of_isRestriction F
    (PartialHistory.isRestriction_of_isRegular F) p m hp hm hfit σ hdir
  exact ⟨τ, hτ, fun τ' hτ' => directed_gluing_unique p m hp hm hfit hcov σ τ' τ hτ' hτ⟩

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
