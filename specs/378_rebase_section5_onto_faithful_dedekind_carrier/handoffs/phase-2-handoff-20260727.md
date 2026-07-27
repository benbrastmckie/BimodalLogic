# Phase 2 handoff — the `HasDedekindSUP` / Since mirror landed live

**Session**: `sess_1785150996_3c6f1f_378` | **Date**: 2026-07-27 | **Phase 2 status**: COMPLETED

## Immediate next action

Dispatch **Phase 3** — the missing `VVecEA2` combinators (`VVecEA2.conjEverywhere`,
`VVecEA2.concatPin`), landing in `Kamp/VecEACombinators.lean`. Phase 3 is a pure combinator
addition at a type layer that already exists; the plan states explicitly that it **cannot fail
informatively** and must not be read as evidence either way on the migration GO/NO-GO. The
migration canary is **Phase 4**, not Phase 3.

Re-confirm absence of both combinators by search before writing them, as Phase 3's first task
requires.

## Kill criterion: DID NOT FIRE

`kminusFormula` has a TL-definable spelling with a proved correctness lemma and needs **no
hypothesis absent from PDF p.8**. `Formula.snce` is interpreted natively by `TemporalTruth`
(`Table.lean:198`) exactly as `Formula.untl` is, so `K⁻(P) := ¬P ∧ ¬(⊤ S ¬P)` is TL-definable on
precisely the same terms as `K⁺(P) := ¬P ∧ ¬(⊤ U ¬P)`. The proof of `kplus_formula_correct`
(`Lemma53.lean:162`) transferred with **no step adapted** beyond reversing the order comparisons.

No mathematics was invented. Phases 4-9 do **not** need re-scoping to the INF/Until direction on
this ground.

## Measured results (actual, not asserted)

| Gate | After Phase 1 | After Phase 2 | Verdict |
|---|---|---|---|
| `lake build` exit | 0 | **0** | pass |
| Jobs | 1884 | **1885** | +1, as specified |
| Live modules from `FormalSystem.lean` | 270 | **271** | +1, as specified |
| Tactic-position sorries in `Kamp/` | 4 dead / 0 live | **4 dead / 0 live** | unchanged |
| Tactic-position sorries in the new module | — | **0** | pass |
| Real `axiom` declarations in tree | 0 | **0** | unchanged |

Liveness was decided by a transitive `import` walk from `FormalSystem.lean`, never by
`lake build <target>`. `lake build BoneyardArchive` was never run or cited.
`Kamp.Lemma53FaithfulPast` is reachable via the new `NfMultiAnchorBridge.lean` import edge.

Sorry census is tactic-position via `.claude/scripts/lean-sorry-census.sh`, never `grep -c`. The
four dead sorries are unchanged and all under `Kamp/Boneyard/`: `EndpointNegation.lean:164`,
`FOToVEA.lean:122`, `EANegationVBracketBackward.lean:452`, `:611`.

Note for the record: `lake build` reports one pre-existing sorry warning at
`Metalogic/WeakCanonical/Transfer.lean:1225`, outside `Kamp/` and untouched by this phase.

### Axiom check — all 11 new declarations

Every axiom set is a subset of `{propext, Classical.choice, Quot.sound}`; **no `sorryAx`
anywhere**.

- Exactly `[propext, Classical.choice, Quot.sound]`: `kminus_formula_correct`, `kminusPred_eval`,
  `orderedPointsExist_combine_right`, `orderedPointsExist_combine_kminus`
- Strict subsets (stronger, not weaker): `orderedPointsExist_widen_right` →
  `[propext, Quot.sound]`; `HasDedekindSUP.last_occ_tp`, `HasAttainedSUP.toHasDefinableSUP`,
  `hasDefinableSUP_excludes_kminus`, `prior_makes_kminus_disjunct_unreachable` → `[propext]`;
  `kminusFormula` and `kminusPred` → no axioms

## What the past carrier EXCLUDES (mandatory non-vacuity statement)

Recorded as code in the module, not only as prose:

