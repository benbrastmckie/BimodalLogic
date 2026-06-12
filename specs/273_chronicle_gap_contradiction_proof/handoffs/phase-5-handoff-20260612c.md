# Phase 5 Handoff: Circularity Analysis and Resolution Paths

**Session**: sess_1781193902_83bc5c
**Date**: 2026-06-12
**Phase**: 5 (FO-to-VecEA Equivalence and NF Bridge)
**Status**: BLOCKED (analysis complete, resolution path identified)

## Summary

Exhaustive analysis of the P1/P2 circularity confirms that the only viable
resolutions are: (a) the composition theorem (Feferman-Vaught for linear
orders), or (b) Lemma 3.2.2 + Prop 4.3 (Rabinovich structural induction).
Both require significant formalization effort. This handoff documents the
precise dependency chain and why simpler approaches fail.

## The Circularity (Precise Statement)

The master_induction at NegationClosure.lean:1394 proves P1(k) ∧ P2(k)
by induction on k. At step k+1:

```
P1(k+1) = nf_char_kp1_from_2var(P1(k), P2(k))     -- sorry-free
P2(k+1) = nf_exist_formula_nested backward direction -- SORRY at line 1371
```

The sorry goal is:
```
h_formula : temporal_truth M atomMap t (nf_exist_formula_nested k char_kp1 parent_atoms sub_nf)
⊢ ∃ x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

## Why the Sorry Cannot Be Filled Directly

The formula `nf_exist_formula_nested` encodes:
- A witness x with depth-(k+1) 1-var NF nf_x (from char_kp1)
- Positive interval conditions from sub_nf.2 (∃ y with compatible char_kp1(nf_y))
- Trivial guard (Formula.top)

From the formula, we extract x with nf_eval_nf M (k+1) 1 (fun _ => x) nf_x.
We need nf_eval_nf M (k+1) 2 (x,t) sub_nf, which requires:

1. Atoms of (x,t) match sub_nf.1 -- YES (from compatibility filter)
2. ∀ ssn, (∃ y, nf_eval_nf M k 3 (y,x,t) ssn) ↔ sub_nf.2(ssn) -- NO

Condition 2 fails because:
- The 1-var NF of x (depth k+1) does NOT determine the 2-var NF of (x,t)
- The 2-var NF includes 3-var quantifier conditions ∃ y, nf_eval_nf M k 3 (y,x,t) ssn
- These 3-var interactions are NOT captured by individual 1-var NFs

## Approaches Analyzed and Rejected

### Approach: p2_from_p1_succ
p2_from_p1_succ gives P2(k) from P1(k+1). To get P2(k+1), we'd need P1(k+2).
P1(k+2) needs P2(k+1). CIRCULAR. No fixed-point trick works because the
formula construction is genuinely circular (char_{k+1} references exist_{k}
which references char_{k+1}).

### Approach: Modified induction (P1 only, derive P2)
Proving ∀ k, P1(k) without P2 fails because P1(k+1) needs P2(k) (via
nf_char_kp1_from_2var), and P2(k) = p2_from_p1_succ(k, P1(k+1)), making
P1(k+1) depend on itself.

### Approach: Encode negative conditions in formula
Adding ¬∃ y conditions to nf_exist_formula_nested for sub_nf.2(ssn) = false
would strengthen the backward direction. But encoding ¬∃ y requires
expressing the negation of a 3-var existential, which involves the same
composition problem at depth k-1.

### Approach: Composition theorem for n=2
The composition theorem for n=2 is TAUTOLOGICAL: the 2-var NF of (x,t)
is determined by... the 2-var NF of (x,t). It provides no new information.

### Approach: Non-constructive existence via Classical.choice
Proving ∃ char_kp1 satisfying P1(k+1) non-constructively requires showing
that the predicate nf_eval_nf has a temporal equivalent. This IS Kamp's
theorem for Prior structures, which is what we're trying to prove. CIRCULAR.

## Viable Resolution Paths

### Path A: Composition Theorem (Feferman-Vaught for Linear Orders)

**Statement**: For all k, n ≥ 3: if two n-tuples (y, x_1, ..., x_{n-1})
and (y', x'_1, ..., x'_{n-1}) have the same pairwise depth-k 2-var NFs
for all pairs, then they have the same depth-k n-var NF.

**Proof strategy**: By induction on k.
- k=0: atoms are pairwise, trivial.
- k+1: quantifier part involves ∃ w at arity n+1. By IH, the (n+1)-var NF
  is determined by pairwise 2-var NFs. Need: if ∃ w with specific pairwise
  NFs with all x_i, then ∃ w' with same pairwise NFs with all x'_i.

  The witness transfer relies on: the depth-(k+1) 2-var NF of (x_a, x_{a+1})
  encoding whether ∃ w in (x_a, x_{a+1}) with specific depth-k 2-var NF with
  x_a. Since 2-var NFs agree, the same w' exists.

  **The hard part (witness merging)**: w' must have the right 2-var NF with
  ALL x'_i simultaneously, not just with x'_a. This requires an induction
  on the number of env points and careful tracking of interval decomposition.

**Key insight for witness merging**: Over a linear order, w' in interval
(x'_a, x'_{a+1}) has its 2-var NF with x'_i (for i far from a) determined
by the COMPOSITION of interval types through intermediate points:
nf(w', x'_i) = compose(nf(w', x'_a), nf(x'_a, x'_{a-1}), ..., nf(x'_{i+1}, x'_i)).

This composition is exactly what Feferman-Vaught provides for ordered sums.

**Estimated effort**: 300-500 lines. The witness merging requires careful
Fin arithmetic and interval decomposition. Previous failures hit this at
the 3-var case; the general case might actually be EASIER because the
induction structure is cleaner.

**Key files to modify**: Create new Composition.lean, modify
nf_exist_formula_nested_backward to use it.

### Path B: Lemma 3.2.2 + Prop 4.3 (Rabinovich Structural Induction)

**Statement (Lemma 3.2.2)**: Every EA formula with n > 2 free variables
decomposes into a conjunction of EA formulas with at most 2 free variables.

**Statement (Prop 4.3)**: Every FOMLO formula is equivalent to a V-EA
formula over Prior structures (using Lemma 3.2.2 + Prop 4.2 + Lemma 3.4).

**How it resolves the circularity**: Prop 4.3 proves that every MonadicFormula
has a V-EA equivalent, by structural induction on the formula (NOT by
induction on NF depth). This gives P1(k) for all k simultaneously:
nf_eval_nf M k 1 t nf ↔ eval M t (nf_to_formula nf), and nf_to_formula nf
is a MonadicFormula that Prop 4.3 makes V-EA, which Prop 3.5 makes temporal.

**The hard part**: Lemma 3.2.2 formalization. An EA formula with n ordered
free variables z_0 < ... < z_{n-1} and witnesses x_0 < ... < x_m placed
among the z_i's decomposes into independent bracket formulas on each
segment (z_i, z_{i+1}). The formalization requires:
1. Partitioning witnesses among segments
2. Showing point types and interval types are local to segments
3. Proving semantic equivalence

**Estimated effort**: 400-600 lines. Lemma 3.2.2 is ~200 lines, Prop 4.3
is ~100 lines, bridge to P1/P2 is ~100-200 lines.

**Key files**: Create Lemma322.lean (or extend VecEAFormula.lean),
create Prop43.lean, modify NfCharFormula.lean and KampPrior.lean.

### Path C: Direct Game Proof (Doets Lemma 1.4/1.5)

Not analyzed in detail. Would require formalizing EF games for ordered
sums, which is a major restructuring.

## Recommendation

**Path A (Composition Theorem)** is recommended. Reasons:
1. It directly closes the sorry at NegationClosure.lean:1371
2. The mathematical argument is well-understood
3. Previous failures were at the Lean encoding level (Fin arithmetic,
   witness construction), not at the mathematical level
4. The key insight for avoiding previous failures: use the depth-(k+1)
   2-var NF encoding to TRANSFER witnesses between intervals, rather than
   constructing witnesses from scratch
5. Cleaner architecture: the composition theorem is a general result
   useful beyond this specific sorry

**Path B** is the alternative if Path A fails again. It's more work but
avoids the witness merging problem entirely.

## Current Sorry Inventory (Unchanged)

- NegationClosure.lean:1371 (`nf_exist_formula_nested_backward`) -- 1 sorry
- NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`) -- 1 sorry
- KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ case) -- 1 sorry
- NfComposition.lean:106,108 (`nf_3var_from_1var_nfs`) -- 2 sorries (bypassed)

