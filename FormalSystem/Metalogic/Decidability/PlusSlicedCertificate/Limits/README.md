# FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Limits/

The **limits** of the `PlusSlicedCertificate` class and of the finite-carrier shape it replaced.
This directory states no positive result. On each of the two obstruction axes it fixes a ℤ-time
non-validity of `PlusFormula` as a specification, proves it is a genuine non-validity, and then
shows that no model on a frame of the shape in question satisfies it:

- **Finite width** (`NoFiniteWidth.lean`): the CTL-like, `⊡`-carrying witness `Φ` has no model on
  any finite-width `FrameOver.ofSlicedStep` frame, so the sliced class's own completeness
  obstruction is exactly finite width.
- **Finite carrier** (`FiniteCarrier.lean`): the `⊡`-free witness `θ` has no model on any regular
  ℤ-frame with a finite world-state carrier, which is why the sliced class's presented carrier is
  `ℤ × Fin n` rather than a finite type in the first place. That shape was never landed, so this
  is a limit of a *rejected* class shape rather than of the landed one — recorded here because the
  two axes are one story and are best read side by side.

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

**Refuted, unconditionally, on the other axis.** The finite-carrier finite model property fails
for L⁺ over ℤ-time (`FiniteCarrier.not_finite_carrier_fmp`) and fails already for the CTL-like
fragment (`FiniteCarrier.not_finite_carrier_fmp_fragment`). `[Finite F.WorldState]` is the whole
finiteness hypothesis on `FiniteCarrier.no_finite_carrier_sat`, with no hypothesis on the
succession relation beyond the regularity `[F.IsRegular]` carries.

**Two scope limits.** Scope is ℤ (discrete) frames only: the pumping arguments on both axes need
discreteness and say nothing about a dense duration. `Φ` uses `⊡` (`PlusFormula.stab`), so the
finite-width result is specifically an **L⁺** result, not a result about the base language TM.

**The two axes differ in both directions, and the asymmetry must not be blurred.** `θ` is
`⊡`-free — `FiniteCarrier.θ_eq_ofFormula` exhibits it as `ofFormula ψL` — so the finite-carrier
refutation is already a statement about the base language TM itself. `Φ` does use `⊡`, so the
finite-width refutation is specifically an L⁺ result and says nothing about TM. The obstruction
chain runs the other way: a finite carrier **forces** finite per-time width, so finite carrier is
the strictly weaker hypothesis, and the finite-width refutation is therefore the stronger result
on the hypothesis axis while the finite-carrier one is stronger on the language axis. Neither
subsumes the other.

**Two further disclaimers.** Nothing here is claimed about an *infinite* carrier — the width axis
speaks only about finite per-time fibres over an infinite carrier, and the carrier axis's own
positive half exhibits an infinite-carrier model rather than obstructing one. Nothing here touches
soundness, on either axis.

**Not a bound.** No width bound is proved for targets that *do* have a finite-width countermodel,
and no carrier bound of any kind is proved; the defect on each axis is that the witness's negation
has no countermodel of that shape at all, not that known bounds are too small.

**The semantic characterisation is argued, not proved.** The class is complete exactly on
targets with a finite-width countermodel: necessity is this directory's shape, sufficiency —
every finite-width model has an eventually periodic, hence tail-stable-presentable, finite-width
model — is a Ramsey-for-pairs-style periodicity argument not formalized anywhere in this tree.

## Modules

| Module | Contents |
|---|---|
| `FiniteCarrier.lean` | The `⊡`-free witness `θ` with its `Formula`-side twin `ψL` and the language-scope identity `θ_eq_ofFormula`; the fragment twin `θ'` built from `NoFiniteWidth`'s own `A'`/`C'` (shared, not copied — `noFiniteWidth_Φ_eq` pins the agreement); the ℤ-carrier shift set `S` with `shiftTruth_psiL` and the positive halves `not_plusValidZTime_neg_θ`, `not_plusValidZTime_neg_θ'`; the step-path-to-history helper `histOfStepPath` and the pumping refutations `no_finite_carrier_sat`, `no_finite_carrier_sat'`; the corollaries `no_ofStep_sat`, `not_finite_carrier_fmp`, `not_finite_carrier_fmp_fragment` |
| `NoFiniteWidth.lean` | The witness `Φ` and its five supporting definitions `pa`/`p`/`Fp`/`Pp`/`Xp`/`A'`/`C'`/`D`; the positive-half frame `F`/`M` on `Node` with the canonical-path theorem `path_eq_canon`, and `not_plusValidZTime_neg_Φ`; the negative-half path/pre-post/chain/König machinery and `core_false`; the semantic layer and `no_finite_width_sat`; the certificate corollaries `not_certifies`, `not_sliced_complete`, `not_finite_width_fmp` |

## Provenance

Each module here is a transcription of a compiled probe
(`specs/.../probes/NoFiniteWidthModel.lean` and `specs/.../probes/NoFiniteCarrierModel.lean`
respectively), with the arguments unchanged. What changed in the transcription is the import set (narrowed from
the whole library), the namespace (nested under `PlusSlicedCertificate.NoFiniteWidth` rather than
a probe-local namespace), and the linter discipline (per-declaration `omit [...] in` rather than a
file-level suppression). The probe is retained as the provenance record and is not superseded.

## Dependencies

- **Imports**: `PlusSlicedCertificate.Sound` (which transitively supplies `Check`, `Frame`,
  `Basic`, and the `Semantics`/`PlusLanguage` chain), `FormalSystem.Semantics.SlicedFrame`,
  `FormalSystem.Semantics.IntNormalForm`, `FormalSystem.PlusLanguage.PlusValidity`,
  `FormalSystem.Init`, and Mathlib's `Tactic.Ring`.
- **Imported by**: `PlusSlicedCertificate.lean`.

`FiniteCarrier.lean` additionally imports `Limits.NoFiniteWidth`, in order to **share** `pa`,
`p`, `Fp`, `Pp`, `A'` and `C'` with the finite-width landing rather than hold private copies of
them; the `⊡`-free witness `θ` uses nothing `⊡`-specific from it.

This subtree is sorry-free. `NoFiniteWidth.lean`'s five headline declarations and
`FiniteCarrier.lean`'s seven axiom-bearing headline declarations each report axioms
`[propext, Classical.choice, Quot.sound]`; `FiniteCarrier.θ_eq_ofFormula`, proved by `decide`,
depends on no axioms at all.

## Related Documentation

- [PlusSlicedCertificate README](../README.md)
- [Decidability README](../../README.md)
- [WitnessFamily Limits README](../../PlusWitnessFamily/Limits/README.md) — the companion limits
  directory for the retired sharing-witness class

---

*Last verified: 2026-10-03*
