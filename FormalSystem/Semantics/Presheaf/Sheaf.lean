/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.Presheaf.Behavior

/-!
# The *Sheaf* clause: gluing two interval sections at a seam

Two sections of the behavior presheaf whose germs agree at a seam glue to a **unique** section
over the joined interval. Stated in *cut* form: a section `τ₁` over `p` and a section `τ₂` over
`l - p`, agreeing where the first ends and the second begins, determine exactly one section `υ`
over `l` restricting to each of them. That is `sheaf_clause`, and `glue` is the section it
exhibits.

The cut form is the primary one and the only one proved. Its alternative — a *sum* form over two
independent lengths `l₁` and `l₂`, gluing to `l₁ + l₂` — would need a dependent transport along
`l₁ + l₂ - l₁ = l₂` at every statement and buys nothing, since `l := l₁ + l₂` and `p := l₁`
recovers it.

What makes the clause cheap is that the gluing argument is not proved here either. The relation
across the seam is `PartialHistory.rel_across_seam`, stated once off totality with two
independent seam coordinates; this module instantiates it at `m := p` in the left section and
`m' := 0` in the right. Pasting two total world histories at a shared time is the other
instantiation, and the two were once the same proof written twice.

## Main Definitions

- `glue`: the glued section. On `[0, p]` it reads `τ₁`; past `p` it reads `τ₂` at the shifted
  time `z - p`. Its domain is literally `fun z => 0 ≤ z ∧ z ≤ l`.

## Main Results

- `glue_states_le`, `glue_states_not_le`: the two reading equations of `glue`, one per branch of
  its dependent `if`. Every later proof reads `glue` through these rather than unfolding it.
- `restrict_glue_left`, `restrict_glue_right`: the two restriction identities — restricting the
  glued section to `[0, p]` gives back `τ₁`, and to `[p, l]` gives back `τ₂`.
- `glue_unique`: any section restricting to `τ₁` and `τ₂` is `glue`.
- `sheaf_clause`: the clause itself, as the `∃!` the three preceding results package.
- `states_eq_of_eq`: reading a state out of an equality of sections, the step both restriction
  identities and uniqueness need.
- `restrictTr_coverLeft`, `restrictTr_coverRight`: restriction along either member of the
  Johnstone covering family **is** the raw-data restriction the clause is stated with. Both are
  `rfl`, which is what makes the site-level clause free.
- `sheaf_clause_site`: the clause in the site's own vocabulary, along `coverLeft` and
  `coverRight`, derived from `sheaf_clause` through those two identities with no transport.
- `compat_iff_match`: the coverage's compatible-family condition — an equality of germ sections
  in `Beh F 0` — is equivalent to the raw seam hypothesis.

## Implementation Notes

**The decidability of `z ≤ p` is the order's own.** `glue`'s `states` field splits on
`if hzp : z ≤ p`, whose `Decidable` instance comes from the `LinearOrder` on the temporal order
carried by the frame, not from `Classical.propDecidable`. The split is therefore computational
and contributes no axiom.

**The split is a `dite`, not an `ite`.** Each branch needs its own domain witness — `τ₁`'s at `z`
on one side, `τ₂`'s at `z - p` on the other — and only the dependent form makes the test's proof
available to build them. The payoff is that `glue_states_le` and `glue_states_not_le` are
literally `dif_pos` and `dif_neg`, and every later proof goes through them.

**`respects_task` is unconditional at `PartialHistory`.** The field quantifies over *all* pairs
`(s, t)` with no `s ≤ t` guard, so the obligation has **four** cases rather than two, and the
mixed-orientation case — `t ≤ p < s`, where the pair runs backwards across the seam — is
unavoidable. It is discharged by the off-zero reflection law `TaskFrame.reflection_of_ne`, which
suffices because that case is strict, and which is what keeps the construction clear of
`Classical.choice`. The four-way split mirrors the one in `PlusLanguage.paste_rel` exactly; that
correspondence is the structural evidence that the two constructions are one argument.

