# Phase 1 handoff — faithful three-disjunct Lemma 5.3 landed live

**Session**: `sess_1785150996_3c6f1f_378` | **Date**: 2026-07-27 | **Phase 1 status**: COMPLETED

## Immediate next action

Dispatch **Phase 2** — the `HasDedekindSUP` / Since mirror
(`Kamp/Lemma53FaithfulPast.lean`). Phase 2 is genuinely absent work, **not** a transcription:
`kminusFormula` and `kminus_formula_correct` do not exist anywhere in the live tree, so nothing
in the probe covers it. Phase 2 carries its own written kill criterion (if `kminusFormula`
cannot be given a TL-definable spelling with a proved correctness lemma without a hypothesis
absent from PDF p.8, stop and re-scope Phases 4-9 to the INF/Until direction).

Do **not** treat "Phase 7-scope" as finished because Phase 1 closed. Phase 1 covered the
INF/Until direction only.

## Measured results (actual, not asserted)

| Gate | Baseline (re-measured this dispatch) | After Phase 1 | Verdict |
|---|---|---|---|
| `lake build` exit | 0 | **0** | pass |
| Jobs | 1883 | **1884** | +1, as specified |
| Live modules from `FormalSystem.lean` | 269 | **270** | +1, as specified |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** | unchanged |
| `axiom` declarations in tree | 0 | **0** | unchanged |
| `AggregateOffDiagK1.lean` | LIVE, builds | **LIVE, builds** | no regression |

Liveness was decided by transitive `import` walk from `FormalSystem.lean`, never by
`lake build <target>`. `Kamp.Lemma53Faithful` is reachable via the new
`NfMultiAnchorBridge.lean` import edge.

Sorry census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. The
four dead sorries are all under `Kamp/Boneyard/`: `EndpointNegation.lean:164`,
`FOToVEA.lean:122`, `EANegationVBracketBackward.lean:452`, `:611`.

### Axiom check — all 13 new declarations

Every declaration's axiom set is a subset of `{propext, Classical.choice, Quot.sound}`; **no
`sorryAx` anywhere**.

- Exactly `[propext, Classical.choice, Quot.sound]`: `kplusPred_eval`,
  `VVecEA2.prependAllVec_holds`, `orderedPointsExist_combine_kplus`, `kplusLeftBlock_holds`,
  `negChainOnFaithful_iff`, `lemma53Faithful`, `lemma53Faithful_perPoint_is_VACUOUS`
- Strict subsets (stronger, not weaker): `orderedPointsExist_widen_left` and
  `negChainOnFaithful` → `[propext, Quot.sound]`; `VVecEA2.prependAllVec` →
  `[propext, Quot.sound]`; `prior_makes_disjunct2_unreachable` → `[propext]`;
  `kplusPred` and `kplusLeftBlock` → no axioms

## What the landed carrier EXCLUDES (mandatory non-vacuity statement)

Recorded as code in the module, not only as prose:

1. **`lemma53Faithful` is the HOISTED shape** `∃ O, ∀ M atomMap z₀ z₁` — `O` is a function of
   `P` alone. `lemma53Faithful_perPoint_is_VACUOUS` compiles the per-point ordering
   (`∃ O` inside `∀ z₀ z₁`) with **no carrier hypothesis at all**, which is the control proving
   the two are different statements. It landed unconditionally, as required.
2. **`HasDedekindINF` excludes** chains on which a first occurrence of `P` in `(z₀,z₁)` has an
   infimum that is none of eq (5.2)'s printed shapes: `r₀ = z₀` (equivalently `K⁺(P)(z₀)`), or
   `r₀ ∈ (z₀,z₁)` with `P(r₀) ∨ K⁺(P)(r₀)`. The strengthening chain is unchanged:
   `Rabinovich's Dedekind completeness < HasDedekindINF < HasDefinableINF < HasAttainedINF`.
   The carrier is still strictly stronger than the paper's hypothesis, only much less so.
3. **Disjunct (2) is provably dead on every Prior structure.**
   `prior_makes_disjunct2_unreachable` proves it (routed through `prior_hasAttainedINF` →
   `toHasDefinableINF` → `hasDefinableINF_excludes_kplus`). So the re-base is contentful
   mathematics **whose content is not yet reachable from any live consumer** — the live chain is
   Prior structures, where attainment holds outright. Observability arrives only with a
   genuinely non-attained Dedekind-complete frame class, which this tree does not build.
   `hasDedekindINF_admits_kplus_shape` (`DedekindINF.lean:264`) must **not** be cited against
   this: its proof is `Or.inl h_kplus` and its own docstring admits it exhibits no structure.

## Fidelity

No mathematics was invented. All eleven substantive declarations plus the two non-vacuity
declarations were lifted verbatim from the machine-checked probe
`reports/01_lemma53-faithful-gate-probe.lean`; **no proof body required adaptation**. Every
declaration carries a PDF p.8 source correspondence. All twelve in-docstring line references
were re-verified by `grep` against the current tree and were already current.

## Deviations

Two, both strict supersets of a listed task, both recorded inline in the plan file under
"Phase 1 deviations". No listed task was skipped, narrowed, or substituted.

1. `Section5Correspondence.lean` table fix widened from the 3 named rows to all 6 drifted rows
   (report section 0 lists the other three: `BoundedFix.lean:449→:455`, `:768→:774`,
   `NegFix.lean:424→:449`).
2. One extra in-tree comment corrected: the `DedekindINF` NOTE in `NfMultiAnchorBridge.lean`
   said the Lemma 5.3 re-base is "DEFERRED, not done", which Phase 1 falsifies. Amended
   minimally; nothing deleted.

## Constraints observed

- No file deleted; no attained-carrier declaration deleted or weakened. `EANegationFix/` is
  untouched — the faithful versions are parallel additions.
- `EANegation.lean:1090`/`:1249` not touched (they do not exist; the file is 694 lines). The
  model-independent Prop 4.2 backward direction was not approached.
- No task-number reference in any file outside `specs/**` (verified by grep on all four
  touched `.lean` files).
- `lake build BoneyardArchive` was never run or cited.

## Files

- `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53Faithful.lean` — new, live (created)
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — import edge + NOTE;
  `DedekindINF` NOTE amended
- `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53.lean` — docstring correction only
- `FormalSystem/Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean` — table line-number
  corrections only
