# Research Report 002: Removal Plan for MCS-Membership Validity Definition

**Task**: 930 - Verify correctness of MCS-membership box semantics
**Session**: sess_1772070540_7d6e78
**Date**: 2026-02-25
**Purpose**: Identify all code depending on `bmcs_valid_mcs` / `bmcs_truth_at_mcs`, analyze the fundamental obstruction, and produce a concrete plan to REMOVE the MCS-membership validity definition from the metalogic.

## 1. Dependency Analysis

### 1.1 Scope of `_mcs` Definitions

ALL `_mcs` definitions and theorems are **self-contained within a single file**:

**File**: `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean`

No other Lean file imports or references any `_mcs` symbol. The file itself is not imported by any other `.lean` file (it appears only in a documentation comment in `Metalogic.lean`).

### 1.2 Complete Inventory of `_mcs` Symbols (lines 350-691)

| Symbol | Kind | Line | Description |
|--------|------|------|-------------|
| `bmcs_truth_at_mcs` | **def** | 357 | Modified truth predicate (Box via MCS membership) |
| `bmcs_truth_mcs_neg` | theorem | 369 | Negation truth for modified semantics |
| `bmcs_truth_lemma_mcs` | theorem | 383 | Truth lemma for modified semantics |
| `bmcs_representation_mcs` | theorem | 483 | Representation theorem using modified truth |
| `bmcs_context_representation_mcs` | theorem | 497 | Context representation using modified truth |
| `bmcs_valid_mcs` | **def** | 533 | Validity notion using modified truth |
| `bmcs_consequence_mcs` | **def** | 542 | Consequence relation using modified truth |
| `ContextDerivable_mcs` | **def** | 551 | Context derivability (duplicate of existing) |
| `not_derivable_implies_neg_consistent_mcs` | lemma | 563 | Helper (duplicate of Completeness.lean) |
| `bmcs_not_valid_mcs_of_not_derivable` | theorem | 583 | Contrapositive weak completeness |
| `bmcs_weak_completeness_mcs` | theorem | 601 | Weak completeness (modified) |
| `context_not_derivable_implies_extended_consistent_mcs` | lemma | 609 | Helper (duplicate) |
| `bmcs_not_consequence_mcs_of_not_derivable` | theorem | 632 | Contrapositive strong completeness |
| `bmcs_strong_completeness_mcs` | theorem | 655 | Strong completeness (modified) |

**Total**: 3 definitions + 11 theorems/lemmas to remove.

### 1.3 Non-`_mcs` Code in ChainBundleBFMCS.lean (lines 1-349)

The first half of the file contains **reusable construction code** that is NOT tied to the `_mcs` truth predicate:

| Symbol | Kind | Line | Reusable? |
|--------|------|------|-----------|
| `MCSBoxContent_reverse_of_CanonicalR` | theorem | 66 | YES |
| `MCSBoxContent_eq_of_CanonicalR` | theorem | 91 | YES |
| `MCSBoxContent_eq_of_superset` | theorem | 103 | YES |
| `CanonicalBC` | structure | 138 | YES |
| `Preorder (CanonicalBC BC)` | instance | 149 | YES |
| `canonicalBCBFMCS` | def | 161 | YES |
| `canonicalBC_forward_F` | theorem | 175 | YES |
| `canonicalBC_backward_P` | theorem | 188 | YES |
| `constantBCFamily` | def | 207 | YES |
| `chainBundleFamilies` | def | 228 | YES |
| `evalFamily_mem` | lemma | 233 | YES |
| `constantFamily_mem` | lemma | 237 | YES |
| `chainBundle_boxcontent_eq` | theorem | 245 | YES |
| `chainBundle_modal_forward` | theorem | 256 | YES |
| `chainBundle_modally_saturated` | theorem | 289 | YES |
| `chainBundle_modal_backward` | theorem | 311 | YES |
| `chainBundleBFMCS` | def | 338 | YES |
| `chainBundleBFMCS_modally_saturated` | theorem | 346 | YES |
| `fully_saturated_bfmcs_exists_CanonicalBC` | theorem | 456 | YES (KEY) |

These are the valuable constructions. The `CanonicalBC`-based BFMCS is a legitimate and sorry-free construction.

