/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.PartialHistory
import FormalSystem.Semantics.Presheaf.Site

/-!
# The behavior presheaf `Beh(F)`

A task frame's convex histories, packaged as a presheaf on the interval site
`Semantics/Presheaf/Site.lean` builds. `Beh F l` is the type of partial histories whose domain is
exactly the interval `[0, l]`, and the presheaf action restricts along a translation `Tr p`:

```
(restrict p l' … τ)  =  fun z => τ (p + z)   on [0, l']
```

Functoriality then says that `Tr 0` acts trivially and that restricting along `Tr (p + p')` is
restricting along `Tr p` and then along `Tr p'` — contravariantly, which is what makes `Beh F`
a *pre*sheaf rather than a covariant family. Both laws are stated twice: at raw data
(`restrict_id`, `restrict_comp`), where the offsets and their order proofs are explicit, and at
the site (`restrictTr_id`, `restrictTr_comp`), where a single morphism of `Int(D)` carries them.

The *Germs* clause closes the circle at length zero: a section over `0` is a single world state,
and `germEquiv` is that bijection. It is the one result here that needs frame constraints —
*Seriality* and *Limit*, via the `[F.IsRegular]` bundle — because building a section out of a bare
world state needs the zero-duration task relation to be the identity, which is the derived
`nullity_identity`. Nothing else in this module assumes anything of the frame at all: the
sections, the restriction map and both functoriality laws hold at **no** constraint.

## Main Definitions

- `Beh F l`: the sections over `l` — the subtype of `PartialHistory F` whose members satisfy
  `∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l)`.
- `Beh.restrict`: the presheaf action at raw data — an offset `p`, a new length `l'`, and the
  three order facts `0 ≤ p`, `0 ≤ l'`, `p + l' ≤ l`.
- `Beh.restrictTr`: the same action indexed by a morphism `f : Tr l' l` of the interval site.
- `Beh.germ`, `Beh.ofGerm`: a section over `0` to its single state, and back.
- `Beh.germEquiv`: the *Germs* clause as an `Equiv`, `Beh F 0 ≃ F.WorldState`.

## Main Results

- `partialHistory_ext`: two partial histories agreeing on their domain and pointwise on their
  states are equal. Lean generates no `PartialHistory.ext` — see the Implementation Notes.
- `Beh.mem_dom`, `Beh.isConvex`, `Beh.domain_eq_interval`: a section's domain contains every point
  of `[0, l]`, is convex, and is literally `Interval 0 l`.
- `Beh.restrict_domain`, `Beh.restrict_states`: the two defining equations of the action, both
  `rfl`.
- `Beh.restrict_id`, `Beh.restrict_comp`: presheaf functoriality at raw data.
- `Beh.restrictTr_id`, `Beh.restrictTr_comp`: the same, at the site. `restrictTr_comp` is where
  the contravariance is visible — `restrictTr (Tr.comp f g) = restrictTr g ∘ restrictTr f`.
- `Beh.germ_ofGerm`, `Beh.ofGerm_germ`: the two round trips of `germEquiv`.

## Implementation Notes

**The sections carry a pointwise `Iff`, not a domain equality.** `Beh F l` is defined by
`∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l)` rather than by `τ.domain = Interval 0 l`. This is load-bearing
rather than stylistic: in this form the domain-side obligations of `restrict`, `ofGerm` and
`restrict_domain` all discharge by `Iff.rfl`/`rfl`, because the condition is a pointwise `Iff`
against the *same* predicate the restriction's new domain is built from. Restating it as an
equality breaks every one of them. The equality is available as the derived
`Beh.domain_eq_interval`.

**Convexity is derived, not carried.** `Beh.isConvex` is a theorem, not a field. The history layer
deliberately carries convexity as a *predicate* on `PartialHistory` and there is no
`ConvexHistory` structure to subtype, so a section's convexity falls out of its interval domain
rather than being assumed alongside it.

**`partialHistory_ext` lives here, and that is a deliberate deferral.** `PartialHistory`'s
`states` field is dependent on its `domain` field, so Lean's `@[ext]` machinery generates no
`PartialHistory.ext`, and an extensionality lemma has to be written by hand. The natural home for
it is `Semantics/PartialHistory.lean` beside the structure, and consolidating it there is recorded
here as a follow-up rather than done: the history module is outside this cluster's remit, and the
earlier shift-set extensionality lemma this one replaces already named the consolidation a clean
follow-up before it was removed. Anything else needing partial-history extensionality should move
this lemma down rather than write a second copy.

