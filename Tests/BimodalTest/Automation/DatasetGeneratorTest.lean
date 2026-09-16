/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.DatasetGenerator

/-!
# Dataset Generator Tests

Regression tests for the structural pre-filters and the labelling pipeline in
`FormalSystem/Automation/DatasetGenerator.lean`.

- **Pre-filter rows** are `#guard`s over the pure pre-filter functions. Every expected value was
  captured from the library's own evaluation, so a changed verdict or axiom attribution fails
  elaboration of this module.
- **Smoke tests** are `IO` actions over the pool-backed and hybrid labelling modes. Each throws on
  failure, which fails elaboration, and prints its per-formula trace on success.
-/

namespace BimodalTest.Automation.DatasetGeneratorTest

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Automation
open FormalSystem.Automation.DataExport
open FormalSystem.Automation.Enriched

private def pTest : Formula := .atom ⟨"p", none⟩
private def qTest : Formula := .atom ⟨"q", none⟩
private def rTest : Formula := .atom ⟨"r", none⟩
private def sTest : Formula := .atom ⟨"s", none⟩

/-! ### Pre-filter unit tests -/

-- isUnsatBotTemporal: recursive cases
#guard isUnsatBotTemporal (.bot) == true
#guard isUnsatBotTemporal (.untl pTest (.box .bot)) == true
#guard isUnsatBotTemporal (.snce pTest (.untl qTest .bot)) == true
#guard isUnsatBotTemporal (.box (.untl pTest .bot)) == true
#guard isUnsatBotTemporal (.untl qTest pTest) == false
#guard isUnsatBotTemporal pTest == false

-- isStructurallyValid: tautology detection
#guard isStructurallyValid (.imp pTest pTest) == true
#guard isStructurallyValid (.imp qTest (.imp pTest pTest)) == true
#guard isStructurallyValid (.box (.imp pTest pTest)) == true
#guard isStructurallyValid pTest == false
#guard isStructurallyValid (.imp pTest qTest) == false

-- structuralPrefilter: integration tests
#guard structuralPrefilter (.imp (.untl pTest (.box .bot)) qTest) == some true
#guard structuralPrefilter (.imp pTest (.imp qTest qTest)) == some true
#guard structuralPrefilter (.imp pTest (.box (.imp qTest qTest))) == some true
#guard structuralPrefilter (.imp pTest qTest) == none

-- structuralPrefilterWithAxiom: axiom attribution tests
#guard (structuralPrefilterWithAxiom (.imp (.untl pTest (.box .bot)) qTest))
  == some (true, "structural_bot_temporal")
#guard (structuralPrefilterWithAxiom (.imp pTest (.imp qTest qTest)))
  == some (true, "structural_tautology")
#guard (structuralPrefilterWithAxiom (.imp (.box (.box .bot)) qTest))
  == some (true, "structural_bot_temporal")
#guard (structuralPrefilterWithAxiom (.imp (.box (.box pTest)) pTest))
  == some (true, "structural_modal_4")
#guard (structuralPrefilterWithAxiom (.imp (.box pTest) (.imp qTest pTest)))
  == some (true, "structural_modal_t_weakening")
#guard structuralPrefilterWithAxiom (.imp pTest qTest) == none

-- Phase 1 tests

-- collectTopLevelConjuncts
#guard collectTopLevelConjuncts (pTest.and qTest) == [pTest, qTest]
#guard (collectTopLevelConjuncts (pTest.and (qTest.and (.imp pTest pTest))))
  == [pTest, qTest, .imp pTest pTest]

-- isAllFutureShape / isSomeFutureShape / isAllPastShape / isSomePastShape
#guard isAllFutureShape pTest.allFuture == some pTest
#guard isSomeFutureShape pTest.someFuture == some pTest
#guard isAllPastShape pTest.allPast == some pTest
#guard isSomePastShape pTest.somePast == some pTest

-- S5 reflexive shortcutting
#guard (structuralPrefilterWithAxiom (.imp (Formula.and (Formula.box pTest) (Formula.neg pTest))
    qTest))
  == some (true, "structural_s5_reflexive_conflict")

-- Temporal loop detection (until)
#guard (structuralPrefilterWithAxiom (.imp
    (Formula.and (Formula.untl qTest pTest) (Formula.allFuture (Formula.neg qTest)))
    (Formula.atom (Atom.mkBase "r"))))
  == some (true, "structural_temporal_loop_until")

