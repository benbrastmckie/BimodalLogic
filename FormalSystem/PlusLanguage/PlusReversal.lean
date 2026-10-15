/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.PlusValidity
import FormalSystem.Semantics.Reversal

/-!
# Time reversal of L⁺ truth — `lem:time-reflection` for the stability language

`lem:time-reflection` passes from a task frame to its **converse frame** `F⁻`, from a model to
the model over `F⁻` with the same valuation, and from a possible world `τ` to the world
`x ↦ τ(-x)` over `F⁻` (`Semantics/Reversal.lean`). This module carries that transport at L⁺:

```
M, τ, t ⊨ φ     iff     M⁻, τ⁻, -t ⊨ φ_{S|U}
```

for every sentence of L⁺, where `φ_{S|U}` is `PlusFormula.reflectTime`
(`PlusLanguage/Formula.lean`), whose stability clause sends `⊡φ` to `⊡(φ_{S|U})`.

**Why `⊡` commutes.** `⟨τ⟩_x` is defined by a same-time condition on world states, so `τ ↦ τ⁻`
carries `⟨τ⟩_x` onto `⟨τ⁻⟩_{-x}` — the semantic layer's `sameState_rev_iff`, with its image form
`OpenLanguage.image_rev_stabClass`. The reflection therefore leaves `⊡` fixed while exchanging
`U` with `S`, which is exactly the clause the paper's cut proof states.

**An induction of its own, unlike the base language.** For L, `truthAt_rev` is an instance of the
generic order-reversing transport `Truth.truthAt_of_truthAntiIso`
(`Semantics/TruthTransport.lean`), which asks only for an order-reversing equivalence of
durations, an equivalence of world histories, and atomic agreement. That machinery cannot serve
here, for the reason `Semantics/Reversal.lean`'s own docstring gives: the `⊡` clause quantifies
over a *class* of histories, and transporting a class is not what an atom-level `TruthAntiIso`
does. So L⁺ gets the seven-case induction below, exactly as L^▷ gets its own in
`OpenLanguage/OpenReversal.lean`.

## Main Definitions

None. The reversal operations this module reasons about — `FrameOver.rev`, `TaskFrame.rev`,
`TaskModel.rev`, `WorldHistory.rev` — are declared in `Semantics/` and used here through dot
notation.

## Main Results

- `plusTruthAt_rev` — `lem:time-reflection` for L⁺, the seven-case transport
- `plusValidOn_rev_iff` — the single-frame form: `φ` is valid over `F` exactly when its
  reflection is valid over `F⁻`
- `plusValidOnFrames_reflectTime` — `thm:TR-valid` at an arbitrary frame predicate, the
  primitive of the family, carrying the closure of the class under `rev` as an argument
- `plusValidIn_reflectTime`, `plusValidIn_reflectTime_iff`, `plusValid_reflectTime` —
  `thm:TR-valid` at a frame class, in its involution form, and at the unconstrained class

## References

* JPL paper `lem:time-reflection` — the converse frame, the reflected world, and the transport
* JPL paper `thm:TR-valid` — the validity-level consequence
* JPL paper `def:time-reflection` — `reflectTime`, whose L⁺ extension is in
  `PlusLanguage/Formula.lean`
* `cor:deterministic-completeness` — **CUT from the live paper**, kept verbatim in
  `JPL/appendix_cut_material.tex` under the header "The stability logic and its completeness over
  the deterministic frames". Its soundness half states the `⊡` extension of `lem:time-reflection`
  in one sentence: the mirror of a stability formula is the stability of its mirror, since
  `τ ↦ τ⁻` carries the state-local class at `x` onto the state-local class at `-x`. That sentence
  is what this module formalizes; the Cthm itself is cited for nothing proved here, and the
  completeness result it states is already in the tree under `Metalogic/Deterministic/`
* `FormalSystem/Semantics/Reversal.lean` — `TaskModel.rev`, `WorldHistory.rev`,
  `sameState_rev_iff`, and `truthAt_rev`, which is `lem:time-reflection` for the base language
