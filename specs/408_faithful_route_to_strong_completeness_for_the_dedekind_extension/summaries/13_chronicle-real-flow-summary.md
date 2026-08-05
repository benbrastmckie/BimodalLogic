# Phase 29 closure — Doets' theorem at the chronicle bridge

**Task**: 408 — faithful route to strong completeness for the Dedekind extension
**Phase**: 29 (*Doets' Theorem — Reynolds §8 Theorem 6*), residual work only
**Plan**: `plans/10_strong-completeness-dedekind-v10.md`
**Status at exit**: Phase 29 `[COMPLETED]` — the anti-vacuity checkbox, its only outstanding item,
is met.

## What was outstanding, and what closed it

Phase 29's proof half (`doets_theorem_dense`) had been sorry-free and axiom-clean since sub-phase
29.6. The phase stayed `[PARTIAL]` for exactly one item: the anti-vacuity checkbox — instantiate
Doets' theorem at `chronicleIsDensePriorSepStructure` and land the resulting `ℝ`-flowed structure
as a named definition.

That was gated on discharging `DoetsD1` / `DoetsD2` at the chronicle structure, which needed §6 to
run on the countable-dense reading. Sub-phase 29.8 supplied the bulk of it — §6 restated against an
arbitrary structure class — and left two named follow-ups. This dispatch landed both and then the
checkbox.

### 1. `epsDense`'s witness at the countable-dense class

`epsDense_isContempEquivDenseOn_countableDense` (`FormalSystem/Metalogic/WeakCanonical/RealModel/
EpsilonDense.lean`). `IsContempEquivDenseCD.toOn` fed `simDense_refl` and `simDense_symm`
transported along `contempEquivDense_epsDense_iff`. Both carry no instance hypotheses, so nothing
is assumed of `∼_M` beyond what §8 Lemma 12 already gives. Landed as the one-liner 29.8 predicted.

### 2. D1/D2 restated at the class-parameterized bundle

`DoetsD1` / `DoetsD2` (`RealModel/DoetsTheorem.lean`) now quantify over `ε` satisfying
`IsContempEquivDenseOn ε (CountableDense sig)` rather than `IsContempEquivDenseCD ε`.

**This is a strengthening of `doets_theorem_dense`, and it is checked rather than asserted.** The
three readings order as `IsContempEquivDense → IsContempEquivDenseOn _ (CountableDense _) →
IsContempEquivDenseCD`, strongest requirement on `ε` first. D1/D2 quantify *over* `ε`, so a
stronger antecedent admits fewer `ε`, makes the hypothesis weaker, and makes the theorem stronger;
the reading also stays strictly stronger than Reynolds' own, whose D1/D2 range over the
unrestricted bundle. `doetsD1_of_cd` / `doetsD2_of_cd` are the machine-checked no-weakening pair:
any supplier that met the previous reading meets this one, through
`isContempEquivDenseCD_of_countableDense`.

The step is forced, not cosmetic. The surplus `IsContempEquivDenseCD → IsContempEquivDenseOn _
(CountableDense _)` is unrestricted reflexivity and symmetry. That is available for `epsDense` and
**not** available for an arbitrary `ε` that a caller hands to D1 — so with the old antecedent the
chronicle instantiation is impossible, not merely awkward.

### 3. The join module

`FormalSystem/Metalogic/WeakCanonical/RealModel/ChronicleRealFlow.lean` (new, 170 lines):

| Declaration | Content |
|---|---|
| `chronicleMonadic_doetsD1` | D1 at the bridge, both ends, from `chronicleMonadic_no_gaps` / `_left` |
| `chronicleMonadic_doetsD2` | D2 at the bridge, from `chronicleMonadic_dense_singletons` |
| `exists_chronicleRealFlow` | Theorem 6 with all seven hypotheses discharged |
| `chronicleRealFlow` | the named `ℝ`-flowed structure |
| `chronicleRealFlow_isRealFlow` | *"flow of time the real numbers"* |
| `chronicleRealFlow_kEquiv` | *"satisfying the same monadic sentences of depth ≤ k"* |

29.8's second follow-up — chronicle-level `CountableDense` membership — is discharged inside D1/D2
there as two `haveI`s off `chronicleIsDensePriorSepStructure`'s own `countable` and
`denselyOrdered` fields, exactly as 29.8's handoff predicted. It is not a global instance because
`h_mcs` and `h_box_dense` are non-class explicit arguments.

## Why the instantiation is not vacuous

The v10 caveat warned that closing this checkbox at `epsTop` would be vacuous, for two independent
reasons already recorded in `ChronicleInstance.lean` (`EndsInGapOnRight` is empty at `epsTop`;
`QuotientDenselyOrdered` is unsatisfiable at `epsTop`). Neither hatch is taken:

- `chronicleMonadic_doetsD1` / `_doetsD2` are proved at an **arbitrary** `ε` in the countable-dense
  class, not at a chosen convenient one.
- `doets_theorem_dense` then *consumes* them at `ε := epsDense (mkSigFrom root) k` — Reynolds' own
  `∼_M` — via `doetsD1_epsDense` / `doetsD2_epsDense`. So the `ε` at which D1 and D2 do work inside
  `chronicleRealFlow_kEquiv` is the live one Phase 25 built.

## `Owns` deviation, recorded

Phase 29's `Owns` names `RealModel/DoetsTheorem.lean` alone. Two files outside it were touched:
`RealModel/EpsilonDense.lean` (which 29.8 explicitly assigned to that file's owner and named as
this checkbox's prerequisite) and the new `RealModel/ChronicleRealFlow.lean`. The new module is a
leaf — it imports `RealModel/DoetsTheorem` and `DenseModelSurgery/ChronicleInstance`, and nothing
imports it. It exists for the layering reason `ChronicleInstance.lean` records for itself:
`RealModel/` must not acquire the chronicle's ~280-module closure and the bridge must not acquire
§8's, so the join could not live in either file it joins. Nothing outside `RealModel/` was
modified; `StrongCompleteness.lean` and all of `DenseModelSurgery/` are byte-identical.

## Verification

| Check | Result |
|---|---|
| Full `lake build` | green, 1983 jobs (unchanged — the new module is a leaf the root does not reach) |
| Scoped build (`ChronicleInstance` + `DoetsTheorem` + `ChronicleRealFlow`) | green, 2235 jobs (2234 baseline + 1) |
| `#print axioms` on all five new chronicle declarations | `[propext, Classical.choice, Quot.sound]` — no `sorryAx` |
| Non-Boneyard sorry census | 1 at entry, 1 at exit (`Metalogic/WeakCanonical/Transfer.lean:1242`, pre-existing, unrelated) |
| Vacuous definitions | 0 |
| New axioms | 0 |
| `StrongCompleteness.lean` | byte-identical |

## Commits

| SHA | Subject |
|---|---|
| `f57d00293` | epsDense's witness at the countable-dense structure class |
| `4406ae4c2` | D1 and D2 at the class-parameterized bundle |
| (this dispatch, final) | Doets' theorem at the chronicle bridge — the R-flowed structure; plan and summary |

## What this unblocks

Phase 30's `countermodel_dedekind_dense` can now consume `chronicleRealFlow` and
`chronicleRealFlow_kEquiv` directly instead of re-deriving the instantiation. The Block H
checkpoint — *"an `ℝ`-flowed structure `≡ₖ`-equivalent to the chronicle model now exists"* — is
met by a named definition rather than by an existential the caller must re-open.