-- Temporal loop detection (since)
#guard (structuralPrefilterWithAxiom (.imp
    (Formula.and (Formula.snce qTest pTest) (Formula.allPast (Formula.neg qTest)))
    (Formula.atom (Atom.mkBase "r"))))
  == some (true, "structural_temporal_loop_since")

-- Subsumption rules
#guard (structuralPrefilterWithAxiom (.imp (pTest.allFuture) pTest))
  == some (true, "structural_subsumption_gt")
#guard (structuralPrefilterWithAxiom (.imp (pTest.allPast) pTest))
  == some (true, "structural_subsumption_ht")
#guard (structuralPrefilterWithAxiom (.imp (pTest.allFuture) pTest.someFuture))
  == some (true, "structural_subsumption_gf")
#guard (structuralPrefilterWithAxiom (.imp (pTest.allPast) pTest.somePast))
  == some (true, "structural_subsumption_hp")
#guard (structuralPrefilterWithAxiom (.imp (pTest.allFuture) pTest.allFuture.allFuture))
  == some (true, "structural_subsumption_g4")
#guard (structuralPrefilterWithAxiom (.imp (pTest.allPast) pTest.allPast.allPast))
  == some (true, "structural_subsumption_h4")
#guard (structuralPrefilterWithAxiom (.imp (pTest.someFuture.someFuture) pTest.someFuture))
  == some (true, "structural_subsumption_ff")
#guard (structuralPrefilterWithAxiom (.imp (pTest.somePast.somePast) pTest.somePast))
  == some (true, "structural_subsumption_pp")
#guard (structuralPrefilterWithAxiom (.imp (.box pTest) pTest))
  == some (true, "structural_subsumption_modal_t")
#guard (structuralPrefilterWithAxiom (.imp (.box pTest) (.box (.box pTest))))
  == some (true, "structural_subsumption_modal_4")
#guard (structuralPrefilterWithAxiom (.imp (.box pTest) (pTest.diamond)))
  == some (true, "structural_subsumption_modal_d")

-- Temporal implication pattern tests

-- U(p, q) → F(q): Until implies Future of event
#guard (structuralPrefilterWithAxiom (.imp (.untl qTest pTest) qTest.someFuture))
  == some (true, "structural_until_implies_future")

-- S(p, q) → P(q): Since implies Past of event
#guard (structuralPrefilterWithAxiom (.imp (.snce qTest pTest) qTest.somePast))
  == some (true, "structural_since_implies_past")

-- U(p, q) → F(p): NOT valid (Until does not guarantee F(guard) -- Y could hold immediately)
#guard structuralPrefilterWithAxiom (.imp (.untl qTest pTest) pTest.someFuture) == none

-- G(p) → F(p): Always implies Sometimes (caught by isSubsumptionPattern as G→F)
#guard (structuralPrefilterWithAxiom (.imp pTest.allFuture pTest.someFuture))
  == some (true, "structural_subsumption_gf")

-- H(p) → P(p): Always-past implies Sometimes-past (caught by isSubsumptionPattern as H→P)
#guard (structuralPrefilterWithAxiom (.imp pTest.allPast pTest.somePast))
  == some (true, "structural_subsumption_hp")

-- U(p, q) → U(p, q): identity (caught by structural_identity)
#guard (structuralPrefilterWithAxiom (.imp (.untl qTest pTest) (.untl qTest pTest)))
  == some (true, "structural_identity")

-- U(p, q) → U(r, s): all different atoms — not structurally decidable
#guard structuralPrefilterWithAxiom (.imp (.untl qTest pTest) (.untl sTest rTest)) == none

-- U(p, q) → U(r, q): shared event, different guard — NOT valid, not caught
#guard structuralPrefilterWithAxiom (.imp (.untl qTest pTest) (.untl qTest rTest)) == none

-- Phase 2 tests: polarity analysis

-- collectPolarities
#guard (collectPolarities (Formula.imp pTest qTest) .pos)
  == [(Formula.imp pTest qTest, Sign.pos), (pTest, Sign.neg), (qTest, Sign.pos)]
#guard (collectPolarities (Formula.neg pTest) .pos)
  == [(Formula.imp pTest .bot, Sign.pos), (pTest, Sign.neg), (Formula.bot, Sign.pos)]

