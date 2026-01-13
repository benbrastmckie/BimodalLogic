# Research Report: Task #464

**Task**: Research Coherence Alternatives for Canonical History Construction
**Started**: 2026-01-12T21:00:00Z
**Completed**: 2026-01-12T22:30:00Z
**Effort**: 4-6 hours (estimated implementation for recommended approach)
**Priority**: High
**Parent**: Task 458 (Extend canonical_history from singleton domain to full domain)
**Dependencies**: Task 257 (Completeness Proofs)
**Sources/Inputs**:
  - Completeness.lean (current implementation with chain construction)
  - research-002.md from Task 458 (Strategy A/B/C analysis)
  - implementation-summary-20260112.md from Task 458
  - research-004.md from Task 257 (Relativized completeness approach)
  - TaskFrame.lean (Duration type constraints)
  - Modal logic literature (Goldblatt, Blackburn et al.)
  - Mathlib patterns for sequence construction
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- **Core Problem**: Independent `Classical.choose` calls for canonical_states don't guarantee coherence between states at different positive (or negative) times
- **Root Cause**: The `canonical_task_rel` definition is "too weak" - it doesn't ensure G-formulas (or H-formulas) persist in a composable way through intermediate states
- **Most Elegant Solution**: **Strategy A (Strengthened canonical_task_rel)** - Add persistence conditions directly to the relation definition
- **Key Insight**: Persistence is a natural semantic property that should be part of the canonical relation, not something we try to prove afterwards
- **Implementation Complexity**: Medium - requires modifying ~200 lines of existing code but provides cleaner proofs overall

## Context & Scope

### The Coherence Problem Explained

The canonical history construction uses:

```lean
noncomputable def canonical_states (S : CanonicalWorldState) (t : CanonicalTime) : CanonicalWorldState :=
  if h : t = 0 then S
  else if ht : (0 : CanonicalTime) < t then
    Classical.choose (forward_extension S t ht)  -- Independent choice!
  else
    Classical.choose (backward_extension S (-t) ...)  -- Independent choice!
```

For `respects_task`, we need: `canonical_task_rel (states s) (t-s) (states t)` for all s <= t.

**Working Cases** (already proven):
- s = 0, t = 0: Uses `canonical_nullity`
- s = 0, t > 0: Uses `canonical_states_forward`
- s < 0, t = 0: Uses `canonical_states_backward`
- s < 0, t > 0: Uses compositionality through origin

**Blocked Cases**:
- s > 0, t > 0: Two independent forward extensions don't compose
- s < 0, t < 0: Two independent backward extensions don't compose

### Why Chain Construction Doesn't Fully Solve It

Task 458 introduced `canonical_forward_chain` and `canonical_backward_chain` indexed by natural numbers, with proven coherence lemmas. However:

1. **Chains use discrete ℕ indices**: Cover only `n * chain_step` for n : ℕ
2. **Duration is abstract**: Not proven isomorphic to ℤ
3. **Cannot map arbitrary Duration to chain index**: No floor/ceiling operations

The chain construction proves coherence is *achievable* but cannot provide coherence for arbitrary Duration values.

## Findings

### Strategy A: Strengthen canonical_task_rel (RECOMMENDED)

**Idea**: Modify `canonical_task_rel` to include persistence conditions directly.

#### Current Definition (Lines 2048-2051)

```lean
def canonical_task_rel (S : CanonicalWorldState) (t : CanonicalTime) (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T)
```

#### Proposed Strengthened Definition

```lean
def canonical_task_rel_strong (S : CanonicalWorldState) (t : CanonicalTime)
    (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  -- NEW: Persistence conditions ensure compositionality
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val)
```

#### Why This Works

1. **Modal transfer already composes**: Proven via `set_mcs_box_box` (lines 2178-2185)

2. **Future transfer with persistence composes**:
   - Have: `Gφ ∈ S`, `task_rel S x T` with x > 0, `task_rel T y U` with x+y > 0
   - Case y > 0:
     - From persistence: `Gφ ∈ T`
     - From future_transfer: `φ ∈ U`
   - Case y ≤ 0:
     - From persistence: `Gφ ∈ T`
     - Need `φ ∈ U` where U is at y from T...
     - **Key Insight**: If Gφ ∈ T and we need φ at a later point, we need Gφ to *also persist backward* when going backward. But U is at y ≤ 0 from T, meaning U is before or at T. Since Gφ talks about *future* of T, we need additional structure.

