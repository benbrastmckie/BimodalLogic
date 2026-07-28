/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax
import FormalSystem.ProofSystem
import FormalSystem.Metalogic.Decidability.SignedFormula
import FormalSystem.Metalogic.Decidability.Closure

/-!
# Trace Certificates for Tableau Rule Firings

This module defines the data types for instrumenting the tableau decision
procedure with rule-firing trace certificates. Every rule application during
proof search is recorded as a `TraceEntry` mirroring the Libal & Volpe
FPC schema `(precondition, rule, conclusion, branch_id)`. The certificate
is threaded through `expandBranchWithFuel` as a pure `StateM` layer so
that the existing termination/soundness proofs in `Saturation.lean`
remain valid.

## Main Definitions

- `TraceEntry` — A single trace event for a tableau rule firing.
- `CertOutcome` — Outcome classification (valid, countermodel, timeout, blocked).
- `ProofCertificate` — Aggregate certificate collecting all trace events.
- `ProofCertificate.empty` — Empty certificate for a given formula and frame class.
- `TraceFailure` — Failure with preserved partial trace.
- `TraceResult` — Sum type: success or failure with partial trace.

## References

* Libal & Volpe (2016) "Certification of Prefixed Tableau Proofs for Modal Logic"
  (GandALF/EPTCS 226, pp. 257–271) — FPC schema.
* `tableau_rule_firing_traces` — the rule-firing trace deliverable these
  certificates feed (exported by `TraceExport.lean`).
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem

/-!
## TraceEntry Inductive
-/

/--
A single trace entry for a tableau rule firing.

Mirrors the Libal & Volpe FPC schema `(precondition, rule, conclusion, branch_id)`.

Constructors:
- `ruleFired`: A rule was applied to a source signed formula producing
  conclusion signed formulas.
- `branchCreated`: A new sub-branch was created during a split.
- `branchClosed`: A branch closed (with `ClosureReason`).
- `blockingFired`: Subset blocking detected a saturating time.
- `fuelExhausted`: Fuel budget was exhausted.
-/
inductive TraceEntry : Type where
  /-- A tableau rule was applied. Carries the source signed formula
      (precondition), the rule applied, and the produced signed formulas
      (conclusion). `stepIndex` is a monotonic counter. -/
  | ruleFired (stepIndex : Nat) (rule : TableauRule) (sign : Sign)
      (formula : Formula) (label : Label)
      (produced : List SignedFormula) (isPersistent : Bool)
      (branchDepth : Nat) : TraceEntry
  /-- A new sub-branch was created during a split (branching rule). -/
  | branchCreated (stepIndex : Nat) (parentBranch : Nat)
      (newBranchId : Nat) (fromRule : TableauRule) : TraceEntry
  /-- A branch closed, with a `ClosureReason` witness. -/
  | branchClosed (stepIndex : Nat) (branchId : Nat)
      (reason : ClosureReason) : TraceEntry
  /-- Subset blocking detected a saturating time point. -/
  | blockingFired (stepIndex : Nat) (blockedTime : TimeIndex)
      (ancestorTime : TimeIndex) : TraceEntry
  /-- Fuel budget was exhausted. `fuelRemaining` is the budget that
      remained (typically `0`). -/
  | fuelExhausted (stepIndex : Nat) (fuelRemaining : Nat) : TraceEntry
  deriving Repr, Inhabited

/-!
## Outcome Types
-/

/--
Outcome classification of a `ProofCertificate` run.

- `validProof`: All branches closed (formula is valid).
- `countermodel`: Saturated open branch found (formula is invalid).
- `timeout`: Fuel exhausted before decision.
- `blocked`: Subset blocking fired (sub-branch may be saturated).
-/
inductive CertOutcome : Type where
  | validProof
  | countermodel
  | timeout
  | blocked
  deriving Repr, Inhabited, DecidableEq, BEq

