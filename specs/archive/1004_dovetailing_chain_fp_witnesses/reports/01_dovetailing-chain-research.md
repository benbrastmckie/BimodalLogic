# Research Report: Task #1004

**Task**: Implement enriched dovetailing chain construction for F/P witnesses
**Date**: 2026-03-19
**Focus**: Resolving sorries at intFMCS_forward_F (line 563) and intFMCS_backward_P (line 574)

## Summary

The two sorries in IntBFMCS.lean arise because the basic `intChainMCS` construction uses generic Lindenbaum extension at each step, which does not guarantee that witnesses from `canonical_forward_F`/`canonical_backward_P` appear in the chain. The solution requires a dovetailing construction that enumerates (position, formula) pairs and uses the specific witness MCSes from the canonical theorems. The project already has extensive dovetailing infrastructure in `Dovetailing.lean` and `DovetailedBuild.lean` that can be adapted for this purpose.

## Findings

### 1. Problem Analysis

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`

**The Two Sorries**:

```lean
-- Line 563
theorem intFMCS_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ intChainMCS M0 h_mcs0 t) :
    ∃ s : Int, t < s ∧ phi ∈ intChainMCS M0 h_mcs0 s := by
  sorry

-- Line 574
theorem intFMCS_backward_P (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula)
    (h_P : Formula.some_past phi ∈ intChainMCS M0 h_mcs0 t) :
    ∃ s : Int, s < t ∧ phi ∈ intChainMCS M0 h_mcs0 s := by
  sorry
```

**Root Cause**: The basic chain construction (`intChainMCS`) iterates via:
- `posChain n+1 = successorMCS(posChain n)` - Lindenbaum of `g_content`
- `negChain n+1 = predecessorMCS(negChain n)` - Lindenbaum of `h_content`

When `F(phi) ∈ mcs(t)`, `canonical_forward_F` provides a witness MCS W with `CanonicalR mcs(t) W` and `phi ∈ W`. However, the chain at position `t+1` is a *different* MCS (the generic Lindenbaum extension). The witness W may not appear anywhere in the basic chain.

### 2. Existing Dovetailing Infrastructure

**Key Files**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/Dovetailing.lean` - Cantor pairing infrastructure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` - Dovetailed staged construction

**Core Types and Theorems**:

```lean
-- Cantor pairing wrapper
abbrev dovetailPair : Nat → Nat → Nat := Nat.pair
abbrev dovetailUnpair : Nat → Nat × Nat := Nat.unpair

-- Process obligation type
structure ProcessObligation where
  point_index : Nat
  formula_encoding : Nat

-- Key coverage theorem
theorem forall_obligation_eventually_processed (p f : Nat) :
    ∃ n, obligationAtStep n = mkObligation p f
```

**Existing Witness Processing Functions**:
```lean
-- From DovetailedBuild.lean
noncomputable def processForwardObligationDovetailed
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) : DovetailedBuildState :=
  if h : Formula.some_future phi ∈ point.mcs then
    let witness_mcs := executeForwardStep point.mcs point.is_mcs phi h
    let witness_is_mcs := executeForwardStep_mcs (h_mcs := point.is_mcs) (h_P := h)
    addPoint state witness_mcs witness_is_mcs stage
  else state
```

### 3. Canonical Witness Theorems

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

```lean
-- Forward F witness (sorry-free)
theorem canonical_forward_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ psi ∈ W

