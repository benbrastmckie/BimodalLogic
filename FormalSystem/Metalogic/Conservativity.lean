/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.BaseLanguage

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

This module proves the **backward** direction only. The converse is refuted for two of the four
rows and open for the other two; see the "The forward direction" section below, which exists
specifically so that a future dispatch does not re-attempt it.

## No semantics

Nothing here — nor anything under `FormalSystem/BaseLanguage/`, transitively — imports
`FormalSystem.Semantics`. `translate` is a function between two `DerivationTree` types and
touches no truth definition, frame, or validity predicate, so the bridge composes unchanged
with whatever the totality-based validity definition becomes. The intended composition is

```
BL-validity over C  ⟸[BL soundness, not built]  ⊢ᴮᴸ[fc] φ  ⟶[translate]  ⊢[fc] tr φ
                                                          ⟸[completeness_*]  BL⁺-validity over C
```

and this module is the middle arrow only.
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

end FormalSystem.Metalogic.Conservativity
