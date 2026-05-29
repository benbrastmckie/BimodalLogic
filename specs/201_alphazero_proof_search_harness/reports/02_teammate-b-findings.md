# Teammate B Findings: Alternative Approaches for Corrective Training Signal

**Task**: 201 — AlphaZero-style proof search harness (Round 2: ModelChecker integration)
**Angle**: Alternative patterns and prior art
**Date**: 2026-05-29

---

## Key Findings

### 1. The Lean Decidability Procedure Already Provides Countermodels — No Python Needed

**Confidence**: High (confirmed by code inspection)

The Lean codebase already contains a complete countermodel extraction pipeline in `Metalogic/Decidability/`:

- `DecisionProcedure.lean` defines `DecisionResult φ` — a sum type returning either `valid (proof : ⊢ φ)` or `invalid (counter : SimpleCountermodel)` or `timeout`
- `CountermodelExtraction.lean` extracts `SimpleCountermodel` from open tableau branches, providing `trueAtoms` and `falseAtoms` lists
- `findCountermodel : Formula → Nat → CountermodelResult φ` is a ready-to-use API

**Critical implication**: The positive signal (proof certificates) AND the negative signal (countermodels) can both come from Lean itself, without any dependency on the Python ModelChecker. The `decide` function already returns both:

```lean
def decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000)
    : DecisionResult φ  -- valid proof | invalid counter | timeout
```

This is **substantially simpler** than integrating the Python ModelChecker as a separate corrective signal source. The Lean decision procedure produces countermodels that are verified by the same trusted codebase.

**Limitation**: The current `SimpleCountermodel` only captures atom truth/falsity — it does not extract full task-frame structures (world histories, time intervals, task relations). The Python ModelChecker provides richer countermodels. However, for training signal purposes, the atomic truth assignment may suffice: it tells the neural network _which atoms to flip_ to break the inference.

### 2. The Python ModelChecker Provides Richer but Slower Countermodels

**Confidence**: High (confirmed by code inspection)

The ModelChecker's `BimodalStructure` extracts full semantic models including:
- World histories (time → state mappings per world)
- Task relations (valid transitions between states)
- Time-shift relations between worlds
- Full truth conditions at world states
- Model iteration via `BimodalModelIterator` for diverse countermodels

This richness is valuable for **interpretable** corrective signals — the neural network can learn _why_ an inference fails, not just _that_ it fails. However:
- The Z3 solver is orders of magnitude slower than the tableau procedure
- The ModelChecker's operator set (15 operators) is outdated relative to the Lean codebase (42 axiom constructors + 7 rules)
- Integration requires a Python↔Lean bridge

**The outdatedness problem**: The ModelChecker's `operators.py` implements `\neg`, `\wedge`, `\vee`, `\rightarrow`, `\leftrightarrow`, `\bot`, `\top`, `\Box`, `\Diamond`, `\Future`, `\Past`, `\future`, `\past`. But the Lean `Axioms.lean` has 42 axiom constructors covering a much broader proof vocabulary. Any formula using operators not in the ModelChecker (e.g., Until/Since if they exist in the full Logos but not the bimodal fragment) would fail to generate countermodels.

### 3. Three Alternative Corrective Signal Strategies

**Confidence**: Medium-High

| Strategy | Source | Richness | Speed | Integration Cost |
|----------|--------|----------|-------|------------------|
| **A: Lean tableau countermodel** | `findCountermodel` in Lean | Low (atoms only) | Fast (native Lean) | Zero (already exists) |
| **B: Standalone Z3 script** | New Python/Z3 script in BimodalLogic | High (full frames) | Medium (Z3 calls) | Medium (write fresh, ~500 LOC) |
| **C: ModelChecker integration** | Existing ModelChecker API | High (full frames) | Slow (Z3 + overhead) | High (bridge + version sync) |

**Strategy A** is the clear Phase 1 choice. **Strategy B** is recommended for Phase 2 — building a lightweight standalone Z3 countermodel generator in the BimodalLogic project that mirrors only the semantic constraints needed. This avoids the ModelChecker's version drift problem while providing rich countermodels.

**Strategy C** (full ModelChecker integration) is the Phase 3 option, only worthwhile if the richer countermodel structure proves essential for training quality AND the ModelChecker gets updated to match the Lean formalization.

### 4. Prior Art: Dual-Signal Training Approaches

**Confidence**: Medium (based on literature survey)

