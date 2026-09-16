/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.PlusLanguage.Derivation

/-!
# The naive `⊡`-system: TM⁺ with the two pasting axioms withheld

`NaiveDerivable` is derivability in TM⁺ (`PlusLanguage/Derivation.lean`) using only the axiom
schemata **other than** `paste` and `untl_paste` — that is, TM together with the six S5/bridge
schemata for `⊡` (SK, ST, S4, S5, MS, AS). It is the system whose *incompleteness* the two
pasting axioms exist to repair, and `Metalogic/Independence/PastingIndependence.lean` records
that they are genuinely needed.

## The naive system stays out of the live proof system

There is **no second axiom inductive**. `NaiveDerivable` is a predicate on the *existing*
`PlusDerivationTree`s: a recursive `NaiveOnly` requiring every `axiom` node's `PlusAxiom` to be
outside `{paste, untl_paste}`, and then

```
NaiveDerivable fc Γ φ := ∃ d : PlusDerivationTree fc Γ φ, d.NaiveOnly.
```

So `PlusAxiom` is untouched, nothing downstream recompiles differently, and the naive system is
by construction a *sub*-system of TM⁺: `naiveDerivable_imp_plusDerivable` is immediate.

## Main Definitions

- `PlusAxiom.IsNaive` — the schema is not one of the two pasting schemata
- `PlusDerivationTree.NaiveOnly` — every `axiom` node of the tree is naive
- `NaiveDerivable`

## Main Results

- `naiveDerivable_imp_plusDerivable` — the naive system is a subsystem of TM⁺
- `NaiveDerivable.mono` — monotonicity in the frame class
- the derived rules `naiveMp`, `naiveAx`, `naiveNec`, `naiveTNec`, `naiveTDual`, which is the
  full rule inventory the soundness recursion needs

## References

* `FormalSystem/PlusLanguage/Axioms.lean` — the docstring explaining why the S5/bridge set alone
  is provably incomplete and what the pasting schemata add

## Tags

independence · proof-system · plus-language · stability-modal
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage

/-- A TM⁺ schema is **naive** when it is not one of the two pasting schemata. Every TM arm and
every S5/bridge `⊡` arm is naive. -/
def PlusAxiom.IsNaive {φ : PlusFormula} : PlusAxiom φ → Prop
  | .paste _ _ _ _ => False
  | .untl_paste _ _ _ _ => False
  | _ => True

/-- A derivation is **naive-only** when every `axiom` node in it cites a naive schema. -/
def _root_.FormalSystem.PlusLanguage.PlusDerivationTree.NaiveOnly {fc : FrameClass} : {Γ : PlusContext} → {φ : PlusFormula} →
    PlusDerivationTree fc Γ φ → Prop
  | _, _, .axiom _ _ h _ => PlusAxiom.IsNaive h
  | _, _, .assumption _ _ _ => True
  | _, _, .modus_ponens _ _ _ d1 d2 => d1.NaiveOnly ∧ d2.NaiveOnly
  | _, _, .necessitation _ d => d.NaiveOnly
  | _, _, .temporal_necessitation _ d => d.NaiveOnly
  | _, _, .temporal_duality _ d => d.NaiveOnly
  | _, _, .weakening _ _ _ d _ => d.NaiveOnly

/-- Derivability in TM⁺ with the two pasting axioms withheld. -/
def NaiveDerivable (fc : FrameClass) (Γ : PlusContext) (φ : PlusFormula) : Prop :=
  ∃ d : PlusDerivationTree fc Γ φ, d.NaiveOnly

/-- The naive system is a subsystem of TM⁺: forgetting the side condition gives a TM⁺
derivation. -/
theorem naiveDerivable_imp_plusDerivable {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula}
    (h : NaiveDerivable fc Γ φ) : PlusDerivable fc Γ φ :=
  h.elim fun d _ => ⟨d⟩

/-- `lift` preserves naivety: it rewrites only the frame-class side conditions. -/
theorem _root_.FormalSystem.PlusLanguage.PlusDerivationTree.naiveOnly_lift {fc₁ fc₂ : FrameClass} (h_le : fc₁ ≤ fc₂) :
    ∀ {Γ : PlusContext} {φ : PlusFormula} (d : PlusDerivationTree fc₁ Γ φ),
      d.NaiveOnly → (d.lift h_le).NaiveOnly
  | _, _, .axiom _ _ _ _, hd => hd
  | _, _, .assumption _ _ _, _ => trivial
  | _, _, .modus_ponens _ _ _ d1 d2, hd =>
      ⟨naiveOnly_lift h_le d1 hd.1, naiveOnly_lift h_le d2 hd.2⟩
  | _, _, .necessitation _ d, hd => naiveOnly_lift h_le d hd
  | _, _, .temporal_necessitation _ d, hd => naiveOnly_lift h_le d hd
  | _, _, .temporal_duality _ d, hd => naiveOnly_lift h_le d hd
  | _, _, .weakening _ _ _ d _, hd => naiveOnly_lift h_le d hd

/-- `NaiveDerivable` is monotone in the frame class. -/
theorem NaiveDerivable.mono {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {Γ : PlusContext}
    {φ : PlusFormula} (hd : NaiveDerivable fc₁ Γ φ) : NaiveDerivable fc₂ Γ φ :=
  hd.elim fun d hn => ⟨d.lift h, PlusDerivationTree.naiveOnly_lift h d hn⟩

/-! ## The derived rules -/

variable {fc : FrameClass}

/-- A naive axiom instance is a naive theorem. -/
theorem naiveAx {φ : PlusFormula} (h : PlusAxiom φ) (hn : PlusAxiom.IsNaive h)
    (hb : h.minFrameClass ≤ fc) : NaiveDerivable fc [] φ :=
  ⟨.axiom [] φ h hb, hn⟩

/-- Modus ponens in the naive system. -/
theorem naiveMp {φ ψ : PlusFormula} (h1 : NaiveDerivable fc [] (φ.imp ψ))
    (h2 : NaiveDerivable fc [] φ) : NaiveDerivable fc [] ψ :=
  h1.elim fun d1 hn1 => h2.elim fun d2 hn2 => ⟨.modus_ponens [] φ ψ d1 d2, ⟨hn1, hn2⟩⟩

/-- Necessitation in the naive system. -/
theorem naiveNec {φ : PlusFormula} (h : NaiveDerivable fc [] φ) :
    NaiveDerivable fc [] (PlusFormula.box φ) :=
  h.elim fun d hn => ⟨.necessitation φ d, hn⟩

/-- Temporal necessitation in the naive system. -/
theorem naiveTNec {φ : PlusFormula} (h : NaiveDerivable fc [] φ) :
    NaiveDerivable fc [] (PlusFormula.allFuture φ) :=
  h.elim fun d hn => ⟨.temporal_necessitation φ d, hn⟩

/-- Temporal duality in the naive system. -/
theorem naiveTDual {φ : PlusFormula} (h : NaiveDerivable fc [] φ) :
    NaiveDerivable fc [] φ.swapTemporal :=
  h.elim fun d hn => ⟨.temporal_duality φ d, hn⟩

/-- **`⊡`-necessitation is derived in the naive system too**: `MS` (`box_stab`) is naive, so the
route through `necessitation` survives the restriction. -/
theorem naiveStabNec {φ : PlusFormula} (h : NaiveDerivable fc [] φ) :
    NaiveDerivable fc [] (PlusFormula.stab φ) :=
  naiveMp (naiveAx (PlusAxiom.box_stab φ) trivial (FrameClass.base_le fc)) (naiveNec h)

end FormalSystem.Metalogic.Independence
