/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.PlusLanguage.PlusValidity
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth
import Mathlib.Tactic.Ring

/-!
# The Finite-Carrier Finite Model Property Fails: a `⊡`-Free Witness

The witness is

  `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`

("every history meets `p`, and never twice"), with `Fp := ⊤ U p` and `Pp := ⊤ S p`. It contains
**no** `⊡`, and `θ_eq_ofFormula` proves that mechanically by exhibiting `θ` as `ofFormula ψL` for
an explicit `Formula`-side twin `ψL`.

## The argument, in four steps

1. **A model of `θ` exists over ℤ-time.** The ℤ-carrier shift set `S` (`sh w d := w + d`, with the
   atom true only at state `0`) satisfies `ψL` at every point, so `θ` holds in the induced task
   model and `θ.neg` is a genuine ℤ-time non-validity (`not_plusValidZTime_neg_θ`). The carrier of
   that model is infinite.
2. **No finite-carrier regular ℤ-frame satisfies `θ` anywhere.** Take a model `M` on a regular
   `FrameOver intOrder` whose world-state carrier is `Finite`, a history `τ` and a time `t` with
   `θ` true there. The first conjunct gives a time `a` with `p` at `τ.path a`; the second,
   read at every time by shifting the history, makes `τ` `p`-free strictly left of `a`.
3. **Pigeonhole on the finite carrier** finds `x < y ≤ a - 1` with `τ.path x = τ.path y`.
4. **The cycle between the repeats, pumped bi-infinitely**, is a step path, hence a history
   (`FrameOver.worldHistoryOfStepPath`, whose correctness rests on `mem_HF_iff_adjacent`), and it
   lies entirely left of `a`, so by step 2 it never meets `p` — contradicting the first conjunct.

`not_finite_carrier_fmp` packages the two halves: there is a ℤ-time non-validity with no
countermodel on any regular ℤ-frame with a finite world-state carrier. Consequently a certificate
class that lands a refutation by presenting a finite-carrier frame — in particular any class
presenting `FrameOver.ofStep` on a finite type, which `no_ofStep_sat` rules out at that
constructor directly — is incomplete for ℤ-time non-validity. That is why the time-sliced
certificate's presented carrier is `ℤ × Fin n` rather than a finite type, as the subtree root's
section "The carrier is infinite, with finite fibres, and that is forced" records.

## Language scope: this half is about the base language, not only about L⁺

`θ` contains no `⊡`, and `θ_eq_ofFormula : θ = ofFormula ψL` proves it by exhibiting `θ` as the
embedding of the `Formula`-side witness `ψL`. **That is what makes this half a result about the
base language TM itself** rather than an L⁺-specific result: the non-validity `θ.neg` and the
finite-carrier obstruction both live already in the `⊡`-free fragment, so a reader of TM alone
cannot escape them. The `Formula`-side twin `ψL` is recorded, with the same shape, in
`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`.

The companion finite-*width* refutation in `Limits/NoFiniteWidth.lean` is the other half of the
programme's obstruction record, and the two differ in language scope in exactly the opposite
direction, which must not be blurred:

- **This witness `θ` is `⊡`-free**, so this half is already a statement about TM.
- **That witness `Φ` does use `⊡`** (its conjunct `D`, and the `⊡`s inside `A'`/`C'`), so that
  half is specifically an **L⁺** result and says nothing about TM.

The obstruction chain runs the other way round, which is the second half of the asymmetry: a
finite carrier **forces** finite per-time width, so *finite carrier is the strictly weaker
hypothesis*. The width refutation is therefore the stronger result on the hypothesis axis, and
this one is the stronger result on the language axis. Neither subsumes the other.
`FormalSystem/Metalogic/Decidability/FMP/README.md`'s section "The finite-carrier route is
refuted, not merely open" states the same asymmetry in the same terms.

## Scope, stated so the result is not over-read

- **Scope is ℤ (discrete) frames only.** The pumping argument of steps 3-4 needs discreteness —
  pigeonhole over a `ℕ`-indexed backward enumeration of times, then an `Int.emod` cycle — and says
  nothing whatever about a dense duration.
