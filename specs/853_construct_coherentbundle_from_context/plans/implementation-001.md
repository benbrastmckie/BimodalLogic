# Implementation Plan: Task #853

- **Task**: 853 - construct_coherentbundle_from_context
- **Status**: [PARTIAL]
- **Effort**: 6 hours
- **Dependencies**: Tasks #851 (CoherentBundle structure) and #852 (toBMCS) - both COMPLETED
- **Research Inputs**: specs/853_construct_coherentbundle_from_context/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task constructs the main entry point for completeness theorem integration: building a saturated `CoherentBundle` from a consistent context. The construction proceeds in stages: (1) extend the context to an MCS via Lindenbaum, (2) build a constant base family, (3) create an initial singleton CoherentBundle, (4) iteratively or via Zorn's lemma add coherent witnesses for all Diamond formulas until saturation. The key theorem `diamond_boxcontent_consistent_constant` (already proven) provides the consistency foundation for adding witnesses.

### Research Integration

Key findings from research-001.md:
- `CoherentBundle.toBMCS` is fully proven with no sorries
- `constantIndexedMCSFamily` creates the base family from an MCS
- `constructCoherentWitness` creates coherent witnesses for Diamond formulas (proven for constant families)
- The saturation challenge requires preserving `MutuallyCoherent` when adding witnesses
- Solution: build ALL witnesses from the same `UnionBoxContent` so mutual coherence is preserved by construction

## Goals & Non-Goals

**Goals**:
- Define `initialCoherentBundle` that creates a singleton bundle from a constant base family
- Prove `diamond_unionboxcontent_consistent`: extending core consistency lemma to UnionBoxContent
- Define `addCoherentWitness` that adds a witness while preserving mutual coherence
- Implement saturation via Zorn's lemma (or iterative approach if simpler)
- Define `constructCoherentBundleFromContext` as the main entry point
- Define `construct_coherent_bmcs` using the proven `toBMCS` conversion
- Prove context preservation: all formulas from Gamma appear in the resulting BMCS

**Non-Goals**:
- Modifying the existing `CoherentBundle.toBMCS` proof (already complete)
- Implementing non-constant family approaches (the constant-family approach avoids the Lindenbaum control problem)
- Full temporal saturation (the constant-family approach makes temporal coherence trivial)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| UnionBoxContent consistency proof complexity | High | Medium | Proof structure mirrors `diamond_boxcontent_consistent_constant`; use same approach |
| Zorn's lemma termination complexity | Medium | Medium | Can fall back to iterative approach for finite closure |
| Mutual coherence preservation on witness addition | High | Low | Build witness with full UnionBoxContent; coherence by construction |
| Integration issues with existing infrastructure | Low | Low | All required components already exist and are proven |

## Sorry Characterization

### Pre-existing Sorries
- 0 sorries in `CoherentConstruction.lean` (target module)
- 3 sorries in `SaturatedConstruction.lean` (different code path, not used here)
- 1 axiom `singleFamily_modal_backward_axiom` in `Construction.lean` (this task aims to eliminate its need)

### Expected Resolution
- This task does not resolve existing sorries but provides an alternative axiom-free path
- The `singleFamily_modal_backward_axiom` becomes unnecessary when using `CoherentBundle.toBMCS`

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- The axiom-based path in `Construction.lean` remains as an alternative (still valid)
- The 3 sorries in `SaturatedConstruction.lean` remain (different approach, not blocked by this task)
- Publication via the CoherentBundle path will be unblocked

## Implementation Phases

### Phase 1: Initial CoherentBundle Construction [COMPLETED]

**Goal:** Define `initialCoherentBundle` that creates a singleton bundle from a constant base family, and prove it is valid.

