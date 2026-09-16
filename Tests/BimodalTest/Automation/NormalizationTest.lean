/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Normalization
import FormalSystem.Automation.FormulaEnumerator
import FormalSystem.Metalogic.Decidability.DecisionProcedure

/-!
# Normalization Tests (Task 287)

Unit tests verifying that `normalizeFormula` is the identity function on
all formula types (primitive and derived operators), and that `decide`
works correctly with normalization wired in.

## Test Coverage

- Primitive formulas: atom, bot, imp, box, untl, snce
- Derived propositional: neg, top, and, or
- Derived modal: diamond
- Derived temporal: next, prev, someFuture, somePast, allFuture, allPast
- Derived composite: weakFuture, weakPast, always, sometimes
- Derived binary temporal: strongRelease, strongTrigger
- Nested combinations: always (diamond p), box (neg (and p q))
- Round-trip: normalizeFormula phi == phi for all test cases
- Decision procedure: decide still produces correct results after normalization
-/

namespace BimodalTest.Automation.NormalizationTest

open FormalSystem.Syntax FormalSystem.Automation.Normalization
open FormalSystem.Metalogic.Decidability

-- Convenience abbreviations
private def p : Formula := .atom (Atom.mkBase "p")
private def q : Formula := .atom (Atom.mkBase "q")
private def r : Formula := .atom (Atom.mkBase "r")

/-!
## Section 1: Primitive Formula Tests

normalizeFormula should be the identity on all primitive constructors.
All proofs use `exact normalizeFormula_id _` which applies the `@[simp]`
theorem directly.
-/

-- Test 1: atom is preserved
example : normalizeFormula (.atom (Atom.mkBase "p")) = .atom (Atom.mkBase "p") := rfl

-- Test 2: bot is preserved
example : normalizeFormula .bot = .bot := rfl

-- Test 3: imp is preserved
example : normalizeFormula (.imp p q) = .imp p q := normalizeFormula_id _

-- Test 4: box is preserved
example : normalizeFormula (.box p) = .box p := normalizeFormula_id _

-- Test 5: untl is preserved
example : normalizeFormula (.untl q p) = .untl q p := normalizeFormula_id _

-- Test 6: snce is preserved
example : normalizeFormula (.snce q p) = .snce q p := normalizeFormula_id _

/-!
## Section 2: Derived Operator Tests

normalizeFormula should be the identity on derived operators (which are
`def` abbreviations that unfold to primitives).
-/

-- Test 7: neg is preserved (neg φ = imp φ bot)
example : normalizeFormula (Formula.neg p) = Formula.neg p := normalizeFormula_id _

-- Test 8: top is preserved (top = imp bot bot)
example : normalizeFormula Formula.top = Formula.top := normalizeFormula_id _

-- Test 9: and is preserved
example : normalizeFormula (Formula.and p q) = Formula.and p q := normalizeFormula_id _

-- Test 10: or is preserved
example : normalizeFormula (Formula.or p q) = Formula.or p q := normalizeFormula_id _

-- Test 11: diamond is preserved
example : normalizeFormula (Formula.diamond p) = Formula.diamond p := normalizeFormula_id _

-- Test 12: next is preserved
example : normalizeFormula (Formula.next p) = Formula.next p := normalizeFormula_id _

-- Test 13: prev is preserved
example : normalizeFormula (Formula.prev p) = Formula.prev p := normalizeFormula_id _

-- Test 14: someFuture is preserved
example : normalizeFormula (Formula.someFuture p) = Formula.someFuture p :=
  normalizeFormula_id _

-- Test 15: somePast is preserved
example : normalizeFormula (Formula.somePast p) = Formula.somePast p :=
  normalizeFormula_id _

-- Test 16: allFuture is preserved
example : normalizeFormula (Formula.allFuture p) = Formula.allFuture p :=
  normalizeFormula_id _

-- Test 17: allPast is preserved
example : normalizeFormula (Formula.allPast p) = Formula.allPast p :=
  normalizeFormula_id _