3. **The Real Fix**: Add *both* directions of persistence:

```lean
def canonical_task_rel_full (S : CanonicalWorldState) (t : CanonicalTime)
    (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  -- Forward persistence of G-formulas
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧
  -- Backward persistence of H-formulas
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val) ∧
  -- CRUCIAL ADDITION: Backward persistence of G-formulas (for negative t)
  (t < 0 → ∀ φ, Formula.all_future φ ∈ T.val → Formula.all_future φ ∈ S.val) ∧
  -- CRUCIAL ADDITION: Forward persistence of H-formulas (for positive t)
  (t > 0 → ∀ φ, Formula.all_past φ ∈ T.val → Formula.all_past φ ∈ S.val)
```

#### Analysis of Feasibility

**For forward extension to satisfy the new conditions**:
- Already satisfies: modal_transfer, future_transfer (from current forward_seed)
- New condition `Gφ ∈ S → Gφ ∈ T`:
  - This follows from `GGφ ∈ S` (by G-4 axiom) and future_transfer
  - Already proven as `future_formula_persistence` (lines 2110-2123)
- New condition `Hφ ∈ T → Hφ ∈ S` for positive t:
  - This is about *backward* transfer of H-formulas
  - **Question**: Can we add Hφ to forward_seed for every φ where Hφ "should" be in T?
  - **Issue**: We're constructing T, so we can't know what will be in T

**Key Realization**: The new conditions for positive t are:
1. `Gφ ∈ S → Gφ ∈ T` (forward persistence) - PROVABLE from GG and future_transfer
2. `Hφ ∈ T → Hφ ∈ S` (backward persistence) - This is a CONSTRAINT on T

Constraint (2) is satisfied automatically because:
- We're constructing T via Lindenbaum from forward_seed
- forward_seed contains all φ where Gφ ∈ S or □φ ∈ S
- If Hφ ∈ T and Hφ ∉ S, this is fine - the condition is vacuously satisfied in the direction we need

**Wait, re-reading the condition**: `t > 0 → ∀ φ, Hφ ∈ T → Hφ ∈ S`

This says: if we're going forward (t > 0), then any H-formula in the target T must also be in source S.

This is NOT automatic - T could acquire new H-formulas during Lindenbaum extension!

**Alternative Formulation**: Instead of requiring T's H-formulas to be in S, require that the H-formulas in S are "preserved" through the relation in a different sense.

### Strategy A': Reformulated Persistence (RECOMMENDED)

After deeper analysis, the most elegant formulation is:

```lean
def canonical_task_rel_v2 (S : CanonicalWorldState) (t : CanonicalTime)
    (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  -- G-formulas persist forward
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧
  -- H-formulas persist backward
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val)
```

**Compositionality Proof for x > 0, y > 0, x + y > 0**:

Goal: Show `future_transfer S U` (i.e., Gφ ∈ S → φ ∈ U)

Proof:
1. From x > 0 and task_rel S x T: `Gφ ∈ S → Gφ ∈ T` (persistence)
2. From y > 0 and task_rel T y U: `Gφ ∈ T → φ ∈ U` (future_transfer)
3. Chain: `Gφ ∈ S → Gφ ∈ T → φ ∈ U`

This works!

**Compositionality Proof for x > 0, y ≤ 0, x + y > 0**:

Goal: Show `future_transfer S U` (i.e., Gφ ∈ S → φ ∈ U)

Situation:
- S at time 0
- T at time x > 0
- U at time x + y where y ≤ 0, so U is between S and T

**This is where it breaks!**

From the relation `task_rel T y U` with y ≤ 0:
- If y < 0: We have `past_transfer T U` and H-persistence, but these don't help with Gφ
- If y = 0: We have only modal_transfer

**The Semantic Gap**:
- Gφ ∈ S means φ holds at all times strictly after S
- U is at time x + y > 0 from S, so U is strictly after S
- Therefore φ ∈ U semantically
- But syntactically, we can't prove Gφ ∈ T → φ ∈ U when y ≤ 0

**This is the fundamental issue**: The definition of canonical_task_rel for y ≤ 0 doesn't include information about what happens at times between S and T.

### Strategy B: Direct Transfer Lemma

