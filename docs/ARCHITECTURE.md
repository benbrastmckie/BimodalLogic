# Architecture

The layer graph of `FormalSystem/`, and the one set of edges that runs *upward* through it.

A reader who assumes the layering is a clean downward cascade will be wrong in one place, and
that exception is recorded rather than excused. It is drawn in the diagram below rather than
mentioned in passing, because a diagram that hides it misdescribes the build.

The table here and the two tables in `scripts/measure-refactor-partitions.py` — `LAYERS` for the
directories, `LANGUAGE_FILE_LAYERS` for the files of the four language directories — state the
same order and must be changed together. [`ORGANISATION.md`](../ORGANISATION.md) carries the
same table in signpost form.

## The layer diagram

```
                         ┌──────────────────────────────────┐
  Layer 4  Examples      │  Examples/    MainResults.lean   │
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
                         │  Tactic/      Version.lean       │             │
                         └──────────────────────────────────┘             │
                                                                          │
  Layered PER FILE       ┌──────────────────────────────────┐             │
  across the stack       │  MinusLanguage/  PlusLanguage/   │             │
                         │  StarLanguage/                   │             │
    layer 3   1 file     │    MinusLanguage/Soundness       │             │
    layer 1  16 files    │    <Lang>Truth, <Lang>Validity … │             │
    layer 0  13 files    │    Formula, Axioms, Derivation … │   UPWARD    │
                         │    MinusLanguage/AxiomDischarge ─┼── 7 lines ──┘
                         └──────────────────────────────────┘
```

### The upward set: seven lines, all from one file

The library has **seven** measured upward import lines, and they are one class. All run from
`MinusLanguage/AxiomDischarge.lean` to `Theorems/*`: the L⁻ axiom-discharge proofs apply derived
object-logic theorems (`Combinators`, `DedekindDerived`, `DeductionTheorem`,
`DiscreteUnfolding`, `GeneralizedNecessitation`, `Propositional.Core`, `TemporalDerived`), and
the file is a syntax-side file at layer 0 while `Theorems/` is at layer 2. They are recorded,
not excused; turning them downward means relocating the file, which is separate work.

These are the same seven lines the file carried as `Syntax/MinusLanguage/AxiomDischarge.lean`.
The `{Plus,Minus,Star}Language` directory merges moved it to the library root, into a directory
the layer table did not then cover, and for a while the measured set read zero. **That move did
not turn the edges downward; it stopped them being measured.** The three language directories
are now layered, and the seven lines are back under their new path.

### The language directories are layered per file

`MinusLanguage/`, `PlusLanguage/` and `StarLanguage/` each hold a language's syntax, proof
system and semantics, so one layer number for the directory is wrong whichever number is
chosen — measured, that leaves 23 upward lines at layer 0, 9 at layer 1, 5 at layer 2 and 3 at
layer 3. Each **file** therefore carries the layer of the directory it occupied before the merge:
13 files from `Syntax/<Lang>/` at layer 0, 16 from `Semantics/<Lang>/` at layer 1, and
`MinusLanguage/Soundness.lean`, from `Metalogic/Conservativity/`, at layer 3. `OpenLanguage/` —
L⁺ plus the open-future and open-past modals, semantic only — was created after the merge and is
layered by the same table: a file with no origin directory takes the layer of the directory it
would have occupied, so its syntax file is at layer 0 and its five semantic modules at layer 1,
for 14 and 21 in all. The full table and
the reason origin rather than content is the rule are in
[`ORGANISATION.md`](../ORGANISATION.md#the-extension-language-directories-are-layered-per-file).
Under it `Metalogic → MinusLanguage` is downward and the three
`Semantics/ → {PlusLanguage, StarLanguage}` bridge lines are intra-layer.

All of it is **asserted, not trusted**. `bash scripts/check-metalogic-cycles.sh` fails if the
measured upward set is anything other than the recorded allowlist, on a surplus and on a
shortfall alike; if any module under `FormalSystem/` matches no layer row, or a per-file row
names a file that is gone; and if a layer-0 file of a language directory imports a semantics
file — the syntax-before-semantics order that the directory boundary used to enforce.

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

Layer 0 is six entries, and four of them are easy to miss:

| Module | Role | Constraint |
|--------|------|------------|
| `Syntax/` | `Formula` (six constructors), atoms, contexts, subformula closure. The L⁻/L⁺/L⋆ language family sits beside it at the library root (`PlusLanguage/` and its siblings); its syntax and proof-system files are layer 0 too, by the per-file table | — |
| `ProofSystem/` | 29 axiom constructors (the paper's primitive schemata; mirrors derived in `DerivedAxioms`), 7 inference rules, `DerivationTree`, `FrameClass` | imports only `Syntax` |
| `ForMathlib/` | Mathlib-shaped proper/maximal/prime **filter** API | imports **nothing** from `FormalSystem.*` — it is intended for upstreaming |
| `Init.lean` | The library-wide preamble, modelled on `Mathlib.Init`: the linters and common tactics every module inherits, plus `Tactic.Attr` | check C24 asserts every module reaches it transitively |
| `Tactic/` | `Attr.lean`, every attribute and named simp set the library uses; `Meta.lean`, the shared `MetaM` plumbing for derivability goals | `Attr.lean` imports `Lean` **only** and carries attribute declarations and nothing else — `Init.lean` imports it, so anything heavier would be upstream of the whole library |
| `Version.lean` | `FormalSystem.version`, the release version string, and nothing else | imports only `Init` |

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
                                            # upward set is exactly the 7 recorded lines, AND
                                            # syntax before semantics in the language directories
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
