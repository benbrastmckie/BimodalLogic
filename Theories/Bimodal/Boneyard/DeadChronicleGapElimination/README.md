# Dead Chronicle Gap Elimination (Archived)

**Archived**: Task 301 (completeness cleanup)
**Original location**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (lines 55-867)

Dead code from the BX chronicle gap elimination pipeline. These declarations
are NOT on any live call path to `completeness_discrete`, which uses the
Reynolds pipeline (`countermodel_discrete_reynolds_v2`) instead.

## Archived Declarations

- `succ_reaches_dom_N` — dead BX pipeline stage induction (sorry)
- `z1_formula`, `z1_derivation`, `z1_in_mcs` — Z1 axiom helpers for gap proof
- `limit_f_some_future_of_lt`, `limit_f_not_G_neg_of_mem` — limit function helpers
- `chronicle_gap_contradiction` — core gap elimination (sorry)
- `succ_cofinal` — cofinality from gap elimination (depends on sorry)
- `limitDomSubtype_isSuccArchimedean` — IsSuccArchimedean from cofinality (depends on sorry)

## Sorry Chain

```
chronicle_gap_contradiction (sorry)
  -> succ_cofinal
  -> limitDomSubtype_isSuccArchimedean
  -> succ_embed_surjective (still in live code, now uses axiom instead)
```

## Why Dead

`completeness_discrete` was refactored to use the Reynolds pipeline
(`countermodel_discrete_reynolds_v2` in ReynoldsBridge.lean), which bypasses
the entire chronicle gap elimination path. The sole remaining sorry blocker
is `existPart_succ_n1_bypass` k>0 in KampBypass.lean (task 303).

## Note

The archived file does NOT compile standalone — it was extracted from the
middle of a namespace block. Preserved for historical reference only.
