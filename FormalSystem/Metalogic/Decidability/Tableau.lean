/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.SignedFormula

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

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem

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
  /-- T(□A) → derive T(GA) and T(HA) at the same label (modal-temporal interaction, persistent).
      Sound by boxToFuture (□φ → Gφ) and boxToPast (□φ → Hφ). -/
  | boxTemporal
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
  /-- T(U(event,guard)) → branch:
    event-witness at fresh future time OR guard+continue (consumable) -/
  | untlPos
  /-- F(U(event,guard)) → Reynolds co-decomposition at known future times (persistent) -/
  | untlNeg
  /-- T(S(event,guard)) → branch: event-witness at fresh past time OR guard+continue (consumable) -/
  | sncePos
  /-- F(S(event,guard)) → Reynolds co-decomposition at known past times (persistent) -/
  | snceNeg
  /-- Order trichotomy (R2, repairs D2). A positive witness `T(φ)` at a time `t1` and a
      positive `T(ψ)` at an incomparable sibling time `t2` (both after a common `t0`, same
      world) branch on the relative order of `t1` and `t2`, syntactically the three
      `temp_linearity` (BX11) disjuncts at `t0`:
      `T(F(φ ∧ ψ)) | T(F(φ ∧ F ψ)) | T(F(F φ ∧ ψ))`.
      Base rule: BX11 is a base axiom, so this is sound for every frame class. -/
  | orderTrichotomy
  /-- Dense: close branch when T(U(⊤,⊥)) appears (since ¬U(⊤,⊥) is a Dense axiom,
      asserting U(⊤,⊥) leads to contradiction on dense frames). Only applicable when fc >= .Dense.
      -/
  | denseIndicatorClosure
  /-- Dense: when T(G(φ)) at (w,t) and there exists a future time t' > t on the branch,
      introduce an intermediate time t'' with t < t'' < t' and add T(φ) at (w,t'').
      Captures density: between any two time points there is another. Only when fc >= .Dense. -/
  | densityRule
  /-- Discrete: when T(F(φ)) at (w,t), add T(U(φ, ¬φ)) at (w,t).
      Captures "nearest future φ-point reachable by Until". Only when fc >= .Discrete. -/
  | priorUZ
  /-- Discrete: when T(P(φ)) at (w,t), add T(S(φ, ¬φ)) at (w,t).
      Captures "nearest past φ-point reachable by Since". Only when fc >= .Discrete. -/
  | priorSZ
  /-- Discrete: when both T(G(G(φ) → φ)) and T(F(G(φ))) at same label,
      add T(G(φ)). Z1 backward induction axiom. Only when fc >= .Discrete. -/
  | z1Rule
  /-- Dedekind: Prior-U (gap form). When `T(U(⊤,φ) ∧ F(¬φ))` at `(w,t)`, add
      `T(U(¬φ ∨ K⁺(¬φ), φ))` at `(w,t)` — the φ-region has a definable right endpoint.
      Tableau counterpart of `Axiom.prior_U_gap`. Only when `fc >= .Dedekind`.
      NOT `priorUZ`, which is the integer well-ordering axiom at `.Discrete`. -/
  | priorUGap
  /-- Dedekind: Prior-S (gap form). Past dual of `priorUGap`: from
      `T(S(⊤,φ) ∧ P(¬φ))` add `T(S(¬φ ∨ K⁻(¬φ), φ))`.
      Tableau counterpart of `Axiom.prior_S_gap`. NOT `priorSZ`. -/
  | priorSGap
  /-- Dedekind: separation. From `T(K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)))` add
      `T(K⁺(K⁺φ ∧ K⁻φ))`. Tableau counterpart of `Axiom.sep`. -/
  | sepRule
  deriving Repr, DecidableEq, BEq, Hashable

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
Try to decompose a formula as somePast (PA = S(A, ⊤)).
Note: somePast A = snce A top = snce A (imp bot bot)
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asSomePast? : Formula → Option Formula
  | .somePast φ => some φ
  | _ => none

/--
Try to decompose a formula as someFuture (FA = U(A, ⊤)).
Note: someFuture A = untl A top = untl A (imp bot bot)
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asSomeFuture? : Formula → Option Formula
  | .someFuture φ => some φ
  | _ => none

/--
Try to decompose a formula as allFuture (GA = ¬F¬A = ¬(U(¬A, ⊤))).
Note: allFuture A = (someFuture A.neg).neg
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asAllFuture? : Formula → Option Formula
  | .allFuture φ => some φ
  | _ => none

/--
Try to decompose a formula as allPast (HA = ¬P¬A = ¬(S(¬A, ⊤))).
Note: allPast A = (somePast A.neg).neg
Returns `some A` if it matches the pattern, otherwise `none`.
-/
def asAllPast? : Formula → Option Formula
  | .allPast φ => some φ
  | _ => none

/--
Try to decompose a formula as a genuine Until (not someFuture).
Returns `some (event, guard)` if the formula is `untl event guard` with `guard != top`.
This filters out `someFuture φ = untl φ top` which is handled by someFuturePos/someFutureNeg.
Burgess convention: first component = event, second = guard.
-/
def asUntil? : Formula → Option (Formula × Formula)
  | .untl event guard =>
    if guard == Formula.top then none
    else some (event, guard)
  | _ => none

/--
Try to decompose a formula as a genuine Since (not somePast).
Returns `some (event, guard)` if the formula is `snce event guard` with `guard != top`.
This filters out `somePast φ = snce φ top` which is handled by somePastPos/somePastNeg.
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
def isApplicable (rule : TableauRule) (sf : SignedFormula)
    (fc : FrameClass := .Base) : Bool :=
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
  -- Modal-temporal interaction
  | .boxTemporal, .pos, .box _ => true
  -- Temporal rules (G/H universal)
  | .allFuturePos, .pos, .allFuture _ => true
  | .allFutureNeg, .neg, .allFuture _ => true
  | .allPastPos, .pos, .allPast _ => true
  | .allPastNeg, .neg, .allPast _ => true
  -- Temporal rules (F/P existential)
  | .someFuturePos, .pos, φ => (asSomeFuture? φ).isSome
  | .someFutureNeg, .neg, φ => (asSomeFuture? φ).isSome
  | .somePastPos, .pos, φ => (asSomePast? φ).isSome
  | .somePastNeg, .neg, φ => (asSomePast? φ).isSome
  -- Until/Since rules (genuine, not someFuture/somePast)
  | .untlPos, .pos, φ => (asUntil? φ).isSome
  | .untlNeg, .neg, φ => (asUntil? φ).isSome
  | .sncePos, .pos, φ => (asSince? φ).isSome
  | .snceNeg, .neg, φ => (asSince? φ).isSome
  -- Order trichotomy: shape gate only. The real restriction (an incomparable sibling
  -- time under a common predecessor, carrying a formula the branch already constrains) is
  -- in `applyRule`, which has the branch and the ordering; `isApplicable` sees only the
  -- signed formula. Same split of labour as `z1Rule`. Conjunctions are excluded here
  -- because they are exactly this rule's own output.
  | .orderTrichotomy, .pos, φ => (asAnd? φ).isNone
  -- Dense-specific rules (gated by fc >= .Dense)
  | .denseIndicatorClosure, .pos, .untl (.imp .bot .bot) .bot =>
      decide (FrameClass.Dense ≤ fc)
  | .densityRule, .pos, .allFuture _ =>
      decide (FrameClass.Dense ≤ fc)
  -- Discrete-specific rules (gated by fc >= .Discrete)
  | .priorUZ, .pos, φ => decide (FrameClass.Discrete ≤ fc) && (asSomeFuture? φ).isSome
  | .priorSZ, .pos, φ => decide (FrameClass.Discrete ≤ fc) && (asSomePast? φ).isSome
  | .z1Rule, .pos, .allFuture _ => decide (FrameClass.Discrete ≤ fc)
  -- Dedekind (R6). All three trigger on the axiom's *antecedent conjunction* rather than on
  -- one of its conjuncts. Triggering on a conjunct loses a race: the conjuncts of
  -- `U(⊤,φ) ∧ F(¬φ)` are produced one expansion step apart, and the base rule that owns the
  -- first one (`untlPos`, `someFuturePos`) is consumable, so it destroys the antecedent
  -- before the other conjunct exists. The conjunction itself is what the branch actually
  -- carries at a single moment, and matching it makes each rule a 1:1 transcription of its
  -- axiom.
  | .priorUGap, .pos, φ => decide (FrameClass.Dedekind ≤ fc) && (asAnd? φ).isSome
  | .priorSGap, .pos, φ => decide (FrameClass.Dedekind ≤ fc) && (asAnd? φ).isSome
  | .sepRule, .pos, φ => decide (FrameClass.Dedekind ≤ fc) && (asAnd? φ).isSome
  | _, _, _ => false

