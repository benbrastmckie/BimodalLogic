# Research Report: Task #93 - Round 44

**Task**: Complete BXCanonical embedding
**Date**: 2026-04-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1745088000_team44
**Focus**: Rigorously study how the QuasimodelChain's periodic structure can be embedded into Int-indexed BFMCS, cutting no corners towards identifying a fully worked out long-term solution.

## Summary

All four teammates conducted deep code-level analysis of the quasimodel infrastructure (2,289 lines across 9 files) and its potential to close the 3 remaining sorries. The team converges on a clear diagnosis but diverges on confidence levels due to a critical blocker identified by the Critic.

**The core finding**: The quasimodel bridge requires **replacing dd_bfmcs** with a quasimodel-derived BFMCS (Teammates A, B, D agree). An incremental approach within the existing dd_chain is blocked (all 4 teammates agree). However, the Critic (Teammate C) identifies that the oracle construction itself has **7-8 sorry sites** in OracleStep.lean, including the fundamental defect-count decrease problem that transfers to any oracle-based approach. This means the quasimodel bridge, while architecturally correct, still requires solving the Lindenbaum defect-monotonicity problem.

**Three distinct paths forward emerge**, with different risk/reward profiles.

## Key Findings

### 1. OracleStep.lean Sorry Inventory (Teammate C, VERIFIED)

The "sorry-free oracle" claim is misleading. Direct code inspection reveals:

| Location | Sorry | Nature |
|----------|-------|--------|
| `hintikka_step_or_condition_sigma_sig` (line 272) | 1 | Defect-count decrease for sigma_sig |
| `hintikka_step_oracle` (lines 341, 348, 367, 386, 393, 397) | 6 | Universal oracle: H-backward, Until-propagation, defect decrease |
| `hintikka_step_oracle_for_sigma_sig` (line 452) | 1 | "Fully sorry-free" oracle: defect decrease |

**What IS genuinely sorry-free**: `hintikka_step_for_sigma_sig` (line 188-222) -- proves the `hintikka_step` relation holds between sigma-signatures of consecutive oracle steps. This is necessary but insufficient: it proves the step relation without the defect-count decrease disjunct.

**What IS genuinely sorry-free infrastructure**:
- `hintikka_chain_exists` (Construction.lean:594-659) -- correct but takes oracle as parameter
- `qm_oracle_step_bx_le` (OracleStep.lean:98) -- G-content propagation
- `qm_oracle_step_h_content` (OracleStep.lean:103) -- H-content backward
- `chain_step_seed_consistent` (Construction.lean:676-690) -- seed consistency
- Frame.lean: entirely sorry-free (verified: no sorry sites)
- Realization.lean: sorry-free (only a comment mentions sorry)

### 2. dd_countermodel Is Fully Parametric Over BFMCS (Teammate B, DEFINITIVE)

`dd_countermodel` (RootScopedChain.lean:1164-1190) needs exactly:
1. A BFMCS satisfying `restricted_temporally_coherent root`
2. A BFMCS satisfying `restricted_backward_until_since_coherent root`
3. A BFMCS satisfying `restricted_forward_until_since_coherent root`
4. A family containing an MCS where `neg(phi) ∈ mcs(0)`

The algebraic machinery (`ParametricCanonicalTaskFrame`, `RestrictedParametricTruthLemma`) is parametric -- any BFMCS satisfying these predicates works. **A quasimodel-derived BFMCS can be substituted wholesale.**

### 3. Periodic Extension Is Viable for G/H But Has Wraparound Problem (Teammates A, D)

For a finite chain `v_0, ..., v_k` of BXPoints, periodic extension `chain(t) = v_{t mod (k+1)}` gives:
- **G-forward**: `hintikka_step` guarantees G(chi) ∈ h_i → chi ∈ h_{i+1}. At BXPoint level: `bx_le v_i v_{i+1}`, giving `g_content(v_i) ⊆ v_{i+1}`. ✓
- **H-backward**: `hintikka_step` guarantees H(chi) ∈ h_{i+1} → chi ∈ h_i. ✓
- **Wraparound**: `g_content(v_k) ⊆ v_0` is NOT guaranteed. Three solutions proposed:
  1. **Palindromic cycling** (Teammate D): period 2k chain `v_0,...,v_k,v_{k-1},...,v_1`. H-backward gives the reverse direction.
  2. **Fresh Lindenbaum at wraparound** (Teammate D): construct v_0' from seed `h_0.formulas ∪ g_content(v_k) ∪ modal_fix(M_0)`.
  3. **Constant tail** (Teammate A): after defects discharge, repeat the final MCS forever.

