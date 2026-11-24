# BimodalLib: the library of TM results

`BimodalLib` is a Lake library beside `BimodalTools`. It files what is known about TM and its
extensions by language fragment: the theorems proved under `FormalSystem/Theorems/`, second
proofs of those theorems, and conjectures. This page describes what the library holds and how
to add to it. The design of the parts not yet built (countermodels, the tableau pipeline,
diagnostics, sweeps of the proof mode) is in
[records/theorem-library.md](../../records/theorem-library.md).

## Where it sits

`BimodalLib` imports `FormalSystem`, and `FormalSystem` never imports it. Check `B3` of
`scripts/check-module-invariants.sh` fails on an `import BimodalLib` anywhere under
`FormalSystem/`. The library therefore sits above the tableau and above the proof mode and may
use both.

It is outside `defaultTargets`. A plain `lake build` compiles the published library and nothing
here; the library is built by explicit target and by its own `--wfail` step in CI:

```bash
lake build BimodalLib --wfail       # the library; also the registration check
lake build BimodalLibTest --wfail   # its tests
bash scripts/library-index.sh       # regenerate BimodalLib/INDEX.md
```

The alternative is a default target, under which a contributor's plain build would catch a
second proof that has drifted from its statement. It is rejected because CI catches the same
drift, and because the library is where sweeps and enumerated entries land, of which there will
be many: `lake build` means "the published library".

## Layout

| Path | Holds |
|---|---|
| `BimodalLib/Fragment.lean` | The operator families, the four fragments, and the profile of a formula |
| `BimodalLib/Registry.lean` | The row type `TheoremEntry` and the command `register_theorem` |
| `BimodalLib/Registry/Complete.lean` | The command `assert_registry_complete` |
| `BimodalLib/Theorems/<Fragment>/<FrameClass>.lean` | The registration lines, one per registered theorem |
| `BimodalLib/Theorems/Complete.lean` | Runs the registration check over the published library |
| `BimodalLib/Pairing.lean` | The row type `ReproofEntry` and the command `reprove X as Y := t` |
| `BimodalLib/Conjecture.lean` | The type `Conjecture` |
| `BimodalLib/Conservativity.lean` | Derivability within a cell, in which the conservativity conjectures are stated |
| `BimodalLib/Conjectures/` | The registered conjectures |
| `BimodalLib/Index.lean` | The polarity census and the command `library_index` |
| `BimodalLib/INDEX.md` | The generated index |
| `Tests/BimodalLibTest/` | Tests of each command, in both directions |

## Fragments

There is one Boolean base and two operator families over it: **Modal** (`□`, and `⊡` in the
extended language) and **Temporal** (Until, Since and what is defined from them). A fragment is
a set of families: `Boolean`, `ModalBoolean`, `TemporalBoolean`, `ModalTemporalBoolean`.

The fragment of a formula is computed. `profileF : Formula → Profile` and
`profileP : PlusFormula → Profile` record which primitive operators occur, by recursion on the
primitives; a defined operator is counted through its definition because it unfolds to
primitives. A `Profile` has a field for `□`, one for `⊡` and one for the temporal operators, so
it carries the **modal operator set** of a formula as well as its fragment, and
`Profile.fragment` maps both `□` and `⊡` to the Modal family. Profiles are ordered by inclusion.
`profileP_ofFormula` proves that the two computations agree on the embedding of `Formula` into
`PlusFormula`. Why `⊡` is in the Modal family and not a family of its own is set out in
[stability-operator-family.md](../development/stability-operator-family.md).

`SubstClass` records whether a statement is schematic in all its variables or restricted to
atoms or to state-local formulas in named variables. Only a statement with `⊡` can be
restricted.

## The registry

A theorem is registered by reference. One line names a closed derivation declared under
`FormalSystem/Theorems/`:

```lean
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity1
  (dual := FormalSystem.Theorems.Perpetuity.perpetuity2)
```

The command reads the type of the declaration and adds a definition
`BimodalLib.Registry.<full name>` of type `TheoremEntry`:

| Field | What it is |
|---|---|
| `arity` | The number of schema variables |
| `frameClass` | The frame class the derivation is stated at |
| `stmt` | The statement, as a function of an assignment to its variables |
| `proof` | The registered derivation, at every class above `frameClass` and every assignment |
| `profile`, `profile_eq` | The operators of the statement, and a proof by `rfl` that they are the computed ones |
| `substClass` | The substitution class; `schematic` for every row, since `proof` holds at every assignment |
| `dual` | The declaration registered as the law in the other polarity, if one is declared |

A row is a term the kernel has checked. Its `proof` field cites the declaration at the row's
statement, so the statement is read from the declaration and is never retyped, and the fragment
and operator set are computed and not asserted. The registry is the set of constants of type
`TheoremEntry`. Nothing is stored in an attribute or an environment extension, because rows
held there pass no kernel check; and the derivations stay in `FormalSystem/Theorems/`, where
the metalogic imports them.

