import Bimodal.Metalogic.Decidability.SignedFormula

/-!
# Tableau Rules for TM Bimodal Logic

This module defines the tableau expansion rules for the TM bimodal logic
decision procedure. The rules systematically decompose signed formulas
until branches close (contradiction found) or saturate (countermodel exists).

## Main Definitions

- `TableauRule`: Enumeration of all tableau expansion rules
- `RuleResult`: Result of applying a rule (linear extension or branching)
- `applyRule`: Apply a tableau rule to a signed formula
- `expandBranch`: Single-step expansion of a branch

## Tableau Rules

### Propositional Rules
- `andPos`: T(A ∧ B) → T(A), T(B) (non-branching)
- `andNeg`: F(A ∧ B) → F(A) | F(B) (branching)
- `orPos`: T(A ∨ B) → T(A) | T(B) (branching)
- `orNeg`: F(A ∨ B) → F(A), F(B) (non-branching)
- `impPos`: T(A → B) → F(A) | T(B) (branching)
- `impNeg`: F(A → B) → T(A), F(B) (non-branching)
- `negPos`: T(¬A) → F(A) (non-branching)
- `negNeg`: F(¬A) → T(A) (non-branching)

### Modal S5 Rules
- `boxPos`: T(□A) → propagate T(A) to accessible states
- `boxNeg`: F(□A) → create state with F(A)

### Temporal Rules
- `allFuturePos`: T(GA) → propagate T(A) to future times
- `allFutureNeg`: F(GA) → create future time with F(A)
- `allPastPos`: T(HA) → propagate T(A) to past times
- `allPastNeg`: F(HA) → create past time with F(A)

## Implementation Notes

Since TM combines S5 modal logic with linear temporal logic, we use a
simplified tableau system that exploits the special properties of S5
(all worlds are mutually accessible, so we can use a single equivalence class).

## References

* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Wu, M. Verified Decision Procedures for Modal Logics
-/

namespace Bimodal.Metalogic.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Tableau Rule Type
-/

/--
Tableau expansion rules for TM bimodal logic.

Each rule specifies how to decompose a signed formula. Rules are either:
- **Linear** (non-branching): Add formulas to the current branch
- **Branching**: Split into multiple branches (any must close for tableau to close)
-/
inductive TableauRule : Type where
  /-- T(A ∧ B) → T(A), T(B) (A ∧ B = ¬(A → ¬B)) -/
  | andPos
  /-- F(A ∧ B) → F(A) | F(B) (branching) -/
  | andNeg
  /-- T(A ∨ B) → T(A) | T(B) (A ∨ B = ¬A → B, branching) -/
  | orPos
  /-- F(A ∨ B) → F(A), F(B) -/
  | orNeg
  /-- T(A → B) → F(A) | T(B) (branching) -/
  | impPos
  /-- F(A → B) → T(A), F(B) -/
  | impNeg
  /-- T(¬A) → F(A) (¬A = A → ⊥) -/
  | negPos
  /-- F(¬A) → T(A) -/
  | negNeg
  /-- T(□A) → propagate T(A) to all known worlds (S5 universal, persistent) -/
  | boxPos
  /-- F(□A) → introduce fresh witness world with F(A), auto-propagate universals -/
  | boxNeg
  /-- T(◇A) → introduce fresh witness world with T(A), auto-propagate universals -/
  | diamondPos
  /-- F(◇A) → propagate F(A) to all known worlds (S5 universal, persistent) -/
  | diamondNeg
  /-- T(GA) → propagate T(A) to all known future times (universal, persistent) -/
  | allFuturePos
  /-- F(GA) → F(A) at fresh future time (existential, consumable) -/
  | allFutureNeg
  /-- T(HA) → propagate T(A) to all known past times (universal, persistent) -/
  | allPastPos
  /-- F(HA) → F(A) at fresh past time (existential, consumable) -/
  | allPastNeg
  /-- T(FA) → T(A) at fresh future time (existential, consumable) -/
  | someFuturePos
  /-- F(FA) → propagate F(A) to all known future times (universal, persistent) -/
  | someFutureNeg
  /-- T(PA) → T(A) at fresh past time (existential, consumable) -/
  | somePastPos
  /-- F(PA) → propagate F(A) to all known past times (universal, persistent) -/
  | somePastNeg
  /-- T(U(event,guard)) → branch: event-witness at fresh future time OR guard+continue (consumable) -/
  | untlPos
  /-- F(U(event,guard)) → Reynolds co-decomposition at known future times (persistent) -/
  | untlNeg
  /-- T(S(event,guard)) → branch: event-witness at fresh past time OR guard+continue (consumable) -/
  | sncePos
  /-- F(S(event,guard)) → Reynolds co-decomposition at known past times (persistent) -/
  | snceNeg
  deriving Repr, DecidableEq

