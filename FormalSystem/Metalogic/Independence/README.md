# Independence — underivability results

Underivability results, established by exhibiting a model of the assumptions in which the
target formula fails.

Twelve results are carried here. This list and the one in `Independence.lean`'s module docstring
enumerate the same twelve results in the same order; earlier revisions of the two drifted apart
(this README carried nine, the docstring six, overlapping in five) and were reconciled to their
union.

1. The paper's `CO` principle does **not** derive Reynolds' `Axiom.prior_U_gap` over the dense
   base. The converse direction — Reynolds' triple *does* derive `CO` — is
   `FormalSystem.Theorems.DedekindDerived.coDerived`, so the two settle the relationship in both
   directions.
2. `Sat .RTime ⊊ Mod (AxiomSet .RTime)`, witnessed by the static frame over `ℚ`
   (`sat_rtime_ssubset_mod_axiomSet`, `RationalWitness.lean`).
3. `Sat .ZTime ⊊ Mod (AxiomSet .ZTime)`, witnessed by the static frame over `ℤ ×ₗ ℤ`
   (`sat_ztime_ssubset_mod_axiomSet`, `LexIntWitness.lean`).
4. The stability modal `⊡` is **not L-definable**: no `Formula` is equivalent to `⊡Fp` across
   all task models (`stabNotDefinable`, `StabUndefinable.lean`). This is what makes L⁺ a
   genuinely larger language rather than notation for something L can already say.
5. **`TaskFrame.Deterministic` is not L⁺-definable** (`cor:no-characterization`,
   `deterministic_not_plusDefinable`, `DeterminismUndefinable.lean`), witnessed by the
   indistinguishable pair `F°`/`F¹` over `ℝ`: the two agree on every `PlusFormula`
   (`fzero_plusValidOn_iff_f1`). The same pair refutes the converse of the deterministic collapse
   (`PlusLanguage/PlusDeterminism.lean`): `F°` validates *Determined* without being deterministic
   (`determined_valid_on_non_deterministic`).
6. The two **pasting schemata are not derivable** from the naive `⊡`-set {SK, ST, S4, S5, MS, AS}
   together with TM (`PastingIndependence.lean`), so TM⁺'s axiom set is non-redundant.
7. **Store and recall discriminate where nothing without them can** (`StarDiscrimination.lean`).
   `sent:det` — the manuscript's `↑¹\Future↑²↓¹(⊡↓²¬φ ∨ ⊡↓²φ)` — is valid over the deterministic
   translation frame `F¹` and refuted over the drift frame `F°`, while result 5's
   `deterministic_not_plusDefinable` shows that no set of `PlusFormula`s separates them at all.
   This is the live-text footnote following `app:deterministic-future`.
