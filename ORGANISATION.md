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

One class of edge is called out against that stack:

* **`Semantics → ProofSystem`.** Both are at layer 0, so this is not upward at all under the
  table above; it is called out because it is the only module under `Semantics/` that imports from
  `ProofSystem/`. `Semantics/FrameClassValidity.lean` defines `FrameClass.Sat`, the semantic
  reading of the proof-side frame-class tag, so that both sides can be indexed by the same tag
  instead of by a hand-maintained binder list that would drift.

**The measured upward set is now empty**, and that is asserted rather than trusted:
`bash scripts/check-metalogic-cycles.sh` fails if it is anything other than the recorded
allowlist — on a surplus and on a shortfall alike. It used to hold 7 lines, all from
`Syntax/MinusLanguage/AxiomDischarge.lean` into `Theorems/*`, the L⁻ axiom-discharge proofs
reaching for the derived object-logic theorems.
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) draws the graph, explains the relocations that were
considered and rejected, and gives the commands that re-derive it from the tree rather than
trusting the picture.

### The extension-language directories sit outside this table

`MinusLanguage/`, `PlusLanguage/` and `StarLanguage/` are **not** layers and are **not** in the
table above. Each is a self-contained object language at the library root, carrying its syntax,
its proof system and its semantics in one directory, parallel to the core stack rather than
stacked against it. Their absence is deliberate, not an oversight.

**It has a measurement consequence worth stating plainly.** `layer_of` in
`scripts/measure-refactor-partitions.py` returns `None` for any path outside `LAYERS`, so every
import *into* and *out of* these three directories is invisible to the upward-edge measurement.
`Metalogic → MinusLanguage` and
`Semantics/StateLocalTransfer.lean → PlusLanguage.PlusStateLocal` are both real edges that the
measurement does not see. This is also why the 7-line allowlist above emptied: the merge moved
`AxiomDischarge.lean` from `Syntax/` to `MinusLanguage/`, which did not turn its edges downward
— it stopped measuring them. Read the empty allowlist as *"nothing measured is upward"*, never as
*"nothing is upward"*. **No harness check catches a regression here; this paragraph is the only
record.**

`Boneyard/` is outside the stack for a different reason: it is the archive, it is not compiled,
and no live module imports it. Read [its README](Boneyard/README.md) before resurrecting
anything from it — the argument order of two constructors changed after most of it was written.

### Module size

Split a module along a **dependency seam**, never to satisfy a line count. This is cslib's rule,
adopted as written. A file is worth dividing when part of it can be imported without the rest —
when a consumer needs the definitions but not the thousand lines of lemmas behind one theorem, or
when two halves share nothing but a namespace. A file that is long because one argument is long
is not improved by being cut where the scroll bar happens to be: the cut adds an import, a
docstring and a name to learn, and the reader still has to hold both halves in mind.

The mechanical half is `linter.style.longFile`, set to 1,500 in `lakefile.toml`. A longer file
carries an in-source baseline, `set_option linter.style.longFile N`, directly after its module
docstring; the linter keeps N tight, so the file's length is recorded rather than suppressed.
[LEAN_STYLE_GUIDE.md](docs/development/LEAN_STYLE_GUIDE.md) has the details under "The long-file
baseline". A baseline is not a to-do item: splitting a file only to retire its baseline is
exactly what this rule rules out.

Two files are large enough to say so by name, both over 4,500 lines:
`FormalSystem/Metalogic/Expressiveness/EFGames/GapDetection.lean` (5,094) and
`FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPoint.lean` (4,906). Each is a
candidate for a split if a dependency seam is found in it, and for nothing otherwise. Re-derive
the list with:

```bash
find FormalSystem -name '*.lean' -exec wc -l {} + | sort -rn | head
```

### Recorded namespace exceptions

A module's first `namespace` normally equals its directory-derived module name or an ancestor of
it. Eight modules declare an unrelated one. Each is deliberate, each carries a
`## Recorded namespace exception` section in its own module docstring giving the full argument,
and none is scheduled for renaming: a rename moves declarations, breaks fully-qualified
references, and invalidates pinned `#print axioms` baselines, for no gain in any of these cases.
This table is the index; the docstrings are the record.

| Module (under `FormalSystem/`) | Declares | Why, in one line |
|---|---|---|
| `ForMathlib/Order/PFilter` | `Order.PFilter` | Mathlib's own namespace, so that upstreaming deletes the file and renames nothing |
| `Metalogic/BXCanonical/Chronicle/ChronicleRealExtension` | `…Metalogic.Bundle` | Interleaves Bundle and Chronicle blocks; the Chronicle block uses two lemmas from the Bundle block above it, so it cannot be hoisted first |
| `Metalogic/Decidability/BiLasso/Periodic` | `…Decidability.Periodic` | Names the generic periodic-decoding scheme, which is stated directory-independently on purpose |
| `Metalogic/WeakCanonical/DenseModelSurgery/ChronicleInstance` | `…BXCanonical.Chronicle` | The chronicle bridge's own instances; relocating it would change the one sanctioned `WeakCanonical → BXCanonical` cycle that `check-metalogic-cycles.sh` pins |
| `Metalogic/WeakCanonical/RealModel/ChronicleRealFlow` | `…BXCanonical.Chronicle` | Same cycle, same reason as the row above |
| `Semantics/FrameClassValidity` | `FormalSystem.ProofSystem` | Extends `ProofSystem.FrameClass`; dot notation resolves against the type's namespace, so `fc.Sat` requires it |
| `Tactic/Meta` | `FormalSystem.Automation` | Moved to layer 0 for its importers; every consumer reaches it through `open FormalSystem.Automation` |
| `Theorems/DeductionTheorem` | `FormalSystem.Metalogic.Core` | Moved down a layer to delete four upward imports; 51 fully-qualified references across 13 files keep the old namespace |

```bash
# re-derive the list: the `unrelated` bucket must be exactly these eight
python3 scripts/measure-refactor-partitions.py namespace-audit
```

Do not repair one of these with a bare `scripts/move-modules.py --namespace-map` when the
namespace prefix is shared with files that stay: the map applies to the prefix wherever it
occurs. [MODULE_RELOCATION.md](docs/development/MODULE_RELOCATION.md) describes the refusal that
guards the worst case and the `--namespace-paths` option that scopes the rewrite.

## Everything else

| Path | Holds |
|---|---|
| `Tests/BimodalTest/` | The test suite, mirroring the library's directory shape |
| `BimodalTools/`, `Tests/BimodalToolsTest/` | The tooling library (dataset generation, export, benchmarks, the executable roots) and its tests; outside `defaultTargets`, and never imported by the library |
| `docs/` | Prose documentation: architecture, reference, user guides, development standards |
| `scripts/` | Repository invariant checks, inventory generation, release tooling |
| `specs/` | The project development record: research reports, implementation plans and summaries for each unit of work. Tracked and published permanently; not part of the library, and nothing in the library depends on it |
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
