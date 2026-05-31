# Teammate C (Critic) Findings: Round 3 — Dual-Signal Soundness Analysis

**Task**: 226 — Build standalone Z3 countermodel generator for negative training signal
**Date**: 2026-05-30
**Focus**: Soundness of the dual-signal pipeline (positive from BimodalLogic, negative from ModelChecker, assembled in BimodalHarness)

## Key Findings

### 1. Cross-Signal Consistency Is RUNTIME-CHECKED, Not Formally Guaranteed

BimodalHarness has a `CrossSignalConsistencyChecker` in `signal/consistency.py` that detects oracle/verifier conflicts. For each formula, it calls both:
- `oracle_provider.find_countermodel(formula)` → countermodel or None
- `verifier_provider.verify_formula(formula)` → VerificationResult or None

If BOTH return non-None for the same formula, it flags an inconsistency (a formula simultaneously has a proof AND a countermodel).

**Critical observation**: This is a runtime empirical check, not a formal guarantee. It tests a finite set of formulas. The formal guarantee comes from two separate Lean theorems:

1. **Soundness** (sorry-free in `Metalogic/Soundness.lean`): If `Γ ⊢ φ` (derivable), then `Γ ⊨ φ` (valid in all models). This means: if BimodalLogic produces a proof certificate for φ, then φ is true in every model — no countermodel can exist.

2. **Z3 encoding soundness** (from Round 2 Teammate C): Every countermodel found by the ModelChecker IS a valid model in the Lean semantics where the formula is false.

Together: if BimodalLogic proves φ, then φ is valid (soundness), so NO model exists where φ is false, so the Z3 oracle MUST return None. Conversely, if the Z3 oracle returns a countermodel, then φ IS false in some model, so φ is NOT valid, so BimodalLogic CANNOT prove φ (by contrapositive of soundness).

**The formal guarantee exists but is implicit — it follows from Lean soundness plus Z3 encoding soundness. It is never stated as a single cross-system theorem.**

### 2. Formula Translation Is a Single Point of Failure

Both signals share the 6-tag JSON formula format defined in `DataExport.lean:96-116`:
```
atom → {"tag": "atom", "name": "p"}
bot → {"tag": "bot"}
imp → {"tag": "imp", "left": <φ>, "right": <ψ>}
box → {"tag": "box", "child": <φ>}
untl → {"tag": "untl", "event": <φ>, "guard": <ψ>}
snce → {"tag": "snce", "event": <φ>, "guard": <ψ>}
```

The ModelChecker task 102 implements `json_to_prefix()` translating this format to the ModelChecker's internal prefix representation, then `Sentence.from_prefix()` constructing internal Sentence objects.

**Risk**: The translation must be semantically faithful. Key concerns:

- **Atom encoding**: BimodalLogic uses `Atom` with `base: String` and `fresh_index: Option Nat`. The JSON serializes only `name` (the `base` field). The ModelChecker uses string-based sentence letters. This matches IF fresh_index is always None in the exported dataset. Confirmed: bmlogic-bench.jsonl uses only `{"base": "p", "fresh_index": null}` style atoms.

- **Operator role convention**: Until/Since use `event`/`guard` field names in JSON. The ModelChecker's operators.py uses `UntilOperator(event, guard)` with the same convention (Burgess). But task 102 must verify the field mapping is not transposed.

- **No G/H/F/P tags**: The 6-tag JSON has no derived operators. G is defined as `¬U(¬φ,⊤)` and H as `¬S(¬φ,⊤)` in the Lean syntax. Formulas in the dataset are always expanded to primitives. Task 102 must verify G/H equivalence: that `¬U(¬φ,⊤)` in the ModelChecker produces the same Z3 constraints as the direct `FutureOperator` (G) encoding. This is ModelChecker task 102's explicit scope.

### 3. SoundnessGateway Already Validates Countermodels Against Lean

The `SoundnessGateway` in BimodalHarness (gateway.py) has a three-phase preflight:

