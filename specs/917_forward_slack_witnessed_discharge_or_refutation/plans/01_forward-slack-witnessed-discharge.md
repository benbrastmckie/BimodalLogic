# Implementation Plan: ForwardSlackWitnessed — discharge or refutation

- **Task**: 917 - Discharge `ForwardSlackWitnessed` under `ParamsOk`, or compile a refutation
- **Status**: [IMPLEMENTING]
- **Effort**: 14.5 hours
- **Dependencies**: None blocking. The antitone slice of the collision dichotomy is already landed (see Overview).
- **Research Inputs**: `specs/917_forward_slack_witnessed_discharge_or_refutation/reports/01_forward-slack-witnessed-discharge.md`; the compile-verified Phase 4 signature measurement in `specs/917_forward_slack_witnessed_discharge_or_refutation/evidence/phase-4-pinned-signature-deficit.lean` and `.../evidence/phase-4-pinned-signature-deficit-FAILS.lean`
- **Reports Integrated**: `reports/01_forward-slack-witnessed-discharge.md`, `evidence/phase-4-pinned-signature-deficit.lean`, `evidence/phase-4-pinned-signature-deficit-FAILS.lean`
- **Artifacts**: plans/01_forward-slack-witnessed-discharge.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Goal Polarity**: mixed -- the Phase 6 goal exists only if the Phase 5 decision gate passes; see Decisions

## Overview

Research delivered a compiled reduction, not a verdict: `HasForwardSlack g z l n` is EXACTLY a
bound on the countdown of the first region start above `z`'s region, so `ForwardSlackWitnessed`
is a condition on the object walk and nothing else. This plan lands that reduction and its
scoping records unconditionally, then attacks the discharge through the one live route (excise a
type-respecting block from inside the NEXT region until its countdown falls below `tShort`, then
close with (K3)), with a named decision gate at the single open obstruction — straddling pin
compatibility across the deleted block. Done means: the reduction and the three scoping probes
are landed, and either `ForwardSlackWitnessed` is discharged for the regime (dropping one
hypothesis from each of the five landed schemas) or the obstruction is compiled as a wired
refutation of the route and recorded as such. The verdict is stated either way, never tacit.

### Research Integration

- **The reduction (compiled, Probe 2)**: `HasForwardSlack` ⟺ a bound on the next region's
  countdown. `hasForwardSlack_of_next_region_cnt_le` is the landed `⇐`; Probe 2 is the `⇒`.
- **The amount cancels at the schemas' own instantiation (Finding 3)**: the witnessing is asked
  at the HIGHER pair, so the required bound is the LOWER pair's Lipschitz allowance `K ≤ n+c+I`,
  independent of the displacement. This is why one generic discharge serves all five consumers.
- **The obstruction (Finding 4)**: the landed deletion `exists_deleted_ladderPath_of_pend_past`
  needs `hpast` at the deletion point, unavailable inside the next region; and the deletion
  shortens straddling pin-to-pin distances by `d` while leaving pin values put, so
  `pinCompat_of_ladderPath` can fail in a window of width `2d`. (K2)'s `cascadeBound` is the
  budget; the lemma that spends it is what is missing.
- **The refutation side is blocked (Finding 6, Probe 3)**: `fwd` seriality forces a pending
  successor, so no admissible object bounds its region lengths. The surviving partial refutation
  is the amount ceiling (Probe 4), which reaches the bare predicate only, never the schemas.
- **Scope correction (Finding 5)**: the discharge does NOT land the reserved
  `cellLE_zero_const_of_kappa_eq`. The pending-forever gap and the room bounds remain, and the
  ordinary window regime `c ≤ n + 1` is covered by nothing. Carried forward into every new
  docstring and into the test file's pin block.
- **Plan-time sharpening, corrected against compiled measurement**: taking the deletion ABOVE
  `z`'s region leaves every pin POSITION between `z` and the block undisplaced, but it does NOT
  leave every pin VALUE put. `delCnt` lowers by exactly `l` the value of the pin that STARTS the
  region CONTAINING the deleted block — a pin sitting below `a`, hence outside `hanch`'s `a ≤ v`
  range — because that region swallows the block (`delCnt_of_lt`'s `if a ≤ v + cntAt g v`
  branch). So an undisplaced-position pin's anchor clause is free from
  `nxtAt_lipschitz_two_sided` only once `(nxtAt g z : ℤ) ≤ (cntAt g z : ℤ)` is in hand: that
  inequality is the exact residue of the deficit after `cntAt_ge_of_reaches`, `hcl` and `hza`,
  and it is carried as the hypothesis `hnz` on Phase 4's pinned statement (Decision 3). Two
  clauses still become one-and-a-half: the straddling pin compatibility and the above-block
  anchor. Phase 4 is mechanical; Phase 5 carries the whole risk.
- **Revision input (compile-verified, not argued)**: both variants of the full Phase 4 proof are
  preserved as task evidence and were re-compiled with `lake env lean` at revision time.
  `evidence/phase-4-pinned-signature-deficit.lean` (signature plus `hnz`) emits ZERO output;
  `evidence/phase-4-pinned-signature-deficit-FAILS.lean` (signature exactly as originally
  pinned) emits exactly ONE error, at `123:8`, whose printed `omega` counterexample leaves
  `i := ↑(nxtAt g z)` and `c := ↑(cntAt g z)` mutually unconstrained. The deficit IS `hnz` and
  nothing else: not the stronger pending-forever gap, and not `hpast`, which stays because the
  proof uses it (it proves `habove`). `hnz` is never named in the proof body — one `omega`
  consumes it implicitly — so admitting it changes no proof text. Downstream cost is zero: at
  the Phase 6 consumer's state `⟨(q, C, N), h⟩` the existing `hgap : N + 2 ≤ C` implies it,
  verified compiling.

### Prior Plan Reference

No prior plan. This is the task's first plan round.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap phases are scheduled.

## Goals & Non-Goals

**Goals**:
- `next_region_cnt_le_of_hasForwardSlack` -- the converse direction of the reduction, landed beside its forward half.
- `hasForwardSlack_iff_next_region_cnt_le` -- the regime restated as a bound on one countdown, so the hypothesis becomes checkable.
- `hasForwardSlack_amount_le` -- the amount ceiling, scoped in its own docstring to the bare predicate.
- `pend_succ_of_fwd` -- seriality forces a pending successor; the fact that closes the refutation construction.
- `paramsOk_inflate` -- `ParamsOk` is closed under inflating the modulus.
- `exists_deleted_ladderPath_of_next_region_nxt` -- the deletion above `z`'s region, register held, with the two undischargeable clauses explicit.
- `forwardSlackWitnessed_of_paramsOk_of_pend_gap` -- the discharge, CONDITIONAL on the Phase 5 gate.

**Non-Goals**:
- Landing anything under the reserved name `cellLE_zero_const_of_kappa_eq`. The discharge does
  not reach it (Finding 5), and no declaration introduced here may take that name.
- The antitone slice of the collision dichotomy. Already landed (five schemas, not three).
- Any amendment to (K1). The obstruction lives in the pin layer, not the periodicity layer.
- Route (a) (idle-run lengthening -- refuted) or route (b) (lowering the register between `z` and
  the pin -- dead by the reduction).
- A weakened substitute for the discharge. If Phase 5's gate fails, the terminus is the compiled
  obstruction, not a discharge with an extra hypothesis bolted on.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 5's straddling pin cascade is not payable from (K2)'s budget in the forward direction (the budget was derived for the backward one) | H | M | Phase 5 is an explicit decision gate with a stated criterion and a STOP. On failure, Phase 8 compiles the obstruction as a wired probe and Phases 6-7 close `[COMPLETED WITH EXCLUSIONS]` citing Phase 5's own measurement. Do not weaken the statement to make it go through; do not introduce an axiom or a `sorry`-deferred case |
