/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.MinusExt
import FormalSystem.Metalogic.Conservativity.SpWitness
import FormalSystem.Metalogic.Conservativity.SpCountermodel
import FormalSystem.Metalogic.Conservativity.ChainBundleTruth
import FormalSystem.Metalogic.Conservativity.DenseObstructionTransfer

/-!
# Native axiomatization of the H/G-fragment — the canonical verdict record

**Read `Metalogic/Conservativity.lean`'s module docstring first.** Nothing here states,
approaches, or `sorry`s forward conservativity (`Forward fc`) or TM⁻-completeness
(`TMMinusComplete fc`), and **nothing here concludes `ChainComplete fc Ax`** for any `fc`, `Ax`.
That proposition is the single explicit hypothesis of every completeness-shaped theorem below.
It is concluded at exactly one class, `.Dense` with `Ax = ∅`, by
`Conservativity/MinusChainCompleteness.lean`'s `chainComplete_dense` (a machine-checked L⁻
canonical model); at the other three classes it is supplied by the classical literature on paper,
never by a Lean declaration.

## The question

`TMFrag fc φ := TM ⊢[fc] tr φ` (`Conservativity/Fragment.lean`) is, by `tmFrag_iff_minusValidIn`,
exactly the set of L⁻ (H/G/□) formulas valid over the frames of `fc`. TM⁻ is a *proper* subset
of it at `.Base` (`not_derivable_sp`) and at `.ZTime` (`not_minus_derivable_z1`). Is the gap
finitely axiomatizable **natively**, in L⁻, without going through TM's since/until?

## The verdict, per class

The table pins the candidate schema set Σ_fc and separates, cell by cell, what this module
**machine-checks** from what is **literature-backed and not machine-checked**.

| Class    | `TMFrag fc` = | Σ_fc                       | Verdict                       |
|----------|---------------|----------------------------|-------------------------------|
| `.Base`  | TM⁻ + (Sp)    | `sigmaBase` = all `Sp φ ψ` | finitely axiomatizable (one schema) |
| `.Dense` | TM⁻_d         | ∅                          | finitely axiomatizable (TM⁻_d itself) |
| `.ZTime` | TM⁻_z + Z1    | `sigmaZTime` = all `Z1 φ`  | finitely axiomatizable (one schema) |
| `.RTime` | TM⁻_r         | ∅                          | finitely axiomatizable (TM⁻_r itself) |

Per class, the three cells behind each verdict:

* **`.Base`** — soundness `TM⁻ + (Sp) ⊆ TMFrag .Base`: machine-checked,
  `minusExt_sigmaBase_le_tmFrag`. Strictness `TM⁻ ⊊ TM⁻ + (Sp)`: machine-checked,
  `tmMinus_lt_minusExt_sigmaBase`. Completeness `TMFrag .Base ⊆ TM⁻ + (Sp)`: **not
  machine-checked** — Burgess 1984 §2.5 for the dense side, §2.6 plus the collapse of discrete
  orders onto ℚ ×ₗ ℤ for the discrete side, and the boxed-disjunction intersection lemma;
  conditional form `minusExt_sigmaBase_iff_tmFrag_of_chainComplete`.
* **`.Dense`** — soundness `TM⁻_d ⊆ TMFrag .Dense`: machine-checked,
  `minusExt_empty_le_tmFrag_dense`. No strictness claim (Σ = ∅). Completeness
  `TMFrag .Dense ⊆ TM⁻_d`: **machine-checked** — `chainComplete_dense` in
  `Conservativity/MinusChainCompleteness.lean` (Burgess 1984 §2.5, the tense logic of ℚ, as a
  step-by-step ℚ-chronicle construction), discharging the hypothesis of the conditional form
  `minusExt_empty_iff_tmFrag_dense_of_chainComplete` to give `minusExt_iff_tmFrag_dense`.
