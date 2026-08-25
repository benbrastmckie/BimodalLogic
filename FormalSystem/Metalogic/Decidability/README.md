# Decidability - Tableau Decision Procedure for TM Logic

Tableau-based decision procedure for TM bimodal logic validity checking, returning proof
terms or countermodels.

## Overview

This directory implements a tableau search procedure that:
- Searches, via tableau expansion, for a proof of `φ` or a countermodel to `φ` — this does not by
  itself establish decidability of TM validity
- The **sound direction** of the `isValid`-shaped statement, `isValid φ fc = true → ⊨ φ`, is
  proved and landed: `sound_of_isValid` and `isValid_sound` (`Correctness.lean`), sorry-free,
  along with the `isTautology` / `isContradiction` / `isSatisfiable` siblings and the
  frame-class-relativized forms. `decide_sound` (same file) is the corresponding corollary at the
  empty context: a proof `decide` returns (its `.valid` constructor) yields `⊨ φ`
- The full decidability biconditional — `isValid φ fc = true ↔ ⊨ φ`, plus `Decidable (⊨ φ)`
  instances for the four frame classes — is not established; see `Correctness.lean`'s
  "`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous" section
- Returns proof terms (`DerivationTree`) when valid
- Returns countermodel descriptions when invalid
- Uses fuel-based termination for practical execution

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `SignedFormula.lean` | Sign, SignedFormula, Branch types | Sorry-free |
| `Tableau.lean` | Tableau expansion rules (propositional, modal, temporal) | Sorry-free |
| `TraceCertificate.lean` | Defines `TraceEntry`/`ProofCertificate`/`TraceResult`; imported directly by both `Saturation.lean` and `DecisionProcedure.lean` — a core dependency, not peripheral | Sorry-free |
| `Saturation.lean` | Saturation and fuel-based termination | Sorry-free |
| `Closure.lean` | Branch closure detection | Sorry-free |
| `Correctness.lean` | Soundness proof | Sorry-free |
| `ProofExtraction.lean` | Extract DerivationTree from closed tableau | Sorry-free |
| `CountermodelExtraction.lean` | Extract countermodel from open branch | Sorry-free |
| `DecisionProcedure.lean` | Main `decide` function with proof search | Sorry-free |
| `CancellableExpansion.lean` | Runtime-only `IO` abort-aware mirror of the pure tableau core; imports `Saturation.lean` and `DecisionProcedure.lean`; not imported by the aggregator | Sorry-free |
| `TraceExport.lean` | JSON serialization for trace certificates; consumed by `Automation/TraceExporter.lean` rather than by the aggregator | Sorry-free |
| `IntPresentation.lean` | Computational presentation of a finite ℤ-time frame (`Fin card` adjacency matrix + valuation) | Sorry-free |
| `BiLasso.lean` | Re-export for BiLasso subdirectory | Sorry-free; not itself imported by the main library build graph (one test file, `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean`, does import it) |
| `FMP/` | Finite model property proofs (6 files) | Sorry-free |
| `BiLasso/` | Finitely presented bi-infinite ultimately-periodic step paths over an `IntPresentation` — the decision layer for *presented* ℤ-frames. Entry point `check` decides satisfiability at a state of one presented frame; it does **not** decide the logic (18 files) | Sorry-free; outside the build graph (the re-export is unimported), compile-checked by the C6 rot guard |
| `Verified/` | Correctness theory for the tableau engine — termination bounds and the model-construction bridge; all files imported by the aggregator. See [Verified README](Verified/README.md) (21 files) | Sorry-free |
| `Propositional/` | Self-contained Kalmár-style propositional decision procedure, independent of the modal/temporal/completeness machinery; all files imported by the aggregator. See [Propositional README](Propositional/README.md) (3 files) | Sorry-free |

## Quick Reference

- **Main entry point**: `decide` in `DecisionProcedure.lean`
- **Blocking entry point**: `decideBlocking` in `DecisionProcedure.lean` — a documented complement
  to `decide` for the blocking-aware engine, not a substitute for it
