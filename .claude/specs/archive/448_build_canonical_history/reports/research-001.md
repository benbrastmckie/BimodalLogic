# Research Report: Task #448 - Build canonical_history

**Task**: 448 - Build canonical_history construction
**Date**: 2026-01-13
**Session ID**: sess_1768265631_be2b71
**Started**: 2026-01-13T05:15:00Z
**Completed**: 2026-01-13T06:00:00Z
**Effort**: 6-8 hours (estimated implementation)
**Priority**: Low
**Parent**: Task 257 (Completeness Proofs)
**Dependencies**: Task 447 (Canonical frame and model construction - COMPLETED)
**Sources/Inputs**:
  - Completeness.lean (current state with canonical_frame, canonical_model implemented)
  - WorldHistory.lean (WorldHistory type definition)
  - Truth.lean (Semantic truth evaluation requirements)
  - Task 447 implementation summary
  - Task 133 research-001.md (canonical history approach options)
  - implementation-002.md (Phase 5 plan)
**Artifacts**: This report (.claude/specs/448_build_canonical_history/reports/research-001.md)
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- The `canonical_history` axiom stub (line 2212) must be replaced with a definition that constructs a `WorldHistory canonical_frame` from a `CanonicalWorldState` (maximal consistent set)
- The WorldHistory structure requires: convex domain, state assignment function, and respects_task property
- **Three viable approaches**: (1) Singleton domain at time 0 (simplest MVP), (2) Full domain over all Duration values (most general), (3) Generated domain from temporal formulas in the MCS
- **Recommended approach**: Start with singleton domain, which is sufficient for the base case of the truth lemma and can be extended if temporal cases require witnesses at non-zero times
- Key technical challenge: Proving `respects_task` for non-trivial domains requires constructing MCSs at adjacent times that are related by `canonical_task_rel`
- The existing `canonical_frame`, `canonical_task_rel`, `canonical_nullity`, and `canonical_compositionality` from Task 447 provide the necessary infrastructure

## Context & Scope

### Task Objective

Phase 5 of the completeness proofs: Build the canonical_history construction that threads maximal consistent sets (MCSs) together with the canonical task relation, establishing the temporal backbone for the canonical model. This bridges canonical_frame/model (Phase 4, Task 447) and truth_lemma (Phase 6, Task 449).

### Current State After Task 447

From Task 447, the following are now implemented in Completeness.lean:

1. **Duration Type** (via Task 446): Agnostic duration construction as `Algebra.GrothendieckAddGroup PositiveDuration` with `LinearOrder` and `IsOrderedAddMonoid` instances

2. **CanonicalWorldState** (line 1397-1411):
```lean
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}
```

3. **CanonicalTime** (line 1932): Alias for `Duration`

4. **canonical_task_rel** (lines 1990-2017): Three-part definition with:
   - Modal transfer: `forall phi, box phi in S -> phi in T`
   - Future transfer (conditional on t > 0): `forall phi, all_future phi in S -> phi in T`
   - Past transfer (conditional on t < 0): `forall phi, all_past phi in S -> phi in T`

5. **canonical_nullity** (lines 2025-2056): Proven

6. **canonical_compositionality** (lines 2058-2131): Partially proven (modal case complete, temporal cases have `sorry`)

7. **canonical_frame** (lines 2133-2155): Defined as `TaskFrame Duration`

8. **canonical_model** (lines 2180-2189): Defined with `canonical_valuation`

9. **canonical_history** (lines 2197-2212): **AXIOM STUB** - This is what Task 448 must implement

### The Axiom to Replace

```lean
axiom canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame
```

Current docstring indicates:
- Domain: All integers (representing all times) - but this is from before Duration was integrated
- States: Map each time t to a set-based MCS
- Convexity: Automatically satisfied if domain = all Duration
- Task relation respect: By construction of canonical_task_rel

## Findings

### 1. WorldHistory Type Requirements

From WorldHistory.lean (lines 69-98), the WorldHistory structure requires:

```lean
structure WorldHistory {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (F : TaskFrame T) where
  domain : T → Prop
  convex : ∀ (x z : T), domain x → domain z → ∀ (y : T), x ≤ y → y ≤ z → domain y
  states : (t : T) → domain t → F.WorldState
  respects_task : ∀ (s t : T) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

For `canonical_frame`:
- `T = Duration`
- `F.WorldState = CanonicalWorldState`
- `F.task_rel = canonical_task_rel`

### 2. Three Implementation Approaches

#### Approach 1: Singleton Domain (MVP)

**Definition**:
```lean
def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun t => t = 0
  convex := by
    intros x z hx hz y hxy hyz
    -- x = 0 and z = 0 implies x = y = z = 0
    simp only at hx hz
    have h1 : x = y := le_antisymm hxy (by simp [hx]; exact le_of_eq (hz.symm) ▸ hyz)
    exact h1 ▸ hx
  states := fun t ht => by simp only at ht; exact ht ▸ S
  respects_task := by
    intros s t hs ht hst
    simp only at hs ht
    -- s = 0 and t = 0, so t - s = 0
    have h : t - s = 0 := by simp [hs, ht]
    rw [h]
    -- Need: canonical_task_rel S 0 S
    exact canonical_nullity S
```

**Pros**:
- Simplest implementation
- Convexity trivial (singleton is convex)
- respects_task uses only nullity (already proven)
- Sufficient for atoms, bottom, implication cases in truth lemma

**Cons**:
- Temporal formulas (Past, Future) quantify over times in domain - singleton domain means no past/future times exist
- May cause issues in truth lemma temporal cases (vacuously true or blocked)

#### Approach 2: Full Domain (Most General)

**Definition concept**:
```lean
def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => S_at_time t  -- Must construct MCS at each time
  respects_task := by
    intros s t hs ht hst
    -- Need: canonical_task_rel (S_at_time s) (t - s) (S_at_time t)
    sorry  -- Requires existence lemmas
```

**Challenge**: Must construct `S_at_time : Duration -> CanonicalWorldState` such that:
1. `S_at_time 0 = S` (the given MCS)
2. For any s <= t: `canonical_task_rel (S_at_time s) (t - s) (S_at_time t)`

This requires **existence lemmas**:
- Forward extension: Given MCS Gamma, construct MCS Delta such that `canonical_task_rel Gamma d Delta` for d > 0
- Backward extension: Given MCS Gamma, construct MCS Delta such that `canonical_task_rel Delta d Gamma` for d > 0

**Pros**:
- Full temporal domain enables non-trivial quantification in truth lemma
- Most faithful to semantic requirements

**Cons**:
- Requires proving existence of successor/predecessor MCSs (complex)
- May require Choice axiom for non-constructive selection
- The existence lemmas need careful modal/temporal saturation arguments

#### Approach 3: Generated Domain

**Concept**: Build domain from temporal formulas present in S:
- Include 0 in domain
- For each `all_future phi` in S, include positive times
- For each `all_past phi` in S, include negative times

**Complexity**: Medium, but still requires existence lemmas for times beyond 0.

### 3. Truth Lemma Requirements

From Truth.lean (lines 95-102), truth evaluation for temporal operators:

```lean
| Formula.all_past φ => ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ
| Formula.all_future φ => ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ
```

**Implications**:
- For singleton domain at t = 0:
  - `all_past` case: No s < 0 in domain, so vacuously true
  - `all_future` case: No s > 0 in domain, so vacuously true
- This might break the truth lemma correspondence:
  - `all_future phi in S` should correspond to `truth_at ... phi.all_future`
  - If domain is singleton, temporal truth is vacuously true regardless of S membership

**Critical Insight**: The truth lemma temporal cases may REQUIRE non-singleton domain to establish the correspondence correctly. Specifically:
- If `all_future phi NOT_IN S`, we need a time s > 0 in domain where `phi` is false to show `not (truth_at ... phi.all_future)`
- Singleton domain cannot provide such witnesses

### 4. Existence Lemmas for Full Domain

To implement the full domain approach, we need:

#### Forward Existence Lemma

```lean
lemma exists_future_extension (S : CanonicalWorldState) (d : Duration) (hd : d > 0) :
    ∃ T : CanonicalWorldState, canonical_task_rel S d T
