# Research Report 001: Constant Witness Family Removal from Metalogic

**Task**: 932
**Session**: sess_1772084922_a68d00
**Date**: 2026-02-25
**Focus**: Identify all constant witness family constructions in the Metalogic module, map dependencies, and document removal strategy.

---

## Executive Summary

The "constant witness family" approach appears in multiple locations across the Metalogic module. It consists of constructing an `FMCS D` that maps every time point to the SAME MCS. This approach is fundamentally flawed for achieving temporal coherence because constant families cannot satisfy `forward_F` or `backward_P` for formulas like `{F(psi), neg(psi)}`. The approach was correctly documented as flawed in research-007 for task 930.

The good news: the sorry-free completeness chain in `ChainBundleBFMCS.lean` has already REPLACED this approach with the correct `CanonicalBC`-based construction. The constant witness family code that remains in the active Metalogic module is either (a) used only in the sorry-backed `fully_saturated_bfmcs_exists_int` chain (which is superseded), or (b) defined but no longer consumed by the active completeness chain.

---

## 1. Inventory of Constant Family Constructions

### 1.1 Active Metalogic Files (non-Boneyard)

| File | Definition/Theorem | Lines | Status |
|------|-------------------|-------|--------|
| `ModalSaturation.lean` | `constantWitnessFamily` | 249-262 | **REMOVE** - creates constant FMCS from single MCS |
| `ModalSaturation.lean` | `constantWitnessFamily_mcs_eq` | 267-268 | **REMOVE** - accessor for above |
| `ModalSaturation.lean` | `constructWitnessFamily` | 276-280 | **REMOVE** - wraps constantWitnessFamily |
| `ModalSaturation.lean` | `constructWitnessFamily_contains` | 285-288 | **REMOVE** - property of above |
| `Construction.lean` | `constantBFMCS` | 90-107 | **REMOVE** - constant FMCS from MCS via T-axiom |
| `Construction.lean` | `constantBFMCS_mcs_eq` | 112-113 | **REMOVE** - accessor for above |
| `WitnessGraph.lean` | `witnessGraphBFMCS` | 2474-2481 | **REMOVE** - constant FMCS from root MCS |
| `WitnessGraph.lean` | `witnessGraphBFMCS_mcs_eq` | 2484-2486 | **REMOVE** - accessor |
| `WitnessGraph.lean` | `witnessGraphBFMCS_root_preserved` | 2489-2492 | **REMOVE** - root preservation |
| `WitnessGraph.lean` | `witnessGraphBFMCS_edge_ordering_compatible` | 2527-2532 | **REMOVE** - edge ordering |
| `WitnessGraph.lean` | `witnessGraphBFMCS_at_root` | 2551-2556 | **REMOVE** - bridge lemma |
| `WitnessGraph.lean` | Phase 4 comment block | 2402-2438 | **REMOVE** - documents constant family approach |
| `TemporalCoherentConstruction.lean` | `TemporalEvalSaturatedBundle` | 338-346 | **REVIEW** - constant family + temporal saturation |
| `TemporalCoherentConstruction.lean` | `TemporalEvalSaturatedBundle.toFMCS` | 351-362 | **REVIEW** - converts to constant FMCS |
| `TemporalCoherentConstruction.lean` | `TemporalEvalSaturatedBundle.toFMCS_constant` | 367-370 | **REVIEW** - proves constancy |
| `TemporalCoherentConstruction.lean` | `TemporalEvalSaturatedBundle.toTemporalCoherentFamily` | 378-386 | **REVIEW** - relies on temporal saturation |
| `TemporalCoherentConstruction.lean` | `TemporalForwardSaturated` / `TemporalBackwardSaturated` / `TemporallySaturated` | 315-328 | **REVIEW** - predicates for constant family saturation |
| `TemporalCoherentConstruction.lean` | `fully_saturated_bfmcs_exists` (axiom) | 753-758 | **REMOVE** - deprecated, uses constant family approach |
| `TemporalCoherentConstruction.lean` | `fully_saturated_bfmcs_exists_int` (sorry) | 797-817 | **REMOVE** - sorry-backed, superseded by ChainBundleBFMCS |
| `TemporalCoherentConstruction.lean` | `construct_saturated_bfmcs` + wrappers | 844-868 | **REMOVE** - uses deprecated axiom |
| `TemporalCoherentConstruction.lean` | `construct_saturated_bfmcs_int` + wrappers | 887-911 | **REMOVE** - uses sorry-backed theorem |
| `ChainBundleBFMCS.lean` | `constantBCFamily` | 207-219 | **KEEP** - correct CanonicalBC constant family |

