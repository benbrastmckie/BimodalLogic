# Research Report: Task #656

**Task**: Complete the imp and box cases in the truth lemma forward direction for the parametric canonical model
**Date**: 2026-01-26
**Focus**: MCS modus ponens closure (imp case) and witness construction for modal accessibility (box case)
**Language**: lean
**Priority**: Medium

## Summary

Researched the two remaining sorries in `TruthLemma.lean` forward direction (lines 144 and 155). Found that:

1. **Imp case (line 144)**: Requires MCS modus ponens closure lemma, which **already exists** in the Boneyard as `set_mcs_implication_property`
2. **Box case (line 155)**: Requires witness construction for universal quantification over histories - this is the harder case with no direct existing proof
3. Both cases are non-critical to the main representation theorem (which only needs temporal operators)
4. Estimated effort: 8-12 hours total (4-6 for imp, 4-6 for box)

## Context and Background

### Task 654 Accomplishments

From review-20260121-task654.md, Task 654 successfully proved the representation theorem using an indexed MCS family approach. The truth lemma has these gaps documented:

- **Forward direction**: imp case (line 144), box case (line 155)
- **Backward direction**: imp/box/temporal cases (lines 211, 219, 228, 237)

The gaps don't affect the representation theorem because it only requires forward direction for temporal operators (G/H), which are **already proven** (lines 157-177).

### Current File State

**Location**: `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`

**Line 144 (imp case)**:
```lean
| imp psi chi ih_psi ih_chi =>
    intro h_mem
    -- phi = psi -> chi
    -- Need: truth_at psi -> truth_at chi
    simp only [truth_at]
    intro h_psi_true
    -- Apply IH for chi direction
    -- This requires showing chi in mcs t
    -- If (psi -> chi) in mcs t and psi in mcs t, then chi in mcs t by modus ponens closure
    sorry -- Requires proving backward direction first, or modus ponens closure lemma
```

**Line 155 (box case)**:
```lean
| box psi ih =>
    intro h_mem
    -- phi = box psi
    -- Need: forall sigma : WorldHistory, truth_at sigma t psi
    simp only [truth_at]
    intro sigma
    -- Box universally quantifies over ALL histories
    -- This is the hardest case - requires showing psi true on arbitrary histories
    -- The canonical model construction ensures box formulas work correctly
    sorry -- Complex case requiring additional lemmas about histories
```

## Findings

### Finding 1: MCS Modus Ponens Closure Lemma Exists

**Location**: `Theories/Bimodal/Boneyard/Metalogic/Completeness.lean:655-672`

The **exact lemma we need** already exists in the Boneyard:

```lean
/--
Set-based MCS implication property: modus ponens is reflected in membership.

If (φ → ψ) ∈ S and φ ∈ S for a SetMaximalConsistent S, then ψ ∈ S.
-/
theorem set_mcs_implication_property {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_imp : (φ.imp ψ) ∈ S) (h_phi : φ ∈ S) : ψ ∈ S := by
  -- Use set_mcs_closed_under_derivation with L = [φ, φ.imp ψ]
  have h_sub : ∀ χ ∈ [φ, φ.imp ψ], χ ∈ S := by
    intro χ h_mem
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at h_mem
    cases h_mem with
    | inl h_eq => exact h_eq ▸ h_phi
    | inr h_eq => exact h_eq ▸ h_imp
  -- Derive ψ from [φ, φ → ψ]
  have h_deriv : DerivationTree [φ, φ.imp ψ] ψ := by
    have h_assume_phi : [φ, φ.imp ψ] ⊢ φ :=
      DerivationTree.assumption [φ, φ.imp ψ] φ (by simp)
    have h_assume_imp : [φ, φ.imp ψ] ⊢ φ.imp ψ :=
      DerivationTree.assumption [φ, φ.imp ψ] (φ.imp ψ) (by simp)
    exact DerivationTree.modus_ponens [φ, φ.imp ψ] φ ψ h_assume_imp h_assume_phi
  exact set_mcs_closed_under_derivation h_mcs [φ, φ.imp ψ] h_sub h_deriv
```

**Key Dependencies**:
- `set_mcs_closed_under_derivation`: Also in Completeness.lean, proven at line 573-637
- Requires: `SetMaximalConsistent` predicate (available via `Bimodal.Metalogic.Core`)

**Import Path**: Already imported at line 4 of IndexedMCSFamily.lean:
```lean
import Bimodal.Boneyard.Metalogic.Completeness  -- For set_mcs_closed_under_derivation
```

