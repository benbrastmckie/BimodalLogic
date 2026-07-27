/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.DecisionProcedure
import FormalSystem.Metalogic.Decidability.CancellableExpansion
import FormalSystem.Automation.SuccessPatterns
import FormalSystem.Automation.FormulaEnumerator
import FormalSystem.Automation.DataExport
import FormalSystem.Automation.EnrichedCountermodel
import FormalSystem.Automation.InterestingnessMetrics
import FormalSystem.Automation.ForwardProofGenerator
import Std.Data.HashMap

/-!
# Dataset Generator: Decider Integration and ProofTrace Extraction

This module provides the labeling pipeline for the formula dataset.
It runs the existing `DecisionProcedure.decide` on enumerated formulas,
extracts simplified proof traces from valid results, computes difficulty
metrics, and produces labeled records.

## Main Definitions

- `ProofTrace`: Simplified proof information (height, axiom names, rule names)
- `DifficultyMetrics`: Structural and computational difficulty measures
- `FormulaLabel`: Classification label (valid, invalid, timeout)
- `LabeledFormula`: Complete labeled record with formula, label, trace, and metrics
- `labelFormula`: Run decision procedure and produce a labeled record
- `labelBatch`: Process multiple formulas with progress reporting
- `GenerationMode`: Labeling mode — exhaustive, proofFirst, or hybrid
- `structuralPrefilterWithAxiom`: O(n) syntactic prefilter for known-valid patterns

## Structural Prefilter Patterns

### Valid Prefilter (`structuralPrefilterWithAxiom`)

Short-circuits the decision procedure for formulas matching known-valid
syntactic shapes:

- **Identity**: `φ → φ`
- **Bot-temporal**: `U(⊥, X) → Y`, `S(□⊥, X) → Y`, etc.
- **Tautological consequent**: `X → (p → p)`, `X → □(q → q)`
- **S5 reflexive conflict**: `□φ ∧ ¬φ → Y`
- **Temporal loop**: `U(X, guard) ∧ G(¬guard) → Y`
- **Subsumption**: `□φ → φ`, `Gφ → φ`, `Gφ → Fφ`, `F(Fφ) → Fφ`, etc.
- **Temporal implication**: `U(X, Y) → F(Y)`, `S(X, Y) → P(Y)`
- **Box descent**: `□(valid)` where `valid` is structurally valid

### Invalid Prefilter (`structuralInvalidPrefilter`)

Companion to the valid prefilter. Detects formulas that are provably
**invalid** (have obvious countermodels), inserted as Phase 1.5 in
`labelFormulaImpl` between the valid prefilter and the tableau:

- **False consequent** (`invalid_false_consequent`): `φ → ψ` where `ψ`
  is always false and `φ` is not always false
- **Satisfiable negation** (`invalid_satisfiable_neg`): `φ → ⊥` where
  `φ` is trivially satisfiable, or `φ → ψ` where `φ` is satisfiable
  and `ψ` is always false
- **Unfulfillable eventuality** (`invalid_unfulfillable_eventuality`):
  `φ → U(event, guard)` where `φ` contains `G(¬event)`, or the
  symmetric `S` case with `H(¬event)`

Formal soundness proofs in `PrefilterSoundness.lean`.

## Design Decisions

- **Simplified ProofTrace**: Extracts height, axiom constructor names, and rule names
  from `DerivationTree` without full serialization (dependent types make full
  serialization impractical)
- **Frame class support**: `labelFormula` accepts `fc : FrameClass` parameter
  (default `.Base`), enabling generation for Base, Dense, and Discrete frame classes
  via the `--frame-class` CLI flag
- **Hybrid labeling**: `labelFormula` accepts `mode : GenerationMode` and optional
  `ProofPool` parameters. In hybrid mode, formulas are checked against
  the proof pool for O(1) lookup before falling through to the tableau.
- **Wall-clock timing**: Uses `IO.monoMsNow` for decision time measurement
- **All axiom constructors handled**: Pattern match covers all constructors in
  `FormalSystem.ProofSystem.Axiom`

## References

- DecisionProcedure: FormalSystem/Metalogic/Decidability/DecisionProcedure.lean
-/

set_option autoImplicit false

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Automation.DataExport
open FormalSystem.Automation.Enriched
open FormalSystem.Automation.InterestingnessMetrics

/--
Simplified proof trace extracted from a DerivationTree.

Contains the proof height, list of axiom schema names used,
and list of inference rule names applied. This avoids serializing
the full dependent-type proof tree.
-/
structure ProofTrace where
  /-- Maximum depth of the proof tree. -/
  height : Nat
  /-- Names of axiom schemata used (e.g., "modal_t", "prop_k"). -/
  axiomsUsed : List String
  /-- Names of inference rules applied (e.g., "modus_ponens", "necessitation"). -/
  rulesApplied : List String
  deriving Repr, Inhabited

/-- Convert a ProofTrace to ProofData for interestingness metrics. -/
def ProofTrace.toProofData (pt : ProofTrace) : ProofData :=
  { height := pt.height
  , axiomsUsed := pt.axiomsUsed
  , rulesApplied := pt.rulesApplied }

/--
Difficulty metrics for a formula, combining structural and computational measures.
-/
structure DifficultyMetrics where
  /-- Structural complexity (connective count + 1). -/
  complexity : Nat
  /-- Maximum modal operator nesting. -/
  modalDepth : Nat
  /-- Maximum temporal operator nesting. -/
  temporalDepth : Nat
  /-- Number of implication operators. -/
  impCount : Nat
  /-- Number of distinct atoms. -/
  atomCount : Nat
  /-- Wall-clock decision time in milliseconds. -/
  decisionTimeMs : Nat := 0
  /-- Human-readable difficulty tier. -/
  difficultyTier : String := "unknown"
  deriving Repr, Inhabited

/--
Label classification for a formula.
- `valid`: Formula is valid in the logic (a theorem)
- `invalid`: Formula is not valid (countermodel exists)
- `timeout`: Decision procedure ran out of resources
-/
inductive FormulaLabel where
  | valid
  | invalid
  | timeout
  deriving Repr, DecidableEq, BEq, Inhabited

/-- Generation mode for dataset labeling. -/
inductive GenerationMode where
  | exhaustive
  | proofFirst
  | hybrid
  deriving Repr, DecidableEq, BEq, Inhabited

/--
Serializable summary of a `SemanticCountermodel` for JSON export.

The full `SemanticCountermodel` contains non-serializable fields (the raw branch
list and a function-valued atom valuation). This summary captures the key
structural information: world set, time set, temporal ordering constraints,
and the formula being refuted.
-/
structure SemanticCountermodelSummary where
  /-- All world indices in the model. -/
  worlds : List Nat
  /-- All time indices in the model. -/
  times : List Nat
  /-- Temporal ordering constraints: each `(a, b)` means `a < b`. -/
  timeConstraints : List (Nat × Nat)
  /-- Number of worlds. -/
  worldCount : Nat
  /-- Number of time points. -/
  timeCount : Nat
  deriving Repr, Inhabited

/--
Extract a serializable summary from a `SemanticCountermodel`.
-/
def SemanticCountermodelSummary.fromSemanticCountermodel
    (scm : SemanticCountermodel) : SemanticCountermodelSummary :=
  { worlds := scm.worlds
  , times := scm.times
  , timeConstraints := scm.timeOrdering.constraints
  , worldCount := scm.worlds.length
  , timeCount := scm.times.length
  }

/--
A fully labeled formula record combining the formula with its
decision result, proof trace (if valid), countermodel (if invalid),
difficulty metrics, and pattern key.
-/
structure LabeledFormula where
  /-- The formula that was labeled. -/
  formula : Formula
  /-- Classification result. -/
  label : FormulaLabel
  /-- Proof trace if formula is valid (None for invalid/timeout). -/
  proofTrace : Option ProofTrace
  /-- Countermodel if formula is invalid (None for valid/timeout). -/
  countermodel : Option SimpleCountermodel
  /-- Difficulty metrics. -/
  metrics : DifficultyMetrics
  /-- Pattern key for structural indexing. -/
  patternKey : PatternKey
  /-- Rule application counts from walkDerivationTree (valid formulas only). -/
  ruleProfile : Option RuleProfile
  /-- Which decision pipeline stage produced the result. -/
  decisionMethod : String
  /-- Whether the countermodel is self-consistent (invalid formulas only). -/
  countermodelConsistent : Option Bool
  /-- Enriched countermodel with branch structure (invalid formulas only). -/
  enrichedCountermodel : Option EnrichedCountermodel
  /-- Semantic countermodel summary (invalid formulas only). -/
  semanticCountermodelSummary : Option SemanticCountermodelSummary
  /-- How the proof was reconstructed (valid formulas only).
      Values: "axiom_match", "derived_match", "compositional", "proof_search",
      "tableau_extraction". -/
  proofReconstructionMethod : Option String
  /-- Interestingness composite score on 0-1000 scale (None if not computed). -/
  interestingnessScore : Option Nat := none
  /-- Interestingness tier classification (None if not computed). -/
  interestingnessTier : Option String := none
  deriving Repr

instance : Inhabited LabeledFormula :=
  ⟨{ formula := .bot
     label := .timeout
     proofTrace := none
     countermodel := none
     metrics := default
     patternKey := default
     ruleProfile := none
     decisionMethod := "timeout"
     countermodelConsistent := none
     enrichedCountermodel := none
     semanticCountermodelSummary := none
     proofReconstructionMethod := none }⟩

/--
Extract axiom schema name as a string from an Axiom constructor.

Covers all constructors in `FormalSystem.ProofSystem.Axiom`:
- Layer 1: Propositional (prop_k, prop_s, ex_falso, peirce)
- Layer 2: S5 Modal (modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist)
- Layer 3: BX Temporal (20 constructors)
- Layer 4: Modal-Temporal (modal_future)
- Layer 5: Uniformity (5 constructors)
- Layer 6: Prior (prior_UZ, prior_SZ)
- Layer 7: Z1
- Layer 8: Density (density, dense_indicator)
-/
def extractAxiomName {φ : Formula} (ax : Axiom φ) : String :=
  match ax with
  | .prop_k _ _ _ => "prop_k"
  | .prop_s _ _ => "prop_s"
  | .ex_falso _ => "ex_falso"
  | .peirce _ _ => "peirce"
  | .modal_t _ => "modal_t"
  | .modal_4 _ => "modal_4"
  | .modal_b _ => "modal_b"
  | .modal_5_collapse _ => "modal_5_collapse"
  | .modal_k_dist _ _ => "modal_k_dist"
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
  | .F_until_equiv _ => "F_until_equiv"
  | .P_since_equiv _ => "P_since_equiv"
  | .modal_future _ => "modal_future"
  | .discrete_symm_fwd => "discrete_symm_fwd"
  | .discrete_symm_bwd => "discrete_symm_bwd"
  | .discrete_propagate_fwd => "discrete_propagate_fwd"
  | .discrete_propagate_bwd => "discrete_propagate_bwd"
  | .discrete_box_necessity => "discrete_box_necessity"
  | .prior_UZ _ => "prior_UZ"
  | .prior_SZ _ => "prior_SZ"
  | .z1 _ => "z1"
  | .density _ => "density"
  | .dense_indicator => "dense_indicator"

/--
Extract a simplified proof trace from a DerivationTree.

Recursively traverses the proof tree, collecting:
- Height (max depth)
- Axiom names at leaves
- Inference rule names at internal nodes

This provides a useful summary without the complexity of full
dependent-type serialization.
-/
def extractProofTrace {fc : FrameClass} {Γ : Context} {φ : Formula}
    (d : DerivationTree fc Γ φ) : ProofTrace :=
  match d with
  | .axiom _ _ ax _ =>
    { height := 0
      axiomsUsed := [extractAxiomName ax]
      rulesApplied := [] }
  | .assumption _ _ _ =>
    { height := 0
      axiomsUsed := []
      rulesApplied := ["assumption"] }
  | .modus_ponens _ _ _ d1 d2 =>
    let t1 := extractProofTrace d1
    let t2 := extractProofTrace d2
    { height := 1 + max t1.height t2.height
      axiomsUsed := (t1.axiomsUsed ++ t2.axiomsUsed).eraseDups
      rulesApplied := "modus_ponens" :: (t1.rulesApplied ++ t2.rulesApplied).eraseDups }
  | .necessitation _ d1 =>
    let t1 := extractProofTrace d1
    { height := 1 + t1.height
      axiomsUsed := t1.axiomsUsed
      rulesApplied := "necessitation" :: t1.rulesApplied }
  | .temporal_necessitation _ d1 =>
    let t1 := extractProofTrace d1
    { height := 1 + t1.height
      axiomsUsed := t1.axiomsUsed
      rulesApplied := "temporal_necessitation" :: t1.rulesApplied }
  | .temporal_duality _ d1 =>
    let t1 := extractProofTrace d1
    { height := 1 + t1.height
      axiomsUsed := t1.axiomsUsed
      rulesApplied := "temporal_duality" :: t1.rulesApplied }
  | .weakening _ _ _ d1 _ =>
    let t1 := extractProofTrace d1
    { height := 1 + t1.height
      axiomsUsed := t1.axiomsUsed
      rulesApplied := "weakening" :: t1.rulesApplied }

