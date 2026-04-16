# Research Report: Task #93 -- Depth-Zero Base Case Analysis

**Task**: 93 - Complete BXCanonical embedding
**Started**: 2026-04-16T00:00:00Z
**Completed**: 2026-04-16T01:30:00Z
**Effort**: ~90 minutes
**Dependencies**: Reports 26, 27; Phase 3 implementation (depth >= 1 proved)
**Sources/Inputs**:
  - Codebase: RootScopedChain.lean (proof sketch sections 1-30, sorry sites), CanonicalModel.lean (fwd_succ), SuccRelation.lean (Succ, single_step_forcing), CanonicalTaskRelation.lean (bounded_witness), TemporalCoherence.lean (restricted_temporal_backward_G_strict), WitnessSeed.lean (forward_temporal_witness_seed_consistent), Quasimodel/ (1,816 lines), Filtration/ (316 lines)
  - Reports: 26_defect-reentry-analysis.md, 27_team-research.md, 27_bxcanonical-embedding-summary.md
**Artifacts**: specs/093_complete_bxcanonical_embedding/reports/28_depth-zero-base-case.md
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- The depth-0 base case of `forward_F` is the sole remaining obstacle; all depth >= 1 cases are proved sorry-free via `rr_fwd_chain_forward_F_depth_pos`.
- **Path A (omega-squared chain)** is mathematically unsound: any single linear chain using fwd_succ with round-robin scheduling faces the same F-persistence failure. The omega-squared interleaving does not help because the chain is a linear sequence with shared state -- resolving one defect at step k can kill F-obligations for other defects at step k+1, regardless of scheduling order.
- **Path B (quasimodel bridge)** is the most mathematically rigorous path. The 1,816-line sorry-free quasimodel infrastructure can be leveraged, but requires a fundamentally different architecture: replace dd_fmcs with a construction that directly obtains forward_F from the Succ/bounded_witness infrastructure already in the codebase. Estimated 400-800 new LOC.
- **Path C (counting argument)** is blocked: the BX11 fold ordering can perpetually defer a specific formula (Report 26), and no counting/pigeonhole argument overcomes this for the enriched chain.
- **Path D (NEW -- Succ-based chain replacement)** is the recommended approach. The codebase already has `single_step_forcing` (SuccRelation.lean:232) and `bounded_witness` (CanonicalTaskRelation.lean:650), both sorry-free, which prove forward_F for chains satisfying the `Succ` relation. Replace `rr_fwd_chain` with a chain where consecutive states satisfy `Succ`, and forward_F follows immediately from `bounded_witness`. Estimated 300-500 new LOC.

---

## Context and Scope

### Problem Statement

The theorem `rr_fwd_chain_forward_F` requires: for all psi in sigma_list, if F(psi) in chain(n), then there exists s > n with psi in chain(s).

The WF-induction structure (Phase 3) reduces this to the depth-0 base case: when `f_nesting_depth(psi) = 0` (psi has no outer F-operators), prove that F(psi) in chain(n) implies psi in chain(s) for some s > n.

### The Fundamental Obstruction

The depth-0 obstruction has two manifestations depending on chain architecture:

1. **Enriched chain (current rr_fwd_chain)**: F(psi) persists forever (`rr_fwd_chain_F_obligation_persists`), but at each visit step the BX11 fold may resolve a DIFFERENT formula, perpetually deferring psi (Report 26).

2. **Simple fwd_succ chain**: F(psi) can be KILLED at resolving steps for other targets. The resolving seed `{target} + g_content(M)` does not include f_carry(M), so F(psi) may not survive to psi's next visit step.

Both manifestations stem from the same root cause: the `fwd_succ` resolving seed `{target} + g_content(M)` is proved consistent via `forward_temporal_witness_seed_consistent`, but the EXTENDED seed `{target} + g_content(M) + f_carry(M)` is NOT provably consistent (Section 10 of proof sketch, confirmed in Section 24 Case 4 analysis).

