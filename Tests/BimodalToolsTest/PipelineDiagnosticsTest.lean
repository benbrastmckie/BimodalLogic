/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.PipelineDiagnostics

/-!
# Tests for the five reserved-stage diagnostics emitters

Schema agreement is the whole contract of `BimodalTools/PipelineDiagnostics.lean`, and it is
decided here two ways.

## Key equality against the schema

For each of the five reserved stages, `record.keys = Head.keys ++ Stage.reservedKeys <stage>`.
That is the mechanical form of "each record carries exactly the fields the schema reserves for
its stage, in that order": a renamed field, a dropped field, a field in the wrong place, or a
field the schema never reserved all fail here. The emitter module carries the same five
assertions as `example`s, because `lean_lib BimodalTools` has no `linter.hashCommand` opt-out;
they are `#guard`s here, where it does.

Key *order* is read off `toJsonFields`, the ordered association list, not off the rendered
object: `Json.mkObj` stores fields in a search tree and so renders them alphabetically. That is
also why the golden strings below are alphabetical rather than in record order.

## One golden record per stage

A whole record, pinned byte for byte. `set_option diagnostics.zeroTimings true` is in force and is
genuinely read — `readZeroTimingsOption` reads the option registered in
`BimodalLib/Diagnostics/Emit.lean`, so one `set_option` governs both modules — which is what makes
the `decide` record pinnable at all: `decision_time_ms` is the only field of these five payloads
that is not a function of the commit and the toolchain.

The `decide` golden's verdict is `extractionFailed` on purpose. It is 26 of 133 at `ModalBoolean`
complexity 5 — as large as `fuelExhausted` and larger than `valid` — so the schema's handling of
it is tested rather than assumed, and the four-name vocabulary guard below pins the whole closed
list against `DecisionResult`'s own constructor names.

Two `certify` goldens, not one: a `Base` record carrying the eight gate `Bool`s verbatim from
`BranchGates.toJson`, and a `ZTime` record carrying `certificate` and `"gates":null`, because at
`ZTime` the gated route is structurally unavailable rather than merely rare.

## References

* `BimodalTools/PipelineDiagnostics.lean` — the emitters under test
* `BimodalLib/Diagnostics/Record.lean` — `Head.keys` and `Stage.reservedKeys`, the authority
* `Tests/BimodalLibTest/DiagnosticsTest.lean` — the same discipline for the two implemented stages
-/

-- Zeroing the one volatile timing field is what makes a whole record pinnable. Read for real by
-- `readZeroTimingsOption` in the `#eval` at the end of this file.
set_option diagnostics.zeroTimings true

open Lean (Json)
open BimodalLib.Diagnostics (Head Stage)
open BimodalTools.PipelineDiagnostics
open BimodalTools.TableauBridge (BranchGates)

namespace BimodalToolsTest.PipelineDiagnosticsTest

/-! ## Fixtures

One head shape, varying only in stage and frame class. The statement identifier is the `data/`
convention for an enumerated formula, which has no declaration name and so cannot use
`unregisteredStatementId`.
-/

/-- The shared head of every fixture below. -/
def hd (s : Stage) (fc : String) : Head :=
  { statement := datasetStatementId "bmlogic" 42
    stage := s
    fragment := "ModalBoolean"
    frameClass := fc
    commit := "unstamped"
    command := "pipeline --atoms 2" }

/-- An `enumerate` fixture: the live `ModalBoolean` complexity-5 yield at a 2-atom pool. -/
def gEnum : EnumerateRecord :=
  { head := hd .enumerate "Base"
    formulasGenerated := 133
    byFragment := [("ModalBoolean", 133)]
    byComplexity := [(4, 37), (5, 96)]
    duplicatesRemoved := 618 }

/-- A `decide` fixture whose verdict is `extractionFailed`: the tableau closed, so the formula is
valid, but no `⊢ φ` witness was extracted, so it is never admissible. -/
def gDecide : DecideRecord :=
  { head := hd .decide "Base"
    verdict := .extractionFailed
    decisionTimeMs := 1234
    fuelUsed := 300
    branchesOpened := 9
    branchesClosed := 9 }

/-- An `extract` fixture on the `extractionFailed` route: no derivation and no countermodel. -/
def gExtract : ExtractRecord :=
  { head := hd .extract "Base"
    derivationSize := none
    derivationHeight := none
    axiomSchemata := []
    extractionRoute := "proof_extractor"
    countermodelHistories := none
    countermodelTimes := none }

/-- All eight gates holding, which is the `Base`/`Dense`/`RTime` case (11 of 11 measured). -/
def allGates : BranchGates :=
  { timeOrderTotal := true
    boxAnchored := true
    regionLabel := true
    temporalWitness := true
    branchOrderValid := true
    saturated := true
    noClosure := true
    rootDenied := true }

/-- A `certify` fixture on the gated route, at `Base`. -/
def gCertify : CertifyRecord :=
  { head := hd .certify "Base"
    axioms := []
    countermodelGrade := some .gatedTableau
    gates := some allGates }

