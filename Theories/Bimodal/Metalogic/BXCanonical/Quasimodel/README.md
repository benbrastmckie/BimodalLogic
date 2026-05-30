# Quasimodel — Intermediate Canonical Structure

Quasimodel construction as an intermediate step in BXCanonical completeness.

A quasimodel is a partial canonical structure that satisfies the local consistency
conditions of TM frames without necessarily satisfying all global coherence requirements.
Quasimodels are used as an intermediate step before the full chronicle construction.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Construction.lean` | 841 | Quasimodel construction from a consistent MCS set |
| `EnrichedClosure.lean` | 158 | Enriched subformula closure used in quasimodel construction |
| `HintikkaPoint.lean` | 144 | Hintikka-style point consistency conditions for quasimodel nodes |
| `LocusControl.lean` | 49 | Locus control properties: temporal focus management in quasimodels |
| `Realization.lean` | 493 | Realization lemma: quasimodels give rise to full canonical models |
| `SubformulaClosure.lean` | 112 | Subformula closure utilities specific to the quasimodel construction |

## Key Results

- `quasimodel_construction`: Builds a quasimodel from a consistent formula set
- `realization_lemma`: Every quasimodel can be extended to a full TM model
- `hintikka_consistency`: Quasimodel nodes satisfy Hintikka-style local conditions

## Dependencies

- **Imports from**: `Bimodal.Metalogic.Core`, `Bimodal.Syntax.SubformulaClosure`
- **Imported by**: `Bimodal.Metalogic.BXCanonical.Chronicle`

## Related Documentation

- [BXCanonical README](../README.md)
- [Chronicle README](../Chronicle/README.md)

---

*Last verified: 2026-05-29*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
