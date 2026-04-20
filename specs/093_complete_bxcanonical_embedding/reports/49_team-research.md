# Research Report: Task #93 - Sorry Closure Strategy (Post-Irreflexive Switch)

**Task**: 93 - Complete BXCanonical Embedding
**Date**: 2026-04-20
**Mode**: Team Research (4 teammates)
**Session**: sess_1776695919_9ccc81

## Summary

Four teammates rigorously analyzed the Phase 4 blocker (Lindenbaum non-determinism preventing finite descent on active_defects). A CRITICAL finding emerged: the implementation may have broken soundness of the axiom system. The recommended path forward has two prerequisite steps before any sorry closure can be attempted.

## Critical Finding: Potential Soundness Break

**Teammate C identified** that Soundness.lean contains sorry'd proofs with comments stating axioms are "NOT directly semantically valid under irreflexive semantics with open guard." Specifically:
- `until_step` (BX8 replacement)
- `until_elim` (BX9)
- `serial_future`, `serial_past`

**Root cause analysis**: The plan specified **A2 guard convention = half-open [t, s)** which DOES validate BX9 (since the guard includes t, ensuring phi(t) ∨ psi(t)). However, the implementation comments reference **open guard (t, s)** which does NOT validate BX9 (since t is excluded from the guard).

**Resolution required**: Either (a) the Truth.lean Until semantics actually uses half-open [t, s) and the soundness proofs simply weren't completed (engineering debt), or (b) the implementation accidentally used open (t, s) which breaks BX9. This must be verified before any further work.

## Key Findings

### Primary Approach: Constrained Lindenbaum (Teammates A, B, D)

**The Mathematical Principle** (agreed by all teammates):
- Under irreflexive semantics, `phi -> F(phi)` is not derivable
- By the deduction theorem: if `F(phi)` is not derivable from seed S, then `S union {neg(F(phi))}` is consistent
- A standard Lindenbaum extension of `S union {neg(F(phi))}` gives an MCS that excludes `F(phi)`

**Disagreement on feasibility**:

| Teammate | Assessment | Key Concern |
|----------|-----------|-------------|
| A | LOW confidence | `G(neg phi)` inconsistent with `g_content(M)` when `G(phi) in M` |
| B | MEDIUM-HIGH (75%) | Claims independent exclusions don't interact |
| C | FAILS in general | Same concern as A: G(phi) and G(neg phi) coexist |
| D | 65% confidence | Multi-exclusion interaction is the risk |

**Conflict analysis**: Teammates A and C raise the same objection -- if `G(phi)` is in `M`, then `G(phi)` is in `g_content(M)`, and adding `G(neg phi)` creates `{G(phi), G(neg phi)}` which derives `G(bot)`, contradicting `serial_future`.

**Critical distinction (resolving the conflict)**: The constrained Lindenbaum approach does NOT add `G(neg phi)` to the seed. It adds `neg(F(phi))`. Under irreflexive semantics:
- `neg(F(phi)) = G(neg phi)` -- these ARE the same formula
- So the objection is valid: if `G(phi) in g_content(M)`, adding `G(neg phi) = neg(F(phi))` to the seed creates inconsistency

**However**, there is a subtlety: `g_content(M) = {psi | G(psi) in M}`. So `G(phi) in g_content(M)` iff `G(G(phi)) in M`. Under irreflexive semantics with `temp_4` (G(phi) -> G(G(phi))), if `G(phi) in M` then `G(G(phi)) in M`, so indeed `G(phi) in g_content(M)`.

But wait: `phi in g_content(M)` iff `G(phi) in M`. The seed contains g_content(M). Does it contain `phi` (the resolved formula) via g_content? Only if `G(phi) in M`. And adding `neg(F(phi)) = G(neg phi)` to a seed containing `phi` (from g_content) means the seed has both `phi` and `G(neg phi)`. Under irreflexive semantics, this IS consistent (phi holds now, neg phi holds at strict future). The issue is whether the seed ALSO contains `G(phi)` (from g_content).

**Final verdict on constrained Lindenbaum**: It works UNLESS `G(phi) in M` (equivalently, `G(G(phi)) in M`). This is not guaranteed to hold for arbitrary M. So the approach works in many cases but NOT universally.

### Alternative Approaches (Teammate B)

| Approach | Status | Reason |
|----------|--------|--------|
| Oracle Chain (B) | REJECTED | Archived in Boneyard, hits same defect-count blocker + backward step transfer invalid |
| Semantic Argument (C) | REJECTED | Circular (cannot assume completeness to prove countermodel) |
| Weakened Coherence (D) | REJECTED | Already at minimum for truth lemma |

### Strategic Assessment (Teammate D)

