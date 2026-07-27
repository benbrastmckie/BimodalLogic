/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEAConjFull
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.ConcatPin

/-!
# The two missing `VVecEA2` combinators: `conjEverywhere` and `concatPin`

The `VBracketFormula` layer already carries a full combinator kit. The `VVecEA2` layer — the
same disjunctive normal form, but with the two **endpoint predicates** `endpointLeft(z₀)` and
`endpointRight(z₁)` retained alongside the interval bracket — carries all of that kit except
these two. This module closes exactly that gap; nothing else at this layer is rebuilt here.

Already present at the `VVecEA2` layer and **reused, not reimplemented**: `disj`/`disj_holds`
(`VecEAFormula.lean:288`/`:292`), `conjFull`/`conjFull_iff` (`VecEAConjFull.lean:498`/`:510`),
`trivialTrue` (`VecEAConjFull.lean:549`), `enrichEndpoints`
(`NfMultiAnchorBridge/ExteriorBracket.lean:652`), `disjList`
(`NfMultiAnchorBridge/NavigatedSpine.lean:149`), `singleton`
(`NfMultiAnchorBridge/CarrierK1V.lean:2150`), `conjStruct` (`VecEAClosure.lean:222`), and
`prependAllVec` (`Lemma53Faithful.lean:100`).

## Source correspondence

Cite Rabinovich by **PDF page only**:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
The companion `.md` conversion is corrupt and is never ground truth.

* **PDF p.6**, Propositions 4.2 and 4.3: the `∨∃⃗∀` fragment is closed under conjunction,
  disjunction and existential quantification. `conjEverywhere` is the conjunction-closure
  operation in the shape the negation recursion actually consumes it — conjoin a single
  segment type into *every* interior position of a disjunctive form.
* **PDF p.9**, Corollary 5.4 and the Case 3 of the Lemma 5.1 proof: the negation of a bracket on
  `(z₀,z₁)` is assembled from forms on `(z₀,r)` and `(r,z₁)` glued at a pinned point
  `x ∈ (z₀,z₁)` with `¬β₁(x)`. `concatPin` is that gluing.

## Why the `VVecEA2` versions are needed at all (the design point)

`VBracketFormula.conjEverywhere` (`EANegationFix/NegFix.lean:78`) and
`VBracketFormula.concatPin` (`EANegationFix/ConcatPin.lean:97`) operate on a form with **no
endpoint predicates**. At the `VVecEA2` layer the endpoints are real data, and the pin point is
precisely where the left form's *right* endpoint and the right form's *left* endpoint both live:
they are two assertions about the same carrier element `r`.

`VecEA2.concatPin` therefore carries them **through** the pin, conjoining them into the pinned
point type as `(endpointRight_L ∧ pin) ∧ endpointLeft_R`. A version that discarded them would
compile and would be sorry-free, and would still be the **wrong object**: it would assert
strictly less than the conjunction of its two arguments, and the `_holds_iff` biconditional
below would be unprovable in the backward direction. That carrying is the entire reason a
`VVecEA2`-level `concatPin` is needed rather than a reuse of the `VBracketFormula` one.

## Carrier neutrality (non-vacuity statement)

**This module is carrier-neutral.** It lands no carrier hypothesis, weakens none, and mentions
none: `HasDedekindINF`, `HasDedekindSUP`, `HasDefinableINF`/`SUP` and `HasAttainedINF`/`SUP` do
not appear in any statement below, and no declaration here takes any hypothesis about the
ordered structure `M` beyond `OrderedMonadicStructure sig` itself. Nothing in this module can
make a downstream carrier claim easier or harder to discharge.

The non-vacuity obligation is discharged instead by **biconditionality**. Each `_holds_iff`
below is an `↔`, not a one-directional `→`. This matters: a one-directional
`(combinator).holds → (spec)` would be satisfiable by a combinator whose output is unsatisfiable
(`False → anything`), and a one-directional `(spec) → (combinator).holds` would be satisfiable
by a combinator whose output is trivially true. Only the biconditional pins the constructed form
to its intended meaning in both directions, which is what makes the constructions below usable
as *definitions of a normal form* rather than as one-way approximations. Concretely, the
backward direction of `VecEA2.concatPin_holds_iff` is the direction that forces the pin to carry
both endpoint predicates, and the forward direction of `VecEA2.conjEverywhere_holds_iff` is the
direction that forces `s` to reach every interior point rather than only the segment types.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## `conjEverywhere` at the `VecEA2` / `VVecEA2` layer (PDF p.6)

Mirrors `BracketFormula.conjEverywhere` (`VecEAConjFull.lean:234`) and
`VBracketFormula.conjEverywhere` (`EANegationFix/NegFix.lean:78`) one layer up. -/