8. **`sent:det` defines only *forward* determinism** (`ForwardDeterministicFrame.lean`). The
   frame `F^N` (`W = ℕ`, `D = ℤ`, the absorbing predecessor map) is forward-deterministic and
   **not** `Deterministic`, and `sent:det` is valid over it at every sentence letter. Replacing
   `\Future` by `always` closes the gap: `Det-pm` does define the deterministic frames
   (`StarLanguage/StarDeterminism.lean`'s `deterministic_starDefinable`).
9. **The current TM⁺ axiom set is incomplete at Base** (`PlusIncompleteness.lean`). The
   limit-closure formula `(⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))` — the Burgess/Thomason
   branch-extension pattern transposed to the stability modal — is valid over every task frame
   (`PlusLanguage/PlusLimitClosure.lean`, by Zorn plus the Extension Theorem) and is
   not a Base theorem of TM⁺. Completeness of any *extension* of the axiom set is open at every
   class, and nothing is claimed at Dense, ZTime or RTime.
10. **The `.ZTime` row of `Axiom.minFrameClass` is characterized, not merely upper-bounded**
    (`ZTimeSharpness.lean`). `Metalogic.axiom_validIn_min` already proves every axiom valid at its
    own tag; `prior_UZ_minFrameClass_sharp` and `z1_minFrameClass_sharp` supply the other
    direction, so no frame class strictly below `.ZTime` validates `Axiom.prior_UZ` or `Axiom.z1`.
    `.Dense` and `.RTime` are incomparable with `.ZTime` rather than below it and so are refuted
    separately, by `not_validIn_dense_prior_UZ` / `not_validIn_dense_z1` over the rationals and
    `not_validIn_rtime_prior_UZ` / `not_validIn_rtime_z1` over the reals; with all four classes
    settled, `prior_UZ_validIn_iff_ztime` and `z1_validIn_iff_ztime` state the exhaustive form
    `ValidIn fc φ ↔ fc = .ZTime`. The underivability corollaries are
    `not_derivable_base_prior_UZ` and `not_derivable_base_z1`. What the countermodel refutes is
    *discreteness*, not the Archimedean property: both axioms fail on the translation frame over
    any densely ordered duration group, the reals included.
11. **The `.Dense` rows of `Axiom.minFrameClass` are characterized and its `prior_U_gap` row is
    minimal** (`DenseRTimeSharpness.lean`). One refutation on the translation frame over `ℤ` —
    whose durations have a least positive element, so the group is not densely ordered — gives
    `not_validIn_base_density` / `not_validIn_ztime_density` and
    `not_validIn_base_dense_indicator` / `not_validIn_ztime_dense_indicator`, hence
    `density_minFrameClass_sharp` and `dense_indicator_minFrameClass_sharp` through
    `eq_base_of_lt_dense`, and hence the exhaustive `density_validIn_iff` and
    `dense_indicator_validIn_iff`, both of the form `ValidIn fc φ ↔ .Dense ≤ fc`. A second
    refutation, on the periodic clock frame, gives `not_validIn_base_prior_U_gap` and
    `not_validIn_dense_prior_U_gap` at once, hence `prior_U_gap_minFrameClass_sharp` through
    `base_or_dense_of_lt_rtime`; nothing is claimed about `.ZTime`, which is incomparable with
    `.RTime`. The module also proves the boundary that fixes where a `sep` refutation could live:
    `sep_validOn_of_isLeastPos` shows `sep` is vacuously valid on every frame with a least
    positive duration, so no discrete witness for it can exist. Result 12 supplies the dense one.
12. **The `sep` row of `Axiom.minFrameClass` is characterized** (`SepSharpness.lean`). The dense
    witness result 11 showed to be necessary is the translation frame over the Hahn group
    `Lex (ℚ →₀ ℚ)`, with the atom true exactly on the positive-index single-support generators.
    That region is order-anti-isomorphic to the positive rationals, so it is dense in itself and
    accumulates at `0`; but distinct generators sit on distinct archimedean scales, so no positive
    duration is an accumulation point of it. Both of `sep`'s antecedent conjuncts therefore hold
    at `0` while its consequent fails, giving `not_validOn_sep_lexHahn`, hence
    `not_validIn_base_sep` and `not_validIn_dense_sep` at once, hence `sep_minFrameClass_sharp`
    through `base_or_dense_of_lt_rtime`. Unlike `prior_U_gap`, the `.ZTime` case is *positive* and
    schematic in `φ`: `sep_validIn_ztime` derives it from result 11's
    `sep_validOn_of_isLeastPos`, since `IsZTime` supplies a successor order and hence a least
    positive duration. So `sep_validIn_iff` reads
    `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc`, not `↔ .RTime ≤ fc`, which would be false. The
    underivability corollary is `not_derivable_dense_sep`.

`BehSeparatedness.lean` is deliberately **not** a thirteenth numbered result. It carries a
*strictness* result — separatedness of `Beh F` is strictly stronger than the validity of
*Determined* on `F` — rather than an underivability result established by refuting a formula in a
model, which is what the twelve above are. Its countermodel is result 5's `F°`, reused, and the
asymmetry it records sharpens result 5's second half on the presheaf side.

Results 2 and 3 are the two halves of the finding that the frame-class *narrowings* are not
Galois-closed, in contrast with the paper's bare classes — which are closed, by
`Semantics/Correspondence/Indicator.lean`'s `galoisClosed_sat_dense` and `galoisClosed_isDiscrete`.

Result 6 is the one that leaves the standard semantics. PS and US are valid on **every** task
frame (`PlusLanguage/PlusPasting.lean`), because the splice of two world histories through a common
state is again a world history; so no ordinary task model can witness their underivability. The
witness is a *coarsened-state* model (`CoarsenedModels.lean`), which interprets `⊡` over a
quotient of the world states and thereby removes the common state a splice would need. Everything
else about the argument is the usual four steps.

Result 9 uses the same non-standard semantics with one hypothesis restored. A coarsened model is
*paste-closed* (`PastedCoarseModels.lean`) when the splice exists at the level of `π`-images;
then PS and US are coarsely valid too, and **all** of TM⁺ at Base is sound for it. The witness
(`LimitClosureFrame.lean`, `LimitClosureCountermodel.lean`) has as `π`-images exactly the
eventually-false Boolean sequences: closed under splicing, not closed under limits. In one line,
the coarsened countermodel is a dense, non-closed bundle — PS and US say paste-closed, MF says
translation-closed, nothing says closed. Under `⊡ = id` the formula is a tautology, hence a
theorem of TM⁺ + *Determined*, so the countermodel is necessarily nondeterministic.
Coarse refutations and paste-closure also transfer to the translation product of the underlying
frame (`TranslationProductCoarse.lean`: `c_refuted_lift`, `pasteClosed_liftK`,
`pasteClosed_of_liftK`), which is recurrence-free and satisfies *Limit* for free in the same
frame class — the route by which a coarse countermodel found over a frame without Limit would
become one over a frame with it.

Results 7 and 8 leave the language rather than the semantics: they are stated over **L⋆**
(`FormalSystem/StarLanguage/`), L⁺ plus the manuscript's time store/recall operators. The
paper-label correspondence table for that appendix — every `\label` mapped to a Lean name or to
an explicit exclusion — lives in `FormalSystem/StarLanguage/README.md`.

Every result here follows the same four steps: build a concrete frame satisfying every
structural axiom of the semantics; prove a truth-invariance lemma for it (a symmetry or
periodicity constraining *every* formula uniformly, by induction on `Formula` with the history
universally quantified **inside** the induction, so the `□` case can apply the inductive
hypothesis); derive validity of the assumptions; and exhibit a valuation refuting the target.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Independence -->
| File | Lines | Description |
|------|-------|-------------|
| `BehSeparatedness.lean` | 185 | The countermodel half of the *Determinism* theorem pair of `app:presheaf-dictionary`: `driftSec` cuts the rate-1 and rate-2 affine drift worlds down to sections over `[0, 1]`, `fzero_not_separated` refutes separatedness of `Beh F°` off their shared germ at `0`, and `separated_strictly_stronger` pairs that with `fzero_determined` — separatedness is strictly stronger than the validity of *Determined* on the frame. |
| `ClockFrame.lean` | 229 | The periodic clock frame: temporal order `D = ℚ`, world-state carrier the rational circle `W = ℚ ⧸ ℤ`, task relation the deterministic translation flow. All `TaskFrame` obligations discharged, with a reference world history. |
| `CoNotPriorU.lean` | 527 | The symmetric irrational arc valuation on the clock frame, the refutation of `Axiom.prior_U_gap` in that model, and the two independence statements. |
| `CoarsenedModels.lean` | 756 | The non-standard semantics the pasting-independence argument runs on: `CoarseModel`, `SameUnder`, `CTruthAt`; the three structural ports (`c_truth_congr_ext`, `cTruthAt_timeShift`, `c_stab_state_only`); the atomization transfer; the six naive `⊡` validities; and naive soundness `naive_cValid`. |
| `DenseRTimeSharpness.lean` | 409 | The `.Dense` rows of `Axiom.minFrameClass` characterized and its `prior_U_gap` row shown minimal: `not_validOn_density_of_isLeastPos` and `not_validOn_dense_indicator_of_isLeastPos` refute both `.Dense`-tagged axioms at frame level over any duration group with a least positive element, instantiated at `ℤ` to reach `.Base` and `.ZTime`, so `eq_base_of_lt_dense` gives `density_minFrameClass_sharp` / `dense_indicator_minFrameClass_sharp` and a four-way `cases fc` gives the exhaustive `density_validIn_iff` / `dense_indicator_validIn_iff`; `not_validOn_prior_U_gap_clock` reaches `.Base` and `.Dense` at once, so `base_or_dense_of_lt_rtime` gives `prior_U_gap_minFrameClass_sharp`. `sep_validOn_of_isLeastPos` proves the discreteness obstruction that confines any `Axiom.sep` refutation to a densely ordered duration group, and is then reused by `SepSharpness.lean` to prove `sep` valid at `.ZTime`. Three `example` shape pins make formula-transcription fidelity a compiler obligation. |
| `DeterminismUndefinable.lean` | 189 | The instantiation at `F°`/`F¹`: (T3) `determined_valid_on_non_deterministic`, (T4) `fzero_plusValidOn_iff_f1`, and `deterministic_not_plusDefinable`. |
| `DriftFrame.lean` | 261 | `F°`, the drift band `x ≤ u - w ≤ 2x` over `ℝ`, with all six `FrameOver` axioms (`limit` and `saturation` included) and `fzero_not_deterministic`. |
| `DriftHistories.lean` | 176 | `F°`'s world histories are strictly increasing bi-Lipschitz bijections of `ℝ` (`fzero_hits_future` is the crux, by IVT); (H1) `fzero_orderFlow` and (H2) `fzero_stateOccurs`, the latter by an explicit affine witness. |
| `ForwardDeterministicFrame.lean` | 468 | `F^N` — `W = ℕ`, `D = ℤ`, the absorbing predecessor map — with all six `FrameOver` obligations (*Saturation* via the new finite-**fibres** helper, since `ℕ` is infinite); `fn_forwardDeterministic`, `fn_not_deterministic`, the forward engine `states_eq_of_forwardDeterministic`, `fn_sentDet_stateLocal` (valid at every **state-local** instance, not only at sentence letters) and the separation `fn_separates`; plus `fn_refutes_sentDet_somePast`, which shows the *schematic* reading of that validity is false, and `fn_sentDet_bounds`, which records the two-sided bound as one object. |
| `LexIntWitness.lean` | 208 | The discrete, non-Archimedean carrier `ℤ ×ₗ ℤ`, the static frame over it as a member of `Mod (AxiomSet .ZTime)` outside `Sat .ZTime`, the semantic upper-bound engine `validOn_nextTop_of_mem_mod_discrete`, and the Discrete sandwich. |
| `LimitClosureCountermodel.lean` | 275 | The coarse model `eK` on `EF` (`π` the Boolean class, every sentence letter read as the `true` class): the `π`-image of its world histories is exactly `evFalse`, the eventually-false sequences (`hist_image_mem`, `exists_hist_of_evFalse`), which is closed under splicing (`eK_pasteClosed`) and not under limits; `blc_cRefuted` refutes the limit-closure formula at every history and time, and `blc_not_plusDerivable_base` concludes it is not a `.Base` theorem of TM⁺. |
| `LimitClosureFrame.lean` | 327 | `EF` — `W = Option (Bool × ℕ)`, `D = ℤ`: a hub `none` reaching every state, and class/budget pairs whose budget never increases and strictly drops on entering the `true` class — with all six `FrameOver` obligations (`eR_trans` and `eR_dense` give the task relation in closed form; *Saturation* via `sInter_nonempty_of_directed_of_finite_mem` and "every fibre or segment contains the hub or is finite"); `isWalk_state`, `walk_lt`, `histOfWalk`: the world histories of `EF` are exactly the bi-infinite `eR`-walks. |
| `LoopingDuration.lean` | 237 | The reusable content. A frame carrying a *looping duration* (a nonzero `π` whose task relation is the identity) has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every instance of `CO`. Proved for an arbitrary such frame. |
| `NaiveSystem.lean` | 143 | TM⁺ with the two pasting axioms withheld, as a predicate on the *existing* derivation trees (`NaiveOnly`, `NaiveDerivable`) rather than a second axiom inductive, plus its derived rules. |
| `OrderTransfer.lean` | 197 | The frame-independent layer: `OrderFlow` (H1), `StateOccurs` (H2), and the order-transfer lemmas — `future_image`, `past_image`, `between`, `between_past`, `state_image`. |
| `PastedCoarseModels.lean` | 275 | `CoarseModel.PasteClosed` — the splice of two world histories exists at the level of `π`-images — the purity congruences `c_truth_congr_from` / `c_truth_congr_upTo`, PS and US with their reflected forms (`c_paste`, `c_paste'`, `c_untl_paste`, `c_snce_paste`), and soundness of all of TM⁺ at `.Base` for paste-closed coarse models (`plus_pcValid_and_reflect_time`, `not_plusDerivable_of_pcRefuted`). |
| `PastingIndependence.lean` | 279 | One coarsened-state model over the deterministic clock on `ℤ`, coarsened by absolute value of the clock offset, refuting both pasting schemata: `pasteNotNaiveDerivable`, `untlPasteNotNaiveDerivable`, and hence `plusAxiomSetNonRedundant` — PS and US are not theorems of TM together with the naive `⊡`-set {SK, ST, S4, S5, MS, AS}. |
| `PlusIncompleteness.lean` | 88 | The assembly. `plus_incomplete_base`: the limit-closure formula is valid (`blc_plusValid`) and is not a `.Base` theorem of TM⁺ (`blc_not_plusDerivable_base`), so the current TM⁺ axiom set is incomplete at `.Base`; `not_plus_complete_base`: the hypothesis of `starConservative_of_plusComplete` at `.Base`, refuted. No claim about extensions of the axiom set, other frame classes, or conservativity of TM⋆ over TM⁺. |
| `RationalWitness.lean` | 206 | `rat_not_complete` — `ℚ` is not Dedekind-complete, written out because Mathlib carries no statement in this shape — and the static frame over `ℚ` as a member of `Mod (AxiomSet .RTime)` outside `Sat .RTime`, with the Dedekind sandwich. |
| `RealTranslationFrame.lean` | 196 | `realOrder`; `F¹`, the deterministic translation flow over `ℝ`, built through `ShiftSet` (the only route on which the world-set characterization elaborates); `f1_deterministic`, `f1_total_eq_orbit`, `f1_eq_of_states_eq`. |
| `SepSharpness.lean` | 439 | The `sep` row of `Axiom.minFrameClass` characterized, over the Hahn group `Lex (ℚ →₀ ℚ)`: the `DenselyOrdered` instance Mathlib does not supply, the single-support generators `sepGen` and `sepRegion`, the region of positive-index generators they span, and the three accumulation facts about it — it accumulates at `0`, has no gapped successors, and has no accumulation point above `0`, which is exactly both antecedent conjuncts holding at `0` while the consequent fails. That gives `not_validOn_sep_lexHahn`, hence `not_validIn_base_sep` and `not_validIn_dense_sep` at once, hence `sep_minFrameClass_sharp` through `base_or_dense_of_lt_rtime`. `sep_validIn_ztime` is positive and schematic, off `DenseRTimeSharpness.lean`'s `sep_validOn_of_isLeastPos`, so `sep_validIn_iff` reads `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc` rather than the `.Dense`-row shape, which would be false here. One `example` shape pin makes formula-transcription fidelity a compiler obligation. |
| `StabUndefinable.lean` | 241 | `stabNotDefinable`: no `Formula` is equivalent to `⊡Fp` over all task models, by a `TruthCorr` between the permissive frame over `ℤ` and the deterministic clock at family index `ℤ → ℕ`. |
| `StarDiscrimination.lean` | 189 | The positive half of the discrimination footnote: the affine drift histories `driftLinear` and the manuscript's own valuation `driftModel`, which makes `p` true exactly on `[3/2, ∞)`; `fzero_refutes_sentDet`, `f1_sentDet`, `sentDet_discriminates`, and `star_discriminates_where_plus_cannot` — one `StarFormula` separates `F°` from `F¹` where `cor:no-characterization` shows no `PlusFormula` set can. |
| `StateSetTruth.lean` | 236 | `satSet` and `plusTruthAt_iff_mem_satSet`: over an (H1)+(H2) frame, L⁺ truth depends only on the world state of evaluation. Plus `plusValidOn_iff_satSet_univ` and `determined_of_orderFlow`. |
| `StaticFrame.lean` | 323 | The static frame at an arbitrary duration group: every nonzero duration loops, so truth is time-invariant, and the `untl`/`snce` clauses collapse into a small constant-truth calculus (general, dense and discrete forms, plus `K⁺`/`K⁻` and `Axiom.z1`). Turns every later axiom check into a rewrite. |
| `TranslationProductCoarse.lean` | 136 | Coarse models on the translation product (`Semantics/Frames/TranslationProduct.lean`, a proof device, never an intended model): `liftK` lifts a coarse model with the coarsening forgetting the clock; `c_invariance` — coarse truth is preserved by the projection; `pasteClosed_liftK` / `pasteClosed_of_liftK` — paste-closure transfers in both directions; `c_refuted_lift` — a coarse refutation on `F` is a coarse refutation on the recurrence-free, Limit-for-free product in the same frame class. |
| `ZTimeSharpness.lean` | 433 | The `.ZTime` row of `Axiom.minFrameClass`, characterized rather than upper-bounded: `not_validOn_prior_UZ_dense` / `not_validOn_z1_dense` refute both `.ZTime`-tagged axioms at frame level over any densely ordered duration group; instantiating at ℚ and ℝ gives non-validity at `.Base`, `.Dense` and `.RTime`, and `eq_base_of_lt_ztime` covers everything strictly below `.ZTime`; `prior_UZ_validIn_iff_ztime` / `z1_validIn_iff_ztime` assemble `ValidIn fc φ ↔ fc = .ZTime`, with `not_derivable_base_*` the underivability corollaries. Two `example` shape pins make formula-transcription fidelity a compiler obligation. |
<!-- END GENERATED -->

## Key Results

- `co_not_derives_prior_U_gap` and its companion `co_not_derives_prior_U_gap_schema`
  (`CoNotPriorU.lean`) — the two independence statements, the second closing the context gap the
  first leaves open.
- `states_add_of_looping` and `truthAt_add_period` (`LoopingDuration.lean`) — history
  periodicity and truth periodicity from a looping duration alone.
- `clockFrame` (`ClockFrame.lean`) — the witness frame, with every structural axiom discharged.
- `static_time_invariant` and the `static_untl_iff*` family (`StaticFrame.lean`) — the
  constant-truth calculus both non-closure witnesses run on.
- `sat_rtime_ssubset_mod_axiomSet` (`RationalWitness.lean`) and
  `sat_ztime_ssubset_mod_axiomSet` (`LexIntWitness.lean`) — `Sat .RTime` and
  `Sat .ZTime` are strictly smaller than the model classes of their axiom sets, hence not
  Galois-closed.
- `deterministic_not_plusDefinable` (`DeterminismUndefinable.lean`) — no set of `PlusFormula`s
  defines the deterministic frames (`cor:no-characterization`), via the `F°`/`F¹`
  indistinguishable pair.
- `determined_valid_on_non_deterministic` (`DeterminismUndefinable.lean`) — `F°` validates
  *Determined* without being deterministic, refuting the converse of `determined_of_deterministic`
- `fzero_not_separated`, `separated_strictly_stronger` (`BehSeparatedness.lean`) — the presheaf-side
  sharpening of the line above: separatedness of `Beh F` is **strictly stronger** than the validity
  of *Determined* on `F`, with `F°` the witness for the failure of the converse. The clause the pair
  sharpens — `F.Deterministic ↔ Presheaf.Separated F` at a regular frame — is
  `Semantics/DeterministicBridge.lean`'s `deterministic_iff_separated`, and **its** converse does
  not fail; a biconditional has none to fail
  (`PlusLanguage/PlusDeterminism.lean`).
- `plusTruthAt_iff_mem_satSet` (`StateSetTruth.lean`) — the state-set bridge, proved once against
  (H1)+(H2) and instantiated twice; `[propext]` alone.
- `stabNotDefinable` (`StabUndefinable.lean`) — no `Formula` is equivalent to `⊡Fp` over all task
  models, by a `TruthCorr` between the permissive frame over `ℤ` and the deterministic clock at
  family index `ℤ → ℕ`; the two models realize the same atom profiles and differ only in which
  histories share a state.
- `naive_cValid` (`CoarsenedModels.lean`) — naive soundness: every theorem of TM⁺ with the two
  pasting axioms withheld is valid in every coarsened-state model. The TM schemata are handled by
  the same atomization route the standard semantics uses, because the coarsened `⊡` is still a
  state formula (`c_stab_state_only`).
- `pasteNotNaiveDerivable`, `untlPasteNotNaiveDerivable` (`PastingIndependence.lean`) — PS and US
  are not naively derivable, both refuted in one coarsened model over `ℤ` whose coarsening
  identifies the offsets `w₀` and `-w₀`.
- `not_plusDerivable_of_pcRefuted` (`PastedCoarseModels.lean`) — soundness of TM⁺ at Base for
  paste-closed coarsened-state models, in the shape a refutation consumes.
- `prior_UZ_validIn_iff_ztime`, `z1_validIn_iff_ztime` (`ZTimeSharpness.lean`) — `ValidIn fc φ
  ↔ fc = .ZTime` for each `.ZTime`-tagged axiom's atomic instance: valid at `.ZTime` and at no
  other frame class. Assembled by a four-way `cases fc` from `axiom_validIn_min` and the four
  non-validity results below.
- `prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp` (`ZTimeSharpness.lean`) — the weaker
  minimality half: the `.ZTime` tag of `Axiom.minFrameClass` is minimal for both its axioms, via
  the frame-level refutations `not_validOn_prior_UZ_dense` / `not_validOn_z1_dense` at an
  arbitrary densely ordered duration group and the order fact `eq_base_of_lt_ztime`. The
  `CoNotPriorU.lean` frame-versus-model obstruction does not apply, because a bare non-validity
  claim validates nothing.
- `not_validIn_dense_*`, `not_validIn_rtime_*` (`ZTimeSharpness.lean`) — the two classes the
  order fact cannot reach, refuted over `ztimeSharpOrder` and `realOrder`. Dedekind completeness
  buys the axioms nothing: what they need is discreteness.
- `sep_validIn_iff` (`SepSharpness.lean`) — `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc` for
  `Axiom.sep`'s atomic instance. The disjunctive right-hand side is not a stylistic choice: the
  `.Dense`-row form `↔ .RTime ≤ fc` would be false here, because `.RTime` is incomparable with
  `.ZTime` and `sep` is nonetheless `.ZTime`-valid.
- `sep_minFrameClass_sharp` (`SepSharpness.lean`) — the minimality half: `Axiom.sep`'s atomic
  instance is valid at no frame class strictly below `.RTime`, off the single frame-level
  refutation `not_validOn_sep_lexHahn` over the Hahn group `Lex (ℚ →₀ ℚ)` and the order fact
  `base_or_dense_of_lt_rtime`.
- `sep_validIn_ztime` (`SepSharpness.lean`) — the positive half, and the only *schematic* claim in
  either sharpness family: `Axiom.sep` is vacuously valid at `.ZTime` for every `φ`, because
  `IsZTime` supplies a successor order and hence a least positive duration, feeding
  `sep_validOn_of_isLeastPos`.
- `plus_incomplete_base`, `not_plus_complete_base` (`PlusIncompleteness.lean`) — the limit-closure
  formula is valid and not a Base theorem of TM⁺; the hypothesis of
  `starConservative_of_plusComplete` at Base, refuted. Halves: `blc_plusValid`
  (`PlusLanguage/PlusLimitClosure.lean`) and `blc_not_plusDerivable_base`
  (`LimitClosureCountermodel.lean`).

## Building a countermodel: what to reach for first

The default route to a native `Formula`/`TruthAt` countermodel is the translation frame together
with its ready-made realisation layer — not the L⁻ transfer, and not any of the bespoke frames
already in this directory. It is what both sharpness modules run on, and `ZTimeSharpness.lean`'s
entire import surface is `Semantics/Correspondence/DurationFrames.lean`,
`Metalogic/Soundness.lean` and `Semantics/Correspondence/RigidityReal.lean`: none of
`Metalogic/Conservativity/Z1Countermodel.lean`, `Semantics/LexCarrier.lean` or the L⁻ soundness
family is needed.

**The default route — three definitions and three bridges.**

- `translationFrame D` (`Semantics/Frames/Standard.lean`) — world states are the durations
  themselves, with `w ⇒_x u ↔ u = w + x` (`translationFrame_taskRel`, `@[simp]`).
  `translationFrame_isRegular` is a **global instance**, so the `FrameClass.Sat` side condition is
  `inferInstance` at `.Base`, `⟨inferInstance, inferInstance⟩` at `.Dense`, and a triple at
  `.RTime`.
- `translationHist D` (`Semantics/Correspondence/DurationFrames.lean`) — the identity reference
  history `t ↦ t`, total. This is *why* the route is the default: atoms are valued on world
  states, so a time-varying atom needs a history whose state varies with time, and the identity
  history is exactly that.
- `translationModel D A` — values **every** atom by membership in an arbitrary `A ⊆ ↑D`
  (`translationModel_atom`, `@[simp]`, by `Iff.rfl`).
- `translation_realizes`, `translation_realizes_allPast`, `translation_realizes_allFuture` — the
  atom-realisation bridges. Atom truth at `t` is `t ∈ A`; `Hp` at `u` is `∀ r < u, r ∈ A`; `Gp` at
  `u` is `∀ r, u < r → r ∈ A`. Each turns a temporal claim into an order claim about `A` in one
  rewrite.

The recipe is four steps: choose the set `A`; apply the validity hypothesis at
`h (translationModel D A) (translationHist D) 0`; rewrite with the realisation lemma for the
operator in play; derive the contradiction from order facts about `A`. Two mechanical notes that
cost time if unknown. Both refutations open with `haveI := noMaxOrder_of_duration D`, which is a
plain lemma and deliberately **not** an instance. And pulling
`Metalogic/DedekindNonCompactness.lean` into the import closure alongside
`Semantics/Correspondence/RigidityReal.lean` reintroduces an `Ambiguous term realOrder` error,
because the two declare `realOrder` in a namespace these modules both open;
`ZTimeSharpness.lean`'s import block records the constraint.

**The fallback route, and why it is the fallback.** Transferring a refutation out of the
neighbouring L⁻ language is landed and real — `not_minus_derivable_z1`
(`Metalogic/Conservativity/Z1Countermodel.lean`) over the `ℚ ×ₗ ℤ` carrier from
`Semantics/LexCarrier.lean`, with `minus_soundness_ztime_succ` from
`FormalSystem/MinusLanguage/Soundness.lean`. But anything crossing `MinusLanguage.tr` meets the
`tr_ne_untl` obstruction (`FormalSystem/MinusLanguage/Translation.lean`): `Formula.someFuture` is
a top-level `untl` and nothing in the range of `tr` is, so a `U`-shaped target cannot be reached
that way. The paragraph in `Metalogic/Conservativity.lean` documenting that obstruction is
accurate; it simply never arises on the default route, because nothing leaves the native
language.

**Two frames that look right and are not.** Both are attractive starting points on which an agent
will prove a true theorem about a different question.

- The **static frame** (`FrameOver.staticFrame`, `StaticFrame.lean`) has time-invariant truth, and
  time-invariant truth **validates** `Axiom.z1` outright — the landed `static_validates_z1`, which
  `LexIntWitness.lean` depends on. The trap is live precisely because `LexIntWitness.lean` makes
  its discrete non-Archimedean carrier look like the obvious place to start.
- The **clock frame** (`clockFrame`, `ClockFrame.lean`) is a dead end for **`z1` only**, and the
  asymmetry matters. Its period-1 truth (`clockFrame_looping`, `truthAt_add_period`,
  `truthAt_add_nsmul`, `clock_allPast_imp_allFuture`) makes `Gφ` time-independent over the
  Archimedean `ℚ`, so `FGφ → Gφ` holds there and `z1` cannot be refuted on it. It is **not** a
  dead end for `Axiom.prior_UZ`: the arc valuation `clockModel`, with `clock_atom_truth`, already
  in `CoNotPriorU.lean` refutes that axiom's atomic instance. What rules the clock frame out for
  `prior_UZ` is cost, not validity — it is pinned to `ℚ` and a quotient carrier, where the
  translation frame delivers both axioms from one generic lemma each at an arbitrary dense `D`.

**Three specifics worth not re-deriving.**

1. *What refutes the `.ZTime` axioms is non-discreteness, not failure of the Archimedean
   property.* `not_validOn_prior_UZ_dense` and `not_validOn_z1_dense` are stated at
   `(D : TemporalOrder) [DenselyOrdered (D : Type)]`, so each is a single lemma covering **every**
   densely ordered duration group. That genericity is what converts one construction into several
   frame classes: instantiating at `ztimeSharpOrder` and at `realOrder` reaches `.Base`, `.Dense`
   and `.RTime` from the same proof, and `eq_base_of_lt_ztime` covers everything strictly below
   `.ZTime`. Dedekind completeness buys these axioms nothing. Discrete *non-Archimedean* carriers
   are a different story, told by `LexIntWitness.lean`.
2. *Pin the shape, because a schematic `∀ φ` non-validity claim can be outright false.*
   `Axiom.prior_UZ ⊥` has an unsatisfiable antecedent and **is** `.Base`-valid, which falsifies
   the `∀ φ` reading of the `.Base` results and of both biconditionals. Every statement is
   therefore made at `Formula.atom p`, and anonymous shape pins of the form
   `example (φ : Formula) : Axiom (...) := Axiom.<ctor> φ` are standard practice: the whole result
   is vacuous if the transcribed formula drifts from the constructor, and a pin makes
   transcription fidelity a compiler obligation. Two are ready to copy in `ZTimeSharpness.lean`'s
   *Shape pins* section and three in `DenseRTimeSharpness.lean`'s. The `prior_UZ` pin also settles
   a genuine reading trap: `ProofSystem/Axioms.lean`'s prose renders the axiom `F(φ) → U(φ, ¬φ)`,
   argument-reversed relative to the constructor's `Formula.untl φ.neg φ`, because the prefix
   `U(e, g)` rendering is deliberately event-first while the constructor and the infix `φ U ψ` are
   guard-first.
3. *`by decide` fails on `FrameClass` `<`.* Only `≤` carries a `DecidableRel` instance; `<` comes
   from `PartialOrder`'s default definition and is not reached by instance search. The idiom in
   the tree is `absurd h.le (by decide)`, and `DenseRTimeSharpness.lean`'s *Order facts* section
   is where this is written down.

**When one infinitesimal level is not enough.** `SepSharpness.lean` is the one countermodel here
whose carrier is not a familiar duration group, and the reason is worth keeping. `Axiom.sep` needs
a region that accumulates at one point and is dense in itself, yet has no ambient accumulation
point above that one — impossible in a separable flow, which is exactly the hypothesis Reynolds'
positive argument for `sep` runs on. A two-level lexicographic carrier such as `ℚ ×ₗ ℚ` does not
deliver it: with one infinitesimal scale the natural region is already dense in the ambient order,
every one of its points is a two-sided accumulation point, and there is nothing left to refute.
Neither does any finite number of levels. What works is a direct sum over a *dense, unbounded*
index order — the Hahn group `Lex (ℚ →₀ ℚ)`, where the region of single-support generators spans
infinitely many mutually infinitely-separated archimedean scales. Two elaboration traps come with
it, both costly to rediscover. Helper lemmas must be stated at the bare carrier abbreviation
(`LexHahn`) and never at `(sepSharpOrder : Type)`: at `TemporalOrder.carrier` the application
`ofLex r j` fails to elaborate, and reducibility bridges the two only at the frame-level theorem,
where no such application appears. And Mathlib's `Finsupp.Lex.single_lt_iff` and
`Finsupp.Lex.single_strictAnti` look directly applicable but are specialised away from a general
value type in the pinned snapshot, so they do not apply at value type `ℚ`; `sepGen_lt_sepGen` is
the three-line replacement, proved from `Finsupp.Lex.lt_iff`.

## When frame-level refutation is obstructed, and when it is not

`CoNotPriorU.lean`'s *Why this is a statement about a model, not a frame* section records a real
obstruction, and it is narrow. Frame-validity quantifies over **all** valuations, so on a densely
ordered flow rich enough to realize an arbitrary set of times, frame-validity of `CO` already
forces gap-freeness — and gap-freeness forces Prior-U valid too. No frame-level countermodel can
therefore exist for `CO` against `Axiom.prior_U_gap`, on any frame whatever, and that result has
to be stated over a **fixed** `TaskModel`. This matches Reynolds' own printed caveat (1992,
p.169), quoted in that same docstring: the gap axioms enforce only a *definably* Dedekind-complete
flow.

