# Implementation Plan: Task #909

- **Task**: 909 - Construct the register-LOWERING deletion that would drop the equal-register hypothesis `n = n'` from `cellLE_zero_const_of_kappa_eq_of_forwardSlack` on branch 2 of the collision case split
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: None (no `research_artifact` on this dispatch; see "Why no research round" below)
- **Artifacts**: plans/01_register-lowering-deletion-common-shift.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Land the register-LOWERING exact-shift deletion the `RaySummary/README.md` record names as one
of its two open routes, and spend it on the one thing it buys: the COMMON-SHIFT sub-regime's
DOWNWARD cell inclusion, and hence a branch-2 depth-`0` cell-equality schema that carries NO
equal-register hypothesis. Four new declarations plus one re-derivation. Done means: the
register-lowering deletion compiles with the register carried DOWN by exactly the same
`m · (P + 1)` as the countdown; the two cell-level consequences (path-level membership, then the
state-level inclusion under `ForwardSlackWitnessed`) compile; the branch-2 schema is proved as
cell EQUALITY by `Set.Subset.antisymm` against the landed upward
`cellAt_subset_of_common_shift_of_pend_past`; the reserved name `cellLE_zero_const_of_kappa_eq`
is still claimed by nothing; and `RaySummary/README.md`'s "two routes left open" paragraph no
longer asserts this route open.

### The construction, named before it is scheduled

The task description's item (3) names the forward register cascade as the obstruction, and the
arithmetic of that cascade is what makes the construction a bookkeeping problem rather than a
refutation problem. The landed anchor machinery already takes the anchor POSITION and the anchor
VALUE as free parameters: `exists_deleted_ladderPath_of_pend_past_nxt` takes `(z : ℤ) (n : ℕ)`
and an anchor clause `hanch`, and `anchor_clause_of_first_region_start` collapses that clause,
at any anchor value, to one inequality at the first region start above `z`'s region — which is
exactly `HasForwardSlack`'s shape. Lowering the anchor value from `nxtAt g z` to `n₀` therefore
costs precisely `nxtAt g z − n₀` of additional forward slack in the upper direction of that one
inequality, and nothing in the lower direction (the lower direction only gets easier as the
anchor falls). The deficit the description measures as "exactly `l`, and `m · (P + 1)` when
iterated" is that cost.

So the route is: generalize the landed up-first exact-shift theorem
`exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` over the target register, carrying
a parameter `k` with `n₀ + k = nxtAt g z` and demanding forward slack at `m · (P + 1) + k`
instead of `m · (P + 1)`. At `k = 0` the generalized statement IS the landed one, hypothesis for
hypothesis, which is why Phase 2 can retire the landed proof body to a one-line instance instead
of leaving a 140-line near-duplicate in the module. At the cell level the common shift is the
instance `n₀ := n`, `k := m · (P + 1)`, so the slack amount a consumer must supply is
`m · (P + 1) + m · (P + 1)` and the room hypothesis is `n + (m · (P + 1) + m · (P + 1)) ≤ c`.

Three facts about this route are worth stating up front because they bound what the plan may
claim:

1. **The regime hypothesis is not removable, and is not weakened here.** `HasForwardSlack` is a
   property of a PATH, refuted at the state level by the compiled
   `ClimbWitness.hasForwardSlack_refuted_unconditional`. The downward statements below are
   therefore stated on the witnessing path and lifted to the state level only through
   `ForwardSlackWitnessed`, exactly as the landed `cellAt_subset_of_shift_of_pend_past_rev` is.
   Nothing here asserts the regime holds anywhere.
2. **The room hypothesis genuinely strengthens.** The landed equal-register downward inclusion
   runs on `n + 2 ≤ c` alone, because the register is held and the gap at the higher state
   collapses to `n ≤ c`. The common shift displaces the register too, so the gap at the higher
   state is `(n + m · (P + 1)) + m · (P + 1) ≤ c + m · (P + 1)`, i.e. `n + m · (P + 1) ≤ c`, and
   the lowered anchor costs another `m · (P + 1)`. Both `n + 2 ≤ c` and
   `n + (m · (P + 1) + m · (P + 1)) ≤ c` are therefore carried as named hypotheses; neither
   implies the other (the second is vacuous at `m = 0`, the first is not).
3. **The saturated-gap residue is untouched.** `kappa_collision_two_regimes_refuted_of_pend_gap`
   compiles that branch 3 survives inside the pending-forever regime above the threshold. This
   plan addresses branch 2 only, as the task's SCOPE paragraph requires, and the branch-2 schema
   below takes the common-shift displacement as an explicit hypothesis rather than dispatching on
   `kappa_collision_regimes`.

