/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Axioms
import FormalSystem.ProofSystem.Derivation
import FormalSystem.Automation.DataExport
import FormalSystem.Automation.AxiomNames

/-!
# Machine Appendix Export - Shipped Machine-Readable Axiomatization

This module exports the complete TM axiomatization as a JSONL artifact shipped
with the BimodalReference book: the 42 axiom schemata, the 7 inference rules of
`DerivationTree`, and the derived-operator definitions, in the same formula
encoding as the dataset pipeline (`Formula.toJson` tag schema).

## Fidelity Design (implicit-index extraction)

Because `Axiom : Formula → Type` is *indexed* by the axiom's schema formula,
`mkAxiomEntry {φ : Formula} … (ax : Axiom φ)` recovers the schema from the type
index and the frame class from `Axiom.minFrameClass` — a wrong entry is a Lean
type error, never silent drift. The derived-operator unfoldings are serialized
by applying the real `Formula` defs to schematic atoms, so the kernel computes
every unfolding; nothing is transcribed by hand.

The 7 inference-rule records are declarative (rules are constructors of
`DerivationTree`, which has no formula index to exploit); each record carries a
doc-comment reference to the corresponding constructor in `Derivation.lean`,
and the rule *count* is cross-checked against the live source by
`scripts/typst-sync-check.sh` Check 3.

## Coverage Assertions

`main` fails with a nonzero exit unless:
- exactly 42 axiom entries are present, with name multiset equal to
  `FormalSystem.Automation.allAxiomNames` (shared with `BenchmarkAnchors.lean` via
  `Automation/AxiomNames.lean`; no missing, no extra, no duplicates);
- exactly 7 inference-rule entries are present.

## Output Schema (JSONL, one object per line)

- line 1: `{"kind": "metadata", "generator": "BimodalLogic/MachineAppendixExport",
  "version": "1.0", "stamp_commit": …, "stamp_date": …, counts…}`
- `{"kind": "axiom", "name", "layer", "params", "frame_class",
  "schema_string", "schema"}`
- `{"kind": "inference_rule", "name", "premises", "conclusion",
  "side_condition"}`
- `{"kind": "derived_operator", "name", "params", "definition_string",
  "definition"}`

`schema`/`definition` use the `Formula.toJson` tag encoding
(`atom`/`bot`/`imp`/`box`/`untl`/`snce`); `schema_string`/`definition_string`
use `Formula.prettyPrint`.

## Usage

```
lake exe machine_appendix -- --output PATH --stamp-commit SHA --stamp-date DATE
```

Invoked by `scripts/typst-machine-appendix.sh`, which injects the git stamps
(the exe never shells out to git).

## References

- `FormalSystem.ProofSystem.Axioms` — the 42 `Axiom` constructors and `FrameClass`
- `FormalSystem.ProofSystem.Derivation` — the 7 `DerivationTree` constructors
- `FormalSystem.Automation.DataExport` — `Formula.toJson`, `prettyPrint`, escaping
- `FormalSystem.Automation.AxiomNames` — `allAxiomNames` (canonical 42-name list)
-/

namespace FormalSystem.Automation.MachineAppendixExport

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Automation.DataExport

/-!
## Schematic Atoms

The metavariables of the axiom schemata, represented as atoms so that the
exported schema formulas display the schematic parameter names.
-/

/-- Schematic metavariable φ. -/
def phiS : Formula := Formula.atomS "φ"

/-- Schematic metavariable ψ. -/
def psiS : Formula := Formula.atomS "ψ"

/-- Schematic metavariable χ. -/
def chiS : Formula := Formula.atomS "χ"

/-- Schematic metavariable θ (needed by the 4-parameter axioms
`linear_until`/`linear_since`). -/
def thetaS : Formula := Formula.atomS "θ"

/-- Schematic metavariable p (used by `enrichment_until`/`enrichment_since`). -/
def pS : Formula := Formula.atomS "p"

/-!
## JSON Helpers
-/

/-- Quote and escape a string as a JSON string literal. -/
def strJson (s : String) : String :=
  "\"" ++ escapeJsonString s ++ "\""

