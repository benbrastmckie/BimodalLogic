# Research Report: Task #226 (Round 3)

**Task**: Build standalone Z3 countermodel generator for negative training signal
**Date**: 2026-05-30
**Mode**: Team Research (4 teammates)
**Focus**: Dual-signal architecture — positive signal from BimodalLogic, negative from ModelChecker, handshake in BimodalHarness

## Summary

Round 3 reveals that task 226 needs FUNDAMENTAL REDEFINITION. The technical memo describes a "Dual Verification Architecture" where proof certificates (positive signal from BimodalLogic) and countermodels (negative signal from ModelChecker) combine for training. BimodalHarness task 28 (COMPLETED) already built the complete infrastructure: `VerifierProvider` and `OracleProvider` protocols, `SignalRegistry`, `CrossSignalConsistencyChecker`, soundness gateways — all waiting for real providers.

**The critical finding**: BimodalLogic has ZERO `VerifierProvider` implementation. The ModelChecker (tasks 100-106) handles the negative signal. Task 226 should pivot from "countermodel generator" to **implementing the `LeanVerifierProvider` for positive signal**, completing the dual-verification architecture. The existing Lean executables (`lake exe dataset_generator`, `proof_extractor`, `dataset_validator`) already do the heavy lifting — the missing piece is a ~200-300 line Python wrapper package (`bmlogic-verifier`) that implements the VerifierProvider protocol and registers via entry points.

## Key Findings

### 1. BimodalHarness Has COMPLETE Dual-Signal Infrastructure (Waiting for Providers)

| Module | Purpose | Status |
|--------|---------|--------|
| `oracle/protocol.py` | OracleProvider — negative signal | Complete |
| `verifier/protocol.py` | VerifierProvider — positive signal | Complete |
| `signal/registry.py` | SignalRegistry — unified management | Complete |
| `signal/consistency.py` | CrossSignalConsistencyChecker | Complete |
| `oracle/gateway.py` | SoundnessGateway — 3-phase preflight | Complete |
| `verifier/gateway.py` | VerifierSoundnessGateway | Complete |
| `oracle/_mock.py` | Mock oracle (10 known-invalid formulas) | Complete |
| `verifier/_mock.py` | Mock verifier (10 known-valid formulas) | Complete |

Only mock providers exist. The infrastructure is architecturally complete and tested against mocks.

### 2. BimodalLogic Has the Lean Machinery — Missing Is the Python Wrapper

**Already exists in Lean:**
- `lake exe dataset_generator`: Labels formulas valid/invalid/timeout with proof traces
- `lake exe proof_extractor`: Extracts 2,424 step-level proof records from 36 theorems
- `lake exe dataset_validator`: Conformance tests (20 known-valid, 20 known-invalid)
- `lake exe benchmark_oracle`: Formula validation endpoint
- `DataExport.lean`: `Formula.toJson` in 6-tag format (exact BimodalHarness format)
- `DatasetGenerator.lean`: `LabeledFormula` pipeline with `decideAuto`

**Missing:**
- No Python package (`pyproject.toml`) for pip installation
- No `VerifierProvider` class wrapping the Lean executables
- No entry-point registration for `bimodal_harness.verifier_providers`
- No single-formula verification endpoint (only batch via `lake exe`)

### 3. The VerifierProvider Protocol Requires 5 Properties + 3 Methods

```python
class VerifierProvider(Protocol):
    provider_id: str              # "bmlogic_lean_verifier_v1"
    provider_version: str         # semver
    semantics_version: str        # pinned to BimodalLogic version
    supported_frame_classes: frozenset[str]  # {"Base"}
    capabilities: dict[str, Any]

    def verify_formula(formula_json, frame_class, timeout_ms) -> VerificationResult | None
    def extract_proof_steps(formula_json, frame_class, timeout_ms) -> list[dict] | None
    def validate_self(spot_check_formulas) -> bool
```

### 4. Cross-Signal Soundness Is Formally Guaranteed (Implicitly)

Teammate C established that cross-signal consistency follows from two separate Lean facts:

1. **Soundness** (sorry-free): If `Γ ⊢ φ`, then `Γ ⊨ φ` — proofs certify validity
2. **Z3 encoding soundness** (Round 2): Every countermodel IS a valid Lean model

Together: if BimodalLogic proves φ (positive signal), φ is valid in all models, so no countermodel can exist → oracle MUST return None. Conversely, if oracle returns a countermodel, φ is NOT valid → BimodalLogic CANNOT prove it.

The `CrossSignalConsistencyChecker` in BimodalHarness provides runtime empirical validation on top of this formal guarantee.

### 5. Task 226 Should Be REVISED and Task 228-229 Created

**Unanimous recommendation**: Task 226's original description is now wrong. The negative signal is handled by ModelChecker tasks 100-106. Task 226 should become the positive signal provider.

**Recommended split:**

| Task | Description | Effort | Blocks On |
|------|-------------|--------|-----------|
| 226 (REVISED) | Implement LeanVerifierProvider for BimodalHarness | ~8 hours | Nothing (can start now) |
| 228 (NEW) | Lean bounded model soundness formalization | ~12 hours | Nothing (independent) |
| 229 (NEW) | Cross-signal conformance + dataset enrichment | ~8 hours | 226 + ModelChecker 103 |

