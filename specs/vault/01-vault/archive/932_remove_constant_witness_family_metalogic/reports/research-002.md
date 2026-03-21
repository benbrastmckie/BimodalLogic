# Research Report 002: CanonicalBC-Based Construction Removal

**Task**: 932
**Session**: sess_1772085342_149f9e
**Date**: 2026-02-25
**Focus**: Document the full CanonicalBC-based construction in ChainBundleBFMCS.lean, explain why it is incorrect, identify all definitions/theorems requiring removal, and map dependencies.

---

## Executive Summary

Research-001 incorrectly characterized the `constantBCFamily` / `CanonicalBC`-based construction in `ChainBundleBFMCS.lean` as "the correct approach." This follow-up research reveals that the ENTIRE `ChainBundleBFMCS.lean` file is built on a fundamentally flawed semantic foundation: the "MCS-membership box semantics" (`bmcs_truth_at_mcs`), which defines `Box phi` as `phi in fam'.mcs t` instead of recursively evaluating truth. This produces completeness theorems for the WRONG notion of validity -- one that does not correspond to standard Kripke semantics.

Task 931 (research-001 at `specs/931_.../reports/research-001.md`) independently identified and documented this exact problem, cataloguing all 14 non-standard `_mcs` symbols. The user's instruction confirms that the CanonicalBC construction is ALSO flawed and the ENTIRE file should be gutted.

**Key finding**: The entire ChainBundleBFMCS.lean file should be removed to Boneyard. The construction infrastructure (lines 1-349) -- while technically compiling without sorry -- is purpose-built for the flawed `bmcs_truth_at_mcs` semantics and has no consumers outside of that chain. The CanonicalBC domain, constantBCFamily, and chainBundleBFMCS are all tightly coupled to the non-standard approach.

---

## 1. What Is the CanonicalBC-Based Construction?

### 1.1 Architecture Overview

The CanonicalBC approach is a complete "parallel completeness chain" in `ChainBundleBFMCS.lean` (692 lines). It defines:

**Domain**: `CanonicalBC BC` (line 138) -- A structure pairing an MCS with a fixed "BoxContent" set BC. BoxContent is the set of all `Box(phi)` formulas in an MCS. The key idea is to group MCSes that share the same BoxContent into a common domain.

**Preorder**: CanonicalR (reflexive-transitive closure of temporal accessibility) restricted to MCSes with matching BoxContent (line 149).

**Eval Family**: `canonicalBCBFMCS BC` (line 161) -- Maps each `CanonicalBC BC` element to its own MCS (the identity mapping). This is the only non-constant family.

**Witness Families**: `constantBCFamily BC N h_mcs h_bc` (line 207) -- For each MCS N with matching BoxContent, a constant family mapping ALL time points to N. Used for modal saturation.

**Bundle**: `chainBundleBFMCS BC` (line 338) -- The BFMCS containing the eval family and all constant witness families.

### 1.2 Key Theorems

