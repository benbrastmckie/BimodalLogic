# Blocker Analysis: Task #335

**Parent Task**: #335 - Outer-gate assembly engine `kvE2_body` / `bracketEndChar_kvE2`
**Generated**: 2026-07-08
**Blocker**: Phases 2-4 of the implementation plan (⇒ soundness, ⇐ completeness, assembled k=2
gate) all bottom out on one missing prerequisite: a joint multi-owner disjunct bracket-`holds`
builder for `kvE2_sepDisjunct` over the merged slot lists `kvE2_sepSlotsL/R qnf`.

## Root Cause

**Category**: Missing prerequisite (a task-334-deferred obligation that was never built).

Task 335's Phase 1 landed cleanly: a live `bracketEndChar_kvE2` def plus its `rfl` bridge, in a
new sibling file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean`,
axiom-clean and committed. Phases 2-4 are all marked `[BLOCKED]` in the plan
(`specs/335_outer_gate_assembly_engine_kvE2_body/plans/01_outer-gate-assembly.md`), and each
blocker note traces to the same single obstruction:

- **Phase 2 (⇒ soundness)** needs to reconstruct the full depth-2 evaluation
  `nf_eval_nf M 2 3 (Fin.cons w …)` from the carrier's `holds`. The landed extractor
  `kvE2_sepBody_extract` (SharedWitness.lean:1955) supplies per-σ bundle *inputs*, and
  `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1290) reconstructs a *single* positive σ's
  inner realization — but nothing lands the ⟹ direction of the quant-layer iff or reassembles the
  outer atom layer across all subs. The plan's own Phase 2 blocker note states this is "symmetric
  to the missing joint multi-owner bracket engine (see Phase 3 blocker)".
- **Phase 3 (⇐ completeness, left-interior)** needs to build
  `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds M atomMap x t`
  — a `VecEA2.holds` (VecEAFormula:262) that unfolds to `endpointLeft@x ∧ endpointRight@t ∧
  bracket.holds`, where `bracket.holds` is an `IntervalPattern.holds` requiring a **globally
  monotone witness sequence across ALL owners** in the merged slot lists. A full survey of
  `SharedWitness.lean` confirms only *extractors* exist (`kvE2_sepDisjunct_extract` :1807,
  `_halves` :1906, `kvE2_sepArr'_sound` :2536) — there is no ⇐ `holds` **builder**. The two nearest
  landed lemmas, `kvE_subBracket2V_complete` (SubBracket2V.lean:1730) and
  `bracketEndChar_k1v_complete` (CarrierK1V.lean:1629), are per-owner / k=1 and structurally do not
  lift to the joint multi-owner case.
- **Phase 4 (assembly)** simply depends on both 2 and 3 and cannot proceed until they land.

