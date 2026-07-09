# Task 342 Phase 3 Handoff (sess_1783617988_38e7cf)

## Immediate Next Action

Phase 4: re-anchor `kvE2_sepCoincidentOrder` (SW:~2480) and `kvE2_sepHonestOrder` (SW:~3270)
to `zipIdx` over `kvE2_sepPosI qnf`, then delete the interim `hpos` bridges this phase
installed (exact recipe below).

## Current State

- Phase 3 [COMPLETED] at commit `264f9b6a6`. Full `lake build` green (1720 jobs).
  Diff: 112 insertions, 58 deletions, `SharedWitness.lean` only.
- Sorry count in landed declarations: 0. `sorry_inventory`: empty. No new axioms; no
  vacuous defs (baseline counts unchanged vs HEAD).
- Axioms on ALL rebuilt/restated declarations (`kvE2_sepPosI_eq_pos`, `_owners`,
  `_mem_orderTypes` ×3, `_mem_arr'` ×2 + `kvE2_sepArr'_mem_modelOrder`, `mem_orderOwners`,
  `SlotsL/ROf_mem`, `mem_pos`/`mem_block` chain, valueSorted pair, `OrderOwners_nodup`,
  `kvE2_sepBody_extract`, `kvE2_sepBody_complete`, `kvE2_sepHonest_hLR_absurd`): exactly
  `{propext, Classical.choice, Quot.sound}` (or subset).
- `kvE2_sepHonest_hLR_absurd` verbatim-untouched (zero diff hunks mention it).
- `hLR` statements untouched everywhere (still present in the four hLR theorems; Phase 5
  deletes them). Phase 3 added USES of `hLR` (to discharge `hpos`) — Phase 4 removes those
  uses, restoring the syntactically-unused state Phase 5's statement rewrite needs.
- Plan exit-criterion grep `map Prod.fst = kvE2_sepPos qnf` → no matches.

## What Phase 3 Changed (all in SharedWitness.lean)

1. **`kvE2_sepOrderTypes`**: `foldr` over `kvE2_sepPosI qnf` (the `n` bound stays
   `(kvE2_sepAllSlots qnf).length`).
2. **`kvE2_sepModelOrder`**: `zipIdx` over `kvE2_sepPosI qnf`. Its `mem_orderTypes` proof
   instantiates `kvE2_sepOrderTypes_mem_aux'` with `(kvE2_sepPosI qnf)` and recovers
   `σ ∈ kvE2_sepPos` for `kvE2_sepMem_allSlots` via `kvE2_sepPosI_subset`. UNCONDITIONAL
   (no hpos needed — both sides re-anchored together). `kvE2_sepArr'_mem_modelOrder`
   untouched.
3. **`kvE2_sepOrderTypes_owners`**: conclusion `wo.map Prod.fst = kvE2_sepPosI qnf`.
4. **`kvE2_sepMem_orderOwners`, `kvE2_sepSlotsLOf_mem`/`ROf_mem`**: `hσ : σ ∈ kvE2_sepPosI`.
   Sole Pos-holding call site (`kvE2_sepBody_extract`, SW:~5050) upgraded in place via
   `kvE2_sepMem_posI_of_slotL/R` (slot forces interiority).
