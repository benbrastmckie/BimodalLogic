/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.BaseLanguage

/-!
# The backward TM/TM⁺ conservativity bridge

**Read `Metalogic/Conservativity.lean`'s module docstring first.** That aggregator carries the
whole narrative this file's declarations sit inside — in particular the
**forward-conservativity prohibition**, which states that

```
theorem forward {fc} {φ} : ProofSystem.Derivable fc [] (tr φ) → BaseLanguage.Derivable fc [] φ
```

is refuted at `fc := .Base` and `fc := .Discrete`, and that a `sorry`-ed proof of it would be an
unsound placeholder rather than deferred debt. Nothing in this file states or approaches
`forward`.

What this file holds is the **backward** direction, which is unproblematic and proved: the
translation `translate` from BL derivations to BL⁺ derivations, its `Derivable`-level corollary
`derivable_translate`, the four per-class rows `ceb_backward` / `cef_backward` / `ced_backward` /
`cec_backward`, and the CEF forward-direction *witness* `Z1` / `z1_translate` — the half of the
CEF refutation that succeeds. The half that fails is `Z1Countermodel.not_bl_derivable_z1`, in a
sibling module.

## No semantics

Nothing here — nor anything under `FormalSystem/BaseLanguage/`, transitively — imports
`FormalSystem.Semantics`. `translate` is a function between two `DerivationTree` types and
touches no truth definition, frame, or validity predicate. The semantics-facing half of the
story lives in the sibling `Conservativity/BaseLanguageSoundness.lean`, which is where the
`FormalSystem.Semantics` import enters.
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.BaseLanguage

/--
**The backward conservativity bridge.**

Every TM derivation over the base language BL becomes a TM⁺ derivation of its translation, at
the same frame class and over the translated context.

Seven cases, one per BL rule:

- `axiom` — `BaseLanguage.dischargeAxiom`, the lookup table of
  `BaseLanguage/AxiomDischarge.lean`, weakened from the empty context.
- `assumption` — membership transported through `tr` by `BaseLanguage.mem_trCtx`.
- `modus_ponens`, `weakening` — structural.
- `necessitation`, `temporal_necessitation` — structural; both rules are empty-context on both
  sides and `trCtx [] = []` definitionally.
- `temporal_duality` — the load-bearing case. TM's **TD** concludes `⊢ swapBL φ` while BL⁺'s
  rule concludes `⊢ swapTemporal (tr φ)`; `BaseLanguage.tr_swapBL` is exactly the equation that
  makes those the same formula, and without it this case does not typecheck.
-/
noncomputable def translate {fc : FrameClass} {Γ : BaseLanguage.Context} {φ : BLFormula} :
    BaseLanguage.DerivationTree fc Γ φ → ProofSystem.DerivationTree fc (trCtx Γ) (tr φ)
  | .axiom Γ _ h h_fc =>
      ProofSystem.DerivationTree.weakening [] (trCtx Γ) _
        (BaseLanguage.dischargeAxiom h h_fc) (List.nil_subset _)
  | .assumption _ _ h => .assumption _ _ (BaseLanguage.mem_trCtx h)
  | .modus_ponens _ φ ψ d1 d2 =>
      .modus_ponens _ (tr φ) (tr ψ) (translate d1) (translate d2)
  | .necessitation φ d => .necessitation (tr φ) (translate d)
  | .temporal_necessitation φ d => .temporal_necessitation (tr φ) (translate d)
  | .temporal_duality φ d =>
      (BaseLanguage.tr_swapBL φ).symm ▸
        ProofSystem.DerivationTree.temporal_duality (tr φ) (translate d)
  | .weakening _ _ _ d h =>
      .weakening _ _ _ (translate d)
        (by
          intro x hx
          obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx
          exact List.mem_map_of_mem (h hy))

/--
The `Prop`-level backward bridge: TM-derivability implies TM⁺-derivability of the translation,
at the same frame class.
-/
theorem derivable_translate {fc : FrameClass} {Γ : BaseLanguage.Context} {φ : BLFormula}
    (h : BaseLanguage.Derivable fc Γ φ) :
    ProofSystem.Derivable fc (trCtx Γ) (tr φ) :=
  h.elim fun d => ⟨translate d⟩

/-! ## The four paper rows

Each row is `translate` at one frame class and the empty context — the paper's rows are
theoremhood claims, not consequence claims. `trCtx [] = []` definitionally, so no context
bookkeeping appears in the statements. -/

/--
**CEB**: `TM ⊢ φ ⟹ TM⁺ ⊢ tr φ`, at `FrameClass.Base`.

The base row: no extension axiom is available on either side.
-/
theorem ceb_backward {φ : BLFormula}
    (h : BaseLanguage.Derivable FrameClass.Base [] φ) :
    ProofSystem.Derivable FrameClass.Base [] (tr φ) :=
  derivable_translate h

/--
**CEF**: `TM_f ⊢ φ ⟹ TM⁺_f ⊢ tr φ`, at `FrameClass.Discrete`.

