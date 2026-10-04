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
# The *Totality* clause: every restriction map is surjective

`app:presheaf-dictionary`'s *Totality* clause says that every restriction map
`Beh(F)(l) → Beh(F)(m)` of the behavior presheaf is surjective. It is a **wrapper** on
`thm:extension`, and the wrapper is three steps long: translate the section over `m` onto the
window `[p, p + m]` (`place`), extend the translate to a possible world (the hypothesis), and cut
the world back down to `[0, l]` (`ofWorld`). `restrict_ofWorld` is the bridge that says the cut
of a world extending the translate restricts to the section it started from.

The clause is stated **four times**, once as a binder-free engine and three times as an
instantiation, and the split is load-bearing rather than tidiness. `totality_of_isRestriction`
takes `∀ τ, PartialHistory.IsRestriction τ` as an *explicit hypothesis* and so carries no frame
constraint at all; the three corollaries each supply that hypothesis from a different source, and
each is one line. What the engine buys is **attribution**: because it measures
`[propext, Quot.sound]` — no `Classical.choice` — the `Classical.choice` in `totality_clause` is
attributable exactly to `thm:extension` and to nothing in the geometry. See the choice record in
`Semantics/Presheaf/Directed.lean`'s *Directed Gluing* half once it lands, and the third recorded
verdict in `Semantics/Presheaf/README.md`.

## Main Definitions

- `place`: the translate — a section over `m` placed at offset `p`, as a partial history with
  domain `Interval p (p + m)` and states `t ↦ σ (t - p)`.
- `ofWorld`: the cut — a possible world restricted to `[0, l]`, as a section of `Beh F l`.

## Main Results

- `place_mem`: every point of `[p, p + m]` is in the translate's domain.
- `restrict_ofWorld`: the bridge. If a possible world extends `place p hm σ`, then restricting its
  cut over `[0, l]` along the translation by `p` returns `σ` exactly.
- `totality_of_isRestriction`: the clause's **engine** — surjectivity of `Beh.restrict`, with the
  extension property taken as an explicit hypothesis. `Constraints consumed: None`.
- `totality_clause`: the clause at `[F.IsRegular]`, via `PartialHistory.isRestriction_of_isRegular`.
- `totality_clause_site`: the same in the site's own vocabulary, along a morphism `f : Tr l' l`.
- `totality_of_isZTime`, `totality_of_completion`: the two minimal-hypothesis forms, over discrete
  ℤ-time and at bare *Completion* respectively — both **Saturation-free**.

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
destroying the attribution result above, since the engine row would then read `Classical.choice`
and there would be nothing left to attribute. The chosen idiom is the one `Beh.restrict` already
uses in `Behavior.lean`. The same caution applies to any `*_iff_*` round trip on a path whose axiom
measurement is load-bearing.

**`states_eq_of_eq` is imported, not restated.** `Semantics/Presheaf/Sheaf.lean` declares it at top
level in this same namespace, so a local copy under the same name is a hard duplicate-declaration
error rather than a shadowing. Importing `Presheaf.Sheaf` costs nothing — it imports only
`FormalSystem.Init` and `Presheaf.Behavior`, both of which this module needs anyway.

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
* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Totality* clause
  `totality_clause` discharges. **`DANGLING`**: cut from the paper with `app:Structure` and
  recorded in `docs/reference/paper-definitions-of-record.md`
* JPL paper `def:behavior-presheaf` — `Beh(F)(l)` and restriction along `Tr p`. **`DANGLING`**, as
  above
* JPL paper `app:Structure` — the cut appendix containing both. **`DANGLING`**, as above
* JPL paper `thm:extension` — every partial history is extended by some possible world; the single
  result both clauses of this module consume
* JPL paper `cor:occurrence` — the occurrence corollary drawn off `thm:extension`, whose footnote
  records that the route through Zorn's lemma is what makes the derivation a theorem of ZFC
* `FormalSystem/Semantics/Extension/Extension.lean` — `PartialHistory.extension`,
  `PartialHistory.isRestriction_of_isRegular`
* `FormalSystem/Semantics/Extension/Completion.lean` — `extension_of_completion`,
  `extension_of_isZTime`, the two minimal-hypothesis sources of the engine's hypothesis
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrict`, `Beh.restrictTr`,
  `partialHistory_ext`
* `FormalSystem/Semantics/Presheaf/Sheaf.lean` — `states_eq_of_eq`, and `sheaf_clause`, the binary
  companion clause whose choice-freeness this module's does not share
* `FormalSystem/Semantics/Presheaf/Site.lean` — `Interval`, `Obj`, `Tr`
* `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory`, `WorldHistory`,
  `PartialHistory.restrict`, `states_eq_of_time_eq`
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

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