**Action Required**: Re-export or directly invoke from the Boneyard namespace.

### Finding 2: Negation Completeness Available

**Location**: `Theories/Bimodal/Boneyard/Metalogic/Completeness.lean:679-732`

```lean
theorem set_mcs_negation_complete {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) (φ : Formula) :
    φ ∈ S ∨ (Formula.neg φ) ∈ S
```

This is available but **not needed for the forward direction imp case** - only for backward direction.

### Finding 3: Box Case Requires Witness Construction

The box case is more complex. The issue:

**Semantic Requirement**:
```lean
truth_at M tau t (Formula.box psi) ↔
  ∀ sigma : WorldHistory F, truth_at M sigma t psi
```

This requires proving `psi` is true at **every possible world history**, not just the canonical history.

**Canonical Model Approach**: In standard canonical model constructions, the box case uses:
1. **Accessibility relation**: Box formulas propagate only to accessible worlds
2. **Witness construction**: For arbitrary history σ, construct a world where box psi → psi holds

**Current Architecture**: The parametric canonical model uses:
- `UniversalCanonicalFrame` with `canonical_task_rel`
- `IndexedMCSFamily` with varying MCS at each time
- `canonical_history_family` that uses the family's MCS

**Challenge**: The truth_at definition quantifies over **all** WorldHistory structures, not just ones built from the family. This is a universal quantification over an arbitrary type.

**Research Findings**:

1. **Boneyard Approach**: In `Metalogic_v2/Representation/TruthLemma.lean`, the box case is handled trivially:
   ```lean
   theorem truthLemma_box (w : CanonicalWorldState) (φ : Formula) :
       canonicalTruthAt w (Formula.box φ) ↔ Formula.box φ ∈ w.carrier := by
     rfl
   ```
   This works because their `canonicalTruthAt` is **defined as set membership**, not semantic truth.

2. **Semantic Truth Issue**: Our TruthLemma.lean uses actual semantic `truth_at`, which requires quantification over histories.

3. **Possible Approaches**:
   - **Option A**: Restrict to accessible worlds via an accessibility relation
   - **Option B**: Show that box formulas in MCS imply necessity over all histories
   - **Option C**: Use modal axiom K to derive box properties

### Finding 4: Box Case Comment Suggests Architecture Issue

The comment at line 155 says:
```lean
-- The canonical model construction ensures box formulas work correctly
```

But then it has a sorry. This suggests a **potential architectural mismatch**:
- The valuation is defined for box formulas: `valuation := fun w p => Formula.atom p ∈ w.mcs`
- But `truth_at` for box requires **universal quantification over histories**
- The family coherence conditions (forward_G, backward_H, etc.) only handle **temporal** operators

**Key Insight**: The box operator may require **modal accessibility** to be defined, separate from the task relation used for temporal operators.

### Finding 5: Relevant Existing Infrastructure

**Available in Core/MaximalConsistent.lean** (re-exported to Metalogic.Core):
- `maximal_consistent_closed`: MCS are deductively closed
- `maximal_negation_complete`: MCS contain φ or ¬φ
- `theorem_in_mcs`: Theorems are in every MCS

**Available in Boneyard/Metalogic/Completeness.lean**:
- `set_mcs_closed_under_derivation`: Key for modus ponens
- `set_mcs_implication_property`: **Exact lemma for imp case**
- `set_mcs_negation_complete`: For backward direction

**Not Available**:
- Modal accessibility relation between canonical worlds
- Witness construction for box case
- Lemma connecting box ∈ MCS to semantic truth over all histories

## Proof Strategies

### Strategy 1: Imp Case (Line 144)

**Approach**: Use `set_mcs_implication_property` from Boneyard.

**Required Steps**:
1. Import or re-export `Bimodal.Boneyard.Metalogic.set_mcs_implication_property`
2. In the imp case, given:
   - `h_mem : (psi.imp chi) ∈ family.mcs t`
   - `h_psi_true : truth_at M tau t psi`
3. Apply backward IH to get: `psi ∈ family.mcs t`
4. Apply `set_mcs_implication_property` with `h_mem` and backward IH result
5. Get: `chi ∈ family.mcs t`
6. Apply forward IH: `truth_at M tau t chi`

**CRITICAL ISSUE**: This requires the **backward direction** IH to prove `truth_at → membership`. But we're only proving the forward direction!

