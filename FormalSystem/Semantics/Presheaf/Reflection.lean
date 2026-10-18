/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import Mathlib.Tactic.Abel
import FormalSystem.Semantics.Presheaf.Behavior

/-!
# The *Reflection* clause: `Beh(F) ≅ Beh(F⁻) ∘ ref`

The clause of `app:presheaf-dictionary` reading: reflection is a natural isomorphism between the
behavior presheaf of a task frame and that of its converse frame, precomposed with the reflection
automorphism of the interval site. Concretely, a section `τ` over `[0, l]` is reflected to
`τʳ(z) = τ(l - z)`, which is a section of the **converse** frame `F⁻` over the same interval, and
reflecting commutes with restriction once the translation `Tr p : l' → l` is itself reflected to
`Tr (l - p - l') : l' → l`. Every component `Beh F l → Beh F⁻ l` is a bijection, because reflecting
twice is the identity on sections and `(F⁻)⁻ = F` holds by `rfl`.

## Why this clause matters

This natural isomorphism is what underlies the soundness of the **time reflection metarule `TR`**.
`thm:TR-valid` — formalized as `validOn_rev_iff` in `Semantics/Validity.lean`, resting on
`truthAt_rev` in `Semantics/Reversal.lean` — says that a formula is valid on `F` exactly when its
time-reflection is valid on `F⁻`; the present clause is the same involution one level up, stated
on the sections of the behavior presheaf rather than on truth values. The reflection convention on
the task relation supplies the involution **by definition**, not by assumption: `FrameOver.rev`
reverses the primitive relation and nothing else, so `FrameOver.rev_taskRel` is `Iff.rfl` and
`TaskFrame.rev_rev` is `rfl`. That is why the clause costs so little — no declaration here reaches
a field of `FrameOver.IsRegular`, and every result measures choice-free. Along with the
*Determinism* clause of `Presheaf/Determinism.lean`, this is one of the few places where the
categorical packaging says something about the logic rather than restating the semantics.

## Reuse, not rebuild

**The converse frame is consumed, not defined.** `F⁻` is `FrameOver.rev` / `TaskFrame.rev` of
`Semantics/TaskFrame.lean` (section `ConverseFrame`), reached here through `rev_taskRel` alone. No
second converse-frame construction is introduced. Two neighbouring pieces of machinery are *not*
converse frames and are not duplicated either: `Semantics/TruthTransport.lean`'s `TruthAntiIso` is
a model-level transport that takes both frames as given, and `Formula.reflectTime` is a syntactic
operation on formulas.

**The two forms of `⇒⁻`.** The clause is stated over the primitive reversal `rev_taskRel`,
`F⁻.TaskRel w d u ↔ F.TaskRel u d w`, which holds at no frame constraint. The paper's negated form
`w ⇒⁻_x u := w ⇒_{-x} u` is `rev_taskRel_neg`, which needs `[F.IsRegular]` for *Reflection*
itself; it is the bridge between the two presentations and is cited here, not used.

## Main Definitions

- `Tr.ref`: the reflection automorphism of `Int(D)` on morphisms, `Tr p ↦ Tr (l - p - l')`. It
  fixes objects, so no object-level map is declared.
- `Beh.reflectSec`: the reflection of a section, `τʳ(z) = τ(l - z)`, landing in `Beh F.rev l`.
- `Beh.reflectEquiv`: the component bijection `Beh F l ≃ Beh F.rev l`.

## Main Results

- `Tr.ref_shift`: the defining equation of `Tr.ref`, by `rfl` and `@[simp]`.
- `Tr.ref_ref`, `Tr.ref_id`, `Tr.ref_comp`: `ref` is an involution, fixes identities, and
  preserves composition. Composition is preserved **covariantly**: `ref` fixes objects and is an
  automorphism of `Int(D)`, not a duality.
- `Tr.ref_lres`, `Tr.ref_rres`: `ref` interchanges the left and right restrictions of
  `Presheaf/Site.lean`.
- `Beh.reflectSec_states`: the reading equation of `reflectSec`, by `rfl`.
- `Beh.reflect_natural`: naturality — reflecting a restriction is restricting the reflection along
  the reflected translation.
