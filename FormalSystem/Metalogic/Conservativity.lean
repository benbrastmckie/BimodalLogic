/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Backward
import FormalSystem.Metalogic.Conservativity.BaseLanguageSoundness
import FormalSystem.Metalogic.Conservativity.TMCompletenessReduction
import FormalSystem.Metalogic.Conservativity.SpWitness
import FormalSystem.Metalogic.Conservativity.Z1Countermodel

/-!
# The TM/TM⁺ conservativity bridge — backward direction

`TM ⊢ φ  ⟹  TM⁺ ⊢ tr φ`, by structural recursion over TM derivations, parameterized by the
existing `ProofSystem.FrameClass` so that the paper's four rows are four instantiations of one
theorem rather than four developments.

## Main Definitions

- `translate` : the recursion, `BaseLanguage.DerivationTree fc Γ φ →
  ProofSystem.DerivationTree fc (trCtx Γ) (tr φ)`

## Main Results

- `derivable_translate` : the `Prop`-level corollary
- `ceb_backward`, `cef_backward`, `ced_backward`, `cec_backward` : the four paper rows

## Scope

This module proves the **backward** direction only.

# THE FORWARD DIRECTION IS NOT OPEN WORK — DO NOT ATTEMPT IT

The converse, `TM⁺ ⊢ tr φ ⟹ TM ⊢ φ`, is **refuted** for the Base and Discrete rows and
**open** for the other two. This section exists so that a future dispatch reading only this
file does not re-attempt it. The evidence below is this repository's own axiom set, not an
appeal to the source.

## Why it must not be `sorry`-ed

Writing

```
theorem forward {fc} {φ} : ProofSystem.Derivable fc [] (tr φ) → BaseLanguage.Derivable fc [] φ
```

and discharging it with `sorry` would place a `sorry` on a statement that is **provably
false** at `fc := .Base` and `fc := .Discrete`. That is an unsound placeholder, not deferred
debt, and the repository's zero-debt policy forbids it. Do not state the theorem; do not state
an approximation of it.

**Cross-reference**: `Metalogic/Conservativity/TMCompletenessReduction.lean` pins "TM (resp. TM_f) is complete
over task frames" as *the same proposition* as `forward` above, restricted to `fc := .Base`
(resp. `.Discrete`) — its `tmCompleteBase_iff_forwardBase` / `tmCompleteDiscrete_iff_forwardDiscrete`
are equivalences between two unasserted `Prop`s, proving neither side. A future dispatch
attempting to prove TM-completeness directly is thereby attempting `forward` under a different
name, and falls under this same prohibition.

## CEF / `FrameClass.Discrete` — refuted, and **both halves are now machine-checked**

`ProofSystem.Axiom.z1` (`ProofSystem/Axioms.lean`, `minFrameClass = .Discrete`) is

```
G(Gφ → φ) → (F(Gφ) → Gφ)
```

built entirely from `allFuture`, `someFuture` and `imp`. Take the BL-side schema `Z1` below —
the same formula with BL's *derived* `F` — and `z1_translate` proves
`⊢[Discrete] tr (Z1 φ)` outright, in two lines: the axiom, plus the standing `F`-bridge. That is
the TM⁺_f half.

The other half — `TM_f ⊢ Z1 φ` fails, because `TM_f = TM + DF` is sound over *every* discrete
frame while `Z1` is unsound over non-Archimedean discrete orders — is now **also** a theorem:
`Metalogic/Conservativity/Z1Countermodel.lean`'s `not_bl_derivable_z1`, via `bl_soundness_discrete_succ`
(`Metalogic/Conservativity/BaseLanguageSoundness.lean`, the binder-weakened discrete BL soundness theorem
dropping the Archimedean instances) applied to a countermodel over `ℚ ×_lex ℤ`
(`Semantics/LexCarrier.lean`), **not** `ℤ ×_lex ℤ` as an earlier draft of this section and the
research report both suggested — `ℚ ×_lex ℤ` is the carrier `BXCanonical/DiscreteCarrierProbe.lean`
already probes for the `FrameClass.Base` layer, so the two modules read as one story rather than
introducing a second non-Archimedean carrier. **CEF is therefore refuted with both halves
machine-checked**, not merely documented.

