# Research Report: Task #458 - Alternative Strategies Analysis

**Task**: 458 - Extend canonical_history from singleton domain to full domain
**Date**: 2026-01-12
**Session ID**: sess_1768276143_d8e772
**Started**: 2026-01-12T18:00:00Z
**Completed**: 2026-01-12T19:00:00Z
**Effort**: 8-12 hours (estimated implementation)
**Priority**: High
**Parent**: Task 257 (Completeness Proofs)
**Dependencies**: Task 448 (Build canonical_history - singleton domain MVP)
**Language**: lean
**Sources/Inputs**:
  - Completeness.lean (current state with chain construction attempt)
  - WorldHistory.lean (WorldHistory type requirements)
  - TaskFrame.lean (Duration type constraints)
  - research-001.md (initial analysis)
  - research-004.md (relativized completeness approach)
  - Mathlib patterns for sequence construction
  - Modal logic literature
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- **Problem Structure**: The current implementation uses independent `Classical.choose` calls that don't guarantee coherence between states at different times
- **Duration Type**: Duration is an **abstract** totally ordered abelian group (not ℤ) constructed via Grothendieck completion of order-type equivalence classes
- **Chain approach (v002)**: Viable but requires careful handling of the abstract Duration type's relationship to ℕ
- **Three alternative strategies identified** with different trade-offs
- **Recommended approach**: Hybrid strategy using indexed chains with explicit composition proofs

## Context & Scope

### The Core Problem

The current `canonical_states` construction (lines 2638-2665 of Completeness.lean) uses:

```lean
noncomputable def canonical_states (S : CanonicalWorldState) (t : CanonicalTime) : CanonicalWorldState :=
  if h : t = 0 then S
  else if ht : (0 : CanonicalTime) < t then
    Classical.choose (forward_extension S t ht)
  else
    Classical.choose (backward_extension S (-t) ...)
```

**Coherence Problem**: When proving `respects_task` for times `s > 0` and `t > 0`:
- `canonical_states S s` is chosen independently (one Classical.choose call)
- `canonical_states S t` is chosen independently (another Classical.choose call)
- No guarantee that `canonical_task_rel (canonical_states S s) (t-s) (canonical_states S t)`

### Duration Type Analysis

From Completeness.lean (lines 1779-1951), Duration is:

1. **PositiveDuration**: Quotient of chain segments under order-type equivalence
2. **Duration**: Grothendieck group completion of PositiveDuration
3. **Structure**: `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`

**Key insight**: Duration is NOT isomorphic to ℤ in general. It's an abstract ordered abelian group whose structure emerges from the logic's axioms (temporal chain segments quotient).

**Implications for chain indexing**:
- Cannot assume Duration ≅ ℤ
- Need a step size `chain_step : Duration` that is provably positive
- Chain indexed by ℕ covers discrete multiples of step size
- Full domain requires extension beyond discrete chain

## Findings

### 1. Analysis of Duration Structure

**Current Definition** (line 1779):
```lean
noncomputable def Duration := Algebra.GrothendieckAddGroup PositiveDuration
```

**Properties available**:
- `AddCommGroup Duration` (from Grothendieck)
- `LinearOrder Duration` (defined in file)
- `IsOrderedAddMonoid Duration` (defined in file)

**What we DON'T have**:
- Explicit embedding `ℤ → Duration`
- Floor/ceiling operations
- Density or discreteness axioms
- Archimedean property

**The `chain_step` construction** (lines 2671-2676):
```lean
noncomputable def chain_step_pd : PositiveDuration :=
  PositiveDuration.add ⟦mkSingletonSigma someWorldState⟧ ⟦mkSingletonSigma someWorldState⟧

noncomputable def chain_step : Duration :=
  positiveToDuration chain_step_pd
```

**Problem**: Proving `chain_step > 0` requires showing two-element order type differs from one-element order type, which has a sorry placeholder.

### 2. Three Alternative Strategies

#### Strategy A: Strengthen canonical_task_rel to Include Persistence

**Idea**: Modify the definition of `canonical_task_rel` to automatically ensure that G-formulas and H-formulas persist through the relation.

**Current definition** (lines 2015-2018):
```lean
def canonical_task_rel (S : CanonicalWorldState) (t : CanonicalTime) (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T)
```

