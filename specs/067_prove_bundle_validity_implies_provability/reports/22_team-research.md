# Research Report: Task #67 — Plan 07 Review and Task Relation Approach

**Task**: 67 — prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Mode**: Team Research (2 teammates)
**Session**: sess_1774803889_0e5b27

## Summary

Plan 07 (wire restricted chain) has a sound core mechanism (transfer-back via DRM maximality) but three significant issues: Phase 1 is already done, Phase 3 has hidden backward-chain sorries, and Phase 5 integration is fundamentally underspecified because `boxClassFamilies` uses unrestricted `SuccChainFMCS`, not restricted chains. The task relation approach clarifies the semantic requirement (family-level temporal coherence = world histories where every F/P obligation is resolved) but does not provide a new proof path. The dovetailing approach (replacing `omega_chain_forward` to resolve ALL F-obligations round-robin) is the most mathematically principled solution, achieving temporal coherence by construction rather than through fuel-bound or transfer-back arguments.

## Key Findings

### 1. Plan 07 Has Three Significant Issues (Teammate A)

**Phase 1 is already done**: `extendToMCS_transfer_back` is implemented and sorry-free at SuccChainFMCS.lean:3180. The DRM maximality property is formalized and the proof works via contradiction. No implementation work needed.

**Phase 3 has hidden sorry debt**: Two structural sorries exist in backward chain infrastructure that Plan 07 depends on:
- `constrained_predecessor_restricted_g_persistence_reverse` (line 3944): "if G(chi) ∈ predecessor, then chi ∈ u" — comment admits argument is circular
- `constrained_predecessor_restricted_f_step_forward` (line 4001): case "chi ∉ u and F(chi) ∉ u but F(chi) ∈ predecessor" unresolved
- `constrained_predecessor_restricted_succ` (line 4009) depends on both

**Phase 5 integration is underspecified**: `boxClassFamilies` builds families as `shifted_fmcs (SuccChainFMCS S) delta` where `SuccChainFMCS` uses plain `forward_chain`/`backward_chain` over arbitrary `SerialMCS` — NOT restricted chains. The `FMCS` structure has `forward_G`/`backward_H` fields but NO `forward_F`/`backward_P` — temporal coherence is a separate predicate. The plan proposes `restricted_Z_chain_family` without addressing how it connects to `boxClassFamilies`.

**Revised effort estimate**: 14-21h vs plan's 8-12h.

### 2. Task Relation Semantics (Teammate B)

The task relation (`TaskFrame.lean:93`) encodes reachability: `task_rel w d u` means state `u` is reachable from `w` by a task of duration `d`. World histories are functions from convex time domains to world states where adjacent states satisfy the task relation — precisely what an FMCS encodes at the canonical level.

**Semantic clarification**: World histories = valid execution sequences = temporally coherent FMCS families. The task relation constrains which chains are valid. The truth lemma for G/H formulas requires that F/P witnesses lie within the SAME world history.

**But this doesn't bypass the sorry**: The task relation re-describes the requirement without providing a new construction. The same gap remains — how to ensure each individual FMCS family resolves all F/P obligations within itself.

### 3. The Actual Gap (Both Teammates Agree)

The sorry is NOT about:
- CS ⊆ MCS ∈ FMCS ∈ BFMCS — this is already done (`construct_bfmcs_bundle`, sorry-free)
- Bundle-level coherence — this is already done (F(phi) in fam.mcs(t) → ∃ fam' in bundle, s > t, phi in fam'.mcs(s))

The sorry IS about:
- **Family-level temporal coherence**: F(phi) in fam.mcs(t) → ∃ s > t, phi in fam.mcs(s) (SAME family)
- Required by the truth lemma's backward direction for G formulas
- Current `SuccChainFMCS` families don't guarantee this

The `omega_chain_forward` construction only resolves `F_top` at each step (not arbitrary F-obligations), causing the gap. The crossing-chain sorry (`Z_chain_forward_G`:2347) shows G-theory doesn't propagate from backward to forward chain.

### 4. Dovetailing Is the Most Principled Solution

**Why dovetailing wins**:
- Achieves temporal coherence **by construction** rather than through a separate termination/transfer argument
- Each step resolves a specific F-obligation via `Nat.unpair` enumeration
- Fairness guarantee: every F-obligation is eventually resolved
- Avoids the crossing-chain G-theory problem (forward/backward chains are explicitly symmetric)
- Aligns directly with task relation semantics: valid world histories = chains where every temporal obligation is resolved