/-- A `certify` fixture at `ZTime`: the certificate route, with no gates evaluated. -/
def gCertifyZ : CertifyRecord :=
  { head := hd .certify "ZTime"
    axioms := []
    countermodelGrade := some .certificate
    gates := none }

/-- An `admit` fixture on the conjecture path, carrying the verdict verbatim. -/
def gAdmit : AdmitRecord :=
  { head := hd .admit "Base"
    disposition := .conjecture
    subsumedBy := none
    conjectureVerdict := some .extractionFailed }

/-! ## Key equality against `Stage.reservedKeys` -/

#guard gEnum.keys == Head.keys ++ Stage.reservedKeys .enumerate
#guard gDecide.keys == Head.keys ++ Stage.reservedKeys .decide
#guard gExtract.keys == Head.keys ++ Stage.reservedKeys .extract
#guard gCertify.keys == Head.keys ++ Stage.reservedKeys .certify
#guard gAdmit.keys == Head.keys ++ Stage.reservedKeys .admit

-- The head comes first in every one of them, and the payload is exactly the reserved tail.
#guard (gEnum.keys.take Head.keys.length) == Head.keys
#guard (gDecide.keys.drop Head.keys.length) == Stage.reservedKeys .decide

/-! ## The `decide` verdict vocabulary

`DecisionResult`'s own four constructor names, not `FormulaLabel`'s three. `extractionFailed` is
the one the three-name reading folds away, and it is the largest single non-`valid` outcome at
`ModalBoolean` complexity 5.
-/

#guard Verdict.all.length == 4
#guard Verdict.all.map Verdict.key ==
  ["valid", "invalid", "fuel_exhausted", "extraction_failed"]
#guard Verdict.all.all (fun v => Verdict.ofKey? v.key == some v)
#guard Verdict.ofKey? "extraction_failed" == some Verdict.extractionFailed
-- A valid formula with no witness: known valid, never admissible. That pair is what makes the
-- fourth name load-bearing rather than pedantic.
#guard Verdict.extractionFailed.isKnownValid
#guard !Verdict.extractionFailed.admissible
#guard Verdict.valid.admissible
-- `FormulaLabel`'s three-name reading is not a prefix of this one: it has no fourth name to drop.
#guard (Verdict.all.filter (fun v => v.isKnownValid)).length == 2

/-! ## The closed vocabularies of `certify` and `admit` -/

#guard Grade.all.map Grade.key == ["gated_tableau", "certificate"]
#guard Grade.all.all (fun g => Grade.ofKey? g.key == some g)
#guard Disposition.all.map Disposition.key == ["admitted", "subsumed", "conjecture"]
#guard Disposition.all.all (fun d => Disposition.ofKey? d.key == some d)

-- At `ZTime` no record claims the gated grade and none carries evaluated gates. The negative
-- case is a named fixture, so the assertion is `!r.zTimeWellFormed` and not a `!` that would
-- bind to the record instead of to the predicate.
/-- An ill-formed `ZTime` record: it claims the grade that is unavailable there. -/
def gCertifyZBadGrade : CertifyRecord :=
  { gCertifyZ with countermodelGrade := some Grade.gatedTableau }

/-- An ill-formed `ZTime` record: it carries gates that were never evaluated there. -/
def gCertifyZBadGates : CertifyRecord :=
  { gCertifyZ with gates := some allGates }

#guard gCertifyZ.zTimeWellFormed
#guard gCertify.zTimeWellFormed
#guard !gCertifyZBadGrade.zTimeWellFormed
#guard !gCertifyZBadGates.zTimeWellFormed

-- The two optional `admit` fields are present exactly on their own disposition.
/-- An ill-formed `admit` record: a conjecture with no verdict. -/
def gAdmitNoVerdict : AdmitRecord :=
  { gAdmit with conjectureVerdict := none }

/-- A well-formed `admit` record on the subsumption path. -/
def gAdmitSubsumed : AdmitRecord :=
  { gAdmit with
      disposition := .subsumed
      subsumedBy := some "BimodalLib.Registry.FormalSystem.Theorems.Combinators.identity"
      conjectureVerdict := none }

/-- An ill-formed `admit` record: admitted, yet naming a subsuming row. -/
def gAdmitBoth : AdmitRecord :=
  { gAdmit with
      disposition := .admitted
      subsumedBy := some "BimodalLib.Registry.foo"
      conjectureVerdict := none }

#guard gAdmit.dispositionWellFormed
#guard !gAdmitNoVerdict.dispositionWellFormed
#guard gAdmitSubsumed.dispositionWellFormed
#guard !gAdmitBoth.dispositionWellFormed

/-! ## The statement-identifier convention -/

#guard datasetStatementId "bmlogic" 42 == "bmlogic-00042"
#guard datasetStatementId "bmlogic" 123456 == "bmlogic-123456"
-- Distinct from the registry's own fallback, which needs a declaration name an enumerated
-- formula does not have.
#guard datasetStatementId "bmlogic" 42 != BimodalLib.Diagnostics.unregisteredStatementId "foo"

