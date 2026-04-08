# Research Report: Task #85 — Until/Since Chain Coherence Approaches

**Task**: 85 — Research Until/Since chain coherence approaches
**Date**: 2026-04-08
**Mode**: Team Research (3 teammates, Opus model)
**Session**: sess_1775682962_1ece6e

## Executive Summary

Three teammates investigated the three proposed directions (restricted deferral closure, simultaneous well-founded induction, quasimodel replacement) plus critical analysis. **Two breakthrough findings fundamentally reframe the problem**:

1. **x_content triviality**: Under BX reflexive Until semantics (BX8: ψ → φ U ψ), the next-step operator X(α) = ⊥ U α is equivalent to α in any MCS. This means x_content(M) = M, making deterministic chains **constant** and rendering all x_content-based chain constructions degenerate. This was independently discovered by Teammates B and C and confirmed by codebase comments.

2. **Burgess-Xu axiom 4 invalidity**: The standard Burgess-Xu axiom 4 (α ∧ χ U ψ → χ U (ψ ∧ χ S α)) is **semantically invalid** under the half-open guard convention used in this system. Task 83 report 35's recommendation to derive it is provably impossible. (Confirmed by Soundness.lean:397-401 comment.)

These findings redirect attention from the Bundle/chain path (~40+ sorries) to the **BXCanonical path** (only 5 sorries) and the **FMP path** (1 trivially fixable sorry).

## Key Findings

### 1. Direction 1 (Restricted Deferral Closure): Does NOT Resolve the Blocker

**Confidence**: HIGH (all teammates agree)

- The truth lemma CAN be weakened to use `restricted_forward_until_since_coherent` quantifying only over `subformulaClosure(root)` — this is a valid refactoring. (Teammate A, Finding 1)
- However, the restriction does NOT reduce proof difficulty. The blocker is proving forward Until coherence for **even one** Until formula, not for too many. (Teammate A, Analysis Step 2-3)
- The restricted chain's `restricted_forward_chain_forward_F` has a hidden sorry at fuel=0 (SuccChainFMCS.lean:3042) with an explicitly unsound termination argument. (Teammate A, Finding 2)
- Under reflexive semantics, the X = id collapse eliminates the primary Until propagation mechanism through seeds. (Teammates A, B, C)

**Verdict**: Direction 1 is a useful refactoring but does not close any sorry sites.

### 2. Direction 2 (Well-Founded Induction): Not Needed for Active Architecture

**Confidence**: HIGH

- **Architecture A** (deterministic chain, Boneyard): The circularity forward_F(ψ) → backward_G(¬ψ) → forward_F(¬¬ψ) is genuine and unbreakable. sizeof(¬¬ψ) = sizeof(ψ) + 4 — the dependency goes **upward** (n → n+4 → n+8 → ...). No formula-complexity measure can break this. (Teammate B, Findings 2-4)
- **Architecture B** (restricted succ-chain, active): ALREADY avoids this circularity for forward_F via fuel-based descent on F-nesting boundaries, independent of backward_G. (Teammate B, Finding 1)
- The remaining sorries in Architecture B are in different categories: BX axiom derivations, fuel exhaustion proofs, forward Until coherence, and removed-axiom re-derivation. (Teammate B, Finding 5)
- Subformula depth does NOT identify ¬¬ψ with ψ in the subformula closure. While DNE holds in MCS (classical logic), no well-founded measure on Formula descends through double negation. (Teammate B, Finding 3)

**Verdict**: Direction 2 is conclusively non-viable for Architecture A, and unnecessary for Architecture B.

### 3. Direction 3 (Quasimodel / Alternative Architectures): Reframed

**Confidence**: MEDIUM-HIGH

Teammate C's critical analysis reframes the landscape:

#### 3a. BXCanonical Path Is Most Promising (5 sorry sites total)

The BXCanonical architecture (Frame.lean, Completeness.lean) has **only 5 sorry sites** — dramatically fewer than the Bundle path's 40+. All 4 Frame.lean sorries reduce to a single mathematical question: **linearity/totality of the bx_le ordering** derivable from BX7.

- `bx_until_eventuality_resolution` (Frame.lean:553)
- `bx_until_backward` (Frame.lean:575)
- `bx_since_eventuality_resolution` (Frame.lean:590)
- `bx_since_backward` (Frame.lean:604)
- `completeness_theorem` (Completeness.lean:144, depends on above)

**Key approach**: If bx_le can be shown to be a total preorder on intervals (any two bx_le-related points above a common ancestor are linearly ordered), the eventuality resolution becomes tractable. BX7 (linearity of Until) should encode this property.

#### 3b. FMP Path Has a Trivially Fixable Sorry

The FMP path (Decidability/FMP/) has **exactly 1 sorry** in TruthPreservation.lean:263: `sorry /- temp_4 removed in BX -/`. But temp_4 IS a BX axiom (Axiom.temp_4). The fix is a one-liner:

