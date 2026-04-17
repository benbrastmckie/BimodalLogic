# Research Report: Task #93

**Task**: Close TaskModel embedding sorry (sole remaining active-path sorry)
**Date**: 2026-04-17
**Mode**: Team Research (4 teammates)
**Session**: sess_1776438432_8c4a0c

## Summary

Four-teammate deep study of the Quasimodel bridge approach and all alternatives for closing the 8 sorry sites in RootScopedChain.lean. Three transformative conclusions:

1. **The quasimodel bridge as a "patch" on existing infrastructure is BLOCKED** (5 independent gaps confirmed by A, B, C). It requires REPLACING the BFMCS layer entirely, not augmenting it.
2. **The BX11 fold is non-standard and is the root cause** of the perpetual deferral problem (D confirms via literature survey). Standard temporal logic completeness uses sequential one-at-a-time targeting, never simultaneous fold.
3. **The correct path is: oracle construction + full Until/Since coherence + BX12 bridge** -- build the HintikkaStepOracle from `bx_forward_witness`, use `hintikka_chain_exists` for finite chains, and replace dd_bfmcs with a quasimodel-backed BFMCS construction.

## Key Findings

### Finding 1: Quasimodel Bridge (Patch Version) is BLOCKED

All three codebase-reading teammates (A, B, C) independently confirmed that trying to bridge the existing quasimodel infrastructure to the existing dd_bfmcs chain is blocked by multiple gaps:

| Gap | Source | Severity |
|-----|--------|----------|
| HintikkaStepOracle never constructed | A, C | CRITICAL |
| Finite chain vs. Int-indexed FMCS type mismatch | A, C | CRITICAL |
| BX12 scope: `(top U psi) notin subformulaClosure(root)` | B, C | DECISIVE for restricted coherence path |
| G-persistence loss after 1 step (hintikka_step) | A, C | MEDIUM (navigable for one step) |
| Realization.lean delegates to sorry-carrying Frame.lean | A, C | CLARIFIED (only the realization functions, not Construction.lean) |

**Resolution**: The quasimodel bridge is not a patch. It requires a new BFMCS construction (~1500-2000 LOC as full replacement, per A; or ~600-900 LOC if narrowly scoped to the oracle + lifting + integration).

### Finding 2: BX11 Fold is Non-Standard (Literature Confirmation)

Teammate D's literature survey confirms:

- **Standard approach** (Burgess 1984, Reynolds 2003, Gabbay-Hodkinson-Reynolds 1994): Sequential one-at-a-time targeting with f_carry in the seed. Each formula gets a dedicated step. F-persistence comes from f_carry, not from fold.
- **BX11 fold**: Attempts simultaneous resolution of all F-formulas via a fold over the formula list. This is a codebase innovation not found in the literature. The fold can perpetually defer any specific formula.
- **Extended seed inconsistency** (`{target} union g_content(M) union f_carry(M)`) is a genuine obstacle in the BX axiom system (Case 4: `F(G(neg psi)) in M`). Standard proofs sidestep this by working over simpler time flows or using different techniques.
- **No known completeness proof for S5+LTL(Until,Since) over Z found in the literature**. The closest reference is Finger-Gabbay's product construction.

### Finding 3: All Alternative Approaches Are BLOCKED

Teammate B evaluated 6 alternative approaches:

| Approach | Verdict | Key Obstacle |
|----------|---------|-------------|
| DRM Chain Revival | BLOCKED | Negation completeness for iter_F in deferralClosure |
| Enriched Until-Aware Seed | BLOCKED | G-lift fails for non-G-liftable seed elements |
| Finite Deferral Pigeonhole | BLOCKED | Circular G(neg psi) derivation; `until_induction` axiom removed |
| BX12 + Full Until/Since | VIABLE | Oracle construction needed; closure alignment via full coherence |
| BXPointChain (bx_forward_witness) | PARTIALLY VIABLE | F-persistence lost; covers forward_F but not Until/Since |
| self_resolving Round-Robin | BLOCKED | Non-target F(chi) not preserved |

**New discovery (B)**: The FiniteDeferral Boneyard's `G_neg_kills_until` theorem references a REMOVED `until_induction` axiom (line 325), making that entire Boneyard approach potentially unsound.

### Finding 4: The Oracle Construction IS Feasible (A's Corrected Analysis)

Teammate A's detailed analysis (lines 196-238 of their report) provides a corrected assessment:

**The H-backward clause of hintikka_step CAN be satisfied** by the `bx_forward_witness` construction:
- Given BXPoint `w` backing HintikkaPoint `h1 = sigma_signature(w, Sigma)`
- `bx_forward_witness` gives BXPoint `v` with `bx_le w v`
- Next HintikkaPoint `h2 = sigma_signature(v, Sigma)`
- H-backward: `H(chi) in h2 -> chi in h1` works because:
  - `H(chi) in sigma_signature(v, Sigma)` means `H(chi) in v.formulas`
  - `bx_H_forward(bx_le w v)` gives `chi in w.formulas`
  - `chi in Sigma` and `chi in w.formulas` gives `chi in sigma_signature(w, Sigma) = h1`
