# Task 331 Phase 5 Handoff (2026-07-07, sess_1783475175_afdf09)

## Immediate Next Action
Dispatch Phase 6: extract `SubBracket2V.lean` (protected faithful-API slab, orig :6734-:8607,
~1,874 lines, byte-identical, ZERO token edits) with the FAITHFUL SEPARATE-BRACKET API banner
from the plan's H3 mapping table. Imports: `SubBracket2`. **Slab location in current monolith:
lines 848-2721** (see mapping below).

## Current State
- Phase 5 [COMPLETED]; plan amendment (accepted option i) applied and committed separately.
- Commits this dispatch: 804c1aedf (plan amendment: Phase 4 rescoped to PriorInterface-only
  [COMPLETED]; Phase 7 now extracts the ENTIRE MergedQuarantine parts 1+2 + NavigatedSpine +
  umbrella), fadbbea31 (phase 5: SubBracket.lean 266 lines + SubBracket2.lean 644 lines
  extracted; monolith 4,238 → 3,363 lines).
- Full `lake build` exit 0 (1716 jobs) at fadbbea31.
- Byte-identity gates: SubBracket body vs orig :5857-:6106 EMPTY; SubBracket2 body vs orig
  :6107-:6733 exactly the 4 inventoried `private ` removals (`kvE_sub2_zXU` :6213,
  `kvE_sub2_zUW` :6217, `kvE_sub2_zWT` :6221, `kvE_sub2_zoneHolds_cons_iff` :6628); monolith
  git diff = +2 import lines, -877 slab lines, nothing else. Full monolith remainder
  re-verified byte-identical vs ORIG_SHA in three segments (below).
- De-privatizations so far: 6 (Phase 2) + 1 (Phase 3) + 4 (Phase 5) = 11 of 11 inventoried.
  Phases 6-7 have ZERO token edits remaining.
- Sorry count: 0 introduced (all grep hits are prose in docstrings; parity with orig slabs
  exact). Neither new file imports MergedQuarantine (it does not exist yet).

## Line Mapping for Phase 6 (monolith now 3,363 lines)
Monolith structure: orig :1-:28 (lines 1-28) + 7 module imports Base/CarrierK1V/CarrierKv/
RefutationF2/PriorInterface/SubBracket/SubBracket2 (lines 29-35) + orig :29-:87 (lines 36-94) +
orig :5077-:5332 (lines 95-350) + orig :5360-:5856 (lines 351-847) + orig :6734-:9249
(lines 848-3363).
- orig L in [5077, 5332] → monolith L - 4982
- orig L in [5360, 5856] → monolith L - 5009
- orig L in [6734, 9249] → monolith L - 5886
- **Phase 6 slab :6734-:8607 = monolith 848-2721** (verified: all three segment diffs vs
  ORIG_SHA empty at commit state).

## Key Decisions
- Plan amendment per accepted option (i): Phase 4 = PriorInterface only [COMPLETED]; the ENTIRE
  MergedQuarantine (parts 1+2 together, orig :5077-:5856 minus fold_iff :5333-:5359, plus
  :8608-:8826, importing PriorInterface + SubBracket2V) moved to Phase 7 alongside
  NavigatedSpine + umbrella reduction. Zero token edits ever in the quarantine.
- Monolith imports both SubBracket and SubBracket2 explicitly (consistent with the existing
  all-modules-listed import block pattern).
- Module scaffold mirrors PriorInterface.lean: provenance header, single DAG-predecessor
  import, namespace + the three `open`s copied from orig :82-:84, slab, `end`.

## Sorry Inventory
[] (empty — nothing deferred)
