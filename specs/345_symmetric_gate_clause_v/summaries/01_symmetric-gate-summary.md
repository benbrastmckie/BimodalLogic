# Summary: Symmetrize kvE2_sepGate with RIGHT inner-consistency clause (v)

- **Task**: 345 — symmetric_gate_clause_v
- **Status**: implemented (all 4 phases COMPLETED)
- **Session**: sess_1783723095_edd5a7_345
- **File touched**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (only)

## What landed

Added clause (v) — the zWT3 RIGHT-owner mirror of clause (iv) — to `kvE2_sepGate`, per
Rabinovich 2014 Cor 5.4(1)/(2) mirror pair (report 01). Clause (v) turns the former free,
LEFT-unsatisfiable `hInnerR` premise into a **gate consequence**, which was then removed from the
three landed 344 `_frag` lemmas, unblocking the 335 outer fold.

## Per-phase results

| Phase | Scope | Outcome |
|-------|-------|---------|
| 1 | Add clause (v) to gate def; discharge in `kvE2_sepGate_holds_of_honest` | Green; gate {propext, Quot.sound}, holds_of_honest {propext, Classical.choice, Quot.sound} |
| 2 | Drop `hInnerR` from `kvE2_sepGateAtPin_fragR`; derive from `hg.2.2.2.2` (clause v) | Green (committed jointly with 3) |
| 3 | Thread removal through `kit_sound_frag` + `outer_fold_frag` | Green; all three `_frag` axiom-clean |
| 4 | Consumer sweep, freeze-diff, axiom check, 335 handback | Full build green (1720 jobs) |

## Changed declarations (with line numbers, post-change)

- `kvE2_sepGate` (SW:1259) — +1 conjunct (clause v).
- `kvE2_sepGate_holds_of_honest` (SW:2802) — `refine` 4→5 goals; +1 discharge block closing
  clause (v) directly via the landed `kvE2_sep_zone4_consistentR` + the depth-1 fold `h_zone` iff
  (no new `kvE2_sepHonestBundleR` closer needed).
- `kvE2_sepInnerConsistentR` (def) and `kvE2_sep_zone4_consistentR` (theorem) — **relocated**
  from ~SW:11295/11309 to above the gate def / above `holds_of_honest` (forward-reference
  requirement). Bodies verified **byte-identical**; position changed only.
- `kvE2_sepGateAtPin_fragR` (SW:11553) — dropped `hInnerR` param; `h_bwd` classifier now from
  `hg.2.2.2.2 σ hσ0true hz`.
- `kvE2_sepBody_kit_sound_frag` (SW:12487) — dropped `hInnerR` param + call-site pass-through.
- `kvE2_outer_fold_frag` (SW:12529) — dropped `hInnerR` param + call-site pass-through.

### Deviations (H7 consumer-sweep, flagged & minimal)

Appending clause (v) makes clause (iv) the penultimate conjunct, shifting its positional
projection `hg.2.2.2` → `hg.2.2.2.1` at exactly two consumer sites (one-token edits, no signature
change):
- `kvE2_sepHgate_innerNine` (SW:6837)
- `kvE2_sepGateAtPin_fragL` (SW:11238)

All other gate consumers and decision sites appear in no diff hunk — compiled unmodified (inert).

## Final `_frag` signatures (335's resume consumes these)

- **`kvE2_sepGateAtPin_fragR`**: params now (…gate order bits…, `M`, `x t`, `σ0`, `hfrag`,
  `hz : nf0_zoneSpec σ0.1 = kvE2_sep_zWT3`, `hcorrK`, `h`). No `hInnerR`.
- **`kvE2_sepBody_kit_sound_frag`**: params now (…gate order bits…, `M`, `x t`, `hfrag`,
  `hcorrK`, `h`). No `hInnerR`.
- **`kvE2_outer_fold_frag`**: params now (…gate order bits…, `M`, `x t`, `h`, `hfrag`, `hcorrK`,
  `hexcl`). **No `hInnerR`.** Remaining discharge obligations for 335 are exactly
  `{hcorrK, hexcl}`.

## Verification

- Full `lake build` green (1720 jobs).
- Axiom-clean: gate def {propext, Quot.sound}; the four theorems {propext, Classical.choice,
  Quot.sound}. Zero `sorryAx` on live paths. No new axioms, no vacuous defs.
- Freeze-diff: SharedWitness.lean is the only touched `.lean`; relocation byte-identical.

## Commits

- `758a5214b` task 345 phase 1: add clause (v) + discharge holds_of_honest
- `521163638` task 345 phase 3: drop hInnerR from fragR + kit_sound_frag + outer_fold_frag
- Phase 4 verification commit (this dispatch).
