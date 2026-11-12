# Chronicle — Dense Chronicle Construction

Dense chronicle construction for the BXCanonical completeness proof.

A chronicle is a dense sequence of maximally consistent sets indexed by rational-like
time points, constructed to witness completeness of Dense TM logic. This directory
implements the construction of such chronicles from a consistent seed MCS, following
the Burgess (1982) approach.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/BXCanonical/Chronicle rows=loose cols=lines -->
| File | Lines | Description |
|------|-------|-------------|
| `ChronicleConstruction.lean` | 1,611 | Main chronicle construction algorithm: building the dense MCS sequence |
| `ChronicleGuardAccumulation.lean` | 816 | The guard-accumulation invariant: original work bounding where fresh-point witness placements can converge, with no source in the corpus |
| `ChronicleLimitGapWitness.lean` | 221 | Discharges `BFMCS.LimitFutureWitness`: at an unselected real, a witness for an eventual future formula already exists strictly above it |
| `ChronicleLimitGuardAbove.lean` | 225 | Discharges the Until/Since left-gap guard: continues a guard abutting an unselected real from below to an interval abutting it from above |
| `ChronicleLimitGuardWitness.lean` | 219 | Discharges `BFMCS.LimitGuardBelow`: continues a guard abutting an unselected real from above down through it to an interval below |
| `ChronicleMonadicBridge.lean` | 1,029 | Turns the landed rational chronicle into a finite-monadic-language temporal structure over a dense rational flow, per Reynolds 1992 Section 9 |
| `ChronicleRealExtension.lean` | 1,179 | Transports restricted Until/Since coherence from the rational bundle to the real bundle via `guard_transport_realLimitMCS` |
| `ChronicleToCountermodel.lean` | 1,271 | Extracting a countermodel from an open chronicle (refutation extraction) |
| `ChronicleToCountermodelBasic.lean` | 1,206 | Converts the chronicle construction into a countermodel for the BX completeness theorem via a density/discreteness case split |
| `ChronicleTypes.lean` | 888 | Type definitions for chronicles, chronicle elements, and indexed families |
| `CounterexampleElimination.lean` | 3,887 | Counterexample elimination: showing chronicles avoid false formulas |
| `MCSMixedCase.lean` | 77 | Shows the MCS mixed case is impossible via `discrete_box_necessity`, used by `derivable_of_validZTime` in `Completeness.lean` |
| `PointInsertion.lean` | 3,577 | Point insertion lemma: inserting intermediate chronicle points for density |
| `RRelation.lean` | 1,708 | Task relation construction for chronicles: R(τ,t,σ) derived from MCS membership |
<!-- END GENERATED -->

## Key Results

- `chronicle_construction`: Main construction producing a dense MCS sequence from a seed
- `point_insertion`: Between any two chronicle points, an intermediate point can be inserted
- `counterexample_elimination`: Chronicles do not falsify consistent formulas
- `chronicle_to_countermodel`: Open chronicles yield countermodels

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Core`, `FormalSystem.Metalogic.BXCanonical.Quasimodel`
- **Imported by**: `FormalSystem.Metalogic.BXCanonical.CanonicalModel`

## Related Documentation

- [BXCanonical README](../README.md)
- [Quasimodel README](../Quasimodel/README.md)

---

*Last verified: 2026-09-21*