**Tasks**:
- [ ] Define `initialCoherentBundle` taking a constant `IndexedMCSFamily` and returning a `CoherentBundle`
- [ ] Prove the families field is `{base}` (singleton set)
- [ ] Prove `all_constant` using the input hypothesis
- [ ] Prove `nonempty` via `Set.singleton_nonempty`
- [ ] Prove `mutually_coherent` via `MutuallyCoherent_singleton` (already exists)
- [ ] Prove `initialCoherentBundle_is_constant` helper lemma
- [ ] Add `initialCoherentBundle_eval_family_eq` lemma

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add initial bundle definition and lemmas

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CoherentConstruction` succeeds
- No new sorries introduced

---

### Phase 2: UnionBoxContent Consistency Lemma [COMPLETED - SINGLETON ONLY]

**Goal:** Prove `diamond_unionboxcontent_consistent`: if Diamond psi is in any family of a CoherentBundle, then `{psi} U UnionBoxContent(B.families)` is consistent.

**Tasks**:
- [ ] Define `UnionWitnessSeed(B, psi) := {psi} U UnionBoxContent(B.families)`
- [ ] Prove `diamond_unionboxcontent_consistent` theorem
  - Structure mirrors `diamond_boxcontent_consistent_constant`
  - Key insight: by `MutuallyCoherent`, all families contain `UnionBoxContent`
  - The proof uses the same K-distribution chain argument
- [ ] Prove `UnionBoxContent_eq_BoxContent_for_singleton` helper (for singleton bundles)
- [ ] Add supporting lemmas for relating UnionBoxContent to individual family BoxContent

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add UnionWitnessSeed and consistency proof

**Verification**:
- `lake build` succeeds
- No sorries in new code
- Proof follows structure of `diamond_boxcontent_consistent_constant`

---

### Phase 3: Witness Addition with Mutual Coherence [SKIPPED]

**Goal:** Define `addCoherentWitness` that adds a witness family to a CoherentBundle while preserving mutual coherence.

**Tasks**:
- [ ] Define `constructCoherentWitnessForBundle`: build witness from UnionWitnessSeed
  - Uses `set_lindenbaum` on `UnionWitnessSeed`
  - Creates constant family via `constantWitnessFamily`
- [ ] Prove the witness contains `UnionBoxContent` (by construction from seed)
- [ ] Define `addCoherentWitness`: add witness to bundle families
- [ ] Prove `addCoherentWitness_all_constant`: new bundle has all constant families
- [ ] Prove `addCoherentWitness_mutually_coherent`: new bundle preserves mutual coherence
  - Key: witness was built with `UnionBoxContent` in its seed
  - New `UnionBoxContent` may grow, but all families still contain it
- [ ] Prove `addCoherentWitness_preserves_eval_family`: evaluation family unchanged

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add witness addition infrastructure

**Verification**:
- `lake build` succeeds
- No sorries in new code
- `addCoherentWitness` returns valid `CoherentBundle`

---

### Phase 4: Saturation via Zorn's Lemma [AXIOMATIZED]

**Goal:** Construct a saturated CoherentBundle using Zorn's lemma or iterative saturation.

**Tasks**:
- [ ] Define partial order on CoherentBundles by family set inclusion
- [ ] Prove chains have upper bounds (union of families preserves mutual coherence)
  - Define `ChainUpperBound`: union of families from chain
  - Prove `MutuallyCoherent` for the union (all families contain their BoxContent, union contains all)
  - Prove `all_constant` for union (each family is constant)
- [ ] Apply `zorn_subset_nonempty` to get maximal CoherentBundle
- [ ] Prove maximal bundle is saturated
  - Contraposition: if not saturated, exists unsatisfied Diamond
  - Can add witness via `addCoherentWitness`, contradicting maximality
- [ ] Alternative: implement finite iterative saturation for bounded Diamond closure
  - Collect all `neg(Box phi)` formulas in closure of context
  - Iterate adding witnesses until all satisfied

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add Zorn-based saturation

**Verification**:
- `lake build` succeeds
- No sorries in saturation proof
- `saturateCoherentBundle` returns saturated bundle

---

### Phase 5: Main Entry Point and Integration [COMPLETED]

**Goal:** Define the main entry points `constructCoherentBundleFromContext` and `construct_coherent_bmcs`, plus context preservation theorem.

**Tasks**:
- [ ] Define `constructCoherentBundleFromContext`: consistent context to saturated bundle
  - Step 1: `list_consistent_to_set_consistent` to get set consistency
  - Step 2: `set_lindenbaum` to extend to MCS
  - Step 3: `constantIndexedMCSFamily` to build base family
  - Step 4: `initialCoherentBundle` to create singleton bundle
  - Step 5: `saturateCoherentBundle` to add all witnesses
  - Return: `{ B : CoherentBundle D // B.isSaturated }`
- [ ] Define `construct_coherent_bmcs`: consistent context to BMCS
  - Calls `constructCoherentBundleFromContext`
  - Calls `CoherentBundle.toBMCS` with saturation proof
- [ ] Prove `construct_coherent_bmcs_contains_context`:
  - All formulas in Gamma are in `eval_family.mcs t` for any time `t`
  - Follows from: Lindenbaum extension contains Gamma, constant family has same MCS at all times
- [ ] Add `construct_coherent_bmcs_eval_family_is_base` lemma
- [ ] Document the axiom-free path in module docstring

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add main entry points

**Verification**:
- `lake build` succeeds with no errors
- No sorries in final construction
- Context preservation theorem proven
- Module compiles as axiom-free alternative to `Construction.lean`

## Testing & Validation

- [ ] `lake build` succeeds for entire project
- [ ] No new sorries introduced (verify with `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`)
- [ ] `constructCoherentBundleFromContext` type-checks
- [ ] `construct_coherent_bmcs` type-checks
- [ ] `construct_coherent_bmcs_contains_context` is proven (no sorry)
- [ ] The main entry point can be used in completeness theorem (type compatibility)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Extended with saturation construction
- `specs/853_construct_coherentbundle_from_context/plans/implementation-001.md` - This plan
- `specs/853_construct_coherentbundle_from_context/summaries/implementation-summary-YYYYMMDD.md` - Final summary

## Rollback/Contingency

If the Zorn-based saturation proves too complex:
1. Implement finite iterative saturation instead (Phase 4 alternative)
2. Restrict to formulas in the closure of the original context
3. The finite approach is simpler but requires tracking the Diamond formula set

If mutual coherence preservation fails:
1. Review the witness construction to ensure it includes full UnionBoxContent
2. May need to iterate: add witness, recompute UnionBoxContent, verify all families still contain it
3. Document any additional invariants needed

If integration with completeness theorem encounters issues:
1. Verify type compatibility between `construct_coherent_bmcs` and existing BMCS consumers
2. May need adapter lemmas for specific type constraints
