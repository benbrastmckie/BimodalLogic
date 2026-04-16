# Teammate B Findings: Alternative Approaches for Task 93

**Task**: 93 - Complete BXCanonical embedding
**Role**: Alternatives researcher (Teammate B)
**Date**: 2026-04-16
**Artifact**: 29

## Key Findings

### 1. Quasimodel-to-FMCS Bridge (MOST PROMISING)

**Assessment**: The sorry-free Quasimodel directory (6 files, ~900 lines in Construction.lean + Realization.lean + LocusControl.lean) provides substantial proven infrastructure that can be bridged to BFMCS.

**What the quasimodel already proves (sorry-free)**:

- `hintikka_chain_exists` (Construction.lean:594-659): Given a `HintikkaStepOracle`, produces a `HintikkaRawChain` starting at `h0`, ending at a point containing the witness `psi`, with every point backed by a concrete `BXPoint` (`ChainWitnessed`). This is the **core chain existence theorem** for Until defect-discharge.
- `hintikka_chain_exists_since` (Construction.lean:769-824): Since-dual of the above.
- `chain_step_seed_consistent` (Construction.lean:676-690): Any subset of a chain point's formulas is `SetConsistent` via the MCS backing witness.
- `bx_until_eventuality_resolution` / `bx_since_eventuality_resolution` (Frame.lean:623-665): Given `phi U psi in w` with `psi not in w`, produces `v` with `bx_le w v` and `psi in v.formulas`.
- All MCS-level BX axiom lemmas: `until_elim_mcs`, `self_accum_mcs`, `until_F_mcs`, `connect_future_mcs`, etc.

**Can the quasimodel chain be linearized into an Int-indexed sequence?**

Yes, but not trivially. The quasimodel chain produces a `HintikkaRawChain` (a `List (HintikkaPoint Sigma)` with `ChainWitnessed`). Each point is backed by a `BXPoint` via `ChainWitnessed`. The chain resolves ONE specific Until-defect. To build an FMCS, we need an Int-indexed family that resolves ALL temporal obligations simultaneously.

The linearization strategy would be:
1. Start from a BXPoint `w0` (from the Lindenbaum extension of {neg phi}).
2. At each step, select a temporal defect (F-obligation or Until-obligation) from the current MCS.
3. Use `bx_forward_witness` (Frame.lean:164-171) to get a successor BXPoint `v` with `bx_le w v` and the witness formula present.
4. The `bx_le` relation gives `forward_G` for free: `G(chi) in w` implies `chi in v` via the definition of `bx_le`.
5. For `forward_F`: `F(psi) in w` gives `bx_forward_witness` producing `v` with `psi in v.formulas`.

**Does `bx_le` between consecutive states give forward_G?**

YES. By definition, `bx_le w v` means `g_content w.formulas subset v.formulas`, which is exactly `forall chi, G(chi) in w.formulas -> chi in v.formulas`. This is precisely the `forward_G` field of the FMCS structure. So any chain where `bx_le chain(t) chain(t+1)` automatically satisfies forward_G.

**How does the quasimodel handle F-defects?**

The quasimodel handles F-defects via `bx_forward_witness` (Frame.lean:164-171), which is proven sorry-free. Given `F(psi) in w`, it produces `v` with `bx_le w v` and `psi in v`. The Construction.lean oracle machinery then chains these single-step witnesses into a full defect-discharge chain. The key fact: `bx_forward_witness` produces a BXPoint (full MCS), not just a HintikkaPoint, so we get a complete successor state.

**forward_F comes "for free" in a specific sense**: If we build the FMCS by choosing, at each step, a BXPoint successor via `bx_forward_witness` that resolves the highest-priority F-obligation, then the F-obligation is directly resolved. The problem is resolving ALL F-obligations simultaneously in a single chain, since resolving one may destroy another (the BX11 hijacking problem from Report 17).

**Realization.lean:29-30 comment about bx_le non-totality**: The comment states:
> "The guard property in these signatures is mathematically correct but appears unprovable from BX1-BX12 due to non-totality of the `bx_le` preorder."

This refers specifically to the **guard condition** in the Until truth lemma: `forall r, t <= r -> r < s -> phi in fam.mcs r`. The issue is that intermediate BXPoints `u` between `w` and `v` (in the `bx_le` sense) need not be comparable -- `bx_le` is a preorder, not a total order. This means the guard formula might not hold at every intermediate point. This is a real obstacle for the `restricted_forward_until_since_coherent` property but NOT for `restricted_temporally_coherent` (which only needs forward_F/backward_P).