**Revised Strategy**:
- **If proving forward-only**: We need to assume `psi ∈ family.mcs t` when `truth_at psi` holds
- **Issue**: This is circular - we'd need backward direction proven first
- **Resolution**: The comment at line 144 is correct - "Requires proving backward direction first, or modus ponens closure lemma"

**Alternative Strategy (Without Backward Direction)**:
1. Assume for contradiction: `chi ∉ family.mcs t`
2. By negation completeness: `(¬chi) ∈ family.mcs t`
3. We have: `(psi → chi) ∈ family.mcs t` and `(¬chi) ∈ family.mcs t`
4. By propositional logic: derive `¬psi ∈ family.mcs t`
5. By negation completeness: cannot have both `psi` and `¬psi`
6. This would require backward IH anyway to get contradiction

**CONCLUSION FOR IMP CASE**: Cannot complete without backward direction, or need mutual induction.

### Strategy 2: Box Case (Line 155)

**Approach**: Define modal accessibility and use modal axiom K.

**Challenge**: The current definition of `truth_at` for box is:
```lean
truth_at M tau t (Formula.box psi) ↔
  ∀ sigma : WorldHistory F, truth_at M sigma t psi
```

This requires **all** histories, not just accessible ones.

**Possible Approaches**:

**Approach A - Restrict Semantics**:
Modify `truth_at` definition for box to use modal accessibility:
```lean
truth_at M tau t (Formula.box psi) ↔
  ∀ sigma : WorldHistory F, R tau sigma t → truth_at M sigma t psi
```

But this would require changing `Bimodal.Semantics.Truth`, which is outside task scope.

**Approach B - Prove Universal Property**:
Show that if `box psi ∈ family.mcs t`, then `psi` is true at **all** histories.

Steps:
1. `box psi ∈ family.mcs t`
2. Use modal axiom K and necessitation: if `box psi`, then `psi` is derivable in modal context
3. For arbitrary history σ, construct a world w_σ at time t
4. Show `psi ∈ w_σ.mcs`
5. Apply forward IH: `truth_at M σ t psi`

**Issue**: Step 4 requires constructing an MCS from an arbitrary history, which may not be possible.

**Approach C - Canonical Histories Only**:
Restrict the proof to work only with canonical histories (those built from an IndexedMCSFamily).

This would require:
1. Parameterizing the truth lemma by "canonical histories only"
2. Showing box formulas work for canonical constructions
3. Accepting this limitation

**CONCLUSION FOR BOX CASE**: Requires either:
- Semantic change (add modal accessibility)
- Strong witness construction theorem
- Restriction to canonical histories

Current architecture may not support full proof without changes.

## Alternative: Mutual Induction for Forward+Backward

**Observation**: The standard approach for truth lemmas is **mutual induction** proving both directions simultaneously.

**Structure**:
```lean
theorem truth_lemma_mutual (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t ↔ truth_at (canonical_model D family) (canonical_history_family D family) t phi := by
  induction phi generalizing t with
  | imp psi chi ih_psi ih_chi =>
    constructor
    · -- Forward direction
      intro h_mem h_psi_true
      -- Use backward IH: truth_at psi → psi ∈ mcs
      have h_psi_mem := (ih_psi t).mpr h_psi_true
      -- Apply modus ponens closure
      have h_chi_mem := set_mcs_implication_property (family.is_mcs t) h_mem h_psi_mem
      -- Use forward IH
      exact (ih_chi t).mp h_chi_mem
    · -- Backward direction
      intro h_implies
      -- Uses negation completeness...
```

This allows using backward IH in forward direction proof, breaking the circularity.

## Recommendations

### Recommendation 1: Use Mutual Induction (Preferred)

**Approach**: Restructure as a single biconditional proof with mutual induction.

**Advantages**:
- Imp case becomes straightforward (can use backward IH)
- Standard approach in completeness proofs
- Cleaner architecture

**Disadvantages**:
- Requires proving backward direction simultaneously
- More complex than splitting forward/backward

**Effort**: 8-10 hours
- 2 hours: Restructure to mutual induction
- 4 hours: Complete imp case (both directions)
- 2-4 hours: Box case (depends on semantic resolution)

### Recommendation 2: Complete Forward-Only with Restrictions (Alternative)

**Approach**: Complete forward direction with explicit assumptions.

**For Imp Case**:
- Add assumption that backward direction holds
- Or axiomatize modus ponens closure as a family property

**For Box Case**:
- Restrict to canonical histories
- Or add modal accessibility relation
- Or axiomatize box propagation

