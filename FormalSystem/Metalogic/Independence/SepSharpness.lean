/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.DenseRTimeSharpness
import Mathlib.Data.Finsupp.Lex

/-!
# Sharpness of the `sep` row of `Axiom.minFrameClass`

`Independence/DenseRTimeSharpness.lean` closes three of the four non-`.Base` rows of
`Axiom.minFrameClass` and records, for the fourth, a *proved obstruction* rather than a
refutation: `not_kPlus_of_isLeastPos` and `sep_validOn_of_isLeastPos` show `Axiom.sep` is
vacuously valid on every frame whose durations have a least positive element, so by
`Semantics.duration_dense_or_least_pos` no discrete witness for it can exist. This module closes
that row, over a densely ordered duration group.

## What is claimed, exactly

`sep_minFrameClass_sharp` is **minimality**: `Axiom.sep`'s atomic instance is not valid at any
frame class strictly below `.RTime`, i.e. at neither `.Base` nor `.Dense`, which
`base_or_dense_of_lt_rtime` shows are the only two. That claim comes off a single frame-level
refutation, because `Sat .Dense F` implies `Sat .Base F`.

`sep_validIn_iff` is more than minimality, and its shape is **not** the one the `.Dense` rows
take. `Axiom.sep` is valid at `.ZTime` (`sep_validIn_ztime`) — schematically in `φ`, since
`IsZTime` supplies a `SuccOrder` and hence a least positive duration, feeding the landed
`sep_validOn_of_isLeastPos`. So the characterization is

  `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc`,

**not** `↔ .RTime ≤ fc`, which is false: `.RTime ≰ .ZTime`, yet `sep` is `.ZTime`-valid. Copying
`density_validIn_iff`'s shape mechanically would state something false here. This is the one place
where `sep`'s row genuinely diverges from `prior_U_gap`'s, which deliberately claims nothing at
`.ZTime`.

Every non-validity statement is at an atomic instance (`Formula.atom a`) and that is forced: a
schematic `∀ φ` non-validity claim can be outright false. `sep_validIn_ztime` is schematic
because it is a *validity* claim, where the `∀ φ` form is sound.

## The `sep` row in order language

Reading `Truth.kPlus_iff`, `K⁺φ` at `t` says the φ-region right-accumulates at `t`. So `sep` says:
if the φ-region right-accumulates at `t`, and the φ-points carrying a gapped φ-successor do *not*
right-accumulate at `t`, then the two-sided accumulation points of the φ-region right-accumulate
at `t`. Refuting it therefore needs a region that accumulates at one point and is dense in itself,
yet has no ambient accumulation point anywhere above that one. In a *separable* flow that is
impossible — which is exactly the hypothesis Reynolds' positive argument for `sep` over `ℝ` runs
on — so the carrier must be non-separable.

