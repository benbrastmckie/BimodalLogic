# Research Report: Literature-First Construction for k>0 Depth Induction

**Task**: 303 (k_gt_0_depth_induction)
**Session**: sess_1781705483_67e1df
**Mode**: hard (H2, H3, H4, H5)
**Date**: 2026-06-17
**Tier**: 1 (literature-backed, Rabinovich 2014 primary source)

## Summary

This report extracts the exact construction from Rabinovich 2014 (Proposition 3.5, Section 5) and maps it to the existing Lean formalization. The key finding is that the sorry sites in KampBypass.lean require a ZONE DECOMPOSITION formula construction that follows Rabinovich's interval-decomposition approach. The current GeneralExistPart (Formula.top/bot classical satisfiability split) cannot close the sorry because it requires full 2-var NF agreement as a precondition, creating circularity. The fix is a redesigned GeneralExistPart with individual 1-var NF parameters and an actual temporal formula built via zone enumeration.

## H3 Reference Grounding Table (Tier 1)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|--------------|-----------------|----------------|--------|
| Rabinovich 2014, Def 3.1 | Exists-forall formula: zone decomposition | `NormalForm sig k r` | `(AtomKind sig r -> Bool) x (NormalForm sig (k-1) (r+1) -> Bool)` | Implemented (different formalism) |
| Rabinovich 2014, Prop 3.5 | V-EA with 1 free var -> TL via nested Until/Since | `enriched_vecEA2_until/since` | Zone-specific Until/Since nesting | Implemented at k=0 only |
| Rabinovich 2014, Lemma 3.4 | V-EA closed under exists quantification | `ExistPart k` | `forall n >= 1 ... exists A, temporal_truth <-> exists x, nf_eval_nf ...` | Implemented, sorry at k>0 |
| Rabinovich 2014, Prop 4.2 | Closure under negation | `charPart_succ` + `existPart_succ` | Mutual induction on k | Sorry at existPart_succ for k>0 |
| Rabinovich 2014, Sec 5, Lemma 5.1 | Interval splitting for negation closure | Zone bridge infrastructure | `ssn_zone_until/since` patterns | Implemented at k=0 only |
| NfComposition.lean | 1-var NFs + order do NOT determine 2-var NF | Counterexample documented | Z, (0,2) vs (0,1) | Confirmed -- blocks naive transfer |
| KampBypass.lean:636,688 | Sorry sites: backward quantifier transfer | `existPart_succ_n1_bypass` k>0 case | Goal: transfer 3-var existentials from M0 to M | SORRY (2 sites) |

## Finding 1: Rabinovich's Construction (Proposition 3.5, Exact Statement)

From Rabinovich 2014, Proposition 3.5 (page 5):

> **Proposition 3.5**: Every V-exists-forall formula with one free variable is equivalent to a TL(Until, Since) formula.

> **Proof sketch**: An exists-forall formula with one free variable at position z_k in a sequence x_0 < ... < x_n is equivalent to the conjunction of:
> - A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))
> - A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... (A_0 AND Overleftarrow-Box B_0)...)))

This is the core mechanism: **the interval decomposition directly maps to nested Until/Since**. Each A_i is the type at witness point x_i, and each B_j is the type along the interval (x_{j-1}, x_j).

### What this means for the Lean formalization

In the Lean formalization, the "exists-forall formula" corresponds to `NormalForm sig k (r+1)`. The free variable z_k is `e 0` (the point where we evaluate the temporal formula). The existentially quantified variables x_0 < ... < x_n are encoded in the NF's zones.

The Rabinovich construction says: to characterize `exists y, nf_eval_nf M k (r+1) (Fin.cons y e) ssn`, decompose into zones based on where y falls relative to the elements of e, and build nested Until/Since formulas.

## Finding 2: The Exact Sorry Goal and Why it Resists Current Infrastructure

### Goal at line 636 (Until zone, k > 0)

```
forall (sub_nf_1 : NormalForm sig (k' + 1) (1 + 1 + 1)),
    (exists x_1, nf_eval_nf M (k' + 1) (1 + 1 + 1)
      (Fin.cons x_1 (Fin.cons x (fun _ => t))) sub_nf_1) <->
    sub_nf.2 sub_nf_1 = true
```