1. **`HasDedekindSUP` excludes** chains on which a last occurrence of `P` in `(z₀,z₁)` has a
   supremum that is none of the mirrored eq (5.2) shapes: `r₀ = z₁` (equivalently `K⁻(P)(z₁)`), or
   `r₀ ∈ (z₀,z₁)` with `¬P` on `(r₀,z₁)` and `P(r₀) ∨ K⁻(P)(r₀)`. Bare Dedekind completeness gives
   the supremum's *existence*; `HasDedekindSUP` additionally asserts TL-definability in one of
   those shapes. The strengthening chain mirrors the INF side exactly:
   `Rabinovich's Dedekind completeness < HasDedekindSUP < HasDefinableSUP < HasAttainedSUP`.
2. **The `K⁻` boundary disjunct is provably dead on every Prior structure.**
   `prior_makes_kminus_disjunct_unreachable` proves it, routed through `prior_hasAttainedSUP`
   (`PriorINF.lean:275`) → `HasAttainedSUP.toHasDefinableSUP` → `hasDefinableSUP_excludes_kminus`.
   This is the exact mirror of `prior_makes_disjunct2_unreachable`.
3. **Is the past mirror observable by any current consumer? NO.** Same reason as the INF
   direction: the live goal chain is Prior structures, where SUP attainment holds outright from
   the SZ axiom, so no live consumer can distinguish `HasAttainedSUP` from `HasDedekindSUP`.
   Observability arrives only with a genuinely non-attained Dedekind-complete frame class, which
   this tree does not construct. `hasDedekindINF_admits_kplus_shape` (`DedekindINF.lean:264`) is
   **not** cited against this: its proof is `Or.inl h_kplus` and its own docstring admits it
   exhibits no structure.

## What was genuinely absent, and is now landed

`grep` over the whole tree returned ZERO hits for `kminusFormula`, `kminus_formula_correct` and
`kminusPred` before this phase. `kminus` itself appeared only at `PriorINF.lean:98`/`:102` plus
three `DedekindINF.lean` references — i.e. the past carrier could be *stated* but none of its
content could be *used*. Eleven declarations now close that gap:

`kminusFormula`, `kminus_formula_correct`, `kminusPred`, `kminusPred_eval`,
`HasDedekindSUP.last_occ_tp`, `orderedPointsExist_combine_right`,
`orderedPointsExist_combine_kminus`, `orderedPointsExist_widen_right`,
`HasAttainedSUP.toHasDefinableSUP`, `hasDefinableSUP_excludes_kminus`,
`prior_makes_kminus_disjunct_unreachable`.

## Deviations

Two, both strict supersets of a listed task, both recorded inline on the plan's checklist items
and summarized under "Phase 2 deviations". No listed task was skipped, narrowed, or substituted.

1. `orderedPointsExist_combine_right` added — the right-end mirror of
   `orderedPointsExist_combine` (`EANegationFix/OnBuilder.lean:95`), which only ever prepends at
   the left end because the landed stack peels point types off the front of the list. The past
   direction pins the *last* point type, so the mirror had to be built.
2. `HasAttainedSUP.toHasDefinableSUP` and `hasDefinableSUP_excludes_kminus` added — the task list
   routes the exclusion "through `prior_hasAttainedSUP` and the SUP-side exclusion", but no
   SUP-side exclusion existed. Both mirrors of the INF-side originals had to be proved first.

## Constraints observed

- No file deleted; no attained-carrier declaration deleted or weakened. `EANegationFix/` is
  untouched — the faithful past declarations are parallel additions.
- `EANegation.lean:1090`/`:1249` not touched (they do not exist; the file is shorter than that).
- Rabinovich cited by **PDF page only** throughout; the corrupt companion `.md` was never read.
  Source correspondence for every declaration is PDF p.8, mirrored, with the mirroring stated
  explicitly in the module docstring rather than left implicit.
- No task-number reference in any file outside `specs/**` (verified by grep on both touched
  `.lean` files).
- `lake build BoneyardArchive` was never run or cited.

## Files

- `FormalSystem/Metalogic/WeakCanonical/Kamp/Lemma53FaithfulPast.lean` — new, live (created)
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` — import edge + NOTE
