# Research Report: Task #88 -- Teammate C (Critic) Findings

**Task**: 88 -- Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Critic -- architectural soundness analysis
**Focus**: Determine whether the problems are solvable within the current architecture

## Key Findings

### Finding 1: The BX Axiom System Is INCOMPLETE for Linear Time (HIGH CONFIDENCE: 95%)

This is the root cause of all failures across tasks 83-88. The BX axiom system lacks two critical axioms that are present in the standard Burgess-Xu completeness proofs for Until/Since on linear orders:

**Missing Axiom A: temp_linearity** (`F(phi) & F(psi) -> F(phi & psi) | F(phi & F(psi)) | F(F(phi) & psi)`)

This axiom was explicitly present in the original TM system (`LinearityDerivedFacts.lean` documents it was added as `temp_l`), then **deliberately removed** during the BX refactoring on the theory that BX7 (linearity of Until) would subsume it. The file itself documents:

> **Theorem (informal)**: The linearity schema [...] is NOT derivable from the base TM axioms

A concrete counterexample is given: a 3-point frame {0, 1a, 1b} where 0 sees both 1a and 1b but 1a and 1b are temporally incomparable. This frame satisfies all BX axioms but violates temp_linearity.

**Missing Axiom B: F(phi) <-> (top U phi)** (or equivalently `F(top) -> bot U top`)

The SEP supplement on the Burgess-Xu system explicitly lists `F(top) -> bot U top` as an axiom added for completeness on discrete linear orderings. This axiom bridges the gap between F/P-based reasoning (which controls the g_content ordering) and Until/Since-based reasoning (which controls eventuality resolution). The BX system has BX10 (`phi U psi -> F(psi)`) going one direction but NOT the reverse `F(psi) -> top U psi`.

**Evidence chain**:
1. `LinearityDerivedFacts.lean` proves temp_linearity is NOT derivable from BX axioms
2. The 3-point counterexample is explicit and verified
3. `Soundness.lean:285` proves temp_linearity IS semantically valid (`temp_linearity_valid`)
4. Report 08 proves global bx_le linearity is false without temp_linearity
5. All 4 Frame.lean sorries require bx_le linearity (or equivalent)
6. The SEP/Burgess-Xu literature confirms these axioms are needed for completeness

**The BX axiom system as currently formalized is sound but incomplete for linear time.** BX7 does NOT subsume temp_linearity. The removal was a mathematical error.

### Finding 2: The 4 Frame.lean Sorries Are Unsolvable Without Additional Axioms (95% Confidence)

The sorry signatures are:

```lean
-- Forward Until eventuality resolution
bx_until_eventuality_resolution : phi U psi in w, psi not-in w ->
  exists v >= w, psi in v, forall u in [w,v), phi in u

-- Backward Until
bx_until_backward : w <= v, psi in v, guard on [w,v), psi not-in w ->
  phi U psi in w

-- Forward Since (mirror)
-- Backward Since (mirror)
```

These require showing that **all** BXPoints between w and v in the bx_le ordering satisfy the guard condition phi. This requires bx_le to be a total (linear) order on intervals, which requires temp_linearity, which is absent from the axiom system.

**The lemma statements themselves are correct** -- they ARE what a completeness proof needs. But they cannot be proved from the current axioms because bx_le (defined as g_content inclusion) is a preorder that is NOT linear. Without linearity, arbitrary BXPoints u with `bx_le w u` and `bx_le u v` can exist that are incomparable with each other, and no axiom forces phi into such points.

### Finding 3: The CanonicalEmbedding.lean Sorry (imp Case B) Is a DIFFERENT Problem (90% Confidence)

The sorry at `usf_completeness` line 418 (imp Case B) is:
```
Given: psi -> chi valid, psi not valid, (psi -> chi) not derivable
Need: contradiction
```

The proof strategy constructs an MCS w with psi in w, chi not-in w, and tries to show validity of `psi -> chi` is violated. On constant histories, `truth_at G(alpha) = truth_at alpha`, so G/H inside chi collapse and the backward truth bridge gives `flatten(chi) in w` rather than `chi in w`.

