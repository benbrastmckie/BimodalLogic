/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusValidity
import FormalSystem.Metalogic.Soundness

/-!
# Atomization — TM schema soundness over L⁺ in one lemma

The TM schemata of TM⁺ (`PlusLanguage/Axioms.lean`) range over all of `PlusFormula`, so their
instances may contain `⊡`. Rather than re-proving all 45 schemata over `PlusTruthAt`, this
module transfers the landed L validity lemmas `axiom_validIn_min` / `axiom_swap_validIn_min`
(`Metalogic/Soundness.lean`) through **atomization**:

1. `⊡χ` depends on the world state alone (`Semantics.stab_state_only`), so it behaves like a
   state-valued atom.
2. `atomize e : PlusFormula → Formula` replaces each maximal `⊡χ` by a fresh atom `e.ι (inr χ)`
   and each atom `p` by `e.ι (inl p)`, for an injective **encoding**
   `e.ι : Atom ⊕ PlusFormula → Atom` (`Encoding`; one exists classically because both sides are
   denumerable).
3. `TaskModel.atomModel M e` is the L model on the same frame whose valuation reads `e.ι (inl p)`
   as `p` and `e.ι (inr χ)` as "`⊡χ` holds at some total history through this state, at some
   time" — well defined by (1).
4. `plusTruthAt_iff_atomize`: `PlusTruthAt M τ t φ ↔ TruthAt (M.atomModel e) τ t (atomize e φ)`.

A TM schema instance over L⁺ then holds in `M` iff its L instance at the atomized parameters
holds in `M.atomModel e`, which is the landed lemma applied on the same frame — so `fc.Sat` is
inherited. `plusValidIn_of_tm` packages this, and `plusValidIn_swap_of_tm` its swap form via
`atomize_swapTemporal` (atomization commutes with temporal duality up to swapping the encoding,
`Encoding.swap`).

## Main Definitions

- `Encoding`, `Encoding.nonempty`, `Encoding.swap`
- `atomize`, `TaskModel.atomModel`

## Main Results

- `plusTruthAt_iff_atomize` — the transfer lemma
- `atomize_swapTemporal` — `atomize e φ.swapTemporal = (atomize e.swap φ).swapTemporal`
- `plusValidIn_of_tm`, `plusValidIn_swap_of_tm` — the two helpers the dispatch lemmas of
  `Conservativity/Plus/AxiomValidity.lean` consume

## References

* `FormalSystem/Metalogic/Soundness.lean` — `axiom_validIn`, `axiom_swap_validIn`
* `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean` — `stab_state_only`
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-! ## Encodings -/

/-- An injective encoding of atoms and `⊡`-formulas into atoms. -/
structure Encoding where
  /-- The encoding map. -/
  ι : Atom ⊕ PlusFormula → Atom
  /-- Injectivity. -/
  inj : Function.Injective ι

/-- An encoding exists: both `Atom ⊕ PlusFormula` and `Atom` are denumerable. -/
theorem Encoding.nonempty : Nonempty Encoding := by
  haveI : Denumerable Atom := Classical.choice (nonempty_denumerable Atom)
  exact ⟨⟨(Denumerable.eqv (Atom ⊕ PlusFormula)).trans (Denumerable.eqv Atom).symm,
    Equiv.injective _⟩⟩

/-- `swapTemporal` is injective, being an involution. -/
theorem swapTemporal_injective : Function.Injective PlusFormula.swapTemporal :=
  Function.Involutive.injective swap_temporal_involution

/-- The encoding conjugated by temporal duality on the `⊡`-formula side: `e.swap.ι (inr χ) =
e.ι (inr χ.swapTemporal)`. Injective because `swapTemporal` is an involution. -/
def Encoding.swap (e : Encoding) : Encoding where
  ι := e.ι ∘ Sum.map id PlusFormula.swapTemporal
  inj := e.inj.comp (Sum.map_injective.mpr ⟨fun _ _ h => h, swapTemporal_injective⟩)

/-! ## Atomization -/

/-- Replace each atom `p` by `e.ι (inl p)` and each maximal `⊡χ` by the fresh atom
`e.ι (inr χ)`; structural on the six L constructors. -/
def atomize (e : Encoding) : PlusFormula → Formula
  | .atom p => .atom (e.ι (.inl p))
  | .bot => .bot
  | .imp φ ψ => .imp (atomize e φ) (atomize e ψ)
  | .box φ => .box (atomize e φ)
  | .untl φ ψ => .untl (atomize e φ) (atomize e ψ)
  | .snce φ ψ => .snce (atomize e φ) (atomize e ψ)
  | .stab χ => .atom (e.ι (.inr χ))

