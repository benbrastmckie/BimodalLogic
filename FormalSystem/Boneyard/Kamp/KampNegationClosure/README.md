# Boneyard / Kamp / KampNegationClosure

The **negation-closure chain**: proving that the negation of a VecEA2 formula is again
expressible, so the vectorized-EA fragment is closed under negation.

## What the approach was

`NegationClosure.lean` is the bulk of it (1,845 lines): closure of the VecEA2 fragment under
negation over Prior structures. `NegationClosure5.lean` carries the arity-5 case,
`NegationClosureProp42.lean` states the result as Rabinovich 2014 Proposition 4.2, and
`FoToVecEA.lean` bridges `NormalForm` evaluation into the vec-EA framework.

## Why it died

Dead code: the chain had no live downstream consumers. Every file here still carries its own
`-- ARCHIVED from ... -- Reason: Dead code — negation closure chain with no live downstream
consumers -- Archived: 2026-06-16` header, which is the authoritative record. The live tree
reaches negation closure through `Metalogic/WeakCanonical/Kamp/EANegationClosure.lean` and
`VecEAClosure.lean` instead.

## What revival would require

A consumer. The mathematics is not the obstacle -- the obstacle is that nothing needs it. Before
reviving, check whether the live `EANegationClosure` / `VecEAClosure` pair already covers the
case at hand; it was written to.

## Files

| File | Lines | Path before consolidation | Live origin before archival |
|------|------:|---------------------------|--------------|
| `FoToVecEA.lean` | 231 | `FormalSystem/Boneyard/KampNegationClosure/FoToVecEA.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` |
| `NegationClosure.lean` | 1,845 | `FormalSystem/Boneyard/KampNegationClosure/NegationClosure.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` |
| `NegationClosure5.lean` | 1,035 | `FormalSystem/Boneyard/KampNegationClosure/NegationClosure5.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` |
| `NegationClosureProp42.lean` | 173 | `FormalSystem/Boneyard/KampNegationClosure/NegationClosureProp42.lean` | `FormalSystem/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` |

Nothing in this directory is compiled. It is outside the `lakefile.lean` import closure
and no live module imports it. Its imports are still checked -- C11 in
`scripts/check-module-invariants.sh` requires every one to resolve to a file on disk or be
waived in `scripts/boneyard-import-waivers.txt`.

Last verified: 2026-08-24