Total: 3 active sorries on the critical path (all stem from the same circularity)

## Immediate Next Action

For the successor agent: implement Path A (Composition Theorem) in a new
file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Composition.lean`.

Key theorem to prove:
```lean
theorem composition_from_pairwise {sig : MonadicSignature}
    (k n : Nat)
    (M : OrderedMonadicStructure sig) (env : Fin n → M.carrier)
    (N : OrderedMonadicStructure sig) (env' : Fin n → N.carrier)
    (h_pair : ∀ i j nf, nf_eval_nf M k 2 (pair_env env i j) nf ↔
                         nf_eval_nf N k 2 (pair_env env' i j) nf)
    (nf : NormalForm sig k n) :
    nf_eval_nf M k n env nf ↔ nf_eval_nf N k n env' nf
```

Once this is proved, use it in `nf_exist_formula_nested_backward` to
determine the 2-var NF of (x,t) from the pairwise information extracted
from the formula.

Specifically, from the formula truth + char_kp1(nf_x) + interval conditions:
- nf(x,t) at depth k+1: ATOMS match sub_nf.1 (from filter)
- For POSITIVE ssn (sub_nf.2(ssn) = true): ∃ y in interval with char_kp1(nf_y)
  → by composition, nf_eval_nf M k 3 (y,x,t) ssn
  → so (nf_char M (k+1) 2 (x,t)).2(ssn) = true
- For NEGATIVE ssn (sub_nf.2(ssn) = false): need ¬∃ y with 3-var NF ssn
  → this follows from nf_x's quantifier part + composition
  → nf_x encodes all 2-var NFs realizable at (·, x), which by composition
    determine the 3-var NFs at (·, x, t)

The last step (negative direction) is the crux. It requires showing that
nf_x's quantifier data, combined with the pairwise NF of (x,t) that we're
CONSTRUCTING, determines the 3-var NF. This is circular unless we can
extract the negative information from nf_x alone.

**Alternative for negative direction**: Use the formula information MORE
CAREFULLY. The formula encodes ALL compatible nf_x's in its disjunction.
The SPECIFIC nf_x that matches is the one whose quantifier part is
consistent with sub_nf.2. Since nf_x.2 encodes ∃ z, nf_eval_nf M k 2 (z,x)
sub_nf', and sub_nf.2(ssn) specifies which 3-var NFs are realizable, the
compatibility filter ensures that nf_x's quantifier data is consistent
with sub_nf.2 for "non-interval" ssn (those where y equals x or t, or is
outside the interval). The remaining "interval" ssn are handled by the
explicit interval chains in the formula.

The negative interval ssn (sub_nf.2(ssn) = false, y in interval): the
formula does NOT explicitly encode these. But they follow from the
COMBINATION of: (a) nf_x's quantifier data (which 2-var NFs at (·, x) are
realizable), (b) the pairwise NF of (x,t) at depth k, and (c) the
composition theorem. The composition theorem shows that the 3-var NF
(y,x,t) is determined by pairwise, so if no y with the right PAIRWISE NFs
exists, no y with the right 3-var NF exists.

The remaining question: does the formula provide enough information to
determine the PAIRWISE NFs of (y,x) and (y,t) for all interval witnesses?
Answer: nf_x encodes which (·, x) 2-var NFs exist (from its quantifier
part). The depth-(k+1) 2-var NF of (x,t) (which we're trying to determine)
encodes which 3-var NFs (·,x,t) exist. By composition, these are
determined by the pairwise (·,x) and (·,t) 2-var NFs, which are in turn
determined by nf_x and nf_t and the interval type. This is STILL CIRCULAR.

**Bottom line**: The composition theorem is NECESSARY but NOT SUFFICIENT
for closing the sorry via the current formula. The formula must also
encode enough information to determine the interval type, which it doesn't
(it only encodes positive interval conditions).

**Revised recommendation**: Path B (Lemma 3.2.2 + Prop 4.3) is cleaner
because it BYPASSES the formula-level backward direction entirely. Instead
of trying to prove the backward direction of nf_exist_formula_nested, it
replaces the entire P1/P2 induction with a structural induction on
MonadicFormula that doesn't need the backward direction at all.
