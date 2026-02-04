# Implementation Plan: Task #856 (Revised)

- **Task**: 856 - Implement multi-family saturated BMCS construction
- **Status**: [IMPLEMENTING]
- **Version**: 002
- **Effort**: 30-48 hours
- **Dependencies**: None (self-contained)
- **Research Inputs**: research-001.md, research-002.md, research-003.md, research-004.md
- **Previous Plan**: implementation-001.md (abandoned - fundamental obstacles)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**REVISED APPROACH**: Complete CoherentConstruction.lean via enumeration with strengthened box-equivalence coherence.

The original plan (implementation-001.md) attempted to resolve 3 sorries in SaturatedConstruction.lean using Zorn's lemma. The implementation summary and research-004.md revealed that this approach has **fundamental mathematical obstacles**: Lindenbaum extension cannot be controlled, and the multi-family BoxContent consistency proof fails because Box chi in one family doesn't imply Box chi in another.

**New Strategy**: The CoherentConstruction.lean approach is viable because:
1. It builds coherence into the witness seed (not post-hoc)
2. Uses proven `constructCoherentWitness` infrastructure
3. Has working `diamond_boxcontent_consistent_constant` lemma for single constant families

**Key Innovation**: Strengthen CoherentBundle coherence to require **box-equivalence** across families: if Box chi is in any family at any time, it's in all families at all times. This makes the K-distribution argument work for multi-family bundles.

### Why Original Plan Failed

From research-004.md analysis:
- **Sorry 1 (line ~979)**: Multi-family BoxContent has chi from different families - need Box chi in source family but only have Box chi in some other family
- **Sorry 2 (line ~999)**: Temporal uniformity fails for non-constant families
- **Sorry 3 (line ~1050)**: Lindenbaum adds arbitrary Box formulas - **FUNDAMENTALLY IMPOSSIBLE to control**

The SaturatedConstruction approach is mathematically sound for S4/S5 logics with positive introspection (Box phi → Box Box phi), but the TM bimodal logic lacks this axiom.

## Goals & Non-Goals

**Goals**:
- Complete CoherentConstruction.lean with zero sorries
- Prove `saturated_extension_exists` axiom via enumeration-based construction
- Enable removal of `singleFamily_modal_backward_axiom` from Construction.lean
- Provide a mathematically correct BMCS construction with full modal saturation

**Non-Goals**:
- Completing SaturatedConstruction.lean (abandoned - fundamental obstacles)
- Completing WeakCoherentBundle.lean (alternative approach, could be pursued separately)
- Refactoring completeness.lean to use the new construction (future task)
- Addressing temporal backward directions (separate Task 857/858)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strengthened coherence too restrictive | High | Low | Verify singleton bundles and witness additions satisfy it |
| Enumeration saturation doesn't terminate | Medium | Low | Use subformula closure for finite case; transfinite induction for general |
| Box-equivalence preservation harder than expected | Medium | Medium | Start with singleton bundles where it's trivial |
| Proof complexity exceeds estimates | Medium | High | Build modular infrastructure; commit incrementally |

## Sorry Characterization

### Current State (CoherentConstruction.lean)

| Location | Type | Description |
|----------|------|-------------|
| Line 779 | Axiom | `saturated_extension_exists` - needs proof via enumeration |

The rest of CoherentConstruction.lean is proven:
- `diamond_boxcontent_consistent_constant`: PROVEN (no sorry)
- `constructCoherentWitness`: PROVEN (no sorry)
- `CoherentBundle.toBMCS`: PROVEN (no sorry)

### Expected Resolution

This plan resolves the `saturated_extension_exists` axiom by:
1. Defining strengthened box-equivalence coherence
2. Proving it's preserved by witness addition
3. Proving multi-family consistency with box-equivalence
4. Implementing enumeration-based saturation

### Remaining Debt After Implementation

- 0 sorries expected in CoherentConstruction.lean
- 0 axioms expected (saturated_extension_exists becomes theorem)
- SaturatedConstruction.lean sorries remain (documented as intractable)
- `singleFamily_modal_backward_axiom` can be removed from Construction.lean

## Implementation Phases

### Phase 1: Strengthen CoherentBundle Coherence [COMPLETED]

**Goal**: Define and implement box-equivalence coherence requirement.

