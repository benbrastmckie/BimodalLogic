# Teammate B: Alternative Approaches -- Chain Replacement Analysis

## Key Findings

### A. Can dd_countermodel use a different BFMCS?

**Yes, with constraints.** `dd_countermodel` (RootScopedChain.lean:1164-1190) needs exactly three coherence proofs from its BFMCS:

1. `restricted_temporally_coherent root` (line 1185)
2. `restricted_backward_until_since_coherent root` (line 1187)
3. `restricted_forward_until_since_coherent root` (line 1188)

It also needs:
- `fully_restricted_parametric_representation_from_neg_membership` applied to a family containing the initial MCS M with `phi.neg in M`
- The BFMCS plugged into `ParametricCanonicalTaskFrame Int`, `ParametricCanonicalTaskModel Int`, `ShiftClosedParametricCanonicalOmega`

The algebraic machinery is parametric over BFMCS -- any BFMCS satisfying the three restricted coherence predicates works. The current `dd_bfmcs` could be replaced wholesale.

### B. What does BFMCS require?

A BFMCS (BFMCS.lean:84-115) has:
1. **families** : `Set (FMCS Int)` -- a set of Int-indexed MCS families
2. **nonempty** : `families.Nonempty`
3. **modal_forward** : `Box phi in fam.mcs t -> phi in fam'.mcs t` for all fam' in families
4. **modal_backward** : `(forall fam', phi in fam'.mcs t) -> Box phi in fam.mcs t`
5. **eval_family** : distinguished FMCS
6. **eval_family_mem** : eval_family in families

Each FMCS (implicitly) requires:
- `mcs : Int -> Set Formula` with `is_mcs : forall t, SetMaximalConsistent (mcs t)`
- `forward_G : t <= t' -> G(phi) in mcs t -> phi in mcs t'`
- `backward_H : t' <= t -> H(phi) in mcs t -> phi in mcs t'`

Plus the three restricted coherence predicates on the BFMCS level.

### C. The MCS-vs-HintikkaPoint Gap

**Critical gap, but bridgeable.** HintikkaPoints (HintikkaPoint.lean:43-52) are finite subsets of a Sigma-closure. They are NOT MCSs. However, the quasimodel infrastructure already bridges this:

- `sigma_signature` (HintikkaPoint.lean:85-87) projects a BXPoint (which IS an MCS) to its Sigma-component
- `qm_oracle_step` (OracleStep.lean:87-91) constructs a full BXPoint via Lindenbaum extension of the oracle seed
- `qm_oracle_step_bx_le` (OracleStep.lean:98-100) proves G-propagation at the MCS level

The quasimodel chain operates at the HintikkaPoint level for termination (defect_count bounded by |Sigma|), but each HintikkaPoint in the oracle-based construction is backed by a full BXPoint/MCS. We could extract these backing MCSs and use them as chain values.

**The extraction path**: At each oracle step, `qm_oracle_step w Sigma` gives a BXPoint whose `.formulas` is a full MCS. These MCSs satisfy:
- G-propagation: by `qm_oracle_step_bx_le` (g_content(w) subset of next)
- Until-defect propagation: by oracle seed construction
- Defect decrease: by `hintikka_step_target_decrease`

### D. The Scheduling Problem

This is the hardest sub-problem. Given `sigma_list = [phi1 U psi1, phi2 U psi2, ..., phi_k U psi_k]`, each Until formula needs its own finite chain segment to discharge. The scheduling approach:

**Option 1: Sequential concatenation.** For each Until formula `phi_i U psi_i` present at time `t`, produce a finite chain segment `[t, t + n_i]` that discharges it. Concatenate all segments. Problem: discharging `phi_1 U psi_1` might introduce new instances of `phi_2 U psi_2` at intermediate points.

**Option 2: Round-robin with quasimodel segments.** The current `preserving_fwd_step` already resolves "at least one defect" per step while preserving all F-obligations. The missing piece is proving termination of defect resolution (the sorry at line 1111).

**Option 3: Single quasimodel chain for all defects.** The oracle seed in OracleStep.lean already includes ALL Until-defects (not just one target). Each oracle step carries forward all unresolved defects and decreases defect_count by at least 1. This means a single oracle chain of length at most |Sigma| resolves ALL Until-defects simultaneously.

