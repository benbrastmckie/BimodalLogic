# Round 30 - Teammate A: Quasimodel Bridge Deep Analysis

## Key Findings

### 1. The Quasimodel Infrastructure Is Sorry-Free But Operates at a Different Level

The quasimodel infrastructure (Construction.lean, Realization.lean, LocusControl.lean) is sorry-free and proves:

- `hintikka_chain_exists` (Construction.lean:594-659): Given a step oracle, constructs a **finite** raw Hintikka chain from `h0` to a point where the Until-witness `psi` is present. Well-founded recursion on `defect_count`.
- `hintikka_chain_exists_since` (Construction.lean:769-824): Symmetric for Since.
- `bx_until_eventuality_resolution` (Frame.lean:623-643): Given `phi U psi in w` with `psi not in w`, produces a BXPoint `v` with `bx_le w v` and `psi in v`. This is a **one-step** result: it finds a single future BXPoint where psi holds.

**Critical observation**: These results produce **individual BXPoints** or **finite chains of HintikkaPoints**. They do NOT produce Int-indexed FMCS families. The gap between "exists v : BXPoint with bx_le w v and psi in v" and "exists s : Int, t < s and psi in fam.mcs(s)" is the entire problem.

### 2. How the Quasimodel Avoids BX11 Hijacking

The quasimodel construction avoids BX11 hijacking through **targeted defect discharge**:

- `HintikkaStepOracle` (Construction.lean:477-483): At each point carrying the target Until-defect, the oracle produces a next point that either:
  - (a) Contains `psi` (witness reached), OR
  - (b) Has `defect_count` strictly decreased while preserving the target defect

- The key is that the oracle builds **fresh BXPoints at each step** via Lindenbaum extension of carefully chosen seeds. Each step is a **separate** Lindenbaum extension, not a round-robin schedule. The target defect `phi U psi` is explicitly maintained in the seed, so BX11 cannot hijack it.

- Termination: `defect_count` is bounded by `|Sigma|`, so the chain terminates in at most `|Sigma|` steps.

### 3. The Bridging Gap: Finite Quasimodel Chain to Int-Indexed FMCS

The 6 sorry sites require:

**Sorry 1** (line 3644): `rr_fwd_chain_forward_F` depth-0 base case
- Need: `F(psi) in rr_fwd_chain(n) => exists s > n, psi in rr_fwd_chain(s)`
- The rr_fwd_chain is a **fixed** Nat-indexed chain using round-robin scheduling.

**Sorry 2** (line 3688): `dd_fmcs_forward_F` backward chain case
- Need: Forward F when starting in the backward chain (t < 0)

**Sorry 3** (line 3695): `dd_fmcs_backward_P`
- Symmetric to forward_F but for the past direction

**Sorry 4** (line 3748): `dd_bfmcs_restricted_tc`
- Need: Every family in `dd_bfmcs` satisfies restricted temporal coherence (forward_F + backward_P for deferralClosure formulas)

**Sorry 5** (line 3753): `dd_bfmcs_restricted_buc`
- Need: Backward Until/Since coherence: semantic truth of Until implies Until in MCS

**Sorry 6** (line 3758): `dd_bfmcs_restricted_fuc`
- Need: Forward Until/Since coherence: Until in MCS implies semantic witness exists

### 4. Approach A Assessment: Replace rr_fwd_chain with Quasimodel-Based Chain

The quasimodel bridge would need to:

**Step 1**: Replace `rr_fwd_chain` with a chain that, at each step with an active F-defect `F(psi)`, uses the quasimodel construction to build a **dedicated sub-chain** that resolves psi. This is essentially a priority-based chain construction.

**Obstacle 4a**: The quasimodel oracle produces **BXPoints** backed by Lindenbaum extension. Each BXPoint is a full MCS (Set Formula). The chain needs `g_content` propagation (G(phi) in chain(n) => phi in chain(n+1)), which is guaranteed by construction in the current `enriched_fwd_step` but would need to be verified for the quasimodel-derived chain steps.

**Obstacle 4b**: The quasimodel chain resolves ONE specific Until-defect at a time. But the forward_F theorem needs ALL F-obligations to eventually resolve. If resolving one defect kills F-obligations for other formulas (the BX11 hijacking problem), the chain doesn't compose.

**Obstacle 4c**: The `enriched_fwd_step` already tries to protect all F-formulas from sigma_list (line 586: filters sigma_list for formulas with F-obligations). The problem is that at a resolving step, the Lindenbaum extension can still choose `G(neg psi)` for some formula psi whose F-obligation we want to preserve.

### 5. The Real Architecture of the Bridge

A true quasimodel bridge would need to:

1. **Define a new chain construction** `qm_fwd_chain : Nat -> Set Formula` where:
   - At step n, identify the "most urgent" F-defect from sigma_list
   - Use the quasimodel step oracle to produce the next MCS that resolves it
   - Ensure g_content propagation is maintained

2. **Prove forward_F** for this new chain:
   - Given F(psi) in qm_fwd_chain(n), the chain will eventually target psi
   - When psi is targeted, the quasimodel step gives psi in the next MCS
   - Need: F(psi) persists until psi is targeted

3. **The persistence problem remains**: Between the time F(psi) appears and the time it gets targeted, other quasimodel steps may kill F(psi). This is EXACTLY the same BX11 hijacking problem.

### 6. Why the Quasimodel Bridge Does NOT Solve the Core Problem

The quasimodel infrastructure solves a **different** problem than what's needed:

- **What quasimodel solves**: Given `phi U psi in w`, find a BXPoint `v` with `bx_le w v` and `psi in v`. This is a **local** existence result. It says: there EXISTS a future MCS containing psi. No chain construction needed.

