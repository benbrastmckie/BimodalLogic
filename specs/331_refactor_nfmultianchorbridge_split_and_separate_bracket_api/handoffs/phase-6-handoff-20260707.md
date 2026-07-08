# Task 331 Phase 6 Handoff (2026-07-07, sess_1783475175_afdf09)

## Immediate Next Action
Dispatch Phase 7: extract `MergedQuarantine.lean` (BOTH parts in ONE file, per the Phase-4
amendment and the do-not-split postmortem rule), `NavigatedSpine.lean`, and reduce the
monolith to the import-only umbrella (~90 lines). **Boundary amendment from Phase 6 (binding):
quarantine part 2 is now :8586-:8826, NOT :8608-:8826** — orig :8586-:8607 (`open Classical
in` + the `kvE2_body` doc comment) stayed in the monolith because a doc comment cannot dangle
at the end of SubBracket2V.lean; it moves with its declaration into MergedQuarantine.

## Current State
- Phase 6 [COMPLETED] at commit d35ab2714; full `lake build` exit 0 (1717 jobs).
- `SubBracket2V.lean` created (1,893 lines = 39-line banner/scaffold + 1,852-line slab +
  2-line footer). Slab = orig :6734-:8585, byte-identical (diff EMPTY). Banner = FAITHFUL
  SEPARATE-BRACKET API (Rabinovich 2014) from the plan's H3 table, incl. cross-references to
  `neg_2var_vec_ea` / `VVecEA2.conj_struct` and the task-321 shared-interior-witness note.
- Monolith now 1,512 lines; imports 8 modules (added SubBracket2V). Remainder verified
  byte-identical vs ORIG_SHA in five segments (below). Zero token edits this phase.
- De-privatizations: still 11 of 11 (all done in Phases 2/3/5); Phase 7 has ZERO token edits.
- Sorry count: 0 introduced (single grep hit in SubBracket2V is prose "sorry-free" in a
  relocated docstring, parity with orig).

## Line Mapping for Phase 7 (monolith now 1,512 lines)
Monolith structure: orig :1-:28 (lines 1-28) + 8 module imports (lines 29-36) + orig :29-:87
(lines 37-95) + orig :5077-:5332 (lines 96-351) + orig :5360-:5856 (lines 352-848) + orig
:8586-:9249 (lines 849-1512).
- orig L in [29, 87]     → monolith L + 8
- orig L in [5077, 5332] → monolith L − 4981
- orig L in [5360, 5856] → monolith L − 5008
- orig L in [8586, 9249] → monolith L − 7737
- **Phase 7 sub-slabs**: quarantine part 1a :5077-:5332 = mono 96-351; part 1b :5360-:5856 =
  mono 352-848; part 2 :8586-:8826 = mono 849-1089 (AMENDED, includes the kvE2_body doc
  comment); NavigatedSpine :8827-:9249 = mono 1090-1512 (runs to end of file).
- All five segment diffs vs ORIG_SHA verified EMPTY at commit state (d35ab2714).
- Umbrella reduction: retain orig :1-:28 + header docstring orig :30-:79 (= mono 38-87 —
  note plan says :30-:79; the whole orig :29-:87 block is currently mono 37-95) + the 10
  import lines (Base, CarrierK1V, CarrierKv, RefutationF2, PriorInterface, MergedQuarantine,
  SubBracket, SubBracket2, SubBracket2V, NavigatedSpine). Namespace block no longer needed.

## Key Decisions
- Slab cut :6734-:8585 (not :8607): orig :8586-:8607 is `open Classical in` + the `/-- -/`
  doc comment of `kvE2_body` :8608; splitting a doc comment from its declaration does not
  parse. Partition change only — every line remains byte-identical to ORIG_SHA. Annotated
  inline in the plan (Phase 6 task 1 deviation note).
- MergedQuarantine imports: `PriorInterface` + `SubBracket2V` (plan Phase 7, verified
  acyclic — SubBracket2V does not import MergedQuarantine).
- NavigatedSpine imports: `SubBracket2V` only (all kvE2 mentions in :8827-:9249 are comments).

## Sorry Inventory
[] (empty — nothing deferred)