### 6. Existing Dataset Tasks Coordinate with the New Scope

| Task | Status | Relationship |
|------|--------|-------------|
| 220 (anchor expansion 42/42) | COMPLETED | Verifier benefits from broader anchor set |
| 221 (proof step expansion 36→200+) | NOT STARTED | Generates data that VerifierProvider serves — coordinate |
| 217 (c9/c11 complexity tiers) | NOT STARTED | More formulas for both oracle and verifier pipelines |
| 219 (LLM baseline calibration) | NOT STARTED | Downstream consumer of dual-signal dataset |

Task 221 and task 226 should coordinate: 221 generates more proof step data in Lean, 226 wraps that data behind the VerifierProvider protocol.

### 7. Parallel Execution Path

```
ModelChecker 100→101→102→103 (OracleProvider)     ← negative signal
BimodalLogic 226 (VerifierProvider)                 ← positive signal
                    ↓ (both pip-installable)
BimodalHarness SignalRegistry auto-discovers both
                    ↓
CrossSignalConsistencyChecker runs preflight
                    ↓
Dual-signal training begins
```

Task 226 and ModelChecker task 103 can proceed **in parallel**. Once both are pip-installable, BimodalHarness discovers them automatically via entry points.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Task 226 = "countermodel generator" vs "positive signal provider" | REVISED to positive signal — ModelChecker owns negative |
| Build Z3 from scratch vs consume external oracle | External oracle (ModelChecker 100-106) confirmed |
| Single task vs split | Split into 226 (verifier), 228 (Lean soundness), 229 (cross-signal + enrichment) |
| Cross-signal soundness: formal vs runtime | Both — formal via Lean soundness theorem, runtime via BimodalHarness checker |

### Revised Task 226 Description

> **Implement LeanVerifierProvider for dual-signal training integration.** Create a `bmlogic-verifier` Python package that wraps BimodalLogic's Lean executables (`lake exe dataset_generator`, `proof_extractor`, `dataset_validator`) behind the BimodalHarness `VerifierProvider` protocol. Implement `verify_formula()` (calls Lean decision procedure for single-formula verification), `extract_proof_steps()` (serves proof step records), and `validate_self()` (spot-check against known-valid formulas). Register as entry point `bimodal_harness.verifier_providers` so BimodalHarness discovers it automatically. This provides the positive training signal (proof certificates) that complements the negative signal (countermodels) from ModelChecker's OracleProvider, enabling the dual verification architecture described in the technical memo.

### New Task 228 Description

> **Lean bounded model soundness formalization.** Prove in Lean that any bounded finite model satisfying the Z3 frame axioms constitutes a valid TaskFrame, and that truth evaluation on bounded models is faithful to `truth_at`. Leverages existing `FiniteTaskFrame` (with coercion to `TaskFrame`). This certifies that every countermodel found by the Z3 oracle guarantees a genuine countermodel in the Lean semantics.

### New Task 229 Description

> **Cross-signal conformance testing and dataset enrichment.** Run both the OracleProvider (ModelChecker) and VerifierProvider (BimodalLogic) on shared formula benchmarks, verifying no formula receives both a proof and a countermodel. Batch-enrich existing JSONL datasets with structured countermodels from the oracle. Resolve the ~1,552 timeout formulas where the Lean tableau timed out but Z3 may succeed. Depends on task 226 (verifier provider) and ModelChecker task 103 (oracle provider).

## Teammate Contributions

| Teammate | Angle | Key Contribution |
|----------|-------|-----------------|
| A | Positive signal interface | Mapped BimodalLogic's 7 Lean executables to VerifierProvider methods; identified single-formula endpoint gap |
| B | Cross-repo architecture | Confirmed BimodalHarness has COMPLETE infrastructure; identified BimodalLogic has ZERO VerifierProvider; found boundary effects from MC task 106 |
| C | Soundness analysis | Cross-signal consistency is formally guaranteed (Lean soundness + Z3 encoding soundness) AND runtime-checked; formula translation is single point of failure |
| D | Task redesign | Proposed 3-task split; minimum viable path is 226 + MC 103 in parallel; coordinated with existing tasks 221/227 |

## References

- Technical memo: `/home/benjamin/Projects/Logos/Vision/shared/strategy/01-overview/03-technical_memo.typ`
- VerifierProvider protocol: `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/verifier/protocol.py`
- CrossSignalConsistencyChecker: `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/signal/consistency.py`
- SignalRegistry: `/home/benjamin/Projects/BimodalHarness/src/bimodal_harness/signal/registry.py`
- BimodalHarness task 28 (COMPLETED): Symmetric verifier provider architecture
- ModelChecker tasks 100-106: OracleProvider refactoring pipeline
- Lean soundness: `Theories/Bimodal/Metalogic/Soundness/Soundness.lean` (sorry-free)
- Lean data export: `Theories/Bimodal/Automation/DataExport.lean`, `DatasetGenerator.lean`
- Existing proof steps: `data/proof_steps.jsonl` (2,424 records)
