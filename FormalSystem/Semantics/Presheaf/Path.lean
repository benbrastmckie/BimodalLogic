/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import Mathlib.CategoryTheory.Functor.Basic
import Mathlib.Combinatorics.Quiver.Path
import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Presheaf.Duration
import FormalSystem.Semantics.IntNormalFormEffective

/-!
# The path category `Path(F)` and the discrete Conduché fibration `len`

The categorical packaging of a task frame's convex histories: `Path(F)` is the category whose
objects are the world states and whose morphisms `w → u` of length `l` are the sections
`τ ∈ Beh F l` with `τ(0) = w` and `τ(l) = u`, composing by gluing at the shared endpoint and
with the germs — the one-point sections — as identities. The **length functor**
`len : Path(F) → BD⁺` reads off each morphism's length, and the content of `cor:path-fibration`
is that `len` is a **discrete Conduché fibration** whose associated presheaf is `Beh F` itself.
Over `D = ℤ` the whole package is the free category on the one-step task graph `(W, ⇒₁)`.

## The HARD SCOPE LIMIT: an instance, not Johnstone's theorem

`fact:conduche-equivalence` — for any temporal order `D` and any sheaf `X` on `Int(D)`, the length
functor on the associated category of `X` is a discrete Conduché fibration whose associated
presheaf is naturally isomorphic to `X`, these assignments constituting an equivalence between the
sheaves on `Int(D)` and the discrete Conduché fibrations over `BD⁺` — is a **cited, external
fact**. The paper states it without proof, attributing it to Johnstone (Prop. 3.6) and to Schultz,
Spivak and Vasilakopoulou (Thm. A.2.1), and this module does **not** prove it. What this module
builds is the **instance at `X = Beh F`**: it constructs `Path(F)` directly from the sections of
`Beh F`, proves the three category laws from the *Sheaf* clause, and proves the fibration property
of `len` for this one functor. The two general notions of `def:conduche` — the *associated
category of a sheaf* and the *associated presheaf of a fibration* — are therefore **instantiated**
here (`Path(F)` **is** the associated category of `Beh F`; `PathHom.assocRestrict` **is** the
associated presheaf of `len`) and **not defined in general**: no declaration below constructs a
category from an arbitrary sheaf or a presheaf from an arbitrary fibration. The one general
declaration, `IsDiscreteConduche`, is the fibration *predicate* of `def:conduche`, stated so that
`len` can be shown to satisfy it. A reader must not mistake the instance for the theorem, and a
later editor who finds the general proof cheap at this site has a finding to report, not a licence
to expand this module.

## What `Path(F)` is here

A morphism `w → u` is a `PathHom F w u`: a length `len : Dur F.Duration`, a section
`sec : Beh F len.val`, and the two endpoint equations `src : sec(0) = w` and `tgt : sec(len) = u`.
The objects are the world states, which the *Germs* clause of `app:presheaf-dictionary`
(`Beh.germEquiv`) identifies with the sections over `0`; so the identity at `w` is the germ
`Beh.ofGerm F w` at length `0`, and composition is the *Sheaf* clause: two sections meeting at a
state glue to one section over the summed length (`glueSum`, the sum form of `Sheaf.lean`'s
`glue`). **The length lives in the hom, not in the type**: `PathHom F w u` is a Σ-type over
`Dur F.Duration`, so `PathHom.comp` is total and `len` is a plain projection, and the three
category laws reduce by `PathHom.ext'` to a `Dur` law on the lengths plus a `PartialHistory`
equation on the sections — no `HEq`, no transport along `Dur.comp_assoc`.

## Why `Mathlib.CategoryTheory` enters here and nowhere else in the cluster