### 1.2 Boneyard Files (already deprecated)

These files are in the Boneyard and import `ModalSaturation.lean`'s `constantWitnessFamily`:

| File | Usage |
|------|-------|
| `Boneyard/Bundle/SaturatedConstruction.lean` | Heavy use of `constantWitnessFamily`, `constantWitnessFamily_isConstant` |
| `Boneyard/Bundle/CoherentConstruction.lean` | `constantWitnessFamily`, `constructCoherentWitness` |
| `Boneyard/Bundle/WeakCoherentBundle.lean` | `constantWitnessFamily` for witness construction |
| `Boneyard/Bundle/PreCoherentBundle.lean` | `diamond_implies_psi_consistent` for witness seed |
| `Boneyard/Bundle/FinalConstruction.lean` | `constantWitnessFamily`, temporal saturation lemmas |
| `Boneyard/Bundle/TemporalLindenbaum.lean` | Imports `ModalSaturation` |

**Boneyard decision**: These files are already in the Boneyard. They will break when `constantWitnessFamily` is removed from `ModalSaturation.lean`. Either (a) add their own local copy of the definition, or (b) accept broken Boneyard imports (Boneyard files do not participate in the build).

### 1.3 ChainBundleBFMCS.lean -- The Correct Approach

`ChainBundleBFMCS.lean` uses `constantBCFamily` (line 207-219) which is a constant family BUT:
- It operates on `CanonicalBC BC`, not `Int`
- The "constancy" is only for witness families, not the eval family
- The eval family (`canonicalBCBFMCS`) is NON-constant (identity mapping on CanonicalBC)
- Temporal coherence is required ONLY for the eval family (via modified truth lemma `bmcs_truth_lemma_mcs`)
- The constant witness families do NOT need temporal coherence

This is the CORRECT architecture. The `constantBCFamily` in ChainBundleBFMCS is NOT the same flawed pattern as the Int-indexed constant families.

---

## 2. Dependency Map

### 2.1 What Consumes `constantWitnessFamily` (non-Boneyard)

```
constantWitnessFamily (ModalSaturation.lean:249)
  <- constructWitnessFamily (ModalSaturation.lean:276)
     [No non-Boneyard consumers]
  <- [Boneyard files only]
```

**Finding**: `constantWitnessFamily` and `constructWitnessFamily` have ZERO non-Boneyard consumers outside of `ModalSaturation.lean` itself. They can be removed without affecting any active code.

### 2.2 What Consumes `constantBFMCS` (Construction.lean)

```
constantBFMCS (Construction.lean:90)
  <- [No consumers in active Metalogic]
  <- ModalSaturation.lean comment references it (line 247), but does not import/use it
```

**Finding**: `constantBFMCS` is defined in `Construction.lean` but has ZERO consumers in active Metalogic code. It can be removed.

### 2.3 What Consumes `witnessGraphBFMCS` (WitnessGraph.lean)

```
witnessGraphBFMCS (WitnessGraph.lean:2474)
  <- witnessGraphBFMCS_mcs_eq (WitnessGraph.lean:2484)
  <- witnessGraphBFMCS_root_preserved (WitnessGraph.lean:2489)
  <- witnessGraphBFMCS_edge_ordering_compatible (WitnessGraph.lean:2527)
  <- witnessGraphBFMCS_at_root (WitnessGraph.lean:2551)
  <- [All consumers are within WitnessGraph.lean itself]
```

**Finding**: `witnessGraphBFMCS` and all its dependents are self-contained within `WitnessGraph.lean`. The enriched chain (`enrichedChainBFMCS`, line 3380) is a SEPARATE, non-constant construction that does NOT use `witnessGraphBFMCS`. These are independent constructions in the same file.

### 2.4 What Consumes `fully_saturated_bfmcs_exists_int`

```
fully_saturated_bfmcs_exists_int (TemporalCoherentConstruction.lean:797)
  <- construct_saturated_bfmcs_int (TemporalCoherentConstruction.lean:887)
     <- construct_saturated_bfmcs_int_contains_context (TemporalCoherentConstruction.lean:894)
     <- construct_saturated_bfmcs_int_temporally_coherent (TemporalCoherentConstruction.lean:902)
     <- construct_saturated_bfmcs_int_is_modally_saturated (TemporalCoherentConstruction.lean:909)
     <- Completeness.lean: bmcs_representation, bmcs_context_representation
     <- Representation.lean (inherits sorry)
```

