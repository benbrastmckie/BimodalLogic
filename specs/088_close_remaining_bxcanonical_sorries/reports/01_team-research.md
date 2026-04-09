# Team Research Report: Task #88 — Close Remaining BXCanonical Sorries

**Task**: 88 — Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Mode**: Team Research (4 teammates, all opus)
**Session**: sess_1775761829_9fc245

## Summary

All four teammates converge on a single diagnosis: **the BX axiom system is incomplete for linear time**. The removed `temp_linearity` axiom (or equivalently `F(phi) <-> top U phi`) is necessary for completeness, and its removal during the BX refactoring was a mathematical error. Two viable paths forward are identified, with a clear primary recommendation and a well-characterized alternative.

## Key Findings

### 1. Root Cause: Missing Axiom(s) (ALL TEAMMATES AGREE, 95% confidence)

The BX axiom system lacks two axioms present in every standard completeness proof for Until/Since temporal logic:

| Missing Axiom | Effect | Status |
|--------------|--------|--------|
| `temp_linearity`: `F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)` | Forces bx_le to be a linear order | Was in system, removed in BX refactoring |
| `F_until_equiv`: `F(φ) → ⊤ U φ` | Bridges F/P reasoning with Until/Since reasoning | Was in system, removed in BX refactoring |

**Evidence chain** (Critic, Teammate C):
- `LinearityDerivedFacts.lean` contains an explicit 3-point counterexample proving `temp_linearity` is NOT derivable from BX1-BX10
- `Soundness.lean:285` proves `temp_linearity_valid` sorry-free (the axiom IS semantically valid)
- `DovetailedChain.lean:572` and `FiniteDeferral.lean:48` have sorry markers reading "F_until_equiv removed in BX"
- 40+ research rounds across tasks 83-88 all fail at the same wall
- The standard literature (Burgess 1982, Xu 1988, Venema 1993) all include these axioms

**BX7 does NOT subsume temp_linearity**: BX7 (linearity of Until) constrains Until-witness ordering *within* a single MCS. temp_linearity constrains the temporal ordering *between* MCS pairs. These are fundamentally different structural properties.

### 2. The 6 Sorries Decompose Into Three Independent Problems (Teammate A)

| Problem | Files | Count | Core Issue | Blocked By |
|---------|-------|-------|------------|------------|
| A: Until/Since eventuality | Frame.lean | 4 | Guard requires bx_le linearity | Missing temp_linearity |
| B: imp Case B | CanonicalEmbedding.lean | 1 | Constant histories collapse G/H | Missing non-constant chain |
| C: Model embedding | Completeness.lean | 1 | Depends on A+B | Downstream |

Problem A is the hardest. Problem B is orthogonal but also needs non-constant histories (which require linearity to construct). Problem C closes automatically when A+B are resolved.

### 3. Two Viable Paths Forward

#### Path 1: Re-add temp_linearity + F_until_equiv as Axioms (HIGH confidence, 8-16 hours)

**Champions**: Teammates A and C.

Add `temp_linearity` and `F_until_equiv` (or just one — they may be inter-derivable given the other BX axioms) back to the `Axiom` inductive type. This is:
- **Sound**: `temp_linearity_valid` already proved sorry-free in `Soundness.lean`
- **Conservative**: Does not change which formulas are valid (both are semantic tautologies)
- **Standard**: Every known completeness proof for Until/Since includes these axioms
- **A bug fix**: The removal was based on incorrect reasoning that BX7 subsumes temp_linearity

**Cascade effect**:
1. bx_le becomes provably linear → closes 4 Frame.lean sorries
2. Non-constant chain histories become constructible → closes CanonicalEmbedding sorry
3. Full truth lemma established → closes Completeness sorry

**Implementation**:
- Add 1-2 new constructors to `Axiom` in `Axioms.lean`
- Prove soundness (straightforward — pattern already exists)
- Derive bx_le linearity from BX7 + F_until_equiv
- Close sorries using standard canonical model techniques

#### Path 2: Clean Chain Construction (MEDIUM confidence 55-65%, 20-40 hours)

**Champions**: Teammates B and D.

Build a new chain-specific canonical model that avoids needing global bx_le linearity by constructing a linear chain where linearity holds by construction.

**Key enabling discovery** (Teammate B): The **multi-target Until seed** `g_content(w) ∪ {φ₁ U ψ₁, ..., φₖ U ψₖ}` IS consistent (proved via g_content_closed_derivation + BX1 + MCS disjunction). This is fundamentally different from the invalid combined F-seed (which was mathematically false).

**Architecture**:
- New module `CanonicalChain.lean`: Int-indexed chain of BXPoints with dovetailed eventuality resolution
- New module `ChainTruthLemma.lean`: Truth lemma by structural induction for chain points only
- Modified `Completeness.lean`: Use chain model instead of global canonical model

