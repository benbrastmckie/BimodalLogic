# Research Report: Task #107 — g_content_chain_property Blocker Resolution

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-24
**Mode**: Team Research (4 teammates)
**Session**: sess_1777077832_fc367d

## Summary

Four-teammate investigation of the g_content_chain_property blocker — the single sorry preventing the BX completeness theorem. All 4 approaches from the v7 handoff were evaluated alongside creative alternatives. The key finding is a **dual blocker structure**: the chronicle has F-witnesses (sorry-free) but lacks g_content propagation, while the deterministic chain has g_content propagation (sorry-free) but lacks F-witnesses. Three actionable paths emerged, all requiring understanding of Burgess 1982's actual construction mechanism.

## Key Findings

### 1. Root Cause Confirmed: Omega-Chain Does Not Maintain C3

**From Teammate A (high confidence)**: The codebase's `eliminate_potential_counterexample` copies `chi.g` unchanged when inserting new points. Burgess maintains (f, g) pairs with C2/C3 as invariants at EVERY finite stage. The current codebase only maintains C0 (MCS property). This is a **translation error** from Burgess's paper to code, not a fundamental mathematical impossibility.

**From Teammate C**: The codebase's omega_chain return type is `{ chi : Chronicle // chi.c0 }` — C1, C2, C3 are never maintained. This confirms the root cause is architectural, not mathematical.

### 2. Seed-Based Propagation: Forward Works, Backward Fails

**From Teammate A**: g_content propagation does NOT go through g(x,y) ⊆ f(y). It goes through the **seed construction**: when point z is inserted, the seed for f(z) includes g_content(f(predecessor)), giving g_content(f(predecessor)) ⊆ f(z) by Lindenbaum. By temp_4 transitivity (lemma_2_5b), g_content of ALL earlier predecessors propagates forward.

**The BACKWARD problem**: When z is inserted between x and y, we need g_content(f(z)) ⊆ f(y). But f(y) was fixed BEFORE z existed. Lindenbaum opacity prevents controlling g_content(f(z)) — the extension could add arbitrary G-formulas not in f(y). This is the irreducible obstacle.

**Conflict resolution**: Teammate A initially suggested the seed mechanism suffices (60% confidence), but deeper analysis confirmed Teammate C's critique: the backward direction (g_content of new point ⊆ existing successor) remains unsolved by seed manipulation alone.

### 3. Dual Blocker Structure (Novel Finding)

**From Teammate B (high confidence)**:

| Approach | g_content chain | F-witness (C5) | Net Sorries |
|----------|----------------|----------------|-------------|
| Chronicle (current) | BLOCKED (1 sorry → 12 total) | PROVEN | 12 |
| Deterministic chain | PROVEN | BLOCKED (2 sorry → 4 total) | 4 |

The chronicle and deterministic chain have **complementary strengths**. The deterministic chain (`DeterministicFMCS.lean`) has:
- `forward_G_nat`: g_content propagation — sorry-free
- `backward_H_nat`: h_content propagation — sorry-free
- Only 2 leaf sorries: `deterministic_forward_F` and `deterministic_backward_P`
- These 2 leaf sorries cause 4 total (including Until/Since coherence)

### 4. Sorry Cluster Analysis (Critic Correction)

**From Teammate C**: The handoff conflates all 12 chronicle sorries into one dependency chain. In reality, there are **3 independent blocker clusters**:

1. **g_content_chain_property** (2 direct: limit_forward_G, limit_backward_H + downstream G/H coherence sorries)
2. **extended_limit_f being FALSE** (2 sorries for non-domain point MCS property — independent of g_content)
3. **Until/Since coherence** (depending on C4/C5 + guard conventions, partially independent)

### 5. Binary g: Right Direction, Incomplete Solution

**Consensus across all teammates**: The binary g(x,y) reformulation proposed in plan v7 is the right structural direction (matches Burgess), but it does NOT automatically solve the chain property. The specific step g(x,y) ⊆ f(y) for adjacent pairs has the same Lindenbaum issue. The binary g IS needed for the truth lemma's Until interval conditions, but the chain property requires additional construction changes.

### 6. C4 Seed Design Is Wrong

**From Teammate A**: The C4 elimination (`eliminate_C4_counterexample`) assigns f(z) = f(x) or f(z) = f(y) directly in sub-cases 2 and 1b, WITHOUT Lindenbaum extension from a seed including g_content. This breaks the chain property for C4-inserted points. The fix: always construct f(z) via Lindenbaum extension with seed `{neg(delta)} union g_content(f(x))`.

### 7. Alternative Approaches Evaluation

| Approach | Verdict | Reason |
|----------|---------|--------|
| Two-phase construction | BLOCKED | F(eta) doesn't propagate through g_content |
| Ordinal-indexed | BLOCKED | Rebuilding at limit stages destroys C5 witnesses |
| Enriched seeds | BLOCKED | Same F-propagation gap |
| Backward/bidirectional | BLOCKED | Lindenbaum opacity regardless of insertion position |
| Deterministic chain | **MOST PROMISING ALT** | g_content proven, only F-witness blockers (4 sorries) |
| f-Refinement (mutable f) | **CREATIVE OPTION** | Replace f-agreement with monotone refinement |
| Verbrugge finite closure | Viable but expensive | Eliminates Lindenbaum entirely; major refactor |