**`restrict_id` and `restrict_comp` are new content at the partial-history level.** The shift-set
layer's `ts_zero` and `ts_add` are the corresponding facts for **total** histories; neither
specialises to a section over a bounded interval, because the restriction here changes the domain
rather than translating a function defined everywhere. The proofs route through
`PartialHistory.states_eq_of_time_eq` to move a state across `0 + r = r` and
`p + (p' + r) = p + p' + r`, which is the only step a reader is likely to find surprising.

**Frame constraints.** Only the *Germs* clause reaches them, and only through the `[F.IsRegular]`
bundle on `ofGerm`, `germ_ofGerm`, `ofGerm_germ` and `germEquiv`: building a section from a bare
world state needs `w ⇒_0 w`, which is the derived `nullity_identity`, resting on *Seriality* and
*Limit*. `Beh`, `restrict`, `restrict_id`, `restrict_comp`, `restrictTr` and both site-indexed
laws carry no bundling binder at all.

**Paper state: the source appendix is cut.** As for `Semantics/Presheaf/Site.lean`, the anchors
cited below live in `app:Structure`, which the paper **cut in full** under an explicit
`% SECTION CUT` record and whose surviving commented block carries a bare `% CHECK` — the author
has not finished reviewing this material. They resolve against
`docs/reference/paper-definitions-of-record.md`, where each carries a `DANGLING` row, and not
against a live `\label{}`; `scripts/check-paper-definitions.sh --resolve` structurally cannot pin
a commented-out label, so none is pinned.

## References

* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  §3.2 Def. 3.2.1 — the behavior sheaf of a dynamical system, of which `Beh F` is the
  task-frame instance
* JPL paper `def:behavior-presheaf` — `Beh(F)(l)` and restriction along `Tr p`. **`DANGLING`**:
  cut from the paper with `app:Structure` and recorded in
  `docs/reference/paper-definitions-of-record.md`
* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Germs* clause `germEquiv`
  discharges. **`DANGLING`**, as above
* JPL paper `app:Structure` — the cut appendix containing both. **`DANGLING`**, as above
* `FormalSystem/Semantics/Presheaf/Site.lean` — the site `Int(D)` this is a presheaf on
* `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory`, `IsConvex`,
  `states_eq_of_time_eq`
* `FormalSystem/Semantics/TaskFrame.lean` — `FrameOver.nullity_identity` and the `IsRegular`
  constraint bundle
-/

namespace FormalSystem.Semantics.Presheaf

variable {F : TaskFrame}

