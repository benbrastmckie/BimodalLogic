# Phase 11.11 Handoff — The Idle-Insertion Walk and Its Four Local Ladder Conditions

- **Task**: 761
- **Phase**: 11.11 (Plan v11, `plans/11_idle-insertion-cascade-restatement.md`)
- **Dispatch**: `dispatch_seq` 33, session `sess_1793823065_4dcf25`
- **Phase marker at close**: `[COMPLETED]`

## Immediate next action

Phase 11.12 — the PIN half (`hpins`, `hn₀`) and the existential
`exists_ladderPath_at_region_of_idle_past` — is the next phase in order. It is the open
construction and carries no hour estimate. Everything it needs from this layer now exists in
`FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`'s Cascade section, and the four
local-condition lemmas are verified to be accepted POSITIONALLY in
`exists_ladderPath_of_walk`'s `hw`/`hidle`/`hpp`/`hpi` slots at
`w := insObj g a l u d`, `c := insCnt g a l u d`.

**Phase 11.12 inherits one premise this phase decided to carry explicitly**: the self-loop
`hself : step (objAt g u) (objAt g u) = true`. See "The primitive decision" below; it is not
optional and it is not discharged anywhere.

## What landed

Fifteen declarations, all in `LadderAgree.lean`'s Cascade section, all with docstrings, all pinned
in the axiom test:

| Declaration | Role |
|-------------|------|
| `insIdx u d` | the index map: identity above `u`, constantly `u` on the collapsed block `[u - d, u]`, `· + d` below it |
| `insObj g a l u d` | the inserted walk's object component, `spliceObj` through `insIdx` |
| `insCnt g a l u d` | its countdown, `spliceCnt` through the same map |
| `insIdx_of_gt`, `insIdx_of_mem_block`, `insIdx_of_lt_block` | the three retraction facts |
| `insIdx_of_ge`, `insIdx_succ_of_lt_block` | two further readings the local conditions rewrite with |
| `insObj_of_gt`, `insCnt_of_gt` | the comparison position carried BY CONSTRUCTION, each carrying `hv : u < v` explicitly |
| `insObj_step` | `hw`, and the ONLY site of the self-loop hypothesis |
| `insCnt_idle` | `hidle` — no case analysis at all |
| `insCnt_pend_pend`, `insCnt_pend_idle` | `hpp`, `hpi` |
| `le_region_start_of_idle` | the regime's idle witness is a legal insertion site |

**No existential, and no pin hypothesis.** `hpins` and `hn₀` for the inserted walk are owed in
full; nothing applies `exists_ladderPath_of_walk` to it. Verified: `grep "∃"` over this phase's
additions to `LadderAgree.lean` returns nothing, and the only `exists_ladderPath_at_region*`
declaration anywhere under `FormalSystem/` is still the landed
`exists_ladderPath_at_region_of_pend_past`.

## The primitive decision: (a), the self-loop as an explicit hypothesis

**Candidate (b) is unavailable at this layer, not merely inconvenient.** It needs `u ≤ u'` at or
below the region start with `objAt g u = objAt g u'` AND an idle position in `[u, u')`, from a
pigeonhole over a finite object type. The premise that pigeonhole needs is MANY idle runs below the
region start; the idle-past regime hypothesis supplies exactly ONE idle position at or below the
splice point, and `[Fintype Q]` does not supply the rest — a finite object type bounds how many
distinct states the positions below can carry, not how many idle runs they contain. The one landed
pigeonhole of this family is in `LadderPin.lean`, ABOVE this module in the import DAG; it is cited
by path in the docstring and is not a proof term (checked mechanically: `LadderAgree.lean`'s import
list is unchanged at `AnchorLayer` and `CounterQuotient`, and the scoped build passes).

**Consequence, for Phases 11.12 and 11.13 to carry forward.** On a general object relation the
self-loop is a genuine additional premise, not a consequence of `IsLadderPath`. So an
UNCONDITIONAL idle-past interface needs more than this plan lands. Phase 11.10's probe exhibits the
whole construction working at a single instance precisely BECAUSE its carrier's `step` is total —
which is why that probe decides REFUTABILITY and never PROVABILITY, and why the witness there is
not evidence that this premise is discharge-able in general.

## The reindexed countdown needed no correction, and that is proved

`insCnt = spliceCnt ∘ insIdx` is not automatically the countdown of `insObj`, because the countdown
is read off the walk (`cntAt_eq_of_obj_eq`) and `insIdx` is not injective. Its one non-injective
place is the collapsed block, where `d + 1` positions go to `u`; there the walk is idle, the
countdown must be `0`, and `spliceCnt g a l u = 0` already holds (`spliceCnt_idle`). `insCnt_idle`
then discharges the idle-zero clause at every position with NO case analysis, and
`insCnt_pend_pend`/`insCnt_pend_idle` the other two with the collapsed block vacuous by
`hu : pend (objAt g u) = false`.