- `Beh.reflect_reflect`: the involution `(τʳ)ʳ = τ`, stated at `F.rev.rev`, which is `F` by `rfl`.

## Implementation Notes

**No `Functor` instance.** `Presheaf/Site.lean` records the decision to state the site concretely,
with no `Mathlib.CategoryTheory` import; `ref` follows it as a plain `def` on `Tr` with its laws as
plain theorems. Anything wanting the categorical packaging should add the instance beside the site
and reconcile with that note — as `Presheaf/Path.lean` has since done, synonym-scoped and without
touching the site; see its Implementation Notes.

**`Mathlib.Tactic.Abel` is imported for the time identities.** The cluster's import closure did not
carry `abel`, and the four identities `l - (l - p - l') - l' = p`,
`l - (p + p') - l'' = (l - p - l') + (l' - p' - l'')`, `(l - s) - (l - t) = t - s` and
`l - (l - r) = r` are commutative-group facts a `simp` set does not close. In-cluster
precedent: `Semantics/Extension/Constraint.lean`. The import leaves the cluster's
`assert_not_exists` lock intact.

**`reflect_reflect` is stated at `F.rev.rev` with no cast.** `TaskFrame.rev` is `@[reducible]` and
`TaskFrame.rev_rev` is `rfl`, so `Beh.reflectSec (F := F.rev) l (Beh.reflectSec l τ)` has type
`Beh F.rev.rev l.val`, which Lean identifies with `Beh F l.val` definitionally; the statement
compares it with `τ` directly. The `Equiv` is then assembled from the one lemma applied twice, once
at `F` and once at `F.rev`, exactly as `Beh.germEquiv` is assembled from its two round trips.

**Measured axiom profile** (`#print axioms`): every one of the twelve declarations — `Tr.ref` and
its six laws, `Beh.reflectSec`, `Beh.reflectSec_states`, `Beh.reflect_natural`,
`Beh.reflect_reflect` and `Beh.reflectEquiv` — is `[propext, Quot.sound]`. The clause is therefore
**choice-free in both of `Presheaf/README.md`'s measured senses**, and in the first more strongly
than *Germs* and *Sheaf* are: it consumes **no** frame constraint at all, not even
*Compositionality* as an explicit hypothesis (every doc block below reads
`Constraints consumed: None`), and `#print axioms` reports no `Classical.choice` anywhere. This is
the measured content of the claim that the reflection convention supplies the involution by
definition.

**Paper state: the source appendix is cut.** As for the sibling modules, the anchors cited below
live in `app:Structure`, which the paper **cut in full** under an explicit `% SECTION CUT` record;
the text is kept verbatim, still commented, in the paper repository's `appendix_cut_material.tex`.
They resolve against `docs/reference/paper-definitions-of-record.md`, where each carries a
`DANGLING` row, and not against a live `\label{}`; `scripts/check-paper-definitions.sh --resolve`
structurally cannot pin a commented-out label, so none is pinned. `thm:TR-valid` and
`lem:time-reflection`, by contrast, are live anchors.

## References

* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  §3.2 Def. 3.2.1 — the behavior sheaf whose task-frame instance `Beh F` is
* [P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999], §2 — the interval
  site `ref` is an automorphism of
* JPL paper `def:behavior-presheaf` — the *Reflection*, *Converse Frame* and *Reflection
  Automorphism* clauses: `τʳ`, `F⁻` and `ref`. **`DANGLING`**: cut from the paper with
  `app:Structure` and recorded in `docs/reference/paper-definitions-of-record.md`
* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Reflection* clause and proof
  paragraph this module discharges. **`DANGLING`**, as above
* JPL paper `app:Structure` — the cut appendix containing both. **`DANGLING`**, as above
* JPL paper `thm:TR-valid` — the soundness of the time reflection metarule this clause underlies;
  formalized as `validOn_rev_iff`