**Option 3 is the most promising** because:
- The oracle already handles multiple simultaneous defects
- `hintikka_step_target_decrease` proves strict decrease given defect monotonicity
- The chain length is bounded by |Sigma|, giving finite termination

### E. G-content Coherence

**Holds by construction for oracle-derived chains.** `qm_oracle_step_bx_le` (OracleStep.lean:98-100) proves `bx_le w (qm_oracle_step w Sigma)`, which means `g_content(w.formulas) subset (qm_oracle_step w Sigma).formulas`. This directly gives `forward_G` for the resulting FMCS.

For backward (H-content): `qm_oracle_step_h_content` (referenced in OracleStep.lean header, line 49) provides `h_content(oracle_step) subset w.formulas`, which gives `backward_H`.

The transitive closure of G-propagation across multiple oracle steps gives `forward_G` for the full chain.

### F. Box Stability

**Achievable but requires careful seed construction.** The current dd_bfmcs achieves box stability via `box_stable_dd_chain` (RootScopedChain.lean:743-788), which relies on:
1. `modal_fix(M0)` subset of every chain MCS (conceptually)
2. Box formulas propagate forward via `temp_future` (BX1: G(phi) -> phi gives Box(phi) -> G(Box(phi)))
3. Box formulas propagate backward via `box_to_past` and `modal_4`

For a quasimodel-derived chain, box stability requires ensuring the oracle seed includes modal_fix(M0). Currently `qm_oracle_seed` (OracleStep.lean:66-69) only includes `g_content(w) union {Until-defects}`. Box formulas ARE in g_content when Box(phi) implies G(Box(phi)) (by temp_future + modal_4), so `Box(phi) in M0 -> G(Box(phi)) in M0 -> Box(phi) in g_content(M0) -> Box(phi) in oracle_step`. The reverse (neg-Box stability) requires the same S5 argument used in `box_stable_dd_chain`.

**Assessment**: Box stability should transfer to any chain where g_content propagates, which the oracle chain provides.

### G. Cost Analysis

#### Full chain replacement approach:

**New code needed (~500-800 lines)**:
1. `quasimodel_fmcs`: Convert a sequence of oracle-step BXPoints into an FMCS (~100 lines)
2. `quasimodel_bfmcs`: Bundle shifted copies into a BFMCS with modal coherence (~150 lines)
3. `restricted_tc_by_construction`: Prove restricted temporal coherence from oracle chain properties (~100 lines)
4. `restricted_fuc_by_construction`: Prove restricted forward Until/Since coherence from defect discharge (~150 lines)
5. `restricted_buc_by_construction`: Prove restricted backward Until/Since coherence (~100 lines)
6. Integration: Wire into dd_countermodel or a new countermodel theorem (~100 lines)

**Existing infrastructure reusable**:
- `qm_oracle_seed`, `qm_oracle_step`, `qm_oracle_step_bx_le` (OracleStep.lean)
- `hintikka_step_target_decrease` (Construction.lean:275-299)
- `until_elim_mcs`, `self_accum_mcs`, `until_F_mcs` (Construction.lean:114-144)
- `box_stable_dd_chain` argument structure (RootScopedChain.lean:743-788)
- All of `BFMCS.lean`, `TemporalCoherence.lean`, `RestrictedParametricTruthLemma.lean`
- `fully_restricted_parametric_representation_from_neg_membership` (unchanged)

**NOT reusable**:
- `preserving_fwd_step` and `fwd_chain_of_sigma` (replaced by oracle chain)
- `dd_chain` assembly (replaced by quasimodel chain assembly)
- `enriched_fwd_fold` infrastructure (subsumed by oracle)

#### Minimal patching approach (proving the 3 sorries directly):

**Sorry 1** (`fwd_chain_forward_F`, line 1111): Needs a termination argument for defect resolution. The `preserving_fwd_step` resolves at least one defect per step, but proving the TARGET formula is eventually resolved requires showing defects can't cycle indefinitely. This is blocked by the BX11 perpetual deferral obstruction (documented at line 448-458).