**Mathematical Definition**:
```
box_equivalent(families) :=
  ∀ chi, (∃ fam ∈ families, ∃ t, Box chi ∈ fam.mcs t) →
         (∀ fam' ∈ families, ∀ t', Box chi ∈ fam'.mcs t')
```

This is **stronger** than the current MutuallyCoherent, which only requires chi agreement.

**Tasks**:
- [ ] Define `BoxEquivalent` predicate for family sets
- [ ] Add `box_equivalent` field to CoherentBundle structure (or prove it follows from existing structure)
- [ ] Prove `singleton_box_equivalent`: A single constant family trivially satisfies box_equivalent
- [ ] Prove `constant_family_box_equivalent`: All constant families with same base MCS are box-equivalent

**Timing**: 4-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add coherence predicate

**Verification**:
- `lake build` passes
- `lean_goal` shows no unsolved goals in new definitions

---

### Phase 2: Prove Singleton Bundles Satisfy Coherence [COMPLETED]

**Goal**: Establish that initial CoherentBundles (from single constant family) satisfy box-equivalence.

**Tasks**:
- [ ] Prove `initialCoherentBundle_box_equivalent`: The bundle from Lindenbaum of Gamma satisfies box_equivalent
- [ ] Verify existing `initialCoherentBundle` construction preserves the property
- [ ] Add documentation explaining why singleton case is trivial

**Timing**: 2-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- `lean_goal` shows no unsolved goals
- `lake build` passes

---

### Phase 3: Prove Witness Addition Preserves Coherence [IN PROGRESS]

**Goal**: Show that adding a CoherentWitness to a box-equivalent bundle produces a box-equivalent bundle.

**Key Insight**: The witness family inherits BoxContent from the existing bundle. Since witness is constant and extends {psi} ∪ BoxContent(existing), any Box chi in the witness was either:
1. Already in BoxContent (hence in all existing families by box-equivalence)
2. A new box added by Lindenbaum

For case 2, we need to show: if Lindenbaum adds Box chi to witness, then chi is in BoxContent of existing bundle (since {psi} ∪ BoxContent ⊢ Box chi by MCS maximality), hence Box chi will be in all families.

**Actually**: This is the same obstacle as before! Lindenbaum can add Box chi where chi is NOT in BoxContent.

**REVISED INSIGHT**: Instead of general box-equivalence, use the fact that for **constant** families, the coherence propagates correctly. The witness family:
1. Is constant (by construction)
2. Contains BoxContent of the source bundle
3. By `diamond_boxcontent_consistent_constant`, the extension is consistent

The key lemma from research-004: **Build coherence into the seed, don't try to control Lindenbaum**.

**Tasks**:
- [ ] Analyze `constructCoherentWitness` in detail to understand how it builds coherence
- [ ] Prove that adding CoherentWitness preserves MutuallyCoherent
- [ ] If full box-equivalence isn't achievable, prove a weaker property sufficient for modal_backward
- [ ] Document the coherence preservation argument

**Timing**: 6-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- `lake build` passes
- Key lemmas compile without sorry

---

### Phase 4: Multi-Family BoxContent Consistency [NOT STARTED]

**Goal**: Prove that if Diamond psi is in a family of a CoherentBundle B, then {psi} ∪ UnionBoxContent(B) is consistent.

**Current State**:
- `diamond_boxcontent_consistent_constant` proves this for a SINGLE constant family
- We need to extend to multiple families

**Strategy**:
- Use the MutuallyCoherent property: if Box chi in fam1.mcs t, then chi in fam2.mcs t for all fam2
- The K-distribution argument: if L ⊢ ⊥ where L ⊆ BoxContent, then Box(L) ⊢ Box(⊥)
- Key insight: We need Box(L) ⊆ source_fam.mcs, not just L ⊆ various families

**If direct proof fails**: Restrict to the "eval-saturation" approach where we only need consistency with the eval_family's BoxContent (sufficient for completeness).

**Tasks**:
- [ ] Attempt direct proof using MutuallyCoherent
- [ ] If blocked, analyze what additional coherence property is needed
- [ ] If necessary, restrict scope to eval-saturation (weaker but sufficient)
- [ ] Document the consistency argument with clear mathematical justification

**Timing**: 8-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- `lean_goal` shows no unsolved goals in consistency lemma
- `lake build` passes

---

### Phase 5: Enumeration-Based Saturation [NOT STARTED]

**Goal**: Implement the saturation algorithm that eliminates the `saturated_extension_exists` axiom.

