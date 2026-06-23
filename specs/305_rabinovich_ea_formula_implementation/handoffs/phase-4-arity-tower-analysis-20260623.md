# Phase 4 Handoff: Arity Tower Analysis and Resolution Path

**Date**: 2026-06-23
**Task**: 305 (Rabinovich EA Formula Implementation)
**Phase**: 4 (Prop 4.3 Structural Induction)
**Status**: BLOCKED (mathematical barrier confirmed)
**Session**: sess_1782234661_3b566f

## Immediate Next Action

Implement Rabinovich's Prop 4.3 structural induction on MonadicFormula using
V-EA formulas for arbitrary arities. This requires three new pieces of
infrastructure: (1) a semantic V-EA type parametrized by arity n, (2) Lemma 3.2(2)
for arity reduction from n to 2, and (3) V-EA closure under existential
quantification (Lemma 3.4(3)). The negation closure (Prop 4.2) for arity 2
is already sorry-free as `neg_2var_vec_ea` in EANegationClosure.lean.

## Current State

- **Build**: passes (1700 jobs)
- **Sorry**: NfExistTL.lean:301 (Part B at depth k+1)
- **Phase 4 plan status**: [PARTIAL] -- combined induction architecture created but sorry remains
- **All other code**: unchanged, sorry-free infrastructure preserved

## Mathematical Analysis (Definitive)

### The Arity Tower Barrier

The sorry at NfExistTL.lean:301 requires proving:

```
∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf
```

is temporally definable on Prior structures for all k.

**Root cause**: At depth k+1, the arity-2 NF has quantifier assignments on
`NormalForm sig k 3` (arity-3 sub-NFs). Each quantifier condition involves
`∃ y, nf_eval_nf M k 3 (y::x::t) ssn`, a 2-variable statement that depends
on BOTH x and t. This introduces arity 3, which at depth k-1 introduces
arity 4, etc.

### Why the NF-Depth Induction Cannot Work

Every attempt to prove Part B at depth k+1 faces the same circularity:

1. **Via Doets + NF disjunction**: The existential is determined by the
   depth-(k+2) arity-1 NF. Building its temporal formula requires Part A at
   depth k+2, which requires Part B at depth k+1 (the thing being proved).

2. **Via nf_to_formula bridge**: The existential equals
   `eval M (fun _ => t) (.ex (nf_to_formula sub_nf))`, a MonadicFormula sig 1
   of quantifier depth k+2. Converting this to temporal requires Part A at
   depth k+2 (same circularity).

3. **Via rearranged induction (Part A at k+1, Part B at k)**: Part B at k
   via nf_to_formula gives a MonadicFormula sig 1 of depth k+1. Converting
   this needs Part A at k+1 (just proved), but Part A at k+1 was proved
   USING Part B at k (the IH). The circularity is: Part B(k) needs Part A(k+1)
   which needs Part B(k).

4. **Via well-founded induction on quantifier depth**: Part A at depth d
   needs Part B at depth d-1. Part B at d-1 (via nf_to_formula) gives a
   formula of depth d. Converting to temporal needs Part A at depth d.
   Same circularity.

5. **Via formula structural induction**: The `ex` case for MonadicFormula sig 1
   introduces MonadicFormula sig 2. The `ex` case at sig 2 introduces sig 3.
   This is the arity tower at the formula level.

**Conclusion**: The circularity is INTRINSIC to the NF-based approach and
cannot be resolved by any rearrangement of the induction. A fundamentally
different proof method is required.

### Rabinovich's Resolution (Prop 4.3)

Rabinovich breaks the circularity via structural induction on the FORMULA
(not the NF), using three key ingredients:

1. **Lemma 3.2(2)**: Every EA formula with m free variables is equivalent to a
   CONJUNCTION of EA formulas with at most 2 free variables. This reduces the
   arity tower to arity 2 at each step.

2. **Prop 4.2** (negation closure): The negation of a V-EA formula with ≤ 2
   free variables is V-EA. We have this as `neg_2var_vec_ea` (model-dependent,
   sorry-free in EANegationClosure.lean).

3. **Lemma 3.4(3)** (existential closure): If phi(y, z_0, ..., z_m) is V-EA,
   then `∃ y, phi` is V-EA. The existential simply absorbs y into the EA
   witness block.

The structural induction:
- **Atomic**: EA trivially.
- **Negation**: By IH, phi is V-EA. Apply Lemma 3.2(2) to reduce to ≤ 2 free
  variables. Apply Prop 4.2 to negate each piece. Recombine via V-EA closure
  under conjunction (Lemma 3.4(1)).
- **Conjunction**: By IH, both V-EA. Conjunction of V-EA is V-EA (Lemma 3.4(1)).
- **Existential**: By IH, sub-formula is V-EA. Apply Lemma 3.4(3).

