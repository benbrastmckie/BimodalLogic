/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Backward
import FormalSystem.Metalogic.Conservativity.MinusLanguageSoundness
import FormalSystem.Metalogic.Conservativity.TMCompletenessReduction
import FormalSystem.Metalogic.Conservativity.SpWitness
import FormalSystem.Metalogic.Conservativity.Z1Countermodel
import FormalSystem.Metalogic.Conservativity.DenseObstructionTransfer
import FormalSystem.Metalogic.Conservativity.ChainBundleTruth
import FormalSystem.Metalogic.Conservativity.SpCountermodel
import FormalSystem.Metalogic.Conservativity.Fragment
import FormalSystem.Metalogic.Conservativity.FragmentCompactness
import FormalSystem.Metalogic.Conservativity.Plus
import FormalSystem.Metalogic.Conservativity.Star

/-!
# The TM⁻/TM conservativity bridge — backward direction

`TM⁻ ⊢ φ  ⟹  TM ⊢ tr φ`, by structural recursion over TM⁻ derivations, parameterized by the
existing `ProofSystem.FrameClass` so that the paper's four rows are four instantiations of one
theorem rather than four developments.

## System names, and how they map onto the paper

Two families of system name run through this directory, and only one of them is the paper's.

- **`TM` is the paper's `TM`.** `TM` is this repository's name for the proof system over the
  language `L`, with `S` and `U` primitive (`ProofSystem/`), and the paper calls that same system
  `TM` (`def:TMplus` — the anchor label still reads `TMplus` for historical reasons, but its text
  defines `TM` over 𝓛). Its extensions `TM_z`, `TM_d` and `TM_r` are the paper's `TM_z`, `TM_d`
  and `TM_r`, each named for the class it is complete over (`cor:tm-completeness`): `ℤ`-time, the
  dense task frames, and `ℝ`-time — the dense and Dedekind-complete orders. They rest on the
  Burgess–Xu cores `BX_z`, `BX_d` and `BX_r` (`def:BX-z`, `def:BX-d`, `def:BX-r`, pinned under
  those names in `docs/reference/paper-definitions-of-record.md`; the paper's earlier labels for them were
  `def:TMplus-f`, `def:TMplus-d` and `def:TMplus-c`, now recorded `DANGLING`), where `BX_r`
  extends `BX_d` by `PU` and `SEP` with `CO` a *derived* theorem rather than a further axiom —
  which is exactly this tree's own Dedekind-class arrangement (`Theorems/DedekindDerived.lean`).
- **`TM⁻` and its extensions answer to no paper system.** `TM⁻` is this repository's name for the
  system over the Past/Future language `L⁻`, with `H` and `G` primitive (`MinusLanguage/`), and
  its extensions `TM⁻_z`, `TM⁻_d` and `TM⁻_r` add `DF`, `DN`, and `DN` together with `CO`. The
  paper names no Past/Future system at all: the passage that once did is commented out in the
  live source, pending exactly the kind of result this directory supplies. The `z`/`d`/`r`
  subscripts on this side are Lean-only labels, chosen to run parallel to the `TM` side.
  The `FrameClass` tags `.ZTime`, `.Dense` and `.RTime` name the same three classes on both
  sides. Do not read `TM⁻_z` as a paper system.

The `⁻` superscript carries that whole distinction and is load-bearing throughout this directory.
The historical subscripts are retired on both sides: what was written `_f` is now `_z`, and what
was written `_c` or `_dc` is now `_r` — the two former names for the dense-and-complete extension
having collapsed into one. No system name in this tree carries an `_f`, `_c` or `_dc` subscript.

## Main Definitions

- `translate` : the recursion, `MinusLanguage.DerivationTree fc Γ φ →
  ProofSystem.DerivationTree fc (trCtx Γ) (tr φ)`

## Main Results

- `derivable_translate` : the `Prop`-level corollary
- `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward` : the four paper rows

Per-theorem status for all of these — statement, frame class, and machine-pinned axiom set —
lives in `docs/theorem-index.md`, which is the repository's single ledger. This module is the
authority on *why the forward direction must not be attempted*, not on which theorems hold.

## Scope

This module proves the **backward** direction only.

# THE FORWARD DIRECTION IS NOT OPEN WORK — DO NOT ATTEMPT IT

