/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.MinusLanguage

/-!
# The backward TM⁻/TM conservativity bridge

**Read `Metalogic/Conservativity.lean`'s module docstring first.** That aggregator carries the
whole narrative this file's declarations sit inside — in particular the
**forward-conservativity prohibition**, which states that

```
theorem forward {fc} {φ} : ProofSystem.Derivable fc [] (tr φ) → MinusLanguage.Derivable fc [] φ
```

is refuted at `fc := .Base` and `fc := .ZTime`, and that a `sorry`-ed proof of it would be an
unsound placeholder rather than deferred debt. Nothing in this file states or approaches
`forward`.

What this file holds is the **backward** direction, which is unproblematic and proved: the
translation `translate` from L⁻ derivations to L derivations, its `Derivable`-level corollary
`derivable_translate`, the four per-class rows `ceb_backward` / `cef_backward` / `ced_backward` /
`cec_backward`, and the CEF forward-direction *witness* `Z1` / `z1_translate` — the half of the
CEF refutation that succeeds. The half that fails is `Z1Countermodel.not_minus_derivable_z1`, in a
sibling module.

## No semantics

Nothing here — nor anything under `FormalSystem/MinusLanguage/`, transitively — imports
`FormalSystem.Semantics`. `translate` is a function between two `DerivationTree` types and
touches no truth definition, frame, or validity predicate. The semantics-facing half of the
story lives in the sibling `Conservativity/MinusLanguageSoundness.lean`, which is where the
`FormalSystem.Semantics` import enters.

## Tags

conservativity · base-language · translation · CEB · CEF · CED · CEC
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage

/--
**The backward conservativity bridge.**

Every TM⁻ derivation over the base language L⁻ becomes a TM derivation of its translation, at
the same frame class and over the translated context.

Seven cases, one per L⁻ rule:

- `axiom` — `MinusLanguage.dischargeAxiom`, the lookup table of
  `MinusLanguage/AxiomDischarge.lean`, weakened from the empty context.
- `assumption` — membership transported through `tr` by `MinusLanguage.mem_trCtx`.
- `modus_ponens`, `weakening` — structural.
- `necessitation`, `temporal_necessitation` — structural; both rules are empty-context on both
  sides and `trCtx [] = []` definitionally.
- `temporal_duality` — the load-bearing case. TM⁻'s **TD** concludes `⊢ swapMinus φ` while L's
  rule concludes `⊢ swapTemporal (tr φ)`; `MinusLanguage.tr_swapMinus` is exactly the equation that
  makes those the same formula, and without it this case does not typecheck.
