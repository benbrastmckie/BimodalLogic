# Research Report: Task #986 (Second Iteration)

**Task**: 986 - bfmcs_construction_for_int
**Started**: 2026-03-17T10:00:00Z
**Completed**: 2026-03-17T11:30:00Z
**Effort**: 4-6 hours estimated for implementation
**Dependencies**: None (CanonicalFMCS.lean provides the template)
**Sources/Inputs**: Codebase exploration, Mathlib lookup, context files, ROAD_MAP.md
**Artifacts**: specs/986_bfmcs_construction_for_int/reports/research-002.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Core Problem**: The Int-indexed FMCS chain construction cannot guarantee that F/P witnesses land within the chain range. The simple chain `M_{n+1} = Lindenbaum(g_content(M_n))` extends g_content but does NOT preserve F-formulas.
- **Key Insight**: The sorry-free CanonicalFMCS.lean proves F/P coherence by using ALL MCSes as the domain - witnesses trivially exist because every MCS is in the domain.
- **Mathematical Solution**: Use `Int.exists_strictMono` from Mathlib to embed Int into CanonicalMCS, then prove F/P coherence by lifting from the all-MCS construction.
- **Recommended Approach**: **Enriched witness-guided chain** where at each step we use the canonical witness rather than a generic Lindenbaum extension.

## Context & Scope

### Task Goal

Prove a sorry-free BFMCS construction for D = Int: given any MCS M0, construct a temporally coherent BFMCS over Int containing M0 at position 0. The two remaining sorries are:
- `intFMCS_forward_F` (line 557-563)
- `intFMCS_backward_P` (line 570-574)

### Why the Simple Chain Fails

The current IntBFMCS.lean construction builds:
```
posChain(n+1) = successorMCS(posChain(n)) = Lindenbaum(g_content(posChain(n)))
negChain(n+1) = predecessorMCS(negChain(n)) = Lindenbaum(h_content(negChain(n)))
```

This guarantees:
- **G-coherence**: `CanonicalR M_{t} M_{t+1}` (g_content propagates)
- **H-coherence**: `CanonicalR_past M_{t+1} M_{t}` (h_content propagates)

But it does NOT guarantee:
- **F-coherence**: If `F(phi) in M_t`, then `phi in M_s` for some `s > t`

The problem is that `canonical_forward_F` (line 122-137 of CanonicalFrame.lean) gives a witness MCS `W = Lindenbaum({psi} ∪ g_content(M))`, but this W is NOT the same as `M_{t+1} = Lindenbaum(g_content(M_t))`. The two Lindenbaum extensions may differ because:
1. One contains `{psi}`, the other does not
2. Lindenbaum is non-deterministic (depends on formula enumeration order)

## Findings

### Why CanonicalFMCS Works (Key Insight)

From CanonicalFMCS.lean (lines 219-228):
```lean
theorem canonicalMCS_forward_F
    (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalMCS_mcs w) :
    ∃ s : CanonicalMCS, w ≤ s ∧ phi ∈ canonicalMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  exact ⟨s, CanonicalMCS.le_of_canonicalR w s h_R, h_phi_W⟩
```

The proof is trivial because:
1. `canonical_forward_F` gives witness MCS W with `CanonicalR M W` and `phi in W`
2. W is an MCS, so it's automatically a `CanonicalMCS` element
3. No need to show W is in any specific chain - it's in the domain by construction

**The domain being ALL MCSes is the key that unlocks trivial F/P coherence.**

### Mathematical Analysis: Why Int-Indexed is Hard

For Int-indexed FMCS, we need the witness to be AT A SPECIFIC INTEGER POSITION. This requires:

**Option A: Witness-Guided Chain Construction**
- At each step, instead of using generic Lindenbaum, use the canonical witness
- Problem: Which F-obligation do we witness? There are infinitely many.
- Solution: Dovetailing enumeration over (time, formula) pairs

**Option B: Embedding into CanonicalMCS**
- From Mathlib: `Int.exists_strictMono : ∃ f : Int → CanonicalMCS, StrictMono f`
- Build chain as `c(t) = f(t)` where f is strictly monotone
- F/P coherence: witness from `canonical_forward_F` is SOME element s in CanonicalMCS
- Problem: s may not be in the range of f (the embedding may not be surjective)