/-- Serialize a list of strings as a JSON array of string literals. -/
def strListJson (ss : List String) : String :=
  listToJsonArray (ss.map strJson)

/-- Explicit 3-case `FrameClass` serialization (no `Repr` output dependence). -/
def frameClassToString : FrameClass → String
  | .Base => "Base"
  | .Dense => "Dense"
  | .Discrete => "Discrete"

/-!
## Axiom Entries (implicit-index extraction)
-/

/--
One exported axiom schema: constructor name, source layer, schematic
parameters, the schema formula, and the minimum frame class.
-/
structure AxiomEntry where
  name : String
  layer : String
  params : List String
  formula : Formula
  frameClass : FrameClass

/--
Build an `AxiomEntry` from an `Axiom φ` witness.

The schema formula is recovered from the type index `φ` and the frame class
from `Axiom.minFrameClass` — supplying a witness that does not match the named
constructor is a Lean type error, so entries cannot silently drift from
`Axioms.lean`.
-/
def mkAxiomEntry {φ : Formula} (name layer : String) (params : List String)
    (ax : Axiom φ) : AxiomEntry :=
  { name := name, layer := layer, params := params
  , formula := φ, frameClass := ax.minFrameClass }

/-- Serialize an `AxiomEntry` as one JSONL line. -/
def AxiomEntry.toJsonLine (e : AxiomEntry) : String :=
  "{\"kind\": \"axiom\", \"name\": " ++ strJson e.name
  ++ ", \"layer\": " ++ strJson e.layer
  ++ ", \"params\": " ++ strListJson e.params
  ++ ", \"frame_class\": " ++ strJson (frameClassToString e.frameClass)
  ++ ", \"schema_string\": " ++ strJson e.formula.prettyPrint
  ++ ", \"schema\": " ++ e.formula.toJson
  ++ "}"

/-- Layer name: Propositional (Layer 1, 4 axioms). -/
def layerPropositional : String := "Propositional"
/-- Layer name: S5 Modal (Layer 2, 5 axioms). -/
def layerS5Modal : String := "S5 Modal"
/-- Layer name: BX Temporal (Layer 3, 18 axioms). -/
def layerBXTemporal : String := "BX Temporal"
/-- Layer name: Additional BX Temporal (Layer 3b, 4 axioms). -/
def layerAdditionalBX : String := "Additional BX Temporal"
/-- Layer name: Modal-Temporal Interaction (Layer 4, 1 axiom). -/
def layerInteraction : String := "Modal-Temporal Interaction"
/-- Layer name: Uniformity (Layer 5, 5 axioms). -/
def layerUniformity : String := "Uniformity"
/-- Layer name: Prior (Layer 6, 2 axioms). -/
def layerPrior : String := "Prior"
/-- Layer name: Z1 (Layer 7, 1 axiom). -/
def layerZ1 : String := "Z1"
/-- Layer name: Density (Layer 8, 2 axioms). -/
def layerDensity : String := "Density"