/-! ## Golden records

One per stage, pinned byte for byte under `diagnostics.zeroTimings`. Alphabetical, because
`Json.mkObj` renders a search tree; see this file's module docstring.
-/

/-- The compressed `enumerate` golden. -/
def gEnumGolden : String :=
  "{\"by_complexity\":{\"4\":37,\"5\":96},\"by_fragment\":{\"ModalBoolean\":133},\"comm\
   and\":\"pipeline --atoms 2\",\"commit\":\"unstamped\",\"duplicates_removed\":618,\"f\
   ormulas_generated\":133,\"fragment\":\"ModalBoolean\",\"frame_class\":\"Base\",\"sta\
   ge\":\"enumerate\",\"statement\":\"bmlogic-00042\"}"

/-- The compressed `decide` golden, with `decision_time_ms` zeroed. -/
def gDecideGolden : String :=
  "{\"branches_closed\":9,\"branches_opened\":9,\"command\":\"pipeline --atoms 2\",\"co\
   mmit\":\"unstamped\",\"decision_time_ms\":0,\"fragment\":\"ModalBoolean\",\"frame_cl\
   ass\":\"Base\",\"fuel_used\":300,\"stage\":\"decide\",\"statement\":\"bmlogic-00042\
   \",\"verdict\":\"extraction_failed\"}"

/-- The compressed `extract` golden. -/
def gExtractGolden : String :=
  "{\"axiom_schemata\":[],\"command\":\"pipeline --atoms 2\",\"commit\":\"unstamped\",\
   \"countermodel_histories\":null,\"countermodel_times\":null,\"derivation_height\":nu\
   ll,\"derivation_size\":null,\"extraction_route\":\"proof_extractor\",\"fragment\":\"\
   ModalBoolean\",\"frame_class\":\"Base\",\"stage\":\"extract\",\"statement\":\"bmlogi\
   c-00042\"}"

/-- The compressed `certify` golden at `Base`, on the gated route. -/
def gCertifyGolden : String :=
  "{\"axioms\":[],\"command\":\"pipeline --atoms 2\",\"commit\":\"unstamped\",\"counter\
   model_grade\":\"gated_tableau\",\"fragment\":\"ModalBoolean\",\"frame_class\":\"Base\
   \",\"gates\":{\"box_anchored_check\":true,\"branch_order_valid\":true,\"gated\":true\
   ,\"no_closure\":true,\"region_label_check\":true,\"root_denied\":true,\"saturated\":\
   true,\"temporal_witness_check\":true,\"time_order_total\":true},\"stage\":\"certify\
   \",\"statement\":\"bmlogic-00042\"}"

/-- The compressed `certify` golden at `ZTime`, on the certificate route. -/
def gCertifyZGolden : String :=
  "{\"axioms\":[],\"command\":\"pipeline --atoms 2\",\"commit\":\"unstamped\",\"counter\
   model_grade\":\"certificate\",\"fragment\":\"ModalBoolean\",\"frame_class\":\"ZTime\
   \",\"gates\":null,\"stage\":\"certify\",\"statement\":\"bmlogic-00042\"}"

/-- The compressed `admit` golden. -/
def gAdmitGolden : String :=
  "{\"command\":\"pipeline --atoms 2\",\"commit\":\"unstamped\",\"conjecture_verdict\":\
   \"extraction_failed\",\"disposition\":\"conjecture\",\"fragment\":\"ModalBoolean\",\
   \"frame_class\":\"Base\",\"stage\":\"admit\",\"statement\":\"bmlogic-00042\",\"subsu\
   med_by\":null}"

#guard gEnum.toJson.compress == gEnumGolden
#guard (gDecide.toJson true).compress == gDecideGolden
#guard gExtract.toJson.compress == gExtractGolden
#guard gCertify.toJson.compress == gCertifyGolden
#guard gCertifyZ.toJson.compress == gCertifyZGolden
#guard gAdmit.toJson.compress == gAdmitGolden

-- The `certify` golden reuses `BranchGates.toJson`'s snake_case keys verbatim rather than
-- restating them: its nine keys appear in the record, parsed back into the object.
#guard (gCertifyGolden.splitOn "temporal_witness_check").length == 2
#guard (gCertifyGolden.splitOn "\"gated\":true").length == 2

/-! ## The stamp option is read, not merely passed

`set_option diagnostics.zeroTimings true` at the top of this file reaches the emitter through
`readCommitOption`/`readZeroTimingsOption`, which read the options registered in
`BimodalLib/Diagnostics/Emit.lean`. The `#eval` below is what distinguishes "the flag was hard-
coded `true` in the `#guard` above" from "the option governs the record".
-/

/-- info: true -/
#guard_msgs in
#eval do
  let z ← readZeroTimingsOption
  return z && (gDecide.toJson z).compress == gDecideGolden

/-- info: "unstamped" -/
#guard_msgs in
#eval readCommitOption

end BimodalToolsTest.PipelineDiagnosticsTest
