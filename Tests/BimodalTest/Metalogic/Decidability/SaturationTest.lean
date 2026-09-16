/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Saturation

/-!
# Saturation Tests

Behavioural tests for the tableau engine in
`FormalSystem/Metalogic/Decidability/Saturation.lean`.

- **Probes** (`#guard_msgs`) pin the arm-settling repair in `resolveOpenArm` and the budgeted
  entry point `buildTableauAt` against their measured outputs.
- **Integration tests** (`#guard`) run the engine on known valid and satisfiable formulas and
  pin the exact verdict string of each row, so a row that changes branch (a `PASS` turning into
  an out-of-fuel verdict, say) fails elaboration rather than printing a different line.
-/

namespace BimodalTest.Metalogic.Decidability.SaturationTest

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability

/-! ## Arm-Settling Probes

Evidence rows for the `resolveOpenArm` repair (see "Why the test is `findUnexpandedUnblocked`,
not `findUnexpanded`" above). These are checkable by *running*, not by reading, which is the
point: the claim being pinned is a behavioural one.

The first three rows are the ones that were measured to fail before the repair.
`F(G p)` and `¬G(F p)` returned `none` from `expandBranchWithFuel` at every tested pair
`(fuel, maxBranches) ∈ {500, 8000, 50000, 229376, 300000} × {50000, 10⁹, 10¹²}`, always through
`resolveOpenArm`'s undecided arm and never through the fuel or `maxBranches` guards. They now
settle. `U(p,q)` is the control: it succeeded before and is unchanged.

The last two rows say what the repair did *not* do. `buildTableau` still tests with the literal
`findUnexpanded` at its own two top-level decision points — deliberately, since those feed the
dependently-typed `ExpandedTableau.hasOpen` constructor whose proof field is
`findUnexpanded … = none` and which downstream consumers read. So `buildTableau (F(G p))` is
still `none`; the budget-parameterised entry point below is what settles it.

`armDisagreement` exhibits the mechanism directly: at the branch `expandBranchWithFuel` hands
back for `F(G p)`, the literal test reports work outstanding (`true`) while the engine's real
test reports saturation (`false`). That standing disagreement — `saturateBlocked` refusing to
mint time points, `findUnexpanded` counting them — is the whole of the defect.
-/
section ArmSettlingProbes

private def probeP : Formula := .atom (Atom.mkBase "p")
private def probeQ : Formula := .atom (Atom.mkBase "q")

/-- `F(G p)` — refuting formula #1 from the counterexample census. -/
private def probeFGp : Formula := Formula.someFuture (Formula.allFuture probeP)
/-- `¬G(F p)` — refuting formula #2. -/
private def probeNGFp : Formula := (Formula.allFuture (Formula.someFuture probeP)).neg
/-- `U(p,q)` — the unchanged control. -/
private def probeUpq : Formula := Formula.untl probeQ probeP

private def probeSeed (φ : Formula) : Branch := [SignedFormula.neg φ Label.initial]

private def armProbe (φ : Formula) (fuel : Nat) : Bool :=
  (expandBranchWithFuel (probeSeed φ) fuel).isSome

-- `F(G p)` settles. Before the repair this was `false` at every fuel and every budget.
/-- info: true -/
#guard_msgs in
#eval armProbe probeFGp 500

-- `¬G(F p)` settles likewise.
/-- info: true -/
#guard_msgs in
#eval armProbe probeNGFp 500

-- `U(p,q)` is unchanged: it succeeded before and still does.
/-- info: true -/
#guard_msgs in
#eval armProbe probeUpq 500

-- The top level is *not* repaired by this phase: `buildTableau` still tests literally.
/-- info: false -/
#guard_msgs in
#eval (buildTableau probeFGp 500).isSome

/-- The two saturation tests at the branch `expandBranchWithFuel` returns for `F(G p)`:
literal reports outstanding work, blocking-aware reports saturation. -/
private def armDisagreement : Option (Bool × Bool) :=
  match expandBranchWithFuel (probeSeed probeFGp) 500 with
  | some (.inr (ob, ord, _)) =>
      some ((findUnexpanded ob (timeOrd := ord) (fc := .Base)).isSome,
            (findUnexpandedUnblocked ob ord .Base (armTracker ob)).isSome)
  | _ => none

/-- info: some (true, false) -/
#guard_msgs in
#eval armDisagreement

end ArmSettlingProbes

/-!
## Until/Since Integration Tests

These tests verify the 4 Until/Since tableau rules (untlPos, untlNeg, sncePos, snceNeg)
produce correct results for known axioms and satisfiable formulas.
-/

section UntilSinceTests

open FormalSystem.Syntax

-- Helper: create propositional atom formulas
private def p : Formula := .atom (Atom.mkBase "p")
private def q : Formula := .atom (Atom.mkBase "q")

-- Test 1: U(p, bot) -> F(p) should be valid (allClosed)
-- U(p, bot) = "bot until p" = essentially Next(p)
-- Event branch: T(p) at t1 + F(p) at t1 from F(F(p)) propagation => contradiction
-- Guard branch: T(bot) at t1 => botPos closure
#guard (Id.run do
  let φ := Formula.imp (.untl .bot p) (Formula.someFuture p)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: U(p, bot) -> F(p) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL: U(p, bot) -> F(p) should be valid but got open branch"
  | none => return "FAIL: U(p, bot) -> F(p) ran out of fuel")
  == "PASS: U(p, bot) -> F(p) is valid"