`Lex (ℚ →₀ ℚ)` supplies it. The φ-region `sepRegion` is the positive-index single-support
generators; `γ ↦ sepGen γ` is order-reversing, every generator is positive, and the generators run
off to `0` as the index grows. The region is order-anti-isomorphic to the positive rationals, so
it is dense in itself (no gapped successors, hence `sep`'s second antecedent conjunct at `0`) and
unbounded in index (hence accumulation at `0`, `sep`'s first antecedent conjunct); but distinct
generators live on distinct archimedean scales, infinitely separated in the ambient order, so no
positive duration is a right-accumulation point and the consequent fails at `0`.

## Two routes not taken

* A two-level carrier such as `ℚ ×ₗ ℚ` is **refuted**, and for a sharper reason than "a group has
  no fibre tops": with only one infinitesimal scale, the natural φ-region is already dense in the
  ambient order, so every one of its points is a two-sided accumulation point, the consequent
  holds and there is nothing to refute. One level is never enough, and neither is any finite
  number — which is what motivates a direct sum over a *dense, unbounded* index order.
* A bespoke Cantor set inside plain `ℚ`, exploiting completeness rather than separability, is
  **excluded on cost, not refuted**. It needs a Cantor–Bendixson regress built by recursion, with
  three separate order properties then proved about it; the Hahn carrier replaces that recursion
  with one algebraic construction.

## Main results

* `LexHahn`, `sepSharpOrder`, `sepGen`, `sepRegion` — the Hahn carrier, its duration order, the
  single-support generators and the φ-region
* `sepGen_apply`, `sepGen_pos`, `sepGen_lt_of_index_lt`, `lt_sepGen_of_lt_index`, `pos_index`,
  `sepGen_lt_sepGen` — the order machinery for the generators
* `exists_mem_sepRegion_lt`, `not_gapped_successor_sepRegion`, `exists_sepRegion_free_interval` —
  the three accumulation facts about the φ-region
* `not_validOn_sep_lexHahn` — the frame-level refutation
* `not_validIn_base_sep`, `not_validIn_dense_sep`, `sep_minFrameClass_sharp` — the closed row
* `isLeastPos_of_succOrder`, `sep_validIn_ztime` — the positive `.ZTime` result
* `sep_validIn_iff` — the exhaustive characterization
* `not_derivable_dense_sep` — the underivability corollary through soundness

## Tags

independence · sharpness · minimality · sep · dense · hahn group · finsupp lex
-/

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem Finsupp

namespace FormalSystem.Metalogic.Independence

/-! ## The Hahn carrier

`Lex (ℚ →₀ ℚ)` is the Hahn group of finitely supported functions `ℚ → ℚ` ordered
lexicographically — a direct sum of `ℚ`-many archimedean classes indexed by `ℚ` itself. Both
features of the index order are load-bearing and neither can be dropped: it must be **dense**
(over `ℕ →₀ ℚ` each generator would have an immediate generator-successor, killing the axiom's
second antecedent conjunct) and it must be **unbounded above** (that is what makes the generators
accumulate at `0`).

Every instance `TemporalOrder.of` needs is supplied by Mathlib — `AddCommGroup` and `Nontrivial`
by `Lex`-synonym transfer, `LinearOrder` by `Finsupp.Lex.linearOrder`, and `IsOrderedAddMonoid`
by `Finsupp.Lex.isOrderedCancelAddMonoid` — except `DenselyOrdered`, written below.
-/

/-- The Hahn group `⊕_{γ ∈ ℚ} ℚ`: finitely supported `ℚ → ℚ`, ordered lexicographically.

Every helper in this module is stated at this bare abbreviation and *not* at
`(sepSharpOrder : Type)`. That is forced rather than stylistic: at `TemporalOrder.carrier` the
application `ofLex r j` fails to elaborate ("function expected at `ofLex r`"), and reducibility
bridges the two only at the frame-level theorem, where no such application appears. -/
abbrev LexHahn := Lex (ℚ →₀ ℚ)

/-- `Lex (ℚ →₀ ℚ)` is densely ordered: between `x < y` differing first at index `i` sits `x`
shifted at `i` by half the gap. The explicit `rw` chain is required — a bare `simp` over-simplifies
the strict-inequality goals to `False`.

This is the one instance Mathlib does not already supply for the carrier. The argument
generalises: for `[LinearOrder α] [AddCommGroup N] [LinearOrder N] [DenselyOrdered N]` one gets
`DenselyOrdered (Lex (α →₀ N))` by replacing the midpoint `(y i - x i) / 2` with `exists_between`
in `N`, which also drops the need for division. That generalisation is a genuine upstreaming
candidate for `FormalSystem/ForMathlib/Order/`; it is kept local here because a new `ForMathlib/`
file is a recorded exception requiring coordinated edits to the init-import checker, churn out of
proportion to a fourteen-line instance at one closed type. -/
instance : DenselyOrdered LexHahn where
  dense := by
    intro x y h
    obtain ⟨i, hlt, hi⟩ := Finsupp.Lex.lt_iff.mp h
    refine ⟨toLex (ofLex x + Finsupp.single i ((ofLex y i - ofLex x i) / 2)), ?_, ?_⟩
    · refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
      · intro j hj
        rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_neg (ne_of_gt hj), add_zero]
      · rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_pos rfl]; linarith
    · refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
      · intro j hj
        rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_neg (ne_of_gt hj), add_zero]
        exact hlt j hj
      · rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, if_pos rfl]; linarith

/-- The Hahn duration order, carrier for the `sep`-row refutation. `AddCommGroup (Lex (ℚ →₀ ℚ))`
is noncomputable, so this is a `noncomputable abbrev`, matching `denseSharpOrder`. -/
noncomputable abbrev sepSharpOrder : TemporalOrder := TemporalOrder.of LexHahn

