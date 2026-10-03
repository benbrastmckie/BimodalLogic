# FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/

The **limits** of the `PlusSlicedCertificate` class. This directory states no positive result. It
fixes a ℤ-time non-validity of `PlusFormula` — the CTL-like, `⊡`-carrying witness `Φ` — as a
specification, proves it is a genuine non-validity, and then shows that no model on any
finite-width `FrameOver.ofSlicedStep` frame satisfies it: the class's completeness obstruction is
exactly **finite width**.

Nothing here redefines `PlusSlicedCertificate`, `Certifies`, `FrameOver.ofSlicedStep`, or the
flagship completeness result. Those are consumed as given, and the soundness direction —
`PlusSlicedCertificate.Sound`'s `plusRefutes_of_certifies` — is not at issue.

## The route

1. **The witness.** `Φ := (A' ∧ C') ∧ D`: `A'`/`C'` say every history meets `p` exactly once,
   `D` says every pre state (every history through it has `p` strictly ahead) has a
   `p`-successor. Every `⊡` and `□` in `Φ` governs a state formula, so `Φ` lies in the CTL-like
   fragment.
2. **The positive half.** A countable, finitely branching, time-homogeneous regular ℤ-frame `F`
   with carrier `Node = {pre k} ∪ {x k} ∪ {post k j}` satisfies `Φ` (`Φ_true`,
   `not_plusValidZTime_neg_Φ`). Every bi-infinite step path of `F` is canonical
   (`path_eq_canon`), which is what makes verification a case split.
3. **The negative half.** No model on a finite-width `FrameOver.ofSlicedStep` frame satisfies `Φ`
   anywhere (`no_finite_width_sat`). Classify every state as `p`, pre, or post; predecessors of a
   `p` state are pre, so there is a `p` state at every earlier time; successors of `p`/post states
   are post; a post state has no infinite backward chain of post predecessors (König,
   `core_false`); but the forward post-chains from earlier `p` states reach every post state as
   backward chains of unbounded length — pigeonhole, on a finite carrier per time.
4. **The corollaries.** `not_certifies`, `not_sliced_complete`, `not_finite_width_fmp`: no
   `PlusSlicedCertificate` certifies `Φ.neg`, the class is incomplete for L⁺ over ℤ-time, and no
   certificate class presenting finite-width sliced frames is complete, whatever its clauses.

## What is refuted, and what is not

**Refuted, unconditionally.** The time-sliced certificate class is incomplete for full L⁺, and
already for the CTL-like fragment: `Φ.neg` is a ℤ-time non-validity no `PlusSlicedCertificate`
certifies. The obstruction is exactly finite width — `[Finite W] [Nonempty W]` is the whole
finiteness hypothesis on `no_finite_width_sat`, with no hypothesis on the succession relation
beyond the bi-seriality every `FrameOver.ofSlicedStep` frame already carries.

**Two scope limits.** Scope is ℤ (discrete) frames only: the pumping argument needs discreteness
and says nothing about a dense duration. `Φ` uses `⊡` (`PlusFormula.stab`), so this is
specifically an **L⁺** result, not a result about the base language TM.

**Two further disclaimers.** Nothing here is claimed about an *infinite* carrier (only about
finite per-time fibres over an infinite carrier). Nothing here touches soundness.

**Not a bound.** No width bound is proved for targets that *do* have a finite-width countermodel;
the defect is that `Φ.neg` has none at all, not that known bounds are too small.

**The semantic characterisation is argued, not proved.** The class is complete exactly on
targets with a finite-width countermodel: necessity is this directory's shape, sufficiency —
every finite-width model has an eventually periodic, hence tail-stable-presentable, finite-width
model — is a Ramsey-for-pairs-style periodicity argument not formalized anywhere in this tree.

## Modules

| Module | Contents |
|---|---|
| `NoFiniteWidth.lean` | The witness `Φ` and its five supporting definitions `pa`/`p`/`Fp`/`Pp`/`Xp`/`A'`/`C'`/`D`; the positive-half frame `F`/`M` on `Node` with the canonical-path theorem `path_eq_canon`, and `not_plusValidZTime_neg_Φ`; the negative-half path/pre-post/chain/König machinery and `core_false`; the semantic layer and `no_finite_width_sat`; the certificate corollaries `not_certifies`, `not_sliced_complete`, `not_finite_width_fmp` |

## Provenance

`NoFiniteWidth.lean` is a transcription of a compiled probe (`specs/.../probes/NoFiniteWidthModel.lean`),
with the arguments unchanged. What changed in the transcription is the import set (narrowed from
the whole library), the namespace (nested under `PlusSlicedCertificate.NoFiniteWidth` rather than
a probe-local namespace), and the linter discipline (per-declaration `omit [...] in` rather than a
file-level suppression). The probe is retained as the provenance record and is not superseded.

## Dependencies

- **Imports**: `PlusSlicedCertificate.Sound` (which transitively supplies `Check`, `Frame`,
  `Basic`, and the `Semantics`/`PlusLanguage` chain), `FormalSystem.Semantics.SlicedFrame`,
  `FormalSystem.Semantics.IntNormalForm`, `FormalSystem.PlusLanguage.PlusValidity`,
  `FormalSystem.Init`, and Mathlib's `Tactic.Ring`.
- **Imported by**: `PlusSlicedCertificate.lean`.

This subtree is sorry-free; its five headline declarations each report axioms
`[propext, Classical.choice, Quot.sound]`.

## Related Documentation

- [PlusSlicedCertificate README](../README.md)
- [Decidability README](../../README.md)
- [WitnessFamily Limits README](../../PlusWitnessFamily/Limits/README.md) — the companion limits
  directory for the retired sharing-witness class

---

*Last verified: 2026-10-03*