**Bridge difficulty assessment**: The bridge needs to construct:
1. `FMCS Int` with `forward_G` and `backward_H` -- **straightforward** via `bx_le` chain.
2. `restricted_temporally_coherent root` (forward_F and backward_P) -- **medium** difficulty; requires showing every F-obligation in `deferralClosure(root)` is eventually resolved.
3. `restricted_forward_until_since_coherent root` (Until/Since with guard) -- **hardest** part; the guard condition requires showing phi holds at ALL intermediate Int-indices.
4. `restricted_backward_until_since_coherent root` (backward Until/Since) -- **medium**; standard MCS argument.

**Estimated LOC**: 400-600 for a bridge that addresses forward_F/backward_P (restricted_temporally_coherent), plus 200-400 more for Until/Since coherence. Total: 600-1000 LOC.

### 2. Direct Chain Replacement Architecture

**Assessment**: Partially viable. The consumer `dd_countermodel` (RootScopedChain.lean:3762-3788) requires a `BFMCS Int` with three restricted coherence properties plus modal coherence.

**What dd_countermodel actually needs**:

```lean
dd_countermodel M h_mcs phi h_neg_in :=
  fully_restricted_parametric_representation_from_neg_membership
    (dd_bfmcs M h_mcs sigma_list) phi
    (dd_bfmcs_restricted_tc ...)   -- restricted_temporally_coherent
    (dd_bfmcs_restricted_buc ...)  -- restricted_backward_until_since_coherent
    (dd_bfmcs_restricted_fuc ...)  -- restricted_forward_until_since_coherent
    phi (self_mem_subformulaClosure phi)
    (shifted_dd_fmcs M h_mcs sigma_list 0) ⟨M, h_mcs, 0, ...⟩ 0 h_neg_fam
```

The required BFMCS properties are:
- `families : Set (FMCS Int)` -- a set of Int-indexed MCS families
- `modal_forward` / `modal_backward` -- S5 modal coherence across families
- `restricted_temporally_coherent root` -- F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)
- `restricted_forward_until_since_coherent root` -- Until witness with guard
- `restricted_backward_until_since_coherent root` -- Until backward direction

**Could we build BFMCS directly from BXPoint infrastructure?**

Yes, conceptually. The approach:
1. For each BXPoint `w`, build an FMCS by iterating `bx_forward_witness` / `bx_backward_witness` to create an Int-indexed chain.
2. The FMCS's `forward_G` and `backward_H` follow from `bx_le` transitivity.
3. Modal coherence: the existing `bx_modal_witness` (Frame.lean) and `bx_modal_equiv` give the S5 structure for free -- exactly as `dd_bfmcs` already does.

**Key insight**: The existing `dd_bfmcs` construction (RootScopedChain.lean:3699-3741) ALREADY handles modal coherence correctly (proved sorry-free). The ONLY remaining problems are the three restricted coherence theorems (lines 3744-3758). So a "direct replacement" would actually mean replacing `dd_chain` / `rr_fwd_chain` with a BXPoint-based chain while keeping `dd_bfmcs`'s modal structure.

This is essentially the same as Approach 1 (Quasimodel bridge) but without using the Hintikka/quasimodel machinery as an intermediate layer.

### 3. Filtration-Based Approach

**Assessment**: NOT viable for forward_F. The filtration infrastructure (316 lines across 2 files) provides `sigma_le`, `sigma_strict`, and `sigma_equiv` -- a Sigma-restricted ordering on BXPoints. This is useful for reasoning about finite quotients of the canonical model, but does NOT address the core forward_F problem.

**What filtration provides**:
- `sigma_le Sigma w v`: w and v agree on all G-formulas in Sigma (w forwards to v).
- `sigma_strict Sigma w v`: sigma_le plus a distinguishing witness (strict ordering).
- Properties: `bx_le_implies_sigma_le`, `sigma_strict_irrefl`, `not_bx_le_of_sigma_strict`.

**Why it does not help**:
- Filtration constructs a FINITE model by quotienting BXPoints by `sigma_equiv`. This is useful for decidability proofs but not for completeness.
- The completeness proof needs an INFINITE (Int-indexed) chain of MCS, not a finite quotient.
- The core obstacle (forward_F: showing F(psi) in chain(t) implies psi in chain(s) for some s > t) is about the construction of the chain itself, not about finiteness properties.
- The `DefectChain.lean` file provides `sigma_defect_count` infrastructure but no mechanism to actually construct the chain steps -- it only counts defects.

