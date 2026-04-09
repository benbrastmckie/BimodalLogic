# Research Report: Task #88 (Round 2)

**Task**: 88 — Close remaining 6 BXCanonical sorries
**Date**: 2026-04-09
**Mode**: Team Research (4 teammates)
**Context**: Round 2 research after Phase 1 implementation (axiom restoration complete, phases 2-5 blocked)

## Summary

Phase 1 added `temp_linearity` (BX11), `temp_linearity_past` (BX11'), `F_until_equiv` (BX12), and `P_since_equiv` (BX12') to the axiom system with full soundness proofs. Four downstream sorries were closed. However, the original plan's Phase 2 goal — proving `bx_le_total` globally — is mathematically impossible (all 4 teammates agree, consistent with the round 1 counterexample).

The key breakthrough is a **reformulated Phase 2 goal**: instead of global bx_le totality, prove **interval-specific linearity** — that any two BXPoints reachable from a common predecessor with an Until formula are bx_le-comparable. This is what the eventuality resolution sorries actually need, and it IS derivable from the new axioms via BX7 + BX4 + F_until_equiv. This reformulation was independently identified by Teammates B and D and validated by Teammate C's analysis of what each sorry site actually requires.

## Key Findings

### 1. Global bx_le Totality Is False; Interval Linearity Is the Correct Goal

**Consensus (4/4 teammates)**: `bx_le_total : ∀ (w v : BXPoint), bx_le w v ∨ bx_le v w` is false. Two arbitrary MCSs can have incomparable g_content. The round 1 counterexample stands.

**New insight (Teammates B, D)**: The Frame.lean sorries do NOT require global totality. They require: given `φ U ψ ∈ w`, any two BXPoints u, v both reachable from w (via bx_le) are comparable. This **interval linearity** is derivable because:
- `φ U ψ ∈ w` → `F(ψ) ∈ w` (BX10) → `⊤ U ψ ∈ w` (BX12/F_until_equiv)
- BX7 (linear_until) constrains witness ordering for Until formulas at w
- BX4 (connect_future: `α → G(P(α))`) propagates Until-membership forward via g_content

**Confidence**: 70% that interval linearity is provable in Lean (Teammate D). The mathematical argument is standard in the literature but formalization requires careful proof engineering.

### 2. Concrete Proof Path for Forward Until (Frame.lean:653)

Teammate B identified the most detailed proof sketch using BX12 + BX7:

1. From `φ U ψ ∈ w` and BX10: `F(ψ) ∈ w`
2. From BX12 (F_until_equiv): `⊤ U ψ ∈ w`
3. BX5 (self_accum_until) on `φ U ψ`: `(φ ∧ (φ U ψ)) U ψ ∈ w`
4. BX7 (linear_until) on `(φ ∧ (φ U ψ)) U ψ` and `⊤ U ψ`: witnesses are linearly ordered
5. For intermediate u: BX4 gives `G(P(φ U ψ)) ∈ w`, so `P(φ U ψ) ∈ u`, yielding backward witness with `φ U ψ`. BX9 (until_elim: `φ U ψ → φ ∨ ψ`) gives the guard.

**Critical gap (Teammate C, 85% confidence)**: Step 5 requires showing `φ U ψ ∈ u` at intermediate points, not just `P(φ U ψ) ∈ u`. The backward witness from P gives an arbitrary predecessor, not necessarily one on the interval. Guard propagation may require well-foundedness or induction arguments beyond what BX7 alone provides.

### 3. Backward Until May Be Simpler Than Expected

Teammate B proposes that the backward Until sorry (Frame.lean:675) may be closable by **direct contradiction + BX8** without needing interval linearity:

- The sorry signature takes the guard as a hypothesis
- If `¬(φ U ψ) ∈ w`, then `G(P(¬(φ U ψ))) ∈ w` (BX4), propagating to `v` where `ψ ∈ v`
- BX8 (ψ → φ U ψ) gives `φ U ψ ∈ v`, contradicting `¬(φ U ψ) ∈ v`

**Assessment**: This sketch is promising but needs verification that BX4 gives exactly `G(P(¬(φ U ψ)))` and that the contradiction chain is complete.

### 4. CanonicalEmbedding Sorry (Line 418) Requires New Infrastructure

**Consensus (Teammates A, B, C)**: The imp Case B sorry needs non-constant WorldHistory construction. A constant history collapses `G(α)` to `α`, so `flatten(χ) ∈ w` does not imply `χ ∈ w`.

**Fix**: Build a two-point history using `bx_forward_witness` (sorry-free) to get `v ≥ w`. Use `G_iff_mcs`/`H_iff_mcs` from TruthLemma.lean for the truth bridge.

**Risk (Teammate C)**: WorldHistory construction infrastructure doesn't exist yet. Estimated 4-8 hours, not the plan's 2 hours.

**Dependency**: Teammate D notes this depends on Phase 3 (eventuality resolution) being complete, since the countermodel needs chain structure.