### 4. restricted_buc Requires a Different Argument (All teammates agree)

`restricted_buc` asks: if the Until semantic condition holds (witness exists in chain), then `φ U ψ ∈ mcs(t)`. This is about INTRODUCING Until formulas, not discharging defects.

**Teammate D's approach**: Use BX axioms at MCS level:
- Base case (s = t): `ψ ∈ mcs(t)` → `φ U ψ ∈ mcs(t)` by BX8 (`refl_intro_until_mcs`)
- Inductive case: Suppose `φ U ψ ∈ mcs(t+1)` and `φ ∈ mcs(t)`. Need `φ U ψ ∈ mcs(t)`.
  - This requires: `φ ∧ G(φ U ψ) → φ U ψ` (BX12, until_induction)
  - But `G(φ U ψ) ∈ mcs(t)` requires `φ U ψ ∈ g_content(mcs(t))`, which requires `G(φ U ψ) ∈ mcs(t)`. Circular.

**Teammate A's contrapositive approach**: Suppose `¬(φ U ψ) ∈ mcs(t)`. Then by BX axioms, propagate `¬(φ U ψ)` forward. At some point it contradicts the witness ψ ∈ mcs(s). This requires showing `¬(φ U ψ)` propagates forward through G-content, which requires `G(¬(φ U ψ)) ∈ mcs(t)`.

**The BX12 approach (synthesis)**: The axiom BX12 is `(φ ∧ G(φ U ψ)) → φ U ψ`. At MCS level: if `φ ∈ mcs(t)` and `G(φ U ψ) ∈ mcs(t)`, then `φ U ψ ∈ mcs(t)`. The key is getting `G(φ U ψ) ∈ mcs(t)`. In the FMCS, `G(chi) ∈ mcs(t)` iff `chi ∈ mcs(t')` for all `t' > t`. So we need `φ U ψ ∈ mcs(t')` for all `t' > t`. By induction from `s` downward: at `mcs(s)`, `ψ ∈ mcs(s)` so `φ U ψ ∈ mcs(s)` by BX8. At `mcs(s-1)`, `φ ∈ mcs(s-1)` and `φ U ψ ∈ mcs(s)`. But the induction step still requires `G(φ U ψ) ∈ mcs(s-1)`, which is what we're trying to prove.

**This is genuinely hard.** The backward induction requires a co-inductive or simultaneous argument: prove `φ U ψ ∈ mcs(r)` for ALL `r ∈ [t, s]` simultaneously. The standard approach uses the `restricted_temporal_backward_G` lemma (TemporalCoherence.lean:324-342): if `φ U ψ ∈ mcs(r)` for all `r > t`, then `G(φ U ψ) ∈ mcs(t)`. But this uses restricted_tc (forward F-resolution) which must be proved first.

**Dependency**: restricted_buc requires restricted_tc as a prerequisite.

### 5. The Defect-Count Decrease Problem Is the Irreducible Core (All teammates)

Every approach -- dd_chain, oracle chain, quasimodel bridge -- hits the same wall: Lindenbaum extension via `set_lindenbaum` is non-constructive (Classical.choice). The extended MCS may contain arbitrary Until-formulas beyond those in the seed. This breaks `defect_mono` (untilDefectSet monotonicity).

**Why SubformulaClosure doesn't help**: SubformulaClosure is G/H/U-closed, so if `φ U ψ ∈ Sigma` then `φ, ψ ∈ Sigma`. But Lindenbaum can add `φ U ψ` to the MCS even when `φ U ψ` is NOT in the seed. Since we only track defects within Sigma, any `φ U ψ ∈ Sigma` added by Lindenbaum where `ψ ∉` MCS creates a new defect.

**Potential resolution** (Teammate B): The oracle seed includes ALL Until-formulas from Sigma that are defects. If `φ U ψ ∈ Sigma` and `φ U ψ ∈ w` (original MCS), then either `ψ ∈ w` (not a defect) or `φ U ψ` is in the seed. The Lindenbaum extension of seed ∪ g_content(w) produces MCS w'. If `φ U ψ ∈ w'` with `ψ ∉ w'`, it's a defect at w'. This defect was either: (a) inherited from seed (defect at w too), or (b) added by Lindenbaum. Case (b) is the problem.

