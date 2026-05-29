import Bimodal.Syntax.Formula
import Bimodal.Syntax.Context
import Bimodal.ProofSystem.Derivation
import Bimodal.Automation.DataExport

/-!
# Proof Step Extractor for BimodalHarness Training Data

This module implements the proof step extraction pipeline that walks
`DerivationTree` values and emits ordered `ProofStep` records for the
BimodalHarness AlphaZero-style training pipeline.

## Main Definitions

- `Axiom.toName`: Maps all 42 axiom constructors to string names
- `ProofStep`: Structure containing (context, goal, rule, axiom_name, subgoals)
- `ProofStep.toJson`: JSON serialization matching the `ProofStepRecord` schema
- `extractStepSequence`: Recursive tree walker emitting ordered proof steps
- `TheoremEntry`: Registry entry pairing theorem name with DerivationTree value
- `theoremRegistry`: Collection of all computable theorems for extraction

## Design

The 49-action space consists of:
- 42 axiom constructors (via `Axiom.toName`)
- 7 inference rules (axiom, assumption, modus_ponens, necessitation,
  temporal_necessitation, temporal_duality, weakening)

Each `ProofStep` captures the proof state at a single node: the current
context, the goal formula, which rule was applied, which axiom (if any),
and what subgoals remain.

## References

- `Bimodal.ProofSystem.Derivation` — `DerivationTree` and constructors
- `Bimodal.ProofSystem.Axioms` — `Axiom` inductive with 42 constructors
- `Bimodal.Automation.DataExport` — JSON serialization helpers
-/

namespace Bimodal.Automation.ProofStepExtractor

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Automation.DataExport

/-!
## Axiom Name Mapping

Maps all 42 axiom constructors to their string names for the action space.
-/

/--
Map each axiom constructor to its canonical string name.

This exhaustive 42-case pattern match provides the string representation
of each axiom for the training data action space. The names match the
constructor names in `Bimodal.ProofSystem.Axiom`.
-/
def _root_.Bimodal.ProofSystem.Axiom.toName {φ : Formula} : Axiom φ → String
  -- Layer 1: Propositional (4)
  | .prop_k _ _ _ => "prop_k"
  | .prop_s _ _ => "prop_s"
  | .ex_falso _ => "ex_falso"
  | .peirce _ _ => "peirce"
  -- Layer 2: S5 Modal (5)
  | .modal_t _ => "modal_t"
  | .modal_4 _ => "modal_4"
  | .modal_b _ => "modal_b"
  | .modal_5_collapse _ => "modal_5_collapse"
  | .modal_k_dist _ _ => "modal_k_dist"
  -- Layer 3: BX Temporal (20)
  | .serial_future => "serial_future"
  | .serial_past => "serial_past"
  | .left_mono_until_G _ _ _ => "left_mono_until_G"
  | .left_mono_since_H _ _ _ => "left_mono_since_H"
  | .right_mono_until _ _ _ => "right_mono_until"
  | .right_mono_since _ _ _ => "right_mono_since"
  | .connect_future _ => "connect_future"
  | .connect_past _ => "connect_past"
  | .enrichment_until _ _ _ => "enrichment_until"
  | .enrichment_since _ _ _ => "enrichment_since"
  | .self_accum_until _ _ => "self_accum_until"
  | .self_accum_since _ _ => "self_accum_since"
  | .absorb_until _ _ => "absorb_until"
  | .absorb_since _ _ => "absorb_since"
  | .linear_until _ _ _ _ => "linear_until"
  | .linear_since _ _ _ _ => "linear_since"
  | .until_F _ _ => "until_F"
  | .since_P _ _ => "since_P"
  | .temp_linearity _ _ => "temp_linearity"
  | .temp_linearity_past _ _ => "temp_linearity_past"
  -- Layer 3b: Additional BX Temporal (4)
  | .F_until_equiv _ => "F_until_equiv"
  | .P_since_equiv _ => "P_since_equiv"
  -- Layer 4: Modal-Temporal Interaction (1)
  | .modal_future _ => "modal_future"
  -- Layer 5: Uniformity Axioms (5)
  | .discrete_symm_fwd => "discrete_symm_fwd"
  | .discrete_symm_bwd => "discrete_symm_bwd"
  | .discrete_propagate_fwd => "discrete_propagate_fwd"
  | .discrete_propagate_bwd => "discrete_propagate_bwd"
  | .discrete_box_necessity => "discrete_box_necessity"
  -- Layer 6: Prior Axioms (2)
  | .prior_UZ _ => "prior_UZ"
  | .prior_SZ _ => "prior_SZ"
  -- Layer 7: Z1 Axiom (1)
  | .z1 _ => "z1"
  -- Layer 8: Density Axioms (2)
  | .density _ => "density"
  | .dense_indicator => "dense_indicator"

/-!
## ProofStep Structure

Each ProofStep captures the proof state at a single derivation tree node.
-/

/--
A single proof step extracted from a derivation tree node.

Fields:
- `theoremName`: Name of the theorem being extracted
- `stepIndex`: Position in the step sequence (0-indexed)
- `context`: The context (list of formulas) at this node
- `goal`: The formula being derived at this node
- `rule`: Name of the inference rule applied (one of 7 rules)
- `axiomName`: Name of the axiom (non-null only when rule = "axiom")
- `subgoals`: List of subgoal formulas (children of this node)
- `frameClass`: Frame class parameter of the derivation
-/
structure ProofStep where
  theoremName : String
  stepIndex : Nat
  context : List Formula
  goal : Formula
  rule : String
  axiomName : Option String
  subgoals : List Formula
  frameClass : String
  deriving Repr