-- Backward P witness (sorry-free)
theorem canonical_backward_P (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR_past M W ∧ psi ∈ W
```

These are the witnesses that need to appear in the chain at appropriate positions.

### 4. Alternative Approach: Saturated Chains

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean`

The codebase also has a Zorn's lemma-based approach using saturated chains:

```lean
-- F-saturated chain: witnesses exist within the chain
def ChainFSaturated (C : Set CanonicalMCS) : Prop :=
  ∀ w ∈ C, ∀ phi : Formula,
    Formula.some_future phi ∈ w.world →
    ∃ v ∈ C, w < v ∧ phi ∈ v.world

-- P-saturated chain: past witnesses exist within the chain
def ChainPSaturated (C : Set CanonicalMCS) : Prop :=
  ∀ w ∈ C, ∀ phi : Formula,
    Formula.some_past phi ∈ w.world →
    ∃ v ∈ C, v < w ∧ phi ∈ v.world
```

This approach uses Zorn's lemma to construct a maximal saturated chain containing the root MCS, then embeds this chain into Int.

### 5. FMCSTransfer Pattern

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`

An embedding/retraction pair from CanonicalMCS to Int would give sorry-free forward_F/backward_P via transfer. Requirements:
- `embed : CanonicalMCS →o Int` (monotone)
- `retract : Int → CanonicalMCS`
- `retract_left_inverse`, `embed_retract_eq` (bijection on image)
- `retract_lt`, `embed_lt` (strict monotonicity)

## Solution Strategies

### Strategy A: Enriched Dovetailing Chain (Recommended)

Modify `intChainMCS` to use dovetailing that ensures witnesses appear:

**Key Insight**: Instead of using generic `successorMCS`/`predecessorMCS`, enumerate all (position, formula) obligations and use witnesses from `canonical_forward_F`/`canonical_backward_P`.

**Implementation Outline**:

1. **Define obligation enumeration**:
   - At step n, process obligation `unpair(n) = (t, k)` where t is position, k is formula encoding
   - Decode formula k to phi
   - If t < 0 (past position), process P-obligations; if t >= 0, process F-obligations

2. **Define enriched chain state**:
   ```lean
   structure EnrichedChainState where
     mcs_at : Int → Set Formula
     is_mcs : ∀ t, SetMaximalConsistent (mcs_at t)
     pending_F : Finset (Int × Formula)  -- unwitnessed F-obligations
     pending_P : Finset (Int × Formula)  -- unwitnessed P-obligations
   ```

3. **Step function**:
   - Process next (t, phi) obligation from dovetailing order
   - If `F(phi) ∈ mcs_at t` and not yet witnessed:
     - Get witness W from `canonical_forward_F`
     - Assign W to the next available future position s > t
   - Symmetrically for P

4. **Prove coverage**:
   - `forall_obligation_eventually_processed` guarantees every (t, phi) is eventually processed
   - Each processed obligation either finds a witness or confirms no obligation exists

**Estimated Effort**: 200-300 lines of Lean

### Strategy B: Use SaturatedChain + Embedding

Leverage existing `SaturatedChain.lean`:

1. Use Zorn's lemma to get maximal saturated chain containing root MCS
2. The chain is F-saturated and P-saturated by construction
3. Define bijection between chain elements and Int (requires enumeration)
4. Apply FMCSTransfer pattern

**Challenge**: The maximal chain from Zorn may be uncountable. Need to show a countable saturated chain exists, which is non-trivial.

**Estimated Effort**: 150-200 lines (if countability proven)

### Strategy C: Direct CanonicalMCS Construction

Use CanonicalMCS directly as the domain (as done in `CanonicalFMCS.lean`):

**Problem**: `valid phi` quantifies over domains with `[AddCommGroup D] [LinearOrder D]`. CanonicalMCS does not have AddCommGroup structure.

**Workaround**: Change completeness theorem to use weaker validity or define algebraic structure on an enumerable subset of CanonicalMCS.

**Estimated Effort**: High - requires rearchitecting completeness theorem

## Recommendations

1. **Implement Strategy A** (Enriched Dovetailing Chain):
   - Reuse existing `Dovetailing.lean` infrastructure
   - Adapt `DovetailedBuild.lean` patterns for Int-indexed chain
   - Key modification: use `canonical_forward_F`/`canonical_backward_P` witnesses instead of generic Lindenbaum

2. **Implementation approach**:
   - Define `enrichedIntChainMCS` that builds the chain via dovetailing
   - At each step, either add a new witness MCS or propagate existing chain
   - Prove `enrichedIntChainMCS_forward_F` and `enrichedIntChainMCS_backward_P` by induction on dovetail step

3. **Key invariant to maintain**:
   - For all (t, phi) with t < dovetail_step(t, encode(phi)):
     - If `F(phi) ∈ mcs(t)`, then witness position s > t is already assigned
     - If `P(phi) ∈ mcs(t)`, then witness position s < t is already assigned

## Phase Decomposition (for Implementation Plan)

**Phase 1: Chain State Definition** (50 lines)
- Define `EnrichedChainState` structure
- Define position assignment for witnesses
- Initial state with root MCS at position 0

**Phase 2: Step Function** (80 lines)
- Process forward/backward obligations
- Use `canonical_forward_F`/`canonical_backward_P` for witnesses
- Position assignment logic

**Phase 3: Iteration and Union** (60 lines)
- Define full chain as limit of steps
- Prove monotonicity and coverage

**Phase 4: Forward F/Backward P Proofs** (100 lines)
- Prove `enrichedIntChainMCS_forward_F`
- Prove `enrichedIntChainMCS_backward_P`
- Key lemma: obligation (t, encode(phi)) is processed at step `pair(t_nat, encode(phi))`

**Phase 5: Integration** (30 lines)
- Replace `intChainMCS` with `enrichedIntChainMCS` in FMCS definition
- Update `intFMCS_forward_F` and `intFMCS_backward_P` to use new proofs

## References

- IntBFMCS.lean: Current chain construction with sorries
- CanonicalFrame.lean: `canonical_forward_F`, `canonical_backward_P` (sorry-free witnesses)
- Dovetailing.lean: Cantor pairing and obligation enumeration
- DovetailedBuild.lean: Dovetailed staged construction patterns
- SaturatedChain.lean: Zorn-based saturated chain construction
- FMCSTransfer.lean: Domain transfer infrastructure
- CanonicalFMCS.lean: Sorry-free construction over CanonicalMCS domain

## Next Steps

1. Create implementation plan based on Strategy A (Enriched Dovetailing Chain)
2. Implement phases 1-5 as described above
3. Verify integration with tasks 997 and 988 (dependencies)