* JPL paper `lem:time-reflection` — the truth transfer under reflection; formalized as `truthAt_rev`
* `FormalSystem/Semantics/Presheaf/Site.lean` — `Tr`, `Tr.id`, `Tr.comp`, `lres`, `rres`
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrictTr`, `Beh.mem_dom`,
  `Beh.ext`, and `Beh.germEquiv` as the model for `reflectEquiv`
* `FormalSystem/Semantics/TaskFrame.lean` — the `ConverseFrame` section: `FrameOver.rev`,
  `rev_taskRel`, `rev_taskRel_neg`, `TaskFrame.rev`, `TaskFrame.rev_rev`
* `FormalSystem/Semantics/Reversal.lean` — `truthAt_rev`, the truth-level form of the involution
* `FormalSystem/Semantics/Validity.lean` — `validOn_rev_iff`, the validity-level form

## Tags

presheaf-dictionary · reflection · converse-frame · time-reflection · natural-isomorphism ·
app:presheaf-dictionary
-/

namespace FormalSystem.Semantics.Presheaf

variable {D : TemporalOrder}

/-! ### The reflection automorphism on morphisms -/

namespace Tr

/-- **The reflection automorphism of `Int(D)` on morphisms.** The translation `Tr p : l' → l`,
reading the window `[p, p + l']` out of `[0, l]`, is sent to `Tr (l - p - l') : l' → l`, reading
the mirror-image window `[l - p - l', l - p]`. Objects are fixed. The two side conditions are
`0 ≤ l - p - l'`, from `p + l' ≤ l`, and `(l - p - l') + l' ≤ l`, from `0 ≤ p`.

Constraints consumed: None -/
def ref {l' l : Obj D} (f : Tr l' l) : Tr l' l :=
  ⟨l.val - f.shift - l'.val,
   sub_nonneg.mpr (le_sub_iff_add_le.mpr (by rw [add_comm]; exact f.shift_add_le)),
   by rw [sub_add_cancel]; exact sub_le_self _ f.shift_nonneg⟩

/-- The defining equation of `ref`.

Constraints consumed: None -/
@[simp] theorem ref_shift {l' l : Obj D} (f : Tr l' l) :
    (ref f).shift = l.val - f.shift - l'.val := rfl

/-- `ref` is an involution: reflecting a translation twice returns it.

Constraints consumed: None -/
theorem ref_ref {l' l : Obj D} (f : Tr l' l) : ref (ref f) = f := by
  ext; simp; abel

/-- `ref` fixes identities: the reflection of `Tr 0 : l → l` is `Tr (l - 0 - l) = Tr 0`.

Constraints consumed: None -/
theorem ref_id (l : Obj D) : ref (Tr.id l) = Tr.id l := by
  ext; simp

/-- `ref` preserves composition, covariantly: it is an automorphism of `Int(D)` fixing objects,
not a duality, so the order of the factors is unchanged.

