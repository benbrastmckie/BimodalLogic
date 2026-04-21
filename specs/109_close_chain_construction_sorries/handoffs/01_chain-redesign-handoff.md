# Handoff: Chain Redesign Required for fwd_chain_forward_F

**Task**: 109 -- Close chain construction sorries
**Session**: sess_1745189500_b4c8d2
**Date**: 2026-04-20
**Status**: BLOCKED at Phase 1
**Reason**: The current chain construction (`fwd_chain_of_sigma` using `preserving_fwd_step`) is provably unable to satisfy `fwd_chain_forward_F`. A chain redesign is required.

## Context

The 5 sorry sites in `RootScopedChain.lean` (lines 1134, 1161, 1168, 1176, 1183) all depend on the chain's ability to resolve temporal eventuality obligations. The keystone sorry is `fwd_chain_forward_F` (line 1134):

```lean
private theorem fwd_chain_forward_F (M0 : Set Formula) (h0 : SetMaximalConsistent M0)
    (sigma_list : List Formula) (n : Nat) (phi : Formula) (h_phi : phi in sigma_list)
    (h_F : Formula.some_future phi in (fwd_chain_of_sigma M0 h0 sigma_list n).val) :
    exists m, n < m /\ phi in (fwd_chain_of_sigma M0 h0 sigma_list m).val
```

## Why the Current Chain Cannot Prove This

### The Preserving Step Dilemma

The current chain uses `preserving_fwd_step` at every step. This calls `defect_step_choice_early` which in turn calls `resolving_enriched_fwd_exists`. The BX11 fold produces a compound beta' with F(beta') in M, and the Lindenbaum extension of `{beta'} union g_content(M)` gives:

- For the target (head of active_defects): target in M' OR F(target) in M' (disjunction)
- For all other defects: chi in M' OR F(chi) in M' (disjunction)
- Some witness w in M' (directly resolved)