/--
All 42 axiom entries, in `Axioms.lean` source order (the same order as
`BenchmarkAnchors.allAxiomNames`). Each entry applies the real constructor to
schematic atoms; the schema formula and frame class are extracted from the
resulting `Axiom φ` witness, never transcribed.
-/
def allAxiomEntries : List AxiomEntry :=
  [ -- Layer 1: Propositional (4)
    mkAxiomEntry "prop_k" layerPropositional ["φ", "ψ", "χ"] (Axiom.prop_k phiS psiS chiS)
  , mkAxiomEntry "prop_s" layerPropositional ["φ", "ψ"] (Axiom.prop_s phiS psiS)
  , mkAxiomEntry "ex_falso" layerPropositional ["φ"] (Axiom.ex_falso phiS)
  , mkAxiomEntry "peirce" layerPropositional ["φ", "ψ"] (Axiom.peirce phiS psiS)
    -- Layer 2: S5 Modal (5)
  , mkAxiomEntry "modal_t" layerS5Modal ["φ"] (Axiom.modal_t phiS)
  , mkAxiomEntry "modal_4" layerS5Modal ["φ"] (Axiom.modal_4 phiS)
  , mkAxiomEntry "modal_b" layerS5Modal ["φ"] (Axiom.modal_b phiS)
  , mkAxiomEntry "modal_5_collapse" layerS5Modal ["φ"] (Axiom.modal_5_collapse phiS)
  , mkAxiomEntry "modal_k_dist" layerS5Modal ["φ", "ψ"] (Axiom.modal_k_dist phiS psiS)
    -- Layer 3: BX Temporal (18)
  , mkAxiomEntry "serial_future" layerBXTemporal [] Axiom.serial_future
  , mkAxiomEntry "serial_past" layerBXTemporal [] Axiom.serial_past
  , mkAxiomEntry "left_mono_until_G" layerBXTemporal ["φ", "χ", "ψ"]
      (Axiom.left_mono_until_G phiS chiS psiS)
  , mkAxiomEntry "left_mono_since_H" layerBXTemporal ["φ", "χ", "ψ"]
      (Axiom.left_mono_since_H phiS chiS psiS)
  , mkAxiomEntry "right_mono_until" layerBXTemporal ["φ", "ψ", "χ"]
      (Axiom.right_mono_until phiS psiS chiS)
  , mkAxiomEntry "right_mono_since" layerBXTemporal ["φ", "ψ", "χ"]
      (Axiom.right_mono_since phiS psiS chiS)
  , mkAxiomEntry "connect_future" layerBXTemporal ["φ"] (Axiom.connect_future phiS)
  , mkAxiomEntry "connect_past" layerBXTemporal ["φ"] (Axiom.connect_past phiS)
  , mkAxiomEntry "enrichment_until" layerBXTemporal ["φ", "ψ", "p"]
      (Axiom.enrichment_until phiS psiS pS)
  , mkAxiomEntry "enrichment_since" layerBXTemporal ["φ", "ψ", "p"]
      (Axiom.enrichment_since phiS psiS pS)
  , mkAxiomEntry "self_accum_until" layerBXTemporal ["φ", "ψ"]
      (Axiom.self_accum_until phiS psiS)
  , mkAxiomEntry "self_accum_since" layerBXTemporal ["φ", "ψ"]
      (Axiom.self_accum_since phiS psiS)
  , mkAxiomEntry "absorb_until" layerBXTemporal ["φ", "ψ"] (Axiom.absorb_until phiS psiS)
  , mkAxiomEntry "absorb_since" layerBXTemporal ["φ", "ψ"] (Axiom.absorb_since phiS psiS)
  , mkAxiomEntry "linear_until" layerBXTemporal ["φ", "ψ", "χ", "θ"]
      (Axiom.linear_until phiS psiS chiS thetaS)
  , mkAxiomEntry "linear_since" layerBXTemporal ["φ", "ψ", "χ", "θ"]
      (Axiom.linear_since phiS psiS chiS thetaS)
  , mkAxiomEntry "until_F" layerBXTemporal ["φ", "ψ"] (Axiom.until_F phiS psiS)
  , mkAxiomEntry "since_P" layerBXTemporal ["φ", "ψ"] (Axiom.since_P phiS psiS)
    -- Layer 3b: Additional BX Temporal (4)
  , mkAxiomEntry "temp_linearity" layerAdditionalBX ["φ", "ψ"]
      (Axiom.temp_linearity phiS psiS)
  , mkAxiomEntry "temp_linearity_past" layerAdditionalBX ["φ", "ψ"]
      (Axiom.temp_linearity_past phiS psiS)
  , mkAxiomEntry "F_until_equiv" layerAdditionalBX ["φ"] (Axiom.F_until_equiv phiS)
  , mkAxiomEntry "P_since_equiv" layerAdditionalBX ["φ"] (Axiom.P_since_equiv phiS)
    -- Layer 4: Modal-Temporal Interaction (1)
  , mkAxiomEntry "modal_future" layerInteraction ["φ"] (Axiom.modal_future phiS)
    -- Layer 5: Uniformity (5)
  , mkAxiomEntry "discrete_symm_fwd" layerUniformity [] Axiom.discrete_symm_fwd
  , mkAxiomEntry "discrete_symm_bwd" layerUniformity [] Axiom.discrete_symm_bwd
  , mkAxiomEntry "discrete_propagate_fwd" layerUniformity [] Axiom.discrete_propagate_fwd
  , mkAxiomEntry "discrete_propagate_bwd" layerUniformity [] Axiom.discrete_propagate_bwd
  , mkAxiomEntry "discrete_box_necessity" layerUniformity [] Axiom.discrete_box_necessity
    -- Layer 6: Prior (2)
  , mkAxiomEntry "prior_UZ" layerPrior ["φ"] (Axiom.prior_UZ phiS)
  , mkAxiomEntry "prior_SZ" layerPrior ["φ"] (Axiom.prior_SZ phiS)
    -- Layer 7: Z1 (1)
  , mkAxiomEntry "z1" layerZ1 ["φ"] (Axiom.z1 phiS)
    -- Layer 8: Density (2)
  , mkAxiomEntry "density" layerDensity ["φ"] (Axiom.density phiS)
  , mkAxiomEntry "dense_indicator" layerDensity [] Axiom.dense_indicator
  ]