* **`.ZTime`** — soundness `TM⁻_z + Z1 ⊆ TMFrag .ZTime`: machine-checked,
  `minusExt_sigmaZTime_le_tmFrag`. Strictness `TM⁻_z ⊊ TM⁻_z + Z1`: machine-checked,
  `tmMinus_lt_minusExt_sigmaZTime`. Completeness `TMFrag .ZTime ⊆ TM⁻_z + Z1`: **not
  machine-checked** — Venema 2001 Thm 3.3, a survey citation whose primary sources (Segerberg
  1970, Goldblatt) are not in the corpus; conditional form
  `minusExt_sigmaZTime_iff_tmFrag_of_chainComplete`.
* **`.RTime`** — soundness `TM⁻_r ⊆ TMFrag .RTime`: machine-checked,
  `minusExt_empty_le_tmFrag_rtime`. No strictness claim (Σ = ∅). Completeness
  `TMFrag .RTime ⊆ TM⁻_r`: **not machine-checked** — Burgess 1984 §2.7, the tense logic of ℝ,
  with CO subsuming Burgess's A7 on paper; conditional form
  `minusExt_empty_iff_tmFrag_rtime_of_chainComplete`.

`(Sp) := □(DF φ) ∨ □(DN ψ)` (`Conservativity/SpWitness.lean`) is the (DD) split schema; `Z1` is
`G(Gφ → φ) → (F(Gφ) → Gφ)` (`Conservativity/Backward.lean`). `.Dense` and `.RTime` need no
schema: `Sp φ ψ` is already a TM⁻_d / TM⁻_r theorem there (`spDerivableDense`,
`spDerivableRTime`; see the two `example`s at the end of the soundness section), and the
classical results say nothing further is missing.

## The bridge: `□` is the universal modality

Every completeness cell above is a claim about H/G-with-`□` validity on task frames, whereas
the classical theorems axiomatize pure H/G validity on a single linear order. What connects
them is that on a task model MF + TR + S5 make `□` **universal** — globally constant across
every history and every time (`Conservativity/ChainBundleTruth.lean`'s `chainSat` box clause,
and the four `□`-globality derivations `boxGlobalFuture`, `boxGlobalPast`,
`notBoxGlobalFuture`, `notBoxGlobalPast` in `Conservativity/MinusDeduction.lean`). So the
completeness question for `TM⁻ + Σ_fc` over task frames reduces to completeness of its tense
part over `D`-chain bundles, which is what `ChainComplete fc Ax` names, and which the classical
theorems settle on paper. **`ChainComplete` is never asserted here**; it is asserted at `.Dense`
only, in `MinusChainCompleteness.lean`.

## What is machine-checked here

* `sigmaBase`, `sigmaZTime` — the two non-empty schema-instance sets.
* `sigmaBase_le_tmFrag`, `sigmaZTime_le_tmFrag` — each instance is in the fragment
  (`sp_translate`, `z1_translate`).
* The four soundness rows `minusExt_*_le_tmFrag`, through `minusExt_le_tmFrag`.
* The two strictness rows `tmMinus_lt_minusExt_*`, over the landed countermodels.
* `ChainValidIn`, `ChainComplete`, `tmFrag_chainValidIn`, and the conditional completeness
  theorem `minusExt_iff_tmFrag_of_chainComplete` with its four per-class corollaries — the
  completeness half with its hypothesis explicit.

## Paper note

The JPL paper's source (`possible_worlds.tex`, `sub:Logic`) carries a commented-out footnote after
"TM⁻ owes its strength to since and until" asserting that the Past/Future language admits **no**
complete finite axiomatization of this fragment. That negative claim is **not supportable** and
should not be un-commented as drafted: on the classical results above, every one of the four
fragments is finitely axiomatizable over TM⁻ in L⁻. The footnote should instead say that TM⁻ is
incomplete at `.Base` and `.ZTime` (machine-checked here: `tmMinusCompleteBase_refuted`,
`tmMinusCompleteZTime_refuted`), and that TM⁻ + (DD) and TM⁻_z + Z1 are complete for all task
frames and for ℤ-time respectively, while TM⁻_d and TM⁻_r are already complete — by the classical
H/G completeness results (Burgess 1984 §§2.5–2.7, Venema 2001 Thm 3.3) and the universal-modality
reduction, with the soundness halves machine-checked in this module and the completeness halves
literature-backed. Since the fragment is r.e. through TM in any case, only the *finite*
axiomatizability claim carries content, and it is positive.