## 2. Obstruction Analysis: Why `bmcs_truth_at_mcs` Was Created

### 2.1 The Two Truth Predicates Compared

**Standard (`bmcs_truth_at`, BFMCSTruth.lean:87)**:
```lean
| Formula.box φ => ∀ fam' ∈ B.families, bmcs_truth_at B fam' t φ
```

**Modified (`bmcs_truth_at_mcs`, ChainBundleBFMCS.lean:357)**:
```lean
| Formula.box φ => ∀ fam' ∈ B.families, φ ∈ fam'.mcs t
```

The ONLY difference is in the **box case**: the standard version recurses into `bmcs_truth_at` (semantic truth) while the modified version short-circuits to syntactic MCS membership.

### 2.2 Why This Matters for the Truth Lemma

The standard truth lemma (`bmcs_truth_lemma` in TruthLemma.lean) proves:
```
φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ
```

In the **box case backward direction**, it must show:
```
(∀ fam' ∈ B.families, bmcs_truth_at B fam' t ψ) → Box ψ ∈ fam.mcs t
```

The proof applies the IH to each `fam'`:
```lean
have h_ψ_all_mcs : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
  intro fam' hfam'
  exact (ih fam' hfam' t).mpr (h_all fam' hfam')
```

This requires the IH applied at `fam'` -- meaning the truth lemma must hold for ALL families in the bundle. The standard truth lemma requires `B.temporally_coherent` which demands ALL families satisfy `forward_F` and `backward_P`.

### 2.3 The Fundamental Obstruction

The `chainBundleBFMCS` construction contains **constant witness families** (`constantBCFamily`). A constant family maps every time point to the same MCS `N`.

For a constant family to satisfy `forward_F`:
```
F(psi) ∈ N → ∃ s ≥ t, psi ∈ N
```
Since the family is constant (same `N` at all times), this simplifies to:
```
F(psi) ∈ N → psi ∈ N
```

This requires `N` to be **temporally forward-saturated**. But the witness MCSes in `chainBundle_modally_saturated` are created via Lindenbaum extension of `{psi} ∪ MCSBoxContent(fam.mcs t)`, with NO guarantee of temporal saturation.

**Summary**: The constant witness families in `chainBundleBFMCS` are NOT temporally coherent, so the standard truth lemma (`bmcs_truth_lemma`) CANNOT be applied to this construction.

### 2.4 Why `bmcs_truth_at_mcs` Bypasses This

The modified truth predicate's box case does NOT recurse into semantic truth -- it directly checks MCS membership. The modified truth lemma (`bmcs_truth_lemma_mcs`) therefore only needs temporal coherence for the **evaluated family** (the `fam` parameter), not for ALL families.

Concretely, `bmcs_truth_lemma_mcs` has signature:
```lean
theorem bmcs_truth_lemma_mcs (B : BFMCS D)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (h_forward_F : ∀ t, ∀ φ, F φ ∈ fam.mcs t → ∃ s, t ≤ s ∧ φ ∈ fam.mcs s)
    (h_backward_P : ∀ t, ∀ φ, P φ ∈ fam.mcs t → ∃ s, s ≤ t ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula) :
    φ ∈ fam.mcs t ↔ bmcs_truth_at_mcs B fam t φ
```

Only `fam` needs `forward_F`/`backward_P`, not the witness families. Since the eval family (`canonicalBCBFMCS`) IS temporally coherent (via `canonicalBC_forward_F` and `canonicalBC_backward_P`), the truth lemma goes through.

## 3. Deletion Plan

### 3.1 Items to DELETE (from ChainBundleBFMCS.lean)

Delete lines 350-691 (everything after the `chainBundleBFMCS_modally_saturated` theorem). This removes:

1. `bmcs_truth_at_mcs` (def)
2. `bmcs_truth_mcs_neg` (theorem)
3. `bmcs_truth_lemma_mcs` (theorem)
4. `bmcs_representation_mcs` (theorem)
5. `bmcs_context_representation_mcs` (theorem)
6. `bmcs_valid_mcs` (def)
7. `bmcs_consequence_mcs` (def)
8. `ContextDerivable_mcs` (def)
9. `not_derivable_implies_neg_consistent_mcs` (lemma)
10. `bmcs_not_valid_mcs_of_not_derivable` (theorem)
11. `bmcs_weak_completeness_mcs` (theorem)
12. `context_not_derivable_implies_extended_consistent_mcs` (lemma)
13. `bmcs_not_consequence_mcs_of_not_derivable` (theorem)
14. `bmcs_strong_completeness_mcs` (theorem)
15. The "Summary" documentation section at the end

