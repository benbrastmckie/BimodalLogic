import Bimodal.Automation.DatasetGenerator
import Bimodal.Automation.EnrichedCountermodel
import Bimodal.Automation.FormulaEnumerator

/-!
# Formula Mutator: Contrastive Pair Generation

This module implements systematic formula mutations for generating contrastive
training pairs. For each valid formula, mutations are applied (atom substitution,
operator weakening, subformula deletion, depth reduction, temporal duality) and
the decision procedure re-run to produce (valid_formula, invalid_mutation,
countermodel) triples.

## Main Definitions

- `MutationType`: Classification of mutation strategies
- `ContrastivePair`: Record linking an original formula to its mutated variant
- `substAtom`: Local atom-to-formula substitution (avoids Separation import)
- `matchAllFuture`/`matchAllPast`: Derived operator recognition helpers
- `mutateAtomToBot`: Replace an atom with bot
- `weakenBoxToDiamond`: Replace box with diamond
- `weakenAllToSome`: Replace G with F and H with P
- `deleteSubformula`: Replace a subformula with a given replacement
- `reduceModalDepth`: Strip outermost box operators
- `reduceTemporalDepth`: Strip outermost untl/snce operators
- `generateMutations`: Produce all applicable mutations for a formula
- `classifyMutation`: Run decision procedure on a mutation and build a pair
- `generateContrastivePairs`: Generate all contrastive pairs for a labeled formula
- `filterContrastive`: Keep only truly contrastive pairs
- `ContrastivePair.toJson`: JSON serialization
- `writeContrastiveJSONL`: JSONL file export
- `main`: Standalone executable entry point

## Design

Mutations operate at the primitive level (6 constructors of `Formula`).
Derived operators (G, H, F, P) are recognized via pattern matching on their
encoding in terms of `imp`, `bot`, `untl`, `snce`.

## References

- Task 206 research report: specs/206_contrastive_pair_generation/reports/01_contrastive-pairs.md
- Formula AST: Theories/Bimodal/Syntax/Formula.lean
- Decision procedure: Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean
-/

set_option autoImplicit false

namespace Bimodal.Automation.FormulaMutator

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.DataExport
open Bimodal.Automation.Enriched
open Bimodal.Metalogic.Decidability

/-!
## Core Types
-/

/-- Classification of mutation strategies applied to formulas. -/
inductive MutationType where
  /-- Replace a specific atom with bot (falsity). -/
  | atomSubBot (atom : Atom)
  /-- Weaken all box (necessity) operators to diamond (possibility). -/
  | boxToDiamond
  /-- Weaken G (all future) to F (some future). -/
  | allFutureToSomeFuture
  /-- Weaken H (all past) to P (some past). -/
  | allPastToSomePast
  /-- Delete a subformula by replacing it with top or bot. -/
  | subformulaDeletion (target : Formula) (replacement : Formula)
  /-- Reduce modal depth by stripping outermost box operators. -/
  | modalDepthReduction
  /-- Reduce temporal depth by stripping outermost untl/snce operators. -/
  | temporalDepthReduction
  /-- Apply temporal duality via swap_temporal. -/
  | temporalDuality
  -- Single-occurrence mutations
  /-- Swap box to diamond at a specific occurrence index. -/
  | boxToDiamondAtOccurrence (occurrenceIdx : Nat)
  /-- Swap diamond to box at a specific occurrence index. -/
  | diamondToBoxAtOccurrence (occurrenceIdx : Nat)
  /-- Swap until to release at a specific occurrence index. -/
  | untilToReleaseAtOccurrence (occurrenceIdx : Nat)
  /-- Swap release to until at a specific occurrence index. -/
  | releaseToUntilAtOccurrence (occurrenceIdx : Nat)
  /-- Swap some_future to all_future at a specific occurrence index. -/
  | futureToGloballyAtOccurrence (occurrenceIdx : Nat)
  /-- Swap all_future to some_future at a specific occurrence index. -/
  | globallyToFutureAtOccurrence (occurrenceIdx : Nat)
  /-- Swap some_past to all_past at a specific occurrence index. -/
  | pastToHistoricallyAtOccurrence (occurrenceIdx : Nat)
  /-- Swap all_past to some_past at a specific occurrence index. -/
  | historicallyToPastAtOccurrence (occurrenceIdx : Nat)
  /-- Swap weak_until to strong_release at a specific occurrence index. -/
  | weakUntilToStrongReleaseAtOccurrence (occurrenceIdx : Nat)
  /-- Swap strong_release to weak_until at a specific occurrence index. -/
  | strongReleaseToWeakUntilAtOccurrence (occurrenceIdx : Nat)
  /-- Swap trigger to strong_trigger at a specific occurrence index. -/
  | triggerToStrongTriggerAtOccurrence (occurrenceIdx : Nat)
  /-- Swap strong_trigger to trigger at a specific occurrence index. -/
  | strongTriggerToTriggerAtOccurrence (occurrenceIdx : Nat)
  /-- Flip implication direction at a specific occurrence index. -/
  | flipImplicationAtOccurrence (occurrenceIdx : Nat)
  /-- Remove left conjunct at a specific occurrence index. -/
  | removeLeftConjunctAtOccurrence (occurrenceIdx : Nat)
  /-- Remove right conjunct at a specific occurrence index. -/
  | removeRightConjunctAtOccurrence (occurrenceIdx : Nat)
  deriving Repr, BEq

/-- A contrastive pair linking an original formula to its mutated variant. -/
structure ContrastivePair where
  /-- The original formula. -/
  original : Formula
  /-- The label of the original formula. -/
  originalLabel : FormulaLabel
  /-- The mutated formula. -/
  mutated : Formula
  /-- The label of the mutated formula (from decision procedure). -/
  mutatedLabel : FormulaLabel
  /-- The type of mutation applied. -/
  mutationType : MutationType
  /-- Simple countermodel for the invalid formula (if applicable). -/
  countermodel : Option SimpleCountermodel
  /-- Enriched countermodel for the invalid formula (if applicable). -/
  enrichedCountermodel : Option EnrichedCountermodel
  /-- Proof trace for the original formula (if valid). -/
  originalProofTrace : Option ProofTrace
  deriving Repr

/-!
## Local Substitution (avoids Separation import)
-/

/--
Substitute a formula for an atom throughout a formula.

This is a local reimplementation to avoid importing the heavy
`Bimodal.Metalogic.WeakCanonical.Separation.FormulaOps` dependency chain.
-/
def substAtom (φ : Formula) (target : Atom) (replacement : Formula) : Formula :=
  match φ with
  | .atom a => if a == target then replacement else .atom a
  | .bot => .bot
  | .imp ψ χ => .imp (substAtom ψ target replacement) (substAtom χ target replacement)
  | .box ψ => .box (substAtom ψ target replacement)
  | .untl ψ χ => .untl (substAtom ψ target replacement) (substAtom χ target replacement)
  | .snce ψ χ => .snce (substAtom ψ target replacement) (substAtom χ target replacement)

/--
Collect all atoms in a formula as a `List Atom` (computable version of `Formula.atoms`).