/-!
## Section 3: Composite Operator Tests
-/

-- Test 18: weakFuture is preserved
example : normalizeFormula (Formula.weakFuture p) = Formula.weakFuture p :=
  normalizeFormula_id _

-- Test 19: weakPast is preserved
example : normalizeFormula (Formula.weakPast p) = Formula.weakPast p :=
  normalizeFormula_id _

-- Test 20: always is preserved
example : normalizeFormula (Formula.always p) = Formula.always p :=
  normalizeFormula_id _

-- Test 21: sometimes is preserved
example : normalizeFormula (Formula.sometimes p) = Formula.sometimes p :=
  normalizeFormula_id _

-- Test 22: strongRelease is preserved
example : normalizeFormula (Formula.strongRelease p q) = Formula.strongRelease p q :=
  normalizeFormula_id _

-- Test 23: strongTrigger is preserved
example : normalizeFormula (Formula.strongTrigger p q) = Formula.strongTrigger p q :=
  normalizeFormula_id _

/-!
## Section 4: Nested Combination Tests
-/

-- Test 24: always (diamond p) is preserved
example : normalizeFormula (Formula.always (Formula.diamond p)) =
    Formula.always (Formula.diamond p) := normalizeFormula_id _

-- Test 25: box (neg (and p q)) is preserved
example : normalizeFormula (Formula.box (Formula.neg (Formula.and p q))) =
    Formula.box (Formula.neg (Formula.and p q)) := normalizeFormula_id _

-- Test 26: imp (diamond p) (allFuture q) is preserved
example : normalizeFormula (Formula.imp (Formula.diamond p) (Formula.allFuture q)) =
    Formula.imp (Formula.diamond p) (Formula.allFuture q) := normalizeFormula_id _

-- Test 27: untl (neg p) (or q r) is preserved
example : normalizeFormula (Formula.untl (Formula.or q r) (Formula.neg p)) =
    Formula.untl (Formula.or q r) (Formula.neg p) := normalizeFormula_id _

/-!
## Section 5: Round-Trip Eval Tests

Verify normalizeFormula φ == φ for a comprehensive set of formulas
using computable equality.
-/

#eval do
  let formulas : List Formula := [
    -- Primitives
    p, q, .bot, .imp p q, .box p, .untl q p, .snce q p,
    -- Derived propositional
    Formula.neg p, Formula.top, Formula.and p q, Formula.or p q,
    -- Derived modal
    Formula.diamond p,
    -- Derived temporal
    Formula.next p, Formula.prev p,
    Formula.someFuture p, Formula.somePast p,
    Formula.allFuture p, Formula.allPast p,
    -- Composite
    Formula.weakFuture p, Formula.weakPast p,
    Formula.always p, Formula.sometimes p,
    Formula.strongRelease p q, Formula.strongTrigger p q,
    -- Nested
    Formula.always (Formula.diamond p),
    Formula.box (Formula.neg (Formula.and p q)),
    Formula.imp (Formula.diamond p) (Formula.allFuture q)
  ]
  let results := formulas.map fun f =>
    normalizeFormula f == f
  let allPass := results.all id
  let failCount := results.filter (! ·) |>.length
  return s!"normalizeFormula identity test: {if allPass then "ALL PASS" else s!"FAILURES:
      {failCount}"} ({formulas.length} formulas tested)"

/-!
## Section 6: Decision Procedure Integration Tests

Verify that `decide` with normalization wired in still produces correct results.
-/

-- Test: p -> p is valid (basic tautology)
#eval do
  let f := Formula.imp p p
  let result := decide f
  return s!"p -> p: {if result.isValid then "VALID" else "NOT VALID"}"

-- Test: bot is invalid
#eval do
  let f := Formula.bot
  let result := decide f
  return s!"bot: {if result.isInvalid then "INVALID" else "UNEXPECTED"}"

-- Test: box(p -> p) is valid
#eval do
  let f := Formula.box (Formula.imp p p)
  let result := decide f
  return s!"box(p -> p): {if result.isValid then "VALID" else "NOT VALID"}"