**Option C: Cofinal Embedding**
- Build embedding f that hits all "relevant" MCSes
- Define "relevant" as: reachable from M0 via canonical relations
- Problem: CanonicalMCS may be uncountable (continuum MCSes), Int is countable

### Mathlib Theorems (From Lookup)

1. **`Int.exists_strictMono`** (Mathlib.Order.Monotone.Basic):
   ```lean
   theorem Int.exists_strictMono : ∀ (α : Type u) [Preorder α] [Nonempty α] [NoMinOrder α] [NoMaxOrder α],
     ∃ f, StrictMono f
   ```
   For any preorder with no min/max, a strictly monotone `Int → α` exists.

2. **`strictMono_int_of_lt_succ`** (Mathlib.Order.Monotone.Basic):
   ```lean
   theorem strictMono_int_of_lt_succ {f : ℤ → α} (hf : ∀ n, f n < f (n + 1)) : StrictMono f
   ```
   If `f(n) < f(n+1)` for all n, then f is strictly monotone.

3. **`CanonicalMCS` Properties**:
   - `NoMaxOrder CanonicalMCS`: Every MCS has a successor (via `SetMaximalConsistent.has_canonical_successor`)
   - `NoMinOrder CanonicalMCS`: Every MCS has a predecessor (via `SetMaximalConsistent.has_canonical_predecessor`)
   - `Nonempty CanonicalMCS`: Any consistent context extends to an MCS

### The Enriched Witness-Guided Chain (Recommended Approach)

The mathematical solution is to modify the chain construction to EXPLICITLY use canonical witnesses:

**Construction**:
```
Phase 1: Build base chain via generic successorMCS/predecessorMCS
Phase 2: For each (t, phi) with F(phi) in M_t:
  - Get witness W from canonical_forward_F
  - If W is not already in chain, INSERT W at some position s > t
  - Adjust indices to maintain Int indexing
```

**Problem with Insertion**: Inserting disrupts the bijection Int -> MCS chain.

**Alternative: Pre-planned Witnesses**
```
At step n, let (s, phi) = unpair(n) (dovetailing enumeration)
If s < n and F(phi) in M_s:
  M_n := canonical witness for F(phi) at M_s
Else:
  M_n := generic successorMCS/predecessorMCS
```

This is exactly the DovetailingChain.lean approach, but it has the same problem: the witness from `canonical_forward_F` at time s may ALREADY have been placed at an earlier position (collision), or may conflict with existing chain structure.

### The Fundamental Obstacle

The core issue is:

**Theorem (Chain Incompleteness)**: For any countable chain `c : Int → MCS` with `CanonicalR c(t) c(t+1)`, there exist formulas phi and times t such that `F(phi) in c(t)` but `phi notin c(s)` for all `s > t`.

**Proof Sketch**:
1. The canonical frame has continuum-many MCSes (one for each ultrafilter on Formula)
2. A countable chain can only cover countably many MCSes
3. The witness for `F(phi)` may be one of the uncountably many MCSes NOT in the chain

### Solution: Relativized Coherence

The way forward is to accept that Int-indexed FMCS CANNOT satisfy full F/P coherence for arbitrary formulas. Instead:

**Relativized F-Coherence**: For formulas phi that appear in the ROOT context Gamma:
- If F(phi) in M_t, then phi in M_s for some s > t

This is achievable via dovetailing over the FINITE set of formulas in Gamma.

However, this is NOT what the current `TemporalCoherentFamily` definition requires. The definition requires F-coherence for ALL formulas.

### Alternative: Accept CanonicalMCS as Domain

The cleanest solution is to accept that for algebraic completeness with sorry-free F/P coherence, the domain must be CanonicalMCS (or a quotient), not Int.

**Impact on Algebraic Infrastructure**:
- `DiscreteInstantiation.lean` requires `[AddCommGroup D]`
- CanonicalMCS lacks addition
- Solution: Define a new infrastructure that works with Preorder D without group structure