Constraints consumed: None -/
theorem ref_comp {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') :
    ref (Tr.comp f g) = Tr.comp (ref f) (ref g) := by
  ext; simp; abel

/-- `ref` carries the left restriction `Tr 0 : l' → l` to the right restriction
`Tr (l - l') : l' → l`.

Constraints consumed: None -/
theorem ref_lres {l l' : Obj D} (h : l'.val ≤ l.val) : ref (lres h) = rres h := by
  ext; simp [lres, rres]

/-- `ref` carries the right restriction `Tr (l - l') : l' → l` to the left restriction
`Tr 0 : l' → l`.

Constraints consumed: None -/
theorem ref_rres {l l' : Obj D} (h : l'.val ≤ l.val) : ref (rres h) = lres h := by
  ext; simp [lres, rres]

end Tr

/-! ### The reflection of a section -/

namespace Beh

/-- **The reflection of a section.** A section `τ` of `Beh F` over `[0, l]` is sent to
`τʳ(z) = τ(l - z)`, a section of the **converse** frame `F.rev` over the same interval. The domain
is the interval again; the states read `τ` at the mirrored time; and `respects_task` for `F.rev` is
`respects_task` for `F` at the mirrored pair, transported across `FrameOver.rev_taskRel` — the
primitive reversal, which is `Iff.rfl` — with the time identity `(l - s) - (l - t) = t - s`.

Constraints consumed: None -/
def reflectSec {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val) : Beh F.rev l.val :=
  ⟨{ domain := fun z => 0 ≤ z ∧ z ≤ l.val
     nonempty_domain := ⟨0, le_refl 0, l.property⟩
     states := fun z hz =>
       τ.val.states (l.val - z)
         (Beh.mem_dom τ (sub_nonneg.mpr hz.2) (sub_le_self _ hz.1))
     respects_task := by
       intro s t hs ht
       refine (FrameOver.rev_taskRel F.toFibre _ (t - s) _).mpr ?_
       have h := τ.val.respects_task (l.val - t) (l.val - s)
         (Beh.mem_dom τ (sub_nonneg.mpr ht.2) (sub_le_self _ ht.1))
         (Beh.mem_dom τ (sub_nonneg.mpr hs.2) (sub_le_self _ hs.1))
       rwa [show (l.val - s) - (l.val - t) = t - s by abel] at h },
   fun _ => Iff.rfl⟩

/-- The reading equation of `reflectSec`: the reflected section at `z` is `τ` at `l - z`.

Constraints consumed: None -/
theorem reflectSec_states {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val)
    (z : F.Duration) (hz : (reflectSec l τ).val.domain z) (h' : τ.val.domain (l.val - z)) :
    (reflectSec l τ).val.states z hz = τ.val.states (l.val - z) h' := rfl

/-! ### Naturality -/

/-- **Naturality of reflection in the translations.** Reflecting the restriction of `τ` along
`f : Tr l' l` is restricting the reflection of `τ` along the reflected translation `Tr.ref f`.
Both sides read `τ` at `p + (l' - r)` and at `l - ((l - p - l') + r)`, which `abel` identifies.
This is the square that makes `reflectSec` a natural transformation `Beh F ⟶ Beh F.rev ∘ ref`.

Constraints consumed: None -/
theorem reflect_natural {F : TaskFrame} {l' l : Obj F.Duration} (f : Tr l' l)
    (τ : Beh F l.val) :
    reflectSec l' (Beh.restrictTr f τ)
      = Beh.restrictTr (F := F.rev) (Tr.ref f) (reflectSec l τ) := by
  refine Beh.ext (partialHistory_ext rfl ?_)
  intro r hr hr'
  change τ.val.states (f.shift + (l'.val - r)) _
      = τ.val.states (l.val - ((l.val - f.shift - l'.val) + r)) _
  exact PartialHistory.states_eq_of_time_eq τ.val _ _ (by abel) _ _

/-! ### Each component is a bijection -/

/-- **Reflection is an involution on sections**: `(τʳ)ʳ = τ`. Stated at `F.rev.rev`, which is `F`
by `rfl` since `TaskFrame.rev` is `@[reducible]`, so no cast appears. The domain half is the
section's own interval condition; the states half is `l - (l - r) = r`.

Constraints consumed: None -/
theorem reflect_reflect {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val) :
    reflectSec (F := F.rev) l (reflectSec l τ) = τ := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ l.val) = τ.val.domain z
    exact propext ((τ.property z).symm)
  · intro r hr h'
    change τ.val.states (l.val - (l.val - r)) _ = τ.val.states r _
    exact PartialHistory.states_eq_of_time_eq τ.val _ _ (by abel) _ _

/-- **The *Reflection* clause's component bijection**: `Beh F l ≃ Beh F.rev l`. Both inverse laws
are `reflect_reflect`, once at `F` and once at `F.rev`, using `(F.rev).rev = F` by `rfl`.
Together with `reflect_natural` this is the natural isomorphism `Beh(F) ≅ Beh(F⁻) ∘ ref` of
`app:presheaf-dictionary`.

Constraints consumed: None -/
def reflectEquiv (F : TaskFrame) (l : Obj F.Duration) : Beh F l.val ≃ Beh F.rev l.val where
  toFun := reflectSec l
  invFun := reflectSec (F := F.rev) l
  left_inv := reflect_reflect l
  right_inv := reflect_reflect (F := F.rev) l

end Beh

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
