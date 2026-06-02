import Bimodal.Automation.InterestingnessMetrics
import Bimodal.Automation.DataExport

/-!
# Interestingness Metrics Tests

Compile-time validation of the interestingness metrics module.
Tests cover:
- Trivial formula detection (SNT gate)
- Operator profile extraction (derived operator patterns)
- Operator diversity scoring
- Axiom layer classification
- Tier boundary classification
- Composite score computation
-/

namespace BimodalTest.Automation.Interestingness

open Bimodal.Syntax
open Bimodal.Automation.InterestingnessMetrics
open Bimodal.Automation.DataExport

-- Convenience abbreviations
private abbrev p : Formula := .atom_s "p"
private abbrev q : Formula := .atom_s "q"
private abbrev r : Formula := .atom_s "r"

/-!
## Section 1: Semantic Non-Triviality (SNT Gate)

Verify that trivial patterns receive SNT = 0.
-/

-- ex_falso: ⊥ → p should be trivial (SNT = 0)
#eval do
  let snt := semanticNonTriviality (.imp .bot p)
  if snt != 0 then throw (IO.userError s!"Expected SNT=0 for ex_falso, got {snt}")
  IO.println "PASS: ex_falso SNT = 0"

-- identity: p → p should be trivial (SNT = 0)
#eval do
  let snt := semanticNonTriviality (.imp p p)
  if snt != 0 then throw (IO.userError s!"Expected SNT=0 for identity, got {snt}")
  IO.println "PASS: identity SNT = 0"

-- weakening: p → (q → p) should be trivial (SNT = 0)
#eval do
  let snt := semanticNonTriviality (.imp p (.imp q p))
  if snt != 0 then throw (IO.userError s!"Expected SNT=0 for weakening, got {snt}")
  IO.println "PASS: weakening SNT = 0"

-- top-implication: p → ⊤ should be trivial (SNT = 0)
#eval do
  let snt := semanticNonTriviality (.imp p Formula.top)
  if snt != 0 then throw (IO.userError s!"Expected SNT=0 for top-imp, got {snt}")
  IO.println "PASS: top-implication SNT = 0"

-- propositional non-trivial: p → q should have SNT = 1
#eval do
  let snt := semanticNonTriviality (.imp p q)
  if snt != 1 then throw (IO.userError s!"Expected SNT=1 for propositional, got {snt}")
  IO.println "PASS: propositional SNT = 1"

-- modal formula: □p → p should have SNT = 2
#eval do
  let snt := semanticNonTriviality (.imp (.box p) p)
  if snt != 2 then throw (IO.userError s!"Expected SNT=2 for modal, got {snt}")
  IO.println "PASS: modal SNT = 2"

-- bimodal formula: □p → Fp should have SNT = 3
#eval do
  let snt := semanticNonTriviality (.imp (.box p) (Formula.some_future p))
  if snt != 3 then throw (IO.userError s!"Expected SNT=3 for bimodal, got {snt}")
  IO.println "PASS: bimodal SNT = 3"

/-!
## Section 2: Operator Profile Extraction

Verify that derived operator patterns are correctly detected.
-/

-- F(p) = untl p top should detect hasSomeFuture
#eval do
  let profile := extractOperatorProfile (Formula.some_future p)
  if !profile.hasSomeFuture then throw (IO.userError "Expected hasSomeFuture for F(p)")
  IO.println "PASS: F(p) detected as some_future"

-- P(p) = snce p top should detect hasSomePast
#eval do
  let profile := extractOperatorProfile (Formula.some_past p)
  if !profile.hasSomePast then throw (IO.userError "Expected hasSomePast for P(p)")
  IO.println "PASS: P(p) detected as some_past"

-- G(p) = ¬F(¬p) should detect hasAllFuture
#eval do
  let profile := extractOperatorProfile (Formula.all_future p)
  if !profile.hasAllFuture then throw (IO.userError "Expected hasAllFuture for G(p)")
  IO.println "PASS: G(p) detected as all_future"

-- H(p) = ¬P(¬p) should detect hasAllPast
#eval do
  let profile := extractOperatorProfile (Formula.all_past p)
  if !profile.hasAllPast then throw (IO.userError "Expected hasAllPast for H(p)")
  IO.println "PASS: H(p) detected as all_past"

-- ◇p = ¬□¬p should detect hasDiamond
#eval do
  let profile := extractOperatorProfile (Formula.diamond p)
  if !profile.hasDiamond then throw (IO.userError "Expected hasDiamond for ◇p")
  IO.println "PASS: ◇p detected as diamond"

-- □p should detect hasBox
#eval do
  let profile := extractOperatorProfile (.box p)
  if !profile.hasBox then throw (IO.userError "Expected hasBox for □p")
  IO.println "PASS: □p detected as box"

