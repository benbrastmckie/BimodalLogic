/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.ProofExtraction
import FormalSystem.Metalogic.Decidability.CountermodelExtraction
import FormalSystem.Metalogic.Decidability.TraceCertificate
import FormalSystem.Automation.ProofSearch.Strategies
import FormalSystem.Automation.Normalization

/-!
# Decision Procedure for TM Bimodal Logic

This module provides the main decision procedure for TM bimodal logic validity.
The procedure decides whether a formula is valid, returning either:
- A proof term (`DerivationTree`) if valid
- A countermodel description if invalid

## Main Definitions

- `DecisionResult`: Sum type of proof or countermodel
- `decide`: Main decision function
- `isValid`, `isSatisfiable`: Boolean convenience functions

## Algorithm Overview

1. **Optimization**: First try direct proof search for shallow proofs
2. **Tableau**: Build tableau for F(φ) (asserting φ is false)
3. **Analysis**:
   - All branches close → φ is valid, extract proof
   - Open saturated branch → φ is invalid, extract countermodel

## Complexity

- Time: O(2^n) where n = formula complexity (PSPACE-complete)
- Space: O(n) for DFS-based tableau expansion
- Typical formulas: Much faster due to pruning and optimization

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Automation

/-!
## Decision Result Type
-/

/--
Result of the decision procedure for a formula.

- `valid`: Formula is valid, with a proof term
- `invalid`: Formula is invalid, with a countermodel description
- `fuelExhausted`: Tableau construction ran out of fuel — validity genuinely undetermined
- `extractionFailed`: Tableau closed (so the formula *is* valid) but no proof term
  could be reconstructed

**Why `timeout` was split (R7).** The former single `timeout` constructor conflated two
situations that are not epistemically alike. `buildTableau` returning `none` leaves validity
open: nothing was decided. `buildTableau` returning `.allClosed` while `extractProof` returns
`.incomplete` is *not* undecided — every branch of the tableau closed, which is exactly the
tableau-level witness of validity; only the *proof-term reconstruction* failed. Reporting the
second as a timeout made the procedure claim ignorance about formulas it had in fact refuted
the negation of, and it made `decide_result_exclusive` unable to state that a closed tableau
is never reported undecided. The two are now distinct constructors, and `isUndecided` holds
of `fuelExhausted` only.
-/
inductive DecisionResult (φ : Formula) : Type where
  /-- Formula is valid, witnessed by a derivation tree. -/
  | valid (proof : ⊢ φ)
  /-- Formula is invalid, witnessed by a countermodel description. -/
  | invalid (counter : SimpleCountermodel)
  /-- Tableau fuel was exhausted before any verdict: validity is undetermined. -/
  | fuelExhausted
  /-- The tableau closed on every branch (the formula is valid) but proof-term
  extraction was incomplete, so no `⊢ φ` witness is available. -/
  | extractionFailed
  deriving Repr

namespace DecisionResult

variable {φ : Formula}

/-- Check if result indicates validity. -/
def isValid : DecisionResult φ → Bool
  | valid _ => true
  | _ => false

/-- Check if result indicates invalidity. -/
def isInvalid : DecisionResult φ → Bool
  | invalid _ => true
  | _ => false

/-- Check if the tableau ran out of fuel. -/
def isFuelExhausted : DecisionResult φ → Bool
  | fuelExhausted => true
  | _ => false

/-- Check if the tableau closed but proof extraction failed. -/
def isExtractionFailed : DecisionResult φ → Bool
  | extractionFailed => true
  | _ => false

/--
Check if the result leaves validity genuinely undetermined.

Only `fuelExhausted` qualifies: `extractionFailed` means the tableau closed, so the formula
is valid even though no proof term was reconstructed. This is the honest-reporting half of
R7 — a closed tableau is never reported as undecided.
-/
def isUndecided : DecisionResult φ → Bool
  | fuelExhausted => true
  | _ => false

/--
Check if the run established validity, whether or not a proof term was recovered.

