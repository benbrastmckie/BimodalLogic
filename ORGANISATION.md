# Organisation

Where things live in this repository, in one page. This is a **signpost**: each section says
what a directory holds and hands you off to the document that treats it properly. The layer
graph itself, with its exceptions drawn rather than described, is in
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## The library

`FormalSystem/` is a six-layer stack. Each layer imports downward:

| Layer | Directory | Holds |
|---|---|---|
| 5 | `Examples/` | Worked derivations and pedagogical material |
| 4 | `Automation/` | Tactics, proof search, the ML dataset pipeline |
| 3 | `Theorems/` | Derived object-logic theorems |
| 2 | `Metalogic/` | Soundness, completeness, compactness, decidability |
| 1 | `Semantics/` | `TaskFrame`, `ConvexHistory`, `TaskModel`, `TruthAt`, validity |
| 0 | `Syntax/`, `ProofSystem/`, `PlusLanguage/`, `ForMathlib/` | Formulas, axioms, derivations |

Two edges run *upward* through that stack, and both are deliberate:

* **`Semantics → ProofSystem`.** `Semantics/FrameClassValidity.lean` is the only module under
  `Semantics/` that imports from `ProofSystem/`. It defines `FrameClass.Sat`, the semantic
  reading of the proof-side frame-class tag, so that both sides can be indexed by the same tag
  instead of by a hand-maintained binder list that would drift.
* **`Decidability → Automation`.** The tableau decision procedure feeds the dataset pipeline.

Neither closes a cycle. [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) draws both, explains the
relocations that were considered and rejected, and gives the commands that re-derive the graph
from the tree rather than trusting the picture.

`Boneyard/` is outside the stack: it is the archive, it is not compiled, and no
live module imports it. Read [its README](Boneyard/README.md) before resurrecting
anything from it — the argument order of two constructors changed after most of it was written.

## Everything else

| Path | Holds |
|---|---|
| `Tests/BimodalTest/` | The test suite, mirroring the library's directory shape |
| `docs/` | Prose documentation: architecture, reference, user guides, development standards |
| `scripts/` | Repository invariant checks, inventory generation, release tooling |
| `specs/` | Task-management artefacts; not part of the deliverable |
| `typst/` | The paper sources |

## Where to look next

| Question | Document |
|---|---|
| How do the layers fit together, and what are the exceptions? | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Which namespace does a new declaration go in? | [docs/development/MODULE_ORGANIZATION.md](docs/development/MODULE_ORGANIZATION.md) |
| What does this symbol mean? | [NOTATION.md](NOTATION.md) |
| Which theorem lives where? | [docs/theorem-index.md](docs/theorem-index.md) |
| What are the headline results, and what do they depend on? | `FormalSystem/MainResults.lean` |
| How do I build, test and check the repository? | [README.md](README.md) |

## Verifying this page

The layering claims above are structural, so they are checkable rather than asserted:

```bash
# the single Semantics -> ProofSystem edge
grep -rn '^import FormalSystem.ProofSystem' --include='*.lean' FormalSystem/Semantics/

# no live module imports the archive, and nothing under it is built
grep -rn '^import Boneyard' --include='*.lean' FormalSystem/ Tests/
find .lake/build -path '*Boneyard*' -name '*.olean'

# the full structural check suite
bash scripts/check-module-invariants.sh --no-build
```

## Tags

organisation · layering · navigation · directory-structure
