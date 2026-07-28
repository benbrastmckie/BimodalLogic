# Phase 19 — Reynolds §6 Lemma 5: formula and elementary transfer across classes

## Outcome

`[COMPLETED]`. Both statements of Reynolds' Lemma 5 are sorry-free and axiom-clean. Full
`lake build` green at **1930 jobs**.

## What landed

One new module, `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma5.lean` (820 lines),
plus one import line in `FormalSystem/Metalogic/WeakCanonical.lean` (the Phase 17/18 precedent for
registering the leaf `DenseModelSurgery/` chain against the CI edge).

| Reynolds' proof step (printed p.179) | In-tree name |
|---|---|
| *"find `B` which is true at points only if `A` occurs somewhere in their `∼`-class"* | `holdsSomewhereInClassTemporal` (+ `_spec`) |
| *"`B` holds in the whole of a class if it is true anywhere at all in the class"* | `holdsSomewhereInClass_congr` |
| *"by Prior-U … a first point `s > t` where `¬B ∧ K⁻(B)` holds"* | inside `false_of_classInvariant_changes` (`hnBs`, `hkm`) |
| *"so `s` must be the left hand end point of its `∼`-class"* | inside the same (`hmin`) |
| *"for a while after this class `B` stays false"* | `exists_bound_notHolds` |
| *"let `C` be the temporal formula saying …"* | `classLeftEndKMinusTemporal` (+ `_spec`) |
| *"`C` is true in `s`'s class but false afterwards contradicting Prior-U"* | `false_of_holds_throughout_class_bounded` |
| the first statement | `reynolds_lemma5_first` |
| *"we relativise it by restricting quantifiers to where `ε(x,−)` holds"* | `relativizeAt` / `relativizeToClass` (+ `eval_relativizeAt`) |
| *"true exactly throughout `∼`-classes which model `φ`"* | `classModelsTemporal_spec` |
| the second statement | `reynolds_lemma5_second` |
| both statements assembled | `reynolds_lemma5` |

Reusable assets landed on the way, each with a **checked** transcription theorem rather than an
asserted one (the Phase 18 pattern):

- `temporalAt` / `temporalToMonadic` + `eval_temporalAt` — the temporal-to-monadic direction of
  expressive completeness, which the tree did not previously have.
- `classBeginsWithFormula` / `ClassBeginsWith` + `_eval`, `kMinusFormula` / `KMinusAt` + `_eval` —
  the two auxiliary-formula families §6 keeps reusing.
- `atVar` / `eval_atVar` — `rhoAt` generalized to an arbitrary payload.
- `evalOn` — satisfaction relativized to a subset, i.e. the induced substructure's satisfaction
  relation, named without building the substructure.
- `false_of_holds_throughout_class_bounded` — Phase 18's gap-crossing with a bounded failure
  region.

## Verification

| Check | Result |
|---|---|
| Full `lake build` | green, **1930 jobs** |
| Scoped `lake build …DenseModelSurgery.Lemma5` | green, 1243 jobs |
| New sorries | **0** |
| Live-tree sorry count | 1, pre-existing and unrelated: `Transfer.lean:1242` |
| New vacuous definitions | 0 |
| New axiom declarations | 0 |
| `#print axioms`, all 35 new top-level declarations | `[propext, Classical.choice, Quot.sound]` or a strict subset; `sorryAx` absent everywhere |
| Module-specific lint | clean (only the tree-wide `push_neg` deprecation, as `Lemma34.lean` also emits) |

## Deviations

Full record in the plan file under "Deviation record (Phase 19)". In brief:

1. **Page reference**: the plan says p.178; Lemma 5 is printed entirely on **p.179**. Same drift
   Phase 18 recorded for Lemmas 3-4.
2. **`φ'` vs `φ(x)`**: the corpus (and the plan following it) writes `φ'`; the page prints `φ(x)`.
   Cosmetic. Lemma 5 has **no displayed formula**, so the two earlier §6 corpus defects have no
   analogue here — the inline text checks out against the page image.
3. **`temporalToMonadic` was required and did not exist** — Reynolds builds `B` from `A`'s monadic
   form, and only the hard direction of §5 Theorem 3 was landed.
4. **Phase 18's `false_of_holds_throughout_class` could not be reused as it stands.** Its `hout` is
   strictly stronger than what Lemma 5's `C` satisfies, and `C` provably cannot satisfy it
   (`C₀ ⊨ ¬B`, `C₁ ⊨ B`, `C₂ ⊨ ¬B` makes `C` true again at `C₂`). The bounded variant is a genuine
   strengthening. Phase 18's theorem is left unweakened and unrenamed; zero removals.
5. **Renderings that are this tree's, not Reynolds' words**: *"in the same maximal interval of `R`"*
   as `R` throughout the closed segment; *"elementarily equivalent taken as substructures of `M`"*
   as relativized satisfaction (a `∼`-class ends in a gap, so `M.subinterval` cannot name it).

## Honest caveat, carried forward

Every §6 lemma below Lemma 2 remains **conditional**. `IsContempEquivDense ε` plus Prior-U/Prior-S
are hypotheses, and the only `ε` the tree can currently exhibit satisfying them is `epsTop`, for
which `EndsInGapOnRight` is empty. Lemma 5 has no live non-trivial instance; the first is due at
the Lemma 9 / dense-surgery stage. Nothing in §6 below Lemma 2 should be described as discharged.

## Correction to an inbound carry-forward

The dispatch brief stated the repository's sole live `sorry` sits at `Transfer.lean:1225`. It is at
`Transfer.lean:1242` — the plan's original figure was correct and the "correction" was not.
Re-measured with `lean-sorry-census.sh` and a raw grep, not assumed.
