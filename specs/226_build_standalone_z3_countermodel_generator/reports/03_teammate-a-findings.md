# Teammate A Findings (Round 3): Positive Signal Interface for BimodalLogic

**Task**: 226 — Redesign: BimodalLogic as positive-signal provider in dual verification architecture
**Date**: 2026-05-30
**Angle**: What BimodalLogic needs to implement the VerifierProvider interface
**Confidence Level**: High

## Key Findings

### 1. BimodalLogic Already Has Most of the Positive-Signal Infrastructure

The existing Lean codebase provides a mature data export pipeline:

| Component | File | Status | What It Does |
|-----------|------|--------|-------------|
| Formula JSON serialization | `DataExport.lean` | Complete | 6-tag JSON schema (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) — exact format expected by BimodalHarness |
| ProofTrace extraction | `DatasetGenerator.lean:55-62,193-229` | Complete | Extracts height, axiom names, rule names from `DerivationTree` |
| RuleProfile counting | `DataExport.lean:289-364` | Complete | Counts all 7 rule types across a derivation tree |
| LabeledFormula pipeline | `DatasetGenerator.lean:101-114,258-316` | Complete | End-to-end: formula → `decideAuto` → labeled record with proof trace + countermodel |
| Dataset generation executable | `lake exe dataset_generator` | Complete | Generates JSONL datasets at configurable complexity tiers |
| Proof step extraction executable | `lake exe proof_extractor` | Complete | Extracts step-by-step proof data for policy network training |
| Dataset validation | `lake exe dataset_validator` | Complete | Validates JSONL data and individual proof claims |

**Existing datasets:**
- `data/bmlogic-bench.jsonl`: 387 formulas with fields: `id`, `formula_ast`, `label`, `proof_trace`, `countermodel`, `pattern_key`, `metrics`, etc.
- `data/proof_steps.jsonl`: 2,424 proof step records with fields: `theorem_name`, `step_index`, `context`, `goal`, `rule`, `axiom_name`, `subgoals`, `frame_class`
- `data/bmlogic-c5.jsonl` / `bmlogic-c7.jsonl`: Full enumerated datasets at complexity 5 and 7

### 2. The VerifierProvider Protocol Requires 5 Properties + 3 Methods

From BimodalHarness `verifier/protocol.py`:

**Properties:**
- `provider_id: str` — e.g., `"bmlogic_lean_verifier_v1"`
- `provider_version: str` — semver
- `semantics_version: str` — pinned to BimodalLogic version
- `supported_frame_classes: frozenset[str]` — `{"Base"}` only for now
- `capabilities: dict[str, Any]`

**Methods:**
- `verify_formula(formula_json, frame_class="Base", timeout_ms=5000) -> VerificationResult | None` — returns proof result or None
- `extract_proof_steps(formula_json, frame_class="Base", timeout_ms=5000) -> list[dict] | None` — step-level training data
- `validate_self(spot_check_formulas) -> bool` — self-check against known-valid formulas

**VerificationResult** (from `verifier/types.py`):
```python
@dataclass(frozen=True, slots=True)
class VerificationResult:
    formula_json: dict[str, Any]
    proof_steps: list[dict[str, Any]] | None = None
    proof_depth: int = 0
    proof_certificate: str | None = None
```

### 3. Gap Analysis: What's Missing for VerifierProvider

| Requirement | Existing | Missing |
|-------------|----------|---------|
| Formula JSON → decision result | `lake exe dataset_generator` processes formulas | No programmatic single-formula API — only batch via `lake exe` |
| ProofTrace → VerificationResult | `DatasetGenerator.extractProofTrace` | Translation layer: Lean ProofTrace → Python VerificationResult dict |
| Proof step extraction | `lake exe proof_extractor` extracts step data | Step data format needs mapping to BimodalHarness `ProofStepRecord` schema |
| Single-formula verification | `decideAuto φ` in Lean | Need a `lake exe verify_formula` command taking JSON stdin or args |
| Python wrapper | None | Need a `LeanVerifierProvider` class that subprocess-calls `lake exe` |
| pyproject.toml + entry point | None (this is a Lean repo) | Need a thin Python package (`bmlogic-verifier`) with entry point registration |
| validate_self | None | Need to identify 10 known-valid formulas as spot-checks |

### 4. BimodalHarness Already Consumes Lean Output — But Ad-Hoc

From `bimodal_harness/data/ingestion.py`:
- `load_labeled_formulas()` reads JSONL files directly (hardcoded paths)
- `load_proof_steps()` reads proof_steps.jsonl directly
- `bimodal_harness/config.py` has a `LEAN_TIMEOUT` for `lake exe` subprocess

From `bimodal_harness/verifier/gateway.py`:
- Already references `lake exe dataset_validator --mode validate-proof`
- Already designed to call Lean subprocess for proof validation

The ad-hoc `ingestion.py` approach is being replaced by the `VerifierProvider` protocol (BimodalHarness task 28). BimodalLogic needs to provide the provider implementation.

### 5. Proposed Architecture: `bmlogic-verifier` Python Package

