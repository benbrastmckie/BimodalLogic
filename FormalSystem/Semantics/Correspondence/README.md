# Correspondence — the frame-class Galois layer

The `Th`/`Mod` adjunction between sets of task frames and sets of formulas, the indicator
mechanism that decides when a frame class is Galois-closed, the duration-level correspondence
theorems `app:discrete`/`app:dense`/`app:complete` in the reading the paper's proofs actually
establish, and the forward-recurrence correspondent of the density schema.

The organising fact is that "is this frame class axiomatizable?" and "is this frame class
Galois-closed?" are the same question (`galoisClosed_mod`), and that a class is shown closed by
exhibiting a *single* formula valid on precisely its members (`galoisClosed_of_indicator`, whose
iff-shaped entry point `galoisClosed_of_indicator_iff` is what call sites use). Every closure
result in the tree is one application of that lemma; there is no per-class copy of the argument.

Since the re-basing on `Mathlib.Order.Concept`, that adjunction is not hand-rolled: `Th`, `Mod`
and `GaloisClosed` are the `upperPolar`, `lowerPolar` and `Order.IsExtent` of the validity
relation, and the connection theorems are projections of Mathlib's.

Two distinctions are load-bearing throughout and are documented at their statement sites:

- **`TaskFrame.IsDiscrete` versus `FrameClass.Sat FrameClass.Discrete`.** The first is
  `def:frame-properties`' bare Discrete clause and *is* Galois-closed; the second is
  `def:BX-z`'s narrowing to ℤ-time (`prop:archimedean`) and is *not*, as
  `Metalogic/Independence/LexIntWitness.lean` witnesses.
- **(T0) versus (T1).** The per-frame reading of the three correspondence theorems is false in
  its (⇒) direction; only the temporal-order-level reading is true. See `DurationFrames.lean`'s
  header and `docs/reference/paper-definitions-of-record.md`'s reading note.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Galois.lean` | 290 | `Th`/`Mod`/`GaloisClosed` as the polars of `validOnRel` over `Mathlib.Order.Concept` (`upperPolar`/`lowerPolar`/`Order.IsExtent`), so antitonicity, both inflationary round trips and both triple-composite collapses are one-line projections. Adds `mod_th_gc` (the adjunction as an explicit Mathlib `GaloisConnection`), `galoisClosed_iff` (the bridge back to the fixed-point equation), `galoisClosed_of_indicator_iff` (the iff-shaped entry point call sites use), and the free `galoisClosed_iInter`/`_inter`/`_univ` and `mod_union`/`mod_iUnion`/`mod_empty`/`th_empty`. Carries the reified formula sets `AxiomSet` and `densitySchema`, and records the layer's non-goals: closed-form characterizations of `Mod (AxiomSet .Discrete)` and `Mod (AxiomSet .Dedekind)` are open and not promised. |
| `Indicator.lean` | 176 | Indicator exactness: `F ⊨ ¬X⊤ ↔ DenselyOrdered F.Duration`, its `X⊤`/discrete dual, and the guarded form against `TaskFrame.IsDiscrete`; plus `galoisClosed_sat_dense` and `galoisClosed_isDiscrete` as single-line applications of `galoisClosed_of_indicator_iff`. The header tabulates the full four-part closed/not-closed picture, naming the two non-closure witnesses in `Metalogic/Independence/`. |
| `DurationFrames.lean` | 459 | The reference histories and models of the translation and permissive frames (the frames themselves now live in `Semantics/Frames/Standard.lean`), the atom-realisation layer `translationHist`/`permissiveHist` and `translation_realizes`/`permissive_realizes` with the `H`/`G` forms, the `NoMaxOrder`/`SuccOrder` glue a non-dense carrier supplies, and the three (T1) biconditionals for DF/DN/CO — whose (⇒) branches all run the same five-step realisation argument — with the (T0) refutation recorded beside them. |
| `FwdRec.lean` | 119 | `TaskFrame.FwdRec` — forward recurrence at covering pairs, over bundled frames — the `validOn_iff_total` bridge, and the *atomic* density correspondence at an arbitrary duration group. |
| `FwdRecPeriodicity.lean` | 485 | The `Walk`/`MinCyc` apparatus: `AllRec` forces every bi-infinite walk in a digraph to be periodic, by way of determinism along walks. Plus truth periodicity from a *per-history* period, and the fact that periodic histories validate the whole density schema. |
| `FwdRecBridge.lean` | 155 | The frame/digraph dictionary at `ℤ` — walks are total histories and conversely — under which `FwdRec` is exactly `AllRec`. Gives full-schema exactness at `ℤ` and `Mod densitySchema` on the `ℤ` fibre. |
| `Rigidity.lean` | 285 | `TaskFrame.Static` and `TaskFrame.UniformDwell`, the Archimedean chop `eq_of_rel_of_step` stated at the hypothesis it uses, and the rigidity theorem: over a dense Archimedean duration group a frame is static iff it has a uniform dwell time, so every finite-carrier frame over such an order is static. |
| `RigiditySharpness.lean` | 216 | Every rigidity hypothesis is sharp: the permissive frame over any successor order (so over `ℤ`, Archimedean but not dense) is not static; a two-state frame over `ℚ ×ₗ ℚ` (dense but provably not Archimedean, `lexRat_not_archimedean`) is not static; and the rational clock (`ratClock_not_static`) is countable, dense and Archimedean but not static, so finiteness cannot be weakened to countability over a merely dense Archimedean order. |
| `RigidityReal.lean` | 351 | The `ℝ` boundary: `FrameOver.static_of_countable` — over `ℝ`, every task frame with **countably** many world states is static, with no finiteness, density or Archimedean hypothesis. Carries the sharp `constant_of_countable_range`, the *Limit*-only `levels_closed`, the two-point application `exists_history_of_taskRel` of `thm:extension`, the local-clock results `range_uncountable_of_nonconstant` / `uncountable_image_of_not_localConst` / `exists_local_clock`, and the cardinality-sharpness witnesses `realClock_not_static` and the `paddedClock` family. |

