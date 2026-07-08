# Task 331 Phase 4 Handoff (2026-07-07, sess_1783475175_afdf09)

## Immediate Next Action
ORCHESTRATOR DECISION REQUIRED — Phase 4 is [BLOCKED] on its MergedQuarantine half (full
blocker record under the Phase 4 heading in `plans/01_split-and-api-plan.md`). Recommended
resolution: amend the plan to defer the entire MergedQuarantine extraction (part 1
:5077-:5856 minus fold_iff, together with part 2 :8608-:8826) to Phase 7, where SubBracket2V
already exists; MergedQuarantine then imports PriorInterface + SubBracket2V, zero token edits
ever, one-file settled decision preserved. Under that amendment Phase 4 = PriorInterface only,
which LANDED GREEN this dispatch (commit f1cae4b57) — the amendment retroactively completes
Phase 4, and Phase 5 (SubBracket/SubBracket2) is immediately dispatchable: its slabs
:5857-:6106 and :6107-:6733 do not touch the part-1 region.

## Current State
- Phase 4 [BLOCKED]; working tree GREEN: full `lake build` exit 0 (1714 jobs) at f1cae4b57.
- Landed: `PriorInterface.lean` (105 lines: 15 header + orig :4988-:5076 byte-identical +
  `end`; imports CarrierKv; slab diff vs ORIG_SHA EMPTY).
- NOT landed: `MergedQuarantine.lean` — extraction executed byte-identically but build went
  RED (4 unknown-identifier errors in part 2, orig :8653/:8676/:8687/:8700, referencing the
  now-file-scoped private helpers). Fixed forward: part-1 slab restored byte-identically to
  the monolith; `MergedQuarantine.lean` removed.
- Monolith now 4,238 lines: orig :1-:28 (lines 1-28) + 5 module imports Base/CarrierK1V/
  CarrierKv/RefutationF2/PriorInterface (lines 29-33) + orig :29-:87 (lines 34-92) +
  orig :5077-:5332 (lines 93-348) + orig :5360-:9249 (lines 349-4238).
  **Mapping for Phase 5**: orig L in [5077, 5332] is at monolith line L - 4984;
  orig L in [5360, 9249] is at monolith line L - 5011. Phase 5 slabs: :5857-:6106 =
  monolith 846-1095; :6107-:6733 = monolith 1096-1722.
- Byte-identity gates all EMPTY at commit state (orig :1-:28, :29-:87, :5077-:5332,
  :5360-:9249 against the monolith; :4988-:5076 against PriorInterface.lean lines 16-104).
- Sorry count: 0 introduced (all grep hits are prose in docstrings). Pre-existing sorryAx
  infos in BXCanonical unrelated (same as phases 1-3). Axiom count unchanged (2, pre-existing).

## Key Decisions
- Root cause is a plan sequencing defect, not an implementation defect: Lean `private` is
  file-scoped; part 2 consumes part 1's private helpers (`kvE_gate` :5172, `kvE_body` :5193,
  `kvE_pinArrangements` :5521, `kvE_pinDisjunct` :5531, `kvE_exclConj` :5544, `kvE'_body`
  :5562), and orig :8588-:8589 documents "same-module `private` reuse ... is legal" as the
  design assumption. Phases 4-6 would leave part 2 cross-module.
- Part-2 pull-forward rejected: `kvE2_body` (:8608) uses `kvE_subChain2V` (:6955, SubBracket2V,
  Phase 6), forcing MergedQuarantine → monolith import while monolith → MergedQuarantine —
  a cycle.
- De-privatization rejected: violates the settled binding constraint (ZERO token edits;
  do-not-edit helpers stay private).
- Fix-forward (no git rollback): monolith reassembled from HEAD-committed header + ORIG_SHA
  slabs, verified by diff gates, then committed green as sub-step 4.1.
- PriorInterface import retained in the monolith import block (line 33); MergedQuarantine
  import removed with the file.

## Sorry Inventory
[] (empty — nothing deferred)