/-- Extensionality for partial histories: agreement on the domain and pointwise agreement on the
states suffices. Written by hand because `PartialHistory`'s `states` field is dependent on its
`domain` field, so no `@[ext]` lemma is generated. -/
theorem partialHistory_ext {σ τ : PartialHistory F} (hd : σ.domain = τ.domain)
    (hs : ∀ (r : F.Duration) (h : σ.domain r) (h' : τ.domain r), σ.states r h = τ.states r h') :
    σ = τ := by
  obtain ⟨d₁, n₁, s₁, t₁⟩ := σ
  obtain ⟨d₂, n₂, s₂, t₂⟩ := τ
  simp only at hd hs
  subst hd
  have : s₁ = s₂ := by funext r h; exact hs r h h
  subst this
  rfl

/-- The sections of the behavior presheaf over a duration `l`: the partial histories whose domain
is exactly the interval `[0, l]`. The condition is a pointwise `Iff` on purpose — see the module's
Implementation Notes. -/
def Beh (F : TaskFrame) (l : F.Duration) : Type :=
  { τ : PartialHistory F // ∀ t, τ.domain t ↔ (0 ≤ t ∧ t ≤ l) }

namespace Beh

/-- Every point of `[0, l]` is in a section's domain. -/
theorem mem_dom {l : F.Duration} (τ : Beh F l) {t : F.Duration} (h0 : 0 ≤ t) (hl : t ≤ l) :
    τ.val.domain t := (τ.property t).mpr ⟨h0, hl⟩

/-- A section is convex. Derived from its interval domain rather than carried as a field. -/
theorem isConvex {l : F.Duration} (τ : Beh F l) : τ.val.IsConvex := by
  intro x z hx hz y hxy hyz
  exact (τ.property y).mpr
    ⟨le_trans ((τ.property x).mp hx).1 hxy, le_trans hyz ((τ.property z).mp hz).2⟩

/-- The domain of a section over `l` is the interval `[0, l]` of the site. -/
theorem domain_eq_interval {l : F.Duration} (τ : Beh F l) : τ.val.domain = Interval 0 l := by
  funext t; exact propext (τ.property t)

/-- The presheaf action at raw data: restriction of a section over `l` along the translation by
`p`, onto a section over `l'`. Pointwise, `z ↦ τ (p + z)` on `[0, l']`. -/
def restrict {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) : Beh F l' :=
  ⟨{ domain := fun z => 0 ≤ z ∧ z ≤ l'
     nonempty_domain := ⟨0, le_refl 0, hl'⟩
     states := fun z hz =>
       τ.val.states (p + z) (mem_dom τ (add_nonneg hp hz.1)
         (le_trans (add_le_add (le_refl p) hz.2) hple))
     respects_task := by
       intro s t hs ht
       have h := τ.val.respects_task (p + s) (p + t)
         (mem_dom τ (add_nonneg hp hs.1) (le_trans (add_le_add (le_refl p) hs.2) hple))
         (mem_dom τ (add_nonneg hp ht.1) (le_trans (add_le_add (le_refl p) ht.2) hple))
       rwa [add_sub_add_left_eq_sub] at h },
   fun _ => Iff.rfl⟩

/-- The domain of a restriction, by definition. -/
theorem restrict_domain {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) (z : F.Duration) :
    (restrict p l' hp hl' hple τ).val.domain z = (0 ≤ z ∧ z ≤ l') := rfl

/-- The states of a restriction, by definition: the restriction reads `τ` at the shifted time. -/
theorem restrict_states {l : F.Duration} (p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l')
    (hple : p + l' ≤ l) (τ : Beh F l) (z : F.Duration)
    (hz : (restrict p l' hp hl' hple τ).val.domain z) (hpz : τ.val.domain (p + z)) :
    (restrict p l' hp hl' hple τ).val.states z hz = τ.val.states (p + z) hpz := rfl

/-- Sections over a fixed length are determined by their underlying partial history. -/
theorem ext {l : F.Duration} {σ τ : Beh F l} (h : σ.val = τ.val) : σ = τ := Subtype.ext h

/-- Presheaf functoriality, identity half: translating by `0` onto the same length acts
trivially. -/
theorem restrict_id {l : F.Duration} (hl : 0 ≤ l) (τ : Beh F l) :
    restrict 0 l (le_refl 0) hl (by rw [zero_add]) τ = τ := by
  refine ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ l) = τ.val.domain z
    exact propext ((τ.property z).symm)
  · intro r hr h'
    have h0r : τ.val.domain (0 + r) := by rw [zero_add]; exact h'
    rw [restrict_states 0 l (le_refl 0) hl (by rw [zero_add]) τ r hr h0r]
    exact PartialHistory.states_eq_of_time_eq τ.val (0 + r) r (zero_add r) h0r h'

/-- Presheaf functoriality, composition half: restricting by `p` and then by `p'` is restricting
by `p + p'`. -/
theorem restrict_comp {l : F.Duration} (p l' p' l'' : F.Duration)
    (hp : 0 ≤ p) (hl' : 0 ≤ l') (hple : p + l' ≤ l)
    (hp' : 0 ≤ p') (hl'' : 0 ≤ l'') (hple' : p' + l'' ≤ l')
    (τ : Beh F l) :
    restrict p' l'' hp' hl'' hple' (restrict p l' hp hl' hple τ)
      = restrict (p + p') l'' (add_nonneg hp hp') hl''
          (by
            rw [add_assoc]
            exact le_trans (add_le_add (le_refl p) hple') hple) τ := by
  refine ext (partialHistory_ext rfl ?_)
  intro r hr hr'
  have hin : τ.val.domain (p + (p' + r)) :=
    mem_dom τ (add_nonneg hp (add_nonneg hp' hr.1))
      (le_trans (add_le_add (le_refl p) (le_trans (add_le_add (le_refl p') hr.2) hple')) hple)
  have hin' : τ.val.domain (p + p' + r) := by rw [← add_assoc] at hin; exact hin
  rw [restrict_states p' l'' hp' hl'' hple' _ r hr (by
        rw [restrict_domain]
        exact ⟨add_nonneg hp' hr.1, le_trans (add_le_add (le_refl p') hr.2) hple'⟩),
      restrict_states p l' hp hl' hple τ (p' + r) _ hin,
      restrict_states (p + p') l'' (add_nonneg hp hp') hl'' _ τ r hr' hin']
  exact PartialHistory.states_eq_of_time_eq τ.val (p + (p' + r)) (p + p' + r)
    (add_assoc p p' r).symm hin hin'

/-! ### Restriction indexed by a site morphism: `Beh F` as a genuine presheaf -/

/-- The presheaf action indexed by a morphism `f : Tr l' l` of the interval site, rather than by
raw data: the morphism supplies the offset and both order facts. -/
def restrictTr {l' l : Obj F.Duration} (f : Tr l' l) (τ : Beh F l.val) : Beh F l'.val :=
  restrict f.shift l'.val f.shift_nonneg l'.property f.shift_add_le τ

/-- Functoriality at the identity, stated at the site. -/
theorem restrictTr_id {l : Obj F.Duration} (τ : Beh F l.val) :
    restrictTr (Tr.id l) τ = τ :=
  restrict_id l.property τ

/-- Functoriality at a composite, stated at the site. The order of `f` and `g` on the right is
reversed: `Beh F` is **contravariant** on `Int(D)`, hence a presheaf. -/
theorem restrictTr_comp {l'' l' l : Obj F.Duration} (f : Tr l' l) (g : Tr l'' l')
    (τ : Beh F l.val) :
    restrictTr (Tr.comp f g) τ = restrictTr g (restrictTr f τ) :=
  (restrict_comp f.shift l'.val g.shift l''.val f.shift_nonneg l'.property f.shift_add_le
    g.shift_nonneg l''.property g.shift_add_le τ).symm

/-! ### Germs -/

/-- The germ of a section over `0`: its single state. -/
def germ (τ : Beh F 0) : F.WorldState :=
  τ.val.states 0 (mem_dom τ (le_refl 0) (le_refl 0))

/-- Every world state is a germ: the one-point section at it. -/
def ofGerm (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : Beh F 0 :=
  ⟨{ domain := fun t => 0 ≤ t ∧ t ≤ 0
     nonempty_domain := ⟨0, le_refl 0, le_refl 0⟩
     states := fun _ _ => w
     respects_task := by
       intro s t hs ht
       have hs0 : s = 0 := le_antisymm hs.2 hs.1
       have ht0 : t = 0 := le_antisymm ht.2 ht.1
       subst hs0; subst ht0
       simpa [sub_self] using (F.nullity_identity w w).mpr rfl },
   fun _ => Iff.rfl⟩

/-- Taking the germ of the one-point section at `w` returns `w`. -/
theorem germ_ofGerm (F : TaskFrame) [F.IsRegular] (w : F.WorldState) :
    germ (ofGerm F w) = w := rfl

/-- The one-point section at a section's own germ is that section. -/
theorem ofGerm_germ [F.IsRegular] (τ : Beh F 0) : ofGerm F (germ τ) = τ := by
  refine ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ 0) = τ.val.domain z
    exact propext ((τ.property z).symm)
  · intro r _ h'
    have hr0 : r = 0 := le_antisymm ((τ.property r).mp h').2 ((τ.property r).mp h').1
    subst hr0
    rfl

/-- The *Germs* clause: `Beh F 0 ≃ F.WorldState`. The sections over the zero duration are exactly
the world states. -/
def germEquiv (F : TaskFrame) [F.IsRegular] : Beh F 0 ≃ F.WorldState where
  toFun := germ
  invFun := ofGerm F
  left_inv := ofGerm_germ
  right_inv := germ_ofGerm F

end Beh

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
