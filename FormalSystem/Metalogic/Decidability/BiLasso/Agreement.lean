/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.Orbit

/-!
# Window Agreement: What a Lasso Certificate Does and Does Not License

A placed bi-lasso decodes to a total world history, and if it agrees with a bounded partial
history on that history's own domain then it **extends** it in the paper's sense. That is the
theorem in this module, and it is what a model checker cites when it reports that a bounded
observation really is a fragment of a possible world.

Because that is a useful thing to cite, it is also an easy thing to over-cite. **Read the three
limits below before reading the theorem.** They are stated first deliberately: each one names a
specific way that agreement on a window fails to transfer, and each cites a declaration rather
than asserting in prose.

## Limit 1 — for `box φ`, window agreement is the wrong instrument entirely

Not "insufficient" — *the wrong kind of thing*. `TruthAt`'s box clause quantifies over **all** of
`H_F`, not over the constructed history, and `FormalSystem.Semantics.Truth.box_const` proves that
a boxed formula's truth value is independent of the history; its specialisation
`FormalSystem.Semantics.Truth.box_time_const` proves it is independent of the time as well. So the
box facts of a model are a property of the *model*, computed once, and no window certificate about
any particular history bears on them at all. A design that reaches for a window certificate to
settle a box claim has not merely brought too little evidence; it has brought evidence about the
wrong object.

## Limit 2 — `Past φ` and `Future φ` do not transfer

The `untl` and `snce` clauses of `TruthAt` quantify over all `s : D`, unrestricted by any window.
Agreement on `dom τ` therefore says nothing whatever about truth at times outside `dom τ`, and
`Past` / `Future` are exactly the connectives that look there. A certificate that pins a history
on `[a, b]` leaves every temporal claim reaching outside `[a, b]` completely open.

## Limit 3 — no scan bound is computable from the lasso, and path periodicity is not truth periodicity

The declaration `no_formula_independent_scan_bound` exhibits, for **every** integer `N`, a formula
whose earliest witness after `t = -1` lies beyond `N` — on **one fixed** bi-lasso, with
`|back| = 1`, `|mid| = 0`, `|fwd| = 1`. Only the formula moves; the lasso does not. Since `N`
ranges over every quantity computable from the segment lengths and the time, no scan bound that is
a function of the lasso alone can be correct.

**The corollary nobody may skip**: the fact that the constructed history is eventually periodic
with period `p₁` does **not** license the claim that the truth of `φ` along it is eventually
periodic with period `p₁`. It is not. Path periodicity and truth periodicity are different
properties, and this module establishes only the first.

## The misuse to foreclose by name

`extends_of_agrees` and `extend_periodic_extends` license **existential** claims about the window
that was found: *this* bounded history really is a fragment of *some* possible world. They license
**nothing whatever** about universal obligations — nothing about what must hold at every history,
which is what validity quantifies over. In particular, a design that drops abundance wholesale and
cites the Extension Theorem as cover is wrong, and citing the effective version here instead does
not make it less wrong; the effective version is strictly weaker in scope, not stronger.

## Main Results

- `PlacedBiLasso.extends_of_agrees` — pointwise agreement on `dom τ` is exactly `Extends`
- `IntPresentation.extend_periodic_extends` — the Deliverable-3 statement: every bounded partial
  history over a contiguous integer domain is extended by a finitely represented, doubly
  ultimately-periodic possible world
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Semantics

namespace PlacedBiLasso

variable {P : IntPresentation}

/--
**Agreement is extension.** A placed bi-lasso whose decoding matches `τ` at every time in `τ`'s
domain extends `τ` in the paper's sense.

Domain inclusion is free: the decoded history is total, so `dom τ ⊆ ℤ` holds for any `τ`
whatsoever. All the content is in state agreement, and that comes straight from the fidelity
lemma of the construction.
-/
theorem extends_of_agrees (L : PlacedBiLasso P) (τ : PartialHistory P.toTaskFrame)
    (h : ∀ (t : ℤ) (ht : τ.domain t), L.unroll t = τ.states t ht) :
    PartialHistory.Extends L.toHF.val.toPartialHistory τ where
  subset := fun _ _ => trivial
  agree := fun t ht => h t ht

end PlacedBiLasso

namespace IntPresentation

/--
**Deliverable 3: every bounded history over a presented frame is a fragment of a finitely
represented possible world.**

Given a partial history whose domain is exactly the integer interval `[a, b]`, there is a placed
bi-lasso — three finite lists plus an integer origin — whose decoded total history **extends** it,
and which is ultimately periodic in both directions with both periods bounded by `P.card`.

Read the three limits in this module's docstring before citing this. In particular this licenses
an existential claim about the given window and licenses nothing about universal obligations.
-/
theorem extend_periodic_extends (P : IntPresentation)
    (τ : PartialHistory P.toTaskFrame) (a b : ℤ) (hab : a ≤ b)
    (hdom : ∀ t : ℤ, τ.domain t ↔ a ≤ t ∧ t ≤ b) :
    ∃ L : PlacedBiLasso P,
      PartialHistory.Extends L.toHF.val.toPartialHistory τ ∧
      0 < L.lasso.back.length ∧ L.lasso.back.length ≤ P.card ∧
      0 < L.lasso.fwd.length ∧ L.lasso.fwd.length ≤ P.card ∧
      (∀ t : ℤ, t < L.origin → L.unroll (t - (L.lasso.back.length : ℤ)) = L.unroll t) ∧
      (∀ t : ℤ, L.origin + (L.lasso.mid.length : ℤ) ≤ t →
        L.unroll (t + (L.lasso.fwd.length : ℤ)) = L.unroll t) := by
  obtain ⟨L, _hpath, hagree, h1, h2, h3, h4, h5, h6⟩ :=
    P.extend_periodic_of_icc τ a b hab hdom
  exact ⟨L, L.extends_of_agrees τ hagree, h1, h2, h3, h4, h5, h6⟩

end IntPresentation

/-!
## Why this is a certificate and not merely an assurance

The distinguishing property of the object produced above is that a consumer can *check* it without
re-running any of the reasoning that produced it. Two decidability facts carry that weight:

- `BiLasso.coherent` — the property that makes three arbitrary lists a genuine walk in the
  adjacency matrix — is a quantifier over a `Fin`, so `Fintype.decidableForallFintype` decides it,
  and `BiLasso.flipBiLasso` in `BiLasso/Basic.lean` discharges its own by `decide`.
- Pointwise agreement between a decoding and a finite window is likewise decidable, since it is a
  bounded quantifier over `ℕ` into a type with decidable equality.

The `example` below is the second of those, stated so that the claim is elaborated rather than
asserted. Note what it does *not* say: deciding agreement on the window is not deciding anything
about truth of formulas along the decoded path, for the three reasons given at the top of this
module.
-/

section Decidability

example (P : IntPresentation) (L : PlacedBiLasso P) (win : List (Fin P.card)) (origin : ℤ) :
    Decidable (∀ k : ℕ, k < win.length → L.unroll (origin + (k : ℤ)) = win.getD k default) :=
  inferInstance

end Decidability

end FormalSystem.Metalogic.Decidability