## References

* `FormalSystem/Metalogic/Conservativity/MinusExt.lean` — `MinusExt`, `minusExt_le_tmFrag`
* `FormalSystem/Metalogic/Conservativity/Fragment.lean` — `TMFrag`, `tmFrag_sound`
* `FormalSystem/Metalogic/Conservativity/SpWitness.lean`, `SpCountermodel.lean` — `Sp`,
  `sp_translate`, `not_derivable_sp`
* `FormalSystem/Metalogic/Conservativity/Backward.lean`, `Z1Countermodel.lean` — `Z1`,
  `z1_translate`, `not_minus_derivable_z1`
* `FormalSystem/Metalogic/Conservativity/ChainBundleTruth.lean` — `chainSat`,
  `not_minusValidIn_of_not_chainSat`
* `FormalSystem/Metalogic/Conservativity/DenseObstructionTransfer.lean` — `spDerivableDense`,
  `spDerivableRTime`
* Burgess, *Basic Tense Logic* (1984), §§2.5–2.7; Venema, *Temporal Logic* (2001), Thm 3.3

## Tags

conservativity · fragment · base-language · axiomatization · conditional-completeness
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic
open FormalSystem.Metalogic.Algebraic

/-! ## Σ_fc — the candidate schema sets

`.Dense` and `.RTime` carry `∅` and need no named set. -/

/-- **Σ_Base**: every instance of the (Sp)/(DD) schema, `□(DF φ) ∨ □(DN ψ)`. Membership of
`Sp φ ψ` is `⟨φ, ψ, rfl⟩`. -/
def sigmaBase : Set MinusFormula := {χ | ∃ φ ψ, χ = Sp φ ψ}

/-- **Σ_ZTime**: every instance of the Z1 schema, `G(Gφ → φ) → (F(Gφ) → Gφ)`. Membership of
`Z1 φ` is `⟨φ, rfl⟩`. -/
def sigmaZTime : Set MinusFormula := {χ | ∃ φ, χ = Z1 φ}

/-- Every (Sp) instance is in the fragment at `.Base`: this is `sp_translate`. -/
theorem sigmaBase_le_tmFrag : ∀ ψ ∈ sigmaBase, TMFrag FrameClass.Base ψ := by
  rintro _ ⟨φ, ψ, rfl⟩
  exact sp_translate φ ψ

/-- Every Z1 instance is in the fragment at `.ZTime`: this is `z1_translate`. -/
theorem sigmaZTime_le_tmFrag : ∀ ψ ∈ sigmaZTime, TMFrag FrameClass.ZTime ψ := by
  rintro _ ⟨φ, rfl⟩
  exact z1_translate φ

/-! ## The four soundness rows: `TM⁻ + Σ_fc ⊆ TMFrag fc`

Each is `minusExt_le_tmFrag` at the row's schema set. -/

/-- **Soundness at `.Base`**: `TM⁻ + (Sp) ⊆ TMFrag .Base`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem minusExt_sigmaBase_le_tmFrag {φ : MinusFormula}
    (h : MinusExt FrameClass.Base sigmaBase φ) : TMFrag FrameClass.Base φ :=
  minusExt_le_tmFrag sigmaBase_le_tmFrag h

/-- **Soundness at `.ZTime`**: `TM⁻_z + Z1 ⊆ TMFrag .ZTime`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem minusExt_sigmaZTime_le_tmFrag {φ : MinusFormula}
    (h : MinusExt FrameClass.ZTime sigmaZTime φ) : TMFrag FrameClass.ZTime φ :=
  minusExt_le_tmFrag sigmaZTime_le_tmFrag h