-- U(p, q) (non-top guard) should detect hasUntil
#eval do
  let profile := extractOperatorProfile (.untl p q)
  if !profile.hasUntil then throw (IO.userError "Expected hasUntil for U(p,q)")
  IO.println "PASS: U(p,q) detected as until"

-- S(p, q) (non-top guard) should detect hasSince
#eval do
  let profile := extractOperatorProfile (.snce p q)
  if !profile.hasSince then throw (IO.userError "Expected hasSince for S(p,q)")
  IO.println "PASS: S(p,q) detected as since"

/-!
## Section 3: Operator Diversity Scoring
-/

-- Pure propositional: p → q should have OD = 0
#eval do
  let od := operatorDiversity (.imp p q)
  if od != 0 then throw (IO.userError s!"Expected OD=0 for propositional, got {od}")
  IO.println "PASS: propositional OD = 0"

-- Single box: □p should have OD = 1
#eval do
  let od := operatorDiversity (.box p)
  if od != 1 then throw (IO.userError s!"Expected OD=1 for □p, got {od}")
  IO.println "PASS: □p OD = 1"

-- Box + F (cross-modal): □p → Fp should have high OD (base + cross-modal bonus)
#eval do
  let od := operatorDiversity (.imp (.box p) (Formula.some_future p))
  -- hasBox=1, hasSomeFuture=1, cross-modal=2 => 4
  if od < 4 then throw (IO.userError s!"Expected OD>=4 for □p→Fp, got {od}")
  IO.println s!"PASS: □p→Fp OD = {od}"

-- G + H (bidirectional): Gp → Hp should have bidirectional bonus
#eval do
  let od := operatorDiversity (.imp (Formula.all_future p) (Formula.all_past p))
  -- hasAllFuture=1, hasAllPast=1, bidirectional=1 => 3
  if od < 3 then throw (IO.userError s!"Expected OD>=3 for Gp→Hp, got {od}")
  IO.println s!"PASS: Gp→Hp OD = {od}"

/-!
## Section 4: Axiom Layer Classification
-/

-- Propositional axioms
#eval do
  let layer := classifyAxiomLayer "prop_k"
  if layer != "propositional" then throw (IO.userError s!"Expected propositional, got {layer}")
  IO.println "PASS: prop_k -> propositional"

-- Modal axioms
#eval do
  let layer := classifyAxiomLayer "modal_t"
  if layer != "modal" then throw (IO.userError s!"Expected modal, got {layer}")
  IO.println "PASS: modal_t -> modal"

-- Interaction axiom
#eval do
  let layer := classifyAxiomLayer "modal_future"
  if layer != "interaction" then throw (IO.userError s!"Expected interaction, got {layer}")
  IO.println "PASS: modal_future -> interaction"

-- Temporal axioms
#eval do
  let layer := classifyAxiomLayer "serial_future"
  if layer != "temporal" then throw (IO.userError s!"Expected temporal, got {layer}")
  IO.println "PASS: serial_future -> temporal"

#eval do
  let layer := classifyAxiomLayer "connect_future"
  if layer != "temporal" then throw (IO.userError s!"Expected temporal, got {layer}")
  IO.println "PASS: connect_future -> temporal"

#eval do
  let layer := classifyAxiomLayer "density"
  if layer != "temporal" then throw (IO.userError s!"Expected temporal, got {layer}")
  IO.println "PASS: density -> temporal"

/-!
## Section 5: Tier Classification Boundaries
-/

-- Test tier boundary: 0 -> trivial
#eval do
  let t := InterestingnessTier.fromScore 0
  if t.toString != "trivial" then throw (IO.userError s!"Score 0: expected trivial, got {t}")
  IO.println "PASS: Score 0 -> trivial"

-- Test tier boundary: 49 -> trivial
#eval do
  let t := InterestingnessTier.fromScore 49
  if t.toString != "trivial" then throw (IO.userError s!"Score 49: expected trivial, got {t}")
  IO.println "PASS: Score 49 -> trivial"

-- Test tier boundary: 50 -> routine
#eval do
  let t := InterestingnessTier.fromScore 50
  if t.toString != "routine" then throw (IO.userError s!"Score 50: expected routine, got {t}")
  IO.println "PASS: Score 50 -> routine"

-- Test tier boundary: 150 -> basic
#eval do
  let t := InterestingnessTier.fromScore 150
  if t.toString != "basic" then throw (IO.userError s!"Score 150: expected basic, got {t}")
  IO.println "PASS: Score 150 -> basic"

-- Test tier boundary: 300 -> moderate
#eval do
  let t := InterestingnessTier.fromScore 300
  if t.toString != "moderate" then throw (IO.userError s!"Score 300: expected moderate, got {t}")
  IO.println "PASS: Score 300 -> moderate"