Unlike `Formula.atoms` which returns a `Finset Atom` (noncomputable `toList`),
this returns a deduplicated list suitable for runtime iteration.
-/
def collectAtoms : Formula → List Atom
  | .atom a => [a]
  | .bot => []
  | .imp ψ χ => (collectAtoms ψ ++ collectAtoms χ).eraseDups
  | .box ψ => collectAtoms ψ
  | .untl ψ χ => (collectAtoms ψ ++ collectAtoms χ).eraseDups
  | .snce ψ χ => (collectAtoms ψ ++ collectAtoms χ).eraseDups

/-!
## Derived Operator Recognition

G(φ) = ¬F(¬φ) = ¬(U(¬φ, ⊤)) = imp (untl (imp φ bot) (imp bot bot)) bot
H(φ) = ¬P(¬φ) = ¬(S(¬φ, ⊤)) = imp (snce (imp φ bot) (imp bot bot)) bot
-/

/--
Recognize the encoding of G(φ) = all_future φ.

Pattern: `imp (untl (imp inner bot) (imp bot bot)) bot`
Returns `some inner` if the formula matches this pattern.
-/
def matchAllFuture : Formula → Option Formula
  | .imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot => some inner
  | _ => none

/--
Recognize the encoding of H(φ) = all_past φ.

Pattern: `imp (snce (imp inner bot) (imp bot bot)) bot`
Returns `some inner` if the formula matches this pattern.
-/
def matchAllPast : Formula → Option Formula
  | .imp (.snce (.imp inner .bot) (.imp .bot .bot)) .bot => some inner
  | _ => none

/-!
## Single-Occurrence Mutation Engine

The engine applies a transformation at exactly one AST node, producing
a list of (mutated_formula, occurrence_index) pairs. Each pair represents
a mutant where one structural change was made.
-/

/--
Apply a transformation at exactly one occurrence in a formula.

Takes a `Formula` and a `Formula → Option Formula` transformer.
Returns a list of (mutated_formula, occurrence_index) pairs where each
mutant differs from the original by exactly one AST node transformation.

The occurrence index is assigned sequentially in depth-first order
to each node where `transform` returns `some`.
-/
def mutateSingleOccurrence (φ : Formula) (transform : Formula → Option Formula) : List (Formula × Nat) :=
  let rec go (ψ : Formula) (idx : Nat) : List (Formula × Nat) × Nat :=
    match transform ψ with
    | some mutated =>
      let (childMuts, nextIdx) := match ψ with
      | .atom _ | .bot => ([], idx + 1)
      | .imp a b =>
        let (m1, i1) := go a (idx + 1)
        let (m2, i2) := go b i1
        let wrapped := m1.map (fun (m, i) => (.imp m b, i)) ++ m2.map (fun (m, i) => (.imp a m, i))
        (wrapped, i2)
      | .box a =>
        let (m1, i1) := go a (idx + 1)
        let wrapped := m1.map (fun (m, i) => (.box m, i))
        (wrapped, i1)
      | .untl a b =>
        let (m1, i1) := go a (idx + 1)
        let (m2, i2) := go b i1
        let wrapped := m1.map (fun (m, i) => (.untl m b, i)) ++ m2.map (fun (m, i) => (.untl a m, i))
        (wrapped, i2)
      | .snce a b =>
        let (m1, i1) := go a (idx + 1)
        let (m2, i2) := go b i1
        let wrapped := m1.map (fun (m, i) => (.snce m b, i)) ++ m2.map (fun (m, i) => (.snce a m, i))
        (wrapped, i2)
      ((mutated, idx) :: childMuts, nextIdx)
    | none =>
      let (childMuts, nextIdx) := match ψ with
      | .atom _ | .bot => ([], idx)
      | .imp a b =>
        let (m1, i1) := go a idx
        let (m2, i2) := go b i1
        let wrapped := m1.map (fun (m, i) => (.imp m b, i)) ++ m2.map (fun (m, i) => (.imp a m, i))
        (wrapped, i2)
      | .box a =>
        let (m1, i1) := go a idx
        let wrapped := m1.map (fun (m, i) => (.box m, i))
        (wrapped, i1)
      | .untl a b =>
        let (m1, i1) := go a idx
        let (m2, i2) := go b i1
        let wrapped := m1.map (fun (m, i) => (.untl m b, i)) ++ m2.map (fun (m, i) => (.untl a m, i))
        (wrapped, i2)
      | .snce a b =>
        let (m1, i1) := go a idx
        let (m2, i2) := go b i1
        let wrapped := m1.map (fun (m, i) => (.snce m b, i)) ++ m2.map (fun (m, i) => (.snce a m, i))
        (wrapped, i2)
      (childMuts, nextIdx)
  go φ 0 |>.1

/-!
## Specific Single-Occurrence Mutation Transformers
-/

/-- Match `box φ` and return `diamond φ`. -/
def trySwapBoxDiamond : Formula → Option Formula
  | .box φ => some φ.diamond
  | _ => none

/-- Match `diamond φ` (primitive: `imp (box (imp φ bot)) bot`) and return `box φ`. -/
def trySwapDiamondBox : Formula → Option Formula
  | .imp (.box (.imp inner .bot)) .bot => some (.box inner)
  | _ => none

/-- Match `untl φ ψ` and return `release φ ψ`. -/
def trySwapUntilRelease : Formula → Option Formula
  | .untl φ ψ => some (Formula.release φ ψ)
  | _ => none

/-- Match `release φ ψ` (primitive: `imp (untl (imp φ bot) (imp ψ bot)) bot`) and return `untl φ ψ`. -/
def trySwapReleaseUntil : Formula → Option Formula
  | .imp (.untl (.imp inner1 .bot) (.imp inner2 .bot)) .bot =>
    some (.untl inner1 inner2)
  | _ => none

/-- Match `some_future φ` (primitive: `untl φ top`) and return `all_future φ`. -/
def trySwapFutureGlobally : Formula → Option Formula
  | .untl φ (.imp .bot .bot) => some (Formula.all_future φ)
  | _ => none

/-- Match `all_future φ` (primitive: `imp (untl (imp φ bot) top) bot`) and return `some_future φ`. -/
def trySwapGloballyFuture : Formula → Option Formula
  | .imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot =>
    some (Formula.some_future inner)
  | _ => none

/-- Match `some_past φ` (primitive: `snce φ top`) and return `all_past φ`. -/
def trySwapPastHistorically : Formula → Option Formula
  | .snce φ (.imp .bot .bot) => some (Formula.all_past φ)
  | _ => none

/-- Match `all_past φ` (primitive: `imp (snce (imp φ bot) top) bot`) and return `some_past φ`. -/
def trySwapHistoricallyPast : Formula → Option Formula
  | .imp (.snce (.imp inner .bot) (.imp .bot .bot)) .bot =>
    some (Formula.some_past inner)
  | _ => none

/-- Match `weak_until φ ψ` and return `strong_release φ ψ`. -/
def trySwapWeakUntilStrongRelease : Formula → Option Formula
  | .imp (.imp (.untl φ ψ1) .bot) (.imp (.untl (.imp ψ2 .bot) (.imp .bot .bot)) .bot) =>
    if ψ1 == ψ2 then some (Formula.strong_release φ ψ1) else none
  | _ => none