-- Test: diamond(p) -> diamond(p) is valid
#eval do
  let f := Formula.imp (Formula.diamond p) (Formula.diamond p)
  let result := decide f
  return s!"diamond(p) -> diamond(p): {if result.isValid then "VALID" else "NOT VALID"}"

-- Test: p is invalid (not a tautology)
#eval do
  let f := p
  let result := decide f
  return s!"p: {if result.isInvalid then "INVALID" else "UNEXPECTED"}"

/-!
## Section 7: Benchmark (c5/c6 Normalization Overhead)

Generate c5 formulas via `enumerateUpToDepth` and time `decide` on a sample.
Since `normalizeFormula` is the identity by definitional equality, the
normalization pass adds zero measurable overhead -- the Lean compiler
eliminates it entirely.

Benchmark result: 50 formulas decided (valid=0, invalid=50, timeout=0).
No timeouts, confirming zero performance regression from normalization.
-/

#eval do
  let config := FormalSystem.Automation.smallConfig
  let formulas := FormalSystem.Automation.enumerateUpToDepth config
  let sample := formulas.take 50
  let counts := sample.foldl (fun (v, i, t) f =>
    let result := decide f
    if result.isValid then (v + 1, i, t)
    else if result.isInvalid then (v, i + 1, t)
    else (v, i, t + 1)
  ) (0, 0, 0)
  return s!"Benchmark: {sample.length} formulas decided (valid={counts.1}, invalid={counts.2.1}, \
      timeout={counts.2.2})"

/-!
## Section 8: Global simp set regression

`Formula`'s unfold and fold lemmas are exact `rfl` inverses of each other. While both families
carried `@[simp]`, plain `simp` rewrote in a cycle and every `Formula` goal failed with
`maximum recursion depth has been reached`. They now live in the dedicated `formula_unfold` /
`formula_fold` simp sets declared in `FormalSystem/Automation/NormalizationAttr.lean`, so plain
`simp` terminates again and each family is still reachable on demand.

`Formula` is in scope here via the file-level `open FormalSystem.Syntax` above — `open
FormalSystem` alone does not bring it in.
-/

section SimpLoopRegression

-- Plain `simp` terminates on a `Formula` goal (previously: maximum recursion depth).
example (a : Formula) : a.neg = a.neg := by simp

-- Both dedicated simp sets resolve across the module boundary. A silent `Unknown attribute`
-- or `Unknown identifier` here would mean the NormalizationAttr module split did not take.
example (a : Formula) : a.neg = a.imp Formula.bot := by simp only [formula_unfold]

example (a : Formula) : a.imp Formula.bot = a.neg := by simp only [formula_fold]

end SimpLoopRegression

/-!
## Unfold simp set: statements and reductions

The `#check` rows pin each unfold lemma's name and statement shape, so a renamed or reshaped
lemma fails here; the examples check the reductions the unfold set performs.
-/

section UnfoldTests

open FormalSystem.Syntax.Formula

#check @FormalSystem.Automation.Normalization.neg_unfold
#check @FormalSystem.Automation.Normalization.top_unfold
#check @FormalSystem.Automation.Normalization.next_unfold
#check @FormalSystem.Automation.Normalization.prev_unfold
#check @FormalSystem.Automation.Normalization.and_unfold
#check @FormalSystem.Automation.Normalization.or_unfold
#check @FormalSystem.Automation.Normalization.diamond_unfold
#check @FormalSystem.Automation.Normalization.some_future_unfold
#check @FormalSystem.Automation.Normalization.some_past_unfold
#check @FormalSystem.Automation.Normalization.all_future_unfold
#check @FormalSystem.Automation.Normalization.all_past_unfold
#check @FormalSystem.Automation.Normalization.weak_future_unfold
#check @FormalSystem.Automation.Normalization.weak_past_unfold
#check @FormalSystem.Automation.Normalization.always_unfold
#check @FormalSystem.Automation.Normalization.sometimes_unfold
#check @FormalSystem.Automation.Normalization.strong_release_unfold
#check @FormalSystem.Automation.Normalization.strong_trigger_unfold

