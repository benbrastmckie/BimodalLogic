# Research Report: Task #924

**Task**: 924 - Decide the fate of the `ForwardSlackWitnessed` frontier, now that its only landed
discharge route is refuted
**Started**: 2026-11-11T08:35:00Z
**Completed**: 2026-11-11T09:25:00Z
**Effort**: ~50 min (research only; two evidence files compiled, no library file edited)
**Dependencies**: None blocking. Parent: task 917 (closed). Concurrent siblings: 918
(`LadderWindow.lean`/`LadderModel.lean` territory), 925 (`LadderPump.lean` lint debt) — no file
touched by this dispatch.
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderIdle.lean` (the register-anchored
  iterated idle pump and the sharpened lengthening schema)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` (`idleSplice_pins`,
  `exists_idleSpliced_ladderPath`, `exists_idleTypeBlock_of_budget_le_run`, `idleBudget`,
  `idle_run_lt_tIdle_of_no_idleCycle`, the deletion primitives and their type lemmas)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`
  (`exists_deleted_ladderPath_of_next_region_nxt` and its verdict docstring, `HasForwardSlack`,
  `hasForwardSlack_of_next_region_cnt_le`, `exists_ladderPath_of_walk_nxt_at`,
  `exists_typeBlock_of_spacing`)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` (`ForwardSlackWitnessed`,
  `forwardSlackWitnessed_iff_next_region_cnt_le`, the five depth-`0` schemas)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` (`pinCompat_of_ladderPath`,
  `nxtAt_lipschitz_two_sided`, `cntAt_eq_nxtAt_of_idle_pend`, `cntAt_sub_of_pend`,
  `tpOf_periodic_of_objAt_periodic`, `exists_hist_of_isLadderPath`)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (`ParamsOk` (K1)-(K4),
  `cascadeBound`, `tShort`, `tIdle`, `objCycleLens`)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` (`certStabK` of `Real` as
  the unclaimed condition (5), `stab_bit_agree_of_certStabK`)
- `specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean`,
  `specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean`
- `specs/917_forward_slack_witnessed_discharge_or_refutation/` (report, plan, summary,
  `evidence/phase-5-gate-measurement.lean`, phase-5 handoff)
- Literature: NOT consulted, and the briefing's 106 documents were not read. The obstruction and
  the route found here are internal to this formalization's own counter/pin layer; the corpus
  carries no counterpart to it (the nearest entry, `hodkinson_wolter_zakharyaschev_2000`, supplies
  the block-deletion type lemma this tree already cites as HWZ Lemma 17 and nothing at the pin
  layer). Recorded so the omission is a decision and not an oversight.
**Artifacts**:
- `specs/924_forward_slack_witnessed_frontier_disposition/reports/01_forward-slack-frontier-disposition.md`
- `specs/924_forward_slack_witnessed_frontier_disposition/evidence/route-a-idle-pump-discharge.lean`
  (compiles `sorry`-free under `lake env lean`, zero diagnostics)
- `specs/924_forward_slack_witnessed_frontier_disposition/evidence/route-space-closure.lean`
  (compiles `sorry`-free under `lake env lean`, zero diagnostics)
**Standards**: report-format.md, subagent-return.md, anti-analysis.md, reference-grounding.md,
adversarial-verification.md

## Executive Summary

- **VERDICT: NEITHER of the dispatch's two terminal outcomes. This is the THIRD, NON-TERMINAL
  result, reported as such and not smoothed into (b).** It is reported with a strictly sharper
  frontier than the parent left, and with the half of the frontier that the parent could not
  reach now COMPILED.
- **OUTCOME (b) IS NOT AVAILABLE AS THE DISPATCH WORDS IT, and recording it would have been a
  factual error.** (b) asks for "a compiled statement of why no route through the currently
  landed machinery can succeed". That statement is FALSE. A route through the currently landed
  machinery DOES succeed, and this dispatch compiled it.
- **THE ROUTE, COMPILED (`evidence/route-a-idle-pump-discharge.lean`).**
  `forwardSlackWitnessed_of_cell_idleRunPumpable` derives `ForwardSlackWitnessed … x z l x.1.2.2`
  — **for EVERY amount `l`** — from one run-local premise: every type the cell at `x` realizes is
  realized there by some path that is pending forever into the past at `z`, sits in the
  pending-forever gap, and whose INTERVENING IDLE RUN carries an `(objAt, tpOf)`-repeat block.
  It passes through no deletion inside the first region above `z`'s region and spends no part of
  `(K2)`'s `cascadeBound`, so it satisfies both of the dispatch's exclusions on route (a).
- **IT IS ASSEMBLED ENTIRELY FROM LANDED MACHINERY — the route the dispatch presumed had to be
  invented already exists.** `idleGapLengtheningOfIdleRunRepeat_holds` (`LadderIdle.lean`) pumps
  the idle run by `d · k` while holding all three components of the state at `z`, preserving the
  realized type at `z`, and leaving the next region's countdown UNTOUCHED;
  `hasForwardSlack_of_next_region_cnt_le` (`LadderChain.lean`) then converts the original path's
  own free Lipschitz bound into the regime at amount `l`. The composition is two `obtain`s and an
  `omega`.