/-- The single-support generator at index `γ`: the Hahn vector with value `1` at `γ` and `0`
elsewhere. Index `γ` is the archimedean scale; `γ ↦ sepGen γ` is order-*reversing*, so larger
indices give smaller durations. -/
noncomputable def sepGen (γ : ℚ) : LexHahn := toLex (Finsupp.single γ (1 : ℚ))

/-- The φ-region: the positive-index single-support generators. Order-anti-isomorphic to the
positive rationals, so it is dense in itself, yet its elements are mutually infinitely separated
in the ambient order — the tension the `sep` axiom is about. -/
def sepRegion : Set LexHahn := {x | ∃ γ : ℚ, 0 < γ ∧ x = sepGen γ}

/-! ## Order machinery for the generators -/

/-- Componentwise normal form of a generator. -/
@[simp] theorem sepGen_apply (γ j : ℚ) : ofLex (sepGen γ) j = if γ = j then 1 else 0 := by
  simp [sepGen, Finsupp.single_apply]

/-- Every generator is a positive duration. -/
theorem sepGen_pos (γ : ℚ) : (0 : LexHahn) < sepGen γ := by
  refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
  · intro j hj; simp [ne_of_gt hj]
  · simp

/-- A generator sits strictly below any positive vector whose leading index is strictly smaller:
a coarser archimedean scale dominates every finer one. -/
theorem sepGen_lt_of_index_lt {r : LexHahn} {i γ : ℚ} (h0 : ∀ j, j < i → ofLex r j = 0)
    (hi : 0 < ofLex r i) (hγ : i < γ) : sepGen γ < r := by
  refine Finsupp.Lex.lt_iff.mpr ⟨i, ?_, ?_⟩
  · intro j hj; rw [h0 j hj]; simp [ne_of_gt (hj.trans hγ)]
  · simpa [ne_of_gt hγ] using hi

/-- Even doubled, a vector whose leading index is strictly larger than `γ` stays below the
generator at `γ`: the separation between archimedean scales is infinite, so no finite multiple
bridges it. This is what makes the generators mutually non-accumulating. -/
theorem lt_sepGen_of_lt_index {r : LexHahn} {i γ : ℚ} (h0 : ∀ j, j < i → ofLex r j = 0)
    (hγ : γ < i) : r + r < sepGen γ := by
  refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
  · intro j hj
    have hz : ofLex r j = 0 := h0 j (hj.trans hγ)
    simp [hz, ne_of_gt hj]
  · have hz : ofLex r γ = 0 := h0 γ hγ
    simp [hz]

/-- Leading-index extraction: a positive vector has an index below which it vanishes and at which
it is strictly positive. -/
theorem pos_index {r : LexHahn} (h : 0 < r) :
    ∃ i, (∀ j, j < i → ofLex r j = 0) ∧ 0 < ofLex r i := by
  obtain ⟨i, h1, h2⟩ := Finsupp.Lex.lt_iff.mp h
  exact ⟨i, fun j hj => (h1 j hj).symm, h2⟩