**Critical caveat** (Teammate B's deep analysis): The **backward Until truth lemma on chains** remains genuinely hard. The forward direction (membership implies truth) works by construction. But the backward direction (truth implies membership) requires showing that if φ U ψ is semantically true on the chain, then φ U ψ ∈ chain(n) — which appears to need either linearity or a novel argument. Teammate B's 300-line analysis explores multiple sub-approaches and finds the standard truth lemma requires the full bidirectional IFF with no shortcut.

**This path would bypass Frame.lean sorries** (they remain sorry'd but become dead code) while closing Completeness.lean and CanonicalEmbedding.lean.

### 4. Strategic Assessment (Teammate D)

- **The BXCanonical architecture is fundamentally the wrong architecture for Until/Since**: It uses a global canonical frame with non-linear ordering, but the standard representation theorem requires a constructed linear chain. This explains all 11+ dead ends.
- **Tasks 87 and 88 are the same mathematical problem** approached from different starting points. A clean chain construction serves both.
- **No prior Lean/Coq/Isabelle formalizations of Until/Since temporal logic completeness exist**. This project would be a first if completed.
- **Two-track strategy recommended**: Track 1 (short-term): close CanonicalEmbedding sorry for USF completeness. Track 2 (long-term): full representation theorem via chain construction.

## Synthesis

### Conflicts Found and Resolved

| Conflict | Teammate A | Teammates B/D | Resolution |
|----------|-----------|---------------|------------|
| Primary approach | Add axioms (8-16h) | Chain construction (20-40h) | **Both viable; axiom approach is faster and higher confidence** |
| Frame.lean sorries | Close via linearity | Bypass as dead code | **Axiom approach closes them; chain approach bypasses them** |
| temp_linearity vs F_until_equiv | Prefers F_until_equiv | Acknowledges both needed | **Need to determine if one suffices or both needed** |
| Philosophical acceptability | "Bug fix, not design change" | "Needs fundamentally new architecture" | **User directive says "no compromises" — suggests adding axioms if needed** |

### Key Agreement Points

1. **All four teammates agree** the BX axiom system is incomplete for linear time (95% confidence)
2. **All four teammates agree** incremental patching is exhausted after 40+ rounds
3. **All four teammates agree** the 4 Frame.lean sorries require temp_linearity or equivalent
4. **Three of four teammates** (A, C, D) identify adding axioms as the correct mathematical solution
5. **Teammate B** provides the strongest alternative (chain construction with Until-enriched seeds) but acknowledges backward Until difficulty

### Gaps Identified

1. **Are temp_linearity and F_until_equiv independent?** Could adding just one suffice? Need to check if temp_linearity is derivable from BX + F_until_equiv or vice versa.
2. **Backward Until truth lemma on chains**: Teammate B's deep analysis shows this remains hard even with Until-enriched seeds. The chain approach may still need temp_linearity for this direction.
3. **Impact on existing infrastructure**: Adding axioms requires updating all Axiom pattern matches (soundness, etc.). The scope of code changes beyond the sorry sites needs assessment.
4. **USF completeness (CanonicalEmbedding:418)**: Teammates C and D suggest this may be closable independently with a proof-theoretic approach (60% confidence), before the full Until/Since story is resolved.

## Recommendations

### Primary Recommendation: Path 1 — Re-add temp_linearity as an Axiom

This is the mathematically correct solution. The removal was an error (the codebase itself documents that temp_linearity is NOT derivable from BX axioms, contradicting the premise of its removal). Re-adding it:
- Fixes the axiom system to match the standard Burgess-Xu system
- Unblocks all 6 sorries through established mathematical technique
- Is the fastest path (8-16 hours)
- Highest confidence (HIGH)
- Aligns with user directive: "no compromises in establishing a standard representation theorem"

### Secondary Recommendation: Path 2 — Chain Construction (if axiom addition is rejected)

If the project maintainer philosophically rejects adding axioms, the chain construction with Until-enriched seeds is the most viable alternative. But it requires 20-40 hours and has a known hard spot (backward Until truth lemma, 55-65% confidence).

### Quick Win: Close CanonicalEmbedding:418 Independently

Regardless of which path is chosen for the 4 Frame.lean sorries, investigate closing the USF completeness sorry via proof-theoretic approach (4-8 hours, 60% confidence). This gives a publishable result (sorry-free USF completeness) while the full representation theorem is pursued.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary approach | completed | HIGH | Identified F_until_equiv as root cause; concrete axiom addition plan |
| B | Alternatives | completed | MEDIUM-HIGH | Until-enriched seed consistency proof; deep backward Until analysis |
| C | Critic | completed | HIGH (95%) | Definitive diagnosis: axiom system incomplete; 3-point counterexample |
| D | Horizons | completed | MEDIUM-HIGH | Clean-sheet design; two-track strategy; literature survey |

## References

- Burgess, J.P. (1982). "Axioms for tense logic I: Since and until." Notre Dame J. Formal Logic 23(4).
- Xu, M. (1988). Simplification of Burgess's axiomatization for reflexive linear orders.
- Venema, Y. (1993). "Derivation rules as anti-axioms in modal logic." JSL 58(3).
- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects." OUP.
- Goldblatt, R. (1992). "Logics of Time and Computation." CSLI.
- Stanford Encyclopedia of Philosophy, "Temporal Logic" supplement on Burgess-Xu axiom system.
- `LinearityDerivedFacts.lean` — counterexample proving temp_linearity underivable from BX
- `Soundness.lean:285` — sorry-free proof of temp_linearity semantic validity