/-- Match `strong_release φ ψ` and return `weak_until φ ψ`. -/
def trySwapStrongReleaseWeakUntil : Formula → Option Formula
  | .untl (.imp (.imp ψ1 (.imp φ .bot)) .bot) ψ2 =>
    if ψ1 == ψ2 then some (Formula.weak_until φ ψ1) else none
  | _ => none

/-- Match `trigger φ ψ` (primitive: `imp (snce (imp φ bot) (imp ψ bot)) bot`) and return `strong_trigger φ ψ`. -/
def trySwapTriggerStrongTrigger : Formula → Option Formula
  | .imp (.snce (.imp φ .bot) (.imp ψ .bot)) .bot =>
    some (Formula.strong_trigger φ ψ)
  | _ => none

/-- Match `strong_trigger φ ψ` and return `trigger φ ψ`. -/
def trySwapStrongTriggerTrigger : Formula → Option Formula
  | .snce (.imp (.imp ψ1 (.imp φ .bot)) .bot) ψ2 =>
    if ψ1 == ψ2 then some (Formula.trigger φ ψ1) else none
  | _ => none

/-- Match `imp φ ψ` where `ψ != bot` and return `imp ψ φ`. -/
def tryFlipImplication : Formula → Option Formula
  | .imp φ ψ =>
    if ψ == .bot then none
    else some (.imp ψ φ)
  | _ => none

/-- Match `and φ ψ` (primitive: `imp (imp φ (imp ψ bot)) bot`) and return the right conjunct `ψ`. -/
def tryRemoveLeftConjunct : Formula → Option Formula
  | .imp (.imp _ (.imp ψ .bot)) .bot => some ψ
  | _ => none

/-- Match `and φ ψ` (primitive: `imp (imp φ (imp ψ bot)) bot`) and return the left conjunct `φ`. -/
def tryRemoveRightConjunct : Formula → Option Formula
  | .imp (.imp φ (.imp _ .bot)) .bot => some φ
  | _ => none

/-!
## Mutation Functions
-/

/--
Replace a specific atom with bot (falsity) throughout a formula.
-/
def mutateAtomToBot (φ : Formula) (target : Atom) : Formula :=
  substAtom φ target .bot

/--
Weaken all box (necessity) operators to diamond (possibility).

Replaces `box ψ` with `diamond ψ` = `neg (box (neg ψ))` recursively.
-/
def weakenBoxToDiamond : Formula → Formula
  | .atom a => .atom a
  | .bot => .bot
  | .box ψ => (weakenBoxToDiamond ψ).diamond
  | .imp ψ χ => .imp (weakenBoxToDiamond ψ) (weakenBoxToDiamond χ)
  | .untl ψ χ => .untl (weakenBoxToDiamond ψ) (weakenBoxToDiamond χ)
  | .snce ψ χ => .snce (weakenBoxToDiamond ψ) (weakenBoxToDiamond χ)

/--
Weaken G (all future) to F (some future) and H (all past) to P (some past).

Recognizes the derived-operator encoding patterns and replaces them with
their existential counterparts. Non-matching formulas are recursed into.

Uses direct pattern matching on the primitive encoding rather than calling
`matchAllFuture`/`matchAllPast` to ensure structural termination.
-/
def weakenAllToSome : Formula → Formula
  -- G(inner) = imp (untl (imp inner bot) (imp bot bot)) bot → F(inner) = untl inner (imp bot bot)
  | .imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot =>
    Formula.some_future (weakenAllToSome inner)
  -- H(inner) = imp (snce (imp inner bot) (imp bot bot)) bot → P(inner) = snce inner (imp bot bot)
  | .imp (.snce (.imp inner .bot) (.imp .bot .bot)) .bot =>
    Formula.some_past (weakenAllToSome inner)
  | .imp ψ χ => .imp (weakenAllToSome ψ) (weakenAllToSome χ)
  | .box ψ => .box (weakenAllToSome ψ)
  | .untl ψ χ => .untl (weakenAllToSome ψ) (weakenAllToSome χ)
  | .snce ψ χ => .snce (weakenAllToSome ψ) (weakenAllToSome χ)
  | φ => φ

/--
Delete a subformula by replacing all occurrences of `target` with `replacement`.

This is used to systematically simplify formulas by replacing subformulas
with `top` (vacuous truth) or `bot` (falsity).
-/
def deleteSubformula (φ : Formula) (target : Formula) (replacement : Formula) : Formula :=
  if φ == target then replacement
  else match φ with
  | .atom a => .atom a
  | .bot => .bot
  | .imp ψ χ => .imp (deleteSubformula ψ target replacement) (deleteSubformula χ target replacement)
  | .box ψ => .box (deleteSubformula ψ target replacement)
  | .untl ψ χ => .untl (deleteSubformula ψ target replacement) (deleteSubformula χ target replacement)
  | .snce ψ χ => .snce (deleteSubformula ψ target replacement) (deleteSubformula χ target replacement)

/--
Reduce modal depth by stripping outermost box operators.

Replaces each top-level `box ψ` with just `ψ`, recursing into binary
operators to find boxes at the top level of each branch.
-/
def reduceModalDepth : Formula → Formula
  | .atom a => .atom a
  | .bot => .bot
  | .box ψ => ψ
  | .imp ψ χ => .imp (reduceModalDepth ψ) (reduceModalDepth χ)
  | .untl ψ χ => .untl (reduceModalDepth ψ) (reduceModalDepth χ)
  | .snce ψ χ => .snce (reduceModalDepth ψ) (reduceModalDepth χ)

/--
Reduce temporal depth by stripping outermost untl/snce operators.

Replaces each top-level `untl ψ χ` or `snce ψ χ` with `ψ` (the event formula),
recursing into other operators to find temporal operators at the top level.
-/
def reduceTemporalDepth : Formula → Formula
  | .atom a => .atom a
  | .bot => .bot
  | .untl ψ _ => ψ
  | .snce ψ _ => ψ
  | .imp ψ χ => .imp (reduceTemporalDepth ψ) (reduceTemporalDepth χ)
  | .box ψ => .box (reduceTemporalDepth ψ)

/-!
## Mutation Generation
-/

/--
Check whether a formula contains any box operators.
-/
def hasBox : Formula → Bool
  | .atom _ => false
  | .bot => false
  | .box _ => true
  | .imp ψ χ => hasBox ψ || hasBox χ
  | .untl ψ χ => hasBox ψ || hasBox χ
  | .snce ψ χ => hasBox ψ || hasBox χ

/--
Check whether a formula contains any G (all_future) patterns.
-/
def hasAllFuture : Formula → Bool
  | .imp (.untl (.imp _ .bot) (.imp .bot .bot)) .bot => true
  | .imp ψ χ => hasAllFuture ψ || hasAllFuture χ
  | .box ψ => hasAllFuture ψ
  | .untl ψ χ => hasAllFuture ψ || hasAllFuture χ
  | .snce ψ χ => hasAllFuture ψ || hasAllFuture χ
  | _ => false

