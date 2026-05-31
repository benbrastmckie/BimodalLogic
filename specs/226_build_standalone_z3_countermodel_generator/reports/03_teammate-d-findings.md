# Teammate D (Horizons) Findings: Round 3 — Task 226 Redesign

**Focus**: Redefine task 226 given the three-repo dual-signal architecture
**Date**: 2026-05-30

## Key Findings

### 1. The Three-Repo Architecture Is Now Complete at the Protocol Level

The dual-signal architecture from the technical memo is fully designed:

```
BimodalLogic  →  VerifierProvider  →  positive signal (proofs + proof steps)
ModelChecker  →  OracleProvider    →  negative signal (countermodels)
                        ↓
             BimodalHarness SignalRegistry
                        ↓
             CrossSignalConsistencyChecker
                        ↓
             Dual-signal training pipeline
```

- **BimodalHarness task 28** (COMPLETED): Created `VerifierProvider` protocol, `VerifierRegistry`, `SignalRegistry`, `CrossSignalConsistencyChecker`, all types and gateways
- **ModelChecker tasks 100-106**: Creating `OracleProvider` implementation (bmlogic-oracle)
- **BimodalLogic task 226**: Must now create the `VerifierProvider` implementation (bmlogic-verifier)

### 2. BimodalLogic Already Has Most of the Machinery — Missing Is the Python Wrapper

The Lean side already has:
- **`lake exe dataset_generator`**: Enumerates formulas, labels them valid/invalid/timeout, exports JSONL
- **`lake exe proof_extractor`**: Extracts 2424 proof steps from 36 theorems as JSONL
- **`lake exe dataset_validator`**: Conformance tests (20 known-valid, 20 known-invalid), diversity metrics
- **`lake exe benchmark_oracle`**: Validates benchmark formulas
- **`DataExport.lean`**: Full `Formula.toJson` serialization (6-tag format)
- **`DatasetGenerator.lean`**: `LabeledFormula`, `labelFormula`, `labelBatch`
- **`ProofStepExport.lean`**: Step-level extraction with rule profiles

What's MISSING is a Python package that:
1. Wraps these Lean executables behind the `VerifierProvider` protocol
2. Registers as entry point `bimodal_harness.verifier_providers`
3. Calls `lake exe` subprocesses for `verify_formula()` and `extract_proof_steps()`
4. Returns `VerificationResult` objects matching BimodalHarness's types

### 3. Task 226 Should Be SPLIT — The Original Description Is Now Wrong

The original task 226 says "create a standalone version of the bimodal ModelChecker Z3 infrastructure." That's now ModelChecker tasks 100-106. Task 226 needs a complete description rewrite.

**Recommended split into 3 tasks:**

**Task 226 (REVISED)**: Implement LeanVerifierProvider for BimodalHarness integration
- Create `bmlogic-verifier` Python package in `tools/bmlogic-verifier/`
- Implement `VerifierProvider` protocol (5 properties, 3 methods)
- `verify_formula()`: calls `lake exe benchmark_oracle` or extends `dataset_generator` to check a single formula
- `extract_proof_steps()`: calls `lake exe proof_extractor` for formulas with known proofs
- `validate_self()`: uses `DatasetValidator.knownValidFormulas` spot-check list
- Entry point: `[project.entry-points.'bimodal_harness.verifier_providers'] lean_v1 = "bmlogic_verifier.provider:LeanVerifierProvider"`
- Cross-validates against BimodalHarness's `MockVerifierProvider`

**New task 228**: Lean bounded model soundness formalization (the original Phase 3)
- Prove `FiniteTaskFrame` satisfying Z3 constraints implies valid `TaskFrame`
- Prove truth evaluation faithfulness for bounded models
- This supports the "every countermodel guarantees" claim
- Independent of Python work, can start immediately

**New task 229**: Cross-signal conformance and dataset enrichment
- Run both oracle and verifier on shared formula set
- Verify no formula gets both a countermodel AND a proof
- Batch-enrich JSONL datasets with structured countermodels from oracle
- Resolve the 1,552 timeout formulas
- Depends on: task 226 (verifier) + ModelChecker task 103 (oracle)

### 4. Relationship to Existing Dataset Enhancement Tasks

| Task | Status | Relevance to 226 |
|------|--------|------------------|
| 217 (c9/c11 tiers) | NOT STARTED | Generates MORE formulas for the verifier/oracle pipeline — orthogonal but complementary |
| 219 (LLM baselines) | NOT STARTED | Consumes the dual-signal dataset — downstream, no conflict |
| 220 (anchor expansion) | COMPLETED | Expanded coverage to 42/42 axioms — verifier benefits from broader anchor set |
| 221 (proof step expansion) | NOT STARTED | Directly overlaps with verifier's `extract_proof_steps()` — should coordinate to avoid duplication |
| 227 (pipeline automation) | RESEARCHED | The sync script should also sync verifier/oracle outputs — coordinate |