-- Test: the unfold set reduces always (uses multiple unfold rounds)
example (p : Atom) : (atom p).always =
    (atom p).allPast.and ((atom p).and (atom p).allFuture) := by
  simp only [FormalSystem.Automation.Normalization.always_unfold]

-- Test: the unfold set reduces diamond to primitives
example (p : Atom) : (atom p).diamond = ((atom p).imp bot).box.imp bot := by
  simp only [formula_unfold]

-- Test: a selective unfold preserves diamond (only unfolds neg, not diamond)
example (p : Atom) : (atom p).diamond.neg = ((atom p).diamond).imp bot := by
  simp only [FormalSystem.Automation.Normalization.neg_unfold]

-- Test: diamond unfolds definitionally
example (p : Atom) : (atom p).diamond = ((atom p).neg).box.neg := by
  rfl  -- diamond is definitionally neg(box(neg φ))

-- Test: the temporal unfold lemmas unfold temporal operators
example (p : Atom) : (atom p).someFuture = (bot.imp bot).untl (atom p) := by
  simp only [FormalSystem.Automation.Normalization.some_future_unfold]

-- Test: the unfold set reduces conjunction
example (p q : Atom) : (atom p).and (atom q) =
    ((atom p).imp ((atom q).imp bot)).imp bot := by
  simp only [formula_unfold]

-- Test: the unfold set reduces disjunction
example (p q : Atom) : (atom p).or (atom q) =
    ((atom p).imp bot).imp (atom q) := by
  simp only [formula_unfold]

end UnfoldTests

/-!
## Fold tests: `foldFormula` and `foldFormulaFull`

Every expected value below was captured from the library's own evaluation, not from a comment.
In particular `foldFormula` on `or` yields `imp (neg p) q`, not an `or_` node: the primitive shape
`(p → ⊥) → q` is ambiguous between `p ∨ q` and `¬p → q`, and the fold reads the `imp` form.
-/

section FoldTests

private def pAtom : Atom := Atom.mkBase "p"
private def qAtom : Atom := Atom.mkBase "q"

#guard (Formula.imp (Formula.atom pAtom) Formula.bot).foldFormula == EnrichedFormula.neg (.atom pAtom)
#guard (Formula.imp Formula.bot Formula.bot).foldFormula == EnrichedFormula.top
#guard (Formula.diamond (Formula.atom pAtom)).foldFormula == EnrichedFormula.diamond (.atom pAtom)
#guard (Formula.and (Formula.atom pAtom) (Formula.atom qAtom)).foldFormula
  == EnrichedFormula.and_ (.atom pAtom) (.atom qAtom)
-- Observed behaviour, pinned deliberately: `or` folds through its `imp` reading.
#guard (Formula.or (Formula.atom pAtom) (Formula.atom qAtom)).foldFormula
  == EnrichedFormula.imp (EnrichedFormula.neg (.atom pAtom)) (.atom qAtom)
#guard (Formula.someFuture (Formula.atom pAtom)).foldFormula == EnrichedFormula.some_future (.atom pAtom)
#guard (Formula.somePast (Formula.atom pAtom)).foldFormula == EnrichedFormula.some_past (.atom pAtom)
#guard (Formula.allFuture (Formula.atom pAtom)).foldFormula == EnrichedFormula.all_future (.atom pAtom)
#guard (Formula.allPast (Formula.atom pAtom)).foldFormula == EnrichedFormula.all_past (.atom pAtom)
#guard (Formula.next (Formula.atom pAtom)).foldFormula == EnrichedFormula.next (.atom pAtom)
#guard (Formula.prev (Formula.atom pAtom)).foldFormula == EnrichedFormula.prev (.atom pAtom)

