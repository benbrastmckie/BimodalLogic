# Boneyard / Kamp / RabinovichPath

The **Rabinovich route**: following Rabinovich 2014's proof of expressive completeness rather
than Kamp's original separation argument.

## What the approach was

`RabinovichGeneralized.lean` generalizes the 2-variable existential characterization;
`RabinovichNegation.lean` supplies `nf_2var_exist_formula_prior_neg` as a drop-in replacement for
the positive-only version; `RabinovichWiring.lean` connects the translation to `NormalForm` and
`PriorDefs`; `RabinovichProp42.lean` documents what was, at the time, the sole remaining `sorry`
on the Kamp critical path and wires up the surrounding infrastructure.

## Why it died

Dead code: no live downstream consumers. Each file carries its own `-- ARCHIVED from ...
-- Reason: Dead code — Rabinovich approach path with no live downstream consumers -- Archived:
2026-06-16` header. The route depends on `RabinovichTranslation.lean` and `SeparationBridge.lean`,
both now in the sibling `KampWeakCanonical/TranslationEra/`, and on `NfCharFormula.lean` in
`KampBypassArchive/` -- so it is entangled with two other abandoned approaches and cannot be
revived alone.

## What revival would require

Reviving `KampBypassArchive/NfCharFormula.lean` and `KampWeakCanonical/TranslationEra/` first,
then re-checking Rabinovich 2014 Proposition 4.2 against the current `VecEA` definitions. The
`sorry` that `RabinovichProp42.lean` documents was subsequently closed on the live path by other
means; that file's framing is historical.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `RabinovichGeneralized.lean` | 524 | `FormalSystem/Boneyard/RabinovichPath/RabinovichGeneralized.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` |
| `RabinovichNegation.lean` | 281 | `FormalSystem/Boneyard/RabinovichPath/RabinovichNegation.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean` |
| `RabinovichProp42.lean` | 116 | `FormalSystem/Boneyard/RabinovichPath/RabinovichProp42.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/RabinovichProp42.lean` |
| `RabinovichWiring.lean` | 373 | `FormalSystem/Boneyard/RabinovichPath/RabinovichWiring.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/RabinovichWiring.lean` |

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
