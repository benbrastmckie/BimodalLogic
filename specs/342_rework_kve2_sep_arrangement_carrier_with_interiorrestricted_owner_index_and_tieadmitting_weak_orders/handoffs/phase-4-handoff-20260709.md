# Task 342 Phase 4 Handoff (sess_1783617988_38e7cf)

## Immediate Next Action

Phase 5: delete the `hLR` binder from the four theorems (`kvE2_sepBody_complete` ~SW:2632,
`kvE2_sepCoincidentOrder_mem_arr'` ~SW:2678, `kvE2_sepHonestOrder_mem_arr'` ~SW:3286,
`kvE2_sepBody_complete_holds` ~SW:4462), fix the one forwarding call (SW:4477), restate
`kvE2_sepDisjunct_extract` over `kvE2_sepPosI`, and do the OuterGate.lean doc edit (~line 28).

## Current State

- Phase 4 [COMPLETED]. Full `lake build` green (1720 jobs). Diff: 63 insertions,
  72 deletions, `SharedWitness.lean` only.
- **VACUITY BRIDGE DELETED**: `kvE2_sepPosI_eq_pos` declaration removed; `grep -c` over the
  file AND over all of `Theories/` returns 0. Zero `hpos : kvE2_sepPosI = kvE2_sepPos`
  binders remain; zero `List.filter_eq_self` occurrences remain in the file. No proof
  anywhere derives a PosI/Pos equality from `hLR`.
- Sorry count in landed declarations: 0 (all 8 `grep sorry` hits are comment prose).
  `sorry_inventory`: empty. No new axioms; no vacuous defs (baseline unchanged).
- Axioms on keystones (`lean_verify`): `kvE2_sepCoincidentOrder_mem_arr'`,
  `kvE2_sepHonestOrder_mem_arr'`, `kvE2_sepSlotGIdx_honestOrder_mono`,
  `kvE2_sepBody_complete_holds`, `kvE2_sepSlotsLOf_honest_valueSorted`,
  `kvE2_sepHonest_hLR_absurd` — all exactly `{propext, Classical.choice, Quot.sound}`.
- `kvE2_sepHonest_hLR_absurd` verbatim-untouched (zero diff hunks mention it).

## What Phase 4 Changed (all in SharedWitness.lean)

1. **Deleted `kvE2_sepPosI_eq_pos`** (was after `kvE2_sepPosI_nodup`, ~SW:242) with its
   interim-bridge docstring — 13 lines gone.
2. **`kvE2_sepZipPayload_flatMap`**: restated over `(kvE2_sepPosI qnf).zipIdx`; proof is now
   `rw [kvE2_sepAllSlots]; exact kvE2_sepZip_flatMap_aux g f (kvE2_sepPosI qnf) 0`
   (definitionally aligned with the Phase 2 `kvE2_sepAllSlots`; `kvE2_sepAllSlots_eq_pos` no
   longer needed here).
3. **`kvE2_sepCoincidentOrder` / `kvE2_sepHonestOrder`**: `zipIdx` carriers over
   `kvE2_sepPosI qnf`.
4. **Both `mem_orderTypes` lemmas**: `hpos` binder DELETED — now UNCONDITIONAL. Proofs: aux'
   instantiated with `(kvE2_sepPosI qnf)`; inside the bound argument,
   `kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs` (exact mirror of the Phase 3
   `kvE2_sepModelOrder_mem_orderTypes` template).
5. **Three consumers** (`kvE2_sepBody_complete`, both `mem_arr'`): the
   `(kvE2_sepPosI_eq_pos qnf hLR)` argument deleted; conjunct (i)
   `rcases hLR σ hσmem` → `rcases kvE2_sepPosI_zone hσmem`, validators fed
   `(kvE2_sepPosI_subset hσmem)`; conjunct (ii) consistency lemmas fed
   `(kvE2_sepPosI_subset hσmem)`. Statements UNCHANGED (hLR binders stay for Phase 5).
   `kvE2_sepCoincidentOrder_mem_arr'` proof-shape-identical (same refine/rcases skeleton).
