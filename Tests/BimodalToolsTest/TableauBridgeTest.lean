/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.TableauBridge

/-!
# Tableau Bridge: branch gates and frame-class parsing

Acceptance rows for the two protocol changes in `BimodalTools/TableauBridge.lean`:

1. the additive `"gates"` object on the `.invalid` arm, whose `"gated"` key says whether
   `not_valid_of_hasOpen_int` / `not_validZTime_of_hasOpen_int`
   (`FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean`) actually apply to the
   branch the verdict came from; and
2. `parseFrameClass`, which now **rejects** an unrecognized `frame_class` instead of silently
   coercing it to `.Base`.

Every row is a `#guard` on a pure function, so a regression fails `lake build BimodalToolsTest`
rather than being absorbed. The idiom follows
`Tests/BimodalTest/Metalogic/Decidability/Verified/BridgeProbes.lean`.

**Formula choice is not free.** Only formulas with a measured outcome are used here: `p → q` at
`.Base` and at `.ZTime`, and `p → p` for the valid arm. `p → □p`, `□p → □q` and `S(q,p) → p` are
measured to STALL at `.ZTime` and must not be added.
-/

namespace BimodalToolsTest.TableauBridge

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open BimodalTools.TableauBridge

private def p : Formula := .atomS "p"
private def q : Formula := .atomS "q"

/-- Substring test. Lean core carries neither `String.isInfixOf` nor `String.containsSubstr` at
this toolchain, and `splitOn` yields more than one piece exactly when the needle occurs. -/
private def hasSub (haystack needle : String) : Bool :=
  (haystack.splitOn needle).length > 1

/-- info: true -/
#guard_msgs in
#eval hasSub "{\"gated\": true}" "\"gated\": true"

/-- info: false -/
#guard_msgs in
#eval hasSub "{\"gated\": true}" "\"gated\": false"

/-! ## Row A — a gated invalid verdict

`p → q` at `.Base` is refuted on a branch satisfying every one of the eight hypotheses, so the
verdict is citable through `not_valid_of_hasOpen_int`. All eight booleans are pinned, not just
`gated`: a regression that flipped two of them in compensating directions would otherwise pass.
-/

#guard evalBranchGates (.imp p q) .Base ==
  some { timeOrderTotal := true, boxAnchored := true, regionLabel := true,
         temporalWitness := true, branchOrderValid := true, saturated := true,
         noClosure := true, rootDenied := true }

/-- info: some true -/
#guard_msgs in
#eval (evalBranchGates (.imp p q) .Base).map BranchGates.gated

/-! ## Row B — an ungated invalid verdict

The same formula at `.ZTime` is still decided `.invalid`, but `regionLabelCheck` and
`temporalWitnessCheck` are both `false` on the resulting branch, so the verdict is the decision
procedure's own and is **not** backed by `not_validZTime_of_hasOpen_int`.

This row records the `.ZTime` rules' measured behaviour today (`priorUZ`/`priorSZ` on the
seriality-minted `T(F ⊤)`). It is deliberately **not** an assertion that the behaviour is correct
— repairing those two gates is a separate, larger change inside `Verified/Bridge/`. If that
repair lands, this row is expected to go red and should be updated, not deleted: the point of the
row is that the bridge reports the gates honestly either way.
-/

#guard evalBranchGates (.imp p q) .ZTime ==
  some { timeOrderTotal := true, boxAnchored := true, regionLabel := false,
         temporalWitness := false, branchOrderValid := true, saturated := true,
         noClosure := true, rootDenied := true }

/-- info: some false -/
#guard_msgs in
#eval (evalBranchGates (.imp p q) .ZTime).map BranchGates.gated

/-! ## Row C — the response shape

Substring checks rather than whole-string pins, so a later additive field does not break the row.
`"status": "invalid"` must survive unchanged: the `"gates"` object is additive and existing
consumers are not to be broken.
-/

