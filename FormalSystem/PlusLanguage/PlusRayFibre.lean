/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Presheaf.Ray
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.PlusLanguage.PlusTruth

/-!
# `⊡` as a quantifier over a product of two path spaces

The stability modal `⊡` quantifies over the possible worlds agreeing with the present one at the
present time — `PlusTruth.stab_iff`'s domain, the set of `σ : WorldHistory F` with
`τ.state t = σ.state t`. This module replaces that domain by a **fibre product**: by
`Semantics/Presheaf/Ray.lean`'s `seamFibreEquiv` it is the pairs of a past ray and a future ray
agreeing at the seam state, and over a regular ℤ-frame it is, by `seamOmegaEquiv`, the pairs of
ω-indexed step sequences out of that state — one factor running backward from the seam against
the arrow of time, one forward.

`plusStab_iff_rays` and `plusStab_iff_omega` are the clause in those two forms. Read as a
decision problem this is the content: **`⊡` is a quantifier over a product of two path spaces**,
and any device summarising it must be universal over *both* factors.

## What this does not do

**It bounds nothing.** `not_finite_width_fmp` stands exactly as proved, and the ray-product
presentation is the *mechanism behind* that refutation rather than an escape from it: a product
of two path spaces cannot be a finite fibre. Nothing here decides anything, commits to any
width, tail-period or complexity bound, or supplies a summary device.

## The choice record, which splits

The ray half is **choice-free**: `seamFibreEquiv` and `plusStab_iff_rays` measure
`[propext, Quot.sound]`. The ω half is **not**, and the cause is upstream and named —
`FrameOver.worldHistoryOfStepPath`, which `pathFibreEquiv` reaches to build a possible world out
of a bare bi-infinite step path, measures `Classical.choice`, and so `seamOmegaEquiv` and
`plusStab_iff_omega` measure it too. Rerouting that declaration is deliberately out of scope
here: it is a core `Semantics/IntNormalForm.lean` declaration with consumers across several
independent fronts. The honest record is the split, not a uniform claim either way.

## Layering

This module sits **above** `Semantics/Truth.lean` by construction, because the clause it restates
mentions `PlusTruthAt`. That is why it is separate from `Semantics/Presheaf/Ray.lean`, which
carries the ray layer and `seamFibreEquiv` and stays strictly below `Semantics/Truth.lean` with
the rest of its cluster. The split is forced by the layering and is not a matter of taste; this
module therefore carries no `assert_not_exists` on the proof system.

## Main Definitions

- `BwdSeq`, `FwdSeq`: the backward and forward ω-indexed step sequences over a ℤ-frame. The
  backward one is indexed *against* the arrow of time, which is exactly the half of the structure
  a forward-only re-basing of the semantics would delete.
- `SeqPair`: the fibre product of the two ω-sequence spaces over a seam state.
- `ZPathFibre`: the `⊡` fibre read on bare bi-infinite step paths.
- `splice`: the glued path of an ω-sequence pair — the forward sequence from the seam on, the
  backward sequence strictly before.

## Main Results

- `plusStab_iff_rays`: `⊡φ` at `(τ, t)` iff `φ` holds at every gluing of a past ray and a future
  ray through `τ`'s state at `t`.
- `pathFibreEquiv`: the possible worlds in a given state at a given time are exactly the step
  paths through that state.
- `splice_isStepPath`: the spliced path is a bi-infinite step path; the only non-routine case is
  the seam step, where the shared base point is used.
- `omegaSplitEquiv`: the step paths through a state are exactly the pairs of a backward and a
  forward ω-step-sequence based at it.
- `seamOmegaEquiv`: the ω-sequence form of the keystone — over a regular ℤ-frame the `⊡` fibre
  over a seam state is equivalent to `BwdSeq × FwdSeq` based there. This is the "re-base the
  semantics on ω-sequences" proposal proved as a theorem *about* the landed ℤ-time semantics: no
  new semantics is introduced, and the backward factor is retained rather than deleted.