**Modified definition**:
```lean
def canonical_task_rel_strong (S : CanonicalWorldState) (t : CanonicalTime) (T : CanonicalWorldState) : Prop :=
  modal_transfer S T ∧
  (t > 0 → future_transfer S T) ∧
  (t < 0 → past_transfer S T) ∧
  -- Add persistence conditions:
  (t > 0 → ∀ φ, Formula.all_future φ ∈ S.val → Formula.all_future φ ∈ T.val) ∧
  (t < 0 → ∀ φ, Formula.all_past φ ∈ S.val → Formula.all_past φ ∈ T.val)
```

**Pros**:
- Makes compositionality easier to prove
- Persistence is a natural semantic property

**Cons**:
- Changes existing infrastructure (Task 447 work)
- May be harder to prove `forward_extension` and `backward_extension`
- Risks breaking proven lemmas

**Assessment**: Medium viability - requires careful refactoring

#### Strategy B: Use Quotient Construction for Coherent Histories

**Idea**: Instead of building histories directly, define an equivalence relation on potential histories and work with the quotient.

**Construction**:
```lean
-- A proto-history is any assignment of states to times
structure ProtoHistory where
  states : Duration → CanonicalWorldState
  origin : states 0

-- Two proto-histories are equivalent if they satisfy task relation
def history_equiv (h1 h2 : ProtoHistory) : Prop :=
  h1.origin = h2.origin ∧
  ∀ s t, s ≤ t → canonical_task_rel (h1.states s) (t - s) (h1.states t) ↔
                  canonical_task_rel (h2.states s) (t - s) (h2.states t)

-- Take quotient
def CoherentHistory := Quotient (history_equiv.setoid)
```

**Pros**:
- Coherence guaranteed by definition
- Works with any Duration type
- Avoids explicit choice of witnesses

**Cons**:
- Complex quotient infrastructure
- Need to lift operations to quotient
- May complicate truth lemma proofs
- Unclear how to extract actual world states

**Assessment**: Low viability - adds complexity without clear benefit

#### Strategy C: Indexed Chain with Explicit Composition (v002 Enhanced)

**Idea**: Build chains indexed by ℕ, but explicitly prove composition at each step rather than relying on general compositionality.

**Key insight**: The compositionality proof for consecutive steps (both positive durations) may be simpler than the general case with mixed signs.

**Construction**:
```lean
/-- Forward chain built step-by-step -/
noncomputable def canonical_forward_chain (S : CanonicalWorldState) : ℕ → CanonicalWorldState
| 0 => S
| n + 1 =>
    let Sn := canonical_forward_chain S n
    Classical.choose (forward_extension Sn chain_step chain_step_pos)

/-- The relation holds between consecutive chain elements by construction -/
lemma forward_chain_consecutive (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel (canonical_forward_chain S n) chain_step (canonical_forward_chain S (n + 1)) :=
  Classical.choose_spec (forward_extension (canonical_forward_chain S n) chain_step chain_step_pos)

/-- Build total relation by induction -/
lemma forward_chain_total (S : CanonicalWorldState) (n : ℕ) :
    canonical_task_rel S (n • chain_step) (canonical_forward_chain S n) := by
  induction n with
  | zero =>
    simp only [zero_smul]
    exact canonical_nullity S
  | succ n ih =>
    -- Need: task_rel S ((n+1) • step) (chain n+1)
    -- Have: task_rel S (n • step) (chain n)  [ih]
    -- Have: task_rel (chain n) step (chain n+1)  [consecutive]
    simp only [succ_nsmul]
    exact canonical_compositionality S (canonical_forward_chain S n)
          (canonical_forward_chain S (n+1)) (n • chain_step) chain_step ih
          (forward_chain_consecutive S n)
```

**Key requirement**: The `canonical_compositionality` proof must work for the case where both durations are positive (chain_step > 0). Looking at the code (lines 2140-2265), the positive+positive case has a sorry when the intermediate result needs past transfer, but for forward chains, both arguments are positive, so we stay in the "forward transfer" case.

**Analysis of compositionality for forward chains**:
- Case: x > 0, y > 0, x + y > 0
- Modal transfer composes (proven, lines 2145-2152)
- Future transfer: Need `Gφ ∈ S → φ ∈ U`
  - From ih: `Gφ ∈ S → φ ∈ T` (via future_transfer, since x = n•step > 0)
  - From consecutive: `Gφ ∈ T → ...` but wait, we need Gφ ∈ T, not just φ ∈ T
  - This requires **G-formula persistence**: `Gφ ∈ S ∧ x > 0 ∧ task_rel S x T → Gφ ∈ T`