- G-propagation (one step): `G(chi) in h1 -> chi in h2` works via `bx_le w v`

**G-persistence over multiple steps is NOT needed** by the quasimodel framework. `hintikka_step` only requires one-step G-propagation, and `hintikka_chain_exists` (Construction.lean) only uses `hintikka_step`.

### Finding 5: Full Until/Since Coherence Avoids Closure Gap

The BX12 scope mismatch (C's decisive finding) blocks the path through `restricted_forward_until_since_coherent` because `(top U psi) notin subformulaClosure(root)`.

**Solution** (converged by B, D): Prove **full (unrestricted) Until/Since coherence**. This covers ALL Until formulas including BX12-derived `(top U psi)`, and the restricted version follows as a corollary.

The full coherence is actually easier to state and avoids the subformulaClosure membership check entirely.

### Finding 6: Quasimodel Chain Provides Until Guard for Free

The hintikka_step Until propagation clause provides the full Until coherence guard:
- If `(phi U psi) in h_i` and `psi notin h_i`, then `phi in h_i` AND `(phi U psi) in h_{i+1}`
- This gives `phi in h_r` for all `r in [start, k)` where `k` is the discharge step
- This is EXACTLY the guard condition required by Until coherence

Combined with the defect_count termination (Construction.lean), the quasimodel chain provides full Until coherence at the HintikkaPoint level. Lifting to BXPoint level works via sigma_signature (phi in h_i iff phi in Sigma and phi in w_i).

### Finding 7: The Correct Architecture

The literature (D) and the codebase analysis (A, B, C) converge on one architecture:

1. **Build the HintikkaStepOracle** from `bx_forward_witness` (~200-300 LOC)
   - Input: HintikkaPoint h with Until-defect (phi U psi in h, psi notin h)
   - Get backing BXPoint w (from WitnessedHintikka)
   - Use `bx_forward_witness` to get v with `bx_le w v` and psi in v
   - Project: `sigma_signature(v, Sigma)` gives next HintikkaPoint
   - Prove: hintikka_step h h' (G-propagation and H-backward from bx_le, Until propagation from BX9/BX10)

2. **Use hintikka_chain_exists** (already sorry-free in Construction.lean)
   - Produces finite chain discharging all Until defects
   - Termination via defect_count decrease
   - Each chain element has a backing BXPoint

3. **Build new BFMCS from BXPoint chain** (~200-400 LOC)
   - The backing BXPoints form an FMCS (they are MCS with bx_le between consecutive states)
   - Extend to Int-indexed: forward chain resolves all eventualities, backward chain symmetric
   - For positions past the finite chain: use the last BXPoint (which has all defects resolved)

4. **Prove full Until/Since coherence** (~100-200 LOC)
   - Follows from hintikka_step's Until propagation + defect_count termination
   - Guard condition: phi in chain(r) for all r in [start, discharge_step) from hintikka_step

5. **Derive forward_F via BX12** (~50-100 LOC)
   - F(psi) in chain(t) -> (top U psi) in chain(t) (BX12)
   - Full Until coherence gives witness s > t with psi in chain(s)
   - Guard: top in chain(r) for r in [t,s) -- trivially true (top = neg bot, and bot not in any MCS)

6. **Wire into dd_countermodel** (~100-200 LOC)
   - Replace or supplement dd_bfmcs with the new quasimodel-backed BFMCS
   - Derive restricted coherence from full coherence

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| A: quasimodel bridge LOW confidence vs. D: approach is viable | **Both correct**: the NAIVE bridge (patching existing chain) is LOW. Building a NEW BFMCS from quasimodel is VIABLE. The distinction is patch vs. replacement. |
| C: 5 blocking gaps vs. D: oracle is the only gap | **C's gaps are real but several have known solutions**: (1) BX12 scope -> full coherence; (2) finite-to-Int -> new BFMCS construction; (3) Lindenbaum circularity -> use BXPoints directly; (4) G-persistence -> not needed (one-step suffices); (5) Realization.lean -> we bypass it, build oracle from bx_forward_witness directly |
| B: BXPointChain approach has F-persistence gap vs. D: BX12 bypass | **D is correct**: BX12 converts F to Until. The quasimodel handles Until without needing F-persistence. The BXPointChain approach (B's Approach 5) is a stepping stone but incomplete alone. |
| A: "most viable path is singleton defect chain" vs. consensus | **Overruled**: The singleton defect chain maps forward_F for one formula but doesn't solve Until/Since coherence (sorry sites 1522, 1527). The oracle + full coherence path solves ALL 8 sites. |

### Gaps Remaining

1. **Oracle construction specifics** (~200-300 LOC): The exact construction of `HintikkaStepOracle` from `bx_forward_witness`. A's analysis shows it's feasible but implementation details need working out. Key question: does Sigma (the SubformulaClosure/enrichedClosure) need to include `(top U psi)` formulas for the BX12 bridge?

2. **Int extension of finite chain** (~100-200 LOC): The quasimodel gives a finite chain of length <= |Sigma|. Need to extend to Int. Forward: repeat last state (all defects resolved). Backward: symmetric construction. The last-state extension must satisfy g_content propagation (which it does: G(chi) in M and MCS gives chi in M, so g_content(M) subset M holds reflexively).

3. **Sigma closure for BX12** (~50-100 LOC): Ensure that `enrichedClosure` or `extendedDeferralClosure` includes `(top U psi)` formulas needed by BX12 bridge. EnrichedClosure.lean may already handle this.

4. **Backward direction (P, Since)** (~200-300 LOC): Symmetric construction using `bx_backward_witness`. The quasimodel framework has `hintikka_chain_exists_since` (Construction.lean) for the backward direction.

### Recommendations

**Primary Strategy**: Oracle Construction + Full Until/Since Coherence + BX12 Bridge

| Phase | Component | LOC | Risk |
|-------|-----------|-----|------|
| 0 | Verify Sigma closure includes BX12-derived formulas | 50-100 | LOW |
| 1 | HintikkaStepOracle from bx_forward_witness | 200-300 | MEDIUM |
| 2 | New BFMCS from quasimodel chain + Int extension | 200-400 | MEDIUM |
| 3 | Full Until/Since coherence proof | 100-200 | LOW (follows from hintikka_step) |
| 4 | Forward_F/backward_P via BX12 bridge | 50-100 | LOW |
| 5 | Wire into dd_countermodel + close 8 sorry sites | 100-200 | MEDIUM |

**Total**: 700-1300 LOC, 60-70% success probability
**Key risk**: Phase 1 (oracle construction) and Phase 2 (BFMCS construction) are the critical path

**Fallback**: If the oracle construction hits an unexpected obstacle, the backup is to modify the restricted coherence predicate to use `extendedDeferralClosure` instead of `subformulaClosure`, reducing the scope of what needs to be proved. This is a smaller change (~200-300 LOC) but requires modifying existing sorry-free infrastructure.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Quasimodel bridge deep study | completed | LOW (for patch), MEDIUM (for replacement) |
| B | Alternative approaches | completed | MEDIUM |
| C | Critic - mathematical soundness | completed | HIGH |
| D | Literature + strategic horizons | completed | MEDIUM-HIGH |

## Dead Ends Confirmed (Round 36)

Adding to the cumulative dead-end list:

| # | Approach | Why Dead |
|---|----------|----------|
| 20 | DRM chain bounded_witness | Negation completeness for iter_F beyond closure_F_bound |
| 21 | Enriched Until-aware seed | G-lift fails for deferralDisjunctions + p_step_blocking |
| 22 | FiniteDeferral Boneyard | Circular G(neg psi); `until_induction` axiom removed |
| 23 | self_resolving round-robin | Non-target F-persistence unproved and likely false |
| 24 | Naive quasimodel patch | 5 blocking gaps (BX12 scope, finite-to-Int, Lindenbaum circularity, G-persistence, delegation) |
| 25 | BXPointChain alone | F-persistence lost in bx_forward_witness steps |

## References

### Codebase
- Quasimodel/Construction.lean (887 lines, sorry-free abstract framework)
- Quasimodel/HintikkaPoint.lean (167 lines, sigma_signature)
- Quasimodel/Realization.lean (445 lines, analysis of Phase 5 obstacles)
- BXCanonical/Frame.lean (bx_forward_witness at lines 164-171, sorry-free)
- BXCanonical/RootScopedChain.lean (sorry sites at 1413, 1457, 1464, 1517, 1522, 1527, 2196, 2289)
- BXCanonical/CanonicalChain.lean (BX12 F_imp_top_until_mcs at 65-72)
- Bundle/TemporalCoherence.lean (restricted coherence predicates)
- Bundle/UntilSinceCoherence.lean (backward Until from step transfer)
- Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean (removed axiom issue)

### Literature (from Teammate D)
- Burgess (1982/1984): Sequential one-at-a-time defect discharge
- Reynolds (1996, 2003): Quasimodel technique with defect_count termination
- Gabbay, Hodkinson, Reynolds (1994): Standard temporal logic completeness
- Finger, Gabbay (1996): Combining temporal logic systems via product construction
- Marx, Mikulas, Reynolds (2000): Mosaic method for temporal logics
