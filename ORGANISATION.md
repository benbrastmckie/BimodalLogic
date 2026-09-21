# Organisation

Where things live in this repository, in one page. This is a **signpost**: each section says
what a directory holds and hands you off to the document that treats it properly. The layer
graph itself, with its exceptions drawn rather than described, is in
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## The library

`FormalSystem/` is a five-layer stack. Each layer imports downward:

| Layer | Directory | Holds |
|---|---|---|
| 4 | `Examples/` | Worked derivations and pedagogical material |
| 3 | `Metalogic/`, `Automation/` | Soundness, completeness, compactness, decidability; tactics and proof search |
| 2 | `Theorems/` | Derived object-logic theorems |
| 1 | `Semantics/` | `TaskFrame`, `ConvexHistory`, `TaskModel`, `TruthAt`, validity |
| 0 | `Syntax/`, `ProofSystem/`, `ForMathlib/`, `Init.lean`, `Tactic/` | Formulas, axioms, derivations; the shared preamble and the library's attribute declarations |

This is the **measured** order, not an aspiration. Two entries in it are easy to misread:

* **`Metalogic/` and `Automation/` share layer 3.** They are beside each other, not stacked. 50
  `Metalogic/` import lines reach into `Theorems/`, so Metalogic sits above it; and the surviving
  `Decidability/ → {ProofSearch, Normalization}` lines are the decision procedure calling library
  automation, which is a legitimate **intra-layer** edge. Placing `Automation/` above `Metalogic/`
  would make those three lines upward exceptions; placing it below would make them downward and
  say something false about which depends on which. Beside is what the tree does.
* **`Tactic/` is at layer 0, below everything.** `Tactic/Attr.lean` declares every attribute and
  named simp set the library uses, and `FormalSystem/Init.lean` imports it, so all of them reach
  every module transitively. That is why no module imports it directly. It carries an
  attributes-only constraint for exactly this reason — see
  [`FormalSystem/Tactic/README.md`](FormalSystem/Tactic/README.md). `Tactic/Meta.lean` beside it
  is ordinary metaprogramming placed at layer 0 because its consumers are spread across
  `Automation/` and `Metalogic/`.

Two classes of edge run *upward* through that stack, and both are recorded:

* **`Semantics → ProofSystem`.** Both are at layer 0, so this is not upward at all under the
  table above; it is called out because it is the only module under `Semantics/` that imports from
  `ProofSystem/`. `Semantics/FrameClassValidity.lean` defines `FrameClass.Sat`, the semantic
  reading of the proof-side frame-class tag, so that both sides can be indexed by the same tag
  instead of by a hand-maintained binder list that would drift.
* **`Syntax/MinusLanguage/AxiomDischarge.lean → Theorems/*`, 7 lines.** The only genuinely upward
  set left in the library. The L⁻ axiom-discharge proofs need the derived object-logic theorems.
  The work that removes them is the `{Plus,Minus,Star}Language` directory merges in
  [docs/development/PUBLICATION_REFACTOR.md](docs/development/PUBLICATION_REFACTOR.md), which move
  that file out of `Syntax/` entirely.

Neither closes a cycle, and the second set is asserted mechanically rather than trusted:
`bash scripts/check-metalogic-cycles.sh` fails if the upward set is anything other than exactly
those 7 lines — on a surplus and on a shortfall alike.
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) draws the graph, explains the relocations that were
considered and rejected, and gives the commands that re-derive it from the tree rather than
trusting the picture.

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
# the layer table above, re-derived from the tree: every upward import line, grouped
python3 scripts/measure-refactor-partitions.py upward-edges

# the same claim as a gate: exactly one Metalogic cycle, and the upward set is exactly
# the recorded 7 AxiomDischarge lines (fails on a surplus AND on a shortfall)
bash scripts/check-metalogic-cycles.sh

# the single Semantics -> ProofSystem edge
grep -rn '^import FormalSystem.ProofSystem' --include='*.lean' FormalSystem/Semantics/

# no live module imports the archive, and nothing under it is built
grep -rn '^import Boneyard' --include='*.lean' FormalSystem/ Tests/
find .lake/build -path '*Boneyard*' -name '*.olean'

# the full structural check suite
bash scripts/check-module-invariants.sh --no-build
```

The table above and the `LAYERS` dictionary in `scripts/measure-refactor-partitions.py` say the
same thing and must be changed together; `check-metalogic-cycles.sh` loads that dictionary rather
than keeping a second copy.

## Tags

organisation · layering · navigation · directory-structure