| Symbol | Line | Description |
|--------|------|-------------|
| `MCSBoxContent_reverse_of_CanonicalR` | 66 | BoxContent preserved (reverse) along CanonicalR |
| `MCSBoxContent_eq_of_CanonicalR` | 91 | BoxContent equality along CanonicalR |
| `MCSBoxContent_eq_of_superset` | 103 | BoxContent equality for supersets |
| `CanonicalBC` | 138 | MCS with fixed BoxContent (structure) |
| `canonicalBCBFMCS` | 161 | Eval family on CanonicalBC |
| `canonicalBC_forward_F` | 175 | Forward F for eval family |
| `canonicalBC_backward_P` | 188 | Backward P for eval family |
| `constantBCFamily` | 207 | Constant witness family on CanonicalBC |
| `chainBundleFamilies` | 228 | Bundle families set |
| `chainBundle_boxcontent_eq` | 245 | BoxContent equality across bundle |
| `chainBundle_modal_forward` | 256 | Modal forward |
| `chainBundle_modally_saturated` | 289 | Modal saturation |
| `chainBundle_modal_backward` | 311 | Modal backward |
| `chainBundleBFMCS` | 338 | The BFMCS definition |
| `chainBundleBFMCS_modally_saturated` | 346 | Modal saturation proof |
| `bmcs_truth_at_mcs` | 357 | **NON-STANDARD** truth predicate |
| `bmcs_truth_lemma_mcs` | 383 | Truth lemma (non-standard) |
| `fully_saturated_bfmcs_exists_CanonicalBC` | 456 | Existence theorem |
| `bmcs_representation_mcs` | 483 | Representation (non-standard) |
| `bmcs_context_representation_mcs` | 497 | Context representation (non-standard) |
| `bmcs_valid_mcs` | 533 | **NON-STANDARD** validity definition |
| `bmcs_consequence_mcs` | 542 | **NON-STANDARD** consequence definition |
| `bmcs_weak_completeness_mcs` | 601 | Weak completeness (non-standard) |
| `bmcs_strong_completeness_mcs` | 655 | Strong completeness (non-standard) |

### 1.3 What `bmcs_truth_at_mcs` Does

```lean
def bmcs_truth_at_mcs {D : Type*} [Preorder D] (B : BFMCS D) (fam : FMCS D) (t : D) :
    Formula -> Prop
  | Formula.atom p => Formula.atom p in fam.mcs t
  | Formula.bot => False
  | Formula.imp phi psi => bmcs_truth_at_mcs B fam t phi -> bmcs_truth_at_mcs B fam t psi
  | Formula.box phi => forall fam' in B.families, phi in fam'.mcs t   -- <-- THE PROBLEM
  | Formula.all_past phi => forall s, s <= t -> bmcs_truth_at_mcs B fam s phi
  | Formula.all_future phi => forall s, t <= s -> bmcs_truth_at_mcs B fam s phi
```

The Box case uses **flat MCS membership** (`phi in fam'.mcs t`) instead of **recursive truth** (`bmcs_truth_at_mcs B fam' t phi`). This is the non-standard "MCS-membership box semantics."

Compare with the standard `bmcs_truth_at` in `BFMCSTruth.lean:87`:

```lean
def bmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula -> Prop
  | ...
  | Formula.box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi  -- recursive truth
  | ...
```

---

## 2. Why Is It Incorrect?

### 2.1 The Non-Standard Semantics Problem

The MCS-membership box semantics (`bmcs_truth_at_mcs`) defines a different notion of truth than standard Kripke/BFMCS semantics. The standard truth definition is recursive: `Box phi TRUE iff phi is TRUE at all accessible worlds`, where truth is evaluated recursively. The modified definition collapses the Box case to: `Box phi TRUE iff phi is IN THE MCS at all families`.

These notions coincide IF the truth lemma holds for ALL families (i.e., `phi in fam.mcs t <-> bmcs_truth_at B fam t phi` for all fam). But the truth lemma for standard `bmcs_truth_at` requires temporal coherence of ALL families -- which constant witness families cannot provide (the fundamental tension from research-007 of task 930).

The `bmcs_truth_at_mcs` approach "solves" this by changing the semantics so that the truth lemma only needs temporal coherence of the eval family. But this is a sleight of hand: it proves completeness for `bmcs_valid_mcs`, not for standard `bmcs_valid` or `valid`.

### 2.2 Connection to Task 930/931

Task 930 research-007 (Section 5.3-5.5) explicitly identified this as "Strategy D" and noted: "The `bmcs_truth_at_mcs` completeness is with respect to `bmcs_valid_mcs`, NOT standard `valid`."

Task 931 research-001 then documented all 14 non-standard symbols and recommended removal to Boneyard with a ban notice: "Do NOT restore or replicate this pattern."

### 2.3 What Specifically Is Wrong