#guard hasSub (decideResponseBody (.imp p q) .Base) "\"status\": \"invalid\""
#guard hasSub (decideResponseBody (.imp p q) .Base) "\"gated\": true"
#guard hasSub (decideResponseBody (.imp p q) .ZTime) "\"status\": \"invalid\""
#guard hasSub (decideResponseBody (.imp p q) .ZTime) "\"gated\": false"

-- The valid arm carries no `"gates"` key at all -- the gates are a property of an open branch,
-- and there is none.
#guard !hasSub (decideResponseBody (.imp p p) .Base) "\"gates\""

-- Every pre-existing `.invalid` field is still present.
#guard hasSub (decideResponseBody (.imp p q) .Base) "\"countermodel\": "
#guard hasSub (decideResponseBody (.imp p q) .Base) "\"formula_string\": "

/-! ## Row D — the frame-class vocabulary

`Base`, `Dense`, `ZTime`, `Discrete` (an alias for `ZTime`) and `RTime` are accepted; everything
else is rejected. `RTime` is accepted rather than refused: `FrameClass.RTime` exists and
`allRulesForFC` has a live `rTimeRules` arm, so the engine genuinely supports it.
-/

#guard parseFrameClass "Base" == .ok .Base
#guard parseFrameClass "Dense" == .ok .Dense
#guard parseFrameClass "ZTime" == .ok .ZTime
#guard parseFrameClass "Discrete" == .ok .ZTime
#guard parseFrameClass "RTime" == .ok .RTime

/-- info: Except.error "unknown frame_class: 'Bogus' (expected one of: Base, Dense, ZTime, Discrete, RTime)" -/
#guard_msgs in
#eval parseFrameClass "Bogus"

-- The pre-change behaviour was `_ => .Base`. This row is what stops it coming back.
#guard (parseFrameClass "Bogus").toOption == none

/-! ## Row E — end-to-end rejection through `parseRequest`

`parseRequest` is `Except String BridgeRequest` and `replLoop` already renders an `.error` as
`{"status": "error", "message": ...}`, so a rejected `frame_class` reaches the wire through the
existing error path with no new plumbing.
-/

private def bogusLine : String :=
  "{\"command\": \"tableau_decide\", \"frame_class\": \"Bogus\", " ++
  "\"formula\": {\"tag\": \"imp\", \"left\": {\"tag\": \"atom\", \"name\": \"p\"}, " ++
  "\"right\": {\"tag\": \"atom\", \"name\": \"q\"}}}"

/-- info: Except.error "unknown frame_class: 'Bogus' (expected one of: Base, Dense, ZTime, Discrete, RTime)" -/
#guard_msgs in
#eval (parseRequest bogusLine).map (fun r => r.frameClass)

private def rtimeLine : String :=
  "{\"command\": \"tableau_decide\", \"frame_class\": \"RTime\", " ++
  "\"formula\": {\"tag\": \"imp\", \"left\": {\"tag\": \"atom\", \"name\": \"p\"}, " ++
  "\"right\": {\"tag\": \"atom\", \"name\": \"q\"}}}"

/-- info: Except.ok (FormalSystem.ProofSystem.FrameClass.RTime) -/
#guard_msgs in
#eval (parseRequest rtimeLine).map (fun r => r.frameClass)

private def noFrameClassLine : String :=
  "{\"command\": \"tableau_decide\", " ++
  "\"formula\": {\"tag\": \"imp\", \"left\": {\"tag\": \"atom\", \"name\": \"p\"}, " ++
  "\"right\": {\"tag\": \"atom\", \"name\": \"q\"}}}"

-- An absent `frame_class` still defaults to `Base`; only an *unrecognized* value is rejected.
/-- info: Except.ok (FormalSystem.ProofSystem.FrameClass.Base) -/
#guard_msgs in
#eval (parseRequest noFrameClassLine).map (fun r => r.frameClass)

end BimodalToolsTest.TableauBridge
