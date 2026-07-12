# Blocker Analysis: Task #353

**Parent Task**: #353 - Build depth-k endpoint-pinned exterior converter extF4
**Generated**: 2026-07-12
**Blocker**: The flat/endpoint-pinned `extF4 : NormalForm sig k 5 -> Formula` as originally scoped
is a machine-verified NO-GO. Its literal signature is type-ill-posed, and the well-posed 4-anchor
carrier reformulation requires a 4-endpoint bracket primitive that does not exist and cannot exist
under the frozen 2-endpoint architecture.

## Root Cause

Category: **Design ambiguity resolved to architectural impossibility** (the original task-352
Deliverable 4 spec for `extF4` was an imprecise transcription of the k=2 carrier pattern; task
353's own research (`reports/01_extf4-endpoint-pinned-converter.md`) machine-confirmed it cannot
be built as scoped, for two independent, compounding reasons):

1. **Type-level ill-posedness.** `extF4_correct` as literally written uses
   `temporal_truth M atomMap t (extF4 s)` as the LHS. `temporal_truth` is a predicate of the
   single carrier point `t` only (`Table.lean:182-193`, verified). The RHS
   `exists y, nf_eval_nf M k 5 (Fin.cons y [x1,w,x,t]) s` depends on the free variables
   `x1, w, x`. Fixing `t` and varying `x1/w/x` breaks the biconditional in any model where `s`
   distinguishes the anchor coordinates. This is exactly the F2 env-transfer impossibility task
   352 already machine-proved via `transfer_probe` (`env4 = env'` residual;
   `specs/352_.../reports/03_realizability-transfer-blocker.md` Deliverable 3).

2. **Architectural impossibility of the well-posed reformulation.** Replacing `temporal_truth`
   with a 4-anchor carrier `.holds M atomMap x1 w x t` (the honest fix, by analogy to the k=2
   carrier `BracketCarrierCorrectVPrior`, which uses the 2-anchor `VVecEA2.holds M atomMap x t`)
   requires a 4-endpoint bracket primitive. None exists, and the entire bracket machinery is
   fundamentally 2-endpoint by construction: `VecEA2`/`VVecEA2` have exactly 2 free variables
   `z0, z1` (`VecEAFormula.lean:252-279`); even the arity-4 `kvE_subBracket2` exposes only 2
   explicit endpoints `(z0, z)`, with the interior anchors `x1, w` temporally quantified
   (`SubBracket2.lean:336`, Amendment F3). This is Rabinovich's own design invariant (Lemma 5.1:
   point-types quantifier-free; Def 3.1: interior points temporally quantified between exactly 2
   fixed endpoints) — not an accidental gap in this codebase's infrastructure.

The faithful mechanism Rabinovich actually uses (Lemma 5.3 Case 2/3) is **nested 2-endpoint
bracket re-anchoring**: the unique interior witness `r0 = inf{z in (z0,z1) | P1(z)}` becomes the
endpoint of the recursive sub-bracket `On(P2,...,Pn, r0, z1)`. Depth is carried by nesting, not by
widening a flat anchor tuple. This is a recursive, multi-phase construction — not a single new
lemma — and is the sole survivable unblocker for task 353's DoD.

Full grounding (read, do not re-derive):
`specs/353_build_depthk_endpoint_pinned_exterior_converter_extf4/reports/01_extf4-endpoint-pinned-converter.md`
(primary — exact signature reconciliation, Deliverable 5 with both re-scope options),
`specs/353_.../.orchestrator-handoff.json`,
`specs/352_build_depthk_navigated_exterior_negation_clause_layer_via_existproviders/reports/03_realizability-transfer-blocker.md`,
Rabinovich 2014 Lemma 5.1 / Lemma 5.3 / Cor 5.4 (`~/Projects/Literature/sources/rabinovich_2014/`).

## Proposed New Tasks

### New Task 1: Build nested 2-endpoint bracket re-anchoring converter (Rabinovich Lemma 5.3 recursion)