1. **`bmcs_valid_mcs` is not standard validity**: The completeness theorem `bmcs_weak_completeness_mcs` proves `bmcs_valid_mcs phi -> derivable phi`, but `bmcs_valid_mcs` quantifies over CanonicalBC-domain BFMCS with the modified truth predicate. This is NOT the same as `bmcs_valid phi` (standard BFMCS validity) or `valid phi` (standard Kripke validity from Semantics/Validity.lean).

2. **No bridge to standard validity exists**: There is no theorem in the codebase connecting `bmcs_valid_mcs` to `bmcs_valid` or `valid`. The module docstring claims "the resulting completeness theorem is equally valid because it connects the same proof system to a sound and complete semantics" (line 687-688), but this is misleading -- it connects the proof system to a DIFFERENT semantics.

3. **The CanonicalBC construction is purpose-built for the flawed semantics**: Every definition in lines 1-349 exists solely to support the `bmcs_truth_at_mcs` chain. The `constantBCFamily` (line 207) works precisely because the Box case does not recursively evaluate truth at witness families. Under standard `bmcs_truth_at`, constant witness families would need temporal coherence, and the construction would fail.

### 2.4 Why Research-001 Was Wrong About constantBCFamily

Research-001 stated: "The `constantBCFamily` in ChainBundleBFMCS.lean is the CORRECT pattern for witness families because the modified truth lemma only requires temporal coherence of the eval family."

This is technically accurate about how the code works, but it papers over the fundamental problem: the "modified truth lemma" uses the wrong semantics. The constant witness families "work" only because the Box case was changed to avoid recursive evaluation. This is not a correct approach -- it is an approach that avoids the hard problem by changing the problem statement.

---

## 3. What Needs Surgical Removal

### 3.1 The Entire ChainBundleBFMCS.lean File

The ENTIRE file should be moved to Boneyard. Unlike research-001's recommendation to keep lines 1-349, there is no reason to keep ANY of the CanonicalBC infrastructure in the active codebase:

| Lines | Content | Reason to Remove |
|-------|---------|-----------------|
| 1-8 | Imports | No longer needed |
| 10-51 | Module docstring | Documents the flawed approach |
| 53-58 | Namespace, opens | Boilerplate |
| 59-99 | `MCSBoxContent_reverse_of_CanonicalR`, `MCSBoxContent_eq_of_CanonicalR` | Only consumers are `canonicalBC_forward_F`, `canonicalBC_backward_P`, and `chainBundle_boxcontent_eq` -- all within this file |
| 100-130 | `MCSBoxContent_eq_of_superset` | Only consumer is `chainBundle_modally_saturated` -- within this file |
| 131-153 | `CanonicalBC` structure + Preorder instance | Only consumers are within this file |
| 154-199 | `canonicalBCBFMCS`, `canonicalBC_forward_F`, `canonicalBC_backward_P` | Only consumers are within this file |
| 200-231 | `constantBCFamily`, membership lemmas | Only consumers are within this file |
| 232-349 | `chainBundleFamilies`, modal forward/backward/saturation, `chainBundleBFMCS` | Only consumers are within this file and the `_mcs` chain |
| 350-691 | ALL `_mcs` definitions and theorems (already documented by task 931) | Non-standard semantics |

**Zero external dependents**: No other `.lean` file imports `ChainBundleBFMCS` or references ANY symbol from it. Confirmed by grep.

### 3.2 Dependencies That Break

**Nothing breaks**. The file is completely self-contained with zero external consumers:

- `Metalogic.lean` does NOT import `ChainBundleBFMCS` (it is mentioned only in a documentation comment at line 64)
- `Completeness.lean` (Bundle) uses `construct_saturated_bfmcs_int` from `TemporalCoherentConstruction.lean`, NOT from `ChainBundleBFMCS.lean`
- `Representation.lean` uses `construct_saturated_bfmcs_int`, NOT CanonicalBC
- No other Bundle file imports ChainBundleBFMCS

