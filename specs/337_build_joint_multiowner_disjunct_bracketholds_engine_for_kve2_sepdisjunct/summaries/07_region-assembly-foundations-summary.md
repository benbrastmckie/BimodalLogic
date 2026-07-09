# Task 337 — Cycle 7 Summary: Region-Assembly Foundations

**Status**: partial (Phase 1 still IN PROGRESS). SharedWitness.lean GREEN throughout; never RED.
**Session**: sess_1783578954_3bce55_337
**Build target**: `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` (scoped, exit 0)

## What landed (10 additive, green, axiom-clean lemmas)

All inserted immediately after `kvE2_sepSlotsROf_honest_valueSorted` (before the Task 340 Phase 5D
docstring). Axioms: `{propext, Classical.choice, Quot.sound}` (verified on
`kvE2_sepSlotsLOf_nodup` and `kvE2_sepSlotValue_lX1_mem`). No new axioms, no sorry, no vacuous defs.

### Batch A — anchor boundary + distinctness (commit `phase 1.6`)
- `kvE2_sepSlotValue_lX1_mem` — LEFT anchor slot value ∈ `(x, w)` (honest bundle L).
- `kvE2_sepSlotValue_rX1_mem` — RIGHT anchor slot value ∈ `(w, t)` (honest bundle R).
- `kvE2_sepSlotValue_lX1_injOn` — distinct positive owners → distinct `.lX1` values (`kvE2_sepAnchor_injOn`).
- `kvE2_sepSlotValue_rX1_injOn` — mirror for `.rX1`.

These are the `hpos` strictness seed and `hbdry` endpoints for the region assembly.

### Batch B — merged slot-list `Nodup` (commit `phase 1.7`)
- `kvE2_sepSlotsLFor_nodup` / `kvE2_sepSlotsRFor_nodup` — per-owner region blocks Nodup (from `kvE2_sepSlotBlock_nodup`).
- `kvE2_sepSlotsLFor_disjoint` / `kvE2_sepSlotsRFor_disjoint` — cross-owner disjoint (from `kvE2_sep_blocks_disjoint`).
- `kvE2_sepOrderOwners_nodup` — wo-ordered owners Nodup (mergeSort perm of Nodup `kvE2_sepPos`).
- `kvE2_sepSlotsLOf_nodup` / `kvE2_sepSlotsROf_nodup` — the merged slot lists are `Nodup` (the `hnd` foundation).

## What did NOT land

`kvE2_sepHonest_engineInputs` (the region assembly producing regionsL/R + hpos/hlink/hnd/hreal/hbdry)
is NOT built. Terminal deliverables `kvE2_sepDisjunct_holds_of_honest` and `kvE2_sepBody_holds_of_honest`
NOT delivered.

## Crux uncovered — the `hreal` base/anchor value collision (next cycle's design question)

The anchor-gap partition's `hreal` needs, for each base type χ in open gap `(a_i, a_{i+1})`,
`∃ u, a_i < u < a_{i+1} ∧ realizes χ`. χ's slot value `v` realizes χ and lies in the *closed* gap
(value-sortedness), but `v` can EQUAL an anchor value `a_j` (base realizers via `Classical.epsilon`
are chosen independently of `kvE2_sepAnchorVal`; no non-collision lemma is provable in general). At
`v = a_i`, `v` is a boundary, not strictly interior — `hreal` has no witness. Plus a SECONDARY
question: the engine's `hnd` is on a `List (NF 0 1)` of TYPES, but two distinct base SLOTS (different
owners) can share the same χ in one gap → the TYPE list is not Nodup though the SLOT list is; the
engine is likely applied per-SLOT or via a de-dup/indexed wrapper. Both must be resolved before
`kvE2_sepHonest_engineInputs` can be defined. Resolution options recorded in plan Phase 1 §OPEN
DESIGN QUESTION and in `.orchestrator-handoff.json`.

## Preserved

Halign trio, all cycle-6 value-sortedness lemmas, `kvE2_sepCoincidentOrder_mem_arr'`, all
334/336/338/339/340 declarations — untouched (strictly additive inserts).
