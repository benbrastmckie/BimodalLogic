# Teammate A Findings: Literature Analysis for neg_bracket_syn_iff Blocker

**Session**: sess_1781284347_6fed81
**Date**: 2026-06-12
**Artifact**: 23
**Role**: Primary Angle -- Deep dive into primary literature (GHR93, Rabinovich 2014)

---

## Key Findings

1. **The blocker in `neg_bracket_syn_iff` is a real mathematical gap**: The syntactic
   negation construction (`neg_bracket_syn`) in VecEADecomposition.lean cannot be proved
   sound in Case C because the interval `(r, z1)` for the counter-pattern's tail differs
   from the interval `(w(0), z1)` for the original bracket formula's tail. These witnesses
   from independent existentials cannot be forced to coincide under open-interval semantics.

2. **The construction in VecEADecomposition.lean does NOT correspond to any step in
   Rabinovich 2014 or GHR93**: Rabinovich's approach to negation closure is purely
   semantic (Lemma 5.1 and Prop 4.2 in NegationClosureProp42.lean) and does NOT require
   a syntactic `neg_bracket_syn` operator with a biconditional. The syntactic negation
   was an architectural detour.

3. **Prop 4.3 in Rabinovich is bypassed by a cleaner path already in place**: The
   files `FoToVecEA.lean` + `NegationClosure.lean` implement Rabinovich's actual approach
   (P1/P2 simultaneous induction with `p2_from_p1_succ`) which does NOT use
   `neg_bracket_syn_iff` or `neg_vecEA2_syn_iff` at all.

4. **The sorry that actually blocks `nf_2var_existential_transfer` (StaviCompleteness.lean)
   is in the backward direction of `nf_exist_formula_nested_backward`
   (NegationClosure.lean:1371)**, not in VecEADecomposition.lean directly. That sorry is
   blocked on the Feferman-Vaught composition lemma (`nf_3var_from_1var_nfs` in
   NfComposition.lean:106,108).

5. **Path (b) -- semantic Prop 4.3 -- is what Rabinovich actually does**, and it is
   already implemented in `neg_2var_vec_ea` (NegationClosureProp42.lean). The VecEADecomposition
   sorry does NOT block this path.

---

## Literature Analysis

### What Rabinovich 2014 Actually Says About Negation Closure

Rabinovich's argument for negation closure (Section 5) proceeds in this order:

- **Lemma 5.1** (`neg_interval_formula` in NegationClosure5.lean): The negation of a
  BracketFormula `[alpha_0, beta_1, ..., alpha_n](z_0, z_1)` is equivalent to a
  **V-bracket formula** (existential disjunction). This is proved semantically by induction
  on n, using `first_occurrence_prior_strict` and interval splitting. This lemma is
  **completely proved and sorry-free** in the codebase.

- **Prop 4.2** (`neg_2var_vec_ea` in NegationClosureProp42.lean): The negation of a
  VVecEA2 formula is equivalent to a VVecEA2 formula. This uses Lemma 5.1 plus de Morgan.
  This is also **completely proved and sorry-free**.

- **Prop 4.3** (the bridge from FO/NF to VecEA): Rabinovich states that every 2-free-variable
  quantifier block in a k-depth NF can be expressed as a VVecEA2 formula, using the
  temporal characterizations of depth-k 1-variable NFs. The implementation in
  `FoToVecEA.lean` via `p2_from_p1_succ` already does this **without requiring any syntactic
  negation biconditional**.

**Crucially**: Rabinovich's Prop 4.3 does NOT produce a uniform syntactic negation
operator `neg_bracket_syn` with a biconditional. It produces a model-dependent semantic
statement: "for any M and formula phi, there EXISTS a VVecEA2 equivalent." The
`neg_bracket_syn_iff` theorem was attempting a stronger, syntactic claim that goes
beyond what the literature establishes.

### What GHR93 (Gabbay, Hodkinson, Reynolds 1993) Says

GHR93 proves expressive completeness for ALL linear orders using Stavi formulas. The
vectorial EA formulas (VecEA) are GHR93's "ea formulas" (Proposition 7 in GHR93). The
analogous negation closure step in GHR93 uses:

1. Interval type data from the EF game (the "type" of an interval includes quantifier
   depth information about what NFs can be realized inside)
2. The composition theorem (Feferman-Vaught): if the interval types of `(x, u)` and
   `(u, t)` match those of `(x', u')` and `(u', t')`, then the NF of `(x, t)` matches
   `(x', t')`

GHR93 does NOT construct a syntactic `neg_bracket_syn` operator. Instead, GHR93 works
entirely with semantic equivalence classes (types). The "negation closure" in GHR93 is
the closure of VecEA formulas under Boolean operations, proved using the composition
theorem.