### 3.3 Other Files To Clean (From Research-001 Scope)

Research-001 also identified constant witness family definitions in other files. These should STILL be removed per that report:

| File | Definitions to Remove |
|------|----------------------|
| `ModalSaturation.lean` | `constantWitnessFamily`, `constantWitnessFamily_mcs_eq`, `constructWitnessFamily`, `constructWitnessFamily_contains` |
| `Construction.lean` | `constantBFMCS`, `constantBFMCS_mcs_eq` |
| `WitnessGraph.lean` | `witnessGraphBFMCS` and all its accessors/lemmas (Phase 4 section) |
| `TemporalCoherentConstruction.lean` | `TemporalEvalSaturatedBundle`, `fully_saturated_bfmcs_exists` (axiom), `fully_saturated_bfmcs_exists_int` (sorry), `construct_saturated_bfmcs` + wrappers, `construct_saturated_bfmcs_int` + wrappers |

### 3.4 Cascade Impact of Removing fully_saturated_bfmcs_exists_int

Removing `fully_saturated_bfmcs_exists_int` and its wrappers (`construct_saturated_bfmcs_int`, etc.) will break:

1. **`Bundle/Completeness.lean`**: Lines 100-136 (`bmcs_representation`, `bmcs_context_representation`) call `construct_saturated_bfmcs_int`. These are the standard completeness chain.

2. **`Representation.lean`**: Lines 95-100+ use `construct_saturated_bfmcs_int` to build canonical frames/models for standard validity bridge.

**This is the critical cascade**: Removing the sorry-backed `fully_saturated_bfmcs_exists_int` will break the entire standard completeness chain in Completeness.lean and Representation.lean.

**Options**:
- **Option A**: Move Completeness.lean and Representation.lean completeness theorems to Boneyard alongside the sorry chain. The standard completeness result would be "temporarily unavailable" until a correct construction is developed.
- **Option B**: Keep `fully_saturated_bfmcs_exists_int` as a sorry-backed theorem temporarily. The completeness chain remains functional but sorry-dependent.
- **Option C**: Replace `construct_saturated_bfmcs_int` calls in Completeness.lean with a new construction that avoids the temporal coherence problem entirely.

**Recommendation**: Option A or B depending on the user's tolerance. Option B is safer (preserves the completeness chain, even if sorry-backed). Option A is cleaner (removes all flawed infrastructure). The FMP completeness (`fmp_weak_completeness` in `SemanticCanonicalModel.lean`) is SORRY-FREE and provides an independent completeness result, so the project is not left without completeness even if the BFMCS chain is temporarily broken.

---

## 4. Boneyard Warnings

### 4.1 For ChainBundleBFMCS.lean (Entire File)

```
BONEYARD: ChainBundleBFMCS.lean removed (Task 932).

BANNED PATTERNS:

1. MCS-Membership Box Semantics: Defining Box as "phi in fam'.mcs t" instead of
   recursive truth evaluation. This produces completeness for the wrong notion of
   validity. The standard truth definition must use recursive truth for all
   connectives, including Box.

2. CanonicalBC-based Construction: Building a BFMCS domain from
   "MCSes with fixed BoxContent" (CanonicalBC BC). While the construction compiles,
   it is purpose-built for the non-standard MCS-membership semantics. The CanonicalBC
   domain, constantBCFamily, and chainBundleBFMCS are tightly coupled to the flawed
   approach.

3. Constant Witness Families for Modal Saturation: Using constant families that
   map all time points to the same MCS as modal witnesses. These families cannot
   satisfy forward_F/backward_P because temporal saturation of a single MCS is
   impossible in general. Counterexample: {F(psi), neg(psi)} is consistent but
   violates F(psi) -> psi.

CORRECT APPROACH:
Build witness families that are non-constant (different MCS at different times)
and achieve temporal coherence by placing witnesses at different time points.
The standard truth lemma (bmcs_truth_lemma in TruthLemma.lean) with standard
truth (bmcs_truth_at in BFMCSTruth.lean) must be the basis for completeness.

See: specs/930_verify_mcs_membership_box_semantics_correctness/reports/research-007.md
See: specs/931_remove_bmcs_truth_lemma_mcs_nonstandard_validity/reports/research-001.md
```