- **WHY THIS ROUTE PAYS WHERE THE DELETION ROUTE COULD NOT — the one-line reason.** The regime
  asks `K ≤ n + cntAt g z + I - l`; the free bound every ladder path carries is
  `K ≤ n + cntAt g z + I`. The refuted route tried to buy `l` units by LOWERING `K`, a quantity
  the saturated register has already spent to the last unit. The pump instead MANUFACTURES `d · k`
  units of `I`, and `I` is not a quantity any pin obligation bounds from above: the duplicated
  idle block contributes no pin of its own, and the pins above it move farther from those below
  while their values stay put (`idleSplice_pins`, unconditional).
- **BUT IT IS A CONDITIONAL DISCHARGE, so the hypothesis is NOT removed from the five schemas.**
  The premise is a datum of the object's step graph met by the path, not a consequence of
  `ParamsOk`: `idle_run_lt_tIdle_of_no_idleCycle` bounds every idle run below `tIdle pend` when
  the object has no idle cycle, and (K1) quantifies `prodCycleLens`, `objCycleLens` and
  `satPeriod` — never `idleCycleLens`. What the route buys is a RELOCATION of the frontier: from
  an opaque existential over paths at a given amount, onto a checkable, amount-free condition on
  one idle run.
- **THE FRONTIER IS NOW EXACTLY ONE NAMED SUB-REGIME: the non-pumpable side.** By C3
  (`evidence/route-space-closure.lean`) the premise needs an idle run of length at least two, so
  the open side is the paths whose intervening idle run has length `1` — equivalently, whose walk
  carries no idle-to-idle edge there. On that side the only dial left is lowering `K`, and every
  placement of it is closed: intra-region deletion inside the first region above `z`'s is REFUTED
  (parent task, compiled); a block spanning a region boundary is IMPOSSIBLE (C1: a
  type-respecting block's endpoints share an object state, hence a pendingness); the landed
  deletion is CONFINED to one region's interior by its own `hcl` (C2), so it never reduces the
  pin set and the straddling pair always survives; and the one dial the landed machinery does not
  implement — a pin-set-reducing, idle-aligned deletion of whole regions, which is pin-rigid and
  enters no cascade — FAILS ITS ANCHOR by at least `l` on the same saturated configuration, for
  every choice of which regions to delete (`whole_region_anchor_refuted`).
- **CONSEQUENCE FOR `certStabK`: the restatement obligation must stay PROVISIONAL, not be made
  permanent.** Making it permanent is the second half of outcome (b), and the compiled route
  removes its justification: `certStabK`'s unclaimed `Real` condition is now blocked on a
  condition that is DISCHARGEABLE on the pumpable side, not on one refuted outright.

## Context & Scope

Researched: whether a discharge route for `ForwardSlackWitnessed` exists that avoids both of the
dispatch's exclusions (block deletion inside the first region above `z`'s region; re-entry into
the doubling cascade), and, if not, what a compiled closure of the route space would have to say.

Constraints honored: no file under `FormalSystem/`, `Tests/` or `scripts/` was read-modified;
nothing was committed; no sibling's territory was touched (918 holds `LadderWindow.lean`,
`LadderModel.lean`, `RaySummary.lean`, the READMEs, `KTypeSummaryAxiomTest.lean`,
`check-evidence-probes.sh`, `typst/generated/status.typ`; 925 holds `LadderPump.lean` — this
dispatch wrote only inside its own `specs/924_…/` directory). The (K1) amendment the dispatch
excludes was not pursued and is not relied on anywhere below. No `sorry`, no axiom, no vacuous
definition is proposed; the two evidence files are `sorry`-free.

Evidence tier: lean-lsp was registered and reachable throughout; `lean_local_search` was not
needed, since every object in question is project-local and was read from source. The two
evidence files were additionally compiled by `lake env lean` directly (exit 0, no diagnostics),
so the claims below rest on elaboration against the project's own oleans and not on the MCP
snippet runner alone. Blocked tools (`lean_diagnostic_messages`, `lean_file_outline`) were not
called. No `lake build` was run: nothing was written into the library.

## Findings

### Reference Grounding — Tier 3 (implementation-backed)

No research paper, textbook or proof sketch is named by the task, the parent record or the
dispatch; the whole subject is this tree's own counter/pin layer. Tier 3 applies, and the mapping
is from LANDED DECLARATIONS to the obligations they discharge.