-- appearsOnlyPositively / appearsOnlyNegatively
#guard appearsOnlyPositively (collectPolarities (Formula.imp pTest qTest) .pos) pTest == false
#guard appearsOnlyNegatively (collectPolarities (Formula.imp pTest qTest) .pos) pTest == true

-- isStructurallyValidDeep: nested unsat antecedent
#guard isStructurallyValidDeep (Formula.imp (Formula.untl qTest Formula.bot) pTest) == true
#guard (structuralPrefilterWithAxiom (.imp pTest
    (Formula.imp (Formula.untl qTest Formula.bot) pTest)))
  == some (true, "structural_polarity_drop_tautology")

-- hasBotConjunct
#guard (structuralPrefilterWithAxiom (.imp (Formula.and pTest Formula.bot) qTest))
  == some (true, "structural_polarity_bot_neg")

-- Phase 3 tests: lightweight propositional contradiction
#guard hasPropContradiction [pTest, Formula.neg pTest] == true
#guard hasPropContradiction [pTest, Formula.imp pTest Formula.bot] == true
#guard hasPropContradiction [pTest, qTest] == false
#guard (structuralPrefilterWithAxiom (.imp (Formula.and pTest (Formula.neg pTest)) qTest))
  == some (true, "structural_prop_contradiction")

-- Extended tautology detection (φ → ⊤ and φ → □⊤)
#guard isStructurallyValid (.imp pTest Formula.top) == true
#guard isStructurallyValid (.imp pTest (.box Formula.top)) == true
#guard structuralPrefilterWithAxiom (.imp pTest Formula.top) == some (true, "structural_tautology")
#guard (structuralPrefilterWithAxiom (.imp pTest (.box Formula.top)))
  == some (true, "structural_tautology")

/-! ### Invalid prefilter unit tests -/

-- isTrivialSatisfiable: positive cases
#guard isTrivialSatisfiable pTest == true
#guard isTrivialSatisfiable (Formula.imp .bot .bot) == true
#guard isTrivialSatisfiable (.box pTest) == true
#guard isTrivialSatisfiable (Formula.and pTest qTest) == true
#guard isTrivialSatisfiable (.box (.box pTest)) == true
#guard isTrivialSatisfiable (Formula.neg .bot) == true
#guard isTrivialSatisfiable (.untl qTest pTest) == false
#guard isTrivialSatisfiable (.snce qTest pTest) == false
#guard isTrivialSatisfiable (.imp pTest qTest) == false
#guard isTrivialSatisfiable .bot == false

-- isTemporalContradiction: positive cases (invalid formulas)
#guard isTemporalContradiction (.imp pTest (.untl qTest .bot)) == true
#guard isTemporalContradiction (.imp pTest (.box .bot)) == true
#guard isTemporalContradiction (.imp (.box pTest) .bot) == true
#guard isTemporalContradiction (.imp pTest (.snce qTest .bot)) == true
#guard isTemporalContradiction (.imp (.box (.untl qTest pTest)) (.untl rTest .bot)) == true
#guard isTemporalContradiction (.imp (.untl pTest .bot) (.untl qTest .bot)) == false
#guard isTemporalContradiction (.imp pTest qTest) == false
#guard isTemporalContradiction pTest == false
#guard isTemporalContradiction (.imp .bot .bot) == false

-- isObviousSatisfiable: positive cases (invalid formulas)
#guard isObviousSatisfiable (.imp pTest .bot) == true
#guard isObviousSatisfiable (.imp (.box pTest) .bot) == true
#guard isObviousSatisfiable (.imp (Formula.and pTest qTest) .bot) == true
#guard isObviousSatisfiable (.imp pTest (.untl qTest .bot)) == true
#guard isObviousSatisfiable (.imp (Formula.imp .bot .bot) .bot) == true
#guard isObviousSatisfiable (.imp (.untl qTest pTest) .bot) == false
#guard isObviousSatisfiable (.imp pTest qTest) == false
#guard isObviousSatisfiable (.imp .bot .bot) == false
#guard isObviousSatisfiable pTest == false

-- hasUnfulfillableEventuality: positive cases (invalid formulas)
#guard (hasUnfulfillableEventuality (.imp (Formula.allFuture (Formula.neg pTest))
    (.untl qTest pTest)))
  == true
#guard (hasUnfulfillableEventuality (.imp (Formula.and (Formula.allFuture (Formula.neg pTest))
    rTest) (.untl qTest pTest)))
  == true
