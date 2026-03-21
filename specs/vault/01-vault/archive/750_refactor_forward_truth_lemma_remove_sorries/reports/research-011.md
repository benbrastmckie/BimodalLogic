# Research Report: Task #750 - Truth Lemma Gap: Deep Analysis and Alternative Approaches

**Task**: Refactor forward Truth Lemma - Remove sorries
**Date**: 2026-01-29
**Focus**: Rigorously research three potential approaches: (1) truth correspondence for MCS-derived states only, (2) modifying FiniteWorldState definition, (3) completely different proof strategy

## Executive Summary

After deep analysis of the architectural gap in `truth_at_implies_semantic_truth`, I have identified that the core issue is **not** a missing lemma but a fundamental type-theoretic mismatch. The current design allows arbitrary `FiniteWorldState` assignments that don't correspond to any logically coherent formula evaluation. Three approaches were analyzed:

| Approach | Feasibility | Effort | Breaking Changes |
|----------|-------------|--------|------------------|
| 1. MCS-restricted truth lemma | **High** | Medium (8-12 hours) | None |
| 2. Redefine FiniteWorldState | Low | Very High | Yes, significant |
| 3. Different proof strategy | Low-Medium | Very High | Requires new architecture |

**Recommendation**: Approach 1 (MCS-restricted truth lemma) is the most promising. It preserves existing sorry-free results while providing a clean path to complete `valid -> derives`.

## The Core Problem: Deep Analysis

### What the Sorry Needs

The sorry in `truth_at_implies_semantic_truth` (line 684 of SemanticCanonicalModel.lean) needs to prove:

```lean
theorem truth_at_implies_semantic_truth (phi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi) :
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin _) phi
```

In plain terms: "If phi is recursively true at position 0 in history tau, then the FiniteWorldState at tau.states(0) has assignment(phi) = true."

### Why It Fails

**The Gap in Detail**:

1. `truth_at` evaluates formulas **recursively**:
   - `truth_at (psi -> chi) = truth_at psi -> truth_at chi` (material implication)
   - `truth_at (box psi) = forall accessible histories, truth_at psi`
   - `truth_at (all_future psi) = forall future times, truth_at psi`

2. `semantic_truth_at_v2` checks a **boolean assignment**:
   - `semantic_truth_at_v2 w phi = w.assignment(phi) = true`

3. For this equivalence to hold, the assignment must **reflect logical structure**:
   - `assignment(psi -> chi) = true` iff `(assignment(psi) = true) -> (assignment(chi) = true)`

4. `IsLocallyConsistent` only enforces the **modus ponens direction**:
   ```lean
   def IsLocallyConsistent phi v : Prop :=
     -- Bot is false
     (forall h : bot in closure, v bot h = false) and
     -- Modus ponens: imp=true AND psi=true -> chi=true
     (forall psi chi, imp in closure -> psi in closure -> chi in closure ->
       v imp = true -> v psi = true -> v chi = true) and
     -- T-axiom: box=true -> psi=true
     (forall psi, box psi in closure -> psi in closure ->
       v (box psi) = true -> v psi = true)
   ```

5. **The Missing Property**: For arbitrary locally consistent assignments, we can have:
   - `v(psi) = false`, `v(chi) = false`, `v(psi -> chi) = false`
   - This is locally consistent (MP is vacuously satisfied)
   - But `truth_at (psi -> chi) = true` when `psi` is false!

### Why MCS-Derived States Are Different

For states built from `ClosureMaximalConsistent` sets, we have the **biconditional** via `closure_mcs_imp_iff`:

```lean
theorem closure_mcs_imp_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S)
    (psi chi : Formula) (h_imp_clos : Formula.imp psi chi in closure phi) :
    Formula.imp psi chi in S <-> (psi in S -> chi in S)
```

This provides BOTH directions. The proof (fully implemented in Closure.lean) uses:
- **Forward**: Consistency under modus ponens
- **Backward**: Negation completeness (psi in S OR psi.neg in S)

## Approach 1: MCS-Restricted Truth Lemma (RECOMMENDED)

### Strategy

Instead of proving truth correspondence for ALL SemanticWorldStates, restrict to the subtype of MCS-derived states:

```lean
def MCSDerivedWorldState (phi : Formula) :=
  { w : SemanticWorldState phi // exists S h_mcs,
    SemanticWorldState.toFiniteWorldState w = worldStateFromClosureMCS phi S h_mcs }
```

Then prove:

```lean
theorem mcs_truth_correspondence (phi : Formula)
    (w : MCSDerivedWorldState phi)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_w_eq : tau.states 0 ht = w.val) :
    truth_at (SemanticCanonicalModel phi) tau 0 phi <->
    semantic_truth_at_v2 phi w.val (BoundedTime.origin _) phi
```

### Why This Works

1. **MCS-derived states have full propositional closure**: `closure_mcs_imp_iff` provides the biconditional
2. **MCS-derived states have negation completeness**: Either psi in S or psi.neg in S
3. **All countermodels in completeness proofs are MCS-derived**: The `semantic_weak_completeness` proof constructs countermodels from MCS, so they satisfy the property
4. **The universal quantifier in `valid` can be specialized**: When phi is valid, it's true at ALL states including MCS-derived ones

### Implementation Plan

**Phase 1: Define MCSDerivedSemanticWorldState (2-3 hours)**
- Create subtype `MCSDerivedSemanticWorldState phi`
- Prove that `worldStateFromClosureMCS` produces MCS-derived states
- Show that the completeness countermodel construction yields MCS-derived states

**Phase 2: Prove Truth Lemma for MCS-Derived States (4-6 hours)**
- Prove `mcs_truth_at_iff_assignment` by structural induction on formulas
- For `imp`: Use `closure_mcs_imp_iff` (already proven)
- For `box`: Use MCS modal properties (need to verify these exist)
- For `all_past/all_future`: Use MCS temporal properties (may need to add)

**Phase 3: Connect to Completeness (2-3 hours)**
- Prove `valid_implies_mcs_semantic_truth`: valid phi -> truth at MCS-derived states
- Combine with `semantic_weak_completeness` for sorry-free completeness

### Risk Assessment

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Box case requires MCS modal property not yet proven | Medium | Check MCSProperties.lean, may need to add |
| Temporal cases complex | Medium | Use existing `set_mcs_all_future_all_future` pattern |
| Time bound issues | Low | BoundedTime handles this |

### Existing Infrastructure

Already available (sorry-free):
- `closure_mcs_imp_iff`: Implication biconditional
- `closure_mcs_neg_complete`: Negation completeness
- `worldStateFromClosureMCS_models_iff`: Membership equals assignment
- `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`: Temporal 4 axiom properties

Likely needed:
- MCS box property: `box psi in S <-> forall accessible S', psi in S'`
- This is the standard canonical model box property; should be derivable

## Approach 2: Redefine FiniteWorldState (NOT RECOMMENDED)

### Strategy

Strengthen `IsLocallyConsistent` to include full propositional closure:

```lean
def IsLocallyConsistent' (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  -- All existing conditions plus:
  -- Full propositional closure for implication
  (forall psi chi, imp in closure -> psi in closure -> chi in closure ->
    v imp = true <-> (v psi = true -> v chi = true)) and
  -- Negation completeness
  (forall psi, psi in closure -> v psi = true or v psi.neg = true)
```

### Why This Is Problematic

1. **Changes the type of FiniteWorldState**: All existing proofs would need revision
2. **Cardinality bound changes**: Fewer states satisfy the stronger constraint
3. **May not exist**: For some formulas, no assignment satisfies full propositional closure
4. **Essentially forces MCS-derived states**: The strengthened conditions are exactly what MCS provides

### Assessment

This approach is essentially forcing Approach 1 at the type level. The cost is much higher (refactoring all FiniteWorldState usage) for the same benefit. Not recommended.

## Approach 3: Different Proof Strategy (EXPLORATORY)

### Alternative Strategies Considered

**Strategy 3A: Algebraic Completeness (Lindenbaum-Tarski)**

Use the Boolean algebra structure of the Lindenbaum algebra directly:
- `AlgebraicRepresentation.lean` provides sorry-free `algebraic_representation_theorem`
- `UltrafilterMCS.lean` provides sorry-free bijection between ultrafilters and MCS

