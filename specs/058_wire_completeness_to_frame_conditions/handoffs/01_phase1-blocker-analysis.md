# Phase 1 Blocker Analysis: Seed Consistency

## Summary

Deep analysis of `constrained_successor_seed_restricted_consistent` (SuccChainFMCS.lean:1543) reveals a fundamental issue: the theorem may be **unprovable** with the current definition of `boundary_resolution_set`.

## Problem Statement

The theorem claims:
```lean
theorem constrained_successor_seed_restricted_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.bot.neg.some_future ∈ u) :
    SetConsistent (constrained_successor_seed_restricted phi u)
```

The seed is:
```
constrained_successor_seed_restricted phi u =
  g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u) ∪ boundary_resolution_set(phi, u)
```

## The Fundamental Issue

### boundary_resolution_set Definition

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula)}
```

For chi ∈ BRS:
1. F(chi) ∈ u
2. FF(chi) ∉ deferralClosure(phi)

### Why Consistency Fails

**Key Observation**: Both chi AND neg(chi) can be in boundary_resolution_set simultaneously!

For chi ∈ BRS: F(chi) ∈ u and FF(chi) ∉ deferralClosure
For neg(chi) ∈ BRS: F(neg(chi)) ∈ u and FF(neg(chi)) ∉ deferralClosure

These conditions are **independent**. In temporal logic:
- F(chi) ∈ u means "eventually chi" holds
- F(neg(chi)) ∈ u means "eventually not-chi" holds
- Both can be true simultaneously (chi true at t', false at t'')

Since neg(chi) = chi.imp bot is syntactically different from chi, the F-depth conditions FF(chi) ∉ deferralClosure and FF(neg(chi)) ∉ deferralClosure are also independent.

**Result**: The seed can contain both chi and neg(chi), making it **inconsistent**.

### Why Helper Lemmas Don't Help

The existing lemmas prove neg(chi) is NOT in:
- g_content(u) - PROVEN (neg_not_in_g_content_when_F_in)
- deferralDisjunctions(u) - PROVEN (structural: neg is imp, disj is or)
- p_step_blocking_formulas_restricted - PROVEN (structural: neg is imp, blocking is all_past)

But `neg_not_in_boundary_resolution_set` has a **sorry** and is **unprovable** in general because F(chi) ∈ u does NOT imply F(neg(chi)) ∉ u.

## Analysis of the Plan's Proof Sketch

The plan (lines 104-111) suggests:
> For each chi ∈ L_brs, by deduction: L_u ∪ (L_brs \ {chi}) ⊢ chi → ⊥ = ¬chi.
> Combined with chi ∨ F(chi) ∈ u, we get F(chi) derivable from u-elements.

**Issue**: This argument replaces chi with F(chi), but:
1. F(chi) doesn't give a contradiction
2. After replacing all BRS elements, we have {F(chi1), F(chi2), ...} ∪ L_u
3. This set doesn't necessarily derive ⊥

The proof sketch is **flawed**.

## Impact Assessment

### What Works (Sorry-Free)
- `construct_bfmcs_bundle` - builds BFMCS_Bundle from any MCS
- `bundle_completeness_contradiction` - algebraic completeness
- `SuccChainFMCS` - unrestricted chain from full MCS
- `shifted_truth_lemma` - truth lemma for BFMCS with family-level coherence

### What's Blocked
- `constrained_successor_seed_restricted_consistent` - may be FALSE
- `restricted_forward_chain` and downstream - depends on above
- `RestrictedTemporallyCoherentFamily` - depends on above
- `bundle_validity_implies_provability` - needs model-theoretic glue

### The Real Gap

The existing infrastructure has:
- **Algebraic completeness**: NOT provable implies NOT in all MCSes
- **Bundle-level coherence**: F-witnesses exist in SOME family

But needs:
- **Semantic completeness**: valid_over Int implies provable
- **Family-level coherence**: F-witnesses in SAME family (for truth lemma)

The restricted construction was meant to provide family-level coherence, but its foundation (seed consistency) is flawed.

## Recommended Path Forward

### Option 1: Fix boundary_resolution_set Definition

Add constraint: chi ∈ BRS only if neg(chi) ∉ BRS

This requires: either chi ∉ BRS or neg(chi) ∉ BRS (mutual exclusion).

Implementation: Add condition `chi.neg.some_future ∉ u` or `chi.neg.some_future.some_future ∈ deferralClosure`.

### Option 2: Use Different Consistency Argument

Instead of negation exclusion, prove consistency via:
- Model-theoretic argument: show the seed has a model
- Direct syntactic argument specific to TM logic

### Option 3: Alternative Completeness Path

Bypass restricted construction entirely:
1. Accept bundle-level coherence
2. Define "bundle-level validity" where F-witnesses can be in different families
3. Prove completeness for bundle-level validity
4. Show standard validity implies bundle-level validity

### Option 4: Accept Partial Result

Document that:
- Algebraic completeness is proven (NOT provable → countermodel exists)
- Semantic connection (valid_over → provable) has gap
- Gap is in model-theoretic glue, not algebraic core

## Files Modified

None (analysis only)

## Files Examined

- SuccChainFMCS.lean: Lines 1412-1543 (helper lemmas and main sorry)
- SuccExistence.lean: Lines 284-293 (boundary_resolution_set definition)
- CanonicalConstruction.lean: Lines 650+ (shifted_truth_lemma)
- UltrafilterChain.lean: Lines 2758-2877 (BFMCS_Bundle, construct_bfmcs_bundle)
- Completeness.lean: Lines 186-214 (bundle_validity_implies_provability)

## Session Info

- Session ID: sess_1774626770_4fbb21
- Agent: lean-implementation-agent
- Date: 2026-03-27