/-- The generators are order-reversing in their index. Mathlib's `Finsupp.Lex.single_lt_iff` and
`Finsupp.Lex.single_strictAnti` look applicable but are specialised away from a general value type
in the pinned snapshot and do not apply at value type `ℚ`; this is the replacement, proved
directly from `Finsupp.Lex.lt_iff`. -/
theorem sepGen_lt_sepGen {γ δ : ℚ} : sepGen δ < sepGen γ ↔ γ < δ := by
  constructor
  · intro h
    obtain ⟨i, h1, h2⟩ := Finsupp.Lex.lt_iff.mp h
    rw [sepGen_apply, sepGen_apply] at h2
    have hγi : γ = i := by
      by_contra hne
      rw [if_neg hne] at h2
      split at h2 <;> linarith
    subst hγi
    rcases lt_trichotomy γ δ with h' | h' | h'
    · exact h'
    · subst h'; simp at h2
    · have h3 := h1 δ h'
      rw [sepGen_apply, sepGen_apply, if_pos rfl, if_neg (ne_of_gt h')] at h3
      exact absurd h3 (by norm_num)
  · intro h
    refine Finsupp.Lex.lt_iff.mpr ⟨γ, ?_, ?_⟩
    · intro j hj
      rw [sepGen_apply, sepGen_apply, if_neg (ne_of_gt hj),
        if_neg (by intro hh; exact absurd (hh ▸ hj) (by linarith))]
    · simp [ne_of_gt h]

/-! ## Shape pin

The `example` below type-checks only if the formula refuted in this module is *exactly* the one
`Axiom.sep` produces. Without it, a mis-transcribed formula would yield a true but entirely
vacuous non-validity result about some other formula. The pin also guards the argument-order trap
the Independence README flags: the prose reads `U(φ, ¬φ)` event-first, while the constructor is
`Formula.untl φ.neg φ`, guard-first.
-/

/-- Shape pin: the formula refuted below is exactly `Axiom.sep`'s. -/
example (φ : Formula) : Axiom ((Formula.and (Formula.kPlus φ)
    (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
    (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := Axiom.sep φ

/-! ## The three order facts

Reading `Truth.kPlus_iff` in order language, `K⁺φ` at `t` says the φ-region *right-accumulates* at
`t`. The three facts below say the φ-region right-accumulates at `0`, has no gapped successors
anywhere, and right-accumulates at no positive duration — which is exactly `sep`'s two antecedent
conjuncts holding at `0` while its consequent fails there.
-/

/-- The φ-region right-accumulates at `0`: below any positive duration sits a generator. Given `s`
with leading index `i`, the generator at `max i 0 + 1` lies on a strictly finer archimedean scale
and so falls strictly between. This is `K⁺φ` at `0`, `sep`'s first antecedent conjunct. -/
theorem exists_mem_sepRegion_lt (s : LexHahn) (hs : 0 < s) :
    ∃ r, 0 < r ∧ r < s ∧ r ∈ sepRegion := by
  obtain ⟨i, h0, hi⟩ := pos_index hs
  refine ⟨sepGen (max i 0 + 1), sepGen_pos _, ?_, ⟨max i 0 + 1, by positivity, rfl⟩⟩
  exact sepGen_lt_of_index_lt h0 hi (by have := le_max_left i 0; linarith)

/-- No point of the φ-region has an immediate φ-successor across a gap: the region is
order-anti-isomorphic to the positive rationals, hence dense in itself. So `φ ∧ U(φ, ¬φ)` is false
*everywhere*, which is why `sep`'s second antecedent conjunct `¬K⁺(φ ∧ U(φ, ¬φ))` holds at `0`. -/
theorem not_gapped_successor_sepRegion (r : LexHahn) (hr : r ∈ sepRegion) :
    ¬ ∃ s, r < s ∧ s ∈ sepRegion ∧ ∀ u, r < u → u < s → u ∉ sepRegion := by
  rintro ⟨s, hrs, ⟨ε, hε, rfl⟩, hgap⟩
  obtain ⟨γ, hγ, rfl⟩ := hr
  have hεγ : ε < γ := sepGen_lt_sepGen.mp hrs
  obtain ⟨ε', h1, h2⟩ := exists_between hεγ
  exact hgap (sepGen ε') (sepGen_lt_sepGen.mpr h2) (sepGen_lt_sepGen.mpr h1) ⟨ε', hε.trans h1, rfl⟩

/-- No positive duration is a right-accumulation point of the φ-region: the generators are
mutually infinitely separated, so above any `r > 0` there is a φ-free interval. The split is
two-way, on `sepGen i ≤ r` versus `r < sepGen i` for `r`'s own leading index `i`; refuting `K⁺φ`
(rather than `K⁻φ` or the conjunction `K⁺φ ∧ K⁻φ`) is what keeps it two-way, since the `K⁻` route
would force a three-way split on `r`'s leading coefficient. -/
theorem exists_sepRegion_free_interval (r : LexHahn) (hr : 0 < r) :
    ∃ s, r < s ∧ ∀ u, r < u → u < s → u ∉ sepRegion := by
  obtain ⟨i, h0, hi⟩ := pos_index hr
  rcases le_or_gt (sepGen i) r with hc | hc
  · refine ⟨r + r, lt_add_of_pos_left r hr, ?_⟩
    rintro u hru hus ⟨γ, hγ, rfl⟩
    rcases lt_trichotomy γ i with hh | hh | hh
    · exact absurd (lt_sepGen_of_lt_index h0 hh) (not_lt.mpr hus.le)
    · exact absurd (hh ▸ hru) (not_lt.mpr hc)
    · exact absurd (sepGen_lt_of_index_lt h0 hi hh) (not_lt.mpr hru.le)
  · refine ⟨sepGen i, hc, ?_⟩
    rintro u hru hus ⟨γ, hγ, rfl⟩
    exact absurd (sepGen_lt_of_index_lt h0 hi (sepGen_lt_sepGen.mp hus)) (not_lt.mpr hru.le)

/-! ## The frame-level refutation -/

/-- `Axiom.sep`'s atomic instance fails on the translation frame over the Hahn group: at time `0`,
under the valuation making the atom true exactly on `sepRegion`, both antecedent conjuncts hold
and the consequent fails.

This is a frame-level statement (`¬ F.ValidOn φ`), per the Independence README's criterion — a
bare non-validity claim validates nothing, so the frame-versus-model obstruction recorded in
`Independence/CoNotPriorU.lean` does not bite. The proof drives the truth clauses through the
named lemmas `Truth.imp_iff`, `Truth.and_iff`, `Truth.kPlus_iff`, `Truth.neg_iff` and
`Truth.untl_iff`, never `simp [TruthAt]`. -/
theorem not_validOn_sep_lexHahn (a : Atom) :
    ¬ (translationFrame sepSharpOrder).toTaskFrame.ValidOn
      ((Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus (Formula.atom a))
          (Formula.kMinus (Formula.atom a))))) := by
  intro h
  have hval := h (translationModel sepSharpOrder sepRegion) (translationHist sepSharpOrder) 0
  rw [Truth.imp_iff] at hval
  have hant : TruthAt (translationModel sepSharpOrder sepRegion)
      (translationHist sepSharpOrder) 0
      (Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg) := by
    rw [Truth.and_iff]
    constructor
    · rw [Truth.kPlus_iff]
      intro s hs
      obtain ⟨r, hr0, hrs, hrA⟩ := exists_mem_sepRegion_lt s hs
      exact ⟨r, hr0, hrs, (translation_realizes sepSharpOrder sepRegion a r).mpr hrA⟩
    · rw [Truth.neg_iff, Truth.kPlus_iff]
      intro hk
      obtain ⟨r, hr0, _, hr⟩ := hk (sepGen 1) (sepGen_pos 1)
      rw [Truth.and_iff] at hr
      obtain ⟨hrA, hru⟩ := hr
      rw [Truth.untl_iff] at hru
      obtain ⟨s, hrs, hsA, hgap⟩ := hru
      refine not_gapped_successor_sepRegion r
        ((translation_realizes sepSharpOrder sepRegion a r).mp hrA)
        ⟨s, hrs, (translation_realizes sepSharpOrder sepRegion a s).mp hsA, ?_⟩
      intro u hru' hus huA
      exact (Truth.neg_iff _).mp (hgap u hru' hus)
        ((translation_realizes sepSharpOrder sepRegion a u).mpr huA)
  have hcon := hval hant
  rw [Truth.kPlus_iff] at hcon
  obtain ⟨r, hr0, _, hr⟩ := hcon (sepGen 1) (sepGen_pos 1)
  rw [Truth.and_iff] at hr
  obtain ⟨hkp, _⟩ := hr
  rw [Truth.kPlus_iff] at hkp
  obtain ⟨s', hrs', hgap'⟩ := exists_sepRegion_free_interval r hr0
  obtain ⟨u, hru, hus, hu⟩ := hkp s' hrs'
  exact hgap' u hru hus ((translation_realizes sepSharpOrder sepRegion a u).mp hu)

/-! ## The closed `sep` row

One dense witness closes both classes strictly below `.RTime` at once, since `Sat .Dense F`
implies `Sat .Base F` — exactly the pattern `not_validIn_dense_prior_U_gap` follows for the
`prior_U_gap` row. `translationFrame_isRegular` is a global instance, so `.Base` membership is
`inferInstance` and `.Dense` membership is `⟨inferInstance, inferInstance⟩` once the
`DenselyOrdered` instance above is in scope.
-/

/-- `Axiom.sep`'s atomic instance is not valid at `FrameClass.Dense`. -/
theorem not_validIn_dense_sep (a : Atom) :
    ¬ ValidIn FrameClass.Dense
      ((Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus (Formula.atom a))
          (Formula.kMinus (Formula.atom a))))) :=
  fun h => not_validOn_sep_lexHahn a (h _ ⟨inferInstance, inferInstance⟩)

/-- `Axiom.sep`'s atomic instance is not valid at `FrameClass.Base`. -/
theorem not_validIn_base_sep (a : Atom) :
    ¬ ValidIn FrameClass.Base
      ((Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus (Formula.atom a))
          (Formula.kMinus (Formula.atom a))))) :=
  fun h => not_validOn_sep_lexHahn a (h _ inferInstance)

/-- Minimality of `Axiom.sep`'s `.RTime` tag: its atomic instance is not valid at any frame class
strictly below `FrameClass.RTime`. `base_or_dense_of_lt_rtime` supplies the two-class split;
`by decide` is not available, since only `≤` on `FrameClass` carries a `DecidableRel` instance. -/
theorem sep_minFrameClass_sharp (a : Atom) {fc : FrameClass} (hfc : fc < FrameClass.RTime) :
    ¬ ValidIn fc
      ((Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus (Formula.atom a))
          (Formula.kMinus (Formula.atom a))))) := by
  rcases base_or_dense_of_lt_rtime hfc with rfl | rfl
  · exact not_validIn_base_sep a
  · exact not_validIn_dense_sep a

