# Phase 0 Handoff: Bypass Infrastructure Archived

## Immediate Next Action

Begin Phase 1: Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EndpointNegation.lean` implementing the VecEA2-level Lemma 5.1 (`neg_vecEA2_is_vvecEA2`).

## Current State

- Phase 0: COMPLETED
- Phase 1: IN PROGRESS (plan file marked, no code written yet)
- Build: passes (1695 jobs, 0 errors)
- Sorry count in Kamp directory: 3 (KampPrior.lean:136 placeholder, EANegation.lean:1084 documented impossibility, EANegation.lean:1235 Cor 5.4 backward)

## Key Decisions

1. **KampForward.lean archived**: Plan said to remove import, but KampForward uses `ssn_xt_compatible` from KampBypassCore. Since nothing in the new chain imports KampForward, it was archived to Boneyard instead.
2. **GeneralExistPart.lean archived**: Similarly, nothing in the new chain needs it.
3. **Old Kamp/Boneyard files moved**: KampBypassK1.lean and PriorComposition_old.lean moved to main Boneyard.
4. **KampPrior.lean**: Imports simplified to remove NfCharFormula and KampMutualInduction. Proof body for k+1 case replaced with `sorry`. The outer structure (NF disjunction, Doets lemma usage) is preserved.

## Architecture for Phase 1

### What to prove

```lean
theorem neg_vecEA2_is_vvecEA2 (n : Nat) (vea : VecEA2 n) :
    ∃ (v : VVecEA2),
    ∀ {sig} (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
      (h_INF : HasAttainedINF M atomMap)
      (z0 z1 : M.carrier), z0 < z1 →
      (v.holds M atomMap z0 z1 ↔ ¬ (vea.holds M atomMap z0 z1))
```

### Key insight

`vea.holds M atomMap z0 z1 = endpointLeft(z0) AND endpointRight(z1) AND bracket(z0, z1)`

The negation decomposes by de Morgan:
- `¬endpointLeft(z0)`: trivial VVecEA2 disjunct (endpointLeft.neg at z0)
- `endpointLeft(z0) AND ¬endpointRight(z1)`: trivial VVecEA2 disjunct
- `endpointLeft(z0) AND endpointRight(z1) AND ¬bracket(z0, z1)`: THIS is where Lemma 5.1 is needed

For the bracket negation, we need the MODEL-INDEPENDENT version. The existing `neg_bracket_is_vbracket` in EANegation.lean has this structure but with 2 sorries at the BracketFormula level.

At the VecEA2 level, the critical difference is: alpha_0 = endpointLeft is at z0 (fixed point), not an interior existential witness. This eliminates the beta_0(r0) problem.

### Induction structure (by n = number of bracket witnesses)

**Base case (n=0)**: bracket = trivial (just segment types). Easy.

**Inductive step (n+1)**:
- Case 1: ¬endpointLeft(z0) - trivial
- Case 2: endpointLeft(z0) AND segmentTypes(0) holds everywhere in (z0, z1) - reduces to Cor 5.4 on tail with n witnesses, which in turn reduces to Lemma 5.3
- Case 3: endpointLeft(z0) AND segmentTypes(0) fails somewhere - use HasAttainedINF to find first failure point r, split bracket at r, apply IH

### Template code

`EANegationClosure.lean` provides sorry-free model-dependent templates:
- `neg_interval_formula` (lines 237-312): model-dependent Lemma 5.1
- `neg_vecEA2` (lines 482-521): model-dependent Prop 4.2 single-conjunct
- `neg_2var_vec_ea` (lines 556-565): model-dependent Prop 4.2 full

The model-independent version needs to construct the VVecEA2 BEFORE choosing M, then prove the biconditional.

### Risk assessment

The model-independent biconditional is fundamentally harder than the model-dependent forward direction because:
1. The V-bracket must be fixed before M is chosen
2. The backward direction (v.holds → ¬vea.holds) requires showing the constructed V-bracket witnesses exactly negate the original
3. The forward direction (¬vea.holds → v.holds) is essentially the same as the model-dependent version

The VecEA2-level approach should work because alpha_0 at z0 eliminates the beta_0(r0) case that blocked the BracketFormula-level biconditional.

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| KampPrior.lean | 136 | `nf_characterizable_temporal_prior` k+1 case | Full NF-to-temporal translation | Placeholder pending Rabinovich chain | Phase 4: replace with `kamp_theorem_rabinovich` call |
| EANegation.lean | 1084 | `neg_bracket_is_vbracket` beta_0(r0) case | BracketFormula-level biconditional | UNPROVABLE at BracketFormula level (documented) | NOT on critical path; may remain permanently |
| EANegation.lean | 1235 | `neg_partialBracketExist_is_vbracket` backward | Cor 5.4 backward direction | Same BracketFormula limitation | Phase 1: may be fixable via VecEA2-level result |

## Files Modified This Dispatch

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` - MODIFIED (removed bypass imports, sorry placeholder)
- `Theories/Bimodal/Boneyard/KampBypassArchive/` - 13 files archived:
  - KampBypassCore.lean, KampBypassEqCase.lean, KampBypassBridge.lean
  - KampBypassUntil.lean, KampBypassSince.lean, KampBypass.lean
  - KampMutualInduction.lean, NfCharFormula.lean, PriorComposition.lean
  - KampForward.lean, GeneralExistPart.lean
  - KampBypassK1.lean, PriorComposition_old.lean
