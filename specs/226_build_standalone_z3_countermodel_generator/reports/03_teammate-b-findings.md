# Teammate B Findings (Round 3): Cross-Repository Handshake Architecture

**Task**: 226 — Build standalone Z3 countermodel generator for negative training signal
**Angle**: Review the three-repo handshake and identify gaps for end-to-end dual-signal training
**Date**: 2026-05-30
**Confidence Level**: High

## Key Findings

### 1. BimodalHarness Task 28 Is COMPLETED — Full Signal Infrastructure Exists

The BimodalHarness already has a complete dual-signal infrastructure:

| Module | Purpose | Status |
|--------|---------|--------|
| `oracle/protocol.py` | `OracleProvider` — negative signal (countermodels) | Complete |
| `oracle/registry.py` | Entry-point discovery for oracle providers | Complete |
| `oracle/gateway.py` | `SoundnessGateway` — 3-phase preflight validation | Complete |
| `oracle/compatibility.py` | Compatibility matrix for oracle versioning | Complete |
| `verifier/protocol.py` | `VerifierProvider` — positive signal (proofs) | Complete |
| `verifier/registry.py` | Entry-point discovery for verifier providers | Complete |
| `verifier/gateway.py` | `VerifierSoundnessGateway` — 3-phase preflight | Complete |
| `verifier/compatibility.py` | Compatibility matrix for verifier versioning | Complete |
| `signal/registry.py` | `SignalRegistry` — unified oracle+verifier management | Complete |
| `signal/consistency.py` | `CrossSignalConsistencyChecker` — mutual exclusion check | Complete |
| `data/ingestion.py` | Layers 1-4 including VerifierProvider adapters | Complete |

**The infrastructure is waiting for real providers.** Only mock providers exist (`_mock.py` in both oracle/ and verifier/).

### 2. The VerifierProvider Protocol Requires Three Methods

BimodalLogic must implement:

```python
class VerifierProvider(Protocol):
    # Properties (5 required):
    provider_id: str                    # e.g. "bmlogic_lean_verifier_v1"
    provider_version: str               # semver
    semantics_version: str              # BimodalLogic semantics version
    supported_frame_classes: frozenset  # {"Base"}
    capabilities: dict                  # proof_system, backend, etc.

    # Methods (3 required):
    def verify_formula(formula_json, frame_class, timeout_ms) -> VerificationResult | None
    def extract_proof_steps(formula_json, frame_class, timeout_ms) -> list[dict] | None
    def validate_self(spot_check_formulas) -> bool
```

`VerificationResult` is a frozen dataclass with fields: `formula_json`, `proof_steps` (optional list of dicts), `proof_depth` (int), `proof_certificate` (optional string).

### 3. Cross-Signal Consistency Check Is the Soundness Handshake

The `CrossSignalConsistencyChecker` (signal/consistency.py) implements the core invariant: **no formula should get both a countermodel AND a proof**.

For each formula in a benchmark set:
1. Call `oracle.find_countermodel(formula)` → countermodel or None
2. Call `verifier.verify_formula(formula)` → proof or None
3. If BOTH return non-None → INCONSISTENCY (a bug in one or both providers)

The `SignalRegistry.preflight_all()` orchestrates all three validation phases:
1. Oracle gateway preflight (self-check against known-invalid formulas)
2. Verifier gateway preflight (self-check against known-valid formulas, optional cross-signal with oracle)
3. Cross-signal consistency check on combined spot-check formulas

### 4. BimodalLogic Has ZERO VerifierProvider Implementation

There is NO implementation of `VerifierProvider` anywhere in BimodalLogic or any other repo (only the mock in BimodalHarness). This is the primary gap for task 226.

**What BimodalLogic currently exports:**
- `data/bmlogic-bench.jsonl`: 387 formulas with 14 fields including `proof_trace` (height, axioms_used, rules_applied) and `countermodel` (SimpleCountermodel)
- `data/proof_steps.jsonl`: 2,424 proof step records with fields: theorem_name, step_index, context, goal, rule, axiom_name, subgoals, frame_class
- `scripts/generate_dataset.py`: Converts JSONL to PyTorch tensors
- Lean executables: `lake exe` pattern for proof extraction

**What BimodalLogic DOESN'T have:**
- No Python package (`pyproject.toml`)
- No `VerifierProvider` implementation
- No entry-point registration for `bimodal_harness.verifier_providers`
- No programmatic API for proof search (the Lean decision procedure runs as a subprocess)

### 5. The Positive Signal Implementation Path

To implement `VerifierProvider`, BimodalLogic needs a Python wrapper around its Lean proof capabilities:

**Option A — JSONL-backed provider** (simplest, ~100 lines):
```python
class JsonlVerifierProvider:
    """Serves pre-computed proofs from existing JSONL files."""
    def verify_formula(self, formula_json, frame_class, timeout_ms):
        # Look up formula in bmlogic-bench.jsonl or bmlogic-c5/c7.jsonl
        # Return VerificationResult if label=="valid" with proof_trace
        # Return None if label=="invalid" or not found
```

**Option B — Lean subprocess provider** (~300 lines):
```python
class LeanVerifierProvider:
    """Runs Lean decision procedure as subprocess for live verification."""
    def verify_formula(self, formula_json, frame_class, timeout_ms):
        # Write formula to temp file
        # Run: lake exe proof_checker <formula_file>
        # Parse output for proof trace
        # Return VerificationResult or None
```

**Option C — Both** (recommended):
- JSONL provider for batch training (fast, no Lean dependency)
- Lean subprocess provider for live/online verification (slower but complete)

### 6. ModelChecker Task 106 Round 2 Has Critical Findings

The architecture review (task 106 Round 2) identified:

**CRITICAL — Boundary Effects**: Z3 countermodels at time domain boundaries may have no BimodalLogic analog. If `G(phi)` is vacuously true at t=M-1 because no future times exist, the countermodel is unsound relative to Lean's infinite domain.

**Resolution (proposed)**: Require M > temporal_depth(formula) so boundary effects can't influence the evaluation point. This is NOT yet implemented in any task.

**Architecture consensus**: Three-repo split with JSON contracts:
- BimodalLogic = specification (Lean definitions are truth)
- ModelChecker = executive (Z3 oracle, Python only)
- BimodalHarness = judicial (soundness bridge, integration)

### 7. Data Format Alignment Assessment

| BimodalLogic exports | BimodalHarness expects | Status |
|---------------------|----------------------|--------|
| `formula_ast` (6-tag JSON) | `formula_json` (same format) | ✅ Aligned (field name differs) |
| `proof_trace` (height, axioms, rules) | `VerificationResult.proof_steps` (list of dicts) | ⚠️ Different granularity |
| `proof_steps.jsonl` (step-level) | `ProofStepRecord` (step-level) | ⚠️ Field name translations needed |
| `countermodel` (SimpleCountermodel) | `SimpleCountermodel.from_dict()` | ✅ Aligned |
| No structured countermodel | `StructuredCountermodel` | ❌ Gap (ModelChecker task 103 will fill) |
| `label` ("valid"/"invalid") | `Label.VALID`/`Label.INVALID` | ✅ Aligned |
| `pattern_key` | `PatternKey.from_dict()` | ✅ Aligned |
| `metrics` | `DifficultyMetrics.from_dict()` | ✅ Aligned |

The `data/ingestion.py` Layer 2 already handles the field-name translations (`formula_ast` → `formula_json`, `formula_str` → `formula_pretty`, etc.).

### 8. BimodalHarness Already Has VerifierProvider Adapters in ingestion.py

Layer 4 of `data/ingestion.py` is described as "VerifierProvider adapters (for proof step extraction via verifier protocol)." This means BimodalHarness already expects to consume proof data through the VerifierProvider interface. The adapters convert VerifierProvider output into `ProofStepRecord` objects for the training pipeline.

### 9. Gap Summary: What's Missing for End-to-End

| Component | Owner Repo | Status | Blocks |
|-----------|-----------|--------|--------|
| OracleProvider protocol | BimodalHarness | ✅ Complete | — |
| VerifierProvider protocol | BimodalHarness | ✅ Complete | — |
| SignalRegistry + consistency | BimodalHarness | ✅ Complete | — |
| OracleProvider implementation | ModelChecker (tasks 100-105) | ❌ Not started | Negative signal |
| VerifierProvider implementation | **BimodalLogic (task 226)** | ❌ Not started | Positive signal |
| Cross-signal consistency check | BimodalHarness | ✅ Complete (uses mocks) | Real providers |
| Boundary effect mitigation | ModelChecker (no task yet) | ❌ Not addressed | Soundness claim |
| Lean soundness bridge | BimodalHarness (no task yet) | ❌ Not addressed | Certified oracle |
| StructuredCountermodel extraction | ModelChecker (task 103) | ❌ Not started | Rich negative signal |

## Recommended Approach

### Task 226 Should Focus on Positive Signal (VerifierProvider)

Given that the ModelChecker handles the negative signal (tasks 100-106), task 226 in BimodalLogic should pivot from "countermodel generator" to **"dual-signal integration with positive-signal provider"**:

1. **Create a Python package** (`bmlogic-verifier` or similar) that implements `VerifierProvider`:
   - `verify_formula()`: Look up formula in pre-computed JSONL, optionally fall back to `lake exe` subprocess
   - `extract_proof_steps()`: Return proof step records from `proof_steps.jsonl` or live extraction
   - `validate_self()`: Verify against 10 known-valid spot-check formulas
   - Entry-point: `[project.entry-points.'bimodal_harness.verifier_providers'] lean_v1 = "bmlogic_verifier.provider:LeanVerifierProvider"`

2. **Cross-validation conformance**: Once both the oracle (ModelChecker) and verifier (BimodalLogic) are registered, `SignalRegistry.preflight_all()` runs the cross-signal consistency check automatically.

3. **Lean soundness formalization**: Independent of the Python provider, prove in Lean that bounded finite models are genuine countermodels (already planned in prior rounds).

### Key Insight: The Positive Signal Is as Important as the Negative

The technical memo states: "Proof certificates provide positive reinforcement signals ... Countermodels provide targeted corrective feedback." The BimodalHarness is architecturally ready for BOTH. The ModelChecker provides the negative signal. BimodalLogic must provide the positive signal. Task 226 should own both sides from BimodalLogic's perspective.

## Evidence/Examples

| Finding | Source | Line(s) |
|---------|--------|---------|
| VerifierProvider protocol complete | BimodalHarness verifier/protocol.py | 72-218 |
| CrossSignalConsistencyChecker complete | BimodalHarness signal/consistency.py | 40-143 |
| SignalRegistry.preflight_all() complete | BimodalHarness signal/registry.py | 148-283 |
| VerifierProvider adapters in ingestion | BimodalHarness data/ingestion.py | Layer 4 |
| No VerifierProvider in BimodalLogic | find command (zero results) | — |
| 2,424 proof step records available | data/proof_steps.jsonl | wc -l |
| Boundary effects identified (critical) | ModelChecker task 106 Round 2 report | Lines 20-24 |
| Entry-point group for verifiers | BimodalHarness verifier/registry.py | Line 43 |
| Mock verifier spot-checks | BimodalHarness verifier/_mock.py | 10 known-valid formulas |
