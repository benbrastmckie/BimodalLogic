# Handoff: KampBypass Until/Since Sorries Closed

## Immediate Next Action
Prove `generalExistPartOrdered_zero` (GeneralExistPart.lean:174) and
`generalExistPartOrdered_succ` (GeneralExistPart.lean:207).

## Current State
- **KampBypass.lean**: ZERO sorries. `existPart_succ_n1_bypass` verified
  sorry-free (lean_verify: no sorryAx). The Until and Since zone formulas
  are enriched with quantifier conjunctions from ih_general_exist.
- **KampMutualInduction.lean**: Updated to include GeneralExistPartOrdered
  as third mutual induction conjunct. `kamp_mutual_induction` has sorryAx
  only from GeneralExistPartOrdered.
- **GeneralExistPart.lean**: 2 sorries remain:
  - Line 174: `generalExistPartOrdered_zero` (base case)
  - Line 207: `generalExistPartOrdered_succ` (inductive step)

## Key Decisions

### GeneralExistPartOrdered vs GeneralExistPartIndiv
The original plan's `GeneralExistPartIndiv` (individual 1-var NFs without orders)
is **FALSE**. A temporal formula at e(0) cannot detect the order of other env
elements, but the existential truth value depends on these orders (Z counterexample:
integers with uniform predicate, [0,2] vs [0,1]).

`GeneralExistPartOrdered` adds `env_atoms : AtomKind sig r -> Bool` as a
precondition alongside `env_nfs`. This provides the formula with knowledge of
pairwise orders, making the proposition TRUE.

### Enriched Formula Structure
Until zone: `char(nf_t0) AND ((char(nf_x0) AND quant_conj) U top)`
Since zone: `char(nf_t0) AND ((char(nf_x0) AND quant_conj) S top)`

quant_conj is built from ih_general_exist at r=2, env_nfs = [nf_x0, nf_t0],
env_atoms = sub_nf.1. Each conjunct is either ge_formula(ssn) or its negation
depending on sub_nf.2(ssn).

### Proof Strategy for Remaining Sorries

**generalExistPartOrdered_zero** (depth 0):
- At depth 0, nf_eval_nf is purely atomic
- For r=1 (constant env): classical top/bot works via exist_transfer_const_env
- For r>=2: need zone decomposition. The between-zone existential is NOT
  determined by env_nfs + env_atoms alone (Z counterexample with gap).
  Must build actual temporal formulas using nested Until/Since.
- Existing infrastructure: ZoneBridge.lean has zone_bridge_above_x/between_tx/
  below_t/eq_x/eq_t for depth-0 arity-3 (the r=2 case).
- The formula for each zone uses char_0 formulas and temporal operators.

**generalExistPartOrdered_succ** (depth k+1):
- Atom part: same zone decomposition as depth 0
- Quantifier part: for each chi : NF(k, r+2), use ih_gen_exist_k at arity r+1
- Recursive: depth decreases, so well-founded

## Sorry Inventory

| File | Line | Statement | Why Deferred |
|------|------|-----------|--------------|
| GeneralExistPart.lean | 174 | generalExistPartOrdered_zero | Requires zone decomposition at depth 0 |
| GeneralExistPart.lean | 207 | generalExistPartOrdered_succ | Depends on zero + zone decomposition at k+1 |

## References
- ZoneBridge.lean: zone_bridge_above_x, zone_bridge_between_tx, etc.
- KampBypassUntil.lean: enriched_vecEA2_until (depth-0 zone formula construction)
- KampBypassSince.lean: enriched_vecEA2_since (mirror)
- exist_transfer_const_env (KampBypass.lean): constant-env existential transfer
