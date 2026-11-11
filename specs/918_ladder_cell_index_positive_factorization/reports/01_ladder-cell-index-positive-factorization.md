# Research Report: Task #918

**Task**: 918 - Ladder cell index positive factorization
**Started**: 2026-11-10T23:41:00Z
**Completed**: 2026-11-10T23:58:00Z
**Effort**: ~2-3 implement dispatches for the recommended re-scope; the task AS WRITTEN is not executable (see Decisions)
**Dependencies**: None recorded; supersedes nothing, but reads task 917's closed record as its starting position
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Decidability/RaySummary/`), the wired-probe collection under `specs/evidence/`, task 917's plan/summary, lean-lsp `lean_local_search`; no Mathlib search was needed (every declaration in question is project-local)
**Artifacts**: - `specs/918_ladder_cell_index_positive_factorization/reports/01_ladder-cell-index-positive-factorization.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task description's starting position is stale by roughly thirty wired probes.** It
  describes the record as of `ladder-residue-index-refutation.lean` (Oct 13). Since then
  `CounterQuotient.lean` has landed `kappa`, `ParamsOk` and the four parameter conditions
  `(K1)`-`(K4)`, and `LadderCell.lean` has landed FIVE restricted depth-`0` cell-equality
  schemas. The frontier moved; the task's framing did not.
- **The second admissible outcome is FORECLOSED, by a compiled theorem.** The dispatch offers "a
  compiled refutation that [the two constraints] cannot be jointly met". They *are* jointly met:
  `paramsOk_params` (`CounterQuotient.lean`) proves `ParamsOk` at exhibited parameters
  `(Tcof, Tnof, Pof, Bof)`. `(K1)` is the modulus-multiple-of-period constraint (over
  `prodCycleLens`, `objCycleLens` and `satPeriod`), `(K2)`/`(K4)` the formula-derived threshold
  and clip. No refutation of joint satisfiability can exist.
- **The first admissible outcome has a name and is open.** The positive factorization lemma is
  `cellLE_zero_const_of_kappa_eq` (schema `CellLEZeroConstOfKappaEq`). An exact-name sweep —
  grep over the tree plus `lean_local_search` — finds **no declaration site**; only the five
  hypothesis-strengthened schemas exist.