**The persistence lemma exists** (lines 2077-2090):
```lean
theorem future_formula_persistence {S T : CanonicalWorldState} {d : CanonicalTime}
    (hrel : canonical_task_rel S d T) (hd : d > 0) (φ : Formula)
    (h_all_future : Formula.all_future φ ∈ S.val) :
    Formula.all_future φ ∈ T.val
```

**This is proven!** It uses `set_mcs_all_future_all_future` (G-4 axiom).

**Pros**:
- Uses existing proven infrastructure
- Coherence by construction
- Only requires compositionality for positive-positive case
- Forward chain composition should work with existing lemmas

**Cons**:
- Need to prove `chain_step_pos` (has sorry)
- Full domain coverage requires interpolation from chain points
- Backward chain requires similar but mirrored treatment

**Assessment**: High viability - builds on existing work

### 3. The chain_step_pos Gap

The critical sorry in Strategy C is proving `chain_step > 0` (line 2696):

```lean
theorem chain_step_pos : (0 : Duration) < chain_step := by
  unfold chain_step
  simp only [LT.lt]
  constructor
  · use chain_step_pd
    simp only [map_zero, zero_add]
  · -- 0 ≠ chain_step: two singletons ≠ one singleton in order type
    sorry
```

**What's needed**: Show that `chain_step_pd ≠ PositiveDuration.zero`, i.e., that concatenating two singleton segments gives a different order type than a single singleton.

**Approach**: Order types are bijection classes. A two-element set is NOT bijective to a one-element set (by cardinality).

**Proof sketch**:
```lean
-- chain_step_pd = two singletons concatenated
-- PositiveDuration.zero = one singleton
-- The carriers have different cardinalities (2 vs 1)
-- So they cannot be order-type equivalent (bijection implies equal cardinality)
```

**This should be provable** using basic set cardinality arguments, assuming the concat operation doesn't collapse elements.

### 4. Full Domain from Discrete Chain

Even with chain construction, we only get states at `n • chain_step` for n : ℕ.

**Options for full domain**:

**Option 4a: Accept discrete coverage**
- Define domain as `{t | ∃ n : ℕ, t = n • chain_step ∨ t = -(n • chain_step)}`
- Still convex if chain_step is "dense enough" for the logic

**Option 4b: Interpolation via forward_extension**
- For arbitrary `t > 0`, find n such that `n • chain_step ≤ t < (n+1) • chain_step`
- Use `forward_extension` from `chain n` to reach a state at time t
- Coherence follows from compositionality

**Option 4c: Use the abstract Duration directly**
- Since Duration is constructed from chain segments, every Duration element corresponds to some segment
- Could potentially index by Duration directly if we can define the recursion

**Recommended**: Option 4b for generality, with 4a as a simpler fallback.

### 5. Mathlib Patterns Relevant to Chain Construction

From `lean_leansearch` results:

**`exists_seq_of_forall_finset_exists`** (Mathlib.Data.Fintype.Basic):
```lean
theorem exists_seq_of_forall_finset_exists {α : Type*} (P : α → Prop) (r : α → α → Prop) :
  (∀ (s : Finset α), (∀ x ∈ s, P x) → ∃ y, P y ∧ ∀ x ∈ s, r x y) →
  ∃ f : ℕ → α, (∀ n, P (f n)) ∧ (∀ m n, m < n → r (f m) (f n))
```

This is a dependent-choice style lemma for building increasing sequences. Could potentially be adapted.

**`Nat.rec`**: Standard for recursive definitions on ℕ - already used in chain construction.

### 6. Comparison with Modal Logic Literature

Standard completeness proofs for temporal logic (Goldblatt, Blackburn et al.):

1. **Time as parameter, not constructed**: The time domain T is given, not built from syntax
2. **Worlds from syntax**: Maximal consistent sets
3. **Temporal ordering from formula membership**: w <_F v iff ∀φ, Gφ ∈ w → φ ∈ v

**Key difference in our setting**: We have a three-place task relation with duration, not just a binary accessibility relation.

**Implication**: Our construction is more complex, but the chain approach handles this by iterating unit steps.

## Decisions

1. **Chain construction (Strategy C) is the most viable approach** - it builds on existing proven infrastructure
2. **The chain_step_pos proof is the critical blocker** - this must be resolved first
3. **Compositionality for forward chains should work** - future_formula_persistence is proven
4. **Full domain extension via interpolation** - use forward_extension from nearest chain point

