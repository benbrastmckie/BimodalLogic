# Task 348 Phase 3 Progress — Future-side clause family (construction + soundness)

- **Status**: done (all objectives green)
- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean` (extended
  840 → 1323 lines, +483; additive import of `ExteriorZoneTriage`)

## Objectives

1. **σ-generic helpers** — done.
   - Channel readers: `kvE2_futGapBit`, `kvE2_futRayBit`, `kvE2_futSelfBit` (σ.2 read at the
     three `(t,∞)`-side assembled zone-4 specs).
   - Alphabet lists: `kvE2_futGapList`, `kvE2_futRayList` (`Finset.univ.toList.filter`,
     nodup by construction).
   - Zone geometry: `kvE2_futPossibleZones` (the nine order-possible zone-4 specs at
     exterior `x1`) + `kvE2_futZoneClass` (classification of any `zoneHolds` spec into the
     nine; reuses the spike's private `kvE2_futBelowClass`/`kvE2_futCharZone4`).
   - Syntactic order-admissibility: `kvE2_futAdmissible : Bool` (zone marking + off-fiber
     bits + impossible-zone bits + self-bit pattern) with `kvE2_futRealizer_admissible`
     (a realizer under `(hxw, hwt, htx1)` forces admissibility — order bits only) and
     `kvE2_futFreshProfile` (atom-layer fresh-profile read, shared with Phase 4).
2. **`kvE2_extNegFut` for all σ** — done. `(kvE2_futPos σ).neg` where `kvE2_futPos` is the
   admissibility-gated `formula_disjList` over `(kvE2_futGapList σ).permutations` of
   `kvE2_futChain` (D-guarded Until chain, Cor 5.4 O_n device) ending in `kvE2_futEnd`
   (fresh-profile char ∧ `kvE2_futRayForm` exact-ray-content). Inadmissible σ ↦ `⊥`
   positive form (clause trivially true). No qnf parameter — signature verbatim Phase 2.
3. **`kvE2_extNegFut_sound`** — done, sorry-free, under `(hxw, hwt)` ONLY. Strengthening:
   no `zFutT3`-marking hypothesis needed (forced by Phase 1's
   `kvE2_exterior_zone_determination_fut`). Support: `kvE2_futMinPick` (minimal-witness
   selection) + `kvE2_futChainBuild` (occurrence-sorted permutation chain construction;
   distinct profiles occupy distinct points via `nf_profile_unique`).

## Verification (phase gate)

- Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExteriorNegation`: GREEN.
- Full `lake build`: GREEN (1721 jobs, matches Phase 2 baseline).
- `#print axioms` on `kvE2_extNegFut_sound`, `kvE2_futRealizer_admissible`,
  `kvE2_futZoneClass`, `kvE2_futFreshProfile` AND preserved `kvE2_extNegFutSpike_sound`,
  `kvE2_extNegFutSpike_complete`, `kvE2_futAnyBit_correct`:
  all `{propext, Classical.choice, Quot.sound}`.
- Sorry census on ExteriorNegation.lean: 0. No new sorries anywhere (repo-wide census
  unchanged: 163 pre-existing, all outside task scope — Boneyard/BXCanonical/Expressiveness/
  KampPrior(309-owned)/EANegation pre-existing).
- Vacuous-definition scan: 0 new. Axiom scan: 0 new (2 grep hits are comment text).

## Phase-4 obligations recorded (unchanged from design)

`kvE2_extNegFut_complete` (Phase 4) is stated under the pins `(hxw, hwt, henv, hbelow)` PLUS
two syntactic σ-side hypotheses available at both consumption sites:
- `nf0_dropFresh σ.1 = qnf.1` (base-restriction match — the spike had this by construction);
- σ's six at-or-below-`t` gap bits agree with `kvE2_futAnyBit qnf` (the below-bit comparison;
  mismatched bit-false σ are handled at the consumption site by fact-pinning, not by the
  clause — Phase 7/8 restricts the gate conjunction to matched σ).
The if-gate in `kvE2_futPos` hands Phase 4 admissibility for free (a true positive form
certifies the gate passed, since the else-branch is `⊥`).

## Commits

- a2c4a2552 task 348 phase 3: future-side clause family kvE2_extNegFut + _sound sorry-free