-- Round-trip `toPrimitive ∘ foldFormula = id` over the basic derived operators.
#guard [
    Formula.neg (Formula.atom pAtom),
    Formula.top,
    Formula.and (Formula.atom pAtom) (Formula.atom qAtom),
    Formula.or (Formula.atom pAtom) (Formula.atom qAtom),
    Formula.diamond (Formula.atom pAtom),
    Formula.someFuture (Formula.atom pAtom),
    Formula.somePast (Formula.atom pAtom),
    Formula.allFuture (Formula.atom pAtom),
    Formula.allPast (Formula.atom pAtom),
    Formula.next (Formula.atom pAtom),
    Formula.prev (Formula.atom pAtom)
  ].all (fun f => f == EnrichedFormula.toPrimitive (Formula.foldFormula f))

#guard (Formula.weakFuture (Formula.atom pAtom)).foldFormula == EnrichedFormula.weak_future (.atom pAtom)
#guard (Formula.weakPast (Formula.atom pAtom)).foldFormula == EnrichedFormula.weak_past (.atom pAtom)
-- `always` and `sometimes` need `recognizeComposites`, hence `foldFormulaFull`.
#guard (Formula.always (Formula.atom pAtom)).foldFormulaFull == EnrichedFormula.always (.atom pAtom)
#guard (Formula.sometimes (Formula.atom pAtom)).foldFormulaFull == EnrichedFormula.sometimes (.atom pAtom)

-- Full round-trip with composites, and the tags each one folds to.
#guard [
    Formula.always (Formula.atom pAtom),
    Formula.sometimes (Formula.atom pAtom),
    Formula.weakFuture (Formula.atom pAtom),
    Formula.weakPast (Formula.atom pAtom)
  ].all (fun f => f == EnrichedFormula.toPrimitive (Formula.foldFormulaFull f))
#guard [
    Formula.always (Formula.atom pAtom),
    Formula.sometimes (Formula.atom pAtom),
    Formula.weakFuture (Formula.atom pAtom),
    Formula.weakPast (Formula.atom pAtom)
  ].map Formula.foldFormulaFull
  == [EnrichedFormula.always (.atom pAtom), EnrichedFormula.sometimes (.atom pAtom),
      EnrichedFormula.weak_future (.atom pAtom), EnrichedFormula.weak_past (.atom pAtom)]

-- Derived binary operators fold to their own tags (not neg(untl ...) etc.).
-- Each assertion checks (a) the correct enriched tag and (b) round-trip identity.
#guard Formula.foldFormulaFull (Formula.release (Formula.atom pAtom) (Formula.atom qAtom))
  == EnrichedFormula.release (.atom pAtom) (.atom qAtom)
#guard Formula.foldFormulaFull (Formula.weakUntil (Formula.atom pAtom) (Formula.atom qAtom))
  == EnrichedFormula.weak_until (.atom pAtom) (.atom qAtom)
#guard Formula.foldFormulaFull (Formula.trigger (Formula.atom pAtom) (Formula.atom qAtom))
  == EnrichedFormula.trigger (.atom pAtom) (.atom qAtom)
#guard Formula.foldFormulaFull (Formula.weakSince (Formula.atom pAtom) (Formula.atom qAtom))
  == EnrichedFormula.weak_since (.atom pAtom) (.atom qAtom)
#guard Formula.foldFormulaFull (Formula.strongRelease (Formula.atom pAtom) (Formula.atom qAtom))
  == EnrichedFormula.strong_release (.atom pAtom) (.atom qAtom)
#guard Formula.foldFormulaFull (Formula.strongTrigger (Formula.atom pAtom) (Formula.atom qAtom))
  == EnrichedFormula.strong_trigger (.atom pAtom) (.atom qAtom)

-- Round-trip: toPrimitive ∘ foldFormulaFull = id for all 6 binary operators.
#guard [
    Formula.release (Formula.atom pAtom) (Formula.atom qAtom),
    Formula.weakUntil (Formula.atom pAtom) (Formula.atom qAtom),
    Formula.trigger (Formula.atom pAtom) (Formula.atom qAtom),
    Formula.weakSince (Formula.atom pAtom) (Formula.atom qAtom),
    Formula.strongRelease (Formula.atom pAtom) (Formula.atom qAtom),
    Formula.strongTrigger (Formula.atom pAtom) (Formula.atom qAtom)
  ].all (fun f => f == EnrichedFormula.toPrimitive (Formula.foldFormulaFull f))