/-!
## Rule Result Type
-/

/--
Result of applying a tableau rule to a signed formula.

- `linear`: Add formulas to the current branch (non-branching)
- `branching`: Split into multiple branches (all must close for validity)
- `notApplicable`: Rule doesn't apply to this signed formula
-/
inductive RuleResult : Type where
  /-- Add these signed formulas to the current branch. -/
  | linear (formulas : List SignedFormula)
  /-- Split into multiple branches (each is a list of formulas to add). -/
  | branching (branches : List (List SignedFormula))
  /-- Universal modal rule: add formulas but do NOT remove the source formula.
      Used for T(□A) and F(◇A) which must persist for propagation to new worlds. -/
  | persistent (formulas : List SignedFormula)
  /-- Rule does not apply to this signed formula. -/
  | notApplicable
  deriving Repr

/-!
## Formula Decomposition Helpers
-/

/--
Try to decompose a formula as negation (A → ⊥).
Returns `some A` if the formula is `A.imp .bot`, otherwise `none`.
-/
def asNeg? : Formula → Option Formula
  | .imp φ .bot => some φ
  | _ => none

/--
Try to decompose a formula as conjunction (¬(A → ¬B)).
Note: A ∧ B = (A.imp B.neg).neg = (A.imp (B.imp .bot)).imp .bot
Returns `some (A, B)` if it matches the pattern, otherwise `none`.
-/
def asAnd? : Formula → Option (Formula × Formula)
  | .imp (.imp φ (.imp ψ .bot)) .bot => some (φ, ψ)
  | _ => none

/--
Try to decompose a formula as disjunction (¬A → B).
Note: A ∨ B = A.neg.imp B = (A.imp .bot).imp B
Returns `some (A, B)` if it matches the pattern, otherwise `none`.
-/
def asOr? : Formula → Option (Formula × Formula)
  | .imp (.imp φ .bot) ψ => some (φ, ψ)
  | _ => none

/--
Try to decompose a formula as diamond (¬□¬A).
Note: ◇A = A.neg.box.neg = ((A.imp .bot).box).imp .bot
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asDiamond? : Formula → Option Formula
  | .imp (.box (.imp φ .bot)) .bot => some φ
  | _ => none

/--
Try to decompose a formula as some_past (PA = S(A, ⊤)).
Note: some_past A = snce A top = snce A (imp bot bot)
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asSomePast? : Formula → Option Formula
  | .some_past φ => some φ
  | _ => none

/--
Try to decompose a formula as some_future (FA = U(A, ⊤)).
Note: some_future A = untl A top = untl A (imp bot bot)
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asSomeFuture? : Formula → Option Formula
  | .some_future φ => some φ
  | _ => none

/--
Try to decompose a formula as all_future (GA = ¬F¬A = ¬(U(¬A, ⊤))).
Note: all_future A = (some_future A.neg).neg
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asAllFuture? : Formula → Option Formula
  | .all_future φ => some φ
  | _ => none

/--
Try to decompose a formula as all_past (HA = ¬P¬A = ¬(S(¬A, ⊤))).
Note: all_past A = (some_past A.neg).neg
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asAllPast? : Formula → Option Formula
  | .all_past φ => some φ
  | _ => none

/--
Try to decompose a formula as a genuine Until (not some_future).
Returns `some (event, guard)` if the formula is `untl event guard` with `guard != top`.
This filters out `some_future φ = untl φ top` which is handled by someFuturePos/someFutureNeg.
Burgess convention: first component = event, second = guard.
-/
def asUntil? : Formula → Option (Formula × Formula)
  | .untl event guard =>
    if guard == Formula.top then none
    else some (event, guard)
  | _ => none

/--
Try to decompose a formula as a genuine Since (not some_past).
Returns `some (event, guard)` if the formula is `snce event guard` with `guard != top`.
This filters out `some_past φ = snce φ top` which is handled by somePastPos/somePastNeg.
Burgess convention: first component = event, second = guard.
-/
def asSince? : Formula → Option (Formula × Formula)
  | .snce event guard =>
    if guard == Formula.top then none
    else some (event, guard)
  | _ => none

