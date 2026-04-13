# Research Report: Task #102 — Resolution Paths for 4 Remaining Frame.lean Sorries

**Task**: 102 - Implement defect-discharge chain and close Until/Since sorries
**Date**: 2026-04-12
**Mode**: Team Research (4 teammates, round 5)
**Session**: sess_1776054236_8274bc

## Summary

All 4 teammates converge on a clear picture: the 4 remaining Frame.lean sorries (lines ~612-647) are **architecturally unprovable as stated** because they quantify over arbitrary BXPoints in a `bx_le` interval, but `bx_le` (g_content subset inclusion) is a non-total preorder that includes "junk points" from unrelated Lindenbaum extensions. No axiom addition or definition restructuring can control what formulas appear in these junk points.

**Verdict on the three proposed paths**:

| Path | Verdict | Confidence | Effort |
|------|---------|------------|--------|
| 1. Until induction axiom | **REJECT** — does not close the sorries | High (Teammate A) | N/A |
| 2. Chain-based completeness bypass | **VIABLE with caveats** | Medium-High | 300-400 lines |
| 3. Restructure bx_le | **REJECT** — not a coherent distinct path | High (Teammate C) | N/A |

**Two new alternatives emerged from Critic analysis**:

| Alternative | Description | Confidence | Effort |
|-------------|-------------|------------|--------|
| A. Weaken sorry signatures | Quantify over chain members only, not all bx_le BXPoints | Medium (65%) | Moderate |
| B. Inductive reformulation via unfolding theorem | Use `φ U ψ → ψ ∨ (φ ∧ F(φ U ψ))` to reformulate TruthLemma | Medium (40%) | Low (3-5h) |

## Key Findings

### Path 1: Until Induction Axiom — REJECTED

**Teammate A (High Confidence)**: The reflexive Until induction axiom `G(ψ → χ) ∧ G((φ ∧ χ) → χ) → ((φ U ψ) → χ)` was deliberately removed in task 83 phase 1 (commit `1d9bd6160`) when switching to reflexive semantics, replaced by BX5+BX6+BX7. It IS sound on all linear orders (does not require discreteness).

**Critical finding**: Adding it back **does not close the 4 sorries**. The "seed consistency" role is already covered by BX10 (WitnessSeed.lean is sorry-free). The guard problem — showing `φ ∈ u` for arbitrary intermediate BXPoints `u` — is structural. Until induction with `χ = φ` requires the base premise `G(ψ → φ)`, which is not provable from `φ U ψ ∈ w` alone.

**Teammate C concurs**: The axiom is valid only on discrete/well-founded orders in its strongest form. The reflexive version is sound but insufficient for the guard property.

**Teammate D dissents partially**: Claims Until induction is the fastest path (8-12h, 85% confidence). However, this contradicts Teammate A's detailed analysis showing the axiom doesn't address the actual gap. **Resolution**: Teammate D's assessment appears based on incomplete analysis of the sorry signatures — they evaluated the axiom's general utility rather than its specific applicability to the guard property. Teammate A's signature-level analysis is more authoritative here.

### Path 2: Chain-Based Completeness Bypass — VIABLE

**Teammate B (High Confidence on temporal component)**: The bypass route is mathematically clear:
1. Build a bi-infinite chain `(w_i : BXPoint)_{i:Int}` using iterated `bx_forward_witness` + `bx_backward_witness` with defect-discharge seeding
2. Define `task_rel w_i d w_j := j = i + d`
3. Guard property is trivially satisfied on chain by induction on chain index using `defect_step_phi` (already proved in DefectChain.lean)
4. Route: `Completeness.lean` → new chain truth lemma → bypasses Frame.lean entirely

**Existing infrastructure**: `bx_forward_witness`, `bx_backward_witness`, `defect_step_phi`, `defect_step_F_psi`, `sigma_defect_count_bounded` are all proved. Missing piece: assembly into `BXChain` type + chain truth lemma (~300-400 new lines).

**Teammate C caveat (important)**: The temporal component (Until/Since) works, but there's an open gap for the **S5 box modality truth lemma**. Nobody has worked out how to construct `Omega` (the shift-closed history set) so that box modality holds at chain positions. Confidence in FULL completeness: 40%.

**Teammate D caveat**: Claims chain bypass is "not viable" based on v4 plan analysis, but this contradicts Teammate B's concrete infrastructure inventory. **Resolution**: Teammate D's assessment refers to the broader Hintikka/MCS abstraction gap (which is real for full completeness), while Teammate B focuses on the temporal component only. Both are correct in their respective scopes.