- `plusStab_iff_omega`: the clause over ω-sequence pairs — the form a decision procedure would
  have to check.

## References

* JPL paper `def:BLstar-semantics` — the `⊡` clause this module restates, whose quantification
  domain `PlusTruth.stab_iff` presents
* JPL paper `app:gluing` — the gluing lemma whose seam case the ray presentation rests on. Cited
  as a **pointer only**, its record row being `LIVE-UNPINNED`
* `FormalSystem/Semantics/Presheaf/Ray.lean` — `PastRay`, `FutRay`, `Ray.seamGlue`, `StabFibre`,
  `RayPair` and `seamFibreEquiv`, the keystone this module reads the clause through
* `FormalSystem/Semantics/IntNormalForm.lean` — `IsStepPath`,
  `FrameOver.worldHistoryOfStepPath` and `FrameOver.mem_HF_iff_adjacent`, the identification of
  possible worlds over ℤ with bi-infinite step paths
* `FormalSystem/PlusLanguage/PlusTruth.lean` — `PlusTruth.stab_iff`, the clause's own statement
* `FormalSystem/Metalogic/Decidability/FMP/` — `not_finite_width_fmp`, the refutation this
  presentation is the mechanism behind and does not escape
* The Possible Worlds limit presentation `H_F ≅ lim Beh(F)(2x)` is the natural categorical
  companion to this fibre product. It is **not landed** anywhere under `FormalSystem/` and is
  cited here as a pointer to future work only, never as a result
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Semantics FormalSystem.Semantics.Presheaf

/-! ## The `⊡` clause as a quantifier over ray pairs -/

section Stab

variable {F : TaskFrame} [F.IsRegular]

/--
**`⊡` is a quantifier over a product of two path spaces.** `⊡φ` holds at `(τ, t)` exactly when
`φ` holds at every gluing of a past ray and a future ray through `τ`'s state at `t`.