**Frame class.** A derivation stated at every class is filed at `Base`; one with a hypothesis
`C ≤ fc` at `C`; one stated at a fixed class at that class. Above `Base`, the class of a row is
the class its derivation is **stated at**: the row proves derivability there and at every
stronger class, and does not prove failure at a weaker one.

**What is registered.** A closed derivation concludes a derivation from the empty context and
has no derivation among its premises. A derivation from a non-empty context and a rule with a
derivation among its premises are not registered; the check reports how many of each it saw.

**The check.** `BimodalLib/Theorems/Complete.lean` imports the root `FormalSystem` and every
registration module and runs `assert_registry_complete`. It fails, naming the declarations,
when a closed derivation declared in a module under `FormalSystem.Theorems`, outside
`FormalSystem.Theorems.ProofMode`, has no row, or when a declared dual has none. A closed
derivation added under `FormalSystem/Theorems/` therefore breaks `lake build BimodalLib` until
it is registered. The check keys on the module that declares a constant, and it sees only
imported modules, which is why the module that runs it imports the library root.

**Adding a theorem.** Add its `register_theorem` line to the file for its fragment and frame
class, importing the module that declares it, and regenerate the index. A line filed in the
wrong file still builds; the index files every row by what the row computes.

## Pairing a second proof

```lean
reprove FormalSystem.Theorems.Perpetuity.perpetuity1 as perpetuity1Again :=
  fun φ => combineImpConj3 (boxToPast φ) (boxToPresent φ) (boxToFuture φ)
```

`reprove X as Y := t` elaborates `t` against the type of the registered declaration `X` and
declares `Y`, in the current namespace, with that type. A proof of any other statement is a type
error and declares nothing. The command then adds a row of type `ReproofEntry`, named by the
full name of `Y` under the library's `Reproofs` namespace, whose `proof` field cites `Y` at the statement of the row of `X`. The
pairing is a kernel-checked term and not a naming convention. The command fails if `X` has no
registry row. Lean's own `reprove ... by` command is a different command; the two are told
apart by the keyword `as`.

## Conjectures

A conjecture is a constant of type `Conjecture`: a `statement : Prop`, a `fragment`, an operator
set `ops`, an optional `frameClass`, a `status` and a `note` on where it is stated, what was
tried and what it would settle. The type has no field for a proof, so a conjecture cannot stand
where a theorem is required and registering one leaves nothing unproved in the library. The
statement is a `Prop` and not a formula because some conjectures are about derivability. Its
fragment and operator set are declared by its author, where those of a theorem row are computed.

To register one, declare a `Conjecture` in a module under `BimodalLib/Conjectures/` and
regenerate the index.

The conservativity edges are stated over derivability within a cell. `within c d` holds when
every formula derived in the derivation `d` has a profile included in `c`; `DerivableIn c fc φ`
says `φ` has such a closed derivation; `ConservativeEdge c fc` says that a formula of the cell
derivable at `fc` is derivable within the cell. `withinP` and `DerivableInP` are the same for
the extended system. The axiom instances and rule applications that stay inside a cell are that
cell's logic, so no proof system per fragment is defined.

The registered conjectures are the conservativity edges that are not yet proved and the
derivability in the extended system of the collapse `φ ↔ ⊡φ` for state-local `φ`, which is
proved as a validity (`plusStateLocal_stab_iff`). `BimodalLib/INDEX.md` lists each with its
statement and note.

## The index

`bash scripts/library-index.sh` builds the library, runs the command `library_index`, and
writes `BimodalLib/INDEX.md`: the theorems by fragment and frame class, the second proofs by
statement, the conjectures, and for each pair of dual operators the laws with no declared dual.
`--check` fails when the committed index differs from a fresh one; CI runs it.

The dual pairs are `□`/`◇`, `G`/`F`, `H`/`P` and always/sometimes, with `⊡`/`⟐` listed as
having no rows. The operators of a statement are recognized by pattern over the primitives,
most specific pattern first, so the `G` and `H` inside an `always` are not counted again.
Whether one law is the dual of another is declared with `(dual := Y)`, not computed: a row is
listed when its statement has the universal operator of a pair and its `dual` is empty. The
listing is long because few duals are declared.

## What checks the library

| Check | Catches |
|---|---|
| `lake build BimodalLib --wfail` (CI) | An unregistered closed derivation; a declared dual with no row; any warning |
| `lake build BimodalLibTest --wfail` (CI) | A command that stops failing where it should: the check on a fixture, a drifted second proof, a declaration that is not a closed derivation |
| `scripts/library-index.sh --check` (CI) | A stale `BimodalLib/INDEX.md` |
| `B3` of `scripts/check-module-invariants.sh` | `FormalSystem` importing `BimodalLib` |
| `lake exe runLinter BimodalLib` | A declaration, generated rows included, with no docstring |