/-!
## ProofCertificate Structure
-/

/--
A proof certificate collecting all trace events during a tableau run.

`axiomFingerprint`, `branchingFactor`, and `maxDepth` are pre-computed
(incrementally during expansion) to support O(1) reads and O(n) writes.
`elapsedMs` is `0` in pure `decideWithTrace`; the `IO` wrapper fills
it in.
-/
structure ProofCertificate where
  /-- The original formula being decided. -/
  formula : Formula
  /-- The frame class used for the decision procedure. -/
  frameClass : FrameClass
  /-- The outcome of the proof attempt. -/
  outcome : CertOutcome
  /-- Sequential trace of all rule firings and state changes
      (in chronological order: most recent event at the head, oldest
      at the tail — see `finalizeCertificate`). -/
  trace : List TraceEntry
  /-- Total rule firings (cached for O(1) access). -/
  totalSteps : Nat
  /-- Per-rule-name firing counts. -/
  axiomFingerprint : Std.HashMap String Nat
  /-- Average branching factor across all branching rule events. -/
  branchingFactor : Float
  /-- Maximum branch depth observed. -/
  maxDepth : Nat
  /-- Time consumed (wall-clock, in ms). `0` in pure version. -/
  elapsedMs : Nat
  deriving Repr

namespace ProofCertificate

/--
Empty certificate for a given formula and frame class. All accumulators
are zero; the trace is empty.
-/
def empty (φ : Formula) (fc : FrameClass := .Base) : ProofCertificate :=
  { formula := φ
  , frameClass := fc
  , outcome := .timeout          -- provisional until result is known
  , trace := []
  , totalSteps := 0
  , axiomFingerprint := ∅
  , branchingFactor := 1.0       -- default (no branching events)
  , maxDepth := 0
  , elapsedMs := 0 }

/--
Manual `Inhabited` instance for `ProofCertificate` (using `Formula.bot`
as the default formula, since `Atom` is intentionally not `Inhabited`).
-/
instance : Inhabited ProofCertificate :=
  ⟨ProofCertificate.empty Formula.bot .Base⟩

end ProofCertificate

/-!
## Failure Types
-/

/--
A failure outcome carrying the partial trace for post-mortem analysis.

- `outOfFuel`: Fuel budget exhausted; the trace contains all events recorded
  up to the point of exhaustion.
- `unsaturatable`: Expansion stalled (no rule applies, but the branch
  is not yet saturated; this is an internal-condition failure).
- `applyRulePanic`: An internal inconsistency was detected during rule
  application (should not occur in practice).
-/
inductive TraceFailure : Type where
  | outOfFuel (trace : List TraceEntry) (stepsCompleted : Nat)
  | unsaturatable (trace : List TraceEntry) (openBranch : Branch)
  | applyRulePanic (trace : List TraceEntry) (rule : TableauRule) (sf : SignedFormula)
  deriving Repr, Inhabited

/--
Sum type for a `decideWithTrace` call: success (carrying the full
certificate) or failure (carrying the partial trace).
-/
inductive TraceResult : Type where
  | success (cert : ProofCertificate)
  | failure (failure : TraceFailure)
  deriving Repr, Inhabited

/-!
## Rule Name Mapping
-/

/--
Map a `TableauRule` to a stable, JSON-safe string name.

