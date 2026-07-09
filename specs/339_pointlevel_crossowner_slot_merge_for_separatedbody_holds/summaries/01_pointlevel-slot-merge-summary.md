# Implementation Summary: Point-level cross-owner slot merge (task 339)

- **Task**: 339 — Point-level cross-owner slot merge for separated-body holds
- **Status**: COMPLETED (all 5 phases; sorry-free, axiom-clean, full build green)
- **Mode**: HARD (lean-implementation-hard-agent; H2 anti-analysis, H9 sorry-inventory)
- **File edited**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (single file)
- **Session**: sess_1783559167_09d562

## What changed

`kvE2_sepSlotsLOf`/`kvE2_sepSlotsROf` (SW:869-876) were redesigned from a per-owner BLOCK
`flatMap` into a genuine POINT-LEVEL cross-owner merge:

```
kvE2_sepSlotsLOf wo = ((kvE2_sepOrderOwners wo).flatMap kvE2_sepSlotsLFor).mergeSort (kvE2_sepSlotMergeLe wo)
```

Two new helper defs support the merge key, and two membership theorems support the re-proof:

- `kvE2_sepOwnerRank wo σ : ℕ` — reads σ's 338 merged-chain rank from `wo` (`List.find?`), consumed as-is.
- `kvE2_sepSlotMergeLe wo a b : Bool` — the composite lexicographic key, **region rank
  (`kvE2_sepSlotRank`) PRIMARY, owner merged-chain rank (`kvE2_sepOwnerRank`) SECONDARY**.
- `kvE2_sepSlotsLOf_mem` / `kvE2_sepSlotsROf_mem` — per-owner slot membership into the merged
  chain, proven via `List.mergeSort_perm` + `kvE2_sepMem_orderOwners` (same permutation technique
  as 338's `kvE2_sepMem_orderOwners`).
- A self-contained interleaving `example` (defining property): for owners with ranks `0 < 1`,
  `τ.lXU` is placed strictly between `σ.lXU` and `σ.lUW` — σ's own slots are non-contiguous in the
  merged chain (a block reorder could never do this).

`kvE2_sepBody_extract`'s internal `hmemL`/`hmemR` were re-routed through the new membership helpers
(Phase 4 work pulled forward into the Phase 2 build so the module never held a transient sorry).

### Key design decision (Phase 1 gate, flagged refinement)

The plan-prose key "(merged-chain rank, intra-owner region rank)" read literally (merged-chain
rank primary) is exactly BLOCK order — 338's ranks are `Nodup` per owner, so a merged-chain-primary
sort keeps each owner contiguous, the failure report 04 proved rank-independent-insufficient and
the plan forbids. The faithful point-level reading is therefore **region-rank primary, owner
merged-chain rank secondary**: within each region layer (all owners' `zXU`, then `x1`, then `zUW`)
owners are ordered by 338's cross-owner rank. This genuinely interleaves individual owner slots
while consuming `wo`'s rank as-is. Validated by hand against report 04's honest interleaving example
(`p<a<b<u`) and confirmed by the compiling interleaving `example`. Full design gate: reports/02.

### Residual granularity note (bounded to task 337, NOT a 339 blocker)

With only per-owner rank + per-slot region-rank the key is 2-level; a case like σ.zUW between σ.x1
and τ.x1 is not value-faithfully reproduced by any 2-level key — full value-faithfulness for the
`.holds` BUILDER (⇐) needs a per-slot global index, which is task 337's obligation. 339's
deliverable (a genuinely point-level, non-block, membership-preserving merge DEF + the ⇒-extraction
lemmas re-proven against it) is met without a carrier-type change, so the Rollback escalation branch
was NOT triggered.

## Phases

| Phase | Outcome |
|-------|---------|
| 1 — design-spec gate | PASS; region-primary merge validated against `holds_eq_succ`; no F5/LITMUS/block violation (reports/02) |
| 2 — merge defs + shallow lemmas | `kvE2_sepSlotsLOf/ROf` redesigned; membership helpers added; body/holds_iff/nonvacuous re-verified; green, sorry-0 |
| 3 — `kvE2_sepDisjunct_extract` | confirmed parametric over `lL/lR`, statement AND proof preserved, no edit; axiom-clean |
| 4 — `kvE2_sepBody_extract` | internal `hmemL/hmemR` re-routed through membership helpers (pulled forward into Phase 2 build); axiom-clean |
| 5 — verification gate | all touched decls axiom-clean; census sorry-0; F5/LITMUS clean; no-collapse + preservation green; full build green |

## Verification results

- **Full `lake build`**: green (1720 jobs).
- **Sorry census** (`lean-sorry-census.sh` on SharedWitness.lean): `sorry_count: 0`.
- **Vacuous defs**: 0. **New axioms**: 0.
- **`lean_verify` (all axioms = `{propext, Classical.choice, Quot.sound}`, no `sorryAx`)**:
  `kvE2_sepSlotsLOf`, `kvE2_sepSlotsROf`, `kvE2_sepSlotsLOf_mem`, `kvE2_sepSlotsROf_mem`,
  `kvE2_sepBody_holds_iff`, `kvE2_sepBody_nonvacuous`, `kvE2_sepDisjunct_extract`,
  `kvE2_sepBody_extract`, and the preserved `kvE2_sepModelOrder_mem_orderTypes`,
  `kvE2_sepCoincidentOrder_mem_orderTypes`, `kvE2_sepCoincidentOrder_mem_arr'`.
- **F5**: merge defs read no zone bit; bit selection untouched. **LITMUS**: merge key is abstract
  ℕ×ℕ, no model relative-position literal.
- **No-collapse**: both `kvE2_sepModelOrder` and `kvE2_sepCoincidentOrder` remain proven members.
- **Preserved assets**: all rows hold; the 338 weak-order TYPE, rank field, and `kvE2_sepDisjValid`
  ranks-Nodup conjunct unchanged.

## Postmortem-constraint compliance

- No block reordering shipped (region-primary interleaves — verified by the `example`). ✓
- Design gate not skipped (Phase 1 PASS recorded before any edit). ✓
- No `sorry` in any def body; no vacuous placeholder; sorry count 0 throughout. ✓
- No `x1 < e_i` relative-position literal (LITMUS). ✓
- No open/closed zone-key conflation (F5). ✓
- 338 cross-owner ORDER consumed as-is, not re-derived. ✓
- No scope creep into 337's `.holds` builder (`hpairL`/`hpairR` kept as hypotheses). ✓

## Follow-up

- Task 337 resumes (`/implement 337`): its `.holds` BUILDER (⇐) now targets the point-level merged
  carrier. The residual granularity note above records that a value-faithful global witness may
  need a per-slot global index; 337 owns that construction.