1. **Self-check**: Oracle must find countermodels for 10 hardcoded known-invalid formulas
2. **Cross-validation** (optional): Uses `LeanSubprocessValidator` which calls `lake exe dataset_validator --mode validate-countermodel` in the BimodalLogic repo to check countermodels against Lean truth semantics
3. **Matrix recording**: Records validated (oracle, semantics_version, benchmark_hash) triples

**This is exactly the "soundness handshake" the task description envisions.** The infrastructure already exists. What's missing is the actual oracle provider (ModelChecker tasks 99-105) and the actual verifier provider (BimodalLogic must expose a `VerifierProvider`).

### 4. BimodalLogic Must Expose a VerifierProvider — This Is NOT in Task 226

BimodalHarness task 28 designed the `VerifierProvider` protocol (symmetric to `OracleProvider`). BimodalLogic must implement this protocol. The required interface:

- `verify_formula(formula_json, frame_class, timeout_ms)` → proof or None
- `extract_proof_steps(formula_json, frame_class, timeout_ms)` → step-level training data
- `validate_self(spot_check_formulas)` → bool

BimodalLogic already has the infrastructure:
- `DatasetGenerator.labelFormula()` decides validity and extracts proofs/countermodels
- `ProofStepExtractor.extractStepSequence()` walks derivation trees to emit ordered steps
- `DatasetExporter` exports labeled formulas to JSONL
- `DatasetValidator` runs conformance tests against known valid/invalid formulas

**But there is no Python wrapper exposing this as a `VerifierProvider`.** The current consumption path is:
1. Lean `lake exe dataset_export` generates JSONL files on disk
2. BimodalHarness `data/ingestion.py` reads those JSONL files

Task 28 proposed refactoring this: a `LeanVerifierProvider` would wrap the `lake exe` subprocess, and a `JsonlVerifierProvider` would wrap static file loading.

**This positive-signal provider is NOT part of task 226. Task 226 is scoped to the negative signal. But the cross-signal consistency check requires BOTH providers to be implemented.**

### 5. Lean Soundness Theorems Are Sorry-Free

The soundness infrastructure is strong:

- `soundness` in Soundness.lean: Sorry-free. For Base frame derivations, `Γ ⊢ φ → Γ ⊨ φ`
- `soundness_dense`: Sorry-free. For dense-compatible derivations on dense frames
- `soundness_discrete`: Sorry-free. For all derivations on discrete frames
- All 42 axiom validity proofs: Sorry-free
- FMP (finite model property): Sorry-free in `FMP/FMP.lean`

The FMP theorem guarantees: if φ is invalid, then a FINITE countermodel exists. Combined with Z3 encoding soundness (Round 2), this means the Z3 oracle is guaranteed to find countermodels for all invalid formulas given sufficient bounds — the question is only performance (how large N,M are needed).

### 6. Timeout Formulas: The Third Category

The dataset has ~1,552 timeout formulas where the Lean tableau couldn't decide within the fuel limit. These fall into three possible categories:

1. **Actually invalid**: Z3 may find countermodels (different search strategy)
2. **Actually valid**: Need more tableau fuel or different proof search strategy
3. **Genuinely hard**: Both approaches timeout

The dual architecture handles this:
- Run oracle on timeouts → some get countermodels → reclassify as invalid
- Run verifier on remaining → some get proofs → reclassify as valid
- Remaining undecided → exclude from training or label as "undecided" (no signal)

**The CrossSignalConsistencyChecker would catch any case where BOTH produce results for the same timeout formula — which would be a soundness bug in one of them.**

### 7. The "Soundness Handshake" Architecture Is Sound but Not Fully Formal

The architecture provides multiple layers of soundness:

| Layer | Mechanism | Formal? | Status |
|-------|-----------|---------|--------|
| 1. Lean soundness | `derivable → valid` | YES (Lean proof) | Sorry-free |
| 2. Z3 encoding soundness | ModelChecker constraints ≥ Lean axioms | EMPIRICAL (Round 2 analysis) | Verified line-by-line |
| 3. Self-check | Oracle finds countermodels for known-invalids | RUNTIME | Implemented in gateway.py |
| 4. Cross-validation | Lean subprocess validates countermodels | RUNTIME + LEAN | Implemented in gateway.py |
| 5. Cross-signal consistency | No formula gets both proof and countermodel | RUNTIME | Implemented in consistency.py |
| 6. Compatibility matrix | Version-stamped validation cache | DATA | Implemented in compatibility.py |

**Gap**: Layer 2 (Z3 encoding soundness) is empirically verified but not formally proved in Lean. The plan's Phase 3 (Lean bounded model soundness) would close this gap by proving that any finite model satisfying the Z3 constraints constitutes a valid TaskFrame countermodel.

### 8. What BimodalLogic Must Provide for the Positive Signal

For the dual architecture to work, BimodalLogic needs to provide:

1. **Already exists**:
   - Formula enumeration (`FormulaEnumerator.lean`)
   - Validity labeling (`DatasetGenerator.labelFormula()`)
   - Proof step extraction (`ProofStepExtractor.extractStepSequence()`)
   - JSONL export (`DatasetExporter.lean`, `DatasetExport.lean`)
   - Conformance testing (`DatasetValidator.lean`)
   - Countermodel extraction (`CountermodelExtraction.lean`, `EnrichedCountermodel.lean`)

2. **Missing / needs creation**:
   - **VerifierProvider Python wrapper**: A `bmlogic-verifier` package that wraps `lake exe` calls and satisfies the `VerifierProvider` protocol. This enables entry-point discovery in BimodalHarness.
   - **Proof step JSONL in VerifierProvider format**: The existing proof_steps.jsonl needs to match the `ProofStepRecord` schema expected by `extract_proof_steps()`
   - **Entry-point registration**: `pyproject.toml` with `[project.entry-points.'bimodal_harness.verifier_providers']`

## Recommended Approach

1. **Task 226 should be REDEFINED to cover the POSITIVE signal** (VerifierProvider), not just negative signal integration. The negative signal work is now entirely in ModelChecker tasks 99-105.

2. **The cross-signal consistency check is the capstone** — it only works when both providers are registered. Neither can be tested in isolation for cross-signal soundness.

3. **Lean bounded model soundness proof** (plan Phase 3) is valuable but NOT blocking — the runtime cross-validation via `LeanSubprocessValidator` provides equivalent assurance for practical purposes.

4. **Timeout formulas should be run through both oracle and verifier**, with results compared. This is pure coverage gain requiring no new infrastructure beyond the two providers.

## Evidence/Examples

| Finding | Source | Line(s) |
|---------|--------|---------|
| CrossSignalConsistencyChecker | BimodalHarness signal/consistency.py | 40-127 |
| SoundnessGateway 3-phase preflight | BimodalHarness oracle/gateway.py | 267-389 |
| LeanSubprocessValidator | BimodalHarness oracle/gateway.py | 106-211 |
| VerifierProvider protocol | BimodalHarness verifier/protocol.py | 74-100 |
| Soundness sorry-free | BimodalLogic Metalogic/Soundness.lean | 60-78 |
| FMP sorry-free | BimodalLogic Metalogic/Decidability/FMP/FMP.lean | exists |
| Formula.toJson 6-tag schema | BimodalLogic Automation/DataExport.lean | 96-116 |
| ProofStepExtractor | BimodalLogic Automation/ProofStepExtractor.lean | 1-38 |
| DatasetValidator | BimodalLogic Automation/DatasetValidator.lean | 1-36 |
| VerifierProvider creation (task 28 design) | BimodalHarness specs/TODO.md | Task 28 description |

## Confidence Level

**High** — Based on direct source code reading across all three repositories. The dual-signal architecture is well-designed with multiple soundness layers. The main gap is that task 226 as currently scoped misses the positive-signal provider, which is the BimodalLogic-side counterpart needed for the full handshake.
