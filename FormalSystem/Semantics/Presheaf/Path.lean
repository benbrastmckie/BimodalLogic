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
  `PathHom.assocRestrict_comp`: **the second half** — the associated presheaf of `len` is `Beh F`
  **itself, as an equality and not merely up to natural isomorphism**. Same sections: a morphism
  of length `l` is a `Beh F l` with two endpoint equations. Same restriction: `def:conduche`
  restricts along `Tr p : l' → l` to the middle factor of the unique three-fold factorization,
  and that middle factor's section **is** `Beh.restrictTr` — `assocRestrict_sec` closes by `rfl`,
  because the middle factor is *defined* as the restriction and `assocRestrict_unique` is the
  theorem that any middle factor has that section. Same functoriality: `assocRestrict_id` and
  `assocRestrict_comp` are `Beh.restrictTr_id` and `Beh.restrictTr_comp`. This is why the paper's
  proof of `cor:path-fibration` can claim equality where `fact:conduche-equivalence` returns only a
  natural isomorphism, and it is how the "associated presheaf of a fibration" of `def:conduche` is
  instantiated at `len` without being defined in general.
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

/-! ### Associativity, the path category, and the length functor -/

/-- **Associativity of composition.** The length half is `Dur.comp_assoc`. The section half
characterizes the right-nested glued section by `glue_unique` against the left-nested one cast to
length `l₁ + (l₂ + l₃)`: its left restriction to `[0, l₁]` is `f.sec` (the left restriction
identity read twice, through `[0, l₁ + l₂]`), and its right restriction onto `l₂ + l₃` is the glued
section of `g` and `h` — itself characterized by `glue_unique` from the two restriction identities
of the left-nested section. Every comparison is made at the `.val` level, where the order proofs
carried by `Beh.restrict` are irrelevant; `glue`'s seam `dite` is never unfolded.

