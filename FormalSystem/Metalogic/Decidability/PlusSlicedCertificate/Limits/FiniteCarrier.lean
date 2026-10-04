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

end FiniteCarrier

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
