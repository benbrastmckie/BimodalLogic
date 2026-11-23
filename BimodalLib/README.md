# BimodalLib

The library of results about TM and its extensions, filed by language fragment. It registers
the theorems proved under `FormalSystem/Theorems/` by reference, pairs second proofs with their
registered statements, holds conjectures apart from results, and generates an index.

`BimodalLib` is a `lean_lib` **outside `defaultTargets`**. A plain `lake build` compiles
`FormalSystem` and nothing here. The library is built by `lake build BimodalLib` and its tests
by `lake build BimodalLibTest`.

## Direction of dependence

`BimodalLib` imports `FormalSystem`. `FormalSystem` never imports `BimodalLib`.

## Submodules

- **Fragment.lean**: the operator families, the four fragments, and the profile of a formula
  (which primitive operators occur), for `Formula` and for `PlusFormula`.

## Building

```bash
lake build BimodalLib --wfail
```

## Related documentation

- [records/theorem-library.md](../records/theorem-library.md): the design of the library
- [docs/development/stability-operator-family.md](../docs/development/stability-operator-family.md):
  why `⊡` is filed in the Modal family

*Last verified: 2026-11-23*
