/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.PlusDiscrete

/-!
# Native positional congruence kernel

A position inside a formula is described by a `Step`: the constructor context `wrap` it
plugs into, the scope `demand` under which a rewrite at that position must hold, and whether
the position is antitone (`flips`). Each step carries a **closed formula** theorem

```text
demand (A → B) → (wrap A → wrap B)          -- flips = false
demand (A → B) → (wrap B → wrap A)          -- flips = true
```

and closed monotonicity of its demand. `Step.comp` composes positions outermost first; the
composite demand is the nested demand and the composite polarity is the exclusive or of the
polarities. Composition uses only the kit's implication transitivity and the outer demand's
monotonicity, so it works uniformly for every polarity pair.

Concrete steps exist for TM (`DerivationTree fc []`) and TM⁺ (`PlusDerivationTree fc []`).
Every primitive TM transfer is an existing closed source schema. TM⁺ transfers are those TM
schemata carried by `PlusDerivationTree.ofTMSubst` at atoms, so they hold at arbitrary TM⁺
arguments including ones containing `⊡`; the stability step is native. Demand monotonicity is
constructed natively in each language from closed necessitation and the relevant K schema.
Next/Previous demand monotonicity uses G/H necessitation with Until/Since event monotonicity at
guard `⊥`, so it holds at every frame class without asserting that an adjacent time exists.

No semantics, completeness, or `Nonempty` extraction is used.
-/

namespace FormalSystem.Theorems.ProofMode.Congruence

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

/-! ## Generic kernel -/

/-- Closed implication structure needed to compose positional transfers: an implication
connective with closed reflexivity and transitivity of its theorems. -/
structure Kit (L : Type) (P : L → Type) where
  /-- The object-language implication. -/
  imp : L → L → L
  /-- Closed reflexivity `⊢ A → A`. -/
  refl : ∀ A, P (imp A A)
  /-- Closed transitivity: from `⊢ A → B` and `⊢ B → C`, conclude `⊢ A → C`. -/
  trans : ∀ {A B C}, P (imp A B) → P (imp B C) → P (imp A C)

/-- One formula position: its constructor context, scope demand and polarity, with the closed
transfer theorem and closed monotonicity of the demand. -/
structure Step {L : Type} {P : L → Type} (kit : Kit L P) where
  /-- Plug a formula into this position. -/
  wrap : L → L
  /-- Scope under which a replacement at this position must hold. -/
  demand : L → L
  /-- Whether the position is antitone (an implication antecedent). -/
  flips : Bool
  /-- Closed transfer of a demanded implication to the wrapped formulas, oriented by `flips`. -/
  transfer : ∀ A B, P (kit.imp (demand (kit.imp A B))
    (if flips then kit.imp (wrap B) (wrap A) else kit.imp (wrap A) (wrap B)))
  /-- The demand is monotone under closed implication. -/
  demandMono : ∀ {A B}, P (kit.imp A B) → P (kit.imp (demand A) (demand B))

namespace Step

variable {L : Type} {P : L → Type} {kit : Kit L P}

/-- The empty path: identity wrap and demand, no polarity flip. -/
def identity (kit : Kit L P) : Step kit where
  wrap x := x
  demand x := x
  flips := false
  transfer A B := kit.refl (kit.imp A B)
  demandMono h := h

/-- Distribution and closed monotonicity determine a positive necessity position. -/
def necessity (box : L → L)
    (distribution : ∀ A B, P (kit.imp (box (kit.imp A B)) (kit.imp (box A) (box B))))
    (mono : ∀ {A B}, P (kit.imp A B) → P (kit.imp (box A) (box B))) : Step kit where
  wrap := box
  demand := box
  flips := false
  transfer := distribution
  demandMono := mono