/-! ## The positive `.ZTime` result, and the characterization -/

/-- A duration group with a successor order has a least positive element, namely `Order.succ 0`.
`NoMaxOrder` is found by instance search, so `Order.lt_succ` needs no side condition. -/
theorem isLeastPos_of_succOrder (F : TaskFrame) (so : SuccOrder F.Duration) :
    IsLeast {x : F.Duration | 0 < x} (Order.succ 0) :=
  ⟨Order.lt_succ (0 : F.Duration), fun _ hx => Order.succ_le_of_lt hx⟩

/-- `Axiom.sep` is valid at `FrameClass.ZTime` — vacuously, and *schematically in `φ`*. `IsZTime`
supplies a `SuccOrder`, hence a least positive duration, hence `sep_validOn_of_isLeastPos`
applies. The `∀ φ` form is sound here precisely because this is a validity claim rather than a
non-validity claim. `IsZTime` is a nested existential, so it is destructured rather than
`haveI`-ed. -/
theorem sep_validIn_ztime (φ : Formula) :
    ValidIn FrameClass.ZTime ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  intro F hF
  obtain ⟨-, so, -, -⟩ := hF
  exact sep_validOn_of_isLeastPos (isLeastPos_of_succOrder F so) φ

/-- The exhaustive characterization of the `sep` row: its atomic instance is valid at `fc` exactly
when `fc` is `.ZTime` or is at least `.RTime`.

