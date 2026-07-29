# Phase 22 — Reynolds §6 Lemma 9 and Theorem 4 (D1)

**Status**: `[PARTIAL]`. Lemma 9 and both halves of Theorem 4 are landed, sorry-free and
axiom-clean. The standing §6 conditionality caveat is **not** retired.

## Landed

`FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/NoGaps.lean` (new, 742 lines), plus one
import line in `FormalSystem/Metalogic/WeakCanonical.lean`. Zero removals, zero renames.

| Declaration | Printed step |
|---|---|
| `priorUFormula`, `priorSFormula` | Prior-U / Prior-S as `Formula`s, p.168 |
| `temporalTruth_untl_top`, `temporalTruth_someFuture_neg`, `temporalTruth_kPlus_neg`, `temporalTruth_untl_stop` (+ 4 past mirrors) | the four readings the schemes are built from |
| `temporalTruth_priorUFormula`, `temporalTruth_priorSFormula` | the rendering, *checked* against `SemanticPriorU`/`PriorS`'s bodies |
| `semanticPriorU_iff_forall`, `semanticPriorS_iff_forall` | Prior-U/S as schemes of temporal formulas |
| `surgeredSemanticPriorU`, `surgeredSemanticPriorS` | *"`N` is a Prior structure"*, p.182 |
| `restrict_val_min/max`, `surgerySubintervalEquiv`, `surgerySubintervalIso`, `contemp_of_mem_class_interval`, `surgeredContempEquiv_of_base` | *"By the contemporaneity of `ε`, `I` … is all in one `∼_N`-class"* |
| `surgeryBase`, `endsInGapOnRight_of_mem`, `mem_of_badStretch`, `reynolds_lemma9_R_in_N`, `reynolds_lemma9_exists_after`, `exists_not_isBadPoint_gt` | Lemma 9's six sentences |
| `reynolds_lemma9` | **LEMMA 9** |
| `HasBadIntervalSurgery` | the one input Theorem 4 still needs |
| `no_gaps_dense_prior`, `no_gaps_dense_prior_left` | **THEOREM 4** (D1), both ends |

## Literature verification

Both pages read as **200 dpi images** (`pdftoppm -f 18 -l 19 -r 200`), not `pdftotext`.

- **Measured range: printed pp.182-183.** PDF p.18 carries running header **182** and holds the
  whole of Lemma 9; PDF p.19 carries **183** and opens with Theorem 4's statement, followed
  immediately by §7. The `+164` §6 offset holds; the plan's extrapolation was right and v8's
  unmeasured `pp.180-181` was wrong.
- **Corpus divergence found**: the page image spells *"appropraite"* in Lemma 9's second
  paragraph; the corpus markdown silently normalizes it to *"appropriate"*. A conversion artifact,
  not a defect in Reynolds. Recorded because §6's corpus text is under a standing accuracy warning.
- No **displayed** formula occurs anywhere in Lemma 9 or Theorem 4 — the whole of both is inline
  prose, which is the half of the corpus the standing warning rates as clean. Nothing needed
  cross-checking against a display.

## The step Phase 21 flagged, discharged

*"`N` is a Prior structure"* is fully proved, with no hypothesis beyond Lemma 8's. Reynolds'
justification — *"we still have all the instances of Prior-U/S continuing to hold as any
counterexample point in `N` is also one in `M`"* — is a **formula-level** argument: Prior-U is a
scheme, so its instances are temporal formulas and Lemma 8 moves them. The landed `SemanticPriorU`
is stated with explicit carrier quantifiers, so the argument cannot run on it directly: a semantic
transfer would need, from *"`p` holds at every point of `N` in `(t,s)`"*, the same about every
point of `M`, and the points of `Q₀ ∖ I` are exactly the ones that fail. Hence the scheme bridge,
built on the landed `Kamp.temporal_truth_top/_neg/_and/_or` and `Kamp.kPlus_formula_correct` —
nothing re-derived.

## The gap, located exactly