/--
Check whether a formula contains any H (all_past) patterns.
-/
def hasAllPast : Formula → Bool
  | .imp (.snce (.imp _ .bot) (.imp .bot .bot)) .bot => true
  | .imp ψ χ => hasAllPast ψ || hasAllPast χ
  | .box ψ => hasAllPast ψ
  | .untl ψ χ => hasAllPast ψ || hasAllPast χ
  | .snce ψ χ => hasAllPast ψ || hasAllPast χ
  | _ => false

/--
Check whether a formula contains any temporal operators (untl or snce).
-/
def hasTemporal : Formula → Bool
  | .atom _ => false
  | .bot => false
  | .untl _ _ => true
  | .snce _ _ => true
  | .imp ψ χ => hasTemporal ψ || hasTemporal χ
  | .box ψ => hasTemporal ψ

/--
Generate all applicable mutations for a given formula.

Returns a list of (mutated_formula, mutation_type) pairs. The mutations include:
1. Atom-to-bot: one mutation per atom in the formula
2. Box-to-diamond: if the formula contains box operators
3. All-future-to-some-future: if the formula contains G patterns
4. All-past-to-some-past: if the formula contains H patterns
5. Subformula deletion (with bot): for each proper subformula
6. Modal depth reduction: if the formula has modal depth > 0
7. Temporal depth reduction: if the formula has temporal depth > 0
8. Temporal duality: if the formula contains temporal operators
9. Single-occurrence mutations: ~10 fine-grained structural changes
-/
private def dedupMutations (muts : List (Formula × MutationType)) : List (Formula × MutationType) :=
  let rec go (acc : List (Formula × MutationType)) (seen : List Formula) (rest : List (Formula × MutationType)) : List (Formula × MutationType) :=
    match rest with
    | [] => acc.reverse
    | (f, mt) :: rest' =>
      if seen.contains f then
        go acc seen rest'
      else
        go ((f, mt) :: acc) (f :: seen) rest'
  go [] [] muts

def generateMutations (φ : Formula) : List (Formula × MutationType) :=
  let atomMutations := (collectAtoms φ).map fun a =>
    (mutateAtomToBot φ a, MutationType.atomSubBot a)
  let boxMutation :=
    if hasBox φ then
      let m := weakenBoxToDiamond φ
      if m == φ then [] else [(m, MutationType.boxToDiamond)]
    else []
  let gMutation :=
    if hasAllFuture φ then
      let m := weakenAllToSome φ
      if m == φ then [] else [(m, MutationType.allFutureToSomeFuture)]
    else []
  let hMutation :=
    if hasAllPast φ then
      let m := weakenAllToSome φ
      if m == φ then [] else [(m, MutationType.allPastToSomePast)]
    else []
  -- Subformula deletion: replace each proper subformula with bot
  let subs := φ.subformulas.eraseDups.filter (· != φ)
  let subDeletions := subs.map fun sub =>
    (deleteSubformula φ sub .bot, MutationType.subformulaDeletion sub .bot)
  let modalReduction :=
    if φ.modalDepth > 0 then
      let m := reduceModalDepth φ
      if m == φ then [] else [(m, MutationType.modalDepthReduction)]
    else []
  let temporalReduction :=
    if φ.temporalDepth > 0 then
      let m := reduceTemporalDepth φ
      if m == φ then [] else [(m, MutationType.temporalDepthReduction)]
    else []
  let dualityMutation :=
    if hasTemporal φ then
      let m := φ.swap_temporal
      if m == φ then [] else [(m, MutationType.temporalDuality)]
    else []
  -- Single-occurrence mutations
  let boxToDiamondOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapBoxDiamond).map fun (m, i) => (m, .boxToDiamondAtOccurrence i)
  let diamondToBoxOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapDiamondBox).map fun (m, i) => (m, .diamondToBoxAtOccurrence i)
  let untilToReleaseOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapUntilRelease).map fun (m, i) => (m, .untilToReleaseAtOccurrence i)
  let releaseToUntilOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapReleaseUntil).map fun (m, i) => (m, .releaseToUntilAtOccurrence i)
  let futureToGloballyOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapFutureGlobally).map fun (m, i) => (m, .futureToGloballyAtOccurrence i)
  let globallyToFutureOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapGloballyFuture).map fun (m, i) => (m, .globallyToFutureAtOccurrence i)
  let pastToHistoricallyOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapPastHistorically).map fun (m, i) => (m, .pastToHistoricallyAtOccurrence i)
  let historicallyToPastOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapHistoricallyPast).map fun (m, i) => (m, .historicallyToPastAtOccurrence i)
  let weakUntilToStrongReleaseOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapWeakUntilStrongRelease).map fun (m, i) => (m, .weakUntilToStrongReleaseAtOccurrence i)
  let strongReleaseToWeakUntilOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapStrongReleaseWeakUntil).map fun (m, i) => (m, .strongReleaseToWeakUntilAtOccurrence i)
  let triggerToStrongTriggerOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapTriggerStrongTrigger).map fun (m, i) => (m, .triggerToStrongTriggerAtOccurrence i)
  let strongTriggerToTriggerOccs := dedupMutations <|
    (mutateSingleOccurrence φ trySwapStrongTriggerTrigger).map fun (m, i) => (m, .strongTriggerToTriggerAtOccurrence i)
  let flipImplicationOccs := dedupMutations <|
    (mutateSingleOccurrence φ tryFlipImplication).map fun (m, i) => (m, .flipImplicationAtOccurrence i)
  let removeLeftConjunctOccs := dedupMutations <|
    (mutateSingleOccurrence φ tryRemoveLeftConjunct).map fun (m, i) => (m, .removeLeftConjunctAtOccurrence i)
  let removeRightConjunctOccs := dedupMutations <|
    (mutateSingleOccurrence φ tryRemoveRightConjunct).map fun (m, i) => (m, .removeRightConjunctAtOccurrence i)
  -- Combine all mutations, filter out those producing same formula as original
  let allMutations := atomMutations ++ boxMutation ++ gMutation ++ hMutation
    ++ subDeletions ++ modalReduction ++ temporalReduction ++ dualityMutation
    ++ boxToDiamondOccs ++ diamondToBoxOccs
    ++ untilToReleaseOccs ++ releaseToUntilOccs
    ++ futureToGloballyOccs ++ globallyToFutureOccs
    ++ pastToHistoricallyOccs ++ historicallyToPastOccs
    ++ weakUntilToStrongReleaseOccs ++ strongReleaseToWeakUntilOccs
    ++ triggerToStrongTriggerOccs ++ strongTriggerToTriggerOccs
    ++ flipImplicationOccs ++ removeLeftConjunctOccs ++ removeRightConjunctOccs
  allMutations.filter fun (m, _) => m != φ

/-!
## Contrastive Pair Generation Pipeline
-/

/--
Run the labeling pipeline on a mutated formula and construct a contrastive pair.