-- Test 2: S(p, bot) -> P(p) should be valid (allClosed)
-- Symmetric past version of Test 1
#guard (Id.run do
  let φ := Formula.imp (.snce .bot p) (Formula.somePast p)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: S(p, bot) -> P(p) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL: S(p, bot) -> P(p) should be valid but got open branch"
  | none => return "FAIL: S(p, bot) -> P(p) ran out of fuel")
  == "PASS: S(p, bot) -> P(p) is valid"

-- Test 3: F(p) -> U(p, top) should be valid (definitional equality: both = untl top p)
-- F(φ) = U(φ, ⊤) by definition, so this is U(p, ⊤) -> U(p, ⊤), trivial
#guard (Id.run do
  let φ := Formula.imp (Formula.someFuture p) (.untl Formula.top p)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: F(p) -> U(p, top) is valid (BX12)"
  | some (.hasOpen _ _ _ _) => return "FAIL: F(p) -> U(p, top) should be valid but got open branch"
  | none => return "FAIL: F(p) -> U(p, top) ran out of fuel")
  == "PASS: F(p) -> U(p, top) is valid (BX12)"

-- Test 4: P(p) -> S(p, top) should be valid (symmetric BX12')
#guard (Id.run do
  let φ := Formula.imp (Formula.somePast p) (.snce Formula.top p)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: P(p) -> S(p, top) is valid (BX12')"
  | some (.hasOpen _ _ _ _) => return "FAIL: P(p) -> S(p, top) should be valid but got open branch"
  | none => return "FAIL: P(p) -> S(p, top) ran out of fuel")
  == "PASS: P(p) -> S(p, top) is valid (BX12')"

-- Test 5: Seriality test: F(top) -> top should be valid
#guard (Id.run do
  let φ := Formula.imp (Formula.someFuture Formula.top) Formula.top
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: F(top) -> top is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL: F(top) -> top should be valid but got open branch"
  | none => return "FAIL: F(top) -> top ran out of fuel")
  == "PASS: F(top) -> top is valid"

-- Test 6: U(p, q) is satisfiable (NOT valid), so buildTableauAuto should produce hasOpen or timeout
-- U(p, q) alone is not a tautology - it has models where p eventually holds with q as guard
#guard (Id.run do
  let φ := Formula.untl q p
  let result := buildTableau φ 50  -- Use limited fuel since this is satisfiable
  match result with
  | some (.allClosed _) => return "FAIL: U(p, q) should be satisfiable but got allClosed"
  | some (.hasOpen _ _ _ _) => return "PASS: U(p, q) is satisfiable (open branch found)"
  | none => return "PASS: U(p, q) is satisfiable (exhausted fuel without closing)")
  == "PASS: U(p, q) is satisfiable (open branch found)"

-- Test 7: p -> p is a tautology (baseline propositional test)
#guard (Id.run do
  let φ := Formula.imp p p
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS: p -> p is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL: p -> p should be valid"
  | none => return "FAIL: p -> p ran out of fuel")
  == "PASS: p -> p is valid"

end UntilSinceTests

/-!
## Blocking Termination Tests

These tests verify that subset blocking correctly terminates tableau expansion
for formulas that would previously loop or exhaust fuel.
-/

section BlockingTests

open FormalSystem.Syntax

private def p' : Formula := .atom (Atom.mkBase "p")
private def q' : Formula := .atom (Atom.mkBase "q")

-- Test B1: G(p) -> G(p) is trivially valid (regression baseline)
#guard (Id.run do
  let φ := Formula.imp (Formula.allFuture p') (Formula.allFuture p')
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS B1: G(p) -> G(p) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL B1: G(p) -> G(p) should be valid"
  | none => return "FAIL B1: G(p) -> G(p) ran out of fuel")
  == "PASS B1: G(p) -> G(p) is valid"

-- Test B2: U(p, q) -> U(p, q) is trivially valid (temporal identity)
#guard (Id.run do
  let φ := Formula.imp (.untl q' p') (.untl q' p')
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS B2: U(p,q) -> U(p,q) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL B2: U(p,q) -> U(p,q) should be valid"
  | none => return "FAIL B2: U(p,q) -> U(p,q) ran out of fuel")
  == "PASS B2: U(p,q) -> U(p,q) is valid"

