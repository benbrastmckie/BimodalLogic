# Research Report: Task #201 — Corrective Training Signal via ModelChecker Integration

**Task**: 201 — Set up AlphaZero-style proof search harness for bimodal logic
**Date**: 2026-05-29
**Mode**: Team Research (4 teammates, Round 2)
**Session**: sess_1780074564_ce378f
**Focus**: Using the ModelChecker's bimodal logic as a corrective training signal

---

## Summary

Four researchers investigated integrating the Python/Z3-based ModelChecker as a corrective training signal source, complementing the Lean ProofChecker's positive signal (proof certificates). The unanimous finding is that **the ModelChecker is semantically incompatible with the ProofChecker in its current state** — using it directly would produce incorrect training data. However, the investigation uncovered a superior alternative: the Lean codebase already contains a countermodel extraction pipeline (`Decidability/CountermodelExtraction.lean`) that provides both positive and negative signals from the same trusted codebase, with zero integration cost.

**Recommended path**: A three-tier corrective signal strategy —
1. **Tier 1 (immediate)**: Use the Lean-native `decide`/`findCountermodel` API for dual-signal training data
2. **Tier 2 (if richer signals needed)**: Build a standalone Z3 countermodel generator (~500 LOC) aligned to the ProofChecker's semantics
3. **Tier 3 (long-term)**: Update the ModelChecker to match the ProofChecker, enabling the full dual verification architecture described in the technical memo

---

## Key Findings

### 1. The ModelChecker Is Semantically Incompatible with the ProofChecker

**Confidence**: HIGH (confirmed independently by Teammates A, C; corroborated by B, D)

The ModelChecker and ProofChecker implement **different logics**, not merely different implementations of the same logic. Seven concrete divergences were identified:

| Feature | ProofChecker (Lean 4) | ModelChecker (Python/Z3) | Severity |
|---------|----------------------|--------------------------|----------|
| Temporal primitives | Until U(φ,ψ), Since S(φ,ψ) | G (Future), H (Past) only — **no Until/Since** | CRITICAL |
| Frame classes | 3: Base, Dense, Discrete | 1: effectively discrete (integer times only) | CRITICAL |
| Temporal quantification | All times in domain D with strict < | Only times within world's interval | CRITICAL |
| Time type | Parametric: Int, Rat, Real | Fixed integer [-M+1, M-1] | CRITICAL |
| Box quantification | ∀ σ ∈ Omega (shift-closed) | ∀ valid world IDs with time-validity guard | HIGH |
| Task relation | Ternary: task_rel w d u (with duration, nullity, compositionality, converse) | Binary: task(w, u) (unit transitions only) | HIGH |
| Abundance | ShiftClosed for arbitrary Δ | Skolem functions for ±1 shifts only | MEDIUM |