Also delete the references to `_mcs` in the module docstring (lines 10-51).

### 3.2 Items to KEEP (in ChainBundleBFMCS.lean)

Keep lines 1-349 (all `CanonicalBC`, `chainBundleBFMCS`, saturation infrastructure). These are valuable, reusable, and NOT tied to any alternative validity notion.

### 3.3 Items to REFACTOR

The `fully_saturated_bfmcs_exists_CanonicalBC` theorem (line 456) is currently used only by the `_mcs` completeness chain. After deletion, it would become an orphan. However, it is a valuable theorem that proves the existence of a BFMCS construction. It should be:

- **Kept** in ChainBundleBFMCS.lean as a standalone result
- **Annotated** as a construction that can feed into the standard completeness chain once the temporal coherence gap is resolved

### 3.4 Documentation Updates

Update the module docstring to describe ChainBundleBFMCS.lean as:
- A construction module providing `chainBundleBFMCS` (sorry-free, modally saturated)
- NOT a completeness proof (completeness uses `Completeness.lean` with standard `bmcs_valid`)
- The construction's value: it demonstrates that a sorry-free BFMCS exists over `CanonicalBC`, and achieves modal saturation without sorry

## 4. Repair Strategy: Standard Validity Completeness

### 4.1 Current State of Standard Completeness Chain

`Completeness.lean` already proves completeness with the STANDARD validity notion (`bmcs_valid` from `BFMCSTruth.lean`). This chain is:

```
bmcs_representation -> bmcs_weak_completeness -> bmcs_strong_completeness
```

These theorems use `construct_saturated_bfmcs_int` which relies on `fully_saturated_bfmcs_exists_int` -- a **sorry-backed theorem** (TemporalCoherentConstruction.lean:797). The sorry exists because combining temporal coherence AND modal saturation simultaneously is the fundamental open problem.

### 4.2 What the Sorry Blocks

`fully_saturated_bfmcs_exists_int` claims that for any consistent context, there exists a BFMCS that is:
1. Temporally coherent (ALL families have `forward_F` and `backward_P`)
2. Modally saturated (every diamond has a witness)
3. Contains the context at the eval family at time 0

The sorry is because:
- Modal saturation creates constant witness families
- Constant witness families need temporally saturated MCSes for temporal coherence
- Building temporally saturated MCSes is a separate non-trivial construction

### 4.3 Path Forward: How to Resolve the Sorry

There are two viable approaches to making the standard chain sorry-free:

**Approach A: Make Witness Families Temporally Coherent**

Modify the modal saturation construction so that witness families are NOT constant but are instead temporally coherent. This requires:
1. For each diamond witness `psi`, build a full `TemporalCoherentFamily` (not just a constant family)
2. Each witness family needs its own dovetailing chain construction
3. This is the "InterleaveConstruction" approach mentioned in TemporalCoherentConstruction.lean

Effort: HIGH -- requires new construction infrastructure

**Approach B: Weaken Truth Lemma Temporal Coherence Requirement**

Modify `bmcs_truth_lemma` to only require temporal coherence of the evaluated family (similar to what `bmcs_truth_lemma_mcs` does, but WITHOUT changing the truth predicate).

This would mean the standard truth lemma becomes:
```lean
theorem bmcs_truth_lemma (B : BFMCS D)
    (fam : FMCS D) (hfam : fam ∈ B.families)
    (h_forward_F : ∀ t, ∀ φ, F φ ∈ fam.mcs t → ∃ s, t ≤ s ∧ φ ∈ fam.mcs s)
    (h_backward_P : ∀ t, ∀ φ, P φ ∈ fam.mcs t → ∃ s, s ≤ t ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula) :
    φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ
```

**CRITICAL QUESTION**: Can this work? The standard truth lemma's box case (backward direction) applies the IH at OTHER families:
```lean
exact (ih fam' hfam' t).mpr (h_all fam' hfam')
```