**One correction to the research report.** The report asserted `z1 φ = tr (Z1 φ')` as a
syntactic identity. It is not, and cannot be: `Formula.someFuture` is a top-level `untl`, and
by `BaseLanguage.tr_ne_untl` nothing in the range of `tr` is a top-level `untl`. The bridge
`BaseLanguage.notGNot_imp_F` closes the gap derivably instead — see `z1_translate`.

## CEB / `FrameClass.Base` — refuted in the source; TM⁺ half machine-checked, TM half not machine-checkable here

The source's witness is `(Sp) := □φ_DF ∨ □ψ_DN`. Its TM⁺ derivation uses TMP-NB (`X⊤ → □X⊤`)
and M5, and **both are available at `FrameClass.Base` in this repository**:
`ProofSystem.Axiom.discrete_box_necessity` is TMP-NB and
`ProofSystem.Axiom.modal_5_collapse` is M5, and neither is named in
`ProofSystem.Axiom.minFrameClass`'s non-`Base` list, so both fall through its catch-all to
`.Base`. The source's `(Sp)` derivation is thus available verbatim in `⊢[FrameClass.Base]`,
given the repository's own `completeness_*` results for the two BL⁺-valid conditionals — but
this repository does not reconstruct that TMP-NB/M5 derivation; instead `Metalogic/Conservativity/SpWitness.lean`
reaches the same TM⁺ half by a different, and independently informative, route: `(Sp)` (its own
reconstruction of the witness, since the source formula's own `\label` was deleted from the
paper — see Provenance below) is BL-**valid** on every task frame for a purely order-theoretic
reason (`SpWitness.blValid_sp`, from `Semantics/DurationClassification.lean`'s
`duration_dense_or_least_pos` dichotomy), and composing with `BXCanonical.completeness` yields
`⊢[Base] tr (Sp φ ψ)` (`SpWitness.sp_translate`) with **no appeal to TMP-NB or M5 at all**.

