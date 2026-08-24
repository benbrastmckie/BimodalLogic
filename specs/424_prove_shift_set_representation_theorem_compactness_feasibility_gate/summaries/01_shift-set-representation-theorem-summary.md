# Implementation Summary: Shift-Set Representation Theorem (Compactness Feasibility Gate)

- **Task**: 424 - Prove shift-set representation theorem (compactness feasibility gate)
- **Plan**: `specs/424_prove_shift_set_representation_theorem_compactness_feasibility_gate/plans/01_shift-set-representation-theorem.md`
- **Research**: `specs/424_prove_shift_set_representation_theorem_compactness_feasibility_gate/reports/01_shift-set-representation-feasibility.md`
- **Phases**: 7 of 7 completed (Phase 7 was optional and was executed)

## GATE VERDICT: **PASSED**

Both directions of the representation theorem are landed sorry-free, neither depends on
`sorryAx`, and the module is registered so that `lake build` actually compiles it.

The cancel condition of the GATING RULE is **not** met. The one field that is not a free
consequence of the group action — `sep`, the transcription of the paper's *Limit* axiom — is
**first-order** over the two-sorted signature `⟨Ω, D; <, +, 0, sh, (A_p)⟩` and hence
ultraproduct-preserved. No non-elementary hypothesis was needed anywhere. Route B (semantic
compactness via a bespoke ultraproduct over a shift-set representation) therefore **stands**.

Per the plan's Non-Goals, this task does **not** spawn, plan, or dispatch S2-S5; a PASSED
verdict only unblocks authorization for them.

## Gate evidence

`#print axioms`, run on the fully qualified names, on the registered module:

```
'FormalSystem.Semantics.ShiftSet.forward_repr' depends on axioms: [propext, Quot.sound]
'FormalSystem.Semantics.ShiftSet.reverse_repr' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Semantics.ShiftSet.total_eq_orbit' depends on axioms: [propext, Quot.sound]
'FormalSystem.Semantics.ShiftSet.SepNotDerivable.sep_not_derivable' depends on axioms: [propext, Classical.choice, Quot.sound]
```

These match the expected sets from research exactly. No `sorryAx` on any of them.
`Classical.choice` on `reverse_repr` traces to `PartialHistory.hF_nonempty`
(`FormalSystem/Semantics/Extension/Extension.lean`, Zorn-based), used only to witness that the
carrier `F.HF` is nonempty. The gate's evidence standard forbids `sorryAx`, not choice.

Other checks:

- `grep -n "sorry" FormalSystem/Semantics/ShiftSet.lean` — no matches.
- `grep -n "Type\*" FormalSystem/Semantics/ShiftSet.lean` — no matches (design-doc risk R3;
  `D : Type` and `Carrier : Type` at the structure binder).
- `lake build FormalSystem.Semantics.ShiftSet` — green (1082 jobs).
- `ShiftSet.ofModel` carries **no** freeness field.

## Both theorem statements, as landed

```lean
theorem ShiftSet.forward_repr (S : ShiftSet D) (w : S.Carrier) (t : D) (φ : Formula) :
    TruthAt S.model (S.hist w) t φ ↔ ShiftTruth S w t φ

theorem ShiftSet.reverse_repr (F : TaskFrame D) (M : TaskModel F) (τ : F.HF) (t : D)
    (φ : Formula) :
    ShiftTruth (ShiftSet.ofModel F M) τ t φ ↔ TruthAt M τ.val t φ
```

Both match the plan's verbatim shapes modulo namespace qualification (the file sits in
`namespace FormalSystem.Semantics`, per the sibling convention, and the short names are kept).
Neither direction was reduced to a bare construction.

## Design-document corrections confirmed in the landed code

1. **The forward direction's "holds by construction" list was stale.** It was written against a
   five-field `TaskFrame`; the live structure
   (`FormalSystem/Semantics/TaskFrame.lean`) has **seven** fields — `nonempty`,
   `nullity_identity`, `comp`, `converse`, `serial`, `limit`, `spherical` — confirmed by reading
   the structure at implementation time. `ShiftSet.frame` discharges all seven. Three are free
   consequences of the task relation being functional plus the group action, and are recorded as
   such in the module docstring: `serial`, the **interpolation** half of the biconditional
   `comp`, and `spherical`.