### 4.2 For constantWitnessFamily Removal Sites

(Same as research-001 recommended, with added cross-reference to this report.)

```
BONEYARD: constantWitnessFamily removed (Tasks 931, 932).
The constant witness family approach (mapping all times to the same MCS) is
fundamentally flawed: constant families cannot satisfy forward_F/backward_P.
See ChainBundleBFMCS.lean Boneyard for extended explanation.
DO NOT reintroduce constant witness families for modal saturation.
```

---

## 5. What Remains After Removal

### 5.1 Salvageable Infrastructure in Metalogic

The following is NOT being removed and remains functional:

**Core MCS Theory** (`Core/`):
- `MaximalConsistent.lean`: Lindenbaum's lemma, MCS properties
- `MCSProperties.lean`: MCS closure under derivation
- `DeductionTheorem.lean`: Hilbert-style deduction theorem

**Bundle Framework** (`Bundle/`):
- `FMCSDef.lean`, `FMCS.lean`: FMCS structure (Family of MCS) -- KEEP
- `BFMCS.lean`: BFMCS structure, modal coherence -- KEEP
- `BFMCSTruth.lean`: Standard `bmcs_truth_at` -- KEEP (dead `eval_bmcs_*` code may be cleaned per task 931)
- `TruthLemma.lean`: Standard `bmcs_truth_lemma` -- KEEP (the correct truth lemma)
- `CanonicalFMCS.lean`: Canonical FMCS construction -- KEEP
- `CanonicalFrame.lean`, `CanonicalQuotient.lean`, `CanonicalReachable.lean`, `CanonicalEmbedding.lean`: Canonical frame infrastructure -- KEEP
- `ChainFMCS.lean`: Chain FMCS construction -- KEEP
- `DovetailingChain.lean`: DovetailingChain construction (has 2 sorries) -- KEEP
- `TemporalContent.lean`: Temporal content definitions -- KEEP
- `ModalSaturation.lean`: Diamond lemmas, `is_modally_saturated`, etc. -- KEEP (minus constantWitnessFamily)
- `Construction.lean`: `ContextConsistent`, `lindenbaumMCS`, etc. -- KEEP (minus `constantBFMCS`)
- `WitnessGraph.lean`: Enriched chain infrastructure -- KEEP (minus Phase 4 constant BFMCS)
- `TemporalCoherentConstruction.lean`: `TemporalCoherentFamily`, temporal backward G/H -- KEEP (minus constant-family wrappers and sorry-backed theorems)
- `Completeness.lean`: Standard completeness chain -- KEEP (will need updating if fully_saturated_bfmcs_exists_int is removed)

**Soundness**:
- `Soundness.lean`, `SoundnessLemmas.lean`: SORRY-FREE -- KEEP

**FMP Completeness** (`FMP/`):
- `SemanticCanonicalModel.lean`: `fmp_weak_completeness` -- SORRY-FREE -- KEEP
- This provides an independent, sorry-free completeness result

**Decidability** (`Decidability/`):
- All files -- SORRY-FREE -- KEEP

**Representation** (`Representation.lean`):
- Standard validity bridge -- KEEP (but sorry-dependent via `construct_saturated_bfmcs_int`)

### 5.2 The Clean Slate for Better Attempts

After removing all constant witness family and CanonicalBC infrastructure, the path forward for BFMCS completeness requires resolving the fundamental tension:

**The Hard Problem**: Combining temporal coherence (forward_F, backward_P) with modal saturation in a single BFMCS over Int.