/-- **Soundness at `.Dense`**: `TM⁻_d ⊆ TMFrag .Dense`, with the empty schema set. The
hypothesis of `minusExt_le_tmFrag` is vacuous. -/
theorem minusExt_empty_le_tmFrag_dense {φ : MinusFormula}
    (h : MinusExt FrameClass.Dense ∅ φ) : TMFrag FrameClass.Dense φ :=
  minusExt_le_tmFrag (fun _ hψ => absurd hψ (Set.notMem_empty _)) h

/-- **Soundness at `.RTime`**: `TM⁻_r ⊆ TMFrag .RTime`, with the empty schema set. -/
theorem minusExt_empty_le_tmFrag_rtime {φ : MinusFormula}
    (h : MinusExt FrameClass.RTime ∅ φ) : TMFrag FrameClass.RTime φ :=
  minusExt_le_tmFrag (fun _ hψ => absurd hψ (Set.notMem_empty _)) h

/-! ## Strictness over TM⁻: `TM⁻ ⊊ TM⁻ + Σ_fc` at `.Base` and `.ZTime`

The witnesses are the landed countermodel formulas: `Sp p p` is in `TM⁻ + (Sp)` by the `ax`
constructor and not TM⁻-derivable by `not_derivable_sp` (soundness over the two-fibre
`MinusFrame` `ℤ ⊕ ℝ`); `Z1 p` is in `TM⁻_z + Z1` by `ax` and not TM⁻_z-derivable by
`not_minus_derivable_z1` (soundness over `ℚ ×ₗ ℤ`). -/

/-- **`TM⁻ ⊊ TM⁻ + (Sp)`.** The schema set genuinely extends TM⁻ at `.Base`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem tmMinus_lt_minusExt_sigmaBase :
    ∃ φ : MinusFormula, MinusExt FrameClass.Base sigmaBase φ ∧
      ¬ MinusLanguage.Derivable FrameClass.Base [] φ :=
  ⟨Sp (.atom (Atom.mkBase "p")) (.atom (Atom.mkBase "p")),
    MinusExt.ax ⟨_, _, rfl⟩, not_derivable_sp _⟩

/-- **`TM⁻_z ⊊ TM⁻_z + Z1`.** The schema set genuinely extends TM⁻_z at `.ZTime`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem tmMinus_lt_minusExt_sigmaZTime :
    ∃ φ : MinusFormula, MinusExt FrameClass.ZTime sigmaZTime φ ∧
      ¬ MinusLanguage.Derivable FrameClass.ZTime [] φ :=
  ⟨Z1 (.atom (Atom.mkBase "p")), MinusExt.ax ⟨_, rfl⟩, not_minus_derivable_z1 _⟩

/-! ### Why Σ_Dense and Σ_RTime carry no (Sp)

At `.Dense` and `.RTime`, `Sp φ ψ` is already a TM⁻ theorem (its right disjunct `□(DN ψ)` is
`DN` necessitated), so adding it as a schema would change nothing. The two `example`s record
this: `MinusExt .Dense ∅ (Sp φ ψ)` and `MinusExt .RTime ∅ (Sp φ ψ)` hold through `tm` alone. -/

example (φ ψ : MinusFormula) : MinusExt FrameClass.Dense ∅ (Sp φ ψ) :=
  MinusExt.tm ⟨spDerivableDense φ ψ⟩

example (φ ψ : MinusFormula) : MinusExt FrameClass.RTime ∅ (Sp φ ψ) :=
  MinusExt.tm ⟨spDerivableRTime φ ψ⟩

/-! ## Conditional completeness via chain bundles