### Path 3: Restructure bx_le — REJECTED

**Teammate C (High Confidence)**: This is not a coherent distinct path. It either reduces to Path 2 (using a sub-ordering on chain members) or requires changing `bx_le`'s definition globally, which breaks all downstream lemmas and requires re-proving soundness. Confidence as distinct path: 10%.

### Alternative A: Weaken Sorry Signatures (from Critic)

Change the 4 Frame.lean sorry signatures to quantify over **chain members only** rather than all BXPoints satisfying `bx_le`. This aligns the code with what the mathematics actually requires — the TruthLemma only needs the guard property at points that appear in world histories, which are chain members.

**Advantage**: Minimal code change, fixes the root cause (over-general signatures).
**Risk**: Need to verify TruthLemma callers actually only need chain-member quantification.
**Confidence**: 65%. Moderate effort.

### Alternative B: Inductive Reformulation via Unfolding (from Critic)

The derived theorem `φ U ψ → ψ ∨ (φ ∧ F(φ U ψ))` (proved in round 3 from BX1+BX9) gives a one-step unfolding. If the backward direction holds, the TruthLemma Until case can be reformulated inductively without touching Frame.lean at all.

**Advantage**: Very cheap to time-box (3-5h). If it works, bypasses Frame.lean entirely at the TruthLemma level.
**Risk**: Backward direction may not hold; termination of the inductive unfolding may be tricky.
**Confidence**: 40%.

## Synthesis

### Conflicts Resolved

1. **Teammate A vs D on Path 1**: Teammate A's signature-level analysis overrides Teammate D's general assessment. Until induction does NOT close these specific sorries.
2. **Teammate B vs D on Path 2**: Both partially correct. Chain bypass works for temporal component; full completeness (including S5 box) remains open. These are different scopes.

### Gaps Identified

1. **S5 box modality at chain positions**: No teammate fully analyzed how to construct the shift-closed history set `Omega` for chain positions. This is the critical gap for full completeness via any chain-based approach.
2. **Backward direction of unfolding theorem**: Not yet verified whether `ψ ∨ (φ ∧ F(φ U ψ)) → φ U ψ` is derivable.
3. **TruthLemma caller analysis**: No one traced exactly what the TruthLemma callers need from the 4 sorry'd lemmas to validate Alternative A.

### Root Cause (consensus)

The Frame.lean sorries conflate **information-theoretic ordering** (`bx_le` = g_content inclusion, capturing safety properties) with **positional ordering** (world history index, needed for liveness/guard conditions). The sorries ask for liveness guarantees (`φ` holds at intermediate points) using safety infrastructure (`bx_le` intervals), which is a category error. All three proposed paths patch symptoms; Alternatives A and B fix causes.

### Recommendations

**Recommended investigation order** (minimize wasted effort):

1. **Alternative B first (3-5h time-box)**: Check if the unfolding theorem approach works at the TruthLemma level. Cheapest option with decent odds.
2. **Alternative A second (8-12h)**: Weaken Frame.lean signatures to quantify over chain members. Aligns code with mathematics.
3. **Path 2 if both fail (300-400 lines)**: Full chain-based bypass of Frame.lean. Requires additional work on S5 box modality gap.
4. **Long-term**: Spawn a separate task for quotient/filtration model architecture (Teammate D recommendation, aligns with quasimodel pivot goals).

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Until induction axiom | completed | high | Proved Path 1 doesn't close sorries; identified junk point problem |
| B | Chain-based bypass | completed | high (temporal) | Concrete infrastructure inventory; viable bypass route |
| C | Critic | completed | high | Identified root cause; proposed Alternatives A and B |
| D | Strategic horizons | completed | medium | Long-term architecture assessment; quotient model recommendation |

## References

- Burgess 1984 — Until induction axiom (reflexive form)
- Task 83 phase 1 (commit `1d9bd6160`) — Axiom refactoring that removed until_induction
- BX10/WitnessSeed.lean — Seed consistency (sorry-free)
- DefectChain.lean — `defect_step_phi`, `bx_forward_witness`, `bx_backward_witness`
- CanonicalChain.lean — BX axiom analysis and bypass documentation
- Round 3 research — Unfolding theorem `φ U ψ → ψ ∨ (φ ∧ F(φ U ψ))` from BX1+BX9
