# Research Report: Task #856

**Task**: Implement multi-family saturated BMCS construction
**Date**: 2026-02-04
**Focus**: Implement multi-family saturated BMCS construction to eliminate singleFamily_modal_backward_axiom
**Session ID**: sess_1738668430_f79144

## Summary

This task aims to eliminate `singleFamily_modal_backward_axiom` (Construction.lean:228) by implementing a multi-family saturated BMCS construction. The current `bmcs_weak_completeness` depends on this axiom through the `construct_bmcs` function. Three approaches exist: (1) the current single-family approach with axiom, (2) CoherentBundle with `saturated_extension_exists` axiom, and (3) WeakCoherentBundle with `weak_saturated_extension_exists` axiom. The WeakCoherentBundle approach is the most promising path forward, but all approaches currently require axioms. SaturatedConstruction.lean has 3 sorries in the Zorn's lemma formalization that represent the key implementation gap.

## 1. Current Architecture Analysis

### 1.1 Axiom Dependencies

| Axiom | File | Line | Purpose |
|-------|------|------|---------|
| `singleFamily_modal_backward_axiom` | Construction.lean | 228 | phi in single-family MCS implies Box phi in MCS |
| `saturated_extension_exists` | CoherentConstruction.lean | 779 | Saturated CoherentBundle extension exists |
| `weak_saturated_extension_exists` | WeakCoherentBundle.lean | 826 | Saturated WeakCoherentBundle extension exists |

### 1.2 Dependency Chain to Completeness

```
bmcs_weak_completeness (Completeness.lean:234)
  <- bmcs_representation (Completeness.lean:99)
    <- construct_bmcs (Construction.lean:328)
      <- singleFamilyBMCS (Construction.lean:242)
        <- singleFamily_modal_backward_axiom (Construction.lean:228)
```

### 1.3 File Structure

| File | Purpose | Status |
|------|---------|--------|
| `BMCS.lean` | BMCS structure definition | Complete, no sorries |
| `Construction.lean` | Single-family BMCS construction | 1 axiom (`singleFamily_modal_backward_axiom`) |
| `ModalSaturation.lean` | Saturation predicate & proof | Complete, no sorries |
| `SaturatedConstruction.lean` | Multi-family saturation via Zorn | 3 sorries in existence proof |
| `CoherentConstruction.lean` | CoherentBundle approach | 1 axiom (`saturated_extension_exists`) |
| `WeakCoherentBundle.lean` | WeakCoherentBundle approach | 1 axiom + 3 sorries |

## 2. The Modal Backward Problem

### 2.1 Mathematical Statement

The `modal_backward` property of BMCS requires:
```lean
modal_backward : forall fam in families, forall phi t,
  (forall fam' in families, phi in fam'.mcs t) -> Box phi in fam.mcs t
```

For a single-family BMCS, this reduces to: `phi in M -> Box phi in M`, which is NOT a theorem of modal logic. The axiom captures this as a metatheoretic fact.

### 2.2 Why Multi-Family Saturation Solves This

A **modally saturated** BMCS satisfies: if `Diamond psi in fam.mcs t`, then there exists `fam' in families` where `psi in fam'.mcs t`.

With saturation, `modal_backward` follows by **contraposition** (proven in ModalSaturation.lean:418-457):
1. Assume phi is in ALL families but Box phi is NOT in fam.mcs t
2. By MCS negation completeness: neg(Box phi) is in fam.mcs t
3. Use box_dne_theorem: neg(Box phi) implies Diamond(neg phi)
4. By saturation: exists fam' where neg phi is in fam'.mcs t
5. But phi is in ALL families including fam' - contradiction with consistency

This proof is complete in `saturated_modal_backward` (ModalSaturation.lean).

## 3. Current Implementation Approaches

### 3.1 SaturatedConstruction.lean Analysis

The file implements a Zorn's lemma approach:

**Complete Infrastructure:**
- `FamilyCollection` structure (lines 224-237)
- `FamilyCollection.isSaturated` predicate (line 243)
- `FamilyCollection.isFullySaturated` predicate (lines 254-257)
- `FamilyCollection.toBMCS` conversion (lines 277-321)
- `initialFamilyCollection` construction (lines 392-407)
- `box_coherence_sUnion` for chain upper bounds (lines 469-487)
- Chain infrastructure and witness construction scaffolding

**Remaining Sorries (3 total):**

1. **Line 714** (in `exists_fullySaturated_extension`): Witness set consistency when `psi in L`
   - Need: modal existence lemma showing `{psi} union BoxContent` is consistent when `Diamond psi` is in fam.mcs t
   - Gap: BoxContent uses formulas from DIFFERENT families at DIFFERENT times

