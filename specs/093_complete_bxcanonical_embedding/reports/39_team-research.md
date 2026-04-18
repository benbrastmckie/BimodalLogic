# Research Report: Task #93 - Round 39

**Task**: Complete BXCanonical embedding
**Date**: 2026-04-18
**Mode**: Team Research (4 teammates)
**Session**: sess_1776533662_a1d4fd
**Focus**: Systematic review of all past reports/summaries to find the mathematically correct long-term solution

## Summary

After 38 prior rounds and 19+ failed approaches, this round conducted a systematic review of the entire task history. Four teammates independently analyzed the sorry sites, failed approaches, existing infrastructure, and viable paths forward. The key findings converge on two actionable paths and one critical correction to prior analysis.

**Critical correction**: Plan v37's oracle approach was abandoned based on a **mischaracterized blocker**. The "extended seed consistency fails because G-lift doesn't work for Until formulas" diagnosis was incorrect -- the consistency proof uses a subset-of-MCS argument, NOT G-lifting for Until formulas. The quasimodel oracle approach deserves re-examination.

**Two viable paths** (not mutually exclusive):

1. **sr_fwd_chain redefinition** (50% confidence, ~400-600 LOC): Replace `enriched_fwd_step` with conditional `self_resolving_fwd_step` in dd_chain. Gives forward_F by construction. **Critical gap identified**: F-preservation for non-scheduled formulas requires f_carry augmentation of the seed, needing a new consistency proof.

2. **Quasimodel-based BFMCS** (HIGH confidence for oracle discharge, MEDIUM for full bridge, ~900 LOC): Build new `qm_bfmcs` bypassing dd_fmcs entirely, using the sorry-free quasimodel infrastructure (`hintikka_chain_exists`, `defect_count` decrease). The oracle discharge is straightforward because the "witness reached" branch always fires for `Sigma = SubformulaClosure(root)`.

**Quick win**: `restricted_buc` (backward Until coherence, line 1522) is provably INDEPENDENT of the forward_F blocker and may be closeable via BX axioms + induction (~2-4 hours). Requires verifying BX6's exact statement first.

## Key Findings

### 1. The Three Sorry Sites Have Asymmetric Difficulty (Unanimous, HIGH confidence)

```
dd_bfmcs_restricted_tc  (line 1517) — F/P eventuality discharge — HARDEST (core blocker)
    |
    v  (fuc uses tc's forward_F result)
dd_bfmcs_restricted_fuc (line 1527) — forward Until/Since coherence — MEDIUM
    |
dd_bfmcs_restricted_buc (line 1522) — backward Until/Since coherence — INDEPENDENT, EASIEST
```

- **restricted_buc** does NOT depend on forward_F. It requires only BX axioms at MCS level + h_content backward propagation. Proof by induction on witness distance `s - t`, using BX8 (base) and a derived Until introduction rule (step).
- **restricted_fuc** depends on restricted_tc (uses `F(psi)` from `phi U psi` via BX10, then tc gives witness).
- **restricted_tc** is the core blocker: requires F-eventuality discharge within the chain.

### 2. Plan v37 Was Abandoned on a False Blocker (C, HIGH confidence 85%)

Round 37 summary states: "extended seed consistency fails because `alpha U beta in MCS` does NOT imply `G(alpha U beta) in MCS`, breaking the G-lift argument."

**This is a mischaracterization.** The extended seed `{psi_target} ∪ g_content(w) ∪ {active Until defects from w}` does NOT need G-lifting for Until formulas. The correct consistency argument:

- Until defects come from `w.formulas` directly (they are active defects of w)
- The seed is a subset of `{psi_target} ∪ w.formulas`
- Consistency follows by the same argument as `forward_temporal_witness_seed_consistent`: if `L ⊢ ⊥` and `L ⊆ seed`, then `L \ {psi_target} ⊆ w.formulas`, so `G(L \ {psi_target}) ⊢ G(¬psi_target)`, giving `G(¬psi_target) ∈ w`, contradicting `F(psi_target) ∈ w`.

The G-lift was only needed for the g_content portion, which works as before. Until defects bypass G-lifting entirely because they're already in `w.formulas`.

**Impact**: The quasimodel oracle approach (Plan v37) may be viable after all. The `HintikkaStepOracle` discharge requires ~150 LOC using `until_eventuality_resolution` + `sigma_signature` projection.