True for `valid` (term in hand) and `extractionFailed` (closed tableau, no term).
-/
def isKnownValid : DecisionResult φ → Bool
  | valid _ => true
  | extractionFailed => true
  | _ => false

/-- Get the proof if valid. -/
def getProof? : DecisionResult φ → Option (⊢ φ)
  | valid proof => some proof
  | _ => none

/-- Get the countermodel if invalid. -/
def getCountermodel? : DecisionResult φ → Option SimpleCountermodel
  | invalid cm => some cm
  | _ => none

end DecisionResult

/-!
## Main Decision Procedure
-/

/--
Decide validity of a TM bimodal logic formula.

**Algorithm**:
1. Try direct axiom proof (fast path for axiom instances)
2. Try proof search with limited depth (fast for shallow proofs)
3. Build tableau starting with F(φ)
4. If all branches close: valid, try to extract proof
5. If open branch found: invalid, extract countermodel

**Parameters**:
- `φ`: Formula to decide
- `searchDepth`: Maximum depth for initial proof search (default 10)
- `tableauFuel`: Maximum steps for tableau expansion (default 1000)

**Returns**:
- `valid proof`: Formula is valid with proof term
- `invalid counter`: Formula is invalid with countermodel
- `fuelExhausted`: Tableau fuel ran out before any verdict
- `extractionFailed`: Tableau closed (formula valid) but no proof term recovered
-/
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    (fc : FrameClass := .Base) : DecisionResult φ :=
  -- Normalize formula to primitive constructors before decision.
  -- normalizeFormula is definitionally the identity (all derived operators are
  -- `def` abbreviations), so this is a no-op at runtime. It serves as a
  -- documented normalization contract and future-proofing guard.
  -- We use the identity theorem to cast the result back to the original type.
  have h_norm : Automation.Normalization.normalizeFormula φ = φ :=
    Automation.Normalization.normalizeFormula_id φ
  let φ_n := Automation.Normalization.normalizeFormula φ
  -- Fast path: direct axiom proof
  match tryAxiomProof φ_n with
  | some proof => .valid (h_norm ▸ proof)
  | none =>
    -- Fast path: compositional proof (box-valid patterns)
    match buildCompositionalProof φ_n 10 with
    | some proof => .valid (h_norm ▸ proof)
    | none =>
    -- Try proof search (fast for simple proofs)
    match boundedSearchWithProof [] φ_n searchDepth with
    | (some proof, _, _) => .valid (h_norm ▸ proof)
    | (none, _, _) =>
      -- Fall back to tableau method
      match buildTableau φ_n tableauFuel fc with
      | none => .fuelExhausted
      | some tableau =>
          match tableau with
          | .allClosed _ =>
              -- Formula is valid, use full extraction pipeline
              match extractProof φ_n tableau fc with
              | .success proof => .valid (h_norm ▸ proof)
              | .incomplete _ =>
                  -- The tableau closed, so the formula IS valid; only the proof-term
                  -- reconstruction failed. Reporting this as a timeout (the pre-R7
                  -- behaviour) claimed the procedure was undecided about a formula it
                  -- had in fact settled.
                  .extractionFailed
          | .hasOpen openBranch _ord _fc hSat =>
              -- Formula is invalid, extract countermodel
              .invalid (extractCountermodelSimple φ_n openBranch hSat)

/-!
## Blocking-Aware Decision Entry

`decide` above consumes `buildTableau`, whose open certificate carries the *literal* saturation
test `findUnexpanded … = none`. On a blocking engine that test is unreachable for exactly the
formulas whose refutation needs blocking: work remains outstanding at times a saturated ancestor
blocks, so `buildTableau` returns `none` and `decide` reports `.fuelExhausted` for a formula it
has in fact refuted.

`decideBlocking` is the complement. It consumes `buildTableauAt`, whose `hasOpen` carries the
engine's *real* saturation test relative to a named blocked set, so those formulas can be
reported `.invalid` on the certificate the engine can actually produce.