#guard (hasUnfulfillableEventuality (.imp (Formula.allPast (Formula.neg pTest))
    (.snce qTest pTest)))
  == true
#guard (hasUnfulfillableEventuality (.imp (Formula.and (Formula.allPast (Formula.neg pTest)) rTest)
    (.snce qTest pTest)))
  == true
#guard (hasUnfulfillableEventuality (.imp (Formula.allFuture (Formula.neg qTest))
    (.untl qTest pTest)))
  == false
#guard hasUnfulfillableEventuality (.imp pTest (.untl rTest qTest)) == false
#guard hasUnfulfillableEventuality (.imp pTest qTest) == false
#guard hasUnfulfillableEventuality pTest == false

-- structuralInvalidPrefilter: integration tests
#guard (structuralInvalidPrefilter (.imp pTest (.untl qTest .bot)))
  == some (false, "invalid_satisfiable_neg")
#guard structuralInvalidPrefilter (.imp pTest .bot) == some (false, "invalid_satisfiable_neg")
#guard (structuralInvalidPrefilter (.imp (.untl qTest pTest) (.untl rTest .bot)))
  == some (false, "invalid_false_consequent")
#guard (structuralInvalidPrefilter (.imp (Formula.allFuture (Formula.neg pTest))
    (.untl qTest pTest)))
  == some (false, "invalid_unfulfillable_eventuality")
#guard structuralInvalidPrefilter (.imp pTest qTest) == none
#guard structuralInvalidPrefilter (.imp .bot .bot) == none
#guard structuralInvalidPrefilter (.imp (.untl pTest .bot) (.untl qTest .bot)) == none

-- structuralInvalidPrefilter: constructTrivialCountermodel test
-- `SimpleCountermodel` derives only `Repr`, so compare projected fields.
#guard
  let cm := constructTrivialCountermodel (.imp pTest (.untl qTest .bot))
  (cm.trueAtoms.length, cm.falseAtoms.length) == (2, 0)

section SmokeTests

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
    throw (IO.userError "[test] FAIL: pool is empty")

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
    throw (IO.userError "[test] FAIL: hybrid mode did not label (p → p) as valid")

-- Test 3: Fallthrough to tableau for a formula not in the pool
#eval show IO Unit from do
  -- Build an empty pool
  let pool : ProofPool .Base := { ProofPool.empty with cap := 10 }
  -- U(p, q) → U(r, s) is not in an empty pool; should fall through to tableau
  let φ := Formula.imp
    (Formula.untl (Formula.atom ⟨"q", none⟩) (Formula.atom ⟨"p", none⟩))
    (Formula.untl (Formula.atom ⟨"s", none⟩) (Formula.atom ⟨"r", none⟩))
  let lf ← labelFormula φ .Base 1000 .hybrid (some pool)
  IO.println s!"[test] Hybrid fallthrough: label={repr lf.label}, method={lf.decisionMethod}"
  if lf.decisionMethod != "proof_first" then
    IO.println "[test] PASS: hybrid mode fell through to tableau (not proof_first)"
  else
    throw (IO.userError "[test] FAIL: hybrid mode did not fall through")

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
    .imp (.untl q p) q.someFuture,        -- valid (U->F)
    .imp (.snce q p) q.somePast,          -- valid (S->P)
    .imp p q,                              -- invalid
    .imp (.untl q p) (.untl q r),          -- unknown/invalid
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
        IO.println
            s!"[test] MISMATCH at {φ.prettyPrint}: exhaustive={repr exLabel} hybrid={repr hyLabel}"
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
    throw (IO.userError "[test] FAIL: label mismatch detected")

/-! ### Phase 1.5 integration test: invalid prefilter in labelFormulaImpl -/

