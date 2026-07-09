# Task 342 Phase 1 Handoff (sess_1783617988_38e7cf)

## Immediate Next Action

Phase 2: re-anchor `kvE2_sepAllSlots` to `(kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock`.
First step: add `kvE2_sepAllSlots_eq_pos : kvE2_sepAllSlots qnf = (kvE2_sepPos qnf).flatMap
kvE2_sepSlotBlock` (one `rw [kvE2_sepAllSlots, kvE2_sepPosI_flatMap_slotBlock]`) as the
universal repair tool, then repair `kvE2_sepAllSlots_nodup`, `kvE2_sepMem_allSlots`
(keep its `σ ∈ kvE2_sepPos` hypothesis; route through `kvE2_sepMem_posI_of_slot`),
`kvE2_sepSlotIndexOf` lemmas, `kvE2_sepConsistentBlock_slotIndexOf`,
`kvE2_sepZipPayload_flatMap`.

## Current State

- Phase 1 [COMPLETED], full `lake build` green (1720 jobs), purely additive diff
  (150 insertions, 0 deletions in Theories/).
- Sorry count in landed declarations: 0. `sorry_inventory`: empty.
- Axioms on `kvE2_sepPosI_flatMap_slotBlock`: `{propext, Classical.choice, Quot.sound}`.
- `kvE2_sepHonest_hLR_absurd` untouched, now at SW:4768 (pure line shift from insertions).

## Landed Declarations (all new, SharedWitness.lean)

Insertion 1 (after `kvE2_sepPosIn`, SW:~203-244):
- `kvE2_sepPosI` — SINGLE two-zone order-preserving filter (settled design; `++` form forbidden)
- `kvE2_sepPosI_mem`, `kvE2_sepPosI_subset`, `kvE2_sepPosI_zone`, `kvE2_sepPosI_nodup`

Insertion 2 (after `kvE2_sepMem_slotBlock`, SW:~410-520):
- `kvE2_sepSlotsLFor_eq_nil`, `kvE2_sepSlotsRFor_eq_nil`, `kvE2_sepSlotBlock_eq_nil`
- `kvE2_sepMem_posI_of_slotL`, `kvE2_sepMem_posI_of_slotR`, `kvE2_sepMem_posI_of_slot`
- `kvE2_sep_flatMap_filter_of_vanish` (private generic engine)
- `kvE2_sepPosI_flatMap_slotBlock`, `kvE2_sepPosI_flatMap_slotsLFor`,
  `kvE2_sepPosI_flatMap_slotsRFor`

## Key Decisions

- `kvE2_sepPosI_nodup` proves `((Finset.nodup_toList _).filter _).filter _` directly: a
  PRIVATE `kvE2_sepPos_nodup` already exists at SW:2014, BELOW the Phase 1 insertion point,
  so it cannot be referenced (and adding a public duplicate collides — build error confirmed,
  then fixed). Do NOT add a public `kvE2_sepPos_nodup` in later phases without removing the
  private one first (which would violate the additive discipline for now).
- Generic transfer engine proof: induction + `List.filter_cons_of_pos/neg`,
  `decide_eq_false_iff_not`, `not_or`. Reusable pattern for any later filter-transfer need.

## Sorry Inventory

(empty)