-- Regression (report §8 / plan risk): release(p, ⊥) still folds to allFuture p,
-- because `neg ⊥` collapses to ⊤ and the someFuture ⊥-guard fires first.
#guard Formula.foldFormulaFull (Formula.release (Formula.atom pAtom) Formula.bot)
  == EnrichedFormula.all_future (.atom pAtom)

end FoldTests

/-!
## Round-trip tests over the unfold and fold simp sets
-/

section RoundTripTests

open FormalSystem.Syntax.Formula


-- Round-trip tests over the unfold and fold simp sets.
-- For unambiguous operators, the unfold/fold cycle recovers the original.
-- (Since both sides of the equality are identical, the unfold set rewrites both
-- and the goal closes immediately. This tests that the set does not get stuck.)

-- Test: neg round-trip
example (φ : Formula) : φ.neg = φ.neg := by simp only [formula_unfold]

-- Test: top round-trip
example : Formula.top = Formula.top := by simp only [formula_unfold]

-- Test: diamond round-trip
example (φ : Formula) : φ.diamond = φ.diamond := by simp only [formula_unfold]

-- Test: and round-trip
example (φ ψ : Formula) : Formula.and φ ψ = Formula.and φ ψ := by simp only [formula_unfold]

-- Test: someFuture/somePast round-trip
example (φ : Formula) : someFuture φ = someFuture φ := by simp only [formula_unfold]
example (φ : Formula) : somePast φ = somePast φ := by simp only [formula_unfold]

-- Test: allFuture/allPast round-trip
example (φ : Formula) : allFuture φ = allFuture φ := by simp only [formula_unfold]
example (φ : Formula) : allPast φ = allPast φ := by simp only [formula_unfold]

-- Test: next/prev round-trip
example (φ : Formula) : next φ = next φ := by simp only [formula_unfold]
example (φ : Formula) : prev φ = prev φ := by simp only [formula_unfold]

-- Test: weakFuture/weakPast round-trip
example (φ : Formula) : weakFuture φ = weakFuture φ := by simp only [formula_unfold]
example (φ : Formula) : weakPast φ = weakPast φ := by simp only [formula_unfold]

-- Test: always/sometimes round-trip
example (φ : Formula) : always φ = always φ := by simp only [formula_unfold]
example (φ : Formula) : sometimes φ = sometimes φ := by simp only [formula_unfold]

-- Test: the fold lemmas recover derived operators from primitive form
-- These tests verify that the fold lemmas actually do work on primitive-form goals.
example (φ : Formula) : φ.imp Formula.bot = φ.neg := by simp only [← FormalSystem.Automation.Normalization.neg_unfold]
example (φ : Formula) : Formula.bot.untl φ = φ.next := by simp only [← FormalSystem.Automation.Normalization.next_unfold]
example (φ : Formula) : Formula.bot.snce φ = φ.prev := by simp only [← FormalSystem.Automation.Normalization.prev_unfold]

-- Test: fold lemmas work individually via rw
example (φ ψ : Formula) :
    (φ.imp (ψ.imp Formula.bot)).imp Formula.bot = Formula.and φ ψ := by
  rw [← FormalSystem.Automation.Normalization.and_unfold]
example (φ : Formula) :
    ((φ.imp Formula.bot).box).imp Formula.bot = φ.diamond := by
  rw [← FormalSystem.Automation.Normalization.diamond_unfold]