Constraints consumed: Compositionality -/
theorem PathHom.comp_assoc (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u v x : F.WorldState} (f : PathHom F w u) (g : PathHom F u v) (h : PathHom F v x) :
    PathHom.comp hcomp (PathHom.comp hcomp f g) h
      = PathHom.comp hcomp f (PathHom.comp hcomp g h) := by
  refine PathHom.ext' (Dur.comp_assoc f.len g.len h.len) ?_
  have h₁ := f.len.property
  have h₂ := g.len.property
  have h₃ := h.len.property
  have hassoc : f.len.val + (g.len.val + h.len.val) ≤ f.len.val + g.len.val + h.len.val :=
    le_of_eq (add_assoc f.len.val g.len.val h.len.val).symm
  have hpl : f.len.val ≤ f.len.val + (g.len.val + h.len.val) :=
    le_add_of_nonneg_right (add_nonneg h₂ h₃)
  -- the left-nested section, read at the right-nested length
  let υ : Beh F (f.len.val + (g.len.val + h.len.val)) :=
    Beh.castLen (add_assoc f.len.val g.len.val h.len.val)
      (PathHom.comp hcomp (PathHom.comp hcomp f g) h).sec
  -- its restriction onto `[l₁, l₁ + l₂ + l₃]` is the glued section of `g` and `h`
  have hL' : Beh.restrict 0 g.len.val le_rfl h₂
      (by rw [zero_add]; exact le_add_of_nonneg_right h₃)
      (Beh.restrict f.len.val (g.len.val + h.len.val) h₁ (add_nonneg h₂ h₃) hassoc
        (PathHom.comp hcomp (PathHom.comp hcomp f g) h).sec) = g.sec := by
    refine Beh.ext (partialHistory_ext ?_ ?_)
    · funext z
      change (0 ≤ z ∧ z ≤ g.len.val) = g.sec.val.domain z
      exact propext (g.sec.property z).symm
    · intro r hr h'
      have hr' : 0 + r ≤ g.len.val + h.len.val := by
        rw [zero_add]; exact le_trans hr.2 (le_add_of_nonneg_right h₃)
      rw [Beh.restrict_states 0 g.len.val le_rfl h₂
          (by rw [zero_add]; exact le_add_of_nonneg_right h₃) _ r hr
          ⟨add_nonneg le_rfl hr.1, hr'⟩,
        Beh.restrict_states f.len.val (g.len.val + h.len.val) h₁ (add_nonneg h₂ h₃) hassoc
          (PathHom.comp hcomp (PathHom.comp hcomp f g) h).sec (0 + r) ⟨add_nonneg le_rfl hr.1, hr'⟩
          (Beh.mem_dom _ (add_nonneg h₁ (add_nonneg le_rfl hr.1))
            (le_trans (add_le_add (le_refl f.len.val) hr') hassoc))]
      have hA := states_eq_of_eq (glueSum_restrict_left hcomp (add_nonneg h₁ h₂) h₃
        (PathHom.comp hcomp f g).sec h.sec ((PathHom.comp hcomp f g).tgt.trans h.src.symm))
        (f.len.val + r) ⟨add_nonneg h₁ hr.1, add_le_add (le_refl f.len.val) hr.2⟩
        (Beh.mem_dom _ (add_nonneg h₁ hr.1) (add_le_add (le_refl f.len.val) hr.2))
      have hB := states_eq_of_eq (glueSum_restrict_right hcomp h₁ h₂ f.sec g.sec
        (f.tgt.trans g.src.symm)) r hr h'
      have hw2 : (PathHom.comp hcomp (PathHom.comp hcomp f g) h).sec.val.domain
          (0 + (f.len.val + r)) :=
        Beh.mem_dom _ (add_nonneg le_rfl (add_nonneg h₁ hr.1))
          (by
            rw [zero_add]
            exact le_trans (add_le_add (le_refl f.len.val) hr.2) (le_add_of_nonneg_right h₃))
      exact (PartialHistory.states_eq_of_time_eq _ (f.len.val + (0 + r)) (0 + (f.len.val + r))
        (by rw [zero_add, zero_add]) _ hw2).trans (hA.trans hB)
  have hR' : Beh.restrict g.len.val (g.len.val + h.len.val - g.len.val) h₂
      (sub_nonneg.mpr (le_add_of_nonneg_right h₃)) (by rw [add_sub_cancel])
      (Beh.restrict f.len.val (g.len.val + h.len.val) h₁ (add_nonneg h₂ h₃) hassoc
        (PathHom.comp hcomp (PathHom.comp hcomp f g) h).sec)
      = Beh.castLen (add_sub_cancel_left g.len.val h.len.val).symm h.sec := by
    refine Beh.ext (partialHistory_ext ?_ ?_)
    · funext z
      change (0 ≤ z ∧ z ≤ g.len.val + h.len.val - g.len.val) = h.sec.val.domain z
      rw [add_sub_cancel_left]
      exact propext (h.sec.property z).symm
    · intro r hr h'
      have hr3 : r ≤ h.len.val := by
        have := hr.2
        rwa [add_sub_cancel_left] at this
      rw [Beh.restrict_states g.len.val (g.len.val + h.len.val - g.len.val) h₂
          (sub_nonneg.mpr (le_add_of_nonneg_right h₃)) (by rw [add_sub_cancel]) _ r hr
          ⟨add_nonneg h₂ hr.1, add_le_add (le_refl g.len.val) hr3⟩,
        Beh.restrict_states f.len.val (g.len.val + h.len.val) h₁ (add_nonneg h₂ h₃) hassoc
          (PathHom.comp hcomp (PathHom.comp hcomp f g) h).sec (g.len.val + r)
          ⟨add_nonneg h₂ hr.1, add_le_add (le_refl g.len.val) hr3⟩
          (Beh.mem_dom _ (add_nonneg h₁ (add_nonneg h₂ hr.1))
            (le_trans (add_le_add (le_refl f.len.val) (add_le_add (le_refl g.len.val) hr3))
              hassoc))]
      have hC := states_eq_of_eq (glueSum_restrict_right hcomp (add_nonneg h₁ h₂) h₃
        (PathHom.comp hcomp f g).sec h.sec ((PathHom.comp hcomp f g).tgt.trans h.src.symm))
        r ⟨hr.1, hr3⟩ h'
      exact (PartialHistory.states_eq_of_time_eq _ (f.len.val + (g.len.val + r))
        (f.len.val + g.len.val + r) (add_assoc f.len.val g.len.val r).symm _
        (Beh.mem_dom _ (add_nonneg (add_nonneg h₁ h₂) hr.1)
          (add_le_add (le_refl (f.len.val + g.len.val)) hr3))).trans hC
  have hu' := glue_unique hcomp h₂ (le_add_of_nonneg_right h₃) g.sec
    (Beh.castLen (add_sub_cancel_left g.len.val h.len.val).symm h.sec)
    (g.tgt.trans h.src.symm)
    (Beh.restrict f.len.val (g.len.val + h.len.val) h₁ (add_nonneg h₂ h₃) hassoc
      (PathHom.comp hcomp (PathHom.comp hcomp f g) h).sec) hL' hR'
  -- the two restriction identities of the right-nested gluing, for the cast left-nested section
  have hL : Beh.restrict 0 f.len.val le_rfl h₁ (by rw [zero_add]; exact hpl) υ = f.sec := by
    refine Beh.ext (partialHistory_ext ?_ ?_)
    · funext z
      change (0 ≤ z ∧ z ≤ f.len.val) = f.sec.val.domain z
      exact propext (f.sec.property z).symm
    · intro r hr h'
      have hw : υ.val.domain (0 + r) :=
        Beh.mem_dom υ (add_nonneg le_rfl hr.1) (by rw [zero_add]; exact le_trans hr.2 hpl)
      rw [Beh.restrict_states 0 f.len.val le_rfl h₁ (by rw [zero_add]; exact hpl) υ r hr hw]
      have hA := states_eq_of_eq (glueSum_restrict_left hcomp (add_nonneg h₁ h₂) h₃
        (PathHom.comp hcomp f g).sec h.sec ((PathHom.comp hcomp f g).tgt.trans h.src.symm))
        r ⟨hr.1, le_trans hr.2 (le_add_of_nonneg_right h₂)⟩
        (Beh.mem_dom _ hr.1 (le_trans hr.2 (le_add_of_nonneg_right h₂)))
      have hB := states_eq_of_eq (glueSum_restrict_left hcomp h₁ h₂ f.sec g.sec
        (f.tgt.trans g.src.symm)) r hr h'
      have hw2 : (PathHom.comp hcomp f g).sec.val.domain (0 + r) :=
        Beh.mem_dom _ (add_nonneg le_rfl hr.1)
          (by
            rw [zero_add]
            exact le_trans hr.2 (le_add_of_nonneg_right h₂))
      exact hA.trans ((PartialHistory.states_eq_of_time_eq _ r (0 + r) (zero_add r).symm _
        hw2).trans hB)
  have hR : Beh.restrict f.len.val (f.len.val + (g.len.val + h.len.val) - f.len.val) h₁
      (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ
      = Beh.castLen (add_sub_cancel_left f.len.val (g.len.val + h.len.val)).symm
          (PathHom.comp hcomp g h).sec := by
    refine Beh.ext (partialHistory_ext ?_ ?_)
    · funext z
      change (0 ≤ z ∧ z ≤ f.len.val + (g.len.val + h.len.val) - f.len.val)
        = (PathHom.comp hcomp g h).sec.val.domain z
      rw [add_sub_cancel_left]
      exact propext ((PathHom.comp hcomp g h).sec.property z).symm
    · intro r hr h'
      have hr23 : r ≤ g.len.val + h.len.val := by
        have := hr.2
        rwa [add_sub_cancel_left] at this
      exact states_eq_of_eq hu' r ⟨hr.1, hr23⟩ h'
  have hu := glue_unique hcomp h₁ hpl f.sec
    (Beh.castLen (add_sub_cancel_left f.len.val (g.len.val + h.len.val)).symm
      (PathHom.comp hcomp g h).sec)
    (f.tgt.trans (PathHom.comp hcomp g h).src.symm) υ hL hR
  exact congrArg Subtype.val hu

/-- **The path category `Path(F)` as a type**: a synonym of `F.WorldState`, so that the
`Category` instance below sits on a type this module owns and no instance is placed on
`F.WorldState` itself. Its objects are the world states — the *Germs* clause's identification of
the germs of `Beh F` with the states of `F`. -/
def PathCat (F : TaskFrame) : Type := F.WorldState

/-- **`Path(F)` as a Mathlib category**: homs the morphisms `PathHom F w u`, identities the germs,
composition by gluing, with the three laws proved above. `F.comp` supplies *Compositionality* to
`PathHom.comp`; the identities reach *Seriality* and *Limit* through `Beh.ofGerm`. This is
`def:path-category`'s `Path(F) := Beh(F)‾`, the associated category of `Beh F`, built directly.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
instance PathCat.instCategory (F : TaskFrame) [F.IsRegular] : Category (PathCat F) where
  Hom w u := PathHom F w u
  id w := PathHom.id F w
  comp f g := PathHom.comp F.comp f g
  id_comp f := PathHom.id_comp f
  comp_id f := PathHom.comp_id f
  assoc f g h := PathHom.comp_assoc F.comp f g h

/-- **The length functor `len : Path(F) ⥤ BD⁺`**: every object to the one object of `BD⁺`, every
morphism to its length. Functoriality is `rfl` on both counts, because `PathHom.id` has length
`Dur.id` and `PathHom.comp` has length `Dur.comp` definitionally. This is `def:conduche`'s length
functor, instantiated at `X = Beh F`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
def PathCat.len (F : TaskFrame) [F.IsRegular] : PathCat F ⥤ BObj F.Duration where
  obj _ := ⟨()⟩
  map f := f.len
  map_id _ := rfl
  map_comp _ _ := rfl

/-- `len` reads off the length of a morphism, by `rfl`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
theorem PathCat.len_map (F : TaskFrame) [F.IsRegular] {w u : PathCat F} (f : w ⟶ u) :
    (PathCat.len F).map f = PathHom.len f := rfl

/-! ### The discrete Conduché fibration property of `len` -/

/-- **Discrete Conduché fibrations over `BD⁺`** — the first clause of `def:conduche`, stated in
general: a functor `P : E ⥤ BD⁺` is a discrete Conduché fibration when every morphism `e : A ⟶ B`
and every factorization `P(e) = x + y` of its image into two durations (a `Factorization (P.map e)`)
admit a **unique** pair `e₁ : A ⟶ C`, `e₂ : C ⟶ B` with `e = e₂ ∘ e₁`, `P(e₁) = x`, `P(e₂) = y`.
The predicate is general so that `PathCat.len` can be shown to satisfy it
(`PathCat.len_isDiscreteConduche`); **no construction from a general fibration is built here** —
the associated presheaf of a general fibration is the half of the cited, external
`fact:conduche-equivalence` this module instantiates at `len` only (the HARD SCOPE LIMIT).

Constraints consumed: None -/
def IsDiscreteConduche {D : TemporalOrder} {E : Type*} [Category E] (P : E ⥤ BObj D) : Prop :=
  ∀ {A B : E} (e : A ⟶ B) (fac : Factorization (P.map e)),
    ∃! t : Σ C : E, (A ⟶ C) × (C ⟶ B),
      t.2.1 ≫ t.2.2 = e ∧ (P.map t.2.1).val = fac.fst ∧ (P.map t.2.2).val = fac.snd

/-- **The cut state**: the state a morphism passes through at the cut point `fac.fst` of a
factorization of its length — the object `C` of the unique factorization.

Constraints consumed: None -/
def PathHom.cutState {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    F.WorldState :=
  e.sec.val.states fac.fst (Beh.mem_dom e.sec fac.fst_nonneg fac.fst_le)

/-- **The left factor**: the restriction of `e` to `[0, fac.fst]`, a morphism `w → cutState`.

Constraints consumed: None -/
def PathHom.factorLeft {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom F w (e.cutState fac) where
  len := ⟨fac.fst, fac.fst_nonneg⟩
  sec := Beh.restrict 0 fac.fst le_rfl fac.fst_nonneg (by rw [zero_add]; exact fac.fst_le) e.sec
  src := (PartialHistory.states_eq_of_time_eq e.sec.val (0 + 0) 0 (add_zero 0) _
    (Beh.mem_dom e.sec le_rfl e.len.property)).trans e.src
  tgt := PartialHistory.states_eq_of_time_eq e.sec.val (0 + fac.fst) fac.fst (zero_add _) _
    (Beh.mem_dom e.sec fac.fst_nonneg fac.fst_le)

/-- **The right factor**: the restriction of `e` to `[fac.fst, fac.fst + fac.snd]`, a morphism
`cutState → u`.

Constraints consumed: None -/
def PathHom.factorRight {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom F (e.cutState fac) u where
  len := ⟨fac.snd, fac.snd_nonneg⟩
  sec := Beh.restrict fac.fst fac.snd fac.fst_nonneg fac.snd_nonneg (le_of_eq fac.add_eq) e.sec
  src := PartialHistory.states_eq_of_time_eq e.sec.val (fac.fst + 0) fac.fst (add_zero _) _
    (Beh.mem_dom e.sec fac.fst_nonneg fac.fst_le)
  tgt := (PartialHistory.states_eq_of_time_eq e.sec.val (fac.fst + fac.snd) e.len.val fac.add_eq _
    (Beh.mem_dom e.sec e.len.property le_rfl)).trans e.tgt

/-- The left factor has length `fac.fst`, by `rfl`.

Constraints consumed: None -/
@[simp] theorem PathHom.factorLeft_len {w u : F.WorldState} (e : PathHom F w u)
    (fac : Factorization e.len) : (e.factorLeft fac).len.val = fac.fst := rfl

/-- The right factor has length `fac.snd`, by `rfl`.

Constraints consumed: None -/
@[simp] theorem PathHom.factorRight_len {w u : F.WorldState} (e : PathHom F w u)
    (fac : Factorization e.len) : (e.factorRight fac).len.val = fac.snd := rfl

/-- **Existence of the factorization**: the two factors compose to `e`. The length half is
`fac.add_eq`; the section half characterizes the glued section by `glue_unique` against `e.sec` cast
to length `fac.fst + fac.snd`, whose two restrictions are the two factors by definition.

Constraints consumed: Compositionality -/
theorem PathHom.factor_comp (hcomp : TaskFrame.Compositional F.TaskRel) {w u : F.WorldState}
    (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom.comp hcomp (e.factorLeft fac) (e.factorRight fac) = e := by
  refine PathHom.ext' (Subtype.ext fac.add_eq) ?_
  have hpl : fac.fst ≤ fac.fst + fac.snd := le_add_of_nonneg_right fac.snd_nonneg
  let υ : Beh F (fac.fst + fac.snd) := Beh.castLen fac.add_eq.symm e.sec
  have hL : Beh.restrict 0 fac.fst le_rfl fac.fst_nonneg (by rw [zero_add]; exact hpl) υ
      = (e.factorLeft fac).sec := by
    refine Beh.ext (partialHistory_ext rfl ?_)
    intro r hr h'
    rfl
  have hR : Beh.restrict fac.fst (fac.fst + fac.snd - fac.fst) fac.fst_nonneg (sub_nonneg.mpr hpl)
      (by rw [add_sub_cancel]) υ
      = Beh.castLen (add_sub_cancel_left fac.fst fac.snd).symm (e.factorRight fac).sec := by
    refine Beh.ext (partialHistory_ext ?_ ?_)
    · funext z
      change (0 ≤ z ∧ z ≤ fac.fst + fac.snd - fac.fst) = (0 ≤ z ∧ z ≤ fac.snd)
      rw [add_sub_cancel_left]
    · intro r hr h'
      rfl
  have hu := glue_unique hcomp fac.fst_nonneg hpl (e.factorLeft fac).sec
    (Beh.castLen (add_sub_cancel_left fac.fst fac.snd).symm (e.factorRight fac).sec)
    ((e.factorLeft fac).tgt.trans (e.factorRight fac).src.symm) υ hL hR
  exact (congrArg Subtype.val hu).symm

/-- **Uniqueness of the factorization, at the `PathHom` level and cast-free**: any pair `e₁`, `e₂`
composing to `e` with the lengths of the factorization passes through the cut state and has the two
factors' underlying partial histories. Read off `glueSum_restrict_left`/`glueSum_restrict_right`
for `e₁`, `e₂` against `e` through `h`; the `.val`-level statement keeps the dependent equality
`c = cutState` out of the section equations, so no transport appears.

Constraints consumed: Compositionality -/
theorem PathHom.factor_unique (hcomp : TaskFrame.Compositional F.TaskRel) {w u : F.WorldState}
    (e : PathHom F w u) (fac : Factorization e.len) {c : F.WorldState}
    (e₁ : PathHom F w c) (e₂ : PathHom F c u) (h : PathHom.comp hcomp e₁ e₂ = e)
    (h₁ : e₁.len.val = fac.fst) (h₂ : e₂.len.val = fac.snd) :
    c = e.cutState fac ∧ e₁.sec.val = (e.factorLeft fac).sec.val
      ∧ e₂.sec.val = (e.factorRight fac).sec.val := by
  have key : ∀ {σ τ : PartialHistory F} (hστ : σ = τ) (r : F.Duration) (hσ : σ.domain r)
      (hτ : τ.domain r), σ.states r hσ = τ.states r hτ := by
    intro σ τ hστ r hσ hτ
    subst hστ
    rfl
  have hv : (PathHom.comp hcomp e₁ e₂).sec.val = e.sec.val :=
    congrArg (fun x : PathHom F w u => x.sec.val) h
  have hl₁ := e₁.len.property
  have hl₂ := e₂.len.property
  have hLeft := glueSum_restrict_left hcomp hl₁ hl₂ e₁.sec e₂.sec (e₁.tgt.trans e₂.src.symm)
  have hRight := glueSum_restrict_right hcomp hl₁ hl₂ e₁.sec e₂.sec (e₁.tgt.trans e₂.src.symm)
  have hfst_le : e₁.len.val ≤ e.len.val := by rw [h₁]; exact fac.fst_le
  refine ⟨?_, ?_, ?_⟩
  · refine e₁.tgt.symm.trans ?_
    have hG : (PathHom.comp hcomp e₁ e₂).sec.val.domain (0 + e₁.len.val) :=
      Beh.mem_dom _ (by rw [zero_add]; exact hl₁)
        (by rw [zero_add]; exact le_add_of_nonneg_right hl₂)
    have hE : e.sec.val.domain (0 + e₁.len.val) :=
      Beh.mem_dom e.sec (by rw [zero_add]; exact hl₁) (by rw [zero_add]; exact hfst_le)
    have s1 := states_eq_of_eq hLeft e₁.len.val ⟨hl₁, le_rfl⟩ (Beh.mem_dom e₁.sec hl₁ le_rfl)
    have s2 := key hv (0 + e₁.len.val) hG hE
    have s3 := PartialHistory.states_eq_of_time_eq e.sec.val (0 + e₁.len.val) fac.fst
      (by rw [zero_add]; exact h₁) hE (Beh.mem_dom e.sec fac.fst_nonneg fac.fst_le)
    exact s1.symm.trans (s2.trans s3)
  · refine partialHistory_ext ?_ ?_
    · funext z
      change e₁.sec.val.domain z = (0 ≤ z ∧ z ≤ fac.fst)
      rw [← h₁]
      exact propext (e₁.sec.property z)
    · intro r hr h'
      have hr0 : 0 ≤ r := ((e₁.sec.property r).mp hr).1
      have hrl : r ≤ e₁.len.val := ((e₁.sec.property r).mp hr).2
      have hG : (PathHom.comp hcomp e₁ e₂).sec.val.domain (0 + r) :=
        Beh.mem_dom _ (by rw [zero_add]; exact hr0)
          (by rw [zero_add]; exact le_trans hrl (le_add_of_nonneg_right hl₂))
      have hE : e.sec.val.domain (0 + r) :=
        Beh.mem_dom e.sec (by rw [zero_add]; exact hr0)
          (by rw [zero_add]; exact le_trans hrl hfst_le)
      have s1 := states_eq_of_eq hLeft r ⟨hr0, hrl⟩ hr
      have s2 := key hv (0 + r) hG hE
      exact s1.symm.trans s2
  · refine partialHistory_ext ?_ ?_
    · funext z
      change e₂.sec.val.domain z = (0 ≤ z ∧ z ≤ fac.snd)
      rw [← h₂]
      exact propext (e₂.sec.property z)
    · intro r hr h'
      have hr0 : 0 ≤ r := ((e₂.sec.property r).mp hr).1
      have hrl : r ≤ e₂.len.val := ((e₂.sec.property r).mp hr).2
      have hr_snd : r ≤ fac.snd := by rw [← h₂]; exact hrl
      have hfr : fac.fst + r ≤ e.len.val :=
        le_trans (add_le_add (le_refl fac.fst) hr_snd) (le_of_eq fac.add_eq)
      have hG : (PathHom.comp hcomp e₁ e₂).sec.val.domain (e₁.len.val + r) :=
        Beh.mem_dom _ (add_nonneg hl₁ hr0) (add_le_add (le_refl e₁.len.val) hrl)
      have hE : e.sec.val.domain (e₁.len.val + r) :=
        Beh.mem_dom e.sec (add_nonneg hl₁ hr0) (by rw [h₁]; exact hfr)
      have hE' : e.sec.val.domain (fac.fst + r) :=
        Beh.mem_dom e.sec (add_nonneg fac.fst_nonneg hr0) hfr
      have s1 := states_eq_of_eq hRight r ⟨hr0, hrl⟩ hr
      have s2 := key hv (e₁.len.val + r) hG hE
      have s3 := PartialHistory.states_eq_of_time_eq e.sec.val (e₁.len.val + r) (fac.fst + r)
        (by rw [h₁]) hE hE'
      exact s1.symm.trans (s2.trans s3)

/-- **The first half of `cor:path-fibration`: `len : Path(F) ⥤ BD⁺` is a discrete Conduché
fibration.** Existence is the pair of factors with `factor_comp` and the two length readings;
uniqueness is `factor_unique`, after which the one dependent equality `c = cutState` is
substituted and the two factors are identified by `PathHom.ext'`. This is the fibration property
of the instance at `X = Beh F`; the general equivalence it is an instance of is cited, not proved.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
theorem PathCat.len_isDiscreteConduche (F : TaskFrame) [F.IsRegular] :
    IsDiscreteConduche (PathCat.len F) := by
  intro A B e fac
  refine ⟨⟨PathHom.cutState e fac, (PathHom.factorLeft e fac, PathHom.factorRight e fac)⟩,
    ⟨PathHom.factor_comp F.comp e fac, rfl, rfl⟩, ?_⟩
  rintro ⟨c, e₁, e₂⟩ ⟨h, h₁, h₂⟩
  obtain ⟨hc, hs₁, hs₂⟩ := PathHom.factor_unique F.comp e fac e₁ e₂ h h₁ h₂
  subst hc
  have he₁ : e₁ = PathHom.factorLeft e fac := PathHom.ext' (Subtype.ext h₁) hs₁
  have he₂ : e₂ = PathHom.factorRight e fac := PathHom.ext' (Subtype.ext h₂) hs₂
  subst he₁
  subst he₂
  rfl

/-! ### The associated presheaf of `len` is `Beh F` -/

/-- **The associated presheaf of `len`, as restriction along a site morphism**: for `f : Tr l' l`
and a morphism `e` of length `l`, the middle factor of the three-fold factorization of `e` over
`l = f.shift + l' + (l - f.shift - l')` — a morphism of length `l'` from `e(f.shift)` to
`e(f.shift + l')` whose section is **by definition** `Beh.restrictTr f` of `e`'s section. The
endpoints are carried in the Σ-type because the middle factor's source and target are determined
by `e` and `f`, not given in advance.

Constraints consumed: None -/
def PathHom.assocRestrict {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) : Σ c c' : F.WorldState, PathHom F c c' :=
  have hlv : e.len.val = l.val := congrArg Subtype.val hl
  have hs : f.shift ≤ e.len.val := by
    rw [hlv]; exact le_trans (le_add_of_nonneg_right l'.property) f.shift_add_le
  have hsl : f.shift + l'.val ≤ e.len.val := by rw [hlv]; exact f.shift_add_le
  ⟨e.sec.val.states f.shift (Beh.mem_dom e.sec f.shift_nonneg hs),
   e.sec.val.states (f.shift + l'.val)
     (Beh.mem_dom e.sec (add_nonneg f.shift_nonneg l'.property) hsl),
   { len := l'
     sec := Beh.restrictTr f (Beh.castLen hlv e.sec)
     src := PartialHistory.states_eq_of_time_eq e.sec.val (f.shift + 0) f.shift (add_zero _) _
       (Beh.mem_dom e.sec f.shift_nonneg hs)
     tgt := rfl }⟩

/-- The middle factor has length `l'`, by `rfl`.

Constraints consumed: None -/
theorem PathHom.assocRestrict_len {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict f e hl).2.2.len = l' := rfl

/-- **The equality `cor:path-fibration`'s proof claims**: the section of the middle factor **is**
the restriction of `def:behavior-presheaf`, `z ↦ τ(f.shift + z)` on `[0, l']`, by `rfl`. It is
available where `fact:conduche-equivalence` yields only a natural isomorphism because the middle
factor is *defined* as the restriction; uniqueness (`assocRestrict_unique`) is a theorem about it,
not an input to it.

Constraints consumed: None -/
theorem PathHom.assocRestrict_sec {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict f e hl).2.2.sec.val
      = (Beh.restrictTr f (Beh.castLen (congrArg Subtype.val hl) e.sec)).val := rfl

/-- **Uniqueness of the middle factor**: any three-fold factorization `e = e₃ ∘ e₂ ∘ e₁` of `e`
with `P(e₁) = f.shift` and `P(e₂) = l'` has `e₂`'s section equal to the associated restriction's.
`factor_unique` applied twice — first cutting `e` at `f.shift` (after re-associating `h`), then
cutting the right factor at `l'` — followed by one `.val`-level reading of the nested restriction.

Constraints consumed: Compositionality -/
theorem PathHom.assocRestrict_unique (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l) (e : PathHom F w u)
    (hl : e.len = l) {c c' : F.WorldState} (e₁ : PathHom F w c) (e₂ : PathHom F c c')
    (e₃ : PathHom F c' u) (h : PathHom.comp hcomp (PathHom.comp hcomp e₁ e₂) e₃ = e)
    (h₁ : e₁.len.val = f.shift) (h₂ : e₂.len.val = l'.val) :
    e₂.sec.val = (PathHom.assocRestrict f e hl).2.2.sec.val := by
  have h' : PathHom.comp hcomp e₁ (PathHom.comp hcomp e₂ e₃) = e :=
    (PathHom.comp_assoc hcomp e₁ e₂ e₃).symm.trans h
  have hlen' : e₁.len.val + (PathHom.comp hcomp e₂ e₃).len.val = e.len.val :=
    congrArg (fun x : PathHom F w u => x.len.val) h'
  -- the first cut, at `f.shift`; the factorization is introduced opaquely so that `c` can be
  -- substituted without a dependency cycle through it
  obtain ⟨fac₁, hf₁, hf₂⟩ : ∃ fac : Factorization e.len,
      fac.fst = f.shift ∧ fac.snd = (PathHom.comp hcomp e₂ e₃).len.val :=
    ⟨⟨f.shift, (PathHom.comp hcomp e₂ e₃).len.val, f.shift_nonneg,
      (PathHom.comp hcomp e₂ e₃).len.property, by rw [← h₁]; exact hlen'⟩, rfl, rfl⟩
  obtain ⟨hc, -, hs23⟩ := PathHom.factor_unique hcomp e fac₁ e₁ (PathHom.comp hcomp e₂ e₃) h'
    (h₁.trans hf₁.symm) hf₂.symm
  subst hc
  have hg : PathHom.comp hcomp e₂ e₃ = e.factorRight fac₁ :=
    PathHom.ext' (Subtype.ext hf₂.symm) hs23
  -- the second cut, at `l'` inside the right factor
  obtain ⟨fac₂, hg₁, hg₂⟩ : ∃ fac : Factorization (e.factorRight fac₁).len,
      fac.fst = l'.val ∧ fac.snd = e₃.len.val :=
    ⟨⟨l'.val, e₃.len.val, l'.property, e₃.len.property, by
      change l'.val + e₃.len.val = fac₁.snd
      rw [hf₂, ← h₂]
      rfl⟩, rfl, rfl⟩
  obtain ⟨-, hs₂, -⟩ := PathHom.factor_unique hcomp (e.factorRight fac₁) fac₂ e₂ e₃ hg
    (h₂.trans hg₁.symm) hg₂.symm
  refine hs₂.trans (partialHistory_ext ?_ ?_)
  · funext z
    change (0 ≤ z ∧ z ≤ fac₂.fst) = (0 ≤ z ∧ z ≤ l'.val)
    rw [hg₁]
  · intro r hr h'
    exact PartialHistory.states_eq_of_time_eq e.sec.val (fac₁.fst + (0 + r)) (f.shift + r)
      (by rw [hf₁, zero_add]) _ _

/-- **Functoriality of the associated presheaf, identity**: restricting along `Tr.id` returns the
section — `Beh.restrictTr_id`, read at the `.val` level so that no transport along
`assocRestrict_len` appears.

Constraints consumed: None -/
theorem PathHom.assocRestrict_id {w u : F.WorldState} (e : PathHom F w u) :
    (PathHom.assocRestrict (Tr.id e.len) e rfl).2.2.sec.val = e.sec.val :=
  congrArg Subtype.val (Beh.restrictTr_id (Beh.castLen (congrArg Subtype.val rfl) e.sec))

/-- **Functoriality of the associated presheaf, composition**: restricting along `f` and then
along `g` is restricting along `Tr.comp f g` — `Beh.restrictTr_comp`, contravariantly, read at
the `.val` level.

Constraints consumed: None -/
theorem PathHom.assocRestrict_comp {w u : F.WorldState} {l'' l' l : Obj F.Duration}
    (f : Tr l' l) (g : Tr l'' l') (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict g (PathHom.assocRestrict f e hl).2.2
        (PathHom.assocRestrict_len f e hl)).2.2.sec.val
      = (PathHom.assocRestrict (Tr.comp f g) e hl).2.2.sec.val :=
  (congrArg Subtype.val
    (Beh.restrictTr_comp f g (Beh.castLen (congrArg Subtype.val hl) e.sec))).symm

/-! ### `D = ℤ`, layer 1: sections over `[0, n]` are the adjacency-respecting windows -/

/-- **An adjacency-respecting window iterates the one-step relation**: for `g : ℤ → W` stepping
along `⇒₁` at every `i ∈ [0, n)`, any `0 ≤ s ≤ t ≤ n` gives an `(t - s)`-fold iterate of `⇒₁` from
`g s` to `g t`. The ℤ-window twin of `Periodicity.iter_of_path`, by induction on the natural
number `k` with `t = s + k`; it consumes only `hg`, no frame constraint.

Constraints consumed: None -/
theorem iter_of_adjacent_window (F : FrameOver intOrder) (n : ℤ) (g : ℤ → F.WorldState)
    (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)))
    (s t : ℤ) (hs : 0 ≤ s) (hst : s ≤ t) (htn : t ≤ n) :
    iter (FrameOver.step F) (Int.toNat (t - s)) (g s) (g t) := by
  have aux : ∀ k : ℕ, s + (k : ℤ) ≤ n → iter (FrameOver.step F) k (g s) (g (s + k)) := by
    intro k
    induction k with
    | zero =>
      intro _
      change g s = g (s + ((0 : ℕ) : ℤ))
      rw [Nat.cast_zero, add_zero]
    | succ k ih =>
      intro hk
      have hk1 : s + (k : ℤ) + 1 ≤ n := by rw [Nat.cast_succ, ← add_assoc] at hk; exact hk
      have hk' : s + (k : ℤ) ≤ n := le_trans (le_add_of_nonneg_right zero_le_one) hk1
      refine ⟨g (s + k), ih hk', ?_⟩
      have hstep := hg (s + k) (add_nonneg hs (Int.natCast_nonneg k))
        (Int.lt_iff_add_one_le.mpr hk1)
      rw [Nat.cast_succ, ← add_assoc]
      exact hstep
  obtain ⟨k, hk⟩ : ∃ k : ℕ, t = s + (k : ℤ) :=
    ⟨(t - s).toNat, by
      rw [Int.toNat_of_nonneg (sub_nonneg.mpr hst)]
      exact (add_sub_cancel s t).symm⟩
  subst hk
  have hkn : Int.toNat (s + (k : ℤ) - s) = k := by
    rw [add_sub_cancel_left]
    exact Int.toNat_natCast k
  rw [hkn]
  exact aux k htn

/-- **The section built from an adjacency-respecting window.** Over `D = ℤ`, a function
`g : ℤ → W` with `g i ⇒₁ g (i + 1)` for every `i ∈ [0, n)` is the state function of a section of
`Beh F` over `n`: its task-respect obligation at `s ≤ t` is "iterating *Compositionality*" —
`FrameOver.taskRel_natCast_iff_iter` applied to `iter_of_adjacent_window` — and at `t < s` the
same read through the reflection convention, `FrameOver.reflection_int`. Both are the choice-free
forms; `⇒₀` being the identity (`lem:nullity` with *Limit*) is what makes the `s = t` case of the
iterate the base case of `taskRel_natCast_iff_iter`. The marker lists the bundle the binder
supplies; the proof reaches it through those two lemmas.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
def Beh.ofAdjacentWindow (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1))) :
    Beh F.toTaskFrame n :=
  ⟨{ domain := fun i => 0 ≤ i ∧ i ≤ n
     nonempty_domain := ⟨0, le_rfl, hn⟩
     states := fun i _ => g i
     respects_task := by
       intro s t hs ht
       rcases le_or_gt s t with hst | hts
       · have hit := iter_of_adjacent_window F n g hg s t hs.1 hst ht.2
         have hcast : ((Int.toNat (t - s) : ℕ) : ℤ) = t - s :=
           Int.toNat_of_nonneg (sub_nonneg.mpr hst)
         have h1 := (F.taskRel_natCast_iff_iter (Int.toNat (t - s)) (g s) (g t)).mpr hit
         rwa [hcast] at h1
       · have hit := iter_of_adjacent_window F n g hg t s ht.1 hts.le hs.2
         have hcast : ((Int.toNat (s - t) : ℕ) : ℤ) = s - t :=
           Int.toNat_of_nonneg (sub_nonneg.mpr hts.le)
         have h1 := (F.taskRel_natCast_iff_iter (Int.toNat (s - t)) (g t) (g s)).mpr hit
         rw [hcast] at h1
         have h2 := (F.reflection_int (g t) (s - t) (g s)).mp h1
         rwa [neg_sub] at h2 },
   fun _ => Iff.rfl⟩

/-- The states of the window section are `g`, by `rfl`.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
theorem Beh.ofAdjacentWindow_states (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)))
    (i : ℤ) (hi : (Beh.ofAdjacentWindow F n hn g hg).val.domain i) :
    (Beh.ofAdjacentWindow F n hn g hg).val.states i hi = g i := rfl

/-- **The first `D = ℤ` sentence of `cor:path-fibration`**: a function on `[0, n]` is the state
function of a section of `Beh F` over `n` exactly when it respects adjacency, `g i ⇒₁ g (i + 1)`
for every `i < n`. Forward: `respects_task` at `(i, i + 1)` is a task of duration `1`, which is
`FrameOver.step` by definition. Backward: `Beh.ofAdjacentWindow`. Negative differences are covered
by the reflection convention inside `ofAdjacentWindow`, as the paper's proof says.

Constraints consumed: Compositionality, Seriality, Limit, Saturation -/
theorem beh_int_iff_adjacent_window (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) :
    (∃ τ : Beh F.toTaskFrame n, ∀ i (hi : τ.val.domain i), τ.val.states i hi = g i)
      ↔ ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)) := by
  constructor
  · rintro ⟨τ, hτ⟩ i hi0 hin
    have hi : τ.val.domain i := Beh.mem_dom τ hi0 hin.le
    have hi1 : τ.val.domain (i + 1) :=
      Beh.mem_dom τ (add_nonneg hi0 zero_le_one) (Int.lt_iff_add_one_le.mp hin)
    have h := τ.val.respects_task i (i + 1) hi hi1
    rw [add_sub_cancel_left, hτ i hi, hτ (i + 1) hi1] at h
    exact h
  · intro hg
    exact ⟨Beh.ofAdjacentWindow F n hn g hg, fun _ _ => rfl⟩

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