-- Test B3: U(p, bot) -> F(p) is valid (eventuality: p must be witnessed)
-- The Until formula creates an eventuality for p, and the event branch witnesses it
#guard (Id.run do
  let φ := Formula.imp (.untl .bot p') (Formula.someFuture p')
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS B3: U(p,bot) -> F(p) is valid (eventuality witnessed)"
  | some (.hasOpen _ _ _ _) => return "FAIL B3: U(p,bot) -> F(p) should be valid"
  | none => return "FAIL B3: U(p,bot) -> F(p) ran out of fuel")
  == "PASS B3: U(p,bot) -> F(p) is valid (eventuality witnessed)"

end BlockingTests

/-!
## Modal-Temporal Interaction Tests

These tests verify the cross-modal-temporal interaction rules:
- boxTemporal: T(□φ) → T(Gφ), T(Hφ)
- Temporal inheritance at world creation
- Box persistence at time creation
-/

section ModalTemporalTests

open FormalSystem.Syntax

-- Helper: create propositional atom formulas
private def mtP : Formula := .atom (Atom.mkBase "p")

-- Test MT1: □p → Gp should be valid (boxTemporal derives T(Gp) from T(□p))
#guard (Id.run do
  let φ := Formula.imp (.box mtP) (Formula.allFuture mtP)
  let result := buildTableau φ 500
  match result with
  | some (.allClosed _) => return "PASS: □p → Gp is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL: □p → Gp should be valid but got open branch"
  | none => return "FAIL: □p → Gp ran out of fuel")
  == "PASS: □p → Gp is valid"

-- Test MT2: □p → Hp should be valid (boxTemporal derives T(Hp) from T(□p))
#guard (Id.run do
  let φ := Formula.imp (.box mtP) (Formula.allPast mtP)
  let result := buildTableau φ 500
  match result with
  | some (.allClosed _) => return "PASS: □p → Hp is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL: □p → Hp should be valid but got open branch"
  | none => return "FAIL: □p → Hp ran out of fuel")
  == "PASS: □p → Hp is valid"

-- Test MT3: □p → always p (perpetuity P1: □p → Hp ∧ p ∧ Gp)
-- always p = Hp ∧ (p ∧ Gp) — complex compound formula whose deep encoding
-- requires many expansion steps. With current blocking (refinement still pending), may
-- report open branch or exhaust fuel. The core interaction (MT1, MT2) passes.
#guard (Id.run do
  let φ := Formula.imp (.box mtP) (Formula.always mtP)
  let result := buildTableau φ 500
  match result with
  | some (.allClosed _) => return "PASS: □p → always p is valid (P1 perpetuity)"
  | some (.hasOpen _ _ _ _) => return "INFO: □p → always p open branch (blocking refinement needed)"
  | none => return "INFO: □p → always p fuel exhausted (blocking refinement needed)")
  == "PASS: □p → always p is valid (P1 perpetuity)"

-- Test MT4: □(□p) → G(□p) should be valid (nested modal-temporal)
-- Nested box formulas with temporal interaction. May require blocking refinement.
#guard (Id.run do
  let φ := Formula.imp (.box (.box mtP)) (Formula.allFuture (.box mtP))
  let result := buildTableau φ 500
  match result with
  | some (.allClosed _) => return "PASS: □(□p) → G(□p) is valid"
  | some (.hasOpen _ _ _ _) =>
    return "INFO: □(□p) → G(□p) open branch (blocking refinement needed; see the " ++
      "blocking-termination status section)"
  | none =>
    return "INFO: □(□p) → G(□p) fuel exhausted (blocking refinement needed; see the " ++
      "blocking-termination status section)")
  == "PASS: □(□p) → G(□p) is valid"

-- Test MT5: p ∧ F(¬p) should be satisfiable (NOT valid)
-- Verifies cross-propagation does not over-close: p holds now but ¬p at some future time
#guard (Id.run do
  let φ := Formula.and mtP (Formula.someFuture (Formula.neg mtP))
  let result := buildTableau φ 200
  match result with
  | some (.allClosed _) => return "FAIL: p ∧ F(¬p) should be satisfiable but got allClosed"
  | some (.hasOpen _ _ _ _) => return "PASS: p ∧ F(¬p) is satisfiable (open branch found)"
  | none => return "PASS: p ∧ F(¬p) is satisfiable (exhausted fuel without closing)")
  == "PASS: p ∧ F(¬p) is satisfiable (open branch found)"

-- Test MT6: □p → □(Gp) should be valid (modal_future axiom instance)
#guard (Id.run do
  let φ := Formula.imp (.box mtP) (.box (Formula.allFuture mtP))
  let result := buildTableau φ 500
  match result with
  | some (.allClosed _) => return "PASS: □p → □(Gp) is valid (modal_future)"
  | some (.hasOpen _ _ _ _) => return "FAIL: □p → □(Gp) should be valid but got open branch"
  | none => return "FAIL: □p → □(Gp) ran out of fuel")
  == "PASS: □p → □(Gp) is valid (modal_future)"

end ModalTemporalTests

/-!
## Extended Test Battery

Additional tests verifying blocking and termination behavior across
a range of formula patterns.
-/

