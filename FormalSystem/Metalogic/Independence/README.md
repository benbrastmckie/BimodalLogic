# Independence — underivability results

Underivability results, established by exhibiting a model of the assumptions in which the
target formula fails.

Five results are carried here:

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
   (`Semantics/StarLanguage/StarDeterminism.lean`'s `deterministic_starDefinable`).

Results 2 and 3 are the two halves of the finding that the frame-class *narrowings* are not
Galois-closed, in contrast with the paper's bare classes — which are closed, by
`Semantics/Correspondence/Indicator.lean`'s `galoisClosed_sat_dense` and `galoisClosed_isDiscrete`.

Result 5 is the one that leaves the standard semantics. PS and US are valid on **every** task
frame (`Semantics/PlusLanguage/PlusPasting.lean`), because the splice of two total histories through a common
state is again a total history; so no ordinary task model can witness their underivability. The
witness is a *coarsened-state* model (`CoarsenedModels.lean`), which interprets `⊡` over a
quotient of the world states and thereby removes the common state a splice would need. Everything
else about the argument is the usual four steps.

Results 6 and 7 leave the language rather than the semantics: they are stated over **L⋆**
(`FormalSystem/Syntax/StarLanguage/`), L⁺ plus the manuscript's time store/recall operators. The
paper-label correspondence table for that appendix — every `\label` mapped to a Lean name or to
an explicit exclusion — lives in `FormalSystem/Syntax/StarLanguage/README.md`.

Every result here follows the same four steps: build a concrete frame satisfying every
structural axiom of the semantics; prove a truth-invariance lemma for it (a symmetry or
periodicity constraining *every* formula uniformly, by induction on `Formula` with the history
universally quantified **inside** the induction, so the `□` case can apply the inductive
hypothesis); derive validity of the assumptions; and exhibit a valuation refuting the target.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Independence -->
| File | Lines | Description |
|------|-------|-------------|
| `ClockFrame.lean` | 236 | The periodic clock frame: temporal order `D = ℚ`, world-state carrier the rational circle `W = ℚ ⧸ ℤ`, task relation the deterministic translation flow. All `TaskFrame` obligations discharged, with a reference total history. |
| `CoNotPriorU.lean` | 552 | The symmetric irrational arc valuation on the clock frame, the refutation of `Axiom.prior_U_gap` in that model, and the two independence statements. |
| `CoarsenedModels.lean` | 737 | The non-standard semantics the pasting-independence argument runs on: `CoarseModel`, `SameUnder`, `CTruthAt`; the three structural ports (`c_truth_congr_ext`, `cTruthAt_timeShift`, `c_stab_state_only`); the atomization transfer; the six naive `⊡` validities; and naive soundness `naive_cValid`. |
| `DeterminismUndefinable.lean` | 189 | The instantiation at `F°`/`F¹`: (T3) `determined_valid_on_non_deterministic`, (T4) `fzero_plusValidOn_iff_f1`, and `deterministic_not_plusDefinable`. |
| `DriftFrame.lean` | 254 | `F°`, the drift band `x ≤ u - w ≤ 2x` over `ℝ`, with all six `FrameOver` axioms (`limit` and `saturation` included) and `fzero_not_deterministic`. |
| `DriftHistories.lean` | 178 | `F°`'s total histories are strictly increasing bi-Lipschitz bijections of `ℝ` (`fzero_hits_future` is the crux, by IVT); (H1) `fzero_orderFlow` and (H2) `fzero_stateOccurs`, the latter by an explicit affine witness. |
| `ForwardDeterministicFrame.lean` | 474 | `F^N` — `W = ℕ`, `D = ℤ`, the absorbing predecessor map — with all six `FrameOver` obligations (*Saturation* via the new finite-**fibres** helper, since `ℕ` is infinite); `fn_forwardDeterministic`, `fn_not_deterministic`, the forward engine `states_eq_of_forwardDeterministic`, `fn_sentDet_stateLocal` (valid at every **state-local** instance, not only at sentence letters) and the separation `fn_separates`; plus `fn_refutes_sentDet_somePast`, which shows the *schematic* reading of that validity is false, and `fn_sentDet_bounds`, which records the two-sided bound as one object. |
| `LexIntWitness.lean` | 206 | The discrete, non-Archimedean carrier `ℤ ×ₗ ℤ`, the static frame over it as a member of `Mod (AxiomSet .Discrete)` outside `Sat .Discrete`, the semantic upper-bound engine `validOn_nextTop_of_mem_mod_discrete`, and the Discrete sandwich. |
| `LoopingDuration.lean` | 235 | The reusable content. A frame carrying a *looping duration* (a nonzero `π` whose task relation is the identity) has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every instance of `CO`. Proved for an arbitrary such frame. |
| `NaiveSystem.lean` | 141 | TM⁺ with the two pasting axioms withheld, as a predicate on the *existing* derivation trees (`NaiveOnly`, `NaiveDerivable`) rather than a second axiom inductive, plus its derived rules. |
| `OrderTransfer.lean` | 197 | The frame-independent layer: `OrderFlow` (H1), `StateOccurs` (H2), and the order-transfer lemmas — `future_image`, `past_image`, `between`, `between_past`, `state_image`. |
| `PastingIndependence.lean` | 286 | ` — refuting both pasting schemata: `pasteNotNaiveDerivable`, `untlPasteNotNaiveDerivable`, `plusAxiomSetNonRedundant`. |
| `RationalWitness.lean` | 206 | `rat_not_complete` — `ℚ` is not Dedekind-complete, written out because Mathlib carries no statement in this shape — and the static frame over `ℚ` as a member of `Mod (AxiomSet .Dedekind)` outside `Sat .Dedekind`, with the Dedekind sandwich. |
| `RealTranslationFrame.lean` | 189 | `realOrder`; `F¹`, the deterministic translation flow over `ℝ`, built through `ShiftSet` (the only route on which the world-set characterization elaborates); `f1_deterministic`, `f1_total_eq_orbit`, `f1_eq_of_states_eq`. |
| `StabUndefinable.lean` | 249 | `stabNotDefinable`: no `Formula` is equivalent to `⊡Fp` over all task models, by a `TruthCorr` between the permissive frame over `ℤ` and the deterministic clock at family index `ℤ → ℕ`. |
| `StarDiscrimination.lean` | 194 | = [3/2, ∞)`), `fzero_refutes_sentDet`, `f1_sentDet`, and `star_discriminates_where_plus_cannot` — one `StarFormula` separates `F°` from `F¹` where `cor:no-characterization` shows no `PlusFormula` set can. |
| `StateSetTruth.lean` | 240 | `satSet` and `plusTruthAt_iff_mem_satSet`: over an (H1)+(H2) frame, L⁺ truth depends only on the world state of evaluation. Plus `plusValidOn_iff_satSet_univ` and `determined_of_orderFlow`. |
| `StaticFrame.lean` | 323 | The static frame at an arbitrary duration group: every nonzero duration loops, so truth is time-invariant, and the `untl`/`snce` clauses collapse into a small constant-truth calculus (general, dense and discrete forms, plus `K⁺`/`K⁻` and `Axiom.z1`). Turns every later axiom check into a rewrite. |
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
  (`Semantics/PlusLanguage/PlusDeterminism.lean`).
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

**Last verified**: 2026-09-08

---

*Last verified: 2026-09-08*
