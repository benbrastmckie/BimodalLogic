# Blocker Analysis: Task #46

**Parent Task**: #46 - prove_forward_chain_p_step
**Generated**: 2026-03-23
**Blocker**: Forward chain P-step cannot be proven because successor_deferral_seed lacks P-step blocking formulas

## Root Cause

The forward chain construction uses `successor_deferral_seed`:
```
successor_deferral_seed(u) = g_content(u) ∪ deferralDisjunctions(u)
```

This seed ensures:
- **G-persistence**: `g_content(u) ⊆ v` (G-formulas propagate forward)
- **F-step**: `f_content(u) ⊆ v ∪ f_content(v)` (F-obligations either resolve or defer)

But there is NO mechanism ensuring:
- **P-step**: `p_content(v) ⊆ u ∪ p_content(u)` (P-formulas should trace back to predecessors)

### Counter-Example Scenario

A valid configuration where P-step fails:
1. Let `u` have `H(¬φ) ∈ u` (so `P(φ) ∉ u` and `φ ∉ u` by temp_t_past)
2. The successor `v = lindenbaumMCS(successor_deferral_seed(u))` can have `φ ∈ v` (not blocked)
3. Then `P(φ) ∈ v` (by reflexive P-introduction)
4. But `φ ∉ u` and `P(φ) ∉ u` - P-step is violated

The Lindenbaum extension is free to add `φ` because `H(¬φ)` is not in `g_content(u)` (that would require `G(H(¬φ)) ∈ u`).

### Why Task 34's Solution is the Template

Task 34 faced the symmetric problem: the predecessor seed lacked F-step guarantees. The solution was to add **F-step blocking formulas**:
```
f_step_blocking_formulas(u) = {G(¬φ) | F(φ) ∉ u ∧ φ ∉ u}
```

This works because:
1. Every blocking formula `G(¬φ)` is already in `u` (since `F(φ) ∉ u ⟹ ¬F(φ) ∈ u ⟹ G(¬φ) ∈ u`)
2. Having `G(¬φ)` in the seed prevents `F(φ)` from appearing in the MCS extension
3. Therefore `constrained_predecessor_seed(u) ⊆ u` and F-step is guaranteed

The symmetric solution for forward chains is **P-step blocking formulas**:
```
p_step_blocking_formulas(u) = {H(¬φ) | P(φ) ∉ u ∧ φ ∉ u}
```

## Proposed New Tasks

### New Task 1: Implement Constrained Successor Seed for P-Step
- **Effort**: 3-4 hours
- **Language**: lean4
- **Rationale**: This is the foundational task that modifies the forward chain construction to guarantee P-step. Without this, task 46 cannot be completed.
- **Depends on**: None

**Implementation Details**:
1. Define `p_step_blocking_formulas(u) = {H(¬φ) | P(φ) ∉ u ∧ φ ∉ u}` in SuccExistence.lean
2. Define `constrained_successor_seed(u) = g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas(u)`
3. Prove `p_step_blocking_formulas(u) ⊆ u` using the reasoning:
   - `P(φ) ∉ u ⟹ ¬P(φ) ∈ u` (MCS completeness)
   - `¬P(φ) = ¬¬H(¬φ) = H(¬φ)` (by definition and double negation)
4. Prove `constrained_successor_seed_consistent` using the subset-implies-consistent pattern
5. Prove `successor_p_step` as a theorem (not axiom)
6. Update `forward_chain` construction to use constrained seed

**Key Insight**: This is the exact symmetric approach to task 34's constrained predecessor seed. All proof patterns transfer directly.

### New Task 2: Fill forward_chain P-step sorry using constrained successor seed
- **Effort**: 1-2 hours
- **Language**: lean4
- **Rationale**: Once Task 1 provides the constrained successor seed with P-step guarantees, this task uses that infrastructure to fill the sorry at SuccChainFMCS.lean:350.
- **Depends on**: New Task 1, because the P-step proof requires the `successor_p_step` theorem that Task 1 provides, and the forward chain must be using the constrained seed construction

**Implementation Details**:
1. Update `forward_chain` definition (if not done in Task 1) to use constrained successor seed
2. Prove that forward_chain pairs satisfy Succ with P-step using `successor_p_step`
3. Fill the sorry at SuccChainFMCS.lean:350
4. Verify `succ_chain_fam_p_step` compiles without sorries
5. Verify `succ_chain_backward_P` compiles

## Dependency Reasoning

- **Task 2 depends on Task 1**: The P-step proof at SuccChainFMCS.lean:350 requires the `successor_p_step` theorem. This theorem can only exist after Task 1 implements the constrained successor seed construction with P-step blocking formulas. Specifically, Task 1's implementation choices (the exact definition of the blocking set, the proof structure for subset-implies-consistent) directly affect how Task 2 proves the P-step property.

## After Completion

Once all spawned tasks are complete, the parent task #46 will be resolved because:
1. Task 1 provides the foundational `successor_p_step` theorem guaranteeing P-step for any successor built from the constrained seed
2. Task 2 applies this theorem to the forward chain construction, filling the sorry

The blocker will be resolved because the forward chain will use a constrained successor seed that mathematically guarantees P-step by construction, just as task 34's constrained predecessor seed guarantees F-step.

## Alternative Approaches Considered

### Option 1: Add Past Analog of temp_a Axiom
Adding `φ → H(F(φ))` would provide P-step mechanism semantically. **Rejected** because:
- Project constraints prohibit new axioms
- Would be a logical extension rather than construction fix

### Option 2: Use Full CanonicalMCS Domain
Using `canonicalMCS_backward_P` with the full CanonicalMCS frame. **Rejected** because:
- Loses the discrete Int-indexed chain structure
- More disruptive change to overall architecture
- Constrained seed approach is cleaner and maintains existing structure

### Option 3: Constrained Successor Seed (CHOSEN)
This option is preferred because:
- Symmetric to task 34's successful approach
- No new axioms required
- Maintains existing chain construction patterns
- All proof techniques transfer from task 34
