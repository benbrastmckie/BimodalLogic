# BXCanonicalQuasimodel

Archived from `FormalSystem/Metalogic/BXCanonical/Quasimodel/`.
Archived 2026-06-16 in commit `e94c38ca7`.

## Contents

<!-- BEGIN GENERATED: inventory dir=Boneyard/BXCanonicalQuasimodel rows=loose -->
| File | Lines | Description |
|------|------:|-------------|
| `EnrichedClosure.lean` | 166 | Fisher-Ladner style enriched Sigma-closure: `enrichedClosure`, `enriched_target_mem`, `enriched_subformula_mem`, `enriched_g_neg_bigconj_mem`, `enriched_h_neg_bigconj_mem`, `enriched_neg_pairing` |
<!-- END GENERATED -->

## Why archived

**Superseded approach.** The enriched closure adds, for every subset `T` of the base
`SubformulaClosure`, the formulas `G(¬ (bigconj T.toList))` and `H(¬ (bigconj T.toList))`. It was
written as Phase 1 scaffolding for a migration whose Phase 2 never ran: the chain-step seed
consistency gap it was built to close is handled by the landed pipeline instead. Every
declaration here had zero live downstream consumers at archival.

## Relationship to active code

`SubformulaClosure` and `BigConj` are both still live, at
`FormalSystem/Metalogic/BXCanonical/Quasimodel/SubformulaClosure.lean` and
`FormalSystem/Syntax/BigConj.lean`. The file was written to build as a standalone definition
*alongside* `SubformulaClosure` rather than replacing it, so resurrecting it needs no surgery on
live code — remove the `#exit` and rename the identifiers per the archive root README's naming
caveat.

## Convention note

This file predates the guard-first migration. It contains no `untl`/`snce` occurrences, so the
root README's argument-swap warning has nothing to act on here.
