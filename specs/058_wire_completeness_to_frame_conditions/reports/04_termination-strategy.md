# Research Report: Termination Strategy for restricted_bounded_witness

**Task**: 58 - Wire completeness to FrameConditions
**Session**: sess_1774457348_9a2ac7
**Date**: 2026-03-25
**Focus**: Analyze the termination blocker in `restricted_bounded_witness` and recommend a solution based on task 64 findings

## 1. Executive Summary

The termination proof for `restricted_bounded_witness` is blocked because:

1. **The `boundary_resolution_set` definition is wrong.** It includes `chi in u` as a condition, which defeats its purpose of forcing resolution of boundary F-obligations.

2. **The correct fix** is to remove the `chi in u` condition and add a proper consistency proof for the modified seed.

3. **The termination argument then becomes trivial**: boundary cases resolve directly (depth decreases to 0), interior cases use the already-proven Class A argument (depth decreases by 1).

**Confidence**: HIGH (based on task 64 team research and archived task 53 root cause analysis)

## 2. The Problem

### 2.1 Current State

The theorem `restricted_bounded_witness` at `SuccChainFMCS.lean:2235` has termination sorries:

```lean
theorem restricted_bounded_witness (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (h_d_ge : d >= 1)
    (h_iter_in : iter_F d theta in restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta not_in restricted_forward_chain phi M0 k) :
    exists m : Nat, m > k and theta in restricted_forward_chain phi M0 m
```

The proof uses induction on `d` but the recursive calls don't always decrease `d`:

| Case | Recursive Call Depth | Decrease? |
|------|---------------------|-----------|
| F resolved, d' = 1 | n | Yes (n < n+1) |
| F resolved, d' > 1 | d' + (n-1) >= n+1 | **No** |
| F deferred | d' + n >= n+1 | **No** |

### 2.2 Root Cause Analysis (from Task 53 Archive)

The fundamental issue is that the f_step property `psi in chain(k+1) OR F(psi) in chain(k+1)` is genuinely disjunctive. The Lindenbaum extension resolves this non-deterministically. Without additional forcing, the proof cannot guarantee that the disjunction resolves to `psi` rather than `F(psi)`.

For boundary cases where `FF(psi) not_in deferralClosure`, the deferral option (`F(psi) in chain(k+1)`) would put a formula outside `deferralClosure` into the chain, which is impossible. **But the current proof doesn't exploit this.**

### 2.3 The boundary_resolution_set Bug

The `boundary_resolution_set` was added to force resolution of boundary F-obligations. But the current definition at `SuccExistence.lean:281` is:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | chi in u and                           -- BUG: This condition defeats the purpose
         Formula.some_future chi in u and
         Formula.some_future (Formula.some_future chi) not_in (deferralClosure phi : Set Formula)}
```

The `chi in u` condition was added "to make consistency trivial" (per the docstring), but it means the set only contains formulas that are **already in** the current world. This doesn't help resolve F-obligations for formulas that aren't yet in the world.

**Correct definition** (from task 53 research):
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {psi | Formula.some_future psi in u and
         Formula.some_future (Formula.some_future psi) not_in (deferralClosure phi : Set Formula)}
```

## 3. The Solution

### 3.1 Fix the boundary_resolution_set Definition

Remove the `chi in u` condition:

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {psi | Formula.some_future psi in u and
         Formula.some_future (Formula.some_future psi) not_in (deferralClosure phi : Set Formula)}
```

### 3.2 Prove Consistency of the Modified Seed

The key lemma needed is:

```lean
theorem boundary_resolution_set_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) (h_F_top : F_top in u) :
    SetConsistent (constrained_successor_seed_restricted phi u)
```

**Consistency Argument** (from task 53, Section 4.3):

For `psi in boundary_resolution_set(phi, u)`:
1. `F(psi) in u` (by definition)
2. `FF(psi) not_in deferralClosure` (by definition)
3. `psi in deferralClosure` (since `F(psi) in u subset deferralClosure` and `psi in subformulaClosure(F(psi))`)

Suppose adding `psi` to the seed is inconsistent. Then `seed derives neg(psi)`.

Can `neg(psi) in g_content(u)`? That would require `G(neg(psi)) in u`. But:
- `F(psi) = neg(G(neg(psi)))` (by definition of F)
- Having both `G(neg(psi)) in u` and `neg(G(neg(psi))) in u` contradicts MCS consistency

Therefore `neg(psi) not_in g_content(u)`.

Can `neg(psi)` come from other seed components?
- `deferralDisjunctions`: These are `chi or F(chi)` formulas, not negations of formulas
- `p_step_blocking_formulas_restricted`: These are `H(neg chi)` formulas for specific conditions; need to verify `psi` doesn't trigger this

The full consistency argument requires showing that `psi` doesn't conflict with any `H(neg psi)` in the p_step_blocking set. This is non-trivial but follows from the structure of the blocking formulas.

### 3.3 Prove Boundary Resolution in Successor

With the fixed definition, prove:

```lean
theorem boundary_resolution_in_successor (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) (h_F_top : F_top in u)
    (psi : Formula)
    (h_F_psi : Formula.some_future psi in u)
    (h_FF_not : Formula.some_future (Formula.some_future psi) not_in deferralClosure phi) :
    psi in constrained_successor_restricted phi u h_mcs h_F_top