**Why Plan 07 (wire restricted chain) falls short**:
- Phase 3 backward chain has unsolved sorries
- Phase 5 can't connect restricted chains (over fixed phi) to `boxClassFamilies` (over arbitrary MCS W)
- Scope coverage gap: F(psi) for psi outside `deferralClosure(phi)` in extended MCS
- Transfer-back approach is indirect — proves coherence by connecting two different constructions

## Synthesis

### Conflicts Resolved

| Point | Teammate A | Teammate B | Resolution |
|-------|-----------|-----------|------------|
| Plan 07 viability | Sound core, 3 significant issues | Correct but indirect | **Both right**: mechanism works but integration is harder than acknowledged |
| Task relation value | Not directly analyzed | Clarifies but doesn't bypass | **Teammate B correct**: semantic clarification, not new proof path |
| Recommended path | Fix Phase 3 sorries first | Dovetailing more principled | **Synthesis**: dovetailing avoids both Phase 3 sorries AND Phase 5 integration gap |

### Gaps Identified

1. **No concrete dovetailing implementation analysis**: Neither teammate provided Lean-level implementation details for the dovetailed construction. How exactly does `omega_chain_dovetailed` interact with `SuccChainFMCS`?

2. **Crossing-chain G-theory**: Teammate B identified the `Z_chain_forward_G` crossing sorry (line 2347). Does dovetailing resolve this, or is it a separate issue?

3. **Backward chain dovetailing**: The dovetailing approach is described for forward chains. How does the backward (P-obligation) direction work symmetrically?

### Recommendations

**Primary recommendation: Dovetailed OmegaFMCS construction**

Replace `omega_chain_forward` (which only resolves F_top) with a construction that enumerates and resolves ALL F-obligations round-robin:

1. At step n: decode (time_index, obligation_index) = Nat.unpair(n)
2. Resolve the obligation_index-th F-obligation present at time_index
3. Fairness guarantees every F-obligation is eventually resolved
4. This provides `forward_F` at the family level by construction

**Why this is the most principled approach**:
- From the task relation perspective: valid world histories are chains where every F/P obligation is eventually resolved. Dovetailing constructs exactly this.
- Avoids Plan 07's integration gap (no need to connect restricted chains to boxClassFamilies)
- Avoids backward chain sorries (build symmetric dovetailed backward chain)
- Avoids fuel exhaustion sorry (no fuel parameter needed)
- Follows Segerberg's bulldozing technique (1970) — the textbook approach

**Secondary recommendation**: If dovetailing proves too complex, fix the backward chain sorries in SuccChainFMCS and find a way to connect restricted chains to boxClassFamilies (Plan 07 with fixes).

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Plan 07 verification | completed | MEDIUM | Found 3 significant plan issues: Phase 1 done, Phase 3 sorries, Phase 5 underspecified |
| B | Task relation analysis | completed | HIGH | Confirmed gap is family-level coherence, dovetailing is most principled |

## References

### Key Files
- `SuccChainFMCS.lean:3180` — extendToMCS_transfer_back (already sorry-free)
- `SuccChainFMCS.lean:3944` — constrained_predecessor_restricted_g_persistence_reverse (SORRY)
- `SuccChainFMCS.lean:4001` — constrained_predecessor_restricted_f_step_forward (SORRY)
- `UltrafilterChain.lean:1553` — boxClassFamilies definition (uses plain SuccChainFMCS)
- `UltrafilterChain.lean:2347` — Z_chain_forward_G crossing sorry
- `UltrafilterChain.lean:2424-2485` — Z_chain_forward_F sorry
- `UltrafilterChain.lean:2643-2681` — bundle_forward_F (sorry-free)
- `UltrafilterChain.lean:2853-2870` — construct_bfmcs_bundle (sorry-free)
- `UltrafilterChain.lean:2882-2905` — explicit documentation of coherence gap
- `Completeness.lean:220-226` — bfmcs_from_mcs_temporally_coherent (sorry)
- `TemporalCoherence.lean:216-219` — BFMCS.temporally_coherent predicate
- `TaskFrame.lean:93-122` — task relation definition

### Textbook References
- Segerberg 1970 "bulldozing" technique — fair scheduling for temporal obligations
- Blackburn, de Rijke, Venema "Modal Logic" Ch. 4 — Existence Lemma for flat canonical models