/-! Push-through equations, all `rfl`: the derived operators of `PlusFormula` carry `Formula`'s
right-hand sides, and `atomize` is structural on the L constructors. -/

@[simp] theorem atomize_top (e : Encoding) : atomize e top = Formula.top := rfl
@[simp] theorem atomize_neg (e : Encoding) (φ : PlusFormula) :
    atomize e φ.neg = (atomize e φ).neg := rfl
@[simp] theorem atomize_and (e : Encoding) (φ ψ : PlusFormula) :
    atomize e (φ.and ψ) = (atomize e φ).and (atomize e ψ) := rfl
@[simp] theorem atomize_or (e : Encoding) (φ ψ : PlusFormula) :
    atomize e (φ.or ψ) = (atomize e φ).or (atomize e ψ) := rfl
@[simp] theorem atomize_diamond (e : Encoding) (φ : PlusFormula) :
    atomize e φ.diamond = (atomize e φ).diamond := rfl
@[simp] theorem atomize_someFuture (e : Encoding) (φ : PlusFormula) :
    atomize e (someFuture φ) = Formula.someFuture (atomize e φ) := rfl
@[simp] theorem atomize_somePast (e : Encoding) (φ : PlusFormula) :
    atomize e (somePast φ) = Formula.somePast (atomize e φ) := rfl
@[simp] theorem atomize_allFuture (e : Encoding) (φ : PlusFormula) :
    atomize e (allFuture φ) = Formula.allFuture (atomize e φ) := rfl
@[simp] theorem atomize_allPast (e : Encoding) (φ : PlusFormula) :
    atomize e (allPast φ) = Formula.allPast (atomize e φ) := rfl
@[simp] theorem atomize_kPlus (e : Encoding) (φ : PlusFormula) :
    atomize e (kPlus φ) = Formula.kPlus (atomize e φ) := rfl
@[simp] theorem atomize_kMinus (e : Encoding) (φ : PlusFormula) :
    atomize e (kMinus φ) = Formula.kMinus (atomize e φ) := rfl

/-- Atomization commutes with temporal duality, up to conjugating the encoding: the fresh atom
for `⊡χ.swapTemporal` under `e` is the fresh atom for `⊡χ` under `e.swap`. -/
theorem atomize_swapTemporal (e : Encoding) (φ : PlusFormula) :
    atomize e φ.swapTemporal = (atomize e.swap φ).swapTemporal := by
  induction φ with
  | atom p => rfl
  | bot => rfl
  | imp φ ψ ihφ ihψ => simp only [PlusFormula.swapTemporal, atomize, Formula.swapTemporal, ihφ, ihψ]
  | box φ ih => simp only [PlusFormula.swapTemporal, atomize, Formula.swapTemporal, ih]
  | untl φ ψ ihφ ihψ => simp only [PlusFormula.swapTemporal, atomize, Formula.swapTemporal, ihφ, ihψ]
  | snce φ ψ ihφ ihψ => simp only [PlusFormula.swapTemporal, atomize, Formula.swapTemporal, ihφ, ihψ]
  | stab χ _ => rfl

/-! ## The atomized model -/

variable {F : TaskFrame}

/-- The L model on `M`'s frame that reads the encoded atoms back: `e.ι (inl p)` as `p`, and
`e.ι (inr χ)` as "`⊡χ` holds at some total history through this state, at some time". The
second clause is well defined as a state property by `stab_state_only`. -/
def _root_.FormalSystem.Semantics.TaskModel.atomModel (M : TaskModel F) (e : Encoding) :
    TaskModel F where
  valuation w a :=
    (∃ p, e.ι (.inl p) = a ∧ M.valuation w p) ∨
    (∃ χ, e.ι (.inr χ) = a ∧ ∃ (τ : ConvexHistory F) (hτ : τ.IsTotal) (t : F.Duration),
      τ.states t (hτ t) = w ∧ PlusTruthAt M τ t (.stab χ))

