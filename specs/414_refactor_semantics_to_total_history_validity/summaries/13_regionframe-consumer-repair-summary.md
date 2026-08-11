# Phase 13 Summary — `regionFrame` consumer repair

- **Plan**: `specs/414_refactor_semantics_to_total_history_validity/plans/03_omega-free-totality-refactor.md`
- **Phase**: 13 (`regionFrame` consumer repair) — `[COMPLETED]`
- **Verification tier**: full

## What the phase had to do

Phase 12 re-hosted `regionFrame` onto the deterministic clock `(w, x) ⇒_d (w, x + d)` over
`WorldState := W × D`, which made `regionConstant_regionHistory_zero` **false** rather than merely
unproved: determinism propagates a state along the clock, so a region-constant history would repeat
a state at two distinct times. The tree entered this phase red at exactly one site,
`Bridge/TruthLemma.lean:319`, where that deleted lemma was still being applied.

## What was changed

Two files carry all the code change.

**`Bridge/TruthLemma.lean`.** The atom case's hypothesis is no longer `RegionConstant f τ` but a new
structure `AtomRegionInvariant f M τ`, a joint condition on model and history:

- `domain_congr` — region-mates are both in `τ`'s domain or both out of it (unchanged in force);
- `valuation_congr` — region-mates carry the same *atomic truth values*, rather than the same state.

`RegionConstant.atomRegionInvariant` proves the old hypothesis still implies the new one, so nothing
established under the stronger form is lost. The countermodel-side condition is `RegionValued f M`:
`M.valuation (w, r) p ↔ M.valuation (w, r') p` whenever `SameRegion f r r'` — i.e. the model reads
the time component of a state only through its region code. `atomRegionInvariant_regionHistory`
turns it into `AtomRegionInvariant` at the base history (whose domain is total and whose state at
`r` is `(w, r)`), and `interpInvariantAt` / `interpInvariantAt_regionHistory` consume it. The two
dense-carrier sanity `example`s took the same hypothesis.

**`Bridge/Valuation.lean`.** `regionModel`'s valuation is transported exactly as the inherited
repair shape prescribed:

```
valuation := fun s p => regionValuation f (placedVal s.1) (gapVal s.1) (regionCode f s.2) p
```

which is the general transport `V p (w, x) := V₀ p (w, regionCode f x)` of a valuation written
against the former code-carrying states. `regionValued_regionModel` discharges `RegionValued` for it
in two lines, from `sameRegion_iff_regionCode_eq`.

**Statement stability.** Everything downstream of `regionModel` kept its statement verbatim —
`truthAt_atom_regionHistory`, `truthAt_atom_placed`, `truthAt_atom_gap`,
`truthAt_atom_branch_placed`, `GapDemands`, `not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate`.
Only `regionModel` and its `@[simp]` readback `regionModel_valuation` moved.

**Prose.** Stale descriptions of the frame's state space were corrected in `Valuation.lean`'s header
and `TruthLemma.lean`'s O1 note, and `IntTruth.lean`'s "Correction 10" and certificate-gap
paragraphs were updated to record that `regionOmega f` is now *exactly* the frame's total-history
set (`regionOmega_eq_total`), so its range description and its totality description coincide.

## Scope Hypothesis: confirmed

The plan predicted that `IntTruth.lean`, `DenseTruth.lean`, `RegionLabel.lean` and `Decidable.lean`
would pass `regionOmega` opaquely through the five stable interface lemmas and need no edit. They
needed none — all four built green unedited once the two files above were repaired. Decision C's
spawn contingency is not triggered.

## Verification

| Check | Result |
|-------|--------|
| `lake build` (FormalSystem, 2331 jobs) | green |
| Sorries in `Verified/` | 0 (the 5 grep hits are the word "sorry" in prose) |
| Vacuous definitions introduced | 0 |
| `axiom` declarations | 6 (unchanged from the Phase 12 baseline) |
| `#print axioms` on the three new declarations | `propext`, `Classical.choice`, `Quot.sound` only — no `sorryAx` |

`lake build BimodalTest` reports ten `#guard_msgs` mismatches (`TableauConformance.lean` 7,
`RegionGateProbe.lean` 2, `BoxSpreadProbe.lean` 1). These are **pre-existing and out of scope**:
they are tableau-engine `#eval` expectations, `TableauConformance.lean` and `BoxSpreadProbe.lean`
do not import either edited file even transitively, and the probe expectations were last baselined
2026-07-29 while `Decidability/Saturation.lean` last changed 2026-08-05 under separate work.
Re-baselining them here would exceed the declared file scope and mask an engine-behaviour change
owned elsewhere.

## Files modified

- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Valuation.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean` (prose only)
- `specs/414_refactor_semantics_to_total_history_validity/plans/03_omega-free-totality-refactor.md`
