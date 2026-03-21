# Research Report: Task #681

- **Task**: 681 - Redesign construct_indexed_family with coherent approach
- **Started**: 2026-01-25T22:10:00Z
- **Completed**: 2026-01-25T22:35:00Z
- **Effort**: 25 minutes
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - Task 658 blocking issue analysis (specs/658_*/summaries/implementation-summary-20260125.md)
  - Boneyard canonical_task_rel pattern (Theories/Bimodal/Boneyard/Metalogic/Completeness.lean:2055-2581)
  - Current IndexedMCSFamily implementation (Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean)
- **Artifacts**: This research report
- **Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Blocking Issue Confirmed**: Task 658 is blocked because `construct_indexed_family` uses independent Lindenbaum extensions at each time point, which cannot guarantee temporal coherence
- **Root Cause**: The construction extends seeds independently via `extendToMCS`, with no coordination between time points
- **Boneyard Pattern Identified**: `canonical_task_rel` defines a RELATIONAL approach where each MCS creates seeds for its neighbors, not a pre-determined family
- **Key Insight**: Coherent construction requires building MCS incrementally based on EXISTING MCS, not all from a single root
- **Recommendation**: Redesign using relational approach similar to Boneyard's `forward_extension` and `backward_extension`

## Context & Scope

### The Blocking Issue