6. **`kvE2_sepSlotGIdx_honestOrder`** (337 halign bridge): `find?` resolution now over
   `(kvE2_sepPosI qnf).zipIdx`; the membership witness is
   `kvE2_sepMem_posI_of_slot hσ hs` (slot forces interiority — statement keeps
   `hσ : σ ∈ kvE2_sepPos`, so all call sites compile unchanged).
7. **valueSorted pair**: inline `hwo` owner projection now `= kvE2_sepPosI qnf` (same
   `List.zipIdx_map_fst` proof); the `_mono` calls wrap `kvE2_sepPosI_subset hτ/hσ`.
8. **5A-5C rank machinery**: compiled UNCHANGED (statement-level over `kvE2_sepAllSlots`;
   no defeq-sensitive step surfaced — `kvE2_sepAllSlots_eq_pos` was not needed).

## hLR Occupancy Map (for Phase 5's deletion)

After Phase 4, `hLR` appears in the file ONLY as:
- Statement binders: SW:~2637 (`Body_complete`), ~2684 (`Coincident mem_arr'`),
  ~3292 (`Honest mem_arr'`), ~4469 (`Body_complete_holds`).
- ONE forwarding proof-body use: SW:~4477 (`Body_complete_holds` passes `hLR` to
  `kvE2_sepHonestOrder_mem_arr'`) — disappears when the binders are deleted together.
- The permanent guard `kvE2_sepHonest_hLR_absurd` (~SW:4832): its own binder + the
  `rcases hLR σw hmem` at ~SW:4861. DO NOT TOUCH (statement, docstring, proof all verbatim).
- Docstring prose mentions (Phase 5 rewrites the stale ones per plan task 3).

## Phase 5 Repair Recipe

1. Delete the `(hLR : ∀ σ ∈ kvE2_sepPos qnf, …)` binder from the four theorems; at SW:~4477
   drop `hLR` from the `kvE2_sepHonestOrder_mem_arr'` application. Proof bodies otherwise
   compile verbatim (Phase 4 already removed every destructuring use).
2. Check external call sites of the four (OuterGate.lean or elsewhere) with
   `grep -rn "Body_complete\|mem_arr'" Theories/ --include=*.lean` — drop the `hLR` argument
   wherever supplied.
3. `kvE2_sepDisjunct_extract` (~SW:4650s): restate `hmemL`/`hmemR` quantification over
   `kvE2_sepPosI qnf`; supply via Phase 3's restated `kvE2_sepSlotsLOf_mem`/`ROf_mem`.
4. Docstring rewrites (banner ~SW:2612-2630, ~2673, ~3283, ~4459): interiority is
   definitional via `List.mem_filter` on `kvE2_sepPosI`; keep D1-sanctioned citation
   phrasing (tie-collapse forced by Def 3.1 p.4; Lemma 3.2(1) closure stated without
   printed proof; never "per the proof of Lemma 3.2(1)").
5. OuterGate.lean ~line 28 doc-only edit (R-A bullet): interior-restricted carrier
   description; `kvE2_sepHonest_hLR_absurd` documents why no interiority hypothesis returns.
6. Exit: `grep -n "hLR" SharedWitness.lean` hits only in the `kvE2_sepHonest_hLR_absurd`
   region and historical comments; `lean_verify` clean on all four; full build green.

## Key Decisions / Gotchas

- `kvE2_sepBody_complete_holds` was NOT edited in Phase 4: it has no `rcases hLR`; its
  forwarding use is structurally unavoidable until the `mem_arr'` binder dies in Phase 5.
- The `lean_verify` qualified prefix is `Bimodal.Metalogic.WeakCanonical.Kamp.`.
- The 340-plan file `specs/340_*/plans/03_*.md` and a stray `working-progress-*.patch` are
  dirty in the worktree from an unrelated session — do NOT stage them.
- FORBIDDEN (unchanged): any new PosI/Pos equality lemma; any new hypothesis in the hLR
  shape; `kvE2_sepPosI` as an append of two zone filters.

## Sorry Inventory

(empty)