section ExtendedTests

open FormalSystem.Syntax

private def etP : Formula := .atom (Atom.mkBase "p")
private def etQ : Formula := .atom (Atom.mkBase "q")
private def etR : Formula := .atom (Atom.mkBase "r")

-- Test E1: Deeply nested Until: U(U(p, q), r) -> U(U(p, q), r)
-- Identity should be valid; tests nested Until handling with blocking
#guard (Id.run do
  let inner := Formula.untl etQ etP
  let φ := Formula.imp (Formula.untl etR inner) (Formula.untl etR inner)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS E1: U(U(p,q),r) -> U(U(p,q),r) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL E1: should be valid"
  | none => return "FAIL E1: ran out of fuel")
  == "PASS E1: U(U(p,q),r) -> U(U(p,q),r) is valid"

-- Test E2: Combined Until/Since: S(p, bot) -> P(p) (mirrors test 2, regression)
#guard (Id.run do
  let φ := Formula.imp (Formula.snce .bot etP) (Formula.somePast etP)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS E2: S(p,bot) -> P(p) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL E2: should be valid"
  | none => return "FAIL E2: ran out of fuel")
  == "PASS E2: S(p,bot) -> P(p) is valid"

-- Test E3: Simple propositional regression: p -> (q -> p)
#guard (Id.run do
  let φ := Formula.imp etP (Formula.imp etQ etP)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS E3: p -> (q -> p) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL E3: should be valid"
  | none => return "FAIL E3: ran out of fuel")
  == "PASS E3: p -> (q -> p) is valid"

-- Test E4: Known satisfiable formula with blocking: U(p, q) is satisfiable
-- With blocking, this should terminate with an open branch
#guard (Id.run do
  let φ := Formula.untl etQ etP
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "FAIL E4: U(p,q) should be satisfiable"
  | some (.hasOpen _ _ _ _) => return "PASS E4: U(p,q) is satisfiable (open branch with blocking)"
  | none => return "INFO E4: U(p,q) fuel exhausted (blocking may not have fired)")
  == "PASS E4: U(p,q) is satisfiable (open branch with blocking)"

-- Test E5: G(p) -> p is NOT valid (p holds at all future times does not imply p holds now)
-- In our logic G(p) means p at all strictly future times, not including now
-- This depends on whether the logic is reflexive; in strict temporal logic G(p) ≠> p
#guard (Id.run do
  let φ := Formula.imp (Formula.allFuture etP) etP
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "INFO E5: G(p) -> p is valid (reflexive reading)"
  | some (.hasOpen _ _ _ _) => return "INFO E5: G(p) -> p is invalid (strict reading)"
  | none => return "INFO E5: G(p) -> p ran out of fuel")
  == "INFO E5: G(p) -> p is invalid (strict reading)"

end ExtendedTests

/-! ### Budget-entry-point probes

The row that matters: at a budget the research measured `buildTableau` returning `none` on,
`buildTableauAt` settles. `buildTableau` is re-evaluated alongside so the two verdicts sit in
the same file and drift together if either changes.
-/
section BudgetedTableauProbes

/-- info: false -/
#guard_msgs in
#eval (buildTableau probeFGp 500).isSome

/-- info: true -/
#guard_msgs in
#eval (buildTableauAt probeFGp 500 .Base 50000).isSome

/-- info: true -/
#guard_msgs in
#eval (buildTableauAt probeFGp 500 .Base 1000000).isSome

/-- info: some true -/
#guard_msgs in
#eval (buildTableauAt probeFGp 500 .Base 50000).map BudgetedTableau.isInvalid

/-- info: true -/
#guard_msgs in
#eval (buildTableauAt probeNGFp 500 .Base 50000).isSome

/-- info: true -/
#guard_msgs in
#eval (buildTableauAt probeUpq 500 .Base 50000).isSome

end BudgetedTableauProbes

/-!
## Frame-Class Gating Tests

These tests verify that the FrameClass parameter correctly gates axiom closure:
- Dense axioms close only when fc >= .Dense
- Discrete axioms close only when fc >= .ZTime
- Base axioms close under all frame classes (monotonicity)
- Dense and Discrete are incomparable: Dense axioms don't close under Discrete and vice versa
-/

section FrameClassGatingTests

open FormalSystem.Syntax
open FormalSystem.ProofSystem

private def fcP : Formula := .atom (Atom.mkBase "p")

-- Test FC1: GGp → Gp (density axiom) should close under fc := .Dense
#guard (Id.run do
  let φ := fcP.allFuture.allFuture.imp fcP.allFuture
  let result := buildTableau φ 500 .Dense
  match result with
  | some (.allClosed _) => return "PASS FC1: GGp → Gp closes under Dense"
  | some (.hasOpen _ _ _ _) =>
    return "INFO FC1: GGp → Gp open under Dense (may need density rule expansion)"
  | none => return "INFO FC1: GGp → Gp fuel exhausted under Dense")
  == "PASS FC1: GGp → Gp closes under Dense"