- **What the sorries need**: Given an **omega-chain** of MCSs (the dd_fmcs), show that F(psi) at position t implies psi at some position s > t **within that specific chain**. This is a **global** property of a particular infinite chain construction.

The quasimodel gives us `exists v : BXPoint, bx_le w v and psi in v`, but the challenge is embedding this BXPoint into the **fixed chain** dd_fmcs. The chain is defined recursively, and v may not equal any chain(s) for s > t.

### 7. What Would Actually Work: Redefine the Chain Construction

To use the quasimodel, you would need to **completely replace** the `rr_fwd_chain` / `dd_chain` construction with one that incorporates the quasimodel:

**Option A1: Interleaved quasimodel chains**
- For each F-defect at step n, splice in a quasimodel sub-chain that resolves it
- This gives an omega-squared structure: the main chain has spliced-in sub-chains
- Requires flattening omega * omega -> omega (possible but complex)
- **LOC estimate**: 400-600 new LOC for chain construction, 300-400 for forward_F proof
- **Risk**: Medium-high. G-content propagation through the spliced chains is non-trivial.

**Option A2: Direct quasimodel FMCS**
- Instead of building an omega-chain, use the quasimodel to construct the FMCS directly
- Define `qm_fmcs.mcs(t)` using Classical.choice: for each t, choose an MCS that is consistent with all obligations up to step t
- This avoids the chain construction entirely but requires careful choice-function management
- **LOC estimate**: 300-500 for FMCS construction, 200-400 for coherence proofs
- **Risk**: High. Non-constructive, hard to verify g_content/h_content coherence.

### 8. The Forward/Backward Until/Since Coherence Sorries (lines 3748-3758)

These sorries are SEPARATE from the forward_F problem:

- `restricted_forward_until_since_coherent`: needs `phi U psi in fam.mcs(t) => exists s >= t, psi in fam.mcs(s) and phi guards [t,s)`. This is stronger than forward_F because it also requires the **guard** property (phi holds at all intermediate times).

- `restricted_backward_until_since_coherent`: needs the **converse**: if the semantic condition holds, then `phi U psi in fam.mcs(t)`. This should follow from BX axioms (BX8/BX11) applied at the MCS level.

For the forward case, the quasimodel's `hintikka_chain_guard_step` (Construction.lean:842-848) proves the guard at HintikkaPoint level, but bridging to the Int-indexed FMCS chain level has the same embedding problem.

For the backward case, BX11 (`(phi U psi) <-> (psi or (phi and X(phi U psi)))`) should make this provable for any MCS chain, since it's an MCS-level property. This sorry may be closable independently.

## Recommended Approach

**Do NOT pursue the quasimodel bridge as the primary strategy.** The quasimodel infrastructure solves the wrong problem (local BXPoint existence vs. global chain property).

Instead, the most viable path is:

**Priority 1: Close sorries 5 and 6 (backward/forward Until/Since coherence) independently.** These are about MCS-level properties of Until/Since formulas and should be provable directly from BX axioms without any chain construction changes. Specifically:

- `restricted_backward_until_since_coherent` (sorry 5): If semantic Until holds at time t in the FMCS, then `phi U psi in fam.mcs(t)`. Proof sketch: induction using BX8 (psi => phi U psi) and BX11 ((phi U psi) <-> (psi or (phi and X(phi U psi)))).

- `restricted_forward_until_since_coherent` (sorry 6): If `phi U psi in fam.mcs(t)`, find witness. Proof: BX10 gives F(psi) in fam.mcs(t), then forward_F gives s > t with psi in fam.mcs(s). Guard from BX9/BX5/self-accumulation. **BUT this depends on forward_F (sorry 1/4).**

**Priority 2: For forward_F (sorry 1), consider approach C (Classical.choice-based chain).** Replace rr_fwd_chain with a chain that uses Classical.choice at each step to pick an MCS that resolves the "most overdue" F-defect. This avoids the round-robin scheduling that allows BX11 hijacking.

## Obstacles Identified

| # | Obstacle | Severity | Notes |
|---|----------|----------|-------|
| 1 | Quasimodel gives local BXPoint existence, not global chain property | **Critical** | Fundamental mismatch between what quasimodel provides and what forward_F needs |
| 2 | G-content propagation through quasimodel sub-chains | High | Quasimodel steps build fresh BXPoints; g_content of the parent chain may not persist |
| 3 | F-obligation persistence between quasimodel targeting rounds | High | Same BX11 hijacking problem persists at the meta-level |
| 4 | Chain flattening (omega-squared to omega) | Medium | Technically doable but adds 200+ LOC of index arithmetic |
| 5 | Until guard property requires chain-level control | Medium | Forward Until needs phi at ALL intermediate steps, not just existence of psi |

## Evidence/Examples

- Quasimodel step oracle produces fresh BXPoints: Construction.lean:477-483
- BX11 hijacking documented: RootScopedChain.lean:3596-3616
- Enriched fwd_step already tries F-protection: RootScopedChain.lean:583-590
- Forward Until/Since coherence definitions: TemporalCoherence.lean:535-544, 565-574
- Truth lemma consuming all three coherence properties: RestrictedParametricTruthLemma.lean:308-464
- dd_countermodel using all sorry targets: RootScopedChain.lean:3762-3788

## Confidence Level

**Medium-Low** for the quasimodel bridge approach specifically. The fundamental mismatch (local existence vs. global chain property) is a deep architectural obstacle, not a technical detail. Even with 800-1200 LOC of bridging code, the BX11 hijacking problem re-emerges at the interleaving level.

**Medium** for closing sorries 5 and 6 independently (Until/Since backward coherence should be provable from BX axioms alone).

**Medium** for approach C (Classical.choice chain) as the path to forward_F, though this requires further research.
