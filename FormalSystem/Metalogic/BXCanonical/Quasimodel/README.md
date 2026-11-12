# Quasimodel — Intermediate Canonical Structure

Quasimodel construction as an intermediate step in BXCanonical completeness.

A quasimodel is a partial canonical structure that satisfies the local consistency
conditions of TM frames without necessarily satisfying all global coherence requirements.
Quasimodels are used as an intermediate step before the full chronicle construction.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/BXCanonical/Quasimodel rows=loose cols=lines -->
| File | Lines | Description |
|------|-------|-------------|
| `Construction.lean` | 846 | Quasimodel construction from a consistent MCS set |
| `HintikkaPoint.lean` | 152 | Hintikka-style point consistency conditions for quasimodel nodes |
| `LocusControl.lean` | 56 | Locus control properties: temporal focus management in quasimodels |
| `Realization.lean` | 509 | Realization lemma: quasimodels give rise to full canonical models |
| `SubformulaClosure.lean` | 118 | Subformula closure utilities specific to the quasimodel construction |
<!-- END GENERATED -->

## Key Results

- `quasimodel_construction`: Builds a quasimodel from a consistent formula set
- `realization_lemma`: Every quasimodel can be extended to a full TM model
- `hintikka_consistency`: Quasimodel nodes satisfy Hintikka-style local conditions

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.Core`, `FormalSystem.Syntax.SubformulaClosure`
- **Imported by**: `FormalSystem.Metalogic.BXCanonical.Chronicle`

## Related Documentation

- [BXCanonical README](../README.md)
- [Chronicle README](../Chronicle/README.md)

---

*Last verified: 2026-09-21*
