/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- Re-export commonly used modules for convenience
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.StrongCompleteness
import FormalSystem.Metalogic.DiscreteNonCompactness
import FormalSystem.Metalogic.DedekindNonCompactness
import FormalSystem.Metalogic.Compactness
import FormalSystem.Metalogic.Decidability
import FormalSystem.Metalogic.Independence
import FormalSystem.Metalogic.BXCanonical
import FormalSystem.Metalogic.WeakCanonical
import FormalSystem.Metalogic.Conservativity
import FormalSystem.Metalogic.Algebraic
import FormalSystem.Metalogic.Deterministic

/-!
# Bimodal Metalogic

This module re-exports the metalogical foundations for bimodal logic TM:
soundness, completeness, and decidability.

## Irreflexive Temporal Semantics

Under irreflexive semantics, G and H quantify over strictly future/past
times (s > t and s < t respectively, excluding the current time). Until uses strict
witness (s > t) with open guard (t, s). Since uses strict witness (s < t) with open
guard (s, t).

The modal T-axiom (Box phi -> phi) is valid (S5 universal accessibility), but the
temporal analogs (G phi -> phi, H phi -> phi) are NOT valid under irreflexive semantics.

## Conservativity (proof-theoretic, no semantics)

- **Backward TM/TM bridge** (`Conservativity.translate`, `derivable_translate`, and the four
  row corollaries `ceb_backward` / `cef_backward` / `ced_backward` / `cec_backward`):
  SORRY-FREE (axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). `TM ⊢ φ ⟹
  TM ⊢ tr φ` over the tense-primitive base language of `FormalSystem/MinusLanguage/`. The
  **forward** direction is refuted for the Base and Discrete rows and open for the other two;
  `Metalogic/Conservativity.lean`'s module docstring is the standing record of why it must not
  be attempted or `sorry`-ed. That record is row-dependent and is not restated here: CEF is
  refuted with both halves machine-checked, CEB is refuted in the source with only its TM half
  machine-checkable in this tree, and CED/CEC are open. Per-row status lives in
  `docs/theorem-index.md`; the standing prohibition lives in `Conservativity.lean`.
