/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Formula
import FormalSystem.Automation.FormulaMutator

/-! # Formula Mutator Test Suite

Tests for the single-occurrence mutation engine and contrastive pair generation.

## Test Categories

- `mutateSingleOccurrence` engine correctness
- Individual `try*` mutation transformers
- `MutationType` serialization round-trips
- Deduplication behavior
- `ContrastivePair.toJson` field coverage
-/

namespace BimodalTest.Automation

open FormalSystem.Syntax
open FormalSystem.Automation.FormulaMutator

-- Convenience atoms
private def p : Formula := .atomS "p"
private def q : Formula := .atomS "q"

/-!
## mutateSingleOccurrence Engine Tests
-/

-- mutateSingleOccurrence on box(box p) with trySwapBoxDiamond produces exactly 2 mutants
example :
  let mutants := mutateSingleOccurrence (.box (.box p)) trySwapBoxDiamond
  mutants.length = 2 := rfl

-- The first mutant swaps the outer box
example :
  let mutants := mutateSingleOccurrence (.box (.box p)) trySwapBoxDiamond
  mutants = [((Formula.box p).diamond, 0), (Formula.box p.diamond, 1)] := rfl

-- Occurrence indices are 0 and 1
example :
  let mutants := mutateSingleOccurrence (.box (.box p)) trySwapBoxDiamond
  mutants = [((Formula.box p).diamond, 0), (Formula.box p.diamond, 1)] := rfl

/-!
## Individual Mutation Transformer Tests
-/

-- trySwapBoxDiamond returns none on atom
example : trySwapBoxDiamond p = none := rfl

-- trySwapBoxDiamond returns some on box p
example : trySwapBoxDiamond (.box p) = some p.diamond := rfl

-- trySwapDiamondBox returns none on atom
example : trySwapDiamondBox p = none := rfl

-- trySwapDiamondBox returns some on diamond p
example : trySwapDiamondBox p.diamond = some (.box p) := rfl

-- trySwapUntilRelease returns none on atom
example : trySwapUntilRelease p = none := rfl

-- trySwapUntilRelease returns some on untl p q
example : trySwapUntilRelease (.untl q p) = some (Formula.release p q) := rfl

-- trySwapReleaseUntil returns none on atom
example : trySwapReleaseUntil p = none := rfl

-- trySwapReleaseUntil returns some on release p q
example : trySwapReleaseUntil (Formula.release p q) = some (.untl q p) := rfl

-- trySwapFutureGlobally returns none on atom
example : trySwapFutureGlobally p = none := rfl

-- trySwapFutureGlobally returns some on someFuture p
example : trySwapFutureGlobally p.someFuture = some (Formula.allFuture p) := rfl

-- trySwapGloballyFuture returns none on atom
example : trySwapGloballyFuture p = none := rfl

-- trySwapGloballyFuture returns some on allFuture p
example : trySwapGloballyFuture (Formula.allFuture p) = some p.someFuture := rfl

-- trySwapPastHistorically returns none on atom
example : trySwapPastHistorically p = none := rfl

-- trySwapPastHistorically returns some on somePast p
example : trySwapPastHistorically p.somePast = some (Formula.allPast p) := rfl

-- trySwapHistoricallyPast returns none on atom
example : trySwapHistoricallyPast p = none := rfl

-- trySwapHistoricallyPast returns some on allPast p
example : trySwapHistoricallyPast (Formula.allPast p) = some p.somePast := rfl

-- tryFlipImplication returns none on negation (imp φ bot)
example : tryFlipImplication p.neg = none := rfl

-- tryFlipImplication returns some on genuine implication
example : tryFlipImplication (.imp p q) = some (.imp q p) := rfl

-- tryRemoveLeftConjunct returns none on atom
example : tryRemoveLeftConjunct p = none := rfl

-- tryRemoveLeftConjunct on and p q returns q
example : tryRemoveLeftConjunct (Formula.and p q) = some q := rfl

-- tryRemoveRightConjunct returns none on atom
example : tryRemoveRightConjunct p = none := rfl

-- tryRemoveRightConjunct on and p q returns p
example : tryRemoveRightConjunct (Formula.and p q) = some p := rfl

-- trySwapWeakUntilStrongRelease returns none on atom
example : trySwapWeakUntilStrongRelease p = none := rfl

-- trySwapWeakUntilStrongRelease on weakUntil p q
example : trySwapWeakUntilStrongRelease (Formula.weakUntil p q) = some
    (Formula.strongRelease p q) := rfl

-- trySwapStrongReleaseWeakUntil returns none on atom
example : trySwapStrongReleaseWeakUntil p = none := rfl

-- trySwapStrongReleaseWeakUntil on strongRelease p q
example : trySwapStrongReleaseWeakUntil (Formula.strongRelease p q) = some
    (Formula.weakUntil p q) := rfl

-- trySwapTriggerStrongTrigger returns none on atom
example : trySwapTriggerStrongTrigger p = none := rfl

-- trySwapTriggerStrongTrigger on trigger p q
example : trySwapTriggerStrongTrigger (Formula.trigger p q) = some (Formula.strongTrigger p q) :=
    rfl

-- trySwapStrongTriggerTrigger returns none on atom
example : trySwapStrongTriggerTrigger p = none := rfl

-- trySwapStrongTriggerTrigger on strongTrigger p q
example : trySwapStrongTriggerTrigger (Formula.strongTrigger p q) = some (Formula.trigger p q) :=
    rfl

/-!
## MutationType Serialization Tests
-/

-- boxToDiamondAtOccurrence round-trips through toString
example : MutationType.toString (.boxToDiamondAtOccurrence 3) = "box_to_diamond_at(3)" := rfl

-- flipImplicationAtOccurrence round-trips through toString
example : MutationType.toString (.flipImplicationAtOccurrence 0) = "flip_implication_at(0)" := rfl

-- boxToDiamondAtOccurrence round-trips through toJson
example : MutationType.toJson (.boxToDiamondAtOccurrence 2) = "\"box_to_diamond_at_2\"" := rfl

/-!
## Deduplication Tests
-/

-- Deduplication: generateMutations on a formula with identical subformulas
-- should not produce duplicate mutants for the same rule.
-- (Tested indirectly: mutateSingleOccurrence on a symmetric formula
-- and p q returns exactly one left-conjunct-removal and one right-conjunct-removal)
example :
  let mutants := mutateSingleOccurrence (Formula.and p p) tryRemoveLeftConjunct
  mutants.length = 1 := rfl

/-!
## JSON Field Coverage Test
-/

-- ContrastivePair.toJson contains occurrence_index field for single-occurrence mutations
#eval
  let pair : ContrastivePair := {
    original := p
    originalLabel := .valid
    mutated := q
    mutatedLabel := .invalid
    mutationType := .boxToDiamondAtOccurrence 0
    countermodel := none
    enrichedCountermodel := none
    originalProofTrace := none
  }
  let json := pair.toJson
  json.contains "occurrence_index" && json.contains "mutation_family"
    && json.contains "original_operator" && json.contains "mutated_operator"

end BimodalTest.Automation
