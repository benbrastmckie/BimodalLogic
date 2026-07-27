/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Saturation
import FormalSystem.Metalogic.Decidability.DecisionProcedure

/-!
# Cancellable (Abort-Aware) Tableau Expansion

This module provides **runtime-only** `IO` mirrors of the pure tableau core
(`expandBranchWithFuel` → `saturateBlocked` → `buildTableau` → `decide` →
`decideAutoAdaptive`). Each mirror checks an `IO.Ref Bool` abort flag (plus
`IO.checkCanceled` as belt-and-braces) at every recursive step and maps an
observed abort to `none`, which upstream maps to `.timeout` — an aborted run
can never yield `.valid`/`.invalid`.

## Why a parallel implementation?

Threading an `IO.Ref Bool` through the pure `expandBranchWithFuel` would force
it into `IO` and break the four proof-bearing theorems that `unfold`/`simp`
the pure definition (`expandBranchWithFuel_sound`, the two `tryBranch`
helpers, `invalid_of_expandBranchWithFuel_open`). Instead we follow the
established `_tracedImpl` precedent (Saturation.lean:368): mirror the
pure recursion shape in a monad — here `IO` instead of `StateM` — leaving the
pure functions and all their proofs byte-for-byte untouched.

## Drift risk

Each mirror is a **line-for-line transcription** of the corresponding pure
function; the only additions are the leading abort check and the `for`-loop
rendering of the split `foldl` (identical to `_tracedImpl`). Keep the two
definitions in sync: any change to a pure function
(`expandBranchWithFuel`/`saturateBlocked`/`buildTableau`) must be mirrored
here. A `#eval` spot-check (Phase 5) compares the mirror (abort never set)
against the pure function on sample formulas.

## No new proof obligations

The mirrors feed only dataset labels / JSON output. The convention that abort
maps to `none` (and thence to `.timeout`) keeps labels conservative by
construction, so no soundness theorems are required. Each mirror closes
termination with the identical `termination_by fuel` / `decreasing_by
all_goals simp_wf` already discharged for `_tracedImpl`.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Automation

/--
Cancellable `IO` mirror of `expandBranchWithFuel` (Saturation.lean:228).

Checks `abortRef` (and the task cancellation flag) at each recursive entry;
returns `none` on abort, which upstream maps to `.timeout` — never to
`.valid`/`.invalid`. The body mirrors the pure function line-for-line, with
the split `foldl` rendered as a `for` loop with a mutable `acc` exactly as in
`expandBranchWithFuel_tracedImpl` (Saturation.lean:368).

**Mirror of** `expandBranchWithFuel`; keep the two in sync.
-/
def expandBranchWithFuelCancellable (abortRef : IO.Ref Bool)
    (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (applied : AppliedSet := {})
    (maxBranches : Nat := 50000)
    (branchesUsed : Nat := 0)
    : IO (Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet))) := do
  -- Observe the abort signal at every recursive entry.
  if (← abortRef.get) || (← IO.checkCanceled) then return none
  -- Global branch counter limit (mirrors expandBranchWithFuel).
  if branchesUsed >= maxBranches then return none
  else
  match fuel with
  | 0 => return none  -- Out of fuel
  | fuel + 1 =>
      match findClosure b fc with
      | some reason => return some (.inl ⟨b, reason⟩)
      | none =>
          let tracker := registerEventualities b tracker
          let tracker := fulfillEventualities b tracker
          if (findBlockedTime b timeOrd tracker).isSome then
            return some (.inr (b, timeOrd, applied))  -- Blocked: saturated open
          else
          match expandOnceWithApplied b timeOrd fc applied with
          | (.saturated, _, _) => return some (.inr (b, timeOrd, applied))
          | (.extended newBranch, newOrd, newAppliedFormulas) =>
              let applied' := newAppliedFormulas.foldl (fun s f => s.insert f) applied
              expandBranchWithFuelCancellable abortRef newBranch fuel newOrd fc tracker applied'
                maxBranches (branchesUsed + 1)
          | (.split branches, newOrd, newAppliedFormulas) =>
              let applied' := newAppliedFormulas.foldl (fun s f => s.insert f) applied
              -- Proportional fuel allocation (mirrors expandBranchWithFuel).
              let fuelAllocs := allocateFuelProportionally (fuel + 1) branches
              -- Increment branch counter by number of new branches.
              let branchesUsed' := branchesUsed + branches.length
              let mut acc : Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet)) :=
                some (.inl ⟨b, .botPos Label.initial⟩)
              for pair in branches.zip fuelAllocs do
                match acc with
                | some (.inr openBr) => acc := some (.inr openBr)  -- already found open
                | _ =>
                    match ← expandBranchWithFuelCancellable abortRef pair.1 (min pair.2 fuel)
                      newOrd fc tracker applied' maxBranches branchesUsed' with
                    | none => acc := none
                    | some (.inl _) => pure ()  -- closed; continue
                    | some (.inr openBr) => acc := some (.inr openBr)
              return acc
