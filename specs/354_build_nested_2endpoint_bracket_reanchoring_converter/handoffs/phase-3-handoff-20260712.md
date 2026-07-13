# Task 354 — Phase 1-3 handoff (Future converter GREEN)

## State
- `ExteriorConverterK.lean` (NEW) built GREEN, sorry-free, axioms exactly
  `[propext, Classical.choice, Quot.sound]`. Frozen files byte-identical.
- Phases 1, 2, 3 (Future) COMPLETE. Phase 3 fired **Branch B** (carried saturation residue).

## Phase 3 branch decision (drives Phase 4)
Branch B. The fiber-backward converse is provably false in-module; saturation is carried as the
named hypothesis `hsat` (depth-`k` `hexclExt` analog). Atom layer recovered via
`kvE_futAtom_of_bundle` (bundle route), NOT the risky `kvE_futEnd_forces_atom`.

## Immediate next action — Phase 4 (Past dual)
Mirror `ExteriorConverterK.lean` into `ExteriorConverterPastK.lean`, importing
`...ExteriorNegationPastK`. Mirror Branch B (carried `hsat`). Consume the Past templates:
- `kvE_extNegPast_sound` (ExteriorNegationPastK.lean:539) — the template to reverse.
- Past chain destructor + `kvE_pastEnd`/`kvE_pastPos`/`kvE_pastGapD`/`kvE_pastItemShift` etc.
  (need to read ExteriorNegationPastK.lean to get exact Past names — the Future proof used
  `kvE_futChainDestructG`, `kvE_futEnd`, `kvE_futPos`, `kvE_futGapD`, `kvE_futItemShift`,
  `kvE_futSelfZone`, `kvE_futAdmissible`, `kvE_fiberZoneList`, `kvE_fiberPosOnShift_correct`,
  `kvE_futItemShift_correct`).
- `semantic_prior_SZ` for the last-occurrence endpoint (dual of UZ).
- Shared helpers `kvE_futAtom_of_bundle`, `kvE_futAdmissible_*` are Future-named; Past will need
  Past analogs OR the chain infra may be shared/side-agnostic — check whether
  `kvE_futChainDestructG` is reused by Past (it is generic `{α}`), and whether admissibility /
  fiber helpers are side-shared.

## Key proof shape (Future, to mirror)
1. `rw [kvE_extNegFut, temporal_truth_neg]; intro hpos`
2. `by_cases hadm : kvE_futAdmissible σ = true`
3. admissible: peel `formula_disjList_iff`, `List.mem_map`, `List.mem_permutations` → chain `l`.
4. `himp` via `kvE_fiberPosOnShift_correct` + `kvE_futItemShift_correct`.
5. `kvE_futChainDestructG ... l t himp hφ` → `x1, htx1, hend, _, _`.
6. self-content from `hend` → bit-true `s0` → `hreal` → `kvE_futAtom_of_bundle` → `hA`.
7. `hfib`: `←` via `hreal`, `→` via `hsat`.
8. `(nf_eval_nfk_iff_efold ...).mpr ⟨⟨hA, hfib⟩, offFiber⟩`; offFiber via `kvE_futAdmissible_offFiber`.
9. `exact hcl x1 htx1 hσ`. Non-admissible branch: `kvE_futPos` = ⊥ ⇒ `exact hpos`.

## Remaining phases
- Phase 4: Past dual (Branch B mirror).
- Phase 5: bundle-shape reconciliation + Option B determinacy reader.
- Phase 6: axiom/sorry audit + full `lake build` + frozen git-clean.