**Algorithm**:
```
saturate(B0) :=
  let Ds := enumerate_diamonds(closure)  -- finite for subformula closure
  Ds.foldl add_witness_if_needed B0

add_witness_if_needed(B, Diamond psi) :=
  if ∃ fam ∈ B.families, ∃ t, Diamond psi ∈ fam.mcs t
     ∧ ∀ fam' ∈ B.families, ∀ t', psi ∉ fam'.mcs t'
  then B.addWitness(psi)  -- uses constructCoherentWitness
  else B
```

**Tasks**:
- [ ] Implement finite enumeration of Diamond formulas in a closure
- [ ] Implement `saturate` using foldl over the enumeration
- [ ] Prove saturation terminates (finite Diamond formulas in closure)
- [ ] Prove saturation achieves is_saturated_for_closure
- [ ] Replace `saturated_extension_exists` axiom with theorem

**Timing**: 6-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`

**Verification**:
- `axiom saturated_extension_exists` removed
- `theorem saturated_extension_exists` compiles without sorry
- `lake build` passes

---

### Phase 6: Integration and Axiom Elimination [NOT STARTED]

**Goal**: Verify the complete construction works and prepare for axiom removal.

**Tasks**:
- [ ] Run `lake build` to verify all sorries/axioms are resolved in CoherentConstruction
- [ ] Verify `CoherentBundle.toBMCS` produces valid BMCS with modal_backward
- [ ] Verify completeness theorem path: Gamma consistent → saturated CoherentBundle → BMCS with Gamma ⊆ eval_family
- [ ] Document how `construct_bmcs_saturated` (or equivalent) replaces axiom-based construction
- [ ] Create follow-up task for removing `singleFamily_modal_backward_axiom` from Construction.lean
- [ ] Update sorry count in repository_health

**Timing**: 4-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Add documentation
- `specs/state.json` - Update repository_health metrics
- `specs/TODO.md` - Add follow-up task if needed

**Verification**:
- `grep -c "axiom" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0
- `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` returns 0
- All dependent theorems compile correctly

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No new sorries or axioms introduced
- [ ] `saturated_extension_exists` becomes a theorem (not axiom)
- [ ] `CoherentBundle.toBMCS` produces BMCS with `modal_backward` property
- [ ] Completeness path through CoherentConstruction is transitively sorry-free

## Artifacts & Outputs

- `specs/856_implement_multifamily_saturated_bmcs/plans/implementation-002.md` (this file)
- `specs/856_implement_multifamily_saturated_bmcs/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` with resolved axiom
- Follow-up task for axiom elimination from Construction.lean

## Rollback/Contingency

If any phase proves intractable:

1. **Phase 1-2 (coherence definitions)**: If box-equivalence is too strong, use weaker "eval-coherence" that only tracks coherence relative to eval_family

2. **Phase 3 (witness preservation)**: If full coherence preservation fails, restrict to single-step saturation (one witness at a time with explicit coherence verification)

3. **Phase 4 (multi-family consistency)**: If multi-family consistency fails, fall back to eval-saturation approach (only saturate eval_family, sufficient for completeness)

4. **Phase 5 (enumeration)**: If infinite enumeration issues arise, use subformula closure to bound the Diamond formula count

5. **Full fallback**: Preserve current axiom-based approach in Construction.lean, document CoherentConstruction as alternative (not publication-ready)

All changes should be committed incrementally so partial progress is preserved.

## Key Differences from implementation-001.md

| Aspect | implementation-001 | implementation-002 |
|--------|-------------------|-------------------|
| Target file | SaturatedConstruction.lean | CoherentConstruction.lean |
| Approach | Resolve Zorn lemma sorries | Enumeration-based saturation |
| Coherence | box_coherence | MutuallyCoherent + box-equivalence |
| Lindenbaum control | Attempted (impossible) | Build coherence into seed |
| Key lemma | Controlled Lindenbaum | diamond_boxcontent_consistent_constant |
| Sorries to resolve | 3 (lines ~979, ~999, ~1050) | 0 (1 axiom to prove) |

## References

- research-004.md: Detailed analysis of alternative approaches
- implementation-summary-20260204.md: Why original approach failed
- CoherentConstruction.lean lines 249-337: Proven `diamond_boxcontent_consistent_constant`
- CoherentConstruction.lean line 779: Axiom to eliminate