**The filtration files ARE useful** as supporting infrastructure for the sigma_strict guard condition (approach 1's hardest sub-problem), but they cannot independently close forward_F.

### 4. Boneyard Code Mining

**Assessment**: The Boneyard/ChainCompleteness directory (12 files) contains several partially-proved approaches, the most complete being `ResolvingChain.lean`.

**ResolvingChain.lean** (240 lines, sorry-free):
- Builds a DRM chain using `simplified_restricted_seed` (g_content + deferralDisjunctions + p_step_blocking).
- Proves `simplified_restricted_successor_succ`: the successor satisfies `Succ` (g-persistence + weak f-step).
- Proves `simplified_restricted_successor_f_step`: F(psi) in u implies psi in v OR F(psi) in v (the resolve-or-defer property).
- **Status**: Complete for chain construction, but forward_F was never proved. The module header explicitly notes: "The forward_F resolution (Phase 3) uses the existing sorry-bearing restricted chain infrastructure because the weak f_step alone is insufficient for forward_F (the Lindenbaum extension can perpetually choose F(psi) over psi)."

This is exactly the same BX11 hijacking problem from Report 17. The DRM chain has the same fundamental limitation as the round-robin chain.

**SimplifiedChain.lean** (80+ lines, sorry-free through Phase 2):
- Defines `simplified_restricted_seed` (sans f_content and boundary_resolution_set).
- Proves `simplified_restricted_seed_consistent` (trivially, since seed is subset of u).
- **Status**: Phase 1-2 done, Phase 3 (forward_F) never attempted.

**Other Boneyard files**: `DeterministicChain.lean`, `FiniteDeferral.lean`, `DeterministicFMCS.lean`, `TargetedChain.lean`, `MCSWitnessChain.lean`, `MCSWitnessSuccessor.lean`, `SuccChainWorldHistory.lean`, `SuccChainTaskFrame.lean`, `SuccChainTruth.lean` -- these are older approaches that predate the BXCanonical refactoring and use different type signatures. They are not directly usable.

**Key takeaway from Boneyard**: No Boneyard approach comes close to proving forward_F for a fixed chain. The fundamental obstacle (BX11 hijacking / Lindenbaum perpetual deferral) is present in every approach that builds a single chain via iterated Lindenbaum extension.

## Recommended Approach

**Priority 1: BXPoint-based FMCS with per-formula witness chains (Hybrid of Approaches 1 and 2)**

The core insight that breaks the BX11 hijacking deadlock: instead of building ONE chain that resolves all F-obligations simultaneously, build the FMCS by choosing, at each step, a BXPoint successor that resolves the CURRENT step's priority formula, using `bx_forward_witness` directly.

**Concrete architecture**:

1. **FMCS construction**: Given MCS M0, define `chain : Nat -> BXPoint` by:
   - `chain(0) = M0` (as a BXPoint)
   - `chain(n+1) = bx_forward_witness chain(n) (priority_target n)` where `priority_target n` is the round-robin scheduled formula from `deferralClosure(root)`.

2. **forward_G**: Holds automatically because `bx_le chain(n) chain(n+1)` and `bx_le` is transitive (via `bx_le_trans` or the G-propagation chain).

3. **forward_F proof**: For `F(psi) in chain(t)`:
   - `psi` appears in `deferralClosure(root)` which is finite (size K).
   - The round-robin schedule visits `psi` within K steps.
   - At the visit step `t + d` (where d <= K), the chain uses `bx_forward_witness chain(t+d) psi`.
   - **Critical question**: Is `F(psi) still in chain(t+d)`?

   **This is where the approach differs from RootScopedChain's round-robin**: Here `chain(t+d)` is a BXPoint (full MCS), and `bx_le chain(t) chain(t+d)` holds by transitivity. We need: if `F(psi) in chain(t)` and `bx_le chain(t) chain(t+d)`, does `F(psi) in chain(t+d)`?

   **Answer: NOT necessarily.** F-formulas do not propagate forward along `bx_le`. This is because `F(psi) = neg(G(neg(psi)))`, and the negative of a G-formula is NOT guaranteed to propagate. Specifically: `G(neg(psi)) NOT in chain(t)` (since `F(psi) in chain(t)`), but `G(neg(psi)) MAY be in chain(t+1)` (if neg(psi) is placed in the successor and then G-closed).

   **This is the same BX11 hijacking problem at the BXPoint level.** The `bx_forward_witness` resolves the target formula but may introduce `G(neg(psi))` which kills F(psi) at subsequent steps.

**Priority 2: Per-formula chain construction (existential approach)**

Given the above analysis, the most promising variant is:

For each F-obligation `F(psi) in chain(t)` individually:
1. Use `bx_forward_witness chain(t) psi` to get `v` with `bx_le chain(t) v` and `psi in v`.
2. This `v` is a BXPoint (full MCS). It does NOT need to be chain(t+1).
3. The FMCS forward_F property is existential: `exists s > t, psi in fam.mcs s`. We need `s` but it can be any future index.

The trick: define the FMCS NOT as a deterministic chain but as a sequence where, between any two consecutive "main" states, we insert the witness BXPoints for all active F-obligations. This gives an omega-squared interleaving:

```
chain(0) -> [F-witness for psi1] -> [F-witness for psi2] -> ... -> chain(1) -> ...
```

Each F-witness is a valid BXPoint with `bx_le` from the main chain state. The Int indexing accommodates this by mapping `(main_step, witness_step)` to a single integer via a pairing function.

**Estimated difficulty**: Medium-high. The construction requires:
- A well-defined pairing `Nat x Nat -> Int` (standard, ~20 lines).
- Showing `bx_le` holds between consecutive states in the interleaved chain (requires careful management of the G-propagation between main states and witness states).
- The `backward_H` direction needs a symmetric backward chain.

**Estimated LOC**: 800-1200 (matches the original estimate from Report 30).

**Priority 3: Prove forward_F only for restricted_temporally_coherent**

A pragmatic observation: the three sorry sites at RootScopedChain.lean lines 3748, 3753, 3758 could potentially be closed independently. The `restricted_temporally_coherent` property (forward_F + backward_P) might be provable with a simpler argument than the full Until/Since coherence.

Specifically: the existing `dd_chain` already satisfies `forward_G` and `backward_H` (by construction). The only gap is `forward_F`. If we can prove forward_F for the EXISTING `dd_chain` (even with a sorry at the depth-0 base case), the Until/Since coherence might follow from the proven quasimodel infrastructure.

This is essentially what RootScopedChain.lean:3617 (`rr_fwd_chain_forward_F`) attempts, with the sorry at line 3644 being the depth-0 base case.

## Evidence/Examples

**Evidence for Approach 2 viability**: The `bx_forward_witness` function (Frame.lean:164-171) is proven sorry-free and produces a complete BXPoint successor with `bx_le` and the target formula. This is the atomic building block. The `dd_bfmcs` modal coherence (lines 3699-3741) is also sorry-free. The gap is exclusively in temporal coherence.

**Evidence against filtration**: DefectChain.lean provides counting infrastructure but no chain construction. SigmaOrdering.lean provides ordering infrastructure but no forward_F mechanism. These files support the sigma_strict guard condition but cannot independently close any sorry.

**Evidence against Boneyard approaches**: ResolvingChain.lean's Phase 3 header explicitly identifies the same obstacle: "the weak f_step alone is insufficient for forward_F (the Lindenbaum extension can perpetually choose F(psi) over psi)." Every Boneyard approach that uses iterated Lindenbaum extension hits this wall.

**Evidence for quasimodel bridge**: The `hintikka_chain_exists` theorem (Construction.lean:594-659) is a complete, sorry-free, 65-line proof of chain existence with defect-discharge termination. The `ChainWitnessed` predicate guarantees MCS backing at every chain point. The `chain_step_seed_consistent` lemma provides consistency for arbitrary subsets. This is substantial proven infrastructure.

## Confidence Level

- **Quasimodel bridge for restricted_temporally_coherent**: MEDIUM-HIGH. The `bx_forward_witness` infrastructure is proven and the chain construction is conceptually clear. The main risk is the omega-squared interleaving complexity for handling multiple F-obligations simultaneously.

- **Quasimodel bridge for full Until/Since coherence**: MEDIUM-LOW. The guard condition (phi at all intermediate points) remains a genuine open problem due to bx_le non-totality. The sigma_strict infrastructure from Filtration/ may help but has not been connected to the FMCS construction.

- **Filtration approach**: LOW. Cannot address forward_F independently.

- **Boneyard approaches**: LOW. All hit the same BX11 hijacking wall.

## Summary of Sorry Sites and Dependencies

The 6 sorry sites in RootScopedChain.lean are:
1. Line 3644: `rr_fwd_chain_forward_F` depth-0 base case (root cause)
2. Line 3688: `dd_fmcs_forward_F` negative-time case (depends on #1)
3. Line 3695: `dd_fmcs_backward_P` (symmetric to #1)
4. Line 3748: `dd_bfmcs_restricted_tc` (depends on #1, #2, #3)
5. Line 3753: `dd_bfmcs_restricted_buc` (Until/Since backward)
6. Line 3758: `dd_bfmcs_restricted_fuc` (Until/Since forward)

Closing #1 (the depth-0 base case) would cascade to close #2 and #4. Closing #3 would close #4 as well. Items #5 and #6 are independent of forward_F and concern Until/Since coherence specifically.

The recommended approach is to focus on closing #1 first via the per-formula witness chain construction, then address #5 and #6 via the quasimodel chain-to-FMCS bridge.