**Finding**: The `fully_saturated_bfmcs_exists_int` sorry chain is consumed by `Completeness.lean` (the old completeness proofs). These are SUPERSEDED by the sorry-free `ChainBundleBFMCS.lean` completeness chain (`bmcs_weak_completeness_mcs`, `bmcs_strong_completeness_mcs`). However, removing these will require updating `Completeness.lean` to use the new chain, OR accepting that the old Completeness.lean proofs break.

### 2.5 Independent Proofs (KEEP)

The following are proven independently and do NOT rely on constant witness families:

| Definition/Theorem | File | Reason to Keep |
|-------------------|------|----------------|
| `diamondFormula` | ModalSaturation.lean | Pure syntax definition |
| `asDiamond` | ModalSaturation.lean | Pure syntax function |
| `needs_modal_witness` | ModalSaturation.lean | Predicate definition |
| `is_modally_saturated` | ModalSaturation.lean | Core predicate |
| `is_modally_saturated_iff_no_needs_witness` | ModalSaturation.lean | Equivalence theorem |
| `diamond_excludes_box_neg` | ModalSaturation.lean | MCS property |
| `diamond_and_not_psi_implies_neg` | ModalSaturation.lean | MCS property |
| `diamond_implies_psi_consistent` | ModalSaturation.lean | Core consistency lemma |
| `extendToMCS` / `extendToMCS_contains` / `extendToMCS_is_mcs` | ModalSaturation.lean | Lindenbaum helpers |
| `dne_theorem` / `dni_theorem` / `box_dne_theorem` | ModalSaturation.lean | Proof theory |
| `mcs_contrapositive` | ModalSaturation.lean | MCS reasoning |
| `saturated_modal_backward` | ModalSaturation.lean | Core theorem (PROVEN) |
| `SaturatedBFMCS` | ModalSaturation.lean | Structure + theorem |
| `axiom_5_negative_introspection` / `neg_box_to_box_neg_box` | ModalSaturation.lean | Axiom 5 derivation |
| `mcs_neg_box_implies_box_neg_box` | ModalSaturation.lean | MCS property |
| All Phase 1-2 (temporal duality) | TemporalCoherentConstruction.lean | Independent proofs |
| `temporal_backward_G` / `temporal_backward_H` | TemporalCoherentConstruction.lean | Core theorems |
| `TemporalCoherentFamily` | TemporalCoherentConstruction.lean | Structure definition |
| `temporal_coherent_family_exists_Int` | TemporalCoherentConstruction.lean | Backed by DovetailingChain |
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | Proven (independent) |
| Entire enriched chain (Phase 5) | WitnessGraph.lean | Non-constant, proven |
| `enrichedChainBFMCS` | WitnessGraph.lean | Non-constant FMCS |

---

## 3. The Flawed Pattern

### 3.1 What Research Report 930/007 Identified

The report correctly identified that:
- Modal saturation creates witness families where "a constant witness family maps every time point to the SAME MCS W containing psi"
- This is `constantWitnessFamily` in `ModalSaturation.lean`
- Constant families CANNOT satisfy `forward_F` because temporal saturation (`F(psi) -> psi` within a single MCS) is impossible in general
- The counterexample: `{F(psi), neg(psi)}` is consistent, so some MCSes contain both

### 3.2 Where This Pattern Is Instantiated

1. **ModalSaturation.lean:249** (`constantWitnessFamily`): Builds FMCS from single MCS, assigns it to all times. Used by `constructWitnessFamily` (line 276). The `forward_G`/`backward_H` proofs use T-axiom (G(phi)->phi). No `forward_F`/`backward_P`.

2. **Construction.lean:90** (`constantBFMCS`): Same pattern -- constant FMCS from single MCS. Also uses T-axiom for `forward_G`/`backward_H`. No temporal existential properties.

3. **WitnessGraph.lean:2474** (`witnessGraphBFMCS`): Maps all integers to root MCS. Comments at lines 2544-2546 explicitly acknowledge: "its constant-family FMCS only has universal G/H propagation, not existential F/P witness properties."

4. **TemporalCoherentConstruction.lean:786-817** (`fully_saturated_bfmcs_exists_int`): The sorry in this theorem exists PRECISELY because combining temporal coherence (needs non-constant families) with modal saturation (creates constant witness families) is fundamentally impossible with the constant family approach.

### 3.3 What Is NOT Flawed