- **Nothing is claimed about an infinite carrier.** The hypothesis refuted is `Finite
  F.WorldState`; the positive half exhibits an infinite-carrier model, and no obstruction to one
  is claimed or implied.
- **Nothing here touches soundness**, in either direction. `plusTruth_iff_mem` and
  `PlusSlicedCertificate.Sound`'s `plusRefutes_of_certifies` keep their statements, are untouched,
  and are unused in the refuting direction.

**Not claimed**: no carrier bound of any kind. The defect is that `θ.neg` has no finite-carrier
countermodel at all, not that a known bound is too small. The finite model property for full L⁺
over integer time remains open rather than refuted, and the CTL-like fragment's own finite model
property is a separate question this module neither answers nor assumes.

## The fragment twins

`θ' := A' ∧ C'`, built from the width landing's **own** `A' := □(p ∨ ⊡Fp ∨ ⊡Pp)` and
`C' := □(p → ⊡¬Pp)`, is the CTL-like-fragment companion: it is ℤ-satisfiable on the same shift set
(where `⊡` collapses because histories through a state are unique there) and satisfiable on no
finite-carrier regular ℤ-frame, by the same pumping argument. So restricting the language to the
CTL-like fragment does **not** rescue a finite-carrier certificate shape. Unlike `θ`, the twin
`θ'` *does* bear `⊡`, so `not_finite_carrier_fmp_fragment` is an L⁺ result and not a TM one.

## Main results

- `θ_eq_ofFormula` — `θ` is `⊡`-free: it is `ofFormula ψL` (the language-scope identity)
- `not_plusValidZTime_neg_θ` — `θ.neg` is a ℤ-time non-validity of L⁺ (the positive half)
- `no_finite_carrier_sat` — no model on a regular ℤ-frame with a finite world-state carrier
  satisfies `θ` anywhere (the negative half; the core refutation)
- `no_ofStep_sat` — the same at the concrete `FrameOver.ofStep` constructor on a finite type
- `not_finite_carrier_fmp` — the finite-carrier finite model property fails for L⁺ over ℤ-time
- `not_plusValidZTime_neg_θ'`, `no_finite_carrier_sat'`, `not_finite_carrier_fmp_fragment` — the
  same three results for the `⊡`-bearing CTL-like fragment witness `θ'`

## Tags

plus-language · certificate · finite-model-property · finite-carrier · completeness · pumping
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

namespace PlusSlicedCertificate

-- The single-letter definitions below (`A`, `C`, `S`, `θ`) are nested in their own namespace so
-- that they do not land in `PlusSlicedCertificate` itself — the same discipline the sibling
-- `NoFiniteWidth` module follows for its own `p`/`A'`/`C'`/`Φ`.
namespace FiniteCarrier

-- The `Limits.NoFiniteWidth` import exists to **share** definitions with the finite-width
-- landing rather than to copy them: `pa`, `p`, `Fp`, `Pp` below are that module's, and the
-- fragment twin `θ'` is built from its `A'` and `C'`, so the two landings cannot drift apart.
-- The main witness `θ` uses nothing `⊡`-specific from it, so the `⊡`-free half is not quietly
-- coupled to L⁺-only machinery.
open NoFiniteWidth (pa p Fp Pp)

/-! ## The witness formula -/

/-- `□(p ∨ Fp ∨ Pp)`: every history meets `p` at some time. -/
def A : PlusFormula := PlusFormula.box (p.or (Fp.or Pp))

/-- `□(p → ¬Pp)`: a `p`-time has no earlier `p`-time. Together with `A`: every history meets `p`
exactly once. -/
def C : PlusFormula := PlusFormula.box (p.imp Pp.neg)

/-- The witness `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`: "every history meets `p`, and never twice".
It contains no `⊡`; see `θ_eq_ofFormula`. -/
def θ : PlusFormula := A.and C

/-- The `Formula`-side twin of `θ`, in the base language TM. Its shape is recorded in
`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`. -/
def ψL : Formula :=
  (Formula.box ((Formula.atom pa).or ((Formula.untl Formula.top (Formula.atom pa)).or
      (Formula.snce Formula.top (Formula.atom pa))))).and
    (Formula.box ((Formula.atom pa).imp (Formula.snce Formula.top (Formula.atom pa)).neg))

