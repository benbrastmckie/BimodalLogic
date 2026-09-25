# Independence — underivability results

Underivability results, established by exhibiting a model of the assumptions in which the
target formula fails.

Nine results are carried here:

1. The paper's `CO` principle does **not** derive Reynolds' `Axiom.prior_U_gap` over the dense
   base. The converse direction — Reynolds' triple *does* derive `CO` — is
   `FormalSystem.Theorems.DedekindDerived.coDerived`, so the two settle the relationship in both
   directions.
2. `Sat .Dedekind ⊊ Mod (AxiomSet .Dedekind)`, witnessed by the static frame over `ℚ`.
3. `Sat .Discrete ⊊ Mod (AxiomSet .Discrete)`, witnessed by the static frame over `ℤ ×ₗ ℤ`.

4. The stability modal `⊡` is **not L-definable**: no `Formula` is equivalent to `⊡Fp` across
   all task models (`StabUndefinable.lean`). This is what makes L⁺ a genuinely larger language
   rather than notation for something L can already say.
5. The two **pasting schemata are not derivable** from the naive `⊡`-set {SK, ST, S4, S5, MS, AS}
   together with TM (`PastingIndependence.lean`), so TM⁺'s axiom set is non-redundant.
6. **Store and recall discriminate where nothing without them can** (`StarDiscrimination.lean`).
   `sent:det` — the manuscript's `↑¹\Future↑²↓¹(⊡↓²¬φ ∨ ⊡↓²φ)` — is valid over the deterministic
   translation frame `F¹` and refuted over the drift frame `F°`, while result 4's companion
   `deterministic_not_plusDefinable` shows that no set of `PlusFormula`s separates them at all.
   This is the live-text footnote following `app:deterministic-future`.