The completeness half, `TMFrag fc ⊆ TM⁻ + Σ_fc`, with its hypothesis **explicit, and discharged
in this tree at `.Dense` only** (`MinusChainCompleteness.lean`). The hypothesis is
`ChainComplete fc Ax`: completeness of `MinusExt fc Ax` for the
chain-bundle semantics `chainSat` of `Conservativity/ChainBundleTruth.lean`, over every flow frame
in `fc`. That is exactly where the classical H/G completeness theorems (Burgess 1984 §2.5–2.7,
Venema 2001 Thm 3.3) plus the universal-modality reduction do their work on paper; the report's
Lemma U (normal form under global `□`) and Lemma I (intersection by boxed disjunction) are folded
into it and are not formalized. -/

/--
**Chain-bundle validity at `fc`.** `φ` holds at every point of every disjoint union of
`D`-chains whose flow frame `multiFamTaskFrameGen D FamIdx` lies in `fc`, under every valuation,
with `□` universal (the `chainSat` box clause quantifies over all points of all chains).

Binder shapes copied from `not_minusValidIn_of_not_chainSat`.
-/
def ChainValidIn (fc : FrameClass) (φ : MinusFormula) : Prop :=
  ∀ (D : TemporalOrder) (FamIdx : Type) [Nonempty FamIdx],
    fc.Sat (multiFamTaskFrameGen D FamIdx) →
      ∀ (v : FamIdx × (D : Type) → Atom → Prop) (q : FamIdx × (D : Type)), chainSat v q φ

/--
**Fragment theorems are chain-bundle valid.** `tmFrag_sound` gives `MinusValidIn fc φ`; at each
chain bundle in `fc`, a point refuting `φ` would refute `MinusValidIn fc φ` by
`not_minusValidIn_of_not_chainSat`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem tmFrag_chainValidIn {fc : FrameClass} {φ : MinusFormula} (h : TMFrag fc φ) :
    ChainValidIn fc φ := by
  intro D FamIdx _ hSat v q
  by_contra hn
  exact not_minusValidIn_of_not_chainSat hSat v q φ hn (tmFrag_sound φ h)

/--
**"`TM⁻ + Ax` is complete for chain bundles in `fc`."** Every chain-bundle-valid formula at `fc`
is in `MinusExt fc Ax`.

This is the proposition the classical theorems — Burgess 1984 §2.5 (ℚ), §2.6 (discrete orders),
§2.7 (ℝ); Venema 2001 Thm 3.3 (ℤ) — together with the universal-modality reduction (MF + TR + S5
make `□` universal on a task model) establish **on paper** for `(fc, Σ_fc)` at each of the four
classes. **Exactly one declaration in this tree concludes it**: `chainComplete_dense`
(`Conservativity/MinusChainCompleteness.lean`), at `fc := .Dense`, `Ax := ∅`, by a machine-checked
ℚ-chronicle canonical model. At the other three classes no declaration concludes it, and none may
be added with `sorry`: below it appears only as an explicit hypothesis, so that the theorems here
say exactly "given chain-completeness, the fragment is `TM⁻ + Ax`" and nothing more.
-/
def ChainComplete (fc : FrameClass) (Ax : Set MinusFormula) : Prop :=
  ∀ φ : MinusFormula, ChainValidIn fc φ → MinusExt fc Ax φ

/--
**Conditional completeness.** Given chain-completeness of `TM⁻ + Ax` at `fc` and `Ax ⊆ TMFrag fc`,
the extension *is* the fragment: forward is `minusExt_le_tmFrag`, backward is the hypothesis
applied to `tmFrag_chainValidIn`.

