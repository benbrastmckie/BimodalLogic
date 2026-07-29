# Phase 23 — Reynolds §7 Theorem 5: D2 from `Axiom.sep`

- **Task**: 408
- **Phase**: 23
- **Plan**: `plans/10_strong-completeness-dedekind-v10.md`
- **Mode**: `--hard`, single-phase dispatch, transcription
- **Session**: `sess_1785278656_384f35`

## Headline

**D2 is landed.** `dense_singletons_of_sep` and `reynolds_theorem5` are sorry-free and
axiom-clean, and `chronicleMonadic_dense_singletons` instantiates Theorem 5 at
`chronicleIsDensePriorSepStructure` with Prior-U, Prior-S **and Sep** all discharged.

**BLOCK G CHECKPOINT reached**: both hypotheses of Doets' theorem — D1 (`no_gaps_dense_prior`,
Phases 22/22.1) and D2 (`dense_singletons_of_sep`, this phase) — are now available.

No source defect was found in §7 and none is claimed. The §7 corpus chunk is clean.

## What landed

| Home | Declarations |
|---|---|
| `DenseModelSurgery/Singletons.lean` (new, 598 lines) | `IsLeftEndPoint`, `IsRightEndPoint`, `IsSingletonClass`, `QuotientDenselyOrdered`, `HasDenseSingletons`, `SemanticSepOpen`, `exists_rightEndPoint`, `quotientDenselyOrdered_dual`, `exists_leftEndPoint`, `leftEndFormula`, `leftEndFormula_eval`, `classLeftEndFormula`, `classLeftEndFormula_spec`, `not_leftEnd_and_untl`, `not_kplusOpen_of_never`, `kplusOpen_classLeftEnd`, `isSingletonClass_of_kplus_kminus`, `reynolds_theorem5`, `dense_singletons_of_sep`, `quotientDenselyOrdered_epsTop_vacuous` |
| `DenseModelSurgery/ChronicleInstance.lean` (additive) | `chronicleMonadic_dense_singletons`, `chronicleMonadic_dense_singletons_epsTop_vacuous` |
| `Metalogic/WeakCanonical.lean` | one import line |

## The page measurement, which refuted the plan again

Measured off the 200 dpi page images, PDF indices 18-20:

- The §6 offset **does** carry over to §7: `printed page = PDF 1-based page + 164`, re-verified
  page by page rather than assumed.
