# Task 342 Phase 3 Summary — Re-anchor arrangement enumeration and membership lemmas

**Session**: sess_1783617988_38e7cf
**Commit**: `264f9b6a6`
**Status**: Phase 3 [COMPLETED]; build green (1720 jobs); sorry inventory empty.

## Phases Executed

Phase 3 only (single-phase dispatch; Phases 1-2 were prior dispatches, Phase 4 is next).

## What Changed (SharedWitness.lean only; 112 insertions, 58 deletions)

- `kvE2_sepOrderTypes`: cartesian `foldr` now over the interior index `kvE2_sepPosI qnf`
  (docstring cites the §5 p.7 ψ0/ψ1/φ split; Lemma 3.2(1) states the closure without
  printed proof).
- `kvE2_sepModelOrder`: `zipIdx` over `kvE2_sepPosI qnf`; its `mem_orderTypes` proof
  re-instantiated with `L = kvE2_sepPosI`, Pos recovery via `kvE2_sepPosI_subset`.
- `kvE2_sepOrderTypes_owners`: conclusion `wo.map Prod.fst = kvE2_sepPosI qnf`.
- `kvE2_sepMem_orderOwners`, `kvE2_sepSlotsLOf_mem`, `kvE2_sepSlotsROf_mem`: hypothesis
  `hσ : σ ∈ kvE2_sepPosI qnf`; sole Pos-holding call site (`kvE2_sepBody_extract`)
  upgraded in place via `kvE2_sepMem_posI_of_slotL/R`.
- NEW `kvE2_sepPosI_eq_pos`: `hLR → kvE2_sepPosI qnf = kvE2_sepPos qnf`
  (`List.filter_eq_self`).
- Interim `hpos` hypothesis on `kvE2_sepCoincidentOrder_mem_orderTypes` and
  `kvE2_sepHonestOrder_mem_orderTypes` (their zipIdx carriers stay over `kvE2_sepPos`
  until Phase 4; unconditional membership would be false in general). Discharged from
  `hLR` at all three consumers; consumer statements unchanged.
- `kvE2_sepOrderOwners_mem_pos` + `kvE2_sepSlotsL/ROf_mem_block`: generalized over a
  generic owner list `L` (`howners : wo.map Prod.fst = L`), so the hLR-free task-337
  value-sorted trio keeps unchanged statements (honest order's owner projection read
  directly via `List.zipIdx_map_fst`).
- `kvE2_sepOrderOwners_nodup`: closes with `kvE2_sepPosI_nodup`.

## Verification Results

- Full `lake build`: green (1720 jobs).
- Exit-criterion grep `map Prod.fst = kvE2_sepPos qnf`: no matches.
- Sorries introduced by this diff: 0 (repo census hits are pre-existing Boneyard/Transfer).
- Vacuous defs / axiom declarations: baseline unchanged vs HEAD.
- `#print axioms` on all 19 key rebuilt declarations (incl. both `mem_arr'` theorems,
  `kvE2_sepBody_extract`, `kvE2_sepBody_complete`, `kvE2_sepHonest_hLR_absurd`):
  exactly `{propext, Classical.choice, Quot.sound}` (or subset).
- `kvE2_sepHonest_hLR_absurd`: verbatim-untouched. `hLR` statements untouched (Phase 5).

## Plan Deviations (annotated inline in the plan's Phase 3 checklist)

1. Coincident/honest `mem_orderTypes` repaired via the interim `hpos` bridge rather than
   `kvE2_sepPosI_subset` (the statements are false-in-general until Phase 4 moves the
   carriers — the enumeration pins the owner projection). Phase 4 deletes the bridge.
2. Owner-projection membership chain generalized over a generic owner list `L`
   (statement-level) to preserve the task-337 value-sorted trio without new hypotheses.

## Handoff

`handoffs/phase-3-handoff-20260709.md` — includes the 7-step Phase 4 repair recipe.