`Site.lean`, `Duration.lean` and `Reflection.lean` record the decision to state the site, the
duration monoid and the twisted-arrow category concretely, with no `Mathlib.CategoryTheory`
import, and `Duration.lean`'s Implementation Notes defer the re-weighing of that decision to the
path-category work. The weighing comes out the other way here, for one reason: the first
deliverable — a discrete Conduché fibration `P : E → BD⁺` *in general* — is unstatable without
categories and functors, since it quantifies over a functor into `BD⁺` from an arbitrary category.
`Mathlib.CategoryTheory.Functor.Basic` is therefore imported, minimally. The `Category` instances
sit **only on synonyms** introduced in this module — `BObj D` (the one object of `BD⁺`),
`PathCat F` (a synonym of `F.WorldState`), and the `Quiver` instance on `StepGraph F` (another
synonym of `F.WorldState`) — never on `Obj D`, `Dur D`, `Int(D)`, `Tr`, or `F.WorldState` itself,
so no instance leaks onto a cluster type and `Site.lean`/`Duration.lean` stay exactly as they
are. The cluster's `assert_not_exists` lock on the proof system is unaffected: Mathlib's category
theory is not `FormalSystem.ProofSystem`.

## Reuse, not rebuild

`glueSum` is `glue` at the cut `l₁` under the val-preserving cast `Beh.castLen`, and its four
reading lemmas delegate to `restrict_glue_left`/`restrict_glue_right`; the four-case
`respects_task` argument of `Sheaf.lean` is proved once and consumed here. The `D = ℤ` clause
consumes `FrameOver.step`, `iter`, and the choice-free `FrameOver.taskRel_natCast_iff_iter`
("iterating *Compositionality*"), `FrameOver.reflection_int` and `FrameOver.taskRel_eq_iter_int`
of `Semantics/IntNormalForm.lean` and `Semantics/IntNormalFormEffective.lean`, rather than
re-deriving the adjacency characterization that `Semantics/ShiftFiniteType.lean` already
describes.

## Main Definitions

- `Beh.castLen`: the val-preserving cast of a section along an equation of lengths.
- `glueSum`: the *Sheaf* clause in sum form — a section over `l₁` and one over `l₂` meeting at
  the seam glue to a section over `l₁ + l₂`.
- `PathHom F w u`: a morphism of `Path(F)` — a length, a section of that length, and its two
  endpoint equations.
- `PathHom.id`, `PathHom.comp`: the germ at `w`, and composition by `glueSum`.
- `BObj D`: the one object of `BD⁺`, with the `Category` instance whose homs are `Dur D`.
- `PathCat F`: the synonym of `F.WorldState` carrying the `Category` instance of `Path(F)`.
- `PathCat.len`: the length functor `Path(F) ⥤ BD⁺`.
- `IsDiscreteConduche P`: the discrete Conduché fibration predicate of `def:conduche`, for a
  functor `P : E ⥤ BObj D`.
- `PathHom.cutState`, `PathHom.factorLeft`, `PathHom.factorRight`: the unique factorization of a
  morphism along a factorization of its length.
- `PathHom.assocRestrict`: the associated presheaf of `len` — restriction along `Tr p : l' → l`
  as the middle factor of the three-fold factorization.
- `Beh.ofAdjacentWindow`: over `D = ℤ`, the section built from an adjacency-respecting function
  on `[0, n]`.
- `StepGraph F`, `StepPath F w u`: the one-step task graph `(W, ⇒₁)` as a `Quiver`, on a synonym,
  and its paths.
- `PathHom.toPath`, `PathHom.ofPath`, `PathHom.pathEquiv`: the bijection between morphisms of
  `Path(F)` and paths in `(W, ⇒₁)` over `D = ℤ`.

## Main Results

- `glueSum_restrict_left`, `glueSum_restrict_right`, `glueSum_states_zero`, `glueSum_states_end`:
  the two restriction identities and the two endpoint readings of sum-form gluing.
- `PathHom.ext'`: two morphisms with the same length and the same underlying partial history are
  equal — the principle every category law reduces to.
- `PathHom.id_comp`, `PathHom.comp_id`, `PathHom.comp_assoc`: the three category laws, each
  through uniqueness of gluing (`glue_unique`), never by unfolding `glue`.
- `PathCat.len_map`: `len` reads off the length, by `rfl`.
- `PathHom.factor_comp`, `PathHom.factor_unique`: the cast-free, `PathHom`-level existence and
  uniqueness of the factorization of a morphism along a factorization of its length.
