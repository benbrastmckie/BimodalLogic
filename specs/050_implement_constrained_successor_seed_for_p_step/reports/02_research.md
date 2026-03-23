# Research Report: Constrained Successor Seed for P-Step

**Task**: 50 - Implement constrained successor seed for P-step
**Date**: 2026-03-23
**Focus**: Verify mathematical correctness of P-step blocking formulas approach

## Executive Summary

The proposed approach for implementing P-step blocking formulas is **mathematically sound** and follows the exact symmetric pattern established by task 34's constrained predecessor seed. All proof obligations can be discharged using existing infrastructure in the codebase.

## Mathematical Verification

### 1. P-Step Blocking Formulas Definition

**Proposed definition**:
```lean
def p_step_blocking_formulas (u : Set Formula) : Set Formula :=
  {psi | exists phi : Formula, Formula.some_past phi not_in u and phi not_in u and
    psi = Formula.all_past (Formula.neg phi)}
```

In mathematical notation: `p_step_blocking_formulas(u) = {H(neg phi) | P(phi) not_in u and phi not_in u}`

### 2. Subset Proof: p_step_blocking_formulas(u) subseteq u

**Claim**: If u is an MCS, then `p_step_blocking_formulas(u) subseteq u`.

**Proof**:
Given `H(neg phi) in p_step_blocking_formulas(u)`, we have:
- `P(phi) not_in u` (by definition of the blocking set)

The key formula relationship is:
- `P(phi) = phi.neg.all_past.neg` (definition of some_past)
- `P(phi) = neg(H(neg(phi)))` (i.e., `neg(Formula.all_past (Formula.neg phi))`)

Since `P(phi) not_in u` and u is MCS:
1. By `SetMaximalConsistent.negation_complete`: `neg(P(phi)) in u`
2. `neg(P(phi)) = neg(neg(H(neg(phi))))` = double negation of `H(neg phi)`
3. By `SetMaximalConsistent.double_neg_elim`: `H(neg phi) in u`

**This is exactly symmetric to the F-step blocking proof at SuccExistence.lean:406-413.**

### 3. Constrained Successor Seed Definition

**Proposed definition**:
```lean
def constrained_successor_seed (u : Set Formula) : Set Formula :=
  g_content u union deferralDisjunctions u union p_step_blocking_formulas u
```

Equivalently: `g_content(u) union {phi or F(phi) | F(phi) in u} union {H(neg phi) | P(phi) not_in u and phi not_in u}`

### 4. Constrained Successor Seed Consistency

**Claim**: If u is an MCS with F(top) in u, then `constrained_successor_seed(u)` is consistent.

**Proof**:
The existing `successor_deferral_seed_consistent` proof shows:
- `g_content(u) subseteq u` (via T-axiom)
- `deferralDisjunctions(u) subseteq u` (via disjunction introduction derivation)

Adding p_step_blocking_formulas:
- `p_step_blocking_formulas(u) subseteq u` (proven above)

Therefore `constrained_successor_seed(u) subseteq u`. Since u is consistent (MCS), any subset is consistent.

### 5. Successor P-Step Theorem

**Claim**: For the successor `v = lindenbaumMCS(constrained_successor_seed(u))`, we have:
`p_content(v) subseteq u union p_content(u)`

**Proof** (by contradiction):
Assume `phi in p_content(v)` but `phi not_in u` and `P(phi) not_in u`.

Then by construction:
- `H(neg phi) in p_step_blocking_formulas(u)` (by definition)
- `H(neg phi) in constrained_successor_seed(u)` (subset)
- `H(neg phi) in v` (Lindenbaum extension preserves seed)

But `P(phi) in v` (since `phi in p_content(v)` means `P(phi) in v`).

Since `P(phi) = neg(H(neg phi))`:
- Both `H(neg phi)` and `neg(H(neg phi))` are in v
- This contradicts v being an MCS (consistency)