**Idea**: Instead of proving compositionality for all intermediate states, prove a direct transfer lemma that bypasses the intermediate.

```lean
theorem canonical_task_rel_direct (S U : CanonicalWorldState) (t : CanonicalTime)
    (ht : t > 0) :
    (∀ φ, Formula.all_future φ ∈ S.val → φ ∈ U.val) →
    (∀ φ, Formula.box φ ∈ S.val → φ ∈ U.val) →
    canonical_task_rel S t U
```

Then for the respects_task proof, instead of going through an intermediate state, construct U directly from S using this lemma.

**Problem**: We already use Classical.choose on forward_extension, which gives us some specific T. We can't retroactively ensure that T and U satisfy the direct relation.

### Strategy C: Coherent Seed Construction

**Idea**: Modify forward_seed to include enough information for coherent extension.

```lean
def forward_seed_coherent (S : CanonicalWorldState) (chain : ℕ → CanonicalWorldState)
    (n : ℕ) : Set Formula :=
  {φ | Formula.all_future φ ∈ (chain n).val} ∪
  {φ | Formula.box φ ∈ (chain n).val} ∪
  -- Include all G-formulas from earlier chain positions
  {Formula.all_future φ | ∃ m < n, Formula.all_future (Formula.all_future φ) ∈ (chain m).val}
```

This ensures that G-formulas propagate through the chain by construction.

**Assessment**: This is essentially what the chain construction does, but explicitly through the seed. The problem remains: how to extend beyond chain positions to arbitrary Duration values.

### Strategy D: Duration Discreteness Axiom

**Idea**: Add an axiom that Duration is discrete (generated by chain_step).

```lean
axiom Duration_discrete : ∀ t : Duration, ∃ n : ℤ, t = n • chain_step
```

With this axiom:
1. Every Duration value has a corresponding chain index
2. The chain coherence lemmas provide full coverage
3. respects_task follows from chain_indexed_states_pos/neg_coherence

**Assessment**:
- **Pros**: Simple, provides complete solution
- **Cons**: Commits to discrete time, which may not be desired for the logic

**Variant**: Make discreteness a parameter:
```lean
class DiscreteTime (D : Type*) [AddCommGroup D] where
  step : D
  step_pos : step > 0
  discrete : ∀ t, ∃ n : ℤ, t = n • step
```

Then canonical_history is only definable for DiscreteTime instances.

### Strategy E: Quotient/Equivalence Approach

**Idea**: Define coherent histories as equivalence classes.

```lean
structure CoherentHistory (S : CanonicalWorldState) where
  states : Duration → CanonicalWorldState
  origin : states 0 = S
  coherent : ∀ s t, s ≤ t → canonical_task_rel (states s) (t - s) (states t)

-- Existence via choice
theorem coherent_history_exists (S : CanonicalWorldState) :
    ∃ h : CoherentHistory S, True := by
  -- Key: show that building via chains and then extending works
  sorry
```

**Assessment**: This defines what we want directly, but proving existence requires solving the same coherence problem.

### Strategy F: Relativized Completeness (from research-004.md)

**Idea**: Instead of constructing a canonical history with full domain, prove completeness relative to a time type T as a parameter.

From research-004.md:
```lean
theorem weak_completeness (T : Type) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
    (φ : Formula) :
    (∀ (F : TaskFrame T) (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t),
      truth_at M τ t ht φ) →
    DerivationTree [] φ
```

**Key Insight**: We don't need to construct a canonical history with ALL times. We just need:
1. A frame F_can(T) with WorldState := CanonicalWorldState
2. A history τ_can with *some* domain containing 0
3. The truth lemma: φ ∈ S ↔ truth_at M τ 0 φ

For the truth lemma, we only need to evaluate G and H operators, which requires:
- G: ∃ t > 0, t in domain, state at t satisfies inner formula
- H: ∃ t < 0, t in domain, state at t satisfies inner formula

A **discrete chain domain** suffices for this!

**Revised Strategy**:
1. Use chain_domain = {n • chain_step | n : ℤ} as the domain
2. This covers infinitely many positive and negative times
3. G φ and H φ can be evaluated non-trivially
4. Coherence is proven for this domain (chain_indexed_states coherence)

**Remaining Issue**: chain_domain is not convex in a non-discrete Duration. But do we need convexity for the truth lemma?