Gap: Still need to connect algebraic truth to Kripke validity. This is exactly what `AlgebraicSemanticBridge.lean` attempted and failed.

**Strategy 3B: Henkin-Style Completeness**

Build the canonical model directly from MCS without going through FiniteWorldState:
- Worlds = MCS (infinite set)
- Accessibility = MCS property
- Valuation = membership

Gap: This gives infinite model completeness, not finite model property. The FMP is a separate result.

**Strategy 3C: Filtration Method**

Start with infinite canonical model, then filtrate to finite model:
1. Prove completeness for infinite canonical model
2. Apply filtration lemma to get finite model
3. FMP follows

Gap: Requires proving full canonical model completeness first, which has similar truth lemma issues.

### Assessment

All alternative strategies either:
- Require the same truth lemma (just in a different context)
- Give weaker results (no FMP)
- Require significant new infrastructure

None offers a clear advantage over Approach 1.

## Mathlib Parallel: `FirstOrder.Language.Theory.IsMaximal.mem_iff_models`

Mathlib's first-order logic formalization has an analogous result:

```lean
theorem FirstOrder.Language.Theory.IsMaximal.mem_iff_models
    (h : T.IsMaximal) (phi : L.Sentence) : phi in T <-> T models phi
```

This is the first-order version of our truth lemma. Key observations:

1. **It applies to maximal theories only**: The `IsMaximal` hypothesis is essential
2. **Uses satisfiability, not arbitrary models**: `T models phi` means phi holds in all models of T
3. **Closed under derivation**: Maximal theories contain all their consequences

This validates Approach 1: restricting to MCS-derived (maximal) structures is the standard pattern.

## Concrete Implementation Path for Approach 1

### Files to Modify/Create

1. **FMP/MCSDerivedWorldState.lean** (NEW)
   - `MCSDerivedWorldState` subtype definition
   - Proof that completeness construction yields MCS-derived states
   - MCS truth lemma by structural induction

2. **FMP/SemanticCanonicalModel.lean** (MODIFY)
   - Add `mcs_valid_implies_semantic_truth` using MCS truth lemma
   - Update `sorry_free_weak_completeness` to use MCS path
   - Mark old `truth_at_implies_semantic_truth` as deprecated with doc explaining the gap

3. **Core/MCSProperties.lean** (MODIFY if needed)
   - Add MCS box property if not present
   - Verify temporal MCS properties are sufficient

### Estimated Effort

| Phase | Hours | Risk |
|-------|-------|------|
| Phase 1: MCSDerivedWorldState | 2-3 | Low |
| Phase 2: Truth lemma induction | 4-6 | Medium |
| Phase 3: Completeness connection | 2-3 | Low |
| **Total** | **8-12** | **Medium** |

## Recommendation

**Implement Approach 1: MCS-Restricted Truth Lemma**

Rationale:
1. **Mathematically sound**: Aligns with standard completeness proof patterns (Mathlib's `IsMaximal.mem_iff_models`)
2. **Preserves existing work**: Does not require changing `FiniteWorldState` or any sorry-free theorems
3. **Focused scope**: Only adds new infrastructure, no refactoring
4. **Clear path to completion**: Each phase has well-defined deliverables
5. **Validates existing architecture**: The current `semantic_weak_completeness` already works because it constructs MCS-derived countermodels

## Next Steps

1. **Create task for Approach 1 implementation** (or update this task's plan)
2. **Verify MCS box property exists** in MCSProperties.lean or canonical model files
3. **Design the structural induction** for the truth lemma, identifying each case
4. **Implement in phases** with verification at each step

## References

- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Current sorry location
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - `IsLocallyConsistent` definition, `IsMCSDerived`
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - `closure_mcs_imp_iff` (proven)
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS temporal properties
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - MCS-ultrafilter correspondence (sorry-free)
- Mathlib `Mathlib.ModelTheory.Satisfiability` - `FirstOrder.Language.Theory.IsMaximal.mem_iff_models`
- Prior research: `specs/750_refactor_forward_truth_lemma_remove_sorries/reports/research-009.md`, `research-010.md`
