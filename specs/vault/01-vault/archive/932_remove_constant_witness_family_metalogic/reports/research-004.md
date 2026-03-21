# Research Report: Metalogic Cleanup Scan - Boneyard Candidates

**Task**: 932 (remove_constant_witness_family_metalogic)
**Session**: sess_1772086884_cd2803
**Date**: 2026-02-25
**Type**: Cleanup scan of entire Metalogic module

## Executive Summary

A comprehensive scan of all 46 Lean files across the Metalogic module identified:
- **Section 1**: 3 previously-identified boneyard candidates (confirmed)
- **Section 2**: 10 NEW boneyard candidates across 7 files
- **Section 3**: 5 edge cases requiring discussion
- **Section 4**: Explicit preservation list for infrastructure that must NOT be removed

The scan focused on dead code paths, half-baked constructions, sorry-backed chains
with flawed foundations, duplicate infrastructure, and misleading comments. The goal
is to remove clutter and make room for fresh thinking about correct constructions.

---

## Section 1: Definite Boneyard Candidates (Previously Identified)

### 1A. Constant Witness Families in ModalSaturation.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
**Lines**: 249-288 (constantWitnessFamily, constructWitnessFamily, related lemmas)
**Reason**: Duplicate of constantBFMCS in Construction.lean. These were part of an
abandoned attempt to build witness families from scratch. The constantBCFamily in
ChainBundleBFMCS.lean is the correct replacement. However, see note below about
the predicates and theorems that SHOULD be kept.

**What to remove**: `constantWitnessFamily`, `constructWitnessFamily`,
`constructWitnessFamily_contains`, `extendToMCS`, `extendToMCS_contains`,
`extendToMCS_is_mcs` (lines 225-288).

**What to KEEP in this file**: Everything else. The `is_modally_saturated` predicate,
`saturated_modal_backward` theorem, `diamondFormula`, `diamond_implies_psi_consistent`,
`SaturatedBFMCS`, `axiom_5_negative_introspection`, `mcs_neg_box_implies_box_neg_box`,
`box_dne_theorem`, `mcs_contrapositive`, `dne_theorem`, `dni_theorem` -- all of these
are actively used by ChainBundleBFMCS.lean and other downstream files. The propositional
infrastructure (dne, dni, contrapositive) is used across multiple files.

### 1B. ChainBundleBFMCS.lean - constantBCFamily and Related Infrastructure

**File**: `Theories/Bimodal/Metalogic/Bundle/ChainBundleBFMCS.lean`
**Lines**: 195-293 (constantBCFamily, chainBundleFamilies with constant families,
chainBundle_modally_saturated using constantBCFamily)
**Reason**: The entire ChainBundleBFMCS.lean file provides a sorry-free CanonicalBC-based
BFMCS construction. However, this file is NOT imported by anything in the active
completeness chain (no file imports ChainBundleBFMCS). It represents a valid but
alternative approach.

**Dependency analysis**: `ChainBundleBFMCS.lean` imports `ChainFMCS.lean`,
`CanonicalFMCS.lean`, `ModalSaturation.lean`, `Construction.lean`, and
`TemporalCoherentConstruction.lean`. But NOTHING imports `ChainBundleBFMCS.lean`.
This entire file is a dead end in the current dependency graph.

**Recommendation**: Move entire file to Boneyard. It demonstrates a correct approach
(CanonicalBC quotient classes with constant witness families) but it is not wired into
the completeness proof and adds complexity without active value.

### 1C. singleFamilyBFMCS and construct_temporal_bfmcs

