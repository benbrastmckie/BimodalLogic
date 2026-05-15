# Research Report: Task #153 — Prove succ_cofinal for discrete limit domains

**Task**: 153 — prove_succ_cofinal_discrete
**Date**: 2026-05-15
**Mode**: Team Research (4 teammates)
**Session**: sess_1778879761_8fd87d_t153

## Summary

Four teammates investigated the provability of `succ_cofinal` (ChronicleToCountermodel.lean:1885) from complementary angles. The central conflict — whether the constant-MCS case is the hard case or is formally excluded — was resolved in favor of exclusion: **Prior-UZ combined with the formalized truth lemma (`limit_satisfies_c5_strong`) rules out constant-MCS scenarios**, because `U(φ, ¬φ)` cannot have a C5 witness when all domain points share the same MCS (the guard `¬φ` is never present). This eliminates the supposedly intractable case identified in report 01.

However, resolving the constant-MCS case does NOT make succ_cofinal easy. The non-constant case still faces the core obstacle: even with a discriminating formula φ, controlling its truth at ALL future limit domain points (not just orbit points) is required for backward_G and Z1 to yield a contradiction. The pred-chain points have unknown φ-status, and Prior-UZ gives only "nearest witness" information, not universal control. Teammate A's extensive analysis shows the gap scenario remains self-consistent at the order-theoretic level even with non-constant MCS, and that the contradiction must ultimately come from construction internals (how the omega-chain resolves counterexamples).

All four teammates converge on the same strategic recommendation: **the Reynolds pipeline (tasks 154→155) should be the primary path to sorry-free `bx_completeness`**, with succ_cofinal as a secondary parallel effort. The Reynolds approach is more standard in the literature (Reynolds 1994, Doets 1989), produces less dead code, and advances dense completeness work. Task 153 should apply a hard stopping rule: if the non-constant case is not resolved within 3 implementation phases, deprioritize in favor of the Reynolds path.

## Key Findings

### Primary Approach (Teammate A)

Teammate A conducted the most detailed mathematical analysis, tracing the proof-by-contradiction setup at the sorry site through multiple sub-cases. Key results:

- **M = L is provable**: The pred-chain infimum M equals the orbit limit L. Proof: if M > L, then succ(orbit point) would be a limit_dom point in the gap (L, M), contradicting the absence of limit_dom points there (established by orbit_below_L and h_lt_pred_chain).
- **The contradiction when succ reaches L**: If some succ(s^[n](a)).val = L, then L is in limit_dom, and succ(L) must have value > L but also ≤ L (bounded by all pred-chain values converging to L). Contradiction.
- **The Z+Z scenario persists**: If succ maps orbit to orbit indefinitely (all values < L), the orbit is closed under succ — an ω-chain converging to L. Combined with the pred-chain (ω*-chain descending to L), this forms a Z+Z structure that is order-theoretically consistent.
- **Construction-level argument needed**: The Z+Z scenario must be ruled out by arguing that the Burgess omega-chain construction cannot produce such a gap. This requires tracing how points enter limit_dom across construction stages — the hardest part of the proof.

**Confidence**: HIGH that succ_cofinal is true; LOW that the current proof structure can be completed without substantial new infrastructure (200-400 lines of construction-level arguments).

### Alternative Approaches (Teammate B)

Teammate B systematically evaluated 6 alternative routes:

- **LocallyFiniteOrder**: Equivalent to succ_cofinal — circular, not a bypass.
- **IsSuccArchimedean.of_orderIso**: Circular — requires IsSuccArchimedean to construct the order iso.
- **Reynolds pipeline (recommended)**: Bypasses succ_cofinal entirely. ChronicleExtraction.lean already wraps the chronicle into a ChronicleAsPriorModel satisfying Reynolds Corollary 3. The blocking items are in IntegerModel.lean (sum_preservation, very_good, chronicle_is_good).
- **Doets Henkin construction**: Sound but requires complete reimplementation — too costly.
- **WellFoundedGT**: Closed — LimitDomSubtype has NoMaxOrder.
- **Conservative extension (task 129)**: The weak/reflexive approach was attempted and deferred; Reynolds pipeline is the mature alternative.

**Conclusion**: No shortcut exists to IsSuccArchimedean. The Reynolds pipeline is the only non-circular alternative.

### Gaps and Shortcomings (Critic, Teammate C)

Teammate C produced the most consequential finding:

- **CRITICAL: Constant-MCS case is formally excluded by Prior-UZ + truth lemma**. If all limit_dom points share MCS A with φ ∈ A, then F(φ) ∈ A (by seriality + truth lemma for F), so Prior-UZ gives U(φ, ¬φ) ∈ A. But U(φ, ¬φ) requires a C5 witness y with ¬φ ∈ limit_f(y) = A, contradicting φ ∈ A by MCS consistency. This means the constant-MCS model violates the truth lemma for Until, so it cannot arise as the chronicle's limit domain.
- **Docstring proof strategy (lines 1540-1557) is circular**: The "first limit_dom point z at or above L" argument assumes the conclusion.
- **Non-constant case still hard**: Even with a discriminating formula, backward_G requires φ at ALL future points — but pred-chain φ-status is unknown.
- **Prior-SZ on the pred-chain minimum**: A potentially promising new approach — if the pred-chain converges to some M, applying Prior-SZ at the first pred-chain element above M should force its predecessor to be connected to the orbit.

