import Bimodal.Syntax
import Bimodal.Automation.SuccessPatterns
import Bimodal.Metalogic.Decidability.CountermodelExtraction
import Bimodal.ProofSystem.Derivation

/-!
# JSON Serialization for Training Data Export

This module provides JSON serialization (`toJson`) and human-readable
pretty-printing (`prettyPrint`) for the core types used in the dual-signal
training data pipeline.

## Main Definitions

- `Atom.toJson` — Serialize atoms to JSON objects
- `Formula.toJson` — Recursive JSON serialization of formula trees
- `Formula.prettyPrint` — Human-readable formula notation
- `GoalCategory.toJson` — Category name as JSON string
- `PatternKey.toJson` — Feature vector as JSON object
- `SimpleCountermodel.toJson` — Countermodel as JSON object
- `RuleProfile` — Rule application counts from derivation tree walks
- `RuleProfile.toJson` — Rule counts as JSON object
- `walkDerivationTree` — Recursively count rule applications in a derivation

## Design

All serialization uses simple string concatenation — no external JSON library
is required. String values are escaped (double quotes replaced with `\"`).

## References

- Phase 1 of Task 201 implementation plan
- `Bimodal.Syntax.Formula` — Formula inductive type
- `Bimodal.Automation.SuccessPatterns` — `PatternKey` and `GoalCategory`
- `Bimodal.Metalogic.Decidability.CountermodelExtraction` — `SimpleCountermodel`
- `Bimodal.ProofSystem.Derivation` — `DerivationTree` and `height`
-/

namespace Bimodal.Automation.DataExport

open Bimodal.Syntax
open Bimodal.Automation
open Bimodal.Metalogic.Decidability
open Bimodal.ProofSystem

/-!
## String Helpers
-/