```
BimodalLogic/
├── Theories/Bimodal/        # Lean codebase (unchanged)
├── verifier/                # NEW: Python package for VerifierProvider
│   ├── pyproject.toml       # bmlogic-verifier, entry point registration
│   ├── src/bmlogic_verifier/
│   │   ├── __init__.py
│   │   ├── provider.py      # LeanVerifierProvider implementing protocol
│   │   ├── subprocess.py    # Lean subprocess management (lake exe)
│   │   └── types.py         # Local type helpers
│   └── tests/
│       └── test_provider.py
├── data/                    # Existing dataset exports
└── scripts/                 # Existing Python scripts
```

**Entry point registration:**
```toml
[project.entry-points.'bimodal_harness.verifier_providers']
lean_base = "bmlogic_verifier.provider:LeanVerifierProvider"
```

### 6. Lean-Side Enhancement Needed: Single-Formula Verification Executable

Currently `lake exe dataset_generator` batch-processes all enumerated formulas. For the VerifierProvider's `verify_formula()` method, we need a single-formula endpoint:

```
# Proposed: lake exe verify_formula -- --formula '{"tag":"imp","left":...}' --frame-class Base --timeout 5000
```

This would:
1. Parse the formula JSON from args or stdin
2. Call `decideAuto` on the formula
3. Output a JSON result:
   ```json
   {"status": "valid", "proof_trace": {"height": 3, "axioms_used": [...], "rules_applied": [...]}, "proof_depth": 3}
   ```
   or `{"status": "invalid", "countermodel": {...}}` or `{"status": "timeout"}`

The `LeanVerifierProvider.verify_formula()` Python method would subprocess-call this executable.

### 7. Proof Step Extraction Already Matches BimodalHarness Format

The existing `proof_steps.jsonl` has exactly the fields BimodalHarness expects:
- `theorem_name` → provenance tracking
- `step_index` → ordering within proof
- `context` → antecedent formulas (JSON arrays)
- `goal` → formula JSON (6-tag)
- `rule` → inference rule name (modus_ponens, necessitation, etc.)
- `axiom_name` → axiom schema name if rule is axiom
- `subgoals` → resulting formulas after rule application
- `frame_class` → "Base"

This maps directly to the `extract_proof_steps()` return format. The only gap is that `proof_extractor` currently outputs to a file; the verifier provider needs a per-formula extraction path.

## Recommended Approach: Tasks for BimodalLogic

### Task A: Create `lake exe verify_formula` single-formula verification endpoint (~4 hours, lean4 task)
- New Lean executable that takes formula JSON via args/stdin
- Calls `decideAuto`, outputs JSON result (proof trace or countermodel or timeout)
- Handles timeout_ms parameter
- This is the Lean-side bridge for the Python VerifierProvider

### Task B: Create `bmlogic-verifier` Python package (~6 hours, python task)
- `verifier/pyproject.toml` with entry point registration
- `LeanVerifierProvider` class implementing `VerifierProvider` protocol
- Subprocess management for `lake exe verify_formula`
- Lean repo path discovery (env var or config)
- Tests against known formulas

### Task C: Enhance proof step extraction for per-formula queries (~4 hours, lean4 task)
- Extend `proof_extractor` or create new command to accept single formula JSON
- Output proof steps matching `extract_proof_steps()` return format
- Enable the `LeanVerifierProvider.extract_proof_steps()` method

### Task D: Cross-signal conformance testing (~4 hours, python task)
- Script that runs both oracle and verifier on benchmark formulas
- Verifies no formula gets both proof AND countermodel
- Implements the "cross-signal consistency check" from BimodalHarness task 28

### Task E: Lean soundness of bounded finite models (~12 hours, lean4 task)
- Prove FiniteTaskFrame satisfying Z3 constraints → valid TaskFrame
- Prove bounded truth evaluation faithful to truth_at
- This was already planned in the Round 2 research; still relevant

## Evidence/Examples

| Source | Reference |
|--------|-----------|
| VerifierProvider protocol | `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/verifier/protocol.py` |
| VerificationResult type | `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/verifier/types.py:19-42` |
| DataExport.lean Formula.toJson | `Theories/Bimodal/Automation/DataExport.lean:104-116` |
| ProofTrace structure | `Theories/Bimodal/Automation/DatasetGenerator.lean:55-62` |
| extractProofTrace function | `Theories/Bimodal/Automation/DatasetGenerator.lean:193-229` |
| LabeledFormula structure | `Theories/Bimodal/Automation/DatasetGenerator.lean:101-114` |
| proof_steps.jsonl (2,424 steps) | `data/proof_steps.jsonl` fields: theorem_name, step_index, context, goal, rule, axiom_name, subgoals, frame_class |
| BimodalHarness ingestion | `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/data/ingestion.py` |
| BimodalHarness config subprocess | `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/config.py` (LEAN_TIMEOUT) |
| Existing lake executables | `lakefile.lean`: dataset_generator, proof_extractor, dataset_validator, benchmark_oracle |
| BimodalHarness task 28 (completed) | Symmetric VerifierProvider architecture with cross-signal consistency |
| ModelChecker tasks 99-105 | OracleProvider refactoring pipeline |

## Confidence Level

**High** — The existing infrastructure is mature and well-aligned with what BimodalHarness expects. The main gaps are (1) a single-formula Lean executable for online verification, (2) a thin Python package wrapping that executable as a VerifierProvider, and (3) cross-signal conformance testing. The Lean proof step extraction format already matches BimodalHarness's expected schema almost exactly.