The converse, `TM ⊢ tr φ ⟹ TM⁻ ⊢ φ`, is **refuted** for the Base and Discrete rows and
**open** for the other two. This section exists so that a future dispatch reading only this
file does not re-attempt it. The evidence below is this repository's own axiom set, not an
appeal to the source.

## Why it must not be `sorry`-ed

Writing

```
theorem forward {fc} {φ} : ProofSystem.Derivable fc [] (tr φ) → MinusLanguage.Derivable fc [] φ
```

and discharging it with `sorry` would place a `sorry` on a statement that is **provably
false** at `fc := .Base` and `fc := .ZTime`. That is an unsound placeholder, not deferred
debt, and the repository's zero-debt policy forbids it. Do not state the theorem; do not state
an approximation of it.

**Cross-reference**: `Metalogic/Conservativity/TMCompletenessReduction.lean` pins "TM⁻ (resp. TM⁻_z) is complete
over task frames" as *the same proposition* as `forward` above, restricted to `fc := .Base`
(resp. `.ZTime`) — its `tmMinusCompleteBase_iff_forwardBase` / `tmMinusCompleteZTime_iff_forwardZTime`
are equivalences between two unasserted `Prop`s, proving neither side. A future dispatch
attempting to prove TM⁻-completeness directly is thereby attempting `forward` under a different
name, and falls under this same prohibition.

## CEF / `FrameClass.ZTime` — refuted, and **both halves are now machine-checked**

`ProofSystem.Axiom.z1` (`ProofSystem/Axioms.lean`, `minFrameClass = .ZTime`) is

```
G(Gφ → φ) → (F(Gφ) → Gφ)
```

built entirely from `allFuture`, `someFuture` and `imp`. Take the L⁻-side schema `Z1` below —
the same formula with L⁻'s *derived* `F` — and `z1_translate` proves
`⊢[Discrete] tr (Z1 φ)` outright, in two lines: the axiom, plus the standing `F`-bridge. That is
the TM_z half.

The other half — `TM⁻_z ⊢ Z1 φ` fails, because `TM⁻_z = TM⁻ + DF` is sound over *every* discrete
frame while `Z1` is unsound over non-Archimedean discrete orders — is now **also** a theorem:
`Metalogic/Conservativity/Z1Countermodel.lean`'s `not_minus_derivable_z1`, via `minus_soundness_ztime_succ`
(`Metalogic/Conservativity/MinusLanguageSoundness.lean`, the binder-weakened discrete L⁻ soundness theorem
dropping the Archimedean instances) applied to a countermodel over `ℚ ×_lex ℤ`
(`Semantics/LexCarrier.lean`), **not** `ℤ ×_lex ℤ` as an earlier draft of this section and the
research report both suggested — `ℚ ×_lex ℤ` is the carrier `BXCanonical/DiscreteCarrierProbe.lean`
already probes for the `FrameClass.Base` layer, so the two modules read as one story rather than
introducing a second non-Archimedean carrier. **CEF is therefore refuted with both halves
machine-checked**, not merely documented.

**One correction to the research report.** The report asserted `z1 φ = tr (Z1 φ')` as a
syntactic identity. It is not, and cannot be: `Formula.someFuture` is a top-level `untl`, and
by `MinusLanguage.tr_ne_untl` nothing in the range of `tr` is a top-level `untl`. The bridge
`MinusLanguage.notGNotImpF` closes the gap derivably instead — see `z1_translate`.

## CEB / `FrameClass.Base` — refuted, and **both halves are now machine-checked**

The source's witness is `(Sp) := □φ_DF ∨ □ψ_DN`. Its TM derivation uses TMP-NB (`X⊤ → □X⊤`)
and M5, and **both are available at `FrameClass.Base` in this repository**:
`ProofSystem.Axiom.discrete_box_necessity` is TMP-NB and
`ProofSystem.Axiom.modal_5_collapse` is M5, and neither is named in
`ProofSystem.Axiom.minFrameClass`'s non-`Base` list, so both fall through its catch-all to
`.Base`. The source's `(Sp)` derivation is thus available verbatim in `⊢[FrameClass.Base]`,
given the repository's own `completeness_*` results for the two L-valid conditionals — but
this repository does not reconstruct that TMP-NB/M5 derivation; instead `Metalogic/Conservativity/SpWitness.lean`
reaches the same TM half by a different, and independently informative, route: `(Sp)` (its own
reconstruction of the witness, since the source formula's own `\label` was deleted from the
paper — see Provenance below) is L⁻-**valid** on every task frame for a purely order-theoretic
reason (`SpWitness.minusValid_sp`, from `Semantics/DurationClassification.lean`'s
`duration_dense_or_least_pos` dichotomy), and composing with `BXCanonical.completeness` yields
`⊢[Base] tr (Sp φ ψ)` (`SpWitness.sp_translate`) with **no appeal to TMP-NB or M5 at all**.