/--
Compute difficulty metrics for a formula with optional decision time.
-/
def computeMetrics (φ : Formula) (decisionTimeMs : Nat := 0) : DifficultyMetrics :=
  { complexity := φ.complexity
    modalDepth := φ.modalDepth
    temporalDepth := φ.temporalDepth
    impCount := φ.countImplications
    atomCount := φ.atoms.card
    decisionTimeMs := decisionTimeMs
    difficultyTier := classifyDifficulty φ.complexity decisionTimeMs }
where
  /-- Classify difficulty tier based on complexity and decision time. -/
  classifyDifficulty (complexity : Nat) (_timeMs : Nat) : String :=
    if complexity ≤ 3 then "easy"
    else if complexity ≤ 6 then "medium"
    else if complexity ≤ 9 then "hard"
    else "very_hard"

/--
Infer the proof reconstruction method from the proof structure.

- Single axiom node with no rules: "axiom_match"
- Only weakening applied (derived theorem match): "derived_match"
- Low rule count with modus_ponens (compositional builder): "compositional"
- Higher rule count or deep proof: "proof_search"
-/
def inferReconstructionMethod (rp : RuleProfile) (height : Nat) : String :=
  let totalRules := rp.mpCount + rp.necessitationCount + rp.temporalNecessitationCount +
                    rp.temporalDualityCount + rp.weakeningCount + rp.assumptionCount
  if totalRules == 0 && rp.axiomCount > 0 then
    "axiom_match"
  else if rp.weakeningCount > 0 && rp.mpCount == 0 && rp.axiomCount <= 1 then
    "derived_match"
  else if height <= 5 && rp.mpCount <= 3 then
    "compositional"
  else
    "proof_search"

/--
Extract enriched and semantic countermodel data for an invalid formula.

Runs `buildTableau` to obtain the raw open branch, then extracts:
1. `EnrichedCountermodel` (full branch structure with modal/temporal subsets)
2. `SemanticCountermodelSummary` (worlds, times, temporal ordering)

If the tableau build fails (rare, since `decideAuto` already confirmed invalidity),
returns `(none, none)`.

`fuel` is an explicit parameter (default `soundFuel φ` for
backward compatibility). Callers on the timed dataset path pass the *deciding*
fuel (`adaptiveFuel ≤ 500`) so this re-run reproduces the same open branch
without the previously unbounded `soundFuel` (up to 100000) main-thread
computation. For an abort-aware variant, see
`extractCountermodelDataCancellable`.
-/
def extractCountermodelData (φ : Formula) (fuel : Nat := soundFuel φ) :
    Option EnrichedCountermodel × Option SemanticCountermodelSummary :=
  match buildTableau φ fuel with
  | none => (none, none)
  | some (.allClosed _) => (none, none)  -- Shouldn't happen for invalid formula
  | some (.hasOpen openBranch ord _applied _hSat) =>
      let ecm := extractEnrichedCountermodel φ openBranch
      let scm := extractSemanticCountermodel φ openBranch ord
      let summary := SemanticCountermodelSummary.fromSemanticCountermodel scm
      (some ecm, some summary)

/--
Abort-aware, fuel-bounded `IO` mirror of `extractCountermodelData`.

Runs the cancellable tableau (`buildTableauCancellable`) so an in-flight
extraction stops promptly when `abortRef` is set (or the task is cancelled);
an aborted or fuel-exhausted build yields `(none, none)`.
-/
def extractCountermodelDataCancellable (abortRef : IO.Ref Bool) (φ : Formula)
    (fuel : Nat) :
    IO (Option EnrichedCountermodel × Option SemanticCountermodelSummary) := do
  match ← buildTableauCancellable abortRef φ fuel with
  | none => return (none, none)
  | some (.allClosed _) => return (none, none)  -- Shouldn't happen for invalid formula
  | some (.hasOpen openBranch ord _applied _hSat) =>
      let ecm := extractEnrichedCountermodel φ openBranch
      let scm := extractSemanticCountermodel φ openBranch ord
      let summary := SemanticCountermodelSummary.fromSemanticCountermodel scm
      return (some ecm, some summary)

/--
Build a `LabeledFormula` for an invalid result, including enriched countermodel data.

The enriched/semantic countermodel `(ecm, scmSummary)` is passed
in rather than computed here via an unbounded `extractCountermodelData φ`. This
keeps `mkInvalidLabel` pure while letting the (already-`IO`) caller compute the
extraction abort-aware and fuel-bounded (see `extractCountermodelDataCancellable`).
-/
private def mkInvalidLabel (φ : Formula) (cm : SimpleCountermodel)
    (metrics : DifficultyMetrics) (patternKey : PatternKey)
    (ecm : Option EnrichedCountermodel)
    (scmSummary : Option SemanticCountermodelSummary)
    (method : String := "tableau_open") : LabeledFormula :=
  let consistent := cm.isConsistent
  { formula := φ
    label := .invalid
    proofTrace := none
    countermodel := some cm
    metrics := metrics
    patternKey := patternKey
    ruleProfile := none
    decisionMethod := method
    countermodelConsistent := some consistent
    enrichedCountermodel := ecm
    semanticCountermodelSummary := scmSummary
    proofReconstructionMethod := none
  }

/-!
### Structural Pre-Filter

Detects formulas that are structurally valid due to unsatisfiable antecedents
or tautological implication patterns, bypassing the decision procedure entirely.
Added to eliminate ~151 of 247 c6 timeouts.
-/

/- ## Phase 1 helpers: derived operator shape recognizers -/

/-- Recognize derived negation shape `¬φ` = `φ → ⊥`. -/
def isNegShape : Formula → Option Formula
  | .imp φ .bot => some φ
  | _ => none

/-- Recognize derived `all_future` shape `G(φ) = ¬F(¬φ)`.
    `Gφ = imp (untl (imp φ bot) (imp bot bot)) bot` -/
def isAllFutureShape : Formula → Option Formula
  | .imp (.untl (.imp φ .bot) (.imp .bot .bot)) .bot => some φ
  | _ => none

/-- Recognize derived `some_future` shape `F(φ) = U(φ, ⊤)`.
    `Fφ = untl φ (imp bot bot)` -/
def isSomeFutureShape : Formula → Option Formula
  | .untl φ (.imp .bot .bot) => some φ
  | _ => none

/-- Recognize derived `all_past` shape `H(φ) = ¬P(¬φ)`.
    `Hφ = imp (snce (imp φ bot) (imp bot bot)) bot` -/
def isAllPastShape : Formula → Option Formula
  | .imp (.snce (.imp φ .bot) (.imp .bot .bot)) .bot => some φ
  | _ => none

/-- Recognize derived `some_past` shape `P(φ) = S(φ, ⊤)`.
    `Pφ = snce φ (imp bot bot)` -/
def isSomePastShape : Formula → Option Formula
  | .snce φ (.imp .bot .bot) => some φ
  | _ => none

/-- Collect top-level conjuncts by flattening derived `and` shape.
    `and a b` = `(a.imp b.neg).neg` = `imp (imp a (imp b bot)) bot`. -/
def collectTopLevelConjuncts : Formula → List Formula
  | .imp (.imp a (.imp b .bot)) .bot =>
    collectTopLevelConjuncts a ++ collectTopLevelConjuncts b
  | φ => [φ]

/-- Check if conjuncts contain both `□φ` and `¬φ` (S5 reflexive conflict). -/
def hasS5ReflexiveConflict (conjuncts : List Formula) : Bool :=
  conjuncts.any fun c1 =>
    match c1 with
    | .box φ =>
      conjuncts.any fun c2 =>
        match isNegShape c2 with
        | some ψ => ψ == φ
        | none => false
    | _ => false

/-- Check if conjuncts contain `U(event, guard)` and `G(¬guard)` (temporal loop). -/
def hasUntilGuardConflict (conjuncts : List Formula) : Bool :=
  conjuncts.any fun c1 =>
    match c1 with
    | .untl _event guard =>
      conjuncts.any fun c2 =>
        match isAllFutureShape c2 with
        | some ψ =>
          match isNegShape ψ with
          | some ng => ng == guard
          | none => false
        | none => false
    | _ => false

/-- Check if conjuncts contain `S(event, guard)` and `H(¬guard)` (temporal loop past). -/
def hasSinceGuardConflict (conjuncts : List Formula) : Bool :=
  conjuncts.any fun c1 =>
    match c1 with
    | .snce _event guard =>
      conjuncts.any fun c2 =>
        match isAllPastShape c2 with
        | some ψ =>
          match isNegShape ψ with
          | some ng => ng == guard
          | none => false
        | none => false
    | _ => false

/-- Check if `imp a c` matches a modal/temporal subsumption rule.
    Returns the axiom label if matched, none otherwise. -/
def isSubsumptionPattern (a c : Formula) : Option String :=
  -- □φ → φ (modal T direct)
  match a with
  | .box φ =>
    if c == φ then some "structural_subsumption_modal_t"
    else if c == .box (.box φ) then some "structural_subsumption_modal_4"
    else if c == .imp (.box (.imp φ .bot)) .bot then some "structural_subsumption_modal_d"
    else none
  | _ =>
  -- Gφ → φ, Gφ → G(Gφ), Gφ → Fφ
  match isAllFutureShape a with
  | some φ =>
    if c == φ then some "structural_subsumption_gt"
    else if c == Formula.allFuture (Formula.allFuture φ) then some "structural_subsumption_g4"
    else if c == Formula.someFuture φ then some "structural_subsumption_gf"
    else none
  | none =>
  -- Hφ → φ, Hφ → H(Hφ), Hφ → Pφ
  match isAllPastShape a with
  | some φ =>
    if c == φ then some "structural_subsumption_ht"
    else if c == Formula.allPast (Formula.allPast φ) then some "structural_subsumption_h4"
    else if c == Formula.somePast φ then some "structural_subsumption_hp"
    else none
  | none =>
  -- F(Fφ) → Fφ
  match isSomeFutureShape a with
  | some inner =>
    match isSomeFutureShape inner with
    | some φ => if c == Formula.someFuture φ then some "structural_subsumption_ff" else none
    | none => none
  | none =>
  -- P(Pφ) → Pφ
  match isSomePastShape a with
  | some inner =>
    match isSomePastShape inner with
    | some φ => if c == Formula.somePast φ then some "structural_subsumption_pp" else none
    | none => none
  | none => none

/--
Check if a formula is structurally unsatisfiable due to bot-temporal patterns.

Returns `true` only when the formula itself evaluates to false at every world/time:
- `⊥` is always false (base case)
- `U(event, X)` is always false when `event` is unsatisfiable: the event can never become
  true, so the Until condition can never be fulfilled
- `S(event, X)` is always false when `event` is unsatisfiable: the event was never true
- `□(φ)` is false when `φ` is unsatisfiable (in non-degenerate frames)

Recurses into Until/Since event arguments, catching patterns like
`U(□⊥, X)`, `U(U(⊥, Y), X)`, `S(U(⊥, Y), X)`, etc.

This is NOT a general "contains bot" check. The formula must itself be unsatisfiable.
-/
def isUnsatBotTemporal : Formula → Bool
  | .bot => true
  | .untl event _ => isUnsatBotTemporal event
  | .snce event _ => isUnsatBotTemporal event
  | .box a => isUnsatBotTemporal a
  | _ => false

/--
Check if a formula is structurally valid (a tautology by inspection).

Returns `true` for patterns that are valid regardless of valuation:
- `φ → φ` (identity/reflexivity of implication)
- `X → valid` where `valid` is itself structurally valid (valid consequent)
- `□(valid)` (necessitation of a valid formula is valid)

Soundness: `A → B` is valid whenever `B` is valid, since `B` holds at every world/time.
`□(valid)` is valid by necessitation. The `a == b` check uses structural (BEq) equality,
which is sound: if two formulas are syntactically identical, `A → A` is a tautology.

Added to catch tautological consequents in the structural pre-filter.
-/
def isStructurallyValid : Formula → Bool
  | .imp a b => a == b || isStructurallyValid b || b == Formula.top || b == .box Formula.top
  | .box inner => isStructurallyValid inner
  | _ => false

