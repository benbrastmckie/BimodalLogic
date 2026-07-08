# Implementation Summary: Task #337 — Joint Multi-Owner Disjunct Bracket-`holds` Engine

- **Task**: 337 — Build the joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct`
- **Status**: PARTIAL / [BLOCKED] at Phase 1 (architectural obstruction)
- **Type**: lean4
- **Session**: sess_1783550684_4c28c1
- **Outcome**: No `sorry`, no vacuous placeholder, no axiom introduced. `SharedWitness.lean`
  left **byte-for-byte unmodified**. The deliverable `kvE2_sepDisjunct_holds_of_honest` was NOT
  landed because it is not a theorem as specified (see root cause).

## What Was Completed

Phase 1, task 1 (signature verification, the plan's explicit start-of-phase gate):
- Confirmed `kvE2_sepBody_complete` (:1592) carries the `hLR` left-OR-right-interior disjunctive
  hypothesis (task-336 generalization) and concludes `kvE2_sepArr' qnf ≠ []` (non-vacuity only —
  NOT any disjunct's `.holds`).
- Confirmed `kvE2_sepArr'_sound` (:2594) and the honest bundles `kvE2_sepHonestBundleL` (:1222) /
  `kvE2_sepHonestBundleR` (:1274) signatures.
- Fully traced the target shape `IntervalPattern.holds_eq_succ` (ExistsForallNF:188, mpr), the
  engine `k1v_sorted_realizationK` (SubBracket2V:633), the landed extractor
  `kvE2_sepDisjunct_extract` (:1865), the joint carrier `kvE2_sepBody` (:821) /
  `kvE2_sepBody_holds_iff` (:855), and the single-owner template `bracketEndChar_k1v_complete`
  (CarrierK1V:1629).

## Root Cause of the Blocker (architectural, not effort)

The deliverable's required conclusion is `.holds` for the **FIXED flat-union (flatMap) slot
arrangement** `kvE2_sepSlotsL/R qnf`:

```
(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsL qnf) (kvE2_sepSlotsR qnf)).2.holds M atomMap x t
```

This is hardcoded in `kvE2_sepBody` (:835-836, where the weak-order `_wo` is **ignored** for slot
ordering) and is the exact object consumed by `kvE2_sepBody_holds_iff` (:863-864).

`.holds` (via `IntervalPattern.holds_eq_succ`, first conjunct) demands a **strictly-monotone**
witness `ws` with `ws i` realizing point type `(kvE2_sepSlotsL qnf).map (kvE2_sepSlotType …)[i]`
in **flatMap order** (all of owner σ1's slots, then all of σ2's, …). Three Lean-grounded facts
make this unbuildable:

1. **Engine returns a permutation, not order-equality.** `k1v_sorted_realizationK` (and its
   single-owner base `k1v_sorted_realization`) yields `List.Perm (ps.map Prod.fst) S` (SubBracket2V
   :642 / CarrierK1V :1455) — points sorted by *value*. `interleaveK ps` therefore realizes the
   *value-sorted* arrangement, a **permutation** of the flatMap list, not the flatMap list itself.

2. **The joint carrier abandoned permutation-enumeration.** The single-owner template resolves the
   identical Perm-vs-order issue ONLY because its carrier `bracketEndChar_k1v` enumerates *all*
   permutations and the completeness proof *selects the value-sorted one* as the disjunct's
   point-type list (`List.mem_permutations.mpr hpermL`, CarrierK1V:1995-1996). `kvE2_sepBody` does
   NOT — every disjunct is over the same fixed flatMap list — so no value-sorted permutation can be
   selected.

3. **The flatMap order is not value-monotone in general — documented by the codebase itself.**
   SharedWitness :334-337 (task-334 Phase-6 note): repairing the identity arrangement
   `kvE2_sepSlotsL_valid`/`_valid` "**requires a joint model-sorted arrangement (Phase 2
   make-or-break — no single-σ `k1v_sorted_realization3` analog exists for the joint slot list)**."
   SharedWitness :1038-1041: the two scaffolds `kvE2_sepSlotsL_valid`/`kvE2_sepSlotsR_valid` were
   **REMOVED as FALSE** because "the identity interleaving of the flat union is NOT a valid
   arrangement." Concretely, when two positive interior owners' anchors interleave (σ1's
   `(x1_σ1,w)` UW witnesses exceed σ2's `(x,x1_σ2)` XU witnesses), the flatMap order — grouping
   ALL σ1 slots before ALL σ2 slots — is not value-monotone, so no strictly-monotone `ws` aligned
   to it exists. The deliverable is universally quantified over `M`, so an interleaving model is
   admissible; hence `.holds` for the fixed `kvE2_sepSlotsL qnf` is **not a theorem**.

The plan's engine approach (`k1v_sorted_realizationK` → `interleaveK ps` → re-index to the slot
order) produces the model-sorted arrangement — exactly the "joint model-sorted arrangement" the
codebase flags as unbuilt — but that permutation is a **different** slot list than the fixed
`kvE2_sepSlotsL qnf` the deliverable's conclusion is pinned to. The plan's Risk table anticipated a
"witness re-indexing mismatch" but scoped it as a solvable index-arithmetic exercise; it is in fact
the fundamental Perm-vs-fixed-order obstruction.

## What Is Needed To Unblock

Resolution requires a **carrier-level change** to a task-334 INPUT (forbidden by this task's
Non-Goals), so it is a scope decision, not an additive fix:

- **Option A (retarget to sorted list)**: Change `kvE2_sepBody`/`kvE2_sepDisjunct` so each disjunct
  is built over the engine's **model-sorted** joint slot list (`interleaveK ps`'s underlying
  permutation), then the value-sorted witness matches the disjunct's point-type order and the
  engine approach closes. This edits `kvE2_sepBody`/`kvE2_sepDisjunct`.
- **Option B (enumerate permutations)**: Mirror the single-owner `bracketEndChar_k1v` carrier —
  enumerate permutations of the joint slot lists in `kvE2_sepBody`'s disjunct list and select the
  sorted one in the builder. Also a carrier edit.
- Either way, the deliverable's conclusion type (and its consumer `kvE2_sepBody_holds_iff`, and the
  landed extractor `kvE2_sepDisjunct_extract`'s hypotheses) must be re-targeted consistently.

Recommended: a new task authorizing the `kvE2_sepBody`/`kvE2_sepDisjunct` redesign (the "joint
model-sorted arrangement" machinery the task-334 note names as the unbuilt make-or-break), after
which task 337's builder becomes landable via the engine as originally planned.

## Faithfulness / Acceptance Gates

- Zero `sorry`/`admit`; zero vacuous placeholders; zero new axioms; `SharedWitness.lean` unmodified.
- No F1-F7 regression introduced (no code landed).
- The blocker was identified from the actual definitions and the codebase's own task-334 comments —
  not fabricated, and not papered over.

## Plan Deviations

- Phase 1: marked [BLOCKED] after completing its signature-verification task and discovering the
  architectural obstruction; region assembly (rest of Phase 1) and Phases 2-5 not attempted because
  every candidate helper bottoms out on the non-existent flatMap-monotonicity fact.