2. **`limit` is not free, and the fix is elementary.** The `sep` field transcribes the paper's
   *Limit* axiom over the shift action. It is first-order over the signature, so it does not
   trigger the GATING RULE's cancel condition. The stronger free-action axiom
   `∀ w d, sh w d = w → d = 0` is rejected and must stay rejected: under the reverse direction
   the carrier is `F.HF`, and a constant total history has full stabiliser, so freeness is
   outright refuted there and `ofModel` could not be built. `ShiftSet.rev_sep` shows separation
   is dischargeable from `F.limit` alone, with **no** new frame hypothesis.

## What landed, by phase

| Phase | Content |
|-------|---------|
| 1 | Module header and docstring; `ShiftSet` structure (`Carrier`, `carrier_nonempty`, `sh`, `sh_zero`, `sh_add`, `sep`, `A`); `sh_neg`, `sh_neg'`; local `wh_ext` |
| 2 | `ShiftSet.frame`, discharging all seven live `TaskFrame` fields |
| 3 | `hist`, `hist_isTotal`, `model`, `total_eq_orbit` |
| 4 | `ShiftTruth` (six clauses, `box` over the whole carrier); `forward_repr` |
| 5 | `ts_zero`, `ts_add`, `rev_sep`, `ofModel`, `reverse_repr` |
| 6 | Import line in `FormalSystem/Semantics.lean`; README module-table row; gate evidence |
| 7 | `SepNotDerivable`: `DyadicGroup`, `third_not_dyadic`, `dyadic_approx`, `qsh`, `sep_not_derivable` |

Phase 7 converts "the `sep` field is an unjustified strengthening" from an open reviewer
objection into a theorem: `ℚ` acting by translation on `ℚ ⧸ (dyadics)` satisfies both action
laws and refutes the separation condition. Density of the dyadics supplies the arbitrarily-small
witnesses; properness (`1/3 ∉ H`) makes the conclusion false.

## Scope Hypothesis outcomes

- **Phase 1** (instance list): confirmed. `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  [Nontrivial D]` matches `TaskFrame`'s own binder; no instance missing or extra.
- **Phase 2** (seven `TaskFrame` fields): confirmed by reading the structure. No extra obligation.
- **Phase 6** (registration is one import line plus one README row; expected axiom sets):
  confirmed on all three counts. Actual axiom output matched the expected sets exactly.
- **Phase 7** (40-60 lines; needed Mathlib modules built): **delta recorded.** The needed modules
  (`Mathlib.GroupTheory.QuotientGroup.Basic`, `Mathlib.Algebra.Order.Archimedean.Basic`,
  `Mathlib.Algebra.Order.Floor.Ring`, `Mathlib.Data.Rat.Cast.Order`, `Mathlib.Data.Nat.GCD.Basic`)
  are all built in this checkout, but `Mathlib.Tactic`, `Mathlib.Data.Rat.Order`,
  `Mathlib.RingTheory.Int.Basic`, and `Mathlib.Tactic.NormNum.Prime` are **not**, so imports had
  to be narrowed and the `3 ∤ 2^n` step routed through `Nat.Coprime` rather than through
  primality. The counterexample section is ~75 lines of code (~110 with docstrings) against the
  estimated 40-60 — over, but not materially, and it did not delay the gate.
- **File size**: the landed file is 506 lines against the plan's estimate of ~300-360 including
  Phase 7. The overrun is docstrings, not proof code; the declaration inventory is exactly what
  the plan specified.

## Plan Deviations

- None (implementation followed the plan). Every phase was executed in order, and every
  declaration named in the plan landed under the name the plan gave it.

## Files changed

- `FormalSystem/Semantics/ShiftSet.lean` — created, 506 lines
- `FormalSystem/Semantics.lean` — one added import line (the declared scope change)
- `FormalSystem/Semantics/README.md` — one added module-table row (discretionary)
