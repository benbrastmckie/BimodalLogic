# Automation Tests

Tests for proof automation tactics.

## Contents

| File | Description |
|------|-------------|
| TacticsTest.lean | Custom tactic tests |
| TacticsTest_Simple.lean | Simple tactic examples |
| ProofSearchTest.lean | Proof search tests |
| ProofSearchBenchmark.lean | Proof search benchmarks |
| EdgeCaseTest.lean | Edge case coverage |
| NormalizationTest.lean | Normalization, all four `Tactic/Attr.lean` simp sets (`formula_unfold`/`formula_fold` and `truth_norm`/`reflect_time_norm`), serialization and enumerator counts |
| LemmaDBTest.lean | The `@[tmLemma]` attribute database and `tryLemmaMatch` backward chaining, plus executed `MetaM`/`TermElabM` probes for `Tactic/Meta.lean`'s helpers |
| ProofModeTest.lean | Native compositional TM and TM⁺ scopes |
| ProofModeBooleanTest.lean | Boolean rewriting and simplifier diagnostics |
| ProofModeModalBooleanTest.lean | Modal simplification and named formula views |
| ProofModeTemporalBooleanTest.lean | Temporal rewriting and frame premises |
| ProofModeModalTemporalBooleanTest.lean | Rewriting across modal and temporal scopes |
| DatasetGeneratorTest.lean | Structural pre-filter pins and hybrid labelling smoke tests |

## Coverage

- apply_axiom tactic
- modal_t tactic
- modal_search automation
- Proof search algorithms
- Edge cases and failure modes
- The `Tactic/` support layer: all four `Attr.lean` simp sets, and `Meta.lean`'s
  `MetaM` helpers under executed probes rather than signature pins alone

## Related

- [Source: Automation/](../../../FormalSystem/Automation/)
- [Parent README](../README.md)

---

*Last Updated: 2026-11-19*