```

**Proof**:
1. `psi in boundary_resolution_set phi u` (by h_F_psi and h_FF_not)
2. `boundary_resolution_set phi u subset constrained_successor_seed_restricted phi u`
3. `constrained_successor_seed_restricted phi u subset constrained_successor_restricted phi u h_mcs h_F_top` (Lindenbaum extension)
4. Therefore `psi in constrained_successor_restricted phi u h_mcs h_F_top`

### 3.4 Rewrite restricted_bounded_witness

With boundary resolution working, the proof becomes:

```lean
theorem restricted_bounded_witness (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
    (h_d_ge : d >= 1)
    (h_iter_in : iter_F d theta in restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta not_in restricted_forward_chain phi M0 k) :
    exists m : Nat, m > k and theta in restricted_forward_chain phi M0 m := by
  -- Case split on whether FF(iter_F (d-1) theta) in deferralClosure
  by_cases h_boundary : Formula.some_future (Formula.some_future (iter_F (d-1) theta)) in deferralClosure phi
  case inl =>
    -- INTERIOR CASE: Use Class A argument (already proven)
    -- restricted_single_step_forcing_interior gives iter_F (d-1) theta in chain(k+1)
    -- Recurse with decreased depth (d-1)
    ...
  case inr =>
    -- BOUNDARY CASE: iter_F (d-1) theta in chain(k+1) directly by boundary resolution
    -- If d = 1: theta in chain(k+1), done
    -- If d > 1: Recurse with decreased depth (d-1)
    ...
termination_by d  -- Now terminates because depth always decreases!
```

### 3.5 Why This Solves Termination

In both cases, the depth decreases by at least 1:
- Interior case: Class A argument forces resolution, giving iter_F (d-1) theta in chain(k+1). New depth is d-1.
- Boundary case: boundary_resolution forces psi directly into chain(k+1). New depth is d-1.

The problematic "d' > 1" and "F deferred" cases from the current proof disappear because:
- When d' > 1 at the boundary, the boundary_resolution forces resolution anyway
- F cannot defer at the boundary because FF(psi) not_in deferralClosure means F(psi) cannot persist in the successor

## 4. Implementation Steps

### Step 1: Fix boundary_resolution_set (30 min)

In `SuccExistence.lean`:
1. Remove `chi in u` condition from definition
2. Update docstring
3. Update `mem_boundary_resolution_set_iff` lemma

### Step 2: Prove boundary_resolution_set_subset_u (1 hour)

This is the key consistency lemma. The seed must remain a subset of a consistent extension. The argument from Section 3.2 above provides the proof sketch.

Key sub-lemmas:
- `neg_psi_not_in_g_content_when_F_psi_in_u`
- `psi_not_conflicts_with_p_step_blocking`

### Step 3: Prove boundary_resolution_in_chain (30 min)

Theorem stating that boundary formulas resolve directly in the successor chain.

### Step 4: Rewrite restricted_bounded_witness (1 hour)

Replace the current proof with the case-split approach from Section 3.4. The termination proof should be `termination_by d` with automatic decreasing proof.

### Step 5: Verify downstream (30 min)

- `restricted_forward_chain_forward_F` should become sorry-free
- `restricted_forward_chain_iter_F_witness` should become sorry-free
- `lake build` should succeed

## 5. Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Consistency proof harder than expected | Medium | Task 53 provides the argument structure. If stuck, can use Classical.byContradiction with the semantic fact that a valid model must satisfy F-coherence. |
| p_step_blocking conflict | Low | The blocking formulas are `H(neg chi)` for `P(chi) not_in u and chi not_in u`. When `F(psi) in u`, the temporal duality should prevent `P(psi)` conflicts. |
| Existing lemmas depend on `chi in u` | Low | Only `boundary_resolution_set_subset_deferralClosure` and `neg_not_in_boundary_resolution_set` use this. Both can be reproven with the new definition. |

## 6. Alternative Approaches (NOT Recommended)

### Alternative A: Lexicographic Termination Measure

Use `(maxD - d, pending_count)` where `maxD` is the maximum F-depth in deferralClosure.

**Why not**: This adds significant complexity (defining pending_count, proving it decreases) without addressing the fundamental issue that the construction allows infinite deferral.

### Alternative B: Fuel-Based Recursion

Add explicit fuel parameter bounded by `|deferralClosure| * maxD`.

**Why not**: Changes the theorem signature and requires proving fuel suffices. The boundary resolution fix is cleaner.

### Alternative C: Extend to Full MCS

Extend each chain element to a full MCS and use the unrestricted `bounded_witness`.

**Why not**: Task 53 analysis shows the F-boundary from DRM doesn't transfer to the extension. Also more complex than fixing the seed.

## 7. References

- Task 64 Team Research: `specs/064_critical_path_review/reports/02_team-research.md`
- Task 53 Root Cause Analysis: `specs/archive/053_direct_bounded_witness_induction/reports/01_bounded-witness-restructuring.md`
- Task 58 Plan v2: `specs/058_wire_completeness_to_frame_conditions/plans/02_revised-strategy-c.md`
- Current implementation: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:2235`
- boundary_resolution_set: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:281`