Uses `DatasetGenerator.labelFormula` (with structural pre-filter, wall-clock
timeout, and enriched countermodel extraction) instead of raw `decideAuto`.
-/
def classifyMutation (original : Formula) (originalLabel : FormulaLabel)
    (originalProofTrace : Option ProofTrace)
    (mutated : Formula) (mutationType : MutationType) : IO ContrastivePair := do
  let labeled ← labelFormula mutated .Base 1000
  return {
    original := original
    originalLabel := originalLabel
    mutated := mutated
    mutatedLabel := labeled.label
    mutationType := mutationType
    countermodel := labeled.countermodel
    enrichedCountermodel := labeled.enrichedCountermodel
    originalProofTrace := originalProofTrace
  }

/--
Generate all contrastive pairs for a labeled formula.

For valid formulas: generates all mutations and classifies each.
For invalid formulas: tries temporal duality (swap_temporal) to find
cases where the dual has different validity.
-/
def generateContrastivePairs (lf : LabeledFormula) : IO (List ContrastivePair) := do
  match lf.label with
  | .valid =>
    -- Generate all mutations of the valid formula
    let mutations := generateMutations lf.formula
    let mut pairs : List ContrastivePair := []
    for (mutated, mutType) in mutations do
      let pair ← classifyMutation lf.formula lf.label lf.proofTrace mutated mutType
      pairs := pair :: pairs
    return pairs.reverse
  | .invalid =>
    -- For invalid formulas, try temporal duality
    if hasTemporal lf.formula then
      let dual := lf.formula.swap_temporal
      if dual != lf.formula then
        let pair ← classifyMutation lf.formula lf.label none dual .temporalDuality
        return [pair]
      else return []
    else return []
  | .timeout => return []

/--
Filter contrastive pairs to keep only truly contrastive ones.

A pair is contrastive if:
1. The original and mutated labels differ
2. The mutated formula has complexity >= 3 (non-trivial)
3. Neither formula timed out
-/
def filterContrastive (pairs : List ContrastivePair) : List ContrastivePair :=
  pairs.filter fun p =>
    p.originalLabel != p.mutatedLabel
    && p.mutatedLabel != .timeout
    && p.originalLabel != .timeout
    && p.mutated.complexity >= 3

/--
Generate contrastive pairs for a batch of labeled formulas with progress reporting.

Processes each labeled formula, generates mutations, classifies them, and
filters for truly contrastive pairs. Reports progress every 50 formulas.
-/
def generateBatchContrastive (labeledFormulas : List LabeledFormula)
    : IO (List ContrastivePair) := do
  let total := labeledFormulas.length
  let mut allPairs : List ContrastivePair := []
  let mut count : Nat := 0
  for lf in labeledFormulas do
    let pairs ← generateContrastivePairs lf
    let contrastive := filterContrastive pairs
    allPairs := allPairs ++ contrastive
    count := count + 1
    if count % 50 == 0 then
      IO.println s!"  Contrastive progress: {count}/{total} formulas processed, {allPairs.length} pairs found"
  return allPairs

/-!
## JSON Serialization
-/

/--
Convert a `MutationType` to a human-readable string name.
-/
def MutationType.toString : MutationType → String
  | .atomSubBot a => s!"atom_sub_bot({a.base})"
  | .boxToDiamond => "box_to_diamond"
  | .allFutureToSomeFuture => "all_future_to_some_future"
  | .allPastToSomePast => "all_past_to_some_past"
  | .subformulaDeletion _ _ => "subformula_deletion"
  | .modalDepthReduction => "modal_depth_reduction"
  | .temporalDepthReduction => "temporal_depth_reduction"
  | .temporalDuality => "temporal_duality"
  -- Single-occurrence mutations
  | .boxToDiamondAtOccurrence i => s!"box_to_diamond_at({i})"
  | .diamondToBoxAtOccurrence i => s!"diamond_to_box_at({i})"
  | .untilToReleaseAtOccurrence i => s!"until_to_release_at({i})"
  | .releaseToUntilAtOccurrence i => s!"release_to_until_at({i})"
  | .futureToGloballyAtOccurrence i => s!"future_to_globally_at({i})"
  | .globallyToFutureAtOccurrence i => s!"globally_to_future_at({i})"
  | .pastToHistoricallyAtOccurrence i => s!"past_to_historically_at({i})"
  | .historicallyToPastAtOccurrence i => s!"historically_to_past_at({i})"
  | .weakUntilToStrongReleaseAtOccurrence i => s!"weak_until_to_strong_release_at({i})"
  | .strongReleaseToWeakUntilAtOccurrence i => s!"strong_release_to_weak_until_at({i})"
  | .triggerToStrongTriggerAtOccurrence i => s!"trigger_to_strong_trigger_at({i})"
  | .strongTriggerToTriggerAtOccurrence i => s!"strong_trigger_to_trigger_at({i})"
  | .flipImplicationAtOccurrence i => s!"flip_implication_at({i})"
  | .removeLeftConjunctAtOccurrence i => s!"remove_left_conjunct_at({i})"
  | .removeRightConjunctAtOccurrence i => s!"remove_right_conjunct_at({i})"

/--
Convert a `MutationType` to a JSON-safe string for the mutation_type field.
-/
def MutationType.toJson : MutationType → String
  | .atomSubBot _ => "\"atom_sub_bot\""
  | .boxToDiamond => "\"box_to_diamond\""
  | .allFutureToSomeFuture => "\"all_future_to_some_future\""
  | .allPastToSomePast => "\"all_past_to_some_past\""
  | .subformulaDeletion _ _ => "\"subformula_deletion\""
  | .modalDepthReduction => "\"modal_depth_reduction\""
  | .temporalDepthReduction => "\"temporal_depth_reduction\""
  | .temporalDuality => "\"temporal_duality\""
  -- Single-occurrence mutations
  | .boxToDiamondAtOccurrence i => "\"box_to_diamond_at_" ++ Nat.repr i ++ "\""
  | .diamondToBoxAtOccurrence i => "\"diamond_to_box_at_" ++ Nat.repr i ++ "\""
  | .untilToReleaseAtOccurrence i => "\"until_to_release_at_" ++ Nat.repr i ++ "\""
  | .releaseToUntilAtOccurrence i => "\"release_to_until_at_" ++ Nat.repr i ++ "\""
  | .futureToGloballyAtOccurrence i => "\"future_to_globally_at_" ++ Nat.repr i ++ "\""
  | .globallyToFutureAtOccurrence i => "\"globally_to_future_at_" ++ Nat.repr i ++ "\""
  | .pastToHistoricallyAtOccurrence i => "\"past_to_historically_at_" ++ Nat.repr i ++ "\""
  | .historicallyToPastAtOccurrence i => "\"historically_to_past_at_" ++ Nat.repr i ++ "\""
  | .weakUntilToStrongReleaseAtOccurrence i => "\"weak_until_to_strong_release_at_" ++ Nat.repr i ++ "\""
  | .strongReleaseToWeakUntilAtOccurrence i => "\"strong_release_to_weak_until_at_" ++ Nat.repr i ++ "\""
  | .triggerToStrongTriggerAtOccurrence i => "\"trigger_to_strong_trigger_at_" ++ Nat.repr i ++ "\""
  | .strongTriggerToTriggerAtOccurrence i => "\"strong_trigger_to_trigger_at_" ++ Nat.repr i ++ "\""
  | .flipImplicationAtOccurrence i => "\"flip_implication_at_" ++ Nat.repr i ++ "\""
  | .removeLeftConjunctAtOccurrence i => "\"remove_left_conjunct_at_" ++ Nat.repr i ++ "\""
  | .removeRightConjunctAtOccurrence i => "\"remove_right_conjunct_at_" ++ Nat.repr i ++ "\""