Unlike CEF, the failing half — no instance of `(Sp)` is a TM-theorem, by soundness on a
disjoint two-fibre structure (a `ℤ`-fibre and an `ℝ`-fibre with `□` read globally over both) —
is **not** merely unbuilt but **unavailable in principle** with the tree's current semantics
layer: `BLTruthAt`/`bl_soundness` are `TaskFrame`-bound, and `Metalogic/Conservativity/SpWitness.lean`'s own
un-boxed sharpening (report §4.2) shows why a `TaskFrame`-level argument cannot reach the
two-fibre case — `(Sp)`'s un-boxed dichotomy is valid on *every* strict linear order, so what a
CEB countermodel needs is a structure where `□` sees *different* histories with
differently-shaped time, which no single `TaskFrame` (one shared `Duration`) can express. Closing
CEB needs a frame notion outside `TaskFrame` plus a *native* (non-composed) BL soundness theorem
over it — proposed as a follow-up task, not attempted here (see Phase 8's completion note).

## The Kripke-level answer to "what is TM complete for" (report §5(i)) — principled, unformalized

Independently of the CEB/CEF/CED/CEC row analysis above, there is a standard modal-logic answer
to what TM's Kripke frame class actually is: **S5 ⊗ Kt4.3 + MF**, complete by Sahlqvist
canonicity. This is textbook material (the axioms MK/MT/M5/MF/TK/T4/TB/TA/TL are each Sahlqvist,
and Sahlqvist's theorem gives canonicity, hence completeness, for their join), not a repository
result: formalizing the Sahlqvist-canonicity argument itself is a large separate development
(explicitly a Non-Goal of this plan) and is recorded here only as the principled answer's
provenance, never as something this tree has machine-checked.

## Two live-paper facts bearing on the discrete rows

- **`def:TMplus-f`** (paper `\S sub:Extension`, live text) pins TM⁺_f's Hölder-classified
  completeness class to `ℤ`-time precisely: "It follows by Hölder's theorem that a nontrivial
  discrete Archimedean totally ordered abelian group is isomorphic to `ℤ`, and so the
  successor-Archimedean discrete class to which `BX`_f and `TM⁺`_f are sound and complete is
  exactly `ℤ`-time." This is what makes `Z1Countermodel.tmCompleteDiscrete_refuted` read as the
  `TM_f`-vs-`TM⁺_f` completeness *gap*, rather than a weaker claim about some other class.
- **A commented (non-live) line**, `possible_worlds.tex:4614` immediately below `def:TMplus-f`,
  gives the author's own position in the author's own words: "`TM`_f, by contrast, is sound
  over the full class of discrete frames, since **DF** is valid on every discrete order and not
  only on `ℤ`-time; whether `TM`_f is complete over that broader class remains open, as
  discussed at `cor:tm-completeness`." Cited as the author's stated position, flagged
  explicitly as **commented out** and therefore not live text — the open verdict it records
  matches this module's own CEF finding (`Z1Countermodel.tmCompleteDiscrete_refuted`) that
  `TM_f` is not weakly complete over the *broader* (non-Archimedean) discrete class, only over
  `ℤ`-time.

## CED / CEC — open

No counterexample analogous to the CEB and CEF witnesses is known for CED. CEC inherits that
openness, plus an independent doubt: whether TMP-CO alone axiomatizes the same BL⁺-logic as
the full Reynolds triple is itself open, and the converse direction (CO deriving the Reynolds
gap axioms) is separately **refuted** in
`FormalSystem.Metalogic.Independence.CoNotPriorU`. "Open" here means open in the source, not
merely unattempted here.

## What a machine-checked refutation would need — now row-dependent, not a single narrowing

A BL-side semantics and a BL-side soundness theorem now exist tree-wide
(`FormalSystem/Semantics/BLTruth.lean`'s `BLTruthAt`, and
`FormalSystem/Metalogic/Conservativity/BaseLanguageSoundness.lean`'s `bl_soundness` family), but what each row
still needs beyond that differs, and reading it as one shared "countermodels alone" gap is no
longer accurate for either row:

- **CEF (`FrameClass.Discrete`) — done, both halves machine-checked.** The missing prerequisite
  was a *binder-weakened* BL soundness theorem — `bl_soundness_discrete_succ`
  (`Metalogic/Conservativity/BaseLanguageSoundness.lean`), dropping `IsSuccArchimedean`/`IsPredArchimedean` so
  it applies to a non-Archimedean carrier — plus the countermodel itself, assembled over
  `multiFamTaskFrameGen` at the non-Archimedean discrete carrier `ℚ ×_lex ℤ`
  (`Semantics/LexCarrier.lean`, `Metalogic/Conservativity/Z1Countermodel.lean`). **Both are now landed**: `z1_translate`
  below is the TM⁺_f half, and `Z1Countermodel.not_bl_derivable_z1` is the TM_f half — the
  refutation is machine-checked, not merely documented.
- **CEB (`FrameClass.Base`) — still not machine-checkable in this tree, and not close.** The
  missing prerequisite is a **frame notion outside `TaskFrame`** plus a **native** (non-composed)
  BL soundness theorem over it. `BLTruthAt`/`bl_soundness` are `TaskFrame`-bound and cannot
  supply this: `(Sp) := □(DF φ) ∨ □(DN ψ)` — the reconstructed witness, `Metalogic/Conservativity/SpWitness.lean`'s
  `blValid_sp`/`sp_translate` — is BL-valid on *every* task frame (a theorem now, not a
  conjecture), and TM⁺ is *unsound* on the two-fibre class the source's refutation needs, so the
  `translate`-then-`soundness` composition this module supplies is unavailable **in principle**,
  not merely unbuilt. See `Metalogic/Conservativity/SpWitness.lean`'s module docstring for the un-boxed
  sharpening (report §4.2) that makes this precise: `□` is what turns the dichotomy into a
  frame-uniform fact, and a CEB refutation needs a structure where different histories see
  differently-shaped time.

The **forward direction remains refuted** at both rows and must still not be stated or
`sorry`-ed here — nothing about the CEF closure changes that; it closes CEF's specific
row-refutation with a machine-checked witness, while leaving the general prohibition (this
module's own `forward` schema, for every frame class) exactly as forbidden as before. See also
`Metalogic/Conservativity/TMCompletenessReduction.lean`, whose `tmCompleteBase_iff_forwardBase` /
`tmCompleteDiscrete_iff_forwardDiscrete` pin "TM (resp. TM_f) complete over task frames" as the
*same proposition* as this module's forward-conservativity prohibition, at `.Base` and
`.Discrete` respectively — so a future dispatch attempting TM-completeness directly is thereby
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
module leans on, cite `specs/paper-definitions-of-record.md` rather than the paper directly;
`bash scripts/check-paper-definitions.sh` was run at implementation time and reports the same
two drifted and six dangling anchors the research report recorded, none of them consumed here.

## No semantics

Nothing here — nor anything under `FormalSystem/BaseLanguage/`, transitively — imports
`FormalSystem.Semantics`. `translate` is a function between two `DerivationTree` types and
touches no truth definition, frame, or validity predicate, so the bridge composes unchanged
with whatever the totality-based validity definition becomes. The intended composition is

```
BL-validity over C  ⟸[bl_soundness…]  ⊢ᴮᴸ[fc] φ  ⟶[translate]  ⊢[fc] tr φ
                                                          ⟸[completeness_*]  BL⁺-validity over C
```

and this module is the middle arrow only. The left arrow is now built, in
`FormalSystem/Metalogic/Conservativity/BaseLanguageSoundness.lean`, which is where the `FormalSystem.Semantics`
import lives; it composes `translate` with `Metalogic/Soundness.lean`'s four theorems across the
truth-transfer bridge `truthAt_tr`. This module and everything under
`FormalSystem/BaseLanguage/` remain semantics-free.
-/

/-!
## What this module is

**This file is the aggregator, and it holds no declarations.** It carries the narrative above —
the forward-conservativity prohibition, the paper-anchor record, and the per-row status of CEB
and CEF — and re-exports the five modules that make up the BL-vs-TM story:

| Module | Contents |
|--------|----------|
| `Conservativity/Backward.lean` | `translate`, `derivable_translate`, the four `*_backward` rows, `Z1`, `z1_translate` |
| `Conservativity/BaseLanguageSoundness.lean` | the `bl_soundness` family and the `truthAt_tr` transfer bridge |
| `Conservativity/TMCompletenessReduction.lean` | `TMComplete` / `Forward` and their equivalence |
| `Conservativity/SpWitness.lean` | the reconstructed `(Sp)` witness for the CEB row |
| `Conservativity/Z1Countermodel.lean` | `not_bl_derivable_z1` and `tmCompleteDiscrete_refuted` |

**The children must never import this file.** Each imports
`FormalSystem.Metalogic.Conservativity.Backward` directly; importing the aggregator from a child
is an import cycle, because the aggregator imports every child. The chain the children preserve
is `Backward ← BaseLanguageSoundness ← TMCompletenessReduction ← Z1Countermodel`, with
`SpWitness` hanging off `BaseLanguageSoundness`.

The namespace is unchanged by the reorganization: `Backward.lean` still opens
`namespace FormalSystem.Metalogic.Conservativity`, so every declaration keeps its
fully-qualified name and no call site outside these files moved.
-/