/-!
## Inference Rule Entries

The 7 rules are the constructors of `DerivationTree`
(`FormalSystem.ProofSystem.Derivation`). These records are declarative: the
turnstile schemata below mirror the constructor doc-comments; the count is
cross-checked against the live `inductive DerivationTree` block by
`scripts/typst-sync-check.sh` Check 3.
-/

/--
One exported inference rule: name, premise schemata, conclusion schema, and an
optional side condition.
-/
structure RuleEntry where
  name : String
  premises : List String
  conclusion : String
  sideCondition : Option String

/-- Serialize a `RuleEntry` as one JSONL line. -/
def RuleEntry.toJsonLine (e : RuleEntry) : String :=
  let side := match e.sideCondition with
    | none => "null"
    | some s => strJson s
  "{\"kind\": \"inference_rule\", \"name\": " ++ strJson e.name
  ++ ", \"premises\": " ++ strListJson e.premises
  ++ ", \"conclusion\": " ++ strJson e.conclusion
  ++ ", \"side_condition\": " ++ side
  ++ "}"

/--
The 7 inference rules of `DerivationTree`, in constructor source order
(`Derivation.lean`: `axiom`, `assumption`, `modus_ponens`, `necessitation`,
`temporal_necessitation`, `temporal_duality`, `weakening`).

Side conditions:
- `axiom` requires an axiom witness with compatible frame class
  (`h.minFrameClass ≤ fc`);
- `assumption` requires context membership (`φ ∈ Γ`);
- the three necessitation-style rules (`necessitation`,
  `temporal_necessitation`, `temporal_duality`) apply to theorems only
  (empty context);
- `weakening` requires `Γ ⊆ Δ`.
-/
def allRuleEntries : List RuleEntry :=
  [ { name := "axiom"
    , premises := []
    , conclusion := "Γ ⊢[fc] φ"
    , sideCondition := some "φ is an instance of an axiom schema with minFrameClass ≤ fc" }
  , { name := "assumption"
    , premises := []
    , conclusion := "Γ ⊢[fc] φ"
    , sideCondition := some "φ ∈ Γ" }
  , { name := "modus_ponens"
    , premises := ["Γ ⊢[fc] φ → ψ", "Γ ⊢[fc] φ"]
    , conclusion := "Γ ⊢[fc] ψ"
    , sideCondition := none }
  , { name := "necessitation"
    , premises := ["⊢[fc] φ"]
    , conclusion := "⊢[fc] □φ"
    , sideCondition := some "empty context only (theorems)" }
  , { name := "temporal_necessitation"
    , premises := ["⊢[fc] φ"]
    , conclusion := "⊢[fc] Gφ"
    , sideCondition := some "empty context only (theorems)" }
  , { name := "temporal_duality"
    , premises := ["⊢[fc] φ"]
    , conclusion := "⊢[fc] swap_temporal φ"
    , sideCondition := some "empty context only (theorems)" }
  , { name := "weakening"
    , premises := ["Γ ⊢[fc] φ"]
    , conclusion := "Δ ⊢[fc] φ"
    , sideCondition := some "Γ ⊆ Δ" }
  ]