-- Test FC2: GGp → Gp should NOT close under fc := .Base (density not valid on all frames)
#guard (Id.run do
  let φ := fcP.allFuture.allFuture.imp fcP.allFuture
  let result := buildTableau φ 200 .Base
  match result with
  | some (.allClosed _) => return "FAIL FC2: GGp → Gp should NOT close under Base"
  | some (.hasOpen _ _ _ _) => return "PASS FC2: GGp → Gp correctly open under Base"
  | none => return "PASS FC2: GGp → Gp correctly non-closing under Base (fuel exhausted)")
  == "PASS FC2: GGp → Gp correctly open under Base"

-- Test FC3: ¬U(⊤,⊥) (dense_indicator) should close under fc := .Dense
#guard (Id.run do
  let φ := (Formula.untl .bot Formula.top).neg
  let result := buildTableau φ 500 .Dense
  match result with
  | some (.allClosed _) => return "PASS FC3: ¬U(⊤,⊥) closes under Dense"
  | some (.hasOpen _ _ _ _) =>
    return "INFO FC3: ¬U(⊤,⊥) open under Dense (axiomNeg gating should close)"
  | none => return "INFO FC3: ¬U(⊤,⊥) fuel exhausted under Dense")
  == "PASS FC3: ¬U(⊤,⊥) closes under Dense"

-- Test FC4: ¬U(⊤,⊥) should NOT close under fc := .Base
#guard (Id.run do
  let φ := (Formula.untl .bot Formula.top).neg
  let result := buildTableau φ 200 .Base
  match result with
  | some (.allClosed _) => return "FAIL FC4: ¬U(⊤,⊥) should NOT close under Base"
  | some (.hasOpen _ _ _ _) => return "PASS FC4: ¬U(⊤,⊥) correctly open under Base"
  | none => return "PASS FC4: ¬U(⊤,⊥) correctly non-closing under Base (fuel exhausted)")
  == "PASS FC4: ¬U(⊤,⊥) correctly open under Base"

-- Test FC5: F(p) → U(p, ¬p) (prior_UZ axiom) should close under fc := .ZTime
#guard (Id.run do
  let φ := fcP.someFuture.imp (Formula.untl fcP.neg fcP)
  let result := buildTableau φ 500 .ZTime
  match result with
  | some (.allClosed _) => return "PASS FC5: F(p) → U(p, ¬p) closes under Discrete"
  | some (.hasOpen _ _ _ _) =>
    return "INFO FC5: F(p) → U(p, ¬p) open under Discrete (may need prior rule)"
  | none => return "INFO FC5: F(p) → U(p, ¬p) fuel exhausted under Discrete")
  == "PASS FC5: F(p) → U(p, ¬p) closes under Discrete"

-- Test FC6: F(p) → U(p, ¬p) should NOT close under fc := .Base
#guard (Id.run do
  let φ := fcP.someFuture.imp (Formula.untl fcP.neg fcP)
  let result := buildTableau φ 200 .Base
  match result with
  | some (.allClosed _) => return "FAIL FC6: F(p) → U(p, ¬p) should NOT close under Base"
  | some (.hasOpen _ _ _ _) => return "PASS FC6: F(p) → U(p, ¬p) correctly open under Base"
  | none => return "PASS FC6: F(p) → U(p, ¬p) correctly non-closing under Base")
  == "PASS FC6: F(p) → U(p, ¬p) correctly open under Base"

-- Test FC7: F(p) → U(p, ¬p) should NOT close under fc := .Dense (incomparable with Discrete)
#guard (Id.run do
  let φ := fcP.someFuture.imp (Formula.untl fcP.neg fcP)
  let result := buildTableau φ 200 .Dense
  match result with
  | some (.allClosed _) => return "FAIL FC7: F(p) → U(p, ¬p) should NOT close under Dense"
  | some (.hasOpen _ _ _ _) => return "PASS FC7: F(p) → U(p, ¬p) correctly open under Dense"
  | none => return "PASS FC7: F(p) → U(p, ¬p) correctly non-closing under Dense")
  == "PASS FC7: F(p) → U(p, ¬p) correctly open under Dense"

-- Test FC8: Base axiom p → p should close under ALL frame classes (monotonicity)
#guard (Id.run do
  let φ := Formula.imp fcP fcP
  let resultBase := buildTableauAuto φ
  let resultDense := buildTableau φ 200 .Dense
  let resultZTime := buildTableau φ 200 .ZTime
  let baseOk := match resultBase with | some (.allClosed _) => true | _ => false
  let denseOk := match resultDense with | some (.allClosed _) => true | _ => false
  let zTimeOk := match resultZTime with | some (.allClosed _) => true | _ => false
  if baseOk && denseOk && zTimeOk then
    return "PASS FC8: p → p closes under all frame classes (monotonicity)"
  else
    return s!"FAIL FC8: p → p should close under all: Base={baseOk}, Dense={denseOk}, " ++
      s!"ZTime={zTimeOk}")
  == "PASS FC8: p → p closes under all frame classes (monotonicity)"

