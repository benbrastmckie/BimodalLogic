# Teammate C Findings: Architectural Alternatives

**Task**: 34 - prove_succ_seed_consistency_axioms
**Focus**: Explore whether `predecessor_f_step` can be eliminated through architectural changes
**Date**: 2026-03-23
**HARD CONSTRAINT**: No axioms, no sorries. Must find a complete proof path.

---

## Executive Summary

The `predecessor_f_step_axiom` is used in a specific dependency chain:
```
predecessor_f_step_axiom -> predecessor_succ -> backward_chain_pred -> succ_chain_fam_succ -> SuccChainFMCS -> truth lemma
```

After analyzing four architectural alternatives, I find:

1. **Direct Witness Construction** - NOT VIABLE (same fundamental gap)
2. **Filtration/Finite Model Property** - PARTIALLY VIABLE (major refactor, doesn't eliminate axiom)
3. **Bidirectional Construction** - MOST PROMISING (moderate effort, eliminates asymmetry)
4. **Weaken Succ Definition** - NOT VIABLE (breaks truth lemma)

**Recommendation**: Pursue **Alternative 3 (Bidirectional Construction)** combined with insights from the existing `f_nesting_boundary` infrastructure.

---

## Alternative 1: Direct Witness Construction

### Concept

Instead of constructing predecessor via generic Lindenbaum extension and proving it satisfies F-step, directly construct a witness for F(phi) when needed in the truth lemma.

**Proposed Definition**:
```lean
def predecessor_for_F_witness (u : Set Formula) (phi : Formula)
    (h_mcs : SetMaximalConsistent u) (h_P_top : P_top ∈ u)
    (h_F_phi_constraint : phi ∈ u ∨ F(phi) ∈ u) : Set Formula :=
  -- Build MCS containing phi that serves as predecessor
  lindenbaumMCS_set ({phi} ∪ h_content u ∪ pastDeferralDisjunctions u) (...)
```

### Analysis

**The Problem**: This approach doesn't avoid the fundamental issue. We still need to prove:
1. The seed `{phi} ∪ h_content(u) ∪ pastDeferralDisjunctions(u)` is consistent
2. The Lindenbaum extension satisfies g_persistence: `g_content(predecessor) ⊆ u`
3. The Lindenbaum extension satisfies f_step: `f_content(predecessor) ⊆ u ∪ f_content(u)`

Point 3 is exactly the same gap we have now. Adding `{phi}` to the seed doesn't constrain what OTHER F-formulas enter via maximality.

**Attempted Proof**:
```lean
-- Suppose F(psi) ∈ predecessor for some psi
-- We need: psi ∈ u ∨ F(psi) ∈ u
-- But F(psi) could have entered via negation completeness:
--   If G(neg(psi)) is inconsistent with seed, then neg(G(neg(psi))) = F(psi) enters
-- The seed doesn't block arbitrary G(neg(psi)) from being inconsistent
```

**Verdict**: NOT VIABLE - Same fundamental gap remains.

---

## Alternative 2: Filtration/Finite Model Property

### Concept

Use the finite model property to avoid infinite chain construction. For a target formula phi, construct a finite model over subformulas(phi) where F-step issues don't arise because the model is bounded.

### Current Codebase Support

Examining the codebase:
- `Theories/Bimodal/Syntax/Subformulas.lean` - Defines subformula closure
- `Theories/Bimodal/Semantics/TaskFrame.lean:262-282` - Finite task frame infrastructure
- `Boneyard/FMP_Bridge/` - Partial finite model property work (incomplete)

**Key observation from `TaskFrame.lean`**:
```lean
abbrev FiniteTaskModel {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : FiniteTaskFrame D) := TaskModel F.toTaskFrame
```

### Filtration Approach

Standard filtration for modal logic:
1. Define equivalence on worlds: `w ~ w' iff forall phi in subformulas(target), phi in w <-> phi in w'`
2. Quotient the canonical model by this equivalence
3. Prove the filtration preserves truth for subformulas

**For Temporal Logic Filtration**:
- Need to ensure the quotient preserves Succ structure
- F-step condition becomes: for each equivalence class, F-obligations resolve within the finite chain

### Analysis

**Potential Benefits**:
- Finite model means finite chain means no infinite regression
- F-step might be trivially satisfied by construction bounds

**Critical Problems**:

1. **Time Domain Issue**: The current construction uses `Int` as time domain. Filtration would need bounded time `Fin n` for some n.

2. **Succ Preservation**: The Succ relation depends on g_content and f_content, which involve arbitrary formulas, not just subformulas. The quotient may not preserve Succ.

3. **Completeness vs FMP**: Filtration proves *finite model property* (every satisfiable formula has a finite model). We need *completeness* (every consistent formula is satisfiable). These are related but not identical.

4. **Major Refactor**: Would require:
   - New `FiniteSuccChain` construction
   - New truth lemma for finite models
   - Bridge between finite and infinite constructions
   - Significant new infrastructure

**Verdict**: PARTIALLY VIABLE - Could work but requires major architectural changes and doesn't directly eliminate the axiom; it sidesteps it by using a different proof strategy.

---

## Alternative 3: Bidirectional Construction

### Concept

Instead of building forward chain (successors) and backward chain (predecessors) separately, build both directions simultaneously from the base MCS M0. This maintains F-step invariants at each step.

### Key Insight

The current asymmetry:
- **Successor construction**: Seed includes `deferralDisjunctions` which GUARANTEE F-step by construction
- **Predecessor construction**: Seed includes `pastDeferralDisjunctions` which guarantee P-step but NOT F-step

The fix: Make predecessor seed also include F-content constraints from the successor direction.

### Proposed Construction

**Bidirectional Seed for Predecessor**:
```lean
def bidirectional_predecessor_seed (u : Set Formula) (future_constraints : Set Formula) : Set Formula :=
  h_content u ∪
  pastDeferralDisjunctions u ∪
  {G(neg(phi)) | F(phi) ∉ u ∧ F(phi) ∉ future_constraints}
```

The `future_constraints` parameter carries information about what F-formulas are "allowed" based on the already-constructed successor chain.

**Construction Algorithm**:
```
BidirectionalChain(M0, n):
  if n >= 0:
    // Forward direction - unchanged
    return successor_from_deferral_seed(BidirectionalChain(M0, n-1))
  else:
    // Backward direction - use bidirectional seed
    let future = f_content(BidirectionalChain(M0, n+1)) ∪ (BidirectionalChain(M0, n+1))
    return lindenbaumMCS_set(bidirectional_predecessor_seed(BidirectionalChain(M0, n+1), future))
```

### Why This Could Work

**The Key Property**:
```lean
-- For any phi, if F(phi) ∈ predecessor, then:
-- EITHER: G(neg(phi)) was blocked from seed (because phi ∈ successor OR F(phi) ∈ successor)
-- OR: G(neg(phi)) was in seed but F(phi) entered anyway (contradiction - G(neg(phi)) blocks F(phi))
```

The bidirectional seed explicitly blocks F-formulas that would violate F-step by including their G-negations.

### Consistency Proof Sketch

Need to show `bidirectional_predecessor_seed(u, future)` is consistent when u is MCS with P_top.

**Argument**:
1. `h_content(u) ⊆ u` by T-axiom (current proof works)
2. `pastDeferralDisjunctions(u) ⊆ u` by right disjunction intro (current proof works)
3. For each `G(neg(phi))` added:
   - `F(phi) ∉ u` means `neg(F(phi)) = G(neg(phi)) ∈ u` by MCS negation completeness
   - So `G(neg(phi)) ∈ u`
4. Combined: `bidirectional_predecessor_seed(u, future) ⊆ u`
5. Since u is consistent, the seed is consistent

**Critical Check**: Does condition 3 work?
- `F(phi) ∉ u` by MCS completeness means `neg(F(phi)) ∈ u`
- `neg(F(phi)) = neg(neg(G(neg(phi)))) = G(neg(phi)).neg.neg`
- By double negation elimination (valid in classical logic): `G(neg(phi)) ∈ u`

YES! This is derivable.

### F-Step Proof Sketch

Need to show: `f_content(predecessor) ⊆ u ∪ f_content(u)`

**Argument by Contradiction**:
1. Suppose F(phi) ∈ predecessor but phi ∉ u and F(phi) ∉ u
2. Since F(phi) ∉ u, we have G(neg(phi)) ∈ seed by construction
3. Since predecessor extends seed, G(neg(phi)) ∈ predecessor
4. But F(phi) = neg(G(neg(phi))), so both G(neg(phi)) and neg(G(neg(phi))) in predecessor
5. Contradiction with predecessor being consistent (MCS)

This WORKS!

### Implementation Complexity

**Changes Required**:
1. Define `bidirectional_predecessor_seed` with future constraints parameter
2. Modify `backward_chain` construction to pass constraints
3. Prove new consistency lemma
4. Prove F-step follows from seed construction
5. Update `SuccChainFMCS` to use bidirectional construction

**Estimated Effort**: Medium (200-400 lines of new/modified Lean code)

**Verdict**: MOST PROMISING - Eliminates the axiom through a principled architectural change.

---

## Alternative 4: Weaken the Succ Definition

### Concept

Modify the Succ definition to not require the full F-step property.

**Current Definition**:
```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

**Weakened Definition**:
```lean
def WeakSucc (u v : Set Formula) : Prop :=
  g_content u ⊆ v
  -- Drop F-step requirement
```

### Analysis

**Why This Fails**:

The F-step condition is essential for the truth lemma. The proof of `succ_chain_forward_F` relies on:

1. `single_step_forcing` (line 233-269 of SuccRelation.lean):
   - Uses F-step to show: if F(phi) ∈ u and FF(phi) ∉ u and Succ(u,v), then phi ∈ v
   - Without F-step, we cannot conclude phi ∈ v (it could be deferred indefinitely)

2. `bounded_witness` (line 651-679 of CanonicalTaskRelation.lean):
   - Relies on `single_step_forcing` recursively
   - Without F-step, the induction breaks

**Attempted Workaround**: Use `f_nesting_boundary` to guarantee eventual resolution.

But `f_nesting_boundary` only guarantees that *some* nesting depth is bounded; it doesn't tell us which successor has the witness. We still need the F-step property to propagate through the chain.

**Verdict**: NOT VIABLE - F-step is load-bearing for the truth lemma.

---

## What the Truth Lemma Actually Needs

Looking at `SuccChainTruth.lean`, the truth lemma case for `all_future` (G operator) works because:
```lean
-- Forward: G psi in MCS -> forall s >= t, truth tau s psi
-- Uses succ_chain_forward_G_le which propagates through Succ.g_persistence
```

The truth lemma case for existential `some_future` (F = neg G neg) works because:
```lean
-- succ_chain_forward_F guarantees a witness exists
-- This relies on f_nesting_boundary + bounded_witness
-- Which in turn relies on single_step_forcing
-- Which requires F-step
```

**Critical Path**:
```
F(phi) in mcs(n)
  -> f_nesting_boundary gives d with F^d(phi) in mcs(n), F^{d+1}(phi) not in mcs(n)
  -> bounded_witness gives phi in mcs(n+d)
  -> truth_at ... phi holds at time n+d
```

The `bounded_witness` theorem explicitly requires Succ connections with F-step property.

---

## Ranked Recommendations

### Tier 1: Most Promising (Pursue First)

**Alternative 3: Bidirectional Construction**

- **Viability**: HIGH
- **Effort**: MEDIUM (200-400 lines)
- **Risk**: LOW (principled construction, proof sketch is complete)
- **Benefit**: Eliminates axiom entirely through architectural change

**Implementation Plan**:
1. Define `bidirectional_predecessor_seed` with explicit G-blocking
2. Prove consistency using the "seed ⊆ u" argument
3. Prove F-step directly from seed construction
4. Update backward_chain to use new construction
5. Verify truth lemma still works

### Tier 2: Viable but Major Effort

**Alternative 2: Filtration/Finite Model Property**

- **Viability**: MEDIUM
- **Effort**: HIGH (significant architectural change)
- **Risk**: MEDIUM (may uncover other issues)
- **Benefit**: Sidesteps axiom, provides finite model property as bonus

Only pursue if Alternative 3 encounters unexpected obstacles.

### Tier 3: Not Viable

**Alternative 1: Direct Witness Construction** - Same fundamental gap
**Alternative 4: Weaken Succ Definition** - Breaks truth lemma

---

## Confidence Assessment

| Alternative | Viability | Confidence | Key Factor |
|-------------|-----------|------------|------------|
| Direct Witness | Low | HIGH | Same syntactic gap |
| Filtration | Medium | MEDIUM | Requires major refactor |
| Bidirectional | High | HIGH | Proof sketch is complete |
| Weaken Succ | None | HIGH | Breaks truth lemma |

**Overall Recommendation**: Implement Alternative 3 (Bidirectional Construction). The proof sketch for F-step is complete and the construction is principled. This eliminates the axiom through proper architectural design rather than workaround.

---

## Appendix: Key Files to Modify

For Alternative 3 implementation:

| File | Changes |
|------|---------|
| `SuccExistence.lean` | Add `bidirectional_predecessor_seed`, new consistency proof, direct F-step proof |
| `SuccChainFMCS.lean` | Modify `BackwardChainElement.prev` to use bidirectional seed |
| `SuccChainTruth.lean` | Should work unchanged (same Succ interface) |

**New Definitions Required**:
```lean
def bidirectional_predecessor_seed (u : Set Formula) (future_constraints : Set Formula) : Set Formula
def bidirectional_predecessor_seed_consistent (u : Set Formula) (h_mcs : SetMaximalConsistent u) ...
theorem bidirectional_predecessor_f_step (u : Set Formula) ... -- Direct proof, no axiom
```

**Removed**:
```lean
axiom predecessor_f_step_axiom  -- Eliminated by construction
```