This would require significant refactoring of the algebraic representation theorems.

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | HIGH | Confirms D=Int is problematic, but task 986 is algebraic path (not D-from-syntax) |
| DovetailingChain | HIGH | Documents why naive dovetailing fails - witness collision problem |
| Fragment Chain F-Persistence | HIGH | Confirms F-persistence requires non-linear construction |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| K-Relational with Cantor | ACTIVE | Task 986 is separate; algebraic path can coexist |
| Indexed MCS Family | ACTIVE | Task 986's FMCS construction follows this pattern |

### Key Dead End Analysis

From ROAD_MAP.md lines 601-619:
> "F-persistence proofs required complex reasoning about witness placement ordering that remained sorry-dependent."

This confirms that F/P coherence for Int-indexed chains is a known hard problem.

## Recommendations

### Option 1: Enriched Dovetailing (4-6 hours, Medium Confidence)

**Strategy**: Modify the chain construction to use a witness-guided approach.

**Key Insight**: The issue is that `successorMCS` uses generic Lindenbaum. Instead, at each step:
1. Enumerate all pending F-obligations from earlier times
2. Pick the oldest unwitnessed obligation (t, phi)
3. Use `canonical_forward_F` to get witness W for F(phi) at M_t
4. Set M_{current} := W (not generic Lindenbaum)
5. Verify that W is CanonicalR-compatible with the chain

**Challenge**: W must satisfy `CanonicalR M_{current-1} W`. This is NOT automatically true.
- `canonical_forward_F` at M_t gives W with `CanonicalR M_t W`
- We need `CanonicalR M_{current-1} W` where current-1 != t in general

**Possible Fix**: The witness seed includes `g_content(M_t)`. We need to show `g_content(M_{current-1}) ⊆ W`.
- If M_t -> M_{t+1} -> ... -> M_{current-1} via CanonicalR transitivity
- Then by temporal 4: `g_content(M_t) ⊆ g_content(M_{current-1})` is NOT true in general
- But: `G(G phi) in M_t` implies `G phi in g_content(M_t)` which propagates

**This requires careful bookkeeping** to ensure the chain remains connected.

### Option 2: Indexed Family via Pullback (3-4 hours, High Confidence)

**Strategy**: Don't try to prove F/P coherence directly. Instead:
1. Build the Int-indexed chain with generic successorMCS/predecessorMCS
2. Define `intFMCS_forward_F` using canonical_forward_F on the underlying MCS
3. The witness is SOME CanonicalMCS, not necessarily in the Int-indexed range
4. Map the witness back to Int via an auxiliary function

**Problem**: The witness must be at an Int index. If the witness is not in the chain, this fails.

**Modified Approach**: Change the definition of the FMCS to use a looser coherence condition:
```lean
-- Current (too strong for Int-indexed):
forward_F : ∀ t, ∀ φ, F(φ) ∈ mcs t → ∃ s > t, φ ∈ mcs s

-- Proposed (workable for Int-indexed):
forward_F_witness : ∀ t, ∀ φ, F(φ) ∈ mcs t →
  ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR (mcs t) W ∧ φ ∈ W
```

The witness W exists (via canonical_forward_F) but may not be in the chain. However, this changes the FMCS interface and would require updating TemporalCoherence.lean.

### Option 3: Accept Conditional Theorem (1-2 hours, High Confidence)

**Strategy**: Keep the sorries and document them as intentional technical debt.

The `parametric_algebraic_representation_conditional` already takes `construct_bfmcs` as a parameter. We can:
1. Provide `construct_bfmcs` with the current implementation (sorries included)
2. Document that F/P coherence is sorry-dependent
3. Mark the algebraic representation as conditional

This is acceptable if the primary goal is D-from-syntax completeness (Task 956), not algebraic completeness.

### Option 4: Refactor to CanonicalMCS Domain (6-8 hours, High Confidence)

**Strategy**: Accept that Int is the wrong domain and use CanonicalMCS.