/-- **`θ` is `⊡`-free**: it is the embedding of the `Formula` `ψL`, so the non-validity `θ.neg`
and the finite-carrier obstruction below are statements about the base language TM itself, not
only about L⁺. This is the module's language-scope claim, machine-checked rather than asserted.

Paper: — (a language-scope identity internal to this formalization, with no paper counterpart) -/
theorem θ_eq_ofFormula : θ = ofFormula ψL := by decide

/-! ## Positive half: `θ` is satisfiable over ℤ-time, on an infinite carrier -/

/-- The ℤ-carrier shift set: states are integers, shifting by a duration `d` adds `d`, and the
one atom is true only at state `0`. The valuation is atom-independent by construction (the `A`
field ignores its atom argument), so every atom behaves like `p` here; only `pa` is ever read.
The carrier is **infinite**, which is exactly what the finite-carrier refutation below forces. -/
abbrev S : ShiftSet intOrder where
  Carrier := ℤ
  carrier_nonempty := ⟨0⟩
  sh w d := w + d
  sh_zero w := by simp
  sh_add w a b := by simp [add_assoc]
  sep w u h := by
    obtain ⟨y, hy, rfl⟩ := h 1 (by decide)
    have hy' : |(y : ℤ)| < 1 := hy
    have : (y : ℤ) = 0 := Int.abs_lt_one_iff.mp hy'
    change w + y = w
    rw [this]; simp
  A _ w := w = 0

/-- `ψL` holds at every point of the shift set: the unique history through a state meets `p`
exactly once, namely at the time that carries the state to `0`. -/
theorem shiftTruth_psiL (w t : ℤ) : S.ShiftTruth w t ψL := by
  simp only [ψL, Formula.and, Formula.or, Formula.neg, Formula.top, ShiftSet.ShiftTruth]
  intro h
  apply h
  · intro (v : ℤ) hv1 hv2
    change (v + t = 0 → False) at hv1
    rcases lt_trichotomy t (-v) with hlt | heq | hgt
    · exact (hv2 ⟨-v, hlt, show v + -v = 0 by omega, fun _ _ _ h => h⟩).elim
    · exact (hv1 (by omega)).elim
    · exact ⟨-v, hgt, show v + -v = 0 by omega, fun _ _ _ h => h⟩
  · rintro (v : ℤ) hp ⟨s, hs, hps, -⟩
    change v + t = 0 at hp
    change v + s = 0 at hps
    change s < t at hs
    omega

/-- **The positive half**: `θ.neg` is a genuine ℤ-time non-validity of L⁺, witnessed on the
ℤ-carrier shift set. This is what makes the negative half below a *coverage limit* on a
certificate shape rather than a validity: there is something to certify, and a finite-carrier
presentation cannot certify it.

The route is the `⊡`-free identity `θ_eq_ofFormula`, then `plusTruthAt_ofFormula` to drop into the
base language, then `ShiftSet.forward_repr` to read base-language truth off `ShiftTruth`.

Paper: — (a non-validity internal to this formalization, with no paper counterpart) -/
theorem not_plusValidZTime_neg_θ : ¬ PlusValidZTime θ.neg := by
  intro hv
  have h := hv S.frame ⟨S.frame_isRegular, TaskFrame.isZTime_of_instances _⟩ S.model
    (S.hist (0 : ℤ)) (0 : ℤ)
  apply h
  rw [θ_eq_ofFormula]
  exact (plusTruthAt_ofFormula S.model ψL _ _).mpr
    ((S.forward_repr (0 : ℤ) (0 : ℤ) ψL).mpr (shiftTruth_psiL 0 0))

/-! ## Negative half: no finite-carrier regular ℤ-frame satisfies `θ` anywhere -/

section Finite

variable {F : FrameOver intOrder} [F.IsRegular]

