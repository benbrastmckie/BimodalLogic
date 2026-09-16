# Metalogic/Deterministic — the deterministic metatheory of TM⁺

The `⊡ = identity` corner of TM⁺: validity restricted to the frames satisfying
`TaskFrame.Deterministic` (`Semantics/FrameProperty.lean`), the completeness engines re-read
against that restriction, and the extended system **TM⁺ + *Determined*** with its soundness and
completeness.

The headline is `logicDeterministicEqDeterminedValid`: the logic of the deterministic frames and
the logic of the frames validating the *Determined* schema `φ → ⊡φ` **coincide**, and TM⁺ +
*Determined* axiomatizes both.

## Axiomatizing is not characterizing

*Determined* does **not** define the deterministic frames. The drift frame `F°`
(`Metalogic/Independence/DriftFrame.lean`) validates every instance without being deterministic,
and by `deterministic_not_plusDefinable` no L⁺ formula set defines the class at all. Every
statement in this subtree is phrased over `TaskFrame.Deterministic` or over `DeterminedValid`,
never as a correspondence between a schema and a frame condition.

## General TM⁺ completeness is open

Nothing here states general (nondeterministic) TM⁺ completeness, at any class, and nothing
discharges it with `sorry`. The nearest results in the literature are Reynolds (2003) on
until/since completeness over the reals and Zanardo (1991) on branching-time logics under an
Ockhamist reading; neither settles the all-histories semantics used here. Any future
nondeterministic result must specialize to the theorems below, because on a deterministic frame
`⊡` is pointwise the identity (`Semantics/PlusLanguage/PlusDeterminism.lean`,
`stab_iff_of_deterministic`).

## Why the deterministic case falls out at all

Every completeness engine ends by applying its validity hypothesis to a *concrete* countermodel
frame, and every one of those frames is a specialization of `Algebraic.multiFamTaskFrameGen`,
whose task relation is a deterministic clock. So the engines already refute only over
deterministic frames, and narrowing their hypothesis costs nothing (`Engines.lean`). The
remaining work is the two collapses: semantic (`Erasure.lean`) and syntactic
(`Collapse.lean`).

## Modules

| File | Role |
|------|------|
| `Validity.lean` | `DetSat`, `ValidDetIn`, `PlusValidDetIn`, `DeterminedValid`, `DeterminedSat`, `PlusValidDeterminedIn`; the inclusion `deterministic_determinedValid` and its **strictness** |
| `Frames.lean` | *(absent — the two determinism lemmas are hosted beside their frames, in `Algebraic/FlowFrame.lean` and `WeakCanonical/IntegerModel/ReynoldsBridge.lean`, because the countermodel producers that consume them sit below this subtree in the import order)* |
| `Engines.lean` | `derivable_of_validDet{Base,Dense,ZTime,RTime}` and the uniform `derivable_of_validDet` |
| `Erasure.lean` | `erasePlus` and the **semantic** collapse `plusTruthAt_erasePlus_of_deterministic` |
| `System.lean` | `DetAxiom`, `DetDerivationTree`, `DetDerivable`, and the embeddings of TM and TM⁺ |
| `Soundness.lean` | `detSoundness` over the *Determined*-valid frames, plus consistency |
| `Collapse.lean` | the derived-rule layer and the **syntactic** collapse `detDerivable_iff_erasePlus` |
| `Completeness.lean` | `detCompleteness*`, `logicDeterministicEqDeterminedValid`, the intermediate-class transfers, and `detDerivable_ofFormula_iff` (conservativity over TM) |

## Key Results

- `detCompletenessBase`, `detCompletenessDense`, `detCompletenessZTime`, `detCompletenessRTime`
- `detSoundness` — soundness over the *Determined*-valid frames, the strictly larger class
- `logicDeterministicEqDeterminedValid` — the coincidence corollary
- `detCompletenessBetween` / `logicBetweenEqDeterministic` — the transfer to every class between
  the two
- `detDerivable_ofFormula_iff` — TM⁺ + *Determined* is conservative over TM, at every class
- `determinedValid_not_deterministic` — the inclusion is strict, so the coincidence is a
  statement about logics and not about frames

## Related Documentation

- [Metalogic README](../README.md)
- [`Metalogic/Conservativity/Plus/README.md`](../Conservativity/Plus/README.md) — TM⁺ soundness
  and conservativity, and the metatheory-row table
- [`Metalogic/Independence/README.md`](../Independence/README.md) — the non-definability results
  that bound what this subtree may claim
- [`docs/theorem-index.md`](../../../docs/theorem-index.md) — per-theorem status

---

*Last verified: 2026-09-08*