```lean
have h_temp_4_thm := DerivationTree.axiom [] _ (Axiom.temp_4 psi)
```

After this fix, the FMP path is sorry-free in its core logic. The remaining gap is bridging from FMP to full completeness (filtered model → TaskModel).

#### 3c. Standard Quasimodel Blocked by Linearization + x_content Triviality

Under reflexive semantics, x_content(M) = M makes the deterministic chain constant. Any hybrid chain approach (deterministic + detours) degenerates because there is no non-trivial successor linkage. The quasimodel's eliminative fixpoint approach is blocked by the same deterministic type graph limitation (identified in task 83 report 30).

### 4. Critical Gap: x_content(M) = M Under Reflexive Semantics

**Confidence**: HIGH (confirmed by Teammates B and C, corroborated by UntilSinceCoherence.lean:33-34 docstring)

Under BX reflexive Until semantics:
- BX8: `ψ → φ U ψ` (reflexive Until introduction, witness s = t)
- BX9: `φ U ψ → φ ∨ ψ` (Until elimination)
- Combining for X: `⊥ U α → ⊥ ∨ α → α` (BX9) and `α → ⊥ U α` (BX8 with φ = ⊥)
- Therefore X(α) = ⊥ U α ↔ α in any MCS

This means:
1. x_content(M) = {α | X(α) ∈ M} = {α | α ∈ M} = M
2. Deterministic chains are constant: chain(n) = chain(0) for all n
3. The entire x_content/y_content machinery is degenerate
4. Architecture A (Boneyard) is built on a degenerate construction

The UntilSinceCoherence.lean docstring at lines 33-34 confirms: "Under BX reflexive semantics, x_content(M) = M (since X(alpha) <-> alpha), so the deterministic chain is constant."

### 5. Burgess-Xu Axiom 4 Is Semantically Invalid in This System

**Confidence**: HIGH (Teammate C, confirmed by Soundness.lean:397-401)

The standard Burgess-Xu axiom 4: `α ∧ χ U ψ → χ U (ψ ∧ χ S α)` is invalid under the half-open guard convention [t, s) / (s, t] used in Truth.lean. At the Until witness s, χ(s) is NOT guaranteed by the Until guard (which only requires χ on [t, s), excluding s). But the Since formula χ S α at s requires χ(s). This makes the axiom semantically false.

**Impact**: Task 83 report 35's Option A (derive Burgess-Xu 4 from BX axioms) is provably impossible. This is the most critical gap identified in 43 prior research rounds.

### 6. F_until_equiv Is NOT Trivially Derivable

**Confidence**: MEDIUM-HIGH (Teammate C)

- Forward: `⊤ U ψ → F(ψ)` is BX10 (available).
- Backward: `F(ψ) → ⊤ U ψ` requires converting "∃ s ≥ t, ψ(s)" to "∃ s ≥ t, ψ(s) ∧ ⊤ on [t,s)". The guard (⊤) is trivially satisfied, so semantically these are equivalent. But proof-theoretically, BX8 only gives the reflexive case `ψ → ⊤ U ψ` (witness at t itself), not the strict case.
- The BXCanonical path works directly with F and does NOT need F_until_equiv, which is an argument in its favor.

## Synthesis

### Conflicts Resolved

#### Conflict 1: Recommended Primary Direction

| Teammate | Recommendation |
|----------|---------------|
| A | Quasimodel (Direction 3) as only non-invalidated approach |
| B | Investigate reflexive/strict tension first, then Architecture B |
| C | BXCanonical + BX7 linearity as most promising |

**Resolution**: Teammates A and C both point away from chain constructions toward the canonical model approach. C's BXCanonical recommendation is more specific than A's quasimodel recommendation and has a concrete attack vector (BX7 linearity → bx_le totality). B's concern about reflexive/strict tension is important context but not a blocker for BXCanonical (which works with the reflexive semantics as-is). **Adopt C's recommendation: BXCanonical + BX7 linearity** as primary, with FMP as secondary.

#### Conflict 2: x_content Triviality Impact

| Teammate | Assessment |
|----------|-----------|
| A | Notes reflexive X = id as propagation blocker for Direction 1 |
| B | Raises as potential fundamental issue; derives X(α) = α rigorously |
| C | Confirms and notes it makes deterministic chains constant |

**Resolution**: All three agree on the fact. The impact is that ALL chain-based approaches relying on x_content/y_content are degenerate under reflexive semantics. Architecture B (SuccChainFMCS) uses f_content/g_content instead of x_content, so it is NOT affected by this triviality — but it faces its own separate sorries. BXCanonical avoids chain construction entirely.

#### Conflict 3: Role of Forward Until Coherence

