# Handoff: Phase 4 Complete, Axiom Soundness Issues Found

## Session
- Session ID: sess_1775236244_b897b2
- Agent: lean-implementation-agent
- Date: 2026-04-03

## Completed Work

### Phase 4: Soundness Lemmas and Algebraic Layer [COMPLETED]
- Changed STSA TL axiom from `H(a) ⊓ G(a) ≤ G(H(a))` to `H(a) ⊓ a ⊓ G(a) ≤ G(H(a))`
- Rewrote TL_quot proof to work without temp_t_future
- Updated docstrings in SoundnessLemmas.lean, LinearityDerivedFacts.lean, FrameConditions/Soundness.lean
- InteriorOperators.lean already clean (G/H interior removed in prior work)
- Committed as `db7969f83`

### Phase 5: Partial Progress (Uncommitted)
- FMCSDef.lean: Changed FMCS structure from `≤` to `<` for forward_G/backward_H
- CanonicalIrreflexivity.lean: Removed `existsTask_reflexive`, `existsTask_past_reflexive`, `lt_of_existsTask_and_not_reverse` and their aliases
- SuccChainFMCS.lean: Removed `succ_chain_forward_G_le` and `succ_chain_backward_H_le` wrappers; SuccChainFMCS now uses strict versions directly

### Phase 3: Fixes Applied (Uncommitted)
- Soundness.lean: Fixed `Order.le_pred_iff_of_not_isMin` → `Order.le_pred_of_lt` (4 occurrences)
- Soundness.lean: Fixed `Order.lt_succ_iff_of_not_isMax` → `Order.le_of_lt_succ` (4 occurrences)
- Soundness.lean: Fixed `Succ.rec` usage (must use `refine Succ.rec ?_ ?_` instead of `induction ... using Succ.rec`)

## Critical Issues Found

### Issue 1: until_induction Axiom Was Unsound

The `until_induction` axiom as formulated was:
```
(ψ → χ) ∧ (φ ∧ X(χ) → χ) → (φ U ψ) → X(χ)
```

This is UNSOUND because the premises `ψ → χ` and `φ ∧ X(χ) → χ` are only evaluated at time `t`, not at all future times. The induction proof needs these premises at each time point along the successor chain from `succ(t)` to the witness `s`.

**Fix applied**: Changed to G-quantified premises:
```
G(ψ → χ) ∧ G(φ ∧ X(χ) → χ) → (φ U ψ) → X(χ)
```

Mirror change for `since_induction`:
```
H(ψ → χ) ∧ H(φ ∧ Y(χ) → χ) → (φ S ψ) → Y(χ)
```

**Status**: Axiom definitions in Axioms.lean updated. Substitution.lean updated. Soundness proof rewritten for the new signature. Since_induction soundness proof rewritten. Build NOT yet verified.

### Issue 2: until_linearity Axiom Unsound Under Strict Until

The `until_linearity` axiom was:
```
(φ U ψ) ∧ (φ' U ψ') → (φ U (ψ ∧ (φ' U ψ'))) ∨ (φ' U (ψ' ∧ (φ U ψ)))
```

This is UNSOUND under strict Until when both witnesses `s1` and `s2` coincide (`s1 = s2 = s`). In that case:
- Left disjunct needs `(φ' U ψ')(s)` which requires a FUTURE ψ' witness from `s`, but ψ' holds AT `s`, not after.
- Right disjunct has the same problem symmetrically.

**Counterexample**: t=0, s=1, φ=φ'=⊤, ψ=ψ'= "true only at 1". Both `⊤ U ψ` and `⊤ U ψ'` hold at 0 (witness 1), but neither disjunct can be satisfied because the inner Until at s=1 needs a witness strictly after 1.

**Fix applied**: Added third disjunct `X(ψ ∧ ψ')`:
```
(φ U ψ) ∧ (φ' U ψ') → (φ U (ψ ∧ (φ' U ψ'))) ∨ (φ' U (ψ' ∧ (φ U ψ))) ∨ X(ψ ∧ ψ')
```

Mirror for `since_linearity` with `Y(ψ ∧ ψ')`.

**Status**: Axiom definitions updated. Soundness proof partially rewritten (sorry remains for the equal case handling of the new goal structure). Build NOT yet verified.

### Issue 3: WitnessSeed.lean Broken

WitnessSeed.lean (lines 467, 584) references the old `until_induction`/`since_induction` axiom shapes and needs updating for the new G/H-quantified versions.

## Files Modified (Uncommitted)

| File | Changes |
|------|---------|
| Theories/Bimodal/ProofSystem/Axioms.lean | until/since_induction: G/H quantifiers; until/since_linearity: third disjunct |
| Theories/Bimodal/ProofSystem/Substitution.lean | Updated simp lemmas for new axiom shapes |
| Theories/Bimodal/Metalogic/Soundness.lean | Multiple fixes: le_pred, lt_succ, Succ.rec, induction proofs |
| Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean | FMCS ≤ → < |
| Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean | Removed reflexive theorems |
| Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean | Removed _le wrappers |

## Downstream Impacts of Axiom Changes

The axiom changes (G/H quantifiers on induction, third disjunct on linearity) will cascade to:

1. **SoundnessLemmas.lean**: `axiom_swap_valid` cases for until_induction, since_induction, until_linearity, since_linearity need updating (currently filtered as `exact absurd h_dc id` so may still work)
2. **WitnessSeed.lean**: Uses until_induction and since_induction axioms directly in proof terms
3. **DovetailedChain.lean**: References these axioms
4. **TenseS5Algebra.lean linearity_quot**: Uses temp_linearity which corresponds to the old axiom shape
5. **SoundnessLemmas axiom_temp_linearity_valid**: Needs third disjunct handling

## Recommended Next Steps

1. **Fix until_linearity_valid soundness proof** for the equal case with the new third disjunct
2. **Fix since_linearity_valid** mirror
3. **Fix WitnessSeed.lean** for new axiom shapes
4. **Run lake build** to find all remaining errors
5. **Fix SoundnessLemmas.lean** for axiom_swap_valid and axiom_temp_linearity_valid
6. **Fix SuccChainFMCS.lean** remaining temp_t references (lines 1243, 4008, 4275, 4418)
7. **Continue with Phases 6-9** per the plan

## Build Status

As of handoff, `lake build` produces errors in:
- Soundness.lean (sorry + type mismatches from axiom changes)
- WitnessSeed.lean (old axiom shapes)
- Cascading failures from above
