# Research Report: Prove Sorries in CoherentConstruction

**Task**: 753
**Session**: sess_1769705524_3c2b7a
**Date**: 2026-01-29
**Status**: COMPLETE

## Executive Summary

The `CoherentConstruction.lean` file contains **10 sorries** in total. Of these:
- **2 are infrastructure sorries** (lines 403, 416) required for the chain construction
- **8 are coherence case sorries** (lines 654-744) of which only 2-3 are needed for completeness

The file's own documentation (header comments lines 42-65) explicitly states that most coherence sorries are **NOT required for the completeness theorem**. Only the proven cases are exercised by the current proof path.

## Sorry Inventory

### Category A: Infrastructure Sorries (Required for Completeness)

| Line | Function | Goal | Difficulty |
|------|----------|------|------------|
| 403 | `mcs_forward_chain` | `SetConsistent (forward_seed S)` | Medium |
| 416 | `mcs_backward_chain` | `SetConsistent (backward_seed S)` | Medium |

These are the most critical sorries. They require proving that:
1. `forward_seed(S) = {phi | G phi in S}` is consistent when S is MCS and G-bot not in S
2. `backward_seed(S) = {phi | H phi in S}` is consistent when S is MCS and H-bot not in S

**Analysis**: The lemmas `forward_seed_consistent_of_no_G_bot` (lines 198-229) and `backward_seed_consistent_of_no_H_bot` (lines 236-264) already prove these facts. The sorries exist because the recursive construction needs to *propagate* the `h_no_G_bot` / `h_no_H_bot` conditions through the chain.

### Category B: Coherence Case Sorries (Not Required for Completeness)

Per the file's own documentation (lines 42-65):

| Line | Case | Description | Status |
|------|------|-------------|--------|
| 654 | forward_G Case 3 | t < 0, t' >= 0 (cross-origin) | SORRY - Never exercised |
| 657 | forward_G Case 4 | Both < 0 toward origin | SORRY - Cross-modal |
| 665 | backward_H Case 1 | Both >= 0 | SORRY - Forward chain H |
| 668 | backward_H Case 2 | t >= 0, t' < 0 (cross-origin) | SORRY - Never exercised |
| 686 | forward_H Case 1 | Both >= 0 | SORRY - H in forward chain |
| 693 | forward_H Case 3 | t < 0, t' >= 0 (cross-origin) | SORRY - Never exercised |
| 741 | backward_G Case 3 | t' < 0, t >= 0 (cross-origin) | SORRY - Never exercised |
| 744 | backward_G Case 4 | Both < 0 | SORRY - Backward chain G |

**Proven Cases** (what completeness actually needs):
- forward_G Case 1 (both >= 0): line 645
- backward_H Case 4 (both < 0): line 677
- forward_H Case 4 (both < 0): lines 694-711
- backward_G Case 1 (both >= 0): lines 720-734

## Detailed Analysis of Infrastructure Sorries

### Sorry at Line 403: Forward Chain Consistency

**Context**:
```lean
noncomputable def mcs_forward_chain (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot notin Gamma) : Nat -> Set Formula
  | 0 => Gamma
  | n+1 =>
    let S := mcs_forward_chain Gamma h_mcs h_no_G_bot n
    extendToMCS (forward_seed S) (by
      -- Need: SetConsistent (forward_seed S)
      sorry)
```

**Required Proof Strategy**:
1. By induction on n, prove:
   - `SetMaximalConsistent (mcs_forward_chain Gamma h_mcs h_no_G_bot n)`
   - `Formula.all_future Formula.bot notin mcs_forward_chain Gamma h_mcs h_no_G_bot n`
2. The second property follows from `forward_G_persistence` (lines 285-294):
   - If G-bot were in mcs(n), it persists to mcs(0) = Gamma
   - But G-bot not in Gamma by hypothesis
3. With both properties at mcs(n), apply `forward_seed_consistent_of_no_G_bot`

**Key Insight**: The existing lemma `mcs_forward_chain_is_mcs` (lines 485-492) proves the first property but is AFTER the definition. The sorry is inside the definition, creating a circular dependency.

**Solution Approach**: Use a two-step construction:
1. First define the chain using `Classical.choice` or `Nat.rec` with a proof that consistency is preserved
2. Or refactor to carry the inductive hypothesis explicitly as part of the construction

### Sorry at Line 416: Backward Chain Consistency

**Symmetric to line 403**, requiring:
1. `SetMaximalConsistent (mcs_backward_chain Gamma h_mcs h_no_H_bot n)`
2. `Formula.all_past Formula.bot notin mcs_backward_chain Gamma h_mcs h_no_H_bot n`

Use `backward_H_persistence` (lines 301-310) analogously.

## Available Infrastructure

### Existing Lemmas That Support the Proofs

From `MCSProperties.lean`:
- `set_mcs_closed_under_derivation`: Derivable formulas in MCS
- `set_mcs_all_future_all_future`: G phi in S implies GG phi in S (G-4 axiom)
- `set_mcs_all_past_all_past`: H phi in S implies HH phi in S (H-4 axiom)