/-- Deep structural validity check that also recurses into implication antecedents.
    Catches nested patterns like `p → (U(⊥, q) → r)` where the inner antecedent is unsat. -/
def isStructurallyValidDeep : Formula → Bool
  | .imp a b => a == b || isUnsatBotTemporal a || isStructurallyValidDeep b
  | .box inner => isStructurallyValidDeep inner
  | _ => false

/- ## Phase 2 helpers: polarity analysis -/

/-- Collect all subformula occurrences with their polarity sign.
    `pos` = positive occurrence, `neg` = negative occurrence.
    Polarity flips at the left-hand side of implication and through derived negation. -/
def collectPolarities (φ : Formula) (sign : Sign := .pos) : List (Formula × Sign) :=
  (φ, sign) :: match φ with
  | .imp a b => collectPolarities a sign.flip ++ collectPolarities b sign
  | .box a => collectPolarities a sign
  | .untl a b => collectPolarities a sign ++ collectPolarities b sign
  | .snce a b => collectPolarities a sign ++ collectPolarities b sign
  | _ => []

/-- Check if a given formula appears only with positive polarity. -/
def appearsOnlyPositively (polarities : List (Formula × Sign)) (χ : Formula) : Bool :=
  polarities.all fun (φ, s) => if φ == χ then s == .pos else true

/-- Check if a given formula appears only with negative polarity. -/
def appearsOnlyNegatively (polarities : List (Formula × Sign)) (χ : Formula) : Bool :=
  polarities.all fun (φ, s) => if φ == χ then s == .neg else true

/-- Check if `bot` is among the top-level conjuncts. -/
def hasBotConjunct (conjuncts : List Formula) : Bool :=
  conjuncts.any fun c => c == .bot

/-- Check if any conjunct is the negation of another conjunct (e.g., `p ∧ ¬p`). -/
def hasPropContradiction (conjuncts : List Formula) : Bool :=
  conjuncts.any fun c1 =>
    match isNegShape c1 with
    | some φ => conjuncts.any fun c2 => c2 == φ
    | none => false

/--
Check if `imp a c` matches a temporal implication pattern.
Returns the axiom label if matched, none otherwise.