| Source declaration (file) | What it supplies | Used for | Verification | Status |
|---|---|---|---|---|
| `idleGapLengtheningOfIdleRunRepeat_holds` (`LadderIdle.lean:317`) | pumps the idle run by `d · k`; holds `objAt`/`cntAt`/`nxtAt` at `z`; leaves the next region's countdown equal; preserves `tpOf` at `z` | the whole constructive half of route (a) | consumed in a compiled proof | VERIFIED |
| `idleSplice_pins` (`LadderPump.lean:1803`) | the pin clause of an idle duplication, UNCONDITIONALLY | why route (a) spends no cascade budget | read from source; consumed transitively | VERIFIED |
| `exists_idleTypeBlock_of_budget_le_run` (`LadderPump.lean:1873`) | an `(objAt, tpOf)`-repeat block in any idle run of length `≥ idleBudget pend φ` | how the run-local premise is met in practice | signature read from source | VERIFIED |
| `idle_run_lt_tIdle_of_no_idleCycle` (`LadderPump.lean:1629`) | without an idle cycle every idle run is `< tIdle pend` | why the premise is not `ParamsOk`-derivable | signature + `LadderIdle.lean` contract bullet (iii) | VERIFIED |
| `hasForwardSlack_of_next_region_cnt_le` (`LadderChain.lean:1508`) | the regime from a bound on the next region's countdown | the final step of route (a) | consumed in a compiled proof | VERIFIED |
| `nxtAt_lipschitz_two_sided` (`LadderAgree.lean:1232`) + `cntAt_eq_nxtAt_of_idle_pend` (`LadderAgree.lean:679`) | the free bound `K ≤ n + cntAt g z + I` | the amount the pump must cover | consumed in a compiled proof | VERIFIED |
| `cntAt_sub_of_pend` (`LadderAgree.lean:694`) | every position of `[a, a+l]` is pending when `l ≤ cntAt g a` | C2, the confinement of the landed deletion | consumed in a compiled proof | VERIFIED |
| `exists_deleted_ladderPath_of_next_region_nxt` (`LadderChain.lean:1365`) + `no_deleted_ladderPath_of_straddle_break` (wired probe) | the refuted dial, and its refutation as a theorem | the `K`-dial's intra-region placement | docstring + probe read in full | VERIFIED (parent) |
| `tpOf_periodic_of_objAt_periodic` (`LadderAgree.lean:2825`) + `ladder-tpof-periodicity-refutation.lean` | type periodicity needs GLOBAL walk periodicity; the eventual form is FALSE | closes the "periodize the tail" escape | docstring + probe docstring read | VERIFIED |
| `paramsOkK1` (`CounterQuotient.lean:818`) | divisibility for `prodCycleLens`, `objCycleLens`, `satPeriod` — and nothing about idle cycles | why no parameter condition supplies the premise | definition read in full | VERIFIED |
| `certStabK` of `Real` (`LadderRealize.lean:46-52`) | the ONE unclaimed condition, which consumes the agreement of class-equivalent cells | the restatement obligation's locus | module docstring read | VERIFIED |

### Codebase Patterns

**Finding 1 — THE ROUTE SPACE IS TWO DIALS, AND THE DISPATCH'S STARTING POSITION SURVEYS ONLY
ONE.** `ForwardSlackWitnessed … x z l n` requires `g z = x`, so the countdown `cntAt g z` and the
register `nxtAt g z = n` are PINNED by the state — no construction may move them. By
`forwardSlackWitnessed_iff_next_region_cnt_le` the condition is
`K ≤ n + cntAt g z + I - l`, with `K` the countdown of the first region start above `z`'s region
and `I` the length of the intervening idle run. Exactly two quantities are free: `K` (down) and
`I` (up). The parent task surveyed the `K` dial exhaustively and refuted its one landed
placement. The `I` dial it recorded as refuted in Finding 4's row (a) — but that row refutes the
GENERAL availability of the premise, not the mechanism, and the mechanism has since landed in
full.

**Finding 2 — THE `I` DIAL IS LANDED, ANCHORED, ITERATED AND PIN-FREE.** Three landed facts,
read from source:

- `exists_idleSpliced_ladderPath` (`LadderPump.lean:1830`) duplicates an idle block whose two
  ends carry the same object state, with NO pin side condition — its docstring says
  "unconditional", and `idleSplice_pins` is why: the duplicated block contributes no pin (the
  seam is an idle-to-idle transition), pins below it are untouched, pins above it move `+l` in
  position with their values unchanged, so every pair's demand loosens or stays put.
- `exists_iterIdleSpliced_ladderPath` (`LadderIdle.lean:108`) re-performs that duplication `d`
  times through `exists_ladderPath_of_walk_nxt_at` instead, so the REGISTER AT `z` survives:
  `nxtAt g' z = nxtAt g z`. Its anchor clause is discharged from `idleSplice_pull`'s
  classification plus `nxtAt_lipschitz_two_sided` — the displaced pin class lies above the block
  and hence above `z`, so its distance to `z` only grows.