Note the shape. This is **not** `↔ FrameClass.RTime ≤ fc`, which would be false — `.RTime ≰
.ZTime`, yet `sep` is `.ZTime`-valid by `sep_validIn_ztime`. The `.RTime` case is
`Metalogic.sep_valid`, whose `ValidRTime` is `ValidIn FrameClass.RTime` definitionally. -/
theorem sep_validIn_iff (a : Atom) (fc : FrameClass) :
    ValidIn fc ((Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus (Formula.atom a))
          (Formula.kMinus (Formula.atom a)))))
      ↔ (fc = FrameClass.ZTime ∨ FrameClass.RTime ≤ fc) := by
  constructor
  · intro h
    cases fc with
    | Base => exact absurd h (not_validIn_base_sep a)
    | Dense => exact absurd h (not_validIn_dense_sep a)
    | ZTime => exact Or.inl rfl
    | RTime => exact Or.inr (le_refl _)
  · rintro (rfl | h)
    · exact sep_validIn_ztime (Formula.atom a)
    · exact ValidIn.mono h (sep_valid (Formula.atom a))

/-- Underivability corollary through soundness: `Axiom.sep`'s atomic instance is not derivable in
the `.Dense` system. -/
theorem not_derivable_dense_sep (a : Atom) :
    ¬ Derivable FrameClass.Dense []
      ((Formula.and (Formula.kPlus (Formula.atom a))
        (Formula.kPlus (Formula.and (Formula.atom a)
          (Formula.untl (Formula.atom a).neg (Formula.atom a)))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus (Formula.atom a))
          (Formula.kMinus (Formula.atom a))))) :=
  fun ⟨d⟩ => not_validIn_dense_sep a (soundness_validIn d)

end FormalSystem.Metalogic.Independence