/-!
## Derived Operator Entries

Each entry applies the real `Formula` def to schematic atoms, so the exported
definition is the kernel-computed unfolding to the six primitives — never a
hand transcription. `atom_s` (constructor convenience) and `swap_temporal`
(formula transformer, not a connective) are deliberately excluded.
-/

/--
One exported derived operator: name, schematic parameters, and the unfolded
definition as a `Formula` over the primitives.
-/
structure DerivedOpEntry where
  name : String
  params : List String
  definition : Formula

/-- Serialize a `DerivedOpEntry` as one JSONL line. -/
def DerivedOpEntry.toJsonLine (e : DerivedOpEntry) : String :=
  "{\"kind\": \"derived_operator\", \"name\": " ++ strJson e.name
  ++ ", \"params\": " ++ strListJson e.params
  ++ ", \"definition_string\": " ++ strJson e.definition.prettyPrint
  ++ ", \"definition\": " ++ e.definition.toJson
  ++ "}"

/-- Build a `DerivedOpEntry` (thin named constructor for readability). -/
def mkDerivedOp (name : String) (params : List String) (definition : Formula) :
    DerivedOpEntry :=
  { name := name, params := params, definition := definition }

/--
The 21 derived operators of `Formula` (Syntax/Formula.lean), in definition
source order. Every `definition` field is the real def applied to schematic
atoms; the kernel unfolds it to the primitive basis.
-/
def allDerivedOpEntries : List DerivedOpEntry :=
  [ mkDerivedOp "top" [] Formula.top
  , mkDerivedOp "neg" ["φ"] phiS.neg
  , mkDerivedOp "some_future" ["φ"] phiS.someFuture
  , mkDerivedOp "some_past" ["φ"] phiS.somePast
  , mkDerivedOp "all_future" ["φ"] phiS.allFuture
  , mkDerivedOp "all_past" ["φ"] phiS.allPast
  , mkDerivedOp "and" ["φ", "ψ"] (Formula.and phiS psiS)
  , mkDerivedOp "or" ["φ", "ψ"] (Formula.or phiS psiS)
  , mkDerivedOp "diamond" ["φ"] phiS.diamond
  , mkDerivedOp "always" ["φ"] phiS.always
  , mkDerivedOp "next" ["φ"] phiS.next
  , mkDerivedOp "prev" ["φ"] phiS.prev
  , mkDerivedOp "weak_future" ["φ"] phiS.weakFuture
  , mkDerivedOp "weak_past" ["φ"] phiS.weakPast
  , mkDerivedOp "release" ["φ", "ψ"] (Formula.release phiS psiS)
  , mkDerivedOp "weak_until" ["φ", "ψ"] (Formula.weakUntil phiS psiS)
  , mkDerivedOp "trigger" ["φ", "ψ"] (Formula.trigger phiS psiS)
  , mkDerivedOp "weak_since" ["φ", "ψ"] (Formula.weakSince phiS psiS)
  , mkDerivedOp "strong_release" ["φ", "ψ"] (Formula.strongRelease phiS psiS)
  , mkDerivedOp "strong_trigger" ["φ", "ψ"] (Formula.strongTrigger phiS psiS)
  , mkDerivedOp "sometimes" ["φ"] phiS.sometimes
  ]

/-!
## CLI and Main
-/

/-- CLI configuration for the exporter. -/
structure Config where
  output : String := "typst/generated/machine-appendix.jsonl"
  stampCommit : String := "unstamped"
  stampDate : String := "unstamped"

/--
Parse CLI arguments: `--output PATH`, `--stamp-commit SHA`, `--stamp-date DATE`
(following the `DatasetExport.parseCLIArgs` precedent).
-/
def parseArgs (args : List String) : Config :=
  go args {}
