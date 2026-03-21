# Research Report 001: Remove Non-Standard MCS-Membership Validity from Metalogic

**Task**: 931 - remove_bmcs_truth_lemma_mcs_nonstandard_validity
**Session**: sess_1740494500_r931
**Date**: 2026-02-25
**Purpose**: Identify all non-standard validity definitions, build dependency graph, determine safe removal order, and recommend Boneyard format.

## 1. Identification of All Non-Standard Definitions

### 1.1 The Standard Validity Semantics

The authoritative truth and validity definitions are in `Bimodal.Semantics`:

| Definition | File | Nature |
|-----------|------|--------|
| `truth_at` | `Theories/Bimodal/Semantics/Truth.lean` | Kripke truth over TaskFrame/TaskModel/WorldHistory |
| `valid` | `Theories/Bimodal/Semantics/Validity.lean:71` | Universal validity over all models/histories/times |
| `semantic_consequence` | `Theories/Bimodal/Semantics/Validity.lean:94` | Semantic consequence |

The Henkin-style `bmcs_truth_at` (BFMCSTruth.lean:87) is a legitimate intermediate definition used in the completeness proof. Its box case is `∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ` -- standard recursive truth restricted to bundle families. This is the standard BFMCS approach and should be KEPT.

### 1.2 Non-Standard Definitions (MCS-Membership Box Semantics)

ALL non-standard definitions are in a single file:

**File**: `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean`

The non-standard approach replaces recursive truth in the box case with direct MCS membership:
- **Standard**: `| Formula.box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi`
- **Non-standard**: `| Formula.box phi => forall fam' in B.families, phi in fam'.mcs t`

### 1.3 Complete Inventory of Non-Standard Symbols

All definitions are on lines 350-691 of ChainBundleBFMCS.lean:

| Symbol | Kind | Line | Description |
|--------|------|------|-------------|
| `bmcs_truth_at_mcs` | **def** | 357 | Modified truth predicate (Box via MCS membership) |
| `bmcs_truth_mcs_neg` | theorem | 369 | Negation truth for modified semantics |
| `bmcs_truth_lemma_mcs` | theorem | 383 | Truth lemma for modified semantics |
| `bmcs_representation_mcs` | theorem | 483 | Representation theorem using modified truth |
| `bmcs_context_representation_mcs` | theorem | 497 | Context representation using modified truth |
| `bmcs_valid_mcs` | **def** | 533 | Validity using modified truth |
| `bmcs_consequence_mcs` | **def** | 542 | Consequence relation using modified truth |
| `ContextDerivable_mcs` | **def** | 551 | Context derivability (duplicate of Completeness.lean's `ContextDerivable`) |
| `not_derivable_implies_neg_consistent_mcs` | lemma | 561 | Helper (duplicate of Completeness.lean) |
| `bmcs_not_valid_mcs_of_not_derivable` | theorem | 583 | Contrapositive weak completeness (modified) |
| `bmcs_weak_completeness_mcs` | theorem | 601 | Weak completeness (modified validity) |
| `context_not_derivable_implies_extended_consistent_mcs` | lemma | 609 | Helper (duplicate of Completeness.lean) |
| `bmcs_not_consequence_mcs_of_not_derivable` | theorem | 632 | Contrapositive strong completeness (modified) |
| `bmcs_strong_completeness_mcs` | theorem | 655 | Strong completeness (modified validity) |

**Total**: 4 definitions + 10 theorems/lemmas = 14 symbols to remove.

### 1.4 Eval-BFMCS Definitions (BFMCSTruth.lean)

These definitions in BFMCSTruth.lean use the SAME recursive truth as `bmcs_truth_at` (standard box semantics), just parameterized by `families : Set (FMCS D)` instead of a full `BFMCS D`:

| Symbol | Kind | Line | Standard? |
|--------|------|------|-----------|
| `eval_bmcs_truth_at` | def | 361 | YES (recursive truth for Box) |
| `eval_bmcs_satisfies_context` | def | 373 | YES |
| `eval_bmcs_truth_neg` | theorem | 386 | YES |
| `eval_bmcs_truth_and` | theorem | 396 | YES |
| `eval_bmcs_truth_or` | theorem | 422 | YES |
| `eval_bmcs_truth_diamond` | theorem | 441 | YES |
| `eval_bmcs_truth_box_family_independent` | theorem | 460 | YES |
| `eval_bmcs_truth_box_reflexive` | theorem | 470 | YES |

These are NOT non-standard -- they use recursive truth for Box. However, they are **dead code**: used ONLY within BFMCSTruth.lean itself (no other file references them). The corresponding `eval_bmcs_truth_lemma` was already removed in task 912. Whether to remove these as dead code is a separate decision from the non-standard validity cleanup.

## 2. Dependency Analysis

### 2.1 Dependency Graph

```
bmcs_truth_at_mcs (def, L357)
  |-- bmcs_truth_mcs_neg (L369) [uses bmcs_truth_at_mcs directly]
  |-- bmcs_truth_lemma_mcs (L383) [uses bmcs_truth_at_mcs]
  |     |-- bmcs_representation_mcs (L483) [uses bmcs_truth_lemma_mcs]
  |     |     |-- bmcs_not_valid_mcs_of_not_derivable (L583) [uses bmcs_representation_mcs]
  |     |     |     |-- bmcs_weak_completeness_mcs (L601) [uses bmcs_not_valid_mcs_of_not_derivable]
  |     |-- bmcs_context_representation_mcs (L497) [uses bmcs_truth_lemma_mcs]
  |           |-- bmcs_not_consequence_mcs_of_not_derivable (L632) [uses bmcs_context_representation_mcs]
  |                 |-- bmcs_strong_completeness_mcs (L655) [uses bmcs_not_consequence_mcs_of_not_derivable]

bmcs_valid_mcs (def, L533) [uses bmcs_truth_at_mcs]
  |-- bmcs_not_valid_mcs_of_not_derivable (L583) [target of]
  |-- bmcs_weak_completeness_mcs (L601) [input type]

bmcs_consequence_mcs (def, L542) [uses bmcs_truth_at_mcs]
  |-- bmcs_not_consequence_mcs_of_not_derivable (L632) [target of]
  |-- bmcs_strong_completeness_mcs (L655) [input type]

ContextDerivable_mcs (def, L551) [standalone duplicate]
  |-- context_not_derivable_implies_extended_consistent_mcs (L609) [uses ContextDerivable_mcs]
  |-- bmcs_not_consequence_mcs_of_not_derivable (L632) [uses ContextDerivable_mcs]
  |-- bmcs_strong_completeness_mcs (L655) [uses ContextDerivable_mcs]

not_derivable_implies_neg_consistent_mcs (L561) [standalone helper]
  |-- bmcs_not_valid_mcs_of_not_derivable (L583) [uses this]

context_not_derivable_implies_extended_consistent_mcs (L609) [standalone helper]
  |-- bmcs_not_consequence_mcs_of_not_derivable (L632) [uses this]
```

### 2.2 External Dependencies

**Zero external dependents.** No other `.lean` file in the project imports `ChainBundleBFMCS` or references any `_mcs` symbol. The file appears only in a documentation comment in `Metalogic.lean` (line 64).

### 2.3 Transitive Closure

The transitive closure of dependents of `bmcs_truth_at_mcs` is exactly the 13 symbols listed above (all 14 non-standard symbols minus `bmcs_truth_at_mcs` itself). Everything is self-contained.

## 3. What Should Remain in Metalogic

### 3.1 Standard Definitions to KEEP

| Symbol | File | Nature |
|--------|------|--------|
| `bmcs_truth_at` | BFMCSTruth.lean:87 | Standard BFMCS truth (recursive Box over bundle) |
| `bmcs_valid` | BFMCSTruth.lean:107 | Standard BFMCS validity |
| `bmcs_satisfiable_at` | BFMCSTruth.lean:114 | Standard BFMCS satisfiability |
| `bmcs_satisfies_context` | BFMCSTruth.lean:120 | Standard BFMCS context satisfaction |
| `bmcs_truth_eval` | BFMCSTruth.lean:219 | Eval shorthand |
| `bmcs_truth_lemma` | TruthLemma.lean:260 | Standard truth lemma (temporally_coherent BFMCS) |
| `bmcs_representation` | Completeness.lean:100 | Standard representation |
| `bmcs_context_representation` | Completeness.lean:121 | Standard context representation |
| `bmcs_weak_completeness` | Completeness.lean:243 | Standard weak completeness |
| `bmcs_strong_completeness` | Completeness.lean:401 | Standard strong completeness |
| `bmcs_valid_Int` | Completeness.lean:152 | Int-specific validity |
| `bmcs_consequence` | Completeness.lean:263 | Standard consequence |
| `bmcs_consequence_Int` | Completeness.lean:273 | Int-specific consequence |
| `ContextDerivable` | Completeness.lean:293 | Context derivability |

### 3.2 ChainBundleBFMCS Construction to KEEP (lines 1-349)

These definitions are the valuable, reusable, sorry-free CanonicalBC construction. They do NOT depend on any non-standard validity notion:

| Symbol | Line | Description |
|--------|------|-------------|
| `MCSBoxContent_reverse_of_CanonicalR` | 66 | BoxContent reverse preservation |
| `MCSBoxContent_eq_of_CanonicalR` | 91 | BoxContent equality along CanonicalR |
| `MCSBoxContent_eq_of_superset` | 103 | BoxContent superset equality |
| `CanonicalBC` | 138 | MCS with fixed BoxContent (structure) |
| `Preorder (CanonicalBC BC)` | 149 | Preorder instance |
| `canonicalBCBFMCS` | 161 | Eval family on CanonicalBC |
| `canonicalBC_forward_F` | 175 | Forward F for eval family |
| `canonicalBC_backward_P` | 188 | Backward P for eval family |
| `constantBCFamily` | 207 | Constant witness family on CanonicalBC |
| `chainBundleFamilies` | 228 | Bundle families set |
| `evalFamily_mem` | 233 | Eval family membership |
| `constantFamily_mem` | 237 | Constant family membership |
| `chainBundle_boxcontent_eq` | 245 | BoxContent equality in bundle |
| `chainBundle_modal_forward` | 256 | Modal forward for bundle |
| `chainBundle_modally_saturated` | 289 | Modal saturation for bundle |
| `chainBundle_modal_backward` | 311 | Modal backward for bundle |
| `chainBundleBFMCS` | 338 | The chain-bundle BFMCS definition |
| `chainBundleBFMCS_modally_saturated` | 346 | Modal saturation proof |
| `fully_saturated_bfmcs_exists_CanonicalBC` | 456 | Key existence theorem (sorry-free) |

Note: `fully_saturated_bfmcs_exists_CanonicalBC` (line 456) is CURRENTLY used only by the `_mcs` chain. After removing the `_mcs` code, it becomes an orphan but should be kept as a valuable standalone construction result.

## 4. Boneyard Analysis

### 4.1 Existing Boneyard Structure

A Boneyard already exists at `Theories/Bimodal/Boneyard/` with the following subdirectories:

```
Theories/Bimodal/Boneyard/
  Bundle/           -- 12 files (CoherentConstruction, SeedBFMCS, etc.)
  Completeness/     -- Completeness.lean
  FDSM/             -- 4 files + README.md
  FDSM_SingleHistory/ -- Core.lean
  Metalogic/        -- 2 subdirs (Completeness, Representation)
  Metalogic_v2/     -- 4 subdirs
  Metalogic_v4/     -- Completeness/
  Metalogic_v5/     -- 2 subdirs
  DurationConstruction.lean
```

### 4.2 Boneyard Format Conventions

Based on existing Boneyard files, the convention is:
1. Files are placed in the corresponding subdirectory (e.g., `Boneyard/Bundle/` for Bundle-related code)
2. Files are complete Lean files with their original imports preserved
3. Module docstrings explain why the code was moved to Boneyard
4. Imports may be commented out if they would cause build issues

### 4.3 Recommended Boneyard Location

The non-standard `_mcs` code should go to:
```
Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean
```

### 4.4 Recommended Boneyard Comment Format

```lean
/-!
# BONEYARD: MCS-Membership Box Semantics Completeness Chain

**Archived**: Task 931 (2026-02-25)
**Reason**: This code defines a non-standard validity semantics where Box uses
  MCS membership instead of recursive truth. This departs from the standard
  `truth_at`/`valid` definitions in `Bimodal.Semantics.Validity`.

**Ban Notice**: Do NOT restore or replicate this pattern. The MCS-membership
  box semantics (`bmcs_truth_at_mcs`) is semantically different from standard
  validity and produces a completeness result for the wrong notion of validity.

  Specifically:
  - Standard: `| box phi => forall fam' in families, bmcs_truth_at fam' t phi`
  - Non-standard (BANNED): `| box phi => forall fam' in families, phi in fam'.mcs t`

  The standard truth lemma must use recursive truth for Box. If the standard
  truth lemma is blocked by temporal coherence issues with witness families,
  resolve the underlying construction problem (make witness families temporally
  coherent) rather than changing the semantics.

**Original File**: Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean
**Original Lines**: 350-691
-/
```

## 5. Impact Assessment

### 5.1 Files Affected

| File | Action | Impact |
|------|--------|--------|
| `ChainBundleBFMCS.lean` | Delete lines 350-691, update module docstring | PRIMARY - remove all `_mcs` code |
| `BFMCSTruth.lean` | Optional: remove dead `eval_bmcs_*` code (lines 334-477) | SECONDARY - dead code cleanup |
| `Metalogic.lean` | Update documentation comment (line 64) | MINOR - doc update |
| `Boneyard/Bundle/MCSMembershipCompleteness.lean` | CREATE new file with archived code | NEW FILE |

### 5.2 Definitions Removed/Moved

- **4 definitions** removed from active codebase (`bmcs_truth_at_mcs`, `bmcs_valid_mcs`, `bmcs_consequence_mcs`, `ContextDerivable_mcs`)
- **10 theorems/lemmas** removed from active codebase
- All 14 symbols moved to Boneyard

### 5.3 External Dependents

- **No external dependents** in any `.lean` file
- **No test files** reference `_mcs` symbols
- The `_mcs` symbols appear only in:
  - `ChainBundleBFMCS.lean` itself (definitions + usage)
  - `specs/` markdown documentation (research reports for tasks 930, 931)
  - `Metalogic.lean` doc comment

### 5.4 Build Impact

`lake build` should succeed after removal since:
1. No other file imports `ChainBundleBFMCS`
2. The `_mcs` symbols have zero external dependents
3. The remaining code in ChainBundleBFMCS.lean (lines 1-349) does not reference `_mcs` symbols

### 5.5 Dead Code Note (eval_bmcs_*)

The `eval_bmcs_*` definitions in BFMCSTruth.lean (lines 334-477) are dead code -- used only within that file, and their corresponding truth lemma was archived in task 912. These are NOT non-standard (they use recursive truth), but they are unused. The task description does not specifically target these, but they could be cleaned up as a bonus.

## 6. Safe Removal Order

Since all `_mcs` symbols are self-contained in one file with zero external dependents, the removal order is straightforward. However, for the Boneyard copy to compile (or at least be self-documenting), the order within the file matters.

### 6.1 Recommended Implementation Steps

**Step 1**: Create Boneyard file
- Copy lines 350-691 of ChainBundleBFMCS.lean to `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean`
- Add ban comment header
- Comment out imports (the file will not compile standalone)

**Step 2**: Delete from ChainBundleBFMCS.lean
- Delete lines 350-691 (all `_mcs` code including the "Modified Truth Definition" section header and all subsequent sections)
- Delete `import Bimodal.Theorems.Propositional` from line 8 (only needed by `_mcs` code; check if still needed by remaining code)

**Step 3**: Update module docstring
- Remove references to `_mcs` symbols from the module docstring (lines 10-51)
- Update the module description to focus on the CanonicalBC construction

**Step 4**: Update Metalogic.lean
- Update the documentation comment at line 64 to reflect the file's reduced scope

**Step 5**: Verify build
- Run `lake build` to confirm no regressions

**Step 6**: (Optional) Remove dead `eval_bmcs_*` code from BFMCSTruth.lean
- Lines 334-477 are dead code
- Move to Boneyard or delete (simpler since it uses standard semantics)

### 6.2 Import Dependency Check

The remaining code in ChainBundleBFMCS.lean (lines 1-349) imports:
```lean
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.ChainFMCS
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.TruthLemma
import Bimodal.Theorems.Propositional
```

After removing the `_mcs` code:
- `import Bimodal.Metalogic.Bundle.TruthLemma` -- check if still needed (used by `fully_saturated_bfmcs_exists_CanonicalBC`? No, that theorem is self-contained. TruthLemma is NOT imported for any non-`_mcs` code. However, removing it may affect transitive imports.)
- `import Bimodal.Theorems.Propositional` -- used by `box_dne_theorem` in `chainBundle_modal_backward` (line 323). KEEP this import.
- `import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction` -- used by `TemporalCoherentFamily` in `bmcs_truth_lemma_mcs` (line 429). After removing `_mcs` code, check if any remaining code uses it. `fully_saturated_bfmcs_exists_CanonicalBC` does NOT use it. But `canonicalBC_forward_F` and `canonicalBC_backward_P` might need it indirectly. Need to verify.

Recommendation: Keep all imports initially and let `lake build` determine which can be removed.

## 7. Summary of Recommendations

1. **Create Boneyard**: Move all 14 `_mcs` symbols to `Theories/Bimodal/Boneyard/Bundle/MCSMembershipCompleteness.lean` with ban notice
2. **Delete from active code**: Remove lines 350-691 from ChainBundleBFMCS.lean
3. **Update docstrings**: Remove `_mcs` references from ChainBundleBFMCS.lean and Metalogic.lean
4. **Keep construction code**: Lines 1-349 of ChainBundleBFMCS.lean contain valuable, reusable, sorry-free construction infrastructure
5. **Verify build**: Run `lake build` after all changes
6. **Optional dead code cleanup**: Remove unused `eval_bmcs_*` from BFMCSTruth.lean (separate from the non-standard validity removal)

## 8. Files Examined

| File | Path | Role |
|------|------|------|
| ChainBundleBFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` | Primary target -- all `_mcs` definitions |
| BFMCSTruth.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` | Standard `bmcs_truth_at` + dead `eval_bmcs_*` |
| TruthLemma.lean | `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` | Standard truth lemma (KEEP) |
| Completeness.lean (Bundle) | `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | Standard completeness chain (KEEP) |
| Completeness.lean (Metalogic) | `Theories/Bimodal/Metalogic/Completeness.lean` | MCS closure properties (KEEP) |
| Validity.lean | `Theories/Bimodal/Semantics/Validity.lean` | Authoritative `valid` definition (KEEP) |
| Truth.lean | `Theories/Bimodal/Semantics/Truth.lean` | Authoritative `truth_at` definition (KEEP) |
| Metalogic.lean | `Theories/Bimodal/Metalogic/Metalogic.lean` | Module re-export (update doc comment) |
| Representation.lean | `Theories/Bimodal/Metalogic/Representation.lean` | Standard validity bridge (KEEP) |
| ModalSaturation.lean | `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` | Modal saturation (KEEP) |
| research-002.md | `specs/930_.../reports/research-002.md` | Prior analysis from task 930 |
