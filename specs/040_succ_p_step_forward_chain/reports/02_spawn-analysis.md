# Blocker Analysis: Task #40

**Parent Task**: #40 - succ_p_step_forward_chain
**Generated**: 2026-03-23
**Blocker**: Forward chain p_step cannot be proven from existing axioms without modifying the successor seed construction.

## Root Cause

The task is blocked because the forward chain construction via `successor_from_deferral_seed` does not include any constraints on P-formulas. This creates a structural asymmetry:

**Predecessor Seed** (satisfies p-step by construction):
```
predecessor_deferral_seed = h_content(u) UNION pastDeferralDisjunctions(u)
```
Where `pastDeferralDisjunctions` contains `phi OR P(phi)` for each `P(phi) in u`. This **forces** the MCS extension to satisfy p-step.

**Successor Seed** (no p-step guarantee):
```
successor_deferral_seed = g_content(u) UNION deferralDisjunctions(u)
```
Only contains F-formula deferrals. The Lindenbaum extension can add arbitrary P-formulas without any constraint to satisfy p-step.

### Why CanonicalTask Is Affected

The `CanonicalTask_backward_MCS_P` relation (CanonicalTaskRelation.lean:718) explicitly requires `h_p_step : p_content w <= u UNION p_content u` at each step. This is used by:

1. `backward_witness` (line 872) - proves bounded witness for P-formulas
2. `succ_chain_canonicalTask_backward_MCS_P_from` (SuccChainFMCS.lean:931) - builds chains for backward P coherence
3. `succ_chain_backward_P` (line 1020) - the backward P coherence theorem

The blocked sorry at line 350 (`succ_chain_fam_p_step` for forward chains) is called by `succ_chain_canonicalTask_backward_MCS_P_from` when building chains that cross from the forward region into the backward region.

### User Guidance: Focus on CanonicalTask, Not ExistsTask

The user explicitly stated to focus on **CanonicalTask** (discrete successor chains) rather than **ExistsTask** (Kripke-style existential relation). This is significant because:

- **ExistsTask**: `g_content M <= M'` - any MCS satisfying G-content works
- **CanonicalTask**: Integer-indexed chains via Succ - specific discrete construction

For ExistsTask, p-step is not a concern because each F/P-obligation gets its own independent witness MCS. The p-step issue is specific to the **integer-indexed CanonicalTask construction** where we build a single coherent chain.

## Alternative Approaches Considered

### Approach A: Restrict CanonicalTask_backward_MCS_P to Negative Indices

Only use `CanonicalTask_backward_MCS_P` for chains entirely within the backward region (negative indices). This would require:
- Reformulating `succ_chain_backward_P` to only work on backward chain elements
- Proving that P-coherence can be established without crossing into forward region

**Feasibility**: Low - P(phi) at position n requires a witness at some m < n, which could be in the forward region.

### Approach B: Split CanonicalTask Variants

Have two variants:
- `CanonicalTask_backward_MCS_P`: For chains with P-step (backward construction)
- `CanonicalTask_forward_MCS`: For chains without P-step (forward construction)

**Feasibility**: Medium - Would require significant restructuring and proving that the mixed approach still gives complete semantics.

### Approach C: Modified Successor Seed (User's Preferred Direction)

Investigate whether the successor seed can be modified to include past-related constraints that would guarantee p-step. The key challenge is:

1. **What P-formulas to constrain?** The successor seed is built BEFORE we know which P-formulas the Lindenbaum extension will add.

2. **Can we add constraints after the fact?** Perhaps by showing that any P(phi) added by Lindenbaum must satisfy p-step due to temporal axioms.

3. **Axiom-based reasoning**: The `temp_a: phi -> G(P(phi))` axiom relates forward movement to P-formulas. Can this be exploited?

**Feasibility**: Medium-High - This is the most promising direction for a clean solution within the CanonicalTask framework.

## Proposed New Tasks

### New Task 1: Research Modified Successor Seed for P-Step

Research how to modify the successor seed construction to satisfy p-step, focusing on the CanonicalTask relation. This is exploratory research to determine if a clean structural solution exists.

**Key Questions**:
1. Can `futureDeferralDisjunctionsForP` be defined that predicts which P-formulas will appear?
2. Can the axiom `temp_a: phi -> G(P(phi))` constrain which P-formulas appear in successors?
3. Is there a semantic argument that any P(phi) in a successor v must have phi or P(phi) in the predecessor u?

**Research Focus Areas**:
- SuccExistence.lean lines 50-120: Current successor seed definition
- WitnessSeed.lean: Temporal duality theorems (g_content_subset_implies_h_content_reverse)
- Axioms.lean: temp_a and past_temp_a usage
- CanonicalTaskRelation.lean: How CanonicalTask uses p-step

### New Task 2: Prove Forward Chain P-Step via Temporal Duality

Assuming research identifies a viable approach, implement the proof that forward chain pairs satisfy p-step. This may involve:

1. Proving that P-formulas in successors are constrained by temporal axioms
2. Adding helper lemmas to WitnessSeed.lean
3. Filling the sorry at SuccChainFMCS.lean:350

This task depends on Task 1 identifying a viable proof path.

## Dependency Reasoning

- **Task 2 depends on Task 1**: The implementation of forward chain p-step proof requires knowing which approach is viable. Task 1's research findings (whether a structural solution exists, or whether an axiom is required) directly determine how Task 2 should be implemented.

## After Completion

Once both tasks are complete, resume the parent task #40 with `/implement 40`.

The blocker will be resolved because: Either we will have a clean structural proof of p-step for forward chains (allowing removal of the sorry), or we will have a well-justified axiom that fills the gap while maintaining the CanonicalTask-focused design.

## Impact Assessment

The sorry at line 350 blocks:
- `succ_chain_canonicalTask_backward_MCS_P_from` when chains cross into forward region
- `succ_chain_backward_P` for positions in the forward chain
- `SuccChainTemporalCoherent` (the full temporal coherent family)

The `SuccChainFMCS` (without F/P coherence) is NOT blocked and can still be used for G/H-only reasoning.
