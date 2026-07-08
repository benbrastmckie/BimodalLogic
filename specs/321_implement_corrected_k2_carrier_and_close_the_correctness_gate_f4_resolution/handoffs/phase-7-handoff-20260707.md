# Phase 7 Handoff — Joint Carrier `kvE2_sepBody` (O1 + O1b + O2)

- **Session**: sess_1783487859_3f6358
- **Date**: 2026-07-07
- **Status**: Phase 7 COMPLETED (commits 5f3d4cdab, c9dcc0c0e + wrap-up commit)

## Immediate Next Action (Phase 8 = O3)

From a realized joint disjunct of `kvE2_sepBody`, extract the shared witness `w` (from the
`ptW` slot at bracket position `lL.length`; `x < w < t` from the bracket's own range) and,
for every positive interior σ, the per-σ bundle `(x1_σ, hxx1, hx1t, hanchor, hbelow)`.
Entry point: `kvE2_sepBody_holds_iff` gives `∃ lL ∈ kvE2_sepArrL qnf, ∃ lR ∈ kvE2_sepArrR
qnf, (kvE2_sepDisjunct charBase charK qnf lL lR).2.holds M atomMap x t`. Consume
`BracketFormula.leftPart_holds`/`rightPart_holds` (`VecEAFormula.lean:375/:412`) for the
shared-`w` pivot at index `lL.length`.

## Current State

- NEW module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (943 lines) + ONE import line in the umbrella `NfMultiAnchorBridge.lean`. Nothing else touched.
- Full `lake build` green; all four public theorems axiom-clean
  (`[propext, Classical.choice, Quot.sound]`); 0 sorries; litmus grep 0 hits; no vacuous defs.

## Landed API (all top-level, per the crux failed-closer-3 lesson)

| Object | Role |
|--------|------|
| `kvE2_sepBody charBase charK qnf : VVecEA2` | The joint carrier (O1); dite on `kvE2_sepGate` |
| `kvE2_sepGate qnf : Prop` | Depth-2 gate: outer off-fiber ∧ outer 7-zone ∧ inner off-fiber (all positives) ∧ inner 9-zone (LEFT-interior positives) |
| `kvE2_sepDisjunct charBase charK qnf lL lR : Σ n, VecEA2 n` | Flat-bracket disjunct builder |
| `kvE2_sepArrL/R qnf` | Interleaving sets = `slotsL/R.permutations.filter kvE2_sepValid` |
| `kvE2_sepSlotsL/R qnf`, `kvE2_sepSlotsLFor/RFor σ` | Canonical tagged slot lists (per-σ blocks) |
| `KvE2SepSlot sig` | Tagged slot inductive: `lXU/lX1/lUW/lWT` (left-interior σ), `rXW/rWX1/rX1/rX1T` (right-interior σ) |
| `kvE2_sepValid`, `kvE2_sepSlotLe`, `kvE2_sepSlotSub`, `kvE2_sepSlotRank` | Region-rank interleaving validity |
| `kvE2_sepBracketN lL ptW lR segs` | Fresh N-slot builder with PER-INDEX segment types |
| `kvE2_sepSegs/SegLAt/SegRAt/SegLForSub/SegRForSub` | Refined-conjunction segments, keyed by fresh-slot position via `(l.take i).contains` |
| `kvE2_sepEpL/EpR/PtW` | Joint endpoint predicates + ONE shared `ptW` slot |
| `kvE2_sepPos/PosIn/HasPos`, `kvE2_sepBits/S/SegForm/Proj3/Proj4/Lit` | Enumeration + formula pieces |
| `kvE2_sep_z*3` (7 outer), `kvE2_sep_z*4`/`kvE2_sep_zWX1` etc. (9 inner) | Zone constants; `kvE_sub2_zXU/zUW/zWT` consumed from SubBracket2 |
| `kvE2_sepBody_holds_iff` (O2) | Membership collapse via `VVecEA2.holds_flatMap_map` + `dif_pos` |
| `kvE2_sepBody_gate_fail` | `¬gate → disjuncts = []` |
| `kvE2_sepBody_nonvacuous` (O1b), `kvE2_sepGate_holds_of_honest` | Non-vacuity + honest gate discharge |
| private: `kvE2_sep_zone3_consistent`, `kvE2_sep_dropFresh_eq`, pairwise/validity helpers | O1b plumbing (fresh arity-3 analogs; templates only) |

## Key Decisions (this phase)

1. **σ-placement classification** (plan's O1 sketch was silent): positive subs classified by
   `nf0_zoneSpec σ.1` into 7 outer zones. Interior classes `zXW3`/`zWT3` get tagged slot
   groups (BOTH sides of the shared `w`); the 5 non-interior classes ride σ-level `charK`
   `Since`/`Until`/at-anchor literals in `epL`/`ptW`/`epR` (the shape the landed
   `kvE_nonInterior_*` dischargers serve).
2. **Interleavings = permutations + rank filter**: `kvE2_sepValid` demands same-σ slots in
   non-decreasing region rank; cross-σ order free. Canonical lists proven valid
   (`kvE2_sepSlotsL_valid`/`_R_valid`) for non-vacuity membership.
3. **Inner nine-zone gate clause LEFT-interior only**: stated with the verbatim
   `SubBracket2V.lean:1400-1408` pattern set so `kvE_subBracket2V_gate_holds_of_honest`
   discharges it directly. The mirrored right-interior clause (needs a mirrored
   zone-consistency case bash) is deferred; adding it later is file-internal and additive.
4. **Bit-pattern reuse**: `kvE_sub2_zXU`/`kvE_sub2_zWT` patterns are placement-generic
   (same bits read `(x,w)`/`(x1,t)` for right-interior σ), so only 3 genuinely new interior
   ZoneSpec-4 constants were needed (`zWX1`, `zAtX1R`, `zAtWR`).
5. **Private `DecidableEq (ZoneSpec n)` instance** added file-locally (the type synonym is a
   plain `def`; instance search cannot see through it).

## Watch Items for Phases 8-10

- Right-interior (`zWT3`) positives have slots but NO landed correctness kit (the per-σ pair
  serves `x < x1 < w` only). O3/O4 may need either a mirrored kit fragment or a Phase-10
  narrowing; the F4 `ℤ` counterexample's σ'' is left-interior, so N-fragments remain testable.
- Bracket points inside another σ's zone are not covered by segment exclusions (points sit
  between segments) — this is exactly the O4 crux residue; do NOT patch with chain splicing
  or `x1 < e_i` literals.
- `kvE2_sepGate` may be extended additively in later phases (nothing outside
  `SharedWitness.lean` consumes it yet); O1b/O2 proofs would be updated in the same dispatch.

## Sorry Inventory

Empty. No sorries introduced; none inherited (prior handoff carried no sorry_inventory).
