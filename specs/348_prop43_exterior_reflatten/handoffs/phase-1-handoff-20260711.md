# Task 348 Phase 1 Handoff (2026-07-11)

## Immediate Next Action

Wave 1 counterpart: Phase 2 (R2 GO/NO-GO spike — one concrete future-side σ-clause) in NEW
file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean` (disjoint
territory). Phase 1's outputs are not needed by Phase 2; Phases 3-8 are gated on Phase 2 GO.

## Current State

- Phase 1 of 8 COMPLETED. Full `lake build` GREEN (1721 jobs). Zero new sorries.
- New file: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorZoneTriage.lean`
  (180 lines, 7 declarations, all axiom-clean {propext, Classical.choice, Quot.sound}).
- Wired onto the live path via one additive import in `Kamp/NfMultiAnchorBridge.lean`
  (aggregator, imported by KampPrior.lean).
- Preflight re-verification recorded in `progress/phase1-exterior-zone-triage.md`:
  the three preserved 335 gate theorems are axiom-clean; R6 LinearOrder split verified.

## Key Decisions (settled in this phase)

1. **Uniform-index proof shape**: both residue zone specs are constant functions
   (`zPastX3 ≡ (true,false)`, `zFutT3 ≡ (false,true)`), so determination is
   `funext i` + a per-index `lt`-chain, via two reusable bit-transfer helpers
   (`kvE2_zoneBit_below`/`_above`) that take the raw depth-0 atom clause
   (`∀ a, atom_eval M (Fin.cons x1 env3) a ↔ σ0 a = true`) — Phases 3-6 can reuse these
   against any 3-point env.
2. **Phase-8 consumption shape**: `kvE2_exterior_zone_triage` matches the `hexclExt`
   binder inventory (order bits + exterior guard) and returns the per-side disjunction
   `(x1 < x ∧ zone = zPastX3) ∨ (t < x1 ∧ zone = zFutT3)`; the corollary
   `kvE2_exterior_offZone_notRealizable` matches the SW:12627 interior-discharge signature
   style with the zone-negation guard of the narrowed `hexclExt` (SW:12713).
3. Aggregator import (additive, within Kamp/ territory) chosen over leaving the module
   off-path, so full-project builds gate every later phase against it.

## Sorry Inventory

Empty for task 348 work: no sorries introduced in this phase; none inherited.
(Pre-existing, out-of-scope: `KampPrior.lean:212` strategic sorry — 309-owned per the plan's
R1 scope decision; NOT part of 348's inventory.)

## References

- Plan: `specs/348_prop43_exterior_reflatten/plans/01_prop43-exterior-reflatten.md`
  (Phase 1 marked [COMPLETED]; Postmortem Constraints and Phase 2 NO-GO protocol binding)
- Progress: `specs/348_prop43_exterior_reflatten/progress/phase1-exterior-zone-triage.md`
- Commit: 8a2f401bb