**The right restriction identity is where the seam hypothesis is consumed.** The `dite` test
`p + r ≤ p` is *true* at `r = 0`, so reading the glued section at the right interval's origin
lands in the **left** branch and returns `τ₁`'s state at `p`. Only `hmatch` closes the gap to
`τ₂`'s state at `0`. At every `r > 0` the test is false and the identity is pure arithmetic.

**Two arithmetic steps are deliberately not `linarith`.** `ring` and `linarith` are unavailable
in this import closure. `p + r - p = r` is `add_sub_cancel_left` and `(t - p) - (s - p) = t - s`
is `sub_sub_sub_cancel_right`; neither is a stylistic choice.

**`r ≤ 0` from `p + r ≤ p` is taken choice-free.** The route is `sub_nonpos.mpr` followed by
`add_sub_cancel_left`. `le_of_add_le_add_left` closes the same goal but measures
`Classical.choice`, and must not be substituted.

**The domain is written as the literal predicate.** `glue`'s `domain` field is
`fun z => 0 ≤ z ∧ z ≤ l` with its section condition discharged by `fun _ => Iff.rfl`. Restating
it as an equality against `Interval 0 l` breaks that discharge and every `rfl` downstream of it,
for the reason the behavior presheaf's own Implementation Notes record.

**Choice-freedom, in two distinguished senses, both measured.** The dictionary's *Sheaf* clause
is choice-free, and the claim is worth separating into the two things it can mean, because they
have different witnesses.

*Saturation-independence.* The binary seam gluing uses **Compositionality and nothing else**. The
honest witness is the signature itself: every declaration here takes an explicit
`(hcomp : TaskFrame.Compositional F.TaskRel)` and carries no bracketed frame bundle. An
`[F.IsRegular]` binder would have supplied the property needed and three more besides, and would
have left a reader unable to tell which were used. The contrasting case is **directed** gluing
over an ω-indexed family, which is not binary and does rest on *Saturation*, through the
Extension Theorem in `FormalSystem/Semantics/Extension.lean`; the distinction between the binary
and directed cases is exactly where that dependency enters.

*Axiom-freedom.* `#print axioms` reports `[propext, Quot.sound]` on every declaration in this
module — `states_eq_of_eq` needs only `[propext]` — with no `Classical.choice` anywhere. Two
steps earn that and would lose it if rewritten: the mixed-orientation case goes through the
off-zero reflection law rather than the unrestricted one, and `r ≤ 0` is derived by
`sub_nonpos.mpr` rather than `le_of_add_le_add_left`.

**Paper state: the source appendix is cut.** As for the two sibling modules, the anchors cited
below live in `app:Structure`, which the paper cut in full under an explicit `% SECTION CUT`
record and whose surviving commented block carries a bare `% CHECK`. They resolve against
`docs/reference/paper-definitions-of-record.md`, where each carries a `DANGLING` row, and not
against a live `\label{}`.

## References

* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  §3.2 — the behavior sheaf, whose gluing condition this is the task-frame instance of
* [P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999], §2 — the coverage
  whose sheaf condition `sheaf_clause_site` discharges, and which `coverLeft`/`coverRight`
  instantiate
* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Sheaf* clause
  `sheaf_clause` discharges. **`DANGLING`**: cut from the paper with `app:Structure` and recorded
  in `docs/reference/paper-definitions-of-record.md`
* JPL paper `app:Structure` — the cut appendix containing it. **`DANGLING`**, as above
* JPL paper `app:gluing` — the gluing lemma for two convex histories agreeing on their overlap,
  of which `sheaf_clause` is the interval-site reading. Cited here as a **pointer only**: its
  record row is `LIVE-UNPINNED` precisely because no docstring quotes its text, and this one does
  not either
* `FormalSystem/Semantics/Presheaf/Site.lean` — `coverLeft`, `coverRight`, `rres`, `lres`, and
  `cover_germ_composites`, whose one-point meeting of the two covering morphisms is what makes
  this coverage's sheaf condition a two-section statement