**It is a complement, not a substitute.** `decide` is untouched, still calls `buildTableau`, and
nothing routes through this entry that did not ask for it. And it does not by itself rescue a
formula whose branch never reaches blocking-aware saturation either — that is what
`trivialEventWitnessed` in `Tableau.lean` is for; without that guard `expandBranchWithFuel`
returns `none` and `buildTableauAt` returns `none` here just as `buildTableau` does above.

**No free path to the strong certificate.** The closed arm reaches `ExpandedTableau` only through
`BudgetedTableau.upgrade`; the open arm never reaches `ExpandedTableau` at all. In particular no
`ExpandedTableau.hasOpen` is constructed here, so `upgrade_hasOpen_isSome_iff` remains the only
route from `BudgetedTableau.hasOpen` to `ExpandedTableau.hasOpen`.
-/

/--
Extract a simple countermodel from an open **blocking-aware** saturated branch.

The blocking-aware analogue of `extractCountermodelSimple`: identical extraction, keyed on the
certificate `BudgetedTableau.hasOpen` actually carries
(`findUnexpandedUnblockedWith … (blockedTimes … tracker) = none`) rather than on the literal
`findUnexpanded … = none`. Stating the witness rather than dropping it is what keeps the two
extraction entries distinguishable at their call sites: a reader can see from the signature which
saturation notion the branch was certified against.

This is deliberately *not* routed through `extractCountermodelSimple`, because doing so would
require manufacturing the literal saturation proof this branch does not have.
-/
def extractCountermodelBlocked (φ : Formula) (b : Branch)
    {ord : TimeOrdering} {fc : FrameClass} {tracker : EventualityTracker}
    (_hSaturated : findUnexpandedUnblockedWith b ord fc
      (blockedTimes b ord fc tracker) = none)
    : SimpleCountermodel :=
  extractSimpleCountermodel φ b

/--
Decide validity of a TM bimodal logic formula through the blocking-aware tableau entry.

Arm for arm this is `decide`, with exactly two differences, both forced:

1. The tableau call is `buildTableauAt φ_n tableauFuel fc maxBranches` rather than
   `buildTableau φ_n tableauFuel fc`, so the branch budget is named rather than left at the
   engine default, and the open certificate is blocking-aware.
2. The open arm extracts through `extractCountermodelBlocked`, which consumes the blocking-aware
   witness the certificate carries.

The fast paths (axiom instance, compositional proof, bounded search) are unchanged and are
reached in the same order, so a formula either entry settles early is settled identically by
both.

**Parameters**: as `decide`, plus `maxBranches` (default `50000`, the engine's own default in
`expandBranchWithFuel`), so that `decideBlocking φ` at default arguments and `decide φ` at
default arguments run at the same budget and differ only in the certificate they demand.