/-!
## Rule Application
-/

/--
Check if a specific rule is applicable to a signed formula.
-/
def isApplicable (rule : TableauRule) (sf : SignedFormula) : Bool :=
  match rule, sf.sign, sf.formula with
  -- Propositional rules
  | .andPos, .pos, φ => (asAnd? φ).isSome
  | .andNeg, .neg, φ => (asAnd? φ).isSome
  | .orPos, .pos, φ => (asOr? φ).isSome
  | .orNeg, .neg, φ => (asOr? φ).isSome
  | .impPos, .pos, .imp _ _ => true
  | .impNeg, .neg, .imp _ _ => true
  | .negPos, .pos, φ => (asNeg? φ).isSome
  | .negNeg, .neg, φ => (asNeg? φ).isSome
  -- Modal rules
  | .boxPos, .pos, .box _ => true
  | .boxNeg, .neg, .box _ => true
  | .diamondPos, .pos, φ => (asDiamond? φ).isSome
  | .diamondNeg, .neg, φ => (asDiamond? φ).isSome
  -- Temporal rules (G/H universal)
  | .allFuturePos, .pos, .all_future _ => true
  | .allFutureNeg, .neg, .all_future _ => true
  | .allPastPos, .pos, .all_past _ => true
  | .allPastNeg, .neg, .all_past _ => true
  -- Temporal rules (F/P existential)
  | .someFuturePos, .pos, φ => (asSomeFuture? φ).isSome
  | .someFutureNeg, .neg, φ => (asSomeFuture? φ).isSome
  | .somePastPos, .pos, φ => (asSomePast? φ).isSome
  | .somePastNeg, .neg, φ => (asSomePast? φ).isSome
  -- Until/Since rules (genuine, not some_future/some_past)
  | .untlPos, .pos, φ => (asUntil? φ).isSome
  | .untlNeg, .neg, φ => (asUntil? φ).isSome
  | .sncePos, .pos, φ => (asSince? φ).isSome
  | .snceNeg, .neg, φ => (asSince? φ).isSome
  | _, _, _ => false

/--
Apply a tableau rule to a signed formula.