This works because:
- The formula structure DECREASES at each step (well-founded).
- Arity INCREASES at the `ex` step but Lemma 3.2(2) reduces back to 2.
- Negation uses Prop 4.2 which is specific to ≤ 2 free variables.

## Implementation Plan for Resolution

### Required New Infrastructure

1. **Semantic V-EA for arbitrary arity** (~100-150 lines)
   - Define `VEA_n (n : Nat)`: an exists-forall formula with n free variables
   - Define `VVEA_n (n : Nat)`: disjunction of VEA_n formulas  
   - Evaluation: `VVEA_n.holds M env` for `env : Fin n → M.carrier`
   - Can be defined purely semantically (existentially) without syntactic structure

2. **Lemma 3.2(2): Arity reduction** (~200-300 lines)
   - Statement: Every EA formula with m free variables is equivalent to a
     conjunction of EA formulas with ≤ 2 free variables
   - Key idea: on a linear order, the interval structure of witness points is
     determined by pairwise relationships with free variables
   - Implementation: given `VVEA_n n`, produce `∀ (i j : Fin n), VVEA_n 2` such
     that the original is the conjunction of the projections
   - At depth 0: decompose purely atomic conditions (order + predicates) pairwise
   - At depth k > 0: use nf_to_formula to convert NF conditions to formulas,
     then apply IH on the formula structure

3. **Lemma 3.4(3): Existential closure** (~50-100 lines)
   - Statement: If phi(y, z_0, ..., z_m) is VVEA_{m+1}, then ∃y phi is VVEA_m
   - Implementation: the existential variable y joins the witness block of the EA
   - Straightforward: EA already has the form ∃ x_1 ... x_k, conditions; adding
     ∃ y just extends the witness block

4. **Prop 4.3: Structural induction** (~200-400 lines)
   - Statement: Every MonadicFormula sig n is VVEA_n over Prior structures
   - Proof: mutual structural induction over MonadicFormula sig n for all n
   - Uses: Lemma 3.2(2), Prop 4.2, Lemma 3.4

5. **Bridge to KampPrior** (~100-150 lines)
   - Specialize Prop 4.3 to n=1: every MonadicFormula sig 1 is VVEA_1
   - VVEA_1 is temporal (via Prop 3.5 / VVecEA2.translateLeft, already sorry-free)
   - Wire into nf_characterizable_temporal_prior_combined to eliminate Part B sorry

### Estimated Effort

- Total: ~650-1000 lines across 2-3 dispatches
- Most complex piece: Lemma 3.2(2) arity reduction
- Key risk: Lemma 3.2(2) may require careful handling of the interaction between
  pairwise projections and the interval structure

### Alternative Approaches (Evaluated and Rejected)

1. **Depth-0 arbitrary-arity VecEADecomp**: Only handles depth 0. Higher depths
   reintroduce the arity tower through quantifier conditions.

2. **Model-dependent Part B**: neg_2var_vec_ea is model-dependent. Could potentially
   bypass the arity tower for a specific model, but Part B needs to produce a
   MODEL-INDEPENDENT formula (same formula works for all Prior structures).

3. **Self-referential fixed-point**: Define exist_tl_fn using good_nfs disjunction.
   The formula is definable but the CORRECTNESS proof is circular (it requires
   the formula at the same depth to be correct).

## Key Decisions

- Combined Part A/Part B induction architecture is CORRECT but insufficient
  (Part A at k+1 from Part B at k works; Part B at k+1 is the barrier)
- The resolution MUST go through Rabinovich's Prop 4.3 structural induction
- Semantic V-EA (existential, not constructive) is sufficient since we use
  Classical.choice throughout
- Model-dependent negation (neg_2var_vec_ea) suffices because Prior structures
  have HasAttainedINF

## Sorry Inventory

| File | Line | Statement | Status |
|------|------|-----------|--------|
| NfExistTL.lean | 301 | Part B at k+1 | CRITICAL PATH |
| EANegation.lean | 1084 | neg_bracket beta_0 | NOT CRITICAL (unprovable at BF level) |
| EANegation.lean | 1235 | neg_partialBracketExist n+1 | NOT CRITICAL (unprovable at BF level) |
| EndpointNegation.lean | 160 | neg_vecEA2 succ | NOT CRITICAL (model-dep alternative exists) |

## Files Modified

None in this dispatch (analysis-only -- plan was blocked before file writes).

## References

- Rabinovich 2014, Section 3 (Lemma 3.2, Lemma 3.4, Prop 3.5)
- Rabinovich 2014, Section 4 (Prop 4.2, Prop 4.3, Thm 4.4)
- VecEADecomp.lean: depth-0 arity-3 decomposition (template for arity reduction)
- EANegationClosure.lean: neg_2var_vec_ea (Prop 4.2, model-dependent, sorry-free)
- VecEAClosure.lean: VVecEA2.conj_holds_vvecEA2 (Lemma 3.4(1) for arity 2)
- NfExistTL.lean: combined Part A/Part B induction (current architecture)
