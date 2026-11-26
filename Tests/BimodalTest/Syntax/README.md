# Syntax Tests

Tests for formula syntax and context operations.

## Contents

| File | Description |
|------|-------------|
| FormulaTest.lean | Unit tests for Formula type |
| FormulaPropertyTest.lean | Property-based formula tests |
| ContextTest.lean | Context (list of formulas) tests |
| LanguageDerivationTest.lean | Worked derivations in TM⁻, TM⁺ and TM⋆ |
| SentenceTranslationTest.lean | `#guard` rows pinning every row of the source-language elimination table, including the three that do not push through and the argument-order probes |
| ConnectivesTest.lean | Connective signature test suite: literal bodies, per-language stored bodies, library-type agreement, and rejection cases |
| FormulaSyntaxTest.lean | Operator recognition through the connective signature: `operatorArgs?` at `Formula`, `PlusFormula` and `StarFormula`, plus absence, rejection, rigid-reading and naming cases |

## Coverage

- Formula construction and pattern matching
- Context membership and manipulation
- Property-based testing for formula operations

## Related

- [Source: Syntax/](../../../FormalSystem/Syntax/)
- [Parent README](../README.md)

---

*Last Updated: 2026-09-27*
