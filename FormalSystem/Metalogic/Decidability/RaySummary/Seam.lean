/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary
import FormalSystem.PlusLanguage.PlusRayFibre

/-!
# The seam interface — the `⊡` bridge against an abstract realization hypothesis

This module connects the keystone `FormalSystem.PlusLanguage.plusStab_iff_omega` to the
`k`-type summary substrate (`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`), stated
against a hypothesis bundle that **this module does not discharge**. Read the six points in
order; (c) is the one that matters most.

**(a) The keystone.** `plusStab_iff_omega` restates `⊡φ` at a seam `(τ, t)` as a universal
quantification over `SeqPair F (τ.state t)` — the pairs of a backward ω-sequence and a forward
ω-sequence out of the seam state, i.e. a backward ray glued to a forward ray. Checking `⊡φ`
therefore means summarising a quantification over *all* such pairs: a universal,
complementation-shaped device over the time axis.

**(b) The substrate.** The `KTypeSummary/` cluster summarises a coloured `ℤ`-block by its family
triple `(τneg, τzero, τpos)` (`family_cover`) and makes every `k`-type-determined target constant
on a family (`family_saturation`, via `kTypeOf_zFiber_eq_of_inFamily`).

**(c) What the bundle actually says — the characterization in `SeamMulti.lean`.** The
single-family bundle below is inhabited, for some `T` and `S` and for *every* `sig` and `k`,
**iff** `φ` is `⊡`-decided at the seam — `⊡φ ∨ ⊡¬φ` (`exists_presents_iff`, with
`SeamDecided`). So `colours` in this shape is a **seam condition**, false in general (a regular
`ℤ`-frame seam with no inhabitant for any parameters is exhibited in the wired evidence probe
`specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`), and not the
MSO-over-`⟨ℤ,<⟩` reduction. The reduction's shape is the **multi-family** one: over a two-letter
trace encoding, `⊡φ` at the seam is a finite conjunction over the *realized* family triples
`Hit` with no hypothesis bundle at all (`plusStab_iff_forall_hit`), the four-field
`PresentsMulti` is inhabited outright (`presentsMulti_seamTrace`), and the reduction's entire
remaining content is computing `Hit`, which nothing in the tree does. The one-family restriction
is exactly what collapses this bundle to seam decidedness: a seam whose ray pairs spread over
several families is summarised by finitely many triples (`finite_family_triples`,
`target_eq_union_of_families`), and `SeamMulti.lean` is that generalisation.

**(d) Joint realization, not one-sided liveness.** In the quasimodel route (Hodkinson–Wolter–
Zakharyaschev, APAL 106 (2000), Definition 12 and Lemma 17) a quasistate is a bare set of types,
and the splice of Lemma 17 can create a realised type the model lacked — lethal to a `⊡`-label,
which quantifies over histories through a *state*. The bundle therefore demands that every block
of the summary's family be **realized** by an actual ray pair through the seam
(`Presents.realized`), rather than that each ray be live on its own. The tree's finite-width
analogues of this obligation are `PlusSlicedCertificate.live_iff` and
`PlusSlicedCertificate.stab_factors`.

**(e) The alphabet licence.** `FormalSystem.Metalogic.Conservativity.plusTruthAt_iff_atomize` is
what lets a consumer take `φ` `⊡`-free with a finite alphabet of atoms along the ray, so that a
colouring `c : sig.preds → ℤ → Prop` can carry everything the per-time summary needs.

**(f) Scope.** Discharging this single-family bundle for a concrete frame is exactly deciding
the seam (`exists_presents_iff`); the consumer's real target is `Hit` and
`plusStab_iff_forall_hit`. This module builds no decision procedure, proves no decidability
result, and claims no complexity bound.

## Main definitions and results

* `SeamSummary` — the consumer-facing datum: a family triple reached through the seam and a
  `Bool` verdict.
* `Presents` — the hypothesis bundle, four fields, each named for the obligation it carries.
* `plusStab_iff_seamSummary` — the `⊡` bridge: under `Presents`, `⊡φ` holds at the seam iff the
  summary's verdict is `true`.

## References

* [D. M. Gabbay, A. Kurucz, F. Wolter, M. Zakharyaschev, *Many-Dimensional Modal
  Logics*][gabbay2003manyvalued], Theorem 1.28, Lemma 11.23, Theorem 13.6 (the quasimodel frame).
* I. Hodkinson, F. Wolter, M. Zakharyaschev, *Decidable fragments of first-order temporal
  logics*, Annals of Pure and Applied Logic 106 (2000), Definition 12, Theorem 14, Lemma 17.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.PlusLanguage FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Expressiveness FormalSystem.Semantics

/-! ## The consumer-facing datum -/