## Recommendations

### Implementation Order

1. **Phase 1: Prove chain_step_pos** (1-2 hours)
   - Show two-element order type ≠ one-element order type
   - Use cardinality argument on segment carriers

2. **Phase 2: Implement forward chain** (2-3 hours)
   - `canonical_forward_chain : CanonicalWorldState → ℕ → CanonicalWorldState`
   - `forward_chain_consecutive` using forward_extension
   - `forward_chain_total` using induction + compositionality

3. **Phase 3: Implement backward chain** (2-3 hours)
   - Mirror of forward chain construction
   - Use backward_extension instead

4. **Phase 4: Combine into canonical_states** (2 hours)
   - Integer indexing via ℕ + sign
   - Prove respects_task for chain points

5. **Phase 5: Extend to full domain** (2-3 hours)
   - Either accept discrete domain, or
   - Implement interpolation from nearest chain point

### Critical Dependencies

1. `forward_seed_consistent` must be proven for forward_extension to work
2. `backward_seed_consistent` must be proven for backward_extension to work
3. Both currently have sorry (lines 2377-2408, 2489-2494)

**Recommendation**: The seed consistency proofs should be tackled before or in parallel with chain construction.

### Key Lemmas to Verify

Before implementing, verify these existing lemmas compile without sorry:
- [x] `canonical_nullity` - reflexivity at 0 (PROVEN, lines 2036-2057)
- [x] `future_formula_persistence` - Gφ persists forward (PROVEN, lines 2077-2090)
- [x] `past_formula_persistence` - Hφ persists backward (PROVEN, lines 2103-2116)
- [ ] `forward_seed_consistent` - (HAS SORRY, line 2407)
- [ ] `backward_seed_consistent` - (HAS SORRY, line 2494)
- [ ] `canonical_compositionality` temporal cases - (HAS SORRY, lines 2265, 2287-2288, 2312-2316)

### Alternative if Compositionality Blocks

If `canonical_compositionality` cannot be proven for the required cases:

**Fallback**: Prove a specialized version for consecutive chain elements only:
```lean
lemma chain_compose (S T U : CanonicalWorldState) :
    canonical_task_rel S chain_step T →
    canonical_task_rel T chain_step U →
    canonical_task_rel S (chain_step + chain_step) U
```

This might be easier since both durations are exactly `chain_step` (strictly positive), avoiding mixed-sign complications.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `chain_step_pos` proof complex | High | Low | Cardinality argument should work |
| Seed consistency proofs block | High | Medium | May need to strengthen axiom usage |
| Compositionality sorries persist | High | Medium | Use specialized chain_compose lemma |
| Full domain interpolation complex | Medium | Medium | Accept discrete domain as fallback |
| Duration abstraction causes issues | Medium | Low | Can specialize to ℤ if needed |

## Appendix

### Key Code Locations

| Component | Location | Status |
|-----------|----------|--------|
| Duration type | Lines 1779-1931 | Has sorry in order properties |
| chain_step_pos | Lines 2686-2696 | HAS SORRY |
| forward_extension | Lines 2422-2463 | Complete except seed consistency |
| backward_extension | Lines 2519-2544 | HAS SORRY |
| canonical_compositionality | Lines 2136-2316 | Modal case complete, temporal HAS SORRY |
| future_formula_persistence | Lines 2077-2090 | PROVEN |
| past_formula_persistence | Lines 2103-2116 | PROVEN |
| forward_seed_consistent | Lines 2377-2408 | HAS SORRY |
| backward_seed_consistent | Lines 2489-2494 | HAS SORRY |

### References

1. [Modal Logic, Blackburn et al., Chapter 4](https://www.cambridge.org/core/books/modal-logic/F7FE8F7606F871A0BC498A3C12C0EC97) - Canonical Models
2. [Goldblatt, Logics of Time and Computation](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation) - Temporal completeness
3. Task 257 research-004.md - Relativized completeness approach
4. Task 458 research-001.md - Initial analysis
5. Mathlib `exists_seq_of_forall_finset_exists` - Dependent choice pattern

## Next Steps

1. Verify `future_formula_persistence` and `past_formula_persistence` are truly proven (no transitive sorries)
2. Attempt `chain_step_pos` proof using cardinality
3. If successful, proceed with Phase 2 (forward chain implementation)
4. In parallel, work on seed consistency proofs