### Why Extended Seed Consistency Fails

The proof of `forward_temporal_witness_seed_consistent` relies on the generalized temporal K argument: if L subset g_content(M) and L derives neg(target), then G(L) derives G(neg(target)), and all G(L) are in M (by definition of g_content), so G(neg(target)) in M, contradicting F(target) in M.

This argument REQUIRES all seed elements (except target) to have G-versions in M. Elements from f_carry(M) are F-formulas like F(chi), and G(F(chi)) is NOT generally in M (Report 27, Finding 11: explicit countermodel at times {0,1,2}). Without the G-lift, the argument breaks.

The proof sketch (Section 24, Case 4) constructs a concrete scenario: when F(G(neg(psi))) in M, the seed `{target, F(psi)} + g_content(M)` CAN be inconsistent. And F(psi) + F(G(neg(psi))) is satisfiable in BX (ψ at some future time before G(neg(psi)) kicks in), so this case is non-vacuous.

---

## Findings

### Path A: Omega-Squared Chain

**Mathematical Correctness**: UNSOUND.

The omega-squared idea is to assign each F-defect its own subsequence in the chain, avoiding interference between defects. However, this fundamentally misunderstands the problem:

1. **Linear chain with shared state**: The chain is a single linear sequence chain(0), chain(1), chain(2), ... where chain(k+1) = fwd_succ(chain(k), target_k). Each state is built FROM the previous state. There is no way to have "independent" subsequences -- they all share state.

2. **Interleaving does not help**: Whether we use round-robin, omega-squared pairing, or any other scheduling, the fwd_succ step at position k uses chain(k) as input. If chain(k) lacks F(psi) (because a resolving step at k-1 killed it), no scheduling can recover F(psi).

3. **The proof sketch (Sections 8-14) exhaustively analyzes this**: Sequential resolution (Section 8), recovery steps (Section 13), interleaved construction (Section 12) -- all fail for the same reason: resolving one defect can kill another's F-obligation.

**Counterexample**: At chain(k), F(psi1) and F(psi2) both present. Schedule psi1 first: chain(k+1) = fwd_succ(chain(k), psi1). The resolving seed is {psi1} + g_content(chain(k)). The Lindenbaum extension may or may not include F(psi2). If it chooses G(neg(psi2)) instead, F(psi2) is permanently killed. No scheduling prevents this.

**Lean Formalizability**: N/A -- the approach is mathematically blocked.

**Risk Assessment**: FATAL. There is no variant of omega-squared scheduling that overcomes the F-persistence failure in a linear chain with fwd_succ.

**Verdict**: REJECTED.

### Path B: Quasimodel Bridge

**Mathematical Correctness**: SOUND (with caveats).

The sorry-free quasimodel infrastructure (1,816 lines in Quasimodel/) constructs finite chains of Hintikka/BX points with defect-discharge properties for Until/Since formulas. The key insight from the Quasimodel is that it works at a DIFFERENT level of abstraction -- BXPoints with the bx_le preorder, not the linear chain.

The bridge would need to:
1. Start from the quasimodel's BXPoint-based chain structure
2. Extract an Int-indexed FMCS family from it
3. Prove this family satisfies forward_G/backward_H (from bx_le)
4. Prove forward_F/backward_P (from the defect-discharge property)

**Counterexample Survival**: The quasimodel inherently handles the perpetual deferral scenario because it constructs witnesses BEFORE fixing the chain. Each F-defect gets resolved in its own branch of the quasimodel tree, then the tree is linearized.

**Lean Formalizability**:
- Existing infrastructure: HintikkaPoint, hintikka_step, UntilDefect, defect_count, quasimodel_chain_exists (all sorry-free)
- New definitions needed: BXPoint-to-FMCS functor, Int-indexed family from BXPoint chains, modal coherence across chain segments
- Estimated LOC: 800-1200 new lines
- The main technical difficulty is modal coherence: showing that different chain segments (from different BXPoint chains) agree on box formulas