Therefore `phi in u` or `P(phi) in u`, i.e., `phi in u union p_content(u)`.

## Implementation Pattern

### Files to Modify

1. **SuccExistence.lean** - Add definitions and proofs:
   - `p_step_blocking_formulas` (definition)
   - `p_step_blocking_formulas_subset_u` (lemma)
   - `constrained_successor_seed` (definition)
   - `constrained_successor_seed_consistent` (theorem)
   - `successor_p_step` (theorem)
   - `constrained_successor_from_seed` (definition)
   - `constrained_successor_from_seed_mcs` (theorem)

2. **SuccChainFMCS.lean** - Update forward chain construction:
   - Modify `forward_chain` to use constrained seed
   - Update `succ_chain_fam_p_step` to use `successor_p_step`

### Proof Template (from task 34)

The proof structure follows `predecessor_f_step` at SuccExistence.lean:630-661:

```lean
theorem successor_p_step
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) in u) :
    p_content (constrained_successor_from_seed u h_mcs h_F_top) subseteq u union p_content u := by
  intro phi h_phi_in_p_content
  by_cases h_phi_in_u : phi in u
  . exact Set.mem_union_left _ h_phi_in_u
  . by_cases h_P_phi_in_u : Formula.some_past phi in u
    . exact Set.mem_union_right _ h_P_phi_in_u
    . -- Contradiction case: H(neg phi) in seed, P(phi) in successor
      have h_block : Formula.all_past (Formula.neg phi) in p_step_blocking_formulas u :=
        ⟨phi, h_P_phi_in_u, h_phi_in_u, rfl⟩
      -- ... (see predecessor_f_step for exact pattern)
      sorry
```

## Key Lemmas Required

| Lemma | Exists | Location |
|-------|--------|----------|
| `SetMaximalConsistent.negation_complete` | Yes | MCSProperties.lean |
| `SetMaximalConsistent.double_neg_elim` | Yes | TemporalCoherence.lean |
| `set_consistent_not_both` | Yes | Used in predecessor_f_step |
| `theorem_in_mcs` | Yes | MCSProperties.lean |
| `lindenbaumMCS_set_extends` | Yes | Completeness.lean |
| `lindenbaumMCS_set_is_mcs` | Yes | Completeness.lean |

All required infrastructure exists. No new lemmas need to be proven.

## Verification Checklist

- [x] Mathematical claim `p_step_blocking_formulas(u) subseteq u` is valid
- [x] Consistency proof follows existing pattern
- [x] P-step proof follows symmetric pattern to F-step
- [x] All required lemmas exist in codebase
- [x] No new axioms required (zero-debt compliant)

## Recommended Implementation Order

1. Define `p_step_blocking_formulas` (5 lines)
2. Prove `p_step_blocking_formulas_subset_u` (follow lines 406-413)
3. Define `constrained_successor_seed` (union of three sets)
4. Prove `constrained_successor_seed_consistent` (follow existing pattern)
5. Define `constrained_successor_from_seed` (Lindenbaum construction)
6. Prove `successor_p_step` (follow lines 630-661)
7. Update `forward_chain` to use constrained construction
8. Fill sorry in `succ_chain_fam_p_step` using `successor_p_step`

## Risk Assessment

**Low Risk**: This is a symmetric implementation to task 34's constrained predecessor seed. All proof techniques transfer directly. The mathematical argument is sound and follows established patterns.

**Potential Complications**:
- The forward_chain definition may need careful updating to thread through the new construction
- May need to verify that existing forward_chain properties still hold with constrained seed

## References

- Task 34: Constrained predecessor seed implementation (completed)
- SuccExistence.lean lines 162-176: f_step_blocking_formulas definition
- SuccExistence.lean lines 406-413: f_step_blocking_formulas subset proof
- SuccExistence.lean lines 630-661: predecessor_f_step proof (template)
- spawn-analysis.md: Original proposal for this approach
