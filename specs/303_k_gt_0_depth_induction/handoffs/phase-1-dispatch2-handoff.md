# Handoff: Task 303 Phase 1 Dispatch 2 — GeneralExistPartIndiv Definition

## Current State

Phase 1 IN PROGRESS. Type signature implemented and compiling. Proofs are sorry.

## What Was Accomplished

1. **Defined `GeneralExistPartIndiv`** (line 62-83 of GeneralExistPart.lean):
   - Uses `env_nfs : Fin r -> NormalForm sig (k+1) 1` (individual 1-var NFs)
   - Precondition: `forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)`
   - Formula evaluated at `e 0`
   - This IS satisfiable at the sorry sites (from h_x_eval and h_t_eval)

2. **Preserved `GeneralExistPart`** (old type, line 94-115):
   - Kept for backward compatibility with KampMutualInduction call sites
   - Uses `env_nf : NormalForm sig (k+1) r` (full r-var NF)

3. **Sorry-free backward compatibility** (lines 175-227):
   - `generalExistPart_from_classical`: classical top/bot proof with full r-var NF (sorry-free)
   - `generalExistPart_all`: calls `generalExistPart_from_classical` (sorry-free)
   - These preserve existing call sites in KampMutualInduction.lean lines 311, 325

4. **Stub proofs** (sorry, lines 143 and 171):
   - `generalExistPartIndiv_zero`: needs zone decomposition (Rabinovich Prop 3.5)
   - `generalExistPartIndiv_succ`: needs CharPart(k+1) + GeneralExistPartIndiv(k) + zone decomp

## Build Status

- `lake build` passes (1757 jobs, no errors)
- 2 sorry in GeneralExistPart.lean (generalExistPartIndiv_zero, generalExistPartIndiv_succ)
- 2 sorry in KampBypass.lean:636,688 (unchanged target sorry sites)
- No regressions in KampMutualInduction or downstream

## Key Design Decisions

1. **Individual 1-var NFs break the circularity**: The precondition `forall i, nf_eval_nf M (k+1) 1 (fun _ => e i) (env_nfs i)` is satisfiable at the sorry site (from h_x_eval and h_t_eval in KampBypass.lean), unlike the old full r-var NF precondition.

2. **Classical top/bot CANNOT work with individual 1-var NFs**: The counterexample (Z with [0,2] vs [0,1]) shows that individual 1-var NF agreements do NOT determine r-var NF agreements. So the formula must be built by zone decomposition, not by classical satisfiability.

3. **Backward compatibility is self-contained**: `generalExistPart_from_classical` doesn't depend on GeneralExistPartIndiv at all. It uses the old full r-var NF precondition + classical satisfiability. This means the existing call sites in KampMutualInduction.lean work without any changes.

4. **CharPart(k+1) inlined in generalExistPartIndiv_succ**: Since CharPart is defined in KampMutualInduction.lean (which imports GeneralExistPart.lean), the CharPart type is inlined in the theorem signature to avoid circular imports.

## Immediate Next Action

Prove `generalExistPartIndiv_zero` via zone decomposition at depth 0:

1. At depth 0, `nf_eval_nf M 0 (r+1) (Fin.cons y e) ssn` is purely atomic
2. For each ssn, classify which zone positions for y are compatible
3. For each compatible zone, build a temporal formula using nested Until/Since
4. The formula A is a disjunction over compatible (zone, 1-var NF type for y) pairs
5. Each disjunct uses char_0 formulas (from char_0_correct) + Until/Since for zone position

Key infrastructure:
- `nf_depth0_char_formula` / `nf_depth0_char_formula_correct` in Separation.lean
- `enriched_vecEA2_until` / `enriched_vecEA2_since` in KampBypassUntil/Since.lean
- `VecEADecomp.lean` for zone classification
- `ZoneBridge.lean` for zone <-> temporal bridge

## Sorry Inventory

| File | Line | Statement | Why Deferred | Next |
|------|------|-----------|--------------|------|
| GeneralExistPart.lean | 143 | generalExistPartIndiv_zero | Needs zone decomposition | Build zone formula |
| GeneralExistPart.lean | 171 | generalExistPartIndiv_succ | Depends on zero case + CharPart | After zero case |
| KampBypass.lean | 636 | Until zone quant part | Needs GeneralExistPartIndiv (Phase 4) | After Phases 1-3 |
| KampBypass.lean | 688 | Since zone quant part | Mirror of 636 | After Phases 1-3 |