7. **`sent:det` defines only *forward* determinism** (`ForwardDeterministicFrame.lean`). The
   frame `F^N` (`W = ℕ`, `D = ℤ`, the absorbing predecessor map) is forward-deterministic and
   **not** `Deterministic`, and `sent:det` is valid over it at every sentence letter. Replacing
   `\Future` by `always` closes the gap: `Det-pm` does define the deterministic frames
   (`StarLanguage/StarDeterminism.lean`'s `deterministic_starDefinable`).
8. **The current TM⁺ axiom set is incomplete at Base** (`PlusIncompleteness.lean`). The
   limit-closure formula `(⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))` — the Burgess/Thomason
   branch-extension pattern transposed to the stability modal — is valid over every task frame
   (`PlusLanguage/PlusLimitClosure.lean`, by Zorn plus the Extension Theorem) and is
   not a Base theorem of TM⁺. Completeness of any *extension* of the axiom set is open at every
   class, and nothing is claimed at Dense, ZTime or RTime.
9. **The `.ZTime` row of `Axiom.minFrameClass` is characterized, not merely upper-bounded**
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
   any densely ordered duration group, the reals included. The Base, Dense and RTime rows of
   `Axiom.minFrameClass` itself remain upper-bound-only.

Results 2 and 3 are the two halves of the finding that the frame-class *narrowings* are not
Galois-closed, in contrast with the paper's bare classes — which are closed, by
`Semantics/Correspondence/Indicator.lean`'s `galoisClosed_sat_dense` and `galoisClosed_isDiscrete`.

Result 5 is the one that leaves the standard semantics. PS and US are valid on **every** task
frame (`PlusLanguage/PlusPasting.lean`), because the splice of two world histories through a common
state is again a world history; so no ordinary task model can witness their underivability. The
witness is a *coarsened-state* model (`CoarsenedModels.lean`), which interprets `⊡` over a
quotient of the world states and thereby removes the common state a splice would need. Everything
else about the argument is the usual four steps.

Result 8 uses the same non-standard semantics with one hypothesis restored. A coarsened model is
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

Results 6 and 7 leave the language rather than the semantics: they are stated over **L⋆**
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
| `ClockFrame.lean` | 229 | The periodic clock frame: temporal order `D = ℚ`, world-state carrier the rational circle `W = ℚ ⧸ ℤ`, task relation the deterministic translation flow. All `TaskFrame` obligations discharged, with a reference world history. |
| `CoNotPriorU.lean` | 527 | The symmetric irrational arc valuation on the clock frame, the refutation of `Axiom.prior_U_gap` in that model, and the two independence statements. |
| `CoarsenedModels.lean` | 756 | The non-standard semantics the pasting-independence argument runs on: `CoarseModel`, `SameUnder`, `CTruthAt`; the three structural ports (`c_truth_congr_ext`, `cTruthAt_timeShift`, `c_stab_state_only`); the atomization transfer; the six naive `⊡` validities; and naive soundness `naive_cValid`. |
| `DeterminismUndefinable.lean` | 189 | The instantiation at `F°`/`F¹`: (T3) `determined_valid_on_non_deterministic`, (T4) `fzero_plusValidOn_iff_f1`, and `deterministic_not_plusDefinable`. |
| `DriftFrame.lean` | 261 | `F°`, the drift band `x ≤ u - w ≤ 2x` over `ℝ`, with all six `FrameOver` axioms (`limit` and `saturation` included) and `fzero_not_deterministic`. |
| `DriftHistories.lean` | 176 | `F°`'s world histories are strictly increasing bi-Lipschitz bijections of `ℝ` (`fzero_hits_future` is the crux, by IVT); (H1) `fzero_orderFlow` and (H2) `fzero_stateOccurs`, the latter by an explicit affine witness. |
| `ForwardDeterministicFrame.lean` | 468 | `F^N` — `W = ℕ`, `D = ℤ`, the absorbing predecessor map — with all six `FrameOver` obligations (*Saturation* via the new finite-**fibres** helper, since `ℕ` is infinite); `fn_forwardDeterministic`, `fn_not_deterministic`, the forward engine `states_eq_of_forwardDeterministic`, `fn_sentDet_stateLocal` (valid at every **state-local** instance, not only at sentence letters) and the separation `fn_separates`; plus `fn_refutes_sentDet_somePast`, which shows the *schematic* reading of that validity is false, and `fn_sentDet_bounds`, which records the two-sided bound as one object. |
| `LexIntWitness.lean` | 208 | The discrete, non-Archimedean carrier `ℤ ×ₗ ℤ`, the static frame over it as a member of `Mod (AxiomSet .Discrete)` outside `Sat .Discrete`, the semantic upper-bound engine `validOn_nextTop_of_mem_mod_discrete`, and the Discrete sandwich. |
| `LimitClosureCountermodel.lean` | 275 | The coarse model `eK` on `EF` (`π` the Boolean class, every sentence letter read as the `true` class): the `π`-image of its world histories is exactly `evFalse`, the eventually-false sequences (`hist_image_mem`, `exists_hist_of_evFalse`), which is closed under splicing (`eK_pasteClosed`) and not under limits; `blc_cRefuted` refutes the limit-closure formula at every history and time, and `blc_not_plusDerivable_base` concludes it is not a `.Base` theorem of TM⁺. |
| `LimitClosureFrame.lean` | 327 | `EF` — `W = Option (Bool × ℕ)`, `D = ℤ`: a hub `none` reaching every state, and class/budget pairs whose budget never increases and strictly drops on entering the `true` class — with all six `FrameOver` obligations (`eR_trans` and `eR_dense` give the task relation in closed form; *Saturation* via `sInter_nonempty_of_directed_of_finite_mem` and "every fibre or segment contains the hub or is finite"); `isWalk_state`, `walk_lt`, `histOfWalk`: the world histories of `EF` are exactly the bi-infinite `eR`-walks. |
| `LoopingDuration.lean` | 237 | The reusable content. A frame carrying a *looping duration* (a nonzero `π` whose task relation is the identity) has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every instance of `CO`. Proved for an arbitrary such frame. |
| `NaiveSystem.lean` | 143 | TM⁺ with the two pasting axioms withheld, as a predicate on the *existing* derivation trees (`NaiveOnly`, `NaiveDerivable`) rather than a second axiom inductive, plus its derived rules. |
| `OrderTransfer.lean` | 197 | The frame-independent layer: `OrderFlow` (H1), `StateOccurs` (H2), and the order-transfer lemmas — `future_image`, `past_image`, `between`, `between_past`, `state_image`. |
| `PastedCoarseModels.lean` | 275 | `CoarseModel.PasteClosed` — the splice of two world histories exists at the level of `π`-images — the purity congruences `c_truth_congr_from` / `c_truth_congr_upTo`, PS and US with their reflected forms (`c_paste`, `c_paste'`, `c_untl_paste`, `c_snce_paste`), and soundness of all of TM⁺ at `.Base` for paste-closed coarse models (`plus_pcValid_and_reflect_time`, `not_plusDerivable_of_pcRefuted`). |
| `PastingIndependence.lean` | 279 | ` — refuting both pasting schemata: `pasteNotNaiveDerivable`, `untlPasteNotNaiveDerivable`, `plusAxiomSetNonRedundant`. |
| `PlusIncompleteness.lean` | 88 | The assembly. `plus_incomplete_base`: the limit-closure formula is valid (`blc_plusValid`) and is not a `.Base` theorem of TM⁺ (`blc_not_plusDerivable_base`), so the current TM⁺ axiom set is incomplete at `.Base`; `not_plus_complete_base`: the hypothesis of `starConservative_of_plusComplete` at `.Base`, refuted. No claim about extensions of the axiom set, other frame classes, or conservativity of TM⋆ over TM⁺. |
| `RationalWitness.lean` | 206 | `rat_not_complete` — `ℚ` is not Dedekind-complete, written out because Mathlib carries no statement in this shape — and the static frame over `ℚ` as a member of `Mod (AxiomSet .Dedekind)` outside `Sat .Dedekind`, with the Dedekind sandwich. |
| `RealTranslationFrame.lean` | 196 | `realOrder`; `F¹`, the deterministic translation flow over `ℝ`, built through `ShiftSet` (the only route on which the world-set characterization elaborates); `f1_deterministic`, `f1_total_eq_orbit`, `f1_eq_of_states_eq`. |
| `StabUndefinable.lean` | 241 | `stabNotDefinable`: no `Formula` is equivalent to `⊡Fp` over all task models, by a `TruthCorr` between the permissive frame over `ℤ` and the deterministic clock at family index `ℤ → ℕ`. |
| `StarDiscrimination.lean` | 189 | = [3/2, ∞)`), `fzero_refutes_sentDet`, `f1_sentDet`, and `star_discriminates_where_plus_cannot` — one `StarFormula` separates `F°` from `F¹` where `cor:no-characterization` shows no `PlusFormula` set can. |
| `StateSetTruth.lean` | 236 | `satSet` and `plusTruthAt_iff_mem_satSet`: over an (H1)+(H2) frame, L⁺ truth depends only on the world state of evaluation. Plus `plusValidOn_iff_satSet_univ` and `determined_of_orderFlow`. |
| `StaticFrame.lean` | 323 | The static frame at an arbitrary duration group: every nonzero duration loops, so truth is time-invariant, and the `untl`/`snce` clauses collapse into a small constant-truth calculus (general, dense and discrete forms, plus `K⁺`/`K⁻` and `Axiom.z1`). Turns every later axiom check into a rewrite. |
| `TranslationProductCoarse.lean` | 136 | Coarse models on the translation product (`Semantics/Frames/TranslationProduct.lean`, a proof device, never an intended model): `liftK` lifts a coarse model with the coarsening forgetting the clock; `c_invariance` — coarse truth is preserved by the projection; `pasteClosed_liftK` / `pasteClosed_of_liftK` — paste-closure transfers in both directions; `c_refuted_lift` — a coarse refutation on `F` is a coarse refutation on the recurrence-free, Limit-for-free product in the same frame class. |
| `ZTimeSharpness.lean` | 423 | The `.ZTime` row of `Axiom.minFrameClass`, characterized rather than upper-bounded: `not_validOn_prior_UZ_dense` / `not_validOn_z1_dense` refute both `.ZTime`-tagged axioms at frame level over any densely ordered duration group; instantiating at ℚ and ℝ gives non-validity at `.Base`, `.Dense` and `.RTime`, and `eq_base_of_lt_ztime` covers everything strictly below `.ZTime`; `prior_UZ_validIn_iff_ztime` / `z1_validIn_iff_ztime` assemble `ValidIn fc φ ↔ fc = .ZTime`, with `not_derivable_base_*` the underivability corollaries. Two `example` shape pins make formula-transcription fidelity a compiler obligation. |
<!-- END GENERATED -->

