# Round 44 Teammate A: Quasimodel Periodic Embedding into Int-indexed BFMCS

## Key Findings

### A. The Finite-to-Infinite Bridge

The core challenge: the quasimodel chain is finite (length <= |Sigma| steps), but the BFMCS needs an Int-indexed family of MCSs. After careful code analysis, the bridge works as follows:

**The quasimodel chain does NOT need to tile all of Z.** The restricted coherence properties only require LOCAL witnessing:

1. `restricted_tc`: F(phi) in mcs(t) => exists s > t with phi in mcs(s) -- needs a FINITE forward witness
2. `restricted_fuc`: phi U psi in mcs(t) => exists s >= t with psi in mcs(s) and phi in [t,s) -- needs a FINITE forward witness
3. `restricted_buc`: semantic Until condition => phi U psi in mcs(t) -- needs a membership proof at a SINGLE point

The quasimodel chain provides exactly these finite witnesses. We don't need to replace the entire dd_chain -- we need to USE the quasimodel chain infrastructure to prove that the dd_chain's MCSs satisfy these local properties.

**Key architectural insight**: The dd_chain already exists and provides the Int-indexed family. The quasimodel chain infrastructure provides the PROOF TECHNIQUE for establishing the coherence properties, not an alternative chain construction.

### B. The HintikkaPoint-to-MCS Bridge

The projection goes MCS -> HintikkaPoint via `sigma_signature`. The critical question is whether we need the reverse direction. Analysis:

- `sigma_signature w Sigma` projects w's formulas to Sigma, yielding a HintikkaPoint
- `qm_oracle_step w Sigma` takes a BXPoint w and produces a SUCCESSOR BXPoint via Lindenbaum extension of `g_content(w) U {Until-defects in Sigma}`
- The oracle step is sorry-free for sigma_signature inputs (`hintikka_step_for_sigma_sig` at OracleStep.lean:188)
- `hintikka_chain_exists` (Construction.lean:594) is sorry-free and builds the full chain

The reverse direction (HintikkaPoint -> MCS) is already handled:
- `WitnessedHintikka` bundles a HintikkaPoint with a backing BXPoint
- `ChainWitnessed` ensures every point in the chain has a backing BXPoint
- `hintikka_chain_exists` produces `ChainWitnessed` chains

So the bridge is: start with a BXPoint w, project to sigma_signature to get h0, build the quasimodel chain of HintikkaPoints, and every point is backed by a BXPoint witness.

### C. The Periodic Extension Question

**Periodic extension is NOT needed.** This was a red herring from earlier rounds. The restricted coherence properties are universally quantified over time points but only require local witnesses. At each time point t where an obligation arises (e.g., F(phi) in mcs(t)), we invoke the quasimodel chain starting from the BXPoint backing mcs(t) to get the witness. Different time points use different quasimodel chain instances.

### D. The Family Membership Question

The BFMCS families are indexed by box-equivalent MCSs shifted by integers:
```
families := { fam | exists N h_N s, (forall phi, box phi in M0 <-> box phi in N) /\ fam = shifted_dd_fmcs N h_N sigma_list s }
```

The quasimodel chain produces BXPoints related by `bx_le`. The critical property: `bx_le w v` means `g_content(w) subset v.formulas`. This is EXACTLY the property the dd_chain's `fwd_chain_of_sigma` preserves (`preserving_fwd_step_g_content` at RootScopedChain.lean:569).

The quasimodel chain's BXPoint witnesses are NOT in the dd_chain family -- they are free-standing BXPoints used only to prove properties. The dd_chain family members are the actual MCSs indexed by Z. The quasimodel witnesses prove that the dd_chain MCSs have the right membership properties.

### E. Concrete Proof Strategies

#### Strategy for restricted_tc (line 1114)

The current approach in `fwd_chain_forward_F` (line 1090) tries to show F(phi) eventually resolves in the dd_chain. This is blocked because `Classical.choice` in Lindenbaum extension makes defect resolution uncontrollable.

**New approach using quasimodel infrastructure**:

Given: F(phi) in mcs(t), where mcs(t) is an MCS from dd_chain.

1. mcs(t) is an MCS, hence a BXPoint `w_t`
2. F(phi) in w_t means (by `bx_forward_witness`) there exists BXPoint v with `bx_le w_t v` and `phi in v`
3. This gives us phi in SOME MCS v, but NOT necessarily in the dd_chain

**The real fix**: We don't prove F-resolution within the dd_chain. Instead, we CHANGE THE CHAIN CONSTRUCTION to use the quasimodel oracle step instead of `preserving_fwd_step`.

Specifically, replace `fwd_chain_of_sigma` with a chain built by iterating `qm_oracle_step`:
```
quasimodel_fwd_chain M0 h0 Sigma : Nat -> BXPoint
  | 0 => w0  (where w0 backs M0)
  | n+1 => qm_oracle_step (quasimodel_fwd_chain M0 h0 Sigma n) Sigma
```