The `constantBCFamily` in `ChainBundleBFMCS.lean` (line 207) is NOT flawed because:
- It operates on `CanonicalBC BC` domain (not `Int`)
- The modified truth lemma (`bmcs_truth_lemma_mcs`) uses `phi in fam'.mcs t` for Box, not recursive truth
- Temporal coherence is required ONLY for the eval family
- Witness families need no temporal coherence
- This is exactly "Strategy D" from research-007

---

## 4. Removal Strategy

### Phase 1: Remove from ModalSaturation.lean (Low Risk)

**Remove** (lines 243-288):
- `constantWitnessFamily` (def)
- `constantWitnessFamily_mcs_eq` (lemma)
- `constructWitnessFamily` (def)
- `constructWitnessFamily_contains` (lemma)

**Impact**: Zero non-Boneyard consumers. Boneyard files will break but they are not built.

**Keep**: Everything else in `ModalSaturation.lean` -- all the diamond lemmas, `diamond_implies_psi_consistent`, `extendToMCS*`, `saturated_modal_backward`, `SaturatedBFMCS`, axiom 5 derivations, `mcs_contrapositive`, DNE/DNI theorems.

**Add Boneyard comment** at the removal site:
```
-- BONEYARD: constantWitnessFamily removed (Task 932).
-- The constant witness family approach (mapping all times to the same MCS)
-- is fundamentally flawed: constant families cannot satisfy forward_F/backward_P
-- because temporal saturation (F(psi)->psi within a single MCS) is impossible.
-- Counterexample: {F(psi), neg(psi)} is consistent but violates F(psi)->psi.
-- See ChainBundleBFMCS.lean for the correct approach using CanonicalBC.
-- DO NOT reintroduce constant witness families for Int-indexed constructions.
```

### Phase 2: Remove from Construction.lean (Low Risk)

**Remove** (lines 80-113):
- `constantBFMCS` (def)
- `constantBFMCS_mcs_eq` (lemma)

**Impact**: Zero consumers. The comment at line 13 references it but that can be updated.

**Update** the module docstring to remove `constantBFMCS` from the list of provided definitions.

### Phase 3: Remove from WitnessGraph.lean (Low Risk)

**Remove** (lines 2402-2556):
- Phase 4 Int Embedding section header and approach description
- `mcs_G_implies_self`, `mcs_H_implies_self`, `mcs_G_implies_GG` (keep only if used by enriched chain)
- `witnessGraphBFMCS` (def)
- `witnessGraphBFMCS_mcs_eq` (lemma)
- `witnessGraphBFMCS_root_preserved` (lemma)
- `witnessGraphBFMCS_edge_ordering_compatible` (theorem)
- `witnessGraphBFMCS_at_root` (lemma)

**CAUTION**: `mcs_G_implies_self`, `mcs_H_implies_self`, and `mcs_G_implies_GG` are used by the enriched chain construction (Phase 5). Verify before removing. These helper lemmas are NOT specific to the constant family -- they are general MCS lemmas used by the enriched (non-constant) chain as well.

**Keep**: All of Phase 1-3 (witness graph data structures, obligation processing, witness existence proofs), Phase 5 enriched chain, all enrichedChainBFMCS infrastructure.

**Update**: The Phase 4 section header can be replaced with a note that the constant family approach was removed and the enriched chain (Phase 5) is the correct construction.

### Phase 4: Clean TemporalCoherentConstruction.lean (Medium Risk)

**Remove**:
- `TemporalForwardSaturated` / `TemporalBackwardSaturated` / `TemporallySaturated` (predicates for single-MCS saturation)
- `TemporalEvalSaturatedBundle` structure and all its methods
- `fully_saturated_bfmcs_exists` (deprecated axiom)
- `fully_saturated_bfmcs_exists_int` (sorry-backed theorem)
- `construct_saturated_bfmcs` + all wrapper theorems
- `construct_saturated_bfmcs_int` + all wrapper theorems
- Comment block at lines 681-722 describing the constant family approach

**CAUTION**: `Completeness.lean` directly calls `construct_saturated_bfmcs_int`. Removing it will break the standard completeness chain. Options:
1. **Redirect Completeness.lean** to use `ChainBundleBFMCS` chain instead
2. **Keep sorry-backed `fully_saturated_bfmcs_exists_int`** temporarily until Completeness.lean is updated
3. **Move `fully_saturated_bfmcs_exists_int` to Boneyard** along with old Completeness.lean

**Recommended**: Option 1 if task scope allows, otherwise Option 2.