Returns the result of the rule application:
- `linear [...]`: Add these formulas to the branch
- `branching [[...], [...]]`: Split into these branches
- `notApplicable`: Rule doesn't apply
-/
def applyRule (rule : TableauRule) (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty) : RuleResult × TimeOrdering :=
  let l := sf.label
  match rule, sf.sign, sf.formula with
  -- T(A ∧ B) → T(A), T(B)
  | .andPos, .pos, φ =>
      match asAnd? φ with
      | some (ψ, χ) => (.linear [SignedFormula.pos ψ l, SignedFormula.pos χ l], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(A ∧ B) → F(A) | F(B)
  | .andNeg, .neg, φ =>
      match asAnd? φ with
      | some (ψ, χ) => (.branching [[SignedFormula.neg ψ l], [SignedFormula.neg χ l]], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(A ∨ B) → T(A) | T(B)
  | .orPos, .pos, φ =>
      match asOr? φ with
      | some (ψ, χ) => (.branching [[SignedFormula.pos ψ l], [SignedFormula.pos χ l]], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(A ∨ B) → F(A), F(B)
  | .orNeg, .neg, φ =>
      match asOr? φ with
      | some (ψ, χ) => (.linear [SignedFormula.neg ψ l, SignedFormula.neg χ l], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(A → B) → F(A) | T(B)
  | .impPos, .pos, .imp ψ χ =>
      (.branching [[SignedFormula.neg ψ l], [SignedFormula.pos χ l]], timeOrd)
  -- F(A → B) → T(A), F(B)
  | .impNeg, .neg, .imp ψ χ =>
      (.linear [SignedFormula.pos ψ l, SignedFormula.neg χ l], timeOrd)
  -- T(¬A) → F(A)
  | .negPos, .pos, φ =>
      match asNeg? φ with
      | some ψ => (.linear [SignedFormula.neg ψ l], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(¬A) → T(A)
  | .negNeg, .neg, φ =>
      match asNeg? φ with
      | some ψ => (.linear [SignedFormula.pos ψ l], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(□A) → propagate T(A) to all known worlds (S5 universal, persistent)
  | .boxPos, .pos, .box ψ =>
      let worlds := branch.knownWorlds
      let newFormulas := worlds.filterMap fun w =>
        let newSf := SignedFormula.pos ψ { world := w, time := l.time }
        if branch.contains newSf then none else some newSf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- F(□A) → F(A) at fresh witness world + auto-propagate universals (S5 existential)
  | .boxNeg, .neg, .box ψ =>
      let freshWorld := branch.nextWorld
      let freshLabel : Label := { world := freshWorld, time := l.time }
      -- The witness: F(A) at the fresh world
      let witness := SignedFormula.neg ψ freshLabel
      -- Auto-propagate all T(□B) formulas to the fresh world
      let boxProps := branch.boxPosFormulas.filterMap fun bsf =>
        match bsf.formula with
        | .box inner =>
          let prop := SignedFormula.pos inner { world := freshWorld, time := bsf.label.time }
          if branch.contains prop then none else some prop
        | _ => none
      -- Auto-propagate all F(◇B) formulas to the fresh world
      let diaProps := branch.diamondNegFormulas.filterMap fun dsf =>
        match dsf.formula with
        | .imp (.box (.imp inner .bot)) .bot =>
          let prop := SignedFormula.neg inner { world := freshWorld, time := dsf.label.time }
          if branch.contains prop then none else some prop
        | _ => none
      (.linear (witness :: boxProps ++ diaProps), timeOrd)
  -- T(◇A) → T(A) at fresh witness world + auto-propagate universals (S5 existential)
  | .diamondPos, .pos, φ =>
      match asDiamond? φ with
      | some ψ =>
        let freshWorld := branch.nextWorld
        let freshLabel : Label := { world := freshWorld, time := l.time }
        -- The witness: T(A) at the fresh world
        let witness := SignedFormula.pos ψ freshLabel
        -- Auto-propagate all T(□B) formulas to the fresh world
        let boxProps := branch.boxPosFormulas.filterMap fun bsf =>
          match bsf.formula with
          | .box inner =>
            let prop := SignedFormula.pos inner { world := freshWorld, time := bsf.label.time }
            if branch.contains prop then none else some prop
          | _ => none
        -- Auto-propagate all F(◇B) formulas to the fresh world
        let diaProps := branch.diamondNegFormulas.filterMap fun dsf =>
          match dsf.formula with
          | .imp (.box (.imp inner .bot)) .bot =>
            let prop := SignedFormula.neg inner { world := freshWorld, time := dsf.label.time }
            if branch.contains prop then none else some prop
          | _ => none
        (.linear (witness :: boxProps ++ diaProps), timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(◇A) → propagate F(A) to all known worlds (S5 universal, persistent)
  | .diamondNeg, .neg, φ =>
      match asDiamond? φ with
      | some ψ =>
        let worlds := branch.knownWorlds
        let newFormulas := worlds.filterMap fun w =>
          let newSf := SignedFormula.neg ψ { world := w, time := l.time }
          if branch.contains newSf then none else some newSf
        if newFormulas.isEmpty then (.notApplicable, timeOrd)
        else (.persistent newFormulas, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(GA) @ (w,t) → propagate T(A) to all known future times (universal, persistent)
  -- Strict inequality: G(A) at t means A holds at all t' > t
  | .allFuturePos, .pos, .all_future ψ =>
      let futureTimes := timeOrd.futureOf l.time
      let newFormulas := futureTimes.filterMap fun t' =>
        let newSf := SignedFormula.pos ψ { world := l.world, time := t' }
        if branch.contains newSf then none else some newSf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- F(GA) @ (w,t) → F(A) at fresh future time (existential, consumable)
  -- ¬G(A) at t means there exists t' > t where ¬A
  | .allFutureNeg, .neg, .all_future ψ =>
      let freshTime := branch.nextTime
      let freshLabel : Label := { world := l.world, time := freshTime }
      let newOrd := timeOrd.addFuture l.time freshTime
      -- The witness: F(A) at the fresh future time
      let witness := SignedFormula.neg ψ freshLabel
      -- Auto-propagate all T(GA) formulas from time t to freshTime
      let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
        match gsf.formula with
        | .all_future inner =>
          -- Only propagate if freshTime is future of gsf's time
          -- Since we only added (l.time, freshTime), check gsf is at time l.time
          if gsf.label.time == l.time then
            let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      -- Auto-propagate all F(FA) formulas from time t to freshTime
      let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
        match fsf.formula with
        | .some_future inner =>
          if fsf.label.time == l.time then
            let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      (.linear (witness :: gProps ++ fNegProps), newOrd)
  -- T(HA) @ (w,t) → propagate T(A) to all known past times (universal, persistent)
  -- Strict inequality: H(A) at t means A holds at all t' < t
  | .allPastPos, .pos, .all_past ψ =>
      let pastTimes := timeOrd.pastOf l.time
      let newFormulas := pastTimes.filterMap fun t' =>
        let newSf := SignedFormula.pos ψ { world := l.world, time := t' }
        if branch.contains newSf then none else some newSf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- F(HA) @ (w,t) → F(A) at fresh past time (existential, consumable)
  -- ¬H(A) at t means there exists t' < t where ¬A
  | .allPastNeg, .neg, .all_past ψ =>
      let freshTime := branch.nextTime
      let freshLabel : Label := { world := l.world, time := freshTime }
      let newOrd := timeOrd.addPast l.time freshTime
      -- The witness: F(A) at the fresh past time
      let witness := SignedFormula.neg ψ freshLabel
      -- Auto-propagate all T(HA) formulas from time t to freshTime
      let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
        match hsf.formula with
        | .all_past inner =>
          -- Only propagate if freshTime is past of hsf's time
          -- Since we added (freshTime, l.time), check hsf is at time l.time
          if hsf.label.time == l.time then
            let prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      -- Auto-propagate all F(PA) formulas from time t to freshTime
      let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
        match psf.formula with
        | .some_past inner =>
          if psf.label.time == l.time then
            let prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      (.linear (witness :: hProps ++ pNegProps), newOrd)
  -- T(FA) @ (w,t) → T(A) at fresh future time (existential, consumable)
  -- F(A) at t means there exists t' > t where A holds
  | .someFuturePos, .pos, φ =>
      match asSomeFuture? φ with
      | some ψ =>
        let freshTime := branch.nextTime
        let freshLabel : Label := { world := l.world, time := freshTime }
        let newOrd := timeOrd.addFuture l.time freshTime
        -- The witness: T(A) at the fresh future time
        let witness := SignedFormula.pos ψ freshLabel
        -- Auto-propagate all T(GA) formulas from time t to freshTime
        let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
          match gsf.formula with
          | .all_future inner =>
            if gsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(FA) formulas from time t to freshTime
        let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
          match fsf.formula with
          | .some_future inner =>
            if fsf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        (.linear (witness :: gProps ++ fNegProps), newOrd)
      | none => (.notApplicable, timeOrd)
  -- F(FA) @ (w,t) → propagate F(A) to all known future times (universal, persistent)
  -- F(FA) = ¬(FA) means at all future times, A fails
  | .someFutureNeg, .neg, φ =>
      match asSomeFuture? φ with
      | some ψ =>
        let futureTimes := timeOrd.futureOf l.time
        let newFormulas := futureTimes.filterMap fun t' =>
          let newSf := SignedFormula.neg ψ { world := l.world, time := t' }
          if branch.contains newSf then none else some newSf
        if newFormulas.isEmpty then (.notApplicable, timeOrd)
        else (.persistent newFormulas, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- T(PA) @ (w,t) → T(A) at fresh past time (existential, consumable)
  -- P(A) at t means there exists t' < t where A holds
  | .somePastPos, .pos, φ =>
      match asSomePast? φ with
      | some ψ =>
        let freshTime := branch.nextTime
        let freshLabel : Label := { world := l.world, time := freshTime }
        let newOrd := timeOrd.addPast l.time freshTime
        -- The witness: T(A) at the fresh past time
        let witness := SignedFormula.pos ψ freshLabel
        -- Auto-propagate all T(HA) formulas from time t to freshTime
        let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
          match hsf.formula with
          | .all_past inner =>
            if hsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(PA) formulas from time t to freshTime
        let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
          match psf.formula with
          | .some_past inner =>
            if psf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        (.linear (witness :: hProps ++ pNegProps), newOrd)
      | none => (.notApplicable, timeOrd)
  -- F(PA) @ (w,t) → propagate F(A) to all known past times (universal, persistent)
  -- F(PA) = ¬(PA) means at all past times, A fails
  | .somePastNeg, .neg, φ =>
      match asSomePast? φ with
      | some ψ =>
        let pastTimes := timeOrd.pastOf l.time
        let newFormulas := pastTimes.filterMap fun t' =>
          let newSf := SignedFormula.neg ψ { world := l.world, time := t' }
          if branch.contains newSf then none else some newSf
        if newFormulas.isEmpty then (.notApplicable, timeOrd)
        else (.persistent newFormulas, timeOrd)
      | none => (.notApplicable, timeOrd)
  | _, _, _ => (.notApplicable, timeOrd)

/-!
## Branch Expansion
-/

/--
All tableau rules in priority order.
Propositional rules are tried first, then modal, then temporal.
-/
def allRules : List TableauRule := [
  .negPos, .negNeg,      -- Negation (simplest)
  .impNeg,               -- F(A → B) non-branching
  .andPos, .orNeg,       -- Non-branching compound
  .boxPos, .boxNeg,      -- Modal
  .diamondPos, .diamondNeg,
  .allFuturePos, .allFutureNeg,  -- Temporal G/H
  .allPastPos, .allPastNeg,
  .someFuturePos, .someFutureNeg,  -- Temporal F/P
  .somePastPos, .somePastNeg,
  .impPos,               -- Branching implication
  .andNeg, .orPos        -- Branching compound
]

/--
Find a rule that applies to a signed formula.
Returns the first applicable rule, its result, and the updated TimeOrdering.
-/
def findApplicableRule (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty) : Option (TableauRule × RuleResult × TimeOrdering) :=
  allRules.findSome? fun rule =>
    let (result, newOrd) := applyRule rule sf branch timeOrd
    match result with
    | .notApplicable => none
    | _ => some (rule, result, newOrd)

/--
Check if a signed formula is fully expanded (no rules apply).
Atoms, bot with appropriate signs, and already-reduced formulas are expanded.
-/
def isExpanded (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty) : Bool :=
  (findApplicableRule sf branch timeOrd).isNone

/--
Find an unexpanded formula in a branch.
Returns the first formula that can still be expanded.
-/
def findUnexpanded (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    : Option SignedFormula :=
  b.find? (fun sf => ¬isExpanded sf b timeOrd)

/--
Result of a single expansion step on a branch.
-/
inductive ExpansionResult : Type where
  /-- Branch is fully saturated (no more expansions possible). -/
  | saturated
  /-- Single branch extension (non-branching rule applied). -/
  | extended (newBranch : Branch)
  /-- Branch splits into multiple branches (branching rule applied). -/
  | split (branches : List Branch)
  deriving Repr

/--
Perform a single expansion step on a branch.

Finds the first unexpanded formula and applies the appropriate rule.
Returns the result of the expansion together with the (possibly updated) TimeOrdering.
-/
def expandOnce (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    : ExpansionResult × TimeOrdering :=
  match findUnexpanded b timeOrd with
  | none => (.saturated, timeOrd)
  | some sf =>
      match findApplicableRule sf b timeOrd with
      | none => (.saturated, timeOrd)  -- Shouldn't happen if findUnexpanded returned something
      | some (_, result, newOrd) =>
          match result with
          | .linear formulas =>
              -- Remove the expanded formula and add new ones
              let remaining := b.filter (· != sf)
              (.extended (formulas ++ remaining), newOrd)
          | .branching branches =>
              -- Remove the expanded formula from each branch and add new formulas
              let remaining := b.filter (· != sf)
              (.split (branches.map fun newFormulas => newFormulas ++ remaining), newOrd)
          | .persistent formulas =>
              -- Add new formulas but keep the source formula (universal modal rule)
              (.extended (formulas ++ b), newOrd)
          | .notApplicable => (.saturated, newOrd)  -- Shouldn't happen

/--
Count of unexpanded formulas in a branch (termination measure).
-/
def countUnexpanded (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty) : Nat :=
  b.filter (fun sf => ¬isExpanded sf b timeOrd) |>.length

/--
Total unexpanded complexity (alternative termination measure).
-/
def totalUnexpandedComplexity (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty) : Nat :=
  b.filter (fun sf => ¬isExpanded sf b timeOrd)
  |>.foldl (fun acc sf => acc + sf.complexity) 0

end Bimodal.Metalogic.Decidability