private def natToString (n : Nat) : String := Nat.repr n

/--
Produce a JSON string for the mutation_detail field.

For atom substitutions, includes the atom name. For subformula deletions,
includes the target and replacement formulas.
-/
def MutationType.detailJson : MutationType → String
  | .atomSubBot a => "{\"atom\": \"" ++ escapeJsonString a.base ++ "\"}"
  | .subformulaDeletion target replacement =>
    "{\"target\": \"" ++ escapeJsonString target.prettyPrint
    ++ "\", \"replacement\": \"" ++ escapeJsonString replacement.prettyPrint ++ "\"}"
  | _ => "null"

/-- Map each mutation type to its high-level family string. -/
def MutationType.mutationFamily : MutationType → String
  | .atomSubBot _ => "atom_sub"
  | .boxToDiamond | .boxToDiamondAtOccurrence _ | .diamondToBoxAtOccurrence _ => "modal_swap"
  | .allFutureToSomeFuture | .allPastToSomePast => "global_weakening"
  | .subformulaDeletion _ _ => "subformula_deletion"
  | .modalDepthReduction => "modal_depth_reduction"
  | .temporalDepthReduction => "temporal_depth_reduction"
  | .temporalDuality => "temporal_duality"
  | .untilToReleaseAtOccurrence _ | .releaseToUntilAtOccurrence _ => "temporal_swap"
  | .futureToGloballyAtOccurrence _ | .globallyToFutureAtOccurrence _
  | .pastToHistoricallyAtOccurrence _ | .historicallyToPastAtOccurrence _ => "temporal_swap"
  | .weakUntilToStrongReleaseAtOccurrence _ | .strongReleaseToWeakUntilAtOccurrence _ => "derived_swap"
  | .triggerToStrongTriggerAtOccurrence _ | .strongTriggerToTriggerAtOccurrence _ => "derived_swap"
  | .flipImplicationAtOccurrence _ => "structural_flip"
  | .removeLeftConjunctAtOccurrence _ | .removeRightConjunctAtOccurrence _ => "conjunct_removal"

/-- Return the original operator name for a single-occurrence mutation. -/
def MutationType.originalOperator : MutationType → String
  | .boxToDiamond | .boxToDiamondAtOccurrence _ => "box"
  | .diamondToBoxAtOccurrence _ => "diamond"
  | .allFutureToSomeFuture | .globallyToFutureAtOccurrence _ => "globally"
  | .allPastToSomePast | .historicallyToPastAtOccurrence _ => "historically"
  | .futureToGloballyAtOccurrence _ => "future"
  | .pastToHistoricallyAtOccurrence _ => "past"
  | .untilToReleaseAtOccurrence _ => "until"
  | .releaseToUntilAtOccurrence _ => "release"
  | .weakUntilToStrongReleaseAtOccurrence _ => "weak_until"
  | .strongReleaseToWeakUntilAtOccurrence _ => "strong_release"
  | .triggerToStrongTriggerAtOccurrence _ => "trigger"
  | .strongTriggerToTriggerAtOccurrence _ => "strong_trigger"
  | .flipImplicationAtOccurrence _ => "implication"
  | .removeLeftConjunctAtOccurrence _ | .removeRightConjunctAtOccurrence _ => "conjunction"
  | _ => "unknown"

/-- Return the mutated operator name for a single-occurrence mutation. -/
def MutationType.mutatedOperator : MutationType → String
  | .boxToDiamond | .boxToDiamondAtOccurrence _ => "diamond"
  | .diamondToBoxAtOccurrence _ => "box"
  | .allFutureToSomeFuture | .globallyToFutureAtOccurrence _ => "future"
  | .allPastToSomePast | .historicallyToPastAtOccurrence _ => "past"
  | .futureToGloballyAtOccurrence _ => "globally"
  | .pastToHistoricallyAtOccurrence _ => "historically"
  | .untilToReleaseAtOccurrence _ => "release"
  | .releaseToUntilAtOccurrence _ => "until"
  | .weakUntilToStrongReleaseAtOccurrence _ => "strong_release"
  | .strongReleaseToWeakUntilAtOccurrence _ => "weak_until"
  | .triggerToStrongTriggerAtOccurrence _ => "strong_trigger"
  | .strongTriggerToTriggerAtOccurrence _ => "trigger"
  | .flipImplicationAtOccurrence _ => "implication"
  | .removeLeftConjunctAtOccurrence _ | .removeRightConjunctAtOccurrence _ => "conjunct_removed"
  | _ => "unknown"

/--
Serialize an `Option SimpleCountermodel` to a JSON string.
-/
private def optionCmToJson : Option SimpleCountermodel → String
  | some cm => cm.toJson
  | none => "null"

/--
Serialize an `Option EnrichedCountermodel` to a JSON string.
-/
private def optionEcmToJson : Option EnrichedCountermodel → String
  | some ecm => ecm.toJson
  | none => "null"

/--
Serialize an `Option ProofTrace` to a JSON string.
-/
private def optionPtToJson : Option ProofTrace → String
  | some pt => pt.toJson
  | none => "null"

/--
Serialize a `ContrastivePair` to a JSON object string.

