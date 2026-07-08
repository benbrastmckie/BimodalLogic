# Task 331 Phase 3 Handoff (2026-07-07, sess_1783475175_afdf09)

## Immediate Next Action
Phase 4: extract slab :4988-:5076 (ORIG_SHA coordinates) into
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/PriorInterface.lean`
(imports `CarrierKv`; protected byte-identical, token edits NONE), then slabs :5077-:5766
**minus the already-relocated `nf_eval_depth1_fold_iff` block (:5333-:5359 incl. trailing
blank — already gone from the monolith)** plus :5767-:5856 into `MergedQuarantine.lean`
(imports `PriorInterface`, quarantine banner per plan; leave `end` in place — Phase 7 inserts
before it).

## Current State
- Phase 3 [COMPLETED]; `lake build` exit 0 (1713 jobs, +2 from the two new modules).
- ORIG_SHA = `2146e9c05d144b54495f566169a08a7e734bf645` (in `specs/331_.../.orig-sha`).
- Monolith now 4,326 lines: orig :1-:28 imports + Base/CarrierK1V/CarrierKv/RefutationF2
  imports (lines 29-32) + orig :29-:87 (lines 33-91) + orig :4988-:5332 (lines 92-436) +
  orig :5360-:9249 (lines 437-4326).
  **Mapping for Phase 4**: orig L in [4988, 5332] is at monolith line L - 4896;
  orig L in [5360, 9249] is at monolith line L - 4923. The fold_iff block :5333-:5359
  (block :5333-:5358 + trailing blank :5359) is EXCISED — Phase 4's 5077-5766 slab must be
  assembled as two sub-slabs: :5077-:5332 (monolith 181-436) and :5360-:5766 (monolith
  437-843), diffed separately against ORIG_SHA.
- `CarrierKv.lean` = 482 lines: 17 header lines (import CarrierK1V / provenance / namespace /
  opens); main slab body at lines 18-454 (`tail -n +18 | head -n 437` for re-checks);
  relocated fold_iff block at lines 455-480 (`tail -n +455 | head -n 26`); blank 481;
  `end` 482.
- `RefutationF2.lean` = 963 lines: 15 header lines (import CarrierKv / quarantine provenance /
  namespace / opens); slab body at lines 16-962 (`tail -n +16 | head -n 947`); `end` 963.
- Sanctioned edits landed: 1 de-privatization (`atomKind_castLE`, CarrierKv.lean:54) +
  the fold_iff relocation. Diff gates showed exactly these, nothing else.
- Sorry count: 0 introduced (byte-copy; grep on touched files shows no non-docstring hits).
  Pre-existing sorryAx infos in BXCanonical are unrelated (same as phases 1-2).

## Key Decisions
- fold_iff block bounds resolved as orig :5333-:5358 (docstring `/-- **Depth-1 per-sub
  obligation decomposition**...` at :5333, `theorem nf_eval_depth1_fold_iff` at :5344, proof
  end :5358); trailing blank :5359 excised with it so the monolith keeps a single blank
  between the surviving :5331 `rfl` and the :5360 Phase-13.3 header.
- In CarrierKv.lean the fold_iff block is appended directly after the main slab's own
  trailing blank (orig :4040), followed by one scaffold blank, then `end`.
- Monolith import block: CarrierKv and RefutationF2 imports ADDED after the CarrierK1V
  import; Base/CarrierK1V imports retained (redundant transitively but literal to the plan).
- Extraction header template reused from phases 1-2 (imports / blank / provenance `/-! -/` /
  blank / namespace / blank / opens :82-:86 / blank / slab / `end`).
- Stale docstring cross-refs in surviving monolith text (e.g. "`nf_eval_depth1_fold_iff`
  below") left byte-identical per the semantics-preserving constraint; Phase 8 fixes stale
  comment line-refs.

## Sorry Inventory
[] (empty — nothing deferred)
