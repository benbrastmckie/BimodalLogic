# Architecture

The layer graph of `FormalSystem/`, and the one set of edges that runs *upward* through it.

A reader who assumes the layering is a clean downward cascade will be wrong in one place, and
that exception is recorded rather than excused. It is drawn in the diagram below rather than
mentioned in passing, because a diagram that hides it misdescribes the build.

The table here and the `LAYERS` dictionary in `scripts/measure-refactor-partitions.py` state the
same order and must be changed together. [`ORGANISATION.md`](../ORGANISATION.md) carries the
same table in signpost form.

## The layer diagram

```
                         ┌──────────────────────────────────┐
  Layer 4  Examples      │  Examples/                       │
                         └───────────────┬──────────────────┘
                                         │ imports
                         ┌───────────────┴──────────────────┐
  Layer 3                │  Metalogic/       Automation/    │
                         │  soundness,       tactics,       │
                         │  completeness,    proof search    │
                         │  compactness,   ◄──── intra-layer │
                         │  decidability      Decidability/ →│
                         │                    {ProofSearch,  │
                         │                     Normalization}│
                         └───────────────┬──────────────────┘
                                         │ imports
                         ┌───────────────▼──────────────────┐
  Layer 2  Theorems      │  Theorems/                       │◄────────────┐
                         │  derived object-logic theorems   │             │
                         └───────────────┬──────────────────┘             │
                                         │ imports                        │
                         ┌───────────────▼──────────────────┐             │
  Layer 1  Semantics     │  Semantics/                      │             │
                         │  TaskFrame, PartialHistory,      │             │
                         │  TaskModel, TruthAt, validity    │             │
                         └───────────────┬──────────────────┘             │
                                         │ imports                        │
                         ┌───────────────▼──────────────────┐             │
  Layer 0  Foundation    │  Syntax/      ProofSystem/       │             │
                         │  ForMathlib/  Init.lean          │             │
                         │  Tactic/                         │             │
                         │                                  │             │
                         │  Syntax/MinusLanguage/           │             │
                         │    AxiomDischarge.lean ─────────────UPWARD ────┘
                         └──────────────────────────────────┘   7 lines
```

### The upward set: `Syntax/MinusLanguage/AxiomDischarge.lean → Theorems/*`

Seven import lines, all from one file, and the only genuinely upward set left in the library.
The L⁻ axiom-discharge proofs apply derived object-logic theorems (`Combinators`,
`DedekindDerived`, `DeductionTheorem`, `DiscreteUnfolding`, `GeneralizedNecessitation`,
`Propositional.Core`, `TemporalDerived`), and the file sits under `Syntax/` at layer 0.

They are **asserted, not trusted**: `bash scripts/check-metalogic-cycles.sh` fails if the upward
set is anything other than exactly those seven lines, on a surplus and on a shortfall alike. The
work that empties the allowlist is the `{Plus,Minus,Star}Language` directory merges in
[`development/PUBLICATION_REFACTOR.md`](development/PUBLICATION_REFACTOR.md), which move
`AxiomDischarge.lean` out of `Syntax/` entirely.

### Not upward: `Semantics → ProofSystem`

`Semantics/FrameClassValidity.lean` is the **only** module under `FormalSystem/Semantics/` that
imports anything from `FormalSystem/ProofSystem/`. It defines `FrameClass.Sat`, the semantic
reading of the proof-side `FrameClass` tag, so that the semantic side can be indexed by the same
tag the proof side already carries rather than by a hand-maintained binder list — which is what
keeps a frame class and its binder list from drifting apart.

It is a **downward** edge, not an upward one: `ProofSystem/` is at layer 0 and `Semantics/` at
layer 1. Earlier revisions of this page described it as upward while the diagram beside them put
`ProofSystem` below; the diagram was right. The edge closes no cycle — `ProofSystem/Axioms.lean`
imports only `Syntax/Formula.lean`, and nothing under `ProofSystem/` imports `Semantics`. The
decision, and the two relocations that were considered and rejected on cost, are in
[ADR-008](architecture/ADR-008-FrameClass-Validity-Seam.md).

### Not upward: `Decidability → {ProofSearch, Normalization}`