**Key question**: Can Lindenbaum add `φ U ψ` to the extension when `φ U ψ ∉ seed`? Yes, if `φ U ψ` is consistent with the seed. And `φ U ψ ∈ Sigma` doesn't prevent this.

**But**: if `φ U ψ ∈ w'` (Lindenbaum extension) and `ψ ∈ w'`, then it's NOT a defect. The only problematic case is `φ U ψ ∈ w'` and `ψ ∉ w'`. If the seed includes `ψ` (because `ψ ∈ g_content(w)` or `ψ` in oracle seed), then `ψ ∈ w'` and no new defect. But `ψ` may not be in the seed.

### 6. Three Viable Architecture Paths (Synthesis)

**Path A: Oracle-Based Chain Replacement** (Teammates A, B)
- Replace `fwd_chain_of_sigma` / `bwd_chain_of_sigma` with oracle-based chains using `qm_oracle_step`
- Keep existing BFMCS framework
- Confidence: 50% (blocked by defect-count decrease sorry)
- LOC: 500-800
- Risk: Same Lindenbaum defect-monotonicity problem

**Path B: Full Quasimodel-Derived BFMCS** (Teammate D)
- Replace `dd_bfmcs` entirely with periodic extension of quasimodel chain
- Build new FMCS from palindromic cycling of HintikkaPoint chain
- Confidence: 55% (wraparound + defect-count still needed)
- LOC: 400-600
- Risk: Wraparound problem; restricted_buc still requires BX12 argument

**Path C: Direct Fix of fwd_chain_forward_F** (Teammate C suggestion)
- Fix the existing sorry at line 1111 using pigeonhole on finite sigma_list
- Argument: sigma_list has k formulas. The chain resolves at least one per step (preserving_fwd_step). After k*k steps, by pigeonhole, the target φ must have been resolved at least once.
- Confidence: 35% (pigeonhole requires showing resolved defects don't re-create the same defect pattern)
- LOC: 100-200
- Risk: Defects can oscillate; φ → F(φ) regenerates defects

## Synthesis

### Conflicts Resolved

**Conflict 1**: Teammate B rates oracle approach 8/10 confidence. Teammate C says oracle has 7+ sorries and "CANNOT work."

**Resolution**: Teammate B's confidence is based on the architectural viability of the approach assuming defect-count decrease can be proved. Teammate C correctly identifies that defect-count decrease IS sorry'd. The architecturally correct approach (oracle-based chain) faces the same mathematical obstruction as the current approach. **Teammate C is correct about the sorry sites**; Teammate B's 8/10 confidence is overestimated. Revised confidence: 50%.

**Conflict 2**: Teammate A says "periodic extension is a red herring." Teammate D builds the entire recommended approach on periodic extension.

**Resolution**: Both are partially right. Periodic extension of the FULL chain is not needed for local witnessing (Teammate A). But if we REPLACE dd_bfmcs, we need an Int-indexed chain, and periodic extension is the natural construction (Teammate D). **If we keep dd_bfmcs and only change the proof technique, periodic extension is unnecessary. If we replace dd_bfmcs, it's essential.**

**Conflict 3**: Teammate D rates restricted_buc at 75% confidence via BX axioms. Teammate C says no quasimodel infrastructure addresses restricted_buc.

**Resolution**: Both are correct. Teammate C is right that quasimodel CHAINS don't help with buc. Teammate D is right that BX AXIOMS at MCS level (BX8, BX12) can prove buc. The approach for buc is axiom-based, not chain-based. **The BX12 argument requires restricted_tc as prerequisite** (for the `restricted_temporal_backward_G` lemma), creating a dependency chain: restricted_tc → restricted_buc → restricted_fuc.

### Gaps Identified

1. **Defect-count decrease**: The single most critical gap. ALL approaches require proving `untilDefectSet` monotonicity across Lindenbaum extension. No approach circumvents this.

2. **Backward oracle construction**: No backward analog of `hintikka_step_oracle` exists. Since-direction restricted_tc requires this.

3. **Wraparound G-content**: For periodic extension, `g_content(v_k) ⊆ v_0` needs either palindromic cycling, fresh Lindenbaum, or constant tail.

4. **restricted_buc backward induction**: The BX12-based argument has a circularity: proving `G(φ U ψ) ∈ mcs(t)` requires `φ U ψ ∈ mcs(t')` for all `t' > t`, which is what we're proving. Need to verify `restricted_temporal_backward_G` can break this circularity.

5. **Integration**: The quasimodel infrastructure (9 files) is completely disconnected from RootScopedChain.lean. Any approach requires new integration code.

### Recommendations

**Primary recommendation**: Investigate Path C (direct fix) FIRST as it has lowest cost. Specifically:

1. **Close `fwd_chain_forward_F` directly**: The `preserving_fwd_step` resolves some defect w ∈ M' at each step. Since sigma_list is finite (k elements), and F(φ) persists at every step (by f_carry), and the scheduling repeats every k steps, at the step where target = φ, the resolving case fires (seed = {φ} ∪ g_content) placing φ ∈ M'. The key insight: F(φ) ∈ M guarantees the resolving case fires when target = φ, giving φ ∈ M'. The schedule hits φ every k steps. So take m = next multiple of k after n where sigma_list[m mod k] = φ.

2. **If Path C succeeds for restricted_tc**, use `restricted_temporal_backward_G` to get `G(φ U ψ) ∈ mcs(t)` from `φ U ψ ∈ mcs(r)` for all r > t, enabling the BX12 argument for restricted_buc.

3. **If Path C fails**, proceed to Path A (oracle replacement) with the understanding that defect-count decrease must be solved first.

**Secondary recommendation**: Investigate whether `fwd_succ` already resolves the target in the resolving case. Read `fwd_succ` (CanonicalModel.lean:66-72) carefully: in the resolving case (`F(target) ∈ M`), seed = `{target} ∪ g_content(M)`, and Lindenbaum extension gives M' with `target ∈ M'`. So `fwd_chain_of_sigma` at step n where `sigma_list[n mod k] = φ` and `F(φ) ∈ chain(n)` gives `φ ∈ chain(n+1)`. The only gap is showing `F(φ)` persists from the original point to step n.

## Dead Ends Confirmed (Cumulative)

- All 21+ approaches from Report 17: CONFIRMED DEAD
- Enriched resolving seed: DEFINITIVELY DEAD (counterexample, Report 43)
- Backward step transfer: SEMANTICALLY INVALID (Reports 41-43)
- Defect-count induction on F-defects: IMPOSSIBLE (count never decreases)
- Per-formula witness chain: BLOCKED (witness must be in same-family chain)
- self_resolving_fwd_step as drop-in: BLOCKED (loses F-persistence)
- "Sorry-free oracle" at OracleStep.lean:411: FALSE (sorry at line 452)
- Quasimodel bridge as incremental fix within dd_chain: BLOCKED (Dead Ends #25, #30)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Discovery |
|----------|-------|--------|------------|---------------|
| A | Primary / embedding analysis | completed | 45% | Periodic extension unnecessary for local witnesses; oracle approach viable but blocked by same defect-count gap |
| B | Alternatives / chain replacement | completed | 50% (adjusted from 80%) | dd_countermodel fully parametric; hybrid replacement architecture; multi-defect oracle seed |
| C | Critic | completed | 95% (on findings) | 7+ sorry sites in OracleStep.lean; no integration point; restricted_buc direction mismatch |
| D | Horizons | completed | 65% | Palindromic cycling for wraparound; BX12 for restricted_buc; long-term alignment with literature |

## References

- Teammate A: `specs/093_complete_bxcanonical_embedding/reports/44_teammate-a-findings.md`
- Teammate B: `specs/093_complete_bxcanonical_embedding/reports/44_teammate-b-findings.md`
- Teammate C: `specs/093_complete_bxcanonical_embedding/reports/44_teammate-c-findings.md`
- Teammate D: `specs/093_complete_bxcanonical_embedding/reports/44_teammate-d-findings.md`
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes No. 7.
- Burgess, J.P. (1984). Basic tense logic. *Handbook of Philosophical Logic*, Vol. II.
- Reynolds, M. (2003). Until and Since over Linear Orders. *Journal of Logic and Computation*.
- Verbrugge, R. (2007). Completeness by Construction.
