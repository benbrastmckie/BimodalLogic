# ForMathlib

Mathlib-shaped extensions intended for upstreaming. Everything under this directory is written in
Mathlib's own namespaces, with lemma names one-for-one with the Mathlib declarations they dualise
or extend, so that when a file is upstreamed it is simply deleted here and no consumer changes a
name.

The convention of a `ForMathlib/` directory beside a project's own tree follows downstream-project
precedent such as `PFR/ForMathlib/` and `LeanLTL/ForMathlib.lean`; it is project precedent, not a
Mathlib rule.

## Dependency rule

The import direction is strictly `Mathlib → ForMathlib → FormalSystem.* → downstream`.

**Nothing under `FormalSystem/ForMathlib/` imports `FormalSystem.*`.** A module intended for
Mathlib may not depend on this repository. Checkable by

```
grep -rn '^import FormalSystem' FormalSystem/ForMathlib/
```

which returns nothing.

The rule is stated for the files *under* this directory, not for the sibling aggregator. The
aggregator `FormalSystem/ForMathlib.lean` imports `FormalSystem.Init` in addition to its members:
every `FormalSystem` module must transitively import `FormalSystem.Init` (enforced check C24 in
`scripts/check-module-invariants.sh`), and the modules here may not, so the aggregator carries
that import on its consumers' behalf. Every module under this directory is therefore a recorded
C24 exception, listed in `scripts/CheckInitImportsMain.lean` and documented in
`FormalSystem/Init.lean`. It is not a violation of the dependency rule.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/ForMathlib rows=subdirs cols=files-lines link=yes -->
| Directory | Files | Lines | Role |
|-----------|------:|------:|------|
| [`Order/`](Order/README.md) | 1 | 270 | Proper, maximal and prime filters (`Order.PFilter.IsProper`, `Order.PFilter.IsMaximal`, `Order.PrimeFilter`) |
| [`Topology/`](Topology/README.md) | 1 | 245 | Sierpiński's theorem on countable closed partitions of the line (`Sierpinski.const_of_isClosed_levelSet`, `Sierpinski.const_of_countable_range`) |
<!-- END GENERATED -->

## Related Documentation

- [`ForMathlib.lean`](../ForMathlib.lean) — the sibling aggregator, which also states the
  dependency rule
- [`Order/`](Order/README.md) — proper, maximal and prime filters, the filter side of Mathlib's
  `Order/Ideal.lean` and `Order/PrimeIdeal.lean`
- [`Topology/`](Topology/README.md) — Sierpiński's theorem on countable closed partitions of the
  line, which Mathlib does not carry
- [`Metalogic/Algebraic/`](../Metalogic/Algebraic/README.md) — the consumer: the
  Lindenbaum–Tarski quotient and the ultrafilter/MCS correspondence
- [FormalSystem README](../README.md)

---

*Last verified: 2026-09-21*