This is the canonical serialization for `axiomFingerprint` keys.
-/
def ruleToString : TableauRule → String
  | .andPos                  => "andPos"
  | .andNeg                  => "andNeg"
  | .orPos                   => "orPos"
  | .orNeg                   => "orNeg"
  | .impPos                  => "impPos"
  | .impNeg                  => "impNeg"
  | .negPos                  => "negPos"
  | .negNeg                  => "negNeg"
  | .boxPos                  => "boxPos"
  | .boxNeg                  => "boxNeg"
  | .diamondPos              => "diamondPos"
  | .diamondNeg              => "diamondNeg"
  | .boxTemporal             => "boxTemporal"
  | .allFuturePos            => "allFuturePos"
  | .allFutureNeg            => "allFutureNeg"
  | .allPastPos              => "allPastPos"
  | .allPastNeg              => "allPastNeg"
  | .someFuturePos           => "someFuturePos"
  | .someFutureNeg           => "someFutureNeg"
  | .somePastPos             => "somePastPos"
  | .somePastNeg             => "somePastNeg"
  | .untlPos                 => "untlPos"
  | .untlNeg                 => "untlNeg"
  | .sncePos                 => "sncePos"
  | .snceNeg                 => "snceNeg"
  | .orderTrichotomy         => "orderTrichotomy"
  | .denseIndicatorClosure   => "denseIndicatorClosure"
  | .densityRule             => "densityRule"
  | .priorUZ                 => "priorUZ"
  | .priorSZ                 => "priorSZ"
  | .z1Rule                  => "z1Rule"
  | .priorUGap               => "priorUGap"
  | .priorSGap               => "priorSGap"
  | .serialityRule           => "serialityRule"
  | .timeLinearity           => "timeLinearity"
  | .sepRule                 => "sepRule"

/--
Compute the depth of a trace entry (used for `maxDepth`).
Returns `0` for non-`branchCreated` events and `newBranchId` for `branchCreated`.
-/
def entryDepth : TraceEntry → Nat
  | .branchCreated _ _ newBranchId _ => newBranchId
  | _                                 => 0

/--
Incrementally update the axiom fingerprint for a single `TraceEntry`.
No-op for non-`ruleFired` entries.
-/
def updateFingerprint (fp : Std.HashMap String Nat) (entry : TraceEntry) :
    Std.HashMap String Nat :=
  match entry with
  | .ruleFired _ rule _ _ _ _ _ _ =>
      let key := ruleToString rule
      fp.insert key (fp.getD key 0 + 1)
  | _ => fp

/-!
## TraceM Monad
-/

/--
A trace-monad computation: pure function that reads/writes a `ProofCertificate`.
-/
abbrev TraceM (α : Type) : Type := StateM ProofCertificate α

namespace TraceM

/-- Get the current certificate. -/
def getCert : TraceM ProofCertificate := get

/-- Set the current certificate. -/
def setCert (cert : ProofCertificate) : TraceM Unit := set cert

/--
Record a single trace event.

The certificate is updated as follows:
- `trace`: prepend the entry (O(1) cons; reversed at finalize time)
- `totalSteps`: increment by 1
- `axiomFingerprint`: increment the count for this rule (no-op for non-`ruleFired`)
- `maxDepth`: max with `entryDepth entry`
- `branchingFactor`: unchanged here (computed at finalize)
-/
def record (entry : TraceEntry) : TraceM Unit := do
  modify fun cert =>
    let newTrace := entry :: cert.trace
    let newTotal := cert.totalSteps + 1
    let newFp := updateFingerprint cert.axiomFingerprint entry
    let newMaxDepth := max cert.maxDepth (entryDepth entry)
    { cert with
      trace := newTrace
      totalSteps := newTotal
      axiomFingerprint := newFp
      maxDepth := newMaxDepth }

/--
Helper for the 28 `applyRule` arms: record a `ruleFired` event.

The function takes the `TableauRule`, the source signed formula's components
(sign, formula, label), the produced formulas, whether the rule is persistent,
and the branch depth.
-/
def recordRuleFired (rule : TableauRule) (sign : Sign) (formula : Formula)
    (label : Label) (produced : List SignedFormula)
    (isPersistent : Bool) (branchDepth : Nat) : TraceM Unit := do
  let cert ← get
  let entry : TraceEntry := .ruleFired cert.totalSteps rule sign formula label
      produced isPersistent branchDepth
  record entry

end TraceM

end FormalSystem.Metalogic.Decidability
