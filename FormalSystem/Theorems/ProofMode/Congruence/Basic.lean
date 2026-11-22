/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Init

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
-/

namespace FormalSystem.Theorems.ProofMode.Congruence

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

end FormalSystem.Theorems.ProofMode.Congruence