### 3. sr_fwd_chain Has a Critical F-Preservation Gap (D, HIGH confidence)

Teammate C proposes replacing `enriched_fwd_step` with conditional `self_resolving_fwd_step` in dd_chain. This gives forward_F by construction at scheduled steps. However, Teammate D identifies a **critical gap**:

When resolving `phi` at step k (using `self_resolving_fwd_step(chain(k), phi)`), the seed is `{phi, F(phi)} ∪ g_content(chain(k))`. For a DIFFERENT formula `psi ≠ phi` with `F(psi) ∈ chain(k)`:
- `F(psi)` is NOT in g_content (g_content only contains chi where `G(chi) ∈ M`)
- `F(psi)` is NOT in `{phi, F(phi)}`
- Therefore `F(psi)` may be LOST in `chain(k+1)`
- Once lost, `G(¬psi)` may enter the chain permanently (MCS maximality)

This is the SAME F-obligation loss problem that plagues all non-BX11 approaches. The BX11 fold's f_carry mechanism specifically solves this, but sr_fwd_chain doesn't use it.

**Resolution**: Augment the sr_fwd_chain seed with f_carry: `{target, F(target)} ∪ g_content(M) ∪ f_carry(M)`. This requires a NEW consistency proof for the augmented seed. Whether this consistency proof works is the key mathematical question for this approach.

### 4. Quasimodel Infrastructure Is Substantially Complete (B, HIGH confidence)

The quasimodel infrastructure in `Quasimodel/Construction.lean` is sorry-free through Phase 3:

| Component | Status | Location |
|-----------|--------|----------|
| `hintikka_step` (G-prop, H-backward, Until-defect) | Sorry-free | Construction.lean:45 |
| `defect_count` + `untilDefectSet` | Sorry-free | Construction.lean |
| `hintikka_step_target_decrease` | Sorry-free | Construction.lean:283 |
| `hintikka_chain_exists` | Sorry-free | Construction.lean:594 |
| `chain_step_seed_consistent` | Sorry-free | Construction.lean:676 |
| `SubformulaClosure_G/H/untl_closed` | Sorry-free | Realization.lean |
| `until_eventuality_resolution` | Sorry-free | Realization.lean |
| `HintikkaStepOracle` discharge | NOT YET PROVED | ~150 LOC needed |
| Chain-to-FMCS bridge | NOT YET BUILT | ~750 LOC needed |

**Key insight**: For `Sigma = SubformulaClosure(root)`, the oracle discharge always takes the "witness reached" branch (because `psi ∈ Sigma` by `SubformulaClosure_untl_closed`). No defect-monotonicity argument is needed. This makes the oracle discharge straightforward.

### 5. 21 Approaches Are Definitively Dead (A, HIGH confidence)

All 19 approaches from Report 17 plus FiniteDeferral (circular at Step 5, needs Until Induction not in BX) and BX12 reduction (wrong closure) are confirmed dead. No further investigation warranted. See Teammate A report for the complete classification table.

### 6. Missing Infrastructure: self_resolving_bwd_step (C, MEDIUM confidence 70%)

The backward analog of `self_resolving_fwd_step` is referenced but NEVER DEFINED. The P-infrastructure exists (`P_and_self_P_mcs` at line 2020) but the step function itself is missing. This is needed for `dd_fmcs_backward_P` and the backward half of `restricted_tc`. Estimated ~30-50 LOC, likely provable symmetrically to the forward version.

### 7. defect_fwd_step_choice_singleton Is a Proved Base Case (D, MEDIUM confidence 35%)

`defect_fwd_step_choice_singleton` (line 2161-2170, sorry-free) proves that with `defects = [psi]`, the chain resolves `psi` at step 1. This provides a proved base case for `defect_fwd_chain_forward_F`. The inductive step (multi-element lists) requires showing that `defect_fwd_step_choice` eventually selects each element, which is not obvious but may be provable by well-founded induction on `|defects|`.

## Synthesis

### Conflicts Resolved

**Conflict 1**: Primary approach recommendation differs across teammates.
- A: Start with restricted_buc (independent, easier)
- B: Build new qm_bfmcs from quasimodel (~900 LOC)
- C: Redefine dd_chain with sr_fwd_chain
- D: defect_fwd_chain bridge or redefine dd_fmcs