### 5. Completeness.lean Sorry Is Not Purely Downstream

**Teammate C (75% confidence)**: The Completeness.lean:160 sorry requires constructing a concrete `TaskModel` value, not just wiring together existing lemmas. This includes building WorldHistory objects from BXPoint chains and proving the temporal structure matches the TaskFrame ordering. Estimated 4-8 hours, not 1.5 hours.

### 6. Chain Extraction as Backup Architecture

**Teammate A** provides the most detailed analysis of the chain extraction alternative:

- Build `ChainCompleteness.lean` with chain-indexed BXPoints where linearity holds by construction
- Bypass Frame.lean sorries entirely (they become dead code)
- Reuse existing infrastructure: BXPoint, bx_le, bx_forward/backward_witness, TruthLemma (non-Until cases)
- **Main blocker**: Until persistence through enriched seeds (X-vs-G mismatch)
- Enriched seeds (`g_content(w) ∪ {all Until formulas of w}`) may solve this if consistency is provable
- Estimated effort: 21-39 hours

### 7. Quick Wins Available Now

**Consensus (Teammates B, D)**: Several downstream sorries are mechanically closable with the new axiom constructors:

- ConservativeExtension/Lifting.lean: `Extsorry /- temp_linearity removed in BX -/` → use `Axiom.temp_linearity` constructor
- DovetailedChain.lean:572: `sorry /- F_until_equiv removed in BX -/` → already closed in Phase 1
- FiniteDeferral.lean: Similar pattern (blocked by import errors)

Estimated: 1-2 hours for ConservativeExtension fixes.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate B | Resolution |
|----------|-----------|-----------|------------|
| Can BX12+BX7 close Frame.lean? | X-vs-G mismatch blocks | YES (80%) | **Partially**: BX12+BX7 provides witness ordering, but guard propagation to intermediate points remains the hard step. Teammate B's sketch is the best available path but Teammate C's concern about well-foundedness is valid. |
| Approach priority | Chain extraction | Direct proof via axioms | **Start with direct proof** (lower effort, higher confidence per Teammate B). Fall back to chain extraction if blocked after 8-hour spike. |
| Phase 4 effort | 3-5 hours | 4-8 hours | **4-8 hours** (Teammate C's assessment includes new infrastructure cost) |

### Gaps Identified

1. **Guard propagation mechanism**: How exactly does `φ ∈ u` get established for strictly intermediate u? BX4 gives `P(φ U ψ) ∈ u` but the backward witness may not be on the interval. This is the single hardest proof obligation.

2. **Well-foundedness**: Even with interval linearity, the guard argument may need induction on interval length. Is this formalizable for BXPoints?

3. **WorldHistory construction**: No infrastructure exists for building non-constant WorldHistory from BXPoint chains. Needed for both CanonicalEmbedding and Completeness sorries.

4. **BX4 variant check**: Need to verify exactly which connectedness axiom is available. Is `φ U ψ → G(P(φ U ψ))` derivable from the current axiom set?

### Recommendations

**Primary path** (estimated 14-28 hours, 65% confidence):
1. Reformulate Phase 2 as interval linearity (2-4 hours)
2. Close Frame.lean forward Until using BX12+BX7+BX4+BX9 (4-8 hours)
3. Close Frame.lean backward Until via direct contradiction (2-4 hours)
4. Mirror for Since cases (2-4 hours)
5. Build WorldHistory infrastructure for CanonicalEmbedding (4-8 hours)
6. Close Completeness.lean (2-4 hours)

**Quick wins** (1-2 hours, 90% confidence):
- Close remaining ConservativeExtension sorries tagged "removed in BX"

**Backup path** (20-39 hours, 50% confidence):
- Chain extraction via ChainCompleteness.lean if interval linearity fails

**FMP spike** (2 hours, 55% confidence):
- Investigate whether FMP bridge can bypass BXCanonical entirely
- Teammate D suggests this is worth exploring before committing to full Phase 2

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Chain Extraction | completed | MEDIUM-HIGH | Detailed X-vs-G mismatch analysis; enriched seeds proposal |
| B | Alternative Approaches | completed | HIGH (80%) | BX12+BX7 proof path; BX4 guard propagation; no FMP bridge |
| C | Critic | completed | HIGH (90%) | Guard propagation gap; well-foundedness concern; scope underestimates |
| D | Strategic Horizons | completed | MEDIUM-HIGH (70%) | Interval linearity reformulation; quick wins; FMP spike recommendation |

## References

- Burgess (1984): "Basic Tense Logic" — chain extraction technique for temporal completeness
- Xu (1988): Temporal logic completeness via dovetailed scheduling
- Round 1 report: `specs/088_close_remaining_bxcanonical_sorries/reports/01_team-research.md`
- Phase 1 summary: `specs/088_close_remaining_bxcanonical_sorries/summaries/01_implementation-summary.md`
- Frame.lean sorry analysis: lines 585-622 (note: stale docstring, needs update)