Paper: — (formalization-native; the H/G-fragment is this tree's construction)
-/
theorem minusExt_iff_tmFrag_of_chainComplete {fc : FrameClass} {Ax : Set MinusFormula}
    (hcc : ChainComplete fc Ax) (hAx : ∀ ψ ∈ Ax, TMFrag fc ψ) (φ : MinusFormula) :
    MinusExt fc Ax φ ↔ TMFrag fc φ :=
  ⟨minusExt_le_tmFrag hAx, fun h => hcc φ (tmFrag_chainValidIn h)⟩

/-! ### The four per-class corollaries, hypothesis still explicit -/

/-- `.Base`: given chain-completeness of `TM⁻ + (Sp)`, `TM⁻ + (Sp) = TMFrag .Base`. -/
theorem minusExt_sigmaBase_iff_tmFrag_of_chainComplete
    (h : ChainComplete FrameClass.Base sigmaBase) (φ : MinusFormula) :
    MinusExt FrameClass.Base sigmaBase φ ↔ TMFrag FrameClass.Base φ :=
  minusExt_iff_tmFrag_of_chainComplete h sigmaBase_le_tmFrag φ

/-- `.ZTime`: given chain-completeness of `TM⁻_z + Z1`, `TM⁻_z + Z1 = TMFrag .ZTime`. -/
theorem minusExt_sigmaZTime_iff_tmFrag_of_chainComplete
    (h : ChainComplete FrameClass.ZTime sigmaZTime) (φ : MinusFormula) :
    MinusExt FrameClass.ZTime sigmaZTime φ ↔ TMFrag FrameClass.ZTime φ :=
  minusExt_iff_tmFrag_of_chainComplete h sigmaZTime_le_tmFrag φ

/-- `.Dense`: given chain-completeness of `TM⁻_d`, `TM⁻_d = TMFrag .Dense`.

Composed with `minusExt_empty_iff`, this reads "TM⁻_d is complete for `MinusValidIn .Dense`
given chain-completeness" — the `.Dense` row of `TMCompletenessReduction.lean`'s
`TMMinusComplete`, conditionally. Both propositions are now asserted unconditionally in
`Conservativity/MinusChainCompleteness.lean`: `chainComplete_dense` discharges the hypothesis,
giving `minusExt_iff_tmFrag_dense`, and `tmMinusComplete_dense` closes the `TMMinusComplete`
row. -/
theorem minusExt_empty_iff_tmFrag_dense_of_chainComplete
    (h : ChainComplete FrameClass.Dense ∅) (φ : MinusFormula) :
    MinusExt FrameClass.Dense ∅ φ ↔ TMFrag FrameClass.Dense φ :=
  minusExt_iff_tmFrag_of_chainComplete h (fun _ hψ => absurd hψ (Set.notMem_empty _)) φ

/-- `.RTime`: given chain-completeness of `TM⁻_r`, `TM⁻_r = TMFrag .RTime`.

The same reading as the `.Dense` corollary, for `TMMinusComplete .RTime`; neither side is
asserted. -/
theorem minusExt_empty_iff_tmFrag_rtime_of_chainComplete
    (h : ChainComplete FrameClass.RTime ∅) (φ : MinusFormula) :
    MinusExt FrameClass.RTime ∅ φ ↔ TMFrag FrameClass.RTime φ :=
  minusExt_iff_tmFrag_of_chainComplete h (fun _ hψ => absurd hψ (Set.notMem_empty _)) φ

/-! ### Acceptance checks -/

/-- The contrapositive shape a future refutation probe would consume: a formula outside
`TM⁻ + Ax` is, given chain-completeness, refuted on some chain bundle in `fc`. -/
example {fc : FrameClass} {Ax : Set MinusFormula} {φ : MinusFormula}
    (hn : ¬ MinusExt fc Ax φ) (hcc : ChainComplete fc Ax) : ¬ ChainValidIn fc φ :=
  fun hv => hn (hcc φ hv)

/-- The `.Dense` corollary composed with `minusExt_empty_iff`: TM⁻_d-theoremhood is fragment
membership, given chain-completeness. -/
example (h : ChainComplete FrameClass.Dense ∅) (φ : MinusFormula) :
    MinusLanguage.Derivable FrameClass.Dense [] φ ↔ TMFrag FrameClass.Dense φ :=
  minusExt_empty_iff.symm.trans (minusExt_empty_iff_tmFrag_dense_of_chainComplete h φ)

end FormalSystem.Metalogic.Conservativity