Three import lines from `Metalogic/Decidability/` into `Automation/`. `Metalogic/` and
`Automation/` share layer 3, so these are **intra-layer** edges, which is exactly what placing
library automation beside the metalogic rather than above it means. The decision procedure calls
the proof-search engine and the normalization lemmas; nothing under `Automation/` imports
`Decidability/`.

This is a different claim from the one an earlier revision of this page made. The ML dataset
pipeline that used to live in `Automation/` and consume the tableau procedure — `DataExport.lean`,
`TraceExporterMain.lean`, `TableauProofStepsMain.lean` — is no longer under `FormalSystem/` at
all: it is `lean_lib BimodalTools`, outside `defaultTargets`, and the tooling reaches the library
and never the reverse (check B3). `Automation/` today holds tactics and proof search, not a
dataset pipeline.

## Layer 0 in full

Layer 0 is five entries, and three of them are easy to miss:

| Module | Role | Constraint |
|--------|------|------------|
| `Syntax/` | `Formula` (six constructors), atoms, contexts, subformula closure; also parents the L⁻/L⁺/L⋆ language family (`Syntax/PlusLanguage/` and its siblings) | — |
| `ProofSystem/` | 29 axiom constructors (the paper's primitive schemata; mirrors derived in `DerivedAxioms`), 7 inference rules, `DerivationTree`, `FrameClass` | imports only `Syntax` |
| `ForMathlib/` | Mathlib-shaped proper/maximal/prime **filter** API | imports **nothing** from `FormalSystem.*` — it is intended for upstreaming |
| `Init.lean` | The library-wide preamble, modelled on `Mathlib.Init`: the linters and common tactics every module inherits, plus `Tactic.Attr` | check C24 asserts every module reaches it transitively |
| `Tactic/` | `Attr.lean`, every attribute and named simp set the library uses; `Meta.lean`, the shared `MetaM` plumbing for derivability goals | `Attr.lean` imports `Lean` **only** and carries attribute declarations and nothing else — `Init.lean` imports it, so anything heavier would be upstream of the whole library |

`Tactic/Attr.lean` is why no module imports an attribute module by name: `Init.lean` carries the
declarations on every module's behalf. Before the relocation those five declarations were three
modules under `Automation/`, which is why `Syntax/`, `Semantics/`, `ProofSystem/` and `Theorems/`
each carried an upward import into `Automation/` — eleven lines, all now deleted.

## The three completeness routes

`Metalogic/` is not one completeness proof but three, and they are siblings rather than layers:
the Chronicle route (`BXCanonical/`, the wired entry point), the Kamp/Reynolds route
(`WeakCanonical/`, by far the largest subtree) and the Algebraic route (`Algebraic/`). The other
two are not dead alternatives — `BXCanonical` imports from both.

There is exactly **one** directory-level import cycle in the tree, `BXCanonical ↔ WeakCanonical`,
which is why the routes are not nested under a common parent: directory structure cannot express
a mutual dependency. `bash scripts/check-metalogic-cycles.sh` enumerates the cycle edge-by-edge
and asserts the count is 1; [ADR-006](architecture/ADR-006-Metalogic-No-Physical-Regroup.md)
records the decision.

## The archive

Archived code lives in exactly one tree, `Boneyard/`, and every traversal excludes
it by directory **name** rather than by path prefix. Check B0 asserts the count of such
directories is 1. [ADR-005](architecture/ADR-005-Single-Boneyard.md) records why the name-glob
rule is the load-bearing one.

## Verifying this page

The three structural claims are machine-checked, including the one count on this page (the seven
upward lines), which is asserted by equality rather than stated:

```bash
bash scripts/check-metalogic-cycles.sh      # exactly one directory-level cycle, AND the
                                            # upward set is exactly the 7 recorded lines
python3 scripts/measure-refactor-partitions.py upward-edges   # the same set, enumerated
bash scripts/check-module-invariants.sh     # B0, C4 imports, C8 aggregators, and the rest
```

## Related documentation

- [`theorem-index.md`](theorem-index.md) — the per-theorem ledger
- [`architecture/`](architecture/README.md) — the ADRs
- [`../FormalSystem/README.md`](../FormalSystem/README.md) — per-layer module tables
- [`../FormalSystem/Metalogic/README.md`](../FormalSystem/Metalogic/README.md) — the three routes
  and the generated directory inventory

## Tags

`architecture` · `layering` · `import-graph` · `FrameClass` · `Decidability` · `Boneyard`
