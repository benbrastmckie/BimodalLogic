# Task 303 Cycle 3 Handoff: Until/Since Backward Analysis

## Current State
- Phase 1: [COMPLETED] (mutual induction scaffold)
- Phase 2: [BLOCKED] (Until backward -- compositionality approach invalidated)
- Phases 3-6: [NOT STARTED] (dependent on Phase 2)
- 2 critical path sorries remain: KampBypass.lean:356, 368

## What Was Accomplished
Exhaustive analysis of all known approaches to closing the Until/Since backward direction sorries at KampBypass.lean:356,368. Five approaches were evaluated:

### Approach 1: Compositionality (Plan Phase 2 Strategy) -- INVALID
1-var NF types + ordering determine 2-var NF type. FALSE on Prior structures. Counterexample: M=(Z,<), env1=(0,2), env2=(0,1), k=1. Z with no predicates IS a Prior structure (UZ/SZ trivially satisfied).

### Approach 2: Formula Enrichment via ih_exist -- BLOCKED
ih_exist requires constant parent env (fun _ => t). Until zone quantifier conditions involve [y, x, t] with non-constant parent [x, t]. Cannot express ∃ y, nf_eval M (k'+1) 3 [y, x, t] ssn via ih_exist because the env Fin.cons y (fun _ => t) = [y, t, t] ≠ [y, x, t].

### Approach 3: Cross-Structure NF Transfer -- INSUFFICIENT
nf_extend_fwd from depth-(k'+2) arity-1 agreement gives depth-(k'+1) arity-2 agreement. But sub_nf is at depth k'+2 -- need same-depth 2-var agreement, not one-lower-depth.

### Approach 4: ih_exist at Different Points -- MISMATCHED
ih_exist at x with x's atoms gives env [y, x, x]. ih_exist at t with t's atoms gives env [y, t, t]. Neither matches [y, x, t] for x ≠ t.

### Approach 5: VecEA2 Generalization from k=0 -- POTENTIALLY VIABLE BUT COMPLEX
The k=0 KampBypassUntil.lean (979 lines) encodes zone-specific conditions using VecEA2 brackets with nf_depth0_char_formula. At k>0, replace nf_depth0_char_formula with char_k (ih_char). Quantifier conditions at depth k'+1 involve depth-k' multi-var NFs, creating a recursive encoding. Literature (GHR94 Section 9.3) confirms this approach is mathematically valid but the implementation scope is substantial.

## Key Decisions Made
1. Compositionality approach is definitively ruled out (counterexample confirmed on Prior structures)
2. ih_exist with constant parent env is an architectural limitation, not a bug
3. The Eq zone closure (completed in prior cycle) works BECAUSE x=t makes the parent env constant

## Proposed Path Forward (Requires Plan Revision)

### Option A: Strengthen ExistPart (Recommended)
Redefine ExistPart to handle 2-var parent envs:
```
ExistPart'(k) := ∀ r ≥ 1, parent_nf : NF k r, sub_nf : NF k (r+1),
  ∃ A, ∀ M h_UZ h_SZ t,
    nf_eval_nf M k r (fun _ => t) parent_nf →
    temporal_truth M t A ↔ ∃ x, nf_eval M k (r+1) (Fin.cons x (fun _ => t)) sub_nf
```
The formula A depends on parent_nf. The induction step at depth k+1 uses ExistPart'(k) to express quantifier conditions with non-constant parent (encoded via the parent_nf parameter). This keeps the parent env constant (fun _ => t) but conditions on the PARENT NF at arity r.

Estimated scope: ~200 lines to restructure KampMutualInduction.lean + ~300 lines to modify existPart_succ_n1_bypass.

### Option B: VecEA2 Generalization
Generalize the k=0 VecEA2 bracket construction to k>0. Replace nf_depth0_char_formula with ih_char. Handle quantifier conditions recursively via ih_exist at lower depth for each zone. Estimated scope: ~1000+ lines (mirrors 979-line KampBypassUntil.lean complexity).

### Option C: Negation Closure (Rabinovich Lemma 5.1)
Adopt Rabinovich's negation closure argument. Prior-UZ/SZ ensure interval properties are determined by boundary formulas. The boneyard (Boneyard/KampNegationClosure/) has partial infrastructure. Estimated scope: ~500 lines to revive + extend.

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|-------------|---------------|
| KampBypass.lean | 356 | existPart_succ_n1_bypass Until backward | compat_disj determines 2-var NF | ih_exist constant-parent limitation; compositionality false | Revise plan with Option A/B/C |
| KampBypass.lean | 368 | existPart_succ_n1_bypass Since backward | compat_disj determines 2-var NF | Symmetric to Until | Resolved when Until is resolved |
| NfCharFormula.lean | 542 | nf_exist_backward_prior | Prior composition property | Dead code, not critical path | Not needed |
| NfCharFormula.lean | 651 | nf_2var_exist_formula_prior k+2 | ih_char and ih_exist at depth k+1 | Filled by kamp_mutual_induction once bypass is sorry-free | Auto-resolved |
| KampMutualInduction.lean | 310 | existPart_succ n>=2 | n=1 case sorry-free | Depends on KampBypass sorries | Auto-resolved |

## Immediate Next Action
Run /revise 303 to create a new plan (v4) based on Option A (strengthened ExistPart). The key change: condition ExistPart on a parent NF at the parent arity, which allows expressing quantifier conditions for non-constant parent envs while keeping the evaluation point as a single t.

## References
- NfComposition.lean: counterexample proving compositionality false
- KampBypassUntil.lean: sorry-free k=0 VecEA2 template (979 lines)
- KampBypass.lean:376-515: sorry-free Eq zone using ih_exist at constant env
- GHR94 Section 9.3 Lemma 9.3.2: zone-by-zone encoding for Until