- `idleGapLengtheningOfIdleRunRepeat_holds` (`LadderIdle.lean:317`) packages that into exactly the
  shape a forward-slack consumer needs: `objAt g' z = objAt g z`, `cntAt g' z = cntAt g z`,
  `nxtAt g' z = nxtAt g z`, the run lengthened to `I + d · k`, the displaced region start still
  pending **with its countdown EQUAL to the original's**, and `tpOf σ' z = tpOf σ z`.

The last clause is the load-bearing one: the pump raises `I` and leaves `K` alone.

**Finding 3 — THE COMPOSITION, COMPILED (both statements `sorry`-free, zero diagnostics).**
`evidence/route-a-idle-pump-discharge.lean`:

- `hasForwardSlack_of_idleRunRepeat` — path level. From a pumpable path and any `d` with
  `l ≤ d · k`: a path agreeing at `z` in all three components, realizing the same stab-free type
  at `z`, and carrying `HasForwardSlack · z l (nxtAt g z)`. The arithmetic is one step: the
  pumped run's length is EXACTLY `I + d · k` (so the regime's `∀ I` collapses to one instance,
  proved by a two-case contradiction against the pump's own run and start clauses), and then
  `K ≤ n + cntAt g z + I ≤ n + cntAt g z + (I + d · k) - l`.
- `forwardSlackWitnessed_of_cell_idleRunPumpable` — cell level, with `d := l + 1` so the AMOUNT
  DISAPPEARS FROM THE PREMISE. `g' z = x` is recovered from the three component agreements by
  `Subtype.ext (Prod.ext _ (Prod.ext _ _))`.

**Finding 4 — WHAT CLOSES THE `K` DIAL, placement by placement**
(`evidence/route-space-closure.lean`, plus two landed records):

