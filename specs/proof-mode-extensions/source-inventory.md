# Checked source inventory

Implementation baseline: `81ae7a6`, Lean v4.33.0-rc1. Primitive transfers are closed formula
theorems; demand monotonicity is a separate function on closed derivations. The
[kernel](../../FormalSystem/Theorems/ProofMode/Congruence.lean) checks every instantiated type,
including arbitrary stability-containing Plus arguments. All rows retain fc and start at [];
their whole-formula implications are weakened to Γ after construction.

| Position | Demand | Polarity | Actual closed source |
| --- | --- | --- | --- |
| Implication antecedent | Identity | Negative | Propositional B composition schema |
| Implication consequent | Identity | Positive | Flipped implication-composition schema |
| □ | □ | Positive | `Axiom.modal_k_dist` / `PlusAxiom.modal_k_dist` |
| ⊡ | ⊡ | Positive | Native `PlusAxiom.stab_k` |
| G/H | G/H | Positive | `TemporalDerived.gDistribution` / `hDistribution` |
| Until guard/event | G | Positive | `untilMonoGuard` / `untilMonoEvent` |
| Since guard/event | H | Positive | `sinceMonoGuard` / `sinceMonoEvent` |
| X/Y, exact evidence | X/Y | Positive | `ProofMode.nextK` / `prevK` |
| X/Y, conservative evidence | G/H | Positive | U/S event monotonicity at guard ⊥ |

Plus transfers each closed TM schema at atoms with `ofTMSubst`; stability stays native.
Next/Previous demand monotonicity uses G/H necessitation and event monotonicity at ⊥, never
closed X/Y necessitation. The frontend uses that conservative route for closed rules at Base.
Closed Next/Previous introduction remains the integer-time operation with its existence gate.

Derived negation, conjunction, disjunction and possibility views compose primitive steps.
Each step is bound to the actual selected argument and its siblings. Iff repeats both arguments
and is not advertised as a single monotone argument view.

| Conversion/projection | Actual source | Premises retained |
| --- | --- | --- |
| □P→GP / HP | `Theorems.Perpetuity.boxToFuture` / `boxToPast` | Same fc, no open assumptions |
| □P→⊡P | `PlusAxiom.box_stab` | Plus language |
| □P→□□P | `ProofSystem.DerivedAxioms.modal4` | Same fc |
| GP→GGP / HP→HHP | `TemporalDerived.gTransitivity` / `hTransitivity` | Same fc; strict time |
| Scoped iff→scoped arrow | Closed `Propositional.lceImp` / `rceImp`, lifted by demand monotonicity | Exact demand word |

`temporalFutureDerived` proves □P→G□P, not □P→GP. The implementation uses the existing direct
Perpetuity helper. The finite resolver permits exact words, single-letter boxed conversions and
homogeneous iteration, with no unrestricted conversion search.

`Metalogic.soundness_in` consumes the native tree, `fc.Sat F`, the exact model/history/time and
truth of every assumption in an abstract Γ at that point. The shared extension fixture
type-checks this application. The Plus counterpart is `Conservativity.plus_soundness_in`.
Soundness stays outside both pure kernels; Base satisfaction includes regularity.

The branch-2 temporal module type-checks Base Until/Since fold, ZTime unfolding, mapped-context
reflection, strict progress composition and G/H persistence. It is integrated in the native frontend.
Branch 3 integrates covering-time, semantic demand, rank, typed transports and explicit
context-form soundness. `ProofModeRules` and `ProofModeTemporalRules` are clause-only layer 1;
`ProofModeIntervals` adds strict/inclusive/dual truth views and concrete TM/Plus pins.
`ProofModeTransport` wraps the existing correspondence/shift/reversal/locality/morphism sources;
its HistoryMorphism import retains that existing module’s documented Axioms seam.
`Metalogic/ProofModeSoundness` is the higher-layer native adapter. Semantic frontend leaves
retain the exact truth dictionary and all evaluation indices.

Native rules use the existing layer-2 `Theorems/ProofMode` classification; elaborators and
registration use layer-3 `Automation/ProofMode`. Registration validates actual result judgments
and telescopes and stores only declaration names/orientations. Native roots guard the named
completeness exports. No metadata itself establishes an inference.

Last updated: 2026-11-19.