## Deviations

- **Five retraction/reading lemmas where the plan anticipated three.** `insIdx_of_ge` and
  `insIdx_succ_of_lt_block` are needed by the local conditions and are landed as named lemmas
  beside the three rather than inlined. Annotated inline on the corresponding checklist item.
- **`le_region_start_of_idle` does NOT carry the `pinnedRegions` membership clause `s + 1 ≤ a`.**
  The window inequality `a ≤ s + 1 + cntAt g (s + 1)` and `p ≤ a` already place `p` inside the span
  whenever `s < p`, so carrying it would be an unused binder — the `unusedVariables` linter said
  so, and the narrowing is recorded in the lemma's own docstring rather than silently absorbed.
- **A second length ceiling fired that the plan did not anticipate.** The axiom test crossed its own
  in-source `longFile 2000` at 2,081 lines; its baseline is raised in place to `2,100` by the same
  pre-authorized primary remedy the plan names for `LadderAgree.lean`.
- **Two generated README blocks beyond this phase's `Files to modify` rolled.**
  `FormalSystem/Metalogic/README.md` (the `Decidability/` line count) and the root `README.md`
  (two repository metrics) are aggregate roll-ups of the same number and are rewritten by
  `check-module-invariants.sh --emit-inventory`, whose own INV check fails if they go stale. That
  is the 744 cross-set territory the task description leaves to the admission gate; no hand edit was
  made to either, and no other content in them changed.

## Measurements at close

| Quantity | At revision authoring | At close |
|----------|-----------------------|----------|
| `LadderAgree.lean` lines | 2,558 | 2,783 |
| `LadderAgree.lean` in-source `longFile` | 2,600 | 2,900 |
| `KTypeSummaryAxiomTest.lean` lines | not carried | 2,081 |
| `KTypeSummaryAxiomTest.lean` in-source `longFile` | 2,000 | 2,100 |
| Wired evidence probes | 49 | 50 |

`LadderCascade.lean` was NOT created and neither contingency import edge was touched: the primary
remedy (raise the in-source baseline in place) sufficed, and the comment now records why a split
would be wrong — the insertion walk reads `spliceObj`/`spliceCnt` and the same Cascade section's pin
bookkeeping at every step, so a split would put one argument across an import edge.

## Verification at close

| Item | Result |
|------|--------|
| Guarded scoped build of `LadderAgree` | exit 0, 0 errors, 0 warnings |
| Guarded scoped build of `KTypeSummaryAxiomTest` | exit 0, 0 errors, 0 warnings |
| Full-project `lake build` through the guard | exit 0, `Build completed successfully (2895 jobs)`, 0 `error:` |
| No existential landed | `grep "∃"` over the additions returns nothing |
| Four local conditions match `exists_ladderPath_of_walk` positionally | verified MECHANICALLY by a scratch `example` type-ascribing all four; all elaborate |
| Primitive decision recorded | module subsection docstring + axiom-test subsection + phase body |
| Self-loop on an auxiliary only | `hself` appears on `insObj_step` and on none of the three unclaimed signatures |
| Insertion site strictly below comparison position | explicit `hv : u < v` in both pointwise lemmas |
| Splice/pin declarations unmodified | `git diff` names none of the eight listed statements |
| Imports unchanged, no above-DAG proof term | `AnchorLayer` + `CounterQuotient`; the `LadderPin.lean` mention is a docstring path |
| Certificate-freedom grep (extended form) | 0 matches |
| `#print axioms` on all 15 | 3 defs depend on no axioms; the rest a subset of `[propext, Classical.choice, Quot.sound]` |
| `lean-sorry-census.sh` | exit 0, `sorry_count: 0` |
| Module-scoped vacuous grep | 0 |
| Repository vacuous grep / `^axiom ` counts | 1 (unchanged) / 12 and 2 (unchanged vs `HEAD`) |
| `scripts/typst-sync-check.sh` | PASS, all 4 checks green, exit 0 |
| `scripts/readme-lint.sh` | PASS, 0 broken references, exit 0 |
| `scripts/check-evidence-probes.sh` | `PASS  all 50 wired probe(s) compile`, exit 0 |
| `.claude/scripts/check-task-references.sh --quiet` | exit 0 |
| `scripts/check-module-invariants.sh` | every group passes except the single pre-existing `C16` finding — `mem_cellAt_of_shift_of_hasForwardSlack` in `LadderChain.lean:2136`, a file this phase does not touch, unchanged in content and count |

## Plan-revision sentinel

`.plan-revised.json` carries `revised_at: 1793822703`, PRECEDING this dispatch's
`dispatch_start_ts: 1793823203`. No fresh revision landed mid-phase; the Phase 11.11 section was
re-read directly from plan v11 before the first edit.
