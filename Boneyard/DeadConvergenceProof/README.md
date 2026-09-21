# DeadConvergenceProof

Archived 2026-05-29 in commit `bcb2b36f9`, from inline blocks in
`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`. Relocated from the
former root-level `Boneyard/` into this tree on 2026-06-16.

## Contents

<!-- BEGIN GENERATED: inventory dir=Boneyard/DeadConvergenceProof rows=loose -->
| File | Lines | Description |
|------|------:|-------------|
| `limit_dom_succ_iterates.lean` | 90 | `limit_dom_points_are_succ_iterates` — every `limit_dom` point in `[a, z]` is a succ-iterate of `a`; infinite-descent argument, stuck on the same convergence gap as `succ_cofinal` |
| `succ_cofinal_convergence.lean` | 378 | The convergence proof attempt for `succ_cofinal`, formerly inlined in the theorem body |
<!-- END GENERATED -->

## Why archived

**Structural dead end.** The approach proves `succ_cofinal` by showing the successor orbit
`{s^[n](a)}` converges to a limit `L` in `ℝ` and deriving a contradiction from Z1, Prior-UZ and
`c5_strong`. It fails in the *constant MCS* case: when every `limit_dom` point carries an
identical MCS label, no discriminating formula exists and the temporal axioms are trivially
satisfied. Three gap-elimination routes were evaluated (Prior-SZ maximum principle with a
discriminating formula; a syntactic Z1 derivation tree from Prior-UZ; stage induction on the
omega-chain construction) and none closed it.

`limit_dom_succ_iterates.lean` is a helper with exactly one consumer — the dead convergence proof
in the same directory — so the two were retired as a unit.

## Relationship to active code

The live `succ_cofinal` is derived from `one_class` instead, which sidesteps the convergence
argument entirely. `StageInductionGapAnalysis/` records the independent finding that the gap
scenario this proof stumbled on is *genuine* rather than an artifact of the proof strategy.

## Convention note

Both files predate the guard-first migration; check for `untl`/`snce` occurrences and swap the
arguments before resurrecting anything, per the archive root README.