**Key overlap**: Task 221 (proof step expansion, 36→200+) produces the SAME data that `VerifierProvider.extract_proof_steps()` would serve. These should be coordinated:
- Task 221 generates more proof step data in Lean
- Task 226 wraps that data behind the VerifierProvider protocol for BimodalHarness

### 5. The Minimum Viable Path for Dual-Signal Training

**Must-have (3 tasks):**
1. **Task 226 (revised)**: LeanVerifierProvider — wraps existing `lake exe` commands behind VerifierProvider protocol (~200-300 lines Python)
2. **ModelChecker task 103**: OracleProvider implementation — wraps existing Z3 solving behind OracleProvider protocol
3. Cross-signal consistency check using BimodalHarness task 28's checker

**Nice-to-have:**
4. **Task 228**: Lean soundness formalization (strengthens claims but training works without it)
5. **Task 229**: Dataset enrichment (richer countermodels, timeout resolution)
6. **Task 221**: More proof steps (more positive signal)

**Order**: ModelChecker 100→101→102→103 (oracle) + BimodalLogic 226 (verifier) can proceed IN PARALLEL. Once both are pip-installable, BimodalHarness's SignalRegistry discovers them automatically.

### 6. The LeanVerifierProvider Is Simpler Than Expected

The Lean executables already do the heavy lifting. The Python wrapper needs to:

```python
class LeanVerifierProvider:
    provider_id = "bmlogic_lean_verifier_v1"
    provider_version = "0.1.0"
    semantics_version = "2.1.0"
    supported_frame_classes = frozenset({"Base"})
    capabilities = {"proof_system": "BX axiom system", "backend": "lean4"}

    def verify_formula(self, formula_json, frame_class="Base", timeout_ms=5000):
        # Pipe formula_json to `lake exe dataset_generator --single`
        # or extend DatasetGenerator to accept single-formula input
        result = subprocess.run(["lake", "exe", "benchmark_oracle", ...])
        if result says valid:
            return VerificationResult(formula_json=formula_json, proof_depth=...)
        return None

    def extract_proof_steps(self, formula_json, frame_class="Base", timeout_ms=5000):
        # Check if formula matches a known theorem
        # If yes, use proof_extractor output
        # If not, return None
        ...

    def validate_self(self, spot_check_formulas):
        # Run dataset_validator's knownValidFormulas list
        ...
```

The main engineering challenge is adding single-formula input mode to the Lean executables. Currently they batch-process — they need a `--formula '{"tag":"imp",...}'` flag.

### 7. Strategic Value: The Technical Memo Promise

The technical memo states: "Every valid inference produces a proof certificate—a machine-verified witness establishing correctness with mathematical certainty. Countermodels provide targeted corrective feedback."

Task 226 (revised) is the LAST PIECE needed to deliver on this promise:
- Proof certificates → VerifierProvider (BimodalLogic)
- Countermodels → OracleProvider (ModelChecker)
- Dual verification → SignalRegistry + CrossSignalConsistencyChecker (BimodalHarness)

## Recommended Approach

1. **REVISE task 226 description** to: "Implement LeanVerifierProvider for dual-signal training integration"
2. **CREATE task 228** for Lean bounded model soundness formalization
3. **CREATE task 229** for cross-signal conformance testing and dataset enrichment
4. **Coordinate with task 221** (proof step expansion) — task 221 generates data, task 226 wraps it as a provider
5. **Both 226 and ModelChecker 103 can proceed in parallel** — they're independent implementations of symmetric protocols

## Evidence/Examples

| Finding | Source | Reference |
|---------|--------|-----------|
| VerifierProvider protocol | BimodalHarness | `verifier/protocol.py` |
| VerificationResult type | BimodalHarness | `verifier/types.py` |
| CrossSignalConsistencyChecker | BimodalHarness | `signal/consistency.py` |
| SignalRegistry | BimodalHarness | `signal/registry.py` |
| BimodalHarness task 28 | BimodalHarness | `specs/TODO.md` (COMPLETED) |
| 7 Lean executables | BimodalLogic | `lakefile.lean` |
| 36 theorems / 2424 steps | BimodalLogic | `ProofStepExport.lean` |
| DatasetValidator conformance | BimodalLogic | `DatasetValidator.lean` |
| Formula.toJson (6-tag) | BimodalLogic | `DataExport.lean` |
| Task 221 overlap | BimodalLogic | `specs/TODO.md` |

## Confidence Level

**High** — The three-repo architecture is fully designed at the protocol level. The BimodalLogic side has all the Lean machinery; the gap is purely the Python wrapper (~200-300 lines). The main risk is that single-formula Lean executable input may require a small Lean-side change (adding `--formula` flag to benchmark_oracle or dataset_generator), but this is minor.