2. **Line 733** (in `exists_fullySaturated_extension`): BoxContent across times
   - Issue: `chi in BoxContent` means `Box chi in fam'.mcs s` for some `fam', s`
   - Need: Either restrict to time t or prove temporal consistency

3. **Line 785** (in `exists_fullySaturated_extension`): Coherent witness construction
   - Issue: New witness's Box formulas may not be in all other families
   - Need: Lindenbaum extension doesn't add "problematic" Box formulas

### 3.2 CoherentConstruction.lean Status

This implements the `CoherentBundle` approach:
- Requires ALL families to be mutually coherent (share UnionBoxContent)
- Uses `saturated_extension_exists` axiom (line 779)
- Complete proofs for singleton bundle case
- Blocked by multi-family coherence gap (Lindenbaum control problem)

### 3.3 WeakCoherentBundle.lean Status

This implements Approach B from research-004.md:
- Separates "core" families (full coherence) from "witness" families (contain BoxClosure only)
- Uses `weak_saturated_extension_exists` axiom (line 826)
- 3 documented sorries (lines 501, 750, 944) for technical gaps
- Most promising approach conceptually

## 4. Key Technical Gaps

### 4.1 The Multi-Family Consistency Gap

**Problem**: For multi-family bundles, proving `{psi} union UnionBoxContent` is consistent requires:
- `BoxContent(fam1)` includes chi where `Box chi in fam1.mcs t`
- `BoxContent(fam2)` includes chi' where `Box chi' in fam2.mcs s`
- K-distribution argument requires Box formulas in the SAME family

**Singleton works**: For one family, `BoxContent = BoxContentAt t` for constant families.

**Multi-family fails**: BoxContent spans multiple families and times; no single MCS contains all Box formulas.

### 4.2 The Lindenbaum Control Problem

**Problem**: When extending a seed to MCS via Lindenbaum, we cannot control which Box formulas are added.

**Consequence**: A witness family W constructed to contain `{psi} union BoxClosure(core)` may have:
- `Box theta in W` for arbitrary theta
- theta may not be in other families
- This breaks box_coherence for the extended bundle

**Why it's fundamental**: MCS negation completeness forces: for every theta, either `Box theta in W` OR `neg(Box theta) in W`. Many Box formulas WILL be added beyond the seed.

## 5. Mathlib Infrastructure Available

### 5.1 Zorn's Lemma

```lean
-- From Mathlib.Order.Zorn
zorn_subset_nonempty : forall S : Set (Set alpha),
  (chains have upper bounds in S) ->
  forall x in S, exists maximal m >= x
```

Already used in SaturatedConstruction.lean for the Zorn application structure.

### 5.2 Chain Infrastructure

```lean
-- From Mathlib.Order.Preorder.Chain
IsChain : (r : alpha -> alpha -> Prop) -> Set alpha -> Prop
Set.Subsingleton.isChain : s.Subsingleton -> IsChain r s
```

Used for chain predicate in saturation proofs.

### 5.3 Already Proven in Codebase

- `consistent_chain_union`: Union of consistent chain is consistent
- `diamond_boxcontent_consistent_constant`: Singleton seed consistency
- `diamond_implies_psi_consistent`: Diamond psi in MCS implies {psi} consistent
- `mcs_contrapositive`: Contraposition in MCS
- `box_dne_theorem`: Box(not not phi) -> Box phi

## 6. Recommended Implementation Strategy

### 6.1 Primary Path: Complete WeakCoherentBundle

The WeakCoherentBundle approach (Task 853's implementation-002.md) is the most promising:

**Current State:**
- Core/witness separation is defined
- `addWitness` function exists with 1 sorry (disjointness)
- `maximal_weak_bundle_is_eval_saturated` proven
- `toWeakBMCS` has 1 sorry (modal_backward for non-eval families)
- `weak_saturated_extension_exists` axiom captures Zorn result

**To Eliminate Axiom:**
1. Prove `addWitness.core_disjoint_witness` (line 501)
   - Need: Fresh MCS from Lindenbaum differs from eval_family
   - Approach: Track MCS identity via seed differences

2. Prove `toWeakBMCS.modal_backward` (line 944)
   - Issue: Requires saturation for ALL families, not just eval_family
   - Solution: Either prove full saturation or restrict modal_backward

3. Instantiate Zorn application (replacing axiom)
   - Infrastructure exists: `chainUpperBound`, `maximal_weak_bundle_is_eval_saturated`
   - Gap: Formally invoking `zorn_subset_nonempty` with bundle ordering

### 6.2 Alternative: Restrict to Eval-Saturation BMCS

A more pragmatic approach: define `EvalBMCS` with relaxed requirements:

```lean
structure EvalBMCS (D : Type*) ... where
  families : Set (IndexedMCSFamily D)
  nonempty : families.Nonempty
  -- Only modal_forward FROM eval_family
  modal_forward_eval : forall phi t,
    Box phi in eval_family.mcs t -> forall fam' in families, phi in fam'.mcs t
  -- Only modal_backward TO eval_family
  modal_backward_eval : forall phi t,
    (forall fam' in families, phi in fam'.mcs t) -> Box phi in eval_family.mcs t
  eval_family : IndexedMCSFamily D
  eval_family_mem : eval_family in families