### Strategic Horizons (Teammate D)

- **Reynolds is the expected literary standard** for integer-time completeness. Doets 1.4 is the cornerstone lemma. A referee would expect this approach.
- **Path B produces less dead code**: Activating Reynolds transforms 3,710 lines of WeakCanonical from secondary to primary. Path A leaves those lines as secondary infrastructure.
- **Dense completeness alignment**: Path B directly develops Doets 1.4, prerequisite for Doets 1.5 (dense case). Path A contributes nothing to future work.
- **Dual proofs have publication value**: Both paths sorry-free would be the first computer-checked BX completeness via two independent methods.
- **Risk-adjusted effort**: Path A (4-8h optimistic, HIGH risk on constant-MCS); Path B (14-25h, moderate risk).

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A | Teammate C | Resolution |
|----------|-----------|-----------|------------|
| Constant-MCS provability | "Genuine gap — Z+Z consistent with all axioms" | "Formally excluded by Prior-UZ + truth lemma" | **Teammate C is correct on exclusion but the resolution is nuanced.** Teammate A's Z+Z analysis is valid at the order-theoretic level but fails to account for the truth lemma constraint: `limit_satisfies_c5_strong` combined with Prior-UZ in every MCS formally excludes constant-MCS scenarios. However, Teammate A correctly identifies that EVEN WITH non-constant MCS, the gap scenario persists — the constant-MCS exclusion eliminates one case but does not solve the problem. |
| Approach viability | "Construction-level argument (200-400 lines)" | "Non-constant case still requires controlling all future points" | **Both are correct.** The non-constant case remains hard regardless of constant-MCS exclusion. The construction-level argument is the only viable direct approach, but it's high-effort and high-risk. |

### Gaps Identified

1. **No concrete proof strategy for the non-constant case**: All teammates agree the discriminating formula exists (by Prior-UZ exclusion of constant-MCS) but none produce a working proof sketch that controls φ at pred-chain points.
2. **Construction internals unexplored**: The omega-chain's counterexample resolution mechanism (PointInsertion.lean, CounterexampleElimination.lean) has not been analyzed for succ_cofinal implications. This is where the Z+Z impossibility argument must live.
3. **Prior-SZ approach unverified**: Teammate C proposes applying Prior-SZ to the pred-chain's infimum region. This needs formal investigation — it could connect the orbit to the pred-chain.
4. **M = L proof needs formalization**: Teammate A's argument that pred-chain infimum equals orbit limit is mathematically sound but requires careful Lean formalization using BddBelow + strictMono + Rat density.

### Recommendations

1. **Primary path**: Pursue tasks 154→155 (Reynolds pipeline) as the main route to sorry-free `bx_completeness`.
2. **Secondary path**: Attempt task 153 (succ_cofinal) in parallel, focused on:
   - Phase 1: Formalize constant-MCS exclusion via Prior-UZ (the C-finding — moderate difficulty, high confidence)
   - Phase 2: Formalize M = L (pred-chain converges to orbit limit — moderate difficulty)
   - Phase 3: Attempt the non-constant case via Prior-SZ or construction-level argument
   - **Stopping rule**: If Phase 3 does not yield results within one implementation cycle, deprioritize task 153.
3. **Update task 153 description**: Note that constant-MCS is excluded (reducing the problem scope) and that the Reynolds pipeline is the primary strategic path.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary approach | completed | medium | M = L proof, Z+Z analysis, construction-level argument assessment |
| B | Alternatives | completed | high | All alternatives circular; Reynolds is only non-circular bypass |
| C | Critic | completed | high | **Constant-MCS exclusion via Prior-UZ** (breakthrough finding) |
| D | Horizons | completed | high | Strategic assessment: Path B primary, Path A secondary with stopping rule |

## Final Recommendation

**succ_cofinal is mathematically true but remains hard to prove directly.** The constant-MCS case is excluded (Teammate C's finding), narrowing the problem to the non-constant case. But the non-constant case still requires either (a) a construction-level argument showing the omega-chain cannot produce Z+Z gaps, or (b) a novel temporal logic argument controlling formula truth across the gap.

**The Reynolds pipeline (tasks 154→155) is the recommended primary path.** It is more standard, lower-risk, and advances adjacent goals. Task 153 should be pursued in parallel with a hard stopping rule: formalize the constant-MCS exclusion and M = L proof (valuable regardless), then attempt the non-constant case with a fixed budget. If it doesn't yield, accept that the chronicle discrete path carries a sorry and the Reynolds path is the primary completeness proof.

## References

- Burgess 1982: "Axioms for Tense Logic" — the BX axiom system and chronicle construction
- Doets 1987: "Completeness and Definability" thesis — Claim 10 (maximum principle), Lemma 1.4 (sum preservation)
- Doets 1989: "Monadic Π₁¹-Theories" — Lemma 1.1 (normal forms), Lemma 1.4
- Reynolds 1994: "Axiomatising U and S over integer time" — Theorem 15, Corollary 3, Lemmas 6-10 (gap elimination)
- ChronicleToCountermodel.lean: lines 1559-1885 (succ_cofinal proof with sorry)
- ChronicleConstruction.lean: omega-chain construction, limit_dom, limit_f
- WeakCanonical/Transfer.lean: Reynolds pipeline architecture (steps 1-6)