Theorem 4 is conditional on `HasBadIntervalSurgery`, which stands in for **Reynolds' Lemma 6 first
clause** — *"in any bad interval both `R` and `L` hold throughout"* (printed p.180). The
obstruction was measured, not guessed:

- `IsBadInterval.saturated` is stated over `IsBadPoint` (= `R ∨ L`), so the bad-connected
  component of a point is the only candidate satisfying it;
- but `IsBadIntervalSurgery.interior` demands `ClassInteriorToBadInterval`, carrying `R` **and**
  `L` throughout its segment;
- closing that is `L → R` at a point where only `L` is known. `endsInGapOnRight_of_endsInGapOnLeft`
  (`BadIntervals.lean:1346`) proves the implication, but only from a `ClassInteriorToLInterval`
  witness; producing that witness at a merely-`L` point is the missing clause.

This is the same clause `reynolds_lemma6_right_endpoint` already carries as `hbadR`, with the
recorded note that the landed development declined to assume it silently. **One gap, one place,
three declarations.** Everything else assembles from landed material: `reynolds_lemma4_no_last_class`
supplies the upper interiority witness, `reynolds_lemma4_no_first_class` the lower.

This is a gap in the formalization, **not** in Reynolds: his Lemma 6 states the clause and he
treats it as established by the time Lemma 9 runs.

## The caveat is NOT retired

Stated plainly, because the phase's charter made this the deliverable's point:

- **Structure half** — blocked by *module direction*, not mathematics.
  `chronicleIsDensePriorSepStructure` (`ChronicleMonadicBridge.lean:1053`) exists and is a genuine
  Prior structure, but `ChronicleMonadicBridge` **imports** `WeakCanonical`, so a module under
  `WeakCanonical/DenseModelSurgery/` cannot import it back. The instantiation needs a new module
  downstream of both — outside this phase's `Owns`. Territory was not extended silently.
- **`ε` half** — unchanged. `epsTop` is still the only exhibitable `ε`, and `EndsInGapOnRight` is
  empty for it. There is still **no live non-trivial instance** of anything in `Lemma5.lean`,
  `BadIntervals.lean`, `Dual.lean`, `TruthTransfer.lean` or `NoGaps.lean`.
- **A third condition**, new here: `HasBadIntervalSurgery`.

The caveat therefore stays **verbatim** in every module header that carries it; none was softened.
`NoGaps.lean`'s closing section `## Conditionality after Theorem 4` states the position in full so
no reader has to reconstruct it.

Note that even the chronicle instantiation, once landed, would discharge only the Prior-U/S
hypotheses — it would not by itself retire the caveat.

## Verification

- Full `lake build` green: **1940 jobs** (+1 over Phase 21's 1939, the new module). No foreign
  failure observed in `Decidability/Verified/Bridge/`.
- `#print axioms` on `reynolds_lemma9`, `no_gaps_dense_prior`, `no_gaps_dense_prior_left`,
  `surgeredSemanticPriorU`, `surgeredSemanticPriorS`, `surgeredContempEquiv_of_base`,
  `temporalTruth_priorUFormula`, `temporalTruth_priorSFormula`: all
  `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- Sorry census outside `Boneyard/`: **1**, `WeakCanonical/Transfer.lean:1242` — pre-existing,
  unrelated, untouched. My delta: **0**.
- Vacuous-definition scan over `DenseModelSurgery/`: 0. New `axiom` declarations: 0.

## Follow-ups (named, not vague)

- **F1** — Reynolds' §6 Lemma 6 first clause, *"in any bad interval both `R` and `L` hold
  throughout"* (printed p.180). Discharges `HasBadIntervalSurgery` **and** `reynolds_lemma9`'s and
  `reynolds_lemma6_right_endpoint`'s `hbadR` at once, making Theorem 4 unconditional in its Prior
  hypotheses and consumable by Phase 29.
- **F2** — a new module downstream of both `BXCanonical/Chronicle` and
  `WeakCanonical/DenseModelSurgery` carrying the chronicle anti-vacuity instantiation of D1.
  Blocked behind F1 for the result to be non-trivial.
