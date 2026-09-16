# Architecture

The layer graph of `FormalSystem/`, and the two edges that run *upward* through it.

A reader who assumes the layering is a clean downward cascade will be wrong twice, and both
exceptions are deliberate. They are drawn in the diagram below rather than mentioned in passing,
because a diagram that hides them misdescribes the build.

## The layer diagram

```
                         ┌──────────────────────────────────┐
  Layer 5  Examples      │  Examples/                       │
                         └───────────────┬──────────────────┘
                                         │ imports
                         ┌───────────────▼──────────────────┐
  Layer 4  Automation    │  Automation/                     │◄────────────┐
                         │  tactics, Aesop rules, ML data   │             │
                         └───────────────┬──────────────────┘             │
                                         │ imports                        │
                         ┌───────────────▼──────────────────┐             │
  Layer 3  Theorems      │  Theorems/                       │             │
                         │  derived object-logic theorems   │             │
                         └───────────────┬──────────────────┘             │
                                         │ imports                        │
                         ┌───────────────▼──────────────────┐             │
  Layer 2  Metalogic     │  Metalogic/                      │             │
                         │  soundness, completeness,        │             │
                         │  compactness, decidability       │             │
                         │                                  │             │
                         │  Decidability/ ─────────────────────UPWARD ────┘
                         │      the tableau procedure feeds  │   EDGE (2)
                         │      the dataset pipeline         │
                         └───────────────┬──────────────────┘
                                         │ imports
                         ┌───────────────▼──────────────────┐
  Layer 1  Semantics     │  Semantics/                      │
                         │  TaskFrame, ConvexHistory,        │
                         │  TaskModel, TruthAt, validity    │
                         │                                  │
                         │  FrameClassValidity.lean ────────────UPWARD ────┐
                         └───────────────┬──────────────────┘   EDGE (1)   │
                                         │ imports                         │
                         ┌───────────────▼──────────────────┐              │
  Layer 0  Foundation    │  Syntax/      ProofSystem/ ◄─────────────────────┘
                         │  ForMathlib/  PlusLanguage/      │
                         └──────────────────────────────────┘
```

### Upward edge (1): `Semantics → ProofSystem`, via `Semantics/FrameClassValidity.lean`

`FrameClassValidity.lean` is the **only** module under `FormalSystem/Semantics/` that imports
anything from `FormalSystem/ProofSystem/`. It defines `FrameClass.Sat`, the semantic reading of
the proof-side `FrameClass` tag, so that the semantic side can be indexed by the same tag the
proof side already carries rather than by a hand-maintained binder list — which is what keeps a
frame class and its binder list from drifting apart.

The edge closes no cycle: `ProofSystem/Axioms.lean` imports only `Syntax/Formula.lean`, and
nothing under `ProofSystem/` imports `Semantics`. The decision, and the two relocations that were
considered and rejected on cost, are in
[ADR-008](architecture/ADR-008-FrameClass-Validity-Seam.md).

### Upward edge (2): `Decidability → Automation`

The ML dataset pipeline in `Automation/` consumes the tableau decision procedure from
`Metalogic/Decidability/`: `DataExport.lean`, `TraceExporter.lean` and
`TableauProofStepsMain.lean` all import `Decidability` modules directly. A Layer-4 module
therefore depends on a Layer-2 one — which is downward and unremarkable — but the *pipeline* runs
in the other direction: the decision procedure is the producer and the pipeline the consumer, so
a reader tracing data flow sees Decidability feeding Automation.

The distinction matters when reading either graph: the **import** graph is acyclic and downward;
the **data-flow** graph runs Decidability → Automation. Neither is the other.

## Layer 0 in full

Layer 0 is four modules, not two. Both `ForMathlib` and `PlusLanguage` are easy to miss:

| Module | Role | Constraint |
|--------|------|------------|
| `Syntax/` | `Formula` (six constructors), atoms, contexts, subformula closure | — |
| `ProofSystem/` | 45 axiom constructors, 7 inference rules, `DerivationTree`, `FrameClass` | imports only `Syntax` |
| `ForMathlib/` | Mathlib-shaped proper/maximal/prime **filter** API | imports **nothing** from `FormalSystem.*` — it is intended for upstreaming |
| `PlusLanguage/` | `PlusFormula` (**L⁺** = L plus the stability modal `⊡`), `PlusAxiom`, `PlusDerivationTree`, `ofFormula` | a second object language beside `Formula` |

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

Archived code lives in exactly one tree, `FormalSystem/Boneyard/`, and every traversal excludes
it by directory **name** rather than by path prefix. Check B0 asserts the count of such
directories is 1. [ADR-005](architecture/ADR-005-Single-Boneyard.md) records why the name-glob
rule is the load-bearing one.

## Verifying this page

Nothing here is a count, so nothing here can go stale numerically. The two structural claims are
machine-checked:

```bash
bash scripts/check-metalogic-cycles.sh      # exactly one directory-level cycle
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