### Why no research round

This dispatch carries no `research_artifact`. The opening assessment was run and a research
round was NOT requested: the task description is a specification, not a research question — it
names the blocking asymmetry, the obstruction, the landed objects on both sides of it, and the
scope boundary — and everything else the plan needed was settled by direct reads of
`LadderCell.lean`, `LadderChain.lean`, `LadderPump.lean`, `RaySummary/README.md` and
`.claude/context/project/lean4/patterns/plan-authoring-gate-collisions.md` within this dispatch.
In particular, the parametrization that makes the construction go through (the free anchor value
of `exists_deleted_ladderPath_of_pend_past_nxt` and the free anchor value of
`anchor_clause_of_first_region_start`) is read off the landed signatures, not inferred.

### Prior Plan Reference

No prior plan. `specs/909_.../plans/` was empty at authoring time.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no `roadmap_flag` was set, so no roadmap
phases are scheduled and `specs/ROADMAP.md` is not read or written by any phase.

## Goals & Non-Goals

**Goals**:
- `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` -- the up-first
  exact-shift deletion generalized over the target register: the countdown lowered by exactly
  `m · (P + 1)` and the register lowered to a prescribed `n₀`, under forward slack at
  `m · (P + 1) + k` where `n₀ + k = nxtAt g z`.
- `mem_cellAt_of_common_shift_of_hasForwardSlack_exact` -- the DOWNWARD cell inclusion on the
  witnessing path for the COMMON SHIFT: a type realized at `(q, c + m · (P + 1), n + m · (P + 1))`
  by a path carrying the regime at `m · (P + 1) + m · (P + 1)` is realized at `(q, c, n)`.
- `cellAt_subset_of_common_shift_of_pend_past_rev` -- the same inclusion at the STATE level,
  under `ForwardSlackWitnessed` of the higher pair.
- `CellLEZeroConstOfKappaEqCommonShiftForwardSlack` -- the branch-2 depth-`0` cell-equality
  schema, with the common-shift displacement in place of the equal-register hypothesis.
- `cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack` -- that schema is a theorem at
  every parameter tuple `ParamsOk` admits.

**Non-Goals**:
- The reserved name `cellLE_zero_const_of_kappa_eq`. It stays reserved and claimed by nothing;
  no phase lands anything under it, and no phase alters its truth value in either direction.
- The saturated-gap residue (branch 3 of `kappa_collision_regimes`). A sibling follow-up owns it;
  this plan's schema does not reach it and does not claim to.
- Dropping the equal-register hypothesis from `CellLEZeroConstOfKappaEqForwardSlack` itself.
  That landed schema's statement is pinned and is left exactly as it stands; the branch-2 schema
  is a NEW, differently-hypothesised statement alongside it.
- Weakening `HasForwardSlack`, or stating any state-level per-path register regime. Refuted by
  `ClimbWitness.hasForwardSlack_refuted_unconditional`.
- An iterated deletion in `LadderPump.lean`. The task description records its absence as part of
  the starting position; the overshoot loop in `LadderChain.lean` already performs the iteration
  this construction consumes, so no new pump-layer declaration is needed and `LadderPump.lean`
  is not modified.
- Any `(K1)` amendment, any change to the parameter contract, and any re-opening of the
  spanning-block device.

## Decisions

- **The register-lowering assembly lands in `LadderChain.lean`, not `LadderCell.lean`.** It is a
  path-level assembly consuming the overshoot loop, the raise, `hasForwardSlack_raise`,
  `anchor_clause_of_first_region_start` and `exists_deleted_ladderPath_of_pend_past_nxt` — every
  one of which lives in `LadderChain.lean`'s own `DelNxtIter`/`Slack` sections. `LadderCell.lean`'s
  module contract says it "imports `LadderChain.lean` alone and says nothing about pumps or pins
  beyond what that module already landed", so putting a new path-level assembly there would
  contradict its own stated contract. The cost of this decision is that `LadderChain.lean` is one
  file beyond the task's declared `file_scope`; it is declared honestly in Phase 1's
  `Files to modify` and carries no territory conflict (the only concurrent sibling, task 915,
  declares `specs/literature-index.json` alone).
- **The landed up-first theorem is re-derived, not duplicated.** Phase 2 replaces its proof body
  with the `k = 0` instance of the Phase 1 generalization. Its SIGNATURE is untouched — the
  statement is a pinned Challenge statement from an earlier round, and `plan-compliance.md`'s
  Statement Fidelity section governs signatures, not proof bodies. Phase 2 is contingent: if the
  `k = 0` instance does not reduce to the landed statement hypothesis-for-hypothesis, the landed
  proof is left exactly as it stands and the near-duplication is recorded rather than forced.