The failing half — the schema `(Sp)` is not a TM⁻-theorem — is **now machine-checked** in
`Metalogic/Conservativity/SpCountermodel.lean`: `not_derivable_sp` at the atomic instance, and
its corollary `tmMinusCompleteBase_refuted : ¬ TMMinusCompleteBase`, the `.Base` mirror of
`Z1Countermodel.tmMinusCompleteZTime_refuted`.

The two-fibre description this section previously gave as a wish list is what the implementation
vindicates, and it is the *explanation* of why the result took the shape it did. The refutation
cannot live on a `TaskFrame`: `Metalogic/Conservativity/SpWitness.lean`'s un-boxed sharpening
(report §4.2) shows `(Sp)`'s un-boxed dichotomy is valid on *every* strict linear order, so a
countermodel needs a structure where `□` sees differently-shaped time, which no single
`TaskFrame` (one shared `Duration`) can express. Neither can it be reached by composition through
`tr`: **TM is unsound on the two-fibre class**, so the `translate`-then-`soundness` route this
module supplies is unavailable in principle for this half. What closed it instead is exactly what
this section previously said was missing — a frame notion outside `TaskFrame`
(`Semantics/MinusLanguage/MinusFrame.lean`'s `MinusFrame`: a nonempty point set with an unbounded, transitive,
irreflexive, forward- and backward-linear order and **no group structure**, with `□` read as the
universal modality over the points) plus a *native*, non-composed L⁻ soundness theorem over it
(`minusFrameValid_of_derivation`, by recursion on `MinusLanguage.DerivationTree`, with
`Semantics.truth_swap` discharging the temporal-duality rule). The countermodel is the disjoint
sum `ℤ ⊕ ℝ` — a discrete fibre refuting the `DN` disjunct and a dense-complete fibre refuting the
`DF` disjunct, both `□`-accessible. Note that the native soundness theorem is about **TM⁻**
(`MinusLanguage.DerivationTree`), never about TM; the two must not be blurred.

One caveat is recorded so it is never re-attempted: the *universally quantified* reading — "no
instance of `(Sp)` is a TM⁻-theorem" — is **false**. `□(DF ⊤)` holds on every `MinusFrame` (its
consequent follows from `no_max`), so `Sp ⊤ ψ` is not refuted. The claim is schema-level,
witnessed by the atomic instance, which is all a completeness refutation needs.

## The Kripke-level answer to "what is TM⁻ complete for" (report §5(i)) — principled, unformalized

