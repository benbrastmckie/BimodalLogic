# Kamp — Separation and the Reynolds Discrete Route

The Kamp/Reynolds separation machinery: **99 live `.lean` files / 71,246 lines**, the
largest single subtree in the repository — larger than every other directory under
`Metalogic/` combined. Any description of this repository's shape that omits `Kamp/`
is wrong about the repository.

## This Directory's Archived Work Lives in the Archive

`Kamp/` used to carry its own nested `Boneyard/`, the **second** archive directory in the
repository. It no longer does: that archive was moved whole into
[`FormalSystem/Boneyard/Kamp/KampWeakCanonical/`](../../../Boneyard/Kamp/KampWeakCanonical/README.md),
and the four Kamp-facing approach directories that sat at the top-level archive's root joined it
under [`FormalSystem/Boneyard/Kamp/`](../../../Boneyard/Kamp/README.md). A `find` filter naming
only the top-level `Boneyard` used to count the nested archive's lines as live, which is how
several past counts of this repository came out wrong; B0 now asserts the archive directory count
is exactly 1, so that cannot recur silently.

Archive counts are stated in exactly one place,
[`FormalSystem/Boneyard/README.md`](../../../Boneyard/README.md). Re-derive live counts with:

```bash
bash scripts/check-module-invariants.sh   # B0 self-test + C7 live inventory
```

## Structure

| | Files | Lines |
|---|------:|------:|
| loose modules | 49 | 26,160 |
| [`NfMultiAnchorBridge/`](NfMultiAnchorBridge/README.md) | 43 | 41,859 |
| [`EANegationFix/`](EANegationFix/README.md) | 7 | 3,227 |

The 49 loose modules group by what they transcribe:

- **Existential/universal normal form** — `ExistsForallFormula`, `ExistsForallNF`,
  `ExistsForallLemmas`, `PerFormulaExistsForall`, `VeeExistsForall`, `ESigmaExpansion`,
  `ESigmaCapture`
- **Vector-EA encoding** — `VecEAFormula`, `VecEATranslation`, `VecEAClosure`,
  `VecEAConjFull`, `VecEADecomp`, `VVecEA2Collapse`, `NfToVecEA`
- **Negation handling** — `EANegation`, `EANegationClosure`, `EANegationFix`,
  `EFSatNegation`, `EFSatNegationGeneral`, `VeeSatNegation`, `ExteriorNegation`,
  `ExteriorNegationPast`
- **Prior structures and Dedekind carriers** — `KampPrior`, `PriorINF`, `DedekindINF`,
  `ZetaPriorTransfer`, `ZetaUniformExtract`
- **Paper transcriptions** — `Prop35*`, `Prop42*`, `Prop43Translate`, `Lemma53`,
  `Section5Correspondence` (Rabinovich 2014, Sections 3–5)
- **Normal-form zones** — `NfDepth0Generalized`, `NfZoneDepthK`, `NfZoneFlattenNavigable`,
  `NfEFold`, `NfMultiAnchorBridge`

## Position in the Layering

`Kamp/` sits inside `WeakCanonical/`, the Kamp/Reynolds completeness route. It is
reached from `WeakCanonical.lean` (the sibling aggregator) and is what makes
`WeakCanonical` the riskiest subtree in the tree to relocate: `WeakCanonical` carries
339 import lines across 137 live files, so a partial move leaving dangling imports is
a real hazard rather than a theoretical one.

## A Note on Reachability

Several modules here exist specifically to hold an import edge so that a transcription
or a refutation stays inside the build graph. Files parked in a `Boneyard/` fall under no CI
build, so their *content* still rots unseen -- C11 checks that an archived file's imports resolve,
which stops the archive drifting out of sync with the tree, but nothing typechecks the proofs
inside it. Import edges into apparently unused transcription modules are therefore
deliberate; see the extensive import notes at the top of `NfMultiAnchorBridge.lean`.

## Related Documentation

- [WeakCanonical README](../README.md)
- [Metalogic architecture map](../../README.md)
- [Kamp Boneyard inventory](../../../Boneyard/Kamp/KampWeakCanonical/README.md)

## References

- Kamp 1968 — separation and expressive completeness
- Reynolds 1994, Theorems 14–18 — the discrete completeness route
- Rabinovich 2014 — the separation transcription this subtree follows