-- Test FC9: ¬U(⊤,⊥) should NOT close under fc := .ZTime (Dense and ZTime are incomparable)
#guard (Id.run do
  let φ := (Formula.untl .bot Formula.top).neg
  let result := buildTableau φ 200 .ZTime
  match result with
  | some (.allClosed _) => return "FAIL FC9: ¬U(⊤,⊥) should NOT close under Discrete"
  | some (.hasOpen _ _ _ _) => return "PASS FC9: ¬U(⊤,⊥) correctly open under Discrete"
  | none => return "PASS FC9: ¬U(⊤,⊥) correctly non-closing under Discrete")
  == "PASS FC9: ¬U(⊤,⊥) correctly open under Discrete"

end FrameClassGatingTests

/-!
## Persistent Rule Loop Fix Tests
-/

section PersistentLoopTests

open FormalSystem.Syntax

private def plP : Formula := .atom (Atom.mkBase "p")
private def plR : Formula := .atom (Atom.mkBase "r")

-- Test PL1: diamond p should terminate (was the known counterexample for boxPos loop)
#guard (Id.run do
  let diamondP := Formula.imp (Formula.box (Formula.imp plP .bot)) .bot
  let result := buildTableauAuto diamondP
  match result with
  | some (.allClosed _) => return "FAIL PL1: diamond p should be satisfiable"
  | some (.hasOpen _ _ _ _) => return "PASS PL1: diamond p terminates with open branch (no loop)"
  | none => return "FAIL PL1: diamond p ran out of fuel (loop not fixed)")
  == "PASS PL1: diamond p terminates with open branch (no loop)"

-- Test PL2: The stall formula (box(bot -> bot) -> r) should decide quickly
#guard (Id.run do
  let φ := Formula.imp (Formula.box (Formula.imp .bot .bot)) plR
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "INFO PL2: (box(bot -> bot) -> r) is valid"
  | some (.hasOpen _ _ _ _) => return "PASS PL2: (box(bot -> bot) -> r) terminates (no stall)"
  | none => return "FAIL PL2: (box(bot -> bot) -> r) ran out of fuel (stall not fixed)")
  == "PASS PL2: (box(bot -> bot) -> r) terminates (no stall)"

-- Test PL3: box(bot -> p) should be valid (necessitation of ex_falso)
#guard (Id.run do
  let φ := Formula.box (Formula.imp .bot plP)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS PL3: box(bot -> p) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL PL3: box(bot -> p) should be valid"
  | none => return "FAIL PL3: box(bot -> p) ran out of fuel")
  == "PASS PL3: box(bot -> p) is valid"

-- Test PL4: box(p -> p) should be valid (necessitation of identity)
#guard (Id.run do
  let φ := Formula.box (Formula.imp plP plP)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS PL4: box(p -> p) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL PL4: box(p -> p) should be valid"
  | none => return "FAIL PL4: box(p -> p) ran out of fuel")
  == "PASS PL4: box(p -> p) is valid"

-- Test PL5: (box bot -> r) should be valid (box bot is unsatisfiable via modal_t)
#guard (Id.run do
  let φ := Formula.imp (Formula.box .bot) plR
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS PL5: (box bot -> r) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL PL5: (box bot -> r) should be valid"
  | none => return "FAIL PL5: (box bot -> r) ran out of fuel")
  == "PASS PL5: (box bot -> r) is valid"

end PersistentLoopTests

/-!
## Active Until/Since Negative Rule Tests

These tests verify that the active untlNeg/snceNeg rules correctly create
fresh time points when no future/past times exist, enabling countermodel
construction for formulas that previously caused premature saturation or
timeout.

The key innovation is that F(U(event, guard)) at a time with no future
times will now create a fresh future time and perform Reynolds
co-decomposition there, rather than returning notApplicable.
-/

section ActiveUntlNegTests

open FormalSystem.Syntax

private def anP : Formula := .atom (Atom.mkBase "p")
private def anQ : Formula := .atom (Atom.mkBase "q")

-- Test AN1: G(p) → ¬F(¬p) should be valid
-- G(p) means p holds at all future times, ¬F(¬p) means there is no future time
-- where ¬p holds. These are logically equivalent.
-- Tests that active untlNeg (via F = U(·,⊤)) creates fresh future times
-- where the interaction between G(p) and F(¬p) can be checked.
#guard (Id.run do
  let gp := Formula.allFuture anP
  let fnp := Formula.someFuture (Formula.neg anP)
  let φ := Formula.imp gp (Formula.neg fnp)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS AN1: G(p) → ¬F(¬p) is valid"
  | some (.hasOpen _ _ _ _) => return "INFO AN1: G(p) → ¬F(¬p) open (may need active rule)"
  | none => return "INFO AN1: G(p) → ¬F(¬p) fuel exhausted")
  == "PASS AN1: G(p) → ¬F(¬p) is valid"

