# Task 348 Phase 6 Progress — Past-side completeness

- **Status**: done
- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11

## Delivered (EXTENDED `ExteriorNegationPast.lean`: 656 → 1109 lines, +453)

Time-reversal of the Phase-4 completeness template (`kvE2_extNegFut_complete`,
`ExteriorNegation.lean:1484`), per the Phase-5 handoff porting notes:

| Declaration | Role |
|---|---|
| `kvE2_pastAbove_ge_x` (private) | at-or-above-`x` zone-3 witness sits above any `x1 < x` (mirror of `kvE2_futBelow_le_t`; above-`x` key `(zs ⟨1⟩).1 = false`) |
| `kvE2_pastZone4_above_iff` (private) | lift at-or-above-`x` zone-3 facts to zone-4 coupling `(false, true)`, and back (mirror of `kvE2_futZone4_below_iff`) |
| `kvE2_pastSigma_atom` (private) | σ's atom layer honest at a reconstructed MINIMAL exterior endpoint over an `henv`-pinned base (mirror of `kvE2_futSigma_atom`; `zPastX3` order bits `(true, false)` throughout, so `iff_of_true`/`iff_of_false` roles swap) |
| `kvE2_pastChainDestruct` (private) | converse of `kvE2_pastChainBuild`: true `Since` chain at `s` yields endpoint `x1 < s`, D-uniform gap `(x1, s)`, per-profile occurrences |
| `kvE2_extNegPast_complete` | **the Phase-6 deliverable**: no realizer at any `x1 < x` ⇒ clause at `x`, under pins `(hxw, hwt, henv, habove)` + σ-side `(hbase, hbits)` |

## Key decisions (within the Phase-2 BINDING signature modulo side — H6 clean)

1. **`kvE2_futAnyBit` reused as-is** (per the Phase-5 handoff's side-neutrality
   observation): the zone-fact channel is qnf-side and side-neutral in its `ZoneSpec 3`
   argument; only the six-constant DISJUNCTION guard in `hbits` swaps to the above-`x`
   set `{zAtX3, zXW3, zAtW3, zWT3, zAtT3, zFutT3}` and `habove`'s key becomes
   `(zs ⟨1⟩).1 = false`. No new bit-reader definition was needed.
2. **No `futBelowSpec_*`-style named constants**: the six `(kvE2_sep_z* ⟨1⟩).1 = false`
   facts are consumed as inline `rfl` (the future file's named constants serve only its
   spike section, which has no past mirror obligation).
3. **Forward-trichotomy case order kept as `lt_trichotomy v x1`** (same as future):
   `v < x1` → ray, `v = x1` → self, `x1 < v` → `le_or_gt x v` splits above-six vs gap —
   roles time-reversed relative to future but the rcases skeleton identical.
4. **Admissibility not hypothesized** (mirrors Phase 4): a true positive form certifies
   `kvE2_pastAdmissible σ` (else-branch `⊥`), and admissibility contains the marking.

## Verification (phase gate)

- Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExteriorNegationPast`: GREEN
  (first compile, zero errors/warnings in the new block).
- Full `lake build`: GREEN (1721 jobs, matches Phase-4/5 baseline).
- `#print axioms` on `kvE2_extNegPast_complete`, `kvE2_extNegPast_sound`,
  `kvE2_extNegPast` = `{propext, Classical.choice, Quot.sound}` exactly.
- Repo sorry census 163 = Phase-5 baseline; zero sorries in task files.
- No vacuous definitions; no new `axiom` declarations.
- H7 territory clean: only `ExteriorNegationPast.lean` touched (extension in place);
  ExteriorNegation/SharedWitness/SubBracket2V/OuterGate byte-unchanged this dispatch.

## Notes for Phase 7 (adjacent exterior brackets + enriched gate)

- Both sides now have the full `_sound` + `_complete` pair with symmetric hypothesis
  inventories (future: `hbelow` key `(zs ⟨2⟩).2 = false`, guard {zPastX3..zAtT3};
  past: `habove` key `(zs ⟨1⟩).1 = false`, guard {zAtX3..zFutT3}); both consume the
  SAME `kvE2_futAnyBit qnf` bits.
- Dedupe candidates for Phase 7's explicit dedupe task (skip-if-nontrivial churn bar):
  `nf_profile_unique/exists`, `kvE2_pastCharZone4/3'`, `kvE2_pastSigma_atom`'s two
  side-neutral `.pred`/`.order (i+1)(j+1)` cases.
- Positive existence clause (bit-true σ, Lemma 7.10) is NOT in this file — Phase 7
  builds it in the new `NfMultiAnchorBridge/ExteriorBracket.lean`.