- **Boolean helpers**: `isValid`, `isSatisfiable`
- **Result type**: `DecisionResult` (valid/invalid/fuelExhausted/extractionFailed). Post-R7, the
  single prior inconclusive-verdict constructor was split into `fuelExhausted` (validity genuinely
  undetermined) and `extractionFailed` (the tableau closed, so the formula is valid, but no proof
  term was reconstructed) — see `decide_result_exclusive` in `Correctness.lean`

## Algorithm Overview

1. **Optimization**: First try direct proof search for shallow proofs
2. **Tableau**: Build tableau for `F(phi)` (asserting `phi` is false)
3. **Analysis**:
   - All branches close -> `phi` is valid, extract proof
   - Open saturated branch -> `phi` is invalid, extract countermodel

## Usage

```lean
import FormalSystem.Metalogic.Decidability

open FormalSystem.Metalogic.Decidability

#check decide        -- Main decision procedure
#check isValid       -- Boolean validity check
#check isSatisfiable -- Boolean satisfiability check
```

## Dependency Flowchart

This diagram shows the core chain only. Deliberately omitted: `IntPresentation.lean`,
`CancellableExpansion.lean`, `TraceExport.lean`, `BiLasso.lean` (imported by one test file,
`Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean`, but not by the main library build
graph), and the `Verified/` and `Propositional/` subtrees.

```
      ┌─────────────────────────────────────────────────┐
      │          DecisionProcedure.lean                 │
      │       (decide, isValid, isSatisfiable)          │
      └─────────────────────────────────────────────────┘
                               │
         ┌─────────────────────┴──────────────────────┐
         v                     v                      v
┌─────────────────┐   ┌─────────────────┐   ┌───────────────────┐
│ ProofExtraction │   │ Countermodel    │   │ TraceCertificate  │
│   .lean         │   │ Extraction.lean │   │      .lean        │
└─────────────────┘   └─────────────────┘   └───────────────────┘
         │                     │
         └──────────┬──────────┘
                    v
           ┌─────────────────┐
           │ Saturation.lean │
           └─────────────────┘
                    │
            ┌──────────────┐
            │ Closure.lean │
            └──────────────┘
                    │
            ┌──────────────┐
            │ Tableau.lean │
            └──────────────┘
                    │
         ┌────────────────────┐
         │ SignedFormula.lean │
         └────────────────────┘
```

`TraceCertificate.lean` is also imported directly by `Saturation.lean` (a second edge into the
same node, not drawn above to avoid a crossing line).

`Correctness.lean` is a downstream consumer of `DecisionProcedure.lean` — it imports
`DecisionProcedure.lean`, not the reverse — and it also imports `FMP/FMP.lean`:

```
                            ┌──────────────────┐
                            │ Correctness.lean │
                            │  (decide_sound)  │
                            └──────────────────┘
                                      │
                     ┌────────────────┴────────────────┐
                     v                                 v
┌─────────────────────────────────────────┐    ┌──────────────┐
│          DecisionProcedure.lean         │    │ FMP/FMP.lean │
│      (above — downstream consumer,      │    └──────────────┘
│            not between it and           │
│ ProofExtraction/CountermodelExtraction) │
└─────────────────────────────────────────┘
```

## Complexity

- Time: `O(2^n)` where `n` = formula complexity (PSPACE-complete)
- Space: `O(n)` for DFS-based tableau expansion
- Typical formulas: Much faster due to pruning and optimization

## Related Documentation

- [Metalogic README](../README.md) - Overall metalogic architecture
- [Bundle README](../Bundle/README.md) - BFMCS completeness approach
- [Core README](../Core/README.md) - MCS foundations
- [FMP README](FMP/README.md) - Finite model property
- [BiLasso README](BiLasso/README.md) - Bi-lasso decision layer for presented ℤ-frames
- [Verified README](Verified/README.md) - Correctness theory for the tableau engine
- [Propositional README](Propositional/README.md) - Kalmár-style propositional decision procedure

## References

- Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
- Wu, M. Verified Decision Procedures for Modal Logics (Lean formalization)

---

*Last verified: 2026-08-19*
