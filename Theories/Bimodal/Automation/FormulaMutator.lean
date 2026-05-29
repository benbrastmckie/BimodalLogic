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
-/
def weakenAllToSome : Formula → Formula
  | φ@(.imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot) =>
    -- This is G(inner), weaken to F(inner)
    match matchAllFuture φ with
    | some innerFormula => Formula.some_future (weakenAllToSome innerFormula)
    | none => φ  -- should not happen given the pattern match above
  | φ@(.imp (.snce (.imp inner .bot) (.imp .bot .bot)) .bot) =>
    -- This is H(inner), weaken to P(inner)
    match matchAllPast φ with
    | some innerFormula => Formula.some_past (weakenAllToSome innerFormula)
    | none => φ  -- should not happen given the pattern match above
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
  | φ@(.imp (.untl (.imp _ .bot) (.imp .bot .bot)) .bot) => matchAllFuture φ |>.isSome
  | .imp ψ χ => hasAllFuture ψ || hasAllFuture χ
  | .box ψ => hasAllFuture ψ
  | .untl ψ χ => hasAllFuture ψ || hasAllFuture χ
  | .snce ψ χ => hasAllFuture ψ || hasAllFuture χ
  | _ => false

/--
Check whether a formula contains any H (all_past) patterns.
-/
def hasAllPast : Formula → Bool
  | φ@(.imp (.snce (.imp _ .bot) (.imp .bot .bot)) .bot) => matchAllPast φ |>.isSome
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
-/
def generateMutations (φ : Formula) : List (Formula × MutationType) :=
  let atomMutations := φ.atoms.toList.map fun a =>
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
  -- Combine all mutations, dedup by mutated formula
  let allMutations := atomMutations ++ boxMutation ++ gMutation ++ hMutation
    ++ subDeletions ++ modalReduction ++ temporalReduction ++ dualityMutation
  -- Filter out mutations that produce the same formula as the original
  allMutations.filter fun (m, _) => m != φ

/-!
## Contrastive Pair Generation Pipeline
-/

/--
Run the decision procedure on a mutated formula and construct a contrastive pair.

Uses `decideAuto` (with fallback to `decideOptimized` on timeout) to classify
the mutated formula. If the mutation is invalid, also extracts an enriched
countermodel for richer corrective signal.
-/
def classifyMutation (original : Formula) (originalLabel : FormulaLabel)
    (originalProofTrace : Option ProofTrace)
    (mutated : Formula) (mutationType : MutationType) : IO ContrastivePair := do
  let result := decideAuto mutated
  match result with
  | .valid _ =>
    return {
      original := original
      originalLabel := originalLabel
      mutated := mutated
      mutatedLabel := .valid
      mutationType := mutationType
      countermodel := none
      enrichedCountermodel := none
      originalProofTrace := originalProofTrace
    }
  | .invalid cm =>
    -- Also try to get enriched countermodel
    let ecm := match findEnrichedCountermodel mutated with
      | .found e => some e
      | _ => none
    return {
      original := original
      originalLabel := originalLabel
      mutated := mutated
      mutatedLabel := .invalid
      mutationType := mutationType
      countermodel := some cm
      enrichedCountermodel := ecm
      originalProofTrace := originalProofTrace
    }
  | .timeout =>
    -- Retry with decideOptimized
    let retryResult := decideOptimized mutated
    match retryResult with
    | .valid _ =>
      return {
        original := original
        originalLabel := originalLabel
        mutated := mutated
        mutatedLabel := .valid
        mutationType := mutationType
        countermodel := none
        enrichedCountermodel := none
        originalProofTrace := originalProofTrace
      }
    | .invalid cm =>
      let ecm := match findEnrichedCountermodel mutated with
        | .found e => some e
        | _ => none
      return {
        original := original
        originalLabel := originalLabel
        mutated := mutated
        mutatedLabel := .invalid
        mutationType := mutationType
        countermodel := some cm
        enrichedCountermodel := ecm
        originalProofTrace := originalProofTrace
      }
    | .timeout =>
      return {
        original := original
        originalLabel := originalLabel
        mutated := mutated
        mutatedLabel := .timeout
        mutationType := mutationType
        countermodel := none
        enrichedCountermodel := none
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

/--
Serialize a `ContrastivePair` to a JSON object string.

Produces the full JSON record including original formula/AST/label,
mutated formula/AST/label, countermodel, enriched countermodel,
mutation type and detail.
-/
def ContrastivePair.toJson (cp : ContrastivePair) : String :=
  let originalStr := "{\"formula_str\": \"" ++ escapeJsonString cp.original.prettyPrint
    ++ "\", \"formula_ast\": " ++ cp.original.toJson
    ++ ", \"label\": " ++ cp.originalLabel.toJson
    ++ ", \"proof_trace\": " ++ match cp.originalProofTrace with
      | some pt => pt.toJson
      | none => "null"
    ++ "}"
  let mutatedStr := "{\"formula_str\": \"" ++ escapeJsonString cp.mutated.prettyPrint
    ++ "\", \"formula_ast\": " ++ cp.mutated.toJson
    ++ ", \"label\": " ++ cp.mutatedLabel.toJson
    ++ ", \"countermodel\": " ++ match cp.countermodel with
      | some cm => cm.toJson
      | none => "null"
    ++ ", \"enriched_countermodel\": " ++ match cp.enrichedCountermodel with
      | some ecm => ecm.toJson
      | none => "null"
    ++ "}"
  "{\"original\": " ++ originalStr
    ++ ", \"mutation\": " ++ mutatedStr
    ++ ", \"mutation_type\": " ++ cp.mutationType.toJson
    ++ ", \"mutation_detail\": " ++ cp.mutationType.detailJson
    ++ "}"

/-!
## JSONL Export
-/

/--
Write a list of contrastive pairs to a JSONL file.

Each pair is written as a single JSON line with an auto-incrementing ID.
-/
def writeContrastiveJSONL (pairs : List ContrastivePair)
    (path : System.FilePath) : IO Unit := do
  let handle ← IO.FS.Handle.mk path .write
  let mut idx : Nat := 1
  for cp in pairs do
    let idStr := s!"\"contrastive-{String.mk (Nat.toDigits 10 idx |>.map fun d => Char.ofNat (d + 48))}\"".replace "\"" ""
    let paddedId := String.mk ("0" ++ Nat.toDigits 10 idx |>.map fun d => Char.ofNat (d + 48)).toList
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
  /-- Breakdown by mutation type. -/
  atomSubBotCount : Nat
  boxToDiamondCount : Nat
  allFutureToSomeCount : Nat
  allPastToSomeCount : Nat
  subformulaDeletionCount : Nat
  modalReductionCount : Nat
  temporalReductionCount : Nat
  temporalDualityCount : Nat
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
  }