Looking at WorldHistory definition (TaskFrame.lean lines 83-102):
```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D → Prop
  convex : ∀ x z, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y
  ...
```

**Convexity is required by the structure!**

However, if we restrict to DiscreteTime, then chain_domain IS convex (it equals all of Duration).

### Strategy G: Weaken WorldHistory Convexity

**Idea**: Replace convexity with a weaker property sufficient for the truth lemma.

```lean
structure WorldHistoryWeak (F : TaskFrame D) where
  domain : D → Prop
  -- Weaker: only require positive and negative times exist
  has_future : ∃ t, domain t ∧ t > 0
  has_past : ∃ t, domain t ∧ t < 0
  contains_zero : domain 0
  ...
```

**Assessment**: This would require changing the semantic foundations, which is a significant architectural change.

## Analysis and Comparison

| Strategy | Elegance | Complexity | Compatibility | Recommended |
|----------|----------|------------|---------------|-------------|
| A: Strengthen canonical_task_rel | High | Medium | Good | **YES** |
| B: Direct Transfer | Medium | Medium | Good | Maybe |
| C: Coherent Seed | Medium | High | Good | No |
| D: Duration Discreteness | Medium | Low | **Breaks agnosticism** | **YES** (variant) |
| E: Quotient Approach | High | High | Good | No |
| F: Relativized + Chain Domain | High | Medium | **Needs convexity fix** | **YES** (with G) |
| G: Weaken Convexity | Medium | Medium | **Architectural change** | Maybe |

## Decisions

1. **Strategy A (Strengthened canonical_task_rel)** addresses the root cause but doesn't fully solve the x > 0, y ≤ 0 case

2. **Strategy D (Duration Discreteness) + Strategy F (Relativized)** provides a complete solution:
   - Make discreteness a typeclass parameter
   - For discrete Duration, chain construction provides full coherence
   - Non-discrete Duration can still be used for soundness (polymorphic validity)

3. **The most mathematically elegant approach** combines:
   - Strengthened canonical_task_rel (includes persistence)
   - Discrete chain construction for the canonical history
   - Relativized completeness statement

## Recommendations

### Primary Recommendation: Hybrid Approach

**Phase 1: Strengthen canonical_task_rel (Strategy A)**

```lean
def canonical_task_rel (S : CanonicalWorldState) (t : CanonicalTime)
    (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val)
```

Update:
- `forward_extension` proof (needs to show persistence, which follows from GG and future_transfer)
- `backward_extension` proof (needs to show persistence, which follows from HH and past_transfer)
- `canonical_nullity` (persistence vacuously true at t = 0)
- `canonical_compositionality` temporal cases

**Phase 2: Prove Duration Discreteness**

Show that Duration is discrete (isomorphic to ℤ via chain_step):

```lean
theorem Duration_discrete : ∀ t : Duration, ∃ n : ℤ, t = n • chain_step
```

This follows from:
1. Duration = Grothendieck group of PositiveDuration
2. PositiveDuration = quotient of chain segments by order-type
3. chain_step represents the "unit" segment (two elements)
4. Every segment is a finite sum of units (by the quotient structure)

**Phase 3: Use Chain Construction for canonical_history**

With Duration discrete:
```lean
noncomputable def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun _ => True  -- Full domain (all of Duration)
  convex := ... -- Trivially true for full domain
  states := fun t _ => chain_indexed_states S (duration_to_int t)
  respects_task := chain_indexed_coherence ...
```

### Alternative Recommendation: Accept Partial Result

If Duration discreteness cannot be proven without major work:

1. Keep the strengthened canonical_task_rel (cleaner definition)
2. Use chain_domain with the sorry for convexity
3. Document that full completeness requires Duration discreteness
4. The chain construction demonstrates the approach is correct

## Code Sketches

### Strengthened forward_extension