-/
noncomputable def translate {fc : FrameClass} {Γ : MinusLanguage.Context} {φ : MinusFormula} :
    MinusLanguage.DerivationTree fc Γ φ → ProofSystem.DerivationTree fc (trCtx Γ) (tr φ)
  | .axiom Γ _ h h_fc =>
      ProofSystem.DerivationTree.weakening [] (trCtx Γ) _
        (MinusLanguage.dischargeAxiom h h_fc) (List.nil_subset _)
  | .assumption _ _ h => .assumption _ _ (MinusLanguage.mem_trCtx h)
  | .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (tr φ) (tr ψ) (translate d1) (translate d2)
  | .necessitation φ d => .necessitation (tr φ) (translate d)
  | .temporal_necessitation φ d => .temporal_necessitation (tr φ) (translate d)
  | .temporal_duality φ d =>
      (MinusLanguage.tr_swapMinus φ).symm ▸
        ProofSystem.DerivationTree.temporal_duality (tr φ) (translate d)
  | .weakening _ _ _ d h =>
      .weakening _ _ _ (translate d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/--
The `Prop`-level backward bridge: TM⁻-derivability implies TM-derivability of the translation,
at the same frame class.

Paper: — (formalization-native; the paper states no TM⁻/TM⁻-plus proof-theoretic bridge)
-/
theorem derivable_translate {fc : FrameClass} {Γ : MinusLanguage.Context} {φ : MinusFormula}
    (h : MinusLanguage.Derivable fc Γ φ) :
    ProofSystem.Derivable fc (trCtx Γ) (tr φ) :=
  h.elim fun d => ⟨translate d⟩

/-! ## The four paper rows

Each row is `translate` at one frame class and the empty context — the paper's rows are
theoremhood claims, not consequence claims. `trCtx [] = []` definitionally, so no context
bookkeeping appears in the statements. -/

/--
**CEB**: `TM⁻ ⊢ φ ⟹ TM ⊢ tr φ`, at `FrameClass.Base`.

The base row: no extension axiom is available on either side.

Paper: — (formalization-native; the paper states no TM⁻/TM⁻-plus proof-theoretic bridge)
-/
theorem ceb_backward {φ : MinusFormula}
    (h : MinusLanguage.Derivable FrameClass.Base [] φ) :
    ProofSystem.Derivable FrameClass.Base [] (tr φ) :=
  derivable_translate h

/--
**CEF**: `TM⁻_z ⊢ φ ⟹ TM_z ⊢ tr φ`, at `FrameClass.ZTime`.

`TM⁻_z` is TM⁻ + **DF**; its translation is discharged by
`FormalSystem.Theorems.DiscreteUnfolding.dfSchema`, derived syntactically (Route A) with no
appeal to the completeness machinery.

Paper: — (formalization-native; the paper states no TM⁻/TM⁻-plus proof-theoretic bridge)
-/
theorem cef_backward {φ : MinusFormula}
    (h : MinusLanguage.Derivable FrameClass.ZTime [] φ) :
    ProofSystem.Derivable FrameClass.ZTime [] (tr φ) :=
  derivable_translate h

/--
**CED**: `TM⁻_d ⊢ φ ⟹ TM_d ⊢ tr φ`, at `FrameClass.Dense`.

`TM⁻_d` is TM⁻ + **DN** (`GGφ → Gφ`), whose translation is literally `Axiom.density`.

Paper: — (formalization-native; the paper states no TM⁻/TM⁻-plus proof-theoretic bridge)
-/
theorem ced_backward {φ : MinusFormula}
    (h : MinusLanguage.Derivable FrameClass.Dense [] φ) :
    ProofSystem.Derivable FrameClass.Dense [] (tr φ) :=
  derivable_translate h

/--
**CEC**: `TM⁻_r ⊢ φ ⟹ TM_r ⊢ tr φ`, at `FrameClass.RTime`.

**Why the row is the dense-and-complete one.** This repository's `FrameClass.RTime` sits
strictly *above* `FrameClass.Dense` (`Dense ≤ RTime`, see `ProofSystem/Axioms.lean`), so a
`.RTime` derivation may use `Axiom.density` and `Axiom.dense_indicator` as well as the Reynolds
gap axioms. The row is therefore `TM⁻_r ⟶ TM_r` — the dense complete / real-flow system — and
`TM_r` is the paper's `TM⁻_r`, the `ℝ`-time row of `cor:tm-completeness`, so nothing is lost in
translation here. There is no repository frame class for density-free completeness; that binder
set is `Semantics/Validity.lean`'s repository-only `ValidComplete`, which answers to no paper
system.

The L⁻-side CO axiom's translation is discharged by
`FormalSystem.Theorems.DedekindDerived.coDerived`, itself sorry-free over the Reynolds triple.

Paper: — (formalization-native; the paper states no TM⁻/TM⁻-plus proof-theoretic bridge)
-/
theorem cec_backward {φ : MinusFormula}
    (h : MinusLanguage.Derivable FrameClass.RTime [] φ) :
    ProofSystem.Derivable FrameClass.RTime [] (tr φ) :=
  derivable_translate h

/-! ## The CEF forward-direction witness

Not part of the bridge: this is the TM_z half of the CEF refutation. The other half — that
`TM⁻_z ⊬ Z1` — is **also machine-checked**, in the sibling module
`Conservativity/Z1Countermodel.lean`, as `not_minus_derivable_z1`; the L⁻-side soundness theorem it
needed, `minus_soundness_ztime_succ`, is in `Conservativity/MinusLanguageSoundness.lean`.
`tmMinusCompleteZTime_refuted`, in that same countermodel module, reads the pair off as an outright
refutation of TM⁻_z-completeness over the discrete class. Neither half is outstanding. -/

/--
The L⁻-side **Z1** schema, `G(Gφ → φ) → (F(Gφ) → Gφ)`, with L⁻'s *derived* `F`.

This is the paper's TMP-Z1 written in the base language. It is the CEF forward-direction
witness: its translation is a `TM_z` theorem (`z1_translate` below) while it is not a `TM⁻_z`
theorem — the latter by soundness over `ℚ ×_lex ℤ` (`Semantics/LexCarrier.lean`), which **is**
formalized in this tree, as `Z1Countermodel.not_minus_derivable_z1`
(`Conservativity/Z1Countermodel.lean`). The carrier is `ℚ ×_lex ℤ`, not the `ℤ ×_lex ℤ` an
earlier draft of this file and the research report both named; see the aggregator's module
docstring, which records the correction and why `ℚ ×_lex ℤ` is the right carrier.
-/
def Z1 (φ : MinusFormula) : MinusFormula :=
  (φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)

/--
`⊢[Discrete] tr (Z1 φ)` — the translation of the L⁻-side Z1 schema is a `TM_z` theorem.

Two steps: `ProofSystem.Axiom.z1` at `FrameClass.ZTime`, then
`MinusLanguage.notGNotImpF` pushed into the antecedent of the consequent by
`MinusLanguage.impMono`, converting the axiom's `F(Gφ)` into the `¬G¬(Gφ)` shape `tr` produces.

**This is not the forward direction and does not approach it.** It is one half of the CEF
witness, and it is the half proved *here*; the other half is `not_minus_derivable_z1`
(`Conservativity/Z1Countermodel.lean`). See the aggregator's module docstring for why no
`sorry`-ed `forward` theorem may be written — that prohibition is unaffected by both halves of
CEF being discharged, since `forward` is refuted rather than open.
-/
theorem z1_translate (φ : MinusFormula) :
    ProofSystem.Derivable FrameClass.ZTime [] (tr (Z1 φ)) :=
  ⟨FormalSystem.Theorems.Combinators.impTrans
    (ProofSystem.DerivationTree.axiom [] _ (ProofSystem.Axiom.z1 (tr φ))
      (show FrameClass.ZTime ≤ FrameClass.ZTime from le_refl _))
    (MinusLanguage.impMono
      (MinusLanguage.notGNotImpF (tr φ).allFuture)
      (FormalSystem.Theorems.Combinators.identity (tr φ).allFuture))⟩

end FormalSystem.Metalogic.Conservativity