- §7 *Separability* **opens on printed p.183**, directly beneath Theorem 4's statement.
- **Lemma 10** (Sep's validity over real flows) and its whole proof are on **p.183**, not p.184 as
  the plan says.
- **Theorem 5's statement and its entire proof fit on printed p.184 alone**, not pp.184-185. §8
  *Doets' Theorem* also opens on p.184, so p.185 is already inside §8's preliminaries.

**Corpus reliability differs from §6's.** §6's chunk had two recorded display defects and Phase
22.1 repaired a genuine one-symbol defect in Reynolds' Lemma 4 display. The §7 chunk
(`sec04_7-separability.md`) was compared sentence-by-sentence against both page images and is
**clean**. Theorem 5 carries **no displayed formulas at all** — every formula is inline — which is
consistent with §6's finding that the corpus's inline prose is reliable where its displays are not.
So: no §7 defect, no §7 repair, nothing landed beside a faithful transcription.

## Proof-step to declaration map

Reynolds' five proof paragraphs, in order:

| Step (printed p.184) | Declaration |
|---|---|
| *"the classes do not end at gaps"* | `no_gaps_dense_prior` / `_left` (consumed, not re-proved) |
| *"the classes must be closed intervals"* | `exists_rightEndPoint` / `exists_leftEndPoint` |
| *"Without loss of generality, `c` is the right hand end point of its class"* | **discharged**, not assumed: `exists_rightEndPoint` applied to `c` |
| *"Let the temporal formula `C` …"*, *"We use expressive completeness here"* | `leftEndFormula` → `classLeftEndFormula` (the sole §7 consumption of Phase 14) |
| *"`C ∧ U(C,¬C)` never holds in `M`"* | `not_leftEnd_and_untl` |
| *"…so `¬K⁺(C ∧ U(C,¬C))` holds at `c`"* | `not_kplusOpen_of_never` |
| *"Also `K⁺(C)` holds at `c`"* | `kplusOpen_classLeftEnd` |
| *"we can use axiom Sep to deduce `K⁺(K⁺C ∧ K⁻C)`"* | the `h_sep` hypothesis |
| *"`K⁺C ∧ K⁻C` must hold at some `e` between `c` and `d`"* | `reynolds_theorem5`, final application |
| *"but clearly `e` must be in a class of its own"* | `isSingletonClass_of_kplus_kminus` |

Two structural findings worth recording:

1. The **WLOG is discharged**, not assumed. `exists_rightEndPoint` moves `c` to the right hand end
   point `c'` of its own class; `c ≤ c'` and `c' < d` and `c' ≁ d` all follow from convexity plus
   the end-point property, so nothing is assumed away.
2. **`isSingletonClass_of_kplus_kminus` consumes no gap lemma at all.** A class-mate `y ≠ e`
   supplies its own bound for `K⁺`/`K⁻`, and the left end point that lands strictly inside `(e,y)`
   (resp. `(y,e)`) contradicts its own left-end-point property directly. Reynolds' *"but clearly"*
   is, on inspection, genuinely immediate.

## Assets reused rather than rebuilt

- **Theorem 4, both ends**, consumed inside `reynolds_theorem5` — so Theorem 4 is *not* an extra
  hypothesis of Theorem 5; the Prior pair it needs is already there.
- **`Dual.lean`'s order-duality transport** for the left-hand closed-interval lemma:
  `exists_leftEndPoint` is `exists_rightEndPoint` instantiated at `(dual M, dualize ε)` through
  `endsInGapOnRight_dual`, `contempEquivDense_dual`, `isContempEquivDense_dualize` and `d_lt`. The
  one new transport it needed, `quotientDenselyOrdered_dual`, is landed. **No hand mirror.**
- **Phase 10.1's `K⁺`/`K⁻` bridge**, `Kamp.kPlus_formula_correct` / `kMinus_formula_correct`, cited
  by name in the module header and used to read `Axiom.sep`'s `Formula.kPlus`/`kMinus`.
- **`uSExpressivelyCompleteOverDensePrior`** (§5 Theorem 3), consumed at exactly one place.
- **`ChronicleInstance.lean`** extended rather than duplicated.

## Verification

| Check | Result |
|---|---|
| `#print axioms`, all 12 `Singletons.lean` targets | exactly `[propext, Classical.choice, Quot.sound]` or a subset; **no `sorryAx`** |
| `#print axioms`, both new `ChronicleInstance.lean` targets | `[propext, Classical.choice, Quot.sound]` |
| Regression canaries `chronicleMonadic_no_gaps`, `chronicleMonadic_no_gaps_left` | unchanged: `[propext, Classical.choice, Quot.sound]` |
| Live sorries outside `Boneyard/` | **two**: `WeakCanonical/Transfer.lean:1242` (pre-existing, unrelated, not attempted) and `Decidability/Verified/Decidable.lean:1002` (**foreign** — committed by the concurrent task-165 session, outside this phase's territory) |
| Vacuous definitions | 1 hit, pre-existing and outside territory (`Examples/TemporalStructures.lean:277`); unchanged |
| `^axiom ` declarations | 2 hits, both prose inside Boneyard docstrings, not declarations; unchanged |
| Removals / renames (D11) | **zero** in both files |
| Scoped builds | `Singletons` green at 1248 jobs; `ChronicleInstance` green at 1884 jobs |
| Full `lake build` | **green, 1983 jobs** (absolute figure contaminated by the concurrent session's modules; this phase's own delta is **+1 module** plus the import-cone join it creates) |
| Task-number citations in `.lean` | none |

## What this phase does NOT claim

**The standing §6 conditionality caveat is NOT retired, and Phase 23 adds nothing to its
discharge.** Theorem 5 consumes Theorem 4, so it is conditional on everything Theorem 4 is
conditional on, plus Sep and plus density of `M/∼`. Specifically:

- `IsContempEquivDense ε` remains a hypothesis. `epsTop` is still the only `ε` this tree can
  exhibit satisfying it; `EndsInGapOnRight` is still empty for it; there is still **no live
  non-trivial instance** of any §6 or §7 result below Lemma 2. The `ε` half stands until **Phase
  25** (§8 Lemma 12).
- The `epsTop` instantiation of Theorem 5 is vacuous **twice over**, and the second reason is new:
  `QuotientDenselyOrdered M (epsTop sig)` is itself *unsatisfiable* whenever `M` has two distinct
  points, since `epsTop`'s single class is the whole structure. Recorded in-file as
  `quotientDenselyOrdered_epsTop_vacuous` and `chronicleMonadic_dense_singletons_epsTop_vacuous`.
- **No §6 or §7 result is described as discharged** in any docstring produced by this phase.

## Deviations

Five, all recorded in the plan's Phase 23 deviation record. The two that matter:

- **Page range corrected** (#1) — `p.184` alone, not `pp.184-185`; Lemma 10 on `p.183`. A **plan**
  error, not a source defect.
- **`SemanticSepOpen` restated rather than imported** (#2) — to keep the parametric §6/§7 layer off
  `ChronicleMonadicBridge`'s ~280-module closure. `SemanticSep` is untouched, and the definitional
  identity is machine-checked by use in `ChronicleInstance.lean` rather than asserted.