- `PathCat.len_isDiscreteConduche`: **the first half of `cor:path-fibration`** — `len` is a
  discrete Conduché fibration.
- `PathHom.assocRestrict_sec`, `PathHom.assocRestrict_unique`, `PathHom.assocRestrict_id`,
  `PathHom.assocRestrict_comp`: **the second half** — the associated presheaf of `len` is `Beh F`,
  as an equality (see below).
- `iter_of_adjacent_window`, `beh_int_iff_adjacent_window`: over `D = ℤ`, a function on `[0, n]`
  is the state function of a section iff it respects adjacency at every step.
- `PathHom.toPath_length`, `PathHom.toPath_id`, `PathHom.toPath_comp`, `PathHom.ofPath_toPath`,
  `PathHom.toPath_ofPath`: sections are paths, identities are the empty paths, gluing is
  concatenation, and the two are in bijection.

## Implementation Notes

**The cast kit is load-bearing, and `castLen` must stay val-preserving.** `Beh.castLen h τ` is
`⟨τ.val, _⟩` — the same underlying partial history with the interval condition re-read along
`h : l = l'` — so `Beh.castLen_val` is `rfl` and the seam hypothesis of `glueSum` is accepted by
`exact` (definitionally) rather than by rewriting. Every comparison of sections in this module is
made at the `.val` level through `castLen_val` and `Beh.ext`, where the order proofs carried by
`Beh.restrict` are irrelevant. A later refactor of `castLen` to a `▸`-based transport would
silently break every `comp` in the module; this note is the record of why it is written as it is.

**The sum form is the cut form under that cast.** `Sheaf.lean`'s Implementation Notes record that
the sum form of gluing "buys nothing" for the *Sheaf* clause itself. For composition in `Path(F)`
it is exactly what is consumed, and it costs one line: `glueSum` is `glue` at the cut `l₁` applied
to `castLen` of the second section, and its lemmas delegate to `restrict_glue_left` and
`restrict_glue_right`. Nothing in `Sheaf.lean` moves.

**The category laws go through `glue_unique`, never through `glue`'s `dite`.** `Sheaf.lean` paid
once for the four-case `respects_task` argument and for the `r = 0` subtlety of the right
restriction identity; the laws here read endpoints through the two restriction identities and
characterize every glued section by `glue_unique`. No proof below case-splits on the seam.

**Synonyms carry every instance.** `BObj D` carries the `Category` instance of `BD⁺`,
`PathCat F` that of `Path(F)`, and `StepGraph F` the `Quiver` instance of `(W, ⇒₁)`. A bare
`def`-valued `Quiver F.WorldState` is not found by instance synthesis, so the synonym is a
requirement, not a style choice; and placing an instance on `F.WorldState` or `Dur D` directly
would leak it into every module of the cluster.

**Paper state: the source appendix is cut.** As for the sibling modules, the anchors cited below
live in `app:Structure`, which the paper **cut in full** under an explicit `% SECTION CUT` record;
the text is kept verbatim, still commented, in the paper repository's `appendix_cut_material.tex`.
They resolve against `docs/reference/paper-definitions-of-record.md`, where each carries a
`DANGLING` row, and not against a live `\label{}`; `scripts/check-paper-definitions.sh --resolve`
structurally cannot pin a commented-out label, so none is pinned.

**Forwarded appendix item: the translation product and the pullback of `len` (posed, not
built).** For the translation product of a task frame — states `W × D`, same duration group, and
`(w, s) ⇒ₓ (v, t)` iff `w ⇒ₓ v` and `t = s + x`, which is `FrameOver.translationProduct` of
`FormalSystem/Semantics/Frames/TranslationProduct.lean` (`prodRel`, `liftH`, `projH`) — a
`PathHom (prodFrame F).toTaskFrame (w, d) (v, e)` of length `l` projects to a `PathHom F w v` of
length `l` with `e = d + l`. That is the shape of the pullback of `len : Path(F) → BD⁺` along the
functor `(D, ≤) → BD⁺` sending `d ≤ e` to the duration `e - d`. Three questions are posed here
and settled nowhere in this module: (a) is `Path(prodFrame F)` that pullback on the nose, with the
projection to `Path(F)` as the pullback leg? (b) is `len` restricted to it the height functor to
`(D, ≤)`, and does the discrete Conduché property transfer? (c) do `liftH`/`projH` — unique lifts
of total histories — express that the pullback along a *poset* is a discrete fibration over `D`?
The product's path category is the natural test case for the pullback reading once this module
exists; nothing here depends on the answers.

