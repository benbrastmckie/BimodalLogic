# Research Report: Task #658 (Followup)

- **Task**: 658 - Prove indexed family coherence conditions
- **Started**: 2026-01-28T10:00:00Z
- **Completed**: 2026-01-28T12:00:00Z
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: Task 657 (completed - seed consistency)
- **Sources/Inputs**:
  - IndexedMCSFamily.lean - Current construction with sorries
  - CoherentConstruction.lean - Alternative coherent relation approach
  - TaskRelation.lean - canonical_task_rel pattern
  - Boneyard/Metalogic/Completeness.lean - forward_seed/backward_seed approach
  - Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean - Semantic approach
  - implementation-summary-20260125.md - Previous analysis identifying the blocker
- **Artifacts**: This report
- **Standards**: report-format.md, artifact-management.md

## Executive Summary

- **Root Cause Confirmed**: The blocking issue is that independent Lindenbaum extensions at different time points cannot guarantee coherence - each extension makes arbitrary choices about formulas beyond the seed
- **Boneyard Pattern Analysis**: The `canonical_task_rel` approach defines coherence RELATIONALLY between MCS pairs rather than trying to prove it for a pre-constructed family
- **Architectural Solutions Identified**: Three viable paths forward, each with distinct tradeoffs
- **Metalogic Context Mapped**: Coherence is needed for the canonical model construction, but alternative completeness proofs exist that bypass this issue
- **Recommendation**: Adopt the relational approach from the Boneyard (Option B) rather than trying to prove coherence for the indexed family construction

## Context & Scope

### The Blocking Issue (Confirmed)

The `construct_indexed_family` function builds MCS at each time point using **independent** Lindenbaum extensions:

```
mcs(0) = extendToMCS(Gamma)                    -- Root MCS
mcs(t > 0) = extendToMCS(future_seed(Gamma))  -- Seeds: {phi | G phi in Gamma}
mcs(t < 0) = extendToMCS(past_seed(Gamma))    -- Seeds: {phi | H phi in Gamma}
```

**Why this fails**: Lindenbaum's lemma (via Zorn) makes non-deterministic choices when extending a consistent set to MCS. Different calls to `extendToMCS` can add different formulas. There is no coordination between the extensions at different time points.

**Concrete failure scenario**:
1. Let `G phi ∈ Gamma` but `phi ∉ future_seed(Gamma)` for some `phi`
2. When extending `future_seed` at time 1, Lindenbaum might NOT add `phi`
3. When extending `future_seed` at time 2, Lindenbaum might ADD `G phi`
4. Now `G phi ∈ mcs(2)` but `phi ∉ mcs(1)` for `1 < 2`, violating forward_G coherence

The issue is fundamental: **coherence between independent random extensions is not provable**.

### Task 657 Contribution (Completed)

Task 657 proved seed consistency:
- `future_seed_consistent`: Requires `G bot ∉ Gamma` (no future absurdity)
- `past_seed_consistent`: Requires `H bot ∉ Gamma` (no past absurdity)

These use `generalized_temporal_k` and `generalized_past_k` to show that if the seed were inconsistent, the root MCS would contain `G bot` or `H bot`. This confirms seeds CAN be extended to MCS, but says nothing about the coherence of those extensions.

## Findings

### 1. Boneyard's canonical_task_rel Pattern

The Boneyard (lines 2055-2581 of Completeness.lean) uses a fundamentally different approach:

**Definition Pattern**:
```lean
def canonical_task_rel (S : CanonicalWorldState) (t : CanonicalTime) (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val)
```

**Key Insight**: Instead of constructing a family of MCS and then proving coherence, define a RELATION between ANY two MCS that captures what "coherent transition" means. Worlds are then filtered by this relation.

**Transfer Definitions**:
- `modal_transfer S T`: `box phi ∈ S → phi ∈ T`
- `future_transfer S T`: `G phi ∈ S → phi ∈ T`
- `past_transfer S T`: `H phi ∈ S → phi ∈ T`

**Existence Lemmas** (lines 2521-2637):
- `forward_extension`: For any MCS S and d > 0, exists MCS T with `canonical_task_rel S d T`
- `backward_extension`: For any MCS S and d > 0, exists MCS T with `canonical_task_rel T d S`

These use `forward_seed` and `backward_seed` similar to the indexed family approach, but the relation is established BY CONSTRUCTION of T from S, not proven after independent constructions.

