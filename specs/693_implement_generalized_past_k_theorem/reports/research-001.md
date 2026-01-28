# Research Report: Task #693

**Task**: 693 - Implement generalized_past_k theorem
**Started**: 2026-01-28T10:00:00Z
**Completed**: 2026-01-28T10:30:00Z
**Effort**: Low (< 1 hour implementation)
**Priority**: High (blocks Task 657)
**Dependencies**: None (all prerequisites exist)
**Sources/Inputs**: Codebase analysis, lean_local_search, lean_leansearch
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The `generalized_temporal_k` theorem exists and provides a complete pattern to follow
- Implementation requires adding `generalized_past_k` using temporal duality approach
- Key components (`past_k_dist`, `temporal_duality` rule, `deduction_theorem`) already exist
- Two implementation approaches available: direct proof mirroring `generalized_temporal_k`, or derivation via temporal duality

## Context & Scope

Task 693 requires implementing `generalized_past_k` theorem in `GeneralizedNecessitation.lean`. This theorem states:

```
If Gamma |- phi, then (H Gamma) |- H phi
```

Where `H` is the "all_past" temporal operator (also written as P for "Past" in some notation). This is the past-time analog of the existing `generalized_temporal_k` which handles the future operator `G` (written as F for "all_future" or "Future").

The theorem is needed to complete the `past_seed_consistent` proof in `IndexedMCSFamily.lean` (Task 657), which currently has a `sorry` at line 450.

## Findings

### 1. Existing `generalized_temporal_k` Implementation

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`

**Signature**:
```lean
noncomputable def generalized_temporal_k : (Gamma : Context) -> (phi : Formula) ->
    (h : Gamma |- phi) -> ((Context.map Formula.all_future Gamma) |- Formula.all_future phi)
```

**Proof Structure** (lines 101-122):
- Base case: Empty context uses `DerivationTree.temporal_necessitation`
- Inductive case:
  1. Apply `deduction_theorem` to get `Gamma' |- A.imp phi`
  2. Apply inductive hypothesis to get `(FGamma') |- F(A.imp phi)`
  3. Use `temp_k_dist` axiom: `|- F(A -> phi) -> (FA -> F phi)`
  4. Apply weakening and modus ponens
  5. Use `reverse_deduction` to reconstruct the context

### 2. Required Components for `generalized_past_k`

| Component | Status | Location |
|-----------|--------|----------|
| `deduction_theorem` | EXISTS | `Bimodal.Metalogic_v2.Core.DeductionTheorem` |
| `reverse_deduction` | EXISTS | `GeneralizedNecessitation.lean` lines 40-46 |
| `past_k_dist` | EXISTS | `Bimodal.Theorems.Perpetuity.Principles` lines 725-737 |
| `temporal_necessitation` for past | DERIVABLE | Via temporal duality |
| `Context.map` | EXISTS | `Bimodal.Syntax.Context` line 80 |

### 3. Temporal Duality Infrastructure

The codebase has complete temporal duality support:

**`temporal_duality` inference rule** (Derivation.lean line 136-137):
```lean
| temporal_duality (phi : Formula)
    (d : DerivationTree [] phi) : DerivationTree [] phi.swap_past_future
```

**`swap_temporal` function** (Formula.lean lines 289-295):
- Swaps `all_past` <-> `all_future` recursively
- Is an involution: `swap_temporal . swap_temporal = id`

**`past_k_dist` derivation** (Principles.lean lines 725-737):
The `past_k_dist` theorem is derived from `future_k_dist` via temporal duality:
```lean
noncomputable def past_k_dist (A B : Formula) :
    |- (A.imp B).all_past.imp (A.all_past.imp B.all_past) := by
  -- Apply future_k_dist to swapped formulas, then apply temporal duality
```

### 4. Missing Component: Past Necessitation

There is NO primitive `past_necessitation` rule in the proof system. However, it can be derived:

**Derivation pattern**:
```lean
-- If |- phi, then |- H phi
-- Proof: apply temporal_duality to get |- swap(phi)
--        apply temporal_necessitation to get |- G(swap(phi))
--        apply temporal_duality again to get |- H phi
def past_necessitation (phi : Formula) (d : [] |- phi) : [] |- Formula.all_past phi := by
  have h_swap : |- phi.swap_temporal := DerivationTree.temporal_duality _ d
  have g_swap : |- phi.swap_temporal.all_future := DerivationTree.temporal_necessitation _ h_swap
  have final : |- phi.swap_temporal.all_future.swap_temporal :=
    DerivationTree.temporal_duality _ g_swap
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at final
  exact final
```

### 5. Usage Context in Task 657

In `IndexedMCSFamily.lean` (lines 436-450), the `past_seed_consistent` proof requires:
```lean
-- L |- bot
-- Need: H L |- H bot (i.e., L.map all_past |- all_past bot)
-- This is exactly generalized_past_k L bot d_bot
```

The comment at line 445-449 explicitly states:
```
-- **Infrastructure needed**: generalized_past_k theorem
-- This can be derived from generalized_temporal_k via temporal duality,
-- but requires additional infrastructure to apply swap_past_future at context level.
```

## Proof Strategies

### Strategy A: Direct Implementation (Recommended)

Mirror the `generalized_temporal_k` proof structure, replacing:
- `Formula.all_future` -> `Formula.all_past`
- `temporal_necessitation` -> derived `past_necessitation`
- `temp_k_dist` axiom -> `past_k_dist` theorem