This is NOT about bx_le linearity. It is about the **constant-history collapse** of temporal operators. The fix requires non-constant histories (a chain of distinct BXPoints), which in turn requires... bx_le linearity to construct properly.

**However**, there may be a proof-theoretic workaround that avoids semantic countermodels entirely. Report 07 identified two untested approaches:
1. USF normal form reduction (45% confidence)
2. Direct proof-theoretic Case B (60% confidence)

Neither has been attempted. The proof-theoretic approach would use BX axioms to derive `psi -> chi` directly without building a countermodel, bypassing the branching-vs-linear mismatch entirely.

### Finding 4: The Completeness.lean Sorry Is Downstream (100% Confidence)

The sorry in `bx_completeness` (line 160) is simply the top-level sorry that delegates to the canonical model construction. Once either:
- The Frame.lean sorries + CanonicalEmbedding sorry are closed (full truth lemma), OR
- An alternative completeness proof path is established

...this sorry closes automatically. It has no independent mathematical content.

### Finding 5: Pattern Analysis of 11+ Dead Ends -- Common Root Cause

Every failed approach across tasks 83-88 ultimately hits one of two walls:

**Wall 1: bx_le is not linear** (blocks Frame.lean sorries)
- Dovetailed chain approaches: cannot show guard for off-chain points
- Until-induction: removed axiom, not derivable from BX
- Combined F-seed: G does not distribute over disjunction
- Enriched seed: Lindenbaum can introduce G(neg psi), killing F(psi)

**Wall 2: constant histories collapse G/H** (blocks CanonicalEmbedding sorry)
- Constant-history truth lemma: G(alpha) = alpha semantically
- Flatten reduction: alpha does not imply G(alpha)
- Two-point model: same seed problem as chains

Both walls trace back to the same root: **the BX axiom system cannot establish that the canonical temporal ordering is linear**. In the standard Burgess-Xu approach, temp_linearity (or equivalently, Until-induction) provides this. It was removed and nothing equivalent was added.

### Finding 6: The Axiom System Itself -- What Is Missing

Reading `Axioms.lean` carefully, the BX system has 33 constructors. Comparing with the standard Burgess-Xu system from the literature:

**Present and correct**: BX1-BX10, BX1'-BX10' (temporal), S5 modal, interaction axioms.

**Missing**:
1. `temp_linearity`: `F(phi) & F(psi) -> F(phi & psi) | F(phi & F(psi)) | F(F(phi) & psi)`
2. `F_implies_until`: `F(phi) -> top U phi` (or the weaker `F(top) -> bot U top`)

The first is needed for bx_le linearity. The second bridges F/P reasoning with Until/Since reasoning. Both are sound (provably valid on all linear orders).

BX7 (linearity of Until) is NOT a substitute for temp_linearity. BX7 says "if two Until formulas hold at the same point, their witnesses are linearly ordered." This constrains Until-witness ordering within a SINGLE MCS. temp_linearity says "if two eventualities exist, they are ordered." This constrains the temporal ordering BETWEEN MCS. These are fundamentally different structural properties.

## Verdict

**The BX axiom system is incomplete for linear time. The 6 sorries are unsolvable within the current axiom system.**

Specific classification:

| Sorry | Classification | Required Fix |
|-------|---------------|--------------|
| Frame.lean x 4 (eventuality) | **Axiom system insufficient** | Add temp_linearity |
| CanonicalEmbedding.lean x 1 (imp Case B) | **Solvable with changes** | Either add temp_linearity OR find proof-theoretic bypass |
| Completeness.lean x 1 (top-level) | **Downstream** | Closes when others close |

### Recommended Path Forward

**Option A: Re-add temp_linearity (HIGH CONFIDENCE, 2-4 hours)**

Add temp_linearity back to the Axiom inductive type. It was there before, was removed in BX refactoring based on incorrect belief that BX7 subsumes it, and soundness is already proven. This is not "adding a new axiom" -- it is **correcting an error in the BX refactoring**.

Impact:
- bx_le becomes provably linear (from temp_linearity, F-witnesses are linearly ordered, and this propagates to g_content inclusion)
- All 4 Frame.lean sorries become solvable via standard canonical model arguments
- CanonicalEmbedding sorry becomes solvable via non-constant chain histories
- Completeness.lean sorry closes downstream