This is the decidability-relevant restatement: the quantification is over PAIRS, one factor
running backward from the seam and one forward.
-/
theorem plusStab_iff_rays (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ (b : PastRay F t) (f : FutRay F t) (hb : b.seam = τ.state t) (hf : f.seam = τ.state t),
        PlusTruthAt M (Ray.seamGlue b f (hb.trans hf.symm)) t φ := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h b f hb hf
    refine h _ ?_
    rw [Ray.seamGlue_states_le _ _ _ le_rfl]
    exact hb.symm
  · intro h σ hσ
    have hb : (pastOf σ t).seam = τ.state t := hσ.symm
    have hf : (futOf σ t).seam = τ.state t := hσ.symm
    have hglue : Ray.seamGlue (pastOf σ t) (futOf σ t) (hb.trans hf.symm) = σ := by
      refine WorldHistory.ext_state fun r => ?_
      by_cases hr : r ≤ t
      · rw [Ray.seamGlue_states_le _ _ _ hr]; rfl
      · rw [Ray.seamGlue_states_not_le _ _ _ hr]; rfl
    have := h (pastOf σ t) (futOf σ t) hb hf
    rwa [hglue] at this

end Stab

/-! ## The ω-sequence form over ℤ -/

section Omega

variable {F : FrameOver intOrder}

/-- A **backward ω-sequence**: each `b (n+1)` steps to `b n`. The ω-indexing runs *against* the
arrow of time, which is exactly the half of the structure a forward-only re-basing deletes. -/
def BwdSeq (F : FrameOver intOrder) : Type _ :=
  {b : ℕ → F.WorldState // ∀ n, F.step (b (n + 1)) (b n)}

/-- A **forward ω-sequence**: each `f n` steps to `f (n+1)`. -/
def FwdSeq (F : FrameOver intOrder) : Type _ :=
  {f : ℕ → F.WorldState // ∀ n, F.step (f n) (f (n + 1))}

/-- The fibre product of the two ω-sequence spaces over the seam state `s`. -/
def SeqPair (F : FrameOver intOrder) (s : F.WorldState) : Type _ :=
  {bf : BwdSeq F × FwdSeq F // bf.1.1 0 = s ∧ bf.2.1 0 = s}

/-- The `⊡` fibre read on bare bi-infinite step paths, via the landed
`FrameOver.mem_HF_iff_adjacent`. -/
def ZPathFibre (F : FrameOver intOrder) (t : ℤ) (s : F.WorldState) : Type _ :=
  {g : ℤ → F.WorldState // IsStepPath F g ∧ g t = s}

variable [F.IsRegular]

/-- Possible worlds in a given state at a given time are exactly the step paths through that
state: `WorldHistory.ext_state` one way, `FrameOver.worldHistoryOfStepPath` the other. The
`Classical.choice` of this module's ω half enters here and nowhere else. -/
def pathFibreEquiv (t : ℤ) (s : F.WorldState) :
    StabFibre F.toTaskFrame t s ≃ ZPathFibre F t s where
  toFun σ := ⟨σ.1.path, σ.1.isStepPath, σ.2⟩
  invFun g := ⟨FrameOver.worldHistoryOfStepPath F g.1 g.2.1, g.2.2⟩
  left_inv := by
    rintro ⟨σ, hσ⟩
    exact Subtype.ext (WorldHistory.ext_state fun r => rfl)
  right_inv := by
    rintro ⟨g, hg, hgt⟩
    exact Subtype.ext rfl

/-- The glued path of an ω-sequence pair: the forward sequence from `t` on, the backward sequence
strictly before. -/
def splice (t : ℤ) (b : BwdSeq F) (f : FwdSeq F) : ℤ → F.WorldState :=
  fun z => if t ≤ z then f.1 (z - t).natAbs else b.1 (t - z).natAbs

omit [F.IsRegular] in
/-- The spliced path is a bi-infinite step path. The only non-routine case is the seam step
`z + 1 = t`, where the shared base point `b 0 = s = f 0` is used. -/
theorem splice_isStepPath (t : ℤ) (b : BwdSeq F) (f : FwdSeq F) {s : F.WorldState}
    (hb : b.1 0 = s) (hf : f.1 0 = s) : IsStepPath F (splice t b f) := by
  intro z
  unfold splice
  by_cases hz : t ≤ z
  · rw [if_pos hz, if_pos (by omega : t ≤ z + 1)]
    have e : (z + 1 - t).natAbs = (z - t).natAbs + 1 := by omega
    rw [e]
    exact f.2 _
  · rw [if_neg hz]
    by_cases hz1 : t ≤ z + 1
    · rw [if_pos hz1]
      have e1 : (t - z).natAbs = 0 + 1 := by omega
      have e2 : (z + 1 - t).natAbs = 0 := by omega
      rw [e1, e2, hf, ← hb]
      exact b.2 0
    · rw [if_neg hz1]
      have e : (t - z).natAbs = (t - (z + 1)).natAbs + 1 := by omega
      rw [e]
      exact b.2 _

/--
**The ω-splitting of the fibre.** The step paths through a state `s` at time `t` are exactly the
pairs of a backward and a forward ω-step-sequence based at `s`.
-/
def omegaSplitEquiv (t : ℤ) (s : F.WorldState) :
    ZPathFibre F t s ≃ SeqPair F s where
  toFun g :=
    ⟨(⟨fun n => g.1 (t - n), fun n => by
        have h := g.2.1 (t - ((n + 1 : ℕ) : ℤ))
        rwa [show t - ((n + 1 : ℕ) : ℤ) + 1 = t - (n : ℕ) by push_cast; omega] at h⟩,
      ⟨fun n => g.1 (t + n), fun n => by
        have h := g.2.1 (t + ((n : ℕ) : ℤ))
        rwa [show t + ((n : ℕ) : ℤ) + 1 = t + ((n + 1 : ℕ) : ℤ) by push_cast; omega] at h⟩),
     by
      refine ⟨?_, ?_⟩
      · change g.1 (t - ((0 : ℕ) : ℤ)) = s
        rw [show t - ((0 : ℕ) : ℤ) = t by push_cast; omega]; exact g.2.2
      · change g.1 (t + ((0 : ℕ) : ℤ)) = s
        rw [show t + ((0 : ℕ) : ℤ) = t by push_cast; omega]; exact g.2.2⟩
  invFun bf :=
    ⟨splice t bf.1.1 bf.1.2, splice_isStepPath t bf.1.1 bf.1.2 bf.2.1 bf.2.2, by
      unfold splice
      rw [if_pos (le_refl t), show (t - t).natAbs = 0 by omega]
      exact bf.2.2⟩
  left_inv := by
    rintro ⟨g, hg, hgt⟩
    refine Subtype.ext (funext fun z => ?_)
    change splice t _ _ z = g z
    unfold splice
    by_cases hz : t ≤ z
    · rw [if_pos hz]
      change g (t + (((z - t).natAbs : ℕ) : ℤ)) = g z
      congr 1
      omega
    · rw [if_neg hz]
      change g (t - (((t - z).natAbs : ℕ) : ℤ)) = g z
      congr 1
      omega
  right_inv := by
    rintro ⟨⟨b, f⟩, hb, hf⟩
    refine Subtype.ext (Prod.ext (Subtype.ext (funext fun n => ?_))
      (Subtype.ext (funext fun n => ?_)))
    · change splice t b f (t - ((n : ℕ) : ℤ)) = b.1 n
      unfold splice
      by_cases hn : t ≤ t - ((n : ℕ) : ℤ)
      · have hn0 : n = 0 := by omega
        subst hn0
        rw [if_pos hn, show (t - ((0 : ℕ) : ℤ) - t).natAbs = 0 by push_cast; omega, hf, ← hb]
      · rw [if_neg hn, show (t - (t - ((n : ℕ) : ℤ))).natAbs = n by omega]
    · change splice t b f (t + ((n : ℕ) : ℤ)) = f.1 n
      unfold splice
      rw [if_pos (by omega : t ≤ t + ((n : ℕ) : ℤ)),
        show (t + ((n : ℕ) : ℤ) - t).natAbs = n by omega]

/--
**The ω-sequence form of the keystone.** Over a regular ℤ-frame the `⊡` fibre over a seam state
is equivalent to the pairs of ω-indexed step sequences out of that state.

This is the "re-base the semantics on ω-sequences" proposal, proved as a theorem ABOUT the landed
ℤ-time semantics: no new semantics is introduced, and the backward factor is retained as an
ω-sequence run against the arrow of time rather than deleted.
-/
def seamOmegaEquiv (t : ℤ) (s : F.WorldState) :
    StabFibre F.toTaskFrame t s ≃ SeqPair F s :=
  (pathFibreEquiv t s).trans (omegaSplitEquiv t s)

end Omega

/-! ## The `⊡` clause over ω-sequence pairs -/

section StabOmega

variable {F : FrameOver intOrder} [F.IsRegular]

/--
**`⊡` as a quantifier over pairs of ω-sequences.** The form a decision procedure would have to
check: for every pair of a backward and a forward ω-step-sequence out of the present state.

Summarising such a quantification finitely requires a device universal over *both* factors; what
that device is is settled nowhere, and nothing is asserted about it here.
-/
theorem plusStab_iff_omega (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ bf : SeqPair F (τ.state t),
        PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ := by
  rw [PlusTruth.stab_iff]
  constructor
  · intro h bf
    exact h _ ((seamOmegaEquiv t (τ.state t)).symm bf).2.symm
  · intro h σ hσ
    have key := h ((seamOmegaEquiv t (τ.state t)) ⟨σ, hσ.symm⟩)
    rw [(seamOmegaEquiv t (τ.state t)).symm_apply_apply ⟨σ, hσ.symm⟩] at key
    exact key

end StabOmega

end FormalSystem.PlusLanguage
