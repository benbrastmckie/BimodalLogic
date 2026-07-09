# Task 337 — Implementation Summary (v4 dispatch, 2026-07-09)

## Outcome: PARTIAL — stale stop-guard overturned, build scoped for per-phase re-dispatch

This dispatch executed the delegation's **mandatory precondition-verification gate** against the
CURRENT `SharedWitness.lean` (now 4174 lines, vs. the ~2600 the prior stop-guard examined). The
gate **PASSED**: the prior dispatch's `status=blocked` is **stale and is overturned**. No Lean was
written (no RED risk taken); `SharedWitness.lean` remains byte-for-byte untouched and GREEN
(scoped `lake build` exit 0).

## Primary deliverable: the stop-guard is resolved

The prior blocker's root cause was `kvE2_sepSlotGIdx` reading a per-owner-**region** honest tuple
`(3r,3r+1,3r+2)` with ties, making `kvE2_sepSlotsLOf` non-value-sorted within tie-blocks and
`halign` unprovable. **Task 340 Phases 5–7 dissolved this**: it landed the per-INDIVIDUAL-slot
value-faithful global index

- `kvE2_sepSlotHonestGIdx` (SW:2979) — `kvE2_ordRank` of the lex family
  `kvE2_sepSlotG = (value, slotIndex)` (SW:2945),
- `kvE2_sepSlotHonestGIdx_mono` (SW:2990) — value-faithful (`value a < value b → GIdx a < GIdx b`),
- `kvE2_sepSlotHonestGIdx_injOn` (SW:3012) — injective on the slot family (no ties),
- `kvE2_sepHonestOrder` (SW:3063) + `kvE2_sepHonestOrder_mem_arr'` (SW:3095) — the honest carrier
  member on that payload.

The index's own docstrings (SW:2975-2978, 3059-3062) state verbatim that it "replaces the tied
`(3r,3r+1,3r+2)` owner-region tuple the 337 stop-guard refuted." Per the delegation decision rule
this is the **"derivable from landed 340 lemmas"** case → proceed to build; it is NOT a genuine
missing precondition. **No task-340 re-dispatch is required.**

## Why no Lean landed this dispatch (honest scoping, not deflection)

Full engine-API analysis (`k1v_sorted_realizationK` SubBracket2V.lean:633; `interleaveK` :453;
`IntervalPattern.holds_eq_succ` ExistsForallNF.lean:188; `k1v_bracket_construct3` :720;
`kvE2_sepDisjunct_extract` SW:3435) confirmed the remaining build is a genuine multi-phase
construction (plan-04 P1–P5, ~4–5h) with three concrete subtleties, each grounded in exact
signatures:

1. **Value ties** — distinct owners may share `kvE2_sepSlotValue` (lex-index tiebreak in
   `kvE2_sepSlotG`, SW:2939-2949), so bracket witnesses must be the engine's fresh
   strictly-increasing `interleaveK ps`, not slot values. The direct `ws i = slotValue` shortcut
   is provably wrong.
2. **Cross-`w` slots** — `.rXW`/`.lWT` straddle `w` (SW:2820, 296-303), so the bracket pivot at
   index `|lL|` is a fresh point above all left-region values, not the model `w`.
3. **Refined-conjunction segments** — the three `holds_eq_succ` segment families realize
   per-`σ` exclusion forms keyed structurally (`take i .contains`), discharged via
   `kvE2_sepSegForm_excludes` (SW:3768) / `kvE2_sepSeg{L,R}ForSub'_at_sound` (SW:4052/4133).

Attempting to force this in one run would risk a RED build — explicitly forbidden by the
delegation. The full turnkey continuation (interface derivation map + per-phase plan + the
immediate halign bridge-lemma proof sketch) is recorded in `.orchestrator-handoff.json`.

## Phases

| Phase | Status | Notes |
|-------|--------|-------|
| 1 | IN PROGRESS | Stop-guard resolved; regions-assembly ingredients identified (see handoff). |
| 2–5 | NOT STARTED | Engine invoke → single-`ptW` bracket match → endpoint discharge → axiom/faithfulness gate. |

## Verification

- `sorry` count: 0 (no Lean written)
- vacuous defs: 0
- new axioms: 0
- `lake build` (scoped, `...NfMultiAnchorBridge.SharedWitness`): GREEN (exit 0)
- `kvE2_sepCoincidentOrder_mem_arr'` (v3 asset) and all 334/336/338/339/340 results: untouched.

## Immediate next step

Re-dispatch 337 Phase 1 (`skill-lean-implementation-hard`), starting with the halign bridge lemma
`kvE2_sepSlotGIdx (kvE2_sepHonestOrder …) s = kvE2_sepSlotHonestGIdx … s` (proof sketch in the
handoff), then regions assembly from `kvE2_sepHonestAnchorBundleL/R`.
