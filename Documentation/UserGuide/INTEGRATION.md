# Logos Integration Guide

This document describes how to integrate Logos with the Model-Checker to create a comprehensive dual verification architecture for Logos.

## 1. Overview

Logos and Model-Checker form a **dual verification architecture** providing complementary syntactic and semantic verification:

```
┌─────────────────────────────────────────────────────────────┐
│              Dual Verification Architecture                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│      ┌───────────────┐                  ┌───────────┐      │
│      │ Logos  │◀────────────────▶│  Model-   │      │
│      │   (LEAN 4)    │  Formula         │  Checker  │      │
│      │               │  Exchange        │  (Python) │      │
│      └───────────────┘                  └───────────┘      │
│             │                                  │            │
│      Syntactic Proofs              Semantic Countermodels  │
│      (Proof Receipts)              (Validity Checking)     │
│                                                             │
│      Layer 0 (Core TM)             Hyperintensional        │
│      Implementation                Semantics               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Integration Points

| Component | Integration Type | Data Exchanged |
|-----------|------------------|----------------|
| Model-Checker | Bidirectional | Formulas, validity results, counterexamples |
| External Tools | Export | SMT-LIB format |

## 2. Model-Checker Integration

### Export to Model-Checker

Convert Logos formulas to Model-Checker format:

```lean
/-- Export formula to SMT-LIB format for model checking -/
def export_to_smt_lib (φ : Formula) : String :=
  match φ with
  | Formula.atom p => s!"(atom \"{p}\")"
  | Formula.bot => "(false)"
  | Formula.imp ψ χ => s!"(=> {export_to_smt_lib ψ} {export_to_smt_lib χ})"
  | Formula.box ψ => s!"(box {export_to_smt_lib ψ})"
  | Formula.all_past ψ => s!"(all-past {export_to_smt_lib ψ})"
  | Formula.all_future ψ => s!"(all-future {export_to_smt_lib ψ})"

/-- Export context and formula for validity check -/
def export_validity_query (Γ : Context) (φ : Formula) : String :=
  let premises := Γ.map export_to_smt_lib |>.intersperse " " |> String.join
  let conclusion := export_to_smt_lib φ
  s!"(check-validity (premises {premises}) (conclusion {conclusion}))"
```

### Import Validation Results

Parse results from Model-Checker:

```lean
/-- Result from model checker -/
inductive ModelCheckResult
  | valid                           -- Formula is valid
  | invalid (model : String)        -- Countermodel found
  | unknown (reason : String)       -- Could not determine

/-- Parse model checker response -/
def parse_model_check_result (response : String) : IO ModelCheckResult := do
  -- Parse JSON/SMT-LIB response format
  sorry
```

### Coordinated Verification

Combine proof search with model checking:

```lean
/-- Verify inference using both proof and model checking -/
def verify_inference (Γ : Context) (φ : Formula) :
  IO (Either String (Γ ⊢ φ)) := do

  -- First, try proof search
  match bounded_proof_search Γ φ 10 with
  | some proof => return Either.right proof
  | none =>
    -- If proof not found, check with model checker
    let query := export_validity_query Γ φ
    let mc_result ← call_model_checker query

    match mc_result with
    | ModelCheckResult.valid =>
      -- Model checker says valid, try deeper proof search
      match bounded_proof_search Γ φ 50 with
      | some proof => return Either.right proof
      | none => return Either.left "Valid but proof not found in depth limit"

    | ModelCheckResult.invalid model =>
      return Either.left s!"Invalid: countermodel = {model}"

    | ModelCheckResult.unknown reason =>
      return Either.left s!"Unknown: {reason}"
```

## 3. API Design

### Formula Exchange Interface

```lean
/-- Standard formula exchange format -/
structure FormulaExchange where
  version : String := "1.0"
  format : String := "tm-logic"
  formula : Formula

/-- Serialize formula for exchange -/
def FormulaExchange.serialize (fe : FormulaExchange) : String :=
  s!"\{\"version\":\"{fe.version}\",\"format\":\"{fe.format}\",\"formula\":{serialize_formula fe.formula}\}"

/-- Deserialize formula from exchange format -/
def FormulaExchange.deserialize (s : String) : Option FormulaExchange :=
  sorry -- JSON parsing
```

### Generic Inference API

Logos provides a generic inference verification API for external tools:

```lean
/-- Generic inference verification request -/
structure InferenceRequest where
  request_id : String
  premises : List Formula
  conclusion : Formula
  timeout_ms : Option Nat := none
  depth_limit : Option Nat := none

/-- Inference verification response -/
structure InferenceResponse where
  request_id : String
  status : InferenceStatus
  proof : Option String  -- Serialized proof if found
  countermodel : Option String  -- If invalid (from Model-Checker)
  duration_ms : Nat

inductive InferenceStatus
  | valid_proof        -- Proof found
  | valid_no_proof     -- Valid but proof not constructed
  | invalid            -- Countermodel found (via Model-Checker)
  | timeout            -- Timed out
  | error (msg : String)
```

### API Endpoints (Conceptual)

```lean
/-- Verify single inference -/
def api_verify_inference (req : InferenceRequest) : IO InferenceResponse := do
  let start_time ← IO.monoMsNow

  let result ← verify_inference req.premises req.conclusion
  let end_time ← IO.monoMsNow

  match result with
  | Either.right proof =>
    return {
      request_id := req.request_id,
      status := InferenceStatus.valid_proof,
      proof := some (serialize_proof proof),
      countermodel := none,
      duration_ms := end_time - start_time
    }
  | Either.left msg =>
    return {
      request_id := req.request_id,
      status := InferenceStatus.error msg,
      proof := none,
      countermodel := none,
      duration_ms := end_time - start_time
    }

