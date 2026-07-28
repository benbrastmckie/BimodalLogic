# Phase 18 — Reynolds §6 Lemmas 3 and 4: maximal `R`-intervals

**Status**: COMPLETED. Both lemmas fully proved, sorry-free and axiom-clean. No skeleton, no
strategic sorries.

**Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/Lemma34.lean` (new, 957 lines).

## Tree state at dispatch start

The previous session died at wrap-up. A full `lake build` was run before any Phase 18 work and
returned green at 1928 jobs, so Phase 17 was in fact complete — only its wrap-up was missing. Its
untracked `DenseModelSurgery/Defs.lean` (503 lines) plus the modified `WeakCanonical.lean` and
`Kamp/Section5Correspondence.lean` were committed as `04dddfbb1` before Phase 18 began.

## What landed

27 new top-level declarations plus 6 private environment-lookup helpers.

**Lemma 3** — *"The maximal intervals in which `R` holds are open intervals which, if bounded, have
elements of `M` as their (excluded) end points."* Reynolds' single printed sentence is landed as
four named theorems plus an assembled `reynolds_lemma3`, with a table in the module header mapping
each to the proof step it transcribes:

| Reynolds' proof step | In-tree name |
|---|---|
| *"`ρ` holding at `t` implies that `R` will hold for a while after `t`"* | `endsInGapOnRight_forAWhile` |
| *"Prior-U applied to `R` … a first point of `¬R`"* | `reynolds_lemma3_right` |
| *"we must rule out the third case"* | `reynolds_lemma3_no_first_point` |
| *"Prior-S … a last point of `¬R` just before this stretch"* | `reynolds_lemma3_left` |

**Lemma 4** — *"There is no last class and no first class in any maximal interval of `R`."* Both
halves: `reynolds_lemma4_no_last_class` (Reynolds' one-line *"the last class … wouldn't end in a
gap"*, which is the argument already carried out in `exists_gt_notContemp_holds`) and
`reynolds_lemma4_no_first_class` (the displayed formula plus Prior-U).

**Auxiliary formulas, named rather than inlined** — the phase's explicitly-required reusable
artifact. Two full families were landed, each with a *checked* transcription theorem rather than an
asserted one: `classBeginsAtGapStartFormula` (Lemma 3's `B`) and `firstClassFormula` (Lemma 4's
displayed formula), each with a semantic reading, an `_eval` theorem, a temporal equivalent via
expressive completeness, and a `_spec` theorem.

**One factoring beyond the task list**: `false_of_holds_throughout_class` isolates the *"holds up to
a gap and is false arbitrarily soon after the gap, contradicting Prior-U"* step, which Reynolds runs
verbatim at Lemmas 3, 4, 5 and 7. Both Phase 18 uses go through it.

## Literature fidelity — a second corpus defect in §6

Lemma 4's displayed formula is corrupted in **four independent places** in the pre-segmented corpus
chunk, and the plan quotes the corrupted form. The printed formula, read off the page image
(printed p.179), is

```
ρ(x) ∧ ∀y < x(¬ε(x, y) → ∃z(y < z < x ∧ ¬ρ(z)))
```

The corpus drops the implication's antecedent, drops the `∃z` binder (leaving `z` free, so the text
is not a well-formed formula of one free variable), substitutes the two-place `ε(y,z)` for the
one-place `¬ρ(z)`, and flattens the nesting. `pdftotext` is also unusable on that page. Only the
printed formula means what Reynolds says it means. The printed formula was transcribed; the plan
premise is reported as a deviation, not silently followed.

This is the second such defect — the first, `ρ`'s missing middle conjunct, was found in Phase 17.
Every remaining displayed formula in §6 should be read off the page image.

## Verification

| Gate | Result |
|---|---|
| Full `lake build` | green, **1929 jobs** (1928 before) |
| Sorries in `DenseModelSurgery/` | **0** |
| New sorries anywhere | **0** — sole live-tree sorry remains `Transfer.lean:1225`, pre-existing and untouched |
| Vacuous definitions | **0** |
| New axioms | **0** (repo total unchanged at 2) |
| `#print axioms`, all 27 declarations | `[propext, Classical.choice, Quot.sound]` or the strict subset `[propext]`; `sorryAx` absent everywhere |

## Anti-vacuity, recorded honestly

Every §6 theorem below Lemma 2 is conditional on both `IsContempEquivDense ε` and
`EndsInGapOnRight M ε t`, and the only exhibited inhabitant of the former (`epsTop`) refutes the
latter everywhere. That is the shape of Reynolds' argument — §6 exists in order to refute
`EndsInGapOnRight` — but it means none of Lemmas 3-8 has a live non-trivial instance until Phase
22's chronicle instance. This is stated in the module's closing section rather than left for a
reader to discover.

## Commits

- `04dddfbb1` phase 17: §6 vocabulary, `ρ`/`λ`, Lemma 2 (committed here per the tree-state caveat)
- `3f11d4675` phase 18.1: class calculus and the right-hand end point
- `884f7282b` phase 18.2: Lemma 3's auxiliary formula `B`
- `45e1856e6` phase 18.3: the left-hand end point, third case ruled out
- `4482415e9` phase 18: Lemmas 3 and 4 assembled