**What Works**:
- Eval family via DovetailingChain (forward_G, backward_H proven; forward_F, backward_P have 2 sorries)
- Modal saturation via Lindenbaum extension (sorry-free)
- Truth lemma for standard `bmcs_truth_at` (sorry-free, but requires temporal coherence of ALL families)

**What Does Not Work**:
- Constant witness families (cannot be temporally coherent)
- MCS-membership box semantics (proves completeness for wrong validity)
- CanonicalBC domain (tightly coupled to MCS-membership semantics)

**The remaining 5 sorries in the Metalogic module**:
1. `singleFamilyBFMCS.modal_backward` (Construction.lean) -- 1 sorry
2. `temporal_coherent_family_exists` (TemporalCoherentConstruction.lean) -- 1 sorry
3. `fully_saturated_bfmcs_exists_int` (TemporalCoherentConstruction.lean) -- 1 sorry
4. `buildDovetailingChainFamily_forward_F` (DovetailingChain.lean) -- 1 sorry
5. `buildDovetailingChainFamily_backward_P` (DovetailingChain.lean) -- 1 sorry

Sorries 4-5 are the DovetailingChain structural limitations. Sorry 3 combines temporal coherence + modal saturation. Sorry 2 is a related temporal construction. Sorry 1 is a separate issue (single-family modal backward).

**Future approach**: Either (a) fix DovetailingChain's forward_F/backward_P to make the eval family fully temporally coherent, then find a way to make witness families non-constant and temporally coherent too, or (b) find an entirely different construction that avoids the temporal coherence requirement for witness families while maintaining standard recursive truth semantics.

---

## 6. Summary of Findings

1. **The CanonicalBC-based construction** in ChainBundleBFMCS.lean is purpose-built for the non-standard `bmcs_truth_at_mcs` semantics and should be entirely removed to Boneyard.

2. **The MCS-membership box semantics** (`bmcs_truth_at_mcs`) defines a different notion of truth than standard Kripke/BFMCS semantics. Completeness theorems proven with this semantics do not apply to standard validity.

3. **Zero external dependencies** exist on ChainBundleBFMCS.lean. The entire file can be removed without breaking any other file.

4. **Removing `fully_saturated_bfmcs_exists_int`** (from TemporalCoherentConstruction.lean, per research-001 scope) WILL break the standard completeness chain in `Bundle/Completeness.lean` and `Representation.lean`. This cascade must be handled.

5. **The FMP completeness** (`fmp_weak_completeness`) provides an independent, sorry-free completeness result, so the project retains a valid completeness theorem even if the BFMCS chain is temporarily broken.

6. **Three banned patterns** should be documented in Boneyard: (a) MCS-membership box semantics, (b) CanonicalBC domain construction, (c) constant witness families for modal saturation.

---

## 7. Files Examined

| File | Path | Role |
|------|------|------|
| ChainBundleBFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean` | PRIMARY target -- entire file |
| BFMCS.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` | BFMCS structure definition |
| BFMCSTruth.lean | `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` | Standard truth + dead eval code |
| TruthLemma.lean | `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` | Standard truth lemma |
| Completeness.lean (Bundle) | `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` | Standard completeness (will break) |
| Completeness.lean (Metalogic) | `Theories/Bimodal/Metalogic/Completeness.lean` | MCS closure properties |
| TemporalCoherentConstruction.lean | `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` | Sorry-backed construction |
| Representation.lean | `Theories/Bimodal/Metalogic/Representation.lean` | Standard validity bridge |
| Metalogic.lean | `Theories/Bimodal/Metalogic/Metalogic.lean` | Module re-export |
| research-001.md | `specs/932_.../reports/research-001.md` | Prior research (this task) |
| research-001.md | `specs/931_.../reports/research-001.md` | Task 931 research |
| research-007.md | `specs/930_.../reports/research-007.md` | Fundamental tension analysis |