**Returns**: as `decide`. `.fuelExhausted` here means fuel or branch budget ran out before
*blocking-aware* saturation, which is a strictly weaker demand than the one `decide` reports
`.fuelExhausted` against.
-/
def decideBlocking (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    (fc : FrameClass := .Base) (maxBranches : Nat := 50000) : DecisionResult φ :=
  have h_norm : Automation.Normalization.normalizeFormula φ = φ :=
    Automation.Normalization.normalizeFormula_id φ
  let φ_n := Automation.Normalization.normalizeFormula φ
  match tryAxiomProof φ_n with
  | some proof => .valid (h_norm ▸ proof)
  | none =>
    match buildCompositionalProof φ_n 10 with
    | some proof => .valid (h_norm ▸ proof)
    | none =>
    match boundedSearchWithProof [] φ_n searchDepth with
    | (some proof, _, _) => .valid (h_norm ▸ proof)
    | (none, _, _) =>
      match buildTableauAt φ_n tableauFuel fc maxBranches with
      | none => .fuelExhausted
      | some (.allClosed cs) =>
          -- Cross the bridge. `upgrade` is the only path to the strong certificate, and
          -- `allClosed` is the arm it crosses unconditionally.
          match hup : (BudgetedTableau.allClosed cs).upgrade with
          | some tableau =>
              match extractProof φ_n tableau fc with
              | .success proof => .valid (h_norm ▸ proof)
              | .incomplete _ =>
                  -- As in `decide`: the tableau closed, so the formula IS valid; only the
                  -- proof-term reconstruction failed.
                  .extractionFailed
          | none =>
              -- Dead by `upgrade_allClosed`. Discharged, not guessed at: emitting any verdict
              -- here would be a heuristic one.
              absurd hup (by simp)
      | some (.hasOpen openBranch _ord _fc _tracker hSatBlocked) =>
          -- Blocking-aware saturated and open: invalid on the certificate the engine produced.
          .invalid (extractCountermodelBlocked φ_n openBranch hSatBlocked)

/--
Simplified decision: just return whether formula is valid.
-/
def isValid (φ : Formula) (fc : FrameClass := .Base) : Bool :=
  (decide φ (fc := fc)).isValid

/--
Check if a formula is satisfiable (its negation is not valid).
-/
def isSatisfiable (φ : Formula) (fc : FrameClass := .Base) : Bool :=
  ¬isValid φ.neg fc

/--
Decide with automatic fuel, using `soundFuel` (from subformula closure cardinality) instead of the
ad-hoc `recommendedFuel` heuristic.

**What termination means here.** `decideAuto` terminates on every input because it is a total
function called at a finite fuel figure: every path through `decide` returns a `DecisionResult`,
and `.fuelExhausted` is one of the four constructors it may return. No theorem rules
`.fuelExhausted` out, and this docstring does not claim one does.

**What is actually bounded, and under which hypotheses.** The expansion `decideAuto` drives is
proved total only under stated hypotheses:
`expandBranchWithFuel_isSome_of_stock` (`Verified/Termination/Fuel.lean`) gives
`(expandBranchWithFuel …).isSome` from three hypothesis families together — no splitting
(`NoSplit P fc`), a confined formula stock `C` and label set `L`, fuel exceeding
`2 * C.card * L.card`, and a branch budget accommodating that fuel
(`branchesUsed + fuel ≤ maxBranches`). It is derived from
`expandBranchWithFuel_isSome_of_noSplit`, which takes the same shape against an arbitrary finite
signed universe. None of these hypotheses is discharged by `decideAuto` itself.

**Where `soundFuel` sits relative to the justified figure.** `soundFuel φ` is
`min (n * 2 ^ n) 100000` — a *capped* runtime default. `soundFuel_le_soundFuel'`
(`Verified/Termination/Fuel.lean`) proves it is dominated by the uncapped `soundFuel' φ`, and
`soundFuel'` is itself justified only in the single-world dimension: `chain_le_soundFuel'` reaches
it under a hypothesis `hL` confining the label count to the T2 *time* figure, which its own
docstring records as not dischargeable once any `boxNeg` or `diamondPos` fires. The figure that
takes the world dimension as a dimension is `chain_le_worlds_bounded` / `worldFuel'`.

**Subset blocking is a measured behaviour, not a universal guarantee.** `Fuel.lean` evaluates
`buildTableau ((G p) → □(G p)) n .Base` across `n ∈ [0, 40]` and beyond: `none` for every
`n ≤ 24`, and `hasOpen` with a stationary 40-formula certified open branch for every `n ≥ 25` —
a measured ceiling roughly 82× below `soundFuel φ` at that formula. That is an empirical witness
for one `φ`, and is recorded as such rather than quantified over all formulas.
-/
def decideAuto (φ : Formula) (fc : FrameClass := .Base) : DecisionResult φ :=
  let fuel := soundFuel φ
  let depth := 5 + φ.complexity / 2
  decide φ depth fuel fc

/--
Single-tier fuel strategy with fuel=500. Returns the result and a tag
indicating the fuel tier used (for logging and dataset labeling).

Analysis across c3-c8 confirmed a strictly bimodal decision
landscape: formulas either resolve at fuel=500 or not at all. Zero
formulas across all complexity levels resolved at the former tiers of
2000 or 10000, making the multi-tier escalation dead code. The remaining
timeouts are structural patterns handled by a pre-filter in `labelFormula`.

Returns `(result, fuelTierUsed)` where fuelTierUsed is:
- `"adaptive_500"` for decided formulas
- `"adaptive_timeout"` if fuel exhausted
- `"adaptive_extraction_failed"` if the tableau closed but no proof term was recovered
-/
def decideAutoAdaptive (φ : Formula) (fc : FrameClass := .Base)
    (fuel : Nat := 500)
    : DecisionResult φ × String :=
  let depth := 5 + φ.complexity / 2
  match decide φ depth fuel fc with
  | .fuelExhausted => (.fuelExhausted, "adaptive_timeout")
  | .extractionFailed => (.extractionFailed, "adaptive_extraction_failed")
  | result => (result, s!"adaptive_{fuel}")

/-!
## Batch Decision
-/

/--
Result of batch decision with statistics.
-/
structure BatchDecisionResult where
  /-- Number of formulas decided valid. -/
  validCount : Nat
  /-- Number of formulas decided invalid. -/
  invalidCount : Nat
  /-- Number of formulas left undecided by fuel exhaustion. -/
  timeoutCount : Nat
  /-- Number of formulas whose tableau closed but whose proof term could not be
  reconstructed. These are valid; they are counted apart from `timeoutCount` so a closed
  tableau is never reported as undecided (R7). -/
  extractionFailedCount : Nat
  /-- Total formulas processed. -/
  totalCount : Nat
  deriving Repr, Inhabited

/--
Decide a batch of formulas, collecting statistics.
-/
def decideBatch (formulas : List Formula) (fuel : Nat := 1000)
    (fc : FrameClass := .Base) : BatchDecisionResult :=
  formulas.foldl (fun acc φ =>
    let result := decide φ 10 fuel fc
    { acc with
      validCount := acc.validCount + (if result.isValid then 1 else 0)
      invalidCount := acc.invalidCount + (if result.isInvalid then 1 else 0)
      timeoutCount := acc.timeoutCount + (if result.isUndecided then 1 else 0)
      extractionFailedCount :=
        acc.extractionFailedCount + (if result.isExtractionFailed then 1 else 0)
      totalCount := acc.totalCount + 1
    }
  ) { validCount := 0, invalidCount := 0, timeoutCount := 0, extractionFailedCount := 0,
      totalCount := 0 }

/-!
## Integration with Proof Search
-/

/--
Combined decision procedure using both tableau and proof search.

For formulas that are provable, this tries to return the shortest proof
by comparing tableau-derived proofs with proof search results.
-/
def decideOptimized (φ : Formula) (fc : FrameClass := .Base) : DecisionResult φ :=
  -- First, quick check with IDDFS
  let (found, _, _, _, _) := search [] φ (.IDDFS 20)
  if found then
    -- Found provable, get the proof term
    match boundedSearchWithProof [] φ 20 with
    | (some proof, _, _) => .valid proof
    | (none, _, _) =>
        -- Couldn't construct proof term, fall back to decide
        decide φ (fc := fc)
  else
    -- Not immediately provable, use full decision procedure
    decide φ (fc := fc)

/-!
## Convenience Functions
-/

/--
Check if a formula is a tautology (valid in propositional sense).
For TM logic, this is just validity check.
-/
def isTautology (φ : Formula) (fc : FrameClass := .Base) : Bool := isValid φ fc

/--
Check if a formula is a contradiction (negation is valid).
-/
def isContradiction (φ : Formula) (fc : FrameClass := .Base) : Bool := isValid φ.neg fc

/--
Check if a formula is contingent (neither valid nor contradictory).
-/
def isContingent (φ : Formula) (fc : FrameClass := .Base) : Bool :=
  ¬isValid φ fc ∧ ¬isContradiction φ fc

/-!
## Display Functions
-/

/--
Display the decision result as a human-readable string.
-/
def DecisionResult.display {φ : Formula} : DecisionResult φ → String
  | .valid proof => s!"Valid (proof height: {proof.height})"
  | .invalid _ => s!"Invalid (countermodel found)"
  | .fuelExhausted => "Undecided (tableau fuel exhausted)"
  | .extractionFailed => "Valid (tableau closed); proof term not reconstructed"

/-!
## Trace-Instrumented Decision Procedure

The functions below mirror `decide` and `decideAuto` but additionally
return a `TraceResult` carrying a full `ProofCertificate` with all rule
firings, branch closures, blocking events, and fuel-exhaustion events
recorded during the tableau expansion.

The original `decide` and `decideAuto` are preserved unchanged. The
traced versions call `expandBranchWithFuelTraced` (a `StateM` wrapper
around `expandBranchWithFuel`) to gather the trace, then post-process
the certificate to fill in `outcome`, `branchingFactor`, and `maxDepth`.
-/

/--
Compute the average branching factor over all `branchCreated` events
in a trace.

Returns `1.0` if there are no `branchCreated` events (degenerate case
where no branching occurred).
-/
def computeBranchingFactor (trace : List TraceEntry) : Float :=
  let branchEvents := trace.filter fun e =>
    match e with
    | .branchCreated _ _ _ _ => true
    | _ => false
  if branchEvents.isEmpty then
    1.0
  else
    -- Each branchCreated event represents one new branch, so the
    -- average branching factor is the total number of new branches
    -- divided by the number of split operations. Since we don't track
    -- splits separately, we just count the events.
    Float.ofNat branchEvents.length

/--
Finalize a `ProofCertificate` by:
- Reversing the trace (events are stored prepended; chronological order
  has oldest first).
- Setting the outcome based on the result.
- Computing `branchingFactor` from the trace.
- Pre-computing `maxDepth` (already maintained incrementally).
-/
def finalizeCertificate (cert : ProofCertificate)
    (outcome : CertOutcome) (trace : List TraceEntry)
    : ProofCertificate :=
  { cert with
    trace := trace.reverse
    outcome := outcome
    branchingFactor := computeBranchingFactor trace }

/--
Run the trace-instrumented decision procedure on a formula.

Returns a `TraceResult`:
- `.success cert` — the decision completed and a full certificate is returned.
- `.failure (.outOfFuel trace steps)` — fuel was exhausted; the partial
  trace is returned for post-mortem analysis.

**Parameters**:
- `φ`: Formula to decide.
- `fuel`: Maximum number of tableau expansion steps.

**Returns**: A `TraceResult` with the full `ProofCertificate`.
-/
def decideWithTrace (φ : Formula) (fuel : Nat := 500)
    (fc : FrameClass := .Base) : TraceResult :=
  let initialCert := ProofCertificate.empty φ fc
  let initialBranch : Branch := [SignedFormula.neg φ Label.initial]
  let (result, tracedCert) := expandBranchWithFuelTraced initialBranch fuel fc initialCert
  match result with
  | none =>
      -- Fuel exhausted; return failure with partial trace
      .failure (.outOfFuel tracedCert.trace tracedCert.totalSteps)
  | some (.inl _) =>
      -- All branches closed: formula is valid
      let finalized := finalizeCertificate tracedCert .validProof tracedCert.trace
      .success finalized
  | some (.inr _) =>
      -- Open saturated branch found: formula is invalid (countermodel)
      let finalized := finalizeCertificate tracedCert .countermodel tracedCert.trace
      .success finalized

/--
Adaptive trace-instrumented decision procedure.

Uses `soundFuel` (from subformula closure cardinality) as the fuel bound,
combined with a depth proportional to formula complexity.
-/
def decideAutoWithTrace (φ : Formula) (fc : FrameClass := .Base) : TraceResult :=
  let fuel := soundFuel φ
  decideWithTrace φ fuel fc

end FormalSystem.Metalogic.Decidability