-- Test AN2: U(p, q) is satisfiable (open branch with active untlNeg)
-- Active untlNeg creates a fresh future time for Reynolds decomposition
-- when no future times exist, enabling countermodel construction.
#guard (Id.run do
  let φ := Formula.untl anQ anP
  let result := buildTableau φ 200
  match result with
  | some (.allClosed _) => return "INFO AN2: U(p,q) unexpectedly closed"
  | some (.hasOpen _ _ _ _) =>
    return "PASS AN2: U(p,q) is satisfiable (active untlNeg created time)"
  | none => return "INFO AN2: U(p,q) fuel exhausted")
  == "PASS AN2: U(p,q) is satisfiable (active untlNeg created time)"

-- Test AN3: U(p, q) → U(p, q) should be valid (identity, regression baseline)
-- Tests that the active untlNeg rule does not break simple identity proofs.
-- Negation produces F(U(p,q)) and T(U(p,q)) at the same label -- the positive
-- Until creates a fresh future time, and the negative Until decomposes there.
#guard (Id.run do
  let φ := Formula.imp (Formula.untl anQ anP) (Formula.untl anQ anP)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS AN3: U(p,q) → U(p,q) is valid"
  | some (.hasOpen _ _ _ _) => return "FAIL AN3: U(p,q) → U(p,q) should be valid"
  | none => return "INFO AN3: U(p,q) → U(p,q) fuel exhausted")
  == "PASS AN3: U(p,q) → U(p,q) is valid"

-- Test AN4: S(p, q) is satisfiable (symmetric past test for active snceNeg)
-- Active snceNeg should create a fresh past time to decompose F(S(p, q))
#guard (Id.run do
  let φ := Formula.snce anQ anP
  let result := buildTableau φ 200
  match result with
  | some (.allClosed _) => return "INFO AN4: S(p,q) unexpectedly closed"
  | some (.hasOpen _ _ _ _) =>
    return "PASS AN4: S(p,q) is satisfiable (active snceNeg created time)"
  | none => return "INFO AN4: S(p,q) fuel exhausted")
  == "PASS AN4: S(p,q) is satisfiable (active snceNeg created time)"

-- Test AN5: H(p) → ¬P(¬p) should be valid (past-directed mirror of AN1)
-- H(p) means p holds at all past times, ¬P(¬p) means there is no past time
-- where ¬p holds. Tests snceNeg active rule via P = S(·,⊤) equivalence.
#guard (Id.run do
  let hp := Formula.allPast anP
  let pnp := Formula.somePast (Formula.neg anP)
  let φ := Formula.imp hp (Formula.neg pnp)
  let result := buildTableauAuto φ
  match result with
  | some (.allClosed _) => return "PASS AN5: H(p) → ¬P(¬p) is valid"
  | some (.hasOpen _ _ _ _) => return "INFO AN5: H(p) → ¬P(¬p) open (may need active rule)"
  | none => return "INFO AN5: H(p) → ¬P(¬p) fuel exhausted")
  == "PASS AN5: H(p) → ¬P(¬p) is valid"

-- Fuel assessment: test representative formulas with buildTableau (fuel=500)
-- to verify the active rule does not cause regressions or excessive fuel consumption.
-- The active rule only fires when futureOf/pastOf is empty, so fuel impact should
-- be minimal compared to the passive rule.

-- Test AN6: buildTableau(fuel=500) on nested Until: U(U(p,q), q) → U(U(p,q), q)
-- Tests that the active rule handles nested Until without fuel exhaustion.
#guard (Id.run do
  let inner := Formula.untl anQ anP
  let outer := Formula.untl anQ inner
  let φ := Formula.imp outer outer
  let result := buildTableau φ 500
  match result with
  | some (.allClosed _) => return "PASS AN6: nested Until identity valid (fuel=500)"
  | some (.hasOpen _ _ _ _) => return "INFO AN6: nested Until identity open (fuel=500)"
  | none => return "INFO AN6: nested Until identity timeout (fuel=500)")
  == "PASS AN6: nested Until identity valid (fuel=500)"

-- Test AN7: buildTableau(fuel=500) on U(p, q) → F(p)
-- If U(p, q) holds (q until p), then eventually p (F(p)) must hold.
-- This exercises both untlPos (creating future time for T(U(p,q))) and
-- untlNeg (decomposing F(F(p)) = F(U(p, top)) at the created time).
#guard (Id.run do
  let upq := Formula.untl anQ anP
  let fp := Formula.someFuture anP
  let φ := Formula.imp upq fp
  let result := buildTableau φ 500
  match result with
  | some (.allClosed _) => return "PASS AN7: U(p,q) → F(p) valid (fuel=500)"
  | some (.hasOpen _ _ _ _) => return "INFO AN7: U(p,q) → F(p) open (fuel=500)"
  | none => return "INFO AN7: U(p,q) → F(p) timeout (fuel=500)")
  == "PASS AN7: U(p,q) → F(p) valid (fuel=500)"