- **Effort**: high
- **Task Type**: lean4
- **Rationale**: This is Option A from report 01's Deliverable 5 — the only source-grounded,
  architecture-respecting mechanism that can discharge task 353's DoD. It replaces the refuted
  flat `extF4` with the faithful recursive nested-bracket construction Rabinovich actually proves
  Cor 5.4(1) with. Completing it directly unblocks task 353 (which can then re-close by citing the
  new converter) and re-opens the path to closing `kvE_extNegFut_complete` /
  `kvE_extNegPast_complete` (currently `[BLOCKED]`, task 352 completion summary).
- **Depends on**: None (foundational — no other spawned task in this batch).

## Deferred, Not Spawned: Option B (per-sub determinacy interface conditioned on realization)

Report 01 Deliverable 5 also documents Option B: package `nf_eval_nfk_iff_efold`
(`NfEFold.lean:627`) + `kvE_subBit_iff` (`ExteriorBracketK.lean:314` — NOTE the report flagged this
is NOT in `ExteriorFiberK.lean` as task 353's original description implied) into an
`hbelowFib`-shaped biconditional for the below-`t` / at-anchor zones where `sigma` IS already
realized at `[x1,w,x,t]`, and hand it to a future `_complete` re-dispatch as a discharged bundle
field. This is genuinely provable now, sorry-free, and frozen-file-clean — but it is **not spawned
as a separate task** here, for two reasons:

1. **It does not unblock task 353.** Task 353's DoD is specifically the endpoint-pinned converter
   deliverable. Option B produces a different artifact (a partial determinacy reader for the
   below-t/at-anchor zones only) that is consumed by a future `_complete` re-dispatch, not by task
   353 itself. Spawning it now would not satisfy the "minimal tasks to overcome 353's blocker"
   mandate.
2. **Sequencing risk if built ahead of Option A.** Option B's target shape (`hbelowFib`-style
   bundle field) is expressed against the pinned env `[x1,w,x,t]` that Option A's nested-bracket
   carrier will also produce and consume once built. Building Option B first risks the packaged
   interface needing rework once Option A's recursive carrier shape is finalized (Option A decides
   how `r0` is re-anchored and what the resulting carrier's field shape looks like). No
   dependency-worthy detail is missing today — Option B is provable in isolation — but doing it in
   the same window as Option A's design work is more efficient as a phase-0/scaffolding step
   inside Option A's own multi-phase plan (to be decided by the planner when `/plan` is run on the
   new task) than as a second, independently-scheduled task.

**Recommendation**: when `/plan` is run on New Task 1, the planner should evaluate folding Option
B in as an early phase (it can land independently and sorry-free, providing partial value while
the nested-bracket recursion is built) or leave it for a follow-up `/spawn` once Option A's carrier
interface stabilizes. It is not a blocking requirement either way, so it is not spawned as a task
here to avoid over-spawning.

## Dependency Reasoning

- **Single spawned task, no internal dependency edges.** New Task 1 is the only task in this
  batch; `dependency_order = [0]` trivially. There is no second task to depend on it or for it to
  depend on.
- **File Footprint Overlap Check (Component 4a)**: N/A for a single-task batch (the pairwise
  overlap algorithm in `.claude/context/patterns/file-footprint-overlap.md` requires at least two
  items to compare; with only New Task 1 present, no auto-added dependency edges are possible or
  needed).
- **Task 353's dependencies**: task 353 currently depends on `[352]` (completed). This spawn adds
  New Task 1's assigned number to task 353's `dependencies` array (handled by skill-spawn
  postflight Stage 13), so task 353 can re-close once New Task 1's nested-bracket converter lands.

## After Completion

Once New Task 1 (the nested-bracket re-anchoring converter) is complete, resume task 353 with
`/implement 353` — or more likely, task 353 should be re-scoped in place: it can either directly
cite the new converter to discharge its own DoD, or its description can be revised (`/revise 353`)
to point at the landed converter as the deliverable, since the flat `extF4` signature itself is
permanently refuted and should not be re-attempted.

The blocker will be resolved because: New Task 1 builds the source-grounded, architecture-
respecting mechanism (nested 2-endpoint re-anchoring, Rabinovich Lemma 5.3) that the flat extF4
spec was attempting — and failing — to shortcut. Once it lands, task 353's original purpose
(exposing an endpoint-pinned realizability interface for task 352's `_complete` re-close and task
349 Phase 2's bracket `_complete` lemmas) is satisfied by the new converter rather than by the
refuted flat signature.