Cost: ~35 constructor in Axiom type, ~50-100 LOC for linearity proofs, plus fixing match exhaustiveness in soundness and other axiom-handling code.

**Option B: Prove F(phi) <-> top U phi from BX axioms (LOW CONFIDENCE, speculative)**

If this equivalence can be derived from BX1-BX10, it would bridge the gap without adding temp_linearity explicitly. However, report 08 assesses this as "almost certainly impossible" and no attempt has succeeded.

**Option C: Proof-theoretic bypass for CanonicalEmbedding only (MEDIUM CONFIDENCE, 4-8 hours)**

Attempt the proof-theoretic Case B approach (report 07, Finding 8) to close just the CanonicalEmbedding sorry without fixing Frame.lean. This gives USF fragment completeness while leaving full completeness open.

**Option D: Accept fragment completeness as the achievable result (pragmatic)**

The sorry-free `fragment_completeness` (temporal-free fragment) and `usf_completeness` (minus one sorry) already represent significant results. Document the axiom incompleteness as a known limitation and close the task.

### Recommendation

**Option A is the correct mathematical solution.** The BX refactoring removed temp_linearity based on incorrect reasoning. This should be treated as a bug fix, not a design change. The axiom is sound, standard in the literature, and necessary for completeness. Every approach that has been tried for 40+ research rounds has failed precisely because this axiom is missing.

If Option A is philosophically unacceptable (the project maintainer wants a minimal axiom set), then **Option C + Option D** is the pragmatic fallback: close what can be closed proof-theoretically, document the incompleteness, and move on.

## Evidence/Examples

### Evidence 1: Concrete counterexample to bx_le linearity (from LinearityDerivedFacts.lean)

Frame: {0, 1a, 1b} with 0 < 1a, 0 < 1b, but 1a and 1b incomparable.
- Satisfies all BX axioms (including BX7)
- Violates temp_linearity
- Produces two MCS w_1a, w_1b where neither `bx_le w_1a w_1b` nor `bx_le w_1b w_1a`

### Evidence 2: Soundness of temp_linearity (from Soundness.lean:285)

```lean
theorem temp_linearity_valid (phi psi : Formula) :
    valid (Formula.and (Formula.some_future phi) (Formula.some_future psi) |>.imp
      (Formula.or (Formula.some_future (Formula.and phi psi))
        (Formula.or (Formula.some_future (Formula.and phi (Formula.some_future psi)))
          (Formula.some_future (Formula.and (Formula.some_future phi) psi)))))
```

This is proved sorry-free. The axiom is valid on ALL linear orders.

### Evidence 3: temp_linearity was previously in the system

`LinearityDerivedFacts.lean:73` has `temp_linearity_derivation` which previously derived from `Axiom.temp_l`, now sorry'd with comment "temp_l removed in BX". The old `FrameConditions/Compatibility.lean:31` still lists `temp_linearity` as a "Linear (Base)" axiom.

### Evidence 4: All alternative approaches fail at the same point

Report 08 Section 7: "Deriving temp_linearity from BX axioms is almost certainly impossible without additional infrastructure."

Report 07: "The fundamental tension: TaskFrame G semantics is LINEAR (future times on one history). MCS G semantics is BRANCHING (all bx_le successors). Embedding branching into linear requires forward_F, which is blocked."

This branching-vs-linear mismatch IS the incompleteness manifesting.

## Confidence Level

**HIGH (95%)** for the diagnosis that the BX axiom system is incomplete.

Evidence:
- The counterexample to temp_linearity derivability is explicit and verified
- Soundness of temp_linearity is proved sorry-free
- 40+ research rounds across 5 tasks all fail at the same point
- The standard literature (Burgess, Xu, Venema) all include temp_linearity or its equivalent
- The removal was documented as "believed impossible to derive" in the codebase itself

The only remaining uncertainty (5%) is whether there exists some completely novel proof technique that avoids needing linearity entirely. No evidence for such a technique has been found in 40+ rounds of research.