/-- **A seam summary**: the family triple `(τneg, τzero, τpos)` reached through the seam, and
the `Bool` verdict the summary assigns to it. A plain structure over `Fintype` components — no
quotient, no `Set`. -/
structure SeamSummary (sig : MonadicSignature) (k : ℕ) where
  /-- The common `k`-type of the segments below the middle one. -/
  τneg : KType sig k
  /-- The `k`-type of the middle segment. -/
  τzero : KType sig k
  /-- The common `k`-type of the segments above the middle one. -/
  τpos : KType sig k
  /-- The verdict the summary assigns to its family. -/
  holds : Bool

/-! ## The hypothesis bundle -/

/-- **`S` presents `⊡φ` at the seam `(τ, t)` of `M`.** Four hypotheses, none of which this
module discharges. `T` is the module's abstract target on coloured `ℤ`-blocks.

* `colours` — every ray pair through the seam is summarised by a coloured block in the summary's
  **one** family whose `T`-value is the truth of `φ` along that pair. In this single-family
  shape it is a seam condition, not the MSO reduction: the bundle is inhabited iff the seam is
  `⊡`-decided (`exists_presents_iff`, `SeamMulti.lean`; point (c) of the module docstring).
* `determined` — the substrate's own hypothesis: `T` is determined by the block's `k`-type;
  discharged for a depth-`k` normal form by `determinedByKType_nfEval`.
* `realized` — the joint-realization obligation (point (d)): every block of the summary's family
  is realized by some ray pair through the seam whose `φ`-truth is the block's `T`-value. It is
  joint and not one-sided because of the Lemma 17 splice hazard.
* `verdict` — the summary's `Bool` is `T` read at one representative block of its family; by
  saturation that is `T` on every block of the family, which is what makes a single `Bool` an
  honest summary. This is the fourth field: without it `holds` would be unconstrained.
-/
structure Presents {F : FrameOver intOrder} [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ)
    (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k) : Prop where
  /-- Every ray pair is summarised by a block of the summary's one family carrying `φ`'s truth
  along it as its `T`-value. In this shape the field is seam decidedness, not the MSO reduction
  (`exists_presents_iff`, `SeamMulti.lean`). -/
  colours : ∀ bf : SeqPair F (τ.state t), ∃ c : sig.preds → ℤ → Prop,
    InFamily sig k S.τneg S.τzero S.τpos c ∧
      (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c)
  /-- The target is determined by the block's `k`-type. -/
  determined : DeterminedByKType sig k T
  /-- Joint realization through the seam: every block of the family is some ray pair's block. -/
  realized : ∀ c : sig.preds → ℤ → Prop, InFamily sig k S.τneg S.τzero S.τpos c →
    ∃ bf : SeqPair F (τ.state t),
      (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c)
  /-- The verdict is `T` at a representative block of the family. -/
  verdict : ∃ c : sig.preds → ℤ → Prop,
    InFamily sig k S.τneg S.τzero S.τpos c ∧ (S.holds = true ↔ T c)

/-! ## The bridge -/

/-- **The `⊡` bridge.** Under `Presents`, `⊡φ` holds at the seam iff the summary's verdict is
`true`. Forward: `⊡φ` makes `φ` true along every ray pair (`plusStab_iff_omega`); the
representative block of `verdict` is realized by some pair (`realized`), so `T` holds there and
the verdict is `true`. Backward: the verdict gives `T` at the representative; by saturation
(`family_saturation`, from `determined`) the family is wholly inside `T`; every ray pair is
summarised by a block of the family (`colours`), so `φ` holds along it. Nothing here reduces
`⊡` to anything: the hypothesis `colours` is, in this single-family shape, equivalent to the
seam being decided (`exists_presents_iff`); the hypothesis-free bridge over the realized triples
is `plusStab_iff_forall_hit` in `SeamMulti.lean`. -/
theorem plusStab_iff_seamSummary {F : FrameOver intOrder} [F.IsRegular]
    {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame} {t : ℤ} {φ : PlusFormula}
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : ℕ}
    {T : (sig.preds → ℤ → Prop) → Prop} {S : SeamSummary sig k}
    (h : Presents M τ t φ sig k T S) :
    PlusTruthAt M τ t (.stab φ) ↔ S.holds = true := by
  rw [plusStab_iff_omega]
  obtain ⟨c₀, hc₀, hverdict⟩ := h.verdict
  constructor
  · intro hall
    obtain ⟨bf, hbf⟩ := h.realized c₀ hc₀
    exact hverdict.mpr (hbf.mp (hall bf))
  · intro hholds bf
    obtain ⟨c, hc, hbf⟩ := h.colours bf
    have hT₀ : T c₀ := hverdict.mp hholds
    rcases family_saturation sig k h.determined S.τneg S.τzero S.τpos with hin | hout
    · exact hbf.mpr (hin c hc)
    · exact absurd hT₀ (hout c₀ hc₀)

end FormalSystem.Metalogic.Decidability.RaySummary