This chain has:
- G-propagation: `qm_oracle_step_bx_le` gives `bx_le chain(n) chain(n+1)`
- H-backward: `qm_oracle_step_h_content` gives `h_content(chain(n+1)) subset chain(n)`
- Until defect propagation: `qm_oracle_step_until_in_next`
- Defect resolution: `hintikka_step_or_condition_sigma_sig` (modulo the sorry at line 272)

**The remaining sorry at OracleStep.lean:272** is the defect_count decrease. This is the ONE remaining hard problem. It requires showing `untilDefectSet(sigma_sig(oracle)) subset untilDefectSet(sigma_sig(w))`, which fails because Lindenbaum extension may introduce new Until-formulas.

#### Strategy for restricted_fuc (line 1155)

Given: phi U psi in mcs(t).

1. mcs(t) is a BXPoint w_t
2. If psi in w_t, done (reflexive case, `t <= t`)
3. If psi not in w_t: invoke `hintikka_chain_exists` with oracle from `hintikka_step_oracle`
4. Get chain h0, h1, ..., hk with psi in hk.formulas and phi in h0,...,h(k-1).formulas
5. Each hi is backed by BXPoint wi with `bx_le w(i) w(i+1)`
6. The wi chain gives a finite sequence of MCSs with the right memberships
7. Map this to dd_chain indices: w0 at time t, w1 at time t+1, etc.

**Blocker**: Step 7 is the gap. The quasimodel chain produces BXPoints w0, w1, ..., wk. But the dd_chain at times t, t+1, ..., t+k are DIFFERENT MCSs (built by preserving_fwd_step). We cannot substitute the quasimodel BXPoints into the dd_chain.

**Resolution path**: Replace the dd_chain construction entirely. Build the Int-indexed chain by:
- At each time step, use `qm_oracle_step` to advance
- This ensures the chain's MCSs are exactly the quasimodel BXPoints
- Then restricted_fuc follows from `hintikka_chain_exists`

#### Strategy for restricted_buc (line 1147)

Given: exists s >= t with psi in mcs(s) and phi in [t,s) mcs(r). Need: phi U psi in mcs(t).

This is the BACKWARD introduction. The standard proof:

1. At mcs(t): either psi in mcs(t) (then by BX8: phi U psi in mcs(t)) or psi not in mcs(t)
2. If psi not in mcs(t): phi in mcs(t) (given). Need phi U psi in mcs(t).
3. By BX12 (induction axiom for Until): if phi in mcs(t) and phi U psi in mcs(t+1), then phi U psi in mcs(t)
4. Induction from s down to t: at mcs(s), psi in mcs(s) so phi U psi in mcs(s) by BX8. Work backwards.

This requires: g_content(mcs(t)) subset mcs(t+1) (to apply BX12 transfer). The dd_chain guarantees this via `preserving_fwd_step_g_content`. So BX12 gives:

phi U psi in mcs(t+1) and g_content(mcs(t)) subset mcs(t+1) => we can derive phi U psi in mcs(t) if phi in mcs(t) and (phi U psi) in mcs(t+1).

**The key BX axiom needed**: BX12 (until_induction): `(phi /\ G(phi U psi)) -> phi U psi`. At MCS level: if phi in mcs(t) and G(phi U psi) in mcs(t), then phi U psi in mcs(t).

From the hypothesis: phi U psi in mcs(t+1). Since g_content(mcs(t)) subset mcs(t+1), we need G(phi U psi) in mcs(t). But that requires phi U psi in mcs(t+1) and the G-relationship, which gives us: if phi U psi in mcs(t+1) and bx_le mcs(t) mcs(t+1), then we do NOT directly get G(phi U psi) in mcs(t).

Actually the relationship is: G(chi) in mcs(t) => chi in mcs(t+1) (forward). The reverse (chi in mcs(t+1) => G(chi) in mcs(t)) does NOT hold. So backward Until induction via BX12 does NOT directly work.

**Alternative for buc**: Use the contrapositive approach. Suppose phi U psi not in mcs(t). Then neg(phi U psi) in mcs(t). Show this leads to contradiction with the hypothesis.

neg(phi U psi) in mcs(t) means: by BX axioms, neg(psi) in mcs(t) AND (neg(phi) OR neg(phi U psi) eventually).

This is actually the HARDEST of the three. It requires showing that the chain's G-propagation of neg(phi U psi) conflicts with the witnessed Until condition. The standard literature proof uses the canonical model where the temporal ordering IS bx_le, giving the transfer property directly. In the dd_chain construction, the ordering is Z (integers), not bx_le, so the transfer is weaker.

## Recommended Approach

**Replace the dd_chain construction with a quasimodel-oracle-based chain.**