Independently of the CEB/CEF/CED/CEC row analysis above, there is a standard modal-logic answer
to what TM⁻'s Kripke frame class actually is: **S5 ⊗ Kt4.3 + MF**, complete by Sahlqvist
canonicity. This is textbook material (the axioms MK/MT/M5/MF/TK/T4/TS/TC/TL are each Sahlqvist,
and Sahlqvist's theorem gives canonicity, hence completeness, for their join), not a repository
result: formalizing the Sahlqvist-canonicity argument itself is a large separate development
(explicitly a Non-Goal of this plan) and is recorded here only as the principled answer's
provenance, never as something this tree has machine-checked.

## Two live-paper facts bearing on the discrete rows

- **The paper pins the `ℤ`-time class exactly** (`def:BX-z`, live text). Its closing sentence
  reasons that `UZ` and `Z1` fail over every discrete temporal order that is not Archimedean, and
  that the Archimedean discrete orders are exactly `ℤ`-time, so the discrete task frames over
  which `BX_z` and `TM_z` are sound and complete are exactly those over `ℤ`-time. (The earlier
  wording, which reached that conclusion through Hölder's theorem and spoke of a
  "successor-Archimedean discrete class", has been cut from the paper; the conclusion is
  unchanged, and is restated here rather than quoted.) This is what makes
  `Z1Countermodel.tmMinusCompleteZTime_refuted` read as the `TM⁻_z`-vs-`TM_z` completeness *gap*,
  rather than a weaker claim about some other class.
- **A commented (non-live) line** inside `def:BX-z` gives the author's own position in the
  author's own words: `TM_z`, by contrast, is sound over the full class of discrete frames,
  since `DF` is valid on every discrete order and not only on `ℤ`-time; whether it is complete
  over that broader class remains open, as discussed at `cor:tm-completeness`. Cited as the
  author's stated position and flagged explicitly as **commented out**, therefore not live text —
  the open verdict it records matches this module's own CEF finding
  (`Z1Countermodel.tmMinusCompleteZTime_refuted`) that `TM⁻_z` is not weakly complete over the
  *broader* (non-Archimedean) discrete class, only over `ℤ`-time.

## The H/G-fragment logic

Because the forward direction is refuted, TM⁻ is **not** the complete logic of `MinusValidIn`. The
logic that is — at every frame class carrying a `WeakCompleteness` engine — is the **H/G-fragment
of TM**, `TMFrag fc φ := TM ⊢[fc] tr φ` (`Conservativity/Fragment.lean`). Its soundness,
completeness at four rows, containment of TM⁻, and the strictness of that containment at `.ZTime`
are rows in `docs/theorem-index.md`, which is the status of record and is not restated here.
`tmMinusComplete_iff_tmFrag_le_tmMinus` restates the reduction above in fragment terms with `Forward`
unfolded, never asserted. Compactness of the base-language consequence relation transfers along
`tr` at `.Base` and `.Dense` **only** (`Conservativity/FragmentCompactness.lean`): the Discrete
and Dedekind non-compactness witnesses lie outside `range tr`, so nothing transfers there.

## The stability extension L⁺

The other extension direction, L ⊂ L⁺ (L plus the paper's stability modal `⊡`, `def:BLstar-semantics`;
`FormalSystem/PlusLanguage/`), is the mirror image of L⁻ ⊂ L with the hard direction *available*:
`Conservativity/Plus.lean` (aggregating `Plus/{Atomization,AxiomValidity,PlusSoundness,Forward}.lean`)
proves soundness of TM⁺ at every frame class and **proof-theoretic conservativity of TM⁺ over
TM in both directions** at all four classes; both are rows in `docs/theorem-index.md`. What
matters here is *why* the forward half is available: backward is the embedding of derivations,
and forward is TM⁺ soundness plus the truth-transfer bridge plus the TM completeness engine —
the very composition that fails for L⁻ ⊂ L because TM⁻ is incomplete. So `Forward⁺` holds
everywhere, unlike `Forward`; the composed pair L⁻ ⊂ L⁺ (`plus_of_tmMinus`) inherits this module's
forward status unchanged. TM⁺ completeness and decidability are open and not asserted anywhere.

## The register extension L⋆

One level further out, L⁺ ⊂ L⋆ adds the manuscript's time registers `↑ⁱ`/`↓ⁱ`
(`def:BLstar-semantics`; `FormalSystem/StarLanguage/`), and `Conservativity/Star.lean` carries
TM⋆'s soundness and its two conservativity rows. The rows split, and the split is the same
completeness-engine fact as above read one level up: over **TM** the composition ends in a TM
engine and there are four, so `starDerivable_ofFormula_iff` is unconditional at all four classes;
over **TM⁺** it ends in a TM⁺ engine and there is none, so that row is a proved conditional pair
whose unconditional half says any separating witness for non-conservativity is a witness of TM⁺
incompleteness. TM⋆ completeness is open under two named obstructions and is asserted nowhere;
see `Conservativity/Star/README.md`.

## CED / CEC — open

No counterexample analogous to the CEB and CEF witnesses is known for CED. CEC inherits that
openness, plus an independent doubt: whether CO alone axiomatizes the same L⁻-logic as
the full Reynolds triple is itself open, and the converse direction (CO deriving the Reynolds
gap axioms) is separately **refuted** in
`FormalSystem.Metalogic.Independence.CoNotPriorU`. "Open" here means open in the source, not
merely unattempted here.

## What a machine-checked refutation would need — now row-dependent, not a single narrowing

An L⁻-side semantics and an L⁻-side soundness theorem now exist tree-wide
(`FormalSystem/Semantics/MinusLanguage/MinusTruth.lean`'s `MinusTruthAt`, and
`FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`'s `minus_soundness` family), but what each row
still needs beyond that differs, and reading it as one shared "countermodels alone" gap is no
longer accurate for either row:

- **CEF (`FrameClass.ZTime`) — done, both halves machine-checked.** The missing prerequisite
  was a *binder-weakened* L⁻ soundness theorem — `minus_soundness_ztime_succ`
  (`Metalogic/Conservativity/MinusLanguageSoundness.lean`), dropping `IsSuccArchimedean`/`IsPredArchimedean` so
  it applies to a non-Archimedean carrier — plus the countermodel itself, assembled over
  `multiFamTaskFrameGen` at the non-Archimedean discrete carrier `ℚ ×_lex ℤ`
  (`Semantics/LexCarrier.lean`, `Metalogic/Conservativity/Z1Countermodel.lean`). **Both are now landed**: `z1_translate`
  below is the TM_z half, and `Z1Countermodel.not_minus_derivable_z1` is the TM⁻_z half — the
  refutation is machine-checked, not merely documented.
- **CEB (`FrameClass.Base`) — done, both halves machine-checked.** The missing prerequisite was
  a **frame notion outside `TaskFrame`** plus a **native** (non-composed) L⁻ soundness theorem
  over it, and both are now landed: `Semantics/MinusLanguage/MinusFrame.lean` supplies `MinusFrame`/`MinusFrameTruth`/
  `MinusFrameValid` and the order-reversal transfer lemma `truth_swap`, and
  `Metalogic/Conservativity/SpCountermodel.lean` supplies
  `minusFrameValid_of_derivation` together with the `ℤ ⊕ ℝ` countermodel. The TM
  half is `Metalogic/Conservativity/SpWitness.lean`'s `minusValid_sp`/`sp_translate`; the TM⁻ half is
  `not_derivable_sp`, and the two compose into
  `tmMinusCompleteBase_refuted`.
  Why the composition route this module supplies could **not** serve here, in one line:
  `MinusTruthAt`/`minus_soundness` are `TaskFrame`-bound, `(Sp) := □(DF φ) ∨ □(DN ψ)` is L⁻-valid on
  *every* task frame, and **TM is unsound on the two-fibre class** — so
  `translate`-then-`soundness` was unavailable in principle, and a native soundness theorem was
  mandatory rather than merely convenient. See `Metalogic/Conservativity/SpWitness.lean`'s module
  docstring for the un-boxed sharpening (report §4.2) that makes this precise: `□` is what turns
  the dichotomy into a frame-uniform fact, and a CEB refutation needs a structure where different
  histories see differently-shaped time.

The **forward direction remains refuted** at both rows and must still not be stated or
`sorry`-ed here — nothing about the CEF closure changes that; it closes CEF's specific
row-refutation with a machine-checked witness, while leaving the general prohibition (this
module's own `forward` schema, for every frame class) exactly as forbidden as before. See also
`Metalogic/Conservativity/TMCompletenessReduction.lean`, whose `tmMinusCompleteBase_iff_forwardBase` /
`tmMinusCompleteZTime_iff_forwardZTime` pin "TM⁻ (resp. TM⁻_z) complete over task frames" as the
*same proposition* as this module's forward-conservativity prohibition, at `.Base` and
`.ZTime` respectively — so a future dispatch attempting TM⁻-completeness directly is thereby
attempting the forbidden claim, under a different name.

## Provenance of the source claim — historical, not a live anchor

`\label{thm:ConservativeExtension}` **no longer exists** in the paper. Cite it only as
history:

- Introduced at paper commit `df2e8ad9` (2026-06-29).
- Last revision carrying the theorem together with its full seven-site cross-reference set:
  **`58c7c0c0^` = `330bb25d` (2026-08-12)**. Commit `58c7c0c0` itself
  ("cor:tm-completeness four-row restructure") cut those seven sites to four.
- The `\label` itself was removed at **`b07ceb31` (2026-08-12)**, not at `c0116d04`. (The
  research report and this task's plan both name `c0116d04` (2026-08-14) as the deletion
  commit; that is off by two commits and two days. `c0116d04` is where the last *prose*
  assertion of conservativity was rewritten, and its only remaining occurrence of the string
  is a source comment describing the label as already deleted. Verified by walking
  `git log -- JPL/possible_worlds.tex` and counting `\label{thm:ConservativeExtension}` per
  revision.)
- The live paper contains no occurrence of "conservative" at all, and states that a
  proof-system conservativity theorem for the tense-primitive subsystem "is that subsystem's
  own future result rather than part of this book's system".

Do **not** cite `thm:ConservativeExtension` as a live anchor. For any semantic definition this
module leans on, cite `docs/reference/paper-definitions-of-record.md` rather than the paper directly;
`bash scripts/check-paper-definitions.sh` was run at implementation time and reports the same
two drifted and six dangling anchors the research report recorded, none of them consumed here.

## No semantics

Nothing here — nor anything under `FormalSystem/MinusLanguage/`, transitively — imports
`FormalSystem.Semantics`. `translate` is a function between two `DerivationTree` types and
touches no truth definition, frame, or validity predicate, so the bridge composes unchanged
with whatever the totality-based validity definition becomes. The intended composition is

```
L⁻-validity over C  ⟸[minus_soundness…]  ⊢⁻[fc] φ  ⟶[translate]  ⊢[fc] tr φ
                                                          ⟸[completeness_*]  L-validity over C
```

and this module is the middle arrow only. The left arrow is now built, in
`FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean`, which is where the `FormalSystem.Semantics`
import lives; it composes `translate` with `Metalogic/Soundness.lean`'s four theorems across the
truth-transfer bridge `truthAt_tr`. This module and everything under
`FormalSystem/MinusLanguage/` remain semantics-free.
-/

/-!
## What this module is

**This file is the aggregator, and it holds no declarations.** It carries the narrative above —
the forward-conservativity prohibition, the paper-anchor record, and the per-row status of CEB
and CEF — and re-exports the nine modules that make up the L⁻-vs-TM⁻ and TM-vs-TM⁺ story:

| Module | Contents |
|--------|----------|
| `Conservativity/Backward.lean` | `translate`, `derivable_translate`, the four `*_backward` rows, `Z1`, `z1_translate` |
| `Conservativity/MinusLanguageSoundness.lean` | the `minus_soundness` family and the `truthAt_tr` transfer bridge |
| `Conservativity/TMCompletenessReduction.lean` | `TMMinusComplete` / `Forward` and their equivalence |
| `Conservativity/SpWitness.lean` | the reconstructed `(Sp)` witness for the CEB row |
| `Conservativity/Z1Countermodel.lean` | `not_minus_derivable_z1` and `tmMinusCompleteZTime_refuted` |
| `Conservativity/SpCountermodel.lean` | `not_derivable_sp` and `tmMinusCompleteBase_refuted`, over the native `MinusFrame` semantics |
| `Conservativity/Fragment.lean` | `TMFrag`, the H/G-fragment of TM: soundness, completeness at all four classes, `TM⁻ ⊆ TMFrag`, `TM⁻ ⊊ TMFrag` at `.ZTime` |
| `Conservativity/FragmentCompactness.lean` | `MinusCompact`, `minusCompactBase`, `minusCompactDense` — base-language compactness transferred along `tr` |
| `Conservativity/Plus.lean` | aggregator for the L⁺ side: TM⁺ soundness at every class and conservativity of TM⁺ over TM in both directions (`plusDerivable_ofFormula_iff`) |
| `Conservativity/Star.lean` | aggregator for the L⋆ side: TM⋆ soundness at every class, conservativity of TM⋆ over TM in both directions (`starDerivable_ofFormula_iff`), and the conditional pair over TM⁺ |

**The children must never import this file.** Each imports
`FormalSystem.Metalogic.Conservativity.Backward` directly; importing the aggregator from a child
is an import cycle, because the aggregator imports every child. The chain the children preserve
is `Backward ← MinusLanguageSoundness ← TMCompletenessReduction ← Z1Countermodel ← Fragment ←
FragmentCompactness ← Plus/Forward`, with `SpWitness` hanging off `MinusLanguageSoundness`,
`SpCountermodel` hanging off `SpWitness` and `TMCompletenessReduction` jointly (it also imports
`Semantics/MinusLanguage/MinusFrame.lean`, which is outside this directory and reaches nothing in `ProofSystem/`),
and the `Plus/` chain `Atomization ← AxiomValidity ← PlusSoundness ← Forward` hanging off
`Fragment`. The `Star/` chain `StarAxiomValidity ← StarSoundness ← Forward` hangs off the `Plus/`
one at two points: `Star/StarAxiomValidity` imports `Plus/AxiomValidity` (for the two TM⁺
dispatch lemmas the closed uniformity arms transport) and `Star/Forward` imports `Plus/Forward`
(for the four completeness engines and `plusValidIn_ofFormula_iff`).

The namespace is unchanged by the reorganization: `Backward.lean` still opens
`namespace FormalSystem.Metalogic.Conservativity`, so every declaration keeps its
fully-qualified name and no call site outside these files moved.
-/