**GHR93 Proposition 7** is the claim that every monadic FO formula over 2 free variables
is equivalent to a VVecEA2 formula. This is NOT proved by a syntactic negation construction
but by induction over the quantifier depth, using the Feferman-Vaught composition theorem
at each step.

### The Real Blocker: Feferman-Vaught Composition

The actual mathematical gap in the codebase is the **Feferman-Vaught composition theorem**
for NormalForms, which appears in two sorry sites:

1. **NfComposition.lean:106,108** (`nf_3var_from_1var_nfs`): Given that three pairs of
   points (y1,x1,t1)/(y2,x2,t2) have matching depth-(k+1) 1-var NFs and matching orders,
   prove that the depth-k 3-var NFs match. The quantifier part requires transferring
   4-variable NF witnesses across models with matching interval structure.

2. **NegationClosure.lean:1371** (`nf_exist_formula_nested_backward`): The backward
   direction of P2(k+1) -- given a temporal formula holds, extract the witness with the
   right 2-var NF. This is blocked on the Feferman-Vaught argument.

3. **StaviCompleteness.lean:2421/2503** (`nf_2var_existential_transfer`, j+1 case):
   The 4-variable quantifier transfer requiring sub-interval matching for the 3-point
   configuration. This is where the EF game argument is needed.

All three sorry sites correspond to the SAME underlying gap: the Feferman-Vaught
composition theorem asserting that interval type data from 1-var NFs propagates correctly
to multi-variable NFs when combined with order information.

---

## Recommended Approach

### Path (b) -- Semantic Prop 4.3 -- is the Correct Literature Path

Rabinovich's actual proof avoids the `neg_bracket_syn` biconditional entirely. The
architecture in `FoToVecEA.lean` and `FoToVecEA.p2_from_p1_succ` already implements
the correct semantic approach:

1. **Do NOT try to prove `neg_bracket_syn_iff` soundness**: This theorem is not in
   Rabinovich and is not needed for the completeness chain.

2. **The sorry in `neg_bracket_syn_iff` (VecEADecomposition.lean)** can be **left as
   dead code** or the file can be restructured to not need it. The completeness chain
   (`KampPrior.lean` -> `NegationClosure.lean` -> `FoToVecEA.lean`) does not call
   `neg_bracket_syn_iff` or `neg_vecEA2_syn_iff`.

3. **The real target for unblocking `nf_2var_existential_transfer`** is the
   Feferman-Vaught composition lemma (`nf_3var_from_1var_nfs` in NfComposition.lean).

### Feferman-Vaught Composition: The Correct Attack

The correct approach following GHR93 and Rabinovich:

**Step 1**: Prove `nf_3var_from_1var_nfs` in NfComposition.lean. The key insight is:

Given:
- Points y1, x1, t1 in M and y2, x2, t2 in M with matching depth-(k+1) 1-var NFs
- Matching pairwise orders

Then the depth-k 3-var NFs of (y1,x1,t1) and (y2,x2,t2) agree.

This follows from the definition of NF: the depth-k 3-var NF is determined by:
- Atom assignment at each of the 3 variables (given by 1-var NFs)
- For each depth-(k-1) 4-var NF sub_nf: whether `∃ z, nf_eval M (k-1) 4 (z::y::x::t) sub_nf`

The existential transfer at arity 4 requires showing that a witness z in context (y1,x1,t1)
can be matched by a witness z' in context (y2,x2,t2). This is exactly the `zone_match_witness`
argument already present in StaviCompleteness.lean.

**Step 2**: Use `nf_3var_from_1var_nfs` to fill the sorry in
`nf_exist_formula_nested_backward` (NegationClosure.lean:1371). The proof structure is:

Given temporal formula holds, extract x from Until/Since. The depth-(k+1) 1-var NF of x
records which depth-k 2-var NFs are realized with t. Apply Feferman-Vaught to show the
3-var NF of (y,x,t) is determined. Then show the 2-var NF `(Fin.cons x (fun _ => t))`
is correct.

**Step 3**: The sorry in `nf_2var_existential_transfer` (StaviCompleteness.lean:2421) will
then follow from Step 2 since the Kamp/Prior route uses the same composition argument.

### Path (c) -- Canonical Witness Lemma

Path (c) -- showing `bf.holds z0 z1` implies existence of a canonical configuration
where the first witness IS the first alpha0 occurrence -- is the same as the first-occurrence
argument already proved in `first_occurrence_prior_strict`. However, this does NOT resolve
the Case C soundness blocker:

The issue is not about which witness is "canonical" within bf.holds. It is that the
counter-pattern's tail negation lives on `(r, z1)` where r is independently chosen
(from the counter-pattern's existential), while bf.tail.holds lives on `(w(0), z1)`.
Even if we take w(0) to be the first alpha0 occurrence, r need not equal w(0) because r
comes from a different (negation) context.

**Path (c) is blocked** for the same fundamental reason: open-interval semantics prevent
forcing witness coincidence between the original formula and its negation.

### Path (a) -- Compactness/Finiteness Lift

Path (a) is unnecessary complexity. The semantic approach (Path b) already achieves
model-independence through the NF framework: the NF is a finite Boolean structure that
captures exactly which VVecEA2 conditions hold, and the formula construction in
`p2_from_p1_succ` is already model-independent (it's a disjunction over finitely many
NF types).

### Path (d) -- Different Syntactic Construction

Path (d) is not needed because the correct resolution (Path b) abandons the requirement
for a syntactic biconditional altogether, not just changes how Case C is constructed.

---

## Evidence and Examples

### Evidence That the Kamp/Prior Chain Bypasses `neg_bracket_syn_iff`

Dependency chain for the target `kamp_prior_expressive_completeness`:

```
kamp_prior_expressive_completeness (KampPrior.lean)
  -> nf_characterizable_temporal_prior (KampPrior.lean:149 -- sorry, target)
     -> master_induction -> p2_kp1 (NegationClosure.lean)
        -> nf_exist_formula_nested_backward (NegationClosure.lean:1371 -- sorry)
           -> nf_3var_from_1var_nfs (NfComposition.lean:106 -- sorry)
```

None of this chain calls `neg_bracket_syn_iff` or `neg_vecEA2_syn_iff`.

### Evidence That VecEADecomposition Sorries Are Not On the Critical Path

The file `VecEADecomposition.lean` imports `NegationClosureProp42` and `VecEAClosure`.
Its sorries (`neg_bracket_syn_iff` and `neg_vecEA2_syn_iff`) are NOT imported by any
file in the critical chain:

- `NfCharFormula.lean` imports `ExistsForallNF`, `PriorINF`, `Translation`, `NormalForm`
- `KampPrior.lean` imports `ExistsForallNF`, `NormalForm`, `PriorDefs`, `KampTranslation`
- `NegationClosure.lean` imports `ExistsForallNF`, `KampPrior`, `NfCharFormula`, `PriorINF`, `Translation`, `NormalForm`, `KampTranslation`
- `FoToVecEA.lean` imports `NegationClosureProp42`, `NegationClosure`

`FoToVecEA.lean` imports `NegationClosure` (not `VecEADecomposition`). The
`neg_vecEA2_syn_iff` in VecEADecomposition.lean is dead code relative to the critical path.

### Evidence That `nf_3var_from_1var_nfs` Is the Key Lemma

The sorry in NfComposition.lean:106 says:
```
-- By IH, the (k+1)-level 3-var NF at (z,y,x,t) is determined by
-- pairwise 2-var NFs. The witness transfer on linear orders gives
-- z' with the same pairwise structure in context 2.
sorry
```

This is the quantifier part of the Feferman-Vaught composition. The forward direction
requires: given z witnessing a 4-var NF in context (y1,x1,t1), find z' witnessing the
same 4-var NF in context (y2,x2,t2). The `zone_match_witness` machinery already in
StaviCompleteness.lean for the 2-var case needs to be generalized to handle the
additional variables y1,y2.

---

## Confidence Level

**High** -- The analysis is based on direct reading of:
- All 6 files in the Kamp/ subdirectory
- The StaviCompleteness.lean sorry sites and their dependency chain
- The module import graph (no VecEADecomposition sorries on the critical path)

**High** for the diagnosis that `neg_bracket_syn_iff` is not on the critical path.

**High** for the diagnosis that the real blocker is `nf_3var_from_1var_nfs`
(Feferman-Vaught composition).

**Medium** for the claim that Path (b)/composition approach will succeed: the
`zone_match_witness` generalization for 4-variable contexts requires careful formalization
work, but the mathematical content is standard Feferman-Vaught and well-established.

---

## Summary: Recommended Resolution

The sorry in `nf_2var_existential_transfer` (StaviCompleteness.lean) and the
`nf_characterizable_temporal_prior` sorry (KampPrior.lean) share the same root cause:
the Feferman-Vaught composition lemma for NormalForms is not proved.

**Immediate action**: Prove `nf_3var_from_1var_nfs` in NfComposition.lean. This is a
self-contained mathematical goal (does not require the EF game machinery from
StaviCompleteness.lean) and corresponds directly to Doets 1989 Lemma 1.4/1.5 cited in
the file header.

**Architecture note**: The sorries in VecEADecomposition.lean (`neg_bracket_syn_iff`,
`neg_vecEA2_syn_iff`) are **not on the critical path** and should be treated as
technical debt / documentation of a failed approach, not as blockers. The Kamp/Prior
completeness chain bypasses them entirely via `FoToVecEA.p2_from_p1_succ`.