## References

* [P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999], Introduction and
  §2 — the discrete Conduché fibrations and the twisted-arrow site; Prop. 3.6 — the equivalence
  with sheaves, **cited only**
* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  Def. A.1.1 and §§A.2-A.3 — the associated category at `Int` and the free category on a graph;
  Prop. 3.2.3 — sheaves on `Int_ℕ` as graphs; Thm. A.2.1 — the equivalence for factorization-linear
  categories, **cited only**
* JPL paper `def:conduche` — discrete Conduché fibration, associated presheaf, associated
  category, length functor. **`DANGLING`**: cut from the paper with `app:Structure` and recorded in
  `docs/reference/paper-definitions-of-record.md`
* JPL paper `def:path-category` — `Path(F)` as the associated category of `Beh(F)`.
  **`DANGLING`**, as above
* JPL paper `fact:conduche-equivalence` — Johnstone's general equivalence, **cited and external**;
  not proved here. **`DANGLING`**, as above
* JPL paper `cor:path-fibration` — the theorem this module formalizes at the instance `Beh F`,
  including its `D = ℤ` clause. **`DANGLING`**, as above
* JPL paper `app:presheaf-dictionary` — the *Germs* and *Sheaf* clauses this module composes over.
  **`DANGLING`**, as above
* JPL paper `lem:nullity` — `⇒₀` is the identity, the fact that makes the germs identities.
  Live anchor