Produces the full JSON record including original formula/AST/label,
mutated formula/AST/label, countermodel, enriched countermodel,
mutation type and detail.
-/
def ContrastivePair.toJson (cp : ContrastivePair) : String :=
  let ptStr := optionPtToJson cp.originalProofTrace
  let cmStr := optionCmToJson cp.countermodel
  let ecmStr := optionEcmToJson cp.enrichedCountermodel
  let originalStr := "{\"formula_str\": \"" ++ escapeJsonString cp.original.prettyPrint
    ++ "\", \"formula_ast\": " ++ cp.original.toJson
    ++ ", \"label\": " ++ cp.originalLabel.toJson
    ++ ", \"proof_trace\": " ++ ptStr
    ++ "}"
  let mutatedStr := "{\"formula_str\": \"" ++ escapeJsonString cp.mutated.prettyPrint
    ++ "\", \"formula_ast\": " ++ cp.mutated.toJson
    ++ ", \"label\": " ++ cp.mutatedLabel.toJson
    ++ ", \"countermodel\": " ++ cmStr
    ++ ", \"enriched_countermodel\": " ++ ecmStr
    ++ "}"
  let occIdxStr := match cp.mutationType with
    | .boxToDiamondAtOccurrence i | .diamondToBoxAtOccurrence i
    | .untilToReleaseAtOccurrence i | .releaseToUntilAtOccurrence i
    | .futureToGloballyAtOccurrence i | .globallyToFutureAtOccurrence i
    | .pastToHistoricallyAtOccurrence i | .historicallyToPastAtOccurrence i
    | .weakUntilToStrongReleaseAtOccurrence i | .strongReleaseToWeakUntilAtOccurrence i
    | .triggerToStrongTriggerAtOccurrence i | .strongTriggerToTriggerAtOccurrence i
    | .flipImplicationAtOccurrence i | .removeLeftConjunctAtOccurrence i
    | .removeRightConjunctAtOccurrence i => toString i
    | _ => "null"
  let familyStr := cp.mutationType.mutationFamily
  let origOpStr := cp.mutationType.originalOperator
  let mutOpStr := cp.mutationType.mutatedOperator
  "{\"original\": " ++ originalStr
    ++ ", \"mutation\": " ++ mutatedStr
    ++ ", \"mutation_type\": " ++ cp.mutationType.toJson
    ++ ", \"mutation_detail\": " ++ cp.mutationType.detailJson
    ++ ", \"occurrence_index\": " ++ occIdxStr
    ++ ", \"mutation_family\": \"" ++ escapeJsonString familyStr ++ "\""
    ++ ", \"original_operator\": \"" ++ escapeJsonString origOpStr ++ "\""
    ++ ", \"mutated_operator\": \"" ++ escapeJsonString mutOpStr ++ "\""
    ++ "}"

/-!
## JSONL Export
-/

/--
Left-pad a number string to a minimum width with zeros.
-/
private def padLeft (s : String) (width : Nat) : String :=
  let padding := width - min s.length width
  String.ofList (List.replicate padding '0') ++ s

/--
Write a list of contrastive pairs to a JSONL file.

Each pair is written as a single JSON line with an auto-incrementing ID.
-/
def writeContrastiveJSONL (pairs : List ContrastivePair)
    (path : System.FilePath) : IO Unit := do
  let handle ← IO.FS.Handle.mk path .write
  let mut idx : Nat := 1
  for cp in pairs do
    let idNum := Nat.repr idx
    let paddedId := padLeft idNum 5
    let line := "{\"id\": \"contrastive-" ++ paddedId
      ++ "\", " ++ (cp.toJson.drop 1)  -- drop the leading '{' and prepend id
    handle.putStrLn line
    idx := idx + 1

/-!
## Batch Statistics
-/

/--
Summary statistics for a batch of contrastive pair generation.
-/
structure ContrastiveBatchStats where
  /-- Total mutations attempted. -/
  totalMutations : Nat
  /-- Number of truly contrastive pairs found. -/
  contrastiveCount : Nat
  /-- Yield rate (contrastive / total). -/
  yieldRate : Float
  /-- Breakdown by legacy mutation type. -/
  atomSubBotCount : Nat
  boxToDiamondCount : Nat
  allFutureToSomeCount : Nat
  allPastToSomeCount : Nat
  subformulaDeletionCount : Nat
  modalReductionCount : Nat
  temporalReductionCount : Nat
  temporalDualityCount : Nat
  /-- Breakdown by single-occurrence mutation family. -/
  modalSwapCount : Nat
  temporalSwapCount : Nat
  derivedSwapCount : Nat
  structuralFlipCount : Nat
  conjunctRemovalCount : Nat
  deriving Repr

/--
Compute summary statistics for a batch of contrastive pairs.
-/
def computeContrastiveStats (totalMutations : Nat) (pairs : List ContrastivePair)
    : ContrastiveBatchStats :=
  let count := pairs.length
  let rate := if totalMutations > 0 then
    (count.toFloat / totalMutations.toFloat) * 100.0
  else 0.0
  { totalMutations := totalMutations
    contrastiveCount := count
    yieldRate := rate
    atomSubBotCount := pairs.filter (fun p => match p.mutationType with | .atomSubBot _ => true | _ => false) |>.length
    boxToDiamondCount := pairs.filter (fun p => match p.mutationType with | .boxToDiamond => true | _ => false) |>.length
    allFutureToSomeCount := pairs.filter (fun p => match p.mutationType with | .allFutureToSomeFuture => true | _ => false) |>.length
    allPastToSomeCount := pairs.filter (fun p => match p.mutationType with | .allPastToSomePast => true | _ => false) |>.length
    subformulaDeletionCount := pairs.filter (fun p => match p.mutationType with | .subformulaDeletion _ _ => true | _ => false) |>.length
    modalReductionCount := pairs.filter (fun p => match p.mutationType with | .modalDepthReduction => true | _ => false) |>.length
    temporalReductionCount := pairs.filter (fun p => match p.mutationType with | .temporalDepthReduction => true | _ => false) |>.length
    temporalDualityCount := pairs.filter (fun p => match p.mutationType with | .temporalDuality => true | _ => false) |>.length
    modalSwapCount := pairs.filter (fun p => p.mutationType.mutationFamily == "modal_swap") |>.length
    temporalSwapCount := pairs.filter (fun p => p.mutationType.mutationFamily == "temporal_swap") |>.length
    derivedSwapCount := pairs.filter (fun p => p.mutationType.mutationFamily == "derived_swap") |>.length
    structuralFlipCount := pairs.filter (fun p => p.mutationType.mutationFamily == "structural_flip") |>.length
    conjunctRemovalCount := pairs.filter (fun p => p.mutationType.mutationFamily == "conjunct_removal") |>.length
  }

/--
Print summary statistics in a human-readable format.
-/
def printContrastiveStats (stats : ContrastiveBatchStats) : IO Unit := do
  IO.println "\n=== Contrastive Pair Generation Summary ==="
  IO.println s!"Total mutations attempted: {stats.totalMutations}"
  IO.println s!"Contrastive pairs found: {stats.contrastiveCount}"
  IO.println s!"Yield rate: {stats.yieldRate}%"
  IO.println "\nBreakdown by legacy mutation type:"
  IO.println s!"  atom_sub_bot: {stats.atomSubBotCount}"
  IO.println s!"  box_to_diamond: {stats.boxToDiamondCount}"
  IO.println s!"  all_future_to_some: {stats.allFutureToSomeCount}"
  IO.println s!"  all_past_to_some: {stats.allPastToSomeCount}"
  IO.println s!"  subformula_deletion: {stats.subformulaDeletionCount}"
  IO.println s!"  modal_depth_reduction: {stats.modalReductionCount}"
  IO.println s!"  temporal_depth_reduction: {stats.temporalReductionCount}"
  IO.println s!"  temporal_duality: {stats.temporalDualityCount}"
  IO.println "\nBreakdown by single-occurrence mutation family:"
  IO.println s!"  modal_swap: {stats.modalSwapCount}"
  IO.println s!"  temporal_swap: {stats.temporalSwapCount}"
  IO.println s!"  derived_swap: {stats.derivedSwapCount}"
  IO.println s!"  structural_flip: {stats.structuralFlipCount}"
  IO.println s!"  conjunct_removal: {stats.conjunctRemovalCount}"

