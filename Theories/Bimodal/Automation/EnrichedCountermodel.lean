import Bimodal.Syntax
import Bimodal.Automation.DataExport
import Bimodal.Metalogic.Decidability.CountermodelExtraction
import Bimodal.Metalogic.Decidability.SignedFormula

/-!
# Enriched Countermodel Extraction

This module extends countermodel extraction beyond the atom-level `SimpleCountermodel`
to capture the full saturated branch content, providing richer corrective signal
for training data.

## Main Definitions

- `EnrichedCountermodel`: Enriched countermodel with full branch, modal, and temporal formulas
- `isModalFormula`: Check if a signed formula has a modal top-level operator
- `isTemporalFormula`: Check if a signed formula has a temporal top-level operator
- `extractModalFormulas`: Filter a branch for modal signed formulas
- `extractTemporalFormulas`: Filter a branch for temporal signed formulas
- `extractEnrichedCountermodel`: Build enriched countermodel from a raw branch
- `findEnrichedCountermodel`: Run the tableau and extract enriched countermodel
- `SignedFormula.toJson`: JSON serialization for signed formulas
- `EnrichedCountermodel.toJson`: JSON serialization for enriched countermodels

## Design

`SimpleCountermodel` captures only atoms (which atoms are true/false).
The saturated branch contains richer structural information: which modal and
temporal formulas held or failed, and the branch's total complexity. This helps
the value network learn *why* a formula is invalid — which modal or temporal
subformulas are the obstruction.

## References

- Phase 4 of Task 201 implementation plan
- `Bimodal.Metalogic.Decidability.CountermodelExtraction` — `SimpleCountermodel`
- `Bimodal.Metalogic.Decidability.SignedFormula` — `SignedFormula`, `Branch`
- `Bimodal.Metalogic.Decidability.Saturation` — `buildTableau`, `ExpandedTableau`
-/

set_option autoImplicit false

namespace Bimodal.Automation.Enriched

open Bimodal.Syntax
open Bimodal.Metalogic.Decidability
open Bimodal.Automation.DataExport

/-!
## Enriched Countermodel Type
-/

/--
An enriched countermodel that extends `SimpleCountermodel` with full branch
information from the saturated tableau.

- `simple`: The atom-level countermodel (true/false atoms)
- `branchFormulas`: The full list of signed formulas on the saturated branch
- `modalFormulas`: Signed formulas whose top-level operator is modal (box)
- `temporalFormulas`: Signed formulas whose top-level operator is temporal (untl/snce)
- `branchLength`: Total number of signed formulas on the branch
-/
structure EnrichedCountermodel where
  simple : SimpleCountermodel
  branchFormulas : List SignedFormula
  modalFormulas : List SignedFormula
  temporalFormulas : List SignedFormula
  branchLength : Nat
  deriving Repr

/-!
## Formula Classification
-/

/--
Check if a signed formula has a modal top-level operator.

A formula is considered modal if its top-level constructor is `box`,
or if it is an implication with `box` on the left (a common pattern
in modal tableau branches from box-elimination rules).
-/
def isModalFormula (sf : SignedFormula) : Bool :=
  match sf.formula with
  | .box _ => true
  | .imp (.box _) _ => true
  | _ => false

/--
Check if a signed formula has a temporal top-level operator.

A formula is considered temporal if its top-level constructor is
`untl` or `snce`. This captures both primitive temporal operators
and their derived forms (G, H, F, P all reduce to untl/snce combinations).
-/
def isTemporalFormula (sf : SignedFormula) : Bool :=
  match sf.formula with
  | .untl _ _ => true
  | .snce _ _ => true
  | _ => false

/--
Extract all modal signed formulas from a branch.
-/
def extractModalFormulas (branch : Branch) : List SignedFormula :=
  branch.filter isModalFormula

/--
Extract all temporal signed formulas from a branch.
-/
def extractTemporalFormulas (branch : Branch) : List SignedFormula :=
  branch.filter isTemporalFormula

/-!
## Enriched Countermodel Construction
-/

/--
Build an enriched countermodel from a formula and its saturated open branch.

This extracts:
1. The simple countermodel (atom truth assignments) via `extractSimpleCountermodel`
2. The full branch content
3. Modal and temporal subsets of the branch
4. The branch length
-/
def extractEnrichedCountermodel (φ : Formula) (branch : Branch) : EnrichedCountermodel :=
  { simple := extractSimpleCountermodel φ branch
  , branchFormulas := branch
  , modalFormulas := extractModalFormulas branch
  , temporalFormulas := extractTemporalFormulas branch
  , branchLength := branch.length
  }

/--
Result type for enriched countermodel extraction.
-/
inductive EnrichedCountermodelResult (φ : Formula) : Type where
  /-- Successfully extracted an enriched countermodel. -/
  | found (ecm : EnrichedCountermodel)
  /-- Formula is valid (all branches closed), no countermodel exists. -/
  | valid
  /-- Extraction failed (e.g., tableau construction timeout). -/
  | failed (reason : String)
  deriving Repr

/--
Try to find an enriched countermodel for a formula.

Uses `buildTableau` to construct the tableau, then extracts enriched data
from the open branch if one exists. This gives access to the raw `Branch`
(unlike `findCountermodel`, which discards it after extracting atoms).
-/
def findEnrichedCountermodel (φ : Formula) (fuel : Nat := 1000)
    : EnrichedCountermodelResult φ :=
  match buildTableau φ fuel with
  | none => .failed "Tableau construction timeout"
  | some (.allClosed _) => .valid
  | some (.hasOpen openBranch _) =>
      .found (extractEnrichedCountermodel φ openBranch)

/-!
## JSON Serialization
-/

/--
Serialize a `Sign` to a JSON string value (`"pos"` or `"neg"`).
-/
def Sign.toJsonStr : Sign → String
  | .pos => "\"pos\""
  | .neg => "\"neg\""

/--
Serialize a `SignedFormula` to a JSON object string.

Example output:
```json
{"sign": "pos", "formula": {"tag": "atom", "name": "p"}}
```
-/
def _root_.Bimodal.Metalogic.Decidability.SignedFormula.toJson (sf : SignedFormula) : String :=
  "{\"sign\": " ++ Sign.toJsonStr sf.sign
  ++ ", \"formula\": " ++ sf.formula.toJson
  ++ ", \"label\": {\"world\": " ++ toString sf.label.world
  ++ ", \"time\": " ++ toString sf.label.time ++ "}"
  ++ "}"

/--
Serialize an `EnrichedCountermodel` to a JSON object string.

Example output:
```json
{
  "simple": {"trueAtoms": [...], "falseAtoms": [...], "formula": {...}},
  "branchFormulas": [{"sign": "neg", "formula": {...}}, ...],
  "modalFormulas": [...],
  "temporalFormulas": [...],
  "branchLength": 5
}
```
-/
def EnrichedCountermodel.toJson (ecm : EnrichedCountermodel) : String :=
  let simpleStr := ecm.simple.toJson
  let branchStr := listToJsonArray (ecm.branchFormulas.map SignedFormula.toJson)
  let modalStr := listToJsonArray (ecm.modalFormulas.map SignedFormula.toJson)
  let temporalStr := listToJsonArray (ecm.temporalFormulas.map SignedFormula.toJson)
  "{\"simple\": " ++ simpleStr
  ++ ", \"branchFormulas\": " ++ branchStr
  ++ ", \"modalFormulas\": " ++ modalStr
  ++ ", \"temporalFormulas\": " ++ temporalStr
  ++ ", \"branchLength\": " ++ toString ecm.branchLength
  ++ "}"

end Bimodal.Automation.Enriched