- **The gap is now a single named obligation, and task 917 just measured its only landed route
  as REFUTED.** `kappa_collision_monotone_or_antitone_named` makes the monotone/antitone slices
  exhaustive over every collision, and both are dispatched as cell EQUALITY under
  `ForwardSlackWitnessed`. So the whole gap is discharging `ForwardSlackWitnessed` at a positive
  amount — and route (d) (deletion inside the first region above `z`'s) is refuted at the pin
  layer by the wired `specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean`.
- **Recommended re-scope (Target A): the ordinary window regime `c ≤ n + 1`.** All five landed
  schemas carry the pending-forever gap `n + 2 ≤ c`; the complementary branch is addressed by NO
  landed inclusion in either direction. It is a required component of the positive lemma however
  `ForwardSlackWitnessed` resolves, it is independent of the refuted pin cascade, and it needs no
  parameter-contract change. The two routes 917 left open (a `(K1)` amendment; a
  register-lowering deletion) are costlier and are assessed below.
- **Do NOT state a tuple index.** The successor design is already chosen and recorded: `kappa` is
  a coordinate of the carrier `D`, not an index, and "a parameter-coupled tuple index stated
  alone is dominated on every obligation, incomplete as a presentation and barred by the
  refutation record."

## Context & Scope

Scope per dispatch: the INDEX only, not the cell-agreement chain, not the refuted stabilization
lemma. Constraint carried in: zero-debt — the outcome must be a theorem or a compiled refutation,
never a `sorry`, a new axiom or a vacuous definition.

What was researched: (1) what the two recorded necessary constraints are now, mechanically, in
source; (2) whether they are jointly satisfiable; (3) what the positive factorization lemma is
called and whether anything claims it; (4) what stands between the landed schemas and it; (5)
which attack routes are already refuted, so none is re-attempted.

Evidence tier: all declaration-level findings are from direct source reads plus grep over the
tree. One `lean_local_search` call returned `index: warming`, so per the readiness rule its
NON-empty result (the five schemas) is usable but an empty result would not have been proof of
absence — the `cellLE_zero_const_of_kappa_eq` absence claim therefore rests on the grep sweep and
on task 917's own independently-run exact-name sweep, not on the LSP call.

## Findings

### Codebase Patterns

**F1. The two constraints the dispatch names are landed, named, and discharged.**

| Dispatch's wording | Landed as | Content |
|---|---|---|
| "threshold must be FORMULA-derived" | `paramsOkK4` + `paramsOkK2` | `2·dBack φ + 1 ≤ B`, `2·dFwd φ + 1 ≤ B`, `2 ≤ B`; `cascadeBound pend φ ≤ Tc`, `satThreshold step lab φ ≤ Tc` |
| "modulus a MULTIPLE OF THE PERIOD of every letter-definable sub-object" | `paramsOkK1` | `∀ l ∈ prodCycleLens step pend lab φ, l ∣ P+1`; `∀ l ∈ objCycleLens step pend, l ∣ P+1`; `satPeriod step lab φ ∣ P+1` |

`ParamsOk` is their conjunction with `(K3)`'s ordering, and `paramsOk_params` discharges all four
at `(Tcof, Tnof, Pof, Bof)` — a theorem, with `Pof.succ = modulusOf` an `lcm`. Note `(K1)` goes
through `prodCycleLens` (the certificate graph's cycle lengths on saturated classes), i.e. the
product of the object with the closure, *strictly stronger* than the "letter-definable
sub-object" phrasing of the task description. That is why no third period-shaped mechanism is
available: a path constraint a closure formula can express lives in the product, and the product's
cycle lengths already divide `P + 1`.

**F2. The positive factorization lemma's identity and status.** The reserved name is
`cellLE_zero_const_of_kappa_eq`, the schema `CellLEZeroConstOfKappaEq`. Claimed by nothing.
What exists (all in `LadderCell.lean`, all strictly stronger in hypotheses, all concluding cell
EQUALITY):

1. `cellLE_zero_const_of_kappa_eq_of_forwardSlack` — equal-register slice (`n = n'`).
2. `cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack` — common-shift displacement, no
   equal-register hypothesis, doubled regime amount plus a room bound.
3. `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` — `MonotoneCollisionDisplacement`.
4. `cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack` — `AntitoneCollisionDisplacement`.
5. `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` — the bounded sub-slice,
   carrying exactly ONE `ForwardSlackWitnessed` (the upward amount is literally `0` there and
   `forwardSlackWitnessed_zero` discharges it).

**F3. The gap is exactly one obligation.** `kappa_collision_monotone_or_antitone_named` makes
monotone ∪ antitone exhaustive over `kappa`-collisions with no third case, and (3) and (4)
dispatch both slices. So nothing separates the landed schemas from the reserved statement except
the hypotheses they carry — principally `ForwardSlackWitnessed` at a positive amount, plus the
room bounds and the pending-forever gap. The README states this in the same terms: "whether a
`ForwardSlackWitnessed` hypothesis at a POSITIVE amount is satisfiable at any state the induction
one layer up actually reaches" is open and claimed in neither direction.

**F4. `ForwardSlackWitnessed` is now a checkable condition on ONE region.** By
`forwardSlackWitnessed_iff_next_region_cnt_le` (cell level) and
`hasForwardSlack_iff_next_region_cnt_le` (path level), the condition restates as: every type the
cell at `x` realizes is realized there by some path whose FIRST REGION above `z`'s region has
countdown at most `n + cntAt g z + I − l`, with `I` the separating idle run's length. Nothing
about the register survives on the right. The automatic bound from `nxtAt_lipschitz_two_sided` is
`n + cntAt g z + I`, so the condition asks for exactly `l` more than the path supplies — the
climbing-register path (`ClimbWitness`, register `+1` per step) attains the bound and violates the
condition by exactly `l`.

**F5. The obvious attack is already landed AND already refuted.** The deletion primitive for a
type-respecting block inside the next region, with the register at `z` held, is
`exists_deleted_ladderPath_of_next_region_nxt` (`LadderChain.lean`, `section DelNxt`). It takes
exactly two clauses: `hanch` (pins at or above the block) and `hstraddle` (pairs straddling it).
Both FAIL in the pending-forever regime at countdown `≥ Tc` under `ParamsOk`, by exactly `l` and
exactly `2·l`. `no_deleted_ladderPath_of_straddle_break` makes it a theorem rather than a witness
artefact: on a path whose straddling pin pair saturates compatibility the primitive's own
CONCLUSION is false, because any deleted path would itself be a ladder path and
`pinCompat_of_ladderPath` binds its pins at the broken positions. `obs_no_admissible_block`
refutes every block that path's next region admits. And `(K2)`'s budget cannot pay: the saturated
configuration ATTAINS `cascadeBound`'s recurrence `a(k+1) ≤ 2·a k + J + 1` with equality — the
doubling cascade I re-derived independently before finding this record is exactly the compiled
obstruction.

**F6. What `ForwardSlackWitnessed` is NOT.** It is not refuted. It is an existential over paths,
so a saturated path may still realize each of its types via some other path with slack. Only
route (d) is closed. The two routes task 917 left open, named rather than claimed:

- **Route (e)** — a `(K1)` AMENDMENT constraining the length of a type-respecting block that
  SPANS a region start. This would reopen the spanning-block device, which is refuted in both
  directions *as a consequence of the current parameter conditions*. Cost: it alters the parameter
  contract every wired probe discharges — blast radius is the whole 53-probe collection plus
  `paramsOk_params`.
- **Route (f)** — a register-LOWERING deletion. Adjacent to the landed
  `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`, but note the arithmetic:
  `hanch` needs `B ≤ N + (p − z) − l` where `N = nxtAt g z = n` is pinned by the state, so it
  cannot be raised at `z`; relief must come from lowering the UPPER pin `B`, which re-enters the
  doubling cascade `hstraddle` closes. This route should be GATED arithmetically before any line
  is landed.

**F7. An untouched branch, independent of all of the above.** Every one of the five schemas
carries the pending-forever gap `n + 2 ≤ c`. The ORDINARY WINDOW regime `c ≤ n + 1` is addressed
by no landed inclusion in either direction — stated as a surviving restriction in
`forwardSlackWitnessed_iff_next_region_cnt_le`'s own docstring and repeated in 917's follow-ups.
This branch does not go through `ForwardSlackWitnessed`, the pin cascade, or the parameter
contract. By `pend_past_of_nxtAt_lt`, the gap hypothesis is what restricts to paths pending at
every earlier position; in the complementary regime the compared position has an idle position in
its past, where the BACKWARD window `cntAt_le_nxtAt_succ_of_idle_past` (`LadderAgree.lean`) is
available and the countdown is bounded by `nxtAt + 1` — i.e. the regime where the two counters are
*tied together* rather than free, which is the structurally easier side.

**F8. Supporting machinery already available for any route.** `tpOf_eq_delIdx_of_tpOf_eq` and
`tpOf_eq_spliceIdx_of_tpOf_eq` (type held across a deletion/duplication of a type-respecting
block, needing only stab-freeness, NOT pend-past — the pend-past hypotheses sit only on the
ADMISSIBILITY halves); `exists_typeBlock_of_budget_le_cnt(_within)` (the type pigeonhole, generic
in the position, block inside that position's region, length `≤ |Q| · 2^|cl φ|`);
`drift_extension_of_pins` and `exists_ladderPath_of_walk(_nxt_at)` (a 1-Lipschitz-compatible pin
family extends to a `Drift` register; a walk plus its forced countdown lifts to a path);
`paramsOk_inflate` (take any multiple of `P + 1` without re-deriving `ParamsOk`);
`two_pow_card_prodState_le_Tc` (`(K2)`'s exponential reading);
`cntAt_eq_nxtAt_of_idle_pend` (the pin equation) and `nxtAt_le_cntAt_add_of_next_region` (the
forward window). `ladderModel`'s valuation reads the object component only, so for stab-free `φ`
`tpOf` is a function of the OBJECT WALK alone — the fact every surgery lemma above rests on.

### External Resources

No external search was warranted: every object in question is project-local, and the two
literature anchors already cited by the record (HWZ 2000 Lemma 17 for the duplication/deletion
type lemmas; HWZ 2000 Definition 12's quasimodel for the frame scheme) are already consumed in
source with their UNVERIFIED-summary provenance flagged there. The literature briefing's
`hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl` entry is the HWZ source and is
marked `provenance_fidelity: unverified_summary`; it orients shape and sources no claim, exactly
as the existing module docstrings already say. Nothing in this report cites it.

### Recommendations

A sorry-free path exists for Target A and (conditionally) for Target B; no route requires a
`sorry`, a new axiom, or a vacuous definition. Recommended phase shape:

1. **Target A (recommended) — the ordinary window regime `c ≤ n + 1`.**
   - Phase 1: a GATE, arithmetic only, in the style that worked for 917 (two layers: a
     scale-invariant arithmetic measurement, then a path-level object). Measure whether, in the
     regime `c ≤ n + 1` at countdown `≥ Tc` under `ParamsOk`, a `kappa`-collision's two
     displacement coordinates can be moved by a common multiple of `P + 1` with the backward
     window `cntAt_le_nxtAt_succ_of_idle_past` supplying the bound the pending-forever gap
     supplies on the other side. Record the verdict before landing anything.
   - Phase 2 (on PASS): the regime's upward and downward cell inclusions, mirroring
     `cellAt_subset_of_shift_of_pend_past` / `..._rev` but with the idle-past hypothesis in place
     of the pending-forever one.
   - Phase 3 (on PASS): the schema + theorem, under its own name, exhaustive against the
     pending-forever schemas via a compiled dichotomy on `c ≤ n + 1` vs `n + 2 ≤ c`.
   - Phase 2' (on FAIL): a wired probe recording the obstruction, in the shape
     `pin-cascade-straddle.lean` uses — a theorem for the obstruction, a concrete object for
     non-vacuity, and exhaustion over the choices the construction admits.
   - Either branch is a complete, reportable outcome. Neither touches `ForwardSlackWitnessed`,
     `ParamsOk`, or any wired probe's contract.
2. **Target B (if Target A closes cheaply, or as a second task) — route (f)**, the
   register-lowering deletion, GATED first per F6: measure `hanch`/`hstraddle` with the upper pin
   freed, before landing a primitive. Do not land the primitive on the expectation that the gate
   passes; 917's FAIL branch is the precedent for how a failing gate is recorded.
3. **Target C — route (e), the `(K1)` amendment: NOT recommended for this task.** It changes the
   parameter contract `paramsOk_params` and 53 wired probes discharge. If it is ever taken it
   should be its own task with the probe-collection re-verification in its own phase list.
4. **Prohibited for this task, on the record's own authority**: re-attempting route (d) (the
   next-region deletion with the register held at `z`); stating a tuple index at any parameters;
   re-attempting the stabilization lemma, the clipped-coordinate index family, the bounded-carrier
   route, or the object-exhibited-parameter residue index.

## Decisions

- **The task as written is not executable, and this is recorded rather than worked around.**
  Outcome (b) is foreclosed by `paramsOk_params`; outcome (a) is the reserved
  `cellLE_zero_const_of_kappa_eq`, whose remaining gap is the obligation task 917 closed its only
  landed route against three commits ago. A plan that restated the dispatch's two outcomes
  verbatim would be planning work that is either impossible or already measured.
- **The positive lemma is identified with `cellLE_zero_const_of_kappa_eq` rather than with a
  tuple index.** The dispatch asks for "a positive factorization lemma for the index"; the record
  has since decided that the cell's presentation is a set-valued per-state datum over the quotient
  `K`, with the factorization lemma for `K` a COROLLARY of the fibre equation, never its
  hypothesis. Honouring the dispatch's words over the record's decision would re-introduce the
  barred tuple-index shape.
- **No third period-shaped mechanism is pursued.** I derived one candidate independently (a
  bounded-`X`-depth path invariant forcing a closed-walk period that no letter-definable state-set
  restriction exhibits — the alternating 2-cycle/3-cycle giving period 5 against an lcm of 6) and
  then found it already covered: `(K1)`'s `prodCycleLens` conjunct quantifies the certificate
  graph's cycle lengths on saturated classes, i.e. the object-closure product, which subsumes
  every path constraint a closure formula can express. Recorded here so the next reader does not
  spend the same cycles.
- **Evidence tier announced rather than assumed.** The `lean_local_search` index reported
  `warming`; the absence claim for `cellLE_zero_const_of_kappa_eq` is therefore sourced to grep
  plus 917's own exact-name sweep, not to the LSP.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Target A's gate FAILS and the phase list has nothing to land | The plan must carry an explicit FAIL branch that lands a wired probe, as 917's Phase 5-8 did; a zero-line PASS branch is a recorded result, not a skipped task |
| Concurrency with the cell-agreement siblings (`LadderAgree.lean`, `LadderChain.lean`, `LadderCell.lean` are hot — three files changed Nov 10) | Target A's writes land in `LadderCell.lean` (new schema) and read-only from `LadderAgree.lean`; the dispatch asserts a different file set from the siblings, but the plan should state its territory explicitly and expect `longFile` baseline collisions |
| A `(K1)`/`ParamsOk` change creeps in via a "small" amendment | Target C is explicitly out of scope; any phase that would touch `paramsOkK1` must stop and escalate |
| The backward window `cntAt_le_nxtAt_succ_of_idle_past` turns out too weak to replace the pending-forever gap | That is precisely what Phase 1's gate measures, before any proof is attempted |
| `check-module-invariants.sh` C16 is already failing on `LadderPump.lean` from a sibling task | Pre-existing and attributed in 917's record; enumerate and attribute, do not edit an out-of-scope file |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This is a statement-identification and
  route-elimination research dispatch, not a proof-search one: no goal state was opened, so
  `lean_multi_attempt` and `lean_hammer_premise` had nothing to measure. The arithmetic layers the
  recommended phases need are `omega`-shaped by construction, as every landed gate in
  `counter-lift-gates.lean` and `pin-cascade-straddle.lean` already is.

## Context Extension Recommendations

- **Topic**: Dispatch descriptions that pin a "VERIFIED STARTING POSITION" against a fast-moving
  compiled record.
- **Gap**: Task 918's description was written against the 15th wired probe and dispatched against
  the 53rd. Both of its admissible outcomes were resolved or relocated in the interval — one
  foreclosed by a theorem, the other renamed and narrowed — yet the description reads as current
  because every sentence in it was true when written.
- **Recommendation**: add a short subsection to `context/project/lean4/patterns/` (or extend
  `plan-authoring-gate-collisions.md`) stating that a Lean research dispatch whose description
  cites named compiled evidence MUST re-verify each cited name's current status in source before
  scoping, and MUST report a stale starting position as a finding rather than planning against it.
  The mechanical check is cheap: grep each named declaration and read the owning module's
  docstring, which in this tree carries the current verdict.

## Appendix

### Search queries and sweeps used

- `grep -rn "cellLE_zero_const_of_kappa_eq\b" --include=*.lean .` — 10 hits, all prose; no
  declaration site.
- `mcp__lean-lsp__lean_local_search "cellLE_zero_const_of_kappa_eq"` — 5 items, all the
  `_of_forwardSlack` variants; `index: warming`, `sources_searched: [source_text, symbol_index]`.
- `grep -n "^\(def\|theorem\|abbrev\|structure\) " LadderCell.lean` — the schema/theorem inventory
  in F2.
- `grep -rn "theorem exists_deleted_ladderPath\|theorem exists_spliced_ladderPath\|theorem drift_extension_of_pins\|theorem exists_ladderPath_of_walk\b\|theorem exists_rlad_hist_of_walk"` —
  the surgery-primitive inventory in F8.

### Files read (absolute paths)

- `/home/benjamin/Projects/BimodalLogic/specs/918_ladder_cell_index_positive_factorization/.dispatch/10.md`
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean`
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` (`Drift`, `Count`, `Rlad`, branching, `drift_extension_of_pins`)
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` (`tpOf`, `cellAt`)
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (`kappa`, `Bof`, `(K1)`-`(K4)`, `ParamsOk`, `paramsOk_params`)
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` (`ForwardSlackWitnessed`, `forwardSlackWitnessed_iff_next_region_cnt_le`, `forwardSlackWitnessed_zero`, the five schemas, the collision dichotomy)
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` (`HasForwardSlack`, `exists_deleted_ladderPath_of_next_region_nxt` and its verdict docstring)
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` (`tpOf_eq_delIdx_of_tpOf_eq`, the type pigeonhole, `exists_deleted_ladderPath_of_pend_past`, `nxtAt_le_cntAt_add_of_next_region`)
- `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/RaySummary/README.md` (requirement (W) frontier)
- `/home/benjamin/Projects/BimodalLogic/specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean` (header)
- `/home/benjamin/Projects/BimodalLogic/specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` (header)
- `/home/benjamin/Projects/BimodalLogic/specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean` (header)
- `/home/benjamin/Projects/BimodalLogic/specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` (`region_doubling`, `iter_doubling`)
- `/home/benjamin/Projects/BimodalLogic/specs/evidence/forward-slack-pin-cascade/pin-cascade-straddle.lean` (header)
- `/home/benjamin/Projects/BimodalLogic/specs/917_forward_slack_witnessed_discharge_or_refutation/summaries/01_forward-slack-witnessed-discharge-summary.md`