/-- Conjoin a segment type `s` into every interior position of a `VecEA2`, via
    `BracketFormula.conjEverywhere` on its bracket. The endpoint predicates are **not** touched:
    `s` is asserted on the *open* interval `(z₀,z₁)`, which excludes the endpoints.

    Source correspondence: PDF p.6, Prop 4.2/4.3 (closure of the `∨∃⃗∀` fragment under
    conjunction). -/
def VecEA2.conjEverywhere {n : Nat} (vea : VecEA2 n) (s : TemporalPred) : VecEA2 n :=
  { endpointLeft := vea.endpointLeft
    endpointRight := vea.endpointRight
    bracket := vea.bracket.conjEverywhere s }

/-- Semantics of `VecEA2.conjEverywhere`: the original form holds **and** `s` holds at every
    interior point. A **biconditional** — see the carrier-neutrality note in the module
    docstring for why the one-directional forms would be worthless here. -/
theorem VecEA2.conjEverywhere_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {n : Nat} (vea : VecEA2 n) (s : TemporalPred) (z0 z1 : M.carrier) :
    (vea.conjEverywhere s).holds M atomMap z0 z1 ↔
    vea.holds M atomMap z0 z1 ∧
      ∀ y : M.carrier, z0 < y → y < z1 → s.EvalAt M atomMap y := by
  simp only [holds, conjEverywhere, BracketFormula.conjEverywhere_holds_iff]
  tauto

/-- Conjoin a segment type into every disjunct of a `VVecEA2`, via `VecEA2.conjEverywhere`.
    Structural mirror of `VBracketFormula.conjEverywhere` (`EANegationFix/NegFix.lean:78`). -/
def VVecEA2.conjEverywhere (v : VVecEA2) (s : TemporalPred) : VVecEA2 :=
  ⟨v.disjuncts.map fun d => ⟨d.1, d.2.conjEverywhere s⟩⟩

/-- Semantics of the `VVecEA2`-level `conjEverywhere`: the disjunctive form holds and `s` holds
    at every interior point. Proved by the same disjunct-chase as
    `VBracketFormula.conjEverywhere_holds_iff` (`EANegationFix/NegFix.lean:84`). -/
theorem VVecEA2.conjEverywhere_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) (s : TemporalPred) (z0 z1 : M.carrier) :
    (v.conjEverywhere s).holds M atomMap z0 z1 ↔
    v.holds M atomMap z0 z1 ∧
      ∀ y : M.carrier, z0 < y → y < z1 → s.EvalAt M atomMap y := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [conjEverywhere, List.mem_map] at hmem
    obtain ⟨d', hd', rfl⟩ := hmem
    rw [VecEA2.conjEverywhere_holds_iff] at hh
    exact ⟨⟨d', hd', hh.1⟩, hh.2⟩
  · rintro ⟨⟨d, hd, hh⟩, hs⟩
    refine ⟨⟨d.1, d.2.conjEverywhere s⟩, ?_, ?_⟩
    · simp only [conjEverywhere, List.mem_map]
      exact ⟨d, hd, rfl⟩
    · rw [VecEA2.conjEverywhere_holds_iff]
      exact ⟨hh, hs⟩

/-! ## `concatPin` at the `VecEA2` / `VVecEA2` layer (PDF p.9)

Mirrors `BracketFormula.concatPin` (`EANegationFix/ConcatPin.lean:66`) and
`VBracketFormula.concatPin` (`EANegationFix/ConcatPin.lean:97`) one layer up, with the endpoint
predicates carried through the pin point rather than discarded. -/

/-- Pinned concatenation of two `VecEA2` forms: `veaL` on `(z₀,r)`, the pin at `r`, `veaR` on
    `(r,z₁)`.

    The pinned point type is `(veaL.endpointRight ∧ pin) ∧ veaR.endpointLeft`. Both endpoint
    predicates are assertions about the *same* carrier element `r` — `veaL`'s right endpoint and
    `veaR`'s left endpoint coincide there — so they are conjoined into the pin rather than
    dropped. The surviving endpoints of the result are `veaL`'s left (at `z₀`) and `veaR`'s
    right (at `z₁`).

    Source correspondence: PDF p.9, Case 3 of the Lemma 5.1 proof (a pinned `x ∈ (z₀,z₁)` with
    `¬β₁(x)` splitting the interval) and Corollary 5.4. -/
def VecEA2.concatPin {nL nR : Nat} (veaL : VecEA2 nL) (pin : TemporalPred)
    (veaR : VecEA2 nR) :
    VecEA2 (veaL.bracket.foldPairs ++
      ((veaL.endpointRight.conj pin).conj veaR.endpointLeft,
        veaR.bracket.segmentTypes ⟨0, Nat.succ_pos nR⟩) :: veaR.bracket.foldPairs).length :=
  { endpointLeft := veaL.endpointLeft
    endpointRight := veaR.endpointRight
    bracket := veaL.bracket.concatPin
      ((veaL.endpointRight.conj pin).conj veaR.endpointLeft) veaR.bracket }

