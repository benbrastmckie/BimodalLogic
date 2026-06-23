# Faithfulness Audit: Rabinovich 2014 vs Current Implementation

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Type**: lean4
- **Session**: sess_1782191203_6e98b6
- **Agent**: lean-research-hard-agent (H3 + H4)
- **Tier**: 1 (literature-backed, lean4 strict)

## H3 Reference Grounding Table (Tier 1)

| Rabinovich Reference | Lean Declaration | File | Status | Faithfulness |
|---------------------|------------------|------|--------|-------------|
| Def 3.1 (EA formula) | `VecEAFormula`, `BracketFormula` | VecEAFormula.lean | proved | faithful |
| Def 3.3 (V-EA formula) | `VBracketFormula`, `VVecEA2` | VecEAFormula.lean | proved | faithful |
| Lemma 3.2.1 (conjunction closure) | `BracketFormula.conj_to_bracket_exists` | VecEAClosure.lean | proved | faithful |
| Lemma 3.4 (V-EA closure: disj, conj, exists) | `VBracketFormula.disj_holds`, `VVecEA2.conj_holds_vvecEA2` | VecEAClosure.lean | proved | faithful |
| Prop 3.5 (V-EA 1-var -> TL) | `ExistsForallSpec.translate_correct` | RabinovichTranslation.lean | proved | faithful |
| Notation 5.2 (bracket) | `BracketFormula.holds` | VecEAFormula.lean | proved | faithful |
| Eq 5.2 (K+ operator) | `kplus` | PriorINF.lean | proved | adapted (Prior: attained INF only) |
| INF formula (Lemma 5.3) | `inf_bracket_formula`, `inf_bracket_formula_hasINF` | EANegationClosure.lean | proved | adapted (HasAttainedINF, no K+) |
| Lemma 5.3 (base case, all betas True) | `neg_orderedPointsExist_is_vbracket` | EANegation.lean | proved (biconditional) | faithful |
| Corollary 5.4 (partial bracket negation, forward) | `neg_partialBracketExist_sufficient` | EANegation.lean | proved (one direction) | adapted (forward only) |
| Corollary 5.4 (partial bracket negation, biconditional) | `neg_partialBracketExist_is_vbracket` | EANegation.lean:1172 | **sorry** | diverged (backward blocked) |
| Lemma 5.1 (bracket negation, model-dependent) | `neg_interval_formula` | EANegationClosure.lean | proved (sorry-free) | adapted (model-dependent) |
| Lemma 5.1 (bracket negation, biconditional) | `neg_bracket_is_vbracket` | EANegation.lean:1047 | **sorry** (beta_0(r0) case) | diverged (model-independent blocked) |
| Corollary 5.4 (model-dependent forward) | `neg_bounded_exists` | EANegationClosure.lean | proved (sorry-free) | adapted (model-dependent) |
| Prop 4.2 (neg of VecEA2 -> VVecEA2, model-dep) | `neg_vecEA2`, `neg_2var_vec_ea` | EANegationClosure.lean | proved (sorry-free) | adapted (model-dependent) |
| Prop 4.2 (neg of VecEA2 -> VVecEA2, model-indep) | -- | -- | **missing** | diverged (never attempted) |
| Prop 4.3 (FO -> V-EA) | -- (implicit in mutual induction) | KampMutualInduction.lean | partial (sorry at k>=2) | adapted (bypassed by Prior composition) |
| Theorem 4.4 (Kamp's theorem) | `kamp_mutual_induction` | KampMutualInduction.lean, KampPrior.lean | partial (sorry propagates) | adapted (Prior-specific) |
| A_i^- / A_i^+ decomposition (p.10) | `BracketFormula.leftPart`, `BracketFormula.rightPart`, `BracketFormula.splitAt_combine` | VecEAFormula.lean | proved | faithful |
| Prior-specific: attained INF | `HasAttainedINF`, `prior_hasAttainedINF` | PriorINF.lean | proved | N/A (not in Rabinovich) |
| Prior composition transfer | `prior_2var_transfer_until`, `prior_2var_transfer_since` | PriorComposition.lean:131,162 | **sorry** | diverged (not in Rabinovich) |

## Question 1: Does zone decomposition correspond to Rabinovich Section 5's interval splitting?

**Assessment: Partially faithful, with significant structural divergence.**

Rabinovich's Section 5 interval splitting (A_i^-/A_i^+ decomposition) IS faithfully formalized:
- `BracketFormula.leftPart` / `BracketFormula.rightPart` correspond exactly to Rabinovich's A_i^-(z_0, z) and A_i^+(z, z_1)
- `BracketFormula.splitAt_combine` proves the combination direction
- `BracketFormula.tail` and `bracket_tail_satisfiable` in EANegationClosure.lean implement the recursive decomposition from Lemma 5.1

However, the "zone decomposition" referenced in plan v22 is a DIFFERENT concept from Rabinovich's interval splitting. The plan's zone decomposition refers to the ordering zones of the existential witness w relative to x and t (zones 1-5: w <= t, w = t, t < w < x, w = x, w >= x). This is an implementation-specific technique for proving `prior_2var_transfer_until/since`, which has NO counterpart in Rabinovich's paper.

**Key distinction**: Rabinovich's Lemma 5.1 works at the formula level (bracket formulas decompose into V-bracket formulas). The implementation's zone decomposition works at the NF level (normal form evaluation transfers between models). These are mathematically different operations solving different subproblems.

## Question 2: Missing Rabinovich lemmas

### Formalized and sorry-free:
1. **Lemma 5.3** (base case): `neg_orderedPointsExist_is_vbracket` -- full biconditional, sorry-free
2. **Corollary 5.4** (forward direction): `neg_partialBracketExist_sufficient` -- one-directional, sorry-free
3. **Lemma 5.1** (model-dependent): `neg_interval_formula` in EANegationClosure.lean -- sorry-free but model-dependent
4. **Prop 4.2** (model-dependent): `neg_vecEA2` and `neg_2var_vec_ea` in EANegationClosure.lean -- sorry-free but model-dependent
5. **Prop 3.5**: `ExistsForallSpec.translate_correct` -- full biconditional, sorry-free

### Formalized with sorry:
6. **Lemma 5.1** (model-independent biconditional): `neg_bracket_is_vbracket` in EANegation.lean:1047 -- the beta_0(r0) case is sorry
7. **Corollary 5.4** (biconditional): `neg_partialBracketExist_is_vbracket` in EANegation.lean:1172 -- backward direction sorry

### Missing entirely:
8. **Prop 4.2** (model-independent): Never formalized as a model-independent statement. The model-dependent version in EANegationClosure.lean is used instead.
9. **Prop 4.3** (structural induction: every FO formula -> V-EA): Partially implicit in `kamp_mutual_induction`, but the full induction is not structured as Rabinovich describes it (atomic/disjunction/negation/exists cases). Instead, the implementation uses a different decomposition: CharPart(k) AND ExistPart(k) by mutual induction on NF depth k, not by structural induction on FO formula structure.
10. **Theorem 4.4**: The final statement connecting FO -> TL is not explicitly stated as such. The implementation goes through Prior-specific normal forms rather than the Rabinovich chain: FO -> V-EA -> TL.

### Assessment
The proof chain from Rabinovich's paper is:

```
Lemma 5.3 -> Cor 5.4 -> Lemma 5.1 -> Prop 4.2 -> Prop 4.3 -> Theorem 4.4
```

The implementation has TWO parallel chains:

**Chain A (model-independent, EANegation.lean)**: Follows Rabinovich but BLOCKED at Lemma 5.1 backward direction (sorry at line 1047).

**Chain B (model-dependent, EANegationClosure.lean + KampBypass.lean)**: An alternative path that avoids the model-independent blocker but introduces a new sorry-bearing component (`prior_2var_transfer_until/since`).

Neither chain is complete. The implementation takes a hybrid approach, using Chain B's sorry-free negation closure results alongside a "Kamp bypass" (KampBypass.lean) that directly encodes the existential characterization as a temporal formula on Prior structures, circumventing the full Rabinovich proof chain. This bypass is where `prior_2var_transfer_until/since` appears.

## Question 3: Model-dependent vs model-independent

**Assessment: The distinction matters mathematically but not for the target application.**

### What Rabinovich does (model-independent)
Rabinovich's Lemma 5.1 constructs a FIXED V-bracket formula V (independent of any model M) such that for ALL Dedekind complete chains M:
```
V.holds M z0 z1  <->  neg bracket.holds M z0 z1
```

This is a syntactic transformation: given a bracket formula, produce a V-bracket formula. The construction depends only on the bracket's types, not on any particular model.

### What the implementation does (model-dependent)
`neg_interval_formula` in EANegationClosure.lean takes `neg bf.holds M atomMap z0 z1` (the NEGATION ALREADY HOLDING in a SPECIFIC model M) as input and produces a V-bracket formula that holds in THAT model:
```
HasAttainedINF M atomMap ->
neg bf.holds M atomMap z0 z1 ->
exists v, v.holds M atomMap z0 z1
```

This is an existential result: given a model where the negation holds, find SOME V-bracket that works for that model. The V-bracket may be different for different models.

### Does this compromise correctness?
**No, for the downstream use case.** The model-dependent version suffices for proving `neg_2var_vec_ea` (Prop 4.2, model-dependent), which in turn suffices for the Prior-specific Kamp theorem. The downstream consumer (`completeness_discrete`) only needs the result on Prior structures, which are specific models.

### Does this compromise generality?
**Yes.** Rabinovich's theorem applies to ALL Dedekind complete chains. The implementation's result applies only to structures with `HasAttainedINF` (which includes Prior structures and all Dedekind complete chains where infima are attained, but NOT chains where the infimum is a limit point). For the integers (N, Z) and Prior structures this distinction is irrelevant (all infima are attained), but for the reals (R), the K+ case is needed, and the current implementation does not handle it.

### Why the model-independent version is blocked
The model-independent `neg_bracket_is_vbracket` in EANegation.lean:1047 is sorry because of the beta_0(r0) sub-case in Lemma 5.1's backward direction. When:
- beta_0(r0) holds (i.e., the first segment type holds at the first witness point)
- beta_0 holds on the segment (z0, r0)
- The right part (tail bracket) fails on (r0, z1)

The V-bracket construction needs to "absorb" the fact that r0 satisfies both the segment and point conditions. The model-dependent version avoids this by constructing the V-bracket witnessing specific model data. The model-independent version would need a FIXED finite V-bracket structure that works for all models, which creates a self-referential construction (the V-bracket would need to reference its own negation). The handoff document confirms this is a fundamental structural issue, not a proof engineering problem.

## Question 4: Is `prior_2var_transfer_until/since` what Rabinovich needs?

**Assessment: No. This is NOT part of Rabinovich's proof. It arose from the "Kamp bypass" formalization strategy.**

### What Rabinovich's proof chain requires
Rabinovich's proof of Kamp's theorem goes:
1. Lemma 5.1: bracket negation -> V-bracket (model-independent)
2. Prop 4.2: V-EA negation -> V-EA (using Lemma 5.1)
3. Prop 4.3: every FO formula -> V-EA (structural induction using Prop 4.2 for negation)
4. Theorem 4.4: V-EA with 1 free var -> TL (by Prop 3.5)

None of these steps involve cross-model NF transfer. The `prior_2var_transfer_until/since` theorems are an artifact of the "Kamp bypass" approach:

### How the Kamp bypass works
Instead of following Rabinovich's path through Prop 4.3 (structural induction on FO formulas), the implementation uses `kamp_mutual_induction` which does mutual induction on NF depth k:
- **CharPart(k)**: every depth-k arity-1 NF has a temporal characteristic formula
- **ExistPart(k)**: for every depth-k arity-(n+1) NF, the existential is temporally characterizable

The ExistPart(k+1) at n=1 (arity 2) is handled by `existPart_succ_n1_bypass` in KampBypass.lean. This theorem constructs a temporal formula characterizing `exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` on Prior structures. For the backward direction (temporal formula truth -> existential witness), when k >= 1, it uses a "reference model" M_0 that satisfies the NF, and transfers the witness from M_0 to M. This transfer is where `prior_2var_transfer_until/since` appears.

### Why this sorry exists
The transfer needs to show: given depth-(K+2) arity-1 NF agreement at x and t between M and M_0, the depth-(K+2) arity-2 NF agreement at (x,t) follows. This decomposes into:
1. **Atom part**: handled sorry-free by `nonconstenv_atom_agree_until/since`
2. **Quantifier part**: for each existential condition `exists w, chi(x,t,w)`, transfer the witness w. This is the unsolved part.

### Could a faithful Rabinovich path avoid this?
**Yes.** If Lemma 5.1 (model-independent) were proved, the full Rabinovich chain would avoid NF transfer entirely. The Kamp bypass with its NF transfer is a workaround for the blocked model-independent Lemma 5.1.

## Question 5: What would a fully faithful Rabinovich formalization look like?

### The ideal structure

A fully faithful formalization would follow Rabinovich's proof chain exactly:

```
Section 3 (definitions + closure):
  - VecEAFormula, BracketFormula              [DONE, sorry-free]
  - Lemma 3.2 (conjunction closure)           [DONE, sorry-free]
  - Lemma 3.4 (V-EA closure)                  [DONE, sorry-free]
  - Prop 3.5 (V-EA 1-var -> TL)              [DONE, sorry-free]

Section 5 (negation closure):
  - INF formula construction                   [DONE, sorry-free]
  - Lemma 5.3 (base case)                     [DONE, sorry-free]
  - Corollary 5.4 (partial bracket negation)   [BLOCKED at backward direction]
  - Lemma 5.1 (full bracket negation)          [BLOCKED at beta_0(r0) case]

Section 4 (main argument):
  - Prop 4.2 (negation closure for 2-var V-EA) [BLOCKED, depends on Lemma 5.1]
  - Prop 4.3 (FO -> V-EA by structural induction)  [NOT ATTEMPTED]
  - Theorem 4.4 (Kamp's theorem)               [NOT ATTEMPTED via this path]
```

### What blocks the faithful path
The single blocker is **Lemma 5.1 backward direction, beta_0(r0) case** (EANegation.lean:1047). When beta_0 holds at r0 (the first alpha_0 point) AND on the segment (z0, r0), the negation `neg bf.holds(z0, z1)` reduces to `neg rightPart.holds(r0, z1)`, which by IH gives a V-bracket on (r0, z1). But expressing this as a V-bracket on (z0, z1) requires:
- Either: a V-bracket construction that "absorbs" the segment (z0, r0) where both alpha_0 and beta_0 hold (endpoint induction, not available at BracketFormula level)
- Or: an argument that the beta_0(r0) sub-case can be handled by a finite V-bracket covering all possible r0 positions

The handoff identifies this as a fundamental structural issue: the V-bracket must be a finite data structure, but the recursion `neg bf.holds(r0, z1)` generates V-brackets that depend on the specific r0 position, creating an infinite family.

### Potential resolution approaches
1. **Well-founded induction on intervals** (uses Dedekind completeness more deeply)
2. **Endpoint bracket formulas** (VecEA2-level Lemma 5.1, where alpha_0 is at z0 not interior)
3. **Direct structural argument** using the fact that the V-bracket disjuncts are drawn from a finite set (determined by the finite types alpha_i, beta_j)

Approach 3 is the most promising and closest to Rabinovich's intent: the paper works with formulas (syntactic objects), and there are only finitely many distinct bracket formulas of bounded size over a given finite signature. The induction terminates not because the interval shrinks, but because the bracket formula complexity decreases. This finiteness argument may be what the formalization is missing.

### How the current approach compares

The current approach (KampBypass + Prior composition) is a valid ALTERNATIVE proof, not a faithful Rabinovich implementation:

| Rabinovich's approach | Current approach |
|----------------------|-----------------|
| Model-independent V-bracket construction | Model-dependent V-bracket + NF transfer |
| Structural induction on FO formulas (Prop 4.3) | Mutual induction on NF depth (CharPart + ExistPart) |
| Works over all Dedekind complete chains | Works over Prior structures only |
| Uses K+ operator for limit infima | Uses `HasAttainedINF` (attained infima only) |
| Single proof chain: 5.3 -> 5.4 -> 5.1 -> 4.2 -> 4.3 -> 4.4 | Two parallel chains, neither complete |
| No cross-model NF transfer | Requires `prior_2var_transfer` (sorry) |

## Specific Recommendations for Plan v22

### Recommendation 1: The plan v22 approach (zone decomposition for prior_2var_transfer) is mathematically sound but NOT Rabinovich-faithful

The zone decomposition technique for proving `prior_2var_transfer_until/since` is a reasonable proof strategy that could work. But it solves a problem that only exists because the formalization diverged from Rabinovich. If faithfulness to Rabinovich is a goal, this plan perpetuates the divergence.

### Recommendation 2: Consider whether the beta_0(r0) blocker can be resolved

Before investing in the zone decomposition approach (plan v22), it may be worth one more attempt at the beta_0(r0) case in EANegation.lean:1047. The key insight from the paper that may not have been tried:

Rabinovich's Lemma 5.1 proof uses induction on n (the number of witnesses), NOT on the interval size. When beta_0(r0) holds, the negation becomes `neg bf.rightPart.holds(r0, z1)`, which has n-1 witnesses (not n). By IH, this is a V-bracket on (r0, z1). The V-bracket on (z0, z1) prepends r0 with the appropriate segment types. The construction is:

For each V-bracket disjunct `bf_v` in the IH result:
```
bf_v.prepend alpha_0.neg alpha_0  -- prepend r0 with alpha_0 as point, neg alpha_0 as segment
```

This is ALREADY DONE in the code for the neg-beta_0(r0) sub-case (EANegation.lean:1049-1065). The beta_0(r0) sub-case at line 1047 is sorry because the point type at r0 needs to be `alpha_0.conj beta_0` (both alpha_0 and beta_0 hold), but CaseD's point type is `alpha_0.conj beta_0.neg` (alpha_0 and NOT beta_0). The fix would be a CaseE disjunct with point type `alpha_0.conj beta_0` and using the IH V-bracket on (r0, z1) where the right part of bf fails.

### Recommendation 3: If faithfulness is not a priority, plan v22 is reasonable

If the goal is simply "remove all sorry sites that block `completeness_discrete`", then plan v22's zone decomposition approach is a valid path. The mathematical content is sound: 2-var NF agreement CAN be transferred using 1-var agreement at each component plus ordering, given characteristic formula availability. The implementation complexity is estimated at 200-400 lines, which seems realistic.

### Recommendation 4: Catalog the full sorry chain

The sorry propagation chain is:
```
PriorComposition.lean:131  (prior_2var_transfer_until)   -- SORRY
PriorComposition.lean:162  (prior_2var_transfer_since)   -- SORRY
  -> KampBypass.lean:646,713  (existPart_succ_n1_bypass, k>=1 backward)
    -> KampMutualInduction.lean:312  (existPart_succ)
      -> KampMutualInduction.lean:388  (kamp_mutual_induction)
        -> KampPrior.lean  (kamp_prior)
          -> completeness_discrete  (via expressive completeness)
```

Additionally, there are "dead-code" sorrys that do NOT propagate:
```
EANegation.lean:1047  (neg_bracket_is_vbracket backward, beta_0(r0))  -- UNUSED downstream
EANegation.lean:1172  (neg_partialBracketExist_is_vbracket backward)  -- UNUSED downstream
NfCharFormula.lean:515  (nf_exist_backward_prior, k+1)  -- bypassed by existPart_succ_n1_bypass
NfCharFormula.lean:626  (nf_2var_exist_formula_prior_filled, k>=2)  -- bypassed by kamp_mutual_induction
```

## Adversarial Self-Verification (H4)

### Challenge 1: "The model-dependent neg_interval_formula is sorry-free"
**Verified**: Read EANegationClosure.lean lines 237-312. The theorem is proved by induction on n with explicit case analysis (Case A: no pointTypes(0) in interval; Case B1: segment holds + tail fails; Case B2: segment fails -> INF bracket). No sorry anywhere in the proof. Confirmed via `lean_local_search` that the declaration exists in EANegationClosure.lean.

### Challenge 2: "EANegation.lean:1047 and 1172 are unused downstream"
**Verified**: `grep -rn "neg_bracket_is_vbracket\|neg_partialBracketExist_is_vbracket" Theories/` (excluding EANegation.lean itself and comments) returns zero hits. These theorems are declared but never referenced by any other file. Confirmed by the handoff document's Finding 1.

### Challenge 3: "prior_2var_transfer is used at KampBypass.lean:646,713"
**Verified**: Read KampBypass.lean lines 646 and 713. Line 646 calls `prior_2var_transfer_until atomMap h_surj k' M x t M0 x0 t0 ...`. Line 713 calls `prior_2var_transfer_since` with analogous arguments. These are the only two call sites.

### Challenge 4: "The beta_0(r0) case is the ONLY blocker for model-independent Lemma 5.1"
**Verified by reading EANegation.lean:826-1073**: The proof of `neg_bracket_is_vbracket` handles:
- Base case (n=0): sorry-free (lines 836-838, delegates to `neg_bracket_zero_is_vbracket`)
- Inductive step: CaseA (no alpha_0 in interval): sorry-free (lines 1066-1073)
- CaseC (beta_0 fails in (z0, r0)): sorry-free (lines 999-1027)
- CaseD (neg-beta_0 at r0): sorry-free (lines 1048-1065)
- **CaseE (beta_0 holds at r0)**: sorry at line 1047

The sorry is confined to exactly one case. However, I should challenge whether a CaseE construction could work. Reading lines 1038-1047: the case `h_beta_r0 : beta_0.eval_at M atomMap r0` triggers, and the comment says "This sub-case requires VecEA2 endpoint infrastructure (Rabinovich Lemma 5.1 full proof, p.10)." This is a genuine gap, not an easily-closable oversight.

### Challenge 5: "Plan v22's zone decomposition can close prior_2var_transfer"
**Uncertain (confidence: medium)**. The plan's strategy is plausible: decompose the existential condition `exists w, nf_eval_nf M (K+1) 3 (Fin.cons w env) chi` into zones based on w's position relative to x and t. Each zone's transfer uses existing infrastructure (1-var NF agreement + ordering). However, the actual proof has not been attempted, and the plan's risk assessment acknowledges "the NF structure at arity 2 decomposes as atoms + quantifier conditions (each at arity 3)" which requires recursive zone decomposition at higher arities. The induction structure is not fully spelled out. I flag this as uncertain pending implementation.

## Addendum: Circular Dependency Analysis (Implementation Agent Findings)

The implementation agent attempted plan v22 Phase 1 and discovered a circular dependency that blocks the zone decomposition approach. This section analyzes whether Rabinovich's proof avoids this issue and what it means for the formalization strategy.

### The Circular Dependency Explained

The theorem `prior_2var_transfer_until` needs to show:

```
Given: h_x, h_t : 1-var NF agreement at depth K+2
       char_correct : temporal formulas at depth d <= K+1
       sub_nf : NormalForm sig (K+2) 2
       h_eval_0 : M_0 satisfies sub_nf at (x_0, t_0)
Show:  M satisfies sub_nf at (x, t)
```

The proof decomposes `nf_eval_nf M (K+2) 2 env sub_nf` into:
1. **Atom part**: handled sorry-free by `nonconstenv_atom_agree_until`
2. **Quantifier part**: for each `chi : NormalForm sig (K+1) 3`, need to transfer `exists w, nf_eval_nf M (K+1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi`

To transfer the existential witness w, the Boneyard's `nvar_transfer_from_1var_agree` requires `h_rvar`: full r-var NF agreement at depth d+1. At the target depth K+2, this requires depth K+3 agreement -- one above what the hypotheses provide.

This is a genuine circularity: to prove 2-var agreement at depth K+2, we need 2-var agreement at depth K+3.

### Q1: Does Rabinovich's Proof Avoid This Circularity?

**Yes, completely.** This is the most important finding of the audit.

Rabinovich's proof operates at an entirely different level of abstraction. His argument never mentions NF depths, cross-model transfers, or arity-climbing. Instead:

1. **Prop 4.3** uses **structural induction on FO formulas** (not on NF depth). The cases are: atomic (immediate), disjunction (immediate), negation (Prop 4.2), exists (Lemma 3.4). There is no depth parameter to consume.

2. **Prop 4.2** (negation closure) uses **Lemma 5.1** which does induction on the number of bracket witnesses n, not on depth. The key operation (interval splitting at a witness point) reduces n by 1 without touching any depth parameter.

3. **Prop 3.5** (V-EA 1-var to TL) directly constructs Until/Since chains from the bracket structure. No depth arithmetic involved.

The depth consumption problem is an artifact of the implementation's choice to use NF depth induction (CharPart/ExistPart) instead of Rabinovich's structural formula induction. In Rabinovich's framework:

- There is no "depth K+2 to depth K+1" reduction
- There is no cross-model NF transfer
- There is no arity-climbing from 1-var to 2-var to 3-var
- The entire argument works with formula-level V-EA constructions

### Q2: Is the Depth Consumption a Sign of Divergence?

**Yes, definitively.** The circular dependency is a symptom of the formalization having diverged from Rabinovich's method at the architectural level. Specifically:

**Rabinovich's method**: FO formula -> V-EA formula -> TL formula (by Prop 3.5)
- Negation handled by Lemma 5.1 at the formula level
- No normal forms, no depths, no cross-model transfer

**Implementation's method**: NF at depth k -> temporal formula (by mutual induction on k)
- ExistPart(k+1) needs to transfer existential witnesses between models
- This transfer requires NF agreement at higher depths (circular)
- The `prior_2var_transfer` theorem is the implementation's attempt to close this gap

The depth consumption is inherent to the NF-based approach. Every time the quantifier step introduces a new variable, it drops one depth level. To transfer a witness w that sits in a 3-var context at depth K+1, you need 1-var agreement at depth K+1 for w, but getting the matched w' in the other model requires the existential transfer from depth-(K+2) agreement, which is what you are trying to prove.

### Q3: Does Rabinovich Use Strong Induction (Option A)?

**No.** Rabinovich uses simple induction on n (the number of witnesses) in Lemma 5.1, not strong induction on depth. The paper has no concept analogous to NF depth.

**Option A** (strong induction on K) is a valid technique within the NF-based framework: the IH at K-1 supplies 2-var agreement at depth K+1, then `nvar_transfer_from_1var_agree` gives depth-K agreement, then `nf_eval_from_lower_agree` upgrades to depth K+2. However:

- `nf_eval_from_lower_agree` in the Boneyard has a sorry at d=0 (the base case requires Prior-UZ/SZ, not purely algebraic)
- The strong induction restructuring would require significant refactoring of PriorComposition.lean
- It is solving a problem that exists only because the formalization diverged from Rabinovich

### Q4: Could Option B (Inline into KampBypass mutual induction) Be More Faithful?

**Partially.** Option B observes that inside `kamp_mutual_induction`, the `hex` existential transfer is directly available from the CharPart/ExistPart decomposition at depth k. This avoids the circular dependency because the mutual induction ALREADY provides the existential transfer at each depth level.

Looking at the code structure, `nf_skipIdx_cross` in KampBypass.lean (lines 137-209) already does exactly this for the projection case: it takes full (n+1)-var agreement at depth k and uses the `hex` from the characteristic NF to transfer witnesses, then recurses on k with the IH. The key insight is that `nf_skipIdx_cross` has `hex` available because it receives full (n+1)-var agreement, not just 1-var agreement.

The problem with `prior_2var_transfer` is that it receives only 1-var agreement and must reconstruct 2-var agreement from it. Inside the mutual induction, the characteristic NF machinery already provides the existential transfer without needing to reconstruct multi-var agreement from 1-var components.

**Option B is closer to Rabinovich's spirit** because it uses the existing algebraic NF infrastructure rather than trying to prove a standalone composition theorem. However, it is still an NF-based approach, not a formula-level approach like Rabinovich's.

### The Most Faithful Resolution

The most faithful resolution to the circular dependency is **none of the above**. It is to abandon the NF-depth mutual induction approach entirely and instead:

1. Resolve the beta_0(r0) case in Lemma 5.1 (EANegation.lean:1047)
2. Use the resulting model-independent Lemma 5.1 to prove Prop 4.2 (model-independent)
3. Use Prop 4.2 to prove Prop 4.3 by structural induction on FO formulas
4. Use Prop 4.3 + Prop 3.5 to get the full Kamp theorem

This path has no depth arithmetic, no cross-model NF transfer, and no circular dependency. The ONLY blocker is the beta_0(r0) case, which is a finite combinatorial problem about bracket formula constructions.

### Practical Assessment

Given the history (21 plan versions, 20+ research rounds, the beta_0(r0) case having resisted all attempts), the pragmatic recommendation is:

1. **Try Option B first** (inline into KampBypass mutual induction) -- it avoids the circular dependency by using `hex` directly, and requires only local changes to KampBypass.lean
2. **If Option B fails**, try Option A (strong induction on K) -- it is algebraically correct but requires Boneyard restoration and the d=0 base case fix
3. **The fully faithful path** (resolving beta_0(r0)) should remain a long-term goal but should not block the immediate sorry elimination

## Summary

1. **Sections 3 (definitions + closure) and Prop 3.5 (translation)**: Faithfully formalized and sorry-free.
2. **Section 5 (negation closure)**: Two parallel formalizations exist. The model-dependent version (EANegationClosure.lean) is sorry-free but weaker than Rabinovich's claim. The model-independent version (EANegation.lean) follows Rabinovich closely but is blocked at one sub-case of Lemma 5.1.
3. **Section 4 (main argument)**: Replaced by a fundamentally different proof architecture (mutual induction on NF depth via KampBypass) that is NOT in Rabinovich's paper. This alternative architecture introduces its own sorry (`prior_2var_transfer`).
4. **The circular dependency in plan v22 is an inherent consequence of the NF-depth approach, not a proof engineering bug.** Rabinovich's formula-level argument avoids depth arithmetic entirely. The depth consumption problem will recur in any approach that tries to prove `prior_2var_transfer` as a standalone theorem.
5. **Option B (inlining into the mutual induction) is the recommended next step** because it avoids the circular dependency by using the existential transfer (`hex`) already available inside the induction, rather than trying to prove it from 1-var agreement alone.
6. **The two remaining sorry-bearing chains are independent**: (a) model-independent Lemma 5.1 in EANegation.lean (unused), and (b) Prior composition transfer in PriorComposition.lean (used by completeness).
7. **A fully faithful Rabinovich formalization would require resolving the beta_0(r0) case** in Lemma 5.1 backward direction. This would eliminate the need for the Kamp bypass and `prior_2var_transfer` entirely.
