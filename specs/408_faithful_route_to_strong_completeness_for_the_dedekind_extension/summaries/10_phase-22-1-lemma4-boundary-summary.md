# Phase 22.1 — Reynolds §6 Lemma 4's boundary case, and the discharge of `HasBadIntervalSurgery`

- **Task**: 408
- **Phase**: 22.1 (Phase 22 closes `[COMPLETED]` in the same postflight)
- **Plan**: `plans/10_strong-completeness-dedekind-v10.md`
- **Research consumed**: `reports/09_lemma6-first-clause-blocker.md` §3 (the pre-compiled route)
- **Mode**: `--hard`, single-phase dispatch, transcription
- **Session**: `sess_1785278656_384f35`

## Headline

The 239-line pre-compiled route from `reports/09` §3 transcribed into the tree.
**The hard gate was not tripped**: Step A reproduced green in-file on the first attempt with zero
repairs, and so did Steps B, C and D. The one repair needed in the whole dispatch was a missing
`open` in the new `ChronicleInstance.lean` — a namespace matter, not a proof failure. None of the
five residual errors recorded in `reports/09` §3.6 was re-encountered, because all five were
pre-applied from the charter's table before the first build.

`HasBadIntervalSurgery` is now a theorem. `no_gaps_dense_prior` and `no_gaps_dense_prior_left`
no longer carry it.

## What landed

| Step | Home | Declarations |
|---|---|---|
| A | `DenseModelSurgery/Lemma34.lean` | `firstClassFormulaClosed`, `IsFirstClassPointClosed`, `firstClassFormulaClosed_eval`, `firstClassTemporalClosed`, `firstClassTemporalClosed_spec`, `isFirstClassPointClosed_congr`, `not_isFirstClassPointClosed`, `reynolds_lemma4_no_first_class_closed` |
| B | `DenseModelSurgery/BadIntervals.lean` | `exists_classInteriorToRInterval` |
| C | `DenseModelSurgery/BadIntervals.lean` | `endsInGapOnLeft_of_endsInGapOnRight'`, `endsInGapOnRight_of_endsInGapOnLeft'` |
| D | `DenseModelSurgery/NoGaps.lean` | `StepD.Btw`, `btw_of_minmax`, `minmax_of_btw`, `btw_self`, `badComp`, `badComp_isBadInterval`, `badComp_right`, `hasBadIntervalSurgery`; hypothesis-free `no_gaps_dense_prior` / `no_gaps_dense_prior_left`; retained `no_gaps_dense_prior_of_hasBadIntervalSurgery` / `no_gaps_dense_prior_left_of_hasBadIntervalSurgery` |
| F2 | `DenseModelSurgery/ChronicleInstance.lean` (new) | `chronicleMonadic_no_gaps`, `chronicleMonadic_no_gaps_left`, `chronicleMonadic_no_gaps_epsTop_vacuous` |

Plus one import line in `FormalSystem/Metalogic/WeakCanonical.lean`.

## The source defect, stated precisely