## Key Results

- `galoisClosed_of_indicator` and `galoisClosed_of_indicator_iff` (`Galois.lean`) — the indicator
  mechanism, factored exactly once, and the iff-shaped entry point both closure corollaries apply.
- `galoisClosed_sat_dense` and `galoisClosed_isDiscrete` (`Indicator.lean`) — the two classes
  that *are* closed.
- `validOn_dn_iff_denselyOrdered`, `validOn_df_iff_isDiscrete`, `validOn_co_iff_isComplete`
  (`DurationFrames.lean`) — `app:dense`, `app:discrete` and `app:complete` at (T1).
- `validOn_atomic_density_iff_fwdRec` (`FwdRec.lean`) and
  `Bridge.density_schema_iff_fwdRec` (`FwdRecBridge.lean`) — the atomic correspondence at
  arbitrary `D` and the schema correspondence at `ℤ`, stated separately because they have
  different strengths.
- `FrameOver.static_iff_uniformDwell` and `FrameOver.static_of_finite` (`Rigidity.lean`) — over
  a dense Archimedean duration group, static is the same as having a uniform dwell time, and a
  finite carrier always has one; the collapse direction uses only interpolation and the dwell
  bound, the biconditional additionally uses *Seriality* and the reflection law.
- `Rigidity.permissiveFrame_not_static`, `Rigidity.lexRatFrame_not_static`,
  `Rigidity.lexRat_not_archimedean` and `Rigidity.ratClock_not_static`
  (`RigiditySharpness.lean`) — the hypotheses of the rigidity theorem are each necessary:
  density, the Archimedean property, and (over a merely dense Archimedean order) finiteness
  rather than countability.
- `FrameOver.static_of_countable` (`RigidityReal.lean`) — over `ℝ`, a **countable** carrier
  already forces a static frame. *Saturation* supplies a total history through `thm:extension`
  (the sole source of `Classical.choice` here), *Limit* makes its level sets closed, Sierpiński's
  theorem (`ForMathlib/Topology/Sierpinski.lean`) collapses it, and *Seriality* plus the
  reflection law give the positive half of `Static`; density and the Archimedean property are not
  used at all, Dedekind completeness replacing them. Sharp in cardinality
  (`Rigidity.realClock_not_static`, `Rigidity.paddedClock_not_static`) and in the duration order
  (`Rigidity.ratClock_not_static`).
- **See also**, for the *non*-closure complement of the two corollaries above:
  `sat_dedekind_ssubset_mod_axiomSet` (`Metalogic/Independence/RationalWitness.lean`) and
  `sat_discrete_ssubset_mod_axiomSet` (`Metalogic/Independence/LexIntWitness.lean`). Together with
  `galoisClosed_sat_dense` and `galoisClosed_isDiscrete` these are the four rows of the
  closed/not-closed table in `Indicator.lean`'s header: the paper's bare Dense and Discrete
  clauses are Galois-closed, and the two `FrameClass.Sat` narrowings are not.

## Dependencies

- **Imports from**: `FormalSystem.Semantics.Validity` (and through it `FrameClassValidity`, the
  single documented `Semantics → ProofSystem` edge), `FormalSystem.Semantics.DurationClassification`,
  `Mathlib.Order.Concept` (`Galois.lean` only — a Mathlib leaf, opening no new
  `FormalSystem`-internal seam), and `Mathlib.Algebra.Order.Archimedean.Defs` (`Rigidity.lean`
  only, for `Archimedean.arch`), plus `FormalSystem.Semantics.Frames.Standard`,
  `FormalSystem.Semantics.LexCarrier`, `Mathlib.Data.Int.SuccPred` and
  `Mathlib.Data.Rat.Denumerable` (`RigiditySharpness.lean` only), and
  `FormalSystem.Semantics.Extension`, `FormalSystem.ForMathlib.Topology.Sierpinski` and
  `Mathlib.Analysis.Real.Cardinality` (`RigidityReal.lean` only — the two edges this subtree did
  not previously carry are the extension theorem and `ForMathlib/Topology/`)
- **Imported by**: `FormalSystem.Semantics` (the aggregator), and
  `FormalSystem.Metalogic.Independence.{RationalWitness, LexIntWitness}`, which supply the two
  frames showing `Sat .Dedekind` and `Sat .Discrete` are *not* closed

## Related Documentation

- [Semantics README](../README.md)
- [Independence README](../../Metalogic/Independence/README.md) — the two non-closure witnesses
  and both sandwich theorems

---

**Last verified**: 2026-09-22

---

*Last verified: 2026-09-22*