- **The H/G-fragment of TM** (`Conservativity.TMFrag`, `Metalogic/Conservativity/Fragment.lean`):
  SORRY-FREE (axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Because the forward
  direction is refuted, TM is not the complete logic of base-language validity; the fragment
  `TMFrag fc φ := TM ⊢[fc] tr φ` is — sound (`tmFrag_sound`), complete at all four classes
  (`tmFrag_complete_*`), containing TM everywhere (`tmMinus_le_tmFrag`) and strictly at `.ZTime`
  (`tmMinus_lt_tmFrag_ztime`). Its consequence relation is compact at `.Base` and `.Dense`
  (`minusCompactBase`, `minusCompactDense`, `Metalogic/Conservativity/FragmentCompactness.lean`); the
  Discrete/Dedekind non-compactness witnesses lie outside `range tr` and do not transfer.
- **The stability extension L⁺ / TM⁺** (`Metalogic/Conservativity/Plus.lean`, over
  `FormalSystem/PlusLanguage/` and `Semantics/PlusLanguage/`): SORRY-FREE (axioms: exactly
  `propext`, `Classical.choice`, `Quot.sound`). Soundness of TM⁺ at every frame class
  (`plus_soundness_validIn`), TD discharged semantically by the companion recursion with the
  TM schemata over L⁺ handled by atomization; semantic conservativity
  (`Semantics.plusValidIn_ofFormula_iff`); and **proof-theoretic conservativity of TM⁺ over TM
  in both directions at all four classes** (`plusDerivable_ofFormula_iff`) — the forward
  direction from TM⁺ soundness and the four completeness engines, needing no TM⁺ completeness.
  TM⁺ completeness and decidability are open. One durable fact bears on any future attempt: the
  countermodels of all four completeness engines are **deterministic** — `multiFamTaskFrameGen`
  (`Metalogic/Algebraic/FlowFrame.lean`) has `TaskRel p d q := p.1 = q.1 ∧ q.2 = p.2 + d`, and
  `zTaskFrameV2` (`Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`) has `u = w + d` —
  so on them `⊡` is the identity, and none of the engines transfers to L⁺.

## Publication-Ready Results

- **Soundness** (`soundness`): SORRY-FREE
- **Soundness (dense)** (`soundness_dense`): SORRY-FREE
- **Soundness (discrete)** (`soundness_ztime`): SORRY-FREE
- **Soundness, base language L⁻** (`minus_soundness`, `minus_soundness_dense`,
  `minus_soundness_ztime`, `minus_soundness_rtime`, plus the empty-context validity forms and the
  consistency corollaries `minus_not_derivable_nil_bot` / `minus_not_derivable_nil_bot_ztime`):
  SORRY-FREE (axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Stated against the
  **native** L⁻ semantics `MinusTruthAt` of `Semantics/MinusLanguage/MinusTruth.lean` — a six-clause recursion on
  `MinusFormula`, not `TruthAt ∘ tr` — and obtained by composing `Conservativity.translate` with the
  four theorems above across the truth-transfer bridge `Semantics.truthAt_tr`, which is proved by
  induction in `Metalogic/Conservativity/MinusLanguageSoundness.lean`. `minus_soundness_rtime` carries
  `ValidRTime`'s binder set and its validity form concludes at `MinusValidRTime`,
  inheriting `soundness_rtime`'s target; a density-free `MinusValidComplete` is deliberately not
  defined because it would be refutable
- **Completeness** (`completeness`): SORRY-FREE (sorryAx-free; axioms: exactly `propext`,
  `Classical.choice`, `Quot.sound`). Its Base-frame discrete branch,
  `WeakCanonical.countermodel_discrete`, is proved in
  `WeakCanonical/GroupModel/CountermodelBase.lean` at the non-Archimedean discrete carrier
  `ℚ ×ₗ ℤ`, off `companionChronicle`
- **Completeness (dense)** (`completeness_dense`): SORRY-FREE (sorryAx-free; axioms: exactly
  `propext`, `Classical.choice`, `Quot.sound`)
- **Completeness (discrete)** (`completeness_ztime`): SORRY-FREE (sorryAx-free; axioms:
  exactly `propext`, `Classical.choice`, `Quot.sound`)
- **Completeness (Dedekind)** (`completeness_rtime`): SORRY-FREE (sorryAx-free; axioms:
  exactly `propext`, `Classical.choice`, `Quot.sound`). Weak completeness for
  `FrameClass.RTime` against `ValidRTime`, on the real line. It is a corollary of
  the consequence form below, not an independent construction.
- **Consequence completeness (Dedekind)** (`consequence_completeness_rtime`): SORRY-FREE
  (sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Finite-context
  consequence completeness. This is **not** strong completeness: `Context` is `List Formula`,
  so it is inter-derivable with the weak form through the deduction theorem — see the module
  docstring of `StrongCompleteness.lean`. The finite-context consequence form now exists for
  **all four** frame classes; the three siblings follow.
- **Consequence completeness (base)** (`consequence_completeness_base`): SORRY-FREE
  (sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Stated against
  the existing general `SemanticConsequence` relation (`Semantics/Validity.lean`) rather than a
  new one, because for `FrameClass.Base` "all carriers" *is* the class. Its soundness guard is
  `soundness_base_consequence` and its weak corollary `completeness_base`, both at the same
  axiom set.
- **Consequence completeness (dense)** (`consequence_completeness_dense`): SORRY-FREE
  (sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Stated against
  `SemanticConsequenceDense`, with guard `soundness_dense_consequence` and weak corollary
  `completeness_dense`, both at the same axiom set.
- **Consequence completeness (discrete)** (`consequence_completeness_ztime`): SORRY-FREE
  (sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). Stated against
  `SemanticConsequenceZTime`, with guard `soundness_ztime_consequence` and weak corollary
  `completeness_ztime`, both at the same axiom set.

  **Terminology caveat, binding on all four entries above.** `Context` is `List Formula`, so
  every one of these is a *finite*-context result, inter-derivable with the corresponding weak
  form through the deduction theorem. None of them is **strong completeness**, which is reserved
  for consequence from a possibly-infinite `Γ : Set Formula` under a finitary set-derivability
  relation. The infinitary statement has **three distinct statuses** across the four classes,
  which must not be collapsed into one:

  * `FrameClass.ZTime` — **machine-refuted**. `notCompactZTime` and
    `notStrongCompletenessZTime` (entry below) settle it negatively.
  * `FrameClass.Base` and `FrameClass.Dense` — **proved**. `strongCompletenessBase` and
    `strongCompletenessDense` (`Metalogic/Compactness.lean`) inhabit the
    `StrongCompletenessBase`/`StrongCompletenessDense` statements of
    `Metalogic/SetConsequence.lean`, obtained by instantiating the single `FrameClass`-generic
    reduction `strongCompleteness_of_compact` with `compactBase`/`compactDense` and the
    weak-completeness engines. Compactness itself comes from
    `modelExistenceBase`/`modelExistenceDense` by an ultraproduct construction over the finite
    sublists of the premise set.
  * `FrameClass.RTime` — **refuted**, like Discrete. Reynolds 1992 Theorem 7 is weak-only,
    and this tree now explains why: `CompactRTime` and `StrongCompletenessRTime` are
    stated in `Metalogic/SetConsequence.lean` and refuted in
    `Metalogic/DedekindNonCompactness.lean` by `notCompactRTime` and
    `notStrongCompletenessRTime`.
- **Non-compactness (discrete)** (`notCompactZTime`): SORRY-FREE (sorryAx-free;
  axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). The `FrameClass.ZTime`
  set-based consequence relation is **not** compact: the premise set `{F p} ∪ {¬Xⁿ p : n ∈ ℕ}`
  is finitely satisfiable over `ℤ` yet has no model on any Archimedean discrete carrier. The
  companion `notStrongCompletenessZTime` (same axiom set) converts this into an outright
  refutation of strong completeness for the class, which is why only the weak form
  (`completeness_ztime`) appears above.
- **Decidability** (`decide`): SORRY-FREE
- **Characterization / definability** (`galoisClosed_mod`, `galoisClosed_of_indicator`,
  `galoisClosed_sat_dense`, `galoisClosed_isDiscrete`): SORRY-FREE, with the two negative
  results `sat_rtime_ssubset_mod_axiomSet` and `sat_ztime_ssubset_mod_axiomSet`
  (`Metalogic/Independence/{RationalWitness,LexIntWitness}.lean`). Non-Galois-closure of a
  narrowing is a statement about definability of the model class, a **different** property from
  strong completeness at that class — do not read one off the other. The exposition is in
  `README.md`'s "Characterization and Definability" section and is not repeated here;
  per-theorem status is in `docs/theorem-index.md`.
- **Non-definability of determinism** (`deterministic_not_plusDefinable`,
  `Metalogic/Independence/DeterminismUndefinable.lean`): SORRY-FREE. No set of `PlusFormula`s
  defines the class of frames satisfying `TaskFrame.Deterministic`, witnessed by the
  indistinguishable pair `F°` (a drift band over `ℝ`) and `F¹` (translation over `ℝ`), which
  validate exactly the same L⁺ formulas while differing in determinism. The same pair refutes the
  converse of the deterministic collapse `determined_of_deterministic`
  (`Semantics/PlusLanguage/PlusDeterminism.lean`): validity of *Determined* holds on a class strictly larger
  than the deterministic frames. Uniform substitution is unsound in this setting, so no proof
  here argues by substitution.
- **Expressive completeness (Kamp, Prior structures)** (`kampPriorExpressiveCompleteness`,
  `WeakCanonical/Kamp/KampPrior.lean`): SORRY-FREE (axioms: exactly `propext`,
  `Classical.choice`, `Quot.sound`). `{U, S}` is expressively complete relative to monadic
  first-order logic **for Prior structures** — not for TM, not for all task frames. Load-bearing
  for the live completeness chain via `uSExpressivelyCompleteOverPrior`.

## Completeness Architecture

The completeness proof uses a three-way case split based on MCS membership:

1. **Dense case** (Box(F'T) in M): Countermodel on Rat via Cantor isomorphism
   (Chronicle/ChronicleToCountermodel.lean, Algebraic/FlowFrame.lean)
2. **Discrete case** (Box(U(T,bot)) in M): Countermodel on Int
   (WeakCanonical/Transfer.lean)
3. **Mixed case**: Eliminated by `mcs_mixed_case_absurd`

The `FrameClass.RTime` route has no case split. `Dense <= Dedekind`, so
`Axiom.dense_indicator` is admissible in a Dedekind derivation and `dedekind_box_dense_mem`
(`BXCanonical/CompletenessDedekind.lean`) puts `Box(F'T)` in every Dedekind-MCS
unconditionally: only the dense branch exists. Its countermodel is on the **reals**
(`countermodel_dedekind_dense`), obtained by pushing the rational chronicle through Doets'
theorem (Reynolds 1992, Section 8 Theorem 6) at the chronicle bridge and reading the resulting
`R`-flowed monadic structure back as a value of the `R` fibre.

### Key Components

- **Algebraic/FlowFrame**: generic flow frame, four-axiom conformance, and the D-generic re-hosted truth lemma (core of countermodel)
- **BXCanonical/Chronicle/**: Burgess 1982 chronicle construction for dense case
- **WeakCanonical/**: Reynolds/Doets pipeline for discrete case
- **WeakCanonical/DenseModelSurgery/**, **WeakCanonical/RealModel/**: Reynolds Sections 6-8
  (Theorems 4, 5 and Doets' Theorem 6), the Dedekind route's model surgery and real-flow layer
- **BXCanonical/CompletenessDedekind.lean**: Reynolds Section 9 Theorem 7 — the real-line
  countermodel and the single-formula completeness engine
- **StrongCompleteness.lean**: the per-class finite-context consequence layer — for each of
  Base, Dense, Discrete and Dedekind a semantic deduction theorem, a consequence terminus, a
  soundness guard and a weak corollary — including the Dedekind terminus
  (`consequence_completeness_rtime`, `completeness_rtime`); plus the strong-completeness
  programme, the single `FrameClass`-generic compactness reduction
  `strongCompleteness_of_compact` (keeping its single-formula `engine` hypothesis live, so that
  the reduction records compactness as the whole of the gap between weak and strong
  completeness; the engine is supplied at the call site in `Compactness.lean`), the single
  model-existence bridge `compact_of_modelExistence` (which derives `Compact fc` from
  `ModelExistence fc`, and so `CompactBase` / `CompactDense` from their model-existence
  statements), and the non-compactness obstruction that bounds the Discrete class
- **Compactness.lean**: the discharge of the Base and Dense strong-completeness programme —
  `modelExistenceBase` and `modelExistenceDense` by an ultraproduct over the finite sublists of
  the premise set, `compactBase` and `compactDense` through the two bridges above, and
  `strongCompletenessBase` and `strongCompletenessDense` by instantiating the two reductions
- **SetConsequence.lean**: the `Γ : Set Formula` vocabulary the strong-completeness statements
  are phrased in — `SetDerivable`, the four per-class set consequence relations, and the
  `FrameClass`-indexed compactness family `SatisfiableSet` / `ModelExistence` / `Compact` /
  `StrongCompleteness`, whose per-class instantiations are the `Prop`-valued names for the Base
  and Dense statements (`StrongCompletenessBase`, `CompactBase`, `SatisfiableBaseSet`,
  `ModelExistenceBase` and their Dense siblings), proved in `Compactness.lean`, together with
  the refuted Discrete and Dedekind ones
- **DiscreteNonCompactness.lean**: the machine-checked discharge of one of those obstructions —
  the `{F p} ∪ {¬Xⁿ p}` witness, the first semantic characterisation of `Formula.next`
  (`truthAt_next_iff`), and the two refutations `notCompactZTime` and
  `notStrongCompletenessZTime`
- **DedekindNonCompactness.lean**: its Dedekind sibling, and the discharge of the last remaining
  obstruction — the `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤ : n ∈ ℕ}` witness (`dedWitness`, with
  `Xq φ = untl ¬q (q ∧ φ)`), finitely satisfiable over `ℝ` and unsatisfiable over every
  Dedekind-complete carrier, and the two refutations `notCompactRTime` and
  `notStrongCompletenessRTime`. `archWitness` does not port: `Formula.next` is vacuously
  false on a densely ordered carrier, so the witness is genuinely new
- **Bundle/**: BFMCS infrastructure (shared by all paths)

## Axiom Dependencies

Soundness, decidability, and the completeness theorems (`completeness_dense`,
`completeness_ztime`, `completeness_rtime`, `consequence_completeness_rtime`) all use
standard Lean axioms only: `propext`, `Classical.choice`, `Quot.sound`. The former `Lean.ofReduceBool`/`Lean.trustCompiler` dependency was eliminated
by swapping the Syntax-layer `native_decide` sites to `rfl`/`decide` (see the Axiom Audit
in `BXCanonical/Completeness.lean`). No `sorryAx` on any of these paths. The general
Base-frame `completeness` is now on the same footing: its discrete branch
`WeakCanonical.countermodel_discrete` is proved
(`WeakCanonical/GroupModel/CountermodelBase.lean`), so `completeness` too depends on exactly
those three axioms.

## Module Structure

Every subdirectory carries exactly one sibling aggregator `X.lean` beside `X/`, which check C8
asserts. `SoundnessLemmas` is a directory with such an aggregator, not a loose file, and there
is no top-level `Completeness.lean` — it had no live importer and is archived under
`Boneyard/SupersededCompleteness/`; the completeness results live on the three routes.

The per-directory file and line counts are not restated here. They are generated into
`Metalogic/README.md` by `scripts/check-module-invariants.sh --emit-inventory`, and the `INV`
check fails if they drift. There is exactly **one** archive in the tree,
`FormalSystem/Boneyard/`, and B0 asserts that; every count excludes it by directory name.
-/
