# Blocker Analysis: Task #349

**Parent Task**: #349 - Build recursive `endChar` navigated arity-3 endpoint primitive
**Generated**: 2026-07-12
**Blocker**: Plan v7 Phase 2 (`ExteriorBracketK.lean`) is design-level BLOCKED: the four
depth-`k` exterior bracket lemmas (`kvE_extBracketPast/Fut_sound`/`_complete`) are provably
unconstructible in the prescribed byte-identical-statement shape from inside the prescribed
leaf module, because the frozen clause layer they would need to reuse is depth-hardwired to
depth-0 subs.

## Root Cause

Phase 2 of plan v7 (`specs/349_.../plans/07_enriched-bracket-carrier.md`, Phase 2 block,
lines 411-499) landed its design-invariant determinacy core GREEN and sorry-free in the new
module `ExteriorBracketK.lean` (commits `34a173e88`, `af794abcb`, `c4c5c7eb1`) — `nfk_truncD`/
`nf_eval_truncD`, `nf_eval_take`/`nf_eval_projFresh`, `kvE_sepPos`/`kvE_projFreshD`/
`kvE_futAnyBit`(`_correct`), and `kvE_subBit`(`_iff`) — but the four bracket lemmas themselves
could not be proved. The blocker (recorded in full in
`specs/349_.../handoffs/v7-phase2-blocked-1783882788.json` and the plan's Phase-2 BLOCKER
block) has three isolated causes:

1. **Depth-hardwired frozen clause layer.** `kvE2_futPos`/`kvE2_extNegFut` +
   `_sound`/`_complete` (`ExteriorNegation.lean:1124/1136/1243/1484`, and the `Past` mirrors in
   `ExteriorNegationPast.lean`) read `sigma.2` through `nf0_assemble`'s coordinatization, which
   is lossless ONLY for depth-0 subs (`NfEFold.lean:549-561`) — the frozen layer is hardwired
   to `sigma : NormalForm sig 1 4`, one fixed depth.
2. **Truncation-shadow brackets are jointly unsatisfiable.** An F2-style pair of qnfs sharing a
   depth-1 truncation but differing on a joint-coupled depth-`k` sub (`f2_sub_proj_eq` pattern,
   `RefutationF2.lean:471`) makes a full-bit clause selector falsify `_complete` and a
   shadow-bit selector falsify `_sound` — no single bracket-formula construction over
   `nfk_truncD` shadows can satisfy both directions simultaneously.
3. **The faithful Rabinovich Def-7.5 rung-`(k+1)` bracket recursively consumes rung-`k`
   formulas** ("the exterior bracket's own recursive fold", report
   `10_q3-uniform-k-probe.md` adversarial §2) — a depth-`k` closed-formula channel
   (`ExistProviders`, `PriorInterface.lean:38-40`) and/or the Phase-3 recursive carrier, neither
   of which is available inside the prescribed leaf module. Re-deriving the navigated clause
   layer at depth `k` over `P.existF 0` point descriptions is ExteriorNegation-scale
   (~2000+ lines), 5-10x the Phase-2 budget.

The user has adjudicated **resolution (a)**: re-scope the bracket construction to take
`P : ExistProviders sig atomMap k` (`PriorInterface.lean:38`) as a parameter, and budget the
depth-`k` clause-layer rebuild as its own dedicated task — an ExteriorNegation-scale rebuild
consuming the landed determinacy core unchanged. This is a single foundational blocker: once
the depth-`k` clause layer exists and exposes bracket-buildable interface points, task 349's
Phase-2 re-dispatch closes the four bracket lemmas as its own (in-task) follow-on work — that
closure is NOT part of the spawned task.

## Proposed New Tasks

### New Task 1: Build depth-`k` navigated exterior negation clause layer (ExistProviders channel)
- **Effort**: high
- **Task Type**: lean4
- **Rationale**: This is the single missing prerequisite for Phase 2's four bracket lemmas.
  Without a depth-`k` (rather than depth-0-hardwired) clause layer reachable through the
  `ExistProviders` channel, no bracket formula constructible in Phase 2's leaf module can
  satisfy both soundness and completeness simultaneously (root cause 2 above) — the depth-`k`
  clause layer removes the depth-hardwiring (root cause 1) and supplies the rung-`k` recursive
  formula input the faithful bracket needs (root cause 3).
- **Depends on**: None

## Dependency Reasoning

There is only one spawned task, so there is no internal dependency graph to reason about.
Task 349 will be made to depend on this new task in postflight (parent-child linking is handled
outside this spawn batch, not via the `new_tasks[].dependencies` field).

## After Completion

Once the spawned task is complete, resume the parent task #349 with `/implement 349` (plan v7
Phase 2 re-dispatch, or a plan revision if the landed clause-layer interface warrants restating
the Phase-2 task list — at the discretion of the next `/plan 349` or `/implement 349` pass).

The blocker will be resolved because: the four bracket lemmas' unprovability traces entirely to
the frozen clause layer being depth-0-hardwired and to the faithful bracket needing a rung-`k`
recursive formula source. Once the new task lands a depth-`k` clause layer parameterized by
`P : ExistProviders sig atomMap k` that (i) is not hardwired to `sigma : NormalForm sig 1 4` and
(ii) exposes the interface Phase 2 needs to construct honest per-side bracket formulas, Phase 2
can construct `kvE_extBracketPast`/`kvE_extBracketFut` and discharge `_sound`/`_complete` against
that new interface, consuming the already-landed `ExteriorBracketK.lean` determinacy core
verbatim.