| Teammate | Assessment |
|----------|-----------|
| A | Forward Until coherence blocked by same fundamentals as forward_F |
| B | Forward Until coherence blocked; backward step transfer also blocked |
| C | BXCanonical reframes the question: Until coherence becomes bx_le totality |

**Resolution**: In the Bundle path, forward Until coherence is indeed structurally blocked by Lindenbaum extension freedom. The BXCanonical path reformulates the question: instead of "does Until persist through chain steps?", it asks "is the bx_le ordering linear enough to verify guards?" This is a genuinely different question that has NOT been explored in 43 prior rounds.

### Gaps Identified

1. **BX7 linearity → bx_le totality has never been attempted** (Gap 3 from Teammate C). This is the most promising unexplored direction.

2. **FMP trivial sorry was missed during BX refactoring** (Gap 4 from Teammate C). One-liner fix brings FMP path to 0 core-logic sorries.

3. **Burgess-Xu axiom 4 invalidity was not known** during task 83 report 35 analysis. The entire "derive Burgess-Xu 4" recommendation was based on a false premise.

4. **The reflexive/strict semantics tension** may be deeper than previously appreciated. BX8 creates the X = id collapse, which trivializes chain approaches but is mathematically correct under reflexive Until. The system's design choice (reflexive G/H/U/S) has far-reaching consequences that were not fully traced through prior research.

## Recommendations (Priority Order)

### 1. PRIMARY: Pursue BXCanonical + BX7 Linearity (50% viability, ~500-800 LOC)

The BXCanonical architecture has only 5 sorry sites, all reducing to bx_le ordering properties. Attempt to prove from BX7 that bx_le is sufficiently linear for interval-based guard verification.

**Concrete first steps**:
1. Read BXCanonical/Frame.lean in detail — understand what bx_le totality gives
2. Attempt to prove: for BXPoints w, u, v with bx_le w u and bx_le w v, either bx_le u v or bx_le v u
3. The proof should use BX7 (linearity of Until) applied to carefully chosen Until formulas at w

**Risk**: BX7 operates on formulas, not ordering directly. The translation from formula-level linearity to ordering linearity may require substantial derivation infrastructure.

### 2. SECONDARY: Fix FMP sorry and explore FMP completeness (40% viability, ~200-400 LOC)

Fix the trivial `temp_4` sorry in TruthPreservation.lean:263. Then investigate whether the FMP path can be extended from "non-provable → falsifiable in finite model" to full completeness. The finite setting may enable inductive arguments that fail in the infinite canonical model.

### 3. TERTIARY: Refactor truth lemma to restricted coherence (cleanup, ~200 LOC)

Define `restricted_forward_until_since_coherent root` and wire into the truth lemma. Does not close sorries but properly scopes the obligation and may enable future approaches.

### 4. DO NOT PURSUE

- **Enriched seed approaches**: Proven infeasible (43 prior rounds + this round confirms)
- **Deterministic/dovetailed chain approaches**: x_content triviality under reflexive semantics makes these degenerate
- **Burgess-Xu axiom 4 derivation**: Semantically invalid in this system
- **Simultaneous well-founded induction on Architecture A**: Unbreakable circularity
- **F-nesting depth induction**: Non-viable (task 83 report 30)

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|-----------------|
| A | Restricted deferral closure + novel approaches | completed | Rigorous proof that restriction doesn't reduce difficulty; confirmed dovetailed forward_F doesn't extend to forward Until; found hidden sorry in restricted_forward_F fuel argument |
| B | Well-founded induction + finite deferral | completed | Proved circularity unbreakable for Architecture A; discovered X(α) = α under reflexive semantics; showed Architecture B already avoids the circularity for forward_F |
| C | Quasimodel + critical analysis | completed | **Critical**: Burgess-Xu axiom 4 invalid; x_content triviality confirmed; identified BXCanonical path as 5-sorry (vs 40+ Bundle); found trivially fixable FMP sorry; recommended BX7 linearity approach |

## References

### Key Files
- `BXCanonical/Frame.lean:501-605` — 4 sorry sites (Until/Since eventuality + backward)
- `BXCanonical/Completeness.lean:144` — 1 sorry (completeness theorem)
- `FMP/TruthPreservation.lean:263` — 1 trivially fixable sorry (temp_4)
- `Soundness.lean:397-401` — Comment confirming Burgess-Xu 4 invalidity
- `UntilSinceCoherence.lean:33-34` — x_content(M) = M confirmation
- `Bundle/SuccChainFMCS.lean:3042` — Hidden fuel exhaustion sorry
- `Axioms.lean:197-199` — BX8 reflexive Until introduction

### Prior Research Referenced
- Task 83 report 24: Quasimodel-filtration study (partially corrected here)
- Task 83 report 30: Pull-before-push philosophy, tuple construction
- Task 83 report 35: Burgess-Xu axiom 4 recommendation (**invalidated here**)
- Task 84 report 04: Definitive G-lift incompatibility (confirmed)