**DeepSeek-Prover V1.5/V2**: Uses binary reward (proof compiles = 1, doesn't = 0). No explicit countermodel signal. Negative examples are simply failed proof attempts. The system selects training theorems where the model has moderate success rate, ensuring both positive and negative signals.

**PACT (Proof Artifact Co-Training)**: Co-trains on proof terms as self-supervised targets. Negative signal comes from unprovable goals (where the tactic fails). No countermodels, but proof trace structure is used.

**"Learning to Disprove" (2025, arxiv:2603.19514)**: Explicitly trains LLMs to generate formal counterexamples. Uses a mutation strategy that discards necessary hypotheses to create counterexample problems. The CounterMath dataset provides 1,216 counterexample benchmark problems. This is the closest prior art to the dual-verification architecture.

**Isabelle Nitpick/Quickcheck**: Isabelle's model finder generates finite countermodels for invalid conjectures. `lean-smt` (LeanSMT) provides SMT integration for Lean 4 but focuses on proof discharge, not countermodel extraction. No published work on feeding Nitpick countermodels into neural training pipelines.

**Key insight from prior art**: No existing system uses Z3-generated countermodels with full semantic structure as RL training signals. The "Learning to Disprove" work generates counterexamples in natural language, not formal countermodels. This means the dual-verification architecture described in the technical memo is genuinely novel — but also unproven.

### 5. Lean-Native Z3 Integration via lean-smt

**Confidence**: Medium

The `lean-smt` project (LeanSMT) provides Lean 4 ↔ Z3/CVC5 integration. It translates Lean goals to SMT queries and reconstructs proofs. However:

- It focuses on **proof discharge** (proving goals), not **countermodel extraction**
- It could potentially be adapted to extract countermodels from UNSAT cores
- Performance on Isabelle-derived benchmarks shows subsecond proof times for 98% of problems
- This would provide Z3-powered countermodels without leaving Lean

This is a potential future path that avoids the Python bridge entirely, but requires significant development effort.

### 6. Training Data Format Considerations

**Confidence**: Medium

For encoding bimodal logic formulas as training data:

- **S-expression format**: Standard for formal logic (e.g., `(Box (Imp (Atom "p") (Atom "q")))`). Already implicit in Lean's `Formula` inductive type.
- **Prefix notation tokenization**: Used by PACT, maps well to tree-structured formulas.
- **Structured output**: For countermodels, a JSON format capturing `{formula, trueAtoms, falseAtoms, isValid, proofDepth}` would suffice for Phase 1.
- **Rich countermodel format**: For Phase 2, `{formula, worldHistories: [{worldId, timeStates: [{time, state}]}], taskRelations: [{from, to}], truthConditions: [{atom, state, value}]}` enables the neural network to learn from semantic structure.

The formula enumerator (task 203, not yet started) would need to output in a compatible format. The existing `decide` API returns `DecisionResult` which already contains both proof terms and countermodel descriptions — the export format is the main gap.

### 7. Synthetic Negative Example Generation

**Confidence**: High

Even without countermodels, invalid formulas can be generated synthetically:

1. **Enumerate and filter**: Generate all formulas up to depth d, run `decide`, partition into valid/invalid
2. **Mutation**: Take valid formulas, swap one operator (e.g., `Box → Future`), creating plausibly-but-not-actually valid formulas — these are harder negatives
3. **Premise removal**: Take valid inferences `{Γ ⊢ φ}`, drop one premise to create invalid inferences (the "Learning to Disprove" mutation strategy)
4. **Temporal duality breaking**: Valid formulas under duality can be broken by asymmetric mutations

Strategy 2 (mutation) produces the hardest negative examples because they are structurally similar to valid formulas. This is exactly the kind of training signal that helps the neural network learn subtle distinctions.

---

## Recommended Approach

**Phase 1 (immediate, zero integration cost)**: Use the Lean-native `decide`/`findCountermodel` as both positive and negative signal source. Export `(formula, DecisionResult)` pairs via task 203's enumerator. The `SimpleCountermodel` atom lists provide a lightweight corrective signal.

**Phase 2 (if Phase 1 training quality insufficient)**: Build a standalone `countermodel_generator.py` (500 LOC) in the BimodalLogic project that takes formula strings, constructs Z3 constraints matching the Lean semantics, and outputs rich countermodels with world histories and task relations. This avoids ModelChecker version drift.

**Phase 3 (if rich countermodels prove essential)**: Integrate the full ModelChecker, but ONLY after updating its operator set to match the Lean formalization. The `iterate.py` model iteration could generate diverse countermodels for each invalid formula, enriching the training distribution.

**Do NOT start with ModelChecker integration** — it's the highest cost, highest risk option, and the Lean-native alternative already exists.

---

## Evidence/Examples

### Lean Countermodel API (already working)

```lean
-- From DecisionProcedure.lean
#eval do
  let result := decide (Formula.imp (Formula.box (.atom ⟨"p", none⟩))
                                     (Formula.allFuture (.atom ⟨"p", none⟩)))
  match result with
  | .valid proof => IO.println "Valid with proof"
  | .invalid cm => IO.println s!"Invalid: {cm.display}"
  | .timeout => IO.println "Timeout"
```

### Minimum Viable Standalone Z3 Generator (~50 LOC core)

```python
import z3

def check_validity(formula_str, N=2, M=2):
    """Check if a bimodal formula is valid, return countermodel if not."""
    # Parse formula_str into Z3 constraints matching Lean semantics
    # (WorldStateSort, TimeSort, WorldIdSort, task relation, etc.)
    solver = z3.Solver()
    # ... add frame constraints ...
    # ... add negation of formula ...
    if solver.check() == z3.sat:
        model = solver.model()
        return {"valid": False, "countermodel": extract_model(model)}
    else:
        return {"valid": True, "countermodel": None}
```

This is much simpler than the full ModelChecker because it doesn't need proposition display, model iteration, or the general-purpose theory framework.

---

## References

- [DeepSeek-Prover-V1.5: Harnessing Proof Assistant Feedback for RL and MCTS](https://arxiv.org/pdf/2408.08152)
- [DeepSeek-Prover-V2: Advancing Formal Mathematical Reasoning via RL](https://arxiv.org/pdf/2504.21801)
- [Learning to Disprove: Formal Counterexample Generation with LLMs](https://arxiv.org/pdf/2603.19514)
- [Proof Artifact Co-training for Theorem Proving with Language Models](https://arxiv.org/pdf/2102.06203)
- [lean-smt: An SMT Tactic for Discharging Proof Goals in Lean](https://www.researchgate.net/publication/393948518_lean-smt_An_SMT_Tactic_for_Discharging_Proof_Goals_in_Lean)