Available hypotheses:
- `h_x_agree`: 1-var NF agreement at x/x0 (depth k'+1+1)
- `h_t_agree`: 1-var NF agreement at t/t0 (depth k'+1+1)
- `h_atom_agree`: 2-var ATOM agreement at [x,t]/[x0,t0]
- `h_eval0_quant`: M0 answers for all 3-var existentials at [y,x0,t0]
- `h_tx`: t < x, `h_order0`: t0 < x0

### Why the transfer fails

To use `nf_extend_fwd` (already proved in file) to transfer 3-var existentials from M0 to M, we need FULL depth-(k'+1+1) 2-var NF agreement:
```
forall nf, nf_eval_nf M (k'+1+1) 2 (Fin.cons x (fun _ => t)) nf <->
           nf_eval_nf M0 (k'+1+1) 2 (Fin.cons x0 (fun _ => t0)) nf
```

We have the ATOM part (h_atom_agree). But the QUANTIFIER part of 2-var NF agreement IS EXACTLY the 3-var existential transfer -- the goal we're trying to prove. Circularity.

### Why Formula.top/bot cannot work

The NfComposition.lean counterexample proves that 1-var NF agreement + order matching does NOT determine 2-var NF. Counterexample: M = (Z, <) with no predicates, env1 = (0, 2), env2 = (0, 1). Both points have the same 1-var NF, 0 < 2 and 0 < 1, but (0,2) has an intermediate point and (0,1) does not. The depth-1 2-var NFs differ.

Therefore the classical satisfiability split (which produces Formula.top or Formula.bot) carries NO information about which 3-var existentials hold. The formula cannot distinguish two environments that agree on 1-var NFs but disagree on 2-var NFs.

## Finding 3: The Fix -- Redesigned GeneralExistPart with Zone Decomposition

### The redesigned definition

```lean
abbrev GeneralExistPart' {sig : MonadicSignature}
    (atomMap : Formula -> sig.preds) (k : Nat) : Prop :=
  forall (r : Nat) (_ : r >= 1)
    (char_k : NormalForm sig k 1 -> Formula)
    (char_k_correct : ...)
    (env_nfs : Fin r -> NormalForm sig (k + 1) 1)  -- individual 1-var NFs
    (ssn : NormalForm sig k (r + 1)),
    exists (A : Formula),
      forall (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (e : Fin r -> M.carrier),
        (forall i, nf_eval_nf M (k + 1) 1 (fun _ => e i) (env_nfs i)) ->
        (temporal_truth M atomMap (e 0) A <->
         exists y, nf_eval_nf M k (r + 1) (Fin.cons y e) ssn)
```

### Key change: 1-var NF parameters instead of full r-var NF

The precondition changes from:
- OLD: `nf_eval_nf M (k+1) r e env_nf` (full r-var NF, circular at sorry sites)
- NEW: `forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)` (individual 1-var NFs, satisfiable from h_x_agree/h_t_agree)

### Key change: actual temporal formula instead of top/bot

The formula must perform ACTUAL zone decomposition per Rabinovich Prop 3.5:

**Zone enumeration for `exists y, nf_eval_nf M k (r+1) (Fin.cons y e) ssn`**:

The atom part of ssn determines the ordering of y relative to each e(i). The zones are:
- y < min(e): "y is before all environment elements"
- y = e(i): "y coincides with environment element i"
- e(i) < y < e(i+1): "y is between consecutive elements"
- y > max(e): "y is after all environment elements"

For each zone, the temporal formula is:
- **y < min(e)**: `char_k(tau_y) Since top` evaluated at min(e)
- **y > max(e)**: `char_k(tau_y) Until top` evaluated at max(e)
- **y = e(i)**: `char_k(tau_y)` evaluated at e(i), with recursive quantifier conditions
- **y in (e(i), e(i+1))**: zone bridge formula via Prior structures

The big picture formula is the disjunction over all zones.

## Finding 4: How the Sorry Closes with Redesigned GeneralExistPart'

### Modified enriched Until formula

For the Until zone (t < x), the formula becomes:

```lean
let char_k := fun nf_k => (ih_char nf_k).choose
-- Build ih_general_exist' formulas for each 3-var NF
let quant_formula : NormalForm sig (k' + 1) 3 -> Formula := fun ssn =>
  (ih_general_exist' 2 (by omega) char_k char_k_correct
    ![nf_x0, nf_t0] ssn).choose  -- 1-var NFs for [x,t]
let quant_conj := formula_conjList
  (NF(k'+1, 3).list.map fun ssn =>
    if sub_nf.2 ssn then quant_formula ssn
    else (quant_formula ssn).neg)
let enriched_x_type := Formula.and (char_kp1 nf_x0) quant_conj
let until_formula := Formula.and (char_kp1 nf_t0)
  (enriched_x_type.untl Formula.top)
```

### Backward direction proof sketch

1. From `temporal_truth M atomMap t until_formula`:
   - Extract `h_t_nf : temporal_truth M atomMap t (char_kp1 nf_t0)` => t has 1-var NF nf_t0
   - Extract Until witness x with `enriched_x_type` holding at x
2. From `enriched_x_type` at x:
   - `h_x_nf : temporal_truth M atomMap x (char_kp1 nf_x0)` => x has 1-var NF nf_x0
   - `h_quant : temporal_truth M atomMap x quant_conj` => quant_conj holds at x
3. From quant_conj at x:
   - For each ssn : NF(k'+1, 3):
   - `temporal_truth M atomMap x (quant_formula ssn)` <-> `sub_nf.2 ssn = true`
4. Apply `ih_general_exist'` correctness:
   - Precondition: `nf_eval_nf M (k'+1+1) 1 (fun _ => x) nf_x0` -- HAVE (h_x_eval)
   - Precondition: `nf_eval_nf M (k'+1+1) 1 (fun _ => t) nf_t0` -- HAVE (h_t_eval)
   - Conclusion: `temporal_truth M atomMap x (quant_formula ssn)` <-> `exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn`
5. Combined: `forall ssn, (exists y, nf_eval_nf M (k'+1) 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) <-> sub_nf.2 ssn = true`
6. This IS the sorry goal. QED.

### Why the circularity is broken

- OLD `ih_general_exist` needs `nf_eval_nf M (k'+1+1) 2 (Fin.cons x (fun _ => t)) sub_nf` as precondition -- which IS the goal
- NEW `ih_general_exist'` needs `nf_eval_nf M (k'+1+1) 1 (fun _ => x) nf_x0` AND `nf_eval_nf M (k'+1+1) 1 (fun _ => t) nf_t0` -- which we HAVE from the enriched formula

## Finding 5: Induction Structure for GeneralExistPart'

### Base case: GeneralExistPart'(0)

At depth 0, `exists y, nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn` is purely atomic. The ssn determines:
- Ordering of y relative to each e(i) (from ssn.1's order atoms)
- Predicate type of y (from ssn.1's pred atoms)

The formula is a zone-specific temporal encoding:
- For each consistent zone (y's ordering pattern relative to e):
  - Build `char_0(tau_y)` for y's predicate type
  - Build zone formula: e.g., `char_0(tau_y) Until char_0(tau_{e(i+1)})` from e(i)
  - Conjoin with type checks for e(i)'s matching env_nfs
- Disjoin over all consistent zones

This requires Prior structures (semantic_prior_UZ/SZ) to ensure the temporal formula correctly encodes the zone existence.

### Inductive step: GeneralExistPart'(k+1)

The existential `exists y, nf_eval_nf M (k+1) (r+1) (Fin.cons y e) ssn` decomposes as:
- **Atom part**: zone of y + predicate type of y (same as k=0)
- **Quantifier part**: `forall chi : NF(k, r+2), (exists z, nf_eval_nf M k (r+2) (Fin.cons z (Fin.cons y e)) chi) <-> ssn.2(chi)`

The quantifier part is `GeneralExistPart'(k)` at arity r+1 (with env_nfs for [y, e(0), ..., e(r-1)]).

**Depth decreases from k+1 to k**, so recursion terminates.

The formula construction:
1. For each zone of y relative to e:
   - Build zone-specific temporal formula (atom part)
   - Build quantifier conjunction using `GeneralExistPart'(k)` at arity r+1
   - Combine with conjunction
2. Disjoin over all zones

### Mutual induction structure

```
CharPart(0)           <-- nf_depth0_char_formula (sorry-free)
ExistPart(0)          <-- nf_2var_exist_formula_prior (sorry-free)
GeneralExistPart'(0)  <-- NEW: zone decomposition, all arities (sorry-free if built)

CharPart(k+1)         <-- CharPart(k) + ExistPart(k) (sorry-free, unchanged)
ExistPart(k+1)        <-- CharPart(k+1) + ExistPart(k) + GeneralExistPart'(k) (sorry closes!)
GeneralExistPart'(k+1) <-- CharPart(k+1) + GeneralExistPart'(k) (new, no circularity)
```

All dependencies point to LOWER depth k. No circularity.

## Finding 6: What Exists vs What's Missing

### Already implemented (sorry-free, reusable for k>0)

| Component | File | Status |
|-----------|------|--------|
| NormalForm types | NormalForm.lean | Complete |
| nf_eval_nf, nf_characteristic | NormalForm.lean | Complete |
| nf_agreement_from_shared_nf | NormalForm.lean | Complete |
| nf_extend_fwd/bwd | KampBypass.lean | Complete |
| nf_skipIdx_cross | KampBypass.lean | Complete |
| nonconstenv_atom_agree_until/since | KampBypass.lean | Complete |
| exist_transfer_const_env | KampBypass.lean | Complete |
| charPart_zero, charPart_succ | KampMutualInduction.lean | Complete |
| existPart_zero | KampMutualInduction.lean | Complete |
| existPart_succ (eq zone, k>0) | KampBypass.lean:705-844 | Complete |
| existPart_succ_n1_bypass_k0 | KampBypass.lean:321-360 | Complete |
| constenv_2var_determines | NfComposition.lean | Complete |
| nf_drop_last_cross | NfComposition.lean | Complete |
| Prior zone formulas (UZ/SZ) | PriorDefs.lean, PriorExpressiveness.lean | Complete |
| Zone bridge infrastructure | ZoneBridge.lean | Complete |

### Must be implemented (new)

| Component | Est. Lines | Difficulty |
|-----------|-----------|------------|
| GeneralExistPart' definition (redesigned) | 25-35 | Low |
| Zone enumeration for r-var environments | 80-120 | Medium |
| generalExistPart'_zero (k=0, zone construction) | 300-500 | High |
| generalExistPart'_succ (k+1, recursive formula) | 200-400 | High |
| Enriched Until formula (modified KampBypass) | 100-150 | Medium |
| Enriched Since formula (mirror) | 100-150 | Medium |
| Modified kamp_mutual_induction (3 conjuncts) | 40-60 | Low |
| **Total new code** | **845-1415** | |

## Finding 7: Comparison with Other Literature Sources

### Gabbay, Hodkinson, Reynolds 1994 (Chapter 10)

The Gabbay et al. approach uses the SEPARATION property: every TL formula is equivalent to a Boolean combination of "pure past", "present", and "pure future" formulas. The separation proof (Theorem 10.3.20) proceeds through an elimination procedure:
- Remove Until from within Since (via K+/K- eliminations)
- Iterate on junction depth

This is a DIFFERENT proof strategy from Rabinovich. It does not use the exists-forall normal form and does not directly produce a zone decomposition formula. For the Lean formalization, the Rabinovich approach is a better fit because:
1. The NormalForm type already encodes the exists-forall structure
2. The mutual induction (CharPart + ExistPart) matches Rabinovich's proof structure
3. The k=0 case is already implemented following Rabinovich

### Doets 1989

Doets works with EF games and n-equivalence at the formula level, not the NF level. The composition Lemma 1.4/1.5 applies to the ORDERED SUM of structures, which is the setting for NEquivalence.lean. The intra-structure composition (NfComposition.lean) is a specialization. Doets' approach is already used in the codebase for the ordered sum infrastructure but does not directly help with the GeneralExistPart construction.

### Verdict: Rabinovich is the right source

The Lean formalization should continue following Rabinovich 2014. The exists-forall normal form (Def 3.1) maps to `NormalForm sig k r`, and Proposition 3.5 (V-EA -> TL via nested Until/Since) provides the exact construction needed for `GeneralExistPart'`.

## Adversarial Self-Verification

| Challenge | Verdict |
|-----------|---------|
| Does the redesigned GeneralExistPart' actually break the circularity? | **YES** -- the precondition `forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)` is satisfiable from h_x_agree/h_t_agree, unlike the old `nf_eval_nf M (k+1) r e env_nf` which IS the goal |
| Can Formula.top/bot work with any modification? | **NO** -- the NfComposition.lean counterexample is definitive: 1-var NFs + order do not determine the 3-var existentials, so any formula that ignores zone structure will be wrong |
| Does the induction terminate? | **YES** -- GeneralExistPart'(k+1) uses GeneralExistPart'(k) at depth k (decreased), CharPart(k+1) is from lower depth |
| Is the zone decomposition implementable on Prior structures? | **YES (90% confidence)** -- the k=0 case already has zone bridge infrastructure (enriched_vecEA2_until/since). The k>0 case extends this with char_k formulas. Uncertainty: the Prior zone formulas may need extension for multi-variable environments |
| Does the eq-zone case (lines 705-844) need modification? | **NO** -- it already works because x = t makes the env constant. The enriched formula pattern for Until/Since mirrors this but at x instead of t |
| Could there be a simpler approach? | **UNLIKELY** -- the counterexample in NfComposition.lean proves that ANY approach must construct zone-aware formulas. Classical satisfiability splits (top/bot) are provably insufficient |
| Is the estimated line count realistic? | **YES** -- the k=0 zone infrastructure is ~400 lines (KampBypassUntil/Since). The k>0 extension adds recursive quantifier handling but reuses the zone enumeration |

### Revised claims after verification

- **Report 06's Finding 5 (induction structure)**: CONFIRMED. The mutual induction with 3 conjuncts is correct.
- **Report 06's Finding 3 (redesigned definition)**: CONFIRMED and REFINED. This report provides the exact formula construction from Rabinovich Prop 3.5.
- **Report 06's Finding 6 (third conjunct)**: CONFIRMED. The dependency graph has no cycles.

## Literature Proof Structure (Tier 1)

### Rabinovich 2014, full proof chain for Kamp's Theorem

**Step 1** (Def 3.1): Define exists-forall formulas as interval decompositions.
- Lean: `NormalForm sig k r` (atom part = ordering + predicates, quant part = sub-NF satisfiability)

**Step 2** (Lemma 3.2): Closure properties -- conjunction of EA formulas = disjunction of EA formulas.
- Lean: Built into the NF formalism (NFs are finite, enumerate all combinations)

**Step 3** (Lemma 3.4): V-EA closed under disjunction, conjunction, existential quantification.
- Lean: `existPart_zero` (depth 0), `existPart_succ` (depth k+1)

**Step 4** (Prop 3.5): V-EA with 1 free var -> TL formula via nested Until/Since.
- Lean: `enriched_vecEA2_until/since` (depth 0), **NEW GeneralExistPart'** (all depths)

**Step 5** (Prop 4.2): Closure under negation via interval splitting (Lemma 5.1).
- Lean: `charPart_succ` (uses ExistPart to handle negation)

**Step 6** (Prop 4.3): Every FO formula -> V-EA.
- Lean: `kamp_mutual_induction` (CharPart AND ExistPart for all k)

**Step 7** (Thm 4.4): Kamp's Theorem: FO formula -> TL formula.
- Lean: `kamp_forward` (combines Prop 4.3 and Prop 3.5)

### Where the sorry blocks the chain

Step 4 (Prop 3.5) at depth k>0 is incomplete. This blocks Step 3 (existPart_succ at k>0), which blocks Step 6 (kamp_mutual_induction), which blocks Step 7.

The fix is to implement Step 4 fully via GeneralExistPart' with zone decomposition.

## Tactic Survey Results

Not applicable (this is a research report, not an implementation report). However, the following tactics will be critical for the implementation:

- `Fin.cases` / `match i with | 0 => ... | succ j => ...` : zone enumeration over Fin r
- `formula_conjList_iff` / `formula_disjList_iff` : big conjunction/disjunction reasoning
- `nf_agreement_from_shared_nf` : transfer between structures sharing an NF
- `nf_characteristic_satisfies` : characteristic NF exists and is unique

## Estimated Implementation Complexity

| Phase | Description | Lines | Dependencies |
|-------|-------------|-------|-------------|
| 1 | GeneralExistPart' definition + zone enumeration | 150-200 | None |
| 2 | generalExistPart'_zero (depth 0, all arities) | 300-500 | Phase 1 + Prior zone infrastructure |
| 3 | generalExistPart'_succ (depth k+1, recursive) | 200-400 | Phase 2 + CharPart(k+1) |
| 4 | Enriched Until/Since formulas in KampBypass | 200-300 | Phase 1 definition |
| 5 | Modified kamp_mutual_induction (3 conjuncts) | 40-60 | Phases 2-4 |
| **Total** | | **890-1460** | |