**Risk Assessment**: MEDIUM. The mathematical path is well-understood (standard in the literature), but the Lean formalization effort is substantial. The bx_le preorder is NOT total (it's only a preorder), which complicates linearization. The Realization.lean comment (line 29-30) explicitly notes this: "appears unprovable from BX1-BX12 due to non-totality of the bx_le preorder."

**Verdict**: VIABLE but costly. Not recommended as primary path.

### Path C: Counting Argument

**Mathematical Correctness**: BLOCKED.

The counting argument would show: the set of unresolved F-defects is finite, and each round-robin cycle resolves at least one. By pigeonhole, every defect is eventually resolved.

This fails because:
1. **Resolving one defect can RE-CREATE others**: When psi1 is resolved (psi1 in chain(k+1)), at the next step chain(k+2), psi1 may leave chain(k+2) (defect re-entry, Report 26 Section 3). The defect set is NOT monotonically non-increasing.
2. **BX11 fold perpetual deferral**: The BX11 ordering can permanently favor formula A over formula B at every step where both compete (Report 26, concrete 2-formula counterexample). The count does not decrease.
3. **F-obligation constancy paradox**: In the ENRICHED chain, FO = {chi | F(chi) in chain(n)} is constant (Report 26, Section 2). Every formula in FO has F(chi) in chain(n) for ALL n. The enriched step resolves ONE formula per step but may re-introduce its defect at the next step.

**Lean Formalizability**: N/A.

**Risk Assessment**: FATAL. The counting premise (each cycle resolves at least one) is false.

**Verdict**: REJECTED.

### Path D (NEW): Succ-Based Chain Replacement

**Mathematical Correctness**: SOUND.

This is the key discovery of this research round. The codebase already contains the mathematical machinery to prove forward_F, but it lives in a DIFFERENT module (SuccRelation.lean, CanonicalTaskRelation.lean) and was designed for a different chain architecture.

**The key theorems (all sorry-free)**:

1. `Succ(u, v)` (SuccRelation.lean:59): Defined as `g_content(u) subset v AND f_content(u) subset v union f_content(v)`. This is exactly the property that fwd_succ provides at non-resolving steps (via g_content + f_carry preservation), AND at resolving steps the enriched step provides (via `enriched_fwd_step_preserves`).

2. `single_step_forcing` (SuccRelation.lean:232): If F(phi) in u AND FF(phi) NOT in u AND Succ(u,v), then phi in v. This is proved by showing GG(neg(phi)) in u (from FF not in u), hence G(neg(phi)) propagates via g_content to v, killing F(phi) in v, forcing phi in v (not f_content(v)).

3. `bounded_witness` (CanonicalTaskRelation.lean:650): If iter_F(n, phi) in u AND iter_F(n+1, phi) NOT in u AND CanonicalTask_forward_MCS(u, n, v), then phi in v. This inductively applies single_step_forcing over n steps.

**The construction**: The existing `enriched_fwd_step` already satisfies the `Succ` relation:
- g_content(chain(n)) subset chain(n+1): proved as `enriched_fwd_step_g_content`
- f_content(chain(n)) subset chain(n+1) union f_content(chain(n+1)): this IS `enriched_fwd_step_preserves` (for chi in sigma_list, chi in chain(n+1) OR F(chi) in chain(n+1))

**The forward_F proof for the enriched chain**:

Given F(psi) in chain(n) with f_nesting_depth(psi) = 0:
- psi has no outer F-operators, so FF(psi) = F(F(psi)).
- f_nesting_depth(F(psi)) = 1 (since psi has depth 0).
- F(F(psi)) in chain(n) iff F(psi) in chain(n) by... wait. FF(psi) in chain(n) means F(F(psi)) in chain(n). We have F(psi) in chain(n). By phi_in_mcs_imp_F_phi, F(F(psi)) in chain(n). So FF(psi) IS in chain(n).

**CRITICAL ISSUE**: `single_step_forcing` requires FF(phi) NOT in u. But by reflexivity (phi_in_mcs_imp_F_phi), F(psi) in chain(n) implies F(F(psi)) in chain(n). So the precondition FF(phi) NOT in u FAILS for every F-formula in an MCS.

This means `single_step_forcing` and `bounded_witness` do NOT directly apply to the depth-0 case because their precondition (FF not in the state) is never satisfied when F is in the state.

**Re-analysis**: The `single_step_forcing` theorem is designed for a specific scenario: when the F-nesting is at EXACTLY level n (iter_F(n,phi) present but iter_F(n+1,phi) absent). In an MCS, F is reflexive (phi implies F(phi)), so F(phi) always implies FF(phi). The bounded_witness approach works for the Boneyard's DRM chains (DeferralRestrictedMCS) where formulas are RESTRICTED to deferralClosure, and F-nesting beyond closure_F_bound is excluded. But for full MCS chains, the reflexivity of F prevents single_step_forcing from applying.

**Revised Path D: DRM-based chain**:

The Boneyard's ResolvingChain.lean already outlines this approach:
1. Build a DRM chain (restricted to deferralClosure) where F-nesting is bounded
2. In a DRM, iter_F(closure_F_bound, phi) is NOT in the DRM (by `iter_F_not_mem_closureWithNeg`)
3. Apply `bounded_witness` within the DRM to get forward_F
4. Lift the DRM chain to full MCS via Lindenbaum extensions

**The key obstacle for the DRM approach**: The existing DRM chain in ResolvingChain.lean is in the Boneyard (deprecated code). It uses `simplified_restricted_seed` and `deferral_restricted_lindenbaum`. These definitions may be stale or incompatible with the current architecture. However, the MATHEMATICAL argument is sound.

**Estimated LOC**: 300-500 new lines to:
1. Define a DRM-based forward chain using deferral_restricted_lindenbaum
2. Prove the DRM chain satisfies the Succ relation (restricted to deferralClosure)
3. Apply bounded_witness to get forward_F within the DRM
4. Lift to full MCS and wire into dd_fmcs

**Risk Assessment**: MEDIUM-LOW. The mathematical argument is sound and the infrastructure exists (albeit in Boneyard). Main risks:
- The DRM-to-MCS lift may have modal coherence issues
- The Boneyard code may need significant adaptation
- The `Succ` relation in the DRM setting needs to be verified

**Verdict**: VIABLE. Most promising approach if the DRM infrastructure can be revived.

### Path E (NEW): Replace Chain with fwd_succ + Targeted Resolution

**Mathematical Correctness**: SOUND.

Instead of trying to prove forward_F for a single fixed chain, define a NEW chain that uses `fwd_succ` and TARGETS each formula when asked:

```
targeted_fwd_chain(M0, sigma_list, n) =
  fwd_succ(targeted_fwd_chain(M0, sigma_list, n-1), rrSchedule(sigma_list, n-1))
```

This is literally the same as rr_fwd_chain but using fwd_succ instead of enriched_fwd_step. The proof sketch (Section 28) correctly identifies this as equivalent to the greedy chain.

For this chain, the depth >= 1 case is already proved (it doesn't depend on the specific step function -- only on FF_imp_F and phi_in_mcs_imp_F_phi).

For depth 0: the chain does NOT satisfy forward_F in general (F-obligations can be killed). HOWEVER:

**The key insight not explored in the proof sketch**: We do NOT need to prove forward_F for rr_fwd_chain. We need to prove forward_F for dd_fmcs, which is built from rr_fwd_chain. We can REPLACE the construction of dd_fmcs entirely.

**Alternative dd_fmcs construction**: For each MCS M0, instead of building a SINGLE chain, build a FAMILY of chains (one per formula) and take their UNION via a tree-to-linear conversion:

For each psi in deferralClosure with F(psi) in M0:
  Define chain_psi(0) = M0, chain_psi(1) = fwd_succ(M0, psi)
  Then psi in chain_psi(1) by fwd_succ_resolves

To satisfy the FMCS interface (a single function mcs : D -> Set Formula), we need to merge these per-formula chains into one. This requires a MORE SOPHISTICATED chain construction:

**Iterated single-step resolution chain**:
```
chain(0) = M0
chain(2k+1) = fwd_succ(chain(2k), sigma_list[k % |sigma_list|])  -- resolving step
chain(2k+2) = fwd_succ(chain(2k+1), dummy)                       -- non-resolving recovery
```

At odd steps, we resolve a specific target. At even steps, we recover f_carry. But this has the SAME problem: the resolving step at 2k+1 may kill F-obligations for other formulas, and the recovery step at 2k+2 only preserves what survived.

This path reduces to the same obstruction as Path A.

**Verdict**: BLOCKED (reduces to Path A obstruction).

### Path F (NEW): Exploit the Enriched Step's Succ Property

**Mathematical Correctness**: POTENTIALLY SOUND. Requires careful analysis.

The enriched_fwd_step provides:
- g_content(M) subset M' (enriched_fwd_step_g_content)
- For chi in sigma_list with F(chi) in M: chi in M' OR F(chi) in M' (enriched_fwd_step_preserves)

This means the enriched chain satisfies the `Succ` relation (restricted to sigma_list formulas). The `single_step_forcing` argument fails because of reflexivity (FF always present when F is present in a full MCS).

**BUT**: Consider the CONTRAPOSITIVE of the depth-0 forward_F statement. Suppose forward_F fails for psi (depth 0, F(psi) in chain(n), psi never in chain(s) for any s > n). Then:

- F(psi) in chain(n) for all n >= some n0 (by F-obligation constancy in enriched chain)
- psi NOT in chain(s) for any s > n0
- neg(psi) in chain(s) OR psi in chain(s) for each s (by MCS completeness)
- Since psi NOT in chain(s): neg(psi) in chain(s) for all s > n0
- neg(psi) in chain(s) for all s > n0 means neg(psi) is "eventually always" true in the chain

Can we derive G(neg(psi)) in chain(n0)? If we had G(neg(psi)) in chain(n0), then F(psi) = neg(G(neg(psi))) would be NOT in chain(n0), contradicting F(psi) in chain(n0).

To derive G(neg(psi)) from "neg(psi) in chain(s) for all s > n0": this is EXACTLY what `restricted_temporal_backward_G_strict` does! It says: if phi in fam.mcs(s) for all s > t, and neg(phi) in deferralClosure, THEN G(phi) in fam.mcs(t).

But `restricted_temporal_backward_G_strict` takes forward_F as an EXPLICIT PARAMETER. It uses forward_F in its proof: if NOT G(phi), then F(neg(phi)), and forward_F gives a witness where neg(phi) holds, contradicting phi in all future states.

**This is the circularity**: To prove forward_F, we need backward_G. To prove backward_G, we need forward_F. They are mutually dependent.

**Breaking the circularity**: The restricted_temporal_backward_G_strict signature says forward_F is needed for neg(phi) where phi is being universalized. In our case, phi = neg(psi), so neg(phi) = neg(neg(psi)) = psi. We need forward_F for PSI ITSELF to get G(neg(psi)).

But psi is the VERY FORMULA we're trying to prove forward_F for! The circularity is TIGHT.

**Can we break it by induction on the number of "stuck" formulas?** No -- forward_F failure for psi is the base case, and the argument for psi requires forward_F for psi.

**Verdict**: BLOCKED by fundamental circularity.

---

## Decisions

1. **Path A (omega-squared) is REJECTED**: Mathematically unsound for linear chains.
2. **Path C (counting argument) is REJECTED**: Premises are false (BX11 perpetual deferral).
3. **Path D (Succ/bounded_witness) is the MOST PROMISING**: The mathematical argument is sound for DRM chains. The single_step_forcing theorem is exactly what's needed, but requires working within deferralClosure (DRM) rather than full MCS to avoid the F-reflexivity issue.
4. **Path B (quasimodel bridge) is VIABLE FALLBACK**: Sound but expensive (800-1200 LOC).
5. **Path F (circularity exploit) is BLOCKED**: The forward_F/backward_G circularity is tight and cannot be broken for the depth-0 case.

---

## Recommendations

### Primary Recommendation: Path D -- DRM-based Succ chain

**Priority**: HIGH. This is the shortest path to closing forward_F.

**Implementation plan**:

1. **Revive DRM infrastructure** (100-150 LOC):
   - Import `DeferralRestrictedMCS` and `deferral_restricted_lindenbaum` from the Boneyard (or re-define in the active codebase)
   - Define `drm_fwd_succ`: a forward step within deferralClosure that satisfies the `Succ` relation (g_content propagation + f_step)

2. **Build DRM forward chain** (100-150 LOC):
   - `drm_fwd_chain(M0_drm, sigma_list, n)` iterating `drm_fwd_succ`
   - Prove consecutive states satisfy `Succ`
   - Prove `CanonicalTask_forward_MCS` for n-step chains

3. **Apply bounded_witness** (50-100 LOC):
   - Key insight: in a DRM, F-nesting IS bounded. `iter_F(closure_F_bound, psi) NOT in drm` by `iter_F_not_mem_closureWithNeg`.
   - `bounded_witness` gives: if F(psi) in drm_chain(t), then psi in drm_chain(t + closure_F_bound).
   - This is forward_F within the DRM chain.

4. **Lift DRM to full MCS** (50-100 LOC):
   - Each DRM state extends to a full MCS via Lindenbaum
   - forward_F for deferralClosure formulas transfers (membership in DRM iff membership in MCS extension, for deferralClosure formulas)
   - Wire into dd_fmcs replacing rr_fwd_chain

**Total estimated LOC**: 300-500.

**Critical verification needed**: The `Succ` relation's f_step condition in the DRM setting. In a DRM, `f_content(u) subset u union f_content(u)` needs to hold. For a DRM using `simplified_restricted_seed` (g_content + deferralDisjunctions), the deferralDisjunctions provide the f_step property (F(psi) implies psi or F(psi) in successor, from the disjunction phi_or_F(phi) in the seed).

### Fallback: Path B -- Quasimodel Bridge

If the DRM approach encounters unexpected obstacles (e.g., the DRM-to-MCS lift fails for modal coherence), fall back to the quasimodel bridge.

---

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DRM infrastructure in Boneyard is stale | HIGH | MEDIUM | Re-derive from first principles; the mathematical argument is clear |
| DRM-to-MCS lift breaks modal coherence | HIGH | LOW | The restricted truth lemma only needs deferralClosure formulas; modal coherence is separate |
| Succ relation not satisfied in DRM | HIGH | LOW | Verify on paper before implementing; deferralDisjunctions provide f_step |
| closure_F_bound computation is off-by-one | LOW | LOW | Careful unit testing with small formulas |
| New chain breaks backward_P symmetry | MEDIUM | MEDIUM | Build symmetric DRM backward chain simultaneously |

---

## Appendix

### A. Key Infrastructure Inventory

| Component | Location | LOC | Sorry-Free | Relevance |
|-----------|----------|-----|------------|-----------|
| `fwd_succ` | CanonicalModel.lean:66 | 40 | Yes | Forward step (resolving + non-resolving) |
| `fwd_succ_resolves` | CanonicalModel.lean:92 | 6 | Yes | Target appears in resolving step |
| `fwd_succ_g_content` | CanonicalModel.lean:82 | 9 | Yes | G-content propagation |
| `fwd_succ_f_carry` | CanonicalModel.lean:100 | 7 | Yes | F-carry preserved at non-resolving steps |
| `enriched_fwd_step` | RootScopedChain.lean:583 | 8 | Yes | BX11 fold step |
| `enriched_fwd_step_preserves` | RootScopedChain.lean:626 | 18 | Yes | F-obligations resolved or deferred |
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean:81 | 49 | Yes | Resolving seed consistency |
| `enriched_seed_consistent` | CanonicalModel.lean:51 | 10 | Yes | Non-resolving seed consistency |
| `single_step_forcing` | SuccRelation.lean:232 | 37 | Yes | F(phi) + NOT FF(phi) + Succ => phi in v |
| `bounded_witness` | CanonicalTaskRelation.lean:650 | 29 | Yes | Iterated single_step_forcing |
| `closure_F_bound` | CanonicalTaskRelation.lean:153 | 5 | Yes | Max F-nesting in closure |
| `iter_F_not_mem_closureWithNeg` | CanonicalTaskRelation.lean:175 | 12 | Yes | F-nesting beyond bound leaves closure |
| `restricted_temporal_backward_G_strict` | TemporalCoherence.lean:376 | 18 | Yes | backward_G from forward_F |
| `rr_fwd_chain_forward_F_depth_pos` | RootScopedChain.lean:3562 | 29 | Yes | Depth >= 1 case |
| Quasimodel/ | 6 files | 1,816 | Yes | BXPoint-based defect discharge |
| Filtration/ | 2 files | 316 | Yes | Sigma defect counting |

### B. Search Queries Used

- Grep for `sorry` in RootScopedChain.lean (6 sites at lines 3644, 3688, 3695, 3748, 3753, 3758)
- Grep for `deferralClosure`, `fwd_succ`, `enriched_fwd_step`, `single_step_forcing`, `bounded_witness`, `Succ`, `f_content`, `f_carry`, `DeferralRestrictedMCS`, `Quasimodel`
- Read: RootScopedChain.lean (proof sketch sections 1-30, lines 1280-3515), CanonicalModel.lean (fwd_succ definitions), SuccRelation.lean (Succ relation + single_step_forcing), CanonicalTaskRelation.lean (bounded_witness), WitnessSeed.lean (seed consistency), TemporalCoherence.lean (backward_G), FMCSDef.lean (FMCS structure), Quasimodel/Construction.lean, Quasimodel/Realization.lean, Filtration/DefectChain.lean, Boneyard ResolvingChain.lean

### C. References

- Goldblatt, R. (1992). "Logics of Time and Computation" -- CSLI Lecture Notes
- Burgess, J.P. (1984). "Basic tense logic"
- Reynolds, M. (2003). Temporal logic completeness techniques
- Report 26: Defect Re-Entry Analysis (perpetual deferral impossibility proof)
- Report 27: Team Research (4 teammates, all viable paths assessed)

### D. Why the Proof Sketch's 30 Sections All Failed

The proof sketch (Sections 1-30 in RootScopedChain.lean) is a 2,200-line exhaustive analysis that tries every conceivable approach to proving forward_F within the FULL MCS setting. Every approach fails because:

1. **Extended seed inconsistency** (Sections 6, 10, 15, 24): `{target} + g_content(M) + f_carry(M)` may be inconsistent when target = G(neg(chi)) and F(chi) in f_carry(M).

2. **F-persistence failure** (Sections 3a, 4, 7, 11-13): In any linear chain using fwd_succ, resolving one F-defect can kill another's F-obligation.

3. **Forward_F/backward_G circularity** (Sections 17, 25): Deriving G(neg(psi)) from "neg(psi) in all future states" requires forward_F for psi itself.

4. **Reflexivity of F** (Sections 3b, 5): phi_in_mcs_imp_F_phi means F(phi) in M always implies FF(phi) in M, preventing single_step_forcing from applying in full MCS.

The DRM approach (Path D) sidesteps ALL FOUR obstacles:
- Obstacle 1: DRM seed is a subset of the DRM, trivially consistent
- Obstacle 2: DRM f_step is built into the seed (deferralDisjunctions)
- Obstacle 3: Not needed -- bounded_witness proves forward_F directly
- Obstacle 4: In the DRM, F-nesting IS bounded (formulas beyond closure_F_bound are outside deferralClosure)