termination_by fuel
decreasing_by all_goals simp_wf

/--
Cancellable `IO` mirror of `saturateBlocked` (Saturation.lean:495).

Continues expanding a blocked branch, rejecting steps that introduce new
time constraints, until saturated or closed. Returns `none` only on abort
(the pure function never returns `none`; upstream maps `none` to `.timeout`).

**Mirror of** `saturateBlocked`; keep the two in sync.
-/
def saturateBlockedCancellable (abortRef : IO.Ref Bool)
    (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering) (fc : FrameClass := .Base)
    : IO (Option (ClosedBranch ⊕ (Branch × TimeOrdering))) := do
  -- Observe the abort signal at every recursive entry.
  if (← abortRef.get) || (← IO.checkCanceled) then return none
  match fuel with
  | 0 => return some (.inr (b, timeOrd))  -- fuel exhausted: still blocked/open
  | fuel + 1 =>
      match findClosure b fc with
      | some reason => return some (.inl ⟨b, reason⟩)
      | none =>
          match expandOnce b timeOrd fc with
          | (.saturated, _) => return some (.inr (b, timeOrd))  -- fully saturated
          | (.extended newBranch, newOrd) =>
              if newOrd.constraints.length > timeOrd.constraints.length then
                return some (.inr (b, timeOrd))  -- reject: new time point
              else
                saturateBlockedCancellable abortRef newBranch fuel timeOrd fc
          | (.split branches, newOrd) =>
              if newOrd.constraints.length > timeOrd.constraints.length then
                return some (.inr (b, timeOrd))  -- reject: new time point
              else
                let mut acc : Option (ClosedBranch ⊕ (Branch × TimeOrdering)) :=
                  some (.inl ⟨b, .botPos Label.initial⟩)
                for newBranch in branches do
                  match acc with
                  | some (.inr openBr) => acc := some (.inr openBr)  -- already found open
                  | _ =>
                      match ← saturateBlockedCancellable abortRef newBranch fuel timeOrd fc with
                      | some (.inl _) => pure ()  -- sub-branch closed; continue
                      | some (.inr openBr) => acc := some (.inr openBr)
                      | none => acc := none
                return acc
termination_by fuel
decreasing_by all_goals simp_wf

/--
Cancellable `IO` mirror of `buildTableau` (Saturation.lean:555).

Builds a complete tableau for `¬φ` using the two cancellable helpers; an
observed abort surfaces as `none` (→ `.timeout` upstream).