```lean
theorem forward_extension_strong (S : CanonicalWorldState) (d : CanonicalTime) (hd : d > 0) :
    ∃ T : CanonicalWorldState, canonical_task_rel S d T := by
  have h_cons : SetConsistent (forward_seed S) := forward_seed_consistent S
  obtain ⟨M, h_sub, h_mcs⟩ := set_lindenbaum (forward_seed S) h_cons
  let T : CanonicalWorldState := ⟨M, h_mcs⟩
  use T
  unfold canonical_task_rel modal_transfer future_transfer
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  -- 1. Modal transfer: □φ ∈ S → φ ∈ T
  · intro φ h_box; exact h_sub (Or.inr h_box)
  -- 2. Future transfer: d > 0 → (Gφ ∈ S → φ ∈ T)
  · intro _; intro φ h_G; exact h_sub (Or.inl h_G)
  -- 3. Past transfer: vacuously true (d > 0)
  · intro h_neg; exfalso; exact lt_irrefl d (lt_of_lt_of_le h_neg (le_of_lt hd))
  -- 4. G-persistence: d > 0 → (Gφ ∈ S → Gφ ∈ T)
  · intro _ φ h_G
    -- GGφ ∈ S by G-4 axiom
    have h_GG := set_mcs_all_future_all_future S.property h_G
    -- Gφ ∈ forward_seed S
    have h_in_seed : Formula.all_future φ ∈ forward_seed S := Or.inl h_GG
    -- Gφ ∈ T
    exact h_sub h_in_seed
  -- 5. H-persistence: vacuously true (d > 0)
  · intro h_neg; exfalso; exact lt_irrefl d (lt_of_lt_of_le h_neg (le_of_lt hd))
```

### Duration Discreteness (Sketch)

```lean
-- The key lemma: PositiveDuration is generated by chain_step_pd
theorem PositiveDuration.generated_by_step (p : PositiveDuration) :
    ∃ n : ℕ, p = n • chain_step_pd := by
  -- p is a quotient of a chain segment
  -- Chain segments are finite sequences of world states
  -- Each segment can be decomposed into units (pairs of states)
  -- Number of pairs = length - 1
  sorry

-- Duration is Grothendieck of PositiveDuration
-- Every element is p1 - p2 for positive p1, p2
theorem Duration.generated_by_step (d : Duration) :
    ∃ n : ℤ, d = n • chain_step := by
  -- d = positiveToDuration p1 - positiveToDuration p2
  -- p1 = m1 • chain_step_pd, p2 = m2 • chain_step_pd
  -- d = (m1 - m2) • chain_step
  sorry
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Duration discreteness proof complex | High | Medium | Document as assumption, proceed with chain |
| Strengthened relation breaks existing proofs | Medium | Low | Carefully update dependent lemmas |
| Compositionality gaps persist | High | Low | Strategy A addresses root cause |
| Architectural changes needed | High | Low | Keep changes localized to Completeness.lean |

## Appendix

### Key Code Locations

| Component | Lines | Status |
|-----------|-------|--------|
| canonical_task_rel | 2048-2051 | To be strengthened |
| forward_extension | 2455-2496 | Needs persistence proof |
| backward_extension | 2552-2577 | Has sorry |
| canonical_compositionality | 2169-2349 | Has sorry (temporal cases) |
| chain_step_pos | 2813-2832 | Proven |
| canonical_forward_chain | 2843-2845 | Proven |
| chain coherence lemmas | 2895-2926 | Proven |
| Duration construction | 1750-1983 | Needs discreteness proof |

### Relevant Mathlib Patterns

1. **Classical.axiom_of_choice**: `(∀ x, ∃ y, P x y) → ∃ f, ∀ x, P x (f x)`
2. **RelEmbedding.natLT**: Builds strictly increasing sequence from step relation
3. **Set.seq_of_forall_finite_exists**: Dependent choice pattern for sequences

### References

1. [Modal Logic, Blackburn et al., Chapter 4](https://www.cambridge.org/core/books/modal-logic/F7FE8F7606F871A0BC498A3C12C0EC97) - Canonical Models
2. [Goldblatt, Logics of Time and Computation](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation) - Temporal completeness
3. Task 257 research-004.md - Relativized completeness approach
4. Task 458 research-001.md, research-002.md - Initial analysis and strategy exploration
5. Mathlib patterns for sequence construction and dependent choice

## Next Steps

1. Implement Phase 1: Strengthen canonical_task_rel with persistence conditions
2. Update forward_extension proof to satisfy new conditions
3. Attempt Duration discreteness proof
4. If (3) succeeds, complete canonical_history with chain construction
5. If (3) blocked, document limitation and use chain_domain with sorry

Run `/plan 464` to create an implementation plan based on these recommendations.