```

**Proof Strategy**:
1. Define candidate set: `T_candidate = {phi | all_future phi in S.val} ∪ {phi | box phi in S.val}`
2. Show T_candidate is consistent
3. Extend to maximal consistent set via Lindenbaum
4. Show the resulting MCS satisfies canonical_task_rel

**Key Lemmas Needed**:
- Future saturation: If `all_future phi in S` and S is MCS, then `phi` can be consistently added to T_candidate
- Modal transfer preservation: The box formulas transfer correctly

#### Backward Existence Lemma

```lean
lemma exists_past_extension (S : CanonicalWorldState) (d : Duration) (hd : d > 0) :
    ∃ T : CanonicalWorldState, canonical_task_rel T d S
```

Similar structure using `all_past` formulas.

### 5. Recommended Implementation Strategy

Given the analysis, I recommend a **phased approach**:

**Phase 5A: Singleton Domain MVP** (2-3 hours)
- Implement canonical_history with singleton domain at 0
- Convexity and respects_task are trivial
- Verify it compiles and integrates with canonical_model

**Phase 5B: Assess Truth Lemma Impact** (during Task 449)
- Attempt truth lemma proofs with singleton domain
- Identify if/where temporal cases fail
- Document specific requirements

**Phase 5C: Full Domain Extension** (if needed, 4-6 hours)
- Implement existence lemmas
- Replace singleton with full domain
- Re-verify respects_task

This approach minimizes upfront complexity while ensuring we can extend if needed.

### 6. Related Mathlib Patterns

From LeanSearch/LeanFinder:
- `FirstOrder.Language.Theory.IsMaximal` - Similar concept of maximal consistent theories
- `FirstOrder.Language.completeTheory` - Complete theory construction from models

However, Mathlib's first-order model theory is significantly more general and doesn't directly provide temporal history constructions. The codebase-specific patterns from WorldHistory.lean are more relevant.

### 7. Duration-Specific Considerations

From Task 446/447, `Duration` is constructed as:
- Grothendieck group of `PositiveDuration`
- Has `LinearOrder` instance with some `sorry` proofs
- Comparison operators (>, <, >=, <=) are available

For the canonical_history implementation:
- `0 : Duration` exists (from AddCommGroup)
- Comparison with 0 uses LinearOrder instance
- The sign analysis in canonical_task_rel uses these comparisons

### 8. Gap Analysis: Temporal Compositionality

Task 447 noted that `canonical_compositionality` has `sorry` placeholders for temporal cases. The issue:
- Current definition transfers CONTENTS of G/H formulas, not the formulas themselves
- For compositionality, need G-formula persistence: `all_future phi in S -> all_future phi in T`

**Impact on canonical_history**: If compositionality is incomplete, the respects_task proof for full domain approach will be blocked at non-singleton cases.

**Recommendation**: The singleton domain approach avoids this issue entirely since respects_task only needs nullity.

## Decisions

1. **Start with singleton domain MVP**: Simplest implementation that compiles and may suffice
2. **Defer full domain to Phase 5B/5C**: Only implement if truth lemma requires it
3. **Document temporal limitation**: Singleton domain means temporal quantification is vacuous
4. **Track dependency on compositionality**: Full domain approach is blocked until temporal compositionality is fixed

## Recommendations

### Implementation Order

1. **Implement singleton canonical_history** (2-3 hours)
   ```lean
   def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
     domain := fun t => t = 0
     convex := <trivial proof>
     states := fun t ht => <use S at time 0>
     respects_task := <use canonical_nullity>
   ```

2. **Add documentation** noting:
   - Singleton domain is MVP
   - Temporal formulas will be vacuously satisfied
   - Extension to full domain requires existence lemmas

3. **Verify compilation** with canonical_model and existing infrastructure

### Verification Checklist

- [ ] `canonical_history` compiles without `sorry`
- [ ] Type of `canonical_history` is `CanonicalWorldState -> WorldHistory canonical_frame`
- [ ] `canonical_history` integrates with `canonical_model`
- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] No regression in existing proofs

### Future Work (Phase 5B/5C if needed)

If truth lemma temporal cases require witnesses:

1. **Implement forward existence lemma**
2. **Implement backward existence lemma**
3. **Fix temporal compositionality** in canonical_task_rel (Task 447 follow-up)
4. **Replace singleton domain** with full domain using existence lemmas

## Risks & Mitigations

### Risk 1: Truth Lemma Temporal Cases Fail

**Risk**: Singleton domain makes temporal quantification vacuously true, breaking truth lemma correspondence.

**Likelihood**: Medium-High

**Mitigation**:
- Document limitation clearly
- Have extension plan ready (Phase 5B/5C)
- May need to fix before Task 449 completes

### Risk 2: Compositionality Dependency

**Risk**: Full domain approach blocked by incomplete temporal compositionality from Task 447.

**Likelihood**: High (known issue)

**Mitigation**:
- Singleton domain MVP avoids this entirely
- Create follow-up task to complete temporal compositionality
- Defer full domain until compositionality is proven

### Risk 3: Duration Sorry Proofs

**Risk**: Duration type has some `sorry` proofs from Task 446.

**Likelihood**: Low impact for Task 448

**Mitigation**:
- Singleton domain uses only `0` and basic equality
- Full domain would need LinearOrder properties more heavily
- Document any new dependencies

### Risk 4: Existence Lemmas Complexity

**Risk**: Forward/backward existence lemmas may be more complex than estimated.

**Likelihood**: Medium

**Mitigation**:
- Defer to Phase 5C
- Study modal logic completeness proofs for patterns
- May need additional saturation lemmas for MCSs

## Appendix

### Files to Modify

- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace axiom with definition

### Key Code Locations

- WorldHistory structure: `Theories/Bimodal/Semantics/WorldHistory.lean` lines 69-98
- canonical_history axiom: `Theories/Bimodal/Metalogic/Completeness.lean` lines 2197-2212
- canonical_nullity: `Theories/Bimodal/Metalogic/Completeness.lean` lines 2025-2056
- canonical_task_rel: `Theories/Bimodal/Metalogic/Completeness.lean` lines 1990-2017
- truth_at definition: `Theories/Bimodal/Semantics/Truth.lean` lines 95-102

### References

1. Modal Logic, Blackburn et al., Chapter 4 (Canonical Models)
2. Task 447 implementation summary
3. Task 133 research-001.md - canonical history approach options
4. implementation-002.md (Phase 5 plan from Task 257)
5. WorldHistory.lean - WorldHistory type documentation
6. Truth.lean - Semantic truth evaluation

### Implementation Template

```lean
/--
Canonical world history constructed from a maximal consistent set.