/-- A bi-infinite step path is a history. This is the step that turns the pumped cycle of the
pigeonhole argument into an object the semantics can quantify over; its correctness rests on
`mem_HF_iff_adjacent`, through `FrameOver.worldHistoryOfStepPath`. -/
def histOfStepPath (f : ℤ → F.WorldState) (hf : ∀ n, F.step (f n) (f (n + 1))) :
    WorldHistory F.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath F f hf

omit [F.IsRegular] in
/-- Every history is a step path: consecutive states are related by `F.step`. -/
theorem steps (σ : WorldHistory F.toTaskFrame) (n : ℤ) :
    F.step (σ.path n) (σ.path (n + 1)) :=
  σ.isStepPath n

/-- **The core refutation.** No model on a regular ℤ-frame whose world-state carrier is `Finite`
satisfies `θ` at any history and any time.

`[Finite F.WorldState]` is the **whole** finiteness hypothesis, and there is no hypothesis
whatever on the succession relation beyond the regularity `[F.IsRegular]` already carries. The
argument: the first conjunct gives a `p`-time `a` on `τ`; the second, read at every time by
shifting `τ`, makes `τ` `p`-free strictly left of `a`; pigeonhole on the finite carrier gives a
repeated state strictly left of `a`; the cycle between the repeats, pumped bi-infinitely, is a
history that stays strictly left of `a` and so never meets `p`, contradicting the first conjunct.

Scope: ℤ (discrete) frames only — the pumping step needs discreteness and says nothing about a
dense duration. Nothing is claimed about an infinite carrier, and nothing here touches soundness.