5. **NEW `kvE2_sepPosI_eq_pos`** (after `kvE2_sepPosI_nodup`, SW:~242): from `hLR`,
   `kvE2_sepPosI qnf = kvE2_sepPos qnf` by `List.filter_eq_self`. THE interim bridge —
   Phase 4 makes it dead; delete it in Phase 5 together with `hLR` (or leave with a
   deprecation note if Phase 8 wants it for the non-interior pack — planner's call).
6. **Interim `hpos` hypothesis** `(hpos : kvE2_sepPosI qnf = kvE2_sepPos qnf)` added to
   `kvE2_sepCoincidentOrder_mem_orderTypes` and `kvE2_sepHonestOrder_mem_orderTypes`
   (their carriers still zipIdx over `kvE2_sepPos`, so unconditional membership in the
   PosI-anchored enumeration is FALSE in general — the enumeration pins the owner
   projection). Proofs: `rw [<order-def>, kvE2_sepOrderTypes, hpos]` then the old aux'
   instance verbatim. Discharged at all three consumers with
   `(kvE2_sepPosI_eq_pos qnf hLR)`: `kvE2_sepBody_complete`,
   `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepHonestOrder_mem_arr'` (statements of all
   three UNCHANGED — hLR was already a hypothesis).
7. **Owner-projection membership chain generalized** (statement-level):
   `kvE2_sepOrderOwners_mem_pos`, `kvE2_sepSlotsLOf_mem_block`, `kvE2_sepSlotsROf_mem_block`
   now take `{L} (howners : wo.map Prod.fst = L)` and conclude membership in `L`
   (enumeration members supply `L = kvE2_sepPosI` via `kvE2_sepOrderTypes_owners`; the
   honest order supplies `L = kvE2_sepPos` directly). This kept the hLR-free task-337
   value-sorted trio's STATEMENTS unchanged.
8. **`kvE2_sepSlotsL/ROf_honest_valueSorted`**: proofs open with an inline
   `have hwo : (kvE2_sepHonestOrder …).map Prod.fst = kvE2_sepPos qnf` proved by
   `rw [kvE2_sepHonestOrder, List.map_map]; exact List.zipIdx_map_fst 0 _` — the owner
   projection read directly off the zipIdx carrier, bypassing enumeration membership.
9. **`kvE2_sepOrderOwners_nodup`**: closes with `kvE2_sepPosI_nodup`.
10. **Comment fix** at `kvE2_sepOwnerRank` (owner projection now `kvE2_sepPosI`).

## Phase 4 Repair Recipe

1. Move `kvE2_sepCoincidentOrder` and `kvE2_sepHonestOrder` to
   `(kvE2_sepPosI qnf).zipIdx.map …`.
2. **Delete the `hpos` binder** from both `mem_orderTypes` lemmas; proofs: drop `, hpos`
   from the `rw` and instantiate aux' with `(kvE2_sepPosI qnf)`; inside the `hb` argument
   `hσ : σ ∈ kvE2_sepPosI` — wrap with `kvE2_sepPosI_subset` where
   `kvE2_sepMem_allSlots`/`kvE2_sepSlotIndexOf_lt` need `σ ∈ kvE2_sepPos` (mirror the
   repaired `kvE2_sepModelOrder_mem_orderTypes`, which is the exact template).
3. Delete `(kvE2_sepPosI_eq_pos qnf hLR)` at the three consumer sites (step 6 above).
4. In the four hLR theorems' proof bodies (`kvE2_sepBody_complete`, both `mem_arr'`,
   `kvE2_sepBody_complete_holds` ~SW:4490): `List.fst_mem_of_mem_zipIdx hmem` now yields
   `σ ∈ kvE2_sepPosI qnf`; replace `rcases hLR σ hσmem with hzone | hzone` by
   `rcases kvE2_sepPosI_zone hσmem with hzone | hzone`, and pass
   `kvE2_sepPosI_subset hσmem` where the validators/`kvE2_sepConsistentBlock_*` need
   `σ ∈ kvE2_sepPos`. After this `hLR` is syntactically unused in every proof body.
5. `kvE2_sepZipPayload_flatMap`: restate over `(kvE2_sepPosI qnf).zipIdx`; proof becomes
   `rw [kvE2_sepAllSlots]; exact kvE2_sepZip_flatMap_aux g f (kvE2_sepPosI qnf) 0`
   (AllSlots ≡ PosI.flatMap since Phase 2 — now definitionally aligned, no eq_pos needed).
6. valueSorted pair: the inline `have hwo : … = kvE2_sepPos qnf` becomes
   `= kvE2_sepPosI qnf` (same `List.zipIdx_map_fst` proof); downstream
   `kvE2_sepSlotGIdx_honestOrder_mono` wants `∈ kvE2_sepPos` — apply `kvE2_sepPosI_subset`
   to the `mem_block` outputs.
7. 5A-5C rank machinery over `kvE2_sepAllSlots`: statement-level, expect no change;
   defeq-sensitive steps (if any surface) repair with `kvE2_sepAllSlots_eq_pos`.

## Key Decisions / Gotchas

- The generic-`L` membership chain (item 7 above) means Phase 4 does NOT need to touch
  `kvE2_sepOrderOwners_mem_pos`/`mem_block` at all — only their `howners` arguments at
  call sites change target list.
- `kvE2_sepOrderTypes_owners_aux` (the fixed-tuple owners aux, SW:~1740) is now dead code
  (aux' superseded it); left in place, compiles. Candidate for Phase 5 cleanup.
- `List.zipIdx_map_fst i l : List.map Prod.fst (List.zipIdx l i) = l` (core); needs
  `List.map_map` first and unifies up to defeq with the pair-building lambda.
- The 340-plan file `specs/340_*/plans/03_*.md` and a stray `working-progress-*.patch`
  are dirty in the worktree from an unrelated session — do NOT stage them.

## Sorry Inventory

(empty)