| The four probes compiled as standalone `lean_run_code` snippets, where `autoImplicit` is on; three of them leave `Q`, `step`, `pend` unbound | M | H | Every probe is landed inside a section whose `variable` line supplies `{Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}`, or with those binders written out explicitly. Treat a `linter.autoImplicit` warning as a failure: CI builds with `--wfail` (gate-collision Condition 8) |
| `exists_typeBlock_of_spacing`'s bound is `Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card` while (K3) is stated against `tShort Q φ = Fintype.card (ProdState Q φ)`; the two are equal only if `Fintype.card (ClType φ) = 2 ^ (plusSubformulaClosure φ).card` | M | M | Phase 5 confirms that identity against `ClType`'s own definition BEFORE building the loop, and carries it as a named lemma if it is not already landed. The Scope Hypothesis on Phase 5 names it |
| Line-count growth crosses each file's `set_option linter.style.longFile N` baseline; the linter accepts `N` only when `N - 200 ≤ lines < N`, so a stale baseline fails in both directions | M | H | Every phase that crosses its file's current `N` raises it in the SAME change to the smallest multiple of 100 strictly greater than the new line count; Phase 9 re-tightens every baseline it finds out of window (gate-collision Condition 7) |
| `.githooks/pre-commit` blocks any commit staging a `.lean` path while `typst/generated/status.typ` has drifted | M | H | Every Lean-touching phase runs `lake build && bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in its own commit (gate-collision Condition 1, surface (b) -- cannot be deferred) |
| Over-claiming: a landed `forwardSlackWitnessed_of_paramsOk_of_pend_gap` read as the reserved name's discharge | H | M | Finding 5 is reproduced verbatim in the new declaration's docstring, in each of the five new schemas' docstrings, and in `KTypeSummaryAxiomTest.lean`'s Requirement (W) pin block: the window regime `c ≤ n + 1` is covered by nothing and the room bounds remain |
| `objCycleLens_nonempty_of_pend` needs a pigeonhole-plus-reindexing argument that research flagged as argued, not compiled | L | M | It is a Phase 2 step with an explicit escape: if the re-indexing to `f l = f 0` with `l ≤ Fintype.card Q` exceeds the phase budget, Phase 2 closes `[COMPLETED WITH EXCLUSIONS]` for that one step with a `#### Reasoned Exclusions` record. `pend_succ_of_fwd` itself is compiled and lands regardless |
| A repo-wide gate is red for pre-existing, unrelated reasons | L | M | Every gate criterion below is scoped to the files the phase touches, or stated as a delta against the pre-task baseline, never as an absolute repo-wide zero (gate-collision Condition 4) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |

Phases within the same wave can execute in parallel. Phases 2 and 3 are the only parallel pair,
and they are file-disjoint by construction: Phase 2 touches `LadderChain.lean` and
`CounterQuotient.lean`, Phase 3 touches `LadderCell.lean` only. Every other wave holds one phase,
because the remaining phases share `LadderChain.lean` or `LadderCell.lean` and must not be run
concurrently against the same file.

### Phase 1: The Reduction and Its `iff` [COMPLETED]

**Goal**: Land the converse of `hasForwardSlack_of_next_region_cnt_le` and the named `iff` that
turns the regime from an opaque condition on a path into a bound on one countdown.

**Tasks**:
- [x] Confirm `next_region_cnt_le_of_hasForwardSlack` and `hasForwardSlack_iff_next_region_cnt_le` are absent from the tree (exact-name sweep, not a prefix anchor -- gate-collision Condition 3).
- [x] Land `next_region_cnt_le_of_hasForwardSlack` in `LadderChain.lean`'s `section Slack`, directly after `hasForwardSlack_of_next_region_cnt_le`, using the research report's Probe 2 body verbatim. Supply `{Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}` from the section's own `variable` line or explicitly; do not rely on `autoImplicit`.
- [x] Land `hasForwardSlack_iff_next_region_cnt_le` as the two-direction `iff`, `mpr` being the landed forward half and `mp` the new converse.
- [ ] Optionally introduce `def NextRegionBounded` beside `HasForwardSlack` as a naming convenience for the right-hand side, and restate the `iff` against it. This is a presentation choice, not a deliverable: if it is taken, the `iff`'s pinned statement must remain propositionally the one recorded in `## Lean Challenge Statements` (unfolding a `def` is not a weakening). *(deviation: skipped — declared a presentation choice, not a deliverable; the `iff` is stated against the explicit right-hand side so its pinned statement matches the Challenge block verbatim)*
- [x] Record in the converse's docstring that the two directions are EXACT, so the regime is a condition on the WALK: the countdown is read off the walk (`cntAt_eq_of_obj_eq`), and the pin value is forced (`cntAt_eq_nxtAt_of_idle_pend`).
- [x] Run `lake build` scoped to the module through the build guard, then `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` with the Lean change.
- [x] If the file's line count reaches or passes its current `set_option linter.style.longFile 2700`, raise `N` in the same change to the smallest multiple of 100 strictly greater than the new count. *(2669 lines after the edit; baseline 2700 still inside the linter's 2500-2699 window, so unchanged)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` is the complete covering check -- the phase adds declarations only and changes no existing signature, so nothing outside this module can observe the edit.

**Scope Hypothesis**: `LadderChain.lean` is 2615 lines with a `longFile` baseline of 2700 (read live at authoring time via `wc -l` and `grep set_option linter.style.longFile`); this phase adds an estimated hundred lines, which may or may not cross that baseline. Confirm with `wc -l` after the edit and apply the baseline rule above rather than assuming either outcome.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the converse, the `iff`, and optionally the `NextRegionBounded` naming convenience
- `typst/generated/status.typ` - regenerated line/count fields (`--fix`), staged in the same commit

**Verification**:
- The scoped guarded build is green with no `linter.autoImplicit`, `linter.style.show`, or unused-variable warning on the new declarations (treat a warning as a failure: CI runs `--wfail`).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.
- `lean_verify` on both new names reports the standard axiom profile and no `sorryAx`.

---

### Phase 2: The Scoping Records [COMPLETED]

**Goal**: Land the three compiled scoping probes, each with a docstring that states exactly what
it does and does not reach.

**Tasks**:
- [x] Exact-name sweep confirming `hasForwardSlack_amount_le`, `pend_succ_of_fwd`, `paramsOk_inflate` and `objCycleLens_nonempty_of_pend` are absent.
- [x] Land `hasForwardSlack_amount_le` (Probe 4, verbatim) in `LadderChain.lean`'s `section Slack`. Its docstring MUST scope itself: it refutes the bare predicate at a freely chosen amount and says NOTHING about the five schemas, where the amount cancels against the higher countdown (Finding 3). Model the scoping language on `kappa_collision_two_regimes_refuted`'s own docstring.
- [x] Land `paramsOk_inflate` (Probe 1, verbatim) in `CounterQuotient.lean` beside `paramsOk_params`, recording that (K1) is divisibility INTO `P + 1` while (K2)-(K4) never mention `P`.
- [x] Land `pend_succ_of_fwd` (Probe 3, verbatim) in `CounterQuotient.lean` beside `objCycleLens`.
- [x] Land `objCycleLens_nonempty_of_pend` *(landed in full; the ESCAPE was not needed -- the re-basing closed via `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` plus an index shift)*: from `pend_succ_of_fwd`, build a pending walk and pigeonhole it on the finite `Q` to produce `l` with `0 < l`, `l ≤ Fintype.card Q` and `f l = f 0`. ESCAPE: if the re-indexing to a cycle based at `f 0` exceeds this phase's budget, close the phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` row for this step alone; `pend_succ_of_fwd` lands regardless and the consequence (no admissible object bounds its region lengths) is recorded in its docstring either way.
- [x] Run the scoped guarded builds for both modules, then `typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.
- [x] Apply the `longFile` baseline rule to `LadderChain.lean` if its count crosses `N`. `CounterQuotient.lean` is 1013 lines with no baseline; confirm it stays below 1500 or add one. *(LadderChain crossed 2700 at 2703 lines; baseline raised to 2800. CounterQuotient at 1115 lines, still under 1500, no baseline added)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The two scoped module builds (`... -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` and `... -- build FormalSystem.Metalogic.Decidability.RaySummary.CounterQuotient`) together are the complete covering check; the phase adds declarations only and changes no existing signature, so no dependent module can observe it.

**Scope Hypothesis**: estimated added lines, `LadderChain.lean` roughly forty-five and `CounterQuotient.lean` roughly a hundred and twenty, and the four names are asserted absent on the strength of the research report's own greps (CARRIED from report section Appendix). Re-run the exact-name sweep at implementation time rather than trusting the carried figure, and confirm the line counts with `wc -l`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - `hasForwardSlack_amount_le` with its scoping docstring
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - the modulus-inflation closure lemma and the two seriality records
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit

**Verification**:
- Both scoped guarded builds green, warning-free on the new declarations.
- `hasForwardSlack_amount_le`'s docstring contains the explicit statement that it does not reach the schemas.
- `lean_verify` on each new name: no `sorryAx`.

---

### Phase 3: The Walk-Level Condition at the Cell Level [COMPLETED]

**Goal**: Restate `ForwardSlackWitnessed` as an assertion about region lengths, so the hypothesis
is checkable even if the discharge is defeated. This is the honest terminus from the research
report's Recommendation 5, landed early as unconditional value rather than held as a contingency.

**Tasks**:
- [x] Land, in `LadderCell.lean` beside `ForwardSlackWitnessed`, a named equivalence restating the definition with `HasForwardSlack` replaced by the next-region bound, proved by rewriting under the existential with Phase 1's `iff`.
- [x] The docstring MUST say what the restatement buys and what it does not: it converts an existential over paths into a statement about the first region above `z`'s region, and it is NOT a discharge. Reproduce Finding 5's scope note (the reserved name stays unclaimed; the window regime `c ≤ n + 1` is covered by nothing; the room bounds remain).
- [x] Do NOT name this declaration `cellLE_zero_const_of_kappa_eq` or any prefix of it. *(landed as `forwardSlackWitnessed_iff_next_region_cnt_le`)*
- [x] Scoped guarded build of `LadderCell`, then `typst-sync-check.sh --fix`, stage `typst/generated/status.typ`.
- [x] Apply the `longFile` baseline rule: `LadderCell.lean` is 1939 lines against a baseline of 2000. *(1991 lines after the edit; baseline 2000 still inside the 1800-1999 window, so unchanged)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell` is the complete covering check; the only dependents of `LadderCell` are the `RaySummary.lean` aggregator and the test file, and this phase adds a declaration without touching any existing signature either of them reads.

