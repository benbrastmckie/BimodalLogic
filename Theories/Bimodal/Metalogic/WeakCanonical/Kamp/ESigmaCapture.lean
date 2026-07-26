/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.Kamp.PerFormulaType

/-!
# E[Σ] Canonical-Expansion Conservativity + Atom-Naming (Def 4.1 collapse facts)

This module supplies the two semantic facts about the canonical expansion `canonExpand`
(`ESigmaExpansion.lean`) that the ζ re-wire consumes (Rabinovich, *A Proof of Kamp's Theorem*,
2014, Definition 4.1, PDF p.5, and the p.6 collapse-to-atom note):

- `temporal_truth_canonExpand`: **conservativity** — when the object-language atom map factors
  through the old predicates, `temporal_truth` is preserved verbatim between `M` and its
  canonical expansion (the fresh atoms never participate; carrier and order are inherited).
- `canonExpand_atom_named`: **atom-naming** — on the concrete `canonExpand` built with the
  fresh atoms interpreted as `M`'s temporal truth (the ζ-site choice
  `sat A := temporal_truth M g · A`), the fresh atom `esigmaPred A` reads back exactly as
  `temporal_truth N atomMap · A`. With the infinite E[Σ] alphabet (`sigE`'s fresh summand is
  the full `Formula` type), this holds for EVERY formula `A` — no `A ∈ F` membership premise.

## Where the old finite-alphabet capture machinery went

Under the pre-flip finite alphabet (`sig.preds ⊕ {A // A ∈ F}`) this module additionally
carried the interval-level reverse-capture machinery (`intervalCapture_of_atomNamed` /
`intervalCapture_forall_mem` / `esigmaCapture_canonExpand`) discharging the threaded
`hCapture` hypothesis by a whole-alphabet `Finset.univ.filter` witness. That construction is a
finite-alphabet encoding artifact: it requires `Fintype` on the E[Σ] predicate names, which the
infinite Def 4.1 alphabet deliberately does not have. It is deleted, not ported — on the
infinite expansion every readback IS an atom (`atom_eval_new`), so the capture obligation is
discharged directly at the ζ re-wire and the `hCapture`/`capFn` parameters are removed there
(see the p.6 collapse note; the atomic-naming content survives as `canonExpand_atom_named`).

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Definition 4.1 (p.5), collapse-to-atom note
  (p.6). Cited by PDF page; the companion markdown transcription is corrupt.
- `ESigmaExpansion.lean`: `sigE`, `esigmaPred`, `canonExpand`, `atom_eval_new`.
- `Table.lean`: `temporal_truth`.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula)
open Bimodal.Metalogic.WeakCanonical

/-! ## 1. Discharging the atom-naming premise on the concrete `canonExpand`

The atom-naming biconditional is not an axiom: on the concrete canonical expansion built with
the fresh atoms interpreted as the temporal truth carried by `M` (the ζ-site choice
`sat A := temporal_truth M g · A`), it holds by `atom_eval_new` composed with a
**conservativity** fact — `temporal_truth` is preserved from `M` to its expansion, because the
object-language `atomMap` factors through the *old* predicates (`oldPred`) and the carrier + order
are inherited verbatim. This is the faithful "E[Σ] is closed at the stage" content of Def 4.1 (p.5):
the fresh atom reads back exactly as the truth of the formula it names. -/

/--
**Conservativity of `temporal_truth` under `canonExpand`.** When the object-language atom map
factors through the old predicates (`atomMap φ = oldPred (g φ)`), evaluating a `TL` formula in the
canonical expansion `canonExpand sig F M sat` agrees with evaluating it in `M` under `g`. The fresh
E[Σ] atoms never participate, and the carrier and linear order are inherited verbatim, so the
`Until`/`Since` quantifiers range over the identical ordered carrier. Proved by induction on the
formula.
-/
theorem temporal_truth_canonExpand {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ)) (A : Formula) (y : M.carrier) :
    temporal_truth (canonExpand sig F M sat) atomMap y A ↔ temporal_truth M g y A := by
  induction A generalizing y with
  | atom a => simp only [temporal_truth, hMap, oldPred, canonExpand]
  | bot => simp only [temporal_truth]
  | imp φ ψ ihφ ihψ => simp only [temporal_truth, ihφ, ihψ]
  | box φ _ => simp only [temporal_truth, hMap, oldPred, canonExpand]
  | untl φ ψ ihφ ihψ =>
    simp only [temporal_truth]
    constructor
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mp hsφ, fun r h1 h2 => (ihψ r).mp (hr r h1 h2)⟩
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mpr hsφ, fun r h1 h2 => (ihψ r).mpr (hr r h1 h2)⟩
  | snce φ ψ ihφ ihψ =>
    simp only [temporal_truth]
    constructor
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mp hsφ, fun r h1 h2 => (ihψ r).mp (hr r h1 h2)⟩
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mpr hsφ, fun r h1 h2 => (ihψ r).mpr (hr r h1 h2)⟩