/-- Semantics of the `VecEA2`-level pinned concatenation: some `r ∈ (z₀,z₁)` carries the pin,
    with `veaL` holding on `(z₀,r)` **including its right endpoint predicate at `r`** and `veaR`
    holding on `(r,z₁)` **including its left endpoint predicate at `r`**.

    This is the **biconditional** that fails for a `concatPin` that drops the endpoints: its
    `mpr` direction is exactly what consumes `veaL.endpointRight` and `veaR.endpointLeft` at
    `r`, and there is nowhere for them to come from unless the pin carries them. -/
theorem VecEA2.concatPin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {nL nR : Nat} (veaL : VecEA2 nL) (pin : TemporalPred) (veaR : VecEA2 nR)
    (z0 z1 : M.carrier) :
    (veaL.concatPin pin veaR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      veaL.holds M atomMap z0 r ∧ pin.EvalAt M atomMap r ∧
      veaR.holds M atomMap r z1 := by
  simp only [holds, concatPin]
  constructor
  · rintro ⟨hEL, hER, hbr⟩
    obtain ⟨r, h1, h2, hbL, hpt, hbR⟩ :=
      (BracketFormula.concatPin_holds_iff M atomMap veaL.bracket _ veaR.bracket z0 z1).mp hbr
    rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj] at hpt
    exact ⟨r, h1, h2, ⟨hEL, hpt.1.1, hbL⟩, hpt.1.2, ⟨hpt.2, hER, hbR⟩⟩
  · rintro ⟨r, h1, h2, ⟨hEL, hLR, hbL⟩, hpin, ⟨hRL, hER, hbR⟩⟩
    refine ⟨hEL, hER, ?_⟩
    refine (BracketFormula.concatPin_holds_iff M atomMap veaL.bracket _ veaR.bracket
      z0 z1).mpr ⟨r, h1, h2, hbL, ?_, hbR⟩
    exact (TemporalPred.eval_at_conj M atomMap _ _ r).mpr
      ⟨(TemporalPred.eval_at_conj M atomMap _ _ r).mpr ⟨hLR, hpin⟩, hRL⟩

/-- Pinned concatenation of two `VVecEA2` forms: every pair of disjuncts joined around the pin.
    Structural mirror of `VBracketFormula.concatPin` (`EANegationFix/ConcatPin.lean:97`); the
    endpoint carrying happens inside `VecEA2.concatPin`. -/
def VVecEA2.concatPin (VL : VVecEA2) (pin : TemporalPred) (VR : VVecEA2) : VVecEA2 :=
  ⟨VL.disjuncts.flatMap fun dL =>
    VR.disjuncts.map fun dR => ⟨_, dL.2.concatPin pin dR.2⟩⟩

/-- Semantics of the `VVecEA2`-level pinned concatenation: the `∃ r` and the fixed pin distribute
    over both disjunction lists. Same disjunct-chase as
    `VBracketFormula.concatPin_holds_iff` (`EANegationFix/ConcatPin.lean:104`). -/
theorem VVecEA2.concatPin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (VL : VVecEA2) (pin : TemporalPred) (VR : VVecEA2) (z0 z1 : M.carrier) :
    (VL.concatPin pin VR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      VL.holds M atomMap z0 r ∧ pin.EvalAt M atomMap r ∧
      VR.holds M atomMap r z1 := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [concatPin, List.mem_flatMap, List.mem_map] at hmem
    obtain ⟨dL, hdL, dR, hdR, rfl⟩ := hmem
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      (VecEA2.concatPin_holds_iff M atomMap dL.2 pin dR.2 z0 z1).mp hh
    exact ⟨r, h1, h2, ⟨dL, hdL, h3⟩, h4, ⟨dR, hdR, h5⟩⟩
  · rintro ⟨r, h1, h2, ⟨dL, hdL, h3⟩, h4, ⟨dR, hdR, h5⟩⟩
    refine ⟨⟨_, dL.2.concatPin pin dR.2⟩, ?_, ?_⟩
    · simp only [concatPin, List.mem_flatMap, List.mem_map]
      exact ⟨dL, hdL, dR, hdR, rfl⟩
    · exact (VecEA2.concatPin_holds_iff M atomMap dL.2 pin dR.2 z0 z1).mpr
        ⟨r, h1, h2, h3, h4, h5⟩

end FormalSystem.Metalogic.WeakCanonical.Kamp