**Advantages**:
- Minimal changes to existing structure
- Documents limitations clearly

**Disadvantages**:
- Incomplete truth lemma
- May not support full completeness proof

**Effort**: 4-6 hours

### Recommendation 3: Defer Box Case, Complete Imp Only (Minimal)

**Approach**: Focus only on imp case, leave box for future work.

**Rationale**:
- Task 654 representation theorem doesn't need box operator
- Box case has fundamental architectural questions
- Imp case can be completed with mutual induction

**Advantages**:
- Concrete progress on imp case
- Avoids box complexity

**Disadvantages**:
- Truth lemma still incomplete

**Effort**: 4-6 hours

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Mutual induction increases complexity | Medium | Follow standard textbook approach (Blackburn et al.) |
| Box case requires semantic changes | High | Consult with user on acceptable semantic modifications |
| Backward direction proves harder than expected | Medium | Focus on forward direction with documented limitations |
| Circular dependencies in proof | High | Use mutual induction to break circularity |

## Implementation Phases

### Phase 1: Imp Case via Mutual Induction (4-6 hours)

**Objectives**:
1. Restructure `truth_lemma` as single biconditional with mutual induction
2. Prove imp case forward direction using backward IH
3. Prove imp case backward direction using negation completeness

**Files**:
- `TruthLemma.lean` - Restructure theorem, complete imp case

**Verification**:
- `lake build` succeeds
- No sorries in imp case
- Both directions proven

### Phase 2: Box Case Investigation (2-3 hours)

**Objectives**:
1. Determine feasibility of box case with current semantics
2. Identify needed infrastructure (modal accessibility, etc.)
3. Document approach or limitations

**Files**:
- `TruthLemma.lean` - Investigation comments
- Research notes

**Verification**:
- Clear path forward documented, or
- Limitations clearly stated with rationale

### Phase 3: Box Case Implementation (2-3 hours)

**Objectives**:
1. Implement chosen approach (canonical histories restriction, etc.)
2. Prove box case or document axiomatization

**Files**:
- `TruthLemma.lean` - Complete box case or add axioms

**Verification**:
- `lake build` succeeds
- Box case completed or explicitly axiomatized

## Success Criteria

### Minimum Success (Recommendation 3)
- [ ] Imp case forward direction proven
- [ ] Box case documented with clear limitations
- [ ] No regressions in existing proofs

### Preferred Success (Recommendation 1)
- [ ] Truth lemma restructured as biconditional
- [ ] Imp case fully proven (both directions)
- [ ] Box case completed or axiomatized with justification
- [ ] All sorries in truth_lemma resolved or documented

## References

### Primary Sources
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Target file
- `Theories/Bimodal/Boneyard/Metalogic/Completeness.lean` - MCS properties source
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Family structure

### Key Lemmas
- `set_mcs_implication_property` (Completeness.lean:655-672)
- `set_mcs_closed_under_derivation` (Completeness.lean:573-637)
- `set_mcs_negation_complete` (Completeness.lean:679-732)

### Related Documentation
- `specs/reviews/review-20260121-task654.md` - Task 654 review
- Modal Logic by Blackburn, de Rijke, and Venema - Chapter 4 (Canonical Models)
- Handbook of Modal Logic - Truth Lemma sections

## Next Steps

1. **Consult with user** on preferred approach (mutual induction vs. forward-only)
2. **Determine box case semantics**: Acceptable to restrict or modify?
3. **Create implementation plan** with chosen approach
4. **Begin Phase 1** (imp case via mutual induction)

## Appendix: Search Query Log

Searches performed during research:

1. **Local searches** (lean_local_search):
   - `set_mcs` - Found implication_property and other MCS lemmas
   - `modus_ponens` - Found closure properties
   - `negation_complete` - Found completeness theorems

2. **File reads**:
   - TruthLemma.lean (full file)
   - IndexedMCSFamily.lean (full file)
   - Completeness.lean (600+ lines)
   - MaximalConsistent.lean (500 lines)
   - CanonicalHistory.lean (full file)

3. **Pattern searches**:
   - Searched for existing truth lemma implementations
   - Found Metalogic_v2 approach (different architecture)
   - Located modus ponens closure lemmas

---

**Research completed**: 2026-01-26
**Estimated total effort**: 8-12 hours (4-6 imp, 4-6 box)
**Recommended approach**: Mutual induction (Recommendation 1)
**Critical dependency**: User decision on box case semantics