**Sorry 2** (`dd_bfmcs_restricted_buc`, line 1153): Backward Until/Since coherence requires proving that if the witness pattern holds at the MCS level, then the Until/Since formula is in the MCS. This needs a "step transfer property" that is unavailable for Lindenbaum-based chains.

**Sorry 3** (`dd_bfmcs_restricted_fuc`, line 1160): Forward Until/Since coherence depends on restricted_tc (itself sorry'd) plus Until propagation via BX10+BX12.

**Sub-sorry in Sorry 1** (line 1138): The backward chain case of restricted_tc (F(phi) in backward chain needs resolution). The backward chain has NO F-preservation mechanism.

## Recommended Approach

**Hybrid approach: Replace the forward chain construction with oracle-based chain, keep the BFMCS/countermodel framework.**

Specifically:

1. **Replace `fwd_chain_of_sigma`** with an oracle-chain that:
   - Uses `qm_oracle_step` at each step
   - Carries forward all Until-defects from sigma_list
   - Terminates defect resolution within |sigma_list| steps
   - After all defects are resolved, continues with simple `fwd_succ` steps

2. **Replace `bwd_chain_of_sigma`** symmetrically with a Since-oracle chain.

3. **Keep `dd_bfmcs`** structure but use the new chain as the underlying FMCS.

4. **Prove the three coherence properties** from oracle chain guarantees:
   - `restricted_tc`: Oracle chain resolves F(phi) within bounded steps (by defect_count decrease)
   - `restricted_buc`: Oracle chain preserves Until-defect propagation (by seed construction)
   - `restricted_fuc`: Oracle chain + BX10 gives Until witness existence

This approach has the best risk/reward ratio because:
- It reuses the most existing infrastructure (BFMCS, parametric representation, truth lemma)
- The oracle chain's defect-decrease property is already partially proved
- The finite termination of oracle chains is the key insight from the literature (Burgess/Reynolds)
- It avoids the BX11 perpetual deferral obstruction by using structured seeds rather than round-robin

## Evidence/Examples

**The BX11 perpetual deferral obstruction** (documented at RootScopedChain.lean:448-458 and confirmed over 40 research rounds) is the fundamental reason the current approach fails. The `preserving_fwd_step` resolves "at least one" defect per step, but BX11's three-way case split means the resolved defect may not be the target. The target could be perpetually deferred to F(target) rather than being directly resolved.

**The oracle seed avoids this** because it includes ALL Until-defects in the seed, not just the target. The Lindenbaum extension of the oracle seed produces an MCS containing all propagated defects. By `hintikka_step_target_decrease`, each step that resolves any defect strictly decreases the total defect count. Since defect count is bounded by |Sigma|, ALL defects are resolved within |Sigma| steps.

**The key formula**: For a chain of length N = |Sigma|, starting from MCS M0:
```
M0 -> oracle_step(M0) -> oracle_step^2(M0) -> ... -> oracle_step^N(M0)
```
At each step i, defect_count(M_{i+1}) < defect_count(M_i) (given defect monotonicity). After at most N steps, defect_count = 0, meaning every Until formula phi U psi has psi present in the MCS.

## Confidence Level

**High confidence (8/10)** that the hybrid approach is viable. The main risk is:

1. **Defect monotonicity** (`defect_mono` hypothesis in `hintikka_step_target_decrease`): This requires that oracle steps don't introduce NEW Until-defects. The oracle seed includes all current defects but the Lindenbaum extension could theoretically introduce new ones not in Sigma. However, since we only track defects within Sigma (= subformulaClosure of root), and Sigma is closed under subformulas, new Until-formulas outside Sigma cannot appear as Sigma-defects.

2. **Since-direction symmetry**: The oracle infrastructure is built for Until (forward direction). The Since-direction (backward chain) needs a symmetric construction. The existing `sinceDefectSet` and `hintikka_step_target_decrease_since` provide the scaffolding.

3. **Integration complexity**: Wiring the new chain into the existing BFMCS framework requires careful type-level matching. The oracle chain produces BXPoints, which need to be projected to their `.formulas` field for FMCS construction.

**Medium confidence (6/10)** on the estimated code size (500-800 lines). The oracle-to-FMCS conversion may require more infrastructure than anticipated if g_content transitivity across multiple oracle steps needs explicit proof.