where
  go : List String → Config → Config
  | [], acc => acc
  | "--output" :: p :: rest, acc => go rest { acc with output := p }
  | "--stamp-commit" :: s :: rest, acc => go rest { acc with stampCommit := s }
  | "--stamp-date" :: d :: rest, acc => go rest { acc with stampDate := d }
  | _ :: rest, acc => go rest acc

/-- Metadata envelope line (first JSONL line), following the
`DatasetExporter.DatasetMetadata` precedent. -/
def metadataLine (cfg : Config) (axCount ruleCount opCount : Nat) : String :=
  "{\"kind\": \"metadata\""
  ++ ", \"generator\": \"BimodalLogic/MachineAppendixExport\""
  ++ ", \"version\": \"1.0\""
  ++ ", \"stamp_commit\": " ++ strJson cfg.stampCommit
  ++ ", \"stamp_date\": " ++ strJson cfg.stampDate
  ++ ", \"axiom_count\": " ++ toString axCount
  ++ ", \"rule_count\": " ++ toString ruleCount
  ++ ", \"derived_operator_count\": " ++ toString opCount
  ++ ", \"formula_encoding\": \"Formula.toJson tag schema (atom/bot/imp/box/untl/snce)\""
  ++ "}"

/--
Coverage check mirroring `BenchmarkAnchors.checkCoverage`: the axiom entry
names must be exactly the 42 names in `allAxiomNames` (no missing, no extra,
no duplicates), and there must be exactly 7 rule entries. Returns diagnostics
(empty list = pass).
-/
def coverageDiagnostics : List String :=
  let names := allAxiomEntries.map (·.name)
  let missing := allAxiomNames.filter (fun n => !(names.contains n))
  let extra := names.filter (fun n => !(allAxiomNames.contains n))
  let dups := names.length - names.eraseDups.length
  let d1 := if allAxiomEntries.length == 42 then []
    else [s!"axiom entry count {allAxiomEntries.length} ≠ 42"]
  let d2 := if missing.isEmpty then []
    else [s!"missing axiom entries: {missing}"]
  let d3 := if extra.isEmpty then []
    else [s!"unexpected axiom entries: {extra}"]
  let d4 := if dups == 0 then []
    else [s!"duplicate axiom entry names ({dups} duplicates)"]
  let d5 := if allRuleEntries.length == 7 then []
    else [s!"inference rule count {allRuleEntries.length} ≠ 7"]
  d1 ++ d2 ++ d3 ++ d4 ++ d5

/--
Entry point: verify coverage, then stream the JSONL artifact (metadata line
first, then 42 axiom lines, 7 rule lines, and the derived-operator lines).
Exits nonzero with diagnostics on any coverage mismatch.
-/
def main (args : List String) : IO UInt32 := do
  let cfg := parseArgs args

  -- Coverage assertions (mirroring BenchmarkAnchors.checkCoverage)
  let diags := coverageDiagnostics
  if !diags.isEmpty then
    IO.eprintln "machine_appendix: coverage assertion FAILED:"
    for d in diags do
      IO.eprintln s!"  - {d}"
    return 1

  -- Ensure output directory exists
  let outPath := System.FilePath.mk cfg.output
  if let some dir := outPath.parent then
    IO.FS.createDirAll dir

  -- Stream the artifact
  let handle ← IO.FS.Handle.mk outPath .write
  handle.putStrLn (metadataLine cfg allAxiomEntries.length allRuleEntries.length
    allDerivedOpEntries.length)
  for e in allAxiomEntries do
    handle.putStrLn e.toJsonLine
  for e in allRuleEntries do
    handle.putStrLn e.toJsonLine
  for e in allDerivedOpEntries do
    handle.putStrLn e.toJsonLine
  handle.flush

  IO.println s!"machine_appendix: wrote {cfg.output} \
    ({allAxiomEntries.length} axioms, {allRuleEntries.length} rules, \
    {allDerivedOpEntries.length} derived operators; \
    stamp {cfg.stampCommit} {cfg.stampDate})"
  return 0

end FormalSystem.Automation.MachineAppendixExport

/-- Executable entry point for `lake exe machine_appendix`. -/
def main (args : List String) : IO UInt32 :=
  FormalSystem.Automation.MachineAppendixExport.main args
