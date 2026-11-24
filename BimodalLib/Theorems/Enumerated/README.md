# Enumerated theorems

Machine-generated registry entries: the theorems the tableau pipeline enumerated, decided,
extracted a derivation for, generalized from concrete atoms to schema variables, and admitted.

Nothing here is hand-written. Every file is emitted by

```bash
bash scripts/theorem-library-pipeline.sh \
  --all-fragments --atoms 2 \
  --frame-class Base --frame-class Dense --frame-class ZTime --frame-class RTime
```

and is replaced wholesale on the next run. An edit made here is lost; change the emitter
(`BimodalTools/LeanSourceEmit.lean`) or the driver (`BimodalTools/TheoremPipeline.lean`) instead.

| Path | Description |
|------|-------------|
| `Base.lean` | Every admitted entry, at `Base`. One file, because proof extraction is `Base`-only: `extractProof` ignores its frame-class argument and `ProofExtractionResult.success` is hard-coded to `Base`, so the frame-class axis moves the countermodel half alone |

## What admission requires

A formula is admitted only when it is **valid and carries an extracted `DerivationTree`**. A
valid formula whose tableau closed without yielding a witness (`extractionFailed`) is not
admissible, and neither is a `fuelExhausted` verdict or an ungated `invalid` one; all three are
registered as conjectures in `BimodalLib/Conjectures/Enumerated.lean` with their verdicts.

A candidate that is a substitution instance of an entry already admitted is dropped rather than
registered. That is a build invariant, not merely a pipeline convention:
`assert_no_subsumed_entries BimodalLib.Theorems.Enumerated` in `BimodalLib/Theorems/Complete.lean`
fails the build if one generated entry's statement is a substitution instance of another row's.
The prefix scopes the candidate side only — the comparison side ranges over the whole registry —
so a generated entry duplicating a hand-curated law is caught too.

## How an entry is built

Each entry is three declarations. A `private def` holding the derivation the tableau extracted,
over the formula's own concrete atoms. A second `private def` holding the substitution that sends
those atoms to the entry's schema variables. Then the entry itself, obtained from the two by
`FormalSystem.ProofSystem.DerivationTree.substNil` and closed by
`simp only [substF, …, reduceIte] at h` — `simp only` with a closed lemma list rather than
`simpa`, because `simpa`'s full set closes an arity-2 entry through `Classical.choice`, which a
registry row must not depend on.

*Last verified: 2026-11-24*