* `FormalSystem/Semantics/Extension.lean` — the Extension Theorem, where the **directed** gluing
  case takes on its dependence on *Saturation*
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrict`, `partialHistory_ext`
* `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory.rel_across_seam`, the seam
  argument this module instantiates, and `states_eq_of_time_eq`
* `FormalSystem/PlusLanguage/PlusPasting.lean` — `paste`, the other instantiation of that same
  argument
-/

namespace FormalSystem.Semantics.Presheaf

variable {F : TaskFrame}

/-! ## The glued section -/

/--
**The glued section**, in cut form: a section over `p` and a section over `l - p` whose germs
agree at the seam determine a section over `l`.

On `[0, p]` it reads `τ₁` at `z`; past `p` it reads `τ₂` at the shifted time `z - p`. The split
is a dependent `if` so that each branch carries the domain witness it needs — see the module's
Implementation Notes, which also record why the task-respect obligation has four cases and why
the mixed-orientation one is discharged off zero.
-/
def glue (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p)
    (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) : Beh F l :=
  ⟨{ domain := fun z => 0 ≤ z ∧ z ≤ l
     nonempty_domain := ⟨0, le_refl 0, le_trans hp hpl⟩
     states := fun z hz =>
       if hzp : z ≤ p then τ₁.val.states z (Beh.mem_dom τ₁ hz.1 hzp)
       else τ₂.val.states (z - p)
         (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp hzp))) (sub_le_sub_right hz.2 p))
     respects_task := by
       intro s t hs ht
       by_cases hsp : s ≤ p <;> by_cases htp : t ≤ p
       · rw [dif_pos hsp, dif_pos htp]
         exact τ₁.val.respects_task s t _ _
       · rw [dif_pos hsp, dif_neg htp]
         exact PartialHistory.rel_across_seam hcomp (Beh.mem_dom τ₁ hp le_rfl)
           (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) hmatch _ _ hsp
           (sub_nonneg.mpr (le_of_lt (not_le.mp htp)))
           (by rw [sub_zero, add_comm]; exact (sub_add_sub_cancel t p s).symm)
       · have hts : t < s := lt_of_le_of_lt htp (not_le.mp hsp)
         rw [dif_neg hsp, dif_pos htp,
           TaskFrame.reflection_of_ne F (sub_ne_zero_of_ne (ne_of_lt hts)), neg_sub]
         exact PartialHistory.rel_across_seam hcomp (Beh.mem_dom τ₁ hp le_rfl)
           (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) hmatch _ _ htp
           (sub_nonneg.mpr (le_of_lt (not_le.mp hsp)))
           (by rw [sub_zero, add_comm]; exact (sub_add_sub_cancel s p t).symm)
       · rw [dif_neg hsp, dif_neg htp]
         have h := τ₂.val.respects_task (s - p) (t - p)
           (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp hsp))) (sub_le_sub_right hs.2 p))
           (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp htp))) (sub_le_sub_right ht.2 p))
         rwa [sub_sub_sub_cancel_right] at h },
   fun _ => Iff.rfl⟩

/-! ### The two reading equations -/

/-- Reading the glued section at or before the seam: it is `τ₁`'s state. The left branch of
`glue`'s dependent `if`, so the proof is `dif_pos`. -/
theorem glue_states_le (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p)
    (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)))
    (z : F.Duration) (hz : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain z) (hzp : z ≤ p) :
    (glue hcomp hp hpl τ₁ τ₂ hmatch).val.states z hz
      = τ₁.val.states z (Beh.mem_dom τ₁ hz.1 hzp) :=
  dif_pos hzp

/-- Reading the glued section past the seam: it is `τ₂`'s state at the shifted time. The right
branch of `glue`'s dependent `if`, so the proof is `dif_neg`. -/
theorem glue_states_not_le (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration}
    (hp : 0 ≤ p) (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)))
    (z : F.Duration) (hz : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain z) (hzp : ¬ z ≤ p)
    (h2 : τ₂.val.domain (z - p)) :
    (glue hcomp hp hpl τ₁ τ₂ hmatch).val.states z hz = τ₂.val.states (z - p) h2 :=
  dif_neg hzp

/-! ### Reading a state out of an equality of sections -/

/-- Equal sections have equal states, at any point of the common domain and for either domain
witness. The step every restriction identity and the uniqueness proof need, since the sections
they equate carry different witnesses at the same time. -/
theorem states_eq_of_eq {l : F.Duration} {σ τ : Beh F l} (h : σ = τ) (r : F.Duration)
    (hσ : σ.val.domain r) (hτ : τ.val.domain r) : σ.val.states r hσ = τ.val.states r hτ := by
  subst h; rfl

/-! ## The two restriction identities -/

/-- **Left restriction identity**: restricting the glued section to `[0, p]` returns `τ₁`. Pure
arithmetic — the seam hypothesis is not consumed here, since every point of `[0, p]` lands in
`glue`'s left branch. -/
theorem restrict_glue_left (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration}
    (hp : 0 ≤ p) (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl)
      (glue hcomp hp hpl τ₁ τ₂ hmatch) = τ₁ := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ p) = τ₁.val.domain z
    exact propext (τ₁.property z).symm
  · intro r hr h'
    have hdomr : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain r :=
      ⟨hr.1, le_trans hr.2 hpl⟩
    have hdom0 : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain (0 + r) := by
      rw [zero_add]; exact hdomr
    rw [Beh.restrict_states 0 p le_rfl hp (by rw [zero_add]; exact hpl) _ r hr hdom0,
      PartialHistory.states_eq_of_time_eq _ (0 + r) r (zero_add r) hdom0 hdomr,
      glue_states_le hcomp hp hpl τ₁ τ₂ hmatch r hdomr hr.2]

/-- **Right restriction identity**: restricting the glued section to `[p, l]` returns `τ₂`.

This is where `hmatch` is consumed. The `dite` test `p + r ≤ p` is *true* at `r = 0`, so the
right interval's own origin reads out of `glue`'s **left** branch as `τ₁`'s state at `p`, and
only the seam hypothesis closes the gap to `τ₂`'s state at `0`. Every `r > 0` falls in the right
branch and is arithmetic. -/
theorem restrict_glue_right (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration}
    (hp : 0 ≤ p) (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel])
      (glue hcomp hp hpl τ₁ τ₂ hmatch) = τ₂ := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ l - p) = τ₂.val.domain z
    exact propext (τ₂.property z).symm
  · intro r hr h'
    have hdom : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain (p + r) :=
      ⟨add_nonneg hp hr.1, by
        have := add_le_add (le_refl p) hr.2
        rwa [add_sub_cancel] at this⟩
    rw [Beh.restrict_states p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) _ r hr hdom]
    by_cases hr0 : p + r ≤ p
    · have hle : p + r - p ≤ 0 := sub_nonpos.mpr hr0
      rw [add_sub_cancel_left] at hle
      have hr00 : r = 0 := le_antisymm hle hr.1
      subst hr00
      rw [glue_states_le hcomp hp hpl τ₁ τ₂ hmatch (p + 0) hdom hr0]
      rw [PartialHistory.states_eq_of_time_eq τ₁.val (p + 0) p (add_zero p) _
        (Beh.mem_dom τ₁ hp le_rfl), hmatch]
    · rw [glue_states_not_le hcomp hp hpl τ₁ τ₂ hmatch (p + r) hdom hr0
        (by rw [add_sub_cancel_left]; exact h')]
      exact PartialHistory.states_eq_of_time_eq τ₂.val (p + r - p) r (add_sub_cancel_left p r) _ h'

/-! ## Uniqueness and the clause -/

/-- **Uniqueness**: a section over `l` restricting to `τ₁` on the left and `τ₂` on the right is
the glued section. Both sides are read pointwise through `glue`'s two reading equations and the
hypotheses' own restriction equations. -/
theorem glue_unique (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p)
    (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)))
    (υ : Beh F l)
    (hL : Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ = τ₁)
    (hR : Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ = τ₂) :
    υ = glue hcomp hp hpl τ₁ τ₂ hmatch := by
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change υ.val.domain z = (0 ≤ z ∧ z ≤ l)
    exact propext (υ.property z)
  · intro r hr hr'
    have hr0 : 0 ≤ r := ((υ.property r).mp hr).1
    have hrl : r ≤ l := ((υ.property r).mp hr).2
    by_cases hrp : r ≤ p
    · rw [glue_states_le hcomp hp hpl τ₁ τ₂ hmatch r hr' hrp]
      have hd1 : (Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ).val.domain r :=
        ⟨hr0, hrp⟩
      have h0r : υ.val.domain (0 + r) := by rw [zero_add]; exact hr
      have h1 := states_eq_of_eq hL r hd1 (Beh.mem_dom τ₁ hr0 hrp)
      rw [Beh.restrict_states 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ r hd1 h0r,
        PartialHistory.states_eq_of_time_eq υ.val (0 + r) r (zero_add r) h0r hr] at h1
      exact h1
    · have hrp' : 0 ≤ r - p := sub_nonneg.mpr (le_of_lt (not_le.mp hrp))
      have hrpl : r - p ≤ l - p := sub_le_sub_right hrl p
      rw [glue_states_not_le hcomp hp hpl τ₁ τ₂ hmatch r hr' hrp (Beh.mem_dom τ₂ hrp' hrpl)]
      have hd2 : (Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl)
          (by rw [add_sub_cancel]) υ).val.domain (r - p) := ⟨hrp', hrpl⟩
      have hpr : υ.val.domain (p + (r - p)) := by rw [add_sub_cancel]; exact hr
      have h1 := states_eq_of_eq hR (r - p) hd2 (Beh.mem_dom τ₂ hrp' hrpl)
      rw [Beh.restrict_states p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ
          (r - p) hd2 hpr,
        PartialHistory.states_eq_of_time_eq υ.val (p + (r - p)) r (add_sub_cancel p r) hpr hr] at h1
      exact h1

/-- **The *Sheaf* clause.** Two sections agreeing at the seam glue to a unique section over the
joined interval: existence is `glue` with its two restriction identities, uniqueness is
`glue_unique`. -/
theorem sheaf_clause (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p)
    (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    ∃! υ : Beh F l,
      Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ = τ₁ ∧
      Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ = τ₂ :=
  ⟨glue hcomp hp hpl τ₁ τ₂ hmatch,
   ⟨restrict_glue_left hcomp hp hpl τ₁ τ₂ hmatch, restrict_glue_right hcomp hp hpl τ₁ τ₂ hmatch⟩,
   fun _ h => glue_unique hcomp hp hpl τ₁ τ₂ hmatch _ h.1 h.2⟩

/-! ## The clause at the site

The statements above are in raw data: explicit offsets with their order proofs. The site's own
vocabulary is a morphism of `Int(D)`, and the two members of the Johnstone covering family of `l`
cut at `p` are `coverLeft` and `coverRight`. Restriction along either is **definitionally** the
raw-data restriction the clause is already stated with, so the site-indexed clause follows with
no transport and no cast.
-/

/-- Restriction along the left member of the covering family **is** the raw-data restriction at
offset `0` onto length `p`. A definitional identity: `coverLeft`'s offset is literally `0`. -/
theorem restrictTr_coverLeft (l : Obj F.Duration) (p : ↑F.Duration) (hp : 0 ≤ p)
    (hpl : p ≤ l.val) (υ : Beh F l.val) :
    Beh.restrictTr (coverLeft l p hp hpl) υ
      = Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ :=
  rfl

/-- Restriction along the right member of the covering family **is** the raw-data restriction at
offset `p` onto length `l - p`. A definitional identity: `coverRight`'s offset is literally
`p`. -/
theorem restrictTr_coverRight (l : Obj F.Duration) (p : ↑F.Duration) (hp : 0 ≤ p)
    (hpl : p ≤ l.val) (υ : Beh F l.val) :
    Beh.restrictTr (coverRight l p hp hpl) υ
      = Beh.restrict p (l.val - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ :=
  rfl

/--
**The coverage's compatible-family condition is the seam hypothesis.** The two covering morphisms
of `l` at `p` meet in exactly one point (`cover_germ_composites`), so a compatible family for
this coverage is a pair of sections whose restrictions to that single germ agree — an equality in
`Beh F 0`. This says that equality is equivalent to the raw `hmatch`: `τ₁`'s state at `p` is
`τ₂`'s state at `0`.

With `Beh.germEquiv` this is the statement that the germ of a section is its endpoint state, read
through both covering morphisms at once. It is what licenses stating the clause with `hmatch`
rather than with an equality of germ sections.

`Beh.restrictTr` must be unfolded before `rw` can see the `Beh.restrict_states` pattern — the
`simp only [Beh.restrictTr, rres, lres]` below is a measured requirement, not housekeeping: the
morphism's offset is otherwise hidden inside `Tr.shift`.
-/
theorem compat_iff_match (l p : F.Duration) (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) :
    Beh.restrictTr (l' := (⟨0, le_refl 0⟩ : Obj F.Duration)) (l := ⟨p, hp⟩) (rres hp) τ₁
        = Beh.restrictTr (l' := (⟨0, le_refl 0⟩ : Obj F.Duration))
            (l := ⟨l - p, sub_nonneg.mpr hpl⟩) (lres (sub_nonneg.mpr hpl)) τ₂
      ↔ τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
          = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) := by
  constructor
  · intro h
    have h0 := states_eq_of_eq h 0 (by exact ⟨le_rfl, le_rfl⟩) (by exact ⟨le_rfl, le_rfl⟩)
    simp only [Beh.restrictTr, rres, lres] at h0
    rw [Beh.restrict_states (p - 0) 0 _ _ _ τ₁ 0 _
          (Beh.mem_dom τ₁ (by simpa using hp) (by simp)),
        Beh.restrict_states 0 0 _ _ _ τ₂ 0 _
          (Beh.mem_dom τ₂ (by simp) (by simpa using sub_nonneg.mpr hpl))] at h0
    rw [PartialHistory.states_eq_of_time_eq τ₁.val (p - 0 + 0) p (by simp) _
          (Beh.mem_dom τ₁ hp le_rfl),
        PartialHistory.states_eq_of_time_eq τ₂.val (0 + 0) 0 (by simp) _
          (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))] at h0
    exact h0
  · intro h
    refine Beh.ext (partialHistory_ext rfl ?_)
    intro r hr hr'
    have hr0 : r = 0 := le_antisymm hr.2 hr.1
    subst hr0
    simp only [Beh.restrictTr, rres, lres] at hr hr' ⊢
    rw [Beh.restrict_states (p - 0) 0 _ _ _ τ₁ 0 hr
          (Beh.mem_dom τ₁ (by simpa using hp) (by simp)),
        Beh.restrict_states 0 0 _ _ _ τ₂ 0 hr'
          (Beh.mem_dom τ₂ (by simp) (by simpa using sub_nonneg.mpr hpl))]
    rw [PartialHistory.states_eq_of_time_eq τ₁.val (p - 0 + 0) p (by simp) _
          (Beh.mem_dom τ₁ hp le_rfl),
        PartialHistory.states_eq_of_time_eq τ₂.val (0 + 0) 0 (by simp) _
          (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))]
    exact h

/-- **The *Sheaf* clause, at the site.** The same `∃!` as `sheaf_clause`, stated along the two
members of the Johnstone covering family rather than at raw offsets. It is the raw clause read
through `restrictTr_coverLeft` and `restrictTr_coverRight`, both of which are `rfl` — no
transport, no cast. This closes the loop `cover_germ_composites` opens: that theorem says the two
covering morphisms meet in one point, and this says the sheaf condition over that coverage holds.
-/
theorem sheaf_clause_site (hcomp : TaskFrame.Compositional F.TaskRel) (l : Obj F.Duration)
    (p : ↑F.Duration) (hp : 0 ≤ p) (hpl : p ≤ l.val)
    (τ₁ : Beh F p) (τ₂ : Beh F (l.val - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    ∃! υ : Beh F l.val,
      Beh.restrictTr (coverLeft l p hp hpl) υ = τ₁ ∧
      Beh.restrictTr (coverRight l p hp hpl) υ = τ₂ := by
  simp only [restrictTr_coverLeft, restrictTr_coverRight]
  exact sheaf_clause hcomp hp hpl τ₁ τ₂ hmatch

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
