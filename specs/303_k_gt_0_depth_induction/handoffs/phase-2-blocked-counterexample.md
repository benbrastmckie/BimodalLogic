# Phase 2 Blocked: False Theorems in PriorComposition.lean

**Date**: 2026-06-17
**Session**: sess_1781661075_5cab61
**Status**: BLOCKED (theorems are mathematically false)

## Immediate Next Action

Research task needed: determine the correct enrichment of Until/Since zone formulas to encode full 2-var NF content (not just 1-var types). The eq zone pattern (KampBypass.lean:596-740) is the model -- it encodes quantifier conditions using ih_exist on constant parents. The Until/Since zones need an analogous approach that handles non-constant parents.

## Critical Discovery

The theorems `prior_nonconstenv_2var_agree_until` and `prior_nonconstenv_2var_agree_since` in PriorComposition.lean are **mathematically false**. They claim:

> depth-(K+2) 1-var NF agreement at x/x' and t/t' + matching orders (t < x, t' < x') + Prior-UZ/SZ
> implies depth-(K+2) 2-var NF agreement at [x,t]/[x',t']

### Counterexample

Let M = N = (Z, <, P) where P is a single unary predicate holding at every integer.

- sig has one predicate p, atomMap maps the relevant formula atom to p
- env_M = [x=2, t=0], env_N = [x'=1, t'=0]
- All integers have the same depth-(K+2) 1-var NF for any K (translation symmetry + uniform predicates)
- Matching orders: 0 < 2 and 0 < 1
- Z satisfies Prior-UZ/SZ: each upper set {s > t} is isomorphic to N (well-ordered), so every temporal formula with an occurrence above t has a first occurrence

But the depth-2 2-var NFs at [2,0] and [1,0] DIFFER:
- The 3-var existential "exists w with nf_eval_nf M 0 3 [w,2,0] chi" where chi specifies 0 < w < 2 is **satisfiable** (take w=1)
- The same chi at [1,0] specifying 0 < w < 1 is **unsatisfiable** (no integer in the open interval (0,1))

This refutes `prior_nonconstenv_2var_agree_until` at K=0 and generalizes to all K.

### Root Cause

1-var NF agreement tells us: "x and x' have the same predicates and the same quantifier-depth profile (what types exist globally)." Matching orders tells us: "t < x iff t' < x'." But NEITHER captures what types exist IN THE INTERVAL (t, x) vs (t', x'). The between-zone content is a 2-var property that 1-var NFs + orders cannot determine.

### Impact

1. **PriorComposition.lean sorries (lines 231, 239, 322, 399)**: Cannot be closed. The theorems are false.
2. **KampBypass.lean k>0 backward proofs (lines 532, 577)**: Use `prior_2var_transfer_until/since` which invoke the false theorems. These proofs are unsound.
3. **KampBypass.lean k>0 formulas**: The enriched formula `char_kp1(nf_t0) AND (char_kp1(nf_x0) U top)` encodes only 1-var NF types. This is insufficient.

## What Is Preserved

- **KampComposition.lean (Phase 1)**: All theorems are CORRECT. `constenv_same_depth_2var`, `exist_transfer_nvar_constenv` work because constant environments `[t,t]` have empty between-zones.
- **KampBypass.lean k>0 forward proofs**: The forward direction (lines 534-552, 579-594) is correct -- it goes from nf_eval to temporal formula, not the reverse.
- **KampBypass.lean eq zone (lines 596-740)**: Correct because x=t makes the env constant.
- **All k=0 infrastructure**: Unaffected.

## What Must Change

### Option A: Encode full 2-var NF in Until/Since formula

Enrich the Until/Since formula to include quantifier conditions, analogous to the eq zone's `quant_conj`:

```
-- Current (insufficient):
char_kp1(nf_t0) AND (char_kp1(nf_x0) U top)

-- Needed:
char_kp1(nf_t0) AND (char_kp1(nf_x0) U top) AND quant_conj_nonconstant
```

where `quant_conj_nonconstant` encodes "for each 3-var sub_nf ssn, exists y in (t,x) with nf_eval at [y,x,t] ssn iff sub_nf.2(ssn)=true."

The problem: `ih_exist` only handles constant parents `(fun _ => t)`. For non-constant parents `[x,t]`, a new variant is needed.

### Option B: Generalize VecEA2 to k>0

The k=0 VecEA2 machinery encodes each zone's content separately using temporal brackets (Until, Since). At k>0, the same zone-bracket approach could encode zone content using char_kp1 to identify witness NF types within each bracket.

This is the most natural generalization of the working k=0 approach.

### Option C: Non-constant-parent ExistPart

Add a new component to the mutual induction:

```
ExistPart_nc(k, x_type, t_type, sub_nf) :
  ∃ A, ∀ M h_UZ h_SZ t x,
    nf_eval_nf M (k+1) 1 (fun _ => t) t_type →
    nf_eval_nf M (k+1) 1 (fun _ => x) x_type →
    (temporal_truth M atomMap t A ↔ ∃ y, nf_eval M k 3 [y,x,t] sub_nf)
```

This directly addresses the gap but significantly enlarges the mutual induction.

## Key Decisions

- PriorComposition.lean's false theorems should be deleted or moved to Boneyard
- KampBypass.lean k>0 Until/Since backward proofs must be rewritten
- A new plan version (v6) is needed

## Sorry Inventory

| File | Line | Status | Notes |
|------|------|--------|-------|
| PriorComposition.lean | 231 | FALSE | Theorem conclusion is false |
| PriorComposition.lean | 239 | FALSE | Symmetric, same issue |
| PriorComposition.lean | 322 | FALSE | Inside false theorem |
| PriorComposition.lean | 399 | FALSE | Inside false theorem |
| NfCharFormula.lean | 542 | Dead code | Not on critical path |
| NfCharFormula.lean | 651 | Blocked | Upstream dependency on false theorems |

## References

- NfComposition.lean:20-36 -- original counterexample (Z,<) with different envs
- PriorDefs.lean -- semantic_prior_UZ/SZ definitions
- KampBypass.lean:596-740 -- eq zone approach (working model for encoding quantifier conditions)
- KampBypassUntil.lean -- k=0 VecEA2 approach (zone-bracket encoding)
