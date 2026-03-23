# Research Report: Task #34 - Axiom-Free Solutions for predecessor_f_step_axiom

**Task**: Prove SuccExistence seed consistency axioms
**Date**: 2026-03-23
**Mode**: Team Research (3 teammates, round 2)
**Constraint**: NO axioms, NO sorries — must find complete proof path

## Summary

Three agents investigated axiom-free solutions under the hard constraint that axioms and sorries are unacceptable. The critical finding is a **Constrained Predecessor Seed** construction that eliminates `predecessor_f_step_axiom` through principled seed design, with a **complete proof sketch** showing both consistency and F-step.

## Key Results

| Approach | Viable? | Source | Confidence |
|----------|---------|--------|------------|
| Alternative 3B (nesting boundary bypass) | **NO** | Teammate A | HIGH |
| Constrained Lindenbaum (generic) | Complex, 40-120 hrs | Teammate B | MEDIUM |
| **Constrained Predecessor Seed** | **YES** | Teammate C | **HIGH** |
| Direct witness construction | NO | Teammate C | HIGH |
| Filtration/FMP | Partial, major refactor | Teammate C | MEDIUM |
| Weaken Succ definition | NO | Teammate C | HIGH |

## The Winning Approach: Constrained Predecessor Seed

### Core Idea

Add **G-blocking formulas** to the predecessor seed that explicitly prevent "bad" F-formulas from entering the Lindenbaum extension:

```lean
def constrained_predecessor_seed (u : Set Formula) : Set Formula :=
  h_content u ∪
  pastDeferralDisjunctions u ∪
  {G(¬φ) | φ : Formula, F(φ) ∉ u ∧ φ ∉ u}
```

For every formula φ where BOTH `φ ∉ u` AND `F(φ) ∉ u`, we add `G(¬φ)` to the seed. This blocks `F(φ)` from entering the Lindenbaum extension (since `F(φ) = ¬G(¬φ)` would contradict `G(¬φ)`).

### Consistency Proof (Complete)

**Theorem**: `constrained_predecessor_seed(u)` is consistent when `u` is an MCS with `P(⊤) ∈ u`.

**Proof**:
1. `h_content(u) ⊆ u` — by T-axiom: `H(ψ) → ψ`, so `H(ψ) ∈ u ⟹ ψ ∈ u`
2. `pastDeferralDisjunctions(u) ⊆ u` — for each `P(φ) ∈ u`, `φ ∨ P(φ) ∈ u` by right disjunction
3. For each blocking formula `G(¬φ)` where `F(φ) ∉ u ∧ φ ∉ u`:
   - `F(φ) ∉ u` ⟹ `¬F(φ) ∈ u` (MCS negation completeness)
   - `¬F(φ) = ¬¬G(¬φ)` (by definition: `F(φ) = ¬G(¬φ)`)
   - `¬¬G(¬φ) ∈ u` ⟹ `G(¬φ) ∈ u` (MCS double negation elimination)
4. **Therefore**: `constrained_predecessor_seed(u) ⊆ u`
5. Since `u` is consistent (MCS), any subset of `u` is consistent. ∎

### F-Step Proof (Complete)

**Theorem**: If `v = lindenbaumMCS_set(constrained_predecessor_seed(u), ...)`, then `f_content(v) ⊆ u ∪ f_content(u)`.

**Proof** (by contradiction):
1. Suppose `F(φ) ∈ v` but `φ ∉ u` and `F(φ) ∉ u`
2. Since `φ ∉ u` and `F(φ) ∉ u`, we have `G(¬φ) ∈ constrained_predecessor_seed(u)` by construction
3. Since `v` extends the seed: `G(¬φ) ∈ v`
4. But `F(φ) = ¬G(¬φ)`, so both `G(¬φ)` and `¬G(¬φ)` are in `v`
5. This contradicts `v` being consistent (MCS). ∎

### Why This Works Where Others Failed

The key insight is that the blocking formulas `G(¬φ)` are **already in `u`** (step 3 of consistency proof). We're not adding "foreign" formulas — we're adding formulas that `u` already contains. This is why:

- **Teammate B's concern about infinite sets** is addressed: yes the blocking set is infinite, but it's a subset of `u`, so consistency is trivial
- **Teammate B's concern about seed conflicts** is addressed: no conflicts because the seed is a subset of `u`
- The construction is semantically natural: we're telling the Lindenbaum process "respect the successor's temporal structure"

## Alternative 3B: Definitively Ruled Out

Teammate A provided a rigorous trace through the dependency chain:

```
truth lemma → temporal_backward_G → forward_F → succ_chain_forward_F_neg
  → succ_chain_canonicalTask_forward_MCS_from → succ_chain_fam_succ
    → backward_chain_pred → predecessor_succ → predecessor_f_step_axiom
```

The `bounded_witness` theorem requires building a chain of `CanonicalTask_forward_MCS` steps, each requiring `Succ` with F-step. The nesting boundary tells us WHERE the witness is, but `single_step_forcing` needs F-step to PROPAGATE the witness through each link.

**Conclusion**: The truth lemma fundamentally needs local F-step at each chain link. No bypass is possible without changing the proof architecture.

## Conflicts Resolved

**Conflict: Teammate B says constrained seed fails; Teammate C says it works.**

Resolution: Teammate C's analysis is correct. Teammate B identified real concerns (infinite set, potential conflicts) but didn't notice that the blocking formulas are already in `u`, making the consistency proof trivial. The key observation is:

> `F(φ) ∉ u` ⟹ `G(¬φ) ∈ u` (via MCS completeness + double negation)

This means `constrained_predecessor_seed(u) ⊆ u`, immediately giving consistency.

## Implementation Plan

### Required Changes

| File | Changes | Lines Est. |
|------|---------|-----------|
| `SuccExistence.lean` | Add `constrained_predecessor_seed` def, consistency proof, F-step theorem | 80-120 |
| `SuccExistence.lean` | Remove `predecessor_f_step_axiom` | -5 |
| `SuccExistence.lean` | Update `predecessor_from_deferral_seed` to use new seed | 10-20 |

### Key Theorems to Prove

```lean
-- 1. Define the constrained seed
def constrained_predecessor_seed (u : Set Formula) : Set Formula :=
  h_content u ∪ pastDeferralDisjunctions u ∪
  {Formula.all_future (Formula.neg φ) | φ : Formula,
    Formula.some_future φ ∉ u ∧ φ ∉ u}

-- 2. Prove seed ⊆ u (key insight)
theorem constrained_predecessor_seed_subset_u
    (u : Set Formula) (h_mcs : SetMaximalConsistent u) :
    constrained_predecessor_seed u ⊆ u

-- 3. Prove consistency (follows from subset)
theorem constrained_predecessor_seed_consistent
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (constrained_predecessor_seed u)

-- 4. Prove F-step (by contradiction)
theorem constrained_predecessor_f_step
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    f_content (lindenbaumMCS_set (constrained_predecessor_seed u) ...) ⊆ u ∪ f_content u
```

### Estimated Effort

- **Implementation**: 4-8 hours (modify SuccExistence.lean)
- **Verification**: 1-2 hours (lake build, lean_verify)
- **Total**: 5-10 hours

### Symmetric Application

The same approach applies to `successor_p_step_axiom` (Task 40):
```lean
def constrained_successor_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪
  {H(¬φ) | φ : Formula, P(φ) ∉ u ∧ φ ∉ u}
```

## Teammate Contributions

| Teammate | Angle | Status | Key Finding |
|----------|-------|--------|-------------|
| A | Nesting boundary bypass | completed | Alt 3B NOT viable — traced full dependency chain |
| B | Constrained Lindenbaum | completed | Approaches feasible but complex (40-120 hrs) |
| C | Architectural alternatives | completed | **Bidirectional/constrained seed WORKS** — complete proof sketch |

## Recommendation

**Implement the Constrained Predecessor Seed construction.** The proof sketch is complete, the approach is principled, and it eliminates the axiom entirely. This is the mathematically correct solution: instead of hoping Lindenbaum "does the right thing" and axiomatizing the result, we tell Lindenbaum what to do by including the right formulas in the seed.

**Priority**: This should be the next implementation attempt for task 34 Phase 4.