## Synthesis

### Conflicts Resolved

1. **"Does binary g solve the chain property?"** — Teammates A (medium) vs C (low). Resolution: Binary g is necessary but insufficient. It provides the structure for maintaining C2/C3 as invariants, but the specific mechanism for ensuring g(x,y) ⊆ f(y) at backward pairs requires a construction detail from Burgess that has not been extracted. **Score: LOW confidence that binary g alone solves it.**

2. **"Deterministic chain vs chronicle?"** — Teammates B (pivot to deterministic) vs D (stay with chronicle). Resolution: Both have merit. The deterministic chain has fewer sorries (4 vs 12) and the F-witness problem may be more tractable. However, the chronicle has ~3000 lines of infrastructure and matches the mathematical literature. **Recommendation: investigate deterministic chain's F-witness problem as a parallel track (10 hours), while continuing chronicle seed fix (primary track).**

3. **"Is Lindenbaum opacity irreducible?"** — Handoff (yes) vs Teammate C (overstated). Resolution: It is irreducible for BACKWARD propagation at a fixed point, but the construction can be designed to avoid needing backward propagation. Burgess's construction likely does this by maintaining C3 as an invariant, so backward propagation is never needed — only forward propagation at insertion time.

### Gaps Identified

1. **Nobody has read Burgess 1982** — All analysis is inferred from codebase + second-hand descriptions. The exact construction mechanism for C3 maintenance is unknown.
2. **C4 sub-case 1a may be circular** — It depends on g_content chain property, which depends on C4 being fully proved. Needs Burgess's Lemma 2.9 induction on intermediate point count.
3. **C5' elimination uses h_content seed, not g_content** — The `past_temporal_witness_seed` is `{eta} union h_content(f(x))`. This may need a symmetric fix.
4. **limit_g definition is wrong** — Currently unary `deductiveClosure(g_content(limit_f(x)))`, ignoring y. Even after binary g, the limit definition is non-trivial.
5. **Guard convention (Phase 2) is independent** — The BX9 bridge can be proved NOW without waiting for Phase 1.

## Recommendations

### Priority 1: Study Burgess 1982 Section 2 (10 hours)

**All 4 teammates converge on this recommendation.** Extract the exact mechanism for maintaining C3 through point insertion. Specific questions:
- How does Burgess define the seed for C5 witnesses to maintain C3?
- How does Burgess handle C4 insertion (Lemma 2.9) — does the seed include g_content?
- Is g(x,y) ⊆ f(y) ever needed, or does Burgess route through a different path?
- What is the exact relationship between the binary g and the truth lemma's G-case?

### Priority 2: Parallel Investigation of Deterministic Chain F-Witness (10 hours)

The deterministic chain has only 2 leaf sorries (`deterministic_forward_F`, `deterministic_backward_P`) blocking 4 total. The F-witness problem may be solvable via:
- Finite deferral infrastructure (already in codebase)
- `ordered_two_defect_seed_consistent` theorem
- BX linearity (`temp_linearity_mcs`) for priority-ordered discharge

If the deterministic chain's F-witness problem proves tractable, it provides a shorter path (4 sorries → 0) than the chronicle (12 sorries → 0).

### Priority 3: Fix C4 Seed Design (5 hours)

Independent of the g_content chain property: always construct C4 insertion points via Lindenbaum extension with seed `{neg(delta)} union g_content(f(x))`, not by copying f(x) or f(y). This fixes sub-cases 2 and 1b and may enable sub-case 1a.

### Priority 4: Separate Guard Convention Work (5 hours)

Phase 2 (BX9 bridge for half-open guard) is independent of Phase 1 (binary g). Prove `until_elim_mcs` and the half-open guard derivation NOW to reduce technical debt.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Burgess mechanism | completed | high/medium | Seed-based propagation analysis, C4 seed gap |
| B | Alternatives | completed | high/medium | Dual blocker structure, deterministic chain path |
| C | Critic | completed | high | Sorry cluster decomposition, translation error |
| D | Horizons | completed | medium | f-refinement creative option, cost-benefit analysis |

## References

- Burgess 1982 Part I — [Project Euclid](https://projecteuclid.org/euclid.ndjfl/1093870149)
- Burgess 1982 Part II — [Project Euclid](https://projecteuclid.org/euclid.ndjfl/1093870150)
- Burgess 1984 Basic Tense Logic — [Springer](https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2)
- Verbrugge et al. Completeness by Construction — [festschriften.illc.uva.nl](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- Report 16 (critical evaluation) — chronicle IS the right path
- Report 17 (binary g root cause) — unary g is architecturally wrong
- Phase 1 v7 handoff — 4 approaches analyzed, all blocked by Lindenbaum opacity