`TM_f` is TM + **DF**; its translation is discharged by
`FormalSystem.Theorems.DiscreteUnfolding.dfSchema`, derived syntactically (Route A) with no
appeal to the completeness machinery.
-/
theorem cef_backward {φ : BLFormula}
    (h : BaseLanguage.Derivable FrameClass.Discrete [] φ) :
    ProofSystem.Derivable FrameClass.Discrete [] (tr φ) :=
  derivable_translate h

/--
**CED**: `TM_d ⊢ φ ⟹ TM⁺_d ⊢ tr φ`, at `FrameClass.Dense`.

`TM_d` is TM + **DN** (`GGφ → Gφ`), whose translation is literally `Axiom.density`.
-/
theorem ced_backward {φ : BLFormula}
    (h : BaseLanguage.Derivable FrameClass.Dense [] φ) :
    ProofSystem.Derivable FrameClass.Dense [] (tr φ) :=
  derivable_translate h

/--
**CEC**: `TM_dc ⊢ φ ⟹ TM⁺_dc ⊢ tr φ`, at `FrameClass.Dedekind`.

**Fidelity caveat — this row is TM_dc, not the paper's TM_c.** This repository's
`FrameClass.Dedekind` sits strictly *above* `FrameClass.Dense` (`Dense ≤ Dedekind`, see
`ProofSystem/Axioms.lean`), so a `.Dedekind` derivation may use `Axiom.density` and
`Axiom.dense_indicator` as well as the Reynolds gap axioms. The row therefore reads
`TM_dc ⟶ TM⁺_dc` — the dense complete / real-flow system — and **not** the paper's TM_c,
which is completeness *simpliciter* with no density binder. There is no repository frame class
for "complete but not dense"; `ProofSystem/Axioms.lean`'s `FrameClass` docstring explains why
that is a genuine gap rather than an omission. Do not read `cec_backward` as establishing the
TM_c row.

The BL-side CO axiom's translation is discharged by
`FormalSystem.Theorems.DedekindDerived.co_derived`, itself sorry-free over the Reynolds triple.
-/
theorem cec_backward {φ : BLFormula}
    (h : BaseLanguage.Derivable FrameClass.Dedekind [] φ) :
    ProofSystem.Derivable FrameClass.Dedekind [] (tr φ) :=
  derivable_translate h

/-! ## The CEF forward-direction witness

Not part of the bridge: this is the TM⁺_f half of the CEF refutation. The other half — that
`TM_f ⊬ Z1` — is **also machine-checked**, in the sibling module
`Conservativity/Z1Countermodel.lean`, as `not_bl_derivable_z1`; the BL-side soundness theorem it
needed, `bl_soundness_discrete_succ`, is in `Conservativity/BaseLanguageSoundness.lean`.
`tmCompleteDiscrete_refuted`, in that same countermodel module, reads the pair off as an outright
refutation of TM_f-completeness over the discrete class. Neither half is outstanding. -/

/--
The BL-side **Z1** schema, `G(Gφ → φ) → (F(Gφ) → Gφ)`, with BL's *derived* `F`.

This is the paper's TMP-Z1 written in the base language. It is the CEF forward-direction
witness: its translation is a `TM⁺_f` theorem (`z1_translate` below) while it is not a `TM_f`
theorem — the latter by soundness over `ℚ ×_lex ℤ` (`Semantics/LexCarrier.lean`), which **is**
formalized in this tree, as `Z1Countermodel.not_bl_derivable_z1`
(`Conservativity/Z1Countermodel.lean`). The carrier is `ℚ ×_lex ℤ`, not the `ℤ ×_lex ℤ` an
earlier draft of this file and the research report both named; see the aggregator's module
docstring, which records the correction and why `ℚ ×_lex ℤ` is the right carrier.
-/
def Z1 (φ : BLFormula) : BLFormula :=
  (φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)

/--
`⊢[Discrete] tr (Z1 φ)` — the translation of the BL-side Z1 schema is a `TM⁺_f` theorem.

Two steps: `ProofSystem.Axiom.z1` at `FrameClass.Discrete`, then
`BaseLanguage.notGNot_imp_F` pushed into the antecedent of the consequent by
`BaseLanguage.impMono`, converting the axiom's `F(Gφ)` into the `¬G¬(Gφ)` shape `tr` produces.

**This is not the forward direction and does not approach it.** It is one half of the CEF
witness, and it is the half proved *here*; the other half is `not_bl_derivable_z1`
(`Conservativity/Z1Countermodel.lean`). See the aggregator's module docstring for why no
`sorry`-ed `forward` theorem may be written — that prohibition is unaffected by both halves of
CEF being discharged, since `forward` is refuted rather than open.
-/
theorem z1_translate (φ : BLFormula) :
    ProofSystem.Derivable FrameClass.Discrete [] (tr (Z1 φ)) :=
  ⟨FormalSystem.Theorems.Combinators.impTrans
    (ProofSystem.DerivationTree.axiom [] _ (ProofSystem.Axiom.z1 (tr φ))
      (show FrameClass.Discrete ≤ FrameClass.Discrete from le_refl _))
    (BaseLanguage.impMono
      (BaseLanguage.notGNot_imp_F (tr φ).allFuture)
      (FormalSystem.Theorems.Combinators.identity (tr φ).allFuture))⟩

end FormalSystem.Metalogic.Conservativity

