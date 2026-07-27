# LeanSearch Results: Proof Caching and Memoization

**Query**: "proof caching memoization"  
**Date**: Sun Dec 21 2025  
**Results Found**: 10  
**Library Coverage**: Mathlib  

## Executive Summary

This search identified 10 highly relevant definitions and functions in Mathlib related to proof caching, memoization, and computation reuse. The results span multiple domains:

1. **Core Memoization Primitives**: General-purpose memoization with pointer hashing
2. **Tactic-Level Caching**: Multiple tactics implement sophisticated caching strategies
3. **Dual Caching Strategy**: Both successful results and failures are cached
4. **Metaprogramming Patterns**: MonadCacheT pattern is widely used for stateful caching

## Top Results

### 1. memoFix (Relevance: 0.049)
- **Type**: Opaque definition
- **Library**: Mathlib
- **Signature**: `{α : Type u} → {β : Type v} → [Nonempty β] → ((α → β) → α → β) → α → β`
- **Description**: Takes the fixpoint of f with caching of values using pointer hash. Useful for tree traversal with shared subtrees.
- **Use Case**: General-purpose memoization primitive for recursive computations

### 2. Mathlib.Meta.FunProp.cacheResult (Relevance: 0.035)
- **Type**: Definition
- **Library**: Mathlib
- **Signature**: `Lean.Expr → Mathlib.Meta.FunProp.Result → Mathlib.Meta.FunProp.FunPropM Mathlib.Meta.FunProp.Result`
- **Description**: Cache result if it does not have any subgoals. Stores successful proof results in the FunProp tactic cache.
- **Use Case**: Proof result caching in the FunProp tactic

### 3. Mathlib.Meta.FunProp.cacheFailure (Relevance: 0.093)
- **Type**: Definition
- **Library**: Mathlib
- **Signature**: `Lean.Expr → Mathlib.Meta.FunProp.FunPropM Unit`
- **Description**: Cache for failed goals so fun_prop can fail fast on repeated encounters with the same goal.
- **Use Case**: Negative caching to avoid redundant failed proof attempts

### 4. Mathlib.Tactic.CC.CCM.mkCCHCongrTheorem (Relevance: 0.118)
- **Type**: Definition
- **Library**: Mathlib
- **Signature**: `Lean.Expr → Nat → Mathlib.Tactic.CC.CCM (Option Mathlib.Tactic.CC.CCCongrTheorem)`
- **Description**: Find congruence theorem with caching support. Checks cache first, generates if needed, then caches result.
- **Use Case**: Congruence closure tactic with theorem caching

### 5. Mathlib.Meta.FunProp.State.failureCache (Relevance: 0.187)
- **Type**: Definition
- **Library**: Mathlib
- **Signature**: `Mathlib.Meta.FunProp.State → Lean.ExprSet`
- **Description**: Failure cache storage in the FunProp state for metaprogramming.
- **Use Case**: State management for failure caching

### 6. Mathlib.Tactic.Ring.Cache.mk.noConfusion (Relevance: 0.212)
- **Type**: Definition
- **Library**: Mathlib
- **Signature**: Complex type signature for Cache constructor equality
- **Description**: Injectivity of the Cache.mk Constructor for the ring tactic implementation.
- **Use Case**: Cache data structure for ring tactic

### 7. Mathlib.Tactic.GeneralizeProofs.abstractProofs (Relevance: 0.216)
- **Type**: Definition
- **Library**: Mathlib
- **Signature**: `Lean.Expr → Option Lean.Expr → Mathlib.Tactic.GeneralizeProofs.MAbs Lean.Expr`
- **Description**: Abstract proofs with caching. Recursively abstracts proof subterms using MonadCacheT for efficiency.
- **Use Case**: Proof abstraction with memoization

### 8. Mathlib.Meta.FunProp.State.cache (Relevance: 0.225)
- **Type**: Definition
- **Library**: Mathlib
- **Signature**: `Mathlib.Meta.FunProp.State → Lean.Meta.Simp.Cache`
- **Description**: Cache component in the FunProp state management system.
- **Use Case**: State management for proof caching

### 9. Mathlib.Tactic.Propose.proposeLemmas (Relevance: 0.235)
- **Type**: Opaque definition
- **Library**: Mathlib
- **Signature**: `Batteries.Tactic.DeclCache (Lean.Meta.DiscrTree Lean.Name)`
- **Description**: Lemma cache for forward reasoning tactics using discrimination tree for the have? tactic.
- **Use Case**: Lemma database caching with discrimination trees

### 10. Mathlib.Tactic.TermCongr.M (Relevance: 0.248)
- **Type**: Type abbreviation
- **Library**: Mathlib
- **Signature**: `Type → Type`
- **Description**: Monad for caching CongrResults using MonadCacheT pattern.
- **Use Case**: Monadic caching for congruence results

## Key Patterns and Insights

### 1. Dual Caching Strategy
Mathlib implements both **positive caching** (successful results) and **negative caching** (failures):
- `cacheResult`: Stores successful proof results
- `cacheFailure`: Stores failed attempts to avoid redundant work

### 2. MonadCacheT Pattern
Multiple tactics use the `MonadCacheT` monad transformer for stateful caching:
- `Mathlib.Tactic.TermCongr.M`
- `Mathlib.Tactic.GeneralizeProofs.abstractProofs`

### 3. Specialized Cache Structures
Different tactics implement domain-specific caching:
- **Discrimination Trees**: `proposeLemmas` uses `DiscrTree` for efficient lemma lookup
- **Expression Sets**: `failureCache` uses `Lean.ExprSet` for failure tracking
- **Simp Cache**: `State.cache` integrates with Lean's simplifier cache

### 4. Core Memoization Primitive
`memoFix` provides a general-purpose memoization mechanism using:
- Pointer-based hashing for efficient lookup
- Fixpoint computation with caching
- Optimized for tree traversal with shared subtrees

## Recommendations for ProofChecker

Based on these findings, consider implementing:

1. **Dual Caching**: Implement both success and failure caching in proof search
2. **MonadCacheT Integration**: Use Lean's MonadCacheT for stateful caching in tactics
3. **Discrimination Trees**: Use DiscrTree for efficient lemma/theorem lookup
4. **memoFix Usage**: Leverage `memoFix` for recursive proof search with shared subgoals
5. **Expression-Based Keys**: Use `Lean.Expr` as cache keys (with proper hashing)

## Related Searches

To expand this research, consider additional searches:
- "discrimination tree indexing"
- "proof term sharing"
- "tactic state management"
- "congruence closure caching"

## References

All results from Mathlib library, accessible via:
- Mathlib documentation: https://leanprover-community.github.io/mathlib4_docs/
- Source code: https://github.com/leanprover-community/mathlib4

## Notes

- **Search Limitation**: Only the primary query was executed due to LeanSearch MCP server configuration
- **Pending Queries**: "cached computation" and "memoization function" were not executed
- **Future Work**: Configure LeanSearch MCP server for comprehensive multi-query searches
