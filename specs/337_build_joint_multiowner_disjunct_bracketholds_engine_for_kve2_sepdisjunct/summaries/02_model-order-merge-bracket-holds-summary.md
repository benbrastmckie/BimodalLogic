# Implementation Summary: Task #337 v2 (Model-Order Merge Bracket-`holds`) — BLOCKED at Phase 1

- **Task**: 337 — Joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct` (Option A)
- **Plan**: `plans/02_model-order-merge-bracket-holds.md`
- **Status**: PARTIAL / BLOCKED (Phase 1 of 6) — requires user review + re-plan (v3)
- **Code changes**: NONE. `SharedWitness.lean` is byte-for-byte at its green post-task-336 state.
- **Zero-debt**: no `sorry`, no `admit`, no vacuous placeholder, no new axiom introduced.

## Outcome

A read-only feasibility investigation (baseline build confirmed green; all target machinery read
and cross-checked against source line numbers) surfaced a **structural, plan-level blocker** at the
foundation of Phase 1, before any code was written. The blocker is documented in full in the plan
file under `### Phase 1 … [BLOCKED]`. It is NOT a tactic-level difficulty and cannot be resolved
within the plan's authorized additive-plus-single-rewire scope.

## Root Cause (one paragraph)

`kvE2_sepBracketN.holds` (via `IntervalPattern.holds_eq_succ`, ExistsForallNF.lean:188) demands a
witness sequence `ws` **strictly monotone in the FIXED slot-position order** of
`sortedL ++ ptW :: sortedR`, each `ws i` realizing slot `i`'s point type in a **model-determined**
interval, with segment (`beta`) obligations keyed to a fixed prefix-membership
(`kvE2_sepSegLForSub`). But `sortedL/sortedR` must be **model-independent** (they are arguments to
`kvE2_sepDisjunct` inside the model-free `noncomputable def kvE2_sepBody`), while the landed carrier
weak-order `KvE2SepWeakOrder := List (σ × KvE2SepSpikeOrderType)` (SharedWitness.lean:694-695)
records only a **per-owner** tag relative to the shared `w` and carries **NO cross-owner
interleaving** of the interior owners' fresh anchors `x1_σ`. Hence, for interior owners whose
anchors interleave differently across honest models, no fixed model-independent `sortedL` is
strictly-monotone-realizable for all such models, and `wo` cannot select the correct interleaving.
The codebase itself flags this as the unbuilt general case (SharedWitness.lean:2007-2012:
"the general multi-owner pairwise discharge is the completeness-side Phase-8 obligation"), and the
plan's cited "sorted-list source" patch (`specs/333_.../handoffs/phase1-switch-and-repairs.patch`)
contains no `sortedL/sortedR` — it only redefines `kvE2_sepSlotLe`, a switch already live.

## Secondary tension (independent)

The strict `kvE2_sepModelOrder` validity is NOT honestly provable — the task-334 empirical finding
(SharedWitness.lean:1421-1429) shows only the CLOSED `zAtX1L` bit is forced at each owner's fresh
anchor, so the honestly-valid `kvE2_sepArr'` member is `kvE2_sepCoincidentOrder`, not
`kvE2_sepModelOrder`. Phase 5's stated ⇐ route through `kvE2_sepArr'_mem_modelOrder` (:800) is
therefore not honestly dischargeable and must target the coincidence order.

## Recommended next step

Re-plan (v3) or spawn a carrier-enrichment task that:
1. Enriches `KvE2SepWeakOrder`/`kvE2_sepOrderTypes`/`kvE2_sepArr'`/`kvE2_sepModelOrder` to carry a
   cross-owner order on the merged anchor multiset (successor to task 333; this is the sanctioned,
   faithful alternative to the forbidden Option B slot-permutation enumeration).
2. Re-scopes the "single authorized carrier edit" to include that weak-order encoding.
3. Re-targets Phases 4-5 onto `kvE2_sepCoincidentOrder`.

## Verification snapshot

- `lake build Bimodal.…SharedWitness`: green (baseline, pre-investigation; unchanged after).
- sorry/admit/axiom/vacuous added: 0 (no code edited).

## Plan Deviations

- Phase 1 **[BLOCKED]** before code — structural obstruction in the carrier encoding; documented
  in the plan. Phases 2-6 not started (each depends on Phase 1).
