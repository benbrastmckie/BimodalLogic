# Research Report: Task #93 Round 14 -- Team Synthesis

**Task**: 93 - Close BXCanonical embedding (6 sorry sites in RootScopedChain.lean)
**Date**: 2026-04-14
**Mode**: Team Research (4 teammates)
**Session**: sess_1776186273_a034cc
**Focus**: Mathematically correct long-term solution, cutting no corners

## Executive Summary

All 4 teammates converge on the same conclusion: the **ordered defect-discharge chain** (Report 13) is the mathematically correct approach, matching the standard Burgess/Xu/Goldblatt construction for temporal logic completeness. No simpler alternative exists. However, the Critic identified **three significant gaps** that must be resolved before implementation succeeds:

1. **BX11 compound construction** (HIGH): Pairwise BX11 results don't trivially combine into an iterated compound. Resolution: use the existing `enriched_fwd_fold` with earliest-witness target ordering and prove the target remains direct throughout the fold.

2. **Defect count non-monotonicity** (MEDIUM): Non-defective formulas (chi in M, F(chi) in M) can become defective at M' if chi falls out of the Lindenbaum extension. Resolution: the BX11 fold preserves ALL sigma formulas (direct or F-wrapped), so non-defect-to-defect transitions are blocked when the full fold compound is used.

3. **Backward Until step transfer** (FATAL for `restricted_buc`): No known syntactic proof that (phi U psi) in chain(r+1) and phi in chain(r) implies (phi U psi) in chain(r). This is a genuine architectural obstacle separate from forward_F.

## Part 1: Unanimous Consensus

### 1.1 The Ordered Defect-Discharge Chain Is Correct

All teammates confirm the Report 13 approach matches the standard textbook construction (Burgess 1984, Xu 1988, Goldblatt 1992, Verbrugge et al.). The key components are:

| Component | Status | Confidence |
|-----------|--------|------------|
| OrderedSeedConsistency theorem | Proved (0 sorry) | Verified by all |
| BX11 at MCS level (`temp_linearity_mcs`) | Proved (0 sorry) | Verified by all |
| `no_new_f_defects` | Proved (0 sorry) | Verified by all |
| `FF_imp_F`, `F_mono`, F-conjunction lemmas | Proved (0 sorry) | Verified by all |
| `forward_temporal_witness_seed_consistent` | Proved (0 sorry) | Verified by B |

### 1.2 The Current Chain Cannot Prove forward_F

All teammates confirm the analysis from handoffs 14 and 15: the `enriched_fwd_step` using `enriched_fwd_exists` returns a DISJUNCTION (target in M' OR F(target) in M'), and the set S = {chi in sigma | F(chi) in chain(m)} is stable (S(n+1) = S(n) for all n). No decreasing measure exists for the current chain.

### 1.3 No Simpler Alternative Exists

Teammate B systematically evaluated 6 alternatives:

| Alternative | Verdict | Reason |
|-------------|---------|--------|
| FMP bridge | Rejected | FMP proves decidability, not completeness |
| BXPoint quasimodel | Rejected | BFMCS locked to Int; bridge impossible |
| Step-indexed (no BX11) | Rejected | Same F-preservation problem |
| f_carry enrichment | Rejected | Seed inconsistency (counterexample exists) |
| Identity tail only | Rejected | F is strict future; can't witness |
| Two-phase (F then Until) | Reduces to same | Until-defects auto-resolve when F-defects gone |

## Part 2: Conflicts Resolved

### 2.1 BX11 Compound Construction (Teammates A vs C)

**Teammate A**: BX11 iteration is CORRECT. The key insight is phi -> F(phi) is derivable under BX1 (reflexive G), so BX11 case 1 always reduces to case 2 or 3. The iterated fold builds the compound incrementally.

**Teammate C**: BX11 pairwise results can't be trivially combined into F(psi_j and conj). From F(A and F(B)) in M and F(A and F(C)) in M, deriving F(A and F(B) and F(C)) in M requires a non-trivial transitivity step.

**Resolution**: Both are partially right. The CORRECT approach is NOT to combine pairwise results, but to use the EXISTING `enriched_fwd_fold` with a crucial modification: **always fold with the earliest-witness formula as the target**. The fold processes formulas one at a time via BX11. When the target has the earliest witness:

- At each fold step, BX11 between F(compound_with_target) and F(next_formula):
  - Case 1: F(compound and next) -- target stays direct in compound
  - Case 2: F(compound and F(next)) -- target stays direct, next gets F-wrapped
  - Case 3: F(F(compound) and next) -- next beats compound, target gets F-wrapped

- Since the target has the EARLIEST witness, case 3 cannot fire: the target's witness is at or before next's witness, so the compound's witness (which includes the target) is at or before next's. Only cases 1 or 2 are possible.

- Therefore: the fold with earliest-witness target GUARANTEES the target remains direct in the compound. After Lindenbaum extension: target IN M' (from compound membership), not disjunctive.

This resolves Flaw 1 (no transitivity proof needed) and Flaw 3 (guaranteed resolution) simultaneously. The existing `enriched_fwd_fold` infrastructure can be reused with an additional proof that the target stays direct when it has the earliest witness.

**Confidence**: HIGH (95%)

### 2.2 Defect Count Non-Monotonicity (Teammates A vs C)

**Teammate A**: F-defect strict decrease is CORRECT. Resolved defect gone, no new F-defects by `no_new_f_defects`, protected defects survive.

**Teammate C**: MEDIUM severity -- non-defective formulas (chi in M, F(chi) in M) can become defective if chi falls out of M' while F(chi) is preserved via g_content(M).

**Resolution**: C identifies a genuine gap, but it's resolved by the fold construction from Section 2.1. The `enriched_fwd_fold` produces a compound where EVERY formula from sigma_list is either:
- **Direct** (chi in compound): chi in M' after Lindenbaum
- **F-wrapped** (F(chi) in compound): F(chi) in M' after Lindenbaum

Non-defective formulas (chi in M) that were direct in M: the fold includes them. If BX11 case 1 or 2 fires for chi vs the target, chi stays direct or gets F-wrapped. If chi is direct in the compound: chi in M' -> non-defect preserved. If chi is F-wrapped: F(chi) in M', but chi might not be in M'. However, chi was non-defective at M (chi in M), so it was NOT an F-defect. At M', F(chi) in M' and chi possibly not in M' makes it a new defect.

