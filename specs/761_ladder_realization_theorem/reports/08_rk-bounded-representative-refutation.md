# Research Report: Task #761

**Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
**Started**: 2026-11-04T16:15:00Z
**Completed**: 2026-11-04T16:35:00Z
**Effort**: ~0.4 hours
**Dependencies**: 760, 775, 805, 806, 819, 820 — all six discharged
**Sources/Inputs**:
- Library source: `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (`CK`, `clipIdx`, `kappa`, `repsCnt`, `rkStepB`, `RKb`, `RK`, `rk_iff`, `relK`, the six `K`-indexed conditions, `ParamsOk` and its four conjuncts), `LadderRealize.lean` (the module docstring's statement of the missing lemma; `Real`), `RunLayer.lean` (`Count`, `Drift`, `Rlad`), `LadderAgree.lean` (`spliceObj`, `spliceCnt`, `spliceObj_of_lt`, `exists_spliced_ladderPath`, `pinCompat_of_ladderPath`, `pinnedRegions` and the Phase 11.2 cascade facts, `kappa_eq_components`, `kappa_eq_of_shift`, `eq_or_both_ge_of_min_eq`, `clipIdx_regime_of_eq`)
- Prior round: `.orchestrator-handoff.json` (dispatch 26), `summaries/07_tight-chain-gate-regated-graph-summary.md`, `plans/09_tight-chain-gate-regated-graph.md` (Phase 11.8 blocker record, Phase 11.9 gate)
- Compiled probes authored and run in this session (scratchpad, not landed): three `decide`-checked refutation witnesses against the live library
- Exhaustive scans authored and run in this session: 900-tuple parameter sweep of the representative bound
- lean-lsp `lean_local_search` (one query; `index: unavailable`, see Evidence Tier)
- Literature: none consulted. The question researched is internal to this library's own definitions and no corpus source bears on it; the literature-extraction protocol does not apply to this round.
**Artifacts**:
- `specs/761_ladder_realization_theorem/reports/08_rk-bounded-representative-refutation.md`
**Standards**: report-format.md, subagent-return.md, status-markers.md, artifact-management.md, tasks.md

## Executive Summary

- **`rk_of_count_drift` — the single lemma the prior round named as unblocking three of the six
  conditions of `Real` — is FALSE as recorded.** Not hard, not open: refuted. Three independent
  `decide`-checked witnesses were compiled against the live library in this session.
- The obstruction is **the size of `repsCnt`, not the non-existence of representatives**. A
  900-tuple exhaustive sweep found **no class pair that is unliftable in a wider window**, so the
  repair is a definitional widening of `repsCnt` and NOT a new hypothesis on the lemma.
- The current bound `Tc + Tn + P + B + 2` is wrong in **two independent directions**, each with
  its own compiled witness: it carries one `B` where the saturated-gap regime needs `2B` (witness
  at `P = 0`), and one `P` where the `Drift`-plus-residue coupling needs `2P`.
- **Adding `ParamsOk` does not repair it.** A second witness sits at `ParamsOk`-shaped numerics
  (`Tc = 4`, `Tn = 6`, `P = 5`, `B = 2`), and `ParamsOk` places no upper bound on `P` relative to
  `Tc`, `Tn` or `B` at all — (K1) is a divisibility condition and (K2)/(K3)'s bounds never mention
  `P`.
- The widening is **monotone and safe**: `RK` occurs only positively (`relK` → `certChain`,
  `certBiInfK`, `certFwdK`, `certBwdK`; no negative occurrence anywhere in `FormalSystem/`,
  `Tests/` or `specs/evidence/`), and `repsCnt`/`RK`/`rk_iff` have no dependent outside
  `CounterQuotient.lean`. Recommended replacement: `Tc + Tn + 3*P + 2*B + 5`.
- Secondary: Phase 11.8's restatement should move to the **interface level** — the two facts
  `spliced_at_region` exposes at the comparison position — rather than to a new pointwise walk
  description; and the 480-line tight-chain probe is confirmed **tracked but unwired**, so it will
  rot silently.

## Context & Scope

This round researched the open questions the prior implement dispatch (seq 26) left, in the order
the handoff ranks them:

1. Phase 12.1's three Reasoned Exclusions, which the handoff says **one** lemma unblocks:
   `rk_of_count_drift`. The `LadderRealize.lean` module docstring states the lemma in full and
   records the decisive sub-question as open in terms: "Whether `repsCnt`'s own bound
   `Tc + Tn + P + B + 2` suffices for that construction is itself open and is not assumed anywhere
   here." That sub-question is this round's primary target.
2. Phase 11.8's `[BLOCKED]` record — its Goal and its third task contradict each other and the
   shape the third task names is refutable.
3. Phase 11.9's recorded statement defects and the unwired probe.

Constraints honoured: no library file was modified; no `sorry`, axiom, vacuous definition or
weakened Challenge statement was introduced anywhere; the probes authored here live in the
session scratchpad and are NOT landed under `specs/evidence/**` (landing them is an implement-phase
act against a listed `Files to modify`, not a research one).

### Evidence Tier

`lean-lsp` is registered and reachable, but `lean_local_search` reported `index: unavailable` on
its one query, so its hits are **source-text** hits only and an empty result from it would NOT be
proof of absence. Every absence claim in this report is therefore backed by a `grep` sweep over
`FormalSystem/`, `Tests/` and `specs/evidence/`, not by an LSP negative. Every positive claim is
backed either by a compiled `decide` (the probes) or by an exhaustive enumeration whose script is
named in the Appendix.

## Findings

### Finding 1: `rk_of_count_drift` is refuted at `repsCnt`'s current bound [COMPILED]

The lemma, as `LadderRealize.lean` records it: given `Count px py c n c'` and `Drift n n'`,
exhibit `x, y ∈ repsCnt Tc Tn P B` with `kappa x = kappa (c, n)`, `kappa y = kappa (c', n')`,
`Count px py x.1 x.2 y.1` and `Drift x.2 y.2`. By `rk_iff` this is exactly
`RK Tc Tn P B px py (kappa (c, n)) (kappa (c', n'))`.

Three witnesses, each compiled standalone against the live library via `lake env lean` with zero
errors and zero warnings (full probe sources in the Appendix):

| Witness | `(Tc,Tn,P,B)` | `repsCnt` bound | The step | Status |
|---------|---------------|-----------------|----------|--------|
| A | `(1,2,2,2)` | 9 | `Count false false 9 5 0`, `Drift 5 4` | `¬ RK … (kappa (9,5)) (kappa (0,4))` compiled |
| B | `(4,6,5,2)` | 19 | `Count true true 20 11 19`, `Drift 11 12` | `¬ RK … (kappa (20,11)) (kappa (19,12))` compiled |
| C | `(0,0,0,3)` | 5 | `Count false false 5 2 0`, `Drift 2 3` | `¬ RK … (kappa (5,2)) (kappa (0,3))` compiled |

Witness A, worked through, is the whole mechanism: `kappa 1 2 2 2 (9,5) = (1,0,2,2,0)` and
`kappa 1 2 2 2 (0,4) = (0,0,2,1,4)`. A representative `x` of the first class needs
`x.1 % 3 = 0`, `x.1 ≥ 1`, `x.2 % 3 = 2`, `x.2 ≥ 2` and — the gap coordinate being `0` —
`x.1 - x.2 ≥ 2`. A representative `y` of the second needs `y.1 = 0` and `y.2 % 3 = 1`,
`y.2 ≥ 2`. `Drift x.2 y.2` then forces `(x.2, y.2) ∈ {(5,4), (8,7), …}`, and the least admissible
`x.1` is `9` — exactly one above the bound `Tc + Tn + P + B + 2 = 9`.

### Finding 2: the bound is wrong in two independent directions

Witness C has `P = 0`, so no residue coupling is in play at all, and it still fails. Its mechanism
is the **saturated-gap** one: a class pair whose gap coordinates are `0` and `2B` forces
`x.1 ≥ x.2 + B` with `y.2 ≥ B` and `Drift x.2 y.2`, hence `x.1 ≥ 2B - 1`, while the bound offers
only `B + 2`. Witnesses A and B add the **residue** direction on top of it: `Drift` ties `x.2` to a
value congruent to `n'` mod `P + 1`, which can cost a further `P` beyond the `P` the `n`-coordinate
already costs.

An exhaustive sweep over the 900 parameter tuples with `Tc < 5`, `Tn < 6`, `P < 6`, `B < 5` (every
`Count`/`Drift` step with `c, n, c', n' ≤ 3(Tc+Tn+P+B)+10`, deduplicated to class pairs):

| Representative bound | Failing tuples (of 900) |
|---|---|
| `Tc + Tn + P + B + 2` (current) | **496** |
| `Tc + Tn + 2*P + 2*B + 3` | 0 |
| `Tc + Tn + 3*P + 2*B + 2` | 0 |
| `Tc + Tn + 3*P + 2*B + 5` | 0 |
| `2*(Tc + Tn + P + B) + 2` | 0 |

The current bound fails on **more than half** the grid. This is the typical case, not an edge case.

### Finding 3: every class pair IS liftable in a wider window

Across the whole sweep, **zero** class pairs were unliftable in a window of 160 (`unliftable=0` on
every tuple measured). The missing lemma is therefore TRUE with a large enough representative set,
and the repair is a bound fix rather than a hypothesis, a weakening, or a new obligation. A
construction supporting this, with the bound it discharges, is in the Appendix; its analytic bound
is `Tc + Tn + 3*P + 2*B + 4` on the largest coordinate, i.e. `Tc + Tn + 3*P + 2*B + 5` as a
`Finset.range` argument.

### Finding 4: `ParamsOk` is not the repair

Witness B sits at numerics that satisfy every numeric conjunct of `ParamsOk` for an object with
`Fintype.card (ProdState Q φ) = 1`, `tIdle pend = 0` and `dBack φ = dFwd φ = 0`:
(K3) needs `2 * tShort + tIdle + 2 ≤ Tc` (`4 ≤ 4`) and `Tc + 2 * ell0 ≤ Tn + 1` (`6 ≤ 7`);
(K4) needs `2 * dBack + 1 ≤ B`, `2 * dFwd + 1 ≤ B` and `2 ≤ B` (`1 ≤ 2`, `1 ≤ 2`, `2 ≤ 2`).

More decisively, and independently of whether any object realizes exactly `(4,6,5,2)` as its
parameter outputs: **`ParamsOk` constrains `P` only through (K1), which is a divisibility
condition into `P + 1`, and neither (K2) nor (K3) mentions `P` at all.** So `ParamsOk` admits `P`
arbitrarily large relative to `Tc`, `Tn` and `B`, which is precisely the direction the refutation
exploits. No numeric consequence of `ParamsOk` can close the gap.

### Finding 5: the widening is monotone and has no dependents to break

Measured by `grep` over `FormalSystem/`, `Tests/` and `specs/evidence/`:

- `repsCnt` appears in exactly two proof-term positions, both inside `CounterQuotient.lean`
  (`rkStepB`, `rk_iff`); every other occurrence is prose in `LadderRealize.lean`'s docstring.
- `RK`, `RKb`, `rkStepB`, `rk_iff`, `rkStepB_iff` and `decidableRK` have **no** occurrence outside
  `CounterQuotient.lean`.
- `relK` occurs in `certChain` (`LadderRealize.lean:136`), `certBiInfK`, `certFwdK` and `certBwdK`
  — all **positively**, under `∃ y ∈ R` or `∀ i < m, rel (f i) (f (i+1))`.
- There is **no** negative occurrence of `RK` or `relK` anywhere: the sweep for `¬ RK`, `¬ relK`,
  `not_RK`, `not_relK` and their parenthesized forms returns nothing.

Consequences: widening `repsCnt` enlarges `RK`, hence `relK`, hence weakens `certBiInfK`,
`certFwdK`, `certBwdK` and `certChain` monotonically. The two landed conditions of `Real`
(`real_certLocK`, `real_certBoxK`) mention no relation and are untouched. `Dmax` can only grow —
which is a real semantic change and is flagged under Risks, not waved away.

### Finding 6: Phase 11.8's restatement target

The plan's blocker record is correct as diagnosed and the mechanism checks out against the landed
source: `spliceCnt`'s `if a ≤ v + cntAt g v` branch raises the pin at `a`'s region start by exactly
`l` while an earlier region start is left alone (`spliceObj_of_lt`, `LadderAgree.lean:1040`), and
`pinCompat_of_ladderPath` (`LadderAgree.lean:1192`) makes pairwise pin compatibility NECESSARY for
any ladder path. The deliverable `exists_spliced_ladderPath_of_idle_past` is still absent from the
library — its one occurrence in `LadderAgree.lean:1374` is a docstring sentence saying so.

What the single consumer actually reads is narrower than the blocked statement. `spliced_at_region`
delivers two facts at one position: `objAt g' v = objAt g v` and `cntAt g' v = cntAt g v + l`, for
`v ≤ a` inside `a`'s region. Those two facts, not the pointwise identity of the walk, are what the
agreement consumes. So the restatement that survives the refutation is an **interface-level
existential**: some ladder path `g'` agreeing with `g` at the comparison position in object state
and carrying `cntAt g v + l` there — with no claim that `g'` is `spliceObj g a l`.

That shape is left open rather than refuted by the tight chain, and the cascade has a coherent
mechanism for it: insert idle positions into idle runs strictly **below** the comparison position's
region start, which on a `ℤ` axis shifts the past downward while leaving the walk at and above that
start pointwise fixed. Pushing an earlier region start down by `d` grows `|s - v|` by `d` and so
relaxes the inequality the splice violated; the displacement then propagates to the next pin down,
which is the doubling recurrence `cascadeDemand` already encodes, and it terminates because
`pinnedRegions_subset_Ico` confines the constraining pins to `Set.Ico p a` when the anchor `p` is
idle — which is exactly the regime hypothesis. Phase 11.2's four landed facts are the right base
for it.

### Finding 7: the tight-chain probe is tracked but unwired [MEASURED]

`specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean` is 480 lines, is
tracked by git (`git ls-files --error-unmatch` succeeds), and does **not** appear in
`scripts/check-evidence-probes.sh` (`grep -c` returns 0). It is therefore outside the gate's
`WIRED` array and will rot without notice. The gate's own `check_probe` requires both presence and
tracking, so the file is in the one state the gate was built to catch and is not catching: tracked,
compiling, and unmeasured.

## Decisions

- **D1 — The primary research target was the open sub-question, not the lemma's proof.** The
  `LadderRealize.lean` docstring names "whether `repsCnt`'s own bound suffices" as the open hinge;
  settling it decides whether the next round proves a lemma or revises a definition. It is settled
  negatively, which is a stronger and cheaper result than a partial proof attempt would have been.
- **D2 — The witnesses were compiled, not argued.** Each of the three is a `decide` against the
  library's own `RK` and `kappa`, so the refutation is machine-checked rather than a reading of the
  definitions. Witness B required `maxHeartbeats`/`maxRecDepth` to be raised (the bound-19
  enumeration is `19^4`-shaped); that is a probe-authoring note, not a library change.
- **D3 — No probe was landed under `specs/evidence/**` and no library file was touched.** Landing
  an evidence probe is an implement act against a phase's listed `Files to modify`. The probe
  sources are reproduced in full in the Appendix so the next dispatch can land them verbatim.
- **D4 — The recommended replacement bound is the analytically safe one, not the empirically
  tightest.** `Tc + Tn + 2*P + 2*B + 3` passes the whole 900-tuple grid, but the construction in
  the Appendix only discharges `Tc + Tn + 3*P + 2*B + 5`. A bound a proof can actually close is
  worth more than two saved `P`s, and by Finding 5 a larger `repsCnt` costs nothing semantically.
- **D5 — Phase 11.8's restatement is recommended at the interface level, not as a second walk
  description.** Recommended, not decided: the choice of what interface Phase 15 consumes is the
  plan's to make, and the blocker record already says "one interface serves both regimes" is what
  the refutation denies.

## Recommendations

Prioritized; all are `/revise` inputs, since every one of them changes a recorded statement or a
definition rather than executing a recorded task.

1. **Widen `repsCnt` to `Finset.range (Tc + Tn + 3*P + 2*B + 5)` squared, then state and prove
   `rk_of_count_drift` against the widened set.** Highest value: it unblocks `certBiInfK`,
   `certFwdK` and `certBwdK` of `Real` — three of the six conditions — and nothing else in the
   library depends on `repsCnt`'s value (Finding 5). The construction and its case analysis are in
   the Appendix; the landed `kappa_eq_components`, `eq_or_both_ge_of_min_eq` and
   `kappa_eq_of_shift` (instantiated downward, at the reduced pair) are the pieces it cites, and no
   new helper about `clipIdx` beyond `clipIdx_lt` is needed.
2. **Land the three refutation witnesses as a wired evidence probe in the same revision.** They
   are the compiled reason the bound changed, and the pattern this library already uses
   (`ladder-unconstrained-parameter-refutation.lean` is the compiled reason `ParamsOk` exists) is
   exactly this. Wire it into `scripts/check-evidence-probes.sh`'s `WIRED` array in the same
   commit, and name witness C explicitly as the `P = 0` half so a later reader cannot conclude the
   defect was only about residues.
3. **Correct `LadderRealize.lean`'s module docstring.** Its sentence "Whether `repsCnt`'s own
   bound `Tc + Tn + P + B + 2` suffices for that construction is itself open" is now false: it does
   not suffice, and the answer is compiled. The docstring's independent-reduction counterexample
   (`c = 100, n = 101, B = 3, Tc = Tn = 1, P = 0`) stays — it is about a different mechanism and is
   still correct.
4. **Do NOT add `ParamsOk` to `rk_of_count_drift`.** Finding 4 is the reason, and it should be
   recorded as the reason, so a later round does not re-propose it: `ParamsOk` bounds `P` only by
   divisibility and never from above.
5. **Restate Phase 11.8's conclusion at the interface level** (Finding 6), and decide in the same
   revision what Phase 15 consumes. If the restated existential is to be attempted, state the
   cascade over Phase 11.2's four landed facts and keep the insertion strictly below the comparison
   position's region start, so `objAt g' v = objAt g v` survives by construction.
6. **Repair Phase 11.9's recorded statements and wire its probe** (Finding 7). The handoff's own
   list applies unchanged: `0 < m`, the lifting form rather than the register-specific one, and the
   pin set unbounded above. The wiring is the urgent half — 480 tracked, compiling, unmeasured
   lines.
7. **Leave the pre-existing C16 `unusedArguments` finding alone** until a revision puts
   `LadderChain.lean` in a phase's territory.
   [CARRIED-UNVERIFIED: `specs/761_ladder_realization_theorem/.orchestrator-handoff.json`,
   `blockers[3]` — not re-measured this round; `scripts/check-module-invariants.sh` was not run.]

## Risks & Mitigations

- **Risk**: widening `repsCnt` enlarges `Dmax`, and `certStabK`/`certBoxK` are equalities that are
  not stable under enlarging the candidate set (`CounterQuotient.lean`'s own "What this module does
  NOT hold" says so).
  **Mitigation**: the growth is in `certAdmK`'s *relational* conjuncts only, and the two
  non-union-stable conditions' fibres never mention `RK`. But Finding 3 of the presentation-decision
  record — that the realizable set is certified — must be **re-read against the widened set** rather
  than assumed stable. Name this explicitly in the revision so it is checked rather than inherited.
- **Risk**: a larger `repsCnt` makes every `decide` over `RK` quadratically more expensive, and
  witness B already needed raised limits at bound 19.
  **Mitigation**: no landed theorem decides `RK` at a concrete large parameter tuple, and the
  refutation probes should keep their small tuples (A and C are cheap). Keep `decide`-based probes
  at bound ≤ 10 and prove the general lemma by construction, never by enumeration.
- **Risk**: the recommended bound is justified by a 900-tuple sweep plus an analytic construction,
  not by a compiled proof. The sweep's step range is finite (`3(Tc+Tn+P+B)+10`), so it is evidence,
  not proof.
  **Mitigation**: the construction in the Appendix is parameter-generic and is what should be
  proved; if its case analysis does not close, the phase goes `[BLOCKED]` with the goal state
  recorded rather than the bound being tuned empirically until a probe passes.
- **Risk**: Finding 6's interface-level restatement might itself be refutable — nothing proved that
  a ladder path through the same object state with countdown `+ l` exists in the tight idle-past
  regime.
  **Mitigation**: say so in the revision. The claim established here is only that the refutation
  which kills the `spliceObj`-shaped conclusion leaves the interface-level one open; the cascade is
  a mechanism, not a proof, and a one-theorem probe on the chain Phase 11.9 already declares is the
  cheap way to test it before a phase is sized around it.

## Tactic Survey Results

A tactic survey in the `lean_multi_attempt`/`lean_hammer_premise` sense was not the shape of this
round's work: the question was whether a recorded statement is true, and the answer came from
`decide` on a closed proposition plus exhaustive enumeration, not from proof search against an open
goal. What was measured:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `Count false false 9 5 0`, `Drift 5 4` | `decide` | success | default |
| `¬ RK 1 2 2 2 false false (kappa (9,5)) (kappa (0,4))` | `decide` | success | `maxRecDepth 100000` |
| `kappa 1 2 2 2 (9,5) = (1,0,2,2,0)` (as `Fin` tuple) | `decide` | success | `maxRecDepth 100000` |
| `¬ RK 4 6 5 2 true true (kappa (20,11)) (kappa (19,12))` | `decide` | fail, then success | fails at `maxHeartbeats 200000`; succeeds at `maxRecDepth 4000000`, `maxHeartbeats 4000000` |
| `¬ RK 0 0 0 3 false false (kappa (5,2)) (kappa (0,3))` | `decide` | success | `maxRecDepth 400000` |

Note for the implementing round: `decide` on `RK` is `M^4`-shaped in `repsCnt`'s bound `M`, so the
heartbeat ceiling is the practical limit on how large a tuple a probe may name.

## Context Extension Recommendations

- **Topic**: refuting a recorded lemma by `decide` against a library's own decidable predicate.
- **Gap**: `context/project/lean4/patterns/` has `dependency-tracing.md` and the MCP guides, but
  nothing on the pattern this round used — when a recorded statement quantifies over a bounded
  `Finset` of representatives, the statement is a closed decidable proposition at any concrete
  parameter tuple, so `decide` refutes it outright and no proof search is needed. The two
  practical constraints are the `maxRecDepth`/`maxHeartbeats` ceilings and the `M^4` growth.
- **Recommendation**: a short `context/project/lean4/patterns/decide-refutation-of-bounded-claims.md`
  recording the pattern, the two ceilings, and the rule that a `decide` refutation at concrete
  parameters refutes the universally-quantified statement but says nothing about a repaired one.

## Appendix

### A. The construction the recommended bound discharges

Write `L = P + 1` and `T* = max Tn (Tc + L + B)`. Given `Count px py c n c'` and `Drift n n'`:

- **`n`-side, one common shift.** Let `m = min n n'`. If `m ≤ T*` take `s = 0`; else
  `s = (m - T*) / L`. Set `b = n - s*L` and `b' = n' - s*L`. Residues mod `L` are preserved; the
  difference `b' - b = n' - n` is preserved, so `Drift b b'` holds; and either `s = 0` (nothing
  moved) or `min b b' ≥ T*`, which saturates `min · Tn` and `min · B` alike. Bound:
  `max b b' ≤ T* + L + 1`.
- **`a`-side, three sub-cases on the gap coordinate.** If `|n - c| < B` the clip is exact, so take
  `a = c - s*L` with the same `s` (the gap is preserved verbatim); `T* ≥ Tc + L + B` is what keeps
  `a ≥ Tc + 1` here. If `n - c ≥ B`, take `a` the least value `≥ Tc + 1` congruent to `c` mod `L`,
  which is `≤ Tc + L`, and `b - a ≥ B` follows from `b > T* ≥ Tc + L + B`. If `c - n ≥ B`, take `a`
  the least value `≥ max (Tc + 1) (b + B)` congruent to `c` mod `L`, which is `≤ T* + 2L + B + 1`.
  This third sub-case is the one that drives the bound and the one all three witnesses live in or
  next to.
- **`a'`-side, by the `Count` case.** `py = false`: `a' = 0`, forced and consistent since `c' = 0`
  (and when `px = true` the hypothesis gives `c = 0`, which forces `s = 0` and `a = 0`).
  `py = true, px = true`: `a' = a - 1`, which is why the `a` choices above target `Tc + 1` rather
  than `Tc`. `py = true, px = false`: `a' = b`, which adds `min b Tc = min n Tc` to `b`'s
  constraints — satisfied because `T* ≥ Tc`.
- **Bound.** The largest coordinate is `≤ T* + 2L + B + 1 ≤ Tc + Tn + 3P + 2B + 4`, so
  `Finset.range (Tc + Tn + 3*P + 2*B + 5)` suffices.

Landed lemmas this cites: `kappa_eq_components` and `eq_or_both_ge_of_min_eq`
(`LadderAgree.lean:853`, `:866`) to read a class equality coordinate by coordinate;
`kappa_eq_of_shift` (`LadderAgree.lean:2435`) instantiated at the *reduced* pair, which is the
down-shift form; `clipIdx_lt` and `clipIdx_regime_of_eq` for the gap sub-cases.

### B. Probe sources, as run

Witness A and the class computation (`lake env lean`, exit 0, no diagnostics):

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient
set_option maxRecDepth 100000
open FormalSystem.Metalogic.Decidability.RaySummary

theorem step_count : Count false false 9 5 0 := by decide
theorem step_drift : Drift 5 4 := by decide
theorem not_rk_of_count_drift :
    ¬ RK 1 2 2 2 false false (kappa 1 2 2 2 (9, 5)) (kappa 1 2 2 2 (0, 4)) := by decide
```

Witness B, at `ParamsOk`-shaped numerics (same preamble, plus
`set_option maxRecDepth 4000000` and `set_option maxHeartbeats 4000000`):

```lean
theorem step_count : Count true true 20 11 19 := by decide
theorem step_drift : Drift 11 12 := by decide
theorem not_rk_paramsok_shaped :
    ¬ RK 4 6 5 2 true true (kappa 4 6 5 2 (20, 11)) (kappa 4 6 5 2 (19, 12)) := by decide
```

Witness C, the `P = 0` half (same preamble, `set_option maxRecDepth 400000`):

```lean
theorem step_count : Count false false 5 2 0 := by decide
theorem step_drift : Drift 2 3 := by decide
theorem not_rk_at_P_zero :
    ¬ RK 0 0 0 3 false false (kappa 0 0 0 3 (5, 2)) (kappa 0 0 0 3 (0, 3)) := by decide
```

### C. Enumeration method

The sweep re-implements `clipIdx`, `kappa`, `Count` and `Drift` exactly as `CounterQuotient.lean`
and `RunLayer.lean` define them, enumerates every `Count`/`Drift` step with all four counters at or
below `3*(Tc+Tn+P+B)+10`, deduplicates to `(px, py, kappa (c,n), kappa (c',n'))` class pairs, and
for each pair searches `range(M)^2` for a witness. Three scripts, in the session scratchpad:
`rk.py` (the first failing-tuple scan), `rk2.py` (the per-tuple minimal sufficient bound and its
worst case), `rk5.py` (the 900-tuple candidate-bound comparison). The re-implementation's agreement
with the library is cross-checked by the three compiled witnesses, each of which the scan predicted
before it was compiled.

### D. References

- `specs/761_ladder_realization_theorem/plans/09_tight-chain-gate-regated-graph.md` — Phase 11.8
  blocker record, Phase 11.9 decision gate, Phase 12.1 Reasoned Exclusions
- `specs/761_ladder_realization_theorem/summaries/07_tight-chain-gate-regated-graph-summary.md` —
  the prior round's Follow-ups, which name `rk_of_count_drift`
- `specs/761_ladder_realization_theorem/.orchestrator-handoff.json` — dispatch 26's four blockers
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` — `repsCnt`, `RK`,
  `rk_iff`, `relK`, `ParamsOk`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — the recorded statement of
  the missing lemma and the open sub-question this report settles
- `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean` — tracked,
  compiling, unwired