**Scope Hypothesis**: roughly sixty added lines, which is expected to reach or cross the 2000-line baseline from the file's current 1939. Confirm with `wc -l` and, if crossed, raise the baseline in the same change to the next value inside the linter's acceptance window; do not assume the baseline survives.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - the cell-level restatement and its scope docstring
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit

**Verification**:
- Scoped guarded build green and warning-free.
- The new docstring contains Finding 5's three surviving restrictions verbatim.

---

### Phase 4: The Deletion Above `z`'s Region, Register Held [COMPLETED]

**ADMITTED HYPOTHESIS, `hnz`** (this phase's pinned statement now carries it):
- **What the measurement established**: the phase's earlier pinned signature of
  `exists_deleted_ladderPath_of_next_region_nxt` was incomplete by exactly one inequality,
  `(nxtAt g z : ℤ) ≤ (cntAt g z : ℤ)`. Everything else in the phase discharges. The pinned
  statement in `## Lean Challenge Statements` now carries that inequality as `hnz`, on one line
  between `hza` and `hpast`, in exactly the MINIMAL cast form written above — not as the
  stronger pending-forever gap, which would import a restriction the proof does not need.
  `hpast` STAYS: the proof uses it, to prove `habove`.
- **What is therefore required of the implementer**: land the signature AS PINNED, `hnz`
  included. `hnz` is never named in the proof body — the single `omega` closing the anchor
  clause at a low pin consumes it implicitly — so admitting it changes no proof text. Lifting
  the already-compiled evidence proof verbatim is the expected route, not a re-derivation.
- **The evidence, compiled twice and re-verified at revision time** (both variants preserved as
  task evidence, both re-compiled with `lake env lean`):
  - `specs/917_forward_slack_witnessed_discharge_or_refutation/evidence/phase-4-pinned-signature-deficit.lean`
    — the pinned signature PLUS `hnz : (nxtAt g z : ℤ) ≤ (cntAt g z : ℤ)`. Compiles clean
    (`lake env lean`, no errors, no `sorry`), including the two pull lemmas `probe_low`/`probe_high`,
    the four pin-compatibility cases (both-below with its four reach sub-cases, both-above,
    and the two straddling directions through `hstraddle`), and the anchor clause at every pin.
  - `.../evidence/phase-4-pinned-signature-deficit-FAILS.lean` — the SAME proof with `hnz`
    deleted, i.e. the signature exactly as pinned. It fails at exactly ONE goal (line 123,
    the `omega` closing the anchor clause at a low pin whose region reaches the block) with
    omega's own counterexample constraint set printed, `i := ↑(nxtAt g z)` and
    `c := ↑(cntAt g z)` unrelated in it. The deficit is `hnz` and nothing else.
- **Why the deficit is real, and where Decision 3 went wrong**: Decision 3's reasoning ("taking the deletion ABOVE `z`'s region
  leaves every pin between `z` and the block UNDISPLACED, so that pin's anchor clause is free
  from `nxtAt_lipschitz_two_sided`") holds for pin POSITIONS but not for pin VALUES. The pin that
  starts the region CONTAINING the block sits below `a` — its position is undisplaced — but
  `delCnt`'s own definition lowers its value by exactly `l`, because that region swallows the
  deleted block (`delCnt_of_lt`'s `if a ≤ v + cntAt g v` branch, confirmed at `v + 1 = a` through
  `delSeg`). So the anchor's LOWER direction carries a deficit of exactly `l`:
  `nxtAt_lipschitz_two_sided` gives `nxtAt g z ≤ nxtAt g v + (v - z)` while the clause needs
  `nxtAt g z + l ≤ (nxtAt g v - l) + (v - z) + l`. Reducing that deficit through
  `cntAt_ge_of_reaches` and `hcl : l ≤ cntAt g a` and `hza` leaves precisely
  `nxtAt g z ≤ cntAt g z` and nothing else. That inequality does NOT follow from `hpast`:
  `Drift n n' := n' = n ∨ n' = n + 1 ∨ n' + 1 = n` admits free ±1 drift, and a path pending at
  every `p ≤ z` carries `cntAt g (z - k) = cntAt g z + k` with its register wholly unconstrained,
  so `hpast` cannot bound `nxtAt g z` against `cntAt g z` in either direction.
- **Why the repair is free downstream**: Phase 6's consumer instantiates at the state
  `⟨(q, C, N), h⟩` at `z`, where `cntAt g z = C` and `nxtAt g z = N`, and already carries
  `hgap : N + 2 ≤ C`, which implies `hnz` — verified compiling at revision time. No other
  consumer exists, and no snapshot manifest records this signature, so nothing has to be
  re-recorded. Phase 5's gate criterion is unchanged in substance.
- **Prohibited workarounds, unchanged by this revision**: do NOT use `sorry`, `def X := True`,
  or any vacuous placeholder; do NOT add any FURTHER hypothesis beyond the pinned `hnz` under
  the pinned name, and do NOT edit the recorded Challenge statement again to match what
  compiles. `hnz` is admitted by an explicit, user-approved plan revision recorded here and in
  Decision 3; anything beyond it is the exact laundering
  `.claude/rules/plan-compliance.md`'s Statement Fidelity section exists to catch. If a second
  deficit appears, STOP and report it rather than widening the statement.


**Goal**: Land `exists_deleted_ladderPath_of_next_region_nxt`: the register-exposing deletion at a
block ABOVE `z`'s region, discharging every pin obligation the landed construction can discharge
and taking exactly the two it cannot as explicit hypotheses.

**Tasks**:
- [x] Read `exists_deleted_ladderPath_of_pend_past_nxt` (`LadderChain.lean`, `section DelNxt`) in full. The new theorem re-runs the same construction through `exists_ladderPath_of_walk_nxt_at`, reusing `delObj_step`, `delCnt_idle`, `delCnt_pend_pend`, `delCnt_pend_idle` verbatim -- none of those four takes `hpast`.
- [x] Land the theorem with the pinned signature in `## Lean Challenge Statements`, `hnz` included. The register is pinned at `nxtAt g z`, not at a free `n`: that is what the consumer needs (`g' z = g z`), and it is `hnz` together with the pinned register that makes the undisplaced-position pins' anchor close.
- [x] Lift the compiled proof from `evidence/phase-4-pinned-signature-deficit.lean` rather than re-deriving it: both pull lemmas (`probe_low`/`probe_high`), the four pin-compatibility cases, and the anchor clause at every pin are already green against the real tree under this exact signature. `hnz` appears in no tactic — one `omega` consumes it — so no proof text changes when it is admitted.
- [x] Discharge, inside the proof: pins at or below `z` do not exist (`hpast` -- every `p ≤ z` is pending, so every idle position lies above `z`); the anchor for a position-undisplaced pin `v` with `z < v < a` is `nxtAt_lipschitz_two_sided g hg v z` composed with `cntAt_eq_nxtAt_of_idle_pend`, plus `hnz` at the one low pin whose region swallows the block and whose VALUE `delCnt` therefore lowers by `l`; a both-below pair is the original pair at the original distance; a both-above pair is the original pair with both positions displaced by `-l`, so its distance is unchanged -- both close through `pinCompat_of_ladderPath`.
- [x] Leave exactly two clauses as hypotheses, both stated in the DELETED walk's own vocabulary (`delObj`/`delCnt`) so no boundary case has to be re-derived at the statement level: `hanch` for the pins at or above `a`, and `hstraddle` for the pairs that straddle `a`.
- [x] Record in the docstring WHY these two and no others: the deletion leaves the undisplaced pins put while moving every later pin down by `l`, so a straddling pair's distance shrinks by `l` while its values do not move -- the `2l`-wide window `pinCompat_of_ladderPath` can fail in. Name (K2)'s `cascadeBound` and its `iter_doubling` recurrence `a (k+1) ≤ 2 * a k + J + 1` as the budget Phase 5 must spend, and state that this theorem spends none of it.
- [x] Do NOT drop `hpast`: the compiled evidence proof uses it, to prove `habove` (every idle position lies above `z`). The general permission still stands — dropping a genuinely unused hypothesis strengthens the theorem and is permitted; adding one beyond the pinned `hnz` is not.
- [x] Scoped guarded build, `typst-sync-check.sh --fix`, stage `typst/generated/status.typ`, apply the `longFile` baseline rule.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` is the complete covering check; the theorem is new, is consumed by nothing until Phase 5, and changes no existing signature.

**Scope Hypothesis**: estimated +130 lines to `LadderChain.lean`, and the claim that the four `delCnt`/`delObj` clauses need no `hpast` is read off the landed `exists_deleted_ladderPath_of_pend_past_nxt`'s own `refine` line (CARRIED from that proof, re-read at authoring time). Confirm the line count with `wc -l`; confirm the no-`hpast` claim by elaborating the four clause applications before writing the rest of the proof.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the new deletion primitive in `section DelNxt`
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit

**Verification**:
- Scoped guarded build green and warning-free.
- The landed signature matches the pinned one in `## Lean Challenge Statements`, modulo a deleted unused hypothesis (a strengthening).
- `lean_verify`: no `sorryAx`, standard axiom profile.

---

### Phase 5: DECISION GATE -- Spend (K2)'s Budget on the Straddling Pins [COMPLETED]

**Goal**: Decide, by compiled attempt rather than by argument, whether Phase 4's two clauses can
be discharged in the regime for the block `exists_typeBlock_of_spacing` returns inside the next
region. This phase decides which branch the rest of the plan takes.

**GATE VERDICT: FAIL.** Both clauses are non-dischargeable from the gate's admitted hypotheses,
measured and compiled rather than argued. The FAIL branch is taken: Phases 6 and 7 close
`[COMPLETED WITH EXCLUSIONS]`, Phase 8 compiles the obstruction, and `ForwardSlackWitnessed`
stays a hypothesis a consumer must supply.

- **Measurement of record**: `evidence/phase-5-gate-measurement.lean`, compiled `sorry`-free
  through `lake env lean`. It defines `Gate917.Avail`, which collects EVERY fact the admitted
  hypotheses supply about the arithmetic the two clauses reduce to, and exhibits concrete
  assignments satisfying all of them at which each clause is FALSE
  (`Gate917.anch_refuted`, `Gate917.straddle_refuted`), plus
  `Gate917.deficit_is_the_block_length` showing the residual is the deletion's own length and so
  survives every admissible choice of `u` and `d`.
- **The two facts available about the upper pin's value**, and no others:
  `pinCompat_of_ladderPath` at the pin pair gives `B ≤ K + (p - s)`, and
  `nxtAt_lipschitz_two_sided` from `z` gives `B ≤ N + (p - z)`, where `B = cntAt g (p + 1) =
  nxtAt g p` is the upper pin's value, `K = cntAt g s₀`, `s = z + cntAt g z + I` is the UNIQUE
  pin strictly below the block, and `p = v + d` is the upper pin's undeleted position.
- **Which pair, and which deficit**:
  - `hanch` at the upper pin needs `B ≤ N + (p - z) - d`; the available bound is
    `B ≤ N + (p - z)`. Deficit exactly `d`. The deletion leaves the pin's VALUE untouched while
    shortening its distance from `z` by `d`.
  - `hstraddle` at the pair `(s, v)` needs `B ≤ K + (p - s) - 2 · d`; the available bound is
    `B ≤ K + (p - s)`. Deficit exactly `2 · d`. The deletion lowers the LOWER pin's value by `d`
    (its region swallows the block, `del_pin_pull_of_lt`'s first branch) AND shortens the pair's
    distance by `d`; the two losses add.
  - Both violating assignments are the SATURATED ones — the register climbing at its maximum
    `Drift` rate, so both available bounds hold with equality. A configuration already at the
    bound breaks by exactly what the deletion removes.
- **Why the first attack fails**: the planned attack was that a straddling pair's distance
  `v - s` is at least the lower pin's own countdown plus one, so the deficit `d ≤ tShort` is
  payable out of the distance once the pin values are bounded by `cascadeBound ≤ Tc`. The
  distance IS that large — but the needed bound is not on the DISTANCE, it is on `B` relative to
  `K + (p - s)`, and that quantity already saturates. `cascadeBound`'s recurrence
  `K_{j+1} ≤ 2 · K_j + I + 1` is the SAME bound the saturated configuration attains with
  equality (`B = 2K + I' + 1` at the first pin above `s₀`'s region), so (K2)'s budget does not
  dominate the configuration — it describes it. There is no slack in the budget to spend.
- **Why no other hypothesis helps**: `Adm pend q = {c | pend q = false → c = 0}`
  (`LadderModel.lean`) places NO upper bound on a pending state's countdown, so the saturated
  region countdowns are admissible; and every `ParamsOk` conjunct the thresholds enter is a
  LOWER bound on a parameter (`CounterQuotient.lean`), never an upper bound on a path quantity.
  `K` can be exactly `tShort` while `C ≥ Tc ≥ 2 · tShort + tIdle + 2`, which is the direction
  that would be needed to make the Lipschitz bound beat the pin bound by `2 · d`.
- **Scope of the verdict**: this refutes ROUTE D at the pin layer — the discharge by deleting a
  type-respecting block inside the first region above `z`'s region with the register held at
  `z`. It does NOT refute `ForwardSlackWitnessed`, which is an existential over paths: a
  saturated path may still realize its types via some other path carrying `HasForwardSlack`.
  The hypothesis remains neither discharged nor refuted.

**Tasks**:
- [x] Confirm the threshold identity the loop's arithmetic rests on: `exists_typeBlock_of_spacing` bounds its block length by `Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card` while (K3) is stated against `tShort Q φ = Fintype.card (ProdState Q φ)` with `ProdState Q φ = Q × ClType φ`. Establish `Fintype.card (ClType φ) = 2 ^ (plusSubformulaClosure φ).card`, or find it landed, BEFORE building anything on top of it.
- [x] Instantiate `exists_typeBlock_of_spacing` at the first region start above `z`'s region (`s₀ := z + cntAt g z + 1 + I`), `w₀ := s₀`, `s := 1`. Its only hypotheses are that `s₀` is pending and that the sampling window fits inside `s₀`'s own region -- it carries no gap, no room bound and no `ParamsOk`, so re-instantiating it away from `z` imports none of `z`'s regime hypotheses. Verify that against its signature rather than assuming it.
- [x] ATTEMPT the gate: discharge Phase 4's `hanch` and `hstraddle` for `a := u`, `l := d` with `d ≤ tShort`, under `ParamsOk`, the pending-forever gap at `z`, and `Tc ≤ cntAt g z`. First attack: a straddling pair `s < a ≤ v` has `v - s` at least the lower pin's own countdown plus one (a region's length is its start countdown plus one, `cntAt_sub_of_pend` with `not_pend_of_count`), so the deficit `d ≤ tShort` is payable out of the distance whenever the pin values are bounded by (K2)'s `cascadeBound ≤ Tc`; the iterated bound is `K_{j+1} ≤ 2 · K_j + I + 1`, exactly `cascadeBound`'s own recurrence.
- [x] GATE CRITERION, measured not asserted: both clauses elaborate for the block `exists_typeBlock_of_spacing` returns, with no new hypothesis beyond `ParamsOk`, the pending-forever gap, and `Tc ≤ cntAt g z`. Unchanged in substance by Phase 4's `hnz`: the gate discharges `hanch` and `hstraddle` only, and `hnz` already follows from the pending-forever gap this criterion admits.
- [ ] On PASS: land the one-pass shortening lemma -- given a path through `x` at `z` with pending-forever below `z` and next-region countdown at least `tShort`, produce a path with the same object state, countdown and register at `z`, the same realized stab-free type at `z` (`tpOf_eq_delIdx_of_tpOf_eq`, which needs no pin condition and no `ParamsOk`), pending-forever below `z` preserved, the same region start and intervening idle run, and next-region countdown strictly smaller. *(not taken: the gate measured FAIL -- see **GATE VERDICT** below; the FAIL branch's zero-line outcome is a recorded result, not a skipped task, per this phase's own Scope Hypothesis)*
- [x] On FAIL: STOP. Do not add a hypothesis to make either clause go through, do not introduce an axiom, do not leave a `sorry`-deferred case. Record the obstruction's exact shape (which pair, which deficit, what was tried) in this phase's own notes for Phase 8 to compile, and mark Phases 6 and 7 `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` row each citing this phase's measurement.
- [x] Scoped guarded build, `typst-sync-check.sh --fix`, stage `typst/generated/status.typ`, apply the `longFile` baseline rule.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` is the complete covering check on the PASS branch (new declarations in one module, no signature change); on the FAIL branch the phase lands no Lean declaration at all and the covering check is the unchanged-tree build.

**Scope Hypothesis**: estimated +170 lines on the PASS branch and +0 on the FAIL branch, and the threshold identity `Fintype.card (ClType φ) = 2 ^ (plusSubformulaClosure φ).card` is asserted, not confirmed, at authoring time. Confirm the identity against `ClType`'s definition as this phase's first task; confirm the line count with `wc -l`. Nothing in this phase's task list is excluded by this hypothesis -- the FAIL branch's zero-line outcome is a recorded result, not a skipped task.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the clause discharge and the one-pass shortening lemma (PASS branch only)
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit (PASS branch only)

**Verification**:
- PASS: the scoped guarded build is green, both clauses elaborate with no hypothesis beyond the three named above, and `lean_verify` on the one-pass lemma shows no `sorryAx`.
- FAIL: the obstruction is recorded with the specific pair and deficit that could not be closed, and the gate's verdict is written into this phase's notes in a form Phase 8 can compile. A FAIL with no recorded measurement is not a completed phase.

---

### Phase 6: The Normalization Loop and the Discharge [NOT STARTED]

**Goal**: Iterate Phase 5's one-pass lemma to drive the next region's countdown below `tShort`,
then close with (K3) to land `forwardSlackWitnessed_of_paramsOk_of_pend_gap`. Conditional on
Phase 5's gate passing.

**Tasks**:
- [ ] Build the normalization loop over the measure `cntAt g s₀` -- the countdown of the first region start above `z`'s region, which each pass lowers by `d ≥ 1` while leaving the region start and the intervening idle run fixed. State the measure over that ONE pin; keep every later pin's treatment inside Phase 4's primitive, never in the loop. The existing overshoot/iterated-splice loop in `LadderChain.lean` is the model.
- [ ] Land the loop's conclusion: every stab-free type realized at `x` at `z` is realized there by a path whose first region above `z`'s region has countdown below `tShort Q φ`.
- [ ] Land `forwardSlackWitnessed_of_paramsOk_of_pend_gap` in `LadderCell.lean` with the pinned signature. Close the arithmetic with Phase 1's `iff`: the loop gives `K < tShort Q φ`, `I ≥ 1`, and `hroom : tShort Q φ + l ≤ N + C` gives `K ≤ N + C + I - l`, which is the regime.
- [ ] Discharge Phase 4's `hnz` here, where it is free: at this theorem's state `⟨(q, C, N), h⟩` at `z` we have `cntAt g z = C` and `nxtAt g z = N`, and `hgap : N + 2 ≤ C` gives `(N : ℤ) ≤ (C : ℤ)` outright. This costs the discharge no hypothesis it does not already carry — confirmed compiling at revision time — so `hnz` must NOT be propagated into this theorem's signature, which is unchanged.
- [ ] The docstring MUST state what is and is not discharged: the hypothesis is discharged for the pending-forever regime at countdown at least `Tc`; the reserved name `cellLE_zero_const_of_kappa_eq` remains claimed by nothing; the window regime `c ≤ n + 1` is covered by no landed inclusion in either direction; the room bounds the five schemas carry are untouched (Finding 5).
- [ ] `hroom` is stated with slack on purpose -- every consumer has `Tc ≤ c` and (K3) gives `2 · tShort + tIdle + 2 ≤ Tc`, so the slack is free. Weakening `hroom` (strengthening the theorem) is permitted; weakening the CONCLUSION is not.
- [ ] Scoped guarded builds for both modules, `typst-sync-check.sh --fix`, stage `typst/generated/status.typ`, apply the `longFile` baseline rule to both files.
- [ ] If Phase 5's gate FAILED: close this phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record whose Evidence column cites Phase 5's own failing measurement. Land nothing.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: interface

**Tier Justification**: The loop lands in `LadderChain.lean` and is consumed from `LadderCell.lean`, so the covering check is the build of the changed module plus its enumerated direct dependents -- `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`, `...LadderCell`, `...LadderIdle`, and the `FormalSystem.Metalogic.Decidability.RaySummary` aggregator -- which no cheaper tier reaches.

**Scope Hypothesis**: estimated added lines on the PASS branch, `LadderChain.lean` roughly a hundred and forty and `LadderCell.lean` roughly seventy; the per-consumer discharge of `hroom` is asserted to follow from `Tc ≤ c` plus (K3) for all five schemas on the strength of Finding 3's cancellation (CARRIED from the research report's Finding 3 table). Confirm the cancellation per schema in Phase 7, not here, and confirm line counts with `wc -l`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - the normalization loop
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - `forwardSlackWitnessed_of_paramsOk_of_pend_gap` and its scope docstring
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit

**Verification**:
- Both scoped guarded builds green and warning-free.
- The landed signature of `forwardSlackWitnessed_of_paramsOk_of_pend_gap` matches the pinned one, modulo a weakened `hroom` (a strengthening).
- `lean_verify` on it: no `sorryAx`, standard axiom profile.
- Its docstring reproduces all three surviving restrictions from Finding 5.

---

### Phase 7: The Five Schemas Without the Witnessing Hypothesis [NOT STARTED]

**Goal**: Drop `ForwardSlackWitnessed` from each of the five landed depth-`0` cell-equality
schemas, keeping every other hypothesis exactly as it stands. Conditional on Phase 6.

**Tasks**:
- [ ] Enumerate all FIVE consumers (not three -- the dispatch's starting position is stale): `cellLE_zero_const_of_kappa_eq_of_forwardSlack`, `..._commonShift_of_forwardSlack`, `..._monotone_of_forwardSlack`, `..._antitone_of_forwardSlack`, `..._antitone_bounded_of_forwardSlack`, with their schema `def`s.
- [ ] For each, add a new schema `def` that is the existing one with the witnessing conjunct DELETED and every other hypothesis -- the pending-forever gap, the threshold bounds, the equal-register or displacement hypothesis, and the room bound -- kept verbatim. The deletion must be checkable as a one-conjunct diff against the original `def`.
- [ ] For each, add a theorem discharging the new schema by applying the existing `_of_forwardSlack` theorem with the witnessing supplied by `forwardSlackWitnessed_of_paramsOk_of_pend_gap`, confirming per schema that `hroom` follows from that schema's own room bound plus `Tc ≤ c` and (K3). The common-shift and monotone cases instantiate the discharge at the DOUBLED amount; verify the cancellation arithmetic separately for each rather than once.
- [ ] Naming: suffix each new name so the surviving restriction is in the name (`_of_pend_past` or equivalent). NO new declaration may take the reserved name `cellLE_zero_const_of_kappa_eq`, and none may be a bare prefix of it. Schema `def` names stay CamelCase (C26 flags a non-trailing underscore in a `def` name; `theorem` is exempt).
- [ ] Each new declaration's docstring reproduces Finding 5: the reserved schema quantifies over EVERY `kappa`-collision; these five carry the pending-forever gap, which by `pend_past_of_nxtAt_lt` restricts to paths pending at every earlier position; the ordinary window regime `c ≤ n + 1` is addressed by nothing; the room bounds remain.
- [ ] Scoped guarded build, `typst-sync-check.sh --fix`, stage `typst/generated/status.typ`, apply the `longFile` baseline rule.
- [ ] If Phase 6 was excluded: close this phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record citing Phase 5's failing measurement. Land nothing.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: interface

**Tier Justification**: The new schema `def`s and theorems in `LadderCell.lean` are read by the enumerated direct dependents `FormalSystem.Metalogic.Decidability.RaySummary` (the aggregator) and `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, so the covering check is the build of `LadderCell` plus those two targets -- which the `local` tier's single-module build does not reach.

**Scope Hypothesis**: ten new declarations (five schema `def`s, five theorems) at an estimated +250 lines to `LadderCell.lean`, on the hypothesis that each theorem's proof is a one-line delegation. Confirm by writing the equal-register case first and measuring it before committing to the remaining four; if a case needs real work, split it into its own sub-phase rather than overrunning.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - the five new schema definitions with their five discharging theorems and scope docstrings
- `typst/generated/status.typ` - regenerated count fields, staged in the same commit

**Verification**:
- Scoped guarded build plus the test-library build green and warning-free.
- Each new schema `def` differs from its original by exactly the deleted witnessing conjunct (checked by reading the two side by side).
- An exact-name sweep confirms `cellLE_zero_const_of_kappa_eq` itself still has no declaration site anywhere under `FormalSystem/`.
- `lean_verify` on each of the five new theorems: no `sorryAx`.

---

### Phase 8: CONDITIONAL -- Compile the Route-(d) Obstruction [NOT STARTED]

**Goal**: Runs only if Phase 5's gate FAILED. Turn the obstruction into a machine-checked record,
so the route is refuted rather than merely unproved, and record the consequence for `certStabK`'s
unclaimed condition.

**Tasks**:
- [ ] Write a `sorry`-free probe under `specs/evidence/` whose theorem exhibits the failure: a ladder path, a block inside the first region above `z`'s region, and a straddling pin pair whose compatibility fails at the reduced distance for every admissible choice the normalization can make. Model it on the existing refutation probes' shape.
- [ ] Add the probe's path to `scripts/check-evidence-probes.sh`'s `WIRED` list with a one-line entry saying what it holds in place. A probe under `specs/` is reached by no Lake target, so without the entry it rots silently.
- [ ] Record the verdict in `LadderChain.lean`'s module docstring and in Phase 4's primitive docstring: route (d) is refuted at the pin layer; the two clauses are not dischargeable from (K2)'s budget in the forward direction; `ForwardSlackWitnessed` stays a hypothesis a consumer must supply.
- [ ] Record the dispatch's named consequence: if the hypothesis is not derivable, `certStabK`'s one unclaimed Real condition must be RESTATED rather than proved. Write that consequence into the durable record -- this task's own description in `specs/state.json` and the `KTypeSummaryAxiomTest.lean` pin block (Phase 9 stages the test-file half) -- never into a dispatch-created sidecar.
- [ ] If Phase 5's gate PASSED: close this phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record whose Evidence column cites Phase 5's passing measurement. Land nothing.

**Timing**: 1 hour

**Depends on**: 7

**Verification Tier**: local

**Tier Justification**: `bash scripts/check-evidence-probes.sh` compiles the new probe through `lake env lean` and is the complete covering check for it; the accompanying docstring edits have no elaboration surface beyond the scoped module build already named in Phase 4.

**Scope Hypothesis**: this phase lands content only on the FAIL branch, and the probe is estimated at one file of 60-120 lines plus one `WIRED` entry. Confirm the branch from Phase 5's recorded measurement before starting, and confirm the probe compiles via `check-evidence-probes.sh` rather than by reading it.

**Files to modify**:
- `specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean` - the new wired probe (FAIL branch only; adjust the directory name to the obstruction actually measured)
- `scripts/check-evidence-probes.sh` - the probe's `WIRED` entry (FAIL branch only)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - module and primitive docstrings recording the verdict (FAIL branch only)
- `typst/generated/status.typ` - regenerated count fields if any `.lean` line count moved, staged in the same commit

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 with the new probe compiled and no pre-existing probe newly red (stated as a delta against the pre-task run, not an absolute).
- The probe is `sorry`-free and axiom-free beyond the standard profile.
- The verdict appears in the durable record, not only in this plan.

---

### Phase 9: Records, Generated Surfaces and Final Verification [NOT STARTED]

**Goal**: Land the test-file pin block, reconcile every generated surface, re-tighten the
`longFile` baselines, and run the complete gate set. The verdict -- discharge or compiled
obstruction -- is stated explicitly here, never left tacit.

**Tasks**:
- [ ] Update `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`'s Requirement (W) narrative to the actual outcome. On the discharge branch: the witnessing hypothesis is discharged for the pending-forever regime, the five schemas lose it, and the reserved name is STILL claimed by nothing -- with Finding 5's three surviving restrictions spelled out. On the obstruction branch: route (d) is refuted, the hypothesis is carried, and `certStabK`'s unclaimed Real condition must be restated rather than proved.
- [ ] Add `#print axioms` pins (with `#guard_msgs`) for every new declaration the task landed, following the file's existing pin convention.
- [ ] Re-tighten every `set_option linter.style.longFile N` this task touched to the smallest value satisfying the linter's `N - 200 ≤ lines < N` window at the file's FINAL line count -- `LadderChain.lean`, `LadderCell.lean`, and `CounterQuotient.lean` if it crossed 1500. An earlier phase's baseline is wrong by construction once later phases have grown the file.
- [ ] Regenerate the module-inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`, then verify with `--emit-inventory --check`. This is Condition 1's surface (a) and is legitimately deferred to here.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` one final time and stage `typst/generated/status.typ`.
- [ ] Run the full gate set and record each result: the unscoped guarded `lake build`; `bash scripts/check-module-invariants.sh`; `bash scripts/typst-sync-check.sh`; `bash scripts/check-metalogic-cycles.sh`; `bash scripts/check-evidence-probes.sh`; `bash scripts/check-copyright-headers.sh`; and the test library.
- [ ] For each gate, distinguish findings that name this task's own touched files from the tree's standing baseline. A gate whose only failures are pre-existing and outside this task's file scope is a recorded PASS for this phase, with the pre-existing findings enumerated -- it is not grounds to edit an out-of-scope file.
- [ ] State the task's verdict in the summary artifact, in one sentence, naming which of the two admissible outcomes was reached.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: the file list below is the set of generated and record surfaces a Lean
line-count change is expected to move, enumerated from gate-collision Conditions 1 and 7 at
authoring time. Confirm it by running the regeneration commands and reading which tracked files
they actually rewrite -- add any file they touch that is absent here, and drop any that comes
back unchanged, rather than forcing a surface to appear in the diff.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the Requirement (W) narrative and the new axiom pins
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - final `longFile` re-tightening
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - final `longFile` re-tightening
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - `longFile` baseline if the file crossed 1500
- `README.md` - regenerated module-inventory block
- `FormalSystem/Metalogic/README.md` - regenerated module-inventory blocks
- `typst/generated/status.typ` - final regenerated count fields

**Verification**:
- The complete gate set runs and is recorded: unscoped guarded `lake build` green; `bash scripts/check-module-invariants.sh` green or green-modulo-enumerated-pre-existing; `bash scripts/typst-sync-check.sh` green; `bash scripts/check-metalogic-cycles.sh` green (no new upward import was introduced, so Assertion B's frozen allowlist needs no extension -- confirm rather than assume); `bash scripts/check-evidence-probes.sh` green; `bash scripts/check-copyright-headers.sh` green; the test library builds with every `#guard_msgs` pin satisfied.
- Every `longFile` baseline this task touched sits inside the linter's acceptance window at the final line count.
- `bash .claude/scripts/validate-artifact.sh specs/917_forward_slack_witnessed_discharge_or_refutation/plans/01_forward-slack-witnessed-discharge.md plan` passes.
- The verdict sentence is present and names one of the two admissible outcomes.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem next_region_cnt_le_of_hasForwardSlack {Q : Type} {step : Q → Q → Bool}
    {pend : Q → Bool} (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n : ℕ)
    (hs : HasForwardSlack g z l n) :
    ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      (cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) : ℤ) ≤ (n : ℤ) + cntAt g z + I - l := sorry

theorem hasForwardSlack_iff_next_region_cnt_le {Q : Type} {step : Q → Q → Bool}
    {pend : Q → Bool} (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n : ℕ) :
    HasForwardSlack g z l n ↔
      (∀ I : ℕ, 0 < I →
        (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
        pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
        (cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) : ℤ)
          ≤ (n : ℤ) + cntAt g z + I - l) := sorry

theorem hasForwardSlack_amount_le {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n I : ℕ) (hI : 0 < I)
    (hidle : ∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false)
    (hnx : pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true)
    (hs : HasForwardSlack g z l n) :
    (l : ℤ) ≤ (n : ℤ) + cntAt g z + I := sorry

theorem pend_succ_of_fwd {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (q : Q) (hq : pend q = true) :
    ∃ q', step q q' = true ∧ pend q' = true := sorry

theorem paramsOk_inflate {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) (j : ℕ) (hj : 0 < j) :
    ParamsOk step pend lab φ Tc Tn (j * (P + 1) - 1) B := sorry

theorem exists_deleted_ladderPath_of_next_region_nxt {Q : Type} {step : Q → Q → Bool}
    {pend : Q → Bool} {g : ℤ → LadderState Q pend} {z a : ℤ} {l : ℕ}
    (hg : IsLadderPath step pend g) (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hza : z + (cntAt g z : ℤ) + 1 ≤ a)
    (hnz : (nxtAt g z : ℤ) ≤ (cntAt g z : ℤ))
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true)
    (hrep : objAt g a = objAt g (a + (l : ℤ)))
    (hanch : ∀ v : ℤ, a ≤ v → pend (delObj g a l v) = false →
      pend (delObj g a l (v + 1)) = true →
      ((delCnt g a l (v + 1) : ℤ) - (nxtAt g z : ℤ)).natAbs ≤ (v - z).natAbs)
    (hstraddle : ∀ s v : ℤ, s < a → a ≤ v →
      pend (delObj g a l s) = false → pend (delObj g a l (s + 1)) = true →
      pend (delObj g a l v) = false → pend (delObj g a l (v + 1)) = true →
      ((delCnt g a l (s + 1) : ℤ) - (delCnt g a l (v + 1) : ℤ)).natAbs
        ≤ (s - v).natAbs) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      (∀ v, objAt g' v = delObj g a l v) ∧ (∀ v, cntAt g' v = delCnt g a l v) ∧
      nxtAt g' z = nxtAt g z := sorry

theorem forwardSlackWitnessed_of_paramsOk_of_pend_gap {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (C N : ℕ) (h : C ∈ Adm pend q) (hgap : N + 2 ≤ C)
    (l : ℕ) (hroom : tShort Q φ + l ≤ N + C) (z : ℤ) :
    ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, C, N), h⟩ : LadderState Q pend) z l N := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Decisions

1. **The Challenge block pins seven statements, not every declaration the plan lands.** The seven
   are the ones where weakening is the live hazard and the exact signature is knowable at plan
   time. Deliberately excluded, each for a stated reason: the `NextRegionBounded` naming
   convenience and Phase 3's cell-level restatement, because pinning them would require a `def`
   in the Challenge block, whose body a snapshot forces to `sorry` and whose pinned statement
   would therefore be empty; Phase 5's clause discharge and one-pass lemma, because their exact
   shape depends on the mechanism the gate is there to decide; Phase 6's loop, an internal step
   of the discharge it feeds; and Phase 7's ten declarations, whose statements are pinned by
   construction as a one-conjunct diff against five already-landed schemas, checkable by reading
   the two side by side.
2. **`Goal Polarity` is declared `mixed` rather than left absent.** `forwardSlackWitnessed_of_paramsOk_of_pend_gap`
   exists only if Phase 5's gate passes, so must-exist semantics would fail a plan that correctly
   took its own contingency branch, and `refutation` semantics would fail it the other way. The
   vocabulary has no `conditional` value, and the documented escape for a Goals block that cannot
   be expressed by the single global field is an explicit non-`refutation` value, which makes
   `lean-plan-compliance-check.sh` record `skipped` with a stated reason. The six unconditional
   goals are still verified by Phase 9's own per-name checks.
3. **The deletion is taken ABOVE `z`'s region, with the register pinned at `nxtAt g z`, and the
   statement carries `hnz : (nxtAt g z : ℤ) ≤ (cntAt g z : ℤ)`.** The deletion's position is
   what reduces the research report's two-clause obstruction to one-and-a-half. But the
   reduction holds for pin POSITIONS, not pin VALUES, and the distinction is load-bearing: every
   pin position between `z` and the deleted block is undisplaced, yet `delCnt` lowers by exactly
   `l` the VALUE of the pin that starts the region CONTAINING the block (a pin below `a`, outside
   `hanch`'s `a ≤ v` range), because that region swallows the block. At that one pin the anchor's
   lower direction carries a deficit of exactly `l`: `nxtAt_lipschitz_two_sided` gives
   `nxtAt g z ≤ nxtAt g v + (v - z)` while the clause needs
   `nxtAt g z + l ≤ (nxtAt g v - l) + (v - z) + l`. Reducing that deficit through
   `cntAt_ge_of_reaches`, `hcl : l ≤ cntAt g a` and `hza` leaves precisely `hnz` and nothing
   else, and `hnz` does NOT follow from `hpast`: `Drift n n' := n' = n ∨ n' = n + 1 ∨ n' + 1 = n`
   admits free ±1 register drift, so a path pending at every `p ≤ z` has
   `cntAt g (z - k) = cntAt g z + k` with its register wholly unconstrained. `hnz` is therefore
   taken as an explicit hypothesis, in its minimal cast form rather than as the stronger
   pending-forever gap. It is free at the only consumer (Phase 6's `hgap : N + 2 ≤ C` implies
   it), so the discharge loses nothing. The consumer needs `g' z = g z` anyway, so pinning the
   register at its own value costs no generality.
4. **One generic discharge serves all five consumers.** The displacement cancels against the
   higher pair's countdown (research Finding 3), so `hroom : tShort Q φ + l ≤ N + C` is the single
   hypothesis each schema discharges from its own room bound plus `Tc ≤ c` and (K3). This is a
   plan-time factorization of the research report's phase-4 recommendation, not a departure from
   it.
5. **Phase 5 is a decision gate with a STOP, and Phase 8 is its contingency branch.** A compiled
   refutation of route (d) is a legitimate terminus of the same kind as
   `free_register_anchor_clause_monotone_required`. Weakening the discharge's statement, adding an
   axiom, or leaving a `sorry`-deferred case is not.
6. **Nothing is named `cellLE_zero_const_of_kappa_eq`.** Full success on this task drops ONE
   hypothesis from five schemas; the reserved name stays unclaimed, the room bounds remain, and
   the ordinary window regime `c ≤ n + 1` is covered by nothing in either direction. This is the
   scope the prior cycle's decision settled, and it is recorded in every new docstring rather than
   only here.

## Testing & Validation

- [ ] Every new declaration elaborates with no `sorry` and no new axiom beyond the standard
      `propext`/`Classical.choice`/`Quot.sound` profile (`lean_verify` per name).
- [ ] Every new declaration is warning-free: no `linter.autoImplicit`, no `linter.style.show`, no
      unused variable. CI builds with `--wfail`, so a warning is a failure.
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` builds with every `#guard_msgs`
      axiom pin satisfied, including the new ones.
- [ ] An exact-name sweep confirms `cellLE_zero_const_of_kappa_eq` has no declaration site
      anywhere under `FormalSystem/`.
- [ ] `bash scripts/check-module-invariants.sh` and `bash scripts/typst-sync-check.sh` are green,
      or green modulo enumerated pre-existing findings outside this task's file scope.
- [ ] `bash scripts/check-evidence-probes.sh` is green and no pre-existing probe is newly red.
- [ ] Every `longFile` baseline this task touched sits inside the linter's `N - 200 ≤ lines < N`
      window at the final line count.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` -- the reduction, its `iff`,
  the amount ceiling, the deletion above `z`'s region, and (gate permitting) the clause discharge
  and normalization loop.
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` -- `paramsOk_inflate`,
  `pend_succ_of_fwd`, `objCycleLens_nonempty_of_pend`.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` -- the cell-level restatement,
  and (gate permitting) the discharge plus five hypothesis-free schemas and their theorems.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` -- the updated Requirement (W)
  narrative and the new axiom pins.
- `specs/evidence/` probe plus its `check-evidence-probes.sh` `WIRED` entry, on the obstruction
  branch only.
- Regenerated generated surfaces: `typst/generated/status.typ`, `README.md`'s and
  `FormalSystem/Metalogic/README.md`'s module-inventory blocks.
- `specs/917_forward_slack_witnessed_discharge_or_refutation/summaries/01_forward-slack-witnessed-discharge-summary.md`
  carrying the verdict sentence.

## Rollback/Contingency

Each phase commits once, green, with its generated-surface regeneration staged alongside its Lean
change, so reverting is per-phase `git revert` of a single commit -- no cross-phase unwinding is
needed. Phases 1-4 are independent of the gate's outcome and are kept whatever Phase 5 decides.

If a phase must be abandoned mid-edit with uncommitted work in the tree, take a durable,
non-reverting checkpoint first (`bash .claude/scripts/git-snapshot.sh 917 --no-revert`) and then
decide; only a genuine rollback uses the default reverting mode, per
`context/contracts/recovery.md`'s rollback rung.

Two contingencies are planned rather than improvised. If Phase 5's gate fails, Phases 6 and 7
close `[COMPLETED WITH EXCLUSIONS]` citing its measurement and Phase 8 compiles the obstruction --
the task still lands the reduction, the three scoping records, the cell-level restatement, the
deletion primitive, and a machine-checked refutation of route (d). If Phase 7's per-schema
`hroom` discharge fails for some of the five but not all, the schemas that close are landed and
the remainder are recorded as excluded with the specific arithmetic that did not go through; a
partial drop is an honest result, and the five are not bundled into one all-or-nothing step.