/--
Escape a string for inclusion in a JSON string value.
Replaces `"` with `\"` and `\` with `\\`.
-/
def escapeJsonString (s : String) : String :=
  s.toList.foldl (fun acc c =>
    match c with
    | '\\' => acc ++ "\\\\"
    | '"'  => acc ++ "\\\""
    | '\n' => acc ++ "\\n"
    | c    => acc.push c
  ) ""

/--
Wrap a list of JSON-formatted strings into a JSON array.

Example: `listToJsonArray ["1", "2", "3"]` produces `[1, 2, 3]`.
-/
def listToJsonArray (items : List String) : String :=
  "[" ++ String.intercalate ", " items ++ "]"

/-!
## Atom Serialization
-/

/--
Serialize an `Atom` to a JSON object string.

Examples:
- `{ base := "p", fresh_index := none }` → `{"base": "p", "fresh_index": null}`
- `{ base := "p", fresh_index := some 3 }` → `{"base": "p", "fresh_index": 3}`
-/
def _root_.Bimodal.Syntax.Atom.toJson (a : Atom) : String :=
  let baseStr := escapeJsonString a.base
  let idxStr := match a.fresh_index with
    | none   => "null"
    | some n => toString n
  "{\"base\": \"" ++ baseStr ++ "\", \"fresh_index\": " ++ idxStr ++ "}"

/-!
## Formula Serialization
-/

/--
Serialize a `Formula` to a recursive JSON object string.

The JSON schema uses a `"tag"` field for the constructor name:
- `atom a` → `{"tag": "atom", "name": "<base>"}`
- `bot` → `{"tag": "bot"}`
- `imp φ ψ` → `{"tag": "imp", "left": <φ>, "right": <ψ>}`
- `box φ` → `{"tag": "box", "child": <φ>}`
- `untl φ ψ` → `{"tag": "untl", "event": <φ>, "guard": <ψ>}`
- `snce φ ψ` → `{"tag": "snce", "event": <φ>, "guard": <ψ>}`
-/
def _root_.Bimodal.Syntax.Formula.toJson : Formula → String
  | .atom a   =>
    let nameStr := escapeJsonString a.base
    "{\"tag\": \"atom\", \"name\": \"" ++ nameStr ++ "\"}"
  | .bot      => "{\"tag\": \"bot\"}"
  | .imp φ ψ  =>
    "{\"tag\": \"imp\", \"left\": " ++ φ.toJson ++ ", \"right\": " ++ ψ.toJson ++ "}"
  | .box φ    =>
    "{\"tag\": \"box\", \"child\": " ++ φ.toJson ++ "}"
  | .untl φ ψ =>
    "{\"tag\": \"untl\", \"event\": " ++ φ.toJson ++ ", \"guard\": " ++ ψ.toJson ++ "}"
  | .snce φ ψ =>
    "{\"tag\": \"snce\", \"event\": " ++ φ.toJson ++ ", \"guard\": " ++ ψ.toJson ++ "}"

/--
Pretty-print a `Formula` in human-readable notation.

- `atom a` → the atom's base name (e.g., `"p"`)
- `bot` → `"⊥"`
- `imp φ ψ` → `"(φ → ψ)"`
- `box φ` → `"□φ"`
- `untl φ ψ` → `"U(φ, ψ)"`
- `snce φ ψ` → `"S(φ, ψ)"`
-/
def _root_.Bimodal.Syntax.Formula.prettyPrint : Formula → String
  | .atom a   => a.base
  | .bot      => "⊥"
  | .imp φ ψ  => "(" ++ φ.prettyPrint ++ " → " ++ ψ.prettyPrint ++ ")"
  | .box φ    => "□" ++ φ.prettyPrint
  | .untl φ ψ => "U(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"
  | .snce φ ψ => "S(" ++ φ.prettyPrint ++ ", " ++ ψ.prettyPrint ++ ")"

/--
Serialize a `Formula` to an S-expression string.

Canonical parenthesized prefix notation using constructor names as heads:
- `atom a` → `(atom "p")` or `(atom "p" 3)` if `fresh_index = some 3`
- `bot` → `bot`
- `imp φ ψ` → `(imp <φ> <ψ>)`
- `box φ` → `(box <φ>)`
- `untl φ ψ` → `(untl <φ> <ψ>)`
- `snce φ ψ` → `(snce <φ> <ψ>)`
-/
def _root_.Bimodal.Syntax.Formula.toSExpr : Formula → String
  | .atom a   =>
    let idx := match a.fresh_index with
      | none => ""
      | some n => " " ++ toString n
    "(atom \"" ++ escapeJsonString a.base ++ "\"" ++ idx ++ ")"
  | .bot      => "bot"
  | .imp φ ψ  => "(imp " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .box φ    => "(box " ++ φ.toSExpr ++ ")"
  | .untl φ ψ => "(untl " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"
  | .snce φ ψ => "(snce " ++ φ.toSExpr ++ " " ++ ψ.toSExpr ++ ")"

/--
Tokenize a `Formula` into a prefix-notation (Polish notation) token list.

Operator tokens: `ATOM`, `BOT`, `IMP`, `BOX`, `UNTL`, `SNCE`.
Atom base names appear as value tokens immediately after `ATOM`.

Examples:
- `p → q` → `["IMP", "ATOM", "p", "ATOM", "q"]`
- `□p` → `["BOX", "ATOM", "p"]`
- `U(p, q)` → `["UNTL", "ATOM", "p", "ATOM", "q"]`
-/
def _root_.Bimodal.Syntax.Formula.tokenize : Formula → List String
  | .atom a   => ["ATOM", a.base]
  | .bot      => ["BOT"]
  | .imp φ ψ  => "IMP" :: (φ.tokenize ++ ψ.tokenize)
  | .box φ    => "BOX" :: φ.tokenize
  | .untl φ ψ => "UNTL" :: (φ.tokenize ++ ψ.tokenize)
  | .snce φ ψ => "SNCE" :: (φ.tokenize ++ ψ.tokenize)

/--
Serialize a list of string tokens as a JSON array of quoted strings.

Example: `["IMP", "ATOM", "p"]` → `["IMP", "ATOM", "p"]`
-/
def tokenListToJson (tokens : List String) : String :=
  listToJsonArray (tokens.map fun t => "\"" ++ escapeJsonString t ++ "\"")

/-!
## GoalCategory Serialization
-/

/--
Serialize a `GoalCategory` to its string name for JSON.
-/
def _root_.Bimodal.Automation.GoalCategory.toJson : GoalCategory → String
  | .Atom        => "\"Atom\""
  | .Bottom      => "\"Bottom\""
  | .Implication => "\"Implication\""
  | .Box         => "\"Box\""
  | .AllPast     => "\"AllPast\""
  | .AllFuture   => "\"AllFuture\""
  | .Until       => "\"Until\""
  | .Since       => "\"Since\""

/-!
## PatternKey Serialization
-/

/--
Serialize a `PatternKey` to a JSON object string with all 5 fields.

Example output:
```json
{"modalDepth": 1, "temporalDepth": 0, "impCount": 1, "complexity": 3, "topOperator": "Implication"}
```
-/
def _root_.Bimodal.Automation.PatternKey.toJson (pk : PatternKey) : String :=
  "{\"modalDepth\": " ++ toString pk.modalDepth
  ++ ", \"temporalDepth\": " ++ toString pk.temporalDepth
  ++ ", \"impCount\": " ++ toString pk.impCount
  ++ ", \"complexity\": " ++ toString pk.complexity
  ++ ", \"topOperator\": " ++ pk.topOperator.toJson
  ++ "}"

/--
Map a `GoalCategory` to a numeric ID for feature vector encoding.

- `Atom` = 0, `Bottom` = 1, `Implication` = 2, `Box` = 3,
  `AllPast` = 4, `AllFuture` = 5, `Until` = 6, `Since` = 7
-/
def _root_.Bimodal.Automation.GoalCategory.toNat : GoalCategory → Nat
  | .Atom        => 0
  | .Bottom      => 1
  | .Implication => 2
  | .Box         => 3
  | .AllPast     => 4
  | .AllFuture   => 5
  | .Until       => 6
  | .Since       => 7

/--
Extract a flat numeric feature vector from a `PatternKey`.

The vector has 5 elements:
`[modalDepth, temporalDepth, impCount, complexity, topOperator.toNat]`
-/
def _root_.Bimodal.Automation.PatternKey.toFeatureVector (pk : PatternKey) : List Nat :=
  [pk.modalDepth, pk.temporalDepth, pk.impCount, pk.complexity, pk.topOperator.toNat]

/--
Serialize a `PatternKey` feature vector as a JSON array of integers.

Example: `[1, 0, 1, 3, 2]` for modalDepth=1, temporalDepth=0, impCount=1,
complexity=3, topOperator=Implication.
-/
def _root_.Bimodal.Automation.PatternKey.featureVectorToJson (pk : PatternKey) : String :=
  listToJsonArray (pk.toFeatureVector.map toString)

/-!
## SimpleCountermodel Serialization
-/

/--
Serialize a `SimpleCountermodel` to a JSON object string.

Example output:
```json
{"trueAtoms": [...], "falseAtoms": [...], "formula": {...}}
```
-/
def _root_.Bimodal.Metalogic.Decidability.SimpleCountermodel.toJson
    (cm : SimpleCountermodel) : String :=
  let trueStr := listToJsonArray (cm.trueAtoms.map Atom.toJson)
  let falseStr := listToJsonArray (cm.falseAtoms.map Atom.toJson)
  "{\"trueAtoms\": " ++ trueStr
  ++ ", \"falseAtoms\": " ++ falseStr
  ++ ", \"formula\": " ++ cm.formula.toJson
  ++ "}"

/-!
## Proof Metrics: RuleProfile
-/

/--
Counts of rule applications in a derivation tree.

Each field corresponds to one of the 7 constructors of `DerivationTree`:
`axiom`, `assumption`, `modus_ponens`, `necessitation`,
`temporal_necessitation`, `temporal_duality`, `weakening`.
-/
structure RuleProfile where
  axiomCount : Nat
  assumptionCount : Nat
  mpCount : Nat
  necessitationCount : Nat
  temporalNecessitationCount : Nat
  temporalDualityCount : Nat
  weakeningCount : Nat
  deriving Repr, Inhabited

/-- The empty rule profile (all counts zero). -/
def RuleProfile.empty : RuleProfile :=
  { axiomCount := 0
  , assumptionCount := 0
  , mpCount := 0
  , necessitationCount := 0
  , temporalNecessitationCount := 0
  , temporalDualityCount := 0
  , weakeningCount := 0 }

/-- Merge two rule profiles by summing corresponding counts. -/
def RuleProfile.merge (r1 r2 : RuleProfile) : RuleProfile :=
  { axiomCount := r1.axiomCount + r2.axiomCount
  , assumptionCount := r1.assumptionCount + r2.assumptionCount
  , mpCount := r1.mpCount + r2.mpCount
  , necessitationCount := r1.necessitationCount + r2.necessitationCount
  , temporalNecessitationCount := r1.temporalNecessitationCount + r2.temporalNecessitationCount
  , temporalDualityCount := r1.temporalDualityCount + r2.temporalDualityCount
  , weakeningCount := r1.weakeningCount + r2.weakeningCount }

/--
Recursively walk a `DerivationTree` to count rule applications.

Each constructor increments its corresponding counter. Binary rules
(modus_ponens) merge the profiles of both sub-derivations.
-/
def walkDerivationTree {fc : FrameClass} {Γ : Context} {φ : Formula}
    : DerivationTree fc Γ φ → RuleProfile
  | .axiom _ _ _ _ =>
    { RuleProfile.empty with axiomCount := 1 }
  | .assumption _ _ _ =>
    { RuleProfile.empty with assumptionCount := 1 }
  | .modus_ponens _ _ _ d1 d2 =>
    let r := (walkDerivationTree d1).merge (walkDerivationTree d2)
    { r with mpCount := r.mpCount + 1 }
  | .necessitation _ d =>
    let r := walkDerivationTree d
    { r with necessitationCount := r.necessitationCount + 1 }
  | .temporal_necessitation _ d =>
    let r := walkDerivationTree d
    { r with temporalNecessitationCount := r.temporalNecessitationCount + 1 }
  | .temporal_duality _ d =>
    let r := walkDerivationTree d
    { r with temporalDualityCount := r.temporalDualityCount + 1 }
  | .weakening _ _ _ d _ =>
    let r := walkDerivationTree d
    { r with weakeningCount := r.weakeningCount + 1 }

/--
Serialize a `RuleProfile` to a JSON object string.

Example output:
```json
{"axiom": 2, "assumption": 0, "modus_ponens": 1, "necessitation": 0,
 "temporal_necessitation": 0, "temporal_duality": 0, "weakening": 0}
```
-/
def RuleProfile.toJson (rp : RuleProfile) : String :=
  "{\"axiom\": " ++ toString rp.axiomCount
  ++ ", \"assumption\": " ++ toString rp.assumptionCount
  ++ ", \"modus_ponens\": " ++ toString rp.mpCount
  ++ ", \"necessitation\": " ++ toString rp.necessitationCount
  ++ ", \"temporal_necessitation\": " ++ toString rp.temporalNecessitationCount
  ++ ", \"temporal_duality\": " ++ toString rp.temporalDualityCount
  ++ ", \"weakening\": " ++ toString rp.weakeningCount
  ++ "}"

/-!
## Combined Proof Metrics Serialization
-/

/--
Serialize proof metrics (height + rule profile) as a JSON object.

Example output:
```json
{"height": 3, "rules": {"axiom": 1, "assumption": 0, ...}}
```
-/
def proofMetricsToJson (height : Nat) (rp : RuleProfile) : String :=
  "{\"height\": " ++ toString height
  ++ ", \"rules\": " ++ rp.toJson
  ++ "}"

end Bimodal.Automation.DataExport