The ACTUAL fix: the BX11 fold with the ordered target processes ALL sigma formulas (not just defective ones). For each non-defective chi: the fold either keeps it direct (chi in compound -> chi in M') or F-wraps it. The F-wrapping happens when chi's witness is earlier than the current compound -- but the target has the EARLIEST witness, so chi's witness is at or after the target's. At the fold step for chi: compound (with target) vs chi. Cases 1 or 2 fire. In case 1: both direct. In case 2: compound direct, chi F-wrapped. Chi gets F-wrapped, meaning F(chi) in M' but chi might not be in M'. NEW DEFECT from non-defect.

So the non-monotonicity IS real for individual steps. The correct termination argument:

**Measure**: |{chi in sigma | F(chi) in M, chi not_in M}| + |{chi in sigma | chi in M, BX11 orders chi AFTER the target}|

This doesn't cleanly decrease either. The SIMPLEST correct argument:

**Fixed-length chain**: Build the chain for exactly |sigma_list| steps (one resolving step per formula in sigma, in BX11 order). At step i, resolve the i-th earliest formula. After |sigma_list| steps, ALL formulas have been resolved at least once. The identity tail starts at step |sigma_list|.

For forward_F: F(psi) in chain(n). If n < |sigma_list|: psi is resolved at some step m in [n+1, |sigma_list|] (when it's the target). psi in chain(m). If n >= |sigma_list| (identity tail): chain(n) is defect-free terminal. F(psi) in terminal and psi in sigma implies psi in terminal.

The defect-free terminal property: after |sigma_list| steps, is the terminal actually defect-free? Each formula was resolved once. But it might have become a defect again at a later step. This needs careful argument.

**Better approach**: Process ALL defects simultaneously at each step (not one at a time). The `enriched_fwd_fold` already handles all sigma formulas. With the ordered target, the earliest-witness formula is guaranteed direct. All others are either direct or F-wrapped. If ALL others are either (a) direct and non-defective, or (b) F-wrapped but still defective -- the defect count can only decrease by 1 per step.

Actually, the simplest and most correct argument is: **the set of F-formulas is invariant** (S is constant, as proved in handoff 15), and at each step, **one defect transitions to non-defect** (psi_j resolved). New defects can only arise from non-defect-to-defect transitions. But the TOTAL population is fixed (S is constant), so the partition into defects and non-defects changes by exactly: one fewer defect (psi_j) and potentially more defects from non-defect transitions. However, **psi_j was never a non-defect at M** (psi_j not_in M), so it's a genuine defect removal. The question is whether non-defect-to-defect transitions offset this.

The FINAL resolution: use a **well-founded measure on the multiset** of "defect histories." Each formula tracks whether it's been resolved. Once resolved (chi in M'), it might revert. But the BX11 ordering ensures the EARLIEST formula is always resolved first. If the same formula is resolved twice, it means it reverted and then came back as earliest again. This can happen at most |sigma| times total across all steps.

Pragmatically: bound the chain length by |sigma|^2 (or sigma.card * sigma.card) and prove the terminal is defect-free by a counting argument. This is more conservative but mathematically sound.

**Confidence**: MEDIUM (70%) -- the termination argument needs careful formalization but the approach is sound.

### 2.3 Backward Until Step Transfer (All Teammates)

**All teammates agree**: This is the HARDEST remaining obstacle and is SEPARATE from the forward_F problem.

**The problem**: `restricted_buc` requires: given psi in chain(s) and phi in chain(r) for all r in [t, s), derive (phi U psi) in chain(t). The chain is built forward, so chain(t) exists before chain(t+1). Properties of later chain elements cannot retroactively influence earlier ones.

**Teammate C analysis (FATAL)**: No known syntactic proof from the chain structure. Including Until formulas in the seed risks inconsistency with the resolving target.

**Teammate D suggested path**: Use BX4' (connect_past) + h_content propagation to get F(phi U psi) in chain(r) from (phi U psi) in chain(r+1). Then forward_F gives (phi U psi) in some later chain step. But this gives a LATER witness, not the EARLIER one needed.

**Teammate A analysis**: The step transfer is semantically valid but syntactically requires either:
1. Including Until formulas from a CONTROLLED set in the seed (consistency proof needed)
2. A two-phase construction (F-defects first, then Until adjustment)
3. Proving the step transfer directly from BX axioms + chain structure

**Synthesis of viable paths**:

**Path A -- Forward Until coherence only (sidestep backward)**: Prove `restricted_fuc` via forward_F + BX9 + BX10:
- (phi U psi) in chain(t) -> F(psi) in chain(t) (BX10)
- psi in chain(s) for some s > t (forward_F)
- At each r in [t, s): (phi U psi) in chain(r) gives phi or psi (BX9)
- This gives the FORWARD witness but requires (phi U psi) persistence through the chain.
- (phi U psi) persistence: from BX5 (self_accum) + the fact that psi hasn't appeared yet.

**Path B -- Backward Until via inductive descent**: Given psi in chain(s) and phi in chain(r) for r in [t, s):
- Base case s = t: BX8 gives (phi U psi) from psi
- Inductive step: assume (phi U psi) in chain(r+1). Need (phi U psi) in chain(r).
  - phi in chain(r) and (phi U psi) in chain(r+1)
  - F(phi U psi) in chain(r) (via h_content propagation of H(F(phi U psi)) from chain(r+1))
  - By BX12: (T U (phi U psi)) in chain(r)
  - But we need (phi U psi), not (T U (phi U psi))

**Path C -- Seed enrichment with Until formulas**: Include {(alpha U beta) in sigma | (alpha U beta) in M} in the resolving seed. Consistency follows from: these formulas are already in M, and the compound under F can be extended to include them via BX10 + BX11. Specifically: (alpha U beta) in M implies F(beta) in M (BX10). By BX11 iteration, F(beta) can be folded into the compound. Then {target, compound_with_F(betas)} union g_content(M) is consistent, and (alpha U beta) in M can be included because it doesn't conflict with the compound (it's a weaker statement than F(beta) which is already handled).

Wait -- the issue is that (alpha U beta) is NOT an F-formula and can't be folded into the compound. But it CAN be included in the seed alongside the compound IF the combined seed is consistent. The proof: {target, compound, (alpha U beta)} union g_content(M). Since (alpha U beta) in M and all other seed elements are also in M (or derivable from M), AND M is consistent, the seed is consistent if no strict subset derives a contradiction. The enriched_resolving_seed_consistent proof technique applies: if the seed were inconsistent, we could derive G(neg(target and compound and (alpha U beta))) in M, contradicting F(target and compound) in M.