* `FormalSystem/Semantics/Validity.lean` — the base-language validity family these mirror
* `FormalSystem/OpenLanguage/OpenReversal.lean` — the same transport one language up

## Tags

plus-language · time-reflection · converse-frame · stability-modal
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

/-! ## The transport theorem -/

/--
**`lem:time-reflection` for L⁺.** A formula is true at `(M, τ, t)` exactly when its time
reflection is true at the reflected point `(M⁻, τ⁻, -t)` of the converse frame.

By induction on `φ`, generalizing the history and the time. `box` uses the surjectivity of
reversal on histories; `untl` and `snce` negate the bounds, which is where `reflectTime`
exchanges the two tenses; `stab` is the semantic layer's `sameState_rev_iff`, the one place the
carrying of `⟨τ⟩_x` onto `⟨τ⁻⟩_{-x}` is used.

Paper: `lem:time-reflection`
-/
theorem plusTruthAt_rev {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) : PlusTruthAt M τ t φ ↔ PlusTruthAt M.rev τ.rev (-t) φ.reflectTime := by
  induction φ generalizing τ t with
  | atom p =>
    change M.valuation (τ.state t) p ↔ M.valuation (τ.state (- -t)) p
    rw [neg_neg]
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih =>
    constructor
    · intro h σ'
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ)
    · intro h σ
      exact (ih σ t).mpr (h σ.rev)
  | untl ψ φ ihψ ihφ =>
    constructor
    · rintro ⟨s, hts, hφ, hψ⟩
      refine ⟨-s, neg_lt_neg hts, (ihφ τ s).mp hφ, ?_⟩
      intro r' h1 h2
      obtain ⟨r, rfl⟩ : ∃ r : F.Duration, r' = -r := ⟨-r', (neg_neg r').symm⟩
      exact (ihψ τ r).mp (hψ r (neg_lt_neg_iff.mp h2) (neg_lt_neg_iff.mp h1))
    · rintro ⟨s', hs't, hφ, hψ⟩
      obtain ⟨s, rfl⟩ : ∃ s : F.Duration, s' = -s := ⟨-s', (neg_neg s').symm⟩
      refine ⟨s, neg_lt_neg_iff.mp hs't, (ihφ τ s).mpr hφ, ?_⟩
      intro r h1 h2
      exact (ihψ τ r).mpr (hψ (-r) (neg_lt_neg h2) (neg_lt_neg h1))
  | snce ψ φ ihψ ihφ =>
    constructor
    · rintro ⟨s, hst, hφ, hψ⟩
      refine ⟨-s, neg_lt_neg hst, (ihφ τ s).mp hφ, ?_⟩
      intro r' h1 h2
      obtain ⟨r, rfl⟩ : ∃ r : F.Duration, r' = -r := ⟨-r', (neg_neg r').symm⟩
      exact (ihψ τ r).mp (hψ r (neg_lt_neg_iff.mp h2) (neg_lt_neg_iff.mp h1))
    · rintro ⟨s', hts', hφ, hψ⟩
      obtain ⟨s, rfl⟩ : ∃ s : F.Duration, s' = -s := ⟨-s', (neg_neg s').symm⟩
      refine ⟨s, neg_lt_neg_iff.mp hts', (ihφ τ s).mpr hφ, ?_⟩
      intro r h1 h2
      exact (ihψ τ r).mpr (hψ (-r) (neg_lt_neg h2) (neg_lt_neg h1))
  | stab φ ih =>
    constructor
    · intro h σ' hs
      obtain ⟨σ, rfl⟩ := WorldHistory.rev_surjective σ'
      exact (ih σ t).mp (h σ ((sameState_rev_iff τ σ t).mpr hs))
    · intro h σ hs
      exact (ih σ t).mpr (h σ.rev ((sameState_rev_iff τ σ t).mp hs))

/-! ## Validity is closed under time reflection — `thm:TR-valid` at L⁺ -/

/--
**`lem:time-reflection` at the level of a single frame**, for L⁺: `φ` is valid over `F` exactly
when its time reflection is valid over the converse frame `F⁻`. The L⁺ twin of
`Semantics.validOn_rev_iff`, arm for arm.

The backward arm goes through `WorldHistory.rev_surjective` — every world over `F⁻` is the
reflection of a world over `F` — and then undoes the double negation on the evaluation time.

Paper: `lem:time-reflection`
-/
theorem plusValidOn_rev_iff (F : TaskFrame) (φ : PlusFormula) :
    F.rev.PlusValidOn φ.reflectTime ↔ F.PlusValidOn φ := by
  constructor
  · intro h M τ t
    exact (plusTruthAt_rev M τ t φ).mpr (h M.rev τ.rev (-t))
  · intro h M' τ' t'
    obtain ⟨τ, rfl⟩ := WorldHistory.rev_surjective τ'
    have key := (plusTruthAt_rev (M'.rev : TaskModel F) τ (-t') φ).mp (h _ τ (-t'))
    rw [neg_neg] at key
    exact key

/--
**`thm:TR-valid`, at an arbitrary frame predicate.** L⁺ validity over any `rev`-closed class of
frames is closed under time reflection: `F⁻⁻ = F`, so a validity over the class yields the
reflected validity by `plusValidOn_rev_iff` at `F⁻`. The L⁺ twin of
`Semantics.validOnFrames_reflectTime`.

This is the **primitive** of the family, carrying the closure as an argument. The generality is
what reaches a class no `FrameClass` tag denotes — the frames validating *Determined* and the
deterministic frames both arrive this way
(`Metalogic/Deterministic/Validity.lean`).

Paper: `thm:TR-valid`
-/
theorem plusValidOnFrames_reflectTime {P : TaskFrame → Prop} {φ : PlusFormula}
    (hP : ∀ F : TaskFrame, P F → P F.rev) (h : PlusValidOnFrames P φ) :
    PlusValidOnFrames P φ.reflectTime :=
  fun F hF => (plusValidOn_rev_iff F.rev φ).mpr (h F.rev (hP F hF))

/--
**`thm:TR-valid`, frame-class form** for L⁺: if `⊨_fc φ` then `⊨_fc φ_{S|U}`, at *every* frame
class. The L⁺ twin of `Semantics.validIn_reflectTime`.

No closure hypothesis is needed, and that is the content of `ProofSystem.FrameClass.Sat.rev`
(`Semantics/FrameClassValidity.lean`): the converse frame shares its temporal order, so each
tag's own frame condition transfers unchanged and only regularity has to be re-derived.

Paper: `thm:TR-valid`
-/
theorem plusValidIn_reflectTime {fc : ProofSystem.FrameClass} {φ : PlusFormula}
    (h : PlusValidIn fc φ) : PlusValidIn fc φ.reflectTime :=
  plusValidOnFrames_reflectTime (fun _ => ProofSystem.FrameClass.Sat.rev) h

/--
The involution form, which is what a caller reasoning *back* from a reflected formula wants:
`reflectTime` is its own inverse (`PlusFormula.reflect_time_involution`), so the implication
above is a biconditional. The L⁺ twin of `Semantics.validIn_reflectTime_iff`.
-/
theorem plusValidIn_reflectTime_iff {fc : ProofSystem.FrameClass} {φ : PlusFormula} :
    PlusValidIn fc φ.reflectTime ↔ PlusValidIn fc φ := by
  constructor
  · intro h
    have := plusValidIn_reflectTime h
    rwa [PlusFormula.reflect_time_involution] at this
  · exact plusValidIn_reflectTime

/--
**`thm:TR-valid`** at the unconstrained class, for L⁺: `⊨ φ` implies `⊨ φ_{S|U}`. The L⁺ twin of
`Semantics.valid_reflectTime`.

Paper: `thm:TR-valid`
-/
theorem plusValid_reflectTime {φ : PlusFormula} (h : PlusValid φ) :
    PlusValid φ.reflectTime :=
  plusValidIn_reflectTime h

end FormalSystem.PlusLanguage