/-- Transfer of a composite position. The inner transfer is lifted through the outer demand and
composed with the outer transfer, at swapped arguments when the inner position flips. -/
private def compTransfer (outer inner : Step kit) (A B : L) :
    P (kit.imp (outer.demand (inner.demand (kit.imp A B)))
      (if (outer.flips ^^ inner.flips) then
        kit.imp (outer.wrap (inner.wrap B)) (outer.wrap (inner.wrap A))
      else kit.imp (outer.wrap (inner.wrap A)) (outer.wrap (inner.wrap B)))) := by
  have hInner := outer.demandMono (inner.transfer A B)
  have hFwd := outer.transfer (inner.wrap A) (inner.wrap B)
  have hRev := outer.transfer (inner.wrap B) (inner.wrap A)
  revert hInner hFwd hRev
  cases outer.flips <;> cases inner.flips <;> intro hInner hFwd hRev
  · exact kit.trans hInner hFwd
  · exact kit.trans hInner hRev
  · exact kit.trans hInner hFwd
  · exact kit.trans hInner hRev

/-- Compose an outer position with an inner one. Demands nest outermost first, polarities
combine by exclusive or, and demand monotonicity is the nested monotonicity function. -/
def comp (outer inner : Step kit) : Step kit where
  wrap x := outer.wrap (inner.wrap x)
  demand x := outer.demand (inner.demand x)
  flips := outer.flips ^^ inner.flips
  transfer := compTransfer outer inner
  demandMono h := outer.demandMono (inner.demandMono h)

end Step

/-! ## TM -/

section TM

variable (fc : FrameClass)

/-- Closed TM implication kit at frame class `fc`. -/
def tmKit : Kit Formula (DerivationTree fc []) where
  imp := Formula.imp
  refl A := Combinators.identity A
  trans h₁ h₂ := Combinators.impTrans h₁ h₂

variable {fc}

private def tmMp {A B : Formula} (hAB : DerivationTree fc [] (A.imp B))
    (hA : DerivationTree fc [] A) : DerivationTree fc [] B :=
  .modus_ponens [] A B hAB hA

private def tmBoxMono {A B : Formula} (h : DerivationTree fc [] (A.imp B)) :
    DerivationTree fc [] (A.box.imp B.box) :=
  tmMp (.axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)) (.necessitation _ h)

private def tmFutureMono {A B : Formula} (h : DerivationTree fc [] (A.imp B)) :
    DerivationTree fc [] (A.allFuture.imp B.allFuture) :=
  tmMp (TemporalDerived.gDistribution A B) (.temporal_necessitation _ h)

private def tmPastMono {A B : Formula} (h : DerivationTree fc [] (A.imp B)) :
    DerivationTree fc [] (A.allPast.imp B.allPast) :=
  tmMp (TemporalDerived.hDistribution A B) (pastNecessitation _ h)

/-- `⊢ (A → B) → ((B → C) → (A → C))`, the flipped composition combinator. -/
private def tmImpLeftSchema (A B C : Formula) :
    DerivationTree fc [] ((A.imp B).imp ((B.imp C).imp (A.imp C))) :=
  Combinators.mp Combinators.bCombinator Combinators.theoremFlip

/-- Implication antecedent `x ↦ x → C`, antitone with identity demand. -/
def tmImpLeft (C : Formula) : Step (tmKit fc) where
  wrap x := x.imp C
  demand x := x
  flips := true
  transfer A B := tmImpLeftSchema A B C
  demandMono h := h

/-- Implication consequent `x ↦ C → x`, monotone with identity demand. -/
def tmImpRight (C : Formula) : Step (tmKit fc) where
  wrap x := C.imp x
  demand x := x
  flips := false
  transfer _ _ := Combinators.bCombinator
  demandMono h := h

/-- Modal body `x ↦ □x`, demand `□`, by modal K. -/
def tmBox : Step (tmKit fc) :=
  Step.necessity Formula.box
    (fun A B => .axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)) tmBoxMono

/-- Strict future body `x ↦ Gx`, demand `G`, by `gDistribution`. -/
def tmFuture : Step (tmKit fc) where
  wrap := Formula.allFuture
  demand := Formula.allFuture
  flips := false
  transfer := TemporalDerived.gDistribution
  demandMono := tmFutureMono

/-- Strict past body `x ↦ Hx`, demand `H`, by `hDistribution`. -/
def tmPast : Step (tmKit fc) where
  wrap := Formula.allPast
  demand := Formula.allPast
  flips := false
  transfer := TemporalDerived.hDistribution
  demandMono := tmPastMono