/--
Helper: collect T(□A) and F(◇A) formulas at a specific world and time,
re-labeled to a fresh time. Used by time-creation rules to propagate
box persistence (□φ → G(□φ)) and diamond-neg persistence.
-/
private def boxDiamondPersistence (branch : Branch) (w : WorldIndex) (t : TimeIndex)
    (freshTime : TimeIndex) : List SignedFormula :=
  let boxProps := (branch.boxPosAtWorldTime w t).filterMap fun bsf =>
    let prop := { bsf with label := { bsf.label with time := freshTime } }
    if branch.contains prop then none else some prop
  let diaProps := (branch.diamondNegAtWorldTime w t).filterMap fun dsf =>
    let prop := { dsf with label := { dsf.label with time := freshTime } }
    if branch.contains prop then none else some prop
  boxProps ++ diaProps

/--
Apply a single tableau rule to a signed formula, in the context of the branch it
belongs to and the time ordering accumulated so far.

Returns the rule's outcome together with a possibly-extended time ordering:
`.linear fs` replaces the formula with `fs` on the same branch, `.branching bss`
splits the branch once per element of `bss`, `.persistent fs` adds `fs` while
keeping the formula, and `.notApplicable` means the rule does not match this
sign/connective pair. Rules that introduce a fresh time (the temporal and
diamond rules) are what extend the returned `TimeOrdering`.
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
      -- Cross-modal-temporal: propagate temporal universals at time l.time to fresh world
      let tempGProps := (branch.allFuturePosAtTime l.time).filterMap fun gsf =>
        let prop := { gsf with label := { gsf.label with world := freshWorld } }
        if branch.contains prop then none else some prop
      let tempHProps := (branch.allPastPosAtTime l.time).filterMap fun hsf =>
        let prop := { hsf with label := { hsf.label with world := freshWorld } }
        if branch.contains prop then none else some prop
      let tempFNegProps := (branch.someFutureNegAtTime l.time).filterMap fun fsf =>
        let prop := { fsf with label := { fsf.label with world := freshWorld } }
        if branch.contains prop then none else some prop
      let tempPNegProps := (branch.somePastNegAtTime l.time).filterMap fun psf =>
        let prop := { psf with label := { psf.label with world := freshWorld } }
        if branch.contains prop then none else some prop
      let tempUNegProps := (branch.untlNegAtTime l.time).filterMap fun usf =>
        let prop := { usf with label := { usf.label with world := freshWorld } }
        if branch.contains prop then none else some prop
      let tempSNegProps := (branch.snceNegAtTime l.time).filterMap fun ssf =>
        let prop := { ssf with label := { ssf.label with world := freshWorld } }
        if branch.contains prop then none else some prop
      let temporalProps :=
        tempGProps ++ tempHProps ++ tempFNegProps ++ tempPNegProps ++ tempUNegProps ++ tempSNegProps
      (.linear (witness :: boxProps ++ diaProps ++ temporalProps), timeOrd)
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
        -- Cross-modal-temporal: propagate temporal universals at time l.time to fresh world
        let tempGProps := (branch.allFuturePosAtTime l.time).filterMap fun gsf =>
          let prop := { gsf with label := { gsf.label with world := freshWorld } }
          if branch.contains prop then none else some prop
        let tempHProps := (branch.allPastPosAtTime l.time).filterMap fun hsf =>
          let prop := { hsf with label := { hsf.label with world := freshWorld } }
          if branch.contains prop then none else some prop
        let tempFNegProps := (branch.someFutureNegAtTime l.time).filterMap fun fsf =>
          let prop := { fsf with label := { fsf.label with world := freshWorld } }
          if branch.contains prop then none else some prop
        let tempPNegProps := (branch.somePastNegAtTime l.time).filterMap fun psf =>
          let prop := { psf with label := { psf.label with world := freshWorld } }
          if branch.contains prop then none else some prop
        let tempUNegProps := (branch.untlNegAtTime l.time).filterMap fun usf =>
          let prop := { usf with label := { usf.label with world := freshWorld } }
          if branch.contains prop then none else some prop
        let tempSNegProps := (branch.snceNegAtTime l.time).filterMap fun ssf =>
          let prop := { ssf with label := { ssf.label with world := freshWorld } }
          if branch.contains prop then none else some prop
        let temporalProps :=
          tempGProps ++ tempHProps ++ tempFNegProps ++ tempPNegProps ++ tempUNegProps ++
          tempSNegProps
        (.linear (witness :: boxProps ++ diaProps ++ temporalProps), timeOrd)
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
  -- T(□A) → derive T(GA) and T(HA) at the same label (modal-temporal interaction)
  -- Sound by boxToFuture (□φ → Gφ) and boxToPast (□φ → Hφ)
  | .boxTemporal, .pos, .box ψ =>
      let gFormula := SignedFormula.pos (Formula.allFuture ψ) l
      let hFormula := SignedFormula.pos (Formula.allPast ψ) l
      let newFormulas := [gFormula, hFormula].filter fun sf => !branch.contains sf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- T(GA) @ (w,t) → propagate T(A) to all known future times (universal, persistent)
  -- Strict inequality: G(A) at t means A holds at all t' > t
  | .allFuturePos, .pos, .allFuture ψ =>
      let futureTimes := timeOrd.futureOf l.time
      let newFormulas := futureTimes.filterMap fun t' =>
        let newSf := SignedFormula.pos ψ { world := l.world, time := t' }
        if branch.contains newSf then none else some newSf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- F(GA) @ (w,t) → F(A) at fresh future time (existential, consumable)
  -- ¬G(A) at t means there exists t' > t where ¬A
  | .allFutureNeg, .neg, .allFuture ψ =>
      let freshTime := branch.nextTime
      let freshLabel : Label := { world := l.world, time := freshTime }
      let newOrd := timeOrd.addFuture l.time freshTime
      -- The witness: F(A) at the fresh future time
      let witness := SignedFormula.neg ψ freshLabel
      -- Auto-propagate all T(GA) formulas from time t to freshTime
      let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
        match gsf.formula with
        | .allFuture inner =>
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
        | .someFuture inner =>
          if fsf.label.time == l.time then
            let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh future time
      let modalProps := boxDiamondPersistence branch l.world l.time freshTime
      (.linear (witness :: gProps ++ fNegProps ++ modalProps), newOrd)
  -- T(HA) @ (w,t) → propagate T(A) to all known past times (universal, persistent)
  -- Strict inequality: H(A) at t means A holds at all t' < t
  | .allPastPos, .pos, .allPast ψ =>
      let pastTimes := timeOrd.pastOf l.time
      let newFormulas := pastTimes.filterMap fun t' =>
        let newSf := SignedFormula.pos ψ { world := l.world, time := t' }
        if branch.contains newSf then none else some newSf
      if newFormulas.isEmpty then (.notApplicable, timeOrd)
      else (.persistent newFormulas, timeOrd)
  -- F(HA) @ (w,t) → F(A) at fresh past time (existential, consumable)
  -- ¬H(A) at t means there exists t' < t where ¬A
  | .allPastNeg, .neg, .allPast ψ =>
      let freshTime := branch.nextTime
      let freshLabel : Label := { world := l.world, time := freshTime }
      let newOrd := timeOrd.addPast l.time freshTime
      -- The witness: F(A) at the fresh past time
      let witness := SignedFormula.neg ψ freshLabel
      -- Auto-propagate all T(HA) formulas from time t to freshTime
      let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
        match hsf.formula with
        | .allPast inner =>
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
        | .somePast inner =>
          if psf.label.time == l.time then
            let prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        | _ => none
      -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh past time
      let modalProps := boxDiamondPersistence branch l.world l.time freshTime
      (.linear (witness :: hProps ++ pNegProps ++ modalProps), newOrd)
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
          | .allFuture inner =>
            if gsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(FA) formulas from time t to freshTime
        let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
          match fsf.formula with
          | .someFuture inner =>
            if fsf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh future time
        let modalProps := boxDiamondPersistence branch l.world l.time freshTime
        (.linear (witness :: gProps ++ fNegProps ++ modalProps), newOrd)
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
          | .allPast inner =>
            if hsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(PA) formulas from time t to freshTime
        let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
          match psf.formula with
          | .somePast inner =>
            if psf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh past time
        let modalProps := boxDiamondPersistence branch l.world l.time freshTime
        (.linear (witness :: hProps ++ pNegProps ++ modalProps), newOrd)
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
  -- T(U(event, guard)) @ (w,t) → branch: event-witness at fresh future time OR guard+continue
  -- Consumable: removed after application. Creates fresh time t' > t.
  -- Branch 1 (event witness): T(event) @ (w, t')
  -- Branch 2 (guard + continue): T(guard) @ (w, t'), T(U(event, guard)) @ (w, t')
  | .untlPos, .pos, φ =>
      match asUntil? φ with
      | some (event, guard) =>
        let freshTime := branch.nextTime
        let freshLabel : Label := { world := l.world, time := freshTime }
        let newOrd := timeOrd.addFuture l.time freshTime
        -- Branch 1: event witness at fresh future time
        let branch1 := [SignedFormula.pos event freshLabel]
        -- Branch 2: guard holds at fresh time + Until continues from fresh time
        let branch2 := [SignedFormula.pos guard freshLabel,
                         SignedFormula.pos (.untl event guard) freshLabel]
        -- Auto-propagate all T(GA) formulas to freshTime
        let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
          match gsf.formula with
          | .allFuture inner =>
            if gsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(FA) formulas to freshTime
        let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
          match fsf.formula with
          | .someFuture inner =>
            if fsf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(U(event', guard')) formulas to freshTime
        let untlNegProps := branch.untlNegFormulas.filterMap fun usf =>
          if usf.label.time == l.time then
            let prop :=
              SignedFormula.neg usf.formula { world := usf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh future time
        let modalProps := boxDiamondPersistence branch l.world l.time freshTime
        let autoProp := gProps ++ fNegProps ++ untlNegProps ++ modalProps
        (.branching [branch1 ++ autoProp, branch2 ++ autoProp], newOrd)
      | none => (.notApplicable, timeOrd)
  -- T(S(event, guard)) @ (w,t) → branch: event-witness at fresh past time OR guard+continue
  -- Consumable: removed after application. Creates fresh time t' < t.
  -- Branch 1 (event witness): T(event) @ (w, t')
  -- Branch 2 (guard + continue): T(guard) @ (w, t'), T(S(event, guard)) @ (w, t')
  | .sncePos, .pos, φ =>
      match asSince? φ with
      | some (event, guard) =>
        let freshTime := branch.nextTime
        let freshLabel : Label := { world := l.world, time := freshTime }
        let newOrd := timeOrd.addPast l.time freshTime
        -- Branch 1: event witness at fresh past time
        let branch1 := [SignedFormula.pos event freshLabel]
        -- Branch 2: guard holds at fresh time + Since continues from fresh time
        let branch2 := [SignedFormula.pos guard freshLabel,
                         SignedFormula.pos (.snce event guard) freshLabel]
        -- Auto-propagate all T(HA) formulas to freshTime
        let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
          match hsf.formula with
          | .allPast inner =>
            if hsf.label.time == l.time then
              let prop := SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(PA) formulas to freshTime
        let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
          match psf.formula with
          | .somePast inner =>
            if psf.label.time == l.time then
              let prop := SignedFormula.neg inner { world := psf.label.world, time := freshTime }
              if branch.contains prop then none else some prop
            else none
          | _ => none
        -- Auto-propagate all F(S(event', guard')) formulas to freshTime
        let snceNegProps := branch.snceNegFormulas.filterMap fun ssf =>
          if ssf.label.time == l.time then
            let prop :=
              SignedFormula.neg ssf.formula { world := ssf.label.world, time := freshTime }
            if branch.contains prop then none else some prop
          else none
        -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh past time
        let modalProps := boxDiamondPersistence branch l.world l.time freshTime
        let autoProp := hProps ++ pNegProps ++ snceNegProps ++ modalProps
        (.branching [branch1 ++ autoProp, branch2 ++ autoProp], newOrd)
      | none => (.notApplicable, timeOrd)
  -- F(U(event, guard)) @ (w,t) → Reynolds co-decomposition at future times
  -- Persistent: source formula re-included in both branches.
  -- PASSIVE mode: For each known future time t' > t, branch:
  --   Branch 1: F(event) @ (w, t'), source re-included
  --   Branch 2: F(guard) @ (w, t'), F(U(event, guard)) @ (w, t'), source re-included
  -- ACTIVE mode: When no future times exist, create a fresh future time and
  --   perform Reynolds co-decomposition there with full auto-propagation.
  | .untlNeg, .neg, φ =>
      match asUntil? φ with
      | some (event, guard) =>
        let futureTimes := timeOrd.futureOf l.time
        -- Find first unprocessed future time (where decomposition hasn't been done yet)
        let unprocessed := futureTimes.filter fun t' =>
          let negEvent := SignedFormula.neg event { world := l.world, time := t' }
          let negGuard := SignedFormula.neg guard { world := l.world, time := t' }
          !branch.contains negEvent && !branch.contains negGuard
        match unprocessed with
        | [] =>
          if futureTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4 then
            -- ACTIVE: no future times exist at all — create fresh future time
            -- for Reynolds decomposition (Skolem witness for universal quantifier)
            -- Guard: limit fresh time point creation to prevent runaway chains
            --. Without this guard, standalone temporal formulas create
            -- exponential branching chains that exhaust fuel.
            let freshTime := branch.nextTime
            let freshLabel : Label := { world := l.world, time := freshTime }
            let newOrd := timeOrd.addFuture l.time freshTime
            -- Auto-propagate T(GA) formulas from time t to freshTime
            let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
              match gsf.formula with
              | .allFuture inner =>
                if gsf.label.time == l.time then
                  let prop :=
                    SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
                  if branch.contains prop then none else some prop
                else none
              | _ => none
            -- Auto-propagate F(FA) formulas from time t to freshTime
            let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
              match fsf.formula with
              | .someFuture inner =>
                if fsf.label.time == l.time then
                  let prop :=
                    SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
                  if branch.contains prop then none else some prop
                else none
              | _ => none
            -- Auto-propagate OTHER F(U(event', guard')) formulas to freshTime
            let untlNegProps := branch.untlNegFormulas.filterMap fun usf =>
              if usf.label.time == l.time && usf != sf then
                let prop :=
                  SignedFormula.neg usf.formula { world := usf.label.world, time := freshTime }
                if branch.contains prop then none else some prop
              else none
            -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh future time
            let modalProps := boxDiamondPersistence branch l.world l.time freshTime
            let autoProp := gProps ++ fNegProps ++ untlNegProps ++ modalProps
            -- Reynolds co-decomposition at the fresh time
            let branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp
            let branch2 := [SignedFormula.neg guard freshLabel,
                             SignedFormula.neg (.untl event guard) freshLabel, sf] ++ autoProp
            (.branching [branch1, branch2], newOrd)
          else
            -- All existing future times processed, or depth limit reached
            (.notApplicable, timeOrd)
        | t' :: _ =>
          let targetLabel : Label := { world := l.world, time := t' }
          -- Branch 1: event fails at t', source formula re-included for persistence
          let branch1 := [SignedFormula.neg event targetLabel, sf]
          -- Branch 2: guard fails at t' AND Until propagated to t', source re-included
          let branch2 := [SignedFormula.neg guard targetLabel,
                           SignedFormula.neg (.untl event guard) targetLabel, sf]
          (.branching [branch1, branch2], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- F(S(event, guard)) @ (w,t) → Reynolds co-decomposition at past times
  -- Persistent: source formula re-included in both branches.
  -- PASSIVE mode: For each known past time t' < t, branch:
  --   Branch 1: F(event) @ (w, t'), source re-included
  --   Branch 2: F(guard) @ (w, t'), F(S(event, guard)) @ (w, t'), source re-included
  -- ACTIVE mode: When no past times exist, create a fresh past time and
  --   perform Reynolds co-decomposition there with full auto-propagation.
  | .snceNeg, .neg, φ =>
      match asSince? φ with
      | some (event, guard) =>
        let pastTimes := timeOrd.pastOf l.time
        -- Find first unprocessed past time
        let unprocessed := pastTimes.filter fun t' =>
          let negEvent := SignedFormula.neg event { world := l.world, time := t' }
          let negGuard := SignedFormula.neg guard { world := l.world, time := t' }
          !branch.contains negEvent && !branch.contains negGuard
        match unprocessed with
        | [] =>
          if pastTimes.isEmpty && timeOrd.timeCount > 0 && timeOrd.timeCount < 4 then
            -- ACTIVE: no past times exist at all — create fresh past time
            -- for Reynolds co-decomposition (Skolem witness for universal quantifier)
            -- Guard: limit fresh time point creation to prevent runaway chains
            --. Same guard as untlNeg active case above.
            let freshTime := branch.nextTime
            let freshLabel : Label := { world := l.world, time := freshTime }
            let newOrd := timeOrd.addPast l.time freshTime
            -- Auto-propagate T(HA) formulas from time t to freshTime
            let hProps := branch.allPastPosFormulas.filterMap fun hsf =>
              match hsf.formula with
              | .allPast inner =>
                if hsf.label.time == l.time then
                  let prop :=
                    SignedFormula.pos inner { world := hsf.label.world, time := freshTime }
                  if branch.contains prop then none else some prop
                else none
              | _ => none
            -- Auto-propagate F(PA) formulas from time t to freshTime
            let pNegProps := branch.somePastNegFormulas.filterMap fun psf =>
              match psf.formula with
              | .somePast inner =>
                if psf.label.time == l.time then
                  let prop :=
                    SignedFormula.neg inner { world := psf.label.world, time := freshTime }
                  if branch.contains prop then none else some prop
                else none
              | _ => none
            -- Auto-propagate OTHER F(S(event', guard')) formulas to freshTime
            let snceNegProps := branch.snceNegFormulas.filterMap fun ssf =>
              if ssf.label.time == l.time && ssf != sf then
                let prop :=
                  SignedFormula.neg ssf.formula { world := ssf.label.world, time := freshTime }
                if branch.contains prop then none else some prop
              else none
            -- Cross-modal-temporal: propagate T(□A) and F(◇A) to fresh past time
            let modalProps := boxDiamondPersistence branch l.world l.time freshTime
            let autoProp := hProps ++ pNegProps ++ snceNegProps ++ modalProps
            -- Reynolds co-decomposition at the fresh time
            let branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp
            let branch2 := [SignedFormula.neg guard freshLabel,
                             SignedFormula.neg (.snce event guard) freshLabel, sf] ++ autoProp
            (.branching [branch1, branch2], newOrd)
          else
            -- All existing past times processed, or depth limit reached
            (.notApplicable, timeOrd)
        | t' :: _ =>
          let targetLabel : Label := { world := l.world, time := t' }
          -- Branch 1: event fails at t', source formula re-included for persistence
          let branch1 := [SignedFormula.neg event targetLabel, sf]
          -- Branch 2: guard fails at t' AND Since propagated to t', source re-included
          let branch2 := [SignedFormula.neg guard targetLabel,
                           SignedFormula.neg (.snce event guard) targetLabel, sf]
          (.branching [branch1, branch2], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Order trichotomy (R2, repairs D2): branch on the relative order of two incomparable
  -- times that share a common past.
  --
  -- **Why the branches are syntactically the BX11 disjuncts.** `temp_linearity`
  -- (`Axioms.lean:238`) is `F φ ∧ F ψ → F(φ ∧ ψ) ∨ F(φ ∧ F ψ) ∨ F(F φ ∧ ψ)`, and those three
  -- disjuncts *are* the trichotomy on two future witnesses: they coincide, the φ-witness
  -- comes first, or the ψ-witness comes first. Emitting them verbatim rather than as fresh
  -- ordering constraints keeps the rule's admissibility obligation a single appeal to BX11
  -- instead of a semantic argument about `TimeOrdering`, and it is the form the Phase 3
  -- `RuleSpec` gate maps to `Axiom.temp_linearity`.
  --
  -- **Why the trigger is a witness formula and not the eventuality.** The obvious trigger —
  -- `T(F φ)` with a partner `T(F ψ)` at the same label — never fires in practice, because
  -- `someFuturePos` is consumable: on `F φ ∧ F ψ → …` the branch reaches
  -- `T(F φ) @ t0` while `T(F ψ) @ t0` is still buried inside an undecomposed conjunction,
  -- `someFuturePos` consumes `T(F φ)` immediately, and the pair never coexists. The rule
  -- therefore triggers on the *witness*: a positive formula `T(φ) @ (w, t1)` looks back for
  -- a common predecessor `t0` and sideways for an incomparable sibling `t2` carrying
  -- `T(ψ)`, which is exactly the D2 configuration (two fresh times, both after `t0`, with
  -- no order between them).
  --
  -- **Branching restriction (the `3^k` containment).**
  --
  -- 1. *Incomparable time pairs.* `t1 ≠ t2`, neither is in the other's transitive future or
  --    past, and both lie in `futureOf t0`. The common predecessor is required because the
  --    BX11 instance being used is the one *at* `t0`: without it there is no point at which
  --    `F φ ∧ F ψ` holds and the split is not an axiom instance at all.
  -- 2. *Shared world.* `t1`, `t2` and `t0` are read at `l.world` throughout. Times are
  --    world-indexed here, so a pair drawn across two worlds is not a temporal-order
  --    question.
  -- 3. *Shared temporal formula (analytic restriction).* The split fires only when the
  --    branch already carries, at `(w, t0)`, the negation of at least one of the three
  --    disjuncts. This is what makes the rule analytic with respect to the branch: it never
  --    introduces a BX11 instance that no formula on the branch is about, so the branching
  --    is bounded by the negated eventualities present rather than by the square of the
  --    formulas at incomparable times. It is a genuine restriction, and it is the one the
  --    plan's Risk 1 flags for re-examination: if a conformance row that should CLOSE stays
  --    OPEN, this guard is the first suspect.
  -- 4. *No re-firing, in two halves.* A split must not repeat for a pair whose order the
  --    branch has already fixed, and the evidence for "already fixed" changes shape as the
  --    branch grows, so both halves are needed:
  --      (a) one of the three disjuncts is still present, positive, at some time of this
  --          world — the split fired and its conclusion has not yet been decomposed;
  --      (b) the conclusion *has* been decomposed: `someFuturePos` consumed the disjunct
  --          and left witnesses, so some φ-time and some ψ-time after `t0` are now equal
  --          or ordered. This is the half that makes the rule terminate. Guard (a) alone
  --          is not enough precisely because `someFuturePos` is consumable: the disjunct
  --          it removes was the only record that the pair had been split, so the trigger
  --          recurs at the freshly created time and the branch regresses without bound.
  --          Measured with only (a): counterexample B and the plain `F p ∧ F q` corpus
  --          rows STALLED at fuel 20000, the trace showing `orderTrichotomy` firing once
  --          per newly created time. Guard (b) is also the exact statement of what the
  --          rule is for — once the two witness sets are comparable, the trichotomy has
  --          been decided and there is nothing left to branch on.
  --    Guards (a) and (b) together still leave a window: the split's conclusion can be
  --    consumed by `someFuturePos` and its witness only *partly* decomposed, so that for a
  --    step or two neither (a) nor (b) holds and the pair re-fires at the newly created
  --    time. The third half closes it — *first witnesses only*: the pair fires only while
  --    each operand has at most one witness after `t0`. A second φ-witness can only exist
  --    because something already produced one, which is precisely the state the split was
  --    meant to reach. This is what makes the branch count finite: without it the trace
  --    shows `orderTrichotomy` firing at time 2, 3, 4, … forever, one new direct successor
  --    of `t0` per firing.
  --
  -- Neither operand may be a conjunction: every formula this rule produces has a
  -- conjunction under the `F`, so that restriction is exactly "the rule does not consume
  -- its own output".
  --
  -- The trigger formula is re-added to each branch (`.branching` deletes the expanded
  -- formula, and a witness atom must survive to close the branch against its negation).
  | .orderTrichotomy, .pos, φ =>
      if (asAnd? φ).isSome then (.notApplicable, timeOrd)
      else
        let disjuncts : Formula → Formula → List Formula := fun x y =>
          [ Formula.someFuture (Formula.and x y)
          , Formula.someFuture (Formula.and x (Formula.someFuture y))
          , Formula.someFuture (Formula.and (Formula.someFuture x) y) ]
        -- Positive, non-conjunctive formulas carried by a sibling time.
        let carriedAt : TimeIndex → List Formula := fun t =>
          branch.filterMap fun sf' =>
            match sf'.sign with
            | .pos =>
                if sf'.label.world == l.world && sf'.label.time == t
                    && (asAnd? sf'.formula).isNone then some sf'.formula else none
            | _ => none
        let futs := timeOrd.futureOf l.time
        let pasts := timeOrd.pastOf l.time
        -- Restriction 1+2: incomparable siblings under a common predecessor, same world.
        let candidates : List (TimeIndex × Formula) :=
          pasts.flatMap fun t0 =>
            let siblings := (timeOrd.futureOf t0).filter fun t2 =>
              t2 != l.time && !futs.contains t2 && !pasts.contains t2
            siblings.flatMap fun t2 => (carriedAt t2).map fun ψ => (t0, ψ)
        -- Restriction 4a: the split's own output is still on the branch, unconsumed.
        let firedAlready : Formula → Bool := fun d =>
          branch.any fun sf' =>
            sf'.sign == Sign.pos && sf'.label.world == l.world && sf'.formula == d
        -- Restriction 4b: the split's output has been consumed but its witnesses survive —
        -- some φ-time and ψ-time after `t0` are now ordered or identical.
        let witnessesOf : TimeIndex → Formula → List TimeIndex := fun t0 χ =>
          (timeOrd.futureOf t0).filter fun t =>
            branch.contains (SignedFormula.pos χ { world := l.world, time := t })
        let settled : TimeIndex → Formula → Bool := fun t0 ψ =>
          (witnessesOf t0 φ).any fun a => (witnessesOf t0 ψ).any fun b =>
            a == b || (timeOrd.futureOf a).contains b || (timeOrd.pastOf a).contains b
        let fires : TimeIndex × Formula → Bool := fun (t0, ψ) =>
          let l0 : Label := { world := l.world, time := t0 }
          let ds := disjuncts φ ψ
          !(ds.any firedAlready) && !settled t0 ψ
            && (witnessesOf t0 φ).length <= 1 && (witnessesOf t0 ψ).length <= 1
            && (ds.any fun d => branch.contains (SignedFormula.neg d l0))
        match candidates.find? fires with
        | none => (.notApplicable, timeOrd)
        | some (t0, ψ) =>
            let l0 : Label := { world := l.world, time := t0 }
            (.branching ((disjuncts φ ψ).map fun d => [SignedFormula.pos d l0, sf]), timeOrd)
  -- Dense: T(U(⊤,⊥)) closes the branch on dense frames
  -- U(⊤,⊥) asserts "⊥ holds until ⊤" which requires an immediate successor,
  -- but ¬U(⊤,⊥) is a Dense axiom (no immediate successors on dense frames).
  | .denseIndicatorClosure, .pos, .untl (.imp .bot .bot) .bot =>
      -- Close branch: T(U(top, bot)) contradicts density
      -- Return as linear with empty list -- the closure will be detected by checkAxiomNeg
      -- since F(¬U(top, bot)) is the dense_indicator axiom
      (.linear [], timeOrd)
  -- Dense: T(G(φ)) at (w,t) with known future time → introduce intermediate point
  -- On a dense frame, for any t' > t there exists t'' with t < t'' < t', so Gφ at t gives φ at t''.
  | .densityRule, .pos, .allFuture ψ =>
      let futureTimes := timeOrd.futureOf l.time
      match futureTimes with
      | [] => (.notApplicable, timeOrd)  -- No future times to interpolate
      | t' :: _ =>
        -- Check if we already have an intermediate time between l.time and t'
        -- Only add if not already present (to avoid infinite loops)
        let existingIntermediates := timeOrd.futureOf l.time |>.filter fun t'' =>
          timeOrd.futureOf t'' |>.any (· == t')
        if existingIntermediates.isEmpty then
          let freshTime := branch.nextTime
          let freshLabel : Label := { world := l.world, time := freshTime }
          -- Add t < freshTime < t' to the ordering
          let newOrd := (timeOrd.addFuture l.time freshTime).addFuture freshTime t'
          -- The intermediate point gets T(ψ) from G(ψ) at l.time
          let witness := SignedFormula.pos ψ freshLabel
          -- Also propagate all T(G(A)) from l.time to the intermediate
          let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
            match gsf.formula with
            | .allFuture inner =>
              if gsf.label.time == l.time && gsf.formula != .allFuture ψ then
                let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
                if branch.contains prop then none else some prop
              else none
            | _ => none
          (.persistent (witness :: gProps), newOrd)
        else
          (.notApplicable, timeOrd)
  -- Discrete: T(F(φ)) → T(U(φ, ¬φ))
  -- On discrete frames, F(φ) implies there is a nearest φ-point reachable by Until
  | .priorUZ, .pos, φ =>
      match asSomeFuture? φ with
      | some ψ =>
        let untilFormula := Formula.untl ψ ψ.neg
        let newSf := SignedFormula.pos untilFormula l
        if branch.contains newSf then (.notApplicable, timeOrd)
        else (.persistent [newSf], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Discrete: T(P(φ)) → T(S(φ, ¬φ))
  -- On discrete frames, P(φ) implies there is a nearest φ-point reachable by Since
  | .priorSZ, .pos, φ =>
      match asSomePast? φ with
      | some ψ =>
        let sinceFormula := Formula.snce ψ ψ.neg
        let newSf := SignedFormula.pos sinceFormula l
        if branch.contains newSf then (.notApplicable, timeOrd)
        else (.persistent [newSf], timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Discrete: Z1 backward induction
  -- When T(G(G(φ) → φ)) and T(F(G(φ))) both at same label, add T(G(φ))
  | .z1Rule, .pos, .allFuture φ_inner =>
      -- Check if sf matches T(G(G(φ) → φ)) pattern
      match φ_inner with
      | .imp (.imp (.untl (.imp inner .bot) (.imp .bot .bot)) .bot) rhs =>
        -- This is G(G(inner) → rhs) -- verify rhs = inner
        if inner == rhs then
          -- Look for T(F(G(inner))) on the branch at the same label
          let gInner := Formula.allFuture inner
          let fgFormula := Formula.someFuture gInner
          let fgSf := SignedFormula.pos fgFormula l
          if branch.contains fgSf then
            let newSf := SignedFormula.pos gInner l
            if branch.contains newSf then (.notApplicable, timeOrd)
            else (.persistent [newSf], timeOrd)
          else (.notApplicable, timeOrd)
        else (.notApplicable, timeOrd)
      | _ => (.notApplicable, timeOrd)
  -- Dedekind: Prior-U (gap form), `Axiom.prior_U_gap`.
  -- `U(⊤,φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)`: the φ-region ends, and its right endpoint is
  -- definable by `K⁺` ("¬φ holds arbitrarily soon after"). The rule adds the consequent and
  -- keeps its trigger, so the base rules still decompose the conjunction normally.
  | .priorUGap, .pos, χ =>
      match asAnd? χ with
      | some (a, b) =>
          match a with
          | .untl e g =>
              if e == Formula.top
                  && b == Formula.someFuture (Formula.neg g) then
                let concl :=
                  Formula.untl (Formula.or (Formula.neg g) (Formula.kPlus (Formula.neg g))) g
                let newSf := SignedFormula.pos concl l
                if branch.contains newSf then (.notApplicable, timeOrd)
                else (.persistent [newSf], timeOrd)
              else (.notApplicable, timeOrd)
          | _ => (.notApplicable, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Dedekind: Prior-S (gap form), `Axiom.prior_S_gap`. Past dual of `priorUGap`.
  | .priorSGap, .pos, χ =>
      match asAnd? χ with
      | some (a, b) =>
          match a with
          | .snce e g =>
              if e == Formula.top
                  && b == Formula.somePast (Formula.neg g) then
                let concl :=
                  Formula.snce (Formula.or (Formula.neg g) (Formula.kMinus (Formula.neg g))) g
                let newSf := SignedFormula.pos concl l
                if branch.contains newSf then (.notApplicable, timeOrd)
                else (.persistent [newSf], timeOrd)
              else (.notApplicable, timeOrd)
          | _ => (.notApplicable, timeOrd)
      | none => (.notApplicable, timeOrd)
  -- Dedekind: separation, `Axiom.sep`.
  -- `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)`. `K⁺ψ` unfolds to
  -- `(U(⊤, ¬ψ)) → ⊥`, which is the shape matched on `a` below; matching `Formula.top`
  -- as an equality rather than as a pattern keeps this independent of how `top` is defined.
  | .sepRule, .pos, χ =>
      match asAnd? χ with
      | some (a, b) =>
          match a with
          | .imp (.untl e (.imp ψ .bot)) .bot =>
              if e == Formula.top
                  && b == Formula.neg
                        (Formula.kPlus (Formula.and ψ (Formula.untl ψ (Formula.neg ψ)))) then
                let concl :=
                  Formula.kPlus (Formula.and (Formula.kPlus ψ) (Formula.kMinus ψ))
                let newSf := SignedFormula.pos concl l
                if branch.contains newSf then (.notApplicable, timeOrd)
                else (.persistent [newSf], timeOrd)
              else (.notApplicable, timeOrd)
          | _ => (.notApplicable, timeOrd)
      | none => (.notApplicable, timeOrd)
  | _, _, _ => (.notApplicable, timeOrd)

/--
`RuleResult.branching` is never equal to `RuleResult.notApplicable`.
-/
@[simp] theorem RuleResult.branching_ne_notApplicable (bs : List (List SignedFormula)) :
    RuleResult.branching bs ≠ RuleResult.notApplicable := by
  exact nofun

/--
`RuleResult.linear` is never equal to `RuleResult.notApplicable`.
-/
@[simp] theorem RuleResult.linear_ne_notApplicable (fs : List SignedFormula) :
    RuleResult.linear fs ≠ RuleResult.notApplicable := by
  exact nofun

/--
`RuleResult.persistent` is never equal to `RuleResult.notApplicable`.
-/
@[simp] theorem RuleResult.persistent_ne_notApplicable (fs : List SignedFormula) :
    RuleResult.persistent fs ≠ RuleResult.notApplicable := by
  exact nofun

/-!
## Applied-Set Tracking

Persistent rules (boxPos, diamondNeg, allFuturePos, allPastPos, boxTemporal,
someFutureNeg, somePastNeg, untlNeg, snceNeg) keep their source formula on the
branch and propagate consequences. If a consumable rule later removes a propagated
formula, the persistent rule sees it as "new" and re-adds it, creating an infinite
loop. The `AppliedSet` tracks signed formulas that have already been produced by
persistent rules. When a persistent rule's output formulas are ALL already in the
applied set, the rule is treated as not applicable.
-/

/-- Set of signed formulas already produced by persistent rule applications.
    Used to prevent infinite cycling between persistent and consumable rules. -/
abbrev AppliedSet := Std.HashSet SignedFormula

/-!
## Branch Expansion
-/

/--
All base tableau rules in priority order (frame-class independent).
Propositional rules are tried first, then modal, then temporal.
-/
def allRules : List TableauRule := [
  .negPos, .negNeg,      -- Negation (simplest)
  .impNeg,               -- F(A → B) non-branching
  .andPos, .orNeg,       -- Non-branching compound
  .boxPos, .boxNeg,      -- Modal
  .diamondPos, .diamondNeg,
  .boxTemporal,                    -- Modal-temporal interaction (before temporal rules)
  .allFuturePos, .allFutureNeg,  -- Temporal G/H
  .allPastPos, .allPastNeg,
  .someFuturePos, .someFutureNeg,  -- Temporal F/P
  .somePastPos, .somePastNeg,
  .untlPos, .untlNeg,             -- Until (genuine, not someFuture)
  .sncePos, .snceNeg,             -- Since (genuine, not somePast)
  .impPos,               -- Branching implication
  .andNeg, .orPos,       -- Branching compound
  -- Order trichotomy last: it triggers on witness formulas (typically atoms, which no
  -- other rule touches), so every cheaper decomposition is exhausted before a 3-way
  -- linearity split is considered.
  .orderTrichotomy
]

/--
Dense-specific rules, included only when fc >= .Dense.
-/
def denseRules : List TableauRule := [
  .denseIndicatorClosure,
  .densityRule
]

/--
Discrete-specific rules, included only when fc >= .Discrete.
-/
def discreteRules : List TableauRule := [
  .priorUZ, .priorSZ,
  .z1Rule
]

/--
Dedekind-specific rules (R6), included only when fc >= .Dedekind.

The tableau counterparts of `Axiom.prior_U_gap`, `Axiom.prior_S_gap` and `Axiom.sep`
(`Axioms.lean:377,387,398`) — the three axioms whose gap/separation content no other rule
touches, and the reason `Discrete ≰ Dedekind` is the correct gating rather than a defect:
the Dedekind terminus consumes `ValidDedekindDense`, so its arm is base + dense + dedekind
and never includes the Discrete rules.
-/
def dedekindRules : List TableauRule := [
  .priorUGap, .priorSGap, .sepRule
]

/--
All tableau rules for a given frame class, in priority order.
Base rules are always included; Dense/Discrete rules are appended
when the frame class supports them.
-/
def allRulesForFC (fc : FrameClass := .Base) : List TableauRule :=
  let base := allRules
  let dense := if decide (FrameClass.Dense ≤ fc) then denseRules else []
  let discrete := if decide (FrameClass.Discrete ≤ fc) then discreteRules else []
  let dedekind := if decide (FrameClass.Dedekind ≤ fc) then dedekindRules else []
  -- The Dedekind rules come FIRST, ahead of the base rules. They are persistent, they fire
  -- at most once per label (each checks `branch.contains` on its own conclusion), and they
  -- trigger on a conjunction that the consumable propositional rules destroy on their very
  -- next step. Appending them, as the Dense and Discrete arms are appended, would mean
  -- `negPos` decomposes `T(U(⊤,φ) ∧ F(¬φ))` before `priorUGap` is ever consulted and the
  -- rules would be dead code. Nothing else depends on their position: a persistent rule
  -- that adds one formula and then reports `notApplicable` cannot pre-empt any other rule.
  dedekind ++ base ++ dense ++ discrete

/-!
## Uniform Branch Guards

The persistent rules have always been self-guarded: each one filters its own output against
`branch.contains` and reports `.notApplicable` when nothing new remains. The `.linear` and
`.branching` rules were not, and did not need to be — they were *destructive*, deleting their
source from the branch, so they could not re-fire.

Destruction is what made the applied set necessary, and it made it necessary for a reason
that has nothing to do with the persistent rules themselves. `boxPos` produces `T(¬p)`;
`negPos` consumes `T(¬p)`; `boxPos`'s own guard now sees its output missing and re-emits it;
`negPos` consumes it again. The cycle is driven by the consumable rule deleting the persistent
rule's output, not by the persistent rule ignoring the branch.

So the fix is to stop deleting, and to give the consumable arms the guard the persistent arms
already have. `untlNeg` and `snceNeg` are the in-repo precedent: both re-include their source
formula in every arm and are guarded by their own `unprocessed` filter, and both have always
been non-destructive.

**The fresh-label complication.** Eight rules mint a fresh world or a fresh time, so their
outputs live at a label that by construction is not on the branch. `fs.all branch.contains`
can therefore never suppress them, and non-destructive application would mint labels forever.
For those eight, output-presence is replaced by *witness existence*: the rule is suppressed
when the branch already carries a witness of the right shape at some already-known world (for
the modal rules) or at some already-ordered time (for the temporal ones). This is the standard
"do not duplicate an existing witness" restriction and is satisfiability-preserving in both
directions, exactly as the output-presence guard is.

`densityRule` also mints a fresh time but is deliberately absent from the list below: it
carries its own equivalent guard (`existingIntermediates.isEmpty`), which is the same test
specialised to the intermediate it would create.

With both guards in place every expansion step strictly adds at least one formula the branch
did not have, so branch length is a strict progress measure and the applied set has no work
left to do.
-/

/--
Rules whose output lives at a freshly-minted world or time, and which therefore cannot be
suppressed by testing their output against the branch.

`densityRule` mints a fresh time too but is not listed: its `existingIntermediates` guard is
already the witness test specialised to its own witness shape.
-/
def ruleMintsFreshLabel : TableauRule → Bool
  | .boxNeg | .diamondPos | .allFutureNeg | .allPastNeg
  | .someFuturePos | .somePastPos | .untlPos | .sncePos => true
  | _ => false

/--
Rules that already suppress themselves, and so need no guard added in `findApplicableRule`.

`untlNeg` and `snceNeg` return `.branching`, but they filter the times they act on through
their own `unprocessed` test — a target time counts only when *neither* co-decomposition
output is on the branch yet — and they re-include the source formula in every arm. They are
therefore self-guarded and non-destructive already, by exactly the argument that makes the
`.persistent` arms self-guarded. Re-guarding them here would add nothing operationally (the
outer test can never fire where the inner filter has already passed) while putting an extra
`if` between the saturation lemmas and the filter structure they read.
-/
def ruleSelfGuarded : TableauRule → Bool
  | .untlNeg | .snceNeg => true
  | _ => false

/--
Does the branch already carry a witness for this fresh-label rule at this formula?

The witness test per rule, at label `(w, t)`:

- `boxNeg` / `diamondPos` — the modal accessibility relation is universal (S5), so any known
  world serves: some `w'` with `F(ψ) @ (w', t)` (resp. `T(ψ) @ (w', t)`) on the branch.
- `allFutureNeg` / `someFuturePos` — some `t'` strictly after `t` in the *transitive* ordering
  carrying `F(ψ)` (resp. `T(ψ)`) at `w`.
- `allPastNeg` / `somePastPos` — the past-directed mirrors.
- `untlPos` / `sncePos` — either arm counts, since the rule's conclusion is a disjunction: a
  future (resp. past) time carrying the event witness, or one carrying both the guard and the
  Until/Since itself.

Returns `false` for every other rule, so it is only ever consulted behind
`ruleMintsFreshLabel`.
-/
def witnessPresent (rule : TableauRule) (sf : SignedFormula) (branch : Branch)
    (timeOrd : TimeOrdering) : Bool :=
  let l := sf.label
  match rule, sf.sign, sf.formula with
  | .boxNeg, .neg, .box ψ =>
      branch.knownWorlds.any fun w =>
        branch.contains (SignedFormula.neg ψ { world := w, time := l.time })
  | .diamondPos, .pos, φ =>
      match asDiamond? φ with
      | some ψ =>
          branch.knownWorlds.any fun w =>
            branch.contains (SignedFormula.pos ψ { world := w, time := l.time })
      | none => false
  | .allFutureNeg, .neg, .allFuture ψ =>
      (timeOrd.futureOf l.time).any fun t =>
        branch.contains (SignedFormula.neg ψ { world := l.world, time := t })
  | .allPastNeg, .neg, .allPast ψ =>
      (timeOrd.pastOf l.time).any fun t =>
        branch.contains (SignedFormula.neg ψ { world := l.world, time := t })
  | .someFuturePos, .pos, φ =>
      match asSomeFuture? φ with
      | some ψ =>
          (timeOrd.futureOf l.time).any fun t =>
            branch.contains (SignedFormula.pos ψ { world := l.world, time := t })
      | none => false
  | .somePastPos, .pos, φ =>
      match asSomePast? φ with
      | some ψ =>
          (timeOrd.pastOf l.time).any fun t =>
            branch.contains (SignedFormula.pos ψ { world := l.world, time := t })
      | none => false
  | .untlPos, .pos, φ =>
      match asUntil? φ with
      | some (event, guard) =>
          (timeOrd.futureOf l.time).any fun t =>
            let lab : Label := { world := l.world, time := t }
            branch.contains (SignedFormula.pos event lab) ||
              (branch.contains (SignedFormula.pos guard lab) &&
               branch.contains (SignedFormula.pos (.untl event guard) lab))
      | none => false
  | .sncePos, .pos, φ =>
      match asSince? φ with
      | some (event, guard) =>
          (timeOrd.pastOf l.time).any fun t =>
            let lab : Label := { world := l.world, time := t }
            branch.contains (SignedFormula.pos event lab) ||
              (branch.contains (SignedFormula.pos guard lab) &&
               branch.contains (SignedFormula.pos (.snce event guard) lab))
      | none => false
  | _, _, _ => false

/--
Find a rule that applies to a signed formula.
Returns the first applicable rule, its result, and the updated TimeOrdering.

Every arm is branch-guarded: a rule whose conclusion the branch already carries is not
"applicable", so `findApplicableRule … = none` is a genuine downward-saturation statement
rather than a statement about what the engine happens to have tried. See the
"Uniform Branch Guards" section above for why the `.linear`/`.branching` guards must exist
and why the eight fresh-label rules use witness existence instead of output presence.
-/
def findApplicableRule (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Option (TableauRule × RuleResult × TimeOrdering) :=
  (allRulesForFC fc).findSome? fun rule =>
    if isApplicable rule sf fc then
      let (result, newOrd) := applyRule rule sf branch timeOrd
      match result with
      | .notApplicable => none
      | .linear fs =>
          if ruleMintsFreshLabel rule then
            if witnessPresent rule sf branch timeOrd then none
            else some (rule, result, newOrd)
          else if fs.all branch.contains then none
          else some (rule, result, newOrd)
      | .persistent _ =>
          -- No guard here, deliberately. Every `.persistent` arm of `applyRule` already
          -- filters its own output against `branch.contains` and returns `.notApplicable`
          -- when nothing new remains (the sole exception, `densityRule`, emits at a fresh
          -- time, so its output cannot be on the branch and it carries an equivalent
          -- `existingIntermediates` guard instead). A `fs.all branch.contains` test here
          -- would therefore always be false and never fire. Adding it anyway would be
          -- harmless operationally but would put an extra `if` between every saturation
          -- lemma and the rule's own filter structure, which is precisely what those
          -- lemmas read to extract their conclusion.
          some (rule, result, newOrd)
      | .branching bss =>
          -- Symmetric with the `.linear` arm: a fresh-label rule is tested for witness
          -- existence *instead of* output presence, never in addition to it. Its arms all
          -- live at a label the branch does not have, so the output-presence test could
          -- never fire there anyway; running both would only put a dead `if` between the
          -- saturation lemmas and the witness condition they need to read off.
          if ruleSelfGuarded rule then some (rule, result, newOrd)
          else if ruleMintsFreshLabel rule then
            (if witnessPresent rule sf branch timeOrd then none else some (rule, result, newOrd))
          else if bss.any (fun fs => fs.all branch.contains) then none
          else some (rule, result, newOrd)
    else none

/--
Check if a signed formula is fully expanded (no rules apply).
Atoms, bot with appropriate signs, and already-reduced formulas are expanded.
-/
def isExpanded (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Bool :=
  (findApplicableRule sf branch timeOrd fc).isNone

/--
Find an unexpanded formula in a branch.
Returns the first formula that can still be expanded.
-/
def findUnexpanded (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Option SignedFormula :=
  b.find? (fun sf => ¬isExpanded sf b timeOrd fc)

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

**Non-destructive.** No arm deletes the source formula. The `.linear` and `.branching` arms
used to (`remaining := b.filter (· != sf)`), which is what created the persistent/consumable
cycle the applied set was invented to suppress: a consumable rule would delete a formula a
persistent rule had produced, the persistent rule's `branch.contains` guard would then see
its own output missing, and the two would alternate forever. With the guards in
`findApplicableRule` covering all three arms, deletion is no longer needed to prevent
re-firing, and keeping the source buys two things: the branch is monotone, so its length is a
strict progress measure; and a time whose formulas were all consumed no longer disappears from
`Branch.knownTimes`, which is what made the ordering induced on the known times lossy.
-/
def expandOnce (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : ExpansionResult × TimeOrdering :=
  match findUnexpanded b timeOrd fc with
  | none => (.saturated, timeOrd)
  | some sf =>
      match findApplicableRule sf b timeOrd fc with
      | none => (.saturated, timeOrd)  -- Shouldn't happen if findUnexpanded returned something
      | some (_, result, newOrd) =>
          match result with
          | .linear formulas =>
              (.extended (formulas ++ b), newOrd)
          | .branching branches =>
              (.split (branches.map fun newFormulas => newFormulas ++ b), newOrd)
          | .persistent formulas =>
              (.extended (formulas ++ b), newOrd)
          | .notApplicable => (.saturated, newOrd)  -- Shouldn't happen

/--
A single expansion step restricted to rules that introduce **no new label** — neither a fresh
world nor a fresh time.

This is the step the post-blocking pass needs. That pass exists to finish the propositional
and propagation work still outstanding on a branch that time-blocking halted, without
extending the time structure the blocking decision was made against.

Its predecessor asked `expandOnce` for *the* next step and abandoned the whole branch when
that step happened to introduce a time. That is too brittle to survive non-destructive
expansion: the source formulas now stay on the branch, so the first formula `findUnexpanded`
lands on is frequently a temporal existential, and the pass would give up with ordinary
propositional work still pending. Here the label-introducing candidates are *skipped* and the
search continues, so the pass stops only when no label-free work remains at all.

The test is exact rather than a rule list: a candidate is rejected if it mints a fresh world
(`ruleMintsFreshLabel`) or if applying it would lengthen the ordering constraints. That covers
`densityRule` and the active-mode arms of `untlNeg`/`snceNeg`, which introduce times without
being witness-guarded, and it stays correct if a future rule does the same.
-/
def expandOnceNoFresh (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : ExpansionResult × TimeOrdering :=
  let pick := b.findSome? fun sf =>
    match findApplicableRule sf b timeOrd fc with
    | some (rule, result, newOrd) =>
        if ruleMintsFreshLabel rule then none
        else if newOrd.constraints.length > timeOrd.constraints.length then none
        else some (result, newOrd)
    | none => none
  match pick with
  | none => (.saturated, timeOrd)
  | some (result, newOrd) =>
      match result with
      | .linear formulas => (.extended (formulas ++ b), newOrd)
      | .branching branches => (.split (branches.map fun fs => fs ++ b), newOrd)
      | .persistent formulas => (.extended (formulas ++ b), newOrd)
      | .notApplicable => (.saturated, newOrd)

/-!
## The Applied Set, Demoted

The applied set existed to break the persistent/consumable cycle described in the
"Uniform Branch Guards" section. The branch guards plus non-destructive expansion break that
cycle at its source, so the applied set has nothing left to suppress, and it must not be
allowed to suppress anything: a rule filtered out by the applied set rather than by the branch
is a rule whose conclusion may be *absent* from the branch, which is exactly the orphan
situation that stopped the open-branch certificate from meaning downward saturation.

The four functions below are therefore **inert wrappers**: they ignore the `applied` argument
entirely and delegate to the guarded, non-destructive versions, always reporting an empty
applied-set delta. The signatures are kept only so that the certificate and the fuel loop can
be moved off them in a separate step; nothing depends on the applied set's contents any more,
and an open certificate's applied set is now always empty.
-/

/--
Deprecated in substance: delegates to `findApplicableRule`, ignoring `applied`.
Always reports an empty applied-set delta.
-/
def findApplicableRuleWithApplied (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (_applied : AppliedSet := {}) :
      Option (TableauRule × RuleResult × TimeOrdering × List SignedFormula) :=
  match findApplicableRule sf branch timeOrd fc with
  | none => none
  | some (rule, result, newOrd) => some (rule, result, newOrd, [])

/-- Deprecated in substance: agrees with `isExpanded`, ignoring `applied`. -/
def isExpandedWithApplied (sf : SignedFormula) (branch : Branch := [])
    (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (applied : AppliedSet := {}) : Bool :=
  (findApplicableRuleWithApplied sf branch timeOrd fc applied).isNone

/-- Deprecated in substance: agrees with `findUnexpanded`, ignoring `applied`. -/
def findUnexpandedWithApplied (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base)
    (applied : AppliedSet := {}) : Option SignedFormula :=
  b.find? (fun sf => ¬isExpandedWithApplied sf b timeOrd fc applied)

/--
Deprecated in substance: delegates to `expandOnce`, ignoring `applied` and always reporting
an empty applied-set delta.
-/
def expandOnceWithApplied (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) (_applied : AppliedSet := {})
    : ExpansionResult × TimeOrdering × List SignedFormula :=
  let (result, newOrd) := expandOnce b timeOrd fc
  (result, newOrd, [])

/--
Count of unexpanded formulas in a branch (termination measure).
-/
def countUnexpanded (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Nat :=
  b.filter (fun sf => ¬isExpanded sf b timeOrd fc) |>.length

/--
Total unexpanded complexity (alternative termination measure).
-/
def totalUnexpandedComplexity (b : Branch) (timeOrd : TimeOrdering := TimeOrdering.empty)
    (fc : FrameClass := .Base) : Nat :=
  b.filter (fun sf => ¬isExpanded sf b timeOrd fc)
  |>.foldl (fun acc sf => acc + sf.complexity) 0

end FormalSystem.Metalogic.Decidability