/-!
## JSON Serialization
-/

/--
Serialize a context (list of formulas) to a JSON array string.
-/
def contextToJson (ctx : List Formula) : String :=
  listToJsonArray (ctx.map Formula.toJson)

/--
Serialize a `ProofStep` to a JSON object string matching the
`ProofStepRecord` schema expected by BimodalHarness.

The output format is:
```json
{
  "theorem_name": "...",
  "step_index": 0,
  "context": [...],
  "goal": {...},
  "rule": "...",
  "axiom_name": "..." | null,
  "subgoals": [...],
  "frame_class": "..."
}
```
-/
def ProofStep.toJson (step : ProofStep) : String :=
  let axiomStr := match step.axiomName with
    | none => "null"
    | some name => "\"" ++ escapeJsonString name ++ "\""
  "{\"theorem_name\": \"" ++ escapeJsonString step.theoremName ++ "\""
  ++ ", \"step_index\": " ++ toString step.stepIndex
  ++ ", \"context\": " ++ contextToJson step.context
  ++ ", \"goal\": " ++ step.goal.toJson
  ++ ", \"rule\": \"" ++ step.rule ++ "\""
  ++ ", \"axiom_name\": " ++ axiomStr
  ++ ", \"subgoals\": " ++ listToJsonArray (step.subgoals.map Formula.toJson)
  ++ ", \"frame_class\": \"" ++ step.frameClass ++ "\""
  ++ "}"

/-!
## Frame Class Serialization
-/

/--
Serialize a `FrameClass` to its string name.
-/
def frameClassToString : FrameClass → String
  | .Base => "Base"
  | .Dense => "Dense"
  | .Discrete => "Discrete"

/-!
## Step Extraction

The core extraction function recursively walks a `DerivationTree` and
accumulates `ProofStep` records in pre-order (parent before children).
-/

/--
Recursively walk a `DerivationTree` and emit ordered `ProofStep` records.

The traversal is pre-order: each node emits its own step first, then
recursively processes sub-derivations. The `startIndex` parameter tracks
the current position in the global step sequence.

Returns the list of steps and the next available index.
-/
def extractStepSequence {fc : FrameClass} {Γ : Context} {φ : Formula}
    (thmName : String) (fcStr : String) (startIndex : Nat)
    : DerivationTree fc Γ φ → (List ProofStep × Nat)
  | .axiom Γ φ h _ =>
    let step : ProofStep := {
      theoremName := thmName
      stepIndex := startIndex
      context := Γ
      goal := φ
      rule := "axiom"
      axiomName := some h.toName
      subgoals := []
      frameClass := fcStr
    }
    ([step], startIndex + 1)

  | .assumption Γ φ _ =>
    let step : ProofStep := {
      theoremName := thmName
      stepIndex := startIndex
      context := Γ
      goal := φ
      rule := "assumption"
      axiomName := none
      subgoals := []
      frameClass := fcStr
    }
    ([step], startIndex + 1)

  | .modus_ponens Γ φ ψ d1 d2 =>
    let step : ProofStep := {
      theoremName := thmName
      stepIndex := startIndex
      context := Γ
      goal := ψ
      rule := "modus_ponens"
      axiomName := none
      subgoals := [φ.imp ψ, φ]
      frameClass := fcStr
    }
    let (steps1, idx1) := extractStepSequence thmName fcStr (startIndex + 1) d1
    let (steps2, idx2) := extractStepSequence thmName fcStr idx1 d2
    ([step] ++ steps1 ++ steps2, idx2)

  | .necessitation φ d =>
    let step : ProofStep := {
      theoremName := thmName
      stepIndex := startIndex
      context := []
      goal := Formula.box φ
      rule := "necessitation"
      axiomName := none
      subgoals := [φ]
      frameClass := fcStr
    }
    let (steps, idx) := extractStepSequence thmName fcStr (startIndex + 1) d
    ([step] ++ steps, idx)

  | .temporal_necessitation φ d =>
    let step : ProofStep := {
      theoremName := thmName
      stepIndex := startIndex
      context := []
      goal := Formula.all_future φ
      rule := "temporal_necessitation"
      axiomName := none
      subgoals := [φ]
      frameClass := fcStr
    }
    let (steps, idx) := extractStepSequence thmName fcStr (startIndex + 1) d
    ([step] ++ steps, idx)

  | .temporal_duality φ d =>
    let step : ProofStep := {
      theoremName := thmName
      stepIndex := startIndex
      context := []
      goal := φ.swap_temporal
      rule := "temporal_duality"
      axiomName := none
      subgoals := [φ]
      frameClass := fcStr
    }
    let (steps, idx) := extractStepSequence thmName fcStr (startIndex + 1) d
    ([step] ++ steps, idx)

  | .weakening _Γ Δ φ d _ =>
    let step : ProofStep := {
      theoremName := thmName
      stepIndex := startIndex
      context := Δ
      goal := φ
      rule := "weakening"
      axiomName := none
      subgoals := [φ]
      frameClass := fcStr
    }
    let (steps, idx) := extractStepSequence thmName fcStr (startIndex + 1) d
    ([step] ++ steps, idx)

/-!
## Theorem Registry

The registry pairs theorem names with their `DerivationTree` values,
packaged as sigma types to erase the formula and frame class parameters.
-/

/--
A registry entry for a computable theorem.

Packages a theorem name with a thunk that produces a list of ProofStep records.
The thunk pattern avoids evaluating all derivation trees at registry construction time.
-/
structure TheoremEntry where
  name : String
  extract : Unit → List ProofStep

end Bimodal.Automation.ProofStepExtractor
