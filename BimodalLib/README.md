# BimodalLib

The library of results about TM and its extensions, filed by language fragment. It registers
the theorems proved under `FormalSystem/Theorems/` by reference, pairs second proofs with their
registered statements, holds conjectures apart from results, and generates an index.

`BimodalLib` is a `lean_lib` **outside `defaultTargets`**. A plain `lake build` compiles
`FormalSystem` and nothing here. The library is built by `lake build BimodalLib` and its tests
by `lake build BimodalLibTest`. The reference page is
[docs/reference/bimodal-lib.md](../docs/reference/bimodal-lib.md).

## Direction of dependence

`BimodalLib` imports `FormalSystem`. `FormalSystem` never imports `BimodalLib`, and check `B3`
in `scripts/check-module-invariants.sh` asserts it.

## Modules

| Path | Description |
|------|-------------|
| `Fragment.lean` | The operator families, the four fragments, and the profile of a formula (which primitive operators occur), for `Formula` and for `PlusFormula` |
| `Registry.lean` | `TheoremEntry`, the kernel-checked row of a registered theorem, and `register_theorem` |
| `Registry/` | `assert_registry_complete`, the registration check |
| `Theorems/` | The registration lines, by `<Fragment>/<FrameClass>.lean`, and the module that runs the check |
| `Pairing.lean` | `ReproofEntry` and `reprove X as Y := t` |
| `Conjecture.lean` | `Conjecture`, a statement with a status and a note and no proof |
| `Conservativity.lean` | Derivability within a cell: `within`, `DerivableIn`, `ConservativeEdge` |
| `Conjectures/` | The registered conjectures |
| `Index.lean` | The polarity census and `library_index` |
| [INDEX.md](INDEX.md) | The generated index; do not edit |

## How to

**Register a theorem.** Add one line to the file for its fragment and frame class under
`Theorems/`, importing the module that declares it:

```lean
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity1
```

Add `(dual := Y)` to name the law in the other polarity. A closed derivation added under
`FormalSystem/Theorems/` with no such line fails the build of `Theorems/Complete.lean`, which
names it.

**Pair a second proof.** `reprove X as Y := t` declares `Y` with the type of the registered
declaration `X`. A proof of another statement is a type error.

**Register a conjecture.** Declare a constant of type `Conjecture` in a module under
`Conjectures/`.

**Regenerate the index.** After any of the above:

```bash
bash scripts/library-index.sh
```

## Two things the index does not claim

- **A frame class above `Base` is the class a row is stated at.** The row proves derivability
  at that class and every stronger one. It does not prove that the statement fails at a weaker
  class.
- **The listing of laws with no dual rests on declared links.** The operators of a statement
  are computed; that one law is the dual of another is declared with `(dual := Y)`.

## Building

```bash
lake build BimodalLib --wfail
lake build BimodalLibTest --wfail
bash scripts/library-index.sh --check
```

## Related documentation

- [docs/reference/bimodal-lib.md](../docs/reference/bimodal-lib.md): what the library holds
  and how each command works
- [records/theorem-library.md](../records/theorem-library.md): the design of the parts not yet
  built
- [docs/development/stability-operator-family.md](../docs/development/stability-operator-family.md):
  why `⊡` is filed in the Modal family

*Last verified: 2026-11-23*