**The criterion.** The obstruction bites only when a statement must *simultaneously* **validate**
something on a valuation-rich flow while refuting something else. It is the validation half that
the all-valuations quantifier defeats. A bare non-validity claim validates nothing, and is
therefore unobstructed. `ZTimeSharpness.lean`'s *The frame-versus-model obstruction does not bite
here* section — and `DenseRTimeSharpness.lean`'s section of the same name — are where this was
first written down; the criterion stated here is what those two instances have in common.

**The operational consequence: choose the statement form before starting the proof.** When the
criterion says "unobstructed", the available form is the frame-level `¬ F.ValidOn φ`, and the
frame-class form `¬ ValidIn fc φ` built on it. That is **strictly stronger** than the
model-relativized form the obstruction forces, in which the *validated* side is asserted only of
the chosen `TaskModel` and never of the frame. It is the form every `.ZTime`, `.Dense` and
`.RTime` non-validity result in this directory actually takes: `not_validOn_prior_UZ_dense`,
`not_validOn_z1_dense`, `not_validOn_density_of_isLeastPos`,
`not_validOn_dense_indicator_of_isLeastPos`, `not_validOn_prior_U_gap_clock`. Deciding this up
front is cheap; discovering it mid-proof, after a model has been fixed and the surrounding lemmas
shaped around it, is not.

**The failure mode this prevents.** Read narrowly, the `CoNotPriorU.lean` docstring looks like a
general warning against frame-level refutation in this semantics, and over-generalizing it into a
prohibition costs real effort to undo. It is not a prohibition. It is a statement about one shape
of claim — refute-while-validating — and establishing that a new refutation is not of that shape
is a one-line check against the criterion above, not a research question.

## Dependencies

- **Imports from**: `FormalSystem.Semantics` (including
  `Semantics.Correspondence.{Galois, Indicator}` for the two sandwich statements),
  `FormalSystem.Metalogic.Soundness`, `FormalSystem.ProofSystem`, Mathlib's `ℚ ⧸ ℤ`
- **Imported by**: `FormalSystem.Metalogic.Independence` (the sibling aggregator)

## Related Documentation

- [Metalogic README](../README.md)
- [Theorems README](../../Theorems/README.md) — `DedekindDerived.coDerived`, the converse
  direction

---

**Last verified**: 2026-09-25

---

*Last verified: 2026-09-25*