**Keep**: All temporal duality infrastructure (Phase 1), `TemporalCoherentFamily` structure, `temporal_backward_G`/`temporal_backward_H`, `temporal_coherent_family_exists_Int`/`_theorem` (backed by DovetailingChain), `temporal_witness_seed_consistent`, `BFMCS.temporally_coherent`, `construct_temporal_bfmcs` + wrappers.

### Phase 5: Update Comments and Docstrings

Files needing comment/docstring updates:
- `Construction.lean`: Remove references to `constantBFMCS` in module docstring
- `WitnessGraph.lean`: Update Phase 4/5 section headers
- `TemporalCoherentConstruction.lean`: Remove references to constant family approach in comments
- `ChainBundleBFMCS.lean`: Add note that this supersedes the constant family approach

### Phase 6: Boneyard Files

For each Boneyard file that imports `ModalSaturation.lean` and uses `constantWitnessFamily`:
- Option A: Add local copy of `constantWitnessFamily` to the Boneyard file
- Option B: Accept broken imports (Boneyard files are not built)
- **Recommended**: Option B (less work, Boneyard is dead code)

---

## 5. Risk Assessment

| Phase | Risk | Rationale |
|-------|------|-----------|
| 1 (ModalSaturation.lean) | **Low** | Zero non-Boneyard consumers |
| 2 (Construction.lean) | **Low** | Zero consumers |
| 3 (WitnessGraph.lean) | **Low** | Self-contained; check helper lemma usage |
| 4 (TemporalCoherentConstruction.lean) | **Medium** | Completeness.lean dependency |
| 5 (Comments) | **Low** | No code changes |
| 6 (Boneyard) | **Low** | Dead code |

---

## 6. Definitions NOT Being Removed

For clarity, here is what stays:

### ModalSaturation.lean (Phases 1-5 minus witness family):
- `diamondFormula`, `asDiamond`, `needs_modal_witness`
- `is_modally_saturated`, `is_modally_saturated_iff_no_needs_witness`
- `diamond_excludes_box_neg`, `diamond_and_not_psi_implies_neg`
- `diamond_implies_psi_consistent`
- `extendToMCS`, `extendToMCS_contains`, `extendToMCS_is_mcs`
- `dne_theorem`, `dni_theorem`, `box_dne_theorem`
- `mcs_contrapositive`
- `saturated_modal_backward`
- `SaturatedBFMCS`, `SaturatedBFMCS.modal_backward`
- `axiom_5_negative_introspection`, `neg_box_to_box_neg_box`, `mcs_neg_box_implies_box_neg_box`

### Construction.lean:
- `ContextConsistent`, `contextAsSet`, `list_consistent_to_set_consistent`
- `singleFamilyBFMCS` (has sorry but is used by `construct_temporal_bfmcs`)
- `lindenbaumMCS`, `lindenbaumMCS_extends`, `lindenbaumMCS_is_mcs`
- `lindenbaumMCS_set`, `lindenbaumMCS_set_extends`, `lindenbaumMCS_set_is_mcs`

### WitnessGraph.lean:
- All of Phase 1-3 (data structures, obligation processing, witness existence)
- All of Phase 5 enriched chain (enrichedForwardChain, enrichedBackwardChain, enrichedChainBFMCS)
- Helper lemmas `mcs_G_implies_self`, `mcs_H_implies_self`, `mcs_G_implies_GG` (used by enriched chain)

### ChainBundleBFMCS.lean:
- Everything (this is the correct approach)
- `constantBCFamily` (correct constant family pattern for CanonicalBC)

---

## 7. Summary of Findings

1. **Three constant family definitions** exist in active Metalogic: `constantWitnessFamily`, `constantBFMCS`, `witnessGraphBFMCS`. ALL have zero non-Boneyard consumers and can be safely removed.

2. **The sorry in `fully_saturated_bfmcs_exists_int`** exists because of the constant family approach. Removing the sorry-backed theorem and its wrappers is part of this cleanup, but requires updating `Completeness.lean`.

3. **The `TemporalEvalSaturatedBundle` infrastructure** (lines 338-386 of TemporalCoherentConstruction.lean) is a dead-end approach to temporal saturation of constant families. It should be removed.

4. **The enriched chain in WitnessGraph.lean** (`enrichedChainBFMCS`) is NOT a constant family and should be KEPT. It is a separate, non-constant construction in the same file as `witnessGraphBFMCS`.

5. **Boneyard files** will break but this is acceptable since they are not built.

6. **The `constantBCFamily` in ChainBundleBFMCS.lean** is the CORRECT pattern for witness families because the modified truth lemma only requires temporal coherence of the eval family.