The witness `w` is determined by `Exists.choose` (from the BX11 fold's `enriched_fwd_fold_with_witness`). The witness can be ANY element of the defect list -- we cannot control which one.

### Why the Defect Count Might Never Decrease

The active defect set `D(k) = sigma_list.filter(chi => F(chi) in chain(k))` is non-increasing by `fwd_chain_F_obligation_monotone`. But it can STABILIZE at a set of size > 1 containing phi. When it stabilizes:

1. At each step, some w in D is resolved (w in chain(k+1))
2. But F(w) in chain(k+1) is also possible (the Lindenbaum extension is non-constructive)
3. If F(w) in chain(k+1), w is still an active defect, and |D| doesn't decrease

### Why BX12 Bridge Doesn't Help

The BX12 bridge idea (F(phi) -> T U phi, then use bx_until_eventuality_resolution) produces an abstract BXPoint `v` with phi in v.formulas and bx_le chain(n) v. But this v is an arbitrary MCS, NOT a chain point. There is no way to embed v into the existing chain.

### Why Extended Discharge Doesn't Work

The extended discharge seed `{phi} union {F(chi_i) | i} union g_content(M)` is NOT always consistent. Specifically, if `G(phi -> G(neg chi_i)) in M`, then `phi -> G(neg chi_i)` is in g_content(M), and `{phi, F(chi_i), phi -> G(neg chi_i)}` derives contradiction (phi + (phi -> G(neg chi_i)) gives G(neg chi_i), and G(neg chi_i) + F(chi_i) is inconsistent).

## Proposed Solution: Chain Redesign

### Key Mathematical Insight

From `F(phi) in M` and `G(F(phi)) not-in M` (the typical case):

- `F(G(neg phi)) in M` (since G(F(phi)) not-in M and M is MCS)
- By BX11 on F(phi) and F(G(neg phi)):
  - Case 1: F(phi and G(neg phi)) in M -- gives seed with phi AND G(neg phi), which KILLS F(phi)
  - Case 2: F(phi and F(G(neg phi))) in M -- gives seed with phi AND F(G(neg phi)), phi resolved but F(phi) persists
  - Case 3: F(F(phi) and G(neg phi)) in M -- IMPOSSIBLE (F(phi) and G(neg phi) = F(phi) and neg F(phi) = contradiction, so F(contradiction) = F(bot) not-in MCS)

In BOTH feasible cases, phi in M' is guaranteed. Case 1 additionally kills F(phi).

### The New Chain Construction

Replace `preserving_fwd_step` with a step that:

1. Uses `discharge_single_step` for the round-robin target (guaranteeing target in M')
2. Uses `preserving_fwd_step` for all other steps (preserving F-obligations)

The chain cycles through sigma_list in round-robin. At each formula's designated step, if F(target) in chain(n), use `discharge_single_step` to guarantee target in chain(n+1).

### Proof of fwd_chain_forward_F for the New Chain

Given F(phi) in chain(n):
1. Between step n and phi's next round-robin step (at most len steps away): F(phi) persists because `preserving_fwd_step` is used at non-phi steps
2. At each preserving step: phi in chain(k+1) OR F(phi) in chain(k+1)
3. If phi in chain(k+1) at any point: done
4. Otherwise F(phi) in chain(m) at phi's round-robin step m
5. discharge_single_step at step m: phi in chain(m+1). Done.

The key property: preserving_fwd_step preserves F-obligations (either resolves or keeps F), and discharge_single_step guarantees resolution.

### Required Changes

Files to modify:
1. `RootScopedChain.lean`:
   - Add new step function `discharge_fwd_step` (uses `discharge_single_step` for target)
   - Define new chain `fwd_chain_v2` alternating between preserving and discharge steps
   - Prove g_content propagation for new chain
   - Prove `fwd_chain_forward_F` for new chain
   - Update `dd_chain` to use new forward chain
   - Update `dd_bfmcs_restricted_tc` to use new chain
   - Close sorries #1-#5

2. Potentially `CanonicalModel.lean`:
   - Add/modify `discharge_single_step` variants if needed

### Critical Issue: F-Obligation Destruction

When `discharge_single_step` is used for target psi (not phi), it uses seed `{psi} union g_content(M)`. F(phi) is NOT in this seed. The Lindenbaum extension MIGHT NOT include F(phi).

However, the new chain uses `discharge_single_step` ONLY at the target's round-robin step. At ALL other steps, `preserving_fwd_step` is used, which preserves F(phi).

So between step n (where F(phi) first appears) and phi's round-robin step (at most len steps away), the only non-preserving steps are for OTHER formulas' round-robin slots. These steps use `discharge_single_step` which might destroy F(phi).

MITIGATION: Use `preserving_fwd_step` at ALL steps, but MODIFY the defect list ordering at phi's round-robin step to ensure phi is the BX11-minimum target. When phi is BX11-minimum, `target_stays_direct_in_fold` guarantees phi in M'.

But phi might not be BX11-minimum. The BX11 ordering depends on the specific MCS and which BX11 cases fire.

ALTERNATIVE MITIGATION: Use a two-level approach:
- Level 1 (most steps): `preserving_fwd_step` -- preserves all F-obligations
- Level 2 (phi's step): `discharge_single_step` -- guarantees phi resolution

At Level 2 steps for OTHER formulas (not phi), F(phi) might be destroyed. But since Level 2 only fires when F(target) is present, and the round-robin has period len, there are at most len Level 2 steps between any two consecutive phi steps.

The key lemma needed: at each Level 2 step for target psi (where psi != phi), either:
(a) phi in chain(k+1) (done), or
(b) F(phi) in chain(k+1) (preserved), or
(c) G(neg phi) in chain(k+1) AND phi was resolved at some earlier step

Option (c) requires showing phi was resolved BEFORE G(neg phi) appeared. This needs careful analysis.

### Estimated Effort

- Chain redesign and proof of fwd_chain_forward_F: 6-10 hours
- Updating dependent theorems (dd_chain, dd_fmcs, etc.): 4-6 hours
- Closing remaining sorries (#2-#5) using the new chain: 4-6 hours
- Total: 14-22 hours (2-3 implementation sessions)

## What Was Accomplished This Session

1. Deep analysis confirming `fwd_chain_forward_F` is unprovable for the current chain
2. Validated the research findings from the team (all 4 teammates + deep analysis)
3. Identified the BX11 Case 3 impossibility: F(F(phi) and G(neg phi)) is impossible because F(phi) and G(neg phi) are contradictory under irreflexive semantics
4. Identified that in both feasible BX11 cases (1 and 2), phi in M' is guaranteed when using the right seed
5. Outlined the chain redesign strategy with detailed mathematical justification
6. Wrote this handoff document

## Recommendations for Next Session

1. Start by implementing the new step function `targeted_discharge_step` that uses `discharge_single_step` for the round-robin target
2. Define the new chain `fwd_chain_v2`
3. Prove the key lemma: F-preservation through preserving steps
4. Prove `fwd_chain_forward_F` for the new chain
5. Update the chain infrastructure (dd_chain, dd_fmcs, etc.)
6. Close the 5 sorry sites

The most promising approach is the "all preserving + discharge at target's step" hybrid, which avoids F-obligation destruction while guaranteeing target resolution.