**Resolution**: These are complementary, not competing. The recommended strategy is:
1. **Quick win first**: Verify BX6 statement and attempt restricted_buc (1-2 hours, independent of tc)
2. **Primary path**: Re-examine Plan v37 oracle approach with corrected seed consistency argument (Finding 2 above)
3. **Fallback**: sr_fwd_chain with f_carry augmentation if oracle approach hits new blockers

**Conflict 2**: Teammate C says Plan v37 oracle was abandoned on false blocker; Teammate B says G-lift genuinely fails for Until formulas.

**Resolution**: Both are correct about different things. G-lift DOES fail for Until formulas through bx_le. But the extended seed consistency proof does NOT need G-lifting for Until formulas -- it uses the subset-of-MCS argument instead. The Plan v37 abandonment was based on checking whether Until formulas can be G-lifted (they can't), but the actual consistency argument doesn't require this. The oracle approach remains viable.

**Conflict 3**: Teammate D identifies F-preservation gap in sr_fwd_chain; Teammate C claims sr_fwd_chain is viable.

**Resolution**: Teammate D's analysis is correct -- the raw sr_fwd_chain (without f_carry) does NOT preserve F-obligations for non-scheduled formulas. Teammate C's proposal needs augmentation with f_carry in the seed, which requires a new consistency proof. This reduces the confidence of the sr_fwd_chain approach from C's 90% to a more realistic 50%.

### Gaps Identified

1. **BX6 exact statement**: Must be verified in `Axioms.lean`. If BX6 = absorption (`phi ∧ F(phi U psi) → phi U psi`), restricted_buc becomes straightforward. 30-minute check.

2. **self_resolving_bwd_step**: Missing, needed for backward_P. Estimated 30-50 LOC.

3. **Extended seed consistency via subset-of-MCS**: Needs formal verification that the argument works as described. The key question: does `L \ {psi_target} ⊆ w.formulas` hold when L contains Until defects from w? Answer: yes, because Until defects are drawn from `w.formulas` by definition.

4. **Chain-to-FMCS bridge for quasimodel**: The largest missing piece (~750 LOC). How to convert finite Hintikka chains to Int-indexed FMCS.

5. **Until persistence through g_content**: Until formulas do NOT propagate forward through g_content. This affects the guard proof in restricted_fuc. No concrete resolution proposed by any teammate.

### Recommendations

1. **Immediate (30 min)**: Read `Axioms.lean` and check BX6's exact statement. This determines whether restricted_buc has a quick path.

2. **Phase 1 (2-4 hours)**: Attempt restricted_buc via BX axioms + induction. This is independent of the forward_F blocker and closes 1 of 3 sorry sites.

3. **Phase 2 (4-8 hours)**: Re-examine Plan v37's oracle approach with the corrected seed consistency argument. Focus on:
   - Discharge `HintikkaStepOracle` using `until_eventuality_resolution` + `sigma_signature` (~150 LOC)
   - Build the Chain-to-FMCS bridge (~750 LOC)

4. **Phase 3 (2-4 hours)**: Use the quasimodel-backed BFMCS to close restricted_tc and restricted_fuc.

5. **Contingency**: If the oracle approach hits new blockers, attempt sr_fwd_chain with f_carry-augmented seed.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: complete approach classification | completed | high |
| B | Alternatives: quasimodel infrastructure | completed | high |
| C | Critic: blind spots and false blockers | completed | high |
| D | Horizons: strategic options assessment | completed | high |

## References

### Codebase
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — Sorry sites (1517, 1522, 1527)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` — Sorry-free quasimodel
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` — Closure properties
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — Seed consistency proofs
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — Coherence definitions
- `Theories/Bimodal/ProofSystem/Axioms.lean` — BX1-BX12 axiom system
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` — Dead end (circular)

### Prior Reports
- Report 17: Round-robin chain history (19 failed approaches)
- Report 38: Language design tradeoffs (unanimous: do not change language)
- Summary 35: BX12 reduction blocked
- Summary 36: SubformulaClosure closure properties proved
- Summary 37: Oracle approach blocked (on mischaracterized blocker)
- Handoff 01_mathematical-analysis: Plan v38 Phase 1 blocked analysis