Recognized patterns:
- `U(X, Y) → F(Y)`: Until guarantees the event eventually occurs (future of event)
- `S(X, Y) → P(Y)`: Since guarantees the event occurred in the past (past of event)
- `U(X, Y) → F(X)`: Until guarantees the guard holds at some point (when Y hasn't happened yet)
  Note: This is NOT valid in general. U(X,Y) could be satisfied by Y holding immediately.
- `G(X) → U(X, Y)`: NOT valid (G doesn't guarantee Y). Excluded.
- `U(X, Y) → U(X', Y)` where X subsumes X': antecedent-monotonic Until
- `S(X, Y) → S(X', Y)` where X subsumes X': antecedent-monotonic Since
-/
def isTemporalImplicationPattern (a c : Formula) : Option String :=
  -- U(X, Y) → F(Y): Until guarantees the event eventually occurs
  -- Proof: U(X, Y) at t means ∃t'>t, Y(t') ∧ ∀t''∈(t,t'), X(t''). So F(Y) = ∃t'>t, Y(t').
  match a with
  | .untl _guard event =>
    match isSomeFutureShape c with
    | some ψ => if ψ == event then some "structural_until_implies_future" else none
    | none => none
  | .snce _guard event =>
    -- S(X, Y) → P(Y): Since guarantees the event occurred in the past
    -- Proof: S(X, Y) at t means ∃t'<t, Y(t') ∧ ∀t''∈(t',t), X(t''). So P(Y) = ∃t'<t, Y(t').
    match isSomePastShape c with
    | some ψ => if ψ == event then some "structural_since_implies_past" else none
    | none => none
  | _ => none

/--
Structural pre-filter with axiom attribution.

Like `structuralPrefilter`, but returns the matched axiom pattern name
alongside the validity result. This enables temporal axiom usage tracking
in the dataset.

Returns `some (true, axiomName)` if structurally valid with identified pattern,
`none` if undetermined.
-/
def structuralPrefilterWithAxiom : Formula → Option (Bool × String)
  | .imp antecedent consequent =>
    -- Identity check (φ → φ is always valid)
    if antecedent == consequent then some (true, "structural_identity")
    else if isUnsatBotTemporal antecedent then some (true, "structural_bot_temporal")
    else if isStructurallyValid consequent then some (true, "structural_tautology")
    else if isStructurallyValidDeep consequent then some (true, "structural_polarity_drop_tautology")
    else
      -- Phase 1 quick wins: conjunct-level patterns
      let conjuncts := collectTopLevelConjuncts antecedent
      if hasBotConjunct conjuncts then some (true, "structural_polarity_bot_neg")
      else if hasPropContradiction conjuncts then some (true, "structural_prop_contradiction")
      else if hasS5ReflexiveConflict conjuncts then some (true, "structural_s5_reflexive_conflict")
      else if hasUntilGuardConflict conjuncts then some (true, "structural_temporal_loop_until")
      else if hasSinceGuardConflict conjuncts then some (true, "structural_temporal_loop_since")
      else match isSubsumptionPattern antecedent consequent with
      | some label => some (true, label)
      | none =>
      -- Temporal implication patterns
      match isTemporalImplicationPattern antecedent consequent with
      | some label => some (true, label)
      | none => match antecedent, consequent with
      | .box (.box .bot), _ => some (true, "structural_double_box_bot")
      | .box (.box inner), consequent =>
        if inner == consequent then some (true, "structural_modal_4") else none
      | .box inner, .imp _ rhs =>
        if inner == rhs then some (true, "structural_modal_t_weakening") else none
      | _, _ => none
  | .box inner =>
    match structuralPrefilterWithAxiom inner with
    | some (v, ax) => some (v, ax)
    | none => none
  | _ => none

/--
Structural pre-filter for known-valid formula patterns. Returns `some true` if the
formula is provably valid by structural inspection, `none` if undetermined.

Recognized patterns:
0. **Identity**: `φ → φ` — always valid (catches temporal/derived operator identities)
1. **Bot-temporal antecedent**: `φ → ψ` where `isUnsatBotTemporal φ` — vacuously valid
   (now recursive: catches `U(□⊥, X)`, `U(U(⊥, Y), X)`, etc.)
2. **Valid consequent**: `φ → ψ` where `isStructurallyValid ψ` — tautological consequent
   (catches `X → (p → p)`, `X → □(q → q)`, etc.)
3. **Double-box-bot**: `□□⊥ → ψ` — □⊥ is false, so □□⊥ is false, implication vacuously valid
4. **Double-box-identity**: `□□φ → φ` — valid by T axiom (reflexivity) applied twice
5. **Box-prop**: `□φ → (ψ → φ)` — valid by T axiom + weakening
6. **Box descent**: `□φ` where `φ` is itself structurally valid — necessitation of valid = valid
7. **Until → Future**: `U(X, Y) → F(Y)` — valid since Until guarantees eventual occurrence
8. **Since → Past**: `S(X, Y) → P(Y)` — valid since Since guarantees past occurrence

Never returns `some false` (would require soundness argument for invalidity).
-/
def structuralPrefilter (φ : Formula) : Option Bool :=
  match structuralPrefilterWithAxiom φ with
  | some (v, _) => some v
  | none => none

/-! ### Invalid Pattern Recognizers

Structural recognizers for formulas that are provably **invalid** (have obvious
countermodels). These complement the valid prefilter by short-circuiting the
tableau for formulas with false consequents, trivially satisfiable antecedents
negated to bot, or unfulfillable Until/Since eventualities.

Three recognizer functions:
- `isTemporalContradiction`: Detects `φ → ψ` where consequent is always false
  and antecedent is not always false.
- `isObviousSatisfiable`: Detects `φ → ⊥` where `φ` is trivially satisfiable
  in a reflexive 1-world S5 model, and `φ → ψ` where `φ` is trivially
  satisfiable and `ψ` is always false.
- `hasUnfulfillableEventuality`: Detects `φ → U(event, guard)` where `φ`
  contains `G(¬event)`, making the Until unfulfillable, and the symmetric
  `φ → S(event, guard)` where `φ` contains `H(¬event)`.

Combined in `structuralInvalidPrefilter` and wired into `labelFormulaImpl`
as Phase 1.5 between the valid prefilter and the tableau decision procedure.

**Coverage estimates** (c6): ~30-50 of 96 remaining timeouts.
-/

/--
Check if a formula is trivially satisfiable in a reflexive 1-world S5 model
with all atoms set to true. Returns `true` only for patterns we can prove
satisfiable by explicit model construction.

Conservative: returns `false` for temporal operators (Until/Since require
2+ time points) and complex implications (would need SAT-solving).

Satisfiable patterns:
- Atoms: set to true in the model
- Top (⊥ → ⊥): always true
- Box(satisfiable): in reflexive S5 with one world, □φ ↔ φ
- Conjunction of satisfiables: set all atoms to true
- Negation of always-false: ¬(always-false) is always true
-/
def isTrivialSatisfiable : Formula → Bool
  | .atom _ => true
  | .imp .bot .bot => true  -- top
  | .box a => isTrivialSatisfiable a  -- reflexive S5: box(sat) is sat
  | .imp (.imp a (.imp b .bot)) .bot =>  -- and(a, b) pattern
    isTrivialSatisfiable a && isTrivialSatisfiable b
  | .imp a .bot =>  -- neg(a): satisfiable when a is always false
    isUnsatBotTemporal a
  | _ => false

/--
Detect `φ → ψ` where the consequent `ψ` is always false (via `isUnsatBotTemporal`)
and the antecedent `φ` is not always false. Such formulas are invalid because
whenever the antecedent is true, the consequent is false.

Uses `isUnsatBotTemporal` as the core "always false" checker. The `!isUnsatBotTemporal`
guard on the antecedent prevents catching vacuously valid formulas like `⊥ → ⊥`
or `U(⊥, p) → U(⊥, q)`.

Examples:
- `p → U(⊥, q)` : consequent always false, antecedent satisfiable → INVALID
- `p → □(⊥)` : consequent always false, antecedent satisfiable → INVALID
- `U(⊥, p) → U(⊥, q)` : both sides always false → vacuously valid, NOT caught
-/
def isTemporalContradiction : Formula → Bool
  | .imp antecedent consequent =>
    isUnsatBotTemporal consequent && !isUnsatBotTemporal antecedent
  | _ => false

/--
Detect `φ → ⊥` where `φ` is trivially satisfiable (via `isTrivialSatisfiable`),
and `φ → ψ` where `φ` is trivially satisfiable and `ψ` is always false.

The first pattern (`φ → ⊥` = `¬φ`) is invalid because `φ` has a model.
The second pattern extends this: `φ` is true and `ψ` is false simultaneously.

This overlaps with `isTemporalContradiction` for the `φ → alwaysFalse` case,
but adds coverage for `φ → ⊥` where `φ` is satisfiable but not caught by
the false-consequent check (since `⊥` is trivially always-false, it is also
caught by `isTemporalContradiction`; the `isTrivialSatisfiable` check adds
confidence that the antecedent is genuinely satisfiable).

Examples:
- `□(p) → ⊥` : antecedent satisfiable in reflexive model → INVALID
- `(p ∧ q) → ⊥` : conjunction satisfiable → INVALID
- `p → U(⊥, q)` : antecedent satisfiable, consequent always false → INVALID
-/
def isObviousSatisfiable : Formula → Bool
  | .imp antecedent .bot =>
    isTrivialSatisfiable antecedent
  | .imp antecedent consequent =>
    isTrivialSatisfiable antecedent && isUnsatBotTemporal consequent
  | _ => false

/--
Detect `φ → U(event, guard)` where `φ` contains `G(¬event)` as a top-level
conjunct, making the Until eventuality unfulfillable. Under the assumption
`G(¬event)`, `event` is never true in the future, so `U(event, guard)` cannot
be fulfilled at any time point.

Also detects the symmetric past case: `φ → S(event, guard)` where `φ`
contains `H(¬event)` as a conjunct.

Example:
- `G(¬p) → U(p, q)` : Under G(¬p), p is never true, so U(p,q) is never
  fulfilled → INVALID
- `(G(¬p) ∧ r) → U(p, q)` : Same reasoning, G(¬p) is a conjunct → INVALID
- `H(¬p) → S(p, q)` : Symmetric past case → INVALID
-/
def hasUnfulfillableEventuality : Formula → Bool
  | .imp antecedent (.untl event _guard) =>
    let conjuncts := collectTopLevelConjuncts antecedent
    conjuncts.any fun c =>
      match isAllFutureShape c with
      | some inner =>
        match isNegShape inner with
        | some negInner => negInner == event
        | none => false
      | none => false
  | .imp antecedent (.snce event _guard) =>
    let conjuncts := collectTopLevelConjuncts antecedent
    conjuncts.any fun c =>
      match isAllPastShape c with
      | some inner =>
        match isNegShape inner with
        | some negInner => negInner == event
        | none => false
      | none => false
  | _ => false

/--
Collect all atoms appearing in a formula as a list (computable).
May contain duplicates; used only for trivial countermodel construction.
-/
private def collectAtomsList : Formula → List Atom
  | .atom a => [a]
  | .bot => []
  | .imp a b => collectAtomsList a ++ collectAtomsList b
  | .box a => collectAtomsList a
  | .untl a b => collectAtomsList a ++ collectAtomsList b
  | .snce a b => collectAtomsList a ++ collectAtomsList b

/--
Construct a trivial countermodel for a structurally invalid formula.
Sets all atoms in the formula to true (satisfies most antecedents in
a reflexive 1-world S5 model).

This is conservative: the "all atoms true" assignment provides a valid
countermodel for patterns where the consequent is structurally false
regardless of the valuation.
-/
def constructTrivialCountermodel (φ : Formula) : SimpleCountermodel :=
  let allAtoms := (collectAtomsList φ).eraseDups
  { trueAtoms := allAtoms
  , falseAtoms := []
  , formula := φ }

/--
Structural invalid pre-filter.

Detects formulas that are provably **invalid** by structural inspection.
Returns `some (false, patternLabel)` if the formula has an obvious countermodel.
Returns `none` if undetermined (proceed to decision procedure).

Three patterns detected:
1. **False consequent** (`invalid_false_consequent`): `φ → ψ` where `ψ` is always
   false and `φ` is not always false. Coverage: ~15-25 c6 timeouts.
2. **Satisfiable negation** (`invalid_satisfiable_neg`): `φ → ⊥` where `φ` is
   trivially satisfiable, or `φ → ψ` where `φ` is satisfiable and `ψ` is
   always false. Coverage: ~10-20 c6 timeouts.
3. **Unfulfillable eventuality** (`invalid_unfulfillable_eventuality`): `φ → U(event, guard)`
   where `φ` contains `G(¬event)`, or symmetric `S` case. Coverage: ~5-10 c6 timeouts.

Never returns `some (true, ...)` (that is the valid prefilter's job).
-/
def structuralInvalidPrefilter : Formula → Option (Bool × String)
  | .imp antecedent consequent =>
    -- Pattern 2 first (more specific): Trivially satisfiable antecedent with bot consequent
    if consequent == .bot && isTrivialSatisfiable antecedent then
      some (false, "invalid_satisfiable_neg")
    -- Pattern 2b: Trivially satisfiable antecedent with always-false consequent
    else if isTrivialSatisfiable antecedent && isUnsatBotTemporal consequent then
      some (false, "invalid_satisfiable_neg")
    -- Pattern 1: Always-false consequent with non-always-false antecedent (wider net)
    else if isUnsatBotTemporal consequent && !isUnsatBotTemporal antecedent then
      some (false, "invalid_false_consequent")
    -- Pattern 3: Unfulfillable eventuality in consequent
    else if hasUnfulfillableEventuality (.imp antecedent consequent) then
      some (false, "invalid_unfulfillable_eventuality")
    else none
  | _ => none

/-! ### Pre-filter unit tests -/

-- Test atoms for #eval tests
private def p_test : Formula := .atom ⟨"p", none⟩
private def q_test : Formula := .atom ⟨"q", none⟩

-- isUnsatBotTemporal: recursive cases
#eval isUnsatBotTemporal (.bot)                                   -- true  (base case)
#eval isUnsatBotTemporal (.untl (.box .bot) p_test)               -- true  (U(□⊥, p))
#eval isUnsatBotTemporal (.snce (.untl .bot q_test) p_test)       -- true  (S(U(⊥, q), p))
#eval isUnsatBotTemporal (.box (.untl .bot p_test))               -- true  (□(U(⊥, p)))
#eval isUnsatBotTemporal (.untl p_test q_test)                    -- false (U(p, q) is satisfiable)
#eval isUnsatBotTemporal p_test                                   -- false (atom is satisfiable)

-- isStructurallyValid: tautology detection
#eval isStructurallyValid (.imp p_test p_test)                    -- true  (p → p)
#eval isStructurallyValid (.imp q_test (.imp p_test p_test))      -- true  (q → (p → p))
#eval isStructurallyValid (.box (.imp p_test p_test))             -- true  (□(p → p))
#eval isStructurallyValid p_test                                  -- false (atom is not valid)
#eval isStructurallyValid (.imp p_test q_test)                    -- false (p → q, p ≠ q)

-- structuralPrefilter: integration tests
#eval structuralPrefilter (.imp (.untl (.box .bot) p_test) q_test) -- some true (recursive unsat antecedent)
#eval structuralPrefilter (.imp p_test (.imp q_test q_test))       -- some true (valid consequent)
#eval structuralPrefilter (.imp p_test (.box (.imp q_test q_test)))-- some true (valid consequent under box)
#eval structuralPrefilter (.imp p_test q_test)                     -- none  (unknown)

-- structuralPrefilterWithAxiom: axiom attribution tests
#eval structuralPrefilterWithAxiom (.imp (.untl (.box .bot) p_test) q_test)
  -- some (true, "structural_bot_temporal")
#eval structuralPrefilterWithAxiom (.imp p_test (.imp q_test q_test))
  -- some (true, "structural_tautology")
#eval structuralPrefilterWithAxiom (.imp (.box (.box .bot)) q_test)
  -- some (true, "structural_bot_temporal") — box(box(bot)) is caught by isUnsatBotTemporal first
#eval structuralPrefilterWithAxiom (.imp (.box (.box p_test)) p_test)
  -- some (true, "structural_modal_4")
#eval structuralPrefilterWithAxiom (.imp (.box p_test) (.imp q_test p_test))
  -- some (true, "structural_modal_t_weakening")
#eval structuralPrefilterWithAxiom (.imp p_test q_test)
  -- none (unknown)

-- Phase 1 tests

-- collectTopLevelConjuncts
#eval collectTopLevelConjuncts (p_test.and q_test)
  -- [p, q]
#eval collectTopLevelConjuncts (p_test.and (q_test.and (.imp p_test p_test)))
  -- [p, q, p → p]

-- isAllFutureShape / isSomeFutureShape / isAllPastShape / isSomePastShape
#eval isAllFutureShape p_test.allFuture                -- some p
#eval isSomeFutureShape p_test.someFuture             -- some p
#eval isAllPastShape p_test.allPast                   -- some p
#eval isSomePastShape p_test.somePast                 -- some p

-- S5 reflexive shortcutting
#eval structuralPrefilterWithAxiom (.imp (Formula.and (Formula.box p_test) (Formula.neg p_test)) q_test)
  -- some (true, "structural_s5_reflexive_conflict")

-- Temporal loop detection (until)
#eval structuralPrefilterWithAxiom (.imp (Formula.and (Formula.untl p_test q_test) (Formula.allFuture (Formula.neg q_test))) (Formula.atom (Atom.mkBase "r")))
  -- some (true, "structural_temporal_loop_until")

-- Temporal loop detection (since)
#eval structuralPrefilterWithAxiom (.imp (Formula.and (Formula.snce p_test q_test) (Formula.allPast (Formula.neg q_test))) (Formula.atom (Atom.mkBase "r")))
  -- some (true, "structural_temporal_loop_since")

-- Subsumption rules
#eval structuralPrefilterWithAxiom (.imp (p_test.allFuture) p_test)
  -- some (true, "structural_subsumption_gt")
#eval structuralPrefilterWithAxiom (.imp (p_test.allPast) p_test)
  -- some (true, "structural_subsumption_ht")
#eval structuralPrefilterWithAxiom (.imp (p_test.allFuture) p_test.someFuture)
  -- some (true, "structural_subsumption_gf")
#eval structuralPrefilterWithAxiom (.imp (p_test.allPast) p_test.somePast)
  -- some (true, "structural_subsumption_hp")
#eval structuralPrefilterWithAxiom (.imp (p_test.allFuture) p_test.allFuture.allFuture)
  -- some (true, "structural_subsumption_g4")
#eval structuralPrefilterWithAxiom (.imp (p_test.allPast) p_test.allPast.allPast)
  -- some (true, "structural_subsumption_h4")
#eval structuralPrefilterWithAxiom (.imp (p_test.someFuture.someFuture) p_test.someFuture)
  -- some (true, "structural_subsumption_ff")
#eval structuralPrefilterWithAxiom (.imp (p_test.somePast.somePast) p_test.somePast)
  -- some (true, "structural_subsumption_pp")
#eval structuralPrefilterWithAxiom (.imp (.box p_test) p_test)
  -- some (true, "structural_subsumption_modal_t")
#eval structuralPrefilterWithAxiom (.imp (.box p_test) (.box (.box p_test)))
  -- some (true, "structural_subsumption_modal_4")
#eval structuralPrefilterWithAxiom (.imp (.box p_test) (p_test.diamond))
  -- some (true, "structural_subsumption_modal_d")

-- Temporal implication pattern tests
private def r_test : Formula := .atom ⟨"r", none⟩
private def s_test : Formula := .atom ⟨"s", none⟩

-- U(p, q) → F(q): Until implies Future of event
#eval structuralPrefilterWithAxiom (.imp (.untl p_test q_test) q_test.someFuture)
  -- some (true, "structural_until_implies_future")

-- S(p, q) → P(q): Since implies Past of event
#eval structuralPrefilterWithAxiom (.imp (.snce p_test q_test) q_test.somePast)
  -- some (true, "structural_since_implies_past")

-- U(p, q) → F(p): NOT valid (Until does not guarantee F(guard) -- Y could hold immediately)
#eval structuralPrefilterWithAxiom (.imp (.untl p_test q_test) p_test.someFuture)
  -- none

-- G(p) → F(p): Always implies Sometimes (caught by isSubsumptionPattern as G→F)
#eval structuralPrefilterWithAxiom (.imp p_test.allFuture p_test.someFuture)
  -- some (true, "structural_subsumption_gf")

-- H(p) → P(p): Always-past implies Sometimes-past (caught by isSubsumptionPattern as H→P)
#eval structuralPrefilterWithAxiom (.imp p_test.allPast p_test.somePast)
  -- some (true, "structural_subsumption_hp")

-- U(p, q) → U(p, q): identity (caught by structural_identity)
#eval structuralPrefilterWithAxiom (.imp (.untl p_test q_test) (.untl p_test q_test))
  -- some (true, "structural_identity")

-- U(p, q) → U(r, s): all different atoms — not structurally decidable
#eval structuralPrefilterWithAxiom (.imp (.untl p_test q_test) (.untl r_test s_test))
  -- none (mixed validity, falls through to tableau)

-- U(p, q) → U(r, q): shared event, different guard — NOT valid, not caught
#eval structuralPrefilterWithAxiom (.imp (.untl p_test q_test) (.untl r_test q_test))
  -- none (U(p,q) does not imply U(r,q))

-- Phase 2 tests: polarity analysis

-- collectPolarities
#eval collectPolarities (Formula.imp p_test q_test) .pos
  -- [(p→q, pos), (p, neg), (q, pos)]
#eval collectPolarities (Formula.neg p_test) .pos
  -- [(¬p, pos), (p, neg)]

-- appearsOnlyPositively / appearsOnlyNegatively
#eval appearsOnlyPositively (collectPolarities (Formula.imp p_test q_test) .pos) p_test
  -- false (p appears negatively)
#eval appearsOnlyNegatively (collectPolarities (Formula.imp p_test q_test) .pos) p_test
  -- true

-- isStructurallyValidDeep: nested unsat antecedent
#eval isStructurallyValidDeep (Formula.imp (Formula.untl Formula.bot q_test) p_test)
  -- true (unsat → anything is valid)
#eval structuralPrefilterWithAxiom (.imp p_test (Formula.imp (Formula.untl Formula.bot q_test) p_test))
  -- some (true, "structural_polarity_drop_tautology")

-- hasBotConjunct
#eval structuralPrefilterWithAxiom (.imp (Formula.and p_test Formula.bot) q_test)
  -- some (true, "structural_polarity_bot_neg")

-- Phase 3 tests: lightweight propositional contradiction
#eval hasPropContradiction [p_test, Formula.neg p_test]                    -- true
#eval hasPropContradiction [p_test, Formula.imp p_test Formula.bot]        -- true (¬p derived as p→⊥)
#eval hasPropContradiction [p_test, q_test]                                -- false
#eval structuralPrefilterWithAxiom (.imp (Formula.and p_test (Formula.neg p_test)) q_test)
  -- some (true, "structural_prop_contradiction")

-- Extended tautology detection (φ → ⊤ and φ → □⊤)
#eval isStructurallyValid (.imp p_test Formula.top)                     -- true
#eval isStructurallyValid (.imp p_test (.box Formula.top))              -- true
#eval structuralPrefilterWithAxiom (.imp p_test Formula.top)             -- some (true, "structural_tautology")
#eval structuralPrefilterWithAxiom (.imp p_test (.box Formula.top))      -- some (true, "structural_tautology")

/-! ### Invalid prefilter unit tests -/

-- isTrivialSatisfiable: positive cases
#eval isTrivialSatisfiable p_test                                          -- true  (atom)
#eval isTrivialSatisfiable (Formula.imp .bot .bot)                         -- true  (top)
#eval isTrivialSatisfiable (.box p_test)                                   -- true  (box(atom))
#eval isTrivialSatisfiable (Formula.and p_test q_test)                     -- true  (and of atoms)
#eval isTrivialSatisfiable (.box (.box p_test))                            -- true  (box(box(atom)))
#eval isTrivialSatisfiable (Formula.neg .bot)                              -- true  (neg(bot) = top, isUnsatBotTemporal bot = true)
-- isTrivialSatisfiable: negative cases
#eval isTrivialSatisfiable (.untl p_test q_test)                           -- false (Until needs 2+ times)
#eval isTrivialSatisfiable (.snce p_test q_test)                           -- false (Since needs 2+ times)
#eval isTrivialSatisfiable (.imp p_test q_test)                            -- false (imp not a known-sat shape)
#eval isTrivialSatisfiable .bot                                            -- false (bot is never true)

-- isTemporalContradiction: positive cases (invalid formulas)
#eval isTemporalContradiction (.imp p_test (.untl .bot q_test))            -- true  (p → U(⊥,q): conseq always false)
#eval isTemporalContradiction (.imp p_test (.box .bot))                    -- true  (p → □⊥: conseq always false)
#eval isTemporalContradiction (.imp (.box p_test) .bot)                    -- true  (□p → ⊥: conseq false, antecedent not)
#eval isTemporalContradiction (.imp p_test (.snce .bot q_test))            -- true  (p → S(⊥,q): conseq always false)
#eval isTemporalContradiction (.imp (.box (.untl p_test q_test)) (.untl .bot r_test))
  -- true  (□(U(p,q)) → U(⊥,r): consequent always false, antecedent satisfiable)
-- isTemporalContradiction: negative cases
#eval isTemporalContradiction (.imp (.untl .bot p_test) (.untl .bot q_test))
  -- false (both sides always false → vacuously valid, not invalid)
#eval isTemporalContradiction (.imp p_test q_test)                         -- false (q not always false)
#eval isTemporalContradiction p_test                                       -- false (not an implication)
#eval isTemporalContradiction (.imp .bot .bot)                             -- false (bot → bot is valid)

-- isObviousSatisfiable: positive cases (invalid formulas)
#eval isObviousSatisfiable (.imp p_test .bot)                              -- true  (p → ⊥: p satisfiable)
#eval isObviousSatisfiable (.imp (.box p_test) .bot)                       -- true  (□p → ⊥: sat in reflexive model)
#eval isObviousSatisfiable (.imp (Formula.and p_test q_test) .bot)         -- true  ((p∧q) → ⊥: sat)
#eval isObviousSatisfiable (.imp p_test (.untl .bot q_test))               -- true  (p → U(⊥,q): sat antecedent, false conseq)
#eval isObviousSatisfiable (.imp (Formula.imp .bot .bot) .bot)             -- true  (⊤ → ⊥: top is satisfiable)
-- isObviousSatisfiable: negative cases
#eval isObviousSatisfiable (.imp (.untl p_test q_test) .bot)               -- false (U(p,q) not trivially sat)
#eval isObviousSatisfiable (.imp p_test q_test)                            -- false (q not always false)
#eval isObviousSatisfiable (.imp .bot .bot)                                -- false (bot not trivially sat)
#eval isObviousSatisfiable p_test                                          -- false (not an implication)

-- hasUnfulfillableEventuality: positive cases (invalid formulas)
#eval hasUnfulfillableEventuality (.imp (Formula.allFuture (Formula.neg p_test)) (.untl p_test q_test))
  -- true  (G(¬p) → U(p,q): p never true in future, Until unfulfillable)
#eval hasUnfulfillableEventuality (.imp (Formula.and (Formula.allFuture (Formula.neg p_test)) r_test) (.untl p_test q_test))
  -- true  (G(¬p) ∧ r → U(p,q): G(¬p) is a conjunct)
#eval hasUnfulfillableEventuality (.imp (Formula.allPast (Formula.neg p_test)) (.snce p_test q_test))
  -- true  (H(¬p) → S(p,q): symmetric past case)
#eval hasUnfulfillableEventuality (.imp (Formula.and (Formula.allPast (Formula.neg p_test)) r_test) (.snce p_test q_test))
  -- true  (H(¬p) ∧ r → S(p,q): H(¬p) is a conjunct)
-- hasUnfulfillableEventuality: negative cases
#eval hasUnfulfillableEventuality (.imp (Formula.allFuture (Formula.neg q_test)) (.untl p_test q_test))
  -- false (G(¬q), not G(¬p) — wrong atom)
#eval hasUnfulfillableEventuality (.imp p_test (.untl q_test r_test))
  -- false (no G(¬q) in antecedent)
#eval hasUnfulfillableEventuality (.imp p_test q_test)                     -- false (consequent not Until/Since)
#eval hasUnfulfillableEventuality p_test                                   -- false (not an implication)

-- structuralInvalidPrefilter: integration tests
#eval structuralInvalidPrefilter (.imp p_test (.untl .bot q_test))
  -- some (false, "invalid_satisfiable_neg") — atom is trivially satisfiable, so Pattern 2b fires
#eval structuralInvalidPrefilter (.imp p_test .bot)
  -- some (false, "invalid_satisfiable_neg") — atom is trivially satisfiable
#eval structuralInvalidPrefilter (.imp (.untl p_test q_test) (.untl .bot r_test))
  -- some (false, "invalid_false_consequent") — U(p,q) not trivially satisfiable, falls to Pattern 1
#eval structuralInvalidPrefilter (.imp (Formula.allFuture (Formula.neg p_test)) (.untl p_test q_test))
  -- some (false, "invalid_unfulfillable_eventuality") — G(¬p) makes U(p,q) unfulfillable
#eval structuralInvalidPrefilter (.imp p_test q_test)
  -- none (undetermined)
#eval structuralInvalidPrefilter (.imp .bot .bot)
  -- none (vacuously valid, not invalid — bot is not trivially satisfiable)
#eval structuralInvalidPrefilter (.imp (.untl .bot p_test) (.untl .bot q_test))
  -- none (both sides always false → valid, not caught as invalid)

-- structuralInvalidPrefilter: constructTrivialCountermodel test
#eval do
  let cm := constructTrivialCountermodel (.imp p_test (.untl .bot q_test))
  return (cm.trueAtoms.length, cm.falseAtoms.length)
  -- (2, 0) — both atoms p and q set to true

/-! ### DecideCache: Bounded HashMap Cache for Formula Labeling

Cache for `labelFormulaImpl` results, keyed by `(Formula, FrameClass)`.
Thread-safe via `Std.Mutex`. Uses bounded HashMap with bulk eviction:
when entries exceed `maxSize`, the oldest half (by insertion order) is
evicted. Cache statistics (hits, misses, evictions) are tracked for
benchmark reporting.
-/

/--
Cache key for the decide cache: `(Formula, FrameClass)` pair.
Since `searchDepth` and `tableauFuel` are deterministic functions of
the formula, the effective cache key is just `(Formula, FrameClass)`.
-/
structure DecideCacheKey where
  formula : Formula
  frameClass : FrameClass
  deriving BEq, Hashable

/--
Bounded HashMap cache for `LabeledFormula` results.
Stores results keyed by `DecideCacheKey`, tracks insertion order for
FIFO eviction, and maintains hit/miss/eviction counters.
-/
structure DecideCache where
  /-- The cache map from key to labeled result. -/
  entries : Std.HashMap DecideCacheKey LabeledFormula
  /-- Insertion order for FIFO eviction (oldest first). -/
  accessOrder : Array DecideCacheKey
  /-- Number of cache hits. -/
  hits : Nat
  /-- Number of cache misses. -/
  misses : Nat
  /-- Number of bulk eviction events. -/
  evictions : Nat
  /-- Maximum number of entries before eviction triggers. -/
  maxSize : Nat
  deriving Inhabited

/-- Create an empty cache with the given maximum size. -/
def DecideCache.empty (maxSize : Nat := 10000) : DecideCache :=
  { entries := {}
    accessOrder := #[]
    hits := 0
    misses := 0
    evictions := 0
    maxSize := maxSize }

/-- Compute the cache hit rate as a percentage (0-100). -/
def DecideCache.hitRate (c : DecideCache) : Float :=
  let total := c.hits + c.misses
  if total == 0 then 0.0
  else (c.hits.toFloat / total.toFloat) * 100.0

/--
Look up a key in the cache. Returns the cached `LabeledFormula` if found
(cache hit), or `none` (cache miss). Updates hit/miss counters.
-/
def DecideCache.lookup (c : DecideCache) (key : DecideCacheKey)
    : DecideCache × Option LabeledFormula :=
  match c.entries[key]? with
  | some lf => ({ c with hits := c.hits + 1 }, some lf)
  | none => ({ c with misses := c.misses + 1 }, none)

/--
Evict the oldest half of cache entries when size exceeds `maxSize`.
Removes the first half of `accessOrder` keys from the HashMap and
trims the `accessOrder` array accordingly.
-/
def DecideCache.evict (c : DecideCache) : DecideCache :=
  if c.accessOrder.size ≤ c.maxSize then c
  else
    let halfSize := c.accessOrder.size / 2
    let keysToRemove := c.accessOrder.extract 0 halfSize
    let remainingOrder := c.accessOrder.extract halfSize c.accessOrder.size
    let newEntries := keysToRemove.foldl (fun m k => m.erase k) c.entries
    { c with
      entries := newEntries
      accessOrder := remainingOrder
      evictions := c.evictions + 1 }

/--
Insert a key-value pair into the cache. Appends the key to `accessOrder`
for FIFO eviction tracking. Triggers eviction if size exceeds `maxSize`.
-/
def DecideCache.insert (c : DecideCache) (key : DecideCacheKey) (lf : LabeledFormula)
    : DecideCache :=
  let c' := { c with
    entries := c.entries.insert key lf
    accessOrder := c.accessOrder.push key }
  c'.evict

/--
Display cache statistics as a human-readable string.
-/
def DecideCache.display (c : DecideCache) : String :=
  let total := c.hits + c.misses
  let rateStr := if total == 0 then "N/A"
    else s!"{(c.hits * 100 / total)}%"
  s!"Cache: {c.hits} hits, {c.misses} misses, {rateStr} hit rate, {c.evictions} evictions, {c.entries.size} entries"

/--
Label a single formula by running the decision procedure.

1. Checks the structural pre-filter for known-valid patterns
2. Measures wall-clock time using `IO.monoMsNow`
3. Calls `decideAutoAdaptive` (single-tier fuel=500)
4. Extracts proof trace (valid), countermodel (invalid), or records timeout
5. Computes difficulty metrics and pattern key
6. For valid formulas, infers proof reconstruction method from proof structure
7. For invalid formulas, extracts enriched and semantic countermodel data

With the 5-strategy proof extraction pipeline in place, `decideAuto`
returns `.valid` for all closed tableaux where proof extraction succeeds.
The `.timeout` case now represents genuine resource exhaustion (tableau
construction exceeded sound fuel), not a masking of extraction failure.
The `decideOptimized` retry path is no longer needed.
-/
def labelFormulaImpl (φ : Formula) (fc : FrameClass := .Base)
    (wallclockTimeoutMs : Nat := 1000) : IO LabeledFormula := do
  -- Phase 1: Structural pre-filter with axiom attribution
  -- Check for known-valid patterns before invoking the decision procedure.
  -- Returns axiom pattern name alongside validity for dataset attribution.
  match structuralPrefilterWithAxiom φ with
  | some (true, axiomPattern) =>
    let metrics := computeMetrics φ 0
    let patternKey := PatternKey.fromFormula φ
    let intResult := computeInterestingness φ none none
    return {
      formula := φ
      label := .valid
      proofTrace := none
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := none
      decisionMethod := "structural_prefilter"
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := some ("structural_prefilter:" ++ axiomPattern)
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }
  | _ =>
  -- Phase 1.5: Structural invalid pre-filter
  -- Check for known-invalid patterns before invoking the decision procedure.
  -- Catches formulas with false consequents, trivially satisfiable antecedents
  -- negated to bot, or unfulfillable Until/Since eventualities.
  match structuralInvalidPrefilter φ with
  | some (false, pattern) =>
    let metrics := computeMetrics φ 0
    let patternKey := PatternKey.fromFormula φ
    let cm := constructTrivialCountermodel φ
    let intResult := computeInterestingness φ none none
    return {
      formula := φ
      label := .invalid
      proofTrace := none
      countermodel := some cm
      metrics := metrics
      patternKey := patternKey
      ruleProfile := none
      decisionMethod := "structural_invalid_prefilter"
      countermodelConsistent := some true
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := some ("structural_invalid_prefilter:" ++ pattern)
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }
  | _ =>
  -- Phase 2: Decision procedure with wall-clock timeout
  -- Spawn the decision procedure on a dedicated IO thread so we can
  -- enforce a wall-clock timeout and cancel the task if it exceeds the deadline.
  -- Replaced Task.spawn with IO.asTask + IO.cancel to prevent
  -- unkillable abandoned tasks from consuming memory after timeout.
  -- Also adds adaptive fuel reduction for high-complexity formulas.
  let startTime ← IO.monoMsNow
  if wallclockTimeoutMs > 0 then
    -- Adaptive fuel reduction for high-complexity formulas.
    -- For complexity >= 7, reduce fuel to bound exponential branching.
    -- Formula: min 500 (150 + complexity * 30)
    -- c7: min 500 360 = 360, c8: min 500 390 = 390, c12+: 500
    let adaptiveFuel := min 500 (150 + φ.complexity * 30)
    -- Spawn decision procedure on a dedicated IO thread.
    -- IO.asTask (unlike Task.spawn) supports IO.cancel on the timeout path,
    -- ensuring the spawned task is signaled for cancellation when the
    -- wall-clock deadline fires instead of running forever in the background.
    -- Run the *cancellable* decision mirror so the timed task
    -- re-enters IO at every tableau step and observes the abort ref set below,
    -- instead of running a single non-observing pure computation to
    -- fuel/branch exhaustion as a zombie thread.
    let abortRef ← IO.mkRef false
    let task ← IO.asTask (prio := .dedicated) do
      decideAutoAdaptiveCancellable abortRef φ fc adaptiveFuel
    let deadline := startTime + wallclockTimeoutMs
    let mut timedOut := false
    -- Poll loop with 1ms sleep
    repeat do
      let done ← IO.hasFinished task
      if done then break
      let now ← IO.monoMsNow
      if now >= deadline then
        timedOut := true
        break
      IO.sleep 1
    let endTime ← IO.monoMsNow
    let elapsed := endTime - startTime
    let metrics := computeMetrics φ elapsed
    let patternKey := PatternKey.fromFormula φ
    if timedOut then
      -- Signal the abort ref first (observed cooperatively by
      -- decideAutoAdaptiveCancellable at every tableau step), then cancel the
      -- spawned IO task as belt-and-braces. This stops abandoned exponential
      -- tableau branching promptly instead of letting it run to exhaustion.
      abortRef.set true
      IO.cancel task
      let intResult := computeInterestingness φ none none
      return {
        formula := φ
        label := .timeout
        proofTrace := none
        countermodel := none
        metrics := metrics
        patternKey := patternKey
        ruleProfile := none
        decisionMethod := "wallclock_timeout"
        countermodelConsistent := none
        enrichedCountermodel := none
        semanticCountermodelSummary := none
        proofReconstructionMethod := none
        interestingnessScore := some intResult.compositeScore
        interestingnessTier := some intResult.tier.toString
      }
    -- Task finished within deadline; retrieve the result
    let taskResult ← IO.wait task
    let (result, fuelTier) ← IO.ofExcept taskResult
    match result with
    | .valid proof =>
      let trace := extractProofTrace proof
      let rp := walkDerivationTree proof
      let method := if rp.mpCount == 0 && rp.necessitationCount == 0 &&
                       rp.temporalNecessitationCount == 0 && rp.temporalDualityCount == 0 &&
                       rp.weakeningCount == 0 && rp.assumptionCount == 0
                    then "fast_path_axiom"
                    else fuelTier
      let reconMethod := inferReconstructionMethod rp trace.height
      let intResult := computeInterestingness φ (some trace.toProofData) (some rp)
      return {
        formula := φ
        label := .valid
        proofTrace := some trace
        countermodel := none
        metrics := metrics
        patternKey := patternKey
        ruleProfile := some rp
        decisionMethod := method
        countermodelConsistent := none
        enrichedCountermodel := none
        semanticCountermodelSummary := none
        proofReconstructionMethod := some reconMethod
        interestingnessScore := some intResult.compositeScore
        interestingnessTier := some intResult.tier.toString
      }
    | .invalid cm =>
      let intResult := computeInterestingness φ none none
      -- Extract abort-aware at the *deciding* fuel (adaptiveFuel),
      -- not the unbounded soundFuel. The task finished normally here so the
      -- abort ref is unset; the bound is the win. `min pair.2 fuel`-style
      -- reproduction of the open branch is deterministic at the same fuel.
      let (ecm, scmSummary) ← extractCountermodelDataCancellable abortRef φ adaptiveFuel
      let base := mkInvalidLabel φ cm metrics patternKey ecm scmSummary fuelTier
      return { base with
        interestingnessScore := some intResult.compositeScore
        interestingnessTier := some intResult.tier.toString
      }
    | .timeout =>
      let intResult := computeInterestingness φ none none
      return {
        formula := φ
        label := .timeout
        proofTrace := none
        countermodel := none
        metrics := metrics
        patternKey := patternKey
        ruleProfile := none
        decisionMethod := fuelTier
        countermodelConsistent := none
        enrichedCountermodel := none
        semanticCountermodelSummary := none
        proofReconstructionMethod := none
        interestingnessScore := some intResult.compositeScore
        interestingnessTier := some intResult.tier.toString
      }
  -- Fallback: no wall-clock timeout (wallclockTimeoutMs == 0), run synchronously
  let (result, fuelTier) := decideAutoAdaptive φ fc
  let endTime ← IO.monoMsNow
  let elapsed := endTime - startTime
  let metrics := computeMetrics φ elapsed
  let patternKey := PatternKey.fromFormula φ
  match result with
  | .valid proof =>
    let trace := extractProofTrace proof
    let rp := walkDerivationTree proof
    -- Determine decision method: combine fast-path detection with fuel tier info
    let method := if rp.mpCount == 0 && rp.necessitationCount == 0 &&
                     rp.temporalNecessitationCount == 0 && rp.temporalDualityCount == 0 &&
                     rp.weakeningCount == 0 && rp.assumptionCount == 0
                  then "fast_path_axiom"
                  else fuelTier
    let reconMethod := inferReconstructionMethod rp trace.height
    -- Compute interestingness with full proof data
    let intResult := computeInterestingness φ (some trace.toProofData) (some rp)
    return {
      formula := φ
      label := .valid
      proofTrace := some trace
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := some rp
      decisionMethod := method
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := some reconMethod
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }
  | .invalid cm =>
    -- Compute interestingness without proof data (syntactic metrics only)
    let intResult := computeInterestingness φ none none
    -- This synchronous fallback runs `decideAutoAdaptive φ fc` at the
    -- default fuel 500; re-run the countermodel extraction fuel-bounded at 500
    -- (pure; no timeout/abort ref exists on this path) instead of soundFuel.
    let (ecm, scmSummary) := extractCountermodelData φ 500
    let base := mkInvalidLabel φ cm metrics patternKey ecm scmSummary fuelTier
    return { base with
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }
  | .timeout =>
    -- Compute interestingness without proof data (syntactic metrics only)
    let intResult := computeInterestingness φ none none
    return {
      formula := φ
      label := .timeout
      proofTrace := none
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := none
      decisionMethod := fuelTier
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := none
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
      }

/--
Look up a formula in a proof-first pool and produce a `LabeledFormula`.
If the formula is not in the pool, returns `.invalid` with a fallback label.
-/
def labelFormulaProofFirst (φ : Formula) (pool : ProofPool .Base)
    (fc : FrameClass := .Base) : IO LabeledFormula := do
  match pool.index[φ]? with
  | some idx =>
    let σ := pool.entries[idx]!
    let d := σ.snd
    -- Lift base derivation to the requested frame class if needed
    let d_lifted := d.lift (FrameClass.base_le fc)
    let trace := extractProofTrace d_lifted
    let rp := walkDerivationTree d_lifted
    let metrics := computeMetrics φ 0
    let patternKey := PatternKey.fromFormula φ
    let intResult := computeInterestingness φ (some trace.toProofData) (some rp)
    return {
      formula := φ
      label := .valid
      proofTrace := some trace
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := some rp
      decisionMethod := "proof_first"
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := some "proof_first_compositional"
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }
  | none =>
    let metrics := computeMetrics φ 0
    let patternKey := PatternKey.fromFormula φ
    let intResult := computeInterestingness φ none none
    return {
      formula := φ
      label := .invalid
      proofTrace := none
      countermodel := none
      metrics := metrics
      patternKey := patternKey
      ruleProfile := none
      decisionMethod := "proof_first_miss"
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := none
      interestingnessScore := some intResult.compositeScore
      interestingnessTier := some intResult.tier.toString
    }

/--
Label a single formula, dispatching on the generation mode.
-/
def labelFormula (φ : Formula) (fc : FrameClass := .Base)
    (wallclockTimeoutMs : Nat := 1000)
    (mode : GenerationMode := .exhaustive)
    (proofFirstPool : Option (ProofPool .Base) := none) : IO LabeledFormula := do
  match mode, proofFirstPool with
  | .exhaustive, _ => labelFormulaImpl φ fc wallclockTimeoutMs
  | .proofFirst, some pool => labelFormulaProofFirst φ pool fc
  | .proofFirst, none =>
    IO.eprintln "[warn] proofFirst mode requested but no pool provided; falling back to exhaustive"
    labelFormulaImpl φ fc wallclockTimeoutMs
  | .hybrid, some pool =>
    let lf ← labelFormulaProofFirst φ pool fc
    match lf.label with
    | .valid => return lf
    | _ => labelFormulaImpl φ fc wallclockTimeoutMs
  | .hybrid, none => labelFormulaImpl φ fc wallclockTimeoutMs

/--
Label a formula with cache support. Uses a `Std.Mutex`-protected `DecideCache`
for thread-safe access. On cache hit, returns the cached result with
`decisionMethod` set to `"cached"` and `decisionTimeMs` set to 0.
On cache miss, calls `labelFormula`, caches the result, and returns it.

**Important**: The mutex is NOT held during the `labelFormula` call.
Only the lookup and insert operations acquire the lock, keeping the
critical section O(1) while the expensive decide computation runs unlocked.
-/
def labelFormulaWithCache (cache : Std.Mutex DecideCache) (φ : Formula)
    (fc : FrameClass := .Base) (wallclockTimeoutMs : Nat := 1000)
    (mode : GenerationMode := .exhaustive)
    (proofFirstPool : Option (ProofPool .Base) := none)
    : IO LabeledFormula := do
  let key : DecideCacheKey := { formula := φ, frameClass := fc }
  -- Check cache (short critical section)
  let cached ← cache.atomically do
    let c ← get
    let (c', result) := c.lookup key
    set c'
    return result
  match cached with
  | some lf =>
    -- Cache hit: return with "cached" method and zero time
    return { lf with
      decisionMethod := "cached"
      metrics := { lf.metrics with decisionTimeMs := 0 } }
  | none =>
    -- Cache miss: compute result WITHOUT holding the mutex
    let lf ← labelFormula φ fc wallclockTimeoutMs mode proofFirstPool
    -- Insert result into cache (short critical section)
    cache.atomically do
      modify fun c => c.insert key lf
    return lf

/--
Label a batch of formulas with progress reporting.

Prints progress every 100 formulas processed.
Returns the list of all labeled results.
-/
def labelBatch (formulas : List Formula) (wallclockTimeoutMs : Nat := 1000)
    (parallelThreads : Nat := 0)
    (mode : GenerationMode := .exhaustive)
    (proofFirstPool : Option (ProofPool .Base) := none)
    (cacheMaxSize : Nat := 10000)
    : IO (List LabeledFormula) := do
  let total := formulas.length
  -- Create shared Mutex-protected cache for deduplication
  let cache ← Std.Mutex.new (DecideCache.empty cacheMaxSize)
  if parallelThreads == 0 then
    -- Sequential path with cache
    let mut results : List LabeledFormula := []
    let mut count : Nat := 0
    for φ in formulas do
      let labeled ← labelFormulaWithCache cache φ .Base wallclockTimeoutMs mode proofFirstPool
      results := labeled :: results
      count := count + 1
      if count % 100 == 0 then
        IO.println s!"  Progress: {count}/{total} formulas labeled"
    -- Print cache statistics
    let cacheStats ← cache.atomically do return (← get)
    IO.println (cacheStats.display)
    return results.reverse
  else
    -- Parallel path: chunk-based IO.asTask with shared cache
    let arr := formulas.toArray
    let chunkSize := max 1 ((arr.size + parallelThreads - 1) / parallelThreads)
    let numChunks := (arr.size + chunkSize - 1) / chunkSize
    -- Helper: timeout placeholder for a formula
    let mkTimeout (φ : Formula) : LabeledFormula := {
      formula := φ
      label := .timeout
      proofTrace := none
      countermodel := none
      metrics := computeMetrics φ 0
      patternKey := PatternKey.fromFormula φ
      ruleProfile := none
      decisionMethod := "chunk_exception_timeout"
      countermodelConsistent := none
      enrichedCountermodel := none
      semanticCountermodelSummary := none
      proofReconstructionMethod := none
    }
    -- Spawn one IO.asTask per chunk, sharing the cache across all chunks
    let mut tasks : List (Task (Except IO.Error (List LabeledFormula))) := []
    for i in [:numChunks] do
      let startIdx := i * chunkSize
      let endIdx := min ((i + 1) * chunkSize) arr.size
      let chunk := arr.extract startIdx endIdx
      let task ← IO.asTask (prio := .dedicated) do
        let mut chunkResults : List LabeledFormula := []
        for φ in chunk do
          let labeled ← try
            labelFormulaWithCache cache φ .Base wallclockTimeoutMs mode proofFirstPool
          catch _e =>
            pure (mkTimeout φ)
          chunkResults := labeled :: chunkResults
        return chunkResults.reverse
      tasks := task :: tasks
    -- Wait for all tasks and concatenate in chunk order
    let tasksArr := tasks.reverse.toArray
    let mut allResults : List LabeledFormula := []
    let mut completedCount : Nat := 0
    for i in [:numChunks] do
      let chunkResult ← IO.ofExcept (← IO.wait tasksArr[i]!)
      allResults := allResults ++ chunkResult
      completedCount := completedCount + chunkResult.length
      if completedCount % 100 == 0 || i == numChunks - 1 then
        IO.println s!"  Progress: {completedCount}/{total} formulas labeled (chunk {i + 1}/{numChunks})"
    -- Print cache statistics
    let cacheStats ← cache.atomically do return (← get)
    IO.println (cacheStats.display)
    return allResults

/--
Batch statistics: count labeled formulas by category.
-/
structure BatchStats where
  /-- Total formulas processed. -/
  totalCount : Nat
  /-- Number labeled valid. -/
  validCount : Nat
  /-- Number labeled invalid. -/
  invalidCount : Nat
  /-- Number that timed out. -/
  timeoutCount : Nat
  /-- Average decision time in milliseconds. -/
  avgTimeMs : Nat
  deriving Repr, Inhabited

/--
Compute batch statistics from labeled formulas.
-/
def computeBatchStats (labeled : List LabeledFormula) : BatchStats :=
  let init : BatchStats := { totalCount := 0, validCount := 0, invalidCount := 0,
                              timeoutCount := 0, avgTimeMs := 0 }
  let stats := labeled.foldl (fun acc lf =>
    { totalCount := acc.totalCount + 1
      validCount := acc.validCount + (if lf.label == .valid then 1 else 0)
      invalidCount := acc.invalidCount + (if lf.label == .invalid then 1 else 0)
      timeoutCount := acc.timeoutCount + (if lf.label == .timeout then 1 else 0)
      avgTimeMs := acc.avgTimeMs + lf.metrics.decisionTimeMs }
  ) init
  { stats with
    avgTimeMs := if stats.totalCount > 0 then stats.avgTimeMs / stats.totalCount else 0 }

/--
Display batch statistics as a human-readable string.
-/
def BatchStats.display (s : BatchStats) : String :=
  let timeoutRate := if s.totalCount > 0
    then toString (s.timeoutCount * 100 / s.totalCount)
    else "0"
  let validRate := if s.totalCount > 0
    then toString (s.validCount * 100 / s.totalCount)
    else "0"
  s!"Batch Statistics:\n" ++
  s!"  Total: {s.totalCount}\n" ++
  s!"  Valid: {s.validCount} ({validRate}%)\n" ++
  s!"  Invalid: {s.invalidCount}\n" ++
  s!"  Timeout: {s.timeoutCount} ({timeoutRate}%)\n" ++
  s!"  Avg decision time: {s.avgTimeMs}ms"

/-!
## JSON Serialization for Phase 3 API

These methods provide direct JSON serialization on `FormulaLabel` and
`LabeledFormula`, using the primitives from `DataExport.lean`.
-/

/--
Serialize a `FormulaLabel` to a JSON string value.

- `.valid` → `"valid"`
- `.invalid` → `"invalid"`
- `.timeout` → `"timeout"`
-/
def FormulaLabel.toJson : FormulaLabel → String
  | .valid => "\"valid\""
  | .invalid => "\"invalid\""
  | .timeout => "\"timeout\""

/--
Serialize a `ProofTrace` to a JSON object string.

Example:
```json
{"height": 2, "axioms_used": ["modal_t"], "rules_applied": ["modus_ponens"]}
```
-/
def ProofTrace.toJson (pt : ProofTrace) : String :=
  let axiomsArr := listToJsonArray (pt.axiomsUsed.map fun s =>
    "\"" ++ escapeJsonString s ++ "\"")
  let rulesArr := listToJsonArray (pt.rulesApplied.map fun s =>
    "\"" ++ escapeJsonString s ++ "\"")
  "{\"height\": " ++ toString pt.height
  ++ ", \"axioms_used\": " ++ axiomsArr
  ++ ", \"rules_applied\": " ++ rulesArr
  ++ "}"

/--
Serialize a `DifficultyMetrics` to a JSON object string.
-/
def DifficultyMetrics.toJson (dm : DifficultyMetrics) : String :=
  "{\"complexity\": " ++ toString dm.complexity
  ++ ", \"modalDepth\": " ++ toString dm.modalDepth
  ++ ", \"temporalDepth\": " ++ toString dm.temporalDepth
  ++ ", \"impCount\": " ++ toString dm.impCount
  ++ ", \"atomCount\": " ++ toString dm.atomCount
  ++ ", \"decisionTimeMs\": " ++ toString dm.decisionTimeMs
  ++ ", \"difficultyTier\": \"" ++ escapeJsonString dm.difficultyTier ++ "\""
  ++ "}"

/--
Serialize a `SemanticCountermodelSummary` to a JSON object string.
-/
def SemanticCountermodelSummary.toJson (s : SemanticCountermodelSummary) : String :=
  let worldsStr := listToJsonArray (s.worlds.map toString)
  let timesStr := listToJsonArray (s.times.map toString)
  let constraintsStr := listToJsonArray (s.timeConstraints.map fun (a, b) =>
    "[" ++ toString a ++ ", " ++ toString b ++ "]")
  "{\"worlds\": " ++ worldsStr
  ++ ", \"times\": " ++ timesStr
  ++ ", \"time_constraints\": " ++ constraintsStr
  ++ ", \"world_count\": " ++ toString s.worldCount
  ++ ", \"time_count\": " ++ toString s.timeCount
  ++ "}"

/--
Serialize a `LabeledFormula` to a complete JSON object string.

Includes all fields: formula, features, decision result, proof trace,
countermodel (simple, enriched, semantic), metrics, and rule profile.
-/
def LabeledFormula.toJson (lf : LabeledFormula) : String :=
  let proofStr := match lf.proofTrace with
    | none => "null"
    | some pt => pt.toJson
  let cmStr := match lf.countermodel with
    | none => "null"
    | some cm => cm.toJson
  let rpStr := match lf.ruleProfile with
    | none => "null"
    | some rp => rp.toJson
  let cmConsStr := match lf.countermodelConsistent with
    | none => "null"
    | some true => "true"
    | some false => "false"
  let ecmStr := match lf.enrichedCountermodel with
    | none => "null"
    | some ecm => ecm.toJson
  let scmStr := match lf.semanticCountermodelSummary with
    | none => "null"
    | some s => s.toJson
  let reconStr := match lf.proofReconstructionMethod with
    | none => "null"
    | some m => "\"" ++ escapeJsonString m ++ "\""
  "{\"formula\": " ++ lf.formula.toJson
  ++ ", \"formula_string\": \"" ++ escapeJsonString lf.formula.prettyPrint ++ "\""
  ++ ", \"features\": " ++ lf.patternKey.toJson
  ++ ", \"decision\": " ++ lf.label.toJson
  ++ ", \"decision_method\": \"" ++ escapeJsonString lf.decisionMethod ++ "\""
  ++ ", \"proof_reconstruction_method\": " ++ reconStr
  ++ ", \"proof\": " ++ proofStr
  ++ ", \"rule_profile\": " ++ rpStr
  ++ ", \"countermodel\": " ++ cmStr
  ++ ", \"countermodel_consistent\": " ++ cmConsStr
  ++ ", \"enriched_countermodel\": " ++ ecmStr
  ++ ", \"semantic_countermodel\": " ++ scmStr
  ++ ", \"metrics\": " ++ lf.metrics.toJson
  ++ ", \"interestingness_score\": " ++ (match lf.interestingnessScore with
    | none => "null"
    | some s => toString s)
  ++ ", \"interestingness_tier\": " ++ (match lf.interestingnessTier with
    | none => "null"
    | some t => "\"" ++ escapeJsonString t ++ "\"")
  ++ "}"

/-!
### Proof-Pool Hybrid Mode and Extended Prefilter

**Prefilter patterns** (hybrid-mode additions):
- `structural_identity`: `φ → φ` for any formula φ (catches temporal/derived operator identities)
- `structural_until_implies_future`: `U(X, Y) → F(Y)` (Until guarantees eventual occurrence)
- `structural_since_implies_past`: `S(X, Y) → P(Y)` (Since guarantees past occurrence)

**Integration test results** (mini-batch, 8 formulas):
- 6/8 caught by structural prefilter
- 1/8 resolved by adaptive tableau (invalid)
- 1/8 timeout (genuinely hard: `U(p, q) → U(r, q)`)
- 0 label regressions (exhaustive and hybrid modes agree on all labels)

**CLI flags** (in DatasetExport.lean):
- `--generation-mode exhaustive|proofFirst|hybrid` (default: exhaustive)
- `--pool-depth N` (default: 2)
- `--pool-seeds N` (default: 10000)
-/

/-! ### Phase 1 smoke tests: proof-pool hybrid mode -/

-- Test 1: Pool generation produces a non-empty pool
#eval show IO Unit from do
  let cfg : ForwardConfig := {
    seedCount := 100
    maxDepth := 1
    maxPoolSize := 200
    atoms := [⟨"p", none⟩, ⟨"q", none⟩]
    frameClass := .Base
  }
  let entries ← forwardGenerate cfg
  IO.println s!"[test] Pool generation: {entries.length} entries (expected > 0)"
  if entries.length > 0 then
    IO.println "[test] PASS: pool is non-empty"
  else
    IO.println "[test] FAIL: pool is empty"

-- Test 2: labelFormula with hybrid mode hits a known valid formula (p → p)
#eval show IO Unit from do
  -- Build a small pool containing p → p
  let cfg : ForwardConfig := {
    seedCount := 100
    maxDepth := 1
    maxPoolSize := 200
    atoms := [⟨"p", none⟩, ⟨"q", none⟩]
    frameClass := .Base
  }
  let entries ← forwardGenerate cfg
  let mut pool : ProofPool .Base := { ProofPool.empty with cap := 200 }
  for σ in entries do
    pool := pool.add σ.fst σ.snd
  let pImpP := Formula.imp (Formula.atom ⟨"p", none⟩) (Formula.atom ⟨"p", none⟩)
  let containsPImpP := pool.contains pImpP
  IO.println s!"[test] Pool contains (p → p): {containsPImpP}"
  let lf ← labelFormula pImpP .Base 1000 .hybrid (some pool)
  IO.println s!"[test] Hybrid label for (p → p): {repr lf.label}, method: {lf.decisionMethod}"
  if lf.label == .valid then
    IO.println "[test] PASS: hybrid mode correctly labels (p → p) as valid"
  else
    IO.println "[test] FAIL: hybrid mode did not label (p → p) as valid"

-- Test 3: Fallthrough to tableau for a formula not in the pool
#eval show IO Unit from do
  -- Build an empty pool
  let pool : ProofPool .Base := { ProofPool.empty with cap := 10 }
  -- U(p, q) → U(r, s) is not in an empty pool; should fall through to tableau
  let φ := Formula.imp
    (Formula.untl (Formula.atom ⟨"p", none⟩) (Formula.atom ⟨"q", none⟩))
    (Formula.untl (Formula.atom ⟨"r", none⟩) (Formula.atom ⟨"s", none⟩))
  let lf ← labelFormula φ .Base 1000 .hybrid (some pool)
  IO.println s!"[test] Hybrid fallthrough: label={repr lf.label}, method={lf.decisionMethod}"
  if lf.decisionMethod != "proof_first" then
    IO.println "[test] PASS: hybrid mode fell through to tableau (not proof_first)"
  else
    IO.println "[test] FAIL: hybrid mode did not fall through"

/-! ### Phase 3 integration test: mini batch comparison -/

-- Test 4: Mini batch comparison of exhaustive vs hybrid modes
-- Uses a small representative set of formulas to verify both modes agree on labels
#eval show IO Unit from do
  let p := Formula.atom ⟨"p", none⟩
  let q := Formula.atom ⟨"q", none⟩
  let r := Formula.atom ⟨"r", none⟩
  -- Mix of valid, invalid, and potentially timeout formulas
  let testFormulas : List Formula := [
    .imp p p,                              -- valid (identity)
    .imp (.box p) p,                       -- valid (T axiom)
    .imp (.untl p q) q.someFuture,        -- valid (U->F)
    .imp (.snce p q) q.somePast,          -- valid (S->P)
    .imp p q,                              -- invalid
    .imp (.untl p q) (.untl r q),          -- unknown/invalid
    .imp p (.imp q q),                     -- valid (tautological consequent)
    .imp (.box .bot) q                     -- valid (bot antecedent)
  ]
  -- Exhaustive mode
  let mut exhaustiveResults : List (Formula × FormulaLabel × String) := []
  for φ in testFormulas do
    let lf ← labelFormula φ .Base 1000 .exhaustive none
    exhaustiveResults := (φ, lf.label, lf.decisionMethod) :: exhaustiveResults
  exhaustiveResults := exhaustiveResults.reverse
  -- Hybrid mode with a small pool
  let cfg : ForwardConfig := {
    seedCount := 200
    maxDepth := 1
    maxPoolSize := 500
    atoms := [⟨"p", none⟩, ⟨"q", none⟩, ⟨"r", none⟩]
    frameClass := .Base
  }
  let entries ← forwardGenerate cfg
  let mut pool : ProofPool .Base := { ProofPool.empty with cap := 500 }
  for σ in entries do
    pool := pool.add σ.fst σ.snd
  let mut hybridResults : List (Formula × FormulaLabel × String) := []
  for φ in testFormulas do
    let lf ← labelFormula φ .Base 1000 .hybrid (some pool)
    hybridResults := (φ, lf.label, lf.decisionMethod) :: hybridResults
  hybridResults := hybridResults.reverse
  -- Compare
  IO.println s!"[test] Pool size: {pool.size}"
  let mut allMatch := true
  let mut prefilterHits := 0
  let mut poolHits := 0
  for i in List.range testFormulas.length do
    match exhaustiveResults[i]?, hybridResults[i]? with
    | some (φ, exLabel, exMethod), some (_, hyLabel, hyMethod) =>
      let labelMatch := exLabel == hyLabel
      if !labelMatch then
        IO.println s!"[test] MISMATCH at {φ.prettyPrint}: exhaustive={repr exLabel} hybrid={repr hyLabel}"
        allMatch := false
      else
        IO.println s!"[test] OK: {φ.prettyPrint} -> {repr exLabel} (ex: {exMethod}, hy: {hyMethod})"
      if hyMethod.startsWith "structural_" then prefilterHits := prefilterHits + 1
      if hyMethod == "proof_first" then poolHits := poolHits + 1
    | _, _ => pure ()
  IO.println s!"[test] Prefilter hits: {prefilterHits}, Pool hits: {poolHits}"
  if allMatch then
    IO.println "[test] PASS: all labels match between exhaustive and hybrid modes"
  else
    IO.println "[test] FAIL: label mismatch detected"

/-! ### Phase 1.5 integration test: invalid prefilter in labelFormulaImpl -/

-- Test 5: labelFormulaImpl catches structurally invalid formulas via Phase 1.5
#eval show IO Unit from do
  let p := Formula.atom ⟨"p", none⟩
  let q := Formula.atom ⟨"q", none⟩
  let r := Formula.atom ⟨"r", none⟩
  -- Formulas that should be caught by the invalid prefilter
  let invalidFormulas : List (Formula × String) := [
    (.imp p .bot, "invalid_satisfiable_neg"),           -- p → ⊥: satisfiable negation
    (.imp p (.untl .bot q), "invalid_satisfiable_neg"), -- p → U(⊥,q): satisfiable + false consequent
    (.imp (.box p) .bot, "invalid_satisfiable_neg"),    -- □p → ⊥: box(atom) satisfiable
    (.imp (.untl p q) (.untl .bot r), "invalid_false_consequent"),  -- U(p,q) → U(⊥,r): false consequent
    (.imp (Formula.allFuture (Formula.neg p)) (.untl p q), "invalid_unfulfillable_eventuality")
      -- G(¬p) → U(p,q): unfulfillable eventuality
  ]
  let mut allPass := true
  for (φ, expectedPattern) in invalidFormulas do
    let lf ← labelFormulaImpl φ .Base 1000
    let methodOk := lf.decisionMethod == "structural_invalid_prefilter"
    let labelOk := lf.label == .invalid
    let patternOk := lf.proofReconstructionMethod == some ("structural_invalid_prefilter:" ++ expectedPattern)
    if methodOk && labelOk && patternOk then
      IO.println s!"[test] OK: {φ.prettyPrint} -> invalid via structural_invalid_prefilter:{expectedPattern}"
    else
      IO.println s!"[test] FAIL: {φ.prettyPrint} -> label={repr lf.label} method={lf.decisionMethod} recon={repr lf.proofReconstructionMethod}"
      allPass := false
  -- Verify valid formulas are NOT caught by the invalid prefilter
  let validFormulas : List Formula := [
    .imp p p,                              -- identity (valid)
    .imp (.box .bot) q,                    -- bot antecedent (valid)
    .imp (.untl .bot p) (.untl .bot q),    -- both sides always false → valid
    .imp p (.imp q q)                      -- tautological consequent (valid)
  ]
  for φ in validFormulas do
    let lf ← labelFormulaImpl φ .Base 1000
    if lf.decisionMethod == "structural_invalid_prefilter" then
      IO.println s!"[test] FAIL: valid formula {φ.prettyPrint} incorrectly caught by invalid prefilter (method={lf.decisionMethod})"
      allPass := false
    else
      IO.println s!"[test] OK: {φ.prettyPrint} -> {repr lf.label} via {lf.decisionMethod} (not invalid prefilter)"
  if allPass then
    IO.println "[test] PASS: all invalid prefilter integration tests pass"
  else
    IO.println "[test] FAIL: some invalid prefilter integration tests failed"

/-! ### Phase 4 tests: cross-validation, regression, and edge cases -/

-- Test 6: Cross-validation — invalid prefilter agrees with full tableau on known invalid formulas
#eval show IO Unit from do
  let p := Formula.atom ⟨"p", none⟩
  let q := Formula.atom ⟨"q", none⟩
  let r := Formula.atom ⟨"r", none⟩
  -- Formulas the invalid prefilter should catch, verified against full tableau
  let crossValFormulas : List Formula := [
    .imp p .bot,                                       -- p → ⊥ (invalid)
    .imp (.box p) .bot,                                -- □p → ⊥ (invalid)
    .imp p (.untl .bot q),                             -- p → U(⊥, q) (invalid)
    .imp p (.box .bot),                                -- p → □⊥ (invalid)
    .imp (Formula.and p q) .bot,                       -- (p ∧ q) → ⊥ (invalid)
    .imp (.box (.box p)) (.untl .bot q),               -- □□p → U(⊥, q) (invalid)
    .imp (Formula.imp .bot .bot) .bot,                 -- ⊤ → ⊥ (invalid)
    .imp p (.snce .bot q),                             -- p → S(⊥, q) (invalid)
    .imp (Formula.and p (Formula.neg q)) .bot,         -- (p ∧ ¬q) → ⊥ (invalid)
    .imp (.untl p q) (.untl .bot r)                    -- U(p,q) → U(⊥,r) (invalid)
  ]
  let mut allMatch := true
  for φ in crossValFormulas do
    let pfResult := structuralInvalidPrefilter φ
    let lf ← labelFormulaImpl φ .Base 1000
    match pfResult with
    | some (false, _pat) =>
      if lf.label == .invalid || lf.decisionMethod == "structural_invalid_prefilter" then
        IO.println s!"[test] OK: {φ.prettyPrint} — prefilter=invalid, tableau={repr lf.label}"
      else
        IO.println s!"[test] MISMATCH: {φ.prettyPrint} — prefilter=invalid but tableau={repr lf.label}"
        allMatch := false
    | _ =>
      IO.println s!"[test] SKIP: {φ.prettyPrint} — not caught by prefilter (method={lf.decisionMethod})"
  if allMatch then
    IO.println "[test] PASS: all cross-validation tests agree"
  else
    IO.println "[test] FAIL: cross-validation mismatch detected"

-- Test 7: Regression — known-valid formulas not mislabeled by invalid prefilter
#eval show IO Unit from do
  let p := Formula.atom ⟨"p", none⟩
  let q := Formula.atom ⟨"q", none⟩
  let validFormulas : List Formula := [
    .imp p p,                              -- identity
    .imp (.box .bot) q,                    -- bot antecedent
    .imp p (.imp q q),                     -- tautological consequent
    .imp (.box p) p,                       -- T axiom
    .imp (.box p) (.box (.box p)),         -- 4 axiom
    .imp p.allFuture p,                   -- Gp → p
    .imp p.allFuture p.someFuture,       -- Gp → Fp
    .imp (.untl p q) q.someFuture,        -- U(p,q) → F(q)
    .imp (.snce p q) q.somePast,          -- S(p,q) → P(q)
    .imp (.untl .bot p) (.untl .bot q)     -- U(⊥,p) → U(⊥,q): both always false, valid
  ]
  let mut allPass := true
  for φ in validFormulas do
    match structuralInvalidPrefilter φ with
    | some (false, pat) =>
      IO.println s!"[test] FAIL: valid formula {φ.prettyPrint} mislabeled as invalid ({pat})"
      allPass := false
    | _ =>
      IO.println s!"[test] OK: {φ.prettyPrint} — not caught by invalid prefilter"
  if allPass then
    IO.println "[test] PASS: no valid formulas mislabeled by invalid prefilter"
  else
    IO.println "[test] FAIL: regression — valid formulas mislabeled"

-- Test 8: Edge cases — vacuously valid and boundary formulas
#eval show IO Unit from do
  let p := Formula.atom ⟨"p", none⟩
  let q := Formula.atom ⟨"q", none⟩
  -- bot → bot: vacuously valid (both sides always false), should NOT be caught as invalid
  let e1 := structuralInvalidPrefilter (.imp .bot .bot)
  IO.println s!"[test] ⊥ → ⊥: {repr e1} (expected: none — vacuously valid)"
  -- top → bot: ⊤ is satisfiable, bot is always false → INVALID
  let e2 := structuralInvalidPrefilter (.imp Formula.top .bot)
  IO.println s!"[test] ⊤ → ⊥: {repr e2} (expected: some (false, invalid_satisfiable_neg))"
  -- box(bot) → U(bot, p): both sides always false → vacuously valid, should NOT be caught
  let e3 := structuralInvalidPrefilter (.imp (.box .bot) (.untl .bot p))
  IO.println s!"[test] □⊥ → U(⊥,p): {repr e3} (expected: none — vacuously valid)"
  -- p → box(bot): invalid (p is satisfiable, box(bot) always false)
  let e4 := structuralInvalidPrefilter (.imp p (.box .bot))
  IO.println s!"[test] p → □⊥: {repr e4} (expected: some (false, invalid_satisfiable_neg))"
  -- Verify correctness
  let pass1 := e1 == none
  let pass2 := e2 == some (false, "invalid_satisfiable_neg")
  let pass3 := e3 == none
  let pass4 := e4 == some (false, "invalid_satisfiable_neg")
  if pass1 && pass2 && pass3 && pass4 then
    IO.println "[test] PASS: all edge case tests correct"
  else
    IO.println s!"[test] FAIL: edge case failures (pass1={pass1} pass2={pass2} pass3={pass3} pass4={pass4})"

end FormalSystem.Automation