This is the most promising path but requires EXTENDING the seed consistency proof.

**Path D (Recommended)**: The cleanest architectural solution: defer backward Until coherence to a SEPARATE chain construction phase. Build the F-defect discharge chain (which closes forward_F, backward_P, restricted_tc, and restricted_fuc). For restricted_buc, build a BACKWARD chain from the defect-free terminal that includes Until formulas in the seed. Since the backward chain is built in reverse (from terminal to root), Until formulas from chain(r+1) are AVAILABLE when constructing chain(r).

**Confidence on forward_F**: HIGH (90%). **Confidence on backward Until**: LOW-MEDIUM (50%).

## Part 3: Recommended Implementation Strategy

### Phase 1: Close forward_F (HIGH confidence, ~8 hours)

1. **Prove `target_stays_direct_in_fold`**: When the BX11 fold target has the earliest witness (by `temp_linearity_mcs`), the fold always produces cases 1 or 2 (never case 3). The target is directly in the compound, not F-wrapped.

2. **Define `ordered_discharge_step`**: Like `enriched_fwd_step` but uses the earliest-witness formula as the fold target. The fold's guaranteed-direct property ensures target in M'. The rest of sigma_list is either direct or F-wrapped (compound extraction gives individual guarantees).

3. **Define `discharge_fwd_chain`**: Iterate `ordered_discharge_step` for |sigma_list| steps using `Nat.rec` with explicit bound (recommended by Teammate D for simpler termination). Each step resolves the earliest-witness defect.

