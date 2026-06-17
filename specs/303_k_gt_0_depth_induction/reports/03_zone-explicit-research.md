# Research Report: Zone-Explicit Temporal Formula Encoding for k>0

- **Task**: 303 - k_gt_0_depth_induction
- **Started**: 2026-06-16T00:00:00Z
- **Completed**: 2026-06-16T02:00:00Z
- **Session**: sess_1781661075_5cab61
- **Effort**: Hard mode (H3 reference grounding + H4 adversarial verification)
- **Sources/Inputs**:
  - KampBypass.lean (sorry sites at lines 356, 368)
  - KampBypassUntil.lean (k=0 sorry-free Until zone template, 979 lines)
  - KampBypassCore.lean (zone definitions, VecEA2 infrastructure, 2161 lines)
  - KampMutualInduction.lean (CharPart/ExistPart mutual induction)
  - NfCharFormula.lean (nf_2var_exist_formula_prior, classical path)
  - NfComposition.lean (counterexample refuting NfCompose, nf_extend_fwd/bwd)
  - Rabinovich 2014, Section 5 (interval-splitting argument)
  - Phase-1 handoff (ExistPart_r proved FALSE via counterexample)

## Reference Grounding (H3 Tier 1 -- Literature-Backed)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|---------------|-----------------|----------------|--------|
| Rabinovich 2014 | Prop 3.5 (V-EA -> TL) | `existPart_succ_n1_bypass` | `... -> exists A, ...` | SORRY at k>0 backward |
| Rabinovich 2014 | Lemma 5.1 (interval splitting) | `existPart_succ_n1_bypass_k0_until` | k=0 Until case | COMPLETE (sorry-free) |
| Rabinovich 2014 | Lemma 5.3 (base: beta_i = True) | `enriched_vecEA2_until` / VecEA2 bracket | k=0 bracket infrastructure | COMPLETE |
| Rabinovich 2014 | Prop 4.2 (negation closure) | `nf_2var_exist_formula_prior` | `... -> exists A, forall M ...` | Routes through bypass |
| Rabinovich 2014 | Thm 4.4 (Kamp's Theorem) | `kamp_mutual_induction` | `CharPart k AND ExistPart k` | Depends on bypass |

## Executive Summary

The zone-explicit temporal formula encoding approach for k>0 is **not directly viable** within the current constant-parent ExistPart framework. The fundamental obstacle -- that `ih_exist` only handles constant parent environments `(fun _ => t)` while the k>0 Until/Since zones require non-constant environments `[y, x, t]` -- cannot be overcome by zone decomposition alone. Each zone still requires expressing quantifier conditions at depth k'+1 with a non-constant 2-variable parent, which is the same gap that motivates the research.

However, the analysis reveals a viable resolution: **enrich the formula to carry x's full NF type AND the M0-witness transfer at the formula level**, rather than at the NF level. The key insight is that `nf_extend_fwd` (KampBypass.lean:33-51) provides cross-structure witness transfer at the right depth, and the formula can be constructed to USE this transfer rather than trying to bypass it.

## Findings

### Finding 1: Precise Zone Decomposition for Until Backward (k>0)

For the Until backward goal at line 356:
```
temporal_truth M atomMap t (compat_disj.untl Formula.top) ->
  exists x, nf_eval_nf M (k'+1+1) (1+1) (Fin.cons x (fun _ => t)) sub_nf
```

After Until extraction, we have x > t with `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x` for some compatible nf_x. The 2-var NF requirement decomposes as:

**Atom part** (SOLVED): follows from nf_x compatibility + h_atoms. Already proved in the forward direction.

**Quantifier part** (THE BLOCKER): for each `ssn : NormalForm sig (k'+1) 3`,
```
(exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn)
  <-> sub_nf.2 ssn = true
```

Decomposing by y's zone relative to x and t (with t < x):

| Zone | Position | y constraint | Environment form |
|------|----------|-------------|-----------------|
| Zone 1 | y < t < x | y < t | `[y, x, t]` non-constant |
| Zone 2 | y = t < x | y = t | `[t, x, t]` non-constant |
| Zone 3 | t < y < x | t < y < x | `[y, x, t]` non-constant |
| Zone 4 | y = x > t | y = x | `[x, x, t]` non-constant |
| Zone 5 | y > x > t | x < y | `[y, x, t]` non-constant |

**Critical observation**: In ALL five zones, the parent environment is `Fin.cons x (fun _ => t)` which is non-constant (x != t in the Until zone). This means `ih_exist` with constant parent `(fun _ => z)` for any single z cannot directly express any of these zones.

### Finding 2: Why Zone-by-Zone ih_exist Fails

Consider Zone 5 (y > x): one might try `ih_exist 2 (by omega) char_k char_k_correct (x_atoms) ssn'` to express "exists y > x with the right type." But:
- `ih_exist` requires `parent_atoms' : AtomKind sig 1 -> Bool` and produces formulas for `exists y, nf_eval M (k'+1) (2+1) (Fin.cons y (fun _ => t')) ssn'`.
- Setting t' = x gives `[y, x, x]`, not `[y, x, t]`.
- Setting t' = t gives `[y, t, t]`, not `[y, x, t]`.
- No choice of constant parent recovers the non-constant env `[y, x, t]`.

This is not a technical limitation but a fundamental mismatch: the NF type of `[y, x, t]` depends on the JOINT configuration of x and t, which no single constant environment can capture.

### Finding 3: The M0 Witness Transfer Strategy (nf_extend_fwd)

The existing `nf_extend_fwd` theorem (KampBypass.lean:33-51) provides:
```
nf_extend_fwd :
  (h : forall nf, nf_eval_nf M (K+1) r eM nf <-> nf_eval_nf N (K+1) r eN nf)
  (c' : N.carrier) ->
  exists c : M.carrier, forall nf,
    nf_eval_nf M K (r+1) (Fin.cons c eM) nf <-> nf_eval_nf N K (r+1) (Fin.cons c' eN) nf
```

**Application to our problem**: We have M0 satisfying sub_nf at `[x0, t0]`. If we could establish depth-(k'+2) arity-1 NF agreement between `(M, fun _ => t)` and `(M0, fun _ => t0)`, then `nf_extend_fwd` with `c' = x0` would give us SOME c in M with depth-(k'+1) arity-2 NF agreement at `[c, t]` and `[x0, t0]`.

**The gap**: This c is existentially chosen by `nf_extend_fwd`, not our specific x. We need x to have the right 2-var NF, not just some c.

### Finding 4: The Correct Formula Enrichment -- Encode 2-var NF Directly

The key realization from the Eq zone proof (KampBypass.lean:376-515) is that the formula can encode BOTH the 1-var type AND the quantifier conditions. The Eq zone works because x = t collapses the env to constant, making ih_exist usable.

For k>0 Until/Since, the formula must be enriched MORE aggressively. Instead of:
```
Until(compat_disj, top)
```
where compat_disj encodes only x's 1-var NF type, the formula must encode the **full 2-var NF type** of `[x, t]`. Specifically, for each candidate 2-var NF type `tau_2 : NormalForm sig (k'+2) 2`, the formula becomes:

```
Disjunction over tau_2 compatible with sub_nf:
  Until(char_kp1(tau_2.1_var_at_x), top)
  AND quant_conj(tau_2)
```

where `quant_conj(tau_2)` encodes, for each ssn:
```
tau_2.2 ssn = true  ->  ih_exist_formula(ssn) at appropriate evaluation point
tau_2.2 ssn = false ->  neg(ih_exist_formula(ssn))
```

**But** this still has the ih_exist constant-parent problem for the ssn formulas.

### Finding 5: The Actual Resolution -- Change ExistPart Itself

After exhaustive analysis across 6 cycles (including this one), the conclusion is definitive:

**The sorry cannot be closed within the current ExistPart framework.** The constant-parent constraint is a fundamental information gap. The correct resolution requires one of:

**(A) Restructure the mutual induction to avoid ExistPart at depth k+1 for n=1 with non-constant environments entirely.** This means changing HOW the bypass formula is constructed and verified.

**(B) Use the classical existence argument more aggressively.** Instead of trying to construct a specific formula and prove it correct backward, use `Classical.choice` to assert that SOME temporal formula exists that distinguishes all 2-var NF types. The existence follows from the completeness of TL(Until, Since) for FOMLO on Prior structures (which is what we're ultimately proving, but at a lower depth).

**(C) Strengthen the IH to carry multi-variable NF transfer.**

### Finding 6: Path B -- Classical Bypass via Depth Induction

The most promising approach leverages the observation that the sorry at `existPart_succ_n1_bypass` only needs `exists A, ...` -- an existential over formulas. The formula A does not need to be explicitly constructed; it suffices to prove existence.

**Key insight**: We already have `nf_extend_fwd/bwd` which transfers witnesses between structures that agree at a HIGHER depth. If we strengthen the inductive hypothesis to carry depth-(k'+3) information (one level higher), the transfer works:

1. At depth k'+3 arity 1, M and M0 agree at `(fun _ => t)` and `(fun _ => t0)`.
2. `nf_extend_fwd` gives SOME c in M with depth-(k'+2) arity-2 agreement at `[c, t]` and `[x0, t0]`.
3. From depth-(k'+2) arity-2 agreement, `nf_extend_fwd` again gives depth-(k'+1) arity-3 agreement, which is exactly the quantifier transfer.

**The problem**: Step 1 requires depth-(k'+3) information, but the IH only gives depth-(k'+2).

**However**: The mutual induction `kamp_mutual_induction` proves `CharPart(k) AND ExistPart(k)` for ALL k. So `CharPart(k'+3)` IS available in the inductive case (it's proved from `CharPart(k'+2) + ExistPart(k'+2)`). The formula `char_{k'+3}(nf_t)` evaluated at t gives depth-(k'+3) 1-var NF information.

**Wait -- this is circular.** To prove `ExistPart(k'+2)`, we need `CharPart(k'+2) + ExistPart(k'+1)`. We're in the case `k = k'+1`, trying to prove `ExistPart(k'+2)`. The IH gives `CharPart(k'+1) + ExistPart(k'+1)`, and `CharPart(k'+2)` is derived from these. But `CharPart(k'+3)` requires `ExistPart(k'+2)` -- which is what we're proving. So depth-(k'+3) is NOT available.

### Finding 7: The Formula IS Already Strong Enough -- M0 Transfer IS the Proof

Re-examining the sorry goal more carefully. The current code has:

1. M0 witnesses sub_nf at `[x0, t0]` with h_atoms0 matching parent_atoms.
2. The Until formula gives x > t with some compatible nf_x type: `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x`.
3. `compat_of_eval M t x h_eval` would give `compat_check nf_x = true` IF we had h_eval (circular).

The current formula `Until(compat_disj, top)` gives us x with `temporal_truth M atomMap x compat_disj`, from which we extract that M satisfies `char_kp1(nf_x)` at x for some compatible nf_x, giving `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x`.

**The M0 transfer approach**: We need `nf_eval_nf M (k'+2) 2 [x, t] sub_nf`. We KNOW M0 satisfies it at `[x0, t0]`. The question is whether M also satisfies it at `[x, t]`.

From `h_atoms` and `h_atoms0`, M and M0 agree on parent_atoms at t and t0. From `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x`, we know x's 1-var type. But as established, 1-var types at x and t separately do NOT determine the 2-var type at `[x, t]`.

**However**: We DON'T need M and M0 to have the same 2-var type. We need M to satisfy SUB_NF specifically. Since M0 satisfies sub_nf, and sub_nf is a FIXED NF determined by the theorem statement, we can ask: does every Prior structure M with a compatible x > t satisfy sub_nf at `[x, t]`?

Answer: NO. The NfComposition.lean counterexample shows this is false. Two elements with the same 1-var NF type can have different 2-var NF types.

### Finding 8: The Enriched Formula Must Encode Quantifier Conditions Directly

The ONLY path that works is to encode the quantifier conditions in the formula itself, exactly as the Eq zone does. For k>0, this means the Until formula cannot be `Until(compat_disj, top)` but must include quantifier information.

**The correct enrichment for the Until zone (k>0)**:

Replace the current formula construction (KampBypass.lean:353):
```
Formula.untl compat_disj Formula.top
```

With an enriched formula that, like the Eq zone's `eq_formula = compat_disj AND quant_conj`, encodes quantifier conditions. The quant_conj must express `sub_nf.2 ssn` for each ssn using temporal formulas.

**For each ssn : NormalForm sig (k'+1) 3**, the condition `exists y, nf_eval_nf M (k'+1) 3 [y, x, t] ssn` involves a non-constant parent `[x, t]`. But at the FORMULA level (not the NF level), we can express this as a temporal formula evaluated at x and t via nested Until/Since.

**Using ih_exist at arity n=2**: `ih_exist 2 (by omega) char_k char_k_correct parent_atoms' ssn` gives a formula for `exists y, nf_eval M (k'+1) 3 (Fin.cons y (fun _ => t')) ssn` with constant parent `(fun _ => t')`.

Setting parent_atoms' to encode x's predicates and t' = x:
```
exists y, nf_eval M (k'+1) 3 (Fin.cons y (fun _ => x)) ssn_x
```
This is `[y, x, x]`, not `[y, x, t]`.

**But**: if ssn has ssn(.pred p 1) = ssn(.pred p 2) for all p (i.e., variables 1 and 2 have the same predicates), then `[y, x, x]` and `[y, x, t]` would give the same NF evaluation when x and t have the same predicates. But they don't necessarily have the same predicates.

### Finding 9: Resolution -- Require Separate ih_exist Calls per Variable Assignment

The true resolution requires ih_exist to be called with a parent that matches BOTH x's atoms AND t's atoms simultaneously. This is impossible with a constant parent `(fun _ => z)` because z can only match ONE set of atoms.

**The fix**: Extend ExistPart to support arity-r parent environments, not just constant ones. This is the ExistPart_r approach from the previous research -- but modified to avoid the counterexample.

The counterexample shows ExistPart_r fails when parameterized by parent NF TYPES (because same 1-var NF types don't determine multi-var NF types). However, ExistPart_r succeeds when parameterized by the FORMULA EVALUATION CONTEXT rather than NF types.

Specifically, the formula can be:
```
For each 2-var NF type tau : NormalForm sig (k'+2) 2:
  if tau == sub_nf:
    let A_tau = formula_for_tau  -- encodes "there exist [x, t] with this 2-var type"
    then A_tau
```

But `formula_for_tau` expressing "exists x, nf_eval_nf M (k'+2) 2 [x, t] tau" is EXACTLY the goal statement. This is circular.

### Finding 10: The CORRECT Solution -- Direct Cross-Structure Transfer Without NF Identity

After this exhaustive analysis, the correct approach emerges:

**Observation**: The backward goal doesn't need to show that x has the same 2-var NF as x0 in M0. It needs to show that the SPECIFIC sub_nf holds at [x, t] in M. These are different claims.

The proof should work as follows:
1. From the formula, extract x > t with nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x.
2. Build nf_eval_nf M (k'+2) 2 [x, t] sub_nf by:
   a. Atom part: from nf_x compatibility + h_atoms (DONE in current code).
   b. Quantifier part: for each ssn, need `(exists y, nf_eval M (k'+1) 3 [y, x, t] ssn) <-> sub_nf.2 ssn`.

For the quantifier part, the -> direction (exists y -> sub_nf.2 ssn = true) is the HARD part. The <- direction (sub_nf.2 ssn = true -> exists y) can use the M0 witness:
- sub_nf.2 ssn = true means M0 has y0 with nf_eval M0 (k'+1) 3 [y0, x0, t0] ssn.
- We need to transfer this to M.

**For the <- direction using `nf_extend_fwd`**:
- From h_atoms and h_atoms0: M at (fun _ => t) and M0 at (fun _ => t0) agree on depth-(k'+2) 1-var NF (via char_kp1_correct and the classical satisfiability case).

Wait -- do they? h_atoms gives `atom_eval M (fun _ => t) a <-> parent_atoms a = true` -- this is only DEPTH 0 atom information. We need depth-(k'+2) 1-var NF agreement, which requires quantifier information too.

**This is the depth gap again.** parent_atoms gives depth 0. char_kp1_correct gives depth k'+2 = depth k'+2, but only for specific NFs, not full agreement.

However: in the compat_disj extraction, we get `char_kp1(nf_x_candidate)` holds at x, from which `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x_candidate`. And from the classical satisfiability case, nf_x_candidate has the same atom part as sub_nf at variable 0.

**The enrichment needed**: Include `char_kp1(nf_t)` in the formula, where nf_t is the depth-(k'+2) 1-var NF of t. Since the formula is evaluated at t, char_kp1(nf_t) can be checked at t. If we know t's FULL depth-(k'+2) 1-var NF type (not just atoms), we can establish depth-(k'+1) 2-var NF agreement between (M, [c, t]) and (M0, [x0, t0]) via nf_extend_fwd.

**Updated formula construction for Until zone (k>0)**:

For each pair (nf_x, nf_t) of depth-(k'+2) 1-var NF types with:
- nf_x atom-compatible with sub_nf at variable 0
- nf_t atom-matching parent_atoms
- nf_t matching t's actual depth-(k'+2) 1-var NF (checked via char_kp1(nf_t) at t)

The formula is:
```
char_kp1(nf_t) AND Until(char_kp1(nf_x) AND quant_transfer_conj(nf_x, nf_t), top)
```

where `quant_transfer_conj(nf_x, nf_t)` is built using the M0 witness: for each ssn, the truth value `sub_nf.2 ssn` is fixed, and we need a temporal formula at x that confirms/denies the existential.

**The issue remains**: quant_transfer_conj needs to express the 3-var existential at `[y, x, t]`, which is the original problem.

**HOWEVER**: With BOTH nf_x AND nf_t's full depth-(k'+2) 1-var NF types known, `nf_extend_fwd` applied twice gives depth-(k'+1) 2-var NF agreement between M and M0. Then nf_extend_fwd a third time gives depth-k' 3-var NF agreement, which transfers the quantifier conditions.

Let me verify this chain:
1. nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t -- from char_kp1(nf_t) at t
2. nf_eval_nf M0 (k'+2) 1 (fun _ => t0) nf_t -- from h_eval0 + nf_1var_from_2var_agree (extracting t0's NF from the 2-var NF)
3. These give depth-(k'+2) 1-var agreement: forall nf, nf_eval M (k'+2) 1 (fun _ => t) nf <-> nf_eval M0 (k'+2) 1 (fun _ => t0) nf
4. nf_extend_fwd with c' = x0: exists c in M with depth-(k'+1) 2-var agreement at [c, t] and [x0, t0]
5. The c from step 4 satisfies nf_eval_nf M (k'+1) 2 [c, t] (nf_characteristic M0 (k'+1) 2 [x0, t0])
6. nf_extend_fwd on this 2-var agreement with any y0: exists y in M with depth-k' 3-var agreement at [y, c, t] and [y0, x0, t0]

**Problem**: c != x. We need the quantifier conditions at [y, x, t], not [y, c, t].

**Solution within the enriched formula**: The formula doesn't assert things about x directly; it asserts things at temporal positions. From the formula at x, we have char_kp1(nf_x). From the formula at t, we have char_kp1(nf_t). The question is whether we can build a temporal formula whose truth at t entails `exists x, nf_eval_nf M (k'+2) 2 [x, t] sub_nf` on Prior structures.

**The cleanest resolution**: Use the M0 transfer with `exist_transfer_const_env` at the RIGHT depth.

From KampBypass.lean:77-92, `exist_transfer_const_env` gives:
```
h_agree : forall nf, nf_eval M (K+1) 1 (fun _ => t) nf <-> nf_eval N (K+1) 1 (fun _ => s) nf
ssn : NormalForm sig K 2
-> (exists y, nf_eval M K 2 (Fin.cons y (fun _ => t)) ssn) <->
   (exists y, nf_eval N K 2 (Fin.cons y (fun _ => s)) ssn)
```

Apply with K = k'+2, M = M, N = M0, t = t, s = t0:
```
h_agree : forall nf, nf_eval M (k'+3) 1 (fun _ => t) nf <-> nf_eval M0 (k'+3) 1 (fun _ => t0) nf
-> (exists x, nf_eval M (k'+2) 2 (Fin.cons x (fun _ => t)) sub_nf) <->
   (exists x, nf_eval M0 (k'+2) 2 (Fin.cons x (fun _ => t0)) sub_nf)
```

This transfers the ENTIRE 2-var existential! M0 has x0 satisfying sub_nf, so the M side also has some x satisfying sub_nf.

**THE DEPTH GAP**: This requires depth-(k'+3) = depth-(k+2) agreement. We have char_kp1 at depth k'+2 = k+1. We need one level HIGHER.

**Using CharPart at depth k+2**: The mutual induction at step k+1 has:
- CharPart(k+1) available (proved from CharPart(k) + ExistPart(k))
- ExistPart(k+1) is what we're proving

CharPart(k+1) gives char formulas at depth k+1 = k'+2. We need depth k'+3 = k+2.
CharPart(k+2) is NOT available (it requires ExistPart(k+1) which we're proving).

**Conclusion**: The depth gap is inherent. exist_transfer_const_env at the right depth needs one more level than available.

### Finding 11: The Viable Path -- Change Formula to Use ih_exist Differently

Going back to the structure of the problem. The current formula is:
```
Until(compat_disj, top)
```

This only encodes x's 1-var NF type. The Eq zone formula is:
```
compat_disj AND quant_conj
```

where quant_conj uses `ih_exist 2 (by omega) char_k char_k_correct parent_atoms ssn` to encode each 3-var existential as a temporal formula at t.

The Eq zone works because x = t, so `[y, x, t] = [y, t, t] = Fin.cons y (fun _ => t)`, which is exactly what ih_exist handles.

For Until/Since zones, x != t, so `[y, x, t]` is NOT `Fin.cons y (fun _ => z)` for any z. However:

**Sub-observation**: The quantifier condition `exists y, nf_eval M (k'+1) 3 [y, x, t] ssn` involves ssn at depth k'+1 with arity 3. At arity 3, the environment has three distinguished elements: y, x, t.

The ih_exist at n=2 gives formulas for `exists y, nf_eval M (k'+1) 3 (Fin.cons y (fun _ => t)) ssn` = `exists y, nf_eval M (k'+1) 3 [y, t, t] ssn`.

**The question**: Is `[y, x, t]` with specific ssn related to `[y, t, t]` or `[y, x, x]` with DIFFERENT ssn?

Yes -- via ssn manipulation. If ssn' is obtained from ssn by "collapsing" variables 1 and 2 (setting all order relations between them to equality), then nf_eval at `[y, t, t]` with ssn' might be related to nf_eval at `[y, x, t]` with ssn.

But this is ad hoc and doesn't work in general. The 3-var NF type at `[y, x, t]` encodes order relationships between all three pairs (y-x, y-t, x-t) and quantifier conditions about 4-element tuples. Collapsing variables loses information.

### Finding 12: The Final Assessment

After exhaustive analysis across all approaches:

**The sorry at KampBypass.lean:356/368 CANNOT be closed by changing only the PROOF of the backward direction.** The formula `Until(compat_disj, top)` is fundamentally too weak -- it does not encode enough information to reconstruct the 2-var NF.

**The fix must change the FORMULA CONSTRUCTION** (the `refine` at line 353). The enriched formula must encode quantifier conditions. The challenge is that the available IH (`ih_exist`) only handles constant parents.

**Two viable approaches remain**:

**Approach 1: Strengthen the mutual induction** to include a higher-arity ExistPart or a cross-structure transfer theorem. This requires modifying `KampMutualInduction.lean` and potentially `existPart_succ`.

**Approach 2: Use the nf_extend_fwd chain within the satisfiable branch.** Instead of using the simple formula `Until(compat_disj, top)`, use `exist_transfer_const_env` at the available depth. This trades the specific witness x for an EXISTENTIALLY CHOSEN witness c that has the correct 2-var NF by construction. The formula becomes:

```
-- For the satisfiable case, use exist_transfer_const_env:
-- M and M0 agree at depth k'+2 arity 1 (from char_kp1 matching)
-- => (exists x, nf_eval M (k'+1) 2 [x, t] sub_nf') <->
--    (exists x0, nf_eval M0 (k'+1) 2 [x0, t0] sub_nf')
-- for sub_nf' at depth k'+1, NOT k'+2.
```

**Wait** -- this transfers at depth k'+1, not k'+2. The sub_nf is at depth k'+2. So this transfers existentials of depth-(k'+1) 2-var NFs, not depth-(k'+2) ones.

exist_transfer_const_env at K = k'+1:
```
h_agree : depth-(k'+2) 1-var agreement
=> (exists x, nf_eval M (k'+1) 2 [x, t] ssn) <-> (exists x0, nf_eval M0 (k'+1) 2 [x0, t0] ssn)
```

This transfers at depth k'+1, arity 2. But our sub_nf is at depth k'+2, arity 2. The atom part is at depth k'+2 and the quantifier part involves depth-(k'+1) arity-3 NFs.

**Actually**: `nf_eval_nf M (k'+2) 2 [x, t] sub_nf` decomposes as:
```
(forall a, atom_eval M [x,t] a <-> sub_nf.1 a) AND
(forall ssn, (exists y, nf_eval M (k'+1) 3 [y,x,t] ssn) <-> sub_nf.2 ssn)
```

The quantifier part involves depth-(k'+1) arity-3 existentials. Using exist_transfer_const_env at K = k'+1 with arity 2 transfers depth-(k'+1) arity-2 existentials between constant-env structures -- NOT arity-3.

**Approach 3 (NEW): Use nf_extend_fwd in the backward direction proof directly.**

Instead of trying to show x has sub_nf, show:
1. M and M0 agree at depth-(k'+2) arity-1 at (fun _ => t) and (fun _ => t0). [From char_kp1 matching -- but wait, we need this to be provable from the formula. The formula char_kp1(nf_t0) at t gives nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t0.]
2. nf_extend_fwd: for x0 in M0, exists c in M with depth-(k'+1) arity-2 agreement at [c, t] and [x0, t0].
3. This c satisfies sub_nf (since x0 does and they have the same 2-var NF type at depth k'+1).

**But** sub_nf is at depth k'+2, not k'+1. Step 3 is wrong: depth-(k'+1) arity-2 agreement does NOT imply same depth-(k'+2) arity-2 NF. It implies same depth-(k'+1) arity-2 NF.

Actually, let me reconsider. `nf_eval_nf M (k'+2) 2 [x, t] sub_nf` where sub_nf : NormalForm sig (k'+2) 2 = (AtomKind sig 2 -> Bool) x (NormalForm sig (k'+1) 3 -> Bool).

The atom part is at depth 0 (just atom evaluation). The quantifier part is at depth k'+1. So "nf_eval_nf at depth k'+2 arity 2" is really "atoms match AND depth-(k'+1) arity-3 quantifier conditions match."

From nf_extend_fwd at K = k'+1, we get depth-(k'+1) arity-2 agreement. This means:
```
forall nf : NormalForm sig (k'+1) 2,
  nf_eval_nf M (k'+1) 2 [c, t] nf <-> nf_eval_nf M0 (k'+1) 2 [x0, t0] nf
```

This does NOT directly give us nf_eval_nf M (k'+2) 2 [c, t] sub_nf, because that would require:
- Atoms at [c, t] match sub_nf.1 (separate from the arity-2 NF agreement)
- Depth-(k'+1) arity-3 quantifier transfer (follows from depth-(k'+1) arity-2 agreement)

The atom part: sub_nf.1 at variable 0 matches nf_x (from compat_check). We need c to have the same atoms as x0. From depth-(k'+1) arity-2 agreement and nf_drop_last, c and x0 have the same depth-(k'+1) arity-1 NF. At depth k'+1 >= 2, this includes depth-0 atoms. So c has the same predicates as x0.

The quantifier part: depth-(k'+1) arity-2 agreement between [c, t] and [x0, t0] means:
```
forall nf : NormalForm sig (k'+1) 2,
  nf_eval_nf M (k'+1) 2 [c, t] nf <-> nf_eval_nf M0 (k'+1) 2 [x0, t0] nf
```

But we need:
```
forall ssn : NormalForm sig (k'+1) 3,
  (exists y, nf_eval_nf M (k'+1) 3 [y, c, t] ssn) <-> (exists y0, nf_eval_nf M0 (k'+1) 3 [y0, x0, t0] ssn)
```

This is nf_extend_fwd/bwd applied to the depth-(k'+1) arity-2 agreement! Specifically:
- From `forall nf, nf_eval M (k'+1) 2 [c, t] nf <-> nf_eval M0 (k'+1) 2 [x0, t0] nf`
- nf_extend_fwd at K = k', r = 2: for y0, exists y with depth-k' arity-3 agreement.

**But** we need depth-(k'+1) arity-3 agreement (to transfer nf_eval_nf at depth k'+1), not depth-k'. nf_extend_fwd drops one depth level.

**The chain**:
- depth-(k'+2) arity-1 agreement (from char_kp1 matching at t)
- nf_extend_fwd -> depth-(k'+1) arity-2 agreement at [c, t] and [x0, t0]
- This gives: `forall nf, nf_eval M (k'+1) 2 [c, t] nf <-> nf_eval M0 (k'+1) 2 [x0, t0] nf`

Now, `nf_eval_nf M (k'+2) 2 [c, t] sub_nf` decomposes as:
- (a) Atom part: `forall a, atom_eval M [c, t] a <-> sub_nf.1 a`
- (b) Quantifier part: `forall ssn, (exists y, nf_eval M (k'+1) 3 [y, c, t] ssn) <-> sub_nf.2 ssn`

For (a): From depth-(k'+1) arity-2 agreement and nf_drop_last, c and x0 have the same depth-(k'+1) arity-1 NF. Since k'+1 >= 1, this gives the same predicates. Combined with h_atoms matching parent_atoms, the atom part follows.

For (b): We need `(exists y, nf_eval M (k'+1) 3 [y, c, t] ssn) <-> sub_nf.2 ssn`. Since M0 satisfies sub_nf at [x0, t0]:
- `(exists y0, nf_eval M0 (k'+1) 3 [y0, x0, t0] ssn) <-> sub_nf.2 ssn`

So we need: `(exists y, nf_eval M (k'+1) 3 [y, c, t] ssn) <-> (exists y0, nf_eval M0 (k'+1) 3 [y0, x0, t0] ssn)`.

From the depth-(k'+1) arity-2 agreement:
```
forall nf : NormalForm sig (k'+1) 2, nf_eval M (k'+1) 2 [c, t] nf <-> nf_eval M0 (k'+1) 2 [x0, t0] nf
```

Apply intra_structure_extend (or nf_extend_fwd between M and M0):
- For y0 in M0: exists y in M with `forall nf, nf_eval M k' 3 [y, c, t] nf <-> nf_eval M0 k' 3 [y0, x0, t0] nf`

This is depth-k' arity-3 agreement, but we need depth-(k'+1) arity-3 NF evaluation.

**The quantifier condition is**: `nf_eval_nf M (k'+1) 3 [y, c, t] ssn` which decomposes as atoms + depth-k' arity-4 quantifiers. The depth-k' arity-3 agreement from nf_extend_fwd gives us enough to transfer the arity-3 NF evaluation at depth k' (which is the quantifier part of the depth-(k'+1) arity-3 evaluation). Combined with atom transfer, we get the full transfer.

**THIS WORKS!** Let me verify:

`nf_eval_nf M (k'+1) 3 [y, c, t] ssn` = `(forall a, atom_eval M [y,c,t] a <-> ssn.1 a) AND (forall chi, (exists w, nf_eval M k' 4 [w,y,c,t] chi) <-> ssn.2 chi)`.

From depth-k' arity-3 agreement between [y, c, t] and [y0, x0, t0]:
- Atoms at [y, c, t] match atoms at [y0, x0, t0] (immediate from depth-k' agreement via nf_drop_last)
- `(exists w, nf_eval M (k'-1) 4 [w,y,c,t] chi) <-> (exists w0, nf_eval M0 (k'-1) 4 [w0,y0,x0,t0] chi)` (from nf_extend_fwd/bwd on the depth-k' arity-3 agreement)

**Wait**: ssn.1 is at depth 0 (atoms), and ssn.2 involves depth-k' NFs. The depth-k' arity-3 agreement gives `forall nf : NormalForm sig k' 3, nf_eval M k' 3 [y,c,t] nf <-> nf_eval M0 k' 3 [y0,x0,t0] nf`. This means the depth-k' arity-3 NFs match. Since `nf_eval_nf M (k'+1) 3 ssn` = atoms match ssn.1 AND `forall chi, ... <-> ssn.2 chi`, we need:

1. atoms match: From depth-k' arity-3 agreement and k' >= 1, atoms are transferred (nf_drop_last gives depth-0 atom agreement). Actually, depth-k' agreement directly implies atom agreement (trivially for k'=0 since depth-0 NF IS the atom function, and for k'>0 via the atom component of nf_eval_nf).

2. quantifier conditions match: `(exists w, nf_eval M k' 4 [w,y,c,t] chi) <-> (exists w0, nf_eval M0 k' 4 [w0,y0,x0,t0] chi)`. This follows from nf_extend_fwd/bwd applied to the depth-k' arity-3 agreement.

Actually, nf_eval_nf M (k'+1) 3 [y,c,t] ssn is:
```
(forall a, atom_eval M [y,c,t] a <-> ssn.1 a)
AND
(forall chi : NormalForm sig k' 4, (exists w, nf_eval M k' 4 [w,y,c,t] chi) <-> ssn.2 chi)
```

From depth-k' arity-3 NF agreement between [y,c,t] and [y0,x0,t0]:
```
forall nf : NormalForm sig k' 3, nf_eval M k' 3 [y,c,t] nf <-> nf_eval M0 k' 3 [y0,x0,t0] nf
```

This gives nf_characteristic M k' 3 [y,c,t] = nf_characteristic M0 k' 3 [y0,x0,t0].

Now, nf_eval_nf M (k'+1) 3 [y,c,t] ssn requires:
- atoms of [y,c,t] match ssn.1
- quantifier conditions at depth k'

The atoms: Since depth-k' NFs agree, the atom components agree (nf_characteristic at depth k' arity 3 encodes atoms for k'=0, and for k'>0 the atom part is the first component).

The quantifier conditions: `(exists w, nf_eval M k' 4 [w,y,c,t] chi) <-> ssn.2 chi`. From the NF agreement and the definition of nf_eval at depth k'+1 applied to the characteristic NF:
```
nf_eval_nf M (k'+1) 3 [y,c,t] (nf_characteristic M (k'+1) 3 [y,c,t])
```
The quantifier part says `(exists w, nf_eval M k' 4 [w,y,c,t] chi) <-> (nf_characteristic M (k'+1) 3 [y,c,t]).2 chi`.

Similarly for M0. Since depth-k' arity-3 NFs agree, we have:
```
nf_characteristic M k' 3 [y,c,t] = nf_characteristic M0 k' 3 [y0,x0,t0]
```

But nf_characteristic at depth k'+1 arity 3 involves BOTH the depth-0 atom part AND the depth-k' quantifier part. The depth-k' arity-3 agreement gives the depth-k' NF equality, but the depth-(k'+1) NF requires additional information (the depth-k' quantifier conditions, which are the quantifier part of the depth-(k'+1) characteristic).

From nf_agreement_from_shared_nf applied to the depth-k' shared NF:
```
forall nf : NormalForm sig (k'+1) 3,
  nf_eval_nf M (k'+1) 3 [y,c,t] nf <-> nf_eval_nf M0 (k'+1) 3 [y0,x0,t0] nf
```

**Wait** -- `nf_agreement_from_shared_nf` gives agreement at ALL depths <= k', not at depth k'+1. Let me check.

Actually, `nf_agreement_from_shared_nf` gives:
```
forall nf : NormalForm sig k' 3,
  nf_eval_nf M k' 3 [y,c,t] nf <-> nf_eval_nf M0 k' 3 [y0,x0,t0] nf
```

This is depth-k' agreement, from which we can derive depth-j agreement for all j <= k' via nf_agreement_monotone. But we need depth-(k'+1) agreement to transfer the quantifier conditions of ssn (which are at depth k').

From depth-k' arity-3 agreement, we get:
```
nf_characteristic M k' 3 [y,c,t] = nf_characteristic M0 k' 3 [y0,x0,t0]
```

This means both envs satisfy the same depth-k' arity-3 NF. The depth-(k'+1) arity-3 NF is (atoms, quantifier_fn) where atoms are depth-0 and quantifier_fn is at depth k'.

The depth-(k'+1) characteristic:
```
nf_characteristic M (k'+1) 3 [y,c,t] = (atom_fn, quant_fn)
where atom_fn a = decide (atom_eval M [y,c,t] a)
and quant_fn chi = decide (exists w, nf_eval M k' 4 [w,y,c,t] chi)
```

For the quantifier part: `(exists w, nf_eval M k' 4 [w,y,c,t] chi)` <-> `(exists w0, nf_eval M0 k' 4 [w0,y0,x0,t0] chi)` follows from nf_extend_fwd/bwd applied to the depth-k' arity-3 agreement.

So quant_fn is the same for M and M0. And atom_fn is the same (from depth-k' agreement giving depth-0 atom agreement). Therefore:

```
nf_characteristic M (k'+1) 3 [y,c,t] = nf_characteristic M0 (k'+1) 3 [y0,x0,t0]
```

**This gives depth-(k'+1) arity-3 NF agreement!** And since M0 satisfies ssn at [y0, x0, t0] (from h_eval0's quantifier part), M also satisfies ssn at [y, c, t].

**THE CHAIN IS COMPLETE:**

1. depth-(k'+2) arity-1 agreement at (M, fun _ => t) and (M0, fun _ => t0) [from nf_t matching]
2. nf_extend_fwd -> depth-(k'+1) arity-2 agreement at [c, t] and [x0, t0] [c existentially chosen]
3. For each ssn with sub_nf.2 ssn = true: M0 has y0. nf_extend_fwd on step 2 -> depth-k' arity-3 agreement at [y, c, t] and [y0, x0, t0] [y existentially chosen]
4. From step 3: depth-(k'+1) arity-3 agreement (lifting by showing atoms and quantifiers match)
5. M0 satisfies ssn at [y0, x0, t0] -> M satisfies ssn at [y, c, t]

6. For each ssn with sub_nf.2 ssn = false: M0 has NO y0. By contraposition using nf_extend_bwd from step 2, M has no y either.

7. Atom part: c has the same predicates as x0 (from step 2 + nf_drop_last), and t has parent_atoms (from h_atoms). Since x0 and t0 satisfy sub_nf.1, and c/t have matching atoms, c/t also satisfy sub_nf.1.

**THE WITNESS IS c, NOT x.** The formula gives x, but the proof uses c (existentially chosen by nf_extend_fwd). The formula `Until(compat_disj, top)` asserts there exists x > t with compat_disj. The proof shows the EXISTENCE of a c satisfying sub_nf, but c might not be x.

**Resolution**: The backward direction doesn't need to show that the SPECIFIC x from the Until formula satisfies sub_nf. It needs to show `exists x, nf_eval_nf M (k'+2) 2 [x, t] sub_nf`. The c from nf_extend_fwd IS a valid witness.

**BUT**: does c satisfy t < c? From step 2, c and x0 have the same depth-(k'+1) arity-2 NF at [c, t] and [x0, t0]. Since x0 > t0 (from h_eval0 and h_gt_val), the order atom (.order 1 0) = true in the 2-var NF. From NF agreement, this atom also holds at [c, t], meaning t < c.

**This approach works and does NOT require changing the formula or ExistPart.** The proof of the backward direction at lines 356/368 can be closed using the EXISTING infrastructure:

1. Extract x from Until(compat_disj, top) to get x > t with char_kp1(nf_x) at x.
2. From nf_x compatibility and parent_atoms, establish that M and M0 share 1-var NF types at t and t0.
3. Actually, step 2 requires t's FULL depth-(k'+2) NF type, not just atoms. This needs enrichment.

**WAIT**: h_atoms gives only depth-0 atom information about t. We need depth-(k'+2) 1-var NF agreement between (M, fun _ => t) and (M0, fun _ => t0).

From h_atoms: `forall a : AtomKind sig 1, atom_eval M (fun _ => t) a <-> parent_atoms a = true`.
From h_atoms0: `forall a : AtomKind sig 1, atom_eval M0 (fun _ => t0) a <-> parent_atoms a = true`.

This gives atom agreement. But depth-(k'+2) 1-var NF agreement requires quantifier agreement at depth k'+1.

**The missing link**: We need `nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t0 <-> nf_eval_nf M0 (k'+2) 1 (fun _ => t0) nf_t0` for all nf_t0. This is NOT implied by atom agreement alone.

**This brings us back to the enrichment**: The formula MUST include char_kp1(nf_t) at t, where nf_t is the characteristic NF of t0 in M0. From char_kp1 correctness, char_kp1(nf_t0) at t gives nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t0. Combined with M0's satisfaction, this gives depth-(k'+2) 1-var NF agreement by nf_agreement_from_shared_nf.

**ENRICHED FORMULA (FINAL)**:

For the satisfiable branch of the Until zone (k>0), replace:
```lean
Formula.untl compat_disj Formula.top
```
with:
```lean
Formula.and (char_kp1 nf_t0) (Formula.untl compat_disj Formula.top)
```
where `nf_t0 := nf_characteristic M0 (k'+2) 1 (fun _ => t0)`.

Since nf_t0 is determined by M0 and t0 (which are fixed in the satisfiable branch via Classical.em), this is a fixed formula. At t, char_kp1(nf_t0) evaluates to `nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t0`, establishing M and M0 agree on t's NF type.

**Backward proof using the enriched formula**:
1. Extract char_kp1(nf_t0) at t -> nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t0
2. M0 satisfies nf_t0 at t0 -> nf_agreement: forall nf, nf_eval M (k'+2) 1 (fun _ => t) nf <-> nf_eval M0 (k'+2) 1 (fun _ => t0) nf
3. nf_extend_fwd with c' = x0 -> exists c in M with depth-(k'+1) 2-var agreement at [c, t] and [x0, t0]
4. From 2-var agreement + atom check: nf_eval_nf M (k'+2) 2 [c, t] sub_nf (via the chain above)
5. t < c (from order atom in the 2-var NF agreement + h_gt_val)
6. Produce witness c.

**Forward proof using the enriched formula**:
1. Given x with nf_eval_nf M (k'+2) 2 [x, t] sub_nf and h_atoms:
2. char_kp1(nf_t0) at t: need nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t0.
   - From the satisfiable case, M0/t0/x0/h_eval0/h_atoms0 are fixed.
   - nf_t0 = nf_characteristic M0 (k'+2) 1 (fun _ => t0).
   - h_atoms + h_atoms0 give atom agreement at t and t0.
   - Need: the FULL depth-(k'+2) 1-var NF of t equals nf_t0.
   - **This is NOT guaranteed by atom agreement alone!** t in M might have different depth-(k'+2) 1-var NF than t0 in M0.

**FORWARD DIRECTION FAILS**: char_kp1(nf_t0) at t requires t to have the same full NF type as t0. But h_atoms only gives atom agreement, not full NF agreement.

**Fix for forward direction**: Include `h_atoms` check as a PRECONDITION. The formula already has `h_atoms` as a precondition via the existPart_succ_n1_bypass signature:
```
(forall a, atom_eval M (fun _ => t) a <-> parent_atoms a = true) ->
  (temporal_truth M atomMap t A <-> exists x, ...)
```

So the formula A only needs to be correct WHEN h_atoms holds. This means we can include char_kp1(nf_t0) in A, and if M's t doesn't satisfy it, the forward direction is vacuously true (the biconditional holds trivially because the formula is false and the existential might or might not hold -- but actually we need the biconditional, not just implication).

**The biconditional requires both directions to be correct.** If char_kp1(nf_t0) is false at t, then A is false, but there might still exist x with sub_nf satisfied. So the biconditional fails.

**This means char_kp1(nf_t0) must be TRUE at all t satisfying h_atoms.** Is this the case?

Not necessarily. parent_atoms only constrains depth-0 atoms. Two t's with the same atoms but different quantifier structure would have different depth-(k'+2) 1-var NFs.

**Further enrichment needed**: The formula must be a DISJUNCTION over all possible nf_t types (depth-(k'+2) 1-var NFs) that are compatible with parent_atoms:

```lean
formula_disjList [for nf_t compatible with parent_atoms:
  Formula.and (char_kp1 nf_t) (Formula.untl compat_disj_for_nf_t Formula.top)]
```

where compat_disj_for_nf_t filters nf_x candidates based on the fixed nf_t.

**But**: Which nf_t values are "compatible with parent_atoms"? A depth-(k'+2) 1-var NF nf_t is compatible if nf_t.1(.pred p 0) = parent_atoms(.pred p 0) for all p. This is a finite disjunction.

**For the forward direction**: Given x with h_eval and h_atoms, we know t's NF type nf_t = nf_characteristic M (k'+2) 1 (fun _ => t). This nf_t is compatible with parent_atoms (by h_atoms). So the disjunct for this nf_t is in the list, and char_kp1(nf_t) holds at t (by char_kp1_correct). Also, compat_disj holds at x (same argument as current forward direction).

**For the backward direction**: We get some nf_t disjunct with char_kp1(nf_t) at t and Until(compat_disj_for_nf_t, top). From char_kp1(nf_t) at t, we get nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t. Then:
- Does M0 also satisfy nf_t at t0? Not necessarily for arbitrary nf_t. But nf_t0 (the characteristic of t0 in M0) is one of the compatible disjuncts. For the backward direction, we need to handle ANY compatible nf_t, not just nf_t0.
- **Key**: For each nf_t, the satisfiability case must be checked. If there exists M0, t0, x0 with h_eval0 AND nf_eval_nf M0 (k'+2) 1 (fun _ => t0) nf_t, then the transfer works. If no such M0 exists, the formula for this nf_t disjunct should be bot (unsatisfiable).

**Refined formula construction**:

```
Disjunction over nf_t : NormalForm sig (k'+2) 1 with nf_t.atom_compat(parent_atoms):
  if (exists M0 h_UZ h_SZ t0 x0, nf_eval M0 (k'+2) 2 [x0, t0] sub_nf
      AND nf_eval M0 (k'+2) 1 (fun _ => t0) nf_t
      AND h_atoms0):
    let nf_t0_witness = Classical.choose ...
    Formula.and (char_kp1 nf_t) (Formula.untl compat_disj_nf_t Formula.top)
  else:
    Formula.bot
```

For the satisfiable disjuncts, the backward direction uses the M0 witness with matching nf_t to establish depth-(k'+2) 1-var NF agreement at t, then nf_extend_fwd for the rest.

**This works!** The implementation requires:
1. Adding char_kp1(nf_t) to the formula for each nf_t disjunct (~20 lines)
2. Using Classical.em for M0 witness existence per nf_t (~10 lines per disjunct)
3. The nf_extend_fwd chain for the backward proof (~100-150 lines)
4. Adapting the forward direction (straightforward -- the extra char_kp1(nf_t) holds trivially)

**Estimated total: 200-300 lines per zone (Until + Since), total ~500-600 lines.**

## Adversarial Self-Verification (H4)

### Challenged Claims

1. **Claim**: "nf_extend_fwd gives depth-(k'+1) arity-2 agreement at [c, t] and [x0, t0]."
   **Verification**: nf_extend_fwd signature requires depth-(K+1) arity-r agreement as input and produces depth-K arity-(r+1) agreement. With K = k'+1, r = 1: depth-(k'+2) arity-1 agreement -> depth-(k'+1) arity-2 agreement. VERIFIED.

2. **Claim**: "Depth-k' arity-3 agreement lifts to depth-(k'+1) arity-3 agreement."
   **Verification**: NOT directly from nf_agreement_from_shared_nf or nf_agreement_monotone (those go from higher to lower depth, not lower to higher). However, the argument shows that atoms AND quantifier conditions match separately. Atoms match because depth-k' agreement implies depth-0 atom agreement. Quantifier conditions match because nf_extend_fwd/bwd on depth-k' arity-3 agreement transfers depth-(k'-1) arity-4 existentials. The combined atom + quantifier match gives depth-(k'+1) arity-3 NF equality via nf_eval_unique. **VERIFIED** (requires explicit proof, ~30 lines).

3. **Claim**: "The forward direction is straightforward with the enriched formula."
   **Verification**: Forward direction needs char_kp1(nf_t) true at t. Since nf_t is among the disjuncts (nf_characteristic M (k'+2) 1 (fun _ => t) is atom-compatible with parent_atoms by h_atoms), and char_kp1_correct gives truth, this holds. The Until part is the same as the current forward direction. VERIFIED.

4. **Claim**: "t < c follows from 2-var NF agreement."
   **Verification**: From depth-(k'+1) arity-2 agreement at [c, t] and [x0, t0], the atom (.order 1 0) has the same value. Since t0 < x0 (from h_eval0 and h_gt_val), the atom is true for M0, hence true for M, giving t < c. VERIFIED.

### Uncertain Claims (Confidence Levels)

1. **"The backward direction for the sub_nf.2 ssn = false case works by contraposition"** (90% confidence). If M had y with nf_eval_nf M (k'+1) 3 [y, c, t] ssn, then by nf_extend_bwd, M0 would have y0 with matching depth-k' arity-3 NF, and the lifting argument would give nf_eval_nf M0 (k'+1) 3 [y0, x0, t0] ssn, contradicting sub_nf.2 ssn = false. Minor concern: nf_extend_bwd requires the same depth-(k'+1) arity-2 agreement, which we have from step 2.

2. **"The lifting from depth-k' to depth-(k'+1) arity-3 agreement requires explicit proof"** (95% confidence). The argument is sound but needs to be formalized as a helper lemma. The existing `nf_eval_unique` can be used after showing both atoms and quantifier conditions match.

### Recommendations Modified After Verification

None. The core argument is sound. The enrichment strategy is correct.

## Decisions

1. The zone-explicit temporal formula encoding (as originally proposed in the task description) is NOT viable as a standalone approach because ih_exist's constant-parent constraint prevents zone-by-zone temporal encoding at k>0.

2. The correct approach is to ENRICH the existing formula with char_kp1(nf_t) and use nf_extend_fwd chain for the backward proof. This is a modification to the formula construction at KampBypass.lean:353/365, not a restructuring of ExistPart.

3. The n>=2 sorry at KampMutualInduction.lean:310 depends on n=1 and will resolve once the n=1 case is closed.

## Proof Strategy (Concrete Lean Pseudocode)

### Step 1: Enrich the formula (modify lines 342-375 of KampBypass.lean)

Replace the Until/Since formula construction with per-nf_t disjuncts:

```lean
-- For the Until zone (h_gt_val = true, h_lt_val = false):
-- Disjunction over compatible nf_t types
let nf_t_compat (nf_t : NormalForm sig (k' + 1 + 1) 1) : Bool :=
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    nf_t.1 (.pred p ⟨0, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)
let per_nf_t_formula := fun nf_t =>
  if nf_t_compat nf_t then
    -- Check: exists M0 satisfying sub_nf with this nf_t at t0
    if Classical.propDecidable (∃ (M0 : OrderedMonadicStructure sig)
        (h_UZ0 : semantic_prior_UZ M0 atomMap)
        (h_SZ0 : semantic_prior_SZ M0 atomMap)
        (t0 x0 : M0.carrier),
        nf_eval_nf M0 (k'+1+1) (1+1) (Fin.cons x0 (fun _ => t0)) sub_nf ∧
        nf_eval_nf M0 (k'+1+1) 1 (fun _ => t0) nf_t ∧
        (∀ a, atom_eval M0 (fun _ => t0) a ↔ parent_atoms a = true)) |>.decide
    then
      some (Formula.and (char_kp1 nf_t) (Formula.untl compat_disj Formula.top))
    else none
  else none
let until_formula := formula_disjList
  ((Fintype.elems (α := NormalForm sig (k'+1+1) 1)).val.toList.filterMap per_nf_t_formula)
refine ⟨until_formula, fun M h_UZ h_SZ t h_atoms => ?_⟩
```

### Step 2: Forward direction (unchanged modulo disjunct selection)

```lean
-- Forward: exists x -> until_formula holds at t
intro ⟨x, h_eval⟩
-- t has NF type nf_t := nf_characteristic M (k'+2) 1 (fun _ => t)
-- nf_t is in the disjunct list (compatible + satisfiable via M itself)
-- char_kp1(nf_t) holds at t by char_kp1_correct
-- compat_disj.untl holds at x (same as current forward proof)
```

### Step 3: Backward direction (the new proof)

```lean
-- Backward: until_formula holds at t -> exists x
-- Extract disjunct: some nf_t with char_kp1(nf_t) at t and Until(compat_disj, top) at t
-- From char_kp1(nf_t) at t: nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t
-- From Classical existence: M0 satisfying sub_nf with nf_t at t0
-- nf_agreement: M and M0 agree at depth-(k'+2) arity-1 at (fun _ => t) and (fun _ => t0)
have h_agree : ∀ nf, nf_eval_nf M (k'+2) 1 (fun _ => t) nf ↔
    nf_eval_nf M0 (k'+2) 1 (fun _ => t0) nf :=
  nf_agreement_from_shared_nf ...
-- nf_extend_fwd: exists c in M with depth-(k'+1) 2-var agreement
obtain ⟨c, hc⟩ := nf_extend_fwd M (fun _ => t) M0 (fun _ => t0) h_agree x0
-- c satisfies sub_nf:
-- Atom part: from hc + nf_drop_last (c has same atoms as x0) + h_atoms
-- Quantifier part: for each ssn
--   sub_nf.2 ssn = true case: M0 has y0. nf_extend_fwd on hc gives y in M.
--     Lift depth-k' to depth-(k'+1) via atoms + quantifier matching.
--   sub_nf.2 ssn = false case: contraposition using nf_extend_bwd.
-- t < c: from hc and h_gt_val (order atom transfer)
refine ⟨c, ?_⟩
```

### Step 4: Helper lemma needed

```lean
/-- If two 3-var environments have the same depth-k' arity-3 NFs,
    they have the same depth-(k'+1) arity-3 NFs. -/
private theorem nf_agree_lift_3var {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (N : OrderedMonadicStructure sig)
    (k' : Nat) (env_M : Fin 3 → M.carrier) (env_N : Fin 3 → N.carrier)
    (h_agree_k' : ∀ nf : NormalForm sig k' 3,
      nf_eval_nf M k' 3 env_M nf ↔ nf_eval_nf N k' 3 env_N nf) :
    ∀ nf : NormalForm sig (k' + 1) 3,
      nf_eval_nf M (k' + 1) 3 env_M nf ↔ nf_eval_nf N (k' + 1) 3 env_N nf
```

Wait -- this is FALSE in general. Depth-k' NF agreement does not imply depth-(k'+1) NF agreement. The depth hierarchy is strict.

**CORRECTION**: The lifting argument from Finding 12 is WRONG. Depth-k' arity-3 agreement does NOT lift to depth-(k'+1) arity-3 agreement in general.

The correct claim is: from depth-(k'+1) arity-2 agreement, nf_extend_fwd gives depth-k' arity-3 agreement, and from this we can transfer QUANTIFIER CONDITIONS of depth-(k'+1) arity-3 NFs (which involve depth-k' arity-4 NFs, transferable from the depth-k' arity-3 agreement). But the ATOM conditions of depth-(k'+1) arity-3 NFs also need to match.

From depth-k' arity-3 agreement via nf_drop_last: depth-k' arity-2 agreement on the first two components [y, c] and [y0, x0]. Then depth-k' arity-1 agreement on y and y0. For k' >= 1, this gives atom agreement.

Actually, depth-k' arity-3 NF agreement directly gives atom agreement: the atom function is part of the NF (for k' >= 1 it's the .1 component, for k' = 0 the entire NF IS the atom function). So atoms at [y, c, t] match atoms at [y0, x0, t0].

For quantifier conditions: `(exists w, nf_eval M k' 4 [w, y, c, t] chi) <-> (exists w, nf_eval N k' 4 [w, y0, x0, t0] chi)`. This follows from nf_extend_fwd/bwd on the depth-k' arity-3 agreement (with K = k'-1):

Wait, nf_extend_fwd requires depth-(K+1) arity-r agreement and produces depth-K arity-(r+1) agreement. Here r = 3, and we have depth-k' arity-3 agreement. So K = k'-1, producing depth-(k'-1) arity-4 agreement. But the quantifier conditions need depth-k' arity-4 existentials.

**THE GAP REAPPEARS**: We need depth-k' arity-4 transfer but nf_extend_fwd only gives depth-(k'-1) arity-4 from depth-k' arity-3.

**This is the same depth gap at every level.** nf_extend_fwd always drops one depth level when increasing arity. To transfer at depth d arity r+1, you need depth d+1 arity r.

**So the lifting from depth-k' arity-3 to depth-(k'+1) arity-3 does NOT work.** My earlier analysis in Finding 12 was WRONG.

**Revised assessment**: The nf_extend_fwd chain gives:
- depth-(k'+2) arity-1 -> depth-(k'+1) arity-2 (at [c, t] and [x0, t0])
- depth-(k'+1) arity-2 -> depth-k' arity-3 (at [y, c, t] and [y0, x0, t0])

This is depth-k' arity-3 agreement. We need `nf_eval_nf M (k'+1) 3 [y, c, t] ssn` where ssn is at depth k'+1. The NF evaluation at depth k'+1 decomposes as:
- atoms match ssn.1
- `forall chi : NF sig k' 4, (exists w, nf_eval M k' 4 [w,y,c,t] chi) <-> ssn.2 chi`

Atoms: from depth-k' arity-3 agreement, atoms match. GOOD.

Quantifier: need `(exists w, nf_eval M k' 4 [w,y,c,t] chi) <-> ssn.2 chi`. We know:
- M0 satisfies ssn at [y0, x0, t0]: `(exists w0, nf_eval M0 k' 4 [w0,y0,x0,t0] chi) <-> ssn.2 chi`
- Need: `(exists w, nf_eval M k' 4 [w,y,c,t] chi) <-> (exists w0, nf_eval M0 k' 4 [w0,y0,x0,t0] chi)`

From depth-k' arity-3 agreement:
```
forall nf : NF sig k' 3, nf_eval M k' 3 [y,c,t] nf <-> nf_eval M0 k' 3 [y0,x0,t0] nf
```

Apply nf_extend_fwd/bwd at K = k'-1, r = 3:
- Requires depth-k' arity-3 agreement (CHECK)
- Produces depth-(k'-1) arity-4 agreement

But we need depth-k' arity-4 EXISTENTIAL transfer, not depth-(k'-1) arity-4 agreement.

From the depth-k' arity-3 agreement, we can extract the quantifier part:
- `nf_characteristic M k' 3 [y,c,t] = nf_characteristic M0 k' 3 [y0,x0,t0]` (by nf_eval_unique)
- The quantifier part of this characteristic: `forall chi, (exists w, nf_eval M (k'-1) 4 [w,y,c,t] chi) <-> ...`

Wait. The depth-k' arity-3 NF characteristic is:
- For k' = 0: just the atom function. No quantifier part.
- For k' >= 1: (atoms, quantifier_fn) where quantifier_fn chi = `decide(exists w, nf_eval M (k'-1) 4 [w,...] chi)`.

So depth-k' arity-3 agreement gives:
- Same atoms at [y,c,t] and [y0,x0,t0]
- For k' >= 1: same depth-(k'-1) arity-4 quantifier conditions

But we need depth-k' arity-4 existential transfer. For k' = 0: the quantifier condition is `(exists w, nf_eval M 0 4 [w,y,c,t] chi) <-> ssn.2 chi` where nf_eval at depth 0 arity 4 is purely atomic. The existence of w with the right atoms in M follows from the Prior property (semantic_prior_UZ/SZ ensure witnesses exist in every zone).

**For k' = 0**: The quantifier transfer at depth 0 arity 4 reduces to: do the same atom types appear in the same zones for M and M0? On Prior structures, the answer is YES -- every atom type that appears anywhere also appears in every interval (because Prior structures have witnesses everywhere). This is the content of the k=0 zone bridge lemmas.

**For k' >= 1**: The quantifier transfer at depth k' arity 4 requires depth-k' arity-3 agreement, which is exactly what we have. The existential `exists w, nf_eval M k' 4 [w,y,c,t] chi` can be transferred using nf_extend_fwd/bwd at K = k'-1, r = 3, from the depth-k' arity-3 agreement. This gives depth-(k'-1) arity-4 agreement, which allows transferring the quantifier conditions of chi at depth k'-1.

**But** chi is at depth k', and its evaluation involves depth-(k'-1) arity-4 quantifier conditions AND depth-0 atoms. The atoms transfer as before. The depth-(k'-1) quantifier conditions transfer via the depth-(k'-1) arity-4 agreement.

So `nf_eval M k' 4 [w,y,c,t] chi <-> nf_eval M0 k' 4 [w0,y0,x0,t0] chi` where [w,...] and [w0,...] have the same depth-(k'-1) arity-4 NF. The existence of w0 for a given w (or vice versa) follows from nf_extend_fwd/bwd.

**Therefore**: The depth-k' arity-3 agreement + nf_extend_fwd chain gives depth-k' arity-4 existential transfer. This gives the quantifier part of the depth-(k'+1) arity-3 NF evaluation.

**Combined**: atoms (from depth-k' agreement) + quantifier transfer = `nf_eval_nf M (k'+1) 3 [y,c,t] ssn <-> nf_eval_nf M0 (k'+1) 3 [y0,x0,t0] ssn`.

**THE KEY HELPER LEMMA**:

```lean
theorem nf_eval_transfer_via_agreement {sig : MonadicSignature}
    {k r : Nat}
    (M : OrderedMonadicStructure sig)
    (N : OrderedMonadicStructure sig)
    (envM : Fin r → M.carrier)
    (envN : Fin r → N.carrier)
    (h_agree : ∀ nf : NormalForm sig k r,
      nf_eval_nf M k r envM nf ↔ nf_eval_nf N k r envN nf)
    (nf : NormalForm sig (k + 1) r) :
    nf_eval_nf M (k + 1) r envM nf ↔ nf_eval_nf N (k + 1) r envN nf
```

Wait -- this says depth-k agreement implies depth-(k+1) agreement. This is FALSE in general. Depth-k agreement does NOT imply depth-(k+1) agreement (the depth hierarchy is strict).

What IS true is that depth-k arity-r agreement gives:
- Same atoms at envM and envN (depth-0 information, follows from any positive depth agreement)
- For each chi : NF sig (k-1) (r+1), `(exists w, nf_eval M (k-1) (r+1) (Fin.cons w envM) chi) <-> (exists w, nf_eval N (k-1) (r+1) (Fin.cons w envN) chi)` (from nf_extend_fwd/bwd)

The FULL depth-(k+1) evaluation requires:
- Same atoms (CHECK from depth-k agreement)
- For each chi : NF sig k (r+1), `(exists w, nf_eval M k (r+1) (Fin.cons w envM) chi) <-> (exists w, nf_eval N k (r+1) (Fin.cons w envN) chi)`

This requires depth-k arity-(r+1) existential transfer, which from nf_extend_fwd needs depth-(k+1) arity-r agreement... which is what we're trying to prove. CIRCULAR.

**FINAL VERDICT**: The nf_extend_fwd chain does NOT give the depth-(k'+1) arity-3 transfer needed. The depth gap is real and unavoidable.

**Corrected strategy**: Instead of trying to transfer at depth (k'+1), use the enriched formula to directly encode the quantifier conditions via ih_exist at the AVAILABLE depth.

Specifically: The quantifier conditions of sub_nf at `[y, x, t]` involve depth-(k'+1) arity-3 NFs. But sub_nf.2 ssn is a FIXED boolean (determined by the specific sub_nf). So the formula only needs to assert that the correct boolean pattern holds. And the pattern is determined by the M0 witness.

The formula can encode: "M has the SAME depth-(k'+1) arity-2 NF at [c, t] as M0 has at [x0, t0]." This is what nf_extend_fwd gives. And the correct existential conclusion follows from the depth-(k'+1) arity-2 NF agreement because:

`nf_eval_nf M (k'+2) 2 [c, t] sub_nf` is equivalent to `nf_characteristic M (k'+2) 2 [c, t] = sub_nf` (by nf_eval_unique). And the depth-(k'+1) arity-2 NF is a DIFFERENT thing from the depth-(k'+2) arity-2 NF.

The depth-(k'+1) arity-2 NF at [c, t] tells us: all depth-(k'+1) arity-2 formulas agree. The depth-(k'+2) arity-2 NF at [c, t] tells us: all depth-(k'+2) arity-2 formulas agree. These are NOT the same.

**The depth gap is fundamental.** nf_extend_fwd trades depth for arity but never increases depth. To get depth-(k'+2) arity-2 information, you need depth-(k'+3) arity-1 information (which requires CharPart(k'+3), which requires ExistPart(k'+2), which is what we're proving).

## Revised Direction

Given the adversarial verification revealed that the nf_extend_fwd chain has an inherent depth gap that cannot be bridged, the enriched formula strategy with char_kp1(nf_t) does NOT close the sorry as initially analyzed in Finding 12.

**The revised recommendation** is:

### Option A: Change the mutual induction structure

Add a third mutual component `TransferPart(k)` that asserts: for all r >= 1, if two structures agree at depth-k arity-r on some environments, then they agree at depth-(k+1) arity-r. This is the "depth lifting" lemma.

TransferPart(k) at arity r requires:
- Atom agreement: follows from depth-k arity-r agreement (any k >= 0)
- Quantifier transfer: `(exists w, nf_eval M k (r+1) [w, envM] chi) <-> (exists w, nf_eval N k (r+1) [w, envN] chi)`. This is ExistPart-like but between two structures, not a temporal formula.

This is equivalent to the Feferman-Vaught "composition theorem" for linear orders.

**Feasibility**: The composition theorem IS true on Prior structures (it's what Rabinovich/GHR94 prove). But proving it requires substantial infrastructure (~500-1000 lines).

### Option B: Restructure the proof to avoid the depth gap

Instead of trying to transfer NF evaluations between structures, work entirely within a single structure using the classical existence argument.

The key: `nf_2var_exist_formula_prior` (NfCharFormula.lean:612) already uses `existPart_succ_n1_bypass` at depth k+2 (line 650-651), passing `sorry sorry` for ih_char and ih_exist. If we could fill these sorries with the REAL ih_char and ih_exist from the mutual induction, the sorry chain would close.

Currently, `nf_2var_exist_formula_prior` at depth k+2 requires `ih_char` and `ih_exist` at depth k+1. The mutual induction provides these: `(kamp_mutual_induction atomMap h_surj (k+1)).1` and `(kamp_mutual_induction atomMap h_surj (k+1)).2`.

BUT: this creates a circular dependency because `kamp_mutual_induction` at k+1 calls `existPart_succ` which calls `existPart_succ_n1_bypass` which calls `nf_2var_exist_formula_prior`... which at depth k+2 would call `kamp_mutual_induction` at k+1 again.

The circularity is: `kamp_mutual_induction(k+1)` -> `existPart_succ(k+1)` -> `existPart_succ_n1_bypass(k+1)` -> `nf_2var_exist_formula_prior(k+2)` -> `existPart_succ_n1_bypass(k+1)` -> LOOP.

So Option B doesn't work either.

### Option C (RECOMMENDED): Enrich Until/Since formula with M0's quantifier conditions encoded as temporal formulas using ih_exist at LOWER depth

The key insight from the Eq zone: ih_exist at depth k'+1 with constant parent gives formulas for `exists y, nf_eval M (k'+1) (n+1) (Fin.cons y (fun _ => t)) ssn`.

For the Until zone with c (the nf_extend_fwd witness):
- The depth-(k'+1) arity-2 NF of [c, t] agrees with [x0, t0] in M0.
- This 2-var NF has a quantifier part: for each ssn, `(exists y, nf_eval M k' 3 [y, c, t] ssn) <-> nf_2.2 ssn` where nf_2 is the depth-(k'+1) 2-var characteristic.
- The formula can encode nf_2.2 ssn using ih_exist at depth k' (not k'+1).

Wait -- ih_exist is at depth k'+1, not k'. And we need existentials at depth k'+1 arity 3 for the quantifier conditions of sub_nf.

Let me reconsider the depth arithmetic:
- sub_nf : NormalForm sig (k'+2) 2
- sub_nf.2 : NormalForm sig (k'+1) 3 -> Bool
- The quantifier condition: `(exists y, nf_eval M (k'+1) 3 [y, x, t] ssn) <-> sub_nf.2 ssn`

ih_exist at depth k'+1 with n=2 gives formulas for `exists y, nf_eval M (k'+1) 3 (Fin.cons y (fun _ => z)) ssn` with constant parent (fun _ => z).

Setting z = t: `exists y, nf_eval M (k'+1) 3 [y, t, t] ssn`. NOT what we need.
Setting z = x: `exists y, nf_eval M (k'+1) 3 [y, x, x] ssn`. NOT what we need either.

We need `[y, x, t]` with x != t. ih_exist cannot express this.

**Option C fails for the same reason as all previous approaches.** The constant-parent constraint is fundamental.

### FINAL RECOMMENDATION

The problem requires a **composition theorem for Prior structures**: given that M and M0 agree at depth K on constant-env representations of multiple elements, and the elements have matching orders, then M and M0 agree at depth-(K-1) on multi-variable environments built from those elements.

This is NOT the same as "same 1-var NFs at individual elements implies same multi-var NF" (which was proved FALSE). Instead, it's "depth-K 1-var agreement at EACH element + matching orders + Prior-UZ/SZ implies depth-(K-1) 2-var agreement." The difference is that depth-K 1-var agreement is between TWO STRUCTURES (M and M0), giving enough information for the cross-structure transfer via nf_extend_fwd.

**Concrete plan**: Prove a restricted composition theorem as a new helper:

```lean
theorem prior_2var_composition {sig : MonadicSignature}
    (M N : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (K : Nat)
    (t : M.carrier) (s : N.carrier)
    (x : M.carrier) (x' : N.carrier)
    (h_t_agree : ∀ nf, nf_eval_nf M (K+1) 1 (fun _ => t) nf ↔ nf_eval_nf N (K+1) 1 (fun _ => s) nf)
    (h_x_agree : ∀ nf, nf_eval_nf M (K+1) 1 (fun _ => x) nf ↔ nf_eval_nf N (K+1) 1 (fun _ => x') nf)
    (h_order : t < x ↔ s < x')
    (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap) :
    ∀ nf : NormalForm sig K 2,
      nf_eval_nf M K 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N K 2 (Fin.cons x' (fun _ => s)) nf
```

This says: on Prior structures, depth-(K+1) 1-var agreement at each element + matching order implies depth-K 2-var agreement.

This IS true on Prior structures (it's the content of the composition theorem for linear orders with the density/discreteness property that Prior axioms provide).

**Proof by induction on K**: At K = 0, the 2-var NF is purely atomic. Atoms at [x, t] are determined by 1-var atoms at x and t (predicates) plus the order (given). At K > 0, the quantifier conditions involve `exists y, nf_eval M (K-1) 3 [y, x, t] chi`, which by the IH (at K-1, arity 3) can be transferred using the Prior property to find matching witnesses.

**Estimated effort**: 300-500 lines for the composition theorem, then 100-200 lines to use it in the backward direction.

**With this theorem**, the backward proof becomes:
1. From char_kp1(nf_x) at x and h_agree(nf_t) at t: depth-(k'+2) 1-var agreement at x/x0 and t/t0
2. prior_2var_composition: depth-(k'+1) 2-var agreement at [x, t] and [x0, t0]
3. Since M0 satisfies sub_nf at [x0, t0] (depth-(k'+2) evaluation), and depth-(k'+1) 2-var agreement gives same quantifier conditions: M satisfies sub_nf at [x, t]

Wait -- same issue. Depth-(k'+1) 2-var agreement is NOT depth-(k'+2) 2-var agreement. sub_nf is at depth k'+2.

Sub_nf at depth k'+2: atoms + depth-(k'+1) quantifier conditions.
- Atoms: follow from individual 1-var atom agreement + order matching.
- Quantifier conditions: `(exists y, nf_eval M (k'+1) 3 [y, x, t] ssn) <-> sub_nf.2 ssn`.

We need depth-(k'+1) arity-3 existential transfer. From depth-(k'+1) arity-2 agreement (via composition at K = k'+1):
- nf_extend_fwd: depth-k' arity-3 agreement at [y, x, t] and [y0, x0, t0].

Still one depth level short. The quantifier conditions of ssn at depth k'+1 require depth-k' arity-4 transfer from depth-k' arity-3 agreement.

Actually: from depth-(k'+1) arity-2 agreement, nf_extend_fwd gives depth-k' arity-3 agreement. From depth-k' arity-3 agreement, nf_extend_fwd gives depth-(k'-1) arity-4 agreement. But we need depth-k' arity-4 existential transfer.

The composition theorem at (K=k', arity 3) applied recursively:
- Need depth-(k'+1) 1-var agreement at each of y, x, t (3 elements).
- We have depth-(k'+2) at t (from char_kp1(nf_t)), depth-(k'+2) at x (from char_kp1(nf_x)).
- We need depth-(k'+1) at y -- but y is chosen by nf_extend_fwd, not from the formula.

Actually, from nf_extend_fwd: we get y in M and y0 in M0 with depth-k' arity-3 agreement at [y,x,t] and [y0,x0,t0]. From nf_drop_last: depth-k' arity-1 agreement at y and y0 (extracting the first variable).

For the recursive composition at (K = k', arity 3): we need depth-(k'+1) 1-var agreement at EACH of y, x, t. We have:
- depth-(k'+2) at t and x (from char_kp1 matching)
- depth-k' at y (from nf_drop_last on the nf_extend_fwd result)

The y agreement is only depth-k', not depth-(k'+1). Insufficient for the recursive composition.

**The depth gap is inherent at every level.** nf_extend_fwd always loses one depth level. The composition theorem can at most recover this by the Prior property, but I cannot see how.

## Final Assessment

**Status: The zone-explicit encoding research question has been thoroughly investigated. The fundamental obstacle is the depth gap inherent in nf_extend_fwd: trading depth for arity always loses one level, and no amount of formula enrichment or zone decomposition can recover this within the current framework.**

**The sorry CANNOT be closed by modifying only KampBypass.lean.** It requires either:

1. A new composition theorem for Prior structures that provides full multi-variable NF agreement from 1-var NF agreements WITHOUT the depth drop (requires Prior-UZ/SZ in an essential way). Estimated: 500-1000 lines, substantial mathematical content.

2. Restructuring the mutual induction to use a different formulation of ExistPart that avoids the constant-parent constraint. This likely means working at the formula level (FOMLO formulas) rather than the NF level, following Rabinovich's approach more literally.

3. An entirely different proof architecture for Kamp's theorem on Prior structures, perhaps using EF games or the separation property rather than the composition method.

**Recommendation**: Pursue option 1 (composition theorem for Prior structures) as a new task. The composition theorem is of independent mathematical interest and would resolve all remaining sorries in one stroke.

## Tactic Survey Results

No tactic survey was conducted as the blocker is mathematical (proof strategy), not tactical.
