# Task 348 Phase 5 Progress — Past-side mirror: construction + soundness

- **Status**: done
- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11
- **Commit**: 539995814 (`task 348 phase 5: past-side clause family kvE2_extNegPast + _sound sorry-free`)

## Delivered (new leaf module, 656 lines)

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegationPast.lean` — the
`Since`-navigated past-side mirror of the Phase-3 future-side family, per the Phase-2
BINDING signature modulo side (H6 clean, no drift):

| Declaration | Role |
|---|---|
| `kvE2_pastGapBit`/`kvE2_pastRayBit`/`kvE2_pastSelfBit` | σ-channel readers (gap `(x1,x)`, ray `(−∞,x1)`, self) |
| `kvE2_pastGapList`/`kvE2_pastRayList` | Fintype-filter profile lists |
| `kvE2_pastPossibleZones` + `kvE2_pastZoneClass` | nine-zone classification at exterior `x1 < x` |
| `kvE2_pastAdmissible` + `kvE2_pastRealizer_admissible` | syntactic order-admissibility; realizer forces it (zone marking via Phase 1 `kvE2_exterior_zone_determination_past`) |
| `kvE2_pastGapD`/`kvE2_pastRayD`/`kvE2_pastRayForm`/`kvE2_pastEnd`/`kvE2_pastChain`/`kvE2_pastPos` | clause construction (Cor 5.4(1) exterior analog; Lemma 5.3 O_n device time-reversed) |
| `kvE2_extNegPast` | the complement clause family, `(kvE2_pastPos σ).neg`, anchored at `x` |
| `kvE2_pastMaxPick` + `kvE2_pastChainBuild` (private) | maximal-witness chain sort (mirror of MinPick/ChainBuild) |
| `kvE2_extNegPast_sound` | **the Phase-5 deliverable**: clause at `x` → no `x1 < x` realizes σ, under `(hxw, hwt)` ONLY |

## Time-reversal dictionary (recorded in the module docstring)

anchor `t`→`x`; `untl`→`snce`; `zFutT3`→`zPastX3`; gap coupling `(true,false)`→`(false,true)`;
ray coupling `(false,true)`→`(true,false)`; below-`t` key `(zs ⟨2⟩).2 = false` → above-`x`
key `(zs ⟨1⟩).1 = false`; min-pick → max-pick; determination `_fut` → `_past`.

## Key decisions

1. **Local past-side copies, no ExteriorNegation.lean edits** (plan task-1 option A, per
   Phase-4 handoff + H7 territory): future-side privates (`CharZone4`, `CharZone3'`,
   `BelowClass`, `MinPick`, `ChainBuild`, `nf_profile_unique/exists`) are unreachable;
   copied side-neutral ones verbatim, time-reversed the rest. Dedupe deferred to Phase 7.
2. **Reused public side-neutral lemmas**: `nf_depth0_char_correct'`, `kvE2_futFreshProfile`
   (fresh-profile read has no side content despite the name).
3. **Additive strengthening mirrored from Phase 3**: `_sound` holds for ALL σ with NO
   `zPastX3`-marking hypothesis (a realized exterior σ is forced marked).
4. **`kvE2_pastAboveClass` case order**: `hxv.lt_or_eq` first (strict-above trichotomy
   before the `v = x` boundary) — cleaner than the future file's leading `lt_trichotomy`.

## Verification (phase gate)

- Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExteriorNegationPast`: GREEN
  (first compile, zero errors in the new file).
- Full `lake build`: GREEN (1721 jobs, matches Phase-4 baseline).
- `#print axioms` on `kvE2_extNegPast_sound`, `kvE2_pastRealizer_admissible`,
  `kvE2_pastZoneClass`, `kvE2_extNegPast`, `kvE2_pastPos`, `kvE2_pastAdmissible` =
  `{propext, Classical.choice, Quot.sound}` exactly.
- Repo sorry census 163 = Phase-4 baseline; zero sorries in task files (the single grep
  hit is the word "sorry-free" in ExteriorNegation.lean's docstring).
- No vacuous definitions; no new `axiom` declarations.

## Notes for Phase 6 (past-side completeness)

- Phase 6 extends THIS file. Needed additions (mirror the Phase-4 kit, all private in
  ExteriorNegation.lean): `kvE2_pastAnyBit` + `_correct` analog? — NO: the below-`t`
  pin `hbelow`/`kvE2_futAnyBit` is qnf-side and SIDE-NEUTRAL in its zone-3 argument;
  Phase 6 should re-examine whether the SAME `kvE2_futAnyBit qnf` bits serve the past
  side's six at-or-above-`x` zones (they range over ALL `ZoneSpec 3`), with the
  six-constant disjunction guard swapped to the above-`x` set {zAtX3..zFutT3}.
- Past mirrors still missing (Phase-6 obligations): `kvE2_pastZone4_above_iff` (lift
  at-or-above-`x` zone-3 facts to zone-4 coupling `(false,true)`, key `(zs ⟨1⟩).1 = false`),
  `kvE2_pastChainDestruct` (converse of `kvE2_pastChainBuild`), `kvE2_pastSigma_atom`
  (atom-layer for a MINIMAL exterior point of fresh profile over an `henv`-pinned base).
- Binding hypothesis inventory modulo side: pins `(hxw, hwt, henv, hbelow-analog)` +
  σ-side `hbase : nf0_dropFresh σ.1 = qnf.1` + `hbits` with the six-constant disjunction
  guard (Phase-4 decision 1 applies mutatis mutandis).