**Mirror of** `buildTableau`; keep the two in sync.
-/
def buildTableauCancellable (abortRef : IO.Ref Bool) (φ : Formula)
    (fuel : Nat := 1000) (fc : FrameClass := .Base)
    : IO (Option ExpandedTableau) := do
  let initialBranch : Branch := [SignedFormula.neg φ Label.initial]
  match ← expandBranchWithFuelCancellable abortRef initialBranch fuel TimeOrdering.empty fc with
  | none => return none  -- out of fuel or aborted
  | some (.inl closedBr) => return some (.allClosed [closedBr])
  | some (.inr (openBr, ord, appliedSet)) =>
      match h : findUnexpandedWithApplied openBr (timeOrd := ord) (applied := appliedSet) with
      | none => return some (.hasOpen openBr ord appliedSet h)
      | some _ =>
          match ← saturateBlockedCancellable abortRef openBr fuel ord fc with
          | some (.inl closedBr) => return some (.allClosed [closedBr])
          | some (.inr (satBr, satOrd)) =>
              match h2 :
                findUnexpandedWithApplied satBr (timeOrd := satOrd) (applied := appliedSet) with
              | none => return some (.hasOpen satBr satOrd appliedSet h2)
              | some _ => return none  -- still not saturated after post-blocking pass
          | none => return none  -- aborted (or the pure "should not happen")

/-!
## Cancellable Decision Wrappers

These wrap the cancellable tableau core into decision-level entry points that
reuse the pure fast paths (`tryAxiomProof`, `buildCompositionalProof`,
`bounded_search_with_proof` — cheap and bounded) and map an observed abort
(surfacing as a `none` tableau) to `.timeout`, never `.valid`/`.invalid`.
-/

/--
Cancellable `IO` mirror of `decide` (DecisionProcedure.lean:122).

Reuses the pure fast paths unchanged and calls `buildTableauCancellable` for
the expensive tableau leg. An aborted tableau (`none`) maps to `.timeout`.

**Mirror of** `decide`; keep the two in sync.
-/
def decideCancellable (abortRef : IO.Ref Bool) (φ : Formula)
    (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    (fc : FrameClass := .Base) : IO (DecisionResult φ) := do
  -- Normalization is definitionally the identity (mirrors `decide`).
  have h_norm : Automation.Normalization.normalizeFormula φ = φ :=
    Automation.Normalization.normalizeFormula_id φ
  let φ_n := Automation.Normalization.normalizeFormula φ
  -- Fast path: direct axiom proof.
  match tryAxiomProof φ_n with
  | some proof => return .valid (h_norm ▸ proof)
  | none =>
    -- Fast path: compositional proof (box-valid patterns).
    match buildCompositionalProof φ_n 10 with
    | some proof => return .valid (h_norm ▸ proof)
    | none =>
    -- Fast path: bounded proof search.
    match boundedSearchWithProof [] φ_n searchDepth with
    | (some proof, _, _) => return .valid (h_norm ▸ proof)
    | (none, _, _) =>
      -- Expensive leg: cancellable tableau. Abort/fuel exhaustion → none.
      match ← buildTableauCancellable abortRef φ_n tableauFuel fc with
      | none => return .timeout
      | some tableau =>
          match tableau with
          | .allClosed _ =>
              match extractProof φ_n tableau fc with
              | .success proof => return .valid (h_norm ▸ proof)
              | .incomplete _ => return .timeout
          | .hasOpen openBranch _ord _applied hSat =>
              return .invalid (extractCountermodelSimple φ_n openBranch hSat)

/--
Cancellable `IO` mirror of `decideAutoAdaptive` (DecisionProcedure.lean:198).

Runs `decideCancellable` at the single fuel tier and tags the result. An
aborted run returns `(.timeout, "adaptive_timeout")`.

**Mirror of** `decideAutoAdaptive`; keep the two in sync.
-/
def decideAutoAdaptiveCancellable (abortRef : IO.Ref Bool) (φ : Formula)
    (fc : FrameClass := .Base) (fuel : Nat := 500)
    : IO (DecisionResult φ × String) := do
  let depth := 5 + φ.complexity / 2
  match ← decideCancellable abortRef φ depth fuel fc with
  | .timeout => return (.timeout, "adaptive_timeout")
  | result => return (result, s!"adaptive_{fuel}")

end FormalSystem.Metalogic.Decidability