/--
Write per-mutation-family yield statistics to a JSON summary file.
-/
def writeYieldSummary (stats : ContrastiveBatchStats) (path : System.FilePath) : IO Unit := do
  let handle ← IO.FS.Handle.mk path .write
  let json := "{\"total_mutations\": " ++ toString stats.totalMutations
    ++ ", \"contrastive_count\": " ++ toString stats.contrastiveCount
    ++ ", \"yield_rate\": " ++ toString stats.yieldRate
    ++ ", \"families\": {"
    ++ "\"atom_sub\": " ++ toString stats.atomSubBotCount
    ++ ", \"modal_swap\": " ++ toString stats.modalSwapCount
    ++ ", \"global_weakening\": " ++ toString (stats.allFutureToSomeCount + stats.allPastToSomeCount)
    ++ ", \"subformula_deletion\": " ++ toString stats.subformulaDeletionCount
    ++ ", \"modal_depth_reduction\": " ++ toString stats.modalReductionCount
    ++ ", \"temporal_depth_reduction\": " ++ toString stats.temporalReductionCount
    ++ ", \"temporal_duality\": " ++ toString stats.temporalDualityCount
    ++ ", \"temporal_swap\": " ++ toString stats.temporalSwapCount
    ++ ", \"derived_swap\": " ++ toString stats.derivedSwapCount
    ++ ", \"structural_flip\": " ++ toString stats.structuralFlipCount
    ++ ", \"conjunct_removal\": " ++ toString stats.conjunctRemovalCount
    ++ "}}"
  handle.putStrLn json

/--
Run the contrastive pair generation pipeline over a pre-labeled corpus.

Takes a list of labeled formulas (e.g., from c5/c7 corpus), generates
contrastive pairs, writes them to JSONL, and exports yield statistics
to a separate JSON summary file.
-/
def runBatchContrastive (labeledFormulas : List LabeledFormula)
    (outputPath : System.FilePath)
    (summaryPath : System.FilePath) : IO Unit := do
  IO.println s!"Running batch contrastive on {labeledFormulas.length} labeled formulas..."
  let pairs ← generateBatchContrastive labeledFormulas
  let stats := computeContrastiveStats (pairs.length + (pairs.filter (·.mutatedLabel == .timeout)).length) pairs
  writeContrastiveJSONL pairs outputPath
  writeYieldSummary stats summaryPath
  printContrastiveStats stats
  IO.println s!"Output written to: {outputPath}"
  IO.println s!"Summary written to: {summaryPath}"

end Bimodal.Automation.FormulaMutator

/-!
## Standalone Executable Entry Point
-/

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Automation.FormulaMutator

/--
Configuration for the contrastive pair generator.
-/
structure ContrastiveConfig where
  /-- Maximum formula complexity for enumeration. -/
  maxComplexity : Nat := 5
  /-- Maximum modal depth for enumeration. -/
  maxModalDepth : Nat := 2
  /-- Maximum temporal depth for enumeration. -/
  maxTemporalDepth : Nat := 2
  /-- Maximum number of formulas to process. -/
  maxFormulas : Nat := 1000
  /-- Number of parallel threads for labeling (0 = sequential). -/
  parallelThreads : Nat := 0
  /-- Output JSONL file path. -/
  outputPath : String := "data/contrastive_pairs.jsonl"
  deriving Repr, Inhabited

/--
Parse CLI arguments into a `ContrastiveConfig`.
-/
def parseContrastiveArgs (args : List String) : ContrastiveConfig :=
  go args default
where
  go : List String → ContrastiveConfig → ContrastiveConfig
  | "--max-complexity" :: n :: rest, cfg =>
    go rest { cfg with maxComplexity := n.toNat! }
  | "--max-modal-depth" :: n :: rest, cfg =>
    go rest { cfg with maxModalDepth := n.toNat! }
  | "--max-temporal-depth" :: n :: rest, cfg =>
    go rest { cfg with maxTemporalDepth := n.toNat! }
  | "--max-formulas" :: n :: rest, cfg =>
    go rest { cfg with maxFormulas := n.toNat! }
  | "--parallel" :: n :: rest, cfg =>
    go rest { cfg with parallelThreads := n.toNat! }
  | "--output" :: p :: rest, cfg =>
    go rest { cfg with outputPath := p }
  | _ :: rest, cfg => go rest cfg
  | [], cfg => cfg

/--
Main entry point for the contrastive pair generator executable.

1. Parses CLI arguments
2. Enumerates formulas using FormulaEnumerator
3. Labels each formula via the decision procedure
4. Generates contrastive pairs from labeled formulas
5. Exports results to JSONL
6. Prints summary statistics
-/
def main (args : List String) : IO Unit := do
  let cfg := parseContrastiveArgs args
  IO.println "=== Contrastive Pair Generator ==="
  IO.println s!"Config: maxComplexity={cfg.maxComplexity}, maxModalDepth={cfg.maxModalDepth}, maxTemporalDepth={cfg.maxTemporalDepth}, maxFormulas={cfg.maxFormulas}"
  IO.println s!"Parallel threads: {cfg.parallelThreads}"
  IO.println s!"Output: {cfg.outputPath}"

  -- Step 1: Enumerate formulas
  IO.println "\n[Step 1] Enumerating formulas..."
  let params : EnumParams := {
    maxComplexity := cfg.maxComplexity
    maxModalDepth := cfg.maxModalDepth
    maxTemporalDepth := cfg.maxTemporalDepth
    maxFormulas := cfg.maxFormulas
    samplingMode := .exhaustive
  }
  let formulas ← generateFormulas params
  IO.println s!"  Generated {formulas.length} formulas"

  -- Step 2: Label formulas
  IO.println "\n[Step 2] Labeling formulas with decision procedure..."
  let labeled ← labelBatch formulas (parallelThreads := cfg.parallelThreads)
  let validCount := labeled.filter (·.label == .valid) |>.length
  let invalidCount := labeled.filter (·.label == .invalid) |>.length
  let timeoutCount := labeled.filter (·.label == .timeout) |>.length
  IO.println s!"  Valid: {validCount}, Invalid: {invalidCount}, Timeout: {timeoutCount}"

  -- Step 3: Generate contrastive pairs
  IO.println "\n[Step 3] Generating contrastive pairs..."
  let mut allPairsCount : Nat := 0
  let mut contrastivePairs : List ContrastivePair := []
  for lf in labeled do
    let pairs ← generateContrastivePairs lf
    allPairsCount := allPairsCount + pairs.length
    let filtered := filterContrastive pairs
    contrastivePairs := contrastivePairs ++ filtered
    if contrastivePairs.length % 100 == 0 && contrastivePairs.length > 0 then
      IO.println s!"  ... {contrastivePairs.length} contrastive pairs so far"

  -- Step 4: Export to JSONL
  IO.println s!"\n[Step 4] Exporting {contrastivePairs.length} contrastive pairs to JSONL..."
  writeContrastiveJSONL contrastivePairs cfg.outputPath

  -- Step 5: Print summary
  let stats := computeContrastiveStats allPairsCount contrastivePairs
  printContrastiveStats stats
  IO.println s!"\nOutput written to: {cfg.outputPath}"