/--
**Atom-naming on the concrete `canonExpand` (Def 4.1 p.5 / p.6 collapse).**
Build the canonical expansion with the fresh atoms interpreted as `M`'s temporal truth,
`sat B := temporal_truth M g · B`. Then for EVERY formula `A` — the infinite E[Σ] alphabet
names all of them, no `A ∈ F` premise — the fresh atom `esigmaPred A` reads back exactly as
`temporal_truth N atomMap · A`. The left side collapses to `sat A y = temporal_truth M g y A`
by `atom_eval_new`; the right side agrees with it by `temporal_truth_canonExpand`. This is the
fact that lets the ζ re-wire discharge the capture obligation directly (every readback is an
atom of the expansion).
-/
theorem canonExpand_atom_named {sig : MonadicSignature} {F : Finset Formula}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ)) (A : Formula) (y : M.carrier) :
    (canonExpand sig F M (fun B x => temporal_truth M g x B)).interp (esigmaPred A) y
      ↔ temporal_truth (canonExpand sig F M (fun B x => temporal_truth M g x B)) atomMap y A := by
  -- LHS is `sat A y = temporal_truth M g y A` definitionally (canonExpand on a fresh atom).
  change temporal_truth M g y A
      ↔ temporal_truth (canonExpand sig F M (fun B x => temporal_truth M g x B)) atomMap y A
  exact (temporal_truth_canonExpand M (fun B x => temporal_truth M g x B) atomMap g hMap A y).symm

/-! ## 2. Direct `M`-relative capture: the readback IS an atom (p.6 collapse)

Under the infinite E[Σ] alphabet every temporal-logic readback `A` is named by the fresh atom
`esigmaPred A`, so capturing `A`'s truth-set as an interval type needs no alphabet-wide search
and no threaded capture hypothesis: the interval is the SINGLETON partial type over the
singleton mentioned-atom set `{A-at-the-point}` asserting the fresh atom true. This is the
direct discharge the ζ re-wire uses in place of the deleted finite-alphabet capture machinery:
the `M`-relative shape (`IntervalTypeFin` over a one-element `M`) is exactly Prop 3.5's
"finitely many mentioned atoms" (p.5), and the semantic content is the p.6 collapse-to-atom
note. -/

variable {sig : MonadicSignature} {F : Finset Formula}

/-- **The direct capture interval for an E[Σ] predicate `p`.** The singleton interval type over
the singleton mentioned-atom set `{p · 0}` whose unique partial 1-type asserts `p` true at the
point. Purely syntactic in `p` — no model input, no alphabet enumeration, no instances. -/
def capTypeFin (p : (sigE sig F).preds) :
    IntervalTypeFin sig F {AtomKind.pred p (0 : Fin 1)} :=
  {fun _ => true}

/-- **Generic realization of the direct capture interval.** For every structure `N` over the
E[Σ] alphabet, a point `y` satisfies `capTypeFin p` iff `N` interprets `p` true at `y`. -/
theorem intervalHoldsFin_capTypeFin (N : OrderedMonadicStructure (sigE sig F))
    (p : (sigE sig F).preds) (y : N.carrier) :
    intervalHoldsFin N (capTypeFin p) y ↔ N.interp p y := by
  unfold capTypeFin intervalHoldsFin
  constructor
  · rintro ⟨c, hc, hold⟩
    rw [Finset.mem_singleton] at hc
    subst hc
    exact (hold ⟨AtomKind.pred p (0 : Fin 1), Finset.mem_singleton_self _⟩).mpr rfl
  · intro h
    refine ⟨fun _ => true, Finset.mem_singleton_self _, ?_⟩
    rintro ⟨a, ha⟩
    rw [Finset.mem_singleton] at ha
    subst ha
    simpa [atom_eval] using h

/-- **Atom-named capture (the ζ-site discharge shape).** Given that `N` names every readback —
each fresh atom `esigmaPred A` reads back as the temporal truth of `A` (on the concrete
`canonExpand` this is exactly `canonExpand_atom_named`) — the direct capture interval
`capTypeFin (esigmaPred A)` captures `A`'s truth-set at every point. This is the fact the
capture-free negation stack consumes: capture is CONSTRUCTED, never hypothesized. -/
theorem capTypeFin_atomNamed (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (hNamed : ∀ (A : Formula) (y : N.carrier),
        N.interp (esigmaPred (F := F) A) y ↔ temporal_truth N atomMap y A)
    (A : Formula) (y : N.carrier) :
    intervalHoldsFin N (capTypeFin (esigmaPred (F := F) A)) y
      ↔ temporal_truth N atomMap y A :=
  (intervalHoldsFin_capTypeFin N (esigmaPred (F := F) A) y).trans (hNamed A y)

end Bimodal.Metalogic.WeakCanonical.Kamp
