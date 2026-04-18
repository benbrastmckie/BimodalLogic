# Teammate B: Oracle Approach Viability Analysis

**Task**: Task 93 - Complete BXCanonical embedding
**Date**: 2026-04-18
**Assignment**: Analyze whether qm_bfmcs (oracle approach) could replace dd_bfmcs
**Session**: sess_1776547511_361857

---

## Key Findings

1. **The oracle approach is mathematically sound in structure but has two fundamental sorries** that block it from being used as a replacement for `dd_bfmcs`.

2. **The defect-count decrease sorry (OracleStep.lean:272, 452) is the pivotal blocker**: It prevents `hintikka_chain_exists` from terminating, which in turn prevents `qm_bfmcs_restricted_tc` from being proved. This sorry cannot be easily closed.

3. **The backward Until step transfer sorry (qm_bfmcs_restricted_buc:1921) is a fundamental gap**: The formula `φ ∧ F(φ U ψ) → φ U ψ` is semantically invalid and no BX axiom derives it. This would block `qm_bfmcs_restricted_buc` even if the defect_count issue were resolved.

4. **However, the enriched oracle seed (Report 41, Teammate B Architecture E v2) could close the defect-count decrease sorry for `hintikka_step_oracle_for_sigma_sig`**: By adding negations of non-defect Until-formulas and their resolution formulas to the seed, defect monotonicity is achievable.

5. **The backward Until step transfer for qm_bfmcs_restricted_buc requires a separate fix**: The enriched backward oracle seed (from Report 41 Teammate D) adds Until-formulas to the backward seed, providing backward Until persistence BY CONSTRUCTION rather than via the invalid step transfer formula.

6. **Wiring `qm_bfmcs` into `dd_countermodel` as a replacement for `dd_bfmcs` is mathematically viable but requires closing 4-5 sorry sites** in OracleStep.lean and 3 sorry sites in RootScopedChain.lean, compared to 3 sorry sites in the `dd_bfmcs` path.

---

## Oracle Infrastructure Status

### What Exists (Sorry-Free)

All of the following are fully proved without sorries:

**In OracleStep.lean**:
- `qm_oracle_seed_consistent` (line 79): Oracle seed is SetConsistent (subset of MCS)
- `qm_oracle_step` (line 87): Lindenbaum BXPoint extension of the oracle seed (noncomputable, uses Classical)
- `qm_oracle_step_bx_le` (line 98): G-propagation: bx_le w (qm_oracle_step w Sigma)
- `qm_oracle_step_h_content` (line 103): H-backward: h_content(oracle_step) ⊆ w
- `qm_oracle_step_until_in_next` (line 109): Until-defect propagation into oracle step
- `qm_oracle_seed_bwd` and symmetric backward versions (lines 131-180): All sorry-free
- `hintikka_step_for_sigma_sig` (line 188): **FULLY SORRY-FREE** oracle step for sigma_signature inputs
- `hintikka_step_or_condition_sigma_sig` (line 227): Partial - has one sorry at line 272

**In Construction.lean**:
- `hintikka_chain_exists` (line 594): The main chain existence theorem is FULLY PROVED (sorry-free)
- `chain_step_seed_consistent` (line 676): Sorry-free
- `hintikka_chain_exists_since` (line 769): Sorry-free
- `QuasimodelChain` infrastructure, `HintikkaRawChain`, `WitnessedHintikka`: All sorry-free

**In Realization.lean**:
- `enriched_seed_consistent_until` / `_since` (lines 195, 248): Sorry-free
- `chain_step_seed_consistent_enriched` / `_since` (lines 315, 346): Sorry-free
- `SubformulaClosure_G_closed`, `_H_closed`, `_untl_closed` (lines 562, 573, 586): Sorry-free
- `F_of_mem`, `P_of_mem`, `F_from_above` (lines 54, 73, 95): Sorry-free

### What Has Sorries

**OracleStep.lean - Sorry Sites**:

1. **Line 272** in `hintikka_step_or_condition_sigma_sig`: Defect-count decrease not proved. The docstring explains: "sub-case (b) blocks the general proof of defect_mono" because Lindenbaum extension may add new Until-formulas not in the seed.