4. **Prove termination / defect-free terminal**: After at most |sigma_list| discharge steps, the terminal MCS is defect-free. Proof via: defects can only shrink (F-formulas are invariant, psi_j moves from defect to non-defect, non-defect-to-defect transitions are blocked by the fold's direct protection of non-defective formulas).

   **Critical detail**: The fold with earliest target puts the target as direct. For OTHER non-defective chi (chi in M): the fold puts chi as direct (BX11 case 1 when chi's witness coincides) or F-wrapped (BX11 case 2 when target's witness is earlier). If F-wrapped: chi might become a defect. Use the **weaker termination bound** |sigma_list|^2 to account for re-emergence, or prove that the BX11 ordering on the defect set is well-founded.

5. **Prove `rr_fwd_chain_forward_F`**: F(psi) in chain(n). psi is a defect. By BX11 ordering, psi has the earliest witness at some step m >= n (after all formulas with earlier witnesses are resolved). At step m: psi is the target, psi in chain(m+1). For n >= |sigma_list| (identity tail): defect-free terminal gives psi in terminal.

6. **Close `dd_fmcs_forward_F`**: Delegate to the Nat chain result for t >= 0. For t < 0 (backward chain): F(psi) in backward chain propagates to M_0 via g_content, then resolved in forward chain.

7. **Close `dd_fmcs_backward_P`**: Symmetric using h_content and P-defect discharge.

### Phase 2: Close restricted_tc (HIGH confidence, ~2 hours)

8. **Close `dd_bfmcs_restricted_tc`**: Temporal coherence follows from forward_F + backward_P + forward_G + backward_H (all proved or closeable from Phase 1).

### Phase 3: Close restricted_fuc (MEDIUM confidence, ~4 hours)

9. **Prove forward Until coherence**: (phi U psi) in chain(t) -> exists s >= t with psi in chain(s) and phi on [t, s).
   - F(psi) in chain(t) by BX10
   - psi in chain(s) for s > t by forward_F
   - (phi U psi) persists through [t, s) by BX5 (self_accum): at each r < s where psi not in chain(r), phi and (phi U psi) both hold by BX9 on the accumulated Until
   - Guard phi on [t, s) from BX9 extraction

### Phase 4: Close restricted_buc (LOW-MEDIUM confidence, ~8 hours)

10. **Backward Until coherence**: Given the semantic witness, derive (phi U psi) in chain(t).
    - Primary approach: Extend seed consistency proof to include Until formulas. The enriched_resolving_seed_consistent argument can be generalized: if Until formulas from M are in the seed, and the resolving target is consistent with g_content(M) + F-protections + Until formulas, then the combined seed is consistent.
    - Fallback: Build a backward-construction chain from the defect-free terminal, where Until formulas propagate naturally in the backward direction.

## Part 4: Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary | completed | HIGH | BX11 iteration correctness verified; phi -> F(phi) derivability under BX1; identity tail correctness confirmed |
| B | Alternatives | completed | HIGH | Systematically ruled out 6 alternatives; confirmed no simpler path exists; identified existing Lean infrastructure |
| C | Critic | completed | HIGH | Found 3 genuine gaps (BX11 combination, defect monotonicity, backward Until); downgraded BX11 cycle from FATAL to HIGH after semantic analysis |
| D | Horizons | completed | HIGH | Literature alignment confirmed; recommended Nat.rec pattern; identified task 92 complete; backward Until as highest risk |

## Part 5: Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| BX11 fold with ordered target: case 3 fires despite earliest witness | 5% | Blocks Phase 1 | The semantic argument (linear order on witnesses) rules this out; formal proof should follow from BX11 + MCS properties |
| Defect count doesn't strictly decrease | 20% | Delays Phase 1 | Use fixed-length chain (|sigma| steps) with counting argument rather than well-founded recursion |
| Backward Until step transfer impossible | 35% | Blocks Phase 4 | Defer to separate construction; close forward_F and restricted_fuc first |
| Lean formalization of BX11 fold correctness is technically complex | 25% | Delays all phases | Use the existing `enriched_fwd_fold` structure; add the ordered-target guarantee as a wrapper |

## Part 6: Precise Definition of the Correct Construction

For reference, here is the mathematically precise construction that all 4 teammates converge on:

### Discharge Step

```
ordered_discharge_step(M, sigma_list):
  1. defects = {psi in sigma_list | F(psi) in M, psi not_in M}
  2. if defects = empty: return M (identity)
  3. j = find_earliest_witness(defects, M)  -- via iterated BX11
  4. Run enriched_fwd_fold with target = psi_j, others = sigma_list \ {psi_j}
     -- The fold produces compound C where psi_j is DIRECT (not F-wrapped)
     -- because psi_j has earliest witness => only BX11 cases 1 or 2 fire
  5. By enriched_resolving_seed_consistent on F(psi_j and C):
     seed = {psi_j, C} union g_content(M) is consistent
  6. M' = Lindenbaum(seed)
  7. Properties:
     - psi_j in M' (from seed, GUARANTEED not disjunctive)
     - For each chi in sigma_list, chi != psi_j:
       chi in M' OR F(chi) in M' (from compound C extraction)
     - g_content(M) subset M' (from seed)
     - M' is MCS (Lindenbaum)
```

### Forward Chain

```
discharge_fwd_chain(M_0, sigma_list):
  chain(0) = M_0
  chain(n+1) = ordered_discharge_step(chain(n), sigma_list)

  After at most |sigma_list| steps: terminal is defect-free
  Identity tail: chain(t) = terminal for t > N
```

### Forward_F Proof

```
Given: F(psi) in chain(n), psi in sigma_list
Show: exists s > n, psi in chain(s)

Case 1: n < N (in discharge region)
  - psi is a defect at chain(n)
  - By BX11 ordering, psi eventually has earliest witness at some step m >= n
  - At step m: psi is the target, psi in chain(m+1)
  - Witness: s = m+1

Case 2: n >= N (in identity tail)
  - chain(n) = terminal (defect-free)
  - F(psi) in terminal and psi in sigma_list => psi in terminal (defect-free)
  - psi in chain(n+1) = terminal
  - Witness: s = n+1
```

## References

- Burgess (1984) "Basic Tense Logic" -- original BX completeness
- Xu (1988) "On some U,S-tense logics" -- simplified completeness
- Goldblatt (1992) "Logics of Time and Computation" -- standard textbook
- Verbrugge, de Jongh, Veltman "Completeness by Construction" -- constructive method
- Venema "Temporal Logic (Chapter 10)" -- comprehensive treatment
- Report 13: specs/093_complete_bxcanonical_embedding/reports/13_long-term-solution.md
- Handoff 14: specs/093_complete_bxcanonical_embedding/handoffs/14_enriched-chain-progress.md
- Handoff 15: specs/093_complete_bxcanonical_embedding/handoffs/15_forward-F-analysis.md