## Key Results

- `co_not_derives_prior_U` and its companion (`CoNotPriorU.lean`) — the independence
  statements.
- `states_add_of_looping` and `truthAt_add_period` (`LoopingDuration.lean`) — history
  periodicity and truth periodicity from a looping duration alone.
- `clockFrame` (`ClockFrame.lean`) — the witness frame, with every structural axiom discharged.
- `static_time_invariant` and the `static_untl_iff*` family (`StaticFrame.lean`) — the
  constant-truth calculus both non-closure witnesses run on.
- `sat_dedekind_ssubset_mod_axiomSet` (`RationalWitness.lean`) and
  `sat_discrete_ssubset_mod_axiomSet` (`LexIntWitness.lean`) — `Sat .Dedekind` and
  `Sat .Discrete` are strictly smaller than the model classes of their axiom sets, hence not
  Galois-closed.
- `deterministic_not_plusDefinable` (`DeterminismUndefinable.lean`) — no set of `PlusFormula`s
  defines the deterministic frames (`cor:no-characterization`), via the `F°`/`F¹`
  indistinguishable pair.
- `determined_valid_on_non_deterministic` (`DeterminismUndefinable.lean`) — `F°` validates
  *Determined* without being deterministic, refuting the converse of `determined_of_deterministic`
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
- `plus_incomplete_base`, `not_plus_complete_base` (`PlusIncompleteness.lean`) — the limit-closure
  formula is valid and not a Base theorem of TM⁺; the hypothesis of
  `starConservative_of_plusComplete` at Base, refuted. Halves: `blc_plusValid`
  (`PlusLanguage/PlusLimitClosure.lean`) and `blc_not_plusDerivable_base`
  (`LimitClosureCountermodel.lean`).

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

**Last verified**: 2026-09-24

---

*Last verified: 2026-09-24*