Task 658 attempted to prove four coherence conditions in `construct_indexed_family`:
1. `forward_G`: G φ ∈ mcs(t) → φ ∈ mcs(t') for t < t'
2. `backward_H`: H φ ∈ mcs(t) → φ ∈ mcs(t') for t' < t
3. `forward_H`: H φ ∈ mcs(t') → φ ∈ mcs(t) for t < t'
4. `backward_G`: G φ ∈ mcs(t') → φ ∈ mcs(t) for t' < t

**Current Construction** (IndexedMCSFamily.lean:417-450):
```lean
mcs_at_time D Gamma h_mcs t = extendToMCS (time_seed D Gamma t) ...
```

Where:
- `mcs(0)` = extend root Gamma to MCS
- `mcs(t > 0)` = extend `{φ | G φ ∈ Gamma}` to MCS
- `mcs(t < 0)` = extend `{φ | H φ ∈ Gamma}` to MCS

**Problem**: Each extension is INDEPENDENT. The extendToMCS function can add different formulas at different times, breaking coherence.

### Research Focus

1. Understand the Boneyard's canonical_task_rel pattern as a reference for coherent construction
2. Identify alternative approaches to indexed MCS family construction
3. Evaluate feasibility of each approach for temporal logic setting
4. Recommend a path forward to unblock Task 658

## Findings

### 1. The Boneyard's Relational Approach

**Key File**: `Theories/Bimodal/Boneyard/Metalogic/Completeness.lean:2055-2581`

**Core Pattern**: Instead of constructing a predetermined family, define a RELATION between MCS:

```lean
def canonical_task_rel (S : CanonicalWorldState) (t : CanonicalTime) (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val)
```

**Transfer Properties**:
- `modal_transfer S T`: ∀ φ, □φ ∈ S → φ ∈ T
- `future_transfer S T`: ∀ φ, G φ ∈ S → φ ∈ T
- `past_transfer S T`: ∀ φ, H φ ∈ S → φ ∈ T

**Coherence Built In**: The relation DEFINITION ensures coherence - if the relation holds, coherence is automatic.

### 2. Forward/Backward Extension Pattern

**Forward Extension** (Completeness.lean:2521-2581):

Given an MCS S and positive duration d, construct T such that `canonical_task_rel S d T`:

1. Define `forward_seed S = {φ | G φ ∈ S} ∪ {φ | □φ ∈ S}`
2. Prove `forward_seed S` is consistent
3. Extend via Lindenbaum: `T = extendToMCS (forward_seed S)`
4. Verify relation properties:
   - Modal transfer: √ (φ from □φ ∈ S is in seed, thus in T)
   - Future transfer: √ (φ from G φ ∈ S is in seed, thus in T)
   - G-persistence: Uses G-4 axiom (G φ → GG φ) to ensure G φ ∈ T

**Backward Extension** (Completeness.lean:2638-2700, similar structure):

Given an MCS S, construct T in the past such that `canonical_task_rel T (-d) S`.

**Key Difference from Current Approach**:
- Seeds are derived from CURRENT MCS S, not from distant root Gamma
- Each step builds on the PREVIOUS MCS, maintaining coherence

### 3. Why the Current Construction Fails

**Scenario illustrating the issue**:

```
Root MCS Gamma at t=0:
  Contains: {p, G q, G r, ...}

Future time t1 > 0:
  Seed: {q, r, ...} (from G q, G r ∈ Gamma)
  Extended to MCS M1: Lindenbaum adds s (where s is independent)

Future time t2 > t1:
  Seed: {q, r, ...} (SAME seed from Gamma)
  Extended to MCS M2: Lindenbaum might add ¬s (also independent)

Result: M1 contains s, M2 contains ¬s
Problem: If we had G s ∈ M1, we need s ∈ M2 (coherence)
         But Lindenbaum at M2 has no knowledge of M1's choices
```

**The Issue**: Independent Lindenbaum extensions don't coordinate. Each time point makes independent choices about what to add beyond the seed.

### 4. Comparison: Family vs Relational Approach

| Aspect | Current (Family) | Boneyard (Relational) |
|--------|------------------|------------------------|
| Structure | Pre-determined function `t ↦ mcs(t)` | Relation between neighboring MCS |
| Seeds | All from root Gamma | From immediate neighbor MCS |
| Extension | Independent at each time | Coordinated step-by-step |
| Coherence | Must be PROVEN after construction | Built into relation DEFINITION |
| Construction | Top-down (all from one root) | Bottom-up (incremental) |

### 5. Alternative Approaches Identified

#### Option A: Relational Approach (Recommended)

**Pattern**: Adapt Boneyard's `canonical_task_rel` approach.

**Structure**:
1. Define a relation `coherent_mcs_rel : Set Formula → D → Set Formula → Prop`
2. For each pair (t, t') with t < t', define what it means for mcs(t) and mcs(t') to be coherent
3. Use forward/backward extension lemmas to CONSTRUCT related MCS
4. Coherence is automatic from relation definition

**Advantages**:
- Coherence guaranteed by construction
- Pattern proven in Boneyard (though with sorries in compositionality)
- Natural match for task frame semantics (relations between states)

**Challenges**:
- Requires restructuring from family to relational definition
- May need existence lemmas (forward_extension, backward_extension)
- Compositionality proofs may be complex (Boneyard has sorries here)

**Feasibility**: HIGH. Pattern exists, just needs adaptation from CanonicalWorldState to indexed setting.

#### Option B: Incremental Family Construction

**Pattern**: Build family incrementally, each step using previous MCS.

**Structure**:
1. Start with mcs(0) = extendToMCS(Gamma)
2. For t > 0: Define `mcs(t+1) = extendToMCS(forward_seed(mcs(t)))`
3. For t < 0: Define `mcs(t-1) = extendToMCS(backward_seed(mcs(t)))`
4. Prove coherence by induction on time steps

**Advantages**:
- Keeps family structure (IndexedMCSFamily)
- Incremental construction ensures coordination
- Coherence provable by induction

**Challenges**:
- Requires defining "next time" function (assumes discrete time?)
- Current D is LinearOrderedAddCommGroup (could be dense like rationals)
- May not work for dense/continuous time structures

**Feasibility**: MEDIUM. Works for discrete time (ℤ), unclear for dense time.

#### Option C: Coherent Lindenbaum Extension

**Pattern**: Modify Lindenbaum's lemma to extend MULTIPLE sets coherently.

**Structure**:
1. Define `multiExtendToMCS : (D → Set Formula) → (∀ t, SetConsistent (seeds t)) → (D → Set Formula)`
2. Prove: Extended family satisfies coherence conditions
3. Use Zorn's lemma on the partial order of coherent families

**Advantages**:
- Most direct solution to the problem
- Preserves family structure
- General (works for any time structure)

**Challenges**:
- **Very Complex**: Requires generalizing Zorn's lemma to families
- **Novel Proof**: No existing pattern to follow
- **High Risk**: May not be provable

**Feasibility**: LOW. Extremely complex, unclear if provable.

#### Option D: Weaken Coherence Requirements

**Pattern**: Accept that full coherence isn't provable, weaken the theorem.

**Structure**:
1. Add axiom: Assume Lindenbaum extensions are coherent
2. OR: Prove weaker coherence (e.g., only for seed formulas, not all formulas)
3. Document limitation

**Advantages**:
- Unblocks Task 658 immediately
- Allows progress on other parts

**Challenges**:
- Weakens the representation theorem
- May not be mathematically satisfactory
- Could invalidate later proofs

**Feasibility**: HIGH (trivially), but UNDESIRABLE.

### 6. Detailed Analysis of Option A (Relational Approach)

**Concrete Design**:

```lean
-- Define what it means for two MCS to be coherent at times t, t'
def coherent_at (mcs_t : Set Formula) (mcs_t' : Set Formula) (t t' : D) : Prop :=
  (t < t' → ∀ φ, Formula.all_future φ ∈ mcs_t → φ ∈ mcs_t') ∧
  (t' < t → ∀ φ, Formula.all_past φ ∈ mcs_t → φ ∈ mcs_t') ∧
  (t < t' → ∀ φ, Formula.all_past φ ∈ mcs_t' → φ ∈ mcs_t) ∧
  (t' < t → ∀ φ, Formula.all_future φ ∈ mcs_t' → φ ∈ mcs_t)

-- IndexedMCSFamily becomes a proof obligation that pairwise coherence holds
structure CoherentIndexedFamily where
  mcs : D → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  pairwise_coherent : ∀ t t', coherent_at (mcs t) (mcs t') t t'
```

**Construction Strategy**:

1. **Base Case**: Given root MCS Gamma at t=0
2. **Forward Extension Lemma**: ∀ S: MCS, ∀ ε > 0, ∃ T: MCS, coherent_at S T 0 ε
   - Proof: Use forward_seed pattern from Boneyard
   - T = extendToMCS({φ | G φ ∈ S} ∪ {φ | □φ ∈ S})
3. **Backward Extension Lemma**: ∀ S: MCS, ∀ ε > 0, ∃ T: MCS, coherent_at T S (-ε) 0
   - Proof: Use backward_seed pattern from Boneyard
4. **Transitive Coherence**: Show that if coherent_at S T t t' and coherent_at T U t' t'', then coherent_at S U t t''
5. **Use Dependent Choice**: Build the entire family inductively

**Note**: This approach requires either:
- Discrete time (ℤ) to use induction, OR
- Axiom of Dependent Choice to build continuously

### 7. Mathlib Patterns for Coherent Construction

**Search Query**: Used lean_local_search for "coherent", "family", "indexed"

**Findings**:
- No direct "coherent family construction" pattern found in Mathlib
- Relevant patterns:
  - Zorn's lemma applications (used in Lindenbaum)
  - Dependent choice (for constructing functions with coherence constraints)
  - Inductive constructions (for discrete structures)

**Conclusion**: This is a domain-specific pattern, not a general Mathlib construct.

## Decisions

1. **Option A (Relational Approach) is Recommended** due to:
   - Proven pattern in Boneyard
   - Coherence guaranteed by definition
   - Natural match for semantic structure
   - Feasible implementation

2. **Option B (Incremental Family)** is a fallback if we commit to discrete time (ℤ)

3. **Option C (Coherent Lindenbaum)** is too complex and risky

4. **Option D (Weaken Requirements)** is unacceptable mathematically

## Recommendations

### Immediate Actions

1. **Create Task 682**: "Implement relational coherent MCS construction"
   - Phase 1: Define coherent_at relation and CoherentIndexedFamily structure
   - Phase 2: Prove forward_extension and backward_extension existence lemmas
   - Phase 3: Prove pairwise coherence implies IndexedMCSFamily coherence conditions
   - Phase 4: Use Dependent Choice to construct the full family
   - Estimated effort: 12-16 hours

2. **Update Task 658 Status**: Mark as "blocked by 682"

3. **Document the Issue**: Add clear comments to current construct_indexed_family explaining why it's insufficient

### Implementation Strategy

**Phase 1: Define Relational Structure** (3-4 hours)
- Define `coherent_at` relation
- Define `CoherentIndexedFamily` structure
- Prove equivalence: `CoherentIndexedFamily → IndexedMCSFamily` (coherence conditions follow from pairwise coherence)

**Phase 2: Extension Lemmas** (4-6 hours)
- Port `forward_seed` and `backward_seed` from Boneyard
- Prove `forward_seed_consistent` (uses temporal K distribution)
- Prove `backward_seed_consistent` (symmetric)
- Prove `forward_extension`: ∀ S, ε > 0, ∃ T, coherent_at S T 0 ε
- Prove `backward_extension`: ∀ S, ε > 0, ∃ T, coherent_at T S (-ε) 0

**Phase 3: Transitivity** (2-3 hours)
- Prove: coherent_at S T t t' ∧ coherent_at T U t' t'' → coherent_at S U t t''
- Uses temporal axioms (G-4, H-4) for formula propagation

**Phase 4: Full Family Construction** (3-4 hours)
- Use Axiom of Dependent Choice or discrete induction
- Construct: ∀ t, ∃ mcs(t): MCS, ∀ t', coherent_at (mcs t) (mcs t') t t'
- Assemble into CoherentIndexedFamily
- Convert to IndexedMCSFamily

### Alternative Path (If Time Structure is Discrete)

If we commit to D = ℤ (discrete time):
- Use simple induction instead of Dependent Choice
- Simpler construction: mcs(n+1) = extendToMCS(forward_seed(mcs(n)))
- Effort: 8-10 hours (simpler than relational approach)

**Trade-off**: Less general (only works for discrete time)

### Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Extension lemmas have sorries | High | Medium | Boneyard has sorries in seed_consistent; may need to accept or fix |
| Dependent Choice axiom needed | Medium | High | Document clearly; alternative is discrete time restriction |
| Transitivity proof complex | Medium | Medium | Use temporal axiom patterns from Boneyard |
| Approach still doesn't work | Critical | Low | Fall back to discrete time + induction |

## Appendix

### Reference: Current construct_indexed_family

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean:417-450`

**Current Approach**:
```lean
noncomputable def construct_indexed_family
    (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
    IndexedMCSFamily D where
  mcs := mcs_at_time D Gamma h_mcs
  is_mcs := mcs_at_time_is_mcs D Gamma h_mcs
  forward_G := sorry  -- BLOCKED
  backward_H := sorry  -- BLOCKED
  forward_H := sorry  -- BLOCKED
  backward_G := sorry  -- BLOCKED
```

### Reference: Boneyard forward_extension

**File**: `Theories/Bimodal/Boneyard/Metalogic/Completeness.lean:2521-2581`

**Pattern**:
```lean
theorem forward_extension (S : CanonicalWorldState) (d : CanonicalTime) (hd : d > 0) :
    ∃ T : CanonicalWorldState, canonical_task_rel S d T := by
  have h_cons : SetConsistent (forward_seed S) := forward_seed_consistent S
  obtain ⟨M, h_sub, h_mcs⟩ := set_lindenbaum (forward_seed S) h_cons
  let T : CanonicalWorldState := ⟨M, h_mcs⟩
  use T
  -- Verify relation properties...
```

### Search Queries Used

**Lean Local Searches**:
- Query: "coherent" - No relevant results in current codebase
- Query: "family" - Found IndexedMCSFamily (current implementation)
- Query: "canonical_task_rel" - Found Boneyard implementation
- Query: "forward_seed" - Found Boneyard pattern

**Conceptual Searches**:
- Mathlib pattern: Zorn's lemma applications → Used in Lindenbaum's lemma
- Mathlib pattern: Dependent choice → Needed for continuous construction
- Mathlib pattern: Inductive types → Useful for discrete time alternative

## Next Steps

1. **Discuss with user**: Confirm approach preference (relational vs discrete time)
2. **Create Task 682** with detailed implementation plan
3. **Update Task 658** with "blocked by 682" status
4. **Document in IndexedMCSFamily.lean**: Add comments explaining the blocking issue

## Notes

The blocking issue is FUNDAMENTAL, not a proof difficulty. The current construction method (independent extensions from a single root) cannot guarantee temporal coherence without additional coordination. The relational approach (building incrementally from neighbors) naturally ensures coherence by construction.

This is similar to the difference between:
- **Bad**: Building a linked list by independently creating each node, then trying to prove they're linked
- **Good**: Building a linked list by creating each node with a pointer to the previous node

The coherence conditions are the "links" in the temporal structure, and they must be built in during construction, not proven after the fact.
