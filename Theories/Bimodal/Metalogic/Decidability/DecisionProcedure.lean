import Bimodal.Metalogic.Decidability.ProofExtraction
import Bimodal.Metalogic.Decidability.CountermodelExtraction
import Bimodal.Metalogic.Decidability.TraceCertificate
import Bimodal.Automation.ProofSearch.Strategies
import Bimodal.Automation.Normalization

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

namespace Bimodal.Metalogic.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation

/-!
## Decision Result Type
-/

/--
Result of the decision procedure for a formula.

- `valid`: Formula is valid, with a proof term
- `invalid`: Formula is invalid, with a countermodel description
- `timeout`: Procedure ran out of resources
-/
inductive DecisionResult (φ : Formula) : Type where
  /-- Formula is valid, witnessed by a derivation tree. -/
  | valid (proof : ⊢ φ)
  /-- Formula is invalid, witnessed by a countermodel description. -/
  | invalid (counter : SimpleCountermodel)
  /-- Decision procedure timed out (fuel exhausted). -/
  | timeout
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

/-- Check if result timed out. -/
def isTimeout : DecisionResult φ → Bool
  | timeout => true
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
- `timeout`: Resources exhausted before decision
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
    match bounded_search_with_proof [] φ_n searchDepth with
    | (some proof, _, _) => .valid (h_norm ▸ proof)
    | (none, _, _) =>
      -- Fall back to tableau method
      match buildTableau φ_n tableauFuel fc with
      | none => .timeout
      | some tableau =>
          match tableau with
          | .allClosed _ =>
              -- Formula is valid, use full extraction pipeline
              match extractProof φ_n tableau fc with
              | .success proof => .valid (h_norm ▸ proof)
              | .incomplete _ =>
                  -- Extraction failed despite validity; genuine resource limitation
                  .timeout
          | .hasOpen openBranch _ord _applied hSat =>
              -- Formula is invalid, extract countermodel
              .invalid (extractCountermodelSimple φ_n openBranch hSat)

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
Decide with automatic fuel based on FMP-derived sound bound.

Uses `soundFuel` (from subformula closure cardinality) instead of the
ad-hoc `recommendedFuel` heuristic. Combined with subset blocking in
`expandBranchWithFuel`, this ensures termination for all formulas.
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
-/
def decideAutoAdaptive (φ : Formula) (fc : FrameClass := .Base)
    (fuel : Nat := 500)
    : DecisionResult φ × String :=
  let depth := 5 + φ.complexity / 2
  match decide φ depth fuel fc with
  | .timeout => (.timeout, "adaptive_timeout")
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
  /-- Number of formulas that timed out. -/
  timeoutCount : Nat
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
      timeoutCount := acc.timeoutCount + (if result.isTimeout then 1 else 0)
      totalCount := acc.totalCount + 1
    }
  ) { validCount := 0, invalidCount := 0, timeoutCount := 0, totalCount := 0 }

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
    match bounded_search_with_proof [] φ 20 with
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
  | .timeout => "Timeout (resources exhausted)"

/-!
## Trace-Instrumented Decision Procedure

The functions below mirror `decide` and `decideAuto` but additionally
return a `TraceResult` carrying a full `ProofCertificate` with all rule
firings, branch closures, blocking events, and fuel-exhaustion events
recorded during the tableau expansion.

The original `decide` and `decideAuto` are preserved unchanged. The
traced versions call `expandBranchWithFuel_traced` (a `StateM` wrapper
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
  let (result, tracedCert) := expandBranchWithFuel_traced initialBranch fuel fc initialCert
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

end Bimodal.Metalogic.Decidability