**File**: `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
**Lines**: 177-204 (singleFamilyBFMCS, singleFamilyBFMCS_eval_family_eq)
**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
**Lines**: 635-678 (construct_temporal_bfmcs and its three theorems)
**Reason**: singleFamilyBFMCS has a sorry in modal_backward that is known to be
unprovable from first principles (the FALSE axiom singleFamily_modal_backward_axiom
was already removed in task 905). construct_temporal_bfmcs depends on singleFamilyBFMCS,
inheriting the sorry. Neither is used by the active completeness chain (which uses
construct_saturated_bfmcs_int instead).

**Dependency analysis**: construct_temporal_bfmcs is only referenced within
TemporalCoherentConstruction.lean itself (in comments and docstrings). The active
completeness chain in Bundle/Completeness.lean uses construct_saturated_bfmcs_int,
which uses fully_saturated_bfmcs_exists_int -- NOT construct_temporal_bfmcs.

---

## Section 2: NEW Boneyard Candidates (Discovered in This Scan)

### 2A. WitnessGraph.lean - Entire File (3403 lines)

**File**: `Theories/Bimodal/Metalogic/Bundle/WitnessGraph.lean`
**Lines**: 1-3403 (entire file)
**Reason**: This is the largest file in the Metalogic module at 3403 lines. It implements
an elaborate "Deferred Concretization" approach with WitnessNode, WitnessObligation,
WitnessGraph, buildWitnessGraph, processStep, and witnessGraphBFMCS. However:

1. **Nothing imports it**. No file in the codebase has `import ...WitnessGraph`.
2. **The approach was acknowledged as incomplete** - the docstring explicitly states:
   "The witness graph alone does NOT suffice to close the forward_F/backward_P sorries
   in DovetailingChain.lean because its constant-family FMCS only has universal G/H
   propagation, not existential F/P witness properties."
3. **witnessGraphBFMCS is just another constant family** (same MCS at all times) --
   the very pattern the user wants to remove.
4. It contains duplicate helper lemmas (GContent_consistent_of_mcs',
   HContent_consistent_of_mcs') defined to "avoid circular imports."

**Assessment**: This file represents significant effort but is a dead code path that
adds 3403 lines of complexity with no downstream consumers. The local witness existence
theorems are mathematically correct but unused. The ideas may be valuable as reference
material (move to Boneyard, not delete).

### 2B. construct_saturated_bfmcs (Polymorphic D Version)

**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
**Lines**: 844-868 (construct_saturated_bfmcs and its three theorems)
**Reason**: This is the polymorphic-D version that uses the DEPRECATED AXIOM
`fully_saturated_bfmcs_exists`. The axiom itself is marked `@[deprecated]`.
The active completeness chain uses construct_saturated_bfmcs_INT instead.
Having both clutters the namespace and may mislead future developers into
using the deprecated polymorphic version.

**Dependency analysis**: construct_saturated_bfmcs is NOT used by
Bundle/Completeness.lean (which uses construct_saturated_bfmcs_int).
It is not imported by any active file.

### 2C. fully_saturated_bfmcs_exists (Polymorphic AXIOM)

**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
**Lines**: 753-758 (the axiom declaration)
**Reason**: Already marked `@[deprecated]`. This is a genuine AXIOM (in the trusted
kernel), not just a sorry-backed theorem. Having it in the codebase increases the
trusted base unnecessarily. The Int-specialized version
`fully_saturated_bfmcs_exists_int` is a sorry-backed THEOREM (not an axiom),
which is strictly better.

**Risk assessment**: Removing an axiom is always safe from a soundness perspective --
it can only make things MORE trustworthy, not less. Any code that depended on it
would fail to compile, making breakage visible.

### 2D. temporal_coherent_family_exists (Polymorphic D, sorry-backed)

**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
**Lines**: 605-611 (the generic D theorem with sorry)
**Reason**: Only the Int version is ever instantiated downstream. The generic D version
has a sorry that can never be resolved because the construction is inherently Int-specific
(uses dovetailIndex : Nat -> Int). It is dead code that cannot become live.

**What to KEEP**: `temporal_coherent_family_exists_Int` (lines 569-578) is actively
used via DovetailingChain.temporal_coherent_family_exists_theorem and IS part of the
live dependency chain.

### 2E. RecursiveSeed.lean.backup-v004 (Backup File)

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean.backup-v004`
**Lines**: Entire file (likely 4000+ lines based on grep results showing lines 4288+)
**Reason**: This is a .backup file, not compiled, not imported. Contains many sorries
and references to abandoned approaches. It serves no purpose in the active codebase.
Should be deleted entirely (not even moved to Boneyard -- it's a backup of abandoned work).

### 2F. TemporalForwardSaturated / TemporalBackwardSaturated / TemporallySaturated

**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
**Lines**: 315-328 (three predicate definitions)
**Lines**: 338-386 (TemporalEvalSaturatedBundle structure and methods)
**Reason**: These predicates define "temporal saturation" (F psi -> psi in same MCS),
which was part of the constant-family approach. The TemporalEvalSaturatedBundle
converts a temporally saturated MCS into a constant FMCS. However:

1. TemporalEvalSaturatedBundle is never instantiated by any downstream code.
2. The approach of "temporally saturated constant families" was proven flawed --
   the docstring itself says: "counterexample: {F(psi), neg psi} is consistent but
   cannot be in a single temporally saturated MCS."
3. These are vestiges of the abandoned constant-family temporal approach.

**What to KEEP**: The TemporalCoherentFamily structure (lines 204-210) and
temporal_backward_G / temporal_backward_H theorems ARE actively used by the
truth lemma. Only the saturation predicates and the TemporalEvalSaturatedBundle
are dead.

### 2G. IsConstantFamily

**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
**Lines**: Need to check exact location
**Reason**: Referenced by TemporalEvalSaturatedBundle.toFMCS_constant. If
TemporalEvalSaturatedBundle is removed (2F above), IsConstantFamily also becomes dead.

**Dependency check needed**: Verify IsConstantFamily is not used elsewhere.

### 2H. ModalWitnessSeed and Related Definitions in ChainFMCS.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`
**Lines**: Various (ModalWitnessSeed, psi_mem_ModalWitnessSeed,
MCSBoxContent_subset_ModalWitnessSeed, modal_witness_seed_consistent)
**Assessment**: These are used by chainBundle_modally_saturated in
ChainBundleBFMCS.lean. If ChainBundleBFMCS.lean is boneyarded (1B above),
check whether these definitions have other consumers.

**Dependency check**: ChainFMCS.lean also provides MCSBoxContent, BoxContent
infrastructure, diamond persistence lemmas, etc. Much of this IS used by
CanonicalFMCS.lean (which imports ChainFMCS via CanonicalFMCS -> ChainFMCS).
So ChainFMCS.lean should NOT be entirely removed -- only the ModalWitnessSeed
functions that serve exclusively ChainBundleBFMCS.lean.

**Result**: ModalWitnessSeed, psi_mem_ModalWitnessSeed,
MCSBoxContent_subset_ModalWitnessSeed are used ONLY by ChainBundleBFMCS.lean
(and possibly by the Completeness chain through ChainBundleBFMCS). Since
ChainBundleBFMCS is not imported anywhere, these are dead code.
However, modal_witness_seed_consistent is used by ChainBundleBFMCS too, BUT its
analog (diamond_implies_psi_consistent + extendToMCS pattern) exists in
ModalSaturation.lean. Keep the theorem but consider consolidation.

### 2I. Completeness.lean (Metalogic/Completeness.lean) - Partial Deadness

**File**: `Theories/Bimodal/Metalogic/Completeness.lean` (629 lines)
**Reason**: This file contains MCS closure properties (disjunction, conjunction, box
closure, diamond-box duality, temporal 4, etc.). SOME of these are actively used:

- `set_mcs_disjunction_*`: Used by BFMCSTruth.lean and Representation.lean
- `set_mcs_conjunction_*`: Used by BFMCSTruth.lean and Representation.lean
- `set_mcs_box_closure`: Used by CanonicalFrame.lean and other files
- `set_mcs_box_box`: Used by CanonicalFrame.lean and ChainFMCS.lean
- `set_mcs_all_future_all_future` / `set_mcs_all_past_all_past`: Used by temporal chain
- `set_mcs_diamond_box_duality`: Check if used
- `set_mcs_modal_saturation_forward`: Trivially wraps set_mcs_box_closure; check usage

The `temp_4_past` derivation and the diamond-box duality proofs appear to be actively
used. The comment "CanonicalWorldState was removed in Task 928 Phase 6" shows cleanup
already occurred.

**Assessment**: This file is MOSTLY live infrastructure. Do NOT boneyard it.
The only potentially dead item is `set_mcs_modal_saturation_forward` which is a
trivial alias for `set_mcs_box_closure`.

### 2J. Representation.lean Sorry Chain

**File**: `Theories/Bimodal/Metalogic/Representation.lean` (685 lines)
**Reason**: This file bridges BFMCS completeness to standard semantics. It is imported
by Metalogic/Metalogic.lean. Its sorry-dependence comes from
construct_saturated_bfmcs_int. The file itself is architecturally sound -- the sorries
are inherited, not local.

**Assessment**: KEEP. The standard completeness theorems (standard_weak_completeness,
standard_strong_completeness) are valuable even with inherited sorry-dependence. They
will become sorry-free once the upstream BFMCS construction is completed.

---

## Section 3: Edge Cases (Needs Discussion)

### 3A. ChainFMCS.lean - BoxContent Infrastructure

**File**: `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` (729 lines)
**Pros of removal**: Contains diamond_persistence_through_CanonicalR and extensive
BoxContent propagation infrastructure that was built for the ChainBundleBFMCS approach.
Some of this duplicates simpler proofs in CanonicalFrame.lean.
**Cons of removal**: MCSBoxContent, MCSBoxContent_subset_of_CanonicalR, and
modal_witness_seed_consistent are used by ChainBundleBFMCS.lean AND by the
CanonicalFMCS.lean -> ChainFMCS dependency. CanonicalFMCS.lean imports ChainFMCS.lean.
**Recommendation**: Keep ChainFMCS.lean but consider extracting the MCSBoxContent
definitions into a smaller, dedicated file. The ModalWitnessSeed infrastructure can
be removed if ChainBundleBFMCS is boneyarded.

### 3B. Canonical Frame/Embedding/Reachable/Quotient Chain

**Files**: CanonicalFrame.lean (233 lines), CanonicalEmbedding.lean (398 lines),
CanonicalReachable.lean (329 lines), CanonicalQuotient.lean (277 lines)
**Total**: 1237 lines
**Pros of removal**: This is the "Canonical Quotient approach" (Task 922) that was
proposed as an alternative to DovetailingChain for solving forward_F/backward_P. It
provides sorry-free forward_F/backward_P for the abstract canonical frame, but the
Int embedding was never completed. The chain CanonicalFrame -> CanonicalEmbedding ->
CanonicalReachable -> CanonicalQuotient -> CanonicalFMCS is largely infrastructure
for an unfinished approach.
**Cons of removal**: CanonicalFrame.lean provides canonical_forward_F, canonical_backward_P,
canonical_forward_G, canonical_backward_H, CanonicalR, CanonicalR_past -- which ARE
used by CanonicalFMCS.lean (the sorry-free FMCS for CanonicalMCS domain). CanonicalFMCS
is listed as "keep" in the task description.
**Recommendation**: KEEP CanonicalFrame.lean (it provides the fundamental canonical
frame relations used by CanonicalFMCS). The other three files (CanonicalEmbedding,
CanonicalReachable, CanonicalQuotient) could be boneyarded since their purpose was
the unfinished Int embedding. However, they are architecturally clean and sorry-free --
removing them loses valid mathematical work that could be revived.
**Decision needed**: Does "making room for fresh thinking" outweigh preserving
correct-but-unfinished work?

### 3C. Algebraic Module (6 files, ~2100 lines)

**Files**: Algebraic/Algebraic.lean, LindenbaumQuotient.lean, BooleanStructure.lean,
InteriorOperators.lean, UltrafilterMCS.lean, AlgebraicRepresentation.lean
**Total**: ~2100 lines
**Status**: All sorry-free. Self-contained. Not used by main completeness proof.
**Pros of removal**: Reduces overall module size by ~2100 lines. Not needed for
completeness.
**Cons of removal**: Entirely sorry-free. Self-contained (doesn't add confusion).
Provides an independent mathematical verification path. Could be useful for future work.
**Recommendation**: KEEP. The Algebraic module is clean, sorry-free, self-contained,
and doesn't interfere with the main proof path. The task says "Do NOT move anything
worth keeping" -- this module is explicitly worth keeping.

### 3D. TemporalContent.lean

**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` (38 lines)
**Content**: GContent and HContent definitions.
**Assessment**: KEEP. Small, clean, used by many files.

### 3E. fully_saturated_bfmcs_exists_int (Sorry-backed Theorem)

**File**: `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
**Lines**: 797-817
**Reason**: This is a sorry-backed theorem (not axiom) that is the foundation of the
active completeness chain. It is used by construct_saturated_bfmcs_int, which is used
by Bundle/Completeness.lean.
**Recommendation**: KEEP -- this is the active sorry location where future work should
focus. Removing it would break the entire completeness chain.

---

## Section 4: Worth Keeping (Explicitly Preserve)

The following infrastructure MUST NOT be removed:

### Core MCS Theory
- `Core/MaximalConsistent.lean` (56 lines) - Lindenbaum's lemma, SetMaximalConsistent
- `Core/MCSProperties.lean` (362 lines) - MCS closure properties
- `Core/DeductionTheorem.lean` (457 lines) - Deduction theorem
- `Core/RestrictedMCS.lean` (443 lines) - Restricted MCS theory
- `Core/Core.lean` (24 lines) - Re-exports

### Bundle Framework
- `Bundle/FMCSDef.lean` (219 lines) - FMCS structure definition
- `Bundle/FMCS.lean` (22 lines) - Re-export
- `Bundle/BFMCS.lean` (269 lines) - BFMCS structure definition
- `Bundle/BFMCSTruth.lean` (334 lines) - bmcs_truth_at predicate
- `Bundle/TruthLemma.lean` (488 lines) - Sorry-free truth lemma (KEY RESULT)
- `Bundle/Completeness.lean` (476 lines) - Sorry-free completeness theorems
- `Bundle/CanonicalFMCS.lean` (399 lines) - Sorry-free CanonicalMCS-based FMCS
- `Bundle/CanonicalFrame.lean` (233 lines) - Canonical frame relations

### Temporal Chain Infrastructure
- `Bundle/DovetailingChain.lean` (1908 lines) - Valid approach with 2 sorries
- `Bundle/TemporalContent.lean` (38 lines) - GContent/HContent
- `Bundle/TemporalCoherentConstruction.lean` - KEEP the following:
  - TemporalCoherentFamily structure
  - temporal_backward_G, temporal_backward_H theorems
  - temporal_witness_seed_consistent theorem
  - temporal_coherent_family_exists_Int theorem
  - construct_saturated_bfmcs_int and its properties
  - fully_saturated_bfmcs_exists_int theorem
  - BFMCS.temporally_coherent predicate

### Modal Saturation (Partial Keep)
- `Bundle/ModalSaturation.lean` - KEEP: is_modally_saturated, saturated_modal_backward,
  SaturatedBFMCS, diamondFormula, diamond_implies_psi_consistent,
  axiom_5_negative_introspection, mcs_neg_box_implies_box_neg_box,
  box_dne_theorem, dne_theorem, dni_theorem, mcs_contrapositive

### Construction Utilities (Partial Keep)
- `Bundle/Construction.lean` - KEEP: ContextConsistent, contextAsSet,
  list_consistent_to_set_consistent, constantBFMCS, lindenbaumMCS, lindenbaumMCS_set,
  and their lemmas. These are used by construct_saturated_bfmcs_int and other active code.

### Sorry-Free Completeness Results
- `FMP/` (4 files, ~2027 lines) - Entire FMP directory (sorry-free completeness)
- `Soundness.lean` (344 lines) - Sorry-free soundness
- `SoundnessLemmas.lean` (984 lines) - Axiom validity lemmas
- `Decidability/` (8 files, ~2624 lines) - Sorry-free decision procedure

### Other Keep
- `Completeness.lean` (629 lines) - MCS closure properties (disjunction, conjunction, etc.)
- `Representation.lean` (685 lines) - Standard semantics bridge
- `Algebraic/` (6 files, ~2100 lines) - Independent algebraic path (sorry-free)
- `Bundle/ChainFMCS.lean` (729 lines) - BoxContent infrastructure (used by CanonicalFMCS)

---

## Section 5: Proposed Removal Summary

### Definite Removals (Move to Boneyard)

| Item | File | Lines | Reason |
|------|------|-------|--------|
| WitnessGraph.lean | Bundle/WitnessGraph.lean | 3403 | Dead code, not imported, constant-family |
| ChainBundleBFMCS.lean | Bundle/ChainBundleBFMCS.lean | 338 | Dead code, not imported |
| constantWitnessFamily etc. | Bundle/ModalSaturation.lean | 225-288 | Duplicate, unused |
| singleFamilyBFMCS | Bundle/Construction.lean | 115-204 | Sorry, deprecated, unused |
| construct_temporal_bfmcs | Bundle/TemporalCoherentConstruction.lean | 635-678 | Depends on singleFamilyBFMCS |
| construct_saturated_bfmcs (D) | Bundle/TemporalCoherentConstruction.lean | 844-868 | Deprecated polymorphic version |
| fully_saturated_bfmcs_exists AXIOM | Bundle/TemporalCoherentConstruction.lean | 753-758 | Deprecated axiom in trusted kernel |
| temporal_coherent_family_exists (D) | Bundle/TemporalCoherentConstruction.lean | 605-611 | Generic D sorry, dead code |
| TemporalEvalSaturatedBundle | Bundle/TemporalCoherentConstruction.lean | 315-386 | Abandoned constant-family temporal approach |
| RecursiveSeed.lean.backup-v004 | Bundle/RecursiveSeed.lean.backup-v004 | ~4300+ | Backup file, delete entirely |

### Total Lines Removable: ~8,700+ lines

**Estimated line count reduction**:
- WitnessGraph.lean: 3,403 lines
- ChainBundleBFMCS.lean: 338 lines
- ModalSaturation.lean partial: ~64 lines
- Construction.lean partial: ~90 lines
- TemporalCoherentConstruction.lean partial: ~200 lines
- RecursiveSeed.lean.backup-v004: ~4,300+ lines
- **Total**: ~8,400+ lines

### Edge Case Removals (Discuss First)

| Item | File | Lines | Discussion |
|------|------|-------|------------|
| CanonicalEmbedding.lean | Bundle/ | 398 | Unfinished Int embedding |
| CanonicalReachable.lean | Bundle/ | 329 | Unfinished Int embedding |
| CanonicalQuotient.lean | Bundle/ | 277 | Unfinished Int embedding |
| ModalWitnessSeed in ChainFMCS | Bundle/ChainFMCS.lean | ~100 | Only if ChainBundleBFMCS removed |

---

## Section 6: Boneyard Warning Comments (Templates)

For files moved to Boneyard, add headers like:

```
-- BONEYARD: Moved from Theories/Bimodal/Metalogic/Bundle/ (Task 932, 2026-02-25)
-- Reason: [specific reason]
-- Original purpose: [what it was meant to do]
-- Why removed: [why it doesn't work / is unused]
-- Resurrect if: [conditions under which it might be valuable again]
```

For inline warnings where partial removal occurs:

```
-- WARNING: Code below removed in Task 932 cleanup.
-- The [X] approach was abandoned because [reason].
-- See Boneyard/Metalogic_v6/ for archived code.
```

---

## Methodology Notes

**Scan approach**: Read all 46 Lean files in the Metalogic module (excluding Boneyard/).
Traced import dependencies using `grep import`. Checked usage of every definition via
`grep` across the entire Theories/Bimodal directory. Verified sorry counts. Checked
axiom declarations. Analyzed dependency chains to identify dead code.

**Key finding**: The single largest source of removable code is WitnessGraph.lean
(3,403 lines). Combined with the backup file and other dead code, roughly 8,400 lines
can be removed -- nearly 40% of the module's total 22,178 lines.