/--
**The transfer lemma.** At a total history, an L⁺ formula is true in `M` iff its atomization is
true in the atomized model. By induction on `φ`, `generalizing τ t`: the six L cases are
congruence (the `box` case ranges over total `σ`), the `atom` case is injectivity of the
encoding, and the `stab` case is `stab_state_only` — the `→` direction witnesses `τ` itself, the
`←` direction transports the witnessing history's `⊡χ` to `τ` through the shared state.
-/
theorem plusTruthAt_iff_atomize (M : TaskModel F) (e : Encoding) (φ : PlusFormula) :
    ∀ (τ : ConvexHistory F) (hτ : τ.IsTotal) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ TruthAt (M.atomModel e) τ t (atomize e φ) := by
  induction φ with
  | atom p =>
    intro τ hτ t
    constructor
    · rintro ⟨ht, hv⟩
      exact ⟨ht, Or.inl ⟨p, rfl, hv⟩⟩
    · rintro ⟨ht, hv⟩
      refine ⟨ht, ?_⟩
      rcases hv with ⟨p', hp, hv⟩ | ⟨χ, hχ, _⟩
      · cases Sum.inl.inj (e.inj hp)
        exact hv
      · exact absurd (e.inj hχ) Sum.inr_ne_inl
  | bot => intro τ _ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro τ hτ t; exact Iff.imp (ihφ τ hτ t) (ihψ τ hτ t)
  | box φ ih =>
    intro τ hτ t
    exact forall_congr' fun σ => imp_congr_right fun hσ => ih σ hσ t
  | untl ψ φ ihψ ihφ =>
    intro τ hτ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ hτ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ hτ r)
  | snce ψ φ ihψ ihφ =>
    intro τ hτ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ hτ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ hτ r)
  | stab χ _ =>
    intro τ hτ t
    constructor
    · intro h
      exact ⟨hτ t, Or.inr ⟨χ, rfl, τ, hτ, t, rfl, h⟩⟩
    · rintro ⟨ht, hv⟩
      rcases hv with ⟨p, hp, _⟩ | ⟨χ', hχ, σ, hσ, s, hst, hs⟩
      · exact absurd (e.inj hp) Sum.inl_ne_inr
      · cases Sum.inr.inj (e.inj hχ)
        exact (stab_state_only M σ τ hσ hτ s t hst χ).mp hs

/-! ## The two helpers for the dispatch lemmas -/

/--
**TM schema soundness over L⁺.** If the atomization of `φ` is a TM axiom instance admissible
at `fc`, then `φ` is `PlusValidIn fc`: `axiom_validIn` on the atomized model (same frame, so
`fc.Sat` is inherited), transported back through `plusTruthAt_iff_atomize`.
-/
theorem plusValidIn_of_tm {fc : FrameClass} (e : Encoding) (φ : PlusFormula)
    (ax : Axiom (atomize e φ)) (h : ax.minFrameClass ≤ fc) : PlusValidIn fc φ :=
  PlusValidIn.of_forall_total fun F hF M τ hτ t =>
    (plusTruthAt_iff_atomize M e φ τ hτ t).mpr
      ((axiom_validIn ax h).apply_total F hF (M.atomModel e) τ hτ t)

/--
**TM schema swap-soundness over L⁺.** If the atomization of `φ` **under the conjugated
encoding** is a TM axiom instance admissible at `fc`, then `φ.swapTemporal` is
`PlusValidIn fc`: `axiom_swap_validIn` on the atomized model, with `atomize_swapTemporal`
rewriting the target.
-/
theorem plusValidIn_swap_of_tm {fc : FrameClass} (e : Encoding) (φ : PlusFormula)
    (ax : Axiom (atomize e.swap φ)) (h : ax.minFrameClass ≤ fc) :
    PlusValidIn fc φ.swapTemporal :=
  PlusValidIn.of_forall_total fun F hF M τ hτ t =>
    (plusTruthAt_iff_atomize M e φ.swapTemporal τ hτ t).mpr
      (by
        rw [atomize_swapTemporal]
        exact (axiom_swap_validIn ax h).apply_total F hF (M.atomModel e) τ hτ t)

/-! ## Acceptance test

`□⊡p → □G⊡p` — MF at a `⊡`-formula — is sound over every task frame, by one application of
`plusValidIn_of_tm` to `Axiom.modal_future` at the fresh atom for `⊡p`. -/

example (p : Atom) :
    PlusValidIn FrameClass.Base
      ((PlusFormula.box (PlusFormula.stab (PlusFormula.atom p))).imp
        (PlusFormula.box (allFuture (PlusFormula.stab (PlusFormula.atom p))))) :=
  let e : Encoding := Classical.choice Encoding.nonempty
  plusValidIn_of_tm e _ (Axiom.modal_future (Formula.atom (e.ι (.inr (PlusFormula.atom p)))))
    le_rfl

end FormalSystem.Metalogic.Conservativity
