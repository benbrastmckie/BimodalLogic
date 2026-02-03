# Implementation Plan: Task #842 (Revised)

- **Task**: 842 - Formalize Zorn's lemma proof in exists_fullySaturated_extension
- **Status**: [NOT STARTED]
- **Version**: 002 (supersedes implementation-001.md)
- **Effort**: 12-16 hours
- **Dependencies**: None (follows from task #841)
- **Research Inputs**:
  - specs/842_formalize_zorn_lemma_exists_fullySaturated_extension/reports/research-001.md
  - specs/842_formalize_zorn_lemma_exists_fullySaturated_extension/reports/research-002.md
  - specs/842_formalize_zorn_lemma_exists_fullySaturated_extension/reports/research-003.md (primary basis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**NEW APPROACH**: Pre-Coherent Bundle Construction

The previous approach (implementation-001.md) encountered irreducible sorries due to the "uncontrolled Lindenbaum" problem. This revised plan implements a fundamentally different construction based on research-003.md:

1. **Define pre-coherent families** with S-bounded Box formulas (Box contents must be in closure S)
2. **Use restricted Lindenbaum** that skips Box formulas with contents outside S
3. **Construct the bundle as a product** of ALL pre-coherent families
4. **Saturation follows automatically** from the product structure

This approach avoids the Lindenbaum control problem entirely by defining the property families must have, then taking ALL families with that property.

### Why the Previous Approach Failed

The original approach tried to:
1. Start with a box-coherent set M of families
2. Add witnesses iteratively, hoping Lindenbaum doesn't break coherence

This failed because Lindenbaum can add arbitrary `Box alpha` formulas where `alpha` is NOT in existing families, breaking `box_coherence`. The 3 sorries in implementation-001.md all stem from this architectural mismatch.

### Why This Approach Succeeds

The new approach:
1. Defines families that CANNOT have "bad" Box formulas (by construction)
2. Takes the PRODUCT of all such families
3. Box coherence follows from S-boundedness
4. Saturation follows from including all witnesses in the product

## Goals & Non-Goals

**Goals**:
- Replace the sorry-laden construction with a clean, sorry-free alternative
- Prove `exists_fullySaturated_extension` without any axioms
- Achieve publication-ready quality (no sorries, no axioms)
- Archive the old approach once the new one is verified

**Non-Goals**:
- Modifying the existing `BMCS` or `IndexedMCSFamily` interfaces
- Changing the completeness theorem structure
- Supporting more than the current bimodal logic

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restricted Lindenbaum doesn't produce MCS | High | Low | Prove maximality among S-bounded sets (standard technique) |
| Pre-coherent families set is empty | High | Low | Construct witness from Gamma's extension (guaranteed pre-coherent) |
| Box coherence proof subtle | Medium | Medium | Careful case analysis; auxiliary closure lemmas if needed |
| Integration with temporal operators | Medium | Low | Temporal coherence is orthogonal; handled within family |
| Existing code conflicts | Low | Medium | Develop in parallel, swap at the end |

## Sorry Characterization

### Pre-existing Sorries (to be eliminated)
The current `SaturatedConstruction.lean` has sorries from the old approach:
- `exists_fullySaturated_extension` - multiple sorries in Phase 4

### Expected Resolution
- All sorries eliminated by new construction
- Old sorry-laden code can be archived or deleted

### New Sorries
- **None expected**. The Pre-Coherent Bundle approach avoids the Lindenbaum control problem entirely.

### Remaining Debt
After this implementation:
- 0 sorries in `exists_fullySaturated_extension`
- 0 axioms required
- Publication-ready completeness proof

## Implementation Phases

### Phase 1: Foundation - Restricted Lindenbaum [NOT STARTED]

**Goal**: Implement restricted Lindenbaum that produces S-bounded MCSs

**Timing**: 4-5 hours

**Tasks**:
- [ ] Define `S_bounded` predicate for formula sets:
  ```lean
  def S_bounded (M : Set Formula) (S : Set Formula) : Prop :=
    forall phi, phi in M -> phi.is_box -> phi.box_content in S
  ```
- [ ] Define `SaturationClosure` for a context Gamma:
  ```lean
  def SaturationClosure (Gamma : List Formula) : Set Formula :=
    -- Subformula closure of Gamma
    -- Plus contents of any Box/Diamond that could arise
  ```
- [ ] Prove `SaturationClosure` is finite for finite Gamma
- [ ] Implement `restrictedLindenbaum`:
  ```lean
  noncomputable def restrictedLindenbaum
      (base : Set Formula) (h_cons : SetConsistent base)
      (S : Set Formula) (h_base_ok : S_bounded base S) :
      { M : Set Formula // SetMaximalConsistent M /\ base subseteq M /\ S_bounded M S }
  ```
- [ ] Key theorem: restricted Lindenbaum produces maximal S-bounded consistent set

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - Add restricted Lindenbaum
- New file: `Theories/Bimodal/Metalogic/Bundle/SaturationClosure.lean` - Closure definitions

**Verification**:
- `lake build` succeeds
- `restrictedLindenbaum` compiles without sorry
- Unit tests for closure properties

**Key Insight**: The standard Lindenbaum construction iterates:
```
M_{n+1} = if consistent(M_n U {phi_n}) then M_n U {phi_n} else M_n
```

Restricted Lindenbaum adds a filter:
```
M_{n+1} = if phi_n is Box alpha with alpha not in S
          then M_n  -- SKIP
          else if consistent(M_n U {phi_n})
               then M_n U {phi_n}
               else M_n
```

---

### Phase 2: Pre-Coherent Families [NOT STARTED]

**Goal**: Define pre-coherent indexed families and prove basic properties

**Timing**: 3-4 hours

**Tasks**:
- [ ] Define `PreCoherent` predicate for indexed families:
  ```lean
  def PreCoherent (f : IndexedMCSFamily D) (S : Set Formula) : Prop :=
    -- Each time point is an MCS (already guaranteed by IndexedMCSFamily)
    -- Temporal coherence (G/H) - use existing temporal properties
    -- S-bounded Box formulas at each time
    (forall t phi, Formula.box phi in f.mcs t -> phi in S)
  ```
- [ ] Define `AllPreCoherentFamilies`:
  ```lean
  def AllPreCoherentFamilies (S : Set Formula) : Set (IndexedMCSFamily D) :=
    { f | PreCoherent f S }
  ```
- [ ] Prove `AllPreCoherentFamilies` is nonempty (given consistent context)
- [ ] Construct a pre-coherent family from a consistent context:
  ```lean
  theorem precoherent_family_exists (Gamma : List Formula) (h : ContextConsistent Gamma) :
      exists f : IndexedMCSFamily D, PreCoherent f (SaturationClosure Gamma) /\
                                      ContextInFamily Gamma f
  ```

**Files to modify**:
- New file: `Theories/Bimodal/Metalogic/Bundle/PreCoherent.lean`

**Verification**:
- `lake build` succeeds
- `precoherent_family_exists` compiles without sorry
- All definitions type-check

**Key Insight**: Pre-coherent families are "well-behaved by construction". We don't try to add witnesses to an existing structure; instead, we define what it means to be a valid witness and include ALL valid witnesses.

---

### Phase 3: Box Coherence from Pre-Coherence [NOT STARTED]

**Goal**: Prove that the product of all pre-coherent families is automatically box-coherent

**Timing**: 3-4 hours

**Tasks**:
- [ ] Prove the key theorem:
  ```lean
  theorem precoherent_bundle_is_box_coherent (S : Set Formula) :
      box_coherence_pred (AllPreCoherentFamilies S)
  ```
- [ ] Proof sketch:
  1. Let f, g in AllPreCoherentFamilies S
  2. Suppose Box phi in f.mcs t
  3. By PreCoherent, phi in S
  4. Need: phi in g.mcs t
  5. Key: if phi in S and g is pre-coherent, then either phi in g.mcs t or neg phi in g.mcs t
  6. Show that if neg phi in g.mcs t, we get inconsistency (contradiction with Box phi "forcing" phi)
- [ ] May need auxiliary lemma about S-closure properties:
  ```lean
  lemma box_content_forced (S : Set Formula) (h_closed : is_box_closed S)
      (f g : IndexedMCSFamily D) (hf : PreCoherent f S) (hg : PreCoherent g S)
      (t : D) (phi : Formula) (h_box : Formula.box phi in f.mcs t) :
      phi in g.mcs t
  ```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/PreCoherent.lean` - Add coherence theorem

**Verification**:
- `precoherent_bundle_is_box_coherent` compiles without sorry
- `lake build` succeeds

**Key Insight**: The crucial property is that if `Box phi` is in ANY pre-coherent family at time t, then `phi` must be in ALL pre-coherent families at time t. This follows from S-boundedness and the fact that all families share the same S.

---

### Phase 4: Modal Saturation [NOT STARTED]

**Goal**: Prove that the pre-coherent bundle is modally saturated

**Timing**: 3-4 hours

**Tasks**:
- [ ] Prove saturation theorem:
  ```lean
  theorem precoherent_bundle_is_saturated (S : Set Formula)
      (h_S : is_saturation_closure S Gamma) :
      is_modally_saturated_bundle (AllPreCoherentFamilies S)
  ```
- [ ] Proof sketch:
  1. Suppose Diamond psi in f.mcs t for some pre-coherent f
  2. By saturation closure property, psi in S
  3. Construct witness family f' containing psi at time t using restricted Lindenbaum
  4. Show f' is pre-coherent (by construction)
  5. f' is in AllPreCoherentFamilies by definition
  6. Thus Diamond psi has a witness in the bundle
- [ ] Define `is_modally_saturated_bundle`:
  ```lean
  def is_modally_saturated_bundle (B : Set (IndexedMCSFamily D)) : Prop :=
    forall f in B, forall t psi,
      diamondFormula psi in f.mcs t ->
      exists f' in B, psi in f'.mcs t
  ```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/PreCoherent.lean` - Add saturation theorem

**Verification**:
- `precoherent_bundle_is_saturated` compiles without sorry
- `lake build` succeeds

**Key Insight**: Saturation is "free" in the product construction. Because we include ALL pre-coherent families, any witness that could exist does exist. We just need to show that pre-coherent witnesses can be constructed.

---

### Phase 5: Integration and Verification [NOT STARTED]

**Goal**: Connect the new construction to `exists_fullySaturated_extension` and verify zero sorries

**Timing**: 2-3 hours

**Tasks**:
- [ ] Define the new `exists_fullySaturated_extension` using pre-coherent bundle:
  ```lean
  theorem exists_fullySaturated_extension_v2 (C : FamilyCollection D phi) :
      exists C' : FamilyCollection D phi,
        C.families ⊆ C'.families /\
        C'.eval_family = C.eval_family /\
        C'.isFullySaturated
  ```
- [ ] Proof using pre-coherent bundle:
  1. Let S = SaturationClosure (context from C)
  2. Let B = AllPreCoherentFamilies S
  3. Prove C.families ⊆ B (C's families are pre-coherent)
  4. Construct C' with families = B
  5. Show C' is fully saturated (from saturation theorem)
- [ ] Verify the construction connects to existing BMCS interface
- [ ] Run `lake build` and verify NO sorries in the construction
- [ ] Verify downstream theorems still work (`saturate`, `constructSaturatedBMCS`, completeness)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Replace old construction
- May need to update `FamilyCollection` definition to use new bundle

**Verification**:
- `lake build` succeeds with zero sorries in the file
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` returns empty
- Completeness theorem still type-checks

---

### Phase 6: Cleanup and Documentation [NOT STARTED]

**Goal**: Archive old code, update documentation, prepare for publication

**Timing**: 1-2 hours

**Tasks**:
- [ ] Move old sorry-laden construction to Boneyard (or delete if not useful)
- [ ] Update module docstrings explaining the pre-coherent approach
- [ ] Add inline comments explaining key proof steps
- [ ] Update any related documentation
- [ ] Create implementation summary

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Documentation
- `Theories/Bimodal/Boneyard/` - Archive old code if desired

**Verification**:
- Documentation complete
- No references to old construction remain
- `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/` returns no matches in new files
- [ ] `grep -r "axiom" Theories/Bimodal/Metalogic/Bundle/` returns no unwanted axioms
- [ ] Verify `FamilyCollection.saturate` compiles without sorry inheritance
- [ ] Verify `constructSaturatedBMCS` compiles without sorry inheritance
- [ ] Verify completeness theorems still work
- [ ] Check `#print axioms` on key theorems shows no sorryAx

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - Restricted Lindenbaum
- `Theories/Bimodal/Metalogic/Bundle/SaturationClosure.lean` - New file
- `Theories/Bimodal/Metalogic/Bundle/PreCoherent.lean` - New file
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Modified with new proof
- `specs/842_formalize_zorn_lemma_exists_fullySaturated_extension/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the new approach encounters unexpected difficulties:
1. Keep old code functional (don't delete until new code works)
2. Document specific failure point
3. Consider hybrid approaches:
   - Use pre-coherent families for bundle construction
   - Use different saturation strategy if needed
4. Worst case: revert to axiom-based construction with full documentation

The old implementation-001.md phases 1-3 and 5 remain valid code that could be reused if needed.

## Comparison with Previous Plan

| Aspect | implementation-001.md | implementation-002.md |
|--------|----------------------|----------------------|
| Core approach | Sequential saturation | Product construction |
| Lindenbaum | Uncontrolled | S-bounded (controlled) |
| Sorries | 3 irreducible | 0 expected |
| Axioms | N/A (would need axiom) | 0 |
| Effort estimate | 11-14 hours | 12-16 hours |
| Publication ready | No | Yes |