/-- Check validity of formula -/
def api_check_validity (φ : Formula) : IO Bool := do
  let result ← verify_inference [] φ
  return result.isRight

/-- Check satisfiability of context -/
def api_check_satisfiability (Γ : Context) : IO Bool := do
  -- Check if Γ ∪ {¬φ} is consistent for some φ
  sorry
```

## 4. Extension Points

### Layer 1-3 Operator Extensions

Logos's layered architecture supports extensions:

```lean
/-- Layer 1: Explanatory operators -/
inductive ExtendedFormula : Type
  | core : Formula → ExtendedFormula
  | boxright : ExtendedFormula → ExtendedFormula → ExtendedFormula  -- □→
  | ground : ExtendedFormula → ExtendedFormula → ExtendedFormula    -- ≤
  | cause : ExtendedFormula → ExtendedFormula → ExtendedFormula     -- ○→

/-- Export extended formula -/
def export_extended (φ : ExtendedFormula) : String :=
  match φ with
  | ExtendedFormula.core ψ => export_to_smt_lib ψ
  | ExtendedFormula.boxright ψ χ =>
    s!"(boxright {export_extended ψ} {export_extended χ})"
  | ExtendedFormula.ground ψ χ =>
    s!"(ground {export_extended ψ} {export_extended χ})"
  | ExtendedFormula.cause ψ χ =>
    s!"(cause {export_extended ψ} {export_extended χ})"
```

### Custom Operator Integration

To add custom operators:

1. Define operator in `Syntax/` module
2. Add axioms in `ProofSystem/`
3. Define semantics in `Semantics/`
4. Update export/import functions
5. Add tests

```lean
/-- Example: Adding a custom operator -/
-- 1. Syntax extension (in Syntax/Formula.lean)
inductive Formula
  | ...existing...
  | custom_op : Formula → Formula  -- New operator

-- 2. Axiom extension (in ProofSystem/Axioms.lean)
inductive Axiom : Formula → Prop
  | ...existing...
  | custom_axiom (φ : Formula) : Axiom (custom_op φ).imp φ

-- 3. Semantic extension (in Semantics/Truth.lean)
def truth_at : ... → Formula → Prop
  | ...existing cases...
  | Formula.custom_op φ => -- Define truth condition

-- 4. Export extension
def export_to_smt_lib : Formula → String
  | ...existing cases...
  | Formula.custom_op φ => s!"(custom-op {export_to_smt_lib φ})"
```

### Semantic Extension

Extend task semantics for new operators:

```lean
/-- Extended task model with selection functions -/
structure ExtendedTaskModel (F : TaskFrame) extends TaskModel F where
  -- Counterfactual selection function
  selection : F.WorldState → Formula → Set (WorldHistory F)

  -- Selection function constraints
  centering : ∀ w φ, (canonical_history w) ∈ selection w φ
  success : ∀ w φ σ, σ ∈ selection w φ → satisfies σ φ
```

## 5. Versioning and Compatibility

### Semantic Versioning

Logos uses semantic versioning:

- **MAJOR**: Breaking API changes
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes

### Compatibility Matrix

| Logos | Model-Checker |
|--------------|---------------|
| 0.1.x | 1.0.x, 1.1.x, 1.2.x |
| 0.2.x | 1.2.x+ |

### Migration Guide

When upgrading:

1. Check compatibility matrix
2. Review CHANGELOG for breaking changes
3. Update import/export functions if format changed
4. Run integration tests
5. Update dependent components

## 6. Error Handling

### Error Types

```lean
/-- Integration error types -/
inductive IntegrationError
  | parse_error (msg : String)
  | serialization_error (msg : String)
  | timeout
  | invalid_format (expected : String) (got : String)
  | version_mismatch (expected : String) (got : String)
  | connection_error (msg : String)
```

### Error Handling Pattern

```lean
/-- Handle integration errors -/
def handle_integration_error (e : IntegrationError) : IO Unit := do
  match e with
  | IntegrationError.parse_error msg =>
    IO.eprintln s!"Parse error: {msg}"
  | IntegrationError.timeout =>
    IO.eprintln "Operation timed out"
  | IntegrationError.version_mismatch expected got =>
    IO.eprintln s!"Version mismatch: expected {expected}, got {got}"
  | _ =>
    IO.eprintln s!"Integration error: {e}"
```

## 7. Testing Integration

### Integration Test Setup

```lean
-- LogosTest/Integration/ModelCheckerTest.lean

/-- Test round-trip serialization -/
example (φ : Formula) : deserialize (serialize φ) = some φ := by
  sorry

/-- Test export produces valid SMT-LIB -/
example (φ : Formula) : valid_smt_lib (export_to_smt_lib φ) := by
  sorry

/-- Test inference request handling -/
example : verify_inference [p, p.imp q] q = valid_proof := by
  sorry
```

### Mock Model-Checker

For testing without full Model-Checker:

```lean
/-- Mock model checker for testing -/
def mock_model_checker (query : String) : IO ModelCheckResult := do
  -- Simple validity check based on formula structure
  if query.containsSubstr "box" && query.containsSubstr "imp" then
    return ModelCheckResult.valid
  else
    return ModelCheckResult.unknown "mock"
```

## References

- [Architecture Guide](ARCHITECTURE.md) - Full system design
- [Tutorial](TUTORIAL.md) - Getting started
- [Examples](EXAMPLES.md) - Usage examples
- [Versioning](../Development/VERSIONING.md) - Version policy