-- Test AN8: buildTableau(fuel=500) on ¬U(p, q) is satisfiable
-- F(U(p, q)) at t0 with no future times: active rule creates t1 and decomposes.
-- The branch should produce a countermodel with blocking termination.
#guard (Id.run do
  let upq := Formula.untl anQ anP
  let φ := Formula.neg upq  -- ¬U(p,q)
  let result := buildTableau φ 500
  match result with
  | some (.allClosed _) => return "INFO AN8: ¬U(p,q) closed (unexpected)"
  | some (.hasOpen _ _ _ _) =>
    return "PASS AN8: ¬U(p,q) satisfiable (fuel=500, active rule + blocking)"
  | none => return "INFO AN8: ¬U(p,q) timeout (fuel=500)")
  == "PASS AN8: ¬U(p,q) satisfiable (fuel=500, active rule + blocking)"

end ActiveUntlNegTests

/-!
## Fuel Allocation Heuristic Tests
-/
section FuelAllocationTests

open FormalSystem.Syntax in
private def faP := Formula.atom ⟨"p", none⟩
open FormalSystem.Syntax in
private def faQ := Formula.atom ⟨"q", none⟩

-- Test FA1: balanced branches (identical formulas) get approximately equal fuel
#guard (Id.run do
  let b1 : Branch := [SignedFormula.pos faP]
  let b2 : Branch := [SignedFormula.pos faQ]
  let allocs := allocateFuelProportionally 100 [b1, b2]
  -- Both branches have identical difficulty (1 atom each)
  -- so allocations should be equal
  let balanced := match allocs with
    | [a1, a2] => a1 == a2
    | _ => false
  if balanced then return "PASS FA1: balanced branches get equal fuel"
  else return s!"FAIL FA1: balanced branches got unequal fuel: {allocs}")
  == "PASS FA1: balanced branches get equal fuel"

-- Test FA2: temporal branch gets more fuel than propositional branch
#guard (Id.run do
  let b_prop : Branch := [SignedFormula.pos faP]
  let b_temp : Branch := [SignedFormula.pos (Formula.untl faQ faP)]
  let allocs := allocateFuelProportionally 100 [b_prop, b_temp]
  let correct := match allocs with
    | [a_prop, a_temp] => decide (a_temp > a_prop)
    | _ => false
  if correct then return "PASS FA2: temporal branch gets more fuel than propositional"
  else return s!"FAIL FA2: fuel allocation incorrect: {allocs}")
  == "PASS FA2: temporal branch gets more fuel than propositional"

-- Test FA3: all allocations are <= fuel-1 and >= 1 when fuel > 1
#guard (Id.run do
  let b1 : Branch := [SignedFormula.pos faP]
  let b2 : Branch := [SignedFormula.pos (Formula.untl faQ faP)]
  let b3 : Branch := [SignedFormula.pos (Formula.box faP)]
  let fuel := 200
  let allocs := allocateFuelProportionally fuel [b1, b2, b3]
  let allValid := allocs.all (fun a => a >= 1 && a <= fuel - 1)
  if allValid then return s!"PASS FA3: all allocations in bounds [1, {fuel-1}]: {allocs}"
  else return s!"FAIL FA3: allocations out of bounds: {allocs}")
  == "PASS FA3: all allocations in bounds [1, 199]: [25, 100, 75]"

-- Test FA4: fuel = 0 gives all zeros
#guard (Id.run do
  let b1 : Branch := [SignedFormula.pos faP]
  let b2 : Branch := [SignedFormula.pos faQ]
  let allocs := allocateFuelProportionally 0 [b1, b2]
  let allZero := allocs.all (· == 0)
  if allZero then return "PASS FA4: fuel=0 gives all zeros"
  else return s!"FAIL FA4: expected all zeros, got: {allocs}")
  == "PASS FA4: fuel=0 gives all zeros"

-- Test FA5: estimateBranchDifficulty gives correct difficulty ordering
#guard (Id.run do
  let b_prop : Branch := [SignedFormula.pos faP]
  let b_modal : Branch := [SignedFormula.pos (Formula.box faP)]
  let b_temp : Branch := [SignedFormula.pos (Formula.untl faQ faP)]
  let d_prop := estimateBranchDifficulty b_prop
  let d_modal := estimateBranchDifficulty b_modal
  let d_temp := estimateBranchDifficulty b_temp
  -- temporal > modal > propositional
  if d_temp > d_modal && d_modal > d_prop then
    return s!"PASS FA5: difficulty ordering correct: prop={d_prop} < modal={d_modal} " ++
      s!"< temp={d_temp}"
  else
    return s!"FAIL FA5: difficulty ordering wrong: prop={d_prop}, modal={d_modal}, temp={d_temp}")
  == "PASS FA5: difficulty ordering correct: prop=1 < modal=3 < temp=4"

end FuelAllocationTests

end BimodalTest.Metalogic.Decidability.SaturationTest