This obligation was explicitly flagged as un-landed by task 334 itself
(`SharedWitness.lean:1954`: "the general multi-owner pairwise discharge is the completeness-side
Phase-8 obligation") — task 334 built the carrier's non-vacuousness/completeness scaffolding
(`kvE2_sepBody_nonvacuous`, `kvE2_sepBody_complete`) but deliberately deferred the underlying
joint bracket-holds construction. Task 336 (now COMPLETED) generalized `kvE2_sepBody_complete`
from left-interior (`hL`) to left-OR-right-interior (`hLR`) owners, but did not touch this
obligation — it operates one layer up (the disjunct-membership gate, not the disjunct's own
`.holds` realization).

The plan already scopes the unblocking path precisely: wire the general region engine
`k1v_sorted_realizationK` (SubBracket2V.lean:633) into the `kvE2_sepDisjunct` slot/segment/endpoint
layout — map each positive owner's honest bundle (`kvE2_sepHonestBundleL`/`R`) into a region, run
the engine to get a monotone interleaved witness sequence, and match it to `kvE2_sepBracketN`'s
`IntervalPattern` point types + segments, discharging `kvE2_sepEpL`/`kvE2_sepEpR` at `x`/`t`. This
is estimated as comparable in size to `bracketEndChar_k1v_complete` (~370 lines), a single
well-scoped construction — not a decomposable set of independent sub-problems.

## Proposed New Tasks

### New Task 1: Build the joint multi-owner disjunct bracket-holds engine for `kvE2_sepDisjunct`

- **Effort**: 4-5 hours (comparable to `bracketEndChar_k1v_complete`'s ~370 lines, plus
  verification overhead for a more general multi-owner construction)
- **Task Type**: lean4
- **Rationale**: This is the single missing prerequisite blocking all of task 335's remaining
  phases (2, 3, 4). Building it directly unblocks the parent task's re-dispatch.
- **Depends on**: None (internal)
- **Description** (implementer-ready): Wire the general region engine
  `k1v_sorted_realizationK` (`SubBracket2V.lean:633`) into the `kvE2_sepDisjunct` slot/segment/
  endpoint layout (`SharedWitness.lean`), delivering a ⇐-direction `holds` **builder** for the
  joint multi-owner disjunct bracket: given the merged per-owner slot lists `kvE2_sepSlotsL/R qnf`,
  each positive owner's honest bundle (`kvE2_sepHonestBundleL`/`kvE2_sepHonestBundleR`), and
  witnesses `x < w < t`, produce
  `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds M
  atomMap x t`. Concretely: (1) map each positive owner's honest bundle into a region compatible
  with `k1v_sorted_realizationK`'s input shape; (2) run the engine to obtain a globally monotone
  interleaved witness sequence across all owners; (3) match that sequence to `kvE2_sepBracketN`'s
  `IntervalPattern` point types and segments; (4) discharge the endpoint conjuncts
  `kvE2_sepEpL`/`kvE2_sepEpR` at `x`/`t`. Deliver as a new lemma (naming pattern:
  `kvE2_sepDisjunct_holds_of_honest` or similar, mirroring the `kvE2_sepGate_holds_of_honest`
  naming convention already in the file) in `SharedWitness.lean`, sorry-free, axiom-clean
  (`lean_verify` -> `{propext, Classical.choice, Quot.sound}` only, no `sorryAx`), preserving all
  seven faithfulness invariants F1-F7 (in particular F5: no open/closed zone-key conflation, and
  the LITMUS at NavigatedSpine:437: no `x1 < e_i` relative-position literal — witness bounds must
  come from the bracket range, never a chain). Treat all task-334/336 carrier lemmas
  (`kvE2_sepBody_extract`, `kvE2_sepBody_complete`, `kvE2_sepHonestBundleL/R`,
  `kvE2_sepDisjunct_extract`, `kvE2_sepArr'_sound`) as verified INPUTS — apply them, do not
  re-derive or weaken them. **File-safety note**: this task is very likely to edit
  `SharedWitness.lean`, the same file task 336 (now COMPLETED) just edited to generalize
  `kvE2_sepBody_complete` from `hL` to `hLR`. Task 336 is complete, so there is no live blocking
  dependency, but this note documents the serialization intent for traceability — verify on start
  that the `hLR`-generalized `kvE2_sepBody_complete` signature is the one in scope (per
  `specs/336_generalize_completeness_right_interior_zAtX1R/summaries/01_generalize-completeness-right-interior-summary.md`).
  On completion, task 335 re-dispatches Phases 2-4 to consume the new builder.
- **file_scope**: `["Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean"]`

## Dependency Reasoning

Only one new task is proposed, so there is no internal dependency graph to reason about. The task
is deliberately **not decomposed further** (per the Task Minimization Principle) because:

1. The joint multi-owner bracket-`holds` construction is a single coherent mathematical
   obligation — mapping honest bundles into regions, running the sorted-realization engine, and
   matching the result to the `IntervalPattern` structure are steps *within* one proof, not
   independently dispatchable sub-tasks. Splitting them would force an artificial dependency chain
   where each "task" is really just a `have` inside the same lemma.
2. It has a clear, comparably-sized precedent already landed in the codebase
   (`bracketEndChar_k1v_complete`, ~370 lines) confirming this is a single-agent-run-sized unit of
   work, not a multi-task decomposition.
3. The parent task's plan (Phase 3 blocker note) explicitly frames this as "a new construction" —
   singular — not a set of independent deliverables.

**File-safety note (not a dependency, documented per spawn-agent instructions)**: The new task
will very likely edit `SharedWitness.lean`, the same file task 336 (COMPLETED) edited. Because
task 336 is already complete, there is no blocking edge to add; this is noted in the task
description as a traceability/verification-on-start reminder rather than a `dependencies[]` entry
(the new task has no internal-index dependencies — `dependencies: []`).

## After Completion

Once the new task is complete, resume the parent task #335 with `/implement 335`.

The blocker will be resolved because: with the joint multi-owner disjunct bracket-`holds` builder
landed, Phase 2 (⇒) gains the missing connector to reconstruct the full depth-2 evaluation across
all subs, and Phase 3 (⇐) gains the missing `.holds` proof needed by `kvE2_sepBody_holds_iff`'s
mpr direction. Phase 4 then assembles both directions into the delivered left-interior
gate-correctness theorem exactly as originally planned, with no further blockers anticipated.
