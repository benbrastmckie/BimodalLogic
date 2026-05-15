# Deep Extraction Analysis: Split NEquivalence.lean

- **Task**: 145 - Split NEquivalence.lean, redesign KType to NormalForm, close k_equiv_monotone
- **Started**: 2026-05-15T15:00:00Z
- **Completed**: 2026-05-15T16:00:00Z
- **Effort**: Deep analysis
- **Dependencies**: 143 (completed), 141 (insertEnv/lift_eval sorries -- orthogonal)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (610 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` (572 lines, 0 sorries)
  - `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (304 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (76 lines)
  - `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/WeakCanonical.lean` (aggregator)
  - Report 01: `specs/145_split_nequivalence_close_k_equiv_monotone/reports/01_split-design.md`
  - Doets 1989 Lemma 1.1: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- **Artifacts**: This file
- **Standards**: report.md, artifact-formats.md

## Executive Summary

This analysis provides exact line ranges, verified import requirements, and a precise implementation specification for the NEquivalence.lean split. Key findings:

1. **MonadicFO.lean extraction** covers lines 46-366 (320 lines, 24 definitions). Zero hidden dependencies on canonical model confirmed.
2. **MonadicFO.lean imports**: Three Mathlib imports needed (`Fintype.Card`, `SuccPred.Basic`, `Fin.Tuple.Basic`). Does NOT need `Bimodal.Syntax` or `Bimodal.ProofSystem`.
3. **insertEnv/lift_eval/weaken_eval** (task 141 sorries) go to MonadicFO.lean. They have no interaction with NormalForm.lean and are orthogonal to this task.
4. **k_equiv_monotone proof**: Verified via `decide_eq_decide` bridge from `Init.PropLemmas` plus `nf_agreement_monotone` from NormalForm.lean.
5. **finite_types**: Proof structure unchanged -- `NormalForm sig k 0 -> Bool` is `Fintype` since `NormalForm` is `Fintype`.
6. **Downstream impact**: Table.lean import must change from NEquivalence to MonadicFO. All others unaffected.

## Section 1: Exact Line Ranges for MonadicFO.lean Extraction

### Lines to Extract (NEquivalence.lean -> MonadicFO.lean)

| Lines | Content | Dependency |
|-------|---------|------------|
| 46 | `namespace Bimodal.Metalogic.WeakCanonical` | -- |
| 51-59 | MonadicSignature + attribute instances | None |
| 61-95 | MonadicFormula inductive, MonadicSentence abbrev, quantifier_depth | MonadicSignature |
| 97-107 | MonadicStructure structure | MonadicSignature |
| 108-191 | OrderedMonadicStructure, toMonadic, subinterval, subinterval_singleton_finite, subinterval_two_element_finite | MonadicStructure, Mathlib (LinearOrder, SuccOrder, Finset.mem_singleton) |
| 193-216 | ZStructure, ZStructure.toMonadic, ZStructure.toOrdered | MonadicStructure, OrderedMonadicStructure |
| 218-235 | eval (Tarski satisfaction) | OrderedMonadicStructure, MonadicFormula, Fin.cons |
| 237-274 | finLift, MonadicFormula.lift, MonadicFormula.weaken | MonadicFormula |
| 282-332 | insertEnv, insertEnv_zero_eq_cons (sorry), insertEnv_succ_cons (sorry), insertEnv_finLift (sorry), lift_eval (sorry), weaken_eval | eval, Fin.cons (task 141 sorries) |
| 334-366 | atomCount, nfCount, nfCount_pos, NormalFormIdx | MonadicSignature, Fintype.card |

**Total**: ~320 lines, 24 definitions/theorems.

### Lines That Stay in NEquivalence.lean

| Lines | Content | Why it stays |
|-------|---------|-------------|
| 1-3 | imports (will change) | -- |
| 5-44 | module docstring (will update) | -- |
| 48-49 | `open Bimodal.Syntax`, `open Bimodal.ProofSystem` | Needed by chronicle section |
| 368-453 | KType, nf_rep, k_type_of, k_equiv, k_equiv_iff_same_type, k_equiv_monotone | k-equivalence framework (will be rewritten) |
| 455-537 | KEquivalenceFramework class + default instance | Depends on k_equiv |
| 539-609 | chronicleAsMonadicStructure + instances | Depends on ChronicleAsPriorModel, Formula |
| 610 | `end Bimodal.Metalogic.WeakCanonical` | -- |

### Lines to DELETE from NEquivalence.lean

| Lines | Content | Reason |
|-------|---------|--------|
| 400-404 | `nf_rep` (noncomputable def via Classical.choice) | Replaced by nf_eval_nf |

## Section 2: Import Analysis

### MonadicFO.lean Imports (Verified)

```lean
import Mathlib.Data.Fintype.Card       -- Fintype, Fintype.card, Finset.mem_singleton (transitive)
import Mathlib.Order.SuccPred.Basic    -- SuccOrder, Order.succ, Order.le_succ
import Mathlib.Data.Fin.Tuple.Basic    -- Fin.cons
```

**NOT needed** (verified by checking all references in lines 46-366):
- `Bimodal.Syntax` -- no `Formula` or syntax types used
- `Bimodal.ProofSystem` -- no proof system types used
- `Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical` -- no canonical model types
- `Bimodal.Metalogic.WeakCanonical.ChronicleExtraction` -- no chronicle types

**Verification**: Searched all references to `Formula`, `ChronicleAsPriorModel`, `ReflCanDomain`, `MCS`, `SetMaximalConsistent`, `fmcs`, `g_w_content` in lines 46-366: zero matches.

### NormalForm.lean Imports (Post-Split)

```lean
import Bimodal.Metalogic.WeakCanonical.MonadicFO  -- was: NEquivalence
```

**What NormalForm.lean uses from MonadicFO** (all confirmed by grep):
- `MonadicSignature` (lines 48, 52, 83, 103, 124, etc.)
- `OrderedMonadicStructure` (lines 104, 189, 206)
- `MonadicFormula` (line 449 in doets_lemma_1_1)
- `eval` (line 449+)
- `atomCount`, `nfCount` (implicit via NormalForm definition)
- `NormalFormIdx` (lines 418-419, 427-428, legacy defs)
- `Fin.cons` (lines 196, 210, 211, etc.)

**What NormalForm.lean does NOT use** from the current NEquivalence:
- `KType`, `k_type_of`, `k_equiv`, `nf_rep` -- only in comments
- `KEquivalenceFramework` -- not referenced
- `chronicleAsMonadicStructure` -- not referenced
- `insertEnv`, `lift_eval`, `weaken_eval` -- not referenced

### NEquivalence.lean Imports (Post-Split)

```lean
import Bimodal.Metalogic.WeakCanonical.MonadicFO
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
```

**Note**: `Mathlib.Data.Finset.Basic` is no longer needed directly since MonadicFO brings it transitively.

### Table.lean Import Change

```lean
import Bimodal.Metalogic.WeakCanonical.MonadicFO  -- was: NEquivalence
```

**Table.lean uses from MonadicFO** (confirmed by grep):
- `MonadicSignature` (lines 91, 154, 168, 205, 269)
- `MonadicFormula` (lines 92, 155, 232, 247)
- `OrderedMonadicStructure` (lines 206, 230, 245, 270)
- `eval` (lines 233-234, 248-249, 273)
- `insertEnv` (lines 224, 226, 238, 240)
- `lift_eval` (lines 236, 254)
- `MonadicFormula.lift`, `MonadicFormula.quantifier_depth` (throughout)

**Table.lean does NOT use**: `KType`, `k_equiv`, `KEquivalenceFramework`, chronicle defs.

### Downstream Files (No Change Needed)

| File | Current Import | After Split | Reason |
|------|----------------|-------------|--------|
| OrderedSum.lean | NEquivalence | NEquivalence (unchanged) | Uses `k_equiv`, `KType`, `k_type_of` |
| IntegerModel.lean | OrderedSum, Table, ChronicleExtraction | Same (unchanged) | Gets NEquivalence transitively via OrderedSum |
| Transfer.lean | IntegerModel, OrderedSum | Same (unchanged) | Gets NEquivalence transitively |
| WeakCanonical.lean | NEquivalence, NormalForm | Same (unchanged) | Aggregator, gets everything transitively |

**WeakCanonical.lean note**: It explicitly imports both NEquivalence and NormalForm. After the split, NEquivalence already imports NormalForm, so the explicit NormalForm import becomes redundant but harmless. Can optionally add explicit `MonadicFO` import for clarity.

## Section 3: KType Redesign Specification

### Current Definitions (to be replaced)

```lean
-- Line 365: NormalFormIdx stays in MonadicFO.lean (still useful for Fin-based counting)
abbrev NormalFormIdx (sig : MonadicSignature) (k n : Nat) :=
  Fin (nfCount (Fintype.card sig.preds) k n)

-- Line 383: KType currently uses NormalFormIdx
abbrev KType (sig : MonadicSignature) (k : Nat) : Type :=
  NormalFormIdx sig k 0 → Bool

-- Lines 400-404: nf_rep (vacuous Classical.choice) -- DELETE
noncomputable def nf_rep (sig : MonadicSignature) (k : Nat) :
    NormalFormIdx sig k 0 → MonadicFormula sig 0 :=
  Classical.choice ⟨fun _ => ...⟩

-- Lines 414-416: k_type_of uses nf_rep + eval
noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun i => @decide (eval M Fin.elim0 (nf_rep sig k i)) (Classical.dec _)
```

### New Definitions (in NEquivalence.lean, importing NormalForm.lean)

```lean
-- KType now maps NormalForm (concrete, fintype) to Bool
abbrev KType (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 0 → Bool

-- k_type_of uses nf_eval_nf (concrete semantic evaluation)
noncomputable def k_type_of (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) : KType sig k :=
  fun nf => @decide (nf_eval_nf M k 0 Fin.elim0 nf) (Classical.dec _)

-- nf_rep is DELETED (no longer needed)

-- k_equiv unchanged API
def k_equiv (sig : MonadicSignature) (k : Nat)
    (M N : OrderedMonadicStructure sig) : Prop :=
  k_type_of sig k M = k_type_of sig k N

-- k_equiv_iff_same_type unchanged
theorem k_equiv_iff_same_type ... := by rfl
```

### Fintype Verification

`NormalForm sig k 0` is `Fintype` by `normalForm_fintype` (NormalForm.lean, line 167).
`NormalForm sig k 0 -> Bool` is `Fintype` since `NormalForm sig k 0` is `Fintype` and `DecidableEq`.
Thus `KType sig k` is `Fintype` via `inferInstance`.

The `finite_types` proof in the `KEquivalenceFramework` instance is unchanged:
```lean
finite_types k := by
  have h_inj : Function.Injective
      (Quotient.lift (k_type_of sig k) ...) := by ...
  exact Fintype.ofInjective _ h_inj
```

The injectivity argument works because `k_equiv` is still defined as `k_type_of M = k_type_of N`, and `Quotient.sound` yields the equality. The target type `KType sig k` is still `Fintype`. No change to the proof body.

## Section 4: k_equiv_monotone Proof Design

### Bridge Lemma: decide_eq_decide

From `Init.PropLemmas` (verified available):
```lean
theorem decide_eq_decide {p q : Prop} {x : Decidable p} {x_1 : Decidable q} :
    decide p = decide q ↔ (p ↔ q)
```

### Proof Sketch

```lean
theorem k_equiv_monotone (sig : MonadicSignature) {k m : Nat}
    {M N : OrderedMonadicStructure sig}
    (hkm : m ≤ k) (h_equiv : k_equiv sig k M N) : k_equiv sig m M N := by
  -- h_equiv : k_type_of sig k M = k_type_of sig k N
  -- i.e. (fun nf => decide (nf_eval_nf M k 0 Fin.elim0 nf))
  --    = (fun nf => decide (nf_eval_nf N k 0 Fin.elim0 nf))
  --
  -- Goal: k_type_of sig m M = k_type_of sig m N
  -- i.e. (fun nf => decide (nf_eval_nf M m 0 Fin.elim0 nf))
  --    = (fun nf => decide (nf_eval_nf N m 0 Fin.elim0 nf))
  unfold k_equiv k_type_of at h_equiv ⊢
  funext nf_m
  -- Step 1: Convert depth-k hypothesis from decide equality to Iff
  have h_agree_k : ∀ nf : NormalForm sig k 0,
      nf_eval_nf M k 0 Fin.elim0 nf ↔ nf_eval_nf N k 0 Fin.elim0 nf := by
    intro nf
    have := congr_fun h_equiv nf
    rwa [decide_eq_decide] at this
  -- Step 2: Apply nf_agreement_monotone (NormalForm.lean, line 329)
  have h_agree_m := nf_agreement_monotone m k 0 hkm M Fin.elim0 N Fin.elim0 h_agree_k nf_m
  -- Step 3: Convert back from Iff to decide equality
  rw [decide_eq_decide]
  exact h_agree_m
```

### Dependency Chain

```
k_equiv_monotone
  ├── k_equiv (definition, same file)
  ├── k_type_of (definition, same file, uses nf_eval_nf from NormalForm.lean)
  ├── decide_eq_decide (Init.PropLemmas, universally available)
  └── nf_agreement_monotone (NormalForm.lean, line 329, 0 sorries)
       ├── nf_exists_unique (NormalForm.lean, line 267)
       ├── nf_eval_unique (NormalForm.lean, line 235)
       ├── nf_characteristic_satisfies (NormalForm.lean, line 214)
       └── atom_agreement_from_nf (NormalForm.lean, line 305)
```

All dependencies are sorry-free. The proof is self-contained.

## Section 5: Precise File Layouts After Split

### MonadicFO.lean (NEW, ~330 lines)

```
import Mathlib.Data.Fintype.Card
import Mathlib.Order.SuccPred.Basic
import Mathlib.Data.Fin.Tuple.Basic

/-! # Monadic First-Order Logic over Linear Orders ... -/

namespace Bimodal.Metalogic.WeakCanonical

-- Lines from NEquivalence.lean 51-366:
structure MonadicSignature ...             -- L51-59
inductive MonadicFormula ...               -- L61-95
structure MonadicStructure ...             -- L97-107
structure OrderedMonadicStructure ...      -- L108-191
structure ZStructure ...                   -- L193-216
def eval ...                               -- L218-235
def finLift ...                            -- L237-245
def MonadicFormula.lift ...                -- L256-263
def MonadicFormula.weaken ...              -- L272-274
def insertEnv ...                          -- L282-288
theorem insertEnv_zero_eq_cons ... sorry   -- L292-294 (task 141)
theorem insertEnv_succ_cons ... sorry      -- L301-304 (task 141)
private theorem insertEnv_finLift ... sorry -- L307-310 (task 141)
theorem lift_eval ... sorry                -- L313-317 (task 141)
theorem weaken_eval ...                    -- L327-332
def atomCount ...                          -- L342
def nfCount ...                            -- L351-353
theorem nfCount_pos ...                    -- L356-359
abbrev NormalFormIdx ...                   -- L365-366

end Bimodal.Metalogic.WeakCanonical
```

### NormalForm.lean (MODIFIED import only)

```
import Bimodal.Metalogic.WeakCanonical.MonadicFO  -- CHANGED from NEquivalence

-- Rest unchanged (572 lines, 0 sorries)
```

### NEquivalence.lean (REDUCED to ~180 lines)

```
import Bimodal.Metalogic.WeakCanonical.MonadicFO        -- NEW
import Bimodal.Metalogic.WeakCanonical.NormalForm        -- NEW (breaks cycle)
import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical -- KEPT
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction -- KEPT

/-! # k-Equivalence Framework ... (updated docstring) -/

namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem

/-! ## k-Types and k-Equivalence -/
abbrev KType ...                           -- REWRITTEN (NormalForm-based)
-- nf_rep DELETED
noncomputable def k_type_of ...            -- REWRITTEN (nf_eval_nf-based)
def k_equiv ...                            -- UNCHANGED
theorem k_equiv_iff_same_type ...          -- UNCHANGED
theorem k_equiv_monotone ...               -- CLOSED (was sorry)

/-! ## K-Equivalence Framework (Typeclass) -/
class KEquivalenceFramework ...            -- UNCHANGED
noncomputable instance ...                 -- finite_types STILL CLOSED

/-! ## Chronicle As Monadic Structure Converter -/
def chronicleAsMonadicStructure ...        -- UNCHANGED
instance chronicleAsMonadicStructure_countable ...  -- UNCHANGED
-- (all chronicle instances unchanged)

end Bimodal.Metalogic.WeakCanonical
```

### Table.lean (MODIFIED import only)

```
import Bimodal.Metalogic.WeakCanonical.MonadicFO  -- CHANGED from NEquivalence

-- Rest unchanged (304 lines)
```

### WeakCanonical.lean (ADD MonadicFO import)

```
import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.TruthLemma
import Bimodal.Metalogic.WeakCanonical.FrameProperties
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Bimodal.Metalogic.WeakCanonical.MonadicFO        -- NEW
import Bimodal.Metalogic.WeakCanonical.NEquivalence
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.WeakCanonical.Table
import Bimodal.Metalogic.WeakCanonical.IntegerModel
import Bimodal.Metalogic.WeakCanonical.Transfer
```

## Section 6: Import Graph (Post-Split)

```
                    Mathlib.*
                       |
                  MonadicFO.lean
                   /          \
          NormalForm.lean   Table.lean
                |
           NEquivalence.lean  <--- also imports ReflexiveCanonical, ChronicleExtraction
           /           \
   OrderedSum.lean    (others transitively)
        |
   IntegerModel.lean  <--- also imports Table, ChronicleExtraction
        |
    Transfer.lean
```

**Cycle broken**: NormalForm.lean no longer imports NEquivalence.lean. NEquivalence.lean imports NormalForm.lean.

## Section 7: Sorry Inventory (Post-Split)

### MonadicFO.lean (4 sorries -- all task 141)

| Line | Definition | Sorry Reason |
|------|-----------|--------------|
| ~294 | `insertEnv_zero_eq_cons` | Task 141 |
| ~304 | `insertEnv_succ_cons` | Task 141 |
| ~310 | `insertEnv_finLift` | Task 141 |
| ~317 | `lift_eval` | Task 141 |

### NEquivalence.lean (3 sorries -- unchanged)

| Definition | Sorry Reason |
|-----------|--------------|
| `KEquivalenceFramework.sum_preservation` (2x `carrier_order`) | Sigma lexicographic order construction |
| `KEquivalenceFramework.sum_preservation` (1x body) | Doets Lemma 1.4 EF-game formalization |

### Closed by this task

| Definition | Was | Becomes |
|-----------|-----|---------|
| `k_equiv_monotone` | sorry | Proved via `nf_agreement_monotone` |

### Net sorry change: -1 (from 8 to 7 in NEquivalence + MonadicFO combined)

## Section 8: Risk Analysis

### Risk 1: MonadicFO.lean Mathlib imports insufficient

**Probability**: Low (verified via `lean_run_code`).

**Evidence**: All three imports (`Fintype.Card`, `SuccPred.Basic`, `Fin.Tuple.Basic`) were tested and provide `Fintype`, `SuccOrder`, `Order.succ`, `Fin.cons`, `Finset.mem_singleton`, `LinearOrder`, `Subtype` linear order.

**Mitigation**: If a rare import is missing, add it to MonadicFO.lean. Since it's a leaf in the import graph, this cannot cause cycles.

### Risk 2: finite_types proof breaks after KType domain change

**Probability**: Very low.

**Evidence**: The proof uses `Fintype.ofInjective` with injection from quotient into `KType sig k`. The injectivity argument is:
```lean
Quotient.lift (k_type_of sig k) (fun M N (h : k_equiv sig k M N) => h)
```
Since `k_equiv` is still `k_type_of M = k_type_of N`, the lift is well-defined and injective by the same argument. The target `KType sig k = NormalForm sig k 0 -> Bool` is `Fintype` because `NormalForm sig k 0` is `Fintype` and `DecidableEq`.

**Mitigation**: If `inferInstance` doesn't fire for `Fintype (NormalForm sig k 0 -> Bool)`, explicitly provide `haveI : Fintype (NormalForm sig k 0) := normalForm_fintype sig k 0`.

### Risk 3: k_equiv_monotone proof doesn't typecheck

**Probability**: Low.

**Evidence**: `decide_eq_decide` is in `Init.PropLemmas` (verified). `nf_agreement_monotone` has exactly the right type signature. The bridge is: `congr_fun h_equiv nf` gives `decide ... = decide ...`, `decide_eq_decide.mp` gives `↔`, apply `nf_agreement_monotone`, then `decide_eq_decide.mpr` converts back.

**Mitigation**: If `unfold` doesn't fully reduce, use `simp only [k_equiv, k_type_of]` or `show ... = ...` with explicit types.

### Risk 4: Table.lean fails with MonadicFO import

**Probability**: Very low.

**Evidence**: Table.lean uses only: `MonadicSignature`, `MonadicFormula`, `OrderedMonadicStructure`, `eval`, `insertEnv`, `lift_eval`, `MonadicFormula.lift`, `MonadicFormula.quantifier_depth`. All move to MonadicFO.lean. Table.lean also uses `open Bimodal.Syntax` and `open Bimodal.ProofSystem` which import `Formula` from the Bimodal syntax module -- these are Table.lean's own opens, not from NEquivalence.

**Note**: Table.lean has `import Bimodal.Metalogic.WeakCanonical.NEquivalence` at line 1 which also brings in `Bimodal.Syntax` transitively (via `ReflexiveCanonical` -> ... -> `Syntax`). After changing to `MonadicFO`, this transitive chain is broken. Table.lean needs `Formula` from `Bimodal.Syntax` for its own `operator_depth` and `table` functions. **Table.lean will need an additional import of `Bimodal.Syntax.Formula` or similar.**

**CRITICAL DISCOVERY**: Table.lean's `operator_depth` (line 43) and `table` (line 91) use `Formula` (the temporal formula type from `Bimodal.Syntax`). This is NOT in MonadicFO.lean. Table.lean's `open Bimodal.Syntax` at line 28 provides this, but the import that brings `Bimodal.Syntax` into scope was previously transitive via NEquivalence -> ReflexiveCanonical -> ... -> Syntax. After the split, MonadicFO.lean does not import Bimodal.Syntax.

**Fix**: Table.lean must add `import Bimodal.Syntax.Formula` (or `import Bimodal.Syntax`) alongside `import MonadicFO`.

## Section 9: Implementation Order

### Phase 1: Create MonadicFO.lean

1. Create `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean`
2. Add three Mathlib imports
3. Copy lines 46-366 from NEquivalence.lean (namespace, MonadicSignature through NormalFormIdx)
4. **Do NOT copy** lines 48-49 (`open Bimodal.Syntax`, `open Bimodal.ProofSystem`) -- not needed
5. Add `end Bimodal.Metalogic.WeakCanonical` at end
6. Run `lake build Bimodal.Metalogic.WeakCanonical.MonadicFO`

### Phase 2: Rewire NormalForm.lean

1. Change import from `NEquivalence` to `MonadicFO`
2. Update module docstring (remove "core definitions live in NEquivalence" reference)
3. Run `lake build Bimodal.Metalogic.WeakCanonical.NormalForm`

### Phase 3: Rewire Table.lean

1. Change import from `NEquivalence` to `MonadicFO`
2. Add `import Bimodal.Syntax.Formula` (or whichever module provides `Formula`)
3. Run `lake build Bimodal.Metalogic.WeakCanonical.Table`

### Phase 4: Rewrite NEquivalence.lean

1. Replace imports: add MonadicFO + NormalForm, keep ReflexiveCanonical + ChronicleExtraction, remove Mathlib.Data.Finset.Basic
2. Remove lines 46-366 (extracted to MonadicFO)
3. Keep `open Bimodal.Syntax` and `open Bimodal.ProofSystem`
4. Rewrite KType: `NormalForm sig k 0 -> Bool` (was `NormalFormIdx sig k 0 -> Bool`)
5. Delete `nf_rep`
6. Rewrite `k_type_of`: use `nf_eval_nf` instead of `nf_rep` + `eval`
7. Close `k_equiv_monotone` using proof from Section 4
8. Verify `finite_types` still compiles
9. Run `lake build Bimodal.Metalogic.WeakCanonical.NEquivalence`

### Phase 5: Update WeakCanonical.lean

1. Add `import Bimodal.Metalogic.WeakCanonical.MonadicFO`
2. Run `lake build`

### Phase 6: Full Build Verification

1. `lake build` (full project)
2. Verify no new sorries introduced
3. Verify `k_equiv_monotone` sorry removed
4. Verify `finite_types` remains closed

## Section 10: Legacy Definitions in NormalForm.lean

NormalForm.lean contains legacy definitions at lines 412-430:

```lean
noncomputable def nf_eval (sig ...) ... := Classical.choice ...
noncomputable def nf_vector (sig ...) ... := fun idx => @decide (nf_eval ...) ...
```

These use `NormalFormIdx` (which stays in MonadicFO.lean). They are legacy placeholders that will be removed in "Phase 10" per their docstrings. **These can remain as-is during this task** since they compile with MonadicFO.lean's `NormalFormIdx` and are not referenced by anything in the codebase.

However, once `KType` is redefined as `NormalForm sig k 0 -> Bool`, the comment "will be replaced when KType domain switches" becomes resolved. A cleanup pass could delete them, but this is optional for task 145.

## Appendix: Verification Commands Run

1. `lean_run_code` with `import Mathlib.Data.Fintype.Card; import Mathlib.Order.SuccPred.Basic; import Mathlib.Data.Fin.Tuple.Basic` -- verified all needed types available
2. `lean_loogle` for `decide_eq_decide` -- found in `Init.PropLemmas`
3. `grep` for all symbol references across 7 files -- confirmed no hidden dependencies
4. Import chain traced: ReflexiveCanonical -> MCSProperties, MaximalConsistent, TemporalContent, ... (deep Mathlib chain not needed by pure FO section)
