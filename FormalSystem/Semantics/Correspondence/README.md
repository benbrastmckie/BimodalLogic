# Correspondence — the frame-class Galois layer

The `Th`/`Mod` adjunction between sets of task frames and sets of formulas, the indicator
mechanism that decides when a frame class is Galois-closed, the duration-level correspondence
theorems `app:discrete`/`app:dense`/`app:complete` in the reading the paper's proofs actually
establish, and the forward-recurrence correspondent of the density schema.

The organising fact is that "is this frame class axiomatizable?" and "is this frame class
Galois-closed?" are the same question (`galoisClosed_mod`), and that a class is shown closed by
exhibiting a *single* formula valid on precisely its members (`galoisClosed_of_indicator`). Every
closure result in the tree is one application of that lemma; there is no per-class copy of the
argument.

Two distinctions are load-bearing throughout and are documented at their statement sites:

- **`TaskFrame.IsDiscrete` versus `FrameClass.Sat FrameClass.Discrete`.** The first is
  `def:frame-properties`' bare Discrete clause and *is* Galois-closed; the second is
  `def:TMplus-f`'s Hölder narrowing to ℤ-time and is *not*, as
  `Metalogic/Independence/LexIntWitness.lean` witnesses.
- **(T0) versus (T1).** The per-frame reading of the three correspondence theorems is false in
  its (⇒) direction; only the temporal-order-level reading is true. See `DurationFrames.lean`'s
  header and `specs/paper-definitions-of-record.md`'s reading note.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Galois.lean` | 183 | `Th`/`Mod`, antitonicity, both inflationary round trips, both triple-composite collapses, `GaloisClosed`, `galoisClosed_mod`, `galoisClosed_of_indicator`, and the reified formula sets `AxiomSet` and `densitySchema`. Records the layer's non-goals: closed-form characterizations of `Mod (AxiomSet .Discrete)` and `Mod (AxiomSet .Dedekind)` are open and not promised. |
| `Indicator.lean` | 161 | Indicator exactness: `F ⊨ ¬X⊤ ↔ DenselyOrdered F.Duration`, its `X⊤`/discrete dual, and the guarded form against `TaskFrame.IsDiscrete`; plus the two closure corollaries as one-line applications of `galoisClosed_of_indicator`. |
| `DurationFrames.lean` | 563 | The translation frame (`W = D`, `w ⇒_x u ↔ u = w + x`) and the two-state permissive frame (`W = Bool`, `w ⇒_d u ↔ d ≠ 0 ∨ w = u`) with their histories and models, the `NoMaxOrder`/`SuccOrder` glue a non-dense carrier supplies, and the three (T1) biconditionals for DF/DN/CO with the (T0) refutation recorded beside them. |
| `FwdRec.lean` | 131 | `TaskFrame.FwdRec` — forward recurrence at covering pairs, over bundled frames — the `validOn_iff_total` bridge, and the *atomic* density correspondence at an arbitrary duration group. |
| `FwdRecPeriodicity.lean` | 445 | The `Walk`/`MinCyc` apparatus: `AllRec` forces every bi-infinite walk in a digraph to be periodic, by way of determinism along walks. Plus truth periodicity from a *per-history* period, and the fact that periodic histories validate the whole density schema. |
| `FwdRecBridge.lean` | 186 | The frame/digraph dictionary at `ℤ` — walks are total histories and conversely — under which `FwdRec` is exactly `AllRec`. Gives full-schema exactness at `ℤ` and `Mod densitySchema` on the `ℤ` fibre. |

## Key Results

- `galoisClosed_of_indicator` (`Galois.lean`) — the indicator mechanism, factored exactly once.
- `galoisClosed_sat_dense` and `galoisClosed_isDiscrete` (`Indicator.lean`) — the two classes
  that *are* closed.
- `validOn_dn_iff_denselyOrdered`, `validOn_df_iff_isDiscrete`, `validOn_co_iff_isComplete`
  (`DurationFrames.lean`) — `app:dense`, `app:discrete` and `app:complete` at (T1).
- `validOn_atomic_density_iff_fwdRec` (`FwdRec.lean`) and
  `Bridge.density_schema_iff_fwdRec` (`FwdRecBridge.lean`) — the atomic correspondence at
  arbitrary `D` and the schema correspondence at `ℤ`, stated separately because they have
  different strengths.

## Dependencies

- **Imports from**: `FormalSystem.Semantics.Validity` (and through it `FrameClassValidity`, the
  single documented `Semantics → ProofSystem` edge), `FormalSystem.Semantics.DurationClassification`
- **Imported by**: `FormalSystem.Semantics` (the aggregator), and
  `FormalSystem.Metalogic.Independence.{RationalWitness, LexIntWitness}`, which supply the two
  frames showing `Sat .Dedekind` and `Sat .Discrete` are *not* closed

## Related Documentation

- [Semantics README](../README.md)
- [Independence README](../../Metalogic/Independence/README.md) — the two non-closure witnesses
  and both sandwich theorems

---

**Last verified**: 2026-09-01