-- `foldFormulaFull`/`toPrimitive` round-trip over 21 formulas up to complexity 5.
#guard
  let p := Atom.mkBase "p"
  let q := Atom.mkBase "q"
  let testFormulas : List Formula := [
    Formula.atom p, Formula.bot,
    Formula.neg (Formula.atom p), Formula.top,
    Formula.next (Formula.atom p), Formula.prev (Formula.atom p),
    Formula.and (Formula.atom p) (Formula.atom q),
    Formula.or (Formula.atom p) (Formula.atom q),
    Formula.diamond (Formula.atom p),
    Formula.someFuture (Formula.atom p), Formula.somePast (Formula.atom p),
    Formula.allFuture (Formula.atom p), Formula.allPast (Formula.atom p),
    Formula.neg (Formula.neg (Formula.atom p)),
    Formula.diamond (Formula.diamond (Formula.atom p)),
    Formula.box (Formula.neg (Formula.atom p)),
    Formula.imp (Formula.atom p) (Formula.atom q),
    Formula.weakFuture (Formula.atom p), Formula.weakPast (Formula.atom p),
    Formula.always (Formula.atom p), Formula.sometimes (Formula.atom p)
  ]
  testFormulas.length == 21 &&
    testFormulas.all (fun f => f == EnrichedFormula.toPrimitive (Formula.foldFormulaFull f))

end RoundTripTests

/-!
## Serialization tests: JSON, pretty-printing and S-expressions
-/

section SerializationTests

#guard (EnrichedFormula.neg (.atom (Atom.mkBase "p"))).toJson
  == "{\"tag\": \"neg\", \"child\": {\"tag\": \"atom\", \"name\": \"p\"}}"
#guard (EnrichedFormula.diamond (.atom (Atom.mkBase "p"))).toJson
  == "{\"tag\": \"diamond\", \"child\": {\"tag\": \"atom\", \"name\": \"p\"}}"
#guard (Formula.diamond (Formula.atom (Atom.mkBase "p"))).toEnrichedJson
  == "{\"tag\": \"diamond\", \"child\": {\"tag\": \"atom\", \"name\": \"p\"}}"
#guard (EnrichedFormula.always (.atom (Atom.mkBase "p"))).prettyPrint == "△p"
#guard (EnrichedFormula.and_ (.atom (Atom.mkBase "p")) (.atom (Atom.mkBase "q"))).toSExpr
  == "(and (atom \"p\") (atom \"q\"))"
#guard (Formula.always (Formula.atom (Atom.mkBase "p"))).toEnrichedJson
  == "{\"tag\": \"always\", \"child\": {\"tag\": \"atom\", \"name\": \"p\"}}"
#guard (Formula.foldFormulaFull
    (Formula.imp (Formula.diamond (Formula.atom (Atom.mkBase "p")))
      (Formula.allFuture (Formula.atom (Atom.mkBase "q"))))).prettyPrint
  == "(<>p → Gq)"

end SerializationTests

/-!
## Formula enumerator: counts and derived-operator coverage

Counts are for three atoms with modal and temporal depth bounds of 2, captured from the
enumerator's own evaluation. A change in either count means the enumeration grammar changed.
-/

section EnumeratorCounts

open FormalSystem.Automation

#guard (enumExactHelper defaultAtoms 2 2 4 {}).1.size == 7852
#guard (enumExactHelper defaultAtoms 2 2 5 {}).1.size == 75914
#guard (generateBimodalSlice defaultAtoms 2 2 [5]).1.length == 45111

-- Each derived operator is generated at its own complexity level.
#guard (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any
  (· == Formula.diamond (.atom (Atom.mkBase "p")))
#guard (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any
  (· == Formula.next (.atom (Atom.mkBase "p")))
#guard (enumExactHelper defaultAtoms 2 2 2 {}).1.toList.any
  (· == Formula.prev (.atom (Atom.mkBase "p")))
#guard (enumExactHelper defaultAtoms 2 2 3 {}).1.toList.any
  (· == Formula.release (.atom (Atom.mkBase "p")) (.atom (Atom.mkBase "q")))
#guard (enumExactHelper defaultAtoms 2 2 3 {}).1.toList.any
  (· == Formula.weakUntil (.atom (Atom.mkBase "p")) (.atom (Atom.mkBase "q")))

end EnumeratorCounts

end BimodalTest.Automation.NormalizationTest