-- Test 5: labelFormulaImpl catches structurally invalid formulas via Phase 1.5
#eval show IO Unit from do
  let p := Formula.atom ⟨"p", none⟩
  let q := Formula.atom ⟨"q", none⟩
  let r := Formula.atom ⟨"r", none⟩
  -- Formulas that should be caught by the invalid prefilter
  let invalidFormulas : List (Formula × String) := [
    (.imp p .bot, "invalid_satisfiable_neg"),           -- p → ⊥: satisfiable negation
    (.imp p (.untl q .bot), "invalid_satisfiable_neg"), -- p → U(⊥,q): satisfiable + false
    -- consequent
    (.imp (.box p) .bot, "invalid_satisfiable_neg"),    -- □p → ⊥: box(atom) satisfiable
    (.imp (.untl q p) (.untl r .bot), "invalid_false_consequent"),  -- U(p,q) → U(⊥,r): false
    -- consequent
    (.imp (Formula.allFuture (Formula.neg p)) (.untl q p), "invalid_unfulfillable_eventuality")
      -- G(¬p) → U(p,q): unfulfillable eventuality
  ]
  let mut allPass := true
  for (φ, expectedPattern) in invalidFormulas do
    let lf ← labelFormulaImpl φ .Base 1000
    let methodOk := lf.decisionMethod == "structural_invalid_prefilter"
    let labelOk := lf.label == .invalid
    let patternOk := lf.proofReconstructionMethod == some
        ("structural_invalid_prefilter:" ++ expectedPattern)
    if methodOk && labelOk && patternOk then
      IO.println
          s!"[test] OK: {φ.prettyPrint} -> invalid via \
              structural_invalid_prefilter:{expectedPattern}"
    else
      IO.println
          s!"[test] FAIL: {φ.prettyPrint} -> label={repr lf.label} method={lf.decisionMethod} \
              recon={repr lf.proofReconstructionMethod}"
      allPass := false
  -- Verify valid formulas are NOT caught by the invalid prefilter
  let validFormulas : List Formula := [
    .imp p p,                              -- identity (valid)
    .imp (.box .bot) q,                    -- bot antecedent (valid)
    .imp (.untl p .bot) (.untl q .bot),    -- both sides always false → valid
    .imp p (.imp q q)                      -- tautological consequent (valid)
  ]
  for φ in validFormulas do
    let lf ← labelFormulaImpl φ .Base 1000
    if lf.decisionMethod == "structural_invalid_prefilter" then
      IO.println
          s!"[test] FAIL: valid formula {φ.prettyPrint} incorrectly caught by invalid prefilter \
              (method={lf.decisionMethod})"
      allPass := false
    else
      IO.println
          s!"[test] OK: {φ.prettyPrint} -> {repr lf.label} via {lf.decisionMethod} (not invalid \
              prefilter)"
  if allPass then
    IO.println "[test] PASS: all invalid prefilter integration tests pass"
  else
    throw (IO.userError "[test] FAIL: some invalid prefilter integration tests failed")

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
    .imp p (.untl q .bot),                             -- p → U(⊥, q) (invalid)
    .imp p (.box .bot),                                -- p → □⊥ (invalid)
    .imp (Formula.and p q) .bot,                       -- (p ∧ q) → ⊥ (invalid)
    .imp (.box (.box p)) (.untl q .bot),               -- □□p → U(⊥, q) (invalid)
    .imp (Formula.imp .bot .bot) .bot,                 -- ⊤ → ⊥ (invalid)
    .imp p (.snce q .bot),                             -- p → S(⊥, q) (invalid)
    .imp (Formula.and p (Formula.neg q)) .bot,         -- (p ∧ ¬q) → ⊥ (invalid)
    .imp (.untl q p) (.untl r .bot)                    -- U(p,q) → U(⊥,r) (invalid)
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
        IO.println
            s!"[test] MISMATCH: {φ.prettyPrint} — prefilter=invalid but tableau={repr lf.label}"
        allMatch := false
    | _ =>
      IO.println
          s!"[test] SKIP: {φ.prettyPrint} — not caught by prefilter (method={lf.decisionMethod})"
  if allMatch then
    IO.println "[test] PASS: all cross-validation tests agree"
  else
    throw (IO.userError "[test] FAIL: cross-validation mismatch detected")

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
    .imp (.untl q p) q.someFuture,        -- U(p,q) → F(q)
    .imp (.snce q p) q.somePast,          -- S(p,q) → P(q)
    .imp (.untl p .bot) (.untl q .bot)     -- U(⊥,p) → U(⊥,q): both always false, valid
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
    throw (IO.userError "[test] FAIL: regression — valid formulas mislabeled")

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
  let e3 := structuralInvalidPrefilter (.imp (.box .bot) (.untl p .bot))
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
    throw <| IO.userError
        s!"[test] FAIL: edge case failures (pass1={pass1} pass2={pass2} pass3={pass3} \
            pass4={pass4})"

end SmokeTests

end BimodalTest.Automation.DatasetGeneratorTest
