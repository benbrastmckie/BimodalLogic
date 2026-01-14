# Research Summary: Property-Based Testing for Lean 4

## Key Findings

1. **Plausible is the only mature framework**: Plausible is the primary and only production-ready property-based testing framework for Lean 4, actively maintained by the Lean community with 74 stars and 16 forks.

2. **Excellent Lean integration**: Plausible integrates as both a tactic (`plausible`) and command (`#test`), with automatic derivation via `deriving Arbitrary` for custom types and automatic shrinking of counterexamples.

3. **No external dependencies**: Pure Lean implementation with no NPM/TypeScript dependencies, making integration straightforward via lakefile.lean.

4. **Ideal for metalogic testing**: Perfect for testing soundness, derivation properties, semantic properties, and proof search correctness in the Logos project.

5. **Comprehensive generator support**: Provides size-controlled generation, shrinking strategies, and configurable test parameters for custom modal logic types (Formula, Context, TaskFrame).

## Most Relevant Resources

- **Plausible Repository**: https://github.com/leanprover-community/plausible
- **Mathlib4 Documentation**: https://leanprover-community.github.io/mathlib4_docs/Plausible.html
- **Detailed Research Findings**: docs/research/property-based-testing-lean4.md
- **Plausible Test Suite**: Examples in Test/Plausible.lean

## Recommendations

**Use Plausible** as the property-based testing framework for Logos:
- Add dependency: `require plausible from git "https://github.com/leanprover-community/plausible" @ "main"`
- Create generators for Formula, Context, TaskFrame using `deriving Arbitrary` or manual instances
- Write property tests for metalogic properties (soundness), derivation rules, and semantic properties
- Integrate into CI/CD pipeline for continuous testing
- Expected effort: 6-10 hours for full integration and core property tests

## Full Report

See: `.opencode/specs/174_property_based_testing/reports/research-001.md`
