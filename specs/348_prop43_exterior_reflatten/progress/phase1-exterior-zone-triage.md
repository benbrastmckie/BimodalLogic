# Task 348 Phase 1 Progress — Exterior zone-determination lemma (residue triage)

- **Status**: done (all objectives green)
- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11
- **Dispatch**: hard mode, single-phase (phase_number = 1)

## Preflight checks (recorded per plan "Done when")

| Check | Result |
|-------|--------|
| Full `lake build` (pre-change tree) | GREEN (exit 0) |
| `#print axioms bracketEndChar_kvE2_correct_two_prior_frag` | {propext, Classical.choice, Quot.sound} |
| `#print axioms bracketEndChar_kvE2_sound_two_prior_frag` | {propext, Classical.choice, Quot.sound} |
| `#print axioms bracketEndChar_kvE2_complete_two_prior` | {propext, Classical.choice, Quot.sound} |
| R6 `LinearOrder M.carrier` exposure | VERIFIED — instance `OrderedMonadicStructure.carrier_order` (MonadicFO.lean:103-109); `not_and_or`/`not_le` split compiles in `kvE2_exterior_zone_triage` |

## Objectives

| Objective | Status | Delivered as |
|-----------|--------|--------------|
| Zone-determination lemma (plan shape) | done | `kvE2_exterior_zone_determination` (ExteriorZoneTriage.lean) |
| Per-side workhorses | done | `kvE2_exterior_zone_determination_past` / `_fut` |
| Bit-transfer helpers (SW:12642-12649 pattern in reverse) | done | `kvE2_zoneBit_below` / `kvE2_zoneBit_above` |
| Off-zone exterior refutation corollary | done | `kvE2_exterior_offZone_notRealizable` |
| Phase-8-facing triage disjunction (additive) | done | `kvE2_exterior_zone_triage` |

## Verification (phase gate)

- Scoped build new module: GREEN (first compile, no errors/warnings in new file)
- Consumer builds (`NfMultiAnchorBridge` aggregator, `KampPrior`): GREEN
- Full `lake build` (post-change): GREEN (1721 jobs)
- `#print axioms` on ALL 7 new declarations: exactly {propext, Classical.choice, Quot.sound}
- `grep -n sorry` on new file: empty; vacuous-definition grep: 0
- Frozen files: SharedWitness.lean / SubBracket2V.lean byte-unchanged; OuterGate.lean untouched;
  only additive change outside the new file is one import line in the
  `NfMultiAnchorBridge.lean` aggregator (wires the module onto the live path via KampPrior)

## Key facts for downstream phases

- Both genuine residue zones are CONSTANT specs: `kvE2_sep_zPastX3 i = (true, false)` and
  `kvE2_sep_zFutT3 i = (false, true)` for all `i : Fin 3` — this made determination uniform
  in the zone index (single `funext` + 3-way env-point order chain per side).
- `kvE2_exterior_zone_triage` has exactly the `hexclExt` guard inventory
  (`hxw`, `hwt`, `hguard : ¬(x ≤ x1 ∧ x1 ≤ t)`) and yields
  `(x1 < x ∧ zone = zPastX3) ∨ (t < x1 ∧ zone = zFutT3)` — the split Phase 8 applies at
  SW:12788 before calling per-side `_sound`.
- Pre-existing `KampPrior.lean:212` strategic sorry untouched (309-owned, R1 scope decision).

## Commits

- 8a2f401bb — task 348 phase 1: exterior zone-determination lemma + preflight re-verify