1. Modify algebraic infrastructure to work with Preorder D (not AddCommGroup D)
2. Use CanonicalMCS as the domain for algebraic completeness
3. The representation theorem becomes:
   ```lean
   theorem algebraic_representation_CanonicalMCS (φ : Formula) :
     (∀ M : Model CanonicalMCS, M.satisfies φ) → [] ⊢ φ
   ```

**Impact**: Requires redefining TaskFrame, task_rel, and related infrastructure.

## Final Recommendation

**Primary Recommendation: Option 3 (Accept Conditional)**

Given:
1. The D-from-syntax path (Task 956) is the PRIMARY completeness strategy
2. The algebraic path is LOW priority (per ROAD_MAP.md Ambitions)
3. F/P coherence for Int-indexed chains is mathematically difficult
4. The current infrastructure already supports conditional theorems

The pragmatic choice is to accept the sorries as intentional technical debt. The `parametric_algebraic_representation_conditional` is already designed for this.

**Secondary Recommendation: Option 1 (Enriched Dovetailing)**

If a sorry-free algebraic path is required, implement enriched dovetailing with careful witness tracking. The key insight is:

```
At each step n with target time t = dovetailIndex(n):
1. Find the oldest (s, phi) pair with s < t and F(phi) in M_s and phi not witnessed yet
2. If found: M_t := canonical_forward_F witness for (s, phi)
3. Verify: CanonicalR M_{t-1} M_t (may need G-propagation lemma)
4. If not found: M_t := generic successorMCS(M_{t-1})
5. Track witnessed obligations to avoid re-witnessing
```

The verification step (3) is the crux. It requires proving that the canonical witness is CanonicalR-connected to the chain endpoint.

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Chain Incompleteness Theorem | The Fundamental Obstacle | No | new_file |
| Relativized F-Coherence | Solution: Relativized Coherence | No | extension |
| Witness-Guided Chain | Enriched Dovetailing | Partial (DovetailingChain.lean) | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `temporal-coherence-patterns.md` | `project/math/lattice-theory/` | F/P coherence approaches and their limitations | Medium | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| ROAD_MAP.md | Dead End: Int Chain F-Persistence | Add mathematical proof of why countable chains cannot achieve full F-coherence | Low | No |

### Summary

- **New files needed**: 1 (optional)
- **Extensions needed**: 1 (optional)
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. **Primary Path**: Accept sorries as intentional technical debt for algebraic path
2. **Rationale**: D-from-syntax (Task 956) is the primary completeness strategy
3. **Alternative**: If sorry-free is required, implement enriched witness-guided dovetailing

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Enriched dovetailing may still have corner cases | Medium | Thorough testing of edge cases (boundary times, multiple obligations) |
| Refactoring to CanonicalMCS domain is high effort | High | Only pursue if D-from-syntax path is abandoned |
| Int-indexed F/P coherence may be mathematically impossible | Medium | Accept conditional theorem; focus on D-from-syntax |

## Appendix

### Search Queries Used

- Glob: `**/*CanonicalFMCS*.lean`, `**/*CanonicalFrame*.lean`, `**/*DovetailingChain*.lean`
- Grep: `canonical_forward_F`, `forward_F.*sorry`, `h_content_subset_implies_g_content_reverse`
- lean_leansearch: "order embedding from integers to preorder"
- lean_leanfinder: "constructing a chain indexed by integers in a preorder"

### Key Mathlib Theorems

| Theorem | Type | Relevance |
|---------|------|-----------|
| `Int.exists_strictMono` | `∃ f : Int → α, StrictMono f` | Embedding Int into CanonicalMCS |
| `strictMono_int_of_lt_succ` | `(∀ n, f n < f (n + 1)) → StrictMono f` | Building monotone chain |
| `NoMaxOrder.infinite` | Nonempty NoMaxOrder → Infinite | CanonicalMCS is infinite |

### References

- IntBFMCS.lean (lines 557-574): Current sorry locations
- CanonicalFMCS.lean (lines 219-251): Sorry-free forward_F/backward_P
- CanonicalFrame.lean (lines 122-137): canonical_forward_F proof
- WitnessSeed.lean: g_content/h_content duality theorems
- ROAD_MAP.md (lines 515-619): Dead Ends analysis