```

This suffices for completeness since we only evaluate formulas at `eval_family`.

### 6.3 Implementation Phases

**Phase 1: Core Infrastructure (10-15 hours)**
- Define `EvalBMCS` or strengthen `WeakBMCS`
- Prove conversion from saturated WeakCoherentBundle
- Verify completeness theorem still works

**Phase 2: Disjointness Proofs (5-10 hours)**
- Prove `addWitness.core_disjoint_witness`
- Track MCS identity through construction

**Phase 3: Zorn Formalization (15-20 hours)**
- Complete `chainUpperBound` preserves all invariants
- Formally invoke `zorn_subset_nonempty`
- Prove maximality implies saturation

**Phase 4: Integration (5-10 hours)**
- Replace `construct_bmcs` with axiom-free version
- Verify all downstream theorems compile
- Remove axioms from codebase

**Total Estimated Effort: 35-55 hours**

## 7. Sorry and Axiom Summary

### 7.1 Current Technical Debt

| Location | Type | Category | Remediation Path |
|----------|------|----------|------------------|
| Construction.lean:228 | axiom | Single-family backward | Eliminate via multi-family saturation |
| CoherentConstruction.lean:779 | axiom | Saturated extension | Eliminate via Zorn proof |
| WeakCoherentBundle.lean:826 | axiom | Weak saturated extension | Eliminate via Zorn proof |
| SaturatedConstruction.lean:714 | sorry | Consistency (psi in L) | Modal existence lemma |
| SaturatedConstruction.lean:733 | sorry | BoxContent across times | Temporal argument |
| SaturatedConstruction.lean:785 | sorry | Coherent witness | Lindenbaum control or relaxed requirements |
| WeakCoherentBundle.lean:501 | sorry | Disjointness | MCS identity tracking |
| WeakCoherentBundle.lean:750 | sorry | Full saturation | Not needed if using eval-saturation |
| WeakCoherentBundle.lean:944 | sorry | modal_backward | Relaxed requirements or full saturation |

### 7.2 Transitive Dependencies

The completeness theorem `bmcs_weak_completeness` transitively depends on:
- `singleFamily_modal_backward_axiom` (via `construct_bmcs`)

If we switch to `construct_weak_bmcs` or `construct_coherent_bmcs`:
- Would depend on respective axiom instead
- Axiom elimination requires completing the Zorn proofs

## 8. Recommendations

### 8.1 Immediate Actions

1. **Adopt EvalBMCS/WeakBMCS pattern**: The relaxed modal requirements suffice for completeness
2. **Focus on WeakCoherentBundle path**: Most infrastructure exists
3. **Document remaining gaps**: Create subtasks for specific sorries

### 8.2 Implementation Priority

| Priority | Task | Blocks |
|----------|------|--------|
| High | Complete `addWitness` disjointness | Zorn formalization |
| High | Complete Zorn invocation for WeakCoherentBundle | Axiom elimination |
| Medium | Prove `toWeakBMCS.modal_backward` | Full BMCS conversion |
| Low | Prove full saturation (not just eval) | Theoretical completeness |

### 8.3 Risk Assessment

**Low Risk**: Using `EvalBMCS` pattern with relaxed requirements
- Completeness theorem works
- Only evaluates at eval_family anyway

**Medium Risk**: Completing WeakCoherentBundle sorries
- Most infrastructure exists
- Disjointness may require tracking machinery

**High Risk**: Attempting full CoherentBundle saturation
- Multi-family coherence gap is fundamental
- May require different proof strategy

## 9. Next Steps

1. Create implementation plan based on EvalBMCS/WeakBMCS approach
2. Prioritize completing `addWitness.core_disjoint_witness` sorry
3. Formalize Zorn application for WeakCoherentBundle
4. Integrate with completeness theorem
5. Remove `singleFamily_modal_backward_axiom` when path is complete

## References

### Codebase Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BMCS.lean`

### Previous Research
- `specs/853_construct_coherentbundle_from_context/reports/research-004.md` (comparative analysis)
- `specs/853_construct_coherentbundle_from_context/summaries/implementation-summary-20260204.md`

### Mathlib
- `Mathlib.Order.Zorn` - Zorn's lemma variants
- `Mathlib.Order.Preorder.Chain` - Chain infrastructure
