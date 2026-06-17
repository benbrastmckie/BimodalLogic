# Phase 4 Handoff: BLOCKED -- GeneralExistPart Circular Precondition

**Date**: 2026-06-17
**Session**: sess_1781700693_29c274
**Phase**: 4 (Enrich Formula and Close Sorries)
**Status**: BLOCKED

## Immediate Next Action

Re-plan task 303 with corrected GeneralExistPart design. Phases 1-2 must be re-done with individual 1-var NF parameters and actual temporal formula construction before Phase 4 can proceed.

## Current State

- Phases 1-3: COMPLETED (GeneralExistPart exists sorry-free, threaded to KampBypass.lean)
- Phase 4: BLOCKED (GeneralExistPart has circular precondition at sorry site)
- Phase 5: NOT STARTED (depends on Phase 4)
- Build: passes with 2 sorries in KampBypass.lean (lines 636, 688)

## Root Cause Analysis

### The Circularity

At both sorry sites (KampBypass.lean:636 and :688), the goal is:

```
∀ ssn : NormalForm sig (k'+1) (1+1+1),
    (∃ y, nf_eval_nf M (k'+1) (1+1+1) (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    sub_nf.2 ssn = true
```

This is the QUANTIFIER PART of `nf_eval_nf M (k'+1+1) 2 (Fin.cons x (fun _ => t)) sub_nf`. The ATOM PART is already proved (`h_atom_agree`).

The `ih_general_exist` parameter (= GeneralExistPart at depth k'+1) provides: for any `env_nf : NormalForm sig (k'+1+1) 2` and `ssn : NormalForm sig (k'+1) 3`, there exists formula A such that for any M with `e` satisfying `nf_eval_nf M (k'+1+1) 2 e env_nf`, temporal_truth of A at `e 0` iff the existential.

Using `env_nf = sub_nf`: the precondition becomes `nf_eval_nf M (k'+1+1) 2 (Fin.cons x (fun _ => t)) sub_nf`, which has atoms (proved) AND quantifiers (the goal). So the precondition IS the goal. Circular.

### Why Formula.top/bot Doesn't Help

GeneralExistPart was proved using a classical satisfiability split: if the existential is satisfiable for ANY env matching env_nf, use Formula.top; otherwise Formula.bot. This means:

- For `sub_nf.2 ssn = true`: A_ssn = Formula.top (trivially true, encodes no information)
- For `sub_nf.2 ssn = false`: A_ssn = Formula.bot (trivially false, encodes no information)

Putting Formula.top/Formula.bot inside the Until guard adds NO information to the enriched formula. The enriched formula is semantically equivalent to the original formula.

### Why 1-var NF Agreement Is Insufficient

The 2-var NF agreement `nf_eval_nf M (k'+1+1) 2 [x,t] sub_nf` cannot be derived from individual 1-var NF agreements `h_x_agree` and `h_t_agree` plus matching order. Counterexample: Z with (0,2) vs (0,1) -- same 1-var NFs at all depths, same order, but different 2-var NFs (the between-zone is non-empty for (0,2) but empty for (0,1)). This is documented in NfComposition.lean.

## Fix Required

Re-implement GeneralExistPart with the ORIGINAL research design (report 05, Section 2.2):

1. **Parameter change**: `env_nf : NormalForm sig (k+1) r` becomes `env_nfs : Fin r -> NormalForm sig (k+1) 1`
2. **Precondition change**: `nf_eval_nf M (k+1) r e env_nf` becomes `∀ i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)`
3. **Formula construction**: Zone decomposition + recursive encoding (Rabinovich Prop 3.5 pattern) instead of Formula.top/bot classical split
4. **Proof**: By induction on depth k with arity r universally quantified (depth decreases, arity increases -- well-founded)

After this change:
- `ih_general_exist`'s precondition becomes individual 1-var NF matches
- At the sorry site: `h_x_agree` and `h_t_agree` directly satisfy the precondition
- The formula encodes actual quantifier information (not trivially true/false)
- Backward proof extracts quantifier conditions from the formula

## Key Decisions

- GeneralExistPart.lean (207 lines, sorry-free) should be REPLACED entirely
- The cross-structure transfer approach (Formula.top/bot) is mathematically valid for proving existence but functionally useless at the sorry site
- The existing ih_general_exist parameter in KampBypass.lean has the RIGHT type shape but will need updating when GeneralExistPart's signature changes

## Sorry Inventory

| File | Line | Status | Resolution |
|------|------|--------|------------|
| KampBypass.lean | 636 | BLOCKED | Requires re-implemented GeneralExistPart |
| KampBypass.lean | 688 | BLOCKED | Mirror of 636 |
| NfCharFormula.lean | 542 | Non-goal | Dead code path |
| NfCharFormula.lean | 651 | Non-goal | Dead code path |

## References

- `specs/303_k_gt_0_depth_induction/reports/05_recursive-formula-design.md` Section 2.2: original GeneralExistPart design with individual 1-var NFs
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` lines 19-37: counterexample for composition theorem
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean`: current implementation
