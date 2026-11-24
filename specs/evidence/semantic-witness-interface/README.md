# Semantic witness interface comparison

This [Lean probe](witness-interface-probe.lean) proves the same four countermodel claims with ordinary lemmas, a clause-ordered witness pattern and labelled witness entries. It prints proof-source token counts and elaborated term sizes and checks how the two interfaces report malformed evidence.

Run it from the repository root with the pinned toolchain and the library built.

```sh
lake env lean -DwarningAsError=true specs/evidence/semantic-witness-interface/witness-interface-probe.lean
```

The [design record](../../../records/semantic-proof-mode.md) gives the results and explains the choice of interface for the next prototype.
