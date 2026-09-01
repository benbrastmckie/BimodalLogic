# Implementation Summary: Build the ShiftSet Ultraproduct and the Łoś Lemma

- **Task**: 492 - Build shiftset ultraproduct and Łoś lemma
- **Plan**: `specs/492_build_shiftset_ultraproduct_and_los_lemma/plans/01_shiftset-ultraproduct-los.md`
- **Phases executed**: 4 of 4
- **Status**: implemented

## What was built

Four new modules under `FormalSystem/Semantics/Ultraproduct/`, all wired into the
`FormalSystem/Semantics.lean` aggregator:

| Module | Contents |
|---|---|
| `Carrier.lean` | `evZero`, `UD` (the eventually-zero quotient of the Pi group) and its `LE` / `LinearOrder` / `IsOrderedAddMonoid` / `Nontrivial` / `DenselyOrdered` structure; `carrierSetoid`, `UOmega`, `omk`, `shU`; support lemmas `exists_section`, `mk_surjective`, `mk_zero`, `mk_max`, `mk_abs` |
| `IndexFilter.lean` | `Idx`, `tailFilter`, `tailFilter_neBot`, `idxUF`, `eventually_mem` |
| `ShiftSetProduct.lean` | `UT` (the ultraproduct temporal order), `uSep`, `uShiftSet` — all seven `ShiftSet` fields discharged, no hypotheses |
| `Los.lean` | `los` (Łoś for `ShiftTruth`, six formula cases), `los_truthAt` (Łoś for `TruthAt`, by conjugation through `ShiftSet.forward_repr`) |

Phase 4 additionally retired the second carrier construction from the tree:
`Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` shrank from 289 lines to 69 and no
longer defines anything. It is now a consumer of the promoted modules, retained for two compiler
checks: the elaboration of `uShiftSet φ S : ShiftSet (UT φ T)` (the binder-list and
`Type`-not-`Type 1` universe check that the old `shiftSetOnUD` made against a hypothesis-laden
stand-in) and the four `#print axioms` lines below, which keep the axiom profile under a build
target as a regression check.

## Acceptance evidence

### `#print axioms` — literal output

Produced by `lake env lean Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`
(`uShiftSet`, `los`, `los_truthAt`, `eventually_mem`) and by `lake env lean` on a one-line
scratch file importing `FormalSystem.Semantics.Ultraproduct.Los` (`uSep`):

```
'FormalSystem.Semantics.Ultraproduct.los_truthAt' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.Ultraproduct.los' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.Ultraproduct.uShiftSet' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.Ultraproduct.uSep' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.Ultraproduct.eventually_mem' depends on axioms: [propext, Classical.choice, Quot.sound]
```

`sorryAx` is absent from all five. This is the task's named acceptance criterion.
`Classical.choice` enters through `toDecidableLE := Classical.decRel _`, the `choose` calls in
the `Nontrivial` and `DenselyOrdered` instances, and `exists_section` — the same profile
`ShiftSet.reverse_repr` already carries.

### `lake build` — literal result

```
Build completed successfully (2506 jobs).
EXIT=0
```

Run as `lake-build-guard.sh build --timeout 1800 --no-share -- build`. `--no-share` forces a
real build rather than a replayed prior result; the 2506-job count confirms a full-tree build,
not a scoped one. Zero lines matching `error` in 2755 lines of output.

### `sorry` count: zero

`grep -rn 'sorry\|sorryAx\|admit' FormalSystem/Semantics/Ultraproduct/` returns two hits, both
prose inside module docstrings recording that `sorryAx` is *absent* from the axiom profile
(`Los.lean:43`, `ShiftSetProduct.lean:55`). There is no `sorry`, `admit`, or `native_decide`
term anywhere in the new code, and the five axiom profiles above are the compiler's own
confirmation of that.

### Single-carrier check

`grep -rn 'def evZero\|abbrev UD\|def carrierSetoid\|def UOmega' FormalSystem/ Tests/`:

```
FormalSystem/Semantics/Ultraproduct/Carrier.lean:74:def evZero : AddSubgroup (∀ i, D i) where
FormalSystem/Semantics/Ultraproduct/Carrier.lean:88:abbrev UD := (∀ i, D i) ⧸ evZero φ D
FormalSystem/Semantics/Ultraproduct/Carrier.lean:200:def carrierSetoid (Ω : I → Type) : Setoid (∀ i, Ω i) where
FormalSystem/Semantics/Ultraproduct/Carrier.lean:207:def UOmega (Ω : I → Type) : Type := Quotient (carrierSetoid φ Ω)
```

Hits in `Carrier.lean` only. The tree holds exactly one carrier construction — the point of
Phase 4.

### Test suite

`lake test` passes. `Tests/BimodalTest.lean:17`'s
`import BimodalTest.Semantics.DependentUltraproductProbe` is untouched and still resolves.

## Deviations from the plan

- **Probe imports two modules, not one.** Phase 4 specified replacing the probe's imports with
  `import FormalSystem.Semantics.Ultraproduct.Los` alone. That does not transitively reach
  `IndexFilter.lean` — `Los.lean` imports `ShiftSetProduct.lean`, which imports `Carrier.lean`
  and `ShiftSet.lean`, and nothing in that chain depends on the index filter. With only the `Los`
  import, `#print axioms ...eventually_mem` failed with
  `unknownIdentifier`. `import FormalSystem.Semantics.Ultraproduct.IndexFilter` was added
  alongside it, which is the minimal way to keep the `eventually_mem` axiom check that the same
  phase requires.
- **The elaboration check is `noncomputable example`.** A bare `example` failed with
  `dependsOnNoncomputable`, since `uShiftSet` is `noncomputable` (its `LinearOrder` instance goes
  through `Classical.decRel`). The `noncomputable` modifier changes nothing about what is
  measured.
- **`FormalSystem/Semantics/README.md` does enumerate submodules**, so the conditional edit
  applied: an `Ultraproduct/` row was added to the Contents table after the `Extension/` row.

## Out of scope, left alone

`FormalSystem/Semantics/TaskFrame.lean` carries a pre-existing `[Nontrivial D]`
`overlappingInstances` warning at `:846`, `:897`, `:957`. It predates this work, is queued as
separate follow-up, and was not touched; the linter was not disabled.

## Artifacts

- `FormalSystem/Semantics/Ultraproduct/Carrier.lean` (new)
- `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean` (new)
- `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean` (new)
- `FormalSystem/Semantics/Ultraproduct/Los.lean` (new)
- `FormalSystem/Semantics.lean` (modified: four imports + submodule docstring entries)
- `Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` (modified: 289 -> 69 lines)
- `FormalSystem/Semantics/README.md` (modified: `Ultraproduct/` Contents row)
