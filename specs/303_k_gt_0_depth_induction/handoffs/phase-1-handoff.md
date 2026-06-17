# Phase 1 Handoff: GeneralExistPart Definition + Base Case

## Immediate Next Action
Phase 2: Prove `generalExistPart_succ` in GeneralExistPart.lean -- the inductive step
GeneralExistPart(k+1) from CharPart(k+1) + GeneralExistPart(k).

## Current State
- Phase 1 completed, sorry count in GeneralExistPart.lean: 0
- Build status: clean (lake build succeeds)
- 2 existing sorries remain in KampBypass.lean:617,669 (unchanged)

## Key Decisions
1. **GeneralExistPart parameterization**: Uses `env_nf : NormalForm sig (k+1) r` (the full
   depth-(k+1) r-var NF type) rather than individual 1-var NF types. This is a stronger
   hypothesis than what the plan originally envisioned, but it enables a much simpler k=0
   proof via cross-structure transfer. The inductive step (Phase 2) will need to construct
   the appropriate env_nf when applying the IH at higher arity.

2. **k=0 proof strategy**: Classical satisfiability split + Formula.top/Formula.bot. The
   nf_extend_fwd pattern (inlined from KampBypass.lean's private theorem) transfers
   existentials between any two environments sharing the same depth-1 r-var NF. No explicit
   zone decomposition needed at k=0.

3. **`h_surj` unused in definition**: Removed from GeneralExistPart abbrev signature. Kept
   as `_h_surj` in theorem signature for compatibility with kamp_mutual_induction call site.

## Phase 2 Considerations
- The inductive step needs to construct the (r+1)-var NF type for (Fin.cons y e) when
  applying GeneralExistPart(k) at higher arity. This NF type is the nf_characteristic
  of the extended environment, which can be obtained from nf_characteristic_satisfies.
- The formula will be a disjunction over compatible 1-var NF types for y, with each
  branch containing a zone guard (Until/Since/equality) AND a quantifier conjunction
  from GeneralExistPart(k) at arity r+1.

## Sorry Inventory
| File | Line | Statement | Next Dispatch |
|------|------|-----------|---------------|
| KampBypass.lean | 617 | backward quantifier (Until) | Phase 4 |
| KampBypass.lean | 669 | backward quantifier (Since) | Phase 4 |
