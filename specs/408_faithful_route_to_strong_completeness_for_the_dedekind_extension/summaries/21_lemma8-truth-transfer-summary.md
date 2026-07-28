# Phase 21 — Reynolds §6 Lemma 8: truth preservation under bad-interval surgery

**Status**: COMPLETED. Zero sorry, zero removals, zero renames.
**Owns**: `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/TruthTransfer.lean` (new, 806 lines).

## What landed

Reynolds 1992, §6 Lemma 8, printed **pp.181-182**: *"For all temporal formulas `A`, for all
`t ∈ N`, `M ⊨ A(t)` iff `N ⊨ A(t)"`*, where `N` is `M` with a whole bad interval `Q₀` replaced by
one of its `∼`-classes `I`.

| Declaration | Reynolds' step |
|---|---|
| `restrictStructure`, `SurgeryDomain`, `surgeredStructure` | *"the substructure of `M` whose domain is just `Q⁻ ∪ I ∪ Q⁺`"* |
| `IsBadIntervalSurgery` | *"`Q₀` the bad interval itself and `I` … one of its `∼`-classes"* |
| `.lt_of_before` / `.lt_of_after` / `.mem_of_contemp` | *"all that precedes"* / *"all that follows"* / `I ⊆ Q₀` |
| `.exists_mem_lt` / `.exists_mem_gt` | a bad interval has no first and no last point (Lemma 6, used from inside) |
| `.lemma7_{start,end,close_left,close_right}_wide` | Lemma 7 re-indexed from a segment to the whole bad interval |
| `reynolds_lemma8_untl_forward` | forward cases 1-7, printed p.181 |
| `reynolds_lemma8_untl_backward` | backward cases 1-6, printed p.182 |
| `temporalTruth_iso`, `surgeredDualIso`, `isBadIntervalSurgery_dual`, `snce_mirror_ih` | the bridges for *"`S(A,B)` is similar"* |
| `reynolds_lemma8_snce_forward` / `_backward` | *"`S(A,B)` is similar"*, by instantiation |
| **`reynolds_lemma8`** | **LEMMA 8** |

## Literature verification

Both printed pages were read as **images** at 200 dpi (`pdftoppm -f 17 -l 18` of the corpus PDF),
not from `pdftotext` and not from another docstring. PDF p.17 carries the printed running header
**181**, PDF p.18 carries **182** — confirming the measured §6 offset `printed = PDF + 164` and
v9's corrected range (v8's `pp.179-180` was wrong).

- **Case count, measured not assumed**: seven forward and six backward, thirteen in all, counted
  off the images. The plan's hypothesis was right.
- **The one displayed formula** in Lemma 8 (`M ⊨ A(t) iff N ⊨ A(t)`) is **clean** in the corpus
  markdown — checked against the image, per the standing warning that §6's displays are
  unreliable. The thirteen case bodies were compared line by line and agree with the corpus
  prose; the only difference is *"Straight forward"* vs *"Straightforward"*, which is typesetting.

## Two measured divergences from the printed text, both recorded in the module header

1. **Reynolds' seven forward cases are jointly exhaustive but not pairwise disjoint** — his case 4
   (*"`t < s ∈ I`"*) overlaps his case 2 (*"`t ∈ Q⁻` and `s ∈ Q₀`"*) when `t ∈ Q⁻` and `s ∈ I`.
   Lean needs a disjoint split, so the transcription fixes the position of `t` first and of `s`
   second: `3 + 3 + 1 = 7` forward and `3 + 2 + 1 = 6` backward, exactly his counts, with his case
   4 read as the `t ∈ I` reading. Case-by-case correspondence is in the header table and in inline
   case comments.
2. **Reynolds names Lemma 7 in forward case 3**, where in this rendering his remark that *"`B`
   holds throughout `I`"* is simply the observation that `I ⊆ (t, s)`, so the `U`-hypothesis
   already covers it. Lemma 7 is genuinely consumed in forward cases 2 and 5 and backward cases 2,
   3 and 5 — five of thirteen; the other eight are his *"apply the induction hypothesis at `s` and
   at all points in between"*, factored into two shared helpers.

## The gap-crossing family: which form was used, and why

**None of them directly.** The three (four with the past mirror) gap-crossing contradictions
differ only in their preconditions, and the choice among them was already made *inside* Lemma 7.
This module consumes `reynolds_lemma7`'s four landed halves and nothing below them; re-picking a
gap-crossing form here would have been re-deriving Lemma 7. **No Prior axiom is applied anywhere
in the owned file outside the four `reynolds_lemma7_*` calls.** The only new bridge is the
`_wide` family, which is pure re-indexing of the landed segment-bounded statements onto the whole
bad interval, via `IsBadIntervalSurgery.interior`.

## The `S` mirror: instantiation, not a third hand-written mirror

`Dual.lean`'s landed policy (*"no later phase should derive a third mirror by hand when an
instantiation at `(dual M, dualize ε)` will do"*) was followed. `S(A,B)` is the `U` case run at
the order-dual and transported back.

**Cost was ~110 lines, not the ~25 the plan estimated**, because two bridges were missing:

- `temporalTruth_iso` — `Dual.lean` proved `eval` invariant along a `StructIso` but never lifted
  it to `TemporalTruth`. The lift is `table_correctness` on both sides of `eval_iso`, five lines.
  Stated for an arbitrary `StructIso`, so it is reusable for any later carrier transport.
- `surgeredDualIso` — `surgeredStructure` commutes with `dual` only up to rewriting its domain
  predicate by `contempEquivDense_dual`, exactly as `subintervalDualIso` handles the subinterval's
  conjunct exchange. Same points, same order, same interpretations.

Plus `isBadIntervalSurgery_dual` (every clause is its own mirror: *"non-empty"* unchanged, *"`R ∨ L`
throughout"* is `isBadPoint_dual` since the disjunction is symmetric, *"interval"* and *"maximal"*
reverse their bounds, interiority witnesses exchange).

**Nothing in `Dual.lean` or `BadIntervals.lean` was edited, renamed, weakened or deprecated.**

## `truth_transfer` (`Transfer.lean:361`): does not transfer

Recorded in the module header so the comparison is not made twice. `truth_transfer` is an
Ehrenfeucht-Fraïssé argument — it moves an *existentially closed* formula between two
`k`-equivalent structures, concluding *"`ψ` holds at **some** point of `N`"*. Lemma 8 needs
point-by-point agreement at a *designated* `t` between structures not assumed `k`-equivalent, with
all the content in the `U`/`S` cases. Only `TemporalTruth` is shared vocabulary. `table_correctness`,
which `truth_transfer` uses, **is** reused — inside `temporalTruth_iso`.

## Dependency check (plan's first task)

The de-serialization from Phase 20.4 held. Consumed: `reynolds_lemma7_start`, `_end`,
`_close_to_left`, `_close_to_right`, `IsBadInterval`, `ClassInteriorToBadInterval`.
**Not** consumed: `reynolds_lemma6`'s fourth conjunct, `reynolds_lemma6_nonsingleton`,
`reynolds_lemma6_right_endpoint`. The two Lemma 6 facts Lemma 8 does need (*"no first point"*,
*"no last point"*) are re-derived in-file as `exists_mem_lt` / `exists_mem_gt` from the interiority
witnesses plus `IsBadInterval.saturated`, four lines each. No `[BLOCKED]` report was required.

Phase 20.4's `Dual.lean` **was** used, for the `S` mirror only — off the critical path in the sense
that the `U` case (`reynolds_lemma8_untl_forward` / `_backward`) was landed and committed green
before the mirror was attempted.

## Honest caveat, carried and not weakened

Every §6 lemma below Lemma 2 is **conditional**, Lemma 8 included. `IsContempEquivDense ε` plus
semantic Prior-U / Prior-S are hypotheses, and the only `ε` this tree can exhibit satisfying them
is `epsTop`, for which `EndsInGapOnRight` is empty — **there is no live non-trivial instance of
anything in this file**. Nothing in §6 below Lemma 2 may be described as discharged until the
anti-vacuity instance lands with Lemma 9 and Theorem 4 (Phase 22). The caveat appears in the
module header and again in `reynolds_lemma8`'s own docstring.

## Verification

| Gate | Result |
|---|---|
| Sorries in owned file | **0** |
| Sorry delta for this job | **0** |
| Vacuous definitions | 0 |
| New axioms declared | 0 |
| `#print axioms reynolds_lemma8` | `[propext, Classical.choice, Quot.sound]` — no `sorryAx` |
| Scoped build | green (1246 jobs) |
| Full `lake build` | green (1939 jobs) |
| Removals / renames | 0 / 0 (D11 honoured) |

**Repository sorry state, observed not owned**: outside `Boneyard/` the only live sorry is
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` (pre-existing, unrelated, never touched).
The two `Decidability/Verified/Bridge/IntTruth.lean` sorries flagged in the dispatch **no longer
exist** — the concurrent session closed them; only prose mentions of the word remain in that file.
Reported as an observation about someone else's territory, not as this phase's delta.

## Commits

| Commit | Content |
|---|---|
| `c8926069e` | 21.1 — surgery set-up, `N`, the `Q`-geometry |
| `7660985cf` | 21.2 — Lemma 7 re-indexed to the whole bad interval |
| `3e00c23f1` | 21.3 — Lemma 8's `U` case, all thirteen printed cases |
| `cc56116b3` | 21.4 — the `S` mirror by instantiation, and Lemma 8 |

## What Phase 22 inherits

- `reynolds_lemma8` at arbitrary `A`, and the two direction lemmas if a finer grain is wanted.
- `IsBadIntervalSurgery` and `surgeredStructure` — Lemma 9's *"`R` holds in `I` in `N`"* and its
  *"`N` is a Prior structure"* step both need exactly this vocabulary. **`N` is a Prior
  structure is NOT proved here**; the plan already flags it as needing its own named lemma, and
  nothing in this phase discharges it.
- `temporalTruth_iso` and `surgeredDualIso`, reusable for any further carrier transport.
- The conditionality caveat, still live: Phase 22 is where it is retired, and it must not be
  retired earlier.