Paper: — (a coverage limit internal to this formalization, with no paper counterpart) -/
theorem no_finite_carrier_sat [Finite F.WorldState] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ := by
  intro h
  have hA : PlusTruthAt M τ t A := by
    by_contra hA; exact h (fun a => absurd a hA)
  have hC : PlusTruthAt M τ t C := by
    by_contra hC; exact h (fun _ c => hC c)
  simp only [A, C, PlusFormula.or, PlusFormula.neg, NoFiniteWidth.Fp, NoFiniteWidth.Pp,
    PlusFormula.top, NoFiniteWidth.p, PlusTruthAt] at hA hC
  have someP : ∀ σ : WorldHistory F.toTaskFrame, ∃ a, M.valuation (σ.path a) NoFiniteWidth.pa := by
    intro σ
    by_contra hno
    have hno' : ∀ a, ¬ M.valuation (σ.state a) NoFiniteWidth.pa := fun a h => hno ⟨a, h⟩
    obtain ⟨s, -, hs, -⟩ := hA σ (hno' t) (fun ⟨s, _, hs, _⟩ => hno' s hs)
    exact hno' s hs
  have firstP : ∀ σ : WorldHistory F.toTaskFrame, ∀ a, M.valuation (σ.path a) NoFiniteWidth.pa →
      ∀ b < a, ¬ M.valuation (σ.path b) NoFiniteWidth.pa := by
    intro σ a ha b hb hbt
    let g : ℤ → F.WorldState := fun n => σ.path (n + (a - t))
    have hg : ∀ n, F.step (g n) (g (n + 1)) := by
      intro n
      have := steps σ (n + (a - t))
      simp only [g]; rwa [show n + 1 + (a - t) = n + (a - t) + 1 by ring]
    apply hC (histOfStepPath g hg)
    · change M.valuation (σ.path (t + (a - t))) NoFiniteWidth.pa
      rwa [show t + (a - t) = a by ring]
    · refine ⟨b - (a - t), by omega, ?_, fun _ _ _ h => h⟩
      change M.valuation (σ.path (b - (a - t) + (a - t))) NoFiniteWidth.pa
      rwa [show b - (a - t) + (a - t) = b by ring]
  obtain ⟨a, ha⟩ := someP τ
  let f : ℕ → F.WorldState := fun i => τ.path (a - 1 - i)
  obtain ⟨i, j, hij, hfij⟩ := Finite.exists_ne_map_eq_of_infinite f
  obtain ⟨x, y, hxy, hya, hpxy⟩ : ∃ x y : ℤ, x < y ∧ y ≤ a - 1 ∧ τ.path x = τ.path y := by
    rcases lt_or_gt_of_ne hij with hlt | hgt
    · exact ⟨a - 1 - j, a - 1 - i, by omega, by omega, hfij.symm⟩
    · exact ⟨a - 1 - i, a - 1 - j, by omega, by omega, hfij⟩
  set L := y - x with hL
  have hLpos : 0 < L := by omega
  let h' : ℤ → F.WorldState := fun n => τ.path (x + n % L)
  have hstep : ∀ n, F.step (h' n) (h' (n + 1)) := by
    intro n
    have hr0 := Int.emod_nonneg n (ne_of_gt hLpos)
    have hrL := Int.emod_lt_of_pos n hLpos
    have hdecomp := Int.emod_add_mul_ediv n L
    have key : τ.path (x + (n + 1) % L) = τ.path (x + n % L + 1) := by
      have e : (n + 1) % L = (n % L + 1) % L := by
        conv_lhs => rw [← hdecomp]
        rw [show n % L + L * (n / L) + 1 = (n % L + 1) + L * (n / L) by ring,
          Int.add_mul_emod_self_left]
      rw [e]
      rcases lt_or_eq_of_le (show n % L + 1 ≤ L by omega) with hlt | heq
      · rw [Int.emod_eq_of_lt (by omega) hlt, add_assoc]
      · rw [heq, Int.emod_self, add_zero, hpxy]
        congr 1; omega
    simp only [h']
    rw [key]
    exact steps τ _
  obtain ⟨s, hs⟩ := someP (histOfStepPath h' hstep)
  have hr0 := Int.emod_nonneg s (ne_of_gt hLpos)
  have hrL := Int.emod_lt_of_pos s hLpos
  exact firstP τ a ha (x + s % L) (by omega) hs

end Finite

/-- The refutation at the concrete constructor: no model on `FrameOver.ofStep R fwd bwd` over a
finite type satisfies `θ` anywhere. This is the frame shape a finite-graph certificate class
would present, so the class cannot certify `θ.neg`.

`FrameOver.ofStep`'s relation is **time-independent** (`R : W → W → Prop`). It is *not*
`FrameOver.ofSlicedStep`, whose relation is `ℤ → W → W → Prop` and whose finite-*width*
obstruction is the companion result in `Limits/NoFiniteWidth.lean`; confusing the two would
silently restate that other theorem.

Paper: — (a coverage limit internal to this formalization, with no paper counterpart) -/
theorem no_ofStep_sat {W : Type} [Finite W] [Nonempty W] (R : W → W → Prop)
    (fwd : ∀ w, ∃ u, R w u) (bwd : ∀ w, ∃ v, R v w)
    (M : TaskModel (FrameOver.ofStep R fwd bwd).toTaskFrame)
    (τ : WorldHistory (FrameOver.ofStep R fwd bwd).toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ :=
  haveI : Finite (FrameOver.ofStep R fwd bwd).WorldState := ‹Finite W›
  no_finite_carrier_sat (F := FrameOver.ofStep R fwd bwd) M τ t

/-- **The finite-carrier finite model property fails for L⁺ over ℤ-time.** There is a ℤ-time
non-validity — `θ.neg`, which is `⊡`-free and therefore already a formula of the base language
TM — with no countermodel on any regular ℤ-frame whose world-state carrier is finite.

Read the statement precisely, because it is easy to over-read:

- **Scope is ℤ (discrete) frames only.** The pumping argument behind `no_finite_carrier_sat`
  needs discreteness and says **nothing** about a dense duration.
- **Nothing is claimed about an infinite carrier.** The positive half exhibits an
  infinite-carrier model of `θ`; no obstruction to one is claimed or implied.
- **Nothing here touches soundness**, in either direction. `plusTruth_iff_mem` and
  `PlusSlicedCertificate.Sound`'s `plusRefutes_of_certifies` keep their statements, are
  untouched, and are unused in the refuting direction.
- **No bound of any kind is claimed.** The defect is that `θ.neg` has no finite-carrier
  countermodel at all, not that a known carrier bound is too small. The finite model property for
  full L⁺ over integer time remains open rather than refuted.

Paper: — (a coverage limit internal to this formalization, with no paper counterpart) -/
theorem not_finite_carrier_fmp :
    ¬ ∀ φ : PlusFormula, ¬ PlusValidZTime φ →
      ∃ (F : FrameOver intOrder) (_ : F.IsRegular) (_ : Finite F.WorldState)
        (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ),
        ¬ PlusTruthAt M τ t φ := by
  intro fmp
  obtain ⟨F, hreg, hfin, M, τ, t, hτ⟩ := fmp θ.neg not_plusValidZTime_neg_θ
  exact hτ (fun hθ => no_finite_carrier_sat M τ t hθ)

/-! ## The single-operator (CTL-like) fragment fails the same way

`θ' := □(p ∨ ⊡Fp ∨ ⊡Pp) ∧ □(p → ⊡¬Pp)`: every `⊡` and every `□` governs a state formula or a
single temporal operator applied to state formulas, so `θ'` lies in the CTL-like fragment. It is
ℤ-satisfiable (on the shift set, where `⊡` collapses because histories through a state are unique
there) and satisfiable on no finite-carrier regular ℤ-frame, by the same pumping argument. So
staging through the fragment does not rescue a finite-carrier certificate shape either.

Unlike `θ`, the twin `θ'` **does** bear `⊡`, so this part of the module is an L⁺ result and says
nothing about the base language TM. -/

/-- The CTL-like-fragment twin of `θ`, built from the finite-width landing's **own** `A'` and `C'`
rather than from private copies, so the two landings cannot drift apart on its definition. The
finite-width witness `Φ` extends `θ'` by one conjunct; `noFiniteWidth_Φ_eq` states that
mechanically. -/
def θ' : PlusFormula := NoFiniteWidth.A'.and NoFiniteWidth.C'

/-- The finite-width witness is exactly this module's fragment twin with one further conjunct.
Landing the relation as a definitional identity rather than as prose means an edit to either
landing that broke the agreement would break the build. -/
theorem noFiniteWidth_Φ_eq : NoFiniteWidth.Φ = θ'.and NoFiniteWidth.D := rfl

/-- On the shift set, two histories sharing a state at one time coincide: every history is the
orbit of its state, so a single agreement pins the whole history. -/
theorem shift_hist_unique (τ σ : WorldHistory S.frame) (t : ℤ) (h : τ.state t = σ.state t) :
    σ = τ := by
  have hτ := S.total_eq_orbit τ
  have hσ := S.total_eq_orbit σ
  have h1 : τ.state t = τ.state 0 + t :=
    congrArg (fun ρ : WorldHistory S.frame => ρ.state t) hτ
  have h2 : σ.state t = σ.state 0 + t :=
    congrArg (fun ρ : WorldHistory S.frame => ρ.state t) hσ
  have e : σ.state 0 = τ.state 0 := by
    have : (τ.state 0 : ℤ) + t = σ.state 0 + t := by rw [← h1, ← h2, h]
    exact (add_right_cancel this).symm
  rw [hσ, hτ, e]

/-- `⊡` collapses on the shift set: the stability modal quantifies over the histories through a
state, and by `shift_hist_unique` there is only one, so `⊡φ` and `φ` agree there. -/
theorem stab_iff_S (τ : WorldHistory S.frame) (t : ℤ) (φ : PlusFormula) :
    PlusTruthAt S.model τ t (.stab φ) ↔ PlusTruthAt S.model τ t φ :=
  ⟨fun h => h τ rfl, fun h σ hs => by rw [shift_hist_unique τ σ t hs]; exact h⟩

/-- On the shift set, `θ` upgrades to the fragment twin `θ'`: inserting the `⊡`s costs nothing
because `stab_iff_S` collapses them. -/
theorem θ'_of_θ (τ : WorldHistory S.frame) (t : ℤ) (h : PlusTruthAt S.model τ t θ) :
    PlusTruthAt S.model τ t θ' := by
  have hA : PlusTruthAt S.model τ t A := by
    by_contra hA; exact h (fun a => absurd a hA)
  have hC : PlusTruthAt S.model τ t C := by
    by_contra hC; exact h (fun _ c => hC c)
  intro hnot
  apply hnot
  · intro σ hnp hnsF
    rw [stab_iff_S]
    apply hA σ hnp
    intro hF
    exact hnsF ((stab_iff_S σ t NoFiniteWidth.Fp).mpr hF)
  · intro σ hp
    rw [stab_iff_S]
    exact hC σ hp

/-- **The positive half for the fragment**: `θ'.neg` is a genuine ℤ-time non-validity of L⁺ that
lies inside the CTL-like fragment, witnessed on the same ℤ-carrier shift set.

Paper: — (a non-validity internal to this formalization, with no paper counterpart) -/
theorem not_plusValidZTime_neg_θ' : ¬ PlusValidZTime θ'.neg := by
  intro hv
  have h := hv S.frame ⟨S.frame_isRegular, TaskFrame.isZTime_of_instances _⟩ S.model
    (S.hist (0 : ℤ)) (0 : ℤ)
  apply h
  apply θ'_of_θ
  rw [θ_eq_ofFormula]
  exact (plusTruthAt_ofFormula S.model ψL _ _).mpr
    ((S.forward_repr (0 : ℤ) (0 : ℤ) ψL).mpr (shiftTruth_psiL 0 0))

section Finite'

variable {F : FrameOver intOrder} [F.IsRegular]

/-- **The core refutation, for the fragment twin.** No model on a regular ℤ-frame whose
world-state carrier is `Finite` satisfies `θ'` at any history and any time.

As for `no_finite_carrier_sat`, `[Finite F.WorldState]` is the **whole** finiteness hypothesis and
there is no hypothesis on the succession relation beyond the regularity `[F.IsRegular]` carries.
The argument is the same pumping argument; the `⊡`s are discharged at the frame by instantiating
each stability modal at the history already in hand.

Paper: — (a coverage limit internal to this formalization, with no paper counterpart) -/
theorem no_finite_carrier_sat' [Finite F.WorldState] (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt M τ t θ' := by
  intro h
  have hA : PlusTruthAt M τ t NoFiniteWidth.A' := by
    by_contra hA; exact h (fun a => absurd a hA)
  have hC : PlusTruthAt M τ t NoFiniteWidth.C' := by
    by_contra hC; exact h (fun _ c => hC c)
  simp only [NoFiniteWidth.A', NoFiniteWidth.C', PlusFormula.or, PlusFormula.neg,
    NoFiniteWidth.Fp, NoFiniteWidth.Pp, PlusFormula.top, NoFiniteWidth.p, PlusTruthAt] at hA hC
  have someP : ∀ σ : WorldHistory F.toTaskFrame, ∃ a, M.valuation (σ.path a) NoFiniteWidth.pa := by
    intro σ
    by_contra hno
    have hno' : ∀ a, ¬ M.valuation (σ.state a) NoFiniteWidth.pa := fun a h => hno ⟨a, h⟩
    obtain ⟨s, -, hs, -⟩ := hA σ (hno' t)
      (fun hF => by
        obtain ⟨s, -, hs, -⟩ := hF σ rfl
        exact hno' s hs) σ rfl
    exact hno' s hs
  have firstP : ∀ σ : WorldHistory F.toTaskFrame, ∀ a, M.valuation (σ.path a) NoFiniteWidth.pa →
      ∀ b < a, ¬ M.valuation (σ.path b) NoFiniteWidth.pa := by
    intro σ a ha b hb hbt
    let g : ℤ → F.WorldState := fun n => σ.path (n + (a - t))
    have hg : ∀ n, F.step (g n) (g (n + 1)) := by
      intro n
      have := steps σ (n + (a - t))
      simp only [g]; rwa [show n + 1 + (a - t) = n + (a - t) + 1 by ring]
    apply hC (histOfStepPath g hg) ?_ (histOfStepPath g hg) rfl
    · refine ⟨b - (a - t), by omega, ?_, fun _ _ _ h => h⟩
      change M.valuation (σ.path (b - (a - t) + (a - t))) NoFiniteWidth.pa
      rwa [show b - (a - t) + (a - t) = b by ring]
    · change M.valuation (σ.path (t + (a - t))) NoFiniteWidth.pa
      rwa [show t + (a - t) = a by ring]
  obtain ⟨a, ha⟩ := someP τ
  let f : ℕ → F.WorldState := fun i => τ.path (a - 1 - i)
  obtain ⟨i, j, hij, hfij⟩ := Finite.exists_ne_map_eq_of_infinite f
  obtain ⟨x, y, hxy, hya, hpxy⟩ : ∃ x y : ℤ, x < y ∧ y ≤ a - 1 ∧ τ.path x = τ.path y := by
    rcases lt_or_gt_of_ne hij with hlt | hgt
    · exact ⟨a - 1 - j, a - 1 - i, by omega, by omega, hfij.symm⟩
    · exact ⟨a - 1 - i, a - 1 - j, by omega, by omega, hfij⟩
  set L := y - x with hL
  have hLpos : 0 < L := by omega
  let h' : ℤ → F.WorldState := fun n => τ.path (x + n % L)
  have hstep : ∀ n, F.step (h' n) (h' (n + 1)) := by
    intro n
    have hr0 := Int.emod_nonneg n (ne_of_gt hLpos)
    have hrL := Int.emod_lt_of_pos n hLpos
    have hdecomp := Int.emod_add_mul_ediv n L
    have key : τ.path (x + (n + 1) % L) = τ.path (x + n % L + 1) := by
      have e : (n + 1) % L = (n % L + 1) % L := by
        conv_lhs => rw [← hdecomp]
        rw [show n % L + L * (n / L) + 1 = (n % L + 1) + L * (n / L) by ring,
          Int.add_mul_emod_self_left]
      rw [e]
      rcases lt_or_eq_of_le (show n % L + 1 ≤ L by omega) with hlt | heq
      · rw [Int.emod_eq_of_lt (by omega) hlt, add_assoc]
      · rw [heq, Int.emod_self, add_zero, hpxy]
        congr 1; omega
    simp only [h']
    rw [key]
    exact steps τ _
  obtain ⟨s, hs⟩ := someP (histOfStepPath h' hstep)
  have hr0 := Int.emod_nonneg s (ne_of_gt hLpos)
  have hrL := Int.emod_lt_of_pos s hLpos
  exact firstP τ a ha (x + s % L) (by omega) hs

end Finite'

/-- **The finite-carrier finite model property fails already for the CTL-like fragment.** There is
a ℤ-time non-validity inside the fragment — `θ'.neg` — with no countermodel on any regular ℤ-frame
whose world-state carrier is finite. So restricting the language to the CTL-like fragment does
**not** rescue a finite-carrier certificate shape.

The scope limits of `not_finite_carrier_fmp` apply here unchanged: ℤ (discrete) frames only;
nothing claimed about an infinite carrier; nothing touching soundness in either direction; and no
bound of any kind.

One difference from `not_finite_carrier_fmp` is load-bearing: `θ'` **does** bear `⊡`
(`PlusFormula.stab`), so this twin is specifically an **L⁺** result and says nothing about the base
language TM — whereas `θ` is `⊡`-free (`θ_eq_ofFormula`) and so the main result above is already a
statement about TM itself.

The fragment's **own** finite model property — whether the fragment has one at some other frame
shape — is a separate, research-first question that this module neither answers nor assumes.

Paper: — (a coverage limit internal to this formalization, with no paper counterpart) -/
theorem not_finite_carrier_fmp_fragment :
    ¬ ∀ φ : PlusFormula, ¬ PlusValidZTime φ →
      ∃ (F : FrameOver intOrder) (_ : F.IsRegular) (_ : Finite F.WorldState)
        (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ),
        ¬ PlusTruthAt M τ t φ := by
  intro fmp
  obtain ⟨F, hreg, hfin, M, τ, t, hτ⟩ := fmp θ'.neg not_plusValidZTime_neg_θ'
  exact hτ (fun hθ => no_finite_carrier_sat' M τ t hθ)

end FiniteCarrier

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