- **The room hypothesis is bundled into the schema's witnessing clauses.** In
  `CellLEZeroConstOfKappaEqCommonShiftForwardSlack` the displacement `m` is existentially bound,
  so the room bound `n + (m · (P + 1) + m · (P + 1)) ≤ c` cannot be stated outside the clause
  that already quantifies `m`. It is carried as a conjunct of each direction's witnessing clause.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The pinned Challenge signature for Phase 1 carries the wrong slack or room amount, making it unprovable as written | H | M | The amounts are derived in "The construction, named before it is scheduled" from the landed `hslack₂`/`hfirst`/`hanch` chain inside `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`, not guessed. If the derivation is off, `plan-compliance.md` forbids silently substituting a weaker statement: mark the phase `[BLOCKED]`, report the exact goal state and the deficit, and escalate for a `/revise`. |
| The `k = 0` instance does not recover the landed up-first statement exactly, so Phase 2 cannot close | M | M | Phase 2 is explicitly contingent with a stated fallback (leave the landed proof untouched, record the duplication, close `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record). No later phase depends on Phase 2's success. |
| The pre-commit hook refuses the first Lean-touching commit because `typst/generated/status.typ` drifted | M | H | Surface (b) of `plan-authoring-gate-collisions.md` Condition 1 is BLOCKING and cannot be deferred. Every Lean-touching phase (1-5) runs `lake build && bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in its own commit, and carries that path in its own `Files to modify`. |
| A verify-deploy gate is red for reasons unrelated to this task (the dispatch context reports the deployed `.claude/` tree STALE for core, lean, literature and memory) | M | H | Condition 2 of `plan-authoring-gate-collisions.md`: the final phase's criterion is phrased to distinguish findings naming this task's own touched files from the tree's standing baseline, never as a bare "the gate passes". The staleness is pre-existing and is NOT remedied by this task (no phase hand-patches `.claude/**`). |
| An unused-binder linter (`linter.unusedVariables` at the frontend, Batteries' `unusedArguments` over the compiled environment) fires on the branch-2 theorem's unread collision hypothesis | L | M | The schema's collision hypothesis is discarded at `intro` with a `-` pattern rather than bound to a name, so no unused local is created. If the env linter fires anyway, the remedy is a hand-added row in `scripts/nolints.json` (never `lake exe runLinter --update`, which rewrites the whole ledger) — recorded here rather than discovered mid-phase. |
| Line-count drift leaves the module-inventory blocks stale (surface (a)) | L | H | Final phase deliverable: edit the Description cells first, then `bash scripts/check-module-invariants.sh --emit-inventory` (which preserves existing Description text and refreshes only the counts), then `--emit-inventory --check`. |
| The new `LadderChain.lean` declaration is read as reviving a refuted claim | M | L | It does not touch `HasForwardSlack`'s necessity, the tight-chain non-liftability probe, or the reserved name. Phase 5's README edit states the boundary explicitly: the route is now landed for branch 2 and still does not reach the saturated residue. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential by design:
every phase stages `typst/generated/status.typ` (the blocking pre-commit surface), so two phases
running concurrently would collide on that one generated file even when their Lean edits are in
different modules.

### Phase 1: The Register-Lowering Up-First Exact-Shift Deletion [COMPLETED]

**Goal**: `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` compiles in
`LadderChain.lean`'s `DelNxtIter` section at the pinned signature: the countdown lowered by
exactly `m · (P + 1)` and the register lowered to a prescribed `n₀`.

**Tasks**:
- [x] Add the declaration to `LadderChain.lean`'s `section DelNxtIter`, immediately before the
      landed `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`, at the signature
      pinned in `## Lean Challenge Statements` below. *(deviation: altered — landed at the pinned
      signature but placed immediately AFTER the landed theorem, because the implemented route
      CONSUMES that theorem; placing it before would be a forward reference)*
- [x] Build the proof as the landed up-first spine with two changes and no others: (i) the final
      `exists_deleted_ladderPath_of_pend_past_nxt` call takes the anchor value `n₀` in place of
      `nxtAt g z`; (ii) the `hfirst` step that feeds `anchor_clause_of_first_region_start` closes
      against `n₀` by `omega` from `hslack₂` at the amount `r * l + k`, `hk : n₀ + k = nxtAt g z`
      and the gap. Steps (i)-(iii) of the landed ordering — the pigeonhole block, the raise by
      `budget` copies, the overshoot loop above the run — are reused unchanged. *(deviation:
      altered — this spine is NOT implementable with the landed loop: see the task note below)*

      **PLAN-SPINE DEVIATION (recorded, not silent).** The spine above cannot be built without
      modifying a landed declaration. `exists_deleted_ladderPath_overshoot_of_pend_past` pins its
      slack amount to the shape `R * l + budget * l` AT register `nxtAt g z`, in its hypothesis
      and in its conclusion alike; its output is therefore `HasForwardSlack g₂ z (r * l)
      (nxtAt g z)` no matter what the input carried, and the extra `k` is destroyed. It cannot be
      recovered afterwards: slack transport is exact in both directions
      (`hasForwardSlack_del`/`hasForwardSlack_raise`), and `k` can only be folded into the loop's
      amount shape when `l ∣ k`, which an arbitrary `k` does not satisfy. The implemented route
      instead performs the lowering BEFORE the surgery, at no extra cost and with the landed
      theorem reused as a black box: `exists_ladderPath_of_walk_nxt_at` re-lifts `g`'s OWN object
      walk and countdown with the anchor at `n₀`, whose single pin clause is exactly
      `anchor_clause_of_first_region_start` at deleted length `0` — the one inequality where the
      `k` of the lowering is spent; `HasForwardSlack` then transfers to the re-lift because a
      region start's countdown is the register's value at the idle position before it, so the
      regime depends on the walk and countdown alone; and the landed held-register exact-shift
      theorem applied to the re-lift yields this conclusion, with the realized type returning to
      `g` through `tpOf_stabFree_eq_of_objAt_eq` on the shared walk. The PINNED SIGNATURE is
      landed byte-for-byte; the deviation is in the internal decomposition only.
- [ ] Thread the extra `k` through the loop's slack bookkeeping: the raise supplies
      `budget · l` (`hasForwardSlack_raise`), the loop consumes `t · l`, and the remainder
      deletion needs `r * l + k`, so the input amount is `m * (P + 1) + k`. Confirm the
      arithmetic at the `hamt`/`hslack₂` rewrite rather than assuming it. *(deviation: skipped —
      the arithmetic was confirmed and REFUTES this step: the loop's amount shape is pinned, so
      the `+ k` cannot pass through it. Superseded by the re-lift route above.)*
- [x] Write the docstring in the module's established voice: name the two changed steps, say that
      the lowered anchor costs exactly `k` of additional slack in the upper anchor direction and
      nothing in the lower one, and name `k = 0` as recovering the landed statement. *(deviation:
      altered — the docstring names the re-lift construction actually used instead of "the two
      changed steps", and does say both the exact-`k` cost and the `k = 0` recovery)*
- [x] `lake build` the module scoped, then
      `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` with the
      Lean change in one commit.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly ONE new declaration and modifies no existing
declaration's signature or body in `LadderChain.lean`; confirm at implementation time with
`git diff --stat` on the module plus a `git diff` read-through showing only additions inside
`section DelNxtIter`.

**Scope Hypothesis outcome**: CONFIRMED for the declaration count (exactly one new declaration,
no existing declaration's signature or body touched). PARTIALLY REFUTED on "only additions": one
existing non-declaration line changed, the module's `set_option linter.style.longFile` baseline,
raised from `2300` to `2500` because the module is now 2385 lines. That baseline is the recorded
length ceiling `check-module-invariants.sh` treats as an exception rather than a linter disable.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
covers a purely additive declaration in one module with no externally visible signature change.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - new declaration in `section DelNxtIter`; this file is one path beyond the task's declared `file_scope`, declared here deliberately (see `## Decisions`)
- `typst/generated/status.typ` - regenerated line counts; blocking pre-commit surface, staged in this phase's own commit

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
  exits 0 with no `sorry` and no error.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`
  reports no `sorryAx` and no custom axiom beyond the module's own recorded profile.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit is attempted.

---

### Phase 2: Retire the Landed Up-First Proof to the `k = 0` Instance (CONTINGENT) [COMPLETED WITH EXCLUSIONS]

**Goal**: `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` keeps its signature
byte-for-byte and gets a one-line proof body: the `k = 0`, `n₀ := nxtAt g z` instance of Phase 1's
declaration. If that instance does not reduce exactly, the landed proof is left untouched.

**Tasks**:
- [x] Attempt the instance: `n₀ := nxtAt g z`, `k := 0`, `hk := by omega`. Check that the
      generalized `hgap` (`nxtAt g z + m * (P + 1) + k ≤ cntAt g z`) and `hslack`
      (`HasForwardSlack g z (m * (P + 1) + k) (nxtAt g z)`) reduce to the landed binders at
      `k = 0`, with `Nat.add_zero` rewrites only. *(deviation: altered — the binders DO reduce at
      `k = 0`, but the instance cannot be taken: Phase 1's declaration is PROVED FROM the landed
      theorem, so retiring the landed proof to it is circular)*
- [ ] If it reduces: replace the proof body, leaving the signature lines untouched. *(deviation:
      skipped — would be circular; see the Reasoned Exclusions record below)*
- [x] If it does not reduce: STOP. Leave the landed declaration exactly as it stands, close this
      phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record naming the
      specific binder that failed to reduce and the goal state observed, and proceed to Phase 3.
      Do NOT alter the landed signature to make the instance fit — that is exactly the
      same-name-different-signature drift `plan-compliance.md`'s Statement Fidelity section
      forbids. *(the stated fallback was taken, for a different reason than anticipated:
      circularity, not binder mismatch)*
- [x] Either way: `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the Lean change. *(deviation: skipped — this phase makes
      no Lean change, so no line counts moved and there is nothing to regenerate or stage)*

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the landed theorem's signature is unchanged by this phase; confirm with
`git diff` on `LadderChain.lean` showing changed lines strictly BELOW the landed `:=`/`by` line
and none within its binder list or conclusion.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`
covers a proof-body-only change whose signature is verified unchanged by the `git diff` above, so
no downstream consumer's elaboration can be affected.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - proof body of `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` only; this declaration exists at authoring time (confirmed by read) — if it has moved or been renamed by the time this phase runs, treat the phase as `[BLOCKED]` and escalate rather than relocating the edit
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- The scoped `lake build` above exits 0.
- `git diff` on the module confirms the landed signature lines are unchanged.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check` is run and its verdict recorded; per
  `plan-compliance.md` the verdict is ADVISORY — a drift finding is investigated, never treated
  as an automatic failure.

**Verification outcome**: the full-project `lake build` closing Phase 1 is the last build before
this phase and no Lean file was edited here, so the build evidence carries over unchanged (exit
0, zero `error:` lines, `.olean` newer than source for every touched module). `git diff` on
`LadderChain.lean` shows no change in this phase at all, so the landed signature is trivially
unchanged. `lean-challenge-snapshot.sh --check` was NOT run: no Challenge snapshot exists for
this task (`specs/909_.../challenge/` is absent — the snapshot is created at plan time and this
dispatch's plan round did not create one), so there is no recorded baseline to compare against.
Recorded as absent rather than as a pass or a drift.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Replacing `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past`'s proof body with the `k = 0`, `n₀ := nxtAt g z` instance of Phase 1's declaration | CIRCULAR. The plan assumed Phase 1 would be built as an independent copy of the landed spine with a lowered final anchor, making the landed theorem a specialization of it. That spine is not implementable with the landed overshoot loop (which pins its slack amount to `R * l + budget * l` at register `nxtAt g z` and so destroys the extra `k`), so Phase 1 was instead landed by REDUCTION to the landed theorem: it re-lifts the walk with the anchor at `n₀` and then applies `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` as a black box. Deriving the landed theorem from Phase 1's declaration would therefore make the landed theorem depend on itself. | `LadderChain.lean`, `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`'s step (C) calls `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` directly; Phase 1's recorded PLAN-SPINE DEVIATION note states why the independent spine is unavailable. |
| The near-duplication this phase existed to remove | NOT INCURRED, so there is nothing to remove. The reduction route added ~70 lines that share no proof text with the landed spine (no pigeonhole block, no raise, no overshoot loop, no remainder deletion), rather than the ~140-line near-duplicate the plan anticipated. The module therefore carries one copy of the spine, which is the outcome this phase was scheduled to secure. | `git diff --stat` for the Phase 1 commit: 119 added lines in `LadderChain.lean` for one new declaration plus one `longFile` baseline line. |

---

### Phase 3: The Common-Shift Downward Inclusion on the Witnessing Path [NOT STARTED]

**Goal**: `mem_cellAt_of_common_shift_of_hasForwardSlack_exact` compiles in `LadderCell.lean`: a
type realized at `(q, c + m · (P + 1), n + m · (P + 1))` by a path carrying the regime at
`m · (P + 1) + m · (P + 1)` is realized at `(q, c, n)`.

**Tasks**:
- [ ] Add the declaration to `LadderCell.lean`'s `section ForwardSlack`, before
      `CellLEZeroConstOfKappaEqForwardSlack`, at the pinned signature below.
- [ ] Model the body on the landed `mem_cellAt_of_shift_of_hasForwardSlack_exact`: read
      `objAt g z = q`, `cntAt g z = c + m * (P + 1)` and `nxtAt g z = n + m * (P + 1)` off `hgz`;
      derive `pend (objAt g z) = true` from `h'` and the gap; derive `hpast` by
      `pend_past_of_nxtAt_lt` from `n + 2 ≤ c`.
- [ ] Apply Phase 1's declaration with `n₀ := n` and `k := m * (P + 1)`, discharging `hk` from
      `hgz`, `hTc` from `Tc ≤ c`, and `hgap` from `hroom`.
- [ ] Finish exactly as the landed theorem does: `mem_cellAt_ladder_iff`, a `Subtype.ext` on
      `(objAt g' z, cntAt g' z, nxtAt g' z) = (q, c, n)`, and the type clause.
- [ ] Docstring: state that the register is carried DOWN by the same multiple as the countdown,
      that the regime amount is DOUBLED relative to the landed equal-register inclusion and why,
      that `hroom` is a genuine strengthening not implied by `n + 2 ≤ c`, and that the statement
      is on the witnessing path because the state-level form is refuted.
- [ ] `bash scripts/typst-sync-check.sh --fix`; stage `typst/generated/status.typ` with the Lean
      change.

**Timing**: 1 hour 15 minutes

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly ONE new declaration to `LadderCell.lean` and
changes no existing declaration there; confirm with `git diff --stat` plus a `git diff`
read-through.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
covers a purely additive declaration in one module with no externally visible signature change.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - new declaration in `section ForwardSlack`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- The scoped `lake build` on `...RaySummary.LadderCell` exits 0 with no `sorry`.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.mem_cellAt_of_common_shift_of_hasForwardSlack_exact`
  reports no `sorryAx`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit.

---

### Phase 4: The Common-Shift Downward Inclusion at the State Level [NOT STARTED]

**Goal**: `cellAt_subset_of_common_shift_of_pend_past_rev` compiles: the same inclusion between
cells, under `ForwardSlackWitnessed` of the higher pair at the doubled amount.

**Tasks**:
- [ ] Add the declaration to `LadderCell.lean` directly after Phase 3's, at the pinned signature
      below.
- [ ] Body: the landed `cellAt_subset_of_shift_of_pend_past_rev` pattern verbatim — `intro T hT`,
      destructure `hw T hT` into `⟨g, τ, hg, hgz, hτ, hslack, hty⟩`, apply Phase 3's declaration,
      close with `rwa [hty] at hmem`.
- [ ] Confirm `ForwardSlackWitnessed` is instantiated at `l := m * (P + 1) + m * (P + 1)` and
      `n := n + m * (P + 1)`, matching Phase 3's `hslack` binder exactly; a mismatch here is the
      one place this phase can fail silently in the sense of compiling a weaker statement.
- [ ] Docstring: name it the common-shift mirror of `cellAt_subset_of_shift_of_pend_past_rev`,
      and state that the hypothesis is not removable for the same compiled reason.
- [ ] `bash scripts/typst-sync-check.sh --fix`; stage `typst/generated/status.typ`.

**Timing**: 45 minutes

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: one new declaration, no existing declaration touched; confirm with
`git diff --stat` on `LadderCell.lean`.

**Tier Justification**: the same scoped `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderCell`
covers a purely additive declaration whose only consumers are later phases of this same plan.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - new declaration in `section ForwardSlack`
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- The scoped `lake build` exits 0 with no `sorry`.
- `lean_verify` on
  `FormalSystem.Metalogic.Decidability.RaySummary.cellAt_subset_of_common_shift_of_pend_past_rev`
  reports no `sorryAx`.
- Read back the compiled `ForwardSlackWitnessed` argument (via `lean_hover_info` on the binder)
  and confirm the amount is `m * (P + 1) + m * (P + 1)`, not `m * (P + 1)`.

---

### Phase 5: The Branch-2 Schema, the Records, and the Full Gate [NOT STARTED]

**Goal**: `CellLEZeroConstOfKappaEqCommonShiftForwardSlack` and
`cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack` compile as cell EQUALITY with no
equal-register hypothesis; the durable records say what landed and what did not; the full gate
set is green or its findings are attributed.

**Tasks**:
- [ ] Add the schema `def` and its theorem to `LadderCell.lean`'s `section ForwardSlack`, after
      Phase 4's declaration, at the pinned signatures below.
- [ ] Proof: `intro hp hno q c n c' n' h h' z - hbr hgap hgap' hTc hTc' hwup hwdn`, discarding the
      collision hypothesis at `intro` with `-` so no unused local is created (the displacement
      comes from `hbr`, not from `kappa_eq_components`). Destructure `hbr`, `subst` the
      displacement in each direction, and close each with `Set.Subset.antisymm` on the landed
      upward `cellAt_subset_of_common_shift_of_pend_past` and Phase 4's downward inclusion.
- [ ] Docstring on the schema: enumerate its hypotheses, state that it is NOT the reserved
      statement `CellLEZeroConstOfKappaEq`, that it is strictly stronger in hypotheses and bears
      on the reserved schema's truth value in neither direction, that the equal-register
      hypothesis is ABSENT by construction (the common-shift displacement replaces it), and that
      branch 3 of `kappa_collision_regimes` is not reached.
- [ ] Amend `LadderCell.lean`'s module docstring: the layer now has three halves, not two — add
      the register-lowering downward half and the branch-2 schema, and keep the existing
      reserved-name sentence intact.
- [ ] Amend `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: the "two routes left
      open" paragraph (confirmed present at authoring time, in the `LadderCell.lean` /
      depth-`0`-obligation discussion near the end of the file) must no longer assert the
      REGISTER-LOWERING DELETION route open — it is landed for branch 2 and still does not reach
      the saturated residue; the `(K1)` AMENDMENT route is unchanged and stays named as open.
      Also extend the `LadderCell.lean` and `LadderChain.lean` Description cells of the generated
      inventory table with the new declarations. If that paragraph has moved or been reworded by
      the time this phase runs, locate it by its "two routes left open" heading phrase and amend
      in place; if it is genuinely absent, treat the phase as `[BLOCKED]` and escalate rather
      than inventing a new home for the record.
- [ ] Regenerate surface (a) IN THIS ORDER: edit the Description cells first, then
      `bash scripts/check-module-invariants.sh --emit-inventory` (it preserves existing
      Description text and refreshes only the counts), then
      `bash scripts/check-module-invariants.sh --emit-inventory --check`.
- [ ] `bash scripts/typst-sync-check.sh --fix`; stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase adds exactly TWO new declarations (one `def`, one `theorem`) and
edits three records (`LadderCell.lean`'s module docstring, `RaySummary/README.md`, and the two
regenerated inventory blocks); confirm the declaration count with `git diff` on `LadderCell.lean`
and the record edits with `git diff --stat`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - schema `def` + theorem in `section ForwardSlack`; module docstring amended to record the third half
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the "two routes left open" paragraph amended; `LadderCell.lean` and `LadderChain.lean` Description cells extended
- `README.md` - regenerated `FormalSystem` totals inventory block
- `FormalSystem/Metalogic/README.md` - regenerated inventory block
- `typst/generated/status.typ` - regenerated line counts

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project) exits 0
  with no `sorry` and no error.
- `bash scripts/check-module-invariants.sh` exits 0 — the project's Lean-tree phase gate,
  including C1 (`lake build`), C2 (recorded axiom baselines), the inventory check and the
  doc-count checks.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/typst-sync-check.sh` exits 0 (full invocation, not `--counts-only`).
- `bash .claude/scripts/verify-deploy.sh` — the complete agent-system gate set this tier names.
  Because the gate set runs against the whole deploy tree and the dispatch context reports that
  tree STALE for the core, lean, literature and memory extensions, the criterion is: every
  finding is attributed, and NO finding names a file this task touched. A pre-existing finding
  attributable to the recorded staleness is recorded as baseline and is NOT hand-patched under
  `.claude/**`.
- `lean_verify` on both
  `FormalSystem.Metalogic.Decidability.RaySummary.cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack`
  and the schema `def`: no `sorryAx`, no custom axiom.
- `grep -rn "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` confirms the reserved name is still
  declared by nothing (it appears only inside docstrings).

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell

set_option autoImplicit false

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ) (n₀ k : ℕ)
    (hk : n₀ + k = nxtAt g z)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) + k ≤ cntAt g z)
    (hslack : HasForwardSlack g z (m * (P + 1) + k) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = n₀ ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

theorem mem_cellAt_of_common_shift_of_hasForwardSlack_exact
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hroom : n + (m * (P + 1) + m * (P + 1)) ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n + m * (P + 1)), h'⟩)
    (hslack : HasForwardSlack g z (m * (P + 1) + m * (P + 1)) (n + m * (P + 1)))
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

theorem cellAt_subset_of_common_shift_of_pend_past_rev {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ)
    (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c) (hroom : n + (m * (P + 1) + m * (P + 1)) ≤ c) (hTc : Tc ≤ c) (z : ℤ)
    (hw : ForwardSlackWitnessed step pend fwd bwd lab φ
      (⟨(q, c + m * (P + 1), n + m * (P + 1)), h'⟩ : LadderState Q pend) z
      (m * (P + 1) + m * (P + 1)) (n + m * (P + 1))) :
    cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c + m * (P + 1), n + m * (P + 1)), h'⟩) :
          (ladderFrameAdm step pend fwd bwd).WorldState) z ⊆
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

def CellLEZeroConstOfKappaEqCommonShiftForwardSlack {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) : Prop :=
  ParamsOk step pend lab φ Tc Tn P B →
    (∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ) →
    ∀ (q : Q) (c n c' n' : ℕ) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q) (z : ℤ),
      kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n') →
      (∃ m : ℕ, (c' = c + m * (P + 1) ∧ n' = n + m * (P + 1)) ∨
        (c = c' + m * (P + 1) ∧ n = n' + m * (P + 1))) →
      n + 2 ≤ c → n' + 2 ≤ c' → Tc ≤ c → Tc ≤ c' →
      (∀ m : ℕ, c' = c + m * (P + 1) → n' = n + m * (P + 1) →
        n + (m * (P + 1) + m * (P + 1)) ≤ c ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c', n'), h'⟩ : LadderState Q pend) z
            (m * (P + 1) + m * (P + 1)) n') →
      (∀ m : ℕ, c = c' + m * (P + 1) → n = n' + m * (P + 1) →
        n' + (m * (P + 1) + m * (P + 1)) ≤ c' ∧
          ForwardSlackWitnessed step pend fwd bwd lab φ
            (⟨(q, c, n), h⟩ : LadderState Q pend) z
            (m * (P + 1) + m * (P + 1)) n) →
      cellAt (ladderModel step pend fwd bwd lab) φ
          ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z
        = cellAt (ladderModel step pend fwd bwd lab) φ
            ((z, ⟨(q, c', n'), h'⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z

theorem cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEqCommonShiftForwardSlack step pend fwd bwd lab φ Tc Tn P B := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Scoped `lake build` green on `...RaySummary.LadderChain` after Phases 1 and 2.
- [ ] Scoped `lake build` green on `...RaySummary.LadderCell` after Phases 3, 4 and 5.
- [ ] Full-project `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` green
      at Phase 5.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 at Phase 5 (C1 build, C2 axiom
      baselines, inventory and doc-count checks).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 at Phase 5; `--counts-only` exits 0 before every
      Lean-touching commit.
- [ ] `lean_verify` reports no `sorryAx` and no custom axiom on all five new declarations.
- [ ] `bash .claude/scripts/lean-sorry-census.sh` shows no new `sorry` attributable to this task.
- [ ] `grep -rn "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` shows the reserved name declared
      by nothing.
- [ ] `bash .claude/scripts/verify-deploy.sh` run at Phase 5 with every finding attributed and
      none naming a file this task touched.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — one new path-level
  assembly; the landed up-first theorem's proof body retired to its `k = 0` instance (signature
  unchanged), contingent on Phase 2.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — four new declarations (the
  path-level downward common-shift membership, the state-level inclusion, the branch-2 schema and
  its theorem) and an amended module docstring.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the register-lowering route no
  longer recorded as open; the two affected Description cells extended.
- `README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks.
- `typst/generated/status.typ` — regenerated line counts (one regeneration per Lean-touching
  phase).
- `specs/909_register_lowering_deletion_drop_equal_register/summaries/01_*-summary.md` — written
  at implementation postflight, not by this plan.

## Rollback/Contingency

Each phase is a single additive Lean declaration (Phase 5: two, plus record edits) committed on
its own, so the rollback unit is one commit and `git revert` of that commit is the first
response. No phase deletes or weakens a landed declaration; the only phase that touches existing
Lean is Phase 2, which changes a proof body and nothing else, and whose own fallback is to make
no change at all.

If a phase must be abandoned mid-edit with uncommitted work present, do NOT reach for a bare
precautionary snapshot: follow `context/contracts/recovery.md`'s recovery ladder — fix forward
first; if the phase genuinely cannot close, mark it `[BLOCKED]` with the goal state recorded and
escalate. Only a genuine rollback of uncommitted work uses the reverting
`bash .claude/scripts/git-snapshot.sh 909` form named on that contract's rollback rung (with its
out-of-scope override flag if the rollback must reach `LadderChain.lean`, which sits outside the
task's originally declared `file_scope`); an ordinary defensive checkpoint uses `--no-revert`.

Contingency on the construction itself: if Phase 1's pinned signature proves unprovable — the one
substantive risk — the correct response is `[BLOCKED]` plus the measured deficit (which `omega`
goal failed, by how much, at which anchor direction), so a `/revise` can re-pin the slack amount.
Substituting a weaker same-named statement is forbidden by `plan-compliance.md`, and no phase of
this plan may land anything under the reserved name `cellLE_zero_const_of_kappa_eq`.