**Critical consequence**: 22 of the 42 BX axiom constructors involve Until/Since, which the ModelChecker cannot express at all. Formulas containing Until/Since — the majority of non-trivial temporal reasoning — cannot be checked. Even for the G/H/Box fragment, the temporal quantification scope difference means the ModelChecker could generate **spurious countermodels** (countermodels that are valid in the ModelChecker's semantics but not in the ProofChecker's) or **miss countermodels** (formulas invalid in the ProofChecker but appearing valid in the ModelChecker's bounded search).

**Bottom line**: Using the ModelChecker as-is for corrective training signals would teach the neural network incorrect information about what constitutes valid/invalid reasoning in the ProofChecker's logic.

### 2. The Lean Codebase Already Contains a Countermodel Extraction Pipeline

**Confidence**: HIGH (Teammate B, confirmed by code inspection)

The `Metalogic/Decidability/` module provides a complete decision procedure that returns **both** proof certificates and countermodels:

```lean
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    : DecisionResult φ  -- valid proof | invalid counter | timeout
```

- `DecisionResult.valid proof` → positive signal (proof certificate)
- `DecisionResult.invalid counter` → corrective signal (`SimpleCountermodel` with `trueAtoms`/`falseAtoms`)
- `DecisionResult.timeout` → unknown (properly flagged)

**Advantages over ModelChecker integration**:
- Zero integration cost — already exists in the same codebase
- Guaranteed semantic alignment — uses the same formalization
- No Python bridge needed — stays entirely in Lean
- No version drift risk — single source of truth

**Limitation**: `SimpleCountermodel` only captures atom truth/falsity from open tableau branches. It does not extract full task-frame structures (world histories, time intervals, task relations). The ModelChecker provides richer countermodels — but only after semantic alignment.

### 3. No Published System Uses Structured Countermodels as RL Training Signals

**Confidence**: HIGH (Teammates B, D — literature survey)

The dual verification architecture is genuinely novel in the ML-for-theorem-proving literature:

| System | Positive Signal | Negative Signal | Countermodel? |
|--------|----------------|-----------------|---------------|
| AlphaProof | Proof success | Discarded failures | No |
| DeepSeek-Prover | Binary (compiles/not) | Binary (doesn't compile) | No |
| PACT | Proof traces | Failed tactics | No |
| "Learning to Disprove" (2026) | N/A | Mutated hypotheses → counterexamples | Syntactic only |
| **Logos (proposed)** | **Proof certificates** | **Structured semantic countermodels** | **Yes — first** |

The closest work is "Learning to Disprove" (arXiv:2603.19514, March 2026), which trains LLMs to generate counterexamples via syntactic mutation. The Logos approach is structurally stronger: Z3 constructs explicit semantic models (world histories, task relations, truth valuations) demonstrating exactly *how* an inference fails, not just *that* it fails.

**Business implication**: For Stage 1 of the commercialization strategy (selling training data), the dual signal is the differentiator. Proof-only data is commoditized; structured countermodels paired with proofs are novel and defensible.

### 4. Three-Tier Corrective Signal Strategy

**Confidence**: MEDIUM-HIGH (synthesized from all teammates)

| Tier | Source | Richness | Speed | Cost | When |
|------|--------|----------|-------|------|------|
| **1: Lean-native** | `findCountermodel` | Low (atoms only) | Fast | Zero | Now |
| **2: Standalone Z3** | New Python/Z3 script (~500 LOC) | High (full frames) | Medium | Medium | If Tier 1 insufficient |
| **3: ModelChecker** | Updated ModelChecker | Highest (+ iteration) | Slow | High | Long-term |

**Tier 1** (immediate): Use the existing `decide` API. The formula enumerator (task 203) already generates formulas; running `decide` on each produces labeled training data with proof traces (positive) and atom-level countermodels (corrective). This is sufficient for Phase 1 of the training pipeline (value estimator).

**Tier 2** (escalation): If Tier 1's shallow countermodels prove insufficient for training quality, build a standalone `countermodel_generator.py` in the BimodalLogic project. This would:
- Parse formula ASTs from Lean-exported JSON
- Construct Z3 constraints matching the ProofChecker's semantics (strict temporal quantification, Until/Since, frame class selection)
- Extract full task-frame countermodels (world histories, time intervals, task relations)
- Export structured JSON for the training pipeline
- ~500 LOC, no dependency on the ModelChecker codebase, no version drift

**Tier 3** (long-term): Update the full ModelChecker to match the ProofChecker's semantics. This unlocks the model iteration infrastructure (diverse countermodels per formula), display capabilities, and enables the ModelChecker to serve the broader Logos vision. Required changes:
1. Add Until/Since operators to `operators.py` (Z3 encoding well-understood)
2. Switch to strict temporal quantification where needed
3. Add frame class support (Base/Dense/Discrete parameter)
4. Update task relation to ternary with duration
5. Add nullity_identity, forward_comp, converse constraints

### 5. Countermodels Enable More Than Binary Negative Signals

**Confidence**: MEDIUM-HIGH (Teammate D)

Structured countermodels serve multiple training functions beyond simple "wrong" labels:

- **Structured negative RL signal**: The countermodel explains *which atoms to flip* and *which world structure witnesses the failure*
- **Curriculum design**: Countermodel complexity (world count, time points, task transitions) provides a natural difficulty metric for curriculum learning
- **Adversarial training**: Generate near-miss invalid formulas (mutations of theorems) with countermodels showing exactly how the mutation breaks validity
- **Semantic proof guidance**: Failed countermodel construction reveals which subformulas are "hard," guiding the prover toward productive search directions
- **Dueling networks**: Train competing prover and refuter networks, where the refuter uses the ModelChecker — the only domain where both sides have formal verification

### 6. Publication Opportunity Is Strong

**Confidence**: HIGH (Teammate D)

"Dual Verification for Neural Theorem Proving: Proof Certificates and Countermodels as Complementary Training Signals" — targeting ICML/NeurIPS/CADE. Novel contribution distinct from "Learning to Disprove" (semantic model construction vs. syntactic mutation). The infrastructure already exists across tasks 201 and 203.

---

## Synthesis

### Conflicts Resolved

**Conflict 1: Update ModelChecker vs. Use Lean-native vs. Build standalone Z3**
- Teammate A recommends updating the ModelChecker first (Architecture A)
- Teammate B recommends starting with Lean-native, escalating to standalone Z3
- Teammate C recommends Lean decidability procedure as primary
- Teammate D recommends hybrid Option C (update ModelChecker + adapter)

**Resolution**: The three-tier strategy resolves this by establishing a clear escalation path. Start with Lean-native (unanimous agreement that this has zero cost and is semantically guaranteed). Only invest in Z3-based countermodels if the atom-level signal proves insufficient for training quality. Only update the full ModelChecker as a long-term investment for the broader Logos vision.

**Conflict 2: Is the ModelChecker update prerequisite or optional?**
- Teammates A and C treat it as prerequisite for ANY ModelChecker integration
- Teammate D treats it as the recommended path (Option C hybrid)
- Teammate B demonstrates it's not needed for Phase 1 at all

**Resolution**: The ModelChecker update is prerequisite for Tier 3 integration but NOT for the overall training pipeline. Tier 1 (Lean-native) and Tier 2 (standalone Z3) bypass the ModelChecker entirely. The update becomes important only when (a) the full Logos vision requires it, or (b) model iteration/diversity proves essential for training quality.

### Gaps Identified

1. **Lean countermodel export format**: The `SimpleCountermodel` type exists but no JSON export pipeline has been built. Task 203's enumerator exports formulas but not decision results. This is a concrete gap for Tier 1.

2. **Conformance test suite**: Before using any corrective signal source (Lean-native, standalone Z3, or ModelChecker), a cross-validation suite should verify agreement between the signal source and the ProofChecker on 1000+ formulas.

3. **Dense frame class countermodels**: None of the three tiers can generate countermodels for the dense frame class. The Lean decidability procedure works on finite models; Z3 uses integer sorts; the ModelChecker uses bounded integers. This is an inherent limitation for formulas valid in discrete but invalid in dense frames.

4. **Countermodel-to-tensor encoding**: No existing work provides a template for encoding modal logic countermodels as training tensors. This is novel engineering that needs design and experimentation.

---

## Recommendations

### Immediate Next Steps

1. **Extend task 203's export pipeline** to include `DecisionResult` data — export `(formula, label, proof_trace_or_countermodel)` tuples in JSON
2. **Build a conformance test**: Run `decide` on all BX axiom instances and known non-theorems to validate the countermodel extraction
3. **Design the training data schema** with extensibility for the full Logos (generic operator set, multiple relation types, dense time support)

### Strategic

4. **Do NOT block on ModelChecker update** — proceed with Tier 1 for the training pipeline
5. **Plan a separate task** for ModelChecker semantic alignment (Until/Since, frame classes, ternary task relation) as a Tier 3 investment
6. **Target the dual verification paper** as the first publication from this work

---

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | Primary Implementation | completed | Identified 7 semantic divergences, formula translation design, pipeline architecture | high |
| B | Alternative Approaches | completed | Discovered Lean-native countermodel API, three-tier strategy, prior art survey | high |
| C | Critic | completed | Severity-ranked divergences (4 critical, 3 high), conformance test suite design | high |
| D | Horizons | completed | Strategic alignment, publication framing, creative training architectures | high |

## References

- "Learning to Disprove" (arXiv:2603.19514, March 2026) — closest prior art
- DeepSeek-Prover V1.5/V2 — binary reward RL for theorem proving
- PACT — proof artifact co-training
- LeanDojo/LeanProgress — Lean 4 ML infrastructure
- Aristotle (Harmonic Team, 2025) — AND/OR hypergraph proof search
- Technical memo: `/home/benjamin/Projects/Logos/Vision/shared/strategy/01-overview/03-technical_memo.typ`