/-- Until guard `x ↦ x U e` at fixed event `e`, demand `G`, by `untilMonoGuard`. -/
def tmUntilGuard (event : Formula) : Step (tmKit fc) where
  wrap x := Formula.untl x event
  demand := Formula.allFuture
  flips := false
  transfer A B := TemporalDerived.untilMonoGuard A B event
  demandMono := tmFutureMono

/-- Until event `x ↦ g U x` at fixed guard `g`, demand `G`, by `untilMonoEvent`. -/
def tmUntilEvent (guard : Formula) : Step (tmKit fc) where
  wrap x := Formula.untl guard x
  demand := Formula.allFuture
  flips := false
  transfer A B := TemporalDerived.untilMonoEvent A B guard
  demandMono := tmFutureMono

/-- Since guard `x ↦ x S e` at fixed event `e`, demand `H`, by `sinceMonoGuard`. -/
def tmSinceGuard (event : Formula) : Step (tmKit fc) where
  wrap x := Formula.snce x event
  demand := Formula.allPast
  flips := false
  transfer A B := TemporalDerived.sinceMonoGuard A B event
  demandMono := tmPastMono

/-- Since event `x ↦ g S x` at fixed guard `g`, demand `H`, by `sinceMonoEvent`. -/
def tmSinceEvent (guard : Formula) : Step (tmKit fc) where
  wrap x := Formula.snce guard x
  demand := Formula.allPast
  flips := false
  transfer A B := TemporalDerived.sinceMonoEvent A B guard
  demandMono := tmPastMono

/-- Next event `x ↦ Xx` with the conditional demand `X`, by closed `nextK`. Demand
monotonicity uses G-necessitation and event monotonicity at guard `⊥`, so it needs no
adjacent-time existence and holds at every frame class. -/
def tmNext : Step (tmKit fc) where
  wrap := Formula.next
  demand := Formula.next
  flips := false
  transfer := ProofMode.nextK
  demandMono {A B} h :=
    tmMp (TemporalDerived.untilMonoEvent A B .bot) (.temporal_necessitation _ h)

/-- Previous event `x ↦ Yx` with the conditional demand `Y`, by closed `prevK`. Demand
monotonicity uses H-necessitation and Since event monotonicity at guard `⊥`. -/
def tmPrev : Step (tmKit fc) where
  wrap := Formula.prev
  demand := Formula.prev
  flips := false
  transfer := ProofMode.prevK
  demandMono {A B} h :=
    tmMp (TemporalDerived.sinceMonoEvent A B .bot) (pastNecessitation _ h)

/-- Next event `x ↦ Xx` with demand `G`, by `untilMonoEvent` at guard `⊥`. -/
def tmNextFuture : Step (tmKit fc) where
  wrap := Formula.next
  demand := Formula.allFuture
  flips := false
  transfer A B := TemporalDerived.untilMonoEvent A B .bot
  demandMono := tmFutureMono

/-- Previous event `x ↦ Yx` with demand `H`, by `sinceMonoEvent` at guard `⊥`. -/
def tmPrevPast : Step (tmKit fc) where
  wrap := Formula.prev
  demand := Formula.allPast
  flips := false
  transfer A B := TemporalDerived.sinceMonoEvent A B .bot
  demandMono := tmPastMono

end TM

/-! ## TM⁺

Transfers instantiate the TM source schema at fresh atoms and substitute the TM⁺ arguments.
Each `transfer` field's expected type checks that substitution against the intended TM⁺ wrap
and demand definitionally. -/

section Plus

variable (fc : FrameClass)

private def plusImpTrans {A B C : PlusFormula}
    (h₁ : PlusDerivationTree fc [] (A.imp B)) (h₂ : PlusDerivationTree fc [] (B.imp C)) :
    PlusDerivationTree fc [] (A.imp C) :=
  .modus_ponens [] _ _
    (.modus_ponens [] _ _ (.axiom [] _ (.prop_k A B C) (FrameClass.base_le fc))
      (.modus_ponens [] _ _ (.axiom [] _ (.prop_s (B.imp C) A) (FrameClass.base_le fc)) h₂))
    h₁