Reynolds 1992, §6 Lemma 4, printed **p.179**, verified against the 200 dpi page image (the local
corpus's rendering of this display is corrupt; the image is authoritative):

> ρ(x) ∧ ∀y < x(¬ε(x, y) → ∃z(y < z < x ∧ ¬ρ(z)))

With `y < z` **strict**, the formula is **false** at a point `x` of the first class of a maximal
`R`-interval bounded below by an excluded end point `r ∈ M` — the configuration Reynolds' own
Lemma 3 licenses. The universal clause at `y := r` demands a `z` with `r < z < x` and `¬ρ(z)`, but
`(r, x)` lies inside `x`'s own class where `ρ` holds throughout, so no witness exists.

The display stays **sound** (true only in first classes), which is the direction Reynolds' own
Lemma 4 proof consumes — so the landed `reynolds_lemma4_no_first_class` is correct as it stands.
What fails is completeness, and the plain-English statement Lemma 6's second paragraph
(printed p.180) goes on to consume is the stronger one. Reading the inner bound as `y ≤ z` repairs
it: at `y := r`, take `z := r`.

**Two honesty constraints, both honoured:**

1. **The defect is the SOURCE's**, recorded as the source's under honesty-charter Rule 7. The
   tree's transcription was faithful and was the right thing to do. `firstClassFormula` and
   `IsFirstClassPoint` are **not modified**; the repaired variant lands beside them. The
   `Lemma34.lean` section docstring quotes the printed display verbatim, names the boundary
   configuration, attributes the defect to the source, and states the fallback framing if the
   attribution is disputed. Recorded as flagged deviation #1 in the plan's Phase 22.1 deviation
   record.
2. **The earlier claim that Reynolds asserts Lemma 6's first clause without argument is
   REFUTED**, and the sentence carrying it in `NoGaps.lean` is corrected. He gives a five-paragraph
   proof with an explicit three-case analysis and a Prior-U contradiction, and **both halves of the
   clause were already landed** in this tree (Phases 20 and 20.4). What was missing was only the
   **hypothesis discharge** — nothing produced a `ClassInteriorToRInterval` witness on either side.

That `reynolds_lemma4_no_first_class_closed`'s proof is byte-for-byte the shape of the landed
`reynolds_lemma4_no_first_class`, closing through the same `false_of_holds_throughout_class`, is
the machine-checked evidence that the repair is faithful to Reynolds' prose even where it deviates
from his display.

## Verification

| Check | Result |
|---|---|
| `#print axioms` on all 11 target declarations | exactly `[propext, Classical.choice, Quot.sound]`; **no `sorryAx`** |
| Canaries `completeness_dense`, `completeness_discrete` | unchanged: `[propext, Classical.choice, Quot.sound]` |
| Live sorries outside `Boneyard/` | **exactly one**: `WeakCanonical/Transfer.lean:1242` — pre-existing, unrelated, not attempted |
| Vacuous definitions | 1 hit, pre-existing and outside territory (`Examples/TemporalStructures.lean:277`, a genuine `trivial` goal); unchanged |
| `^axiom ` declarations | 2 hits, both **prose inside Boneyard docstrings**, not declarations; unchanged |
| Declaration census, `Lemma34.lean` | 41 → 49, **zero removals** |
| Declaration census, `BadIntervals.lean` | 50 → 53, **zero removals** |
| Declaration census, `NoGaps.lean` | 33 → 42, **zero removals** |
| Preserved assets (9) | all present exactly once; `Lemma34.lean` and `BadIntervals.lean` are **purely additive** (zero deleted lines) |
| Scoped builds | green at every substep |
| Task-number citations in `.lean` | none |

The declarations whose signatures changed are exactly the two the charter authorises:
`no_gaps_dense_prior` and `no_gaps_dense_prior_left`, **strengthened only** (one hypothesis
removed), with the hypothesised forms retained under `_of_hasBadIntervalSurgery`. No external
caller existed (verified repo-wide before the change).

## What this phase does NOT claim

**The standing §6 conditionality caveat is NOT retired.** Halves one and two stay verbatim in
`Lemma5.lean`, `BadIntervals.lean`, `Dual.lean`, `TruthTransfer.lean` and `NoGaps.lean`. The
rewritten `## Conditionality after Theorem 4` states the three-condition accounting:

- **`HasBadIntervalSurgery`** — fully gone (a theorem at every structure);
- **Prior-U / Prior-S** — gone **at one named structure** (`chronicleIsDensePriorSepStructure`),
  standing in general, since the surgery layer is parametric in `M`;
- **`ε`** — **standing until Phase 25**. `epsTop` remains the only `ε` this tree can exhibit,
  `EndsInGapOnRight` is empty for it, and an instantiation there is vacuous. There is still **no
  live non-trivial instance** of any §6 result below Lemma 2.

**No §6 result is described as discharged** in any docstring produced by this phase.
`ChronicleInstance.lean` carries `chronicleMonadic_no_gaps_epsTop_vacuous` specifically so that the
vacuity of the only available instantiation is stated in the file rather than left to be
rediscovered.

## Deviations

Five, all recorded in the plan's Phase 22.1 deviation record. The two that matter:

- **Flagged deviation from the source** (#1) — the `≤` repair, per constraint 1 above.
- **In-place edit beyond the one permitted** (#4) — two further docstring corrections in
  `NoGaps.lean` (the module header's *"adds a third condition"* paragraph and the `## Theorem 4`
  section header's *"the input this tree cannot yet supply"* / *"the clause that is missing"*).
  Both became actively false the moment `StepD.hasBadIntervalSurgery` landed; leaving them would
  have left the file asserting a standing gap that no longer exists. Prose only.

The other three are the two chartered placement choices (Step B in `BadIntervals.lean`, forced by
the import DAG since `ClassInteriorToRInterval` is defined downstream of `Lemma34.lean`; F2 at
`DenseModelSurgery/ChronicleInstance.lean`, the recommended home) and the chartered signature
change.

## Scope hypothesis, confirmed

`reports/09`'s estimate was ~415 lines across 4 files. Actual: **+628 / −48** across the four
files plus one import line. The proof content matched the 239-line pre-compiled figure closely;
the overrun is entirely docstring — the Rule 7 quotation block and the three-condition rewrite.
Reported here rather than absorbed into an unchanged estimate.

## Concurrency

A task-165/416 session committed into this repository during this dispatch
(`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`, `ProofSystem/Axioms.lean`,
`Semantics/Validity.lean`). Those are **foreign** and were neither read for edit nor staged. Each
of this phase's five commits touches only `DenseModelSurgery/`, `WeakCanonical.lean`, and the plan
file.