- Constrained Lindenbaum: 65% success, 200-300 LOC
- Semantic rewrite (quasimodel embedding): 75% success, 500-800 LOC
- Current approach unchanged: 0% (fundamentally blocked)
- Do NOT revert irreflexive switch (still valuable)
- Do NOT abandon 5,791-line infrastructure

### Codebase Health (Teammate C)

- Sorry count expanded from ~5 to ~80+ across Metalogic/
- Critical modules (Soundness.lean, CanonicalModel.lean, Frame.lean) have new sorries
- The "builds with 0 errors" is misleading -- sorry is accepted by the kernel
- g_content_subset_self is sorry'd (genuinely false under irreflexive semantics -- G(phi) -> phi no longer holds)

## Synthesis

### Conflicts Resolved

1. **Constrained Lindenbaum feasibility**: A and C are correct that it fails when G(phi) in M. B's optimism is partially warranted but the "independent exclusions" claim doesn't account for g_content propagation of G-formulas. **Verdict: NOT universally applicable.**

2. **Revert vs. keep irreflexive**: C's soundness concern is the most critical. If the guard convention in Truth.lean is wrong (open vs. half-open), the entire axiom system is unsound. However, if it's correctly half-open [t, s), then BX9 IS valid and the soundness proofs are just incomplete (engineering debt). **Verdict: Verify guard convention in Truth.lean first.**

3. **Architecture assessment**: All teammates agree the Lindenbaum chain approach has a fundamental tension with temporal coherence. The disagreement is only about whether constrained Lindenbaum can resolve it. The consensus is: constrained Lindenbaum may work but has a known failure case (G(phi) in M).

### Gaps Identified

1. **Guard convention verification**: What does Truth.lean ACTUALLY implement? Half-open [t, s) or open (t, s)? This determines soundness.
2. **G(phi) frequency**: How often does G(phi) appear in chain MCS for phi in sigma_list? If never (or provably never for resolved formulas), constrained Lindenbaum works.
3. **Semantic rewrite path**: Nobody fully analyzed whether the existing quasimodel infrastructure can bridge to Int-indexed chains. This is the fallback and needs deeper study.
4. **BX5 availability**: Teammate B's Until coherence path depends on BX5 having the form `phi /\ F(phi U psi) -> phi U psi`. Not verified.

### Recommendations (Priority Order)

**Step 0 (PREREQUISITE)**: Verify soundness. Read Truth.lean's Until/Since definitions and confirm the guard convention. If open (t, s): fix to half-open [t, s). If half-open [t, s): complete the soundness proofs (they may just be engineering debt from the rushed Phase 1).

**Step 1**: After soundness is confirmed, determine if constrained Lindenbaum is viable:
- Check: does the chain construction ever produce M where G(phi) in M for phi being a resolved defect?
- If yes: constrained Lindenbaum fails for that case
- If no (or if we can prove it): proceed with constrained Lindenbaum (~300 LOC)

**Step 2 (fallback)**: If constrained Lindenbaum is blocked, pursue semantic rewrite:
- Use quasimodel infrastructure to produce witnesses
- Embed quasimodel chains into Int-indexed positions
- ~500-800 LOC

**Step 3 (nuclear option)**: If both fail, consider a Reynolds-style step-by-step construction replacing the entire RootScopedChain.lean approach. ~2000 LOC.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Constrained Lindenbaum deep analysis | completed | LOW (approach has fundamental flaw) |
| B | Alternative approaches + literature | completed | MEDIUM-HIGH (constrained Lindenbaum viable) |
| C | Critic - soundness break + failure patterns | completed | HIGH (95% current approach blocked) |
| D | Strategic horizons + minimum viable path | completed | MEDIUM (65% constrained Lindenbaum) |

## Key Takeaways

1. **SOUNDNESS FIRST**: Before ANY sorry closure work, verify the guard convention in Truth.lean and ensure the axiom system is sound for the chosen semantics.

2. **Constrained Lindenbaum is NOT universally applicable** but MAY work if we can show G(phi) does not appear in M for resolved defects phi. This needs investigation.

3. **The Lindenbaum-coherence tension is irreducible** -- after 48 rounds, the evidence is overwhelming that unconstrained Lindenbaum cannot prove temporal coherence. ANY solution must either constrain Lindenbaum or avoid it.

4. **The quasimodel infrastructure is the strategic fallback** -- 2,289 sorry-free lines that already solve Until/Since coherence in the abstract. Bridging to Int-indexed chains is the remaining gap.

5. **Do NOT abandon the 5,791-line sorry-free infrastructure** (Teammate D). The BXCanonical approach is architecturally sound; only the chain construction step needs replacement.