**Limitation Found**: Compositionality proof (lines 2190-2415) has many sorries. The issue is the "mixed sign" case: when `x > 0` and `y <= 0` but `x + y > 0`, the intermediate T is at or before S, so `G phi ∈ S` doesn't transfer through T to U. This is documented extensively in the code comments.

### 2. CoherentConstruction.lean Approach

The active codebase has begun a `CoherentIndexedFamily` approach in CoherentConstruction.lean:

**Definition**:
```lean
structure CoherentIndexedFamily where
  mcs : D → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  pairwise_coherent : ∀ t t', coherent_at D (mcs t) (mcs t') t t'
```

**coherent_at Relation**:
```lean
def coherent_at (mcs_t mcs_t' : Set Formula) (t t' : D) : Prop :=
  (t < t' → ∀ φ, Formula.all_future φ ∈ mcs_t → φ ∈ mcs_t') ∧
  (t' < t → ∀ φ, Formula.all_past φ ∈ mcs_t → φ ∈ mcs_t') ∧
  (t < t' → ∀ φ, Formula.all_past φ ∈ mcs_t' → φ ∈ mcs_t) ∧
  (t' < t → ∀ φ, Formula.all_future φ ∈ mcs_t' → φ ∈ mcs_t)
```

This is the same four coherence conditions as `IndexedMCSFamily`, but moved into a requirement `pairwise_coherent` that must be satisfied at construction time.

**Status**: Only reflexivity and swap lemmas are proven. No construction theorem yet.

### 3. Semantic Canonical Model (Metalogic_v2)

The `SemanticCanonicalModel.lean` in Metalogic_v2 takes a completely different approach:

**Key Idea**: Define worlds as equivalence classes of (history, time) pairs. Two pairs are equivalent if they have the same underlying world state. Coherence is then trivial because history paths compose naturally.

**Definition**:
```lean
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)

def semantic_task_rel (phi : Formula) (w : SemanticWorldState phi) (d : Int)
    (v : SemanticWorldState phi) : Prop :=
  ∃ (h : FiniteHistory phi) (t1 t2 : FiniteTime (temporalBound phi)),
    SemanticWorldState.ofHistoryTime h t1 = w ∧
    SemanticWorldState.ofHistoryTime h t2 = v ∧
    FiniteTime.toInt t2 - FiniteTime.toInt t1 = d
```

**Completeness Proof**: `semantic_weak_completeness` provides a sorry-free completeness core by using internal finite model truth (`semantic_truth_at_v2`) rather than general validity.

**Limitation**: Compositionality has a sorry (line 224) because unbounded durations can exceed the finite time domain `[-k, k]`. This is documented as "mathematically false for unbounded durations."

### 4. Metalogic Architecture Context

```
                    Completeness Theorem
                           |
         +-----------------+-----------------+
         |                                   |
   Syntactic Path                      Semantic Path
   (Representation)                    (Truth Lemma)
         |                                   |
   IndexedMCSFamily                  SemanticCanonicalModel
   or canonical_task_rel                     |
         |                           semantic_truth_at_v2
   Coherence Required                        |
   (BLOCKED HERE)                    semantic_weak_completeness
                                        (COMPLETE)
```

**Key Observation**: The semantic path via `semantic_weak_completeness` provides a complete (sorry-free) proof for a weaker notion of completeness. The syntactic path via indexed families is blocked on coherence.

### 5. Finite Model Property and Decidability

From `FiniteModelProperty.lean`:
- FMP: If phi is satisfiable, it's satisfiable in a finite model
- Decidability: Follows from FMP by model enumeration
- `provable_iff_valid`: The soundness-completeness triangle

**Relevance**: The FMP provides an alternative route to decidability that doesn't require the full canonical model construction. The subformula closure bounds the relevant distinctions.

## Decisions

1. **The indexed family approach with independent Lindenbaum extensions cannot work** - this is a fundamental mathematical limitation, not a proof difficulty

2. **The relational approach (canonical_task_rel) is more promising** but still has compositionality issues for mixed-sign durations

3. **The semantic approach (SemanticCanonicalModel) provides a complete core** via `semantic_weak_completeness` but doesn't give the full representation theorem

4. **Coherence IS needed for the syntactic representation theorem** but alternative proof paths exist for completeness

## Recommendations