**Advantages**:
- Clearer correspondence to the future version
- Easier to understand and maintain
- Follows established codebase patterns

### Strategy B: Derivation via Temporal Duality

Derive `generalized_past_k` from `generalized_temporal_k` by:
1. Apply `swap_temporal` to all formulas in context
2. Apply `generalized_temporal_k` to the swapped version
3. Apply `swap_temporal` back

**Advantages**:
- Shorter proof
- Demonstrates duality relationship

**Challenges**:
- Requires proving `Context.map swap_temporal (Context.map swap_temporal Gamma) = Gamma`
- May need additional lemmas about swap_temporal distributing over context operations

### Strategy C: Auxiliary Lemma Approach

Factor out a common pattern and parameterize by operator:
```lean
def generalized_k (op : Formula -> Formula)
    (nec : forall phi, [] |- phi -> [] |- op phi)
    (k_dist : forall A B, |- (A.imp B |> op).imp ((op A).imp (op B)))
    (Gamma : Context) (phi : Formula) (h : Gamma |- phi) :
    (Context.map op Gamma) |- op phi
```

Then instantiate for both future and past.

**Status**: Not needed for MVP; Strategy A is simpler.

## Decisions

1. **Implementation Strategy**: Use Strategy A (direct implementation) for clarity and consistency
2. **File Location**: Add to existing `GeneralizedNecessitation.lean` after `generalized_temporal_k`
3. **Helper Function**: Add `past_necessitation` as a helper definition before `generalized_past_k`
4. **Imports**: Add import for `Bimodal.Theorems.Perpetuity.Principles` to access `past_k_dist`

## Recommendations

1. **Add `past_necessitation` helper** (Priority: High)
   - Define as derived theorem using temporal duality pattern
   - Place before `generalized_past_k` in the file

2. **Implement `generalized_past_k`** (Priority: High)
   - Follow exact structure of `generalized_temporal_k`
   - Use `past_necessitation` for base case
   - Use `past_k_dist` for inductive step

3. **Add documentation** (Priority: Medium)
   - Document the duality relationship to `generalized_temporal_k`
   - Reference Task 657 as the motivating use case

4. **Update module docstring** (Priority: Low)
   - Add `generalized_past_k` to the Main Theorems section

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `past_k_dist` signature mismatch | Low | Medium | Verified signature matches pattern |
| Import cycle issues | Low | Medium | `Principles.lean` has no deps on `GeneralizedNecessitation.lean` |
| `simp` automation differences | Medium | Low | Copy exact simp calls from similar proofs |

## Appendix

### A. Search Queries Used

1. `lean_local_search "generalized_past"` - No results (confirms theorem doesn't exist)
2. `lean_local_search "past_necessitation"` - No results (confirms helper doesn't exist)
3. `lean_local_search "reverse_deduction"` - Found in GeneralizedNecessitation.lean
4. `lean_leansearch "list map function composition"` - Found `List.map_comp_map`

### B. File References

| File | Lines | Content |
|------|-------|---------|
| `GeneralizedNecessitation.lean` | 101-122 | `generalized_temporal_k` implementation |
| `Principles.lean` | 725-737 | `past_k_dist` implementation |
| `Derivation.lean` | 136-137 | `temporal_duality` rule |
| `Formula.lean` | 289-295 | `swap_temporal` definition |
| `IndexedMCSFamily.lean` | 436-450 | Usage site (Task 657 blocker) |

### C. Proposed Implementation Skeleton

```lean
/--
Derived past necessitation rule.

If |- phi, then |- H phi.

Derived via temporal duality: swap -> G -> swap back.
-/
noncomputable def past_necessitation (phi : Formula)
    (d : [] |- phi) : [] |- Formula.all_past phi := by
  have h_swap : |- phi.swap_temporal := DerivationTree.temporal_duality _ d
  have g_swap : |- phi.swap_temporal.all_future :=
    DerivationTree.temporal_necessitation _ h_swap
  have final : |- phi.swap_temporal.all_future.swap_temporal :=
    DerivationTree.temporal_duality _ g_swap
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at final
  exact final

/--
Generalized Past K rule (derived theorem).

If Gamma |- phi, then (H Gamma) |- H phi.

This is the past analog of generalized_temporal_k.
-/
noncomputable def generalized_past_k : (Gamma : Context) -> (phi : Formula) ->
    (h : Gamma |- phi) -> ((Context.map Formula.all_past Gamma) |- Formula.all_past phi)
  | [], phi, h => past_necessitation phi h
  | A :: Gamma', phi, h =>
    let h_deduction : Gamma' |- A.imp phi := deduction_theorem Gamma' A phi h
    let ih_res : (Context.map Formula.all_past Gamma') |- Formula.all_past (A.imp phi) :=
      generalized_past_k Gamma' (A.imp phi) h_deduction
    let k_dist : |- (Formula.all_past (A.imp phi)).imp
                    ((Formula.all_past A).imp (Formula.all_past phi)) :=
      past_k_dist A phi
    let k_dist_weak :
      (Context.map Formula.all_past Gamma') |-
      (Formula.all_past (A.imp phi)).imp
      ((Formula.all_past A).imp (Formula.all_past phi)) :=
      DerivationTree.weakening [] _ _ k_dist (List.nil_subset _)
    let h_mp :
      (Context.map Formula.all_past Gamma') |-
      (Formula.all_past A).imp (Formula.all_past phi) :=
      DerivationTree.modus_ponens _ _ _ k_dist_weak ih_res
    reverse_deduction h_mp
```