From `GeneralizedNecessitation.lean`:
- `generalized_temporal_k`: If Gamma derives phi, then G(Gamma) derives G(phi)
- `generalized_past_k`: If Gamma derives phi, then H(Gamma) derives H(phi)

From `CoherentConstruction.lean` itself:
- `forward_seed_consistent_of_no_G_bot`: Direct proof of consistency
- `backward_seed_consistent_of_no_H_bot`: Direct proof of consistency
- `forward_G_persistence`: G-formulas persist through forward extension
- `backward_H_persistence`: H-formulas persist through backward extension
- `mcs_forward_chain_is_mcs`, `mcs_backward_chain_is_mcs`: Chain elements are MCS

### Mathlib Lemmas

- `Nat.le_induction`: Induction principle for proving properties at all n >= m
- `Nat.strong_induction_on`: Strong induction for natural numbers

## Proof Strategy for Infrastructure Sorries

### Recommended Approach: Explicit Inductive Carry

Refactor the chain construction to carry a proof that G-bot (or H-bot) is not in the set:

```lean
noncomputable def mcs_forward_chain_with_proof (Gamma : Set Formula)
    (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot notin Gamma) :
    (n : Nat) -> { S : Set Formula // SetMaximalConsistent S and Formula.all_future Formula.bot notin S }
  | 0 => { val := Gamma, property := And.intro h_mcs h_no_G_bot }
  | n+1 =>
    let prev := mcs_forward_chain_with_proof Gamma h_mcs h_no_G_bot n
    let S := prev.val
    let h_S_mcs := prev.property.1
    let h_S_no_G_bot := prev.property.2
    let h_seed_cons := forward_seed_consistent_of_no_G_bot S h_S_mcs h_S_no_G_bot
    let T := extendToMCS (forward_seed S) h_seed_cons
    let h_T_mcs := extendToMCS_is_mcs _ h_seed_cons
    let h_T_no_G_bot := -- prove using forward_G_persistence
      ...
    { val := T, property := And.intro h_T_mcs h_T_no_G_bot }
```

The key step is proving `Formula.all_future Formula.bot notin T`:
- Assume G-bot in T
- By `forward_G_persistence`, G-bot persists from previous MCS
- Trace back to Gamma, contradiction

### Estimated Effort

| Sorry Type | Count | Difficulty | Estimated Hours |
|------------|-------|------------|-----------------|
| Infrastructure (403, 416) | 2 | Medium | 2-4 hours |
| Cross-origin coherence | 5 | Hard | 10-15 hours |
| Same-region coherence | 3 | Medium-Hard | 4-6 hours |

**For completeness theorem**: Only the 2 infrastructure sorries need to be resolved.

## Recommendations

### Priority 1: Infrastructure Sorries (Lines 403, 416)

1. **Refactor chain construction** to carry the no-G-bot / no-H-bot invariant
2. Use the existing `forward_seed_consistent_of_no_G_bot` and `backward_seed_consistent_of_no_H_bot` lemmas
3. Prove G-bot / H-bot absence propagates using the persistence lemmas

### Priority 2: Skip Category B Sorries

The file's header documentation explicitly states these are **not required for completeness**:

> "The completeness proof only uses:
> - forward_G Case 1 (both >= 0): PROVEN
> - backward_H Case 4 (both < 0): PROVEN
> - forward_H Case 4 (both < 0): PROVEN"

Cross-origin cases would only be needed for:
- Backward Truth Lemma (membership implies truth)
- Full bidirectional coherence

### Implementation Roadmap

**Phase 1** (2-4 hours): Fix infrastructure sorries
1. Create helper lemma: `mcs_forward_chain_no_G_bot` proving G-bot not in chain
2. Create helper lemma: `mcs_backward_chain_no_H_bot` proving H-bot not in chain
3. Replace sorries with applications of `forward_seed_consistent_of_no_G_bot` / `backward_seed_consistent_of_no_H_bot`

**Phase 2** (Optional, 15-20 hours): Close remaining sorries
- Only if backward truth lemma or full bidirectional coherence is needed
- Requires cross-origin bridge lemmas connecting forward and backward chains through Gamma

## File References

- Main file: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- MCS properties: `Theories/Bimodal/Metalogic/Core/MCSProperties.lean`
- Cross-origin documentation: `Theories/Bimodal/Boneyard/Metalogic_v3/Coherence/CrossOriginCases.lean`
- Generalized necessitation: `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`
- Previous research: `specs/archive/681_redesign_construct_indexed_family_coherent_approach/`

## Conclusion

The sorries in CoherentConstruction fall into two categories:

1. **Infrastructure sorries** (2 total): Required for completeness, feasible to fix with 2-4 hours of work by refactoring the chain construction to carry the inductive invariant.

2. **Coherence case sorries** (8 total): Not required for the current completeness proof path, as documented in the file itself. Would require 15-20 additional hours to close, primarily for theoretical completeness rather than practical necessity.

Recommendation: Focus exclusively on the infrastructure sorries (lines 403, 416) for the standard completeness goal.