| Placement of the block | Effect on `K` | Verdict | Record |
|---|---|---|---|
| strictly inside the first region above `z`'s, deleted | `K − d` | **REFUTED**: `hanch` short by `d`, `hstraddle` by `2d`; on a saturated pair the primitive's CONCLUSION is false | parent task; `pin-cascade-straddle.lean`, `phase-5-gate-measurement.lean` |
| spanning a region boundary (idle end, pending end) | — | **IMPOSSIBLE**: `objAt g u = objAt g (u+d)` forces equal pendingness at the endpoints | C1, compiled |
| idle-aligned, spanning WHOLE regions (pin-set-reducing) | `K := K_{j'}` | **NOT LANDED** (the landed `hcl : l ≤ cntAt g a` confines every block to one region's interior, C2) and **FAILS ITS ANCHOR by at least `l`** on a climbing register, for every `j'` | C2 + `whole_region_anchor_refuted`, compiled |
| inside the first region above `z`'s, spliced | `K + d` | **WRONG DIRECTION**: raises the quantity that must come down | `spliceCnt` (`LadderAgree.lean:1086`) |
| anywhere above the first region above `z`'s | unchanged | **IRRELEVANT** | — |
| inside `z`'s own region | changes `cntAt g z`, or nothing | **DEAD**: `g z = x` pins the countdown | `ForwardSlackWitnessed`'s own `g z = x` clause |
| replace the tail above by a periodic repetition | could make all pins equal, making pin compatibility free | **BLOCKED AT THE TYPE LAYER**: type periodicity needs GLOBAL walk periodicity; the eventual/one-sided form is refuted unconditionally | `tpOf_periodic_of_objAt_periodic`; `ladder-tpof-periodicity-refutation.lean` |

The third row is the one worth stating carefully, because it is the only dial that is both
cascade-free and not already refuted by the parent, and it is therefore the one a reader would
reach for next. A pin-set-reducing deletion IS pin-rigid: it removes one pin and displaces every
higher pin by the same amount, so the surviving pairs inherit their compatibility verbatim and no
doubling is entered. Its only obligation is the anchor at the pin that becomes first. That
obligation is unpayable: on a maximally climbing register the pin at `p` carries
`K = n + (p − z)`, which satisfies every available fact with equality, and every candidate pin
sits strictly above `z`'s region and its idle run — so moving a LATER pin into first position
raises the value it must carry. `saturated_chain_is_the_doubling_recurrence` records that this
saturated assignment is `cascadeBound`'s `iter_doubling` recurrence attained with EQUALITY, so
this dial fails for the parent task's reason rather than a new one.

**Finding 5 — THE OPEN SIDE, NAMED EXACTLY.** C3 compiles that the pumpable premise forces
`2 ≤ I`: the block's endpoints are idle (C1), so its upper endpoint cannot be the next region's
start, and with `0 < k` the run must carry at least two idle positions. So the frontier is:

> paths whose intervening idle run has length `1` — equivalently, whose walk carries no
> idle-to-idle edge between `z`'s region and the next one.

On that side the `I` dial has no fuel and every placement of the `K` dial is closed by Finding 4.
`ForwardSlackWitnessed` there is neither discharged nor refuted, and this report claims neither.
Two further facts bound what a future attempt may expect:

- the premise is reachable in practice whenever the run is long: `exists_idleTypeBlock_of_budget_le_run`
  produces the repeat block from a run of length `≥ idleBudget pend φ`, and
  `exists_idleCycle_of_card_le_run` produces the object-level idle cycle from a run of length
  `≥ Fintype.card Q`. The middle band `2 ≤ I < idleBudget pend φ` is where a repeat may or may not
  exist and the pigeonhole does not decide it.
- nothing in `ParamsOk` bears on idle runs at all except `tIdle pend`'s appearance inside (K3)'s
  LOWER bound on `Tc`, which cannot force a run to be long. (K1)'s three divisibility conjuncts
  name `prodCycleLens`, `objCycleLens` and `satPeriod` — `idleCycleLens` appears in none of them.

**Finding 6 — WHY THE OBJECT-LAYER PIGEONHOLE CANNOT BE TRANSPORTED, which is the sharpest
statement of what blocks the open side.** Inside a region of countdown `> tShort Q φ` the spaced
type pigeonhole does return a type-respecting block, so the next region IS shortenable at the
OBJECT layer. The countdown of a walk is not free data — it is forced by the walk
(`cntAt_sub_of_pend`) — so the shortened walk's countdown is `delCnt`, and
`no_deleted_ladderPath_of_straddle_break` says NO ladder path carries that pair. The shortened
object walk is therefore not the walk of any ladder path, and the type-preservation lemma
`tpOf_eq_delIdx_of_tpOf_eq`, which relates two HISTORIES, has no second history to be applied
with. The object layer's shortenability is real and unliftable; that gap, not a missing
arithmetic bound, is what the open side is made of.

### External Resources

Both evidence files were elaborated against the project's own oleans, first through
`lean_run_code` (`{"success": true, "timed_out": false, "diagnostics": []}`) and then through
`lake env lean` directly (exit `0`, no output). Neither is landed; both are candidates for the
plan. Their full text is in
`specs/924_forward_slack_witnessed_frontier_disposition/evidence/`; the statements are:

```lean
-- evidence/route-a-idle-pump-discharge.lean
theorem hasForwardSlack_of_idleRunRepeat … (hpay : l ≤ d * k) :
    ∃ g' σ', IsLadderPath step pend g' ∧ (∀ t, σ'.state t = (t, g' t)) ∧
      objAt g' z = objAt g z ∧ cntAt g' z = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧
      HasForwardSlack g' z l (nxtAt g z) ∧ tpOf … σ' z = tpOf … σ z

def IdleRunPumpable … (g) (σ) (z) : Prop := …   -- pending-forever past, the gap, and an
                                                -- (objAt, tpOf)-repeat block in the run

theorem forwardSlackWitnessed_of_cell_idleRunPumpable …
    (hprem : ∀ T ∈ cellAt … ((z, x)) z, ∃ g σ, IsLadderPath step pend g ∧ g z = x ∧
      (∀ t, σ.state t = (t, g t)) ∧ tpOf … σ z = T ∧ IdleRunPumpable … g σ z) :
    ForwardSlackWitnessed step pend fwd bwd lab φ x z l x.1.2.2
```

```lean
-- evidence/route-space-closure.lean
theorem pend_endpoints_of_rep …   (hrep : objAt g u = objAt g (u + d)) :
    pend (objAt g u) = pend (objAt g (u + (d : ℤ)))
theorem block_confined_of_hcl … (hcl : l ≤ cntAt g a) :
    ∀ j : ℕ, j ≤ l → pend (objAt g (a + (j : ℤ))) = true
theorem idle_run_two_of_block … : 2 ≤ I
def AvailWhole (z C N I l p K : ℤ) : Prop := …
theorem whole_region_anchor_refuted … :
    AvailWhole z C N I l p (N + (p - z)) ∧ ¬ (N + (p - z) ≤ N + C + I - l)
theorem saturated_chain_is_the_doubling_recurrence … : K' = 2 * K + I' + 1
```

### Recommendations

In dependency order. Phases 1-2 land compiled value whatever is decided about the frontier;
phase 3 is the recording phase and carries the one judgment call.

1. **Land the two route-(a) statements**, in `LadderIdle.lean` (path level) and `LadderCell.lean`
   (cell level). `LadderIdle.lean` currently states NO cell-level consequence and nothing imports
   it, so the cell-level statement is what changes that; it must import `LadderCell` or be placed
   in a module downstream of both. Both proofs are already compiled verbatim in
   `evidence/route-a-idle-pump-discharge.lean` — land them as they stand, with
   `set_option linter.unusedFintypeInType false` scoped per declaration and the precedent cited,
   exactly as `exists_iterIdleSpliced_ladderPath` does.
   Each docstring MUST carry the three scoping clauses, or the statement will be read as the
   discharge it is not: (i) the premise is an object/run datum and not `ParamsOk`-derivable,
   naming `idle_run_lt_tIdle_of_no_idleCycle` and (K1)'s three conjuncts; (ii) the hypothesis is
   NOT removed from the five depth-`0` schemas; (iii) the reserved
   `cellLE_zero_const_of_kappa_eq` stays claimed by nothing, the ordinary window regime
   `c ≤ n + 1` stays uncovered, and the room bounds remain.
2. **Land the route-space closure** from `evidence/route-space-closure.lean` as a wired evidence
   probe under `specs/evidence/forward-slack-pin-cascade/`, beside the parent's
   `pin-cascade-straddle.lean`, with its `WIRED` entry in `scripts/check-evidence-probes.sh`.
   NOTE THE TERRITORY COLLISION: `check-evidence-probes.sh` is inside task 918's declared
   `file_scope`. Either sequence this behind 918 or add the `dependencies[]` edge; do not edit
   that script concurrently.
3. **Record the disposition in the same four durable places the parent used**, with the
   correction: the `certStabK` restatement obligation stays PROVISIONAL. Its justification has
   changed — it is now blocked on a condition that is dischargeable on the pumpable side, not on
   one refuted outright — and a "permanent" marking would be false. The four places are the
   `LadderChain.lean` module docstring (the verdict paragraph at line ~125), the primitive's own
   docstring, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`'s Requirement (W) section,
   and `specs/state.json`. THREE OF THE FOUR ARE IN TASK 918's `file_scope`
   (`KTypeSummaryAxiomTest.lean` explicitly; the READMEs and `status.typ` if counts move); only
   `LadderChain.lean` is free. Sequence accordingly.
4. **Do NOT attempt the open side in the same task.** The honest next step there is a separate
   task with one question: whether the object-layer shortenability of Finding 6 can be lifted at
   all without the (K1) amendment — i.e. whether a pin-set-reducing deletion primitive is worth
   landing for consumers OTHER than this frontier, given that its anchor is unpayable here.

Explicitly NOT recommended: the (K1) amendment (excluded by the dispatch, and orthogonal — the
obstruction is in the pin layer, not the periodicity layer); any attempt to re-enter the cascade;
any restatement of `ForwardSlackWitnessed` that weakens it to make the open side go through.

## Decisions

1. **Reported as the third, non-terminal result rather than as (b).** The dispatch's own
   instruction is explicit that reaching neither outcome must be reported as such. Recording (b)
   would have required asserting that no landed route can succeed, which the compiled
   `forwardSlackWitnessed_of_cell_idleRunPumpable` contradicts. Logged as a `scope-drift` issue.
2. **The route was compiled, not argued.** The dispatch's (a) asks for a route to be identified
   AND landed; a research dispatch cannot land in the library, so the route was compiled as task
   evidence with the exact statements and proofs an implementation phase can lift verbatim. This
   is the strongest form of "identified" available at this phase, and it is why the verdict is
   non-terminal rather than negative.
3. **The `certStabK` obligation is recommended to stay provisional.** This reverses the second
   half of (b) and is the one recommendation that changes a recorded decision of the parent, so
   it is raised as a `user_decision` rather than acted on by recommendation alone.
4. **The whole-region (pin-set-reducing) dial was measured, not dismissed.** It is the only dial
   that is cascade-free and not already refuted, so dismissing it on the grounds that it is
   unimplemented would have left the route space unsurveyed. Its anchor was measured in the
   parent's own `Avail` style, at the arithmetic layer, and fails by at least `l`.
5. **No concrete two-state witness path was built for the open side.** The parent's `obs` took a
   whole implementation phase; the arithmetic measurement is scale-invariant and sufficient for a
   NON-derivability finding, and this report states that limitation rather than implying a
   path-level refutation exists.
6. **No status beyond `researched` is claimed, and no `.orchestrator-handoff.json` is written.**
   Research agents never write one.

## Adversarial Self-Verification

Every load-bearing claim re-read against the Claim Verification Bar. The two claims that would
have been easiest to get wrong — "no route can succeed" and "the idle route is refuted" — are
both FALSE as stated by the dispatch's and the parent's framing, and both are corrected below.

| Claim | Source / counterexample considered | Verification method | Confidence |
|---|---|---|---|
| `ForwardSlackWitnessed` at every amount follows from the run-local premise | counterexample sought in: the amount not cancelling; the pumped run's length not being unique; `g' z = x` failing in the register component | compiled: `forwardSlackWitnessed_of_cell_idleRunPumpable`, zero diagnostics under both `lean_run_code` and `lake env lean` | **High** |
| The pump leaves the next region's countdown untouched | this is the clause the whole route rests on; if the pump moved `K` the arithmetic would not close | `idleGapLengtheningOfIdleRunRepeat_holds`'s own conclusion clause, read from source AND consumed in the compiled proof | **High** |
| The idle duplication carries no pin obligation | sought a hidden side condition in `exists_idleSpliced_ladderPath` / the anchored iterate | source read in full; `idleSplice_pins` takes `hg`, `hk`, `hidle` only; the anchored iterate's `hanch` is discharged internally | **High** |
| The premise is not `ParamsOk`-derivable | sought an idle-cycle conjunct in (K1)-(K4) | `paramsOkK1`-`paramsOkK4` definitions read in full: `idleCycleLens` appears in none; `idle_run_lt_tIdle_of_no_idleCycle` is the bound the other way; `LadderIdle.lean`'s contract bullet (iii) states the same verdict independently | **High** |
| The pumpable premise forces `2 ≤ I` | the degenerate case `a + k = R + I` (upper endpoint at the region start) | compiled: `idle_run_two_of_block` | **High** |
| A type-respecting block cannot span a region boundary | — | compiled: `pend_endpoints_of_rep` | **High** |
| The landed deletion is confined to one region's interior, so it never reduces the pin set | sought a landed deletion lemma without `hcl` | compiled: `block_confined_of_hcl`; `exists_deleted_ladderPath_of_pend_past` and `exists_deleted_ladderPath_of_next_region_nxt` both carry `hcl : l ≤ cntAt g a`, read from source | **High** |
| The pin-set-reducing dial's anchor fails by at least `l` | sought an assignment satisfying the available facts at which it holds — exists only if some pin carries a value below the allowance, i.e. only if the register is NOT saturated | compiled: `whole_region_anchor_refuted` exhibits the saturated family; NOT a refutation for non-saturated paths, and the report does not claim one | **High** for the measurement; **Medium** that no other fact about those pins is available (enumerated by hand from the parent's `Avail`, not mechanically) |
| The periodic-tail escape is closed | — | `tpOf_periodic_of_objAt_periodic`'s GLOBAL hypothesis read from source; `ladder-tpof-periodicity-refutation.lean`'s docstring read in full | **High** |
| The frontier is EXACTLY the `I = 1` side | the middle band `2 ≤ I < idleBudget` | stated explicitly in Finding 5 as a band the pigeonhole does not decide; the claim is scoped to "the premise holds ⇒ discharged" and "the premise needs `2 ≤ I`", not to a decidable dichotomy | **Medium**, and scoped as such |
| `certStabK`'s unclaimed condition is the locus of the restatement obligation | — | `LadderRealize.lean:46-52` read from source: condition (5), `certStabK` of `Real`, is the ONE condition consuming the agreement of class-equivalent cells | **High** |

**Contradiction log.**

1. `UNRESOLVED IN THE SOURCES, RESOLVED HERE: the parent's Finding 4 row (a) records the
   idle-run-lengthening route as "REFUTED already", while LadderIdle.lean lands that very
   route's mechanism as a theorem.` Resolution by precedence (a compiled declaration outranks a
   prose row in a report): both are correct about different objects. The parent's row refutes the
   UNRESTRICTED schema — an idle run of length two needs an idle-to-idle edge, which an
   admissible object need not have, and `idleGapLengtheningAllIncrements_refuted` separately
   refutes the freed-increment form. `idleGapLengtheningOfIdleRunRepeat_holds` is the SHARPENED
   schema, restricted to multiples of the repeat length and premised on a run-local repeat. The
   mechanism is a theorem; the premise is what is refuted as universally available. This report
   relies only on the sharpened form.
2. `RESOLVED: the dispatch asserts "its only landed discharge route is refuted"; this report
   finds a second landed route.` Resolution: the dispatch's premise was written from the parent's
   route survey, which treated the `I` dial as closed by the premise refutation and therefore did
   not revisit the mechanism after `LadderIdle.lean` landed. No contradiction of fact survives —
   only of scope, and the correction is compiled.

**Recommendations modified after verification**: two. The initial draft recommended recording the
frontier closed (outcome (b)) and making the `certStabK` obligation permanent — both were struck
once `forwardSlackWitnessed_of_cell_idleRunPumpable` compiled, and the second is now the report's
`user_decision`. The initial draft also treated the pin-set-reducing dial as "not landed,
therefore out of scope"; that was replaced by a measurement, since an unsurveyed dial is exactly
what a route-space closure may not contain.

## Tactic Survey Results

| Goal | Tactic | Result | Premises / config |
|---|---|---|---|
| the pumped run's length is unique (`J = I + d * k`) | `by_contra` + `rcases lt_or_gt_of_ne` + `Bool.false_ne_true (… .symm.trans …)` | success | needs BOTH the pump's run clause (for `J < I + d·k`) and its start clause (for `J >` ); neither direction closes alone |
| the regime's final arithmetic | `push_cast at hlip ⊢; omega` | success | `omega` reads `Int.natAbs` directly; the two nonnegativity facts `0 ≤ (cntAt g z : ℤ)`, `0 ≤ (I : ℤ)` must be supplied by hand as `Int.natCast_nonneg _` |
| same goal with `d := l + 1` inlined | `push_cast; omega` | **FAILED** | `push_cast` normalizes the goal's `↑((l+1) * k)` to `(↑l + 1) * ↑k` while the `ℕ`-level `hpay : l ≤ (l+1) * k` stays an opaque nonlinear atom, so `omega` sees two unrelated atoms. FIX: keep `d` an opaque variable in a separate lemma and instantiate it at the call site — which is also the right decomposition |
| `g' z = x` from three component agreements | `Subtype.ext (Prod.ext ?_ (Prod.ext ?_ ?_))` then `rw [← hgz]` | success | `objAt`/`cntAt`/`nxtAt` are `.1.1`, `.1.2.1`, `.1.2.2`; `Prod.ext` in the hypothesis-pair form is the shape this tree already uses (`RunLayer.lean`) |
| `nxtAt g z = x.1.2.2` under `g z = x` | `rw [← hgz]; rfl` | success | `nxtAt` is a projection, so `rfl` closes after the rewrite |
| the block cannot end at the region start | `rw [h] at hrep; rw [hrep] at hidleA; exact Bool.false_ne_true …` then `omega` | success | the cast `(1 : ℤ) ≤ (k : ℤ)` must be produced by `exact_mod_cast` before `omega` |
| the `AvailWhole` Lipschitz slot at the saturated value | `have h : (N + (p - z) - N) = p - z := by ring; rw [h]` | success | `rw` leaves `(p - z).natAbs ≤ (p - z).natAbs` closed by `rfl`-unification; `omega` is not needed |

## Context Extension Recommendations

- **Topic**: the two surgery layers of `RaySummary/` and which one carries a pin obligation.
- **Gap**: `context/project/lean4/` records nothing about this layer, and the single most
  expensive fact to re-derive in this dispatch was that the PENDING splice/deletion carries pin
  obligations while the IDLE duplication does not. The parent task spent nine phases inside the
  pending layer; the route that works lives one module away, in the idle layer, and the parent's
  own route table lists it as closed.
- **Recommendation**: add `context/project/lean4/domain/ladder-surgery-layers.md` with: the two
  layers and their entry points (`exists_deleted_ladderPath_of_*` / `exists_iterSpliced_*` versus
  `exists_idleSpliced_ladderPath` / `exists_iterIdleSpliced_ladderPath`); the one-line reason the
  idle layer's pin clause is free; the two pigeonholes and their budgets
  (`exists_typeBlock_of_spacing` against a region's COUNTDOWN, `exists_idleTypeBlock_of_budget_le_run`
  against a run's LENGTH); and the three rigidity facts the parent's own report asked for
  (`cntAt_eq_of_obj_eq`, `cntAt_eq_nxtAt_of_idle_pend`, `pend_past_of_nxtAt_lt`). That earlier
  recommendation is still unmet; this one supersedes and widens it.

## Appendix

Searches run — all local; no rate-limited Mathlib search tool was needed, since every object in
question is project-local:

- `grep -n "^def \|^theorem "` over `LadderPump.lean` — this is the search that surfaced the whole
  idle layer (`idleCycleLens`, `idleSpliceCnt`, `idleSplice_pins`, `exists_idleSpliced_ladderPath`,
  `idleBudget`, `exists_idleTypeBlock_of_budget_le_run`, `idle_run_lt_tIdle_of_no_idleCycle`)
- `grep` for `exists_ladderPath_of_walk_nxt_at` across the module set — the hit at
  `LadderIdle.lean:189` is what identified the register-anchored iterate
- `grep` for `pinCompat_of_ladderPath` across the module set — 20 hits, read at each site to
  establish which surgeries carry a pin obligation
- `grep -n "def ParamsOk" -B 45` in `CounterQuotient.lean` — (K1)-(K4) read in full
- `grep -rn "certStabK"` over `FormalSystem/` and `Tests/` — 20 hits; `LadderRealize.lean:46-52`
  is the locus
- `grep -rn "tpOf_periodic_of_objAt_periodic"` — 3 hits; the refutation probe named in the
  docstring was then read
- `sed -n` reads of: `exists_deleted_ladderPath_of_next_region_nxt` with its full verdict
  docstring, `exists_typeBlock_of_spacing`, `exists_ladderPath_of_walk_nxt_at`,
  `exists_ladderPath_of_walk_of_pins`, `HasForwardSlack`, `hasForwardSlack_{zero,of_next_region_cnt_le,of_idle_above}`,
  `ForwardSlackWitnessed`, `forwardSlackWitnessed_iff_next_region_cnt_le`, `Count`, `Drift`,
  `Rlad`, `Adm`, `cntAt_sub_of_pend`, `cntAt_eq_nxtAt_of_idle_pend`, `nxtAt_lipschitz_two_sided`,
  `pinCompat_of_ladderPath`, `exists_hist_of_isLadderPath`, `objCycleLens`, `tIdle`, `tShort`,
  `cascadeBound`, `ell0`, `exists_iterIdleSpliced_ladderPath`,
  `IdleGapLengtheningOfIdleRunRepeat`, `idleGapLengtheningOfIdleRunRepeat_holds`,
  `IdleGapLengtheningAllIncrements`
- four `lean_run_code` elaborations (one failure, diagnosed in the tactic table; three successes
  with `diagnostics: []`), then `lake env lean` on both evidence files (exit `0`, no output)

Issue-log entries recorded during this dispatch: one `win` (the cascade-free route was already
landed; the composition compiled against the warm olean cache with no `lake build` and no library
edit) and one `issue` (`scope-drift`, `costly`: outcome (b) is not available as worded, and
recording it would have been a factual error).
