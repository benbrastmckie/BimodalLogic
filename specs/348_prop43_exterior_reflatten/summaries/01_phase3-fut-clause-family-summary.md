# Task 348 Phase 3 Implementation Summary — Future-side clause family

- **Task**: 348 - prop43_exterior_reflatten (lean4, hard mode, per-phase dispatch)
- **Phase**: 3 of 8 (single-phase dispatch; phases 1-2 previously completed)
- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11
- **Status**: COMPLETED — build green, sorry-free, axiom-clean

## What Was Implemented

Extended `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean`
(840 → 1323 lines, +483; one additive import: `ExteriorZoneTriage`), generalizing the
Phase-2 spike to the full finite σ alphabet in the BINDING signature (H6, zero drift).

### Declarations delivered

| Declaration | Role |
|---|---|
| `kvE2_futGapBit` / `kvE2_futRayBit` / `kvE2_futSelfBit` | σ.2 channel readers at the three `(t,∞)`-side zone-4 specs |
| `kvE2_futGapList` / `kvE2_futRayList` | nodup `Fintype`-filter profile lists (S_gap, S_ray) |
| `kvE2_futPossibleZones` | the nine order-possible zone-4 specs at exterior `x1` |
| `kvE2_futZoneClass` | classification: any realized `zoneHolds` spec is one of the nine |
| `kvE2_futAdmissible` | syntactic order-admissibility Bool (zone marking, off-fiber, impossible-zone, self-bit) |
| `kvE2_futFreshProfile` | atom-layer fresh-profile read (shared with Phase 4) |
| `kvE2_futRealizer_admissible` | a realizer at exterior `x1` forces admissibility (order bits only) |
| `kvE2_futGapD` / `kvE2_futRayD` / `kvE2_futRayForm` / `kvE2_futEnd` | gap guard, ray disjunction, exact-ray-content form, endpoint description |
| `kvE2_futChain` | D-guarded Until chain (Cor 5.4 O_n / Lemma 5.3 F-chain device, general length) |
| `kvE2_futPos` | admissibility-gated permutation disjunction of chains (positive local-existence form) |
| `kvE2_extNegFut` | **the clause family**: `(kvE2_futPos σ).neg` |
| `kvE2_futMinPick` / `kvE2_futChainBuild` (private) | minimal-witness sorting + chain construction |
| `kvE2_extNegFut_sound` | **family soundness**, sorry-free |

### Signature compliance (H6)

Phase-2 binding signature reproduced verbatim: clause = (Until-navigated positive
local-existence form).neg; `_sound` under `(hxw : x < w, hwt : w < t)` ONLY — no semantic
hypothesis on `M`, no qnf parameter. The spike is literally the `S_gap = {χmid}`,
`S_ray = ∅` instance of the family shape.

### Deviation (additive strengthening)

`kvE2_extNegFut_sound` is proved for ALL σ, without the plan's `zFutT3`-marking
hypothesis: a σ realized at exterior `t < x1` is forced `zFutT3`-marked by Phase 1's
`kvE2_exterior_zone_determination_fut` (consumed inside `kvE2_futRealizer_admissible`).
Annotated inline in the plan checklist.

## Final Verification

- Scoped + full `lake build`: GREEN (1721 jobs, matches Phase-2 baseline).
- `#print axioms` = `{propext, Classical.choice, Quot.sound}` on all four delivered public
  lemmas AND the preserved spike lemmas (`kvE2_extNegFutSpike_sound`/`_complete`,
  `kvE2_futAnyBit_correct`) — no regression.
- Sorry census: 0 in ExteriorNegation.lean; 0 introduced anywhere (repo-wide 163 all
  pre-existing, out of task scope). Vacuous definitions: 0 new. Axioms: 0 new.

## Phase-4 Obligations (recorded)

`_complete` will need, in addition to the pins `(henv, hbelow)`: `nf0_dropFresh σ.1 = qnf.1`
and σ's below-`t` bits = `kvE2_futAnyBit qnf` (syntactic, decidable). The if-gate in
`kvE2_futPos` hands Phase 4 admissibility for free (else-branch is `⊥`). Details in
`progress/phase3-fut-clause-family.md`.

## Commits

- `a2c4a2552` task 348 phase 3: future-side clause family kvE2_extNegFut + _sound sorry-free
- (this dispatch's closing commit) task 348 phase 3: complete