* JPL paper `app:Structure` — the cut appendix containing the four cut anchors. **`DANGLING`**,
  as above
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrict`, `Beh.restrictTr`,
  `Beh.ofGerm`, `Beh.germEquiv`
* `FormalSystem/Semantics/Presheaf/Sheaf.lean` — `glue`, `restrict_glue_left`,
  `restrict_glue_right`, `glue_unique`, `states_eq_of_eq`
* `FormalSystem/Semantics/Presheaf/Duration.lean` — `Dur`, `Dur.comp`, `Dur.id` and their laws;
  `Factorization`
* `FormalSystem/Semantics/IntNormalForm.lean` — `FrameOver.step`, `iter`,
  `FrameOver.taskRel_natCast_iff_iter`
* `FormalSystem/Semantics/IntNormalFormEffective.lean` — the choice-free `FrameOver.reflection_int`
  and `FrameOver.taskRel_eq_iter_int`
* `FormalSystem/Semantics/ShiftFiniteType.lean` — the finite-carrier reading of the same graph
  `(W, ⇒₁)`
* Mathlib `CategoryTheory.Paths.categoryPaths` — the free category on a quiver
  (`Hom := Quiver.Path`, `id := Path.nil`, `comp := Path.comp`), the definition the `D = ℤ`
  clause matches without importing it

## Tags

path-category · conduché-fibration · length-functor · associated-presheaf · free-category ·
sheaf-clause · germs-clause · cor:path-fibration
-/

namespace FormalSystem.Semantics.Presheaf

open CategoryTheory

variable {F : TaskFrame}

/-! ### The cast kit -/

/-- **The val-preserving cast of a section along an equation of lengths.** The underlying partial
history is unchanged; only the interval condition is re-read along `h`. This is what makes
`castLen_val` hold by `rfl`, and the whole module compares sections at the `.val` level through it.

Constraints consumed: None -/
def Beh.castLen {l l' : F.Duration} (h : l = l') (τ : Beh F l) : Beh F l' :=
  ⟨τ.val, fun t => by rw [← h]; exact τ.property t⟩

/-- The cast preserves the underlying partial history, definitionally.

Constraints consumed: None -/
@[simp] theorem Beh.castLen_val {l l' : F.Duration} (h : l = l') (τ : Beh F l) :
    (Beh.castLen h τ).val = τ.val := rfl

/-- A cast section equals a section over the target length exactly when their underlying partial
histories agree.

Constraints consumed: None -/
theorem Beh.castLen_eq_iff {l l' : F.Duration} (h : l = l') (τ : Beh F l) (σ : Beh F l') :
    Beh.castLen h τ = σ ↔ τ.val = σ.val :=
  ⟨fun e => by rw [← e]; rfl, fun e => Beh.ext e⟩

/-! ### Sum-form gluing -/

/-- **The glued section, in sum form**: a section over `l₁` and a section over `l₂` whose states
agree at the seam — `τ₁` at `l₁`, `τ₂` at `0` — determine a section over `l₁ + l₂`. It is
`Sheaf.lean`'s `glue` at the cut `l₁`, applied to `τ₂` cast along `l₂ = l₁ + l₂ - l₁`; the seam
hypothesis is accepted definitionally because the cast preserves `.val`.

Constraints consumed: Compositionality -/
def glueSum (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) : Beh F (l₁ + l₂) :=
  glue hcomp h₁ (le_add_of_nonneg_right h₂) τ₁
    (Beh.castLen (add_sub_cancel_left l₁ l₂).symm τ₂) hmatch

/-- **Left restriction identity, sum form**: the glued section restricted to `[0, l₁]` is `τ₁`.
Delegates to `restrict_glue_left`.

Constraints consumed: Compositionality -/
theorem glueSum_restrict_left (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    Beh.restrict 0 l₁ le_rfl h₁ (by rw [zero_add]; exact le_add_of_nonneg_right h₂)
      (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch) = τ₁ :=
  restrict_glue_left hcomp h₁ (le_add_of_nonneg_right h₂) τ₁
    (Beh.castLen (add_sub_cancel_left l₁ l₂).symm τ₂) hmatch

/-- **Right restriction identity, sum form**: the glued section restricted to `[l₁, l₁ + l₂]` is
`τ₂`. Delegates to `restrict_glue_right`, whose conclusion lands in `Beh F (l₁ + l₂ - l₁)` and is
brought to `Beh F l₂` at the `.val` level.

Constraints consumed: Compositionality -/
theorem glueSum_restrict_right (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    Beh.restrict l₁ l₂ h₁ h₂ le_rfl (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch) = τ₂ := by
  have hR := restrict_glue_right hcomp h₁ (le_add_of_nonneg_right h₂) τ₁
    (Beh.castLen (add_sub_cancel_left l₁ l₂).symm τ₂) hmatch
  refine Beh.ext (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ l₂) = τ₂.val.domain z
    exact propext (τ₂.property z).symm
  · intro r hr h'
    have hdom : (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch).val.domain (l₁ + r) :=
      ⟨add_nonneg h₁ hr.1, add_le_add (le_refl l₁) hr.2⟩
    have hd2 : (Beh.restrict l₁ (l₁ + l₂ - l₁) h₁ (sub_nonneg.mpr (le_add_of_nonneg_right h₂))
        (by rw [add_sub_cancel]) (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch)).val.domain r :=
      ⟨hr.1, by rw [add_sub_cancel_left]; exact hr.2⟩
    have h1 := states_eq_of_eq hR r hd2 h'
    rw [Beh.restrict_states l₁ l₂ h₁ h₂ le_rfl _ r hr hdom]
    exact h1

/-- **The glued section at `0` is `τ₁` at `0`.** Read through the left restriction identity.

Constraints consumed: Compositionality -/
theorem glueSum_states_zero (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch).val.states 0
        (Beh.mem_dom _ le_rfl (add_nonneg h₁ h₂))
      = τ₁.val.states 0 (Beh.mem_dom τ₁ le_rfl h₁) := by
  have hd1 : (Beh.restrict 0 l₁ le_rfl h₁ (by rw [zero_add]; exact le_add_of_nonneg_right h₂)
      (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch)).val.domain 0 := ⟨le_rfl, h₁⟩
  have h00 : (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch).val.domain (0 + 0) := by
    rw [add_zero]; exact Beh.mem_dom _ le_rfl (add_nonneg h₁ h₂)
  have h1 := states_eq_of_eq (glueSum_restrict_left hcomp h₁ h₂ τ₁ τ₂ hmatch) 0 hd1
    (Beh.mem_dom τ₁ le_rfl h₁)
  rw [Beh.restrict_states 0 l₁ le_rfl h₁ (by rw [zero_add]; exact le_add_of_nonneg_right h₂)
      _ 0 hd1 h00,
    PartialHistory.states_eq_of_time_eq _ (0 + 0) 0 (add_zero 0) h00
      (Beh.mem_dom _ le_rfl (add_nonneg h₁ h₂))] at h1
  exact h1

/-- **The glued section at `l₁ + l₂` is `τ₂` at `l₂`.** Read through the right restriction
identity.

Constraints consumed: Compositionality -/
theorem glueSum_states_end (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch).val.states (l₁ + l₂)
        (Beh.mem_dom _ (add_nonneg h₁ h₂) le_rfl)
      = τ₂.val.states l₂ (Beh.mem_dom τ₂ h₂ le_rfl) := by
  have hd : (Beh.restrict l₁ l₂ h₁ h₂ le_rfl (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch)).val.domain l₂ :=
    ⟨h₂, le_rfl⟩
  have h1 := states_eq_of_eq (glueSum_restrict_right hcomp h₁ h₂ τ₁ τ₂ hmatch) l₂ hd
    (Beh.mem_dom τ₂ h₂ le_rfl)
  rw [Beh.restrict_states l₁ l₂ h₁ h₂ le_rfl _ l₂ hd
    (Beh.mem_dom _ (add_nonneg h₁ h₂) le_rfl)] at h1
  exact h1

/-! ### The morphisms of `Path(F)` -/

/-- **A morphism `w → u` of `Path(F)`**: a length `len`, a section `sec` of `Beh F` over that
length, and the two endpoint equations `sec(0) = w` and `sec(len) = u`. The length is carried in the
hom rather than in the type, so that composition is total and `len` is a plain projection; this is
`def:path-category`'s "section `τ ∈ Beh(F)(l)` with `τ(0) = w` and `τ(l) = u`" with `l` packaged
alongside `τ`. -/
structure PathHom (F : TaskFrame) (w u : F.WorldState) where
  /-- The length of the morphism: a duration. -/
  len : Dur F.Duration
  /-- The section of `Beh F` over the length. -/
  sec : Beh F len.val
  /-- The section starts at `w`. -/
  src : sec.val.states 0 (Beh.mem_dom sec le_rfl len.property) = w
  /-- The section ends at `u`. -/
  tgt : sec.val.states len.val (Beh.mem_dom sec len.property le_rfl) = u

/-- **Extensionality for morphisms**: equal lengths and equal underlying partial histories give
equal morphisms. Every category law below reduces through this to a `Dur` equation plus a
`PartialHistory` equation — no `HEq`, no transport.

Constraints consumed: None -/
theorem PathHom.ext' {w u : F.WorldState} {f g : PathHom F w u} (hl : f.len = g.len)
    (hs : f.sec.val = g.sec.val) : f = g := by
  obtain ⟨l, s, hs₁, ht₁⟩ := f
  obtain ⟨l', s', hs₂, ht₂⟩ := g
  simp only at hl hs
  subst hl
  have : s = s' := Subtype.ext hs
  subst this
  rfl

/-- **The identity at `w`**: the germ `Beh.ofGerm F w` at length `0`. Its two endpoint equations
hold by `rfl`. The proof term reaches *Seriality* and *Limit* through `Beh.ofGerm`'s use of
`nullity_identity`; the marker lists the whole bundle the binder supplies.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
def PathHom.id (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : PathHom F w w :=
  ⟨Dur.id, Beh.ofGerm F w, rfl, rfl⟩

/-- **Composition in `Path(F)`**: the *Sheaf* clause. The two sections meet at `u` — `f.tgt` and
`g.src` supply the seam hypothesis — and glue, in sum form, to a section over the summed length;
the endpoints are read through `glueSum_states_zero` and `glueSum_states_end`. The hypotheses are
rewritten, never the goal: `rw [← f.src]` on the goal fails because `f` depends on `w`.

Constraints consumed: Compositionality -/
def PathHom.comp (hcomp : TaskFrame.Compositional F.TaskRel) {w u v : F.WorldState}
    (f : PathHom F w u) (g : PathHom F u v) : PathHom F w v where
  len := Dur.comp f.len g.len
  sec := glueSum hcomp f.len.property g.len.property f.sec g.sec (f.tgt.trans g.src.symm)
  src := (glueSum_states_zero hcomp f.len.property g.len.property f.sec g.sec
    (f.tgt.trans g.src.symm)).trans f.src
  tgt := (glueSum_states_end hcomp f.len.property g.len.property f.sec g.sec
    (f.tgt.trans g.src.symm)).trans g.tgt

/-- The length of a composite is the composite of the lengths in `BD⁺`, by `rfl`.

Constraints consumed: Compositionality -/
@[simp] theorem PathHom.comp_len (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u v : F.WorldState} (f : PathHom F w u) (g : PathHom F u v) :
    (PathHom.comp hcomp f g).len = Dur.comp f.len g.len := rfl

/-- The length of an identity is the identity of `BD⁺`, by `rfl`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
@[simp] theorem PathHom.id_len (F : TaskFrame) [F.IsRegular] (w : F.WorldState) :
    (PathHom.id F w).len = Dur.id := rfl

/-- **Left unit law**: the germ at `w` composed with `f` is `f`. The length half is `Dur.id_comp`;
the section half characterizes the glued section by `glue_unique` against `f.sec` cast to length
`0 + l`: its left restriction to `[0, 0]` is the germ at `f(0) = w` (`Beh.ofGerm_germ`), and its
right restriction onto `0 + l - 0` is `f.sec` itself.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
theorem PathHom.id_comp [F.IsRegular] {w u : F.WorldState} (f : PathHom F w u) :
    PathHom.comp F.comp (PathHom.id F w) f = f := by
  refine PathHom.ext' (Dur.id_comp f.len) ?_
  have hpl : (0 : F.Duration) ≤ 0 + f.len.val := le_add_of_nonneg_right f.len.property
  let υ : Beh F (0 + f.len.val) := Beh.castLen (zero_add f.len.val).symm f.sec
  have hL : Beh.restrict 0 0 le_rfl le_rfl (by rw [zero_add]; exact hpl) υ = Beh.ofGerm F w := by
    have h : Beh.germ (Beh.restrict 0 0 le_rfl le_rfl (by rw [zero_add]; exact hpl) υ) = w := by
      change f.sec.val.states (0 + 0) _ = w
      exact (PartialHistory.states_eq_of_time_eq f.sec.val (0 + 0) 0 (add_zero 0) _
        (Beh.mem_dom f.sec le_rfl f.len.property)).trans f.src
    exact (Beh.ofGerm_germ _).symm.trans (congrArg (Beh.ofGerm F) h)
  have hR : Beh.restrict 0 (0 + f.len.val - 0) le_rfl (sub_nonneg.mpr hpl)
      (by rw [add_sub_cancel]) υ = Beh.castLen (add_sub_cancel_left 0 f.len.val).symm f.sec := by
    refine Beh.ext (partialHistory_ext ?_ ?_)
    · funext z
      change (0 ≤ z ∧ z ≤ 0 + f.len.val - 0) = f.sec.val.domain z
      rw [zero_add, sub_zero]
      exact propext (f.sec.property z).symm
    · intro r hr h'
      change f.sec.val.states (0 + r) _ = f.sec.val.states r h'
      exact PartialHistory.states_eq_of_time_eq f.sec.val (0 + r) r (zero_add r) _ h'
  have hu := glue_unique F.comp le_rfl hpl (Beh.ofGerm F w)
    (Beh.castLen (add_sub_cancel_left 0 f.len.val).symm f.sec)
    ((PathHom.id F w).tgt.trans f.src.symm) υ hL hR
  exact (congrArg Subtype.val hu).symm

/-- **Right unit law**: `f` composed with the germ at `u` is `f`. The length half is `Dur.comp_id`;
the section half characterizes the glued section by `glue_unique` against `f.sec` cast to length
`l + 0`: its left restriction to `[0, l]` is `f.sec`, and its right restriction onto `l + 0 - l` is
the one-point section at `f(l) = u`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
theorem PathHom.comp_id [F.IsRegular] {w u : F.WorldState} (f : PathHom F w u) :
    PathHom.comp F.comp f (PathHom.id F u) = f := by
  refine PathHom.ext' (Dur.comp_id f.len) ?_
  have hpl : f.len.val ≤ f.len.val + 0 := le_add_of_nonneg_right le_rfl
  let υ : Beh F (f.len.val + 0) := Beh.castLen (add_zero f.len.val).symm f.sec
  have hL : Beh.restrict 0 f.len.val le_rfl f.len.property (by rw [zero_add]; exact hpl) υ
      = f.sec := by
    refine Beh.ext (partialHistory_ext ?_ ?_)
    · funext z
      change (0 ≤ z ∧ z ≤ f.len.val) = f.sec.val.domain z
      exact propext (f.sec.property z).symm
    · intro r hr h'
      change f.sec.val.states (0 + r) _ = f.sec.val.states r h'
      exact PartialHistory.states_eq_of_time_eq f.sec.val (0 + r) r (zero_add r) _ h'
  have hR : Beh.restrict f.len.val (f.len.val + 0 - f.len.val) f.len.property (sub_nonneg.mpr hpl)
      (by rw [add_sub_cancel]) υ
      = Beh.castLen (add_sub_cancel_left f.len.val 0).symm (Beh.ofGerm F u) := by
    refine Beh.ext (partialHistory_ext ?_ ?_)
    · funext z
      change (0 ≤ z ∧ z ≤ f.len.val + 0 - f.len.val) = (0 ≤ z ∧ z ≤ 0)
      rw [add_sub_cancel_left]
    · intro r hr _
      have hr2 : r ≤ 0 := by
        have := hr.2
        rwa [add_sub_cancel_left] at this
      have hr0 : r = 0 := le_antisymm hr2 hr.1
      subst hr0
      change f.sec.val.states (f.len.val + 0) _ = u
      exact (PartialHistory.states_eq_of_time_eq f.sec.val (f.len.val + 0) f.len.val (add_zero _) _
        (Beh.mem_dom f.sec f.len.property le_rfl)).trans f.tgt
  have hu := glue_unique F.comp f.len.property hpl f.sec
    (Beh.castLen (add_sub_cancel_left f.len.val 0).symm (Beh.ofGerm F u))
    (f.tgt.trans (PathHom.id F u).src.symm) υ hL hR
  exact (congrArg Subtype.val hu).symm

/-! ### The duration monoid as a one-object category -/

/-- **The one object of `BD⁺`.** A synonym structure rather than `Unit` itself, so that the
`Category` instance below sits on a type this module owns and leaks onto nothing. -/
structure BObj (D : TemporalOrder) where
  /-- The single object. -/
  unit : Unit

/-- **`BD⁺` as a Mathlib category**: one object, homs the durations `Dur D`, composition
`Dur.comp` and identity `Dur.id`, with the three laws of `Presheaf/Duration.lean` verbatim. This is
the reconciliation `Duration.lean`'s Implementation Notes promised: `Dur.id`/`Dur.comp` with those
laws are exactly the fields a `Category` instance needs.

Constraints consumed: None -/
instance BObj.instCategory (D : TemporalOrder) : Category (BObj D) where
  Hom _ _ := Dur D
  id _ := Dur.id
  comp f g := Dur.comp f g
  id_comp := Dur.id_comp
  comp_id := Dur.comp_id
  assoc := Dur.comp_assoc

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