**MVP Implementation**: Uses singleton domain at time 0.

**Construction**:
- Domain: Only includes time 0
- States: Returns the given MCS at time 0
- Convexity: Trivially satisfied (singleton is convex)
- Task relation respect: Uses canonical_nullity for t - s = 0 case

**Limitation**: Singleton domain means temporal operators (Past, Future)
quantify vacuously (no times exist in domain other than 0).
See Phase 5B/5C for potential extension to full domain.
-/
def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun t => t = 0
  convex := by
    intros x z hx hz y hxy hyz
    simp only at hx hz ⊢
    -- x = 0 and z = 0, with x ≤ y ≤ z implies y = 0
    have hxz : x = z := by rw [hx, hz]
    have hxy' : x = y := le_antisymm hxy (hxz ▸ hyz)
    exact hxy' ▸ hx
  states := fun t ht => by
    simp only at ht
    exact ht ▸ S
  respects_task := by
    intros s t hs ht hst
    simp only at hs ht
    -- s = 0 and t = 0, so t - s = 0
    have h_diff : t - s = 0 := by rw [hs, ht]; ring
    rw [h_diff]
    -- states_at 0 is S, so need canonical_task_rel S 0 S
    exact canonical_nullity S
```

## Next Steps

1. Run `/plan 448` to create implementation plan based on this research
2. Implement singleton domain MVP
3. Verify compilation
4. Document limitations for Task 449 (truth lemma)