/-- Closed TM⁺ implication kit at frame class `fc`. -/
def plusKit : Kit PlusFormula (PlusDerivationTree fc []) where
  imp := PlusFormula.imp
  refl := PlusLanguage.ProofMode.identity
  trans := plusImpTrans fc

variable {fc}

private def schemaAtom (n : Nat) : Formula := .atom (Atom.mkFresh "" n)

private def assign (A B C : PlusFormula) (p : Atom) : PlusFormula :=
  match p.freshIndex with
  | some 0 => A
  | some 1 => B
  | _ => C

private def plusMp {A B : PlusFormula} (hAB : PlusDerivationTree fc [] (A.imp B))
    (hA : PlusDerivationTree fc [] A) : PlusDerivationTree fc [] B :=
  .modus_ponens [] A B hAB hA

private def plusFutureMono {A B : PlusFormula} (h : PlusDerivationTree fc [] (A.imp B)) :
    PlusDerivationTree fc [] (A.allFuture.imp B.allFuture) :=
  plusMp (PlusLanguage.ProofMode.gDistribution A B) (.temporal_necessitation _ h)

private def plusPastMono {A B : PlusFormula} (h : PlusDerivationTree fc [] (A.imp B)) :
    PlusDerivationTree fc [] (A.allPast.imp B.allPast) :=
  plusMp (PlusLanguage.ProofMode.hDistribution A B)
    (PlusLanguage.ProofMode.pastNecessitation _ h)

private def plusUntilMonoGuard (A B e : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allFuture.imp ((PlusFormula.untl A e).imp
      (PlusFormula.untl B e))) :=
  .ofTMSubst (assign A B e)
    (TemporalDerived.untilMonoGuard (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))

private def plusUntilMonoEvent (A B g : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allFuture.imp ((PlusFormula.untl g A).imp
      (PlusFormula.untl g B))) :=
  .ofTMSubst (assign A B g)
    (TemporalDerived.untilMonoEvent (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))

private def plusSinceMonoGuard (A B e : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allPast.imp ((PlusFormula.snce A e).imp
      (PlusFormula.snce B e))) :=
  .ofTMSubst (assign A B e)
    (TemporalDerived.sinceMonoGuard (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))

private def plusSinceMonoEvent (A B g : PlusFormula) :
    PlusDerivationTree fc [] ((A.imp B).allPast.imp ((PlusFormula.snce g A).imp
      (PlusFormula.snce g B))) :=
  .ofTMSubst (assign A B g)
    (TemporalDerived.sinceMonoEvent (schemaAtom 0) (schemaAtom 1) (schemaAtom 2))

/-- Implication antecedent `x ↦ x → C`, antitone, from the transferred TM schema. -/
def plusImpLeft (C : PlusFormula) : Step (plusKit fc) where
  wrap x := x.imp C
  demand x := x
  flips := true
  transfer A B := .ofTMSubst (assign A B C) (tmImpLeftSchema (schemaAtom 0) (schemaAtom 1)
    (schemaAtom 2))
  demandMono h := h

/-- Implication consequent `x ↦ C → x`, monotone, from the transferred TM schema. -/
def plusImpRight (C : PlusFormula) : Step (plusKit fc) where
  wrap x := C.imp x
  demand x := x
  flips := false
  transfer A B := .ofTMSubst (assign A B C)
    (Combinators.bCombinator (A := schemaAtom 2) (B := schemaAtom 0) (C := schemaAtom 1))
  demandMono h := h

/-- Modal body `x ↦ □x`, demand `□`, from transferred modal K and native necessitation. -/
def plusBox : Step (plusKit fc) :=
  Step.necessity PlusFormula.box
    (fun A B => .axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc))
    (fun {A B} h =>
      plusMp (.axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)) (.necessitation _ h))