This requires the truth lemma to hold for `fam'`, which means `fam'` must also be temporally coherent. So we CANNOT simply weaken the requirement to per-family temporal coherence while keeping the standard `bmcs_truth_at`.

**This is why `bmcs_truth_at_mcs` was invented**: it breaks the mutual recursion between semantic truth and the box quantifier. With `bmcs_truth_at_mcs`, the box case's IH goes from `bmcs_truth_at_mcs` to MCS membership directly, not needing to apply the truth lemma to other families.

**Approach C: The Only Clean Solution**

Since the standard `bmcs_truth_at` requires temporal coherence of ALL families for the truth lemma, the only clean path is **Approach A**: make ALL witness families temporally coherent.

Concretely:
1. Resolve the sorry in `fully_saturated_bfmcs_exists_int` (TemporalCoherentConstruction.lean:797)
2. This is the SAME sorry that blocks the standard completeness chain
3. Once this sorry is resolved, the standard chain is complete, and the `_mcs` chain is entirely redundant

### 4.4 Impact of Deleting `_mcs` Chain

After deletion:
- The project loses its "sorry-free" completeness claim (the `_mcs` chain was the only sorry-free completeness)
- The standard chain (Completeness.lean) remains sorry-backed via `fully_saturated_bfmcs_exists_int`
- The `chainBundleBFMCS` construction remains as a valuable building block

This is the **correct** state: the project should honestly reflect that it has ONE completeness notion (`bmcs_valid` from standard `bmcs_truth_at`, which is structurally equivalent to `valid` from Kripke semantics) and that the completeness proof has a sorry to resolve.

## 5. Effort Estimate

### 5.1 Deletion (Task 930)

| Action | Effort |
|--------|--------|
| Delete `_mcs` definitions/theorems (lines 350-691) | 15 minutes |
| Update module docstring | 10 minutes |
| Update TODO.md / state.json | 5 minutes |
| Verify `lake build` passes | 5 minutes |
| **Total** | **~35 minutes** |

### 5.2 Resolving the Sorry (Separate Future Task)

| Action | Effort |
|--------|--------|
| Resolve `fully_saturated_bfmcs_exists_int` sorry | MAJOR (days-weeks) |
| Core difficulty: making witness families temporally coherent | Research + implementation |
| DovetailingChain forward_F/backward_P sorries | Part of the same problem |

The sorry resolution is a separate, larger task and should NOT block the cleanup deletion.

## 6. Recommendations

1. **DELETE all `_mcs` definitions and theorems** from `ChainBundleBFMCS.lean` (lines 350-691 plus docstring references). This is safe because no other code depends on them.

2. **KEEP the `CanonicalBC` construction** (lines 1-349) including `chainBundleBFMCS`, `fully_saturated_bfmcs_exists_CanonicalBC`, and all modal saturation infrastructure. These are sorry-free and reusable.

3. **RENAME the file** to better reflect its reduced scope (e.g., `CanonicalBCConstruction.lean` or keep as-is with updated docstring).

4. **Accept the sorry in `fully_saturated_bfmcs_exists_int`** as the honest state of the proof. The standard completeness chain is the authoritative chain.

5. **Create a follow-up task** to resolve `fully_saturated_bfmcs_exists_int` by making witness families temporally coherent (this is the true open problem, not the `_mcs` workaround).

## 7. Files Examined

| File | Path | Relevance |
|------|------|-----------|
| ChainBundleBFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` | Primary target - contains all `_mcs` definitions |
| BFMCSTruth.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` | Standard truth predicate (`bmcs_truth_at`) |
| TruthLemma.lean | `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` | Standard truth lemma (requires `temporally_coherent`) |
| Completeness.lean | `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | Standard completeness chain (sorry-backed) |
| Validity.lean | `Theories/Bimodal/Semantics/Validity.lean` | Authoritative Kripke validity (`valid`) |
| BFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` | BFMCS structure definition |
| TemporalCoherentConstruction.lean | `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` | `fully_saturated_bfmcs_exists_int` sorry location |
| Truth.lean | `Theories/Bimodal/Semantics/Truth.lean` | Standard Kripke truth (`truth_at`) |