-- Test tier boundary: 500 -> notable
#eval do
  let t := InterestingnessTier.fromScore 500
  if t.toString != "notable" then throw (IO.userError s!"Score 500: expected notable, got {t}")
  IO.println "PASS: Score 500 -> notable"

-- Test tier boundary: 700 -> interesting
#eval do
  let t := InterestingnessTier.fromScore 700
  if t.toString != "interesting" then throw (IO.userError s!"Score 700: expected interesting, got {t}")
  IO.println "PASS: Score 700 -> interesting"

-- Test tier boundary: 850 -> remarkable
#eval do
  let t := InterestingnessTier.fromScore 850
  if t.toString != "remarkable" then throw (IO.userError s!"Score 850: expected remarkable, got {t}")
  IO.println "PASS: Score 850 -> remarkable"

-- Test tier boundary: 1000 -> remarkable
#eval do
  let t := InterestingnessTier.fromScore 1000
  if t.toString != "remarkable" then throw (IO.userError s!"Score 1000: expected remarkable, got {t}")
  IO.println "PASS: Score 1000 -> remarkable"

/-!
## Section 6: Composite Score Computation
-/

-- Trivial formula (ex_falso) should get score = 0
#eval do
  let result := computeInterestingness (.imp .bot p) none none
  if result.compositeScore != 0 then
    throw (IO.userError s!"Expected score=0 for ex_falso, got {result.compositeScore}")
  if result.tier != InterestingnessTier.trivial then
    throw (IO.userError s!"Expected tier=trivial for ex_falso, got {result.tier}")
  IO.println "PASS: ex_falso score=0, tier=trivial"

-- Identity should get score = 0
#eval do
  let result := computeInterestingness (.imp p p) none none
  if result.compositeScore != 0 then
    throw (IO.userError s!"Expected score=0 for identity, got {result.compositeScore}")
  IO.println "PASS: identity score=0"

-- Bimodal formula with proof data should get non-zero score
#eval do
  let φ := Formula.imp (.box p) (Formula.some_future p)
  let proofData : ProofData := {
    height := 5
    axioms_used := ["modal_future", "modal_t", "serial_future"]
    rules_applied := ["modus_ponens", "necessitation", "temporal_necessitation"]
  }
  let rp : RuleProfile := {
    axiomCount := 3
    assumptionCount := 0
    mpCount := 2
    necessitationCount := 1
    temporalNecessitationCount := 1
    temporalDualityCount := 0
    weakeningCount := 0
  }
  let result := computeInterestingness φ (some proofData) (some rp)
  if result.compositeScore == 0 then
    throw (IO.userError "Expected non-zero score for bimodal formula with proof data")
  if result.sntGate < 2 then
    throw (IO.userError s!"Expected SNT>=2 for bimodal, got {result.sntGate}")
  if !result.interactionAxiomDep then
    throw (IO.userError "Expected interaction axiom dependency for proof using modal_future")
  IO.println s!"PASS: bimodal score={result.compositeScore}, tier={result.tier}, snt={result.sntGate}, od={result.operatorDiversity}, ald={result.axiomLayerDiversity}"

/-!
## Section 7: JSON Serialization
-/

#eval do
  let result := computeInterestingness (.imp (.box p) (Formula.some_future p)) none none
  let json := result.toJson
  -- Check that JSON starts with { and contains key fields
  if !json.startsWith "{" then
    throw (IO.userError "JSON does not start with {")
  if json.length < 50 then
    throw (IO.userError s!"JSON too short ({json.length} chars), likely incomplete")
  -- Verify it contains expected keys by checking the prefix structure
  -- The toJson function has a fixed field order, so check the beginning
  if !json.startsWith "{\"composite_score\": " then
    throw (IO.userError "JSON does not start with composite_score field")
  IO.println s!"PASS: JSON serialization valid"
  IO.println s!"  JSON: {json}"

/-!
## Section 8: Modal-Temporal Interaction Detection
-/

-- Propositional formula should have no interaction
#eval do
  if modalTemporalInteraction (.imp p q) then
    throw (IO.userError "Expected no interaction for propositional formula")
  IO.println "PASS: propositional has no modal-temporal interaction"

-- Modal-only formula should have no interaction
#eval do
  if modalTemporalInteraction (.box p) then
    throw (IO.userError "Expected no interaction for modal-only formula")
  IO.println "PASS: modal-only has no modal-temporal interaction"

-- Bimodal formula should have interaction
#eval do
  if !modalTemporalInteraction (.imp (.box p) (Formula.some_future p)) then
    throw (IO.userError "Expected interaction for bimodal formula")
  IO.println "PASS: bimodal formula has modal-temporal interaction"

end BimodalTest.Automation.Interestingness