/-- Stability body with native distribution and necessitation. -/
def plusStability : Step (plusKit fc) :=
  Step.necessity PlusFormula.stab
    (fun A B => .axiom [] _ (.stab_k A B) (FrameClass.base_le fc))
    (fun {A B} h =>
      plusMp (.axiom [] _ (.stab_k A B) (FrameClass.base_le fc)) (stabNecessitation h))

/-- Strict future body `x ↦ Gx`, demand `G`, by transferred `gDistribution`. -/
def plusFuture : Step (plusKit fc) where
  wrap := PlusFormula.allFuture
  demand := PlusFormula.allFuture
  flips := false
  transfer := PlusLanguage.ProofMode.gDistribution
  demandMono := plusFutureMono

/-- Strict past body `x ↦ Hx`, demand `H`, by transferred `hDistribution`. -/
def plusPast : Step (plusKit fc) where
  wrap := PlusFormula.allPast
  demand := PlusFormula.allPast
  flips := false
  transfer := PlusLanguage.ProofMode.hDistribution
  demandMono := plusPastMono

/-- Until guard `x ↦ x U e` at fixed event `e`, demand `G`. -/
def plusUntilGuard (event : PlusFormula) : Step (plusKit fc) where
  wrap x := PlusFormula.untl x event
  demand := PlusFormula.allFuture
  flips := false
  transfer A B := plusUntilMonoGuard A B event
  demandMono := plusFutureMono

/-- Until event `x ↦ g U x` at fixed guard `g`, demand `G`. -/
def plusUntilEvent (guard : PlusFormula) : Step (plusKit fc) where
  wrap x := PlusFormula.untl guard x
  demand := PlusFormula.allFuture
  flips := false
  transfer A B := plusUntilMonoEvent A B guard
  demandMono := plusFutureMono

/-- Since guard `x ↦ x S e` at fixed event `e`, demand `H`. -/
def plusSinceGuard (event : PlusFormula) : Step (plusKit fc) where
  wrap x := PlusFormula.snce x event
  demand := PlusFormula.allPast
  flips := false
  transfer A B := plusSinceMonoGuard A B event
  demandMono := plusPastMono

/-- Since event `x ↦ g S x` at fixed guard `g`, demand `H`. -/
def plusSinceEvent (guard : PlusFormula) : Step (plusKit fc) where
  wrap x := PlusFormula.snce guard x
  demand := PlusFormula.allPast
  flips := false
  transfer A B := plusSinceMonoEvent A B guard
  demandMono := plusPastMono

/-- Next event with conditional demand `X`, by transferred `nextK`. Demand monotonicity uses
G-necessitation and event monotonicity at guard `⊥`, never closed Next necessitation. -/
def plusNext : Step (plusKit fc) where
  wrap := PlusFormula.next
  demand := PlusFormula.next
  flips := false
  transfer := PlusLanguage.ProofMode.nextK
  demandMono {A B} h := plusMp (plusUntilMonoEvent A B .bot) (.temporal_necessitation _ h)

/-- Previous event with conditional demand `Y`, by transferred `prevK`. Demand monotonicity
uses H-necessitation and Since event monotonicity at guard `⊥`. -/
def plusPrev : Step (plusKit fc) where
  wrap := PlusFormula.prev
  demand := PlusFormula.prev
  flips := false
  transfer := PlusLanguage.ProofMode.prevK
  demandMono {A B} h :=
    plusMp (plusSinceMonoEvent A B .bot) (PlusLanguage.ProofMode.pastNecessitation _ h)

/-- Next event with demand `G`, by transferred event monotonicity at guard `⊥`. -/
def plusNextFuture : Step (plusKit fc) where
  wrap := PlusFormula.next
  demand := PlusFormula.allFuture
  flips := false
  transfer A B := plusUntilMonoEvent A B .bot
  demandMono := plusFutureMono

/-- Previous event with demand `H`, by transferred Since event monotonicity at guard `⊥`. -/
def plusPrevPast : Step (plusKit fc) where
  wrap := PlusFormula.prev
  demand := PlusFormula.allPast
  flips := false
  transfer A B := plusSinceMonoEvent A B .bot
  demandMono := plusPastMono

end Plus

end FormalSystem.Theorems.ProofMode.Congruence
