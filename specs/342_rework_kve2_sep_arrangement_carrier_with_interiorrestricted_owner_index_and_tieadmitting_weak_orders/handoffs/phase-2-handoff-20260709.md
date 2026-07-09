# Task 342 Phase 2 Handoff (sess_1783617988_38e7cf)

## Immediate Next Action

Phase 3: re-anchor the arrangement enumeration and membership lemmas to `kvE2_sepPosI`.
First step: `kvE2_sepOrderTypes` (SW:~1330 post-shift): change its `foldr` to range over
`kvE2_sepPosI qnf` (the `n` bound stays `(kvE2_sepAllSlots qnf).length` — already re-anchored
in this phase). Then `kvE2_sepModelOrder`: `zipIdx` over `kvE2_sepPosI qnf`. Then
`kvE2_sepOrderTypes_owners` conclusion becomes `wo.map Prod.fst = kvE2_sepPosI qnf`;
`kvE2_sepMem_orderOwners` hypothesis becomes `σ ∈ kvE2_sepPosI qnf`;
`kvE2_sepSlotsLOf_mem`/`ROf_mem` restate `hσ` over `kvE2_sepPosI`. Recover
`σ ∈ kvE2_sepPos` at call sites via `kvE2_sepPosI_subset`; recover interiority via
`kvE2_sepPosI_zone`; upgrade a Pos-membership + slot to PosI via `kvE2_sepMem_posI_of_slot`.

## Current State

- Phase 2 [COMPLETED]. Full `lake build` green (1720 jobs). Diff: 44 insertions,
  20 deletions in `SharedWitness.lean` only.
- Sorry count in landed declarations: 0. `sorry_inventory`: empty.
- Axioms on `kvE2_sepAllSlots_nodup`, `kvE2_sepAllSlots_eq_pos`, `kvE2_sepMem_allSlots`,
  `kvE2_sepZipPayload_flatMap`, `kvE2_sepConsistentBlock_slotIndexOf`, AND
  `kvE2_sepHonest_hLR_absurd`: all exactly `{propext, Classical.choice, Quot.sound}`.
- `kvE2_sepHonest_hLR_absurd` verbatim-untouched (verified: zero diff hunks mention it).
- `hLR` NOT touched anywhere (stays a syntactically-unused hypothesis until Phase 5).

## What Phase 2 Changed (all in SharedWitness.lean)

1. **`kvE2_sepAllSlots` body** (the ONLY statement-level change):
   `(kvE2_sepPosI qnf).flatMap kvE2_sepSlotBlock`. NOT defeq to the old body.
2. **NEW `kvE2_sepAllSlots_eq_pos`** (placed directly after `kvE2_sepPosI_flatMap_slotsRFor`):
   `kvE2_sepAllSlots qnf = (kvE2_sepPos qnf).flatMap kvE2_sepSlotBlock` by
   `rw [kvE2_sepAllSlots, kvE2_sepPosI_flatMap_slotBlock]`. THE universal repair tool —
   use it wherever a Phase 3/4 proof decomposed `kvE2_sepAllSlots` over `kvE2_sepPos`.
3. **`kvE2_sepMem_allSlots` RELOCATED** below `kvE2_sepAllSlots_eq_pos` (its repaired proof
   needs `kvE2_sepMem_posI_of_slot`, declared later than its old position). Statement
   verbatim-unchanged (hypothesis stays `σ ∈ kvE2_sepPos`) — all call sites compile as-is.
   Proof: `List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_posI_of_slot hσ hs, hs⟩` (term-mode defeq
   unfolding of the new body works fine).
4. **`kvE2_sepAllSlots_nodup`**: pairwise-disjointness side now from `kvE2_sepPosI_nodup`
   (`(kvE2_sepPosI_nodup qnf).imp (fun hne => kvE2_sep_blocks_disjoint hne)`).
5. **`kvE2_sepSlotIndexOf_block_mono`**: its `hall` decomposition now opens with
   `rw [kvE2_sepAllSlots_eq_pos, hpos, ...]` (was `rw [kvE2_sepAllSlots, hpos, ...]`);
   everything else verbatim. Its `hσ : σ ∈ kvE2_sepPos` hypothesis unchanged.
6. **`kvE2_sepZipPayload_flatMap`**: proof now `rw [kvE2_sepAllSlots_eq_pos]; exact ...aux`.
   Its statement is still over `kvE2_sepPos qnf).zipIdx` — Phase 4 restates it over
   `kvE2_sepPosI.zipIdx` when `kvE2_sepCoincidentOrder`/`kvE2_sepHonestOrder` move.
7. **Comments only**: `kvE2_sepSlotsL/R` and `kvE2_sepSegLAt/RAt` carry docstring notes
   recording the DELIBERATE choice to stay over `kvE2_sepPos` (report 07 sanctions either;
   non-interior contributions are `[]` resp. `⊤` conjuncts; conservative diff smaller).
   Do not "fix" this in Phase 3.

## Key Decisions / Gotchas for Phase 3

- There were exactly THREE defeq/unfold-sensitive sites of `kvE2_sepAllSlots` in the whole
  repo (nodup, block_mono, zipPayload) — all repaired. `kvE2_sepSlotIndexOf_lt`/`_injOn`
  and every other consumer are statement-level and needed nothing.
- `kvE2_sepAllSlots` is used ONLY in SharedWitness.lean (repo-wide grep).
- When Phase 3 moves `kvE2_sepOrderTypes` to `kvE2_sepPosI`, the length bound argument in
  `kvE2_sepCoincidentOrder_mem_orderTypes`-style proofs still goes through
  `kvE2_sepMem_allSlots qnf hσ hs` with `hσ : σ ∈ kvE2_sepPos` — obtain it from a PosI
  membership via `kvE2_sepPosI_subset`.
- Plan exit-criterion grep for Phase 3: `grep -n "map Prod.fst = kvE2_sepPos qnf"
  SharedWitness.lean` must return nothing when done.

## Sorry Inventory

(empty)