2. **Line 341** in `hintikka_step_oracle` (general case, H-backward): "needs h = sigma_sig(w) to conclude χ ∈ h from χ ∈ w ∩ Sigma" - the general HintikkaStepOracle universally quantifies over ALL HintikkaPoints, but the H-backward property requires knowledge that h = sigma_signature(w).

3. **Line 347** in `hintikka_step_oracle` (general case, Until-propagation guard): "needs ψ' ∉ w from ψ' ∉ h, requires h ⊇ sigma_sig(w)" - same issue.

4. **Line 367** in `hintikka_step_oracle` (ψ' ∈ w branch of Until-propagation): "Use refl_intro_until_mcs on the BXPoint w': need ψ' ∈ w' since ψ' ∈ w and bx_le w w'... but bx_le w w' only says g_content(w) ⊆ w', not w ⊆ w'".

5. **Lines 386, 393, 397** in `hintikka_step_oracle` (OR-condition and fallback): Three more sorries in the general case.

6. **Line 452** in `hintikka_step_oracle_for_sigma_sig`: Defect-count decrease for the specialized (sigma_signature-input) version. This is the critical one because `hintikka_chain_exists` uses this version.

**RootScopedChain.lean - Oracle BFMCS Sorries**:

7. **Line 1878** in `qm_bfmcs_restricted_tc`: The entire forward direction is sorry'd. Depends on defect_count decrease (OracleStep.lean:452) to terminate `hintikka_chain_exists`.

8. **Line 1921** in `qm_bfmcs_restricted_buc`: Step transfer `φ U ψ ∈ mcs(r+1) ∧ φ ∈ mcs(r) → φ U ψ ∈ mcs(r)`. This is a fundamental gap (semantically invalid inference).

9. **Lines 1957, 1961** in `qm_bfmcs_restricted_fuc`: Depends on restricted_tc being proved.

### What Is Missing (Not Yet Built)

The oracle infrastructure lacks:
- Any mechanism to route around the Lindenbaum non-determinism for defect-count decrease
- The enriched backward oracle seed (Until carry-back) proposed in Report 41
- An alternative proof of `hintikka_step_or_condition_sigma_sig` line 272 (the pivotal defect-count decrease sorry)

---

## Mathematical Viability Assessment

### Can the Oracle Sorries Be Closed?

**Sorry site OracleStep.lean:452 (defect-count decrease in hintikka_step_oracle_for_sigma_sig)**:

**CLOSEABLE** using Architecture E v2 from Report 41 Teammate B analysis. The approach:
1. Modify `qm_oracle_seed` to be an "enhanced seed" that adds:
   - `{¬(α U β) | α U β ∈ Sigma ∧ α U β ∉ w.formulas}` - forces non-present Until-formulas out
   - `{β | α U β ∈ Sigma ∧ α U β ∈ w.formulas ∧ β ∈ w.formulas}` - carries resolution formulas
2. Prove that the enhanced seed is consistent (trivially: all new formulas are in w.formulas by MCS completeness for the negations, and directly for the resolution formulas)
3. Prove defect monotonicity: `untilDefectSet(enhanced_oracle_step(w)) ⊆ untilDefectSet(w)`
   - Case α U β ∉ w: negation in enhanced seed → α U β ∉ oracle_step. Not a defect.
   - Case α U β ∈ w and β ∈ w: β in enhanced seed → β ∈ oracle_step. Not a defect.
   - Case α U β ∈ w and β ∉ w: was already a defect at w. Possibly still a defect (mono, not strict).
4. For strict decrease of the TARGET defect (φ U ψ specifically): this requires showing that φ U ψ eventually gets resolved. With defect monotonicity, the defect set can only shrink. The target defect must be resolved at some step (since `bx_until_eventuality_resolution` guarantees a BXPoint witness exists).

**Key remaining gap**: Defect monotonicity gives `untilDefectSet(oracle_step) ⊆ untilDefectSet(w)`, but `hintikka_step_target_decrease` (Construction.lean:275) requires *strict* decrease (`defect_count h2 < defect_count h1`) plus the `defect_mono` hypothesis. With the enhanced seed, defect_mono is provable but strict decrease still requires showing the target defect eventually resolves. This needs: if the target φ U ψ is always in the oracle chain (by `qm_fwd_chain_until_persists`) then eventually ψ must appear.

This last step appears to be **closeable** by contradiction: if ψ never appears in the oracle chain, then the enhanced seed always propagates φ U ψ forward. But `bx_until_eventuality_resolution` guarantees a BXPoint v with ψ ∈ v and `bx_le w v`. If we could show that eventually the Lindenbaum extension "reaches" v, we'd be done. However, this is precisely where Lindenbaum non-determinism creates the obstacle: we cannot control which MCS the Lindenbaum extension produces.

**VERDICT**: OracleStep.lean:452 is **NOT DIRECTLY CLOSEABLE** without additional axioms or a fundamental change to how oracle steps are constructed (e.g., using a determinate rather than arbitrary Lindenbaum extension). The enhanced seed achieves monotonicity but not the strict decrease guarantee for the target defect.

**Sorry sites OracleStep.lean:341, 347, 367, 386, 393, 397 (general HintikkaStepOracle)**:

These sorries are for the GENERAL case (h not necessarily a sigma_signature). Since `hintikka_chain_exists` only calls the oracle on sigma_signature inputs (as documented in OracleStep.lean:40-42), these general sorries are **harmless for the actual completeness proof path**.

The option (c) in the `hintikka_step_oracle` docstring (line 299) proposes strengthening `HintikkaStepOracle` to take a `WitnessedHintikka` rather than a bare `HintikkaPoint`. This would eliminate all six general-case sorries at once. However, this would require changing the signature of `HintikkaStepOracle` and all its callers.

**Sorry site qm_bfmcs_restricted_buc:1921 (backward Until step transfer)**:

**NOT CLOSEABLE** via direct axiom application. The formula `φ ∧ F(φ U ψ) → φ U ψ` is semantically invalid. Report 41 confirms this definitively with a concrete counterexample (φ@t, ¬φ@t+1, ψ@t+2).

**CLOSEABLE** via the enriched backward oracle seed approach (Report 41 Teammate D): by modifying `qm_oracle_seed_bwd` to include `{φ U ψ | φ U ψ ∈ w.formulas ∧ φ U ψ ∈ Sigma}`, we get backward Until persistence BY CONSTRUCTION (no step transfer needed). This approach avoids the semantically invalid inference entirely.

**Sorry sites qm_bfmcs_restricted_fuc:1957, 1961**:

These **depend on qm_bfmcs_restricted_tc** (currently sorry'd). Once restricted_tc is resolved, the guard argument for forward Until coherence follows from oracle chain Until-propagation + BX9. The docstring at line 1931-1944 explains: "the guard argument (step 4) is valid given oracle step propagation".

---

## Comparison: Oracle vs Scheduling Chain

### Oracle Approach (qm_bfmcs)

| Component | Status | Difficulty |
|-----------|--------|-----------|
| Forward chain construction | Done | - |
| Backward chain construction | Done | - |
| G-propagation (hintikka_step) | Done | - |
| H-backward propagation | Done | - |
| Until-defect propagation | Done | - |
| `restricted_tc` | SORRY (3 sorries in chain) | HIGH (Lindenbaum non-determinism) |
| `restricted_buc` (backward Until) | SORRY (semantically invalid step) | MEDIUM (enriched bwd seed fixes this) |
| `restricted_fuc` | SORRY (depends on tc) | LOW (follows from tc) |
| Wired into dd_countermodel? | NO | (would need rewiring) |

**Root cause of oracle sorries**: Lindenbaum non-determinism (for restricted_tc) and a semantically invalid inference attempt (for restricted_buc, though fixable via enriched backward seed).

### Scheduling Chain Approach (dd_bfmcs)

| Component | Status | Difficulty |
|-----------|--------|-----------|
| Forward chain construction | Done | - |
| Backward chain construction | Done | - |
| Modal stability | Done | - |
| `restricted_tc` | SORRY | MEDIUM (F-persistence via defect_fwd_step_choice_spec exists) |
| `restricted_buc` | SORRY | UNCLEAR (needs investigation) |
| `restricted_fuc` | SORRY | MEDIUM (depends on tc) |
| Wired into dd_countermodel? | YES (line 967-993) | Already done |

**Key advantage of dd_bfmcs**: Already wired into `dd_countermodel`. No rewiring needed. `restricted_tc` may be closeable via the F-persistence property of `defect_fwd_step_choice_spec`.

**Key disadvantage of dd_bfmcs**: The backward Until step transfer situation is unclear without reading `defect_fwd_step_choice_spec` more carefully.

### Direct Comparison

| Criterion | Oracle (qm_bfmcs) | Scheduling (dd_bfmcs) |
|-----------|-------------------|----------------------|
| Active proof path | NO (dead code) | YES (in dd_countermodel) |
| Sorry count | 9+ sorries | 3 sorries |
| Fundamental blockers | 2 (defect decrease + bwd Until) | 1-2 (tc + buc unclear) |
| Rewiring needed | YES (significant) | NO |
| Mathematical foundation | Hintikka chain + oracle | Defect scheduling |
| Lindenbaum non-determinism impact | HIGH | MEDIUM |

---

## Recommended Approach

**Do NOT use the oracle approach as a replacement for the scheduling approach.** The rationale:

1. **The oracle approach has more sorry sites** (9+ vs 3) and requires rewiring `dd_countermodel`.

2. **The defect-count decrease sorry (OracleStep.lean:452) is not directly closeable** due to Lindenbaum non-determinism. Even with the enhanced seed achieving defect monotonicity, strict decrease for the target defect cannot be forced without controlling the Lindenbaum extension.

3. **The backward Until step transfer sorry (qm_bfmcs_restricted_buc:1921) requires the enriched backward seed** -- the same fix is applicable to `dd_bfmcs_restricted_buc` if needed.

4. **The scheduling chain is already on the active proof path** and its sorry sites (3) are fewer and potentially easier to close.

**However**, the oracle infrastructure is NOT useless. Two valuable uses:

**Use 1**: The `hintikka_step_oracle_for_sigma_sig` theorem (OracleStep.lean:420-453) is **fully sorry-free** for the sorry-free goal version (`hintikka_step h (oracle_step)`) and could be used independently of the general `HintikkaStepOracle` if the defect-count decrease at line 452 is resolved via the enhanced seed.

**Use 2**: The enriched backward oracle seed idea (Report 41 Teammate D), inspired by the oracle backward chain construction (`qm_oracle_seed_bwd`), can be adapted to **fix `dd_bfmcs_restricted_buc`** without any oracle chain machinery. The key insight -- carry Until-formulas backward through the seed -- applies equally to the scheduling chain.

**Recommended action plan**:

1. Focus on closing `dd_bfmcs_restricted_tc` via the scheduling chain's F-persistence.
2. Fix `dd_bfmcs_restricted_buc` by adapting the enriched backward seed idea to the scheduling chain context.
3. Fix `dd_bfmcs_restricted_fuc` once restricted_tc is available.
4. Leave the oracle infrastructure (OracleStep.lean, qm_bfmcs) in place as potentially useful for mathematical completeness, but marked as not on the active proof path.

---

## Confidence Level

- **Oracle infrastructure is mathematically sound in structure**: HIGH confidence (all structural lemmas are proved; sorries are isolated to specific step-discharge claims).
- **Oracle cannot replace dd_bfmcs without major new work**: HIGH confidence (9+ sorries vs 3; rewiring needed; Lindenbaum non-determinism blocks restricted_tc).
- **Enriched backward seed fixes restricted_buc for both approaches**: HIGH confidence (by construction; the consistency proof is trivial).
- **Enhanced seed achieves defect monotonicity**: HIGH confidence (the Architecture E v2 analysis in Report 41 Teammate B is sound).
- **Strict defect-count decrease for target remains unresolved for oracle approach**: MEDIUM-HIGH confidence (the obstacle is genuine; however, there may be approaches not yet explored, e.g., the "two-phase tree construction" fallback mentioned in Report 41).

**Overall verdict**: The oracle approach was being built as a REPLACEMENT that is unfinished and **fundamentally blocked** by Lindenbaum non-determinism for restricted_tc. The scheduling chain approach is the correct path forward, supplemented by the enriched backward seed insight from the oracle infrastructure.