/--
Print summary statistics in a human-readable format.
-/
def printContrastiveStats (stats : ContrastiveBatchStats) : IO Unit := do
  IO.println "\n=== Contrastive Pair Generation Summary ==="
  IO.println s!"Total mutations attempted: {stats.totalMutations}"
  IO.println s!"Contrastive pairs found: {stats.contrastiveCount}"
  IO.println s!"Yield rate: {stats.yieldRate}%"
  IO.println "\nBreakdown by mutation type:"
  IO.println s!"  atom_sub_bot: {stats.atomSubBotCount}"
  IO.println s!"  box_to_diamond: {stats.boxToDiamondCount}"
  IO.println s!"  all_future_to_some: {stats.allFutureToSomeCount}"
  IO.println s!"  all_past_to_some: {stats.allPastToSomeCount}"
  IO.println s!"  subformula_deletion: {stats.subformulaDeletionCount}"
  IO.println s!"  modal_depth_reduction: {stats.modalReductionCount}"
  IO.println s!"  temporal_depth_reduction: {stats.temporalReductionCount}"
  IO.println s!"  temporal_duality: {stats.temporalDualityCount}"

/-!
## Standalone Executable Entry Point
-/

/--
Parse command-line arguments for the contrastive generator.
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
  /-- Output JSONL file path. -/
  outputPath : String := "data/contrastive_pairs.jsonl"
  deriving Repr

/--
Parse CLI arguments into a `ContrastiveConfig`.
-/
def parseArgs (args : List String) : ContrastiveConfig :=
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
def main : IO Unit := do
  let args ← IO.getArgs
  let cfg := parseArgs args
  IO.println "=== Contrastive Pair Generator ==="
  IO.println s!"Config: maxComplexity={cfg.maxComplexity}, maxModalDepth={cfg.maxModalDepth}, maxTemporalDepth={cfg.maxTemporalDepth}, maxFormulas={cfg.maxFormulas}"
  IO.println s!"Output: {cfg.outputPath}"

  -- Step 1: Enumerate formulas
  IO.println "\n[Step 1] Enumerating formulas..."
  let atoms := [Atom.mk_base "p", Atom.mk_base "q"]
  let formulas := FormulaEnumerator.enumerateFormulas atoms cfg.maxComplexity
    cfg.maxModalDepth cfg.maxTemporalDepth
  let formulaList := formulas.toList.take cfg.maxFormulas
  IO.println s!"  Generated {formulaList.length} formulas"

  -- Step 2: Label formulas
  IO.println "\n[Step 2] Labeling formulas with decision procedure..."
  let labeled ← labelBatch formulaList
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

end Bimodal.Automation.FormulaMutator