### Option A: Adopt Relational Pattern (Recommended for Task 658)

**What**: Replace `IndexedMCSFamily` with a relational approach based on `canonical_task_rel`

**How**:
1. Use `forward_seed`/`backward_seed` to construct MCS on-demand
2. Define coherence relation between world pairs
3. Build world histories by chaining related MCS
4. Accept that compositionality has limitations for mixed-sign durations

**Pros**:
- Coherence is by construction, not proven after
- Aligns with working Boneyard code
- Can reuse forward/backward extension lemmas

**Cons**:
- Compositionality for mixed-sign durations remains unsolved
- Requires restructuring IndexedMCSFamily users

**Effort**: 16-24 hours

### Option B: Use Semantic Weak Completeness

**What**: Accept that the full syntactic representation theorem is blocked, use `semantic_weak_completeness` instead

**How**:
1. Acknowledge limitation in documentation
2. Use `semantic_weak_completeness` for completeness results
3. Keep IndexedMCSFamily for cases where coherence IS provable (e.g., finite domains)

**Pros**:
- Already complete (no sorries in the core theorem)
- Provides usable completeness result
- Minimal new code needed

**Cons**:
- Weaker result (finite model truth, not general validity)
- Doesn't complete the "universal parametric" vision

**Effort**: 4-8 hours (documentation and integration)

### Option C: Coordinated Lindenbaum Construction

**What**: Design a NEW construction that builds all time-point MCS simultaneously with coordination

**How**:
1. Define a "coherent extension system" that extends all seeds together
2. Use transfinite induction with coordination across time points
3. Ensure each extension decision respects coherence with all other time points

**Pros**:
- Could provide the full indexed family with coherence
- Most principled solution

**Cons**:
- Significant theoretical work needed
- May require new proof system infrastructure
- Uncertain if achievable

**Effort**: 40+ hours (research + implementation)

### Option D: Mark as Known Limitation

**What**: Keep sorries with clear documentation, focus on alternative proof paths

**How**:
1. Update IndexedMCSFamily.lean with detailed documentation of the limitation
2. Create a "Limitations" section in the metalogic documentation
3. Recommend semantic_weak_completeness for applications
4. Mark task as "BLOCKED" with clear explanation

**Pros**:
- Honest about current state
- Frees resources for other work
- Documents the issue for future research

**Cons**:
- Leaves sorries in the codebase
- Doesn't advance the syntactic approach

**Effort**: 2-4 hours

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Relational approach has same compositionality issues | High | Accept mixed-sign limitations, document clearly |
| Coordinated construction requires new mathematics | High | Start with literature review before implementation |
| Semantic approach insufficient for some uses | Medium | Identify specific use cases, evaluate alternatives |
| Documentation without solution frustrates users | Low | Provide clear alternative paths and rationale |

## Appendix

### A. Key Code Locations

| File | Lines | Content |
|------|-------|---------|
| IndexedMCSFamily.lean | 550-645 | The four coherence sorries |
| CoherentConstruction.lean | 68-72 | coherent_at definition |
| TaskRelation.lean | 61-78 | canonical_task_rel definition |
| Completeness.lean (Boneyard) | 2055-2061 | canonical_task_rel original |
| Completeness.lean (Boneyard) | 2459-2601 | forward/backward seed definitions |
| SemanticCanonicalModel.lean | 526-590 | semantic_weak_completeness |

### B. Related Literature Concepts

- **Coordinated Lindenbaum**: Not standard; would need novel construction
- **Canonical model via histories**: Standard in temporal logic (Burgess, 1984)
- **Filtration**: Standard technique for FMP (Blackburn et al., Chapter 4)
- **Mosaic method**: Alternative to canonical model (Marx & Reynolds, 1999)

### C. Search Queries Used

- `lean_local_search`: coherent, IndexedMCSFamily, construct_indexed
- `lean_leansearch`: temporal logic completeness maximal consistent set indexed family coherence
- File exploration: Boneyard/Metalogic/, Metalogic/Representation/

### D. Terminology Mapping

| This Project | Standard Literature |
|--------------|---------------------|
| IndexedMCSFamily | Canonical model with time indices |
| forward_G/backward_H | Temporal transfer conditions |
| forward_H/backward_G | Coherence conditions |
| canonical_task_rel | Canonical accessibility relation |
| SemanticWorldState | State equivalence class |