The fundamental problem is that `preserving_fwd_step` uses Lindenbaum extension with `Classical.choice`, making defect resolution uncontrollable. The quasimodel infrastructure (`qm_oracle_step`) uses Lindenbaum extension TOO, but it has the crucial property that the seed includes Until-defects explicitly, giving controlled defect propagation.

Concrete plan:

1. **New chain construction**: Build `qm_fwd_chain : BXPoint -> Finset Formula -> Nat -> BXPoint` by iterating `qm_oracle_step`. Build `qm_bwd_chain` by iterating `qm_oracle_step_bwd`.

2. **Int-indexed assembly**: Combine forward and backward chains at Int indices, similar to current `dd_chain`.

3. **restricted_tc proof**: At any time t with F(phi) in chain(t), the chain(t+1) = qm_oracle_step(chain(t), Sigma). By `bx_forward_witness`, phi eventually appears. The defect-count argument from `hintikka_chain_exists` gives the finite bound.

4. **restricted_fuc proof**: Invoke `hintikka_chain_exists` starting from chain(t). The chain IS the quasimodel chain, so the witness falls directly within the Int-indexed family.

5. **restricted_buc proof**: Use contrapositive + BX12 induction axiom. The key is that in the oracle-based chain, G-propagation is controlled: `bx_le chain(t) chain(t+1)` gives the transfer property needed for backward induction.

**The one remaining hard gap**: The sorry at `hintikka_step_or_condition_sigma_sig` (OracleStep.lean:272) -- proving defect_count decreases. This requires showing Lindenbaum extension doesn't introduce new Until-defects at the Sigma level. This is hard because Lindenbaum is opaque.

**Potential fix for the defect_count gap**: Strengthen the oracle seed to include ALL Until-formulas from Sigma (not just defects). This way, the Lindenbaum extension cannot introduce new Until-formulas from Sigma that aren't already in the seed. Then:
- Any Until phi psi in sigma_sig(oracle_step) was either in the seed (hence a defect at w) or introduced by Lindenbaum
- If the seed already contains ALL Until-formulas from Sigma that are in w, Lindenbaum can only introduce Until-formulas NOT in w
- But sigma_sig only keeps formulas in BOTH Sigma AND oracle_step
- A Until-formula in oracle_step but NOT in w could be in Sigma, creating a new sigma-sig defect

This doesn't fully close the gap either. The real solution may be to bypass defect_count entirely and use `hintikka_chain_exists` which already handles the termination via strong induction.

## Evidence/Examples

The sorry-free theorems that constitute the working infrastructure:
- `hintikka_chain_exists` (Construction.lean:594-659) -- SORRY-FREE
- `hintikka_step_for_sigma_sig` (OracleStep.lean:188-222) -- SORRY-FREE
- `qm_oracle_step_bx_le` (OracleStep.lean:98-100) -- SORRY-FREE
- `qm_oracle_step_h_content` (OracleStep.lean:103-106) -- SORRY-FREE
- `chain_step_seed_consistent` (Construction.lean:676-690) -- SORRY-FREE
- `bx_until_eventuality_resolution` (Frame.lean:623-643) -- SORRY-FREE

The remaining sorries:
- `hintikka_step_or_condition_sigma_sig` defect decrease (OracleStep.lean:272)
- `hintikka_step_oracle` H-backward for general case (OracleStep.lean:341)
- `hintikka_step_oracle` Until-propagation guard for general case (OracleStep.lean:348)
- `fwd_chain_forward_F` (RootScopedChain.lean:1111)
- `dd_bfmcs_restricted_tc` backward case (RootScopedChain.lean:1138)
- `dd_bfmcs_restricted_tc` P-direction (RootScopedChain.lean:1145)
- `dd_bfmcs_restricted_buc` (RootScopedChain.lean:1153)
- `dd_bfmcs_restricted_fuc` (RootScopedChain.lean:1160)

## Confidence Level

**45% confidence** that the quasimodel-oracle-based chain replacement can close all 3 sorries.

Factors reducing confidence:
- The defect_count decrease sorry in OracleStep.lean:272 is a genuine gap that transfers to any oracle-based approach
- restricted_buc requires backward induction that may need additional axiom infrastructure beyond what's currently formalized
- The gap between "BXPoint witness exists" and "BXPoint witness is in the dd_chain family" persists even with an oracle-based chain, because the BFMCS families require box-equivalence

Factors increasing confidence:
- The quasimodel infrastructure is sorry-free at the core level (hintikka_chain_exists, chain witnessing)
- The eventuality resolution lemmas in Frame.lean are sorry-free
- The oracle step for sigma_signature inputs is fully proved
- The approach aligns with the standard literature (Burgess 1984, Reynolds 1996, Verbrugge 2007)

**The critical path**: Close OracleStep.lean:272 (defect_count decrease), then build the oracle-based dd_chain replacement.
